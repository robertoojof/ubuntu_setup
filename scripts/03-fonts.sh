#!/usr/bin/env bash
# Instala as fontes: Nerd Font (ícones) e Fira Code (ligatures).
#
# @title Fontes (Fira Code e Nerd Font)
# @check dpkg -s fonts-firacode && compgen -G "$HOME/.local/share/fonts/BitstreamVeraSansMono/*.ttf"
set -euo pipefail
source "$(dirname "$0")/lib.sh"

NERD_FONTS_VERSION="v3.4.0"
NERD_FONT="BitstreamVeraSansMono"
FONTS_DIR="$HOME/.local/share/fonts"

apt_install fonts-firacode unzip wget fontconfig

if compgen -G "$FONTS_DIR/$NERD_FONT/*.ttf" >/dev/null; then
  success "Nerd Font $NERD_FONT já instalada"
else
  info "Baixando Nerd Font $NERD_FONT ($NERD_FONTS_VERSION)"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  wget -q -O "$tmp/font.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/$NERD_FONT.zip"
  mkdir -p "$FONTS_DIR/$NERD_FONT"
  unzip -oq "$tmp/font.zip" -d "$FONTS_DIR/$NERD_FONT"
  fc-cache -f "$FONTS_DIR"
  success "Nerd Font instalada em $FONTS_DIR/$NERD_FONT"
fi

warn "Lembre de escolher a fonte nas preferências do terminal (ex.: Fira Code Medium) e reabrir o terminal"
