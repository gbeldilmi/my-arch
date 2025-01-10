#!/usr/bin/env bash

source my-arch.cfg

####################################################################################################
# Configuration of the system
####################################################################################################

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc --utc
echo "KEYMAP=fr-latin9" > /etc/vconsole.conf
echo "$_system_hostname" > /etc/hostname


####################################################################################################
# Bootloader installation
####################################################################################################

if [ $_system_boot_uefi = "1" ]; then ##### UEFI
  pacman -Syy grub efibootmgr --noconfirm
  mount | grep efivars &> /dev/null || mount -t efivarfs efivarfs /sys/firmware/efi/efivars
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
  mkdir /boot/efi/EFI/boot
  cp /boot/efi/EFI/grub/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
  grub-mkconfig -o /boot/grub/grub.cfg

else ##### BIOS
  pacman -Syy grub --noconfirm
  grub-install --no-floppy --recheck $_system_boot_device
  grub-mkconfig -o /boot/grub/grub.cfg
fi


####################################################################################################
# User creation
####################################################################################################

passwd root
chsh -s $_system_shell
#visudo # #Uncomment to allow members of group wheel to execute any command
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
useradd -m -g wheel -c "$_system_user" -s $_system_shell $_system_user
passwd $_system_user


####################################################################################################
# Network configuration
####################################################################################################

if [ $_system_network_networkmanager = "1" ]; then ##### With NetworkManager
  pacman -S networkmanager --noconfirm
  systemctl enable NetworkManager

  if [ $_system_network_wireless = "1" ]; then ##### Wireless connection
    nmcli device wifi connect $_system_network_wireless_ssid \
        password $_system_network_wireless_passwd
  fi

  if [ $_system_network_bonding = "1" ]; then ##### Bonding with NetworkManager
    ###################################################################################
  fi

else ##### With systemd-networkd and systemd-resolved
  systemctl enable systemd-networkd
  systemctl enable systemd-resolved

  if [ $_system_network_wireless = "1" ]; then ##### Wireless connection with iwd
    # /etc/systemd/network/20-[interface].network
    echo "[Match]" > /etc/systemd/network/20-$_system_network_wireless_device.network
    echo "Name=$_system_network_wireless_device" >> /etc/systemd/network/20-$_system_network_wireless_device.network
    echo "" >> /etc/systemd/network/20-$_system_network_wireless_device.network
    echo "[Network]" >> /etc/systemd/network/20-$_system_network_wireless_device.network
    echo "DHCP=yes" >> /etc/systemd/network/20-$_system_network_wireless_device.network
    echo "IgnoreCarrierLoss=5s" >> /etc/systemd/network/20-$_system_network_wireless_device.network

    pacman -S iwd --noconfirm
    systemctl enable iwd
    iwctl --passphrase=$_system_network_wireless_passwd station $_system_network_wireless_device \
        connect $_system_network_wireless_ssid
  fi

  if [ $_system_network_bonding = "1" ]; then ##### Bonding with systemd-networkd 
    # /etc/systemd/network/30-bond0.netdev
    cp ./etc/systemd/network/30-bond0.netdev /etc/systemd/network/30-bond0.netdev

    # /etc/systemd/network/30-bond0.network
    cp ./etc/systemd/network/30-bond0.network /etc/systemd/network/30-bond0.network
    echo "BindCarrier=$_system_network_bonding_interfaces" >> /etc/systemd/network/30-bond0.network

    # /etc/systemd/network/30-[interface].network
    for interface in $_system_network_bonding_interfaces; do
      echo "[Match]" > /etc/systemd/network/30-$interface.network
      echo "Name=$interface" >> /etc/systemd/network/30-$interface.network
      echo "" >> /etc/systemd/network/30-$interface.network
      echo "[Network]" >> /etc/systemd/network/30-$interface.network
      echo "Bond=bond0" >> /etc/systemd/network/30-$interface.network
    done
  fi
fi

##### Hosts file
cp /etc/hosts /etc/hosts.bak
cp ./etc/hosts /etc/hosts


####################################################################################################
# Services and main packages
####################################################################################################

pacman -S syslog-ng cronie ntp openssh

echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
echo "AllowUsers=$_system_user" >> /etc/ssh/sshd_config

systemctl enable syslog-ng@default
systemctl enable cronie
systemctl enable ntpd
systemctl enable sshd

pacman -S gzip {b,h}top neofetch parallel pi{g,x}z tar tree

echo "neofetch" >> /etc/profile.d/neofetch.sh


####################################################################################################
# Initramfs
####################################################################################################

mkinitcpio -P
