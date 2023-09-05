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
@@:             ;Здесь все понятно
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
cmp ah,06h
je _06h
cmp ah,07h
je _07h
cmp ah,08h
je _08h
cmp ah,09h
je _09h
cmp ah,0Ah
je _0Ah
cmp ah,0Bh
je _0Bh
cmp ah,0Ch
je _0Ch
cmp ah,0Dh
je _0Dh
cmp ah,0Eh
je _0Eh
cmp ah,0Fh
je _0Fh
cmp ah,010h
je _010h
cmp ah,011h
je _011h
mov bx,-1
iret


_00h:
;Драйвер версии 0.05
mov ax,005
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
call read_shake
iret

;ES:DI = адрес таблицы
_05h:
mov ax,cs
mov es,ax
mov di,rootseg
iret


_06h:
pusha
push es
;читаем FAT  и ROOT
push 01000h
pop es
xor di,di

mov bx,1
mov cx,18+15+1
@@:
mov al,02h
call readsect
add di,200h
dec cx
inc bx
cmp cx,0
jne @b
pop es
popa
iret


_07h:
push ds
push ax
mov  ax,cs
mov  ds,ax
mov  [drive],dl
pop ax
pop ds
iret

;Чтение файла
;in: ES:DI - filename
;    DS:SI - Buffer
_08h:
push ds
push si
;Ищем файл
call Get_First_Claster
cmp bx,-1
je .error
pop di
pop es
;чтение цепочки кластеров
;Параметры:es:di = buffer  BX = первый кластер цепочки
call read_shake
iret
.error:
mov bx,-1
ret

;Ищем пустую запись в FAT
;in: Bx - кластер с которого начинать поиск
;Out bx - номер свободного кластера
_09h:
call Get_empty_claser
iret

;Записать кластер в FAT
;BX - кластер
;DX - Значение
_0Ah:
call Write_Claster
iret

;Найти свободную запись в ROOT
;out: ES:DI = Адресс
;Если DI = 0 значит ошибка
_0Bh:
call Find_empty_Root
iret


_0Ch:
call Write_Sys
iret

;Создать файл
;in : DS:SI - адрес структуры типа
;Смещение     Размер          Значение
;   0            8            Имя файла
;   8            3            Расширение
;   11           1            Атрибут
;   12           10           Резерв
;   22           2            Время Создания
;   24           2            Дата Создания
;   26           2            Начальный кластер (Заполняется системой =) )
;   28           4            Размер файла в байтах
_0Dh:
pusha
push es
push di
push si
mov bx,0
call Get_empty_claser
mov dx,0FFFh
call Write_Claster
mov [ds:si+26],word bx
;mov [ds:si+28],dword 0
call Find_empty_Root
cmp di,0
je .error
mov cx,020h
pop si
rep movsb
;И перепишем FAT и ROOT на диск
call Write_Sys
jmp .exit
.error:
mov si,0
.exit:
pop di
pop es
popa
iret

_0Eh:
call Write_Empty_Claster
iret

_0Fh:
call Write_Clasters
iret



_010h:
call Delete_File
iret
_011h:
call Deletes_File
iret


;Записывает блок данных в свободный кластер
;in: ES:DI - блок данных (512 байт)
;out: bx   - кластер в который были записаны данные
Write_Empty_Claster:
push ds
pusha
mov bx,3
call Get_empty_claser
mov dx,0FFFh
call Write_Claster
mov al,03h
push bx
add bx,1fh   ;Сектор = кол-во скрытых + системных +  зарезервированных
call readsect
pop bx
mov ax,bx
mov ds,ax
popa
mov bx,ds
pop ds
ret

;Запись нескольких секторов с записью значений в FAT
;in: ВХ = начальный кластер
;ES:DI - блок данных
;CX    - Количество секторов которые нужно записать
Write_Clasters:
pusha
;Запишем первый сектор
mov al,03h
push bx
add bx,1Fh   ;Сектор = кластер + кол-во скрытых + системных +  зарезервированных
call  readsect
pop bx
add di,200h     ;512
dec cx
;Теперь цикл по записи
mov dx,bx    ;Сохраним предыдущий кластер

@@:
;in: ES:DI - блок данных (512 байт)
;out: bx   - кластер в который были записаны данные
call Write_Empty_Claster
add di,200h
dec cx

xchg dx,bx

push es
push ds
call Write_Claster
pop es
pop di

;xchg dx,bx

cmp cx,0
je .end
jmp @b

.end:
mov dx,0FFFh
call Write_Claster
popa
ret






Write_Sys:
pusha
push es
;Пишем FAT  и ROOT
push 01000h
pop es
xor di,di
mov bx,1
mov cx,18+15+1
@@:
mov al,03h
call readsect
add di,200h
dec cx
inc bx
cmp cx,0
jne @b
pop es
popa
ret

read_shake:
pusha
@@:
push es
push di
push bx
add bx,1fh
mov al,02h
call readsect
pop bx
pop di
pop es
add di,200h
call Get_next_claster
cmp bx,0FFFh
jne @b
popa
ret


;Сносим файл  с возможностью востановления
;in: ES:DI = имя файла
Delete_File:
pusha
call Find_Name
mov [ds:si],byte 0e5h
call Write_Sys
popa
rep



;Сносим файл  и все упоминания о нем в Root и FAT
;in: ES:DI = имя файла
Deletes_File:
pusha
push es
push di

;Сначала снесем все из FAT
call Get_First_Claster
;В ВХ первый кластер файла
mov cx,bx
@@:

;Выдает следующий за BX кластер
call Get_next_claster
cmp bx,0FFFh
je .end
;В BX следующий кластер
xchg cx,bx

xor dx,dx
call Write_Claster
;xchg cx,bx
jmp @b
.end:


xor dx,dx
call Write_Claster
pop di
pop es
call Find_Name
mov ax,ds
mov es,ax
mov di,si
xor ax,ax
mov cx,20h
rep stosb
call Write_Sys



popa
rep









;Ищет директории запись соответствующее имени файла
;in es:di - Имя файла
;out:ds:si - Адрес записи
Find_Name:
push    es
pusha
push  ds
push  cs
pop   ds
mov   ax,[rootseg]
mov   bx,[rootoff]
pop   ds
mov   ds,ax
mov   si,bx
mov   dx,si
@@:
mov     cx,11
push    di
push    si
repe    cmpsb
pop     si
pop     di
add     si,20h
cmp     si,0FFDFh
ja      .error
test    cx,cx
jnz     @b
sub     si,20h
mov     ax,si
mov     es,ax
.error:
mov si,0
.exit:
popa
mov     si,es
pop     es
ret








;Возвращает в BX первый кластер файла
;in: ES:DI = имя файла
;out: CX = Размер файла в кластерах
;     BX = Первый кластер
Get_First_Claster:
push    es
push    ds
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
mov     cx,11
push    di
push    si
repe    cmpsb
pop     si
pop     di
add     si,20h
cmp     si,5000h
ja      ErrorGFC
test    cx,cx
jnz     @b
sub     si,06
push    word [ds:si]
pop     ds
add     si,2
push    word [ds:si]
pop es
popa
mov     bx,ds
mov     cx,es
pop     ds
pop     es
ret

ErrorGFC:
pop     es
popa
pop     ds
mov     bx,-1
ret

;Выдает следующий за BX кластер
Get_next_claster:
push    es
push    ds
pusha
mov     ax,bx   ;копируем значение в ах
shr     bx,1    ;если кластер не четный то в CF=1
sbb     cx,cx   ;Если CF=1 то CX=-1
add     bx,ax   ;Умножаем на три
push    1000h   ;Сегмент FAT
pop     es
xor     si,si   ;Смещение FAT
add     si,bx
mov     ax,word [es:si]
and     cl,4
shr     ax,cl
and     ax,0FFFh
push    ax
pop     ds
popa
mov     bx,ds
pop     ds
pop     es
ret





;Записать кластер в FAT
;BX - кластер
;DX - Значение
Write_Claster:
pusha
push ds
xor cx,cx
;Рассчитаем смещение
mov ax,bx
shr bx,1      ;Если кластер нечетный то CF = 1
sbb cx,cx     ;Если  CF = 1 то cx = -1
add ax,bx     ;AX = (BX mod 2) * 3   т.е. в АХ смещение на слово содержащее наш кластер
push 1000h
pop ds
xor si,si
add si,ax
mov ax,[ds:si]; В AX наш кластер и кусочек соседнего
cmp cx,-1     ;Если кластер
jne @f        ;был четный то прыгаем на следующую метку @@
shl dx,4      ;Если все таки нечетный
@@:
xor ax,dx      ;Впишем наше значение
mov [ds:si],word  ax  ;И запишем в FAT
pop ds
popa
ret

;Найти свободную запись в ROOT
;out: ES:DI = Адресс
;Если DI = 0 значит ошибка
Find_empty_Root:
push ds
pusha
push 1000h
pop es
mov di,2400h
@@:
mov al,byte [es:di]
;Пустая запись?
cmp al,0
je .exit
;Запись об Удаленном файле?
cmp al,0E5h
je .exit
cmp di,2400h+512*15
je .error
add di,20h      ;Размер записи = 32 байта
jmp @b
jmp .exit
.error:
mov  di,0
.exit:
mov ax,di
mov ds,ax
popa
mov di,ds
pop ds
ret


;Ищем пустую запись в FAT
;Out bx - номер свободного кластера
Get_empty_claser:
push ds
pusha
mov ax,0
@@:
mov bx,ax
push ax
call Get_next_claster
pop ax
cmp bx,000
je .exit
inc ax
jmp @b
.exit:
mov ds,ax
popa
mov bx,ds
pop ds
ret





;Читает\Записывает сектор по LBA
;BX = номер сектора в LBA
;ES:DI буффер
;AL - тип операции
readsect:
push    es
push    ds
pusha
push    ax
mov     ax,bx
mov     cx, 18
mov     bx, di
xor     dx, dx
div     cx          ;Делим ax на 18
mov     ch, al      ;ch = ax div 18
shr     ch, 1       ;сh = ch div 2
mov     cl, dl
inc     cx
mov     dh, al
and     dh, 1
pop     ax
xchg    ah,al
mov     al,1
push    ds
push    ax
mov     ax,cs
mov     ds,ax
mov     dl,[drive]
pop     ax
pop     ds
int     13h
popa
pop     ds
pop     es
ret





drive           db      0
rootseg         dw      1000h
rootoff         dw      2400h
bufw            dw      0
dufb            db      0
clastline       dw      100h    dup (0)
filesize        dw      0