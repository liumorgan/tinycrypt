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
	.file	"xtea.c"
	.text
	.align	2
	.global	xtea_encrypt
	.type	xtea_encrypt, %function
xtea_encrypt:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r5, r6, lr}
	mov	r0, r0, asl #1
	ldmia	r2, {r4, lr}
	mov	r3, #0
	ldr r6, xtea_const
.L2:
	//cmp	r0, #0
	//ble	.L8
	tst	r0, #1
	addne r3, r3, r6
	//addne	r3, r3, #-1644167168
	//addne	r3, r3, #3620864
	//addne	r3, r3, #14720
	//addne	r3, r3, #57
	moveq	ip, r3
	movne	ip, r3, lsr #11
	and	ip, ip, #3
	//sub	r0, r0, #1
	ldr	ip, [r1, ip, asl #2]
	add	r5, r3, ip
	mov	ip, lr, asl #4
	eor	ip, ip, lr, lsr #5
	add	ip, ip, lr
	eor	ip, ip, r5
	add	ip, ip, r4
	mov	r4, lr
	mov	lr, ip
	subs r0, r0, #1
	bne .L2
	//b	.L2
.L8:
	stmia	r2, {r4, lr}
	ldmfd	sp!, {r4, r5, r6, pc}
xtea_const:	
	.word 0x9E3779B9
	.size	xtea_encrypt, .-xtea_encrypt
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
