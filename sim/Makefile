# Makefile to build ZPUSoC for various platforms

# See config file for possible configuration variables:
include ../config.mk
include $(TOPDIR)/vendor/$(VENDOR)/local_config.mk

ifdef MINGW32
LIBSLAVE = $(NETPP)/devices/libslave
LIBEXTRA_FLAGS = -Wl,-lws2_32
SIM_TOP_EXE = $(SIM_TOP).exe
else
LIBEXTRA_FLAGS = -Wl,-lpthread
SIM_TOP_EXE = $(SIM_TOP)
ifdef NETPP
LIBSLAVE = $(NETPP)/devices/libslave
else
MACHINE = $(shell uname -m)
ifeq ($(MACHINE),x86_64)
LOCAL_LIBS = ../contrib
else
LOCAL_LIBS = ../contrib/lib32
endif
LIBSLAVE = $(LOCAL_LIBS)
endif
endif


SIM_TOP ?= tb_$(PLATFORM)

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
	# $(MAKE) -C perio
	cd $@ && make all

.PHONY: all reconfig generate perio

COMMON_BUILD_RULES = yes   # Use common rules
include $(SRC)/project.mk

SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_slave_emu.vhdl
SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_slave.vhd
SIM_SRCFILES-$(CONFIG_VIRTUAL_I2CSLAVE) += hdl/i2c/i2c_syn_pkg.vhd

# Include Test bench and simulation specific files:
PROJECTFILES += $(TOPDIR)/sim/$(SIM_TOP).vhdl $(SIM_SRCFILES-y)

VIRTUAL_EXTENSIONS-$(CONFIG_NATIVE) += hdl/virtualuart.vhdl
VIRTUAL_EXTENSIONS-$(CONFIG_MINGW32) += hdl/dummy-virtualuart.vhdl

PROJECTFILES += $(VIRTUAL_EXTENSIONS-y)

debug:
	@echo "MINGW support: $(CONFIG_MINGW32)"
	@echo "ghdl binary: $(GHDL)" `$(GHDL) --version`
	@echo "ghdlex target: $(GHDLTARGET)"
	@echo "ghdlex dir: $(GHDLEX)"
	@echo "VHDL lib dir: $(LIBGHDL)"

show-duties:
	@echo Files to generate:
	@echo ROM file: $(ROMFILE)
	@echo $(MY_DUTIES)
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
GHDL_LIBFLAGS += -P$(LIBGHDL)/lattice/$(FPGA_ARCH)
GHDL_LIBFLAGS += -P$(LIBGHDL)/xilinx/unisim
GHDL_LIBFLAGS += -P$(LIBGHDL)/fmf
GHDL_LIBFLAGS += -P$(LIBGHDL)/
GHDL_LIBFLAGS += -P$(WORKDIR)
endif

ifdef MINGW32
BUILD_SIMLIB_OPTIONS ?= CC=$(CROSS_CC) PLATFORM=mingw32
LIBEXT = .a
else
BUILD_SIMLIB_OPTIONS ?= all-libsim
LIBEXT = .so
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
MY_DUTIES += $(LIBSIM)
endif

ifdef REQUIRE_LIBSLAVE
GHDL_LDFLAGS += -Wl,-L$(LIBSLAVE_DIR) -Wl,-lslave $(LIBEXTRA_FLAGS)
endif

$(LIBSIM):
	$(MAKE) -f libsim.mk LIBSIM=lib$(SIM_LIBNAME) $(BUILD_SIMLIB_OPTIONS) \
	GHDLEX=$(GHDLEX) show-duties


ghw: $(SIM_TOP)
	 ./$(SIM_TOP) --wave=/tmp/test.ghw --stop-time=3200us 2>run.log
	 # ./$(SIM_TOP) --vcd=/tmp/test.vcd --stop-time=6200us 2>run.log

SAV_EXT = $(EXTENSION)$(TEST_EXTENSION)

run: $(SIM_TOP)
	./run.sh $(PLATFORM) $(SAV_EXT)

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
	$(MAKE) -.. sim defconfig

clean::
	-$(MAKE) -f libsim.mk clean
	$(MAKE) -C ../sw clean
	-rm -fr $(CLEANUP_DUTIES)
	# $(MAKE) -C .. oldconfig silentoldconfig
