.global main
main:
	sub rsp, 8

	# This implementation uses AVX2 instructions to perform multiple calculations simultaneously.
	# The AVX2 Yxx registers are 256-bit registers, so can pack 8 doubleword integers.
	# 
	# To start with, zero out XMM3 which will be used to store the final result. Because VPXOR has
	# a VEX prefix, it will also zero out the upper bits of the YMM3 register.
	vpxor xmm3, xmm3, xmm3

	# The data is organised as a "structure of arrays", rather than the "array of structures" that
	# is commonly used:
	#     struct input_t { int widths[N]; int heights[N]; int lengths[N]; }
	#     input_t input
	# as opposed to:
	#     struct input_t { int width; int height; int length; }
	#     input_t input[N]
	#
	# This memory layout allows us to simply load values 8 values at a time into each register,
	# such that each register will contain a field for 8 input structures at the same time.
	#
	# In terms of addressing and loop control, we'll store the start of the input in R10 as usual,
	# while R11 will now contain the end address of the *first* array, which is also the start
	# address of the second array. We can calculate the corresponding address for the other two
	# arrays at any point by simply adding the stride between arrays.
	lea r10, [rip + .Linput]
	lea r11, [rip + .Linput + stride]

1:
	# Load the length, width, and height arrays into YMM0-2. Each register will now contain 8
	# doubleword (32-bit) integers.
	vmovdqa ymm0, [r10]
	vmovdqa ymm1, [r10 + stride]
	vmovdqa ymm2, [r10 + stride * 2]

	# For each element in YMM0-2, calculate L*W, W*H and L*H into YMM13-15.
	vpmulld ymm13, ymm0, ymm1
	vpmulld ymm14, ymm1, ymm2
	vpmulld ymm15, ymm0, ymm2

	# For each element in YMM13-15, determine the minimum value and store it in YMM11. Then, add
	# each to the running sum in YMM3. In the reference implementation, this is:
	#     min = lw < wh ? lw : wh
	#     result += (lh < min) ? lh : min
	vpminud ymm11, ymm13, ymm14
	vpminud ymm11, ymm11, ymm15
	vpaddd ymm3, ymm3, ymm11

	# Sum the values of YMM13-YMM15 into YMM13, then multiply it by 2 by adding YMM13 to itself,
	# before finally adding each element to the running sum in YMM3. In the reference
	# implementation, this is:
	#     result += 2 * (lw + wh + lh)
	vpaddd ymm13, ymm13, ymm14
	vpaddd ymm13, ymm13, ymm15
	vpaddd ymm13, ymm13, ymm13
	vpaddd ymm3, ymm3, ymm13

	# Loop logic: since we're using AVX2, we increment R10 by 32 bytes each iteration.
	add r10, 32
	cmp r10, r11
	jnz 1b

	# Having processed all the data, we now need to perform what is effectively a reduce where we
	# sum each element of the YMM3 vector into a single output value.
	#
	# First, the upper 128 bits of YMM3 are extracted into XMM4, such that we split the single
	# 256-bit YMM3 register into two 128-bit registers, XMM3 and XMM4.
	vextracti128 xmm4, ymm3, 1
	# Now, perform a vector addition of XMM3 + XMM4, storing the result in XMM3.
	vpaddd xmm3, xmm3, xmm4
	# XMM3 now contains 4 32-bit values. To perform another pairwise addition, we copy the upper 64
	# bits of XMM3 into the lower 64 bits of XMM4 (similar to the VEXTRACTI128 operation above).
	# From this point on, the upper 64 bits of either register will be ignored.
	vpshufd xmm4, xmm3, 0b00001110
	vpaddd xmm3, xmm3, xmm4
	# XMM3 now contains 2 32-bit values. The last pairwise addition will be done by copying the
	# second 32-bit value in XMM3 into XMM4.
	vpshufd xmm4, xmm3, 0b00000001
	vpaddd xmm3, xmm3, xmm4

	xor eax, eax
	lea rdi, [rip + .Lformat]
	# Having flattened XMM3 into a single 32-bit value, we can now simply copy it into RSI to be
	# the argument to the printf call.
	vmovd rsi, xmm3
	call printf

	xor eax, eax
	add rsp, 8
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
