.syntax unified
.text
.global main
main:
	# Push the callee-saved registers we plan on using (R4-R5) to the stack, as
	# well as the link register.
	push {r4-r5, lr}
	# R5 will contain the output value: the number of valid passwords in the
	# input. Initialize it to zero.
	mov r5, 0
	# Initialize R0 with the first byte address of the input.
	ldr r0, =input
.Lloop_start:
	# Load the first index byte. If its value is 0, then it menas we've reached
	# the end of the input, and are seeing the zero byte emitted at the
	# .Lend_input symbol, and should branch to the output section of the
	# program.
	ldrb r1, [r0]
	cmp r1, 0
	beq .Lloop_completed
	# In sequence, load the second index byte, the target value, and the string
	# length byte into R2-4, updating R0 on the final LDRB using pre-indexed
	# addressing.
	ldrb r2, [r0, 1]
	ldrb r3, [r0, 2]
	ldrb r4, [r0, 3]!
	# R0 currently points to the string length byte, but because the index
	# bytes are 1-based, that actually works out perfectly, since R0+1 would
	# place us at the first password character. Perfection.
	#
	# Load password[R1] and password[R2] into R1 and R2, respectively.
	ldrb r1, [r0, r1]
	ldrb r2, [r0, r2]
	# Update R0 to point at the start of the next input record.
	add r0, r0, r4
	add r0, r0, 1
	# Store the comparison values of R1/R2 and R3 into R1/R2. A result of zero
	# means R1/R2 == R3.
	sub r1, r1, r3
	sub r2, r2, r3
	# If R1 == R2, then the password is invalid; branch to the loop start.
	cmp r1, r2
	beq .Lloop_start
	# If R1 != R2 && R1 == 0, then the password is valid; increment R5 and
	# branch to the loop start.
	cmp r1, 0
	addeq r5, r5, 1
	beq .Lloop_start
	# Finally, if R1 != R2 && R1 != 0 && R2 == 0, then the password is valid;
	# increment R5. Then, unconditionally branch to the loop start, which
	# simultaneously takes care of the case where R1 != 0 && R2 != 0.
	cmp r2, 0
	addeq r5, r5, 1
	b .Lloop_start

.Lloop_completed:
	# printf(format_string, result)
	ldr r0, =.Lformat_string
	mov r1, r5
	bl printf

	# return 0
	mov r0, 0
	pop {r4-r5, pc}

.section .rodata
.Lformat_string: .asciz "%d\n"
.include "2020-02.txt.s"
.Lend_input: .byte 0
