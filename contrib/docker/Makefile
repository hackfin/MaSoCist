RECIPES = $(sort $(wildcard recipes/*.mk))

INSTALL_PACKAGES = $(RECIPES:recipes/%.mk=install-%)

RUN_RECIPES = syn

TEST_PACKAGES = $(RUN_RECIPES:%=test-%)
RUN_PACKAGES = $(RUN_RECIPES:%=run-%)
CLEAN_PACKAGES = $(RUN_RECIPES:%=clean-%)

all: $(INSTALL_PACKAGES)

test: clean $(TEST_PACKAGES)

run: $(RUN_PACKAGES)

test-%:
	$(MAKE) -f recipes/$*.mk test INSTALL_PREFIX=$(INSTALL_PREFIX)

run-%:
	$(MAKE) -f recipes/$*.mk run INSTALL_PREFIX=$(INSTALL_PREFIX)

install-%:
	$(MAKE) -f recipes/$*.mk all INSTALL_PREFIX=$(INSTALL_PREFIX)

clean-%:
	$(MAKE) -f recipes/$*.mk clean

dry-run: 
	@for i in $(RECIPES); do \
	echo -------------------------- $$i ------------------------------; \
	$(MAKE) -f $$i dry-run; done

clean: $(CLEAN_PACKAGES)

DISTFILES = Makefile config.mk $(wildcard recipes/*)
DISTFILES += $(wildcard recipes/scripts/*.sh)

masocist-installer.tgz: $(DISTFILES)
	tar cfz $@ $^

dist: masocist-installer.tgz
	cat self-extract.sh $< >masocist-synth_sfx.sh

