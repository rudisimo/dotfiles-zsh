#!/usr/bin/env bash

set -Eeuo pipefail

echo "Installing ${GITHUB_REPOSITORY-'dotfiles-zsh'} via REMOTE execution (${GITHUB_SHA})"
curl -s "file://${RUNNER_WORKSPACE}/install.sh" | sh -s -- -p "${RUNNER_TEMP}" -b "${GITHUB_REF_NAME}" -f -v
