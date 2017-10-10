# dotfiles-zsh

This repository setups the terminal to "my" liking.

## Usage

Command line arguments of installation script.

    ./install.sh:
        -a  Install all configurations (-g -z -m -v)

        -g  Install git configuration
        -z  Install zsh configuration
        -m  Install tmux configuration
        -v  Install vim configuration

        -d  Use curl instead of git-clone

## Installation

Switch your shell to ZSH:

    chsh -s /bin/zsh

With git:

    git clone https://github.com/rudisimo/dotfiles2.git ~/.dotfiles2 \
        && ~/.dotfiles2/install.sh -a

Without git:

    curl -#skfL https://github.com/rudisimo/dotfiles2/tarball/master | tar xzv --strip-components 1 -C ~/.dotfiles2 -- \
        && ~/.dotfiles2/install.sh -a -d
