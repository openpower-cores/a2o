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


module fu_eie(
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
   f_eie_si,
   f_eie_so,
   ex2_act,
   f_byp_eie_ex2_a_expo,
   f_byp_eie_ex2_c_expo,
   f_byp_eie_ex2_b_expo,
   f_pic_ex2_from_integer,
   f_pic_ex2_fsel,
   f_pic_ex3_frsp_ue1,
   f_alg_ex3_sel_byp,
   f_fmt_ex3_fsel_bsel,
   f_pic_ex3_force_sel_bexp,
   f_pic_ex3_sp_b,
   f_pic_ex3_math_bzer_b,
   f_eie_ex3_tbl_expo,
   f_eie_ex3_lt_bias,
   f_eie_ex3_eq_bias_m1,
   f_eie_ex3_wd_ov,
   f_eie_ex3_dw_ov,
   f_eie_ex3_wd_ov_if,
   f_eie_ex3_dw_ov_if,
   f_eie_ex3_lzo_expo,
   f_eie_ex3_b_expo,
   f_eie_ex3_use_bexp,
   f_eie_ex4_iexp
);

   inout         vdd;
   inout         gnd;
   input         clkoff_b;		// tiup
   input         act_dis;		// ??tidn??
   input         flush;		// ??tidn??
   input [2:3]   delay_lclkr;		// tidn,
   input [2:3]   mpw1_b;		// tidn,
   input [0:0]   mpw2_b;		// tidn,
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]         nclk;

   input         f_eie_si;		// perv
   output        f_eie_so;		// perv
   input         ex2_act;		// act

   input [1:13]  f_byp_eie_ex2_a_expo;
   input [1:13]  f_byp_eie_ex2_c_expo;
   input [1:13]  f_byp_eie_ex2_b_expo;

   input         f_pic_ex2_from_integer;
   input         f_pic_ex2_fsel;
   input         f_pic_ex3_frsp_ue1;

   input         f_alg_ex3_sel_byp;
   input         f_fmt_ex3_fsel_bsel;
   input         f_pic_ex3_force_sel_bexp;
   input         f_pic_ex3_sp_b;
   input         f_pic_ex3_math_bzer_b;

   output [1:13] f_eie_ex3_tbl_expo;

   output        f_eie_ex3_lt_bias;		//f_pic
   output        f_eie_ex3_eq_bias_m1;		//f_pic
   output        f_eie_ex3_wd_ov;		//f_pic
   output        f_eie_ex3_dw_ov;		//f_pic
   output        f_eie_ex3_wd_ov_if;		//f_pic
   output        f_eie_ex3_dw_ov_if;		//f_pic
   output [1:13] f_eie_ex3_lzo_expo;		//dlza to lzo
   output [1:13] f_eie_ex3_b_expo;		//dlza to lzo
   output        f_eie_ex3_use_bexp;
   output [1:13] f_eie_ex4_iexp;		//deov to lzasub

   // end ports

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire          sg_0;
   wire          thold_0_b;
   wire          thold_0;
   wire          force_t;


   wire          ex3_act;
   wire [0:3]    act_spare_unused;
   //-----------------
   wire [0:4]    act_so;		//SCAN
   wire [0:4]    act_si;		//SCAN
   wire [0:12]   ex3_bop_so;		//SCAN
   wire [0:12]   ex3_bop_si;		//SCAN
   wire [0:12]   ex3_pop_so;		//SCAN
   wire [0:12]   ex3_pop_si;		//SCAN
   wire [0:6]    ex3_ctl_so;		//SCAN
   wire [0:6]    ex3_ctl_si;		//SCAN
   wire [0:13]   ex4_iexp_so;		//SCAN
   wire [0:13]   ex4_iexp_si;		//SCAN
   //-----------------
   wire [1:13]   ex2_a_expo;
   wire [1:13]   ex2_c_expo;
   wire [1:13]   ex2_b_expo;
   wire [1:13]   ex2_ep56_sum;
   wire [1:12]   ex2_ep56_car;
   wire [1:13]   ex2_ep56_p;
   wire [2:12]   ex2_ep56_g;
   wire [2:11]   ex2_ep56_t;
   wire [1:13]   ex2_ep56_s;
   wire [2:12]   ex2_ep56_c;
   wire [1:13]   ex2_p_expo_adj;
   wire [1:13]   ex2_from_k;
   wire [1:13]   ex2_b_expo_adj;
   wire [1:13]   ex3_p_expo;
   wire [1:13]   ex3_b_expo;
   wire [1:13]   ex3_iexp;
   wire [1:13]   ex3_b_expo_adj;
   wire [1:13]   ex3_p_expo_adj;
   wire [1:13]   ex4_iexp;
   wire          ex2_wd_ge_bot;
   wire          ex2_dw_ge_bot;
   wire          ex2_ge_2048;
   wire          ex2_ge_1024;
   wire          ex2_dw_ge_mid;
   wire          ex2_wd_ge_mid;
   wire          ex2_dw_ge;
   wire          ex2_wd_ge;
   wire          ex2_dw_eq_top;
   wire          ex2_wd_eq_bot;
   wire          ex2_wd_eq;
   wire          ex2_dw_eq;
   wire          ex3_iexp_b_sel;
   wire          ex3_dw_ge;
   wire          ex3_wd_ge;
   wire          ex3_wd_eq;
   wire          ex3_dw_eq;
   wire          ex3_fsel;
   wire          ex4_sp_b;
   wire [1:13]   ex3_b_expo_fixed;		//experiment sp_den/dp_fmt
   wire          ex2_ge_bias;
   wire          ex2_lt_bias;
   wire          ex2_eq_bias_m1;
   wire          ex3_lt_bias;
   wire          ex3_eq_bias_m1;
   wire [2:12]   ex2_ep56_g2;
   wire [2:10]   ex2_ep56_t2;
   wire [2:12]   ex2_ep56_g4;
   wire [2:8]    ex2_ep56_t4;
   wire [2:12]   ex2_ep56_g8;
   wire [2:4]    ex2_ep56_t8;

   ////############################################
   ////# pervasive
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

   ////############################################
   ////# ACT LATCHES
   ////############################################

   tri_rlmreg_p #(.WIDTH(5),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		//tidn,
      .mpw1_b(mpw1_b[2]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({ act_spare_unused[0],
             act_spare_unused[1],
             ex2_act,
             act_spare_unused[2],
             act_spare_unused[3]}),
      //-----------------
      .dout({  act_spare_unused[0],
               act_spare_unused[1],
               ex3_act,
               act_spare_unused[2],
               act_spare_unused[3]})
   );

   ////##############################################
   ////# EX2 latch inputs from rf1
   ////##############################################

   assign ex2_a_expo[1:13] = f_byp_eie_ex2_a_expo[1:13];
   assign ex2_c_expo[1:13] = f_byp_eie_ex2_c_expo[1:13];
   assign ex2_b_expo[1:13] = f_byp_eie_ex2_b_expo[1:13];

   ////##############################################
   ////# EX2 logic
   ////##############################################

   ////##-------------------------------------------------------------------------
   ////## Product Exponent adder (+56 scouta subtract gives final resutl)
   ////##-------------------------------------------------------------------------
   // rebiased from 1023 to 4095 ... (append 2 ones)
   // ep56 : Ec + Ea -bias
   // ep0  : Ec + Ea -bias + 56 = Ec + Ea -4095 + 56
   //
   //  0_0011_1111_1111
   //  1_1100_0000_0001  !1023 + 1 = -1023
   //           11_1000  56
   //------------------
   //  1_1100_0011_1001 + Ea + Ec
   //

   //    ex2_ep56_sum( 0) <= tiup;                                     -- 1
   assign ex2_ep56_sum[1] = (~(ex2_a_expo[1] ^ ex2_c_expo[1]));		// 1
   assign ex2_ep56_sum[2] = (~(ex2_a_expo[2] ^ ex2_c_expo[2]));		// 1
   assign ex2_ep56_sum[3] = (~(ex2_a_expo[3] ^ ex2_c_expo[3]));		// 1
   assign ex2_ep56_sum[4] = (ex2_a_expo[4] ^ ex2_c_expo[4]);		// 0
   assign ex2_ep56_sum[5] = (ex2_a_expo[5] ^ ex2_c_expo[5]);		// 0
   assign ex2_ep56_sum[6] = (ex2_a_expo[6] ^ ex2_c_expo[6]);		// 0
   assign ex2_ep56_sum[7] = (ex2_a_expo[7] ^ ex2_c_expo[7]);		// 0
   assign ex2_ep56_sum[8] = (~(ex2_a_expo[8] ^ ex2_c_expo[8]));		// 1
   assign ex2_ep56_sum[9] = (~(ex2_a_expo[9] ^ ex2_c_expo[9]));		// 1
   assign ex2_ep56_sum[10] = (~(ex2_a_expo[10] ^ ex2_c_expo[10]));		// 1
   assign ex2_ep56_sum[11] = (ex2_a_expo[11] ^ ex2_c_expo[11]);		// 0
   assign ex2_ep56_sum[12] = (ex2_a_expo[12] ^ ex2_c_expo[12]);		// 0
   assign ex2_ep56_sum[13] = (~(ex2_a_expo[13] ^ ex2_c_expo[13]));		// 1

   //    ex2_ep56_car( 0) <=    ( ex2_a_expo( 1) or  ex2_c_expo( 1) ); -- 1
   assign ex2_ep56_car[1] = (ex2_a_expo[2] | ex2_c_expo[2]);		// 1
   assign ex2_ep56_car[2] = (ex2_a_expo[3] | ex2_c_expo[3]);		// 1
   assign ex2_ep56_car[3] = (ex2_a_expo[4] & ex2_c_expo[4]);		// 0
   assign ex2_ep56_car[4] = (ex2_a_expo[5] & ex2_c_expo[5]);		// 0
   assign ex2_ep56_car[5] = (ex2_a_expo[6] & ex2_c_expo[6]);		// 0
   assign ex2_ep56_car[6] = (ex2_a_expo[7] & ex2_c_expo[7]);		// 0
   assign ex2_ep56_car[7] = (ex2_a_expo[8] | ex2_c_expo[8]);		// 1
   assign ex2_ep56_car[8] = (ex2_a_expo[9] | ex2_c_expo[9]);		// 1
   assign ex2_ep56_car[9] = (ex2_a_expo[10] | ex2_c_expo[10]);		// 1
   assign ex2_ep56_car[10] = (ex2_a_expo[11] & ex2_c_expo[11]);		// 0
   assign ex2_ep56_car[11] = (ex2_a_expo[12] & ex2_c_expo[12]);		// 0
   assign ex2_ep56_car[12] = (ex2_a_expo[13] | ex2_c_expo[13]);		// 1

   assign ex2_ep56_p[1:12] = ex2_ep56_sum[1:12] ^ ex2_ep56_car[1:12];
   assign ex2_ep56_p[13] = ex2_ep56_sum[13];
   assign ex2_ep56_g[2:12] = ex2_ep56_sum[2:12] & ex2_ep56_car[2:12];
   assign ex2_ep56_t[2:11] = ex2_ep56_sum[2:11] | ex2_ep56_car[2:11];

   assign ex2_ep56_s[1:11] = ex2_ep56_p[1:11] ^ ex2_ep56_c[2:12];
   assign ex2_ep56_s[12] = ex2_ep56_p[12];
   assign ex2_ep56_s[13] = ex2_ep56_p[13];

   assign ex2_ep56_g2[12] = ex2_ep56_g[12];
   assign ex2_ep56_g2[11] = ex2_ep56_g[11] | (ex2_ep56_t[11] & ex2_ep56_g[12]);
   assign ex2_ep56_g2[10] = ex2_ep56_g[10] | (ex2_ep56_t[10] & ex2_ep56_g[11]);
   assign ex2_ep56_g2[9] = ex2_ep56_g[9] | (ex2_ep56_t[9] & ex2_ep56_g[10]);
   assign ex2_ep56_g2[8] = ex2_ep56_g[8] | (ex2_ep56_t[8] & ex2_ep56_g[9]);
   assign ex2_ep56_g2[7] = ex2_ep56_g[7] | (ex2_ep56_t[7] & ex2_ep56_g[8]);
   assign ex2_ep56_g2[6] = ex2_ep56_g[6] | (ex2_ep56_t[6] & ex2_ep56_g[7]);
   assign ex2_ep56_g2[5] = ex2_ep56_g[5] | (ex2_ep56_t[5] & ex2_ep56_g[6]);
   assign ex2_ep56_g2[4] = ex2_ep56_g[4] | (ex2_ep56_t[4] & ex2_ep56_g[5]);
   assign ex2_ep56_g2[3] = ex2_ep56_g[3] | (ex2_ep56_t[3] & ex2_ep56_g[4]);
   assign ex2_ep56_g2[2] = ex2_ep56_g[2] | (ex2_ep56_t[2] & ex2_ep56_g[3]);
   //  ex2_ep56_g2( 1) <= ex2_ep56_g( 1) or (ex2_ep56_t( 1) and ex2_ep56_g( 2)) ;

   assign ex2_ep56_t2[10] = (ex2_ep56_t[10] & ex2_ep56_t[11]);
   assign ex2_ep56_t2[9] = (ex2_ep56_t[9] & ex2_ep56_t[10]);
   assign ex2_ep56_t2[8] = (ex2_ep56_t[8] & ex2_ep56_t[9]);
   assign ex2_ep56_t2[7] = (ex2_ep56_t[7] & ex2_ep56_t[8]);
   assign ex2_ep56_t2[6] = (ex2_ep56_t[6] & ex2_ep56_t[7]);
   assign ex2_ep56_t2[5] = (ex2_ep56_t[5] & ex2_ep56_t[6]);
   assign ex2_ep56_t2[4] = (ex2_ep56_t[4] & ex2_ep56_t[5]);
   assign ex2_ep56_t2[3] = (ex2_ep56_t[3] & ex2_ep56_t[4]);
   assign ex2_ep56_t2[2] = (ex2_ep56_t[2] & ex2_ep56_t[3]);
   //  ex2_ep56_t2( 1) <=                   (ex2_ep56_t( 1) and ex2_ep56_t( 2)) ;

   assign ex2_ep56_g4[12] = ex2_ep56_g2[12];
   assign ex2_ep56_g4[11] = ex2_ep56_g2[11];
   assign ex2_ep56_g4[10] = ex2_ep56_g2[10] | (ex2_ep56_t2[10] & ex2_ep56_g2[12]);
   assign ex2_ep56_g4[9] = ex2_ep56_g2[9] | (ex2_ep56_t2[9] & ex2_ep56_g2[11]);
   assign ex2_ep56_g4[8] = ex2_ep56_g2[8] | (ex2_ep56_t2[8] & ex2_ep56_g2[10]);
   assign ex2_ep56_g4[7] = ex2_ep56_g2[7] | (ex2_ep56_t2[7] & ex2_ep56_g2[9]);
   assign ex2_ep56_g4[6] = ex2_ep56_g2[6] | (ex2_ep56_t2[6] & ex2_ep56_g2[8]);
   assign ex2_ep56_g4[5] = ex2_ep56_g2[5] | (ex2_ep56_t2[5] & ex2_ep56_g2[7]);
   assign ex2_ep56_g4[4] = ex2_ep56_g2[4] | (ex2_ep56_t2[4] & ex2_ep56_g2[6]);
   assign ex2_ep56_g4[3] = ex2_ep56_g2[3] | (ex2_ep56_t2[3] & ex2_ep56_g2[5]);
   assign ex2_ep56_g4[2] = ex2_ep56_g2[2] | (ex2_ep56_t2[2] & ex2_ep56_g2[4]);
   //  ex2_ep56_g4( 1) <= ex2_ep56_g2( 1) or (ex2_ep56_t2( 1) and ex2_ep56_g2( 3)) ;

   assign ex2_ep56_t4[8] = (ex2_ep56_t2[8] & ex2_ep56_t2[10]);
   assign ex2_ep56_t4[7] = (ex2_ep56_t2[7] & ex2_ep56_t2[9]);
   assign ex2_ep56_t4[6] = (ex2_ep56_t2[6] & ex2_ep56_t2[8]);
   assign ex2_ep56_t4[5] = (ex2_ep56_t2[5] & ex2_ep56_t2[7]);
   assign ex2_ep56_t4[4] = (ex2_ep56_t2[4] & ex2_ep56_t2[6]);
   assign ex2_ep56_t4[3] = (ex2_ep56_t2[3] & ex2_ep56_t2[5]);
   assign ex2_ep56_t4[2] = (ex2_ep56_t2[2] & ex2_ep56_t2[4]);
   //  ex2_ep56_t4( 1) <=                    (ex2_ep56_t2( 1) and ex2_ep56_t2( 3)) ;

   assign ex2_ep56_g8[12] = ex2_ep56_g4[12];
   assign ex2_ep56_g8[11] = ex2_ep56_g4[11];
   assign ex2_ep56_g8[10] = ex2_ep56_g4[10];
   assign ex2_ep56_g8[9] = ex2_ep56_g4[9];
   assign ex2_ep56_g8[8] = ex2_ep56_g4[8] | (ex2_ep56_t4[8] & ex2_ep56_g4[12]);
   assign ex2_ep56_g8[7] = ex2_ep56_g4[7] | (ex2_ep56_t4[7] & ex2_ep56_g4[11]);
   assign ex2_ep56_g8[6] = ex2_ep56_g4[6] | (ex2_ep56_t4[6] & ex2_ep56_g4[10]);
   assign ex2_ep56_g8[5] = ex2_ep56_g4[5] | (ex2_ep56_t4[5] & ex2_ep56_g4[9]);
   assign ex2_ep56_g8[4] = ex2_ep56_g4[4] | (ex2_ep56_t4[4] & ex2_ep56_g4[8]);
   assign ex2_ep56_g8[3] = ex2_ep56_g4[3] | (ex2_ep56_t4[3] & ex2_ep56_g4[7]);
   assign ex2_ep56_g8[2] = ex2_ep56_g4[2] | (ex2_ep56_t4[2] & ex2_ep56_g4[6]);
   //  ex2_ep56_g8( 1) <= ex2_ep56_g4( 1) or (ex2_ep56_t4( 1) and ex2_ep56_g4( 5)) ;

   assign ex2_ep56_t8[4] = (ex2_ep56_t4[4] & ex2_ep56_t4[8]);
   assign ex2_ep56_t8[3] = (ex2_ep56_t4[3] & ex2_ep56_t4[7]);
   assign ex2_ep56_t8[2] = (ex2_ep56_t4[2] & ex2_ep56_t4[6]);
   //  ex2_ep56_t8( 1) <=                    (ex2_ep56_t4( 1) and ex2_ep56_t4( 5)) ;

   assign ex2_ep56_c[12] = ex2_ep56_g8[12];
   assign ex2_ep56_c[11] = ex2_ep56_g8[11];
   assign ex2_ep56_c[10] = ex2_ep56_g8[10];
   assign ex2_ep56_c[9] = ex2_ep56_g8[9];
   assign ex2_ep56_c[8] = ex2_ep56_g8[8];
   assign ex2_ep56_c[7] = ex2_ep56_g8[7];
   assign ex2_ep56_c[6] = ex2_ep56_g8[6];
   assign ex2_ep56_c[5] = ex2_ep56_g8[5];
   assign ex2_ep56_c[4] = ex2_ep56_g8[4] | (ex2_ep56_t8[4] & ex2_ep56_g8[12]);
   assign ex2_ep56_c[3] = ex2_ep56_g8[3] | (ex2_ep56_t8[3] & ex2_ep56_g8[11]);
   assign ex2_ep56_c[2] = ex2_ep56_g8[2] | (ex2_ep56_t8[2] & ex2_ep56_g8[10]);
   //  ex2_ep56_c( 1) <= ex2_ep56_g8( 1) or (ex2_ep56_t8( 1) and ex2_ep56_g8( 9)) ;

   ////##---------------------------------------
   ////## hold onto c_exponent for fsel
   ////##---------------------------------------

   assign ex2_p_expo_adj[1:13] = (ex2_ep56_s[1:13] & {13{(~f_pic_ex2_fsel)}}) |
                                 (ex2_c_expo[1:13] & {13{f_pic_ex2_fsel}});

   ////##---------------------------------------
   ////## select b exponent
   ////##---------------------------------------

   // From integer exponent
   // lsb is at position 162, and value = bias
   // therefore set b_expo to (bias+162)
   // 0_1111_1111_1111   1023 = bias
   //         101_0010    162
   // ----------------   ----
   // 1_0000_0101_0001   4096+57
   // 1 2345 6789 0123

   assign ex2_from_k[1] = tidn;		// 4096
   assign ex2_from_k[2] = tidn;		// 2048
   assign ex2_from_k[3] = tiup;		// 1024
   assign ex2_from_k[4] = tidn;		//  512
   assign ex2_from_k[5] = tidn;		//  256
   assign ex2_from_k[6] = tiup;		//  128
   assign ex2_from_k[7] = tidn;		//   64
   assign ex2_from_k[8] = tiup;		//   32
   assign ex2_from_k[9] = tidn;		//   16
   assign ex2_from_k[10] = tidn;		//    8
   assign ex2_from_k[11] = tidn;		//    4
   assign ex2_from_k[12] = tidn;		//    2
   assign ex2_from_k[13] = tiup;		//    1

   assign ex2_b_expo_adj[1:13] = (ex2_from_k[1:13] & {13{f_pic_ex2_from_integer}}) |
                                 (ex2_b_expo[1:13] & {13{(~f_pic_ex2_from_integer)}});

   ////##---------------------------------------
   ////## to integer overflow boundaries
   ////##---------------------------------------
   // convert to signed_word:
   //      pos int ov ge 2**31             1023+31
   //              ov eq 2**30 * rnd_up    1023+30 <= just look at final MSB position
   //      neg int ov gt 2**31             1023+31
   //      neg int ov eq 2**31             1023+31 & frac[1:*] != 0

   // convert to signed_doubleword:
   //      pos int ov ge 2**63             1023+63  1086
   //              ov eq 2**62 * rnd_up    1023+62  1085 <=== just look at final msb position
   //      neg int ov gt 2**63             1023+63  1086
   //      neg int ov eq 2**63             1023+63  1086 & frac[1:*] != 0;
   //
   //   0_0011_1111_1111   bias 1023
   //            10_0000   32
   //   0_0100 0001 1111   <=== ge
   //
   //   0_0011_1111_1111   bias 1023
   //             1_1111   31
   //   0_0100 0001 1110   <=== eq
   //
   //   0_0011_1111_1111   bias 1023
   //           100_0000   64
   //   0_0100 0011 1111  <==== ge  1087
   //
   //   0_0011_1111_1111   bias 1023
   //            11_1111   63
   //   0_0100 0011 1110  <==== eq  1086
   //
   //               1111
   //   1 2345 6789 0123
   //
   // if exponent less than bias (1023)
   // positive input  if +rnd_up  result = +ulp (ok)  int  1
   // positive input  if -rnd_up  result =   +0 (ok)  int  0
   // negative input  if +rnd_up  result = -ulp (ok)  int -1 (no increment)
   // negative input  if -rnd_up  result =   +0      <== ??force sign??
   //     normalizer shifts wrong (98)=1

   assign ex2_wd_ge_bot = ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & ex2_b_expo[13];

   assign ex2_dw_ge_bot = ex2_b_expo[8] & ex2_wd_ge_bot;

   assign ex2_ge_2048 = (~ex2_b_expo[1]) & ex2_b_expo[2];
   assign ex2_ge_1024 = (~ex2_b_expo[1]) & ex2_b_expo[3];

   assign ex2_dw_ge_mid = ex2_b_expo[4] | ex2_b_expo[5] | ex2_b_expo[6] | ex2_b_expo[7];

   assign ex2_wd_ge_mid = ex2_b_expo[8] | ex2_dw_ge_mid;

   assign ex2_dw_ge = (ex2_ge_2048) | (ex2_ge_1024 & ex2_dw_ge_mid) | (ex2_ge_1024 & ex2_dw_ge_bot);

   assign ex2_wd_ge = (ex2_ge_2048) | (ex2_ge_1024 & ex2_wd_ge_mid) | (ex2_ge_1024 & ex2_wd_ge_bot);

   assign ex2_dw_eq_top = (~ex2_b_expo[1]) & (~ex2_b_expo[2]) & ex2_b_expo[3] & (~ex2_b_expo[4]) & (~ex2_b_expo[5]) & (~ex2_b_expo[6]) & (~ex2_b_expo[7]);

   assign ex2_wd_eq_bot = ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & (~ex2_b_expo[13]);

   assign ex2_wd_eq = ex2_dw_eq_top & (~ex2_b_expo[8]) & ex2_wd_eq_bot;

   assign ex2_dw_eq = ex2_dw_eq_top & ex2_b_expo[8] & ex2_wd_eq_bot;

   assign ex2_ge_bias = ((~ex2_b_expo[1]) & ex2_b_expo[2]) | ((~ex2_b_expo[1]) & ex2_b_expo[3]) | ((~ex2_b_expo[1]) & ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6] & ex2_b_expo[7] & ex2_b_expo[8] & ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & ex2_b_expo[13]);		// for rnd_to_int

   assign ex2_lt_bias = (~ex2_ge_bias);
   // rnd-to-int nearest rounds up
   // sign
   // 2048
   // 1024
   // 512
   // 256
   // 128
   // 64
   // 32
   // 16
   // 8
   // 4
   assign ex2_eq_bias_m1 = (~ex2_b_expo[1]) & (~ex2_b_expo[2]) & (~ex2_b_expo[3]) & ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6] & ex2_b_expo[7] & ex2_b_expo[8] & ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & (~ex2_b_expo[13]);		// 2
   // 1

   ////##############################################
   ////# EX3 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(13),  .NEEDS_SRESET(0)) ex3_bop_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup), //
      .delay_lclkr(delay_lclkr[2]),		//tidn,
      .mpw1_b(mpw1_b[2]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex2_act),
      .scout(ex3_bop_so),
      .scin(ex3_bop_si),
      //-----------------
      .din(ex2_b_expo_adj[1:13]),
      .dout(ex3_b_expo_adj[1:13])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(13),  .NEEDS_SRESET(0)) ex3_pop_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		//tidn,
      .mpw1_b(mpw1_b[2]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex2_act),
      .scout(ex3_pop_so),
      .scin(ex3_pop_si),
      //-----------------
      .din(ex2_p_expo_adj[1:13]),
      .dout(ex3_p_expo_adj[1:13])		//LAT--
   );


   tri_rlmreg_p #(.WIDTH(7),  .NEEDS_SRESET(0)) ex3_ctl_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),		//tidn,
      .mpw1_b(mpw1_b[2]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex2_act),
      .scout(ex3_ctl_so),
      .scin(ex3_ctl_si),
      //-----------------
      .din({ ex2_dw_ge,
             ex2_wd_ge,
             ex2_wd_eq,
             ex2_dw_eq,
             f_pic_ex2_fsel,
             ex2_lt_bias,
             ex2_eq_bias_m1}),
      //-----------------
      .dout({ex3_dw_ge,		//LAT--
             ex3_wd_ge,		//LAT--
             ex3_wd_eq,		//LAT--
             ex3_dw_eq,		//LAT--
             ex3_fsel,		//LAT--
             ex3_lt_bias,		//LAT--
             ex3_eq_bias_m1})		//LAT--
   );

   assign f_eie_ex3_lt_bias = ex3_lt_bias;		//output --f_pic
   assign f_eie_ex3_eq_bias_m1 = ex3_eq_bias_m1;		//output --f_pic

   assign ex3_p_expo[1:13] = ex3_p_expo_adj[1:13];
   assign ex3_b_expo[1:13] = ex3_b_expo_adj[1:13];

   assign f_eie_ex3_wd_ov = ex3_wd_ge;		//output --f_pic
   assign f_eie_ex3_dw_ov = ex3_dw_ge;		//output --f_pic
   assign f_eie_ex3_wd_ov_if = ex3_wd_eq;		//output --f_pic
   assign f_eie_ex3_dw_ov_if = ex3_dw_eq;		//output --f_pic

   assign f_eie_ex3_lzo_expo[1:13] = ex3_p_expo_adj[1:13];		//output --dlza for lzo
   assign f_eie_ex3_b_expo[1:13] = ex3_b_expo[1:13];
   assign f_eie_ex3_tbl_expo[1:13] = ex3_b_expo[1:13];
   ////##############################################
   ////# EX3 logic
   ////##############################################

   //   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //    --experiment sp_den/dp_fmt
   //    -- experimental -- (add 24 for bypass B cases) shift 24 positions to avoid shift right
   //    -- SP_den in DP format is normalized, but SP op must give denorm result.
   //    -- do not want to shift right in normalizer, scoutdent in aligner.
   //    -- ?? problem: LZO positions for bypass case :
   //    --      UE=0: set LZO 24 instead of LZO 0 .... ??? can [0:23] be an alias ???
   //    --      UE=1: always normalize, LZO does not matter
   //    --
   //    -- (changed from 24 to 26) for the offset
   //
   //
   //    ex3_bexp26(13) <=     ex3_b_expo(13); -- 0001
   //    ex3_bexp26(12) <= not ex3_b_expo(12); -- 0002
   //    ex3_bexp26(11) <=     ex3_b_expo(11) xor ex3_bexp26_c(12); -- 0004
   //    ex3_bexp26(10) <= not ex3_b_expo(10) xor ex3_bexp26_c(11) ; -- 0008
   //    ex3_bexp26(9)  <= not ex3_b_expo(9)  xor ex3_bexp26_c(10); -- 0016
   //    ex3_bexp26(1 to 8) <= ex3_b_expo(1 to 8) xor ex3_bexp26_c(2 to 9) ; -- 0032 ...
   //
   //    ex3_bexpo26_9_o_10 <= ex3_b_expo(9)  or ex3_b_expo(10) ;
   //
   //    ex3_bexp26_c(12)     <= ex3_b_expo(12);
   //    ex3_bexp26_c(11)     <= ex3_b_expo(11)     and ex3_b_expo(12);
   //    ex3_bexp26_c(10)     <= ex3_b_expo(10)     or (ex3_b_expo(11) and ex3_b_expo(12) );
   //    ex3_bexp26_c(9)      <= ex3_bexpo26_9_o_10 or (ex3_b_expo(11) and ex3_b_expo(12) );
   //    ex3_bexp26_c(8)      <= ex3_bexp26_gg(8) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(7)      <= ex3_bexp26_gg(7) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(6)      <= ex3_bexp26_gg(6) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(5)      <= ex3_bexp26_gg(5) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(4)      <= ex3_bexp26_gg(4) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(3)      <= ex3_bexp26_gg(3) and  ex3_bexp26_c(9);
   //    ex3_bexp26_c(2)      <= ex3_bexp26_gg(2) and  ex3_bexp26_c(9);
   //
   //    ex3_bexp26_gg2(8)   <= ex3_b_expo(8) ;
   //    ex3_bexp26_gg2(7)   <= ex3_b_expo(7) and ex3_b_expo(8) ;
   //    ex3_bexp26_gg2(6)   <= ex3_b_expo(6) and ex3_b_expo(7) ;
   //    ex3_bexp26_gg2(5)   <= ex3_b_expo(5) and ex3_b_expo(6) ;
   //    ex3_bexp26_gg2(4)   <= ex3_b_expo(4) and ex3_b_expo(5) ;
   //    ex3_bexp26_gg2(3)   <= ex3_b_expo(3) and ex3_b_expo(4) ;
   //    ex3_bexp26_gg2(2)   <= ex3_b_expo(2) and ex3_b_expo(3) ;
   //
   //    ex3_bexp26_gg4(8)   <= ex3_bexp26_gg2(8) ;
   //    ex3_bexp26_gg4(7)   <= ex3_bexp26_gg2(7) ;
   //    ex3_bexp26_gg4(6)   <= ex3_bexp26_gg2(6) and ex3_bexp26_gg2(8) ;
   //    ex3_bexp26_gg4(5)   <= ex3_bexp26_gg2(5) and ex3_bexp26_gg2(7) ;
   //    ex3_bexp26_gg4(4)   <= ex3_bexp26_gg2(4) and ex3_bexp26_gg2(6) ;
   //    ex3_bexp26_gg4(3)   <= ex3_bexp26_gg2(3) and ex3_bexp26_gg2(5) ;
   //    ex3_bexp26_gg4(2)   <= ex3_bexp26_gg2(2) and ex3_bexp26_gg2(4) ;
   //
   //    ex3_bexp26_gg(8)    <= ex3_bexp26_gg4(8) ;
   //    ex3_bexp26_gg(7)    <= ex3_bexp26_gg4(7) ;
   //    ex3_bexp26_gg(6)    <= ex3_bexp26_gg4(6) ;
   //    ex3_bexp26_gg(5)    <= ex3_bexp26_gg4(5) ;
   //    ex3_bexp26_gg(4)    <= ex3_bexp26_gg4(4) and ex3_bexp26_gg4(8) ;
   //    ex3_bexp26_gg(3)    <= ex3_bexp26_gg4(3) and ex3_bexp26_gg4(7) ;
   //    ex3_bexp26_gg(2)    <= ex3_bexp26_gg4(2) and ex3_bexp26_gg4(6) ;
   //
   //
   //
   //    ex3_b_expo_fixed(1 to 13) <=                                              --experiment sp_den/dp_fmt
   //         ( ex3_b_expo(1 to 13) and (1 to 13 =>     f_pic_ex3_sp_b) ) or -- DP --experiment sp_den/dp_fmt
   //         ( ex3_bexp26(1 to 13) and (1 to 13 => not f_pic_ex3_sp_b) ) ;  -- SP --experiment sp_den/dp_fmt
   //   --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   assign ex3_b_expo_fixed[1:13] = ex3_b_expo[1:13];

   assign f_eie_ex3_use_bexp = ex3_iexp_b_sel;

   //NAN/shOv
   // fsel
   assign ex3_iexp_b_sel = (f_alg_ex3_sel_byp & (~ex3_fsel) & f_pic_ex3_math_bzer_b) | f_fmt_ex3_fsel_bsel | f_pic_ex3_force_sel_bexp | f_pic_ex3_frsp_ue1;		// by opcode
   // frsp with ue=1 always does bypass because must normalize anyway
   // if frsp(ue=1) has a shift unf, then loose bits and canot normalize)

   assign ex3_iexp[1:13] = (ex3_b_expo_fixed[1:13] & {13{ex3_iexp_b_sel}}) |
                           (ex3_p_expo[1:13] & {13{(~ex3_iexp_b_sel)}});		//experiment sp_den/dp_fmt

   ////##############################################
   ////# EX4 latches
   ////##############################################


   tri_rlmreg_p #(.WIDTH(14),  .NEEDS_SRESET(0)) ex4_iexp_lat(
      .force_t(force_t),		//tidn,
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),		//tidn,
      .mpw1_b(mpw1_b[3]),		//tidn,
      .mpw2_b(mpw2_b[0]),		//tidn,
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex3_act),
      .scout(ex4_iexp_so),
      .scin(ex4_iexp_si),
      //-----------------
      .din({f_pic_ex3_sp_b,
            ex3_iexp[1:13]}),
      //-----------------
      .dout({ex4_sp_b,		//LAT--
             ex4_iexp[1:13]})		//LAT--
   );

   assign f_eie_ex4_iexp[1:13] = ex4_iexp[1:13];		//output--feov

   ////##############################################
   ////# EX4 logic
   ////##############################################

   ////############################################
   ////# scan
   ////############################################

   assign ex3_bop_si[0:12] = {ex3_bop_so[1:12], f_eie_si};
   assign ex3_pop_si[0:12] = {ex3_pop_so[1:12], ex3_bop_so[0]};
   assign ex3_ctl_si[0:6] = {ex3_ctl_so[1:6], ex3_pop_so[0]};
   assign ex4_iexp_si[0:13] = {ex4_iexp_so[1:13], ex3_ctl_so[0]};
   assign act_si[0:4] = {act_so[1:4], ex4_iexp_so[0]};
   assign f_eie_so = act_so[0];

endmodule
