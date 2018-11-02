# Makefile to generate bit files from code and external flash area

TOPDIR = ../../..


BSCAN_SPIDRV = bscan_spi_lx9.bit

EXE ?= $(TOPDIR)/sw/main.elf 

PROJECT ?= test


VENDOR ?= section5

include $(TOPDIR)/config.mk
include $(TOPDIR)/vendor/$(VENDOR)/config.mk

CCAP_ARCHITECTURE = $(CONFIG_SOCDESC)
include ../buildimg.mk


all: image

clean:
	rm -f main $(DATAFILE)

