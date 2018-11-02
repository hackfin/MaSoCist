ifdef CONFIG_ZEALOT
ZEALOT = $(SRC)/zpu/zealot
include $(SRC)/core/zpu.mk
endif

ifdef CONFIG_ZPUNG
ZEALOT = $(SRC)/zpu/zealot
ZPUNG = $(SRC)/zpu/zpung
include $(SRC)/core/zpu.mk
endif

ifdef CONFIG_NEO430
NEO430 = $(SRC)/neo430
endif

ifdef CONFIG_UART
REQUIRE_FIFOBUF = y
endif

ifdef CONFIG_JPEG
include $(SRC)/core/jpeg/Makefile
REQUIRE_DSPALU = y
REQUIRE_FIFOBUF = y
endif

ifdef REQUIRE_DSPALU
include $(SRC)/core/dsp/Makefile
endif

SRCFILES-$(REQUIRE_FIFOBUF) += core/fifobuf.vhdl

SRCFILES-$(CONFIG_ZEALOT) += zputap_cfg.vhdl
SRCFILES-$(CONFIG_JPEG) += $(JPEG_CORE_FILES:%=core/jpeg/%)
# SRCFILES-$(CONFIG_ZPUNG)  += zputap_cfg.vhdl

SOC_MODULE-$(CONFIG_ZPUNGV2) = = $(SRC)/zpu/zpungv2.chdl
SOC_MODULE-$(CONFIG_ZPUNG) = $(SRC)/zpu/zpu_soc.chdl

SOC_MODULE-$(CONFIG_ZEALOT) = $(SRC)/zpu/zpu_soc.chdl

SOC_MODULE-$(CONFIG_NEO430) = $(SRC)/neo430/neo430_soc.chdl
SOC_MODULE-$(CONFIG_NEO430_NATIVE) = $(SRC)/neo430/neo430_soc_native.chdl

# Wishbone bridge:
SRCFILES-$(CONFIG_ZPUNG)  += core/wb2zpu.vhdl
SRCFILES-$(CONFIG_ZEALOT) += core/wb2zpu.vhdl
SRCFILES-$(CONFIG_NEO430) += core/wb2zpu.vhdl

# The PyPS core (evaluation)
ifndef HAVE_PYPS_LICENSE
SOC_MODULE-$(CONFIG_PYPS) = $(SRC)/mips/pyps_soc.chdl
SOC_MODULE-$(CONFIG_PYPS) += $(SRC)/core/memory2clk.chdl
SRCFILES-$(CONFIG_PYPS) += mips/pyps/mycpu.vhd
endif

ifdef HAVE_MYHDL
GENERATED_FILES-y += $(SRC)/core/flagx.vhd
GENERATED_FILES-y += $(SRC)/core/flagxdn.vhd
GENERATED_FILES-y += $(SRC)/core/flagxdp.vhd
GENERATED_FILES-y += $(SRC)/core/sync.vhd
else
SRCFILES-y += core/flagxdp.vhd
endif

# The myhdl package must be included once somewhere:
SRCFILES-y += core/pck_myhdl_09.vhd

GENERATED_FILES-y += $(SOC_MODULE-y:%.chdl=%.vhdl)

# Library files:
SYN_LIBFILES-$(CONFIG_ZEALOT) += $(ZPU_VHDL)

CUSTOM_DUTIES-$(CONFIG_ZEALOT) += $(ZEALOT)
CUSTOM_DUTIES-$(CONFIG_ZEALOT) += $(WORKDIR)/zpu-obj$(VHDL_STD_SUFFIX).cf
 
# SoC still depends on original Zealot stuff for both options
CUSTOM_DUTIES-$(CONFIG_ZPUNG) += $(ZEALOT)
SYN_LIBFILES-$(CONFIG_ZPUNG) += $(ZPU_VHDL)
CUSTOM_DUTIES-$(CONFIG_ZPUNG) += $(WORKDIR)/zpu-obj$(VHDL_STD_SUFFIX).cf


DISTFILES += $(SOC_MODULE)
