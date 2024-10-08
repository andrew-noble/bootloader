; global descriptor table

; null segment descriptor
gdt_start:
    dq 0x0

; code segment descriptor. How opcodes/operations are accessed in protected mode
gdt_code:
    dw 0xFFFF
    dw 0x0 
    db 0x0
    db 10011010b 
    db 11001111b 
    db 0x0

; data segment. This specifies how segments of data may be accessed in protected mode
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

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start