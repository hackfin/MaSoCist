#include <stdint.h>

#include "driver.h"

struct Uart_Context g_uart = {
	// Note: Initializer not effective when 0 on legacy ZpuSoc
	// Need explicit initialization in code.
	.echo = 1
};

int uart_putc(char dev, char c)
{
	while ((MMR(Reg_UART_STATUS) & TXREADY) == 0);
	MMR(Reg_UART_TXR) = c;
	return 0;
}

int uart_read(char dev, unsigned char *buf, unsigned int size)
{
	int n = 0;
	uint8_t c;
	uint16_t st;

	st = MMR(Reg_UART_STATUS);

	while (n < size && (st & RXREADY)) {

		c = MMR(Reg_UART_RXR);
		n++;
		*buf++ = c;
		if (g_uart.echo & 0x1) {
			if (c != '\033') uart_putc(0, c);
			if (c == '\015') uart_putc(0, '\012'); // Append LF to CR
		}
		st = MMR(Reg_UART_STATUS);
	}

	if (st & RXOVR) {
		return ERR_READ;
	}
	return n;
}

int uart_init(char dev, int dll)
{
	/* Index is currently unused */
	uint32_t v;

	dll--;
	v = (dll << UART_CLKDIV_SHFT) & UART_CLKDIV;

	MMR(Reg_UART_CONTROL) = v | UART_RESET;
	MMR(Reg_UART_CONTROL) = v;

	return 0;
}

////////////////////////////////////////////////////////////////////////////

volatile unsigned int *addr = (unsigned int *) 0x78000;

struct {
	int i;
} g_result;

int test(void)
{
	int a = 0xdeadbeef;
	unsigned int b = 0xffff0000;
	int c;
	char buf[2];
	int ret;

	uart_init(0, 1);

	while (1) {

		c = a & b;
		b >>= 1;
		ret = uart_read(0, buf, 1);
		if (ret < 0) asm("ebreak");
			
		g_result.i = c;
		asm("brkpt:");
	}
	return c;
}

int main(void)
{
	int ret;
	ret = test();
}

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	asm("ebreak");
}

