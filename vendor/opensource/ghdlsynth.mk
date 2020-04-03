# GHDL synthesis workflow
#
#

GHDL_GENERICS = 

include $(TOPDIR)/vendor/default/local_config.mk
-include $(FPGA_VENDOR)/$(PLATFORM)/config.mk

# SRCPREFIX = $(HOME)/src/vhdl
ifeq ($(shell whoami),masocist)
include masocist.mk
else
# Possible local overwrite settings:
-include local.mk
include docker.mk
endif

GHDL_LIBFLAGS = -P$(LIBGHDL)/lattice/$(FPGA_ARCH)
GHDL_LIBFLAGS += -P$(WORKDIR)
# GHDL_LIBFLAGS += -P$(LIBGHDL)

GHDLSYNTH = ghdl

include $(TOPDIR)/ghdl.mk

VHDL_STD = 08

# If we can, let's avoid this:
#GHDL_FLAGS += --ieee=synopsys

GHDL_FLAGS += --warn-no-binding --warn-no-error
GHDL_FLAGS += --warn-no-delayed-checks

TOPLEVEL = $(PLATFORM)_top
EXTENSION = -$(subst $\",,$(CONFIG_PLAT_EXTENSION))

LOGFILE_YS = lattice/$(PLATFORM)/report_yosys.txt
LOGFILE_PNR = lattice/$(PLATFORM)/report_pnr.txt

LPF = lattice/$(PLATFORM)/$(PLATFORM)$(EXTENSION).lpf

# EMULATE_FIFO = y
TAP_GLUE_BB = lattice/lattice_tap_glue.il

VERILOG_BB_WRAPPERS-$(EMULATE_FIFO) += fifo.v

ifdef ENABLE_TAP_BB
READ_NETLIST = read_ilang $(TAP_GLUE_BB); 
endif

ifneq ($(VERILOG_BB_WRAPPERS-y),)
READ_BB_WRAPPERS = read_verilog $(VERILOG_BB_WRAPPERS-y); 
endif

SYN_ARGS = \
	ghdl --std=$(VHDL_STD) $(GHDL_GENERICS) \
	$(GHDL_LIBFLAGS) $(GHDL_FLAGS) $^ -e $(TOPLEVEL); \
	$(READ_NETLIST) \
	$(READ_BB_WRAPPERS) \
	synth_ecp5 -top $(TOPLEVEL) -json

$(PLATFORM).json: $(PROJECTFILES)
	$(YOSYS) -m $(GHDLSYNTH) -p "$(SYN_ARGS) $@" 2>&1 | tee $(LOGFILE_YS)

$(PLATFORM).config: $(PLATFORM).json $(LPF)
	$(NEXTPNR) --json $< --lpf $(LPF) --textcfg $@ $(NEXTPNR_FLAGS) \
	--lpf-allow-unconstrained \
	--package $(PACKAGE)  2>&1 | tee $(LOGFILE_PNR)


# Build SVF file with specific JTAG usercode
$(PLATFORM).svf: $(PLATFORM).config
	$(ECPPACK) --usercode $(TAP_USERCODE_INTEGER)  \
		--input $< --svf $@ \
	

OPENOCD_JTAG_CONFIG = $(FPGA_VENDOR)/$(PLATFORM)/openocd.cfg
OPENOCD_DEVICE_CONFIG = $(FPGA_VENDOR)/openocd/$(FPGA_SPEC).cfg

download: $(PLATFORM).svf
	$(OPENOCD) -f $(OPENOCD_JTAG_CONFIG) -f $(OPENOCD_DEVICE_CONFIG) \
	-c "transport select jtag; init; svf $<; exit"


-include lattice/fifotest.mk
-include lattice/tapglue.mk

%.v: %.blif
	$(YOSYS) -p 'read_blif -wideports $<; write_verilog $@'

help:
	$(NEXTPNR) --help

yosys:
	$(YOSYS_INTERACTIVE)

synlib:
	$(LIB_CREATE) GHDL_TARGET_DIR=synlib  VHDL_STD=$(VHDL_STD)

.PHONY: synlib

bitfile: $(PLATFORM).config


