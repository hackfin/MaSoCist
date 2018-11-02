/* Note: ZPU 'legacy' is kinda broken regarding IRQ handling.
 * If IRQs are occuring at a high rate, chances are that this interrupt
 * handler gets called from within itself -> Stack overflow
 *
 * FIXME: Move all the data I/O into the DMA section later on.
 *
 * DEPRECATED: No longer used and supported. Upgrade to ZPUng :-)
 */

#include "driver.h"


extern struct Uart_Context g_uart;


struct Queue g_i2cb = {
	.tail = 0,
	.head = 0
};

void _zpu_interrupt(void)
{
	unsigned short mask; // Note: No statics inside reentrant routines!

	// irq_count++;
	// The interrupts we support:
	mask = MMR(Reg_SIC_IPEND);

#ifdef CONFIG_OC_UART16550
	int c;
	unsigned char stat;

 	if (mask & PINMAP_IRQ_UART) {
 		stat = MMR(Reg_LSR);
 		if (stat & LSR_DR) {
 			// Read character from register and put into FIFO:
 			c = MMR(Reg_RBR);
 			g_uart.buf[(g_uart.head++)] = c;
			g_uart.head &= FIFO_MASK_UART;
			if (g_uart.echo) {
				if (c != '\033') uart_putc(0, c);
				if (c == '\015') uart_putc(0, '\012'); // Append LF to CR
			}
 		} else
 		if (stat & LSR_BI) {
 			// XXX: Disable UART IRQ when receiving break
 			MMR(Reg_SIC_IMASK) = 0x0000;
 			// Set GPIOs:
 			MMR(Reg_GPIO_SET) = 0x00ff;
 			g_uart.flags = F_BREAK;
 		}
 		MMR(Reg_SIC_IPEND_W1C) = PINMAP_IRQ_UART; // Allow another UART IRQ
	}
#endif // UART

#ifdef CONFIG_I2CBRIDGE
 	if (mask & PINMAP_IRQ_I2C_BRIDGE) {
		g_i2cb.buf[(g_i2cb.head++)] = MMR(Reg_IBData);
		g_i2cb.head &= FIFO_MASK_AUX;
 		MMR(Reg_SIC_IPEND_W1C) = PINMAP_IRQ_I2C_BRIDGE; // Allow another IRQ
	}
#endif
}

