.global main
main:
	xor r9d, r9d

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	# As with the first part, calculate both R9D-1 and R9D+1.
	lea eax, [r9d - 1]
	inc r9d
	cmp byte ptr [r10], 0x28
	cmovnz r9d, eax

	cmp r9d, 0
	jl 2f

	inc r10
	cmp r10, r11
	jnz 1b

	mov eax, 1
	ret

2:
	xor eax, eax
	# Calculate the difference between the current pointer value and the start
	# of the input, i.e. R10 - RDI + 1
	lea rdi, [rip + .Linput]
	neg rdi
	lea rsi, [r10 + rdi + 1]
	lea rdi, [rip + .Lformat]
	call printf

	xor eax, eax
	ret

.section .rodata
.Lformat: .asciz "%zd\n"
.include "input.inc"
