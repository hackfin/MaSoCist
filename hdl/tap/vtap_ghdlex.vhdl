-- Virtual direct Remote TAP Dummy
--
-- Wraps a standard ghdlsim entity with a Debug TAP interface
--
-- (c) 2015, Martin Strubel <hackfin@section5.ch>

--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library ghdlex;
	use ghdlex.virtual.all;
	use ghdlex.ghpi_netpp.all;
	use ghdlex.ghdlsim.all;

library work;
	use work.stdtap.all;

entity VirtualTAP_Direct is
	generic (
		 EMUDAT_SIZE        : natural := 32; -- Dummy
		 EMUIR_SIZE         : natural := 32; -- Dummy
		 INS_NOP            : unsigned(32-1 downto 0); -- Dummy
		 IDCODE             : unsigned(32-1 downto 0)  := x"00000000";
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
	signal clk      : std_logic := '0';
	signal tap_ce   : std_logic;
	constant THROTTLE_LATENCY : natural := 200;  -- No activity latency
	-- constant PIPE_SIZE : natural := 200;  -- Latency delay pipe
	constant VBUS_ADDR_W : natural := 12; -- Maximum address bus width

	signal vtap_reset   : std_logic := '1'; -- reset upon start
	signal vtap_ctrl : netppbus_WritePort;
	signal vtap_stat : netppbus_ReadPort;

	signal vbus_wr   : std_logic;
	signal vbus_rd   : std_logic;
	signal vbus_din  : std_logic_vector(31 downto 0) := (others => '0');
	signal vbus_dout : std_logic_vector(31 downto 0) := (others => '0');
	signal vbus_addr : std_logic_vector(VBUS_ADDR_W-1 downto 0)
		:= (others => '0');

	signal throttling   : std_logic;

begin

	-- Generate internal clock for virtual TAP:

local_clock:
if not USE_GLOBAL_CLK generate
	clk <= not clk after TCLK_PERIOD/2;
end generate;


virtual_bus:
	VirtualBus
	generic map ( ADDR_W => VBUS_ADDR_W, NETPP_NAME => "GHDLEX_DEFAULT",
		BUSTYPE => 1 )
	port map (
		clk         => clk,
		wr          => vbus_wr,
		rd          => vbus_rd,
		wr_busy     => '0',
		rd_busy     => '0',
		addr        => vbus_addr,
		data_in     => vbus_din,
		data_out    => vbus_dout
	);

	tap_ce <= vbus_wr or vbus_rd;

registers:
	-- We use our own TAP decoder:
	entity ghdlex.decode_netppbus
	generic map ( DATA_WIDTH => 32 )
	port map (
		ce       => tap_ce,
		reset    => vtap_reset,
		ctrl     => vtap_ctrl,
		stat     => vtap_stat,
		data_in  => vbus_din,
		data_out => vbus_dout,
		addr     => vbus_addr(BV_MMR_CFG_netppbus),
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
					and vtap_ctrl.throttle = '1' then
				throttling <= '1';
				usleep(to_integer(unsigned(vtap_ctrl.sleepcycles)));
			else
				throttling <= '0';
			end if;

		end if;
	end process;

startup:
	process
	begin
		wait for TCLK_PERIOD*10;
		vtap_reset <= '0';
		wait;
	end process;

	tout.tapclk <= clk;
	-- Wire 'Reset' property to core reset
	tout.core_reset <= vtap_ctrl.reset or vtap_reset;
	tout.emuir <= x"00000000";
	tout.emuexec <= vtap_ctrl.resume;
	tout.reg <= (others => '0');
	tout.emurequest <= '0';
	vtap_stat.break <= tin.break;
end simulation;
