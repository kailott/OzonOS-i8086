RUNCOM:
cmp ax,00
je noCom
cmp ax,01h
je _01h
cmp ax,02h
je _02h
cmp ax,03h
je _03h
cmp ax,04h
je _04h
cmp ax,05h
je _05h
cmp ax,06h
je _06h
cmp ax,07h
je _07h
ret

_01h:
mov ah,05h
int 25h
mov ax,word [es:di]
mov si,word [es:di+2]
mov es,ax
mov di,si
@@:
mov al,byte [es:di]
cmp al,0
je @endprintdir
cmp al,'.'
je _nextprtdir
cmp al,'A'
je _nextprtdir
cmp al,0e5h
je _nextprtdir
call NewStr
call print
_nextprtdir:
add di,20h
jmp @b
@endprintdir:
ret
;����� 11 ��������
print:
push di
xor cx,cx
@@:
mov al,byte [es:di]
mov ah,0eh
int 10h
inc di
inc cl
cmp cl,11
jne @b
pop di
ret




_02h:
mov ax,03h
int 10h
ret



_03h:
pusha
push cs
pop es
mov di,_dirmsg
mov ah,01h
int 21h
mov di,entcom
mov cx,30h
call clear
mov di,entcom
mov ah,04h
int 21h
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;� entcom ��� �����
_nextcurdir:
cmp bx,0ECh
jne _error
;��������� ���������� �� �����
;int 25h
;���������: ES:DI = ��� �����
push cs
pop es
mov di,entcom
mov ah,02h
int 25h
cmp bx,-1
je _dirnot
;���� ��� ���� ����������
;������
;int 25h
;04h ������ ������� ���������
;���������:es:di = buffer  BX = ������ ������� �������
push cs
pop es
push cs
pop ds
mov di,dir
add di,[dirpoint]
mov ah,04h
int 25h
;���������
mov ah,05h
int 25h
push cs
pop ds
mov ax,dir
add ax,[dirpoint]
mov [es:di],word cs
add di,2
mov [es:di],word ax
;�������� � ����
push cs
pop es
mov di,entcom
call write_dir
popa
add [dirpoint],400h
ret

_error:
push cs
pop es
call NewStr
mov ah,01h
mov di,_errormsg
int 21h
popa
ret
_dirnot:
push cs
pop es
call NewStr
mov di,_dirnotfound
mov ah,01h
int 21h
popa
ret


_04h:
;RUN
pusha
push cs
pop es
mov di,_runmsg
mov ah,01h
int 21h
mov di,entcom
mov cx,30h
call clear
mov di,entcom
mov ah,04h
int 21h
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;� entcom ��� �����
_nextruntask:
cmp bx,0EFh
jne _errorrun

;��������� ���������� ����
;int 25h
;���������: ES:DI = ��� �����
;�������
;CX = ������ ����� � ���������  �� = ������ ������� �����
push cs
pop es
mov di,entcom
mov ah,02h
int 25h
cmp bx,-1
je _tasknot
;���� ��� ���� ����������
;������
;int 25h
;04h ������ ������� ���������
;���������:es:di = buffer  BX = ������ ������� �������
push cs
pop es
push cs
pop ds
push bx
;������� �������
mov ah,01h
int 0F5h
pop bx
;mov ax,0x3000
push ax

mov es,ax  ;[segpoint]

mov di,0100h
mov ah,04h
int 25h
;���������
call NewStr

pop ax
mov cx,ax

;add [segpoint],1000h
;����� �� ������� CX:0000 ������� retf
mov ax,cx
mov es,ax
mov al,[_retf]
mov [es:0],byte al


;���������� �������� ��� �������� ����������
;� �� ������ �������� � ������� ���������� ���������
;������ �������� ���� ��������� ����������
mov [stackseg],ss
mov [stackoff],sp
mov ax,cx
cli
mov ss,ax
mov ax,0FFFEh
mov sp,ax
sti

;�������� � ���� ������ ��������
push cs
push word _retShell
;� ���� ������ �� �������� �������� ����������
push word 0

;push 0x3000
push cx
push 0100h
;�������� ��������
mov ax,cx
mov ds,ax
mov es,ax
xor di,di
xor si,si
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
;� �������� ����������
retf

_retShell:
;����� �������� ��������� ����
push cs
pop ds
cli
mov ax,[stackseg]
mov ss,ax
mov ax,[stackoff]
mov sp,ax
sti
;��������� ������
;int f5h
;02h
;���������� ������
;� cx ���������� ���������� ������� ���� ������

mov ah,02h
int 0f5h

popa
ret
_errorrun:
push cs
pop es
call NewStr
mov ah,01h
mov di,_errormsg
int 21h
popa
ret
_tasknot:
push cs
pop es
call NewStr
mov di,_tasknotfound
mov ah,01h
int 21h
popa
ret








_05h:
mov ax,cs
mov es,ax
mov di,help
mov ah,01h
int 21h
ret

_06h:
mov ah,05h
int 25h
mov ax,word [es:di]
cmp ax,0050h
je _endupdir
call deldir
mov ax,dir
cmp [dirpoint],0
je  _rootdir
cmp [dirpoint],400h
je  _rootdir
sub [dirpoint],800h
add ax,[dirpoint]
mov [es:di],word cs
add di,2
mov [es:di],word ax
ret
_rootdir:
mov ah,05h
int 25h
mov [es:di],word 0050h
add di,2
mov [es:di],word 02400h
_endupdir:
ret




_07h:
xor ax,ax
mov ds,ax
mov ax,5304h
xor bx,bx
int 15h
push ax
mov ax,05301h
xor bx,bx
int 15h
mov ax,5308h
mov bx,1
mov cx,bx
int 15h
mov ax,530Dh
mov bx,1
mov cx,bx
int 15h
mov ax,530Fh
mov bx,1
mov cx,bx
int 15h
mov ax,5307h
mov bx,1
mov cx,3
int 15h
ret







noCom:
pusha
mov ax,cs
mov es,ax
mov di,entcom
call NormCom
mov di,entcom
call FileNameNorm
;� entcom ��� �����
cmp bx,0ECh
jne @f

jmp _nextcurdir
@@:
jmp _nextruntask






stackseg	dw	0
stackoff	dw	0
_dirmsg 	db	'Enter  dir name : ',0
_errormsg	db	'Value of range',0
_dirnotfound	db	'Directory not found',0
_runmsg 	db	'Enter file name : ',0
_tasknotfound	db	'Task not found',0
_retf		db	0CBh
help		db	'DIR displays the contents of a folder',0Ah,0Dh
		db	'CLS clear screen',0Ah,0Dh
		db	'CD change directory',0Ah,0Dh
		db	'RUN start task',0Ah,0Dh
		db	'UP rise to the directory above',0Ah,0Dh
		db	'OFF power off',0Ah,0Dh,0




