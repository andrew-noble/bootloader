bits 16
org 0x7c00

boot:
    mov ax, 0x2401 ; put 0x2401 into the ax register
    int 0x15 ; enable A20 bit to allow access to more than 1mb of memory (typically not the case in real mode)

    mov ax, 0x3
    int 0x10 ; set vga text mode 3

    lgdt [gdt_pointer] ; load the gdt table
    mov eax, cr0 
    or eax,0x1 ; set the protected mode bit on special CPU reg cr0
    mov cr0, eax
    jmp CODE_SEG:boot2 ; long jump to the code segment, now that we're in protected mode


; this is defining a global descriptor table, which informs the CPU how each
; segment of memory can be interacted with when in protected mode. This is
; what makes protected mode protected

gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF ; limit low
    dw 0x0 ; base low
    db 0x0 ; base middle
    db 10011010b ; access layout
    db 11001111b ; flags layout
    db 0x0 ; limit high
gdt_data:
    dw 0xFFFF ;same structure as above
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start
    CODE_SEG equ gdt_code - gdt_start
    DATA_SEG equ gdt_data - gdt_start

; now we should be in 32-bit protected mode

bits 32 ; tells nasm to output 32 bit now
boot2:
    mov ax, DATA_SEG ; this loads the data segment of the gdt into each x86 segment reg
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

; now lets hello world in 32-bit protected mode

    mov esi,hello ;source index register, used to store a pointer to a string
    mov ebx,0xb8000 ; base register, this is addr where the VGA text buffer is mapped to
.loop:
    lodsb ;loads a byte from a string in ESI into the al register
    or al,al
    jz halt
    or eax,0x0100 ; this colors each character blue
    mov word [ebx], ax ; send whatever is in ax (lower 16 bits of eax) to the VGA text buffer
    add ebx,2 ; increment ebx to point to the next character position in VGA buffer
    jmp .loop
halt:
    cli
    hlt
hello: db "Hello world!",0

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!

;note: EAX is the extended accumulator address, its 32 bits. AX is the lower 16 bits of this.

; boot1.asm uses 16 bit real mode
; much of this file is setting up 32-bit protected mode which
; is "normal" operation of the system and has guardrails to protect the low-levels
