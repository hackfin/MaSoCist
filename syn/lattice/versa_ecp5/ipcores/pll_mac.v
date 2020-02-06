/* Workaround wrapper module for ECP5 PLL
 
  ghdlsynth does, as of now:

  Thu, 06 Feb 2020 10:46:51 +0100
 
  ..not support generics for blackboxes. Therefore we need a separate wrapper
  in Verilog.
 
  */

module pll_mac(
	input clki,
	output clkop,
	output clkos,
	output clkos2,
	output clkos3,
	output lock
);

	wire clkop_int;

(* FREQUENCY_PIN_CLKOS3 = "75.000000" *)
(* FREQUENCY_PIN_CLKOS2 = "50.000000" *)
(* FREQUENCY_PIN_CLKOS = "25.000000" *)
(* FREQUENCY_PIN_CLKOP = "125.000000" *)
(* FREQUENCY_PIN_CLKI = "100.000000" *)
(* ICP_CURRENT = "7" *)
(* LPF_RESISTOR = "16" *)

EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(4),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(6),
        .CLKOP_CPHASE(5),
        .CLKOP_FPHASE(0),
        // .CLKOP_TRIM_DELAY(0),
        .CLKOP_TRIM_POL("FALLING"),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(30),
        .CLKOS_CPHASE(29),
        .CLKOS_FPHASE(0),
        // .CLKOS_TRIM_DELAY(0),
        .CLKOS_TRIM_POL("FALLING"),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(15),
        .CLKOS2_CPHASE(14),
        .CLKOS2_FPHASE(0),
        .CLKOS3_ENABLE("ENABLED"),
        .CLKOS3_DIV(10),
        .CLKOS3_CPHASE(9),
        .CLKOS3_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(5)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clki),
        .CLKOP(clkop_int),
        .CLKOS(clkos),
        .CLKFB(clkop_int),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(lock)
	);

	assign clkop = clkop_int;


endmodule
