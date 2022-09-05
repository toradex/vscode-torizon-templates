
# get the files content
function _getFileLines ($file) {
    [string[]] $lines = Get-Content -Path $file

    return $lines
}

# replace the dev and prod sections
function _ReplaceSection ([string[]]$fileLines, [string]$section) {
    $_startIx = $null
    $_endIx = $null
    $_ix = 0
    $_newFileContent = New-Object System.Collections.Generic.List[string]

    foreach ($line in $fileLines) {
        if ($line.Contains("__${section}_start__")) {
            $_startIx = $_ix
        }

        if ($line.Contains("__${section}_end__")) {
            $_endIx = $_ix
        }

        $_ix++
    }

    $_ix = 0;
    $_stopAdd = $false

    foreach ($line in $fileLines) {
        if ($_ix -eq $_startIx) {
            $_newFileContent.Add($line)
            $_stopAdd = $true

            $_json = Get-Content -Path "torizonPackages.json" | ConvertFrom-Json
            $_devPacks = $_json.devDeps

            foreach ($pack in $_devPacks) {
                $_newFileContent.Add("`t$pack \")
            }
        }

        if ($_ix -eq $_endIx) {
            $_stopAdd = $false
        }

        if (-not $_stopAdd) {
            $_newFileContent.Add($line)
        }

        $_ix++
    }

    return $_newFileContent
}

# Dockerfile.debug
$debugDockerfile = _getFileLines("Dockerfile.debug")
_ReplaceSection($debugDockerfile, "torizon_packages_dev") `
    | Out-File -FilePath "Dockerfile.debug"

# Dockerfile.sdk
$debugDockerfileSDK = _getFileLines("Dockerfile.sdk")
$debugDockerfileSDK = `
    _ReplaceSection($debugDockerfileSDK, "torizon_packages_prod")
_ReplaceSection($debugDockerfileSDK, "torizon_packages_dev") `
    | Out-File -FilePath "Dockerfile.sdk"

# Dockerfile
$Dockerfile = _getFileLines("Dockerfile")
$Dockerfile = _ReplaceSection($Dockerfile, "torizon_packages_prod")
_ReplaceSection($Dockerfile, "torizon_packages_dev") `
    | Out-File -FilePath "Dockerfile"
