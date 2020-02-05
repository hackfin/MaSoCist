# Makefile to generate SoC VHDL code
#
# (c) 2013-2014 <hackfin@section5.ch>
#

# GENSOC ?= gensoc

SPACE = $(null) $(null)
COMMA = ,
# Create comma separated list:
GENSOC_DECODER_LIST=$(subst $(SPACE),$(COMMA),$(GENSOC_DECODERS))

DATA_WIDTH ?= 32

GENSOC_OPTIONS = --data-width=$(DATA_WIDTH)
GENSOC_OPTIONS += -o $(GENSOC_PREFIX) --interface-type=unsigned
GENSOC_OPTIONS += -sm

# Cordula backwards namespace compatibility:

ifdef CONFIG_MAP_PREFIX
GENSOC_OPTIONS += --map-prefix=2
else
GENSOC_OPTIONS += --map-prefix=1
endif


# Only for simulation:
ifndef SYNTHESIS
ifdef CONFIG_SIM_BUS_ERROR
GENSOC_OPTIONS += --errlevel=failure
else
GENSOC_OPTIONS += --errlevel=warning
endif
endif

ifdef CONFIG_GENSOC_READ_DELAY
GENSOC_OPTIONS += --use-read-delay
endif

ifdef CONFIG_GENSOC_RESET_DEFAULTS
GENSOC_OPTIONS += --use-reset
endif


# Choose decoder entities to build:
GENSOC_OPTIONS += --decoder=$(GENSOC_DECODER_LIST)

BUS_FILES = $(GENSOC_PREFIX)_bus_iomap_pkg.vhdl

SOC_FILES = $(GENSOC_DECODERS:%=$(GENSOC_PREFIX)_%_decode.vhdl)
SOC_FILES += $(GENSOC_PREFIX)_iomap_pkg.vhdl
SOC_FILES += $(GENSOC_PREFIX)_mmr_perio.vhdl
PLAT_FILE = $(GENSOC_PREFIX)_$(PLATFORM)_iomap_pkg.vhdl


ifdef GENSOC

$(SOC_FILES): $(DEVICEFILE_TARGET)
	$(GENSOC) $(GENSOC_OPTIONS) $(DEVICEFILE_TARGET)

ifeq ($(DATA_WIDTH),16)
BUSDESC = $(TOPDIR)/bus16.xml
else
BUSDESC = $(TOPDIR)/bus.xml
endif

$(BUS_FILES): $(BUSDESC)
	$(GENSOC) -o $(GENSOC_PREFIX)_bus --interface-type=unsigned -s $<

$(PLAT_FILE): $(SRC)/plat/plat_$(PLATFORM).xml
	$(GENSOC) -o $(GENSOC_PREFIX)_$(PLATFORM) --interface-type=unsigned -s $<

endif

socfiles:
	@echo Building for $(PLATFORM)
	@echo Device file: $(DEVICEFILE_TARGET)
	@echo "Modules to generate:"
	@echo $(GENSOC_DECODER_LIST)

.PHONY: socfiles
