bits 16
section .mbr start=0x000 vstart=0x600
_start:
    cld
    xor    ax, ax
    mov    ss, ax
    mov    sp, 0x7c00
    mov    bp, sp
    mov    ds, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    si, 0x7c00
    mov    di, 0x600
    mov    cx, 0x100       ;256 words, 512 bytes
    rep    movsw
    jmp    0x0000:.relocate
.relocate:
    mov    byte [drive], dl
.set_video:
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
    mov    cl, 4
    mov    bx, partition1
.find_part:
    cmp    byte [bx], 0x80
    je     .load_stage2
    add    bx, 16
    dec    cl
    jnz    .find_part
    jmp    error.part
.load_stage2:
    mov    al, byte [drive]
    mov    bh, 2           ;start at sector 2
    mov    bl, 1           ;read only one sector
    call   read_disk
    jc     error.disk
.detect_a20:
    call   set_a20
    call   check_a20
    jc     error.a20
    sti
    hlt
    jmp    0x0000:0x7c00   ;load VBR code from FAT32 partition

error:
.a20:
    mov    si, a20err
    jmp    .L0
.part:
    mov    si, parterr
    jmp    .L0
.disk:
    mov    si, diskerr
.L0:
    mov    ah, 0xe
.L1:
    lodsb
    test   al, al
    jz     .L2
    int    0x10
    jmp    .L1
.L2:
    cli
    hlt

%include "a20.asm"
%include "disk.asm"

drive   db 0x0
a20err  db "Failed to enable A20 line", 0x0
parterr db "No active partition found", 0x0
diskerr db "Failed to read boot disk", 0x0

section .partition_table start=0x1b4 vstart=0x7b4
volume_uuid times 10 db 0x0
partition1  times 16 db 0x0
partition2  times 16 db 0x0
partition3  times 16 db 0x0
partition4  times 16 db 0x0

section .mbr_signature start=0x1fe vstart=0x7fe
dw 0xaa55
