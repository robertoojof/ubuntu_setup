#!/usr/bin/env bash
# Atualiza todos os pacotes do sistema.
#
# @title Atualizar pacotes do sistema
set -euo pipefail
source "$(dirname "$0")/lib.sh"

info "Atualizando pacotes do sistema"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold
success "Sistema atualizado"
