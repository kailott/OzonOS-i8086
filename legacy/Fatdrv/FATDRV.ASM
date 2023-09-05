org 00h
;Драйвер файловой системы FAT 12 v.0.02
;Каталоги не поддерживаются
;Запись не поддерживается
;Обработка ошибок отсутствует
;Функции
;00h Возвращает в AX версию драйвера
;01h Чтение сектора
;Параемтры : Bx = LBA , ES:DI = buffer
;02h Возвращает в BX  первый кластер файла
;Параметры: ES:DI = имя файла
;03h Возвращает следующий за BX кластер
;Параметры BX = текущий кластер
;04h чтение цепочки кластеров
;Параметры:es:di = buffer  BX = первый кластер цепочки
@@:		;Здесь все понятно
cmp ah,00h
je _00h
cmp ah,01h
je _01h
cmp ah,02h
je _02h
cmp ah,03h
je _03h
cmp ah,04h
je _04h

cmp ah,05h
je _05h
;cmp ah,06h
;je _06h
;cmp ah,07h
;je _07h
mov bx,-1
iret

_00h:
;Драйвер версии 0.02
mov ax,002
iret
;чтение сектора
_01h:
call readsect
iret

;Первый кластер
_02h:
call Get_First_Claster
iret

;Следующий кластер
_03h:
call Get_next_claster
iret

;Чтение цепочки
_04h:
pusha
@@:
push es
push di
push bx
add bx,1fh
call readsect
pop bx
pop di
pop es
add di,200h
call Get_next_claster
cmp bx,0FFFh
jne @b
popa
iret

;ES:DI = адрес таблицы
_05h:
mov ax,cs
mov es,ax
mov di,rootseg
iret


;Возвращает в BX первый кластер файла
;ES:DI = имя файла
;CX = Размер файла в кластерах
Get_First_Claster:
push	es
push	ds
pusha

push  ds

push  cs
pop   ds
mov   ax,[rootseg]
mov   bx,[rootoff]
pop   ds

mov   ds,ax
mov   si,bx


@@:
mov	cx,11
push	di
push	si
repe	cmpsb
pop	si
pop	di
add	si,20h
cmp	si,5000h
ja	ErrorGFC
test	cx,cx
jnz	@b
sub	si,06
push	word [ds:si]
pop	ds
add	si,2
push	word [ds:si]
pop es
popa
mov	bx,ds
mov	cx,es
pop	ds
pop	es
ret
ErrorGFC:
pop	es
popa
pop	ds
mov	bx,-1
ret
;Выдает следующий за BX кластер
Get_next_claster:
push	es
push	ds
pusha
mov	ax,bx	;копируем значение в ах
shr	bx,1	;если кластер не четный то в CF=1
sbb	cx,cx	;Если CF=1 то CX=-1
add	bx,ax	;Умножаем на три
push	0050h	;Сегмент FAT
pop	es
xor	si,si	;Смещение FAT
add	si,bx
mov	ax,word [es:si]
and	cl,4
shr	ax,cl
and	ax,0FFFh
push	ax
pop	ds
popa
mov	bx,ds
pop	ds
pop	es
ret
;Читает сектор по LBA
;BX = номер сектора в LBA
;ES:DI буффер
readsect:
push	es
push	ds
pusha
mov	ax,bx
mov	cx, 18
mov	bx, di
xor	dx, dx
div	cx	    ;Делим ax на 18
mov	ch, al	    ;ch = ax div 18
shr	ch, 1	    ;сh = ch div 2
mov	cl, dl
inc	cx
mov	dh, al
and	dh, 1
mov	ax, 0201h
push	ds
push	si
push	0050h
pop	ds
mov	si,0FFFah
xchg	al,dl
lodsb
xchg	al,dl
pop	si
pop	ds
int	13h
popa
pop	ds
pop	es
ret



rootseg 	dw	0050h
rootoff 	dw	2400h