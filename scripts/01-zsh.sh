#!/usr/bin/env bash
# Instala zsh, Oh My Zsh, zinit e os plugins, e define o zsh como shell padrão.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ZSHRC="$HOME/.zshrc"
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

# --- zsh ---------------------------------------------------------------------
apt_install zsh curl git

ZSH_PATH="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
  info "Definindo zsh como shell padrão (pode pedir sua senha)"
  chsh -s "$ZSH_PATH"
  warn "Faça logout/login para o zsh virar o shell padrão"
else
  success "zsh já é o shell padrão"
fi

# --- Oh My Zsh ---------------------------------------------------------------
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  success "Oh My Zsh já instalado"
else
  info "Instalando Oh My Zsh"
  # RUNZSH=no: não abre um zsh no fim; CHSH=no: já tratamos acima.
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
fi

# --- zinit + plugins ---------------------------------------------------------
if [[ -d "$ZINIT_HOME" ]]; then
  info "Atualizando zinit"
  git -C "$ZINIT_HOME" pull --quiet
else
  info "Instalando zinit"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone --quiet https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

write_block "$ZSHRC" zinit <<EOF
source "$ZINIT_HOME/zinit.zsh"

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
EOF
success "Plugins do zinit configurados em $ZSHRC"
