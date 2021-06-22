#include <stdint.h>
#include <stdio.h>

#include "2018-01-ref.h"

int main(int argc, char **argv) {
	int32_t frequency = 0;
	for(size_t i = 0; i < sizeof(input) / sizeof(*input); ++i) {
		frequency += input[i];
	}
	printf("%d\n", frequency);
	return 0;
}
