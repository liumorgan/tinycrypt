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
	.eabi_attribute 30, 2
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"gimli.c"
	.text
	.align	2
	.global	gimli
	.type	gimli, %function
gimli:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r5, r6, r7, r8, r9, lr}
	ldr	r4, .L10
	ldr	r5, .L10+4
.L2:
	mov	r1, r0
	mov	lr, #0
.L3:
	ldr	ip, [r1, #16]
	ldr	r3, [r1]
	ldr	r2, [r1, #32]
	mov	ip, ip, ror #23
	mov	r3, r3, ror #8
	orr	r9, r3, r2
	and	r8, ip, r2
	and	r7, ip, r3
	eor	r6, ip, r3
	add	lr, lr, #1
	eor	r3, r3, r2, asl #1
	eor	r2, r2, ip
	eor	r3, r3, r8, asl #2
	eor	ip, r6, r9, asl #1
	eor	r2, r2, r7, asl #3
	cmp	lr, #4
	str	ip, [r1, #16]
	str	r3, [r1, #32]
	str	r2, [r1], #4
	bne	.L3
	ands	r3, r4, #3
	bne	.L4
	ldr	r3, [r0, #4]
	ldr	ip, [r0]
	ldr	r1, [r0, #8]
	ldr	r2, [r0, #12]
	eor	r3, r3, r4
	str	r1, [r0, #12]
	stmia	r0, {r3, ip}
	str	r2, [r0, #8]
.L5:
	sub	r4, r4, #1
	cmp	r4, r5
	bne	.L2
	ldmfd	sp!, {r4, r5, r6, r7, r8, r9, pc}
.L4:
	cmp	r3, #2
	bne	.L5
	ldr	ip, [r0]
	ldr	r1, [r0, #8]
	ldr	r2, [r0, #4]
	ldr	r3, [r0, #12]
	str	ip, [r0, #8]
	str	r1, [r0]
	str	r2, [r0, #12]
	str	r3, [r0, #4]
	b	.L5
.L11:
	.align	2
.L10:
	.word	-1640531688
	.word	-1640531712
	.size	gimli, .-gimli
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
