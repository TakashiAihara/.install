$configRelativePath = "manual\windows\winget\packages.json"
$gitRoot = Invoke-Expression "git rev-parse --show-toplevel"
$configPath = Join-Path $gitRoot $configRelativePath

winget export --config $configPath --disable-interactivity --accept-source-agreements --verbose
