# include
. "$env:HOME/.apollox/scripts/utils/execHostCommand.ps1"

function GetHostIp() {
    if (! [string]::IsNullOrEmpty($env:WSL_DISTRO_NAME)) {
        $_out = ExecHostCommand `
                    /mnt/c/Windows/System32/Wbem/WMIC.exe `
                    NICCONFIG WHERE IPEnabled=true GET IPAddress | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])'

        return $_out.split("`n")[0]
    } else {
        $_out = ExecHostCommand -command `
                    "hostname -I | awk '{print `$1}'"

        return $_out
    }
}
