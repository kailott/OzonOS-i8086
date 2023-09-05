use32
DEFINE FDD_BUFF blk_buffer+ 0x40000
org 0x40000 + $
mov ax,0x10
mov ds,ax
mov es,ax
mov fs,ax
mov gs,ax
mov ss,ax
mov eax, 0x40000
mov esp,eax
mov eax,dword [blk_buffer + 0x200 +028h + 0x40000]
mov [VESA_LFB],eax

mov edi,eax



mov edi,info_msg_3
call vesa32.vesa_print
;mov edi,info_msg_4
;call vesa32.vesa_print
;mov edi,info_msg_5
;call vesa32.vesa_print



lidt fword  [IDTR]



        ; ?????????????? ??????????? ??????????
       mov  bx, 2820h
        
        mov     al, 00010001b
        
        out     020h, al
        out     0A0h, al
        mov     al, bl
        out     021h, al
        mov     al, bh
        out     0A1h, al
        mov     al, 00000100b
        out     021h, al
        mov     al, 2
        out     0A1h, al
        mov     al, 00000001b
        out     021h, al
        out     0A1h, al


        ; ????????? ?????????? ?????????? ? NMI
                in   al, 70h
                and  al, 7Fh
                out  70h, al
                sti
mov edi,info_msg_4
mov ah,0x1
int 0x30
;call vesa32.vesa_print
call memtest
mov [MEM_SIZE],eax

call RAMDRIVE.init
mov esi,kenrel_name
mov edi,0x400000
call RAMDRIVE.readfile


call 0x8:0x400000

jmp $

memtest:
mov eax, 0x400000
@@:
mov ebx,[eax]
mov [eax],dword 0xFAFAFAFA
cmp [eax],dword 0xFAFAFAFA
jne @f
mov [eax],ebx
add eax,4
jmp @b
@@:
call print_memsize
mov [MEM_SIZE],eax
ret




print_memsize:
push eax
push ecx
push edx
push ebx
mov ecx,32
 mov ebx,0
 mov edx,75
@@:
sub ecx,4
push eax
ror eax,cl
call print_hex
pop eax
inc ebx
test ecx,ecx
jnz @b
pop ebx
pop edx
pop ecx
pop eax
ret


print_hex:
push eax
push ecx
and eax,0xf
push ebx
mov ebx,hex_ascii
xlatb
pop ebx
call vesa32.custom_put_char
pop ecx
pop eax
ret


hex_ascii db '0123456789ABCDEF',0






 scan2ascii     db    0,1Bh,'1','2','3','4','5','6','7','8','9','0','-','=',8


MEM_SIZE dd 0x0
kenrel_name db 'KERNEL  BIN'

info_msg_3 db 'Wake up, Neo...',0xa,0xd, 0
info_msg_4 db 'The Matrix has you...',0xa,0xd,0
info_msg_5 db 'Follow the white rabbit.',0xa,0xd,0
include 'vesa32.asm'
include 'pic.inc'
include 'ramdrive.inc'
;include 'flp_drv.inc'
use16
org $ - 0x40000