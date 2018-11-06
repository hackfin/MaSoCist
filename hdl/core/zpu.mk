# Needs ZEALOT/ZPUNG variable defined

ZPU_VHDL-$(CONFIG_ZEALOT) = $(ZEALOT)/zpu_small.vhdl
ZPU_VHDL-y += $(ZEALOT)/zpu_pkg.vhdl

WORKDIR ?= work

ifdef HAVE_MYHDL
GENERATED_FILES-$(CONFIG_ZPUNG) += $(ZPUNG)/ZPUng.vhd
else
SRCFILES-$(CONFIG_ZPUNG) += zpu/zpung/ZPUng.vhd
endif

ZPU_VHDL = $(ZPU_VHDL-y)

$(ZPUNG)/ZPUng.vhd:
	$(MAKE) -C $(ZPUNG)

ZPUREPO = http://repo.or.cz/zpu.git

$(SRC)/zpu/zpu.patched:
	cd $(SRC)/..; \
	git submodule add $(ZPUREPO) hdl/zpu/zpu
	cd $(SRC)/zpu/zpu ; \
	git checkout jtagdbg; \
	patch -p1 < ../zealot-section5-wishbone-fix.patch
	mv $(SRC)/zpu/zpu $@

$(ZEALOT): $(SRC)/zpu/zpu.patched
	ln -s zpu.patched/zpu/hdl/zealot $@

MAYBE_ZEALOT-$(CONFIG_ZEALOT) = $(ZEALOT)

allzpu: $(MAYBE_ZEALOT-y)

