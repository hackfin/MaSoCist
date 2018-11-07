include config.mk

GHDLEX_DIR = src/vhdl/ghdlex

HAVE_NETPP = $(shell [ -e $(NETPP)/xml ] && echo y )

DUTIES = $(GHDLEX_DIR)/src/libghdlex.so

ifeq ($(HAVE_NETPP),y)
DUTIES += $(GHDLEX_DIR)/src/libghdlex-netpp.so
else
DUTIES += warn-no-netpp-installed
endif


GHDLEX_URL = $(REPO_SERVER)/ghdlex.git

$(GHDLEX_DIR): | src/vhdl
	cd $(dir $@) && \
	git clone $(GHDLEX_URL)

dry-run:
	@echo Will install ghdlex from repo:
	@echo $(GHDLEX_URL)

all: $(DUTIES)

warn-no-netpp-installed:
	@echo
	@echo ------------------------------------------------------
	@echo The 'netpp-dev' package is not installed.
	@echo If you wish to build ghdlex against netpp,
	@echo use 'sudo apt-get install netpp-dev' to install.
	@echo ------------------------------------------------------
	@echo

.PHONY: warn-no-netpp-installed

$(GHDLEX_DIR)/src/libghdlex.so: | $(GHDLEX_DIR)
	$(MAKE) -C $(dir $@)/.. clean all NETPP=

$(GHDLEX_DIR)/src/libghdlex-netpp.so: | $(GHDLEX_DIR)
	$(MAKE) -C $(dir $@)/.. clean all

