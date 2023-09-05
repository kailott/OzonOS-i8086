;управление памятью
set_memory_int:
push es
pusha
;Теперь установим обработчик
cli			  ;Запретим прерывания
pushf			  ;Сохраним флаги
push 0
pop es
mov di,0F5h*4
mov [es:di],word memory_int
mov di,0F5h*4+2
mov [es:di],word cs
sti
popf
popa
pop es
ret

memory_int:
cmp ah,00h
je _00h
cmp ah,01h
je _01h
cmp ah,02h
je _02h
mov bx,-1
iret

_00h:
push ds
mov ax,cs
mov ds,ax
;возвращает в AX свободный сегмент
mov ax,[FreeSeg]
pop ds
iret

_01h:
;Резервирует 64k памяти
push ds

mov ax,cs
mov ds,ax

mov ax,[FreeSeg]
mov bx,ax
add [FreeSeg],01000h

pop ds
iret

_02h:
push ds
mov ax,cs
mov ds,ax
;Освободить 64k занятой  памяти
sub [FreeSeg],01000h
pop ds
iret
FreeSeg 	dw	01000h


