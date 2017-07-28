@echo off
yasm -fbin -DBIN crc32x.asm -ocrc32x.bin
yasm -fbin -DBIN crc32x_intel.asm -ocrc32x_intel.bin
yasm -fwin32 crc32x.asm -ocrc32x.obj
yasm -fwin32 crc32x_intel.asm -ocrc32x_intel.obj
cl /Os /O2 /GS- /Fa /c crc32.c
jwasm -bin crc32.asm
cl /DTEST /Os /O2 /GS- crc32.c crc32x.obj crc32x_intel.obj