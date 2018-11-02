-- GPIO with separate I/O ports


library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.system_map.all;

entity gpio_core is
	port (
		ctrl      : in gpio_WritePort;
		stat      : out gpio_ReadPort;

		gpio_in   : in  std_logic_vector(16-1 downto 0);
		gpio_out  : out std_logic_vector(16-1 downto 0);
		gpio_dir  : out std_logic_vector(16-1 downto 0);

		clk       : in std_logic
	);
end entity;

architecture behaviour of gpio_core is
	
	signal gpio_value : std_logic_vector(15 downto 0);

begin


	stat.gpio_out <= unsigned(gpio_value);
	stat.gpio_in <= unsigned(gpio_in);
	gpio_dir <= std_logic_vector(ctrl.gpio_dir);
	gpio_out <= gpio_value;

	process (clk)
	begin
		if rising_edge(clk) then
			 if ctrl.select_gpio_out = '1' then
			 	gpio_value <= std_logic_vector(ctrl.gpio_out);
			 elsif ctrl.select_gpio_clr = '1' then
			 	gpio_value <= gpio_value and not std_logic_vector(ctrl.gpio_clr);
			 elsif ctrl.select_gpio_set = '1' then
			 	gpio_value <= gpio_value or std_logic_vector(ctrl.gpio_set);
			 elsif ctrl.select_gpio_out = '1' then
			 	gpio_value <= std_logic_vector(ctrl.gpio_out);
			 end if;
		end if;
	end process;

end architecture;
