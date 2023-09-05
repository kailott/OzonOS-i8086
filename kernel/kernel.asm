format ELF
include 'proc32.inc'
public _start
extrn main

section ".text" executable

_start:

        call main
@@:
        ;cli
        ;hlt
        jmp @b

section ".data" writable

gdt:
        dq 0                 
        dq 0x00CF9A000000FFFF
        dq 0x00CF92000000FFFF
gdtr:
        dw $ - gdt
        dd gdt
