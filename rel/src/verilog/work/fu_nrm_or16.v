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


module fu_nrm_or16(
   f_add_ex5_res,
   ex5_or_grp16
);
   input [0:162] f_add_ex5_res;
   output [0:10] ex5_or_grp16;

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire [0:162]  ex5_res_b;
   wire [0:3]    g00_or02;
   wire [0:7]    g01_or02;
   wire [0:7]    g02_or02;
   wire [0:7]    g03_or02;
   wire [0:7]    g04_or02;
   wire [0:7]    g05_or02;
   wire [0:7]    g06_or02;
   wire [0:7]    g07_or02;
   wire [0:7]    g08_or02;
   wire [0:7]    g09_or02;
   wire [0:5]    g10_or02;

   wire [0:1]    g00_or04_b;
   wire [0:3]    g01_or04_b;
   wire [0:3]    g02_or04_b;
   wire [0:3]    g03_or04_b;
   wire [0:3]    g04_or04_b;
   wire [0:3]    g05_or04_b;
   wire [0:3]    g06_or04_b;
   wire [0:3]    g07_or04_b;
   wire [0:3]    g08_or04_b;
   wire [0:3]    g09_or04_b;
   wire [0:2]    g10_or04_b;

   wire [0:0]    g00_or08;
   wire [0:1]    g01_or08;
   wire [0:1]    g02_or08;
   wire [0:1]    g03_or08;
   wire [0:1]    g04_or08;
   wire [0:1]    g05_or08;
   wire [0:1]    g06_or08;
   wire [0:1]    g07_or08;
   wire [0:1]    g08_or08;
   wire [0:1]    g09_or08;
   wire [0:1]    g10_or08;

   wire          g00_or16_b;
   wire          g01_or16_b;
   wire          g02_or16_b;
   wire          g03_or16_b;
   wire          g04_or16_b;
   wire          g05_or16_b;
   wire          g06_or16_b;
   wire          g07_or16_b;
   wire          g08_or16_b;
   wire          g09_or16_b;
   wire          g10_or16_b;

   //  ex5_or_grp16(0)  <=   0:  7
   //  ex5_or_grp16(1)  <=   8: 23
   //  ex5_or_grp16(2)  <=  24: 39
   //  ex5_or_grp16(3)  <=  40: 55
   //  ex5_or_grp16(4)  <=  56: 71
   //  ex5_or_grp16(5)  <=  72: 87
   //  ex5_or_grp16(6)  <=  88:103
   //  ex5_or_grp16(7)  <= 104:119
   //  ex5_or_grp16(8)  <= 120:135
   // ex5_or_grp16(9)  <= 136:151
   // ex5_or_grp16(10) <= 152:162

   //===============================================================--

   assign ex5_res_b[0:162] = (~f_add_ex5_res[0:162]);		// small

   //===============================================================--

   assign g00_or02[0] = (~(ex5_res_b[0] & ex5_res_b[1]));
   assign g00_or02[1] = (~(ex5_res_b[2] & ex5_res_b[3]));
   assign g00_or02[2] = (~(ex5_res_b[4] & ex5_res_b[5]));
   assign g00_or02[3] = (~(ex5_res_b[6] & ex5_res_b[7]));

   assign g01_or02[0] = (~(ex5_res_b[8] & ex5_res_b[9]));
   assign g01_or02[1] = (~(ex5_res_b[10] & ex5_res_b[11]));
   assign g01_or02[2] = (~(ex5_res_b[12] & ex5_res_b[13]));
   assign g01_or02[3] = (~(ex5_res_b[14] & ex5_res_b[15]));
   assign g01_or02[4] = (~(ex5_res_b[16] & ex5_res_b[17]));
   assign g01_or02[5] = (~(ex5_res_b[18] & ex5_res_b[19]));
   assign g01_or02[6] = (~(ex5_res_b[20] & ex5_res_b[21]));
   assign g01_or02[7] = (~(ex5_res_b[22] & ex5_res_b[23]));

   assign g02_or02[0] = (~(ex5_res_b[24] & ex5_res_b[25]));
   assign g02_or02[1] = (~(ex5_res_b[26] & ex5_res_b[27]));
   assign g02_or02[2] = (~(ex5_res_b[28] & ex5_res_b[29]));
   assign g02_or02[3] = (~(ex5_res_b[30] & ex5_res_b[31]));
   assign g02_or02[4] = (~(ex5_res_b[32] & ex5_res_b[33]));
   assign g02_or02[5] = (~(ex5_res_b[34] & ex5_res_b[35]));
   assign g02_or02[6] = (~(ex5_res_b[36] & ex5_res_b[37]));
   assign g02_or02[7] = (~(ex5_res_b[38] & ex5_res_b[39]));

   assign g03_or02[0] = (~(ex5_res_b[40] & ex5_res_b[41]));
   assign g03_or02[1] = (~(ex5_res_b[42] & ex5_res_b[43]));
   assign g03_or02[2] = (~(ex5_res_b[44] & ex5_res_b[45]));
   assign g03_or02[3] = (~(ex5_res_b[46] & ex5_res_b[47]));
   assign g03_or02[4] = (~(ex5_res_b[48] & ex5_res_b[49]));
   assign g03_or02[5] = (~(ex5_res_b[50] & ex5_res_b[51]));
   assign g03_or02[6] = (~(ex5_res_b[52] & ex5_res_b[53]));
   assign g03_or02[7] = (~(ex5_res_b[54] & ex5_res_b[55]));

   assign g04_or02[0] = (~(ex5_res_b[56] & ex5_res_b[57]));
   assign g04_or02[1] = (~(ex5_res_b[58] & ex5_res_b[59]));
   assign g04_or02[2] = (~(ex5_res_b[60] & ex5_res_b[61]));
   assign g04_or02[3] = (~(ex5_res_b[62] & ex5_res_b[63]));
   assign g04_or02[4] = (~(ex5_res_b[64] & ex5_res_b[65]));
   assign g04_or02[5] = (~(ex5_res_b[66] & ex5_res_b[67]));
   assign g04_or02[6] = (~(ex5_res_b[68] & ex5_res_b[69]));
   assign g04_or02[7] = (~(ex5_res_b[70] & ex5_res_b[71]));

   assign g05_or02[0] = (~(ex5_res_b[72] & ex5_res_b[73]));
   assign g05_or02[1] = (~(ex5_res_b[74] & ex5_res_b[75]));
   assign g05_or02[2] = (~(ex5_res_b[76] & ex5_res_b[77]));
   assign g05_or02[3] = (~(ex5_res_b[78] & ex5_res_b[79]));
   assign g05_or02[4] = (~(ex5_res_b[80] & ex5_res_b[81]));
   assign g05_or02[5] = (~(ex5_res_b[82] & ex5_res_b[83]));
   assign g05_or02[6] = (~(ex5_res_b[84] & ex5_res_b[85]));
   assign g05_or02[7] = (~(ex5_res_b[86] & ex5_res_b[87]));

   assign g06_or02[0] = (~(ex5_res_b[88] & ex5_res_b[89]));
   assign g06_or02[1] = (~(ex5_res_b[90] & ex5_res_b[91]));
   assign g06_or02[2] = (~(ex5_res_b[92] & ex5_res_b[93]));
   assign g06_or02[3] = (~(ex5_res_b[94] & ex5_res_b[95]));
   assign g06_or02[4] = (~(ex5_res_b[96] & ex5_res_b[97]));
   assign g06_or02[5] = (~(ex5_res_b[98] & ex5_res_b[99]));
   assign g06_or02[6] = (~(ex5_res_b[100] & ex5_res_b[101]));
   assign g06_or02[7] = (~(ex5_res_b[102] & ex5_res_b[103]));

   assign g07_or02[0] = (~(ex5_res_b[104] & ex5_res_b[105]));
   assign g07_or02[1] = (~(ex5_res_b[106] & ex5_res_b[107]));
   assign g07_or02[2] = (~(ex5_res_b[108] & ex5_res_b[109]));
   assign g07_or02[3] = (~(ex5_res_b[110] & ex5_res_b[111]));
   assign g07_or02[4] = (~(ex5_res_b[112] & ex5_res_b[113]));
   assign g07_or02[5] = (~(ex5_res_b[114] & ex5_res_b[115]));
   assign g07_or02[6] = (~(ex5_res_b[116] & ex5_res_b[117]));
   assign g07_or02[7] = (~(ex5_res_b[118] & ex5_res_b[119]));

   assign g08_or02[0] = (~(ex5_res_b[120] & ex5_res_b[121]));
   assign g08_or02[1] = (~(ex5_res_b[122] & ex5_res_b[123]));
   assign g08_or02[2] = (~(ex5_res_b[124] & ex5_res_b[125]));
   assign g08_or02[3] = (~(ex5_res_b[126] & ex5_res_b[127]));
   assign g08_or02[4] = (~(ex5_res_b[128] & ex5_res_b[129]));
   assign g08_or02[5] = (~(ex5_res_b[130] & ex5_res_b[131]));
   assign g08_or02[6] = (~(ex5_res_b[132] & ex5_res_b[133]));
   assign g08_or02[7] = (~(ex5_res_b[134] & ex5_res_b[135]));

   assign g09_or02[0] = (~(ex5_res_b[136] & ex5_res_b[137]));
   assign g09_or02[1] = (~(ex5_res_b[138] & ex5_res_b[139]));
   assign g09_or02[2] = (~(ex5_res_b[140] & ex5_res_b[141]));
   assign g09_or02[3] = (~(ex5_res_b[142] & ex5_res_b[143]));
   assign g09_or02[4] = (~(ex5_res_b[144] & ex5_res_b[145]));
   assign g09_or02[5] = (~(ex5_res_b[146] & ex5_res_b[147]));
   assign g09_or02[6] = (~(ex5_res_b[148] & ex5_res_b[149]));
   assign g09_or02[7] = (~(ex5_res_b[150] & ex5_res_b[151]));

   assign g10_or02[0] = (~(ex5_res_b[152] & ex5_res_b[153]));
   assign g10_or02[1] = (~(ex5_res_b[154] & ex5_res_b[155]));
   assign g10_or02[2] = (~(ex5_res_b[156] & ex5_res_b[157]));
   assign g10_or02[3] = (~(ex5_res_b[158] & ex5_res_b[159]));
   assign g10_or02[4] = (~(ex5_res_b[160] & ex5_res_b[161]));
   assign g10_or02[5] = (~(ex5_res_b[162]));

   //===============================================================--

   assign g00_or04_b[0] = (~(g00_or02[0] | g00_or02[1]));
   assign g00_or04_b[1] = (~(g00_or02[2] | g00_or02[3]));

   assign g01_or04_b[0] = (~(g01_or02[0] | g01_or02[1]));
   assign g01_or04_b[1] = (~(g01_or02[2] | g01_or02[3]));
   assign g01_or04_b[2] = (~(g01_or02[4] | g01_or02[5]));
   assign g01_or04_b[3] = (~(g01_or02[6] | g01_or02[7]));

   assign g02_or04_b[0] = (~(g02_or02[0] | g02_or02[1]));
   assign g02_or04_b[1] = (~(g02_or02[2] | g02_or02[3]));
   assign g02_or04_b[2] = (~(g02_or02[4] | g02_or02[5]));
   assign g02_or04_b[3] = (~(g02_or02[6] | g02_or02[7]));

   assign g03_or04_b[0] = (~(g03_or02[0] | g03_or02[1]));
   assign g03_or04_b[1] = (~(g03_or02[2] | g03_or02[3]));
   assign g03_or04_b[2] = (~(g03_or02[4] | g03_or02[5]));
   assign g03_or04_b[3] = (~(g03_or02[6] | g03_or02[7]));

   assign g04_or04_b[0] = (~(g04_or02[0] | g04_or02[1]));
   assign g04_or04_b[1] = (~(g04_or02[2] | g04_or02[3]));
   assign g04_or04_b[2] = (~(g04_or02[4] | g04_or02[5]));
   assign g04_or04_b[3] = (~(g04_or02[6] | g04_or02[7]));

   assign g05_or04_b[0] = (~(g05_or02[0] | g05_or02[1]));
   assign g05_or04_b[1] = (~(g05_or02[2] | g05_or02[3]));
   assign g05_or04_b[2] = (~(g05_or02[4] | g05_or02[5]));
   assign g05_or04_b[3] = (~(g05_or02[6] | g05_or02[7]));

   assign g06_or04_b[0] = (~(g06_or02[0] | g06_or02[1]));
   assign g06_or04_b[1] = (~(g06_or02[2] | g06_or02[3]));
   assign g06_or04_b[2] = (~(g06_or02[4] | g06_or02[5]));
   assign g06_or04_b[3] = (~(g06_or02[6] | g06_or02[7]));

   assign g07_or04_b[0] = (~(g07_or02[0] | g07_or02[1]));
   assign g07_or04_b[1] = (~(g07_or02[2] | g07_or02[3]));
   assign g07_or04_b[2] = (~(g07_or02[4] | g07_or02[5]));
   assign g07_or04_b[3] = (~(g07_or02[6] | g07_or02[7]));

   assign g08_or04_b[0] = (~(g08_or02[0] | g08_or02[1]));
   assign g08_or04_b[1] = (~(g08_or02[2] | g08_or02[3]));
   assign g08_or04_b[2] = (~(g08_or02[4] | g08_or02[5]));
   assign g08_or04_b[3] = (~(g08_or02[6] | g08_or02[7]));

   assign g09_or04_b[0] = (~(g09_or02[0] | g09_or02[1]));
   assign g09_or04_b[1] = (~(g09_or02[2] | g09_or02[3]));
   assign g09_or04_b[2] = (~(g09_or02[4] | g09_or02[5]));
   assign g09_or04_b[3] = (~(g09_or02[6] | g09_or02[7]));

   assign g10_or04_b[0] = (~(g10_or02[0] | g10_or02[1]));
   assign g10_or04_b[1] = (~(g10_or02[2] | g10_or02[3]));
   assign g10_or04_b[2] = (~(g10_or02[4] | g10_or02[5]));

   //===============================================================--

   assign g00_or08[0] = (~(g00_or04_b[0] & g00_or04_b[1]));

   assign g01_or08[0] = (~(g01_or04_b[0] & g01_or04_b[1]));
   assign g01_or08[1] = (~(g01_or04_b[2] & g01_or04_b[3]));

   assign g02_or08[0] = (~(g02_or04_b[0] & g02_or04_b[1]));
   assign g02_or08[1] = (~(g02_or04_b[2] & g02_or04_b[3]));

   assign g03_or08[0] = (~(g03_or04_b[0] & g03_or04_b[1]));
   assign g03_or08[1] = (~(g03_or04_b[2] & g03_or04_b[3]));

   assign g04_or08[0] = (~(g04_or04_b[0] & g04_or04_b[1]));
   assign g04_or08[1] = (~(g04_or04_b[2] & g04_or04_b[3]));

   assign g05_or08[0] = (~(g05_or04_b[0] & g05_or04_b[1]));
   assign g05_or08[1] = (~(g05_or04_b[2] & g05_or04_b[3]));

   assign g06_or08[0] = (~(g06_or04_b[0] & g06_or04_b[1]));
   assign g06_or08[1] = (~(g06_or04_b[2] & g06_or04_b[3]));

   assign g07_or08[0] = (~(g07_or04_b[0] & g07_or04_b[1]));
   assign g07_or08[1] = (~(g07_or04_b[2] & g07_or04_b[3]));

   assign g08_or08[0] = (~(g08_or04_b[0] & g08_or04_b[1]));
   assign g08_or08[1] = (~(g08_or04_b[2] & g08_or04_b[3]));

   assign g09_or08[0] = (~(g09_or04_b[0] & g09_or04_b[1]));
   assign g09_or08[1] = (~(g09_or04_b[2] & g09_or04_b[3]));

   assign g10_or08[0] = (~(g10_or04_b[0] & g10_or04_b[1]));
   assign g10_or08[1] = (~(g10_or04_b[2]));

   //===============================================================--

   assign g00_or16_b = (~(g00_or08[0]));
   assign g01_or16_b = (~(g01_or08[0] | g01_or08[1]));
   assign g02_or16_b = (~(g02_or08[0] | g02_or08[1]));
   assign g03_or16_b = (~(g03_or08[0] | g03_or08[1]));
   assign g04_or16_b = (~(g04_or08[0] | g04_or08[1]));
   assign g05_or16_b = (~(g05_or08[0] | g05_or08[1]));
   assign g06_or16_b = (~(g06_or08[0] | g06_or08[1]));
   assign g07_or16_b = (~(g07_or08[0] | g07_or08[1]));
   assign g08_or16_b = (~(g08_or08[0] | g08_or08[1]));
   assign g09_or16_b = (~(g09_or08[0] | g09_or08[1]));
   assign g10_or16_b = (~(g10_or08[0] | g10_or08[1]));

   //===============================================================--

   ///////////////////////////////////////////////////////////--

   assign ex5_or_grp16[0] = (~(g00_or16_b));		//output--
   assign ex5_or_grp16[1] = (~(g01_or16_b));		//output--
   assign ex5_or_grp16[2] = (~(g02_or16_b));		//output--
   assign ex5_or_grp16[3] = (~(g03_or16_b));		//output--
   assign ex5_or_grp16[4] = (~(g04_or16_b));		//output--
   assign ex5_or_grp16[5] = (~(g05_or16_b));		//output--
   assign ex5_or_grp16[6] = (~(g06_or16_b));		//output--
   assign ex5_or_grp16[7] = (~(g07_or16_b));		//output--
   assign ex5_or_grp16[8] = (~(g08_or16_b));		//output--
   assign ex5_or_grp16[9] = (~(g09_or16_b));		//output--
   assign ex5_or_grp16[10] = (~(g10_or16_b));		//output--

endmodule
