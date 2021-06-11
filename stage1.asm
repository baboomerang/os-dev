bits 16
section .mbr start=0x0000 vstart=0x7c00
_FAT32_BPB:
    .Jump                  db 0xeb, 0x54, 0x90
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
_FAT32_EBPB:
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
    jmp    0x0000:.setcs
.setcs:
    cld
    xor    ax, ax
    mov    ss, ax
    mov    sp, 0x7c00
    mov    bp, sp
    mov    ds, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    byte [drive], dl
    mov    si, 0x7c00
    mov    di, 0x600
    mov    cx, 0x100       ;256 words, 512 bytes
    rep    movsw
    jmp    0x600 + .relocate - $$
.relocate:
    xor    ah, ah          ;set video mode
    mov    al, 0x3         ;720x400p, 80 columns * 25 rows in 16 bit colors
    int    0x10
    mov    ah, 0x7         ;scroll down window
    xor    al, al          ;clear all rows
    mov    bh, 01001111b
    xor    cx, cx          ;ch,cl = row,column of window's upper left corner
    mov    dh, 0x19        ;0x19 = 25 rows
    mov    dl, 0x50        ;0x50 = 80 columns
    int    0x10
.load_stage2:
    mov    al, byte [drive]
    mov    bh, 2           ;start at sector 2
    mov    bl, 1           ;read only one sector
    call   read_disk
    jc     error.disk
.detect_a20:
    cli
    call   set_a20
    call   check_a20
    jc     error.a20
    sti

    jmp    stage2

error:
.a20:
    mov    si, a20err
    jmp    .print
.disk:
    mov    si, diskerr
.print:
    mov    ah, 0xe
.L1:
    lodsb
    test   al, al
    jz     .L2
    int    0x10
    jmp    .L1
.L2:
    hlt
    jmp    .L2

%include "a20.asm"
%include "disk.asm"

drive   db 0x0
stage2  dw 0x0
a20err  db "HALT: A20 Line is not enabled", 0x0
diskerr db "HALT: Failed to read boot disk", 0x0

section .mbr_signature start=0x01fe vstart=0x7dfe
dw 0xaa55

%include "stage2.asm"
