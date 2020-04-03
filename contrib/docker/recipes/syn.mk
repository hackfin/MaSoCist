
MASOCIST = src/vhdl/masocist-opensource

SVFFILE = $(MASOCIST)/syn/versa_ecp5.svf

$(SVFFILE):
	$(MAKE) -C $(MASOCIST) versa_ecp5-zpu-ghdlsynth
	$(MAKE) -C $(MASOCIST) sw syn


test: $(SVFFILE)

clean:
	rm -f $(MASOCIST)/.config $(SVFFILE)

