# suppress warnings that we need to use
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidOverwritingBuiltInCmdlets', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingInvokeExpression', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingPositionalParameters', ""
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidGlobalVars', ""
)]
param()

$env:DOCKER_HOST = ""

# args are needed
$compoFilePath  = $args[0]
$dockerLogin    = $args[1]
$tag            = $args[2]
$imageName      = $args[3]
$imageArch      = $args[4]
$psswd          = $args[5]

# can be null
$gpu            = $args[6]

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

if ([string]::IsNullOrEmpty($psswd)) {
    $tag = Read-Host "Docker registry password"
    if ($tag -eq "") {
        throw "❌ Docker registry password cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($imageName)) {
    $tag = Read-Host "Image name"
    if ($tag -eq "") {
        throw "❌ Docker image name cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($tag)) {
    $tag = Read-Host "Image tag"
    if ($tag -eq "") {
        throw "❌ Docker image tag cannot be empty"
    }
}

# rebuild and tag
Write-Host "Rebuilding $dockerLogin/$($imageName):$tag ..."

$objSettings = Get-Content ("$compoFilePath/.vscode/settings.json") | `
    Out-String | ConvertFrom-Json
$localRegistry = $objSettings.host_ip

$env:LOCAL_REGISTRY="$($localRegistry):5002"
$env:TAG="$tag"
$env:DOCKER_LOGIN="$dockerLogin"
Set-Location $compoFilePath
docker compose build --build-arg IMAGE_ARCH=$imageArch $imageName
Set-Location -

Write-Host -ForegroundColor DarkGreen "✅ Image rebuild and tagged"

# push it
Write-Host "Pushing it $dockerLogin/$($imageName):$tag ..."

docker login --username $dockerLogin --password $psswd
docker push $dockerLogin/$($imageName):$tag

Write-Host -ForegroundColor DarkGreen "✅ Image push OK"

# check if the yaml module is installed
Write-Host "Importing powershell-yaml ..."
if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
    Write-Host -ForegroundColor Yellow "Installing powershell-yaml ..."
    Install-Module -Name "powershell-yaml" -Confirm:$false -Force
}

Import-Module -Name "powershell-yaml"
Write-Host -ForegroundColor DarkGreen "✅ powershell-yaml loaded"

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
    -OutFile "$compoFilePath/docker-compose.prod.yml" -Force

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.prod.yml created"
