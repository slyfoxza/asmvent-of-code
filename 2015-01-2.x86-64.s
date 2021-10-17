.intel_syntax noprefix
.text
.global main
main:
	# R9 is the equivalent of the "value" local variable in the reference
	# implementation.
	xor r9, r9

	# R10 and R11 will hold the addresses of the first and last input bytes,
	# respectively.
	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]
.Lloop_start:
	# if (*r10 == '(')
	cmp byte ptr [r10], 0x28
	# Instead of writing an if/else with JMPs, this calculates both R9+1 and
	# R9-1 into R9 and RAX, respectively. This assumes that the increment path
	# will be taken, and then uses the CMOVNZ conditional move to overwrite it
	# with RAX if the decrement path was instead the correct one.
	lea rax, [r9 - 1]
	lea r9, [r9 + 1]
	cmovnz r9, rax

	# If R9 has dipped into the negatives, break out of the loop.
	cmp r9, 0
	jl .Lexit_success

	# Increment the R10 "pointer", and conditionally jump to the loop start if
	# it hasn't reached the end of the input yet.
	inc r10
	cmp r10, r11
	jnz .Lloop_start

	# If we somehow don't find the target value, exit with a non-zero result.
	mov eax, 1
	ret

.Lexit_success:
	xor eax, eax
	# Calculate the difference between R10 (the byte address at which R9 became
	# negative) and the start of the input string, and add 1 to make it a
	# 1-based number instead of a 0-based offset.
	#
	# We use LEA to calculate R10 - RDI + 1 and store the result in RSI to pass
	# to printf as the second argument, which is an instruction shorter than:
	#
	#     mov rsi, r10
	#     sub rsi, rdi
	#     inc rsi
	lea rdi, [rip + .Linput]
	neg rdi
	lea rsi, [r10 + rdi + 1]
	# printf(format_string, r10 - input + 1)
	lea rdi, [rip + .Lformat_string]
	call printf

	# Exit with a zero result.
	xor eax, eax
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-01.inc"
