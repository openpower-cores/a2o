// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


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
