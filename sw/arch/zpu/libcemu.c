/* ZPU minimal sys calls emulation
 *
 * (c) 2015, <hackfin@section5.ch>
 *
 */

#include <string.h>

int strcasecmp(const char *a, const char *b)
{
	return strcmp(a, b);
}

// Cheap and broken strcmp.
int strcmp(const char *a, const char *b)
{
	if (!a || !b) asm("breakpoint");
	while (*a == *b) {
		if (*a == '\0' || *b == '\0') break;
		a++; b++;
	}

	if (*a == '\0' && *b == '\0') return 0;
	else return -1;
}

int strncasecmp(const char *a, const char *b, size_t n)
{
	char u, v;
	while (n--) {
		u = *a++ | 0x20; v = *b++ | 0x20;
		if (u > v) return 1;
		else if (u < v) return -1;
		if (!u) break;
	}
	return 0;
}

unsigned long strlen(const char *s)
{
	int n = 0;
	while (*s++) n++;
	return n;
}

int parse_dec(const char *dec, unsigned long *val)
{
	unsigned char c;

	unsigned short d = 0;

	while ( (c = *dec++) ) {
		d *= 10;
		if (c >= '0' && c <= '9') {
			d += (c - '0');
		} else return 0;
	}
	*val = d;
	return 1;
}

unsigned long atoi(const char *c)
{
	unsigned long val;
	parse_dec(c, &val);
	return val;
}

_PTR memset(_PTR dst, int val, size_t n)
{
	unsigned char *d = dst;

	while (n--) {
		*d++ = val;
	}
	return dst;
}

_PTR memcpy(_PTR dst, const _PTR src, size_t n)
{
	const unsigned char *s = src;
	unsigned char *d = dst;

// Dirty: We know that we get called only for DCValue copying:
// WE KNEW WRONG.
//	while (n > 0) {
//		n -= 4;
//		*d++ = *s++;
//	}

//	This one is so horribly inefficient on the ZPU small.
//	But we have to live with it.
	while (n--) {
		*d++ = *s++;
	}
	return dst;
}

