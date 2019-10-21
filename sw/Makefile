# Makefile for MaSoCist firmware

ROMFILE ?= rom_generated.vhd
VENDOR ?= default
# Board supply lib name
BSP_LIBRARIES = -L. -lbsp-$(PLATFORM) 

include ../config.mk

# If you wish to test the code without cache, disable CONFIG_SCACHE in the
# .config file. You don't need to re-synthesize the FPGA image. The FW will
# just not configure the cache.
# If there is no sufficient space, try disabling:
# - CONFIG_LCDIO
# - Other unused stuff from the linker script

ifdef SIMULATION
ifdef CONFIG_scache
# Force in this config:
USE_CACHE = n
else
USE_CACHE = n
endif
endif
USE_CACHE ?= $(CONFIG_SCACHE)


include ../vendor/$(VENDOR)/local_config.mk

# Determine linker script:
# When hard-configuring CUSTOM_MAP, put in the above config.mk
ifdef CUSTOM_MAP
	BSPNAME = $(CUSTOM_MAP)
else
	ifeq ($(USE_CACHE),y)
		ifdef CONFIG_SCACHE_HARDCODE
			BSPNAME = scache-hw
		else
			BSPNAME = scache
		endif
	else
		BSPNAME = baremetal
	endif
endif

DEVICEFILE = $(DESCFILES)/$(DEVICE_FAMILY).xml

ROMGEN = python ../utils/buildrom.py
FWGEN = python ../utils/buildfw.py

ifeq ($(ARCH),msp430)
MEM_INIT = mem_init16.chdl
else
MEM_INIT = mem_init.chdl
endif

AS      = $(CROSS_COMPILE)as
CC      = $(CROSS_COMPILE)gcc
STRIP   = $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
LD      = $(CROSS_COMPILE)ld


CFLAGS-$(CONFIG_OPT_SIZE)  += -Os
CFLAGS-$(CONFIG_OPT_SPEED) += -O3
CFLAGS-$(CONFIG_DEBUG_SYM) += -DDEBUG
CFLAGS-$(CONFIG_RISCV_ARCH) += -march=rv32i -mabi=ilp32


CFLAGS = -g -Wall $(PLATFORM_CFLAGS)
CFLAGS += -I. -Iinclude
CFLAGS += -Iinclude/arch/$(ARCH)
CFLAGS += $(CFLAGS-y)


ifdef SIMULATION
CFLAGS += -DSIMULATION # Disable for hardware
endif

ROM_DUTIES-y = $(ROMFILE)
ROM_DUTIES-$(CONFIG_SCACHE) += flashdata.bin

# Don't build SW for virtual CPU
ifndef CONFIG_NETPP_CPU
DUTIES = $(DUTIES-y) buildnumber main $(ROM_DUTIES-y)
endif

all: $(DUTIES)

lib: libbsp-$(PLATFORM).a

include buildno.mk

ifdef RELEASE
GIT_VERSION = $(shell git describe --always)
CFLAGS += -DBUILD_ID="git-$(GIT_VERSION)-\#$(BUILDNO)"
else
CFLAGS += -DBUILD_ID="$(VERSION)-\#$(BUILDNO)"
endif

ifdef BOOTSTRAP
OBJS = bootstrap.o
else
OBJS = main.o cmds.o utils.o
endif

OBJS-$(CONFIG_ZEALOT)        += irqhandler.o

OBJS-$(CONFIG_UART)          += shell.o
OBJS-$(CONFIG_PWM_ADVANCED)  += pwm.o
OBJS-$(CONFIG_PWM_SIMPLE)    += pwm.o
OBJS-$(CONFIG_TIMER)         += timer.o
OBJS-$(CONFIG_OC_UART16550)  += uart16550.o
OBJS-$(CONFIG_MACHXO_EFB)    += efb.o
OBJS-$(CONFIG_OC_I2C_RD1046) += i2c_oc.o
BSPLIBOBJS-$(CONFIG_UART)    += uart.o 
BSPLIBOBJS-$(CONFIG_SPI)     += spiflash.o 
BSPLIBOBJS-$(CONFIG_TWI)     += twi.o 
BSPLIBOBJS-$(CONFIG_PRINTF)  += printutils.o
BSPLIBOBJS-$(CONFIG_SCACHE)  += spicache.o 
BSPLIBOBJS-$(CONFIG_VIDEO)   += video.o 
BSPLIBOBJS-y                 += helper.o 

BSPLIBOBJS-$(CONFIG_LIBC_MINIMUM)       += arch/$(ARCH)/libcemu.o 
BSPLIBOBJS-$(CONFIG_TASK_MANAGEMENT)    += arch/$(ARCH)/context.o 
BSPLIBOBJS-$(CONFIG_TASK_MANAGEMENT)    += taskmgr.o 

# Further platform specific files should be added here:
-include plat/$(PLATFORM)/config.mk
BSPLIBOBJS-y += commonbsp.o
BSPLIBOBJS-$(CONFIG_RISCV_ARCH) += arch/$(ARCH)/irqmgmt.o

# Hook for system specific BSP addon:
BSPLIBOBJS-y += $(EXTRA_BSP)

OBJS += $(OBJS-y)

OBJS += test_$(PLATFORM).o

DISTFILES = $(OBJS:%.o=%.c) libbsp-$(PLATFORM).a Makefile
DISTFILES += inttypes.h
DISTFILES += $(PLATFORM).h soc_register.h driver.h ioaccess.h register_modes.h
DISTFILES += arch.h platform.h arch/zpu/crt0.s
DISTFILES += test_$(PLATFORM).c
DISTFILES += ldscripts/baremetal.ld $(wildcard ldscripts/*-baremetal.ld)
DISTFILES += lcd.h shell.h cmdhelper.h
DISTFILES += mem_init.chdl
DISTFILES += soc_mmr.gdb efb_mmr.gdb version.gdb .gdbinit pwm.gdb
# DISTFILES += gdbscript-zpu.xsl

$(LINKERSCRIPT):  linkerscript-$(ARCH).xsl $(SRC)/plat/memmap-$(PLATFORM).xml
	xsltproc -o $@ $^

# Make sure to recompile when register definitions change:

ifdef CONFIG_PYPS
BUILD = $(LD) -o $@ $^
else
BUILD = $(CC) -o $@ $(OBJS)
endif

# LDFLAGS are completely handled by ../platform.mk now.
# LDFLAGS += -Wl,--cref

main.elf: $(OBJS) lib $(CUSTOM_LINKERSCRIPT) $(DUTIES-y)
	-cp $(PLATFORM).map $(PLATFORM)-old.map
	$(BUILD) $(LDFLAGS)

showchanges:
	$(DIFF) $(PLATFORM).map $(PLATFORM)-old.map

# Build dependency for 
test_$(PLATFORM).c: $(PLATFORM).h $(PROG_BUILDNO)

# Other stuff we depend on:
ifdef GENSOC
HEADERS-y = soc_register.h soc_register_modes.h
HEADERS-$(CONFIG_MACHXO_EFB) += efb_register.h efb_register_modes.h
HEADERS-$(CONFIG_I2CBRIDGE) += i2cslave_register.h
DUTIES-y += soc_mmr.gdb

HEADERS-$(CONFIG_RISCV_ARCH) += arch/riscv/csr_register.h

else
GENSOC = @echo "gensoc module missing!" \#
# Fallback: Use netpp
ifdef NETPP
include netpp-fallback.mk
endif
endif

XP ?= xsltproc

HEADERS-y += $(PLATFORM).h 

DUTIES-y += $(HEADERS-y)
DUTIES-$(HAVE_BSPSRC)   += libbsp-$(PLATFORM).a
ifndef HAVE_CRT0
DUTIES-$(CONFIG_SCACHE) += crt0.o 
DUTIES-y                += crt0-nocache.o
endif

libbsp-$(PLATFORM).a: $(HEADERS-y) $(BSPLIBOBJS-y)
	  ar ruvs $@ $(BSPLIBOBJS-y) 

soc_register.h: $(DEVICEFILE)
	$(GENSOC) -o soc -r $<

%_register.h %_register_modes.h: $(DEVICEFILE)
	$(GENSOC) -o $* -r -C $<

# Special rule for hard IP
efb_register.h efb_register_modes.h: plat/machxo_efb/efb.xml
	$(GENSOC) -o efb -r -M1 -C $<

ifdef HAVE_PLATFORM_DESCRIPTION
$(PLATFORM)_register.h: $(SRC)/plat/plat_$(PLATFORM).xml
	$(GENSOC) -o $(PLATFORM) -r -M1 $<
else
# deprecated: platform as separate device in SoC device file:
$(PLATFORM)_register.h: $(DEVICEFILE)
	$(GENSOC) -o $(PLATFORM) -r -M1 -Dplatform_$(PLATFORM) $<

endif

arch/riscv/csr_register.h: ../hdl/riscv/riscv32.xml
	$(GENSOC) -o arch/riscv/csr -r -B 1 $<

$(PLATFORM).h: $(PLATFORM)_register.h
	mv -f $< $@

I2C_DEVICEFILE = ../hdl/perio/i2cslave.xml


i2cslave_register.h: $(I2C_DEVICEFILE)
	$(GENSOC) -o i2cslave $<


## XXX Rebuild when changed:
../include/generated/autoconf.h: ../.config
	$(MAKE) -C .. silentoldconfig

bootstrap.o main.o i2c.o: $(DUTIES-y) ../include/generated/autoconf.h

i2c.o: i2cslave_register.h

main.bin: main.elf
	$(OBJCOPY) -O binary $< $@

main: main.elf
	$(OBJCOPY) \
		--set-section-flags .ext.text=NOLOAD,READONLY,CODE \
		--set-section-flags .ext.rodata=NOLOAD,READONLY,DATA \
	$< $@ 
		

main.hex: main.elf
	$(OBJCOPY) -O ihex $< $@

$(ROM_DATA_TABLES): main
	$(ROMGEN) $< $(ARCH)

$(ROMFILE): $(MEM_INIT) $(ROM_DATA_TABLES)
	cpp -P -o $@ -D__VHDL__ -DARCH=$(ARCH) $<

bm_%.o: bm_%.c
	$(CC) -o $@ -c $< # \
	#	-DSECTION_ATTRIBUTE='__attribute__((section(".ext.rodata")))'

spicache.o: spicache.c
	$(CC) -c -o $@ $(CFLAGS) -O3 $<

bootstrap.o: bootstrap.c
	$(CC) -c -o $@ $(CFLAGS) -Os $<

# Platform specific source build rule:
%.o: plat/$(PLATFORM)/%.c
	$(CC) -c -o $@ $(CFLAGS) $<

bm_%.c: ../contrib/bitmaps/%.pnm
	python ../contrib/bitmaps/chartbl.py -r $<
	mv ../contrib/bitmaps/$*.c $@

flashdata.bin: main.elf
	$(FWGEN) $< $@

crt%.o: arch/$(ARCH)/crt%.s
	$(CC) -c $(ASMFLAGS) -o $@ $<

crt%.elf: arch/neo430/crt%.asm
	$(AS) -o $@ $< -mY 

clean::
	rm -f $(OBJS) $(DUTIES-y) $(BSPLIBOBJS-y) 
	rm -f main main.bin *.tmp rom_generated.vhd

mrproper: clean
	rm -f libbsp-$(PLATFORM).a

soc_mmr.gdb: $(DEVICEFILE)
	$(GENSOC) -o soc -g -M 1 $<

efb_mmr.gdb: efb.xml gdbscript.xsl
	$(XP) -o $@ \
		--param useMapPrefix 1 \
		--param lsb_shift 2 \
		--param convertBitfields 1 \
		gdbscript.xsl $<

mmr.gdb: $(DEVICEFILE) gdbscript-$(ARCH).xsl
	$(XP) -o mmr.gdb \
		--param useMapPrefix 1 \
		--param convertBitfields 1 \
		gdbscript-$(ARCH).xsl $<

%.lst: %.elf
	$(OBJDUMP) -S $< >$@

%.lst: %.o
	$(OBJDUMP) -S $< >$@

%.S: %.c
	$(CC) -o $@ -S $(CFLAGS) $< # \

show:
	@echo LDFLAGS = $(LDFLAGS)
	@echo $(DUTIES-y)

ABS_DISTFILES = $(patsubst $(TOPDIR)/%, %,$(DISTFILES))

dist: $(DISTFILES)
	@rsync -aqR $(ABS_DISTFILES) $(DISTDIR)/sw
	
.PHONY: lib dist show
