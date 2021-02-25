# dotfiles-zsh

This repository configures a POSIX-compatible shell to my liking.

## Requirements

- `curl`
- `zsh`

## Requirements

Update your shell to Zsh:

    chsh -s `which zsh`

## Installation

Using cURL:

```bash
curl -s https://raw.githubusercontent.com/rudisimo/dotfiles-zsh/master/install.sh?flush_cache=True | bash -s -- -v
```

Using git:

```bash
git clone https://github.com/rudisimo/dotfiles-zsh.git ~/.dotfiles-zsh && ~/.dotfiles-zsh/install.sh
```

Install one of the fonts in the `fonts` directory, according to your OS.

Install one of the themes in the `themes` directory, according to your Terminal.

## License

This work is licensed under MIT.

`SPDX-License-Identifier: MIT`