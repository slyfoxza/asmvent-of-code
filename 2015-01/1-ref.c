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
	}
	printf("%d\n", value);
	return 0;
}
