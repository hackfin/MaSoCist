# local config:
NETPP ?= /usr/share/netpp
XSLTPROC = xsltproc
LIBGHDL = $(HOME)/src/vhdl/lib-devel/work
GHDLEX = $(HOME)/src/vhdl/ghdlex
GENSOC = gensoc

# We have netpp:
CONFIG_NETPP = y

SIM_OPTIONS = --max-stack-alloc=256 --assert-level=error \
	--ieee-asserts=disable

VENDOR_LIBRARY_DIR = /data/src/diamond_lib

DOC_EXTRA_PARAMETERS = --path $(NETPP)/xml
