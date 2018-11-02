/** \file
 *
 * Board supply & test routines for MACHXO2 breakout board
 *
 *
 */

#include "shell.h"
#include "driver.h"
#ifdef CONFIG_LCD
#include "lcd.h"
#endif
#include "papilio.h"

#ifdef CONFIG_SMARTLED
#include "smartled.h"
#endif

// Local Software settings
#define PWM_TEST

int led_progress(void);
void test_smartled(int mode);

char g_endiancheck[4] = { 0x0b, 0xad, 0xf0, 0x0d };

#define SECTION_RODATA  __attribute__((section(".ext.rodata")))
// #define SECTION_RODATA

#ifdef TEST
int test_endian(void)
{
	uint16_t *p = (uint16_t *) &g_endiancheck;
	int c;

	c = MMR16(Reg_Magic);
	if (c != 0xcafe) BREAK;

	return p[0];
}

#endif // TEST

void led_blink(int n, int d)
{
#ifdef CONFIG_LCD
	int i;
	for (i = 0; i < n; i++) {
		MMR(Reg_PORTCTRL) = BGLED | RST;
		delay(d);
		MMR(Reg_PORTCTRL) = RST;
		delay(d);
	}
#endif
}


enum {
	M_IDLE,
	M_IMG,
	M_RAINBOW,
};

static uint32_t g_lastcount = 0;
int g_animate = 1;
int g_mode = M_IDLE;
int g_wait = 1000;


#ifdef USE_UART_INTERRUPT
extern struct Uart_Fifo g_uart;

void irq_uart_handler(void)
{
	int c;

	while (MMR(Reg_UART_STATUS) & RXREADY) {
		c = MMR(Reg_UART_RXR);
		g_uart.buf[(g_uart.head++)] = c;
		g_uart.head &= FIFO_MASK_UART;
	}
	if (g_uart.echo) {
		if (c != '\033') uart_putc(0, c);
		if (c == '\015') uart_putc(0, '\012'); // Append LF to CR
	}

#ifdef SIMULATION
	MMR(Reg_GPIO_SET) = 0x0001;
	MMR(Reg_GPIO_CLR) = 0x0001;
#endif
	MMR(Reg_SIC_IPEND_W1C) =  PINMAP_IRQ_UART; // rearm IRQ
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
}

#endif

#ifdef CONFIG_SCACHE

/* We have to create a dummy function that the .ext.text section is not
 * completely empty and is not omitted from the objcopy to flashdata.bin...
 *
 * The reason for this is that we don't want changing layout whenever
 * we change the CONFIG_SCACHE_INSN define
 */
__attribute__((section(".ext.text")))
void ext_program_memory_dummy(void)
{

}

#endif

#ifdef CONFIG_LCD

void lcd_clr(void)
{
	lcd_home();
	lcd_fillscreen(TO_RGB332(0x001f));
}

const char g_text[] = "Running rainbow...\n";

extern const uint16_t g_stilleben[];


void lcd_test(void)
{
	// led_blink(10, 20);
	lcd_clr();
	delay(200);

	write_string(g_text);
	lcd_puts(g_text);

	int i;
	for (i = 0; i < 64; i++) {
		lcd_flood();
		write_string(".");
		// led_blink(1, 100);
	}
	write_string("Done.\n");
	lcd_puts("Done.\n");
	delay(500);
	lcd_clr();
	print_splash();
}

#endif // CONFIG_LCD

#ifdef TEST

char g_buf[8];
int g_n = 0;

int uart_test(char dev, int cycles)
{
	char *b, *e;
	int n, l;
	while (1)
	{
#if 0
		b = g_buf;
		n = uart_read(0, b, sizeof(g_buf));
		if (n == 0) continue;
		e = &b[sizeof(g_buf)];
		b += n;
		g_n = n;
		while (b < e) {
			l = uart_read(0, b, e - b);
			b += l;
		}
		b = g_buf;
		n = sizeof(g_buf);
		while (n--) {
			uart_putc(0, *b++);
		}
#else
		uart_putc(0, uart_getc(0));
#endif
	}
	return 0;
}
#endif // TEST


int mainloop_handler(int state)
{
#ifdef CONFIG_LCD
	int d;
	int x, y;
	uint32_t tval;
#endif

#ifdef CONFIG_SMARTLED
	led_progress();
#endif

#if defined(CONFIG_LCD)
	tval = timer_get();

	// Reset delta counter when we have console activity
	if (state != S_INPUT) {
		if (state == S_INTERACTIVE) return 0;
		g_lastcount = tval;
		g_wait = 1000;
		if (state == S_IDLE) {
			print_splash();
		} else {
			g_animate = 0;
		}
		g_mode = M_IDLE;
	}

	switch (g_mode) {
		case M_RAINBOW:
			// lcd_flood();
			break;
		default:
			if (g_animate) { 
				lcd_flood();
				lcd_get_cursor(&x, &y);
				g_putchar = lcd_putc;
				lcd_set_cursor(20 *4, y-2*8);
				put_decval_s(tval);
				lcd_puts("    ");
				lcd_set_cursor(x, y);
				g_putchar = &my_putchar;
			}
	}
	d = tval - g_lastcount;

	if (d > g_wait) {
		g_lastcount = tval;
		switch (g_mode) {
			case M_IDLE:
				lcd_bitmap(g_stilleben);
				g_mode = M_IMG;
				g_animate = 0;
				g_wait = 300;
				break;
			case M_IMG:
				g_animate = 0;
				g_mode = M_RAINBOW;
				g_wait = 500;
				break;
			case M_RAINBOW:
				g_wait = 300;
				print_splash();
				g_animate = 1;
				g_mode = M_IDLE;
				break;
		}
	}

#endif

	return 0;
}

int run_selftest(int is_sim)
{
	MMRBase gpio0_base = device_base(GPIO, 0);
	MMRBase gpio1_base = device_base(GPIO, 1);

	GPIO_MMR(gpio0_base, Reg_GPIO_CLR) = 0xffff;
	GPIO_MMR(gpio1_base, Reg_GPIO_CLR) = 0xffff;

	// Set to out
	GPIO_MMR(gpio0_base, Reg_GPIO_DIR) = 0xffff;
	GPIO_MMR(gpio1_base, Reg_GPIO_DIR) = 0xffff;

	return 0;
}

__attribute__((section(".ext.rodata")))
const char g_cache_info[] = "\nSCache active\n";


const char g_greeting[] = "Hello!\n\r";

int g_tmr1 = 0;

FORCE_L1RAM __attribute__((interrupt))
void irq_timer1_handler(void)
{
	MMR(Reg_SIC_IPEND_W1C) = PINMAP_IRQ_TIMER1; // rearm IRQ
	// MMR(Reg_DBG1) = g_tmr1++;
}

int board_init(void)
{
	int c;
	uint32_t mask = 0;
#ifdef CONFIG_TIMER
	struct timer_t systimer;
#endif

	// Initialize putchar fptr:
	g_putchar = my_putchar;

#ifdef CONFIG_TIMER
	pwm_cfg(1, 19, 19, TMR_IRQEN);
#ifdef SIMULATION
	systimer.hz = 5000000;
	systimer.pulse = 41;
#else
	systimer.hz = 8000;
	systimer.pulse = 80;
#endif
	systimer_init(&systimer);

	MMR(CONSTRUCT_IV(PINMAP_IRQ_TIMER1_SHFT)) = (uint32_t) &irq_timer1_handler;
	MMR(Reg_SIC_IMASK) |= PINMAP_IRQ_TIMER1;

	MMR(Reg_TIMER_START) = 0x02; // start Timer 1

#endif


#ifdef CONFIG_UART
	uart_init(0, CONFIG_SYSCLK / 16 / CONFIG_DEFAULT_UART_BAUDRATE);
	// Initialize handler for UART events:
	uart_puts(0, g_greeting);
#endif

	write_string(g_cache_info);

	// uart_test(0, 1000);

	// uart_test(0, 1000);


#ifdef CONFIG_LCD
	lcd_init(1, 1);
	lcd_enable(1);
	lcd_clr();
	print_splash();
#endif


#ifdef CONFIG_SMARTLED
	write_string("Running LED cycle...\n");
	smled_init(CONFIG_SMARTLED_DEFAULT_PWM, CONFIG_SMARTLEDS_SIZE);
	test_smartled(0);
#endif

	c = MMR(Reg_HWVersion);
	if ((c & 0xffff) == 0xface) {
		MMR(Reg_GPIO_OUT) = MMR(Reg_HWVersion);
		run_selftest(1);
#ifdef SIMULATION
		BREAK;
#else
		return -1;
#endif
	}
	run_selftest(0);

	// test_endian();
	return 0;
}

SECTION_RODATA
const char s_info[] = "\r------------- test shell -------------\n"
                        "--   ZpuSoC for Papilio Spartan3e   --\n"
                        "--  (c) 2012-2015  www.section5.ch  --\n"
                        "--     type 'h' for help            --\n";

// __attribute__((section(".ext.rodata")))
const char s_help[] = "\r---------------  COMMANDS  ---------------\n"
//                        " b <num>        - Set font style [0, 1]\n"
#ifdef CONFIG_SMARTLED
                        " m <ioctl> <val>  - Set background LED mode parameters\n"
                        " L <mode>         - LED test\n"
#endif
#ifdef CONFIG_LCD
                        " c <hex>          - Set background color\n"
                        " B                - Draw bitmap\n"
                        " i                - interactive text dump\n"
                        " l                - Run LCD test\n"
#endif
						;


int exec_cmd(int argc, char **argv)
{
	unsigned long val[3];
	int ret = 0;
	int state = S_IDLE;

	if (argc >= 2) parse_hex(argv[1], &val[0]);
	if (argc >= 3) parse_hex(argv[2], &val[1]);

	switch (argv[0][0]) {
		case 'i':
			state = S_INTERACTIVE;
			uart_stty(0, 0x3);
			write_string("Hit ESC to return to shell..\n");
			break;
#ifdef CONFIG_LCD
		case 'B':
			g_animate = 0;
			lcd_bitmap(g_stilleben);
			state = S_INTERACTIVE;
			write_string("Hit ESC to return to shell..\n");
			break;
#if 0
		case 'b':
			switch (argc) {
				case 2:
					lcd_selfont(val[0]);
					break;
				default:
					write_string("Usage: b [0,1]\n");
			}
			break;
#endif
		case 'c':
			switch (argc) {
				case 2:
					lcd_home();
					lcd_fillscreen(TO_RGB332(val[0]));
					g_animate = 0;
					break;
				default:
					write_string("Usage: c <RGB565 hex value>\n");
			}
			break;
		case 'l':
			lcd_test();
			g_animate = 1;
			break;
#endif
#ifdef CONFIG_SMARTLED
		case 'm':
			switch (argc) {
				case 1:
					val[1] = 0;
					val[0] = 0;
					ret = led_ioctl(val[0], val[1]); break;
				case 2:
					ret = led_iostat(val[0], &val[2]);
					write_string("Read: "); put_shortval(val[2]); write_string("\n");
					break;
				case 3:
					ret = led_ioctl(val[0], val[1]); break;
			}
			break;
		case 'L':
			switch (argc) {
				case 2:
					test_smartled(val[0]);
					break;
				default:
					test_smartled(0);
			}
			break;
#endif
		default:
			return ERR_CMD;
	}
	if (ret < 0) return ret;
	return state;
}

