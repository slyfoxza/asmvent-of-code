.text
.global main
main:
	# Normally we'd push the link register onto the stack to save our return
	# address across the calls we're going to make to (f)printf, but it turns
	# out we have registers to spare, so we'll just shove LR into X19, which is
	# one of the callee-saved registers.
	mov x19, lr

	# Since the very first instruction after the loop_a_start label is going to
	# increment W0 by 1, initialize W0 to all bits 1, so that the increment
	# will overflow to zero, starting the first iteration as desired.
	mov w0, 0xFFFFFFFF

.Lloop_a_start:
	add w0, w0, 1
	cmp w0, max_iter_a
	b.eq .Lloop_a_completed

	# Load the input value at index W0 into W2. We'll keep it there for the
	# remainder of the iteration to avoid repeatedly fetching it from RAM.
	#
	# It first loads the address of input into X2 using an ADR instruction,
	# then calculates the byte offset into W4 using a 2-bit left-shift of W0
	# (that is, W0 * 4), and finally loads the value. The UXTW extension simply
	# widens W4 to the necessary 64-bit value.
	adr x2, input
	lsl w4, w0, 2
	ldr w2, [x2, w4, uxtw]

	mov w1, w0
.Lloop_b_start:
	add w1, w1, 1
	cmp w1, max_iter_b
	b.eq .Lloop_a_start

	# As above, load the next input value into X3. While we'll only use it once
	# in this iteration, if it's the value that makes the sum match the target,
	# we can again re-use it when calculating the product that will be the
	# algorithm result.
	adr x3, input
	lsl w4, w1, 2
	ldr w3, [x3, w4, uxtw]

	# Test the sum against the target value, and repeat the inner loop if it's
	# no match.
	add w4, w2, w3
	cmp w4, 2020
	b.ne .Lloop_b_start

	# If we didn't branch, then we've found the pair we're looking for. Since
	# we're out of the loop, we can now freely clobber X0 and W1 which
	# previously held the loop indices.

	# printf(format_string, product)
	ldr x0, =.Lformat_string
	mul w1, w2, w3
	bl printf

	# return 0
	mov lr, x19
	mov w0, 0
	ret

.Lloop_a_completed:
	# fprintf(stderr, error_string)
	ldr x0, stderr
	ldr x1, =.Lerror_string
	bl fprintf

	# return 1
	mov lr, x19
	mov w0, 1
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.Lerror_string: .asciz "Error: no result found!\n"
.include "2020-01.txt.s"
.set max_iter_b, (. - input) / 4
.set max_iter_a, max_iter_b - 1
