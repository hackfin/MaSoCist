/** \file
 *
 * Board supply & test routines for MACHXO2 breakout board
 *
 *
 */

#include "shell.h"
#include "driver.h"
#include "cmdhelper.h"
#include "breakout.h"

#define PWM_MMR(base, addr) device_mmr_base(PWM, base, addr)


static int s_pwidths[24] = {
	600, 600, 600, 600, 600, 600, 600, 600,
	599, 590, 500, 300, 500, 590, 599, 600,
	600, 600, 600, 600, 600, 600, 600, 600
};


int g_pos = 0;
int g_mode = 0;

int g_dbg1;
int pwm_sweep(void)
{
	int i, k;
	MMRBase pwm;
	int ret = 0;
	int *ptr;

	k = g_pos;

	if (g_mode) {
		k--;
		if (k < 0) {
			k = 0;
			g_mode = 0;
		}

	} else {
		k++;
		if (k > 16) {
			k = 16;
			g_mode = 1;
		}

	}

	ptr = &s_pwidths[k];

	for (i = 0; i < 7; i++) {
		pwm = device_base(PWM, i);
		PWM_MMR(pwm, Reg_PWM_WIDTH) = ptr[i] - 1;
		g_dbg1 = i + k;
	}

	g_pos = k;
	return ret;
}

#ifdef CONFIG_SIC

int g_ticks = 0;

// This is called from within the IRQ handler. Careful with return values.
void do_timer_stuff(void)
{
	g_ticks++;
	if (g_ticks > 200) {
		g_ticks = 0;
	}
}

#endif

void pwm_sweep_init(void)
{
	int i;
	MMRBase pwm;
	pwm = device_base(PWM, 7);

	pwm_cfg(7, 10000, 100, 0);

	for (i = 0; i < 7; i++) {
		pwm_cfg(i, 600, s_pwidths[i], 0);
	}
	MMR(Reg_TIMER_STOP) = 0xff; // stop all timers
	MMR(Reg_TIMER_START) = 0xff; // start all timers

}


#define HW_REVISION ((HWREV_system_map_MAJOR << 8) | HWREV_system_map_MINOR)

char g_endiancheck[4] = { 0x0b, 0xad, 0xf0, 0x0d };

int test_endian(void)
{
	uint16_t *p = (uint16_t *) &g_endiancheck;
	int c;

	c = MMR16(Reg_Magic);
	if (c != 0xdead) BREAK;

	return p[0];
}

int g_count = 0;

int mainloop_handler(int state)
{
	int ret = 0;
	if (g_count++ > 1000) {
		g_count = 0;
		pwm_sweep();
	}
	return 0;
}



#ifdef SIMULATION
void run_selftest(void)
{
	int c;
	MMRBase gpio0_base = device_base(GPIO, 0);
	MMRBase gpio1_base = device_base(GPIO, 1);

#ifdef CONFIG_TIMER
	// pwm_sweep_init(30);
#endif


#ifdef CONFIG_UART
	uart_init(0, 30);
	uart_putc(0, 0x55);
	uart_putc(0, 0x0f);
	c = uart_getc(0);
	if ((c & 0xff) != 0x55) {
		MMR(Reg_GPIO_OUT) = c;
		BREAK;
	}
#endif

	// pwm_test(30);

#ifdef CONFIG_GPIO
	// Defaults:
	GPIO_MMR(gpio0_base, Reg_GPIO_CLR) = 0xffff;
	GPIO_MMR(gpio1_base, Reg_GPIO_CLR) = 0xffff;

	GPIO_MMR(gpio0_base, Reg_GPIO_DIR) = 0xffff;
	GPIO_MMR(gpio1_base, Reg_GPIO_DIR) = 0xffff;

	GPIO_MMR(gpio0_base, Reg_GPIO_SET) = 0xaaff;

	GPIO_MMR(gpio1_base, Reg_GPIO_SET) = 0x0055;

	// Switch to input:
	GPIO_MMR(gpio0_base, Reg_GPIO_DIR) = 0x0000;

	uint16_t data = GPIO_MMR(gpio0_base, Reg_GPIO_IN) & 0xffff;

	if (data != 0x8421) {
		GPIO_MMR(gpio1_base, Reg_GPIO_DIR) = 0x0000;
		BREAK;
	}
#endif
}
#endif

#define _RESOLVE(x) #x
#define STRING(x) _RESOLVE(x)

const char g_greeting[] = "\n\rBuild: " STRING(BUILD_ID) "\n\r";

int board_init(void)
{
	int c;
	struct timer_t systimer;

	c = MMR(Reg_HWVersion);
#ifdef SIMULATION
	if ((c & 0xffff) != HW_REVISION) {
		MMR(Reg_GPIO_OUT) = MMR(Reg_HWVersion);
		BREAK;
	}

	run_selftest();
	// test_endian();
#else
	uart_init(0, get_sysclk() / 16 / CONFIG_DEFAULT_UART_BAUDRATE);
	uart_puts(0, g_greeting);

#ifdef CONFIG_SPI
	spi_init(1);
#endif

	systimer.hz = 100000;
	systimer.pulse = 80;
	systimer_init(&systimer);

#ifdef CONFIG_MACHXO_EFB
	if (test_efb(&MMR32(Unit_Offset_efb)) < 0) BREAK;
#endif

#ifdef CONFIG_TIMER
	 pwm_sweep_init();
#endif
#endif // SIMULATION
	return 0;
}


const char s_info[] = "\r------------- test shell -------------\n"
                        "--      Breakout Kit MACHXO2 v0     --\n"
                        "--  (c) 2012-2017  www.section5.ch  --\n"
                        "--     type 'h' for help            --\n";

const char s_help[] = "\r-------------  COMMANDS  -------------\n"
						CMD_DEFAULT
                        " l <hex>    - Set LEDs accordingly \n";

int exec_cmd(int argc, char **argv)
{
	unsigned long val[3];

	if (argc >= 2) parse_hex(argv[1], &val[0]);
	if (argc >= 3) parse_hex(argv[2], &val[1]);

	switch (argv[0][0]) {
		case 'l':
			switch (argc) {
				case 2:
					MMR(Reg_GPIO_OUT) = BITFIELD(BREAKOUT_LEDS, val[0]);
					break;
				default:
					write_string("Usage: l <hexvalue>\n");
			}
			break;
		default:
			return cmd_fallback(argc, argv);
	}

	return S_IDLE;
}

