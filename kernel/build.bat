cd ..\tools
set PATH=%PATH%;%CD%\GNU_C;%CD%\GNU_C\BIN;%CD%\GNU_C\LIB;%CD%\GNU_C\LIB\gcc-lib\i586-elf-gnu\egcs-2.91.66
set FASMPATH=%CD%\fasm
cd ..\kernel
gcc -c -ffreestanding -o main.o main.c
%FASMPATH%\fasm kernel.asm 
%FASMPATH%\fasm libc.asm
%FASMPATH%\fasm mm.asm
ld --oformat=binary  -T kernel.ld -o kernel.bin kernel.o libc.o mm.o main.o 
echo done 
pause