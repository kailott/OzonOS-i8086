;org 00h
;������� �������� ������� FAT 12 v.0.02
;�������� �� ��������������
;������ �� ��������������
;��������� ������ �����������
;�������
;00h ���������� � AX ������ ��������
;01h ������ �������
;��������� : Bx = LBA , ES:DI = buffer
;02h ���������� � BX  ������ ������� �����
;���������: ES:DI = ��� �����
;03h ���������� ��������� �� BX �������
;��������� BX = ������� �������
;04h ������ ������� ���������
;���������:es:di = buffer  BX = ������ ������� �������
fdd_int:
@@:             ;����� ��� �������
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
;������� ������ 0.05
mov ax,005
iret
;������ �������
_01h:
call readsect
iret

;������ �������
_02h:
call Get_First_Claster
iret

;��������� �������
_03h:
call Get_next_claster
iret

;������ �������
_04h:
call read_shake
iret

;ES:DI = ����� �������
_05h:
mov ax,cs
mov es,ax
mov di,rootseg
iret


_06h:
pusha
push es
;������ FAT  � ROOT
push 0050h
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

;������ �����
;in: ES:DI - filename
;    DS:SI - Buffer
_08h:
push ds
push si
;���� ����
call Get_First_Claster
cmp bx,-1
je .error
pop di
pop es
;������ ������� ���������
;���������:es:di = buffer  BX = ������ ������� �������
call read_shake
iret
.error:
mov bx,-1
ret

;���� ������ ������ � FAT
;in: Bx - ������� � �������� �������� �����
;Out bx - ����� ���������� ��������
_09h:
call Get_empty_claser
iret

;�������� ������� � FAT
;BX - �������
;DX - ��������
_0Ah:
call Write_Claster
iret

;����� ��������� ������ � ROOT
;out: ES:DI = ������
;���� DI = 0 ������ ������
_0Bh:
call Find_empty_Root
iret


_0Ch:
call Write_Sys
iret

;������� ����
;in : DS:SI - ����� ��������� ����
;��������     ������          ��������
;   0            8            ��� �����
;   8            3            ����������
;   11           1            �������
;   12           10           ������
;   22           2            ����� ��������
;   24           2            ���� ��������
;   26           2            ��������� ������� (����������� �������� =) )
;   28           4            ������ ����� � ������
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
;� ��������� FAT � ROOT �� ����
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


;���������� ���� ������ � ��������� �������
;in: ES:DI - ���� ������ (512 ����)
;out: bx   - ������� � ������� ���� �������� ������
Write_Empty_Claster:
push ds
pusha
mov bx,3
call Get_empty_claser
mov dx,0FFFh
call Write_Claster
mov al,03h
push bx
add bx,1fh   ;������ = ���-�� ������� + ��������� +  �����������������
call readsect
pop bx
mov ax,bx
mov ds,ax
popa
mov bx,ds
pop ds
ret

;������ ���������� �������� � ������� �������� � FAT
;in: �� = ��������� �������
;ES:DI - ���� ������
;CX    - ���������� �������� ������� ����� ��������
Write_Clasters:
pusha
;������� ������ ������
mov al,03h
push bx
add bx,1Fh   ;������ = ������� + ���-�� ������� + ��������� +  �����������������
call  readsect
pop bx
add di,200h     ;512
dec cx
;������ ���� �� ������
mov dx,bx    ;�������� ���������� �������

@@:
;in: ES:DI - ���� ������ (512 ����)
;out: bx   - ������� � ������� ���� �������� ������
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
;����� FAT  � ROOT
push 0050h
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


;������ ����  � ������������ �������������
;in: ES:DI = ��� �����
Delete_File:
pusha
call Find_Name
mov [ds:si],byte 0e5h
call Write_Sys
popa
rep



;������ ����  � ��� ���������� � ��� � Root � FAT
;in: ES:DI = ��� �����
Deletes_File:
pusha
push es
push di

;������� ������ ��� �� FAT
call Get_First_Claster
;� �� ������ ������� �����
mov cx,bx
@@:

;������ ��������� �� BX �������
call Get_next_claster
cmp bx,0FFFh
je .end
;� BX ��������� �������
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









;���� ���������� ������ ��������������� ����� �����
;in es:di - ��� �����
;out:ds:si - ����� ������
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








;���������� � BX ������ ������� �����
;in: ES:DI = ��� �����
;out: CX = ������ ����� � ���������
;     BX = ������ �������
Get_First_Claster:
push    es
push    ds
pusha
push  ds
push  cs
pop   ds
mov   ax,[cs:rootseg]
mov   bx,[cs:rootoff]
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

;������ ��������� �� BX �������
Get_next_claster:
push    es
push    ds
pusha
mov     ax,bx   ;�������� �������� � ��
shr     bx,1    ;���� ������� �� ������ �� � CF=1
sbb     cx,cx   ;���� CF=1 �� CX=-1
add     bx,ax   ;�������� �� ���
push    0050h   ;������� FAT
pop     es
xor     si,si   ;�������� FAT
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





;�������� ������� � FAT
;BX - �������
;DX - ��������
Write_Claster:
pusha
push ds
xor cx,cx
;���������� ��������
mov ax,bx
shr bx,1      ;���� ������� �������� �� CF = 1
sbb cx,cx     ;����  CF = 1 �� cx = -1
add ax,bx     ;AX = (BX mod 2) * 3   �.�. � �� �������� �� ����� ���������� ��� �������
push 0050h
pop ds
xor si,si
add si,ax
mov ax,[ds:si]; � AX ��� ������� � ������� ���������
cmp cx,-1     ;���� �������
jne @f        ;��� ������ �� ������� �� ��������� ����� @@
shl dx,4      ;���� ��� ���� ��������
@@:
xor ax,dx      ;������ ���� ��������
mov [ds:si],word  ax  ;� ������� � FAT
pop ds
popa
ret

;����� ��������� ������ � ROOT
;out: ES:DI = ������
;���� DI = 0 ������ ������
Find_empty_Root:
push ds
pusha
push 0050h
pop es
mov di,2400h
@@:
mov al,byte [es:di]
;������ ������?
cmp al,0
je .exit
;������ �� ��������� �����?
cmp al,0E5h
je .exit
cmp di,2400h+512*15
je .error
add di,20h      ;������ ������ = 32 �����
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


;���� ������ ������ � FAT
;Out bx - ����� ���������� ��������
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





;������\���������� ������ �� LBA
;BX = ����� ������� � LBA
;ES:DI ������
;AL - ��� ��������
readsect:
push    es
push    ds
pusha
push    ax
mov     ax,bx
mov     cx, 18
mov     bx, di
xor     dx, dx
div     cx          ;����� ax �� 18
mov     ch, al      ;ch = ax div 18
shr     ch, 1       ;�h = ch div 2
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
rootseg         dw      0050h
rootoff         dw      2400h
bufw            dw      0
dufb            db      0
clastline       dw      100h    dup (0)
filesize        dw      0