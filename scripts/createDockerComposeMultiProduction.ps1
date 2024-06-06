[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', ""
)]
param()

$env:DOCKER_HOST = ""

# load the workspace file
$codeWorkspace = Get-Content *.code-workspace | ConvertFrom-Json

# check if the folder has the production docker-compose
foreach ($project in $codeWorkspace.folders) {
    if (-not ([string]$project.path).Equals(".")) {
        $path = [string]$project.path
        $path
        if (-not [System.IO.File]::Exists("$path/docker-compose.prod.yml")) {
            throw "Project path ($path) does not contain a docker-compose.prod.yml file. Please first run the (Create Production Docker Image) task for each project on the workspace."
        }
    }
}

Write-Host -ForegroundColor DarkGreen "✅ docker-compose.prod.yaml"

# check if the yaml module is installed
Write-Host "Importing powershell-yaml ..."
if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
    Write-Host -ForegroundColor Yellow "Installing powershell-yaml ..."
    Install-Module -Name "powershell-yaml" -Confirm:$false -Force
}

$retYaml = $null

# if the script is here means that is all ok
# let's then merge the prod.yml file
foreach ($project in $codeWorkspace.folders) {
    if (-not ([string]$project.path).Equals(".")) {
        # read the yaml and convert to pwsh obj
        $path = [string]$project.path
        "Reading $path/docker-compose.prod.yml"

        $yamlFile = Get-Content ("$path/docker-compose.prod.yml") | Out-String
        $yamlObj = ConvertFrom-Yaml $yamlFile -AllDocuments -Ordered

        if ($null -eq $retYaml) {
            $retYaml = $yamlObj
        } else {
            # merge services
            foreach ($key in $yamlObj.services.Keys) {
                $retYaml.services[$key] = $yamlObj.services[$key]
            }
        }
    }
}

Write-Host -ForegroundColor DarkGreen "✅ prod.yaml merged"

# write the torizon.io ready docker-compose
ConvertTo-Yaml $retYaml `
    -OutFile "./docker-compose.prod.yml" -Force

Write-Host -ForegroundColor DarkGreen "✅ multi workspace docker-compose.prod.yml created"
