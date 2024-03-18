#!/bin/bash
set -e

# This is a script to install .NET on Ubuntu, based on the official Microsoft recommended method of installation:
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu

package='dotnet-sdk-6.0'

# Get Ubuntu version
declare repo_version=$(if command -v lsb_release &> /dev/null; then lsb_release -r -s; else grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"'; fi)

# Get the source URL of the dotnet-sdk package installed
source=$(apt policy $package | awk '/ \*/{getline; print $2}')


# Check if the dotnet-sdk installed package comes from the Microsoft source
if [ "$source" != "https://packages.microsoft.com/ubuntu/$repo_version/prod" ]; then

    # Download Microsoft signing key and repository
    wget https://packages.microsoft.com/config/ubuntu/$repo_version/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

    # Install Microsoft signing key and repository
    sudo dpkg -i packages-microsoft-prod.deb

    # Clean up
    rm packages-microsoft-prod.deb

    # Remove the dotnet-sdk installation that doesn't come from the Microsoft source
    sudo apt-get remove $package -y

    sudo apt-get autoremove -y

fi

# Update packages
sudo apt update -y


# Install the dotnet-sdk that come from the Microsoft source
sudo apt-get install $package -y