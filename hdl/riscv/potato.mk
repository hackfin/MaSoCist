POTATO_DIR = $(SRC)/riscv/potato

REPO = https://github.com/skordal/potato.git

COREFILES = $(wildcard $(POTATO_DIR)/src/*.vhd)
COREFILES += $(SRC)/riscv/potato_pkg.vhdl

# Force VHDL standard 2008:
VHDL_STD = 08

CROSS_COMPILE = riscv32-unknown-elf-

MAYBE_POTATO-$(CONFIG_RISCV_POTATO) = $(SRC)/riscv/potato.checked_out

MAYBE_POTATO-$(CONFIG_RISCV_POTATO) += \
	$(WORKDIR)/potato-obj08.cf

potato-all: $(MAYBE_POTATO-y) all

$(POTATO_DIR)/README.md:
	cd $(TOPDIR); \
	git submodule init
	git submodule update

$(SRC)/riscv/potato.checked_out: $(POTATO_DIR)/README.md
	cd $(dir $<) ; \
	git checkout master
	touch $@

# Rules to prepare the platform:
PREPARE_PLATFORM = $(MAYBE_POTATO-y)

$(WORKDIR)/potato-obj08.cf: $(COREFILES)
	[ -e $(dir $@) ] || mkdir $(dir $@)
	$(GHDL) -i --workdir=$(dir $@) --std=08 --work=potato $^

