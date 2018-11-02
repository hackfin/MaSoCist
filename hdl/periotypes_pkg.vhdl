
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.busdef.all;

package periotypes is
	subtype regaddr13_t is unsigned(15 downto 0);
	subtype regaddr16_t is unsigned(15 downto 0);

	component jpegmem_wrapper is
		port (
			pclk       : in  std_logic;
			lm_addr    : in  unsigned(5 downto 0);
			cm_addr    : in  unsigned(5 downto 0);
			lm_data    : out unsigned(15 downto 0);
			cm_data    : out unsigned(15 downto 0);

			ce         : in  std_logic;
			bus_in     : in  wb_WritePort;
			data_out   : out unsigned(16-1 downto 0);
			reset      : in  std_logic;
			clk        : in  std_logic
		);
	end component jpegmem_wrapper;

end periotypes;
