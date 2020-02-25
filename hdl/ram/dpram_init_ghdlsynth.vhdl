-- Implementation of dual port RAM, GHDL synthesis VHDL_STD=08
-- Initializeable dual port ram, one clock
-- Martin Strubel <hackfin@section5.ch>
--
-- Note: hread() not supported for VHDL-93
--

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

	use std.textio.all;

library work;
	use work.ram.all;

entity DPRAM_init_hex_ce is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		INIT_HEX    : string  := "ram_init16.hex";
		SYN_RAMTYPE : string  := "block_ram"
	);
	port (
		a_clk   : in  std_logic;
		-- Port A
		a_ce    : in  std_logic;
		a_we    : in  std_logic;
		a_addr  : in  unsigned(ADDR_W-1 downto 0);
		a_write : in  unsigned(DATA_W-1 downto 0);
		a_read  : out unsigned(DATA_W-1 downto 0);
		-- Port B
		b_clk   : in  std_logic;
		b_ce    : in  std_logic;
		b_we    : in  std_logic;
		b_addr  : in  unsigned(ADDR_W-1 downto 0);
		b_write : in  unsigned(DATA_W-1 downto 0);
		b_read  : out unsigned(DATA_W-1 downto 0)
	);
end entity DPRAM_init_hex_ce;

architecture behaviour of DPRAM_init_hex_ce is

type ram_t is array(0 to 2**ADDR_W-1) of unsigned(DATA_W-1 downto 0);


	impure function init_ram(name : string) return ram_t is
		file hexfile : text open read_mode is name;
		variable l : line;
		variable hw : std_logic_vector(15 downto 0);
		variable initmem : ram_t := (others => (others => '0'));
	begin
		for i in 0 to 2**ADDR_W-1 loop
			exit when endfile(hexfile);
			readline(hexfile, l);
			report "read: " & l.all;
			hread(l, hw);
			initmem(i) := unsigned(hw);
		end loop;

		return initmem;
	end function;

	signal mem: ram_t := init_ram(INIT_HEX);

begin

porta_proc: process (a_clk) is
begin
    if rising_edge(a_clk) then
        if a_ce = '1' then
			if a_we = '1' then
				mem(to_integer(a_addr)) <= a_write;
				a_read <= a_write;
			else
				a_read <= mem(to_integer(a_addr));
			end if;
        end if;
    end if;
end process;

portb_proc: process (b_clk) is
begin
    if rising_edge(b_clk) then
        if b_ce = '1' then
			b_read <= mem(to_integer(b_addr));
		end if;
    end if;
end process;


end architecture behaviour;

