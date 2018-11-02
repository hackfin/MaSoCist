-- Simple timer core
-- (c) 2014, 2015 Martin Strubel <hackfin@section5.ch>
--
-- Part of the OpenSource MaSoCist environment
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
	use work.system_map.all;
	use work.global_config.all;

entity tmr_core is
	generic (NUM_PWM : natural := CONFIG_NUM_TMR);
	port (
		pwm_enable : out unsigned(NUM_PWM-1 downto 0);
		pwm_clken  : out std_logic;
		ctrl       : in tmr_WritePort;
		stat       : out tmr_ReadPort;
		clk        : in std_logic
	);
end tmr_core;

architecture behaviour of tmr_core is
	constant COUNT_ZERO : unsigned(16-1 downto 0) := (others => '0');

	signal enable   : unsigned(NUM_PWM-1 downto 0) := (others => '0');
	signal counter  : unsigned(16-1 downto 0) := COUNT_ZERO;

begin

	pwm_enable <= enable;

	process (clk)
	begin
		if rising_edge(clk) then
			if ctrl.select_timer_stop = '1' then
			 	enable <= enable and not
					ctrl.timer_stop(NUM_PWM-1 downto 0);
			elsif ctrl.select_timer_start = '1' then
			 	enable <= enable or
					ctrl.timer_start(NUM_PWM-1 downto 0);
			end if;
		end if;
	end process;

	pwm_clken <= '1' when counter = COUNT_ZERO else '0';

clkdiv:
	process (clk)
	begin
		if rising_edge(clk) then
			if ctrl.creset = '1' and ctrl.select_timer_start = '1' then
				counter <= (others => '0');
			elsif counter = ctrl.pwmclkdiv then
				counter <= (others => '0');
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;

end behaviour;
