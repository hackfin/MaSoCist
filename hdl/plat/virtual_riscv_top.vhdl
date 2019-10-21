--
-- Virtual board example
--
-- SoC for Virtual simple board
--
-- Only tested for these configurations:
--
-- agneta
--
-- 4/2015  Martin Strubel <strubel@section5.ch>
--


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- For some MACHXO2 specific entities:

library work;
	use work.stdtap.all;
	use work.global_config.all;

entity virtual_top is
	generic ( SIMULATION : boolean := true );
	port (
		mclk         : in   std_logic;
		pclk         : in   std_logic;
		global_reset : in   std_logic;
		--clk_xtal_in      : in   std_logic;

		spi_clk       : out std_logic;
		spi_miso      : in std_logic;
		spi_mosi      : out std_logic;
		spi_cs        : out std_logic;


		i2c_sda     : inout std_logic;	
		i2c_scl     : inout std_logic;

		uart_rx     : in std_logic;	
		uart_tx     : out std_logic;

		reset_n      : in   std_logic

	);
end entity virtual_top;


architecture behaviour of virtual_top is

	attribute NOM_FREQ : string;
	-- attribute NOM_FREQ of osc_inst : label is "22.17";

	signal tap2core      : tap_out_rec;
	signal core2tap      : tap_in_rec;

	signal irq_in        : std_logic := '0';

	signal osc_clk       : std_logic;
	signal osc_stdby     : std_logic := '0';
	-- signal count         : unsigned(23 downto 0) := x"aaaaaa";

	signal reset_counter : unsigned(15 downto 0) := x"00ff";

	signal nreset        : std_logic;
	signal cpu_reset     : std_logic := '0';
	-- signal glob_rst      : std_logic := '1';

	-- GPIOs:
	-- Set to defined state for simulation:
	signal gpio          : unsigned(31 downto 0);
	signal pwm           : std_logic_vector(7 downto 0);

	-- Debugging:
	signal uart_loopback : std_logic;

begin

	nreset <= reset_n;


----------------------------------------------------------------------------
-- SoC CPU

maybe_swtap:
if SIMULATION generate
	swtap: VirtualTAP_DIRECT
	generic map ( IDCODE => CONFIG_TAP_ID, TCLK_PERIOD => CONFIG_TAPCLK_PERIOD,
		INS_NOP => x"00000013" )
	port map (
		-- Core <-> TAP signals:
		tin         => core2tap,
		tout        => tap2core
	);
end generate;


	cpu_reset <= tap2core.core_reset or not nreset;

soc: entity work.SoC
	port map (
		clk        => mclk,
		nmi_i      => '0',
		irq0       => irq_in,
		perio_rst  => '0',
		-- gpio      => gpio,
		-- pwm       => pwm(CONFIG_NUM_TMR-1 downto 0),

		-- Emulation pins:
		tin          => tap2core,
		tout         => core2tap,
		tap_reset    => global_reset,

-- Requires CONFIG_UART and CONFIG_SPI enabled:
		uart_tx       => uart_tx,
		uart_rx       => uart_rx,

		spi_sclk   => spi_clk,
		spi_cs     => spi_cs,
		spi_mosi   => spi_mosi,
		spi_miso   => spi_miso,

		reset      => cpu_reset
	);



rev_simulation:
if SIMULATION generate
	gpio(15 downto 0) <= "HLLLLHLLLLHLLLLH";
end generate;

end behaviour;


