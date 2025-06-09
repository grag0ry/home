#!/bin/bash

# shellcheck disable=SC2034
set -e -u -o pipefail

: "${CFG_OS:=$(uname -s)}"

if [[ -n ${CFG_OSID:-} ]]; then
    true
elif [[ $(uname -s) = *CYGWIN* ]]; then
    CFG_OSID=cygwin
else
    eval "$(sed -n s/^ID=/CFG_OSID=/p /etc/os-release)"
fi

: "${CFG_HOME:=$HOME}"
CFG_HOME=$(realpath -m "$CFG_HOME")

: "${CFG_WSL=$([[ $(uname -r) = *-microsoft-* ]] && echo 1 || echo)}"
: "${CFG_NVIM=$([[ -n $(command -v nvim) ]] && echo 1 || echo)}"
: "${CFG_GNUPG_AGENT=}"
: "${CFG_LEMONADE=1}"
: "${CFG_SET_NERDFONTS=}"

while IFS= read -r var; do
    if [[ -n ${!var:-} ]]; then
        printf "override %s = %s\n" "$var" "${!var}"
    else
        printf "override %s =\n" "$var"
    fi
done < <(set | sed -n -e 's/^\(CFG_\w\+\)=.*/\1/p' | sort)
