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

;push 0
;pop ds

;������ FAT  � ROOT
push 0050h
pop es
xor di,di
mov bx,1
mov cx,18+15+1
@@:
call readsect
add di,200h
inc bx
loop @b



ll:
;���� ������ �������
push cs
pop es
ll_2:
mov di,kernelname
call Get_First_Claster
;���� bx=-1 ������ �� �����
cmp bx,-1
je ErrorMesg


ll_1:
push 0500h
pop es
xor di,di


@@:
;push bx
add bx,1fh            ;LBA = CLASTER + 1Fh
;push es
;push di
call readsect         ;������ ������
;pop di
sub bx,0x1F
;pop es
;pop bx
add di,0200h
call Get_next_claster ;��� ��������� �������
cmp bx,0FFFh          ;���� ������� �� ���������
jne @b                ;�� ������ ���
ll_3:
nop
nop
ll_5:
;��� �������� ����� ������������ ���
;������� ������� ������
;mov  [ll_1 + 1], word 0xD00 ;������� ���� = 0xD00
;mov  [ll_2 + 1], word kernelname
;mov  [ll_3], byte 0xEB
;mov  [ll_3 + 1], byte ll_4  - ll_5
;mov  [ErrorMesg + 1],word ERR13
;jmp ll
ll_4:
call 0x500:0000










ErrorMesg:            ;���� ������
mov si,ERR10
call print            ;������� ���������
jmp $                 ;� �������� =)

;���������� � BX ������ ������� �����
;ES:DI = ��� �����
Get_First_Claster:
push    ds
pusha
push    es
push    00050h
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
mov     dl, [ADrive]
int     13h
popa
pop     ds
pop     es
ret

;����� ASCIIZ ������
;ds:si ������
print:
mov ax,cs
mov ds,ax
lodsb
cmp al,0
je @_endp
mov ah,0eh
int 10h
jmp print
@_endp:
ret

ADrive          db 0
ERR10           db 'ERR#10',0
;ERR13           db 'ERR#13',0
;stdioname       db 'STDIO   BIN'
kernelname      db 'KERNEL  BIN'





