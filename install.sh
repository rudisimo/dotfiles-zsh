#!/bin/bash -eu

# checks if the given command exists
exists() {
    command -v "$1" >/dev/null 2>&1
}

# returns "1" if command exists
configure() {
    if exists "$1"; then
        echo "1"
    fi
}

# downloads the repository from github
download() {
    local repository="$1"
    local destination="$2"
    local git="${3-}"

    if [ -n "$git" ]; then
        git clone "https://github.com/${repository}.git" "$destination"
    else
        mkdir -p $destination
        curl -#skfL "https://github.com/${repository}/tarball/master" | tar xzv --strip-components 1 -C $destination
    fi
}

# Configure base directory
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

    g ) configure_git=$(configure "git");;
    z ) configure_zsh=$(configure "zsh");;
    v ) configure_vim=$(configure "vim");;
    m ) configure_tmux=$(configure "tmux");;

    a )
        configure_git=$(configure "git")
        configure_zsh=$(configure "zsh")
        configure_vim=$(configure "vim")
        configure_tmux=$(configure "tmux")
        ;;
    \?) echo "Usage: $(basename $0) [-c] [-g] [-z] [-v] [-m] [-a]";;
  esac
done
shift $(($OPTIND-1))

# Check script requirements
if [ -n "$use_clone" ] && ! exists "git"; then
    (>&2 echo "==> Git is required to continue with the environment configuration.")
    exit 127
fi

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
    # download oh-my-zsh repository
    [ ! -e "$HOME/.oh-my-zsh" ] && download "robbyrussell/oh-my-zsh" "$HOME/.oh-my-zsh" $use_clone
    # install global configuration
    cp $BASEDIR/config/zsh/zshrc $HOME/.zshrc
    # install custom theme
    cp $BASEDIR/config/zsh/rudisimo.zsh-theme $HOME/.oh-my-zsh/themes/
    # install custom scripts
    cp $BASEDIR/config/zsh/aliases.zsh $HOME/.oh-my-zsh/custom/
    cp $BASEDIR/config/zsh/functions.zsh $HOME/.oh-my-zsh/custom/
    cp $BASEDIR/config/zsh/man.zsh $HOME/.oh-my-zsh/custom/
    # warn about shell usage
    if [[ ! $SHELL =~ "zsh" ]]; then
        (>&2 echo "==> ZSH is not configured as your default shell. This configuration will not work until you switch to it (chsh -s `which zsh`)")
    fi
fi

# configure tmux
if [ -n "$configure_tmux" ]; then
    echo "==> Configuring tmux..."
    # clone TPM repository
    [ ! -e "$HOME/.tmux/plugins/tpm" ] && download "tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm" $use_clone
    # install global configuration
    cp $BASEDIR/config/tmux/tmux.conf $HOME/.tmux.conf
    # install TPM plugins
    $HOME/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

# configure vim
if [ -n "$configure_vim" ]; then
    echo "==> Configuring vim..."
    # clone Vundle repository
    [ ! -e "$HOME/.vim/bundle/Vundle.vim" ] && download "VundleVim/Vundle.vim" "$HOME/.vim/bundle/Vundle.vim" $use_clone
    # install global configuration
    cp $BASEDIR/config/vim/vimrc $HOME/.vimrc
    # install Vundle plugins
    vim +PluginInstall +PluginClean! +qall -n >/dev/null 2>&1
fi

exit 0

