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
// *! FILENAME    : tri_regs.v
// *! DESCRIPTION : Multi-bit scan-only latch, LCB included
// *!****************************************************************

`include "tri_a2o.vh"

module tri_regs(
   vd,
   gd,
   nclk,
   force_t,
   thold_b,
   delay_lclkr,
   scin,
   scout,
   dout
);
   parameter                      WIDTH = 4;
   parameter                      OFFSET = 0;		//starting bit
   parameter                      INIT = 0;		// will be converted to the least signficant
                                                        // 31 bits of init_v
   parameter                      IBUF = 1'b0;		//inverted latch IOs, if set to true.
   parameter                      DUALSCAN = "";		// if "S", marks data ports as scan for Moebius
   parameter                      NEEDS_SRESET = 1;		// for inferred latches
   parameter                      DOMAIN_CROSSING = 0;

   inout                          vd;
   inout                          gd;
   input [0:`NCLK_WIDTH-1]        nclk;
   input                          force_t;		// 1: force LCB active
   input                          thold_b;		// 1: functional, 0: no clock
   input                          delay_lclkr;		// 0: functional
   input [OFFSET:OFFSET+WIDTH-1]  scin;		// scan in
   output [OFFSET:OFFSET+WIDTH-1] scout;
   output [OFFSET:OFFSET+WIDTH-1] dout;

   parameter [0:WIDTH-1]          init_v = INIT;
   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};

   // tri_regs

   generate
   begin
      wire                        sreset;
      wire [0:WIDTH-1]            int_din;
      reg [0:WIDTH-1]             int_dout;
      wire [0:WIDTH-1]            vact;
      wire [0:WIDTH-1]            vact_b;
      wire [0:WIDTH-1]            vsreset;
      wire [0:WIDTH-1]            vsreset_b;
      wire [0:WIDTH-1]            vthold;
      wire [0:WIDTH-1]            vthold_b;
       (* analysis_not_referenced="true" *)
      wire                        unused;

      if (NEEDS_SRESET == 1)
      begin : rst
        assign sreset = nclk[1];
      end
      if (NEEDS_SRESET != 1)
      begin : no_rst
        assign sreset = 1'b0;
      end

      assign vsreset = {WIDTH{sreset}};
      assign vsreset_b = {WIDTH{~sreset}};

      assign int_din = (vsreset_b & int_dout) | (vsreset & init_v);

      assign vact = {WIDTH{force_t}};
      assign vact_b = {WIDTH{~force_t}};

      assign vthold_b = {WIDTH{thold_b}};
      assign vthold = {WIDTH{~thold_b}};


      always @(posedge nclk[0])
      begin: l
        int_dout <= (((vact & vthold_b) | vsreset) & int_din) | (((vact_b | vthold) & vsreset_b) & int_dout);
      end

      if (IBUF == 1'b1)
      begin : cob
        assign dout = (~int_dout);
      end

      if (IBUF == 1'b0)
      begin : cnob
        assign dout = int_dout;
      end

      assign scout = ZEROS;

      assign unused = | {vd, gd, nclk, delay_lclkr, scin};
   end
   endgenerate
endmodule
