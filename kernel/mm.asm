format ELF
DEFINE k_heap_ptr k_heap
DEFINE k_heap_size 0x1000
DEFINE k_rw_cycle 100
;�������� ������ Ozon Os
include 'proc32.inc'

public k_split
public k_defrag
public k_alloc_init

macro slock SEMAPHORE
{
@@:
bt dword [SEMAPHORE], 0
jnc @b
lock btr dword [SEMAPHORE], 0
jnc @b
}

macro sfree SEMAPHORE
{
lock bts dword [SEMAPHORE], 0
}

virtual at esi
block_header:
.flags dw ?  ; +0
.size dd ?  ;  +2 ������ ����� ������ �� ����� .data:
.next_ptr dd ? ;+6
sizeof.block_header = $ - block_header
name equ sizeof.block_header
.data:        ;+10
end virtual


section ".text" executable


proc k_alloc_init c
push esi
mov esi,k_heap_ptr
mov eax,k_heap_size
sub eax,sizeof.block_header
mov [block_header.size],eax
mov [block_header.next_ptr],0xFFFFFFFF
pop esi
ret
endp


;

proc k_alloc

endp
;



;�������� �� ����� �� �������� block ����� �������� size
;���������� ��������� �� ����� ����
proc k_split c block,size
push esi
push ebx
mov esi,[block]
;�������� ������ ��������� �� ��������� ����
push [block_header.next_ptr]
;��������� ����� ������ ������ �����
mov ebx,[size]
sub [block_header.size],ebx
sub [block_header.size],sizeof.block_header
;����� ��������� �� ��������� �������
mov eax,esi
add eax,sizeof.block_header
;mov eax,block_header.data
add eax,[block_header.size]
mov [block_header.next_ptr], eax
mov esi,eax
;�������� ��������� �� ���������
pop [block_header.next_ptr]
;������ �����
mov eax,[size]
mov [block_header.size],eax
mov eax,esi
pop ebx
pop esi
endp



;��������� �������������� ����
;���� ��� ��������� �����
;� ���� ��� ��������� ����� ���� ���� �� ������ �� ���������� ��
proc k_defrag c
push esi
push ebx
push ecx
mov esi,k_heap_ptr
.main_loop:
cmp [block_header.flags],0
jne .goto_next
;�������� ��������� ����
mov eax,[block_header.next_ptr]
cmp word [eax],0
je .sew_block




.goto_next:
mov eax,[block_header.next_ptr]
mov esi,eax
cmp [block_header.next_ptr],0xFFFFFFFF ; ������� ���������� �����
je .last_block
jmp .main_loop

;������� ��� ��������� ������ ������ ����� � ����
.sew_block:
;�������� ��� ������ �� ������
mov ebx,esi
add ebx,[block_header.size]
add ebx,sizeof.block_header
cmp ebx,eax
jne .goto_next
;���������
;�������
mov ebx,[eax + 6]
mov [block_header.next_ptr],ebx
mov ebx,[eax+2]
add ebx,sizeof.block_header
add [block_header.size],ebx
mov ecx,sizeof.block_header
@@:
mov byte [eax],0
inc eax
dec ecx
jnz @b
mov esi,k_heap_ptr
jmp .main_loop

.last_block:
pop ecx
pop ebx
pop esi
endp



section ".bss" executable

k_heap rb 0x1000




























