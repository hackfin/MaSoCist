#include "driver.h"

#ifdef CONFIG_I2C

int i2c_do_probe(void)
{
	int i, ret;
	char bra, brb;

	uart_puts(0, "BEGIN Test\r\n");

	uart_puts(0, "\tProbe i2c...(hex addresses!)\r\n\t");
	for (i = 1; i < 0x6f; i++) {
		ret = i2c_probe(0, i);
		if (ret & 1) bra = '<'; else bra = ' ';
		if (ret & 2) brb = '>'; else brb = ' ';
		if (ret) {
			uart_putc(0, bra);
			put_byteval(i);
			uart_putc(0, brb);
		} else if ((i % 8 ) == 0) {
			uart_putc(0, '.');
		}
	}
	uart_puts(0, "OK\r\n");

	uart_puts(0, "END Test\r\n");

	return 0;
}

#endif
