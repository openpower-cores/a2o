// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





module fu_divsqrt_q_table(
   x, 
   cin, 
   q
);
`include "tri_a2o.vh"
   
   input [0:3]  x;
   input        cin;
   
   output  q;
   
   wire    nor123;
   wire    nor123_b;   

   wire    x0_b;
   wire    not0and1or2or3_b; 
   wire    nor01;
   wire    nor23;
   wire    not0or1or2or3_and_cin_b;
   
         

 
   tri_nor3 #(.WIDTH(1), .BTR("NOR3_X4M_A9TH"))  DIVSQRT_N_TABLE_NOR3_01(nor123, x[1], x[2], x[3]);
   tri_inv  #(.WIDTH(1), .BTR("INV_X3M_A9TH"))   DIVSQRT_N_TABLE_INV_02a(nor123_b, nor123);
   tri_inv  #(.WIDTH(1), .BTR("INV_X5B_A9TH"))   DIVSQRT_N_TABLE_INV_02b(x0_b, x[0]);

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X4A_A9TH")) DIVSQRT_N_TABLE_NAND2_03(not0and1or2or3_b, x0_b, nor123_b);
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X8B_A9TH"))  DIVSQRT_N_TABLE_NOR2_01a(nor01, x[0], x[1]);
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X4B_A9TH"))  DIVSQRT_N_TABLE_NOR2_01b(nor23, x[2], x[3]);
    
   tri_nand3 #(.WIDTH(1), .BTR("NAND3_X6M_A9TH")) DIVSQRT_N_TABLE_NAND3_02(not0or1or2or3_and_cin_b, nor01, nor23, cin);

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X8A_A9TH")) DIVSQRT_N_TABLE_NAND2_04(q, not0or1or2or3_and_cin_b, not0and1or2or3_b);
   

endmodule

 
  