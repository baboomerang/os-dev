bits 16
;-----------------
;  a20_enable()
;  Returns: void
;  Clobbers: void
;-----------------
a20_enable:
    pusha
    pushf
    mov    ax, 0x2403       ;SYSTEM - later PS/2s - QUERY A20 GATE SUPPORT
    int    0x15
    jc     .no_bios_support
    test   ah, ah
    jnz    .no_bios_support
    test   bx, 00000010b    ;set a20 gate with bit 1 of I/O port 92h
    je     .fast_a20
    mov    ax, 0x2402       ;SYSTEM - later PS/2s - GET A20 GATE STATUS
    int    0x15
    jc     .no_bios_support
    test   ah, ah
    jnz    .no_bios_support
    test   al, 00000001b    ;AL = current state (00h disabled, 01h enabled)
    jz     .L3
    mov    ax, 0x2401       ;SYSTEM - later PS/2s - ENABLE A20 GATE
    int    0x15
    jc     .no_bios_support
    test   ah, ah
    jz     .L3
.fast_a20:
    in     al, 0x92
    test   al, 00000010b
    je     .L3
    or     al, 00000010b
    out    0x92, al
    jmp    .L3
.no_bios_support:
    mov    ax, 0x1
.L3:
    popf
    popa
    ret

;--------------------------
;  check_a20()
;  Returns: void
;  Clobbers: ES, DI, SI, AX
;--------------------------
check_a20:
    mov    ax, 0xffff
    mov    es, ax
    mov    di, 0x7e0e
    cmp    word [es:di], 0xaa55
    xor    ax, ax
    sete   al
    ret

bioserr db "Error, BIOS does not support changing a20 gate", 0xa, 0xd, 0x0
a20err  db "Error, A20 line is not enabled!", 0xa, 0xd, 0x0
a20set  db "Success, A20 line is enabled!", 0xa, 0xd, 0x0
