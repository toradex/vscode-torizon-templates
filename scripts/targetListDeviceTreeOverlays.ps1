#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true)]
    [string] $login,
    [Parameter(Mandatory=$true)]
    [string] $pass,
    [Parameter(Mandatory=$true)]
    [string] $ip
)

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

# include
. "$env:HOME/.apollox/scripts/utils/animations.ps1"
. "$env:HOME/.apollox/scripts/utils/stackTrace.ps1"

try {
    $dtbList = RunCommandInBackgrounWithWaitAnimation {
        param(
            [Parameter(Mandatory=$true)]
            [string] $login,
            [Parameter(Mandatory=$true)]
            [string] $pass,
            [Parameter(Mandatory=$true)]
            [string] $targetIp
        )

        # get it from the apollox lib
        node $env:HOME/.apollox/scripts/node/listDeviceTreeOverlays.mjs `
            $targetIp `
            $login `
            $pass | ConvertFrom-Json

    } ($login, $pass, $ip)

    Write-Host ""
    Write-Host "🌳 :: DEVICE TREE OVERLAYS :: 🌳"
    Write-Host ""

    foreach ($_dtb in $dtbList) {
        Write-Host "$_dtb"
    }

} catch {
    Write-Host -ForegroundColor Red `
        "`t ❌ :: Could not connect to device :: ❌"
    Write-Host ""

    ShowStackTrace $_
    exit 500
}

Write-Host ""
