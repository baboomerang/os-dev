section .data
    msg    db "Hello World!", 0x0
    len    equ $ - msg

section .text
    global _start

_start:
    xor    ax, ax
    mov    ah, 0x0e

    lea    si, [msg]
.print:
    lodsb
    jz .end
    int 0x10
    jmp .print
.end:

    jmp    $
    times  510 - ($ - $$) db 0



dw  0xaa55
