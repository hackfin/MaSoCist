# Makefile for TAP configuration
#

# VirtualTAP:

SOC_SRCFILES-y += libtap.vhdl

ifdef SYNTHESIS
SOC_SRCFILES-$(CONFIG_MACHXO3) += tap_machxo3.vhdl
SOC_SRCFILES-$(CONFIG_MACHXO2) += tap_machxo2.vhdl
SOC_SRCFILES-$(CONFIG_ECP3)    += tap_ecp3.vhdl
SOC_SRCFILES-$(CONFIG_ECP5)    += tap_ecp5.vhdl

# Lattice FPGAs have a somewhat uniform TAP API:
ifeq ($(FPGA_VENDOR),lattice)
SOC_SRCFILES-y += libhwtap_lattice.vhdl
SOC_SRCFILES-y += lattice_tap_pkg.vhdl
endif

SOC_SRCFILES-$(CONFIG_SPARTAN3) += tap_sp3.vhdl
SOC_SRCFILES-$(CONFIG_SPARTAN3) += xilinx_sp3_tap_pkg.vhdl

SOC_SRCFILES-$(CONFIG_SPARTAN6) += tap_sp6.vhdl
SOC_SRCFILES-$(CONFIG_SPARTAN6) += xilinx_sp6_tap_pkg.vhdl


else
# Virtual TAP (Simulation):
SOC_SRCFILES-$(CONFIG_VTAP) += vtap.vhdl
SOC_SRCFILES-$(CONFIG_VTAP_JTAG)  += stdtap.vhdl
SOC_SRCFILES-$(CONFIG_VTAP_JTAG)  += virtualtap.vhdl
SOC_SRCFILES-$(CONFIG_VTAP_DEBUG) += stdtap.vhdl
SOC_SRCFILES-$(CONFIG_VTAP_DEBUG) += vtap_debug.vhdl

# Special options for a few platforms:
ifdef CONFIG_VTAP_JTAG
SOC_SRCFILES-$(CONFIG_breakout)     += configuration_tap_breakout.vhdl
SOC_SRCFILES-$(CONFIG_papilio)      += configuration_tap_papilio.vhdl
SOC_SRCFILES-$(CONFIG_hdr60)        += configuration_tap_hdr60.vhdl
SOC_SRCFILES-$(CONFIG_versa_ecp5)   += configuration_tap_versa_ecp5.vhdl
SOC_SRCFILES-$(CONFIG_netpp_node)   += configuration_tap_netpp_node.vhdl
endif

endif

# This file is generated:

ifdef HAVE_VTAP
GENERATED_SIMFILES = $(GENSOC_OUTPUT)/vtap_iomap_pkg.vhdl
GENERATED_SIMFILES += $(GENSOC_OUTPUT)/vtap_tap_registers_decode.vhdl
endif

GENERATED_FILES-$(CONFIG_VTAP) += $(GENSOC_OUTPUT)/stdtap_iomap_pkg.vhdl
SOC_SRCFILES-$(CONFIG_DUMMYTAP) += vtap_dummy.vhdl # Direct TAP
SOC_SRCFILES-$(CONFIG_ZPUNG) += zputap_iomap_pkg.vhdl
SOC_SRCFILES-$(CONFIG_ZEALOT) += zputap_iomap_pkg.vhdl

# We need to include this dummy tap for simulation
ifndef SYNTHESIS
SOC_SRCFILES-y += hwtap_dummy.vhdl
endif

TOPDIR ?= ../..
-include $(TOPDIR)/hdl/tap/custom_tap.mk

$(GENERATED_SIMFILES): $(DESCFILES)/tap.xml
	$(GENSOC) -o $(GENSOC_OUTPUT)/vtap \
		--data-width=8 --map-prefix=1 --interface-type=std_logic_vector -s \
		--decoder=tap_registers \
		$<

$(GENSOC_OUTPUT)/stdtap_iomap_pkg.vhdl: $(DESCFILES)/stdtap.xml
	$(GENSOC) -o $(GENSOC_OUTPUT)/stdtap \
		--data-width=8 --map-prefix=1 --interface-type=std_logic_vector -s \
		$<

