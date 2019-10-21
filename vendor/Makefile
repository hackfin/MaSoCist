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
QUIET ?= >/dev/null

%_config.stamp:
	@echo ---------------------------------------------------------
	@echo -e "\e[36mConfiguring platform '$*' \e[0m"
	@echo ---------------------------------------------------------
	@$(MAKE) -C .. $* VENDOR=$(VENDOR)
	@touch $@

%_build.stamp: %_config.stamp
	@echo ---------------------------------------------------------
	@echo -e "\e[36mBuilding platform '$*' \e[0m"
	@echo ---------------------------------------------------------
	@$(MAKE) -C .. $(BUILD_DUTIES) $(BUILD_PARAMS) $(QUIET) 2> /tmp/$*.log || \
	( echo -e "!! \e[41mBUILD FAILED\e[0m, see /tmp/$*.log"; false )
	@touch $@

%_regtest.stamp: %_build.stamp
	@echo ---------------------------------------------------------
	@echo -e "\e[36mRunning test for '$*' \e[0m"
	@echo ---------------------------------------------------------
	$(MAKE) -C .. test $(QUIET) 2> /tmp/$*.log || \
	( echo -e "!! \e[41mREGTEST FAILED\e[0m, see /tmp/$*.log"; false )
	@touch $@

%_defconfig.stamp: %_build.stamp
	$(MAKE) -C .. defconfig VENDOR=$(VENDOR)
	@touch $@


.PHONY: clean build_all test_all

STAMPS = $(DIST_PLATFORMS:%=%_defconfig.stamp)

REGRESS_TEST_STAMPS += $(TEST_PLATFORMS:%=%_regtest.stamp)
REGRESS_TEST_STAMPS += $(TEST_PLATFORMS:%=%_defconfig.stamp)

build_all: $(STAMPS)
	@echo -e "------------------------------------"
	@echo -e "---       \e[42mBUILD DONE\e[0m             ---"
	@echo -e "------------------------------------"

test_all: $(REGRESS_TEST_STAMPS)
	@echo -e "------------------------------------"
	@echo -e "---       \e[42mTESTS DONE\e[0m             ---"
	@echo -e "------------------------------------"

clean:
	rm -f *.stamp

dist_all: build_all
	@for i in $(DIST_PLATFORMS); do \
		$(MAKE) -f dist.mk simdist VENDOR=$(VENDOR) && \
		$(MAKE) -f dist.mk dist SYNTHESIS=y VENDOR=$(VENDOR) && \
		$(MAKE) -f dist.mk dist VENDOR=$(VENDOR); \
	done;

