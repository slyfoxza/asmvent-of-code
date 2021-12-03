#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	uint16_t gammaRate = 0;
	for(int i = 0; i < WIDTH; i++) {
		int count = 0;
		for(const uint16_t *p = input; p != input + LENGTH; ++p) {
			if(*p & (1 << i)) {
				count++;
			}

			if(count > LENGTH / 2) {
				gammaRate |= 1 << i;
				break;
			}
		}
	}

	printf("%d\n", gammaRate * (~gammaRate & MASK));
	return 0;
}
