-- NEO430 simulation only test bench
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.global_config.all;

-- Free model foundry models:
library fmf;

entity tb_virtual_neo430 is
end entity;

architecture sim of tb_virtual_neo430 is

	signal clk                : std_logic := '0';
	signal pclk               : std_logic := '0';
	signal reset_n            : std_logic := '1';
	signal led_g, led_r       : std_logic;

	signal tck, tms, tdi, tdo : std_logic := '0';
	signal global_reset : std_logic := '1';
	signal user_reset   : std_logic := '0';

	-- Fake LED
--	signal led           : std_logic_vector(7 downto 0);
--	signal gpio          : unsigned(31 downto 0);
--	signal pwm           : std_logic_vector(7 downto 0);


	-- I2C bus:
	signal i2c_sda       : std_logic;
	signal i2c_scl       : std_logic;

	signal spi_clk       : std_logic;
	signal spi_miso      : std_logic;
	signal spi_mosi      : std_logic;
	signal spi_cs        : std_logic;

	signal spi_clk_delayed : std_logic;


	signal uart_tx       : std_logic;
	signal uart_rx       : std_logic;

begin


uut: entity work.virtual_top
	port map (
		mclk             => clk,
		pclk             => pclk,
		
--		tck              => tck,
--		tms              => tms,
--		tdi              => tdi,
--		tdo              => tdo,

		i2c_scl          => i2c_scl,
		i2c_sda          => i2c_sda,

		spi_clk      => spi_clk,
		spi_cs       => spi_cs,
		spi_miso     => spi_miso,
		spi_mosi     => spi_mosi,

		-- gpio             => gpio,

		uart_rx          => uart_rx,
		uart_tx          => uart_tx,

 		-- greset           => '1',
 		global_reset     => global_reset,
 		reset_n          => reset_n

	);

maybe_vuart:
	if CONFIG_VIRTUAL_UART generate

vuart: entity work.VirtualUART
	generic map (
		DIVIDER => CONFIG_SYSCLK / CONFIG_DEFAULT_UART_BAUDRATE / 16 - 1
	)
	port map (
		rxi     => uart_tx,
		rxirq  => open,
		txo    => uart_rx,
		clk    => clk
	);

	end generate;


maybe_uart_loopback:
	if not CONFIG_VIRTUAL_UART generate
	uart_rx <= uart_tx; -- Loopback
	end generate;

-- This model may crash with GHDL. Don't use.

-- spi_flash:
-- 	entity fmf.s25fl032a
-- 	generic map (
-- 		TimingModel   => "None",
--  		mem_file_name => "test_neo430_s25.mem",
--  		UserPreload   => TRUE
-- 	)
--  	port map (
--  		  SCK           => spi_clk,
--  		  SI            => spi_mosi,
--  		  CSNeg         => spi_cs,
--  		  HOLDNeg       => '1',
--  		  WNeg          => '1',
--  		  SO            => spi_miso
--  	);


	spi_clk_delayed <= spi_clk after 20 ns;

m25p80_flash:
	entity fmf.m25p80
	generic map (
		mem_file_name => "test_neo430.mem",
		UserPreload   => TRUE
	)
	port map (
        C             => spi_clk_delayed,
        D             => spi_mosi,
        SNeg          => spi_cs,
        HOLDNeg       => '1',
        WNeg          => '1',
        Q             => spi_miso
 	);


-- break_term:
-- 	process (clk)
-- 	begin
-- 		if rising_edge(clk) then
-- 			-- If we run into a break and we did not request emulation,
-- 			-- terminate simulation.
-- 			if (tstat.exstat(B_ZPU_BREAK - 8) = '1'
-- 			and tctrl.emurequest = '0') then
-- -- Disabled for JTAG simulation:
-- --				assert false report "Break issued, terminating simulation" 
-- --					severity failure;
-- 			end if;
-- 		end if;
-- 	end process;
-- 
clkgen:

	clk <= not clk after CONFIG_VIRTUALCLK_PERIOD;

	pclk <= not pclk after 40 ns;

	reset_n <= user_reset;

	-- Note that an improper reset/tap clock behaviour can make
	-- the TAP test fail, due to incorrect initialization of the
	-- pulse strobe units
	process
	begin
		wait for 200 ns;
		global_reset <= '0';
		wait for 1 us;
		user_reset <= '1';
		wait;
	end process;

	-- Pull to (weak) H:
	i2c_scl <= 'H';
	i2c_sda <= 'H';


end sim;

