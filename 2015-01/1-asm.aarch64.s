.global main
main:
	# The AArch64 ABI specifies integer parameters are passed in (in order) X0 and X1. For
	# printf(format, ...), that means the first vararg will be in X1. We'll use this register to
	# calculate the output value, which means it'll already be where it needs to be when printf is
	# called.
	#
	# As with x86-64, writing to the lower 32 bits of X1 as W1 will zero out the upper 32 bits.
	# Unlike x86-64, there is no clear benefit to zeroing out a register using EOR instead of an
	# immediate MOV of 0, so we pick the clearer option, which is the MOV.
	value .req w1
	mov value, 0

	# Store the begin and end addresses of the input in X9 and X10, which are in the ABI-specified
	# range of caller-saved local variables.
	pInput .req x9
	pEnd .req x10
	adr pInput, .Linput
	adr pEnd, input_end

1:
	# Read the next character into W11 (another caller-saved local variable). The LDRB instruction
	# uses post-indexed addressing, which means that the load is performed from the current
	# address, and then the offsetted address is written back after the load. Effectively, this
	# means that X9 will be incremented after the load, removing the need to do so in the loop
	# logic section as a separate instruction.
	char .req w11
	ldrb char, [pInput], 1
	# We need to either increment or decrement W1, depending on the value of the current character
	# in W11. As with x86-64, doing this with an if/else equivalent feels tedious, so instead, we
	# calculate W1-1 and store it in W12 (local variable). We then compare the character to see if
	# it is a '(', and use the result to conditionally increment W1, or take the decremented value
	# that was stored in W12. That is, using the CSINC.NE instruction is roughly equivalent to:
	#   W12 = W1 - 1
	#   W1 = (W11 != '(') ? W12 : W1 + 1
	sub w12, value, 1
	cmp char, 0x28
	csinc value, w12, value, ne

	# Loop logic: X9 has already been incremented thanks to the post-indexed addressing, so we just
	# need to check whether we've reached R10 (input end).
	cmp pInput, pEnd
	b.ne 1b

	# The BL instruction writes the return address into LR, the link register. In doing so, it
	# overwrites the address we need to return to when exiting, so save the current LR value in
	# X19. Per the ABI, X19 is the first callee-saved register, and so will persist when printf
	# returns.
	#
	# A reminder that we wrote the output value into W1, so we only need to update X0 with the
	# address of the format string before calling printf.
	mov x19, lr
	adr x0, .Lformat
	bl printf
	# Now that printf has returned, we can restore the LR for when we return.
	mov lr, x19

	# The API specifies that return values are returned starting in X0, so that's where the exit
	# code for our main() goes.
	mov w0, 0
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
