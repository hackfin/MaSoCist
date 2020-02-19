module usrmclk_wrapper(
	input usrmclki,
	input usrmclkts,
	output spi_mclk_dummy
);

USRMCLK usrmclk_i (.USRMCLKI(usrmclki), .USRMCLKTS(usrmclkts));

assign spi_mclk_dummy = 1'b1;

endmodule
