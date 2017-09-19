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
	ldr	r3, .L7
	stmfd	sp!, {r4, r5, lr}
	ldmia	r2, {r4, lr}
	mul	r0, r3, r0           // r0 = rnds * 0x9E3779B9
	mov	r3, #0               // i = 0
.L3:
	cmp	r3, r0
	beq	.L2
  
	and	ip, r3, #3           // t = sum & 3
	ldr	ip, [r1, ip, asl #2] // t = k[t * 4] 
	add	r5, r3, ip           // r5 = sum + t
	mov	ip, lr, asl #4       // v1 << 4 
	eor	ip, ip, lr, lsr #5   // v1 >> 5 
	add	ip, ip, lr           // += v1
	eor	ip, ip, r5           // ^ (sum + k[t & 3])); 
	add	r4, r4, ip           // v0 += 
	
  add	r3, r3, #-1644167168
	add	r3, r3, #3620864
	add	r3, r3, #14720
	add	r3, r3, #57
  
	mov	ip, r4, asl #4
	eor	ip, ip, r4, lsr #5
	add	r5, ip, r4
	mov	ip, r3, lsr #11
	and	ip, ip, #3
	ldr	ip, [r1, ip, asl #2]
	add	ip, r3, ip
	eor	ip, ip, r5
	add	lr, lr, ip
	b .L3
.L2:
	stmia	r2, {r4, lr}
	ldmfd	sp!, {r4, r5, pc}
.L8:
	.align	2
.L7:
	.word	-1640531527
	.size	xtea_encrypt, .-xtea_encrypt
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
