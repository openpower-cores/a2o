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
// *! FILENAME    : tri_rlmlatch_p.v
// *! DESCRIPTION : 1-bit latch, LCB included
// *!****************************************************************

`include "tri_a2o.vh"

module tri_rlmlatch_p(vd, gd, nclk, act, force_t, thold_b, d_mode, sg, delay_lclkr, mpw1_b, mpw2_b, scin, din, scout, dout);
   parameter             INIT = 0;		// will be converted to the least signficant
                                                // 31 bits of init_v
   parameter             IBUF = 1'b0;		//inverted latch IOs, if set to true.
   parameter             DUALSCAN = "";		// if "S", marks data ports as scan for Moebius
   parameter             NEEDS_SRESET = 1;	// for inferred latches
   parameter             DOMAIN_CROSSING = 0;

   inout                        vd;
   inout                        gd;
   input [0:`NCLK_WIDTH-1]      nclk;
   input                        act;		// 1: functional, 0: no clock
   input                        force_t;	// 1: force LCB active
   input                        thold_b;	// 1: functional, 0: no clock
   input                        d_mode;		// 1: disable pulse mode, 0: pulse mode
   input                        sg;		// 0: functional, 1: scan
   input                        delay_lclkr;	// 0: functional
   input                        mpw1_b;		// pulse width control bit
   input                        mpw2_b;		// pulse width control bit
   input                        scin;		// scan in
   input                        din;		// data in
   output                       scout;		// scan out
   output                       dout;		// data out

   parameter             WIDTH = 1;
   parameter [0:WIDTH-1] init_v = INIT;

   // tri_rlmlatch_p

   generate
   begin
     wire                  sreset;
     wire                  int_din;
     reg                   int_dout;
       (* analysis_not_referenced="true" *)
     wire                  unused;

     if (NEEDS_SRESET == 1)
     begin : rst
       assign sreset = nclk[1];
     end
     if (NEEDS_SRESET != 1)
     begin : no_rst
       assign sreset = 1'b0;
     end

     if (IBUF == 1'b1)
     begin : cib
       assign int_din = ((~sreset) & (~din)) | (sreset & init_v[0]);
     end
     if (IBUF == 1'b0)
     begin : cnib
       assign int_din = ((~sreset) & din) | (sreset & init_v[0]);
     end

     always @(posedge nclk[0])
     begin: l
       int_dout <= ((((act | force_t) & thold_b) | sreset) & int_din) | ((((~act) & (~force_t)) | (~thold_b)) & (~sreset) & int_dout);
     end

     if (IBUF == 1'b1)
     begin : cob
       assign dout = (~int_dout);
     end

     if (IBUF == 1'b0)
     begin : cnob
       assign dout = int_dout;
     end

     assign scout = 1'b0;

     assign unused = d_mode | sg | delay_lclkr | mpw1_b | mpw2_b | scin | vd | gd | (|nclk);
   end
   endgenerate
endmodule
