#!/usr/bin/env bash

source my_arch.cfg

####################################################################################################
# Git
####################################################################################################

git config --global init.defaultBranch dev
git config --global user.name $_git_username
git config --global user.email $_git_email
git config --global core.editor vim
git config --global core.eol lf
git config --global core.autocrlf input
sudo git config --system receive.fsckObjects true

####################################################################################################
# NFS
####################################################################################################

if [ $_nfs_server = "1" ]; then
  sudo pacman -S nfs-utils --noconfirm
  for directory in $_nfs_shared_directories; do
    mkdir -p $directory || sudo mkdir -p $directory
    sudo chown -R $USER $directory
    for client in $_nfs_clients_hostnames; do
      echo "$directory  " \
          "$client(rw,sync,anonuid=65534,anongid=65534,no_subtree_check,crossmnt,nohide)" | \
          sudo tee -a /etc/exports
    done
  done
  sudo systemctl enable nfs-server.service
  sudo exportfs -arv
fi
