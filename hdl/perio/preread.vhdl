-- Preread mini interface for FIFOs with pre-READ_ENABLE requirement.
--
--
-- Fall-through FIFO types present data at the output immediately:

--          __    __    __    __    __    __ 
-- CLK   __/  \__/  \__/  \__/  \__/  \__/  \
--                 _____
-- RDEN   ________/     \__________
--
-- DATA   -----0-------X-----1--------

----------------------------------------------------------------------------
-- Lattice style FIFOs need a pulse beforehand:

--          __    __    __    __    __    __ 
-- CLK   __/  \__/  \__/  \__/  \__/  \__/  \
--                 _____        _____
-- RDEN   ________/     \______/     \______
--
-- DATA   UUUUUUUUUUUUUX-----0-----X-----1-----


-- The preread logic describes a simple interface between the latter FIFO
-- style and a reader which expects a fall-through.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity preread is
	generic (
		DATA_W : natural  := 8
	);
	port (
		empty_i   : in     std_logic;
		ready_o   : out    std_logic;
		next_i    : in     std_logic;
		rden_o    : out    std_logic;
		clk       : in     std_logic
	);
end entity;

architecture behaviour of preread is
	signal ready : std_logic := '0';
begin

	process(clk)
	begin
		if rising_edge(clk) then
			if empty_i = '0' then
				if ready = '0' or next_i = '1' then
					rden_o <= '1';
					ready <= '1';
				else
					rden_o <= '0';
				end if;
			elsif next_i = '1' then
				rden_o <= '0';
				ready <= '0';
			else
				rden_o <= '0';
			end if;
		end if;
	end process;
	
	ready_o <= ready;


end behaviour;
