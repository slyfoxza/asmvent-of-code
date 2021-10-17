.intel_syntax noprefix
.text
.global main
main:
	# R13 is the equivalent of the "value" local variable in the reference
	# implementation.
	xor r13, r13

	# R14 and R15 will hold the addresses of the first and last input bytes,
	# respectively.
	lea r14, [rip + .Linput]
	lea r15, [rip + input_end]
.Lloop_start:
	# if (*r14 == '(')
	cmp byte ptr [r14], 0x28
	# Instead of writing an if/else with JMPs, this calculates both R13+1 and
	# R13-1 into R13 and RAX, respectively. This assumes that the increment
	# path will be taken, and then uses the CMOVNZ conditional move to
	# overwrite it with RAX if the decrement path was instead the correct one.
	lea rax, [r13 - 1]
	lea r13, [r13 + 1]
	cmovnz r13, rax

	# If R13 has dipped into the negatives, break out of the loop.
	cmp r13, 0
	jl .Lexit_success

	# Increment the R14 "pointer", and conditionally jump to the loop start if
	# it hasn't reached the end of the input yet.
	inc r14
	cmp r14, r15
	jnz .Lloop_start

	# If we somehow don't find the target value, exit with a non-zero result.
	mov eax, 1
	ret

.Lexit_success:
	xor eax, eax
	lea rdi, [rip + .Lformat_string]
	# Calculate the difference between R14 (the byte address at which R13
	# became negative) and the start of the input string, and add 1 to make it
	# a 1-based number instead of a 0-based offset.
	#
	# We use LEA to calculate R14 - RBX + 1 and store the result in RSI to pass
	# to printf as the second argument, which is an instruction shorter than:
	#
	#     mov rsi, r14
	#     sub rsi, rbx
	#     inc rsi
	lea rbx, [rip + .Linput]
	neg rbx
	lea rsi, [r14 + rbx + 1]
	call printf

	# Exit with a zero result.
	xor eax, eax
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-01.inc"
