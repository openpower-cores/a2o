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


module fu_loc8inc_lsb(
   x,
   co_b,
   s0,
   s1
);
   input [0:4]  x;		//48 to 52
   output       co_b;
   output [0:4] s0;
   output [0:4] s1;

   wire [0:4]   x_b;
   wire [0:4]   t2_b;
   wire [0:4]   t4;

   // FOLDED layout
   //   i0_xb   i2_xb   i4_xb   skip   skip   skip   skip
   //   i1_xb   i3_xb   skip    skip   skip   skip   skip
   //   i0_t2   i2_t2   i4_t2   skip   skip   skip   skip
   //   skip    i1_t2   i3_t2   skip   skip   skip   skip
   //   i0_t2   i2_t2   i4_t2   skip   skip   skip   skip
   //   i0_t8   i1_t2   i3_t2   skip   skip   skip   skip
   //   i0_s0   i2_s0   i4_s0   skip   skip   skip   skip
   //   i1_s0   i3_s0   skip    skip   skip   skip   skip
   //   i0_s1   i2_s1   i4_s1   skip   skip   skip   skip
   //   i1_s1   i3_s1   skip    skip   skip   skip   skip

   //-------------------------------
   // buffer off non critical path
   //-------------------------------

   assign x_b[0] = (~x[0]);
   assign x_b[1] = (~x[1]);
   assign x_b[2] = (~x[2]);
   assign x_b[3] = (~x[3]);
   assign x_b[4] = (~x[4]);

   //--------------------------
   // local carry chain
   //--------------------------

   assign t2_b[0] = (~(x[0]));
   assign t2_b[1] = (~(x[1] & x[2]));
   assign t2_b[2] = (~(x[2] & x[3]));
   assign t2_b[3] = (~(x[3] & x[4]));
   assign t2_b[4] = (~(x[4]));

   assign t4[0] = (~(t2_b[0]));
   assign t4[1] = (~(t2_b[1] | t2_b[3]));
   assign t4[2] = (~(t2_b[2] | t2_b[4]));
   assign t4[3] = (~(t2_b[3]));
   assign t4[4] = (~(t2_b[4]));

   assign co_b = (~(t4[0] & t4[1]));

   //------------------------
   // sum generation
   //------------------------

   assign s0[0] = (~(x_b[0]));
   assign s0[1] = (~(x_b[1]));
   assign s0[2] = (~(x_b[2]));
   assign s0[3] = (~(x_b[3]));
   assign s0[4] = (~(x_b[4]));

   assign s1[0] = (~(x_b[0] ^ t4[1]));
   assign s1[1] = (~(x_b[1] ^ t4[2]));
   assign s1[2] = (~(x_b[2] ^ t4[3]));
   assign s1[3] = (~(x_b[3] ^ t4[4]));
   assign s1[4] = (~(t4[4]));

endmodule
