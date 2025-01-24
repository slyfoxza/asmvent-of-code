.global main
main:
	# The RISC-V ABI specifies integer parameters are passed in the A# registers. For
	# printf(format, ...), that means the first vararg will be in A1. We'll use this register to
	# calculate the output value, which means it'll already be where it needs to be when printf is
	# called.
	li a1, 0
	# RISC-V only supports register-register comparisons, so we'll load the ASCII value for '('
	# into A2.
	li a2, 0x28

	# Store the begin and end addresses of the input in the T0 and T1 temporary registers.
	lla t0, .Linput
	lla t1, input_end

1:
	# Read the next character into A0.
	lb a0, 0(t0)
	# We need to either increment or decrement A1, depending on the value of the current character
	# in A0. Unlike x86-64 and AArch64, there aren't any clever conditional arithmetic instructions
	# if the Zicond extension isn't present, so we do this with the tedious if/else approach.
	li a3, 1
	beq a0, a2, 2f
	li a3, -1
2:
	add a1, a1, a3

	# Loop logic: increment T0 and check if we've reached T1 (input end).
	addi t0, t0, 1
	bne t0, t1, 1b

	# The CALL pseudo-instruction writes the return address into RA. In doing so, it overwrites the
	# address we need to return to when exiting, so save the current LR value in S0 (which is a
	# callee-saved) register, and so will persist when printf returns.
	#
	# A reminder that we wrote the output value into A1, so we only need to update A0 with the
	# address of the format string before calling printf.
	mv s0, ra
	lla a0, .Lformat
	call printf
	# Now that printf has returned, we can restore the RA for when we return.
	mv ra, s0

	# The ABI specifies that return values are returned starting in A0, so that's where the exit
	# code for our main() goes.
	li a0, 0
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
