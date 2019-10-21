MASOCIST = src/vhdl/masocist-opensource

$(MASOCIST)/.config:
	$(MAKE) -C $(MASOCIST) virtual_riscv-main

$(MASOCIST)/sim/tb_virtual_riscv: $(MASOCIST)/.config
	$(MAKE) -C $(MASOCIST)/sim all

all: $(MASOCIST)/sim/net_virtual_riscv

test: $(MASOCIST)/sim/net_virtual_riscv
	sh recipes/scripts/test-pyrv32.sh

clean:
	rm -f $(MASOCIST)/.config
