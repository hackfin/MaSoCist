define twi_reset
	set_twi_twi_control $I2C_RESET
	set_twi_twi_control 0
	set_twi_twi_div 3300
end

define tt
	set_twi_twi_sladdr 0x20
	set_twi_twi_control $arg0
	set_twi_twi_wdata 6
	wait
end

define twi_write
	printf "WRITING ADDRESS: %d\n", $arg0
	set_twi_twi_control $HOLD
	set_twi_twi_sladdr 0x20
	set_twi_twi_wdata $arg0
	wait
	dump_twi_twi_status
	set_twi_twi_wdata 0xaa
	wait
	dump_twi_twi_status
	set_twi_twi_control 0
	set_twi_twi_wdata $arg1
	wait
	dump_twi_twi_status
end


def wait
	while *$Reg_TWI_TWI_STATUS & $BUSY
		printf "wait...\n"
	end
end



define twi_read
 	printf "READ ADDRESS: %d\n", $arg0
 	set_twi_twi_sladdr 0x20
 	set_twi_twi_control 0
 	set_twi_twi_wdata $arg0
 	wait
	dump_twi_twi_status
	set_twi_twi_control $HOLD
	set_twi_twi_sladdr 0x21
	set_twi_twi_wdata 0 # dummy trigger
	wait
	dump_twi_twi_status
	dump_twi_twi_rdata
	set_twi_twi_control 0
	set_twi_twi_wdata 0 # dummy trigger
	wait
	dump_twi_twi_status
	dump_twi_twi_rdata

end


define st
	dump_twi_twi_status
end

define twi_read16

	printf "WRITING ADDRESS: %d\n", $arg0
	set_twi_twi_control 1
	set_twi_twi_sladdr 32
	set $r = $arg0+0x3000
	set $r = $r >> 8
	set_twi_twi_wdata $r
	dump_twi_twi_status
	set_twi_twi_wdata $arg0&0xff
	dump_twi_twi_status

	printf "READING..\n"
	set_twi_twi_control 1|$AUTOARM
	set_twi_twi_sladdr 33
	dump_twi_twi_rdata
	dump_twi_twi_status
	dump_twi_twi_rdata
	dump_twi_twi_status
	set_twi_twi_control 0
	dump_twi_twi_rdata
	dump_twi_twi_status


end

# set $i = 0
# while $i < 10
# 	twi_read $i
# 	set $i = $i + 1
# end
