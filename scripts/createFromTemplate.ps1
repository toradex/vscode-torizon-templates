# supress warnings that we need to use
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

# include
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/formatJson.ps1"
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/replaceTasksInput.ps1"

$templateFolder = $args[0]
$projectName = $args[1]
$containerName = $args[2]
$location = $args[3]

# optional
$template = $args[4]
$vscode = $args[5]

if ([string]::IsNullOrEmpty($template)) {
    $template = "undefined"
}

if ([string]::IsNullOrEmpty($templateFolder)) {
    $templateFolder = Read-Host "Template Folder"
    if ($templateFolder -eq "") {
        throw "❌ Template folder cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($projectName)) {
    $projectName = Read-Host "Project Name"
    if ($projectName -eq "") {
        throw "❌ Project name cannot be empty"
    }
}

if ([string]::IsNullOrEmpty($containerName)) {
    $containerName = Read-Host "Container Name"
    if ($containerName -eq "") {
        throw "❌ Container name cannot be empty"
    }
}

# container name needs to be lower case
$containerName = $containerName.ToLower()

if (-not [string]::IsNullOrEmpty($location)) {
    # special case for automations
    $location = "$location/$projectName"
} else {
    $location = "$projectName"
}

Write-Host "Data::"
Write-Host "Template Folder ->    $templateFolder"
Write-Host "Project Name ->       $projectName"
Write-Host "Container Name ->     $containerName"

# create the copy
Write-Host -ForegroundColor Yellow "Creating from template ..."
Copy-Item $templateFolder $location -Recurse
Write-Host -ForegroundColor DarkGreen "✅ Folder copy done"

# apply the common tasks and inputs
Write-Host -ForegroundColor Yellow "Applying common tasks ..."
$commonTasks = Get-Content "$templateFolder/../assets/tasks/common.json" | ConvertFrom-Json
$commonInputs = Get-Content "$templateFolder/../assets/tasks/inputs.json" | ConvertFrom-Json
$projTasks = Get-Content "$location/.vscode/tasks.json" | ConvertFrom-Json

$projTasks.tasks += $commonTasks.tasks
$projTasks.inputs += $commonInputs.inputs

ConvertTo-Json -Depth 100 -InputObject $projTasks | `
    Format-Json | `
    Out-File -FilePath "$location/.vscode/tasks.json"

Write-Host -ForegroundColor DarkGreen "✅ Common tasks applied"

# we have to also copy the scripts
Copy-Item "$templateFolder/../scripts/checkDeps.ps1" "$location/.conf/"
Copy-Item "$templateFolder/../scripts/runContainerIfNotExists.ps1" "$location/.conf/"
Copy-Item "$templateFolder/../scripts/shareWSLPorts.ps1" "$location/.conf/"
Copy-Item "$templateFolder/../scripts/createDockerComposeProduction.ps1" "$location/.conf"
Copy-Item "$templateFolder/../scripts/torizonPackages.ps1" "$location/.conf"
Copy-Item "$templateFolder/../scripts/tasks.ps1" "$location/.vscode"
Copy-Item "$templateFolder/../assets/json/torizonPackages.json" "$location/"

# create a dot file to store the template that was used
Write-Output "$template" | Out-File -FilePath "$location/.conf/.template"

Write-Host -ForegroundColor DarkGreen "✅ Scripts copy done"

Set-Location $location

# change the folders that is needed
Write-Host -ForegroundColor Yellow "Renaming folders ..."
Get-ChildItem -Path . `
    -Filter *__change__* -Recurse | ForEach-Object {
        Write-Host $_
        Rename-Item $_ ($_ -replace "__change__",$projectName)
    }
Write-Host -ForegroundColor DarkGreen "✅ Project folders ok"

# change the contents
Write-Host -ForegroundColor Yellow "Renaming file contents ..."
Get-ChildItem -Force -File -Recurse * | ForEach-Object {
    Write-Host $_
    $a = $_.fullname;

    # do not mess up with binary files
    $mimeType = file --mime-encoding $a

    if (-not $mimeType.Contains("binary")) {
        # id_rsa is a special case, is ascii but we do not have permissions
        if (-not $a.Contains("id_rsa")) {
            if ($_ -isnot [System.IO.DirectoryInfo]) {
                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__change__",$projectName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__container__",$containerName
                } | Set-Content $a

                ( Get-Content $a ) |
                ForEach-Object {
                    $_ -replace "__home__",$env:HOME
                } | Set-Content $a
            }
        } elseif (-not $a.Contains("id_rsa.pub")) {
            chmod 0400 $a
        }
    }
}

# if from vscode we need to replace the inputs
if (-not [string]::IsNullOrEmpty($vscode)) {
    Replace-Tasks-Input
}

Write-Host -ForegroundColor DarkGreen "✅ Renaming file contents ok"

# back
Set-Location -
