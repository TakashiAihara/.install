$ErrorActionPreference = "Stop"

$envFile = ".env"
$BaseDir = $PSScriptRoot
Set-Location $BaseDir
$GlobalArgs = $Args

function ReadEnvFile {
    if (Test-Path $envFile) {
        foreach ($line in Get-Content $envFile) {
            if ($line -notmatch '^\s*#.*' -and $line -match '\S') {
                $name, $value = $line.split('=')
                set-content env:\$name $value.Trim('"')
            }
        }
    }
}

function ApplyOptions {
    if ($null -eq $env:AREA -or '' -eq $env:AREA) {
        $env:DOTBOT_AREA = 'home'
    }
    else {
        $env:DOTBOT_AREA = $env:AREA
    }

    if ($null -eq $env:ARCH -or '' -eq $env:ARCH) {
        $env:DOTBOT_ARCH = 'windows'
    }
    else {
        $env:DOTBOT_ARCH = $env:ARCH
    }
}

function UpdateDotbot {
    git submodule update --init --recursive $(Join-Path $env:DOTBOT_PLUGINS_DIR -ChildPath $env:DOTBOT)

}

function ExecutePrepare($PYTHON) {
    &$PYTHON $( `
            Join-Path $BaseDir -ChildPath $env:DOTBOT_PLUGINS_DIR | `
            Join-Path -ChildPath $env:DOTBOT | `
            Join-Path -ChildPath $env:DOTBOT_BIN `
    ) `
        -d $BaseDir `
        -c $( `
            Join-Path $BaseDir -ChildPath $env:DOTBOT_CONFIG_TARGET_DIR | `
            Join-Path -ChildPath $( $env:DOTBOT_PREPARE_CONFIG_FILE + $env:DOTBOT_CONFIG_FILE_SUFFIX )`
    )
}

function ExecuteMainProcess($PYTHON) {
    &$PYTHON $( `
            Join-Path $BaseDir -ChildPath $env:DOTBOT_PLUGINS_DIR | `
            Join-Path -ChildPath $env:DOTBOT | `
            Join-Path -ChildPath $env:DOTBOT_BIN `
    ) `
        -d $BaseDir `
        -c $( `
            Join-Path $BaseDir -ChildPath $env:DOTBOT_CONFIG_TARGET_DIR | `
            Join-Path -ChildPath $( $env:DOTBOT_ARCH + $env:DOTBOT_CONFIG_FILE_SUFFIX ) `
    ) `
        $GlobalArgs
}

ReadEnvFile
ApplyOptions
UpdateDotbot

foreach ($PYTHON in ('python', 'python3', 'python2')) {
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        ExecutePrepare($PYTHON)
        ExecuteMainProcess($PYTHON)
        return
    }
}

Write-Error "Error: Cannot find Python."
