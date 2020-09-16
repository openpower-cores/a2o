// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns

//  Description:  Saturating Incrementer
//
//  Change log at bottom of this file
//*****************************************************************************

module iuq_cpl_itag( inc, i, o);
   parameter         SIZE = 7;
   parameter         WRAP = 40;

   input [0:1]       inc;
   input [0:SIZE-1]  i;

   output [0:SIZE-1] o;

   wire [1:SIZE]     a;
   wire [1:SIZE]     b;
   wire [1:SIZE]     rslt;
   wire              rollover;
   wire              rollover_m1;
   wire              inc_1;
   wire              inc_2;
   wire [0:1]        wrap_sel;


   (* analysis_not_referenced="true" *)

   wire 	     unused;
   // Increment by 1 or 2.
   // Go back to zero at WRAP
   // Flip bit zero when a rollover occurs
   // eg 0...39, 64..103
   assign unused = rslt[SIZE];

   assign a = {i[1:SIZE - 1], inc[1]};
   assign b = {{SIZE-2{1'b0}},{inc[0], inc[1]}};
   assign rslt = a + b;

   assign rollover = {{32-SIZE+1{1'b0}},i[1:SIZE - 1]} == WRAP;
   assign rollover_m1 = {{32-SIZE+1{1'b0}},i[1:SIZE - 1]} == WRAP - 1;

   assign inc_1 = inc[0] ^ inc[1];
   assign inc_2 = inc[0] & inc[1];

   assign wrap_sel[0] = (rollover & inc_1) | (rollover_m1 & inc_2);
   assign wrap_sel[1] = rollover & inc_2;

   assign o[0] = i[0] ^ |(wrap_sel);

   assign o[1:SIZE-1] = (wrap_sel[0:1] == 2'b10) ? {SIZE-1{1'b0}} :
                        (wrap_sel[0:1] == 2'b01) ? {{SIZE-2{1'b0}},{1'b1}} :
                         rslt[1:SIZE-1];

endmodule
