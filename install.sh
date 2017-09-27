#!/bin/bash -eu

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# configure git
cp $BASEDIR/dist/gitconfig $HOME/.gitconfig

# configure oh-my-zsh
[ ! -e "$HOME/.oh-my-zsh" ] && git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
cp $BASEDIR/dist/zshrc $HOME/.zshrc
cp $BASEDIR/dist/rudisimo.zsh-theme $HOME/.oh-my-zsh/themes/rudisimo.zsh-theme

# configure tmux
[ ! -e "$HOME/.tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
cp $BASEDIR/dist/tmux.conf $HOME/.tmux.conf
$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh

# configure vim
[ ! -e "$HOME/.vim/bundle/Vundle.vim" ] && git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
cp $BASEDIR/dist/vimrc $HOME/.vimrc
vim +BundleInstall +BundleClean +qall
