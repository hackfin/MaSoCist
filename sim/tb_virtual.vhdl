-- ZPUNG simulation only test bench
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ghdlex;
	use ghdlex.ghpi_netpp.all;

library work;
	use work.global_config.all;

entity tb_virtual is
end entity;

architecture sim of tb_virtual is

	signal clk                : std_logic := '0';
	signal pclk               : std_logic := '0';
	signal reset_n            : std_logic := '1';
	signal led_g, led_r       : std_logic;

	signal tck, tms, tdi, tdo : std_logic := '0';
	signal global_reset : std_logic := '0';
	signal user_reset   : std_logic := '0';

	-- Fake LED
	signal led           : std_logic_vector(7 downto 0);
	signal gpio          : unsigned(31 downto 0);
	signal pwm           : std_logic_vector(7 downto 0);


	-- I2C bus:
	signal i2c_sda       : std_logic;
	signal i2c_scl       : std_logic;

	signal spi_clk       : std_logic;
	signal spi_miso      : std_logic;
	signal spi_mosi      : std_logic;
	signal spi_cs        : std_logic;


	signal uart_tx       : std_logic;
	signal uart_rx       : std_logic;

begin

initialize:
	process
		variable retval : integer;
	begin
		retval := netpp_init("VirtualBoardSim");
		wait;
	end process;
	


uut: entity work.virtual_top
	port map (
		mclk             => clk,
		pclk             => pclk,
		
		tck              => tck,
		tms              => tms,
		tdi              => tdi,
		tdo              => tdo,

		i2c_scl          => i2c_scl,
		i2c_sda          => i2c_sda,

    	spi_clk      => spi_clk,
    	spi_cs       => spi_cs,
    	spi_miso     => spi_miso,
    	spi_mosi     => spi_mosi,

		-- gpio             => gpio,

		uart_rx          => uart_rx,
		uart_tx          => uart_tx,

		led              => led,
 		-- greset           => '1',
 		reset_n          => reset_n

	);

	spi_miso <= spi_mosi; -- Loopback

	uart_rx <= uart_tx; -- Loopback

-- spi_flash:
--	entity work.s25fl032a
--	port map (
--		  SCK           => spi_clk,
--		  SI            => spi_mosi,
--		  CSNeg         => spi_cs,
--		  HOLDNeg       => '1',
--		  WNeg          => '1',
--		  SO            => spi_miso
--	);


--	entity work.m25p80
--	port map (
--        C             => spi_clk,
--        D             => spi_mosi,
--        SNeg          => spi_cs,
--        HOLDNeg       => '0',
--        WNeg          => '0',
--        Q             => spi_miso
-- 	);


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

	-- Pull to (weak) H:
	i2c_scl <= 'H';
	i2c_sda <= 'H';


end sim;

