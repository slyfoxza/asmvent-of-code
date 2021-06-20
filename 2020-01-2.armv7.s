.syntax unified
.text
# This part is going to have less comments, since it's basically the same as in
# 2020-01-1, except for the addition of another nested loop.
.global main
main:
	# Thanks to the extra loop, we use 2 more registers that need their values
	# preserved for the caller.
	push {r4-r7, lr}
	mov r7, $2020
	mvn r0, $0

.Lloop_a_start:
	add r0, $1
	cmp r0, max_iter_a
	beq .Lloop_a_completed

	adr r3, input
	ldr r3, [r3, r0, LSL#2]

	mov r1, r0
.Lloop_b_start:
	add r1, $1
	cmp r1, max_iter_b
	beq .Lloop_a_start

	adr r4, input
	ldr r4, [r4, r1, LSL#2]

	mov r2, r1
.Lloop_c_start:
	add r2, $1
	cmp r2, max_iter_c
	beq .Lloop_b_start

	adr r5, input
	ldr r5, [r5, r2, LSL#2]

	add r6, r3, r4
	add r6, r6, r5
	cmp r6, r7
	bne .Lloop_c_start

	ldr r0, =format_string
	mul r1, r3, r4
	mul r1, r5, r1
	bl printf  @ printf(format_string, product)

	mov r0, $0; pop {r4-r7, pc}  @ return 0

.Lloop_a_completed:
	ldr r0, =stderr
	ldr r0, [r0]
	ldr r1, =error_string
	bl fprintf  @ fprintf(stderr, error_string)

	mov r0, $1; pop {r4-r7, pc}  @ return 1

.include "2020-01.inc"
.set max_iter_c, (. - input) / 4
.set max_iter_b, max_iter_c - 1
.set max_iter_a, max_iter_b - 1
format_string: .asciz "%d\n"
error_string: .asciz "Error: no result found!\n"
