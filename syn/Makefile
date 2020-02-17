# Auxiliary Makefile for synthesis

include ../config.mk

# These need to be defined for some 'common duties'

GENSOC_OUTPUT       = ../gen/syn-$(PLATFORM)
SYNDIR              ?= .

all: $(PREPARE_PLATFORM) run-synthesis

../gen:
	mkdir $@

$(GENSOC_OUTPUT): | ../gen
	mkdir $@

ifdef GENSOC
CLEANUP_DUTIES = $(MY_DUTIES)
endif

clean::
	rm -fr $(CLEANUP_DUTIES)
	rm -fr $(SYN_SCRIPTS)
	$(MAKE) -C ../sw clean

ifdef CONFIG_GHDL_SYNTH
CHDL_FLAGS += -DSYNTHESIS_GHDL
endif

SYNTHESIS = yes
COMMON_BUILD_RULES = yes   # Use common rules
include $(SRC)/project.mk

generate: $(GENSOC_OUTPUT) $(MY_DUTIES) $(WATCH_DUTIES-y) $(PROJECTFILES)

show-duties:
	@echo =========================================
	@echo PLATFORM: $(PLATFORM) VENDOR : $(VENDOR)
	@echo =========================================
	@echo
	@echo ROMFILE: $(ROMFILE)
	@echo PROJECTFILES: $(PROJECTFILES)
	@echo LIBRARYFILES: $(SYN_LIBFILES-y)
	@echo TCL SCRIPTS: $(SYN_SCRIPTS)

sanity-check:
	@ls -l $(PROJECTFILES) > /dev/null

# Generation of TCL scripts for convenient file import:

ifeq ($(FPGA_VENDOR),lattice)
ifndef CONFIG_GHDL_SYNTH
PROJECT_PREFIX = ../../
SYN_SCRIPTS = $(SYNDIR)/lattice/proj_$(PLATFORM).tcl
SYN_SCRIPTS += $(SYNDIR)/lattice/lib_zpu.tcl
SYN_SCRIPTS += $(SYNDIR)/lattice/proj_syn_$(PLATFORM).tcl
include $(SYNDIR)/synopsys/synplify_proj.mk
include $(SYNDIR)/lattice/diamond_proj.mk
endif
endif

ifeq ($(FPGA_VENDOR),xilinx)
PROJECT_PREFIX = ../../../
SYN_SCRIPTS = $(SYNDIR)/xilinx/proj_$(PLATFORM).tcl
include $(SYNDIR)/xilinx/ise_proj.mk
endif

ifeq ($(IP_VENDOR),cadence)
PROJECT_PREFIX = ../../../
endif

MY_DUTIES = $(GENSOC_OUTPUT) $(GENERATED_FILES-y) 
MY_DUTIES += $(CUSTOM_DUTIES-y)

############################################################################
# Synthesis options:

SYN_DUTIES = $(MY_DUTIES)

ifdef CONFIG_GHDL_SYNTH
include $(TOPDIR)/vendor/$(VENDOR)/ghdlsynth.mk
SYN_DUTIES += synlib $(PLATFORM).svf
else
SYN_DUTIES += syntcl
endif


run-synthesis: $(SYN_DUTIES)

syntcl: $(MY_DUTIES) sanity-check $(SYN_SCRIPTS)

debug:
	@echo $(MY_DUTIES)
	@echo $(ROMFILE)

