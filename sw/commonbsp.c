/* Specific board supply routines */

#include "driver.h"
#include <stdio.h>

#ifdef CONFIG_PLL_MUL
#define PLL_FACTOR       CONFIG_PLL_MUL / CONFIG_PLL_DIV
#else
#define PLL_FACTOR       1
#endif

#define SYSCLK           CLOCK_FREQUENCY * PLL_FACTOR

static uint32_t g_sysclk = SYSCLK;

#ifdef SIMULATION
#define DELAY_CYCLES 1
#else
#define DELAY_CYCLES 1000
#endif

// static unsigned long irq_count = 0;

const int get_sysclk(void)
{
	return g_sysclk;
}

void delay(int i)
{
	int j;
	while (i--) {
		j = DELAY_CYCLES;
		while (j--) { asm("nop"); }
	}
}

#if defined(CONFIG_VIRTUAL_CONSOLE) \
	|| defined(CONFIG_JTAG_CONSOLE)

void my_putchar(int c)
{
	if (c == '\n') {
		MMR(Reg_SysConsole_W) = '\r';
	}
	MMR(Reg_SysConsole_W) = c;
}

#elif defined(CONFIG_UART_DEBUGCONSOLE)

__attribute__((weak))
void my_putchar(int c)
{
	uart_putc(0, c);
	if (c == '\n') {
		uart_putc(0, '\r');
	}
}
#else
#warning "NO putchar present, define your own!"
__attribute__((weak))
void my_putchar(int c)
{
}
#endif

void (*g_putchar)(int s) = my_putchar;

#ifdef CONFIG_PRINTF
void _putc(int c, FILE *stream)
{
	g_putchar(c);
}
#endif

void write_string(const char *s)
{
	while (*s) {
		g_putchar(*s++);
	}
}

