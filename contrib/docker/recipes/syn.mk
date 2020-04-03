
MASOCIST = src/vhdl/masocist-opensource

SVFFILE = $(MASOCIST)/syn/versa_ecp5.svf

$(SVFFILE):
	$(MAKE) -C $(MASOCIST) sw syn


$(MASOCIST)/.config:
	$(MAKE) -C $(MASOCIST) versa_ecp5-zpu-ghdlsynth

all: $(MASOCIST)/.config

test: $(MASOCIST)/.config $(SVFFILE)

clean:
	rm -f $(MASOCIST)/.config $(SVFFILE)

