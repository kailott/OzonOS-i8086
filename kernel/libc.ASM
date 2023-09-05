format ELF
include 'proc32.inc'
public k_print
public k_putc
public get_lfb_address
public get_available_memory
section ".text" executable


proc k_print c Str
push edi
mov edi,[Str]
mov ah,0x1
int 0x30
pop edi
ret
endp

proc k_putc c chr
xor ah,ah
mov al, byte [chr]
int 0x30
ret
endp

proc get_lfb_address
mov ah,0x3
int 0x30
ret
endp

proc get_available_memory
mov ah,0x40
int 0x30
ret
endp