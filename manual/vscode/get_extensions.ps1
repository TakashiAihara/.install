$getList = "code --list-extensions"
$prefix = "code --install-extension"
$outputRelativePath = "manual\vscode\install_extensions"

$gitRoot = Invoke-Expression "git rev-parse --show-toplevel"
$outputPath = Join-Path $gitRoot $outputRelativePath

$extensions = Invoke-Expression $getList
$result = foreach ($extension in $extensions) {
    if (![string]::IsNullOrWhiteSpace($extension)) {
        "$prefix $extension"
    }
}

Write-Output $outputPath
Write-Output $result | Tee-Object -FilePath $outputPath
Write-Output "Succeed."
