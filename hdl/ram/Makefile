
SRCFILES += libram.vhdl

REQUIRE_DPRAM_CLK2=$(CONFIG_MAC)
ifeq ($(REQUIRE_DPRAM_CLK2),)
REQUIRE_DPRAM_CLK2=$(CONFIG_SCRATCHPAD_RAM)
endif

SRCFILES-$(CONFIG_ZEALOT) += ram/bram.vhdl
SRCFILES-$(CONFIG_ZEALOT) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_NEO430) += ram/bram.vhdl
SRCFILES-$(CONFIG_NEO430) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_NEO430) += ram/dpram.vhdl
SRCFILES-$(CONFIG_NEO430) += ram/dpram_wrapper.vhdl
SRCFILES-$(CONFIG_ZPUNG) += ram/bram.vhdl
SRCFILES-$(CONFIG_ZPUNG) += ram/dpram_init.vhdl

SRCFILES-$(CONFIG_SCRATCHPAD_RAM) += ram/dpram.vhdl
SRCFILES-$(CONFIG_SCRATCHPAD_RAM) += ram/dpram_wrapper.vhdl
SRCFILES-$(REQUIRE_DPRAM_CLK2) += ram/dpram_clk2.vhdl
SRCFILES-$(CONFIG_JPEG)           += ram/dpramc2_init.vhdl


SRCFILES-$(CONFIG_PYPS) += ram/pkg_ram.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpramc2_init.vhdl

SRCFILES-$(CONFIG_RISCV_ARCH) += ram/bram.vhdl
SRCFILES-$(CONFIG_RISCV_ARCH) += ram/pkg_ram.vhdl
SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpramc2_init.vhdl
SRCFILES-$(CONFIG_RISCV_ARCH) += ram/memmap_data.vhdl

ram:
	echo $(SRCFILES-y)
