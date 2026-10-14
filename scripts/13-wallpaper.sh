#!/usr/bin/env bash
# Aplica como wallpaper (modo claro, escuro e tela de bloqueio) a imagem que
# estiver em config/wallpaper/.
#
# @title Wallpaper
# @check img="$(ls config/wallpaper/*.{jpg,jpeg,png,webp} 2>/dev/null | head -n1)"; [[ -n "$img" ]] && gsettings get org.gnome.desktop.background picture-uri | grep -qF "/backgrounds/${img##*/}'"
set -euo pipefail
source "$(dirname "$0")/lib.sh"

SRC_DIR="$(dirname "$0")/../config/wallpaper"
DEST_DIR="$HOME/.local/share/backgrounds"

shopt -s nullglob nocaseglob
images=("$SRC_DIR"/*.{jpg,jpeg,png,webp})
shopt -u nullglob nocaseglob

if ((${#images[@]} == 0)); then
  warn "Nenhuma imagem em config/wallpaper/; coloque uma lá e rode: ./install.sh wallpaper"
  exit 0
fi
((${#images[@]} == 1)) || warn "Mais de uma imagem em config/wallpaper/; usando ${images[0]##*/}"

if ! command -v gsettings &>/dev/null; then
  warn "gsettings não encontrado (GNOME); wallpaper não aplicado"
  exit 0
fi

mkdir -p "$DEST_DIR"
dest="$DEST_DIR/${images[0]##*/}"
cp "${images[0]}" "$dest"
uri="file://$dest"

info "Aplicando wallpaper ${dest##*/}"
gsettings set org.gnome.desktop.background picture-uri "$uri"
gsettings set org.gnome.desktop.background picture-uri-dark "$uri"
gsettings set org.gnome.desktop.background picture-options zoom
gsettings set org.gnome.desktop.screensaver picture-uri "$uri"

success "Wallpaper aplicado (claro, escuro e tela de bloqueio)"
