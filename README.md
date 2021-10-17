# ASMvent of Code

Just some low-level implementations of solutions to Advent of Code puzzles, across multiple architectures.
Each solution is accompanied by a reference implementation in C, since it's pretty cool seeing what whacky hijinks GCC gets up to with `-O3` using `objdump --disassemble`.

On a related point, the assembly implementations given here probably suck.
They do not attempt to be overly clever, nor are they particularly optimised either.
I find it interesting to see how different naive implementations are from the optimised versions GCC yields.

## Notes

There are a few common patterns across multiple implementations.
Instead of repeatedly annotating them in each source file, I'll instead list them here.

### x86-64

Because `printf` is a variadic function, it's always (in this repository) preceded by `xor eax, eax` to zero out AL, which (per the System V AMD64 ABI) indicates the number of floating point arguments passed in vector registers.
Not doing this results in Bad Times, also known as `SIGSEGV`.
