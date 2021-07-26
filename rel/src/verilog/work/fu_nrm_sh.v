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


module fu_nrm_sh(
   f_lza_ex5_sh_rgt_en,
   f_lza_ex5_lza_amt_cp1,
   f_lza_ex5_lza_dcd64_cp1,
   f_lza_ex5_lza_dcd64_cp2,
   f_lza_ex5_lza_dcd64_cp3,
   f_add_ex5_res,
   ex5_sh2_o,
   ex5_sh4_25,
   ex5_sh4_54,
   ex5_shift_extra_cp1,
   ex5_shift_extra_cp2,
   ex5_sh5_x_b,
   ex5_sh5_y_b
);
   //--------- SHIFT CONTROLS -----------------
   input          f_lza_ex5_sh_rgt_en;
   input [2:7]    f_lza_ex5_lza_amt_cp1;
   input [0:2]    f_lza_ex5_lza_dcd64_cp1;
   input [0:1]    f_lza_ex5_lza_dcd64_cp2;
   input [0:0]    f_lza_ex5_lza_dcd64_cp3;

   //--------- SHIFT DATA -----------------
   input [0:162]  f_add_ex5_res;

   //-------- SHIFT OUTPUT ---------------
   output [26:72] ex5_sh2_o;
   output         ex5_sh4_25;
   output         ex5_sh4_54;
   output         ex5_shift_extra_cp1;
   output         ex5_shift_extra_cp2;

   output [0:53]  ex5_sh5_x_b;
   output [0:53]  ex5_sh5_y_b;

   // ENTITY


   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire [0:120]   ex5_sh1_x_b;
   wire [0:99]    ex5_sh1_y_b;
   wire [0:35]    ex5_sh1_u_b;
   wire [65:118]  ex5_sh1_z_b;
   wire [0:72]    ex5_sh2_x_b;
   wire [0:72]    ex5_sh2_y_b;
   wire [0:57]    ex5_sh3_x_b;
   wire [0:57]    ex5_sh3_y_b;
   wire [0:54]    ex5_sh4_x_b;
   wire [0:54]    ex5_sh4_y_b;
   wire           ex5_sh4_x_00_b;
   wire           ex5_sh4_y_00_b;

   wire           ex5_shift_extra_cp1_b;

   wire           ex5_shift_extra_cp2_b;
   wire           ex5_shift_extra_cp3_b;
   wire           ex5_shift_extra_cp4_b;
   wire           ex5_shift_extra_cp3;
   wire           ex5_shift_extra_cp4;
   wire [0:54]    ex5_sh4;
   wire [0:57]    ex5_sh3;
   wire [0:72]    ex5_sh2;
   wire [0:120]   ex5_sh1;
   wire [0:2]     ex5_shctl_64;
   wire [0:1]     ex5_shctl_64_cp2;
   wire [0:0]     ex5_shctl_64_cp3;
   wire [0:3]     ex5_shctl_16;
   wire [0:3]     ex5_shctl_04;
   wire [0:3]     ex5_shctl_01;
   wire           ex5_shift_extra_10_cp3;
   wire           ex5_shift_extra_20_cp3_b;
   wire           ex5_shift_extra_11_cp3;
   wire           ex5_shift_extra_21_cp3_b;
   wire           ex5_shift_extra_31_cp3;
   wire           ex5_shift_extra_10_cp4;
   wire           ex5_shift_extra_20_cp4_b;
   wire           ex5_shift_extra_11_cp4;
   wire           ex5_shift_extra_21_cp4_b;
   wire           ex5_shift_extra_31_cp4;
   wire           ex5_shift_extra_00_cp3_b;
   wire           ex5_shift_extra_00_cp4_b;


   ////##############################################
   //# EX5 logic: shift decode
   ////##############################################

   assign ex5_shctl_64[0:2] = f_lza_ex5_lza_dcd64_cp1[0:2];
   assign ex5_shctl_64_cp2[0:1] = f_lza_ex5_lza_dcd64_cp2[0:1];
   assign ex5_shctl_64_cp3[0] = f_lza_ex5_lza_dcd64_cp3[0];

   assign ex5_shctl_16[0] = (~f_lza_ex5_lza_amt_cp1[2]) & (~f_lza_ex5_lza_amt_cp1[3]);		//SH000
   assign ex5_shctl_16[1] = (~f_lza_ex5_lza_amt_cp1[2]) & f_lza_ex5_lza_amt_cp1[3];		//SH016
   assign ex5_shctl_16[2] = f_lza_ex5_lza_amt_cp1[2] & (~f_lza_ex5_lza_amt_cp1[3]);		//SH032
   assign ex5_shctl_16[3] = f_lza_ex5_lza_amt_cp1[2] & f_lza_ex5_lza_amt_cp1[3];		//SH048

   assign ex5_shctl_04[0] = (~f_lza_ex5_lza_amt_cp1[4]) & (~f_lza_ex5_lza_amt_cp1[5]);		//SH000
   assign ex5_shctl_04[1] = (~f_lza_ex5_lza_amt_cp1[4]) & f_lza_ex5_lza_amt_cp1[5];		//SH004
   assign ex5_shctl_04[2] = f_lza_ex5_lza_amt_cp1[4] & (~f_lza_ex5_lza_amt_cp1[5]);		//SH008
   assign ex5_shctl_04[3] = f_lza_ex5_lza_amt_cp1[4] & f_lza_ex5_lza_amt_cp1[5];		//SH012

   assign ex5_shctl_01[0] = (~f_lza_ex5_lza_amt_cp1[6]) & (~f_lza_ex5_lza_amt_cp1[7]);		//SH000
   assign ex5_shctl_01[1] = (~f_lza_ex5_lza_amt_cp1[6]) & f_lza_ex5_lza_amt_cp1[7];		//SH001
   assign ex5_shctl_01[2] = f_lza_ex5_lza_amt_cp1[6] & (~f_lza_ex5_lza_amt_cp1[7]);		//SH002
   assign ex5_shctl_01[3] = f_lza_ex5_lza_amt_cp1[6] & f_lza_ex5_lza_amt_cp1[7];		//SH003

   ////##############################################
   //# EX5 logic: shifting
   ////##############################################
   ////## big shifts first (come sooner from LZA,
   ////## when shift amount is [0] we need to start out with a "dummy" leading bit to sacrifice for shift_extra
   ////   ex5_sh1(0 to 54)   <=
   ////          ( ( tidn & f_add_ex5_res(  0 to 53)                       )  and (0 to 54 => ex5_shctl_64(0))  ) or --SH000
   ////          ( (        f_add_ex5_res( 63 to 117)                      )  and (0 to 54 => ex5_shctl_64(1))  ) or --SH064
   ////          ( (        f_add_ex5_res(127 to 162) & (36 to 54 => tidn) )  and (0 to 54 => ex5_shctl_64(2))  ) ;  --SH128
   ////
   ////   ex5_sh1(55 to 64) <=
   ////          ( (  f_add_ex5_res( 54 to 63 )                            )  and (55 to 64 => ex5_shctl_64_cp2(0))   ) or --SH000
   ////          ( (  f_add_ex5_res(118 to 127)                            )  and (55 to 64 => ex5_shctl_64_cp2(1))   ) ;  --SH064
   ////
   ////   ex5_sh1(65 to 108) <=
   ////          ( (  f_add_ex5_res( 64 to 107)                            )  and (65 to 108 => ex5_shctl_64_cp2(0))  ) or --SH000
   ////          ( (  f_add_ex5_res(128 to 162) & (100 to 108=> tidn)      )  and (65 to 108 => ex5_shctl_64_cp2(1))  ) or --SH064
   ////          ( (  f_add_ex5_res(0 to 43)                               )  and (65 to 108 => f_lza_ex5_sh_rgt_en)  ) ;  --SHR64
   ////
   ////   ex5_sh1(109 to 118) <=
   ////            ( (        f_add_ex5_res(108 to 117)                    )  and (109 to 118 => ex5_shctl_64_cp3(0))  ) or --SH000
   ////            ( (        f_add_ex5_res(44 to 53)                      )  and (109 to 118 => f_lza_ex5_sh_rgt_en)  ) ;  --SHR64
   ////
   ////   ex5_sh1(119 to 120) <=
   ////            ( (        f_add_ex5_res(118 to 119)                    )  and (119 to 120 => ex5_shctl_64_cp3(0))  );   --SH000
   ////
   ////          -- sh2 ony needs to be 0:69 , however since sp & dp group16s would be off by 2
   ////          --                            it saves logic in sticky calc to keep 2 more bits
   ////          --                            and use the same sticky or group 16s for sp/dp.
   ////          --                            70:71 are always part of dp sticky
   ////
   ////   ex5_sh2(0 to 72) <= -- (0 to 69) -- shift by multiples of 16
   ////          ( ex5_sh1( 0 to  72) and  (0 to 72 => ex5_shctl_16(0) ) ) or --SH00
   ////          ( ex5_sh1(16 to  88) and  (0 to 72 => ex5_shctl_16(1) ) ) or --SH16
   ////          ( ex5_sh1(32 to 104) and  (0 to 72 => ex5_shctl_16(2) ) ) or --SH32
   ////          ( ex5_sh1(48 to 120) and  (0 to 72 => ex5_shctl_16(3) ) ) ;  --SH48

   assign ex5_sh2_o[26:72] = ex5_sh2[26:72];		// for sticky bit

   ////   ex5_sh3(0 to 57) <= -- shift by multiples of 4
   ////          ( ex5_sh2( 0 to 57) and  (0 to 57 => ex5_shctl_04(0) ) ) or --SH00
   ////          ( ex5_sh2( 4 to 61) and  (0 to 57 => ex5_shctl_04(1) ) ) or --SH04
   ////          ( ex5_sh2( 8 to 65) and  (0 to 57 => ex5_shctl_04(2) ) ) or --SH08
   ////          ( ex5_sh2(12 to 69) and  (0 to 57 => ex5_shctl_04(3) ) ) ;  --SH12
   ////
   ////   ex5_sh4(0 to 54) <= -- shift by multiples of 1
   ////          ( ex5_sh3(0 to 54) and  (0 to 54 => ex5_shctl_01(0) ) ) or --SH00
   ////          ( ex5_sh3(1 to 55) and  (0 to 54 => ex5_shctl_01(1) ) ) or --SH01
   ////          ( ex5_sh3(2 to 56) and  (0 to 54 => ex5_shctl_01(2) ) ) or --SH02
   ////          ( ex5_sh3(3 to 57) and  (0 to 54 => ex5_shctl_01(3) ) ) ;  --SH03

   assign ex5_sh4_25 = ex5_sh4[25];		// for sticky bit
   assign ex5_sh4_54 = ex5_sh4[54];		// for sticky bit

   ////   ex5_nrm_res(0 to 53) <= -- [53] is for the DP guard bit
   ////          (  ex5_sh4(0 to 53) and (0 to 53 => not ex5_shift_extra) ) or
   ////          (  ex5_sh4(1 to 54) and (0 to 53 =>     ex5_shift_extra) ) ;

   //-------------------------------------------------------
   assign ex5_sh1_x_b[0] = (~(tidn & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[1] = (~(f_add_ex5_res[0] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[2] = (~(f_add_ex5_res[1] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[3] = (~(f_add_ex5_res[2] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[4] = (~(f_add_ex5_res[3] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[5] = (~(f_add_ex5_res[4] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[6] = (~(f_add_ex5_res[5] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[7] = (~(f_add_ex5_res[6] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[8] = (~(f_add_ex5_res[7] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[9] = (~(f_add_ex5_res[8] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[10] = (~(f_add_ex5_res[9] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[11] = (~(f_add_ex5_res[10] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[12] = (~(f_add_ex5_res[11] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[13] = (~(f_add_ex5_res[12] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[14] = (~(f_add_ex5_res[13] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[15] = (~(f_add_ex5_res[14] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[16] = (~(f_add_ex5_res[15] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[17] = (~(f_add_ex5_res[16] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[18] = (~(f_add_ex5_res[17] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[19] = (~(f_add_ex5_res[18] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[20] = (~(f_add_ex5_res[19] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[21] = (~(f_add_ex5_res[20] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[22] = (~(f_add_ex5_res[21] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[23] = (~(f_add_ex5_res[22] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[24] = (~(f_add_ex5_res[23] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[25] = (~(f_add_ex5_res[24] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[26] = (~(f_add_ex5_res[25] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[27] = (~(f_add_ex5_res[26] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[28] = (~(f_add_ex5_res[27] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[29] = (~(f_add_ex5_res[28] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[30] = (~(f_add_ex5_res[29] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[31] = (~(f_add_ex5_res[30] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[32] = (~(f_add_ex5_res[31] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[33] = (~(f_add_ex5_res[32] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[34] = (~(f_add_ex5_res[33] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[35] = (~(f_add_ex5_res[34] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[36] = (~(f_add_ex5_res[35] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[37] = (~(f_add_ex5_res[36] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[38] = (~(f_add_ex5_res[37] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[39] = (~(f_add_ex5_res[38] & ex5_shctl_64[0]));
   assign ex5_sh1_x_b[40] = (~(f_add_ex5_res[39] & ex5_shctl_64_cp2[0]));		//--------
   assign ex5_sh1_x_b[41] = (~(f_add_ex5_res[40] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[42] = (~(f_add_ex5_res[41] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[43] = (~(f_add_ex5_res[42] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[44] = (~(f_add_ex5_res[43] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[45] = (~(f_add_ex5_res[44] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[46] = (~(f_add_ex5_res[45] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[47] = (~(f_add_ex5_res[46] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[48] = (~(f_add_ex5_res[47] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[49] = (~(f_add_ex5_res[48] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[50] = (~(f_add_ex5_res[49] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[51] = (~(f_add_ex5_res[50] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[52] = (~(f_add_ex5_res[51] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[53] = (~(f_add_ex5_res[52] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[54] = (~(f_add_ex5_res[53] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[55] = (~(f_add_ex5_res[54] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[56] = (~(f_add_ex5_res[55] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[57] = (~(f_add_ex5_res[56] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[58] = (~(f_add_ex5_res[57] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[59] = (~(f_add_ex5_res[58] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[60] = (~(f_add_ex5_res[59] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[61] = (~(f_add_ex5_res[60] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[62] = (~(f_add_ex5_res[61] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[63] = (~(f_add_ex5_res[62] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[64] = (~(f_add_ex5_res[63] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[65] = (~(f_add_ex5_res[64] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[66] = (~(f_add_ex5_res[65] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[67] = (~(f_add_ex5_res[66] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[68] = (~(f_add_ex5_res[67] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[69] = (~(f_add_ex5_res[68] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[70] = (~(f_add_ex5_res[69] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[71] = (~(f_add_ex5_res[70] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[72] = (~(f_add_ex5_res[71] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[73] = (~(f_add_ex5_res[72] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[74] = (~(f_add_ex5_res[73] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[75] = (~(f_add_ex5_res[74] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[76] = (~(f_add_ex5_res[75] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[77] = (~(f_add_ex5_res[76] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[78] = (~(f_add_ex5_res[77] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[79] = (~(f_add_ex5_res[78] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[80] = (~(f_add_ex5_res[79] & ex5_shctl_64_cp2[0]));
   assign ex5_sh1_x_b[81] = (~(f_add_ex5_res[80] & ex5_shctl_64_cp3[0]));		//----
   assign ex5_sh1_x_b[82] = (~(f_add_ex5_res[81] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[83] = (~(f_add_ex5_res[82] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[84] = (~(f_add_ex5_res[83] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[85] = (~(f_add_ex5_res[84] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[86] = (~(f_add_ex5_res[85] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[87] = (~(f_add_ex5_res[86] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[88] = (~(f_add_ex5_res[87] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[89] = (~(f_add_ex5_res[88] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[90] = (~(f_add_ex5_res[89] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[91] = (~(f_add_ex5_res[90] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[92] = (~(f_add_ex5_res[91] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[93] = (~(f_add_ex5_res[92] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[94] = (~(f_add_ex5_res[93] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[95] = (~(f_add_ex5_res[94] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[96] = (~(f_add_ex5_res[95] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[97] = (~(f_add_ex5_res[96] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[98] = (~(f_add_ex5_res[97] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[99] = (~(f_add_ex5_res[98] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[100] = (~(f_add_ex5_res[99] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[101] = (~(f_add_ex5_res[100] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[102] = (~(f_add_ex5_res[101] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[103] = (~(f_add_ex5_res[102] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[104] = (~(f_add_ex5_res[103] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[105] = (~(f_add_ex5_res[104] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[106] = (~(f_add_ex5_res[105] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[107] = (~(f_add_ex5_res[106] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[108] = (~(f_add_ex5_res[107] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[109] = (~(f_add_ex5_res[108] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[110] = (~(f_add_ex5_res[109] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[111] = (~(f_add_ex5_res[110] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[112] = (~(f_add_ex5_res[111] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[113] = (~(f_add_ex5_res[112] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[114] = (~(f_add_ex5_res[113] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[115] = (~(f_add_ex5_res[114] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[116] = (~(f_add_ex5_res[115] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[117] = (~(f_add_ex5_res[116] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[118] = (~(f_add_ex5_res[117] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[119] = (~(f_add_ex5_res[118] & ex5_shctl_64_cp3[0]));
   assign ex5_sh1_x_b[120] = (~(f_add_ex5_res[119] & ex5_shctl_64_cp3[0]));

   assign ex5_sh1_y_b[0] = (~(f_add_ex5_res[63] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[1] = (~(f_add_ex5_res[64] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[2] = (~(f_add_ex5_res[65] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[3] = (~(f_add_ex5_res[66] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[4] = (~(f_add_ex5_res[67] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[5] = (~(f_add_ex5_res[68] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[6] = (~(f_add_ex5_res[69] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[7] = (~(f_add_ex5_res[70] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[8] = (~(f_add_ex5_res[71] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[9] = (~(f_add_ex5_res[72] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[10] = (~(f_add_ex5_res[73] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[11] = (~(f_add_ex5_res[74] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[12] = (~(f_add_ex5_res[75] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[13] = (~(f_add_ex5_res[76] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[14] = (~(f_add_ex5_res[77] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[15] = (~(f_add_ex5_res[78] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[16] = (~(f_add_ex5_res[79] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[17] = (~(f_add_ex5_res[80] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[18] = (~(f_add_ex5_res[81] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[19] = (~(f_add_ex5_res[82] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[20] = (~(f_add_ex5_res[83] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[21] = (~(f_add_ex5_res[84] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[22] = (~(f_add_ex5_res[85] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[23] = (~(f_add_ex5_res[86] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[24] = (~(f_add_ex5_res[87] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[25] = (~(f_add_ex5_res[88] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[26] = (~(f_add_ex5_res[89] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[27] = (~(f_add_ex5_res[90] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[28] = (~(f_add_ex5_res[91] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[29] = (~(f_add_ex5_res[92] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[30] = (~(f_add_ex5_res[93] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[31] = (~(f_add_ex5_res[94] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[32] = (~(f_add_ex5_res[95] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[33] = (~(f_add_ex5_res[96] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[34] = (~(f_add_ex5_res[97] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[35] = (~(f_add_ex5_res[98] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[36] = (~(f_add_ex5_res[99] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[37] = (~(f_add_ex5_res[100] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[38] = (~(f_add_ex5_res[101] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[39] = (~(f_add_ex5_res[102] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[40] = (~(f_add_ex5_res[103] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[41] = (~(f_add_ex5_res[104] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[42] = (~(f_add_ex5_res[105] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[43] = (~(f_add_ex5_res[106] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[44] = (~(f_add_ex5_res[107] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[45] = (~(f_add_ex5_res[108] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[46] = (~(f_add_ex5_res[109] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[47] = (~(f_add_ex5_res[110] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[48] = (~(f_add_ex5_res[111] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[49] = (~(f_add_ex5_res[112] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[50] = (~(f_add_ex5_res[113] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[51] = (~(f_add_ex5_res[114] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[52] = (~(f_add_ex5_res[115] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[53] = (~(f_add_ex5_res[116] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[54] = (~(f_add_ex5_res[117] & ex5_shctl_64[1]));
   assign ex5_sh1_y_b[55] = (~(f_add_ex5_res[118] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[56] = (~(f_add_ex5_res[119] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[57] = (~(f_add_ex5_res[120] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[58] = (~(f_add_ex5_res[121] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[59] = (~(f_add_ex5_res[122] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[60] = (~(f_add_ex5_res[123] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[61] = (~(f_add_ex5_res[124] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[62] = (~(f_add_ex5_res[125] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[63] = (~(f_add_ex5_res[126] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[64] = (~(f_add_ex5_res[127] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[65] = (~(f_add_ex5_res[128] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[66] = (~(f_add_ex5_res[129] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[67] = (~(f_add_ex5_res[130] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[68] = (~(f_add_ex5_res[131] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[69] = (~(f_add_ex5_res[132] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[70] = (~(f_add_ex5_res[133] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[71] = (~(f_add_ex5_res[134] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[72] = (~(f_add_ex5_res[135] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[73] = (~(f_add_ex5_res[136] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[74] = (~(f_add_ex5_res[137] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[75] = (~(f_add_ex5_res[138] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[76] = (~(f_add_ex5_res[139] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[77] = (~(f_add_ex5_res[140] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[78] = (~(f_add_ex5_res[141] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[79] = (~(f_add_ex5_res[142] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[80] = (~(f_add_ex5_res[143] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[81] = (~(f_add_ex5_res[144] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[82] = (~(f_add_ex5_res[145] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[83] = (~(f_add_ex5_res[146] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[84] = (~(f_add_ex5_res[147] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[85] = (~(f_add_ex5_res[148] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[86] = (~(f_add_ex5_res[149] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[87] = (~(f_add_ex5_res[150] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[88] = (~(f_add_ex5_res[151] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[89] = (~(f_add_ex5_res[152] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[90] = (~(f_add_ex5_res[153] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[91] = (~(f_add_ex5_res[154] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[92] = (~(f_add_ex5_res[155] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[93] = (~(f_add_ex5_res[156] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[94] = (~(f_add_ex5_res[157] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[95] = (~(f_add_ex5_res[158] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[96] = (~(f_add_ex5_res[159] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[97] = (~(f_add_ex5_res[160] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[98] = (~(f_add_ex5_res[161] & ex5_shctl_64_cp2[1]));
   assign ex5_sh1_y_b[99] = (~(f_add_ex5_res[162] & ex5_shctl_64_cp2[1]));

   assign ex5_sh1_u_b[0] = (~(f_add_ex5_res[127] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[1] = (~(f_add_ex5_res[128] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[2] = (~(f_add_ex5_res[129] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[3] = (~(f_add_ex5_res[130] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[4] = (~(f_add_ex5_res[131] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[5] = (~(f_add_ex5_res[132] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[6] = (~(f_add_ex5_res[133] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[7] = (~(f_add_ex5_res[134] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[8] = (~(f_add_ex5_res[135] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[9] = (~(f_add_ex5_res[136] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[10] = (~(f_add_ex5_res[137] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[11] = (~(f_add_ex5_res[138] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[12] = (~(f_add_ex5_res[139] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[13] = (~(f_add_ex5_res[140] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[14] = (~(f_add_ex5_res[141] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[15] = (~(f_add_ex5_res[142] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[16] = (~(f_add_ex5_res[143] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[17] = (~(f_add_ex5_res[144] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[18] = (~(f_add_ex5_res[145] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[19] = (~(f_add_ex5_res[146] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[20] = (~(f_add_ex5_res[147] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[21] = (~(f_add_ex5_res[148] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[22] = (~(f_add_ex5_res[149] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[23] = (~(f_add_ex5_res[150] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[24] = (~(f_add_ex5_res[151] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[25] = (~(f_add_ex5_res[152] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[26] = (~(f_add_ex5_res[153] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[27] = (~(f_add_ex5_res[154] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[28] = (~(f_add_ex5_res[155] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[29] = (~(f_add_ex5_res[156] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[30] = (~(f_add_ex5_res[157] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[31] = (~(f_add_ex5_res[158] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[32] = (~(f_add_ex5_res[159] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[33] = (~(f_add_ex5_res[160] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[34] = (~(f_add_ex5_res[161] & ex5_shctl_64[2]));
   assign ex5_sh1_u_b[35] = (~(f_add_ex5_res[162] & ex5_shctl_64[2]));

   assign ex5_sh1_z_b[65] = (~(f_add_ex5_res[0] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[66] = (~(f_add_ex5_res[1] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[67] = (~(f_add_ex5_res[2] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[68] = (~(f_add_ex5_res[3] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[69] = (~(f_add_ex5_res[4] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[70] = (~(f_add_ex5_res[5] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[71] = (~(f_add_ex5_res[6] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[72] = (~(f_add_ex5_res[7] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[73] = (~(f_add_ex5_res[8] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[74] = (~(f_add_ex5_res[9] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[75] = (~(f_add_ex5_res[10] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[76] = (~(f_add_ex5_res[11] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[77] = (~(f_add_ex5_res[12] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[78] = (~(f_add_ex5_res[13] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[79] = (~(f_add_ex5_res[14] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[80] = (~(f_add_ex5_res[15] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[81] = (~(f_add_ex5_res[16] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[82] = (~(f_add_ex5_res[17] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[83] = (~(f_add_ex5_res[18] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[84] = (~(f_add_ex5_res[19] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[85] = (~(f_add_ex5_res[20] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[86] = (~(f_add_ex5_res[21] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[87] = (~(f_add_ex5_res[22] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[88] = (~(f_add_ex5_res[23] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[89] = (~(f_add_ex5_res[24] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[90] = (~(f_add_ex5_res[25] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[91] = (~(f_add_ex5_res[26] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[92] = (~(f_add_ex5_res[27] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[93] = (~(f_add_ex5_res[28] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[94] = (~(f_add_ex5_res[29] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[95] = (~(f_add_ex5_res[30] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[96] = (~(f_add_ex5_res[31] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[97] = (~(f_add_ex5_res[32] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[98] = (~(f_add_ex5_res[33] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[99] = (~(f_add_ex5_res[34] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[100] = (~(f_add_ex5_res[35] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[101] = (~(f_add_ex5_res[36] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[102] = (~(f_add_ex5_res[37] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[103] = (~(f_add_ex5_res[38] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[104] = (~(f_add_ex5_res[39] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[105] = (~(f_add_ex5_res[40] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[106] = (~(f_add_ex5_res[41] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[107] = (~(f_add_ex5_res[42] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[108] = (~(f_add_ex5_res[43] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[109] = (~(f_add_ex5_res[44] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[110] = (~(f_add_ex5_res[45] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[111] = (~(f_add_ex5_res[46] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[112] = (~(f_add_ex5_res[47] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[113] = (~(f_add_ex5_res[48] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[114] = (~(f_add_ex5_res[49] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[115] = (~(f_add_ex5_res[50] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[116] = (~(f_add_ex5_res[51] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[117] = (~(f_add_ex5_res[52] & f_lza_ex5_sh_rgt_en));
   assign ex5_sh1_z_b[118] = (~(f_add_ex5_res[53] & f_lza_ex5_sh_rgt_en));

   assign ex5_sh1[0] = (~(ex5_sh1_x_b[0] & ex5_sh1_y_b[0] & ex5_sh1_u_b[0]));
   assign ex5_sh1[1] = (~(ex5_sh1_x_b[1] & ex5_sh1_y_b[1] & ex5_sh1_u_b[1]));
   assign ex5_sh1[2] = (~(ex5_sh1_x_b[2] & ex5_sh1_y_b[2] & ex5_sh1_u_b[2]));
   assign ex5_sh1[3] = (~(ex5_sh1_x_b[3] & ex5_sh1_y_b[3] & ex5_sh1_u_b[3]));
   assign ex5_sh1[4] = (~(ex5_sh1_x_b[4] & ex5_sh1_y_b[4] & ex5_sh1_u_b[4]));
   assign ex5_sh1[5] = (~(ex5_sh1_x_b[5] & ex5_sh1_y_b[5] & ex5_sh1_u_b[5]));
   assign ex5_sh1[6] = (~(ex5_sh1_x_b[6] & ex5_sh1_y_b[6] & ex5_sh1_u_b[6]));
   assign ex5_sh1[7] = (~(ex5_sh1_x_b[7] & ex5_sh1_y_b[7] & ex5_sh1_u_b[7]));
   assign ex5_sh1[8] = (~(ex5_sh1_x_b[8] & ex5_sh1_y_b[8] & ex5_sh1_u_b[8]));
   assign ex5_sh1[9] = (~(ex5_sh1_x_b[9] & ex5_sh1_y_b[9] & ex5_sh1_u_b[9]));
   assign ex5_sh1[10] = (~(ex5_sh1_x_b[10] & ex5_sh1_y_b[10] & ex5_sh1_u_b[10]));
   assign ex5_sh1[11] = (~(ex5_sh1_x_b[11] & ex5_sh1_y_b[11] & ex5_sh1_u_b[11]));
   assign ex5_sh1[12] = (~(ex5_sh1_x_b[12] & ex5_sh1_y_b[12] & ex5_sh1_u_b[12]));
   assign ex5_sh1[13] = (~(ex5_sh1_x_b[13] & ex5_sh1_y_b[13] & ex5_sh1_u_b[13]));
   assign ex5_sh1[14] = (~(ex5_sh1_x_b[14] & ex5_sh1_y_b[14] & ex5_sh1_u_b[14]));
   assign ex5_sh1[15] = (~(ex5_sh1_x_b[15] & ex5_sh1_y_b[15] & ex5_sh1_u_b[15]));
   assign ex5_sh1[16] = (~(ex5_sh1_x_b[16] & ex5_sh1_y_b[16] & ex5_sh1_u_b[16]));
   assign ex5_sh1[17] = (~(ex5_sh1_x_b[17] & ex5_sh1_y_b[17] & ex5_sh1_u_b[17]));
   assign ex5_sh1[18] = (~(ex5_sh1_x_b[18] & ex5_sh1_y_b[18] & ex5_sh1_u_b[18]));
   assign ex5_sh1[19] = (~(ex5_sh1_x_b[19] & ex5_sh1_y_b[19] & ex5_sh1_u_b[19]));
   assign ex5_sh1[20] = (~(ex5_sh1_x_b[20] & ex5_sh1_y_b[20] & ex5_sh1_u_b[20]));
   assign ex5_sh1[21] = (~(ex5_sh1_x_b[21] & ex5_sh1_y_b[21] & ex5_sh1_u_b[21]));
   assign ex5_sh1[22] = (~(ex5_sh1_x_b[22] & ex5_sh1_y_b[22] & ex5_sh1_u_b[22]));
   assign ex5_sh1[23] = (~(ex5_sh1_x_b[23] & ex5_sh1_y_b[23] & ex5_sh1_u_b[23]));
   assign ex5_sh1[24] = (~(ex5_sh1_x_b[24] & ex5_sh1_y_b[24] & ex5_sh1_u_b[24]));
   assign ex5_sh1[25] = (~(ex5_sh1_x_b[25] & ex5_sh1_y_b[25] & ex5_sh1_u_b[25]));
   assign ex5_sh1[26] = (~(ex5_sh1_x_b[26] & ex5_sh1_y_b[26] & ex5_sh1_u_b[26]));
   assign ex5_sh1[27] = (~(ex5_sh1_x_b[27] & ex5_sh1_y_b[27] & ex5_sh1_u_b[27]));
   assign ex5_sh1[28] = (~(ex5_sh1_x_b[28] & ex5_sh1_y_b[28] & ex5_sh1_u_b[28]));
   assign ex5_sh1[29] = (~(ex5_sh1_x_b[29] & ex5_sh1_y_b[29] & ex5_sh1_u_b[29]));
   assign ex5_sh1[30] = (~(ex5_sh1_x_b[30] & ex5_sh1_y_b[30] & ex5_sh1_u_b[30]));
   assign ex5_sh1[31] = (~(ex5_sh1_x_b[31] & ex5_sh1_y_b[31] & ex5_sh1_u_b[31]));
   assign ex5_sh1[32] = (~(ex5_sh1_x_b[32] & ex5_sh1_y_b[32] & ex5_sh1_u_b[32]));
   assign ex5_sh1[33] = (~(ex5_sh1_x_b[33] & ex5_sh1_y_b[33] & ex5_sh1_u_b[33]));
   assign ex5_sh1[34] = (~(ex5_sh1_x_b[34] & ex5_sh1_y_b[34] & ex5_sh1_u_b[34]));
   assign ex5_sh1[35] = (~(ex5_sh1_x_b[35] & ex5_sh1_y_b[35] & ex5_sh1_u_b[35]));
   assign ex5_sh1[36] = (~(ex5_sh1_x_b[36] & ex5_sh1_y_b[36]));
   assign ex5_sh1[37] = (~(ex5_sh1_x_b[37] & ex5_sh1_y_b[37]));
   assign ex5_sh1[38] = (~(ex5_sh1_x_b[38] & ex5_sh1_y_b[38]));
   assign ex5_sh1[39] = (~(ex5_sh1_x_b[39] & ex5_sh1_y_b[39]));
   assign ex5_sh1[40] = (~(ex5_sh1_x_b[40] & ex5_sh1_y_b[40]));
   assign ex5_sh1[41] = (~(ex5_sh1_x_b[41] & ex5_sh1_y_b[41]));
   assign ex5_sh1[42] = (~(ex5_sh1_x_b[42] & ex5_sh1_y_b[42]));
   assign ex5_sh1[43] = (~(ex5_sh1_x_b[43] & ex5_sh1_y_b[43]));
   assign ex5_sh1[44] = (~(ex5_sh1_x_b[44] & ex5_sh1_y_b[44]));
   assign ex5_sh1[45] = (~(ex5_sh1_x_b[45] & ex5_sh1_y_b[45]));
   assign ex5_sh1[46] = (~(ex5_sh1_x_b[46] & ex5_sh1_y_b[46]));
   assign ex5_sh1[47] = (~(ex5_sh1_x_b[47] & ex5_sh1_y_b[47]));
   assign ex5_sh1[48] = (~(ex5_sh1_x_b[48] & ex5_sh1_y_b[48]));
   assign ex5_sh1[49] = (~(ex5_sh1_x_b[49] & ex5_sh1_y_b[49]));
   assign ex5_sh1[50] = (~(ex5_sh1_x_b[50] & ex5_sh1_y_b[50]));
   assign ex5_sh1[51] = (~(ex5_sh1_x_b[51] & ex5_sh1_y_b[51]));
   assign ex5_sh1[52] = (~(ex5_sh1_x_b[52] & ex5_sh1_y_b[52]));
   assign ex5_sh1[53] = (~(ex5_sh1_x_b[53] & ex5_sh1_y_b[53]));
   assign ex5_sh1[54] = (~(ex5_sh1_x_b[54] & ex5_sh1_y_b[54]));
   assign ex5_sh1[55] = (~(ex5_sh1_x_b[55] & ex5_sh1_y_b[55]));
   assign ex5_sh1[56] = (~(ex5_sh1_x_b[56] & ex5_sh1_y_b[56]));
   assign ex5_sh1[57] = (~(ex5_sh1_x_b[57] & ex5_sh1_y_b[57]));
   assign ex5_sh1[58] = (~(ex5_sh1_x_b[58] & ex5_sh1_y_b[58]));
   assign ex5_sh1[59] = (~(ex5_sh1_x_b[59] & ex5_sh1_y_b[59]));
   assign ex5_sh1[60] = (~(ex5_sh1_x_b[60] & ex5_sh1_y_b[60]));
   assign ex5_sh1[61] = (~(ex5_sh1_x_b[61] & ex5_sh1_y_b[61]));
   assign ex5_sh1[62] = (~(ex5_sh1_x_b[62] & ex5_sh1_y_b[62]));
   assign ex5_sh1[63] = (~(ex5_sh1_x_b[63] & ex5_sh1_y_b[63]));
   assign ex5_sh1[64] = (~(ex5_sh1_x_b[64] & ex5_sh1_y_b[64]));
   assign ex5_sh1[65] = (~(ex5_sh1_x_b[65] & ex5_sh1_y_b[65] & ex5_sh1_z_b[65]));
   assign ex5_sh1[66] = (~(ex5_sh1_x_b[66] & ex5_sh1_y_b[66] & ex5_sh1_z_b[66]));
   assign ex5_sh1[67] = (~(ex5_sh1_x_b[67] & ex5_sh1_y_b[67] & ex5_sh1_z_b[67]));
   assign ex5_sh1[68] = (~(ex5_sh1_x_b[68] & ex5_sh1_y_b[68] & ex5_sh1_z_b[68]));
   assign ex5_sh1[69] = (~(ex5_sh1_x_b[69] & ex5_sh1_y_b[69] & ex5_sh1_z_b[69]));
   assign ex5_sh1[70] = (~(ex5_sh1_x_b[70] & ex5_sh1_y_b[70] & ex5_sh1_z_b[70]));
   assign ex5_sh1[71] = (~(ex5_sh1_x_b[71] & ex5_sh1_y_b[71] & ex5_sh1_z_b[71]));
   assign ex5_sh1[72] = (~(ex5_sh1_x_b[72] & ex5_sh1_y_b[72] & ex5_sh1_z_b[72]));
   assign ex5_sh1[73] = (~(ex5_sh1_x_b[73] & ex5_sh1_y_b[73] & ex5_sh1_z_b[73]));
   assign ex5_sh1[74] = (~(ex5_sh1_x_b[74] & ex5_sh1_y_b[74] & ex5_sh1_z_b[74]));
   assign ex5_sh1[75] = (~(ex5_sh1_x_b[75] & ex5_sh1_y_b[75] & ex5_sh1_z_b[75]));
   assign ex5_sh1[76] = (~(ex5_sh1_x_b[76] & ex5_sh1_y_b[76] & ex5_sh1_z_b[76]));
   assign ex5_sh1[77] = (~(ex5_sh1_x_b[77] & ex5_sh1_y_b[77] & ex5_sh1_z_b[77]));
   assign ex5_sh1[78] = (~(ex5_sh1_x_b[78] & ex5_sh1_y_b[78] & ex5_sh1_z_b[78]));
   assign ex5_sh1[79] = (~(ex5_sh1_x_b[79] & ex5_sh1_y_b[79] & ex5_sh1_z_b[79]));
   assign ex5_sh1[80] = (~(ex5_sh1_x_b[80] & ex5_sh1_y_b[80] & ex5_sh1_z_b[80]));
   assign ex5_sh1[81] = (~(ex5_sh1_x_b[81] & ex5_sh1_y_b[81] & ex5_sh1_z_b[81]));
   assign ex5_sh1[82] = (~(ex5_sh1_x_b[82] & ex5_sh1_y_b[82] & ex5_sh1_z_b[82]));
   assign ex5_sh1[83] = (~(ex5_sh1_x_b[83] & ex5_sh1_y_b[83] & ex5_sh1_z_b[83]));
   assign ex5_sh1[84] = (~(ex5_sh1_x_b[84] & ex5_sh1_y_b[84] & ex5_sh1_z_b[84]));
   assign ex5_sh1[85] = (~(ex5_sh1_x_b[85] & ex5_sh1_y_b[85] & ex5_sh1_z_b[85]));
   assign ex5_sh1[86] = (~(ex5_sh1_x_b[86] & ex5_sh1_y_b[86] & ex5_sh1_z_b[86]));
   assign ex5_sh1[87] = (~(ex5_sh1_x_b[87] & ex5_sh1_y_b[87] & ex5_sh1_z_b[87]));
   assign ex5_sh1[88] = (~(ex5_sh1_x_b[88] & ex5_sh1_y_b[88] & ex5_sh1_z_b[88]));
   assign ex5_sh1[89] = (~(ex5_sh1_x_b[89] & ex5_sh1_y_b[89] & ex5_sh1_z_b[89]));
   assign ex5_sh1[90] = (~(ex5_sh1_x_b[90] & ex5_sh1_y_b[90] & ex5_sh1_z_b[90]));
   assign ex5_sh1[91] = (~(ex5_sh1_x_b[91] & ex5_sh1_y_b[91] & ex5_sh1_z_b[91]));
   assign ex5_sh1[92] = (~(ex5_sh1_x_b[92] & ex5_sh1_y_b[92] & ex5_sh1_z_b[92]));
   assign ex5_sh1[93] = (~(ex5_sh1_x_b[93] & ex5_sh1_y_b[93] & ex5_sh1_z_b[93]));
   assign ex5_sh1[94] = (~(ex5_sh1_x_b[94] & ex5_sh1_y_b[94] & ex5_sh1_z_b[94]));
   assign ex5_sh1[95] = (~(ex5_sh1_x_b[95] & ex5_sh1_y_b[95] & ex5_sh1_z_b[95]));
   assign ex5_sh1[96] = (~(ex5_sh1_x_b[96] & ex5_sh1_y_b[96] & ex5_sh1_z_b[96]));
   assign ex5_sh1[97] = (~(ex5_sh1_x_b[97] & ex5_sh1_y_b[97] & ex5_sh1_z_b[97]));
   assign ex5_sh1[98] = (~(ex5_sh1_x_b[98] & ex5_sh1_y_b[98] & ex5_sh1_z_b[98]));
   assign ex5_sh1[99] = (~(ex5_sh1_x_b[99] & ex5_sh1_y_b[99] & ex5_sh1_z_b[99]));
   assign ex5_sh1[100] = (~(ex5_sh1_x_b[100] & ex5_sh1_z_b[100]));
   assign ex5_sh1[101] = (~(ex5_sh1_x_b[101] & ex5_sh1_z_b[101]));
   assign ex5_sh1[102] = (~(ex5_sh1_x_b[102] & ex5_sh1_z_b[102]));
   assign ex5_sh1[103] = (~(ex5_sh1_x_b[103] & ex5_sh1_z_b[103]));
   assign ex5_sh1[104] = (~(ex5_sh1_x_b[104] & ex5_sh1_z_b[104]));
   assign ex5_sh1[105] = (~(ex5_sh1_x_b[105] & ex5_sh1_z_b[105]));
   assign ex5_sh1[106] = (~(ex5_sh1_x_b[106] & ex5_sh1_z_b[106]));
   assign ex5_sh1[107] = (~(ex5_sh1_x_b[107] & ex5_sh1_z_b[107]));
   assign ex5_sh1[108] = (~(ex5_sh1_x_b[108] & ex5_sh1_z_b[108]));
   assign ex5_sh1[109] = (~(ex5_sh1_x_b[109] & ex5_sh1_z_b[109]));
   assign ex5_sh1[110] = (~(ex5_sh1_x_b[110] & ex5_sh1_z_b[110]));
   assign ex5_sh1[111] = (~(ex5_sh1_x_b[111] & ex5_sh1_z_b[111]));
   assign ex5_sh1[112] = (~(ex5_sh1_x_b[112] & ex5_sh1_z_b[112]));
   assign ex5_sh1[113] = (~(ex5_sh1_x_b[113] & ex5_sh1_z_b[113]));
   assign ex5_sh1[114] = (~(ex5_sh1_x_b[114] & ex5_sh1_z_b[114]));
   assign ex5_sh1[115] = (~(ex5_sh1_x_b[115] & ex5_sh1_z_b[115]));
   assign ex5_sh1[116] = (~(ex5_sh1_x_b[116] & ex5_sh1_z_b[116]));
   assign ex5_sh1[117] = (~(ex5_sh1_x_b[117] & ex5_sh1_z_b[117]));
   assign ex5_sh1[118] = (~(ex5_sh1_x_b[118] & ex5_sh1_z_b[118]));
   assign ex5_sh1[119] = (~(ex5_sh1_x_b[119]));
   assign ex5_sh1[120] = (~(ex5_sh1_x_b[120]));

   //----------------------------------------------------------------------------------

   assign ex5_sh2_x_b[0] = (~((ex5_sh1[0] & ex5_shctl_16[0]) | (ex5_sh1[16] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[1] = (~((ex5_sh1[1] & ex5_shctl_16[0]) | (ex5_sh1[17] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[2] = (~((ex5_sh1[2] & ex5_shctl_16[0]) | (ex5_sh1[18] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[3] = (~((ex5_sh1[3] & ex5_shctl_16[0]) | (ex5_sh1[19] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[4] = (~((ex5_sh1[4] & ex5_shctl_16[0]) | (ex5_sh1[20] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[5] = (~((ex5_sh1[5] & ex5_shctl_16[0]) | (ex5_sh1[21] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[6] = (~((ex5_sh1[6] & ex5_shctl_16[0]) | (ex5_sh1[22] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[7] = (~((ex5_sh1[7] & ex5_shctl_16[0]) | (ex5_sh1[23] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[8] = (~((ex5_sh1[8] & ex5_shctl_16[0]) | (ex5_sh1[24] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[9] = (~((ex5_sh1[9] & ex5_shctl_16[0]) | (ex5_sh1[25] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[10] = (~((ex5_sh1[10] & ex5_shctl_16[0]) | (ex5_sh1[26] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[11] = (~((ex5_sh1[11] & ex5_shctl_16[0]) | (ex5_sh1[27] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[12] = (~((ex5_sh1[12] & ex5_shctl_16[0]) | (ex5_sh1[28] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[13] = (~((ex5_sh1[13] & ex5_shctl_16[0]) | (ex5_sh1[29] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[14] = (~((ex5_sh1[14] & ex5_shctl_16[0]) | (ex5_sh1[30] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[15] = (~((ex5_sh1[15] & ex5_shctl_16[0]) | (ex5_sh1[31] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[16] = (~((ex5_sh1[16] & ex5_shctl_16[0]) | (ex5_sh1[32] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[17] = (~((ex5_sh1[17] & ex5_shctl_16[0]) | (ex5_sh1[33] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[18] = (~((ex5_sh1[18] & ex5_shctl_16[0]) | (ex5_sh1[34] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[19] = (~((ex5_sh1[19] & ex5_shctl_16[0]) | (ex5_sh1[35] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[20] = (~((ex5_sh1[20] & ex5_shctl_16[0]) | (ex5_sh1[36] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[21] = (~((ex5_sh1[21] & ex5_shctl_16[0]) | (ex5_sh1[37] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[22] = (~((ex5_sh1[22] & ex5_shctl_16[0]) | (ex5_sh1[38] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[23] = (~((ex5_sh1[23] & ex5_shctl_16[0]) | (ex5_sh1[39] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[24] = (~((ex5_sh1[24] & ex5_shctl_16[0]) | (ex5_sh1[40] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[25] = (~((ex5_sh1[25] & ex5_shctl_16[0]) | (ex5_sh1[41] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[26] = (~((ex5_sh1[26] & ex5_shctl_16[0]) | (ex5_sh1[42] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[27] = (~((ex5_sh1[27] & ex5_shctl_16[0]) | (ex5_sh1[43] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[28] = (~((ex5_sh1[28] & ex5_shctl_16[0]) | (ex5_sh1[44] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[29] = (~((ex5_sh1[29] & ex5_shctl_16[0]) | (ex5_sh1[45] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[30] = (~((ex5_sh1[30] & ex5_shctl_16[0]) | (ex5_sh1[46] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[31] = (~((ex5_sh1[31] & ex5_shctl_16[0]) | (ex5_sh1[47] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[32] = (~((ex5_sh1[32] & ex5_shctl_16[0]) | (ex5_sh1[48] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[33] = (~((ex5_sh1[33] & ex5_shctl_16[0]) | (ex5_sh1[49] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[34] = (~((ex5_sh1[34] & ex5_shctl_16[0]) | (ex5_sh1[50] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[35] = (~((ex5_sh1[35] & ex5_shctl_16[0]) | (ex5_sh1[51] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[36] = (~((ex5_sh1[36] & ex5_shctl_16[0]) | (ex5_sh1[52] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[37] = (~((ex5_sh1[37] & ex5_shctl_16[0]) | (ex5_sh1[53] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[38] = (~((ex5_sh1[38] & ex5_shctl_16[0]) | (ex5_sh1[54] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[39] = (~((ex5_sh1[39] & ex5_shctl_16[0]) | (ex5_sh1[55] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[40] = (~((ex5_sh1[40] & ex5_shctl_16[0]) | (ex5_sh1[56] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[41] = (~((ex5_sh1[41] & ex5_shctl_16[0]) | (ex5_sh1[57] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[42] = (~((ex5_sh1[42] & ex5_shctl_16[0]) | (ex5_sh1[58] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[43] = (~((ex5_sh1[43] & ex5_shctl_16[0]) | (ex5_sh1[59] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[44] = (~((ex5_sh1[44] & ex5_shctl_16[0]) | (ex5_sh1[60] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[45] = (~((ex5_sh1[45] & ex5_shctl_16[0]) | (ex5_sh1[61] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[46] = (~((ex5_sh1[46] & ex5_shctl_16[0]) | (ex5_sh1[62] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[47] = (~((ex5_sh1[47] & ex5_shctl_16[0]) | (ex5_sh1[63] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[48] = (~((ex5_sh1[48] & ex5_shctl_16[0]) | (ex5_sh1[64] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[49] = (~((ex5_sh1[49] & ex5_shctl_16[0]) | (ex5_sh1[65] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[50] = (~((ex5_sh1[50] & ex5_shctl_16[0]) | (ex5_sh1[66] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[51] = (~((ex5_sh1[51] & ex5_shctl_16[0]) | (ex5_sh1[67] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[52] = (~((ex5_sh1[52] & ex5_shctl_16[0]) | (ex5_sh1[68] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[53] = (~((ex5_sh1[53] & ex5_shctl_16[0]) | (ex5_sh1[69] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[54] = (~((ex5_sh1[54] & ex5_shctl_16[0]) | (ex5_sh1[70] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[55] = (~((ex5_sh1[55] & ex5_shctl_16[0]) | (ex5_sh1[71] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[56] = (~((ex5_sh1[56] & ex5_shctl_16[0]) | (ex5_sh1[72] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[57] = (~((ex5_sh1[57] & ex5_shctl_16[0]) | (ex5_sh1[73] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[58] = (~((ex5_sh1[58] & ex5_shctl_16[0]) | (ex5_sh1[74] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[59] = (~((ex5_sh1[59] & ex5_shctl_16[0]) | (ex5_sh1[75] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[60] = (~((ex5_sh1[60] & ex5_shctl_16[0]) | (ex5_sh1[76] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[61] = (~((ex5_sh1[61] & ex5_shctl_16[0]) | (ex5_sh1[77] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[62] = (~((ex5_sh1[62] & ex5_shctl_16[0]) | (ex5_sh1[78] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[63] = (~((ex5_sh1[63] & ex5_shctl_16[0]) | (ex5_sh1[79] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[64] = (~((ex5_sh1[64] & ex5_shctl_16[0]) | (ex5_sh1[80] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[65] = (~((ex5_sh1[65] & ex5_shctl_16[0]) | (ex5_sh1[81] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[66] = (~((ex5_sh1[66] & ex5_shctl_16[0]) | (ex5_sh1[82] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[67] = (~((ex5_sh1[67] & ex5_shctl_16[0]) | (ex5_sh1[83] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[68] = (~((ex5_sh1[68] & ex5_shctl_16[0]) | (ex5_sh1[84] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[69] = (~((ex5_sh1[69] & ex5_shctl_16[0]) | (ex5_sh1[85] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[70] = (~((ex5_sh1[70] & ex5_shctl_16[0]) | (ex5_sh1[86] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[71] = (~((ex5_sh1[71] & ex5_shctl_16[0]) | (ex5_sh1[87] & ex5_shctl_16[1])));
   assign ex5_sh2_x_b[72] = (~((ex5_sh1[72] & ex5_shctl_16[0]) | (ex5_sh1[88] & ex5_shctl_16[1])));

   assign ex5_sh2_y_b[0] = (~((ex5_sh1[32] & ex5_shctl_16[2]) | (ex5_sh1[48] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[1] = (~((ex5_sh1[33] & ex5_shctl_16[2]) | (ex5_sh1[49] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[2] = (~((ex5_sh1[34] & ex5_shctl_16[2]) | (ex5_sh1[50] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[3] = (~((ex5_sh1[35] & ex5_shctl_16[2]) | (ex5_sh1[51] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[4] = (~((ex5_sh1[36] & ex5_shctl_16[2]) | (ex5_sh1[52] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[5] = (~((ex5_sh1[37] & ex5_shctl_16[2]) | (ex5_sh1[53] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[6] = (~((ex5_sh1[38] & ex5_shctl_16[2]) | (ex5_sh1[54] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[7] = (~((ex5_sh1[39] & ex5_shctl_16[2]) | (ex5_sh1[55] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[8] = (~((ex5_sh1[40] & ex5_shctl_16[2]) | (ex5_sh1[56] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[9] = (~((ex5_sh1[41] & ex5_shctl_16[2]) | (ex5_sh1[57] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[10] = (~((ex5_sh1[42] & ex5_shctl_16[2]) | (ex5_sh1[58] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[11] = (~((ex5_sh1[43] & ex5_shctl_16[2]) | (ex5_sh1[59] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[12] = (~((ex5_sh1[44] & ex5_shctl_16[2]) | (ex5_sh1[60] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[13] = (~((ex5_sh1[45] & ex5_shctl_16[2]) | (ex5_sh1[61] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[14] = (~((ex5_sh1[46] & ex5_shctl_16[2]) | (ex5_sh1[62] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[15] = (~((ex5_sh1[47] & ex5_shctl_16[2]) | (ex5_sh1[63] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[16] = (~((ex5_sh1[48] & ex5_shctl_16[2]) | (ex5_sh1[64] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[17] = (~((ex5_sh1[49] & ex5_shctl_16[2]) | (ex5_sh1[65] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[18] = (~((ex5_sh1[50] & ex5_shctl_16[2]) | (ex5_sh1[66] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[19] = (~((ex5_sh1[51] & ex5_shctl_16[2]) | (ex5_sh1[67] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[20] = (~((ex5_sh1[52] & ex5_shctl_16[2]) | (ex5_sh1[68] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[21] = (~((ex5_sh1[53] & ex5_shctl_16[2]) | (ex5_sh1[69] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[22] = (~((ex5_sh1[54] & ex5_shctl_16[2]) | (ex5_sh1[70] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[23] = (~((ex5_sh1[55] & ex5_shctl_16[2]) | (ex5_sh1[71] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[24] = (~((ex5_sh1[56] & ex5_shctl_16[2]) | (ex5_sh1[72] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[25] = (~((ex5_sh1[57] & ex5_shctl_16[2]) | (ex5_sh1[73] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[26] = (~((ex5_sh1[58] & ex5_shctl_16[2]) | (ex5_sh1[74] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[27] = (~((ex5_sh1[59] & ex5_shctl_16[2]) | (ex5_sh1[75] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[28] = (~((ex5_sh1[60] & ex5_shctl_16[2]) | (ex5_sh1[76] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[29] = (~((ex5_sh1[61] & ex5_shctl_16[2]) | (ex5_sh1[77] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[30] = (~((ex5_sh1[62] & ex5_shctl_16[2]) | (ex5_sh1[78] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[31] = (~((ex5_sh1[63] & ex5_shctl_16[2]) | (ex5_sh1[79] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[32] = (~((ex5_sh1[64] & ex5_shctl_16[2]) | (ex5_sh1[80] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[33] = (~((ex5_sh1[65] & ex5_shctl_16[2]) | (ex5_sh1[81] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[34] = (~((ex5_sh1[66] & ex5_shctl_16[2]) | (ex5_sh1[82] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[35] = (~((ex5_sh1[67] & ex5_shctl_16[2]) | (ex5_sh1[83] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[36] = (~((ex5_sh1[68] & ex5_shctl_16[2]) | (ex5_sh1[84] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[37] = (~((ex5_sh1[69] & ex5_shctl_16[2]) | (ex5_sh1[85] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[38] = (~((ex5_sh1[70] & ex5_shctl_16[2]) | (ex5_sh1[86] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[39] = (~((ex5_sh1[71] & ex5_shctl_16[2]) | (ex5_sh1[87] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[40] = (~((ex5_sh1[72] & ex5_shctl_16[2]) | (ex5_sh1[88] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[41] = (~((ex5_sh1[73] & ex5_shctl_16[2]) | (ex5_sh1[89] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[42] = (~((ex5_sh1[74] & ex5_shctl_16[2]) | (ex5_sh1[90] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[43] = (~((ex5_sh1[75] & ex5_shctl_16[2]) | (ex5_sh1[91] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[44] = (~((ex5_sh1[76] & ex5_shctl_16[2]) | (ex5_sh1[92] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[45] = (~((ex5_sh1[77] & ex5_shctl_16[2]) | (ex5_sh1[93] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[46] = (~((ex5_sh1[78] & ex5_shctl_16[2]) | (ex5_sh1[94] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[47] = (~((ex5_sh1[79] & ex5_shctl_16[2]) | (ex5_sh1[95] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[48] = (~((ex5_sh1[80] & ex5_shctl_16[2]) | (ex5_sh1[96] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[49] = (~((ex5_sh1[81] & ex5_shctl_16[2]) | (ex5_sh1[97] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[50] = (~((ex5_sh1[82] & ex5_shctl_16[2]) | (ex5_sh1[98] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[51] = (~((ex5_sh1[83] & ex5_shctl_16[2]) | (ex5_sh1[99] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[52] = (~((ex5_sh1[84] & ex5_shctl_16[2]) | (ex5_sh1[100] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[53] = (~((ex5_sh1[85] & ex5_shctl_16[2]) | (ex5_sh1[101] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[54] = (~((ex5_sh1[86] & ex5_shctl_16[2]) | (ex5_sh1[102] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[55] = (~((ex5_sh1[87] & ex5_shctl_16[2]) | (ex5_sh1[103] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[56] = (~((ex5_sh1[88] & ex5_shctl_16[2]) | (ex5_sh1[104] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[57] = (~((ex5_sh1[89] & ex5_shctl_16[2]) | (ex5_sh1[105] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[58] = (~((ex5_sh1[90] & ex5_shctl_16[2]) | (ex5_sh1[106] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[59] = (~((ex5_sh1[91] & ex5_shctl_16[2]) | (ex5_sh1[107] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[60] = (~((ex5_sh1[92] & ex5_shctl_16[2]) | (ex5_sh1[108] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[61] = (~((ex5_sh1[93] & ex5_shctl_16[2]) | (ex5_sh1[109] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[62] = (~((ex5_sh1[94] & ex5_shctl_16[2]) | (ex5_sh1[110] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[63] = (~((ex5_sh1[95] & ex5_shctl_16[2]) | (ex5_sh1[111] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[64] = (~((ex5_sh1[96] & ex5_shctl_16[2]) | (ex5_sh1[112] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[65] = (~((ex5_sh1[97] & ex5_shctl_16[2]) | (ex5_sh1[113] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[66] = (~((ex5_sh1[98] & ex5_shctl_16[2]) | (ex5_sh1[114] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[67] = (~((ex5_sh1[99] & ex5_shctl_16[2]) | (ex5_sh1[115] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[68] = (~((ex5_sh1[100] & ex5_shctl_16[2]) | (ex5_sh1[116] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[69] = (~((ex5_sh1[101] & ex5_shctl_16[2]) | (ex5_sh1[117] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[70] = (~((ex5_sh1[102] & ex5_shctl_16[2]) | (ex5_sh1[118] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[71] = (~((ex5_sh1[103] & ex5_shctl_16[2]) | (ex5_sh1[119] & ex5_shctl_16[3])));
   assign ex5_sh2_y_b[72] = (~((ex5_sh1[104] & ex5_shctl_16[2]) | (ex5_sh1[120] & ex5_shctl_16[3])));

   assign ex5_sh2[0] = (~(ex5_sh2_x_b[0] & ex5_sh2_y_b[0]));
   assign ex5_sh2[1] = (~(ex5_sh2_x_b[1] & ex5_sh2_y_b[1]));
   assign ex5_sh2[2] = (~(ex5_sh2_x_b[2] & ex5_sh2_y_b[2]));
   assign ex5_sh2[3] = (~(ex5_sh2_x_b[3] & ex5_sh2_y_b[3]));
   assign ex5_sh2[4] = (~(ex5_sh2_x_b[4] & ex5_sh2_y_b[4]));
   assign ex5_sh2[5] = (~(ex5_sh2_x_b[5] & ex5_sh2_y_b[5]));
   assign ex5_sh2[6] = (~(ex5_sh2_x_b[6] & ex5_sh2_y_b[6]));
   assign ex5_sh2[7] = (~(ex5_sh2_x_b[7] & ex5_sh2_y_b[7]));
   assign ex5_sh2[8] = (~(ex5_sh2_x_b[8] & ex5_sh2_y_b[8]));
   assign ex5_sh2[9] = (~(ex5_sh2_x_b[9] & ex5_sh2_y_b[9]));
   assign ex5_sh2[10] = (~(ex5_sh2_x_b[10] & ex5_sh2_y_b[10]));
   assign ex5_sh2[11] = (~(ex5_sh2_x_b[11] & ex5_sh2_y_b[11]));
   assign ex5_sh2[12] = (~(ex5_sh2_x_b[12] & ex5_sh2_y_b[12]));
   assign ex5_sh2[13] = (~(ex5_sh2_x_b[13] & ex5_sh2_y_b[13]));
   assign ex5_sh2[14] = (~(ex5_sh2_x_b[14] & ex5_sh2_y_b[14]));
   assign ex5_sh2[15] = (~(ex5_sh2_x_b[15] & ex5_sh2_y_b[15]));
   assign ex5_sh2[16] = (~(ex5_sh2_x_b[16] & ex5_sh2_y_b[16]));
   assign ex5_sh2[17] = (~(ex5_sh2_x_b[17] & ex5_sh2_y_b[17]));
   assign ex5_sh2[18] = (~(ex5_sh2_x_b[18] & ex5_sh2_y_b[18]));
   assign ex5_sh2[19] = (~(ex5_sh2_x_b[19] & ex5_sh2_y_b[19]));
   assign ex5_sh2[20] = (~(ex5_sh2_x_b[20] & ex5_sh2_y_b[20]));
   assign ex5_sh2[21] = (~(ex5_sh2_x_b[21] & ex5_sh2_y_b[21]));
   assign ex5_sh2[22] = (~(ex5_sh2_x_b[22] & ex5_sh2_y_b[22]));
   assign ex5_sh2[23] = (~(ex5_sh2_x_b[23] & ex5_sh2_y_b[23]));
   assign ex5_sh2[24] = (~(ex5_sh2_x_b[24] & ex5_sh2_y_b[24]));
   assign ex5_sh2[25] = (~(ex5_sh2_x_b[25] & ex5_sh2_y_b[25]));
   assign ex5_sh2[26] = (~(ex5_sh2_x_b[26] & ex5_sh2_y_b[26]));
   assign ex5_sh2[27] = (~(ex5_sh2_x_b[27] & ex5_sh2_y_b[27]));
   assign ex5_sh2[28] = (~(ex5_sh2_x_b[28] & ex5_sh2_y_b[28]));
   assign ex5_sh2[29] = (~(ex5_sh2_x_b[29] & ex5_sh2_y_b[29]));
   assign ex5_sh2[30] = (~(ex5_sh2_x_b[30] & ex5_sh2_y_b[30]));
   assign ex5_sh2[31] = (~(ex5_sh2_x_b[31] & ex5_sh2_y_b[31]));
   assign ex5_sh2[32] = (~(ex5_sh2_x_b[32] & ex5_sh2_y_b[32]));
   assign ex5_sh2[33] = (~(ex5_sh2_x_b[33] & ex5_sh2_y_b[33]));
   assign ex5_sh2[34] = (~(ex5_sh2_x_b[34] & ex5_sh2_y_b[34]));
   assign ex5_sh2[35] = (~(ex5_sh2_x_b[35] & ex5_sh2_y_b[35]));
   assign ex5_sh2[36] = (~(ex5_sh2_x_b[36] & ex5_sh2_y_b[36]));
   assign ex5_sh2[37] = (~(ex5_sh2_x_b[37] & ex5_sh2_y_b[37]));
   assign ex5_sh2[38] = (~(ex5_sh2_x_b[38] & ex5_sh2_y_b[38]));
   assign ex5_sh2[39] = (~(ex5_sh2_x_b[39] & ex5_sh2_y_b[39]));
   assign ex5_sh2[40] = (~(ex5_sh2_x_b[40] & ex5_sh2_y_b[40]));
   assign ex5_sh2[41] = (~(ex5_sh2_x_b[41] & ex5_sh2_y_b[41]));
   assign ex5_sh2[42] = (~(ex5_sh2_x_b[42] & ex5_sh2_y_b[42]));
   assign ex5_sh2[43] = (~(ex5_sh2_x_b[43] & ex5_sh2_y_b[43]));
   assign ex5_sh2[44] = (~(ex5_sh2_x_b[44] & ex5_sh2_y_b[44]));
   assign ex5_sh2[45] = (~(ex5_sh2_x_b[45] & ex5_sh2_y_b[45]));
   assign ex5_sh2[46] = (~(ex5_sh2_x_b[46] & ex5_sh2_y_b[46]));
   assign ex5_sh2[47] = (~(ex5_sh2_x_b[47] & ex5_sh2_y_b[47]));
   assign ex5_sh2[48] = (~(ex5_sh2_x_b[48] & ex5_sh2_y_b[48]));
   assign ex5_sh2[49] = (~(ex5_sh2_x_b[49] & ex5_sh2_y_b[49]));
   assign ex5_sh2[50] = (~(ex5_sh2_x_b[50] & ex5_sh2_y_b[50]));
   assign ex5_sh2[51] = (~(ex5_sh2_x_b[51] & ex5_sh2_y_b[51]));
   assign ex5_sh2[52] = (~(ex5_sh2_x_b[52] & ex5_sh2_y_b[52]));
   assign ex5_sh2[53] = (~(ex5_sh2_x_b[53] & ex5_sh2_y_b[53]));
   assign ex5_sh2[54] = (~(ex5_sh2_x_b[54] & ex5_sh2_y_b[54]));
   assign ex5_sh2[55] = (~(ex5_sh2_x_b[55] & ex5_sh2_y_b[55]));
   assign ex5_sh2[56] = (~(ex5_sh2_x_b[56] & ex5_sh2_y_b[56]));
   assign ex5_sh2[57] = (~(ex5_sh2_x_b[57] & ex5_sh2_y_b[57]));
   assign ex5_sh2[58] = (~(ex5_sh2_x_b[58] & ex5_sh2_y_b[58]));
   assign ex5_sh2[59] = (~(ex5_sh2_x_b[59] & ex5_sh2_y_b[59]));
   assign ex5_sh2[60] = (~(ex5_sh2_x_b[60] & ex5_sh2_y_b[60]));
   assign ex5_sh2[61] = (~(ex5_sh2_x_b[61] & ex5_sh2_y_b[61]));
   assign ex5_sh2[62] = (~(ex5_sh2_x_b[62] & ex5_sh2_y_b[62]));
   assign ex5_sh2[63] = (~(ex5_sh2_x_b[63] & ex5_sh2_y_b[63]));
   assign ex5_sh2[64] = (~(ex5_sh2_x_b[64] & ex5_sh2_y_b[64]));
   assign ex5_sh2[65] = (~(ex5_sh2_x_b[65] & ex5_sh2_y_b[65]));
   assign ex5_sh2[66] = (~(ex5_sh2_x_b[66] & ex5_sh2_y_b[66]));
   assign ex5_sh2[67] = (~(ex5_sh2_x_b[67] & ex5_sh2_y_b[67]));
   assign ex5_sh2[68] = (~(ex5_sh2_x_b[68] & ex5_sh2_y_b[68]));
   assign ex5_sh2[69] = (~(ex5_sh2_x_b[69] & ex5_sh2_y_b[69]));
   assign ex5_sh2[70] = (~(ex5_sh2_x_b[70] & ex5_sh2_y_b[70]));
   assign ex5_sh2[71] = (~(ex5_sh2_x_b[71] & ex5_sh2_y_b[71]));
   assign ex5_sh2[72] = (~(ex5_sh2_x_b[72] & ex5_sh2_y_b[72]));

   //---------------------------------------------

   assign ex5_sh3_x_b[0] = (~((ex5_sh2[0] & ex5_shctl_04[0]) | (ex5_sh2[4] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[1] = (~((ex5_sh2[1] & ex5_shctl_04[0]) | (ex5_sh2[5] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[2] = (~((ex5_sh2[2] & ex5_shctl_04[0]) | (ex5_sh2[6] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[3] = (~((ex5_sh2[3] & ex5_shctl_04[0]) | (ex5_sh2[7] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[4] = (~((ex5_sh2[4] & ex5_shctl_04[0]) | (ex5_sh2[8] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[5] = (~((ex5_sh2[5] & ex5_shctl_04[0]) | (ex5_sh2[9] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[6] = (~((ex5_sh2[6] & ex5_shctl_04[0]) | (ex5_sh2[10] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[7] = (~((ex5_sh2[7] & ex5_shctl_04[0]) | (ex5_sh2[11] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[8] = (~((ex5_sh2[8] & ex5_shctl_04[0]) | (ex5_sh2[12] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[9] = (~((ex5_sh2[9] & ex5_shctl_04[0]) | (ex5_sh2[13] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[10] = (~((ex5_sh2[10] & ex5_shctl_04[0]) | (ex5_sh2[14] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[11] = (~((ex5_sh2[11] & ex5_shctl_04[0]) | (ex5_sh2[15] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[12] = (~((ex5_sh2[12] & ex5_shctl_04[0]) | (ex5_sh2[16] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[13] = (~((ex5_sh2[13] & ex5_shctl_04[0]) | (ex5_sh2[17] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[14] = (~((ex5_sh2[14] & ex5_shctl_04[0]) | (ex5_sh2[18] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[15] = (~((ex5_sh2[15] & ex5_shctl_04[0]) | (ex5_sh2[19] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[16] = (~((ex5_sh2[16] & ex5_shctl_04[0]) | (ex5_sh2[20] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[17] = (~((ex5_sh2[17] & ex5_shctl_04[0]) | (ex5_sh2[21] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[18] = (~((ex5_sh2[18] & ex5_shctl_04[0]) | (ex5_sh2[22] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[19] = (~((ex5_sh2[19] & ex5_shctl_04[0]) | (ex5_sh2[23] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[20] = (~((ex5_sh2[20] & ex5_shctl_04[0]) | (ex5_sh2[24] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[21] = (~((ex5_sh2[21] & ex5_shctl_04[0]) | (ex5_sh2[25] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[22] = (~((ex5_sh2[22] & ex5_shctl_04[0]) | (ex5_sh2[26] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[23] = (~((ex5_sh2[23] & ex5_shctl_04[0]) | (ex5_sh2[27] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[24] = (~((ex5_sh2[24] & ex5_shctl_04[0]) | (ex5_sh2[28] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[25] = (~((ex5_sh2[25] & ex5_shctl_04[0]) | (ex5_sh2[29] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[26] = (~((ex5_sh2[26] & ex5_shctl_04[0]) | (ex5_sh2[30] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[27] = (~((ex5_sh2[27] & ex5_shctl_04[0]) | (ex5_sh2[31] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[28] = (~((ex5_sh2[28] & ex5_shctl_04[0]) | (ex5_sh2[32] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[29] = (~((ex5_sh2[29] & ex5_shctl_04[0]) | (ex5_sh2[33] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[30] = (~((ex5_sh2[30] & ex5_shctl_04[0]) | (ex5_sh2[34] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[31] = (~((ex5_sh2[31] & ex5_shctl_04[0]) | (ex5_sh2[35] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[32] = (~((ex5_sh2[32] & ex5_shctl_04[0]) | (ex5_sh2[36] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[33] = (~((ex5_sh2[33] & ex5_shctl_04[0]) | (ex5_sh2[37] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[34] = (~((ex5_sh2[34] & ex5_shctl_04[0]) | (ex5_sh2[38] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[35] = (~((ex5_sh2[35] & ex5_shctl_04[0]) | (ex5_sh2[39] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[36] = (~((ex5_sh2[36] & ex5_shctl_04[0]) | (ex5_sh2[40] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[37] = (~((ex5_sh2[37] & ex5_shctl_04[0]) | (ex5_sh2[41] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[38] = (~((ex5_sh2[38] & ex5_shctl_04[0]) | (ex5_sh2[42] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[39] = (~((ex5_sh2[39] & ex5_shctl_04[0]) | (ex5_sh2[43] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[40] = (~((ex5_sh2[40] & ex5_shctl_04[0]) | (ex5_sh2[44] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[41] = (~((ex5_sh2[41] & ex5_shctl_04[0]) | (ex5_sh2[45] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[42] = (~((ex5_sh2[42] & ex5_shctl_04[0]) | (ex5_sh2[46] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[43] = (~((ex5_sh2[43] & ex5_shctl_04[0]) | (ex5_sh2[47] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[44] = (~((ex5_sh2[44] & ex5_shctl_04[0]) | (ex5_sh2[48] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[45] = (~((ex5_sh2[45] & ex5_shctl_04[0]) | (ex5_sh2[49] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[46] = (~((ex5_sh2[46] & ex5_shctl_04[0]) | (ex5_sh2[50] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[47] = (~((ex5_sh2[47] & ex5_shctl_04[0]) | (ex5_sh2[51] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[48] = (~((ex5_sh2[48] & ex5_shctl_04[0]) | (ex5_sh2[52] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[49] = (~((ex5_sh2[49] & ex5_shctl_04[0]) | (ex5_sh2[53] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[50] = (~((ex5_sh2[50] & ex5_shctl_04[0]) | (ex5_sh2[54] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[51] = (~((ex5_sh2[51] & ex5_shctl_04[0]) | (ex5_sh2[55] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[52] = (~((ex5_sh2[52] & ex5_shctl_04[0]) | (ex5_sh2[56] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[53] = (~((ex5_sh2[53] & ex5_shctl_04[0]) | (ex5_sh2[57] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[54] = (~((ex5_sh2[54] & ex5_shctl_04[0]) | (ex5_sh2[58] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[55] = (~((ex5_sh2[55] & ex5_shctl_04[0]) | (ex5_sh2[59] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[56] = (~((ex5_sh2[56] & ex5_shctl_04[0]) | (ex5_sh2[60] & ex5_shctl_04[1])));
   assign ex5_sh3_x_b[57] = (~((ex5_sh2[57] & ex5_shctl_04[0]) | (ex5_sh2[61] & ex5_shctl_04[1])));

   assign ex5_sh3_y_b[0] = (~((ex5_sh2[8] & ex5_shctl_04[2]) | (ex5_sh2[12] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[1] = (~((ex5_sh2[9] & ex5_shctl_04[2]) | (ex5_sh2[13] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[2] = (~((ex5_sh2[10] & ex5_shctl_04[2]) | (ex5_sh2[14] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[3] = (~((ex5_sh2[11] & ex5_shctl_04[2]) | (ex5_sh2[15] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[4] = (~((ex5_sh2[12] & ex5_shctl_04[2]) | (ex5_sh2[16] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[5] = (~((ex5_sh2[13] & ex5_shctl_04[2]) | (ex5_sh2[17] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[6] = (~((ex5_sh2[14] & ex5_shctl_04[2]) | (ex5_sh2[18] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[7] = (~((ex5_sh2[15] & ex5_shctl_04[2]) | (ex5_sh2[19] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[8] = (~((ex5_sh2[16] & ex5_shctl_04[2]) | (ex5_sh2[20] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[9] = (~((ex5_sh2[17] & ex5_shctl_04[2]) | (ex5_sh2[21] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[10] = (~((ex5_sh2[18] & ex5_shctl_04[2]) | (ex5_sh2[22] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[11] = (~((ex5_sh2[19] & ex5_shctl_04[2]) | (ex5_sh2[23] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[12] = (~((ex5_sh2[20] & ex5_shctl_04[2]) | (ex5_sh2[24] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[13] = (~((ex5_sh2[21] & ex5_shctl_04[2]) | (ex5_sh2[25] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[14] = (~((ex5_sh2[22] & ex5_shctl_04[2]) | (ex5_sh2[26] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[15] = (~((ex5_sh2[23] & ex5_shctl_04[2]) | (ex5_sh2[27] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[16] = (~((ex5_sh2[24] & ex5_shctl_04[2]) | (ex5_sh2[28] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[17] = (~((ex5_sh2[25] & ex5_shctl_04[2]) | (ex5_sh2[29] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[18] = (~((ex5_sh2[26] & ex5_shctl_04[2]) | (ex5_sh2[30] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[19] = (~((ex5_sh2[27] & ex5_shctl_04[2]) | (ex5_sh2[31] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[20] = (~((ex5_sh2[28] & ex5_shctl_04[2]) | (ex5_sh2[32] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[21] = (~((ex5_sh2[29] & ex5_shctl_04[2]) | (ex5_sh2[33] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[22] = (~((ex5_sh2[30] & ex5_shctl_04[2]) | (ex5_sh2[34] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[23] = (~((ex5_sh2[31] & ex5_shctl_04[2]) | (ex5_sh2[35] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[24] = (~((ex5_sh2[32] & ex5_shctl_04[2]) | (ex5_sh2[36] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[25] = (~((ex5_sh2[33] & ex5_shctl_04[2]) | (ex5_sh2[37] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[26] = (~((ex5_sh2[34] & ex5_shctl_04[2]) | (ex5_sh2[38] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[27] = (~((ex5_sh2[35] & ex5_shctl_04[2]) | (ex5_sh2[39] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[28] = (~((ex5_sh2[36] & ex5_shctl_04[2]) | (ex5_sh2[40] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[29] = (~((ex5_sh2[37] & ex5_shctl_04[2]) | (ex5_sh2[41] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[30] = (~((ex5_sh2[38] & ex5_shctl_04[2]) | (ex5_sh2[42] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[31] = (~((ex5_sh2[39] & ex5_shctl_04[2]) | (ex5_sh2[43] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[32] = (~((ex5_sh2[40] & ex5_shctl_04[2]) | (ex5_sh2[44] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[33] = (~((ex5_sh2[41] & ex5_shctl_04[2]) | (ex5_sh2[45] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[34] = (~((ex5_sh2[42] & ex5_shctl_04[2]) | (ex5_sh2[46] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[35] = (~((ex5_sh2[43] & ex5_shctl_04[2]) | (ex5_sh2[47] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[36] = (~((ex5_sh2[44] & ex5_shctl_04[2]) | (ex5_sh2[48] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[37] = (~((ex5_sh2[45] & ex5_shctl_04[2]) | (ex5_sh2[49] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[38] = (~((ex5_sh2[46] & ex5_shctl_04[2]) | (ex5_sh2[50] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[39] = (~((ex5_sh2[47] & ex5_shctl_04[2]) | (ex5_sh2[51] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[40] = (~((ex5_sh2[48] & ex5_shctl_04[2]) | (ex5_sh2[52] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[41] = (~((ex5_sh2[49] & ex5_shctl_04[2]) | (ex5_sh2[53] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[42] = (~((ex5_sh2[50] & ex5_shctl_04[2]) | (ex5_sh2[54] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[43] = (~((ex5_sh2[51] & ex5_shctl_04[2]) | (ex5_sh2[55] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[44] = (~((ex5_sh2[52] & ex5_shctl_04[2]) | (ex5_sh2[56] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[45] = (~((ex5_sh2[53] & ex5_shctl_04[2]) | (ex5_sh2[57] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[46] = (~((ex5_sh2[54] & ex5_shctl_04[2]) | (ex5_sh2[58] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[47] = (~((ex5_sh2[55] & ex5_shctl_04[2]) | (ex5_sh2[59] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[48] = (~((ex5_sh2[56] & ex5_shctl_04[2]) | (ex5_sh2[60] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[49] = (~((ex5_sh2[57] & ex5_shctl_04[2]) | (ex5_sh2[61] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[50] = (~((ex5_sh2[58] & ex5_shctl_04[2]) | (ex5_sh2[62] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[51] = (~((ex5_sh2[59] & ex5_shctl_04[2]) | (ex5_sh2[63] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[52] = (~((ex5_sh2[60] & ex5_shctl_04[2]) | (ex5_sh2[64] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[53] = (~((ex5_sh2[61] & ex5_shctl_04[2]) | (ex5_sh2[65] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[54] = (~((ex5_sh2[62] & ex5_shctl_04[2]) | (ex5_sh2[66] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[55] = (~((ex5_sh2[63] & ex5_shctl_04[2]) | (ex5_sh2[67] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[56] = (~((ex5_sh2[64] & ex5_shctl_04[2]) | (ex5_sh2[68] & ex5_shctl_04[3])));
   assign ex5_sh3_y_b[57] = (~((ex5_sh2[65] & ex5_shctl_04[2]) | (ex5_sh2[69] & ex5_shctl_04[3])));

   assign ex5_sh3[0] = (~(ex5_sh3_x_b[0] & ex5_sh3_y_b[0]));
   assign ex5_sh3[1] = (~(ex5_sh3_x_b[1] & ex5_sh3_y_b[1]));
   assign ex5_sh3[2] = (~(ex5_sh3_x_b[2] & ex5_sh3_y_b[2]));
   assign ex5_sh3[3] = (~(ex5_sh3_x_b[3] & ex5_sh3_y_b[3]));
   assign ex5_sh3[4] = (~(ex5_sh3_x_b[4] & ex5_sh3_y_b[4]));
   assign ex5_sh3[5] = (~(ex5_sh3_x_b[5] & ex5_sh3_y_b[5]));
   assign ex5_sh3[6] = (~(ex5_sh3_x_b[6] & ex5_sh3_y_b[6]));
   assign ex5_sh3[7] = (~(ex5_sh3_x_b[7] & ex5_sh3_y_b[7]));
   assign ex5_sh3[8] = (~(ex5_sh3_x_b[8] & ex5_sh3_y_b[8]));
   assign ex5_sh3[9] = (~(ex5_sh3_x_b[9] & ex5_sh3_y_b[9]));
   assign ex5_sh3[10] = (~(ex5_sh3_x_b[10] & ex5_sh3_y_b[10]));
   assign ex5_sh3[11] = (~(ex5_sh3_x_b[11] & ex5_sh3_y_b[11]));
   assign ex5_sh3[12] = (~(ex5_sh3_x_b[12] & ex5_sh3_y_b[12]));
   assign ex5_sh3[13] = (~(ex5_sh3_x_b[13] & ex5_sh3_y_b[13]));
   assign ex5_sh3[14] = (~(ex5_sh3_x_b[14] & ex5_sh3_y_b[14]));
   assign ex5_sh3[15] = (~(ex5_sh3_x_b[15] & ex5_sh3_y_b[15]));
   assign ex5_sh3[16] = (~(ex5_sh3_x_b[16] & ex5_sh3_y_b[16]));
   assign ex5_sh3[17] = (~(ex5_sh3_x_b[17] & ex5_sh3_y_b[17]));
   assign ex5_sh3[18] = (~(ex5_sh3_x_b[18] & ex5_sh3_y_b[18]));
   assign ex5_sh3[19] = (~(ex5_sh3_x_b[19] & ex5_sh3_y_b[19]));
   assign ex5_sh3[20] = (~(ex5_sh3_x_b[20] & ex5_sh3_y_b[20]));
   assign ex5_sh3[21] = (~(ex5_sh3_x_b[21] & ex5_sh3_y_b[21]));
   assign ex5_sh3[22] = (~(ex5_sh3_x_b[22] & ex5_sh3_y_b[22]));
   assign ex5_sh3[23] = (~(ex5_sh3_x_b[23] & ex5_sh3_y_b[23]));
   assign ex5_sh3[24] = (~(ex5_sh3_x_b[24] & ex5_sh3_y_b[24]));
   assign ex5_sh3[25] = (~(ex5_sh3_x_b[25] & ex5_sh3_y_b[25]));
   assign ex5_sh3[26] = (~(ex5_sh3_x_b[26] & ex5_sh3_y_b[26]));
   assign ex5_sh3[27] = (~(ex5_sh3_x_b[27] & ex5_sh3_y_b[27]));
   assign ex5_sh3[28] = (~(ex5_sh3_x_b[28] & ex5_sh3_y_b[28]));
   assign ex5_sh3[29] = (~(ex5_sh3_x_b[29] & ex5_sh3_y_b[29]));
   assign ex5_sh3[30] = (~(ex5_sh3_x_b[30] & ex5_sh3_y_b[30]));
   assign ex5_sh3[31] = (~(ex5_sh3_x_b[31] & ex5_sh3_y_b[31]));
   assign ex5_sh3[32] = (~(ex5_sh3_x_b[32] & ex5_sh3_y_b[32]));
   assign ex5_sh3[33] = (~(ex5_sh3_x_b[33] & ex5_sh3_y_b[33]));
   assign ex5_sh3[34] = (~(ex5_sh3_x_b[34] & ex5_sh3_y_b[34]));
   assign ex5_sh3[35] = (~(ex5_sh3_x_b[35] & ex5_sh3_y_b[35]));
   assign ex5_sh3[36] = (~(ex5_sh3_x_b[36] & ex5_sh3_y_b[36]));
   assign ex5_sh3[37] = (~(ex5_sh3_x_b[37] & ex5_sh3_y_b[37]));
   assign ex5_sh3[38] = (~(ex5_sh3_x_b[38] & ex5_sh3_y_b[38]));
   assign ex5_sh3[39] = (~(ex5_sh3_x_b[39] & ex5_sh3_y_b[39]));
   assign ex5_sh3[40] = (~(ex5_sh3_x_b[40] & ex5_sh3_y_b[40]));
   assign ex5_sh3[41] = (~(ex5_sh3_x_b[41] & ex5_sh3_y_b[41]));
   assign ex5_sh3[42] = (~(ex5_sh3_x_b[42] & ex5_sh3_y_b[42]));
   assign ex5_sh3[43] = (~(ex5_sh3_x_b[43] & ex5_sh3_y_b[43]));
   assign ex5_sh3[44] = (~(ex5_sh3_x_b[44] & ex5_sh3_y_b[44]));
   assign ex5_sh3[45] = (~(ex5_sh3_x_b[45] & ex5_sh3_y_b[45]));
   assign ex5_sh3[46] = (~(ex5_sh3_x_b[46] & ex5_sh3_y_b[46]));
   assign ex5_sh3[47] = (~(ex5_sh3_x_b[47] & ex5_sh3_y_b[47]));
   assign ex5_sh3[48] = (~(ex5_sh3_x_b[48] & ex5_sh3_y_b[48]));
   assign ex5_sh3[49] = (~(ex5_sh3_x_b[49] & ex5_sh3_y_b[49]));
   assign ex5_sh3[50] = (~(ex5_sh3_x_b[50] & ex5_sh3_y_b[50]));
   assign ex5_sh3[51] = (~(ex5_sh3_x_b[51] & ex5_sh3_y_b[51]));
   assign ex5_sh3[52] = (~(ex5_sh3_x_b[52] & ex5_sh3_y_b[52]));
   assign ex5_sh3[53] = (~(ex5_sh3_x_b[53] & ex5_sh3_y_b[53]));
   assign ex5_sh3[54] = (~(ex5_sh3_x_b[54] & ex5_sh3_y_b[54]));
   assign ex5_sh3[55] = (~(ex5_sh3_x_b[55] & ex5_sh3_y_b[55]));
   assign ex5_sh3[56] = (~(ex5_sh3_x_b[56] & ex5_sh3_y_b[56]));
   assign ex5_sh3[57] = (~(ex5_sh3_x_b[57] & ex5_sh3_y_b[57]));

   //---------------------------------------------

   assign ex5_sh4_x_00_b = (~((ex5_sh3[0] & ex5_shctl_01[0]) | (ex5_sh3[1] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[0] = (~((ex5_sh3[0] & ex5_shctl_01[0]) | (ex5_sh3[1] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[1] = (~((ex5_sh3[1] & ex5_shctl_01[0]) | (ex5_sh3[2] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[2] = (~((ex5_sh3[2] & ex5_shctl_01[0]) | (ex5_sh3[3] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[3] = (~((ex5_sh3[3] & ex5_shctl_01[0]) | (ex5_sh3[4] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[4] = (~((ex5_sh3[4] & ex5_shctl_01[0]) | (ex5_sh3[5] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[5] = (~((ex5_sh3[5] & ex5_shctl_01[0]) | (ex5_sh3[6] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[6] = (~((ex5_sh3[6] & ex5_shctl_01[0]) | (ex5_sh3[7] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[7] = (~((ex5_sh3[7] & ex5_shctl_01[0]) | (ex5_sh3[8] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[8] = (~((ex5_sh3[8] & ex5_shctl_01[0]) | (ex5_sh3[9] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[9] = (~((ex5_sh3[9] & ex5_shctl_01[0]) | (ex5_sh3[10] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[10] = (~((ex5_sh3[10] & ex5_shctl_01[0]) | (ex5_sh3[11] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[11] = (~((ex5_sh3[11] & ex5_shctl_01[0]) | (ex5_sh3[12] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[12] = (~((ex5_sh3[12] & ex5_shctl_01[0]) | (ex5_sh3[13] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[13] = (~((ex5_sh3[13] & ex5_shctl_01[0]) | (ex5_sh3[14] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[14] = (~((ex5_sh3[14] & ex5_shctl_01[0]) | (ex5_sh3[15] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[15] = (~((ex5_sh3[15] & ex5_shctl_01[0]) | (ex5_sh3[16] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[16] = (~((ex5_sh3[16] & ex5_shctl_01[0]) | (ex5_sh3[17] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[17] = (~((ex5_sh3[17] & ex5_shctl_01[0]) | (ex5_sh3[18] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[18] = (~((ex5_sh3[18] & ex5_shctl_01[0]) | (ex5_sh3[19] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[19] = (~((ex5_sh3[19] & ex5_shctl_01[0]) | (ex5_sh3[20] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[20] = (~((ex5_sh3[20] & ex5_shctl_01[0]) | (ex5_sh3[21] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[21] = (~((ex5_sh3[21] & ex5_shctl_01[0]) | (ex5_sh3[22] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[22] = (~((ex5_sh3[22] & ex5_shctl_01[0]) | (ex5_sh3[23] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[23] = (~((ex5_sh3[23] & ex5_shctl_01[0]) | (ex5_sh3[24] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[24] = (~((ex5_sh3[24] & ex5_shctl_01[0]) | (ex5_sh3[25] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[25] = (~((ex5_sh3[25] & ex5_shctl_01[0]) | (ex5_sh3[26] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[26] = (~((ex5_sh3[26] & ex5_shctl_01[0]) | (ex5_sh3[27] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[27] = (~((ex5_sh3[27] & ex5_shctl_01[0]) | (ex5_sh3[28] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[28] = (~((ex5_sh3[28] & ex5_shctl_01[0]) | (ex5_sh3[29] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[29] = (~((ex5_sh3[29] & ex5_shctl_01[0]) | (ex5_sh3[30] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[30] = (~((ex5_sh3[30] & ex5_shctl_01[0]) | (ex5_sh3[31] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[31] = (~((ex5_sh3[31] & ex5_shctl_01[0]) | (ex5_sh3[32] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[32] = (~((ex5_sh3[32] & ex5_shctl_01[0]) | (ex5_sh3[33] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[33] = (~((ex5_sh3[33] & ex5_shctl_01[0]) | (ex5_sh3[34] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[34] = (~((ex5_sh3[34] & ex5_shctl_01[0]) | (ex5_sh3[35] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[35] = (~((ex5_sh3[35] & ex5_shctl_01[0]) | (ex5_sh3[36] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[36] = (~((ex5_sh3[36] & ex5_shctl_01[0]) | (ex5_sh3[37] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[37] = (~((ex5_sh3[37] & ex5_shctl_01[0]) | (ex5_sh3[38] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[38] = (~((ex5_sh3[38] & ex5_shctl_01[0]) | (ex5_sh3[39] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[39] = (~((ex5_sh3[39] & ex5_shctl_01[0]) | (ex5_sh3[40] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[40] = (~((ex5_sh3[40] & ex5_shctl_01[0]) | (ex5_sh3[41] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[41] = (~((ex5_sh3[41] & ex5_shctl_01[0]) | (ex5_sh3[42] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[42] = (~((ex5_sh3[42] & ex5_shctl_01[0]) | (ex5_sh3[43] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[43] = (~((ex5_sh3[43] & ex5_shctl_01[0]) | (ex5_sh3[44] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[44] = (~((ex5_sh3[44] & ex5_shctl_01[0]) | (ex5_sh3[45] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[45] = (~((ex5_sh3[45] & ex5_shctl_01[0]) | (ex5_sh3[46] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[46] = (~((ex5_sh3[46] & ex5_shctl_01[0]) | (ex5_sh3[47] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[47] = (~((ex5_sh3[47] & ex5_shctl_01[0]) | (ex5_sh3[48] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[48] = (~((ex5_sh3[48] & ex5_shctl_01[0]) | (ex5_sh3[49] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[49] = (~((ex5_sh3[49] & ex5_shctl_01[0]) | (ex5_sh3[50] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[50] = (~((ex5_sh3[50] & ex5_shctl_01[0]) | (ex5_sh3[51] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[51] = (~((ex5_sh3[51] & ex5_shctl_01[0]) | (ex5_sh3[52] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[52] = (~((ex5_sh3[52] & ex5_shctl_01[0]) | (ex5_sh3[53] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[53] = (~((ex5_sh3[53] & ex5_shctl_01[0]) | (ex5_sh3[54] & ex5_shctl_01[1])));
   assign ex5_sh4_x_b[54] = (~((ex5_sh3[54] & ex5_shctl_01[0]) | (ex5_sh3[55] & ex5_shctl_01[1])));

   assign ex5_sh4_y_00_b = (~((ex5_sh3[2] & ex5_shctl_01[2]) | (ex5_sh3[3] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[0] = (~((ex5_sh3[2] & ex5_shctl_01[2]) | (ex5_sh3[3] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[1] = (~((ex5_sh3[3] & ex5_shctl_01[2]) | (ex5_sh3[4] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[2] = (~((ex5_sh3[4] & ex5_shctl_01[2]) | (ex5_sh3[5] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[3] = (~((ex5_sh3[5] & ex5_shctl_01[2]) | (ex5_sh3[6] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[4] = (~((ex5_sh3[6] & ex5_shctl_01[2]) | (ex5_sh3[7] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[5] = (~((ex5_sh3[7] & ex5_shctl_01[2]) | (ex5_sh3[8] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[6] = (~((ex5_sh3[8] & ex5_shctl_01[2]) | (ex5_sh3[9] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[7] = (~((ex5_sh3[9] & ex5_shctl_01[2]) | (ex5_sh3[10] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[8] = (~((ex5_sh3[10] & ex5_shctl_01[2]) | (ex5_sh3[11] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[9] = (~((ex5_sh3[11] & ex5_shctl_01[2]) | (ex5_sh3[12] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[10] = (~((ex5_sh3[12] & ex5_shctl_01[2]) | (ex5_sh3[13] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[11] = (~((ex5_sh3[13] & ex5_shctl_01[2]) | (ex5_sh3[14] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[12] = (~((ex5_sh3[14] & ex5_shctl_01[2]) | (ex5_sh3[15] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[13] = (~((ex5_sh3[15] & ex5_shctl_01[2]) | (ex5_sh3[16] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[14] = (~((ex5_sh3[16] & ex5_shctl_01[2]) | (ex5_sh3[17] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[15] = (~((ex5_sh3[17] & ex5_shctl_01[2]) | (ex5_sh3[18] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[16] = (~((ex5_sh3[18] & ex5_shctl_01[2]) | (ex5_sh3[19] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[17] = (~((ex5_sh3[19] & ex5_shctl_01[2]) | (ex5_sh3[20] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[18] = (~((ex5_sh3[20] & ex5_shctl_01[2]) | (ex5_sh3[21] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[19] = (~((ex5_sh3[21] & ex5_shctl_01[2]) | (ex5_sh3[22] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[20] = (~((ex5_sh3[22] & ex5_shctl_01[2]) | (ex5_sh3[23] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[21] = (~((ex5_sh3[23] & ex5_shctl_01[2]) | (ex5_sh3[24] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[22] = (~((ex5_sh3[24] & ex5_shctl_01[2]) | (ex5_sh3[25] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[23] = (~((ex5_sh3[25] & ex5_shctl_01[2]) | (ex5_sh3[26] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[24] = (~((ex5_sh3[26] & ex5_shctl_01[2]) | (ex5_sh3[27] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[25] = (~((ex5_sh3[27] & ex5_shctl_01[2]) | (ex5_sh3[28] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[26] = (~((ex5_sh3[28] & ex5_shctl_01[2]) | (ex5_sh3[29] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[27] = (~((ex5_sh3[29] & ex5_shctl_01[2]) | (ex5_sh3[30] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[28] = (~((ex5_sh3[30] & ex5_shctl_01[2]) | (ex5_sh3[31] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[29] = (~((ex5_sh3[31] & ex5_shctl_01[2]) | (ex5_sh3[32] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[30] = (~((ex5_sh3[32] & ex5_shctl_01[2]) | (ex5_sh3[33] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[31] = (~((ex5_sh3[33] & ex5_shctl_01[2]) | (ex5_sh3[34] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[32] = (~((ex5_sh3[34] & ex5_shctl_01[2]) | (ex5_sh3[35] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[33] = (~((ex5_sh3[35] & ex5_shctl_01[2]) | (ex5_sh3[36] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[34] = (~((ex5_sh3[36] & ex5_shctl_01[2]) | (ex5_sh3[37] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[35] = (~((ex5_sh3[37] & ex5_shctl_01[2]) | (ex5_sh3[38] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[36] = (~((ex5_sh3[38] & ex5_shctl_01[2]) | (ex5_sh3[39] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[37] = (~((ex5_sh3[39] & ex5_shctl_01[2]) | (ex5_sh3[40] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[38] = (~((ex5_sh3[40] & ex5_shctl_01[2]) | (ex5_sh3[41] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[39] = (~((ex5_sh3[41] & ex5_shctl_01[2]) | (ex5_sh3[42] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[40] = (~((ex5_sh3[42] & ex5_shctl_01[2]) | (ex5_sh3[43] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[41] = (~((ex5_sh3[43] & ex5_shctl_01[2]) | (ex5_sh3[44] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[42] = (~((ex5_sh3[44] & ex5_shctl_01[2]) | (ex5_sh3[45] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[43] = (~((ex5_sh3[45] & ex5_shctl_01[2]) | (ex5_sh3[46] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[44] = (~((ex5_sh3[46] & ex5_shctl_01[2]) | (ex5_sh3[47] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[45] = (~((ex5_sh3[47] & ex5_shctl_01[2]) | (ex5_sh3[48] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[46] = (~((ex5_sh3[48] & ex5_shctl_01[2]) | (ex5_sh3[49] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[47] = (~((ex5_sh3[49] & ex5_shctl_01[2]) | (ex5_sh3[50] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[48] = (~((ex5_sh3[50] & ex5_shctl_01[2]) | (ex5_sh3[51] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[49] = (~((ex5_sh3[51] & ex5_shctl_01[2]) | (ex5_sh3[52] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[50] = (~((ex5_sh3[52] & ex5_shctl_01[2]) | (ex5_sh3[53] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[51] = (~((ex5_sh3[53] & ex5_shctl_01[2]) | (ex5_sh3[54] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[52] = (~((ex5_sh3[54] & ex5_shctl_01[2]) | (ex5_sh3[55] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[53] = (~((ex5_sh3[55] & ex5_shctl_01[2]) | (ex5_sh3[56] & ex5_shctl_01[3])));
   assign ex5_sh4_y_b[54] = (~((ex5_sh3[56] & ex5_shctl_01[2]) | (ex5_sh3[57] & ex5_shctl_01[3])));

   assign ex5_shift_extra_cp1_b = (~(ex5_sh4_x_00_b & ex5_sh4_y_00_b));		// shift extra when implicit bit is not 1
   assign ex5_shift_extra_cp2_b = (~(ex5_sh4_x_00_b & ex5_sh4_y_00_b));		// shift extra when implicit bit is not 1
   assign ex5_shift_extra_00_cp3_b = (~(ex5_sh4_x_b[0] & ex5_sh4_y_b[0]));		// shift extra when implicit bit is not 1
   assign ex5_shift_extra_00_cp4_b = (~(ex5_sh4_x_b[0] & ex5_sh4_y_b[0]));		// shift extra when implicit bit is not 1

   assign ex5_shift_extra_cp1 = (~ex5_shift_extra_cp1_b);		//output--
   assign ex5_shift_extra_cp2 = (~ex5_shift_extra_cp2_b);		//output--

   assign ex5_shift_extra_10_cp3 = (~ex5_shift_extra_00_cp3_b);		// x4
   assign ex5_shift_extra_20_cp3_b = (~ex5_shift_extra_10_cp3);		// x6
   assign ex5_shift_extra_cp3 = (~ex5_shift_extra_20_cp3_b);		// x9

   assign ex5_shift_extra_11_cp3 = (~ex5_shift_extra_00_cp3_b);		// x2
   assign ex5_shift_extra_21_cp3_b = (~ex5_shift_extra_11_cp3);		// x4
   assign ex5_shift_extra_31_cp3 = (~ex5_shift_extra_21_cp3_b);		// x6
   assign ex5_shift_extra_cp3_b = (~ex5_shift_extra_31_cp3);		// x9

   assign ex5_shift_extra_10_cp4 = (~ex5_shift_extra_00_cp4_b);		// x4
   assign ex5_shift_extra_20_cp4_b = (~ex5_shift_extra_10_cp4);		// x6
   assign ex5_shift_extra_cp4 = (~ex5_shift_extra_20_cp4_b);		// x9

   assign ex5_shift_extra_11_cp4 = (~ex5_shift_extra_00_cp4_b);		// x2
   assign ex5_shift_extra_21_cp4_b = (~ex5_shift_extra_11_cp4);		// x4
   assign ex5_shift_extra_31_cp4 = (~ex5_shift_extra_21_cp4_b);		// x6
   assign ex5_shift_extra_cp4_b = (~ex5_shift_extra_31_cp4);		// x9

   assign ex5_sh4[0] = (~(ex5_sh4_x_b[0] & ex5_sh4_y_b[0]));
   assign ex5_sh4[1] = (~(ex5_sh4_x_b[1] & ex5_sh4_y_b[1]));
   assign ex5_sh4[2] = (~(ex5_sh4_x_b[2] & ex5_sh4_y_b[2]));
   assign ex5_sh4[3] = (~(ex5_sh4_x_b[3] & ex5_sh4_y_b[3]));
   assign ex5_sh4[4] = (~(ex5_sh4_x_b[4] & ex5_sh4_y_b[4]));
   assign ex5_sh4[5] = (~(ex5_sh4_x_b[5] & ex5_sh4_y_b[5]));
   assign ex5_sh4[6] = (~(ex5_sh4_x_b[6] & ex5_sh4_y_b[6]));
   assign ex5_sh4[7] = (~(ex5_sh4_x_b[7] & ex5_sh4_y_b[7]));
   assign ex5_sh4[8] = (~(ex5_sh4_x_b[8] & ex5_sh4_y_b[8]));
   assign ex5_sh4[9] = (~(ex5_sh4_x_b[9] & ex5_sh4_y_b[9]));
   assign ex5_sh4[10] = (~(ex5_sh4_x_b[10] & ex5_sh4_y_b[10]));
   assign ex5_sh4[11] = (~(ex5_sh4_x_b[11] & ex5_sh4_y_b[11]));
   assign ex5_sh4[12] = (~(ex5_sh4_x_b[12] & ex5_sh4_y_b[12]));
   assign ex5_sh4[13] = (~(ex5_sh4_x_b[13] & ex5_sh4_y_b[13]));
   assign ex5_sh4[14] = (~(ex5_sh4_x_b[14] & ex5_sh4_y_b[14]));
   assign ex5_sh4[15] = (~(ex5_sh4_x_b[15] & ex5_sh4_y_b[15]));
   assign ex5_sh4[16] = (~(ex5_sh4_x_b[16] & ex5_sh4_y_b[16]));
   assign ex5_sh4[17] = (~(ex5_sh4_x_b[17] & ex5_sh4_y_b[17]));
   assign ex5_sh4[18] = (~(ex5_sh4_x_b[18] & ex5_sh4_y_b[18]));
   assign ex5_sh4[19] = (~(ex5_sh4_x_b[19] & ex5_sh4_y_b[19]));
   assign ex5_sh4[20] = (~(ex5_sh4_x_b[20] & ex5_sh4_y_b[20]));
   assign ex5_sh4[21] = (~(ex5_sh4_x_b[21] & ex5_sh4_y_b[21]));
   assign ex5_sh4[22] = (~(ex5_sh4_x_b[22] & ex5_sh4_y_b[22]));
   assign ex5_sh4[23] = (~(ex5_sh4_x_b[23] & ex5_sh4_y_b[23]));
   assign ex5_sh4[24] = (~(ex5_sh4_x_b[24] & ex5_sh4_y_b[24]));
   assign ex5_sh4[25] = (~(ex5_sh4_x_b[25] & ex5_sh4_y_b[25]));
   assign ex5_sh4[26] = (~(ex5_sh4_x_b[26] & ex5_sh4_y_b[26]));
   assign ex5_sh4[27] = (~(ex5_sh4_x_b[27] & ex5_sh4_y_b[27]));
   assign ex5_sh4[28] = (~(ex5_sh4_x_b[28] & ex5_sh4_y_b[28]));
   assign ex5_sh4[29] = (~(ex5_sh4_x_b[29] & ex5_sh4_y_b[29]));
   assign ex5_sh4[30] = (~(ex5_sh4_x_b[30] & ex5_sh4_y_b[30]));
   assign ex5_sh4[31] = (~(ex5_sh4_x_b[31] & ex5_sh4_y_b[31]));
   assign ex5_sh4[32] = (~(ex5_sh4_x_b[32] & ex5_sh4_y_b[32]));
   assign ex5_sh4[33] = (~(ex5_sh4_x_b[33] & ex5_sh4_y_b[33]));
   assign ex5_sh4[34] = (~(ex5_sh4_x_b[34] & ex5_sh4_y_b[34]));
   assign ex5_sh4[35] = (~(ex5_sh4_x_b[35] & ex5_sh4_y_b[35]));
   assign ex5_sh4[36] = (~(ex5_sh4_x_b[36] & ex5_sh4_y_b[36]));
   assign ex5_sh4[37] = (~(ex5_sh4_x_b[37] & ex5_sh4_y_b[37]));
   assign ex5_sh4[38] = (~(ex5_sh4_x_b[38] & ex5_sh4_y_b[38]));
   assign ex5_sh4[39] = (~(ex5_sh4_x_b[39] & ex5_sh4_y_b[39]));
   assign ex5_sh4[40] = (~(ex5_sh4_x_b[40] & ex5_sh4_y_b[40]));
   assign ex5_sh4[41] = (~(ex5_sh4_x_b[41] & ex5_sh4_y_b[41]));
   assign ex5_sh4[42] = (~(ex5_sh4_x_b[42] & ex5_sh4_y_b[42]));
   assign ex5_sh4[43] = (~(ex5_sh4_x_b[43] & ex5_sh4_y_b[43]));
   assign ex5_sh4[44] = (~(ex5_sh4_x_b[44] & ex5_sh4_y_b[44]));
   assign ex5_sh4[45] = (~(ex5_sh4_x_b[45] & ex5_sh4_y_b[45]));
   assign ex5_sh4[46] = (~(ex5_sh4_x_b[46] & ex5_sh4_y_b[46]));
   assign ex5_sh4[47] = (~(ex5_sh4_x_b[47] & ex5_sh4_y_b[47]));
   assign ex5_sh4[48] = (~(ex5_sh4_x_b[48] & ex5_sh4_y_b[48]));
   assign ex5_sh4[49] = (~(ex5_sh4_x_b[49] & ex5_sh4_y_b[49]));
   assign ex5_sh4[50] = (~(ex5_sh4_x_b[50] & ex5_sh4_y_b[50]));
   assign ex5_sh4[51] = (~(ex5_sh4_x_b[51] & ex5_sh4_y_b[51]));
   assign ex5_sh4[52] = (~(ex5_sh4_x_b[52] & ex5_sh4_y_b[52]));
   assign ex5_sh4[53] = (~(ex5_sh4_x_b[53] & ex5_sh4_y_b[53]));
   assign ex5_sh4[54] = (~(ex5_sh4_x_b[54] & ex5_sh4_y_b[54]));

   //---------------------------------------------

   assign ex5_sh5_x_b[0] = (~(ex5_sh4[0] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[1] = (~(ex5_sh4[1] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[2] = (~(ex5_sh4[2] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[3] = (~(ex5_sh4[3] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[4] = (~(ex5_sh4[4] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[5] = (~(ex5_sh4[5] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[6] = (~(ex5_sh4[6] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[7] = (~(ex5_sh4[7] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[8] = (~(ex5_sh4[8] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[9] = (~(ex5_sh4[9] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[10] = (~(ex5_sh4[10] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[11] = (~(ex5_sh4[11] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[12] = (~(ex5_sh4[12] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[13] = (~(ex5_sh4[13] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[14] = (~(ex5_sh4[14] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[15] = (~(ex5_sh4[15] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[16] = (~(ex5_sh4[16] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[17] = (~(ex5_sh4[17] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[18] = (~(ex5_sh4[18] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[19] = (~(ex5_sh4[19] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[20] = (~(ex5_sh4[20] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[21] = (~(ex5_sh4[21] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[22] = (~(ex5_sh4[22] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[23] = (~(ex5_sh4[23] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[24] = (~(ex5_sh4[24] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[25] = (~(ex5_sh4[25] & ex5_shift_extra_cp3_b));
   assign ex5_sh5_x_b[26] = (~(ex5_sh4[26] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[27] = (~(ex5_sh4[27] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[28] = (~(ex5_sh4[28] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[29] = (~(ex5_sh4[29] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[30] = (~(ex5_sh4[30] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[31] = (~(ex5_sh4[31] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[32] = (~(ex5_sh4[32] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[33] = (~(ex5_sh4[33] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[34] = (~(ex5_sh4[34] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[35] = (~(ex5_sh4[35] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[36] = (~(ex5_sh4[36] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[37] = (~(ex5_sh4[37] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[38] = (~(ex5_sh4[38] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[39] = (~(ex5_sh4[39] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[40] = (~(ex5_sh4[40] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[41] = (~(ex5_sh4[41] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[42] = (~(ex5_sh4[42] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[43] = (~(ex5_sh4[43] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[44] = (~(ex5_sh4[44] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[45] = (~(ex5_sh4[45] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[46] = (~(ex5_sh4[46] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[47] = (~(ex5_sh4[47] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[48] = (~(ex5_sh4[48] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[49] = (~(ex5_sh4[49] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[50] = (~(ex5_sh4[50] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[51] = (~(ex5_sh4[51] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[52] = (~(ex5_sh4[52] & ex5_shift_extra_cp4_b));
   assign ex5_sh5_x_b[53] = (~(ex5_sh4[53] & ex5_shift_extra_cp4_b));

   assign ex5_sh5_y_b[0] = (~(ex5_sh4[1] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[1] = (~(ex5_sh4[2] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[2] = (~(ex5_sh4[3] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[3] = (~(ex5_sh4[4] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[4] = (~(ex5_sh4[5] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[5] = (~(ex5_sh4[6] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[6] = (~(ex5_sh4[7] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[7] = (~(ex5_sh4[8] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[8] = (~(ex5_sh4[9] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[9] = (~(ex5_sh4[10] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[10] = (~(ex5_sh4[11] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[11] = (~(ex5_sh4[12] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[12] = (~(ex5_sh4[13] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[13] = (~(ex5_sh4[14] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[14] = (~(ex5_sh4[15] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[15] = (~(ex5_sh4[16] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[16] = (~(ex5_sh4[17] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[17] = (~(ex5_sh4[18] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[18] = (~(ex5_sh4[19] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[19] = (~(ex5_sh4[20] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[20] = (~(ex5_sh4[21] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[21] = (~(ex5_sh4[22] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[22] = (~(ex5_sh4[23] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[23] = (~(ex5_sh4[24] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[24] = (~(ex5_sh4[25] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[25] = (~(ex5_sh4[26] & ex5_shift_extra_cp3));
   assign ex5_sh5_y_b[26] = (~(ex5_sh4[27] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[27] = (~(ex5_sh4[28] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[28] = (~(ex5_sh4[29] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[29] = (~(ex5_sh4[30] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[30] = (~(ex5_sh4[31] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[31] = (~(ex5_sh4[32] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[32] = (~(ex5_sh4[33] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[33] = (~(ex5_sh4[34] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[34] = (~(ex5_sh4[35] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[35] = (~(ex5_sh4[36] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[36] = (~(ex5_sh4[37] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[37] = (~(ex5_sh4[38] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[38] = (~(ex5_sh4[39] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[39] = (~(ex5_sh4[40] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[40] = (~(ex5_sh4[41] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[41] = (~(ex5_sh4[42] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[42] = (~(ex5_sh4[43] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[43] = (~(ex5_sh4[44] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[44] = (~(ex5_sh4[45] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[45] = (~(ex5_sh4[46] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[46] = (~(ex5_sh4[47] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[47] = (~(ex5_sh4[48] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[48] = (~(ex5_sh4[49] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[49] = (~(ex5_sh4[50] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[50] = (~(ex5_sh4[51] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[51] = (~(ex5_sh4[52] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[52] = (~(ex5_sh4[53] & ex5_shift_extra_cp4));
   assign ex5_sh5_y_b[53] = (~(ex5_sh4[54] & ex5_shift_extra_cp4));

endmodule
