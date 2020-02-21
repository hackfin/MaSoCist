MASOCIST_ABSOLUTE_DIR = $(shell pwd)/..
GHDLLIB_ABSOLUTE_DIR = $(HOME)/src/vhdl/lib-devel

# GHDLEX_ABSOLUTE_DIR = $(HOME)/src/vhdl/ghdlex

LIBPREFIX ?= /src/lib

DOCKER = docker

DOCKERARGS = run --rm \
	-v $(MASOCIST_ABSOLUTE_DIR):/src \
	-v $(GHDLLIB_ABSOLUTE_DIR):$(LIBPREFIX) \
	-w /src/syn

GHDL      ?= $(DOCKER) $(DOCKERARGS) ghdl/synth:beta ghdl
YOSYS     ?= $(DOCKER) $(DOCKERARGS) ghdl/synth:beta yosys
NEXTPNR   ?= $(DOCKER) $(DOCKERARGS) ghdl/synth:nextpnr-ecp5 nextpnr-ecp5
ECPPACK   ?= $(DOCKER) $(DOCKERARGS) ghdl/synth:trellis ecppack
OPENOCD   ?= $(DOCKER) $(DOCKERARGS) \
	--device /dev/bus/usb ghdl/synth:prog openocd

LIB_CREATE   ?= $(DOCKER) $(DOCKERARGS) ghdl/synth:beta \
	make -C $(LIBPREFIX) VHDL_STD=$(VHDL_STD) SYNTHESIS=yes \
	GHDL_TARGET_DIR=synlib

