-- Wishbone to ZPU bus bridge:

-- Not sure if the timing is 100% according to the specs, they're kinda
-- fuzzy. But it works...

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.busdef.all;


entity wb2zpu is
	generic (
		WORD_SIZE  : natural   := 32     -- 32 bits data path
	);
	port (
		clk      : in std_logic;
		addr     : in unsigned(31 downto 0);
		we       : in std_logic;
		re       : in std_logic;
		din      : in unsigned(WORD_SIZE-1 downto 0);
		dout     : out unsigned(WORD_SIZE-1 downto 0);
		wb_in    : in wb_ReadPort;
		wb_out   : out wb_WritePort;
		reset    : in std_logic
	);

end wb2zpu;

architecture behaviour of wb2zpu is

	signal wb_cyc   : std_logic;
	signal din_buf  : unsigned(WORD_SIZE-1 downto 0);
	-- signal we_buf     : std_logic;
	signal io_req   : std_logic; -- I/O request
	signal io_req_d : std_logic; -- delayed

begin

	wb_cyc <= io_req or io_req_d;
	io_req <= we or re;

	wb_out.adr <= addr;
	wb_out.cyc <= wb_cyc;
	wb_out.stb <= io_req;
	wb_out.sel <= "1111";
	wb_out.rst <= reset;

	wb_out.dat  <= din when io_req_d = '0' else din_buf;
	-- wb_out.we   <= we  when io_req_d = '0' else we_buf;
	wb_out.we   <= we;
	wb_out.select_dat <= '0';

	-- Not nice: bad workaround to run correct WB timing:
we_delay:	
	process (clk)
	begin
		if rising_edge(clk) then
			io_req_d <= io_req;
			din_buf <= din;
			-- we_buf    <= we;
		end if;
	end process;

	dout <= unsigned(wb_in.dat);


end architecture behaviour;
