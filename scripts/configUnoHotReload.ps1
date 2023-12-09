
param(
    [string] $workspaceFolder
)

$errorActionPreference = "Stop"

# get the path of the xml file
$_files = `
    Get-ChildItem `
        -Path $workspaceFolder/*.Skia.* `
        -Recurse `
        -Filter *.csproj

$_csprojPath = $_files[0].FullName

# load the csproj file as XML
[xml] $_csproj = Get-Content -Path $_csprojPath

# get my ip address
$hostIp = `
    (Get-Content $workspaceFolder/.vscode/settings.json `
        | ConvertFrom-Json -Depth 100).host_ip

if ([string]::IsNullOrEmpty($hostIp)) {
    Write-Host -ForegroundColor Yellow `
        "`n⚠️  The host ip is not set in the .vscode/settings.json file"
    Write-Host -ForegroundColor Yellow `
        "Did you forget to set a default device?"
    Write-Host `
        "https://developer.toradex.com/torizon/application-development/ide-extension/connect-a-torizoncore-target-device `n"

    Write-Host -ForegroundColor Red `
        "❌ Failed`n`n"

    exit 69
}

Write-Host "Injecting the host ip $hostIp"
Write-Host "into the csproj file: "
Write-Host "$_csprojPath `n`n"

# update it
$_csproj.Project.PropertyGroup.UnoRemoteControlHost = $hostIp;

# save it
$_csproj.Save($_csprojPath)

Write-Host "✅ Success! `n"
