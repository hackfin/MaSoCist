include config.mk

GHDLEX_URL = $(REPO_SERVER)/ghdlex.git

src/vhdl/ghdlex: | src/vhdl
	cd $(dir $@) && \
	git clone $(GHDLEX_URL)

dry-run:
	@echo Will install ghdlex from repo:
	@echo $(GHDLEX_URL)


all: src/vhdl/ghdlex/libnetpp.vhdl

src/vhdl/ghdlex/libnetpp.vhdl: | src/vhdl/ghdlex
	$(MAKE) -C $(dir $@) all

