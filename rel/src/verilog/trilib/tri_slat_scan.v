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
// *! FILENAME    : tri_slat_scan.v
// *! DESCRIPTION : n-bit scan-only latch without scan_connect
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_slat_scan(
   vd,
   gd,
   dclk,
   lclk,
   scan_in,
   scan_out,
   q,
   q_b
);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      BTR = "c_slat_scan";
   parameter                      RESET_INVERTS_SCAN = 1'b1;

   inout                          vd;
   inout                          gd;
   input                          dclk;
   input [0:`NCLK_WIDTH-1]        lclk;
   input [OFFSET:OFFSET+WIDTH-1]  scan_in;
   output [OFFSET:OFFSET+WIDTH-1] scan_out;
   output [OFFSET:OFFSET+WIDTH-1] q;
   output [OFFSET:OFFSET+WIDTH-1] q_b;

   // tri_slat_scan

   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};
   parameter [0:WIDTH-1]          initv = INIT;

   (* analysis_not_referenced="true" *)
   wire                           unused;

   assign unused = | {vd, gd, dclk, lclk, scan_in};

   assign scan_out = ZEROS;
   assign q = initv;
   assign q_b = (~initv);
endmodule
