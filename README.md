Just some low-level implementations of solutions to Advent of Code puzzles, across multiple architectures.

Rather than do file I/O and conversion in assembly, there's an awk script that will convert numeric input to an assembler directive dumping the values as integers in the resulting binary.

Assembly sources are sprinkled liberally with comments, and each part should have an accompanying `.doc` file explaining the method behind the madness.

The assembly probably sucks, especially in ARM, since my knowledge in that architecture is probably just enough to be considered dangerous, but at least it outputs the correct answer.
