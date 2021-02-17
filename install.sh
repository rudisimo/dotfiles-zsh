#!/bin/bash

set -e
set -u

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_installed() {
    command -v "$1" >/dev/null 2>&1
}

is_configurable() {
    if is_installed "$1"; then
        echo "1"
    fi
}

# Define runtime variables
has_git=$(is_configurable git)
has_zsh=$(is_configurable zsh)
has_vim=$(is_configurable vim)
has_tmux=$(is_configurable tmux)

# Parse command-line arguments
with_curl=
with_force=
with_dryrun=
setup_nodenv=
setup_pyenv=
setup_goenv=
setup_wsl=

OPTIND=1
while getopts "hcfdnpgw" opt; do
    case "$opt" in
        c ) with_curl=1    ;;
        f ) with_force=1   ;;
        d ) with_dryrun=1  ;;
        n ) setup_nodenv=1 ;;
        p ) setup_pyenv=1  ;;
        g ) setup_goenv=1  ;;
        w ) setup_wsl=1    ;;

        h|\?) cat <<EOF
Usage: $(basename $0)
  General:
    -c    Use curl instead of git
    -f    Ignore warning message
    -d    Dry-run only

  Features:
    -n    Setup nodenv
    -p    Setup pyenv
    -g    Setup goenv
    -w    Setup WSL
EOF
        exit 0
        ;;
    esac
done
shift $(($OPTIND-1))

# Downloads a Github repository only once
download_once() {
    local src="$1"
    local dst="$2"

    if [ -z "$with_dryrun" ]
    then
        if [ ! -d "$dst" ]
        then
            if [ -n "$has_git" ] && [ -z "$with_curl" ]
            then
                git clone -q --depth 1 "https://github.com/${src}.git" $dst
            else
                mkdir -p $dst
                curl -#skfL "https://github.com/${src}/tarball/master" | tar xzv --strip-components 1 -C $dst
            fi
        fi
    fi
}

# Copy a file
copy_file() {
    local src="$1"
    local dst="$2"

    if [ -z "$with_dryrun" ]
    then
        if [ -e "$src" ]
        then
            cp -v "$src" "$dst"
        fi
    fi
}

# confirm configuration consent
if [ -z "${with_dryrun}" ] && [ -z "${with_force}" ]
then
   read -p "This may overwrite existing files. Are you sure? (y/n) " -n 1;
   echo "";
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "[INFO] Aborting..." >&2
        exit 0
   fi
fi

# configure git
if [ -n "$has_git" ]
then
    echo "[INFO] Configuring git..."

    # install global configuration
    copy_file $BASEDIR/config/git/.gitconfig $HOME/.gitconfig

    # add git user information
    if [ -z "${PS1:-}" ]; then
        echo "[WARN] This shell is not interactive" >&2
    else
        echo "==> Enter your Git user name:"
        read git_user_name
        git config --global user.name "$git_user_name"
        echo "==> Enter your Git user email:"
        read git_user_email
        git config --global user.email "$git_user_email"
    fi
fi

# configure zsh
if [ -n "$has_zsh" ]; then
    echo "[INFO] Configuring zsh..." >&2

    # warn about shell usage
    if [[ ! $SHELL =~ "zsh" ]]; then
        echo "[ERRO] ZSH is not configured as your default shell" >&2
        echo "[INFO] This configuration will not work until you switch to it" >&2
    fi

    # download dependencies
    download_once robbyrussell/oh-my-zsh $HOME/.oh-my-zsh

    # install global configuration
    copy_file $BASEDIR/config/zsh/.zshrc $HOME/.zshrc

    # install custom scripts
    copy_file $BASEDIR/config/zsh/aliases.zsh $HOME/.oh-my-zsh/custom
    copy_file $BASEDIR/config/zsh/functions.zsh $HOME/.oh-my-zsh/custom
    copy_file $BASEDIR/config/zsh/man.zsh $HOME/.oh-my-zsh/custom

    # install p10k theme
    download_once romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    copy_file $BASEDIR/config/zsh/.p10k.zsh $HOME/.p10k.zsh

    # install nodenv
    if [ -n "$setup_nodenv" ]
    then
        echo "[INFO] Configuring nodenv..." >&2
        download_once nodenv/nodenv $HOME/.nodenv
        copy_file $BASEDIR/config/zsh/nodenv.zsh $HOME/.oh-my-zsh/custom
    fi

    # install pyenv
    if [ -n "$setup_pyenv" ]
    then
        echo "[INFO] Configuring pyenv..." >&2
        download_once pyenv/pyenv $HOME/.pyenv
        copy_file $BASEDIR/config/zsh/pyenv.zsh $HOME/.oh-my-zsh/custom
    fi

    # install goenv
    if [ -n "$setup_goenv" ]
    then
        echo "[INFO] Configuring goenv..." >&2
        download_once syndbg/goenv $HOME/.goenv
        copy_file $BASEDIR/config/zsh/goenv.zsh $HOME/.oh-my-zsh/custom
    fi

    # install WSL
    if [ -n "$setup_wsl" ]
    then
        copy_file $BASEDIR/config/zsh/wsl.zsh $HOME/.oh-my-zsh/custom
    fi
fi

# configure vim
if [ -n "$has_vim" ]; then
    echo "[INFO] Configuring vim..." >&2

    # install global configuration
    copy_file $BASEDIR/config/vim/.vimrc $HOME/.vimrc

    # install vundle
    download_once VundleVim/Vundle.vim $HOME/.vim/bundle/Vundle.vim
    vim +PluginInstall +PluginClean! +qall --not-a-term -n >/dev/null
fi

# configure tmux
if [ -n "$has_tmux" ]; then
    echo "[INFO] Configuring tmux..." >&2

    # install global configuration
    copy_file $BASEDIR/config/tmux/.tmux.conf $HOME/.tmux.conf
    copy_file $BASEDIR/config/tmux/.tmux.local.conf $HOME/.tmux.conf.local
fi

echo "[INFO] Done!" >&2
exit 0
