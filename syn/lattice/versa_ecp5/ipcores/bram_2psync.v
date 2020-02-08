module bram_2psync_7_8_69bea9a803033c3ab6453d6a7ac1ed0aa4a7bece #(
	parameter DATA = 8,
	parameter ADDR = 7
) (
	input	wire				clk,

	// Port A
	input	wire				a_we,
	input	wire	[ADDR-1:0]	a_addr,
	input	wire	[DATA-1:0]	a_write,
	output	reg		[DATA-1:0]	a_read,

	// Port B
	input	wire				b_we,
	input	wire	[ADDR-1:0]	b_addr,
	input	wire	[DATA-1:0]	b_write,
	output	reg		[DATA-1:0]	b_read
);

// Shared memory
// (* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;
//  initial begin
//	$readmemh("../build/nuc.hex", mem);
//  end

	dual_raw ram(
		.a_we(a_we),
		.a_addr(a_addr),
		.a_clk(clk),
		.a_read(a_read),
		.a_ce(1'b1),
		.a_write(a_write),
		.b_we(b_we),
		.b_addr(b_addr),
		.b_clk(clk),
		.b_read(b_read),
		.b_ce(1'b1),
		.b_write(b_write)

	);

endmodule

module bram_2psync_7_8_59fe624214af9b8daa183282288d5eb56b321f14 #(
	parameter DATA = 8,
	parameter ADDR = 7
) (
	input	wire				clk,

	// Port A
	input	wire				a_we,
	input	wire	[ADDR-1:0]	a_addr,
	input	wire	[DATA-1:0]	a_write,
	output	reg		[DATA-1:0]	a_read,

	// Port B
	input	wire				b_we,
	input	wire	[ADDR-1:0]	b_addr,
	input	wire	[DATA-1:0]	b_write,
	output	reg		[DATA-1:0]	b_read
);

// Shared memory
// (* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;
//  initial begin
//	$readmemh("../build/nuc.hex", mem);
//  end

	dual_raw ram(
		.a_we(a_we),
		.a_addr(a_addr),
		.a_clk(clk),
		.a_read(a_read),
		.a_ce(1'b1),
		.a_write(a_write),
		.b_we(b_we),
		.b_addr(b_addr),
		.b_clk(clk),
		.b_read(b_read),
		.b_ce(1'b1),
		.b_write(b_write)

	);

endmodule


