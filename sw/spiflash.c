/* SPI flash driver */

#include "driver.h"
#include "spiflash.h"

#if CONFIG_SPI_BITS_POWER == 5
#define SPI_32BIT
#warning "8 bit SPI support only"
#elif CONFIG_SPI_BITS_POWER == 3
#else
#error "Unsupported bit width"
#endif

static
inline void spi_tx(uint32_t v)
{
	MMR(Reg_SPI_TX) = v;
	while (MMR(Reg_SPI_STATUS) & SPIBUSY);
}

static
inline uint32_t spi_rx(void)
{
	while (MMR(Reg_SPI_STATUS) & SPIBUSY);
	return MMR(Reg_SPI_RX);
}

static
uint32_t spi_select(int nbits)
{
	uint32_t r;
	r = MMR(Reg_SPI_CONTROL);
	r &= ~(SPICS | NBITS);
	r |= PUMP | ((nbits-1) << NBITS_SHFT);
	MMR(Reg_SPI_CONTROL) = r;
	return r;
}

static
inline void spi_deselect(uint32_t r)
{
	r &= ~PUMP;
	r |= SPICS; MMR(Reg_SPI_CONTROL) = r;
}

void spi_init(int div)
{
	uint32_t r = 0;
	if (div == CLKDIV_BYPASS) {
		r = CPOL; // Hack
	}
	MMR(Reg_SPI_CLKDIV) = div;

#ifdef SPI_32BIT
	r |= (31 << NBITS_SHFT) | SPICS;
#else
	r |= (7 << NBITS_SHFT) | SPICS;
#endif

	MMR(Reg_SPI_CONTROL) = r | SPIRESET;
	r |= PUMP;
	MMR(Reg_SPI_CONTROL) = r;
}

// FIXME: Implement proper 32 bit architecture detection

void spiflash_read32(uint32_t addr, uint32_t *buf, int n)
{
	uint32_t r;
	uint32_t v;

	r = spi_select(32);

#ifdef SPI_32BIT
	addr |= (SPM_READ << 24); // Read command
	spi_tx(addr);
#else
	spi_tx(SPM_READ);
	spi_tx(addr >> 16);
	spi_tx(addr >> 8);
	spi_tx(addr);
#endif

	spi_rx(); // Dummy read
	while (n--) {
#ifdef SPI_32BIT
		v = spi_rx();
#else
		v = spi_rx(); v <<= 8;
		v |= spi_rx() & 0xff; v <<= 8;
		v |= spi_rx() & 0xff; v <<= 8;
		v |= spi_rx() & 0xff;
#endif
		*buf++ = v;
	}

	spi_deselect(r);
}

#if defined(SPI_32BIT)

int spiflash_detect(char *codes)
{

	uint32_t v;
	uint32_t r;
	
	r = spi_select(32);

	spi_tx(SPM_RDID << 24);
	spi_deselect(r);

	v = spi_rx();
	codes[2] = v; v >>= 8;
	codes[1] = v; v >>= 8;
	codes[0] = v; v >>= 8;

	return 0;
}

#define SECTORS(n, s)  (n * (s / 1024) / 1024)

#ifndef CONFIG_OPT_SIZE

struct flash_info {
	unsigned char fcode;
	const char *desc;
	unsigned short MB;
};

const __rodata_ext
struct flash_info st_spi_flashes[] = {
	{ 0x00, "m25p80",  SECTORS( 16, 0x10000) },
	{ 0x14, "m25p80",  SECTORS( 16, 0x10000) },
	{ 0x15, "m25p16",  SECTORS( 32, 0x10000) },
	{ 0x16, "m25p32",  SECTORS( 64, 0x10000) },
	{ 0x17, "m25p64",  SECTORS(128, 0x10000) },
	{ 0x18, "m25p128", SECTORS(256, 0x10000) },
};


void flash_print_info(char *codes)
{
	char n;
	const struct flash_info *f = st_spi_flashes;
	n = sizeof(st_spi_flashes) / sizeof(struct flash_info);
	do {
		if (codes[2] == f->fcode) {
			printf("Flash Type: %-16s\n", f->desc);
			printf("Capacity MB: %d", f->MB);
			return;
		}
		f++;
	} while (--n);
	puts("<undetected: ");
	put_byteval(codes[2]);
	puts(">");
}
#endif

#define CONSTRUCT32(a, b, c, d) (((a) << 24) | ((b) << 16) | ((c) << 8) | (d))

static
int spi_pollstatus(uint32_t bit)
{
	uint32_t r;
	uint32_t v;
	uint32_t cmd = CONSTRUCT32(SPM_RDSR, 0, 0, 0);

	do {
		r = spi_select(16);
		spi_tx(cmd);
		spi_deselect(r);
		v = spi_rx();
	} while (v & bit);
	return 0;
}

int spiflash_erasesector(uint32_t addr)
{
	uint32_t cmd = CONSTRUCT32(SPM_WREN, 0, 0, 0);

	uint32_t r;
	r = spi_select(8);
	spi_tx(cmd);
	spi_deselect(r);

	r = spi_select(32);
	cmd = CONSTRUCT32(SPM_FLASH_SE, 0, 0, 0);
#if defined(CONFIG_PRINTF) && defined(DEBUG)
	printf("Erasing at 0x%x\n", addr);
#endif
	spi_tx(cmd | addr);
	spi_deselect(r);

	spi_pollstatus(SPS_WEL);

	r = spi_select(8);
	cmd = CONSTRUCT32(SPM_WRDI, 0, 0, 0);
	spi_deselect(r);

	return 0;
}

int spiflash_writeblk32(uint32_t addr, const uint32_t *buf, uint32_t n)
{
	uint32_t r;
	uint32_t cmd = CONSTRUCT32(SPM_WREN, 0, 0, 0);

	r = spi_select(8);
	spi_tx(cmd);
	spi_deselect(r);

	cmd = CONSTRUCT32(SPM_PP, SPM_NO_CMD, SPM_NO_CMD, SPM_NO_CMD) | addr;
	r = spi_select(32);
	spi_tx(cmd);

	while (n--) {
		spi_tx(*buf++);
	}
	spi_deselect(r);
	return spi_pollstatus(SPS_WIP);
}


int spiflash_write32(uint32_t addr, const uint32_t *buf, uint32_t n)
{
	const int pagesize = 256;
	while (n >= pagesize) {
		spiflash_writeblk32(addr, buf, pagesize);
		n -= pagesize; addr += pagesize; buf += pagesize;
	}

	return spiflash_writeblk32(addr, buf, n);
}

#else // !SPI_32BIT


void spiflash_read(uint32_t addr, unsigned char *buf, int n)
{
	uint32_t r;
	uint32_t v;

	r = spi_select(8);

	spi_tx(SPM_READ);
	spi_tx(addr >> 16);
	spi_tx(addr >> 8);
	spi_tx(addr);

	spi_rx(); // Dummy read
	while (n--) {
		*buf++ = spi_rx();
	}
	spi_deselect(r);
}

#endif
