module bram_2psync_10_8_69bea9a803033c3ab6453d6a7ac1ed0aa4a7bece #(
	parameter DATA = 8,
	parameter ADDR = 10
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

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


//	dual_raw ram(
//		.a_we(a_we),
//		.a_addr(a_addr),
//		.a_clk(clk),
//		.a_read(a_read),
//		.a_ce(1'b1),
//		.a_write(a_write),
//		.b_we(b_we),
//		.b_addr(b_addr),
//		.b_clk(clk),
//		.b_read(b_read),
//		.b_ce(1'b1),
//		.b_write(b_write)
//
//	);

endmodule

module bram_2psync_6_8_69bea9a803033c3ab6453d6a7ac1ed0aa4a7bece #(
	parameter DATA = 8,
	parameter ADDR = 6
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

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


//	dual_raw ram(
//		.a_we(a_we),
//		.a_addr(a_addr),
//		.a_clk(clk),
//		.a_read(a_read),
//		.a_ce(1'b1),
//		.a_write(a_write),
//		.b_we(b_we),
//		.b_addr(b_addr),
//		.b_clk(clk),
//		.b_read(b_read),
//		.b_ce(1'b1),
//		.b_write(b_write)
//
//	);

endmodule

module bram_2psync_10_8_59fe624214af9b8daa183282288d5eb56b321f14 #(
	parameter DATA = 8,
	parameter ADDR = 10
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

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


//	dual_raw ram(
//		.a_we(a_we),
//		.a_addr(a_addr),
//		.a_clk(clk),
//		.a_read(a_read),
//		.a_ce(1'b1),
//		.a_write(a_write),
//		.b_we(b_we),
//		.b_addr(b_addr),
//		.b_clk(clk),
//		.b_read(b_read),
//		.b_ce(1'b1),
//		.b_write(b_write)
//
//	);

endmodule


module bram_2psync_6_8_59fe624214af9b8daa183282288d5eb56b321f14 #(
	parameter DATA = 8,
	parameter ADDR = 6
) (

	// Port A
	input	wire				clk,
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
reg [DATA-1:0] mem [(2**ADDR)-1:0];

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


// Note we got A/B ports swapped to support writing to ROM, for the
// time being

assign a_read = mem[addr_a];
// assign b_read = mem[addr_b];

always @(posedge clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
end


always @(posedge clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
    if (b_we) begin
        mem[b_addr] <= b_write;
    end
end


endmodule

module bram_2psync_9_8_69bea9a803033c3ab6453d6a7ac1ed0aa4a7bece #(
	parameter DATA = 8,
	parameter ADDR = 9
) (

	// Port A
	input	wire				clk,
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
reg [DATA-1:0] mem [(2**ADDR)-1:0];

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;


// Note we got A/B ports swapped to support writing to ROM, for the
// time being

assign a_read = mem[addr_a];
// assign b_read = mem[addr_b];

always @(posedge clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
end


always @(posedge clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
    if (b_we) begin
        mem[b_addr] <= b_write;
    end
end


endmodule
