-- Some async/sync coupling primitives
--
-- (c) 11/2005, Martin Strubel <strubel@section5.ch>
--
--


library IEEE;
use IEEE.std_logic_1164.all;

package async is
-- TriggerPulse circuits:
-- These are needed to couple asynchronous trigger signals to
-- clk-synchronous circuits.

-- Derives a rising edge clock to a strobe pulse of duration of at least
-- one clk cycle. The 'strobe' output remains low until the next rising
-- edge of 'clk' occurs.

	component TriggerPulse
		port (
			trigger   : in std_logic;    -- Trigger input
			strobe    : out std_logic;   -- Strobe output
			ce        : in std_logic;    -- /CE
			clk       : in std_logic     -- Clock input
		);
	end component;

-- This version adds has an extra trigger output 'tout'.
-- The 'strobe' signal goes high immediately after a trigger rising edge.
-- It stays high until the next rising edge of 'clk'

	component TriggerPulseEx
		port (
			trigger   : in std_logic;    -- Trigger input
			strobe    : out std_logic;   -- Strobe output
			ce        : in std_logic;    -- /CE
			clk       : in std_logic     -- Clock input
		);
	end component;

-- This version uses 'ce' for reset - it always triggers, but strobe stays
-- high as long as hold is high
	component StrobePulse
		port (
			trigger   : in std_logic;    -- Trigger input
			strobe    : out std_logic;   -- Strobe output
			hold      : in std_logic;    -- hold
			clk       : in std_logic     -- Clock input
		);
	end component;


end package;


