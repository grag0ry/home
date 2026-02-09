Import-Module PSReadLine

Set-PSReadLineOption -EditMode Emacs

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
