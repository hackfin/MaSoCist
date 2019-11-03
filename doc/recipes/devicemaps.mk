
GENERATED_XML = devicemap.xml device_properties.xml

include recipes/plat/$(DEVICE_CONFIG).mk


devicemap.xml: $(DEVICEFILE) devicemap.xsl
	$(XP) -o $@ \
			--stringparam mmr_base $(DOC_MMR_BASE) \
			$(DOC_EXTRA_PARAMETERS) \
			devicemap.xsl $<

custom_map_%.xml: $(DESCFILES)/plat_%.xml custom_map.xsl
	$(XP) -o $@ \
			$(DOC_EXTRA_PARAMETERS) \
			custom_map.xsl $<

memory_map-%.xml: $(DESCFILES)/memmap-%.xml memmap.xsl
	$(XP) -o $@ \
			$(DOC_EXTRA_PARAMETERS) \
			memmap.xsl $<

