#include <stdio.h>

#include "2015-01-ref.h"

void main() {
	int value = 0;
	for(const char *p = input; *p != '\0'; ++p) {
		value += (*p - '(') * -2 + 1;
	}
	printf("%d\n", value);
}
