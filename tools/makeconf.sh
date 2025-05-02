#!/bin/sh

set -e -u -o pipefail

if [[ -n ${1:-} ]]; then
    OS=$1
else
    OS=$(uname -s)
fi

[[ $(uname -r) = *-microsoft-* ]] && WSL=1 || WSL=

if [[ -n ${2:-} ]]; then
    OSID=$2
elif [[ $(uname -s) = *CYGWIN* ]]; then
    OSID=cygwin
else
    eval "$(sed -n s/^ID=/OSID=/p /etc/os-release)"
fi

HOMEDIR=$(realpath -m "${3:-$HOME}")

printf "override %s = %s\n" OS "$OS" OSID "$OSID" HOMEDIR "${HOMEDIR}"
[[ -n $WSL ]] && printf "WSL = 1\n"
