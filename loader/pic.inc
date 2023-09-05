  DEFINE CODE_SELEKTOR 8

 include 'struct.inc'
 include 'idt.inc'
 include 'syscalls.asm'

timer_ticks dd 0x0
irq0_handler:
push esi
mov esi,[VESA_LFB]
add esi, 2044
inc dword [esi]
inc [timer_ticks]
pop esi
jmp int_EOI

irq1_handler:
push ax
push edi
in al,0x60


@@:
in al,0x61
or al,0x80
out 0x61,al
pop edi
pop ax
jmp int_EOI

keyb_ptr dd keyb
keyb rb 8


irq6_handler:

jmp int_EOI



int_EOI:
    push ax
    mov  al, 20h
    out  020h, al  
    out  0a0h, al
    pop  ax
    iretd

exGP_handler:
    pop  eax ; ??? ??????
    iretd