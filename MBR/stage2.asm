bits 16
section .vbr start=0x0000 vstart=0x7c00
_FAT32_BPB:
    Jump                 db 0x0, 0x0, 0x0
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
.prepare_pm:
    xor    ax, ax
    xor    di, di
    mov    ds, ax
    mov    es, ax
    mov    cx, 1024
    rep    stosw                   ;zero 2048 bytes at es:di for the idt
    lidt   [idt_descriptor]
    lgdt   [gdt_descriptor]
    mov    eax, cr0
    or     eax, 0x1
    mov    cr0, eax
    jmp    gdt_codeseg:.protected_mode
bits 32
.protected_mode:
    nop
    nop
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    mov    ebp, 0x9fc00
    mov    esp, ebp
.detect_lm:
    mov    eax, 0x80000000
    cpuid
    test   eax, 0x80000001
    jne    error.cpuid
    mov    eax, 0x80000001
    cpuid
    test   edx, 1 << 29
    jz     error.long
.prepare_lm:
    mov    bx, word [gdt_codeseg + 6]
    mov    dx, word [gdt_dataseg + 6]
    xor    bh, 00001111b           ;zero limit register in gdt
    xor    dh, 00001111b           ;zero limit register in gdt
    xor    eax, eax
    mov    edi, [gdt]
    mov    ecx, 6                  ;6 dwords * 4 bytes = 24 bytes
    rep    stosd                   ;zero the entire 32 bit gdt
    mov    word [gdt_codeseg + 6], bx
    mov    word [gdt_dataseg + 6], dx
    lgdt   [gdt_descriptor]
    jmp    gdt_codeseg:.long_mode
bits 64
.long_mode:
    nop
    nop
    mov    ax, gdt_dataseg
    mov    ds, ax
    mov    ss, ax
    mov    es, ax
    mov    fs, ax
    mov    gs, ax
    hlt

error:
.cpuid:
    mov    esi, cpuiderr
    jmp    print32
.long:
    mov    esi, longerr
    jmp    print32

print32:
    hlt

%include "gdt.asm"

cpuiderr db "CPUID is not supported, cannot use 64 bit mode", 0x0
longerr  db "CPU does not support 64 bit mode, cannot continue", 0x0

section .vbr_signature start=0x1fe vstart=0x7dfe
dw 0xaa55
