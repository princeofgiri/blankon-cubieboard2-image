#!/bin/bash

. settings

MIN_SIZE=1000
if [ $SIZE -lt $MIN_SIZE ];then
  echo "SIZE in settings is too small for this build"
  echo "It should be more than $MIN_SIZE"
  exit
fi


if [ ! -f uImage ];then
  echo "No kernel found, please put uImage file here"
  exit
fi

rm -rf build/
mkdir build/
cp -a boot build/
cp uImage build/boot/
pushd build/boot
mkimage -C none -A arm -T script -d boot.cmd boot.scr 
fex2bin cubieboard2-cubiescreen.fex > script.bin
popd

OUTPUT=cubieboard2-blankon.img

if [ ! -d devrootfs ];then
  echo "devrootfs/ directory is not found"
  echo "You should prepare a debootstrap in that directory"
  echo "e.g. $ sudo debootstrap sid devrootfs"
  exit
fi

dd if=/dev/zero of=$OUTPUT  bs=1M count=$SIZE
echo -e "o\nn\np\n1\n\n+100M\nn\np\n\n\n\nw\n" | /sbin/fdisk $OUTPUT 
sudo modprobe loop
sudo kpartx -a $OUTPUT

# First partition
DEV=`sudo kpartx -l $OUTPUT | head -1 | cut -f1 -d' '`
if [ -z $DEV ];then
  echo "Partitions in $OUTPUT can't be read"
  exit
fi
sleep 1
sudo mkfs.ext2 /dev/mapper/$DEV
sudo tune2fs -i 0 -c 0 /dev/mapper/$DEV  -L BlankOn -O ^has_journal
mkdir -p mnt
sudo mount /dev/mapper/$DEV mnt

pushd build/;find . | cpio -H newc -o > ../initramfs.img;popd
echo "Initramfs image is in initramfs.img"
mkimage -A arm -O linux -T ramdisk -d initramfs.img initramfs.uImage
cp initramfs.uImage build/boot

sudo cp -a build/* mnt 
sudo umount mnt

# Second partition
DEV=`sudo kpartx -l $OUTPUT | tail -1 | cut -f1 -d' '`
if [ -z $DEV ];then
  echo "Partitions in $OUTPUT can't be read"
  exit
fi
sleep 1
sudo mkfs.ext2 /dev/mapper/$DEV
sudo tune2fs -i 0 -c 0 /dev/mapper/$DEV  -L BlankOn -O ^has_journal

mkdir -p mnt
sudo mount /dev/mapper/$DEV mnt
sudo cp -a devrootfs/* mnt 
sudo umount mnt

sudo kpartx -d $OUTPUT

#dd if=build/boot/u-boot-sunxi-with-spl.bin of=$OUTPUT bs=1024 seek=8 conv=notrunc

dd if=build/boot/sunxi-spl.bin of=$OUTPUT bs=1024 seek=8 conv=notrunc
dd if=build/boot/u-boot.bin    of=$OUTPUT bs=1024 seek=32 conv=notrunc

sudo losetup -d /dev/${DEV:0:5}
