# Determine CPU version from ID:

define print_id
	set $r = $arg0
	if $r == 0xdeadbeef
		echo Zealot core 'section5 Debug TAP'\n
	end
	if $r == 0xdeadbeed
		echo ZPUng core v1-alpha\n
	end
	if $r == 0xdead0ace
		echo ZPUng core v1 (TAP Developer version)\n
	end
	if $r == 0xc0010ace
		echo ZPUng core v2 (TAP Developer version)\n
	end
	if $r == 0xdead3195
		echo PyPS core (Developer version)\n
	end
end

define print_socinfo
	set $a = ((unsigned long) $Reg_SysCtrl_SocInfo)|0x0ff0
	set $r = *$a
	set $fam = ($r & 0xf0)
	set $rev = ($r & 0x0f)

	set $a = ((unsigned long) $Reg_SysCtrl_Magic)|0x0ff0
	set $r = *$a
	set $r = $r & 0xffffff00

	if $r == 0xcafe1000
		printf "Standard TAP interface\n"
		if $fam == 0x00
			printf "ZPU small architecture rev%d\n", $rev
		end
		if $fam == 0x10
			printf "ZPUng v1 architecture rev%d\n", $rev
		end
		if $fam == 0x20
			printf "ZPUng v2 architecture rev%d\n", $rev
		end
		if $fam == 0x40
			printf "PyPS architecture rev%d\n", $rev
		end
		if $fam == 0x50
			printf "RiscV architecture rev%d\n", $rev
		end
	end
end

# Reads hard-coded board info:
define config_detect
	set $v = $arg0 >> 16

	if $v == 0
		printf "Opensource / unversioned 'agathe'/'anselm'\n"
	end
	if $v == 0x10
		printf "Custom 'agneta' configuration\n"
	end
	if $v == 1
		printf "Custom 'beatrix' configuration\n"
	end
	if $v == 2
		printf "Stable 'bertram' configuration\n"
	end
	if $v == 3
		printf "Stable 'cranach' configuration\n"
	end
	if $v == 4
		printf "Stable 'dombert' configuration\n"
	end
	if $v == 0x20
		printf "Alpha 'cordula' configuration\n"
	end
	if $v == 0x21
		printf "Alpha 'dorothea' configuration\n"
	end
	if $v == 0x24
		printf "Alpha 'dombert' configuration\n"
	end
	if $v == 0x35
		printf "Development 'emil' configuration\n"
	end
	if $v == 0x40
		printf "Development 'lemuel' configuration\n"
	end
end
