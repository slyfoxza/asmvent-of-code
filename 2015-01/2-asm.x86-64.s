.global main
main:
	sub rsp, 8

	# Unlike the first part, we'll store the running sum in R9 instead of ESI, since the output
	# value we want to print is a different value. Like, R10 and R11, R9 is not callee-saved (in
	# fact, it is one of the integer argument registers).
	xor r9d, r9d

	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	# Increment or decrement R9D depending on [R10].
	lea eax, [r9d - 1]
	inc r9d
	cmp byte ptr [r10], 0x28
	cmovne r9d, eax

	# If the running sum is now a negative value, we can stop iterating over the input.
	cmp r9d, 0
	jl 2f

	# Loop logic
	inc r10
	cmp r10, r11
	jne 1b

	# If, somehow, we manage to exit the loop without having reached a negative value, exit with an
	# error result.
	mov eax, 1
	add rsp, 8
	ret

2:
	# The output value should be the 1-based position at which the running sum became negative.
	# Since R10 still contains the 0-based index of that point, we can take the difference of R10
	# and the start of the input to determine this value. Storing the address of the input start in
	# R8 (another argument register), this corresponds to R10 - R8 + 1. Again, we use LEA to do
	# this arithmetic, however, there's a wrinkle: R10 - R8 + 1 is not encodable in LEA, so we need
	# to introduce a NEG R8.
	#
	# Using the NEG/LEA combination yields code that is slightly more compact than the more
	# "obvious" SUB/ADD/MOV sequence:
	#   49 F7 D8 4B 8D 74 02 01       (NEG/LEA)
	#   4D 29 C2 49 83 C2 01 4C 98 D6 (SUB/ADD/MOV)
	#
	# No claim is made as to the actual performance difference.
	lea r8, [rip + .Linput]
	neg r8
	lea rsi, [r10 + r8 + 1]
	lea rdi, [rip + .Lformat]
	xor eax, eax
	call printf

	xor eax, eax
	add rsp, 8
	ret

.section .rodata
.Lformat: .asciz "%u\n"
.include "input.inc"
