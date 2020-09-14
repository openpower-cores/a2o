// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





module fu_divsqrt_add4(
   x,
   y,
   s
);
`include "tri_a2o.vh"
   
   input [0:3]  x;
   input [0:3]  y;
   output [0:3] s;
   
   wire [0:3]   h;
   wire [1:3]   g_b;
   wire [1:2]   t_b;
   wire         g2_3t3;
   wire         g2_2t3;
   wire         g2_1t2;
   wire         t2_1t2;
   
   wire         g4_1t3_b;
   
   wire         g8_1t3;
   








   
 
   tri_xor2 #(.WIDTH(4), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_00(h[0:3], x[0:3], y[0:3]);
   
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X4M_A9TH")) DIVSQRT_NOR2_t_b_1(t_b[1], x[1], y[1]);
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X2M_A9TH")) DIVSQRT_NOR2_t_b_2(t_b[2], x[2], y[2]);
      

   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X1M_A9TH")) DIVSQRT_NAND2_g_b_1(g_b[1], x[1], y[1]);
   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X2M_A9TH")) DIVSQRT_NAND2_g_b_2(g_b[2], x[2], y[2]);
   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X4M_A9TH")) DIVSQRT_NAND2_g_b_3(g_b[3], x[3], y[3]);
           
   
   tri_inv #(.WIDTH(1), .BTR("INV_X6M_A9TH")) DIVSQRT_INV_g2_3t3(g2_3t3, g_b[3]);
   
   
   tri_oai21 #(.WIDTH(1), .BTR("OAI21_X3M_A9TH")) DIVSQRT_OAI21_g2_2t3(g2_2t3, t_b[2], g_b[3], g_b[2]);
   
   
   tri_oai21 #(.WIDTH(1), .BTR("OAI21_X4M_A9TH")) DIVSQRT_OAI21_g2_1t2(g2_1t2, t_b[1], g_b[2], g_b[1]);
   

   
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X2M_A9TH")) DIVSQRT_NOR2_t2_1t2(t2_1t2, t_b[1], t_b[2]);
   
   tri_aoi21 #(.WIDTH(1), .BTR("AOI21_X4M_A9TH")) DIVSQRT_AOI21_g4_1t3_b(g4_1t3_b, t2_1t2, g2_3t3, g2_1t2);
   
   tri_inv #(.WIDTH(1), .BTR("INV_X6M_A9TH")) DIVSQRT_INV_g8_1t3(g8_1t3, g4_1t3_b);
   


   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_10(s[0], g8_1t3, h[0]);
 
   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_11(s[1], g2_2t3, h[1]);
   		   
   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_12(s[2], g2_3t3, h[2]);   

   assign s[3] = (h[3]);		
   
endmodule
