.text
.global main
main:
	# W1 will be equivalent to the "value" local variable in the reference
	# implementation. It serves a dual purpose of being the second integer
	# argument that will be passed to printf.
	mov w1, 0

	# X0 and X2 will hold the addresses of the first and last input bytes,
	# respectively.
	adr x0, .Linput
	adr x2, input_end
.Lloop_start:
	# if (*x0 == '(') -- note that this uses post-indexed addressing to
	# increment the value of X0 after the read completes.
	ldrb w3, [x0], 1
	cmp w3, 0x28
	# Calculate W1 being decremented, and then use CSINC to conditionally
	# select either the decremented value or an incremented W1 value based on
	# the result of the above CMP. Roughly:
	#
	#     if (w3 == '(') {
	#         w1 = w1 + 1
	#     } else {
	#         w1 = w1 - 1
	#     }
	sub w4, w1, 1
	csinc w1, w4, w1, ne

	# The post-indexed addressing already incremented X0, so we just need to
	# conditionally jump to the loop start if it hasn't reached the end of the
	# input yet.
	cmp x0, x2
	b.ne .Lloop_start

	# Reminder: W1 already contains the integer value we want to print, so we
	# only have to load the format string's address:
	#
	#     printf(format_string, W1);
	mov x19, lr
	ldr x0, =.Lformat_string
	bl printf
	mov lr, x19

	# Exit with a zero result.
	mov w0, 0
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-01.inc"
