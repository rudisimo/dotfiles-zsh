#!/bin/bash -eu

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# configure oh-my-zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
ln -sf $BASEDIR/dist/zshrc $HOME/.zshrc

# configure vim
git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
ln -sf $BASEDIR/dist/vimrc $HOME/.vimrc

# configure tmux
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
ln -sf $BASEDIR/dist/tmux.conf $HOME/.tmux.conf
