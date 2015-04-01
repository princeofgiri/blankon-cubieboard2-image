#!/bin/bash

. settings

if [ -d ./miniroot ];then
  ./miniroot/build.sh
else
  echo "You need to get the submodules by issuing this command"
  echo "  git submodule init"
  echo "  git submodule update"
  exit
fi

if [ ! -f uImage ];then
  echo "No kernel found, please put uImage file here"
  exit
fi

rm -rf build
mkdir -p build/{tmp,dev,proc,sbin,usr/sbin}
cp -a boot build/
cp -a miniroot/build/* build/
cp uImage build/boot/
pushd build/boot
mkimage -C none -A arm -T script -d boot.cmd boot.scr 
fex2bin script.fex > script.bin
popd

OUTPUT=cubieboard2-blankon.img
dd if=/dev/zero of=$OUTPUT  bs=1M count=$SIZE
echo -e "o\nn\np\n1\n\n\nw\n" | /sbin/fdisk $OUTPUT 
sudo modprobe loop
sudo kpartx -a $OUTPUT
DEV=`sudo kpartx -l $OUTPUT | cut -f1 -d' '`
if [ -z $DEV ];then
  echo "Partitions in $OUTPUT can't be read"
  exit
fi
sleep 1
sudo mkfs.ext4 /dev/mapper/$DEV
sudo tune2fs -i 0 -c 0 /dev/mapper/$DEV  -L BlankOn -O ^has_journal
mkdir -p mnt
sudo mount /dev/mapper/$DEV mnt
sudo cp -a build/* mnt 
sudo umount mnt
sudo kpartx -d $OUTPUT

dd if=build/boot/sunxi-spl.bin of=$OUTPUT bs=1024 seek=8 conv=notrunc
dd if=build/boot/u-boot.bin    of=$OUTPUT bs=1024 seek=32 conv=notrunc



