bits 16

;----------------------------------------
; int 0x13, ah=0x2 - DISK READ
;     ch - cylinder
;     dh - head
;     cl - track (1 is the current MBR, 2 is 0x200-0x3FF, etc....)
;     al - length of sectors to read

lba_chs:
    xor    dx, dx



    ret

