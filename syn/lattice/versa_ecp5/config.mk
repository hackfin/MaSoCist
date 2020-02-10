

TAP_GLUE = lattice/tap_glue/hdl/tap_lattice_glue.vhdl

VERILOG_BB_WRAPPERS = pll_mac.v jtag_wrapper.v bram_2psync.v
VERILOG_BB_WRAPPERS += dpram16_init.v

IPCORES_DIR = $(FPGA_VENDOR)/$(PLATFORM)/ipcores

VERILOG_BB_WRAPPERS-y = $(VERILOG_BB_WRAPPERS:%=$(IPCORES_DIR)/%)

# VERILOG_BB_WRAPPERS-y += dual_raw.v

ifdef CONFIG_ZPUNG
TAP_USERCODE_INTEGER = 3405647904
else
TAP_USERCODE_INTEGER = 3405647952
endif

PROJECTFILES += $(TAP_GLUE)

dual_raw.v: ../hdl/ram/ramgen.py
	python $<
