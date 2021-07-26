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

module fu_tbllut(
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
   si,
   so,
   ex2_act,
   f_fmt_ex2_b_frac,
   f_fmt_ex3_b_frac,
   f_tbe_ex3_expo_lsb,
   f_tbe_ex3_est_recip,
   f_tbe_ex3_est_rsqrt,
   f_tbe_ex4_recip_ue1,
   f_tbe_ex4_lu_sh,
   f_tbe_ex4_match_en_sp,
   f_tbe_ex4_match_en_dp,
   f_tbe_ex4_recip_2046,
   f_tbe_ex4_recip_2045,
   f_tbe_ex4_recip_2044,
   f_tbl_ex6_est_frac,
   f_tbl_ex5_unf_expo,
   f_tbl_ex6_recip_den
);
   inout         vdd;
   inout         gnd;
   input         clkoff_b;		// tiup
   input         act_dis;		// ??tidn??
   input         flush;		// ??tidn??
   input [2:5]   delay_lclkr;		// tidn,
   input [2:5]   mpw1_b;		// tidn,
   input [0:1]   mpw2_b;		// tidn,
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		//dc_act
   input [0:`NCLK_WIDTH-1]         nclk;

   input         si;		//perv
   output        so;		//perv
   input         ex2_act;		//act
   //----------------------------
   input [1:6]   f_fmt_ex2_b_frac;
   input [7:22]  f_fmt_ex3_b_frac;
   input         f_tbe_ex3_expo_lsb;
   input         f_tbe_ex3_est_recip;
   input         f_tbe_ex3_est_rsqrt;
   input         f_tbe_ex4_recip_ue1;
   input         f_tbe_ex4_lu_sh;
   input         f_tbe_ex4_match_en_sp;
   input         f_tbe_ex4_match_en_dp;
   input         f_tbe_ex4_recip_2046;
   input         f_tbe_ex4_recip_2045;
   input         f_tbe_ex4_recip_2044;
   //----------------------------
   output [0:26] f_tbl_ex6_est_frac;
   output        f_tbl_ex5_unf_expo;
   output        f_tbl_ex6_recip_den;		//generates den flag

   // ENTITY


   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;

   wire          ex5_unf_expo;
   wire [1:6]    ex3_f;
   wire          ex3_sel_recip;
   wire          ex3_sel_rsqte;
   wire          ex3_sel_rsqto;
   wire [1:20]   ex3_est;
   wire [1:20]   ex3_est_recip;
   wire [1:20]   ex3_est_rsqte;
   wire [1:20]   ex3_est_rsqto;
   wire [6:20]   ex3_rng;
   wire [6:20]   ex3_rng_recip;
   wire [6:20]   ex3_rng_rsqte;
   wire [6:20]   ex3_rng_rsqto;

   wire          thold_0_b;
   wire          thold_0;
   wire          force_t;
   wire          sg_0;
   wire          ex3_act;
   wire          ex4_act;
   wire          ex5_act;
   wire [0:3]    spare_unused;

   wire [0:5]    ex3_lut_so;
   wire [0:5]    ex3_lut_si;
   wire [0:6]    act_so;
   wire [0:6]    act_si;
   wire [0:19]   ex4_lut_e_so;
   wire [0:19]   ex4_lut_e_si;
   wire [0:14]   ex4_lut_r_so;
   wire [0:14]   ex4_lut_r_si;
   wire [0:15]   ex4_lut_b_so;
   wire [0:15]   ex4_lut_b_si;

   wire [6:20]   ex4_rng;
   wire [6:20]   ex4_rng_b;
   wire [1:20]   ex4_est;
   wire [1:20]   ex4_est_b;
   wire [7:22]   ex4_bop;
   wire [7:22]   ex4_bop_b;
   wire [0:36]   ex4_tbl_sum;
   wire [0:35]   ex4_tbl_car;
   wire [0:38]   ex5_tbl_sum;
   wire [0:38]   ex5_tbl_car;

   wire [0:79]   ex5_lut_so;
   wire [0:79]   ex5_lut_si;

   wire [0:27]   ex6_lut_so;
   wire [0:27]   ex6_lut_si;
   wire [0:27]   ex5_lu;
   wire [0:27]   ex5_lux;
   wire [0:26]   ex5_lu_nrm;
   wire [0:26]   ex6_lu;

   wire [0:27]   lua_p;
   wire [1:37]   lua_t;
   wire [1:38]   lua_g;
   wire [1:38]   lua_g2;
   wire [1:36]   lua_g4;
   wire [1:32]   lua_g8;
   wire [1:36]   lua_t2;
   wire [1:32]   lua_t4;
   wire [1:28]   lua_t8;
   wire [1:28]   lua_gt8;
   wire [0:27]   lua_s0_b;
   wire [0:27]   lua_s1_b;
   wire [0:3]    lua_g16;
   wire [0:1]    lua_t16;
   wire          lua_c32;
   wire          lua_c24;
   wire          lua_c16;
   wire          lua_c08;
   wire          ex5_recip_den;
   wire          ex6_recip_den;
   wire          ex5_lu_sh;
   wire          ex5_recip_ue1;
   wire          ex5_recip_2044;
   wire          ex5_recip_2046;
   wire          ex5_recip_2045;
   wire          ex5_recip_2044_dp;
   wire          ex5_recip_2046_dp;
   wire          ex5_recip_2045_dp;
   wire          ex5_recip_2044_sp;
   wire          ex5_recip_2046_sp;
   wire          ex5_recip_2045_sp;

   wire          ex5_shlft_1;
   wire          ex5_shlft_0;
   wire          ex5_shrgt_1;
   wire          ex5_shrgt_2;
   wire          ex5_match_en_sp;
   wire          ex5_match_en_dp;
   wire          tbl_ex4_d1clk;
   wire          tbl_ex4_d2clk;
   wire          tbl_ex5_d1clk;
   wire          tbl_ex5_d2clk;
   wire [0:`NCLK_WIDTH-1]          tbl_ex4_lclk;
   wire [0:`NCLK_WIDTH-1]          tbl_ex5_lclk;
   wire          unused;
   wire [0:36]   ex5_tbl_sum_b;
   wire [0:35]   ex5_tbl_car_b;
   wire          ex5_match_en_sp_b;
   wire          ex5_match_en_dp_b;
   wire          ex5_recip_2046_b;
   wire          ex5_recip_2045_b;
   wire          ex5_recip_2044_b;
   wire          ex5_lu_sh_b;
   wire          ex5_recip_ue1_b;

   wire          ex5_sp_chop_24;
   wire          ex5_sp_chop_23;
   wire          ex5_sp_chop_22;
   wire          ex5_sp_chop_21;

   //==##############################################################
   //= map block attributes
   //==##############################################################

   assign unused = |(lua_g8[29:31]) | |(lua_g4[33:35]);

   //==##############################################################
   //= ex3 logic
   //==##############################################################


   tri_rlmreg_p #(.WIDTH(6)) ex3_lut_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex2_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex3_lut_so),
      .scin(ex3_lut_si),
      //-----------------
      .din(f_fmt_ex2_b_frac[1:6]),
      .dout(ex3_f[1:6])
   );

   //==##############################################################
   //= ex3 logic
   //==##############################################################

   //==###########################################
   //= rsqrt ev lookup table
   //==###########################################


   fu_tblsqe  ftbe(
      .f(ex3_f[1:6]),		//i--
      .est(ex3_est_rsqte[1:20]),		//o--
      .rng(ex3_rng_rsqte[6:20])		//o--
   );

   //==###########################################
   //= rsqrt od lookup table
   //==###########################################


   fu_tblsqo  ftbo(
      .f(ex3_f[1:6]),		//i--
      .est(ex3_est_rsqto[1:20]),		//o--
      .rng(ex3_rng_rsqto[6:20])		//o--
   );

   //==###########################################
   //= recip lookup table
   //==###########################################


   fu_tblres  ftbr(
      .f(ex3_f[1:6]),		//i--
      .est(ex3_est_recip[1:20]),		//o--
      .rng(ex3_rng_recip[6:20])		//o--
   );

   //==###########################################
   //= muxing
   //==###########################################

   assign ex3_sel_recip = f_tbe_ex3_est_recip;
   assign ex3_sel_rsqte = f_tbe_ex3_est_rsqrt & (~f_tbe_ex3_expo_lsb);
   assign ex3_sel_rsqto = f_tbe_ex3_est_rsqrt & f_tbe_ex3_expo_lsb;

   assign ex3_est[1:20] = ({20{ex3_sel_recip}} & ex3_est_recip[1:20]) |
                          ({20{ex3_sel_rsqte}} & ex3_est_rsqte[1:20]) |
                          ({20{ex3_sel_rsqto}} & ex3_est_rsqto[1:20]);		// nand2 / nand3

   assign ex3_rng[6:20] = ({15{ex3_sel_recip}} & (ex3_rng_recip[6:20])) |
                          ({15{ex3_sel_rsqte}} & (ex3_rng_rsqte[6:20])) |
                          ({15{ex3_sel_rsqto}} & (ex3_rng_rsqto[6:20]));		// nand2 / nand3

   //==##############################################################
   //= ex4 latches
   //==##############################################################


   tri_inv_nlats #(.WIDTH(20),   .NEEDS_SRESET(0)) ex4_lut_e_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(tbl_ex4_lclk),		// lclk.clk
      .d1clk(tbl_ex4_d1clk),
      .d2clk(tbl_ex4_d2clk),
      .scanin(ex4_lut_e_si),
      .scanout(ex4_lut_e_so),
      .d(ex3_est[1:20]),		//0:19
      .qb(ex4_est_b[1:20])		//0:19
   );


   tri_inv_nlats #(.WIDTH(15),  .NEEDS_SRESET(0)) ex4_lut_r_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(tbl_ex4_lclk),		// lclk.clk
      .d1clk(tbl_ex4_d1clk),
      .d2clk(tbl_ex4_d2clk),
      .scanin(ex4_lut_r_si),
      .scanout(ex4_lut_r_so),
      .d(ex3_rng[6:20]),		//20:34
      .qb(ex4_rng_b[6:20])		//20:34
   );


   tri_inv_nlats #(.WIDTH(16),   .NEEDS_SRESET(0)) ex4_lut_b_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(tbl_ex4_lclk),		// lclk.clk
      .d1clk(tbl_ex4_d1clk),
      .d2clk(tbl_ex4_d2clk),
      .scanin(ex4_lut_b_si),
      .scanout(ex4_lut_b_so),
      .d(f_fmt_ex3_b_frac[7:22]),		//35:50
      .qb(ex4_bop_b[7:22])		//35:50
   );

   assign ex4_est[1:20] = (~ex4_est_b[1:20]);
   assign ex4_rng[6:20] = (~ex4_rng_b[6:20]);
   assign ex4_bop[7:22] = (~ex4_bop_b[7:22]);

   //==##############################################################
   //= ex4 logic : multiply
   //==##############################################################


   tri_fu_tblmul  ftbm(
      .vdd(vdd),
      .gnd(gnd),
      .x(ex4_rng[6:20]),		//i-- RECODED
      .y(ex4_bop[7:22]),		//i-- SHIFTED
      .z({tiup,ex4_est[1:20]}),		//i--
      .tbl_sum(ex4_tbl_sum[0:36]),		//o--
      .tbl_car(ex4_tbl_car[0:35])		//o--
   );

   //==##############################################################
   //= ex5 latches
   //==##############################################################


   tri_inv_nlats #(.WIDTH(80),   .NEEDS_SRESET(0)) ex5_lut_lat(
      .vd(vdd),
      .gd(gnd),
      .lclk(tbl_ex5_lclk),		// lclk.clk
      .d1clk(tbl_ex5_d1clk),
      .d2clk(tbl_ex5_d2clk),
      .scanin(ex5_lut_si),
      .scanout(ex5_lut_so),
      .d({ex4_tbl_sum[0:36],
              ex4_tbl_car[0:35],
             f_tbe_ex4_match_en_sp,
             f_tbe_ex4_match_en_dp,
             f_tbe_ex4_recip_2046,
             f_tbe_ex4_recip_2045,
             f_tbe_ex4_recip_2044,
             f_tbe_ex4_lu_sh,
             f_tbe_ex4_recip_ue1}),
      //----
      .qb({
          ex5_tbl_sum_b[0:36],
          ex5_tbl_car_b[0:35],
          ex5_match_en_sp_b,
          ex5_match_en_dp_b,
          ex5_recip_2046_b,
          ex5_recip_2045_b,
          ex5_recip_2044_b,
          ex5_lu_sh_b,
          ex5_recip_ue1_b})
   );

   assign ex5_tbl_sum[0:36] = (~ex5_tbl_sum_b[0:36]);
   assign ex5_tbl_car[0:35] = (~ex5_tbl_car_b[0:35]);
   assign ex5_match_en_sp = (~ex5_match_en_sp_b);
   assign ex5_match_en_dp = (~ex5_match_en_dp_b);
   assign ex5_recip_2046 = (~ex5_recip_2046_b);
   assign ex5_recip_2045 = (~ex5_recip_2045_b);
   assign ex5_recip_2044 = (~ex5_recip_2044_b);
   assign ex5_lu_sh = (~ex5_lu_sh_b);
   assign ex5_recip_ue1 = (~ex5_recip_ue1_b);

   assign ex5_tbl_sum[37] = tidn;
   assign ex5_tbl_sum[38] = tidn;

   assign ex5_tbl_car[36] = tidn;		//tiup; -- the +1 in -mul = !mul + 1
   assign ex5_tbl_car[37] = tidn;		//tiup; -- the +1 in -mul = !mul + 1
   assign ex5_tbl_car[38] = tidn;		//tiup; -- the +1 in -mul = !mul + 1

   //==##############################################################
   //= ex5 logic : add
   //==##############################################################
   // all bits paricipate in the carry, but only upper bits of sum are returned

   // P/G/T ------------------------------------------------------
   assign lua_p[0:27] = ex5_tbl_sum[0:27] ^ ex5_tbl_car[0:27];
   assign lua_t[1:37] = ex5_tbl_sum[1:37] | ex5_tbl_car[1:37];
   assign lua_g[1:38] = ex5_tbl_sum[1:38] & ex5_tbl_car[1:38];

   // LOCAL BYTE CARRY --------------------------------------------------

   assign lua_g2[38] = lua_g[38];
   assign lua_g2[37] = lua_g[37] | (lua_t[37] & lua_g[38]);
   assign lua_g2[36] = lua_g[36] | (lua_t[36] & lua_g[37]);
   assign lua_g2[35] = lua_g[35] | (lua_t[35] & lua_g[36]);
   assign lua_g2[34] = lua_g[34] | (lua_t[34] & lua_g[35]);
   assign lua_g2[33] = lua_g[33] | (lua_t[33] & lua_g[34]);
   assign lua_g2[32] = lua_g[32] | (lua_t[32] & lua_g[33]);
   //  lua_t2(38) <= lua_t(38) ;
   //  lua_t2(37) <= lua_t(37) and lua_t(38) ;
   assign lua_t2[36] = lua_t[36] & lua_t[37];
   assign lua_t2[35] = lua_t[35] & lua_t[36];
   assign lua_t2[34] = lua_t[34] & lua_t[35];
   assign lua_t2[33] = lua_t[33] & lua_t[34];
   assign lua_t2[32] = lua_t[32] & lua_t[33];
   //  lua_g4(38) <= lua_g2(38) ;
   //  lua_g4(37) <= lua_g2(37) ;
   assign lua_g4[36] = lua_g2[36] | (lua_t2[36] & lua_g2[38]);
   assign lua_g4[35] = lua_g2[35] | (lua_t2[35] & lua_g2[37]);
   assign lua_g4[34] = lua_g2[34] | (lua_t2[34] & lua_g2[36]);
   assign lua_g4[33] = lua_g2[33] | (lua_t2[33] & lua_g2[35]);
   assign lua_g4[32] = lua_g2[32] | (lua_t2[32] & lua_g2[34]);
   // lua_t4(38) <= lua_t2(38) ;
   // lua_t4(37) <= lua_t2(37) ;
   // lua_t4(36) <= lua_t2(36) and lua_t2(38) ;
   // lua_t4(35) <= lua_t2(35) and lua_t2(37) ;
   // lua_t4(34) <= lua_t2(34) and lua_t2(36) ;
   // lua_t4(33) <= lua_t2(33) and lua_t2(35) ;
   assign lua_t4[32] = lua_t2[32] & lua_t2[34];
   //lua_g8(38) <= lua_g4(38) ;
   //lua_g8(37) <= lua_g4(37) ;
   //lua_g8(36) <= lua_g4(36) ;
   //lua_g8(35) <= lua_g4(35) ;
   //lua_g8(34) <= lua_g4(34) or (lua_t4(34) and lua_g4(38) );
   //lua_g8(33) <= lua_g4(33) or (lua_t4(33) and lua_g4(37) );
   assign lua_g8[32] = lua_g4[32] | (lua_t4[32] & lua_g4[36]);
   //lua_t8(38) <= lua_t4(38) ;
   //lua_t8(37) <= lua_t4(37) ;
   //lua_t8(36) <= lua_t4(36) ;
   //lua_t8(35) <= lua_t4(35) ;
   //lua_t8(34) <= lua_t4(34) and lua_t4(38) ;
   //lua_t8(33) <= lua_t4(33) and lua_t4(37) ;
   //lua_t8(32) <= lua_t4(32) and lua_t4(36) ;

   assign lua_g2[31] = lua_g[31];
   assign lua_g2[30] = lua_g[30] | (lua_t[30] & lua_g[31]);
   assign lua_g2[29] = lua_g[29] | (lua_t[29] & lua_g[30]);
   assign lua_g2[28] = lua_g[28] | (lua_t[28] & lua_g[29]);
   assign lua_g2[27] = lua_g[27] | (lua_t[27] & lua_g[28]);
   assign lua_g2[26] = lua_g[26] | (lua_t[26] & lua_g[27]);
   assign lua_g2[25] = lua_g[25] | (lua_t[25] & lua_g[26]);
   assign lua_g2[24] = lua_g[24] | (lua_t[24] & lua_g[25]);
   assign lua_t2[31] = lua_t[31];
   assign lua_t2[30] = lua_t[30] & lua_t[31];
   assign lua_t2[29] = lua_t[29] & lua_t[30];
   assign lua_t2[28] = lua_t[28] & lua_t[29];
   assign lua_t2[27] = lua_t[27] & lua_t[28];
   assign lua_t2[26] = lua_t[26] & lua_t[27];
   assign lua_t2[25] = lua_t[25] & lua_t[26];
   assign lua_t2[24] = lua_t[24] & lua_t[25];
   assign lua_g4[31] = lua_g2[31];
   assign lua_g4[30] = lua_g2[30];
   assign lua_g4[29] = lua_g2[29] | (lua_t2[29] & lua_g2[31]);
   assign lua_g4[28] = lua_g2[28] | (lua_t2[28] & lua_g2[30]);
   assign lua_g4[27] = lua_g2[27] | (lua_t2[27] & lua_g2[29]);
   assign lua_g4[26] = lua_g2[26] | (lua_t2[26] & lua_g2[28]);
   assign lua_g4[25] = lua_g2[25] | (lua_t2[25] & lua_g2[27]);
   assign lua_g4[24] = lua_g2[24] | (lua_t2[24] & lua_g2[26]);
   assign lua_t4[31] = lua_t2[31];
   assign lua_t4[30] = lua_t2[30];
   assign lua_t4[29] = lua_t2[29] & lua_t2[31];
   assign lua_t4[28] = lua_t2[28] & lua_t2[30];
   assign lua_t4[27] = lua_t2[27] & lua_t2[29];
   assign lua_t4[26] = lua_t2[26] & lua_t2[28];
   assign lua_t4[25] = lua_t2[25] & lua_t2[27];
   assign lua_t4[24] = lua_t2[24] & lua_t2[26];
   assign lua_g8[31] = lua_g4[31];
   assign lua_g8[30] = lua_g4[30];
   assign lua_g8[29] = lua_g4[29];
   assign lua_g8[28] = lua_g4[28];
   assign lua_g8[27] = lua_g4[27] | (lua_t4[27] & lua_g4[31]);
   assign lua_g8[26] = lua_g4[26] | (lua_t4[26] & lua_g4[30]);
   assign lua_g8[25] = lua_g4[25] | (lua_t4[25] & lua_g4[29]);
   assign lua_g8[24] = lua_g4[24] | (lua_t4[24] & lua_g4[28]);
   //  lua_t8(31) <= lua_t4(31) ;
   //  lua_t8(30) <= lua_t4(30) ;
   //  lua_t8(29) <= lua_t4(29) ;
   assign lua_t8[28] = lua_t4[28];
   assign lua_t8[27] = lua_t4[27] & lua_t4[31];
   assign lua_t8[26] = lua_t4[26] & lua_t4[30];
   assign lua_t8[25] = lua_t4[25] & lua_t4[29];
   assign lua_t8[24] = lua_t4[24] & lua_t4[28];

   assign lua_g2[23] = lua_g[23];
   assign lua_g2[22] = lua_g[22] | (lua_t[22] & lua_g[23]);
   assign lua_g2[21] = lua_g[21] | (lua_t[21] & lua_g[22]);
   assign lua_g2[20] = lua_g[20] | (lua_t[20] & lua_g[21]);
   assign lua_g2[19] = lua_g[19] | (lua_t[19] & lua_g[20]);
   assign lua_g2[18] = lua_g[18] | (lua_t[18] & lua_g[19]);
   assign lua_g2[17] = lua_g[17] | (lua_t[17] & lua_g[18]);
   assign lua_g2[16] = lua_g[16] | (lua_t[16] & lua_g[17]);
   assign lua_t2[23] = lua_t[23];
   assign lua_t2[22] = lua_t[22] & lua_t[23];
   assign lua_t2[21] = lua_t[21] & lua_t[22];
   assign lua_t2[20] = lua_t[20] & lua_t[21];
   assign lua_t2[19] = lua_t[19] & lua_t[20];
   assign lua_t2[18] = lua_t[18] & lua_t[19];
   assign lua_t2[17] = lua_t[17] & lua_t[18];
   assign lua_t2[16] = lua_t[16] & lua_t[17];
   assign lua_g4[23] = lua_g2[23];
   assign lua_g4[22] = lua_g2[22];
   assign lua_g4[21] = lua_g2[21] | (lua_t2[21] & lua_g2[23]);
   assign lua_g4[20] = lua_g2[20] | (lua_t2[20] & lua_g2[22]);
   assign lua_g4[19] = lua_g2[19] | (lua_t2[19] & lua_g2[21]);
   assign lua_g4[18] = lua_g2[18] | (lua_t2[18] & lua_g2[20]);
   assign lua_g4[17] = lua_g2[17] | (lua_t2[17] & lua_g2[19]);
   assign lua_g4[16] = lua_g2[16] | (lua_t2[16] & lua_g2[18]);
   assign lua_t4[23] = lua_t2[23];
   assign lua_t4[22] = lua_t2[22];
   assign lua_t4[21] = lua_t2[21] & lua_t2[23];
   assign lua_t4[20] = lua_t2[20] & lua_t2[22];
   assign lua_t4[19] = lua_t2[19] & lua_t2[21];
   assign lua_t4[18] = lua_t2[18] & lua_t2[20];
   assign lua_t4[17] = lua_t2[17] & lua_t2[19];
   assign lua_t4[16] = lua_t2[16] & lua_t2[18];
   assign lua_g8[23] = lua_g4[23];
   assign lua_g8[22] = lua_g4[22];
   assign lua_g8[21] = lua_g4[21];
   assign lua_g8[20] = lua_g4[20];
   assign lua_g8[19] = lua_g4[19] | (lua_t4[19] & lua_g4[23]);
   assign lua_g8[18] = lua_g4[18] | (lua_t4[18] & lua_g4[22]);
   assign lua_g8[17] = lua_g4[17] | (lua_t4[17] & lua_g4[21]);
   assign lua_g8[16] = lua_g4[16] | (lua_t4[16] & lua_g4[20]);
   assign lua_t8[23] = lua_t4[23];
   assign lua_t8[22] = lua_t4[22];
   assign lua_t8[21] = lua_t4[21];
   assign lua_t8[20] = lua_t4[20];
   assign lua_t8[19] = lua_t4[19] & lua_t4[23];
   assign lua_t8[18] = lua_t4[18] & lua_t4[22];
   assign lua_t8[17] = lua_t4[17] & lua_t4[21];
   assign lua_t8[16] = lua_t4[16] & lua_t4[20];

   assign lua_g2[15] = lua_g[15];
   assign lua_g2[14] = lua_g[14] | (lua_t[14] & lua_g[15]);
   assign lua_g2[13] = lua_g[13] | (lua_t[13] & lua_g[14]);
   assign lua_g2[12] = lua_g[12] | (lua_t[12] & lua_g[13]);
   assign lua_g2[11] = lua_g[11] | (lua_t[11] & lua_g[12]);
   assign lua_g2[10] = lua_g[10] | (lua_t[10] & lua_g[11]);
   assign lua_g2[9] = lua_g[9] | (lua_t[9] & lua_g[10]);
   assign lua_g2[8] = lua_g[8] | (lua_t[8] & lua_g[9]);
   assign lua_t2[15] = lua_t[15];
   assign lua_t2[14] = lua_t[14] & lua_t[15];
   assign lua_t2[13] = lua_t[13] & lua_t[14];
   assign lua_t2[12] = lua_t[12] & lua_t[13];
   assign lua_t2[11] = lua_t[11] & lua_t[12];
   assign lua_t2[10] = lua_t[10] & lua_t[11];
   assign lua_t2[9] = lua_t[9] & lua_t[10];
   assign lua_t2[8] = lua_t[8] & lua_t[9];
   assign lua_g4[15] = lua_g2[15];
   assign lua_g4[14] = lua_g2[14];
   assign lua_g4[13] = lua_g2[13] | (lua_t2[13] & lua_g2[15]);
   assign lua_g4[12] = lua_g2[12] | (lua_t2[12] & lua_g2[14]);
   assign lua_g4[11] = lua_g2[11] | (lua_t2[11] & lua_g2[13]);
   assign lua_g4[10] = lua_g2[10] | (lua_t2[10] & lua_g2[12]);
   assign lua_g4[9] = lua_g2[9] | (lua_t2[9] & lua_g2[11]);
   assign lua_g4[8] = lua_g2[8] | (lua_t2[8] & lua_g2[10]);
   assign lua_t4[15] = lua_t2[15];
   assign lua_t4[14] = lua_t2[14];
   assign lua_t4[13] = lua_t2[13] & lua_t2[15];
   assign lua_t4[12] = lua_t2[12] & lua_t2[14];
   assign lua_t4[11] = lua_t2[11] & lua_t2[13];
   assign lua_t4[10] = lua_t2[10] & lua_t2[12];
   assign lua_t4[9] = lua_t2[9] & lua_t2[11];
   assign lua_t4[8] = lua_t2[8] & lua_t2[10];
   assign lua_g8[15] = lua_g4[15];
   assign lua_g8[14] = lua_g4[14];
   assign lua_g8[13] = lua_g4[13];
   assign lua_g8[12] = lua_g4[12];
   assign lua_g8[11] = lua_g4[11] | (lua_t4[11] & lua_g4[15]);
   assign lua_g8[10] = lua_g4[10] | (lua_t4[10] & lua_g4[14]);
   assign lua_g8[9] = lua_g4[9] | (lua_t4[9] & lua_g4[13]);
   assign lua_g8[8] = lua_g4[8] | (lua_t4[8] & lua_g4[12]);
   assign lua_t8[15] = lua_t4[15];
   assign lua_t8[14] = lua_t4[14];
   assign lua_t8[13] = lua_t4[13];
   assign lua_t8[12] = lua_t4[12];
   assign lua_t8[11] = lua_t4[11] & lua_t4[15];
   assign lua_t8[10] = lua_t4[10] & lua_t4[14];
   assign lua_t8[9] = lua_t4[9] & lua_t4[13];
   assign lua_t8[8] = lua_t4[8] & lua_t4[12];

   assign lua_g2[7] = lua_g[7];
   assign lua_g2[6] = lua_g[6] | (lua_t[6] & lua_g[7]);
   assign lua_g2[5] = lua_g[5] | (lua_t[5] & lua_g[6]);
   assign lua_g2[4] = lua_g[4] | (lua_t[4] & lua_g[5]);
   assign lua_g2[3] = lua_g[3] | (lua_t[3] & lua_g[4]);
   assign lua_g2[2] = lua_g[2] | (lua_t[2] & lua_g[3]);
   assign lua_g2[1] = lua_g[1] | (lua_t[1] & lua_g[2]);
   //  lua_g2(0) <= lua_g(0) or (lua_t(0) and lua_g(1) );
   assign lua_t2[7] = lua_t[7];
   assign lua_t2[6] = lua_t[6] & lua_t[7];
   assign lua_t2[5] = lua_t[5] & lua_t[6];
   assign lua_t2[4] = lua_t[4] & lua_t[5];
   assign lua_t2[3] = lua_t[3] & lua_t[4];
   assign lua_t2[2] = lua_t[2] & lua_t[3];
   assign lua_t2[1] = lua_t[1] & lua_t[2];
   //  lua_t2(0) <= lua_t(0) and lua_t(1) ;
   assign lua_g4[7] = lua_g2[7];
   assign lua_g4[6] = lua_g2[6];
   assign lua_g4[5] = lua_g2[5] | (lua_t2[5] & lua_g2[7]);
   assign lua_g4[4] = lua_g2[4] | (lua_t2[4] & lua_g2[6]);
   assign lua_g4[3] = lua_g2[3] | (lua_t2[3] & lua_g2[5]);
   assign lua_g4[2] = lua_g2[2] | (lua_t2[2] & lua_g2[4]);
   assign lua_g4[1] = lua_g2[1] | (lua_t2[1] & lua_g2[3]);
   //  lua_g4(0) <= lua_g2(0) or (lua_t2(0) and lua_g2(2) );
   assign lua_t4[7] = lua_t2[7];
   assign lua_t4[6] = lua_t2[6];
   assign lua_t4[5] = lua_t2[5] & lua_t2[7];
   assign lua_t4[4] = lua_t2[4] & lua_t2[6];
   assign lua_t4[3] = lua_t2[3] & lua_t2[5];
   assign lua_t4[2] = lua_t2[2] & lua_t2[4];
   assign lua_t4[1] = lua_t2[1] & lua_t2[3];
   //  lua_t4(0) <= lua_t2(0) and lua_t2(2) ;
   assign lua_g8[7] = lua_g4[7];
   assign lua_g8[6] = lua_g4[6];
   assign lua_g8[5] = lua_g4[5];
   assign lua_g8[4] = lua_g4[4];
   assign lua_g8[3] = lua_g4[3] | (lua_t4[3] & lua_g4[7]);
   assign lua_g8[2] = lua_g4[2] | (lua_t4[2] & lua_g4[6]);
   assign lua_g8[1] = lua_g4[1] | (lua_t4[1] & lua_g4[5]);
   //lua_g8(0) <= lua_g4(0) or (lua_t4(0) and lua_g4(4) );
   assign lua_t8[7] = lua_t4[7];
   assign lua_t8[6] = lua_t4[6];
   assign lua_t8[5] = lua_t4[5];
   assign lua_t8[4] = lua_t4[4];
   assign lua_t8[3] = lua_t4[3] & lua_t4[7];
   assign lua_t8[2] = lua_t4[2] & lua_t4[6];
   assign lua_t8[1] = lua_t4[1] & lua_t4[5];
   //lua_t8(0) <= lua_t4(0) and lua_t4(4) ;

   // CONDITIONL SUM ---------------------------------------------

   assign lua_gt8[1:28] = lua_g8[1:28] | lua_t8[1:28];

   assign lua_s1_b[0:27] = (~(lua_p[0:27] ^ lua_gt8[1:28]));
   assign lua_s0_b[0:27] = (~(lua_p[0:27] ^ lua_g8[1:28]));

   // BYTE SELECT ------------------------------
   // ex5_lu(0 to 27) <= not( ex5_lu_p(0 to 27) xor ex5_lu_c(1 to 28) ); -- invert

   assign ex5_lu[0] = (lua_s0_b[0] & (~lua_c08)) | (lua_s1_b[0] & lua_c08);
   assign ex5_lu[1] = (lua_s0_b[1] & (~lua_c08)) | (lua_s1_b[1] & lua_c08);
   assign ex5_lu[2] = (lua_s0_b[2] & (~lua_c08)) | (lua_s1_b[2] & lua_c08);
   assign ex5_lu[3] = (lua_s0_b[3] & (~lua_c08)) | (lua_s1_b[3] & lua_c08);
   assign ex5_lu[4] = (lua_s0_b[4] & (~lua_c08)) | (lua_s1_b[4] & lua_c08);
   assign ex5_lu[5] = (lua_s0_b[5] & (~lua_c08)) | (lua_s1_b[5] & lua_c08);
   assign ex5_lu[6] = (lua_s0_b[6] & (~lua_c08)) | (lua_s1_b[6] & lua_c08);
   assign ex5_lu[7] = (lua_s0_b[7] & (~lua_c08)) | (lua_s1_b[7] & lua_c08);

   assign ex5_lu[8] = (lua_s0_b[8] & (~lua_c16)) | (lua_s1_b[8] & lua_c16);
   assign ex5_lu[9] = (lua_s0_b[9] & (~lua_c16)) | (lua_s1_b[9] & lua_c16);
   assign ex5_lu[10] = (lua_s0_b[10] & (~lua_c16)) | (lua_s1_b[10] & lua_c16);
   assign ex5_lu[11] = (lua_s0_b[11] & (~lua_c16)) | (lua_s1_b[11] & lua_c16);
   assign ex5_lu[12] = (lua_s0_b[12] & (~lua_c16)) | (lua_s1_b[12] & lua_c16);
   assign ex5_lu[13] = (lua_s0_b[13] & (~lua_c16)) | (lua_s1_b[13] & lua_c16);
   assign ex5_lu[14] = (lua_s0_b[14] & (~lua_c16)) | (lua_s1_b[14] & lua_c16);
   assign ex5_lu[15] = (lua_s0_b[15] & (~lua_c16)) | (lua_s1_b[15] & lua_c16);

   assign ex5_lu[16] = (lua_s0_b[16] & (~lua_c24)) | (lua_s1_b[16] & lua_c24);
   assign ex5_lu[17] = (lua_s0_b[17] & (~lua_c24)) | (lua_s1_b[17] & lua_c24);
   assign ex5_lu[18] = (lua_s0_b[18] & (~lua_c24)) | (lua_s1_b[18] & lua_c24);
   assign ex5_lu[19] = (lua_s0_b[19] & (~lua_c24)) | (lua_s1_b[19] & lua_c24);
   assign ex5_lu[20] = (lua_s0_b[20] & (~lua_c24)) | (lua_s1_b[20] & lua_c24);
   assign ex5_lu[21] = (lua_s0_b[21] & (~lua_c24)) | (lua_s1_b[21] & lua_c24);
   assign ex5_lu[22] = (lua_s0_b[22] & (~lua_c24)) | (lua_s1_b[22] & lua_c24);
   assign ex5_lu[23] = (lua_s0_b[23] & (~lua_c24)) | (lua_s1_b[23] & lua_c24);

   assign ex5_lu[24] = (lua_s0_b[24] & (~lua_c32)) | (lua_s1_b[24] & lua_c32);
   assign ex5_lu[25] = (lua_s0_b[25] & (~lua_c32)) | (lua_s1_b[25] & lua_c32);
   assign ex5_lu[26] = (lua_s0_b[26] & (~lua_c32)) | (lua_s1_b[26] & lua_c32);
   assign ex5_lu[27] = (lua_s0_b[27] & (~lua_c32)) | (lua_s1_b[27] & lua_c32);

   // GLOBAL BYTE CARRY  ------------------------------

   assign lua_g16[3] = lua_g8[32];
   assign lua_g16[2] = lua_g8[24] | (lua_t8[24] & lua_g8[32]);
   assign lua_g16[1] = lua_g8[16] | (lua_t8[16] & lua_g8[24]);
   assign lua_g16[0] = lua_g8[8] | (lua_t8[8] & lua_g8[16]);

   //lua_t16(3) <= lua_t8(32);
   //lua_t16(2) <= lua_t8(24) and lua_t8(32) ;
   assign lua_t16[1] = lua_t8[16] & lua_t8[24];
   assign lua_t16[0] = lua_t8[8] & lua_t8[16];

   assign lua_c32 = lua_g16[3];
   assign lua_c24 = lua_g16[2];
   assign lua_c16 = lua_g16[1] | (lua_t16[1] & lua_g16[3]);
   assign lua_c08 = lua_g16[0] | (lua_t16[0] & lua_g16[2]);

   //---------------------------------------------------------------
   // normalize
   //---------------------------------------------------------------
   // expo=2046 ==> imp=0 shift right 1
   // expo=2045 ==> imp=0 shift right 0
   // expo=other => imp=1 shift right 0 <normal reslts>
   assign ex5_recip_2044_dp = ex5_recip_2044 & ex5_match_en_dp & (~ex5_recip_ue1);
   assign ex5_recip_2045_dp = ex5_recip_2045 & ex5_match_en_dp & (~ex5_recip_ue1);
   assign ex5_recip_2046_dp = ex5_recip_2046 & ex5_match_en_dp & (~ex5_recip_ue1);

   assign ex5_recip_2044_sp = ex5_recip_2044 & ex5_match_en_sp & (~ex5_recip_ue1);
   assign ex5_recip_2045_sp = ex5_recip_2045 & ex5_match_en_sp & (~ex5_recip_ue1);
   assign ex5_recip_2046_sp = ex5_recip_2046 & ex5_match_en_sp & (~ex5_recip_ue1);

   // lu_sh means : shift left one, and decr exponent (unless it will create a denorm exponent)

   // result in norm dp fmt, but set fpscr flag for sp unf
   // result in norm dp fmt, but set fpscr flag for sp unf
   // result in norm dp fmt, but set fpscr flag for sp unf
   assign ex5_recip_den = ex5_recip_2046_sp | ex5_recip_2045_sp | (ex5_lu_sh & ex5_recip_2044_sp) | ex5_recip_2046_dp | ex5_recip_2045_dp | (ex5_lu_sh & ex5_recip_2044_dp);		// use in round to set implicit bit
   // cannot shift left , denorm result

   // by not denormalizing sp the fpscr(ux) is set even though the implicit bit is set
   // divide does not want the denormed result
   // for setting UX (same for ue=0, ue=1
   //    (                   ex5_match_en_dp) and -- leave SP normalized
   assign ex5_unf_expo = (ex5_match_en_sp | ex5_match_en_dp) & (ex5_recip_2046 | ex5_recip_2045 | (ex5_recip_2044 & ex5_lu_sh));		// leave SP normalized

   assign f_tbl_ex5_unf_expo = ex5_unf_expo;		//output--

   assign ex5_shlft_1 = (~ex5_recip_2046_dp) & (~ex5_recip_2045_dp) & (ex5_lu_sh & (~ex5_recip_2044_dp));
   assign ex5_shlft_0 = (~ex5_recip_2046_dp) & (~ex5_recip_2045_dp) & (~(ex5_lu_sh & (~ex5_recip_2044_dp)));
   assign ex5_shrgt_1 = ex5_recip_2045_dp;
   assign ex5_shrgt_2 = ex5_recip_2046_dp;

   // the final sp result will be in dp_norm format for an sp_denorm.
   // emulate the dropping of bits when an sp is shifted right then fitted into 23 frac bits.

   assign ex5_sp_chop_24 = ex5_recip_2046_sp | ex5_recip_2045_sp | ex5_recip_2044_sp;
   assign ex5_sp_chop_23 = ex5_recip_2046_sp | ex5_recip_2045_sp;
   assign ex5_sp_chop_22 = ex5_recip_2046_sp;
   assign ex5_sp_chop_21 = tidn;

   assign ex5_lux[0:20] = ex5_lu[0:20];
   assign ex5_lux[21] = ex5_lu[21] & (~ex5_sp_chop_21);
   assign ex5_lux[22] = ex5_lu[22] & (~ex5_sp_chop_22);
   assign ex5_lux[23] = ex5_lu[23] & (~ex5_sp_chop_23);
   assign ex5_lux[24] = ex5_lu[24] & (~ex5_sp_chop_24);
   assign ex5_lux[25:27] = ex5_lu[25:27];

   assign ex5_lu_nrm[0:26] = ({27{ex5_shlft_1}} & (ex5_lux[1:27])) |
                             ({27{ex5_shlft_0}} & (ex5_lux[0:26])) |
                             ({27{ex5_shrgt_1}} & ({tidn, ex5_lux[0:25]})) |
                             ({27{ex5_shrgt_2}} & ({tidn, tidn, ex5_lux[0:24]}));

   //==##############################################################
   //= ex6 latches
   //==##############################################################


   tri_rlmreg_p #(.WIDTH(28)) ex6_lut_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex5_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex6_lut_so),
      .scin(ex6_lut_si),
      //-----------------
      .din({ex5_lu_nrm[0:26],
            ex5_recip_den}),
      .dout({ex6_lu[0:26],
             ex6_recip_den})
   );

   assign f_tbl_ex6_est_frac[0:26] = ex6_lu[0:26];
   assign f_tbl_ex6_recip_den = ex6_recip_den;

   //==##############################################################
   //= pervasive
   //==##############################################################


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

   //==##############################################################
   //= act
   //==##############################################################


   tri_rlmreg_p #(.WIDTH(7)) act_lat(
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({spare_unused[0],
            spare_unused[1],
            ex2_act,
            ex3_act,
            ex4_act,
            spare_unused[2],
            spare_unused[3]}),
      //-----------------
      .dout({  spare_unused[0],
               spare_unused[1],
               ex3_act,
               ex4_act,
               ex5_act,
               spare_unused[2],
               spare_unused[3]})
   );


   tri_lcbnd  tbl_ex4_lcb(
      .delay_lclkr(delay_lclkr[3]),		// tidn ,--in
      .mpw1_b(mpw1_b[3]),		// tidn ,--in
      .mpw2_b(mpw2_b[0]),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex3_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(tbl_ex4_d1clk),		//out
      .d2clk(tbl_ex4_d2clk),		//out
      .lclk(tbl_ex4_lclk)		//out
   );


   tri_lcbnd  tbl_ex5_lcb(
      .delay_lclkr(delay_lclkr[4]),		// tidn ,--in
      .mpw1_b(mpw1_b[4]),		// tidn ,--in
      .mpw2_b(mpw2_b[0]),		// tidn ,--in
      .force_t(force_t),		// tidn ,--in
      .nclk(nclk),		//in
      .vd(vdd),		//inout
      .gd(gnd),		//inout
      .act(ex4_act),		//in
      .sg(sg_0),		//in
      .thold_b(thold_0_b),		//in
      .d1clk(tbl_ex5_d1clk),		//out
      .d2clk(tbl_ex5_d2clk),		//out
      .lclk(tbl_ex5_lclk)		//out
   );

   //==##############################################################
   //= scan string
   //==##############################################################

   assign ex3_lut_si[0:5] = {ex3_lut_so[1:5], si};
   assign ex4_lut_e_si[0:19] = {ex4_lut_e_so[1:19], ex3_lut_so[0]};
   assign ex4_lut_r_si[0:14] = {ex4_lut_r_so[1:14], ex4_lut_e_so[0]};
   assign ex4_lut_b_si[0:15] = {ex4_lut_b_so[1:15], ex4_lut_r_so[0]};
   assign ex5_lut_si[0:79] = {ex5_lut_so[1:79], ex4_lut_b_so[0]};
   assign ex6_lut_si[0:27] = {ex6_lut_so[1:27], ex5_lut_so[0]};
   assign act_si[0:6] = {act_so[1:6], ex6_lut_so[0]};
   assign so = act_so[0];		//SCAN

endmodule
