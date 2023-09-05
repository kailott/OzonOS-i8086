;init
;include to kernel Ozon Os
;настроим стэк
cli
mov ax,cs
mov ss,ax
mov ax,0FFFEh
mov sp,ax
sti
;Пробуем загрузить  STDIO.BIN
mov ah,02h
mov di,stdName
int 25h
cmp bx,-1
je	@stdio_err

push bx
;получим размер файла в параграфах
shr cx,5
inc cx
;Резервирует сегмент памяти
;в cx размер сегмента в параграфах
;Возврат: ВХ = адрес сегмента
mov ah,01h

int 0F5h
mov cx,bx
pop bx

push cx
pop es

push cx
mov	ah,04h
xor	di,di
int	25h
;Теперь установим обработчик
pop cx
cli			  ;Запретим прерывания
pushf			  ;Сохраним флаги
push 0
pop es
mov di,21h*4
mov [es:di],word 0
mov di,21h*4+2
mov [es:di],cx
sti
popf
;Функция 01h вывод на экран ASCIIZ строки в позицию курсора в стандартном режиме
push cs
pop es
mov ah,01h
mov di,HelloMesg
int 21h

