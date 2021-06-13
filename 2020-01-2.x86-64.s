.intel_syntax noprefix

.text
.include "2020-01.txt.s"
.set max_iter_c, (. - input) / 4
.set max_iter_b, max_iter_c - 1
.set max_iter_a, max_iter_b - 1
format_string: .asciz "%d\n"
error_string: .asciz "Error: no result found!\n"

# This part is going to have less comments, since it's basically the same as in
# 2020-01-1, except for the addition of another nested loop.
.global main
main:
	mov esi, 0xFFFFFFFF

.Lloop_a_start:
	inc esi
	cmp esi, max_iter_a
	je .Lloop_a_completed

	lea r8, [rip + input@PLT]
	mov r8d, [r8 + rsi*4]

	mov edi, esi
.Lloop_b_start:
	inc edi
	cmp edi, max_iter_b
	je .Lloop_a_start

	lea r9, [rip + input@PLT]
	mov r9d, [r9 + rdi*4]

	mov r10d, edi
.Lloop_c_start:
	inc r10d
	cmp r10d, max_iter_c
	je .Lloop_b_start

	lea r11, [rip + input@PLT]
	mov r11d, [r11 + r10*4]

	mov eax, r8d
	add eax, r9d
	add eax, r11d
	cmp eax, 2020
	jne .Lloop_c_start

	mov eax, r8d
	mul r9d
	mul r11d

	lea rdi, [rip + format_string@PLT]
	mov esi, eax
	xor eax, eax
	call printf  # printf(format_string, product)
	mov eax, 0; ret  # return 0

.Lloop_a_completed:
	mov rdi, stderr
	lea rsi, [rip + error_string@PLT]
	xor eax, eax
	call fprintf  # fprintf(stderr, error_string)
	mov eax, 1; ret  # return 1
