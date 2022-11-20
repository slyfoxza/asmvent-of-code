.global main
main:
	# This implementation uses SIMD instructions to perform multiple calculations simultaneously.
	# The Vxx registers are 128-bit registers, so can pack 4 32-bit integers.
	#
	# To start with, zero out V31 which will be used to store the final result.
	movi v31.4s, 0

	# See the x86-64 version of this implementation for a discussion on the "structure of arrays"
	# memory layout used.
	#
	# In terms of addressing and loop control, we'll store the start of the input in X9, while X10
	# will contain the end address of the *first* array, which is also the start address of the
	# second array. We can calculate the corresponding address for the other two arrays at any
	# point by simply adding the stride between arrays.
	pInput .req x9
	pEnd .req x10
	adr pInput, .Linput
	add pEnd, pInput, stride

1:
	# Load the length, width, and height arrays into Q16-Q18; the Q indicating that the full 128
	# bits of the vector register is to be written to.
	ldur q16, [pInput]
	# Use X0 to store the stride/offset, since it is too large to be used as an immediate offset.
	mov w0, stride
	ldr q17, [pInput, x0]
	lsl w0, w0, 1
	ldr q18, [pInput, x0]

	# For each element in V16-18, calculate L*W, W*H, and L*H into V19-21.
	mul v19.4s, v16.4s, v17.4s
	mul v20.4s, v17.4s, v18.4s
	mul v21.4s, v16.4s, v18.4s

	# For each element in V19-21, determine the minimum value and store it in V22. Then, add to the
	# running sum in V31. In the reference implementatio, this is:
	#     min = lw < wh ? lw : wh
	#     result += (lh < min) ? lh : min
	umin v22.4s, v19.4s, v20.4s
	umin v22.4s, v22.4s, v21.4s
	add v31.4s, v31.4s, v22.4s

	# Sum the values of V19-21 into V19, then multiply it by 2 by adding V19 to itself, before
	# finally adding each element to the running sum in V31. In the reference implementation, this
	# is:
	#     result += 2 * (lw + wh + lh)
	add v19.4s, v19.4s, v20.4s
	add v19.4s, v19.4s, v21.4s
	add v19.4s, v19.4s, v19.4s
	add v31.4s, v31.4s, v19.4s

	# Loop logic: since we're using SIMD instructions, we increment X9 by 16 bytes each iteration.
	add pInput, pInput, 16
	cmp pInput, pEnd
	b.ne 1b

	# Having processed all the data, we now need to perform what is effectively a reduce where we
	# sum each element of the V31 vector into a single output value.
	addv s31, v31.4s
	# Having flattened V31 into a single 32-bit value, we can now simply copy it into the W1
	# general-purpose register to be the argument to the printf call.
	mov w1, v31.s[0]

	mov x19, lr
	adr x0, .Lformat
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
