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

$env:DOCKER_HOST = ""

if ($Env:GITLAB_CI -eq $true) {
    Write-Host "ℹ️ :: GITLAB_CI :: ℹ️"
    $Env:DOCKER_HOST = "tcp://docker:2375"
}


# docker and docker-compose are special cases
# TODO: check also for podman or other runtime
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker installed"
    exit 69
}

$_dockerComposeV = (docker compose version)

if ($? -eq $false || [string]::IsNullOrEmpty($_dockerComposeV)) {
    Write-Host -ForegroundColor DarkRed "❌ you need docker compose plugin installed"
    exit 69
}

# Get the deps at .conf/deps.json file
$_deps = Get-Content .conf/deps.json | ConvertFrom-Json


# ok docker and docker-compose exist so let's check the packages
$_packagesToInstall = New-Object Collections.Generic.List[string]


# Check if all dependencies are installed
Write-Host -ForegroundColor Yellow "Checking dependencies ..."

foreach ($package in $_deps.packages) {

    dpkg -s $package > /dev/null 2>&1

    if ($? -eq $false) {
        $_packagesToInstall.Add($package)
        Write-Host -ForegroundColor DarkRed "😵 $package debian package dependency not installed"
    } else {
        Write-Host -ForegroundColor DarkGreen "👍 $package debian package dependency installed"
    }
}

$_scriptsToInstall = New-Object Collections.Generic.List[string]

# Check if all dependency installation scripts have been executed before for this project on this machine
foreach ($script in $_deps.installDepsScripts) {
    # For scripts, check if their name is present at the .conf/.depok file to see if they have been executed before
    $scriptInstalled = (Test-Path ./.conf/.depok) -and (Get-Content ./.conf/.depok | Select-String $script -Quiet)

    if ($scriptInstalled -eq $false) {
        $_scriptsToInstall.Add($script)
        Write-Host -ForegroundColor DarkRed "😵 $script dependency installation script not executed before for this project on this machine"
    } else {
        Write-Host -ForegroundColor DarkGreen "👍 $script dependency installation script executed before for this project on this machine"
    }
}

# Check if there are any packages to be installed or scripts to be executed
if ($_packagesToInstall.Count -eq 0 -and $_scriptsToInstall.Count -eq 0) {
    Write-Host -ForegroundColor DarkGreen "✅ All packages already installed and installation script executed before for this project on this machine"

    # we need to ran the check deps only if it's not ran yet
    New-Item -Path .conf/ -Name .depok -ItemType File 2>&1 | out-null
} else {

    $_packagesInstalledOk = $true
    $_scriptsInstalledOk = $true

    # ask if the user want to install the packages that are not installed
    if ($_packagesToInstall.Count -gt 0) {

    $_packagesInstalledOk = $false

    $_installConfirm = Read-Host `
        "Do you want to try to install the missing debian package dependencies? <y/N>"

        if ($_installConfirm -eq 'y') {
            # make sure to update the list first
            sudo apt-get update

            $_installedScrips = New-Object Collections.Generic.List[string]

            # Try to install the packages
            foreach ($item in $_packagesToInstall) {
                    sudo apt-get install -y $item

                if ($? -eq $false) {
                    Write-Host -ForegroundColor DarkRed "❌ error trying to install package $item"
                    exit 69
                }
            }

            Write-Host -ForegroundColor DarkGreen "✅ All packages installed successfully"

            $_packagesInstalledOk = $true

        }
    }
    # ask if the user want to execute the installation scripts that have not been executed before for this project on this machine
    if ($_scriptsToInstall.Count -gt 0) {

        $_scriptsInstalledOk = $false

        $_installConfirm = Read-Host `
            "Do you want to try to install the missing debian package dependencies? <y/N>"

            if ($_installConfirm -eq 'y') {

                $_installedScrips = New-Object Collections.Generic.List[string]

                # Try to execute the installation scripts
                foreach ($item in $_scriptsToInstall) {
                    if ($item.EndsWith('.sh')) {
                        chmod +x $item
                    }

                    $_installedScrips.Add($item)
                    & ./$item 2>&1

                    if ($? -eq $false) {
                        Write-Host -ForegroundColor DarkRed "❌ error trying to execute the dependency installation script $item"
                        exit 69
                    }
                }

                Write-Host -ForegroundColor DarkGreen "✅ All packages dependency installation scripts executed successfully"

                $_scriptsInstalledOk = $true

            }
        }

    if ($_packagesInstalledOk -eq $true -and $_scriptsInstalledOk -eq $true) {

        # all packages installed then dep ok
        New-Item -Path .conf/ -Name .depok -ItemType File 2>&1 | out-null

        # Add the name of the scripts to the .conf/.depok to know that it has
        # already been executed for this project on this machine
        foreach ($item in $_installedScrips) {
            Add-Content -Path ./.conf/.depok -Value ("$item" + "`n")
        }
    }

}
