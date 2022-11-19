.global main
main:
	# Align the stack pointer to a 16-byte boundary, otherwise printf gets mighty upset when we
	# call it.
	sub rsp, 8

	# The System V ABI specifies integer parameters are passed in (in order) RDI and RSI. For
	# printf(format, ...), that means the first vararg will be in RSI. We'll use this register to
	# calculate the output value, which means it'll already be where it needs to be when printf is
	# called.
	#
	# Because writes to Exx registers are zero-extended to the full Rxx register, we can simply XOR
	# ESI with itself to zero out the entire RSI, saving us a whole byte on the REX prefix for
	# 64-bit operands.
	#
	# While we're here, why do this XOR business rather than just a MOV ESI, 0? Obviously, the MOV
	# is bigger in terms of code size, because there's a 4-byte immediate to encode, whereas XOR is
	# a simple 2-bye sequence. The other reason is that many x86 CPUs recognise the zeroing XOR
	# idiom, and optimise for it. See, for example, https://stackoverflow.com/a/33668295.
	xor esi, esi

	# Store the begin and end addresses of the input in R10 and R11, respectively. We pick these
	# registers because the ABI specifies that they are not callee-saved registers, meaning we
	# don't have to save their values for whichever function called main(). We also don't need them
	# to survive the printf call, so we don't care if they get clobbered by that function.
	lea r10, [rip + .Linput]
	lea r11, [rip + input_end]

1:
	# We need to either increment or decrement ESI, depending on the value of the current character
	# at [R10]. Doing this with an if/else equivalent feels tedious, so instead we use LEA to
	# calculate ESI-1 and store it in EAX, and also increment ESI (calculating ESI+1). Only then
	# does the comparison occur (0x28 is '('). If it turns out the character wasn't 0x28, then
	# overwrite ESI with EAX, which is the original ESI-1. Otherwise, stick with the increment ESI.
	lea eax, [esi - 1]
	inc esi
	cmp byte ptr [r10], 0x28
	cmovne esi, eax

	# Loop logic: increment R10, and check if we've hit R11 (input end).
	inc r10
	cmp r10, r11
	jne 1b

	# More ABI/calling convention stuff... printf is a variadic function, which means we need to
	# specify the number of floating point arguments passed in vector registers as a number in the
	# AL register. In this case, we're dealing with an integer value, and so EAX gets zeroed.
	xor eax, eax
	lea rdi, [rip + .Lformat]
	call printf

	# Per the ABI, we'll return the exit code for main() in RAX. Since we've completed
	# successfully, this value will be zero. Why do we need to zero it again after having done so
	# before calling printf? Because the ABI specifies that RAX is not preserved by the callee;
	# that is, printf could've stomped all over the value of RAX and left us with the mess.
	xor eax, eax
	# Undo the alignment done right in the prologue, or RET isn't going to find the right return
	# address...
	add rsp, 8
	ret

.section .rodata
.Lformat: .asciz "%d\n"
.include "input.inc"
