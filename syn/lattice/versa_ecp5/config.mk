

VERILOG_BB_WRAPPERS = pll_mac.v jtag_wrapper.v bram_2psync.v
VERILOG_BB_WRAPPERS += dpram16_init.v

IPCORES_DIR = $(FPGA_VENDOR)/$(PLATFORM)/ipcores

VERILOG_BB_WRAPPERS-y = $(VERILOG_BB_WRAPPERS:%=$(IPCORES_DIR)/%)

VERILOG_BB_WRAPPERS-y += dual_raw.v

dual_raw.v: ../hdl/ram/ramgen.py
	python $<
