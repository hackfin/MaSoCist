
memmap_cfg-$(PLATFORM).vhdl: $(SRC)/plat/memmap.xsl $(SRC)/plat/memmap-$(PLATFORM).xml
	xsltproc -o $@ --xinclude \
			--stringparam srcfile $< \
			$^

GENERATED_FILES-$(CONFIG_PYPS) += memmap_cfg-$(PLATFORM).vhdl

