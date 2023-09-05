include 'font.c'
char_line rb 30
text_color dw 0x7E0
backgrount_color dw 0
VESA_LFB dd 0x0



;Отрисовка символа
;al = символ
draw_char:
;Высчитаем смещение символа в таблице шрифта
sub al,0x20
xor ah,ah
xor bx,bx
mov bl,al
shl ax,3
add ax,bx
add ax,bx
add ax,bx
mov si,font
add si,ax


mov cx,11 ;Высота шрифта
@@:
mov ax,[si]
call bitline_expand
call draw_line
add edi,2048
inc si
dec cx
jnz @b
ret







current_line dd 0x0
current_column dd 0x0
;cursor_position dd 0x0
put_char:
;вывод символа
;al = код символа
;расчет 6 пикселей - ширина символа
;       11 пикселей - высота
;Весь дисплей = 170 символов в ширину
;               68 символов в высоту
;Для начала проверим на спецсимволы
cmp al,0xA ; Новая строка
jne @f
inc [current_line]
ret

@@:
cmp al,0xD ;Возврат коретки
jne @f
mov [current_column],0
ret

@@:
push edi
push ebx
push ecx
mov edi,[VESA_LFB_OFFS]
mov ebx,[current_line]
shl ebx,11 ; line * 2048
;теперь умножим на высоту символа
;выысота символа = 10 пикселей
;умножим на 8
mov ecx,ebx
shl ebx,3
shl ecx,1
add ebx,ecx

;add edi,[cursor_position]
add edi,ebx
mov ebx, [current_column]
shl ebx,4
mov ecx,[current_column]
shl ecx,1
sub ebx,ecx
add edi,ebx


call draw_char
inc [current_column]
cmp [current_column],170
jne @f
inc [current_line]
mov [current_column],0
@@:

pop ecx
pop ebx
pop edi
ret


;вывод ASCIIZ строки
;ES:DI строка
vesa_print:
mov al,byte [es:di]
cmp al,0
je @f
call put_char
inc di
jmp vesa_print
@@:
ret





;Отрисовка линии
draw_line:
push si
push edi
pushad
mov si,char_line
mov cx,8;char_width
@@:
mov ax, word [ds:si]
cmp ax,[ backgrount_color]
je  $+4
mov [gs:edi],word ax
add edi,2
add si,2
dec cx
jnz @b
popad
pop edi
pop si
ret



;Работа с битовой картой символа
;Ширина = 2 байта
;Высота = 15 строк
;функция разворачивает битовую строку в строку пикселей
;ax = битовая строка
bitline_expand:
push edi
pushad
mov di,char_line
mov cx,8 ;char_width
push ax
mov ax,[ backgrount_color]
@@:
mov [es:di] ,ax
add di,2
loop @b
pop ax
@@:
mov di,char_line
xor cx,cx
bsf cx,ax
jz @f
shl cx,1        ;cx * 2
add di,cx

mov bx,[text_color]
mov [ds:di], bx

shr cx,1
btr ax,cx


jmp @b
@@:
popad
pop edi
ret
