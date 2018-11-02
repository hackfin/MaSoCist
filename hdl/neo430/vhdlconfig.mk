
ifndef CONFIG_NEO430_NATIVE
CONFIGURATION-y += $(call convert_int,CONFIG_NEO430_DMEM_WIDTH)
endif

CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_DADD)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_MULDIV)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_PWM)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_WDT)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_GPIO)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_TIMER)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_USART)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_CRC)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_TRNG)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_BOOTLD)
CONFIGURATION-y += $(call convert_boolean,CONFIG_NEO430_IMEM_RO)
