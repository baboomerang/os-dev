bits 16
;---------------------------------------------
;  set_a20()
;  Use multiple methods to enable the a20 line
;  Returns: void
;  Clobbers: void
;---------------------------------------------
set_a20:
    pusha
    pushf
    mov    ax, 0x2403     ;SYSTEM - later PS/2s - QUERY A20 GATE SUPPORT
    int    0x15
    jc     .not_supported
    test   ah, ah
    jnz    .slow_a20
    test   bx, 00000010b  ;set a20 gate with bit 1 of I/O port 92h (fast a20)
    je     .fast_a20
    mov    ax, 0x2402     ;SYSTEM - later PS/2s - GET A20 GATE STATUS
    int    0x15
    jc     .not_supported
    test   ah, ah
    jnz    .slow_a20
    test   al, 00000001b  ;AL = current state (00h disabled, 01h enabled)
    je     .end
    mov    ax, 0x2401     ;SYSTEM - later PS/2s - ENABLE A20 GATE
    int    0x15
    jc     .not_supported
    test   ah, ah
    jz     .end
.fast_a20:
    in     al, 0x92
    test   al, 00000010b
    je     .end
    or     al, 00000010b
    out    0x92, al
    jmp    .end
.not_supported:                  ;BIOS is too old, assume ancient (pre-2004 bios)
.slow_a20:
    call   wait_keyboard_command ;wait until 8042 controller is ready to recieve data
    mov    al, 0xad              ;0xad - Disable first PS/2 port
    out    0x64, al
    call   wait_keyboard_command
    mov    al, 0xd0              ;0xd0 - Read Controller Output Port
    out    0x64, al
    call   wait_keyboard_data    ;wait until 8042 controller is ready to send data
    in     al, 0x60              ;read from read/write data port
    mov    dx, ax                ;backup PS/2 Controller Configuration Byte
    call   wait_keyboard_command
    mov    al, 0xd1              ;0xd1 - Write next byte to Controller Output Port
    out    0x64, al
    call   wait_keyboard_command
    mov    ax, dx
    or     al, 00000010b         ;Set A20 Gate (output)
    out    0x60, al              ;write to the read/write data port
    call   wait_keyboard_command
    mov    al, 0xae              ;0xae - Enable first PS/2 port
    out    0x64, al
    call   wait_keyboard_command
    mov    al, 0xff              ;Reset the device on the first PS/2 port
    out    0x64, al
.end:
    popf
    popa
    ret
;----------------------------------------------------
;  wait_keyboard()
;  These are helper functions for the slow a20 method
;  Returns: void
;  Clobbers: AL
;----------------------------------------------------
wait_keyboard_data:
    in     al, 0x64
    test   al, 00000001b
    je     wait_keyboard_data
    ret
wait_keyboard_command:
    in     al, 0x64
    test   al, 00000010b
    je     wait_keyboard_command
    ret
;--------------------------
;  check_a20()
;  Returns: void
;  Clobbers: DI, AX
;--------------------------
check_a20:
    mov    ax, 0xffff
    mov    es, ax
    mov    di, 0x7e0e
    cmp    word [es:di], 0xaa55
    clc
    jne    .L1
    stc
.L1:
    ret
