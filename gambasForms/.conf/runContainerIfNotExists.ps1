
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
