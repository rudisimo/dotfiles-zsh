#!/usr/bin/env bash

set -Eeuo pipefail

echo "Installing ${GITHUB_REPOSITORY-'dotfiles-zsh'} via REMOTE execution (${GITHUB_SHA})"
curl -s "file://${GITHUB_WORKSPACE}/install.sh" | sh -s -- -v -f -b "${GITHUB_REF}"
