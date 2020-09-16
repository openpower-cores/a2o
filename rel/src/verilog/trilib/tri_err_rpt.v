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
// *! FILENAME    : tri_err_rpt.v
// *! DESCRIPTION : Error Reporting Component
// *!****************************************************************

`include "tri.vh"

module tri_err_rpt(
   vd,
   gd,
   err_d1clk,
   err_d2clk,
   err_lclk,
   err_scan_in,
   err_scan_out,
   mode_dclk,
   mode_lclk,
   mode_scan_in,
   mode_scan_out,
   err_in,
   err_out,
   hold_out,
   mask_out
);
   parameter                     WIDTH = 1;		// number of errors of the same type
   parameter                     MASK_RESET_VALUE = 1'b0;	// use to set default/flush value for mask bits
   parameter                     INLINE = 1'b0;		// make hold latch be inline; err_out is sticky -- default to shadow
   parameter                     SHARE_MASK = 1'b0;		// PERMISSION NEEDED for true
                                                                // used for WIDTH >1 to reduce area of mask (common error disable)
   parameter                     USE_NLATS = 1'b0;		// only necessary in standby area to be able to reset to init value
   parameter                     NEEDS_SRESET = 1;		// for inferred latches

   inout                         vd;
   inout                         gd;
   input                         err_d1clk;     // caution1: if lcb uses powersavings, errors must always get reported
   input                         err_d2clk;     // caution2: if use_nlats is used these are also the clocks for the mask latches
   input [0:`NCLK_WIDTH-1]       err_lclk;      // caution2:   hence these have to be the mode clocks
                                                // caution2:   and all bits in the "func" chain have to be connected to the mode chain
   // error scan chain (func or mode)
   input [0:WIDTH-1]             err_scan_in;   // NOTE: connected to mode or func ring
   output [0:WIDTH-1]            err_scan_out;
   // clock gateable mode clocks
   input                         mode_dclk;
   input [0:`NCLK_WIDTH-1]       mode_lclk;
   // mode scan chain
   input [0:WIDTH-1]             mode_scan_in;
   output [0:WIDTH-1]            mode_scan_out;

   input [0:WIDTH-1]             err_in;
   output [0:WIDTH-1]            err_out;

   output [0:WIDTH-1]            hold_out;		// sticky error hold latch for trap usage
   output [0:WIDTH-1]            mask_out;

   // tri_err_rpt

   parameter [0:WIDTH-1]         mask_initv = MASK_RESET_VALUE;
   wire [0:WIDTH-1]              hold_in;
   wire [0:WIDTH-1]              hold_lt;
   wire [0:WIDTH-1]              mask_lt;
    (* analysis_not_referenced="true" *)
   wire                          unused;
   wire [0:WIDTH-1]              unused_q_b;
   // hold latches
   assign hold_in = err_in | hold_lt;

   tri_nlat_scan #(.WIDTH(WIDTH), .NEEDS_SRESET(NEEDS_SRESET))
       hold(
            .vd(vd),
            .gd(gd),
            .d1clk(err_d1clk),
            .d2clk(err_d2clk),
            .lclk(err_lclk),
            .scan_in(err_scan_in[0:WIDTH - 1]),
            .scan_out(err_scan_out[0:WIDTH - 1]),
            .din(hold_in),
            .q(hold_lt),
            .q_b(unused_q_b)
            );

   generate
   begin
      // mask
     if (SHARE_MASK == 1'b0)
     begin : m
       assign mask_lt = mask_initv;
     end
     if (SHARE_MASK == 1'b1)
     begin : sm
       assign mask_lt = {WIDTH{MASK_RESET_VALUE[0]}};
     end

     assign mode_scan_out = {WIDTH{1'b0}};

     // assign outputs
     assign hold_out = hold_lt;
     assign mask_out = mask_lt;

     if (INLINE == 1'b1)
     begin : inline_hold
       assign err_out = hold_lt & (~mask_lt);
     end

     if (INLINE == 1'b0)
     begin : side_hold
       assign err_out = err_in & (~mask_lt);
     end

     assign unused = | {mode_dclk, mode_lclk, mode_scan_in, unused_q_b};
   end
   endgenerate
endmodule
