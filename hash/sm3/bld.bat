@echo off
cl /O2 /Os /Fa /c /GS- sm3.c
yasm -DBIN -fbin s3.asm -os3.bin
yasm -fwin32 s3.asm -os3.obj
jwasm -bin sm3.asm
cl /O2 /Os /GS- test.c sm3.c s3.obj
del *.obj