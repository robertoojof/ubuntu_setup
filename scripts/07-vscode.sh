#!/usr/bin/env bash
# Baixa e instala a versão mais recente do VS Code direto do site, aceitando
# adicionar o repositório da Microsoft para atualizar depois via apt.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

if command -v code &>/dev/null; then
  success "VS Code já instalado; atualize com: sudo apt update && sudo apt upgrade"
  exit 0
fi

case "$(dpkg --print-architecture)" in
  amd64) arch=x64 ;;
  arm64) arch=arm64 ;;
  armhf) arch=armhf ;;
  *) error "Arquitetura não suportada: $(dpkg --print-architecture)"; exit 1 ;;
esac

apt_install wget

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
# O apt baixa como usuário _apt; precisa conseguir ler o .deb.
chmod 755 "$tmp"

info "Baixando VS Code (última versão estável)"
wget -q --show-progress -O "$tmp/code.deb" \
  "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-$arch"

# Responde "sim" à pergunta de adicionar o repositório da Microsoft.
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

info "Instalando VS Code"
sudo apt-get install -y "$tmp/code.deb"

success "VS Code $(code --version | head -n1) instalado; atualizações chegam via apt"
