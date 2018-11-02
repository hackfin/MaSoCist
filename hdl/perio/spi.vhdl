-- Simple SPI core
-- (c) 2009-2015 <hackfin@section5.ch>
--
-- MaSoCist license: OpenSource
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.system_map.all;

entity spi_core is
	generic (NBITS_POWER    : natural := 3);
	port (
		cs        : out std_logic;
		sclk      : out std_logic;
		mosi      : out std_logic;
		miso      : in  std_logic;
		ctrl      : in  spi_WritePort;
		stat      : out spi_ReadPort;
		clk       : in  std_logic
	);
end entity;

architecture behaviour of spi_core is
	type spi_state_t is (
		S_RESET,
		S_IDLE,
		S_SETUP,
		S_START,
		S_TRANSFER,
		S_FINISH
	);

	constant NBITS : natural := 2 ** NBITS_POWER;

	signal sclk_en       : std_logic;
	signal sclk_int      : std_logic;
	signal clkdiv_enable : std_logic;
	signal clken : std_logic;
	signal sclk_strobe : std_logic := '0';
	signal hold : std_logic := '1';
	signal csi : std_logic := '1';
	signal state : spi_state_t := S_IDLE;

	signal phase    : unsigned(2-1 downto 0);
	signal counter  : unsigned(16-1 downto 0) := (others => '0');

	signal cbits   : unsigned(NBITS_POWER-1 downto 0);
	signal cfg_nbits   : unsigned(ctrl.nbits'length-1 downto 0);
	constant BITS_NULL   : unsigned(NBITS_POWER-1 downto 0) :=
		(others => '0');
	signal data    : unsigned(NBITS-1 downto 0);

begin

	stat.spi_rx(data'range) <= data;
	cfg_nbits <= ctrl.nbits;

state_advance:
	process (clk)
	begin
		if rising_edge(clk) then
			-- Access to CLKDIV resets the system:
			if ctrl.spireset = '1' then
				state <= S_RESET;
			elsif hold = '0' or clken = '1' then
				case state is
					when S_IDLE =>
						if ctrl.pump = '1' then
							if ctrl.select_spi_rx = '1' then
								state <= S_SETUP;
							elsif ctrl.select_spi_tx = '1' then
								state <= S_SETUP;
							end if;
						end if;
					when S_SETUP =>
						state <= S_TRANSFER;
					when S_TRANSFER =>
						if cbits = BITS_NULL then
							state <= S_FINISH;
						end if;
					when others =>
						state <= S_IDLE;
				end case;

			end if;

		end if;
	end process;

spi_select:
	process (state)
	begin
		case state is
			when S_RESET | S_IDLE =>
				csi <= '1';
				hold <= '0';
			when S_SETUP | S_TRANSFER | S_FINISH =>
				csi <= '0';
				hold <= '1';
			when others => 
				csi <= '1';
				hold <= '0';
		end case;
	end process;


spi_worker:
	process (clk)
	begin
		if rising_edge(clk) then

			case state is
				when S_TRANSFER | S_SETUP | S_FINISH =>
					clkdiv_enable <= '1';
				when others =>
					clkdiv_enable <= '0';
			end case;

			if clken = '1' then
				case state is
					when S_SETUP =>
						cbits <= cfg_nbits(cbits'range);
						data <= ctrl.spi_tx(data'range);
					when S_TRANSFER =>
						cbits <= cbits - 1;
						if ctrl.lsbfirst = '1' then
							data <= miso & data(NBITS-1 downto 1);
						else
							data <= data(NBITS-2 downto 0) & miso;
						end if;
					when others =>
				end case;
			end if;
		end if;
	end process;


-- Clock divider:
clkdiv: entity work.clkdiv
	generic map ( PREDIV_LEN => 2, DIVIDER_SIZE => 8 )
	port map (
		enable        => clkdiv_enable,
		bypass        => ctrl.clkdiv_bypass,
		clk           => clk,
		divclk        => sclk_int,
		divclk_strobe => sclk_strobe,
		phase         => phase,
		divider       => ctrl.clkdiv
	);

	clken <= sclk_strobe;

	stat.spibusy <= not csi;
	stat.spiwidth <= to_unsigned(NBITS_POWER-3, 2);
	cs <= csi and ctrl.spics;
	mosi <= data(0) when ctrl.lsbfirst = '1' else data(NBITS-1);

	phase <= "11" when ctrl.cpha = '0' else "01";
	sclk_en <= '1' when state = S_TRANSFER else '0';

	-- Clock driver entity (some architectures need it for nice routing):
clkdrv_inst: entity work.clkdrv
	port map (iclk => sclk_int, enable => sclk_en,
		invert => ctrl.cpol, oclk => sclk);

end behaviour;
