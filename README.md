# TakashiAihara's initial installers

## Description

This installer contains init process for each OS. Mac/Ubuntu/WSL(Ubuntu)/Windows

Use submodules for Linking private settings.

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
