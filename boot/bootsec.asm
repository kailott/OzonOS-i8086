org 07c00h
jmp start
nop
; BIOS Parameter Block
BS_OEMName              db      'OzonOS  '              ; 8 ����
BPB_BytsPerSec  dw      512                             ; ���-�� ���� � �������
BPB_SecsPerClus db      1                               ; ���-�� �������� � ��������
BPB_RsvdSecCnt  dw      1                               ; ���-�� �������� � Reserved region
BPB_NumFATs             db      2                       ; ���-�� ������ FAT �� �����
BPB_RootEntCnt  dw      224                             ; 
BPB_TotSec16    dw      2880                            ; ����� ���-�� �������� �� �����
BPB_Media               db      0xF0            
BPB_FATSz16             dw      9                       ; ���-�� �������� ����� FAT
BPB_SecPerTrk   dw      18                              ; �������� �� �������
BPB_NumHeads    dw      2
BPB_HiddSec             dd      0                       ; ���-�� ������� ��������
BPB_TotSec32    dd      0                       
BS_DrvNum               db      0
BS_Reserved1    db      0
BS_BootSig              db      0x29
BS_VolID                dd      2492347306
BS_VolLab               db      'OzonOs 0.01'   ; ��� �����
BS_FileSysType  db      'FAT12   '
;===================================
DEFINE Debug 0
start:
mov [ADrive],dl

push 0
pop ds

mov si,0FFFAh
mov [ds:si],byte dl

;������ FAT  � ROOT
push 1000h
pop es
xor di,di
mov bx,1
mov cx,18+15+1
@@:
call readsect
add di,200h
dec cx
inc bx
cmp cx,0
jne @b

mov ah,0h
mov al,1110111b
int 14h
push 1000h
pop es
xor di,di
;���� ������ �������
push cs
pop es
mov di,FileName
call Get_First_Claster
;���� bx=-1 ������ �� �����
cmp bx,-1
je ErrorMesg
push bx
mov di,OkMesg
call print
pop bx

push 01A00h       ;������� ���
pop es                ;�� ������
xor di,di             ;01A00h:0000h
;������ ����
@@:
push bx
add bx,1fh            ;LBA = CLASTER + 1Fh
push es
push di
call readsect         ;������ ������
pop di
pop es
pop bx
add di,0200h
if Debug=1            ;�������������� ������ ���� Debug = 1
push ax               ;������� ��������� ��� �������
mov ah,0eh            ;
mov al,'*'            ;
int 10h               ;
pop ax                ;
end if
call Get_next_claster ;��� ��������� �������
cmp bx,0FFFh          ;���� ������� �� ���������
jne @b                ;�� ������ ���
;��������� ���������� ���������� 25h
cli                   ;�������� ����������
pushf                 ;�������� �����
push 0
pop es
mov di,25h*4
mov [es:di],word 0    ;�������� 0000h
mov ax,01A00h
mov di,25h*4+2
mov [es:di],word ax   ;������� 0500h
popf                  ;����������� ������� ������
sti                   ;�������� ����������
;������ ������ ����
push cs
pop es
mov di,kernelname
mov ah,02h            ;������� 02h ���������� ������ ������� �����
int 25h
IF Debug = 1
push ax
mov ah,0eh
mov al,'1'
int 10h
pop ax
end if
;� BX ������ ������� ����
;04h ������ ������� ���������
;���������:es:di = buffer  BX = ������ ������� �������
push 04000h
pop es
xor di,di
mov ah,04h
int 25h

IF Debug = 1
push ax
mov ah,0eh
mov al,'2'
int 10h
pop ax
end if


mov ax,4000h          ;�������� �������� �
mov ds,ax
mov es,ax
mov ss,ax
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
xor bp,bp
xor si,si
xor di,di
mov sp,0FFFEh
mov bx,"FD"
call  04000h:0000h     ;�������� ���������� ����
ErrorMesg:            ;���� ������
push cs
pop es
mov di,Errormsg
call print            ;������� ���������
jmp $                 ;� �������� =)

;���������� � BX ������ ������� �����
;ES:DI = ��� �����
Get_First_Claster:
push    ds
pusha
push    es
push    1000h
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
;������ �������� �������� �� ������� BX
Get_next_claster:
push    es
push    ds
pusha
mov     ax,bx   ;�������� �������� � ��
shr     bx,1    ;���� ������� �� ������ �� � CF=1
sbb     cx,cx   ;���� CF=1 �� CX=-1
add     bx,ax   ;�������� �� ���
push    1000h   ;������� FAT
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













;������ ������ �� LBA
;BX = ����� ������� � LBA
;ES:DI ������
readsect:
push    es
push    ds
pusha
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
mov     ax, 0201h
mov     dl, 00
int     13h
popa
pop     ds
pop     es
ret
;����� ASCIIZ ������
;ES:DI ������
print:
mov al,byte [es:di]
cmp al,0
je @_endp
mov ah,0eh
int 10h
inc di
jmp print
@_endp:
ret
ADrive          db 00
OkMesg          db 'File founded',0Ah,0Dh,0
Errormsg        db 'Error file found =(',0
FileName        db 'FATDRV  BIN'
kernelname      db 'LOADER  BIN'



