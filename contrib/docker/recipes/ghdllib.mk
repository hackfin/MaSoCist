# GHDL development library
#

include config.mk
GHDLLIB_TGZ = ghdllib-1.0-devel.tgz
# GHDLLIB_URL = $(REPO_SERVER)/ghdllib.git
GHDLLIB_URL = https://section5.ch/downloads/$(GHDLLIB_TGZ)

# We depend on ghdlex:
GHDLEX ?= $(VHDL)/ghdlex
LIBNAME = lib-devel
GHDLLIB = src/vhdl/$(LIBNAME)

all: $(GHDLLIB)/ghdlex-obj93.cf

dry-run:
	@echo Will checkout GHDL library from $(GHDLLIB_URL)

$(GHDLEX):
	$(MAKE) install-ghdlex

$(GHDLLIB)/ghdlex-obj93.cf: $(GHDLLIB) | $(GHDLEX) 
	$(MAKE) -C $(dir $@) all
	
src/vhdl:
	mkdir $@

# Currently disabled, we pull a snapshot:
# $(GHDLLIB): | src/vhdl
# 	cd $(dir $@) && \
# 	git clone $(GHDLLIB_URL) $(LIBNAME)
# 

$(GHDLLIB): | src/vhdl
	cd $(dir $(GHDLLIB)) && \
	wget $(GHDLLIB_URL) && \
	tar xfz $(GHDLLIB_TGZ)

# src/vhdl/lib: | $(GHDLLIB)
# 	cd src/vhdl && ln -s ghdllib lib

.PHONY: all
