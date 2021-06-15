section .stage2 start=0x0000 vstart=0x7c00
    ;TODO - Setup paging
    ;Detect CPUID
    ;Detect Long Mode Support
    ;Print CPU Information
    ;Scan Partitions on the current drive
    ;Prompt User and boot chosen partition
    ;jmp to kernel


.prepare_pm:
    xor    ax, ax
    xor    di, di
    mov    ds, ax
    mov    es, ax
    mov    cx, 1024
    rep    stosw           ;zero 2048 bytes at es:di for the idt
    lidt   [idt_descriptor]
    lgdt   [gdt_descriptor]
    mov    eax, cr0
    or     eax, 0x1
    mov    cr0, eax
    jmp    gdt_codeseg:.protected_mode
bits 32
.protected_mode:
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    ebp, 0x9fc00
    mov    esp, ebp
    jmp    .err

.detect_lm:
    mov    eax, 0x80000000
    cpuid
    test   eax, 0x80000001
    jne    .err

.prepare_lm:
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

.err:
    hlt
    jmp    .err

%include "gdt.asm"
