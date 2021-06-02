bits 16
;---------------------------------------------------------
;  read_disk(uint8_t disk, uint8_t index, uint8_t sectors)
;  AL - disk - identifier for boot drive
;  BH - index - location of the first sector
;  BL - sectors - number of sectors to read
;---------------------------------------------------------
read_disk:
    pusha
    mov    ah, 0x02
    mov    dl, al     ;0x80 if harddrive, 0x00 if floppy disk
    mov    ch, 0      ;cylinder
    mov    dh, 0      ;head
    mov    al, bl     ;number of total sectors to read
    mov    cl, bh     ;1st sector is 0x1 (MBR), 2nd sector is 0x2 (stage2), etc...
    int    0x13
    jc     read_err
    test   ah, ah     ;test if read had any errors
    jnz    read_err2
    popa
    ret

read_err:
    mov    si, diskerr
    call   s_print
    hlt

read_err2:
    mov    si, secterr
    call   s_print
    movzx  bx, ah
    call   r_print
    hlt

diskerr    db "HALT: Failed to read boot disk", 0x0
secterr    db "HALT: Failed to read sectors, error status:", 0x0
