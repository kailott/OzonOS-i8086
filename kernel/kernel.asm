org 0x0
start:
mov ax,0x500
mov ds,ax
mov es,ax
xchg bx,bx

;��������� ���������� ���������� 25h
cli                   ;�������� ����������
pushf                 ;�������� �����
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
;������� ���������  Shell.com
load_shell:
mov ax,cs
mov ds,ax
mov es,ax
mov ah,02h
mov di,ShellName
int 25h
cmp bx,-1
je      @shell_err
;� �� ������ ����� � ���������
push bx
;������� ������ ����� � ����������
shr cx,5
add cx,10h ;PSP �������� 0�10 ����������
inc cx
;����������� ������� ������
;� cx ������ �������� � ����������
;�������: �� = ����� ��������
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
;������ ��������� ����������
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
;� ���� ����� �� �������� �������� ����������
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

