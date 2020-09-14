// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

`timescale 1 ns / 1 ns



module fu_tblexp(
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
   ex2_act_b,
   f_pic_ex3_ue1,
   f_pic_ex3_sp_b,
   f_pic_ex3_est_recip,
   f_pic_ex3_est_rsqrt,
   f_eie_ex3_tbl_expo,
   f_fmt_ex3_lu_den_recip,
   f_fmt_ex3_lu_den_rsqrto,
   f_tbe_ex4_recip_ue1,
   f_tbe_ex4_lu_sh,
   f_tbe_ex4_match_en_sp,
   f_tbe_ex4_match_en_dp,
   f_tbe_ex4_recip_2046,
   f_tbe_ex4_recip_2045,
   f_tbe_ex4_recip_2044,
   f_tbe_ex4_may_ov,
   f_tbe_ex4_res_expo
);
   `include "tri_a2o.vh"
  

   
   inout         vdd;
   inout         gnd;
   input         clkoff_b;		
   input         act_dis;		
   input         flush;		
   input [2:3]   delay_lclkr;		
   input [2:3]   mpw1_b;		
   input [0:0]   mpw2_b;		
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		
   input [0:`NCLK_WIDTH-1]          nclk;
   
   input         si;		
   output        so;		
   input         ex2_act_b;		
   
   input         f_pic_ex3_ue1;
   input         f_pic_ex3_sp_b;
   input         f_pic_ex3_est_recip;
   input         f_pic_ex3_est_rsqrt;
   input [1:13]  f_eie_ex3_tbl_expo;
   input         f_fmt_ex3_lu_den_recip;
   input         f_fmt_ex3_lu_den_rsqrto;
   
   output        f_tbe_ex4_recip_ue1;
   output        f_tbe_ex4_lu_sh;
   output        f_tbe_ex4_match_en_sp;
   output        f_tbe_ex4_match_en_dp;
   output        f_tbe_ex4_recip_2046;
   output        f_tbe_ex4_recip_2045;
   output        f_tbe_ex4_recip_2044;
   output        f_tbe_ex4_may_ov;
   output [1:13] f_tbe_ex4_res_expo;		
   
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire          thold_0_b;
   wire          thold_0;
   wire          force_t;
   wire          sg_0;
   wire [0:3]    act_spare_unused;
   wire          ex3_act;
   wire [0:4]    act_so;
   wire [0:4]    act_si;
   wire [0:19]   ex4_expo_so;
   wire [0:19]   ex4_expo_si;
   wire [1:13]   ex3_res_expo;
   wire [1:13]   ex4_res_expo;
   wire          ex4_recip_2044;
   wire          ex3_recip_2044;
   wire          ex3_recip_ue1;
   wire          ex4_recip_2045;
   wire          ex3_recip_2045;
   wire          ex4_recip_ue1;
   wire          ex4_recip_2046;
   wire          ex3_recip_2046;
   wire          ex4_force_expo_den;
   
   wire [1:13]   ex3_b_expo_adj_b;
   wire [1:13]   ex3_b_expo_adj;
   wire [1:13]   ex3_recip_k;
   wire [1:13]   ex3_recip_p;
   wire [2:13]   ex3_recip_g;
   wire [2:12]   ex3_recip_t;
   wire [2:13]   ex3_recip_c;
   wire [1:13]   ex3_recip_expo;
   wire [1:13]   ex3_rsqrt_k;
   wire [1:13]   ex3_rsqrt_p;
   wire [2:13]   ex3_rsqrt_g;
   wire [2:12]   ex3_rsqrt_t;
   wire [2:13]   ex3_rsqrt_c;
   wire [1:13]   ex3_rsqrt_expo;
   wire [1:13]   ex3_rsqrt_bsh_b;
   
   wire [2:13]   ex3_recip_g2;
   wire [2:11]   ex3_recip_t2;
   wire [2:13]   ex3_recip_g4;
   wire [2:9]    ex3_recip_t4;
   wire [2:13]   ex3_recip_g8;
   wire [2:5]    ex3_recip_t8;
   
   wire [2:13]   ex3_rsqrt_g2;
   wire [2:11]   ex3_rsqrt_t2;
   wire [2:13]   ex3_rsqrt_g4;
   wire [2:9]    ex3_rsqrt_t4;
   wire [2:13]   ex3_rsqrt_g8;
   wire [2:5]    ex3_rsqrt_t8;
   wire          ex2_act;
   
   wire          ex3_lu_sh;
   wire          ex4_lu_sh;
   wire [2:13]   ex4_res_expo_c;
   wire [2:13]   ex4_res_expo_g8_b;
   wire [2:13]   ex4_res_expo_g4;
   wire [2:13]   ex4_res_expo_g2_b;
   wire [1:13]   ex4_res_decr;
   wire [1:13]   ex4_res_expo_b;
   wire          ex4_decr_expo;
   
   wire          ex3_mid_match_ifsp;
   wire          ex3_mid_match_ifdp;
   wire          ex3_match_en_dp;
   wire          ex3_match_en_sp;
   wire          ex4_match_en_dp;
   wire          ex4_match_en_sp;
   wire          ex3_com_match;
   wire          ex4_recip_2044_dp;
   wire          ex4_recip_2045_dp;
   wire          ex4_recip_2046_dp;
   
   
   
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
   
   
   
   
   
   assign ex2_act = (~ex2_act_b);
   
   
   tri_rlmreg_p #(.WIDTH(5)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),   
      .delay_lclkr(delay_lclkr[2]),		
      .mpw1_b(mpw1_b[2]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(fpu_enable),
      .scout(act_so),
      .scin(act_si),
      .din({  act_spare_unused[0],
              act_spare_unused[1],
              ex2_act,
              act_spare_unused[2],
              act_spare_unused[3]}),
      .dout({ act_spare_unused[0],
              act_spare_unused[1],
              ex3_act,
              act_spare_unused[2],
              act_spare_unused[3]})
   );
   
   
   
   
   
   assign ex3_b_expo_adj[1:13] = f_eie_ex3_tbl_expo[1:13];
   assign ex3_b_expo_adj_b[1:13] = (~ex3_b_expo_adj[1:13]);
   
   
   assign ex3_recip_k[1:13] = {{2{tidn}}, {10{tiup}}, tidn};
   
   assign ex3_recip_p[1:13] = ex3_recip_k[1:13] ^ ex3_b_expo_adj_b[1:13];
   assign ex3_recip_g[2:13] = ex3_recip_k[2:13] & ex3_b_expo_adj_b[2:13];
   assign ex3_recip_t[2:12] = ex3_recip_k[2:12] | ex3_b_expo_adj_b[2:12];
   
   assign ex3_recip_g2[13] = ex3_recip_g[13];
   assign ex3_recip_g2[12] = ex3_recip_g[12] | (ex3_recip_t[12] & ex3_recip_g[13]);
   assign ex3_recip_g2[11] = ex3_recip_g[11] | (ex3_recip_t[11] & ex3_recip_g[12]);
   assign ex3_recip_g2[10] = ex3_recip_g[10] | (ex3_recip_t[10] & ex3_recip_g[11]);
   assign ex3_recip_g2[9] = ex3_recip_g[9] | (ex3_recip_t[9] & ex3_recip_g[10]);
   assign ex3_recip_g2[8] = ex3_recip_g[8] | (ex3_recip_t[8] & ex3_recip_g[9]);
   assign ex3_recip_g2[7] = ex3_recip_g[7] | (ex3_recip_t[7] & ex3_recip_g[8]);
   assign ex3_recip_g2[6] = ex3_recip_g[6] | (ex3_recip_t[6] & ex3_recip_g[7]);
   assign ex3_recip_g2[5] = ex3_recip_g[5] | (ex3_recip_t[5] & ex3_recip_g[6]);
   assign ex3_recip_g2[4] = ex3_recip_g[4] | (ex3_recip_t[4] & ex3_recip_g[5]);
   assign ex3_recip_g2[3] = ex3_recip_g[3] | (ex3_recip_t[3] & ex3_recip_g[4]);
   assign ex3_recip_g2[2] = ex3_recip_g[2] | (ex3_recip_t[2] & ex3_recip_g[3]);
   
   assign ex3_recip_t2[11] = (ex3_recip_t[11] & ex3_recip_t[12]);
   assign ex3_recip_t2[10] = (ex3_recip_t[10] & ex3_recip_t[11]);
   assign ex3_recip_t2[9] = (ex3_recip_t[9] & ex3_recip_t[10]);
   assign ex3_recip_t2[8] = (ex3_recip_t[8] & ex3_recip_t[9]);
   assign ex3_recip_t2[7] = (ex3_recip_t[7] & ex3_recip_t[8]);
   assign ex3_recip_t2[6] = (ex3_recip_t[6] & ex3_recip_t[7]);
   assign ex3_recip_t2[5] = (ex3_recip_t[5] & ex3_recip_t[6]);
   assign ex3_recip_t2[4] = (ex3_recip_t[4] & ex3_recip_t[5]);
   assign ex3_recip_t2[3] = (ex3_recip_t[3] & ex3_recip_t[4]);
   assign ex3_recip_t2[2] = (ex3_recip_t[2] & ex3_recip_t[3]);
   
   assign ex3_recip_g4[13] = ex3_recip_g2[13];
   assign ex3_recip_g4[12] = ex3_recip_g2[12];
   assign ex3_recip_g4[11] = ex3_recip_g2[11] | (ex3_recip_t2[11] & ex3_recip_g2[13]);
   assign ex3_recip_g4[10] = ex3_recip_g2[10] | (ex3_recip_t2[10] & ex3_recip_g2[12]);
   assign ex3_recip_g4[9] = ex3_recip_g2[9] | (ex3_recip_t2[9] & ex3_recip_g2[11]);
   assign ex3_recip_g4[8] = ex3_recip_g2[8] | (ex3_recip_t2[8] & ex3_recip_g2[10]);
   assign ex3_recip_g4[7] = ex3_recip_g2[7] | (ex3_recip_t2[7] & ex3_recip_g2[9]);
   assign ex3_recip_g4[6] = ex3_recip_g2[6] | (ex3_recip_t2[6] & ex3_recip_g2[8]);
   assign ex3_recip_g4[5] = ex3_recip_g2[5] | (ex3_recip_t2[5] & ex3_recip_g2[7]);
   assign ex3_recip_g4[4] = ex3_recip_g2[4] | (ex3_recip_t2[4] & ex3_recip_g2[6]);
   assign ex3_recip_g4[3] = ex3_recip_g2[3] | (ex3_recip_t2[3] & ex3_recip_g2[5]);
   assign ex3_recip_g4[2] = ex3_recip_g2[2] | (ex3_recip_t2[2] & ex3_recip_g2[4]);
   
   assign ex3_recip_t4[9] = (ex3_recip_t2[9] & ex3_recip_t2[11]);
   assign ex3_recip_t4[8] = (ex3_recip_t2[8] & ex3_recip_t2[10]);
   assign ex3_recip_t4[7] = (ex3_recip_t2[7] & ex3_recip_t2[9]);
   assign ex3_recip_t4[6] = (ex3_recip_t2[6] & ex3_recip_t2[8]);
   assign ex3_recip_t4[5] = (ex3_recip_t2[5] & ex3_recip_t2[7]);
   assign ex3_recip_t4[4] = (ex3_recip_t2[4] & ex3_recip_t2[6]);
   assign ex3_recip_t4[3] = (ex3_recip_t2[3] & ex3_recip_t2[5]);
   assign ex3_recip_t4[2] = (ex3_recip_t2[2] & ex3_recip_t2[4]);
   
   assign ex3_recip_g8[13] = ex3_recip_g4[13];
   assign ex3_recip_g8[12] = ex3_recip_g4[12];
   assign ex3_recip_g8[11] = ex3_recip_g4[11];
   assign ex3_recip_g8[10] = ex3_recip_g4[10];
   assign ex3_recip_g8[9] = ex3_recip_g4[9] | (ex3_recip_t4[9] & ex3_recip_g4[13]);
   assign ex3_recip_g8[8] = ex3_recip_g4[8] | (ex3_recip_t4[8] & ex3_recip_g4[12]);
   assign ex3_recip_g8[7] = ex3_recip_g4[7] | (ex3_recip_t4[7] & ex3_recip_g4[11]);
   assign ex3_recip_g8[6] = ex3_recip_g4[6] | (ex3_recip_t4[6] & ex3_recip_g4[10]);
   assign ex3_recip_g8[5] = ex3_recip_g4[5] | (ex3_recip_t4[5] & ex3_recip_g4[9]);
   assign ex3_recip_g8[4] = ex3_recip_g4[4] | (ex3_recip_t4[4] & ex3_recip_g4[8]);
   assign ex3_recip_g8[3] = ex3_recip_g4[3] | (ex3_recip_t4[3] & ex3_recip_g4[7]);
   assign ex3_recip_g8[2] = ex3_recip_g4[2] | (ex3_recip_t4[2] & ex3_recip_g4[6]);
   
   assign ex3_recip_t8[5] = (ex3_recip_t4[5] & ex3_recip_t4[9]);
   assign ex3_recip_t8[4] = (ex3_recip_t4[4] & ex3_recip_t4[8]);
   assign ex3_recip_t8[3] = (ex3_recip_t4[3] & ex3_recip_t4[7]);
   assign ex3_recip_t8[2] = (ex3_recip_t4[2] & ex3_recip_t4[6]);
   
   assign ex3_recip_c[13] = ex3_recip_g8[13];
   assign ex3_recip_c[12] = ex3_recip_g8[12];
   assign ex3_recip_c[11] = ex3_recip_g8[11];
   assign ex3_recip_c[10] = ex3_recip_g8[10];
   assign ex3_recip_c[9] = ex3_recip_g8[9];
   assign ex3_recip_c[8] = ex3_recip_g8[8];
   assign ex3_recip_c[7] = ex3_recip_g8[7];
   assign ex3_recip_c[6] = ex3_recip_g8[6];
   assign ex3_recip_c[5] = ex3_recip_g8[5] | (ex3_recip_t8[5] & ex3_recip_g8[13]);
   assign ex3_recip_c[4] = ex3_recip_g8[4] | (ex3_recip_t8[4] & ex3_recip_g8[12]);
   assign ex3_recip_c[3] = ex3_recip_g8[3] | (ex3_recip_t8[3] & ex3_recip_g8[11]);
   assign ex3_recip_c[2] = ex3_recip_g8[2] | (ex3_recip_t8[2] & ex3_recip_g8[10]);
   
   assign ex3_recip_expo[1:12] = ex3_recip_p[1:12] ^ ex3_recip_c[2:13];
   assign ex3_recip_expo[13] = ex3_recip_p[13];
   
   
   assign ex3_rsqrt_k[1:13] = {tidn, tidn, tiup, tidn, {8{tiup}}, ex3_b_expo_adj_b[13]};
   assign ex3_rsqrt_bsh_b[1:13] = {ex3_b_expo_adj_b[1], ex3_b_expo_adj_b[1:12]};		
   
   assign ex3_rsqrt_p[1:13] = ex3_rsqrt_k[1:13] ^ ex3_rsqrt_bsh_b[1:13];
   assign ex3_rsqrt_g[2:13] = ex3_rsqrt_k[2:13] & ex3_rsqrt_bsh_b[2:13];
   assign ex3_rsqrt_t[2:12] = ex3_rsqrt_k[2:12] | ex3_rsqrt_bsh_b[2:12];
   
   assign ex3_rsqrt_g2[13] = ex3_rsqrt_g[13];
   assign ex3_rsqrt_g2[12] = ex3_rsqrt_g[12] | (ex3_rsqrt_t[12] & ex3_rsqrt_g[13]);
   assign ex3_rsqrt_g2[11] = ex3_rsqrt_g[11] | (ex3_rsqrt_t[11] & ex3_rsqrt_g[12]);
   assign ex3_rsqrt_g2[10] = ex3_rsqrt_g[10] | (ex3_rsqrt_t[10] & ex3_rsqrt_g[11]);
   assign ex3_rsqrt_g2[9] = ex3_rsqrt_g[9] | (ex3_rsqrt_t[9] & ex3_rsqrt_g[10]);
   assign ex3_rsqrt_g2[8] = ex3_rsqrt_g[8] | (ex3_rsqrt_t[8] & ex3_rsqrt_g[9]);
   assign ex3_rsqrt_g2[7] = ex3_rsqrt_g[7] | (ex3_rsqrt_t[7] & ex3_rsqrt_g[8]);
   assign ex3_rsqrt_g2[6] = ex3_rsqrt_g[6] | (ex3_rsqrt_t[6] & ex3_rsqrt_g[7]);
   assign ex3_rsqrt_g2[5] = ex3_rsqrt_g[5] | (ex3_rsqrt_t[5] & ex3_rsqrt_g[6]);
   assign ex3_rsqrt_g2[4] = ex3_rsqrt_g[4] | (ex3_rsqrt_t[4] & ex3_rsqrt_g[5]);
   assign ex3_rsqrt_g2[3] = ex3_rsqrt_g[3] | (ex3_rsqrt_t[3] & ex3_rsqrt_g[4]);
   assign ex3_rsqrt_g2[2] = ex3_rsqrt_g[2] | (ex3_rsqrt_t[2] & ex3_rsqrt_g[3]);
   
   assign ex3_rsqrt_t2[11] = (ex3_rsqrt_t[11] & ex3_rsqrt_t[12]);
   assign ex3_rsqrt_t2[10] = (ex3_rsqrt_t[10] & ex3_rsqrt_t[11]);
   assign ex3_rsqrt_t2[9] = (ex3_rsqrt_t[9] & ex3_rsqrt_t[10]);
   assign ex3_rsqrt_t2[8] = (ex3_rsqrt_t[8] & ex3_rsqrt_t[9]);
   assign ex3_rsqrt_t2[7] = (ex3_rsqrt_t[7] & ex3_rsqrt_t[8]);
   assign ex3_rsqrt_t2[6] = (ex3_rsqrt_t[6] & ex3_rsqrt_t[7]);
   assign ex3_rsqrt_t2[5] = (ex3_rsqrt_t[5] & ex3_rsqrt_t[6]);
   assign ex3_rsqrt_t2[4] = (ex3_rsqrt_t[4] & ex3_rsqrt_t[5]);
   assign ex3_rsqrt_t2[3] = (ex3_rsqrt_t[3] & ex3_rsqrt_t[4]);
   assign ex3_rsqrt_t2[2] = (ex3_rsqrt_t[2] & ex3_rsqrt_t[3]);
   
   assign ex3_rsqrt_g4[13] = ex3_rsqrt_g2[13];
   assign ex3_rsqrt_g4[12] = ex3_rsqrt_g2[12];
   assign ex3_rsqrt_g4[11] = ex3_rsqrt_g2[11] | (ex3_rsqrt_t2[11] & ex3_rsqrt_g2[13]);
   assign ex3_rsqrt_g4[10] = ex3_rsqrt_g2[10] | (ex3_rsqrt_t2[10] & ex3_rsqrt_g2[12]);
   assign ex3_rsqrt_g4[9] = ex3_rsqrt_g2[9] | (ex3_rsqrt_t2[9] & ex3_rsqrt_g2[11]);
   assign ex3_rsqrt_g4[8] = ex3_rsqrt_g2[8] | (ex3_rsqrt_t2[8] & ex3_rsqrt_g2[10]);
   assign ex3_rsqrt_g4[7] = ex3_rsqrt_g2[7] | (ex3_rsqrt_t2[7] & ex3_rsqrt_g2[9]);
   assign ex3_rsqrt_g4[6] = ex3_rsqrt_g2[6] | (ex3_rsqrt_t2[6] & ex3_rsqrt_g2[8]);
   assign ex3_rsqrt_g4[5] = ex3_rsqrt_g2[5] | (ex3_rsqrt_t2[5] & ex3_rsqrt_g2[7]);
   assign ex3_rsqrt_g4[4] = ex3_rsqrt_g2[4] | (ex3_rsqrt_t2[4] & ex3_rsqrt_g2[6]);
   assign ex3_rsqrt_g4[3] = ex3_rsqrt_g2[3] | (ex3_rsqrt_t2[3] & ex3_rsqrt_g2[5]);
   assign ex3_rsqrt_g4[2] = ex3_rsqrt_g2[2] | (ex3_rsqrt_t2[2] & ex3_rsqrt_g2[4]);
   
   assign ex3_rsqrt_t4[9] = (ex3_rsqrt_t2[9] & ex3_rsqrt_t2[11]);
   assign ex3_rsqrt_t4[8] = (ex3_rsqrt_t2[8] & ex3_rsqrt_t2[10]);
   assign ex3_rsqrt_t4[7] = (ex3_rsqrt_t2[7] & ex3_rsqrt_t2[9]);
   assign ex3_rsqrt_t4[6] = (ex3_rsqrt_t2[6] & ex3_rsqrt_t2[8]);
   assign ex3_rsqrt_t4[5] = (ex3_rsqrt_t2[5] & ex3_rsqrt_t2[7]);
   assign ex3_rsqrt_t4[4] = (ex3_rsqrt_t2[4] & ex3_rsqrt_t2[6]);
   assign ex3_rsqrt_t4[3] = (ex3_rsqrt_t2[3] & ex3_rsqrt_t2[5]);
   assign ex3_rsqrt_t4[2] = (ex3_rsqrt_t2[2] & ex3_rsqrt_t2[4]);
   
   assign ex3_rsqrt_g8[13] = ex3_rsqrt_g4[13];
   assign ex3_rsqrt_g8[12] = ex3_rsqrt_g4[12];
   assign ex3_rsqrt_g8[11] = ex3_rsqrt_g4[11];
   assign ex3_rsqrt_g8[10] = ex3_rsqrt_g4[10];
   assign ex3_rsqrt_g8[9] = ex3_rsqrt_g4[9] | (ex3_rsqrt_t4[9] & ex3_rsqrt_g4[13]);
   assign ex3_rsqrt_g8[8] = ex3_rsqrt_g4[8] | (ex3_rsqrt_t4[8] & ex3_rsqrt_g4[12]);
   assign ex3_rsqrt_g8[7] = ex3_rsqrt_g4[7] | (ex3_rsqrt_t4[7] & ex3_rsqrt_g4[11]);
   assign ex3_rsqrt_g8[6] = ex3_rsqrt_g4[6] | (ex3_rsqrt_t4[6] & ex3_rsqrt_g4[10]);
   assign ex3_rsqrt_g8[5] = ex3_rsqrt_g4[5] | (ex3_rsqrt_t4[5] & ex3_rsqrt_g4[9]);
   assign ex3_rsqrt_g8[4] = ex3_rsqrt_g4[4] | (ex3_rsqrt_t4[4] & ex3_rsqrt_g4[8]);
   assign ex3_rsqrt_g8[3] = ex3_rsqrt_g4[3] | (ex3_rsqrt_t4[3] & ex3_rsqrt_g4[7]);
   assign ex3_rsqrt_g8[2] = ex3_rsqrt_g4[2] | (ex3_rsqrt_t4[2] & ex3_rsqrt_g4[6]);
   
   assign ex3_rsqrt_t8[5] = (ex3_rsqrt_t4[5] & ex3_rsqrt_t4[9]);
   assign ex3_rsqrt_t8[4] = (ex3_rsqrt_t4[4] & ex3_rsqrt_t4[8]);
   assign ex3_rsqrt_t8[3] = (ex3_rsqrt_t4[3] & ex3_rsqrt_t4[7]);
   assign ex3_rsqrt_t8[2] = (ex3_rsqrt_t4[2] & ex3_rsqrt_t4[6]);
   
   assign ex3_rsqrt_c[13] = ex3_rsqrt_g8[13];
   assign ex3_rsqrt_c[12] = ex3_rsqrt_g8[12];
   assign ex3_rsqrt_c[11] = ex3_rsqrt_g8[11];
   assign ex3_rsqrt_c[10] = ex3_rsqrt_g8[10];
   assign ex3_rsqrt_c[9] = ex3_rsqrt_g8[9];
   assign ex3_rsqrt_c[8] = ex3_rsqrt_g8[8];
   assign ex3_rsqrt_c[7] = ex3_rsqrt_g8[7];
   assign ex3_rsqrt_c[6] = ex3_rsqrt_g8[6];
   assign ex3_rsqrt_c[5] = ex3_rsqrt_g8[5] | (ex3_rsqrt_t8[5] & ex3_rsqrt_g8[13]);
   assign ex3_rsqrt_c[4] = ex3_rsqrt_g8[4] | (ex3_rsqrt_t8[4] & ex3_rsqrt_g8[12]);
   assign ex3_rsqrt_c[3] = ex3_rsqrt_g8[3] | (ex3_rsqrt_t8[3] & ex3_rsqrt_g8[11]);
   assign ex3_rsqrt_c[2] = ex3_rsqrt_g8[2] | (ex3_rsqrt_t8[2] & ex3_rsqrt_g8[10]);
   
   assign ex3_rsqrt_expo[1:12] = ex3_rsqrt_p[1:12] ^ ex3_rsqrt_c[2:13];
   assign ex3_rsqrt_expo[13] = ex3_rsqrt_p[13];
   
   
   assign ex3_res_expo[1:13] = ({13{f_pic_ex3_est_rsqrt}} & ex3_rsqrt_expo[1:13]) | 
                               ({13{f_pic_ex3_est_recip}} & ex3_recip_expo[1:13]);
   
   
   
   assign ex3_mid_match_ifsp = (~f_eie_ex3_tbl_expo[4]) & (~f_eie_ex3_tbl_expo[5]) & (~f_eie_ex3_tbl_expo[6]);		
   
   assign ex3_mid_match_ifdp = f_eie_ex3_tbl_expo[4] & f_eie_ex3_tbl_expo[5] & f_eie_ex3_tbl_expo[6];		
   
   assign ex3_com_match = (~f_eie_ex3_tbl_expo[1]) & (~f_eie_ex3_tbl_expo[2]) & f_eie_ex3_tbl_expo[3] & f_eie_ex3_tbl_expo[7] & f_eie_ex3_tbl_expo[8] & f_eie_ex3_tbl_expo[9] & f_eie_ex3_tbl_expo[10] & f_eie_ex3_tbl_expo[11];		
   
   assign ex3_match_en_dp = ex3_com_match & f_pic_ex3_sp_b & ex3_mid_match_ifdp;
   assign ex3_match_en_sp = ex3_com_match & (~f_pic_ex3_sp_b) & ex3_mid_match_ifsp;
   
   assign ex3_recip_2046 = f_pic_ex3_est_recip & f_eie_ex3_tbl_expo[12] & (~f_eie_ex3_tbl_expo[13]);		
   
   assign ex3_recip_2045 = f_pic_ex3_est_recip & (~f_eie_ex3_tbl_expo[12]) & f_eie_ex3_tbl_expo[13];		
   
   assign ex3_recip_2044 = f_pic_ex3_est_recip & (~f_eie_ex3_tbl_expo[12]) & (~f_eie_ex3_tbl_expo[13]);		
   
   assign ex3_recip_ue1 = f_pic_ex3_est_recip & f_pic_ex3_ue1;
   
   
   assign ex3_lu_sh = (f_fmt_ex3_lu_den_recip & f_pic_ex3_est_recip) | (f_fmt_ex3_lu_den_rsqrto & f_pic_ex3_est_rsqrt & (~f_eie_ex3_tbl_expo[13]));
   
   
   tri_rlmreg_p #(.WIDTH(20)) ex4_expo_lat(
      .force_t(force_t),		
      .d_mode(tiup), 
      .delay_lclkr(delay_lclkr[3]),		
      .mpw1_b(mpw1_b[3]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex3_act),
      .scout(ex4_expo_so),
      .scin(ex4_expo_si),
      
      .din({   ex3_res_expo[1:13],
               ex3_match_en_dp,
               ex3_match_en_sp,
               ex3_recip_2046,
               ex3_recip_2045,
               ex3_recip_2044,
               ex3_lu_sh,
               ex3_recip_ue1}),
      .dout({  ex4_res_expo[1:13],		
               ex4_match_en_dp,		
               ex4_match_en_sp,		
               ex4_recip_2046,		
               ex4_recip_2045,		
               ex4_recip_2044,		
               ex4_lu_sh,		
               ex4_recip_ue1})		
   );
   
   
   assign f_tbe_ex4_match_en_sp = ex4_match_en_sp;		
   assign f_tbe_ex4_match_en_dp = ex4_match_en_dp;		
   assign f_tbe_ex4_recip_2046 = ex4_recip_2046;		
   assign f_tbe_ex4_recip_2045 = ex4_recip_2045;		
   assign f_tbe_ex4_recip_2044 = ex4_recip_2044;		
   assign f_tbe_ex4_lu_sh = ex4_lu_sh;		
   assign f_tbe_ex4_recip_ue1 = ex4_recip_ue1;		
   
   assign ex4_recip_2046_dp = ex4_recip_2046 & ex4_match_en_dp & (~ex4_recip_ue1);		
   assign ex4_recip_2045_dp = ex4_recip_2045 & ex4_match_en_dp & (~ex4_recip_ue1);		
   assign ex4_recip_2044_dp = ex4_recip_2044 & ex4_match_en_dp & (~ex4_recip_ue1);		
   assign ex4_force_expo_den = ex4_recip_2046_dp | ex4_recip_2045_dp;		
   
   assign ex4_decr_expo = (ex4_lu_sh & ex4_recip_ue1) | (ex4_lu_sh & (~ex4_recip_ue1) & (~ex4_recip_2046_dp) & (~ex4_recip_2045_dp) & (~ex4_recip_2044_dp));		
   
   
   assign ex4_res_expo_b[1:13] = (~ex4_res_expo[1:13]);
   
   assign ex4_res_expo_g2_b[13] = (~(ex4_res_expo[13]));
   assign ex4_res_expo_g2_b[12] = (~(ex4_res_expo[12] | ex4_res_expo[13]));
   assign ex4_res_expo_g2_b[11] = (~(ex4_res_expo[11] | ex4_res_expo[12]));
   assign ex4_res_expo_g2_b[10] = (~(ex4_res_expo[10] | ex4_res_expo[11]));
   assign ex4_res_expo_g2_b[9] = (~(ex4_res_expo[9] | ex4_res_expo[10]));
   assign ex4_res_expo_g2_b[8] = (~(ex4_res_expo[8] | ex4_res_expo[9]));
   assign ex4_res_expo_g2_b[7] = (~(ex4_res_expo[7] | ex4_res_expo[8]));
   assign ex4_res_expo_g2_b[6] = (~(ex4_res_expo[6] | ex4_res_expo[7]));
   assign ex4_res_expo_g2_b[5] = (~(ex4_res_expo[5] | ex4_res_expo[6]));
   assign ex4_res_expo_g2_b[4] = (~(ex4_res_expo[4] | ex4_res_expo[5]));
   assign ex4_res_expo_g2_b[3] = (~(ex4_res_expo[3] | ex4_res_expo[4]));
   assign ex4_res_expo_g2_b[2] = (~(ex4_res_expo[2] | ex4_res_expo[3]));
   
   assign ex4_res_expo_g4[13] = (~(ex4_res_expo_g2_b[13]));
   assign ex4_res_expo_g4[12] = (~(ex4_res_expo_g2_b[12]));
   assign ex4_res_expo_g4[11] = (~(ex4_res_expo_g2_b[11] & ex4_res_expo_g2_b[13]));
   assign ex4_res_expo_g4[10] = (~(ex4_res_expo_g2_b[10] & ex4_res_expo_g2_b[12]));
   assign ex4_res_expo_g4[9] = (~(ex4_res_expo_g2_b[9] & ex4_res_expo_g2_b[11]));
   assign ex4_res_expo_g4[8] = (~(ex4_res_expo_g2_b[8] & ex4_res_expo_g2_b[10]));
   assign ex4_res_expo_g4[7] = (~(ex4_res_expo_g2_b[7] & ex4_res_expo_g2_b[9]));
   assign ex4_res_expo_g4[6] = (~(ex4_res_expo_g2_b[6] & ex4_res_expo_g2_b[8]));
   assign ex4_res_expo_g4[5] = (~(ex4_res_expo_g2_b[5] & ex4_res_expo_g2_b[7]));
   assign ex4_res_expo_g4[4] = (~(ex4_res_expo_g2_b[4] & ex4_res_expo_g2_b[6]));
   assign ex4_res_expo_g4[3] = (~(ex4_res_expo_g2_b[3] & ex4_res_expo_g2_b[5]));
   assign ex4_res_expo_g4[2] = (~(ex4_res_expo_g2_b[2] & ex4_res_expo_g2_b[4]));
   
   assign ex4_res_expo_g8_b[13] = (~(ex4_res_expo_g4[13]));
   assign ex4_res_expo_g8_b[12] = (~(ex4_res_expo_g4[12]));
   assign ex4_res_expo_g8_b[11] = (~(ex4_res_expo_g4[11]));
   assign ex4_res_expo_g8_b[10] = (~(ex4_res_expo_g4[10]));
   assign ex4_res_expo_g8_b[9] = (~(ex4_res_expo_g4[9] | ex4_res_expo_g4[13]));
   assign ex4_res_expo_g8_b[8] = (~(ex4_res_expo_g4[8] | ex4_res_expo_g4[12]));
   assign ex4_res_expo_g8_b[7] = (~(ex4_res_expo_g4[7] | ex4_res_expo_g4[11]));
   assign ex4_res_expo_g8_b[6] = (~(ex4_res_expo_g4[6] | ex4_res_expo_g4[10]));
   assign ex4_res_expo_g8_b[5] = (~(ex4_res_expo_g4[5] | ex4_res_expo_g4[9]));
   assign ex4_res_expo_g8_b[4] = (~(ex4_res_expo_g4[4] | ex4_res_expo_g4[8]));
   assign ex4_res_expo_g8_b[3] = (~(ex4_res_expo_g4[3] | ex4_res_expo_g4[7]));
   assign ex4_res_expo_g8_b[2] = (~(ex4_res_expo_g4[2] | ex4_res_expo_g4[6]));
   
   assign ex4_res_expo_c[13] = (~(ex4_res_expo_g8_b[13]));
   assign ex4_res_expo_c[12] = (~(ex4_res_expo_g8_b[12]));
   assign ex4_res_expo_c[11] = (~(ex4_res_expo_g8_b[11]));
   assign ex4_res_expo_c[10] = (~(ex4_res_expo_g8_b[10]));
   assign ex4_res_expo_c[9] = (~(ex4_res_expo_g8_b[9]));
   assign ex4_res_expo_c[8] = (~(ex4_res_expo_g8_b[8]));
   assign ex4_res_expo_c[7] = (~(ex4_res_expo_g8_b[7]));
   assign ex4_res_expo_c[6] = (~(ex4_res_expo_g8_b[6]));
   assign ex4_res_expo_c[5] = (~(ex4_res_expo_g8_b[5] & ex4_res_expo_g8_b[13]));
   assign ex4_res_expo_c[4] = (~(ex4_res_expo_g8_b[4] & ex4_res_expo_g8_b[12]));
   assign ex4_res_expo_c[3] = (~(ex4_res_expo_g8_b[3] & ex4_res_expo_g8_b[11]));
   assign ex4_res_expo_c[2] = (~(ex4_res_expo_g8_b[2] & ex4_res_expo_g8_b[10]));
   
   assign ex4_res_decr[1:12] = ex4_res_expo_b[1:12] ^ ex4_res_expo_c[2:13];
   assign ex4_res_decr[13] = ex4_res_expo_b[13];
   
   assign f_tbe_ex4_res_expo[1] = (ex4_res_expo[1] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[1] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[2] = (ex4_res_expo[2] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[2] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[3] = (ex4_res_expo[3] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[3] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[4] = (ex4_res_expo[4] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[4] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[5] = (ex4_res_expo[5] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[5] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[6] = (ex4_res_expo[6] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[6] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[7] = (ex4_res_expo[7] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[7] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[8] = (ex4_res_expo[8] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[8] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[9] = (ex4_res_expo[9] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[9] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[10] = (ex4_res_expo[10] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[10] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[11] = (ex4_res_expo[11] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[11] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[12] = (ex4_res_expo[12] & (~ex4_decr_expo) & (~ex4_force_expo_den)) | (ex4_res_decr[12] & ex4_decr_expo);		
   assign f_tbe_ex4_res_expo[13] = (ex4_res_expo[13] & (~ex4_decr_expo)) | (ex4_res_decr[13] & ex4_decr_expo) | (ex4_force_expo_den);		
   
   assign f_tbe_ex4_may_ov = ((~ex4_res_expo[1]) & ex4_res_expo[2]) | ((~ex4_res_expo[1]) & ex4_res_expo[3] & ex4_res_expo[4]) | ((~ex4_res_expo[1]) & ex4_res_expo[3] & ex4_res_expo[5]) | ((~ex4_res_expo[1]) & ex4_res_expo[3] & ex4_res_expo[6]) | ((~ex4_res_expo[1]) & ex4_res_expo[3] & ex4_res_expo[7]) | ((~ex4_res_expo[1]) & ex4_res_expo[3] & ex4_res_expo[8] & ex4_res_expo[9]);		
   
   
   assign ex4_expo_si[0:19] = {ex4_expo_so[1:19], si};
   assign act_si[0:4] = {act_so[1:4], ex4_expo_so[0]};
   assign so = act_so[0];
   
endmodule
