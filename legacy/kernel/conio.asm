;STDIO.asm
;������� ���������� � �������� Ozon Operating System
;������� 00h ������� ������ ��������
;������� 01h ����� �� ����� ASCIIZ ������ � ������� ������� � ����������� ������
;��������� ES:DI = ASCIIZ ������
;������� 02h ����� ASCIIZ ������ � ������� ������� � ����������� ������
;���������: ES:DI = ASCIIZ ������ ,BL = �������
;��� ������ BX=-1
;������� 03h ��������� ������� ������������� � ������� �������
;������� 04h ������ ������ � ����������, ES:DI = ������
conio_int:
@@:
;��� ������������� � DOS
cmp ax,04c00h
je __04c00h
cmp ah,00h
je __00h
cmp ah,01h
je __01h
cmp ah,02h
je __02h
cmp ah,03h
je __03h
cmp ah,04h
je __04h
mov ax,-1
iret

__00h:
mov ax,003h
iret

__01h:
;����� ASCIIZ ������
;ES:DI ������
pusha
@@:
mov al,byte [es:di]
cmp al,0
je @_endp
mov ah,0eh
int 10h
inc di
jmp @b
@_endp:
popa
iret

__02h:
;����� ASCIIZ ������
;ES:DI ������
pusha
push es
push di
xor cx,cx
@@:
mov al,byte [es:di]
inc di
inc cx
cmp cx,254
je @__02hErr
cmp al,0
jne @b
pop di
pop es
mov bp,di
dec cx
call ActivPage
call GetCursor
mov ah,13h
mov al,1
int 10h
popa
iret
@__02hErr:
mov bx,-1
iret

;���������� �������� ������������� � ���������� �������
;�������  : BH = �������������
;           DH = ������ DL = �������
__03h:
call ActivPage
call GetCursor
iret


;������ ������ � ����������
;ES:DI = buffer
__04h:
pusha
call keyread
popa
iret


keyread:
;push bx
call ActivPage
call GetCursor
;pop bx
xor dh,dh
mov [_spaces],dl
xor cx,cx
read:
mov ax,00h
int 16h
cmp ah,1ch
je @end
inc cx
cmp ah,0eh
je @BackSpace
mov ah,0eh
int 10h
mov [es:di],byte al
inc di
jmp read
@end:
mov [_spaces],0
ret

@BackSpace:

call  GetCursor
cmp dl,[_spaces]
je read
dec cx
dec di
mov [es:di],byte 0
push cx
mov al,08h
mov ah,0eh
int 10h
mov ah,0ah
mov al,20h
mov bh,0
mov cx,1
int 10h
pop cx
jmp read
_spaces db 0


;����� �����������
;al = ����������
__05h:
xor ah,ah
int 10h
iret
;��������� �����������
__06h:
mov ah,0Fh
int 10h
iret
;������� ������
__07h:
pusha
mov ax,0E0Ah
int 10h
mov ax,0E0Dh
int 10h
popa
iret











__04c00h:
int 20h
iret

;��������� �������� �������������
;�������:BH = �������� �������������
ActivPage:
push ax
mov ah,0fh
int 10h
pop ax
ret

;��������� ������� �������
;���������: BH = �������������
;�������  : DH = ������ DL = �������
GetCursor:
push ax
push cx
mov ah,03h
int 10h
pop cx
pop ax
ret





