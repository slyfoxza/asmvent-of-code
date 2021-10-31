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
1:
	# The LDRB instruction uses post-indexed addressing to write the
	# incremented value of X0 back into X0.
	char .req w3
	ldrb char, [p_input], 1
	cmp char, 0x28  // 0x28 = '('
	# Calculate W1 being decremented, and then use CSINC to conditionally
	# select either the decremented value in W4 or the incremented value of W1
	# based on the result of the above CMP, then store the selected value in
	# W1. Roughly:
	#
	#     w4 = w1 - 1
	#     w1 = (w3 == '(') ? w1 + 1 : w4
	sub w4, value, 1
	csinc value, w4, value, ne

	cmp p_input, p_end
	b.ne 1b

	mov x19, lr
	ldr x0, =.Lformat
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
