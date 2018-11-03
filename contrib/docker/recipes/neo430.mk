
MASOCIST = src/vhdl/masocist-opensource

$(MASOCIST)/.config:
	$(MAKE) -C $(MASOCIST) virtual_neo430-main

$(MASOCIST)/sim/tb_virtual_neo430: $(MASOCIST)/.config
	$(MAKE) -C $(MASOCIST)/sim all

all: $(MASOCIST)/sim/tb_virtual_neo430
	sh recipes/scripts/run-neo430.sh virtual_neo430
	# FIXME: Add to Masocist regression tests, backport to opensource
