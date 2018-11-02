# All rules for VHDL file generation:
#

# XML configuration (filtered device description)
include $(SRC)/devdesc_config.mk

include $(TOPDIR)/gensoc.mk

GENERATED_FILES-y += $(SOC_FILES) $(BUS_FILES) $(ROMFILE)
ifeq ($(HAVE_PLATFORM_DESCRIPTION),yes)
GENERATED_FILES-y += $(PLAT_FILE)
endif

GENERATED_FILES-$(HAVE_MYHDL) += $(SRC)/core/flagx.vhd

# VHDL configuration files:
include $(SRC)/vhdlconfig.mk
GENERATED_FILES-y += $(VHDLCONFIG)

# Generate VHDL from CHDL:
%.vhdl : %.chdl $(TOPDIR)/.config
	cpp -w -P -o $@ -D__VHDL__ $(CHDL_FLAGS) -I$(TOPDIR)/hdl $<

# Rule to build vhd from myhdl py file
$(SRC)/%.vhd: $(SRC)/%.py
	cd `dirname $<`; python `basename $<`

ifeq ($(SYNTHESIS),yes)
IS_SIM =
else
IS_SIM = SIMULATION=yes
endif

$(ROMFILE):
	@echo Build ROM for platform: $(PLATFORM)
	make -C ../sw all $(IS_SIM) PLATFORM=$(PLATFORM) \
	ROMFILE=$(ROMFILE)

.PHONY: $(ROMFILE)

