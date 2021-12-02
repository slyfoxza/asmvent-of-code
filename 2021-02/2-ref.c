#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	int x = 0, z = 0, aim = 0;

	for(const input_t *p = input; p != input + sizeof(input) / sizeof(*input); ++p) {
		switch(p->direction) {
			case 'd': aim += p->value; break;
			case 'u': aim -= p->value; break;
			case 'f':
				x += p->value;
				z += aim * p->value;
				break;
		}
	}

	printf("%d\n", x * z);
	return 0;
}
