
// xtea in armv6 assembly
// 96 bytes
	.text
	.align	2
	.global	xtea_encrypt

xtea_encrypt:
	push  {r4, r5, r6, lr}
  
	mov	  r0, r0, asl #1
	ldm	  r2, {r4, lr}
	mov	  r3, #0
	ldr   r6, xtea_const
.L2:
	tst	  r0, #1
	addne r3, r3, r6
	moveq	ip, r3
	movne	ip, r3, lsr #11
	and	  ip, ip, #3
	ldr	  ip, [r1, ip, asl #2]
	add	  r5, r3, ip
	mov	  ip, lr, asl #4
	eor	  ip, ip, lr, lsr #5
	add	  ip, ip, lr
	eor	  ip, ip, r5
	add	  ip, ip, r4
	mov	  r4, lr
	mov	  lr, ip
	subs  r0, r0, #1
	bne   .L2
.L8:
	stm	  r2, {r4, lr}
	pop   {r4, r5, r6, pc}
xtea_const:	
	.word 0x9E3779B9
