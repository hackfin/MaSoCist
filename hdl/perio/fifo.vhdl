------------------------------------------------
-- This is a VHDL template file generated from
-- ../../hdl/plat/dombert.xml
-- using coretempl.xsl
--
-- (c) 2012-2013, Martin Strubel // hackfin@section5.ch
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
--  System map definitions:
	use work.system_map.all;
library ghdlex;
	use ghdlex.ghpi_netpp.all;
	use ghdlex.virtual.all;

entity fifo_core is
	generic (WORDSIZE : natural := 2);
	port (
	-- Port export for fifoio pseudo register
		wready               : out    std_logic;
		rready               : out    std_logic;

		data_in              : in     std_logic_vector(7 downto 0);
		data_out             : out    std_logic_vector(7 downto 0);
		re                   : in     std_logic;
		we                   : in     std_logic;
		-- Standard ports:
		ctrl      : in  fifo_WritePort;
		stat      : out fifo_ReadPort;

		clk       : in std_logic
	);
end entity fifo_core;


architecture behaviour of fifo_core is
	signal int_data : std_logic_vector(7 downto 0);
	signal int_rready : std_logic;
begin

fifo: VirtualFIFO
	generic map (WORDSIZE => WORDSIZE, FIFOSIZE => 64)
	port map (
		clk         => clk,
		throttle    => '0',
		wr_ready    => wready,
		rd_ready    => int_rready,
		wr_enable   => we,
		rd_enable   => re,
		data_in     => int_data,
		data_out    => data_in
	);

	-- Because our FIFO is "first fall through" style, we
	-- insert a delay to be "RAM" alike, i.e. first valid data
	-- upon first 're' assertion

delay_fifodata:
	process (clk)
	begin
		if rising_edge(clk) then
			if re = '1' then
				data_out <= int_data;
			end if;
			rready <= int_rready;
		end if;
	end process;

end architecture;

