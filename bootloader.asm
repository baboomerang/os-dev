bits 16
org 0x7c00

section .text
    global _start

_start:
    jmp    0000:.start    ;set cs to 0x0000
.start:
    xor    ax, ax
    mov    ds, ax
    mov    es, ax
    mov    ss, ax
    mov    fs, ax
    mov    gs, ax
    mov    bp, 0x7c00
    mov    sp, bp

    mov    si, msg
    call   s_print

_enable_a20:
    call   a20_enable
    call   check_a20

_protected_mode:
    cli
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


_end:
    hlt
    jmp    _end


%include "print.asm"
%include "a20.asm"
%include "gdt.asm"

msg    db "Hello Real Mode!", 0xa, 0xd, 0x0
times  510 - ($ - $$) db 0x0
dw  0xaa55
