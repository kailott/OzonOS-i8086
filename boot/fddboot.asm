org 07c00h
jmp start
nop
; BIOS Parameter Block
BS_OEMName              db      'OzonOS  '              ; 8 байт
BPB_BytsPerSec  dw      512                             ; кол-во байт в секторе
BPB_SecsPerClus db      1                               ; кол-во секторов в кластере
BPB_RsvdSecCnt  dw      1                               ; кол-во секторов в Reserved region
BPB_NumFATs             db      2                       ; кол-во таблиц FAT на диске
BPB_RootEntCnt  dw      224                             ; 
BPB_TotSec16    dw      2880                            ; общее кол-во секторов на диске
BPB_Media               db      0xF0            
BPB_FATSz16             dw      9                       ; кол-во секторов одной FAT
BPB_SecPerTrk   dw      18                              ; секторов на дорожке
BPB_NumHeads    dw      2
BPB_HiddSec             dd      0                       ; кол-во скрытых секторов
BPB_TotSec32    dd      0                       
BS_DrvNum               db      0
BS_Reserved1    db      0
BS_BootSig              db      0x29
BS_VolID                dd      2492347306
BS_VolLab               db      'OzonOs 0.01'   ; имя диска
BS_FileSysType  db      'FAT12   '
;===================================
DEFINE Debug 0
start:
mov [ADrive],dl

;push 0
;pop ds

;читаем FAT  и ROOT
push 0050h
pop es
xor di,di
mov bx,1
mov cx,18+15+1
@@:
call readsect
add di,200h
inc bx
loop @b



ll:
;Ищем первый кластер
push cs
pop es
ll_2:
mov di,kernelname
call Get_First_Claster
;Если bx=-1 значит не нашли
cmp bx,-1
je ErrorMesg


ll_1:
push 0500h
pop es
xor di,di


@@:
;push bx
add bx,1fh            ;LBA = CLASTER + 1Fh
;push es
;push di
call readsect         ;читаем сектор
;pop di
sub bx,0x1F
;pop es
;pop bx
add di,0200h
call Get_next_claster ;щем следующий кластер
cmp bx,0FFFh          ;Если кластер не последний
jne @b                ;То читаем его
ll_3:
nop
nop
ll_5:
;для экономии места модифицируем код
;изменим сегмент буфера
;mov  [ll_1 + 1], word 0xD00 ;Сегмент ядра = 0xD00
;mov  [ll_2 + 1], word kernelname
;mov  [ll_3], byte 0xEB
;mov  [ll_3 + 1], byte ll_4  - ll_5
;mov  [ErrorMesg + 1],word ERR13
;jmp ll
ll_4:
call 0x500:0000










ErrorMesg:            ;Если ошибка
mov si,ERR10
call print            ;Выведем сообщение
jmp $                 ;И зависнем =)

;Возвращает в BX первый кластер файла
;ES:DI = имя файла
Get_First_Claster:
push    ds
pusha
push    es
push    00050h
pop     ds
mov     si,2400h
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
pop     es
popa
mov     bx,ds
pop     ds
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
push    0050h   ;Сегмент FAT
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
;Читает сектор по LBA
;BX = номер сектора в LBA
;ES:DI буффер
readsect:
push    es
push    ds
pusha
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
mov     ax, 0201h
mov     dl, [ADrive]
int     13h
popa
pop     ds
pop     es
ret

;вывод ASCIIZ строки
;ds:si строка
print:
mov ax,cs
mov ds,ax
lodsb
cmp al,0
je @_endp
mov ah,0eh
int 10h
jmp print
@_endp:
ret

ADrive          db 0
ERR10           db 'ERR#10',0
;ERR13           db 'ERR#13',0
;stdioname       db 'STDIO   BIN'
kernelname      db 'KERNEL  BIN'





