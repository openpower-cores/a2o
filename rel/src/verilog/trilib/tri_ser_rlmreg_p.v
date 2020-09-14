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

module tri_ser_rlmreg_p(
   vd,
   gd,
   nclk,
   act,
   force_t,
   thold_b,
   d_mode,
   sg,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   scin,
   din,
   scout,
   dout
);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;
   parameter                      IBUF = 1'b0;
   parameter                      DUALSCAN = "";
   parameter                      NEEDS_SRESET = 1;
   parameter                      DOMAIN_CROSSING = 0;

   inout                          vd;
   inout                          gd;
   input [0:`NCLK_WIDTH-1]        nclk;
   input                          act;
   input                          force_t;
   input                          thold_b;
   input                          d_mode;
   input                          sg;
   input                          delay_lclkr;
   input                          mpw1_b;
   input                          mpw2_b;
   input [OFFSET:OFFSET+WIDTH-1]  scin;
   input [OFFSET:OFFSET+WIDTH-1]  din;
   output [OFFSET:OFFSET+WIDTH-1] scout;
   output [OFFSET:OFFSET+WIDTH-1] dout;


   wire [OFFSET:OFFSET+WIDTH-1]   dout_b;
   wire [OFFSET:OFFSET+WIDTH-1]   act_buf;
   wire [OFFSET:OFFSET+WIDTH-1]   act_buf_b;
   wire [OFFSET:OFFSET+WIDTH-1]   dout_buf;

   assign act_buf = {WIDTH{act}};
   assign act_buf_b = {WIDTH{~(act)}};
   assign dout_buf = (~dout_b);
   assign dout = dout_buf;

   tri_aoi22_nlats_wlcb #(.WIDTH(WIDTH), .OFFSET(OFFSET), .INIT(INIT), .IBUF(IBUF), .DUALSCAN(DUALSCAN), .NEEDS_SRESET(NEEDS_SRESET)) tri_ser_rlmreg_p(
         .nclk(nclk),
         .vd(vd),
         .gd(gd),
         .act(act),
         .force_t(force_t),
         .d_mode(d_mode),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .thold_b(thold_b),
         .sg(sg),
         .scin(scin),
         .scout(scout),
         .a1(din),
         .a2(act_buf),
         .b1(dout_buf),
         .b2(act_buf_b),
         .qb(dout_b)
   );
endmodule

