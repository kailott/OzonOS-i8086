
;load shell.com
;include to kernel Ozon Os
;Пробуем загрузить  Shell.com
load_shell:
mov ah,02h
mov di,ShellName
int 25h
cmp bx,-1
je	@shell_err
;в СХ размер файла в кластерах
push bx
;получим размер файла в параграфах
shr cx,5
add cx,10h ;PSP занимает 0х10 параграфоф
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
mov	di,100h
int	25h
;Теперь передадим управление
pop cx
mov ax,cx

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









