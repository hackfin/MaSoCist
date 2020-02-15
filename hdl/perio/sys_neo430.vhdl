-- System control
-- Author: <hackfin@section5.ch>
--
-- WARNING: The license permission for this MaSoCist distribution
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
	port (
		ctrl      : in  sys_WritePort;
		stat      : out sys_ReadPort;

		clk       : in std_logic
	);
end entity;

architecture behaviour of sys_core is

begin

	stat.magic <= x"aa55"; -- No CPU ID
	stat.soctype <= x"1"; -- Soc type code
	stat.console_data <= (others => '0');
	stat.data_valid <= '0';
	stat.cpuarch <= to_unsigned(SOCINFO_CPU_TYPE, 4);
	stat.cpuflags <= "00000001"; -- Experimental XXX
	-- stat.rev_reserved <= x"ff00"; -- Experimental
	stat.rev_major <= to_unsigned(HWREV_system_map_MAJOR, 8);
	stat.rev_minor <= to_unsigned(HWREV_system_map_MINOR, 8);

	-- Just forward these, we use a software 'select' in this case:


-- mux_gpio:
-- 	for i in 0 to 15 generate
-- 		pin_gpio(i) <= pri_io(i) when ctrl.pin_mux(i) = '0'
-- 		               else alt_in(i);
-- 	end generate;

end architecture;
