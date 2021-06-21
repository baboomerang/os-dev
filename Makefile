DD=dd
NASM=nasm
PARTED=parted -s
MKFAT=mkfs.fat
QEMU=qemu-system-x86_64

default: mbr

clean:
	rm -f bootloader.bin

mbr: stage1.asm
	$(NASM) -f bin stage1.asm -o bootloader.bin

vbr: stage2.asm
	$(NASM) -f bin stage2.asm -o fat32vbr.bin

test: mbr vbr
	$(DD) if=/dev/zero of=fat32-testdrive.bin bs=1024 count=1024
	$(PARTED) fat32-testdrive.bin mklabel msdos
	$(PARTED) fat32-testdrive.bin mkpart primary fat32 0% 100%
	$(PARTED) fat32-testdrive.bin set 1 boot on
	$(MKFAT) -F 32 fat32-testdrive.bin
	$(DD) if=bootloader.bin of=fat32-test
	$(QEMU)

testdrive: mbr bootloader.bin
	$(DD) if=bootloader.bin of=$(DRIVE) bs=1 count=436 conv=notrunc
	$(QEMU) -drive format=raw,file=$(DRIVE)
