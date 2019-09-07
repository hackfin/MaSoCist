library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
	use work.pp_types.all;

package potato_pkg is

component pp_potato
	generic(
		PROCESSOR_ID           : std_logic_vector(31 downto 0) := x"00000000"; --! Processor ID.
		RESET_ADDRESS          : std_logic_vector(31 downto 0) := x"00000000"; --! Address of the first instruction to execute.
		MTIME_DIVIDER          : positive                      := 5;           --! Divider for the clock driving the MTIME counter.
		ICACHE_ENABLE          : boolean                       := true;        --! Whether to enable the instruction cache.
		ICACHE_LINE_SIZE       : natural                       := 4;           --! Number of words per instruction cache line.
		ICACHE_NUM_LINES       : natural                       := 128          --! Number of cache lines in the instruction cache.
	);
	port(
		clk       : in std_logic;
		timer_clk : in std_logic;
		reset     : in std_logic;

		-- Interrupts:
		irq : in std_logic_vector(7 downto 0);

		-- Test interface:
		test_context_out : out test_context;

		-- Wishbone interface:
		wb_adr_out : out std_logic_vector(31 downto 0);
		wb_sel_out : out std_logic_vector( 3 downto 0);
		wb_cyc_out : out std_logic;
		wb_stb_out : out std_logic;
		wb_we_out  : out std_logic;
		wb_dat_out : out std_logic_vector(31 downto 0);
		wb_dat_in  : in  std_logic_vector(31 downto 0);
		wb_ack_in  : in  std_logic
	);
end component pp_potato;


component pp_core
	generic(
		PROCESSOR_ID           : std_logic_vector(31 downto 0) := x"00000000"; --! Processor ID.
		RESET_ADDRESS          : std_logic_vector(31 downto 0) := x"00000000"; --! Address of the first instruction to execute.
		MTIME_DIVIDER          : positive := 5                                 --! Divider for the clock driving the MTIME counter
	);
	port(
		-- Control inputs:
		clk       : in std_logic; --! Processor clock
		reset     : in std_logic; --! Reset signal

		timer_clk : in std_logic; --! Clock used for the timer/counter

		-- Instruction memory interface:
		imem_address : out std_logic_vector(31 downto 0); --! Address of the next instruction
		imem_data_in : in  std_logic_vector(31 downto 0); --! Instruction input
		imem_req     : out std_logic;
		imem_ack     : in  std_logic;

		-- Data memory interface:
		dmem_address   : out std_logic_vector(31 downto 0); --! Data address
		dmem_data_in   : in  std_logic_vector(31 downto 0); --! Input from the data memory
		dmem_data_out  : out std_logic_vector(31 downto 0); --! Ouptut to the data memory
		dmem_data_size : out std_logic_vector( 1 downto 0);  --! Size of the data, 1 = 8 bits, 2 = 16 bits, 0 = 32 bits. 
		dmem_read_req  : out std_logic;                      --! Data memory read request
		dmem_read_ack  : in  std_logic;                      --! Data memory read acknowledge
		dmem_write_req : out std_logic;                      --! Data memory write request
		dmem_write_ack : in  std_logic;                      --! Data memory write acknowledge

		-- Test interface:
		test_context_out : out test_context;                 --! Test context output.

		-- External interrupt input:
		irq : in std_logic_vector(7 downto 0) --! IRQ inputs.
	);
end component;

end potato_pkg;
