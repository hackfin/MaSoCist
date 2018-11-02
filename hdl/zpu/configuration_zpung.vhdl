library ieee;
	use ieee.std_logic_1164.all;

library zpu;


configuration zpung of ZPU_SoC is
	use zpu.ZPUng_wrapper;

	for behaviour
		for zpucore : ZPUSmallCore
			use entity zpu.ZPUng_wrapper;
		end for;
	end for;

end zpung;

configuration tb_zpung of tb_breakout is
	use work.breakout_top;

	for sim
		for uut : breakout_top
			use configuration work.zpung;
		end for;
	end for;

end tb_zpung;
