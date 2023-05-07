$ErrorActionPreference = "Stop"

$ARCH = $Args[0]

$CONFIG_PATH = "install_conf"
$CONFIG = Join-Path $CONFIG_PATH "${ARCH}.yaml"

$CONFIG_TARGET_PATH = "target"
$CONFIG_TARGET = Join-Path $CONFIG_TARGET_PATH "${ARCH}.yaml"

$DOTBOT_DIR = "dotbot"
$DOTBOT_BIN = "bin/dotbot"

GENERATOR_PATH="utils/generate.py"

PLUGIN_PATH="plugins"

DOTBOT="${PLUGIN_PATH}/dotbot"
DOT_BREWFILE="${PLUGIN_PATH}/dotbot-brewfile"
DOT_GO="${PLUGIN_PATH}/dotbot-golang"
DOT_APT="${PLUGIN_PATH}/dotbot-apt"

DOTBOT_BIN="${DOTBOT}/bin/dotbot"



$BASEDIR = $PSScriptRoot

winget install Git.Git --accept-package-agreements --accept-source-agreements
winget install python3 --accept-package-agreements --accept-source-agreements
python3 -m pip install --user pyyaml
python3 generate.py "${CONFIG}"

Set-Location $BASEDIR
git -C $DOTBOT_DIR submodule sync --quiet --recursive
git submodule update --init --recursive $DOTBOT_DIR

foreach ($PYTHON in ('python', 'python3', 'python2')) {
    # Python redirects to Microsoft Store in Windows 10 when not installed
    if (& { $ErrorActionPreference = "SilentlyContinue"
            ![string]::IsNullOrEmpty((&$PYTHON -V))
            $ErrorActionPreference = "Stop" }) {
        &$PYTHON $(Join-Path $BASEDIR -ChildPath $DOTBOT_DIR | Join-Path -ChildPath $DOTBOT_BIN) -d $BASEDIR -c $CONFIG_TARGET
        return
    }
}
Write-Error "Error: Cannot find Python."
