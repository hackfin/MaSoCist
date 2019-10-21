#include <stdint.h>

#include "driver.h"
#include "soc_register.h"
#include "arch/riscv/csr_register.h"
#include "arch/riscv/irq.h"

void enable_machine_irqs(char which)
{
	uint32_t v;
	v = csr_read(mstatus);
	if (which) v |= MSTATUS_MIE;
	else       v &= ~MSTATUS_MIE;
	csr_write(mstatus, v);
}

void enable_irqs(uint32_t mask)
{
	uint32_t v;
	v = csr_read(mie);
	v |= mask;
	csr_write(mie, v);
}

void disable_irqs(uint32_t mask)
{
	uint32_t v;
	// mask <<= 24;
	v = csr_read(mie);
	v &= ~mask;
	csr_write(mie, v);
}


#include "arch/riscv/csr_register.h"

void dmarx_handler(void);
void dmatx_handler(void);
void timer_handler(void);

extern
void exception_handler(uint32_t cause, void * epc, void * regbase);

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	if (cause & MCAUSE_IRQ) {

#ifdef CONFIG_GPIO
	MMRBase gpio0_base = device_base(GPIO, 0);
	GPIO_MMR(gpio0_base, Reg_GPIO_OUT) = cause;
#endif

#ifndef CONFIG_SIC
		switch (cause & MCAUSE_CAUSE) {
			case PINMAP_IRQ_TIMER0_SHFT:
				timer_handler();
				break;
#ifdef PINMAP_IRQ_DMA_RX_SHFT
			case PINMAP_IRQ_DMA_RX_SHFT:
				dmarx_handler();
				break;
			case PINMAP_IRQ_DMA_TX_SHFT:
				dmatx_handler();
				break;
#endif
			default:
				break;
		}
#endif

	} else {
	// Exception
	}
}

