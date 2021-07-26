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
