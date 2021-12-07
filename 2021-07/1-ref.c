#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "input.h"

int main() {
	unsigned minFuel = ~0;
	const int32_t *end = input + sizeof(input) / sizeof(*input);
	for(const int32_t *i = input; i != end; ++i) {
		unsigned fuel = 0;
		for(const int32_t *j = input; j != end; ++j) {
			fuel += abs(*i - *j);
		}

		if(fuel < minFuel) {
			minFuel = fuel;
		}
	}

	printf("%d\n", minFuel);
	return 0;
}
