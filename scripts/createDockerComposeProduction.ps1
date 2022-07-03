# args are needed
$compoFilePath  = $args[0]
$dockerLogin    = $args[1]
$tag            = $args[2]

# can be null
$gpu            = $args[3]

if ($null -eq $gpu) {
    $gpu = ""
}

# check if the yaml module is installed
if (-not (Get-Module -Name "powershell-yaml")) {
    Install-Module -Name "powershell-yaml" -Confirm:$false -Force
}

Import-Module -Name "powershell-yaml"

# read the yaml file
$composeContent = Get-Content ("$compoFilePath/docker-compose.yml") | Out-String
$composeLoad = ConvertFrom-Yaml $composeContent -AllDocuments
$composeServices = $composeLoad.Services
$removeKeys = New-Object Collections.Generic.List[String]
$prodKeys = New-Object Collections.Generic.List[String]

# get the keys that need to be removed
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

# replace all the env variables
foreach ($key in $prodKeys) {
    $composeServices[$key].Remove("build")
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${DOCKER_LOGIN}", $dockerLogin)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${TAG}", $tag)
    $composeServices[$key].image = `
        $composeServices[$key].image.replace("`${GPU}", $gpu)
}

# write the torizon.io ready docker-compose
ConvertTo-Yaml $composeLoad `
    -OutFile "$compoFilePath/docker-compose.prod.yml"
