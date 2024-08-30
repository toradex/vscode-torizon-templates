#!/usr/bin/env pwsh

# include
. "$env:HOME/.apollox/scripts/utils/animations.ps1"

Write-Host "📡 :: NETWORK DEVICES :: 📡"
Write-Host ""

RunCommandInBackgroundWithWaitAnimationAsync {
    node $env:HOME/.apollox/scripts/node/scanNetworkDevices.mjs
}

# read the output
$nets = Get-Content "$env:HOME/.tcd/scan.json" | ConvertFrom-Json

if ($nets.Length -lt 1) {
    Write-Host -ForegroundColor DarkYellow `
        "`t ❌ :: No network devices found :: ❌"
    Write-Host ""
    exit 404
}

Write-Host ""
