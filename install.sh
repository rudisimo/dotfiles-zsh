#!/bin/sh

set -e -u
trap cleanup 15 2 0

#####################################################
# Global variables
#####################################################

STAGEDIR=$(mktemp -d -q)
DESTDIR=$HOME
BASEDIR=
if [ -t 0 ]; then
    BASEDIR=$(cd -- "$(dirname -- "$0")" && pwd -P)
fi

# Options
OPT_FORCE=
OPT_QUIET=
OPT_VERBOSE=
OPT_DRYRUN=
OPT_COLOR=1
OPT_GIT=1
OPT_ZSH=1
OPT_VIM=1
OPT_TMUX=1
OPT_USECURL=
OPT_BRANCH="master"

# Colors
NC=
R=
G=
O=
B=
M=
C=
Y=

#####################################################
# Core functions
#####################################################

cleanup() {
    trap - 15 2 0
    test -e "$STAGEDIR" && rm -rf "$STAGEDIR"
}

log() {
    [ "$OPT_QUIET" = 1 ] || echo >&2 -e "$@"
}

die() {
    [ -z "$@" ] || log "$@"
    exit 1
}

date_iso8601() {
    date +'%Y-%m-%dT%H:%M:%S%z'
}

debug() {
    log "$(date_iso8601) | ${G}DEBUG${NC} | ${1-}"
}

info() {
    log "$(date_iso8601) | INFO  | ${1-}"
}

warn() {
    log "$(date_iso8601) | ${Y}WARN${NC}  | ${1-}"
}

error() {
    log "$(date_iso8601) | ${R}ERROR${NC} | ${1-}"
}

fatal() {
    die "$(date_iso8601) | ${M}FATAL${NC} | ${1-}"
}

#####################################################
# Utility functions
#####################################################

check_path() {
    command -v "$1" 2>/dev/null || echo ""
}

confirm_user_action() {
    # force user action when requested
    [ "$OPT_FORCE" = 1 ] && return 0

    # cancel when running in non-iteractive mode
    [ ! -t 0 ] || [ ! -t 1 ] && fatal "Running in headless-mode. Please pass --force to continue"

    # request user confirmation
    read -p "${1:-This may overwrite existing files}. Are you sure? (y/n) " -r reply
    case "$reply" in
        [yY]* ) return 0;;
    esac

    return 1
}

confirm_should_run() {
    [ ! "$OPT_DRYRUN" = 1 ] && return 0
    return 1
}

download() {
    local repository=$1
    local repository_url="https://github.com/${repository}"
    local destination=${2-$STAGEDIR/$repository}
    local branch=${3-master}

    if confirm_user_action; then
        info "  download: $repository_url ($branch) -> $destination"
        if confirm_should_run; then
            if [ -z "$OPT_USECURL" ]; then
                [ -d $destination ] && git -C $destination pull || git clone -q --depth 1 --branch $branch "${repository_url}.git" $destination
            else
                mkdir -p $destination
                curl -sfL "${repository_url}/tarball/${branch}" | tar xzv --strip-components 1 -C $destination
            fi
        fi
    fi
}


download_once() {
    local repository=$1
    local destination=${2-$STAGEDIR/$repository}

    if [ ! -e "$destination" ]; then
        download "$@"
    fi
}

copy_file() {
    local sourcefile=$1
    local destinationfile=$2

    if [ -e "$sourcefile" ]; then
        info "  copy: $sourcefile -> $destinationfile"
        if [ -z "$OPT_DRYRUN" ]; then
            cp -f $sourcefile $destinationfile
        fi
    fi
}

link_file() {
    local sourcefile=$1
    local destinationfile=$2

    if [ -e "$sourcefile" ]; then
        info "  symlink: $sourcefile -> $destinationfile"
        if [ -z "$OPT_DRYRUN" ]; then
            ln -sf $sourcefile $destinationfile
        fi
    fi
}

#####################################################
# Installer functions
#####################################################

configure_git() {
    if [ "$OPT_GIT" = 1 ]; then
        info "Configuring git ..."

        git_path=$(check_path git)
        if [ -n "$git_path" ]; then
            if [ "$OPT_VERBOSE" = 1 ]; then
                debug "  path: $git_path"
                debug "  version: $($git_path --version | head -n 1)"
            fi

            # install global configuration
            copy_file $BASEDIR/config/git/.gitconfig $DESTDIR/.gitconfig
        else
            warn "git not found, skipping configuration"
        fi
    fi
}

configure_zsh() {
    if [ "$OPT_ZSH" = 1 ]; then
        info "Configuring zsh ..."

        zsh_path=$(check_path zsh)
        if [ -n "$zsh_path" ]; then
            if [ "$OPT_VERBOSE" = 1 ]; then
                debug "  path: $zsh_path"
                debug "  version: $($zsh_path --version | head -n 1)"
            fi

            # download oh-my-zsh
            download robbyrussell/oh-my-zsh $DESTDIR/.oh-my-zsh

            # install global configuration
            copy_file $BASEDIR/config/zsh/zshrc $DESTDIR/.zshrc
            copy_file $BASEDIR/config/zsh/zprofile $DESTDIR/.zprofile

            # install custom scripts
            copy_file $BASEDIR/config/zsh/aliases.zsh $DESTDIR/.oh-my-zsh/custom
            copy_file $BASEDIR/config/zsh/functions.zsh $DESTDIR/.oh-my-zsh/custom
            copy_file $BASEDIR/config/zsh/man.zsh $DESTDIR/.oh-my-zsh/custom

            # install custom plugins
            download zsh-users/zsh-completions $DESTDIR/.oh-my-zsh/custom/plugins/zsh-completions
            download zsh-users/zsh-autosuggestions $DESTDIR/.oh-my-zsh/custom/plugins/zsh-autosuggestions

            # install p10k theme
            download romkatv/powerlevel10k $DESTDIR/.oh-my-zsh/custom/themes/powerlevel10k
            copy_file $BASEDIR/config/zsh/p10k.zsh $DESTDIR/.p10k.zsh
        else
            warn "zsh not found, skipping configuration"
        fi
    fi
}

configure_vim() {
    if [ "$OPT_VIM" = 1 ]; then
        info "configuring vim ..."

        vim_path=$(check_path vim)
        if [ -n "$vim_path" ]; then
            if [ "$OPT_VERBOSE" = 1 ]; then
                debug "  path: $vim_path"
                debug "  version: $($vim_path --version | head -n 1)"
            fi

            # download vundle
            download VundleVim/Vundle.vim $DESTDIR/.vim/bundle/Vundle.vim

            # install global configuration
            copy_file $BASEDIR/config/vim/.vimrc $DESTDIR/.vimrc

            # # install Vundle plugins
            # vim +PluginInstall +PluginClean! +qall --not-a-term -n >/dev/null
        else
            warn "vim not found, skipping configuration"
        fi
    fi
}

configure_tmux() {
    if [ "$OPT_TMUX" = 1 ]; then
        info "configuring tmux ..."

        tmux_path=$(check_path tmux)
        if [ -n "$tmux_path" ]; then
            if [ "$OPT_VERBOSE" = 1 ]; then
                debug "  path: $tmux_path"
                debug "  version: $($tmux_path -V | head -n 1)"
            fi

            # download vundle
            download gpakosz/.tmux $DESTDIR/.tmux

            # install global configuration
            link_file $DESTDIR/.tmux/.tmux.conf $DESTDIR/.tmux.conf
            copy_file $BASEDIR/config/tmux/.tmux.conf.local $DESTDIR/.tmux.conf.local
        else
            warn "tmux not found, skipping configuration"
        fi
    fi
}

#####################################################
# CLI functions
#####################################################

usage() {
    cat <<EOF
Usage: install.sh [OPTIONS]

Available options:
  -f, --force       Skip all prompts
  -q, --quiet       Hide all output
  -v, --verbose     Increase output verbosity
EOF
  exit 1
}

#####################################################
# Runtime logic begins here...
#####################################################

if [ -t 2 ] && [ -n "$OPT_COLOR" ] && [ "${TERM-}" != "dumb" ]; then
    NC='\033[0m' R='\033[0;31m' G='\033[0;32m' O='\033[0;33m' B='\033[0;34m' M='\033[0;35m' C='\033[0;36m' Y='\033[1;33m'
fi

while [ "$#" -gt 0 ]; do
    arg="$1"
    shift
    case "$arg" in
        -h | --help    ) usage ;;
        -x | --trace   ) set -x ;;
        -f | --force   ) OPT_FORCE=1 ;;
        -q | --quiet   ) OPT_QUIET=1 ;;
        -v | --verbose ) OPT_VERBOSE=1 ;;
        --dry          ) OPT_DRYRUN=1 ;;
        --no-color     ) OPT_COLOR= ;;
        --no-git       ) OPT_GIT= ;;
        --no-zsh       ) OPT_ZSH= ;;
        --no-vim       ) OPT_VIM= ;;
        --no-tmux      ) OPT_TMUX= ;;
        --use-curl     ) OPT_USECURL=1 ;;
        -b | --branch  )
            OPT_BRANCH="$1"
            shift
            ;;
        -p | --prefix  )
            DESTDIR="$1"
            shift
            ;;
        -?*            ) die "Unknown option: $arg" ;;
        *              ) break ;;
    esac
done

if [ "$OPT_DRYRUN" = 1 ]; then
    warn "enabling dry-run mode ..."
fi

# enable cURL downloads
if [ -z "$(check_path git)" ]; then
    info "git not installed, using cURL for downloads instead"
    OPT_USECURL=1
fi

# download dotfiles when running in headless mode
if [ -z "$BASEDIR" ]; then
    info "downloading dotfiles-zsh ..."
    BASEDIR=$STAGEDIR/dotfiles-zsh
    download_once rudisimo/dotfiles-zsh $BASEDIR $OPT_BRANCH
fi

# configure environment
configure_git
configure_zsh
configure_vim
configure_tmux
