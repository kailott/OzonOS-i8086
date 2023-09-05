;mz_loader
mz_loader:
xchg bx,bx
mov ax,0x3010
;вычислим базовый cs дл€ приложени€
mov ds,ax
add ax,[ds:0x8]; прибавл€ем headersize - находим начало бинар€
mov [cs:base_cs],ax
;получили базовый сегментный адрес , сохраним его
add ax , [ds:0xE] ; —егментный адрес стека, относительно базы
mov ss,ax
;—мещение стека
mov sp,[ds:0x10] ; SP
;расчитаем и запушим точку входа
mov ax ,[cs:base_cs]
add ax, [ds:0x16]
push ax
push word [ds:0x14]
mov cx,[ds:0x6]
mov ax, [cs:base_cs]
mov si,[ds: 0x18]
@@:
test cx,cx
jz @f
add word [ds:si + 2], ax
add si,2
loop @b
@@:
mov ax,[cs:base_cs]
mov es,ax
mov ds,ax
xor ax,ax
retf






base_cs dw 0x0





;mov ds,ax
mov es,ax

mov ax,0x3010
add ax,[es:0x8]
mov ds,ax


add ax,[es:0x0E]
add ax,[es:0x8]
mov ss,ax
mov ax,[es:0x10]
add ax,[es:0x8]
add ax,0x3010
mov sp,ax
mov ax,[es:0x16]
add ax,0x3010
add ax,[es:0x8]
push ax
mov ax,[es:0x14]
push ax
;—ломаем таблицу перемещений
mov cx,[es:0x6] ;  оличество аллокаций
mov di,[es:0x18] ; јдрес таблицы перемещений
mov ax,0x3010
add ax,word [es:0x8]
@@:
add word [es:di+2], ax
add di,4
loop @b





mov ax,ds
mov es,ax
xor ax,ax
retf

