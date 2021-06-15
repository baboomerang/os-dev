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
    cli
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
.detect_a20:
    call   set_a20
    call   check_a20
    jc     error.a20
.read_parts:
    sti
    mov    cl, 4
    mov    bx, partition1
.find_active:
    mov    al, byte [bx]
    test   al, 0x80
    je     .found
    add    bx, 0x10
    dec    cl
    jnz    .find_active
    jmp    error.part
.found:
    add    bx, 8           ;bx points to LBA of the first sector of the partition
    push   bx
.fast_method:
    mov    dl, byte [drive]
    mov    al, 0x41
    mov    bx, 0x55aa
    int    0x13
    jc     .slow_method
    inc    al
    mov    si, dap_packet  ;redundant acronym, i know...
    int    0x13
    jnc    _end
.slow_method:
    pop    bx
    call   lba_chs
    mov    bx, 0x7c00
.retry:
    mov    ah, 0x2
    int    0x13
    jnc    _end
    xor    ah, ah
    int    0x13
    jnz    .retry
    jmp    error.disk
_end:
    jmp    0x0000:0x7c00


error:
.a20:
    mov    si, a20err
    jmp    print
.part:
    mov    si, parterr
    jmp    print
.disk:
    mov    si, diskerr


print:
    mov    ah, 0xe
.loop:
    lodsb
    test   al, al
    jz     .end
    int    0x10
    jmp    .loop
.end:
    hlt

%include "a20.asm"
%include "disk.asm"

drive   db 0x0
dap_packet:
;TODO - Fill DAP Packet contents
a20err  db "Failed to enable A20 line", 0x0
parterr db "Invalid partition table", 0x0
diskerr db "Failed to read disk sectors", 0x0

section .partition_table start=0x1b4 vstart=0x7b4
volume_uuid times 10 db 0x0
partition1  times 16 db 0x0
partition2  times 16 db 0x0
partition3  times 16 db 0x0
partition4  times 16 db 0x0

section .mbr_signature start=0x1fe vstart=0x7fe
dw 0xaa55
