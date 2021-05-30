bits 16
;------------------------
;  s_print(char* string)
;  DS:(E)SI - char*
;  Returns: void
;  Clobbers: AL, BX
;------------------------
s_print:
    pusha
    pushf
    xor    bx, bx
    mov    ah, 0xe
.L1:
    lodsb
    test   al, al
    jz     .L2
    int    0x10
    jmp    .L1
.L2:
    popf
    popa
    ret
