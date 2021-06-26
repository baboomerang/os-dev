bits 16
section .vbr start=0x0000 vstart=0x7c00
_FAT32_BPB:
    jmp    _start
    nop
    OEMLabel             db "OSDEV123"
    BytesPerSector       dw 0x0
    SectorsPerCluster    db 0x0
    ReservedSectors      dw 0x0
    FATs                 db 0x0
    RootDirEntries       dw 0x0
    TotalSectors         dw 0x0
    MediaDescriptorType  db 0x0
    SectorsPerFAT12_16   dw 0x0
    SectorsPerTrack      dw 0x0
    HeadsPerCylinder     dw 0x0
    HiddenSectors        dd 0x0
    LargeSectors         dd 0x0
.EBPB:
    SectorsPerFAT32      dd 0x0
    Flags32              dw 0x0
    FATVersionNumber32   dw 0x0
    ClusterNumberRootDir dd 0x0
    SectorNumberFSInfo   dw 0x0
    BackupBootSector     dw 0x0
    reserved    times 12 db 0x0
    DriveNumber          db 0x0
    WindowsNTFlags       db 0x0
    Signature            db 0x0
    VolumeSerialNumber   db "1234567890"
    SystemIdentifier     db "FAT32   "
_start:
    cli
    xor    ax, ax
    xor    di, di
    mov    ds, ax
    mov    es, ax
    mov    cx, 1024
    rep    stosw            ;zero 2048 bytes at es:di for the idt
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
.detect_cpuid:
    pushfd
    pop    eax
    mov    ecx, eax
    xor    eax, 1 << 21
    push   eax
    popfd
    pushfd
    pop    eax
    push   ecx
    popfd
    xor    eax, ecx
    jz     error.cpuid
.detect_lm:
    mov    eax, 0x80000000
    cpuid
    cmp    eax, 0x80000001
    jb     error.long
    mov    eax, 0x80000001
    cpuid
    test   edx, 1 << 29
    jz     error.long
.prepare_lm:
    mov    eax, 10100000b
    mov    cr4, eax
    mov    edx, edi
    mov    cr3, edx
    mov    ecx, 0xC0000080
    rdmsr
    or     eax, 1 << 8
    wrmsr
    mov    eax, cr0
    or     eax, 1 << 31
    mov    cr0, eax
    xor    eax, eax
    mov    edi, [gdt]
    mov    ecx, 6
    rep    stosd
    mov    word [gdt.code + 6], 0x2f9a
    mov    word [gdt.data + 6], 0x0092
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


    mov    edi, 0xb8000
    mov    rcx, 500
    mov    rax, 0x1F201F201F201F20
    rep    stosq
halt:
    hlt
    jmp    halt

error:
.cpuid:
    mov    esi, cpuiderr
    jmp    print32
.long:
    mov    esi, longerr


bits 32
print32:
    mov    edi, 0xb8000
.loop:
    lodsb
    test   al, al
    jz     .end
    mov    byte [edi], al
    add    edi, 2
    jmp    .loop
.end:
    hlt


%include "gdt.asm"


cpuiderr db "HALT: CPUID is not supported", 0x0
longerr  db "HALT: CPU does not support 64 bit mode", 0x0

section .vbr_signature start=0x1fe vstart=0x7dfe
dw 0xaa55
