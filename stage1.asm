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
    mov    bh, 01101111b
    xor    cx, cx          ;ch,cl = row,column of window's upper left corner
    mov    dh, 0x19        ;0x19 = 25 rows
    mov    dl, 0x50        ;0x50 = 80 columns
    int    0x10
.detect_a20:
    cli
    call   set_a20
    call   check_a20
    jc     error.a20
.detect_partition:
    mov    cl, 4
    mov    di, partition1
.retry:
    cmp    byte [di], 0x80 ;active flag
    je     .found
    add    di, 0x10
    dec    cl
    jnz    .retry
    jmp    error.part
.found:
    mov    dl, byte [drive]
_read_drive:
    sti
    mov    ah, 0x41        ;installation check
    mov    bx, 0x55aa
    int    0x13
    jc     .slow_read
    mov    ah, 0x42        ;extended read sectors from drive
    mov    si, dap
    mov    ebx, dword [di + 8]
    mov    dword [dap.transfer], 0x00007c00
    mov    dword [dap.startlba], ebx
    int    0x13
    jnc    _end
.slow_read:
    mov    dh, byte [di + 1] ;head
    mov    cl, byte [di + 2] ;sector
    mov    ch, byte [di + 3] ;track - cylinder
    mov    bx, 0x7c00
    mov    si, 5           ;retry 5 times
.retry:
    mov    ax, 0x201       ;ah=0x2/al=0x1 - read 1 sector(s) from disk
    int    0x13
    jnc    _end
    xor    ah, ah          ;reset disk system
    int    0x13
    dec    si
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


dap:
.size     db 0x10 ;size of packet (10h or 18h)
.reserved db 0x00 ;reserved (0)
.blocks   dw 0x01 ;number of blocks to transfer (max 007Fh for Phoenix EDD)
.transfer dd 0x00 ;-> transfer buffer
.startlba dq 0x00 ;starting absolute block number

drive   db 0x0
a20err  db "Failed to enable A20 line", 0x0
parterr db "Invalid partition table", 0x0
diskerr db "Failed to read disk sectors", 0x0

section .partition_table start=0x1b4 vstart=0x7b4
volume_uuid times 10 db 0x2 ;dummy values so you and others can study the hexdump
partition1  times 16 db 0x3 ;"
partition2  times 16 db 0x4 ;"
partition3  times 16 db 0x5 ;"
partition4  times 16 db 0x6 ;"

section .mbr_signature start=0x1fe vstart=0x7fe
dw 0xaa55
