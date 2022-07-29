
function Replace-Tasks-Input () {
    Get-ChildItem -Force -File -Recurse *.json | ForEach-Object {
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
                        $_ -replace `
                        "input:dockerLogin", `
                        "command:inputOrSetting:docker_login"
                    } | Set-Content $a

                    ( Get-Content $a ) |
                    ForEach-Object {
                        $_ -replace `
                        "input:dockerImageRegistry", `
                        "command:inputOrSetting:docker_registry"
                    } | Set-Content $a

                    ( Get-Content $a ) |
                    ForEach-Object {
                        $_ -replace `
                        "input:dockerPsswd", `
                        "command:inputOrSetting:docker_password"
                    } | Set-Content $a
                }
            }
        }
    }
}
