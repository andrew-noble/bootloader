bits 16 ;tells nasm to output 16 bit commands
switch_to_32bit:
    cli                     ; 1. disable interrupts
    lgdt [gdt_pointer]   ; 2. load GDT descriptor
    mov eax, cr0
    or eax, 0x1             ; 3. enable protected mode
    mov cr0, eax
    jmp CODE_SEG:init_32bit ; 4. far jump

bits 32 ;tells nasm to go 32-bit
init_32bit:
    mov ax, DATA_SEG        ; 5. update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; 6. setup extended 32-bit stack
    mov esp, ebp

    call BEGIN_32BIT        ; 7. move back to mbr.asm