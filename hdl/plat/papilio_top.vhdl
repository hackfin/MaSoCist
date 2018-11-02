--
-- Papilio board top level module
--
-- SoC for Spartan3E-250 papilio board
--
-- Updated 9/2015  Martin Strubel <strubel@section5.ch>
--


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


library work;
	use work.stdtap.all;
	use work.global_config.all;
	use work.system_map.all;

entity papilio_top is
	generic ( SIMULATION : boolean := false );
	port (
		clk       : in    std_logic;
		reset     : in    std_logic;
		tx0       : out   std_logic;  -- UART0 TX
		rx0       : in    std_logic;  -- UART0 RX
		tx1       : out   std_logic;  -- UART1 TX
		rx1       : in    std_logic;  -- UART1 RX

		spi_miso  : in  std_logic;
		spi_mosi  : out std_logic;
		spi_sclk  : out std_logic;
		spi_cs    : out std_logic;

		pwm       : out std_logic_vector(2 downto 0);

		lcd_cs    : out   std_logic;
		lcd_a0    : out   std_logic;
		lcd_rd    : out   std_logic;
		lcd_wr    : out   std_logic;
		lcd_d     : inout unsigned(7 downto 0);
		lcd_bgled : out   std_logic;	
		lcd_rst   : out   std_logic
	);


end entity papilio_top;


architecture behaviour of papilio_top is

	signal tap2core      : tap_out_rec;
	signal core2tap      : tap_in_rec;

	signal irq_in        : std_logic := '0';

	signal reset_counter : unsigned(15 downto 0) := x"00ff";

	-- No more dedicated i2c on papilio.
	-- signal i2c_sda       : std_logic;
	-- signal i2c_scl       : std_logic;

	signal rxdb          : std_logic;
	signal rxdb_buf      : std_logic_vector(3 downto 0);

	signal mclk          : std_logic;

	signal cpu_reset     : std_logic;
	signal tap_reset     : std_logic;
	signal glob_rst      : std_logic := '1';

	signal rx            : std_logic;
	signal tx            : std_logic;
	signal uart_iosel    : std_logic;

	-- GPIOs:
	signal gpio          : unsigned(31 downto 0);

begin


	mclk <= clk;

	-- Debouncing for UART:

rx_debounce:
	process (clk)
	begin
		if rising_edge(clk) then
			rxdb_buf <= rxdb_buf(2 downto 0) & rx;
			if rxdb_buf = "1000" then rxdb <= '0'; end if;
			if rxdb_buf = "0111" then rxdb <= '1'; end if;
		end if;
	end process;

	tx0 <= tx when uart_iosel = '0' else '1';
	tx1 <= tx when uart_iosel = '1' else '1';

	rx <= rx0 when uart_iosel = '0' else rx1;

	
----------------------------------------------------------------------------
-- SoC CPU


	cpu_reset <= tap2core.core_reset or reset;

	tap_reset <= not reset;

soc: entity work.SoC
	port map (
		clk        => mclk,
		tap_reset  => tap_reset,
		reset      => cpu_reset,
		nmi_i      => '0',

		perio_rst  => '0',

		-- Emulation pins:
		tin          => tap2core,
		tout         => core2tap,

		irq0      => irq_in,
		-- gpio      => gpio,
		pwm       => pwm,

		spi_sclk   => spi_sclk,
		spi_cs     => spi_cs,
		spi_mosi   => spi_mosi,
		spi_miso   => spi_miso,

   -- 	lcdio_a0         => lcd_a0,
   -- 	lcdio_cs         => lcd_cs,
   -- 	lcdio_bgled      => lcd_bgled,
   -- 	lcdio_rst        => lcd_rst,
   -- 	lcdio_wr         => lcd_wr,
   -- 	lcdio_rd         => lcd_rd,
   -- 	lcdio_data       => lcd_d,

		uart_tx    => tx,
		uart_rx    => rxdb,
		uart_iosel => uart_iosel
	);

----------------------------------------------------------------------------

maybe_hwtap:
if not SIMULATION generate

hwtap: entity work.Spartan3_TAP
	port map (
		-- On the Spartan3, these are not explicitely connected. All done
		-- internally within the primitive.
		tck         => 'X',
		tms         => 'X',
		tdi         => 'X',
		tdo         => open,
		-- Core <-> TAP signals:
		tin         => core2tap,
		tout        => tap2core
	);

end generate;

-- synthesis translate_off

maybe_swtap:
if SIMULATION generate

	swtap: VirtualTAP_Direct
		generic map (
			IDCODE => CONFIG_TAP_ID,
			INS_NOP => x"0000000b",
			TCLK_PERIOD => CONFIG_TAPCLK_PERIOD
		)
		port map (
			-- Core <-> TAP signals:
			tin         => core2tap,
			tout        => tap2core
		);

end generate;

-- synthesis translate_on

end behaviour;


