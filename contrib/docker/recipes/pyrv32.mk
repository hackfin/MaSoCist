MASOCIST = src/vhdl/masocist-opensource

SIM_EXECUTABLE = $(MASOCIST)/sim/net_virtual_riscv

TESTSUITE = src/EXTERN/riscv-tests

TESTSUITE_REPO = https://github.com/riscv/riscv-tests

$(MASOCIST)/.config:
	$(MAKE) -C $(MASOCIST) virtual_riscv-main

$(SIM_EXECUTABLE): $(MASOCIST)/.config
	$(MAKE) -C $(MASOCIST)/sim clean all

$(TESTSUITE):
	[ -e $(dir $@) ] || mkdir $(dir $@)
	cd $(dir $@) && \
	git clone $(TESTSUITE_REPO)

install-testsuite: $(TESTSUITE)

all: $(SIM_EXECUTABLE)

test: $(SIM_EXECUTABLE)
	sh recipes/scripts/test-pyrv32.sh

clean:
	rm -f $(MASOCIST)/.config
