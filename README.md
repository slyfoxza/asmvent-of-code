# ASMvent of Code

Just some low-level implementations of solutions to Advent of Code puzzles, across multiple architectures.
Reference implementations in C are also provided alongside the assembler implementations, so as to examine the compiler's output.

## Development

Each day is implemented in a subfolder consisting of the year/day pair, like `2015-01`.
The top-level `Makefile` supports recursing into each subdirectory, which should have its own `Makefile` as a symbolic link to `Makefile.subdir` in the root directory, providing common build logic.

Rather than implementing file I/O and parsing in assembly, each input file is translated to a C header file (for C reference implementations) and an assembler include that defines the input data in a format amenable to processing.
The `makemake` script is responsible for generating a `Makefile` fragment that will generate these input includes.
