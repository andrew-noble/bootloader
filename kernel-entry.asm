bits 32 ;nasm
extern main ; nasm directive to load main from kernel.c
call main
jmp $