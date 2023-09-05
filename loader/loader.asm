
org 0
start:
;Clear screen
mov ax,3
int 0x10
;Проверим загрузчик
cmp bx,"FD"
je @f
mov di,err_msg_1
call print
hlt
jmp $

@@:
;Print dbg message
mov di,info_msg_1
call print
;Теперь нам нужно загрузить tarbol выше 1МБ

;Сразу откроем A20
in al,0x92
or al,0x02
out 0x92,al
;Так же загрузим LGDT
xor             eax,eax
mov             ax,cs
shl             eax,4
add             ax, GDT
mov             dword [GDTR+2],eax
lgdt            fword [GDTR]
;Перейдем в нереальный режим
cli
mov eax,cr0
or al,1
mov cr0,eax
jmp $+2
mov bx,0x10
mov fs,bx
mov gs,bx
and al,0xFE
mov cr0,eax
sti


;Определяем первый кластер файла
mov di,tarboll_name
mov ah,0x2
int 0x25
mov [RAMDISK_SIZE],cx
;BX содержит номер первого кластера
;читаем и копируем кластеры
@@:
;Чтение
push bx
mov ah,01
add bx,1fh
mov al,02h
mov di,blk_buffer
int 0x25
pop bx
;копирование
call copy_block
mov ah,0x3
int 0x25
cmp bx,0xFFF
jne @b

mov di,info_msg_2
call print
;Теперь определяем параметры системы
xor eax,eax
mov di,blk_buffer
mov ecx,0x200
rep stosb
;Зададим хотимый видеорежим
mov di,blk_buffer
mov ah,0x4F
mov al,0
int 0x10
cmp dword [es:di],'VESA'
je @f

vesa_err:
mov di,err_msg_2
call print
hlt
jmp $
@@:
cmp bx,0200h
jl vesa_err
; Получаем информацию о режиме
mov ax,4F01h
mov cx,4117h
mov di,blk_buffer + 0x200
int 10h
; Записываем физический адрес начала LFB в ESI
mov esi,dword  [blk_buffer + 0x200 +028h]
push    esi
; Устанавливаем режим
mov ax,4F02h
mov bx,4117h
int 10h
pop esi
mov ecx,1024*768
mov edi,esi
mov ax,0x0
@@:
mov [gs:edi],ax
add edi,2
dec ecx
jnz @b



mov edi,dword  [blk_buffer + 0x200 +028h]
;mov [VESA_LFB_OFFS],edi


;mov di,info_msg_3
;call vesa_print
;mov di,info_msg_4
;call vesa_print
;mov di,info_msg_5
;call vesa_print



;xor eax,eax
;mov ax,cs
;;shl eax,4
;add [@f + 2],eax
;add [IDTR + 2],eax
;запретим прерывания
cli
in al,0x70
or al,0x80
out 0x70,al
;Переходим в защищенный режим
mov eax,cr0
or al,1
mov cr0,eax

@@:
                db              66h
                db              0EAh                    
ENTRY_OFF       dd              @f + 0x40000
                dw              0x8
@@:
include '32x.asm'


;Копирует блок данных из blk_buffer
copy_block:

push di
;DBG PRINT
mov al,'*'
mov ah,0eh
int 10h
;******

mov cx,0x200
mov si,blk_buffer
;mov edi,0x100000
xor esi,esi
xor eax,eax
mov ax,cs
shl eax,4
add eax,blk_buffer
mov esi,eax
@@:


mov al,byte [gs:esi]


db 0x65
db 0x67
db 0xa2
offs dd  0x100000

inc esi
inc [offs]
loop @b
pop di




ret




 data_block dd 0x100000



;вывод ASCIIZ строки
;ES:DI строка
print:
mov al,byte [es:di]
cmp al,0
je @_endp
mov ah,0eh
int 10h
inc di
jmp print
@_endp:
ret


align 8
GDT:
        NULL_descr      db              8 dup(0)
        CODE32_descr    db              0FFh,0FFh,00h,00h,00h,10011010b,11001111b,00h
        DATA_descr      db              0FFh,0FFh,00h,00h,00h,10010010b,11001111b,00h

        CODE_descr_r3   db              0FFh,0FFh,00h,00h,00h,11111010b,11001111b,00h
        DATA_descr_r3   db              0FFh,0FFh,00h,00h,00h,11110010b,11001111b,00h
        GDT_size        equ             $-GDT

label GDTR fword
                dw              GDT_size-1              
                dd              0
LOADER_INFO:
RAMDISK_SIZE dw 0
BOOT_DEVICE  dw 1       ;1 = floppy
VESA_LFB_OFFS dd 0x0


; include 'vesa.inc'


;Info
info_msg_1 db "Ozon Secondary loader",0Ah,0Dh,0
info_msg_2 db "Tarbol loaded",0xa,0xd ,0
;info_msg_3 db 'Wake up, Neo...',0xa,0xd, 0
;info_msg_4 db 'The Matrix has you...',0xa,0xd,0
;info_msg_5 db 'Follow the white rabbit.',0xa,0xd,0

;Error
err_msg_1 db "No Ozon Loader. Process Halt",0xa,0xd,0
err_msg_2 db "No VBE. Process Halt",0xa,0xd,0

tarboll_name db 'INIT    IMA'


align 0x200
blk_buffer rb 0x400
pagin_rb rb 0x4000

