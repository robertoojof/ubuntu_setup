#!/usr/bin/env bash
# Instala o pyenv, a última versão estável do Python 3 (global), o alias `py`
# e atualiza o pip se houver versão nova.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

export PYENV_ROOT="$HOME/.pyenv"
# Python não tem LTS: por padrão usamos a última versão estável do 3.x.
# Para fixar outra, rode: PYTHON_VERSION=3.12 ./install.sh pyenv
PYTHON_VERSION="${PYTHON_VERSION:-3}"

# Dependências para compilar o Python (wiki do pyenv).
apt_install build-essential curl git libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libncurses-dev xz-utils tk-dev libxml2-dev \
  libxmlsec1-dev libffi-dev liblzma-dev libzstd-dev

if [[ -d "$PYENV_ROOT/.git" ]]; then
  info "Atualizando pyenv"
  git -C "$PYENV_ROOT" pull --quiet
elif [[ -d "$PYENV_ROOT" ]]; then
  warn "$PYENV_ROOT existe mas não é um clone git; usando como está"
else
  info "Instalando pyenv"
  git clone --quiet https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
fi

# Carrega o pyenv e o alias `py` nos shells.
for shell in zsh bash; do
  write_block "$HOME/.${shell}rc" pyenv <<EOF
export PYENV_ROOT="\$HOME/.pyenv"
[[ -d \$PYENV_ROOT/bin ]] && export PATH="\$PYENV_ROOT/bin:\$PATH"
eval "\$(pyenv init - $shell)"
alias py=python
EOF
done
success "pyenv e alias 'py' configurados no .zshrc e .bashrc"

export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

version="$(pyenv latest -k "$PYTHON_VERSION")"
info "Instalando Python $version"
pyenv install -s "$version"
pyenv global "$version"

if python -m pip list --outdated --format=freeze 2>/dev/null | grep -q '^pip='; then
  info "Atualizando pip"
  python -m pip install --upgrade pip
else
  success "pip já está atualizado"
fi

success "$(python --version) / pip $(python -m pip --version | cut -d' ' -f2) configurados como global"
