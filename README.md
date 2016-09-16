This prepares a minimal BlankOn for Cubieboard2. At the moment it is configured for a cubieboard2 with DVK521 board + LCD 7".

### Requirements
* sunxi-tools
* linux-utils
* a cubieboard2 kernel and modules
* BlankOn armhf rootfs

### Preparations
* make and make install sunxi-tools
* Put kernel in the same directory of this script with `uImage` name.
* Put kernel modules tree in `lib` directory in the same directory. If you don't need modules, then you will have a very small rootfs.

```
./build.sh
```

You will have a cubieboard2-blankon.img and ready to be put into your SD card with dd:

```
dd if=cubieboard2-blankon.img of=/dev/SDCARD bs=1M
```

Adjust `/dev/SDCARD` to your sd card path.
