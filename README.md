# ASMvent of Code

Just some low-level implementations of solutions to Advent of Code puzzles, across multiple architectures.

## Notes

There are a few common patterns across multiple implementations.
Instead of repeatedly annotating them in each source file, I'll instead list them here.

### AArch64

Branch with link (`BL`) instructions clobber LR (X30, the link register), so its original value needs to be saved for your own `RET` when making subroutine calls.
My approach is to store it in the X19 register, since it is the first callee-saved register in the AArch64 calling convention, meaning it will still be there on the return from the subroutine.

### x86-64

Because `printf` is a variadic function, the number of floating point arguments passed in vector registers must be stored in AL.
Since most implementations in this repository only deal with integer values, calls to `printf` are usually preceded by `xor eax, eax` to zero out the register, lest the call to `printf` cause a segmentation fault.
