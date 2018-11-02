
#include "driver.h"

#define i2c_mmr(dev, x)  MMR32(x + (dev << MMR_SELECT_perio_SHFT))

#define I2C_WRITE 0x0
#define I2C_READ  0x1

#define wait_for_completion(i) \
	while (i2c_mmr(i, Reg_SR) & TIP);

static
int i2c_write(char index, char data, unsigned char mode)
{
	int ret = 0;
	i2c_mmr(index, Reg_TXR) = data;
	i2c_mmr(index, Reg_CR) = WRITE | mode;
	wait_for_completion(index);
 	if ((i2c_mmr(index, Reg_SR) & RXACK) != 0) ret = ERR_NACK;
	return ret;
}

static
int i2c_read(char index, unsigned char *data, unsigned char mode)
{
	int ret = 0;
	i2c_mmr(index, Reg_CR) = READ | mode;
	wait_for_completion(index);
	*data = i2c_mmr(index, Reg_RXR);
 	if ((i2c_mmr(index, Reg_SR) & RXACK) != 0 && (mode & SACK) == 0)
		ret = ERR_NACK; // Failure
	return ret;
}

int i2c_writereg(char index, char slave_addr, char reg, unsigned char data)
{
	int ret;
	ret = i2c_write(index, (slave_addr << 1) | I2C_WRITE, START);
	if (ret >= 0) {
		i2c_write(index, reg, 0);
		ret = i2c_write(index, data, STOP);
	} else {
		i2c_mmr(index, Reg_CR) = STOP;
		wait_for_completion(index);
	}
	return 0;
}

int i2c_readreg(char index, char slave_addr, char reg, unsigned char *data)
{
	int ret;
	ret = i2c_write(index, (slave_addr << 1) | I2C_WRITE, START);
	if (ret >= 0) {
		i2c_write(index, reg, 0);
		ret = i2c_write(index, (slave_addr << 1) | I2C_READ, START);
		if (ret >= 0) ret = i2c_read(index, data, SACK | STOP);
	} else {
		i2c_mmr(index, Reg_CR) = STOP;
		wait_for_completion(index);
	}
	return ret;
}

int i2c_probe(char index, int slave_addr)
{
	unsigned char flags = 0;
	int ret;

	// if (i2c_readreg(0, slave_addr, 0x00, &data) == 0) { flags |= 1; }

	i2c_write(index, (slave_addr << 1) | I2C_WRITE, START);
	delay(1);
	wait_for_completion(index);
 	if ((i2c_mmr(index, Reg_SR) & RXACK) == 0) { flags |= 0x2; }

	i2c_mmr(index, Reg_CR) = STOP;
	wait_for_completion(index);

	i2c_write(index, (slave_addr << 1) | I2C_READ, START);
	delay(1);
 	if ((i2c_mmr(index, Reg_SR) & RXACK) == 0) { flags |= 0x1; }

	i2c_mmr(index, Reg_CR) = STOP;
	wait_for_completion(index);

	return flags;
}


int i2c_init(unsigned char index, uint16_t div)
{
	i2c_mmr(index, Reg_PRERL) = div & 0xff;
	i2c_mmr(index, Reg_PRERH) = div >> 8;
	// enable core:
	i2c_mmr(index, Reg_CTR) = CORE_EN;
#ifdef SIMULATION
	// return i2c_test(0);
#else
	return 0;
#endif
}


