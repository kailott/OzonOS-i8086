;mz_loader
mz_loader:
xchg bx,bx
mov ax,0x3010
;�������� ������� cs ��� ����������
mov ds,ax
add ax,[ds:0x8]; ���������� headersize - ������� ������ ������
mov [cs:base_cs],ax
;�������� ������� ���������� ����� , �������� ���
add ax , [ds:0xE] ; ���������� ����� �����, ������������ ����
mov ss,ax
;�������� �����
mov sp,[ds:0x10] ; SP
;��������� � ������� ����� �����
mov ax ,[cs:base_cs]
add ax, [ds:0x16]
push ax
push word [ds:0x14]
mov cx,[ds:0x6]
mov ax, [cs:base_cs]
mov si,[ds: 0x18]
@@:
test cx,cx
jz @f
add word [ds:si + 2], ax
add si,2
loop @b
@@:
mov ax,[cs:base_cs]
mov es,ax
mov ds,ax
xor ax,ax
retf






base_cs dw 0x0





;mov ds,ax
mov es,ax

mov ax,0x3010
add ax,[es:0x8]
mov ds,ax


add ax,[es:0x0E]
add ax,[es:0x8]
mov ss,ax
mov ax,[es:0x10]
add ax,[es:0x8]
add ax,0x3010
mov sp,ax
mov ax,[es:0x16]
add ax,0x3010
add ax,[es:0x8]
push ax
mov ax,[es:0x14]
push ax
;������� ������� �����������
mov cx,[es:0x6] ; ���������� ���������
mov di,[es:0x18] ; ����� ������� �����������
mov ax,0x3010
add ax,word [es:0x8]
@@:
add word [es:di+2], ax
add di,4
loop @b





mov ax,ds
mov es,ax
xor ax,ax
retf

