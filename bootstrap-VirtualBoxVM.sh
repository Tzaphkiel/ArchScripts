# confirm you can access the internet
# current site chosen gives a 302 not a 200
# if [[ ! $(curl -I http://www.google.com/ | head -n 1) =~ "200 OK" ]]; then
#   echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue."
#   read
# fi

# make 2 partitions on the disk.
parted -s /dev/sda mktable msdos
parted -s /dev/sda mkpart primary 0% 100m
parted -s /dev/sda mkpart primary 100m 100%

# make filesystems
# /boot
mkfs.ext2 /dev/sda1
# /
mkfs.ext4 /dev/sda2

# set up /mnt
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# install base packages (take a coffee break if you have slow internet)
pacstrap /mnt base base-devel syslinux vim netctl net-tools dialog

# install syslinux
arch-chroot /mnt pacman -S syslinux

# generate fstab
genfstab -p /mnt >>/mnt/etc/fstab

# chroot
arch-chroot /mnt /bin/bash <<EOF

# set initial hostname
echo "archlinux-$(date -I)" >/etc/hostname

# set initial timezone to Europe/Brussels
ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# set initial locale
locale >/etc/locale.conf
echo "en_GB.UTF-8 UTF-8" >>/etc/locale.gen
echo "en_GB ISO-8859-1" >>/etc/locale.gen
echo "fr_BE.UTF-8 UTF-8" >>/etc/locale.gen
echo "fr_BE@euro ISO-8859-1" >>/etc/locale.gen
locale-gen

# set key map
echo "KEYMAP=be-latin1" >>/etc/vconsole.conf

# no modifications to mkinitcpio.conf should be needed
mkinitcpio -p linux

# install syslinux bootloader
syslinux-install_update -i -a -m

# update syslinux config with correct root disk
sed 's/root=\S+/root=\/dev\/sda2/' < /boot/syslinux/syslinux.cfg > /boot/syslinux/syslinux.cfg.new
mv /boot/syslinux/syslinux.cfg.new /boot/syslinux/syslinux.cfg

# set root password to "root"
echo root:root | chpasswd

# end section sent to chroot
EOF

# unmount
umount /mnt/{boot,}

echo "Done! Unmount the CD image from the VM, then type 'reboot'."
