
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
	use work.system_map.all;

entity tmr_core is
	port (
		clk    : in std_logic
	);
end tmr_core;

architecture behaviour of tmr_core is

	signal counter  : unsigned(16-1 downto 0) := (others => '0');
	-- signal enable   : std_logic;

	signal outp     : std_logic := '0';
	signal default  : std_logic;

begin

	default <= ctrl.default;

	output <= outp;


	process (clk)
	begin
		if rising_edge(clk) then
		end if;
	end process;


end behaviour;
