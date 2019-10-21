-- Virtual direct Remote TAP
--
-- (c) 2013, Martin Strubel <hackfin@section5.ch>

-- This is the direct TAP without JTAG, using the VirtualBus entity
-- for direct remote register access.
--
--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.vtap.all; -- CORE TAP register config
	use work.stdtap.all;

library ghdlex;
	use ghdlex.ghpi_netpp.all;
	use ghdlex.virtual.all;

entity VirtualTAP_Direct is
	generic (
		 EMUDAT_SIZE        : natural := 32; -- Dummy
		 EMUIR_SIZE         : natural := 32; -- Dummy
		 INS_NOP            : unsigned(32-1 downto 0); -- Dummy
		 IDCODE             : unsigned(32-1 downto 0)  := x"00000000";
		 USE_GLOBAL_CLK     : boolean := false;
		 TCLK_PERIOD        : time := 40 ns
	);
	port (
		-- Core <-> TAP signals:
		tin         : in  tap_in_rec;
		tout        : out tap_out_rec
	);
end entity VirtualTAP_Direct;

architecture simulation of VirtualTAP_Direct is
	-- DirectTAP signals

	constant THROTTLE_LATENCY : natural := 200;  -- No activity latency
	-- constant PIPE_SIZE : natural := 200;  -- Latency delay pipe
	constant VBUS_ADDR_W : natural := 5;

	signal clk      : std_logic := '0';

	signal throttling   : std_logic;

	signal tap_ce   : std_logic;
	signal tap_ctrl : tap_registers_WritePort;
	signal tap_stat : tap_registers_ReadPort;
	-- VirtualBus:
	signal vbus_wr   : std_logic;
	signal vbus_rd   : std_logic;
	signal vbus_din  : std_logic_vector(31 downto 0) := (others => '0');
	signal vbus_dout : unsigned(31 downto 0) := (others => '0');
	signal vbus_addr : std_logic_vector(VBUS_ADDR_W-1 downto 0)
		:= (others => '0');

begin

	-- Generate internal clock for virtual TAP:

global_clock:
if USE_GLOBAL_CLK generate
	clk <= global_dbgclk;
end generate;

local_clock:
if not USE_GLOBAL_CLK generate
	clk <= not clk after TCLK_PERIOD/2;
end generate;

	tout.tapclk      <= clk;
	tout.emuir       <= tap_ctrl.tap_emuir;
	tout.core_reset  <= tap_ctrl.core_reset;
	tout.emumask     <= tap_ctrl.emumask;
	tout.emurequest  <= tap_ctrl.emureq;
	tout.emuexec     <= tap_ctrl.emuexec;
	tout.reg         <= tap_ctrl.select_reg;

	tap_stat.tap_idcode   <= IDCODE;
	tap_stat.tap_emudata  <= tin.emudata;
	tap_stat.emuack       <= tin.emuack;
	tap_stat.emurdy       <= tin.emurdy;
	tap_stat.core_spec    <= tin.exstat;
	tap_stat.tap_emupc    <= tin.dbgpc;


virtual_bus:
	VirtualBus
	generic map ( ADDR_W => VBUS_ADDR_W, NETPP_NAME => "Vtap",
		BUSTYPE => BUS_GLOBAL )
	port map (
		clk         => clk,
		wr          => vbus_wr,
		rd          => vbus_rd,
		wr_busy     => '0',
		rd_busy     => '0',
		addr        => vbus_addr,
		data_in     => vbus_din,
		data_out    => std_logic_vector(vbus_dout)
	);

	tap_ce <= vbus_wr or vbus_rd;

registers:
	-- We use our own TAP decoder:
	entity work.decode_tap_registers
	generic map ( DATA_WIDTH => 32 )
	port map (
		ce       => tap_ce,
		ctrl     => tap_ctrl,
		stat     => tap_stat,
		data_in  => unsigned(vbus_din),
		data_out => vbus_dout,
		addr     => unsigned(vbus_addr(BV_MMR_CFG_tap_registers)),
		re       => vbus_rd,
		we       => vbus_wr,
		clk      => clk
	);

slowdown:
	process(clk)
		variable latencycounter : integer := 0;
	begin
		if rising_edge(clk) then
			if tap_ce = '1' then
				latencycounter := 0;
			else
				latencycounter := latencycounter + 1;
			end if;
			-- Set remotely:
			-- netpp localhost SimThrottle <value>
			if latencycounter > THROTTLE_LATENCY
					and tap_ctrl.sim_throttle = '1' then
				throttling <= '1';
				usleep(to_integer(unsigned(tap_ctrl.sim_sleepcycles)));
			else
				throttling <= '0';
			end if;

		end if;
	end process;

end simulation;
