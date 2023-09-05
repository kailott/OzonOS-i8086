@stdio_err:
push cs
pop es
mov di,STDload_err
call print
jmp $
@shell_err:
push cs
pop es
mov di,Shell_load_err
call print
jmp $