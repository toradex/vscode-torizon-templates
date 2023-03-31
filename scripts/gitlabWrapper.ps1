#!/usr/bin/pwsh -nop

$ErrorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

# wrapper to execute the gitlab script
try {
    # execute line by line
    foreach ($line in $input) {
        if (-not [string]::IsNullOrWhiteSpace($line)) {
            $LASTEXITCODE = 0

            Invoke-Expression `
                -Command $line `
                -ErrorAction Stop

            $exitCode = $LASTEXITCODE
            if (($exitCode -ne 0) -or ($? -eq $false)) {
                throw "Error executing line: $line"
            }
        }
    }
} catch {
    Write-Error -Message $_.Exception.Message
    [System.Environment]::Exit(69)
}
