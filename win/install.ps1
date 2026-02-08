$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

$ScoopDir = "$env:USERPROFILE\scoop"
$ScoopShims = "$ScoopDir\shims"
$ScoopPersist = "$ScoopDir\persist"

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

function Update-ScoopShim {
    param(
        [Parameter(Mandatory)]
        [string]$shim,
        [Parameter(Mandatory)]
        [string]$app
    )
    if (-not(Test-Path "$ScoopShims\$shim.shim" -PathType Leaf)) {
        throw "no such shim: $shim"
    }
    $path = (Get-Content "$ScoopShims\$shim.shim" -Encoding UTF8) -join ' '
    if ($path -match "$([Regex]::Escape($(Convert-Path "$ScoopDir\apps")))[/\\]([^/\\]+)") {
        $current = $Matches[1].ToLower()
    }
    else {
        throw "no app for shim: $shim"
    }

    if ($current -eq $app) { return; }

    if (-not(Test-Path "$ScoopShims\$shim.shim.$app" -PathType Leaf)) {
        throw "no shim for app: $app"
    }

    Write-Host "$ScoopShims\$shim.shim -> $ScoopShims\$shim.shim.$current"
    Rename-Item -Path "$ScoopShims\$shim.shim" -NewName "$ScoopShims\$shim.shim.$current" -Force
    Write-Host "$ScoopShims\$shim.shim.$app -> $ScoopShims\$shim.shim"
    Rename-Item -Path "$ScoopShims\$shim.shim.$app" -NewName "$ScoopShims\$shim.shim" -Force
}


Copy-ItemForceDirs "$ScriptDir/profile.ps1" $PROFILE.CurrentUserAllHosts
Copy-ItemForceDirs "$ScriptDir/../dot.config/ripgrep/config" "$ScoopPersist\ripgrep\config"
Copy-ItemForceDirs "$ScriptDir/../dot.config/bat/config" "$ScoopPersist\bat\config"
Copy-ItemForceDirs "$ScriptDir/../dot.config/bat/themes/Moonfly.tmTheme" "$ScoopPersist\bat\themes\Moonfly.tmTheme"
Copy-ItemForceDirs "$ScriptDir/../dot.config/delta/config" "$ScoopPersist\delta\config"

if (-not(Test-Path $ScoopShims\scoop -PathType Leaf)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

& $ScoopShims\bat cache --build
& $ScoopShims\scoop.ps1 update
& $ScoopShims\scoop.ps1 install busybox curl less git bat eza fd fzf ripgrep delta neovim

Update-ScoopShim less less
Update-ScoopShim xxd neovim
