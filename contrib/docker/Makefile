RECIPES = $(sort $(wildcard recipes/*.mk))

INSTALL_PACKAGES = $(RECIPES:recipes/%.mk=install-%)

RUN_RECIPES = neo430

RUN_PACKAGES = $(RUN_RECIPES:%=test-%)

all: $(INSTALL_PACKAGES)

test: $(RUN_PACKAGES)

test-%:
	$(MAKE) -f recipes/$*.mk test INSTALL_PREFIX=$(INSTALL_PREFIX)

install-%:
	$(MAKE) -f recipes/$*.mk all INSTALL_PREFIX=$(INSTALL_PREFIX)

dry-run: 
	@for i in $(RECIPES); do \
	echo -------------------------- $$i ------------------------------; \
	$(MAKE) -f $$i dry-run; done


DISTFILES = Makefile config.mk recipes

masocist-installer.tgz: $(DISTFILES)
	tar cfz $@ $^

dist: masocist-installer.tgz
	cat self-extract.sh $< >masocist_sfx.sh

