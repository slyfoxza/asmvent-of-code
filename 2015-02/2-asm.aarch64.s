.global main
main:
	movi v31.4s, 0

	pInput .req x9
	pEnd .req x10
	adr pInput, .Linput
	add pEnd, pInput, stride

1:
	ldur q16, [pInput]
	mov w0, stride
	ldr q17, [pInput, x0]
	lsl w0, w0, 1
	ldr q18, [pInput, x0]

	# Calculate W+H, H+L, W+L
	add v19.4s, v16.4s, v17.4s
	add v20.4s, v17.4s, v18.4s
	add v21.4s, v16.4s, v18.4s

	# Calculate:
	#     result += 2 * min(W+H, H+L, W+L)
	umin v19.4s, v19.4s, v20.4s
	umin v19.4s, v19.4s, v21.4s
	add v31.4s, v31.4s, v19.4s
	add v31.4s, v31.4s, v19.4s

	# Calculate
	#     result += W * H * L
	mul v22.4s, v16.4s, v17.4s
	mul v22.4s, v22.4s, v18.4s
	add v31.4s, v31.4s, v22.4s

	# Loop logic
	add pInput, pInput, 16
	cmp pInput, pEnd
	b.ne 1b

	mov x19, lr
	adr x0, .Lformat
	addv s31, v31.4s
	mov w1, v31.s[0]
	bl printf
	mov lr, x19

	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
