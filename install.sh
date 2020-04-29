#!/bin/bash
set -v
set -x

parted --script /dev/sda \
    mklabel msdos \
    mkpart primary 0G 20G \
    mkpart primary 20G 156G \
    mkpart primary 170G 100% \
	set 1 boot on
sleep 5
mkfs.ntfs -f /dev/sda1
mkfs.ntfs -f /dev/sda2
mkfs.ext4 /dev/sda3
sleep 10
fdisk /dev/sda <<EOF
t
1
7

t
2
7

w
EOF


# Mount them
mkdir /mnt/sda1
mount /dev/sda1 /mnt/sda1
mkdir /mnt/sda3
mount /dev/sda3 /mnt/sda3

cd /mnt/sda3
sleep 10
#Donwload win image
#wget https://nawzil.com/1909/64
#wget -O 64 http://vm.abcd.tools/windows_server/RU_Windows2012.iso
wget -O 64 http://vm.abcd.tools/windows_server/RU_Windows2019.iso
#Download drivers
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso

sleep 5
mkdir /mnt/cd
mount -o loop /mnt/sda3/64 /mnt/cd

cp -av /mnt/cd/* /mnt/sda1/

umount /mnt/cd
sleep 5

apt update
apt install software-properties-common -y
add-apt-repository ppa:nilarimogard/webupd
apt install wimtools -y

sleep 5
mount /mnt/sda3/virtio-win.iso /mnt/cd
mkdir /mnt/sda1/virtio && cp -av /mnt/cd/* /mnt/sda1/virtio

sleep 5
mkdir /mnt/wim
wimmountrw /mnt/sda1/sources/boot.wim 1 /mnt/wim
mkdir /mnt/wim/virtio
cp -av /mnt/cd/* /mnt/wim/virtio
wimunmount --commit /mnt/wim

wimmountrw /mnt/sda1/sources/boot.wim 2 /mnt/wim
mkdir /mnt/wim/virtio
cp -av /mnt/cd/* /mnt/wim/virtio
wimunmount --commit /mnt/wim

sync

sleep 5

cd /tmp
umount /mnt/cd
umount /mnt/sda1

wget https://github.com/it-toppp/win/raw/master/ms-sys
chmod +x ms-sys
sleep 5
./ms-sys -n /dev/sda1
./ms-sys -7 /dev/sda
sync
