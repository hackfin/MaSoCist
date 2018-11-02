library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkdiv is
	generic ( DIVIDER_SIZE : natural := 16;
	          PREDIV_LEN   : natural := 4);
	port (
		enable        : in std_logic;
		bypass        : in std_logic;
		clk           : in std_logic;
		divclk        : out std_logic;
		divclk_strobe : out std_logic;
		phase         : in unsigned(PREDIV_LEN-1 downto 0);
		divider       : in unsigned(DIVIDER_SIZE-1 downto 0)
	);
end clkdiv;

architecture behaviour of clkdiv is
	signal pre_count: unsigned(PREDIV_LEN-1 downto 0) := (others => '0');
	signal counter  : unsigned(DIVIDER_SIZE-1 downto 0) := (others => '0');

	signal clk_int  : std_logic;
	signal strobe   : std_logic;

begin


-- Clock divider:
clkdiv_worker:
	process (clk)
	begin
		if rising_edge(clk) then
			if enable = '0' then
				counter <= (others => '0');
				pre_count <= (others => '0');
			elsif counter = divider then
				counter <= (others => '0');
				pre_count <= pre_count + 1;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;

	strobe <= '1' when pre_count = phase and counter = divider else '0';
	divclk_strobe <= strobe when bypass = '0' else enable;

	clk_int <= clk when bypass = '1' else pre_count(PREDIV_LEN-1);
	divclk <= clk_int;

end behaviour;
