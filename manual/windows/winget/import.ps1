$configRelativePath = "manual\windows\winget\packages.json"
$gitRoot = Invoke-Expression "git rev-parse --show-toplevel"
$configPath = Join-Path $gitRoot $configRelativePath

winget import -i $configPath --ignore-versions --accept-package-agreements --accept-source-agreements --disable-interactivity
