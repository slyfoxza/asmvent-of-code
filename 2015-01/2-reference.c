#include <stdio.h>
#include "input.h"

int main() {
	int result = 0;
	unsigned i = 1;
	for(const char *p = input; *p != '\0'; ++p, ++i) {
		const char c = *p;
		if(c == '(') {
			result++;
		} else {
			result--;
		}
		if(result < 0) {
			break;
		}
	}
	printf("%u\n", i);
	return 0;
}
