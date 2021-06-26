gdt_descriptor:
    dw gdt.end - gdt - 1    ;size (2 bytes)
    dd gdt                  ;offset (4 bytes)

align 8                     ;intel recommended for 32bit and 64bit systems

gdt:                        ;global-descriptor-table
.null:                      ;intel reserved, mandatory 16 null bytes (64 bits)
    dq 0x0
.code:                      ;code segment
    dw 0xffff               ;limit address, bit 0 to 15 - 0xffff
    dw 0x0000               ;base address, bit 0 to 15 - 0x0000
    db 0x00                 ;base address, bit 16 to 23 - 0x00
    db 10011010b            ;0x9a - access byte (exec/read)
    db 11001111b            ;0xcf - 0xc0 (flags) and 0x0f (limit address bit 16-19)
    db 0x00                 ;base address, bit 24 to 31 - 0x00
.data:                      ;data segment
    dw 0xffbb               ;limit address, bit 0 to 15 - 0xffff
    dw 0x0000               ;base address, bit 0 to 15 - 0x0000
    db 0x00                 ;base address, bit 16 to 23 - 0x00
    db 10010010b            ;0x92 - access byte (read/write)
    db 11001111b            ;0xcf - 0xc0 (flags) and 0x0f (limit address bit 16-19)
    db 0x00                 ;base address, bit 24 to 31 - 0x00
.end:

gdt_codeseg equ gdt.code - gdt
gdt_dataseg equ gdt.data - gdt

idt_descriptor:
    dw 0x800                ;2048 bytes
    dd 0x00000000           ;linear address of IDT (DS:SI)
