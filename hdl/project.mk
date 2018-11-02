# Project files Makefile
#
# (c) 2015, Martin Strubel <hackfin@section5.ch>
#
#
# Just collects all source files, also generated

# Since simulation and synthesis are different projects, there is a
# SYNTHESIS switch to generate different targets.

# The generated ROM memory:
ifndef CONFIG_NETPP_CPU
ROMFILE = $(GENSOC_OUTPUT)/rom_generated.vhd
endif

############################################################################

# SRCFILES = triggerpulse.vhd libprimitives.vhd

# SRCFILES += dpram_wrapper.vhdl
# i2c slave simulation_

# Obsolete, manually written peripheral maps:
# SRCFILES-$(CONFIG_LOCALBUS) += soc_periomap.vhdl
# SRCFILES-$(CONFIG_WISHBONE) += perio_wb.vhdl

# Add configuration specific sources to SRCFILES:

############################################################################
# Platform specific:

PLAT_SRCFILES-y =  $(PLATFORM)_top.vhdl

# Architecture specific IP core supply:

# Generated IP core:
SYN_SRCFILES-$(CONFIG_xo2starter)  +=  lattice/ipcores/$(PLATFORM)/machxo2_pll.vhd

SYN_SRCFILES-$(CONFIG_xo3starter)  +=  lattice/ipcores/$(PLATFORM)/machxo3_pll.vhd

# netpp node specific:
ifdef CONFIG_netpp_node
ifdef CONFIG_EMULATE_PLATFORM_IP
# Use emulation for SPI clock divider
PERIO-$(CONFIG_SPI) += clkdiv.vhdl
PERIO-$(CONFIG_SPI) += clkdrv.vhdl
else
PLAT_SRCFILES-$(CONFIG_SPI) +=  ipcores/netpp_node/sp6_clkdiv.vhdl
PLAT_SRCFILES-$(CONFIG_SPI) +=  ipcores/netpp_node/sp6_clkdrv.vhdl
endif

PLAT_SRCFILES-y +=  ipcores/netpp_node/sp6_reset.vhdl
endif

# Simulation entities of the platform specifics:
ifndef SYNTHESIS

ifdef CONFIG_EMULATE_PLATFORM_IP
PLAT_SRCFILES-y += emulate_$(PLATFORM).vhdl
PLAT_SRCFILES-$(CONFIG_netpp_node) +=  ipcores/netpp_node/pll_mclk.vhd
else
PLAT_SRCFILES-$(CONFIG_xo3starter) +=  ipcores/xo3starter/machxo3_pll.vhd
PLAT_SRCFILES-$(CONFIG_xo2starter) +=  ipcores/xo2starter/machxo2_pll.vhd
# PLAT_SRCFILES-$(CONFIG_xo2starter) +=  ipcores/xo2starter/efb.vhd
endif

endif

############################################################################

PROJECTFILES += $(MYHDL_SRCFILES:%=$(SRC)/gen/%)

PROJECTFILES += $(PLAT_SRCFILES-y:%=$(SRC)/plat/%)
# Add to watch duties, as platform files may have to be generated:
# Watch duties are NOT removed during a 'clean'!
WATCH_DUTIES-y = $(PLAT_SRCFILES-y:%=$(SRC)/plat/%)

ifdef SYNTHESIS
PROJECTFILES += $(SYN_SRCFILES-y:%=$(TOPDIR)/syn/%)
endif

SYN_LIBFILES-y = 

ifdef COMMON_BUILD_RULES
-include $(TOPDIR)/vendor/$(VENDOR)/Makefile
endif
include $(SRC)/core/Makefile
include $(SRC)/ram/Makefile
include $(SRC)/perio/Makefile
include $(SRC)/tap/Makefile
include $(SRC)/plat/Makefile

SRCFILES += $(SRCFILES-y)

PROJECTFILES += $(SRCFILES:%=$(SRC)/%)

# These files (SOC_SRCFILES) are section5 proprietary and must
# not be distributed:
PROJECTFILES += $(SOC_SRCFILES-y:%=$(SRC)/tap/%)

# Perio sources:
PROJECTFILES += $(PERIO-y:%=$(SRC)/perio/%)

# Parameters to gensoc (included from generate.mk):
GENSOC_DECODERS     = sys $(GENSOC_MODULES-y)
GENSOC_PREFIX       = $(GENSOC_OUTPUT)/soc

include $(TOPDIR)/generate.mk

PROJECTFILES += $(GENERATED_FILES-y)
PROJECTFILES += $(SRC)/periotypes_pkg.vhdl

