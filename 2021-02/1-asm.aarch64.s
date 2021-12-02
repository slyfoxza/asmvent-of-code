.global main
main:
	x .req w1
	z .req w2
	mov x, 0
	mov z, 0

	p_input .req x3
	p_end .req x4
	adr p_input, .Linput
	adr p_end, input_end

1:
	direction .req w5
	value .req w6
	ldrb direction, [p_input], 1
	ldrb value, [p_input], 1
	cmp direction, 0x66  // 0x66 = 'f'
	# If the direction is 'f', branch to the next 2 label to handle updating
	# the W1/X value.
	b.eq 2f
	# If we didn't branch, direction is either 'd' or 'u', which is less than
	# and greater than 'f', respectively. We use this to conditionally negate
	# the value if it was greater (thus, 'u'), allowing us to subsequently
	# simply add the final value of W6 to W2/Z.
	cneg value, value, hi
	add z, z, value
	b 3f
2:
	add x, x, value
3:
	# The LDRB instructions earlier used post-indexed addressing to update X3
	# as we went along, so compare the current value of X3 to X4 to check
	# whether the end of the input has been reached.
	cmp p_input, p_end
	b.ne 1b

	mov x19, lr
	ldr x0, =.Lformat
	mul w1, x, z
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
