-- Async wait state I/O decoding
-- (c) 2011 Martin Strubel <hackfin@section5.ch>
--
-- SOC I/O map


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.busdef.all;
	use work.system_map.all;


entity soc_periomap is
	generic (ADDR_W  : natural := 8);
	port (
		-- CPU side:
		clk       : in std_logic;
		cs        : in std_logic;
		reset     : in std_logic;
		cpu_bus_w : in zpu_WritePort;
		cpu_bus_r : out zpu_ReadPort;

		-- I/O side:
		io_gp     : out unsigned(7 downto 0)  -- GP outputs (LED)
	);

end soc_periomap;

architecture behaviour of soc_periomap is

begin
end behaviour;
