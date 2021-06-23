.text
.global main
main:
	# Save the link register in the callee-saved X19 register.
	mov x19, lr
	# Load the start/end addresses of the input data.
	adr x0, input
	adr x1, input_end
	# Zero out Q0 to initialize the frequency sum.
	eor v0.16B, v0.16B, v0.16B
	# Now we'll use THE POWER OF SIMD to sum 8 values in one fell swoop. ADDP
	# adds values from Q0 and Q1 pairwise, resulting in 4 words in Q0.
	#
	# We'll keep doing this until we hit the end of the input data.
.Lloop_start:
	ldr q1, [x0], 16
	addp v0.4S, v0.4S, v1.4S
	cmp x0, x1
	b.ne .Lloop_start

	# Now we're left with 4 words in Q0 which still need to be summed up, so
	# we'll use ADDV to convert the vector into a scalar value, stored in the
	# least significant bits of Q0.
	addv s0, v0.4S
	# Now we can move the word in the LSB of Q0 to X1, providing the positional
	# argument for the impending printf call.
	smov x1, v0.S[0]

	# printf(.Lformat_string, sum)
	ldr x0, =.Lformat_string
	bl printf

	# return 0
	mov lr, x19
	mov w0, 0
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
# While we don't need to align the memory we load into Q1, it does make it
# easier if we can just load 16 bytes at a time without having to do any kind
# of pointer arithmetic or additional code to deal with leftover bytes without
# spilling over into uninitialized/inaccessible memory.
.balign 16
.include "2018-01.inc"
# The end of the input has to be padded with zero bytes so that we don't make a
# mess of the output value.
.balign 16, 0
.set input_end, .
