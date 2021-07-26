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

module fu_alg_or16(
   ex3_sh_lvl2,
   ex3_sticky_or16
);
   input [0:67] ex3_sh_lvl2;
   output [0:4] ex3_sticky_or16;

   // ENTITY


   parameter    tiup = 1'b1;
   parameter    tidn = 1'b0;
   wire [0:7]   ex3_g1o2_b;
   wire [0:7]   ex3_g2o2_b;
   wire [0:7]   ex3_g3o2_b;
   wire [0:7]   ex3_g4o2_b;
   wire [0:3]   ex3_g1o4;
   wire [0:3]   ex3_g2o4;
   wire [0:3]   ex3_g3o4;
   wire [0:3]   ex3_g4o4;
   wire [0:1]   ex3_g0o8_b;
   wire [0:1]   ex3_g1o8_b;
   wire [0:1]   ex3_g2o8_b;
   wire [0:1]   ex3_g3o8_b;
   wire [0:1]   ex3_g4o8_b;
   wire [0:4]   ex3_o16;
   wire [0:4]   ex3_o16_b;


   //----------------------------------------------------------
   // UnMapped original equations
   //----------------------------------------------------------
   //  ex3_sticky_or16(4) <=  OR( ex3_sh_lvl2[52:67] );
   //  ex3_sticky_or16(3) <=  OR( ex3_sh_lvl2[36:51] );
   //  ex3_sticky_or16(2) <=  OR( ex3_sh_lvl2[20:35] );
   //  ex3_sticky_or16(1) <=  OR( ex3_sh_lvl2[ 4:19] );
   //  ex3_sticky_or16(0) <=  OR( ex3_sh_lvl2[ 0: 3] );
   //---------------------------------------------------------
   assign ex3_g1o2_b[0] = (~(ex3_sh_lvl2[4] | ex3_sh_lvl2[5]));
   assign ex3_g1o2_b[1] = (~(ex3_sh_lvl2[6] | ex3_sh_lvl2[7]));
   assign ex3_g1o2_b[2] = (~(ex3_sh_lvl2[8] | ex3_sh_lvl2[9]));
   assign ex3_g1o2_b[3] = (~(ex3_sh_lvl2[10] | ex3_sh_lvl2[11]));
   assign ex3_g1o2_b[4] = (~(ex3_sh_lvl2[12] | ex3_sh_lvl2[13]));
   assign ex3_g1o2_b[5] = (~(ex3_sh_lvl2[14] | ex3_sh_lvl2[15]));
   assign ex3_g1o2_b[6] = (~(ex3_sh_lvl2[16] | ex3_sh_lvl2[17]));
   assign ex3_g1o2_b[7] = (~(ex3_sh_lvl2[18] | ex3_sh_lvl2[19]));

   assign ex3_g2o2_b[0] = (~(ex3_sh_lvl2[20] | ex3_sh_lvl2[21]));
   assign ex3_g2o2_b[1] = (~(ex3_sh_lvl2[22] | ex3_sh_lvl2[23]));
   assign ex3_g2o2_b[2] = (~(ex3_sh_lvl2[24] | ex3_sh_lvl2[25]));
   assign ex3_g2o2_b[3] = (~(ex3_sh_lvl2[26] | ex3_sh_lvl2[27]));
   assign ex3_g2o2_b[4] = (~(ex3_sh_lvl2[28] | ex3_sh_lvl2[29]));
   assign ex3_g2o2_b[5] = (~(ex3_sh_lvl2[30] | ex3_sh_lvl2[31]));
   assign ex3_g2o2_b[6] = (~(ex3_sh_lvl2[32] | ex3_sh_lvl2[33]));
   assign ex3_g2o2_b[7] = (~(ex3_sh_lvl2[34] | ex3_sh_lvl2[35]));

   assign ex3_g3o2_b[0] = (~(ex3_sh_lvl2[36] | ex3_sh_lvl2[37]));
   assign ex3_g3o2_b[1] = (~(ex3_sh_lvl2[38] | ex3_sh_lvl2[39]));
   assign ex3_g3o2_b[2] = (~(ex3_sh_lvl2[40] | ex3_sh_lvl2[41]));
   assign ex3_g3o2_b[3] = (~(ex3_sh_lvl2[42] | ex3_sh_lvl2[43]));
   assign ex3_g3o2_b[4] = (~(ex3_sh_lvl2[44] | ex3_sh_lvl2[45]));
   assign ex3_g3o2_b[5] = (~(ex3_sh_lvl2[46] | ex3_sh_lvl2[47]));
   assign ex3_g3o2_b[6] = (~(ex3_sh_lvl2[48] | ex3_sh_lvl2[49]));
   assign ex3_g3o2_b[7] = (~(ex3_sh_lvl2[50] | ex3_sh_lvl2[51]));

   assign ex3_g4o2_b[0] = (~(ex3_sh_lvl2[52] | ex3_sh_lvl2[53]));
   assign ex3_g4o2_b[1] = (~(ex3_sh_lvl2[54] | ex3_sh_lvl2[55]));
   assign ex3_g4o2_b[2] = (~(ex3_sh_lvl2[56] | ex3_sh_lvl2[57]));
   assign ex3_g4o2_b[3] = (~(ex3_sh_lvl2[58] | ex3_sh_lvl2[59]));
   assign ex3_g4o2_b[4] = (~(ex3_sh_lvl2[60] | ex3_sh_lvl2[61]));
   assign ex3_g4o2_b[5] = (~(ex3_sh_lvl2[62] | ex3_sh_lvl2[63]));
   assign ex3_g4o2_b[6] = (~(ex3_sh_lvl2[64] | ex3_sh_lvl2[65]));
   assign ex3_g4o2_b[7] = (~(ex3_sh_lvl2[66] | ex3_sh_lvl2[67]));

   //------------------------------------------

   assign ex3_g1o4[0] = (~(ex3_g1o2_b[0] & ex3_g1o2_b[1]));
   assign ex3_g1o4[1] = (~(ex3_g1o2_b[2] & ex3_g1o2_b[3]));
   assign ex3_g1o4[2] = (~(ex3_g1o2_b[4] & ex3_g1o2_b[5]));
   assign ex3_g1o4[3] = (~(ex3_g1o2_b[6] & ex3_g1o2_b[7]));

   assign ex3_g2o4[0] = (~(ex3_g2o2_b[0] & ex3_g2o2_b[1]));
   assign ex3_g2o4[1] = (~(ex3_g2o2_b[2] & ex3_g2o2_b[3]));
   assign ex3_g2o4[2] = (~(ex3_g2o2_b[4] & ex3_g2o2_b[5]));
   assign ex3_g2o4[3] = (~(ex3_g2o2_b[6] & ex3_g2o2_b[7]));

   assign ex3_g3o4[0] = (~(ex3_g3o2_b[0] & ex3_g3o2_b[1]));
   assign ex3_g3o4[1] = (~(ex3_g3o2_b[2] & ex3_g3o2_b[3]));
   assign ex3_g3o4[2] = (~(ex3_g3o2_b[4] & ex3_g3o2_b[5]));
   assign ex3_g3o4[3] = (~(ex3_g3o2_b[6] & ex3_g3o2_b[7]));

   assign ex3_g4o4[0] = (~(ex3_g4o2_b[0] & ex3_g4o2_b[1]));
   assign ex3_g4o4[1] = (~(ex3_g4o2_b[2] & ex3_g4o2_b[3]));
   assign ex3_g4o4[2] = (~(ex3_g4o2_b[4] & ex3_g4o2_b[5]));
   assign ex3_g4o4[3] = (~(ex3_g4o2_b[6] & ex3_g4o2_b[7]));

   //---------------------------------------------

   assign ex3_g0o8_b[0] = (~(ex3_sh_lvl2[0] | ex3_sh_lvl2[1]));
   assign ex3_g0o8_b[1] = (~(ex3_sh_lvl2[2] | ex3_sh_lvl2[3]));

   assign ex3_g1o8_b[0] = (~(ex3_g1o4[0] | ex3_g1o4[1]));
   assign ex3_g1o8_b[1] = (~(ex3_g1o4[2] | ex3_g1o4[3]));

   assign ex3_g2o8_b[0] = (~(ex3_g2o4[0] | ex3_g2o4[1]));
   assign ex3_g2o8_b[1] = (~(ex3_g2o4[2] | ex3_g2o4[3]));

   assign ex3_g3o8_b[0] = (~(ex3_g3o4[0] | ex3_g3o4[1]));
   assign ex3_g3o8_b[1] = (~(ex3_g3o4[2] | ex3_g3o4[3]));

   assign ex3_g4o8_b[0] = (~(ex3_g4o4[0] | ex3_g4o4[1]));
   assign ex3_g4o8_b[1] = (~(ex3_g4o4[2] | ex3_g4o4[3]));

   //------------------------------------------------

   assign ex3_o16[0] = (~(ex3_g0o8_b[0] & ex3_g0o8_b[1]));
   assign ex3_o16[1] = (~(ex3_g1o8_b[0] & ex3_g1o8_b[1]));
   assign ex3_o16[2] = (~(ex3_g2o8_b[0] & ex3_g2o8_b[1]));
   assign ex3_o16[3] = (~(ex3_g3o8_b[0] & ex3_g3o8_b[1]));
   assign ex3_o16[4] = (~(ex3_g4o8_b[0] & ex3_g4o8_b[1]));

   //------------------------------------------------

   assign ex3_o16_b[0] = (~(ex3_o16[0]));
   assign ex3_o16_b[1] = (~(ex3_o16[1]));
   assign ex3_o16_b[2] = (~(ex3_o16[2]));
   assign ex3_o16_b[3] = (~(ex3_o16[3]));
   assign ex3_o16_b[4] = (~(ex3_o16[4]));

   //------------------------------------------------

   assign ex3_sticky_or16[0] = (~(ex3_o16_b[0]));
   assign ex3_sticky_or16[1] = (~(ex3_o16_b[1]));
   assign ex3_sticky_or16[2] = (~(ex3_o16_b[2]));
   assign ex3_sticky_or16[3] = (~(ex3_o16_b[3]));
   assign ex3_sticky_or16[4] = (~(ex3_o16_b[4]));


endmodule
