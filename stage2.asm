section .stage2 start=0x0200 vstart=0x7e00
_stage2:
.a20:
    call   set_a20
    call   check_a20
    jnc    _protected_mode
    lea    si, [a20err]
    call   s_print
    hlt

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
    hlt

msg32 db "Hello Protected Mode!", 0x0
%include "a20.asm"
%include "gdt.asm"
