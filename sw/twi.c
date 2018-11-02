#include "driver.h"


#define TWI_MMR(addr) device_mmr_base(TWI, twi, addr)

uint16_t twi_wait(MMRBase twi)
{
	int retry = 10000;
	uint16_t stat;
	while (((stat = TWI_MMR(Reg_TWI_STATUS)) & BUSY) && retry-- > 0) {
		asm("nop");
	}
	if (retry == 0) {
		BREAK;
	}
	return stat;
}

#define wait_ready(twi) \
	twi_wait(twi);

int twi_send(char dev, unsigned int addr, const unsigned char *data, int n)
{
	uint16_t stat;
	MMRBase twi = &MMR(TWI_Offset); // Single device hack
	if (n < 1) return ERR_PARAM;
	// printf("Write %d bytes to 0x%04x\n", n, addr);
	TWI_MMR(Reg_TWI_CONTROL) = HOLD;
	TWI_MMR(Reg_TWI_SLADDR)  = (addr >> 7) & ~1; // Write
	TWI_MMR(Reg_TWI_WDATA)   = addr & 0xff;
	stat = wait_ready(twi);
 	if (stat & NAK) {
 		TWI_MMR(Reg_TWI_CONTROL) = 0;
 		TWI_MMR(Reg_TWI_WDATA)   = 0; // FIXME: When get in hold state
 		return ERR_NACK;
 	}

	while (--n) {
		TWI_MMR(Reg_TWI_WDATA) = *data++;
		wait_ready(twi);
	}
	TWI_MMR(Reg_TWI_CONTROL) = 0;
	TWI_MMR(Reg_TWI_WDATA) = *data;
	stat = wait_ready(twi);

	if (stat & NAK) return ERR_NACK;
	return 0;
}

int twi_recv(char dev, unsigned int addr, unsigned char *data, int n)
{
	uint16_t stat;
	MMRBase twi = &MMR(TWI_Offset); // Single device hack
	int sladdr = (addr >> 7) & ~1;  // Slave address 'WRITE'

	// printf("Read %d bytes from 0x%04x\n", n, addr);
	// if (TWI_MMR(Reg_TWI_STATUS) & HOLD) return ERR_NOTREADY; 

	if (n < 1) return ERR_PARAM;

	TWI_MMR(Reg_TWI_CONTROL) = 0;
	TWI_MMR(Reg_TWI_SLADDR) = sladdr;
	TWI_MMR(Reg_TWI_WDATA) = addr & 0xff;
	stat = wait_ready(twi);

	if (stat & ARB) {
		return ERR_ARBLOST;
	}

	// If device not present, quit
	if (stat & NAK) {
		return ERR_NACK; 
	}

	delay(1);

	TWI_MMR(Reg_TWI_SLADDR) = sladdr | 1; // READ mode
	if (n == 1) {
		TWI_MMR(Reg_TWI_WDATA) = 0;  // Dummy write to trigger transfer
		wait_ready(twi);
		*data = TWI_MMR(Reg_TWI_RDATA); 
	}
	else {
		n--;
		TWI_MMR(Reg_TWI_CONTROL) = AUTOARM | HOLD; 
		TWI_MMR(Reg_TWI_WDATA) = 0;  // Dummy write to trigger transfer
		wait_ready(twi);
		while (--n) {
			*data++ = TWI_MMR(Reg_TWI_RDATA);
			wait_ready(twi);
			delay(1);
		}
		TWI_MMR(Reg_TWI_CONTROL) = MACK; // Final ACK
		*data++ = TWI_MMR(Reg_TWI_RDATA); 
		wait_ready(twi);
		TWI_MMR(Reg_TWI_WDATA) = 0;  // Dummy write to trigger transfer
		wait_ready(twi);
		*data = TWI_MMR(Reg_TWI_RDATA);
	}

	return 0;
}

int twi_probe(MMRBase twi, char addr)
{
	TWI_MMR(Reg_TWI_SLADDR) = addr << 1;

	TWI_MMR(Reg_TWI_WDATA) = addr & 0xff;
	wait_ready(twi);
	return TWI_MMR(Reg_TWI_STATUS);
}

int twi_dev_init(char dev, int div)
{
	MMRBase twi = &MMR(TWI_Offset); // Single device hack

	TWI_MMR(Reg_TWI_CONTROL) = I2C_RESET;
	TWI_MMR(Reg_TWI_DIV) = div;
	delay(5);
	TWI_MMR(Reg_TWI_CONTROL) = 0;
	return 0;
}

void twi_reset(MMRBase twi)
{
	TWI_MMR(Reg_TWI_CONTROL) = I2C_RESET;
	TWI_MMR(Reg_TWI_CONTROL) = 1-1; // One byte per transaction
}
