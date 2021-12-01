.global main
main:
	# Use ESI to store the output value, which means it will already be in the
	# correct register to be an argument to printf later.
	xor esi, esi

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end - 4]

1:
	# Calculate ESI+1 and store it in EAX. Then, compare the two adjacent
	# values and conditionally overwrite ESI with EAX is the second value is
	# greater than the first value.
	lea eax, [esi + 1]
	mov r9d, [r10]
	cmp dword ptr [r10 + 4], r9d
	cmovg esi, eax

	add r10, 4
	cmp r10, r11
	jnz 1b

	xor eax, eax
	lea rdi, [rip + .Lformat]
	call printf

	xor eax, eax
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
