include 'font.c'
char_line rb 30
text_color dw 0x7E0
backgrount_color dw 0
VESA_LFB dd 0x0
current_line dd 0x0
current_column dd 0x0
cursor_position dd 0x0

vesa32:

;Работа с битовой картой символа
;Ширина = 2 байта
;Высота = 15 строк
;функция разворачивает битовую строку в строку пикселей
;ax = битовая строка
.bitline_expand:
push edi
pushad
mov edi,char_line
mov ecx,8 ;char_width

push eax
mov ax,[ backgrount_color]
rep stosw

pop eax
@@:
mov edi,char_line
xor ecx,ecx

bsf cx,ax
jz @f
shl ecx,1        ;cx * 2
add edi,ecx

mov bx,[text_color]
mov [edi], bx
shr ecx,1
btr eax,ecx
jmp @b
@@:
popad
pop edi
ret



;Отрисовка символа
;al = символ
.draw_char:
;Высчитаем смещение символа в таблице шрифта
sub al,0x20
mov bl,al
xor eax,eax
mov al,bl
xor ah,ah
xor ebx,ebx
mov bl,al
shl eax,3
add eax,ebx
add eax,ebx
add eax,ebx
mov esi,font
add esi,eax


mov cx,11 ;Высота шрифта
@@:
mov ax,[esi]
call .bitline_expand
call .draw_line
add edi,2048
inc esi
dec cx
jnz @b
ret


;Вывод символа al в позицию edx : ebx
.custom_put_char:
push [current_line]
push [current_column]
mov [current_line],edx
mov [current_column],ebx
call .put_char
pop [current_column]
pop [current_line]
ret



.put_char:
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
mov bl,al
xor eax,eax
mov al,bl

mov edi,[VESA_LFB]
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
call .draw_char
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
;EDI строка
.vesa_print:
mov al,byte [edi]
cmp al,0
je @f
call .put_char
inc edi
jmp .vesa_print
@@:
ret



;Отрисовка линии
.draw_line:
push esi
push edi
push ecx
mov esi,char_line
mov ecx,8
@@:
lodsw
stosw
dec cx
jnz @b
pop ecx
pop edi
pop esi
;push esi
;push edi
;pushad
;mov esi,char_line
;mov cx,8;char_width
;@@:
;mov ax, word [esi]
;cmp ax,[ backgrount_color]
;;je  .tnxt
;mov [edi],word ax
;.tnxt:
;add edi,2
;add esi,2
;dec cx
;jnz @b
;popad
;pop edi
;pop esi
ret



