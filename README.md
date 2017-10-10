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

Using git:

    git clone https://github.com/rudisimo/dotfiles-zsh.git ~/.dotfiles-zsh \
    && ~/.dotfiles-zsh/install.sh -a

Using cURL:

    mkdir ~/.dotfiles-zsh \
    && curl -#skfL https://github.com/rudisimo/dotfiles-zsh/tarball/master | tar xzv --strip-components 1 -C ~/.dotfiles-zsh \
    && ~/.dotfiles-zsh/install.sh -a -d
