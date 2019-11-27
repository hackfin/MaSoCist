############################################################################
# MaSoCist master makefile
# (c) 2012-2017 Martin Strubel <hackfin@section5.ch>
#


SHELL := bash
TOPDIR = $(CURDIR)

include config.mk
export VENDOR

Kconfig = ./Kconfig
TMPDIR = /tmp

Q ?= @
QUIET ?= >/dev/null 2>/dev/null

# Minimum duty is to build simulation:
BUILD_DUTIES ?= sim

all: check-config $(BUILD_DUTIES)

sw: check-config
	@echo "BUILDING SOFTWARE FOR SYNTHESIS"
	$(MAKE) -C $@ clean all

syn: check-config
	$(MAKE) -C $@

test: check-config
	$(MAKE) -C $@/$(PLATFORM) all

sim: check-config
	@echo "BUILDING SIMULATION"
	$(MAKE) -C $@ clean all

doc:
	$(MAKE) -C $@

check-config:
	@[ -e .config ] || (echo "Not configured! Run 'make which'."; false)
	@[ -e $(VENDOR_CONFIG) ] || (echo "Initialize vendor/default first!"; false)
	
.PHONY: check-config

############################################################################
# Generate configuration:

show-duties:
	echo $(BUILD_DUTIES)

%: vendor/$(VENDOR)/defconfig_%
	-$(MAKE) clean
	cp $< .config
	$(MAKE) silentoldconfig VENDOR=$(VENDOR)

defconfig: .config
	diff $< $(DEFCONFIG) || \
	cp -i $< $(DEFCONFIG)
	diff $< $(DEFCONFIG) || \
	$(DIFF) $< $(DEFCONFIG)


DEFCONFIG_FILES = $(wildcard vendor/$(VENDOR)/defconfig_*)
DEFCONFIG = vendor/$(VENDOR)/defconfig_$(PLATFORM)$(EXTENSION)

which:
	@for i in \
		$(patsubst vendor/$(VENDOR)/defconfig_%, %, $(DEFCONFIG_FILES)); \
		do \
		if [ \"$$i\" == \"$(PLATFORM)$(EXTENSION)\" ]; then \
		echo --$$i--; \
		else \
		echo $$i; \
		fi; \
	done

############################################################################

clean:
	$(Q)$(MAKE) -C syn clean $(QUIET)
	$(Q)$(MAKE) -C sw clean $(QUIET)
	$(Q)$(MAKE) -C sim clean $(QUIET)
	$(Q)-[ -e doc/Makefile ] && $(MAKE) -C doc clean $(QUIET)


dist:
	$(MAKE) -C vendor all VENDOR=$(VENDOR)

include kconfig/kconfig.mk


dummy:

collectinfo:

.PHONY: sw sim syn doc

