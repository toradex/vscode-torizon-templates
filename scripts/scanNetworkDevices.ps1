#!/usr/bin/env pwsh

# include
. "$env:HOME/.apollox/scripts/utils/animations.ps1"

Write-Host "📡 :: NETWORK DEVICES :: 📡"
Write-Host ""

$_nets = RunCommandInBackgrounWithWaitAnimation {
    node $env:HOME/.apollox/scripts/node/scanNetworkDevices.mjs
} | ConvertFrom-Json -Depth 100

# write this scan to a file
$_nets | ConvertTo-Json -AsArray -Depth 100 | Out-File $env:HOME/.tcd/scan.json

# present it to the user with the index identifier
$_id = 0

foreach ($_net in $_nets) {
    $_hostName = $_net.Hostname
    Write-Host "`t $_id ➡️ $_hostName"

    $_id = $_id + 1
}

if ($_id -eq 0) {
    Write-Host -ForegroundColor DarkYellow `
        "`t ❌ :: No network devices found :: ❌"
    Write-Host ""
    exit 404
}

Write-Host ""
