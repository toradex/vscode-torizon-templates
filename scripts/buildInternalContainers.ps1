#!/usr/env pwsh

$env:BRANCH = $args[0]

# run the build command
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --push `
    tasks

# run the build command
docker compose `
    -f ./container/docker-compose.yml `
    build `
    --push `
    pwsh-gitlab
