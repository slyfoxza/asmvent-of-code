.intel_syntax noprefix

.text
.global main
main:
	# Since the very first instruction after the loop_a_start label is going to
	# be an INC ESI, initialise ESI to all bits 1, so that the increment will
	# overflow to zero, starting the first iteration as desired.
	mov esi, 0xFFFFFFFF

.Lloop_a_start:
	inc esi
	cmp esi, offset max_iter_a
	je .Lloop_a_completed

	# Load the input value at index ESI into R8. We'll keep it there for the
	# remainder of the iteration to avoid repeatedly fetching it from RAM.
	lea r8, [rip + input]
	mov r8d, [r8 + rsi*4]

	mov edi, esi
.Lloop_b_start:
	inc edi
	cmp edi, offset max_iter_b
	je .Lloop_a_start

	# As above, load the next input value into R9. While we'll only use it once
	# in this iteration, if it's the value that makes the sum match the target,
	# we can again re-use it when calculating the product that will be the
	# algorithm result.
	lea r9, [rip + input]
	mov r9d, [r9 + rdi*4]

	# Test the sum against the target value, and repeat the inner loop if it's
	# no match.
	mov eax, r8d
	add eax, r9d
	cmp eax, 2020
	jne .Lloop_b_start

	# If we didn't jump, then we've found the pair we're looking for.
	mov eax, r8d
	mul r9d

	lea rdi, [rip + format_string]
	mov esi, eax
	xor eax, eax  # zero vector registers used for varargs
	call printf  # printf(format_string, product)
	mov eax, 0; ret  # return 0

.Lloop_a_completed:
	# If we've run through the entire range for the outer loop, then it means
	# that we didn't find what we were looking for. Print an error message and
	# fail out.
	mov rdi, stderr
	lea rsi, [rip + error_string]
	xor eax, eax  # zero vector registers used for varargs
	call fprintf  # fprintf(stderr, error_string)
	mov eax, 1; ret  # return 1

.section .rodata
format_string: .asciz "%d\n"
error_string: .asciz "Error: no result found!\n"
.include "2020-01.inc"
.set max_iter_b, (. - input) / 4
.set max_iter_a, max_iter_b - 1
