library ieee;
use ieee.std_logic_1164.all;

package bb_components is 

component pll_mac is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic; 
        CLKOS2: out  std_logic; 
        CLKOS3: out  std_logic; 
        LOCK: out  std_logic);
end component pll_mac;

component jtag_wrapper is
	port (
		tck, tms, tdi, jtdo2, jtdo1 : in std_logic := 'X';
		tdo, jtdi, jtck, jrti2, jrti1,
		jshift, jupdate, jrstn, jce2, jce1  : out std_logic := 'X'
	);
end component jtag_wrapper;

component gsr is
	port (
		reset : in std_logic := 'X'
	);
end component gsr;

----------------------------------------------------------------------------

-- GHDLSYNTH_QUIRK: We have to use a 'spi_mclk_dummy' to prevent
-- component from being optimized away (two inputs, no output)
component usrmclk_wrapper is
  port (
    usrmclki :   in  std_logic;
    usrmclkts :   in  std_logic;
    spi_mclk_dummy :   out  std_logic  );
end component;


end bb_components;

