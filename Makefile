DD=dd
MKFAT=mkfs.fat
PARTED=parted -s
NASM=nasm

clean:
	rm -f bootloader.bin

mbr: stage1.asm
	$(NASM) -f bin stage1.asm -o bootloader.bin

test: all
	qemu-system-x86_64 bootloader.bin
