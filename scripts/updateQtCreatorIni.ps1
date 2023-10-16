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

# include
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/iniFiles.ps1"

# get arguments
$_path = $args[0]
$_deviceHostname = $args[1]
$_projectName = $args[2]
$_deviceArch = $args[3]

# get the ini structured
$datas = `
    Get-IniFile "$_path/.qt/QtProject/QtCreator.ini"

# debug
Write-Host $datas.DebugMode["StartApplication\2\LastServerAddress"]
Write-Host "to"
Write-Host $_deviceHostname

# replace
$datas.DebugMode["StartApplication\2\LastServerAddress"] = `
    "$_deviceHostname"

$datas.DebugMode["StartApplication\2\LastExternalExecutable"] = `
    "$_path/build-$_deviceArch/debug/$_projectName"

$datas.DebugMode["StartApplication\2\LastExternalWorkingDirectory"] = `
    "$_path/build-$_deviceArch/debug"

# write
New-IniContent $datas | Out-File -FilePath "$_path/.qt/QtProject/QtCreator.ini"
