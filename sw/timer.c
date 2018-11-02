/* Note that the systimer initialization is only effective if CONFIG_SIC is enabled
 *
 *
 */

#ifndef CONFIG_SIC
#warning "System interrupt controller not enabled, IRQ handlers not effective"
#endif

#include "driver.h"
#include "platform.h"
#include "soc_register_modes.h"


#ifdef CONFIG_TASK_MANAGEMENT

#include "tasks.h"

extern void irq_timer_handler;

void timer_service(void)
{
	tasklist_visit(0);
	MMR(Reg_SIC_IPEND_W1C) = PINMAP_IRQ_TIMER0; // rearm IRQ
}

#else

volatile static uint32_t g_count;

 __attribute__((weak)) 
void do_timer_stuff(void)
{
}

FORCE_L1RAM __attribute__((interrupt))
void irq_timer_handler(void)
{
	g_count++;
	do_timer_stuff();
	MMR(Reg_SIC_IPEND_W1C) = PINMAP_IRQ_TIMER0; // rearm IRQ
}

uint32_t timer_get(void)
{
	return g_count;
}

#endif


// System timer is always timer 0
void systimer_init(struct timer_t *timer)
{

	// Use bit shift definition to create proper Reg_SIC_IV address:
	MMR(CONSTRUCT_IV(PINMAP_IRQ_TIMER0_SHFT)) = (uint32_t) &irq_timer_handler;

	// Configure timer clock:
#ifndef SIMULATION
	uint16_t clkdiv = get_sysclk() / timer->hz - 1;
#else
	uint16_t clkdiv = (50-1); // Simulation PWM frequency
#endif
	// If we overflow, fail early.
	if (clkdiv > PWMCLKDIV) {
		BREAK;
	}
	MMR(Reg_TIMER_CONFIG) = CRESET | clkdiv;

#ifndef CONFIG_PWM_NONE
	int cfg;
	cfg = TMR_IRQEN;

#ifdef CONFIG_PWM_ADVANCED
	cfg |= TMODE_CFG1;
#endif

	MMR(Reg_SIC_IMASK) |= PINMAP_IRQ_TIMER0;
	pwm_cfg(0, timer->pulse, timer->pulse, cfg);
#endif

	MMR(Reg_TIMER_START) = 0x01; // start Timer 0
}

#ifndef CONFIG_TASK_MANAGEMENT

unsigned long timer_set(int val)
{
	unsigned long c;
	MMR(Reg_TIMER_STOP) = 0x01; // stop Timer 0
	c = g_count;
	MMR(Reg_TIMER_START) = 0x01; // start Timer 0
#ifndef CONFIG_PWM_NONE
#ifdef CONFIG_PWM_ADVANCED
	pwm_cfg(0, val, val, TMR_IRQEN | TMODE_CFG1); // 1000Hz jiffies
#else
	pwm_cfg(0, val, val, TMR_IRQEN); // 1000Hz jiffies
#endif
#endif
	return c;
}

#ifdef TIMER_TEST

void timer_test(void)
{
	unsigned long c;

	c = timer_set(1); while (c == g_count) { asm("nop"); }
	c = timer_set(2); while (c == g_count) { asm("nop"); }
	c = timer_set(1); while (c == g_count) { asm("nop"); }
	while (c == g_count) { asm("nop"); }
	asm("breakpoint");
}

#endif
#endif
