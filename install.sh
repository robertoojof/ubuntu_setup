#!/usr/bin/env bash
# Setup do Ubuntu.
#   ./install.sh            # abre o menu (whiptail) para escolher os passos
#   ./install.sh --all      # roda tudo, sem menu
#   ./install.sh zsh fonts  # roda só os passos com esses nomes, sem menu
#
# Cada scripts/NN-nome.sh descreve a si mesmo no cabeçalho:
#   # @title  Nome que aparece no menu
#   # @check  comando que retorna 0 se o passo já está feito
#   # @env    variáveis do .env que o passo precisa
#   # @interactive  o passo pede algo no terminal (roda fora da barra de progresso)
set -euo pipefail
cd "$(dirname "$0")"
source scripts/lib.sh

TITLE="Ubuntu Setup"

if [[ $EUID -eq 0 ]]; then
  error "Não rode como root; o script usa sudo quando precisa."
  exit 1
fi

# --- Metadados dos scripts --------------------------------------------------------

step_name() { local n="${1##*/}"; n="${n%.sh}"; echo "${n#[0-9][0-9]-}"; }
step_meta() { sed -n "s/^# @$2 *//p" "$1" | head -n1; }
step_has()  { grep -q "^# @$2\$" "$1"; }

step_done() {
  local check
  check="$(step_meta "$1" check)"
  [[ -n "$check" ]] && timeout 10 bash -c "$check" &>/dev/null
}

# --- Modo sem menu ------------------------------------------------------------------

run_plain() {
  for script in "$@"; do
    info "Executando $script"
    bash "$script"
  done
  success "Setup concluído!"
}

if [[ "${1:-}" == "--all" ]]; then
  run_plain scripts/[0-9][0-9]-*.sh
  exit
elif (($#)); then
  scripts=()
  for name in "$@"; do
    match=(scripts/[0-9][0-9]-"$name".sh)
    [[ -f "${match[0]}" ]] || { error "Script não encontrado: $name"; exit 1; }
    scripts+=("${match[0]}")
  done
  run_plain "${scripts[@]}"
  exit
fi

# --- Menu -------------------------------------------------------------------------------

if [[ ! -t 0 || ! -t 1 ]]; then
  error "Sem terminal interativo para o menu; use: ./install.sh --all"
  exit 1
fi

command -v whiptail &>/dev/null || apt_install whiptail

# Escolha dos passos: os já feitos vêm desmarcados.
items=()
for script in scripts/[0-9][0-9]-*.sh; do
  title="$(step_meta "$script" title)"
  if step_done "$script"; then
    # ${#title} conta caracteres (printf %-Ns contaria bytes e desalinharia acentos).
    items+=("$(step_name "$script")" "$title$(printf '%*s' $((47 - ${#title})) '')[instalado]" OFF)
  else
    items+=("$(step_name "$script")" "$title" ON)
  fi
done

selected="$(whiptail --title "$TITLE" --separate-output \
  --checklist "Espaço marca/desmarca, Enter confirma.\nO que já está instalado vem desmarcado." \
  22 78 13 "${items[@]}" 3>&1 1>&2 2>&3)" || exit 0
mapfile -t selected <<<"$selected"
[[ -n "${selected[0]:-}" ]] || { whiptail --title "$TITLE" --msgbox "Nada selecionado." 8 40; exit 0; }

steps=()
for name in "${selected[@]}"; do steps+=(scripts/[0-9][0-9]-"$name".sh); done

# Pede as variáveis do .env que faltarem para os passos escolhidos.
env_get() { [[ -f .env ]] && (source .env && echo "${!1:-}"); }
env_set() {
  [[ -f .env ]] || cp .env.example .env
  LINE="$1=$(printf '%q' "$2")" awk -v k="$1" '
    $0 ~ "^" k "=" { print ENVIRON["LINE"]; found = 1; next } { print }
    END { if (!found) print ENVIRON["LINE"] }' .env >.env.tmp
  mv .env.tmp .env
}

declare -A asked=()
for script in "${steps[@]}"; do
  for var in $(step_meta "$script" env); do
    [[ -z "${asked[$var]:-}" && -z "$(env_get "$var")" ]] || continue
    default=""
    [[ "$var" == GIT_EMAIL ]] && default="$(env_get GITHUB_EMAIL)"
    value="$(whiptail --title "$TITLE" --inputbox \
      "$(step_meta "$script" title)\n\nInforme $var (fica salvo no .env):" \
      11 70 "$default" 3>&1 1>&2 2>&3)" || exit 0
    env_set "$var" "$value"
    asked[$var]=1
  done
done

# sudo uma vez só, mantido ativo enquanto o setup roda.
clear
info "Digite sua senha para o sudo (usada pelos passos de instalação)"
sudo -v
while sleep 50; do sudo -n true; kill -0 $$ 2>/dev/null || exit; done 2>/dev/null &
sudo_keepalive=$!

mkdir -p logs
LOG="logs/install-$(date +%Y%m%d-%H%M%S).log"
export SETUP_NOTES
SETUP_NOTES="$(mktemp)"
trap 'kill "$sudo_keepalive" 2>/dev/null; rm -f "$SETUP_NOTES"' EXIT

# Roda um passo escondido atrás da barra de progresso; saída vai para o log.
run_with_gauge() {
  local script="$1" title="$2" idx="$3" total="$4" start=$SECONDS
  echo "===== $script =====" >>"$LOG"
  bash "$script" </dev/null >>"$LOG" 2>&1 &
  local pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    local elapsed=$((SECONDS - start))
    printf 'XXX\n%d\nInstalando: %s\n\nPasso %d de %d  •  %dm%02ds\nXXX\n' \
      $(((idx - 1) * 100 / total)) "$title" "$idx" "$total" $((elapsed / 60)) $((elapsed % 60))
    sleep 1
  done | whiptail --title "$TITLE" --gauge "Instalando: $title" 9 70 0
  wait "$pid"
}

# Passos interativos rodam direto no terminal.
run_interactive() {
  local script="$1" title="$2"
  clear
  info "$title"
  echo "===== $script =====" >>"$LOG"
  local status=0
  bash "$script" 2>&1 | tee -a "$LOG" || status=${PIPESTATUS[0]}
  echo
  read -rp "Aperte Enter para continuar... "
  return "$status"
}

summary=""
failed=0
total=${#steps[@]}
for i in "${!steps[@]}"; do
  script="${steps[$i]}"
  title="$(step_meta "$script" title)"
  if step_has "$script" interactive; then
    run_interactive "$script" "$title" && ok=1 || ok=0
  else
    run_with_gauge "$script" "$title" $((i + 1)) "$total" && ok=1 || ok=0
  fi
  if ((ok)); then
    summary+="  ✔  $title\n"
  else
    summary+="  ✖  $title\n"
    failed=$((failed + 1))
  fi
done

# --- Resumo ------------------------------------------------------------------------------

text="$summary"
if ((failed)); then
  text+="\n$failed passo(s) falharam. Veja o log:\n  $LOG\n"
fi
notes="$(awk '!seen[$0]++' "$SETUP_NOTES")"
if [[ -n "$notes" ]]; then
  text+="\nPróximos passos:\n"
  while IFS= read -r note; do text+="  •  $note\n"; done <<<"$notes"
fi
text+="\nLog completo: $LOG"

whiptail --title "$TITLE — resumo" --scrolltext --msgbox "$text" 22 78
clear
((failed == 0)) && success "Setup concluído!" || { error "$failed passo(s) falharam; veja $LOG"; exit 1; }
