$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

function Copy-ItemForceDirs {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination
    )
    $destDir = Split-Path $Destination
    Write-Host "$Source -> $Destination"
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Copy-Item -Path $Source -Destination $Destination -Force
}

Copy-ItemForceDirs "$ScriptDir/profile.ps1" $PROFILE.CurrentUserAllHosts
Copy-ItemForceDirs "$ScriptDir/../dot.config/ripgrep/config" "$env:APPDATA\ripgrep\config"
Copy-ItemForceDirs "$ScriptDir/../dot.config/bat/config" "$env:APPDATA\bat\config"
Copy-ItemForceDirs "$ScriptDir/../dot.config/bat/themes/Moonfly.tmTheme" "$env:APPDATA\bat\themes\Moonfly.tmTheme"
bat cache --build

Copy-ItemForceDirs "$ScriptDir/../dot.config/delta/config" "$env:APPDATA\delta\config"

if (-not(Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop update
scoop install busybox curl git bat eza fd fzf ripgrep delta neovim

