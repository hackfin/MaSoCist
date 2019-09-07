/* I/O defines for SoC
 *
 * (c) 2011-2015 <hackfin@section5.ch>
 *
 * Also contains auxiliary peripheral I/O functions.
 *
 * This file is a mess, and documentation is missing. I know.
 *
 */

#include "ioaccess.h"
#include "soc_register.h"
#include "bsp.h"

#ifdef CONFIG_LCD_GPIO
// Simple GPIO driver
#include "lcd_gpio.h"
#else
#endif


/** Simple macro to create bit field value */
#define BITFIELD(name, x)  (((x) << name##_SHFT) & name)

/** HW revision tag generation */
#define HWVERSION ( (HWREV_system_map_MAJOR << REV_MAJOR_SHFT) | \
                    (HWREV_system_map_MINOR << REV_MINOR_SHFT) )

#if defined(CONFIG_MACHXO2) || defined (CONFIG_MACHXO3)
#define CLOCK_FREQUENCY CONFIG_MACHXO2_OSC_CLK
#else
#define CLOCK_FREQUENCY CONFIG_SYSCLK
#endif


// Hack to automatically resolve Interrupt vector register:
#define __CONCAT__(a, b)  a##b
#define CONSTRUCT_IV(n) __CONCAT__(Reg_SIC_IV,n)

#define GPIO_MMR(base, addr) device_mmr_base(GPIO, (base), addr)
#define PWM_MMR_BASE(base, addr) device_mmr_base(PWM, (base), addr)

#define SPAD_ADDRESS(i) \
	(Reg_spad_base + (i << MMR_SELECT_DEVINDEX_SPAD_SHFT))

// Must be power of two:
#define FIFO_SIZE_UART (1 << 4)
#define FIFO_SIZE_AUX  (1 << 4)

#define FIFO_MASK_UART (FIFO_SIZE_UART-1)
#define FIFO_MASK_AUX  (FIFO_SIZE_AUX-1)

struct Uart_Context {
#ifdef USE_UART_INTERRUPT
	char buf[FIFO_SIZE_UART];
	volatile unsigned short tail;
	volatile unsigned short head;
#endif
	unsigned char flags;
	unsigned char echo;
};

struct Queue {
	char buf[FIFO_SIZE_AUX];
	volatile unsigned char tail;
	volatile unsigned char head;
	unsigned char flags;
};

extern struct Uart_Context g_uart;
extern struct Queue g_i2cb;

extern
void (*g_putchar)(int s);

// UART flags:
#define F_BREAK    0x08


/* Driver exports */

int i2c_init(unsigned char index, uint16_t div);
int i2c_test(char dev);
int i2c_probe(char index, int slave_addr);
int i2c_writereg(char index, char slave_addr, char reg, unsigned char data);
int i2c_readreg(char index, char slave_addr, char reg, unsigned char *data);

int i2c_do_probe(void);

// New, license free TWI:
int twi_detect(char dev); // in helper.c
void twi_reset(MMRBase twi);
int twi_probe(MMRBase twi, char addr);
int twi_dev_init(char dev, int div);
int twi_send(char dev, unsigned int addr, const unsigned char *data, int n);
int twi_recv(char dev, unsigned int addr, unsigned char *data, int n);
uint16_t twi_wait(MMRBase twi);

int eeprom_dump(int sladdr, int addr, int n);
int eeprom_write(int sladdr, int addr, int n, char *data);
int eeprom_write_byte(int sladdr, int addr, char data);

/** BEGIN Board specific functions */

/** Board initialization */
int board_init(void);
/** Main loop handler */
int mainloop_handler(int state);
/** Command exec handler */
int exec_cmd(int argc, char **argv);
/** LED blinking function */
void led_init(void);

void led_blink(int n, int d);

/* END Board specific functions */

void my_putchar(int c);

int uart_test(char dev, int cycles);
void uart_reset(char dev);
int uart_putc(char dev, const char c);
int uart_getc(char dev);
int uart_puts(char dev, const char *str);
int uart_stty(int which, int val);
int uart_check(char dev);
int uart_rxready(char dev);

#ifdef CONFIG_TIMER

struct timer_t {
	int hz;
	int pulse;
};

void systimer_init(struct timer_t *timer);
uint32_t timer_get(void);

int pwm_test(int n);
int pwm_cfg(int index, int p, int w, int cfg);
#endif


#ifdef CONFIG_SCACHE
void cache_printinfo(void);
void cache_exc_handler(void);
void cache_init(uint32_t enable);
#endif

#ifdef CONFIG_ETHERNET

// Low level Phy access:
int phy_write(uint16_t addr, uint16_t val);
int phy_read(uint16_t addr, uint16_t *val);

void setup_dma(void);
int mac_handle(void);
void pkt_dump(const unsigned char *buf, int n, const char *pre);
int packet_read(unsigned char **p);
int packet_getptr(unsigned char **p);
int packet_commit(int n);
int packet_pop(void);
void check_errflags(void);

// User 'ESC' abort handler
void user_abort(void);

#define report(x) puts(x)
#endif

#ifdef CONFIG_VIDEO
int sensor_probe(int *slave);
int mt9m024_setres(int x, int y);
int mt9m024_init(void);
void sensor_enable(int en);

int do_jpeg(int argc, unsigned int *val);

#endif

// Utils:
int parse_hex(const char *hex, unsigned int *val);
short parse_dec(const char *dec, unsigned short *val);
void put_byteval(unsigned char val);
void put_shortval(uint16_t val);
char *to_dec(unsigned short val, char *buf);
void put_decval_s(unsigned short val);
#ifndef HAVE_STRLEN
size_t strlen(const char *s);
#endif

void write_string(const char *s);


void delay(int i);
