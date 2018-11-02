define pwmcfg
	set $base = (char *) $PWM_Offset
	set $i = $arg0 << ($MMR_SELECT_DEVINDEX_PWM_SHFT - 2)
	set $r = $Reg_PWM_PWM_CONFIG
	if $arg1
		set $r[$i] = $DEFAULT
	else
		set $r[$i] = 0
	end
end

define pwmset
	set $base = (char *) $PWM_Offset
	set $i = $arg0 << ($MMR_SELECT_DEVINDEX_PWM_SHFT - 2)
	set $r = &$Reg_PWM_PWM_WIDTH[$i]
	set $r[0] = $arg1 - 1
	set $r = &$Reg_PWM_PWM_PERIOD[$i]
	set $r[0] = $arg2 - 1
end

define pwmdiv
set $Reg_TIMER_TIMER_CONFIG = $arg0 | $CRESET
end

define pwmen
	set $which = 1 << $arg0
	if $arg1 == 1
		set *$Reg_TIMER_TIMER_START = $which
	else
		set *$Reg_TIMER_TIMER_STOP = $which
	end
end

define test_pwm
	set *$Reg_TIMER_TIMER_STOP = 0xff
	pwmdiv 2
	pwmset 0 10 2
	pwmset 1 10 5
	pwmcfg 2 1
	# pwmcfg 3 1
	pwmset 2 10 2
	# pwmset 3 10 5
	set *$Reg_TIMER_TIMER_START = 0x0f
	set *$Reg_TIMER_TIMER_STOP = 0x03
	pwmset 0 10 8
	set *$Reg_TIMER_TIMER_START = 0x03
end

############################################################################

doc pwmcfg
	Usage: <pwmno> <0/1>
	Configure the default pin state of the PWM #<pwmno>
end

doc pwmen
	Usage: <pwmno> <0/1>
	Use this command to turn on/off a specific PWM
end

doc pwmset
	Usage: pwmset <pwmno> <width> <period>
	Set PWM properties for a specific PWM. To turn on/off the PWM,
	use the 'pwmen' command.
end

doc pwmdiv
	Set the global PWM clock divider. By default, all writes to the
	PWM divider register reset the counters.
end


