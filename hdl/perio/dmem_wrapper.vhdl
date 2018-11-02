-- Scratch pad data memory, 2x8 bit config only
--
-- This file is in the OpenSource
--
-- (c) 2012-2018 <hackfin@section5.ch>
--

library IEEE;
	use IEEE.std_logic_1164.all;
	use IEEE.numeric_std.all;

library work;
	use work.system_map.all;
	use work.busdef.all; -- Wishbone defs
	use work.ram.all; -- RAM lib

entity dmem_wrapper is
	generic (
		MEM_HIGH_ADDR_BIT : natural := 11
	);
	port (
		ce         : in  std_logic;
		high       : in  std_logic;
		low        : in  std_logic;
		bus_in     : in  wb_WritePort;
		data_out   : out unsigned(16-1 downto 0);
		reset      : in  std_logic;
		clk        : in  std_logic
	);
	
end dmem_wrapper;

architecture behaviour of dmem_wrapper is
	signal we         : std_logic;
	signal we_hl      : std_logic_vector(1 downto 0);
	signal bus_cycle  : std_logic;
	signal host_addr  : unsigned(MEM_HIGH_ADDR_BIT-1 downto 1);

	subtype dbus_t is unsigned(8-1 downto 0);
	type dout_ar_t is array (integer range 0 to 1) of dbus_t;
	signal dout : dout_ar_t;

begin

	bus_cycle <= ce and bus_in.stb;
	we <= bus_cycle and bus_in.we;

	we_hl <= high & low;

dmem_2x8_generate:
	for i in 0 to 1 generate

mem_unit:
	entity work.bram_2psync
	generic map (ADDR_W => MEM_HIGH_ADDR_BIT-1, DATA_W => 8)
	port map (
		clk     => clk,
		-- Port A
		a_we    => we_hl(i),
		a_addr  => host_addr,
		a_write => bus_in.dat((i+1)*8-1 downto i*8),
		a_read  => dout(i),
		-- Port B
		b_we    => '0',
		b_addr  => (others => 'X'),
		b_write => x"00",
		b_read  => open
	);
	
	end generate;

	host_addr <= bus_in.adr(MEM_HIGH_ADDR_BIT-1 downto 1);

	data_out <= dout(1) & dout(0);

----------------------------------------------------------------------------

end behaviour;
