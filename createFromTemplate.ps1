$templateFolder = $args[0]
$projectName = $args[1]
$containerName = $args[2]

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

Write-Host "Data::"
Write-Host "Template Folder ->    $templateFolder"
Write-Host "Project Name ->       $projectName"
Write-Host "Container Name ->     $containerName"

# create the copy
Write-Host -ForegroundColor Yellow "Creating from template ..."
Copy-Item $templateFolder $projectName -Recurse
Write-Host -ForegroundColor DarkGreen "✅ Folder copy done"

Set-Location $projectName

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
            }
        }
    }
}
Write-Host -ForegroundColor DarkGreen "✅ Renaming file contents ok"

# back
Set-Location -
