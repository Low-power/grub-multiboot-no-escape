## Introduction
GRUB2 cannot be used to boot early Solaris release (before 11.2) from ZFS root, due to the kernel cannot parse the command line that the GRUB passed in. In order booting up a Solaris OS from ZFS, the boot-loader need to pass some parameters to tell the kernel where to find zpool, and which one is root file system in the zpool, as following syntax:
```
-B zfs-bootfs=<pool-name>/<fs-num>,bootpath="<device-physical-path>",diskdevid="<device-logic-path>"
```
for example:
```
-B zfs-bootfs=zr/96,bootpath="/pci@0,0/pci103c,30be@1f,2/disk@0,0:s",diskdevid="id1,sd@SATA_____Hitachi_HTS54321091222FBH206VCHTSM0C/s"
```
Note the double quotes in the command line, this is necessary to specify a value that contains commas so the kernel dosen't think such a comma indicates next parameter. The problem in GRUB2 is, the quotes are escaped, the above command that passed the kernel will become:
```
-B zfs-bootfs=zr/96,bootpath=\"/pci@0,0/pci103c,30be@1f,2/disk@0,0:s\",diskdevid=\"id1,sd@SATA_____Hitachi_HTS54321091222FBH206VCHTSM0C/s\"
```
So the kernel being messed up, complains about unrecognized parameters and then panics due to failed to find a root file system.
This program is actully a small patch to the GRUB mutilboot module, that will not escape the command line; in fact it will not modify the command line in any way.

Starting with Solaris 11.2, the kernel recognizes escaped double quotes, thus be able to boot from GRUB2, without need this program.

## Build and Installation
To build this module, configure and build a GRUB from source at first (Tested on GRUB 2.02 source code), copy files **inside** the `src/` directory into the `grub-core/` directory of the GRUB source tree, **enter that directory**, then run the build-multiboot_no_escape.sh script. A module named multiboot_no_escape.mod will appear if build successful; copy the file multiboot_no_escape.mod to your GRUB installation directory, typically /boot/grub/i386-pc if you are using legacy PC BIOS to boot up GRUB.

## Usage
Just issue a `insmod multiboot_no_escape` in GRUB commands before using `multiboot` command to load a Solaris kernel; put this line in your `grub.cfg`. See also the `example-grub.cfg` in this repository.

## Warranty
There's absolutely **NO WARRANTY**. Use the program at your own risk.

## License
Since the code is copied from GRUB2, the original license (GPL-3+) terms applies.
