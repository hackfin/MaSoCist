module dpram16_init_hex_ce_11_16_23733be319a9023de7d592797a5b9adbd315da4f #(
	parameter DATA = 16,
	parameter ADDR = 11
) (

	// Port A
	input	wire				a_clk,
	input	wire				a_ce,
	input	wire				a_we,
	input	wire	[ADDR-1:0]	a_addr,
	input	wire	[DATA-1:0]	a_write,
	output	reg		[DATA-1:0]	a_read,

	// Port B
	input	wire				b_clk,
	input	wire				b_ce,
	input	wire				b_we,
	input	wire	[ADDR-1:0]	b_addr,
	input	wire	[DATA-1:0]	b_write,
	output	reg		[DATA-1:0]	b_read
);

// Shared memory
reg [DATA-1:0] mem [(2**ADDR)-1:0];

initial begin
	$readmemh("../sw/bootrom16.hex", mem);
end

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


// Note we got A/B ports swapped to support writing to ROM, for the
// time being

assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
end


always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
    if (b_we) begin
        mem[b_addr] <= b_write;
    end
end


endmodule



