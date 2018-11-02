# GHDL development library
#

include config.mk

GHDLLIB_URL = $(REPO_SERVER)/ghdllib.git

# We depend on ghdlex:
GHDLEX = src/vhdl/ghdlex
LIBNAME = lib-devel
GHDLLIB = src/vhdl/$(LIBNAME)

all: $(GHDLLIB)/ghdlex-obj93.cf

dry-run:
	@echo Will checkout GHDL library from $(GHDLLIB_URL)

$(GHDLEX):
	$(MAKE) install-ghdlex

$(GHDLLIB)/ghdlex-obj93.cf: | $(GHDLLIB) $(GHDLEX) 
	$(MAKE) -C $(dir $@) all
	
src/vhdl:
	mkdir $@

$(GHDLLIB): | src/vhdl
	cd $(dir $@) && \
	git clone $(GHDLLIB_URL) $(LIBNAME)

src/vhdl/lib: | $(GHDLLIB)
	cd src/vhdl && ln -s ghdllib lib

.PHONY: all
