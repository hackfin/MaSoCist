/* JTAG wrapper
 *
 */

module jtag_wrapper(
	input tck,
	input tms,
	input tdi,
	output tdo,
	input jtdo1,
	input jtdo2,
	output jtdi,
	output jtck,
	output jrti1,
	output jrti2,
	output jshift,
	output jupdate,
	output jrstn,
	output jce1,
	output jce2
);

JTAGG #(.ER1		("ENABLED"),
        .ER2		("ENABLED"),
        // .FLASH_MEM	(1),
        // .EFUSE_MEM	(1),
        // .DECRYPTION	(1)
) jtag_i (
/*
 JTAG currently disabled because of:

Warning: Failed to find a route for arc 4 of net $PACKER_GND_NET.

	.TCK    (tck),
	.TMS    (tms),
	.TDI    (tdi),
	.TDO    (tdo),
	.JTDO1  (jtdo1),
	.JTDO2  (jtdo2),
	.JTDI   (jtdi),
	.JTCK   (jtck),
	.JRTI1  (jrti1),
	.JRTI2  (jrti2),
	.JSHIFT (jshift),
	.JUPDATE(jupdat),
	.JRSTN  (jrstn),
	.JCE1   (jce1),
	.JCE2   (jce2)
*/
);
endmodule
