-- Implementation of dual port RAM, Xilinx compatible
-- Initializeable dual port ram, dual clock
-- Martin Strubel <hackfin@section5.ch>
--
-- Note: This RAM is NOT async FIFO-safe. Must guard write/read collisions
-- and writethrough conditions EXTERNALLY!!!
--
-- --! MUST pass INIT_DATA, otherwise it will crash.

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.ram.all;

entity DPRAMc2_init is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		INIT_DATA   : ram16_init_t;     --! No default!
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
end entity DPRAMc2_init;

architecture behaviour of DPRAMc2_init is
	type dpram_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);

	impure function ram_init (data : in ram16_init_t) return dpram_t is
		variable r : dpram_t;
	begin
-- synthesis translate_off
	-- XXX	assert (dpram_t'length = data'length) report "Init data size mismatch"
	-- XXX		severity failure;
-- synthesis translate_on
		for i in dpram_t'range loop
			r(i) := data(i)(DATA_W-1 downto 0);
		end loop;
		return r;
	end function;

	shared variable ram : dpram_t := ram_init(INIT_DATA);

	attribute syn_ramstyle : string;
	attribute syn_ramstyle of ram : variable is SYN_RAMTYPE;
begin

porta_proc:
	process (a_clk)
		variable index: integer;
	begin
		-- FIXME: catch Dualport write violations
		if rising_edge(a_clk) then
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
	process (b_clk)
		variable index: integer;
	begin
		if rising_edge(b_clk) then
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
