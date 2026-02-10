Import-Module PSReadLine

Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Chord Ctrl+d -Function ViExit

# TAB = bash-style complete
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineOption -ShowToolTips:$false

# history by arrows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    # PROMPT_DIRTRIM=3
    $max = 3
    $parts = @( (Get-Location).ProviderPath -split '[\\/]' | Where-Object { $_ -ne "" } )
    $root = $parts[0]
    if (-not($root -match '^[A-Z]:$')) { $root = "\\" + $root }

    $rest = $parts[1..($parts.Count - 1)]
    if ($parts.Count -eq 1) {
        $short = ""
    }
    elseif ($rest.Count -gt $max) {
        $short = "...\" + ($rest[-$max..-1] -join '\')
    } else {
        $short = $rest -join '\'
    }

    $E = [Char]0x1b
    if ($isAdmin) {
        return "$E[1;31m$env:COMPUTERNAME$E[1;34m $root\$short # $E[0m"
    }
    else {
        return "$E[1;32m$env:USERNAME@$env:COMPUTERNAME$E[1;34m $root\$short > $E[0m"
    }
}

# env - colors
$env:EXA_COLORS = `
      "di=38;5;111:" `
    + "fi=38;5;251:" `
    + "ln=38;5;116:" `
    + "ex=38;5;114:" `
    + "da=38;5;240:" `
    + "sn=38;5;180:sb=38;5;180:" `
    + "ur=38;5;176:uw=38;5;176:ux=38;5;176:" `
    + "gr=38;5;111:gw=38;5;111:gx=38;5;111:" `
    + "tr=38;5;116:tw=38;5;116:tx=38;5;116:" `
    + "uu=38;5;176:gu=38;5;111:" `
    + "un=38;5;116:gn=38;5;116:" `
    + "ga=38;5;114:" `
    + "gm=38;5;180:" `
    + "gd=38;5;176:" `
    + "gv=38;5;116:" `
    + "gt=38;5;111"

$env:LS_COLORS = `
      "di=38;5;111:" `
    + "fi=38;5;251:" `
    + "ln=38;5;116:" `
    + "ex=38;5;114:" `
    + "pi=38;5;176:" `
    + "so=38;5;176:" `
    + "bd=38;5;180;1:" `
    + "cd=38;5;180;1:" `
    + "or=38;5;176;1:" `
    + "mi=38;5;176;1:" `
    + "su=38;5;176;1:" `
    + "sg=38;5;111;1:" `
    + "tw=38;5;116;1:" `
    + "ow=38;5;111;1:" `
    + "st=38;5;116;1:" `
    + "ca=38;5;176;1:" `
    + "mh=38;5;180:" `
    + "rs=0"

$env:FZF_DEFAULT_OPTS = $env:FZF_DEFAULT_OPTS `
+ "  --color bg:#080808" `
+ "  --color bg+:#262626" `
+ "  --color border:#2e2e2e" `
+ "  --color fg:#b2b2b2" `
+ "  --color fg+:#e4e4e4" `
+ "  --color gutter:#262626" `
+ "  --color header:#80a0ff" `
+ "  --color hl+:#f09479" `
+ "  --color hl:#f09479" `
+ "  --color info:#cfcfb0" `
+ "  --color marker:#f09479" `
+ "  --color pointer:#ff5189" `
+ "  --color prompt:#80a0ff" `
+ "  --color spinner:#36c692" `

# env

$env:FZF_DEFAULT_OPTS = "$env:FZF_DEFAULT_OPTS --height 40%"
$env:HOME = $env:USERPROFILE
$env:RIPGREP_CONFIG_PATH = "$env:USERPROFILE\scoop\persist\ripgrep\config"

# aliases

function xopen() {
    param([string]$file)
    $mime = file --mime-type -b $file
    switch -Wildcard ($mime) {
        'text/*' { nvim "$file" }
        default { Start-Process explorer.exe -ArgumentList $file }
    }
}

function f {
    param([switch]$d, [switch]$H, [switch]$I, [switch]$help,
          [Parameter(ValueFromRemainingArguments=$true)]
          [string]$pat, [string]$dir)
    if ($h) {
        Write-Output @"
usage: f [-dHI]
  -d dironly
  -H hidden
  -I no ignore
"@
        return
    }
    $dironly = false; $hidden = false; $noignore = false
    if ($d) { $dironly = $true }
    if ($help) { $hidden = $true }
    if ($I) { $noignore = $true }
    $f = ""
    if (-not($pat)) { $pat = "." }
    if (-not($dir)) { $dir = "." }
    while ($true) {
        $bindcmd = 'Write-Host {0}; exit {1}'
        $fdargs=@($pat, $dir)
        if ($hidden) { $fdargs += "-H" }
        if ($noignore) { $fdargs += "-I" }
        if ($dironly) { $fdargs += @("-t", "d") }
        $fzfargs=@(
            "--header", "fd $($fdargs -Join " ")",
            "--footer", "ctrl+d(dironly)/h(hidden)/i(ignore)/j(jump)/p(print)",
            "--bind", "ctrl-d:become($($bindcmd -f "{q}","40"))",
            "--bind", "ctrl-h:become($($bindcmd -f "{q}","41"))",
            "--bind", "ctrl-j:become($($bindcmd -f "{1}","42"))",
            "--bind", "ctrl-p:become($($bindcmd -f "{1}","43"))",
            "--bind", "ctrl-i:become($($bindcmd -f "{q}","44"))",
            "--with-shell", "powershell -NoProfile -Command"
        )
        if ($f) { $fzfargs+=@("--query", $f) }

        $f = fd $fdargs | fzf $fzfargs
        $r = $LASTEXITCODE
        switch ($r) {
            0 { break }
            40 { $dironly = !$dironly }
            41 { $hidden = !$hidden }
            42 {
                if (-not (Test-Path $f -PathType Container)) { $f = Split-Path $f -Parent }
                $r = 0
            }
            43 { Write-Host $f; return 0 }
            44 { $noignore = !$noignore }
            default { return $r }
        }
        if ($r -eq 0) { break; }
    }
    if (-not($f)) { return 1 }
    if (Test-Path $f -PathType Container) {
        Set-Location $f
    }
    else {
        xopen $f
    }
}

if (Test-Path Alias:ls) { Remove-Item Alias:ls }
if (Test-Path Alias:cat) { Remove-Item Alias:cat }

Set-Alias cat bat
Set-Alias vi nvim

function ls  { eza --icons=always @args }
function ll  { eza --icons=always -l @args }
function la  { eza --icons=always -la @args }

function lt  { eza --icons=always -T @args }
function lt2 { eza --icons=always -T -L2 @args }
function lt3 { eza --icons=always -T -L3 @args }

function llg { eza --icons=always -l --git @args }
function lag { eza --icons=always -la --git @args }
