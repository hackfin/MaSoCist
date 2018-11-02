/* 
 * Standard helper functions
 *
 * These are interactive functions that should not end up in the board
 * supply library to save space.
 *
 */

#include <stdio.h>
#include "driver.h"

void dump(const char *b, int i)
{
	while (i--) {
		put_byteval(*b++); my_putchar(' ');
	}
	write_string("\n");
}


#ifdef CONFIG_SPI

#if CONFIG_SPI_BITS_POWER == 5
void spiflash_dump(unsigned long addr, int n)
{
	uint32_t buf[4];

	int i;
	while (n--) {
		i = 4;
		spiflash_read32(addr, buf, i);
		dump((const char *) buf, i * sizeof(uint32_t));
		addr += 16;
	}
}

#else
void spiflash_dump(unsigned long addr, int n)
{
	uint8_t buf[16];

	int i;
	while (n--) {
		i = 16;
		spiflash_read(addr, buf, i);
		dump((const char *) buf, i);
		addr += 16;
	}
}
#endif

#endif

int memory_dump(const char *addr, int n)
{
	while (n--) {
		dump(addr, 16);
		addr += 16;
	}
	return 0;
}

int cmd_fallback(int argc, char **argv)
{
	unsigned int val[2];
	int ret = 0;

	if (argc >= 2) parse_hex(argv[1], &val[0]);
	if (argc >= 3) parse_hex(argv[2], &val[1]);

	switch (argv[0][0]) {
		case 'm':
			switch (argc) {
				case 3:
					ret = memory_dump((const char *) val[0], val[1]);
					break;
				case 2:
					ret = memory_dump((const char *) val[0], 1);
					break;
				default:
					write_string("Usage: m <xxxxxx> [# lines of 16 bytes]\n");
			}
			break;
#ifdef CONFIG_SPI
		case 's':
			switch (argc) {
				case 3:
					spiflash_dump(val[0], val[1]);
					break;
				case 2:
					spiflash_dump(val[0], 1);
					break;
				default:
					write_string("Usage: s <xxxxxx> [# lines of 16 bytes]\n");
			}
			break;
#endif

		default:
			return ERR_CMD;
	}
	return 0;
}

#ifdef CONFIG_TWI
int twi_detect(char dev)
{
	int i;
	int stat;
	int ret = -1;
	MMRBase twi = &MMR(TWI_Offset); // Single device hack

	twi_reset(twi);

	for (i = 1; i < 127; i++) {
		stat = twi_probe(twi, i);
		if ((stat & ARB)) {
			printf("ARB LOST!\n");
			return -1;
		}
		if ((stat & NAK) == 0) {
			printf("[%02x] ", i);
			ret = i;
		} else {
			printf(" %02x  ", i);
		}
	}
	return ret;
}

#endif
