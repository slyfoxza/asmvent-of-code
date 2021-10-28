# ASMvent of Code

Just some low-level implementations of solutions to Advent of Code puzzles, across multiple architectures.

## Notes

There are a few common patterns across multiple implementations.
Instead of repeatedly annotating them in each source file, I'll instead list them here.

### x86-64

Because `printf` is a variadic function, the number of floating point arguments passed in vector registers must be stored in AL.
Since most implementations in this repository only deal with integer values, calls to `printf` are usually preceded by `xor eax, eax` to zero out the register, lest the call to `printf` cause a segmentation fault.
