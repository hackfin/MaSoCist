# Settings for inside MaSoCist container:
GHDL      = ghdl
YOSYS     = yosys
NEXTPNR   = nextpnr-ecp5
ECPPACK   = ecppack

LIBPREFIX = $(HOME)/src/vhdl/lib-devel

LIB_CREATE     = make -C $(LIBPREFIX) VHDL_STD=$(VHDL_STD) SYNTHESIS=yes \
	GHDL_TARGET_DIR=synlib

