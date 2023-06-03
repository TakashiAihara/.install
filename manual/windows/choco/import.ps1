$configRelativePath = "manual\windows\choco\packages.config"
$gitRoot = Invoke-Expression "git rev-parse --show-toplevel"
$configPath = Join-Path $gitRoot $configRelativePath

choco install $configPath --acceptlicense --yes --allowunofficial
