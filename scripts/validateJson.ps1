#!/usr/bin/env pwsh
param()

# test all the */**/tasks.json
Get-ChildItem -Path . -Force -Filter tasks.json -Recurse | ForEach-Object {
    Write-Host "▶️ Validating $($_.FullName)"
    $_testRet = `
        Test-Json `
            -Path $_.FullName `
            -SchemaFile $PWD/assets/json/tasks.schema.json

    if ($true -ne $_testRet) {
        Write-Host -ForegroundColor Red "❌ $($_.FullName) is not valid"
        code $_.FullName
    }
}
