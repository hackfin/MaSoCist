
SRCFILES += libram.vhdl
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
SRCFILES-$(CONFIG_SCRATCHPAD_RAM) += ram/dpram_clk2.vhdl
SRCFILES-$(CONFIG_JPEG)           += ram/dpramc2_init.vhdl


SRCFILES-$(CONFIG_PYPS) += ram/pkg_ram.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpramc2_init.vhdl

SRCFILES-$(CONFIG_RISCV_POTATO) += ram/bram.vhdl
SRCFILES-$(CONFIG_RISCV_POTATO) += ram/pkg_ram.vhdl
SRCFILES-$(CONFIG_RISCV_POTATO) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_RISCV_POTATO) += ram/dpramc2_init.vhdl
SRCFILES-$(CONFIG_RISCV_POTATO) += ram/memmap_data.vhdl

ram:
	echo $(SRCFILES-y)
