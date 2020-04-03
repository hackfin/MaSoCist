include config.mk

GHDL_YOSYS_PLUGIN_URL = https://github.com/ghdl/ghdl-yosys-plugin.git

src/ghdl-yosys-plugin:
	cd $(dir $@) && \
		git clone $(GHDL_YOSYS_PLUGIN_URL) $(notdir $@)

src/ghdl-yosys-plugin/ghdl.so: | src/ghdl-yosys-plugin
	$(MAKE) -C $(dir $@) all

install: src/ghdl-yosys-plugin/ghdl.so
	sudo $(MAKE) -C $(dir $<) install

dry-run:
	@echo Will install ghdl yosys plugin from repo:
	@echo $(GHDL_YOSYS_PLUGIN_URL)

all: install

