.global main
main:
	xor esi, esi

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end - (4 * 3)]

1:
	# Because we are going to compare the sum of two 3-wide measurement window
	# that overlap, we only actually have to compare the first value of the
	# first window to the last value of the second window.
	#
	# 199  A
	# 200  A B
	# 208  A B
	# 210    B
	#
	# Since the comparison is `199 + 200 + 208 < 200 + 208 + 210`, the
	# overlapping terms are irrelevant, and we can simplify to `199 < 210`.

	# As with the first part, calculate ESI+1 into EAX, and then conditionally
	# update ESI based on the comparison of the two values.
	lea eax, [esi + 1]
	mov r9d, [r10]
	cmp dword ptr [r10 + (4 * 3)], r9d
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
