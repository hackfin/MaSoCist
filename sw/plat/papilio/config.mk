OBJS-$(CONFIG_LCD) += bm_stilleben.o
# OBJS-$(CONFIG_SMARTLED) += bm_elmsfire.o
OBJS-$(CONFIG_SMARTLED) += test_smartled.o

ifdef CONFIG_COMPRESSED_FONT
BSPLIBOBJS-$(CONFIG_LCD) += bm_font4x8c.o
else
BSPLIBOBJS-$(CONFIG_LCD) += bm_font4x8.o
endif


BSPLIBOBJS-$(CONFIG_LCD) += lcd.o
BSPLIBOBJS-$(CONFIG_SMARTLED) += smartled.o trace.o

ifneq ($(VENDOR),opensource)
DISTFILES += lcd.h ili9163.h
endif

BSPLIBOBJS += $(BSPLIBOBJS-y)
