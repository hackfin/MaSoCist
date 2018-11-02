define send
	set *$Reg_UART_UART_TXR = $arg0
	while ((*$Reg_UART_UART_STATUS & $TXREADY) == 0)
	echo Waiting for UART FIFO to be ready..\n
	end
end

define receive
	while ((*$Reg_UART_UART_STATUS & $RXREADY) != 0)
		printf "%02x ", *$Reg_UART_UART_RXR & 0xff
	end
	printf "\n"
end

define uart_sync
	while ((*$Reg_UART_UART_STATUS & $TXBUSY) != 0)
	echo Wait for UART to TX all characters...
	end
end

define uart_reset
	set *$Reg_UART_UART_CONTROL = $UART_RESET | 5
	set *$Reg_UART_UART_CONTROL =               5
end
	
