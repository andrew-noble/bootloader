bits 16 ;nasm directive (as opposed to an asm operation) to output 16-bit operations
org 0x7c00

KERNEL_OFFSET equ 0x1000 ; specify where we'll load kernel to later

mov [BOOT_DRIVE], dl ; BIOS implicity loads boot drive in dl; lets store for later use

; setup stack
mov bp, 0x9000
mov sp, bp

call load_kernel
call switch_to_32bit

jmp $ ;this is an infinite loop

; nasm external linking
%include "disk.asm"
%include "gdt.asm"
%include "switch-to-32bit.asm"

bits 16
load_kernel:
    ;these 3 are effectively arguments to the disk_load funciton. You use registers to do this in asm
    mov bx, KERNEL_OFFSET ; bx -> destination
    mov dh, 2             ; dh -> number of sectors
    mov dl, [BOOT_DRIVE]  ; dl -> disk

    call disk_load
    ret

bits 32
BEGIN_32BIT:
    call KERNEL_OFFSET ; give control to the kernel
    jmp $ ; loop in case kernel returns

; clear boot drive variable
BOOT_DRIVE db 0

; padding to make it a valid boot record
times 510 - ($-$$) db 0

; magic number that signifies this section as bootable to BIOS
dw 0xaa55