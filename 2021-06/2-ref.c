#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "input.h"

int main() {
	unsigned long counts[9] = {0};
	for(const int32_t *p = input; p != input + sizeof(input) / sizeof(*input); ++p) {
		counts[*p]++;
	}

	for(unsigned i = 0; i < 256; ++i) {
		unsigned long resetCount = counts[0];
		memmove(counts, counts + 1, sizeof(counts) - sizeof(*counts));
		counts[6] += resetCount;
		counts[8] = resetCount;
	}

	unsigned long value = 0;
	for(unsigned i = 0; i < 9; ++i) {
		value += counts[i];
	}
	printf("%ld\n", value);

	return 0;
}
