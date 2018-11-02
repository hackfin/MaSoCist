library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkdrv is
	port (
		iclk          : in std_logic;
		invert        : in std_logic;
		enable        : in std_logic;
		oclk          : out std_logic
	);
end clkdrv;

architecture behaviour of clkdrv is
	
begin
	
	oclk <= (iclk xor invert) and enable;

end behaviour;
