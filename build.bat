set ROOT=%CD%
del %ROOT%\bin\*.bin
cd tools/fasm
fasm.exe ../../boot/bootsec.asm  ../../bin/bootsec.bin
fasm.exe ../../loader/loader.asm  ../../bin/loader.bin
fasm.exe ../../fatdrv/fatdrv.asm  ../../bin/fatdrv.bin
cd %ROOT%\kernel
call build.bat
copy kernel.bin %ROOT%\bin\kernel.bin
@echo
pause