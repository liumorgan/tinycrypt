	.cpu arm7tdmi
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 2
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"aes.c"
	.text
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	gf_mulinv.part.0, %function
gf_mulinv.part.0:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	cmp	r0, #3
	str	lr, [sp, #-4]!
	beq	.L6
	mov	r3, #0
	mov	r2, #3
	ldr	lr, .L14
	b	.L3
.L7:
	mov	r3, r1
.L3:
	lsr	ip, r2, #7
	lsl	r1, ip, #1
	add	r1, r1, ip
	add	r1, r1, r1, lsl #3
	and	ip, lr, r2, lsl #1
	eor	r1, r1, ip
	eor	r2, r2, r1
	and	r2, r2, #255
	add	r1, r3, #1
	cmp	r2, r0
	and	r1, r1, #255
	bne	.L7
	add	r3, r3, #3
	ands	r3, r3, #255
	beq	.L13
.L2:
	mov	r0, #1
	ldr	ip, .L14
.L5:
	lsr	r1, r0, #7
	lsl	r2, r1, #1
	add	r2, r2, r1
	add	r2, r2, r2, lsl #3
	and	r1, ip, r0, lsl #1
	add	r3, r3, #1
	eor	r2, r2, r1
	eor	r0, r0, r2
	ands	r3, r3, #255
	and	r0, r0, #255
	bne	.L5
.L4:
	ldr	lr, [sp], #4
	bx	lr
.L6:
	mov	r3, #2
	b	.L2
.L13:
	mov	r0, #1
	b	.L4
.L15:
	.align	2
.L14:
	.word	-16843010
	.size	gf_mulinv.part.0, .-gf_mulinv.part.0
	.align	2
	.syntax unified
	.arm
	.fpu softvfp
	.type	SubByte.part.1, %function
SubByte.part.1:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	subs	r2, r0, #0
	push	{r4, lr}
	bne	.L22
.L17:
	and	r3, r2, #255
	lsr	r0, r3, #7
	eor	r1, r2, #99
	lsr	ip, r3, #6
	orr	r0, r0, r2, lsl #1
	eor	r0, r0, r1
	orr	ip, ip, r2, lsl #2
	lsr	r1, r3, #5
	eor	r0, r0, ip
	orr	r1, r1, r2, lsl #3
	lsr	r3, r3, #4
	eor	r0, r0, r1
	orr	r3, r3, r2, lsl #4
	eor	r0, r0, r3
	and	r0, r0, #255
	pop	{r4, lr}
	bx	lr
.L22:
	bl	gf_mulinv.part.0
	mov	r2, r0
	b	.L17
	.size	SubByte.part.1, .-SubByte.part.1
	.align	2
	.global	gf_mul2
	.syntax unified
	.arm
	.fpu softvfp
	.type	gf_mul2, %function
gf_mul2:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	r3, .L24
	ldr	r2, .L24+4
	and	r3, r3, r0, lsr #7
	add	r3, r3, r3, lsl #1
	add	r3, r3, r3, lsl #3
	and	r0, r2, r0, lsl #1
	eor	r0, r0, r3
	bx	lr
.L25:
	.align	2
.L24:
	.word	16843009
	.word	-16843010
	.size	gf_mul2, .-gf_mul2
	.align	2
	.global	gf_mulinv
	.syntax unified
	.arm
	.fpu softvfp
	.type	gf_mulinv, %function
gf_mulinv:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	cmp	r0, #0
	bxeq	lr
	b	gf_mulinv.part.0
	.size	gf_mulinv, .-gf_mulinv
	.align	2
	.global	SubByte
	.syntax unified
	.arm
	.fpu softvfp
	.type	SubByte, %function
SubByte:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	cmp	r1, #1
	beq	.L31
	eor	r3, r0, #99
	lsr	r0, r3, #7
	lsr	r1, r3, #5
	orr	r0, r0, r3, lsl #1
	orr	r1, r1, r3, lsl #3
	lsl	r2, r3, #6
	eor	r0, r0, r1
	orr	r3, r2, r3, lsr #2
	and	r0, r0, #255
	and	r3, r3, #255
	cmp	r0, r3
	eor	r0, r0, r3
	bxeq	lr
	b	gf_mulinv.part.0
.L31:
	b	SubByte.part.1
	.size	SubByte, .-SubByte
	.align	2
	.global	SubWord
	.syntax unified
	.arm
	.fpu softvfp
	.type	SubWord, %function
SubWord:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, lr}
	mov	r6, r0
	mov	r4, #4
	mov	r5, #0
.L33:
	and	r0, r6, #255
	bl	SubByte.part.1
	sub	r3, r4, #1
	orr	r5, r0, r5
	ands	r4, r3, #255
	ror	r5, r5, #8
	lsr	r6, r6, #8
	bne	.L33
	mov	r0, r5
	pop	{r4, r5, r6, lr}
	bx	lr
	.size	SubWord, .-SubWord
	.align	2
	.global	SubBytes
	.syntax unified
	.arm
	.fpu softvfp
	.type	SubBytes, %function
SubBytes:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, lr}
	mov	r6, r1
	sub	r4, r0, #1
	add	r5, r0, #15
.L37:
	ldrb	r0, [r4, #1]	@ zero_extendqisi2
	mov	r1, r6
	bl	SubByte
	strb	r0, [r4, #1]!
	cmp	r4, r5
	bne	.L37
	pop	{r4, r5, r6, lr}
	bx	lr
	.size	SubBytes, .-SubBytes
	.align	2
	.global	ShiftRows
	.syntax unified
	.arm
	.fpu softvfp
	.type	ShiftRows, %function
ShiftRows:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, lr}
	mov	r4, #0
	mov	r5, #32
	mov	lr, r4
	mov	r6, r4
.L41:
	mov	r2, lr
	mov	r3, r6
.L42:
	ldrb	ip, [r0, r2]	@ zero_extendqisi2
	add	r2, r2, #4
	orr	r3, ip, r3
	cmp	r2, #15
	ror	r3, r3, #8
	bls	.L42
	cmp	r1, #1
	lsreq	r2, r3, r4
	lsrne	r2, r3, r5
	orreq	r3, r2, r3, lsl r5
	orrne	r3, r2, r3, lsl r4
	mov	r2, lr
.L45:
	strb	r3, [r0, r2]
	add	r2, r2, #4
	cmp	r2, #15
	lsr	r3, r3, #8
	bls	.L45
	add	lr, lr, #1
	cmp	lr, #4
	sub	r5, r5, #8
	add	r4, r4, #8
	bne	.L41
	pop	{r4, r5, r6, lr}
	bx	lr
	.size	ShiftRows, .-ShiftRows
	.align	2
	.global	MixColumn
	.syntax unified
	.arm
	.fpu softvfp
	.type	MixColumn, %function
MixColumn:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ror	r2, r0, #8
	ldr	r3, .L51
	eor	ip, r0, r2
	ldr	r1, .L51+4
	eor	r2, r2, r0, ror #16
	and	r3, r3, ip, lsr #7
	eor	r0, r2, r0, ror #24
	add	r3, r3, r3, lsl #1
	and	r2, r1, ip, lsl #1
	eor	r0, r0, r2
	add	r3, r3, r3, lsl #3
	eor	r0, r0, r3
	bx	lr
.L52:
	.align	2
.L51:
	.word	16843009
	.word	-16843010
	.size	MixColumn, .-MixColumn
	.align	2
	.global	MixColumns
	.syntax unified
	.arm
	.fpu softvfp
	.type	MixColumns, %function
MixColumns:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, lr}
	ldr	r4, .L58
	ldr	lr, .L58+4
	sub	ip, r0, #4
	add	r0, r0, #12
.L55:
	cmp	r1, #0
	ldr	r5, [ip, #4]
	bne	.L54
	eor	r3, r5, r5, ror #16
	and	r2, r4, r3, lsr #7
	add	r2, r2, r2, lsl #1
	and	r3, lr, r3, lsl #1
	add	r2, r2, r2, lsl #3
	eor	r2, r2, r3
	and	r3, r4, r2, lsr #7
	add	r3, r3, r3, lsl #1
	and	r2, lr, r2, lsl #1
	add	r6, r3, r3, lsl #3
	eor	r3, r2, r5
	eor	r5, r6, r3
.L54:
	ror	r3, r5, #8
	eor	r6, r5, r3
	and	r2, r4, r6, lsr #7
	eor	r3, r3, r5, ror #16
	eor	r3, r3, r5, ror #24
	and	r6, lr, r6, lsl #1
	add	r2, r2, r2, lsl #1
	eor	r3, r3, r6
	add	r2, r2, r2, lsl #3
	eor	r3, r3, r2
	str	r3, [ip, #4]!
	cmp	r0, ip
	bne	.L55
	pop	{r4, r5, r6, lr}
	bx	lr
.L59:
	.align	2
.L58:
	.word	16843009
	.word	-16843010
	.size	MixColumns, .-MixColumns
	.align	2
	.global	AddRoundKey
	.syntax unified
	.arm
	.fpu softvfp
	.type	AddRoundKey, %function
AddRoundKey:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	add	r1, r1, r2, lsl #4
	sub	r3, r0, #1
	sub	r1, r1, #1
	add	r0, r0, #15
.L61:
	ldrb	r2, [r3, #1]	@ zero_extendqisi2
	ldrb	ip, [r1, #1]!	@ zero_extendqisi2
	eor	r2, r2, ip
	strb	r2, [r3, #1]!
	cmp	r3, r0
	bne	.L61
	bx	lr
	.size	AddRoundKey, .-AddRoundKey
	.align	2
	.global	aes_setkey
	.syntax unified
	.arm
	.fpu softvfp
	.type	aes_setkey, %function
aes_setkey:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r3, r4, r5, r6, r7, r8, r9, r10, fp, lr}
	sub	r6, r0, #4
	mov	r2, r6
	sub	r3, r1, #4
	add	r0, r1, #28
.L64:
	ldr	r1, [r3, #4]!
	cmp	r0, r3
	str	r1, [r2, #4]!
	bne	.L64
	mov	r7, #1
	mov	r5, #8
	mov	r9, #4
	mov	r8, #0
.L69:
	ands	r3, r5, #7
	ldr	r4, [r6, #32]
	bne	.L65
	mov	fp, r9
	mov	r10, r8
	ror	r4, r4, #8
.L66:
	and	r0, r4, #255
	bl	SubByte.part.1
	sub	r3, fp, #1
	orr	r10, r0, r10
	ands	fp, r3, #255
	ror	r10, r10, #8
	lsr	r4, r4, #8
	bne	.L66
	ldr	r3, .L75
	ldr	r2, .L75+4
	and	r3, r3, r7, lsr #7
	add	r3, r3, r3, lsl #1
	add	r3, r3, r3, lsl #3
	and	r1, r2, r7, lsl #1
	eor	r4, r10, r7
	eor	r7, r3, r1
.L67:
	ldr	r0, [r6, #4]!
	add	r5, r5, #1
	eor	r4, r4, r0
	cmp	r5, #60
	str	r4, [r6, #32]
	bne	.L69
	pop	{r3, r4, r5, r6, r7, r8, r9, r10, fp, lr}
	bx	lr
.L65:
	cmp	r3, #4
	bne	.L67
	mov	fp, r4
	mov	r10, r9
	mov	r4, r8
.L68:
	and	r0, fp, #255
	bl	SubByte.part.1
	sub	r3, r10, #1
	orr	r4, r0, r4
	ands	r10, r3, #255
	ror	r4, r4, #8
	lsr	fp, fp, #8
	bne	.L68
	b	.L67
.L76:
	.align	2
.L75:
	.word	16843009
	.word	-16843010
	.size	aes_setkey, .-aes_setkey
	.align	2
	.global	aes_encrypt
	.syntax unified
	.arm
	.fpu softvfp
	.type	aes_encrypt, %function
aes_encrypt:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	push	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	cmp	r2, #1
	sub	sp, sp, #12
	sub	r5, r1, #1
	mov	r4, r2
	str	r0, [sp, #4]
	mov	r10, r1
	mov	r6, r5
	beq	.L107
	ldr	r3, [sp, #4]
	add	r9, r1, #15
	add	r2, r3, #223
.L85:
	ldrb	r3, [r6, #1]	@ zero_extendqisi2
	ldrb	r1, [r2, #1]!	@ zero_extendqisi2
	eor	r3, r3, r1
	strb	r3, [r6, #1]!
	cmp	r6, r9
	bne	.L85
	ldr	r3, [sp, #4]
	add	r7, r3, #207
	sub	fp, r3, #1
.L89:
	mov	r8, r5
.L87:
	ldrb	r0, [r8, #1]	@ zero_extendqisi2
	mov	r1, r4
	bl	SubByte
	strb	r0, [r8, #1]!
	cmp	r8, r6
	bne	.L87
	mov	r0, r10
	mov	r1, r4
	bl	ShiftRows
	mov	r0, r7
	mov	r2, r5
.L88:
	ldrb	r1, [r2, #1]	@ zero_extendqisi2
	ldrb	ip, [r0, #1]!	@ zero_extendqisi2
	eor	r1, r1, ip
	strb	r1, [r2, #1]!
	cmp	r2, r8
	bne	.L88
	sub	r7, r7, #16
	mov	r1, r4
	mov	r0, r10
	bl	MixColumns
	cmp	r7, fp
	bne	.L89
	mov	r7, #0
.L84:
	mov	r6, r5
.L90:
	ldrb	r0, [r6, #1]	@ zero_extendqisi2
	mov	r1, r4
	bl	SubByte
	strb	r0, [r6, #1]!
	cmp	r9, r6
	bne	.L90
	mov	r1, r4
	mov	r0, r10
	bl	ShiftRows
	ldr	r2, [sp, #4]
	sub	r3, r7, #1
	add	r8, r2, r3
.L91:
	ldrb	r3, [r5, #1]	@ zero_extendqisi2
	ldrb	r2, [r8, #1]!	@ zero_extendqisi2
	eor	r3, r3, r2
	strb	r3, [r5, #1]!
	cmp	r6, r5
	bne	.L91
	add	sp, sp, #12
	@ sp needed
	pop	{r4, r5, r6, r7, r8, r9, r10, fp, lr}
	bx	lr
.L107:
	sub	r2, r0, #1
	add	r9, r1, #15
.L79:
	ldrb	r3, [r6, #1]	@ zero_extendqisi2
	ldrb	r1, [r2, #1]!	@ zero_extendqisi2
	eor	r3, r3, r1
	strb	r3, [r6, #1]!
	cmp	r6, r9
	bne	.L79
	mov	r7, #1
	ldr	r3, [sp, #4]
	add	fp, r3, #15
	add	r3, r3, #223
	str	r3, [sp]
.L83:
	mov	r8, r5
.L81:
	ldrb	r0, [r8, #1]	@ zero_extendqisi2
	mov	r1, r7
	bl	SubByte
	strb	r0, [r8, #1]!
	cmp	r6, r8
	bne	.L81
	mov	r1, r7
	mov	r0, r10
	bl	ShiftRows
	mov	r0, r10
	mov	r1, r7
	bl	MixColumns
	mov	r0, fp
	mov	r2, r5
.L82:
	ldrb	r1, [r2, #1]	@ zero_extendqisi2
	ldrb	ip, [r0, #1]!	@ zero_extendqisi2
	eor	r1, r1, ip
	strb	r1, [r2, #1]!
	cmp	r2, r8
	bne	.L82
	ldr	r3, [sp]
	add	fp, fp, #16
	cmp	r3, fp
	bne	.L83
	mov	r7, #224
	b	.L84
	.size	aes_encrypt, .-aes_encrypt
	.ident	"GCC: (GNU Tools for ARM Embedded Processors 6-2017-q2-update) 6.3.1 20170620 (release) [ARM/embedded-6-branch revision 249437]"
