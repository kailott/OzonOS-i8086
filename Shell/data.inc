;������� Ozon Os
comands:
db  'DIR',0,0,0,0,0,00,01h
db  'CLS',0,0,0,0,0,00,02h
db  'CD',0,0,0,0,0,0,00,03h
db  'RUN',0,0,0,0,0,00,04h
db  'HELP',0,0,0,0,00,05h
db  'UP',0,0,0,0,0,0,00,06h
db  'OFF',0,0,0,0,0,00,07h
comend	     dw   $
greeting     db   '%ROOT%\',0




dirpoint     dw   0
segpoint     dw   0
direct	     db   50h	dup	(0)  ;���� � ����������
entcom	     db   30h	dup	(0)  ;�������� ������
dir	     dw   0		     ;����� ���������� ������� ����������

