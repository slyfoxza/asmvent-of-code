#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "input.h"

int main() {
	unsigned counts[9] = {0};
	for(const int32_t *p = input; p != input + sizeof(input) / sizeof(*input); ++p) {
		counts[*p]++;
	}

	for(unsigned i = 0; i < 80; ++i) {
		unsigned resetCount = counts[0];
		memmove(counts, counts + 1, sizeof(counts) - sizeof(*counts));
		counts[6] += resetCount;
		counts[8] = resetCount;
	}

	unsigned value = 0;
	for(unsigned i = 0; i < 9; ++i) {
		value += counts[i];
	}
	printf("%d\n", value);

	return 0;
}
