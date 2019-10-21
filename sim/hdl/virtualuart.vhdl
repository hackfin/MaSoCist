library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library ghdlex;
	use ghdlex.ghpi_pipe.all;

library work;
	use work.system_map.all;

entity VirtualUART is
	generic (DIVIDER : natural := 79);
	port (
		rxi    : in std_logic;
		rxirq  : out std_logic;
		txo    : out std_logic;
		clk    : in std_logic
	);
end entity;

architecture sim of VirtualUART is
	signal txdata : unsigned(7 downto 0);
	signal rxdata : unsigned(7 downto 0);
	signal sigterm : std_logic := '0';
	signal rd       : std_logic := '0';
	signal wr       : std_logic := '0';
	signal rx_ready : std_logic := '1';
	signal data_valid : std_logic := '0';
	signal pipe_flags : pipeflag_t := "0000";
	-- Pipe handles:
	shared variable iopipe : pipehandle_t;
	signal ctrl : uart_WritePort;
	signal stat : uart_ReadPort;

begin
	process
		variable err : integer;
	begin
		iopipe := openpipe("/tmp/ghdlsim");
		if iopipe < 0 then
			assert false report "Failed to open PTY pipe" severity failure;
		end if;
		wait;
	end process;


uart: entity work.uart_core
	port map (
		rx => rxi,
		tx => txo,
		ctrl => ctrl,
		stat => stat,
		clk => clk
	);

	ctrl.uart_clkdiv <= to_unsigned(DIVIDER, ctrl.uart_clkdiv'length);
	ctrl.uart_txr <= rxdata;
	ctrl.select_uart_txr <= wr;
	ctrl.select_uart_rxr <= stat.rxready;

	txdata <= stat.rxdata;

	process (clk)
		variable val : unsigned(7 downto 0);
		variable flags : pipeflag_t;
	begin
		if rising_edge(clk) then

			rd <= stat.rxready;

			flags := pipe_flags;

			-- Only call pipe if
			-- * Data ready to receive
			-- * Write command
			-- * There was something in the RX buffer

			if wr = '1' or rx_ready = '1' or flags(PIPE_RX) = '1' then
				val := txdata;
				flags(PIPE_TX) := rd;
				pipe_rxtx(iopipe, val, flags);
			end if;

			-- Did we get a byte?
			if pipe_flags(PIPE_RX) = '1' then
				rxdata <= val;
				data_valid <= '1';
				wr <= '1';
			else
				wr <= '0';
				data_valid <= '0';
			end if;

			-- Only file read on next cycle when requested:
			flags(PIPE_RX) := flags(PIPE_RX) and rx_ready;

			-- Save flags for next time
			pipe_flags <= flags;

		end if;
	end process;


end sim;


