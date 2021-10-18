#include <stdint.h>
#include <stdio.h>

#include "2015-02-ref.h"

void main() {
	int value = 0;
	for(const input_t *p = input; p < input + sizeof(input) / sizeof(*input); ++p) {
		int lwArea = p->length * p->width;
		int whArea = p->width * p->height;
		int lhArea = p->length * p->height;
		value += 2 * (lwArea + whArea + lhArea);

		int min = lwArea < whArea ? lwArea : whArea;
		if(lhArea < min) min = lhArea;
		value += min;
	}
	printf("%d\n", value);
}
