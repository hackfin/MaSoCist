-- Emulate a i2c slave device
--
--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.i2c_map.all;
	use work.system_map.all;

entity i2cslave_emu is
	port (

		tx_data     : out std_logic_vector(7 downto 0);
		tx_strobe   : out std_logic;
		tx_empty    : in  std_logic;

		rx_data     : in  std_logic_vector(7 downto 0);
		rx_en       : in  std_logic;
		rx_ack      : out std_logic;

		brctrl      : in  i2c_bridge_WritePort;
		brstat      : out i2c_bridge_ReadPort;

		dbgstat     : in  unsigned(7 downto 0);

		busy        : in  std_logic;
		clk         : in  std_logic
	);
end entity i2cslave_emu;

architecture behaviour of i2cslave_emu is

	type i2cslave_state_t is (
		S_IDLE,
		S_ADDR,
		S_TRANSFER,
		S_DATAREADY,
		S_WAIT
	);

	-- Preinitialize Address for simulation to avoid "Bad Read I/O" errors:
	signal address : unsigned(7 downto 0) := (others => '0');
	signal data_re : std_logic;
	signal data_we : std_logic;
	signal tx_wr   : std_logic;
	signal ctrl    : i2c_slave_emu_WritePort;
	signal stat    : i2c_slave_emu_ReadPort;


	signal rx_en_d : std_logic;
	signal tx_empty_d  : std_logic;
	signal rden : std_logic;

	signal brflag  : std_logic := '0';
	signal brover  : std_logic := '0';
	signal brbuf   : unsigned(7 downto 0); -- Buffer flag

	signal state   : i2cslave_state_t := S_IDLE;

	signal data_u  : unsigned(7 downto 0);

	signal dbgcnt  : unsigned(15 downto 0) := (others => '0');

begin

	stat.fwrevision      <= to_unsigned(HWREV_i2c_map_MAJOR, 8);
	stat.fwminorrevision <= to_unsigned(HWREV_i2c_map_MINOR, 8);
	stat.idcode          <= brctrl.sl_idcode;

fsm:
	process (clk)
	begin
		if rising_edge(clk) then
			data_we <= '0';
			data_re <= '0';
			tx_wr <= '0';
			case state is
				when S_IDLE =>
					if busy = '1' then
						state <= S_ADDR;
					end if;
				when S_ADDR =>
					if rx_en = '1' then
						address <= unsigned(rx_data);
						state <= S_TRANSFER;
						data_re <= '1';
					elsif busy = '0' then
						state <= S_IDLE;
					elsif rden = '1' then
						data_re <= '1';
						state <= S_TRANSFER;
					end if;

				when S_TRANSFER =>
					if busy = '0' then
						state <= S_IDLE;
--					elsif tx_empty = '1' then
--						state <= S_WAIT;
					else
						tx_wr <= '1';
						state <= S_DATAREADY;
					end if;


				when S_DATAREADY =>
					address <= address + 1;
					state <= S_WAIT;

				when S_WAIT =>
					if busy = '0' then
						state <= S_IDLE;
					elsif rx_en = '1' then
						state <= S_TRANSFER;
						data_we <= '1';
					elsif tx_empty = '1' then
						state <= S_TRANSFER;
						data_re <= '1';
					end if;			

--					if busy = '0' then
--						state <= S_IDLE;
--					elsif rx_en = '1' then
--						state <= S_DATAREADY;
--					elsif tx_empty = '1' then
--						state <= S_TRANSFER;
--					end if;
--					if brctrl.select_ibdata = '1' then
--						if busy = '0' then
--							state <= S_IDLE;
--						else
--							state <= S_WAIT;
--						end if;
--					end if;
			end case;
		end if;
	end process;

	tx_strobe <= tx_wr;


	tx_data <= std_logic_vector(data_u);

i2c_slave_decoder:
	entity work.decode_i2c_slave_emu
	generic map( DATA_WIDTH => 8)
	port map (
		ce        => '1',
		ack       => open,
		ctrl      => ctrl,
		stat      => stat,
		data_in   => unsigned(rx_data),
		data_out  => data_u,
		addr      => address(BV_MMR_CFG_i2c_slave_emu),
		re        => data_re,
		we        => data_we,
		clk       => clk
	);

----------------------------------------------------------------------------
-- I2C bridge:

	rden <= tx_empty and not tx_empty_d;

i2c_bridge_buffer:
	process (clk)
	begin
		if rising_edge(clk) then
			tx_empty_d <= tx_empty;
			rx_en_d <= rx_en;
			if state = S_ADDR then
				rx_ack <= rx_en;
			else
				rx_ack <= brctrl.select_ibdata;
			end if;

			if state /= S_ADDR and rx_en = '1' and rx_en_d = '0' then
				brbuf <= unsigned(rx_data);
				if brctrl.select_ibdata = '0' then
					if brflag = '1' then
						brover <= '1';
					else
						brflag <= '1';
					end if;
				end if;
			else
				if brctrl.select_ibdata = '1' then
					brflag <= '0';
					brover <= '0'; -- Not sticky !! XXX
				end if;
			end if;
		end if;
	end process;
	

	with state select
		brstat.i2cemu_state <= "000" when S_IDLE,
		                       "001" when S_ADDR,
		                       "010" when S_TRANSFER,
		                       "011" when S_DATAREADY,
		                       "100" when S_WAIT;


	brstat.slcount <= dbgcnt;
	brstat.i2c_sl_stat <= dbgstat(7 downto 4);
	brstat.i2c_sl_err <= dbgstat(3 downto 0);
	brstat.busy <= busy;
	brstat.ibaddr <= address;
	brstat.ibdata <= brbuf;
	brstat.dready <= brflag;
	brstat.overrun <= brover;
	-- Fixme: Use brctrl.select_ibdata to handshake


end architecture behaviour;
