	.arch armv6
	.eabi_attribute 27, 3
	.eabi_attribute 28, 1
	.fpu vfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 4
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"lea128.c"
	.text
	.align	2
	.global	lea128_encrypt
	.type	lea128_encrypt, %function
lea128_encrypt:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, lr}
	mov	ip, r1
	ldr	r3, .L7
	mov	lr, r0
	add	r4, sp, #16
	ldmia	r3, {r0, r1, r2, r3}
	mov	r8, #0
	ldmia	ip, {r6, r7}
	stmdb	r4, {r0, r1, r2, r3}
	ldr	r1, [sp, #4]
	ldr	r4, [lr]
	ldmib	lr, {r2, r5, r9}
	mov	r1, r1, ror #31
	str	r1, [sp, #4]
	ldr	r1, [sp, #8]
	ldr	r3, [ip, #8]
	ldr	lr, [ip, #12]
	mov	r1, r1, ror #30
	str	r1, [sp, #8]
	ldr	r1, [sp, #12]
	mov	r1, r1, ror #29
	str	r1, [sp, #12]
.L2:
	and	r0, r8, #3
	add	r1, sp, #16
	add	r0, r1, r0, asl #2
	add	r8, r8, #1
	ldr	r1, [r0, #-16]
	cmp	r8, #24
	add	r4, r4, r1
	mov	r10, r1, ror #28
	add	r2, r2, r1, ror #31
	add	r5, r5, r1, ror #30
	add	r1, r9, r1, ror #29
	mov	r2, r2, ror #29
	mov	r9, r1, ror #21
	eor	r1, r9, r3
	mov	r5, r5, ror #26
	eor	lr, lr, r2
	add	lr, lr, r1
	mov	r4, r4, ror #31
	eor	r1, r5, r7
	eor	r3, r3, r2
	add	r3, r3, r1
	str	r10, [r0, #-16]
	eor	r1, r4, r6
	eor	r0, r2, r7
	add	r0, r0, r1
	mov	r7, r3, ror #5
	mov	r0, r0, ror #23
	mov	r3, lr, ror #3
	mov	lr, r6
	movne	r6, r0
	bne	.L2
.L6:
	stmia	ip, {r0, r7}
	str	r3, [ip, #8]
	str	r6, [ip, #12]
	add	sp, sp, #16
	@ sp needed
	ldmfd	sp!, {r4, r5, r6, r7, r8, r9, r10, pc}
.L8:
	.align	2
.L7:
	.word	.LANCHOR0
	.size	lea128_encrypt, .-lea128_encrypt
	.section	.rodata
	.align	2
.LANCHOR0 = . + 0
.LC0:
	.word	-1007687205
	.word	1147300610
	.word	2044886154
	.word	2027892972
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
