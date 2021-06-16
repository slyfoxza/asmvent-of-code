.intel_syntax noprefix

.text
.include "2020-02.txt.s"
.Lend_input: .byte 0
format_string: .asciz "%d\n"

.global main
main:
	# Ensure that the direction flag is cleared so that the SCASB instruction
	# later will increment the memory address stored in RDI.
	cld
	# Zero out registers that we'll be using as 8-bit registers later on.
	xor eax, eax
	xor ecx, ecx
	xor r8d, r8d
	# R9 will contain the output value: the number of valid passwords in the
	# input. Initialize it to zero.
	xor r9d, r9d
	# Initialize RDI with the first byte address of the input.
	lea rdi, [rip + input@PLT]

.Lloop_start:
	# Load the first range byte. If its value is 0, then it means we've reached
	# the end of the input, and are seeing the zero byte emitted at the
	# .Lend_input symbol, and should jump to the output section of the program.
	mov r8b, [rdi]
	cmp r8b, 0
	je .Lloop_completed
	# Since we'll use the second range byte at most once, we'll load it
	# directly from memory at that point. Store the address of that byte in
	# RDX, given RDI will be changed by SCASB.
	lea rdx, [rdi + 1]
	# Load the target value into AL, required by SCASB.
	mov al, [rdi + 2]
	# Load the string length byte into EL, required by LOOP.
	mov cl, [rdi + 3]
	# Increment RDI by 4 bytes, placing it at the start of the password string.
	add rdi, 4

	# Zero out R10, since we'll use it to count the number of times AL is in
	# the password string.
	xor r10d, r10d
.Lscan_start:
	# Use SCASB and LOOP to count the number of times that AL occurs in the
	# password string. LOOP will decrement ECX and jump until it reaches a zero
	# value, while R10 will be incremented each time SCASB returns a match.
	scasb
	jne 1f
	inc r10b
1:
	loop .Lscan_start

	# We only want to increment R9 if R10 >= R8 and R10 <= [RDX]. Equivalently,
	# we wish to jump to the next loop iteration if R10 < R8 or R10 > [RDX].
	cmp r10b, r8b
	jl .Lloop_start
	cmp r10b, [rdx]
	jg .Lloop_start
	inc r9d
	jmp .Lloop_start

.Lloop_completed:
	lea rdi, [rip + format_string@PLT]
	mov esi, r9d
	xor eax, eax
	call printf  # printf(format_string, count)
	mov eax, 0; ret  # return 0
