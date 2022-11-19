.global main
main:
	# Unlike the first part, we'll store the running sum in W9 instead of W1, since the output
	# value we want to print is a different value.
	value .req w9
	mov value, 0

	pInput .req x10
	pEnd .req x11
	adr pInput, .Linput
	adr pEnd, input_end

1:
	# As with the first part, increment or decrement W9 depending on the current character.
	char .req w12
	ldrb char, [pInput], 1
	sub w13, value, 1
	cmp char, 0x28
	csinc value, w13, value, ne

	# If the running sum is now a negative value, we can stop iterating over the input.
	cmp value, 0
	b.lt 2f

	# Loop logic
	cmp pInput, pEnd
	b.ne 1b

	# If, somehow, we manage to exit the loop without having reached a negative value, exit with an
	# error result.
	mov w0, 1
	ret

2:
	# The output value should be the 1-based position at which the running sum became negative.
	# Since X10 contains the 0-based index of the character *after* a negative value was reached
	# (because of the post-indexed addressing), it means X10 actually contains the 1-based index of
	# that character. All that needs to be done is to subtract the address of the input start.
	mov x19, lr
	adr x0, .Lformat
	adr x1, .Linput
	sub x1, pInput, x1
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
