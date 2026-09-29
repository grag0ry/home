#!/bin/bash

set -e -u -o pipefail

args=(-LRSs --fail -w 'downloaded: %{size_download} bytes\n')
[[ -f $2 ]] && args+=(-z "$2")
args+=(-o "$2" "$1")

printf "curl"; printf " %q" "${args[@]}"; printf '\n'
exec curl "${args[@]}"
