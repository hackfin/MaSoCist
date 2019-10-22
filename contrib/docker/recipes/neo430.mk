
MASOCIST = src/vhdl/masocist-opensource

SIM_EXECUTABLE = $(MASOCIST)/sim/net_virtual_neo430

$(MASOCIST)/.config:
	$(MAKE) -C $(MASOCIST) virtual_neo430-main

$(SIM_EXECUTABLE): $(MASOCIST)/.config
	$(MAKE) -C $(MASOCIST)/sim all

all: $(SIM_EXECUTABLE)

run: $(SIM_EXECUTABLE)
	sh recipes/scripts/run-neo430.sh virtual_neo430

test: $(SIM_EXECUTABLE)
	sh recipes/scripts/test-neo430.sh virtual_neo430

clean:
	rm -f $(MASOCIST)/.config
