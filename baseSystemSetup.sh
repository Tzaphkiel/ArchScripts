# base package insatallation
pacman -Syu git zsh htop openssh openssl ntfs-3g fuse-exfat exfat-utils tmux unzip p7zip

# enable sshd
systemctl enable sshd.service
systemctl start sshd.service

# configure system for virtualbox
# see https://wiki.archlinux.org/index.php/VirtualBox#Installation_steps_for_Arch_Linux_guests
pacman -S virtualbox-guest-utils-nox
modprobe -a vboxguest vboxsf vboxvideo
echo "vboxguest" >>/etc/modules-load.d/virtualbox.conf
echo "vboxsf" >>/etc/modules-load.d/virtualbox.conf
echo "vboxvideo " >>/etc/modules-load.d/virtualbox.conf
systemctl enable vboxservice
VBoxClient --clipboard --draganddrop --seamless --display --checkhostversionVBoxClient --clipboard --draganddrop --seamless --display --checkhostversion


# add a default user
useradd -m -g users -G wheel,storage,power,audio -s /usr/bin/zsh leroyse
echo leroyse:leroyse | chpasswd
