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

Copy-ItemForceDirs "$ScriptDir/../dot.config/delta/config" "$env:APPDATA\delta\config"

if (-not(Test-Path $env:USERPROFILE\scoop\shims\scoop -PathType Leaf)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

& $env:USERPROFILE\scoop\shims\bat cache --build
& $env:USERPROFILE\scoop\shims\scoop update
& $env:USERPROFILE\scoop\shims\scoop install busybox curl git bat eza fd fzf ripgrep delta neovim

