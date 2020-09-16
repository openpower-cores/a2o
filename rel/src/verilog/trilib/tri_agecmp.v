// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns

//  Description:  Prioritizer
//
//*****************************************************************************

module tri_agecmp(
   a,
   b,
   a_newer_b
);
   parameter        SIZE = 8;

   input [0:SIZE-1] a;
   input [0:SIZE-1] b;
   output           a_newer_b;

   // tri_agecmp

   wire             a_lt_b;
   wire             a_gte_b;
   wire             cmp_sel;

   assign a_lt_b = (a[1:SIZE - 1] < b[1:SIZE - 1]) ? 1'b1 :
   1'b0;

   assign a_gte_b = (~a_lt_b);

   assign cmp_sel = a[0] ~^ b[0];

   assign a_newer_b = (a_lt_b & (~cmp_sel)) | (a_gte_b & cmp_sel);
endmodule
