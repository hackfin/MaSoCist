library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ghdlex;
	use ghdlex.ghpi_netpp.all;

library work;
	use work.global_config.all;

entity tb_versa_ecp5 is
end entity;

architecture sim of tb_versa_ecp5 is
	constant UCLK_PERIOD    : time := 
		real(500000000) / real(50100000) * (1 ns);
	constant SYSCLK_PERIOD    : time := 
		real(500000000) / real(CONFIG_SYSCLK) * (1 ns);
	constant MACCLK_PERIOD    : time := 8000 ps;

	signal clk                : std_logic := '0';
	signal uclk               : std_logic := '0';
	signal reset_n            : std_logic := '1';

	-- Alternative LED on versa_ecp5 board:
	signal led           : std_logic_vector(7 downto 0);

	signal tck, tms, tdi, tdo : std_logic := '0';

	-- I2C bus:
	signal i2c_scl       : std_logic;
	signal i2c_sda       : std_logic;

	-- Internal Slave (bridge) bus:
	signal slv_scl       : std_logic;
	signal slv_sda       : std_logic;

	signal spi_miso      : std_logic;
	signal spi_mosi      : std_logic;
	signal spi_sclk      : std_logic;
	signal spi_cs        : std_logic;

	signal macio_miim_clk   : std_logic; --! MIIM clk
	signal macio_rgmii_tx   : std_logic; --! RGMII TX ctr pin
	signal macio_rgmii_rx   : std_logic; --! 
	signal macio_mdc        : std_logic; --! 
	signal macio_mdio       : std_logic; --! 

	signal mac_mclk        : std_logic := '0';
	signal macio_mii_txclk  : std_logic;
	signal macio_mii_txen   : std_logic;
	signal macio_mii_txd    : std_logic_vector(3 downto 0);
	signal macio_mii_txerr  : std_logic;
	signal macio_mii_rxclk  : std_logic;
	signal macio_mii_rxd    : std_logic_vector(3 downto 0);
	signal macio_rgmii_rc   : std_logic;
	signal macio_rgmii_tc   : std_logic;

	signal uart_tx       : std_logic;
	signal uart_rx       : std_logic;

begin

initialize:
	process
		variable retval : integer;
	begin
		retval := netpp_init("VersaECP5Sim");
		wait;
	end process;
	

	-- Loopback UART:
--	uart_rx <= uart_tx;

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

uut: entity work.versa_ecp5_top
	generic map ( SIMULATION => true)
	port map (
		tck              => tck,
		tms              => tms,
		tdi              => tdi,
		tdo              => tdo,

		-- clk_out          => open,

		spi_miso         => spi_miso,
		spi_mosi         => spi_mosi,
		-- spi_sclk         => spi_sclk,
		spi_cs           => spi_cs,

		twi_scl          => i2c_scl,
		twi_sda          => i2c_sda,

		txd_uart         => uart_rx,
		rxd_uart         => uart_tx,

		oled             => led,
		dip_sw           => "00110001",

--		phy_rgmii_txclk  => macio_mii_txclk,
--		phy_rgmii_txctl  => macio_rgmii_tc,
--		phy_rgmii_txd    => macio_mii_txd,
--		phy_rgmii_rxclk  => macio_mii_rxclk,
--		phy_rgmii_rxctl  => macio_rgmii_rc,
--		phy_rgmii_rxd    => macio_mii_rxd,
--		ts_mac_coremdc   => macio_mdc,
--		ts_mac_coremdio  => macio_mdio,


 		reset_n          => reset_n,
		clk_in           => clk
	);

-- Loopback:
-- We need to supply an external rxclk:
	macio_mii_rxclk <= mac_mclk;

	process (mac_mclk)
	begin
		if rising_edge(mac_mclk) then
			macio_mii_rxd   <= macio_mii_txd;
			macio_rgmii_rc	<= macio_rgmii_tc;
		elsif falling_edge(mac_mclk) then
			macio_mii_rxd   <= macio_mii_txd;
			macio_rgmii_rc	<= macio_rgmii_tc;
		end if;
	end process;

clkgen:
	clk <= not clk after SYSCLK_PERIOD;
	uclk <= not uclk after UCLK_PERIOD;
	-- Only for GMII simulation:
	mac_mclk <= not mac_mclk after 40 ns;
	-- Pull to (weak) H:
	i2c_scl <= 'H';
	i2c_sda <= 'H';

	macio_mdio <= 'L'; -- To have a defined input for simulation

	process
	begin
		global_throttle <= '0';
		wait for 6 us;
		reset_n <= '0';
		wait for 100 ns;
		reset_n <= '1';
		wait;
	end process;

end sim;

