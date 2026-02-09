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
    Write-Host "[CP] $Source -> $Destination"
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

    Write-Host "[MV] $ScoopShims\$shim.shim -> $ScoopShims\$shim.shim.$current"
    Rename-Item -Path "$ScoopShims\$shim.shim" -NewName "$ScoopShims\$shim.shim.$current" -Force
    Write-Host "[MV] $ScoopShims\$shim.shim.$app -> $ScoopShims\$shim.shim"
    Rename-Item -Path "$ScoopShims\$shim.shim.$app" -NewName "$ScoopShims\$shim.shim" -Force
}

function Get-M4Config {
    $base = Get-Content "$ScriptDir/../tools/base.m4" -Encoding UTF8
    $data = @( "m4_divert(-1)m4_dnl", $base )
    $data += "m4_define(<[M4_CFG_WIN]>,<[1]>)"
    $data += "m4_define(<[M4_CFG_HOME]>,<[$($env:USERPROFILE -replace '\\', '/')]>)"
    $data += "m4_define(<[M4_CFG_SCOOP_PERSIST]>,<[$($ScoopPersist -replace '\\', '/')]>)"
    $data += "m4_divert(0)m4_dnl"
    return ($data -Join "`n")
}

function Copy-M4 {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [Parameter(Mandatory)]
        [string]$Destination
    )
    $destDir = Split-Path $Destination
    Write-Host "[M4] $Source -> $Destination"
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $output = & $ScoopShims\m4 -P "$ScriptDir\config.m4" $Source
    [System.IO.File]::WriteAllText($Destination, ($output -Join "`n"), $utf8NoBom)
}


if (-not(Test-Path $ScoopShims\scoop -PathType Leaf)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

& $ScoopShims\scoop.ps1 update
& $ScoopShims\scoop.ps1 install busybox m4 curl less git bat eza fd fzf ripgrep delta neovim

Update-ScoopShim less less
Update-ScoopShim xxd neovim

Write-Host "[MK] config.m4"
Get-M4Config | Set-Content -Encoding ASCII -Path "$ScriptDir/config.m4" -Force

Copy-ItemForceDirs "$ScriptDir\profile.ps1" $PROFILE.CurrentUserAllHosts
Copy-ItemForceDirs "$ScriptDir\..\dot.config\ripgrep\config" "$ScoopPersist\ripgrep\config"
Copy-ItemForceDirs "$ScriptDir\..\dot.config\bat\config" "$ScoopPersist\bat\config"
Copy-ItemForceDirs "$ScriptDir\..\dot.config\bat\themes\Moonfly.tmTheme" "$ScoopPersist\bat\themes\Moonfly.tmTheme"
Copy-ItemForceDirs "$ScriptDir\..\dot.config\delta\config" "$ScoopPersist\delta\config"
Copy-M4 "$ScriptDir\..\dot.gitconfig.in" "$env:USERPROFILE\.gitconfig"
Copy-ItemForceDirs "$ScriptDir\..\dot.gitignore" "$env:USERPROFILE\.gitignore"

& $ScoopShims\bat cache --build
