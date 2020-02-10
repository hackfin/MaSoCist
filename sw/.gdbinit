set remotetimeout 9999

define conn
# target remote 192.168.1.21:2000
target remote :2000
end

set $CONFIG_NUM_PWM = 8
source soc_mmr.gdb
source pwm.gdb
source mac.gdb
source exc.gdb
source irq.gdb
source dma.gdb

# Disable for RISCV:
# mem 0 0x4000 rw 32
set remotetimeout 9999
set remote memory-write-packet-size 1024

define efb
# Load EFB module
set $MMR_OFFSET_ADDRESS = $EFB_Offset
source efb_mmr.gdb
end


source version.gdb

define sysinfo
	# Be somewhat upward/backward compatible with this OR op:
	set $a = ((unsigned long) $Reg_SysCtrl_Magic)|0x0ff0
	set $r = *$a
	printf "====================   CPU / TAP   ===================\n"
	print_id $r
	print_socinfo
	set $a = ((unsigned long) $Reg_SysCtrl_HWVersion)|0x0ff0
	set $r = *$a
	printf "====================   SOC CONFIG  ===================\n"
	config_detect $r
	printf "Peripheral Hardware version:\t%d.%d\n", ($r >> 8) & 0xff, ($r & 0xff)
	printf "======================================================\n"
	# set $r = *$Reg_SysCtrl_SocInfo
end

define trace
	set logging file /tmp/trace.txt
	set height 0
	set logging on
	while 1
		si
		print/x $sp
	end
	set logging off
end

define reset
	monitor reset
	# irqoff
end

define init
	reset
	load
end

define skip
set $pc = $pc + 1
end

# display g_dma

# display s_rxq
display *g_mac.txq
display g_desc_tx

# b cache_handler
# comm
# dump_sysctrl_cachestatus
# end
