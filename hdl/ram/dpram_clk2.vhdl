-- Implementation of dual port RAM, Xilinx compatible
-- Version with different in- and out clocks.
-- Martin Strubel <hackfin@section5.ch>
--
-- Part of the buffer package
-- WARNING: This RAM primitive does not check for concurrent writes
-- or reads.
-- When implementing a dual clock FIFO, the FIFO must handle the
-- access priority, preferrably using Gray Codes.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DPRAM_clk2 is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		EN_BYPASS   : boolean := true;
		SYN_RAMTYPE : string := "block_ram"
	);
	port (
		a_clk   : in  std_logic;
		-- Port A
		a_we    : in  std_logic;
		a_addr  : in  unsigned(ADDR_W-1 downto 0);
		a_write : in  unsigned(DATA_W-1 downto 0);
		a_read  : out unsigned(DATA_W-1 downto 0);
		-- Port B
		b_clk   : in  std_logic;
		b_we    : in  std_logic;
		b_addr  : in  unsigned(ADDR_W-1 downto 0);
		b_write : in  unsigned(DATA_W-1 downto 0);
		b_read  : out unsigned(DATA_W-1 downto 0)
	);
end entity DPRAM_clk2;

architecture behaviour of DPRAM_clk2 is
	type dpramc2_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);

	shared variable ram : dpramc2_t;
	attribute syn_ramstyle : string;
	attribute syn_ramstyle of ram : variable is SYN_RAMTYPE;

begin

porta_proc:
	process (a_clk)
		variable index: integer;
	begin
		if rising_edge(a_clk) then
			index := to_integer(a_addr);
			if a_we = '1' then
				ram(index) := a_write;
				if EN_BYPASS then
					a_read <= a_write;
				end if;
			else
				a_read <= ram(index);
			end if;
		end if;
	end process;

portb_proc:
	process (b_clk)
		variable index: integer;
	begin
		if rising_edge(b_clk) then
			index := to_integer(b_addr);
			if b_we = '1' then
				ram(index) := b_write;
				if EN_BYPASS then
					b_read <= b_write;
				end if;
			else
				b_read <= ram(index);
			end if;
		end if;
	end process;

end architecture behaviour;
