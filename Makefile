#name of disk
DISK_NAME:="test-disk.bin"
#size of disk in megabytes
DISK_SIZE:=1000

DD=dd
PARTED=parted
MCOPY=mcopy
MKFAT=mkfs.fat -F 32

ESP_OFFSET=$(parted --script ${DISK_NAME} unit s p | awk '/ESP/ { print $$2 }' | sed 's/.$$//')

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
	MOUNTED_NAME=$(sudo losetup -Pf --show ${DISK_NAME})
	sudo $(MKFAT) ${MOUNTED_NAME}p1



