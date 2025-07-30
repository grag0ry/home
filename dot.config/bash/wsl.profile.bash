cmdpath=$(wslpath C:/Windows/System32/cmd.exe 2>/dev/null)
if [[ -n $cmdpath ]]; then
    # shellcheck disable=SC2262,SC2139
    alias cmd="${cmdpath@Q}"
    wslenv() {
        local o_export=; local o_raw=;
        local a; while getopts "er" a; do case "$a" in
            e) o_export=1 ;;
            r) o_raw=1 ;;
            *) return 1 ;;
        esac; done

        local var; local val
        local -A winenv
        local a; while IFS= read -r a; do
            [[ $a = *=* ]] || continue
            local var=${a%%=*}; var=${var@U}
            local val=${a#*=}; val=${val/%$'\r'/}
            [[ -n $o_raw ]] \
                && printf "${o_export:+export }%q=%q\n" "$var" "$val" \
                || winenv[$var]=$val
        done < <(cd "$(wslpath C:/)" && cmd /D /C set)
        [[ -n $o_raw ]] && return 0

        xwslpath() { [[ -n $1 ]] && wslpath "$1" 2>/dev/null; }
        local path=
        local a; while IFS= read -r -d ";" a; do
            a=$(xwslpath "$a")
            [[ -n $a ]] && path+="$a:"
        done <<< "${winenv[PATH]:-}${winenv[PATH]:+;}"
        [[ -n $path ]] && path=${path::-1}
        printf "${o_export:+export }%q=%q\n" \
            WIN_PATH "$path" \
            WIN_HOME "$(xwslpath "${winenv[USERPROFILE]:-}")" \
            WIN_TEMP "$(xwslpath "${winenv[TEMP]:-}")" \
            WIN_APPDATA "$(xwslpath "${winenv[APPDATA]:-}")" \
            WIN_PROGRAMDATA "$(xwslpath "${winenv[PROGRAMDATA]:-}")" \
            WIN_PROGRAMFILES "$(xwslpath "${winenv[PROGRAMFILES]:-}")"
        unset xwslpath
    }
    eval "$(wslenv -e)"

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
