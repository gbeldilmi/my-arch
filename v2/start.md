# Get started

## Set the keyboard layout

```sh
loadkeys fr
```

## Connect to the internet

Connect to a wifi network if necessary with `iwctl`.

```sh
timedatectl set-ntp true
```

## Configure via ssh

```sh
ip a
passwd
```

Connect to host via ssh with `ssh root@<ip>`.

# Partition the disks

## System partitions

*from archiso*

### BIOS

Partition            | Mount point | Size
-------------------- | ----------- | ------------------
/dev/sda1 (bootable) | /boot       | 512Mo
/dev/sda2            | /           | Remaining space
/dev/sda3            |             | RAM size (max 8Go)
/dev/sdb1 (optional) | /home       | The whole device

```sh
fdisk -l # Results ending in rom, loop or airoot may be ignored

cfdisk /dev/sda
# cfdisk /dev/sdb

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
# mkfs.ext4 /dev/sdb1

mount /dev/sda2 /mnt
mkdir /mnt/{boot,home}
mount /dev/sda1 /mnt/boot
# mount /dev/sdb1 /mnt/home
```

### UEFI

Code | Partition            | Mount point | Size                                    | Description
---- | -------------------- | ----------- | --------------------------------------- | ----------------
ef00 | /dev/sda1            | /boot/efi   | 512Mo                                   | EFI System
8300 | /dev/sda2            | /           | Remaining space                         | Linux filesystem
8200 | /dev/sda3            |             | RAM size (max 8Go, 16Go if RAM > 128Go) | Linux swap
8300 | /dev/sdb1 (optional) | /home       | The whole device                        | Linux filesystem

```sh
fdisk -l # Results ending in rom, loop or airoot may be ignored

cgdisk /dev/sda
# cgdisk /dev/sdb

mkfs.fat -F32 /dev/sda1
mkfs.xfs /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
# mkfs.xfs /dev/sdb1

mount /dev/sda2 /mnt
mkdir /mnt/{boot{,/efi},home}
mount /dev/sda1 /mnt/boot/efi
# mount /dev/sdb1 /mnt/home
```

## Encrypted partitions

Create encrypted partitions:

```sh
sudo cryptsetup luksFormat /dev/sdc1 # --key-file /path/to/key
```

Add key to encrypted partitions and key path to environment:

```sh
sudo cryptsetup luksAddKey /dev/sdc1 /path/to/key
```

Open and format encrypted partitions:

```sh
sudo cryptsetup luksOpen /dev/sdc1 encrypted # --key-file /path/to/key

sudo mkfs.ext4 /dev/mapper/encrypted

sudo mount /dev/mapper/encrypted /mountpoint
```

# Install Arch Linux

```sh
pacstrap -K /mnt base{,-devel} linux{,-firmware} intel-ucode {,un,p7}zip vim {dosfs,m}tools lsb-release ntfs-3g {exfat,xfs}progs man-{db,pages} bash-completion

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

git clone https://github.com/gbeldilmi/my-arch.git
cd my-arch/src
vim my-arch.cfg

./0-system.sh
chown -R $_system_user:wheels .

exit
umount -R /mnt
shutdown now
```

# Post-installation

*As normal user*

```sh
cd /my-arch/src

# Run one of the following scripts
./1-prod.sh
./1-dev.sh
./1-gui.sh
```
