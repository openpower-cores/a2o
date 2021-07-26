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

////############################################################################
////#####  Quotient digit selection logic                              #########
////############################################################################

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

   //VHDL is below in comments to preserve the labels
   //sum4_l1xor:   h(0 to 3)   <=    ( x(0 to 3) xor y(0 to 3) ) ;--Lvl 1/2 P
   //sum4_l1nor:   t_b(1 to 2) <= not( x(1 to 2) or  y(1 to 2) ) ;--Lvl 1   P or G ... -KILL
   //sum4_l1nand:  g_b(1 to 3) <= not( x(1 to 3) and y(1 to 3) ) ;--Lvl 1   G

   //sum4_l2not:   g2_3t3 <= not(                       g_b(3)  );--kogge-stone carry tree
   //sum4_l2oai1:  g2_2t3 <= not(g_b(2) and (t_b(2) or  g_b(3)) );
   //sum4_l2oai2:  g2_1t2 <= not(g_b(1) and (t_b(1) or  g_b(2)) );

   //sum4_l2nor:   t2_1t2 <= not(           (t_b(1) or  t_b(2)) );

   //sum4_l3aoi:   g4_1t3_b <= not(g2_1t2 or  (t2_1t2 and g2_3t3) );

   //sum4_l4not3:  g8_1t3 <= not( g4_1t3_b  );

   //sum4_l5xor0:  s(0)  <=     ( g8_1t3 xor h(0) );--output
   //sum4_l5xor1:  s(1)  <=     ( g2_2t3 xor h(1) );--output
   //sum4_l5xor2:  s(2)  <=     ( g2_3t3 xor h(2) );--output
   //              s(3)  <=     (            h(3) );--output

   // EXAMPLE
   // tri_xor2 #(.WIDTH(1), .BTR("XOR2_X2M_A9TH")) DIVSQRT_XOR2_0(s[0], g8_1t3, h[0]);

   ////////////////////////////////////////////////////////////////////////////////////////////////
   //assign h[0:3] = (x[0:3] ^ y[0:3]);		//Lvl 1/2 P
   tri_xor2 #(.WIDTH(4), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_00(h[0:3], x[0:3], y[0:3]);

   //assign t_b[1:2] = (~(x[1:2] | y[1:2]));		//Lvl 1   P or G ... -KILL
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X4M_A9TH")) DIVSQRT_NOR2_t_b_1(t_b[1], x[1], y[1]);
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X2M_A9TH")) DIVSQRT_NOR2_t_b_2(t_b[2], x[2], y[2]);


   //assign g_b[1:3] = (~(x[1:3] & y[1:3]));		//Lvl 1   G
   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X1M_A9TH")) DIVSQRT_NAND2_g_b_1(g_b[1], x[1], y[1]);
   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X2M_A9TH")) DIVSQRT_NAND2_g_b_2(g_b[2], x[2], y[2]);
   tri_nand2 #(.WIDTH(1), .BTR("NAND2_X4M_A9TH")) DIVSQRT_NAND2_g_b_3(g_b[3], x[3], y[3]);


   //assign g2_3t3 = (~(g_b[3]));		//kogge-stone carry tree
   tri_inv #(.WIDTH(1), .BTR("INV_X6M_A9TH")) DIVSQRT_INV_g2_3t3(g2_3t3, g_b[3]);


   //assign g2_2t3 = (~(g_b[2] & (t_b[2] | g_b[3])));
   tri_oai21 #(.WIDTH(1), .BTR("OAI21_X3M_A9TH")) DIVSQRT_OAI21_g2_2t3(g2_2t3, t_b[2], g_b[3], g_b[2]);


   //assign g2_1t2 = (~(g_b[1] & (t_b[1] | g_b[2])));
   tri_oai21 #(.WIDTH(1), .BTR("OAI21_X4M_A9TH")) DIVSQRT_OAI21_g2_1t2(g2_1t2, t_b[1], g_b[2], g_b[1]);



   //assign t2_1t2 = (~((t_b[1] | t_b[2])));
   tri_nor2 #(.WIDTH(1), .BTR("NOR2_X2M_A9TH")) DIVSQRT_NOR2_t2_1t2(t2_1t2, t_b[1], t_b[2]);

   //assign g4_1t3_b = (~(g2_1t2 | (t2_1t2 & g2_3t3)));
   tri_aoi21 #(.WIDTH(1), .BTR("AOI21_X4M_A9TH")) DIVSQRT_AOI21_g4_1t3_b(g4_1t3_b, t2_1t2, g2_3t3, g2_1t2);

   //assign g8_1t3 = (~(g4_1t3_b));
   tri_inv #(.WIDTH(1), .BTR("INV_X6M_A9TH")) DIVSQRT_INV_g8_1t3(g8_1t3, g4_1t3_b);



   //assign s[0] = (g8_1t3 ^ h[0]);		//output
   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_10(s[0], g8_1t3, h[0]);

   //assign s[1] = (g2_2t3 ^ h[1]);		//output
   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_11(s[1], g2_2t3, h[1]);

   //assign s[2] = (g2_3t3 ^ h[2]);		//output
   tri_xor2  #(.WIDTH(1), .BTR("XOR2_X4M_A9TH")) DIVSQRT_XOR2_12(s[2], g2_3t3, h[2]);

   assign s[3] = (h[3]);		//output

endmodule
