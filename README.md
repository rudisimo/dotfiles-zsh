# dotfiles-zsh

[![CI](https://github.com/rudisimo/dotfiles-zsh/actions/workflows/ci.yml/badge.svg)](https://github.com/rudisimo/dotfiles-zsh/actions/workflows/ci.yml)

Configures [my](https://github.com/rudisimo) POSIX-compatible shells.

## Requirements

Install and update your shell to Zsh.

    chsh -s `which zsh`

## Installation

Using Git:

```bash
[ -d ~/.dotfiles-zsh ] && git -C ~/.dotfiles-zsh pull || git clone https://github.com/rudisimo/dotfiles-zsh ~/.dotfiles-zsh && ~/.dotfiles-zsh/install.sh -d
```

Using cURL (possibly [unsafe](https://security.stackexchange.com/questions/213401/is-curl-something-sudo-bash-a-reasonably-safe-installation-method)):

```bash
curl -s https://raw.githubusercontent.com/rudisimo/dotfiles-zsh/master/install.sh | bash -s -- -d
```

Install one of the fonts according to your OS, from the `fonts` directory.

Install one of the themes according to your terminal, from the `themes` directory.

## License

This work is licensed under the [MIT](LICENSE.txt) license.
