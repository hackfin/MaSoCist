------------------------------------------------
-- Prototyping playground
-- (c) 2012-2013, Martin Strubel // hackfin@section5.ch
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
--  System map definitions:
	use work.system_map.all; -- XXX Please edit


entity playground_core is
	generic (NUM_BITS : natural := 8);
	port (
		-- Port export for pgio pseudo register
		pout             : out    std_logic;
		-- mode             : out    std_logic_vector((1+3-0) - 1 downto 0);

		ctrl      : in  playground_WritePort;
		stat      : out playground_ReadPort;

		clk       : in std_logic
	);
end entity playground_core;


architecture behaviour of playground_core is
	signal test_sig  : unsigned(NUM_BITS-1 downto 0);
begin

	pout <= '1' when ctrl.test_mode = "1000" else '0';

end architecture;
