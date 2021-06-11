DD=dd
MKFAT=mkfs.fat
PARTED=parted -s
NASM=nasm

default: mbr

clean:
	rm -f bootloader.bin

mbr: stage1.asm
	$(NASM) -f bin stage1.asm -o bootloader.bin

test: bootloader.bin
	qemu-system-x86_64 bootloader.bin
