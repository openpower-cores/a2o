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
////#####  FUQ_GEST_add11.VHDL                                         #########
////#####  side pipe for graphics estimates                            #########
////#####  flogefp, fexptefp                                           #########
////#####                                                              #########
////############################################################################

module fu_gst_add11(
   a_b,
   b_b,
   s0
);
   `include "tri_a2o.vh"


   input [0:10]  a_b;		// inverted adder input
   input [0:10]  b_b;		// inverted adder input
   output [0:10] s0;

   (* NO_MODIFICATION="TRUE" *)
   wire [0:10]   p1;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:10]   g1;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:9]    t1;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:10]   g2_b;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:10]   g4;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:10]   g8_b;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:10]   c16;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:8]    t2_b;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:6]    t4;
   (* NO_MODIFICATION="TRUE" *)
   wire [1:2]    t8_b;

   assign p1[0:10] = (a_b[0:10] ^ b_b[0:10]);
   assign g1[1:10] = (~(a_b[1:10] | b_b[1:10]));
   assign t1[1:9] = (~(a_b[1:9] & b_b[1:9]));

   //---------------------------------------------
   //  carry chain                             ---
   //---------------------------------------------

   assign g2_b[1] = (~(g1[1] | (t1[1] & g1[2])));
   assign g2_b[2] = (~(g1[2] | (t1[2] & g1[3])));
   assign g2_b[3] = (~(g1[3] | (t1[3] & g1[4])));
   assign g2_b[4] = (~(g1[4] | (t1[4] & g1[5])));
   assign g2_b[5] = (~(g1[5] | (t1[5] & g1[6])));
   assign g2_b[6] = (~(g1[6] | (t1[6] & g1[7])));
   assign g2_b[7] = (~(g1[7] | (t1[7] & g1[8])));
   assign g2_b[8] = (~(g1[8] | (t1[8] & g1[9])));
   assign g2_b[9] = (~(g1[9] | (t1[9] & g1[10])));		//done
   assign g2_b[10] = (~(g1[10]));
   assign t2_b[1] = (~(t1[1] & t1[2]));
   assign t2_b[2] = (~(t1[2] & t1[3]));
   assign t2_b[3] = (~(t1[3] & t1[4]));
   assign t2_b[4] = (~(t1[4] & t1[5]));
   assign t2_b[5] = (~(t1[5] & t1[6]));
   assign t2_b[6] = (~(t1[6] & t1[7]));
   assign t2_b[7] = (~(t1[7] & t1[8]));
   assign t2_b[8] = (~(t1[8] & t1[9]));

   assign g4[1] = (~(g2_b[1] & (t2_b[1] | g2_b[3])));
   assign g4[2] = (~(g2_b[2] & (t2_b[2] | g2_b[4])));
   assign g4[3] = (~(g2_b[3] & (t2_b[3] | g2_b[5])));
   assign g4[4] = (~(g2_b[4] & (t2_b[4] | g2_b[6])));
   assign g4[5] = (~(g2_b[5] & (t2_b[5] | g2_b[7])));
   assign g4[6] = (~(g2_b[6] & (t2_b[6] | g2_b[8])));
   assign g4[7] = (~(g2_b[7] & (t2_b[7] | g2_b[9])));		//done
   assign g4[8] = (~(g2_b[8] & (t2_b[8] | g2_b[10])));		//done
   assign g4[9] = (~(g2_b[9]));
   assign g4[10] = (~(g2_b[10]));
   assign t4[1] = (~(t2_b[1] | t2_b[3]));
   assign t4[2] = (~(t2_b[2] | t2_b[4]));
   assign t4[3] = (~(t2_b[3] | t2_b[5]));
   assign t4[4] = (~(t2_b[4] | t2_b[6]));
   assign t4[5] = (~(t2_b[5] | t2_b[7]));
   assign t4[6] = (~(t2_b[6] | t2_b[8]));

   assign g8_b[1] = (~(g4[1] | (t4[1] & g4[5])));
   assign g8_b[2] = (~(g4[2] | (t4[2] & g4[6])));
   assign g8_b[3] = (~(g4[3] | (t4[3] & g4[7])));		//done
   assign g8_b[4] = (~(g4[4] | (t4[4] & g4[8])));		//done
   assign g8_b[5] = (~(g4[5] | (t4[5] & g4[9])));		//done
   assign g8_b[6] = (~(g4[6] | (t4[6] & g4[10])));		//done
   assign g8_b[7] = (~(g4[7]));
   assign g8_b[8] = (~(g4[8]));
   assign g8_b[9] = (~(g4[9]));
   assign g8_b[10] = (~(g4[10]));
   assign t8_b[1] = (~(t4[1] & t4[5]));
   assign t8_b[2] = (~(t4[2] & t4[6]));

   assign c16[1] = (~(g8_b[1] & (t8_b[1] | g8_b[9])));		//done
   assign c16[2] = (~(g8_b[2] & (t8_b[2] | g8_b[10])));		//done
   assign c16[3] = (~(g8_b[3]));
   assign c16[4] = (~(g8_b[4]));
   assign c16[5] = (~(g8_b[5]));
   assign c16[6] = (~(g8_b[6]));
   assign c16[7] = (~(g8_b[7]));
   assign c16[8] = (~(g8_b[8]));
   assign c16[9] = (~(g8_b[9]));
   assign c16[10] = (~(g8_b[10]));

   //---------------------------------------------
   // final result                             ---
   //---------------------------------------------

   assign s0[0:9] = p1[0:9] ^ c16[1:10];
   assign s0[10] = p1[10];


endmodule




