library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ghdlex;
	use ghdlex.ghpi_netpp.all;

entity tb_breakout is
end entity;

architecture sim of tb_breakout is
	signal clk                : std_logic := '0';
	signal greset             : std_logic := '1';
	signal reset_n            : std_logic := '1';
	signal led_g, led_r       : std_logic;

	-- Alternative LED on breakout board:
	signal led           : std_logic_vector(7 downto 0);

	signal tck, tms, tdi, tdo : std_logic := '0';
	signal global_reset : std_logic := '0';
	signal user_reset   : std_logic := '0';

	signal gpio               : unsigned(31 downto 0);


	-- I2C bus:
	signal i2c_sda       : std_logic;
	signal i2c_scl       : std_logic;

	signal spi_clk       : std_logic;
	signal spi_cs        : std_logic;
	signal spi_miso      : std_logic;
	signal spi_mosi      : std_logic;

	-- Internal Slave (bridge) bus:
	signal slv_sda       : std_logic;
	signal slv_scl       : std_logic;

	signal uart_tx       : std_logic;
	signal uart_rx       : std_logic;


begin

initialize:
	process
		variable retval : integer;
	begin
		retval := netpp_init("BreakoutBoardSim");
		wait;
	end process;
	

	-- Loopback UART:
	uart_rx <= uart_tx;

uut: entity work.breakout_top
	generic map ( SIMULATION => true)
	port map (
		
		tck              => tck,
		tms              => tms,
		tdi              => tdi,
		tdo              => tdo,

		clk_out          => clk,

		i2c_scl          => i2c_scl,
		i2c_sda          => i2c_sda,

    	spi_clk      => spi_clk,
    	spi_cs       => spi_cs,
    	spi_miso     => spi_miso,
    	spi_mosi     => spi_mosi,

		gpio             => gpio,

		uart_rx          => uart_rx,
		uart_tx          => uart_tx,

		led              => led,
 		greset           => '1',
 		reset_n          => reset_n
	);

	reset_n <= user_reset;

	process
	begin
		global_throttle <= '0';
		wait for 5 ns;
		global_reset <= '1';
		wait for 100 ns;
		user_reset <= '1';
		-- global_throttle <= '1';
		wait;
	end process;

	-- Pull to (weak) H:
	i2c_scl <= 'H';
	i2c_sda <= 'H';

end sim;

