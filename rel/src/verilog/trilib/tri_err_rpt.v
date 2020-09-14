// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns


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
   parameter                     WIDTH = 1;		
   parameter                     MASK_RESET_VALUE = 1'b0;	
   parameter                     INLINE = 1'b0;		
   parameter                     SHARE_MASK = 1'b0;		
   parameter                     USE_NLATS = 1'b0;		
   parameter                     NEEDS_SRESET = 1;		

   inout                         vd;
   inout                         gd;
   input                         err_d1clk;     
   input                         err_d2clk;     
   input [0:`NCLK_WIDTH-1]       err_lclk;      
   input [0:WIDTH-1]             err_scan_in;   
   output [0:WIDTH-1]            err_scan_out;
   input                         mode_dclk;
   input [0:`NCLK_WIDTH-1]       mode_lclk;
   input [0:WIDTH-1]             mode_scan_in;
   output [0:WIDTH-1]            mode_scan_out;

   input [0:WIDTH-1]             err_in;
   output [0:WIDTH-1]            err_out;

   output [0:WIDTH-1]            hold_out;		
   output [0:WIDTH-1]            mask_out;


   parameter [0:WIDTH-1]         mask_initv = MASK_RESET_VALUE;
   wire [0:WIDTH-1]              hold_in;
   wire [0:WIDTH-1]              hold_lt;
   wire [0:WIDTH-1]              mask_lt;
    (* analysis_not_referenced="true" *)
   wire                          unused;
   wire [0:WIDTH-1]              unused_q_b;
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
     if (SHARE_MASK == 1'b0)
     begin : m
       assign mask_lt = mask_initv;
     end
     if (SHARE_MASK == 1'b1)
     begin : sm
       assign mask_lt = {WIDTH{MASK_RESET_VALUE[0]}};
     end

     assign mode_scan_out = {WIDTH{1'b0}};

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

