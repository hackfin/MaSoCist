-- Stupid CRC16 module for some communication speedups:
-- Author: <hackfin@section5.ch>


library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity crc16 is
	port (
		clk    : in std_logic;
		set    : in std_logic;
		val    : in unsigned(15 downto 0);
		res    : out unsigned(15 downto 0);
		en     : in std_logic;
		data   : in unsigned(7 downto 0)
	);
end entity;

architecture behaviour of crc16 is
	signal crc16 : unsigned(15 downto 0);
begin

	process (clk)
		variable x : unsigned(7 downto 0);
		begin
		if rising_edge(clk) then
			if set = '1' then
				crc16 <= val;
			elsif en = '1' then
				x := crc16(15 downto 8) xor data;
				x := x xor ("0000" & x(7 downto 4));
				crc16 <= (crc16(7 downto 0)              &     "00000000") xor
				         (             x(3 downto 0)     & "000000000000") xor
				         ("000"      & x(7 downto 0)     &        "00000") xor
				         ("00000000" & x);
			end if;
		end if;
	end process;

	res <= crc16;

end architecture;
