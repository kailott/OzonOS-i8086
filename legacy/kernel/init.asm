;init
;include to kernel Ozon Os
;�������� ����
cli
mov ax,cs
mov ss,ax
mov ax,0FFFEh
mov sp,ax
sti
;������� ���������  STDIO.BIN
mov ah,02h
mov di,stdName
int 25h
cmp bx,-1
je	@stdio_err

push bx
;������� ������ ����� � ����������
shr cx,5
inc cx
;����������� ������� ������
;� cx ������ �������� � ����������
;�������: �� = ����� ��������
mov ah,01h

int 0F5h
mov cx,bx
pop bx

push cx
pop es

push cx
mov	ah,04h
xor	di,di
int	25h
;������ ��������� ����������
pop cx
cli			  ;�������� ����������
pushf			  ;�������� �����
push 0
pop es
mov di,21h*4
mov [es:di],word 0
mov di,21h*4+2
mov [es:di],cx
sti
popf
;������� 01h ����� �� ����� ASCIIZ ������ � ������� ������� � ����������� ������
push cs
pop es
mov ah,01h
mov di,HelloMesg
int 21h

