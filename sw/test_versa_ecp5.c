/** \file
 *
 * Board supply & test routines for Versa ECP5 breakout board
 *
 *
 */

#include "shell.h"
#include "versa_ecp5.h" // generated SoC map
#include "driver.h"
#include "machine/endian.h"


#ifdef CONFIG_SCACHE_INSN
#define CACHE_SIZE       0x1000
#else
#define CACHE_SIZE       0x2000
#endif
#define DCACHE_PHYS_ADDR  (1 << CONFIG_CACHE_PHYSICAL_ADDRESS_BIT)
#define ICACHE_PHYS_ADDR  (DCACHE_PHYS_ADDR + CACHE_SIZE)


char g_endiancheck[4] = { 0x0b, 0xad, 0xf0, 0x0d };

int test_endian(void)
{
	uint16_t *p = (uint16_t *) &g_endiancheck[0];
	int c;

	c = *p;
#if defined (LITTLE_ENDIAN)
#warning "Little endian defined"
	if (c != 0xad0b) BREAK;
#elif defined(BIG_ENDIAN)
#warning "Big endian defined"
	if (c != 0x0bad) BREAK;
#else
#error "Endianness undefined"
#endif

	return p[0];
}

void led_blink(int n, int d)
{
#ifdef CONFIG_LCDIO
	int i;
	for (i = 0; i < n; i++) {
		MMR(Reg_PORTCTRL) = BGLED;
		delay(d);
		MMR(Reg_PORTCTRL) = 0;
		delay(d);
	}
#else

#endif
}

static uint32_t s_val = 0x40;

uint32_t g_dbg = 0;
void seg_cycle(void)
{
#ifdef CONFIG_GPIO
	MMRBase gpio0_base = device_base(GPIO, 0);
#endif
	if (s_val == 0x4000) s_val = 0x40;
#ifdef CONFIG_GPIO
	GPIO_MMR(gpio0_base, Reg_GPIO_OUT) = s_val;
#endif
	g_dbg++;
	s_val <<= 1;
}


static volatile int g_wait = 1;

// #define CACHEABLE_MEMORY 0x14000

int run_tap_selftest(void)
{
	return -1;
}

__attribute__((section(".ext.bank0.text")))
int func1(int a)
{
	return a + a;
}

__attribute__((section(".ext.bank1.text")))
int func2(int a)
{
	return func1(a) + 1;
}


int g_result = 0;

#ifdef CONFIG_SCACHE

__attribute__((interrupt))
void cache_handler(void)
{
	// address of cache memory
	uint32_t addr;
	uint32_t stat;

	stat = MMR(Reg_CacheStatus);
	// Clear flags early:
	MMR(Reg_CacheControl) = IACK | DACK | DCACHE_ENABLE | ICACHE_ENABLE;

	if (stat & DMISS) {
		uint32_t *dcacheaddr = (uint32_t *) DCACHE_PHYS_ADDR;
		*dcacheaddr = 0xf00dface;
		dcacheaddr[0xa0 >> 2] = 0x55ff5500;
		dcacheaddr[0x10 >> 2] = 0xbaadf00d;
		dcacheaddr[0x20 >> 2] = 0xdeadbeef;
	}
	if (stat & IMISS) {
		addr = MMR(Reg_ICacheHitAddr);
		uint32_t *icacheaddr = (uint32_t *) (ICACHE_PHYS_ADDR);
		if (addr & 0x1000) {
			// CODE_HACK:
			*icacheaddr++ = 0x803d0d72;
			*icacheaddr++ = 0x51828080;
			*icacheaddr++ = 0x2db00881;
			*icacheaddr++ = 0x05b00c82;
			*icacheaddr++ = 0x3d0d0400;
		} else {
			*icacheaddr++ = 0x7110b00c;
			*icacheaddr++ = 0x04000000;
		}
	}
}


void cache_test()
{
	unsigned long *ptr = (unsigned long *) 0x20000;

	cache_init(ICACHE_ENABLE | DCACHE_ENABLE);
	
	// Here we have an access that triggers the cache exception handler
	// on a MISS condition, loads some code and then revisits the the
	// LOAD instruction:
	if (*ptr != 0xf00dface) BREAK;
	// Here we jump into a function in nemo space, which will trigger
	// a cache load:
	// Test no longer functional. Fix CODE_HACK!
	// g_result = func2(2);
	// if (g_result != 5) BREAK;
	// BREAK;
}
#endif



#include "soc_register_modes.h"



int run_selftest(int is_sim)
{
	// Map IRQ inputs (sources) to channels:
	uint8_t val;

#ifdef CONFIG_SCACHE
	cache_test();
#endif

#ifdef CONFIG_SPI
	MMR(Reg_SPI_CLKDIV) = 4-1;
	MMR(Reg_SPI_CONTROL) = SPIRESET;
	MMR(Reg_SPI_CONTROL) = (7 << NBITS_SHFT) | LSBFIRST | PUMP;
	MMR(Reg_SPI_TX) = 0x55;
	while (MMR(Reg_SPI_STATUS) & SPIBUSY);
	MMR(Reg_SPI_CONTROL) = (7 << NBITS_SHFT) | LSBFIRST;
	// Delayed send on RX access:
	MMR(Reg_SPI_TX) = 0x81;
	MMR(Reg_SPI_CONTROL) = (7 << NBITS_SHFT) | LSBFIRST | PUMP | CPHA;
	val = MMR(Reg_SPI_RX);
	// if (val != 0x55) BREAK;
#endif

	return 0;
}


int board_init(void)
{
	int c;

	MMRBase gpio0_base = device_base(GPIO, 0);
	MMRBase gpio1_base = device_base(GPIO, 1);

	GPIO_MMR(gpio0_base, Reg_GPIO_DIR) = 0xffff;
	GPIO_MMR(gpio1_base, Reg_GPIO_DIR) = 0xffff;

	GPIO_MMR(gpio0_base, Reg_GPIO_OUT) = 0x0001;
	GPIO_MMR(gpio1_base, Reg_GPIO_OUT) = 0x0001;

#ifdef CONFIG_UART
	uart_init(0, CONFIG_SYSCLK / 16 / CONFIG_DEFAULT_UART_BAUDRATE);
	// Initialize handler for UART events:
	uart_puts(0, "Hello.\r\n");
#endif

#ifdef CONFIG_TIMER
	struct timer_t systimer;
	systimer.hz =  500000;
	systimer.pulse = 20;
	systimer_init(&systimer);
#endif

	MMR(Reg_SIC_ILAT_W1C) =  0xffff;
	MMR(Reg_SIC_IPEND_W1C) =  0xffff;

	c = MMR(Reg_HWVersion);
	if ((c & 0xffff) == 0x0ace) {
		run_selftest(1);
		BREAK;
	}
	run_selftest(0);

	test_endian();
	return 0;
}

// SECTION_RODATA
const char s_info[] = "\r------------- test shell -------------\n"
                        "--   ZpuSoC for Versa ECP5   --\n"
                        "--  (c) 2012-2020  www.section5.ch  --\n"
                        "--     type 'h' for help            --\n";

const char s_help[] = "\r-------------  COMMANDS  -------------\n"
                        " l <hex>    - Set LEDs accordingly \n";

int exec_cmd(int argc, char **argv)
{
	unsigned int val[3];

	if (argc >= 2) parse_hex(argv[1], &val[0]);
	if (argc >= 3) parse_hex(argv[2], &val[1]);

	switch (argv[0][0]) {
		case 'l':
			switch (argc) {
				case 2:
					break;
				default:
					write_string("Usage: l <hexvalue>\n");
			}
		case 'b':
			BREAK;
			break;
		default:
			return ERR_CMD;
	}

	return S_IDLE;
}

static long int g_cycle = 0;

int mainloop_handler(int state)
{
	g_cycle++;
	if (g_cycle == 4000) {
		g_cycle = 0;
		seg_cycle();
	}
	return 0;
}

