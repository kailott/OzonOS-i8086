;ram driver
DEFINE RAM_BASE 0x100000
RAM_DATA dd 0x0
;RAM_BASE dd 0x0
RAM_ROOT dd 0x0
RAM_FAT dd 0x0
RAM_DATA_START_Sect dd 0x0
RAM_ROOT_Entry dd 0x0
RAM_Cluster_Size dd 0x0

virtual at esi
BSP:
.jmpBoot rb 3
.OEMName rb 8
.BytesPerSec dw ?
.SecPerClus db ?
.RsvdSecCnt dw ?
.NumFATs db ?
.RootEntCnt dw ?
.TotSec16  dw ?
.Media db ?
.FATSz16 dw ?
.SecPerTrk dw ?
.NumHeads dw ?
.HiddenSec dd ?
.TotSec32 dd ?
end virtual


virtual at ESI
FILE_STRUCT:
.Name rb 11
.Attr db ?
.NTRes db ?
.CrtTimeTenth db ?
.CrtTime      dw ?
.CrtDate      dw ?
.LstAccDate   dw ?
.FstClasHi    dw ?
.WrtTime      dw ?
.WrtDate      dw ?
.FstClusLo    dw ?
.FileSize     dd ?
end virtual

RAMDRIVE:
.init:
mov esi,RAM_BASE
xor eax,eax
;Вычислим размер корневого каталога  в секторах
;(Количество элементов * 32) / 512
mov ax,[BSP.RootEntCnt]
mov [RAM_ROOT_Entry],eax
shr eax,4
;Теперь прибавляем сектора под fat умноженные на 2
xor ebx,ebx
mov bx,[BSP.FATSz16]
shl bx,1
add eax,ebx
;+ 1 boot сектор
inc eax
mov [RAM_DATA_START_Sect],eax

xor eax,eax
mov ax,[BSP.FATSz16]
shl eax,9
add eax,0x200
add eax,esi
mov [RAM_ROOT],eax
xor eax,eax
mov al,[BSP.SecPerClus]
shl eax,9
mov [RAM_Cluster_Size],eax

ret

;Поиск файла в корневом каталоге
;Имя файла в ESI
;Возвращает в ESI указатель на структуру FILE
;0 если нет такого файла
.find_file:
push ecx
push edi
push eax
push ebx
mov edi,[RAM_ROOT]
mov ebx,[RAM_ROOT_Entry]
@@:
dec ebx
jz .error_file_name
push edi
push esi
mov ecx,11
rep cmpsb
pop esi
pop edi
test    ecx,ecx
jz     .file_find
add edi, 32
jmp @b
.error_file_name:
mov edi,0
.file_find:
mov esi,edi
pop ebx
pop eax
pop edi
pop ecx
ret;





.readfile:
;Чтение файла
;В Esi - имя файла
;В edi - Адрес буфера
call .find_file
xor eax,eax
mov ax,[FILE_STRUCT.FstClusLo]
sub ax,2
shl eax,2 ; =* умножить на секторов на кластер
add eax,[RAM_DATA_START_Sect]
shl eax,9
add eax,RAM_BASE
mov esi,eax
mov ecx, 0x400
rep movsb

ret






