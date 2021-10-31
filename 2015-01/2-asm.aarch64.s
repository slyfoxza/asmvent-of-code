.global main
main:
	value .req w1
	mov value, 0

	p_input .req x0
	p_end .req x2
	adr p_input, .Linput
	adr p_end, input_end
1:
	char .req w3
	ldrb char, [p_input], 1
	# As with the first part, use CSINC to update W1 appropriately.
	cmp char, 0x28
	sub w4, value, 1
	csinc value, w4, value, ne

	cmp w1, 0
	b.lt 2f

	cmp x0, x2
	b.ne 1b

	mov w0, 1
	ret

2:
	mov x19, lr
	# Calculate the difference between X0, which is the byte address one after
	# (due to the post-indexed addressing used in the LDRB instruction) the
	# byte which caused W1 to become negative, and the start of the input
	# string.
	adr x1, .Linput
	sub x1, p_input, x1
	ldr x0, =.Lformat
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%zd\n"
.include "input.inc"
