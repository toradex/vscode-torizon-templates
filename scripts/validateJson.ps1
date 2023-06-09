#!/usr/bin/env pwsh
param()

function _validate ($_ref, $_schema) {
    Write-Host "▶️ Validating $($_ref.FullName)"

    if ($null -ne $_schema) {
        $_testRet = `
            Test-Json `
                -Path $_.FullName `
                -SchemaFile $_schema
    } else {
        $_testRet = `
            Test-Json `
                -Path $_.FullName
    }

    if ($true -ne $_testRet) {
        Write-Host -ForegroundColor Red "❌ $($_ref.FullName) is not valid"
        code $_ref.FullName
    }
}

# test all the */**/tasks.json
Get-ChildItem -Path . -Force -Filter tasks.json -Recurse | ForEach-Object {
    _validate $_ $PWD/assets/json/tasks.schema.json
}

# test the common.json
Get-ChildItem -Path . -Force -Filter common.json -Recurse | ForEach-Object {
    _validate $_ $PWD/assets/json/tasks.schema.json
}

# test all the */**/launch.json
Get-ChildItem -Path . -Force -Filter launch.json -Recurse | ForEach-Object {
    _validate $_
}
