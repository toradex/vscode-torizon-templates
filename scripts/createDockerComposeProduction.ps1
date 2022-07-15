# args are needed
$compoFilePath  = $args[0]
$dockerLogin    = $args[1]
$tag            = $args[2]

# can be null
$gpu            = $args[3]

if ($null -eq $gpu) {
    $gpu = ""
}

if ([string]::IsNullOrEmpty($compoFilePath)) {
    $compoFilePath = Read-Host "docker-compose.yml root file path"
    if ($compoFilePath -eq "") {
        throw "❌ docker-compose.yml root file path cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($dockerLogin)) {
    $dockerLogin = Read-Host "Image repository"
    if ($dockerLogin -eq "") {
        throw "❌ Docker image repository cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($tag)) {
    $tag = Read-Host "Image tag"
    if ($tag -eq "") {
        throw "❌ Docker image tag cannot be empty"
    }
}

# check if the yaml module is installed
if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
    Write-Host -ForegroundColor Yellow "Installing powershell-yaml ..."
    Install-Module -Name "powershell-yaml" -Confirm:$false -Force
}

Import-Module -Name "powershell-yaml"

# read the yaml file
Write-Host "Reading docker-compose.yml file ..."
$composeContent = Get-Content ("$compoFilePath/docker-compose.yml") | Out-String
$composeLoad = ConvertFrom-Yaml $composeContent -AllDocuments
$composeServices = $composeLoad.Services
$removeKeys = New-Object Collections.Generic.List[String]
$prodKeys = New-Object Collections.Generic.List[String]

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.yml loaded"


# get the keys that need to be removed
Write-Host "Cleaning services ..."

foreach ($key in $composeServices.Keys) {
    if ($key.toString().contains("debug")) {
        $removeKeys.Add($key)
    } else {
        $prodKeys.Add($key)
    }
}

# remove it
foreach ($key in $removeKeys) {
    $composeServices.Remove($key)
}

Write-Host -ForegroundColor DarkGreen "✅ services cleaned"

# replace all the env variables
Write-Host "Replacing variables ..."

foreach ($key in $prodKeys) {
    $composeServices[$key].Remove("build")
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${DOCKER_LOGIN}", $dockerLogin)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${TAG}", $tag)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${GPU}", $gpu)
}

Write-Host -ForegroundColor DarkGreen "✅ variables replaced"

# write the torizon.io ready docker-compose
ConvertTo-Yaml $composeLoad `
    -OutFile "$compoFilePath/docker-compose.prod.yml"

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.prod.yml created"
