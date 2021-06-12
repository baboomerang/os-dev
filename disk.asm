bits 16
;---------------------------------------------------------------------------
;  read_disk(uint8_t disk, uint8_t index, uint8_t sectors, uint16_t* buffer)
;  AL - disk - identifier for boot drive
;  BH - index - location of the first sector
;  BL - sectors - number of sectors to read
;---------------------------------------------------------------------------
read_disk:
    mov    ah, 0x02
    mov    dl, al     ;0x80 if harddrive, 0x00 if floppy disk
    mov    ch, 0      ;cylinder
    mov    dh, 0      ;head
    mov    al, bl     ;number of total sectors to read - must be 1 or greater
    mov    cl, bh     ;1st sector is 0x1 (MBR), 2nd sector is 0x2 (stage2), etc...
    int    0x13
    ret
