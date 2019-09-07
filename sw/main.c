/* MaSoCist main test program
 *
 * (c) Martin Strubel <hackfin@section5.ch>
 */

#include "driver.h"
#include "shell.h"
#ifdef CONFIG_LCD
#include "lcd/lcd.h"
#endif

#ifdef CONFIG_PRINTF
#include <stdio.h>
#endif

// Special tap test helper:

int run_tap_selftest(void);

struct shell_context {
	char buf[80];
	char word[16];
} g_shell;

uint32_t g_hwrev;

__attribute__((weak))
int default_exec_abort(void)
{
	return 0;
}


int perio_init(void)
{
	int ret;
	uint32_t id;

	id = MMR(Reg_Magic);
	g_hwrev = id;

	switch (id) {
		case 0xdead0ace:
#ifdef CONFIG_VTAP_DEBUG
			run_tap_selftest();
#endif
			break;
		case 0xdeadbeef:
			// This is the legacy Zealot
			break;
		case 0xdead3415: // Mais legacy
		case 0xdeafbeed:
			// Cordula setup PyPS
			break;
		case 0xdeadbeed:
			// Cordula setup ZPU
			break;
		case 0xbaadf00d:
			// PyPS enhanced processor
			break;
		default:
			if ((id & 0xffff0000) != 0xcafe0000) BREAK;
	}

	g_hwrev = MMR(Reg_HWVersion);
	// If firmware does not match hardware, stop CPU.
	// This is the paranoia mode. Software in the field should
	// behave differently :-)

	if ((g_hwrev & (REV_MAJOR | REV_MINOR)) != HWVERSION) {
		BREAK;
	}

	// Init SPI cache early:
#if defined(CONFIG_SPI)
	spi_init(CLKDIV_BYPASS); // Bypass must work on all platforms
#if defined(CONFIG_SCACHE)
	cache_init(ICACHE_ENABLE | DCACHE_ENABLE);
#endif
#endif

	ret = board_init();

	write_string("\nBooting ");
	write_string(CONFIG_SOCDESC);
	write_string(" HW rev: "); put_byteval(g_hwrev);
	write_string(" @");
	put_decval_s(get_sysclk() / 1000000);
	write_string(" MHZ\n\n");

	return ret;
}


extern const char s_info[];
extern const char s_help[];

char *errtostring(int err)
{
	switch (err) {
		case ERR_CMD:     return ("Unknown cmd");
		case ERR_ARGS:    return ("Bad args");
		case ERR_NACK:    return ("NACK (No such device/register?)");
		case ERR_READ:    return ("Read error");
		case ERR_WRITE:   return ("Write error");
		case ERR_PARAM:   return ("Bad function parameters");
		case ERR_ADDRESS: return ("Address error");
		case ERR_EOL:     return ("End of line");
		case ERR_NOTREADY:   return ("Device not ready");
		default:          return ("Error (unknown)");
	}
}

int default_exec_cmd(int argc, char **argv)
{
	int ret;
	ret = exec_cmd(argc, argv);
	if (ret == ERR_CMD) {
		switch (argv[0][0]) {
			case 'h':
				write_string(s_help);
				ret = 0;
				break;
			default:
				return ERR_CMD;
		}
		ret = S_IDLE;
	}
	return ret;
}

const char s_prompt[] = "# ";


int main(void)
{
	int i = 0, j;
	int ret = 0;
	int argc = 0;
	static char *argv[4];
	char c;

	Token t;

	MainState state = S_IDLE;

	ret = perio_init();
	if (ret < 0) {
#ifdef SIMULATION
		BREAK; // Message to debugger: FW/HW mismatch, or intended break
#else
		write_string("Board init failed\n");
#endif
	}

#ifndef SIMULATION
	// Configure GPIO outs:
	write_string(s_info);
#endif

#ifdef CONFIG_UART
	while (1) {
		// Here we can check for other input events:
		mainloop_handler(state);
		switch (state) {
			case S_IDLE:
				write_string(s_prompt);
				uart_stty(0, 1);
				state = S_INPUT;
			case S_INPUT:
				ret = gettoken(&t, g_shell.word, sizeof(g_shell.word));
				if (ret < 0) {
					state = S_ERROR;
					break;
				}
				switch (t) {
					case T_NONE: break;
					case T_NL: state = S_IDLE; break;
					case T_CHAR:
						state = S_CMD;
						break;
					default:
						state = S_ERROR;
				}
				break;
			case S_CMD:
				ret = gettoken(&t, g_shell.word, sizeof(g_shell.word));
				if (ret < 0) { state = S_ERROR; break; }
				switch (t) {
					case T_WORD_LAST:
					case T_WORD:
						j = 0;
						argv[argc++] = &g_shell.buf[i];
						while ( (c = g_shell.word[j++]) )
							{ g_shell.buf[i++] = c; }
						g_shell.buf[i++] = '\0';
						if (t == T_WORD) break;
					case T_NL:
						ret = default_exec_cmd(argc, argv);
						argc = 0; i = 0;
						if (ret < 0) state = S_ERROR;
						else if (ret == 0) state = S_IDLE;
						else         state = ret;
						break;
					default:
						break;
				}
				break;
			case S_INTERACTIVE:
				ret = gettoken(&t, g_shell.word, sizeof(g_shell.word));
				if (ret < 0) { state = S_ERROR; break; }
				switch (t) {
					case T_ESC:
						uart_stty(0, 1);
						state = S_IDLE;
						ret = default_exec_abort();
						break;
					default:
						break;
				}
				break;
			case S_ERROR:
				// uart_reset(0);
				write_string(errtostring(ret));
				write_string("\n");
				state = S_IDLE;
				break;
			default:
#ifdef CONFIG_PRINTF
				printf("Unknown return state: %d\n", state);
#else
				write_string("Unknown return state\n");
#endif
				state = S_IDLE;
		}
	}

#else
	BREAK;

#endif
	// we typically never get here, if we have a console.
	return -1;
}


