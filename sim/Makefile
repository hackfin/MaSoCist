# Makefile to build ZPUSoC for various platforms

# See config file for possible configuration variables:
include ../config.mk
include $(TOPDIR)/vendor/$(VENDOR)/local_config.mk


ifdef REQUIRE_LIBSLAVE
SIM_PREFIX = net_
else
SIM_PREFIX = tb_
endif

SIM_TOP ?= $(PLATFORM)


SIM_LIBNAME = $(subst $\",,$(CONFIG_LIBSIM))

GENSOC_OUTPUT       = ../gen

# Make sure this one gets generated, when needed:
GHDL_IMPORT_DEPENDENCIES = tb_$(PLATFORM).vhdl

ifdef CONFIG_NETPP_CPU
MAYBE_ALL = perio
else
MAYBE_ALL = $(PREPARE_PLATFORM) generate $(SIM_TOP_EXE)
endif

all: $(MAYBE_ALL)

$(GENSOC_OUTPUT):
	mkdir $@

perio: generate
	@echo "------------------------------------"
	@echo "No CPU, building perio simulation..."
	cd $@ && make all

.PHONY: all reconfig generate perio

COMMON_BUILD_RULES = yes   # Use common rules
include $(SRC)/project.mk

SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_slave_emu.vhdl
SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_slave.vhd
SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_syn_pkg.vhd

# Include Test bench and simulation specific files:
PROJECTFILES += $(TOPDIR)/sim/tb_$(SIM_TOP).vhdl $(SIM_SRCFILES-y)

ifdef CONFIG_NATIVE
VIRTUAL_EXTENSIONS-$(CONFIG_VIRTUAL_UART) += hdl/virtualuart.vhdl
else
VIRTUAL_EXTENSIONS-$(CONFIG_VIRTUAL_UART) += hdl/dummy-virtualuart.vhdl
endif

PROJECTFILES += $(VIRTUAL_EXTENSIONS-y)

debug:
	@echo "MINGW support: $(CONFIG_MINGW32)"
	@echo "ghdl binary: $(GHDL)" `$(GHDL) --version`
	@echo "ghdlex target: $(GHDLTARGET)"
	@echo "ghdlex dir: $(GHDLEX)"
	@echo "work dir: $(WORKDIR)"
	@echo "VHDL lib dir: $(LIBGHDL)"

show-duties:
	@echo Files to generate:
	@echo ROM file: $(ROMFILE)
	@echo $(MY_DUTIES)
	@echo Executable: $(SIM_TOP_EXE)
	@echo $(SOC_SRCFILES-y)

# Include these AFTER TCL rule:

$(GENSOC_OUTPUT)/i2c_i2c_slave_emu_decode.vhdl \
$(GENSOC_OUTPUT)/i2c_iomap_pkg.vhdl: $(SRC)/perio/i2cslave.xml
	$(GENSOC) -o $(GENSOC_OUTPUT)/i2c -s \
		--decoder=i2c_slave_emu --use-ack \
		--interface-type=unsigned \
		$<


GENERATED_FILES-$(CONFIG_VIRTUAL_I2CSLAVE) += \
	$(GENSOC_OUTPUT)/i2c_i2c_slave_emu_decode.vhdl \
	$(GENSOC_OUTPUT)/i2c_iomap_pkg.vhdl

GENERATED_FILES-y += $(GENERATED_SIMFILES)

GHDLEX_DIR = $(subst $\",,$(CONFIG_GHDLEX_PATH))
ifneq ($(GHDLEX_DIR),)
GHDLEX = $(GHDLEX_DIR)
else
ifdef MODULE_GHDLEX
GHDLEX = $(MODULE_GHDLEX)
endif
endif

# Extra stuff to do:

MY_DUTIES = $(GENERATED_FILES-y) 

MY_DUTIES += $(CUSTOM_DUTIES-y)


############################################################################
# GHDL Simulation stuff:

# Vendor stuff typically needs these flags:
ifdef CONFIG_USE_PLATFORM_IP_LIBRARY
GHDL_FLAGS = --ieee=synopsys -fexplicit --no-vital-checks
else
ifdef CONFIG_EMULATE_PLATFORM_IP
GHDL_FLAGS = --ieee=synopsys -fexplicit --no-vital-checks
endif
endif

include $(TOPDIR)/ghdl.mk

# Deprecated: no more vendor specific flags here. Move to
# vendor/$(VENDOR)/Makefile

ifdef CROSS
	LIBSLAVE_DIR ?= $(LIBSLAVE)/$(CROSS)-Debug
else
	# Make sure to link against a .so:
	LIBSLAVE_DIR ?= $(LIBSLAVE)
endif

ifdef LIBGHDL
ifeq (lattice,$(FPGA_VENDOR))
GHDL_LIBFLAGS += -P$(LIBGHDL)/lattice/$(FPGA_ARCH)
endif
ifeq (xilinx,$(FPGA_VENDOR))
GHDL_LIBFLAGS += -P$(LIBGHDL)/xilinx/unisim
endif
GHDL_LIBFLAGS += -P$(LIBGHDL)/fmf
GHDL_LIBFLAGS += -P$(LIBGHDL)/
GHDL_LIBFLAGS += -P$(WORKDIR)
endif

ifdef CONFIG_MINGW32
else
BUILD_SIMLIB_OPTIONS ?= all-libsim
endif

ifneq ($(SIM_LIBNAME),)
GHDL_LDFLAGS += -Wl,-l$(SIM_LIBNAME)
LIBSIM = lib$(SIM_LIBNAME)$(LIBEXT)
endif

ifdef GHDLEX
GHDL_LIBFLAGS += -P$(GHDLEX)/$(GHDLTARGET)
MY_DUTIES += $(WORKDIR)/ghdlex-obj$(VHDL_STD_SUFFIX).cf
endif

ifdef MODULE_TAPLIB
# Only build when not using default
ifndef CONFIG_GHDLEX_DEFAULT
MY_DUTIES += $(LIBSIM)
endif
endif

ifdef REQUIRE_LIBSLAVE
GHDL_LDFLAGS += -Wl,-L$(LIBSLAVE_DIR) -Wl,-lslave $(LIBEXTRA_FLAGS)
endif

$(LIBSIM):
	$(MAKE) -f libsim.mk LIBSIM=lib$(SIM_LIBNAME) $(BUILD_SIMLIB_OPTIONS) \
	GHDLEX=$(GHDLEX) show-duties all-libsim


ghw: $(SIM_TOP_EXE)
	 ./$< --wave=/tmp/test.ghw --stop-time=3200us 2>run.log
	 # ./$(SIM_TOP) --vcd=/tmp/test.vcd --stop-time=6200us 2>run.log

SAV_EXT = $(EXTENSION)$(TEST_EXTENSION)

run: $(SIM_TOP_EXE)
	./run.sh $(PLATFORM) $(SAV_EXT) "$(SIM_OPTIONS)" 

view:
	gtkwave /tmp/test.ghw view.sav


simdist:
	install -d $(DISTDIR)/sim
	install -m 644 $(PLATFORM)$(SAV_EXT).sav $(DISTDIR)/sim
	install -m 755 run.sh $(DISTDIR)/sim

reconfig:
	$(MAKE) -C .. oldconfig

generate: $(GENSOC_OUTPUT) $(MY_DUTIES) $(WATCH_DUTIES-y)

ifdef GENSOC
CLEANUP_DUTIES = $(MY_DUTIES)
endif

DIFF ?= diff

defconfig:
	$(MAKE) -C .. defconfig

clean::
	-$(MAKE) -f libsim.mk clean
	$(MAKE) -C ../sw clean
	-rm -fr $(CLEANUP_DUTIES)
	# $(MAKE) -C .. oldconfig silentoldconfig
