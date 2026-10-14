#!/usr/bin/env bash
# Atualiza todos os pacotes do sistema.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

info "Atualizando pacotes do sistema"
sudo apt-get update
sudo apt-get upgrade -y
success "Sistema atualizado"
