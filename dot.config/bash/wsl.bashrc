if [[ $- != *i* ]] ; then
    # Shell is non-interactive.  Be done now!
    return 0
fi

[[ -v WIN_PATH ]] || eval "$(wslenv -e)"
if [[ -z ${WSL_DISTRO_NAME} ]]; then
    WSL_DISTRO_NAME=$(basename "$(wslpath -m /)")
    export WSL_DISTRO_NAME
fi

[[ -x /mnt/c/Windows/System32/cmd.exe ]] || return 0

alias cmd=/mnt/c/Windows/System32/cmd.exe
alias powershell=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
wslwhich() { PATH="$WIN_PATH:$PATH" which "$@"; }

WIN_PWSH=
pwsh.exe() {
    [[ -n $WIN_PWSH ]] || WIN_PWSH=$(wslwhich pwsh.exe 2>/dev/null)
    [[ -n $WIN_PWSH ]] && "$WIN_PWSH" "$@"
}

# vim: filetype=bash
