[org 0x7c00]

section .text
    global _start

_start:
    xor    ax, ax
    mov    ds, ax
    mov    es, ax

    mov    bp, 0x7c00
    mov    sp, bp

    mov    si, msg
    call   s_print
_end:
    jmp    $

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

msg  db "Hello World!", 0x0
times  510 - ($ - $$) db 0x0
dw  0xaa55
