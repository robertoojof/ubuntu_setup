#!/usr/bin/env bash
# Instala o SDKMAN! e o Java LTS mais recente (Temurin) como padrão.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

export SDKMAN_DIR="$HOME/.sdkman"

apt_install curl zip unzip

if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  success "SDKMAN já instalado"
else
  info "Instalando SDKMAN"
  # rcupdate=false: não deixa o instalador mexer nos rc; fazemos isso abaixo.
  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
fi

# Carrega o SDKMAN nos shells (o SDKMAN pede para ficar no fim do arquivo).
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  write_block "$rc" sdkman <<'EOF'
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
done
success "SDKMAN configurado no .zshrc e .bashrc"

# Descobre o LTS mais recente (Adoptium) e o identificador Temurin correspondente no SDKMAN.
lts="$(curl -fsSL https://api.adoptium.net/v3/info/available_releases | grep -oE '"most_recent_lts": *[0-9]+' | grep -oE '[0-9]+$')"
java_id="$(curl -fsSL "https://api.sdkman.io/2/candidates/java/linuxx64/versions/list?installed=" \
  | grep -oE "\b$lts\.[^ |]*-tem\b" | sort -V | tail -n1)"
if [[ -z "$java_id" ]]; then
  error "Não achei uma versão Temurin do Java $lts no SDKMAN"
  exit 1
fi

# sdkman-init.sh não é compatível com `set -u`.
set +u
export sdkman_auto_answer=true
source "$SDKMAN_DIR/bin/sdkman-init.sh"
info "Instalando Java $java_id (LTS $lts)"
sdk install java "$java_id"
sdk default java "$java_id"
set -u

success "$(java -version 2>&1 | head -n1) configurado como padrão"
