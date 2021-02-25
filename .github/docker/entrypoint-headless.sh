#!/usr/bin/env bash

set -Eeuo pipefail
curl -s file://$PWD/install.sh | bash -s -- -d
