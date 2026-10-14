#!/usr/bin/env bash
# Configura nome e email globais do git a partir do .env.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

load_env GIT_NAME GIT_EMAIL

apt_install git

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

success "git configurado: $(git config --global user.name) <$(git config --global user.email)>"
