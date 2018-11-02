-- \file

--! \brief I2C engine
--! This is a small layer handling multi byte transfers to/from the
--! i2c master
--
-- (c) Martin Strubel <hackfin@section5.ch>
--
--

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.soc_iomap.all;

entity i2c_core is
	port (
		cclk      : in std_logic;
		sclk      : in std_logic;
		--! i2c SDA
		sda       : inout  std_logic;
		--! i2c SCL
		scl       : inout  std_logic;

		--! Configuration/Ctrl record:
		ctrl      : in  i2c_WritePort;
		--! Status record
		stat      : out i2c_ReadPort;

		--! Strobe this pin for action (read/write, depending on
		--! ctrl.read). Make sure ctrl.rxtx_ready is 1.
		strobe    : in std_logic
	);

end entity i2c_core;

architecture behaviour of i2c_core is

	subtype byte_t  is unsigned(7 downto 0);
	type    state_t is (S_IDLE, S_READY, S_RUN, S_WAIT, S_LAST);

	signal  nbytes      : unsigned(6 downto 0);
	signal  state       : state_t := S_IDLE;
	signal  hold        : std_logic;
	signal  ready       : std_logic;
	signal  enable      : std_logic;
	signal  enable_c2   : std_logic;
	signal  nak         : std_logic;

begin
	process(cclk)
	begin
		if rising_edge(cclk) then
			if ctrl.i2c_reset = '1' then
				state <= S_IDLE;
				hold <= '0';
			else
				case state is
					when S_IDLE =>
						enable <= '0';
						stat.busy <= '0';
						if strobe = '1' then
							nbytes <= unsigned(ctrl.nbytes);
							stat.busy <= '1';
							enable <= '1';
							state <= S_RUN;
						end if;
					when S_READY =>
						-- Cancel when we got a NAK
						if nak = '1' then
							state <= S_IDLE;
						-- Did we start another?
						elsif strobe = '1' then
							hold <= '0';
							stat.busy <= '1';
							state <= S_RUN;
						-- Nope, assert hold for next data
						else
							hold <= '1';
						end if;
					when S_RUN =>
						if ready = '0' then
							if nbytes = x"00" then
								stat.busy <= '1';
								state <= S_LAST;
							-- Is i2c running?
							else
								nbytes <= nbytes - 1;
								state <= S_WAIT;
							end if;
						end if;
					when S_WAIT =>
						if ready = '1' then
							stat.busy <= '0';
							state <= S_READY;
						end if;
					when S_LAST =>
						enable <= '0';
						if ready = '1' then
							stat.busy <= '0';
							state <= S_IDLE;
						end if;
				end case;
			end if;
		end if;
	end process;

	stat.rxtx_ready <= ready;
	stat.nak        <= nak;
	stat.hold       <= hold;

enable_latch:
	process(sclk)
	begin
		if rising_edge(sclk) then
			enable_c2 <= enable;
		end if;
	end process;

i2c:
	i2c_master
	port map (
		clk       => sclk,
		sda       => sda,
		scl       => scl,
		reset     => ctrl.i2c_reset,
		enable    => enable_c2,
		hold      => hold,
		addr      => ctrl.slaveaddr,
		rw        => ctrl.read,
		data_in   => ctrl.wdata,
		data_out  => stat.rdata,
		divider   => unsigned(ctrl.divider),
		ready     => ready,
		clkstr    => stat.stretch,
		inack     => stat.inack,
		nak       => nak
	);
	

end behaviour;
