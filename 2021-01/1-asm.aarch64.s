.global main
main:
	# Use W1 to store the output value, which means it will already be in the
	# correct register to be an argument to printf later.
	value .req w1
	mov value, 0

	p_input .req x0
	p_end .req x2
	adr p_input, .Linput
	adr p_end, input_end
	sub p_end, p_end, 4

	# Each loop iteration will load the next value into W4, and finally move
	# W4 into W3 in preparation for the next iteration. Perform the initial
	# load of the first value into W3.
	previous .req w3
	ldr previous, [p_input]
1:
	current .req w4
	# Use pre-indexed addressing to increment X0 by 4 and then load the next
	# value from the resulting address.
	ldr current, [p_input, 4]!
	cmp current, previous
	# Increment W1 if the comparison W4 > W3 was true
	cinc value, value, hi

	mov previous, current
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
