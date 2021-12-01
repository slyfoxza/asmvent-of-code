.global main
main:
	value .req w1
	mov value, 0

	p_input .req x0
	p_end .req x2
	adr p_input, .Linput
	adr p_end, input_end
	sub p_end, p_end, 4 * 3

1:
	# Different to the first part: because there is now a wider window, load
	# both values in each iteration rather than swapping values.
	previous .req w3
	current .req w4
	# Use post-indexed addressing to first load the value from X0, and then
	# increment X0 by 4.
	ldr previous, [p_input], 4
	# This uses non-writeback addressing to simply offset from the current
	# value of X0.
	ldr current, [p_input, 4 * 2]
	cmp current, previous
	cinc value, value, hi

	cmp p_input, p_end
	b.ne 1b

	mov x19, lr
	ldr x0, =.Lformat
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
