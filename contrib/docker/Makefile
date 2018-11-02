INSTALL_PACKAGES = $(RECIPES:recipes/%.mk=install-%)

RECIPES = $(sort $(wildcard recipes/*.mk))

all: $(INSTALL_PACKAGES)

install-%:
	$(MAKE) -f recipes/$*.mk all INSTALL_PREFIX=$(INSTALL_PREFIX)

dry-run: 
	@for i in $(RECIPES); do \
	echo -------------------------- $$i ------------------------------; \
	$(MAKE) -f $$i dry-run; done

masocist-installer.tgz: Makefile config.mk recipes
	tar cfz $@ $^

dist: masocist-installer.tgz
	cat self-extract.sh $< >masocist_sfx.sh

