-- Virtual direct Remote TAP Dummy
--
-- (c) 2015, Martin Strubel <hackfin@section5.ch>

--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.stdtap.all;

entity VirtualTAP_Direct is
	generic (
		 EMUDAT_SIZE        : natural := 32; -- Dummy
		 EMUIR_SIZE         : natural := 32; -- Dummy
		 INS_NOP            : std_logic_vector(32-1 downto 0); -- Dummy
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000";
		 USE_GLOBAL_CLK     : boolean := false;
		 TCLK_PERIOD : time := 40 ns
	);
	port (
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end entity VirtualTAP_Direct;

architecture simulation of VirtualTAP_Direct is
	-- DirectTAP signals
begin

end simulation;
