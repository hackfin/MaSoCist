-- i2c master controller
--
-- revamped and rewritten:
-- 2013 Martin Strubel <hackfin@section5.ch>
--
-- Note that we allow a RESTART condition to happen within a ACK_x
-- phase whenever a new transaction is fired immediately within this phase.
-- If this is not desired, the client (CPU) must wait for the INACK flag
-- to deassert before writing more data.
-- Also new is the 'hold' pin: when asserted, the state machine does not
-- enter the STOP state and waits for more transaction requests.
-- Client drivers use this to force byte bursts, i.e.
-- when a continuous byte stream can not be guaranteed from the CPU but
-- a STOP condition within the stream due to timeouts are not an option.


library ieee;
	use ieee.std_logic_1164.all;
	use IEEE.numeric_std.all;

entity i2c_master is
	generic (
		DIVIDER_SIZE : natural := 16
    );
	port (
		--! System clock
		clk       : in     std_logic;
		--! i2c SDA
		sda       : inout  std_logic;
		--! i2c SCL
		scl       : inout  std_logic;
		--! Reset, HIGH active
		reset     : in     std_logic;
		--! Enable
		enable    : in     std_logic;
		--! When 1, hold scl, but don't stop
		hold      : in     std_logic;
		--! Enable RESTART condition on next transaction when in HOLD state
		restart   : in     std_logic;
		--! Slave address
		addr      : in     unsigned(6 downto 0);
		--! Read/Write pin (0: write, 1: read)
		rw        : in     std_logic;
		-- Input data (write)
		data_in   : in     unsigned(7 downto 0);
		--! Output data (read)
		data_out  : out    unsigned(7 downto 0);
		--! Clock divider for i2c clk
		divider   : in     unsigned(DIVIDER_SIZE-1 downto 0);
		--! 0: busy, 1: ready
		ready     : out    std_logic;
		--! 1: Clock stretched
		clkstr    : out    std_logic;
		--! 1 ACK strobe
		ack_stb   : out    std_logic;
		--! 1 when in an ACK phase
		inack     : out    std_logic;
		--! 1: Acknowledge error
		nak       : out    std_logic;
		--! 1: Arbitration lost
		arbl      : out    std_logic
	);
end i2c_master;

architecture behaviour of i2c_master is
	type state_t is (
		S_IDLE,
		S_BUSY,      -- Bus busy (multi master)
		S_TRY,       -- Attempt to make a transaction
		S_NEXT,      -- Transfer next word
		S_ADVANCE,   -- Advance and possibly pause
		S_START,     -- Start transaction
		S_ADDR,      -- Command/Address phase
		S_ACK_A,     -- Ack after command
		S_WRITE,     -- Writing
		S_READ,      -- Reading
		S_ACK_B,     -- ACK after write
		S_MACK,      -- Master to slave ACK when reading
		S_HOLD,      -- Hold SCL while waiting for data written/picked up
		S_PAUSE,     -- Wait cycle after HOLD release
		S_RESUME,    -- Resume after HOLD
		S_WAIT,      -- Wait cycle after busy release
		S_ERROR,     -- Error state
		S_STOP       -- Stop transaction
	);
	signal state : state_t;

	signal scl_en    :  std_logic := '0';

	-- Detection signals for Multimaster fun:
	signal sda_sns_d :  std_logic;
	signal sda_sns   :  std_logic;
	signal is_start  :  std_logic;
	signal is_stop   :  std_logic;

	signal ack_n     :  std_logic;
	signal nack      :  std_logic;
	signal arb_lost  :  std_logic;

	signal scl_act   :  std_logic;
	signal sda_act   :  std_logic;
	signal scl_buf   :  std_logic; -- Buffered signal
	signal sda_buf   :  std_logic; -- Buffered signal
	signal sda_int   :  std_logic;
	signal r_rw      :  std_logic;
	signal r_data    :  unsigned(7 downto 0);
	signal bitcount  :  unsigned(2 downto 0);
	signal stretch   :  std_logic := '0';

	signal iclk_reset :  std_logic;

	signal txd       :  unsigned(7 downto 0);
	signal rxd       :  unsigned(7 downto 0);

	signal phase     :  std_logic_vector(3 downto 0);

	signal is_period :  std_logic;

	-- signal dbg_count :  unsigned(15 downto 0);

	signal count : unsigned(DIVIDER_SIZE-1 downto 0);

begin
	
	is_period <= '1' when count = divider else '0';

	clkstr <= stretch;

	iclk_reset <= '1' when state = S_IDLE or state = S_BUSY else '0';

clk_gen:
	process(clk)
	begin
		if rising_edge(clk) then
			-- dbg_count <= count;
			if iclk_reset = '1' then
				stretch <= '0';
				count <= (others => '0');
				phase <= "1001";
			else
				-- Allow stretching, when scl low in third phase
 				if phase = "0110" and scl = '0' then
 					stretch <= '1';
 				else
 					stretch <= '0';
 				end if;
				-- Rotate
				if is_period = '1' then
					phase <= phase(2 downto 0) & phase(3);
					count <= (others => '0');
				elsif stretch = '0' then
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;

	sda_int <= txd(7);

	-- '1' means getting off the bus:
	with state select
		sda_act <= '0'       when S_START | S_STOP,
		           '1'       when S_IDLE | S_BUSY | S_TRY | S_WAIT | S_PAUSE,
		           '1'       when S_ACK_A | S_ACK_B,
		           ack_n     when S_MACK,
		           sda_int   when others;

	with state select
		inack   <= '1' when S_MACK | S_ACK_B | S_ACK_A,
		           '0' when others;

	with state select
		ready   <= '1' when S_IDLE | S_HOLD | S_NEXT | S_STOP,
		           '0' when others;

	scl_act <= '0' when phase(1) = '0' and scl_en = '1' else '1';

	-- Buffering to prevent glitches:
buffering:
	process(clk)
	begin
		if rising_edge(clk) then
			sda_buf <= sda_act;
			scl_buf <= scl_act;
--			if state = S_HOLD then
--				scl_buf <= '0'; -- Stretch..
--			else
--				scl_buf <= scl_act;
--			end if;
		end if;
	end process;

	-- Open collector:
	scl <= '0' when scl_buf = '0' else 'Z';
	sda <= '0' when sda_buf = '0' else 'Z';

	data_out <= r_data;
	nak <= nack;
	arbl <= arb_lost;
	

	-- Bus busy detection
sense:
	process(clk)
	begin
		if rising_edge(clk) then
			sda_sns_d <= sda_sns;
		end if;
	end process;

	-- SDA sense signal:
	sda_sns <= '0' when sda = '0' else '1';

	is_start <= (not sda_sns and sda_sns_d) when scl /= '0' else '0';
	is_stop  <= (sda_sns and not sda_sns_d) when scl /= '0' else '0';

	-- The master state machine
fsm:
	process(clk, reset)
		variable lastbit : boolean;
	begin
		if rising_edge(clk) then
			ack_stb <= '0'; -- default
			if reset = '1' then
				state <= S_IDLE;
				arb_lost <= '0';
				bitcount <= "000";
				ack_n <= '1';
			else -- {
				case state is -- {
					when S_IDLE =>
						if is_start = '1' then
							state <= S_BUSY;
						elsif enable = '1' then
							txd <= addr & rw;
							r_rw <= rw;
							state <= S_TRY;
						else
							state <= S_IDLE;
						end if;
					when S_BUSY =>
						if is_stop = '1' then
							-- Resume:
							state <= S_WAIT;
						end if;
					when S_TRY =>
						-- Start, when we do not collide:
						arb_lost <= '0';
						if sda /= '0' then
							state <= S_START;
						else
							state <= S_ERROR;
						end if;
					when S_HOLD =>
						if hold = '0' then
							state <= S_PAUSE;
						end if;
					when S_NEXT =>
						if hold = '1' then
							state <= S_HOLD;
						elsif enable = '1' then
							-- If we changed direction, fire restart cond
							if rw /= r_rw then
								txd <= addr & rw;
								r_rw <= rw;
								state <= S_START;
							elsif rw = '0' then
								txd <= data_in;
								state <= S_WRITE;
							else
								state <= S_READ;
							end if;
						else
							state <= S_STOP;
						end if;
					when S_RESUME =>
						if r_rw = '0' then
							txd <= data_in;
							state <= S_WRITE;
						else
							state <= S_READ;
						end if;
					when S_ERROR =>
						arb_lost <= '1';
						state <= S_IDLE;
					when others =>
						-- All other states change sync to SCL:
						if (is_period and phase(2) and phase(3)) = '1' then -- {
							if bitcount = "111" then
								lastbit := true;
							else
								lastbit := false;
							end if;

							case state is
								when S_START =>
									-- When another master is firing a start,
									-- enter busy state. When stop is issued by other
									-- master, resume.
									if rw = '1' then
										state <= S_READ;
									else
										state <= S_ADDR;
									end if;
									bitcount <= "000";
								when S_ADDR =>
									if lastbit then
										state <= S_ACK_A;
									else
										state <= S_ADDR;
									end if;
									txd <= txd(6 downto 0) & '1';
									bitcount <= bitcount + 1;
								-- Slave ack
								when S_ACK_A =>
									state <= S_RESUME;
									ack_stb <= '1';
								when S_WRITE =>
									if lastbit then
										state <= S_ACK_B;
									else
										state <= S_WRITE;
									end if;
									txd <= txd(6 downto 0) & '1';
									bitcount <= bitcount + 1;
								when S_READ =>
									if lastbit then
										if enable = '1' and rw = '1' then
											ack_n <= '0'; -- ACK
										else
											ack_n <= '1'; -- NAK
										end if;
										r_data <= rxd;
										state <= S_MACK;
									else
										state <= S_READ;
									end if;
									bitcount <= bitcount + 1;
								when S_ACK_B =>
									state <= S_NEXT;
									ack_stb <= '1';
								when S_MACK =>
									state <= S_NEXT;
									ack_stb <= '1';
								when S_PAUSE =>
									state <= S_RESUME;
								when S_WAIT =>
									state <= S_IDLE;
								when S_STOP =>
									state <= S_IDLE;
-- synthesis translate_off
								when others =>
									assert false report "Illegal state";
-- synthesis translate_on
							end case;
						end if; -- }
					end case; -- }
			end if; -- }
		end if; -- rising edge
	end process;

read:
	process(clk)
		-- Convert open collector input to proper 0 and 1
		-- (simulate a pull up)
		function my_to_X01(oc : std_logic) return std_logic is
			begin
				if oc = '0' then
				return '0';
			else
				return '1';
			end if;
		end function;
	begin
		-- This process immediately (one half cycle later)
		-- reacts to the state set by 'fsm'
		if rising_edge(clk) then
			if reset = '1' then
				nack <= '0';
				scl_en <= '0';
			elsif (is_period and phase(3) and phase(0)) = '1' then
				case state is
					when S_START =>
						nack <= '0';
						scl_en <= '1';
					when S_ACK_A | S_ACK_B =>
						if sda /= '0' then
							nack <= '1';
							scl_en <= '0';
						end if;
					when S_WRITE | S_RESUME =>
						scl_en <= '1';
					when S_READ =>
						scl_en <= '1';
						rxd <= rxd(6 downto 0) & my_to_X01(sda);
					when S_STOP | S_WAIT | S_HOLD =>
						scl_en <= '0';
					when others =>
						-- keep scl_en
				end case;
			end if;
		end if;
	end process;

end behaviour;
