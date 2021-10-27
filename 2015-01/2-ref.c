#include <stdio.h>

#include "input.h"

int main() {
	int value = 0;
	for(const char *p = input; *p != '\0'; ++p) {
		if(*p == '(') {
			value++;
		} else if(*p == ')') {
			value--;
		}
		if(value < 0) {
			printf("%zd\n", p + 1 - input);
			return 0;
		}
	}
	fprintf(stderr, "Did not reach negative value\n");
	return 1;
}
