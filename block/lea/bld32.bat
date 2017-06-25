@echo off
yasm -fbin -DBIN lx.asm -olx.bin
yasm -fwin32 lx.asm -olx.obj
cl test.c lx.obj
del *.obj