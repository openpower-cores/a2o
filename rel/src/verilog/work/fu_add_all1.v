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
   

module fu_add_all1(
   ex4_inc_byt_c_b,
   ex4_inc_byt_c_glb,
   ex4_inc_byt_c_glb_b,
   ex4_inc_all1
);
   input [0:6]  ex4_inc_byt_c_b;		
   output [1:6] ex4_inc_byt_c_glb;
   output [1:6] ex4_inc_byt_c_glb_b;
   output       ex4_inc_all1;
   
   
   
   parameter    tiup = 1'b1;
   parameter    tidn = 1'b0;
   
   wire [0:6]   ex4_inc_byt_g1;
   wire [0:6]   ex4_inc_byt_g2_b;
   wire [0:6]   ex4_inc_byt_g4;
   wire [0:6]   ex4_inc_byt_g8_b;
   wire [1:6]   ex4_inc_byt_g_glb_int;
   

   
   assign ex4_inc_byt_g1[0:6] = (~ex4_inc_byt_c_b[0:6]);		
   
   assign ex4_inc_byt_g2_b[6] = (~(ex4_inc_byt_g1[6]));
   assign ex4_inc_byt_g2_b[5] = (~(ex4_inc_byt_g1[5] & ex4_inc_byt_g1[6]));
   assign ex4_inc_byt_g2_b[4] = (~(ex4_inc_byt_g1[4] & ex4_inc_byt_g1[5]));
   assign ex4_inc_byt_g2_b[3] = (~(ex4_inc_byt_g1[3] & ex4_inc_byt_g1[4]));
   assign ex4_inc_byt_g2_b[2] = (~(ex4_inc_byt_g1[2] & ex4_inc_byt_g1[3]));
   assign ex4_inc_byt_g2_b[1] = (~(ex4_inc_byt_g1[1] & ex4_inc_byt_g1[2]));
   assign ex4_inc_byt_g2_b[0] = (~(ex4_inc_byt_g1[0] & ex4_inc_byt_g1[1]));
   
   assign ex4_inc_byt_g4[6] = (~(ex4_inc_byt_g2_b[6]));
   assign ex4_inc_byt_g4[5] = (~(ex4_inc_byt_g2_b[5]));
   assign ex4_inc_byt_g4[4] = (~(ex4_inc_byt_g2_b[4] | ex4_inc_byt_g2_b[6]));
   assign ex4_inc_byt_g4[3] = (~(ex4_inc_byt_g2_b[3] | ex4_inc_byt_g2_b[5]));
   assign ex4_inc_byt_g4[2] = (~(ex4_inc_byt_g2_b[2] | ex4_inc_byt_g2_b[4]));
   assign ex4_inc_byt_g4[1] = (~(ex4_inc_byt_g2_b[1] | ex4_inc_byt_g2_b[3]));
   assign ex4_inc_byt_g4[0] = (~(ex4_inc_byt_g2_b[0] | ex4_inc_byt_g2_b[2]));
   
   assign ex4_inc_byt_g8_b[6] = (~(ex4_inc_byt_g4[6]));
   assign ex4_inc_byt_g8_b[5] = (~(ex4_inc_byt_g4[5]));
   assign ex4_inc_byt_g8_b[4] = (~(ex4_inc_byt_g4[4]));
   assign ex4_inc_byt_g8_b[3] = (~(ex4_inc_byt_g4[3]));
   assign ex4_inc_byt_g8_b[2] = (~(ex4_inc_byt_g4[2] & ex4_inc_byt_g4[6]));
   assign ex4_inc_byt_g8_b[1] = (~(ex4_inc_byt_g4[1] & ex4_inc_byt_g4[5]));
   assign ex4_inc_byt_g8_b[0] = (~(ex4_inc_byt_g4[0] & ex4_inc_byt_g4[4]));
   
   assign ex4_inc_all1 = (~ex4_inc_byt_g8_b[0]);
   assign ex4_inc_byt_c_glb[1] = (~ex4_inc_byt_g8_b[1]);		
   assign ex4_inc_byt_c_glb[2] = (~ex4_inc_byt_g8_b[2]);		
   assign ex4_inc_byt_c_glb[3] = (~ex4_inc_byt_g8_b[3]);		
   assign ex4_inc_byt_c_glb[4] = (~ex4_inc_byt_g8_b[4]);		
   assign ex4_inc_byt_c_glb[5] = (~ex4_inc_byt_g8_b[5]);		
   assign ex4_inc_byt_c_glb[6] = (~ex4_inc_byt_g8_b[6]);		
   
   assign ex4_inc_byt_g_glb_int[1] = (~ex4_inc_byt_g8_b[1]);
   assign ex4_inc_byt_g_glb_int[2] = (~ex4_inc_byt_g8_b[2]);
   assign ex4_inc_byt_g_glb_int[3] = (~ex4_inc_byt_g8_b[3]);
   assign ex4_inc_byt_g_glb_int[4] = (~ex4_inc_byt_g8_b[4]);
   assign ex4_inc_byt_g_glb_int[5] = (~ex4_inc_byt_g8_b[5]);
   assign ex4_inc_byt_g_glb_int[6] = (~ex4_inc_byt_g8_b[6]);
   
   assign ex4_inc_byt_c_glb_b[1] = (~ex4_inc_byt_g_glb_int[1]);		
   assign ex4_inc_byt_c_glb_b[2] = (~ex4_inc_byt_g_glb_int[2]);		
   assign ex4_inc_byt_c_glb_b[3] = (~ex4_inc_byt_g_glb_int[3]);		
   assign ex4_inc_byt_c_glb_b[4] = (~ex4_inc_byt_g_glb_int[4]);		
   assign ex4_inc_byt_c_glb_b[5] = (~ex4_inc_byt_g_glb_int[5]);		
   assign ex4_inc_byt_c_glb_b[6] = (~ex4_inc_byt_g_glb_int[6]);		
   
endmodule
