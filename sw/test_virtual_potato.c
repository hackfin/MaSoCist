/** \file
 *
 * Board supply & test routines for Virtual NEO430 hardware
 *
 *
 */

#include "shell.h"
#include "driver.h"
#include "cmdhelper.h"

#define HW_REVISION ((HWREV_system_map_MAJOR << 8) | HWREV_system_map_MINOR)

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
}

int board_init(void)
{
#ifdef CONFIG_UART
	uart_init(0, CONFIG_SYSCLK / 16 / CONFIG_DEFAULT_UART_BAUDRATE);
#endif
#ifdef CONFIG_SPI
	spi_init(1);
#endif
	int c;
	return 0;
}


const char s_info[] = "\r------------- test shell -------------\n"
                        "--      NEO430 hardware test        --\n"
                        "--  (c) 2018       www.section5.ch  --\n"
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

int mainloop_handler(int state)
{
	return 0;
}


