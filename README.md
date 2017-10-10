# dotfiles2

This repository setups an environment to my liking.

## Requirements
* git
* zsh
* tmux
* vim

## Usage

Switch your shell to ZSH:

    chsh -s /bin/zsh

Using git:

    git clone https://github.com/rudisimo/dotfiles2.git ~/.dotfiles && \
        ~/.dotfiles/install.sh -a

Without git:

    curl -#skfL https://github.com/rudisimo/dotfiles2/tarball/master | tar xzv --strip-components 1 -C ~/.dotfiles -- && \
        ~/.dotfiles/install.sh -n -a
