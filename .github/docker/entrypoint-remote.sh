#!/usr/bin/env bash

set -Eeuo pipefail
echo "Installing ${GITHUB_REPOSITORY-'dotfiles-zsh'} via REMOTE execution (${GITHUB_SHA-'HEAD'})"
curl -s file://$PWD/install.sh | bash -s -- -d
