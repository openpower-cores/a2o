// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns





module fu_gst_inc19(
   a,
   o
);
   `include "tri_a2o.vh"
   

   
   input [1:19]  a;
   
   output [1:19] o;		
   
   
   wire [01:19]  a_sum;
   wire [02:19]  a_cout_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [02:19]  g2_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [02:19]  g4;
   (* NO_MODIFICATION="TRUE" *) 
   wire [02:19]  g8_b;
   (* NO_MODIFICATION="TRUE" *) 
   wire [02:19]  g16;
   
 
   
   assign g2_b[19] = (~(a[19]));
   assign g2_b[18] = (~(a[18] & a[19]));
   assign g2_b[17] = (~(a[17] & a[18]));
   assign g2_b[16] = (~(a[16] & a[17]));
   assign g2_b[15] = (~(a[15] & a[16]));
   assign g2_b[14] = (~(a[14] & a[15]));
   assign g2_b[13] = (~(a[13] & a[14]));
   assign g2_b[12] = (~(a[12] & a[13]));
   assign g2_b[11] = (~(a[11] & a[12]));
   assign g2_b[10] = (~(a[10] & a[11]));
   assign g2_b[9] = (~(a[9] & a[10]));
   assign g2_b[8] = (~(a[8] & a[9]));
   assign g2_b[7] = (~(a[7] & a[8]));
   assign g2_b[6] = (~(a[6] & a[7]));
   assign g2_b[5] = (~(a[5] & a[6]));
   assign g2_b[4] = (~(a[4] & a[5]));
   assign g2_b[3] = (~(a[3] & a[4]));
   assign g2_b[2] = (~(a[2] & a[3]));
   
   assign g4[19] = (~(g2_b[19]));
   assign g4[18] = (~(g2_b[18]));
   assign g4[17] = (~(g2_b[17] | g2_b[19]));
   assign g4[16] = (~(g2_b[16] | g2_b[18]));
   assign g4[15] = (~(g2_b[15] | g2_b[17]));
   assign g4[14] = (~(g2_b[14] | g2_b[16]));
   assign g4[13] = (~(g2_b[13] | g2_b[15]));
   assign g4[12] = (~(g2_b[12] | g2_b[14]));
   assign g4[11] = (~(g2_b[11] | g2_b[13]));
   assign g4[10] = (~(g2_b[10] | g2_b[12]));
   assign g4[9] = (~(g2_b[9] | g2_b[11]));
   assign g4[8] = (~(g2_b[8] | g2_b[10]));
   assign g4[7] = (~(g2_b[7] | g2_b[9]));
   assign g4[6] = (~(g2_b[6] | g2_b[8]));
   assign g4[5] = (~(g2_b[5] | g2_b[7]));
   assign g4[4] = (~(g2_b[4] | g2_b[6]));
   assign g4[3] = (~(g2_b[3] | g2_b[5]));
   assign g4[2] = (~(g2_b[2] | g2_b[4]));
   
   assign g8_b[19] = (~(g4[19]));
   assign g8_b[18] = (~(g4[18]));
   assign g8_b[17] = (~(g4[17]));
   assign g8_b[16] = (~(g4[16]));
   assign g8_b[15] = (~(g4[15] & g4[19]));
   assign g8_b[14] = (~(g4[14] & g4[18]));
   assign g8_b[13] = (~(g4[13] & g4[17]));
   assign g8_b[12] = (~(g4[12] & g4[16]));
   assign g8_b[11] = (~(g4[11] & g4[15]));
   assign g8_b[10] = (~(g4[10] & g4[14]));
   assign g8_b[9] = (~(g4[9] & g4[13]));
   assign g8_b[8] = (~(g4[8] & g4[12]));
   assign g8_b[7] = (~(g4[7] & g4[11]));
   assign g8_b[6] = (~(g4[6] & g4[10]));
   assign g8_b[5] = (~(g4[5] & g4[9]));
   assign g8_b[4] = (~(g4[4] & g4[8]));
   assign g8_b[3] = (~(g4[3] & g4[7]));
   assign g8_b[2] = (~(g4[2] & g4[6]));
   
   assign g16[19] = (~(g8_b[19]));
   assign g16[18] = (~(g8_b[18]));
   assign g16[17] = (~(g8_b[17]));
   assign g16[16] = (~(g8_b[16]));
   assign g16[15] = (~(g8_b[15]));
   assign g16[14] = (~(g8_b[14]));
   assign g16[13] = (~(g8_b[13]));
   assign g16[12] = (~(g8_b[12]));
   assign g16[11] = (~(g8_b[11] | g8_b[19]));
   assign g16[10] = (~(g8_b[10] | g8_b[18]));
   assign g16[9] = (~(g8_b[9] | g8_b[17]));
   assign g16[8] = (~(g8_b[8] | g8_b[16]));
   assign g16[7] = (~(g8_b[7] | g8_b[15]));
   assign g16[6] = (~(g8_b[6] | g8_b[14]));
   assign g16[5] = (~(g8_b[5] | g8_b[13]));
   assign g16[4] = (~(g8_b[4] | g8_b[12]));
   assign g16[3] = (~(g8_b[3] | g8_b[11]));
   assign g16[2] = (~(g8_b[2] | g8_b[10]));
   
   assign a_cout_b[19] = (~(g16[19]));
   assign a_cout_b[18] = (~(g16[18]));
   assign a_cout_b[17] = (~(g16[17]));
   assign a_cout_b[16] = (~(g16[16]));
   assign a_cout_b[15] = (~(g16[15]));
   assign a_cout_b[14] = (~(g16[14]));
   assign a_cout_b[13] = (~(g16[13]));
   assign a_cout_b[12] = (~(g16[12]));
   assign a_cout_b[11] = (~(g16[11]));
   assign a_cout_b[10] = (~(g16[10]));
   assign a_cout_b[9] = (~(g16[9]));
   assign a_cout_b[8] = (~(g16[8]));
   assign a_cout_b[7] = (~(g16[7]));
   assign a_cout_b[6] = (~(g16[6]));
   assign a_cout_b[5] = (~(g16[5]));
   assign a_cout_b[4] = (~(g16[4]));
   assign a_cout_b[3] = (~(g16[3] & g16[19]));
   assign a_cout_b[2] = (~(g16[2] & g16[18]));
   
   assign a_sum[1:18] = a[1:18];
   assign a_sum[19] = (~a[19]);
   
   assign o[01:18] = (~(a_sum[01:18] ^ a_cout_b[02:19]));		
   assign o[19] = a_sum[19];		
   
endmodule
