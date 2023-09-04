org 0
start:
call set_vmode
call set_memory_int
include 'init.asm'



call Logo
call load_shell
jmp $


include 'memory.asm'
include 'logo.asm'
include 'display.inc'
include 'error.asm'
include 'loadshell.asm'
include 'data.inc'






