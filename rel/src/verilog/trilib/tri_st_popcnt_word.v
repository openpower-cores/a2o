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

//*****************************************************************************
//  Description:  XU Population Count - Word Phase
//
//*****************************************************************************

module tri_st_popcnt_word(
   b0,
   b1,
   b2,
   b3,
   y,
   vdd,
   gnd
);
   input [0:3]  b0;
   input [0:3]  b1;
   input [0:3]  b2;
   input [0:3]  b3;
   output [0:5] y;
   inout        vdd;
   inout        gnd;

   wire [0:0]   s0;
   wire [0:1]   c1;
   wire [0:1]   s1;
   wire [0:2]   c2;
   wire [0:1]   s2;
   wire [0:2]   c3;
   wire [0:1]   s3;
   wire [0:2]   c4;

   // Level 0

   tri_csa32 csa_l0_0(
      .vd(vdd),
      .gd(gnd),
      .a(b0[0]),
      .b(b0[1]),
      .c(b0[2]),
      .sum(s0[0]),
      .car(c1[0])
   );


   tri_csa22 csa_l0_1(
      .a(b0[3]),
      .b(s0[0]),
      .sum(y[5]),
      .car(c1[1])
   );

   // Level 1

   tri_csa32 csa_l1_0(
      .vd(vdd),
      .gd(gnd),
      .a(b1[0]),
      .b(b1[1]),
      .c(b1[2]),
      .sum(s1[0]),
      .car(c2[0])
   );


   tri_csa32 csa_l1_1(
      .vd(vdd),
      .gd(gnd),
      .a(b1[3]),
      .b(c1[0]),
      .c(c1[1]),
      .sum(s1[1]),
      .car(c2[1])
   );


   tri_csa22 csa_l1_2(
      .a(s1[0]),
      .b(s1[1]),
      .sum(y[4]),
      .car(c2[2])
   );

   // Level 2

   tri_csa32 csa_l2_0(
      .vd(vdd),
      .gd(gnd),
      .a(b2[0]),
      .b(b2[1]),
      .c(b2[2]),
      .sum(s2[0]),
      .car(c3[0])
   );


   tri_csa32 csa_l2_1(
      .vd(vdd),
      .gd(gnd),
      .a(b2[3]),
      .b(c2[0]),
      .c(c2[1]),
      .sum(s2[1]),
      .car(c3[1])
   );


   tri_csa32 csa_l2_2(
      .vd(vdd),
      .gd(gnd),
      .a(c2[2]),
      .b(s2[0]),
      .c(s2[1]),
      .sum(y[3]),
      .car(c3[2])
   );

   // Level 3

   tri_csa32 csa_l3_0(
      .vd(vdd),
      .gd(gnd),
      .a(b3[0]),
      .b(b3[1]),
      .c(b3[2]),
      .sum(s3[0]),
      .car(c4[0])
   );


   tri_csa32 csa_l3_1(
      .vd(vdd),
      .gd(gnd),
      .a(b3[3]),
      .b(c3[0]),
      .c(c3[1]),
      .sum(s3[1]),
      .car(c4[1])
   );


   tri_csa32 csa_l3_2(
      .vd(vdd),
      .gd(gnd),
      .a(c3[2]),
      .b(s3[0]),
      .c(s3[1]),
      .sum(y[2]),
      .car(c4[2])
   );

   // Level 4

   tri_csa32 csa_l4_0(
      .vd(vdd),
      .gd(gnd),
      .a(c4[0]),
      .b(c4[1]),
      .c(c4[2]),
      .sum(y[1]),
      .car(y[0])
   );

endmodule
