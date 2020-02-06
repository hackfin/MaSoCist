# Add custom module decoders to build here:
# Makefile stub for OpenSource repo

# Specific OpenSource modules are added here:


# GENERATED_FILES-$(CONFIG_SCACHE) += 
# SRCFILES-$(CONFIG_OPTION_FOO) += 

# search for libs in $HOME/lib:

GHDL_LDFLAGS += -Wl,-L$(HOME)/lib


PLATFORM_IPCORES = lattice/$(PLATFORM)/ipcores

# Emulation files for simulation:
SIM_SRCFILES-$(CONFIG_versa_ecp5) += hdl/plat/versa_ecp5/black_boxes.vhdl
SYN_SRCFILES-$(CONFIG_versa_ecp5) += $(PLATFORM_IPCORES)/black_boxes.vhdl


