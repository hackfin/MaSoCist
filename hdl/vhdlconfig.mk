# Makefile to generate VHDL package containing global configuration
# variables
#
# (c) 2013-2015 Martin Strubel <hackfin@section5.ch>
#
# Note: Put only common config into this file.
# Vendor specifics should go into vendor/$(VENDOR)/vhdlconfig.mk
#

define nl


endef

define convert_int
	constant $(1) : natural := $($(1));${nl}
endef

define convert_boolean
	constant $(1) : boolean := $(if $(filter $($(1)),y),true,false);${nl}
endef

define convert_hex32
	constant $(1) : std_logic_vector(31 downto 0) := \
		x"$(subst $\",,$($(1)))";${nl}
endef

define convert_hex32u
	constant $(1) : unsigned(31 downto 0) := \
		x"$(subst $\",,$($(1)))";${nl}
endef

define convert_time
	constant $(1) : time := $(subst $\",,$($(1)));${nl}
endef

define HEADER
library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

package global_config is

endef

define FOOTER

end global_config;
endef

CONFIGURATION-y = $(HEADER)

# Defaults for config parameters that may be missing:
CONFIG_NUM_TMR ?= 0
CONFIG_NUM_GPIO ?= 0
CONFIG_NUM_IRQSRC ?= 0
CONFIG_VIRTUALCLK_PERIOD ?= 50 ns
CONFIG_CACHE_PHYSICAL_ADDRESS_BIT ?= 15

# When not defined:
CONFIG_SCACHE_PHYS_PAGE_BIT ?= $(CONFIG_CACHE_PHYSICAL_ADDRESS_BIT)
CONFIG_SCACHE_VIRT_DATA_PAGE_BIT ?= $(CONFIG_CACHE_PHYSICAL_ADDRESS_BIT)
CONFIG_SCACHE_VIRT_INSN_PAGE_BIT ?= $(CONFIG_CACHE_PHYSICAL_ADDRESS_BIT)


CONFIGURATION-y += $(call convert_boolean,CONFIG_SCACHE)
CONFIGURATION-y += $(call convert_boolean,CONFIG_SCACHE_INSN)

# Make sure to not use spaces, otherwise variables don't resolve indirectly.
include $(TOPDIR)/tapconfig.mk
CONFIGURATION-y += $(call convert_hex32,CONFIG_TAP_ID)

CONFIGURATION-y += $(call convert_time,CONFIG_TAPCLK_PERIOD)
CONFIGURATION-y += $(call convert_time,CONFIG_VIRTUALCLK_PERIOD)
CONFIGURATION-y += $(call convert_boolean,CONFIG_VIRTUAL_SILICON)
CONFIGURATION-y += $(call convert_boolean,CONFIG_VIRTUAL_CONSOLE)

ifdef CONFIG_SYSCLK
CONFIGURATION-y += $(call convert_int,CONFIG_SYSCLK)
endif

ifdef CONFIG_DEFAULT_UART_BAUDRATE
CONFIGURATION-y += $(call convert_int,CONFIG_DEFAULT_UART_BAUDRATE)
endif

CONFIGURATION-y += $(call convert_int,CONFIG_NUM_IRQSRC)
CONFIGURATION-$(CONFIG_SPI) += $(call convert_int,CONFIG_SPI_BITS_POWER)
CONFIGURATION-$(CONFIG_TIMER) += $(call convert_int,CONFIG_NUM_TMR)
CONFIGURATION-$(CONFIG_GPIO) += $(call convert_int,CONFIG_NUM_GPIO)
CONFIGURATION-$(CONFIG_UART) += $(call convert_int,CONFIG_NUM_UART)
CONFIGURATION-y += $(call convert_int,CONFIG_ADDR_WIDTH)
CONFIGURATION-y += $(call convert_int,CONFIG_BRAM_ADDR_WIDTH)
CONFIGURATION-y += $(call convert_int,CONFIG_CACHE_PHYSICAL_ADDRESS_BIT)

CONFIGURATION-$(CONFIG_SCRATCHPAD_RAM) += \
	$(call convert_int,CONFIG_SCRATCHPAD_HIGHEST_ADDRESS_BIT)

ifdef CONFIG_PLL_MUL
CONFIGURATION-y += $(call convert_int,CONFIG_PLL_MUL)
CONFIGURATION-y += $(call convert_int,CONFIG_PLL_DIV)
endif

CONFIGURATION-y += $(call convert_boolean,CONFIG_LOCALBUS)
CONFIGURATION-y += $(call convert_boolean,CONFIG_WISHBONE)
CONFIGURATION-y += $(call convert_boolean,CONFIG_ZEALOT)
CONFIGURATION-y += $(call convert_boolean,CONFIG_ZPUNG)
CONFIGURATION-y += $(call convert_boolean,CONFIG_PYPS)

CONFIGURATION-y += $(call convert_boolean,CONFIG_CRC16)
CONFIGURATION-y += $(call convert_boolean,CONFIG_WPU)

CONFIGURATION-$(CONFIG_FIFO) += $(call convert_int,CONFIG_FIFO_WORDWIDTH)

CONFIGURATION-$(CONFIG_MAC) += $(call convert_int,CONFIG_MAC_RXFIFO_BITS)

############################################################################
# Virtual DEVICES config:
#
CONFIGURATION-y += $(call convert_boolean,CONFIG_VIRTUAL_UART)


ifdef CONFIG_ZEALOT
CPU_TYPE = 0
endif

ifdef CONFIG_ZPUNG
CPU_TYPE = 1
endif

ifdef CONFIG_NEO430
CPU_TYPE = 3
endif

# Move all vendor specific configs here:
-include $(TOPDIR)/vendor/$(VENDOR)/vhdlconfig.mk

CONFIGURATION-y += \tconstant SOCINFO_CPU_TYPE : integer := $(CPU_TYPE);${nl}

CONFIGURATION-$(CONFIG_MACHXO2) += \tconstant CONFIG_OSCCLK : string := "$(shell expr substr $(CONFIG_MACHXO2_OSC_CLK) 1 2).$(shell expr substr $(CONFIG_MACHXO2_OSC_CLK) 3 2)";${nl}

CONFIGURATION-$(CONFIG_MACHXO3) += \tconstant CONFIG_OSCCLK : string := "$(shell expr substr $(CONFIG_MACHXO2_OSC_CLK) 1 2).$(shell expr substr $(CONFIG_MACHXO2_OSC_CLK) 3 2)";${nl}

CONFIGURATION-y += $(FOOTER)

VHDLCONFIG = $(SRC)/global_config.vhdl

ECHO_WITH_ESC = printf

$(VHDLCONFIG): $(TOPDIR)/.config $(SRC)/vhdlconfig.mk
	$(ECHO_WITH_ESC) '$(subst $(nl),\n,${CONFIGURATION-y})' > $@

