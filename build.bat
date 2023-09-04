cd tools/fasm
fasm.exe ../../boot/fddboot.asm  ../../bin/bootsec.bin
fasm.exe ../../kernel/kernel.asm  ../../bin/kernel.bin
fasm.exe ../../kernel/stdio.asm  ../../bin/stdio.bin
fasm.exe ../../fatdrv/fatdrv.asm  ../../bin/fatdrv.bin
fasm.exe ../../shell/shell.asm  ../../bin/shell.com
@echo
pause