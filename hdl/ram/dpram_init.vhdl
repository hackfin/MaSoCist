-- Implementation of dual port RAM, Xilinx compatible
-- Initializeable dual port ram, one clock
-- Martin Strubel <hackfin@section5.ch>
--
--
-- --! MUST pass INIT_DATA, otherwise it will crash.

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.ram.all;

entity DPRAM16_init_ce is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		INIT_DATA   : ram16_init_t := ( 0 => (others => '0'));
		SYN_RAMTYPE : string := "block_ram"
	);
	port (
		clk     : in  std_logic;
		-- Port A
		a_ce    : in  std_logic;
		a_we    : in  std_logic;
		a_addr  : in  unsigned(ADDR_W-1 downto 0);
		a_write : in  unsigned(DATA_W-1 downto 0);
		a_read  : out unsigned(DATA_W-1 downto 0);
		-- Port B
		b_ce    : in  std_logic;
		b_we    : in  std_logic;
		b_addr  : in  unsigned(ADDR_W-1 downto 0);
		b_write : in  unsigned(DATA_W-1 downto 0);
		b_read  : out unsigned(DATA_W-1 downto 0)
	);
end entity DPRAM16_init_ce;

architecture behaviour of DPRAM16_init_ce is
	type dpram_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);

	impure function ram_init (data : in ram16_init_t) return dpram_t is
		variable r : dpram_t;
	begin
		assert (dpram_t'length = data'length) report "Init data size mismatch"
			severity failure;
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
	process (clk)
		variable index: integer;
	begin
		-- FIXME: catch Dualport write violations
		if rising_edge(clk) then
			if a_ce = '1' then
				index := to_integer(a_addr);
				if a_we = '1' then
					ram(index) := a_write;
					a_read <= a_write;
				else
					a_read <= ram(index);
				end if;
			end if;
		end if;
	end process;

portb_proc:
	process (clk)
		variable index: integer;
	begin
		if rising_edge(clk) then
			if b_ce = '1' then
				index := to_integer(b_addr);
				if b_we = '1' then
					ram(index) := b_write;
					b_read <= b_write;
				else
					b_read <= ram(index);
				end if;
			end if;
		end if;
	end process;

end architecture behaviour;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.ram.all;

entity DPRAM32_init is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 32;
		INIT_DATA   : ram32_init_t := (0 => x"00000000");     --! No default!
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
end entity DPRAM32_init;

architecture behaviour of DPRAM32_init is
	type dpram_t is array (integer range 0 to 2**ADDR_W-1) of
		unsigned(DATA_W-1 downto 0);

	impure function ram_init (data : in ram32_init_t) return dpram_t is
		variable r : dpram_t;
	begin
		assert (dpram_t'length = data'length) report "Init data size mismatch"
			severity failure;
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
----------------------------------------------------------------------------
-- RAM wrapper

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.ram.all;


entity DPRAM16_init is
	generic (
		ADDR_W      : natural := 6;
		DATA_W      : natural := 16;
		INIT_DATA   : ram16_init_t := ( 0 => (others => '0'));
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
end entity DPRAM16_init;

architecture behaviour of DPRAM16_init is
begin
	wrap:
		entity work.DPRAM16_init_ce
		generic map (
			ADDR_W      => ADDR_W,
			DATA_W      => DATA_W,
			INIT_DATA   => INIT_DATA,
			SYN_RAMTYPE => SYN_RAMTYPE
		)
		port map (
			clk => clk,
			-- Port A
			a_ce    => '1',
			a_we    => a_we,
			a_addr  => a_addr,
			a_write => a_write,
			a_read  => a_read,
			-- Port B
			b_ce    => '1',
			b_we    => b_we,
			b_addr  => b_addr,
			b_write => b_write,
			b_read  => b_read

		);
end behaviour;

