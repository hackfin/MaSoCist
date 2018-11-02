# Define custom modules in vendor/$(VENDOR)/Makefile
# DO NOT PLACE ANY COTTONPICKEN IP IN HERE!
GENSOC_MODULES-$(CONFIG_GPIO)             += gpio
GENSOC_MODULES-$(CONFIG_DMA_SIMPLE)       += dma
GENSOC_MODULES-$(CONFIG_SCACHE)           += cache
GENSOC_MODULES-$(CONFIG_SIC)              += sic
GENSOC_MODULES-$(CONFIG_SPI)              += spi
GENSOC_MODULES-$(CONFIG_TWI)              += twi
GENSOC_MODULES-$(CONFIG_UART_SIMPLE)      += uart
GENSOC_MODULES-$(CONFIG_PWM_SIMPLE)       += pwm
GENSOC_MODULES-$(CONFIG_PWM_ADVANCED)     += pwmplus
GENSOC_MODULES-$(CONFIG_MAC)              += mac
GENSOC_MODULES-$(CONFIG_FIFO)             += fifo
GENSOC_MODULES-$(CONFIG_PLAYGROUND)       += playground

# Some modules that we may want to override:
ifndef CONFIG_SECTION5_PROPRIETARY_MODULES
GENSOC_MODULES-$(CONFIG_TIMER)            += tmr
endif

ifndef SRC
TOPDIR = ../..
include $(TOPDIR)/config.mk
endif

ifneq ($(CUSTOM_MODULES-y),)
GENSOC_MODULES-y                          += $(CUSTOM_MODULES-y)
endif

PERIO-y  += sys_$(DEVICE_FAMILY).vhdl 
PERIO-y  += $(GENSOC_MODULES-y:%=%.vhdl)

-include $(SRC)/perio/refdesign/Makefile

ifdef CONFIG_MAC
include $(SRC)/core/trimac/Makefile
endif

ifndef SYNTHESIS
PERIO-$(CONFIG_VIRTUAL_CONSOLE) += vconsole.vhdl
endif

PERIO-$(CONFIG_CRC16) += crc16.vhdl
# Architectures that are less picky with clock routing:
ifndef CONFIG_SPARTAN6
PERIO-$(CONFIG_SPI) += clkdiv.vhdl
PERIO-$(CONFIG_SPI) += clkdrv.vhdl
endif
PERIO-$(CONFIG_UART_SIMPLE) += uart_tx.vhdl uart_rx.vhdl

GENERATED_FILES-$(CONFIG_TWI)   += $(SRC)/core/unisi/i2c_master.vhd
GENERATED_FILES-$(CONFIG_MACHXO_EFB) += $(SRC)/perio/efb_wrapper.vhdl

# Include for NEO430:
PERIO-$(CONFIG_NEO430) += dmem_wrapper.vhdl

PERIO-$(CONFIG_OC_UART16550) += $(UART16550_FILES)
PERIO-$(CONFIG_OC_I2C_RD1046) += $(LATTICE_RD1046_I2C_FILES)

# Make sure we include this dependency for the perio simulator:
PERIO-$(PERIO_SIMULATION) += ../ram/bram.vhdl

# Template generation:

CORE_SKEL_XSL ?= $(GENSOC_DIR)/coretempl.xsl

%-template.vhdl: $(SOC_DEVICEFILE) $(CORE_SKEL_XSL)
	$(XSLTPROC) -o $@ --stringparam srcfile $< \
	--stringparam iface_type unsigned \
	--stringparam entityname $(patsubst %-template.vhdl,%,$@) \
	$(CORE_SKEL_XSL) $<

clean::
	rm -f *-template.vhdl
