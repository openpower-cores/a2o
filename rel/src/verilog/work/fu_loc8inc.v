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
   
module fu_loc8inc(
   x,
   ci,
   ci_b,
   co_b,
   s0,
   s1
);
   input [0:7]  x;
   input        ci;
   input        ci_b;
   output       co_b;
   output [0:7] s0;
   output [0:7] s1;
   
   
   wire [0:7]   x_if_ci;
   wire [0:7]   x_b;
   wire [0:7]   x_p;
   wire         g2_6t7_b;
   wire         g2_4t5_b;
   wire         g2_2t3_b;
   wire         g2_0t1_b;
   wire         g4_4t7;
   wire         g4_0t3;
   wire         t2_6t7;
   wire         t2_4t5;
   wire         t2_2t3;
   wire         t4_6t7_b;
   wire         t4_4t7_b;
   wire         t4_2t5_b;
   wire         t8_6t7;
   wire         t8_4t7;
   wire         t8_2t7;
   wire         t8_7t7_b;
   wire         t8_6t7_b;
   wire         t8_5t7_b;
   wire         t8_4t7_b;
   wire         t8_3t7_b;
   wire         t8_2t7_b;
   wire         t8_1t7_b;
   wire [0:7]   s1x_b;
   wire [0:7]   s1y_b;
   wire [0:7]   s0_b;
   
   
   
   
   assign x_b[0] = (~x[0]);
   assign x_b[1] = (~x[1]);
   assign x_b[2] = (~x[2]);
   assign x_b[3] = (~x[3]);
   assign x_b[4] = (~x[4]);
   assign x_b[5] = (~x[5]);
   assign x_b[6] = (~x[6]);
   assign x_b[7] = (~x[7]);
   
   assign x_p[0] = (~x_b[0]);
   assign x_p[1] = (~x_b[1]);
   assign x_p[2] = (~x_b[2]);
   assign x_p[3] = (~x_b[3]);
   assign x_p[4] = (~x_b[4]);
   assign x_p[5] = (~x_b[5]);
   assign x_p[6] = (~x_b[6]);
   assign x_p[7] = (~x_b[7]);
   
   
   assign g2_0t1_b = (~(x[0] & x[1]));		
   assign g2_2t3_b = (~(x[2] & x[3]));		
   assign g2_4t5_b = (~(x[4] & x[5]));		
   assign g2_6t7_b = (~(x[6] & x[7]));		
   
   assign g4_0t3 = (~(g2_0t1_b | g2_2t3_b));		
   assign g4_4t7 = (~(g2_4t5_b | g2_6t7_b));		
   
   assign co_b = (~(g4_0t3 & g4_4t7));		
   
   
   assign t2_2t3 = (~(x_b[2] | x_b[3]));		
   assign t2_4t5 = (~(x_b[4] | x_b[5]));		
   assign t2_6t7 = (~(x_b[6] | x_b[7]));		
   
   assign t4_2t5_b = (~(t2_2t3 & t2_4t5));		
   assign t4_4t7_b = (~(t2_4t5 & t2_6t7));		
   assign t4_6t7_b = (~(t2_6t7));		
   
   assign t8_2t7 = (~(t4_2t5_b | t4_6t7_b));		
   assign t8_4t7 = (~(t4_4t7_b));		
   assign t8_6t7 = (~(t4_6t7_b));		
   
   assign t8_1t7_b = (~(t8_2t7 & x_p[1]));		
   assign t8_2t7_b = (~(t8_2t7));		
   assign t8_3t7_b = (~(t8_4t7 & x_p[3]));		
   assign t8_4t7_b = (~(t8_4t7));		
   assign t8_5t7_b = (~(t8_6t7 & x_p[5]));		
   assign t8_6t7_b = (~(t8_6t7));		
   assign t8_7t7_b = (~(x_p[7]));		
   
   
   assign x_if_ci[0] = (~(x_p[0] ^ t8_1t7_b));
   assign x_if_ci[1] = (~(x_p[1] ^ t8_2t7_b));
   assign x_if_ci[2] = (~(x_p[2] ^ t8_3t7_b));
   assign x_if_ci[3] = (~(x_p[3] ^ t8_4t7_b));
   assign x_if_ci[4] = (~(x_p[4] ^ t8_5t7_b));
   assign x_if_ci[5] = (~(x_p[5] ^ t8_6t7_b));
   assign x_if_ci[6] = (~(x_p[6] ^ t8_7t7_b));
   assign x_if_ci[7] = (~(x_p[7]));
   
   assign s1x_b[0] = (~(x_p[0] & ci_b));
   assign s1x_b[1] = (~(x_p[1] & ci_b));
   assign s1x_b[2] = (~(x_p[2] & ci_b));
   assign s1x_b[3] = (~(x_p[3] & ci_b));
   assign s1x_b[4] = (~(x_p[4] & ci_b));
   assign s1x_b[5] = (~(x_p[5] & ci_b));
   assign s1x_b[6] = (~(x_p[6] & ci_b));
   assign s1x_b[7] = (~(x_p[7] & ci_b));
   
   assign s1y_b[0] = (~(x_if_ci[0] & ci));
   assign s1y_b[1] = (~(x_if_ci[1] & ci));
   assign s1y_b[2] = (~(x_if_ci[2] & ci));
   assign s1y_b[3] = (~(x_if_ci[3] & ci));
   assign s1y_b[4] = (~(x_if_ci[4] & ci));
   assign s1y_b[5] = (~(x_if_ci[5] & ci));
   assign s1y_b[6] = (~(x_if_ci[6] & ci));
   assign s1y_b[7] = (~(x_if_ci[7] & ci));
   
   assign s1[0] = (~(s1x_b[0] & s1y_b[0]));		
   assign s1[1] = (~(s1x_b[1] & s1y_b[1]));		
   assign s1[2] = (~(s1x_b[2] & s1y_b[2]));		
   assign s1[3] = (~(s1x_b[3] & s1y_b[3]));		
   assign s1[4] = (~(s1x_b[4] & s1y_b[4]));		
   assign s1[5] = (~(s1x_b[5] & s1y_b[5]));		
   assign s1[6] = (~(s1x_b[6] & s1y_b[6]));		
   assign s1[7] = (~(s1x_b[7] & s1y_b[7]));		
   
   assign s0_b[0] = (~x_p[0]);
   assign s0_b[1] = (~x_p[1]);
   assign s0_b[2] = (~x_p[2]);
   assign s0_b[3] = (~x_p[3]);
   assign s0_b[4] = (~x_p[4]);
   assign s0_b[5] = (~x_p[5]);
   assign s0_b[6] = (~x_p[6]);
   assign s0_b[7] = (~x_p[7]);
   
   assign s0[0] = (~s0_b[0]);		
   assign s0[1] = (~s0_b[1]);		
   assign s0[2] = (~s0_b[2]);		
   assign s0[3] = (~s0_b[3]);		
   assign s0[4] = (~s0_b[4]);		
   assign s0[5] = (~s0_b[5]);		
   assign s0[6] = (~s0_b[6]);		
   assign s0[7] = (~s0_b[7]);		
   
endmodule
