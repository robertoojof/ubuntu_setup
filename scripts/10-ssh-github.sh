#!/usr/bin/env bash
# Gera uma chave SSH para o GitHub (email lido do .env), configura o
# ~/.ssh/config e ajuda a cadastrar a chave na conta.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ENV_FILE="$(dirname "$0")/../.env"
KEY="$HOME/.ssh/id_ed25519"
# Chave publicada pelo GitHub (https://api.github.com/meta).
GITHUB_HOST_KEY="github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"

if [[ ! -f "$ENV_FILE" ]]; then
  error "Arquivo .env não encontrado; rode: cp .env.example .env e preencha"
  exit 1
fi
source "$ENV_FILE"
if [[ -z "${GITHUB_EMAIL:-}" ]]; then
  error "Preencha GITHUB_EMAIL no .env"
  exit 1
fi

apt_install openssh-client xdg-utils

# --- Chave ---------------------------------------------------------------------
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ -f "$KEY" ]]; then
  success "Chave $KEY já existe"
else
  info "Gerando chave SSH para $GITHUB_EMAIL (escolha uma senha ou deixe vazio)"
  ssh-keygen -t ed25519 -C "$GITHUB_EMAIL" -f "$KEY"
fi

# --- ~/.ssh/config e known_hosts -----------------------------------------------------
write_block "$HOME/.ssh/config" github <<EOF
Host github.com
  User git
  IdentityFile $KEY
  AddKeysToAgent yes
EOF
chmod 600 "$HOME/.ssh/config"

touch "$HOME/.ssh/known_hosts"
grep -qxF "$GITHUB_HOST_KEY" "$HOME/.ssh/known_hosts" || echo "$GITHUB_HOST_KEY" >>"$HOME/.ssh/known_hosts"
success "~/.ssh/config e known_hosts configurados para o GitHub"

# --- Cadastro no GitHub --------------------------------------------------------------
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  success "Chave já cadastrada no GitHub"
  exit 0
fi

echo
info "Sua chave pública (cole em https://github.com/settings/ssh/new):"
cat "$KEY.pub"
echo
if command -v wl-copy &>/dev/null; then
  wl-copy <"$KEY.pub" && success "Chave copiada para a área de transferência"
elif command -v xclip &>/dev/null; then
  xclip -selection clipboard <"$KEY.pub" && success "Chave copiada para a área de transferência"
fi
xdg-open "https://github.com/settings/ssh/new" &>/dev/null || true

read -rp "Depois de adicionar a chave no GitHub, aperte Enter para testar... "
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  success "Conexão SSH com o GitHub funcionando"
else
  error "Falha ao autenticar; confira se a chave foi adicionada e rode: ./install.sh ssh-github"
  exit 1
fi
