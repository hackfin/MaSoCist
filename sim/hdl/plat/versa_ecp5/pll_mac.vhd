-- Emulated PLL, since ECP5 BSP does not include a simulation model

library IEEE;
use IEEE.std_logic_1164.all;

entity pll_mac is
    port (
        CLKI: in  std_logic; 
        CLKOP: out  std_logic; 
        CLKOS: out  std_logic; 
        CLKOS2: out  std_logic; 
        CLKOS3: out  std_logic; 
        LOCK: out  std_logic);
end pll_mac;

architecture Structure of pll_mac is

--    attribute FREQUENCY_PIN_CLKOS2 of PLLInst_0 : label is "50.000000";
--    attribute FREQUENCY_PIN_CLKOS of PLLInst_0 : label is "25.000000";
--    attribute FREQUENCY_PIN_CLKOP of PLLInst_0 : label is "125.000000";
--    attribute FREQUENCY_PIN_CLKI of PLLInst_0 : label is "100.000000";

	signal clk50, clk25, clk125 : std_logic := '0';

	signal locked, start_locking : std_logic := '0';

begin

	clk50 <= not clk50 after 10 ns;
	clk25 <= not clk25 after 20 ns;
	clk125 <= not clk125 after 4 ns;

	CLKOP <= clk125 when start_locking = '1' else 'X';
	CLKOS <= clk25 when start_locking = '1' else 'X';
	CLKOS2 <= clk50 when start_locking = '1' else 'X';

lockit:
	process
	begin
		wait for 1 us;
		start_locking <= '1';
		wait for 200 ns;
		locked <= '1';
		wait;
	end process;

	lock <= locked;

end architecture;
