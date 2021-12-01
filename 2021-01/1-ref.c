#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	unsigned count = 0;
	for(const int *p = input; p != input + sizeof(input) / sizeof(*input) - 1; ++p) {
		if(*p < *(p + 1)) {
			count++;
		}
	}
	printf("%u\n", count);
	return 0;
}
