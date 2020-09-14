// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





module fu_divsqrt_nq_table(
   x,  
   nq
);
`include "tri_a2o.vh"
   
   input [0:3]  x;
   output  nq;
   
   wire    not1111;
   wire    nq_b;


 
   tri_nand4 #(.WIDTH(1), .BTR("NAND4_X4M_A9TH")) DIVSQRT_NQ_TABLE_NAND4_00(not1111, x[0], x[1], x[2], x[3]);

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X6A_A9TH")) DIVSQRT_NQ_TABLE_NAND2_00(nq_b, x[0], not1111);
   
   tri_inv   #(.WIDTH(1), .BTR("INV_X11M_A9TH")) DIVSQRT_NQ_TABLE_INV_00(nq, nq_b);

endmodule

 
  