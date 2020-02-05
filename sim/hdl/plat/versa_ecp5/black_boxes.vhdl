library ieee;
use ieee.std_logic_1164.all;

library ecp5um;
use ecp5um.components.all;

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


end bb_components;

