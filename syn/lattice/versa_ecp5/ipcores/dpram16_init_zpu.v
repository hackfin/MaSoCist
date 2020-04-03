
module DPRAM_init_hex_ce #(
	parameter DATA_W = 16,
	parameter ADDR_W = 13,
	parameter INIT_HEX = "../sw/bootrom32.hex",
	parameter SYN_RAMTYPE = "unused"
) (

`include "../../common/dpram_hack.vh"

endmodule


