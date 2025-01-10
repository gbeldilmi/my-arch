#!/usr/bin/env bash

source 1-prod.sh

####################################################################################################
# Development tools
####################################################################################################

sudo pacman -S jdk-openjdk lua nmap python ruby rust wget --noconfirm
