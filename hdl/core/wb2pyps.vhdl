-- Wishbone to PyPS bridge

-- Lazy implementation

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
	use work.busdef.all;


entity wb2pyps is
	generic (
		WORD_SIZE  : natural   := 32     -- 32 bits data path
	);
	port (
		clk      : in std_logic;
		addr     : in unsigned(31 downto 0);
		we       : in std_logic;
		re       : in std_logic;
		sz       : in unsigned(1 downto 0); -- Word size
		din      : in unsigned(WORD_SIZE-1 downto 0);
		dout     : out unsigned(WORD_SIZE-1 downto 0);
		wb_in    : in wb_ReadPort;
		wb_out   : out wb_WritePort;
		reset    : in std_logic
	);

end wb2pyps;

architecture behaviour of wb2pyps is

	signal wb_cyc   : std_logic;
	-- signal we_buf     : std_logic;
	signal io_req   : std_logic; -- I/O request
	signal io_req_d : std_logic; -- delayed

begin

	wb_cyc <= io_req;
	io_req <= we or re;

	wb_out.adr <= addr;
	wb_out.cyc <= wb_cyc;
	wb_out.stb <= io_req;

	-- Simple size translation:
	with sz select wb_out.sel <= "0001" when "00", -- Byte access
                                 "0011" when "01", -- Word access,
                                 "1111" when others;
	wb_out.rst <= reset;

	wb_out.dat  <= din;
	wb_out.we   <= we;

	dout <= unsigned(wb_in.dat);


end architecture behaviour;
