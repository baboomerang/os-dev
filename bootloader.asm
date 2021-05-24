[org 0x7c00]

section .text
    global _start

_start:
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

    cli

_enable_a20:
    call a20_enable

_end:
    hlt
    jmp    _end

a20_enable:
    pushad
    pushfd
    mov    ax, 0x2403
    int    0x15
    jc     .no_bios_support
    test   bx, 00000010b
    jne    .slow_a20
    mov    ax, 0x2402
    int    0x15
    jc     .no_bios_support
    test   al, 00000001b
    je     .L5
    mov    ax, 0x2401
    int    0x15
    test   al, 00000001b
    je     .L5
.fast_a20:
    in     al, 0x92
    or     al, 2
    out    0x92, al
    call   check_a20
    test   al, 00000001b
    je     .L5
.no_bios_support:
.slow_a20:
    ;TODO - insert keyboard method here
    call   check_a20
    test   al, 00000001b
    je     .L5
.err:
    mov    si, a20err
    call   s_print
.L5:
    popfd
    popad
    ret

check_a20:
    pushad
    ;TODO - check if a20 is actually enabled
    popad
    ret

;------------------------
;  s_print(char* string)
;  DS:(E)SI - char*
;  Returns: void
;  Clobbers: AH, AL
;------------------------
s_print:
    xor    bx, bx
    mov    ah, 0xe
.L1:
    lodsb
    test   al, al
    jz     .L2
    int    0x10
    jmp    .L1
.L2:
    ret

msg    db "Hello World!", 0x0
a20err db "Error, cannot enable A20 line!", 0x0
times  510 - ($ - $$) db 0x0
dw  0xaa55
