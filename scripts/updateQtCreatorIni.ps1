# include
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/iniFiles.ps1"

# get arguments
$_path = $args[0]
$_deviceHostname = $args[1]

# get the ini structured
$datas = `
    Get-IniFile "$_path/.qt/QtProject/QtCreator.ini"

# debug
Write-Host $datas.DebugMode["StartApplication\2\LastServerAddress"]
Write-Host "to"
Write-Host $_deviceHostname

# replace
$datas.DebugMode["StartApplication\2\LastServerAddress"] = "$_deviceHostname"
# write
New-IniContent $datas | Out-File -FilePath "$_path/.qt/QtProject/QtCreator.ini"
