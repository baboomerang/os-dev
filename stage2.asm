section .stage2 start=0x0200 vstart=0x7e00
_stage2:

    ;TODO - Setup paging
    ;Detect CPUID
    ;Detect Long Mode Support
    ;Print CPU Information
    ;Scan Partitions on the current drive
    ;Prompt User and boot chosen partition
    ;jmp to kernel

_long_mode:
    lgdt   [gdt_descriptor]
    jmp    gdt_codeseg:.long_mode

bits 64
.long_mode:
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    hlt
