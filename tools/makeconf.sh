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

: "${CFG_WSL=$([[ $(uname -r) = *-microsoft-* ]] && echo 1 || :)}"

: "${CFG_HOME:=$HOME}"
CFG_HOME=$(realpath -m "$CFG_HOME")

if [[ -z "${CFG_X+defined}" ]]; then
    CFG_X=
    if [[ -n $CFG_WSL ]]; then
        if ! grep -q 'guiApplications\s*=\s*false' /etc/wsl.conf >/dev/null; then
            CFG_X=1
        fi
    fi
fi

if [[ -n $CFG_WSL && -n $CFG_X ]]; then
    : "${CFG_SET_GALLIUM_DRIVER=d3d12}"
    : "${CFG_SET_MESA_D3D12_DEFAULT_ADAPTER_NAME=}"
else
    : "${CFG_SET_GALLIUM_DRIVER=}"
    : "${CFG_SET_MESA_D3D12_DEFAULT_ADAPTER_NAME=}"
fi

if [[ -z "${CFG_SSH_AGENT+defined}" ]]; then
    [[ -n $CFG_WSL ]] && CFG_SSH_AGENT=wslsshagent || CFG_SSH_AGENT=openssh
fi

: "${CFG_LEMONADE=1}"
: "${CFG_LEMONADE_INSTALL=$CFG_LEMONADE}"
: "${CFG_LEMONADE_SERVER=}"

: "${CFG_NVIM=$([[ -n $(command -v nvim) ]] && echo 1 || :)}"
: "${CFG_SET_NERDFONTS=}"
: "${CFG_SET_HIGHSCALE=}"

: "${CFG_CARGO_NATIVE=$([[ -n $(command -v cargo) ]] && echo 1 || :)}"

: "${CFG_NNN=1}"
: "${CFG_NNN_INSTALL=${CFG_NNN}}"

: "${CFG_APP_RIPGREP=1}"
: "${CFG_APP_FD=1}"
: "${CFG_APP_EZA=1}"
: "${CFG_APP_BAT=1}"
: "${CFG_APP_GIT_DELTA=1}"
: "${CFG_APP_HEXYL=1}"

while IFS= read -r var; do
    if [[ -n ${!var:-} ]]; then
        printf "override %s = %s\n" "$var" "${!var}"
    else
        printf "override %s =\n" "$var"
    fi
done < <(set | sed -n -e 's/^\(CFG_\w\+\)=.*/\1/p' | sort)
