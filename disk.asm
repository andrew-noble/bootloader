;this procedure/function is called by the bootloader to load kernel from the disk into RAM via 0x13 BIOS interrupt

disk_load:
    pusha ;pushes all general use registers ax, bx, cx, dx onto the stack
    push dx

    ;setting up registers for the 0x13 BIOS interrupt call
    mov ah, 0x02 ; read mode
    mov al, dh   ; read dh number of sectors
    mov cl, 0x02 ; start from sector 2
                 ; (as sector 1 is our boot sector)
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0

    ; dl = drive number is set as input to disk_load
    ; es:bx = buffer pointer is set as input as well. This is where in RAM the above specified disk sector goes

    int 0x13      ; BIOS interrupt -- this is what actually loads kernel into memory
    jc disk_error ; check carry bit for error

    pop dx     ; restore the # of sectors to read that was set by caller
    cmp al, dh ; BIOS sets 'al' to the # of sectors actually read
               ; compare it to expected, 'dh', and error out if they are !=
    jne sectors_error
    popa
    ret

disk_error:
    jmp disk_loop

sectors_error:
    jmp disk_loop

disk_loop:
    jmp $