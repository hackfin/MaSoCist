# GHDL synthesis workflow
#
#

GHDL_GENERICS = 

include $(TOPDIR)/vendor/default/local_config.mk
-include $(FPGA_VENDOR)/$(PLATFORM)/config.mk

LIBGHDL = /src/lib-devel/synlib

GHDL_LIBFLAGS = -P$(LIBGHDL)/lattice/$(FPGA_ARCH)
# GHDL_LIBFLAGS += -P$(LIBGHDL)
# GHDL_LIBFLAGS += -P$(WORKDIR)

CURDIR = $(shell pwd)

MASOCIST_ABSOLUTE_DIR = $(CURDIR)/..
GHDL_LIB_ABSOLUTE_DIR = $(HOME)/src/vhdl/lib-devel
GHDLEX_ABSOLUTE_DIR = $(HOME)/src/vhdl/ghdlex
# For some vendor specific components, we need a copy of the diamond libraries:
# and set VENDOR_LIBRARY_DIR in config.mk or local_config.mk
ifneq ($(VENDOR_LIBRARY_DIR),)
MOUNT_DIAMOND_COMPONENTS = -v $(VENDOR_LIBRARY_DIR):/src/diamond_lib
endif

DOCKERARGS = run --rm -v $(MASOCIST_ABSOLUTE_DIR):/src \
	-v $(GHDLEX_ABSOLUTE_DIR):/src/ghdlex \
	$(MOUNT_DIAMOND_COMPONENTS) \
	-v $(GHDL_LIB_ABSOLUTE_DIR):/src/lib-devel -w /src/syn


GHDL      = $(DOCKER) $(DOCKERARGS) ghdl/synth:beta ghdl
NEXTPNR   = $(DOCKER) $(DOCKERARGS) ghdl/synth:nextpnr-ecp5 nextpnr-ecp5
ECPPACK   = $(DOCKER) $(DOCKERARGS) ghdl/synth:trellis ecppack
OPENOCD   = $(DOCKER) $(DOCKERARGS) \
	--device /dev/bus/usb ghdl/synth:prog openocd

GHDLSYNTH = ghdl

include $(TOPDIR)/ghdl.mk

DOCKER=docker

VHDL_STD = 93c

YOSYS     = $(DOCKER) $(DOCKERARGS) ghdl/synth:beta yosys

LIB_CREATE     = $(DOCKER) $(DOCKERARGS) ghdl/synth:beta \
	make -C /src/lib-devel VHDL_STD=$(VHDL_STD) SYNTHESIS=yes \
	LATTICE_DIR=/src/diamond_lib

# If we can, let's avoid this:
#GHDL_FLAGS += --ieee=synopsys

GHDL_FLAGS += --warn-no-binding --warn-no-error
GHDL_FLAGS += --warn-no-delayed-checks

TOPLEVEL = $(PLATFORM)_top
EXTENSION = -$(subst $\",,$(CONFIG_PLAT_EXTENSION))

LOGFILE_YS = lattice/$(PLATFORM)/report_yosys.txt
LOGFILE_PNR = lattice/$(PLATFORM)/report_pnr.txt

LPF = lattice/$(PLATFORM)/$(PLATFORM)$(EXTENSION).lpf

ifneq ($(VERILOG_BB_WRAPPERS-y),)
READ_BB_WRAPPERS = read_verilog $(VERILOG_BB_WRAPPERS-y);
endif

SYN_ARGS = ghdl --std=$(VHDL_STD) $(GHDL_GENERICS) \
	$(GHDL_LIBFLAGS) $(GHDL_FLAGS) $(PROJECTFILES) -e $(TOPLEVEL); \
	$(READ_BB_WRAPPERS) \
	synth_ecp5 -top $(TOPLEVEL)_0 -json

$(PLATFORM).json: $(PROJECTFILES)
	$(YOSYS) -m $(GHDLSYNTH) -p "$(SYN_ARGS) $@" 2>&1 | tee $(LOGFILE_YS)

$(PLATFORM).config: $(PLATFORM).json $(LPF)
	$(NEXTPNR) --json $< --lpf $(LPF) --textcfg $@ $(NEXTPNR_FLAGS) \
	--lpf-allow-unconstrained \
	--package $(PACKAGE)  2>&1 | tee $(LOGFILE_PNR)

$(PLATFORM).bit: $(PLATFORM).config
	$(ECPPACK) --svf $(PLATFORM).svf $< $@


OPENOCD_JTAG_CONFIG = $(FPGA_VENDOR)/$(PLATFORM)/openocd.cfg
OPENOCD_DEVICE_CONFIG = $(FPGA_VENDOR)/openocd/$(FPGA_SPEC).cfg

download: $(PLATFORM).svf
	$(OPENOCD) -f $(OPENOCD_JTAG_CONFIG) -f $(OPENOCD_DEVICE_CONFIG) \
	-c "transport select jtag; init; svf $<; exit"


synlib:
	$(LIB_CREATE) GHDL_TARGET_DIR=synlib


.PHONY: synlib

bitfile: $(PLATFORM).config


