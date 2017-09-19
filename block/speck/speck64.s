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
	.file	"speck64.c"
	.text
	.align	2
	.global	speck64_encryptx
	.type	speck64_encryptx, %function
speck64_encryptx:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	ldr	r3, [r1]
	ldr	r2, [r1, #4]
	stmfd	sp!, {r4, r5, r6, lr}
	ldr	ip, [r0, #4]
	ldr	lr, [r0]
	ldr	r4, [r0, #8]
	ldr	r5, [r0, #12]
	mov	r0, #0
.L2:
	add	ip, lr, ip, ror #8
	eor	r6, ip, r0
	add	r3, r2, r3, ror #8
	add	r0, r0, #1
	eor	r3, r3, lr
	cmp	r0, #27
	mov	ip, r4
	eor	r2, r3, r2, ror #29
	eor	lr, r6, lr, ror #29
	mov	r4, r5
	movne	r5, r6
	bne	.L2
.L6:
	str	r3, [r1]
	str	r2, [r1, #4]
	ldmfd	sp!, {r4, r5, r6, pc}
	.size	speck64_encryptx, .-speck64_encryptx
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
