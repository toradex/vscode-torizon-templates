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

$settingsTemplate = [PSCustomObject]@{
    torizon_psswd = ""
    torizon_login = ""
    torizon_ip = ""
    torizon_run_as = "torizon"
    torizon_app_root = "/home/torizon"
    torizon_debug_port = ""
    torizon_debug_port2 = ""
    torizon_debug_port3 = ""
    torizon_debug_ssh_port = "2222"
    torizon_gpu = ""
    torizon_arch = ""
    host_ip = ""
    torizon_workspace = "$`{workspaceFolder`}"
    wait_sync = "1"
    "tcb.version" = "3.8.1"
    "tcb.packageName" = "__change__"
}

# update all the .vscode/settings.json
Write-Host -ForegroundColor Yellow "Updating settings.json ..."
Get-ChildItem -Path ../ `
    -Force -Filter settings.json -Recurse | ForEach-Object {
        Write-Host $_
        $old = Get-Content $_ | ConvertFrom-Json
        $oldFields = $old | Get-Member *
        $newFields = $settingsTemplate | Get-Member *

        foreach ($field in $newFields) {
            $hasField = $false

            foreach ($checkField in $oldFields) {
                if ($checkField.Name -eq $field.Name) {
                    $hasField = $true
                }
            }

            if (-not $hasField) {
                # need to update
                $old | `
                    Add-Member -MemberType NoteProperty `
                    -Name $field.Name `
                    -Value $settingsTemplate.($field.Name)
            }
        }

        ConvertTo-Json -InputObject $old | Out-File -FilePath $_
    }
