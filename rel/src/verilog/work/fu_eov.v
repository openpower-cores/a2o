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

module fu_eov(
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
   f_eov_si,
   f_eov_so,
   ex3_act_b,
   f_tbl_ex5_unf_expo,
   f_tbe_ex4_may_ov,
   f_tbe_ex4_expo,
   f_pic_ex4_sel_est,
   f_eie_ex4_iexp,
   f_pic_ex4_sp_b,
   f_pic_ex5_oe,
   f_pic_ex5_ue,
   f_pic_ex5_ov_en,
   f_pic_ex5_uf_en,
   f_pic_ex5_spec_sel_k_e,
   f_pic_ex5_spec_sel_k_f,
   f_pic_ex5_sel_ov_spec,
   f_pic_ex5_to_int_ov_all,
   f_lza_ex5_sh_rgt_en_eov,
   f_lza_ex5_lza_amt_eov,
   f_lza_ex5_no_lza_edge,
   f_nrm_ex5_extra_shift,
   f_eov_ex5_may_ovf,
   f_eov_ex6_sel_k_f,
   f_eov_ex6_sel_k_e,
   f_eov_ex6_sel_kif_f,
   f_eov_ex6_sel_kif_e,
   f_eov_ex6_unf_expo,
   f_eov_ex6_ovf_expo,
   f_eov_ex6_ovf_if_expo,
   f_eov_ex6_expo_p0,
   f_eov_ex6_expo_p1,
   f_eov_ex6_expo_p0_ue1oe1,
   f_eov_ex6_expo_p1_ue1oe1
);
   parameter     expand_type = 2;		
   
   inout         vdd;
   inout         gnd;
   input         clkoff_b;		
   input         act_dis;		
   input         flush;		
   input [4:5]   delay_lclkr;		
   input [4:5]   mpw1_b;		
   input [0:1]   mpw2_b;		
   input         sg_1;
   input         thold_1;
   input         fpu_enable;		
   input [0:`NCLK_WIDTH-1]         nclk;
   
   input         f_eov_si;		
   output        f_eov_so;		
   input         ex3_act_b;		
   
   input         f_tbl_ex5_unf_expo;
   input         f_tbe_ex4_may_ov;
   input [1:13]  f_tbe_ex4_expo;
   input         f_pic_ex4_sel_est;
   input [1:13]  f_eie_ex4_iexp;
   
   input         f_pic_ex4_sp_b;
   input         f_pic_ex5_oe;
   input         f_pic_ex5_ue;
   input         f_pic_ex5_ov_en;
   input         f_pic_ex5_uf_en;
   input         f_pic_ex5_spec_sel_k_e;
   input         f_pic_ex5_spec_sel_k_f;
   input         f_pic_ex5_sel_ov_spec;
   input         f_pic_ex5_to_int_ov_all;
   
   input         f_lza_ex5_sh_rgt_en_eov;
   input [0:7]   f_lza_ex5_lza_amt_eov;
   input         f_lza_ex5_no_lza_edge;
   input         f_nrm_ex5_extra_shift;
   output        f_eov_ex5_may_ovf;		
   
   output        f_eov_ex6_sel_k_f;		
   output        f_eov_ex6_sel_k_e;		
   output        f_eov_ex6_sel_kif_f;		
   output        f_eov_ex6_sel_kif_e;		
   output        f_eov_ex6_unf_expo;		
   output        f_eov_ex6_ovf_expo;		
   output        f_eov_ex6_ovf_if_expo;		
   output [1:13] f_eov_ex6_expo_p0;		
   output [1:13] f_eov_ex6_expo_p1;		
   output [3:7]  f_eov_ex6_expo_p0_ue1oe1;		
   output [3:7]  f_eov_ex6_expo_p1_ue1oe1;		
   
   
   
   
   
   
   parameter     tiup = 1'b1;
   parameter     tidn = 1'b0;
   
   wire          sg_0;		
   wire          thold_0_b;		
   wire          thold_0;
   wire          force_t;
   wire          ex4_act;		
   wire          ex3_act;		
   wire          ex5_act;		
   
   (* analysis_not_referenced="TRUE" *) 
   wire [0:2]    act_spare_unused;		
   wire [0:4]    act_so;		
   wire [0:4]    act_si;		
   wire [0:15]   ex5_iexp_so;		
   wire [0:15]   ex5_iexp_si;		
   wire [0:2]    ex6_ovctl_so;		
   wire [0:2]    ex6_ovctl_si;		
   wire [0:12]   ex6_misc_so;		
   wire [0:12]   ex6_misc_si;		
   wire [0:12]   ex6_urnd0_so;		
   wire [0:12]   ex6_urnd0_si;		
   wire [0:12]   ex6_urnd1_so;		
   wire [0:12]   ex6_urnd1_si;		
   wire          ex5_sp;		
   wire          ex5_unf_m1_co12;		
   wire          ex5_unf_p0_co12;		
   wire          ex5_ovf_m1_co12;		
   wire          ex5_ovf_p0_co12;		
   wire          ex5_ovf_p1_co12;		
   wire          ex5_ovf_m1;		
   wire          ex5_ovf_p0;		
   wire          ex5_ovf_p1;		
   wire          ex5_unf_m1;		
   wire          ex5_unf_p0;		
   
   wire [1:13]   ex5_i_exp;
   wire [3:7]    ex5_ue1oe1_k;
   wire [1:13]   ex5_lzasub_sum;
   wire [1:12]   ex5_lzasub_car;
   wire [1:12]   ex5_lzasub_p;
   wire [2:12]   ex5_lzasub_t;
   wire [2:12]   ex5_lzasub_g;
   wire [1:13]   ex5_lzasub_m1;
   wire [1:13]   ex5_lzasub_p0;
   wire [1:13]   ex5_lzasub_p1;
   wire [2:11]   ex5_lzasub_c0;
   wire [2:11]   ex5_lzasub_c1;
   wire [1:11]   ex5_lzasub_s0;
   wire [1:11]   ex5_lzasub_s1;
   wire [1:13]   ex5_ovf_sum;
   wire [1:12]   ex5_ovf_car;
   wire [2:12]   ex5_ovf_g;
   wire [2:12]   ex5_ovf_t;
   wire [1:1]    ex5_ovf_p;
   wire [1:13]   ex5_unf_sum;
   wire [1:12]   ex5_unf_car;
   wire [2:12]   ex5_unf_g;
   wire [2:12]   ex5_unf_t;
   wire [1:1]    ex5_unf_p;
   wire          ex5_unf_ci0_02t11;
   wire          ex5_unf_ci1_02t11;
   wire [1:13]   ex5_expo_p0;
   wire [1:13]   ex5_expo_p1;
   wire [1:13]   ex6_expo_p0;
   wire [1:13]   ex6_expo_p1;
   wire [3:7]    ex6_ue1oe1_k;
   wire [3:7]    ex6_ue1oe1_p0_p;
   wire [4:6]    ex6_ue1oe1_p0_t;
   wire [4:7]    ex6_ue1oe1_p0_g;
   wire [4:7]    ex6_ue1oe1_p0_c;
   wire [3:7]    ex6_ue1oe1_p1_p;
   wire [4:6]    ex6_ue1oe1_p1_t;
   wire [4:7]    ex6_ue1oe1_p1_g;
   wire [4:7]    ex6_ue1oe1_p1_c;
   wire          ex5_lzasub_m1_c12;		
   wire          ex5_lzasub_p0_c12;		
   wire          ex5_lzasub_p1_c12;		
   wire          ex5_may_ovf;		
   wire [0:7]    ex5_lza_amt_b;
   wire [0:7]    ex5_lza_amt;
   wire [1:13]   ex4_iexp;		
   wire          ex4_sp;		
   wire          ex4_may_ovf;		
   wire          ex5_unf_c2_m1;
   wire          ex5_unf_c2_p0;
   wire          ex5_c2_m1;
   wire          ex5_c2_p0;
   wire          ex5_c2_p1;
   wire [4:7]    ex6_ue1oe1_p0_g2_b;
   wire [4:5]    ex6_ue1oe1_p0_t2_b;
   wire [4:7]    ex6_ue1oe1_p1_g2_b;
   wire [4:5]    ex6_ue1oe1_p1_t2_b;
   wire          ex5_unf_g2_02t03;
   wire          ex5_unf_g2_04t05;
   wire          ex5_unf_g2_06t07;
   wire          ex5_unf_g2_08t09;
   wire          ex5_unf_g2_10t11;
   wire          ex5_unf_ci0_g2;
   wire          ex5_unf_ci1_g2;
   wire          ex5_unf_t2_02t03;
   wire          ex5_unf_t2_04t05;
   wire          ex5_unf_t2_06t07;
   wire          ex5_unf_t2_08t09;
   wire          ex5_unf_t2_10t11;
   wire          ex5_unf_g4_02t05;
   wire          ex5_unf_g4_06t09;
   wire          ex5_unf_ci0_g4;
   wire          ex5_unf_ci1_g4;
   wire          ex5_unf_t4_02t05;
   wire          ex5_unf_t4_06t09;
   wire          ex5_unf_g8_02t09;
   wire          ex5_unf_ci0_g8;
   wire          ex5_unf_ci1_g8;
   wire          ex5_unf_t8_02t09;
   
   wire          ex5_ovf_ci0_02t11;
   wire          ex5_ovf_ci1_02t11;
   
   wire          ex5_ovf_g2_02t03;
   wire          ex5_ovf_g2_04t05;
   wire          ex5_ovf_g2_06t07;
   wire          ex5_ovf_g2_08t09;
   wire          ex5_ovf_g2_ci0;
   wire          ex5_ovf_g2_ci1;
   wire          ex5_ovf_t2_02t03;
   wire          ex5_ovf_t2_04t05;
   wire          ex5_ovf_t2_06t07;
   wire          ex5_ovf_t2_08t09;
   wire          ex5_ovf_g4_02t05;
   wire          ex5_ovf_g4_06t09;
   wire          ex5_ovf_g4_ci0;
   wire          ex5_ovf_g4_ci1;
   wire          ex5_ovf_t4_02t05;
   wire          ex5_ovf_t4_06t09;
   wire          ex5_ovf_g8_02t09;
   wire          ex5_ovf_g8_ci0;
   wire          ex5_ovf_g8_ci1;
   wire          ex5_ovf_t8_02t09;
   
   wire [2:11]   ex5_lzasub_gg02;
   wire [2:11]   ex5_lzasub_gt02;
   wire [2:11]   ex5_lzasub_gg04;
   wire [2:11]   ex5_lzasub_gt04;
   wire [2:11]   ex5_lzasub_gg08;
   wire [2:11]   ex5_lzasub_gt08;
   wire          ex5_sh_rgt_en_b;
   
   wire          ex4_may_ov_usual;
   
   wire          ex5_ovf_calc;
   wire          ex5_ovf_if_calc;
   wire          ex5_unf_calc;
   wire          ex5_unf_tbl;
   wire          ex5_unf_tbl_spec_e;
   wire          ex5_ov_en;
   wire          ex5_ov_en_oe0;
   wire          ex5_sel_ov_spec;
   wire          ex5_unf_en_nedge;
   wire          ex5_unf_ue0_nestsp;
   wire          ex5_sel_k_part_f;
   wire          ex5_sel_k_part_e;
   wire          ex6_ovf_calc;
   wire          ex6_ovf_if_calc;
   wire          ex6_unf_calc;
   wire          ex6_unf_tbl;
   wire          ex6_unf_tbl_b;
   wire          ex6_unf_tbl_spec_e;
   wire          ex6_ov_en;
   wire          ex6_ov_en_oe0;
   wire          ex6_sel_ov_spec;
   wire          ex6_unf_en_nedge;
   wire          ex6_unf_ue0_nestsp;
   wire          ex6_sel_k_part_f;
   wire          ex6_sel_ov_spec_b;
   wire          ex6_ovf_b;
   wire          ex6_ovf_if_b;
   wire          ex6_ovf_oe0_b;
   wire          ex6_ovf_if_oe0_b;
   wire          ex6_unf_b;
   wire          ex6_unf_ue0_b;
   wire          ex6_sel_k_part_f_b;
   wire          ex6_unf_tbl_spec_e_b;
   wire          ex5_sel_est;
   wire          ex5_est_sp;
   
   wire [1:13]   ex5_expo_p0_0_b;
   wire [1:13]   ex5_expo_p0_1_b;
   wire [1:13]   ex5_expo_p1_0_b;
   wire [1:13]   ex5_expo_p1_1_b;
   wire          ex5_ovf_calc_0_b;
   wire          ex5_ovf_calc_1_b;
   wire          ex5_ovf_if_calc_0_b;
   wire          ex5_ovf_if_calc_1_b;
   wire          ex5_unf_calc_0_b;
   wire          ex5_unf_calc_1_b;
   wire          ex6_d1clk;		
   wire          ex6_d2clk;
   wire [0:`NCLK_WIDTH-1]          ex6_lclk;		
   (* analysis_not_referenced="TRUE" *) 
   wire          unused;
   
   
   
   assign unused = |(ex5_expo_p0[1:13]) | |(ex5_expo_p1[1:13]) | ex5_ovf_calc | ex5_ovf_if_calc | ex5_unf_calc;
   
   
   
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
      .delay_lclkr(delay_lclkr[5]),		
      .mpw1_b(mpw1_b[5]),		
      .mpw2_b(mpw2_b[1]),		
      .force_t(force_t),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex5_act),		
      .sg(sg_0),		
      .thold_b(thold_0_b),		
      .d1clk(ex6_d1clk),		
      .d2clk(ex6_d2clk),		
      .lclk(ex6_lclk)		
   );
   
   
   assign ex3_act = (~ex3_act_b);
   
   
   tri_rlmreg_p #(.WIDTH(5),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),							
      .delay_lclkr(delay_lclkr[4]),		
      .mpw1_b(mpw1_b[4]),		
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
              ex3_act,
              ex4_act,
              act_spare_unused[2]}),
      .dout({  act_spare_unused[0],
               act_spare_unused[1],
               ex4_act,
               ex5_act,
               act_spare_unused[2]})
   );
   
   
   assign ex4_iexp[1:13] = ({13{(~f_pic_ex4_sel_est)}} & f_eie_ex4_iexp[1:13]) | 
                            ({13{f_pic_ex4_sel_est}}   & f_tbe_ex4_expo[1:13]);
   
   assign ex4_sp = (~f_pic_ex4_sp_b);
   
   
   assign ex4_may_ovf = (ex4_may_ov_usual & (~f_pic_ex4_sel_est)) | (f_tbe_ex4_may_ov & f_pic_ex4_sel_est);
   
   assign ex4_may_ov_usual = ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[2]) | ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[3] & f_eie_ex4_iexp[4]) | ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[3] & f_eie_ex4_iexp[5]) | ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[3] & f_eie_ex4_iexp[6]) | ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[3] & f_eie_ex4_iexp[7]) | ((~f_eie_ex4_iexp[1]) & f_eie_ex4_iexp[3] & f_eie_ex4_iexp[8] & f_eie_ex4_iexp[9]);
   
   
   
   tri_rlmreg_p #(.WIDTH(16),  .NEEDS_SRESET(0)) ex5_iexp_lat(
      .force_t(force_t),		
      .d_mode(tiup),					      
      .delay_lclkr(delay_lclkr[4]),		
      .mpw1_b(mpw1_b[4]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex4_act),
      .scout(ex5_iexp_so),
      .scin(ex5_iexp_si),
      .din({ ex4_sp,
             ex4_iexp[1:13],
             ex4_may_ovf,
             f_pic_ex4_sel_est}),
      .dout({ ex5_sp,		
              ex5_i_exp[1:13],		
              ex5_may_ovf,		
              ex5_sel_est})		
   );
   
   assign f_eov_ex5_may_ovf = ex5_may_ovf;
   
   
   
   assign ex5_ue1oe1_k[3] = ((~ex5_may_ovf) & (~ex5_sp)) | (ex5_may_ovf & ex5_sp);
   
   assign ex5_ue1oe1_k[4] = ((~ex5_sp)) | (ex5_may_ovf & ex5_sp);
   
   assign ex5_ue1oe1_k[5] = (ex5_may_ovf & ex5_sp);
   
   assign ex5_ue1oe1_k[6] = ((~ex5_may_ovf) & ex5_sp);
   assign ex5_ue1oe1_k[7] = (ex5_sp);
   
   
   
   assign ex5_lza_amt_b[0:7] = (~f_lza_ex5_lza_amt_eov[0:7]);
   assign ex5_lza_amt[0:7] = f_lza_ex5_lza_amt_eov[0:7];
   assign ex5_sh_rgt_en_b = (~f_lza_ex5_sh_rgt_en_eov);
   
   assign ex5_lzasub_sum[1] = ex5_sh_rgt_en_b ^ ex5_i_exp[1];
   assign ex5_lzasub_sum[2] = ex5_sh_rgt_en_b ^ ex5_i_exp[2];
   assign ex5_lzasub_sum[3] = ex5_sh_rgt_en_b ^ ex5_i_exp[3];
   assign ex5_lzasub_sum[4] = ex5_sh_rgt_en_b ^ ex5_i_exp[4];
   assign ex5_lzasub_sum[5] = ex5_sh_rgt_en_b ^ ex5_i_exp[5];
   assign ex5_lzasub_sum[6] = ex5_lza_amt_b[0] ^ ex5_i_exp[6];
   assign ex5_lzasub_sum[7] = ex5_lza_amt_b[1] ^ ex5_i_exp[7];
   assign ex5_lzasub_sum[8] = ex5_lza_amt_b[2] ^ ex5_i_exp[8];
   assign ex5_lzasub_sum[9] = ex5_lza_amt_b[3] ^ ex5_i_exp[9];
   assign ex5_lzasub_sum[10] = ex5_lza_amt_b[4] ^ ex5_i_exp[10];
   assign ex5_lzasub_sum[11] = ex5_lza_amt_b[5] ^ ex5_i_exp[11];
   assign ex5_lzasub_sum[12] = ex5_lza_amt_b[6] ^ ex5_i_exp[12];
   assign ex5_lzasub_sum[13] = (~(ex5_lza_amt_b[7] ^ ex5_i_exp[13]));		
   
   assign ex5_lzasub_car[1] = ex5_sh_rgt_en_b & ex5_i_exp[2];
   assign ex5_lzasub_car[2] = ex5_sh_rgt_en_b & ex5_i_exp[3];
   assign ex5_lzasub_car[3] = ex5_sh_rgt_en_b & ex5_i_exp[4];
   assign ex5_lzasub_car[4] = ex5_sh_rgt_en_b & ex5_i_exp[5];
   assign ex5_lzasub_car[5] = ex5_lza_amt_b[0] & ex5_i_exp[6];
   assign ex5_lzasub_car[6] = ex5_lza_amt_b[1] & ex5_i_exp[7];
   assign ex5_lzasub_car[7] = ex5_lza_amt_b[2] & ex5_i_exp[8];
   assign ex5_lzasub_car[8] = ex5_lza_amt_b[3] & ex5_i_exp[9];
   assign ex5_lzasub_car[9] = ex5_lza_amt_b[4] & ex5_i_exp[10];
   assign ex5_lzasub_car[10] = ex5_lza_amt_b[5] & ex5_i_exp[11];
   assign ex5_lzasub_car[11] = ex5_lza_amt_b[6] & ex5_i_exp[12];
   assign ex5_lzasub_car[12] = ex5_lza_amt_b[7] | ex5_i_exp[13];		
   
   assign ex5_lzasub_p[1:12] = ex5_lzasub_car[1:12] ^ ex5_lzasub_sum[1:12];
   assign ex5_lzasub_t[2:12] = ex5_lzasub_car[2:12] | ex5_lzasub_sum[2:12];
   assign ex5_lzasub_g[2:12] = ex5_lzasub_car[2:12] & ex5_lzasub_sum[2:12];
   
   
   assign ex5_lzasub_m1_c12 = ex5_lzasub_g[12];
   assign ex5_lzasub_p0_c12 = ex5_lzasub_g[12] | (ex5_lzasub_t[12] & ex5_lzasub_sum[13]);
   assign ex5_lzasub_p1_c12 = ex5_lzasub_t[12];
   
   assign ex5_lzasub_m1[13] = ex5_lzasub_sum[13];		
   assign ex5_lzasub_p0[13] = (~ex5_lzasub_sum[13]);		
   assign ex5_lzasub_p1[13] = ex5_lzasub_sum[13];		
   
   assign ex5_lzasub_m1[12] = ex5_lzasub_p[12];		
   assign ex5_lzasub_p0[12] = ex5_lzasub_p[12] ^ ex5_lzasub_sum[13];		
   assign ex5_lzasub_p1[12] = (~ex5_lzasub_p[12]);		
   
   
   
   assign ex5_lzasub_gg02[11] = ex5_lzasub_g[11];		
   assign ex5_lzasub_gg02[10] = ex5_lzasub_g[10] | (ex5_lzasub_t[10] & ex5_lzasub_g[11]);		
   assign ex5_lzasub_gg02[9] = ex5_lzasub_g[9] | (ex5_lzasub_t[9] & ex5_lzasub_g[10]);
   assign ex5_lzasub_gg02[8] = ex5_lzasub_g[8] | (ex5_lzasub_t[8] & ex5_lzasub_g[9]);
   assign ex5_lzasub_gg02[7] = ex5_lzasub_g[7] | (ex5_lzasub_t[7] & ex5_lzasub_g[8]);
   assign ex5_lzasub_gg02[6] = ex5_lzasub_g[6] | (ex5_lzasub_t[6] & ex5_lzasub_g[7]);
   assign ex5_lzasub_gg02[5] = ex5_lzasub_g[5] | (ex5_lzasub_t[5] & ex5_lzasub_g[6]);
   assign ex5_lzasub_gg02[4] = ex5_lzasub_g[4] | (ex5_lzasub_t[4] & ex5_lzasub_g[5]);
   assign ex5_lzasub_gg02[3] = ex5_lzasub_g[3] | (ex5_lzasub_t[3] & ex5_lzasub_g[4]);
   assign ex5_lzasub_gg02[2] = ex5_lzasub_g[2] | (ex5_lzasub_t[2] & ex5_lzasub_g[3]);
   
   assign ex5_lzasub_gt02[11] = ex5_lzasub_t[11];		
   assign ex5_lzasub_gt02[10] = ex5_lzasub_g[10] | (ex5_lzasub_t[10] & ex5_lzasub_t[11]);		
   assign ex5_lzasub_gt02[9] = (ex5_lzasub_t[9] & ex5_lzasub_t[10]);
   assign ex5_lzasub_gt02[8] = (ex5_lzasub_t[8] & ex5_lzasub_t[9]);
   assign ex5_lzasub_gt02[7] = (ex5_lzasub_t[7] & ex5_lzasub_t[8]);
   assign ex5_lzasub_gt02[6] = (ex5_lzasub_t[6] & ex5_lzasub_t[7]);
   assign ex5_lzasub_gt02[5] = (ex5_lzasub_t[5] & ex5_lzasub_t[6]);
   assign ex5_lzasub_gt02[4] = (ex5_lzasub_t[4] & ex5_lzasub_t[5]);
   assign ex5_lzasub_gt02[3] = (ex5_lzasub_t[3] & ex5_lzasub_t[4]);
   assign ex5_lzasub_gt02[2] = (ex5_lzasub_t[2] & ex5_lzasub_t[3]);
   
   assign ex5_lzasub_gg04[11] = ex5_lzasub_gg02[11];		
   assign ex5_lzasub_gg04[10] = ex5_lzasub_gg02[10];		
   assign ex5_lzasub_gg04[9] = ex5_lzasub_gg02[9] | (ex5_lzasub_gt02[9] & ex5_lzasub_gg02[11]);		
   assign ex5_lzasub_gg04[8] = ex5_lzasub_gg02[8] | (ex5_lzasub_gt02[8] & ex5_lzasub_gg02[10]);		
   assign ex5_lzasub_gg04[7] = ex5_lzasub_gg02[7] | (ex5_lzasub_gt02[7] & ex5_lzasub_gg02[9]);
   assign ex5_lzasub_gg04[6] = ex5_lzasub_gg02[6] | (ex5_lzasub_gt02[6] & ex5_lzasub_gg02[8]);
   assign ex5_lzasub_gg04[5] = ex5_lzasub_gg02[5] | (ex5_lzasub_gt02[5] & ex5_lzasub_gg02[7]);
   assign ex5_lzasub_gg04[4] = ex5_lzasub_gg02[4] | (ex5_lzasub_gt02[4] & ex5_lzasub_gg02[6]);
   assign ex5_lzasub_gg04[3] = ex5_lzasub_gg02[3] | (ex5_lzasub_gt02[3] & ex5_lzasub_gg02[5]);
   assign ex5_lzasub_gg04[2] = ex5_lzasub_gg02[2] | (ex5_lzasub_gt02[2] & ex5_lzasub_gg02[4]);
   
   assign ex5_lzasub_gt04[11] = ex5_lzasub_gt02[11];		
   assign ex5_lzasub_gt04[10] = ex5_lzasub_gt02[10];		
   assign ex5_lzasub_gt04[9] = ex5_lzasub_gg02[9] | (ex5_lzasub_gt02[9] & ex5_lzasub_gt02[11]);		
   assign ex5_lzasub_gt04[8] = ex5_lzasub_gg02[8] | (ex5_lzasub_gt02[8] & ex5_lzasub_gt02[10]);		
   assign ex5_lzasub_gt04[7] = (ex5_lzasub_gt02[7] & ex5_lzasub_gt02[9]);
   assign ex5_lzasub_gt04[6] = (ex5_lzasub_gt02[6] & ex5_lzasub_gt02[8]);
   assign ex5_lzasub_gt04[5] = (ex5_lzasub_gt02[5] & ex5_lzasub_gt02[7]);
   assign ex5_lzasub_gt04[4] = (ex5_lzasub_gt02[4] & ex5_lzasub_gt02[6]);
   assign ex5_lzasub_gt04[3] = (ex5_lzasub_gt02[3] & ex5_lzasub_gt02[5]);
   assign ex5_lzasub_gt04[2] = (ex5_lzasub_gt02[2] & ex5_lzasub_gt02[4]);
   
   assign ex5_lzasub_gg08[11] = ex5_lzasub_gg04[11];		
   assign ex5_lzasub_gg08[10] = ex5_lzasub_gg04[10];		
   assign ex5_lzasub_gg08[9] = ex5_lzasub_gg04[9];		
   assign ex5_lzasub_gg08[8] = ex5_lzasub_gg04[8];		
   assign ex5_lzasub_gg08[7] = ex5_lzasub_gg04[7] | (ex5_lzasub_gt04[7] & ex5_lzasub_gg04[11]);		
   assign ex5_lzasub_gg08[6] = ex5_lzasub_gg04[6] | (ex5_lzasub_gt04[6] & ex5_lzasub_gg04[10]);		
   assign ex5_lzasub_gg08[5] = ex5_lzasub_gg04[5] | (ex5_lzasub_gt04[5] & ex5_lzasub_gg04[9]);		
   assign ex5_lzasub_gg08[4] = ex5_lzasub_gg04[4] | (ex5_lzasub_gt04[4] & ex5_lzasub_gg04[8]);		
   assign ex5_lzasub_gg08[3] = ex5_lzasub_gg04[3] | (ex5_lzasub_gt04[3] & ex5_lzasub_gg04[7]);
   assign ex5_lzasub_gg08[2] = ex5_lzasub_gg04[2] | (ex5_lzasub_gt04[2] & ex5_lzasub_gg04[6]);
   
   assign ex5_lzasub_gt08[11] = ex5_lzasub_gt04[11];		
   assign ex5_lzasub_gt08[10] = ex5_lzasub_gt04[10];		
   assign ex5_lzasub_gt08[9] = ex5_lzasub_gt04[9];		
   assign ex5_lzasub_gt08[8] = ex5_lzasub_gt04[8];		
   assign ex5_lzasub_gt08[7] = ex5_lzasub_gg04[7] | (ex5_lzasub_gt04[7] & ex5_lzasub_gt04[11]);		
   assign ex5_lzasub_gt08[6] = ex5_lzasub_gg04[6] | (ex5_lzasub_gt04[6] & ex5_lzasub_gt04[10]);		
   assign ex5_lzasub_gt08[5] = ex5_lzasub_gg04[5] | (ex5_lzasub_gt04[5] & ex5_lzasub_gt04[9]);		
   assign ex5_lzasub_gt08[4] = ex5_lzasub_gg04[4] | (ex5_lzasub_gt04[4] & ex5_lzasub_gt04[8]);		
   assign ex5_lzasub_gt08[3] = (ex5_lzasub_gt04[3] & ex5_lzasub_gt04[7]);
   assign ex5_lzasub_gt08[2] = (ex5_lzasub_gt04[2] & ex5_lzasub_gt04[6]);
   
   assign ex5_lzasub_c0[11] = ex5_lzasub_gg08[11];		
   assign ex5_lzasub_c0[10] = ex5_lzasub_gg08[10];		
   assign ex5_lzasub_c0[9] = ex5_lzasub_gg08[9];		
   assign ex5_lzasub_c0[8] = ex5_lzasub_gg08[8];		
   assign ex5_lzasub_c0[7] = ex5_lzasub_gg08[7];		
   assign ex5_lzasub_c0[6] = ex5_lzasub_gg08[6];		
   assign ex5_lzasub_c0[5] = ex5_lzasub_gg08[5];		
   assign ex5_lzasub_c0[4] = ex5_lzasub_gg08[4];		
   assign ex5_lzasub_c0[3] = ex5_lzasub_gg08[3] | (ex5_lzasub_gt08[3] & ex5_lzasub_gg08[11]);		
   assign ex5_lzasub_c0[2] = ex5_lzasub_gg08[2] | (ex5_lzasub_gt08[2] & ex5_lzasub_gg08[10]);		
   
   assign ex5_lzasub_c1[11] = ex5_lzasub_gt08[11];		
   assign ex5_lzasub_c1[10] = ex5_lzasub_gt08[10];		
   assign ex5_lzasub_c1[9] = ex5_lzasub_gt08[9];		
   assign ex5_lzasub_c1[8] = ex5_lzasub_gt08[8];		
   assign ex5_lzasub_c1[7] = ex5_lzasub_gt08[7];		
   assign ex5_lzasub_c1[6] = ex5_lzasub_gt08[6];		
   assign ex5_lzasub_c1[5] = ex5_lzasub_gt08[5];		
   assign ex5_lzasub_c1[4] = ex5_lzasub_gt08[4];		
   assign ex5_lzasub_c1[3] = ex5_lzasub_gg08[3] | (ex5_lzasub_gt08[3] & ex5_lzasub_gt08[11]);		
   assign ex5_lzasub_c1[2] = ex5_lzasub_gg08[2] | (ex5_lzasub_gt08[2] & ex5_lzasub_gt08[10]);		
   
   assign ex5_lzasub_s0[1:11] = ex5_lzasub_p[1:11] ^ ({ex5_lzasub_c0[2:11], tidn});
   assign ex5_lzasub_s1[1:11] = ex5_lzasub_p[1:11] ^ ({ex5_lzasub_c1[2:11], tiup});
   
   assign ex5_lzasub_m1[1:11] = (ex5_lzasub_s0[1:11] & {11{(~ex5_lzasub_m1_c12)}}) | 
                                (ex5_lzasub_s1[1:11] & {11{ex5_lzasub_m1_c12}});
   
   assign ex5_lzasub_p0[1:11] = (ex5_lzasub_s0[1:11] & {11{(~ex5_lzasub_p0_c12)}}) | 
                                (ex5_lzasub_s1[1:11] & {11{ex5_lzasub_p0_c12}});
   
   assign ex5_lzasub_p1[1:11] = (ex5_lzasub_s0[1:11] & {11{(~ex5_lzasub_p1_c12)}}) | 
                                (ex5_lzasub_s1[1:11] & {11{ex5_lzasub_p1_c12}});
   
   
   assign ex5_ovf_sum[1] = ex5_sh_rgt_en_b ^ (~ex5_i_exp[1]);		
   assign ex5_ovf_sum[2] = ex5_sh_rgt_en_b ^ (~ex5_i_exp[2]);		
   assign ex5_ovf_sum[3] = ex5_sh_rgt_en_b ^ ex5_i_exp[3];		
   assign ex5_ovf_sum[4] = ex5_sh_rgt_en_b ^ ex5_i_exp[4] ^ ex5_sp;		
   assign ex5_ovf_sum[5] = ex5_sh_rgt_en_b ^ ex5_i_exp[5] ^ ex5_sp;		
   assign ex5_ovf_sum[6] = (~ex5_lza_amt[0]) ^ ex5_i_exp[6] ^ ex5_sp;		
   assign ex5_ovf_sum[7] = (~ex5_lza_amt[1]) ^ ex5_i_exp[7];		
   assign ex5_ovf_sum[8] = (~ex5_lza_amt[2]) ^ ex5_i_exp[8];		
   assign ex5_ovf_sum[9] = (~ex5_lza_amt[3]) ^ ex5_i_exp[9];		
   assign ex5_ovf_sum[10] = (~ex5_lza_amt[4]) ^ ex5_i_exp[10];		
   assign ex5_ovf_sum[11] = (~ex5_lza_amt[5]) ^ ex5_i_exp[11];		
   assign ex5_ovf_sum[12] = (~ex5_lza_amt[6]) ^ (~ex5_i_exp[12]);		
   assign ex5_ovf_sum[13] = (~ex5_lza_amt[7]) ^ ex5_i_exp[13];		
   
   assign ex5_ovf_car[1] = ex5_sh_rgt_en_b | ex5_i_exp[2];		
   assign ex5_ovf_car[2] = ex5_sh_rgt_en_b & ex5_i_exp[3];		
   
   assign ex5_ovf_car[3] = (ex5_sp & ex5_i_exp[4]) | (ex5_sh_rgt_en_b & ex5_i_exp[4]) | (ex5_sh_rgt_en_b & ex5_sp);		
   
   assign ex5_ovf_car[4] = (ex5_sp & ex5_i_exp[5]) | (ex5_sh_rgt_en_b & ex5_i_exp[5]) | (ex5_sh_rgt_en_b & ex5_sp);		
   
   assign ex5_ovf_car[5] = ((~ex5_lza_amt[0]) & ex5_i_exp[6]) | ((~ex5_lza_amt[0]) & ex5_sp) | (ex5_sp & ex5_i_exp[6]);		
   assign ex5_ovf_car[6] = (~ex5_lza_amt[1]) & ex5_i_exp[7];		
   assign ex5_ovf_car[7] = (~ex5_lza_amt[2]) & ex5_i_exp[8];		
   assign ex5_ovf_car[8] = (~ex5_lza_amt[3]) & ex5_i_exp[9];		
   assign ex5_ovf_car[9] = (~ex5_lza_amt[4]) & ex5_i_exp[10];		
   assign ex5_ovf_car[10] = (~ex5_lza_amt[5]) & ex5_i_exp[11];		
   assign ex5_ovf_car[11] = (~ex5_lza_amt[6]) | ex5_i_exp[12];		
   assign ex5_ovf_car[12] = (~ex5_lza_amt[7]) & ex5_i_exp[13];		
   
   assign ex5_ovf_g[2:12] = ex5_ovf_car[2:12] & ex5_ovf_sum[2:12];
   assign ex5_ovf_t[2:12] = ex5_ovf_car[2:12] | ex5_ovf_sum[2:12];
   assign ex5_ovf_p[1] = ex5_ovf_car[1] ^ ex5_ovf_sum[1];
   
   
   assign ex5_ovf_m1_co12 = ex5_ovf_g[12];
   assign ex5_ovf_p0_co12 = ex5_ovf_g[12] | (ex5_ovf_t[12] & ex5_ovf_sum[13]);
   assign ex5_ovf_p1_co12 = ex5_ovf_t[12];
   
   
   assign ex5_ovf_g2_02t03 = ex5_ovf_g[2] | (ex5_ovf_t[2] & ex5_ovf_g[3]);
   assign ex5_ovf_g2_04t05 = ex5_ovf_g[4] | (ex5_ovf_t[4] & ex5_ovf_g[5]);
   assign ex5_ovf_g2_06t07 = ex5_ovf_g[6] | (ex5_ovf_t[6] & ex5_ovf_g[7]);
   assign ex5_ovf_g2_08t09 = ex5_ovf_g[8] | (ex5_ovf_t[8] & ex5_ovf_g[9]);
   assign ex5_ovf_g2_ci0 = ex5_ovf_g[10] | (ex5_ovf_t[10] & ex5_ovf_g[11]);
   assign ex5_ovf_g2_ci1 = ex5_ovf_g[10] | (ex5_ovf_t[10] & ex5_ovf_t[11]);
   
   assign ex5_ovf_t2_02t03 = (ex5_ovf_t[2] & ex5_ovf_t[3]);
   assign ex5_ovf_t2_04t05 = (ex5_ovf_t[4] & ex5_ovf_t[5]);
   assign ex5_ovf_t2_06t07 = (ex5_ovf_t[6] & ex5_ovf_t[7]);
   assign ex5_ovf_t2_08t09 = (ex5_ovf_t[8] & ex5_ovf_t[9]);
   
   assign ex5_ovf_g4_02t05 = ex5_ovf_g2_02t03 | (ex5_ovf_t2_02t03 & ex5_ovf_g2_04t05);
   assign ex5_ovf_g4_06t09 = ex5_ovf_g2_06t07 | (ex5_ovf_t2_06t07 & ex5_ovf_g2_08t09);
   assign ex5_ovf_g4_ci0 = ex5_ovf_g2_ci0;
   assign ex5_ovf_g4_ci1 = ex5_ovf_g2_ci1;
   
   assign ex5_ovf_t4_02t05 = (ex5_ovf_t2_02t03 & ex5_ovf_t2_04t05);
   assign ex5_ovf_t4_06t09 = (ex5_ovf_t2_06t07 & ex5_ovf_t2_08t09);
   
   assign ex5_ovf_g8_02t09 = ex5_ovf_g4_02t05 | (ex5_ovf_t4_02t05 & ex5_ovf_g4_06t09);
   assign ex5_ovf_g8_ci0 = ex5_ovf_g4_ci0;
   assign ex5_ovf_g8_ci1 = ex5_ovf_g4_ci1;
   
   assign ex5_ovf_t8_02t09 = (ex5_ovf_t4_02t05 & ex5_ovf_t4_06t09);
   
   assign ex5_ovf_ci0_02t11 = ex5_ovf_g8_02t09 | (ex5_ovf_t8_02t09 & ex5_ovf_g8_ci0);
   assign ex5_ovf_ci1_02t11 = ex5_ovf_g8_02t09 | (ex5_ovf_t8_02t09 & ex5_ovf_g8_ci1);
   
   assign ex5_c2_m1 = (ex5_ovf_ci0_02t11 | (ex5_ovf_ci1_02t11 & ex5_ovf_m1_co12));
   assign ex5_c2_p0 = (ex5_ovf_ci0_02t11 | (ex5_ovf_ci1_02t11 & ex5_ovf_p0_co12));
   assign ex5_c2_p1 = (ex5_ovf_ci0_02t11 | (ex5_ovf_ci1_02t11 & ex5_ovf_p1_co12));
   
   assign ex5_ovf_m1 = (~ex5_ovf_p[1]) ^ ex5_c2_m1;
   assign ex5_ovf_p0 = (~ex5_ovf_p[1]) ^ ex5_c2_p0;
   assign ex5_ovf_p1 = (~ex5_ovf_p[1]) ^ ex5_c2_p1;
   
   
   assign ex5_unf_sum[1] = ex5_sh_rgt_en_b ^ ex5_i_exp[1] ^ ex5_sp;		
   assign ex5_unf_sum[2] = ex5_sh_rgt_en_b ^ ex5_i_exp[2] ^ ex5_sp;		
   assign ex5_unf_sum[3] = ex5_sh_rgt_en_b ^ ex5_i_exp[3] ^ ex5_sp;		
   assign ex5_unf_sum[4] = ex5_sh_rgt_en_b ^ ex5_i_exp[4];		
   assign ex5_unf_sum[5] = ex5_sh_rgt_en_b ^ ex5_i_exp[5];		
   assign ex5_unf_sum[6] = (~ex5_lza_amt[0]) ^ ex5_i_exp[6] ^ ex5_sp;		
   assign ex5_unf_sum[7] = (~ex5_lza_amt[1]) ^ ex5_i_exp[7];		
   assign ex5_unf_sum[8] = (~ex5_lza_amt[2]) ^ ex5_i_exp[8];		
   assign ex5_unf_sum[9] = (~ex5_lza_amt[3]) ^ ex5_i_exp[9];		
   assign ex5_unf_sum[10] = (~ex5_lza_amt[4]) ^ ex5_i_exp[10];		
   assign ex5_unf_sum[11] = (~ex5_lza_amt[5]) ^ ex5_i_exp[11];		
   assign ex5_unf_sum[12] = (~ex5_lza_amt[6]) ^ ex5_i_exp[12];		
   assign ex5_unf_sum[13] = (~ex5_lza_amt[7]) ^ ex5_i_exp[13];		
   
   assign ex5_unf_car[1] = (ex5_sp & ex5_i_exp[2]) | (ex5_sh_rgt_en_b & ex5_i_exp[2]) | (ex5_sh_rgt_en_b & ex5_sp);		
   assign ex5_unf_car[2] = (ex5_sp & ex5_i_exp[3]) | (ex5_sh_rgt_en_b & ex5_i_exp[3]) | (ex5_sh_rgt_en_b & ex5_sp);		
   assign ex5_unf_car[3] = ex5_sh_rgt_en_b & ex5_i_exp[4];		
   assign ex5_unf_car[4] = ex5_sh_rgt_en_b & ex5_i_exp[5];		
   assign ex5_unf_car[5] = ((~ex5_lza_amt[0]) & ex5_i_exp[6]) | ((~ex5_lza_amt[0]) & ex5_sp) | (ex5_sp & ex5_i_exp[6]);		
   assign ex5_unf_car[6] = (~ex5_lza_amt[1]) & ex5_i_exp[7];		
   assign ex5_unf_car[7] = (~ex5_lza_amt[2]) & ex5_i_exp[8];		
   assign ex5_unf_car[8] = (~ex5_lza_amt[3]) & ex5_i_exp[9];		
   assign ex5_unf_car[9] = (~ex5_lza_amt[4]) & ex5_i_exp[10];		
   assign ex5_unf_car[10] = (~ex5_lza_amt[5]) & ex5_i_exp[11];		
   assign ex5_unf_car[11] = (~ex5_lza_amt[6]) & ex5_i_exp[12];		
   assign ex5_unf_car[12] = (~ex5_lza_amt[7]) & ex5_i_exp[13];		
   
   assign ex5_unf_g[2:12] = ex5_unf_car[2:12] & ex5_unf_sum[2:12];
   assign ex5_unf_t[2:12] = ex5_unf_car[2:12] | ex5_unf_sum[2:12];
   assign ex5_unf_p[1] = ex5_unf_car[1] ^ ex5_unf_sum[1];
   
   assign ex5_unf_m1_co12 = ex5_unf_g[12];
   assign ex5_unf_p0_co12 = ex5_unf_g[12] | (ex5_unf_t[12] & ex5_unf_sum[13]);
   
   assign ex5_unf_g2_02t03 = ex5_unf_g[2] | (ex5_unf_t[2] & ex5_unf_g[3]);
   assign ex5_unf_g2_04t05 = ex5_unf_g[4] | (ex5_unf_t[4] & ex5_unf_g[5]);
   assign ex5_unf_g2_06t07 = ex5_unf_g[6] | (ex5_unf_t[6] & ex5_unf_g[7]);
   assign ex5_unf_g2_08t09 = ex5_unf_g[8] | (ex5_unf_t[8] & ex5_unf_g[9]);
   assign ex5_unf_g2_10t11 = ex5_unf_g[10] | (ex5_unf_t[10] & ex5_unf_g[11]);
   assign ex5_unf_ci0_g2 = ex5_unf_g[12];
   assign ex5_unf_ci1_g2 = ex5_unf_t[12];
   
   assign ex5_unf_t2_02t03 = (ex5_unf_t[2] & ex5_unf_t[3]);		
   assign ex5_unf_t2_04t05 = (ex5_unf_t[4] & ex5_unf_t[5]);
   assign ex5_unf_t2_06t07 = (ex5_unf_t[6] & ex5_unf_t[7]);		
   assign ex5_unf_t2_08t09 = (ex5_unf_t[8] & ex5_unf_t[9]);
   assign ex5_unf_t2_10t11 = (ex5_unf_t[10] & ex5_unf_t[11]);		
   
   assign ex5_unf_g4_02t05 = ex5_unf_g2_02t03 | (ex5_unf_t2_02t03 & ex5_unf_g2_04t05);
   assign ex5_unf_g4_06t09 = ex5_unf_g2_06t07 | (ex5_unf_t2_06t07 & ex5_unf_g2_08t09);
   assign ex5_unf_ci0_g4 = ex5_unf_g2_10t11 | (ex5_unf_t2_10t11 & ex5_unf_ci0_g2);
   assign ex5_unf_ci1_g4 = ex5_unf_g2_10t11 | (ex5_unf_t2_10t11 & ex5_unf_ci1_g2);
   
   assign ex5_unf_t4_02t05 = (ex5_unf_t2_02t03 & ex5_unf_t2_04t05);
   assign ex5_unf_t4_06t09 = (ex5_unf_t2_06t07 & ex5_unf_t2_08t09);
   
   assign ex5_unf_g8_02t09 = ex5_unf_g4_02t05 | (ex5_unf_t4_02t05 & ex5_unf_g4_06t09);
   assign ex5_unf_ci0_g8 = ex5_unf_ci0_g4;
   assign ex5_unf_ci1_g8 = ex5_unf_ci1_g4;
   
   assign ex5_unf_t8_02t09 = (ex5_unf_t4_02t05 & ex5_unf_t4_06t09);
   
   assign ex5_unf_ci0_02t11 = ex5_unf_g8_02t09 | (ex5_unf_t8_02t09 & ex5_unf_ci0_g8);
   assign ex5_unf_ci1_02t11 = ex5_unf_g8_02t09 | (ex5_unf_t8_02t09 & ex5_unf_ci1_g8);
   
   assign ex5_unf_c2_m1 = (ex5_unf_ci0_02t11 | (ex5_unf_ci1_02t11 & ex5_unf_m1_co12));
   assign ex5_unf_c2_p0 = (ex5_unf_ci0_02t11 | (ex5_unf_ci1_02t11 & ex5_unf_p0_co12));
   
   assign ex5_unf_m1 = ex5_unf_p[1] ^ ex5_unf_c2_m1;
   assign ex5_unf_p0 = ex5_unf_p[1] ^ ex5_unf_c2_p0;
   
   
   
   assign ex5_expo_p0_0_b[1:13] = (~(ex5_lzasub_m1[1:13] & {13{f_nrm_ex5_extra_shift}}));
   assign ex5_expo_p0_1_b[1:13] = (~(ex5_lzasub_p0[1:13] & {13{(~f_nrm_ex5_extra_shift)}}));
   assign ex5_expo_p0[1:13] = (~(ex5_expo_p0_0_b[1:13] & ex5_expo_p0_1_b[1:13]));
   
   assign ex5_expo_p1_0_b[1:13] = (~(ex5_lzasub_p0[1:13] & {13{f_nrm_ex5_extra_shift}}));
   assign ex5_expo_p1_1_b[1:13] = (~(ex5_lzasub_p1[1:13] & {13{(~f_nrm_ex5_extra_shift)}}));
   assign ex5_expo_p1[1:13] = (~(ex5_expo_p1_0_b[1:13] & ex5_expo_p1_1_b[1:13]));
   
   assign ex5_ovf_calc_0_b = (~(ex5_ovf_m1 & f_nrm_ex5_extra_shift));
   assign ex5_ovf_calc_1_b = (~(ex5_ovf_p0 & (~f_nrm_ex5_extra_shift)));
   assign ex5_ovf_calc = (~(ex5_ovf_calc_0_b & ex5_ovf_calc_1_b));
   
   assign ex5_ovf_if_calc_0_b = (~(ex5_ovf_p0 & f_nrm_ex5_extra_shift));
   assign ex5_ovf_if_calc_1_b = (~(ex5_ovf_p1 & (~f_nrm_ex5_extra_shift)));
   assign ex5_ovf_if_calc = (~(ex5_ovf_if_calc_0_b & ex5_ovf_if_calc_1_b));
   
   assign ex5_unf_calc_0_b = (~(ex5_unf_m1 & f_nrm_ex5_extra_shift));
   assign ex5_unf_calc_1_b = (~(ex5_unf_p0 & (~f_nrm_ex5_extra_shift)));
   assign ex5_unf_calc = (~(ex5_unf_calc_0_b & ex5_unf_calc_1_b));
   
   assign ex5_est_sp = ex5_sel_est & ex5_sp;
   
   assign ex5_unf_tbl = f_pic_ex5_uf_en & f_tbl_ex5_unf_expo;
   assign ex5_unf_tbl_spec_e = (ex5_unf_tbl & (~ex5_est_sp) & (~f_pic_ex5_ue)) | ex5_sel_k_part_e;		
   assign ex5_ov_en = f_pic_ex5_ov_en;
   assign ex5_ov_en_oe0 = f_pic_ex5_ov_en & (~f_pic_ex5_oe);
   assign ex5_sel_ov_spec = f_pic_ex5_sel_ov_spec;
   assign ex5_unf_en_nedge = f_pic_ex5_uf_en & (~f_lza_ex5_no_lza_edge);
   assign ex5_unf_ue0_nestsp = f_pic_ex5_uf_en & (~f_lza_ex5_no_lza_edge) & (~f_pic_ex5_ue) & (~(ex5_est_sp));
   assign ex5_sel_k_part_e = f_pic_ex5_spec_sel_k_e | f_pic_ex5_to_int_ov_all;
   assign ex5_sel_k_part_f = f_pic_ex5_spec_sel_k_f | f_pic_ex5_to_int_ov_all;
   
   
   tri_nand2_nlats #(.WIDTH(13), .NEEDS_SRESET(0)) ex6_urnd0_lat( 
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_urnd0_si),
      .scanout(ex6_urnd0_so),
      .a1(ex5_expo_p0_0_b[1:13]),
      .a2(ex5_expo_p0_1_b[1:13]),
      .qb(ex6_expo_p0[1:13])		
   );
   
   tri_nand2_nlats #(.WIDTH(13),  .NEEDS_SRESET(0)) ex6_urnd1_lat( 
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_urnd1_si),
      .scanout(ex6_urnd1_so),
      .a1(ex5_expo_p1_0_b[1:13]),
      .a2(ex5_expo_p1_1_b[1:13]),
      .qb(ex6_expo_p1[1:13])		
   );
   
   tri_nand2_nlats #(.WIDTH(3),   .NEEDS_SRESET(0)) ex6_ovctl_lat( 
      .vd(vdd),
      .gd(gnd),								  
      .lclk(ex6_lclk),		
      .d1clk(ex6_d1clk),
      .d2clk(ex6_d2clk),
      .scanin(ex6_ovctl_si),
      .scanout(ex6_ovctl_so),
      .a1({ex5_ovf_calc_0_b,
           ex5_ovf_if_calc_0_b,
           ex5_unf_calc_0_b}),
      .a2({ex5_ovf_calc_1_b,
           ex5_ovf_if_calc_1_b,
           ex5_unf_calc_1_b}),
      .qb({ex6_ovf_calc,		
           ex6_ovf_if_calc,		
           ex6_unf_calc})		
   );
   
   
   tri_rlmreg_p #(.WIDTH(13),  .NEEDS_SRESET(0)) ex6_misc_lat(
      .force_t(force_t),		
      .d_mode(tiup),							      
      .delay_lclkr(delay_lclkr[5]),		
      .mpw1_b(mpw1_b[5]),		
      .mpw2_b(mpw2_b[1]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .act(ex5_act),
      .scout(ex6_misc_so),
      .scin(ex6_misc_si),
      .din({ ex5_unf_tbl,
             ex5_unf_tbl_spec_e,
             ex5_ov_en,
             ex5_ov_en_oe0,
             ex5_sel_ov_spec,
             ex5_unf_en_nedge,
             ex5_unf_ue0_nestsp,
             ex5_sel_k_part_f,
             ex5_ue1oe1_k[3:7]}),
      .dout({ ex6_unf_tbl,		
              ex6_unf_tbl_spec_e,		
              ex6_ov_en,		
              ex6_ov_en_oe0,		
              ex6_sel_ov_spec,		
              ex6_unf_en_nedge,		
              ex6_unf_ue0_nestsp,		
              ex6_sel_k_part_f,		
              ex6_ue1oe1_k[3:7]})		
   );
   
   
   assign f_eov_ex6_expo_p0[1:13] = ex6_expo_p0[1:13];		
   assign f_eov_ex6_expo_p1[1:13] = ex6_expo_p1[1:13];		
   
   
   
   assign ex6_sel_ov_spec_b = (~(ex6_sel_ov_spec));
   assign ex6_ovf_b = (~(ex6_ovf_calc & ex6_ov_en));
   assign ex6_ovf_if_b = (~(ex6_ovf_if_calc & ex6_ov_en));
   assign ex6_ovf_oe0_b = (~(ex6_ovf_calc & ex6_ov_en_oe0));
   assign ex6_ovf_if_oe0_b = (~(ex6_ovf_if_calc & ex6_ov_en_oe0));
   assign ex6_unf_b = (~(ex6_unf_calc & ex6_unf_en_nedge));
   assign ex6_unf_ue0_b = (~(ex6_unf_calc & ex6_unf_ue0_nestsp));
   assign ex6_sel_k_part_f_b = (~(ex6_sel_k_part_f));
   assign ex6_unf_tbl_spec_e_b = (~(ex6_unf_tbl_spec_e));
   assign ex6_unf_tbl_b = (~(ex6_unf_tbl));
   
   
   assign f_eov_ex6_ovf_expo = (~(ex6_ovf_b & ex6_sel_ov_spec_b));
   assign f_eov_ex6_ovf_if_expo = (~(ex6_ovf_if_b & ex6_sel_ov_spec_b));
   assign f_eov_ex6_sel_k_f = (~(ex6_ovf_oe0_b & ex6_sel_k_part_f_b));
   assign f_eov_ex6_sel_kif_f = (~(ex6_ovf_if_oe0_b & ex6_sel_k_part_f_b));
   assign f_eov_ex6_unf_expo = (~(ex6_unf_b & ex6_unf_tbl_b));
   assign f_eov_ex6_sel_k_e = (~(ex6_unf_ue0_b & ex6_unf_tbl_spec_e_b & ex6_ovf_oe0_b));
   assign f_eov_ex6_sel_kif_e = (~(ex6_unf_ue0_b & ex6_unf_tbl_spec_e_b & ex6_ovf_if_oe0_b));
   
   
   assign f_eov_ex6_expo_p0_ue1oe1[3:6] = ex6_ue1oe1_p0_p[3:6] ^ ex6_ue1oe1_p0_c[4:7];		
   assign f_eov_ex6_expo_p0_ue1oe1[7] = ex6_ue1oe1_p0_p[7];
   
   assign ex6_ue1oe1_p0_p[3:7] = ex6_expo_p0[3:7] ^ ex6_ue1oe1_k[3:7];
   assign ex6_ue1oe1_p0_g[4:7] = ex6_expo_p0[4:7] & ex6_ue1oe1_k[4:7];
   assign ex6_ue1oe1_p0_t[4:6] = ex6_expo_p0[4:6] | ex6_ue1oe1_k[4:6];
   
   assign ex6_ue1oe1_p0_g2_b[7] = (~(ex6_ue1oe1_p0_g[7]));
   assign ex6_ue1oe1_p0_g2_b[6] = (~(ex6_ue1oe1_p0_g[6] | (ex6_ue1oe1_p0_t[6] & ex6_ue1oe1_p0_g[7])));
   assign ex6_ue1oe1_p0_g2_b[5] = (~(ex6_ue1oe1_p0_g[5]));
   assign ex6_ue1oe1_p0_g2_b[4] = (~(ex6_ue1oe1_p0_g[4] | (ex6_ue1oe1_p0_t[4] & ex6_ue1oe1_p0_g[5])));
   
   assign ex6_ue1oe1_p0_t2_b[5] = (~(ex6_ue1oe1_p0_t[5]));
   assign ex6_ue1oe1_p0_t2_b[4] = (~((ex6_ue1oe1_p0_t[4] & ex6_ue1oe1_p0_t[5])));
   
   assign ex6_ue1oe1_p0_c[7] = (~(ex6_ue1oe1_p0_g2_b[7]));
   assign ex6_ue1oe1_p0_c[6] = (~(ex6_ue1oe1_p0_g2_b[6]));
   assign ex6_ue1oe1_p0_c[5] = (~(ex6_ue1oe1_p0_g2_b[5] & (ex6_ue1oe1_p0_t2_b[5] | ex6_ue1oe1_p0_g2_b[6])));
   assign ex6_ue1oe1_p0_c[4] = (~(ex6_ue1oe1_p0_g2_b[4] & (ex6_ue1oe1_p0_t2_b[4] | ex6_ue1oe1_p0_g2_b[6])));
   
   
   assign f_eov_ex6_expo_p1_ue1oe1[3:6] = ex6_ue1oe1_p1_p[3:6] ^ ex6_ue1oe1_p1_c[4:7];		
   assign f_eov_ex6_expo_p1_ue1oe1[7] = ex6_ue1oe1_p1_p[7];
   
   assign ex6_ue1oe1_p1_p[3:7] = ex6_expo_p1[3:7] ^ ex6_ue1oe1_k[3:7];
   assign ex6_ue1oe1_p1_g[4:7] = ex6_expo_p1[4:7] & ex6_ue1oe1_k[4:7];
   assign ex6_ue1oe1_p1_t[4:6] = ex6_expo_p1[4:6] | ex6_ue1oe1_k[4:6];
   
   assign ex6_ue1oe1_p1_g2_b[7] = (~(ex6_ue1oe1_p1_g[7]));
   assign ex6_ue1oe1_p1_g2_b[6] = (~(ex6_ue1oe1_p1_g[6] | (ex6_ue1oe1_p1_t[6] & ex6_ue1oe1_p1_g[7])));
   assign ex6_ue1oe1_p1_g2_b[5] = (~(ex6_ue1oe1_p1_g[5]));
   assign ex6_ue1oe1_p1_g2_b[4] = (~(ex6_ue1oe1_p1_g[4] | (ex6_ue1oe1_p1_t[4] & ex6_ue1oe1_p1_g[5])));
   
   assign ex6_ue1oe1_p1_t2_b[5] = (~(ex6_ue1oe1_p1_t[5]));
   assign ex6_ue1oe1_p1_t2_b[4] = (~((ex6_ue1oe1_p1_t[4] & ex6_ue1oe1_p1_t[5])));
   
   assign ex6_ue1oe1_p1_c[7] = (~(ex6_ue1oe1_p1_g2_b[7]));
   assign ex6_ue1oe1_p1_c[6] = (~(ex6_ue1oe1_p1_g2_b[6]));
   assign ex6_ue1oe1_p1_c[5] = (~(ex6_ue1oe1_p1_g2_b[5] & (ex6_ue1oe1_p1_t2_b[5] | ex6_ue1oe1_p1_g2_b[6])));
   assign ex6_ue1oe1_p1_c[4] = (~(ex6_ue1oe1_p1_g2_b[4] & (ex6_ue1oe1_p1_t2_b[4] | ex6_ue1oe1_p1_g2_b[6])));
   
   
   assign act_si[0:4] = {act_so[1:4], f_eov_si};
   assign ex5_iexp_si[0:15] = {ex5_iexp_so[1:15], act_so[0]};
   assign ex6_ovctl_si[0:2] = {ex6_ovctl_so[1:2], ex5_iexp_so[0]};
   assign ex6_misc_si[0:12] = {ex6_misc_so[1:12], ex6_ovctl_so[0]};
   assign ex6_urnd0_si[0:12] = {ex6_urnd0_so[1:12], ex6_misc_so[0]};
   assign ex6_urnd1_si[0:12] = {ex6_urnd1_so[1:12], ex6_urnd0_so[0]};
   assign f_eov_so = ex6_urnd1_so[0];
   
endmodule
