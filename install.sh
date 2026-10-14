#!/usr/bin/env bash
# Roda todos os scripts de setup em ordem, ou apenas os passados como argumento.
#   ./install.sh            # roda tudo
#   ./install.sh zsh fonts  # roda só os scripts que casam com esses nomes
set -euo pipefail
cd "$(dirname "$0")"
source scripts/lib.sh

if [[ $EUID -eq 0 ]]; then
  error "Não rode como root; o script usa sudo quando precisa."
  exit 1
fi

scripts=()
if (($#)); then
  for name in "$@"; do
    match=(scripts/[0-9][0-9]-"$name".sh)
    [[ -f "${match[0]}" ]] || { error "Script não encontrado: $name"; exit 1; }
    scripts+=("${match[0]}")
  done
else
  scripts=(scripts/[0-9][0-9]-*.sh)
fi

for script in "${scripts[@]}"; do
  info "Executando $script"
  bash "$script"
done

success "Setup concluído!"
