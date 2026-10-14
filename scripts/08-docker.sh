#!/usr/bin/env bash
# Instala o Docker Engine (repositório oficial) e o Docker Desktop, e libera o
# uso do docker no terminal sem sudo.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

KEYRING="/etc/apt/keyrings/docker.asc"
SOURCES="/etc/apt/sources.list.d/docker.sources"

# --- Repositório apt oficial do Docker ----------------------------------------
apt_install ca-certificates curl wget

if [[ ! -f "$SOURCES" ]]; then
  info "Adicionando repositório apt do Docker"
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$KEYRING"
  sudo chmod a+r "$KEYRING"
  sudo tee "$SOURCES" >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: $KEYRING
EOF
  sudo apt-get update
else
  success "Repositório do Docker já configurado"
fi

# --- Docker Engine -------------------------------------------------------------
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Docker sem sudo -------------------------------------------------------------
# Grupo docker: acesso ao Docker Engine. Grupo kvm: exigido pelo Docker Desktop.
for group in docker kvm; do
  getent group "$group" >/dev/null || sudo groupadd "$group"
  if id -nG "$USER" | grep -qw "$group"; then
    success "$USER já está no grupo $group"
  else
    info "Adicionando $USER ao grupo $group"
    sudo usermod -aG "$group" "$USER"
    warn "Faça logout/login para usar o docker sem sudo"
  fi
done

# --- Docker Desktop --------------------------------------------------------------
if dpkg -s docker-desktop &>/dev/null; then
  success "Docker Desktop já instalado"
elif [[ "$(dpkg --print-architecture)" != amd64 ]]; then
  warn "Docker Desktop para Linux só tem pacote amd64; pulando"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  # O apt baixa como usuário _apt; precisa conseguir ler o .deb.
  chmod 755 "$tmp"

  info "Baixando Docker Desktop (última versão)"
  wget -q --show-progress -O "$tmp/docker-desktop-amd64.deb" \
    "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"

  info "Instalando Docker Desktop"
  sudo apt-get install -y "$tmp/docker-desktop-amd64.deb"
fi

success "Docker $(docker --version | cut -d' ' -f3 | tr -d ,) instalado"
