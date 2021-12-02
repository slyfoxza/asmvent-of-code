.global main
main:
	xor ebx, ebx  # X
	xor esi, esi  # Z
	xor edi, edi  # aim

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	movzx r9d, byte ptr [r10 + 1]
	# Apply the same kind of conditional logic as in the first part
	cmp byte ptr [r10], 0x66
	je 3f
	jg 2f
	add edi, r9d
	jmp 4f
2:
	sub edi, r9d
	jmp 4f
3:
	add ebx, r9d
	# Shuffle some registers because MUL has a hard-wired input/output operand
	# of EAX.
	mov eax, edi
	mul r9d
	add esi, eax
4:
	add r10, 2
	cmp r10, r11
	jnz 1b

	# More MUL-related register shuffling, much like in part 1.
	mov eax, ebx
	mul esi
	mov esi, eax
	xor eax, eax
	lea rdi, [rip + .Lformat]
	call printf

	xor eax, eax
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
