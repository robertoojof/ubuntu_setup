#!/usr/bin/env bash
# Instala o pgAdmin 4 Desktop (sem o modo web) seguindo as instruções do site:
# https://www.pgadmin.org/download/pgadmin-4-apt/
#
# @title pgAdmin 4 Desktop
# @check dpkg -s pgadmin4-desktop
set -euo pipefail
source "$(dirname "$0")/lib.sh"

KEYRING="/etc/apt/keyrings/packages-pgadmin-org.gpg"
SOURCES="/etc/apt/sources.list.d/pgadmin4.list"

apt_install curl gpg lsb-release

if [[ ! -f "$SOURCES" ]]; then
  info "Adicionando repositório apt do pgAdmin"
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
    | sudo gpg --dearmor --yes -o "$KEYRING"
  echo "deb [signed-by=$KEYRING] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
    | sudo tee "$SOURCES" >/dev/null
  sudo apt-get update
else
  success "Repositório do pgAdmin já configurado"
fi

# pgadmin4-desktop: só o modo desktop (o pacote `pgadmin4` traz também o web).
apt_install pgadmin4-desktop

success "pgAdmin 4 Desktop instalado; atualizações chegam via apt"
