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

module tri_rlmreg_p(vd, gd, nclk, act, force_t, thold_b, d_mode, sg, delay_lclkr, mpw1_b, mpw2_b, scin, din, scout, dout);
   parameter                    WIDTH = 4;
   parameter                    OFFSET = 0;		
   parameter                    INIT = 0;		
   parameter                    IBUF = 1'b0;		
   parameter                    DUALSCAN = "";	
   parameter                    NEEDS_SRESET = 1;	
   parameter                    DOMAIN_CROSSING = 0;

   inout                        vd;
   inout                        gd;
   input [0:`NCLK_WIDTH-1]      nclk;
   input                        act;		
   input                        force_t;	
   input                        thold_b;	
   input                        d_mode;	
   input                        sg;		
   input                        delay_lclkr;	
   input                        mpw1_b;	
   input                        mpw2_b;	
   input [OFFSET:OFFSET+WIDTH-1]  scin;		
   input [OFFSET:OFFSET+WIDTH-1]  din;		
   output [OFFSET:OFFSET+WIDTH-1] scout;
   output [OFFSET:OFFSET+WIDTH-1] dout;

   parameter [0:WIDTH-1]        init_v = INIT;
   parameter [0:WIDTH-1]        ZEROS = {WIDTH{1'b0}};


   generate
   begin
     wire                       sreset;
     wire [0:WIDTH-1]           int_din;
     reg [0:WIDTH-1]            int_dout;
     wire [0:WIDTH-1]           vact;
     wire [0:WIDTH-1]           vact_b;
     wire [0:WIDTH-1]           vsreset;
     wire [0:WIDTH-1]           vsreset_b;
     wire [0:WIDTH-1]           vthold;
     wire [0:WIDTH-1]           vthold_b;
       (* analysis_not_referenced="true" *)
     wire [0:WIDTH]             unused;

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

     if (IBUF == 1'b1)
     begin : cib
       assign int_din = (vsreset_b & (~din)) | (vsreset & init_v);
     end
     if (IBUF == 1'b0)
     begin : cnib
       assign int_din = (vsreset_b & din) | (vsreset & init_v);
     end

     assign vact = {WIDTH{act | force_t}};
     assign vact_b = {WIDTH{~(act | force_t)}};

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

     assign unused[0] = d_mode | sg | delay_lclkr | mpw1_b | mpw2_b | vd | gd | (|nclk);
     assign unused[1:WIDTH] = scin;
   end
   endgenerate
endmodule
