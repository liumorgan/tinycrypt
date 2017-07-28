	.file	"rc5.c"
	.intel_syntax noprefix
	.text
	.globl	rc5_setkey
	.type	rc5_setkey, @function
rc5_setkey:
.LFB10:
	.cfi_startproc
	xor	eax, eax
.L3:
	mov	edx, DWORD PTR [rsi+rax]
	mov	DWORD PTR [rsp-16+rax], edx
	add	rax, 4
	cmp	rax, 16
	jne	.L3
	mov	rdx, rdi
	mov	eax, -1209970333
.L5:
	mov	DWORD PTR [rdx], eax
	sub	eax, 1640531527
	add	rdx, 4
	cmp	eax, -914117075
	jne	.L5
	mov	r9d, 78
	xor	ecx, ecx
	xor	esi, esi
	xor	r8d, r8d
	xor	edx, edx
	mov	r10d, 26
.L7:
	mov	eax, edx
	lea	rax, [rdi+rax*4]
	mov	r11d, DWORD PTR [rax]
	add	r11d, ecx
	add	esi, r11d
	ror	esi, 29
	mov	DWORD PTR [rax], esi
	mov	eax, r8d
	inc	r8d
	mov	r11d, DWORD PTR [rsp-16+rax*4]
	and	r8d, 3
	add	r11d, ecx
	add	ecx, esi
	add	r11d, esi
	rol	r11d, cl
	mov	DWORD PTR [rsp-16+rax*4], r11d
	lea	eax, [rdx+1]
	xor	edx, edx
	mov	ecx, r11d
	div	r10d
	dec	r9d
	jne	.L7
	ret
	.cfi_endproc
.LFE10:
	.size	rc5_setkey, .-rc5_setkey
	.globl	rc5_crypt
	.type	rc5_crypt, @function
rc5_crypt:
.LFB11:
	.cfi_startproc
	mov	r9d, ecx
	mov	r8d, DWORD PTR [rsi]
	mov	ecx, DWORD PTR [rsi+4]
	cmp	r9d, 1
	lea	rsi, [rdi+100]
	jne	.L11
	add	r8d, DWORD PTR [rdi]
	add	ecx, DWORD PTR [rdi+4]
	lea	rsi, [rdi+8]
.L11:
	mov	r10d, 24
.L15:
	cmp	r9d, 1
	jne	.L12
	mov	edi, r8d
	add	rsi, 4
	mov	r8d, ecx
	xor	edi, ecx
	rol	edi, cl
	add	edi, DWORD PTR [rsi-4]
	mov	ecx, edi
	jmp	.L13
.L12:
	sub	ecx, DWORD PTR [rsi]
	sub	rsi, 4
	mov	edi, ecx
	mov	cl, r8b
	ror	edi, cl
	mov	ecx, r8d
	xor	r8d, edi
.L13:
	dec	r10d
	jne	.L15
	test	r9d, r9d
	jne	.L16
	sub	ecx, DWORD PTR [rsi]
	sub	r8d, DWORD PTR [rsi-4]
.L16:
	mov	DWORD PTR [rdx], r8d
	mov	DWORD PTR [rdx+4], ecx
	ret
	.cfi_endproc
.LFE11:
	.size	rc5_crypt, .-rc5_crypt
	.ident	"GCC: (Ubuntu 4.8.4-2ubuntu1~14.04.3) 4.8.4"
	.section	.note.GNU-stack,"",@progbits
