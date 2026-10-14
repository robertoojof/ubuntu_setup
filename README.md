# ubuntu_setup

Scripts para configurar o Ubuntu depois da formatação.

## Uso

```bash
git clone <url-deste-repo> ~/ubuntu_setup
cd ~/ubuntu_setup
./install.sh              # abre o menu
./install.sh --all        # roda tudo, sem menu
./install.sh zsh fonts    # roda só os passos escolhidos, sem menu
```

O menu (feito com `whiptail`) mostra todos os passos, já desmarcando o que
estiver instalado. Ele pede o que faltar no `.env` (nome, email), pede a senha
do `sudo` uma vez só, mostra uma barra de progresso e, no fim, um resumo com o
que deu certo, o que falhou e os próximos passos. A saída completa fica em
`logs/`.

Sem o menu, preencha o `.env` antes: `cp .env.example .env`.

Os scripts podem ser rodados mais de uma vez sem problema: o que já estiver
instalado é pulado.

## Passos

| Script | O que faz |
| --- | --- |
| `scripts/00-update.sh` | `apt update` + `apt upgrade` |
| `scripts/01-zsh.sh` | Instala zsh, define como shell padrão, Oh My Zsh, zinit e os plugins listados em [`config/zsh-plugins.txt`](config/zsh-plugins.txt) |
| `scripts/02-theme.sh` | Instala o tema [Aphrodite](https://github.com/win0err/aphrodite-terminal-theme) no Oh My Zsh e o define como `ZSH_THEME` |
| `scripts/03-fonts.sh` | Instala Fira Code (apt) e a Nerd Font BitstreamVeraSansMono em `~/.local/share/fonts` |
| `scripts/04-nvm.sh` | Instala o nvm, carrega no `.zshrc`/`.bashrc` e instala o Node LTS como versão padrão |
| `scripts/05-pyenv.sh` | Instala o pyenv, o último Python 3 estável como global, o alias `py` e atualiza o pip se necessário (outra versão: `PYTHON_VERSION=3.12 ./install.sh pyenv`) |
| `scripts/06-sdkman.sh` | Instala o SDKMAN!, carrega no `.zshrc`/`.bashrc` e instala o Java LTS mais recente (Temurin) como padrão |
| `scripts/07-vscode.sh` | Baixa o `.deb` mais recente do VS Code direto do site e instala, adicionando o repositório da Microsoft para atualizar via `apt` |
| `scripts/08-docker.sh` | Instala o Docker Engine (repositório oficial), o Docker Desktop e adiciona o usuário aos grupos `docker`/`kvm` para usar sem `sudo` |
| `scripts/09-chrome.sh` | Baixa e instala o Google Chrome, garante o repositório apt para atualizações e o define como navegador padrão |
| `scripts/10-ssh-github.sh` | Gera a chave SSH (`ed25519`) com o email do `.env`, configura `~/.ssh/config`/`known_hosts`, abre a página do GitHub para cadastrar a chave e testa a conexão |
| `scripts/11-git.sh` | Configura `user.name` e `user.email` globais do git com `GIT_NAME`/`GIT_EMAIL` do `.env` |
| `scripts/12-pgadmin.sh` | Instala o pgAdmin 4 Desktop (sem o modo web) seguindo as [instruções do site](https://www.pgadmin.org/download/pgadmin-4-apt/), com o repositório apt para atualizações |

### Plugins do zsh

Os plugins ficam em [`config/zsh-plugins.txt`](config/zsh-plugins.txt), um
por linha no formato `usuario/repo` do GitHub. Edite a lista e rode
`./install.sh zsh` para atualizar o `.zshrc` (no menu, esse passo aparece como
instalado; marque-o mesmo assim).

## Novos passos

Para adicionar um novo passo, crie `scripts/NN-nome.sh` (o número define a
ordem) com o cabeçalho que o menu usa:

```bash
#!/usr/bin/env bash
# O que o script faz.
#
# @title Nome que aparece no menu
# @check comando que retorna 0 se o passo já está feito (opcional)
# @env VARIAVEL_DO_ENV OUTRA (opcional)
# @interactive    (opcional: o passo pede algo no terminal)
```

## Depois de rodar

- Faça **logout/login** para o zsh virar o shell padrão e para usar o
  `docker` sem `sudo`.
- O `docker` tem dois contextos: `default` (Docker Engine) e `desktop-linux`
  (Docker Desktop, ativo quando ele está aberto). Troque com
  `docker context use <nome>`.
- Nas preferências do terminal, ative **Fonte personalizada** e escolha
  `Fira Code Medium` (ou a Nerd Font). Feche e abra o terminal.
