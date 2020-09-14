// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


`include "tri_a2o.vh"

module tri_lcbcntl_mac(
   vdd,
   gnd,
   sg,
   nclk,
   scan_in,
   scan_diag_dc,
   thold,
   clkoff_dc_b,
   delay_lclkr_dc,
   act_dis_dc,
   d_mode_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_out
);
   inout        vdd;
   inout        gnd;
   input        sg;
   input [0:`NCLK_WIDTH-1] nclk;
   input        scan_in;
   input        scan_diag_dc;
   input        thold;
   output       clkoff_dc_b;
   output [0:4] delay_lclkr_dc;
   output       act_dis_dc;
   output       d_mode_dc;
   output [0:4] mpw1_dc_b;
   output       mpw2_dc_b;
   output       scan_out;


    (* analysis_not_referenced="true" *)
   wire         unused;

   assign clkoff_dc_b = 1'b1;
   assign delay_lclkr_dc = 5'b00000;
   assign act_dis_dc = 1'b0;
   assign d_mode_dc = 1'b0;
   assign mpw1_dc_b = 5'b11111;
   assign mpw2_dc_b = 1'b1;
   assign scan_out = 1'b0;

   assign unused = vdd | gnd | sg | (|nclk) | scan_in | scan_diag_dc | thold;
endmodule


