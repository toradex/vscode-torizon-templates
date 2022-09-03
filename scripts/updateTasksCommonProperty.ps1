# include
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)/utils/formatJson.ps1"

# object to be updated
# TODO: Add the properties that have to be updated here
$propertyToUpdate = [PSCustomObject]@{
}

# update all the .vscode/tasks.json
Write-Host -ForegroundColor Yellow "Updating tasks.json ..."
Get-ChildItem -Path ../ `
    -Force -Include "tasks.json", "common.json" -Recurse | ForEach-Object {
        Write-Host $_
        $old = Get-Content $_ | ConvertFrom-Json
        $tasks = $old.tasks

        for ($i = 0; $i -lt $tasks.Count; $i++) {
            $task = $tasks[$i]
            $oldFields = $task | Get-Member *
            $newFields = $propertyToUpdate | Get-Member *

            foreach ($field in $newFields) {
                $hasField = $false

                foreach ($checkField in $oldFields) {
                    if ($checkField.Name -eq $field.Name) {
                        $hasField = $true
                    }
                }

                if (-not $hasField) {
                    # need to update
                    $tasks[$i] | `
                        Add-Member -MemberType NoteProperty `
                        -Name $field.Name `
                        -Value $propertyToUpdate.($field.Name)
                }
            }
        }

        # $old | ConvertTo-Json -Depth 100
        ConvertTo-Json `
            -Depth 100 `
            -InputObject $old | `
            Format-Json | `
            Out-File -FilePath $_
    }
