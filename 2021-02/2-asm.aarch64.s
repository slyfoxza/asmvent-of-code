.global main
main:
	x .req w0
	z .req w1
	aim .req w2
	mov x, 0
	mov z, 0
	mov aim, 0

	p_input .req x3
	p_end .req x4
	adr p_input, .Linput
	adr p_end, input_end

1:
	direction .req w5
	value .req w6
	ldrb direction, [p_input], 1
	ldrb value, [p_input], 1
	# Apply the same kind of conditional logic as in the first part
	cmp direction, 0x66  // 0x66 = 'f'
	b.eq 2f
	cneg value, value, hi
	add aim, aim, value
	b 3f
2:
	add x, x, value
	madd z, aim, value, z
3:
	cmp p_input, p_end
	b.ne 1b

	mov x19, lr
	mul w1, x, z
	ldr x0, =.Lformat
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
