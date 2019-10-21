-- Block RAM memory library, rather MIPS specific
-- 2008-2012 hackfin@section5.ch
--
-- This block ram is somewhat generic and synthesizes properly with
-- the Xilinx toolchain so far.
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.global_config.all;

package memory is
	-- For the 32 bit wide memory, we use:
	constant ADDR_W_32 : integer := CONFIG_BRAM_ADDR_WIDTH-2;
	constant ADDR_W_16 : integer := CONFIG_BRAM_ADDR_WIDTH-2;
	constant ADDR_W_8  : integer := CONFIG_BRAM_ADDR_WIDTH-2;
	constant DRAM_ADDR_W  : integer := CONFIG_DRAM_ADDR_WIDTH-2;
	-- For encoding of endianness:
	subtype UPPER_WORD is integer range 31 downto 16;
	subtype LOWER_WORD is integer range 15 downto 0;

	subtype BYTE0      is integer range 7 downto 0;
	subtype BYTE1      is integer range 15 downto 8;
	subtype BYTE2      is integer range 23 downto 16;
	subtype BYTE3      is integer range 31 downto 24;

	type dpram16_t is array(natural range 0 to ((2**ADDR_W_32))-1)
	of unsigned(15 downto 0);

	type dpram8_t is array(natural range 0 to ((2**ADDR_W_32))-1)
	of unsigned(7 downto 0);

	-- Define memory bank types for initialization statements.
	-- See mem_init.chdl for details.
	-- Note: They differ from the above and are always 16 bit wide
	type dram_init_t is array(natural range 0 to 2**DRAM_ADDR_W-1)
		of unsigned(15 downto 0);

	type iram_init_t is array(natural range 0 to 2**ADDR_W_32-1)
		of unsigned(15 downto 0);

	type dram_bank_t is array(natural range 0 to 3)
		of dram_init_t;

	type iram_bank_t is array(natural range 0 to 1)
		of iram_init_t;


component DPRAM16
	generic(
		INITDATA     : dpram16_t := (others => x"0000")
	);
	port(
	clk     : in  std_logic;
	-- Port A
	a_we    : in  std_logic;
	a_addr  : in  unsigned(ADDR_W_16-1 downto 0);
	a_write : in  unsigned(16-1 downto 0);
	a_read  : out unsigned(16-1 downto 0);
	-- Port B
	b_we    : in  std_logic;
	b_addr  : in  unsigned(ADDR_W_16-1 downto 0);
	b_write : in  unsigned(16-1 downto 0);
	b_read  : out unsigned(16-1 downto 0));
end component;

component DPRAM8
	generic(
	   INITDATA     : dpram8_t := (others => x"00")
	);
	port(
		clk     : in  std_logic;
		-- Port A
		a_we    : in  std_logic;
		a_addr  : in  unsigned(ADDR_W_8-1 downto 0);
		a_write : in  unsigned(8-1 downto 0);
		a_read  : out unsigned(8-1 downto 0);
		-- Port B
		b_we    : in  std_logic;
		b_addr  : in  unsigned(ADDR_W_8-1 downto 0);
		b_write : in  unsigned(8-1 downto 0);
		b_read  : out unsigned(8-1 downto 0));
end component;

-- Generic configurable word width RAM with two clocks

component DPRAM_clk2
	generic(
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		SYN_RAMTYPE : string := "block_ram"
	);
	port(
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
	b_read  : out unsigned(DATA_W-1 downto 0));
end component;


end package;


