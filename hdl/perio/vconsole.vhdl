-- Virtual Console for MaSoCist simulator
--
-- Under Linux, run this command to create a virtual UART interface
-- (replace '<me>' by the user id running the simulation:
--
--    > sudo socat PTY,link=/var/run/ghdlsim,raw,echo=0,user=<me> \
--              PTY,link=/var/run/iopipe,raw,echo=0,user=<me>
--
-- Then open a terminal on the host side:
--
--    > minicom -o -D /var/run/iopipe
--
-- and run the simulation


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Unsigned

library ghdlex;
use ghdlex.ghpi_pipe.all;
use ghdlex.txt_util.all;

entity virtual_console is
	port (
		clk         : std_logic;
		data_in     : unsigned(7 downto 0);
		rx_ready    : in std_logic;
		dvalid      : out std_logic;
		data_out    : out unsigned(7 downto 0);
		wr          : in std_logic
	);
end entity;

architecture behaviour of virtual_console is
	signal data : unsigned(7 downto 0);
	signal sigterm : std_logic := '0';
	signal data_valid : std_logic := '0';
	signal pipe_flags : pipeflag_t := "0000";

	shared variable iopipe : pipehandle_t;

begin

	data_out <= data;
	dvalid <= data_valid;
	
	process
		variable err : integer;
	begin
		iopipe := openpipe("/var/run/ghdlsim");
		if iopipe < 0 then
			assert false report
			"Failed to open PTY pipe '/var/run/ghdlsim'. Run init-pty.sh."
			severity failure;
		end if;
		wait;
	end process;

	process (clk)
		variable val : unsigned(7 downto 0);
		variable flags : pipeflag_t;
	begin
		if rising_edge(clk) then

			flags := pipe_flags;

			-- Only call pipe if
			-- * Data ready to receive
			-- * Write command
			-- * There was something in the RX buffer

			if wr = '1' or rx_ready = '1' or flags(PIPE_RX) = '1' then
				val := data_in;
				flags(PIPE_TX) := wr;
				pipe_rxtx(iopipe, val, flags);
			end if;

			-- Did we get a byte?
			if pipe_flags(PIPE_RX) = '1' then
				data <= val;
				data_valid <= '1';
			else
				data_valid <= '0';
			end if;

			-- Only file read on next cycle when requested:
			flags(PIPE_RX) := flags(PIPE_RX) and rx_ready;

			-- Save flags for next time
			pipe_flags <= flags;

		end if;
	end process;



end behaviour;

