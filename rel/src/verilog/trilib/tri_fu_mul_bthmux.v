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
// *! FILE NAME    :  tri_fu_mul_bthdcd.vhdl
// *! DESCRIPTION  :  Booth Decode
// *!****************************************************************

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
   input   sneg;		// do not flip the input (add)
   input   sx;		// shift by 1
   input   sx2;		// shift by 2
   input   right;		// bit from the right (lsb)
   output  left;		// bit from the left
   output  q;		// final output

   wire    center;
   wire    q_b;

   assign center = x ^ sneg;

   assign left = center;		//output-- rename, no gate

   assign q_b = (~((sx & center) | (sx2 & right)));

   assign q = (~q_b);		// output--

endmodule
