bits 16
;------------------------------
;  r_print(uint16_t register)
;  Recieves: SI - 16 bit int
;  Returns: void
;  Clobbers: AX, BX, CX, DX, SI
;------------------------------
r_print:
    pusha
    pushf
    mov    bx, si
    mov    ah, 0xe
    mov    cx, 4              ;4 nibbles * 4 bits = 16 bit register (word)
.L1:
    rol    bx, 4              ;start with the most significant byte in BL
    movzx  si, bl
    and    si, 0xf            ;get the lower nibble
    mov    al, byte [hex + si];convert int hex to char hex
    int    0x10
    dec    cx
    jnz    .L1
    popf
    popa
    ret

hex db "0123456789abcdef"

;------------------------
;  s_print(char* string)
;  DS:(E)SI - char*
;  Returns: void
;  Clobbers: AL, BX
;------------------------
s_print:
    pusha
    pushf
    mov    ah, 0xe
.L1:
    lodsb
    test   al, al    ;check if null-terminator
    jz     .L2
    int    0x10
    jmp    .L1
.L2:
    popf
    popa
    ret
