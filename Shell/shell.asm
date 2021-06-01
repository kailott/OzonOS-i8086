org 100h
start:
call set_int20h





push cs
pop es


@next:
call erase_key
push cs
pop es
push cs
pop ds
;Выводим приглошение
mov ah,01h
mov di,greeting
int 21h
mov ah,01h
mov di,direct
int 21h

mov ah,0eh
mov al,'>'
int 10h

;Приглашение вывели
;читаем команду
;int 21h
;Функция 04h чтение строки с клавиатуры, ES:DI = буффер
mov ah,04h
push cs
pop es
mov di,entcom
int 21h
;Получили строку
;Приведем ее к стандарту
push cs
pop es
mov di,entcom
call NormCom
;Теперь определим что за это команда
call DefCom
push cs
pop ds
push ax
call NewStr
pop ax
;В АХ идентификатор команды
;Обработчик команд RUNCOM
call RUNCOM
;обработали, вернемся в начало

;Очистим буфер
mov di,entcom
mov cx,30h
call clear

call NewStr
push cs
pop ds
push cs
pop es
jmp @next

;Для хоть какой-то совместимости с DOS
set_int20h:
cli			  ;Запретим прерывания
pushf			  ;Сохраним флаги
push 0
pop es
mov di,20h*4
mov [es:di],word _int20h
mov di,20h*4+2
mov [es:di],cs
sti
popf
ret

_int20h:
;Выход из программы
pop ax
pop ax
pop ax
pop ax
pop ax
pop ax
jmp _retShell








include 'utilit.inc'
include 'obrcom.inc'
include 'data.inc'


