-- Gray counter / coding package
--

library ieee;
use ieee.std_logic_1164.all;

package fifoemu is

component fifo_clk2 is
	generic (
		ADDR_W            : natural := 5;
		DATA_W            : natural := 16;
		INDEX_NULL         : integer := 0;
		INDEX_ALMOST_EMPTY : integer := 1;
		INDEX_ALMOST_FULL  : integer := 31
	);
	port (
		-- Input:
		--! Clock input
		clkin        : in  std_logic;
		--! Write enable (write data and advance input pointer)
		wren         : in  std_logic;
		--! Input data
		idata        : in  std_logic_vector(DATA_W-1 downto 0);
		-- Data stream output:
		--! Output    clock
		clkout       : in  std_logic;
		--! Read enable. Data is valid AFTER one cycle!
		rden         : in  std_logic;
		--! Output data
		odata        : out std_logic_vector(DATA_W-1 downto 0);
		-- States:   
		--! Asserts HIGH when nothing is in the FIFO
		empty        : out std_logic;
		--! Asserts HIGH one word before the FIFO is full
		full         : out std_logic;
		almost_empty : out std_logic;
		almost_full  : out std_logic;

		--! Asserts HIGH when a write in FULL state occured
		--! (FIFO overrun). This bit is only cleared by a reset pulse
		overrun      : out std_logic;
		underrun     : out std_logic;
		reset        : in  std_logic             --! Reset, active H
	);
end component fifo_clk2;

end package fifoemu;

