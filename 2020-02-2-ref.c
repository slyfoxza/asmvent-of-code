#include <stdio.h>

int main(int argc, char **argv) {
	char *line = NULL;
	size_t lineSize = 0;
	unsigned validPasswords = 0;
	while((getline(&line, &lineSize, stdin)) != -1) {
		unsigned char i, j;
		char target;
		int n;
		sscanf(line, "%hhd-%hhd %c: %n", &i, &j, &target, &n);
		char *password = line + n - 1;
		char a = password[i];
		char b = password[j];
		if(((a == target) || (b == target)) && (a != b)) {
			++validPasswords;
		}
	}

	printf("%d\n", validPasswords);
	return 0;
}
