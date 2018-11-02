include config.mk

MASOCIST_URL = $(REPO_SERVER)/MaSoCist.git

src/vhdl:
	mkdir $@

src/vhdl/masocist-opensource: | src/vhdl 
	cd $(dir $@) && \
		git clone $(MASOCIST_URL) $(notdir $@)

dry-run:
	@echo Will install masocist from repo:
	@echo $(MASOCIST_URL)

all: | src/vhdl/masocist-opensource
