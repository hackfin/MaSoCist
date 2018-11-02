source utils.gdb

define spi_init
	set $r = 7 << $NBITS_SHFT
	set $r = $r | $SPICS
	set *$Reg_SPI_SPI_CONTROL = $SPIRESET
	set *$Reg_SPI_SPI_CONTROL = $r

	set $r = (*$Reg_SPI_SPI_STATUS & $SPIWIDTH) >> $SPIWIDTH_SHFT
	printf "SPI port width is "
	if $r == 0
		set $g_spidata_shift = 0
		printf "8 bit\n"
	end
	if $r == 1
		set $g_spidata_shift = 8
		printf "16 bit\n"
	end
	if $r == 2
		set $g_spidata_shift = 24
		printf "32 bit\n"
	end
	
	set $spi_init_default = $r

	set *$Reg_SPI_SPI_CLKDIV = 1-1
end

define setflag
	set $r = *$Reg_SPI_SPI_CONTROL
	set *$Reg_SPI_SPI_CONTROL = $r | ($arg0)
end

define clrflag
	set $r = *$Reg_SPI_SPI_CONTROL
	set *$Reg_SPI_SPI_CONTROL = $r & ~($arg0)
end

define spi_rx32
	set $retry = 10
	clrflag $NBITS
	set $a = (31 << $NBITS_SHFT) | $PUMP
	setflag $a
	set *$Reg_SPI_SPI_TX = 0xaa018055
	while ((*$Reg_SPI_SPI_STATUS & $SPIBUSY) == 1 && $retry)
	set $retry = $retry - 1
	echo Waiting for SPI to be ready..\n
	end
	clrflag $PUMP
	set $v = *$Reg_SPI_SPI_RX
end

define spi_tx32
	set *$Reg_SPI_SPI_TX  = $arg0
end

define spi_tx
#	set $retry = 10
	set $v = $arg0 << $g_spidata_shift
	set *$Reg_SPI_SPI_TX  = $v
#	No verify needed, we're too fast.
#	while ((*$Reg_SPI_SPI_STATUS & $SPIBUSY) == 1 && $retry)
#	set $retry = $retry - 1
#	echo Waiting for SPI to be ready..\n
#	end
end

define spi_rx
	set $retry = 10
	while ((*$Reg_SPI_SPI_STATUS & $SPIBUSY) == 1 && $retry)
	end
	set $ret = *$Reg_SPI_SPI_RX
end

define spi_test
	printf "\n\n------------ SPI TEST  ------------\n\n"
	clrflag $NBITS
	set $a = (31 << $NBITS_SHFT) | $PUMP
	setflag $a

	spi_tx 0x01

	spi_tx 0xa0
	spi_tx 0x05
	clrflag $PUMP
	printf "Read back..."
	spi_rx
	printf " got %02x\n", $ret
	if $ret & 0xff != 0x05
		fail
	else
		pass
	end

	set $f = $CPHA + $PUMP
	setflag $f
	spi_tx 0xaa
	setflag $CPOL
	spi_tx 0x55

end

define print_manufacturer
	printf "Manufacturer  [%02x]     : ", $arg0
	if $arg0 == 0x20
		printf "Numonyx"
	end
	if $arg0 == 0xbf
		printf "SST"
	end
	if $arg0 == 0x1f
		printf "Atmel"
	end

	printf "\n"
end

define print_type
	printf "Flash type:   [%02x]     : ", $arg0
	if $arg0 == 0x25
		printf "M25 fast serial Flash"
	end
	if $arg0 == 0xba
		printf "Serial Flash"
	end
	printf "\n"
end

define print_size
	printf "Size          [%02x]     : ", $arg0
	if $arg0 == 0x18
		printf "128 MBit"
	end
	if $arg0 == 0x8d
		printf "4 MBit"
	end
	printf "\n"
end

define spiflash_info
	spi_init

	clrflag $NBITS
	set $a = (7 << $NBITS_SHFT) | $PUMP
	setflag $a

	clrflag $SPICS # select
	spi_tx 0x9f
	spi_tx 0x00

	spi_rx
	print_manufacturer $ret
	spi_rx
	print_type $ret
	spi_rx
	print_size $ret

	setflag $SPICS # deselect

end

define spi_sendaddr
	set $addr = $arg0
	set $r = $addr >> 16
	spi_tx $r
	set $r = $addr >> 8
	spi_tx $r
	spi_tx $addr
end

define spiflash_read32
	clrflag $NBITS
	set $a = (31 << $NBITS_SHFT) | $PUMP
	setflag $a
	clrflag $SPICS # select
	set $a = 0x03000000 + $arg0
	spi_tx $a
	spi_rx
	set $i = $arg1
	while $i > 0
		spi_rx
		printf "> %08x\n", $ret
		set $i = $i - 1
	end
	setflag $SPICS # deselect
end

define spiflash_dump
	clrflag $NBITS
	set $a = (7 << $NBITS_SHFT) | $PUMP
	setflag $a

	clrflag $SPICS # select

	spi_tx 0x03
	spi_sendaddr $arg0
	spi_rx # One dummy read
	set $n = $arg1
	while $n > 0
		set $n = $n - 1
		spi_rx
		printf "%02x ", ($ret & 0xff)
	end
	printf "\n"

	setflag $SPICS # select

end


define spiflash_readsr
	clrflag $NBITS
	set $a = (7 << $NBITS_SHFT) | $PUMP
	setflag $a
	clrflag $SPICS
	spi_tx 0x06
	clrflag $PUMP
	spi_rx
	setflag $SPICS # deselect
end

define spiflash_wren
	# WREN:
	clrflag $SPICS # select
	spi_tx 0x06
	setflag $SPICS # deselect
end

define spiflash_erase
	clrflag $NBITS
	set $a = (31 << $NBITS_SHFT) | $PUMP
	setflag $a
	spiflash_wren
	clrflag $SPICS
	set $a = 0xd8000000 | $arg0
	spi_tx32 $a
	setflag $SPICS # deselect
	spiflash_readsr
	printf "Status: %02x\n", $ret
end

define spiflash_writeblk
	setflag $PUMP
	set $a = $arg0
	set $b = (char *) $arg1
	set $n = $arg2

	spiflash_wren

	clrflag $SPICS # select
	spi_tx 0x02

	spi_sendaddr $a
	set $ea = $a + $n
	printf "Write %d bytes to %08x\n", $n, $a
	while $a < $ea
		set $r = *$b
#		printf "%02x ", $r
		spi_tx $r

		set $a = $a + 1
		set $b = &$b[1]
	end
	printf "\n---------------\n"
	setflag $SPICS # deselect
	spiflash_readsr
	printf "(write) Status: %02x\n", $ret

end

############################################################################

define spi_write_test
	spiflash_erase $addr
	# spiflash_writeblk $addr &s_help[0] sizeof(s_help)
	spiflash_dump $addr 64
end

############################################################################

spiflash_info
#

spiflash_readsr
printf "Status: %02x\n", $ret
set $addr = 0x140000

# spi_test

