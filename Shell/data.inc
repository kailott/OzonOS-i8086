;Команды Ozon Os
comands:
db  'DIR',0,0,0,0,0,00,01h
db  'CLS',0,0,0,0,0,00,02h
db  'CD',0,0,0,0,0,0,00,03h
db  'RUN',0,0,0,0,0,00,04h
db  'HELP',0,0,0,0,00,05h
db  '?',0,0,0,0,0,0,0,00,05h
db  'UP',0,0,0,0,0,0,00,06h
db  'OFF',0,0,0,0,0,00,07h
db  'VER',0,0,0,0,0,00,08h
db  'A:\',0,0,0,0,0,00,09h
db  'B:\',0,0,0,0,0,00,0Ah
db  'ROOT',0,0,0,0,0,0Bh
db  'RM',0,0,0,0,0,0,00,0Ch
comend	     dw   $
ErrorRun     db   'Error! Shell.com running!',0
_DriveA      db   'A:\',0
_DriveB      db   'B:\',0


dirpoint     dw   0
segpoint     dw   0
drivef	     db   0
direct	     db   50h	dup	(0)  ;Путь к директории
entcom	     db   30h	dup	(0)  ;введеная строка
dir	     dw   0		     ;Здесь начинаются таблицы директорий


