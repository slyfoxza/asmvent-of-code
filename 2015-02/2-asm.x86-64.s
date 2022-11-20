.global main
main:
	sub rsp, 8

	vpxor xmm3, xmm3, xmm3

	lea r10, [rip + .Linput]
	lea r11, [rip + .Linput + stride]

1:
	vmovdqa ymm0, [r10]
	vmovdqa ymm1, [r10 + stride]
	vmovdqa ymm2, [r10 + stride * 2]

	# Calculate W+H, H+L, W+L
	vpaddd ymm13, ymm0, ymm1
	vpaddd ymm14, ymm1, ymm2
	vpaddd ymm15, ymm0, ymm2

	# Calculate:
	#     result += 2 * min(W+H, H+L, W+L)
	vpminud ymm13, ymm13, ymm14
	vpminud ymm13, ymm13, ymm15
	vpaddd ymm3, ymm3, ymm13
	vpaddd ymm3, ymm3, ymm13

	# Calculate:
	#     result += W * H * L
	vpmulld ymm12, ymm0, ymm1
	vpmulld ymm12, ymm12, ymm2
	vpaddd ymm3, ymm3, ymm12

	# Loop logic
	add r10, 32
	cmp r10, r11
	jnz 1b

	# Reduce the YMM3 vector into a single 32-bit value in XMM3.
	vextracti128 xmm4, ymm3, 1
	vpaddd xmm3, xmm3, xmm4
	vpshufd xmm4, xmm3, 0b00001110
	vpaddd xmm3, xmm3, xmm4
	vpshufd xmm4, xmm3, 0b00000001
	vpaddd xmm3, xmm3, xmm4

	xor eax, eax
	lea rdi, [rip + .Lformat]
	vmovd rsi, xmm3
	call printf

	xor eax, eax
	add rsp, 8
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
