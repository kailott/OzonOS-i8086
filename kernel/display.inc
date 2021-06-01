;display.inc
;Работа с экраном


;Вывод ASCIIZ строки
;ES:DI
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
;Перевод строки
NewStr:
push ax
mov ax,0e0ah
int 10h
mov ax,0e0dh
int 10h
pop ax
ret

;установка текстового видеорежима  80*25
set_vmode:
push ax
mov ax,0003h
int 10h
pop ax
ret

print_hex:
pusha
mov cl,16
@@:
push ax
sub cl,4
shr ax,cl
mov si,_ASCII
and ax,0Fh
add si,ax
push cs
pop ds
mov al,byte [cs:si]
mov ah,0eh
int 10h
pop ax
cmp cl,0
jne @b
popa
ret