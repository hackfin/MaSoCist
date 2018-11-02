library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.stdtap.all;

entity MachXO2_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For MACHXO2 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		-- JTAG signals (dedicated pins on MACHXO2)
		reset       : in  std_logic;
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end MachXO2_TAP;

architecture sim of MachXO2_TAP is

begin

	process
	begin
		tout.emurequest <= '0';
		tout.core_reset <= '0';
		wait for 5 us;
		tout.core_reset <= '1';
		wait for 1 us;
		tout.core_reset <= '0';
		wait;
	end process;

end sim;

----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.stdtap.all;

entity ECP3_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For ECP3 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		-- JTAG signals (dedicated pins on ECP3)
		reset       : in  std_logic;
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end ECP3_TAP;

architecture sim of ECP3_TAP is

begin

	process
	begin
		tout.emurequest <= '0';
		tout.core_reset <= '0';
		wait for 5 us;
		tout.core_reset <= '1';
		wait for 1 us;
		tout.core_reset <= '0';
		wait;
	end process;

end sim;
----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.stdtap.all;

entity ECP5_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For ECP3 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		reset       : in  std_logic;
		-- JTAG signals (dedicated pins on ECP3)
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end ECP5_TAP;

architecture sim of ECP5_TAP is

begin

	process
	begin
		tout.emurequest <= '0';
		tout.core_reset <= '0';
		wait for 5 us;
		tout.core_reset <= '1';
		wait for 1 us;
		tout.core_reset <= '0';
		wait;
	end process;

end sim;

----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.stdtap.all;

entity Spartan3_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For ECP3 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		-- JTAG signals (dedicated pins on ECP3)
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end Spartan3_TAP;

architecture sim of Spartan3_TAP is

begin

	process
	begin
		tout.emurequest <= '0';
		tout.core_reset <= '0';
		wait for 5 us;
		tout.core_reset <= '1';
		wait for 1 us;
		tout.core_reset <= '0';
		wait;
	end process;

end sim;

----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.stdtap.all;

entity Spartan6_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For ECP3 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		-- JTAG signals (dedicated pins on ECP3)
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end Spartan6_TAP;

architecture sim of Spartan6_TAP is

begin

	process
	begin
		tout.emurequest <= '0';
		tout.core_reset <= '0';
		wait for 5 us;
		tout.core_reset <= '1';
		wait for 1 us;
		tout.core_reset <= '0';
		wait;
	end process;

end sim;


