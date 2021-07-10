#name of virtual disk
DISK_NAME:="virtual-disk.bin"
#size of disk in megabytes
DISK_SIZE:=1000
#local mountpoint for virtual disk
DISK_MOUNT="disk_mount"
KERNEL_FILE="uos.elf"

#bootloader files
LIMINE="limine/BOOTX64.EFI"
LIMINESYS="limine/limine.sys"
LIMINECFG="limine/limine.cfg"

DD=dd
PARTED=parted
MCOPY=mcopy
MKFAT=mkfs.fat -F 32
MOUNT=mount
MKDIR=mkdir -p

default: disk

clean: ${DISK_NAME}
	rm -f ${DISK_NAME}

disk:
	$(DD) if=/dev/zero of=${DISK_NAME} bs=1024K count=${DISK_SIZE}
	$(PARTED) --script ${DISK_NAME} \
		--align optimal \
		mklabel gpt \
		mkpart ESP fat32 0% 500M \
		mkpart system fat32 500M 100%
	LOOPBACK_NAME=$(sudo losetup -Pf --show ${DISK_NAME})
	sudo $(MKFAT) ${LOOPBACK_NAME}p1
	sudo $(MKFAT) ${LOOPBACK_NAME}p2
	$(MKDIR) ${DISK_MOUNT}
	sudo $(MOUNT) ${LOOPBACK_NAME}p2 ${DISK_MOUNT}
	sudo $(MKDIR) ${DISK_MOUNT}/EFI/BOOT
	sudo $(MOUNT) ${LOOPBACK_NAME}p1 ${DISK_MOUNT}/EFI/BOOT
	sudo cp -v ${KERNEL_FILE} ${LIMINECFG} ${LIMINESYS} ${DISK_MOUNT}
	sudo cp -v ${LIMINE} ${DISK_NAME}/EFI/BOOT
	sync
	sudo umount ${DISK_MOUNT}
	sudo losetup -d ${LOOPBACK_NAME}
