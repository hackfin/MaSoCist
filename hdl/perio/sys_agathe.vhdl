-- System control
-- Author: <hackfin@section5.ch>
--
-- WARNING: The license for this MaSoCist distribution
--          DOES NOT allow you to alter this file. You have to request
--          a new board supply package and register a name.
--
-- The system specific control core
-- This contains:
-- * Pin muxing
-- * Autodetection variables

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.global_config.all;
	use work.system_map.all;

entity sys_core is
	generic (NUM_IRQ : natural := 16);
	port (
		ctrl : in  sys_WritePort;
		stat : out sys_ReadPort;


		clk      : in std_logic
	);
end entity;

architecture behaviour of sys_core is
begin

	stat.magic <= unsigned(CONFIG_TAP_ID); -- Mirror CPU id
	stat.socrev <= x"1"; -- Soc revision code
	stat.cpuarch <= to_unsigned(SOCINFO_CPU_TYPE, 4);
	stat.config_id <= x"0000"; -- Experimental agathe code
	stat.rev_major <= to_unsigned(HWREV_system_map_MAJOR, 8);
	stat.rev_minor <= to_unsigned(HWREV_system_map_MINOR, 8);


end architecture;
