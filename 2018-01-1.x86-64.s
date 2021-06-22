.intel_syntax noprefix
.text
.global main
main:
	# Our starting condition is zero, so XOR XMM0 with itself.
	pxor xmm0, xmm0
	# Load the start/end addresses of the input data
	lea rsi, [rip + input]
	lea rdi, [rip + input_end]
	
	# Now, we'll use THE POWER OF SIMD to sum 8 values in one fell swoop. PHADD
	# performs a horizontal add, where each pair of dwords in each operand is
	# added together, resulting in 8 summed pairs in XMM0.
	#
	# We'll keep doing this until we hit the end of the input data.
.Lloop_start:
	phaddd xmm0, [rsi]
	add rsi, 16
	cmp rsi, rdi
	jl .Lloop_start

	# Now we're left with 4 dwords in XMM0 which still need to be summed up,
	# so we'll zero out XMM1 and then perform two additional PHADDs against
	# XMM0 and XMM1, which will have the eventual effect of yielding the final
	# sum in the least significant 4 bytes if XMM0, where we can MOVD it into
	# ESI to send to printf.
	pxor xmm1, xmm1
	phaddd xmm0, xmm1 # Now XMM0 contains 2 dwords
	phaddd xmm0, xmm1 # Now XMM0 contains 1 dword
	movd esi, xmm0

	# printf(.Lformat_string, sum)
	lea rdi, [rip + .Lformat_string]
	xor eax, eax
	call printf

	# return 0
	mov eax, 0
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
# Pointing PHADD at a memory location requires it to be aligned on a 16-byte
# boundary, or we'll incur the wrath of General Protection.
.balign 16
.include "2018-01.inc"
# Similarly, to avoid having to add specialised code for the final N<4 dwords
# in the input, pad the input data with zero values until we have a multiple of
# 16 bytes = 4 dwords.
.balign 16, 0
.set input_end, .
