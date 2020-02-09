# Makefile rules for XML devdesc config file generation from CONFIG_*
# variables
#
# (c) 2013-2016, Martin Strubel <hackfin@section5.ch>
#
# This file is subjected to the MaSoCist license v1
#

define nl


endef

define xml_convert_int
	<num id="$(1)">$($(1))</num>${nl}
endef

define xml_convert_boolean
	<config id="$(1)">$($(1))</config>${nl}
endef

define XML_HEADER
<?xml version="1.0" encoding="UTF-8"?>
<devdesc_cfg version="0.1"
         xmlns="http://www.section5.ch/dclib/schema/devdesc"
         xmlns:my="http://www.section5.ch/dclib/schema/devdesc"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:xs="http://www.w3.org/2001/XMLSchema"
         xmlns:xi="http://www.w3.org/2001/XInclude"
         xmlns:ns22="http://www.w3.org/1999/xhtml"
         xmlns:memmap="http://www.section5.ch/dclib/schema/memmap"
         xmlns:interfaces="http://www.section5.ch/dclib/schema/interfaces"
         xmlns:html="http://www.xmlmind.com/xmleditor/schema/xhtml"
         xmlns:hfp="http://www.w3.org/2001/XMLSchema-hasFacetAndProperty">

endef

define XML_FOOTER

</devdesc_cfg>
endef

XMLCONFIG = perio_config.xml


XMLCONF-y = $(XML_HEADER)
XMLCONF-y += <xi:include href="$(SOC_DEVICEFILE)"/> ${nl}
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SIC)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SCACHE)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_DMA)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SIC2)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SYS)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_UART)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SPI)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_TWI)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_TIMER)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_PWM_ADVANCED)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_PWM_SIMPLE)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_GPIO)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_MAC)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_VIDEO)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_VIDEO_SENSOR)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_FIFO)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_LCDIO)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_SCRATCHPAD_RAM)
XMLCONF-y += $(call xml_convert_boolean,CONFIG_MACHXO2_EFB)


# Custom stuff should move to vendor/$(VENDOR)/Makefile
XMLCONF-y += $(CUSTOM_XMLCONF)

XMLCONF-y += $(XML_FOOTER)

DEVICEFILE_TARGET = $(GENSOC_OUTPUT)/$(DEVICE_FAMILY)-$(PLATFORM).xml

ECHO_WITH_ESC = printf
# echo -e fails on some systems, probably due to bash version

showtarget:
	echo $(DEVICEFILE_TARGET)

$(XMLCONFIG): $(TOPDIR)/.config $(SOC_DEVICEFILE)
	$(ECHO_WITH_ESC) '$(subst $(nl),\n,${XMLCONF-y})' > $@

$(DEVICEFILE_TARGET): $(XMLCONFIG)
	xsltproc -o $@ --path "$(SRC)/plat" --xinclude $(SRC)/plat/target.xsl \
		$<

clean::
	-rm $(XMLCONFIG) $(DEVICEFILE_TARGET)
