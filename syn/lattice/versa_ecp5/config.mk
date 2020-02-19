
ENABLE_TAP_BB = y

TAP_GLUE = lattice/tap_glue/hdl/tap_lattice_glue.vhdl

VERILOG_BB_WRAPPERS = pll_mac.v jtag_wrapper.v bram_2psync.v

# Split into architecture specific files, as they're dependent on
# an existing *.hex:
ARCH_DEP_V-$(CONFIG_NEO430)     = dpram16_init_neo430.v
ARCH_DEP_V-$(CONFIG_ZPUNG)      = dpram16_init_zpu.v
ARCH_DEP_V-$(CONFIG_RISCV_ARCH) = dpram16_init.v

VERILOG_BB_WRAPPERS += $(ARCH_DEP_V-y)

IPCORES_DIR = $(FPGA_VENDOR)/$(PLATFORM)/ipcores

VERILOG_BB_WRAPPERS-y = $(VERILOG_BB_WRAPPERS:%=$(IPCORES_DIR)/%)

# VERILOG_BB_WRAPPERS-y += dual_raw.v

ifdef CONFIG_ZPUNG
TAP_USERCODE_INTEGER = 3405647904
else
	ifdef CONFIG_RISCV_PYRV32
		TAP_USERCODE_INTEGER = 3405647952
	else
		TAP_USERCODE_INTEGER = 0
	endif
endif

ifndef ENABLE_TAP_BB
PROJECTFILES += $(TAP_GLUE)
endif

dual_raw.v: ../hdl/ram/ramgen.py
	python $<
