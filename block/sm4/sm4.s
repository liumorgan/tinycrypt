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
	.file	"sm4.c"
	.text
	.align	2
	.global	T
	.type	T, %function
T:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	ldr	ip, .L8
	sub	sp, sp, #8
	mov	r3, #0
	str	r0, [sp, #4]
.L2:
	add	r2, sp, #4
	ldrb	r0, [r3, r2]	@ zero_extendqisi2
	ldrb	r0, [ip, r0]	@ zero_extendqisi2
	strb	r0, [r3, r2]
	add	r3, r3, #1
	cmp	r3, #4
	bne	.L2
	ldr	r3, [sp, #4]
	cmp	r1, #0
	movne	r0, r3, ror #22
	eorne	r0, r0, r3, ror #30
	moveq	r0, r3, ror #9
	eorne	r0, r0, r3
	eoreq	r0, r0, r3, ror #19
	eorne	r0, r0, r3, ror #14
	eoreq	r0, r0, r3
	eorne	r0, r0, r3, ror #8
	add	sp, sp, #8
	@ sp needed
	bx	lr
.L9:
	.align	2
.L8:
	.word	.LANCHOR0
	.size	T, .-T
	.align	2
	.global	F
	.type	F, %function
F:
	@ args = 4, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, lr}
	mov	r4, r0
	ldr	ip, [sp, #8]
	eor	r3, r3, ip
	eor	r2, r2, r3
	eor	r0, r2, r1
	mov	r1, #1
	bl	T
	eor	r0, r0, r4
	ldmfd	sp!, {r4, pc}
	.size	F, .-F
	.align	2
	.global	CK
	.type	CK, %function
CK:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	@ link register save eliminated.
	mov	r0, r0, asl #2
	mov	r3, #7
	smulbb	r2, r0, r3
	mov	r3, #0
	mov	r0, r3
	uxtb	r2, r2
.L13:
	add	r1, r3, r2
	add	r3, r3, #7
	uxtb	r1, r1
	uxtb	r3, r3
	cmp	r3, #28
	orr	r0, r1, r0, asl #8
	bne	.L13
	bx	lr
	.size	CK, .-CK
	.align	2
	.global	sm4_setkey
	.type	sm4_setkey, %function
sm4_setkey:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, fp, lr}
	mov	r8, r0
	mov	fp, r2
	ldr	ip, [r1]
	ldr	r0, [r1, #4]
	ldr	r2, [r1, #8]
	ldr	r3, [r1, #12]
	ldr	r9, .L23
	ldr	r7, .L23+4
	ldr	r6, .L23+8
	ldr	r5, .L23+12
	rev	ip, ip
	rev	r0, r0
	rev	r2, r2
	rev	r3, r3
	eor	r9, r9, ip
	eor	r7, r7, r0
	eor	r6, r6, r2
	eor	r5, r5, r3
	mov	r4, #0
.L16:
	mov	r0, r4
	bl	CK
	eor	r10, r6, r7
	eor	r10, r10, r5
	mov	r1, #0
	eor	r0, r0, r10
	bl	T
	eor	r0, r0, r9
	str	r0, [r8, r4, asl #2]
	add	r4, r4, #1
	cmp	r4, #32
	mov	r9, r7
	mov	r7, r6
	mov	r6, r5
	mov	r5, r0
	bne	.L16
	cmp	fp, #1
	ldmnefd	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, fp, pc}
	add	r2, r8, #124
	mov	r3, #0
.L18:
	ldr	r0, [r2]
	ldr	r1, [r8, r3, asl #2]
	str	r0, [r8, r3, asl #2]
	add	r3, r3, #1
	cmp	r3, #16
	str	r1, [r2], #-4
	bne	.L18
	ldmfd	sp!, {r3, r4, r5, r6, r7, r8, r9, r10, fp, pc}
.L24:
	.align	2
.L23:
	.word	-1548633402
	.word	1453994832
	.word	1736282519
	.word	-1301273892
	.size	sm4_setkey, .-sm4_setkey
	.align	2
	.global	sm4_encrypt
	.type	sm4_encrypt, %function
sm4_encrypt:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r0, r1, r2, r4, r5, r6, r7, r8, r9, lr}
	mov	r3, r0
	ldr	r5, [r1, #4]
	ldr	r0, [r1]
	ldr	r6, [r1, #8]
	ldr	r7, [r1, #12]
	mov	r4, r1
	rev	r0, r0
	rev	r5, r5
	rev	r6, r6
	rev	r7, r7
	sub	r9, r3, #4
	add	r8, r3, #124
.L26:
	ldr	r3, [r9, #4]!
	mov	r1, r5
	str	r3, [sp]
	mov	r2, r6
	mov	r3, r7
	bl	F
	cmp	r9, r8
	mov	r3, r0
	mov	r0, r5
	movne	r5, r6
	movne	r6, r7
	movne	r7, r3
	bne	.L26
.L29:
	rev	r3, r3
	rev	r7, r7
	rev	r6, r6
	rev	r5, r5
	str	r3, [r4]
	str	r7, [r4, #4]
	str	r6, [r4, #8]
	str	r5, [r4, #12]
	add	sp, sp, #12
	@ sp needed
	ldmfd	sp!, {r4, r5, r6, r7, r8, r9, pc}
	.size	sm4_encrypt, .-sm4_encrypt
	.section	.rodata
.LANCHOR0 = . + 0
	.type	S, %object
	.size	S, 256
S:
	.byte	-42
	.byte	-112
	.byte	-23
	.byte	-2
	.byte	-52
	.byte	-31
	.byte	61
	.byte	-73
	.byte	22
	.byte	-74
	.byte	20
	.byte	-62
	.byte	40
	.byte	-5
	.byte	44
	.byte	5
	.byte	43
	.byte	103
	.byte	-102
	.byte	118
	.byte	42
	.byte	-66
	.byte	4
	.byte	-61
	.byte	-86
	.byte	68
	.byte	19
	.byte	38
	.byte	73
	.byte	-122
	.byte	6
	.byte	-103
	.byte	-100
	.byte	66
	.byte	80
	.byte	-12
	.byte	-111
	.byte	-17
	.byte	-104
	.byte	122
	.byte	51
	.byte	84
	.byte	11
	.byte	67
	.byte	-19
	.byte	-49
	.byte	-84
	.byte	98
	.byte	-28
	.byte	-77
	.byte	28
	.byte	-87
	.byte	-55
	.byte	8
	.byte	-24
	.byte	-107
	.byte	-128
	.byte	-33
	.byte	-108
	.byte	-6
	.byte	117
	.byte	-113
	.byte	63
	.byte	-90
	.byte	71
	.byte	7
	.byte	-89
	.byte	-4
	.byte	-13
	.byte	115
	.byte	23
	.byte	-70
	.byte	-125
	.byte	89
	.byte	60
	.byte	25
	.byte	-26
	.byte	-123
	.byte	79
	.byte	-88
	.byte	104
	.byte	107
	.byte	-127
	.byte	-78
	.byte	113
	.byte	100
	.byte	-38
	.byte	-117
	.byte	-8
	.byte	-21
	.byte	15
	.byte	75
	.byte	112
	.byte	86
	.byte	-99
	.byte	53
	.byte	30
	.byte	36
	.byte	14
	.byte	94
	.byte	99
	.byte	88
	.byte	-47
	.byte	-94
	.byte	37
	.byte	34
	.byte	124
	.byte	59
	.byte	1
	.byte	33
	.byte	120
	.byte	-121
	.byte	-44
	.byte	0
	.byte	70
	.byte	87
	.byte	-97
	.byte	-45
	.byte	39
	.byte	82
	.byte	76
	.byte	54
	.byte	2
	.byte	-25
	.byte	-96
	.byte	-60
	.byte	-56
	.byte	-98
	.byte	-22
	.byte	-65
	.byte	-118
	.byte	-46
	.byte	64
	.byte	-57
	.byte	56
	.byte	-75
	.byte	-93
	.byte	-9
	.byte	-14
	.byte	-50
	.byte	-7
	.byte	97
	.byte	21
	.byte	-95
	.byte	-32
	.byte	-82
	.byte	93
	.byte	-92
	.byte	-101
	.byte	52
	.byte	26
	.byte	85
	.byte	-83
	.byte	-109
	.byte	50
	.byte	48
	.byte	-11
	.byte	-116
	.byte	-79
	.byte	-29
	.byte	29
	.byte	-10
	.byte	-30
	.byte	46
	.byte	-126
	.byte	102
	.byte	-54
	.byte	96
	.byte	-64
	.byte	41
	.byte	35
	.byte	-85
	.byte	13
	.byte	83
	.byte	78
	.byte	111
	.byte	-43
	.byte	-37
	.byte	55
	.byte	69
	.byte	-34
	.byte	-3
	.byte	-114
	.byte	47
	.byte	3
	.byte	-1
	.byte	106
	.byte	114
	.byte	109
	.byte	108
	.byte	91
	.byte	81
	.byte	-115
	.byte	27
	.byte	-81
	.byte	-110
	.byte	-69
	.byte	-35
	.byte	-68
	.byte	127
	.byte	17
	.byte	-39
	.byte	92
	.byte	65
	.byte	31
	.byte	16
	.byte	90
	.byte	-40
	.byte	10
	.byte	-63
	.byte	49
	.byte	-120
	.byte	-91
	.byte	-51
	.byte	123
	.byte	-67
	.byte	45
	.byte	116
	.byte	-48
	.byte	18
	.byte	-72
	.byte	-27
	.byte	-76
	.byte	-80
	.byte	-119
	.byte	105
	.byte	-105
	.byte	74
	.byte	12
	.byte	-106
	.byte	119
	.byte	126
	.byte	101
	.byte	-71
	.byte	-15
	.byte	9
	.byte	-59
	.byte	110
	.byte	-58
	.byte	-124
	.byte	24
	.byte	-16
	.byte	125
	.byte	-20
	.byte	58
	.byte	-36
	.byte	77
	.byte	32
	.byte	121
	.byte	-18
	.byte	95
	.byte	62
	.byte	-41
	.byte	-53
	.byte	57
	.byte	72
	.ident	"GCC: (Raspbian 4.9.2-10) 4.9.2"
	.section	.note.GNU-stack,"",%progbits
