-- Generic Test Access Port (TAP) library
--
-- (c) 2012, 2013, Martin Strubel <hackfin@section5.ch>
--
--
-- --NDAREQ--
--
-- Note: All 'next generation' HW specific TAPs are found in
-- libhwtap_<vendor>.vhdl where vendor can be of [xilinx, lattice, flix]

library IEEE;
use IEEE.std_logic_1164.all;

package stdtap is

	constant EMUCTRL_SIZE  : natural := 16;
	constant EMUDAT_SIZE   : natural := 32;
	constant EMUIR_SIZE    : natural := 32;

	-- Some auxiliary data types:
	subtype  REG_SIZE3 is integer range 2 downto 0;
	subtype  REG_SIZE16 is integer range 15 downto 0;
	subtype  REG_SIZE32 is integer range 31 downto 0;

	subtype emudata_t  is std_logic_vector(EMUDAT_SIZE-1 downto 0);
	subtype emucount_t is std_logic_vector(32-1 downto 0);
	subtype emuir_t    is std_logic_vector(EMUIR_SIZE-1 downto 0);

	type tap_out_rec is record
		tapclk    	: std_logic; --! TAP clock (must exist for PulseStrobe)
		jtag_reset	: std_logic; --! Reset from JTAG logic
		core_reset	: std_logic; --! Reset core logic
		emuexec		: std_logic; --! Execute opcode on rising edge
		emumask   	: std_logic; --! Emulation microcode mask bit
		emurequest	: std_logic; --! Emulation request to core
		emudata     : emudata_t; --! Emulation data I/O register
		emuir       : emuir_t;   --! Emulation instruction
		reg         : std_logic_vector(2 downto 0); --! Register select
	end record;

	type tap_in_rec is record
		emuack		: std_logic;  --! Core has acknowledged EMULATION request
		emurdy		: std_logic;  --! Core ready to execute next instruction
		break     	: std_logic;  --! Core has run into a BREAK condition
		emudata  	: emudata_t;  --! Emulation data I/O register
		count 	    : emucount_t; --! Custom counter register
		--! Extra status bits, core dependent
		exstat		: std_logic_vector(7 downto 0);
		--! PC of possibly running core. Allows to access PC without
		--! entering emulation. Not on all systems.
		dbgpc		: emudata_t;
	end record;

	constant TAP_IN_REC_NULL : tap_in_rec := tap_in_rec'(
		'0', '0', '0', (others => '0'), (others => '0'), (others => '0'),
		(others => '0')
	);

	------------------------------------------------------------------------
	-- Generic Test Access Port
	-- This is a hardware and software independent wrapper for various
	-- TAP implementations, such as the Xilinx BSCAN primitive based TAP or
	-- the section5 VirtualTAP.

	component GenericTAP is
		generic (EMUDAT_SIZE : natural := 32;
				 EMUIR_SIZE  : natural := 32;
				 IDCODE      : std_logic_vector(32-1 downto 0) := x"deadbeef";
				 INS_NOP     : std_logic_vector(32-1 downto 0) := x"00000000"
		);
		port (
			-- JTAG signals:
			tck, trst, tms, tdi : in std_logic;
			tdo                 : out std_logic;
			-- Core <-> TAP signals:
			tin                 : in  tap_in_rec;
			tout                : out tap_out_rec
		);
	end component;

	-- New virtual TAP
	component VirtualTAP_JTAG is
		generic (
			EMUDAT_SIZE    : natural := 32;
			EMUIR_SIZE     : natural := 32;
			IDCODE         : std_logic_vector(32-1 downto 0) := x"deadbeef";
			INS_NOP        : std_logic_vector(32-1 downto 0) := x"00000000";
			USE_GLOBAL_CLK : boolean := false;
			TCLK_PERIOD    : time    := 40 ns
		);
		port (
			-- Core <-> TAP signals:
			tin                 : in  tap_in_rec;
			tout                : out tap_out_rec
		);
	end component;

	-- Virtual Direct TAP without JTAG emulation:
	-- Note: The register definitions of this TAP are currently generated
	-- externally within ghdlsim.xml
	component VirtualTAP_Direct is
		generic (
			EMUDAT_SIZE : natural := 32; -- Dummy
			EMUIR_SIZE  : natural := 32; -- Dummy
			INS_NOP     : std_logic_vector(32-1 downto 0); -- Dummy
			IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000";
			USE_GLOBAL_CLK : boolean := false;
			TCLK_PERIOD : time := 40 ns
		);
		port (
			-- Core <-> TAP signals:
			tin         : in  tap_in_rec;
			tout        : out tap_out_rec
		);
	end component VirtualTAP_Direct;

----------------------------------------------------------------------------
-- LEGACY TAPS
-- DO NOT USE FOR NEW DESIGNS!
----------------------------------------------------------------------------

	component VirtualTAP is
		generic (
			EMUDAT_SIZE    : natural := 32;
			EMUIR_SIZE     : natural := 32;
			IDCODE         : std_logic_vector(32-1 downto 0)  := x"deadbeef";
			INS_NOP	       : std_logic_vector(32-1 downto 0)  := x"00000000";
			TCLK_PERIOD    : time := 40 ns
		);
		port (
			core_reset	: out std_logic; -- Reset core logic
			emuexec		: out std_logic; -- Execute opcode on rising edge
			emurequest	: out std_logic; -- Emulation request to core
			emuack		: in std_logic;  -- Core has acknowledged EMULATION request
			emurdy		: in std_logic; -- Core ready to execute next instruction
			pulse		: in std_logic; -- Pulse event counter
			dbgpc		: in std_logic_vector(EMUDAT_SIZE-1 downto 0); -- PC
			exstat		: in std_logic_vector(7 downto 0);
			emudata_i	: in std_logic_vector(EMUDAT_SIZE-1 downto 0);
			emudata_o	: out std_logic_vector(EMUDAT_SIZE-1 downto 0);
			emuir		: out std_logic_vector(EMUIR_SIZE-1 downto 0)
		);

	end component VirtualTAP;

----------------------------------------------------------------------------
-- LEGACY components:

	------------------------------------------------------------------------
	-- Our StdTAP entity. This is a somewhat generic TAP that is vendor
	-- independent, therefore uses user defined JTAG pins on the hardware.
	-- Also, this is the "ASIC style"

    component StdTestAccessPort
		generic (EMUDAT_SIZE : natural := 32;
				 EMUIR_SIZE  : natural := 32;
				 IDCODE      : std_logic_vector(32-1 downto 0) := x"deadbeef";
				 INS_NOP     : std_logic_vector(32-1 downto 0) := x"00000000"
		);
		port (
			tck, trst, tms, tdi : in std_logic;
			tdo                 : out std_logic;
			core_reset  : out std_logic; -- Reset core logic
			emuexec     : out std_logic; -- Execute opcode on rising edge
			emurequest  : out std_logic; -- Emulation request to core
			emuack      : in std_logic; -- Core has acknowledged EMULATION request
			emurdy      : in std_logic; -- Core ready to execute next instruction
			pulse       : in std_logic; -- event counter
			-- Program Counter without going to emulation.
			dbgpc       : in std_logic_vector(EMUDAT_SIZE-1 downto 0);
			exstat      : in std_logic_vector(7 downto 0);

			emudata_i   : in std_logic_vector(EMUDAT_SIZE-1 downto 0);
			emudata_o   : out std_logic_vector(EMUDAT_SIZE-1 downto 0);
			-- emudat_wr   : in std_logic;
			-- emudat_rd   : in std_logic;
			emuir       : out std_logic_vector(EMUIR_SIZE-1 downto 0)
		);
    end component;

	------------------------------------------------------------------------
	-- Xilinx Spartan6 specific Test Access Port

    component Spartan6_TAP
		generic (EMUDAT_SIZE : natural := 32;
				 EMUIR_SIZE  : natural := 8;
				 INS_NOP     : std_logic_vector(8-1 downto 0)  := x"00"
		);
		port (
			core_reset  : out std_logic;
			emuexec     : out std_logic;
			emurequest  : out std_logic;
			emuack      : in std_logic;
			emurdy      : in std_logic;
			pulse       : in std_logic;
			-- Program Counter without going to emulation.
			dbgpc       : in std_logic_vector(EMUDAT_SIZE-1 downto 0);
			exstat      : in std_logic_vector(7 downto 0);

			emudata_i   : in std_logic_vector(EMUDAT_SIZE-1 downto 0);
			emudata_o   : out std_logic_vector(EMUDAT_SIZE-1 downto 0);
			emuir       : out std_logic_vector(EMUIR_SIZE-1 downto 0)
		);
    end component;

end package;

