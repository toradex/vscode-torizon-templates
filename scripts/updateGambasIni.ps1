# include
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/iniFiles.ps1"

# get arguments
$_path = $args[0]
$_deviceHostname = $args[1]
$_devicePort = $args[2]
$_projectName = $args[3]

# get the ini structured
$datas = `
    Get-IniFile "$_path/$_projectName/.settings"

# debug
Write-Host $datas.Debug["RemoteServer"]
Write-Host "to"
Write-Host $_deviceHostname

# replace
$datas.Debug["RemoteServer"] = `
    "$_deviceHostname"

$datas.Debug["RemotePort"] = `
    "$_devicePort"

# write
New-IniContent $datas | Out-File -FilePath "$_path/$_projectName/.settings"
