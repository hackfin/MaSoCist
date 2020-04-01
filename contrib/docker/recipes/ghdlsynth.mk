include config.mk

COMMIT = e3cbdbca7d4fb3464e9456d627a5b600394c4d18

GHDL_YOSYS_PLUGIN_URL = https://github.com/ghdl/ghdl-yosys-plugin.git

src/ghdl-yosys-plugin:
	cd $(dir $@) && \
		git clone $(GHDL_YOSYS_PLUGIN_URL) $(notdir $@)

src/ghdl-yosys-plugin/ghdl.so: | src/ghdl-yosys-plugin
	cd $(dir $@) && git checkout $(COMMIT)
	$(MAKE) -C $(dir $@) all

install: src/ghdl-yosys-plugin/ghdl.so
	sudo $(MAKE) -C $(dir $<) install

dry-run:
	@echo Will install ghdl yosys plugin from repo:
	@echo $(GHDL_YOSYS_PLUGIN_URL)

all: install

