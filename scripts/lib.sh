#!/usr/bin/env bash
# Funções compartilhadas entre os scripts de setup.

info()    { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m✔\033[0m %s\n' "$*"; }
warn()    { printf '\033[1;33m!\033[0m %s\n' "$*"; }
error()   { printf '\033[1;31m✖\033[0m %s\n' "$*" >&2; }

# Instala pacotes apt apenas se ainda não estiverem instalados.
apt_install() {
  local missing=()
  for pkg in "$@"; do
    dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if ((${#missing[@]})); then
    info "Instalando: ${missing[*]}"
    sudo apt-get install -y "${missing[@]}"
  else
    success "Já instalados: $*"
  fi
}
