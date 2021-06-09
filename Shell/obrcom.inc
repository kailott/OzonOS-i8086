RUNCOM:
cmp ax,00
je noCom
cmp ax,01h
je _01h
cmp ax,02h
je _02h
cmp ax,03h
je _03h
cmp ax,04h
je _04h
cmp ax,05h
je _05h
cmp ax,06h
je _06h
cmp ax,07h
je _07h
cmp ax,08h
je _08h
cmp ax,09h
je _09h
cmp ax,0Ah
je _0Ah
cmp ax,0Bh
je _0Bh
cmp ax,0Ch
je _0Ch
ret

_01h:
mov ah,05h
int 25h
mov ax,word [es:di]
mov si,word [es:di+2]
mov es,ax
mov di,si

@@:
mov al,byte [es:di]
cmp al,0
je @endprintdir
cmp al,0E5h
je _nextprtdir
mov bl,byte [es:di+11]
cmp bl,20h
je .nxt
cmp bl,10h
je .nxt
cmp bl,04h
je .nxt
cmp bl,00h
je .nxt
jmp _nextprtdir
.nxt:
call print
call NewStr
_nextprtdir:
add di,20h
jmp @b
@endprintdir:
ret
;Вывод 11 символов
print:
push di
xor cx,cx
@@:
mov al,byte [es:di]
mov ah,0eh
int 10h
inc di
inc cl
cmp cl,11
jne @b
pop di
ret




_02h:
mov ax,03h
int 10h
ret



_03h:
pusha
push cs
pop es
mov di,_dirmsg
mov ah,01h
int 21h
mov di,entcom
mov cx,30h
call clear
mov di,entcom
mov ah,04h
int 21h
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;в entcom имя папки
_nextcurdir:
cmp bx,0ECh
jne _error
;Проверяем существует ли папка
;int 25h
;Параметры: ES:DI = имя файла
push cs
pop es
mov di,entcom
mov ah,02h
int 25h
cmp bx,-1
je _dirnot
;если все таки существует
;читаем
;int 25h
;04h чтение цепочки кластеров
;Параметры:es:di = buffer  BX = первый кластер цепочки
push cs
pop es
push cs
pop ds
mov di,dir
add di,[dirpoint]
mov ah,04h
int 25h
;прочитали
mov ah,05h
int 25h
push cs
pop ds
mov ax,dir
add ax,[dirpoint]
mov [es:di],word cs
add di,2
mov [es:di],word ax
;пропишем в путь
push cs
pop es
mov di,entcom
call write_dir
popa
add [dirpoint],400h
ret
_error:
push cs
pop es
call NewStr
mov ah,01h
mov di,_errormsg
int 21h
popa
ret
_dirnot:
push cs
pop es
call NewStr
mov di,_dirnotfound
mov ah,01h
int 21h
popa
ret
_04h:
;RUN
pusha
push cs
pop es
mov di,_runmsg
mov ah,01h
int 21h
mov di,entcom
mov cx,30h
call clear
mov di,entcom
mov ah,04h
int 21h
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;в entcom имя файла
_nextruntask:
cmp bx,0EFh
jne _errorrun
call CorrectName
cmp ax,0EFh
je @f
call  UnCorrectTaskMessge
jmp _errorrun
@@:
;Проверяем существует файл
;int 25h
;Параметры: ES:DI = имя файла
;Возврат
;CX = Размер файла в кластерах  ВХ = первый кластер файла
push cs
pop es
mov di,entcom
mov ah,02h
int 25h
cmp bx,-1
je _tasknot
;если все таки существует
;читаем
;int 25h
;04h чтение цепочки кластеров
;Параметры:es:di = buffer  BX = первый кластер цепочки
push cs
pop es
push cs
pop ds
;push bx
;получим сегмент
;mov ah,01h
;int 0F5h
;pop bx
mov ax,0x3000
;push ax
mov es,ax  ;[segpoint]
mov di,0100h
mov ah,04h
int 25h
;прочитали


xchg bx,bx
;mov ax,0x3000
;mov es,ax
cmp word  [es:0x100],'MZ'
je mz_loader


call NewStr
;pop ax
mov cx,ax
;add [segpoint],1000h
;кинем по адрессу CX:0000 команду retf
mov ax,cx
mov es,ax
mov al,[_retf]
mov [es:0],byte al
;Подготовим регистры для передачи управления
;В СХ адресс сегмента в который загруженна программа
;Теперь настроим стэк передадим управление
mov [stackseg],ss
mov [stackoff],sp
mov ax,cx
cli
mov ss,ax
mov ax,0FFFEh
mov sp,ax
sti
;сохраним в стэк адресс возврата
push cs
push word _retShell
;в стэк адресс по которому передаем управление
push word 0
;push 0x3000
push cx
push 0100h
;настроим регистры
mov ax,cx
mov ds,ax
mov es,ax
xor di,di
xor si,si
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
;и передаем управление
retf
_retShell:
;после возврата установим стэк
push cs
pop ds
cli
mov ax,[stackseg]
mov ss,ax
mov ax,[stackoff]
mov sp,ax
sti
;Освободим память
;int f5h
;02h
;Освободить память
;в cx количество параграфоф которое было занято
;mov ah,02h
;int 0f5h
;Проверим видеорежим
mov ah,0Fh
int 10h
cmp al,03h
je @f
mov ax,03h
int 10h
@@:
popa
ret
_errorrun:
push cs
pop es
call NewStr
mov ah,01h
mov di,_errormsg
int 21h
popa
ret
_tasknot:
push cs
pop es
call NewStr
mov di,_tasknotfound
mov ah,01h
int 21h
popa
ret








_05h:
mov ax,cs
mov es,ax
mov di,help
mov ah,01h
int 21h
ret

_06h:
mov ah,05h
int 25h
mov ax,word [es:di]
cmp ax,0050h
je _endupdir
call RestBuff
call deldir
mov ax,dir
cmp [dirpoint],0
je  _rootdir
cmp [dirpoint],400h
je  _rootdir
sub [dirpoint],800h
add ax,[dirpoint]
mov [es:di],word cs
add di,2
mov [es:di],word ax
ret
_rootdir:
mov ah,05h
int 25h
mov [es:di],word 0050h
add di,2
mov [es:di],word 02400h
_endupdir:
ret

RestBuff:
push es
pusha
mov ax,cs
mov es,ax
mov di,dir
xor ax,ax
mov cx,400h
rep stosb
popa
pop es
ret





_07h:
xor ax,ax
mov ds,ax
mov ax,5304h
xor bx,bx
int 15h
push ax
mov ax,05301h
xor bx,bx
int 15h
mov ax,5308h
mov bx,1
mov cx,bx
int 15h
mov ax,530Dh
mov bx,1
mov cx,bx
int 15h
mov ax,530Fh
mov bx,1
mov cx,bx
int 15h
mov ax,5307h
mov bx,1
mov cx,3
int 15h
ret



_08h:
mov ah,08h
int 0f5h
ret


_09h:
;Проверим есть ли диск в дисководе 1
mov ah,00h
mov dl,00
int 13h
cmp ah,06h
je ErrorSetDisk
call _0Bh
;Сменим диск
mov dl,00
mov ah,07h
int 25h
;Перечитаем Root и FAT
mov ah,06h
int 25h
mov [drivef],00
ret



_0Ah:
;Проверим есть ли диск в дисководе 1
mov ah,00h
mov dl,01
int 13h
cmp ah,06h
je ErrorSetDisk
call _0Bh
;Сменим диск
mov dl,01
mov ah,07h
int 25h
;Перечитаем Root и FAT
mov ah,06h
int 25h
mov [drivef],01
ret

ErrorSetDisk:
mov ah,02h
mov bl,04h
mov di,_errordiskop
int 21h
ret





_0Bh:
push ds
mov ax,cs
mov ds,ax
;Очистим путь
mov es,ax
mov di,direct
xor ax,ax
mov cx,50h
rep stosb
pop ds
jmp _rootdir



;Удаление файла
_0Ch:
;DEL
pusha
push cs
pop es
mov di,_runmsg
mov ah,01h
int 21h
mov di,entcom
mov cx,30h
call clear
mov di,entcom
mov ah,04h
int 21h
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;Проверим это вообще файл?
;Ну или на крайняк папка =)
cmp bx,0ECh
je .next
cmp bx,0EFh
jne .error
.next:
;в entcom имя файла
mov ax,cs
mov es,ax
mov di,entcom
mov ah,11h
int 25h
jmp .exit
.error:

push cs
pop es
call NewStr
mov di,_uncorrecttask
mov ah,01h
int 21h


.exit:
popa
ret


noCom:
pusha
mov ax,cs
mov es,ax
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;в entcom имя папки или файла
cmp bx,0ECh
jne @f

jmp _nextcurdir
@@:
jmp _nextruntask
popa
ret


CorrectName:
push ds
pusha
mov ax,cs
mov ds,ax
mov si,entcom
add si,11-3
cld
lodsb
cmp al,'C'
jne UnCorrectTask
lodsb
cmp al,'O'
jne UnCorrectTask
lodsb
cmp al,'M'
jne UnCorrectTask
popa
mov ax,0EFh             ;Условный код
pop ds
ret
UnCorrectTask:
popa
xor ax,ax
pop ds
ret

UnCorrectTaskMessge:
push es
mov ax,cs
;Функция 02h вывод ASCIIZ строки в позицию курсора в расширенном режиме
;Параметры: ES:DI = ASCIIZ строка ,BL = Атрибут
mov es,ax
mov di,_uncorrecttask
mov ah,02h
mov bl,04h
int 21h
pop es
ret











stackseg        dw      0
stackoff        dw      0
_dirmsg         db      'Enter  dir name : ',0
_errormsg       db      'Value of range',0
_dirnotfound    db      'Directory not found',0
_runmsg         db      'Enter file name : ',0
_tasknotfound   db      'Task not found',0
_uncorrecttask  db      'Uncorrected file name',0
_errordiskop    db      'Error!Disk not found or not acces!',0
_retf           db      0CBh
help            db      'DIR displays the contents of a folder',0Ah,0Dh
                db      'CLS clear screen',0Ah,0Dh
                db      'CD change directory',0Ah,0Dh
                db      'RUN start task',0Ah,0Dh
                db      'UP rise to the directory above',0Ah,0Dh
                db      'OFF power off',0Ah,0Dh
                db      'ROOT for select root directory',0Ah,0Dh
                db      'Type A:\ or B:\ for select disk',0Ah,0Dh,0




