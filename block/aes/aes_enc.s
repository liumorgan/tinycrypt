	.file	"aes_enc.c"
	.intel_syntax noprefix
	.text
	.globl	gf_mul2
	.type	gf_mul2, @function
gf_mul2:
.LFB10:
	.cfi_startproc
	mov	edx, edi
	and	edx, -2139062144
	mov	eax, edx
	xor	edi, edx
	shr	eax, 7
	add	edi, edi
	imul	eax, eax, 27
	xor	eax, edi
	ret
	.cfi_endproc
.LFE10:
	.size	gf_mul2, .-gf_mul2
	.globl	gf_mulinv
	.type	gf_mulinv, @function
gf_mulinv:
.LFB11:
	.cfi_startproc
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	test	dil, dil
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	mov	bl, dil
	je	.L3
	xor	r12d, r12d
	mov	bpl, 1
.L5:
	movzx	edi, bpl
	call	gf_mul2
	xor	ebp, eax
	cmp	bpl, bl
	je	.L4
	inc	r12d
	jmp	.L5
.L4:
	lea	ebp, [r12+2]
	mov	bl, 1
.L6:
	test	bpl, bpl
	je	.L3
	movzx	edi, bl
	inc	ebp
	call	gf_mul2
	xor	ebx, eax
	jmp	.L6
.L3:
	mov	al, bl
	pop	rbx
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE11:
	.size	gf_mulinv, .-gf_mulinv
	.globl	SubByte
	.type	SubByte, @function
SubByte:
.LFB12:
	.cfi_startproc
	movzx	edi, dil
	call	gf_mulinv
	mov	sil, al
	xor	eax, 99
	ror	sil, 7
	mov	cl, sil
	xor	eax, esi
	ror	cl, 7
	mov	dl, cl
	xor	eax, ecx
	ror	dl, 7
	xor	eax, edx
	ror	dl, 7
	xor	eax, edx
	ret
	.cfi_endproc
.LFE12:
	.size	SubByte, .-SubByte
	.globl	SubWord
	.type	SubWord, @function
SubWord:
.LFB13:
	.cfi_startproc
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	mov	r12d, edi
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	mov	bpl, 4
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	xor	ebx, ebx
.L13:
	movzx	edi, r12b
	shr	r12d, 8
	call	SubByte
	movzx	eax, al
	or	ebx, eax
	ror	ebx, 8
	dec	bpl
	jne	.L13
	mov	eax, ebx
	pop	rbx
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE13:
	.size	SubWord, .-SubWord
	.globl	SBSR
	.type	SBSR, @function
SBSR:
.LFB14:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	xor	ebp, ebp
	push	rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	mov	dl, BYTE PTR [rdi+5]
	mov	rbx, rdi
	mov	al, BYTE PTR [rdi+1]
	mov	BYTE PTR [rdi+1], dl
	mov	dl, BYTE PTR [rdi+9]
	mov	BYTE PTR [rdi+5], dl
	mov	dl, BYTE PTR [rdi+13]
	mov	BYTE PTR [rdi+13], al
	mov	al, BYTE PTR [rdi+10]
	mov	BYTE PTR [rdi+9], dl
	mov	dl, BYTE PTR [rdi+2]
	mov	BYTE PTR [rdi+2], al
	mov	al, BYTE PTR [rdi+3]
	mov	BYTE PTR [rdi+10], dl
	mov	dl, BYTE PTR [rdi+15]
	mov	BYTE PTR [rdi+3], dl
	mov	dl, BYTE PTR [rdi+11]
	mov	BYTE PTR [rdi+15], dl
	mov	dl, BYTE PTR [rdi+7]
	mov	BYTE PTR [rdi+7], al
	mov	al, BYTE PTR [rdi+14]
	mov	BYTE PTR [rdi+11], dl
	mov	dl, BYTE PTR [rdi+6]
	mov	BYTE PTR [rdi+6], al
	mov	BYTE PTR [rdi+14], dl
.L17:
	movzx	edi, BYTE PTR [rbx+rbp]
	call	SubByte
	mov	BYTE PTR [rbx+rbp], al
	inc	rbp
	cmp	rbp, 16
	jne	.L17
	pop	rbx
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE14:
	.size	SBSR, .-SBSR
	.globl	MixColumns
	.type	MixColumns, @function
MixColumns:
.LFB15:
	.cfi_startproc
	push	r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	mov	r13, rdi
	push	r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	push	rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	push	rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	xor	ebx, ebx
.L21:
	mov	ebp, DWORD PTR [r13+0+rbx]
	mov	r12d, ebp
	ror	r12d, 8
	mov	edi, r12d
	xor	edi, ebp
	call	gf_mul2
	mov	edx, ebp
	ror	ebp, 24
	ror	edx, 16
	xor	edx, r12d
	xor	edx, eax
	xor	edx, ebp
	mov	DWORD PTR [r13+0+rbx], edx
	add	rbx, 4
	cmp	rbx, 16
	jne	.L21
	pop	rbx
	.cfi_def_cfa_offset 32
	pop	rbp
	.cfi_def_cfa_offset 24
	pop	r12
	.cfi_def_cfa_offset 16
	pop	r13
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE15:
	.size	MixColumns, .-MixColumns
	.globl	AddRoundKey
	.type	AddRoundKey, @function
AddRoundKey:
.LFB16:
	.cfi_startproc
	sal	edx, 2
	xor	eax, eax
.L25:
	lea	ecx, [rdx+rax]
	mov	ecx, DWORD PTR [rdi+rcx*4]
	xor	DWORD PTR [rsi+rax*4], ecx
	inc	rax
	cmp	rax, 4
	jne	.L25
	ret
	.cfi_endproc
.LFE16:
	.size	AddRoundKey, .-AddRoundKey
	.globl	aes_setkey
	.type	aes_setkey, @function
aes_setkey:
.LFB17:
	.cfi_startproc
	xor	eax, eax
.L28:
	mov	edx, DWORD PTR [rsi+rax]
	mov	DWORD PTR [rdi+rax], edx
	add	rax, 4
	cmp	rax, 32
	jne	.L28
	push	r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	mov	r13d, 1
	push	r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	lea	r12, [rdi+28]
	push	rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	mov	ebp, 8
	push	rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
.L32:
	mov	eax, ebp
	mov	ebx, DWORD PTR [r12]
	and	eax, 7
	jne	.L29
	mov	edi, ebx
	ror	edi, 8
	call	SubWord
	mov	edi, r13d
	mov	ebx, eax
	xor	ebx, r13d
	call	gf_mul2
	mov	r13d, eax
	jmp	.L30
.L29:
	cmp	eax, 4
	jne	.L30
	mov	edi, ebx
	call	SubWord
	mov	ebx, eax
.L30:
	xor	ebx, DWORD PTR [r12-28]
	inc	ebp
	add	r12, 4
	mov	DWORD PTR [r12], ebx
	cmp	ebp, 60
	jne	.L32
	pop	rbx
	.cfi_restore 3
	.cfi_def_cfa_offset 32
	pop	rbp
	.cfi_restore 6
	.cfi_def_cfa_offset 24
	pop	r12
	.cfi_restore 12
	.cfi_def_cfa_offset 16
	pop	r13
	.cfi_restore 13
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE17:
	.size	aes_setkey, .-aes_setkey
	.globl	aes_enc
	.type	aes_enc, @function
aes_enc:
.LFB18:
	.cfi_startproc
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	xor	edx, edx
	mov	r12, rdi
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	mov	ebp, 1
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	mov	rbx, rsi
	call	AddRoundKey
.L36:
	mov	rdi, rbx
	call	SBSR
	mov	rdi, rbx
	call	MixColumns
	mov	edx, ebp
	mov	rsi, rbx
	mov	rdi, r12
	inc	ebp
	call	AddRoundKey
	cmp	ebp, 14
	jne	.L36
	mov	rdi, rbx
	call	SBSR
	mov	rsi, rbx
	mov	rdi, r12
	mov	edx, 14
	pop	rbx
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	jmp	AddRoundKey
	.cfi_endproc
.LFE18:
	.size	aes_enc, .-aes_enc
	.ident	"GCC: (Ubuntu 4.8.4-2ubuntu1~14.04.3) 4.8.4"
	.section	.note.GNU-stack,"",@progbits
