bits 16

section .mbr start=0x0000 vstart=0x7c00
    global _start
_start:
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

    call   set_a20
    call   check_a20
    jnc    .a20_enabled
    mov    si, a20err
    call   s_print
    hlt

.a20_enabled:


_end:
    hlt
    jmp    _end

bootdrive db 0x0
a20err    db "HALT: A20 line is not enabled!", 0x0

%include "a20.asm"
%include "disk.asm"
%include "print.asm"

section .mbr_signature start=0x01fe vstart=0x7dfe
dw 0xaa55

%include "stage2.asm"
