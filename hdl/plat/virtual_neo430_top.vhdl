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

	-- for hwtap : GenericTAP use entity work.MachXO2_TAP;

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

--	component pll_wrapper is
--		port (
--			CLKI: in  std_logic; 
--			CLKOP: out  std_logic; 
--			LOCK: out  std_logic
--	 	);
--	end component;

-- 	component pwrc
-- 		port (USERSTDBY: in  std_logic; CLRFLAG: in  std_logic; 
-- 			CFGSTDBY: in  std_logic; STDBY: out  std_logic; 
-- 			SFLAG: out  std_logic);
-- 	end component;

	-- Debugging:
	signal uart_loopback : std_logic;

begin

	nreset <= reset_n;


----------------------------------------------------------------------------
-- SoC CPU



-- synthesis translate_on

	cpu_reset <= tap2core.core_reset or not nreset;

soc: entity work.SoC
	port map (
		clk        => mclk,

		-- Emulation pins:

		nmi_i      => irq_in,
		-- gpio      => gpio,
		-- pwm       => pwm(CONFIG_NUM_TMR-1 downto 0),

-- Requires CONFIG_UART and CONFIG_SPI enabled:
		uart_tx       => uart_tx,
		uart_rx       => uart_rx,
		-- uartio_rxirq    => open,

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


