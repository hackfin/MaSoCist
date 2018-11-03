KCONFIG_VER = 4.11.0.0

KCONFIG_URL = http://ymorin.is-a-geek.org/git/kconfig-frontends/

# If you want to be on the safe side, choose this commit:
include config.mk

COMMIT = df6a283

# KCONFIG_DIR = kconfig-frontends-$(KCONFIG_VER)
KCONFIG_DIR = kconfig-frontends
KCONFIG_TAR = $(KCONFIG_DIR).tar.bz2

all: install-kconfig

dry-run:
	@echo Will checkout GHDL library from $(KCONFIG_URL)
	@echo ...and configure and compile it

install-kconfig: build/kconfig-frontends/frontends/kconfig
	$(SUDO) $(MAKE) -C $(dir $<)/.. install

$(KCONFIG_TAR):
	wget http://ymorin.is-a-geek.org/download/kconfig-frontends/$(KCONFIG_TAR)

# src/$(KCONFIG_DIR)/configure: $(KCONFIG_TAR)
# 	tar xfj $(KCONFIG_TAR) -C src

build/kconfig-frontends/Makefile: src/$(KCONFIG_DIR)/configure
	[ -e build ] || mkdir build
	[ -e build/kconfig-frontends ] || mkdir build/kconfig-frontends
	cd $(dir $@); ../../$< --enable-mconf --prefix=$(INSTALL_PREFIX)

src/kconfig-frontends:
	cd src && \
 	git clone $(KCONFIG_URL)

src/kconfig-frontends/configure: | src/kconfig-frontends
	cd $(dir $@) && git checkout $(COMMIT)
	cd $(dir $@) && \
	aclocal && libtoolize && autoconf ; automake --add-missing ; autoreconf

# No longer required
# kconfig-frontends.patch:
# 	wget $(PATCH_URL)/$<
# 
# kconfig-patch.stamp:
# 	cd src && patch -p1 -i ../kconfig-frontends.patch
# 	touch $@

build/kconfig-frontends/config.status: src/$(KCONFIG_DIR)/configure
	[ -e build ] || mkdir build
	[ -e build/kconfig-frontends ] || mkdir build/kconfig-frontends
	cd $(dir $@) && ../../$< --prefix=$(HOME)

build/kconfig-frontends/frontends/kconfig: build/kconfig-frontends/Makefile
	$(MAKE) -C build/kconfig-frontends all

clean:
	rm -fr build/kconfig-frontends
