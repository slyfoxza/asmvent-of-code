.global main
main:
	xor eax, eax  # X
	xor esi, esi  # Z

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	movzx r9d, byte ptr [r10 + 1]
	cmp byte ptr [r10], 0x66  # 0x66 = 'f'
	# If the direction is 'f', branch to the next 3 label to handle updating
	# the EAX/X value.
	je 3f
	# If we didn't branch, direction is either 'd' or 'u', which is less than
	# and greater than 'f', respectively. If it's greater, branch to the next 2
	# label, or if it's smaller, add the value to ESI/Z.
	jg 2f
	add esi, r9d
	jmp 4f
2:
	# The direction was 'u', so subtract the value from ESI/Z
	sub esi, r9d
	jmp 4f
3:
	# If the direction was 'f', add the value to EAX/X
	add eax, r9d
4:
	add r10, 2
	cmp r10, r11
	jnz 1b

	# X is already in EAX, which is one of the hard-wired operands for MUL, but
	# then we need to take the multiplication result from EAX into ESI for the
	# printf call.
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
