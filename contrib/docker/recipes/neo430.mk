
MASOCIST = src/vhdl/masocist-opensource

SIM_EXECUTABLE = $(MASOCIST)/sim/net_virtual_neo430

$(SIM_EXECUTABLE):
	$(MAKE) -C $(MASOCIST) virtual_neo430-main
	$(MAKE) -C $(MASOCIST)/sim clean all

all: $(SIM_EXECUTABLE)

run: $(SIM_EXECUTABLE)
	sh recipes/scripts/run-neo430.sh $(notdir $<) GHDLEX=$(GHDLEX)

test: $(SIM_EXECUTABLE)
	sh recipes/scripts/test-neo430.sh $(notdir $<) GHDLEX=$(GHDLEX)

clean:
	rm -f $(MASOCIST)/.config $(SIM_EXECUTABLE)
