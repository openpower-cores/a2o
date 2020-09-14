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

module tri_plat(vd, gd, nclk, flush, din, q);
   parameter                      WIDTH = 1;
   parameter                      OFFSET = 0;
   parameter                      INIT = 0;		
   parameter                      SYNTHCLONEDLATCH = "";

   inout                          vd;
   inout                          gd;
   input  [0:`NCLK_WIDTH-1]       nclk;
   input                          flush;
   input  [OFFSET:OFFSET+WIDTH-1] din;
   output [OFFSET:OFFSET+WIDTH-1] q;

   reg  [OFFSET:OFFSET+WIDTH-1]  int_dout;

   (* analysis_not_referenced="true" *)
   wire                          unused;
   assign unused = | {vd, gd, nclk[1:`NCLK_WIDTH-1]};
   

   always @ (posedge nclk[0]) 
     begin
 	int_dout <= din;
     end

   assign q = (flush == 1'b1) ? din : int_dout ;

endmodule

