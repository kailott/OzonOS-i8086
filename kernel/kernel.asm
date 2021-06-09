org 0x0
start:
mov ax,0x500
mov ds,ax
mov es,ax
xchg bx,bx

;Установим обработчик прерывания 25h
cli                   ;Запретим прерывания
pushf                 ;Сохраним флаги
push 0
pop es
mov di,25h*4
mov [es:di],word fdd_int

mov di,25h*4+2
mov [es:di],cs

mov di,21h*4
mov [es:di],word conio_int
mov di,21h*4+2
mov [es:di],cs



popf
sti
;


;load shell.com
;include to kernel Ozon Os
;Пробуем загрузить  Shell.com
load_shell:
mov ax,cs
mov ds,ax
mov es,ax
mov ah,02h
mov di,ShellName
int 25h
cmp bx,-1
je      @shell_err
;в СХ размер файла в кластерах
push bx
;получим размер файла в параграфах
shr cx,5
add cx,10h ;PSP занимает 0х10 параграфоф
inc cx
;Резервирует сегмент памяти
;в cx размер сегмента в параграфах
;Возврат: ВХ = адрес сегмента
;mov ah,01h
;int 0F5h
mov bx,0x1000

mov cx,bx

pop bx

push cx
pop es
push cx
mov     ah,04h
mov     di,100h
int     25h
;Теперь передадим управление
pop cx
mov ax,cx

xchg bx,bx
cli
mov ss,ax
mov ax,0FFFEh
mov sp,ax
sti
mov ax,cx
mov es,ax
mov ds,ax
xor si,si
xor di,di
;В стэк адрес по которому передаем управление
push ax
push 100h
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
retf



@shell_err:
push cs
pop es

mov ah,01h
mov di,Shell_load_err
int 21h

;mov di,Shell_load_err
;call print
jmp $


ShellName       db      'SHELL   COM'
Shell_load_err  db      'Shell not found',0










include 'fdd.asm'
include 'conio.asm'

