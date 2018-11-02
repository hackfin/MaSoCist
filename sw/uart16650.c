/* UART 16550 simple driver
 *
 * (c) 2012, Martin Strubel <hackfin@section.ch>
 *
 *
 */


#include "io.h"
#include "driver.h"



int uart_putc(char dev, char c)
{
	while (!(MMR(Reg_LSR) & LSR_THRE));
	MMR(Reg_THR) = c;
	return 0;
}

int uart_puts(char dev, const char *str)
{
	while (*str) {
		while (!(MMR(Reg_LSR) & LSR_THRE));
		MMR(Reg_THR) = *str++;
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

int uart_stty(int which, int val)
{
	g_uart.echo = val;
	return 0;
}

int uart_init(char dev, int dll)
{
	unsigned char c;
	/* Index is currently unused */

	// Shows no effect:
	// MMR(Reg_MCR) = MCR_LOOPB;

	MMR(Reg_LCR) = 0x00;
	MMR(Reg_FCR) = FCR_CLTX | FCR_CLRX; // Clear FIFOS, don't enable

	while ((MMR(Reg_LSR) & LSR_DR)) {
		c = MMR(Reg_RBR); // dummy read until buffer empty
	}

	g_uart.head = g_uart.tail = 0;

	MMR(Reg_IER) = IER_ELSI | IER_ERDAI ; // Enable RX irq
	MMR(Reg_LCR) = LCR_DLAB; // Access Divider Latch
	MMR(Reg_DLL) = dll & 0xff;
	MMR(Reg_DLM) = dll  >> 8;

	MMR(Reg_LCR) = 0x03; // 81N

	// Clear latched spurious interrupts
	MMR(Reg_SIC_ILAT_W1C) = IRQ_UART | IRQ_I2C_BRIDGE;
	
	// Set IMASK to support UART IRQ:
	// Don't enable the IRQ too early. Might fire forever.
	// You might want to disable the next line for the BOOTROM build:
	MMR(Reg_SIC_IMASK)    = IRQ_UART | IRQ_I2C_BRIDGE;

	return 0;
}

