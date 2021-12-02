#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	int x = 0, z = 0;

	for(const input_t *p = input; p != input + sizeof(input) / sizeof(*input); ++p) {
		switch(p->direction) {
			case 'f': x += p->value; break;
			case 'd': z += p->value; break;
			case 'u': z -= p->value; break;
		}
	}

	printf("%d\n", x * z);
	return 0;
}
