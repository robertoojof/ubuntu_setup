#!/usr/bin/env bash
# Baixa e instala o Google Chrome, garante o repositório apt para atualizações
# e o define como navegador padrão.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

KEYRING="/etc/apt/keyrings/google-chrome.asc"
SOURCES="/etc/apt/sources.list.d/google-chrome.sources"

if [[ "$(dpkg --print-architecture)" != amd64 ]]; then
  warn "Google Chrome para Linux só tem pacote amd64; pulando"
  exit 0
fi

apt_install wget xdg-utils

# --- Instalação --------------------------------------------------------------
if dpkg -s google-chrome-stable &>/dev/null; then
  success "Google Chrome já instalado"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  # O apt baixa como usuário _apt; precisa conseguir ler o .deb.
  chmod 755 "$tmp"

  info "Baixando Google Chrome (última versão estável)"
  wget -q --show-progress -O "$tmp/google-chrome.deb" \
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

  info "Instalando Google Chrome"
  sudo apt-get install -y "$tmp/google-chrome.deb"
fi

# --- Repositório apt ---------------------------------------------------------
# O .deb normalmente já adiciona o repositório; só criamos se não existir.
if grep -rqs 'dl.google.com/linux/chrome/deb' /etc/apt/sources.list.d/; then
  success "Repositório do Chrome já configurado"
else
  info "Adicionando repositório apt do Google Chrome"
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo wget -q -O "$KEYRING" https://dl.google.com/linux/linux_signing_key.pub
  sudo chmod a+r "$KEYRING"
  sudo tee "$SOURCES" >/dev/null <<EOF
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: $KEYRING
EOF
  sudo apt-get update
fi

# --- Navegador padrão ----------------------------------------------------------
info "Definindo Google Chrome como navegador padrão"
xdg-settings set default-web-browser google-chrome.desktop
sudo update-alternatives --set x-www-browser /usr/bin/google-chrome-stable
sudo update-alternatives --set gnome-www-browser /usr/bin/google-chrome-stable

success "$(google-chrome --version) instalado e definido como padrão"
