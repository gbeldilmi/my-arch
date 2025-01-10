#!/usr/bin/env bash

source 1-dev.sh

####################################################################################################
# GPU drivers
####################################################################################################

sudo pacman -S mesa vulkan-intel intel-gpu-tools --noconfirm


####################################################################################################
# Spotify
####################################################################################################

git clone https://aur.archlinux.org/spotify.git
cd spotify && makepkg -sri


####################################################################################################
# Install KDE Plasma
####################################################################################################

sudo pacman -S plasma-meta kde-applications sddm --noconfirm
sudo systemctl enable sddm
sudo systemctl start sddm
