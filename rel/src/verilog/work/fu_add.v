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
   

module fu_add(
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
   f_add_si,
   f_add_so,
   ex2_act_b,
   f_sa3_ex4_s,
   f_sa3_ex4_c,
   f_alg_ex4_frc_sel_p1,
   f_alg_ex4_sticky,
   f_alg_ex3_effsub_eac_b,
   f_alg_ex3_prod_z,
   f_pic_ex4_is_gt,
   f_pic_ex4_is_lt,
   f_pic_ex4_is_eq,
   f_pic_ex4_is_nan,
   f_pic_ex4_cmp_sgnpos,
   f_pic_ex4_cmp_sgnneg,
   f_add_ex5_res,
   f_add_ex5_flag_nan,
   f_add_ex5_flag_gt,
   f_add_ex5_flag_lt,
   f_add_ex5_flag_eq,
   f_add_ex5_fpcc_iu,
   f_add_ex5_sign_carry,
   f_add_ex5_to_int_ovf_wd,
   f_add_ex5_to_int_ovf_dw,
   f_add_ex5_sticky
);
   
   inout          vdd;
   inout          gnd;
   input          clkoff_b;		
   input          act_dis;		
   input          flush;		
   input [3:4]    delay_lclkr;		
   input [3:4]    mpw1_b;		
   input [0:0]    mpw2_b;		
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		
   input  [0:`NCLK_WIDTH-1]         nclk;
   
   input          f_add_si;		
   output         f_add_so;		
   input          ex2_act_b;		
   
   input [0:162]  f_sa3_ex4_s;		
   input [53:161] f_sa3_ex4_c;		
   
   input          f_alg_ex4_frc_sel_p1;		
   input          f_alg_ex4_sticky;		
   input          f_alg_ex3_effsub_eac_b;		
   input          f_alg_ex3_prod_z;		
   
   input          f_pic_ex4_is_gt;		
   input          f_pic_ex4_is_lt;		
   input          f_pic_ex4_is_eq;		
   input          f_pic_ex4_is_nan;		
   input          f_pic_ex4_cmp_sgnpos;		
   input          f_pic_ex4_cmp_sgnneg;		
   
   output [0:162] f_add_ex5_res;		
   output         f_add_ex5_flag_nan;		
   output         f_add_ex5_flag_gt;		
   output         f_add_ex5_flag_lt;		
   output         f_add_ex5_flag_eq;		
   output [0:3]   f_add_ex5_fpcc_iu;		
   output         f_add_ex5_sign_carry;		
   output [0:1]   f_add_ex5_to_int_ovf_wd;		
   output [0:1]   f_add_ex5_to_int_ovf_dw;		
   output         f_add_ex5_sticky;		
   
   
   
   
   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;
   
   
   wire           thold_0_b;
   wire           thold_0;
   wire           sg_0;
   wire           force_t;
   
   wire           ex2_act;
   wire           ex3_act;
   wire           ex4_act;
   
   wire [0:8]     act_si;
   wire [0:8]     act_so;
   wire [0:162]   ex5_res_so;
   wire [0:162]   ex5_res_si;
   wire [0:9]     ex5_cmp_so;
   wire [0:9]     ex5_cmp_si;
   
   wire [0:3]     spare_unused;
   
   
   wire [0:162]   ex4_s;
   wire [53:161]  ex4_c;
   
   wire           ex4_flag_nan;
   wire           ex4_flag_gt;
   wire           ex4_flag_lt;
   wire           ex4_flag_eq;
   wire           ex4_sign_carry;
   
   wire           ex4_inc_all1;
   wire [1:6]     ex4_inc_byt_c_glb;
   wire [1:6]     ex4_inc_byt_c_glb_b;
   wire [0:52]    ex4_inc_p1;
   wire [0:52]    ex4_inc_p0;
   
   wire [53:162]  ex4_s_p0;
   wire [53:162]  ex4_s_p1;
   wire [0:162]   ex4_res;
   
   wire           ex3_effsub;
   wire           ex4_effsub;
   
   wire           ex3_effadd_npz;
   wire           ex3_effsub_npz;
   wire           ex4_effsub_npz;
   wire           ex4_effadd_npz;
   wire           ex4_flip_inc_p0;
   wire           ex4_flip_inc_p1;
   wire           ex4_inc_sel_p0;
   wire           ex4_inc_sel_p1;
   
   wire [0:162]   ex5_res;
   wire [0:162]   ex5_res_b;
   wire [0:162]   ex5_res_l2_b;
   wire           ex5_flag_nan_b;
   wire           ex5_flag_gt_b;
   wire           ex5_flag_lt_b;
   wire           ex5_flag_eq_b;
   wire [0:3]     ex5_fpcc_iu_b;
   wire           ex5_sign_carry_b;
   wire           ex5_sticky_b;
   
   wire [0:6]     ex4_g16;
   wire [0:6]     ex4_t16;
   wire [1:6]     ex4_g128;
   wire [1:6]     ex4_t128;
   wire [1:6]     ex4_g128_b;
   wire [1:6]     ex4_t128_b;
   wire [0:6]     ex4_inc_byt_c_b;
   wire [0:6]     ex4_eac_sel_p0n;
   wire [0:6]     ex4_eac_sel_p0;
   wire [0:6]     ex4_eac_sel_p1;
   wire           ex4_flag_nan_cp1;
   wire           ex4_flag_gt_cp1;
   wire           ex4_flag_lt_cp1;
   wire           ex4_flag_eq_cp1;
   wire           add_ex5_d1clk;
   wire           add_ex5_d2clk;
   wire [0:`NCLK_WIDTH-1]           add_ex5_lclk;
   
   wire [53:162]  ex4_s_p0n;
   wire [53:162]  ex4_res_p0n_b;
   wire [53:162]  ex4_res_p0_b;
   wire [53:162]  ex4_res_p1_b;
   wire [0:52]    ex4_inc_p0_x;
   wire [0:52]    ex4_inc_p1_x;
   wire [0:52]    ex4_incx_p0_b;
   wire [0:52]    ex4_incx_p1_b;
   wire [53:162]  ex4_sel_a1;
   wire [53:162]  ex4_sel_a2;
   wire [53:162]  ex4_sel_a3;
   
   
   
   
   
   
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
   assign ex3_effsub = (~f_alg_ex3_effsub_eac_b);
   assign ex3_effsub_npz = (~f_alg_ex3_effsub_eac_b) & (~f_alg_ex3_prod_z);
   assign ex3_effadd_npz = f_alg_ex3_effsub_eac_b & (~f_alg_ex3_prod_z);
   
   
   tri_rlmreg_p #(.WIDTH(9), .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),						       
      .delay_lclkr(delay_lclkr[3]),		
      .mpw1_b(mpw1_b[3]),		
      .mpw2_b(mpw2_b[0]),		
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scout(act_so),
      .scin(act_si),
      .din({  spare_unused[0],
              spare_unused[1],
              ex2_act,
              ex3_act,
              ex3_effsub,
              ex3_effsub_npz,
              ex3_effadd_npz,
              spare_unused[2],
              spare_unused[3]}),
      .dout({  spare_unused[0],
               spare_unused[1],
               ex3_act,
               ex4_act,
               ex4_effsub,
               ex4_effsub_npz,
               ex4_effadd_npz,
               spare_unused[2],
               spare_unused[3]})
   );
   
   
   tri_lcbnd  add_ex5_lcb(
      .delay_lclkr(delay_lclkr[4]),		
      .mpw1_b(mpw1_b[4]),	
      .mpw2_b(mpw2_b[0]),	
      .force_t(force_t),		
      .nclk(nclk),		
      .vd(vdd),		
      .gd(gnd),		
      .act(ex4_act),		
      .sg(sg_0),		
      .thold_b(thold_0_b),		
      .d1clk(add_ex5_d1clk),		
      .d2clk(add_ex5_d2clk),		
      .lclk(add_ex5_lclk)		
   );
   
   
   assign ex4_s[0:162] = f_sa3_ex4_s[0:162];
   assign ex4_c[53:161] = f_sa3_ex4_c[53:161];
   
   
   
   
   fu_add_all1 all1(
      .ex4_inc_byt_c_b(ex4_inc_byt_c_b[0:6]),		
      .ex4_inc_byt_c_glb(ex4_inc_byt_c_glb[1:6]),		
      .ex4_inc_byt_c_glb_b(ex4_inc_byt_c_glb_b[1:6]),		
      .ex4_inc_all1(ex4_inc_all1)		
   );
   
   
   
   fu_loc8inc_lsb inc8_6(
      .co_b(ex4_inc_byt_c_b[6]),		
      .x(ex4_s[48:52]),		
      .s0(ex4_inc_p0[48:52]),		
      .s1(ex4_inc_p1[48:52])		
   );
   
   
   fu_loc8inc inc8_5(
      .ci(ex4_inc_byt_c_glb[6]),		
      .ci_b(ex4_inc_byt_c_glb_b[6]),		
      .co_b(ex4_inc_byt_c_b[5]),		
      .x(ex4_s[40:47]),		
      .s0(ex4_inc_p0[40:47]),		
      .s1(ex4_inc_p1[40:47])		
   );
   
   
   fu_loc8inc inc8_4(
      .ci(ex4_inc_byt_c_glb[5]),		
      .ci_b(ex4_inc_byt_c_glb_b[5]),		
      .co_b(ex4_inc_byt_c_b[4]),		
      .x(ex4_s[32:39]),		
      .s0(ex4_inc_p0[32:39]),		
      .s1(ex4_inc_p1[32:39])		
   );
   
   
   fu_loc8inc inc8_3(
      .ci(ex4_inc_byt_c_glb[4]),		
      .ci_b(ex4_inc_byt_c_glb_b[4]),		
      .co_b(ex4_inc_byt_c_b[3]),		
      .x(ex4_s[24:31]),		
      .s0(ex4_inc_p0[24:31]),		
      .s1(ex4_inc_p1[24:31])		
   );
   
   
   fu_loc8inc inc8_2(
      .ci(ex4_inc_byt_c_glb[3]),		
      .ci_b(ex4_inc_byt_c_glb_b[3]),		
      .co_b(ex4_inc_byt_c_b[2]),		
      .x(ex4_s[16:23]),		
      .s0(ex4_inc_p0[16:23]),		
      .s1(ex4_inc_p1[16:23])		
   );
   
   
   fu_loc8inc inc8_1(
      .ci(ex4_inc_byt_c_glb[2]),		
      .ci_b(ex4_inc_byt_c_glb_b[2]),		
      .co_b(ex4_inc_byt_c_b[1]),		
      .x(ex4_s[8:15]),		
      .s0(ex4_inc_p0[8:15]),		
      .s1(ex4_inc_p1[8:15])		
   );
   
   
   fu_loc8inc inc8_0(
      .ci(ex4_inc_byt_c_glb[1]),		
      .ci_b(ex4_inc_byt_c_glb_b[1]),		
      .co_b(ex4_inc_byt_c_b[0]),		
      .x(ex4_s[0:7]),		
      .s0(ex4_inc_p0[0:7]),		
      .s1(ex4_inc_p1[0:7])		
   );
   
   
   
   
   
   fu_hc16pp_msb hc16_0(
      .x(ex4_s[53:68]),		
      .y(ex4_c[53:68]),		
      .ci0(ex4_g128[1]),		
      .ci0_b(ex4_g128_b[1]),		
      .ci1(ex4_t128[1]),		
      .ci1_b(ex4_t128_b[1]),		
      .s0(ex4_s_p0[53:68]),		
      .s1(ex4_s_p1[53:68]),		
      .g16(ex4_g16[0]),		
      .t16(ex4_t16[0])		
   );
   
   
   fu_hc16pp hc16_1(
      .x(ex4_s[69:84]),		
      .y(ex4_c[69:84]),		
      .ci0(ex4_g128[2]),		
      .ci0_b(ex4_g128_b[2]),		
      .ci1(ex4_t128[2]),		
      .ci1_b(ex4_t128_b[2]),		
      .s0(ex4_s_p0[69:84]),		
      .s1(ex4_s_p1[69:84]),		
      .g16(ex4_g16[1]),		
      .t16(ex4_t16[1])		
   );
   
   
   fu_hc16pp hc16_2(
      .x(ex4_s[85:100]),		
      .y(ex4_c[85:100]),		
      .ci0(ex4_g128[3]),		
      .ci0_b(ex4_g128_b[3]),		
      .ci1(ex4_t128[3]),		
      .ci1_b(ex4_t128_b[3]),		
      .s0(ex4_s_p0[85:100]),		
      .s1(ex4_s_p1[85:100]),		
      .g16(ex4_g16[2]),		
      .t16(ex4_t16[2])		
   );
   
   
   fu_hc16pp hc16_3(
      .x(ex4_s[101:116]),		
      .y(ex4_c[101:116]),		
      .ci0(ex4_g128[4]),		
      .ci0_b(ex4_g128_b[4]),		
      .ci1(ex4_t128[4]),		
      .ci1_b(ex4_t128_b[4]),		
      .s0(ex4_s_p0[101:116]),		
      .s1(ex4_s_p1[101:116]),		
      .g16(ex4_g16[3]),		
      .t16(ex4_t16[3])		
   );
   
   
   fu_hc16pp hc16_4(
      .x(ex4_s[117:132]),		
      .y(ex4_c[117:132]),		
      .ci0(ex4_g128[5]),		
      .ci0_b(ex4_g128_b[5]),		
      .ci1(ex4_t128[5]),		
      .ci1_b(ex4_t128_b[5]),		
      .s0(ex4_s_p0[117:132]),		
      .s1(ex4_s_p1[117:132]),		
      .g16(ex4_g16[4]),		
      .t16(ex4_t16[4])		
   );
   
   
   fu_hc16pp hc16_5(
      .x(ex4_s[133:148]),		
      .y(ex4_c[133:148]),		
      .ci0(ex4_g128[6]),		
      .ci0_b(ex4_g128_b[6]),		
      .ci1(ex4_t128[6]),		
      .ci1_b(ex4_t128_b[6]),		
      .s0(ex4_s_p0[133:148]),		
      .s1(ex4_s_p1[133:148]),		
      .g16(ex4_g16[5]),		
      .t16(ex4_t16[5])		
   );
   
   
   fu_hc16pp_lsb hc16_6(
      .x(ex4_s[149:162]),		
      .y(ex4_c[149:161]),		
      .s0(ex4_s_p0[149:162]),		
      .s1(ex4_s_p1[149:162]),		
      .g16(ex4_g16[6]),		
      .t16(ex4_t16[6])		
   );
   
   
   
   assign ex4_inc_p0_x[0:52] = ex4_inc_p0[0:52] ^ {53{ex4_flip_inc_p0}};
   assign ex4_inc_p1_x[0:52] = ex4_inc_p1[0:52] ^ {53{ex4_flip_inc_p1}};
   
   assign ex4_incx_p0_b[0:52] = (~({53{ex4_inc_sel_p0}} & ex4_inc_p0_x[0:52]));
   assign ex4_incx_p1_b[0:52] = (~({53{ex4_inc_sel_p1}} & ex4_inc_p1_x[0:52]));
   assign ex4_res[0:52] = (~(ex4_incx_p0_b[0:52] & ex4_incx_p1_b[0:52]));
   
   
   assign ex4_sel_a1[53:68] = {16{ex4_eac_sel_p0n[0]}};		
   assign ex4_sel_a1[69:84] = {16{ex4_eac_sel_p0n[1]}};		
   assign ex4_sel_a1[85:100] = {16{ex4_eac_sel_p0n[2]}};		
   assign ex4_sel_a1[101:116] = {16{ex4_eac_sel_p0n[3]}};		
   assign ex4_sel_a1[117:132] = {16{ex4_eac_sel_p0n[4]}};		
   assign ex4_sel_a1[133:148] = {16{ex4_eac_sel_p0n[5]}};		
   assign ex4_sel_a1[149:162] = {14{ex4_eac_sel_p0n[6]}};		
   
   assign ex4_sel_a2[53:68] = {16{ex4_eac_sel_p0[0]}};		
   assign ex4_sel_a2[69:84] = {16{ex4_eac_sel_p0[1]}};		
   assign ex4_sel_a2[85:100] = {16{ex4_eac_sel_p0[2]}};		
   assign ex4_sel_a2[101:116] = {16{ex4_eac_sel_p0[3]}};		
   assign ex4_sel_a2[117:132] = {16{ex4_eac_sel_p0[4]}};		
   assign ex4_sel_a2[133:148] = {16{ex4_eac_sel_p0[5]}};		
   assign ex4_sel_a2[149:162] = {14{ex4_eac_sel_p0[6]}};		
   
   assign ex4_sel_a3[53:68] = {16{ex4_eac_sel_p1[0]}};		
   assign ex4_sel_a3[69:84] = {16{ex4_eac_sel_p1[1]}};		
   assign ex4_sel_a3[85:100] = {16{ex4_eac_sel_p1[2]}};		
   assign ex4_sel_a3[101:116] = {16{ex4_eac_sel_p1[3]}};		
   assign ex4_sel_a3[117:132] = {16{ex4_eac_sel_p1[4]}};		
   assign ex4_sel_a3[133:148] = {16{ex4_eac_sel_p1[5]}};		
   assign ex4_sel_a3[149:162] = {14{ex4_eac_sel_p1[6]}};		
   
   assign ex4_s_p0n[53:162] = (~(ex4_s_p0[53:162]));
   assign ex4_res_p0n_b[53:162] = (~(ex4_sel_a1[53:162] & ex4_s_p0n[53:162]));
   assign ex4_res_p0_b[53:162] = (~(ex4_sel_a2[53:162] & ex4_s_p0[53:162]));
   assign ex4_res_p1_b[53:162] = (~(ex4_sel_a3[53:162] & ex4_s_p1[53:162]));
   assign ex4_res[53:162] = (~(ex4_res_p0n_b[53:162] & ex4_res_p0_b[53:162] & ex4_res_p1_b[53:162]));
   
   
   
   fu_add_glbc glbc(
      .ex4_g16(ex4_g16[0:6]),		
      .ex4_t16(ex4_t16[0:6]),		
      .ex4_inc_all1(ex4_inc_all1),		
      .ex4_effsub(ex4_effsub),		
      .ex4_effsub_npz(ex4_effsub_npz),		
      .ex4_effadd_npz(ex4_effadd_npz),		
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		
      .ex4_g128(ex4_g128[1:6]),		
      .ex4_g128_b(ex4_g128_b[1:6]),		
      .ex4_t128(ex4_t128[1:6]),		
      .ex4_t128_b(ex4_t128_b[1:6]),		
      .ex4_flip_inc_p0(ex4_flip_inc_p0),		
      .ex4_flip_inc_p1(ex4_flip_inc_p1),		
      .ex4_inc_sel_p0(ex4_inc_sel_p0),		
      .ex4_inc_sel_p1(ex4_inc_sel_p1),		
      .ex4_eac_sel_p0n(ex4_eac_sel_p0n),		
      .ex4_eac_sel_p0(ex4_eac_sel_p0),		
      .ex4_eac_sel_p1(ex4_eac_sel_p1),		
      .ex4_sign_carry(ex4_sign_carry),		
      .ex4_flag_nan_cp1(ex4_flag_nan_cp1),		
      .ex4_flag_gt_cp1(ex4_flag_gt_cp1),		
      .ex4_flag_lt_cp1(ex4_flag_lt_cp1),		
      .ex4_flag_eq_cp1(ex4_flag_eq_cp1),		
      .ex4_flag_nan(ex4_flag_nan),		
      .ex4_flag_gt(ex4_flag_gt),		
      .ex4_flag_lt(ex4_flag_lt),		
      .ex4_flag_eq(ex4_flag_eq)		
   );
   
   
   
   tri_inv_nlats #(.WIDTH(53),   .NEEDS_SRESET(0)) ex5_res_hi_lat( 
      .vd(vdd),
      .gd(gnd),							       
      .lclk(add_ex5_lclk),		
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_res_si[0:52]),
      .scanout(ex5_res_so[0:52]),
      .d(ex4_res[0:52]),
      .qb(ex5_res_l2_b[0:52])		
   );
   
   
   tri_inv_nlats #(.WIDTH(110),  .NEEDS_SRESET(0)) ex5_res_lo_lat( 
      .vd(vdd),
      .gd(gnd),							       
      .lclk(add_ex5_lclk),		
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_res_si[53:162]),
      .scanout(ex5_res_so[53:162]),
      .d(ex4_res[53:162]),
      .qb(ex5_res_l2_b[53:162])		
   );
   
   assign ex5_res[0:162] = (~ex5_res_l2_b[0:162]);
   assign ex5_res_b[0:162] = (~ex5_res[0:162]);
   assign f_add_ex5_res[0:162] = (~ex5_res_b[0:162]);		
   
   
   tri_inv_nlats #(.WIDTH(10),  .NEEDS_SRESET(0)) ex5_cmp_lat( 
      .vd(vdd),
      .gd(gnd),							       
      .lclk(add_ex5_lclk),		
      .d1clk(add_ex5_d1clk),
      .d2clk(add_ex5_d2clk),
      .scanin(ex5_cmp_si),
      .scanout(ex5_cmp_so),
      .d({  ex4_flag_lt,
            ex4_flag_lt_cp1,
            ex4_flag_gt,
            ex4_flag_gt_cp1,
            ex4_flag_eq,
            ex4_flag_eq_cp1,
            ex4_flag_nan,
            ex4_flag_nan_cp1,
            ex4_sign_carry,
            f_alg_ex4_sticky}),
      .qb({  ex5_flag_lt_b,		
             ex5_fpcc_iu_b[0],		
             ex5_flag_gt_b,		
             ex5_fpcc_iu_b[1],		
             ex5_flag_eq_b,		
             ex5_fpcc_iu_b[2],		
             ex5_flag_nan_b,		
             ex5_fpcc_iu_b[3],		
             ex5_sign_carry_b,		
             ex5_sticky_b})		
   );
   
   assign f_add_ex5_flag_nan = (~ex5_flag_nan_b);		
   assign f_add_ex5_flag_gt = (~ex5_flag_gt_b);		
   assign f_add_ex5_flag_lt = (~ex5_flag_lt_b);		
   assign f_add_ex5_flag_eq = (~ex5_flag_eq_b);		
   assign f_add_ex5_fpcc_iu[0:3] = (~ex5_fpcc_iu_b[0:3]);		
   assign f_add_ex5_sign_carry = (~ex5_sign_carry_b);		
   assign f_add_ex5_sticky = (~ex5_sticky_b);		
   
   assign f_add_ex5_to_int_ovf_wd[0] = ex5_res[130];		
   assign f_add_ex5_to_int_ovf_wd[1] = ex5_res[131];		
   assign f_add_ex5_to_int_ovf_dw[0] = ex5_res[98];		
   assign f_add_ex5_to_int_ovf_dw[1] = ex5_res[99];		
   
   
   
   assign act_si[0:8] = {act_so[1:8], f_add_si};
   assign ex5_res_si[0:162] = {ex5_res_so[1:162], act_so[0]};
   assign ex5_cmp_si[0:9] = {ex5_cmp_so[1:9], ex5_res_so[0]};
   assign f_add_so = ex5_cmp_so[0];
   
endmodule
