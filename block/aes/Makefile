msvc:
		cl /nologo /O2 /Ot /DTEST test.c aes.c aes_enc.c
compact:
		cl /nologo /O2 /Ot /DTEST test.c aes_enc.c
all:
		gcc -DTEST -Wall -O2 test.c aes.c -otest	 