
# tested on Ubuntu 22.04
$_packages = Get-Content .conf/deps.json | ConvertFrom-Json

# docker and docker-compose are special cases
# TODO: check also for podman or other runtimes
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker installed"
    exit 69
}

if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker-compose installed"
    exit 69
}

# ok docker and docker-compose exist so let's check the packages
$_packagesToInstall = New-Object Collections.Generic.List[string]

Write-Host -ForegroundColor Yellow "Checking dependencies ..."

foreach ($package in $_packages.packages) {
    dpkg -s $package > /dev/null 2>&1
    
    if ($? -eq $false) {
        $_packagesToInstall.Add($package)
        Write-Host -ForegroundColor DarkRed "😵 $package not installed"
    } else {
        Write-Host -ForegroundColor DarkGreen "👍 $package installed"
    }
}

# ask if the user want to install the packages that are not installed
if ($_packagesToInstall.Count -gt 0) {
    $_installConfirm = Read-Host `
        "Do you want to try to install the dependencies? <y/N>"

    if ($_installConfirm -eq 'y') {
        foreach ($item in $_packagesToInstall) {
            sudo apt install $item
        }
    }
} else {
    # we need to ran the check deps only if it's not ran yet
    New-Item -Path .conf/ -Name .depok -ItemType File 2>&1 | out-null
}
