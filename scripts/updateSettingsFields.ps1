
$settingsTemplate = [PSCustomObject]@{
    torizon_psswd = ""
    torizon_login = ""
    torizon_ip = ""
    host_ip = ""
    torizon_workspace = "$`{workspaceFolder`}"
}

# update all the .vscode/settings.json
Write-Host -ForegroundColor Yellow "Updating settings.json ..."
Get-ChildItem -Path ../ `
    -Force -Filter settings.json -Recurse | ForEach-Object {
        Write-Host $_
        ConvertTo-Json -InputObject $settingsTemplate | Out-File -FilePath $_
    }
