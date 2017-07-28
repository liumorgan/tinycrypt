@echo off
:yasm -DBIN -fbin nx.asm -onx.bin
:yasm -fwin32 nx.asm -onx.obj
cl /nologo /O2 /Os /GS- /c /Fa sparx.c
jwasm -nologo -bin sparx.asm
cl /nologo test.c sparx.c
del *.obj