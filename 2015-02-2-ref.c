#include <stdint.h>
#include <stdio.h>

#include "2015-02-ref.h"

void main() {
	int value = 0;
	for(const input_t *p = input; p < input + sizeof(input) / sizeof(*input); ++p) {
		int lwPerimeter = 2 * (p->length + p->width);
		int whPerimeter = 2 * (p->width + p->height);
		int lhPerimeter = 2 * (p->length + p->height);
		int min = lwPerimeter < whPerimeter ? lwPerimeter : whPerimeter;
		if(lhPerimeter < min) min = lhPerimeter;
		value += min;
		value += (p->length * p->width * p->height);
	}
	printf("%d\n", value);
}
