#!/bin/bash

set -eE -u -o pipefail

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" || exit 1

for cfg in *.ini; do
    dconf load / < "$cfg"
done
