library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ghdlex;
	use ghdlex.ghpi_netpp.all;


library work;
	use work.global_config.all;

entity tb_papilio is
end entity;

architecture sim of tb_papilio is
	constant UCLK_PERIOD    : time := 
		-- real(500000000) / real(22118400) * (1 ns);
		real(500000000) / real(32100000) * (1 ns);
	constant SYSCLK_PERIOD    : time := 
		real(500000000) / real(CONFIG_SYSCLK) * (1 ns);
	signal clk                : std_logic := '0';
	signal uclk               : std_logic := '0';
	signal reset              : std_logic;
	signal led_g, led_r       : std_logic;

	-- Alternative LED on papilio board:
	signal led           : std_logic_vector(7 downto 0);

	signal tck, tms, tdi, tdo : std_logic := '0';
	signal global_reset : std_logic := '0';
	signal user_reset   : std_logic := '0';

	signal rj45_loopback      : unsigned(2 downto 0);

	-- SPI
	signal spi_miso      : std_logic := 'L';
	signal spi_mosi      : std_logic;
	signal spi_sclk      : std_logic;
	signal spi_cs        : std_logic;

	-- I2C bus:
	signal i2c_sda       : std_logic;
	signal i2c_scl       : std_logic;

	-- Internal Slave (bridge) bus:
	signal slv_sda       : std_logic;
	signal slv_scl       : std_logic;

	signal uart_tx       : std_logic;
	signal uart_rx       : std_logic;

  component spi_flash_simulator
    generic(
      SYS_CLK_RATE   : real;
      FLASH_ADR_BITS : natural; -- Flash memory size is based on this
      FLASH_INIT     : string   -- Default RX packet digestion settings
    );
    port (
      -- System Clock and Clock Enable
      sys_rst_n  : in  std_logic;
      sys_clk    : in  std_logic;
      sys_clk_en : in  std_logic;

      -- SPI interface
      -- "hold" and "WP" are not implemented.
      spi_cs_i   : in  std_logic;
      spi_sck_i  : in  std_logic;
      spi_si_i   : in  std_logic;
      spi_so_o   : out std_logic

    );
  end component;


component papilio_top is
	generic ( SIMULATION : boolean := false );
	port (
		clk       : in std_logic;
		reset     : in std_logic;
		tx0       : out   std_logic;  -- UART TX
		rx0       : in    std_logic;  -- UART RX
		tx1       : out   std_logic;  -- UART TX
		rx1       : in    std_logic;  -- UART RX

		spi_miso  : in  std_logic;
		spi_mosi  : out std_logic;
		spi_sclk  : out std_logic;
		spi_cs    : out std_logic;

		pwm       : out std_logic_vector(2 downto 0);
		lcd_cs    : out std_logic;
		lcd_a0    : out std_logic;
		lcd_rd    : out std_logic;
		lcd_wr    : out std_logic;
		lcd_d     : inout unsigned(7 downto 0);
		lcd_bgled : out std_logic;	
		lcd_rst   : out std_logic
	);

end component papilio_top;

	signal lcd_data : unsigned(7 downto 0);

begin

initialize:
	process
		variable retval : integer;
	begin
		retval := netpp_init("PapilioSim");
		wait;
	end process;
	

	clk <= not clk after SYSCLK_PERIOD;
	uclk <= not uclk after UCLK_PERIOD;

	-- Loopback UART:
	-- uart_rx <= uart_tx;

	-- Virtual UART runs at DEFAULT_UART_BAUDRATE.
	-- When the program changes this baudrate, you will get garbage here.
vuart: entity work.VirtualUART
	generic map (
		DIVIDER => CONFIG_SYSCLK / CONFIG_DEFAULT_UART_BAUDRATE / 16 - 1
	)
	port map (
		rxi     => uart_tx,
		rxirq  => open,
		txo    => uart_rx,
		clk    => uclk
	);

uut: papilio_top
	generic map ( SIMULATION => true)
	port map (
		clk       => clk,
		reset     => reset,
		tx0       => uart_tx,
		rx0       => uart_rx,
		tx1       => open,
		rx1       => '1',
		spi_miso  => spi_miso,
		spi_mosi  => spi_mosi,
		spi_sclk  => spi_sclk,
		spi_cs    => spi_cs,
		pwm       => open,
		lcd_cs    => open,
		lcd_a0    => open,
		lcd_rd    => open,
		lcd_wr    => open,
		lcd_d     => lcd_data,
		lcd_bgled => open,
		lcd_rst   => open
	);

	-- spi_miso <= spi_mosi;
	reset <= not user_reset;

	process
	begin
		global_throttle <= '0';
		wait for 5 ns;
		global_reset <= '1';
		wait for 100 ns;
		user_reset <= '1';
		global_throttle <= '1';
		wait;
	end process;

-- spi_flash: spi_flash_simulator
-- 	port map (
-- 		-- System Clock and Clock Enable
-- 		sys_rst_n  => user_reset,
-- 		sys_clk    => clk,
-- 		sys_clk_en => '1',
-- 
-- 		-- SPI interface
-- 		-- "hold" and "WP" are not implemented.
-- 		spi_cs_i   => spi_cs,
-- 		spi_sck_i  => spi_sclk,
-- 		spi_si_i   => spi_mosi,
-- 		spi_so_o   => spi_miso
-- 	);

	-- Pull to (weak) H:
	i2c_scl <= 'H';
	i2c_sda <= 'H';

end sim;

