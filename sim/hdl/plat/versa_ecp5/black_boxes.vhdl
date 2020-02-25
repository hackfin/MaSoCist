-- Black boxes for Simulation

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

-- GHDLSYNTH_QUIRK: We have to use a 'spi_mclk_dummy' to prevent
-- component from being optimized away (two inputs, no output)
component usrmclk_wrapper is
  port (
    usrmclki :   in  std_logic;
    usrmclkts :   in  std_logic;
    spi_mclk_dummy :   out  std_logic  );
end component;



end bb_components;

