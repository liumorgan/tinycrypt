@echo off
yasm -fbin -DBIN ck.asm -ock.bin
cl /nologo /O2 /Os /GS- /c /Fa chaskey.c
jwasm -bin -nologo chaskey.asm
yasm -fwin32 ck.asm -ock.obj
cl /nologo test.c chaskey.c ck.obj
del *.obj