# All rules for VHDL file generation:
#

# XML configuration (filtered device description)
include $(SRC)/devdesc_config.mk

include $(TOPDIR)/gensoc.mk

GENERATED_FILES-y += $(VHDLCONFIG)
GENERATED_FILES-y += $(BUS_FILES) $(SOC_FILES) $(ROMFILE)
ifeq ($(HAVE_PLATFORM_DESCRIPTION),yes)
GENERATED_FILES-y += $(PLAT_FILE)
endif

GENERATED_FILES-$(HAVE_MYHDL) += $(SRC)/core/flagx.vhd

# VHDL configuration files:
include $(SRC)/vhdlconfig.mk

# Generate VHDL from CHDL:
%.vhdl : %.chdl $(TOPDIR)/.config
	cpp -w -P -o $@ -D__VHDL__ $(CHDL_FLAGS) -I$(TOPDIR)/hdl $<

# Rule to build vhd from myhdl py file
$(SRC)/%.vhd: $(SRC)/%.py
	cd `dirname $<`; $(PYTHON_MYHDL) `basename $<`

ifeq ($(SYNTHESIS),yes)
IS_SIM =
else
IS_SIM = SIMULATION=yes
endif

SOFTWARE ?= ../sw

$(ROMFILE):
	@echo Build ROM for platform: $(PLATFORM)
	make -C $(SOFTWARE) all USE_CACHE=n $(IS_SIM) PLATFORM=$(PLATFORM) \
	ROMFILE=$(ROMFILE)

.PHONY: $(ROMFILE)

