VERSION_MAJOR := 0
VERSION_MINOR := 0
VERSION_CODENAME := wonz

define KCONF_WARNING

			$(t_red)WARNING!$(col_rst)

	kconfig-frontends not installed!
	You can download kconfig-frontends from their homepage here
	http://ymorin.is-a-geek.org/projects/kconfig-frontends

endef

HAVE_KCONFIG=$(shell which kconfig-conf 2>/dev/null || echo no)

ifeq ($(HAVE_KCONFIG),no)
$(info $(KCONF_WARNING))
$(error Sorry)
endif

$(TMPDIR)/.version: $(GENSOC_DIR)/.version
	$(Q)$(GENSOC_DIR)/kconfig/config --set-str VERSION_MAJOR "$(VERSION_MAJOR)"
	$(Q)$(GENSOC_DIR)/kconfig/config --set-str VERSION_MINOR "$(VERSION_MINOR)"
	$(Q)$(GENSOC_DIR)/kconfig/config --set-str VERSION_CODENAME "$(VERSION_CODENAME)"
	$(Q)$(GENSOC_DIR)/kconfig/config --set-str VERSION_GIT "$(VERSION_GIT)" 
	$(SILENT_VER) $(GENSOC_DIR)/kconfig/config --set-str VERSION_STRING "$(VERSION_MAJOR).$(VERSION_MINOR), $(VERSION_CODENAME)"
	$(Q)touch $(@)

define frontend_template
$(1): collectinfo
	$$(Q) kconfig-$(2) $(Kconfig)
	$$(Q)echo "MaSoCist configuration is now complete."
	$$(Q)echo "Run 'make sim' to build for simulation"
endef

$(eval $(call frontend_template,menuconfig,mconf))
$(eval $(call frontend_template,nconfig,nconf))


$(TOPDIR)/include/config/auto.conf: $(TMPDIR)/.configured
	$(Q)echo > /dev/null

$(TOPDIR)/sw/autoconf.h: $(TMPDIR)/.configured
	$(Q)echo > /dev/null


config: collectinfo
	$(Q)kconfig-conf --oldaskconfig $(Kconfig)

oldconfig: collectinfo
	$(Q)kconfig-conf --$@ $(Kconfig)

$(TMPDIR)/.configured: $(deps_config) .config
	$(SILENT_INFO) "Config changed, running silentoldconfig"
	$(Q)$(MAKE) -f $(GENSOC_DIR)/Makefile silentoldconfig
	$(Q)touch $(@)

silentoldconfig: collectinfo
	$(Q)mkdir -p include/generated
	$(Q)mkdir -p include/config
	$(Q)kconfig-conf --$@ $(Kconfig)

set_version:
	$(Q)$(GENSOC_DIR)/kconfig/config --file $(GENSOC_DIR)/.version --set-str VERSION_GIT "$(VERSION_GIT)"
	$(Q)KCONFIG_CONFIG=$(GENSOC_DIR)/.version kconfig-mconf $(KVersion)
	$(Q)echo "N.B. Remember to amend the version changes to the release commit"
