module bram_2psync #(
	parameter DATA_W = 8,
	parameter ADDR_W = 10,
	parameter SYN_RAMTYPE = "unused"
) (
	input	wire				clk,

	// Port A
	input	wire				a_we,
	input	wire	[ADDR_W-1:0]	a_addr,
	input	wire	[DATA_W-1:0]	a_write,
	output	reg		[DATA_W-1:0]	a_read,

	// Port B
	input	wire				b_we,
	input	wire	[ADDR_W-1:0]	b_addr,
	input	wire	[DATA_W-1:0]	b_write,
	output	reg		[DATA_W-1:0]	b_read
);

// Shared memory
// (* ramstyle = "block_ram" *) reg [DATA_W-1:0] mem [(2**ADDR_W)-1:0] /* synthesis syn_ramstyle="block_ram" */;
//  initial begin
//	$readmemh("../build/nuc.hex", mem);
//  end

reg [ADDR_W-1:0] addr_b;
reg [ADDR_W-1:0] addr_a;


(* ramstyle = "block_ram" *) reg [DATA_W-1:0] mem [(2**ADDR_W)-1:0] /* synthesis syn_ramstyle="block_ram" */;

assign a_read = mem[addr_a];
assign b_read = mem[addr_b];

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
