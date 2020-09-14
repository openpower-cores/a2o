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
   

module fu_fmt(
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
   f_fmt_si,
   f_fmt_so,
   ex1_act,
   ex2_act,
   f_dcd_ex2_perr_force_c,    
   f_dcd_ex2_perr_fsel_ovrd,  
   f_pic_ex2_ftdiv,           
   f_fmt_ex3_be_den,          
   f_byp_fmt_ex2_a_sign,
   f_byp_fmt_ex2_c_sign,
   f_byp_fmt_ex2_b_sign,
   f_byp_fmt_ex2_a_expo,
   f_byp_fmt_ex2_c_expo,
   f_byp_fmt_ex2_b_expo,
   f_byp_fmt_ex2_a_frac,
   f_byp_fmt_ex2_c_frac,
   f_byp_fmt_ex2_b_frac,
   f_dcd_ex1_aop_valid,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_fsel_b,
   f_dcd_ex1_force_pass_b,
   f_dcd_ex1_sp,
   f_pic_ex2_flush_en_sp,
   f_pic_ex2_flush_en_dp,
   f_pic_ex2_nj_deni,
   f_dcd_ex1_uc_end,
   f_dcd_ex1_uc_mid,
   f_dcd_ex1_uc_special,
   f_dcd_ex1_sgncpy_b,
   f_dcd_ex2_divsqrt_v,
   f_fmt_ex3_lu_den_recip,
   f_fmt_ex3_lu_den_rsqrto,
   f_fmt_ex2_bop_byt,
   f_fmt_ex2_a_zero,
   f_fmt_ex2_a_zero_dsq,
   f_fmt_ex2_a_expo_max,
   f_fmt_ex2_a_expo_max_dsq,
   f_fmt_ex2_a_frac_zero,
   f_fmt_ex2_a_frac_msb,
   f_fmt_ex2_c_zero,
   f_fmt_ex2_c_expo_max,
   f_fmt_ex2_c_frac_zero,
   f_fmt_ex2_c_frac_msb,
   f_fmt_ex2_b_zero,
   f_fmt_ex2_b_zero_dsq,
   f_fmt_ex2_b_expo_max,
   f_fmt_ex2_b_expo_max_dsq,
   f_fmt_ex2_b_frac_zero,
   f_fmt_ex2_b_frac_msb,
   f_fmt_ex2_b_imp,
   f_fmt_ex2_b_frac_z32,
   f_fmt_ex2_prod_zero,
   f_fmt_ex2_pass_sel,
   f_fmt_ex2_sp_invalid,
   f_fmt_ex2_bexpu_le126,
   f_fmt_ex2_gt126,
   f_fmt_ex2_ge128,
   f_fmt_ex2_inf_and_beyond_sp,
   f_mad_ex3_uc_a_expo_den,
   f_mad_ex3_uc_a_expo_den_sp,
   f_ex3_b_den_flush,
   f_fmt_ex3_fsel_bsel,
   f_fmt_ex3_pass_sign,
   f_fmt_ex3_pass_msb,
   f_fmt_ex2_b_frac,
   f_fmt_ex2_b_sign_gst,
   f_fmt_ex2_b_expo_gst_b,
   f_fmt_ex2_a_sign_div,
   f_fmt_ex2_a_expo_div_b,
   f_fmt_ex2_a_frac_div,
   f_fmt_ex2_b_sign_div,
   f_fmt_ex2_b_expo_div_b,
   f_fmt_ex2_b_frac_div,
   f_fpr_ex2_a_par,
   f_fpr_ex2_c_par,
   f_fpr_ex2_b_par,
   f_mad_ex3_a_parity_check,
   f_mad_ex3_c_parity_check,
   f_mad_ex3_b_parity_check,
   f_fmt_ex3_ae_ge_54,
   f_fmt_ex3_be_ge_54,
   f_fmt_ex3_be_ge_2,
   f_fmt_ex3_be_ge_2044,
   f_fmt_ex3_tdiv_rng_chk,
   f_fmt_ex3_pass_frac
);
   inout          vdd;
   inout          gnd;
   input          clkoff_b;		
   input          act_dis;		
   input          flush;		
   input [1:2]    delay_lclkr;		
   input [1:2]    mpw1_b;		
   input [0:0]    mpw2_b;		
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		
   input  [0:`NCLK_WIDTH-1]         nclk;
   
   input          f_fmt_si;		
   output         f_fmt_so;		
   
   input          ex1_act;   
   input          ex2_act;   
   input          f_dcd_ex2_perr_force_c;    
   input          f_dcd_ex2_perr_fsel_ovrd;  
   input          f_pic_ex2_ftdiv;           
   output         f_fmt_ex3_be_den;          
   input          f_byp_fmt_ex2_a_sign;
   input          f_byp_fmt_ex2_c_sign;
   input          f_byp_fmt_ex2_b_sign;
   input [1:13]   f_byp_fmt_ex2_a_expo;
   input [1:13]   f_byp_fmt_ex2_c_expo;
   input [1:13]   f_byp_fmt_ex2_b_expo;
   input [0:52]   f_byp_fmt_ex2_a_frac;
   input [0:52]   f_byp_fmt_ex2_c_frac;
   input [0:52]   f_byp_fmt_ex2_b_frac;
   
   input          f_dcd_ex1_aop_valid;
   input          f_dcd_ex1_cop_valid;
   input          f_dcd_ex1_bop_valid;
   input          f_dcd_ex1_from_integer_b;		
   input          f_dcd_ex1_fsel_b;		
   input          f_dcd_ex1_force_pass_b;		
   
   input          f_dcd_ex1_sp;
   
   input          f_pic_ex2_flush_en_sp;
   input          f_pic_ex2_flush_en_dp;
   
   input          f_pic_ex2_nj_deni;
   input          f_dcd_ex1_uc_end;
   input          f_dcd_ex1_uc_mid;		
   input          f_dcd_ex1_uc_special;
   input          f_dcd_ex1_sgncpy_b;
   input          f_dcd_ex2_divsqrt_v;
   output         f_fmt_ex3_lu_den_recip;		
   output         f_fmt_ex3_lu_den_rsqrto;		
   
   output [45:52] f_fmt_ex2_bop_byt;		
   
   output         f_fmt_ex2_a_zero;		
   output         f_fmt_ex2_a_zero_dsq;		
   
   output         f_fmt_ex2_a_expo_max;		
   output         f_fmt_ex2_a_expo_max_dsq;		
   output         f_fmt_ex2_a_frac_zero;		
   output         f_fmt_ex2_a_frac_msb;		
   
   output         f_fmt_ex2_c_zero;		
   output         f_fmt_ex2_c_expo_max;		
   output         f_fmt_ex2_c_frac_zero;		
   output         f_fmt_ex2_c_frac_msb;		
   
   output         f_fmt_ex2_b_zero;		
   output         f_fmt_ex2_b_zero_dsq;		
   
   output         f_fmt_ex2_b_expo_max;		
   output         f_fmt_ex2_b_expo_max_dsq;		
   
   output         f_fmt_ex2_b_frac_zero;		
   output         f_fmt_ex2_b_frac_msb;		
   output         f_fmt_ex2_b_imp;		
   output         f_fmt_ex2_b_frac_z32;		
   
   output         f_fmt_ex2_prod_zero;		
   output         f_fmt_ex2_pass_sel;		
   
   output         f_fmt_ex2_sp_invalid;		
   output         f_fmt_ex2_bexpu_le126;		
   output         f_fmt_ex2_gt126;		
   output         f_fmt_ex2_ge128;		
   output         f_fmt_ex2_inf_and_beyond_sp;		
   
   output         f_mad_ex3_uc_a_expo_den;		
   output         f_mad_ex3_uc_a_expo_den_sp;		
   
   output         f_ex3_b_den_flush;		
   
   output         f_fmt_ex3_fsel_bsel;		
   output         f_fmt_ex3_pass_sign;		
   output         f_fmt_ex3_pass_msb;		
   output [1:19]  f_fmt_ex2_b_frac;		
   output         f_fmt_ex2_b_sign_gst;
   output [1:13]  f_fmt_ex2_b_expo_gst_b;
   
   output         f_fmt_ex2_a_sign_div;
   output [01:13] f_fmt_ex2_a_expo_div_b;
   output [01:52] f_fmt_ex2_a_frac_div;
   
   output         f_fmt_ex2_b_sign_div;
   output [01:13] f_fmt_ex2_b_expo_div_b;
   output [01:52] f_fmt_ex2_b_frac_div;
   
   input [0:7]    f_fpr_ex2_a_par;		
   input [0:7]    f_fpr_ex2_c_par;		
   input [0:7]    f_fpr_ex2_b_par;		
   output         f_mad_ex3_a_parity_check;		
   output         f_mad_ex3_c_parity_check;		
   output         f_mad_ex3_b_parity_check;		
   
   output         f_fmt_ex3_ae_ge_54;		
   output         f_fmt_ex3_be_ge_54;		
   output         f_fmt_ex3_be_ge_2;		
   output         f_fmt_ex3_be_ge_2044;		
   output         f_fmt_ex3_tdiv_rng_chk;		
   output [0:52]  f_fmt_ex3_pass_frac;		
   
   
   
   
   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;
   
   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;
   wire           sg_0;


  (* analysis_not_referenced="TRUE" *) 
   wire [0:3]     spare_unused;
   wire [0:6]     act_si;		
   wire [0:6]     act_so;		
   
   wire [0:8]     ex2_ctl_si;		
   wire [0:8]     ex2_ctl_so;		
   wire [0:79]    ex3_pass_si;		
   wire [0:79]    ex3_pass_so;		
   wire [0:52]    ex3_pass_frac;
   wire           ex2_from_integer;
   wire           ex2_fsel;
   wire           ex2_force_pass;
   wire           ex2_a_sign;
   wire           ex2_c_sign;
   wire           ex2_b_sign;
   wire           ex3_fsel_bsel;
   wire           ex3_pass_sign;
   wire [0:52]    ex2_a_frac;
   wire [0:52]    ex2_c_frac;
   wire [0:52]    ex2_b_frac;
   wire [0:52]    ex2_pass_frac_ac;
   wire [0:52]    ex2_pass_frac;
   wire           ex2_a_frac_msb;
   wire           ex2_a_expo_min;
   wire           ex2_a_expo_max;
   wire           ex2_a_expo_max_dsq;
   wire           ex2_a_frac_zero;
   wire           ex2_c_frac_msb;
   wire           ex2_c_expo_min;
   wire           ex2_c_expo_max;
   wire           ex2_c_frac_zero;
   wire           ex2_b_frac_msb;
   wire           ex2_b_expo_min;
   wire           ex2_b_expo_max;
   wire           ex2_b_expo_max_dsq;
   wire           ex2_b_frac_zero;
   wire           ex2_b_frac_z32;
   wire           ex2_a_nan;
   wire           ex2_c_nan;
   wire           ex2_b_nan;
   wire           ex2_nan_pass;
   wire           ex2_pass_sel;
   wire           ex2_fsel_cif;
   wire           ex2_fsel_bsel;
   wire           ex2_mux_a_sel;
   wire           ex2_mux_c_sel;
   wire           ex2_pass_sign_ac;
   wire           ex2_pass_sign;
   wire [1:13]    ex2_a_expo;
   wire [1:13]    ex2_b_expo;
   wire [1:13]    ex2_c_expo;
   wire [1:13]    ex2_a_expo_b;
   wire [1:13]    ex2_c_expo_b;
   wire [1:13]    ex2_b_expo_b;
   wire           ex1_aop_valid_b;
   wire           ex1_cop_valid_b;
   wire           ex1_bop_valid_b;
   wire           ex2_aop_valid;
   wire           ex2_cop_valid;
   wire           ex2_bop_valid;
   wire           ex2_a_zero;
   wire           ex2_c_zero;
   wire           ex2_b_zero;
   wire           ex2_a_zero_x;
   wire           ex2_c_zero_x;
   wire           ex2_b_zero_x;
   wire           ex2_a_sp_expo_ok_1;
   wire           ex2_c_sp_expo_ok_1;
   wire           ex2_b_sp_expo_ok_1;
   wire           ex2_a_sp_expo_ok_2;
   wire           ex2_c_sp_expo_ok_2;
   wire           ex2_b_sp_expo_ok_2;
   wire           ex2_a_sp_expo_ok_3;
   wire           ex2_c_sp_expo_ok_3;
   wire           ex2_b_sp_expo_ok_3;
   wire           ex2_a_sp_expo_ok_4;
   wire           ex2_c_sp_expo_ok_4;
   wire           ex2_b_sp_expo_ok_4;
   wire [0:52]    ex3_pass_dp;
   wire           ex2_from_integer_b;
   wire           ex2_fsel_b;
   wire           ex2_aop_valid_b;
   wire           ex2_cop_valid_b;
   wire           ex2_bop_valid_b;
   wire           ex2_b_den_flush;
   wire           ex2_b_den_sp;
   wire           ex2_b_den_dp;
   wire           ex2_a_den_sp;
   wire           ex2_be_den;
   wire           ex3_be_den;  
   wire           ex3_b_den_flush;
   wire           ex2_a_den_flush;
   wire           ex2_a_den_sp_ftdiv;
   wire           ex2_a_den_dp;
   
   wire           ex2_lu_den_part;
   wire           ex2_lu_den_recip;
   wire           ex2_lu_den_rsqrto;
   wire           ex3_lu_den_recip;
   wire           ex3_lu_den_rsqrto;
   wire           ex2_recip_lo;
   wire           ex2_rsqrt_lo;
   wire           ex2_bfrac_eq_126;
   wire           ex2_bfrac_126_nz;
   wire           ex2_bexpo_ge897_hi;
   wire           ex2_bexpo_ge897_mid1;
   wire           ex2_bexpo_ge897_mid2;
   wire           ex2_bexpo_ge897_lo;
   wire           ex2_bexpo_ge897;
   wire           ex2_bexpu_eq6;
   wire           ex2_bexpu_ge7;
   wire           ex2_bexpu_ge7_lo;
   wire           ex2_bexpu_ge7_mid;
   wire           ex2_a_sp;
   wire           ex2_c_sp;
   wire           ex2_b_sp;
   wire           ex2_b_frac_zero_sp;
   wire           ex2_b_frac_zero_dp;
   wire           ex2_a_denz;
   wire           ex2_c_denz;
   wire           ex2_b_denz;
   wire [0:52]    ex2_a_frac_chop;
   wire [0:52]    ex2_c_frac_chop;
   wire [0:52]    ex2_b_frac_chop;
   
   wire           ex1_sgncpy;
   wire           ex2_sgncpy;
   wire           ex2_uc_mid;
   wire           ex1_force_pass;
   wire           ex1_uc_end_nspec;
   wire           ex1_uc_end_spec;
   wire           ex2_uc_end_nspec;
   wire           ex2_uc_a_expo_den;
   wire           ex3_uc_a_expo_den;
   wire           ex2_uc_a_expo_den_sp;
   wire           ex3_uc_a_expo_den_sp;
   
   wire           ex2_a_expo_ltx381_sp;
   wire           ex2_a_expo_ltx381;
   wire           ex2_a_expo_00xx_xxxx_xxxx;
   wire           ex2_a_expo_xx11_1xxx_xxxx;
   wire           ex2_a_expo_xxxx_x000_0000;
   wire           ex2_c_expo_ltx381_sp;
   wire           ex2_c_expo_ltx381;
   wire           ex2_c_expo_00xx_xxxx_xxxx;
   wire           ex2_c_expo_xx11_1xxx_xxxx;
   wire           ex2_c_expo_xxxx_x000_0000;
   wire           ex2_b_expo_ltx381_sp;
   wire           ex2_b_expo_ltx381;
   wire           ex2_b_expo_00xx_xxxx_xxxx;
   wire           ex2_b_expo_xx11_1xxx_xxxx;
   wire           ex2_b_expo_xxxx_x000_0000;
   wire           ex2_a_expo_ltx36A_sp;
   wire           ex2_b_expo_ltx36A_sp;
   
   wire           ex2_a_sp_inf_alias_tail;
   wire           ex2_c_sp_inf_alias_tail;
   wire           ex2_b_sp_inf_alias_tail;
   wire           ex3_a_party_chick;
   wire           ex3_c_party_chick;
   wire           ex3_b_party_chick;
   wire           ex2_a_party_chick;
   wire           ex2_c_party_chick;
   wire           ex2_b_party_chick;
   wire [0:7]     ex2_a_party;
   wire [0:7]     ex2_c_party;
   wire [0:7]     ex2_b_party;
   wire           ex2_b_expo_ge1151;
   wire           ex2_ae_234567;
   wire           ex2_ae_89;
   wire           ex2_ae_abc;
   wire           ex2_ae_ge_54;
   wire           ex3_ae_ge_54;
   wire           ex2_be_234567;
   wire           ex2_be_89;
   wire           ex2_be_abc;
   wire           ex2_be_ge_54;
   wire           ex3_be_ge_54;
   wire           ex2_be_ge_2;
   wire           ex3_be_ge_2;
   wire           ex2_be_or_23456789abc;
   wire           ex2_be_ge_2044;
   wire           ex3_be_ge_2044;
   wire           ex2_be_and_3456789ab;
   wire [0:12]    ex2_aembex_car_b;
   wire [0:12]    ex2_aembey_car_b;
   wire [1:13]    ex2_aembex_sum_b;
   wire [1:13]    ex2_aembey_sum_b;
   wire [2:12]    ex2_aembex_g1;
   wire [2:12]    ex2_aembey_g1;
   wire [2:12]    ex2_aembex_t1;
   wire [2:12]    ex2_aembey_t1;
   wire [0:5]     ex2_aembex_g2;
   wire [0:5]     ex2_aembey_g2;
   wire [0:4]     ex2_aembex_t2;
   wire [0:4]     ex2_aembey_t2;
   wire [0:2]     ex2_aembex_g4;
   wire [0:2]     ex2_aembey_g4;
   wire [0:1]     ex2_aembex_t4;
   wire [0:1]     ex2_aembey_t4;
   wire [0:2]     ex3_aembex_g4;
   wire [0:2]     ex3_aembey_g4;
   wire [0:1]     ex3_aembex_t4;
   wire [0:1]     ex3_aembey_t4;
   wire [0:1]     ex3_aembex_g8;
   wire [0:1]     ex3_aembey_g8;
   wire [0:0]     ex3_aembex_t8;
   wire [0:0]     ex3_aembey_t8;
   wire           ex3_aembex_c2;
   wire           ex3_aembey_c2;
   wire           ex2_aembex_sgn;
   wire           ex2_aembey_sgn;
   wire           ex3_aembex_sgn;
   wire           ex3_aembey_sgn;
   wire           ex3_aembex_res_sgn;
   wire           ex3_aembey_res_sgn;
   (* analysis_not_referenced="TRUE" *) 
   wire           unused;
   wire           ex2_divsqrt;
   
   
   assign unused = ex2_aembex_car_b[0] | ex2_aembex_sum_b[13] | ex2_aembex_t1[12] | ex2_aembey_car_b[0] | ex2_aembey_sum_b[13] | ex2_aembey_t1[12];
   
   
   
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
   
   

   
   tri_rlmreg_p #(.WIDTH(7),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),		
      .d_mode(tiup),							
      .delay_lclkr(delay_lclkr[1]),		
      .mpw1_b(mpw1_b[1]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fpu_enable),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      .din({  spare_unused[0],
              spare_unused[1],
              f_dcd_ex1_sp,
              f_dcd_ex1_sp,
              f_dcd_ex1_sp,
              spare_unused[2],
              spare_unused[3]}),
      .dout({ spare_unused[0],
              spare_unused[1],
              ex2_a_sp,
              ex2_c_sp,
              ex2_b_sp,
              spare_unused[2],
              spare_unused[3]})
   );
   
   
   assign ex1_aop_valid_b = (~f_dcd_ex1_aop_valid);
   assign ex1_cop_valid_b = (~f_dcd_ex1_cop_valid);
   assign ex1_bop_valid_b = (~f_dcd_ex1_bop_valid);
   
   
   assign ex2_a_frac[0:52] = f_byp_fmt_ex2_a_frac[0:52];
   assign ex2_c_frac[0:52] = f_byp_fmt_ex2_c_frac[0:52];
   assign ex2_b_frac[0:52] = f_byp_fmt_ex2_b_frac[0:52];
   
   assign ex2_a_sign = f_byp_fmt_ex2_a_sign;		
   assign ex2_c_sign = f_byp_fmt_ex2_c_sign;		
   assign ex2_b_sign = f_byp_fmt_ex2_b_sign;		
   
   assign ex2_a_expo[1:13] = f_byp_fmt_ex2_a_expo[1:13];		
   assign ex2_c_expo[1:13] = f_byp_fmt_ex2_c_expo[1:13];		
   assign ex2_b_expo[1:13] = f_byp_fmt_ex2_b_expo[1:13];		
   
   assign ex2_a_expo_b[1:13] = (~ex2_a_expo[1:13]);
   assign ex2_c_expo_b[1:13] = (~ex2_c_expo[1:13]);
   assign ex2_b_expo_b[1:13] = (~ex2_b_expo[1:13]);
   
   assign f_fmt_ex2_b_sign_gst = ex2_b_sign;
   
   assign ex1_sgncpy = (~f_dcd_ex1_sgncpy_b);
   assign ex1_uc_end_nspec = f_dcd_ex1_uc_end & (~f_dcd_ex1_uc_special);
   assign ex1_uc_end_spec = f_dcd_ex1_uc_end & f_dcd_ex1_uc_special;
   assign ex1_force_pass = ((~f_dcd_ex1_force_pass_b)) | ex1_uc_end_spec;
   
   
   tri_rlmreg_p #(.WIDTH(9),  .NEEDS_SRESET(0)) ex2_ctl_lat(
      .force_t(force_t),		
      .d_mode(tiup),							
      .delay_lclkr(delay_lclkr[1]),		
      .mpw1_b(mpw1_b[1]),		
      .mpw2_b(mpw2_b[0]),		
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ex1_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex2_ctl_so),
      .scin(ex2_ctl_si),
      .din({  f_dcd_ex1_from_integer_b,
              f_dcd_ex1_fsel_b,
              ex1_force_pass,
              ex1_aop_valid_b,
              ex1_cop_valid_b,
              ex1_bop_valid_b,
              ex1_sgncpy,
              ex1_uc_end_nspec,
              f_dcd_ex1_uc_mid}),
      .dout({ ex2_from_integer_b,
              ex2_fsel_b,
              ex2_force_pass,
              ex2_aop_valid_b,
              ex2_cop_valid_b,
              ex2_bop_valid_b,
              ex2_sgncpy,
              ex2_uc_end_nspec,
              ex2_uc_mid})
   );
   
   assign ex2_from_integer = (~ex2_from_integer_b);
   assign ex2_fsel = (~ex2_fsel_b);
   assign ex2_aop_valid = (~ex2_aop_valid_b);
   assign ex2_cop_valid = (~ex2_cop_valid_b);
   assign ex2_bop_valid = (~ex2_bop_valid_b);
   
   assign f_fmt_ex2_bop_byt[45:52] = ex2_b_frac[45:52];		
   
   
   assign f_fmt_ex2_b_expo_gst_b[1:13] = (~ex2_b_expo[1:13]);
   
   assign ex2_bexpo_ge897_hi = (~ex2_b_expo[1]) & ex2_b_frac[0];		
   assign ex2_bexpo_ge897_mid1 = ex2_b_expo[2] | ex2_b_expo[3];
   assign ex2_bexpo_ge897_mid2 = ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6];
   assign ex2_bexpo_ge897_lo = ex2_b_expo[7] | ex2_b_expo[8] | ex2_b_expo[9] | ex2_b_expo[10] | ex2_b_expo[11] | ex2_b_expo[12] | ex2_b_expo[13];		
   
   assign ex2_bexpo_ge897 = (ex2_bexpo_ge897_hi & ex2_bexpo_ge897_mid1) | (ex2_bexpo_ge897_hi & ex2_bexpo_ge897_mid2 & ex2_bexpo_ge897_lo);
   
   assign ex2_bexpu_ge7_mid = ex2_b_expo[4] | ex2_b_expo[5] | ex2_b_expo[6] | ex2_b_expo[7] | ex2_b_expo[8] | ex2_b_expo[9] | ex2_b_expo[10];
   assign ex2_bexpu_ge7_lo = ex2_b_expo[11] & ex2_b_expo[12];
   
   assign ex2_bexpu_ge7 = ((~ex2_b_expo[1]) & ex2_b_expo[2]) | ((~ex2_b_expo[1]) & ex2_b_expo[3] & ex2_bexpu_ge7_mid) | ((~ex2_b_expo[1]) & ex2_b_expo[3] & ex2_bexpu_ge7_lo);
   
   assign ex2_bexpu_eq6 = (~ex2_b_expo[1]) & (~ex2_b_expo[2]) & ex2_b_expo[3] & (~ex2_b_expo[4]) & (~ex2_b_expo[5]) & (~ex2_b_expo[6]) & (~ex2_b_expo[7]) & (~ex2_b_expo[8]) & (~ex2_b_expo[9]) & (~ex2_b_expo[10]) & ex2_b_expo[11] & (~ex2_b_expo[12]) & ex2_b_expo[13];		
   
   assign f_fmt_ex2_bexpu_le126 = (~ex2_bexpo_ge897);		
   assign f_fmt_ex2_gt126 = ex2_bexpu_ge7 | (ex2_bexpu_eq6 & ex2_bfrac_eq_126 & ex2_bfrac_126_nz);		
   assign f_fmt_ex2_ge128 = ex2_bexpu_ge7;		
   
   assign ex2_b_expo_ge1151 = (ex2_b_expo_b[1] & (~ex2_b_expo_b[2])) | (ex2_b_expo_b[1] & (~ex2_b_expo_b[3]) & (~ex2_b_expo_b[4])) | (ex2_b_expo_b[1] & (~ex2_b_expo_b[3]) & (~ex2_b_expo_b[5])) | (ex2_b_expo_b[1] & (~ex2_b_expo_b[3]) & (~ex2_b_expo_b[6])) | (ex2_b_expo_b[1] & (~ex2_b_expo_b[3]) & (~ex2_b_expo_b[7]) & (~ex2_b_expo_b[8]) & (~ex2_b_expo_b[9]) & (~ex2_b_expo_b[10]) & (~ex2_b_expo_b[11]) & (~ex2_b_expo_b[12]) & (~ex2_b_expo_b[13]));		
   
   assign f_fmt_ex2_inf_and_beyond_sp = ex2_b_expo_max | ex2_b_expo_ge1151;
   
   assign ex2_bfrac_eq_126 = ex2_b_frac[0] & ex2_b_frac[1] & ex2_b_frac[2] & ex2_b_frac[3] & ex2_b_frac[4] & ex2_b_frac[5];		
   
   assign ex2_bfrac_126_nz = ex2_b_frac[6] | ex2_b_frac[7] | ex2_b_frac[8] | ex2_b_frac[9] | ex2_b_frac[10] | ex2_b_frac[11] | ex2_b_frac[12] | ex2_b_frac[13] | ex2_b_frac[14] | ex2_b_frac[15] | ex2_b_frac[16] | ex2_b_frac[17] | ex2_b_frac[18] | ex2_b_frac[19] | ex2_b_frac[20] | ex2_b_frac[21] | ex2_b_frac[22] | ex2_b_frac[23];
   
   
   assign ex2_a_frac_msb = ex2_a_frac[1];
   assign ex2_c_frac_msb = ex2_c_frac[1];
   assign ex2_b_frac_msb = ex2_b_frac[1];
   
   assign ex2_a_expo_min = (~ex2_a_frac[0]);		
   assign ex2_c_expo_min = (~ex2_c_frac[0]);
   assign ex2_b_expo_min = (~ex2_b_frac[0]);
   
   assign ex2_a_expo_max = ex2_a_expo_b[1] & ex2_a_expo_b[2] & (~ex2_a_expo_b[3]) & (~ex2_a_expo_b[4]) & (~ex2_a_expo_b[5]) & (~ex2_a_expo_b[6]) & (~ex2_a_expo_b[7]) & (~ex2_a_expo_b[8]) & (~ex2_a_expo_b[9]) & (~ex2_a_expo_b[10]) & (~ex2_a_expo_b[11]) & (~ex2_a_expo_b[12]) & (~ex2_a_expo_b[13]);
   
   assign ex2_c_expo_max = ex2_c_expo_b[1] & ex2_c_expo_b[2] & (~ex2_c_expo_b[3]) & (~ex2_c_expo_b[4]) & (~ex2_c_expo_b[5]) & (~ex2_c_expo_b[6]) & (~ex2_c_expo_b[7]) & (~ex2_c_expo_b[8]) & (~ex2_c_expo_b[9]) & (~ex2_c_expo_b[10]) & (~ex2_c_expo_b[11]) & (~ex2_c_expo_b[12]) & (~ex2_c_expo_b[13]);
   
   assign ex2_b_expo_max = ex2_b_expo_b[1] & ex2_b_expo_b[2] & (~ex2_b_expo_b[3]) & (~ex2_b_expo_b[4]) & (~ex2_b_expo_b[5]) & (~ex2_b_expo_b[6]) & (~ex2_b_expo_b[7]) & (~ex2_b_expo_b[8]) & (~ex2_b_expo_b[9]) & (~ex2_b_expo_b[10]) & (~ex2_b_expo_b[11]) & (~ex2_b_expo_b[12]) & (~ex2_b_expo_b[13]);
   
   assign ex2_a_frac_zero = (~ex2_a_frac[1]) & (~ex2_a_frac[2]) & (~ex2_a_frac[3]) & (~ex2_a_frac[4]) & (~ex2_a_frac[5]) & (~ex2_a_frac[6]) & (~ex2_a_frac[7]) & (~ex2_a_frac[8]) & (~ex2_a_frac[9]) & (~ex2_a_frac[10]) & (~ex2_a_frac[11]) & (~ex2_a_frac[12]) & (~ex2_a_frac[13]) & (~ex2_a_frac[14]) & (~ex2_a_frac[15]) & (~ex2_a_frac[16]) & (~ex2_a_frac[17]) & (~ex2_a_frac[18]) & (~ex2_a_frac[19]) & (~ex2_a_frac[20]) & (~ex2_a_frac[21]) & (~ex2_a_frac[22]) & (~ex2_a_frac[23]) & (~ex2_a_frac[24]) & (~ex2_a_frac[25]) & (~ex2_a_frac[26]) & (~ex2_a_frac[27]) & (~ex2_a_frac[28]) & (~ex2_a_frac[29]) & (~ex2_a_frac[30]) & (~ex2_a_frac[31]) & (~ex2_a_frac[32]) & (~ex2_a_frac[33]) & (~ex2_a_frac[34]) & (~ex2_a_frac[35]) & (~ex2_a_frac[36]) & (~ex2_a_frac[37]) & (~ex2_a_frac[38]) & (~ex2_a_frac[39]) & (~ex2_a_frac[40]) & (~ex2_a_frac[41]) & (~ex2_a_frac[42]) & (~ex2_a_frac[43]) & (~ex2_a_frac[44]) & (~ex2_a_frac[45]) & (~ex2_a_frac[46]) & (~ex2_a_frac[47]) & (~ex2_a_frac[48]) & (~ex2_a_frac[49]) & (~ex2_a_frac[50]) & (~ex2_a_frac[51]) & (~ex2_a_frac[52]);		
   
   assign ex2_c_frac_zero = (~ex2_c_frac[1]) & (~ex2_c_frac[2]) & (~ex2_c_frac[3]) & (~ex2_c_frac[4]) & (~ex2_c_frac[5]) & (~ex2_c_frac[6]) & (~ex2_c_frac[7]) & (~ex2_c_frac[8]) & (~ex2_c_frac[9]) & (~ex2_c_frac[10]) & (~ex2_c_frac[11]) & (~ex2_c_frac[12]) & (~ex2_c_frac[13]) & (~ex2_c_frac[14]) & (~ex2_c_frac[15]) & (~ex2_c_frac[16]) & (~ex2_c_frac[17]) & (~ex2_c_frac[18]) & (~ex2_c_frac[19]) & (~ex2_c_frac[20]) & (~ex2_c_frac[21]) & (~ex2_c_frac[22]) & (~ex2_c_frac[23]) & (~ex2_c_frac[24]) & (~ex2_c_frac[25]) & (~ex2_c_frac[26]) & (~ex2_c_frac[27]) & (~ex2_c_frac[28]) & (~ex2_c_frac[29]) & (~ex2_c_frac[30]) & (~ex2_c_frac[31]) & (~ex2_c_frac[32]) & (~ex2_c_frac[33]) & (~ex2_c_frac[34]) & (~ex2_c_frac[35]) & (~ex2_c_frac[36]) & (~ex2_c_frac[37]) & (~ex2_c_frac[38]) & (~ex2_c_frac[39]) & (~ex2_c_frac[40]) & (~ex2_c_frac[41]) & (~ex2_c_frac[42]) & (~ex2_c_frac[43]) & (~ex2_c_frac[44]) & (~ex2_c_frac[45]) & (~ex2_c_frac[46]) & (~ex2_c_frac[47]) & (~ex2_c_frac[48]) & (~ex2_c_frac[49]) & (~ex2_c_frac[50]) & (~ex2_c_frac[51]) & (~ex2_c_frac[52]);		
   
   assign ex2_b_frac_zero_sp = (~ex2_b_frac[1]) & (~ex2_b_frac[2]) & (~ex2_b_frac[3]) & (~ex2_b_frac[4]) & (~ex2_b_frac[5]) & (~ex2_b_frac[6]) & (~ex2_b_frac[7]) & (~ex2_b_frac[8]) & (~ex2_b_frac[9]) & (~ex2_b_frac[10]) & (~ex2_b_frac[11]) & (~ex2_b_frac[12]) & (~ex2_b_frac[13]) & (~ex2_b_frac[14]) & (~ex2_b_frac[15]) & (~ex2_b_frac[16]) & (~ex2_b_frac[17]) & (~ex2_b_frac[18]) & (~ex2_b_frac[19]) & (~ex2_b_frac[20]) & (~ex2_b_frac[21]) & (~ex2_b_frac[22]) & (~ex2_b_frac[23]);
   
   assign ex2_b_frac_zero = ex2_b_frac_zero_sp & ex2_b_frac_zero_dp;
   
   assign ex2_b_frac_z32 = (~ex2_b_frac[24]) & (~ex2_b_frac[25]) & (~ex2_b_frac[26]) & (~ex2_b_frac[27]) & (~ex2_b_frac[28]) & (~ex2_b_frac[29]) & (~ex2_b_frac[30]) & (~ex2_b_frac[31]);		
   assign f_fmt_ex2_b_frac_z32 = ex2_b_frac_zero_sp & ex2_b_frac_z32;		
   assign ex2_b_frac_zero_dp = ex2_b_frac_z32 & (~ex2_b_frac[32]) & (~ex2_b_frac[33]) & (~ex2_b_frac[34]) & (~ex2_b_frac[35]) & (~ex2_b_frac[36]) & (~ex2_b_frac[37]) & (~ex2_b_frac[38]) & (~ex2_b_frac[39]) & (~ex2_b_frac[40]) & (~ex2_b_frac[41]) & (~ex2_b_frac[42]) & (~ex2_b_frac[43]) & (~ex2_b_frac[44]) & (~ex2_b_frac[45]) & (~ex2_b_frac[46]) & (~ex2_b_frac[47]) & (~ex2_b_frac[48]) & (~ex2_b_frac[49]) & (~ex2_b_frac[50]) & (~ex2_b_frac[51]) & (~ex2_b_frac[52]);
   
   assign f_fmt_ex2_b_frac[1:19] = ex2_b_frac[1:19];		
   
   assign f_fmt_ex2_a_sign_div = ex2_a_sign;
   assign f_fmt_ex2_a_expo_div_b = (~ex2_a_expo[1:13]);
   assign f_fmt_ex2_a_frac_div = ex2_a_frac[1:52];
   
   assign f_fmt_ex2_b_sign_div = ex2_b_sign;
   assign f_fmt_ex2_b_expo_div_b = (~ex2_b_expo[1:13]);
   assign f_fmt_ex2_b_frac_div = ex2_b_frac[1:52];
   
   assign ex2_a_denz = ((~ex2_a_frac[0]) | ex2_a_expo_ltx381_sp) & f_pic_ex2_nj_deni;		
   assign ex2_c_denz = ((~ex2_c_frac[0]) | ex2_c_expo_ltx381_sp) & f_pic_ex2_nj_deni;		
   assign ex2_b_denz = ((~ex2_b_frac[0]) | ex2_b_expo_ltx381_sp) & f_pic_ex2_nj_deni & (~ex2_from_integer);		
   
   assign ex2_a_zero_x = (ex2_a_denz | (ex2_a_expo_min & ex2_a_frac_zero));
   assign ex2_c_zero_x = (ex2_c_denz | (ex2_c_expo_min & ex2_c_frac_zero));
   assign ex2_b_zero_x = (ex2_b_denz | (ex2_b_expo_min & ex2_b_frac_zero)) & ((~ex2_from_integer) | (~ex2_b_sign));
   
   assign ex2_divsqrt = f_dcd_ex2_divsqrt_v;	
   
   assign ex2_b_den_flush = ex2_b_den_sp | ex2_b_den_dp |  ex2_a_den_sp_ftdiv | (ex2_divsqrt & (ex2_a_den_dp | ex2_a_den_sp));

   assign ex2_a_den_sp_ftdiv = f_pic_ex2_ftdiv    &  
                               ex2_aop_valid      &
                               ex2_a_expo_min     & 
                              (~ex2_a_frac_zero)    & 
                              (~f_pic_ex2_nj_deni)  &  
                              ex2_a_expo[5]         ; 
   
   assign ex2_b_den_dp = f_pic_ex2_flush_en_dp & ex2_bop_valid & ex2_b_expo_min & (~ex2_b_frac_zero) & (~f_pic_ex2_nj_deni) & (~ex2_b_expo[5]);		
   
   assign ex2_b_den_sp = f_pic_ex2_flush_en_sp & ex2_bop_valid & ex2_b_expo_min & (~ex2_b_frac_zero) & (~(f_pic_ex2_nj_deni & (~ex2_from_integer))) & ex2_b_expo[5];		
   
   assign ex2_a_den_flush = ex2_a_den_sp | ex2_a_den_dp;
   
   assign ex2_a_den_dp = f_pic_ex2_flush_en_dp & ex2_aop_valid & ex2_a_expo_min & (~ex2_a_frac_zero) & (~f_pic_ex2_nj_deni) & (~ex2_a_expo[5]);		
   
   assign ex2_a_den_sp = f_pic_ex2_flush_en_sp & ex2_aop_valid & ex2_a_expo_min & (~ex2_a_frac_zero) & (~(f_pic_ex2_nj_deni & (~ex2_from_integer))) & ex2_a_expo[5];		
   
   assign ex2_lu_den_part = ex2_b_frac[1] & ex2_b_frac[2] & ex2_b_frac[3] & ex2_b_frac[4] & ex2_b_frac[5] & ex2_b_frac[6] & ex2_b_frac[7] & ex2_b_frac[8] & ex2_b_frac[9] & ex2_b_frac[10] & ex2_b_frac[11] & ex2_b_frac[12];
   
   assign ex2_recip_lo = ex2_b_frac[14] | ex2_b_frac[15] | ex2_b_frac[16] | ex2_b_frac[17] | (ex2_b_frac[18] & ex2_b_frac[19]) | (ex2_b_frac[18] & ex2_b_frac[20]);
   
   
   
   
   assign ex2_rsqrt_lo = ex2_b_frac[13] | ex2_b_frac[14] | ex2_b_frac[15] | ex2_b_frac[16] | (ex2_b_frac[17] & ex2_b_frac[18]) | (ex2_b_frac[17] & ex2_b_frac[19]) | (ex2_b_frac[17] & ex2_b_frac[20] & ex2_b_frac[21]);
   
   assign ex2_lu_den_recip = (ex2_lu_den_part & ex2_b_frac[13] & ex2_recip_lo);
   
   assign ex2_lu_den_rsqrto = (ex2_lu_den_part & ex2_rsqrt_lo);
   
   assign f_fmt_ex3_lu_den_recip = ex3_lu_den_recip;
   assign f_fmt_ex3_lu_den_rsqrto = ex3_lu_den_rsqrto;		
   
   
   assign ex2_a_zero = ex2_aop_valid & ex2_a_zero_x;
   assign ex2_c_zero = ex2_cop_valid & ex2_c_zero_x;
   assign ex2_b_zero = ex2_bop_valid & ex2_b_zero_x;
   
   assign ex2_a_expo_ltx36A_sp = (ex2_a_expo < 13'b0001101101010) ? 1'b1 : 		
                                 1'b0;
   assign ex2_b_expo_ltx36A_sp = (ex2_b_expo < 13'b0001101101010) ? 1'b1 : 
                                 1'b0;
   
   assign ex2_a_expo_max_dsq = (ex2_a_expo > 13'b0010001111110) ? 1'b1 : 
                               1'b0;
   assign ex2_b_expo_max_dsq = (ex2_b_expo > 13'b0010001111110) ? 1'b1 : 
                               1'b0;
   
   assign f_fmt_ex2_a_zero = ex2_a_zero;		
   assign f_fmt_ex2_a_zero_dsq = ((~ex2_a_frac[0]) | (ex2_a_expo_ltx36A_sp)) | (ex2_a_expo_min & ex2_a_frac_zero);
   
   assign f_fmt_ex2_a_expo_max = ex2_aop_valid & ex2_a_expo_max;		
   assign f_fmt_ex2_a_expo_max_dsq = ex2_a_expo_max_dsq;		
   
   assign f_fmt_ex2_a_frac_zero = ex2_a_frac_zero;		
   assign f_fmt_ex2_a_frac_msb = ex2_a_frac_msb;		
   
   assign f_fmt_ex2_c_zero = ex2_c_zero;		
   assign f_fmt_ex2_c_expo_max = ex2_cop_valid & ex2_c_expo_max;		
   assign f_fmt_ex2_c_frac_zero = ex2_c_frac_zero;		
   assign f_fmt_ex2_c_frac_msb = ex2_c_frac_msb;		
   
   assign f_fmt_ex2_b_zero = ex2_b_zero;		
   assign f_fmt_ex2_b_zero_dsq = ((~ex2_b_frac[0]) | (ex2_b_expo_ltx36A_sp)) | (ex2_b_expo_min & ex2_b_frac_zero);
   
   assign f_fmt_ex2_b_expo_max = ex2_bop_valid & ex2_b_expo_max;		
   assign f_fmt_ex2_b_expo_max_dsq = ex2_b_expo_max_dsq;		
   
   assign f_fmt_ex2_b_frac_zero = ex2_b_frac_zero;		
   assign f_fmt_ex2_b_frac_msb = ex2_b_frac_msb;		
   assign f_fmt_ex2_b_imp = ex2_b_frac[0];		
   
   assign f_fmt_ex2_prod_zero = ex2_a_zero | ex2_c_zero;		
   
   
   assign ex2_a_nan = ex2_a_expo_max & (~ex2_a_frac_zero) & (~ex2_from_integer) & (~ex2_sgncpy) & (~ex2_uc_end_nspec) & (~ex2_uc_mid) & (~f_dcd_ex2_perr_fsel_ovrd);
   assign ex2_c_nan = ex2_c_expo_max & (~ex2_c_frac_zero) & (~ex2_from_integer) & (~ex2_fsel) & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   assign ex2_b_nan = ex2_b_expo_max & (~ex2_b_frac_zero) & (~ex2_from_integer) & (~ex2_fsel) & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   
   assign ex2_nan_pass = ex2_a_nan | ex2_c_nan | ex2_b_nan;
   assign ex2_pass_sel = ex2_nan_pass | ex2_fsel | ex2_force_pass;
   
   assign f_fmt_ex2_pass_sel = ex2_pass_sel;		
   
   assign ex2_fsel_cif = (ex2_fsel & (~ex2_a_sign) & (~f_dcd_ex2_perr_fsel_ovrd)) | 
                         (ex2_fsel & ex2_a_zero    & (~f_dcd_ex2_perr_fsel_ovrd)) | 
                         ( f_dcd_ex2_perr_force_c  & ( f_dcd_ex2_perr_fsel_ovrd));


   assign ex2_be_den  = 
           (     ex2_b_expo[1]      ) | 
           (  (~ex2_b_expo[2])  &    
              (~ex2_b_expo[3])  &    
              (~ex2_b_expo[4])  &    
              (~ex2_b_expo[5])  &    
              (~ex2_b_expo[6])  &    
              (~ex2_b_expo[7])  &    
              (~ex2_b_expo[8])  &    
              (~ex2_b_expo[9])  &    
              (~ex2_b_expo[10]) &    
              (~ex2_b_expo[11]) &    
              (~ex2_b_expo[12]) &    
              (~ex2_b_expo[13])     ); 

   assign ex2_fsel_bsel = ex2_fsel & (ex2_a_nan | (~ex2_fsel_cif));
   
   assign ex2_mux_a_sel = ex2_a_nan & (~ex2_fsel);
   
   assign ex2_mux_c_sel = ((~ex2_a_nan) & (~ex2_b_nan) & ex2_c_nan) | (ex2_a_nan & (~ex2_fsel)) | ((~ex2_a_nan) & ex2_fsel & ex2_fsel_cif);
   
   assign ex2_pass_sign_ac = (ex2_mux_a_sel & ex2_a_sign) | ((~ex2_mux_a_sel) & ex2_c_sign);
   assign ex2_pass_sign = (ex2_mux_c_sel & ex2_pass_sign_ac) | ((~ex2_mux_c_sel) & ex2_b_sign);
   
   assign ex2_a_frac_chop[0:23] = ex2_a_frac[0:23];
   assign ex2_c_frac_chop[0:23] = ex2_c_frac[0:23];
   assign ex2_b_frac_chop[0:23] = ex2_b_frac[0:23];
   
   assign ex2_a_frac_chop[24:52] = ex2_a_frac[24:52];		
   assign ex2_c_frac_chop[24:52] = ex2_c_frac[24:52];		
   assign ex2_b_frac_chop[24:52] = ex2_b_frac[24:52];		
   
   assign ex2_a_expo_ltx381_sp = ex2_a_expo_ltx381 & ex2_a_sp;
   assign ex2_c_expo_ltx381_sp = ex2_c_expo_ltx381 & ex2_c_sp;
   assign ex2_b_expo_ltx381_sp = ex2_b_expo_ltx381 & ex2_b_sp;
   
   assign ex2_a_expo_ltx381 = ((~ex2_a_expo_b[1])) | (ex2_a_expo_00xx_xxxx_xxxx & (~ex2_a_expo_xx11_1xxx_xxxx)) | (ex2_a_expo_00xx_xxxx_xxxx & ex2_a_expo_xx11_1xxx_xxxx & ex2_a_expo_xxxx_x000_0000);		
   
   assign ex2_a_expo_00xx_xxxx_xxxx = ex2_a_expo_b[2] & ex2_a_expo_b[3];
   assign ex2_a_expo_xx11_1xxx_xxxx = (~ex2_a_expo_b[4]) & (~ex2_a_expo_b[5]) & (~ex2_a_expo_b[6]);
   assign ex2_a_expo_xxxx_x000_0000 = ex2_a_expo_b[7] & ex2_a_expo_b[8] & ex2_a_expo_b[9] & ex2_a_expo_b[10] & ex2_a_expo_b[11] & ex2_a_expo_b[12] & ex2_a_expo_b[13];
   
   assign ex2_c_expo_ltx381 = ((~ex2_c_expo_b[1])) | (ex2_c_expo_00xx_xxxx_xxxx & (~ex2_c_expo_xx11_1xxx_xxxx)) | (ex2_c_expo_00xx_xxxx_xxxx & ex2_c_expo_xx11_1xxx_xxxx & ex2_c_expo_xxxx_x000_0000);		
   
   assign ex2_c_expo_00xx_xxxx_xxxx = ex2_c_expo_b[2] & ex2_c_expo_b[3];
   assign ex2_c_expo_xx11_1xxx_xxxx = (~ex2_c_expo_b[4]) & (~ex2_c_expo_b[5]) & (~ex2_c_expo_b[6]);
   assign ex2_c_expo_xxxx_x000_0000 = ex2_c_expo_b[7] & ex2_c_expo_b[8] & ex2_c_expo_b[9] & ex2_c_expo_b[10] & ex2_c_expo_b[11] & ex2_c_expo_b[12] & ex2_c_expo_b[13];
   
   assign ex2_b_expo_ltx381 = ((~ex2_b_expo_b[1])) | (ex2_b_expo_00xx_xxxx_xxxx & (~ex2_b_expo_xx11_1xxx_xxxx)) | (ex2_b_expo_00xx_xxxx_xxxx & ex2_b_expo_xx11_1xxx_xxxx & ex2_b_expo_xxxx_x000_0000);		
   
   assign ex2_b_expo_00xx_xxxx_xxxx = ex2_b_expo_b[2] & ex2_b_expo_b[3];
   assign ex2_b_expo_xx11_1xxx_xxxx = (~ex2_b_expo_b[4]) & (~ex2_b_expo_b[5]) & (~ex2_b_expo_b[6]);
   assign ex2_b_expo_xxxx_x000_0000 = ex2_b_expo_b[7] & ex2_b_expo_b[8] & ex2_b_expo_b[9] & ex2_b_expo_b[10] & ex2_b_expo_b[11] & ex2_b_expo_b[12] & ex2_b_expo_b[13];
   
   assign ex2_pass_frac_ac[0:52] = ({53{ex2_mux_a_sel}}    & ex2_a_frac_chop[0:52]) | 
                                   ({53{(~ex2_mux_a_sel)}} & ex2_c_frac_chop[0:52]);
   
   assign ex2_pass_frac[0:52] = ({53{ex2_mux_c_sel}}    & ex2_pass_frac_ac[0:52]) | 
                                ({53{(~ex2_mux_c_sel)}} & ex2_b_frac_chop[0:52]);
   
   assign ex2_uc_a_expo_den = ((~ex2_a_expo_b[1])) | (ex2_a_expo_b[2] & ex2_a_expo_b[3] & ex2_a_expo_b[4] & ex2_a_expo_b[5] & ex2_a_expo_b[6] & ex2_a_expo_b[7] & ex2_a_expo_b[8] & ex2_a_expo_b[9] & ex2_a_expo_b[10] & ex2_a_expo_b[11] & ex2_a_expo_b[12] & ex2_a_expo_b[13]);		
   
   assign ex2_uc_a_expo_den_sp = ex2_a_expo_ltx381;
   
   assign ex2_a_sp_inf_alias_tail = (~ex2_a_expo_b[7]) & (~ex2_a_expo_b[8]) & (~ex2_a_expo_b[9]) & (~ex2_a_expo_b[10]) & (~ex2_a_expo_b[11]) & (~ex2_a_expo_b[12]) & (~ex2_a_expo_b[13]);
   assign ex2_c_sp_inf_alias_tail = (~ex2_c_expo_b[7]) & (~ex2_c_expo_b[8]) & (~ex2_c_expo_b[9]) & (~ex2_c_expo_b[10]) & (~ex2_c_expo_b[11]) & (~ex2_c_expo_b[12]) & (~ex2_c_expo_b[13]);
   assign ex2_b_sp_inf_alias_tail = (~ex2_b_expo_b[7]) & (~ex2_b_expo_b[8]) & (~ex2_b_expo_b[9]) & (~ex2_b_expo_b[10]) & (~ex2_b_expo_b[11]) & (~ex2_b_expo_b[12]) & (~ex2_b_expo_b[13]);
   
   assign ex2_a_sp_expo_ok_1 = ex2_a_expo_b[1] & ex2_a_expo_b[2] & (~ex2_a_expo_b[3]) & ex2_a_expo_b[4] & ex2_a_expo_b[5] & ex2_a_expo_b[6] & (~ex2_a_sp_inf_alias_tail);		
   
   assign ex2_c_sp_expo_ok_1 = ex2_c_expo_b[1] & ex2_c_expo_b[2] & (~ex2_c_expo_b[3]) & ex2_c_expo_b[4] & ex2_c_expo_b[5] & ex2_c_expo_b[6] & (~ex2_c_sp_inf_alias_tail);		
   
   assign ex2_b_sp_expo_ok_1 = ex2_b_expo_b[1] & ex2_b_expo_b[2] & (~ex2_b_expo_b[3]) & ex2_b_expo_b[4] & ex2_b_expo_b[5] & ex2_b_expo_b[6] & (~ex2_b_sp_inf_alias_tail);		
   
   assign ex2_a_sp_expo_ok_2 = ex2_a_expo_b[1] & ex2_a_expo_b[2] & ex2_a_expo_b[3] & (~ex2_a_expo_b[4]) & (~ex2_a_expo_b[5]) & (~ex2_a_expo_b[6]);		
   
   assign ex2_c_sp_expo_ok_2 = ex2_c_expo_b[1] & ex2_c_expo_b[2] & ex2_c_expo_b[3] & (~ex2_c_expo_b[4]) & (~ex2_c_expo_b[5]) & (~ex2_c_expo_b[6]);		
   
   assign ex2_b_sp_expo_ok_2 = ex2_b_expo_b[1] & ex2_b_expo_b[2] & ex2_b_expo_b[3] & (~ex2_b_expo_b[4]) & (~ex2_b_expo_b[5]) & (~ex2_b_expo_b[6]);		
   
   
   assign ex2_a_sp_expo_ok_3 = ex2_a_expo_b[1] & ex2_a_expo_b[2] & ex2_a_expo_b[3] & (~ex2_a_expo_b[4]) & (~ex2_a_expo_b[5]) & ex2_a_expo_b[6] & (~ex2_a_expo_b[7]) & (~ex2_a_expo_b[8]) & (~ex2_a_expo_b[9]);		
   
   assign ex2_c_sp_expo_ok_3 = ex2_c_expo_b[1] & ex2_c_expo_b[2] & ex2_c_expo_b[3] & (~ex2_c_expo_b[4]) & (~ex2_c_expo_b[5]) & ex2_c_expo_b[6] & (~ex2_c_expo_b[7]) & (~ex2_c_expo_b[8]) & (~ex2_c_expo_b[9]);		
   
   assign ex2_b_sp_expo_ok_3 = ex2_b_expo_b[1] & ex2_b_expo_b[2] & ex2_b_expo_b[3] & (~ex2_b_expo_b[4]) & (~ex2_b_expo_b[5]) & ex2_b_expo_b[6] & (~ex2_b_expo_b[7]) & (~ex2_b_expo_b[8]) & (~ex2_b_expo_b[9]);		
   
   
   assign ex2_a_sp_expo_ok_4 = ex2_a_expo_b[1] & ex2_a_expo_b[2] & ex2_a_expo_b[3] & (~ex2_a_expo_b[4]) & (~ex2_a_expo_b[5]) & ex2_a_expo_b[6] & (~ex2_a_expo_b[7]) & (~ex2_a_expo_b[8]) & ex2_a_expo_b[9] & (((~ex2_a_expo_b[10]) & (~ex2_a_expo_b[11])) | ((~ex2_a_expo_b[10]) & (~ex2_a_expo_b[12])));		
   
   assign ex2_c_sp_expo_ok_4 = ex2_c_expo_b[1] & ex2_c_expo_b[2] & ex2_c_expo_b[3] & (~ex2_c_expo_b[4]) & (~ex2_c_expo_b[5]) & ex2_c_expo_b[6] & (~ex2_c_expo_b[7]) & (~ex2_c_expo_b[8]) & ex2_c_expo_b[9] & (((~ex2_c_expo_b[10]) & (~ex2_c_expo_b[11])) | ((~ex2_c_expo_b[10]) & (~ex2_c_expo_b[12])));		
   
   assign ex2_b_sp_expo_ok_4 = ex2_b_expo_b[1] & ex2_b_expo_b[2] & ex2_b_expo_b[3] & (~ex2_b_expo_b[4]) & (~ex2_b_expo_b[5]) & ex2_b_expo_b[6] & (~ex2_b_expo_b[7]) & (~ex2_b_expo_b[8]) & ex2_b_expo_b[9] & (((~ex2_b_expo_b[10]) & (~ex2_b_expo_b[11])) | ((~ex2_b_expo_b[10]) & (~ex2_b_expo_b[12])));		
   
   
   assign f_fmt_ex2_sp_invalid = ((~ex2_a_sp_expo_ok_1) & (~ex2_a_sp_expo_ok_2) & (~ex2_a_sp_expo_ok_3) & (~ex2_a_sp_expo_ok_4) & (~ex2_a_expo_max) & (~ex2_a_zero_x)) | ((~ex2_c_sp_expo_ok_1) & (~ex2_c_sp_expo_ok_2) & (~ex2_c_sp_expo_ok_3) & (~ex2_c_sp_expo_ok_4) & (~ex2_c_expo_max) & (~ex2_c_zero_x)) | ((~ex2_b_sp_expo_ok_1) & (~ex2_b_sp_expo_ok_2) & (~ex2_b_sp_expo_ok_3) & (~ex2_b_sp_expo_ok_4) & (~ex2_b_expo_max) & (~ex2_b_zero_x));
   
   
   
   
   assign ex2_a_party[0] = ex2_a_sign ^ ex2_a_expo[1] ^ ex2_a_expo[2] ^ ex2_a_expo[3] ^ ex2_a_expo[4] ^ ex2_a_expo[5] ^ ex2_a_expo[6] ^ ex2_a_expo[7] ^ ex2_a_expo[8] ^ ex2_a_expo[9];
   assign ex2_a_party[1] = ex2_a_expo[10] ^ ex2_a_expo[11] ^ ex2_a_expo[12] ^ ex2_a_expo[13] ^ ex2_a_frac[0] ^ ex2_a_frac[1] ^ ex2_a_frac[2] ^ ex2_a_frac[3] ^ ex2_a_frac[4];
   assign ex2_a_party[2] = ex2_a_frac[5] ^ ex2_a_frac[6] ^ ex2_a_frac[7] ^ ex2_a_frac[8] ^ ex2_a_frac[9] ^ ex2_a_frac[10] ^ ex2_a_frac[11] ^ ex2_a_frac[12];
   assign ex2_a_party[3] = ex2_a_frac[13] ^ ex2_a_frac[14] ^ ex2_a_frac[15] ^ ex2_a_frac[16] ^ ex2_a_frac[17] ^ ex2_a_frac[18] ^ ex2_a_frac[19] ^ ex2_a_frac[20];
   assign ex2_a_party[4] = ex2_a_frac[21] ^ ex2_a_frac[22] ^ ex2_a_frac[23] ^ ex2_a_frac[24] ^ ex2_a_frac[25] ^ ex2_a_frac[26] ^ ex2_a_frac[27] ^ ex2_a_frac[28];
   assign ex2_a_party[5] = ex2_a_frac[29] ^ ex2_a_frac[30] ^ ex2_a_frac[31] ^ ex2_a_frac[32] ^ ex2_a_frac[33] ^ ex2_a_frac[34] ^ ex2_a_frac[35] ^ ex2_a_frac[36];
   assign ex2_a_party[6] = ex2_a_frac[37] ^ ex2_a_frac[38] ^ ex2_a_frac[39] ^ ex2_a_frac[40] ^ ex2_a_frac[41] ^ ex2_a_frac[42] ^ ex2_a_frac[43] ^ ex2_a_frac[44];
   assign ex2_a_party[7] = ex2_a_frac[45] ^ ex2_a_frac[46] ^ ex2_a_frac[47] ^ ex2_a_frac[48] ^ ex2_a_frac[49] ^ ex2_a_frac[50] ^ ex2_a_frac[51] ^ ex2_a_frac[52];
   
   assign ex2_c_party[0] = ex2_c_sign ^ ex2_c_expo[1] ^ ex2_c_expo[2] ^ ex2_c_expo[3] ^ ex2_c_expo[4] ^ ex2_c_expo[5] ^ ex2_c_expo[6] ^ ex2_c_expo[7] ^ ex2_c_expo[8] ^ ex2_c_expo[9];
   assign ex2_c_party[1] = ex2_c_expo[10] ^ ex2_c_expo[11] ^ ex2_c_expo[12] ^ ex2_c_expo[13] ^ ex2_c_frac[0] ^ ex2_c_frac[1] ^ ex2_c_frac[2] ^ ex2_c_frac[3] ^ ex2_c_frac[4];
   assign ex2_c_party[2] = ex2_c_frac[5] ^ ex2_c_frac[6] ^ ex2_c_frac[7] ^ ex2_c_frac[8] ^ ex2_c_frac[9] ^ ex2_c_frac[10] ^ ex2_c_frac[11] ^ ex2_c_frac[12];
   assign ex2_c_party[3] = ex2_c_frac[13] ^ ex2_c_frac[14] ^ ex2_c_frac[15] ^ ex2_c_frac[16] ^ ex2_c_frac[17] ^ ex2_c_frac[18] ^ ex2_c_frac[19] ^ ex2_c_frac[20];
   assign ex2_c_party[4] = ex2_c_frac[21] ^ ex2_c_frac[22] ^ ex2_c_frac[23] ^ ex2_c_frac[24] ^ ex2_c_frac[25] ^ ex2_c_frac[26] ^ ex2_c_frac[27] ^ ex2_c_frac[28];
   assign ex2_c_party[5] = ex2_c_frac[29] ^ ex2_c_frac[30] ^ ex2_c_frac[31] ^ ex2_c_frac[32] ^ ex2_c_frac[33] ^ ex2_c_frac[34] ^ ex2_c_frac[35] ^ ex2_c_frac[36];
   assign ex2_c_party[6] = ex2_c_frac[37] ^ ex2_c_frac[38] ^ ex2_c_frac[39] ^ ex2_c_frac[40] ^ ex2_c_frac[41] ^ ex2_c_frac[42] ^ ex2_c_frac[43] ^ ex2_c_frac[44];
   assign ex2_c_party[7] = ex2_c_frac[45] ^ ex2_c_frac[46] ^ ex2_c_frac[47] ^ ex2_c_frac[48] ^ ex2_c_frac[49] ^ ex2_c_frac[50] ^ ex2_c_frac[51] ^ ex2_c_frac[52];
   
   assign ex2_b_party[0] = ex2_b_sign ^ ex2_b_expo[1] ^ ex2_b_expo[2] ^ ex2_b_expo[3] ^ ex2_b_expo[4] ^ ex2_b_expo[5] ^ ex2_b_expo[6] ^ ex2_b_expo[7] ^ ex2_b_expo[8] ^ ex2_b_expo[9];
   assign ex2_b_party[1] = ex2_b_expo[10] ^ ex2_b_expo[11] ^ ex2_b_expo[12] ^ ex2_b_expo[13] ^ ex2_b_frac[0] ^ ex2_b_frac[1] ^ ex2_b_frac[2] ^ ex2_b_frac[3] ^ ex2_b_frac[4];
   assign ex2_b_party[2] = ex2_b_frac[5] ^ ex2_b_frac[6] ^ ex2_b_frac[7] ^ ex2_b_frac[8] ^ ex2_b_frac[9] ^ ex2_b_frac[10] ^ ex2_b_frac[11] ^ ex2_b_frac[12];
   assign ex2_b_party[3] = ex2_b_frac[13] ^ ex2_b_frac[14] ^ ex2_b_frac[15] ^ ex2_b_frac[16] ^ ex2_b_frac[17] ^ ex2_b_frac[18] ^ ex2_b_frac[19] ^ ex2_b_frac[20];
   assign ex2_b_party[4] = ex2_b_frac[21] ^ ex2_b_frac[22] ^ ex2_b_frac[23] ^ ex2_b_frac[24] ^ ex2_b_frac[25] ^ ex2_b_frac[26] ^ ex2_b_frac[27] ^ ex2_b_frac[28];
   assign ex2_b_party[5] = ex2_b_frac[29] ^ ex2_b_frac[30] ^ ex2_b_frac[31] ^ ex2_b_frac[32] ^ ex2_b_frac[33] ^ ex2_b_frac[34] ^ ex2_b_frac[35] ^ ex2_b_frac[36];
   assign ex2_b_party[6] = ex2_b_frac[37] ^ ex2_b_frac[38] ^ ex2_b_frac[39] ^ ex2_b_frac[40] ^ ex2_b_frac[41] ^ ex2_b_frac[42] ^ ex2_b_frac[43] ^ ex2_b_frac[44];
   assign ex2_b_party[7] = ex2_b_frac[45] ^ ex2_b_frac[46] ^ ex2_b_frac[47] ^ ex2_b_frac[48] ^ ex2_b_frac[49] ^ ex2_b_frac[50] ^ ex2_b_frac[51] ^ ex2_b_frac[52];
   
   assign ex2_a_party_chick = (ex2_a_party[0] ^ f_fpr_ex2_a_par[0]) | (ex2_a_party[1] ^ f_fpr_ex2_a_par[1]) | (ex2_a_party[2] ^ f_fpr_ex2_a_par[2]) | (ex2_a_party[3] ^ f_fpr_ex2_a_par[3]) | (ex2_a_party[4] ^ f_fpr_ex2_a_par[4]) | (ex2_a_party[5] ^ f_fpr_ex2_a_par[5]) | (ex2_a_party[6] ^ f_fpr_ex2_a_par[6]) | (ex2_a_party[7] ^ f_fpr_ex2_a_par[7]);
   
   assign ex2_c_party_chick = (ex2_c_party[0] ^ f_fpr_ex2_c_par[0]) | (ex2_c_party[1] ^ f_fpr_ex2_c_par[1]) | (ex2_c_party[2] ^ f_fpr_ex2_c_par[2]) | (ex2_c_party[3] ^ f_fpr_ex2_c_par[3]) | (ex2_c_party[4] ^ f_fpr_ex2_c_par[4]) | (ex2_c_party[5] ^ f_fpr_ex2_c_par[5]) | (ex2_c_party[6] ^ f_fpr_ex2_c_par[6]) | (ex2_c_party[7] ^ f_fpr_ex2_c_par[7]);
   
   assign ex2_b_party_chick = (ex2_b_party[0] ^ f_fpr_ex2_b_par[0]) | (ex2_b_party[1] ^ f_fpr_ex2_b_par[1]) | (ex2_b_party[2] ^ f_fpr_ex2_b_par[2]) | (ex2_b_party[3] ^ f_fpr_ex2_b_par[3]) | (ex2_b_party[4] ^ f_fpr_ex2_b_par[4]) | (ex2_b_party[5] ^ f_fpr_ex2_b_par[5]) | (ex2_b_party[6] ^ f_fpr_ex2_b_par[6]) | (ex2_b_party[7] ^ f_fpr_ex2_b_par[7]);
   
   
   
   assign ex2_ae_234567 = ex2_a_expo[2] | ex2_a_expo[3] | ex2_a_expo[4] | ex2_a_expo[5] | ex2_a_expo[6] | ex2_a_expo[7];
   assign ex2_ae_89 = ex2_a_expo[8] & ex2_a_expo[9];
   assign ex2_ae_abc = ex2_a_expo[10] | (ex2_a_expo[11] & ex2_a_expo[12]);
   
   assign ex2_ae_ge_54 = ((~ex2_a_expo[1]) & ex2_ae_234567) | ((~ex2_a_expo[1]) & ex2_ae_89 & ex2_ae_abc);
   
   assign ex2_be_234567 = ex2_b_expo[2] | ex2_b_expo[3] | ex2_b_expo[4] | ex2_b_expo[5] | ex2_b_expo[6] | ex2_b_expo[7];
   assign ex2_be_89 = ex2_b_expo[8] & ex2_b_expo[9];
   assign ex2_be_abc = ex2_b_expo[10] | (ex2_b_expo[11] & ex2_b_expo[12]);
   
   assign ex2_be_ge_54 = ((~ex2_b_expo[1]) & ex2_be_234567) | ((~ex2_b_expo[1]) & ex2_be_89 & ex2_be_abc);
   
   
   assign ex2_be_or_23456789abc = ex2_b_expo[2] | ex2_b_expo[3] | ex2_b_expo[4] | ex2_b_expo[5] | ex2_b_expo[6] | ex2_b_expo[7] | ex2_b_expo[8] | ex2_b_expo[9] | ex2_b_expo[10] | ex2_b_expo[11] | ex2_b_expo[12];
   
   assign ex2_be_and_3456789ab = ex2_b_expo[3] & ex2_b_expo[4] & ex2_b_expo[5] & ex2_b_expo[6] & ex2_b_expo[7] & ex2_b_expo[8] & ex2_b_expo[9] & ex2_b_expo[10] & ex2_b_expo[11];
   
   assign ex2_be_ge_2 = (~ex2_b_expo[1]) & ex2_be_or_23456789abc;
   assign ex2_be_ge_2044 = ((~ex2_b_expo[1]) & ex2_be_and_3456789ab) | ((~ex2_b_expo[1]) & ex2_b_expo[2]);
   
   
   assign ex2_aembex_car_b[0] = (~(ex2_a_expo[1] | ex2_b_expo_b[1]));		
   assign ex2_aembex_car_b[1] = (~(ex2_a_expo[2] | ex2_b_expo_b[2]));		
   assign ex2_aembex_car_b[2] = (~(ex2_a_expo[3] | ex2_b_expo_b[3]));		
   assign ex2_aembex_car_b[3] = (~(ex2_a_expo[4] & ex2_b_expo_b[4]));		
   assign ex2_aembex_car_b[4] = (~(ex2_a_expo[5] & ex2_b_expo_b[5]));		
   assign ex2_aembex_car_b[5] = (~(ex2_a_expo[6] & ex2_b_expo_b[6]));		
   assign ex2_aembex_car_b[6] = (~(ex2_a_expo[7] & ex2_b_expo_b[7]));		
   assign ex2_aembex_car_b[7] = (~(ex2_a_expo[8] & ex2_b_expo_b[8]));		
   assign ex2_aembex_car_b[8] = (~(ex2_a_expo[9] & ex2_b_expo_b[9]));		
   assign ex2_aembex_car_b[9] = (~(ex2_a_expo[10] & ex2_b_expo_b[10]));		
   assign ex2_aembex_car_b[10] = (~(ex2_a_expo[11] & ex2_b_expo_b[11]));		
   assign ex2_aembex_car_b[11] = (~(ex2_a_expo[12] | ex2_b_expo_b[12]));		
   assign ex2_aembex_car_b[12] = (~(ex2_a_expo[13] & ex2_b_expo_b[13]));		
   
   assign ex2_aembex_sum_b[1] = (ex2_a_expo[1] ^ ex2_b_expo_b[1]);		
   assign ex2_aembex_sum_b[2] = (ex2_a_expo[2] ^ ex2_b_expo_b[2]);		
   assign ex2_aembex_sum_b[3] = (ex2_a_expo[3] ^ ex2_b_expo_b[3]);		
   assign ex2_aembex_sum_b[4] = (~(ex2_a_expo[4] ^ ex2_b_expo_b[4]));		
   assign ex2_aembex_sum_b[5] = (~(ex2_a_expo[5] ^ ex2_b_expo_b[5]));		
   assign ex2_aembex_sum_b[6] = (~(ex2_a_expo[6] ^ ex2_b_expo_b[6]));		
   assign ex2_aembex_sum_b[7] = (~(ex2_a_expo[7] ^ ex2_b_expo_b[7]));		
   assign ex2_aembex_sum_b[8] = (~(ex2_a_expo[8] ^ ex2_b_expo_b[8]));		
   assign ex2_aembex_sum_b[9] = (~(ex2_a_expo[9] ^ ex2_b_expo_b[9]));		
   assign ex2_aembex_sum_b[10] = (~(ex2_a_expo[10] ^ ex2_b_expo_b[10]));		
   assign ex2_aembex_sum_b[11] = (~(ex2_a_expo[11] ^ ex2_b_expo_b[11]));		
   assign ex2_aembex_sum_b[12] = (ex2_a_expo[12] ^ ex2_b_expo_b[12]);		
   assign ex2_aembex_sum_b[13] = (~(ex2_a_expo[13] ^ ex2_b_expo_b[13]));		
   
   
   assign ex2_aembex_sgn = ex2_aembex_sum_b[1] ^ ex2_aembex_car_b[1];
   
   assign ex2_aembex_g1[2:12] = (~(ex2_aembex_sum_b[2:12] | ex2_aembex_car_b[2:12]));
   assign ex2_aembex_t1[2:12] = (~(ex2_aembex_sum_b[2:12] & ex2_aembex_car_b[2:12]));
   
   assign ex2_aembex_g2[0] = ex2_aembex_g1[2] | (ex2_aembex_t1[2] & ex2_aembex_g1[3]);
   assign ex2_aembex_g2[1] = ex2_aembex_g1[4] | (ex2_aembex_t1[4] & ex2_aembex_g1[5]);
   assign ex2_aembex_g2[2] = ex2_aembex_g1[6] | (ex2_aembex_t1[6] & ex2_aembex_g1[7]);
   assign ex2_aembex_g2[3] = ex2_aembex_g1[8] | (ex2_aembex_t1[8] & ex2_aembex_g1[9]);
   assign ex2_aembex_g2[4] = ex2_aembex_g1[10] | (ex2_aembex_t1[10] & ex2_aembex_g1[11]);
   assign ex2_aembex_g2[5] = ex2_aembex_g1[12];
   
   assign ex2_aembex_t2[0] = (ex2_aembex_t1[2] & ex2_aembex_t1[3]);
   assign ex2_aembex_t2[1] = (ex2_aembex_t1[4] & ex2_aembex_t1[5]);
   assign ex2_aembex_t2[2] = (ex2_aembex_t1[6] & ex2_aembex_t1[7]);
   assign ex2_aembex_t2[3] = (ex2_aembex_t1[8] & ex2_aembex_t1[9]);
   assign ex2_aembex_t2[4] = (ex2_aembex_t1[10] & ex2_aembex_t1[11]);
   
   assign ex2_aembex_g4[0] = ex2_aembex_g2[0] | (ex2_aembex_t2[0] & ex2_aembex_g2[1]);
   assign ex2_aembex_g4[1] = ex2_aembex_g2[2] | (ex2_aembex_t2[2] & ex2_aembex_g2[3]);
   assign ex2_aembex_g4[2] = ex2_aembex_g2[4] | (ex2_aembex_t2[4] & ex2_aembex_g2[5]);
   
   assign ex2_aembex_t4[0] = (ex2_aembex_t2[0] & ex2_aembex_t2[1]);
   assign ex2_aembex_t4[1] = (ex2_aembex_t2[2] & ex2_aembex_t2[3]);
   
   
   assign ex2_aembey_car_b[0] = (~(ex2_a_expo[1] & ex2_b_expo_b[1]));		
   assign ex2_aembey_car_b[1] = (~(ex2_a_expo[2] & ex2_b_expo_b[2]));		
   assign ex2_aembey_car_b[2] = (~(ex2_a_expo[3] & ex2_b_expo_b[3]));		
   assign ex2_aembey_car_b[3] = (~(ex2_a_expo[4] | ex2_b_expo_b[4]));		
   assign ex2_aembey_car_b[4] = (~(ex2_a_expo[5] | ex2_b_expo_b[5]));		
   assign ex2_aembey_car_b[5] = (~(ex2_a_expo[6] | ex2_b_expo_b[6]));		
   assign ex2_aembey_car_b[6] = (~(ex2_a_expo[7] | ex2_b_expo_b[7]));		
   assign ex2_aembey_car_b[7] = (~(ex2_a_expo[8] | ex2_b_expo_b[8]));		
   assign ex2_aembey_car_b[8] = (~(ex2_a_expo[9] | ex2_b_expo_b[9]));		
   assign ex2_aembey_car_b[9] = (~(ex2_a_expo[10] | ex2_b_expo_b[10]));		
   assign ex2_aembey_car_b[10] = (~(ex2_a_expo[11] | ex2_b_expo_b[11]));		
   assign ex2_aembey_car_b[11] = (~(ex2_a_expo[12] & ex2_b_expo_b[12]));		
   assign ex2_aembey_car_b[12] = (~(ex2_a_expo[13] | ex2_b_expo_b[13]));		
   
   assign ex2_aembey_sum_b[1] = (~(ex2_a_expo[1] ^ ex2_b_expo_b[1]));		
   assign ex2_aembey_sum_b[2] = (~(ex2_a_expo[2] ^ ex2_b_expo_b[2]));		
   assign ex2_aembey_sum_b[3] = (~(ex2_a_expo[3] ^ ex2_b_expo_b[3]));		
   assign ex2_aembey_sum_b[4] = (ex2_a_expo[4] ^ ex2_b_expo_b[4]);		
   assign ex2_aembey_sum_b[5] = (ex2_a_expo[5] ^ ex2_b_expo_b[5]);		
   assign ex2_aembey_sum_b[6] = (ex2_a_expo[6] ^ ex2_b_expo_b[6]);		
   assign ex2_aembey_sum_b[7] = (ex2_a_expo[7] ^ ex2_b_expo_b[7]);		
   assign ex2_aembey_sum_b[8] = (ex2_a_expo[8] ^ ex2_b_expo_b[8]);		
   assign ex2_aembey_sum_b[9] = (ex2_a_expo[9] ^ ex2_b_expo_b[9]);		
   assign ex2_aembey_sum_b[10] = (ex2_a_expo[10] ^ ex2_b_expo_b[10]);		
   assign ex2_aembey_sum_b[11] = (ex2_a_expo[11] ^ ex2_b_expo_b[11]);		
   assign ex2_aembey_sum_b[12] = (~(ex2_a_expo[12] ^ ex2_b_expo_b[12]));		
   assign ex2_aembey_sum_b[13] = (ex2_a_expo[13] ^ ex2_b_expo_b[13]);		
   
   
   assign ex2_aembey_sgn = ex2_aembey_sum_b[1] ^ ex2_aembey_car_b[1];
   
   assign ex2_aembey_g1[2:12] = (~(ex2_aembey_sum_b[2:12] | ex2_aembey_car_b[2:12]));
   assign ex2_aembey_t1[2:12] = (~(ex2_aembey_sum_b[2:12] & ex2_aembey_car_b[2:12]));
   
   assign ex2_aembey_g2[0] = ex2_aembey_g1[2] | (ex2_aembey_t1[2] & ex2_aembey_g1[3]);
   assign ex2_aembey_g2[1] = ex2_aembey_g1[4] | (ex2_aembey_t1[4] & ex2_aembey_g1[5]);
   assign ex2_aembey_g2[2] = ex2_aembey_g1[6] | (ex2_aembey_t1[6] & ex2_aembey_g1[7]);
   assign ex2_aembey_g2[3] = ex2_aembey_g1[8] | (ex2_aembey_t1[8] & ex2_aembey_g1[9]);
   assign ex2_aembey_g2[4] = ex2_aembey_g1[10] | (ex2_aembey_t1[10] & ex2_aembey_g1[11]);
   assign ex2_aembey_g2[5] = ex2_aembey_g1[12];
   
   assign ex2_aembey_t2[0] = (ex2_aembey_t1[2] & ex2_aembey_t1[3]);
   assign ex2_aembey_t2[1] = (ex2_aembey_t1[4] & ex2_aembey_t1[5]);
   assign ex2_aembey_t2[2] = (ex2_aembey_t1[6] & ex2_aembey_t1[7]);
   assign ex2_aembey_t2[3] = (ex2_aembey_t1[8] & ex2_aembey_t1[9]);
   assign ex2_aembey_t2[4] = (ex2_aembey_t1[10] & ex2_aembey_t1[11]);
   
   assign ex2_aembey_g4[0] = ex2_aembey_g2[0] | (ex2_aembey_t2[0] & ex2_aembey_g2[1]);
   assign ex2_aembey_g4[1] = ex2_aembey_g2[2] | (ex2_aembey_t2[2] & ex2_aembey_g2[3]);
   assign ex2_aembey_g4[2] = ex2_aembey_g2[4] | (ex2_aembey_t2[4] & ex2_aembey_g2[5]);
   
   assign ex2_aembey_t4[0] = (ex2_aembey_t2[0] & ex2_aembey_t2[1]);
   assign ex2_aembey_t4[1] = (ex2_aembey_t2[2] & ex2_aembey_t2[3]);
   
   
   tri_rlmreg_p #(.WIDTH(80), .IBUF(1'B1), .NEEDS_SRESET(0)) ex3_pass_lat(
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
      .scout(ex3_pass_so),
      .scin(ex3_pass_si),
      .din({  ex2_fsel_bsel,
              ex2_pass_sign,
              ex2_pass_frac[0:52],
              ex2_b_den_flush,
              ex2_lu_den_recip,
              ex2_lu_den_rsqrto,
              ex2_uc_a_expo_den,
              ex2_uc_a_expo_den_sp,
              ex2_a_party_chick,
              ex2_c_party_chick,
              ex2_b_party_chick,
              ex2_ae_ge_54,
              ex2_be_ge_54,
              ex2_be_ge_2,
              ex2_be_ge_2044,
              ex2_aembex_g4[0],		
              ex2_aembex_t4[0],		
              ex2_aembex_g4[1],		
              ex2_aembex_t4[1],		
              ex2_aembex_g4[2],		
              ex2_aembey_g4[0],		
              ex2_aembey_t4[0],		
              ex2_aembey_g4[1],		
              ex2_aembey_t4[1],		
              ex2_aembey_g4[2],		
              ex2_aembex_sgn,		
              ex2_aembey_sgn,
              ex2_be_den}),		
      .dout({ ex3_fsel_bsel,
              ex3_pass_sign,
              ex3_pass_frac[0:52],
              ex3_b_den_flush,
              ex3_lu_den_recip,
              ex3_lu_den_rsqrto,
              ex3_uc_a_expo_den,
              ex3_uc_a_expo_den_sp,
              ex3_a_party_chick,
              ex3_c_party_chick,
              ex3_b_party_chick,
              ex3_ae_ge_54,
              ex3_be_ge_54,
              ex3_be_ge_2,
              ex3_be_ge_2044,
              ex3_aembex_g4[0],		
              ex3_aembex_t4[0],		
              ex3_aembex_g4[1],		
              ex3_aembex_t4[1],		
              ex3_aembex_g4[2],		
              ex3_aembey_g4[0],		
              ex3_aembey_t4[0],		
              ex3_aembey_g4[1],		
              ex3_aembey_t4[1],		
              ex3_aembey_g4[2],		
              ex3_aembex_sgn,		
              ex3_aembey_sgn,
              ex3_be_den})		
   );
   assign f_fmt_ex3_be_den =  ex3_be_den ;
   assign f_mad_ex3_a_parity_check = ex3_a_party_chick;		
   assign f_mad_ex3_c_parity_check = ex3_c_party_chick;		
   assign f_mad_ex3_b_parity_check = ex3_b_party_chick;		
   
   assign f_mad_ex3_uc_a_expo_den = ex3_uc_a_expo_den;
   assign f_mad_ex3_uc_a_expo_den_sp = ex3_uc_a_expo_den_sp;
   assign f_ex3_b_den_flush = ex3_b_den_flush;
   
   assign f_fmt_ex3_fsel_bsel = ex3_fsel_bsel;		
   assign f_fmt_ex3_pass_sign = ex3_pass_sign;		
   assign f_fmt_ex3_pass_msb = ex3_pass_frac[1];		
   
   assign ex3_pass_dp[0:52] = ex3_pass_frac[0:52];
   assign f_fmt_ex3_pass_frac[0:52] = ex3_pass_dp[0:52];		
   
   
   assign ex3_aembex_g8[0] = ex3_aembex_g4[0] | (ex3_aembex_t4[0] & ex3_aembex_g4[1]);
   assign ex3_aembex_g8[1] = ex3_aembex_g4[2];
   assign ex3_aembex_t8[0] = (ex3_aembex_t4[0] & ex3_aembex_t4[1]);
   assign ex3_aembex_c2 = ex3_aembex_g8[0] | (ex3_aembex_t8[0] & ex3_aembex_g8[1]);
   
   assign ex3_aembey_g8[0] = ex3_aembey_g4[0] | (ex3_aembey_t4[0] & ex3_aembey_g4[1]);
   assign ex3_aembey_g8[1] = ex3_aembey_g4[2];
   assign ex3_aembey_t8[0] = (ex3_aembey_t4[0] & ex3_aembey_t4[1]);
   assign ex3_aembey_c2 = ex3_aembey_g8[0] | (ex3_aembey_t8[0] & ex3_aembey_g8[1]);
   
   assign ex3_aembex_res_sgn = ex3_aembex_c2 ^ ex3_aembex_sgn;
   assign ex3_aembey_res_sgn = ex3_aembey_c2 ^ ex3_aembey_sgn;
   
   assign f_fmt_ex3_tdiv_rng_chk = ((~ex3_aembex_res_sgn)) | (ex3_aembey_res_sgn);		
   
   assign f_fmt_ex3_ae_ge_54 = ex3_ae_ge_54;		
   assign f_fmt_ex3_be_ge_54 = ex3_be_ge_54;		
   assign f_fmt_ex3_be_ge_2 = ex3_be_ge_2;		
   assign f_fmt_ex3_be_ge_2044 = ex3_be_ge_2044;		
   
   
   
   assign ex2_ctl_si[0:8] = {ex2_ctl_so[1:8], f_fmt_si};
   assign ex3_pass_si[0:79] = {ex3_pass_so[1:79], ex2_ctl_so[0]};
   assign act_si[0:6] = {act_so[1:6], ex3_pass_so[0]};
   assign f_fmt_so = act_so[0];
   
endmodule
