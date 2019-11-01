
MASOCIST = src/vhdl/masocist-opensource

include config.mk

SIM_EXECUTABLE = $(MASOCIST)/sim/net_virtual_neo430

$(SIM_EXECUTABLE):
	$(MAKE) -C $(MASOCIST) virtual_neo430-main
	$(MAKE) -C $(MASOCIST)/sim clean all

all: $(SIM_EXECUTABLE)

export GHDLEX

run: $(SIM_EXECUTABLE)
	sh recipes/scripts/run-neo430.sh $(notdir $<)

test: $(SIM_EXECUTABLE)
	sh recipes/scripts/test-neo430.sh $(notdir $<)

clean:
	rm -f $(MASOCIST)/.config $(SIM_EXECUTABLE)
