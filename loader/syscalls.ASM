;int 0x30
int_0x30:
cmp ah, 0x0
je .func_00
cmp ah,0x1
je .func_01
cmp ah,0x2
je .func_02
cmp ah,0x3
je .func_03
cmp ah,0x40
je .func_040

iret;
;Вывод символа
;al = символ
.func_00:
pushad
call vesa32.put_char
popad
iret
;Вывод строки
;edi = указатель на строку
.func_01:
pushad
call vesa32.vesa_print
popad
iret
;Чтение символа с клавиатуры
;возврат = al = скан-код символа
.func_02:

iret


;Возвращает адрес LFB
.func_03:
mov eax,[VESA_LFB]
iret

.func_040:
mov eax,[MEM_SIZE]
iret
