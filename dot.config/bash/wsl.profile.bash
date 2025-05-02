cmd=$(wslpath 'C:\Windows\System32\cmd.exe')
if [[ -n $cmd ]]; then
    alias cmd=$cmd
    export WIN_PATH=$( \
        ( cd $(wslpath c:/) && cmd /C set ) \
        | perl -nE '@_ = map {chomp($_=`wslpath \x27$_\x27`);$_}
                            m/(?:^path=|;\G)([^;]++);/ig
                        or next;
                    $"=":";
                    print "@_"' \
    )
    export WIN_HOME=$( \
        ( cd $(wslpath c:/) && cmd /C set ) \
        |  perl -nE 's/^USERPROFILE=(.*?)\s*+$/\1/i or next;
                     chomp($_=`wslpath \x27$_\x27`);
                     say' \
    )
    function wslwhich { PATH="$WIN_PATH:$PATH" which "$@"; }
    for n in powershell ipconfig gsudo xcopy; do
        alias $n="'$(wslwhich $n.exe)'"
    done
fi
unset cmd
