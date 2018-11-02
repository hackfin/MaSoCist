-- Implementation of dual port RAM, Xilinx compatible

-- Warning: ISE 13.4 throws errors for Spartan6 on suspected concurrent
-- accesses (multiple driver collision)
-- Upgrade, or use another implementation :-)
--
-- Martin Strubel <hackfin@section5.ch>
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_2psync is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		SYN_RAMTYPE : string := "block_ram"
	);
	port (
		clk     : in  std_logic;
		-- Port A
		a_we    : in  std_logic;
		a_addr  : in  unsigned(ADDR_W-1 downto 0);
		a_write : in  unsigned(DATA_W-1 downto 0);
		a_read  : out unsigned(DATA_W-1 downto 0);
		-- Port B
		b_we    : in  std_logic;
		b_addr  : in  unsigned(ADDR_W-1 downto 0);
		b_write : in  unsigned(DATA_W-1 downto 0);
		b_read  : out unsigned(DATA_W-1 downto 0)
	);
end entity bram_2psync;

architecture behaviour of bram_2psync is
	type dpram_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);


	shared variable ram : dpram_t;

	-- Enable to implement RAM in logic: (testing only)
	attribute syn_ramstyle : string;
	attribute syn_ramstyle of ram : variable is SYN_RAMTYPE;

begin

porta_proc:
	process (clk)
		variable index: integer;
	begin
		-- FIXME: catch Dualport write violations
		if rising_edge(clk) then
			index := to_integer(a_addr);
			if a_we = '1' then
				ram(index) := a_write;
				a_read <= a_write;
			else
				a_read <= ram(index);
			end if;

		end if;
	end process;

portb_proc:
	process (clk)
		variable index: integer;
	begin
		if rising_edge(clk) then
			index := to_integer(b_addr);
			if b_we = '1' then
				ram(index) := b_write;
				b_read <= b_write;
			else
				b_read <= ram(index);
			end if;
		end if;
	end process;

end architecture behaviour;
