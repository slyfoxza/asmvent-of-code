#include <stdio.h>
#include <stdint.h>

#include "input.h"

int main() {
	/* The idea with this implementation is to build up the "chosen prefix" so
	 * far, and use that as a mask to select or reject values when considering
	 * the next bit index.
	 *
	 * For example, say the chosen prefix so far is 10xxx. By XORing the prefix
	 * with a candidate value, and masking out the suffix bits, we know that
	 * any result that is not all zeroes should be skipped:
	 *
	 *     00100 ^ 10000 = 10100 & 11000 = 10000 != 0 -> skip
	 *     11110 ^ 10000 = 01110 & 11000 = 01000 != 0 -> skip
	 *     10110 ^ 10000 = 00110 & 11000 = 00000 == 0 -> accept
	 *     10111 ^ 10000 = 00111 & 11000 = 00000 == 0 -> accept
	 *
	 * Thus, with each iteration, the chosen prefix and mask is "grown" by 1
	 * bit until the prefix is the final output value.
	 *
	 * As a bonus, this results in an O(n) implementation. */
	uint16_t oxyPrefix = 0, co2Prefix = 0;
	uint16_t xorMask = 0;
	for(int i = WIDTH - 1; i >= 0; i--) {
		int oxySetCount = 0, co2SetCount = 0;
		int oxyTotalCount = 0, co2TotalCount = 0;
		for(const uint16_t *p = input; p != input + LENGTH; ++p) {
			if(((*p ^ oxyPrefix) & xorMask) == 0) {
				if(*p & (1 << i)) {
					oxySetCount++;
				}
				oxyTotalCount++;
			}

			if(((*p ^ co2Prefix) & xorMask) == 0) {
				if(*p & (1 << i)) {
					co2SetCount++;
				}
				co2TotalCount++;
			}
		}

		if(oxyTotalCount == 1) {
			/* If there is only a single eligible remaining, then the setCount
			 * will be equal to the current bit for that single value, and so
			 * the prefix can simply be extended by it. */
			oxyPrefix |= oxySetCount << i;
		} else if(oxySetCount * 2 >= oxyTotalCount) {
			/* Otherwise, for oxygen, we extend the prefix with a "1" bit if 1s
			 * were the most common bit for the index, or if there was an equal
			 * number of 1s and 0s.
			 *
			 * There's no need to set zeroes in the prefix since it starts off
			 * as zero-initialized. */
			oxyPrefix |= 1 << i;
		}

		if(co2TotalCount == 1) {
			// Same story as with oxygen, as described above.
			co2Prefix |= co2SetCount << i;
		} else if(co2SetCount * 2 < co2TotalCount) {
			/* CO2 has a different criteria where it picks the _least_ common
			 * bit (or 0 winning ties). */
			co2Prefix |= 1 << i;
		}

		xorMask |= 1 << i;
	}

	printf("%d\n", oxyPrefix * co2Prefix);
	return 0;
}
