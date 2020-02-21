# Add custom module decoders to build here:
# Makefile stub for OpenSource repo

# Specific OpenSource modules are added here:


# GENERATED_FILES-$(CONFIG_SCACHE) += 
# SRCFILES-$(CONFIG_OPTION_FOO) += 

GENERATED_FILES-$(CONFIG_versa_ecp5) += $(SRC)/plat/versa_ecp5_top.vhdl
GENERATED_FILES-$(CONFIG_evdk_ecp5)  += $(SRC)/plat/evdk_ecp5_top.vhdl

# search for libs in $HOME/lib:

GHDL_LDFLAGS += -Wl,-L$(HOME)/lib

PLATFORM_IPCORES = lattice/$(PLATFORM)/ipcores

# Emulation files for simulation:
SIM_SRCFILES-$(CONFIG_versa_ecp5) += hdl/plat/versa_ecp5/black_boxes.vhdl
SYN_SRCFILES-$(CONFIG_versa_ecp5) += $(PLATFORM_IPCORES)/black_boxes.vhdl

SIM_SRCFILES-$(CONFIG_versa_ecp5) += hdl/plat/versa_ecp5/pll_mac.vhd

SIM_SRCFILES-$(CONFIG_evdk_ecp5) += hdl/plat/versa_ecp5/black_boxes.vhdl
SYN_SRCFILES-$(CONFIG_evdk_ecp5) += $(PLATFORM_IPCORES)/black_boxes.vhdl

