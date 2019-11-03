# Opensource makefile

NETPP ?= /usr/share/netpp

DEVICE_CONFIG ?= $(DEVICE_FAMILY)

DOCUMENTATION = soc-$(DEVICE_CONFIG)
DUTIES = opensource.pdf $(DOCUMENTATION).pdf

GENERATED_XML = devicemap.xml device_properties.xml


include ../config.mk
include ../vendor/$(VENDOR)/local_config.mk

all: $(DUTIES)

DEVICEFILE = $(DESCFILES)/$(DEVICE_CONFIG).xml

include $(NETPP)/xml/prophandler.mk

include recipes/devicemaps.mk

DEPS = $(GENERATED_XML)

$(DOCUMENTATION).xml: main-$(DEVICE_CONFIG).xml $(DEPS)
	$(XP) -o $@ --xinclude $(NETPP)/xml/xpointer.xsl $<

opensource.pdf: reference/quickstart.xml reference/vendor.xml

show-duties:
	@echo $(DEPS)

clean::
	-rm $(DUTIES)

%.pdf: %.xml
	dblatex $<

