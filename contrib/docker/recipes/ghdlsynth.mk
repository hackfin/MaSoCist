include config.mk

GHDLSYNTH_URL = https://github.com/tgingold/ghdlsynth-beta.git

src/ghdlsynth-beta:
	cd $(dir $@) && \
		git clone $(GHDLSYNTH_URL) $(notdir $@)

src/ghdlsynth-beta/ghdl.so: | src/ghdlsynth-beta
	$(MAKE) -C $(dir $@) all

install: src/ghdlsynth-beta/ghdl.so
	sudo $(MAKE) -C $(dir $<) install

dry-run:
	@echo Will install ghdlsynth from repo:
	@echo $(GHDLSYNTH_URL)

all: install

