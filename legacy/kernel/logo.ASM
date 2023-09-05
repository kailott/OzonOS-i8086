Logo:
pusha
push cs
pop es
mov di,_str1
call print
mov di,_str2
call print
mov ah,00h
int 21h

pusha
call print_hex
popa
call NewStr
mov di,_str3
call print
mov ah,00h
int 25h
pusha
call print_hex
popa
call NewStr
call _CPUIDproc
mov di,_CPUID
call print
popa
ret


_CPUIDproc:
mov si,_CPUID
mov eax,80000002h
@@:
push eax
cpuid
mov [es:si],dword eax
add si,4
mov [es:si],dword ebx
add si,4
mov [es:si],dword ecx
add si,4
mov [es:si],dword edx
add si,4
pop eax
inc eax
cmp eax,80000005h
jne @b
sub si,3
mov [es:si],word 0A0Dh
mov di,_CPUID
ret






_str1	db	'Ozon Operating System v.0.03,Lapardin Roman, 2012',0ah,0dh,0
_str2	db	'STDIO Driver version 0x',0
_str3	db	'FAT12 Driver version 0x',0
_CPUID	db	100h dup (0)