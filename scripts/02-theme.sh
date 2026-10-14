#!/usr/bin/env bash
# Instala o tema Aphrodite no Oh My Zsh e o define como tema do zsh.
# https://github.com/win0err/aphrodite-terminal-theme
#
# @title Tema Aphrodite no zsh
# @check grep -q '^ZSH_THEME="aphrodite/aphrodite"' $HOME/.zshrc
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ZSHRC="$HOME/.zshrc"
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/aphrodite"

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  error "Oh My Zsh não encontrado; rode antes: ./install.sh zsh"
  exit 1
fi

if [[ -d "$THEME_DIR/.git" ]]; then
  info "Atualizando tema Aphrodite"
  git -C "$THEME_DIR" pull --quiet
else
  info "Instalando tema Aphrodite"
  git clone --quiet https://github.com/win0err/aphrodite-terminal-theme "$THEME_DIR"
fi

# Equivalente a `omz theme set aphrodite/aphrodite`, sem precisar de um zsh interativo.
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="aphrodite/aphrodite"|' "$ZSHRC"
  success "Tema Aphrodite definido em $ZSHRC"
else
  error "Linha ZSH_THEME não encontrada em $ZSHRC"
  exit 1
fi
