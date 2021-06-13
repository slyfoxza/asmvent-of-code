.syntax unified
.text
.global main
main:
	# Save the link register to the stack so that we know where to return to
	# later, given we'll also be calling printf which would clobber the LR.
	push {lr}

	# Set R9 to the constant value 2020. We'll use it as the operand to a CMP
	# later, since 2020 is too large to use as an immediate value in the CMP
	# instruction.
	mov r9, $2020

	# Since the very first instruction after the loop_a_start label is going to
	# increment R4 by 1, initialise R4 to all bits 1, so that the increment
	# will overflow to zero, starting the first iteration as desired.
	mvn r4, $0

.Lloop_a_start:
	add r4, $1
	cmp r4, max_iter_a
	beq .Lloop_a_completed

	# Load the input value at index R4 into R6. We'll keep it there for the
	# remainder of the iteration to avoid repeatedly fetching it from RAM.
	#
	# It first loads the address of input into R6 using an ADR instruction, and
	# then uses LDR to calculate the appropriate offset using a 2-bit left-
	# shifted R4; in other words: R6 = input + R4*4
	adr r6, input
	ldr r6, [r6, r4, LSL#2]

	mov r5, r4
.Lloop_b_start:
	add r5, $1
	cmp r5, max_iter_b
	beq .Lloop_a_start

	# As above, load the next input value into R7. While we'll only use it once
	# in this iteration, if it's the value that makes the sum match the target,
	# we can again re-use it when calculating the product that will be the
	# algorithm result.
	adr r7, input
	ldr r7, [r7, r5, LSL#2]

	# Test the sum against the target value, and repeat the inner loop if it's
	# no match.
	add r8, r6, r7
	cmp r8, r9
	bne .Lloop_b_start

	# If we didn't branch, then we've found the pair we're looking for.
	ldr r0, =format_string
	mul r1, r6, r7
	bl printf  @ printf(format_string, product)

	mov r0, #0; pop {pc}  @ return 0

.Lloop_a_completed:
	ldr r0, =stderr
	ldr r0, [r0]
	ldr r1, =error_string
	bl fprintf  @ fprintf(stderr, error_string)

	mov r0, #1; pop {pc}  @ return 1

.include "2020-01.txt.s"
.set max_iter_b, (. - input) / 4
.set max_iter_a, max_iter_b - 1
format_string: .asciz "%d\n"
error_string: .asciz "Error: no result found!\n"
