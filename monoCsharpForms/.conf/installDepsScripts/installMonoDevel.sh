#!/bin/bash
set -e

# This is a script to install .MOno on Ubuntu, based on the official Mono project recommended method of installation:
# https://www.mono-project.com/download/stable/#download-lin

package='mono-devel'


# Get the source URL of the mono-devel package installed
source=$(apt policy $package | awk '/ \*/{getline; print $2}')


# Check if the dotnet-sdk installed package comes from the Microsoft source
if [ "$source" != "https://download.mono-project.com/repo/ubuntu"  ]; then

    sudo apt install ca-certificates gnupg -y

    # Get and install mono signing key and repository
    sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

    # Remove the mono-devel installation that doesn't come from the Microsoft source
    sudo apt-get remove $package -y

    sudo apt-get autoremove -y

fi

# Update packages
sudo apt update -y

# Install the mono-devel that come from the Microsoft source
sudo apt-get install $package msbuild -y