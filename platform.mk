# Custom platform make file

# DEPRECATED: No more adding of platforms. Use vendor/<VENDOR>/config.mk
# (likewise for software: sw/plat/<PLATFORM>/config.mk

VERSION = 0.2

############################################################################
# Public SOC descriptions: (vendor specific ones go to <VENDOR>/config.mk)
ifeq ($(CONFIG_SOCDESC),"agathe")
CHDL_FLAGS = -DHAVE_DBGCOUNT -DHAVE_DIPSWITCH
DOC_MMR_BASE = 0xf8000
endif

############################################################################
# Default supported platforms

# Netpp node board:
# https://section5.ch/index.php/product/netpp-node-v0-1/
#

ifdef CONFIG_netpp_node
HAVE_PLATFORM_DESCRIPTION = yes
FPGA_VENDOR = xilinx
PACKAGE  = TQFP144
PLATFORM = netpp_node
FPGA_ARCH = spartan6
endif

# Simple virtual board:

ifdef CONFIG_virtual
	PLATFORM = virtual
	DEVICENAME = virtual
	# Abuse ecp3 for virtual architecture:
	FPGA_ARCH = ecp3
endif

# Generic tap configuration
include $(TOPDIR)/tapconfig.mk
TAP_ID = $(subst $\",,$(CONFIG_TAP_ID)) 
MAPFILE = $(PLATFORM).map


ifdef CONFIG_ZEALOT
ARCH = zpu
# We use big endian config for now. Little endian not properly supported.
# PLATFORM_CFLAGS = -mno-bytesbig

PLATFORM_CFLAGS += -mno-callpcrel # Use this when changing the BRAM program and
                         # calling stuff from cached ROM

PLATFORM_CFLAGS += -mno-poppcrel

endif

ifdef CONFIG_NEO430
ARCH = msp430
HAVE_CRT0 = y
DATA_WIDTH = 16
BINFMT = -
endif

ifdef CONFIG_RISCV_POTATO
ARCH = riscv
endif

ifdef CONFIG_ZPUNG
ARCH = zpu

ifdef CONFIG_FULL_REENTRANCY
# Important when calling some routines from IRQ handlers:
PLATFORM_CFLAGS += -mno-memreg
endif
endif

ifeq ($(ARCH),zpu)
	# We use big endian config for now. Little endian not properly supported.
	# PLATFORM_CFLAGS = -mno-bytesbig
	ifdef BSPNAME
	CUSTOM_LINKERSCRIPT ?= ldscripts/$(PLATFORM)-$(BSPNAME).ld
	else
	CUSTOM_LINKERSCRIPT ?= ldscripts/$(PLATFORM)-baremetal.ld
	endif

	LDFLAGS = -Wl,--relax -Wl,--gc-sections -Wl,-Map -Wl,$(MAPFILE)
	LDFLAGS += -Wl,-T -Wl,$(CUSTOM_LINKERSCRIPT) -nostdlib -lgcc
	LDFLAGS += -Wl,--defsym -Wl,ZPU_ID=0x$(TAP_ID)
endif

ifeq ($(ARCH),riscv)
	CUSTOM_LINKERSCRIPT = ldscripts/riscv/potato_linker_script.x
	LDFLAGS += -Wl,-T -Wl,$(CUSTOM_LINKERSCRIPT) -nostdlib -lgcc
	LDFLAGS += -Wl,-Map -Wl,$(MAPFILE)
	ASMFLAGS = -x assembler-with-cpp
endif

ifeq ($(ARCH),msp430)
	DUTIES-y += crt0.elf
	CUSTOM_LINKERSCRIPT = ldscripts/neo430/neo430_linker_script.x
	LDFLAGS += -Wl,-T -Wl,$(CUSTOM_LINKERSCRIPT) -nostdlib -lgcc
	LDFLAGS += -Wl,-Map -Wl,$(MAPFILE)
endif


ifdef CONFIG_PYPS
ARCH = mips
LINKERSCRIPT = pyps_default.x
DUTIES-y += $(LINKERSCRIPT)
OBJS-y += crt0.o
PLATFORM_CFLAGS += -mips1
LDFLAGS = -T$(LINKERSCRIPT)
LDFLAGS += -Map $(MAPFILE)
ROM_DATA_TABLES = $(ARCH)_dram_a.tmp $(ARCH)_dram_b.tmp
ROM_DATA_TABLES += $(ARCH)_iram_h.tmp $(ARCH)_iram_l.tmp
endif

ROM_DATA_TABLES ?= $(ARCH)_data.tmp

# If we have no platform definition, determine arch from config
ifndef PLATFORM

ifdef CONFIG_MACHXO2
	FPGA_ARCH = machxo2
endif
ifdef CONFIG_MACHXO3
	FPGA_ARCH = machxo3
endif
ifdef CONFIG_ECP3
	FPGA_ARCH = ecp3
endif
ifdef CONFIG_ECP5
	FPGA_ARCH = ecp5
endif
ifdef CONFIG_SPARTAN3
	FPGA_ARCH = sp3
endif
ifdef CONFIG_SPARTAN6
	FPGA_ARCH = sp6
endif


endif


PLATFORM ?= unknown
ARCH ?= UNKNOWN
BINFMT ?= -elf-

CROSS_COMPILE ?= $(ARCH)$(BINFMT)
