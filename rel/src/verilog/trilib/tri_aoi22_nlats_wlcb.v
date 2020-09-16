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
// *! FILENAME    : tri_aoi22_nlats_wlcb.v
// *! DESCRIPTION : Multi-bit aoi22-latch, LCB included
// *!
// *!****************************************************************

`include "tri_a2o.vh"

module tri_aoi22_nlats_wlcb(
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
   scout,
   a1,
   a2,
   b1,
   b2,
   qb
);

   parameter                      WIDTH = 4;
   parameter                      OFFSET = 0;		//starting bit
   parameter                      INIT = 0;		// will be converted to the least signficant
                                                        // 31 bits of init_v
   parameter                      IBUF = 1'b0;		//inverted latch IOs, if set to true.
   parameter                      DUALSCAN = "";		// if "S", marks data ports as scan for Moebius
   parameter                      NEEDS_SRESET = 1;		// for inferred latches
   parameter                      L2_LATCH_TYPE = 2;            //L2_LATCH_TYPE = slave_latch;
                                                                //0=master_latch,1=L1,2=slave_latch,3=L2,4=flush_latch,5=L4
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      BTR = "NLL0001_X2_A12TH";

   inout                          vd;
   inout                          gd;
   input [0:`NCLK_WIDTH-1]        nclk;
   input                          act;		// 1: functional, 0: no clock
   input                          force_t;		// 1: force LCB active
   input                          thold_b;		// 1: functional, 0: no clock
   input                          d_mode;		// 1: disable pulse mode, 0: pulse mode
   input                          sg;		// 0: functional, 1: scan
   input                          delay_lclkr;		// 0: functional
   input                          mpw1_b;		// pulse width control bit
   input                          mpw2_b;		// pulse width control bit
   input [OFFSET:OFFSET+WIDTH-1]  scin;		// scan in
   output [OFFSET:OFFSET+WIDTH-1] scout;
   input [OFFSET:OFFSET+WIDTH-1]  a1;
   input [OFFSET:OFFSET+WIDTH-1]  a2;
   input [OFFSET:OFFSET+WIDTH-1]  b1;
   input [OFFSET:OFFSET+WIDTH-1]  b2;
   output [OFFSET:OFFSET+WIDTH-1] qb;

   // tri_aoi22_nlats_wlcb

   parameter [0:WIDTH-1]          init_v = INIT;
   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};

   generate
   begin
      wire                        sreset;
      wire [0:WIDTH-1]            int_din;
      wire [0:WIDTH-1]            din;
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

      assign din = (a1 & a2) | (b1 & b2);		// Output is inverted, so just AND-OR here
      assign int_din = (vsreset_b & din) | (vsreset & init_v);

      assign vact = {WIDTH{act | force_t}};
      assign vact_b = {WIDTH{~(act | force_t)}};

      assign vthold_b = {WIDTH{thold_b}};
      assign vthold = {WIDTH{~thold_b}};


      always @(posedge nclk[0])
      begin: l
        int_dout <= (((vact & vthold_b) | vsreset) & int_din) | (((vact_b | vthold) & vsreset_b) & int_dout);
      end

      assign qb = (~int_dout);

      assign scout = ZEROS;

      assign unused = d_mode | sg | delay_lclkr | mpw1_b | mpw2_b | vd | gd | (|nclk) | (|scin);
   end
   endgenerate
endmodule
