;UTILIT
;Библиотечка шела OzonOS
;привидение строки комманд к дефолтному виду
include 'if.inc'
;ЕS:DI = строка с командой  , нуль-терминированная
NormCom:
push di
@@:
mov al,byte [es:di]
cmp al,0
je .endnorm
.if (al<='z')&(al>='a')
sub al,20h
.endif
mov [es:di],byte al
inc di
jmp @b

.endnorm:
pop di
ret

;Возвращает в АХ номер команды.0-неверная команда
;ES:DI = строка с командой
DefCom:
push	es
push	ds
pusha
mov	ax,cs
mov	ds,ax
mov	si,comands
@@:
mov	cx,8
push	di
push	si
repe	cmpsb
pop	si
pop	di
add	si,10
cmp	si,[comend]
ja	ErrorCOM
test	cx,cx
jnz	@b
sub	si,2
push	word [ds:si]
pop	ds
popa
mov	ax,ds
pop	ds
pop	es
xchg	ah,al
ret
ErrorCOM:
pop	es
popa
pop	ds
mov	ax,0
ret

;Перевод строки
NewStr:
mov ax,0e0ah
int 10h
mov ax,0e0dh
int 10h
ret

;очищает строку
;di-строка
;CX-размер
clear:
pusha
push cs
pop es
xor al,al
rep stosb
popa
ret

;Нормализуем имя файла\папки
;ES:DI - строка
FileNameNorm:
push cs
pop es
mov ax,di
push ax
mov si,di
mov cx,11
xor ax,ax
mov al,'.'
cld
repne scasb
jne .dirname
;если имя файла
mov ax,word [es:di]
mov bl,byte [es:di+2]
;AH,AL,BL = символы расширения
pop dx
push ax
push bx
mov ax,di
sub ax,si
mov cx,ax	;в cx количество символов до точки
mov ax,8
sub ax,cx
mov cx,ax
mov al,020h
cld
dec di
inc cx
repne stosb
inc ax
pop bx
pop ax
mov [es:di],word ax
mov [es:di+2],byte bl
add di,3
mov al,0
mov cx,30h-11
rep stosb
mov bx,0EFh	;Это имя файла
ret
;Если введеная строка имя папки
.dirname:
pop di
mov ax,di
push ax
mov al,0
mov cx,11
repne scasb
jne @errval
mov cx,di
pop ax
sub cx,ax
mov bx,11
sub bx,cx
mov cx,bx
inc cx
dec di
mov al,020h
cld
repne stosb

mov bx,0ECh	;Это имя папки
ret
@errval:
mov bx,-1
ret

;ES:DI = Имя папки
write_dir:
pusha
push cs
pop ds
mov si,direct
@@:
mov al,byte [ds:si]
cmp al,0
je _nxtwd
cmp al,020h
je _nxtwd
inc si
jmp @b
_nxtwd:

mov al,byte [es:di]
cmp al,0
je _endwritedir
cmp al,020h
je _endwritedir
mov [ds:si],byte al
inc di
inc si
jmp _nxtwd
_endwritedir:
mov [ds:si],byte '\'
popa
ret



deldir:
push ds
push es
pusha
push cs
pop es
mov di,direct
@@:
mov al,byte [es:di]
cmp al,0
je _nextdirdel
inc di
jmp @b
_nextdirdel:
sub di,2
@@:
mov al,byte [es:di]
cmp al,'\'
je _endstr
mov [es:di],byte 0
dec di
jmp @b
_endstr:
popa
pop es
pop ds
ret

;Чистим буффер клавиатуры
;40h:1Eh
erase_key:
mov ax,040h
mov es,ax
mov di,1eh
@@:
mov [es:di],byte 0
inc di
cmp di,3dh
jne @b




























