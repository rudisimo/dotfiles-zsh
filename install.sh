#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

BASEDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
STAGEDIR=$(mktemp -d -q)

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

locate() {
    command -v $1 2>/dev/null || true
}

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT

    # remove our staging directory
    test -e "${STAGEDIR}" && rm -rf "${STAGEDIR}"
}

#####################################################
# Output functions
#####################################################

print() {
    echo >&2 -e "${1-}"
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
    if [[ ${VERBOSE-} -eq 1 ]]; then
        print "$(datetime) | ${G}DEBUG${NC} | ${1-}"
    fi
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
    FORCE=0
    DRYRUN=0
    VERBOSE=0
    param=''

    while :; do
        case "${1-}" in
        -h | --help    ) usage ;;
        -d | --debug   ) set -x ;;
        -v | --verbose ) VERBOSE=1 ;;
        --no-color     ) NO_COLOR=1 ;;
        --dry-run      ) DRYRUN=1 ;;
        --no-git       ) NO_GIT=1 ;;
        --no-zsh       ) NO_ZSH=1 ;;
        --no-vim       ) NO_VIM=1 ;;
        --no-tmux      ) NO_TMUX=1 ;;
        -f | --force   ) FORCE=1 ;;
        -p | --param   ) # example named parameter
            param="${2-}"
            shift
            ;;
        -?*            ) die "Unknown option: $1" ;;
        *              ) break ;;
        esac
        shift
    done

    args=("$@")

    git=$(locate git)
    zsh=$(locate zsh)
    vim=$(locate vim)
    tmux=$(locate tmux)

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
# Installer functions
#####################################################

download_github() {
    local namespace=$1
    local destination${2-$STAGEDIR/$namespace}
}

configure_git() {
    if [[ ${NO_GIT-} -eq 0 ]]; then
        if [ -n "$git" ]; then
            info "Configuring git"
            debug "  path: $git"
            debug "  version: $($git --version)"
        else
            warn "git not found, skipping configuration"
        fi
    fi
}

configure_zsh() {
    if [[ ${NO_ZSH-} -eq 0 ]]; then
        if [ -n "$zsh" ]; then
            info "Configuring zsh"
            debug "  path: $zsh"
            debug "  version: $($zsh --version)"
        else
            warn "zsh not found, skipping configuration"
        fi
    fi
}

configure_vim() {
    if [[ ${NO_VIM-} -eq 0 ]]; then
        if [ -n "$vim" ]; then
            info "Configuring vim"
            debug "  path: $vim"
            debug "  version: $($vim --version | head -n 1)"
        else
            warn "vim not found, skipping configuration"
        fi
    fi
}

configure_tmux() {
    if [[ ${NO_TMUX-} -eq 0 ]]; then
        if [ -n "$tmux" ]; then
            info "Configuring tmux"
            debug "  path: $tmux"
            debug "  version: $($tmux -V)"
        else
            warn "tmux not found, skipping configuration"
        fi
    fi
}

#####################################################
# Runtime logic begins here...
#####################################################

parse_args "$@"
setup_colors

configure_git
configure_zsh
configure_vim
configure_tmux

# info  "Read parameters:"
# debug "- force: ${force}"
# warn  "- verbose: ${verbose}"
# error "- arguments: ${args[*]-}"
# fatal "..."
