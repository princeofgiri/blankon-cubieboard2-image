setenv bootargs console=ttyS0,115200 root=/dev/mmcblk0p1 panic=10 init=/init ${extra}
ext2load mmc 0 0x43000000 boot/script.bin
ext2load mmc 0 0x48000000 boot/uImage
bootm 0x48000000
