DD=dd
MKFAT=mkfs.fat
PARTED=parted -s
NASM=nasm
QEMU=qemu-system-x86_64
DRIVE=digital-16gb-windows-flashdrive.bin

default: mbr

clean:
	rm -f bootloader.bin

mbr: stage1.asm
	$(NASM) -f bin stage1.asm -o bootloader.bin

test: mbr bootloader.bin
	$(QEMU) bootloader.bin

testdrive: mbr bootloader.bin
	$(DD) if=bootloader.bin of=$(DRIVE) bs=1 count=436 conv=notrunc
	$(QEMU) -drive format=raw,file=$(DRIVE)
