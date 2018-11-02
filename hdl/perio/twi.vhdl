------------------------------------------------
-- This is a VHDL template file generated from
-- ../../hdl/plat/dombert.xml
-- using coretempl.xsl
-- Changes to this file MAY BE LOST. Copy, edit, and remove this line.
--
-- (c) 2012-2013, Martin Strubel // hackfin@section5.ch
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
--  System map definitions:
	use work.system_map.all; -- XXX Please edit


entity twi_core is
	port (
	-- Port export for twio pseudo register
		sclk                 : in     std_logic; --! System clock
		sda                  : inout  std_logic; --! Serial data
		scl                  : inout  std_logic; --! Serial clock

		ctrl      : in  twi_WritePort;
		stat      : out twi_ReadPort;

		clk       : in std_logic
	);
end entity twi_core;


architecture behaviour of twi_core is

	subtype byte_t  is unsigned(7 downto 0);
	type    state_t is (S_IDLE, S_CMD, S_NEXT, S_ADVANCE, S_RUN, S_LAST);

	signal  nbytes      : unsigned(6 downto 0);
	signal  state       : state_t := S_IDLE;
	signal  ack_strobe  : std_logic;
	signal  ready       : std_logic;
	signal  enable      : std_logic;
	signal  enable_c2   : std_logic;
	signal  scl_z       : std_logic;
	signal  sda_z       : std_logic;
	signal  arb         : std_logic;
	signal  busy        : std_logic;

	signal  strobe      : std_logic;

	signal  scl_buffer, sda_buffer : std_logic_vector(3 downto 0) := "1111";
	signal  scl_debounced, sda_debounced : std_logic;

begin

	strobe <= ctrl.select_twi_wdata or
		(ctrl.select_twi_rdata and ctrl.autoarm);



	stat.busy  <= not ready;
	-- stat.debug      <= '0' when state = S_IDLE else '1';
	-- stat.iready <= ready;


debounce:
	process(sclk)
		function my_to_X01(oc : std_logic) return std_logic is
		begin
			if oc = '0' then return '0';
			else return '1';
			end if;
		end function;

	begin
		if rising_edge(sclk) then
			scl_buffer <= scl_buffer(2 downto 0) & my_to_X01(scl);
			sda_buffer <= sda_buffer(2 downto 0) & my_to_X01(sda);
			
			if sda_buffer = "1000" then
				sda_debounced <= '0';
			elsif sda_buffer = "0111" then
				sda_debounced <= '1';
			end if;

			if scl_buffer = "1000" then
				scl_debounced <= '0';
			elsif scl_buffer = "0111" then
				scl_debounced <= '1';
			end if;

		end if;
	end process;


i2c:
	entity work.i2c_master
	port map (


		reset       => ctrl.i2c_reset,
		clk         => sclk,
		data_in     => ctrl.twi_wdata,
		data_out    => stat.twi_rdata,
        stat_arbl   => stat.arb,
		stat_inack  => stat.inack,
        stat_stretch    => stat.stretch,
        stat_nak        => stat.nak,
        stat_ready      => ready,
        -- stat_bus_busy   => stat.bus_busy,
        stat_hold       => stat.inhold,
        stat_fetch      => open,
        ctrl_enable     => strobe,
        ctrl_ack        => ctrl.mack,
        ctrl_sladdr     => ctrl.slaveaddr,
        ctrl_read       => ctrl.read,
        ctrl_hold       => ctrl.hold,
        ctrl_divider    => unsigned(ctrl.twi_div),
        sport_sdao      => sda_z,
        sport_scli      => scl_debounced,
        sport_sclo      => scl_z,
        sport_sdai      => sda_debounced
	);

	-- stat.level <= '0' when sda = '0' else '1';

	-- Open collector:
	scl <= '0' when scl_z = '0' else 'Z';
	sda <= '0' when sda_z = '0' else 'Z';

	
end architecture;
