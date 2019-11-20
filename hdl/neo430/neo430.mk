# Makefile to checkout and pull in external neo430 code
#


REPO = https://github.com/stnolting/neo430.git

# Note: Some of these modules are not VHDL93 compliant and may not
# yet instanciate, when certain components are selected.
# This is GHDL specific, we'll handle it through MaSoCist in later
# revisions.

MODULES = package

# The minimum to run:
MODULES += cpu control reg_file alu addr_gen
MODULES += imem dmem boot_rom application_image bootloader_image
MODULES += wdt sysconfig


COREFILES = $(MODULES:%=$(NEO430_DIR)/rtl/core/neo430_%.vhd)

NEO430_DIR = $(SRC)/neo430/neo430

MAYBE_NEO430-$(CONFIG_NEO430) = $(SRC)/neo430/neo430.checked_out
MAYBE_NEO430-$(CONFIG_NEO430) += $(WORKDIR)/neo430-obj$(VHDL_STD_SUFFIX).cf

# Note: this is the default rule, as it is included early:

neo430-all: $(MAYBE_NEO430-y) all

# Rules to prepare the platform:
PREPARE_PLATFORM = $(MAYBE_NEO430-y)

$(NEO430_DIR)/README.md:
	cd $(TOPDIR); \
	git submodule init
	git submodule update
	# No more, we got it in .gitmodules
	# git submodule add $(REPO) hdl/neo430/neo430

$(SRC)/neo430/neo430.checked_out: $(NEO430_DIR)/README.md
	cd $(dir $<) ; \
	git checkout master
	touch $@

$(SRC)/neo430/neo430.patched: $(SRC)/neo430/neo430.checked_out
	cd $(NEO430_DIR); patch -p1 <../001_pc_sp.patch
	touch $@

# library
$(WORKDIR)/neo430-obj$(VHDL_STD_SUFFIX).cf: $(COREFILES)
	[ -e $(dir $@) ] || mkdir $(dir $@)
	$(GHDL) -i --workdir=$(dir $@) --work=neo430 $^

