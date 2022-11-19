#include <stdio.h>
#include "input.h"

int main() {
	unsigned result = 0;
	for(const input_t *p = input; p < input + sizeof(input) / sizeof(*input); ++p) {
		unsigned lw = p->length * p->width;
		unsigned wh = p->width * p->height;
		unsigned lh = p->length * p->height;
		result += 2 * (lw + wh + lh);

		unsigned min = lw < wh ? lw : wh;
		result += (lh < min) ? lh : min;
	}
	printf("%u\n", result);
	return 0;
}
