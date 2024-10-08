bits 16
org 0x7c00

boot:
    mov ax, 0x2401 
    int 0x15 

    mov ax, 0x3
    int 0x10 ; set vga text mode 3

    mov [disk], dl

    ;this is the novel bit of code. It enables us to use more than 512 mB
    ;this register setup and subsequent int 0x13 disk services call makes more disk space available. 
    mov ah, 0x2    ;read sectors
	mov al, 1      ;sectors to read
	mov ch, 0      ;cylinder idx
	mov dh, 0      ;head idx
	mov cl, 2      ;sector idx
	mov dl, [disk] ;disk idx
	mov bx, copy_target;target pointer
	int 0x13
	cli

    ;go into 32-bit protected mode
    lgdt [gdt_pointer] ; load the gdt table
    mov eax, cr0 
    or eax,0x1 ; set the protected mode bit on special CPU reg cr0
    mov cr0, eax
    mov ax, DATA_SEG ;load the data into the segment registers
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
    jmp CODE_SEG:boot2 


;global descriptor table
gdt_start:
    dq 0x0
gdt_code:
    dw 0xFFFF
    dw 0x0 
    db 0x0
    db 10011010b 
    db 11001111b 
    db 0x0 
gdt_data:
    dw 0xFFFF 
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start
    dd gdt_start

disk:
    db 0x0

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

times 510 - ($-$$) db 0 
dw 0xaa55 

copy_target:
bits 32 
    hello: db "Hello more than 512 bytes world!!",0
boot2:
	mov esi,hello
	mov ebx,0xb8000
.loop:
	lodsb
	or al,al
	jz halt
	or eax,0x0F00
	mov word [ebx], ax
	add ebx,2
	jmp .loop
halt:
	cli
	hlt

times 1024 - ($-$$) db 0 ;this pads the remaining 1024 bits so we don't hit restricted memory

;what the above code does is it gets us into 32-bit protected mode while 


