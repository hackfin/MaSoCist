#include "driver.h"
#include "soc_register.h"

#include "platform.h" // Platform specifics

#define PWM_MMR(base, addr) device_mmr_base(PWM, base, addr)

#ifdef CONFIG_PWM_SIMPLE

int pwm_cfg(int index, int p, int w, int cfg)
{
	MMRBase pwm = device_base(PWM, index);
	
	PWM_MMR(pwm, Reg_PWM_CONFIG) = cfg;
	PWM_MMR(pwm, Reg_PWM_WIDTH) = w-1;
	PWM_MMR(pwm, Reg_PWM_PERIOD) = p-1;

	return 0;
}

#elif defined(CONFIG_PWM_ADVANCED)

int pwm_cfg(int index, int p, int w, int cfg)
{
	MMRBase pwm = device_base(PWM, index);
	
	PWM_MMR_BASE(pwm, Reg_PWM_CONFIG) = cfg;
	PWM_MMR_BASE(pwm, Reg_PWM_WIDTH0) = w-1;
	PWM_MMR_BASE(pwm, Reg_PWM_PERIOD0) = p-1;
	PWM_MMR_BASE(pwm, Reg_PWM_WIDTH1) = w-1;
	PWM_MMR_BASE(pwm, Reg_PWM_PERIOD1) = p-1;

	return 0;
}

#else
#warning "pwm_cfg() undefined"
#endif


#ifdef SIMULATION

int pwm_test(int div)
{
	pwm_cfg(0, 10, 1, 0);
	pwm_cfg(1, 10, 5, 0);
	pwm_cfg(7, 20, 19, 0);

	MMRBase pwm = device_base(PWM, 7);

	PWM_MMR(pwm, Reg_PWM_CONFIG) = TMR_IRQEN;

	MMR(Reg_TIMER_START) = 0x83; // start timers
	delay(20);
	MMR(Reg_TIMER_STOP) = 0x3; // stop #0 and #1
	delay(20);

	MMR(Reg_TIMER_START) = 0x4; // Start timer #2

	PWM_MMR(pwm, Reg_PWM_CONFIG) = 0;
	delay(150);
	MMR(Reg_TIMER_STOP) = 0x7;
	return 0;
}

#endif
