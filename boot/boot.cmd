setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p2 rootwait panic=10  ${extra}
ext2load mmc 0 0x43000000 boot/script.bin
ext2load mmc 0 0x48000000 boot/uImage
ext2load mmc 0 0x49000000 boot/initramfs.uImage
bootm 0x48000000 0x49000000
