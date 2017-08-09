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
	.file	"speck64.c"
	.text
	.align	2
	.global	speck64_encryptx
	.syntax unified
	.arm
	.fpu softvfp
	.type	speck64_encryptx, %function
speck64_encryptx:
	@ Function supports interworking.
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
  
  ; save registers
	push	{r4, r5, r6, lr}
  
  ; set loop counter
	mov	lr, #0
	ldr	ip, [r0]
	ldmib	r0, {r2, r6}
	ldr	r5, [r0, #12]
  
  ; load plaintext
	ldr	r3, [r1]
	ldr	r0, [r1, #4]
.L2:
	add	r2, ip, r2, ror #8
	eor	r4, r2, lr
	add	r3, r0, r3, ror #8
	add	lr, lr, #1
	eor	r3, r3, ip
	cmp	lr, #27
	mov	r2, r6
	eor	r0, r3, r0, ror #29
	mov	r6, r5
	eor	ip, r4, ip, ror #29
	mov	r5, r4
	bne	.L2
  
  ; store ciphertext
	str	r3, [r1]
	str	r0, [r1, #4]
  
  ; restore registers
	pop	{r4, r5, r6, lr}
	bx	lr
	.size	speck64_encryptx, .-speck64_encryptx
	.ident	"GCC: (GNU Tools for ARM Embedded Processors 6-2017-q2-update) 6.3.1 20170620 (release) [ARM/embedded-6-branch revision 249437]"
