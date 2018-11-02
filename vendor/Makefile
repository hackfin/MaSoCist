VENDOR ?= default

include $(VENDOR)/config.mk

# Wicked build script:
# Builds each platform in DIST_PLATFORMS and installs the stuff
# to the distribution dir.
# Not really clean, but rsync takes care of copying only what has changed.
# Let's hope for no clashes..

all: build_all test_all

default: $(VENDOR)
	-rm $@
	ln -s $< $@

.PHONY: default

BUILD_DUTIES ?= all

%_config.stamp:
	@echo ---------------------------------------------------------
	@echo Building platform '$*'
	@echo ---------------------------------------------------------
	$(MAKE) -C .. $* VENDOR=$(VENDOR)
	touch $@

%_build.stamp: %_config.stamp
	$(MAKE) -C .. $(BUILD_DUTIES) $(BUILD_PARAMS) 2> /tmp/$*.log || \
	( echo "!! BUILD FAILED, see /tmp/$*.log"; false )
	touch $@

%_regtest.stamp: %_config.stamp
	$(MAKE) -C .. test 2> /tmp/$*.log || \
	( echo "!! REGTEST FAILED, see /tmp/$*.log"; false )
	touch $@

%_defconfig.stamp: %_build.stamp
	$(MAKE) -C .. defconfig VENDOR=$(VENDOR)
	touch $@


.PHONY: clean build_all test_all

STAMPS = $(DIST_PLATFORMS:%=%_defconfig.stamp)

REGRESS_TEST_STAMPS += $(TEST_PLATFORMS:%=%_regtest.stamp)

build_all: $(STAMPS)
	@echo ------------------------------------
	@echo ---             DONE             ---
	@echo ------------------------------------

test_all: $(REGRESS_TEST_STAMPS)
	@echo ------------------------------------
	@echo ---             DONE             ---
	@echo ------------------------------------

clean:
	rm -f *.stamp

dist_all: build_all
	@for i in $(DIST_PLATFORMS); do \
		$(MAKE) -f dist.mk simdist VENDOR=$(VENDOR) && \
		$(MAKE) -f dist.mk dist SYNTHESIS=y VENDOR=$(VENDOR) && \
		$(MAKE) -f dist.mk dist VENDOR=$(VENDOR); \
	done;

