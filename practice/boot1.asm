bits 16 ; tell NASM this is 16 bit code
org 0x7c00 ; tell NASM to start outputting stuff at offset 0x7c00
boot:
    mov si,hello ; point si register to hello label memory location
    mov ah,0x0e ; 0x0e means 'Write Character in TTY mode'
.loop:
    lodsb
    or al,al ; is al == 0 ?
    jz halt  ; if (al == 0) jump to halt label
    int 0x10 ; runs BIOS interrupt 0x10 - Video Services
    jmp .loop
halt:
    cli ; clear interrupt flag
    hlt ; halt execution
hello: db "Hello world!",0

times 510 - ($-$$) db 0 ; pad whats remaining of the 510 bytes with zeroes
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!

;this is a bootloader itself, that displays Hello, World! FYI this is x86 assembly
