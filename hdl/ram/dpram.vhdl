-- Implementation of dual port RAM, Xilinx compatible
-- Martin Strubel <hackfin@section5.ch>
--
-- Part of the buffer package
-- Warning: Does not synthesize well on Lattice ECP3 into DP* primitives, use
-- dpram_wrapper.vhdl and dpram_clk2.vhdl instead.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DPRAM_sync is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		EN_BYPASS   : boolean := false;
		SYN_RAMTYPE : string := "block_ram"
	);
	port (
		clk   : in  std_logic;
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
end entity DPRAM_sync;

architecture behaviour of DPRAM_sync is
	type dpramc2_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);

	shared variable ram : dpramc2_t;

	attribute syn_ramstyle : string;
	attribute syn_ramstyle of ram : variable is SYN_RAMTYPE;

begin

dualport_proc:
	process (clk)
		variable index_a: integer;
		variable index_b: integer;
	begin
		if rising_edge(clk) then
			index_b := to_integer(b_addr);
			index_a := to_integer(a_addr);

			a_read <= ram(index_a);
			b_read <= ram(index_b);

			if b_we = '1' then
				if a_we = '1' then
-- synthesis translate_off
					if index_a = index_b then
						assert false report "Write violation"
						severity failure;
					end if;
-- synthesis translate_on
					ram(index_a) := a_write;
					a_read <= a_write;
				end if;
				-- Feed through to channel A, if we wrote
				if EN_BYPASS then
					if index_a = index_b then
						a_read <= b_write;
					end if;
				end if;
				ram(index_b) := b_write;
				if EN_BYPASS then
					b_read <= b_write;
				end if;
			elsif a_we = '1' then
				-- Feed through to channel B, if we wrote
				if EN_BYPASS then
					if index_b = index_a then
						b_read <= a_write;
					end if;
				end if;

				ram(index_a) := a_write;
				if EN_BYPASS then
					a_read <= a_write;
				end if;
			end if;
		end if;
	end process;

end architecture behaviour;
