#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "2018-01-ref.h"

int main(int argc, char **argv) {
	int32_t *seen = malloc(sizeof(input));
	size_t nSeen = 0;

	int32_t frequency = 0;
	size_t i = 0;
	bool insert = true;
	while(1) {
		frequency += input[i];

		ssize_t low = 0;
		ssize_t high = nSeen - 1;
		size_t j = nSeen / 2;
		while(low <= high) {
			if(frequency == seen[j]) {
				printf("%d\n", frequency);
				return 0;
			} else if(frequency < seen[j]) {
				high = j - 1;
			} else {
				low = j + 1;
			}
			j = (high - low) / 2 + low;
		}
		if(insert && (low > high)) {
			memmove(seen + low + 1, seen + low, (nSeen - low) * sizeof(*seen));
			seen[low] = frequency;
			++nSeen;
		}

		if(++i >= sizeof(input) / sizeof(*input)) {
			insert = false;
			i = 0;
		}
	}
}
