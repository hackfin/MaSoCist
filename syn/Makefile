# Auxiliary Makefile for synthesis

include ../config.mk
include $(TOPDIR)/vendor/$(VENDOR)/config.mk

GENSOC_OUTPUT       = ../gen/syn-$(PLATFORM)
SYNDIR              ?= .

all: syntcl

$(GENSOC_OUTPUT):
	mkdir $@

ifdef GENSOC
CLEANUP_DUTIES = $(MY_DUTIES)
endif

clean::
	rm -fr $(CLEANUP_DUTIES)
	rm -fr $(SYN_SCRIPTS)

SYNTHESIS = yes
COMMON_BUILD_RULES = yes   # Use common rules
include $(SRC)/project.mk

show-duties:
	@echo =========================================
	@echo PLATFORM: $(PLATFORM) VENDOR : $(VENDOR)
	@echo =========================================
	@echo
	@echo PROJECTFILES: $(PROJECTFILES)
	@echo LIBRARYFILES: $(SYN_LIBFILES-y)
	@echo TCL SCRIPTS: $(SYN_SCRIPTS)

sanity-check:
	@ls -l $(PROJECTFILES) > /dev/null

# Generation of TCL scripts for convenient file import:

ifeq ($(FPGA_VENDOR),lattice)
PROJECT_PREFIX = ../../
SYN_SCRIPTS = $(SYNDIR)/lattice/proj_$(PLATFORM).tcl
SYN_SCRIPTS += $(SYNDIR)/lattice/lib_zpu.tcl
include $(SYNDIR)/lattice/diamond_proj.mk
endif

ifeq ($(FPGA_VENDOR),xilinx)
PROJECT_PREFIX = ../../../
SYN_SCRIPTS = $(SYNDIR)/xilinx/proj_$(PLATFORM).tcl
include $(SYNDIR)/xilinx/ise_proj.mk
endif

MY_DUTIES = $(GENERATED_FILES-y) 
MY_DUTIES += $(CUSTOM_DUTIES-y)

syntcl: $(GENSOC_OUTPUT) $(MY_DUTIES) sanity-check $(SYN_SCRIPTS)

