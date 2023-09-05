format ELF
DEFINE k_heap_ptr k_heap
DEFINE k_heap_size 0x1000
DEFINE k_rw_cycle 100
;Менеджер памяти Ozon Os
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
.size dd ?  ;  +2 Размер блока данных по метке .data:
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



;Отделяет от блока по смещение block кусок размером size
;Возвращает указатель на новый блок
proc k_split c block,size
push esi
push ebx
mov esi,[block]
;сохраним старый указатель на следующий блок
push [block_header.next_ptr]
;расчитаем новый размер данных блока
mov ebx,[size]
sub [block_header.size],ebx
sub [block_header.size],sizeof.block_header
;Новый указатель на следующий элемент
mov eax,esi
add eax,sizeof.block_header
;mov eax,block_header.data
add eax,[block_header.size]
mov [block_header.next_ptr], eax
mov esi,eax
;извлечем указатель на следующий
pop [block_header.next_ptr]
;Размер блока
mov eax,[size]
mov [block_header.size],eax
mov eax,esi
pop ebx
pop esi
endp



;Процедура дефрагментации кучи
;Ищем все свободные блоки
;И если два свободных блока идут друг за другом то объединяем их
proc k_defrag c
push esi
push ebx
push ecx
mov esi,k_heap_ptr
.main_loop:
cmp [block_header.flags],0
jne .goto_next
;проверим следующий блок
mov eax,[block_header.next_ptr]
cmp word [eax],0
je .sew_block




.goto_next:
mov eax,[block_header.next_ptr]
mov esi,eax
cmp [block_header.next_ptr],0xFFFFFFFF ; Признак последнего блока
je .last_block
jmp .main_loop

;сшивает два свободных идущих подряд блока в один
.sew_block:
;Убедимся что адреса не уехали
mov ebx,esi
add ebx,[block_header.size]
add ebx,sizeof.block_header
cmp ebx,eax
jne .goto_next
;Проверили
;Сшиваем
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




























