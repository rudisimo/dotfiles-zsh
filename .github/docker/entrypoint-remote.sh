#!/usr/bin/env bash

set -Eeuo pipefail

echo "Installing ${GITHUB_REPOSITORY-'dotfiles-zsh'} via REMOTE execution (${GITHUB_SHA-'HEAD'})"
curl -s "file://${GITHUB_WORKSPACE}/install.sh" | sh -s -- -v -f
