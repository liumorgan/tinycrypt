@echo off
yasm -DBIN -fbin lmx%1.asm -olmx%1.bin
yasm -fwin%1 lmx%1.asm -olmx%1.obj
cl /nologo /O2 /Os /GS- /Fa /c lightmac%1.c
:jwasm -nologo -bin lightmac%1.asm
cl /nologo /DTEST /DUSE_ASM test.c lightmac%1.obj lmx%1.obj
del *.obj lightmac51.asm