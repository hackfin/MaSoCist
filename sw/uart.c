/* UART simple driver
 *
 * (c) 2012, Martin Strubel <hackfin@section.ch>
 *
 *
 */


#include "driver.h"
/* Software FIFO */

// Hack: Should not be in here for the BSP lib
#ifdef CONFIG_LCDIO_HACK
#include "lcd.h"
#endif

struct Uart_Context g_uart = {
	// Note: Initializer not effective when 0 on legacy ZpuSoc
	// Need explicit initialization in code.
#ifdef USE_UART_INTERRUPT
	.tail = 0,
	.head = 0,
#endif
	.echo = 0
};

int uart_putc(char dev, char c)
{
	while ((MMR(Reg_UART_STATUS) & TXREADY) == 0);
#ifdef RISCV_UGLY_WORKAROUND_HACK_MUST_BE_REMOVED
	delay(1);
#endif
	MMR(Reg_UART_TXR) = c;
	return 0;
}

int uart_getc(char dev)
{
	while (!(MMR(Reg_UART_STATUS) & RXREADY)); // XXX blocking
	return MMR(Reg_UART_RXR);
}

int uart_puts(char dev, const char *str)
{
	while (*str) {
		while (!(MMR(Reg_UART_STATUS) & TXREADY));
		MMR(Reg_UART_TXR) = *str++;
	}
	return 0;

}

/**
 * Read bytes from UART sw FIFO
 *
 * This is a non blocking read routine, i.e. it returns immediately
 * with the number of bytes received from the FIFO.
 *
 * \param buf   The buffer to read the bytes to
 * \param size  The maximum size of the buffer
 *
 * \return The number of bytes read
 *
 */

#ifdef USE_UART_INTERRUPT

int uart_read(unsigned char *buf, unsigned int size)
{
	int nbytes = 0;
	// if (g_uart.fifoerr) { g_uart.fifoerr = 0; return g_uart.fifoerr; }

	while ((g_uart.tail != g_uart.head) && (nbytes < size) ) {
		*buf++ = g_uart.buf[g_uart.tail++];
		g_uart.tail &= FIFO_MASK_UART;
		nbytes++;
	}
	return nbytes;
}

#else

int uart_check(char dev)
{
	return (MMR(Reg_UART_STATUS) & RXOVR);
}

int uart_rxready(char dev)
{
	return (MMR(Reg_UART_STATUS) & RXREADY);
}

int uart_read_raw(char dev, unsigned char *buf, unsigned int size)
{
	int n = 0;
	int c;

	// c = MMR(Reg_UART_RXR);
	while ((MMR(Reg_UART_STATUS) & RXREADY) && (n < size) ) {
	// while (n < size && (c & DVALID)) {
		c = MMR(Reg_UART_RXR);
		*buf++ = c; n++;
	}
	return n;
}

int uart_write(char dev, unsigned char *buf, unsigned int size)
{
	while (size--) {
		while (!(MMR(Reg_UART_STATUS) & TXREADY));
		MMR(Reg_UART_TXR) = *buf++;
	}
	return 0;
}

int uart_read(char dev, unsigned char *buf, unsigned int size)
{
	int n = 0;
	int c;

	volatile uint32_t *stat = &MMR(Reg_UART_STATUS);

	
	while ((*stat & RXREADY) && (n < size) ) {
		c = MMR(Reg_UART_RXR); n++;
		c &= 0xff;
		*buf++ = c;
		if (g_uart.echo & 0x1) {
			if (c != '\033') uart_putc(0, c);
			if (c == '\015') uart_putc(0, '\012'); // Append LF to CR
		}
#ifdef CONFIG_LCDIO_HACK
		if (g_uart.echo & 0x2) {
			// Ctrl-L:
			if (c == '\014') {
				lcd_home(); lcd_fillscreen(TO_RGB332(0x001f));
			}
			else if (c == '\015') lcd_putc('\012');
			else if (c != '\033') lcd_putc(c);
		}
#endif
	}
#ifndef RISCV_UGLY_WORKAROUND_HACK_MUST_BE_REMOVED
	if (MMR(Reg_UART_STATUS) & RXOVR) {
		return ERR_READ;
	}
#endif
	return n;
}


#endif

int uart_stty(int dev, int val)
{
	g_uart.echo = val;
	return 0;
}

void uart_reset(char dev)
{
	uint32_t v;
	v = MMR(Reg_UART_CONTROL);
	MMR(Reg_UART_CONTROL) = v | UART_RESET;
	MMR(Reg_UART_CONTROL) = v;
}

int uart_init(char dev, int dll)
{
	/* Index is currently unused */
	uint32_t v;

	MMR(Reg_UART_CONTROL) = UART_RESET;

	dll--;
	v = (dll << UART_CLKDIV_SHFT) & UART_CLKDIV;

#ifdef USE_UART_INTERRUPT
	g_uart.head = g_uart.tail = 0;
#endif

	MMR(Reg_UART_CONTROL) = v;

	return 0;
}

