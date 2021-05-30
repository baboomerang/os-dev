bits 16
org 0x7c00

section .text
    global _start

_start:
    jmp    0x0000:.start    ;set cs to 0x0000
.start:
    cli
    cld
    xor    ax, ax
    mov    ds, ax
    mov    es, ax
    mov    ss, ax
    mov    fs, ax
    mov    gs, ax
    mov    bp, 0x7c00       ;stack: 0x7c00 to 0x500
    mov    sp, bp

    mov    si, msg
    call   s_print

_a20:
    call   set_a20
    call   check_a20


_protected_mode:
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
    mov    ebp, 0x9fc00     ;stack: 0x9fc00 to 0x7e00 (assuming 1 boot sector max)
    mov    esp, ebp

    mov    esi, msg32
    call   s_print32

_long_mode:
    lgdt   [gdt_descriptor]
    jmp    gdt_codeseg:.long_mode

bits 64
.long_mode:
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax

_end:
    hlt
    jmp    _end


%include "print.asm"
%include "a20.asm"
%include "gdt.asm"

msg    db "Hello Real Mode!", 0xa, 0xd, 0x0
msg32  db "Hello Protected Mode!", 0xa, 0xd, 0x0
times  510 - ($ - $$) db 0x0
dw  0xaa55
