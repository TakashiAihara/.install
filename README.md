# TakashiAihara's initial installers

## Description

This installer contains init process for each OS. Mac/Ubuntu/WSL(Ubuntu)/Windows

Use submodules for Linking private settings.

## Prepare

### For WSL

```shell
apt update
apt install -y gh python3

exec -l $shell
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

gh auth login

git clone https://github.com/TakashiAihara/.install
```

## Usage

### Commandline

```
AREA=home ARCH=wsl ./install
```

```
AREA=gcp ARCH=ubuntu ./install
```

```
AREA=home ARCH=mac ./install
```

*Following command needs Admin rights

```
$Env:AREA="home" ; $Env:ARCH="windows" ; .\install.ps1
```

### Expected Environment Variables

* AREA
  * home/gcp/oci/conoha
* ARCH
  * wsl/ubuntu/mac/windows

## Architecture

* install_conf
  * Main configuration file for each OS. This file is converted by Github Actions into a format that dotbot can read, and automatically pushes it to the "target" dir.

* links
  * Contains submodule to be linked. My public ".dotfiles" and private ***.

* plugins
  * Contains submodule that dotbot plugins.

## Logging and Maintenance

This installer now includes comprehensive logging to track installation status and help with maintenance:

### Log Features

* **Automatic Logging**: All installation steps are logged to `~/.install.log`
* **Success/Failure Tracking**: Each installation step is marked as SUCCESS or ERROR
* **Output Capture**: Both stdout and stderr are captured for debugging
* **Duration Tracking**: Installation time for each component is recorded
* **Skip Detection**: Already installed tools are detected and skipped

### Check Installation Status

```bash
# Check current installation status and maintenance needs
./utils/check_installation_status.sh
```

This will show:
* Which tools are installed/not installed
* Recent installation errors
* Available updates for package managers
* Maintenance recommendations

### View Logs

```bash
# View recent log entries
tail -50 ~/.install.log

# View only errors
grep "\[ERROR\]" ~/.install.log

# View only successful installations
grep "\[SUCCESS\]" ~/.install.log

# Generate installation summary
./install # (summary is shown at the end)
```

### Log Format

The log file uses the following format:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] Message
```

Where LEVEL can be:
* `INFO`: General information
* `SUCCESS`: Successful installation
* `ERROR`: Failed installation
* `CHECK`: Installation status check
* `STDOUT`: Command output
* `STDERR`: Command error output
