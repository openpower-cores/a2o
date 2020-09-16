// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns

// *!****************************************************************
// *! FILENAME    : tri_lcbnd.v
// *! DESCRIPTION : Wrapper for nlat LCB - will not run in pulsed mode
// *!****************************************************************

`include "tri_a2o.vh"

module tri_lcbnd(
   vd,
   gd,
   act,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   nclk,
   force_t,
   sg,
   thold_b,
   d1clk,
   d2clk,
   lclk
);
   parameter                      DOMAIN_CROSSING = 0;

   inout      vd;
   inout      gd;
   input      act;
   input      delay_lclkr;
   input      mpw1_b;
   input      mpw2_b;
   input[0:`NCLK_WIDTH-1]  nclk;
   input      force_t;
   input      sg;
   input      thold_b;
   output     d1clk;
   output     d2clk;
   output[0:`NCLK_WIDTH-1]  lclk;

   // tri_lcbnd
   wire       gate_b;
    (* analysis_not_referenced="true" *)
   wire       unused;

   assign unused = vd | gd | delay_lclkr | mpw1_b | mpw2_b | sg;

   assign gate_b = force_t | act;

   assign d1clk = gate_b;
   assign d2clk = thold_b;
   assign lclk = nclk;
endmodule
