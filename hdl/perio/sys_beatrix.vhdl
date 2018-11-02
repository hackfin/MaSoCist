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
	port (
		ctrl      : in  sys_WritePort;
		stat      : out sys_ReadPort;

		clk       : in std_logic
	);
end entity;

architecture behaviour of sys_core is

    function stdl (arg: boolean) return std_logic is
    begin
        if arg then
            return '1';
        else
            return '0';
        end if;
    end function stdl;

begin

	stat.magic <= unsigned(CONFIG_TAP_ID); -- Mirror CPU id
	stat.socrev <= x"1"; -- Soc type code
	stat.cpuarch <= to_unsigned(SOCINFO_CPU_TYPE, 4);
	stat.cpuflags <= "000000";
	stat.have_dcache <= stdl(CONFIG_SCACHE);
	stat.have_icache <= stdl(CONFIG_SCACHE_INSN);
	stat.config_id <= x"0001"; -- Experimental beatrix code
	stat.rev_major <= to_unsigned(HWREV_system_map_MAJOR, 8);
	stat.rev_minor <= to_unsigned(HWREV_system_map_MINOR, 8);

maybe_crc16:
	if CONFIG_CRC16 generate
	crc16_core: entity work.crc16
	port map (
		clk    => clk,
		set    => ctrl.select_crc16_valueinit,
		val    => ctrl.crc16_valueinit,
		res    => stat.crc16_value,
		en     => ctrl.select_crc16_data,
		data   => ctrl.crc16_data
	);

	end generate;

-- mux_gpio:
-- 	for i in 0 to 15 generate
-- 		pin_gpio(i) <= pri_io(i) when ctrl.pin_mux(i) = '0'
-- 		               else alt_in(i);
-- 	end generate;

end architecture;
