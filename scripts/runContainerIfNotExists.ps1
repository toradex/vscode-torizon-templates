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

$_containerRuntime = $args[0]
$_runArguments = $args[1].Trim("'").Trim('"');
$_containerName = $args[2]

$_containerInfo = 
    Invoke-Expression "$_containerRuntime container inspect $_containerName" | `
    ConvertFrom-Json

if ($null -ne $_containerInfo) {
    Write-Host "Container Exists"

    if ($_containerInfo.Running -eq $false) {
        Invoke-Expression "$_containerRuntime start $_containerName"
    } else {
        Write-Host "Container is running"
    }
} else {
    Write-Host "Container does not exists. Starting ..."
    Invoke-Expression "$_containerRuntime run --name $_containerName $_runArguments"
}
