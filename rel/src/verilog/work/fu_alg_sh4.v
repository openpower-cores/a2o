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

module fu_alg_sh4(
   ex2_lvl1_shdcd000_b,
   ex2_lvl1_shdcd001_b,
   ex2_lvl1_shdcd002_b,
   ex2_lvl1_shdcd003_b,
   ex2_lvl2_shdcd000,
   ex2_lvl2_shdcd004,
   ex2_lvl2_shdcd008,
   ex2_lvl2_shdcd012,
   ex2_sel_special,
   ex2_b_sign,
   ex2_b_expo,
   ex2_b_frac,
   ex2_sh_lvl2
);
   //--------- SHIFT CONTROLS -----------------
   input         ex2_lvl1_shdcd000_b;
   input         ex2_lvl1_shdcd001_b;
   input         ex2_lvl1_shdcd002_b;
   input         ex2_lvl1_shdcd003_b;
   input         ex2_lvl2_shdcd000;
   input         ex2_lvl2_shdcd004;
   input         ex2_lvl2_shdcd008;
   input         ex2_lvl2_shdcd012;
   input         ex2_sel_special;

   //--------- SHIFT DATA -----------------
   input         ex2_b_sign;
   input [3:13]  ex2_b_expo;
   input [0:52]  ex2_b_frac;

   //-------- SHIFT OUTPUT ---------------
   output [0:67] ex2_sh_lvl2;

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire [0:63]   ex2_special_fcfid;
   wire [0:55]   ex2_sh_lv1;
   wire [0:53]   ex2_sh_lv1x_b;
   wire [2:55]   ex2_sh_lv1y_b;
   wire [0:59]   ex2_sh_lv2x_b;
   wire [8:67]   ex2_sh_lv2y_b;
   wire [0:63]   ex2_sh_lv2z_b;

   // signal sh1v1dcd0_cp1_b  :std_ulogic;--decode signals
   wire          sh1v2dcd0_cp1;
   wire          sh1v3dcd0_cp1_b;
   wire          sh1v3dcd0_cp2_b;
   wire          sh1v4dcd0_cp1;
   wire          sh1v4dcd0_cp2;
   wire          sh1v4dcd0_cp3;
   wire          sh1v4dcd0_cp4;
   // signal sh1v1dcd1_cp1_b  :std_ulogic;
   wire          sh1v2dcd1_cp1;
   wire          sh1v3dcd1_cp1_b;
   wire          sh1v3dcd1_cp2_b;
   wire          sh1v4dcd1_cp1;
   wire          sh1v4dcd1_cp2;
   wire          sh1v4dcd1_cp3;
   wire          sh1v4dcd1_cp4;
   // signal sh1v1dcd2_cp1_b  :std_ulogic;
   wire          sh1v2dcd2_cp1;
   wire          sh1v3dcd2_cp1_b;
   wire          sh1v3dcd2_cp2_b;
   wire          sh1v4dcd2_cp1;
   wire          sh1v4dcd2_cp2;
   wire          sh1v4dcd2_cp3;
   wire          sh1v4dcd2_cp4;
   // signal sh1v1dcd3_cp1_b  :std_ulogic;
   wire          sh1v2dcd3_cp1;
   wire          sh1v3dcd3_cp1_b;
   wire          sh1v3dcd3_cp2_b;
   wire          sh1v4dcd3_cp1;
   wire          sh1v4dcd3_cp2;
   wire          sh1v4dcd3_cp3;
   wire          sh1v4dcd3_cp4;
   wire          sh2v1dcd00_cp1_b;
   wire          sh2v2dcd00_cp1;
   wire          sh2v3dcd00_cp1_b;
   wire          sh2v3dcd00_cp2_b;
   wire          sh2v4dcd00_cp1;
   wire          sh2v4dcd00_cp2;
   wire          sh2v4dcd00_cp3;
   wire          sh2v4dcd00_cp4;
   wire          sh2v1dcd04_cp1_b;
   wire          sh2v2dcd04_cp1;
   wire          sh2v3dcd04_cp1_b;
   wire          sh2v3dcd04_cp2_b;
   wire          sh2v4dcd04_cp1;
   wire          sh2v4dcd04_cp2;
   wire          sh2v4dcd04_cp3;
   wire          sh2v4dcd04_cp4;
   wire          sh2v1dcd08_cp1_b;
   wire          sh2v2dcd08_cp1;
   wire          sh2v3dcd08_cp1_b;
   wire          sh2v3dcd08_cp2_b;
   wire          sh2v4dcd08_cp1;
   wire          sh2v4dcd08_cp2;
   wire          sh2v4dcd08_cp3;
   wire          sh2v4dcd08_cp4;
   wire          sh2v1dcd12_cp1_b;
   wire          sh2v2dcd12_cp1;
   wire          sh2v3dcd12_cp1_b;
   wire          sh2v3dcd12_cp2_b;
   wire          sh2v4dcd12_cp1;
   wire          sh2v4dcd12_cp2;
   wire          sh2v4dcd12_cp3;
   wire          sh2v4dcd12_cp4;
   wire          sh2v1dcdpp_cp1_b;
   wire          sh2v2dcdpp_cp1;
   wire          sh2v3dcdpp_cp1_b;
   wire          sh2v3dcdpp_cp2_b;
   wire          sh2v4dcdpp_cp1;
   wire          sh2v4dcdpp_cp2;
   wire          sh2v4dcdpp_cp3;
   wire          sh2v4dcdpp_cp4;



   //#-------------------------------------------------
   //# adjust B for fcfid specials
   //#-------------------------------------------------
   // if implicit bit is off: exponent should be 0 instead of x001, x381 (1/897)
   // frac(0) is the implicit bit.
   // 0_0000_0000_0001    1
   // 0_0011_1000_0001  897

   assign ex2_special_fcfid[0] = ex2_b_sign;		// fcfid integer
   assign ex2_special_fcfid[1] = ex2_b_expo[3];
   assign ex2_special_fcfid[2] = ex2_b_expo[4] & ex2_b_frac[0];
   assign ex2_special_fcfid[3] = ex2_b_expo[5] & ex2_b_frac[0];
   assign ex2_special_fcfid[4] = ex2_b_expo[6] & ex2_b_frac[0];
   assign ex2_special_fcfid[5] = ex2_b_expo[7];
   assign ex2_special_fcfid[6] = ex2_b_expo[8];
   assign ex2_special_fcfid[7] = ex2_b_expo[9];
   assign ex2_special_fcfid[8] = ex2_b_expo[10];
   assign ex2_special_fcfid[9] = ex2_b_expo[11];
   assign ex2_special_fcfid[10] = ex2_b_expo[12];
   assign ex2_special_fcfid[11] = ex2_b_expo[13] & ex2_b_frac[0];
   assign ex2_special_fcfid[12:63] = ex2_b_frac[1:52];		// fcfid integer

   //#---------------------------------------
   //# repower the selects for sh 0/1/2/3
   //#---------------------------------------


   assign sh1v2dcd0_cp1 = (~ex2_lvl1_shdcd000_b);
   assign sh1v3dcd0_cp1_b = (~sh1v2dcd0_cp1);
   assign sh1v3dcd0_cp2_b = (~sh1v2dcd0_cp1);
   assign sh1v4dcd0_cp1 = (~sh1v3dcd0_cp1_b);		//drive 0:13
   assign sh1v4dcd0_cp2 = (~sh1v3dcd0_cp1_b);		//drive 14:27
   assign sh1v4dcd0_cp3 = (~sh1v3dcd0_cp2_b);		//drive 28:41
   assign sh1v4dcd0_cp4 = (~sh1v3dcd0_cp2_b);		//drive 42:55

   assign sh1v2dcd1_cp1 = (~ex2_lvl1_shdcd001_b);
   assign sh1v3dcd1_cp1_b = (~sh1v2dcd1_cp1);
   assign sh1v3dcd1_cp2_b = (~sh1v2dcd1_cp1);
   assign sh1v4dcd1_cp1 = (~sh1v3dcd1_cp1_b);		//drive 0:13
   assign sh1v4dcd1_cp2 = (~sh1v3dcd1_cp1_b);		//drive 14:27
   assign sh1v4dcd1_cp3 = (~sh1v3dcd1_cp2_b);		//drive 28:41
   assign sh1v4dcd1_cp4 = (~sh1v3dcd1_cp2_b);		//drive 42:55

   assign sh1v2dcd2_cp1 = (~ex2_lvl1_shdcd002_b);
   assign sh1v3dcd2_cp1_b = (~sh1v2dcd2_cp1);
   assign sh1v3dcd2_cp2_b = (~sh1v2dcd2_cp1);
   assign sh1v4dcd2_cp1 = (~sh1v3dcd2_cp1_b);		//drive 0:13
   assign sh1v4dcd2_cp2 = (~sh1v3dcd2_cp1_b);		//drive 14:27
   assign sh1v4dcd2_cp3 = (~sh1v3dcd2_cp2_b);		//drive 28:41
   assign sh1v4dcd2_cp4 = (~sh1v3dcd2_cp2_b);		//drive 42:55

   assign sh1v2dcd3_cp1 = (~ex2_lvl1_shdcd003_b);
   assign sh1v3dcd3_cp1_b = (~sh1v2dcd3_cp1);
   assign sh1v3dcd3_cp2_b = (~sh1v2dcd3_cp1);
   assign sh1v4dcd3_cp1 = (~sh1v3dcd3_cp1_b);		//drive 0:13
   assign sh1v4dcd3_cp2 = (~sh1v3dcd3_cp1_b);		//drive 14:27
   assign sh1v4dcd3_cp3 = (~sh1v3dcd3_cp2_b);		//drive 28:41
   assign sh1v4dcd3_cp4 = (~sh1v3dcd3_cp2_b);		//drive 42:55

   //#---------------------------------------
   //# repower the selects for sh 0/4/8/12
   //#---------------------------------------

   assign sh2v1dcd00_cp1_b = (~ex2_lvl2_shdcd000);
   assign sh2v2dcd00_cp1 = (~sh2v1dcd00_cp1_b);
   assign sh2v3dcd00_cp1_b = (~sh2v2dcd00_cp1);
   assign sh2v3dcd00_cp2_b = (~sh2v2dcd00_cp1);
   assign sh2v4dcd00_cp1 = (~sh2v3dcd00_cp1_b);		//drive 0:16
   assign sh2v4dcd00_cp2 = (~sh2v3dcd00_cp1_b);		//drive 17:33
   assign sh2v4dcd00_cp3 = (~sh2v3dcd00_cp2_b);		//drive 34:50
   assign sh2v4dcd00_cp4 = (~sh2v3dcd00_cp2_b);		//drive 57:67

   assign sh2v1dcd04_cp1_b = (~ex2_lvl2_shdcd004);
   assign sh2v2dcd04_cp1 = (~sh2v1dcd04_cp1_b);
   assign sh2v3dcd04_cp1_b = (~sh2v2dcd04_cp1);
   assign sh2v3dcd04_cp2_b = (~sh2v2dcd04_cp1);
   assign sh2v4dcd04_cp1 = (~sh2v3dcd04_cp1_b);		//drive 0:16
   assign sh2v4dcd04_cp2 = (~sh2v3dcd04_cp1_b);		//drive 17:33
   assign sh2v4dcd04_cp3 = (~sh2v3dcd04_cp2_b);		//drive 34:50
   assign sh2v4dcd04_cp4 = (~sh2v3dcd04_cp2_b);		//drive 57:67

   assign sh2v1dcd08_cp1_b = (~ex2_lvl2_shdcd008);
   assign sh2v2dcd08_cp1 = (~sh2v1dcd08_cp1_b);
   assign sh2v3dcd08_cp1_b = (~sh2v2dcd08_cp1);
   assign sh2v3dcd08_cp2_b = (~sh2v2dcd08_cp1);
   assign sh2v4dcd08_cp1 = (~sh2v3dcd08_cp1_b);		//drive 0:16
   assign sh2v4dcd08_cp2 = (~sh2v3dcd08_cp1_b);		//drive 17:33
   assign sh2v4dcd08_cp3 = (~sh2v3dcd08_cp2_b);		//drive 34:50
   assign sh2v4dcd08_cp4 = (~sh2v3dcd08_cp2_b);		//drive 57:67

   assign sh2v1dcd12_cp1_b = (~ex2_lvl2_shdcd012);
   assign sh2v2dcd12_cp1 = (~sh2v1dcd12_cp1_b);
   assign sh2v3dcd12_cp1_b = (~sh2v2dcd12_cp1);
   assign sh2v3dcd12_cp2_b = (~sh2v2dcd12_cp1);
   assign sh2v4dcd12_cp1 = (~sh2v3dcd12_cp1_b);		//drive 0:16
   assign sh2v4dcd12_cp2 = (~sh2v3dcd12_cp1_b);		//drive 17:33
   assign sh2v4dcd12_cp3 = (~sh2v3dcd12_cp2_b);		//drive 34:50
   assign sh2v4dcd12_cp4 = (~sh2v3dcd12_cp2_b);		//drive 57:67

   assign sh2v1dcdpp_cp1_b = (~ex2_sel_special);
   assign sh2v2dcdpp_cp1 = (~sh2v1dcdpp_cp1_b);
   assign sh2v3dcdpp_cp1_b = (~sh2v2dcdpp_cp1);
   assign sh2v3dcdpp_cp2_b = (~sh2v2dcdpp_cp1);
   assign sh2v4dcdpp_cp1 = (~sh2v3dcdpp_cp1_b);		//drive 0:16
   assign sh2v4dcdpp_cp2 = (~sh2v3dcdpp_cp1_b);		//drive 17:33
   assign sh2v4dcdpp_cp3 = (~sh2v3dcdpp_cp2_b);		//drive 34:50
   assign sh2v4dcdpp_cp4 = (~sh2v3dcdpp_cp2_b);		//drive 57:67

   //-------------------------------------

   assign ex2_sh_lv1x_b[0] = (~(sh1v4dcd0_cp1 & ex2_b_frac[0]));
   assign ex2_sh_lv1x_b[1] = (~((sh1v4dcd0_cp1 & ex2_b_frac[1]) | (sh1v4dcd1_cp1 & ex2_b_frac[0])));
   assign ex2_sh_lv1x_b[2] = (~((sh1v4dcd0_cp1 & ex2_b_frac[2]) | (sh1v4dcd1_cp1 & ex2_b_frac[1])));
   assign ex2_sh_lv1x_b[3] = (~((sh1v4dcd0_cp1 & ex2_b_frac[3]) | (sh1v4dcd1_cp1 & ex2_b_frac[2])));
   assign ex2_sh_lv1x_b[4] = (~((sh1v4dcd0_cp1 & ex2_b_frac[4]) | (sh1v4dcd1_cp1 & ex2_b_frac[3])));
   assign ex2_sh_lv1x_b[5] = (~((sh1v4dcd0_cp1 & ex2_b_frac[5]) | (sh1v4dcd1_cp1 & ex2_b_frac[4])));
   assign ex2_sh_lv1x_b[6] = (~((sh1v4dcd0_cp1 & ex2_b_frac[6]) | (sh1v4dcd1_cp1 & ex2_b_frac[5])));
   assign ex2_sh_lv1x_b[7] = (~((sh1v4dcd0_cp1 & ex2_b_frac[7]) | (sh1v4dcd1_cp1 & ex2_b_frac[6])));
   assign ex2_sh_lv1x_b[8] = (~((sh1v4dcd0_cp1 & ex2_b_frac[8]) | (sh1v4dcd1_cp1 & ex2_b_frac[7])));
   assign ex2_sh_lv1x_b[9] = (~((sh1v4dcd0_cp1 & ex2_b_frac[9]) | (sh1v4dcd1_cp1 & ex2_b_frac[8])));
   assign ex2_sh_lv1x_b[10] = (~((sh1v4dcd0_cp1 & ex2_b_frac[10]) | (sh1v4dcd1_cp1 & ex2_b_frac[9])));
   assign ex2_sh_lv1x_b[11] = (~((sh1v4dcd0_cp1 & ex2_b_frac[11]) | (sh1v4dcd1_cp1 & ex2_b_frac[10])));
   assign ex2_sh_lv1x_b[12] = (~((sh1v4dcd0_cp1 & ex2_b_frac[12]) | (sh1v4dcd1_cp1 & ex2_b_frac[11])));
   assign ex2_sh_lv1x_b[13] = (~((sh1v4dcd0_cp1 & ex2_b_frac[13]) | (sh1v4dcd1_cp1 & ex2_b_frac[12])));
   assign ex2_sh_lv1x_b[14] = (~((sh1v4dcd0_cp2 & ex2_b_frac[14]) | (sh1v4dcd1_cp2 & ex2_b_frac[13])));
   assign ex2_sh_lv1x_b[15] = (~((sh1v4dcd0_cp2 & ex2_b_frac[15]) | (sh1v4dcd1_cp2 & ex2_b_frac[14])));
   assign ex2_sh_lv1x_b[16] = (~((sh1v4dcd0_cp2 & ex2_b_frac[16]) | (sh1v4dcd1_cp2 & ex2_b_frac[15])));
   assign ex2_sh_lv1x_b[17] = (~((sh1v4dcd0_cp2 & ex2_b_frac[17]) | (sh1v4dcd1_cp2 & ex2_b_frac[16])));
   assign ex2_sh_lv1x_b[18] = (~((sh1v4dcd0_cp2 & ex2_b_frac[18]) | (sh1v4dcd1_cp2 & ex2_b_frac[17])));
   assign ex2_sh_lv1x_b[19] = (~((sh1v4dcd0_cp2 & ex2_b_frac[19]) | (sh1v4dcd1_cp2 & ex2_b_frac[18])));
   assign ex2_sh_lv1x_b[20] = (~((sh1v4dcd0_cp2 & ex2_b_frac[20]) | (sh1v4dcd1_cp2 & ex2_b_frac[19])));
   assign ex2_sh_lv1x_b[21] = (~((sh1v4dcd0_cp2 & ex2_b_frac[21]) | (sh1v4dcd1_cp2 & ex2_b_frac[20])));
   assign ex2_sh_lv1x_b[22] = (~((sh1v4dcd0_cp2 & ex2_b_frac[22]) | (sh1v4dcd1_cp2 & ex2_b_frac[21])));
   assign ex2_sh_lv1x_b[23] = (~((sh1v4dcd0_cp2 & ex2_b_frac[23]) | (sh1v4dcd1_cp2 & ex2_b_frac[22])));
   assign ex2_sh_lv1x_b[24] = (~((sh1v4dcd0_cp2 & ex2_b_frac[24]) | (sh1v4dcd1_cp2 & ex2_b_frac[23])));
   assign ex2_sh_lv1x_b[25] = (~((sh1v4dcd0_cp2 & ex2_b_frac[25]) | (sh1v4dcd1_cp2 & ex2_b_frac[24])));
   assign ex2_sh_lv1x_b[26] = (~((sh1v4dcd0_cp2 & ex2_b_frac[26]) | (sh1v4dcd1_cp2 & ex2_b_frac[25])));
   assign ex2_sh_lv1x_b[27] = (~((sh1v4dcd0_cp2 & ex2_b_frac[27]) | (sh1v4dcd1_cp2 & ex2_b_frac[26])));
   assign ex2_sh_lv1x_b[28] = (~((sh1v4dcd0_cp3 & ex2_b_frac[28]) | (sh1v4dcd1_cp3 & ex2_b_frac[27])));
   assign ex2_sh_lv1x_b[29] = (~((sh1v4dcd0_cp3 & ex2_b_frac[29]) | (sh1v4dcd1_cp3 & ex2_b_frac[28])));
   assign ex2_sh_lv1x_b[30] = (~((sh1v4dcd0_cp3 & ex2_b_frac[30]) | (sh1v4dcd1_cp3 & ex2_b_frac[29])));
   assign ex2_sh_lv1x_b[31] = (~((sh1v4dcd0_cp3 & ex2_b_frac[31]) | (sh1v4dcd1_cp3 & ex2_b_frac[30])));
   assign ex2_sh_lv1x_b[32] = (~((sh1v4dcd0_cp3 & ex2_b_frac[32]) | (sh1v4dcd1_cp3 & ex2_b_frac[31])));
   assign ex2_sh_lv1x_b[33] = (~((sh1v4dcd0_cp3 & ex2_b_frac[33]) | (sh1v4dcd1_cp3 & ex2_b_frac[32])));
   assign ex2_sh_lv1x_b[34] = (~((sh1v4dcd0_cp3 & ex2_b_frac[34]) | (sh1v4dcd1_cp3 & ex2_b_frac[33])));
   assign ex2_sh_lv1x_b[35] = (~((sh1v4dcd0_cp3 & ex2_b_frac[35]) | (sh1v4dcd1_cp3 & ex2_b_frac[34])));
   assign ex2_sh_lv1x_b[36] = (~((sh1v4dcd0_cp3 & ex2_b_frac[36]) | (sh1v4dcd1_cp3 & ex2_b_frac[35])));
   assign ex2_sh_lv1x_b[37] = (~((sh1v4dcd0_cp3 & ex2_b_frac[37]) | (sh1v4dcd1_cp3 & ex2_b_frac[36])));
   assign ex2_sh_lv1x_b[38] = (~((sh1v4dcd0_cp3 & ex2_b_frac[38]) | (sh1v4dcd1_cp3 & ex2_b_frac[37])));
   assign ex2_sh_lv1x_b[39] = (~((sh1v4dcd0_cp3 & ex2_b_frac[39]) | (sh1v4dcd1_cp3 & ex2_b_frac[38])));
   assign ex2_sh_lv1x_b[40] = (~((sh1v4dcd0_cp3 & ex2_b_frac[40]) | (sh1v4dcd1_cp3 & ex2_b_frac[39])));
   assign ex2_sh_lv1x_b[41] = (~((sh1v4dcd0_cp3 & ex2_b_frac[41]) | (sh1v4dcd1_cp3 & ex2_b_frac[40])));
   assign ex2_sh_lv1x_b[42] = (~((sh1v4dcd0_cp4 & ex2_b_frac[42]) | (sh1v4dcd1_cp4 & ex2_b_frac[41])));
   assign ex2_sh_lv1x_b[43] = (~((sh1v4dcd0_cp4 & ex2_b_frac[43]) | (sh1v4dcd1_cp4 & ex2_b_frac[42])));
   assign ex2_sh_lv1x_b[44] = (~((sh1v4dcd0_cp4 & ex2_b_frac[44]) | (sh1v4dcd1_cp4 & ex2_b_frac[43])));
   assign ex2_sh_lv1x_b[45] = (~((sh1v4dcd0_cp4 & ex2_b_frac[45]) | (sh1v4dcd1_cp4 & ex2_b_frac[44])));
   assign ex2_sh_lv1x_b[46] = (~((sh1v4dcd0_cp4 & ex2_b_frac[46]) | (sh1v4dcd1_cp4 & ex2_b_frac[45])));
   assign ex2_sh_lv1x_b[47] = (~((sh1v4dcd0_cp4 & ex2_b_frac[47]) | (sh1v4dcd1_cp4 & ex2_b_frac[46])));
   assign ex2_sh_lv1x_b[48] = (~((sh1v4dcd0_cp4 & ex2_b_frac[48]) | (sh1v4dcd1_cp4 & ex2_b_frac[47])));
   assign ex2_sh_lv1x_b[49] = (~((sh1v4dcd0_cp4 & ex2_b_frac[49]) | (sh1v4dcd1_cp4 & ex2_b_frac[48])));
   assign ex2_sh_lv1x_b[50] = (~((sh1v4dcd0_cp4 & ex2_b_frac[50]) | (sh1v4dcd1_cp4 & ex2_b_frac[49])));
   assign ex2_sh_lv1x_b[51] = (~((sh1v4dcd0_cp4 & ex2_b_frac[51]) | (sh1v4dcd1_cp4 & ex2_b_frac[50])));
   assign ex2_sh_lv1x_b[52] = (~((sh1v4dcd0_cp4 & ex2_b_frac[52]) | (sh1v4dcd1_cp4 & ex2_b_frac[51])));
   assign ex2_sh_lv1x_b[53] = (~(sh1v4dcd1_cp4 & ex2_b_frac[52]));

   assign ex2_sh_lv1y_b[2] = (~(sh1v4dcd2_cp1 & ex2_b_frac[0]));
   assign ex2_sh_lv1y_b[3] = (~((sh1v4dcd2_cp1 & ex2_b_frac[1]) | (sh1v4dcd3_cp1 & ex2_b_frac[0])));
   assign ex2_sh_lv1y_b[4] = (~((sh1v4dcd2_cp1 & ex2_b_frac[2]) | (sh1v4dcd3_cp1 & ex2_b_frac[1])));
   assign ex2_sh_lv1y_b[5] = (~((sh1v4dcd2_cp1 & ex2_b_frac[3]) | (sh1v4dcd3_cp1 & ex2_b_frac[2])));
   assign ex2_sh_lv1y_b[6] = (~((sh1v4dcd2_cp1 & ex2_b_frac[4]) | (sh1v4dcd3_cp1 & ex2_b_frac[3])));
   assign ex2_sh_lv1y_b[7] = (~((sh1v4dcd2_cp1 & ex2_b_frac[5]) | (sh1v4dcd3_cp1 & ex2_b_frac[4])));
   assign ex2_sh_lv1y_b[8] = (~((sh1v4dcd2_cp1 & ex2_b_frac[6]) | (sh1v4dcd3_cp1 & ex2_b_frac[5])));
   assign ex2_sh_lv1y_b[9] = (~((sh1v4dcd2_cp1 & ex2_b_frac[7]) | (sh1v4dcd3_cp1 & ex2_b_frac[6])));
   assign ex2_sh_lv1y_b[10] = (~((sh1v4dcd2_cp1 & ex2_b_frac[8]) | (sh1v4dcd3_cp1 & ex2_b_frac[7])));
   assign ex2_sh_lv1y_b[11] = (~((sh1v4dcd2_cp1 & ex2_b_frac[9]) | (sh1v4dcd3_cp1 & ex2_b_frac[8])));
   assign ex2_sh_lv1y_b[12] = (~((sh1v4dcd2_cp1 & ex2_b_frac[10]) | (sh1v4dcd3_cp1 & ex2_b_frac[9])));
   assign ex2_sh_lv1y_b[13] = (~((sh1v4dcd2_cp1 & ex2_b_frac[11]) | (sh1v4dcd3_cp1 & ex2_b_frac[10])));
   assign ex2_sh_lv1y_b[14] = (~((sh1v4dcd2_cp2 & ex2_b_frac[12]) | (sh1v4dcd3_cp2 & ex2_b_frac[11])));
   assign ex2_sh_lv1y_b[15] = (~((sh1v4dcd2_cp2 & ex2_b_frac[13]) | (sh1v4dcd3_cp2 & ex2_b_frac[12])));
   assign ex2_sh_lv1y_b[16] = (~((sh1v4dcd2_cp2 & ex2_b_frac[14]) | (sh1v4dcd3_cp2 & ex2_b_frac[13])));
   assign ex2_sh_lv1y_b[17] = (~((sh1v4dcd2_cp2 & ex2_b_frac[15]) | (sh1v4dcd3_cp2 & ex2_b_frac[14])));
   assign ex2_sh_lv1y_b[18] = (~((sh1v4dcd2_cp2 & ex2_b_frac[16]) | (sh1v4dcd3_cp2 & ex2_b_frac[15])));
   assign ex2_sh_lv1y_b[19] = (~((sh1v4dcd2_cp2 & ex2_b_frac[17]) | (sh1v4dcd3_cp2 & ex2_b_frac[16])));
   assign ex2_sh_lv1y_b[20] = (~((sh1v4dcd2_cp2 & ex2_b_frac[18]) | (sh1v4dcd3_cp2 & ex2_b_frac[17])));
   assign ex2_sh_lv1y_b[21] = (~((sh1v4dcd2_cp2 & ex2_b_frac[19]) | (sh1v4dcd3_cp2 & ex2_b_frac[18])));
   assign ex2_sh_lv1y_b[22] = (~((sh1v4dcd2_cp2 & ex2_b_frac[20]) | (sh1v4dcd3_cp2 & ex2_b_frac[19])));
   assign ex2_sh_lv1y_b[23] = (~((sh1v4dcd2_cp2 & ex2_b_frac[21]) | (sh1v4dcd3_cp2 & ex2_b_frac[20])));
   assign ex2_sh_lv1y_b[24] = (~((sh1v4dcd2_cp2 & ex2_b_frac[22]) | (sh1v4dcd3_cp2 & ex2_b_frac[21])));
   assign ex2_sh_lv1y_b[25] = (~((sh1v4dcd2_cp2 & ex2_b_frac[23]) | (sh1v4dcd3_cp2 & ex2_b_frac[22])));
   assign ex2_sh_lv1y_b[26] = (~((sh1v4dcd2_cp2 & ex2_b_frac[24]) | (sh1v4dcd3_cp2 & ex2_b_frac[23])));
   assign ex2_sh_lv1y_b[27] = (~((sh1v4dcd2_cp2 & ex2_b_frac[25]) | (sh1v4dcd3_cp2 & ex2_b_frac[24])));
   assign ex2_sh_lv1y_b[28] = (~((sh1v4dcd2_cp3 & ex2_b_frac[26]) | (sh1v4dcd3_cp3 & ex2_b_frac[25])));
   assign ex2_sh_lv1y_b[29] = (~((sh1v4dcd2_cp3 & ex2_b_frac[27]) | (sh1v4dcd3_cp3 & ex2_b_frac[26])));
   assign ex2_sh_lv1y_b[30] = (~((sh1v4dcd2_cp3 & ex2_b_frac[28]) | (sh1v4dcd3_cp3 & ex2_b_frac[27])));
   assign ex2_sh_lv1y_b[31] = (~((sh1v4dcd2_cp3 & ex2_b_frac[29]) | (sh1v4dcd3_cp3 & ex2_b_frac[28])));
   assign ex2_sh_lv1y_b[32] = (~((sh1v4dcd2_cp3 & ex2_b_frac[30]) | (sh1v4dcd3_cp3 & ex2_b_frac[29])));
   assign ex2_sh_lv1y_b[33] = (~((sh1v4dcd2_cp3 & ex2_b_frac[31]) | (sh1v4dcd3_cp3 & ex2_b_frac[30])));
   assign ex2_sh_lv1y_b[34] = (~((sh1v4dcd2_cp3 & ex2_b_frac[32]) | (sh1v4dcd3_cp3 & ex2_b_frac[31])));
   assign ex2_sh_lv1y_b[35] = (~((sh1v4dcd2_cp3 & ex2_b_frac[33]) | (sh1v4dcd3_cp3 & ex2_b_frac[32])));
   assign ex2_sh_lv1y_b[36] = (~((sh1v4dcd2_cp3 & ex2_b_frac[34]) | (sh1v4dcd3_cp3 & ex2_b_frac[33])));
   assign ex2_sh_lv1y_b[37] = (~((sh1v4dcd2_cp3 & ex2_b_frac[35]) | (sh1v4dcd3_cp3 & ex2_b_frac[34])));
   assign ex2_sh_lv1y_b[38] = (~((sh1v4dcd2_cp3 & ex2_b_frac[36]) | (sh1v4dcd3_cp3 & ex2_b_frac[35])));
   assign ex2_sh_lv1y_b[39] = (~((sh1v4dcd2_cp3 & ex2_b_frac[37]) | (sh1v4dcd3_cp3 & ex2_b_frac[36])));
   assign ex2_sh_lv1y_b[40] = (~((sh1v4dcd2_cp3 & ex2_b_frac[38]) | (sh1v4dcd3_cp3 & ex2_b_frac[37])));
   assign ex2_sh_lv1y_b[41] = (~((sh1v4dcd2_cp4 & ex2_b_frac[39]) | (sh1v4dcd3_cp4 & ex2_b_frac[38])));
   assign ex2_sh_lv1y_b[42] = (~((sh1v4dcd2_cp4 & ex2_b_frac[40]) | (sh1v4dcd3_cp4 & ex2_b_frac[39])));
   assign ex2_sh_lv1y_b[43] = (~((sh1v4dcd2_cp4 & ex2_b_frac[41]) | (sh1v4dcd3_cp4 & ex2_b_frac[40])));
   assign ex2_sh_lv1y_b[44] = (~((sh1v4dcd2_cp4 & ex2_b_frac[42]) | (sh1v4dcd3_cp4 & ex2_b_frac[41])));
   assign ex2_sh_lv1y_b[45] = (~((sh1v4dcd2_cp4 & ex2_b_frac[43]) | (sh1v4dcd3_cp4 & ex2_b_frac[42])));
   assign ex2_sh_lv1y_b[46] = (~((sh1v4dcd2_cp4 & ex2_b_frac[44]) | (sh1v4dcd3_cp4 & ex2_b_frac[43])));
   assign ex2_sh_lv1y_b[47] = (~((sh1v4dcd2_cp4 & ex2_b_frac[45]) | (sh1v4dcd3_cp4 & ex2_b_frac[44])));
   assign ex2_sh_lv1y_b[48] = (~((sh1v4dcd2_cp4 & ex2_b_frac[46]) | (sh1v4dcd3_cp4 & ex2_b_frac[45])));
   assign ex2_sh_lv1y_b[49] = (~((sh1v4dcd2_cp4 & ex2_b_frac[47]) | (sh1v4dcd3_cp4 & ex2_b_frac[46])));
   assign ex2_sh_lv1y_b[50] = (~((sh1v4dcd2_cp4 & ex2_b_frac[48]) | (sh1v4dcd3_cp4 & ex2_b_frac[47])));
   assign ex2_sh_lv1y_b[51] = (~((sh1v4dcd2_cp4 & ex2_b_frac[49]) | (sh1v4dcd3_cp4 & ex2_b_frac[48])));
   assign ex2_sh_lv1y_b[52] = (~((sh1v4dcd2_cp4 & ex2_b_frac[50]) | (sh1v4dcd3_cp4 & ex2_b_frac[49])));
   assign ex2_sh_lv1y_b[53] = (~((sh1v4dcd2_cp4 & ex2_b_frac[51]) | (sh1v4dcd3_cp4 & ex2_b_frac[50])));
   assign ex2_sh_lv1y_b[54] = (~((sh1v4dcd2_cp4 & ex2_b_frac[52]) | (sh1v4dcd3_cp4 & ex2_b_frac[51])));
   assign ex2_sh_lv1y_b[55] = (~(sh1v4dcd3_cp4 & ex2_b_frac[52]));

   assign ex2_sh_lv1[0] = (~(ex2_sh_lv1x_b[0]));
   assign ex2_sh_lv1[1] = (~(ex2_sh_lv1x_b[1]));
   assign ex2_sh_lv1[2] = (~(ex2_sh_lv1x_b[2] & ex2_sh_lv1y_b[2]));
   assign ex2_sh_lv1[3] = (~(ex2_sh_lv1x_b[3] & ex2_sh_lv1y_b[3]));
   assign ex2_sh_lv1[4] = (~(ex2_sh_lv1x_b[4] & ex2_sh_lv1y_b[4]));
   assign ex2_sh_lv1[5] = (~(ex2_sh_lv1x_b[5] & ex2_sh_lv1y_b[5]));
   assign ex2_sh_lv1[6] = (~(ex2_sh_lv1x_b[6] & ex2_sh_lv1y_b[6]));
   assign ex2_sh_lv1[7] = (~(ex2_sh_lv1x_b[7] & ex2_sh_lv1y_b[7]));
   assign ex2_sh_lv1[8] = (~(ex2_sh_lv1x_b[8] & ex2_sh_lv1y_b[8]));
   assign ex2_sh_lv1[9] = (~(ex2_sh_lv1x_b[9] & ex2_sh_lv1y_b[9]));
   assign ex2_sh_lv1[10] = (~(ex2_sh_lv1x_b[10] & ex2_sh_lv1y_b[10]));
   assign ex2_sh_lv1[11] = (~(ex2_sh_lv1x_b[11] & ex2_sh_lv1y_b[11]));
   assign ex2_sh_lv1[12] = (~(ex2_sh_lv1x_b[12] & ex2_sh_lv1y_b[12]));
   assign ex2_sh_lv1[13] = (~(ex2_sh_lv1x_b[13] & ex2_sh_lv1y_b[13]));
   assign ex2_sh_lv1[14] = (~(ex2_sh_lv1x_b[14] & ex2_sh_lv1y_b[14]));
   assign ex2_sh_lv1[15] = (~(ex2_sh_lv1x_b[15] & ex2_sh_lv1y_b[15]));
   assign ex2_sh_lv1[16] = (~(ex2_sh_lv1x_b[16] & ex2_sh_lv1y_b[16]));
   assign ex2_sh_lv1[17] = (~(ex2_sh_lv1x_b[17] & ex2_sh_lv1y_b[17]));
   assign ex2_sh_lv1[18] = (~(ex2_sh_lv1x_b[18] & ex2_sh_lv1y_b[18]));
   assign ex2_sh_lv1[19] = (~(ex2_sh_lv1x_b[19] & ex2_sh_lv1y_b[19]));
   assign ex2_sh_lv1[20] = (~(ex2_sh_lv1x_b[20] & ex2_sh_lv1y_b[20]));
   assign ex2_sh_lv1[21] = (~(ex2_sh_lv1x_b[21] & ex2_sh_lv1y_b[21]));
   assign ex2_sh_lv1[22] = (~(ex2_sh_lv1x_b[22] & ex2_sh_lv1y_b[22]));
   assign ex2_sh_lv1[23] = (~(ex2_sh_lv1x_b[23] & ex2_sh_lv1y_b[23]));
   assign ex2_sh_lv1[24] = (~(ex2_sh_lv1x_b[24] & ex2_sh_lv1y_b[24]));
   assign ex2_sh_lv1[25] = (~(ex2_sh_lv1x_b[25] & ex2_sh_lv1y_b[25]));
   assign ex2_sh_lv1[26] = (~(ex2_sh_lv1x_b[26] & ex2_sh_lv1y_b[26]));
   assign ex2_sh_lv1[27] = (~(ex2_sh_lv1x_b[27] & ex2_sh_lv1y_b[27]));
   assign ex2_sh_lv1[28] = (~(ex2_sh_lv1x_b[28] & ex2_sh_lv1y_b[28]));
   assign ex2_sh_lv1[29] = (~(ex2_sh_lv1x_b[29] & ex2_sh_lv1y_b[29]));
   assign ex2_sh_lv1[30] = (~(ex2_sh_lv1x_b[30] & ex2_sh_lv1y_b[30]));
   assign ex2_sh_lv1[31] = (~(ex2_sh_lv1x_b[31] & ex2_sh_lv1y_b[31]));
   assign ex2_sh_lv1[32] = (~(ex2_sh_lv1x_b[32] & ex2_sh_lv1y_b[32]));
   assign ex2_sh_lv1[33] = (~(ex2_sh_lv1x_b[33] & ex2_sh_lv1y_b[33]));
   assign ex2_sh_lv1[34] = (~(ex2_sh_lv1x_b[34] & ex2_sh_lv1y_b[34]));
   assign ex2_sh_lv1[35] = (~(ex2_sh_lv1x_b[35] & ex2_sh_lv1y_b[35]));
   assign ex2_sh_lv1[36] = (~(ex2_sh_lv1x_b[36] & ex2_sh_lv1y_b[36]));
   assign ex2_sh_lv1[37] = (~(ex2_sh_lv1x_b[37] & ex2_sh_lv1y_b[37]));
   assign ex2_sh_lv1[38] = (~(ex2_sh_lv1x_b[38] & ex2_sh_lv1y_b[38]));
   assign ex2_sh_lv1[39] = (~(ex2_sh_lv1x_b[39] & ex2_sh_lv1y_b[39]));
   assign ex2_sh_lv1[40] = (~(ex2_sh_lv1x_b[40] & ex2_sh_lv1y_b[40]));
   assign ex2_sh_lv1[41] = (~(ex2_sh_lv1x_b[41] & ex2_sh_lv1y_b[41]));
   assign ex2_sh_lv1[42] = (~(ex2_sh_lv1x_b[42] & ex2_sh_lv1y_b[42]));
   assign ex2_sh_lv1[43] = (~(ex2_sh_lv1x_b[43] & ex2_sh_lv1y_b[43]));
   assign ex2_sh_lv1[44] = (~(ex2_sh_lv1x_b[44] & ex2_sh_lv1y_b[44]));
   assign ex2_sh_lv1[45] = (~(ex2_sh_lv1x_b[45] & ex2_sh_lv1y_b[45]));
   assign ex2_sh_lv1[46] = (~(ex2_sh_lv1x_b[46] & ex2_sh_lv1y_b[46]));
   assign ex2_sh_lv1[47] = (~(ex2_sh_lv1x_b[47] & ex2_sh_lv1y_b[47]));
   assign ex2_sh_lv1[48] = (~(ex2_sh_lv1x_b[48] & ex2_sh_lv1y_b[48]));
   assign ex2_sh_lv1[49] = (~(ex2_sh_lv1x_b[49] & ex2_sh_lv1y_b[49]));
   assign ex2_sh_lv1[50] = (~(ex2_sh_lv1x_b[50] & ex2_sh_lv1y_b[50]));
   assign ex2_sh_lv1[51] = (~(ex2_sh_lv1x_b[51] & ex2_sh_lv1y_b[51]));
   assign ex2_sh_lv1[52] = (~(ex2_sh_lv1x_b[52] & ex2_sh_lv1y_b[52]));
   assign ex2_sh_lv1[53] = (~(ex2_sh_lv1x_b[53] & ex2_sh_lv1y_b[53]));
   assign ex2_sh_lv1[54] = (~(ex2_sh_lv1y_b[54]));
   assign ex2_sh_lv1[55] = (~(ex2_sh_lv1y_b[55]));

   //--------------------------------------------------------------------------------------------

   assign ex2_sh_lv2x_b[0] = (~(sh2v4dcd00_cp1 & ex2_sh_lv1[0]));
   assign ex2_sh_lv2x_b[1] = (~(sh2v4dcd00_cp1 & ex2_sh_lv1[1]));
   assign ex2_sh_lv2x_b[2] = (~(sh2v4dcd00_cp1 & ex2_sh_lv1[2]));
   assign ex2_sh_lv2x_b[3] = (~(sh2v4dcd00_cp1 & ex2_sh_lv1[3]));
   assign ex2_sh_lv2x_b[4] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[4]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[0])));
   assign ex2_sh_lv2x_b[5] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[5]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[1])));
   assign ex2_sh_lv2x_b[6] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[6]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[2])));
   assign ex2_sh_lv2x_b[7] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[7]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[3])));
   assign ex2_sh_lv2x_b[8] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[8]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[4])));
   assign ex2_sh_lv2x_b[9] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[9]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[5])));
   assign ex2_sh_lv2x_b[10] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[10]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[6])));
   assign ex2_sh_lv2x_b[11] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[11]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[7])));
   assign ex2_sh_lv2x_b[12] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[12]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[8])));
   assign ex2_sh_lv2x_b[13] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[13]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[9])));
   assign ex2_sh_lv2x_b[14] = (~((sh2v4dcd00_cp1 & ex2_sh_lv1[14]) | (sh2v4dcd04_cp1 & ex2_sh_lv1[10])));
   assign ex2_sh_lv2x_b[15] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[15]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[11])));
   assign ex2_sh_lv2x_b[16] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[16]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[12])));
   assign ex2_sh_lv2x_b[17] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[17]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[13])));
   assign ex2_sh_lv2x_b[18] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[18]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[14])));
   assign ex2_sh_lv2x_b[19] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[19]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[15])));
   assign ex2_sh_lv2x_b[20] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[20]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[16])));		//
   assign ex2_sh_lv2x_b[21] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[21]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[17])));
   assign ex2_sh_lv2x_b[22] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[22]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[18])));
   assign ex2_sh_lv2x_b[23] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[23]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[19])));
   assign ex2_sh_lv2x_b[24] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[24]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[20])));
   assign ex2_sh_lv2x_b[25] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[25]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[21])));
   assign ex2_sh_lv2x_b[26] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[26]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[22])));
   assign ex2_sh_lv2x_b[27] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[27]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[23])));
   assign ex2_sh_lv2x_b[28] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[28]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[24])));
   assign ex2_sh_lv2x_b[29] = (~((sh2v4dcd00_cp2 & ex2_sh_lv1[29]) | (sh2v4dcd04_cp2 & ex2_sh_lv1[25])));
   assign ex2_sh_lv2x_b[30] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[30]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[26])));
   assign ex2_sh_lv2x_b[31] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[31]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[27])));
   assign ex2_sh_lv2x_b[32] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[32]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[28])));
   assign ex2_sh_lv2x_b[33] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[33]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[29])));
   assign ex2_sh_lv2x_b[34] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[34]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[30])));
   assign ex2_sh_lv2x_b[35] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[35]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[31])));
   assign ex2_sh_lv2x_b[36] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[36]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[32])));
   assign ex2_sh_lv2x_b[37] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[37]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[33])));
   assign ex2_sh_lv2x_b[38] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[38]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[34])));
   assign ex2_sh_lv2x_b[39] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[39]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[35])));
   assign ex2_sh_lv2x_b[40] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[40]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[36])));
   assign ex2_sh_lv2x_b[41] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[41]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[37])));
   assign ex2_sh_lv2x_b[42] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[42]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[38])));
   assign ex2_sh_lv2x_b[43] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[43]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[39])));
   assign ex2_sh_lv2x_b[44] = (~((sh2v4dcd00_cp3 & ex2_sh_lv1[44]) | (sh2v4dcd04_cp3 & ex2_sh_lv1[40])));
   assign ex2_sh_lv2x_b[45] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[45]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[41])));
   assign ex2_sh_lv2x_b[46] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[46]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[42])));
   assign ex2_sh_lv2x_b[47] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[47]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[43])));
   assign ex2_sh_lv2x_b[48] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[48]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[44])));
   assign ex2_sh_lv2x_b[49] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[49]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[45])));
   assign ex2_sh_lv2x_b[50] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[50]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[46])));
   assign ex2_sh_lv2x_b[51] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[51]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[47])));
   assign ex2_sh_lv2x_b[52] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[52]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[48])));
   assign ex2_sh_lv2x_b[53] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[53]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[49])));
   assign ex2_sh_lv2x_b[54] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[54]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[50])));
   assign ex2_sh_lv2x_b[55] = (~((sh2v4dcd00_cp4 & ex2_sh_lv1[55]) | (sh2v4dcd04_cp4 & ex2_sh_lv1[51])));
   assign ex2_sh_lv2x_b[56] = (~(sh2v4dcd04_cp4 & ex2_sh_lv1[52]));
   assign ex2_sh_lv2x_b[57] = (~(sh2v4dcd04_cp4 & ex2_sh_lv1[53]));
   assign ex2_sh_lv2x_b[58] = (~(sh2v4dcd04_cp4 & ex2_sh_lv1[54]));
   assign ex2_sh_lv2x_b[59] = (~(sh2v4dcd04_cp4 & ex2_sh_lv1[55]));

   assign ex2_sh_lv2y_b[8] = (~(sh2v4dcd08_cp1 & ex2_sh_lv1[0]));
   assign ex2_sh_lv2y_b[9] = (~(sh2v4dcd08_cp1 & ex2_sh_lv1[1]));
   assign ex2_sh_lv2y_b[10] = (~(sh2v4dcd08_cp1 & ex2_sh_lv1[2]));
   assign ex2_sh_lv2y_b[11] = (~(sh2v4dcd08_cp1 & ex2_sh_lv1[3]));
   assign ex2_sh_lv2y_b[12] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[4]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[0])));
   assign ex2_sh_lv2y_b[13] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[5]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[1])));
   assign ex2_sh_lv2y_b[14] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[6]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[2])));
   assign ex2_sh_lv2y_b[15] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[7]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[3])));
   assign ex2_sh_lv2y_b[16] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[8]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[4])));
   assign ex2_sh_lv2y_b[17] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[9]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[5])));
   assign ex2_sh_lv2y_b[18] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[10]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[6])));
   assign ex2_sh_lv2y_b[19] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[11]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[7])));
   assign ex2_sh_lv2y_b[20] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[12]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[8])));
   assign ex2_sh_lv2y_b[21] = (~((sh2v4dcd08_cp1 & ex2_sh_lv1[13]) | (sh2v4dcd12_cp1 & ex2_sh_lv1[9])));
   assign ex2_sh_lv2y_b[22] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[14]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[10])));
   assign ex2_sh_lv2y_b[23] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[15]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[11])));
   assign ex2_sh_lv2y_b[24] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[16]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[12])));
   assign ex2_sh_lv2y_b[25] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[17]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[13])));
   assign ex2_sh_lv2y_b[26] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[18]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[14])));
   assign ex2_sh_lv2y_b[27] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[19]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[15])));
   assign ex2_sh_lv2y_b[28] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[20]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[16])));
   assign ex2_sh_lv2y_b[29] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[21]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[17])));
   assign ex2_sh_lv2y_b[30] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[22]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[18])));
   assign ex2_sh_lv2y_b[31] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[23]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[19])));
   assign ex2_sh_lv2y_b[32] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[24]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[20])));
   assign ex2_sh_lv2y_b[33] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[25]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[21])));
   assign ex2_sh_lv2y_b[34] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[26]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[22])));
   assign ex2_sh_lv2y_b[35] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[27]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[23])));
   assign ex2_sh_lv2y_b[36] = (~((sh2v4dcd08_cp2 & ex2_sh_lv1[28]) | (sh2v4dcd12_cp2 & ex2_sh_lv1[24])));
   assign ex2_sh_lv2y_b[37] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[29]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[25])));
   assign ex2_sh_lv2y_b[38] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[30]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[26])));
   assign ex2_sh_lv2y_b[39] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[31]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[27])));
   assign ex2_sh_lv2y_b[40] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[32]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[28])));
   assign ex2_sh_lv2y_b[41] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[33]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[29])));
   assign ex2_sh_lv2y_b[42] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[34]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[30])));
   assign ex2_sh_lv2y_b[43] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[35]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[31])));
   assign ex2_sh_lv2y_b[44] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[36]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[32])));
   assign ex2_sh_lv2y_b[45] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[37]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[33])));
   assign ex2_sh_lv2y_b[46] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[38]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[34])));
   assign ex2_sh_lv2y_b[47] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[39]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[35])));
   assign ex2_sh_lv2y_b[48] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[40]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[36])));
   assign ex2_sh_lv2y_b[49] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[41]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[37])));
   assign ex2_sh_lv2y_b[50] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[42]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[38])));
   assign ex2_sh_lv2y_b[51] = (~((sh2v4dcd08_cp3 & ex2_sh_lv1[43]) | (sh2v4dcd12_cp3 & ex2_sh_lv1[39])));
   assign ex2_sh_lv2y_b[52] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[44]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[40])));
   assign ex2_sh_lv2y_b[53] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[45]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[41])));
   assign ex2_sh_lv2y_b[54] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[46]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[42])));
   assign ex2_sh_lv2y_b[55] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[47]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[43])));
   assign ex2_sh_lv2y_b[56] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[48]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[44])));
   assign ex2_sh_lv2y_b[57] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[49]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[45])));
   assign ex2_sh_lv2y_b[58] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[50]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[46])));
   assign ex2_sh_lv2y_b[59] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[51]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[47])));
   assign ex2_sh_lv2y_b[60] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[52]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[48])));
   assign ex2_sh_lv2y_b[61] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[53]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[49])));
   assign ex2_sh_lv2y_b[62] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[54]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[50])));
   assign ex2_sh_lv2y_b[63] = (~((sh2v4dcd08_cp4 & ex2_sh_lv1[55]) | (sh2v4dcd12_cp4 & ex2_sh_lv1[51])));
   assign ex2_sh_lv2y_b[64] = (~(sh2v4dcd12_cp4 & ex2_sh_lv1[52]));
   assign ex2_sh_lv2y_b[65] = (~(sh2v4dcd12_cp4 & ex2_sh_lv1[53]));
   assign ex2_sh_lv2y_b[66] = (~(sh2v4dcd12_cp4 & ex2_sh_lv1[54]));
   assign ex2_sh_lv2y_b[67] = (~(sh2v4dcd12_cp4 & ex2_sh_lv1[55]));

   assign ex2_sh_lv2z_b[0] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[0]));
   assign ex2_sh_lv2z_b[1] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[1]));
   assign ex2_sh_lv2z_b[2] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[2]));
   assign ex2_sh_lv2z_b[3] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[3]));
   assign ex2_sh_lv2z_b[4] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[4]));
   assign ex2_sh_lv2z_b[5] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[5]));
   assign ex2_sh_lv2z_b[6] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[6]));
   assign ex2_sh_lv2z_b[7] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[7]));
   assign ex2_sh_lv2z_b[8] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[8]));
   assign ex2_sh_lv2z_b[9] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[9]));
   assign ex2_sh_lv2z_b[10] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[10]));
   assign ex2_sh_lv2z_b[11] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[11]));
   assign ex2_sh_lv2z_b[12] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[12]));
   assign ex2_sh_lv2z_b[13] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[13]));
   assign ex2_sh_lv2z_b[14] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[14]));
   assign ex2_sh_lv2z_b[15] = (~(sh2v4dcdpp_cp1 & ex2_special_fcfid[15]));
   assign ex2_sh_lv2z_b[16] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[16]));
   assign ex2_sh_lv2z_b[17] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[17]));
   assign ex2_sh_lv2z_b[18] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[18]));
   assign ex2_sh_lv2z_b[19] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[19]));
   assign ex2_sh_lv2z_b[20] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[20]));
   assign ex2_sh_lv2z_b[21] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[21]));
   assign ex2_sh_lv2z_b[22] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[22]));
   assign ex2_sh_lv2z_b[23] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[23]));
   assign ex2_sh_lv2z_b[24] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[24]));
   assign ex2_sh_lv2z_b[25] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[25]));
   assign ex2_sh_lv2z_b[26] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[26]));
   assign ex2_sh_lv2z_b[27] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[27]));
   assign ex2_sh_lv2z_b[28] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[28]));
   assign ex2_sh_lv2z_b[29] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[29]));
   assign ex2_sh_lv2z_b[30] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[30]));
   assign ex2_sh_lv2z_b[31] = (~(sh2v4dcdpp_cp2 & ex2_special_fcfid[31]));
   assign ex2_sh_lv2z_b[32] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[32]));
   assign ex2_sh_lv2z_b[33] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[33]));
   assign ex2_sh_lv2z_b[34] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[34]));
   assign ex2_sh_lv2z_b[35] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[35]));
   assign ex2_sh_lv2z_b[36] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[36]));
   assign ex2_sh_lv2z_b[37] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[37]));
   assign ex2_sh_lv2z_b[38] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[38]));
   assign ex2_sh_lv2z_b[39] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[39]));
   assign ex2_sh_lv2z_b[40] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[40]));
   assign ex2_sh_lv2z_b[41] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[41]));
   assign ex2_sh_lv2z_b[42] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[42]));
   assign ex2_sh_lv2z_b[43] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[43]));
   assign ex2_sh_lv2z_b[44] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[44]));
   assign ex2_sh_lv2z_b[45] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[45]));
   assign ex2_sh_lv2z_b[46] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[46]));
   assign ex2_sh_lv2z_b[47] = (~(sh2v4dcdpp_cp3 & ex2_special_fcfid[47]));
   assign ex2_sh_lv2z_b[48] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[48]));
   assign ex2_sh_lv2z_b[49] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[49]));
   assign ex2_sh_lv2z_b[50] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[50]));
   assign ex2_sh_lv2z_b[51] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[51]));
   assign ex2_sh_lv2z_b[52] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[52]));
   assign ex2_sh_lv2z_b[53] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[53]));
   assign ex2_sh_lv2z_b[54] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[54]));
   assign ex2_sh_lv2z_b[55] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[55]));
   assign ex2_sh_lv2z_b[56] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[56]));
   assign ex2_sh_lv2z_b[57] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[57]));
   assign ex2_sh_lv2z_b[58] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[58]));
   assign ex2_sh_lv2z_b[59] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[59]));
   assign ex2_sh_lv2z_b[60] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[60]));
   assign ex2_sh_lv2z_b[61] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[61]));
   assign ex2_sh_lv2z_b[62] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[62]));
   assign ex2_sh_lv2z_b[63] = (~(sh2v4dcdpp_cp4 & ex2_special_fcfid[63]));

   assign ex2_sh_lvl2[00] = (~(ex2_sh_lv2x_b[00] & ex2_sh_lv2z_b[00]));
   assign ex2_sh_lvl2[01] = (~(ex2_sh_lv2x_b[01] & ex2_sh_lv2z_b[01]));
   assign ex2_sh_lvl2[02] = (~(ex2_sh_lv2x_b[02] & ex2_sh_lv2z_b[02]));
   assign ex2_sh_lvl2[03] = (~(ex2_sh_lv2x_b[03] & ex2_sh_lv2z_b[03]));
   assign ex2_sh_lvl2[04] = (~(ex2_sh_lv2x_b[04] & ex2_sh_lv2z_b[04]));
   assign ex2_sh_lvl2[05] = (~(ex2_sh_lv2x_b[05] & ex2_sh_lv2z_b[05]));
   assign ex2_sh_lvl2[06] = (~(ex2_sh_lv2x_b[06] & ex2_sh_lv2z_b[06]));
   assign ex2_sh_lvl2[07] = (~(ex2_sh_lv2x_b[07] & ex2_sh_lv2z_b[07]));
   assign ex2_sh_lvl2[08] = (~(ex2_sh_lv2x_b[08] & ex2_sh_lv2y_b[08] & ex2_sh_lv2z_b[08]));
   assign ex2_sh_lvl2[09] = (~(ex2_sh_lv2x_b[09] & ex2_sh_lv2y_b[09] & ex2_sh_lv2z_b[09]));
   assign ex2_sh_lvl2[10] = (~(ex2_sh_lv2x_b[10] & ex2_sh_lv2y_b[10] & ex2_sh_lv2z_b[10]));
   assign ex2_sh_lvl2[11] = (~(ex2_sh_lv2x_b[11] & ex2_sh_lv2y_b[11] & ex2_sh_lv2z_b[11]));
   assign ex2_sh_lvl2[12] = (~(ex2_sh_lv2x_b[12] & ex2_sh_lv2y_b[12] & ex2_sh_lv2z_b[12]));
   assign ex2_sh_lvl2[13] = (~(ex2_sh_lv2x_b[13] & ex2_sh_lv2y_b[13] & ex2_sh_lv2z_b[13]));
   assign ex2_sh_lvl2[14] = (~(ex2_sh_lv2x_b[14] & ex2_sh_lv2y_b[14] & ex2_sh_lv2z_b[14]));
   assign ex2_sh_lvl2[15] = (~(ex2_sh_lv2x_b[15] & ex2_sh_lv2y_b[15] & ex2_sh_lv2z_b[15]));
   assign ex2_sh_lvl2[16] = (~(ex2_sh_lv2x_b[16] & ex2_sh_lv2y_b[16] & ex2_sh_lv2z_b[16]));
   assign ex2_sh_lvl2[17] = (~(ex2_sh_lv2x_b[17] & ex2_sh_lv2y_b[17] & ex2_sh_lv2z_b[17]));
   assign ex2_sh_lvl2[18] = (~(ex2_sh_lv2x_b[18] & ex2_sh_lv2y_b[18] & ex2_sh_lv2z_b[18]));
   assign ex2_sh_lvl2[19] = (~(ex2_sh_lv2x_b[19] & ex2_sh_lv2y_b[19] & ex2_sh_lv2z_b[19]));
   assign ex2_sh_lvl2[20] = (~(ex2_sh_lv2x_b[20] & ex2_sh_lv2y_b[20] & ex2_sh_lv2z_b[20]));
   assign ex2_sh_lvl2[21] = (~(ex2_sh_lv2x_b[21] & ex2_sh_lv2y_b[21] & ex2_sh_lv2z_b[21]));
   assign ex2_sh_lvl2[22] = (~(ex2_sh_lv2x_b[22] & ex2_sh_lv2y_b[22] & ex2_sh_lv2z_b[22]));
   assign ex2_sh_lvl2[23] = (~(ex2_sh_lv2x_b[23] & ex2_sh_lv2y_b[23] & ex2_sh_lv2z_b[23]));
   assign ex2_sh_lvl2[24] = (~(ex2_sh_lv2x_b[24] & ex2_sh_lv2y_b[24] & ex2_sh_lv2z_b[24]));
   assign ex2_sh_lvl2[25] = (~(ex2_sh_lv2x_b[25] & ex2_sh_lv2y_b[25] & ex2_sh_lv2z_b[25]));
   assign ex2_sh_lvl2[26] = (~(ex2_sh_lv2x_b[26] & ex2_sh_lv2y_b[26] & ex2_sh_lv2z_b[26]));
   assign ex2_sh_lvl2[27] = (~(ex2_sh_lv2x_b[27] & ex2_sh_lv2y_b[27] & ex2_sh_lv2z_b[27]));
   assign ex2_sh_lvl2[28] = (~(ex2_sh_lv2x_b[28] & ex2_sh_lv2y_b[28] & ex2_sh_lv2z_b[28]));
   assign ex2_sh_lvl2[29] = (~(ex2_sh_lv2x_b[29] & ex2_sh_lv2y_b[29] & ex2_sh_lv2z_b[29]));
   assign ex2_sh_lvl2[30] = (~(ex2_sh_lv2x_b[30] & ex2_sh_lv2y_b[30] & ex2_sh_lv2z_b[30]));
   assign ex2_sh_lvl2[31] = (~(ex2_sh_lv2x_b[31] & ex2_sh_lv2y_b[31] & ex2_sh_lv2z_b[31]));
   assign ex2_sh_lvl2[32] = (~(ex2_sh_lv2x_b[32] & ex2_sh_lv2y_b[32] & ex2_sh_lv2z_b[32]));
   assign ex2_sh_lvl2[33] = (~(ex2_sh_lv2x_b[33] & ex2_sh_lv2y_b[33] & ex2_sh_lv2z_b[33]));
   assign ex2_sh_lvl2[34] = (~(ex2_sh_lv2x_b[34] & ex2_sh_lv2y_b[34] & ex2_sh_lv2z_b[34]));
   assign ex2_sh_lvl2[35] = (~(ex2_sh_lv2x_b[35] & ex2_sh_lv2y_b[35] & ex2_sh_lv2z_b[35]));
   assign ex2_sh_lvl2[36] = (~(ex2_sh_lv2x_b[36] & ex2_sh_lv2y_b[36] & ex2_sh_lv2z_b[36]));
   assign ex2_sh_lvl2[37] = (~(ex2_sh_lv2x_b[37] & ex2_sh_lv2y_b[37] & ex2_sh_lv2z_b[37]));
   assign ex2_sh_lvl2[38] = (~(ex2_sh_lv2x_b[38] & ex2_sh_lv2y_b[38] & ex2_sh_lv2z_b[38]));
   assign ex2_sh_lvl2[39] = (~(ex2_sh_lv2x_b[39] & ex2_sh_lv2y_b[39] & ex2_sh_lv2z_b[39]));
   assign ex2_sh_lvl2[40] = (~(ex2_sh_lv2x_b[40] & ex2_sh_lv2y_b[40] & ex2_sh_lv2z_b[40]));
   assign ex2_sh_lvl2[41] = (~(ex2_sh_lv2x_b[41] & ex2_sh_lv2y_b[41] & ex2_sh_lv2z_b[41]));
   assign ex2_sh_lvl2[42] = (~(ex2_sh_lv2x_b[42] & ex2_sh_lv2y_b[42] & ex2_sh_lv2z_b[42]));
   assign ex2_sh_lvl2[43] = (~(ex2_sh_lv2x_b[43] & ex2_sh_lv2y_b[43] & ex2_sh_lv2z_b[43]));
   assign ex2_sh_lvl2[44] = (~(ex2_sh_lv2x_b[44] & ex2_sh_lv2y_b[44] & ex2_sh_lv2z_b[44]));
   assign ex2_sh_lvl2[45] = (~(ex2_sh_lv2x_b[45] & ex2_sh_lv2y_b[45] & ex2_sh_lv2z_b[45]));
   assign ex2_sh_lvl2[46] = (~(ex2_sh_lv2x_b[46] & ex2_sh_lv2y_b[46] & ex2_sh_lv2z_b[46]));
   assign ex2_sh_lvl2[47] = (~(ex2_sh_lv2x_b[47] & ex2_sh_lv2y_b[47] & ex2_sh_lv2z_b[47]));
   assign ex2_sh_lvl2[48] = (~(ex2_sh_lv2x_b[48] & ex2_sh_lv2y_b[48] & ex2_sh_lv2z_b[48]));
   assign ex2_sh_lvl2[49] = (~(ex2_sh_lv2x_b[49] & ex2_sh_lv2y_b[49] & ex2_sh_lv2z_b[49]));
   assign ex2_sh_lvl2[50] = (~(ex2_sh_lv2x_b[50] & ex2_sh_lv2y_b[50] & ex2_sh_lv2z_b[50]));
   assign ex2_sh_lvl2[51] = (~(ex2_sh_lv2x_b[51] & ex2_sh_lv2y_b[51] & ex2_sh_lv2z_b[51]));
   assign ex2_sh_lvl2[52] = (~(ex2_sh_lv2x_b[52] & ex2_sh_lv2y_b[52] & ex2_sh_lv2z_b[52]));
   assign ex2_sh_lvl2[53] = (~(ex2_sh_lv2x_b[53] & ex2_sh_lv2y_b[53] & ex2_sh_lv2z_b[53]));
   assign ex2_sh_lvl2[54] = (~(ex2_sh_lv2x_b[54] & ex2_sh_lv2y_b[54] & ex2_sh_lv2z_b[54]));
   assign ex2_sh_lvl2[55] = (~(ex2_sh_lv2x_b[55] & ex2_sh_lv2y_b[55] & ex2_sh_lv2z_b[55]));
   assign ex2_sh_lvl2[56] = (~(ex2_sh_lv2x_b[56] & ex2_sh_lv2y_b[56] & ex2_sh_lv2z_b[56]));
   assign ex2_sh_lvl2[57] = (~(ex2_sh_lv2x_b[57] & ex2_sh_lv2y_b[57] & ex2_sh_lv2z_b[57]));
   assign ex2_sh_lvl2[58] = (~(ex2_sh_lv2x_b[58] & ex2_sh_lv2y_b[58] & ex2_sh_lv2z_b[58]));
   assign ex2_sh_lvl2[59] = (~(ex2_sh_lv2x_b[59] & ex2_sh_lv2y_b[59] & ex2_sh_lv2z_b[59]));
   assign ex2_sh_lvl2[60] = (~(ex2_sh_lv2y_b[60] & ex2_sh_lv2z_b[60]));
   assign ex2_sh_lvl2[61] = (~(ex2_sh_lv2y_b[61] & ex2_sh_lv2z_b[61]));
   assign ex2_sh_lvl2[62] = (~(ex2_sh_lv2y_b[62] & ex2_sh_lv2z_b[62]));
   assign ex2_sh_lvl2[63] = (~(ex2_sh_lv2y_b[63] & ex2_sh_lv2z_b[63]));
   assign ex2_sh_lvl2[64] = (~(ex2_sh_lv2y_b[64]));
   assign ex2_sh_lvl2[65] = (~(ex2_sh_lv2y_b[65]));
   assign ex2_sh_lvl2[66] = (~(ex2_sh_lv2y_b[66]));
   assign ex2_sh_lvl2[67] = (~(ex2_sh_lv2y_b[67]));

endmodule
