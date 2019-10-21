/** \file
 *
 * Board supply & test routines for Virtual RISC-V hardware
 *
 * (c) 2019 <hackfin@section5.ch>
 *
 *
 */

#include "shell.h"
#include "driver.h"
#include "cmdhelper.h"
#include "virtual_riscv.h"

#define HW_REVISION ((HWREV_system_map_MAJOR << 8) | HWREV_system_map_MINOR)

int board_init(void)
{
#ifdef CONFIG_UART
	uart_init(0, CONFIG_SYSCLK / 16 / CONFIG_DEFAULT_UART_BAUDRATE);
#endif
#ifdef CONFIG_SPI
	spi_init(1);
#endif

#ifdef CONFIG_GPIO
	MMR(Reg_GPIO_OUT) = 0x0000;
	// Classical error: GPIO_DIR was not initialized before.
#ifdef DEMO_SHOW_PROGRAM_FAILURE
	MMR(Reg_GPIO_DIR) |= 0x0001;
#endif
	MMR(Reg_GPIO_DIR) = 0x0001;
#endif

#ifdef CONFIG_TIMER
	struct timer_t systimer;
	systimer.hz =  20000;
	systimer.pulse = 50;
	systimer_init(&systimer);

#endif

	return 0;
}


const char s_info[] = "\r------------- test shell -------------\n"
                        "--      PYRV32 hardware test        --\n"
                        "--  (c) 2019       www.section5.ch  --\n"
                        "--     type 'h' for help            --\n";

const char s_help[] = "\r-------------  COMMANDS  -------------\n"
						CMD_DEFAULT
						;

int exec_cmd(int argc, char **argv)
{
	unsigned long val[3];

	if (argc >= 2) parse_hex(argv[1], &val[0]);
	if (argc >= 3) parse_hex(argv[2], &val[1]);

	switch (argv[0][0]) {
		case '?':
			write_string(s_help);
			break;
		// Insert your test commands here:
		default:
			return cmd_fallback(argc, argv);
	}

	return S_IDLE;
}

int g_ct = 0;

int mainloop_handler(int state)
{
	static int c = 0;

#ifdef CONFIG_GPIO
	MMR(Reg_GPIO_OUT) ^= (unsigned short) 0x0001;
	// MMR(Reg_GPIO_OUT) = c & 1;
#endif

#define WAIT_CYCLES 200000

	if (g_ct++ > WAIT_CYCLES) {
		g_ct = 0;
		// write_string("> GNA\n");
		MMRBase pwm = device_base(PWM, 0);

		uint16_t cnt = PWM_MMR_BASE(pwm, Reg_PWM_COUNTER);

		// printf("Cnt: %d\n", cnt);

		uint32_t v = MMR(Reg_Magic);

		uint16_t stat = PWM_MMR_BASE(pwm, Reg_PWM_STATUS);

		printf("v: %x stat: %04x\n", v, stat);

	}

	return 1;
}

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	BREAK;
}

