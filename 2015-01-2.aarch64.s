.text
.global main
main:
	# W1 is the equivalent of the "value" local variable in the reference
	# implementation.
	mov w1, 0

	# X0 and X2 will hold the addresses of the first and last input bytes,
	# respectively.
	adr x0, .Linput
	adr x2, input_end
.Lloop_start:
	# See 2015-01-1.aarch64.s; the same explanation applies.
	ldrb w3, [x0], 1
	cmp w3, 0x28
	sub w4, w1, 1
	csinc w1, w4, w1, ne

	# If W1 has dipped into the negatives, break out of the loop.
	cmp w1, 0
	b.lt .Lexit_success

	# The post-indexed addressing already incremented X0, so we just need to
	# conditionally jump to the loop start if it hasn't reached the end of the
	# input yet.
	cmp x0, x2
	b.ne .Lloop_start

	# If we somehow don't find the target value, exit with a non-zero result.
	mov w0, 1
	ret

.Lexit_success:
	mov x19, lr
	# Calculate the difference between X0 (the byte address one after -- due to
	# post-indexed addressing -- which W1 became negative) and the start of the
	# input string, yielding a 1-based distance number.
	adr x2, .Linput
	sub x1, x0, x2
	# printf(format_string, X1)
	ldr x0, =.Lformat_string
	bl printf
	mov lr, x19

	# Exit with a zero result.
	mov w0, 0
	ret

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2015-01.inc"
