.syntax unified
.text
.global main
main:
	# Adhere to the calling convention: we're going to use R4 and R5, so we
	# need to preserve their values from the caller. On top of that, we're
	# going to call out to (f)printf, so we need to keep track of the link
	# register so we don't lose track of where we should return to.
	push {r4-r5, lr}

	# Set R5 to the constant value 2020. We'll use it as the operand to a CMP
	# later, since 2020 is too large to use as an immediate value in the CMP
	# instruction.
	mov r5, $2020

	# Since the very first instruction after the loop_a_start label is going to
	# increment R0 by 1, initialise R0 to all bits 1, so that the increment
	# will overflow to zero, starting the first iteration as desired.
	mvn r0, $0

.Lloop_a_start:
	add r0, $1
	cmp r0, max_iter_a
	beq .Lloop_a_completed

	# Load the input value at index R0 into R2. We'll keep it there for the
	# remainder of the iteration to avoid repeatedly fetching it from RAM.
	#
	# It first loads the address of input into R2 using an ADR instruction, and
	# then uses LDR to calculate the appropriate offset using a 2-bit left-
	# shifted R0; in other words: R2 = input + R0*4
	adr r2, input
	ldr r2, [r2, r0, LSL#2]

	mov r1, r0
.Lloop_b_start:
	add r1, $1
	cmp r1, max_iter_b
	beq .Lloop_a_start

	# As above, load the next input value into R3. While we'll only use it once
	# in this iteration, if it's the value that makes the sum match the target,
	# we can again re-use it when calculating the product that will be the
	# algorithm result.
	adr r3, input
	ldr r3, [r3, r1, LSL#2]

	# Test the sum against the target value, and repeat the inner loop if it's
	# no match.
	add r4, r2, r3
	cmp r4, r5
	bne .Lloop_b_start

	# If we didn't branch, then we've found the pair we're looking for. Since
	# we're out of the loop, we can now freely clobber R0 and R1 which
	# previously held the loop indices.
	ldr r0, =format_string
	mul r1, r2, r3
	bl printf  @ printf(format_string, product)

	mov r0, #0; pop {r4-r5, pc}  @ return 0

.Lloop_a_completed:
	ldr r0, =stderr
	ldr r0, [r0]
	ldr r1, =error_string
	bl fprintf  @ fprintf(stderr, error_string)

	mov r0, #1; pop {r4-r5, pc}  @ return 1

.include "2020-01.inc"
.set max_iter_b, (. - input) / 4
.set max_iter_a, max_iter_b - 1
format_string: .asciz "%d\n"
error_string: .asciz "Error: no result found!\n"
