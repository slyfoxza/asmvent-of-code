#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
	char *line = NULL;
	size_t lineSize = 0;
	unsigned validPasswords = 0;
	while((getline(&line, &lineSize, stdin)) != -1) {
		unsigned char lower, upper;
		char target;
		int n;
		sscanf(line, "%hhd-%hhd %c: %n", &lower, &upper, &target, &n);
		char *password = line + n;
		unsigned hits = 0;
		while(password != NULL) {
			password = strchr(password, target);
			if(password) {
				++hits;
				++password;
			}
		}

		if((hits >= lower) && (hits <= upper)) {
			++validPasswords;
		}
	}

	printf("%d\n", validPasswords);
	return 0;
}
