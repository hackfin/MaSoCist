// Default commands and help strings

#include "arch.h"

#define CMD_BASIC_MEMDUMP " m <addr> [n]     - Dump bytes from memory\n" 
#ifdef CONFIG_SPI
#define CMD_BASIC_SPIDUMP " s <addr> [n]     - Dump words from SPI flash\n"
#else
#define CMD_BASIC_SPIDUMP
#endif


#define CMD_DEFAULT \
	CMD_BASIC_MEMDUMP \
	CMD_BASIC_SPIDUMP


void dump(const char *b, int i);
void spiflash_dump(unsigned long addr, int n);
int cmd_fallback(int argc, char **argv);

