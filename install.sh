#!/bin/bash -eu

# checks if the given command is installed
is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# checks if the target can be configured
is_configurable() {
    if is_installed "$1"; then
        echo "1"
    fi
}

# downloads the given repository from github only once
download_once() {
    local repository="$1"
    local destination="$2"
    local git_clone="${3-}"

    if [ ! -d "$destination" ]; then
        if [ -n "$git_clone" ]; then
            git clone -q "https://github.com/${repository}.git" "$destination"
        else
            mkdir -p $destination
            curl -#skfL "https://github.com/${repository}/tarball/master" | tar xzv --strip-components 1 -C $destination
        fi
    fi
}

# Check hard requirements
if ! is_installed "git"; then
    (>&2 echo "Git does not appear to be installed and it is a requirement.")
    exit 127
fi

# Parse command-line arguments
OPTIND=1
use_clone=1
configure_git=
configure_zsh=
configure_vim=
configure_tmux=
while getopts "dgzvma" opt; do
case "$opt" in
    d ) use_clone=;;

    g ) configure_git=$(is_configurable "git");;
    z ) configure_zsh=$(is_configurable "zsh");;
    v ) configure_vim=$(is_configurable "vim");;
    m ) configure_tmux=$(is_configurable "tmux");;

    a )
        configure_git=$(is_configurable "git")
        configure_zsh=$(is_configurable "zsh")
        configure_vim=$(is_configurable "vim")
        configure_tmux=$(is_configurable "tmux")
        ;;
    \?) echo "Usage: $(basename $0) [-c] [-g] [-z] [-v] [-m] [-a]";;
  esac
done
shift $(($OPTIND-1))

# Define base directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# configure git
if [ -n "$configure_git" ]; then
    echo "==> Configuring git..."
    # install global configuration
    cp $BASEDIR/config/git/gitconfig $HOME/.gitconfig
    # configure user name
    echo -n "Enter your name and press [ENTER]: "
    read git_name
    git config --global user.name "$git_name"
    # configure user email
    echo -n "Enter your email and press [ENTER]: "
    read git_email
    git config --global user.email "$git_email"
fi

# configure zsh
if [ -n "$configure_zsh" ]; then
    echo "==> Configuring zsh..."
    # warn about shell usage
    if [[ ! $SHELL =~ "zsh" ]]; then
        (>&2 echo "==> ZSH is not configured as your default shell. This configuration will not work until you switch to it (chsh -s `which zsh`)")
    fi
    # download oh-my-zsh
    download_once "robbyrussell/oh-my-zsh" "$HOME/.oh-my-zsh" $use_clone
    # install global configuration
    cp $BASEDIR/config/zsh/zshrc $HOME/.zshrc
    # install custom theme
    download_once "rudisimo/powerlevel9k" "$HOME/.oh-my-zsh/custom/themes/powerlevel9k" $use_clone
    # install custom scripts
    cp $BASEDIR/config/zsh/aliases.zsh $HOME/.oh-my-zsh/custom/
    cp $BASEDIR/config/zsh/functions.zsh $HOME/.oh-my-zsh/custom/
    cp $BASEDIR/config/zsh/man.zsh $HOME/.oh-my-zsh/custom/
    cp $BASEDIR/config/zsh/powerlevel9k.zsh $HOME/.oh-my-zsh/custom/
fi

# configure vim
if [ -n "$configure_vim" ]; then
    echo "==> Configuring vim..."
    # download vundle
    download_once "VundleVim/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim" $use_clone
    # install global configuration
    cp $BASEDIR/config/vim/vimrc $HOME/.vimrc
    # install Vundle plugins
    vim +PluginInstall +PluginClean! +qall --not-a-term -n >/dev/null
fi

# configure tmux
if [ -n "$configure_tmux" ]; then
    echo "==> Configuring tmux..."
    # download tmux plugin manager
    download_once "tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" $use_clone
    # install global configuration
    cp $BASEDIR/config/tmux/tmux.conf $HOME/.tmux.conf
    # install TPM plugins
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

exit 0
