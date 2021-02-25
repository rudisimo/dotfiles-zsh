#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

BASEDIR=
STAGEDIR=$(mktemp -d -q)
if [ -n "${BASH_SOURCE-}" ]; then
    BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
fi

#####################################################
# Core functions
#####################################################

usage() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-d] [-v] [-f] -p param_value arg1 [arg2...]

Available options:

-h, --help      Print this help and exit
-d, --debug     Print script debug info
-v, --verbose   Increase output verbosity
-f, --force     Never prompt
-p, --param     Some param description
EOF
  exit
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    test -e "${STAGEDIR}" && rm -rf "${STAGEDIR}"
}

choose() {
    command -v $1 2>/dev/null || true
}

#####################################################
# Output functions
#####################################################

print() {
    [[ ${NO_OUTPUT-} -eq 1 ]] || echo >&2 -e "${1-}"
}

die() {
    local message=$1
    local statuscode=${2-1}
    print "$message"
    exit "$statuscode"
}

datetime() {
    date +'%Y-%m-%dT%H:%M:%S'
}

debug() {
    print "$(datetime) | ${G}DEBUG${NC} | ${1-}"
}

info() {
    print "$(datetime) | INFO  | ${1-}"
}

warn() {
    print "$(datetime) | ${Y}WARN${NC}  | ${1-}"
}

error() {
    print "$(datetime) | ${R}ERROR${NC} | ${1-}"
}

fatal() {
    die "$(datetime) | ${M}FATAL${NC} | ${1-}"
}

#####################################################
# CLI functions
#####################################################

parse_args() {
    while :; do
        case "${1-}" in
            --trace        ) set -x ;;
            -h | --help    ) usage ;;
            -f | --force   ) FORCE=1 ;;
            -d | --debug   ) DEBUG=1 ;;
            -q | --quiet   ) NO_OUTPUT=1 ;;
            --no-color     ) NO_COLOR=1 ;;
            --no-git       ) NO_GIT=1 ;;
            --no-zsh       ) NO_ZSH=1 ;;
            --no-vim       ) NO_VIM=1 ;;
            --no-tmux      ) NO_TMUX=1 ;;
            --dry-run      ) DRYRUN=1 ;;
            -?*            ) die "Unknown option: $1" ;;
            *              ) break ;;
        esac
        shift
    done

    args=("$@")

    git=$(choose git)
    zsh=$(choose zsh)
    vim=$(choose vim)
    tmux=$(choose tmux)

    return 0
}

setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NC='\033[0m' R='\033[0;31m' G='\033[0;32m' O='\033[0;33m' B='\033[0;34m' M='\033[0;35m' C='\033[0;36m' Y='\033[1;33m'
    else
        NC='' R='' G='' O='' B='' M='' C='' Y=''
    fi
}

#####################################################
# Utility functions
#####################################################

download_github_repo() {
    local namespace=$1
    local destination${2-$STAGEDIR/$namespace}
}

#####################################################
# Installer functions
#####################################################

debug_git() {
    debug "  path: $git"
    debug "  version: $($git --version | head -n 1)"
}

debug_zsh() {
    debug "  path: $zsh"
    debug "  version: $($zsh --version | head -n 1)"
}


debug_vim() {
    debug "  path: $vim"
    debug "  version: $($vim --version | head -n 1)"
}


debug_tmux() {
    debug "  path: $tmux"
    debug "  version: $($tmux -V | head -n 1)"
}


configure_git() {
    if [[ -n "$git" ]]; then
        [[ ${DEBUG-} -eq 1 ]] && debug_git
    else
        warn "git not found, skipping configuration"
    fi
}

configure_zsh() {
    if [[ -n "$zsh" ]]; then
        [[ ${DEBUG-} -eq 1 ]] && debug_zsh
    else
        warn "zsh not found, skipping configuration"
    fi
}

configure_vim() {
    if [[ -n "$vim" ]]; then
        [[ ${DEBUG-} -eq 1 ]] && debug_vim
    else
        warn "vim not found, skipping configuration"
    fi
}

configure_tmux() {
    if [[ -n "$tmux" ]]; then
        [[ ${DEBUG-} -eq 1 ]] && debug_tmux
    else
        warn "tmux not found, skipping configuration"
    fi
}

#####################################################
# Runtime logic begins here...
#####################################################

parse_args "$@"
setup_colors

# configure git, unless disabled
if [[ ${NO_GIT-} -eq 0 ]]; then
    info "Configuring git ..."
    configure_git
fi

# configure zsh, unless disabled
if [[ ${NO_ZSH-} -eq 0 ]]; then
    info "Configuring zsh ..."
    configure_zsh
fi

# configure vim, unless disabled
if [[ ${NO_VIM-} -eq 0 ]]; then
    info "Configuring vim ..."
    configure_vim
fi

# configure tmux, unless disabled
if [[ ${NO_TMUX-} -eq 0 ]]; then
    info "Configuring tmux ..."
    configure_tmux
fi

# info  "Read parameters:"
# debug "- force: ${force}"
# warn  "- verbose: ${verbose}"
# error "- arguments: ${args[*]-}"
# fatal "..."
