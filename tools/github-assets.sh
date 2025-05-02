#!/bin/sh

set -e -u -o pipefail

repo=${1:?$0: repo required}
version=${2:-latest}

curl -s "https://api.github.com/repos/$repo/releases/$version" \
    | jq -r '.assets.[].browser_download_url'

