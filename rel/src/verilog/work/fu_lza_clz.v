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

module fu_lza_clz(
   lv0_or,
   lv6_or_0,
   lv6_or_1,
   lza_any_b,
   lza_amt_b
);
   input [0:162] lv0_or;
   output        lv6_or_0;
   output        lv6_or_1;
   output        lza_any_b;
   output [0:7]  lza_amt_b;

   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire [0:81]   lv1_or_b;		// group_002
   wire [0:81]   lv1_inv_b;
   wire [0:81]   lv1_enc7_b;
   wire [0:40]   lv2_or;		// group_004
   wire [0:40]   lv2_inv;
   wire [0:40]   lv2_enc6;
   wire [0:40]   lv2_enc7;
   wire [0:20]   lv3_or_b;		// group_008

   wire [0:20]   lv3_inv_b;		// group_008
   wire [0:20]   lv3_enc5_b;
   wire [0:20]   lv3_enc6_b;
   wire [0:20]   lv3_enc7_b;

   wire [0:10]   lv4_or;		// group_016
   wire [0:10]   lv4_inv;		// group_016
   wire [0:10]   lv4_enc4;
   wire [0:10]   lv4_enc5;
   wire [0:10]   lv4_enc6;
   wire [0:10]   lv4_enc7;

   wire [0:10]   lv4_or_b;		// group_016
   wire [0:10]   lv4_enc4_b;
   wire [0:10]   lv4_enc5_b;
   wire [0:10]   lv4_enc6_b;
   wire [0:10]   lv4_enc7_b;

   //-----------------------------------------------------------

   wire [0:5]    lv5_or;		// group_032
   wire [0:5]    lv5_inv;
   wire [0:5]    lv5_enc3;
   wire [0:5]    lv5_enc4;
   wire [0:5]    lv5_enc5;
   wire [0:5]    lv5_enc6;
   wire [0:5]    lv5_enc7;

   wire [0:2]    lv6_or_b;		// group_064
   wire [0:2]    lv6_inv_b;
   wire [0:2]    lv6_enc2_b;
   wire [0:2]    lv6_enc3_b;
   wire [0:2]    lv6_enc4_b;
   wire [0:2]    lv6_enc5_b;
   wire [0:2]    lv6_enc6_b;
   wire [0:2]    lv6_enc7_b;

   wire [0:1]    lv7_or;		// group_128
   wire [0:1]    lv7_inv;
   wire [0:1]    lv7_enc1;
   wire [0:1]    lv7_enc2;
   wire [0:1]    lv7_enc3;
   wire [0:1]    lv7_enc4;
   wire [0:1]    lv7_enc5;
   wire [0:1]    lv7_enc6;
   wire [0:1]    lv7_enc7;

   wire [0:0]    lv8_or_b;		// group_256
   wire [0:0]    lv8_inv_b;
   wire [0:0]    lv8_enc0_b;
   wire [0:0]    lv8_enc1_b;
   wire [0:0]    lv8_enc2_b;
   wire [0:0]    lv8_enc3_b;
   wire [0:0]    lv8_enc4_b;
   wire [0:0]    lv8_enc5_b;
   wire [0:0]    lv8_enc6_b;
   wire [0:0]    lv8_enc7_b;

   //=#------------------------------------------------
   //=#-- ENCODING TREE (CLZ) count leading zeroes
   //=#------------------------------------------------
   //--------------------------------------------------------------------------------
   // 002 bit group (phase_in=P, phase_out=N, level_in=lv0, level_out=lv1)
   //--------------------------------------------------------------------------------

   assign lv1_or_b[0] = (~(lv0_or[0] | lv0_or[1]));
   assign lv1_or_b[1] = (~(lv0_or[2] | lv0_or[3]));
   assign lv1_or_b[2] = (~(lv0_or[4] | lv0_or[5]));
   assign lv1_or_b[3] = (~(lv0_or[6] | lv0_or[7]));
   assign lv1_or_b[4] = (~(lv0_or[8] | lv0_or[9]));
   assign lv1_or_b[5] = (~(lv0_or[10] | lv0_or[11]));
   assign lv1_or_b[6] = (~(lv0_or[12] | lv0_or[13]));
   assign lv1_or_b[7] = (~(lv0_or[14] | lv0_or[15]));
   assign lv1_or_b[8] = (~(lv0_or[16] | lv0_or[17]));
   assign lv1_or_b[9] = (~(lv0_or[18] | lv0_or[19]));
   assign lv1_or_b[10] = (~(lv0_or[20] | lv0_or[21]));
   assign lv1_or_b[11] = (~(lv0_or[22] | lv0_or[23]));
   assign lv1_or_b[12] = (~(lv0_or[24] | lv0_or[25]));
   assign lv1_or_b[13] = (~(lv0_or[26] | lv0_or[27]));
   assign lv1_or_b[14] = (~(lv0_or[28] | lv0_or[29]));
   assign lv1_or_b[15] = (~(lv0_or[30] | lv0_or[31]));
   assign lv1_or_b[16] = (~(lv0_or[32] | lv0_or[33]));
   assign lv1_or_b[17] = (~(lv0_or[34] | lv0_or[35]));
   assign lv1_or_b[18] = (~(lv0_or[36] | lv0_or[37]));
   assign lv1_or_b[19] = (~(lv0_or[38] | lv0_or[39]));
   assign lv1_or_b[20] = (~(lv0_or[40] | lv0_or[41]));
   assign lv1_or_b[21] = (~(lv0_or[42] | lv0_or[43]));
   assign lv1_or_b[22] = (~(lv0_or[44] | lv0_or[45]));
   assign lv1_or_b[23] = (~(lv0_or[46] | lv0_or[47]));
   assign lv1_or_b[24] = (~(lv0_or[48] | lv0_or[49]));
   assign lv1_or_b[25] = (~(lv0_or[50] | lv0_or[51]));
   assign lv1_or_b[26] = (~(lv0_or[52] | lv0_or[53]));
   assign lv1_or_b[27] = (~(lv0_or[54] | lv0_or[55]));
   assign lv1_or_b[28] = (~(lv0_or[56] | lv0_or[57]));
   assign lv1_or_b[29] = (~(lv0_or[58] | lv0_or[59]));
   assign lv1_or_b[30] = (~(lv0_or[60] | lv0_or[61]));
   assign lv1_or_b[31] = (~(lv0_or[62] | lv0_or[63]));
   assign lv1_or_b[32] = (~(lv0_or[64] | lv0_or[65]));
   assign lv1_or_b[33] = (~(lv0_or[66] | lv0_or[67]));
   assign lv1_or_b[34] = (~(lv0_or[68] | lv0_or[69]));
   assign lv1_or_b[35] = (~(lv0_or[70] | lv0_or[71]));
   assign lv1_or_b[36] = (~(lv0_or[72] | lv0_or[73]));
   assign lv1_or_b[37] = (~(lv0_or[74] | lv0_or[75]));
   assign lv1_or_b[38] = (~(lv0_or[76] | lv0_or[77]));
   assign lv1_or_b[39] = (~(lv0_or[78] | lv0_or[79]));
   assign lv1_or_b[40] = (~(lv0_or[80] | lv0_or[81]));
   assign lv1_or_b[41] = (~(lv0_or[82] | lv0_or[83]));
   assign lv1_or_b[42] = (~(lv0_or[84] | lv0_or[85]));
   assign lv1_or_b[43] = (~(lv0_or[86] | lv0_or[87]));
   assign lv1_or_b[44] = (~(lv0_or[88] | lv0_or[89]));
   assign lv1_or_b[45] = (~(lv0_or[90] | lv0_or[91]));
   assign lv1_or_b[46] = (~(lv0_or[92] | lv0_or[93]));
   assign lv1_or_b[47] = (~(lv0_or[94] | lv0_or[95]));
   assign lv1_or_b[48] = (~(lv0_or[96] | lv0_or[97]));
   assign lv1_or_b[49] = (~(lv0_or[98] | lv0_or[99]));
   assign lv1_or_b[50] = (~(lv0_or[100] | lv0_or[101]));
   assign lv1_or_b[51] = (~(lv0_or[102] | lv0_or[103]));
   assign lv1_or_b[52] = (~(lv0_or[104] | lv0_or[105]));
   assign lv1_or_b[53] = (~(lv0_or[106] | lv0_or[107]));
   assign lv1_or_b[54] = (~(lv0_or[108] | lv0_or[109]));
   assign lv1_or_b[55] = (~(lv0_or[110] | lv0_or[111]));
   assign lv1_or_b[56] = (~(lv0_or[112] | lv0_or[113]));
   assign lv1_or_b[57] = (~(lv0_or[114] | lv0_or[115]));
   assign lv1_or_b[58] = (~(lv0_or[116] | lv0_or[117]));
   assign lv1_or_b[59] = (~(lv0_or[118] | lv0_or[119]));
   assign lv1_or_b[60] = (~(lv0_or[120] | lv0_or[121]));
   assign lv1_or_b[61] = (~(lv0_or[122] | lv0_or[123]));
   assign lv1_or_b[62] = (~(lv0_or[124] | lv0_or[125]));
   assign lv1_or_b[63] = (~(lv0_or[126] | lv0_or[127]));
   assign lv1_or_b[64] = (~(lv0_or[128] | lv0_or[129]));
   assign lv1_or_b[65] = (~(lv0_or[130] | lv0_or[131]));
   assign lv1_or_b[66] = (~(lv0_or[132] | lv0_or[133]));
   assign lv1_or_b[67] = (~(lv0_or[134] | lv0_or[135]));
   assign lv1_or_b[68] = (~(lv0_or[136] | lv0_or[137]));
   assign lv1_or_b[69] = (~(lv0_or[138] | lv0_or[139]));
   assign lv1_or_b[70] = (~(lv0_or[140] | lv0_or[141]));
   assign lv1_or_b[71] = (~(lv0_or[142] | lv0_or[143]));
   assign lv1_or_b[72] = (~(lv0_or[144] | lv0_or[145]));
   assign lv1_or_b[73] = (~(lv0_or[146] | lv0_or[147]));
   assign lv1_or_b[74] = (~(lv0_or[148] | lv0_or[149]));
   assign lv1_or_b[75] = (~(lv0_or[150] | lv0_or[151]));
   assign lv1_or_b[76] = (~(lv0_or[152] | lv0_or[153]));
   assign lv1_or_b[77] = (~(lv0_or[154] | lv0_or[155]));
   assign lv1_or_b[78] = (~(lv0_or[156] | lv0_or[157]));
   assign lv1_or_b[79] = (~(lv0_or[158] | lv0_or[159]));
   assign lv1_or_b[80] = (~(lv0_or[160] | lv0_or[161]));
   assign lv1_or_b[81] = (~(lv0_or[162]));

   assign lv1_inv_b[0] = (~(lv0_or[0]));
   assign lv1_inv_b[1] = (~(lv0_or[2]));
   assign lv1_inv_b[2] = (~(lv0_or[4]));
   assign lv1_inv_b[3] = (~(lv0_or[6]));
   assign lv1_inv_b[4] = (~(lv0_or[8]));
   assign lv1_inv_b[5] = (~(lv0_or[10]));
   assign lv1_inv_b[6] = (~(lv0_or[12]));
   assign lv1_inv_b[7] = (~(lv0_or[14]));
   assign lv1_inv_b[8] = (~(lv0_or[16]));
   assign lv1_inv_b[9] = (~(lv0_or[18]));
   assign lv1_inv_b[10] = (~(lv0_or[20]));
   assign lv1_inv_b[11] = (~(lv0_or[22]));
   assign lv1_inv_b[12] = (~(lv0_or[24]));
   assign lv1_inv_b[13] = (~(lv0_or[26]));
   assign lv1_inv_b[14] = (~(lv0_or[28]));
   assign lv1_inv_b[15] = (~(lv0_or[30]));
   assign lv1_inv_b[16] = (~(lv0_or[32]));
   assign lv1_inv_b[17] = (~(lv0_or[34]));
   assign lv1_inv_b[18] = (~(lv0_or[36]));
   assign lv1_inv_b[19] = (~(lv0_or[38]));
   assign lv1_inv_b[20] = (~(lv0_or[40]));
   assign lv1_inv_b[21] = (~(lv0_or[42]));
   assign lv1_inv_b[22] = (~(lv0_or[44]));
   assign lv1_inv_b[23] = (~(lv0_or[46]));
   assign lv1_inv_b[24] = (~(lv0_or[48]));
   assign lv1_inv_b[25] = (~(lv0_or[50]));
   assign lv1_inv_b[26] = (~(lv0_or[52]));
   assign lv1_inv_b[27] = (~(lv0_or[54]));
   assign lv1_inv_b[28] = (~(lv0_or[56]));
   assign lv1_inv_b[29] = (~(lv0_or[58]));
   assign lv1_inv_b[30] = (~(lv0_or[60]));
   assign lv1_inv_b[31] = (~(lv0_or[62]));
   assign lv1_inv_b[32] = (~(lv0_or[64]));
   assign lv1_inv_b[33] = (~(lv0_or[66]));
   assign lv1_inv_b[34] = (~(lv0_or[68]));
   assign lv1_inv_b[35] = (~(lv0_or[70]));
   assign lv1_inv_b[36] = (~(lv0_or[72]));
   assign lv1_inv_b[37] = (~(lv0_or[74]));
   assign lv1_inv_b[38] = (~(lv0_or[76]));
   assign lv1_inv_b[39] = (~(lv0_or[78]));
   assign lv1_inv_b[40] = (~(lv0_or[80]));
   assign lv1_inv_b[41] = (~(lv0_or[82]));
   assign lv1_inv_b[42] = (~(lv0_or[84]));
   assign lv1_inv_b[43] = (~(lv0_or[86]));
   assign lv1_inv_b[44] = (~(lv0_or[88]));
   assign lv1_inv_b[45] = (~(lv0_or[90]));
   assign lv1_inv_b[46] = (~(lv0_or[92]));
   assign lv1_inv_b[47] = (~(lv0_or[94]));
   assign lv1_inv_b[48] = (~(lv0_or[96]));
   assign lv1_inv_b[49] = (~(lv0_or[98]));
   assign lv1_inv_b[50] = (~(lv0_or[100]));
   assign lv1_inv_b[51] = (~(lv0_or[102]));
   assign lv1_inv_b[52] = (~(lv0_or[104]));
   assign lv1_inv_b[53] = (~(lv0_or[106]));
   assign lv1_inv_b[54] = (~(lv0_or[108]));
   assign lv1_inv_b[55] = (~(lv0_or[110]));
   assign lv1_inv_b[56] = (~(lv0_or[112]));
   assign lv1_inv_b[57] = (~(lv0_or[114]));
   assign lv1_inv_b[58] = (~(lv0_or[116]));
   assign lv1_inv_b[59] = (~(lv0_or[118]));
   assign lv1_inv_b[60] = (~(lv0_or[120]));
   assign lv1_inv_b[61] = (~(lv0_or[122]));
   assign lv1_inv_b[62] = (~(lv0_or[124]));
   assign lv1_inv_b[63] = (~(lv0_or[126]));
   assign lv1_inv_b[64] = (~(lv0_or[128]));
   assign lv1_inv_b[65] = (~(lv0_or[130]));
   assign lv1_inv_b[66] = (~(lv0_or[132]));
   assign lv1_inv_b[67] = (~(lv0_or[134]));
   assign lv1_inv_b[68] = (~(lv0_or[136]));
   assign lv1_inv_b[69] = (~(lv0_or[138]));
   assign lv1_inv_b[70] = (~(lv0_or[140]));
   assign lv1_inv_b[71] = (~(lv0_or[142]));
   assign lv1_inv_b[72] = (~(lv0_or[144]));
   assign lv1_inv_b[73] = (~(lv0_or[146]));
   assign lv1_inv_b[74] = (~(lv0_or[148]));
   assign lv1_inv_b[75] = (~(lv0_or[150]));
   assign lv1_inv_b[76] = (~(lv0_or[152]));
   assign lv1_inv_b[77] = (~(lv0_or[154]));
   assign lv1_inv_b[78] = (~(lv0_or[156]));
   assign lv1_inv_b[79] = (~(lv0_or[158]));
   assign lv1_inv_b[80] = (~(lv0_or[160]));
   assign lv1_inv_b[81] = (~(lv0_or[162]));

   assign lv1_enc7_b[0] = (~(lv1_inv_b[0] & lv0_or[1]));
   assign lv1_enc7_b[1] = (~(lv1_inv_b[1] & lv0_or[3]));
   assign lv1_enc7_b[2] = (~(lv1_inv_b[2] & lv0_or[5]));
   assign lv1_enc7_b[3] = (~(lv1_inv_b[3] & lv0_or[7]));
   assign lv1_enc7_b[4] = (~(lv1_inv_b[4] & lv0_or[9]));
   assign lv1_enc7_b[5] = (~(lv1_inv_b[5] & lv0_or[11]));
   assign lv1_enc7_b[6] = (~(lv1_inv_b[6] & lv0_or[13]));
   assign lv1_enc7_b[7] = (~(lv1_inv_b[7] & lv0_or[15]));
   assign lv1_enc7_b[8] = (~(lv1_inv_b[8] & lv0_or[17]));
   assign lv1_enc7_b[9] = (~(lv1_inv_b[9] & lv0_or[19]));
   assign lv1_enc7_b[10] = (~(lv1_inv_b[10] & lv0_or[21]));
   assign lv1_enc7_b[11] = (~(lv1_inv_b[11] & lv0_or[23]));
   assign lv1_enc7_b[12] = (~(lv1_inv_b[12] & lv0_or[25]));
   assign lv1_enc7_b[13] = (~(lv1_inv_b[13] & lv0_or[27]));
   assign lv1_enc7_b[14] = (~(lv1_inv_b[14] & lv0_or[29]));
   assign lv1_enc7_b[15] = (~(lv1_inv_b[15] & lv0_or[31]));
   assign lv1_enc7_b[16] = (~(lv1_inv_b[16] & lv0_or[33]));
   assign lv1_enc7_b[17] = (~(lv1_inv_b[17] & lv0_or[35]));
   assign lv1_enc7_b[18] = (~(lv1_inv_b[18] & lv0_or[37]));
   assign lv1_enc7_b[19] = (~(lv1_inv_b[19] & lv0_or[39]));
   assign lv1_enc7_b[20] = (~(lv1_inv_b[20] & lv0_or[41]));
   assign lv1_enc7_b[21] = (~(lv1_inv_b[21] & lv0_or[43]));
   assign lv1_enc7_b[22] = (~(lv1_inv_b[22] & lv0_or[45]));
   assign lv1_enc7_b[23] = (~(lv1_inv_b[23] & lv0_or[47]));
   assign lv1_enc7_b[24] = (~(lv1_inv_b[24] & lv0_or[49]));
   assign lv1_enc7_b[25] = (~(lv1_inv_b[25] & lv0_or[51]));
   assign lv1_enc7_b[26] = (~(lv1_inv_b[26] & lv0_or[53]));
   assign lv1_enc7_b[27] = (~(lv1_inv_b[27] & lv0_or[55]));
   assign lv1_enc7_b[28] = (~(lv1_inv_b[28] & lv0_or[57]));
   assign lv1_enc7_b[29] = (~(lv1_inv_b[29] & lv0_or[59]));
   assign lv1_enc7_b[30] = (~(lv1_inv_b[30] & lv0_or[61]));
   assign lv1_enc7_b[31] = (~(lv1_inv_b[31] & lv0_or[63]));
   assign lv1_enc7_b[32] = (~(lv1_inv_b[32] & lv0_or[65]));
   assign lv1_enc7_b[33] = (~(lv1_inv_b[33] & lv0_or[67]));
   assign lv1_enc7_b[34] = (~(lv1_inv_b[34] & lv0_or[69]));
   assign lv1_enc7_b[35] = (~(lv1_inv_b[35] & lv0_or[71]));
   assign lv1_enc7_b[36] = (~(lv1_inv_b[36] & lv0_or[73]));
   assign lv1_enc7_b[37] = (~(lv1_inv_b[37] & lv0_or[75]));
   assign lv1_enc7_b[38] = (~(lv1_inv_b[38] & lv0_or[77]));
   assign lv1_enc7_b[39] = (~(lv1_inv_b[39] & lv0_or[79]));
   assign lv1_enc7_b[40] = (~(lv1_inv_b[40] & lv0_or[81]));
   assign lv1_enc7_b[41] = (~(lv1_inv_b[41] & lv0_or[83]));
   assign lv1_enc7_b[42] = (~(lv1_inv_b[42] & lv0_or[85]));
   assign lv1_enc7_b[43] = (~(lv1_inv_b[43] & lv0_or[87]));
   assign lv1_enc7_b[44] = (~(lv1_inv_b[44] & lv0_or[89]));
   assign lv1_enc7_b[45] = (~(lv1_inv_b[45] & lv0_or[91]));
   assign lv1_enc7_b[46] = (~(lv1_inv_b[46] & lv0_or[93]));
   assign lv1_enc7_b[47] = (~(lv1_inv_b[47] & lv0_or[95]));
   assign lv1_enc7_b[48] = (~(lv1_inv_b[48] & lv0_or[97]));
   assign lv1_enc7_b[49] = (~(lv1_inv_b[49] & lv0_or[99]));
   assign lv1_enc7_b[50] = (~(lv1_inv_b[50] & lv0_or[101]));
   assign lv1_enc7_b[51] = (~(lv1_inv_b[51] & lv0_or[103]));
   assign lv1_enc7_b[52] = (~(lv1_inv_b[52] & lv0_or[105]));
   assign lv1_enc7_b[53] = (~(lv1_inv_b[53] & lv0_or[107]));
   assign lv1_enc7_b[54] = (~(lv1_inv_b[54] & lv0_or[109]));
   assign lv1_enc7_b[55] = (~(lv1_inv_b[55] & lv0_or[111]));
   assign lv1_enc7_b[56] = (~(lv1_inv_b[56] & lv0_or[113]));
   assign lv1_enc7_b[57] = (~(lv1_inv_b[57] & lv0_or[115]));
   assign lv1_enc7_b[58] = (~(lv1_inv_b[58] & lv0_or[117]));
   assign lv1_enc7_b[59] = (~(lv1_inv_b[59] & lv0_or[119]));
   assign lv1_enc7_b[60] = (~(lv1_inv_b[60] & lv0_or[121]));
   assign lv1_enc7_b[61] = (~(lv1_inv_b[61] & lv0_or[123]));
   assign lv1_enc7_b[62] = (~(lv1_inv_b[62] & lv0_or[125]));
   assign lv1_enc7_b[63] = (~(lv1_inv_b[63] & lv0_or[127]));
   assign lv1_enc7_b[64] = (~(lv1_inv_b[64] & lv0_or[129]));
   assign lv1_enc7_b[65] = (~(lv1_inv_b[65] & lv0_or[131]));
   assign lv1_enc7_b[66] = (~(lv1_inv_b[66] & lv0_or[133]));
   assign lv1_enc7_b[67] = (~(lv1_inv_b[67] & lv0_or[135]));
   assign lv1_enc7_b[68] = (~(lv1_inv_b[68] & lv0_or[137]));
   assign lv1_enc7_b[69] = (~(lv1_inv_b[69] & lv0_or[139]));
   assign lv1_enc7_b[70] = (~(lv1_inv_b[70] & lv0_or[141]));
   assign lv1_enc7_b[71] = (~(lv1_inv_b[71] & lv0_or[143]));
   assign lv1_enc7_b[72] = (~(lv1_inv_b[72] & lv0_or[145]));
   assign lv1_enc7_b[73] = (~(lv1_inv_b[73] & lv0_or[147]));
   assign lv1_enc7_b[74] = (~(lv1_inv_b[74] & lv0_or[149]));
   assign lv1_enc7_b[75] = (~(lv1_inv_b[75] & lv0_or[151]));
   assign lv1_enc7_b[76] = (~(lv1_inv_b[76] & lv0_or[153]));
   assign lv1_enc7_b[77] = (~(lv1_inv_b[77] & lv0_or[155]));
   assign lv1_enc7_b[78] = (~(lv1_inv_b[78] & lv0_or[157]));
   assign lv1_enc7_b[79] = (~(lv1_inv_b[79] & lv0_or[159]));
   assign lv1_enc7_b[80] = (~(lv1_inv_b[80] & lv0_or[161]));
   assign lv1_enc7_b[81] = (~(lv1_inv_b[81]));		//dflt1

   //--------------------------------------------------------------------------------
   // 004 bit group (phase_in=N, phase_out=P, level_in=lv1, level_out=lv2)
   //--------------------------------------------------------------------------------

   assign lv2_or[0] = (~(lv1_or_b[0] & lv1_or_b[1]));
   assign lv2_or[1] = (~(lv1_or_b[2] & lv1_or_b[3]));
   assign lv2_or[2] = (~(lv1_or_b[4] & lv1_or_b[5]));
   assign lv2_or[3] = (~(lv1_or_b[6] & lv1_or_b[7]));
   assign lv2_or[4] = (~(lv1_or_b[8] & lv1_or_b[9]));
   assign lv2_or[5] = (~(lv1_or_b[10] & lv1_or_b[11]));
   assign lv2_or[6] = (~(lv1_or_b[12] & lv1_or_b[13]));
   assign lv2_or[7] = (~(lv1_or_b[14] & lv1_or_b[15]));
   assign lv2_or[8] = (~(lv1_or_b[16] & lv1_or_b[17]));
   assign lv2_or[9] = (~(lv1_or_b[18] & lv1_or_b[19]));
   assign lv2_or[10] = (~(lv1_or_b[20] & lv1_or_b[21]));
   assign lv2_or[11] = (~(lv1_or_b[22] & lv1_or_b[23]));
   assign lv2_or[12] = (~(lv1_or_b[24] & lv1_or_b[25]));
   assign lv2_or[13] = (~(lv1_or_b[26] & lv1_or_b[27]));
   assign lv2_or[14] = (~(lv1_or_b[28] & lv1_or_b[29]));
   assign lv2_or[15] = (~(lv1_or_b[30] & lv1_or_b[31]));
   assign lv2_or[16] = (~(lv1_or_b[32] & lv1_or_b[33]));
   assign lv2_or[17] = (~(lv1_or_b[34] & lv1_or_b[35]));
   assign lv2_or[18] = (~(lv1_or_b[36] & lv1_or_b[37]));
   assign lv2_or[19] = (~(lv1_or_b[38] & lv1_or_b[39]));
   assign lv2_or[20] = (~(lv1_or_b[40] & lv1_or_b[41]));
   assign lv2_or[21] = (~(lv1_or_b[42] & lv1_or_b[43]));
   assign lv2_or[22] = (~(lv1_or_b[44] & lv1_or_b[45]));
   assign lv2_or[23] = (~(lv1_or_b[46] & lv1_or_b[47]));
   assign lv2_or[24] = (~(lv1_or_b[48] & lv1_or_b[49]));
   assign lv2_or[25] = (~(lv1_or_b[50] & lv1_or_b[51]));
   assign lv2_or[26] = (~(lv1_or_b[52] & lv1_or_b[53]));
   assign lv2_or[27] = (~(lv1_or_b[54] & lv1_or_b[55]));
   assign lv2_or[28] = (~(lv1_or_b[56] & lv1_or_b[57]));
   assign lv2_or[29] = (~(lv1_or_b[58] & lv1_or_b[59]));
   assign lv2_or[30] = (~(lv1_or_b[60] & lv1_or_b[61]));
   assign lv2_or[31] = (~(lv1_or_b[62] & lv1_or_b[63]));
   assign lv2_or[32] = (~(lv1_or_b[64] & lv1_or_b[65]));
   assign lv2_or[33] = (~(lv1_or_b[66] & lv1_or_b[67]));
   assign lv2_or[34] = (~(lv1_or_b[68] & lv1_or_b[69]));
   assign lv2_or[35] = (~(lv1_or_b[70] & lv1_or_b[71]));
   assign lv2_or[36] = (~(lv1_or_b[72] & lv1_or_b[73]));
   assign lv2_or[37] = (~(lv1_or_b[74] & lv1_or_b[75]));
   assign lv2_or[38] = (~(lv1_or_b[76] & lv1_or_b[77]));
   assign lv2_or[39] = (~(lv1_or_b[78] & lv1_or_b[79]));
   assign lv2_or[40] = (~(lv1_or_b[80] & lv1_or_b[81]));

   assign lv2_inv[0] = (~(lv1_or_b[0]));
   assign lv2_inv[1] = (~(lv1_or_b[2]));
   assign lv2_inv[2] = (~(lv1_or_b[4]));
   assign lv2_inv[3] = (~(lv1_or_b[6]));
   assign lv2_inv[4] = (~(lv1_or_b[8]));
   assign lv2_inv[5] = (~(lv1_or_b[10]));
   assign lv2_inv[6] = (~(lv1_or_b[12]));
   assign lv2_inv[7] = (~(lv1_or_b[14]));
   assign lv2_inv[8] = (~(lv1_or_b[16]));
   assign lv2_inv[9] = (~(lv1_or_b[18]));
   assign lv2_inv[10] = (~(lv1_or_b[20]));
   assign lv2_inv[11] = (~(lv1_or_b[22]));
   assign lv2_inv[12] = (~(lv1_or_b[24]));
   assign lv2_inv[13] = (~(lv1_or_b[26]));
   assign lv2_inv[14] = (~(lv1_or_b[28]));
   assign lv2_inv[15] = (~(lv1_or_b[30]));
   assign lv2_inv[16] = (~(lv1_or_b[32]));
   assign lv2_inv[17] = (~(lv1_or_b[34]));
   assign lv2_inv[18] = (~(lv1_or_b[36]));
   assign lv2_inv[19] = (~(lv1_or_b[38]));
   assign lv2_inv[20] = (~(lv1_or_b[40]));
   assign lv2_inv[21] = (~(lv1_or_b[42]));
   assign lv2_inv[22] = (~(lv1_or_b[44]));
   assign lv2_inv[23] = (~(lv1_or_b[46]));
   assign lv2_inv[24] = (~(lv1_or_b[48]));
   assign lv2_inv[25] = (~(lv1_or_b[50]));
   assign lv2_inv[26] = (~(lv1_or_b[52]));
   assign lv2_inv[27] = (~(lv1_or_b[54]));
   assign lv2_inv[28] = (~(lv1_or_b[56]));
   assign lv2_inv[29] = (~(lv1_or_b[58]));
   assign lv2_inv[30] = (~(lv1_or_b[60]));
   assign lv2_inv[31] = (~(lv1_or_b[62]));
   assign lv2_inv[32] = (~(lv1_or_b[64]));
   assign lv2_inv[33] = (~(lv1_or_b[66]));
   assign lv2_inv[34] = (~(lv1_or_b[68]));
   assign lv2_inv[35] = (~(lv1_or_b[70]));
   assign lv2_inv[36] = (~(lv1_or_b[72]));
   assign lv2_inv[37] = (~(lv1_or_b[74]));
   assign lv2_inv[38] = (~(lv1_or_b[76]));
   assign lv2_inv[39] = (~(lv1_or_b[78]));
   assign lv2_inv[40] = (~(lv1_or_b[80]));

   assign lv2_enc6[0] = (~(lv2_inv[0] | lv1_or_b[1]));
   assign lv2_enc6[1] = (~(lv2_inv[1] | lv1_or_b[3]));
   assign lv2_enc6[2] = (~(lv2_inv[2] | lv1_or_b[5]));
   assign lv2_enc6[3] = (~(lv2_inv[3] | lv1_or_b[7]));
   assign lv2_enc6[4] = (~(lv2_inv[4] | lv1_or_b[9]));
   assign lv2_enc6[5] = (~(lv2_inv[5] | lv1_or_b[11]));
   assign lv2_enc6[6] = (~(lv2_inv[6] | lv1_or_b[13]));
   assign lv2_enc6[7] = (~(lv2_inv[7] | lv1_or_b[15]));
   assign lv2_enc6[8] = (~(lv2_inv[8] | lv1_or_b[17]));
   assign lv2_enc6[9] = (~(lv2_inv[9] | lv1_or_b[19]));
   assign lv2_enc6[10] = (~(lv2_inv[10] | lv1_or_b[21]));
   assign lv2_enc6[11] = (~(lv2_inv[11] | lv1_or_b[23]));
   assign lv2_enc6[12] = (~(lv2_inv[12] | lv1_or_b[25]));
   assign lv2_enc6[13] = (~(lv2_inv[13] | lv1_or_b[27]));
   assign lv2_enc6[14] = (~(lv2_inv[14] | lv1_or_b[29]));
   assign lv2_enc6[15] = (~(lv2_inv[15] | lv1_or_b[31]));
   assign lv2_enc6[16] = (~(lv2_inv[16] | lv1_or_b[33]));
   assign lv2_enc6[17] = (~(lv2_inv[17] | lv1_or_b[35]));
   assign lv2_enc6[18] = (~(lv2_inv[18] | lv1_or_b[37]));
   assign lv2_enc6[19] = (~(lv2_inv[19] | lv1_or_b[39]));
   assign lv2_enc6[20] = (~(lv2_inv[20] | lv1_or_b[41]));
   assign lv2_enc6[21] = (~(lv2_inv[21] | lv1_or_b[43]));
   assign lv2_enc6[22] = (~(lv2_inv[22] | lv1_or_b[45]));
   assign lv2_enc6[23] = (~(lv2_inv[23] | lv1_or_b[47]));
   assign lv2_enc6[24] = (~(lv2_inv[24] | lv1_or_b[49]));
   assign lv2_enc6[25] = (~(lv2_inv[25] | lv1_or_b[51]));
   assign lv2_enc6[26] = (~(lv2_inv[26] | lv1_or_b[53]));
   assign lv2_enc6[27] = (~(lv2_inv[27] | lv1_or_b[55]));
   assign lv2_enc6[28] = (~(lv2_inv[28] | lv1_or_b[57]));
   assign lv2_enc6[29] = (~(lv2_inv[29] | lv1_or_b[59]));
   assign lv2_enc6[30] = (~(lv2_inv[30] | lv1_or_b[61]));
   assign lv2_enc6[31] = (~(lv2_inv[31] | lv1_or_b[63]));
   assign lv2_enc6[32] = (~(lv2_inv[32] | lv1_or_b[65]));
   assign lv2_enc6[33] = (~(lv2_inv[33] | lv1_or_b[67]));
   assign lv2_enc6[34] = (~(lv2_inv[34] | lv1_or_b[69]));
   assign lv2_enc6[35] = (~(lv2_inv[35] | lv1_or_b[71]));
   assign lv2_enc6[36] = (~(lv2_inv[36] | lv1_or_b[73]));
   assign lv2_enc6[37] = (~(lv2_inv[37] | lv1_or_b[75]));
   assign lv2_enc6[38] = (~(lv2_inv[38] | lv1_or_b[77]));
   assign lv2_enc6[39] = (~(lv2_inv[39] | lv1_or_b[79]));
   assign lv2_enc6[40] = (~(lv2_inv[40]));		//dflt1

   assign lv2_enc7[0] = (~(lv1_enc7_b[0] & (lv1_enc7_b[1] | lv2_inv[0])));
   assign lv2_enc7[1] = (~(lv1_enc7_b[2] & (lv1_enc7_b[3] | lv2_inv[1])));
   assign lv2_enc7[2] = (~(lv1_enc7_b[4] & (lv1_enc7_b[5] | lv2_inv[2])));
   assign lv2_enc7[3] = (~(lv1_enc7_b[6] & (lv1_enc7_b[7] | lv2_inv[3])));
   assign lv2_enc7[4] = (~(lv1_enc7_b[8] & (lv1_enc7_b[9] | lv2_inv[4])));
   assign lv2_enc7[5] = (~(lv1_enc7_b[10] & (lv1_enc7_b[11] | lv2_inv[5])));
   assign lv2_enc7[6] = (~(lv1_enc7_b[12] & (lv1_enc7_b[13] | lv2_inv[6])));
   assign lv2_enc7[7] = (~(lv1_enc7_b[14] & (lv1_enc7_b[15] | lv2_inv[7])));
   assign lv2_enc7[8] = (~(lv1_enc7_b[16] & (lv1_enc7_b[17] | lv2_inv[8])));
   assign lv2_enc7[9] = (~(lv1_enc7_b[18] & (lv1_enc7_b[19] | lv2_inv[9])));
   assign lv2_enc7[10] = (~(lv1_enc7_b[20] & (lv1_enc7_b[21] | lv2_inv[10])));
   assign lv2_enc7[11] = (~(lv1_enc7_b[22] & (lv1_enc7_b[23] | lv2_inv[11])));
   assign lv2_enc7[12] = (~(lv1_enc7_b[24] & (lv1_enc7_b[25] | lv2_inv[12])));
   assign lv2_enc7[13] = (~(lv1_enc7_b[26] & (lv1_enc7_b[27] | lv2_inv[13])));
   assign lv2_enc7[14] = (~(lv1_enc7_b[28] & (lv1_enc7_b[29] | lv2_inv[14])));
   assign lv2_enc7[15] = (~(lv1_enc7_b[30] & (lv1_enc7_b[31] | lv2_inv[15])));
   assign lv2_enc7[16] = (~(lv1_enc7_b[32] & (lv1_enc7_b[33] | lv2_inv[16])));
   assign lv2_enc7[17] = (~(lv1_enc7_b[34] & (lv1_enc7_b[35] | lv2_inv[17])));
   assign lv2_enc7[18] = (~(lv1_enc7_b[36] & (lv1_enc7_b[37] | lv2_inv[18])));
   assign lv2_enc7[19] = (~(lv1_enc7_b[38] & (lv1_enc7_b[39] | lv2_inv[19])));
   assign lv2_enc7[20] = (~(lv1_enc7_b[40] & (lv1_enc7_b[41] | lv2_inv[20])));
   assign lv2_enc7[21] = (~(lv1_enc7_b[42] & (lv1_enc7_b[43] | lv2_inv[21])));
   assign lv2_enc7[22] = (~(lv1_enc7_b[44] & (lv1_enc7_b[45] | lv2_inv[22])));
   assign lv2_enc7[23] = (~(lv1_enc7_b[46] & (lv1_enc7_b[47] | lv2_inv[23])));
   assign lv2_enc7[24] = (~(lv1_enc7_b[48] & (lv1_enc7_b[49] | lv2_inv[24])));
   assign lv2_enc7[25] = (~(lv1_enc7_b[50] & (lv1_enc7_b[51] | lv2_inv[25])));
   assign lv2_enc7[26] = (~(lv1_enc7_b[52] & (lv1_enc7_b[53] | lv2_inv[26])));
   assign lv2_enc7[27] = (~(lv1_enc7_b[54] & (lv1_enc7_b[55] | lv2_inv[27])));
   assign lv2_enc7[28] = (~(lv1_enc7_b[56] & (lv1_enc7_b[57] | lv2_inv[28])));
   assign lv2_enc7[29] = (~(lv1_enc7_b[58] & (lv1_enc7_b[59] | lv2_inv[29])));
   assign lv2_enc7[30] = (~(lv1_enc7_b[60] & (lv1_enc7_b[61] | lv2_inv[30])));
   assign lv2_enc7[31] = (~(lv1_enc7_b[62] & (lv1_enc7_b[63] | lv2_inv[31])));
   assign lv2_enc7[32] = (~(lv1_enc7_b[64] & (lv1_enc7_b[65] | lv2_inv[32])));
   assign lv2_enc7[33] = (~(lv1_enc7_b[66] & (lv1_enc7_b[67] | lv2_inv[33])));
   assign lv2_enc7[34] = (~(lv1_enc7_b[68] & (lv1_enc7_b[69] | lv2_inv[34])));
   assign lv2_enc7[35] = (~(lv1_enc7_b[70] & (lv1_enc7_b[71] | lv2_inv[35])));
   assign lv2_enc7[36] = (~(lv1_enc7_b[72] & (lv1_enc7_b[73] | lv2_inv[36])));
   assign lv2_enc7[37] = (~(lv1_enc7_b[74] & (lv1_enc7_b[75] | lv2_inv[37])));
   assign lv2_enc7[38] = (~(lv1_enc7_b[76] & (lv1_enc7_b[77] | lv2_inv[38])));
   assign lv2_enc7[39] = (~(lv1_enc7_b[78] & (lv1_enc7_b[79] | lv2_inv[39])));
   assign lv2_enc7[40] = (~(lv1_enc7_b[80] & (lv1_enc7_b[81] | lv2_inv[40])));

   //--------------------------------------------------------------------------------
   // 008 bit group (phase_in=P, phase_out=N, level_in=lv2, level_out=lv3)
   //--------------------------------------------------------------------------------

   assign lv3_or_b[0] = (~(lv2_or[0] | lv2_or[1]));
   assign lv3_or_b[1] = (~(lv2_or[2] | lv2_or[3]));
   assign lv3_or_b[2] = (~(lv2_or[4] | lv2_or[5]));
   assign lv3_or_b[3] = (~(lv2_or[6] | lv2_or[7]));
   assign lv3_or_b[4] = (~(lv2_or[8] | lv2_or[9]));
   assign lv3_or_b[5] = (~(lv2_or[10] | lv2_or[11]));
   assign lv3_or_b[6] = (~(lv2_or[12] | lv2_or[13]));
   assign lv3_or_b[7] = (~(lv2_or[14] | lv2_or[15]));
   assign lv3_or_b[8] = (~(lv2_or[16] | lv2_or[17]));
   assign lv3_or_b[9] = (~(lv2_or[18] | lv2_or[19]));
   assign lv3_or_b[10] = (~(lv2_or[20] | lv2_or[21]));
   assign lv3_or_b[11] = (~(lv2_or[22] | lv2_or[23]));
   assign lv3_or_b[12] = (~(lv2_or[24] | lv2_or[25]));
   assign lv3_or_b[13] = (~(lv2_or[26] | lv2_or[27]));
   assign lv3_or_b[14] = (~(lv2_or[28] | lv2_or[29]));
   assign lv3_or_b[15] = (~(lv2_or[30] | lv2_or[31]));
   assign lv3_or_b[16] = (~(lv2_or[32] | lv2_or[33]));
   assign lv3_or_b[17] = (~(lv2_or[34] | lv2_or[35]));
   assign lv3_or_b[18] = (~(lv2_or[36] | lv2_or[37]));
   assign lv3_or_b[19] = (~(lv2_or[38] | lv2_or[39]));
   assign lv3_or_b[20] = (~(lv2_or[40]));

   assign lv3_inv_b[0] = (~(lv2_or[0]));
   assign lv3_inv_b[1] = (~(lv2_or[2]));
   assign lv3_inv_b[2] = (~(lv2_or[4]));
   assign lv3_inv_b[3] = (~(lv2_or[6]));
   assign lv3_inv_b[4] = (~(lv2_or[8]));
   assign lv3_inv_b[5] = (~(lv2_or[10]));
   assign lv3_inv_b[6] = (~(lv2_or[12]));
   assign lv3_inv_b[7] = (~(lv2_or[14]));
   assign lv3_inv_b[8] = (~(lv2_or[16]));
   assign lv3_inv_b[9] = (~(lv2_or[18]));
   assign lv3_inv_b[10] = (~(lv2_or[20]));
   assign lv3_inv_b[11] = (~(lv2_or[22]));
   assign lv3_inv_b[12] = (~(lv2_or[24]));
   assign lv3_inv_b[13] = (~(lv2_or[26]));
   assign lv3_inv_b[14] = (~(lv2_or[28]));
   assign lv3_inv_b[15] = (~(lv2_or[30]));
   assign lv3_inv_b[16] = (~(lv2_or[32]));
   assign lv3_inv_b[17] = (~(lv2_or[34]));
   assign lv3_inv_b[18] = (~(lv2_or[36]));
   assign lv3_inv_b[19] = (~(lv2_or[38]));
   assign lv3_inv_b[20] = (~(lv2_or[40]));

   assign lv3_enc5_b[0] = (~(lv3_inv_b[0] & lv2_or[1]));
   assign lv3_enc5_b[1] = (~(lv3_inv_b[1] & lv2_or[3]));
   assign lv3_enc5_b[2] = (~(lv3_inv_b[2] & lv2_or[5]));
   assign lv3_enc5_b[3] = (~(lv3_inv_b[3] & lv2_or[7]));
   assign lv3_enc5_b[4] = (~(lv3_inv_b[4] & lv2_or[9]));
   assign lv3_enc5_b[5] = (~(lv3_inv_b[5] & lv2_or[11]));
   assign lv3_enc5_b[6] = (~(lv3_inv_b[6] & lv2_or[13]));
   assign lv3_enc5_b[7] = (~(lv3_inv_b[7] & lv2_or[15]));
   assign lv3_enc5_b[8] = (~(lv3_inv_b[8] & lv2_or[17]));
   assign lv3_enc5_b[9] = (~(lv3_inv_b[9] & lv2_or[19]));
   assign lv3_enc5_b[10] = (~(lv3_inv_b[10] & lv2_or[21]));
   assign lv3_enc5_b[11] = (~(lv3_inv_b[11] & lv2_or[23]));
   assign lv3_enc5_b[12] = (~(lv3_inv_b[12] & lv2_or[25]));
   assign lv3_enc5_b[13] = (~(lv3_inv_b[13] & lv2_or[27]));
   assign lv3_enc5_b[14] = (~(lv3_inv_b[14] & lv2_or[29]));
   assign lv3_enc5_b[15] = (~(lv3_inv_b[15] & lv2_or[31]));
   assign lv3_enc5_b[16] = (~(lv3_inv_b[16] & lv2_or[33]));
   assign lv3_enc5_b[17] = (~(lv3_inv_b[17] & lv2_or[35]));
   assign lv3_enc5_b[18] = (~(lv3_inv_b[18] & lv2_or[37]));
   assign lv3_enc5_b[19] = (~(lv3_inv_b[19] & lv2_or[39]));
   assign lv3_enc5_b[20] = tiup;		//dflt0

   assign lv3_enc6_b[0] = (~(lv2_enc6[0] | (lv2_enc6[1] & lv3_inv_b[0])));
   assign lv3_enc6_b[1] = (~(lv2_enc6[2] | (lv2_enc6[3] & lv3_inv_b[1])));
   assign lv3_enc6_b[2] = (~(lv2_enc6[4] | (lv2_enc6[5] & lv3_inv_b[2])));
   assign lv3_enc6_b[3] = (~(lv2_enc6[6] | (lv2_enc6[7] & lv3_inv_b[3])));
   assign lv3_enc6_b[4] = (~(lv2_enc6[8] | (lv2_enc6[9] & lv3_inv_b[4])));
   assign lv3_enc6_b[5] = (~(lv2_enc6[10] | (lv2_enc6[11] & lv3_inv_b[5])));
   assign lv3_enc6_b[6] = (~(lv2_enc6[12] | (lv2_enc6[13] & lv3_inv_b[6])));
   assign lv3_enc6_b[7] = (~(lv2_enc6[14] | (lv2_enc6[15] & lv3_inv_b[7])));
   assign lv3_enc6_b[8] = (~(lv2_enc6[16] | (lv2_enc6[17] & lv3_inv_b[8])));
   assign lv3_enc6_b[9] = (~(lv2_enc6[18] | (lv2_enc6[19] & lv3_inv_b[9])));
   assign lv3_enc6_b[10] = (~(lv2_enc6[20] | (lv2_enc6[21] & lv3_inv_b[10])));
   assign lv3_enc6_b[11] = (~(lv2_enc6[22] | (lv2_enc6[23] & lv3_inv_b[11])));
   assign lv3_enc6_b[12] = (~(lv2_enc6[24] | (lv2_enc6[25] & lv3_inv_b[12])));
   assign lv3_enc6_b[13] = (~(lv2_enc6[26] | (lv2_enc6[27] & lv3_inv_b[13])));
   assign lv3_enc6_b[14] = (~(lv2_enc6[28] | (lv2_enc6[29] & lv3_inv_b[14])));
   assign lv3_enc6_b[15] = (~(lv2_enc6[30] | (lv2_enc6[31] & lv3_inv_b[15])));
   assign lv3_enc6_b[16] = (~(lv2_enc6[32] | (lv2_enc6[33] & lv3_inv_b[16])));
   assign lv3_enc6_b[17] = (~(lv2_enc6[34] | (lv2_enc6[35] & lv3_inv_b[17])));
   assign lv3_enc6_b[18] = (~(lv2_enc6[36] | (lv2_enc6[37] & lv3_inv_b[18])));
   assign lv3_enc6_b[19] = (~(lv2_enc6[38] | (lv2_enc6[39] & lv3_inv_b[19])));
   assign lv3_enc6_b[20] = (~(lv2_enc6[40] | lv3_inv_b[20]));		//dflt1

   assign lv3_enc7_b[0] = (~(lv2_enc7[0] | (lv2_enc7[1] & lv3_inv_b[0])));
   assign lv3_enc7_b[1] = (~(lv2_enc7[2] | (lv2_enc7[3] & lv3_inv_b[1])));
   assign lv3_enc7_b[2] = (~(lv2_enc7[4] | (lv2_enc7[5] & lv3_inv_b[2])));
   assign lv3_enc7_b[3] = (~(lv2_enc7[6] | (lv2_enc7[7] & lv3_inv_b[3])));
   assign lv3_enc7_b[4] = (~(lv2_enc7[8] | (lv2_enc7[9] & lv3_inv_b[4])));
   assign lv3_enc7_b[5] = (~(lv2_enc7[10] | (lv2_enc7[11] & lv3_inv_b[5])));
   assign lv3_enc7_b[6] = (~(lv2_enc7[12] | (lv2_enc7[13] & lv3_inv_b[6])));
   assign lv3_enc7_b[7] = (~(lv2_enc7[14] | (lv2_enc7[15] & lv3_inv_b[7])));
   assign lv3_enc7_b[8] = (~(lv2_enc7[16] | (lv2_enc7[17] & lv3_inv_b[8])));
   assign lv3_enc7_b[9] = (~(lv2_enc7[18] | (lv2_enc7[19] & lv3_inv_b[9])));
   assign lv3_enc7_b[10] = (~(lv2_enc7[20] | (lv2_enc7[21] & lv3_inv_b[10])));
   assign lv3_enc7_b[11] = (~(lv2_enc7[22] | (lv2_enc7[23] & lv3_inv_b[11])));
   assign lv3_enc7_b[12] = (~(lv2_enc7[24] | (lv2_enc7[25] & lv3_inv_b[12])));
   assign lv3_enc7_b[13] = (~(lv2_enc7[26] | (lv2_enc7[27] & lv3_inv_b[13])));
   assign lv3_enc7_b[14] = (~(lv2_enc7[28] | (lv2_enc7[29] & lv3_inv_b[14])));
   assign lv3_enc7_b[15] = (~(lv2_enc7[30] | (lv2_enc7[31] & lv3_inv_b[15])));
   assign lv3_enc7_b[16] = (~(lv2_enc7[32] | (lv2_enc7[33] & lv3_inv_b[16])));
   assign lv3_enc7_b[17] = (~(lv2_enc7[34] | (lv2_enc7[35] & lv3_inv_b[17])));
   assign lv3_enc7_b[18] = (~(lv2_enc7[36] | (lv2_enc7[37] & lv3_inv_b[18])));
   assign lv3_enc7_b[19] = (~(lv2_enc7[38] | (lv2_enc7[39] & lv3_inv_b[19])));
   assign lv3_enc7_b[20] = (~(lv2_enc7[40] | lv3_inv_b[20]));		//dflt1

   //--------------------------------------------------------------------------------
   // 016 bit group (phase_in=N, phase_out=P, level_in=lv3, level_out=lv4)
   //--------------------------------------------------------------------------------

   assign lv4_or[0] = (~(lv3_or_b[0] & lv3_or_b[1]));
   assign lv4_or[1] = (~(lv3_or_b[2] & lv3_or_b[3]));
   assign lv4_or[2] = (~(lv3_or_b[4] & lv3_or_b[5]));
   assign lv4_or[3] = (~(lv3_or_b[6] & lv3_or_b[7]));
   assign lv4_or[4] = (~(lv3_or_b[8] & lv3_or_b[9]));
   assign lv4_or[5] = (~(lv3_or_b[10] & lv3_or_b[11]));
   assign lv4_or[6] = (~(lv3_or_b[12] & lv3_or_b[13]));
   assign lv4_or[7] = (~(lv3_or_b[14] & lv3_or_b[15]));
   assign lv4_or[8] = (~(lv3_or_b[16] & lv3_or_b[17]));
   assign lv4_or[9] = (~(lv3_or_b[18] & lv3_or_b[19]));
   assign lv4_or[10] = (~(lv3_or_b[20]));

   assign lv4_inv[0] = (~(lv3_or_b[0]));
   assign lv4_inv[1] = (~(lv3_or_b[2]));
   assign lv4_inv[2] = (~(lv3_or_b[4]));
   assign lv4_inv[3] = (~(lv3_or_b[6]));
   assign lv4_inv[4] = (~(lv3_or_b[8]));
   assign lv4_inv[5] = (~(lv3_or_b[10]));
   assign lv4_inv[6] = (~(lv3_or_b[12]));
   assign lv4_inv[7] = (~(lv3_or_b[14]));
   assign lv4_inv[8] = (~(lv3_or_b[16]));
   assign lv4_inv[9] = (~(lv3_or_b[18]));
   assign lv4_inv[10] = (~(lv3_or_b[20]));

   assign lv4_enc4[0] = (~(lv4_inv[0] | lv3_or_b[1]));
   assign lv4_enc4[1] = (~(lv4_inv[1] | lv3_or_b[3]));
   assign lv4_enc4[2] = (~(lv4_inv[2] | lv3_or_b[5]));
   assign lv4_enc4[3] = (~(lv4_inv[3] | lv3_or_b[7]));
   assign lv4_enc4[4] = (~(lv4_inv[4] | lv3_or_b[9]));
   assign lv4_enc4[5] = (~(lv4_inv[5] | lv3_or_b[11]));
   assign lv4_enc4[6] = (~(lv4_inv[6] | lv3_or_b[13]));
   assign lv4_enc4[7] = (~(lv4_inv[7] | lv3_or_b[15]));
   assign lv4_enc4[8] = (~(lv4_inv[8] | lv3_or_b[17]));
   assign lv4_enc4[9] = (~(lv4_inv[9] | lv3_or_b[19]));
   assign lv4_enc4[10] = tidn;		//dflt0

   assign lv4_enc5[0] = (~(lv3_enc5_b[0] & (lv3_enc5_b[1] | lv4_inv[0])));
   assign lv4_enc5[1] = (~(lv3_enc5_b[2] & (lv3_enc5_b[3] | lv4_inv[1])));
   assign lv4_enc5[2] = (~(lv3_enc5_b[4] & (lv3_enc5_b[5] | lv4_inv[2])));
   assign lv4_enc5[3] = (~(lv3_enc5_b[6] & (lv3_enc5_b[7] | lv4_inv[3])));
   assign lv4_enc5[4] = (~(lv3_enc5_b[8] & (lv3_enc5_b[9] | lv4_inv[4])));
   assign lv4_enc5[5] = (~(lv3_enc5_b[10] & (lv3_enc5_b[11] | lv4_inv[5])));
   assign lv4_enc5[6] = (~(lv3_enc5_b[12] & (lv3_enc5_b[13] | lv4_inv[6])));
   assign lv4_enc5[7] = (~(lv3_enc5_b[14] & (lv3_enc5_b[15] | lv4_inv[7])));
   assign lv4_enc5[8] = (~(lv3_enc5_b[16] & (lv3_enc5_b[17] | lv4_inv[8])));
   assign lv4_enc5[9] = (~(lv3_enc5_b[18] & (lv3_enc5_b[19] | lv4_inv[9])));
   assign lv4_enc5[10] = (~(lv3_enc5_b[20]));		//dflt0 pass

   assign lv4_enc6[0] = (~(lv3_enc6_b[0] & (lv3_enc6_b[1] | lv4_inv[0])));
   assign lv4_enc6[1] = (~(lv3_enc6_b[2] & (lv3_enc6_b[3] | lv4_inv[1])));
   assign lv4_enc6[2] = (~(lv3_enc6_b[4] & (lv3_enc6_b[5] | lv4_inv[2])));
   assign lv4_enc6[3] = (~(lv3_enc6_b[6] & (lv3_enc6_b[7] | lv4_inv[3])));
   assign lv4_enc6[4] = (~(lv3_enc6_b[8] & (lv3_enc6_b[9] | lv4_inv[4])));
   assign lv4_enc6[5] = (~(lv3_enc6_b[10] & (lv3_enc6_b[11] | lv4_inv[5])));
   assign lv4_enc6[6] = (~(lv3_enc6_b[12] & (lv3_enc6_b[13] | lv4_inv[6])));
   assign lv4_enc6[7] = (~(lv3_enc6_b[14] & (lv3_enc6_b[15] | lv4_inv[7])));
   assign lv4_enc6[8] = (~(lv3_enc6_b[16] & (lv3_enc6_b[17] | lv4_inv[8])));
   assign lv4_enc6[9] = (~(lv3_enc6_b[18] & (lv3_enc6_b[19] | lv4_inv[9])));
   assign lv4_enc6[10] = (~(lv3_enc6_b[20] & lv4_inv[10]));		//dflt1

   assign lv4_enc7[0] = (~(lv3_enc7_b[0] & (lv3_enc7_b[1] | lv4_inv[0])));
   assign lv4_enc7[1] = (~(lv3_enc7_b[2] & (lv3_enc7_b[3] | lv4_inv[1])));
   assign lv4_enc7[2] = (~(lv3_enc7_b[4] & (lv3_enc7_b[5] | lv4_inv[2])));
   assign lv4_enc7[3] = (~(lv3_enc7_b[6] & (lv3_enc7_b[7] | lv4_inv[3])));
   assign lv4_enc7[4] = (~(lv3_enc7_b[8] & (lv3_enc7_b[9] | lv4_inv[4])));
   assign lv4_enc7[5] = (~(lv3_enc7_b[10] & (lv3_enc7_b[11] | lv4_inv[5])));
   assign lv4_enc7[6] = (~(lv3_enc7_b[12] & (lv3_enc7_b[13] | lv4_inv[6])));
   assign lv4_enc7[7] = (~(lv3_enc7_b[14] & (lv3_enc7_b[15] | lv4_inv[7])));
   assign lv4_enc7[8] = (~(lv3_enc7_b[16] & (lv3_enc7_b[17] | lv4_inv[8])));
   assign lv4_enc7[9] = (~(lv3_enc7_b[18] & (lv3_enc7_b[19] | lv4_inv[9])));
   assign lv4_enc7[10] = (~(lv3_enc7_b[20] & lv4_inv[10]));		//dflt1

   assign lv4_or_b[0] = (~(lv4_or[0]));		//repower,long wire
   assign lv4_or_b[1] = (~(lv4_or[1]));		//repower,long wire
   assign lv4_or_b[2] = (~(lv4_or[2]));		//repower,long wire
   assign lv4_or_b[3] = (~(lv4_or[3]));		//repower,long wire
   assign lv4_or_b[4] = (~(lv4_or[4]));		//repower,long wire
   assign lv4_or_b[5] = (~(lv4_or[5]));		//repower,long wire
   assign lv4_or_b[6] = (~(lv4_or[6]));		//repower,long wire
   assign lv4_or_b[7] = (~(lv4_or[7]));		//repower,long wire
   assign lv4_or_b[8] = (~(lv4_or[8]));		//repower,long wire
   assign lv4_or_b[9] = (~(lv4_or[9]));		//repower,long wire
   assign lv4_or_b[10] = (~(lv4_or[10]));		//repower,long wire
   assign lv4_enc4_b[0] = (~(lv4_enc4[0]));		//repower,long wire
   assign lv4_enc4_b[1] = (~(lv4_enc4[1]));		//repower,long wire
   assign lv4_enc4_b[2] = (~(lv4_enc4[2]));		//repower,long wire
   assign lv4_enc4_b[3] = (~(lv4_enc4[3]));		//repower,long wire
   assign lv4_enc4_b[4] = (~(lv4_enc4[4]));		//repower,long wire
   assign lv4_enc4_b[5] = (~(lv4_enc4[5]));		//repower,long wire
   assign lv4_enc4_b[6] = (~(lv4_enc4[6]));		//repower,long wire
   assign lv4_enc4_b[7] = (~(lv4_enc4[7]));		//repower,long wire
   assign lv4_enc4_b[8] = (~(lv4_enc4[8]));		//repower,long wire
   assign lv4_enc4_b[9] = (~(lv4_enc4[9]));		//repower,long wire
   assign lv4_enc4_b[10] = (~(lv4_enc4[10]));		//repower,long wire
   assign lv4_enc5_b[0] = (~(lv4_enc5[0]));		//repower,long wire
   assign lv4_enc5_b[1] = (~(lv4_enc5[1]));		//repower,long wire
   assign lv4_enc5_b[2] = (~(lv4_enc5[2]));		//repower,long wire
   assign lv4_enc5_b[3] = (~(lv4_enc5[3]));		//repower,long wire
   assign lv4_enc5_b[4] = (~(lv4_enc5[4]));		//repower,long wire
   assign lv4_enc5_b[5] = (~(lv4_enc5[5]));		//repower,long wire
   assign lv4_enc5_b[6] = (~(lv4_enc5[6]));		//repower,long wire
   assign lv4_enc5_b[7] = (~(lv4_enc5[7]));		//repower,long wire
   assign lv4_enc5_b[8] = (~(lv4_enc5[8]));		//repower,long wire
   assign lv4_enc5_b[9] = (~(lv4_enc5[9]));		//repower,long wire
   assign lv4_enc5_b[10] = (~(lv4_enc5[10]));		//repower,long wire
   assign lv4_enc6_b[0] = (~(lv4_enc6[0]));		//repower,long wire
   assign lv4_enc6_b[1] = (~(lv4_enc6[1]));		//repower,long wire
   assign lv4_enc6_b[2] = (~(lv4_enc6[2]));		//repower,long wire
   assign lv4_enc6_b[3] = (~(lv4_enc6[3]));		//repower,long wire
   assign lv4_enc6_b[4] = (~(lv4_enc6[4]));		//repower,long wire
   assign lv4_enc6_b[5] = (~(lv4_enc6[5]));		//repower,long wire
   assign lv4_enc6_b[6] = (~(lv4_enc6[6]));		//repower,long wire
   assign lv4_enc6_b[7] = (~(lv4_enc6[7]));		//repower,long wire
   assign lv4_enc6_b[8] = (~(lv4_enc6[8]));		//repower,long wire
   assign lv4_enc6_b[9] = (~(lv4_enc6[9]));		//repower,long wire
   assign lv4_enc6_b[10] = (~(lv4_enc6[10]));		//repower,long wire
   assign lv4_enc7_b[0] = (~(lv4_enc7[0]));		//repower,long wire
   assign lv4_enc7_b[1] = (~(lv4_enc7[1]));		//repower,long wire
   assign lv4_enc7_b[2] = (~(lv4_enc7[2]));		//repower,long wire
   assign lv4_enc7_b[3] = (~(lv4_enc7[3]));		//repower,long wire
   assign lv4_enc7_b[4] = (~(lv4_enc7[4]));		//repower,long wire
   assign lv4_enc7_b[5] = (~(lv4_enc7[5]));		//repower,long wire
   assign lv4_enc7_b[6] = (~(lv4_enc7[6]));		//repower,long wire
   assign lv4_enc7_b[7] = (~(lv4_enc7[7]));		//repower,long wire
   assign lv4_enc7_b[8] = (~(lv4_enc7[8]));		//repower,long wire
   assign lv4_enc7_b[9] = (~(lv4_enc7[9]));		//repower,long wire
   assign lv4_enc7_b[10] = (~(lv4_enc7[10]));		//repower,long wire

   //--------------------------------------------------------------------------------
   // 032 bit group (phase_in=N, phase_out=P, level_in=lv4, level_out=lv5)
   //--------------------------------------------------------------------------------

   assign lv5_or[0] = (~(lv4_or_b[0] & lv4_or_b[1]));
   assign lv5_or[1] = (~(lv4_or_b[2] & lv4_or_b[3]));
   assign lv5_or[2] = (~(lv4_or_b[4] & lv4_or_b[5]));
   assign lv5_or[3] = (~(lv4_or_b[6] & lv4_or_b[7]));
   assign lv5_or[4] = (~(lv4_or_b[8] & lv4_or_b[9]));
   assign lv5_or[5] = (~(lv4_or_b[10]));

   assign lv5_inv[0] = (~(lv4_or_b[0]));
   assign lv5_inv[1] = (~(lv4_or_b[2]));
   assign lv5_inv[2] = (~(lv4_or_b[4]));
   assign lv5_inv[3] = (~(lv4_or_b[6]));
   assign lv5_inv[4] = (~(lv4_or_b[8]));
   assign lv5_inv[5] = (~(lv4_or_b[10]));

   assign lv5_enc3[0] = (~(lv5_inv[0] | lv4_or_b[1]));
   assign lv5_enc3[1] = (~(lv5_inv[1] | lv4_or_b[3]));
   assign lv5_enc3[2] = (~(lv5_inv[2] | lv4_or_b[5]));
   assign lv5_enc3[3] = (~(lv5_inv[3] | lv4_or_b[7]));
   assign lv5_enc3[4] = (~(lv5_inv[4] | lv4_or_b[9]));
   assign lv5_enc3[5] = tidn;		//dflt0

   assign lv5_enc4[0] = (~(lv4_enc4_b[0] & (lv4_enc4_b[1] | lv5_inv[0])));
   assign lv5_enc4[1] = (~(lv4_enc4_b[2] & (lv4_enc4_b[3] | lv5_inv[1])));
   assign lv5_enc4[2] = (~(lv4_enc4_b[4] & (lv4_enc4_b[5] | lv5_inv[2])));
   assign lv5_enc4[3] = (~(lv4_enc4_b[6] & (lv4_enc4_b[7] | lv5_inv[3])));
   assign lv5_enc4[4] = (~(lv4_enc4_b[8] & (lv4_enc4_b[9] | lv5_inv[4])));
   assign lv5_enc4[5] = (~(lv4_enc4_b[10]));		//dflt0 pass

   assign lv5_enc5[0] = (~(lv4_enc5_b[0] & (lv4_enc5_b[1] | lv5_inv[0])));
   assign lv5_enc5[1] = (~(lv4_enc5_b[2] & (lv4_enc5_b[3] | lv5_inv[1])));
   assign lv5_enc5[2] = (~(lv4_enc5_b[4] & (lv4_enc5_b[5] | lv5_inv[2])));
   assign lv5_enc5[3] = (~(lv4_enc5_b[6] & (lv4_enc5_b[7] | lv5_inv[3])));
   assign lv5_enc5[4] = (~(lv4_enc5_b[8] & (lv4_enc5_b[9] | lv5_inv[4])));
   assign lv5_enc5[5] = (~(lv4_enc5_b[10]));		//dflt0 pass

   assign lv5_enc6[0] = (~(lv4_enc6_b[0] & (lv4_enc6_b[1] | lv5_inv[0])));
   assign lv5_enc6[1] = (~(lv4_enc6_b[2] & (lv4_enc6_b[3] | lv5_inv[1])));
   assign lv5_enc6[2] = (~(lv4_enc6_b[4] & (lv4_enc6_b[5] | lv5_inv[2])));
   assign lv5_enc6[3] = (~(lv4_enc6_b[6] & (lv4_enc6_b[7] | lv5_inv[3])));
   assign lv5_enc6[4] = (~(lv4_enc6_b[8] & (lv4_enc6_b[9] | lv5_inv[4])));
   assign lv5_enc6[5] = (~(lv4_enc6_b[10] & lv5_inv[5]));		//dflt1

   assign lv5_enc7[0] = (~(lv4_enc7_b[0] & (lv4_enc7_b[1] | lv5_inv[0])));
   assign lv5_enc7[1] = (~(lv4_enc7_b[2] & (lv4_enc7_b[3] | lv5_inv[1])));
   assign lv5_enc7[2] = (~(lv4_enc7_b[4] & (lv4_enc7_b[5] | lv5_inv[2])));
   assign lv5_enc7[3] = (~(lv4_enc7_b[6] & (lv4_enc7_b[7] | lv5_inv[3])));
   assign lv5_enc7[4] = (~(lv4_enc7_b[8] & (lv4_enc7_b[9] | lv5_inv[4])));
   assign lv5_enc7[5] = (~(lv4_enc7_b[10] & lv5_inv[5]));		//dflt1

   //--------------------------------------------------------------------------------
   // 064 bit group (phase_in=P, phase_out=N, level_in=lv5, level_out=lv6)
   //--------------------------------------------------------------------------------

   assign lv6_or_0 = (~lv6_or_b[0]);
   assign lv6_or_1 = (~lv6_or_b[1]);

   assign lv6_or_b[0] = (~(lv5_or[0] | lv5_or[1]));
   assign lv6_or_b[1] = (~(lv5_or[2] | lv5_or[3]));
   assign lv6_or_b[2] = (~(lv5_or[4] | lv5_or[5]));

   assign lv6_inv_b[0] = (~(lv5_or[0]));
   assign lv6_inv_b[1] = (~(lv5_or[2]));
   assign lv6_inv_b[2] = (~(lv5_or[4]));

   assign lv6_enc2_b[0] = (~(lv6_inv_b[0] & lv5_or[1]));
   assign lv6_enc2_b[1] = (~(lv6_inv_b[1] & lv5_or[3]));
   assign lv6_enc2_b[2] = (~(lv6_inv_b[2]));		//dflt1

   assign lv6_enc3_b[0] = (~(lv5_enc3[0] | (lv5_enc3[1] & lv6_inv_b[0])));
   assign lv6_enc3_b[1] = (~(lv5_enc3[2] | (lv5_enc3[3] & lv6_inv_b[1])));
   assign lv6_enc3_b[2] = (~(lv5_enc3[4] | (lv5_enc3[5] & lv6_inv_b[2])));

   assign lv6_enc4_b[0] = (~(lv5_enc4[0] | (lv5_enc4[1] & lv6_inv_b[0])));
   assign lv6_enc4_b[1] = (~(lv5_enc4[2] | (lv5_enc4[3] & lv6_inv_b[1])));
   assign lv6_enc4_b[2] = (~(lv5_enc4[4] | (lv5_enc4[5] & lv6_inv_b[2])));

   assign lv6_enc5_b[0] = (~(lv5_enc5[0] | (lv5_enc5[1] & lv6_inv_b[0])));
   assign lv6_enc5_b[1] = (~(lv5_enc5[2] | (lv5_enc5[3] & lv6_inv_b[1])));
   assign lv6_enc5_b[2] = (~(lv5_enc5[4] | (lv5_enc5[5] & lv6_inv_b[2])));

   assign lv6_enc6_b[0] = (~(lv5_enc6[0] | (lv5_enc6[1] & lv6_inv_b[0])));
   assign lv6_enc6_b[1] = (~(lv5_enc6[2] | (lv5_enc6[3] & lv6_inv_b[1])));
   assign lv6_enc6_b[2] = (~(lv5_enc6[4] | (lv5_enc6[5] & lv6_inv_b[2])));

   assign lv6_enc7_b[0] = (~(lv5_enc7[0] | (lv5_enc7[1] & lv6_inv_b[0])));
   assign lv6_enc7_b[1] = (~(lv5_enc7[2] | (lv5_enc7[3] & lv6_inv_b[1])));
   assign lv6_enc7_b[2] = (~(lv5_enc7[4] | (lv5_enc7[5] & lv6_inv_b[2])));

   //--------------------------------------------------------------------------------
   // 128 bit group (phase_in=N, phase_out=P, level_in=lv6, level_out=lv7)
   //--------------------------------------------------------------------------------

   assign lv7_or[0] = (~(lv6_or_b[0] & lv6_or_b[1]));
   assign lv7_or[1] = (~(lv6_or_b[2]));

   assign lv7_inv[0] = (~(lv6_or_b[0]));
   assign lv7_inv[1] = (~(lv6_or_b[2]));

   assign lv7_enc1[0] = (~(lv7_inv[0] | lv6_or_b[1]));
   assign lv7_enc1[1] = tidn;		//dflt0

   assign lv7_enc2[0] = (~(lv6_enc2_b[0] & (lv6_enc2_b[1] | lv7_inv[0])));
   assign lv7_enc2[1] = (~(lv6_enc2_b[2] & lv7_inv[1]));		//dflt1

   assign lv7_enc3[0] = (~(lv6_enc3_b[0] & (lv6_enc3_b[1] | lv7_inv[0])));
   assign lv7_enc3[1] = (~(lv6_enc3_b[2]));		//dflt0 pass

   assign lv7_enc4[0] = (~(lv6_enc4_b[0] & (lv6_enc4_b[1] | lv7_inv[0])));
   assign lv7_enc4[1] = (~(lv6_enc4_b[2]));		//dflt0 pass

   assign lv7_enc5[0] = (~(lv6_enc5_b[0] & (lv6_enc5_b[1] | lv7_inv[0])));
   assign lv7_enc5[1] = (~(lv6_enc5_b[2]));		//dflt0 pass

   assign lv7_enc6[0] = (~(lv6_enc6_b[0] & (lv6_enc6_b[1] | lv7_inv[0])));
   assign lv7_enc6[1] = (~(lv6_enc6_b[2] & lv7_inv[1]));		//dflt1

   assign lv7_enc7[0] = (~(lv6_enc7_b[0] & (lv6_enc7_b[1] | lv7_inv[0])));
   assign lv7_enc7[1] = (~(lv6_enc7_b[2] & lv7_inv[1]));		//dflt1

   //--------------------------------------------------------------------------------
   // 256 bit group (phase_in=P, phase_out=N, level_in=lv7, level_out=lv8)
   //--------------------------------------------------------------------------------

   assign lv8_or_b[0] = (~(lv7_or[0] | lv7_or[1]));

   assign lv8_inv_b[0] = (~(lv7_or[0]));

   assign lv8_enc0_b[0] = (~(lv8_inv_b[0]));		//dflt1

   assign lv8_enc1_b[0] = (~(lv7_enc1[0] | (lv7_enc1[1] & lv8_inv_b[0])));

   assign lv8_enc2_b[0] = (~(lv7_enc2[0] | (lv7_enc2[1] & lv8_inv_b[0])));

   assign lv8_enc3_b[0] = (~(lv7_enc3[0] | (lv7_enc3[1] & lv8_inv_b[0])));

   assign lv8_enc4_b[0] = (~(lv7_enc4[0] | (lv7_enc4[1] & lv8_inv_b[0])));

   assign lv8_enc5_b[0] = (~(lv7_enc5[0] | (lv7_enc5[1] & lv8_inv_b[0])));

   assign lv8_enc6_b[0] = (~(lv7_enc6[0] | (lv7_enc6[1] & lv8_inv_b[0])));

   assign lv8_enc7_b[0] = (~(lv7_enc7[0] | (lv7_enc7[1] & lv8_inv_b[0])));

   assign lza_any_b = (lv8_or_b[0]);		//repower,long wire
   assign lza_amt_b[0] = (lv8_enc0_b[0]);		//repower,long wire
   assign lza_amt_b[1] = (lv8_enc1_b[0]);		//repower,long wire
   assign lza_amt_b[2] = (lv8_enc2_b[0]);		//repower,long wire
   assign lza_amt_b[3] = (lv8_enc3_b[0]);		//repower,long wire
   assign lza_amt_b[4] = (lv8_enc4_b[0]);		//repower,long wire
   assign lza_amt_b[5] = (lv8_enc5_b[0]);		//repower,long wire
   assign lza_amt_b[6] = (lv8_enc6_b[0]);		//repower,long wire
   assign lza_amt_b[7] = (lv8_enc7_b[0]);		//repower,long wire

endmodule
