#!/usr/bin/env bash
# Funções compartilhadas entre os scripts de setup.

info()    { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m✔\033[0m %s\n' "$*"; }
# Avisos também vão para $SETUP_NOTES (se definido), para o resumo do menu.
warn() {
  printf '\033[1;33m!\033[0m %s\n' "$*"
  [[ -z "${SETUP_NOTES:-}" ]] || echo "$*" >>"$SETUP_NOTES"
}
error()   { printf '\033[1;31m✖\033[0m %s\n' "$*" >&2; }

# Instala pacotes apt apenas se ainda não estiverem instalados.
apt_install() {
  local missing=()
  for pkg in "$@"; do
    dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if ((${#missing[@]})); then
    info "Instalando: ${missing[*]}"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
  else
    success "Já instalados: $*"
  fi
}

# Carrega o .env da raiz do repositório e exige as variáveis passadas.
# Uso: load_env VAR1 VAR2 ...
load_env() {
  local env_file
  env_file="$(dirname "${BASH_SOURCE[0]}")/../.env"
  if [[ ! -f "$env_file" ]]; then
    error "Arquivo .env não encontrado; rode: cp .env.example .env e preencha"
    exit 1
  fi
  source "$env_file"
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      error "Preencha $var no .env"
      exit 1
    fi
  done
}

# Escreve (ou substitui) um bloco gerenciado no final de um arquivo.
# Uso: write_block <arquivo> <nome> <<'EOF' ... EOF
write_block() {
  local file="$1" name="$2"
  local start="# >>> ubuntu_setup: $name >>>" end="# <<< ubuntu_setup: $name <<<"
  touch "$file"
  sed -i "/^$start\$/,/^$end\$/d" "$file"
  { echo "$start"; cat; echo "$end"; } >>"$file"
}
