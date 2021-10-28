.global main
main:
	# Use ESI to store the output value, which means it will already be in the
	# correct register to be an argument to printf later.
	xor esi, esi

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	# Calculate both ESI-1 and ESI+1, storing the latter. Then, check what the
	# actual character was and overwrite ESI with the other value if it was not
	# '('.
	lea eax, [esi - 1]
	inc esi
	cmp byte ptr [r10], 0x28  # 0x28 = '('
	cmovnz esi, eax

	inc r10
	cmp r10, r11
	jnz 1b

	xor eax, eax
	lea rdi, [rip + .Lformat]
	call printf

	xor eax, eax
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
