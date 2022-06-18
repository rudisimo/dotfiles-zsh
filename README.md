# dotfiles-zsh

[![CI](https://github.com/rudisimo/dotfiles-zsh/actions/workflows/ci.yml/badge.svg)](https://github.com/rudisimo/dotfiles-zsh/actions/workflows/ci.yml)

## Requirements

Install and update your shell to `zsh`.

    sudo apt update -y
    sudo apt install -y zsh
    chsh -s `which zsh`

## Installation

Using Git:

    git clone https://github.com/rudisimo/dotfiles-zsh ~/.dotfiles-zsh && sh ~/.dotfiles-zsh/install.sh -v

Using cURL (possibly [unsafe](https://security.stackexchange.com/questions/213401/is-curl-something-sudo-bash-a-reasonably-safe-installation-method)):

    curl -sfL https://raw.githubusercontent.com/rudisimo/dotfiles-zsh/master/install.sh | sh -s -- -v --force

Install one of the fonts according to your OS, from the `fonts` directory.

Install one of the themes according to your terminal, from the `themes` directory.

## License

This work is licensed under the [MIT](LICENSE) license.
