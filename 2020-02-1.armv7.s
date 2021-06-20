.syntax unified
.text
.global main
main:
	# Push the callee-saved registers we plan on using (R4-R7) to the stack, as
	# well as the link register.
	push {r4-r7, lr}
	# R7 will contain the output value: the number of valid passwords in the
	# input. Initialize it to zero.
	mov r7, 0
	# Initialize R0 with the first byte address of the input.
	ldr r0, =input
.Lloop_start:
	# Load the first range byte. If its value is 0, then it means we've reached
	# the end of the input, and are seeing the zero byte emitted at the
	# .Lend_input symbol, and should branch to the output section of the
	# program.
	ldrb r1, [r0]
	cmp r1, 0
	beq .Lloop_completed
	# Since we'll use the second range byte at most once, we'll load it from
	# memory at that point only. Store the address of that byte in R6, given
	# we'll be mutating R0 as we go on.
	add r6, r0, 1
	# Load the target value into R2.
	ldrb r2, [r0, 2]
	# Load the string length byte into R3, and use pre-indexed addressing to
	# update R0 to point at the first password character.
	ldrb r3, [r0, 3]!
	# Add R3 to R0 to have R3 contain the address of the final password
	# character, for use as a loop terminating condition.
	add r3, r0, r3

	# Zero out R4, since we'll use it to count the number of times the target
	# character is found in the string.
	mov r4, 0
.Lscan_start:
	# Load the current password character into R5, using pre-indexed addressing
	# to simultaneously increment R0 to the next character.
	ldrb r5, [r0, 1]!
	# Check if the current character matches the target character, and
	# increment R4 if it does.
	cmp r5, r2
	addeq r4, r4, 1
	# As long as R0 <= R3, we're still iterating over password characters, so
	# branch back to the scan start.
	cmp r0, r3
	ble .Lscan_start
	# We only want to increment R7 if R4 >= R1 and R4 <= [R6]. That means that,
	# for the first term, we wish to branch to the next loop iteration if R4 <
	# R1. If we didn't branch on the first term, then for the second term, we
	# will only increment R7 if R4 <= R6, by adding an LS condition to the ADD
	# instruction, before unconditionally branching back to the overall loop
	# start to continue to the next password, or terminate.
	cmp r4, r1
	blt .Lloop_start
	ldrb r6, [r6]
	cmp r4, r6
	addls r7, r7, 1
	b .Lloop_start

.Lloop_completed:
	# printf(format_string, result)
	ldr r0, =.Lformat_string
	mov r1, r7
	bl printf

	# return 1
	mov r0, 0
	pop {r4-r7, pc}

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2020-02.inc"
.Lend_input: .byte 0
