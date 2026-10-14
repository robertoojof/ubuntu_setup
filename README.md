# ubuntu_setup

Scripts para configurar o Ubuntu depois da formatação.

## Uso

```bash
git clone <url-deste-repo> ~/ubuntu_setup
cd ~/ubuntu_setup
./install.sh              # roda tudo, em ordem
./install.sh zsh fonts    # roda só os passos escolhidos
```

Os scripts podem ser rodados mais de uma vez sem problema: o que já estiver
instalado é pulado.

## Passos

| Script | O que faz |
| --- | --- |
| `scripts/00-update.sh` | `apt update` + `apt upgrade` |
| `scripts/01-zsh.sh` | Instala zsh, define como shell padrão, Oh My Zsh, zinit e os plugins (fast-syntax-highlighting, zsh-autosuggestions, zsh-completions) |
| `scripts/02-theme.sh` | Instala o tema [Aphrodite](https://github.com/win0err/aphrodite-terminal-theme) no Oh My Zsh e o define como `ZSH_THEME` |
| `scripts/03-fonts.sh` | Instala Fira Code (apt) e a Nerd Font BitstreamVeraSansMono em `~/.local/share/fonts` |
| `scripts/04-nvm.sh` | Instala o nvm, carrega no `.zshrc`/`.bashrc` e instala o Node LTS como versão padrão |
| `scripts/05-pyenv.sh` | Instala o pyenv, o último Python 3 estável como global, o alias `py` e atualiza o pip se necessário (outra versão: `PYTHON_VERSION=3.12 ./install.sh pyenv`) |
| `scripts/06-sdkman.sh` | Instala o SDKMAN!, carrega no `.zshrc`/`.bashrc` e instala o Java LTS mais recente (Temurin) como padrão |
| `scripts/07-vscode.sh` | Baixa o `.deb` mais recente do VS Code direto do site e instala, adicionando o repositório da Microsoft para atualizar via `apt` |
| `scripts/08-docker.sh` | Instala o Docker Engine (repositório oficial), o Docker Desktop e adiciona o usuário aos grupos `docker`/`kvm` para usar sem `sudo` |
| `scripts/09-chrome.sh` | Baixa e instala o Google Chrome, garante o repositório apt para atualizações e o define como navegador padrão |

Para adicionar um novo passo, crie `scripts/NN-nome.sh` (o número define a ordem).

## Depois de rodar

- Faça **logout/login** para o zsh virar o shell padrão e para usar o
  `docker` sem `sudo`.
- O `docker` tem dois contextos: `default` (Docker Engine) e `desktop-linux`
  (Docker Desktop, ativo quando ele está aberto). Troque com
  `docker context use <nome>`.
- Nas preferências do terminal, ative **Fonte personalizada** e escolha
  `Fira Code Medium` (ou a Nerd Font). Feche e abra o terminal.

O passo a passo manual original está em `Personalizado_o_terminal_do_linux.pdf`.
