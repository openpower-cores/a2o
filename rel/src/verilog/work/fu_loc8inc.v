// © IBM Corp. 2020
// Licensed under the Apache License, Version 2.0 (the "License"), as modified by
// the terms below; you may not use the files in this repository except in
// compliance with the License as modified.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Modified Terms:
//
//    1) For the purpose of the patent license granted to you in Section 3 of the
//    License, the "Work" hereby includes implementations of the work of authorship
//    in physical form.
//
//    2) Notwithstanding any terms to the contrary in the License, any licenses
//    necessary for implementation of the Work that are available from OpenPOWER
//    via the Power ISA End User License Agreement (EULA) are explicitly excluded
//    hereunder, and may be obtained from OpenPOWER under the terms and conditions
//    of the EULA.  
//
// Unless required by applicable law or agreed to in writing, the reference design
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License
// for the specific language governing permissions and limitations under the License.
// 
// Additional rights, including the ability to physically implement a softcore that
// is compliant with the required sections of the Power ISA Specification, are
// available at no cost under the terms of the OpenPOWER Power ISA EULA, which can be
// obtained (along with the Power ISA) here: https://openpowerfoundation.org. 

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

   //  i0_b0    i1_b0   i2_b0   i3_b0   i4_b0   i5_b0   i6_b0   i7_b0   <=== buffer inputs
   //  i0_b1    i1_b1   i2_b1   i3_b1   i4_b1   i5_b1   i6_b1   i7_b1   <=== buffer inputs
   //  i0_g2    i0_g4   i2_g2   i0_g8   i4_g2   i4_g4   i6_g2   skip    <=== global chain
   //  skip     skip    i2_t4   i2_t2   i4_t4   i4_t2   i6_t4   i6_t2   <=== local carry
   //  skip     skip    i2_t8x  skip    i4_t8x  skip    i6_t8x  skip    <=== local carry
   //  skip     i1_t8   i2_t8   i3_t8   i4_t8   i5_t8   i6_t8   i7_t8   <=== local carry
   //  i0_if    i1_if   i2_if   i3_if   i4_if   i5_if   i6_if   i7_if   <=== local carry
   //  i0_s1x   i1_s1x  i2_s1x  i3_s1x  i4_s1x  i5_s1x  i6_s1x  i7_s1x  <=== carry select
   //  i0_s1y   i1_s1y  i2_s1y  i3_s1y  i4_s1y  i5_s1y  i6_s1y  i7_s1y  <=== carry select
   //  i0_s1    i1_s1   i2_s1   i3_s1   i4_s1   i5_s1   i6_s1   i7_s1   <=== carry select
   //  i0_s0b   i1_s0b  i2_s0b  i3_s0b  i4_s0b  i5_s0b  i6_s0b  i7_s0b  <=== carry select
   //  i0_s0    i1_s0   i2_s0   i3_s0   i4_s0   i5_s0   i6_s0   i7_s0   <=== carry select

   //FOLDED

   //  i0_b0    i2_b0   i4_b0   i6_b0   skip  skip  skip  skip <=== buffer inputs
   //  i1_b0    i3_b0   i5_b0   i7_b0   skip  skip  skip  skip <=== buffer inputs
   //  i0_b1    i2_b1   i4_b1   i6_b1   skip  skip  skip  skip <=== buffer inputs
   //  i1_b1    i3_b1   i5_b1   i7_b1   skip  skip  skip  skip <=== buffer inputs
   //  i0_g2    i2_g2   i4_g2   i6_g2   skip  skip  skip  skip <=== global chain
   //  i0_g4    i0_g8   i4_g4   skip    skip  skip  skip  skip <=== global chain
   //  skip     i2_t2   i4_t2   i6_t2   skip  skip  skip  skip <=== local carry
   //  skip     i2_t4   i4_t4   i6_t4   skip  skip  skip  skip <=== local carry
   //  skip     i2_t8x  i4_t8x  i6_t8x  skip  skip  skip  skip <=== local carry
   //  skip     i2_t8   i4_t8   i6_t8   skip  skip  skip  skip <=== local carry
   //  i1_t8    i3_t8   i5_t8   i7_t8   skip  skip  skip  skip <=== local carry
   //  i0_if    i2_if   i4_if   i6_if   skip  skip  skip  skip <=== local carry
   //  i1_if    i3_if   i5_if   i7_if   skip  skip  skip  skip <=== local carry
   //  i0_s1x   i2_s1x  i4_s1x  i6_s1x  skip  skip  skip  skip <=== carry select
   //  i1_s1x   i3_s1x  i5_s1x  i7_s1x  skip  skip  skip  skip <=== carry select
   //  i0_s1y   i2_s1y  i4_s1y  i6_s1y  skip  skip  skip  skip <=== carry select
   //  i1_s1y   i3_s1y  i5_s1y  i7_s1y  skip  skip  skip  skip <=== carry select
   //  i0_s1    i2_s1   i4_s1   i6_s1   skip  skip  skip  skip <=== carry select
   //  i1_s1    i3_s1   i5_s1   i7_s1   skip  skip  skip  skip <=== carry select
   //  i0_s0b   i2_s0b  i4_s0b  i6_s0b  skip  skip  skip  skip <=== carry select
   //  i1_s0b   i3_s0b  i5_s0b  i7_s0b  skip  skip  skip  skip <=== carry select
   //  i0_s0    i2_s0   i4_s0   i6_s0   skip  skip  skip  skip <=== carry select
   //  i1_s0    i3_s0   i5_s0   i7_s0   skip  skip  skip  skip <=== carry select

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

   //--------------------------------------------

   assign g2_0t1_b = (~(x[0] & x[1]));		//0--
   assign g2_2t3_b = (~(x[2] & x[3]));		//2--
   assign g2_4t5_b = (~(x[4] & x[5]));		//4--
   assign g2_6t7_b = (~(x[6] & x[7]));		//6--

   assign g4_0t3 = (~(g2_0t1_b | g2_2t3_b));		//1--
   assign g4_4t7 = (~(g2_4t5_b | g2_6t7_b));		//5--

   assign co_b = (~(g4_0t3 & g4_4t7));		//3-- ; --output

   //-------------------------------------------

   assign t2_2t3 = (~(x_b[2] | x_b[3]));		//2--
   assign t2_4t5 = (~(x_b[4] | x_b[5]));		//4--
   assign t2_6t7 = (~(x_b[6] | x_b[7]));		//6--

   assign t4_2t5_b = (~(t2_2t3 & t2_4t5));		//3--
   assign t4_4t7_b = (~(t2_4t5 & t2_6t7));		//5--
   assign t4_6t7_b = (~(t2_6t7));		//7--

   assign t8_2t7 = (~(t4_2t5_b | t4_6t7_b));		//3--
   assign t8_4t7 = (~(t4_4t7_b));		//5--
   assign t8_6t7 = (~(t4_6t7_b));		//7--

   assign t8_1t7_b = (~(t8_2t7 & x_p[1]));		//1--
   assign t8_2t7_b = (~(t8_2t7));		//2--
   assign t8_3t7_b = (~(t8_4t7 & x_p[3]));		//3--
   assign t8_4t7_b = (~(t8_4t7));		//4--
   assign t8_5t7_b = (~(t8_6t7 & x_p[5]));		//5--
   assign t8_6t7_b = (~(t8_6t7));		//6--
   assign t8_7t7_b = (~(x_p[7]));		//7--

   //------------------------------------

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

   assign s1[0] = (~(s1x_b[0] & s1y_b[0]));		//output
   assign s1[1] = (~(s1x_b[1] & s1y_b[1]));		//output
   assign s1[2] = (~(s1x_b[2] & s1y_b[2]));		//output
   assign s1[3] = (~(s1x_b[3] & s1y_b[3]));		//output
   assign s1[4] = (~(s1x_b[4] & s1y_b[4]));		//output
   assign s1[5] = (~(s1x_b[5] & s1y_b[5]));		//output
   assign s1[6] = (~(s1x_b[6] & s1y_b[6]));		//output
   assign s1[7] = (~(s1x_b[7] & s1y_b[7]));		//output

   assign s0_b[0] = (~x_p[0]);
   assign s0_b[1] = (~x_p[1]);
   assign s0_b[2] = (~x_p[2]);
   assign s0_b[3] = (~x_p[3]);
   assign s0_b[4] = (~x_p[4]);
   assign s0_b[5] = (~x_p[5]);
   assign s0_b[6] = (~x_p[6]);
   assign s0_b[7] = (~x_p[7]);

   assign s0[0] = (~s0_b[0]);		// output
   assign s0[1] = (~s0_b[1]);		// output
   assign s0[2] = (~s0_b[2]);		// output
   assign s0[3] = (~s0_b[3]);		// output
   assign s0[4] = (~s0_b[4]);		// output
   assign s0[5] = (~s0_b[5]);		// output
   assign s0[6] = (~s0_b[6]);		// output
   assign s0[7] = (~s0_b[7]);		// output

endmodule
