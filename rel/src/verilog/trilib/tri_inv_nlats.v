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
// *! FILENAME    : tri_inv_nlats.v
// *! DESCRIPTION : n-bit scannable m/s latch, for bit stacking, with inv gate in front
// *!****************************************************************

`include "tri_a2o.vh"

module tri_inv_nlats(
   vd,
   gd,
   lclk,
   d1clk,
   d2clk,
   scanin,
   scanout,
   d,
   qb
);
   parameter                      OFFSET = 0;
   parameter                      WIDTH = 1;
   parameter                      INIT = 0;
   parameter                      L2_LATCH_TYPE = 2;            //L2_LATCH_TYPE = slave_latch;
                                                                //0=master_latch,1=L1,2=slave_latch,3=L2,4=flush_latch,5=L4
   parameter                      SYNTHCLONEDLATCH = "";
   parameter                      BTR = "NLI0001_X1_A12TH";
   parameter                      NEEDS_SRESET = 1;		// for inferred latches
   parameter                      DOMAIN_CROSSING = 0;

   inout                          vd;
   inout                          gd;
   input [0:`NCLK_WIDTH-1]        lclk;
   input                          d1clk;
   input                          d2clk;
   input [OFFSET:OFFSET+WIDTH-1]  scanin;
   output [OFFSET:OFFSET+WIDTH-1] scanout;
   input [OFFSET:OFFSET+WIDTH-1]  d;
   output [OFFSET:OFFSET+WIDTH-1] qb;

   // tri_inv_nlats

   parameter [0:WIDTH-1]          init_v = INIT;
   parameter [0:WIDTH-1]          ZEROS = {WIDTH{1'b0}};

   generate
   begin
      wire                          sreset;
      wire [0:WIDTH-1]              int_din;
      reg [0:WIDTH-1]               int_dout;
      wire [0:WIDTH-1]              vact;
      wire [0:WIDTH-1]              vact_b;
      wire [0:WIDTH-1]              vsreset;
      wire [0:WIDTH-1]              vsreset_b;
      wire [0:WIDTH-1]              vthold;
      wire [0:WIDTH-1]              vthold_b;
      wire [0:WIDTH-1]              din;
       (* analysis_not_referenced="true" *)
      wire                          unused;

      if (NEEDS_SRESET == 1)
      begin : rst
        assign sreset = lclk[1];
      end
      if (NEEDS_SRESET != 1)
      begin : no_rst
        assign sreset = 1'b0;
      end

      assign vsreset = {WIDTH{sreset}};
      assign vsreset_b = {WIDTH{~sreset}};
      assign din = d;		// Output is inverted, so don't invert here
      assign int_din = (vsreset_b & din) | (vsreset & init_v);

      assign vact = {WIDTH{d1clk}};
      assign vact_b = {WIDTH{~d1clk}};

      assign vthold_b = {WIDTH{d2clk}};
      assign vthold = {WIDTH{~d2clk}};


      always @(posedge lclk[0])
      begin: l
        int_dout <= (((vact & vthold_b) | vsreset) & int_din) | (((vact_b | vthold) & vsreset_b) & int_dout);
      end
      assign qb = (~int_dout);
      assign scanout = ZEROS;

      assign unused = | {vd, gd, lclk, scanin};
   end
   endgenerate
endmodule
