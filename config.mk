TOPDIR ?= ..

VENDOR ?= default
VENDOR_CONFIG = $(TOPDIR)/vendor/$(VENDOR)

# Where the description files are:
SRC = $(TOPDIR)/hdl
DESCFILES = $(SRC)/plat

SOC_DEVICEFILE = $(DESCFILES)/$(DEVICE_FAMILY).xml

-include $(TOPDIR)/.config
-include $(VENDOR_CONFIG)/config.mk
include $(TOPDIR)/platform.mk

# Device family: agathe, beatrix, cordula, dorothea, ...
DEVICE_FAMILY = $(subst $\",,$(CONFIG_SOCDESC))

ifdef CONFIG_PLAT_EXTENSION
EXTENSION = -$(subst $\",,$(CONFIG_PLAT_EXTENSION))
endif

# Tool defaults:
DIFF ?= diff

