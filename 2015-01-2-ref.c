#include <stdio.h>

#include "2015-01-ref.h"

int main() {
	int value = 0;
	for(const char *p = input; *p != '\0'; ++p) {
		value += (*p - '(') * -2 + 1;
		if(value < 0) {
			printf("%zd\n", p + 1 - input);
			return 0;
		}
	}
	fprintf(stderr, "Did not reach negative value\n");
	return 1;
}
