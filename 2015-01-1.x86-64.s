.intel_syntax noprefix
.text
.global main
main:
	# ESI will be equivalent to the "value" local variable in the reference
	# implementation. It serves a dual purpose of being the second integer
	# argument that will be passed to printf.
	xor esi, esi

	# R10 and R11 will hold the addresses of the first and last input bytes,
	# respectively.
	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]
.Lloop_start:
	# if (*r10 == '(')
	cmp byte ptr [r10], 0x28
	# Instead of writing an if/else with JMPs, this calculates both ESI+1 and
	# ESI-1 into ESI and EAX, respectively. This assumes that the increment
	# path will be taken, and then uses the CMOVNZ conditional move to
	# overwrite it with EAX if the decrement path was instead the correct one.
	lea eax, [esi - 1]
	lea esi, [esi + 1]
	cmovnz esi, eax

	# Increment the R10 "pointer", and conditionally jump to the loop start if
	# it hasn't reached the end of the input yet.
	inc r10
	cmp r10, r11
	jnz .Lloop_start

	# Reminder: ESI already contains the integer value we want to print, so we
	# only have to load the format string's address:
	#
	#     printf(format_string, value);
	xor eax, eax
	lea rdi, [rip + .Lformat_string]
	call printf

	# Exit with a zero result.
	xor eax, eax
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-01.inc"
