TOPDIR ?= ..

include $(TOPDIR)/config.mk
include $(TOPDIR)/vendor/$(VENDOR)/local_config.mk

DEVICEFILE ?= $(DESCFILES)/tap.xml

# ghdlex needs some translation:
ifdef CONFIG_MINGW32
CC=$(CROSS_CC)
PLATFORM_ARCH=mingw32
else
CONFIG_LINUX = $(CONFIG_NATIVE)
endif

ifneq ($(CONFIG_GHDLEX_PATH),)
GHDLEX ?= $(subst $\",,$(CONFIG_GHDLEX_PATH))
else
GHDLEX ?= $(MODULE_GHDLEX)
endif

$(GHDLEX):
	cd `dirname $(GHDLEX)`; tar xfz ghdlex-$(GHDLEX_VERSION).tgz

ifeq ($(MODULE_TAPLIB),y)
include $(GHDLEX)/ghdlex.mk
endif

NETPP ?= /usr/share/netpp

ifdef NETPP
	include $(NETPP)/xml/prophandler.mk
	CFLAGS += -I$(NETPP)/include -I$(NETPP)/devices
endif


all-libsim: check-env $(MYSIM_DUTIES)

show-duties: 
	@echo GHDLEX dir: $(GHDLEX)
	@echo DLL to build: $(MYSIM_DUTIES)
	@echo TAPLIB: $(MODULE_TAPLIB)
check-env:
ifndef MODULE_TAPLIB
	$(warning ### TAPLIB not enabled ###)
endif

clean::
	rm -fr $(LIBSIM).a proplist.c proplist.o


