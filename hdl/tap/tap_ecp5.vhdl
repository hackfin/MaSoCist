-- Lattice ECP5 standard TAP implementation
--
-- (c) 2017, Martin Strubel <hackfin@section5.ch>

-- Implements the "Standard TAP" for Lattice ECP5 devices
-- Note: input signals are NOT clock buffered. The user is responsible
-- for proper clock domain decoupling.

-- This TAP is supported by the libuniemu library.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TAP register definitions:
library work;
	use work.stdtap.all;
	use work.hwtap.all;
	use work.tap_jtag_lattice.all;
	use work.bb_components.all;


entity ECP5_TAP is
	generic (
		 -- The IDCODE is just kept here for interface compatibility
		 -- For ECP5 platforms, it is specified in the .lpf file
		 IDCODE      : std_logic_vector(32-1 downto 0)  := x"00000000"
	);
	port (
		reset       : in  std_logic;
		-- JTAG signals (dedicated pins on ECP5)
		tck         : in  std_logic;
		tms         : in  std_logic;
		tdi         : in  std_logic;
		tdo         : out std_logic;
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end ECP5_TAP;

architecture behaviour of ECP5_TAP is

	constant ER1_SIZE  : natural := EMUCTRL_SIZE;
	constant ER2_SIZE  : natural := EMUDAT_SIZE;

	-- constant SEL_EMUIR   : std_logic_vector(2 downto 0) := EMUIR(2 downto 0);

	signal itck      : std_logic;

	attribute syn_isclock : boolean;
	attribute syn_isclock of itck : signal is true;

	signal tdo1     : std_logic;
	signal tdo2     : std_logic;
	signal rti1     : std_logic;
	signal rti2     : std_logic;
	signal itdi     : std_logic;
	signal shift    : std_logic;
	signal update   : std_logic;
	-- JTAG TRST signals (from JTAG FSM)
	signal jtag_reset    : std_logic;
	signal jtag_resetn   : std_logic;

	signal ce1      : std_logic;
	signal ce2      : std_logic;

	signal emustat      : unsigned(EMUCTRL_SIZE-1 downto 0);
	signal std_r_emuctrl    : std_logic_vector(EMUCTRL_SIZE-1 downto 0);
	signal r_emuctrl    : unsigned(EMUCTRL_SIZE-1 downto 0);
	signal r_emudata    : emudata_t;
	signal emudata_mux  : emudata_t;

	signal rsel         : regaddr_t;

begin

----------------------------------------------------------------------------
-- JTAG register logic

glue:
	TAP_Lattice_Glue
	port map (
		itck         => itck,
		itdi         => itdi,
		tdo1         => tdo1,
		tdo2         => tdo2,
		reset        => jtag_reset,
		shift        => shift,
		update       => update,
		ce1          => ce1,
		ce2          => ce2,
		emuctrl      => std_r_emuctrl,
		emustat      => std_logic_vector(emustat),
		emudata_i    => emudata_mux,
		emudata_o    => r_emudata
	);

	r_emuctrl <= unsigned(std_r_emuctrl);

jtag_port:
	jtag_wrapper
	port map (
		tck          => tck,
		tms          => tms,
		tdi          => tdi,
		jtdo2        => tdo2,
		jtdo1        => tdo1,
		tdo          => tdo,
		jtdi         => itdi,
		jtck         => itck,
		jrti2        => rti2,
		jrti1        => rti1,
		jshift       => shift,
		jupdate      => update,
		jrstn        => jtag_resetn,
		jce2         => ce2,
		jce1         => ce1
	);

	jtag_reset <= (not jtag_resetn) or reset;

	-- These are all somewhat static signals
	emustat <= tin.exstat & "0000"  & "00" & tin.emurdy & tin.emuack;

	rsel <= "00000" & unsigned(r_emuctrl(BV_SELREG));

	with rsel select
		emudata_mux <= tin.count   when R_SELECT_COUNT,
		               tin.dbgpc   when R_SELECT_DBGPC,
		               tin.emudata when R_SELECT_EMUDATA,
		               x"00000010" when R_SELECT_TAPCAPS,
		               x"deadbeef" when others;

	tout.tapclk     <= itck;
	tout.reg        <= r_emuctrl(BV_SELREG);
	tout.craddr     <= (others => '0');

	tout.emurequest <= r_emuctrl(B_EMUREQ);
	tout.emumask    <= r_emuctrl(B_EMUMASK);
	tout.emudata    <= r_emudata;
	tout.emuexec    <= rti2 or rti1;
	tout.jtag_reset <= jtag_reset;
	tout.core_reset <= r_emuctrl(B_CORE_RESET);
	-- EMUIR register does not exist on this TAP, it is multiplexed
	-- with the EMUDATA register
	tout.emuir      <= r_emudata;

end behaviour;
