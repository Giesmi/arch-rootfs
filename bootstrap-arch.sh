#!/bin/bash

set -e

echo "Making directories"
mkdir -p "/tmp/arch"
mkdir "/tmp/depthboot"

echo "Bootstrapping arch"
wget -O /tmp/depthboot/arch-rootfs.tar.gz https://geo.mirror.pkgbuild.com/iso/latest/archlinux-bootstrap-x86_64.tar.gz
git clone --depth=1 https://github.com/eupnea-linux/systemd-services /tmp/depthboot/systemd-services
git clone --depth=1 https://github.com/eupnea-linux/postinstall-scripts /tmp/depthboot/postinstall-scripts
git clone --depth=1 https://github.com/eupnea-linux/audio-scripts /tmp/depthboot/audio-scripts
tar xfp /tmp/depthboot/arch-rootfs.tar.gz
ls
ls
cp -r /tmp/depthboot/arch-rootfs/root.x86_64/ /tmp/arch
mkdir -p /tmp/arch/run/systemd/resolve
cp /etc/resolv.conf /tmp/arch/run/systemd/resolve/stub-resolv.conf
cp /etc/resolv.conf /tmp/arch/etc/resolv.conf
rm /tmp/depthboot/postinstall/LICENSE /tmp/depthboot/postinstall-scripts/README.md /tmp/depthboot/postinstall-scripts/.gitignore
cp /tmp/depthboot/postinstall-scripts/* /tmp/arch/usr/local/bin
cp /tmp/depthboot/audio-scripts/setup-audio" "/tmp/arch/usr/local/bin/setup-audio
wget https://raw.githubusercontent.com/eupnea-linux/depthboot-builder/main/functions.py /tmp/arch/usr/local/bin
chroot /tmp/arch /bin/bash -c "chmod 755 /usr/local/bin/*"
mkdir /tmp/arch/etc/eupnea
git clone https://github.com/eupnea-linux/depthboot-builder /tmp/depthboot/depthboot-builder
cp -r /tmp/depthboot/depthboot-builder/configs/* /tmp/arch/etc/eupnea
cp -r /tmp/depthboot/postinstall-scripts/configs/* /tmp/arch/etc/eupnea
cp -r /tmp/depthboot/audio-scripts/configs/* /tmp/arch/etc/eupnea
mkdir /tmp/arch/etc/systemd/
echo "SuspendState=freeze HibernateState=freeze" > /tmp/arch/etc/systemd/sleep.conf
chroot /tmp/arch /bin/bash -c "systemctl enable systemd-resolved"
cp /tmp/depthboot/depthboot-builder/configs/eupnea-modules.conf /tmp/arch/etc/modules-load.d/eupnea-modules.conf
chroot /tmp/arch /bin/bash -c "useradd --create-home --shell /bin/bash giesmi"
chroot /tmp/arch /bin/bash -c "echo "giesmi:password" | chpasswd"
chroot /tmp/arch /bin/bash -c "usermod -aG wheel giesmi"
wget https://github.com/natesway/natesway/raw/main/arch.py /tmp/depthboot
wget https://raw.githubusercontent.com/eupnea-linux/depthboot-builder/main/functions.py /tmp/depthboot
python3 /tmp/depthboot/arch.py
rm /tmp/depthboot/systemd-services/LICENSE /tmp/depthboot/systemd-services/README.md /tmp/depthboot/systemd-services/.gitignore
cp /tmp/depthboot/systemd-services/* /tmp/arch/etc/systemd/system/
echo "Compressing rootfs"
cd "/tmp/arch"
tar -cv -I 'xz -9 -T0' -f ../arch-rootfs.tar.xz ./
