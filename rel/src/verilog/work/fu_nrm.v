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


module fu_nrm(
   vdd,
   gnd,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   sg_1,
   thold_1,
   fpu_enable,
   nclk,
   f_nrm_si,
   f_nrm_so,
   ex4_act_b,
   f_lza_ex5_lza_amt_cp1,
   f_lza_ex5_lza_dcd64_cp1,
   f_lza_ex5_lza_dcd64_cp2,
   f_lza_ex5_lza_dcd64_cp3,
   f_lza_ex5_sh_rgt_en,
   f_add_ex5_res,
   f_add_ex5_sticky,
   f_pic_ex5_byp_prod_nz,
   f_nrm_ex6_res,
   f_nrm_ex6_int_sign,
   f_nrm_ex6_int_lsbs,
   f_nrm_ex6_nrm_sticky_dp,
   f_nrm_ex6_nrm_guard_dp,
   f_nrm_ex6_nrm_lsb_dp,
   f_nrm_ex6_nrm_sticky_sp,
   f_nrm_ex6_nrm_guard_sp,
   f_nrm_ex6_nrm_lsb_sp,
   f_nrm_ex6_exact_zero,
   f_nrm_ex5_extra_shift,
   f_nrm_ex6_fpscr_wr_dat_dfp,
   f_nrm_ex6_fpscr_wr_dat
);

   inout         vdd;
   inout         gnd;
   input         clkoff_b;		// tiup
   input         act_dis;		// ??tidn??
   input         flush;		// ??tidn??
   input [4:5]   delay_lclkr;		// tidn,
   input [4:5]   mpw1_b;		// tidn,
   input [0:1]   mpw2_b;		// tidn,
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input         f_nrm_si;		// perv
   output        f_nrm_so;		// perv
   input         ex4_act_b;		// act

   input [0:7]   f_lza_ex5_lza_amt_cp1;		// shift amount

   input [0:2]   f_lza_ex5_lza_dcd64_cp1;		//fnrm
   input [0:1]   f_lza_ex5_lza_dcd64_cp2;		//fnrm
   input [0:0]   f_lza_ex5_lza_dcd64_cp3;		//fnrm
   input         f_lza_ex5_sh_rgt_en;

   input [0:162] f_add_ex5_res;		// data to shift
   input         f_add_ex5_sticky;		// or into sticky
   input         f_pic_ex5_byp_prod_nz;
   output [0:52] f_nrm_ex6_res;		//rnd,
   output        f_nrm_ex6_int_sign;		//rnd,   (151:162)
   output [1:12] f_nrm_ex6_int_lsbs;		//rnd,   (151:162)
   output        f_nrm_ex6_nrm_sticky_dp;		//rnd,
   output        f_nrm_ex6_nrm_guard_dp;		//rnd,
   output        f_nrm_ex6_nrm_lsb_dp;		//rnd,
   output        f_nrm_ex6_nrm_sticky_sp;		//rnd,
   output        f_nrm_ex6_nrm_guard_sp;		//rnd,
   output        f_nrm_ex6_nrm_lsb_sp;		//rnd,
   output        f_nrm_ex6_exact_zero;		//rnd,
   output        f_nrm_ex5_extra_shift;		//expo_ov,
   output [0:3]  f_nrm_ex6_fpscr_wr_dat_dfp;		//fpscr, (17:20)
   output [0:31] f_nrm_ex6_fpscr_wr_dat;		//fpscr, (21:52)

   // end ports

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire          sg_0;
   wire          thold_0_b;
   wire          thold_0;
   wire          force_t;
   wire          ex4_act;
   wire          ex5_act;
   wire [0:2]    act_spare_unused;
   //-----------------
   wire [0:3]    act_so;		//SCAN
   wire [0:3]    act_si;		//SCAN
   wire [0:52]   ex6_res_so;		//SCAN
   wire [0:52]   ex6_res_si;		//SCAN
   wire [0:3]    ex6_nrm_lg_so;		//SCAN
   wire [0:3]    ex6_nrm_lg_si;		//SCAN
   wire [0:2]    ex6_nrm_x_so;		//SCAN
   wire [0:2]    ex6_nrm_x_si;		//SCAN
   wire [0:12]   ex6_nrm_pass_so;		//SCAN
   wire [0:12]   ex6_nrm_pass_si;		//SCAN
   wire [0:35]   ex6_fmv_so;		//SCAN
   wire [0:35]   ex6_fmv_si;		//SCAN
   //-----------------
   wire [26:72]  ex5_sh2;
   wire          ex5_sh4_25;		//shifting
   wire          ex5_sh4_54;		//shifting
   wire [0:53]   ex5_nrm_res;		//shifting
   wire [0:53]   ex5_sh5_x_b;
   wire [0:53]   ex5_sh5_y_b;
   wire          ex5_lt064_x;		//sticky
   wire          ex5_lt128_x;		//sticky
   wire          ex5_lt016_x;		//sticky
   wire          ex5_lt032_x;		//sticky
   wire          ex5_lt048_x;		//sticky
   wire          ex5_lt016;		//sticky
   wire          ex5_lt032;		//sticky
   wire          ex5_lt048;		//sticky
   wire          ex5_lt064;		//sticky
   wire          ex5_lt080;		//sticky
   wire          ex5_lt096;		//sticky
   wire          ex5_lt112;		//sticky
   wire          ex5_lt128;		//sticky
   wire          ex5_lt04_x;		//sticky
   wire          ex5_lt08_x;		//sticky
   wire          ex5_lt12_x;		//sticky
   wire          ex5_lt01_x;		//sticky
   wire          ex5_lt02_x;		//sticky
   wire          ex5_lt03_x;		//sticky
   wire          ex5_sticky_sp;		//sticky
   wire          ex5_sticky_dp;		//sticky
   wire          ex5_sticky16_dp;		//sticky
   wire          ex5_sticky16_sp;		//sticky
   wire [0:10]   ex5_or_grp16;		//sticky
   wire [0:14]   ex5_lt;		//sticky
   wire          ex5_exact_zero;		//sticky
   wire          ex5_exact_zero_b;		//sticky
   //------------------
   wire [0:52]   ex6_res;		// LATCH OUTPUTS
   wire          ex6_nrm_sticky_dp;
   wire          ex6_nrm_guard_dp;
   wire          ex6_nrm_lsb_dp;
   wire          ex6_nrm_sticky_sp;
   wire          ex6_nrm_guard_sp;
   wire          ex6_nrm_lsb_sp;
   wire          ex6_exact_zero;
   wire          ex6_int_sign;
   wire [1:12]   ex6_int_lsbs;
   wire [0:31]   ex6_fpscr_wr_dat;
   wire [0:3]    ex6_fpscr_wr_dat_dfp;
   wire          ex5_rgt_4more;
   wire          ex5_rgt_3more;
   wire          ex5_rgt_2more;
   wire          ex5_shift_extra_cp2;
   wire          unused;

   wire          ex5_sticky_dp_x2_b;
   wire          ex5_sticky_dp_x1_b;
   wire          ex5_sticky_dp_x1;
   wire          ex5_sticky_sp_x2_b;
   wire          ex5_sticky_sp_x1_b;
   wire          ex5_sticky_sp_x1;
   wire          ex6_d1clk;
   wire          ex6_d2clk;
   wire  [0:`NCLK_WIDTH-1]          ex6_lclk;
   wire          ex5_sticky_stuff;

   // sticky bit sp/dp does not look at all the bits
   assign unused = |(ex5_sh2[41:54]) | |(ex5_nrm_res[0:53]) | ex5_sticky_sp | ex5_sticky_dp | ex5_exact_zero;

   ////############################################
   //# pervasive
   ////############################################


   tri_plat  thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),
      .q(thold_0)
   );


   tri_plat  sg_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(sg_1),
      .q(sg_0)
   );


   tri_lcbor  lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );

   tri_lcbnd  ex6_lcb(
      .delay_lclkr(delay_lclkr[5]),		// tidn
      .mpw1_b(mpw1_b[5]),		// tidn
      .mpw2_b(mpw2_b[1]),		// tidn
      .force_t(force_t),		// tidn
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex5_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(ex6_d1clk),		//out
      .d2clk(ex6_d2clk),		//out
      .lclk(ex6_lclk)		//out
   );

   ////############################################
   //# ACT LATCHES
   ////############################################

   assign ex4_act = (~ex4_act_b);


   tri_rlmreg_p #(.WIDTH(4),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),		//i-- tidn,
      .mpw1_b(mpw1_b[4]),		//i-- tidn,
      .mpw2_b(mpw2_b[0]),		//i-- tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),
      .scout(act_so[0:3]),
      .scin(act_si[0:3]),
      //-----------------
      .din({  act_spare_unused[0],
              act_spare_unused[1],
              ex4_act,
              act_spare_unused[2]}),
      //-----------------
      .dout({  act_spare_unused[0],
               act_spare_unused[1],
               ex5_act,
               act_spare_unused[2]})
   );

   ////##############################################
   //# EX5 logic: shifting
   ////##############################################


   fu_nrm_sh  sh(
      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		//i--
      .f_lza_ex5_lza_amt_cp1(f_lza_ex5_lza_amt_cp1[2:7]),		//i--
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		//i--
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		//i--
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0:0]),		//i--
      .f_add_ex5_res(f_add_ex5_res[0:162]),		//i--
      .ex5_shift_extra_cp1(f_nrm_ex5_extra_shift),		//o-- <30ish> loads  feov
      .ex5_shift_extra_cp2(ex5_shift_extra_cp2),		//o-- <2> loads  sticky sp/dp
      .ex5_sh4_25(ex5_sh4_25),		//o--
      .ex5_sh4_54(ex5_sh4_54),		//o--
      .ex5_sh2_o(ex5_sh2[26:72]),		//o--
      .ex5_sh5_x_b(ex5_sh5_x_b[0:53]),		//o--
      .ex5_sh5_y_b(ex5_sh5_y_b[0:53])		//o--
   );

   assign ex5_nrm_res[0:53] = (~(ex5_sh5_x_b[0:53] & ex5_sh5_y_b[0:53]));
   ////##############################################
   //# EX5 logic: stciky bit
   ////##############################################

   //# thermometer decode 1 ---------------
   //#
   //# the smaller the shift the more sticky bits.
   //# the multiple of 16 shifter is 0:68 ... bits after 68 are known sticky DP.
   //#                                        53-24=29 extra sp bits  68-29 = 39
   //#                                        bits after 39 are known sticky SP.

   assign ex5_lt064_x = (~(f_lza_ex5_lza_amt_cp1[0] | f_lza_ex5_lza_amt_cp1[1]));		// 00
   assign ex5_lt128_x = (~(f_lza_ex5_lza_amt_cp1[0]));		// 00 01

   assign ex5_lt016_x = (~(f_lza_ex5_lza_amt_cp1[2] | f_lza_ex5_lza_amt_cp1[3]));		// 00
   assign ex5_lt032_x = (~(f_lza_ex5_lza_amt_cp1[2]));		// 00 01
   assign ex5_lt048_x = (~(f_lza_ex5_lza_amt_cp1[2] & f_lza_ex5_lza_amt_cp1[3]));		// 00 01 10

   assign ex5_lt016 = ex5_lt064_x & ex5_lt016_x;		//tail=067  sticky_dp=069:162 sticky_sp=039:162
   assign ex5_lt032 = ex5_lt064_x & ex5_lt032_x;		//tail=083  sticky_dp=085:162 sticky_sp=055:162
   assign ex5_lt048 = ex5_lt064_x & ex5_lt048_x;		//tail=099  sticky_dp=101:162 sticky_sp=071:162
   assign ex5_lt064 = ex5_lt064_x;		//tail=115  sticky_dp=117:162 sticky_sp=087:162
   assign ex5_lt080 = ex5_lt064_x | (ex5_lt128_x & ex5_lt016_x);		//tail=131  sticky_dp=133:162 sticky_sp=103:162
   assign ex5_lt096 = ex5_lt064_x | (ex5_lt128_x & ex5_lt032_x);		//tail=147  sticky_dp=149:162 sticky_sp=119:162
   assign ex5_lt112 = ex5_lt064_x | (ex5_lt128_x & ex5_lt048_x);		//tail=163  sticky_dp=xxxxxxx sticky_sp=135:162
   assign ex5_lt128 = ex5_lt128_x;		//tail=179  sticky_dp=xxxxxxx sticky_sp=151:162

   //  1111xxxx shift right  1 -> 16 (shift right sticky groups of 16 may be off by one from shift left sticky groups)
   //  1110xxxx shift right 17 -> 32
   //  1101xxxx shift right 33 -> 48
   //  1100xxxx shift right 49 -> 64
   //  x0xxxxxx shift > 64
   //  0xxxxxxx shift > 64

   // for shift right Amt[0]==Amt[1]==shRgtEn
   // xx00_dddd   Right64, then Left00   4 more sticky16 group than 0000_dddd
   // xx01_dddd   Right64, then Left16   3 more sticky16 group than 0000_dddd
   // xx10_dddd   Right64, then Left32   2 more sticky16 group than 0000_dddd
   // xx11_dddd   Right64, then Left48   1 more sticky16 group than 0000_dddd

   assign ex5_rgt_2more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]) | (~f_lza_ex5_lza_amt_cp1[3]));		// 234
   assign ex5_rgt_3more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]));		// 23
   assign ex5_rgt_4more = f_lza_ex5_sh_rgt_en & ((~f_lza_ex5_lza_amt_cp1[2]) & (~f_lza_ex5_lza_amt_cp1[3]));		// 2

   //#------------------------
   //# sticky group 16 ors
   //#------------------------


   fu_nrm_or16  or16(
      .f_add_ex5_res(f_add_ex5_res[0:162]),		//i--
      .ex5_or_grp16(ex5_or_grp16[0:10])		//o--
   );

   //#------------------------
   //# enable the 16 bit ors
   //#------------------------

   assign ex5_sticky_stuff = (f_pic_ex5_byp_prod_nz) | (f_add_ex5_sticky);

   // 71: 86
   // 87:102
   //103:118
   //119:134
   //135:150
   //151:162
   // so group16s match for sp/dp
   assign ex5_sticky16_dp = (ex5_or_grp16[1] & ex5_rgt_4more) | (ex5_or_grp16[2] & ex5_rgt_3more) | (ex5_or_grp16[3] & ex5_rgt_2more) | (ex5_or_grp16[4] & f_lza_ex5_sh_rgt_en) | (ex5_or_grp16[5] & (ex5_lt016 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[6] & (ex5_lt032 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[7] & (ex5_lt048 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[8] & (ex5_lt064 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[9] & (ex5_lt080 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[10] & (ex5_lt096 | f_lza_ex5_sh_rgt_en)) | (ex5_sh2[70]) | (ex5_sh2[71]) | (ex5_sh2[72]) | (ex5_sticky_stuff);		// so group16s match for sp/dp

   // 39: 54
   // 55: 70
   // 71: 86
   // 87:102
   //103:118
   //119:134
   //135:150
   assign ex5_sticky16_sp = (ex5_or_grp16[0] & ex5_rgt_3more) | (ex5_or_grp16[1] & ex5_rgt_2more) | (ex5_or_grp16[2] & f_lza_ex5_sh_rgt_en) | (ex5_or_grp16[3] & (ex5_lt016 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[4] & (ex5_lt032 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[5] & (ex5_lt048 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[6] & (ex5_lt064 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[7] & (ex5_lt080 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[8] & (ex5_lt096 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[9] & (ex5_lt112 | f_lza_ex5_sh_rgt_en)) | (ex5_or_grp16[10] & (ex5_lt128 | f_lza_ex5_sh_rgt_en)) | (ex5_sticky_stuff);		//151:162

   assign ex5_exact_zero_b = ex5_or_grp16[0] | ex5_or_grp16[1] | ex5_or_grp16[2] | ex5_or_grp16[3] | ex5_or_grp16[4] | ex5_or_grp16[5] | ex5_or_grp16[6] | ex5_or_grp16[7] | ex5_or_grp16[8] | ex5_or_grp16[9] | ex5_or_grp16[10] | (ex5_sticky_stuff);

   assign ex5_exact_zero = (~ex5_exact_zero_b);

   //#------------------------
   //# thermometer decode 2
   //#------------------------

   assign ex5_lt04_x = (~(f_lza_ex5_lza_amt_cp1[4] | f_lza_ex5_lza_amt_cp1[5]));		// 00
   assign ex5_lt08_x = (~(f_lza_ex5_lza_amt_cp1[4]));		// 00 01
   assign ex5_lt12_x = (~(f_lza_ex5_lza_amt_cp1[4] & f_lza_ex5_lza_amt_cp1[5]));		// 00 01 10

   assign ex5_lt01_x = (~(f_lza_ex5_lza_amt_cp1[6] | f_lza_ex5_lza_amt_cp1[7]));		// 00
   assign ex5_lt02_x = (~(f_lza_ex5_lza_amt_cp1[6]));		// 00 01
   assign ex5_lt03_x = (~(f_lza_ex5_lza_amt_cp1[6] & f_lza_ex5_lza_amt_cp1[7]));		// 00 01 10

   assign ex5_lt[0] = ex5_lt04_x & ex5_lt01_x;		// 1
   assign ex5_lt[1] = ex5_lt04_x & ex5_lt02_x;		// 2
   assign ex5_lt[2] = ex5_lt04_x & ex5_lt03_x;		// 3
   assign ex5_lt[3] = ex5_lt04_x;		// 4

   assign ex5_lt[4] = ex5_lt04_x | (ex5_lt08_x & ex5_lt01_x);		// 5
   assign ex5_lt[5] = ex5_lt04_x | (ex5_lt08_x & ex5_lt02_x);		// 6
   assign ex5_lt[6] = ex5_lt04_x | (ex5_lt08_x & ex5_lt03_x);		// 7
   assign ex5_lt[7] = (ex5_lt08_x);		// 8

   assign ex5_lt[8] = ex5_lt08_x | (ex5_lt12_x & ex5_lt01_x);		// 9
   assign ex5_lt[9] = ex5_lt08_x | (ex5_lt12_x & ex5_lt02_x);		//10
   assign ex5_lt[10] = ex5_lt08_x | (ex5_lt12_x & ex5_lt03_x);		//11
   assign ex5_lt[11] = (ex5_lt12_x);		//12

   assign ex5_lt[12] = ex5_lt12_x | ex5_lt01_x;		//13
   assign ex5_lt[13] = ex5_lt12_x | ex5_lt02_x;		//14
   assign ex5_lt[14] = ex5_lt12_x | ex5_lt03_x;		//15

   //#------------------------
   //# final sticky bits
   //#------------------------

   // lt 01
   // lt 02
   // lt 03
   // lt 04
   // lt 05
   // lt 06
   // lt 07
   // lt 08
   // lt 09
   // lt 10
   // lt 11
   // lt 12
   // lt 13
   // lt 14
   assign ex5_sticky_sp_x1 = (ex5_lt[14] & ex5_sh2[40]) | (ex5_lt[13] & ex5_sh2[39]) | (ex5_lt[12] & ex5_sh2[38]) | (ex5_lt[11] & ex5_sh2[37]) | (ex5_lt[10] & ex5_sh2[36]) | (ex5_lt[9] & ex5_sh2[35]) | (ex5_lt[8] & ex5_sh2[34]) | (ex5_lt[7] & ex5_sh2[33]) | (ex5_lt[6] & ex5_sh2[32]) | (ex5_lt[5] & ex5_sh2[31]) | (ex5_lt[4] & ex5_sh2[30]) | (ex5_lt[3] & ex5_sh2[29]) | (ex5_lt[2] & ex5_sh2[28]) | (ex5_lt[1] & ex5_sh2[27]) | (ex5_lt[0] & ex5_sh2[26]) | (ex5_sticky16_sp);		// lt 15

   assign ex5_sticky_sp_x2_b = (~((~ex5_shift_extra_cp2) & ex5_sh4_25));
   assign ex5_sticky_sp_x1_b = (~ex5_sticky_sp_x1);
   assign ex5_sticky_sp = (~(ex5_sticky_sp_x1_b & ex5_sticky_sp_x2_b));

   // lt 01
   // lt 02
   // lt 03
   // lt 04
   // lt 05
   // lt 06
   // lt 07
   // lt 08
   // lt 09
   // lt 10
   // lt 11
   // lt 12
   // lt 13
   // lt 14
   assign ex5_sticky_dp_x1 = (ex5_lt[14] & ex5_sh2[69]) | (ex5_lt[13] & ex5_sh2[68]) | (ex5_lt[12] & ex5_sh2[67]) | (ex5_lt[11] & ex5_sh2[66]) | (ex5_lt[10] & ex5_sh2[65]) | (ex5_lt[9] & ex5_sh2[64]) | (ex5_lt[8] & ex5_sh2[63]) | (ex5_lt[7] & ex5_sh2[62]) | (ex5_lt[6] & ex5_sh2[61]) | (ex5_lt[5] & ex5_sh2[60]) | (ex5_lt[4] & ex5_sh2[59]) | (ex5_lt[3] & ex5_sh2[58]) | (ex5_lt[2] & ex5_sh2[57]) | (ex5_lt[1] & ex5_sh2[56]) | (ex5_lt[0] & ex5_sh2[55]) | (ex5_sticky16_dp);		// lt 15

   assign ex5_sticky_dp_x2_b = (~((~ex5_shift_extra_cp2) & ex5_sh4_54));
   assign ex5_sticky_dp_x1_b = (~ex5_sticky_dp_x1);
   assign ex5_sticky_dp = (~(ex5_sticky_dp_x1_b & ex5_sticky_dp_x2_b));

   ////##############################################
   //# EX6 latches
   ////##############################################


   		// , ibuf => true,
   tri_nand2_nlats #(.WIDTH(53),  .NEEDS_SRESET(0)) ex6_res_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(ex6_lclk),		//lclk.clk
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_res_si),
      .scanout(ex6_res_so),
      .a1(ex5_sh5_x_b[0:52]),
      .a2(ex5_sh5_y_b[0:52]),
      .qb(ex6_res[0:52])		//LAT--
   );

   		// , ibuf => true,
   tri_nand2_nlats #(.WIDTH(4),  .NEEDS_SRESET(0)) ex6_nrm_lg_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(ex6_lclk),		//lclk.clk
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_nrm_lg_si),
      .scanout(ex6_nrm_lg_so),
      //-----------------
      .a1({ex5_sh5_x_b[23],
           ex5_sh5_x_b[24],
           ex5_sh5_x_b[52],
           ex5_sh5_x_b[53]}),
      //-----------------
      .a2({ex5_sh5_y_b[23],
           ex5_sh5_y_b[24],
           ex5_sh5_y_b[52],
           ex5_sh5_y_b[53]}),
      //-----------------
      .qb({ex6_nrm_lsb_sp,		//LAT-- --sp lsb
           ex6_nrm_guard_sp,		//LAT-- --sp guard
           ex6_nrm_lsb_dp,		//LAT-- --dp lsb
           ex6_nrm_guard_dp})		//LAT-- --dp guard
   );

   		// , ibuf => true,
   tri_nand2_nlats #(.WIDTH(3),   .NEEDS_SRESET(0)) ex6_nrm_x_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(ex6_lclk),		//lclk.clk
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_nrm_x_si),
      .scanout(ex6_nrm_x_so),
      //-----------------
      .a1({ ex5_sticky_sp_x2_b,
            ex5_sticky_dp_x2_b,
            ex5_exact_zero_b}),
      //-----------------
      .a2({ ex5_sticky_sp_x1_b,
            ex5_sticky_dp_x1_b,
            tiup}),
      //-----------------
      .qb({ ex6_nrm_sticky_sp,		//LAT--
            ex6_nrm_sticky_dp,		//LAT--
            ex6_exact_zero})		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(13),  .IBUF(1'B1), .NEEDS_SRESET(0)) ex6_nrm_pass_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),		//i-- tidn,
      .mpw1_b(mpw1_b[5]),		//i-- tidn,
      .mpw2_b(mpw2_b[1]),		//i-- tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(ex6_nrm_pass_so),
      .scin(ex6_nrm_pass_si),
      //-----------------
      .din({f_add_ex5_res[99],
            f_add_ex5_res[151:162]}),		// (151:162)
      //-----------------
      .dout({ex6_int_sign,		//LAT--
             ex6_int_lsbs[1:12]})		//LAT--  --(151:162)
   );


   tri_rlmreg_p #(.WIDTH(36), .IBUF(1'B1), .NEEDS_SRESET(1)) ex6_fmv_lat(
      .force_t(force_t),		//i-- tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),		//i-- tidn,
      .mpw1_b(mpw1_b[5]),		//i-- tidn,
      .mpw2_b(mpw2_b[1]),		//i-- tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(ex6_fmv_so),
      .scin(ex6_fmv_si),
      //-----------------
      .din(f_add_ex5_res[17:52]),		//LAT
      //-----------------
      .dout({ex6_fpscr_wr_dat_dfp[0:3],
             ex6_fpscr_wr_dat[0:31]})		//LAT
   );

   assign f_nrm_ex6_res = ex6_res[0:52];		//output--rnd
   assign f_nrm_ex6_nrm_lsb_sp = ex6_nrm_lsb_sp;		//output--rnd
   assign f_nrm_ex6_nrm_guard_sp = ex6_nrm_guard_sp;		//output--rnd
   assign f_nrm_ex6_nrm_sticky_sp = ex6_nrm_sticky_sp;		//output--rnd
   assign f_nrm_ex6_nrm_lsb_dp = ex6_nrm_lsb_dp;		//output--rnd
   assign f_nrm_ex6_nrm_guard_dp = ex6_nrm_guard_dp;		//output--rnd
   assign f_nrm_ex6_nrm_sticky_dp = ex6_nrm_sticky_dp;		//output--rnd
   assign f_nrm_ex6_exact_zero = ex6_exact_zero;		//output--rnd
   assign f_nrm_ex6_int_lsbs = ex6_int_lsbs[1:12];		//output--rnd   (151:162)
   assign f_nrm_ex6_fpscr_wr_dat = ex6_fpscr_wr_dat[0:31];		//output--fpscr, (21:52)
   assign f_nrm_ex6_fpscr_wr_dat_dfp = ex6_fpscr_wr_dat_dfp[0:3];		//output--fpscr (17:20)
   assign f_nrm_ex6_int_sign = ex6_int_sign;		//output--rnd   (151:162)

   ////############################################
   //# scan
   ////############################################

   assign act_si[0:3] = {act_so[1:3], f_nrm_si};
   assign ex6_res_si[0:52] = {ex6_res_so[1:52], act_so[0]};
   assign ex6_nrm_lg_si[0:3] = {ex6_nrm_lg_so[1:3], ex6_res_so[0]};
   assign ex6_nrm_x_si[0:2] = {ex6_nrm_x_so[1:2], ex6_nrm_lg_so[0]};
   assign ex6_nrm_pass_si[0:12] = {ex6_nrm_pass_so[1:12], ex6_nrm_x_so[0]};
   assign ex6_fmv_si[0:35] = {ex6_fmv_so[1:35], ex6_nrm_pass_so[0]};
   assign f_nrm_so = ex6_fmv_so[0];

endmodule
