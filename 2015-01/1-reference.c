#include <stdio.h>
#include "input.h"

int main() {
	int result = 0;
	for(const char *p = input; *p != '\0'; ++p) {
		const char c = *p;
		if(c == '(') {
			result++;
		} else {
			result--;
		}
	}
	printf("%d\n", result);
	return 0;
}
