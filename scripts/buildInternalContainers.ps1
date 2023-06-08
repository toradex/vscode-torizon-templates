#!/usr/env pwsh

$errorActionPreference = "Stop"
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', "Internal PS variable"
)]
$PSNativeCommandUseErrorActionPreference = $true

$env:BRANCH = $args[0]
$env:UUID = $(id -u)
$env:SHA_DIR = 0

# # run the build command
Write-Host -ForegroundColor Green "🔨 :: PWSH :: 🔨"
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --no-cache `
    --push `
    pwsh

# # run the build command
Write-Host -ForegroundColor Green "🔨 :: TASKS :: 🔨"
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --no-cache `
    --push `
    tasks

# # run the build command
Write-Host -ForegroundColor Green "🔨 :: PWSH-GITLAB :: 🔨"
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --no-cache `
    --push `
    pwsh-gitlab

# run the build command
Write-Host -ForegroundColor Green "🔨 :: TORIZONCORE-DEV :: 🔨"
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --no-cache `
    --push `
    torizoncore-dev
