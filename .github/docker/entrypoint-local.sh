#!/usr/bin/env bash

set -Eeuo pipefail

echo "Installing ${GITHUB_REPOSITORY-'dotfiles-zsh'} via LOCAL execution (${GITHUB_SHA-'HEAD'})"
sh "${RUNNER_WORKSPACE}/install.sh" -p "${RUNNER_TEMP}" -b "${GITHUB_REF_NAME}" -f -v
