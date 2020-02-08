module dpram16_init_hex_ce_13_16_d95ab636b84a63342d4aafb78634193dfafa9bd3 #(
	parameter DATA = 16,
	parameter ADDR = 13
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;
initial begin
	$readmemh("../sw/bootrom_l.hex", mem);
end
reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

module dpram16_init_hex_ce_13_16_eee382c73bd1fad01c2b3fbf9f8f9f1480a54c71 #(
	parameter DATA = 16,
	parameter ADDR = 13
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;
initial begin
	$readmemh("../sw/bootrom_h.hex", mem);
end
reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

module dpram16_init_hex_ce_12_8_ba2e89be2211faa00ef3afb2909c02bfae7c4c78 #(
	parameter DATA = 8,
	parameter ADDR = 12
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

initial begin
	$readmemh("../sw/bootrom_data_b0.hex", mem);
end

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

module dpram16_init_hex_ce_12_8_7c8e64422ad5c562a3c8f73de1253d4bf058bbcd #(
	parameter DATA = 8,
	parameter ADDR = 12
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

initial begin
	$readmemh("../sw/bootrom_data_b2.hex", mem);
end

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

module dpram16_init_hex_ce_12_8_56b16520c103fbd57e3f1c38407b77c85a9a30e9 #(
	parameter DATA = 8,
	parameter ADDR = 12
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

initial begin
	$readmemh("../sw/bootrom_data_b1.hex", mem);
end

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

module dpram16_init_hex_ce_12_8_65f565ad5bd67187540823e9e4181e9ffef74dd1 #(
	parameter DATA = 8,
	parameter ADDR = 12
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
(* ramstyle = "block_ram" *) reg [DATA-1:0] mem [(2**ADDR)-1:0] /* synthesis syn_ramstyle="block_ram" */;

initial begin
	$readmemh("../sw/bootrom_data_b1.hex", mem);
end

reg [ADDR-1:0] addr_b;
reg [ADDR-1:0] addr_a;



assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

always @(posedge b_clk) begin: DUAL_RAW_PORT_B_PROC
    addr_b <= b_addr;
end


always @(posedge a_clk) begin: DUAL_RAW_PORT_A_PROC
    addr_a <= a_addr;
    if (a_we) begin
        mem[a_addr] <= a_write;
    end
end


endmodule

