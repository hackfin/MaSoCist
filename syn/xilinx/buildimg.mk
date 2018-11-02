# Auxiliary rules to build/download image files

DATAFILE ?= flashdata.bin
DATA2MEM ?= $(XILINX_ISE_DIR)/ISE/bin/lin/data2mem
OBJCOPY  ?= zpu-elf-objcopy
STRIP    ?= zpu-elf-strip
PROG     ?= papilio-prog
IMG_EXT   = python $(TOPDIR)/utils/buildfw.py

PREFIX   ?= $(PROJECT)/$(PLATFORM)
WORK     ?= $(PROJECT)/$(PLATFORM)
SRCBITFILE ?= $(PROJECT)/$(PLATFORM)_top.bit

main: $(EXE)
	cp $< $@
	$(STRIP) $@

$(DATAFILE): $(EXE)
	$(IMG_EXT) $< $@

# Important: Make sure to copy all relevant sections
boot.elf: main
	$(OBJCOPY) \
		-j .fixed_vectors \
		-j .l1.text \
		-j .l2.text \
		-j .text \
		-j .data \
		-j .int.rodata \
		-j .int.data \
		-j .rodata \
		-j .rodata.str1.4 \
	$< $@ 

$(WORK)_fw.bit: $(SRCBITFILE) boot.elf
	$(DATA2MEM) -bd boot.elf \
	-bm $(CCAP_ARCHITECTURE)_bd.bmm -bt $< \
	-bx /tmp \
	-o b $@

$(WORK)_top_full.bit: $(WORK)_fw.bit $(DATAFILE)
	python $(TOPDIR)/contrib/bootstrap_sram_from_flash/bitmerge.py \
		$^ $@

%.bin: %.bit
	bitparse -i BIT $< -o BIN -O $@

image: $(WORK)_top_full.bit $(WORK)_top_full.bin


download: $(WORK)_fw.bit
	$(PROG) -f $<

verify: $(WORK)_top_full.bit
	$(PROG) -b $(BSCAN_SPIDRV) -s v -f $<

flash_bm: $(WORK)_fw.bit
	$(PROG) -b $(BSCAN_SPIDRV) -s a -f $<

flash_full: $(WORK)_top_full.bit
	$(PROG) -b $(BSCAN_SPIDRV) -s a -f $<


help:
	$(DATA2MEM) -h all


.PHONY: image download verify flash
