org 100h
start:
call set_int20h





push cs
pop es


@next:
call erase_key
push cs
pop es
push cs
pop ds
;������� �����������
mov ah,01h
mov di,greeting
int 21h
mov ah,01h
mov di,direct
int 21h

mov ah,0eh
mov al,'>'
int 10h

;����������� ������
;������ �������
;int 21h
;������� 04h ������ ������ � ����������, ES:DI = ������
mov ah,04h
push cs
pop es
mov di,entcom
int 21h
;�������� ������
;�������� �� � ���������
push cs
pop es
mov di,entcom
call NormCom
;������ ��������� ��� �� ��� �������
call DefCom
push cs
pop ds
push ax
call NewStr
pop ax
;� �� ������������� �������
;���������� ������ RUNCOM
call RUNCOM
;����������, �������� � ������

;������� �����
mov di,entcom
mov cx,30h
call clear

call NewStr
push cs
pop ds
push cs
pop es
jmp @next

;��� ���� �����-�� ������������� � DOS
set_int20h:
cli			  ;�������� ����������
pushf			  ;�������� �����
push 0
pop es
mov di,20h*4
mov [es:di],word _int20h
mov di,20h*4+2
mov [es:di],cs
sti
popf
ret

_int20h:
;����� �� ���������
pop ax
pop ax
pop ax
pop ax
pop ax
pop ax
jmp _retShell








include 'utilit.inc'
include 'obrcom.inc'
include 'data.inc'


