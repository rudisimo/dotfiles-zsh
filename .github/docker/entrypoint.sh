#!/usr/bin/env bash

set -Eeuo pipefail

# run full installer
./install.sh -d

# run headless installer
curl -s file://$PWD/install.sh | bash -s -- -d

exit 0
