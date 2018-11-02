
----------------------------------------------------------------------------
-- utilies and reusable circuits
-- 
-- $Id: utils.vhdl 3 2006-06-22 23:38:38Z strubi $
--
-- (c) 2006
-- Martin Strubel // <hackfin@section5.ch>
----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- Creates a 1 clk cycle wide pulse from an asynchronous external
-- trigger from another clock domain

entity PulseStrobe is
	generic ( DEFAULT_OUT : std_logic := '0' );

	port (
		trigger   : in std_logic;    -- Trigger input
		strobe    : out std_logic;   -- Strobe output
		ce        : in std_logic;    -- /CE
		clk       : in std_logic     -- Clock input
	);

end PulseStrobe;
	
architecture behaviour of PulseStrobe is
	signal set      : std_logic := DEFAULT_OUT;
	signal reset    : std_logic;
	signal outp     : std_logic := DEFAULT_OUT;

begin
	-- Normal flipflop that does Q = 1 when rising edge 'trigger'
	process (trigger, reset, ce)
	begin
		if reset = not DEFAULT_OUT then
			set <= DEFAULT_OUT;
		elsif rising_edge(trigger) and ce = '1' then
			set <= not DEFAULT_OUT;
		end if;
	end process;

	-- This flipflop does the clk-synchronous coupling and resets the
	-- above flipflop when 'set' = 1
	process (clk)
	begin
		if rising_edge(clk) then
			outp <= set;
		end if;
	end process;

	reset <= outp;
	strobe <= outp;

end behaviour;


