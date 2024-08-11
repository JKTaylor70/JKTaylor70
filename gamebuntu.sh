#!/bin/bash

# Gamebuntu, a simple script to transform an Ubuntu install into a complete game-ready (!) setup
# Copyright (C) 2021  Rudra Saraswat

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# See <https://www.gnu.org/licenses/> for the license.

set -e

cd "$(mktemp -d -t gamebuntu-XXXXXXXXXXXX)"

# start info
cat <<EOF
  ________                         ___.                    __           
 /  _____/ _____     _____    ____ \_ |__   __ __   ____ _/  |_  __ __  
/   \  ___ \__  \   /     \ _/ __ \ | __ \ |  |  \ /    \\   __\|  |  \ 
\    \_\  \ / __ \_|  Y Y  \\  ___/ | \_\ \|  |  /|   |  \|  |  |  |  / 
 \______  /(____  /|__|_|  / \___  >|___  /|____/ |___|  /|__|  |____/  
        \/      \/       \/      \/     \/             \/               

This script will set up a basic (modern) game-ready Ubuntu environment for you.

EOF

# add universe and multiverse
sudo add-apt-repository -y universe
sudo add-apt-repository -y multiverse

# mesa PPA (remove once an official PPA is available)
sudo add-apt-repository -y ppa:kisak/kisak-mesa
sudo apt-get update && sudo apt-get dist-upgrade

# install xanmod kernel
echo 'deb http://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list    
wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/xanmod-kernel.gpg add -
sudo apt update && sudo apt install linux-xanmod-x64v3

# install lutris and steam
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo apt install -y lutris steam wine

# install discord snap
sudo snap install discord

# enable support for i386 packages
sudo dpkg --add-architecture i386 && sudo apt update

# install other packages
sudo apt install -y mesa-utils vulkan-tools libegl1:i386

# install noisetorch
#curl -s https://api.github.com/repos/lawl/NoiseTorch/releases/latest \
#    | grep '/NoiseTorch_x64.tgz' \
#    | cut -d : -f 2,3 \
#    | tr -d \" \
#    | wget -qi -
wget -q https://github.com/noisetorch/NoiseTorch/releases/download/v0.12.2/NoiseTorch_x64_v0.12.2.tgz
mv NoiseTorch_x64_v0.12.2.tgz ./NoiseTorch_x64.tgz
tar -C "$HOME" -xzf NoiseTorch_x64.tgz && gtk-update-icon-cache
sudo setcap 'CAP_SYS_RESOURCE=+ep' ~/.local/bin/noisetorch

# install pulseeffects and OBS
sudo apt install -y pulseeffects
sudo snap install obs-studio

# install Kodi from PPA
sudo add-apt-repository -y ppa:team-xbmc/ppa
sudo apt install -y kodi

# Build and install steamos-compositor-plus
git clone https://github.com/ChimeraOS/steamos-compositor-plus
cd steamos-compositor-plus && sudo apt build-dep -y .
sudo apt install -y devscripts
debuild -us -uc -b && cd .. && sudo apt install ./*.deb
# TODO: Complete Steam full-screen session

# GNOME-specific tweaks
gsettings set org.gnome.shell.extensions.dash-to-dock click-action minimize || true

# info at the end
echo
echo "If you'll be using Steam, it's recommended that you enable Proton to run Windows games in Wine."
