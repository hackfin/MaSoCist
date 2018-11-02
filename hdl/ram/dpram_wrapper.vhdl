-- DPRAM wrapper for ECP3 optimized DP Block RAM
--
-- Experimental.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DPRAM is
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
end entity DPRAM;

architecture behaviour of DPRAM is

begin

gen_distram:
if SYN_RAMTYPE = "distributed" generate
ram_wrap:
	entity work.DPRAM_sync
	generic map ( ADDR_W => ADDR_W, DATA_W => DATA_W,
		SYN_RAMTYPE => SYN_RAMTYPE )
	port map (
		clk   => clk,
		a_we    => a_we,
		a_addr  => a_addr,
		a_write => a_write,
		a_read  => a_read,
		b_we    => b_we,
		b_addr  => b_addr,
		b_write => b_write,
		b_read  => b_read
	);
end generate;

gen_bram:
if SYN_RAMTYPE = "block_ram" generate

ram_wrap:
	entity work.DPRAM_clk2
	generic map ( ADDR_W => ADDR_W, DATA_W => DATA_W,
		SYN_RAMTYPE => SYN_RAMTYPE )
	port map (
		a_clk   => clk,
		a_we    => a_we,
		a_addr  => a_addr,
		a_write => a_write,
		a_read  => a_read,
		b_clk   => clk,
		b_we    => b_we,
		b_addr  => b_addr,
		b_write => b_write,
		b_read  => b_read
	);
end generate;

end architecture behaviour;
