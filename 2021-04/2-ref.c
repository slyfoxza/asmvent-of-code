#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	uint8_t wonBoards[sizeof(boards) / sizeof(*boards) / 25] = {0};

	int lastWinBoard = -1;
	uint8_t lastWinNumber = 0;

	for(unsigned i = 0; i < sizeof(numbers) / sizeof(*numbers); ++i) {
		for(unsigned j = 0; j < sizeof(boards) / sizeof(*boards); ++j) {
			const unsigned board = j / 25;
			if((wonBoards[board] == 0) && (boards[j] == numbers[i])) {
				boards[j] = -1;

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
					wonBoards[board] = 1;
					lastWinBoard = board;
					lastWinNumber = numbers[i];
					continue;
				}

				const unsigned baseY = board * 25 + x;
				for(k = 0; k < 5; ++k) {
					if(boards[baseY + k * 5] != -1) {
						break;
					}
				}
				if(k == 5) {
					wonBoards[board] = 1;
					lastWinBoard = board;
					lastWinNumber = numbers[i];
				}
			}
		}
	}

	unsigned value = 0;
	for(unsigned k = lastWinBoard * 25; k < (lastWinBoard + 1) * 25; ++k) {
		if(boards[k] != -1) {
			value += boards[k];
		}
	}
	printf("%d\n", value * lastWinNumber);

	return 0;
}
