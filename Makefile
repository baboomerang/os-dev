DD=dd
MKFAT=mkfs.fat
PARTED=parted -s
NASM=nasm
QEMU=qemu-system-x86_64

default: mbr

clean:
	rm -f bootloader.bin

mbr: stage1.asm
	$(NASM) -f bin stage1.asm -o bootloader.bin

test: mbr bootloader.bin
	$(QEMU) bootloader.bin
