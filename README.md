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

| Script                    | O que faz                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------------- |
| `scripts/00-update.sh`    | `apt update` + `apt upgrade`                                                                |
| `scripts/01-zsh.sh`       | Instala zsh, define como shell padrão, Oh My Zsh, zinit e os plugins (fast-syntax-highlighting, zsh-autosuggestions, zsh-completions) |
| `scripts/02-fonts.sh`     | Instala Fira Code (apt) e a Nerd Font BitstreamVeraSansMono em `~/.local/share/fonts`       |

Para adicionar um novo passo, crie `scripts/NN-nome.sh` (o número define a ordem).

## Depois de rodar

- Faça **logout/login** para o zsh virar o shell padrão.
- Nas preferências do terminal, ative **Fonte personalizada** e escolha
  `Fira Code Medium` (ou a Nerd Font). Feche e abra o terminal.

O passo a passo manual original está em `Personalizado_o_terminal_do_linux.pdf`.
