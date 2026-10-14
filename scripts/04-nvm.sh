#!/usr/bin/env bash
# Instala o nvm e a versão LTS do Node (definida como padrão).
#
# @title nvm + Node LTS
# @check [[ -s $HOME/.nvm/nvm.sh ]] && ls $HOME/.nvm/versions/node/* -d
set -euo pipefail
source "$(dirname "$0")/lib.sh"

NVM_VERSION="v0.40.8"
export NVM_DIR="$HOME/.nvm"

apt_install curl git

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  success "nvm já instalado"
else
  info "Instalando nvm $NVM_VERSION"
  # PROFILE=/dev/null: não deixa o instalador mexer nos rc; fazemos isso abaixo.
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" \
    | PROFILE=/dev/null bash
fi

# Carrega o nvm nos shells (zsh e bash).
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  write_block "$rc" nvm <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
done
success "nvm configurado no .zshrc e .bashrc"

# nvm.sh não é compatível com `set -u`.
set +u
source "$NVM_DIR/nvm.sh"
info "Instalando Node LTS"
nvm install --lts
nvm alias default 'lts/*'
set -u

success "Node $(node --version) / npm $(npm --version) instalados"
