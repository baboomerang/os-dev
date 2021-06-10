bits 16
section .mbr start=0x0000 vstart=0x7c00
_mbr_start:
    jmp    0x0000:.start
.start:
    cli
    cld
    xor    ax, ax
    mov    ds, ax
    mov    es, ax
    mov    ss, ax
    mov    fs, ax
    mov    gs, ax
    mov    bp, 0x7c00
    mov    sp, bp
    mov    byte [drive], dl
    mov    si, 0x7c00
    mov    di, 0x0600
    mov    cx, 0x0100      ;256 words, 512 bytes
    rep    movsw
    jmp    0x0600 + .relocate - $$
.relocate:
    xor    ah, ah          ;set video mode
    mov    al, 0x03        ;720x400p, 80 columns * 25 rows in 16 bit colors
    int    0x10
    mov    ah, 0x07        ;scroll down window
    xor    al, al          ;clear all rows
    mov    bh, 01001111b
    xor    cx, cx          ;ch,cl = row,column of window's upper left corner
    mov    dh, 0x19        ;0x19 = 25 rows
    mov    dl, 0x50        ;0x50 = 80 columns
    int    0x10
.a20:
    call   set_a20
    call   check_a20
    jc     _a20err
.stage2:
    mov    al, byte [drive]
    mov    bh, 2           ;start at sector 2
    mov    bl, 1           ;read only one sector
    call   read_disk
    jc     _diskerr
.prepare_pm:
    xor    ax, ax
    mov    ds, ax
    lgdt   [gdt_descriptor]
    mov    eax, cr0
    or     eax, 0x1
    mov    cr0, eax
    jmp    gdt_codeseg:.protected_mode
bits 32
.protected_mode:
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    ebp, 0x9fc00
    mov    esp, ebp


_a20err:
    mov    si, a20msg
    jmp    _print
_diskerr:
    mov    si, diskmsg
_print:
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

drive   db 0x0
a20msg  db "HALT: A20 Line is not enabled", 0x0
diskmsg db "HALT: Failed to read boot disk", 0x0

%include "gdt.asm"
%include "a20.asm"
%include "disk.asm"

section .mbr_signature start=0x01fe vstart=0x7dfe
dw 0xaa55

%include "stage2.asm"
