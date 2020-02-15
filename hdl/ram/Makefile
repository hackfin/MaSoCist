
SRCFILES += libram.vhdl

REQUIRE_DPRAM_CLK2=$(CONFIG_MAC)
ifeq ($(REQUIRE_DPRAM_CLK2),)
REQUIRE_DPRAM_CLK2=$(CONFIG_SCRATCHPAD_RAM)
endif

SRCFILES-$(CONFIG_ZEALOT) += ram/bram.vhdl
SRCFILES-$(CONFIG_ZEALOT) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_SCRATCHPAD_RAM) += ram/dpram.vhdl
SRCFILES-$(CONFIG_SCRATCHPAD_RAM) += ram/dpram_wrapper.vhdl
SRCFILES-$(REQUIRE_DPRAM_CLK2) += ram/dpram_clk2.vhdl
SRCFILES-$(CONFIG_JPEG)           += ram/dpramc2_init.vhdl


SRCFILES-$(CONFIG_PYPS) += ram/pkg_ram.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpram_init.vhdl
SRCFILES-$(CONFIG_PYPS) += ram/dpramc2_init.vhdl

SRCFILES-$(CONFIG_RISCV_ARCH) += ram/pkg_ram.vhdl

# We need a few workarounds until dual port RAM fully synthesizes:

ifdef SYNTHESIS
	ifdef CONFIG_GHDL_SYNTH
		SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpram_init_ghdlsynth.vhdl
		SRCFILES-$(CONFIG_RISCV_ARCH) += ram/memmap_data_ghdlsynth.vhdl
		SRCFILES-$(CONFIG_ZPUNG) += ram/dpram_init_ghdlsynth.vhdl
		# SRCFILES-$(CONFIG_ZPUNG) += ram/bram_ghdlsynth.vhdl
		SRCFILES-$(CONFIG_ZPUNG) += ram/memmap_data_ghdlsynth.vhdl
	else
		# Yet unsupported by GHDL synthesis:
		SRCFILES-$(CONFIG_RISCV_ARCH) += ram/bram.vhdl
		SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpram_init.vhdl
		SRCFILES-$(CONFIG_RISCV_ARCH) += ram/memmap_data.vhdl
	endif
else
	SRCFILES-$(CONFIG_ZPUNG) += ram/bram.vhdl
	SRCFILES-$(CONFIG_ZPUNG) += ram/dpram_init.vhdl
	SRCFILES-$(CONFIG_RISCV_ARCH) += ram/bram.vhdl
	SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpram_init.vhdl
	SRCFILES-$(CONFIG_RISCV_ARCH) += ram/memmap_data.vhdl
	SRCFILES-$(CONFIG_NEO430) += ram/bram.vhdl
	SRCFILES-$(CONFIG_NEO430) += ram/dpram_init.vhdl
	SRCFILES-$(CONFIG_NEO430) += ram/dpram.vhdl
	SRCFILES-$(CONFIG_NEO430) += ram/dpram_wrapper.vhdl
endif
SRCFILES-$(CONFIG_RISCV_ARCH) += ram/dpramc2_init.vhdl

ram:
	echo $(SRCFILES-y)
