.intel_syntax noprefix
.text
.global main
main:
	# Zero out YMM3, which will be used as an accumulator for the final result.
	vpxor ymm3, ymm3, ymm3

	# Set each 32-bit element of YMM12 to 2. This will be used later to perform
	# a vector multiplication by this constant value.
	mov eax, 2
	vpinsrd xmm12, xmm12, eax, 0
	vpbroadcastd ymm12, xmm12

	# R10 and R11 will hold the addresses of the first input byte, and the end
	# of the first input array, respectively.
	lea r10, [rip + .Linput]
	lea r11, [rip + .Linput + stride]
.Lloop_start:
	# Load the length, width, and height arrays into YMM0, YMM1, and YMM2,
	# respectively. Each register will now contain 8 integer values.
	vmovdqa ymm0, [r10]
	vmovdqa ymm1, [r10 + stride]
	vmovdqa ymm2, [r10 + stride * 2]

	# For each element in the YMM0-2 vectors, calculate L*W, W*H, and L*H into
	# YMM13-15.
	vpmulld ymm13, ymm0, ymm1
	vpmulld ymm14, ymm1, ymm2
	vpmulld ymm15, ymm0, ymm2

	# Determine the minimum value for each element over the YMM13-15 vectors,
	# storing it in YMM11, and then accumulate YMM11 into YMM3.
	vpminud ymm11, ymm13, ymm14
	vpminud ymm11, ymm11, ymm15
	vpaddd ymm3, ymm3, ymm11

	# Sum the values of YMM13-15 into YMM13, multiply each element by a
	# constant 2, and then accumulate it into YMM3.
	vpaddd ymm13, ymm13, ymm14
	vpaddd ymm13, ymm13, ymm15
	vpmulld ymm13, ymm13, ymm12
	vpaddd ymm3, ymm3, ymm13

	# Add 32 bytes to the R10 "pointer", and conditionally jump to the loop
	# start if there are still elements remaining in the length array.
	add r10, 32
	cmp r10, r11
	jnz .Lloop_start

	# YMM3 consists of 8 32-bit values that now need to be summed to obtain the
	# final result. We do this by adding pairs of elements until there is only
	# a single value remaining.
	#
	# First, extract the upper 128 bits of YMM3 into XMM4.
	vextracti128 xmm4, ymm3, 1
	# Now, do a SIMD addition of XMM3 + XMM4, storing the result in XMM3.
	vpaddd xmm3, xmm3, xmm4
	# XMM3 now contains 4 32-bit values. To perform another pairwise addition,
	# we copy the upper 64 bits of XMM3 into the lower 64 bits of XMM4. From
	# this point on, the upper 64 bits of either register will be ignored.
	vpshufd xmm4, xmm3, 0b00001110
	vpaddd xmm3, xmm3, xmm4
	# XMM3 now contains 2 32-bit values. The last pairwise addition will be
	# done by copying the second 32-bit value in XMM3 into XMM4.
	vpshufd xmm4, xmm3, 0b00000001
	vpaddd xmm3, xmm3, xmm4

	xor eax, eax
	lea rdi, [rip + .Lformat_string]
	# Copy the first 32-bit value out of XMM3 into RSI as the first vararg
	# parameter to printf
	vmovd rsi, xmm3
	call printf

	# Exit with a zero result.
	xor eax, eax
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-02.inc"
