# Opensource makefile

NETPP ?= /usr/share/netpp

DEVICE_CONFIG ?= $(DEVICE_FAMILY)

DOCUMENTATION = soc-$(DEVICE_CONFIG)
DUTIES = opensource.pdf $(DOCUMENTATION).pdf

all: build-docs

GENERATED_XML = devicemap.xml device_properties.xml


include ../config.mk
include ../vendor/$(VENDOR)/local_config.mk


DEVICEFILE = $(DESCFILES)/$(DEVICE_CONFIG).xml

include $(NETPP)/xml/prophandler.mk

include recipes/devicemaps.mk

DEPS = $(GENERATED_XML)

$(DOCUMENTATION).xml: main-$(DEVICE_CONFIG).xml $(DEPS)
	$(XP) -o $@ --xinclude $(NETPP)/xml/xpointer.xsl $<

build-docs: $(DUTIES)

opensource.pdf: reference/quickstart.xml reference/vendor.xml

show-duties:
	@echo $(DUTIES)
	@echo $(DEPS)

clean::
	-rm $(DUTIES) $(GENERATED_XML)

%.pdf: %.xml
	dblatex $<

.PHONY: build-docs

