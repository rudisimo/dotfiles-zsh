# dotfiles-zsh

This repository setups the terminal to "my" liking.

## Requirements

- [git][git]
- [zsh][zsh]
- [nerd-fonts][nerd-fonts]

## Usage

Command line arguments of installation script.

    ./install.sh:
        -g  Install git configuration
        -z  Install zsh configuration
        -m  Install tmux configuration
        -v  Install vim configuration

        -a  Install all configurations (-g -z -m -v)

## Installation

Switch your shell to ZSH:

    chsh -s /bin/zsh

Using git:

    git clone https://github.com/rudisimo/dotfiles-zsh.git ~/.dotfiles-zsh \
    && ~/.dotfiles-zsh/install.sh -a

Using cURL:

    mkdir ~/.dotfiles-zsh \
    && curl -#skfL https://github.com/rudisimo/dotfiles-zsh/tarball/master | tar xzv --strip-components 1 -C ~/.dotfiles-zsh \
    && ~/.dotfiles-zsh/install.sh -a

[git]: https://git-scm.com/downloads
[zsh]: http://zsh.sourceforge.net/
[nerd-fonts]: https://github.com/ryanoasis/nerd-fonts
