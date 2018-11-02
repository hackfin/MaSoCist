-- Simple PWM for FLIX controller
--
-- (c) 2013-2015, <hackfin@section5.ch>
--
-- Now part of MaSoCist environment
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
	use work.system_map.all;

entity pwm_core is
	port (
		pwmclk    : in std_logic;
		pwm_clken : in std_logic;
		ctrl      : in pwm_WritePort;
		stat      : out pwm_ReadPort;
		irq       : out std_logic;
		enable    : in std_logic;
		output    : out std_logic;
		clk       : in std_logic
	);
end pwm_core;

architecture behaviour of pwm_core is

	signal counter  : unsigned(16-1 downto 0) := (others => '0');

	signal outp     : std_logic := '0';
	signal default  : std_logic;

	-- Buffered signals:
	signal pwm_width   : unsigned(16-1 downto 0);
	signal pwm_period  : unsigned(16-1 downto 0);

	type state_type is (S_READY, S_RUNNING);

	signal state : state_type := S_READY;

begin

	default <= ctrl.default;

	output <= outp;

	stat.pwm_counter <= counter;
	stat.tmr_run <= '1' when state = S_RUNNING else '0';


	process (pwmclk)
	begin
		if rising_edge(pwmclk) then
			irq <= '0';
			if pwm_clken = '1' then
				case state is
				when S_READY =>
					if enable = '1' then 
						state <= S_RUNNING;
						pwm_period <= ctrl.pwm_period;
						pwm_width <= ctrl.pwm_width;
					end if;
					outp <= default;
					counter <= (others => '0'); -- <= ctrl.pwm_start;
				when S_RUNNING =>
					counter <= counter + 1;
					if counter = pwm_period then
						outp <= default;
						counter <= (others => '0'); -- ctrl.pwm_start;
						irq <= ctrl.tmr_irqen;
						-- Update PWM values to allow "live" modification
						pwm_period <= ctrl.pwm_period;
						pwm_width <= ctrl.pwm_width;

						if enable = '0' then
							state <= S_READY;
						end if;
					elsif counter = pwm_width then
						outp <= not default;
					end if;
				end case;
			end if;
		end if;
	end process;


end behaviour;
