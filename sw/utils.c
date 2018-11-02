/* Non reentrant puts helpers. Do not use from interrupts. */


#include <stdio.h>
#include "driver.h"

const
static char s_hexcodes[] = "0123456789abcdef";


int parse_hex(const char *hex, unsigned int *val)
{
	unsigned char c;

	unsigned long d = 0;

	while ( (c = *hex++) ) {
		d <<= 4;
		if (c >= '0' && c <= '9') {
			d |= (c - '0');
		} else
		if (c >= 'A' && c <= 'F') {
			d |= (c - 'A' + 0xa);
		} else
		if (c >= 'a' && c <= 'f') {
			d |= (c - 'a' + 0xa);
		} else
			return 0;
	}
	*val = d;
	return 1;
}


#if 0
void install_putc(void (*putc)(int s))
{
	g_putchar = putc;
}
#endif


void put_byteval(unsigned char val)
{
	static char hexint[3] = "00";

	hexint[0] = s_hexcodes[(val >> 4) & 0xf];
	hexint[1] = s_hexcodes[(val >> 0) & 0xf];
	write_string(hexint);
}

void put_shortval(uint16_t val)
{
	static char hexint[5] = "0000";

	hexint[0] = s_hexcodes[(val >> 12) & 0xf];
	hexint[1] = s_hexcodes[(val >> 8) & 0xf];
	hexint[2] = s_hexcodes[(val >> 4) & 0xf];
	hexint[3] = s_hexcodes[(val >> 0) & 0xf];
	write_string(hexint);
}

char *to_dec(unsigned short val, char *buf)
{
	char *p = &buf[7];

	short d = 10;

	*p = '\0';
	do {
		*(--p) = (val % d) + '0';
		val /= d;
	} while (val && (p > buf));
	return p;
}

void put_decval_s(unsigned short val)
{
	static char decint[8];
	char *p = to_dec(val, decint);

	write_string(p);
}

