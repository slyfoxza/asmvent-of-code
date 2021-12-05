#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	int winBoard = -1;

	unsigned i = 0;
	for(i = 0; i < sizeof(numbers) / sizeof(*numbers); ++i) {
		for(unsigned j = 0; j < sizeof(boards) / sizeof(*boards); ++j) {
			if(boards[j] == numbers[i]) {
				boards[j] = -1;

				const unsigned board = j / 25;
				const unsigned y = j % 25 / 5;
				const unsigned x = j % 5;

				const unsigned baseX = board * 25 + y * 5;
				unsigned k;
				for(k = 0; k < 5; ++k) {
					if(boards[baseX + k] != -1) {
						break;
					}
				}
				if(k == 5) {
					winBoard = board;
					break;
				}

				const unsigned baseY = board * 25 + x;
				for(k = 0; k < 5; ++k) {
					if(boards[baseY + k * 5] != -1) {
						break;
					}
				}
				if(k == 5) {
					winBoard = board;
					break;
				}
			}
		}
		if(winBoard != -1) {
			break;
		}
	}

	unsigned value = 0;
	for(unsigned k = winBoard * 25; k < (winBoard + 1) * 25; ++k) {
		if(boards[k] != -1) {
			value += boards[k];
		}
	}
	printf("%d\n", value * numbers[i]);

	return 0;
}
