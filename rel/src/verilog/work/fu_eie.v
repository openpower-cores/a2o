// © IBM Corp. 2020
// This softcore is licensed under and subject to the terms of the CC-BY 4.0
// license (https://creativecommons.org/licenses/by/4.0/legalcode). 
// Additional rights, including the right to physically implement a softcore 
// that is compliant with the required sections of the Power ISA 
// Specification, will be available at no cost via the OpenPOWER Foundation. 
// This README will be updated with additional information when OpenPOWER's 
// license is available.

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
   input         clkoff_b;		
   input         act_dis;		
   input         flush;		
   input [2:3]   delay_lclkr;		
   input [2:3]   mpw1_b;		
   input [0:0]   mpw2_b;		
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		
   input  [0:`NCLK_WIDTH-1]         nclk;
   
   input         f_eie_si;		
   output        f_eie_so;		
   input         ex2_act;		
   
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
   
   output        f_eie_ex3_lt_bias;		
   output        f_eie_ex3_eq_bias_m1;		
   output        f_eie_ex3_wd_ov;		
   output        f_eie_ex3_dw_ov;		
   output        f_eie_ex3_wd_ov_if;		
   output        f_eie_ex3_dw_ov_if;		
   output [1:13] f_eie_ex3_lzo_expo;		
   output [1:13] f_eie_ex3_b_expo;		
   output        f_eie_ex3_use_bexp;
   output [1:13] f_eie_ex4_iexp;		
   
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire          sg_0;		
   wire          thold_0_b;		
   wire          thold_0;
   wire          force_t;
   

   wire          ex3_act;		
   wire [0:3]    act_spare_unused;		
   wire [0:4]    act_so;		
   wire [0:4]    act_si;		
   wire [0:12]   ex3_bop_so;		
   wire [0:12]   ex3_bop_si;		
   wire [0:12]   ex3_pop_so;		
   wire [0:12]   ex3_pop_si;		
   wire [0:6]    ex3_ctl_so;		
   wire [0:6]    ex3_ctl_si;		
   wire [0:13]   ex4_iexp_so;		
   wire [0:13]   ex4_iexp_si;		
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
   
   wire [1:13]   ex3_b_expo_fixed;		
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
   
   
   
   
   tri_rlmreg_p #(.WIDTH(5),  .NEEDS_SRESET(0)) act_lat(
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
      .din({ act_spare_unused[0],
             act_spare_unused[1],
             ex2_act,
             act_spare_unused[2],
             act_spare_unused[3]}),
      .dout({  act_spare_unused[0],
               act_spare_unused[1],
               ex3_act,
               act_spare_unused[2],
               act_spare_unused[3]})
   );
   
   
   assign ex2_a_expo[1:13] = f_byp_eie_ex2_a_expo[1:13];
   assign ex2_c_expo[1:13] = f_byp_eie_ex2_c_expo[1:13];
   assign ex2_b_expo[1:13] = f_byp_eie_ex2_b_expo[1:13];
   
   
   
   assign ex2_ep56_sum[1] = (~(ex2_a_expo[1] ^ ex2_c_expo[1]));		
   assign ex2_ep56_sum[2] = (~(ex2_a_expo[2] ^ ex2_c_expo[2]));		
   assign ex2_ep56_sum[3] = (~(ex2_a_expo[3] ^ ex2_c_expo[3]));		
   assign ex2_ep56_sum[4] = (ex2_a_expo[4] ^ ex2_c_expo[4]);		
   assign ex2_ep56_sum[5] = (ex2_a_expo[5] ^ ex2_c_expo[5]);		
   assign ex2_ep56_sum[6] = (ex2_a_expo[6] ^ ex2_c_expo[6]);		
   assign ex2_ep56_sum[7] = (ex2_a_expo[7] ^ ex2_c_expo[7]);		
   assign ex2_ep56_sum[8] = (~(ex2_a_expo[8] ^ ex2_c_expo[8]));		
   assign ex2_ep56_sum[9] = (~(ex2_a_expo[9] ^ ex2_c_expo[9]));		
   assign ex2_ep56_sum[10] = (~(ex2_a_expo[10] ^ ex2_c_expo[10]));		
   assign ex2_ep56_sum[11] = (ex2_a_expo[11] ^ ex2_c_expo[11]);		
   assign ex2_ep56_sum[12] = (ex2_a_expo[12] ^ ex2_c_expo[12]);		
   assign ex2_ep56_sum[13] = (~(ex2_a_expo[13] ^ ex2_c_expo[13]));		
   
   assign ex2_ep56_car[1] = (ex2_a_expo[2] | ex2_c_expo[2]);		
   assign ex2_ep56_car[2] = (ex2_a_expo[3] | ex2_c_expo[3]);		
   assign ex2_ep56_car[3] = (ex2_a_expo[4] & ex2_c_expo[4]);		
   assign ex2_ep56_car[4] = (ex2_a_expo[5] & ex2_c_expo[5]);		
   assign ex2_ep56_car[5] = (ex2_a_expo[6] & ex2_c_expo[6]);		
   assign ex2_ep56_car[6] = (ex2_a_expo[7] & ex2_c_expo[7]);		
   assign ex2_ep56_car[7] = (ex2_a_expo[8] | ex2_c_expo[8]);		
   assign ex2_ep56_car[8] = (ex2_a_expo[9] | ex2_c_expo[9]);		
   assign ex2_ep56_car[9] = (ex2_a_expo[10] | ex2_c_expo[10]);		
   assign ex2_ep56_car[10] = (ex2_a_expo[11] & ex2_c_expo[11]);		
   assign ex2_ep56_car[11] = (ex2_a_expo[12] & ex2_c_expo[12]);		
   assign ex2_ep56_car[12] = (ex2_a_expo[13] | ex2_c_expo[13]);		
   
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
   
   assign ex2_ep56_t2[10] = (ex2_ep56_t[10] & ex2_ep56_t[11]);
   assign ex2_ep56_t2[9] = (ex2_ep56_t[9] & ex2_ep56_t[10]);
   assign ex2_ep56_t2[8] = (ex2_ep56_t[8] & ex2_ep56_t[9]);
   assign ex2_ep56_t2[7] = (ex2_ep56_t[7] & ex2_ep56_t[8]);
   assign ex2_ep56_t2[6] = (ex2_ep56_t[6] & ex2_ep56_t[7]);
   assign ex2_ep56_t2[5] = (ex2_ep56_t[5] & ex2_ep56_t[6]);
   assign ex2_ep56_t2[4] = (ex2_ep56_t[4] & ex2_ep56_t[5]);
   assign ex2_ep56_t2[3] = (ex2_ep56_t[3] & ex2_ep56_t[4]);
   assign ex2_ep56_t2[2] = (ex2_ep56_t[2] & ex2_ep56_t[3]);
   
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
   
   assign ex2_ep56_t4[8] = (ex2_ep56_t2[8] & ex2_ep56_t2[10]);
   assign ex2_ep56_t4[7] = (ex2_ep56_t2[7] & ex2_ep56_t2[9]);
   assign ex2_ep56_t4[6] = (ex2_ep56_t2[6] & ex2_ep56_t2[8]);
   assign ex2_ep56_t4[5] = (ex2_ep56_t2[5] & ex2_ep56_t2[7]);
   assign ex2_ep56_t4[4] = (ex2_ep56_t2[4] & ex2_ep56_t2[6]);
   assign ex2_ep56_t4[3] = (ex2_ep56_t2[3] & ex2_ep56_t2[5]);
   assign ex2_ep56_t4[2] = (ex2_ep56_t2[2] & ex2_ep56_t2[4]);
   
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
   
   assign ex2_ep56_t8[4] = (ex2_ep56_t4[4] & ex2_ep56_t4[8]);
   assign ex2_ep56_t8[3] = (ex2_ep56_t4[3] & ex2_ep56_t4[7]);
   assign ex2_ep56_t8[2] = (ex2_ep56_t4[2] & ex2_ep56_t4[6]);
   
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
   
   
   assign ex2_p_expo_adj[1:13] = (ex2_ep56_s[1:13] & {13{(~f_pic_ex2_fsel)}}) | 
                                 (ex2_c_expo[1:13] & {13{f_pic_ex2_fsel}});
   
   
   
   assign ex2_from_k[1] = tidn;		
   assign ex2_from_k[2] = tidn;		
   assign ex2_from_k[3] = tiup;		
   assign ex2_from_k[4] = tidn;		
   assign ex2_from_k[5] = tidn;		
   assign ex2_from_k[6] = tiup;		
   assign ex2_from_k[7] = tidn;		
   assign ex2_from_k[8] = tiup;		
   assign ex2_from_k[9] = tidn;		
   assign ex2_from_k[10] = tidn;		
   assign ex2_from_k[11] = tidn;		
   assign ex2_from_k[12] = tidn;		
   assign ex2_from_k[13] = tiup;		
   
   assign ex2_b_expo_adj[1:13] = (ex2_from_k[1:13] & {13{f_pic_ex2_from_integer}}) | 
                                 (ex2_b_expo[1:13] & {13{(~f_pic_ex2_from_integer)}});
   
   
   
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
   
   assign ex2_ge_bias = ((~ex2_b_expo[1]) & ex2_b_expo[2]) | ((~ex2_b_expo[1]) & ex2_b_expo[3]) | ((~ex2_b_expo[1]) & ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6] & ex2_b_expo[7] & ex2_b_expo[8] & ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & ex2_b_expo[13]);		
   
   assign ex2_lt_bias = (~ex2_ge_bias);
   assign ex2_eq_bias_m1 = (~ex2_b_expo[1]) & (~ex2_b_expo[2]) & (~ex2_b_expo[3]) & ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6] & ex2_b_expo[7] & ex2_b_expo[8] & ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11] & ex2_b_expo[12] & (~ex2_b_expo[13]);		
   
   
   
   tri_rlmreg_p #(.WIDTH(13),  .NEEDS_SRESET(0)) ex3_bop_lat(
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
      .act(ex2_act),
      .scout(ex3_bop_so),
      .scin(ex3_bop_si),
      .din(ex2_b_expo_adj[1:13]),
      .dout(ex3_b_expo_adj[1:13])		
   );
   
   
   tri_rlmreg_p #(.WIDTH(13),  .NEEDS_SRESET(0)) ex3_pop_lat(
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
      .act(ex2_act),
      .scout(ex3_pop_so),
      .scin(ex3_pop_si),
      .din(ex2_p_expo_adj[1:13]),
      .dout(ex3_p_expo_adj[1:13])		
   );
   
   
   tri_rlmreg_p #(.WIDTH(7),  .NEEDS_SRESET(0)) ex3_ctl_lat(
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
      .act(ex2_act),
      .scout(ex3_ctl_so),
      .scin(ex3_ctl_si),
      .din({ ex2_dw_ge,
             ex2_wd_ge,
             ex2_wd_eq,
             ex2_dw_eq,
             f_pic_ex2_fsel,
             ex2_lt_bias,
             ex2_eq_bias_m1}),
      .dout({ex3_dw_ge,		
             ex3_wd_ge,		
             ex3_wd_eq,		
             ex3_dw_eq,		
             ex3_fsel,		
             ex3_lt_bias,		
             ex3_eq_bias_m1})		
   );
   
   assign f_eie_ex3_lt_bias = ex3_lt_bias;		
   assign f_eie_ex3_eq_bias_m1 = ex3_eq_bias_m1;		
   
   assign ex3_p_expo[1:13] = ex3_p_expo_adj[1:13];
   assign ex3_b_expo[1:13] = ex3_b_expo_adj[1:13];
   
   assign f_eie_ex3_wd_ov = ex3_wd_ge;		
   assign f_eie_ex3_dw_ov = ex3_dw_ge;		
   assign f_eie_ex3_wd_ov_if = ex3_wd_eq;		
   assign f_eie_ex3_dw_ov_if = ex3_dw_eq;		
   
   assign f_eie_ex3_lzo_expo[1:13] = ex3_p_expo_adj[1:13];		
   assign f_eie_ex3_b_expo[1:13] = ex3_b_expo[1:13];
   assign f_eie_ex3_tbl_expo[1:13] = ex3_b_expo[1:13];
   
   
   assign ex3_b_expo_fixed[1:13] = ex3_b_expo[1:13];
   
   assign f_eie_ex3_use_bexp = ex3_iexp_b_sel;
   
   assign ex3_iexp_b_sel = (f_alg_ex3_sel_byp & (~ex3_fsel) & f_pic_ex3_math_bzer_b) | f_fmt_ex3_fsel_bsel | f_pic_ex3_force_sel_bexp | f_pic_ex3_frsp_ue1;		
   
   assign ex3_iexp[1:13] = (ex3_b_expo_fixed[1:13] & {13{ex3_iexp_b_sel}}) | 
                           (ex3_p_expo[1:13] & {13{(~ex3_iexp_b_sel)}});		
   
   
   
   tri_rlmreg_p #(.WIDTH(14),  .NEEDS_SRESET(0)) ex4_iexp_lat(
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
      .scout(ex4_iexp_so),
      .scin(ex4_iexp_si),
      .din({f_pic_ex3_sp_b,
            ex3_iexp[1:13]}),
      .dout({ex4_sp_b,		
             ex4_iexp[1:13]})		
   );
   
   assign f_eie_ex4_iexp[1:13] = ex4_iexp[1:13];		
   
   
   
   assign ex3_bop_si[0:12] = {ex3_bop_so[1:12], f_eie_si};
   assign ex3_pop_si[0:12] = {ex3_pop_so[1:12], ex3_bop_so[0]};
   assign ex3_ctl_si[0:6] = {ex3_ctl_so[1:6], ex3_pop_so[0]};
   assign ex4_iexp_si[0:13] = {ex4_iexp_so[1:13], ex3_ctl_so[0]};
   assign act_si[0:4] = {act_so[1:4], ex4_iexp_so[0]};
   assign f_eie_so = act_so[0];
   
endmodule
