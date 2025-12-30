if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return 0
fi

[[ -v WIN_PATH ]] || eval "$(wslenv -e)"

cmdpath=$(wslpath C:/Windows/System32/cmd.exe 2>/dev/null)
if [[ -n $cmdpath ]]; then
    # shellcheck disable=SC2262,SC2139
    alias cmd="${cmdpath@Q}"
    wslwhich() { PATH="$WIN_PATH:$PATH" which "$@"; }

    for name in powershell ipconfig gsudo wsl; do
        path=$(wslwhich "$name.exe" 2>/dev/null)
        # shellcheck disable=SC2139
        [[ -n $path ]] && alias "$name=${path@Q}"
    done
    unset name
    unset path
fi
unset cmdpath

# vim: filetype=bash
