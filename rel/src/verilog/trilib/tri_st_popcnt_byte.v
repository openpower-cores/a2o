// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.


module tri_st_popcnt_byte(
   b0,
   y,
   vdd,
   gnd
);
   input [0:7]  b0;
   output [0:3] y;
   inout        vdd;
   inout        gnd;
   
   wire [0:2]   s0;
   wire [0:3]   c1;
   wire [0:0]   s1;
   wire [0:1]   c2;


   tri_csa32 csa_l0_0(
      .vd(vdd),
      .gd(gnd),
      .a(b0[0]),
      .b(b0[1]),
      .c(b0[2]),
      .sum(s0[0]),
      .car(c1[0])
   );


   tri_csa32 csa_l0_1(
      .vd(vdd),
      .gd(gnd),
      .a(b0[3]),
      .b(b0[4]),
      .c(b0[5]),
      .sum(s0[1]),
      .car(c1[1])
   );


   tri_csa22 csa_l0_2(
      .a(b0[6]),
      .b(b0[7]),
      .sum(s0[2]),
      .car(c1[2])
   );


   tri_csa32 csa_l0_3(
      .vd(vdd),
      .gd(gnd),
      .a(s0[0]),
      .b(s0[1]),
      .c(s0[2]),
      .sum(y[3]),
      .car(c1[3])
   );


   tri_csa32 csa_l1_0(
      .vd(vdd),
      .gd(gnd),
      .a(c1[0]),
      .b(c1[1]),
      .c(c1[2]),
      .sum(s1[0]),
      .car(c2[0])
   );


   tri_csa22 csa_l1_1(
      .a(c1[3]),
      .b(s1[0]),
      .sum(y[2]),
      .car(c2[1])
   );


   tri_csa22 csa_l2_0(
      .a(c2[0]),
      .b(c2[1]),
      .sum(y[1]),
      .car(y[0])
   );
      

endmodule
