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
	.file	"ce.c"
	.text
	.align	2
	.global	xor_key
	.type	xor_key, %function
xor_key:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	sub	r3, r1, #4
	sub	r0, r0, #4
	add	r1, r1, #12
.L2:
	ldr	ip, [r3, #4]!
	ldr	r2, [r0, #4]!
	cmp	r3, r1
	eor	r2, r2, ip
	str	r2, [r3]
	bne	.L2
	bx	lr
	.size	xor_key, .-xor_key
	.align	2
	.global	chaskey
	.type	chaskey, %function
chaskey:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
  
	stmfd	sp!, {r3, r4, r5, lr}
	mov	r4, r1
	mov	r5, r0
	bl	xor_key
	ldr	ip, [r4]
	ldmib	r4, {r1, r3}
	ldr	r2, [r4, #12]
	mov	r0, #16
.L6:
	add	ip, ip, r1
	eor	r1, ip, r1, ror #27
	add	r3, r3, r2
	eor	r2, r3, r2, ror #24
	add	r3, r1, r3
	add	ip, r2, ip, ror #16
	subs	r0, r0, #1
	eor	r1, r3, r1, ror #25
	eor	r2, ip, r2, ror #19
	mov	r3, r3, ror #16
	bne	.L6
  
	stmib	r4, {r1, r3}
	str	ip, [r4]
	str	r2, [r4, #12]
	mov	r0, r5
	mov	r1, r4
	ldmfd	sp!, {r3, r4, r5, lr}
	b	xor_key
  
	.size	chaskey, .-chaskey
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
