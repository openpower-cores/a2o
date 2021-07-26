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

module fu_alg_sh16(
   ex3_lvl3_shdcd000,
   ex3_lvl3_shdcd016,
   ex3_lvl3_shdcd032,
   ex3_lvl3_shdcd048,
   ex3_lvl3_shdcd064,
   ex3_lvl3_shdcd080,
   ex3_lvl3_shdcd096,
   ex3_lvl3_shdcd112,
   ex3_lvl3_shdcd128,
   ex3_lvl3_shdcd144,
   ex3_lvl3_shdcd160,
   ex3_lvl3_shdcd192,
   ex3_lvl3_shdcd208,
   ex3_lvl3_shdcd224,
   ex3_lvl3_shdcd240,
   ex3_sel_special,
   ex3_sh_lvl2,
   ex3_sh16_162,
   ex3_sh16_163,
   ex3_sh_lvl3
);
   //--------- SHIFT CONTROLS -----------------
   input          ex3_lvl3_shdcd000;
   input          ex3_lvl3_shdcd016;
   input          ex3_lvl3_shdcd032;
   input          ex3_lvl3_shdcd048;
   input          ex3_lvl3_shdcd064;
   input          ex3_lvl3_shdcd080;
   input          ex3_lvl3_shdcd096;
   input          ex3_lvl3_shdcd112;
   input          ex3_lvl3_shdcd128;
   input          ex3_lvl3_shdcd144;
   input          ex3_lvl3_shdcd160;
   input          ex3_lvl3_shdcd192;
   input          ex3_lvl3_shdcd208;
   input          ex3_lvl3_shdcd224;
   input          ex3_lvl3_shdcd240;
   input          ex3_sel_special;

   //--------- SHIFT DATA -----------------
   input [0:67]   ex3_sh_lvl2;

   //-------- SHIFT OUTPUT ---------------
   output         ex3_sh16_162;
   output         ex3_sh16_163;
   output [0:162] ex3_sh_lvl3;

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire [0:162]   ex3_sh16_r1_b;
   wire [0:162]   ex3_sh16_r2_b;
   wire [0:162]   ex3_sh16_r3_b;

   wire [99:162]  ex3_special;

   wire           cpx_spc_b;
   wire           cpx_000_b;
   wire           cpx_016_b;
   wire           cpx_032_b;
   wire           cpx_048_b;
   wire           cpx_064_b;
   wire           cpx_080_b;
   wire           cpx_096_b;
   wire           cpx_112_b;
   wire           cpx_128_b;
   wire           cpx_144_b;
   wire           cpx_160_b;
   wire           cpx_192_b;
   wire           cpx_208_b;
   wire           cpx_224_b;
   wire           cpx_240_b;
   wire           cp1_spc;
   wire           cp1_000;
   wire           cp1_016;
   wire           cp1_032;
   wire           cp1_048;
   wire           cp1_064;
   wire           cp1_080;
   wire           cp1_096;
   wire           cp1_112;
   wire           cp1_128;
   wire           cp1_144;
   wire           cp1_160;
   wire           cp1_192;
   wire           cp1_208;
   wire           cp1_224;
   wire           cp1_240;
   wire           cp2_spc;
   wire           cp2_000;
   wire           cp2_016;
   wire           cp2_032;
   wire           cp2_048;
   wire           cp2_064;
   wire           cp2_080;
   wire           cp2_096;
   wire           cp2_112;
   wire           cp2_128;
   wire           cp2_144;
   wire           cp2_208;
   wire           cp2_224;
   wire           cp2_240;
   wire           cp3_spc;
   wire           cp3_000;
   wire           cp3_016;
   wire           cp3_032;
   wire           cp3_048;
   wire           cp3_064;
   wire           cp3_080;
   wire           cp3_096;
   wire           cp3_112;
   wire           cp3_128;
   wire           cp3_224;
   wire           cp3_240;
   wire           cp4_spc;
   wire           cp4_000;
   wire           cp4_016;
   wire           cp4_032;
   wire           cp4_048;
   wire           cp4_064;
   wire           cp4_080;
   wire           cp4_096;
   wire           cp4_112;
   wire           cp4_240;
   wire           cp5_spc;
   wire           cp5_000;
   wire           cp5_016;
   wire           cp5_032;
   wire           cp5_048;
   wire           cp5_064;
   wire           cp5_080;
   wire           cp5_096;
   wire           ex3_sh16_r1_162_b;
   wire           ex3_sh16_r2_162_b;
   wire           ex3_sh16_r3_162_b;
   wire           ex3_sh16_r1_163_b;
   wire           ex3_sh16_r2_163_b;
   wire           ex3_sh16_r3_163_b;


////################################################################
////# map block attributes
////################################################################

////#-------------------------------------------------
////# finish shifting
////#-------------------------------------------------
// this looks more like a 53:1 mux than a shifter to shrink it, and lower load on selects
// real implementation should be nand/nand/nor ... ?? integrate nor into latch ??

   assign ex3_special[99:162] = ex3_sh_lvl2[0:63];		// just a rename

   ////#-----------------------------------------------------------------
   ////# repower select signal
   ////#-----------------------------------------------------------------


   assign cpx_spc_b = (~ex3_sel_special);
   assign cpx_000_b = (~ex3_lvl3_shdcd000);
   assign cpx_016_b = (~ex3_lvl3_shdcd016);
   assign cpx_032_b = (~ex3_lvl3_shdcd032);
   assign cpx_048_b = (~ex3_lvl3_shdcd048);
   assign cpx_064_b = (~ex3_lvl3_shdcd064);
   assign cpx_080_b = (~ex3_lvl3_shdcd080);
   assign cpx_096_b = (~ex3_lvl3_shdcd096);
   assign cpx_112_b = (~ex3_lvl3_shdcd112);
   assign cpx_128_b = (~ex3_lvl3_shdcd128);
   assign cpx_144_b = (~ex3_lvl3_shdcd144);
   assign cpx_160_b = (~ex3_lvl3_shdcd160);
   assign cpx_192_b = (~ex3_lvl3_shdcd192);
   assign cpx_208_b = (~ex3_lvl3_shdcd208);
   assign cpx_224_b = (~ex3_lvl3_shdcd224);
   assign cpx_240_b = (~ex3_lvl3_shdcd240);

   assign cp1_spc = (~cpx_spc_b);
   assign cp1_000 = (~cpx_000_b);
   assign cp1_016 = (~cpx_016_b);
   assign cp1_032 = (~cpx_032_b);
   assign cp1_048 = (~cpx_048_b);
   assign cp1_064 = (~cpx_064_b);
   assign cp1_080 = (~cpx_080_b);
   assign cp1_096 = (~cpx_096_b);
   assign cp1_112 = (~cpx_112_b);
   assign cp1_128 = (~cpx_128_b);
   assign cp1_144 = (~cpx_144_b);
   assign cp1_160 = (~cpx_160_b);
   assign cp1_192 = (~cpx_192_b);
   assign cp1_208 = (~cpx_208_b);
   assign cp1_224 = (~cpx_224_b);
   assign cp1_240 = (~cpx_240_b);

   assign cp2_spc = (~cpx_spc_b);
   assign cp2_000 = (~cpx_000_b);
   assign cp2_016 = (~cpx_016_b);
   assign cp2_032 = (~cpx_032_b);
   assign cp2_048 = (~cpx_048_b);
   assign cp2_064 = (~cpx_064_b);
   assign cp2_080 = (~cpx_080_b);
   assign cp2_096 = (~cpx_096_b);
   assign cp2_112 = (~cpx_112_b);
   assign cp2_128 = (~cpx_128_b);
   assign cp2_144 = (~cpx_144_b);
   assign cp2_208 = (~cpx_208_b);
   assign cp2_224 = (~cpx_224_b);
   assign cp2_240 = (~cpx_240_b);

   assign cp3_spc = (~cpx_spc_b);
   assign cp3_000 = (~cpx_000_b);
   assign cp3_016 = (~cpx_016_b);
   assign cp3_032 = (~cpx_032_b);
   assign cp3_048 = (~cpx_048_b);
   assign cp3_064 = (~cpx_064_b);
   assign cp3_080 = (~cpx_080_b);
   assign cp3_096 = (~cpx_096_b);
   assign cp3_112 = (~cpx_112_b);
   assign cp3_128 = (~cpx_128_b);
   assign cp3_224 = (~cpx_224_b);
   assign cp3_240 = (~cpx_240_b);

   assign cp4_spc = (~cpx_spc_b);
   assign cp4_000 = (~cpx_000_b);
   assign cp4_016 = (~cpx_016_b);
   assign cp4_032 = (~cpx_032_b);
   assign cp4_048 = (~cpx_048_b);
   assign cp4_064 = (~cpx_064_b);
   assign cp4_080 = (~cpx_080_b);
   assign cp4_096 = (~cpx_096_b);
   assign cp4_112 = (~cpx_112_b);
   assign cp4_240 = (~cpx_240_b);

   assign cp5_spc = (~cpx_spc_b);
   assign cp5_000 = (~cpx_000_b);
   assign cp5_016 = (~cpx_016_b);
   assign cp5_032 = (~cpx_032_b);
   assign cp5_048 = (~cpx_048_b);
   assign cp5_064 = (~cpx_064_b);
   assign cp5_080 = (~cpx_080_b);
   assign cp5_096 = (~cpx_096_b);

   //-------------------------------------------------------------------

   assign ex3_sh16_r1_b[0] = (~((cp1_192 & ex3_sh_lvl2[64]) | (cp1_208 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[1] = (~((cp1_192 & ex3_sh_lvl2[65]) | (cp1_208 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[2] = (~((cp1_192 & ex3_sh_lvl2[66]) | (cp1_208 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[3] = (~((cp1_192 & ex3_sh_lvl2[67]) | (cp1_208 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[4] = (~(cp1_208 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[5] = (~(cp1_208 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[6] = (~(cp1_208 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[7] = (~(cp1_208 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[8] = (~(cp1_208 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[9] = (~(cp1_208 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[10] = (~(cp1_208 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[11] = (~(cp1_208 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[12] = (~(cp1_208 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[13] = (~(cp1_208 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[14] = (~(cp1_208 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[15] = (~(cp1_208 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[16] = (~((cp2_208 & ex3_sh_lvl2[64]) | (cp2_224 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[17] = (~((cp2_208 & ex3_sh_lvl2[65]) | (cp2_224 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[18] = (~((cp2_208 & ex3_sh_lvl2[66]) | (cp2_224 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[19] = (~((cp2_208 & ex3_sh_lvl2[67]) | (cp2_224 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[20] = (~(cp2_224 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[21] = (~(cp2_224 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[22] = (~(cp2_224 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[23] = (~(cp2_224 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[24] = (~(cp2_224 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[25] = (~(cp2_224 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[26] = (~(cp2_224 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[27] = (~(cp2_224 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[28] = (~(cp2_224 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[29] = (~(cp2_224 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[30] = (~(cp2_224 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[31] = (~(cp2_224 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[32] = (~((cp3_224 & ex3_sh_lvl2[64]) | (cp3_240 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[33] = (~((cp3_224 & ex3_sh_lvl2[65]) | (cp3_240 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[34] = (~((cp3_224 & ex3_sh_lvl2[66]) | (cp3_240 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[35] = (~((cp3_224 & ex3_sh_lvl2[67]) | (cp3_240 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[36] = (~(cp3_240 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[37] = (~(cp3_240 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[38] = (~(cp3_240 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[39] = (~(cp3_240 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[40] = (~(cp3_240 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[41] = (~(cp3_240 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[42] = (~(cp3_240 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[43] = (~(cp3_240 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[44] = (~(cp3_240 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[45] = (~(cp3_240 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[46] = (~(cp3_240 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[47] = (~(cp3_240 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[48] = (~((cp4_240 & ex3_sh_lvl2[64]) | (cp4_000 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[49] = (~((cp4_240 & ex3_sh_lvl2[65]) | (cp4_000 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[50] = (~((cp4_240 & ex3_sh_lvl2[66]) | (cp4_000 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[51] = (~((cp4_240 & ex3_sh_lvl2[67]) | (cp4_000 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[52] = (~(cp4_000 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[53] = (~(cp4_000 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[54] = (~(cp4_000 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[55] = (~(cp4_000 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[56] = (~(cp4_000 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[57] = (~(cp4_000 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[58] = (~(cp4_000 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[59] = (~(cp4_000 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[60] = (~(cp4_000 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[61] = (~(cp4_000 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[62] = (~(cp4_000 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[63] = (~(cp4_000 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[64] = (~((cp5_000 & ex3_sh_lvl2[64]) | (cp4_016 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[65] = (~((cp5_000 & ex3_sh_lvl2[65]) | (cp4_016 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[66] = (~((cp5_000 & ex3_sh_lvl2[66]) | (cp4_016 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[67] = (~((cp5_000 & ex3_sh_lvl2[67]) | (cp4_016 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[68] = (~(cp4_016 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[69] = (~(cp4_016 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[70] = (~(cp4_016 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[71] = (~(cp4_016 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[72] = (~(cp4_016 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[73] = (~(cp4_016 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[74] = (~(cp4_016 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[75] = (~(cp4_016 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[76] = (~(cp4_016 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[77] = (~(cp4_016 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[78] = (~(cp4_016 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[79] = (~(cp4_016 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[80] = (~((cp5_016 & ex3_sh_lvl2[64]) | (cp4_032 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[81] = (~((cp5_016 & ex3_sh_lvl2[65]) | (cp4_032 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[82] = (~((cp5_016 & ex3_sh_lvl2[66]) | (cp4_032 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[83] = (~((cp5_016 & ex3_sh_lvl2[67]) | (cp4_032 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[84] = (~(cp4_032 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[85] = (~(cp4_032 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[86] = (~(cp4_032 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[87] = (~(cp4_032 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[88] = (~(cp4_032 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[89] = (~(cp4_032 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[90] = (~(cp4_032 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[91] = (~(cp4_032 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[92] = (~(cp4_032 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[93] = (~(cp4_032 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[94] = (~(cp4_032 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[95] = (~(cp4_032 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[96] = (~((cp5_032 & ex3_sh_lvl2[64]) | (cp4_048 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[97] = (~((cp5_032 & ex3_sh_lvl2[65]) | (cp4_048 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[98] = (~((cp5_032 & ex3_sh_lvl2[66]) | (cp4_048 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[99] = (~((cp5_032 & ex3_sh_lvl2[67]) | (cp4_048 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[100] = (~(cp4_048 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[101] = (~(cp4_048 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[102] = (~(cp4_048 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[103] = (~(cp4_048 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[104] = (~(cp4_048 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[105] = (~(cp4_048 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[106] = (~(cp4_048 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[107] = (~(cp4_048 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[108] = (~(cp4_048 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[109] = (~(cp4_048 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[110] = (~(cp4_048 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[111] = (~(cp4_048 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[112] = (~((cp5_048 & ex3_sh_lvl2[64]) | (cp4_064 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[113] = (~((cp5_048 & ex3_sh_lvl2[65]) | (cp4_064 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[114] = (~((cp5_048 & ex3_sh_lvl2[66]) | (cp4_064 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[115] = (~((cp5_048 & ex3_sh_lvl2[67]) | (cp4_064 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[116] = (~(cp4_064 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[117] = (~(cp4_064 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[118] = (~(cp4_064 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[119] = (~(cp4_064 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[120] = (~(cp4_064 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[121] = (~(cp4_064 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[122] = (~(cp4_064 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[123] = (~(cp4_064 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[124] = (~(cp4_064 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[125] = (~(cp4_064 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[126] = (~(cp4_064 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[127] = (~(cp4_064 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[128] = (~((cp5_064 & ex3_sh_lvl2[64]) | (cp4_080 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[129] = (~((cp5_064 & ex3_sh_lvl2[65]) | (cp4_080 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[130] = (~((cp5_064 & ex3_sh_lvl2[66]) | (cp4_080 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[131] = (~((cp5_064 & ex3_sh_lvl2[67]) | (cp4_080 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[132] = (~(cp4_080 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[133] = (~(cp4_080 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[134] = (~(cp4_080 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[135] = (~(cp4_080 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[136] = (~(cp4_080 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[137] = (~(cp4_080 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[138] = (~(cp4_080 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[139] = (~(cp4_080 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[140] = (~(cp4_080 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[141] = (~(cp4_080 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[142] = (~(cp4_080 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[143] = (~(cp4_080 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[144] = (~((cp5_080 & ex3_sh_lvl2[64]) | (cp4_096 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[145] = (~((cp5_080 & ex3_sh_lvl2[65]) | (cp4_096 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[146] = (~((cp5_080 & ex3_sh_lvl2[66]) | (cp4_096 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_b[147] = (~((cp5_080 & ex3_sh_lvl2[67]) | (cp4_096 & ex3_sh_lvl2[51])));
   assign ex3_sh16_r1_b[148] = (~(cp4_096 & ex3_sh_lvl2[52]));
   assign ex3_sh16_r1_b[149] = (~(cp4_096 & ex3_sh_lvl2[53]));
   assign ex3_sh16_r1_b[150] = (~(cp4_096 & ex3_sh_lvl2[54]));
   assign ex3_sh16_r1_b[151] = (~(cp4_096 & ex3_sh_lvl2[55]));
   assign ex3_sh16_r1_b[152] = (~(cp4_096 & ex3_sh_lvl2[56]));
   assign ex3_sh16_r1_b[153] = (~(cp4_096 & ex3_sh_lvl2[57]));
   assign ex3_sh16_r1_b[154] = (~(cp4_096 & ex3_sh_lvl2[58]));
   assign ex3_sh16_r1_b[155] = (~(cp4_096 & ex3_sh_lvl2[59]));
   assign ex3_sh16_r1_b[156] = (~(cp4_096 & ex3_sh_lvl2[60]));
   assign ex3_sh16_r1_b[157] = (~(cp4_096 & ex3_sh_lvl2[61]));
   assign ex3_sh16_r1_b[158] = (~(cp4_096 & ex3_sh_lvl2[62]));
   assign ex3_sh16_r1_b[159] = (~(cp4_096 & ex3_sh_lvl2[63]));

   assign ex3_sh16_r1_b[160] = (~((cp5_096 & ex3_sh_lvl2[64]) | (cp4_112 & ex3_sh_lvl2[48])));
   assign ex3_sh16_r1_b[161] = (~((cp5_096 & ex3_sh_lvl2[65]) | (cp4_112 & ex3_sh_lvl2[49])));
   assign ex3_sh16_r1_b[162] = (~((cp5_096 & ex3_sh_lvl2[66]) | (cp4_112 & ex3_sh_lvl2[50])));

   assign ex3_sh16_r2_b[0] = (~((cp1_224 & ex3_sh_lvl2[32]) | (cp1_240 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[1] = (~((cp1_224 & ex3_sh_lvl2[33]) | (cp1_240 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[2] = (~((cp1_224 & ex3_sh_lvl2[34]) | (cp1_240 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[3] = (~((cp1_224 & ex3_sh_lvl2[35]) | (cp1_240 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[4] = (~((cp1_224 & ex3_sh_lvl2[36]) | (cp1_240 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[5] = (~((cp1_224 & ex3_sh_lvl2[37]) | (cp1_240 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[6] = (~((cp1_224 & ex3_sh_lvl2[38]) | (cp1_240 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[7] = (~((cp1_224 & ex3_sh_lvl2[39]) | (cp1_240 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[8] = (~((cp1_224 & ex3_sh_lvl2[40]) | (cp1_240 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[9] = (~((cp1_224 & ex3_sh_lvl2[41]) | (cp1_240 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[10] = (~((cp1_224 & ex3_sh_lvl2[42]) | (cp1_240 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[11] = (~((cp1_224 & ex3_sh_lvl2[43]) | (cp1_240 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[12] = (~((cp1_224 & ex3_sh_lvl2[44]) | (cp1_240 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[13] = (~((cp1_224 & ex3_sh_lvl2[45]) | (cp1_240 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[14] = (~((cp1_224 & ex3_sh_lvl2[46]) | (cp1_240 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[15] = (~((cp1_224 & ex3_sh_lvl2[47]) | (cp1_240 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[16] = (~((cp2_240 & ex3_sh_lvl2[32]) | (cp2_000 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[17] = (~((cp2_240 & ex3_sh_lvl2[33]) | (cp2_000 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[18] = (~((cp2_240 & ex3_sh_lvl2[34]) | (cp2_000 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[19] = (~((cp2_240 & ex3_sh_lvl2[35]) | (cp2_000 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[20] = (~((cp2_240 & ex3_sh_lvl2[36]) | (cp2_000 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[21] = (~((cp2_240 & ex3_sh_lvl2[37]) | (cp2_000 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[22] = (~((cp2_240 & ex3_sh_lvl2[38]) | (cp2_000 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[23] = (~((cp2_240 & ex3_sh_lvl2[39]) | (cp2_000 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[24] = (~((cp2_240 & ex3_sh_lvl2[40]) | (cp2_000 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[25] = (~((cp2_240 & ex3_sh_lvl2[41]) | (cp2_000 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[26] = (~((cp2_240 & ex3_sh_lvl2[42]) | (cp2_000 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[27] = (~((cp2_240 & ex3_sh_lvl2[43]) | (cp2_000 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[28] = (~((cp2_240 & ex3_sh_lvl2[44]) | (cp2_000 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[29] = (~((cp2_240 & ex3_sh_lvl2[45]) | (cp2_000 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[30] = (~((cp2_240 & ex3_sh_lvl2[46]) | (cp2_000 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[31] = (~((cp2_240 & ex3_sh_lvl2[47]) | (cp2_000 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[32] = (~((cp3_000 & ex3_sh_lvl2[32]) | (cp2_016 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[33] = (~((cp3_000 & ex3_sh_lvl2[33]) | (cp2_016 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[34] = (~((cp3_000 & ex3_sh_lvl2[34]) | (cp2_016 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[35] = (~((cp3_000 & ex3_sh_lvl2[35]) | (cp2_016 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[36] = (~((cp3_000 & ex3_sh_lvl2[36]) | (cp2_016 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[37] = (~((cp3_000 & ex3_sh_lvl2[37]) | (cp2_016 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[38] = (~((cp3_000 & ex3_sh_lvl2[38]) | (cp2_016 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[39] = (~((cp3_000 & ex3_sh_lvl2[39]) | (cp2_016 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[40] = (~((cp3_000 & ex3_sh_lvl2[40]) | (cp2_016 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[41] = (~((cp3_000 & ex3_sh_lvl2[41]) | (cp2_016 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[42] = (~((cp3_000 & ex3_sh_lvl2[42]) | (cp2_016 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[43] = (~((cp3_000 & ex3_sh_lvl2[43]) | (cp2_016 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[44] = (~((cp3_000 & ex3_sh_lvl2[44]) | (cp2_016 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[45] = (~((cp3_000 & ex3_sh_lvl2[45]) | (cp2_016 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[46] = (~((cp3_000 & ex3_sh_lvl2[46]) | (cp2_016 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[47] = (~((cp3_000 & ex3_sh_lvl2[47]) | (cp2_016 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[48] = (~((cp3_016 & ex3_sh_lvl2[32]) | (cp2_032 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[49] = (~((cp3_016 & ex3_sh_lvl2[33]) | (cp2_032 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[50] = (~((cp3_016 & ex3_sh_lvl2[34]) | (cp2_032 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[51] = (~((cp3_016 & ex3_sh_lvl2[35]) | (cp2_032 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[52] = (~((cp3_016 & ex3_sh_lvl2[36]) | (cp2_032 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[53] = (~((cp3_016 & ex3_sh_lvl2[37]) | (cp2_032 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[54] = (~((cp3_016 & ex3_sh_lvl2[38]) | (cp2_032 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[55] = (~((cp3_016 & ex3_sh_lvl2[39]) | (cp2_032 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[56] = (~((cp3_016 & ex3_sh_lvl2[40]) | (cp2_032 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[57] = (~((cp3_016 & ex3_sh_lvl2[41]) | (cp2_032 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[58] = (~((cp3_016 & ex3_sh_lvl2[42]) | (cp2_032 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[59] = (~((cp3_016 & ex3_sh_lvl2[43]) | (cp2_032 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[60] = (~((cp3_016 & ex3_sh_lvl2[44]) | (cp2_032 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[61] = (~((cp3_016 & ex3_sh_lvl2[45]) | (cp2_032 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[62] = (~((cp3_016 & ex3_sh_lvl2[46]) | (cp2_032 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[63] = (~((cp3_016 & ex3_sh_lvl2[47]) | (cp2_032 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[64] = (~((cp3_032 & ex3_sh_lvl2[32]) | (cp2_048 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[65] = (~((cp3_032 & ex3_sh_lvl2[33]) | (cp2_048 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[66] = (~((cp3_032 & ex3_sh_lvl2[34]) | (cp2_048 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[67] = (~((cp3_032 & ex3_sh_lvl2[35]) | (cp2_048 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[68] = (~((cp3_032 & ex3_sh_lvl2[36]) | (cp2_048 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[69] = (~((cp3_032 & ex3_sh_lvl2[37]) | (cp2_048 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[70] = (~((cp3_032 & ex3_sh_lvl2[38]) | (cp2_048 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[71] = (~((cp3_032 & ex3_sh_lvl2[39]) | (cp2_048 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[72] = (~((cp3_032 & ex3_sh_lvl2[40]) | (cp2_048 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[73] = (~((cp3_032 & ex3_sh_lvl2[41]) | (cp2_048 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[74] = (~((cp3_032 & ex3_sh_lvl2[42]) | (cp2_048 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[75] = (~((cp3_032 & ex3_sh_lvl2[43]) | (cp2_048 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[76] = (~((cp3_032 & ex3_sh_lvl2[44]) | (cp2_048 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[77] = (~((cp3_032 & ex3_sh_lvl2[45]) | (cp2_048 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[78] = (~((cp3_032 & ex3_sh_lvl2[46]) | (cp2_048 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[79] = (~((cp3_032 & ex3_sh_lvl2[47]) | (cp2_048 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[80] = (~((cp3_048 & ex3_sh_lvl2[32]) | (cp2_064 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[81] = (~((cp3_048 & ex3_sh_lvl2[33]) | (cp2_064 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[82] = (~((cp3_048 & ex3_sh_lvl2[34]) | (cp2_064 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[83] = (~((cp3_048 & ex3_sh_lvl2[35]) | (cp2_064 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[84] = (~((cp3_048 & ex3_sh_lvl2[36]) | (cp2_064 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[85] = (~((cp3_048 & ex3_sh_lvl2[37]) | (cp2_064 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[86] = (~((cp3_048 & ex3_sh_lvl2[38]) | (cp2_064 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[87] = (~((cp3_048 & ex3_sh_lvl2[39]) | (cp2_064 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[88] = (~((cp3_048 & ex3_sh_lvl2[40]) | (cp2_064 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[89] = (~((cp3_048 & ex3_sh_lvl2[41]) | (cp2_064 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[90] = (~((cp3_048 & ex3_sh_lvl2[42]) | (cp2_064 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[91] = (~((cp3_048 & ex3_sh_lvl2[43]) | (cp2_064 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[92] = (~((cp3_048 & ex3_sh_lvl2[44]) | (cp2_064 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[93] = (~((cp3_048 & ex3_sh_lvl2[45]) | (cp2_064 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[94] = (~((cp3_048 & ex3_sh_lvl2[46]) | (cp2_064 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[95] = (~((cp3_048 & ex3_sh_lvl2[47]) | (cp2_064 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[96] = (~((cp3_064 & ex3_sh_lvl2[32]) | (cp2_080 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[97] = (~((cp3_064 & ex3_sh_lvl2[33]) | (cp2_080 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[98] = (~((cp3_064 & ex3_sh_lvl2[34]) | (cp2_080 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[99] = (~((cp3_064 & ex3_sh_lvl2[35]) | (cp2_080 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[100] = (~((cp3_064 & ex3_sh_lvl2[36]) | (cp2_080 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[101] = (~((cp3_064 & ex3_sh_lvl2[37]) | (cp2_080 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[102] = (~((cp3_064 & ex3_sh_lvl2[38]) | (cp2_080 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[103] = (~((cp3_064 & ex3_sh_lvl2[39]) | (cp2_080 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[104] = (~((cp3_064 & ex3_sh_lvl2[40]) | (cp2_080 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[105] = (~((cp3_064 & ex3_sh_lvl2[41]) | (cp2_080 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[106] = (~((cp3_064 & ex3_sh_lvl2[42]) | (cp2_080 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[107] = (~((cp3_064 & ex3_sh_lvl2[43]) | (cp2_080 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[108] = (~((cp3_064 & ex3_sh_lvl2[44]) | (cp2_080 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[109] = (~((cp3_064 & ex3_sh_lvl2[45]) | (cp2_080 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[110] = (~((cp3_064 & ex3_sh_lvl2[46]) | (cp2_080 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[111] = (~((cp3_064 & ex3_sh_lvl2[47]) | (cp2_080 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[112] = (~((cp3_080 & ex3_sh_lvl2[32]) | (cp2_096 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[113] = (~((cp3_080 & ex3_sh_lvl2[33]) | (cp2_096 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[114] = (~((cp3_080 & ex3_sh_lvl2[34]) | (cp2_096 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[115] = (~((cp3_080 & ex3_sh_lvl2[35]) | (cp2_096 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[116] = (~((cp3_080 & ex3_sh_lvl2[36]) | (cp2_096 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[117] = (~((cp3_080 & ex3_sh_lvl2[37]) | (cp2_096 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[118] = (~((cp3_080 & ex3_sh_lvl2[38]) | (cp2_096 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[119] = (~((cp3_080 & ex3_sh_lvl2[39]) | (cp2_096 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[120] = (~((cp3_080 & ex3_sh_lvl2[40]) | (cp2_096 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[121] = (~((cp3_080 & ex3_sh_lvl2[41]) | (cp2_096 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[122] = (~((cp3_080 & ex3_sh_lvl2[42]) | (cp2_096 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[123] = (~((cp3_080 & ex3_sh_lvl2[43]) | (cp2_096 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[124] = (~((cp3_080 & ex3_sh_lvl2[44]) | (cp2_096 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[125] = (~((cp3_080 & ex3_sh_lvl2[45]) | (cp2_096 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[126] = (~((cp3_080 & ex3_sh_lvl2[46]) | (cp2_096 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[127] = (~((cp3_080 & ex3_sh_lvl2[47]) | (cp2_096 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[128] = (~((cp3_096 & ex3_sh_lvl2[32]) | (cp2_112 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[129] = (~((cp3_096 & ex3_sh_lvl2[33]) | (cp2_112 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[130] = (~((cp3_096 & ex3_sh_lvl2[34]) | (cp2_112 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[131] = (~((cp3_096 & ex3_sh_lvl2[35]) | (cp2_112 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[132] = (~((cp3_096 & ex3_sh_lvl2[36]) | (cp2_112 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[133] = (~((cp3_096 & ex3_sh_lvl2[37]) | (cp2_112 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[134] = (~((cp3_096 & ex3_sh_lvl2[38]) | (cp2_112 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[135] = (~((cp3_096 & ex3_sh_lvl2[39]) | (cp2_112 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[136] = (~((cp3_096 & ex3_sh_lvl2[40]) | (cp2_112 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[137] = (~((cp3_096 & ex3_sh_lvl2[41]) | (cp2_112 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[138] = (~((cp3_096 & ex3_sh_lvl2[42]) | (cp2_112 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[139] = (~((cp3_096 & ex3_sh_lvl2[43]) | (cp2_112 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[140] = (~((cp3_096 & ex3_sh_lvl2[44]) | (cp2_112 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[141] = (~((cp3_096 & ex3_sh_lvl2[45]) | (cp2_112 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[142] = (~((cp3_096 & ex3_sh_lvl2[46]) | (cp2_112 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[143] = (~((cp3_096 & ex3_sh_lvl2[47]) | (cp2_112 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[144] = (~((cp3_112 & ex3_sh_lvl2[32]) | (cp2_128 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[145] = (~((cp3_112 & ex3_sh_lvl2[33]) | (cp2_128 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[146] = (~((cp3_112 & ex3_sh_lvl2[34]) | (cp2_128 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_b[147] = (~((cp3_112 & ex3_sh_lvl2[35]) | (cp2_128 & ex3_sh_lvl2[19])));
   assign ex3_sh16_r2_b[148] = (~((cp3_112 & ex3_sh_lvl2[36]) | (cp2_128 & ex3_sh_lvl2[20])));
   assign ex3_sh16_r2_b[149] = (~((cp3_112 & ex3_sh_lvl2[37]) | (cp2_128 & ex3_sh_lvl2[21])));
   assign ex3_sh16_r2_b[150] = (~((cp3_112 & ex3_sh_lvl2[38]) | (cp2_128 & ex3_sh_lvl2[22])));
   assign ex3_sh16_r2_b[151] = (~((cp3_112 & ex3_sh_lvl2[39]) | (cp2_128 & ex3_sh_lvl2[23])));
   assign ex3_sh16_r2_b[152] = (~((cp3_112 & ex3_sh_lvl2[40]) | (cp2_128 & ex3_sh_lvl2[24])));
   assign ex3_sh16_r2_b[153] = (~((cp3_112 & ex3_sh_lvl2[41]) | (cp2_128 & ex3_sh_lvl2[25])));
   assign ex3_sh16_r2_b[154] = (~((cp3_112 & ex3_sh_lvl2[42]) | (cp2_128 & ex3_sh_lvl2[26])));
   assign ex3_sh16_r2_b[155] = (~((cp3_112 & ex3_sh_lvl2[43]) | (cp2_128 & ex3_sh_lvl2[27])));
   assign ex3_sh16_r2_b[156] = (~((cp3_112 & ex3_sh_lvl2[44]) | (cp2_128 & ex3_sh_lvl2[28])));
   assign ex3_sh16_r2_b[157] = (~((cp3_112 & ex3_sh_lvl2[45]) | (cp2_128 & ex3_sh_lvl2[29])));
   assign ex3_sh16_r2_b[158] = (~((cp3_112 & ex3_sh_lvl2[46]) | (cp2_128 & ex3_sh_lvl2[30])));
   assign ex3_sh16_r2_b[159] = (~((cp3_112 & ex3_sh_lvl2[47]) | (cp2_128 & ex3_sh_lvl2[31])));

   assign ex3_sh16_r2_b[160] = (~((cp3_128 & ex3_sh_lvl2[32]) | (cp2_144 & ex3_sh_lvl2[16])));
   assign ex3_sh16_r2_b[161] = (~((cp3_128 & ex3_sh_lvl2[33]) | (cp2_144 & ex3_sh_lvl2[17])));
   assign ex3_sh16_r2_b[162] = (~((cp3_128 & ex3_sh_lvl2[34]) | (cp2_144 & ex3_sh_lvl2[18])));

   assign ex3_sh16_r3_b[0] = (~(cp1_000 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[1] = (~(cp1_000 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[2] = (~(cp1_000 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[3] = (~(cp1_000 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[4] = (~(cp1_000 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[5] = (~(cp1_000 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[6] = (~(cp1_000 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[7] = (~(cp1_000 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[8] = (~(cp1_000 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[9] = (~(cp1_000 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[10] = (~(cp1_000 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[11] = (~(cp1_000 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[12] = (~(cp1_000 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[13] = (~(cp1_000 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[14] = (~(cp1_000 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[15] = (~(cp1_000 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[16] = (~(cp1_016 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[17] = (~(cp1_016 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[18] = (~(cp1_016 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[19] = (~(cp1_016 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[20] = (~(cp1_016 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[21] = (~(cp1_016 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[22] = (~(cp1_016 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[23] = (~(cp1_016 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[24] = (~(cp1_016 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[25] = (~(cp1_016 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[26] = (~(cp1_016 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[27] = (~(cp1_016 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[28] = (~(cp1_016 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[29] = (~(cp1_016 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[30] = (~(cp1_016 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[31] = (~(cp1_016 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[32] = (~(cp1_032 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[33] = (~(cp1_032 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[34] = (~(cp1_032 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[35] = (~(cp1_032 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[36] = (~(cp1_032 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[37] = (~(cp1_032 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[38] = (~(cp1_032 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[39] = (~(cp1_032 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[40] = (~(cp1_032 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[41] = (~(cp1_032 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[42] = (~(cp1_032 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[43] = (~(cp1_032 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[44] = (~(cp1_032 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[45] = (~(cp1_032 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[46] = (~(cp1_032 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[47] = (~(cp1_032 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[48] = (~(cp1_048 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[49] = (~(cp1_048 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[50] = (~(cp1_048 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[51] = (~(cp1_048 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[52] = (~(cp1_048 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[53] = (~(cp1_048 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[54] = (~(cp1_048 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[55] = (~(cp1_048 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[56] = (~(cp1_048 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[57] = (~(cp1_048 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[58] = (~(cp1_048 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[59] = (~(cp1_048 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[60] = (~(cp1_048 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[61] = (~(cp1_048 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[62] = (~(cp1_048 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[63] = (~(cp1_048 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[64] = (~(cp1_064 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[65] = (~(cp1_064 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[66] = (~(cp1_064 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[67] = (~(cp1_064 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[68] = (~(cp1_064 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[69] = (~(cp1_064 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[70] = (~(cp1_064 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[71] = (~(cp1_064 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[72] = (~(cp1_064 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[73] = (~(cp1_064 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[74] = (~(cp1_064 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[75] = (~(cp1_064 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[76] = (~(cp1_064 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[77] = (~(cp1_064 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[78] = (~(cp1_064 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[79] = (~(cp1_064 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[80] = (~(cp1_080 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[81] = (~(cp1_080 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[82] = (~(cp1_080 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[83] = (~(cp1_080 & ex3_sh_lvl2[3]));
   assign ex3_sh16_r3_b[84] = (~(cp1_080 & ex3_sh_lvl2[4]));
   assign ex3_sh16_r3_b[85] = (~(cp1_080 & ex3_sh_lvl2[5]));
   assign ex3_sh16_r3_b[86] = (~(cp1_080 & ex3_sh_lvl2[6]));
   assign ex3_sh16_r3_b[87] = (~(cp1_080 & ex3_sh_lvl2[7]));
   assign ex3_sh16_r3_b[88] = (~(cp1_080 & ex3_sh_lvl2[8]));
   assign ex3_sh16_r3_b[89] = (~(cp1_080 & ex3_sh_lvl2[9]));
   assign ex3_sh16_r3_b[90] = (~(cp1_080 & ex3_sh_lvl2[10]));
   assign ex3_sh16_r3_b[91] = (~(cp1_080 & ex3_sh_lvl2[11]));
   assign ex3_sh16_r3_b[92] = (~(cp1_080 & ex3_sh_lvl2[12]));
   assign ex3_sh16_r3_b[93] = (~(cp1_080 & ex3_sh_lvl2[13]));
   assign ex3_sh16_r3_b[94] = (~(cp1_080 & ex3_sh_lvl2[14]));
   assign ex3_sh16_r3_b[95] = (~(cp1_080 & ex3_sh_lvl2[15]));

   assign ex3_sh16_r3_b[96] = (~(cp1_096 & ex3_sh_lvl2[0]));
   assign ex3_sh16_r3_b[97] = (~(cp1_096 & ex3_sh_lvl2[1]));
   assign ex3_sh16_r3_b[98] = (~(cp1_096 & ex3_sh_lvl2[2]));
   assign ex3_sh16_r3_b[99] = (~((cp1_096 & ex3_sh_lvl2[3]) | (cp1_spc & ex3_special[99])));
   assign ex3_sh16_r3_b[100] = (~((cp1_096 & ex3_sh_lvl2[4]) | (cp1_spc & ex3_special[100])));
   assign ex3_sh16_r3_b[101] = (~((cp1_096 & ex3_sh_lvl2[5]) | (cp1_spc & ex3_special[101])));
   assign ex3_sh16_r3_b[102] = (~((cp1_096 & ex3_sh_lvl2[6]) | (cp1_spc & ex3_special[102])));
   assign ex3_sh16_r3_b[103] = (~((cp1_096 & ex3_sh_lvl2[7]) | (cp1_spc & ex3_special[103])));
   assign ex3_sh16_r3_b[104] = (~((cp1_096 & ex3_sh_lvl2[8]) | (cp1_spc & ex3_special[104])));
   assign ex3_sh16_r3_b[105] = (~((cp1_096 & ex3_sh_lvl2[9]) | (cp1_spc & ex3_special[105])));
   assign ex3_sh16_r3_b[106] = (~((cp1_096 & ex3_sh_lvl2[10]) | (cp1_spc & ex3_special[106])));
   assign ex3_sh16_r3_b[107] = (~((cp1_096 & ex3_sh_lvl2[11]) | (cp1_spc & ex3_special[107])));
   assign ex3_sh16_r3_b[108] = (~((cp1_096 & ex3_sh_lvl2[12]) | (cp1_spc & ex3_special[108])));
   assign ex3_sh16_r3_b[109] = (~((cp1_096 & ex3_sh_lvl2[13]) | (cp1_spc & ex3_special[109])));
   assign ex3_sh16_r3_b[110] = (~((cp1_096 & ex3_sh_lvl2[14]) | (cp1_spc & ex3_special[110])));
   assign ex3_sh16_r3_b[111] = (~((cp1_096 & ex3_sh_lvl2[15]) | (cp1_spc & ex3_special[111])));

   assign ex3_sh16_r3_b[112] = (~((cp1_112 & ex3_sh_lvl2[0]) | (cp2_spc & ex3_special[112])));
   assign ex3_sh16_r3_b[113] = (~((cp1_112 & ex3_sh_lvl2[1]) | (cp2_spc & ex3_special[113])));
   assign ex3_sh16_r3_b[114] = (~((cp1_112 & ex3_sh_lvl2[2]) | (cp2_spc & ex3_special[114])));
   assign ex3_sh16_r3_b[115] = (~((cp1_112 & ex3_sh_lvl2[3]) | (cp2_spc & ex3_special[115])));
   assign ex3_sh16_r3_b[116] = (~((cp1_112 & ex3_sh_lvl2[4]) | (cp2_spc & ex3_special[116])));
   assign ex3_sh16_r3_b[117] = (~((cp1_112 & ex3_sh_lvl2[5]) | (cp2_spc & ex3_special[117])));
   assign ex3_sh16_r3_b[118] = (~((cp1_112 & ex3_sh_lvl2[6]) | (cp2_spc & ex3_special[118])));
   assign ex3_sh16_r3_b[119] = (~((cp1_112 & ex3_sh_lvl2[7]) | (cp2_spc & ex3_special[119])));
   assign ex3_sh16_r3_b[120] = (~((cp1_112 & ex3_sh_lvl2[8]) | (cp2_spc & ex3_special[120])));
   assign ex3_sh16_r3_b[121] = (~((cp1_112 & ex3_sh_lvl2[9]) | (cp2_spc & ex3_special[121])));
   assign ex3_sh16_r3_b[122] = (~((cp1_112 & ex3_sh_lvl2[10]) | (cp2_spc & ex3_special[122])));
   assign ex3_sh16_r3_b[123] = (~((cp1_112 & ex3_sh_lvl2[11]) | (cp2_spc & ex3_special[123])));
   assign ex3_sh16_r3_b[124] = (~((cp1_112 & ex3_sh_lvl2[12]) | (cp2_spc & ex3_special[124])));
   assign ex3_sh16_r3_b[125] = (~((cp1_112 & ex3_sh_lvl2[13]) | (cp2_spc & ex3_special[125])));
   assign ex3_sh16_r3_b[126] = (~((cp1_112 & ex3_sh_lvl2[14]) | (cp2_spc & ex3_special[126])));
   assign ex3_sh16_r3_b[127] = (~((cp1_112 & ex3_sh_lvl2[15]) | (cp2_spc & ex3_special[127])));

   assign ex3_sh16_r3_b[128] = (~((cp1_128 & ex3_sh_lvl2[0]) | (cp3_spc & ex3_special[128])));
   assign ex3_sh16_r3_b[129] = (~((cp1_128 & ex3_sh_lvl2[1]) | (cp3_spc & ex3_special[129])));
   assign ex3_sh16_r3_b[130] = (~((cp1_128 & ex3_sh_lvl2[2]) | (cp3_spc & ex3_special[130])));
   assign ex3_sh16_r3_b[131] = (~((cp1_128 & ex3_sh_lvl2[3]) | (cp3_spc & ex3_special[131])));
   assign ex3_sh16_r3_b[132] = (~((cp1_128 & ex3_sh_lvl2[4]) | (cp3_spc & ex3_special[132])));
   assign ex3_sh16_r3_b[133] = (~((cp1_128 & ex3_sh_lvl2[5]) | (cp3_spc & ex3_special[133])));
   assign ex3_sh16_r3_b[134] = (~((cp1_128 & ex3_sh_lvl2[6]) | (cp3_spc & ex3_special[134])));
   assign ex3_sh16_r3_b[135] = (~((cp1_128 & ex3_sh_lvl2[7]) | (cp3_spc & ex3_special[135])));
   assign ex3_sh16_r3_b[136] = (~((cp1_128 & ex3_sh_lvl2[8]) | (cp3_spc & ex3_special[136])));
   assign ex3_sh16_r3_b[137] = (~((cp1_128 & ex3_sh_lvl2[9]) | (cp3_spc & ex3_special[137])));
   assign ex3_sh16_r3_b[138] = (~((cp1_128 & ex3_sh_lvl2[10]) | (cp3_spc & ex3_special[138])));
   assign ex3_sh16_r3_b[139] = (~((cp1_128 & ex3_sh_lvl2[11]) | (cp3_spc & ex3_special[139])));
   assign ex3_sh16_r3_b[140] = (~((cp1_128 & ex3_sh_lvl2[12]) | (cp3_spc & ex3_special[140])));
   assign ex3_sh16_r3_b[141] = (~((cp1_128 & ex3_sh_lvl2[13]) | (cp3_spc & ex3_special[141])));
   assign ex3_sh16_r3_b[142] = (~((cp1_128 & ex3_sh_lvl2[14]) | (cp3_spc & ex3_special[142])));
   assign ex3_sh16_r3_b[143] = (~((cp1_128 & ex3_sh_lvl2[15]) | (cp3_spc & ex3_special[143])));

   assign ex3_sh16_r3_b[144] = (~((cp1_144 & ex3_sh_lvl2[0]) | (cp4_spc & ex3_special[144])));
   assign ex3_sh16_r3_b[145] = (~((cp1_144 & ex3_sh_lvl2[1]) | (cp4_spc & ex3_special[145])));
   assign ex3_sh16_r3_b[146] = (~((cp1_144 & ex3_sh_lvl2[2]) | (cp4_spc & ex3_special[146])));
   assign ex3_sh16_r3_b[147] = (~((cp1_144 & ex3_sh_lvl2[3]) | (cp4_spc & ex3_special[147])));
   assign ex3_sh16_r3_b[148] = (~((cp1_144 & ex3_sh_lvl2[4]) | (cp4_spc & ex3_special[148])));
   assign ex3_sh16_r3_b[149] = (~((cp1_144 & ex3_sh_lvl2[5]) | (cp4_spc & ex3_special[149])));
   assign ex3_sh16_r3_b[150] = (~((cp1_144 & ex3_sh_lvl2[6]) | (cp4_spc & ex3_special[150])));
   assign ex3_sh16_r3_b[151] = (~((cp1_144 & ex3_sh_lvl2[7]) | (cp4_spc & ex3_special[151])));
   assign ex3_sh16_r3_b[152] = (~((cp1_144 & ex3_sh_lvl2[8]) | (cp4_spc & ex3_special[152])));
   assign ex3_sh16_r3_b[153] = (~((cp1_144 & ex3_sh_lvl2[9]) | (cp4_spc & ex3_special[153])));
   assign ex3_sh16_r3_b[154] = (~((cp1_144 & ex3_sh_lvl2[10]) | (cp4_spc & ex3_special[154])));
   assign ex3_sh16_r3_b[155] = (~((cp1_144 & ex3_sh_lvl2[11]) | (cp4_spc & ex3_special[155])));
   assign ex3_sh16_r3_b[156] = (~((cp1_144 & ex3_sh_lvl2[12]) | (cp4_spc & ex3_special[156])));
   assign ex3_sh16_r3_b[157] = (~((cp1_144 & ex3_sh_lvl2[13]) | (cp4_spc & ex3_special[157])));
   assign ex3_sh16_r3_b[158] = (~((cp1_144 & ex3_sh_lvl2[14]) | (cp4_spc & ex3_special[158])));
   assign ex3_sh16_r3_b[159] = (~((cp1_144 & ex3_sh_lvl2[15]) | (cp4_spc & ex3_special[159])));

   assign ex3_sh16_r3_b[160] = (~((cp1_160 & ex3_sh_lvl2[0]) | (cp5_spc & ex3_special[160])));
   assign ex3_sh16_r3_b[161] = (~((cp1_160 & ex3_sh_lvl2[1]) | (cp5_spc & ex3_special[161])));
   assign ex3_sh16_r3_b[162] = (~((cp1_160 & ex3_sh_lvl2[2]) | (cp5_spc & ex3_special[162])));

   assign ex3_sh_lvl3[0] = (~(ex3_sh16_r1_b[0] & ex3_sh16_r2_b[0] & ex3_sh16_r3_b[0]));
   assign ex3_sh_lvl3[1] = (~(ex3_sh16_r1_b[1] & ex3_sh16_r2_b[1] & ex3_sh16_r3_b[1]));
   assign ex3_sh_lvl3[2] = (~(ex3_sh16_r1_b[2] & ex3_sh16_r2_b[2] & ex3_sh16_r3_b[2]));
   assign ex3_sh_lvl3[3] = (~(ex3_sh16_r1_b[3] & ex3_sh16_r2_b[3] & ex3_sh16_r3_b[3]));
   assign ex3_sh_lvl3[4] = (~(ex3_sh16_r1_b[4] & ex3_sh16_r2_b[4] & ex3_sh16_r3_b[4]));
   assign ex3_sh_lvl3[5] = (~(ex3_sh16_r1_b[5] & ex3_sh16_r2_b[5] & ex3_sh16_r3_b[5]));
   assign ex3_sh_lvl3[6] = (~(ex3_sh16_r1_b[6] & ex3_sh16_r2_b[6] & ex3_sh16_r3_b[6]));
   assign ex3_sh_lvl3[7] = (~(ex3_sh16_r1_b[7] & ex3_sh16_r2_b[7] & ex3_sh16_r3_b[7]));
   assign ex3_sh_lvl3[8] = (~(ex3_sh16_r1_b[8] & ex3_sh16_r2_b[8] & ex3_sh16_r3_b[8]));
   assign ex3_sh_lvl3[9] = (~(ex3_sh16_r1_b[9] & ex3_sh16_r2_b[9] & ex3_sh16_r3_b[9]));
   assign ex3_sh_lvl3[10] = (~(ex3_sh16_r1_b[10] & ex3_sh16_r2_b[10] & ex3_sh16_r3_b[10]));
   assign ex3_sh_lvl3[11] = (~(ex3_sh16_r1_b[11] & ex3_sh16_r2_b[11] & ex3_sh16_r3_b[11]));
   assign ex3_sh_lvl3[12] = (~(ex3_sh16_r1_b[12] & ex3_sh16_r2_b[12] & ex3_sh16_r3_b[12]));
   assign ex3_sh_lvl3[13] = (~(ex3_sh16_r1_b[13] & ex3_sh16_r2_b[13] & ex3_sh16_r3_b[13]));
   assign ex3_sh_lvl3[14] = (~(ex3_sh16_r1_b[14] & ex3_sh16_r2_b[14] & ex3_sh16_r3_b[14]));
   assign ex3_sh_lvl3[15] = (~(ex3_sh16_r1_b[15] & ex3_sh16_r2_b[15] & ex3_sh16_r3_b[15]));
   assign ex3_sh_lvl3[16] = (~(ex3_sh16_r1_b[16] & ex3_sh16_r2_b[16] & ex3_sh16_r3_b[16]));
   assign ex3_sh_lvl3[17] = (~(ex3_sh16_r1_b[17] & ex3_sh16_r2_b[17] & ex3_sh16_r3_b[17]));
   assign ex3_sh_lvl3[18] = (~(ex3_sh16_r1_b[18] & ex3_sh16_r2_b[18] & ex3_sh16_r3_b[18]));
   assign ex3_sh_lvl3[19] = (~(ex3_sh16_r1_b[19] & ex3_sh16_r2_b[19] & ex3_sh16_r3_b[19]));
   assign ex3_sh_lvl3[20] = (~(ex3_sh16_r1_b[20] & ex3_sh16_r2_b[20] & ex3_sh16_r3_b[20]));
   assign ex3_sh_lvl3[21] = (~(ex3_sh16_r1_b[21] & ex3_sh16_r2_b[21] & ex3_sh16_r3_b[21]));
   assign ex3_sh_lvl3[22] = (~(ex3_sh16_r1_b[22] & ex3_sh16_r2_b[22] & ex3_sh16_r3_b[22]));
   assign ex3_sh_lvl3[23] = (~(ex3_sh16_r1_b[23] & ex3_sh16_r2_b[23] & ex3_sh16_r3_b[23]));
   assign ex3_sh_lvl3[24] = (~(ex3_sh16_r1_b[24] & ex3_sh16_r2_b[24] & ex3_sh16_r3_b[24]));
   assign ex3_sh_lvl3[25] = (~(ex3_sh16_r1_b[25] & ex3_sh16_r2_b[25] & ex3_sh16_r3_b[25]));
   assign ex3_sh_lvl3[26] = (~(ex3_sh16_r1_b[26] & ex3_sh16_r2_b[26] & ex3_sh16_r3_b[26]));
   assign ex3_sh_lvl3[27] = (~(ex3_sh16_r1_b[27] & ex3_sh16_r2_b[27] & ex3_sh16_r3_b[27]));
   assign ex3_sh_lvl3[28] = (~(ex3_sh16_r1_b[28] & ex3_sh16_r2_b[28] & ex3_sh16_r3_b[28]));
   assign ex3_sh_lvl3[29] = (~(ex3_sh16_r1_b[29] & ex3_sh16_r2_b[29] & ex3_sh16_r3_b[29]));
   assign ex3_sh_lvl3[30] = (~(ex3_sh16_r1_b[30] & ex3_sh16_r2_b[30] & ex3_sh16_r3_b[30]));
   assign ex3_sh_lvl3[31] = (~(ex3_sh16_r1_b[31] & ex3_sh16_r2_b[31] & ex3_sh16_r3_b[31]));
   assign ex3_sh_lvl3[32] = (~(ex3_sh16_r1_b[32] & ex3_sh16_r2_b[32] & ex3_sh16_r3_b[32]));
   assign ex3_sh_lvl3[33] = (~(ex3_sh16_r1_b[33] & ex3_sh16_r2_b[33] & ex3_sh16_r3_b[33]));
   assign ex3_sh_lvl3[34] = (~(ex3_sh16_r1_b[34] & ex3_sh16_r2_b[34] & ex3_sh16_r3_b[34]));
   assign ex3_sh_lvl3[35] = (~(ex3_sh16_r1_b[35] & ex3_sh16_r2_b[35] & ex3_sh16_r3_b[35]));
   assign ex3_sh_lvl3[36] = (~(ex3_sh16_r1_b[36] & ex3_sh16_r2_b[36] & ex3_sh16_r3_b[36]));
   assign ex3_sh_lvl3[37] = (~(ex3_sh16_r1_b[37] & ex3_sh16_r2_b[37] & ex3_sh16_r3_b[37]));
   assign ex3_sh_lvl3[38] = (~(ex3_sh16_r1_b[38] & ex3_sh16_r2_b[38] & ex3_sh16_r3_b[38]));
   assign ex3_sh_lvl3[39] = (~(ex3_sh16_r1_b[39] & ex3_sh16_r2_b[39] & ex3_sh16_r3_b[39]));
   assign ex3_sh_lvl3[40] = (~(ex3_sh16_r1_b[40] & ex3_sh16_r2_b[40] & ex3_sh16_r3_b[40]));
   assign ex3_sh_lvl3[41] = (~(ex3_sh16_r1_b[41] & ex3_sh16_r2_b[41] & ex3_sh16_r3_b[41]));
   assign ex3_sh_lvl3[42] = (~(ex3_sh16_r1_b[42] & ex3_sh16_r2_b[42] & ex3_sh16_r3_b[42]));
   assign ex3_sh_lvl3[43] = (~(ex3_sh16_r1_b[43] & ex3_sh16_r2_b[43] & ex3_sh16_r3_b[43]));
   assign ex3_sh_lvl3[44] = (~(ex3_sh16_r1_b[44] & ex3_sh16_r2_b[44] & ex3_sh16_r3_b[44]));
   assign ex3_sh_lvl3[45] = (~(ex3_sh16_r1_b[45] & ex3_sh16_r2_b[45] & ex3_sh16_r3_b[45]));
   assign ex3_sh_lvl3[46] = (~(ex3_sh16_r1_b[46] & ex3_sh16_r2_b[46] & ex3_sh16_r3_b[46]));
   assign ex3_sh_lvl3[47] = (~(ex3_sh16_r1_b[47] & ex3_sh16_r2_b[47] & ex3_sh16_r3_b[47]));
   assign ex3_sh_lvl3[48] = (~(ex3_sh16_r1_b[48] & ex3_sh16_r2_b[48] & ex3_sh16_r3_b[48]));
   assign ex3_sh_lvl3[49] = (~(ex3_sh16_r1_b[49] & ex3_sh16_r2_b[49] & ex3_sh16_r3_b[49]));
   assign ex3_sh_lvl3[50] = (~(ex3_sh16_r1_b[50] & ex3_sh16_r2_b[50] & ex3_sh16_r3_b[50]));
   assign ex3_sh_lvl3[51] = (~(ex3_sh16_r1_b[51] & ex3_sh16_r2_b[51] & ex3_sh16_r3_b[51]));
   assign ex3_sh_lvl3[52] = (~(ex3_sh16_r1_b[52] & ex3_sh16_r2_b[52] & ex3_sh16_r3_b[52]));
   assign ex3_sh_lvl3[53] = (~(ex3_sh16_r1_b[53] & ex3_sh16_r2_b[53] & ex3_sh16_r3_b[53]));
   assign ex3_sh_lvl3[54] = (~(ex3_sh16_r1_b[54] & ex3_sh16_r2_b[54] & ex3_sh16_r3_b[54]));
   assign ex3_sh_lvl3[55] = (~(ex3_sh16_r1_b[55] & ex3_sh16_r2_b[55] & ex3_sh16_r3_b[55]));
   assign ex3_sh_lvl3[56] = (~(ex3_sh16_r1_b[56] & ex3_sh16_r2_b[56] & ex3_sh16_r3_b[56]));
   assign ex3_sh_lvl3[57] = (~(ex3_sh16_r1_b[57] & ex3_sh16_r2_b[57] & ex3_sh16_r3_b[57]));
   assign ex3_sh_lvl3[58] = (~(ex3_sh16_r1_b[58] & ex3_sh16_r2_b[58] & ex3_sh16_r3_b[58]));
   assign ex3_sh_lvl3[59] = (~(ex3_sh16_r1_b[59] & ex3_sh16_r2_b[59] & ex3_sh16_r3_b[59]));
   assign ex3_sh_lvl3[60] = (~(ex3_sh16_r1_b[60] & ex3_sh16_r2_b[60] & ex3_sh16_r3_b[60]));
   assign ex3_sh_lvl3[61] = (~(ex3_sh16_r1_b[61] & ex3_sh16_r2_b[61] & ex3_sh16_r3_b[61]));
   assign ex3_sh_lvl3[62] = (~(ex3_sh16_r1_b[62] & ex3_sh16_r2_b[62] & ex3_sh16_r3_b[62]));
   assign ex3_sh_lvl3[63] = (~(ex3_sh16_r1_b[63] & ex3_sh16_r2_b[63] & ex3_sh16_r3_b[63]));
   assign ex3_sh_lvl3[64] = (~(ex3_sh16_r1_b[64] & ex3_sh16_r2_b[64] & ex3_sh16_r3_b[64]));
   assign ex3_sh_lvl3[65] = (~(ex3_sh16_r1_b[65] & ex3_sh16_r2_b[65] & ex3_sh16_r3_b[65]));
   assign ex3_sh_lvl3[66] = (~(ex3_sh16_r1_b[66] & ex3_sh16_r2_b[66] & ex3_sh16_r3_b[66]));
   assign ex3_sh_lvl3[67] = (~(ex3_sh16_r1_b[67] & ex3_sh16_r2_b[67] & ex3_sh16_r3_b[67]));
   assign ex3_sh_lvl3[68] = (~(ex3_sh16_r1_b[68] & ex3_sh16_r2_b[68] & ex3_sh16_r3_b[68]));
   assign ex3_sh_lvl3[69] = (~(ex3_sh16_r1_b[69] & ex3_sh16_r2_b[69] & ex3_sh16_r3_b[69]));
   assign ex3_sh_lvl3[70] = (~(ex3_sh16_r1_b[70] & ex3_sh16_r2_b[70] & ex3_sh16_r3_b[70]));
   assign ex3_sh_lvl3[71] = (~(ex3_sh16_r1_b[71] & ex3_sh16_r2_b[71] & ex3_sh16_r3_b[71]));
   assign ex3_sh_lvl3[72] = (~(ex3_sh16_r1_b[72] & ex3_sh16_r2_b[72] & ex3_sh16_r3_b[72]));
   assign ex3_sh_lvl3[73] = (~(ex3_sh16_r1_b[73] & ex3_sh16_r2_b[73] & ex3_sh16_r3_b[73]));
   assign ex3_sh_lvl3[74] = (~(ex3_sh16_r1_b[74] & ex3_sh16_r2_b[74] & ex3_sh16_r3_b[74]));
   assign ex3_sh_lvl3[75] = (~(ex3_sh16_r1_b[75] & ex3_sh16_r2_b[75] & ex3_sh16_r3_b[75]));
   assign ex3_sh_lvl3[76] = (~(ex3_sh16_r1_b[76] & ex3_sh16_r2_b[76] & ex3_sh16_r3_b[76]));
   assign ex3_sh_lvl3[77] = (~(ex3_sh16_r1_b[77] & ex3_sh16_r2_b[77] & ex3_sh16_r3_b[77]));
   assign ex3_sh_lvl3[78] = (~(ex3_sh16_r1_b[78] & ex3_sh16_r2_b[78] & ex3_sh16_r3_b[78]));
   assign ex3_sh_lvl3[79] = (~(ex3_sh16_r1_b[79] & ex3_sh16_r2_b[79] & ex3_sh16_r3_b[79]));
   assign ex3_sh_lvl3[80] = (~(ex3_sh16_r1_b[80] & ex3_sh16_r2_b[80] & ex3_sh16_r3_b[80]));
   assign ex3_sh_lvl3[81] = (~(ex3_sh16_r1_b[81] & ex3_sh16_r2_b[81] & ex3_sh16_r3_b[81]));
   assign ex3_sh_lvl3[82] = (~(ex3_sh16_r1_b[82] & ex3_sh16_r2_b[82] & ex3_sh16_r3_b[82]));
   assign ex3_sh_lvl3[83] = (~(ex3_sh16_r1_b[83] & ex3_sh16_r2_b[83] & ex3_sh16_r3_b[83]));
   assign ex3_sh_lvl3[84] = (~(ex3_sh16_r1_b[84] & ex3_sh16_r2_b[84] & ex3_sh16_r3_b[84]));
   assign ex3_sh_lvl3[85] = (~(ex3_sh16_r1_b[85] & ex3_sh16_r2_b[85] & ex3_sh16_r3_b[85]));
   assign ex3_sh_lvl3[86] = (~(ex3_sh16_r1_b[86] & ex3_sh16_r2_b[86] & ex3_sh16_r3_b[86]));
   assign ex3_sh_lvl3[87] = (~(ex3_sh16_r1_b[87] & ex3_sh16_r2_b[87] & ex3_sh16_r3_b[87]));
   assign ex3_sh_lvl3[88] = (~(ex3_sh16_r1_b[88] & ex3_sh16_r2_b[88] & ex3_sh16_r3_b[88]));
   assign ex3_sh_lvl3[89] = (~(ex3_sh16_r1_b[89] & ex3_sh16_r2_b[89] & ex3_sh16_r3_b[89]));
   assign ex3_sh_lvl3[90] = (~(ex3_sh16_r1_b[90] & ex3_sh16_r2_b[90] & ex3_sh16_r3_b[90]));
   assign ex3_sh_lvl3[91] = (~(ex3_sh16_r1_b[91] & ex3_sh16_r2_b[91] & ex3_sh16_r3_b[91]));
   assign ex3_sh_lvl3[92] = (~(ex3_sh16_r1_b[92] & ex3_sh16_r2_b[92] & ex3_sh16_r3_b[92]));
   assign ex3_sh_lvl3[93] = (~(ex3_sh16_r1_b[93] & ex3_sh16_r2_b[93] & ex3_sh16_r3_b[93]));
   assign ex3_sh_lvl3[94] = (~(ex3_sh16_r1_b[94] & ex3_sh16_r2_b[94] & ex3_sh16_r3_b[94]));
   assign ex3_sh_lvl3[95] = (~(ex3_sh16_r1_b[95] & ex3_sh16_r2_b[95] & ex3_sh16_r3_b[95]));
   assign ex3_sh_lvl3[96] = (~(ex3_sh16_r1_b[96] & ex3_sh16_r2_b[96] & ex3_sh16_r3_b[96]));
   assign ex3_sh_lvl3[97] = (~(ex3_sh16_r1_b[97] & ex3_sh16_r2_b[97] & ex3_sh16_r3_b[97]));
   assign ex3_sh_lvl3[98] = (~(ex3_sh16_r1_b[98] & ex3_sh16_r2_b[98] & ex3_sh16_r3_b[98]));
   assign ex3_sh_lvl3[99] = (~(ex3_sh16_r1_b[99] & ex3_sh16_r2_b[99] & ex3_sh16_r3_b[99]));
   assign ex3_sh_lvl3[100] = (~(ex3_sh16_r1_b[100] & ex3_sh16_r2_b[100] & ex3_sh16_r3_b[100]));
   assign ex3_sh_lvl3[101] = (~(ex3_sh16_r1_b[101] & ex3_sh16_r2_b[101] & ex3_sh16_r3_b[101]));
   assign ex3_sh_lvl3[102] = (~(ex3_sh16_r1_b[102] & ex3_sh16_r2_b[102] & ex3_sh16_r3_b[102]));
   assign ex3_sh_lvl3[103] = (~(ex3_sh16_r1_b[103] & ex3_sh16_r2_b[103] & ex3_sh16_r3_b[103]));
   assign ex3_sh_lvl3[104] = (~(ex3_sh16_r1_b[104] & ex3_sh16_r2_b[104] & ex3_sh16_r3_b[104]));
   assign ex3_sh_lvl3[105] = (~(ex3_sh16_r1_b[105] & ex3_sh16_r2_b[105] & ex3_sh16_r3_b[105]));
   assign ex3_sh_lvl3[106] = (~(ex3_sh16_r1_b[106] & ex3_sh16_r2_b[106] & ex3_sh16_r3_b[106]));
   assign ex3_sh_lvl3[107] = (~(ex3_sh16_r1_b[107] & ex3_sh16_r2_b[107] & ex3_sh16_r3_b[107]));
   assign ex3_sh_lvl3[108] = (~(ex3_sh16_r1_b[108] & ex3_sh16_r2_b[108] & ex3_sh16_r3_b[108]));
   assign ex3_sh_lvl3[109] = (~(ex3_sh16_r1_b[109] & ex3_sh16_r2_b[109] & ex3_sh16_r3_b[109]));
   assign ex3_sh_lvl3[110] = (~(ex3_sh16_r1_b[110] & ex3_sh16_r2_b[110] & ex3_sh16_r3_b[110]));
   assign ex3_sh_lvl3[111] = (~(ex3_sh16_r1_b[111] & ex3_sh16_r2_b[111] & ex3_sh16_r3_b[111]));
   assign ex3_sh_lvl3[112] = (~(ex3_sh16_r1_b[112] & ex3_sh16_r2_b[112] & ex3_sh16_r3_b[112]));
   assign ex3_sh_lvl3[113] = (~(ex3_sh16_r1_b[113] & ex3_sh16_r2_b[113] & ex3_sh16_r3_b[113]));
   assign ex3_sh_lvl3[114] = (~(ex3_sh16_r1_b[114] & ex3_sh16_r2_b[114] & ex3_sh16_r3_b[114]));
   assign ex3_sh_lvl3[115] = (~(ex3_sh16_r1_b[115] & ex3_sh16_r2_b[115] & ex3_sh16_r3_b[115]));
   assign ex3_sh_lvl3[116] = (~(ex3_sh16_r1_b[116] & ex3_sh16_r2_b[116] & ex3_sh16_r3_b[116]));
   assign ex3_sh_lvl3[117] = (~(ex3_sh16_r1_b[117] & ex3_sh16_r2_b[117] & ex3_sh16_r3_b[117]));
   assign ex3_sh_lvl3[118] = (~(ex3_sh16_r1_b[118] & ex3_sh16_r2_b[118] & ex3_sh16_r3_b[118]));
   assign ex3_sh_lvl3[119] = (~(ex3_sh16_r1_b[119] & ex3_sh16_r2_b[119] & ex3_sh16_r3_b[119]));
   assign ex3_sh_lvl3[120] = (~(ex3_sh16_r1_b[120] & ex3_sh16_r2_b[120] & ex3_sh16_r3_b[120]));
   assign ex3_sh_lvl3[121] = (~(ex3_sh16_r1_b[121] & ex3_sh16_r2_b[121] & ex3_sh16_r3_b[121]));
   assign ex3_sh_lvl3[122] = (~(ex3_sh16_r1_b[122] & ex3_sh16_r2_b[122] & ex3_sh16_r3_b[122]));
   assign ex3_sh_lvl3[123] = (~(ex3_sh16_r1_b[123] & ex3_sh16_r2_b[123] & ex3_sh16_r3_b[123]));
   assign ex3_sh_lvl3[124] = (~(ex3_sh16_r1_b[124] & ex3_sh16_r2_b[124] & ex3_sh16_r3_b[124]));
   assign ex3_sh_lvl3[125] = (~(ex3_sh16_r1_b[125] & ex3_sh16_r2_b[125] & ex3_sh16_r3_b[125]));
   assign ex3_sh_lvl3[126] = (~(ex3_sh16_r1_b[126] & ex3_sh16_r2_b[126] & ex3_sh16_r3_b[126]));
   assign ex3_sh_lvl3[127] = (~(ex3_sh16_r1_b[127] & ex3_sh16_r2_b[127] & ex3_sh16_r3_b[127]));
   assign ex3_sh_lvl3[128] = (~(ex3_sh16_r1_b[128] & ex3_sh16_r2_b[128] & ex3_sh16_r3_b[128]));
   assign ex3_sh_lvl3[129] = (~(ex3_sh16_r1_b[129] & ex3_sh16_r2_b[129] & ex3_sh16_r3_b[129]));
   assign ex3_sh_lvl3[130] = (~(ex3_sh16_r1_b[130] & ex3_sh16_r2_b[130] & ex3_sh16_r3_b[130]));
   assign ex3_sh_lvl3[131] = (~(ex3_sh16_r1_b[131] & ex3_sh16_r2_b[131] & ex3_sh16_r3_b[131]));
   assign ex3_sh_lvl3[132] = (~(ex3_sh16_r1_b[132] & ex3_sh16_r2_b[132] & ex3_sh16_r3_b[132]));
   assign ex3_sh_lvl3[133] = (~(ex3_sh16_r1_b[133] & ex3_sh16_r2_b[133] & ex3_sh16_r3_b[133]));
   assign ex3_sh_lvl3[134] = (~(ex3_sh16_r1_b[134] & ex3_sh16_r2_b[134] & ex3_sh16_r3_b[134]));
   assign ex3_sh_lvl3[135] = (~(ex3_sh16_r1_b[135] & ex3_sh16_r2_b[135] & ex3_sh16_r3_b[135]));
   assign ex3_sh_lvl3[136] = (~(ex3_sh16_r1_b[136] & ex3_sh16_r2_b[136] & ex3_sh16_r3_b[136]));
   assign ex3_sh_lvl3[137] = (~(ex3_sh16_r1_b[137] & ex3_sh16_r2_b[137] & ex3_sh16_r3_b[137]));
   assign ex3_sh_lvl3[138] = (~(ex3_sh16_r1_b[138] & ex3_sh16_r2_b[138] & ex3_sh16_r3_b[138]));
   assign ex3_sh_lvl3[139] = (~(ex3_sh16_r1_b[139] & ex3_sh16_r2_b[139] & ex3_sh16_r3_b[139]));
   assign ex3_sh_lvl3[140] = (~(ex3_sh16_r1_b[140] & ex3_sh16_r2_b[140] & ex3_sh16_r3_b[140]));
   assign ex3_sh_lvl3[141] = (~(ex3_sh16_r1_b[141] & ex3_sh16_r2_b[141] & ex3_sh16_r3_b[141]));
   assign ex3_sh_lvl3[142] = (~(ex3_sh16_r1_b[142] & ex3_sh16_r2_b[142] & ex3_sh16_r3_b[142]));
   assign ex3_sh_lvl3[143] = (~(ex3_sh16_r1_b[143] & ex3_sh16_r2_b[143] & ex3_sh16_r3_b[143]));
   assign ex3_sh_lvl3[144] = (~(ex3_sh16_r1_b[144] & ex3_sh16_r2_b[144] & ex3_sh16_r3_b[144]));
   assign ex3_sh_lvl3[145] = (~(ex3_sh16_r1_b[145] & ex3_sh16_r2_b[145] & ex3_sh16_r3_b[145]));
   assign ex3_sh_lvl3[146] = (~(ex3_sh16_r1_b[146] & ex3_sh16_r2_b[146] & ex3_sh16_r3_b[146]));
   assign ex3_sh_lvl3[147] = (~(ex3_sh16_r1_b[147] & ex3_sh16_r2_b[147] & ex3_sh16_r3_b[147]));
   assign ex3_sh_lvl3[148] = (~(ex3_sh16_r1_b[148] & ex3_sh16_r2_b[148] & ex3_sh16_r3_b[148]));
   assign ex3_sh_lvl3[149] = (~(ex3_sh16_r1_b[149] & ex3_sh16_r2_b[149] & ex3_sh16_r3_b[149]));
   assign ex3_sh_lvl3[150] = (~(ex3_sh16_r1_b[150] & ex3_sh16_r2_b[150] & ex3_sh16_r3_b[150]));
   assign ex3_sh_lvl3[151] = (~(ex3_sh16_r1_b[151] & ex3_sh16_r2_b[151] & ex3_sh16_r3_b[151]));
   assign ex3_sh_lvl3[152] = (~(ex3_sh16_r1_b[152] & ex3_sh16_r2_b[152] & ex3_sh16_r3_b[152]));
   assign ex3_sh_lvl3[153] = (~(ex3_sh16_r1_b[153] & ex3_sh16_r2_b[153] & ex3_sh16_r3_b[153]));
   assign ex3_sh_lvl3[154] = (~(ex3_sh16_r1_b[154] & ex3_sh16_r2_b[154] & ex3_sh16_r3_b[154]));
   assign ex3_sh_lvl3[155] = (~(ex3_sh16_r1_b[155] & ex3_sh16_r2_b[155] & ex3_sh16_r3_b[155]));
   assign ex3_sh_lvl3[156] = (~(ex3_sh16_r1_b[156] & ex3_sh16_r2_b[156] & ex3_sh16_r3_b[156]));
   assign ex3_sh_lvl3[157] = (~(ex3_sh16_r1_b[157] & ex3_sh16_r2_b[157] & ex3_sh16_r3_b[157]));
   assign ex3_sh_lvl3[158] = (~(ex3_sh16_r1_b[158] & ex3_sh16_r2_b[158] & ex3_sh16_r3_b[158]));
   assign ex3_sh_lvl3[159] = (~(ex3_sh16_r1_b[159] & ex3_sh16_r2_b[159] & ex3_sh16_r3_b[159]));
   assign ex3_sh_lvl3[160] = (~(ex3_sh16_r1_b[160] & ex3_sh16_r2_b[160] & ex3_sh16_r3_b[160]));
   assign ex3_sh_lvl3[161] = (~(ex3_sh16_r1_b[161] & ex3_sh16_r2_b[161] & ex3_sh16_r3_b[161]));
   assign ex3_sh_lvl3[162] = (~(ex3_sh16_r1_b[162] & ex3_sh16_r2_b[162] & ex3_sh16_r3_b[162]));

   //--------------------------------------
   // replicated logic for sticky bit
   //--------------------------------------

   assign ex3_sh16_r3_162_b = (~((ex3_lvl3_shdcd160 & ex3_sh_lvl2[2]) | (ex3_sel_special & ex3_special[162])));
   assign ex3_sh16_r3_163_b = (~(ex3_lvl3_shdcd160 & ex3_sh_lvl2[3]));

   assign ex3_sh16_r2_162_b = (~((ex3_lvl3_shdcd128 & ex3_sh_lvl2[34]) | (ex3_lvl3_shdcd144 & ex3_sh_lvl2[18])));
   assign ex3_sh16_r2_163_b = (~((ex3_lvl3_shdcd128 & ex3_sh_lvl2[35]) | (ex3_lvl3_shdcd144 & ex3_sh_lvl2[19])));

   assign ex3_sh16_r1_162_b = (~((ex3_lvl3_shdcd096 & ex3_sh_lvl2[66]) | (ex3_lvl3_shdcd112 & ex3_sh_lvl2[50])));
   assign ex3_sh16_r1_163_b = (~((ex3_lvl3_shdcd096 & ex3_sh_lvl2[67]) | (ex3_lvl3_shdcd112 & ex3_sh_lvl2[51])));

   assign ex3_sh16_162 = (~(ex3_sh16_r1_162_b & ex3_sh16_r2_162_b & ex3_sh16_r3_162_b));
   assign ex3_sh16_163 = (~(ex3_sh16_r1_163_b & ex3_sh16_r2_163_b & ex3_sh16_r3_163_b));

endmodule
