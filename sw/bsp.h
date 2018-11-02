/* Exported board supply package stuff, HW agnostic */

enum {
	ERR_CMD = -32,
	ERR_EOL,
	ERR_NACK,
	ERR_ARBLOST,
	ERR_NODEV,
	ERR_READ,
	ERR_WRITE,
	ERR_NOTREADY,
	ERR_ADDRESS,
	ERR_ARGS,
	ERR_PARAM,
};

enum {
	SYS_REBOOT,
	SYS_BOOT1,
	SYS_BOOT2, // Reserved, yet unused
};

#ifdef CONFIG_SPI
void spi_init(int div);
int spiflash_detect(char *codes);
void spiflash_read(uint32_t addr, unsigned char *buf, int n);
void spiflash_read32(uint32_t addr, uint32_t *buf, int n);
int spiflash_write32(uint32_t addr, const uint32_t *buf, uint32_t n);
int spiflash_erasesector(uint32_t addr);
int spiflash_write(uint32_t addr, const char *buf, uint32_t n);

void flash_print_info(char *codes);
#endif

/* Retrieve system clock */
const int get_sysclk(void);

/* Exported UART functionality */
int uart_init(char dev, int dll);
int uart_read_raw(char dev, unsigned char *buf, unsigned int size);
int uart_read(char dev, unsigned char *buf, unsigned int size);
int uart_write(char dev, unsigned char *buf, unsigned int size);

/* Exported MAC functionality */
int mac_state(int *rxfill, int *txfill, int *rxerr);


void sys_reboot(int mode);

int nv_loadconfig(void);

/* Exported LCD functions: */
