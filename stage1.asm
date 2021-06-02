bits 16

section .mbr start=0x0000 vstart=0x7c00
_FAT32_BPB:
    .MagicNumber           db 0xeb, 0x54, 0x90
    .OEMLabel              db "MSWIN4.1"
    .BytesPerSector        dw 0x0200
    .SectorsPerCluster     db 0x01
    .ReservedSectors       dw 0x0001
    .Fats                  db 0x02
    .RootDirEntries        dw 0x0000
    .TotalSectors          dw 0x0000
    .MediaDescriptorType   db 0xf8
    .TotalSectors_12_16    dw 0x0009
    .SectorsPerTrack       dw 0xffff
    .NumberOfHeads         dw 0x0001
    .NumberOfHiddenSectors dd 0x00000000
    .NumberOfLargeSectors  dd 0x00000000
.FAT32_EBP:
    .SectorsPerFat_32      dd 0x00000000
    .Flags_32              dw 0x0000
    .FatVersionNumber_32   dw 0x0001
    .ClusterNumberRootDir  dd 0x00000002
    .SectorNumberFSInfo    dw 0x0001
    .BackupBootSector      dw 0x0000
    .Reserved8bytes        dq 0x0000000000000000
    .Reserved4bytes        dd 0x00000000
    .DriveNumber           db 0x00
    .WindowsNTFlags        db 0x00
    .Signature             db 0x29
    .VolumeSerialNumber    db "os-dev56789"
    .SystemIdentifier      db "FAT32   "
_start:
    jmp    0x0000:.start
.start:
    cli
    cld
    clc
    xor    ax, ax
    mov    ds, ax
    mov    es, ax
    mov    ss, ax
    mov    fs, ax
    mov    gs, ax
    mov    bp, 0x7c00
    mov    sp, bp
    mov    byte [bootdrive], dl

    xor    ah, ah          ;VIDEO - SET VIDEO MODE
    mov    al, 0x03        ;720x400p, 80 columns * 25 rows in 16 bit colors
    int    0x10
    mov    ah, 0x07        ;VIDEO - SCROLL DOWN WINDOW
    xor    al, al          ;clear entire window
    mov    bh, 01001111b
    xor    cx, cx          ;CH,CL = row,column of window's upper left corner
    mov    dh, 0x19        ;0x19 = 25 rows
    mov    dl, 0x50        ;0x50 = 80 columns
    int    0x10

_end:
    hlt
    jmp    _end

bootdrive db 0x0
a20err    db "HALT: A20 line is not enabled!", 0x0

%include "disk.asm"
%include "print.asm"

section .mbr_signature start=0x01fe vstart=0x7dfe
dw 0xaa55

%include "stage2.asm"
