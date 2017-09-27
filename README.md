# dotfiles2

This repository setups an environment to my liking.

## Usage

Switch to ZSH shell:

    chsh -s zsh

Using git:

    git clone https://github.com/rudisimo/dotfiles2.git ~/.dotfiles && ~/.dotfiles/install.sh

Without git:

    curl -#skfL https://github.com/rudisimo/dotfiles2/tarball/master | tar xzv --strip-components 1 -C ~/.dotfiles -- && ~/.dotfiles/install.sh
