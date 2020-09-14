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




module tri_fu_mul_bthmux(
   x,
   sneg,
   sx,
   sx2,
   right,
   left,
   q
);
   input   x;
   input   sneg;		
   input   sx;		
   input   sx2;		
   input   right;		
   output  left;		
   output  q;		
   
   
   wire    center;
   wire    q_b;

   assign center = x ^ sneg;
   
   assign left = center;		
 
   assign q_b = (~((sx & center) | (sx2 & right)));

   assign q = (~q_b);		








   
endmodule
