library ghdlex;

configuration virtualram of jpegmem_wrapper is
	use ghdlex.VirtualDualPortRAM_dc;

	for behaviour
		for all : DPRAM_clk2
			use entity VirtualDualPortRAM_dc;
		end for;
	end for;
end virtualram;


