# Makefile to generate bit files from code and external flash area

TOPDIR = ../../..

EXE ?= $(TOPDIR)/sw/main.elf 

PROJECT ?= shiney

FLASHDATA = flashdata.bin

include $(TOPDIR)/config.mk

DATA2MEM = $(XILINX_ISE_DIR)/ISE/bin/lin/data2mem
OBJCOPY  = zpu-elf-objcopy

all: $(PLATFORM)_top_full.bit

main: $(EXE)
	cp $< $@
	zpu-elf-strip $@

$(FLASHDATA): $(EXE)
	$(OBJCOPY) \
		-j .ext.text \
		-j .ext.rodata \
		-O binary $< $@

# Important: Make sure to copy all relevant sections
boot.elf: main
	$(OBJCOPY) \
		-j .fixed_vectors \
		-j .l1.text \
		-j .text \
		-j .data \
		-j .int.rodata \
		-j .int.data \
		-j .rodata \
		-j .rodata.str1.4 \
	$< $@ 

help:
	$(DATA2MEM) -h all

$(PLATFORM)_fw.bit: $(PROJECT)/$(PLATFORM)_top.bit boot.elf
	$(DATA2MEM) -bd boot.elf -bm beatrix_bd.bmm -bt $< \
	-bx /tmp \
	-o b $@

$(PLATFORM)_top_full.bit: $(PLATFORM)_fw.bit $(FLASHDATA)
	python $(TOPDIR)/contrib/bootstrap_sram_from_flash/bitmerge.py \
		$^ $@

download: $(PLATFORM)_fw.bit
	papilio-prog -f $<

flash: $(PLATFORM)_top_full.bit
	papilio-prog -b bscan_spi.bit -f $<

clean:
	rm -f main $(FLASHDATA)
