module DPRAM_init_hex_ce #(
	parameter DATA_W = 16,
	parameter ADDR_W = 13,
	parameter INIT_HEX = "mem.hex",
	parameter SYN_RAMTYPE = "block_ram"
	
) (

	// Port A
	input	wire					a_clk,
	input	wire					a_ce,
	input	wire					a_we,
	input	wire	[ADDR_W-1:0]	a_addr,
	input	wire	[DATA_W-1:0]	a_write,
	output	reg		[DATA_W-1:0]	a_read,

	// Port B
	input	wire					b_clk,
	input	wire					b_ce,
	input	wire					b_we,
	input	wire	[ADDR_W-1:0]	b_addr,
	input	wire	[DATA_W-1:0]	b_write,
	output	reg		[DATA_W-1:0]	b_read
);

// Shared memory
(* ramstyle = SYN_RAMTYPE *) reg [DATA_W-1:0] mem [(2**ADDR_W)-1:0] /* synthesis syn_ramstyle="block_ram" */;
initial begin
	$readmemh(INIT_HEX, mem);
end
reg [ADDR_W-1:0] addr_b;
reg [ADDR_W-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
    if (b_we) begin
        mem[b_addr] <= b_write;
    end
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
end


endmodule

