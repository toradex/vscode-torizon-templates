#!/usr/bin/env pwsh
param()

##
# All the files should have a new line at the end
##

$Global:_ERROR_REACH = $false

# Add folder names to ignore
$ignoreFolders = @(
    ".git",
    "node_modules",
    "id_rsa"
)

Get-ChildItem -Path . -Force -Recurse | ForEach-Object {
    $file = $_
    $directory = $file.DirectoryName

    # Check if the file's directory is in the ignore list
    $shouldIgnore = $false
    foreach ($ignoreFolder in $ignoreFolders) {
        if (
            $directory -like "*/$ignoreFolder*" -or
            $file.Name -like "*$ignoreFolder*"
        ) {
            $shouldIgnore = $true
            break
        }
    }

    if (-not $shouldIgnore) {
        $mimeType = $(file --mime-type -b $file.FullName)

        if (
            $mimeType -like 'text/*' -or
            $mimeType -like 'application/javascript' -or
            $mimeType -like 'application/json'
        ) {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
            $lastChar = $content.Substring($content.Length - 1)

            if ($lastChar -ne "`n") {
                Write-Host -ForegroundColor Red "❌ :: $($_.FullName)"
                $Global:_ERROR_REACH = $true
            }
        }
    }
}

if ($Global:_ERROR_REACH) {
    Write-Host -ForegroundColor Red "❌ :: Files are missing new line at the end"
    exit 404
}
