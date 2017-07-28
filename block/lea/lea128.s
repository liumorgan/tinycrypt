	.file	"lea128.c"
	.intel_syntax noprefix
	.text
	.globl	lea_setkey
	.type	lea_setkey, @function
lea_setkey:
.LFB10:
	.cfi_startproc
	mov	r9d, DWORD PTR [rdi]
	mov	r8d, DWORD PTR [rdi+4]
	mov	ecx, DWORD PTR [rdi+8]
	mov	edx, DWORD PTR [rdi+12]
	xor	edi, edi
	mov	DWORD PTR [rsp-16], -1007687205
	mov	DWORD PTR [rsp-12], -2000366076
	mov	DWORD PTR [rsp-8], -410389975
	mov	DWORD PTR [rsp-4], -956725405
.L3:
	mov	r10d, edi
	inc	edi
	add	rsi, 16
	and	r10d, 3
	mov	eax, DWORD PTR [rsp-16+r10*4]
	mov	r11d, eax
	lea	r8d, [r8+rax*2]
	lea	ecx, [rcx+rax*4]
	ror	r11d, 28
	lea	edx, [rdx+rax*8]
	add	r9d, eax
	mov	DWORD PTR [rsp-16+r10*4], r11d
	mov	r10d, eax
	ror	r9d, 31
	shr	r10d, 31
	mov	DWORD PTR [rsi-16], r9d
	or	r8d, r10d
	mov	r10d, eax
	shr	eax, 29
	shr	r10d, 30
	or	edx, eax
	ror	r8d, 29
	or	ecx, r10d
	ror	edx, 21
	mov	DWORD PTR [rsi-12], r8d
	ror	ecx, 26
	mov	DWORD PTR [rsi-4], edx
	mov	DWORD PTR [rsi-8], ecx
	cmp	edi, 24
	jne	.L3
	ret
	.cfi_endproc
.LFE10:
	.size	lea_setkey, .-lea_setkey
	.globl	lea_encrypt
	.type	lea_encrypt, @function
lea_encrypt:
.LFB11:
	.cfi_startproc
	push	rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	mov	eax, DWORD PTR [rsi]
	lea	rbx, [rdi+384]
	mov	r9d, DWORD PTR [rsi+4]
	mov	r10d, DWORD PTR [rsi+8]
	mov	r11d, DWORD PTR [rsi+12]
.L7:
	mov	r8d, DWORD PTR [rdi+4]
	mov	ecx, DWORD PTR [rdi+12]
	add	rdi, 16
	xor	r11d, r8d
	xor	ecx, r10d
	xor	r10d, r8d
	lea	edx, [r11+rcx]
	mov	r11d, DWORD PTR [rdi-8]
	xor	r8d, r9d
	ror	edx, 3
	xor	r11d, r9d
	lea	ecx, [r10+r11]
	mov	r10d, DWORD PTR [rdi-16]
	ror	ecx, 5
	xor	r10d, eax
	add	r8d, r10d
	ror	r8d, 23
	cmp	rdi, rbx
	je	.L6
	mov	r11d, eax
	mov	r10d, edx
	mov	r9d, ecx
	mov	eax, r8d
	jmp	.L7
.L6:
	mov	DWORD PTR [rsi+4], ecx
	mov	DWORD PTR [rsi+8], edx
	mov	DWORD PTR [rsi+12], eax
	mov	DWORD PTR [rsi], r8d
	pop	rbx
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE11:
	.size	lea_encrypt, .-lea_encrypt
	.ident	"GCC: (Ubuntu 4.8.4-2ubuntu1~14.04.3) 4.8.4"
	.section	.note.GNU-stack,"",@progbits
