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

module fu_pic(
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
   f_pic_si,
   f_pic_so,
   f_dcd_ex1_act,
   f_dcd_ex1_aop_valid,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_fsel_b,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_rnd_to_int_b,
   f_dcd_ex1_math_b,
   f_dcd_ex1_est_recip_b,
   f_dcd_ex1_est_rsqrt_b,
   f_dcd_ex1_move_b,
   f_dcd_ex1_compare_b,
   f_dcd_ex1_prenorm_b,
   f_dcd_ex1_frsp_b,
   f_dcd_ex1_mv_to_scr_b,
   f_dcd_ex1_mv_from_scr_b,
   f_dcd_ex1_div_beg,
   f_dcd_ex1_sqrt_beg,
   f_dcd_ex1_force_excp_dis,
   f_dcd_ex1_ftdiv,
   f_dcd_ex1_ftsqrt,
   f_fmt_ex3_ae_ge_54,
   f_fmt_ex3_be_ge_54,
   f_fmt_ex3_be_ge_2,
   f_fmt_ex3_be_ge_2044,
   f_fmt_ex3_tdiv_rng_chk,
   f_dcd_ex1_sp,
   f_dcd_ex1_uns_b,
   f_dcd_ex1_word_b,
   f_dcd_ex1_sp_conv_b,
   f_dcd_ex1_pow2e_b,
   f_dcd_ex1_log2e_b,
   f_dcd_ex1_ordered_b,
   f_dcd_ex1_sub_op_b,
   f_dcd_ex1_op_rnd_v_b,
   f_dcd_ex1_op_rnd_b,
   f_dcd_ex1_inv_sign_b,
   f_dcd_ex1_sign_ctl_b,
   f_dcd_ex1_sgncpy_b,
   f_byp_pic_ex2_a_sign,
   f_byp_pic_ex2_c_sign,
   f_byp_pic_ex2_b_sign,
   f_dcd_ex1_thread,
   f_dcd_ex1_nj_deno,
   f_dcd_ex1_nj_deni,
   f_cr2_ex2_fpscr_shadow_thr0,
   f_cr2_ex2_fpscr_shadow_thr1,
   f_fmt_ex2_sp_invalid,
   f_fmt_ex2_a_zero,
   f_fmt_ex2_a_expo_max,
   f_fmt_ex2_a_frac_zero,
   f_fmt_ex2_a_frac_msb,
   f_fmt_ex2_c_zero,
   f_fmt_ex2_c_expo_max,
   f_fmt_ex2_c_frac_zero,
   f_fmt_ex2_c_frac_msb,
   f_fmt_ex2_b_zero,
   f_fmt_ex2_b_expo_max,
   f_fmt_ex2_b_frac_zero,
   f_fmt_ex2_b_frac_msb,
   f_fmt_ex2_prod_zero,
   f_fmt_ex2_bexpu_le126,
   f_fmt_ex2_gt126,
   f_fmt_ex2_ge128,
   f_fmt_ex2_inf_and_beyond_sp,
   f_alg_ex2_sign_frmw,
   f_fmt_ex3_pass_sign,
   f_fmt_ex3_pass_msb,
   f_fmt_ex2_b_imp,
   f_fmt_ex2_b_frac_z32,
   f_eie_ex3_wd_ov,
   f_eie_ex3_dw_ov,
   f_eie_ex3_wd_ov_if,
   f_eie_ex3_dw_ov_if,
   f_eie_ex3_lt_bias,
   f_eie_ex3_eq_bias_m1,
   f_alg_ex3_sel_byp,
   f_alg_ex3_effsub_eac_b,
   f_alg_ex3_sh_unf,
   f_alg_ex3_sh_ovf,
   f_mad_ex3_uc_a_expo_den,
   f_mad_ex3_uc_a_expo_den_sp,
   f_alg_ex4_int_fr,
   f_alg_ex4_int_fi,
   f_eov_ex5_may_ovf,
   f_add_ex5_fpcc_iu,
   f_add_ex5_sign_carry,
   f_add_ex5_to_int_ovf_wd,
   f_add_ex5_to_int_ovf_dw,

   f_fmt_ex3_be_den,

   f_pic_fmt_ex2_act,
   f_pic_eie_ex2_act,
   f_pic_mul_ex2_act,
   f_pic_alg_ex2_act,
   f_pic_cr2_ex2_act,
   f_pic_tbl_ex2_act,
   f_pic_ex2_ftdiv,

   f_pic_add_ex2_act_b,
   f_pic_lza_ex2_act_b,
   f_pic_eov_ex3_act_b,
   f_pic_nrm_ex4_act_b,
   f_pic_rnd_ex4_act_b,
   f_pic_scr_ex3_act_b,
   f_pic_ex2_rnd_to_int,
   f_pic_ex2_fsel,
   f_pic_ex2_frsp_ue1,
   f_pic_ex3_frsp_ue1,
   f_pic_ex3_ue1,
   f_pic_ex2_effsub_raw,
   f_pic_ex2_from_integer,
   f_pic_ex2_sh_ovf_do,
   f_pic_ex2_sh_ovf_ig_b,
   f_pic_ex2_sh_unf_do,
   f_pic_ex2_sh_unf_ig_b,
   f_pic_ex2_log2e,
   f_pic_ex2_pow2e,
   f_pic_ex2_flush_en_sp,
   f_pic_ex2_flush_en_dp,
   f_pic_ex3_est_recip,
   f_pic_ex3_est_rsqrt,
   f_pic_ex3_force_sel_bexp,
   f_pic_ex3_lzo_dis_prod,
   f_pic_ex3_sp_b,
   f_pic_ex3_sp_lzo,
   f_pic_ex3_to_integer,
   f_pic_ex3_prenorm,
   f_pic_ex3_math_bzer_b,
   f_pic_ex3_b_valid,
   f_pic_ex3_rnd_nr,
   f_pic_ex3_rnd_inf_ok,
   f_pic_ex4_cmp_sgnneg,
   f_pic_ex4_cmp_sgnpos,
   f_pic_ex4_is_eq,
   f_pic_ex4_is_gt,
   f_pic_ex4_is_lt,
   f_pic_ex4_is_nan,
   f_pic_ex4_sp_b,
   f_pic_ex4_sel_est,
   f_dcd_ex1_uc_ft_pos,
   f_dcd_ex1_uc_ft_neg,
   f_dcd_ex1_uc_mid,
   f_dcd_ex1_uc_end,
   f_dcd_ex1_uc_special,
   f_dcd_ex3_uc_zx,
   f_dcd_ex3_uc_vxidi,
   f_dcd_ex3_uc_vxzdz,
   f_dcd_ex3_uc_vxsqrt,
   f_dcd_ex3_uc_vxsnan,
   f_mad_ex4_uc_special,
   f_mad_ex4_uc_zx,
   f_mad_ex4_uc_vxidi,
   f_mad_ex4_uc_vxzdz,
   f_mad_ex4_uc_vxsqrt,
   f_mad_ex4_uc_vxsnan,
   f_mad_ex4_uc_res_sign,
   f_mad_ex4_uc_round_mode,
   f_pic_ex5_byp_prod_nz,
   f_pic_ex5_sel_est_b,
   f_pic_ex2_nj_deni,
   f_pic_ex5_nj_deno,
   f_pic_ex5_oe,
   f_pic_ex5_ov_en,
   f_pic_ex5_ovf_en_oe0_b,
   f_pic_ex5_ovf_en_oe1_b,
   f_pic_ex5_quiet_b,
   f_dcd_ex3_uc_inc_lsb,
   f_dcd_ex3_uc_guard,
   f_dcd_ex3_uc_sticky,
   f_dcd_ex3_uc_gs_v,
   f_pic_ex6_uc_inc_lsb,
   f_pic_ex6_uc_guard,
   f_pic_ex6_uc_sticky,
   f_pic_ex6_uc_g_v,
   f_pic_ex6_uc_s_v,
   f_pic_ex5_rnd_inf_ok_b,
   f_pic_ex5_rnd_ni_b,
   f_pic_ex5_rnd_nr_b,
   f_pic_ex5_sel_fpscr_b,
   f_pic_ex5_sp_b,
   f_pic_ex5_spec_inf_b,
   f_pic_ex5_spec_sel_k_e,
   f_pic_ex5_spec_sel_k_f,
   f_pic_ex5_to_int_ov_all,
   f_pic_ex5_to_integer_b,
   f_pic_ex5_word_b,
   f_pic_ex5_uns_b,
   f_pic_ex5_ue,
   f_pic_ex5_uf_en,
   f_pic_ex5_unf_en_ue0_b,
   f_pic_ex5_unf_en_ue1_b,
   f_pic_ex6_en_exact_zero,
   f_pic_ex6_frsp,
   f_pic_ex6_compare_b,
   f_pic_ex6_fi_pipe_v_b,
   f_pic_ex6_fi_spec_b,
   f_pic_ex6_flag_vxcvi_b,
   f_pic_ex6_flag_vxidi_b,
   f_pic_ex6_flag_vximz_b,
   f_pic_ex6_flag_vxisi_b,
   f_pic_ex6_flag_vxsnan_b,
   f_pic_ex6_flag_vxsqrt_b,
   f_pic_ex6_flag_vxvc_b,
   f_pic_ex6_flag_vxzdz_b,
   f_pic_ex6_flag_zx_b,
   f_pic_ex6_fprf_hold_b,
   f_pic_ex6_fprf_pipe_v_b,
   f_pic_ex6_fprf_spec_b,
   f_pic_ex6_fr_pipe_v_b,
   f_pic_ex6_fr_spec_b,
   f_pic_ex6_invert_sign,
   f_pic_ex6_k_nan,
   f_pic_ex6_k_inf,
   f_pic_ex6_k_max,
   f_pic_ex6_k_zer,
   f_pic_ex6_k_one,
   f_pic_ex6_k_int_maxpos,
   f_pic_ex6_k_int_maxneg,
   f_pic_ex6_k_int_zer,
   f_pic_ex6_ox_pipe_v_b,
   f_pic_ex6_round_sign,
   f_pic_ex6_ux_pipe_v_b,
   f_pic_ex6_scr_upd_move_b,
   f_pic_ex6_scr_upd_pipe_b,
   f_pic_ex6_fpr_wr_dis_b
);
   inout        vdd;
   inout        gnd;
   input        clkoff_b;		// tiup
   input        act_dis;		// ??tidn??
   input        flush;		// ??tidn??
   input [1:5]  delay_lclkr;		// tidn,
   input [1:5]  mpw1_b;		// tidn,
   input [0:1]  mpw2_b;		// tidn,
   input        sg_1;
   input        thold_1;
   input        fpu_enable;		//dc_act
   input  [0:`NCLK_WIDTH-1]       nclk;

   input        f_pic_si;		//perv
   output       f_pic_so;		//perv
   input        f_dcd_ex1_act;		//act

   input        f_dcd_ex1_aop_valid;
   input        f_dcd_ex1_cop_valid;
   input        f_dcd_ex1_bop_valid;

   input        f_dcd_ex1_fsel_b;		// fsel
   input        f_dcd_ex1_from_integer_b;		// fcfid (signed integer)
   input        f_dcd_ex1_to_integer_b;		// fcti* (signed integer 32/64)
   input        f_dcd_ex1_rnd_to_int_b;		// fcti* (signed integer 32/64)
   input        f_dcd_ex1_math_b;		// fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
   input        f_dcd_ex1_est_recip_b;		// fres
   input        f_dcd_ex1_est_rsqrt_b;		// frsqrte
   input        f_dcd_ex1_move_b;		// fmr,fneg,fabs,fnabs
   input        f_dcd_ex1_compare_b;		// fcomp*
   input        f_dcd_ex1_prenorm_b;		// prenorm ?? need
   input        f_dcd_ex1_frsp_b;		// round-to-single-precision ?? need
   input        f_dcd_ex1_mv_to_scr_b;		//mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
   input        f_dcd_ex1_mv_from_scr_b;		//mffs
   input        f_dcd_ex1_div_beg;
   input        f_dcd_ex1_sqrt_beg;
   input        f_dcd_ex1_force_excp_dis;		// ve=ue=xe=ze=oe= 0
   input        f_dcd_ex1_ftdiv;
   input        f_dcd_ex1_ftsqrt;
   input        f_fmt_ex3_ae_ge_54;
   input        f_fmt_ex3_be_ge_54;
   input        f_fmt_ex3_be_ge_2;
   input        f_fmt_ex3_be_ge_2044;
   input        f_fmt_ex3_tdiv_rng_chk;

   input        f_dcd_ex1_sp;		// single precision output
   input        f_dcd_ex1_uns_b;		// convert unsigned
   input        f_dcd_ex1_word_b;		// convert word/dw
   input        f_dcd_ex1_sp_conv_b;		// convert sp/d
   input        f_dcd_ex1_pow2e_b;
   input        f_dcd_ex1_log2e_b;
   input        f_dcd_ex1_ordered_b;		// fcompo
   input        f_dcd_ex1_sub_op_b;		// fsub, fnmsub, fmsub (fcomp)
   input        f_dcd_ex1_op_rnd_v_b;		// fctidz, fctiwz, prenorm, fri*
   input [0:1]  f_dcd_ex1_op_rnd_b;		//
   input        f_dcd_ex1_inv_sign_b;		// fnmsub fnmadd
   input [0:1]  f_dcd_ex1_sign_ctl_b;		// 0:fmr/fneg  1:fneg/fnabs
   input        f_dcd_ex1_sgncpy_b;

   input        f_byp_pic_ex2_a_sign;
   input        f_byp_pic_ex2_c_sign;
   input        f_byp_pic_ex2_b_sign;

   input [0:1]  f_dcd_ex1_thread;
   input        f_dcd_ex1_nj_deno;		// force output den to zero
   input        f_dcd_ex1_nj_deni;		// force output den to zero

   input [0:7]  f_cr2_ex2_fpscr_shadow_thr0;
   input [0:7]  f_cr2_ex2_fpscr_shadow_thr1;

   input        f_fmt_ex2_sp_invalid;
   input        f_fmt_ex2_a_zero;
   input        f_fmt_ex2_a_expo_max;
   input        f_fmt_ex2_a_frac_zero;
   input        f_fmt_ex2_a_frac_msb;
   input        f_fmt_ex2_c_zero;
   input        f_fmt_ex2_c_expo_max;
   input        f_fmt_ex2_c_frac_zero;
   input        f_fmt_ex2_c_frac_msb;
   input        f_fmt_ex2_b_zero;
   input        f_fmt_ex2_b_expo_max;
   input        f_fmt_ex2_b_frac_zero;
   input        f_fmt_ex2_b_frac_msb;
   input        f_fmt_ex2_prod_zero;
   input        f_fmt_ex2_bexpu_le126;		// log2e/pow2e special cases
   input        f_fmt_ex2_gt126;		// log2e/pow2e special cases
   input        f_fmt_ex2_ge128;		// log2e/pow2e special cases
   input        f_fmt_ex2_inf_and_beyond_sp;
   input        f_alg_ex2_sign_frmw;		//?? from_int word is always unsigned (do not need this signal)

   input        f_fmt_ex3_pass_sign;
   input        f_fmt_ex3_pass_msb;
   input        f_fmt_ex2_b_imp;
   input        f_fmt_ex2_b_frac_z32;

   input        f_eie_ex3_wd_ov;
   input        f_eie_ex3_dw_ov;
   input        f_eie_ex3_wd_ov_if;
   input        f_eie_ex3_dw_ov_if;
   input        f_eie_ex3_lt_bias;
   input        f_eie_ex3_eq_bias_m1;

   input        f_alg_ex3_sel_byp;
   input        f_alg_ex3_effsub_eac_b;
   input        f_alg_ex3_sh_unf;
   input        f_alg_ex3_sh_ovf;

   input        f_mad_ex3_uc_a_expo_den;
   input        f_mad_ex3_uc_a_expo_den_sp;

   input        f_alg_ex4_int_fr;
   input        f_alg_ex4_int_fi;

   input        f_eov_ex5_may_ovf;
   input [0:3]  f_add_ex5_fpcc_iu;
   input        f_add_ex5_sign_carry;
   input [0:1]  f_add_ex5_to_int_ovf_wd;
   input [0:1]  f_add_ex5_to_int_ovf_dw;



   input        f_fmt_ex3_be_den;
   output       f_pic_fmt_ex2_act;
   output       f_pic_eie_ex2_act;
   output       f_pic_mul_ex2_act;
   output       f_pic_alg_ex2_act;
   output       f_pic_cr2_ex2_act;
   output       f_pic_tbl_ex2_act;
   output       f_pic_ex2_ftdiv;




   output       f_pic_add_ex2_act_b;		//set
   output       f_pic_lza_ex2_act_b;		//set
   output       f_pic_eov_ex3_act_b;		//set
   output       f_pic_nrm_ex4_act_b;		//set
   output       f_pic_rnd_ex4_act_b;		//set
   output       f_pic_scr_ex3_act_b;		//set

   output       f_pic_ex2_rnd_to_int;
   output       f_pic_ex2_fsel;
   output       f_pic_ex2_frsp_ue1;
   output       f_pic_ex3_frsp_ue1;
   output       f_pic_ex3_ue1;
   output       f_pic_ex2_effsub_raw;
   output       f_pic_ex2_from_integer;
   output       f_pic_ex2_sh_ovf_do;
   output       f_pic_ex2_sh_ovf_ig_b;
   output       f_pic_ex2_sh_unf_do;
   output       f_pic_ex2_sh_unf_ig_b;

   output       f_pic_ex2_log2e;
   output       f_pic_ex2_pow2e;

   output       f_pic_ex2_flush_en_sp;
   output       f_pic_ex2_flush_en_dp;

   output       f_pic_ex3_est_recip;
   output       f_pic_ex3_est_rsqrt;

   output       f_pic_ex3_force_sel_bexp;
   output       f_pic_ex3_lzo_dis_prod;
   output       f_pic_ex3_sp_b;
   output       f_pic_ex3_sp_lzo;
   output       f_pic_ex3_to_integer;
   output       f_pic_ex3_prenorm;
   output       f_pic_ex3_math_bzer_b;
   output       f_pic_ex3_b_valid;
   output       f_pic_ex3_rnd_nr;
   output       f_pic_ex3_rnd_inf_ok;

   output       f_pic_ex4_cmp_sgnneg;
   output       f_pic_ex4_cmp_sgnpos;
   output       f_pic_ex4_is_eq;
   output       f_pic_ex4_is_gt;
   output       f_pic_ex4_is_lt;
   output       f_pic_ex4_is_nan;
   output       f_pic_ex4_sp_b;
   output       f_pic_ex4_sel_est;

   input        f_dcd_ex1_uc_ft_pos;		// force div/sqrt result poitive
   input        f_dcd_ex1_uc_ft_neg;		// force div/sqrt result poitive
   input        f_dcd_ex1_uc_mid;
   input        f_dcd_ex1_uc_end;
   input        f_dcd_ex1_uc_special;
   input        f_dcd_ex3_uc_zx;
   input        f_dcd_ex3_uc_vxidi;
   input        f_dcd_ex3_uc_vxzdz;
   input        f_dcd_ex3_uc_vxsqrt;
   input        f_dcd_ex3_uc_vxsnan;

   output       f_mad_ex4_uc_special;
   output       f_mad_ex4_uc_zx;
   output       f_mad_ex4_uc_vxidi;
   output       f_mad_ex4_uc_vxzdz;
   output       f_mad_ex4_uc_vxsqrt;
   output       f_mad_ex4_uc_vxsnan;
   output       f_mad_ex4_uc_res_sign;
   output [0:1] f_mad_ex4_uc_round_mode;

   output       f_pic_ex5_byp_prod_nz;
   output       f_pic_ex5_sel_est_b;
   output       f_pic_ex2_nj_deni;
   output       f_pic_ex5_nj_deno;
   output       f_pic_ex5_oe;
   output       f_pic_ex5_ov_en;
   output       f_pic_ex5_ovf_en_oe0_b;
   output       f_pic_ex5_ovf_en_oe1_b;
   output       f_pic_ex5_quiet_b;

   input        f_dcd_ex3_uc_inc_lsb;
   input        f_dcd_ex3_uc_guard;
   input        f_dcd_ex3_uc_sticky;
   input        f_dcd_ex3_uc_gs_v;

   output       f_pic_ex6_uc_inc_lsb;
   output       f_pic_ex6_uc_guard;
   output       f_pic_ex6_uc_sticky;
   output       f_pic_ex6_uc_g_v;
   output       f_pic_ex6_uc_s_v;

   output       f_pic_ex5_rnd_inf_ok_b;
   output       f_pic_ex5_rnd_ni_b;
   output       f_pic_ex5_rnd_nr_b;
   output       f_pic_ex5_sel_fpscr_b;
   output       f_pic_ex5_sp_b;
   output       f_pic_ex5_spec_inf_b;
   output       f_pic_ex5_spec_sel_k_e;
   output       f_pic_ex5_spec_sel_k_f;

   output       f_pic_ex5_to_int_ov_all;

   output       f_pic_ex5_to_integer_b;
   output       f_pic_ex5_word_b;
   output       f_pic_ex5_uns_b;
   output       f_pic_ex5_ue;
   output       f_pic_ex5_uf_en;
   output       f_pic_ex5_unf_en_ue0_b;
   output       f_pic_ex5_unf_en_ue1_b;

   output       f_pic_ex6_en_exact_zero;
   output       f_pic_ex6_frsp;
   output       f_pic_ex6_compare_b;
   output       f_pic_ex6_fi_pipe_v_b;
   output       f_pic_ex6_fi_spec_b;
   output       f_pic_ex6_flag_vxcvi_b;
   output       f_pic_ex6_flag_vxidi_b;
   output       f_pic_ex6_flag_vximz_b;
   output       f_pic_ex6_flag_vxisi_b;
   output       f_pic_ex6_flag_vxsnan_b;
   output       f_pic_ex6_flag_vxsqrt_b;
   output       f_pic_ex6_flag_vxvc_b;
   output       f_pic_ex6_flag_vxzdz_b;
   output       f_pic_ex6_flag_zx_b;
   output       f_pic_ex6_fprf_hold_b;
   output       f_pic_ex6_fprf_pipe_v_b;
   output [0:4] f_pic_ex6_fprf_spec_b;
   output       f_pic_ex6_fr_pipe_v_b;
   output       f_pic_ex6_fr_spec_b;
   output       f_pic_ex6_invert_sign;

   output       f_pic_ex6_k_nan;
   output       f_pic_ex6_k_inf;
   output       f_pic_ex6_k_max;
   output       f_pic_ex6_k_zer;
   output       f_pic_ex6_k_one;
   output       f_pic_ex6_k_int_maxpos;
   output       f_pic_ex6_k_int_maxneg;
   output       f_pic_ex6_k_int_zer;
   output       f_pic_ex6_ox_pipe_v_b;
   output       f_pic_ex6_round_sign;
   output       f_pic_ex6_ux_pipe_v_b;
   output       f_pic_ex6_scr_upd_move_b;
   output       f_pic_ex6_scr_upd_pipe_b;
   output       f_pic_ex6_fpr_wr_dis_b;

   // ENTITY


   parameter    tiup = 1'b1;
   parameter    tidn = 1'b0;

   wire         thold_0_b;
   wire         thold_0;
   wire         force_t;
   wire         sg_0;

   wire         ex1_act;
   wire         ex2_act;
   wire         ex3_act;
   wire         ex4_act;
   wire         ex5_act;

   wire         ex2_act_add;
   wire         ex2_act_lza;
   wire         ex3_act_eov;
   wire         ex3_act_scr;
   wire         ex4_act_nrm;
   wire         ex4_act_rnd;
   (* analysis_not_referenced="TRUE" *) // spare_unused
   wire [0:3]   spare_unused;
   wire [0:20]  act_so;
   wire [0:20]  act_si;

   wire [0:44]  ex2_ctl_so;
   wire [0:44]  ex2_ctl_si;
   wire [0:56]  ex3_ctl_so;
   wire [0:56]  ex3_ctl_si;
   wire [0:33]  ex4_ctl_so;
   wire [0:33]  ex4_ctl_si;
   wire [0:28]  ex5_ctl_so;
   wire [0:28]  ex5_ctl_si;
   wire [0:17]  ex3_flg_so;
   wire [0:17]  ex3_flg_si;
   wire [0:7]   ex4_scr_so;
   wire [0:7]   ex4_scr_si;
   wire [0:46]  ex4_flg_so;
   wire [0:46]  ex4_flg_si;
   wire [0:7]   ex5_scr_so;
   wire [0:7]   ex5_scr_si;
   wire [0:37]  ex5_flg_so;
   wire [0:37]  ex5_flg_si;
   wire [0:41]  ex6_flg_so;
   wire [0:41]  ex6_flg_si;

   wire         ex5_may_ovf;
   wire         ex6_unused;
   wire         ex3_a_sign;
   wire         ex4_pass_nan;
   wire         ex3_pass_x;

   wire [0:1]   ex2_rnd_fpscr;
   wire [0:1]   ex3_rnd_fpscr;
   wire [0:1]   ex4_rnd_fpscr;
   wire         ex2_div_sign;
   wire         ex3_div_sign;
   wire         ex4_div_sign;
   wire [0:1]   ex1_thread;
   wire         ex4_ve;
   wire         ex4_oe;
   wire         ex4_ue;
   wire         ex4_ze;
   wire         ex4_xe;
   wire         ex4_nonieee;
   wire         ex4_rnd0;
   wire         ex4_rnd1;
   wire         ex5_ve;
   wire         ex5_oe;
   wire         ex5_ue;
   wire         ex5_ze;
   wire         ex5_xe;
   wire         ex5_nonieee;
   wire         ex5_rnd0;
   wire         ex5_rnd1;
   wire         ex3_toint_nan_sign;

   wire         ex2_uc_ft_neg;
   wire         ex3_uc_ft_neg;
   wire         ex4_uc_ft_neg;
   wire         ex2_uc_ft_pos;
   wire         ex3_uc_ft_pos;
   wire         ex4_uc_ft_pos;
   wire         ex2_a_inf;
   wire         ex2_a_nan;
   wire         ex2_a_sign;
   wire         ex2_b_inf;
   wire         ex2_b_nan;
   wire         ex2_b_sign;
   wire         ex2_b_sign_adj;
   wire         ex2_b_sign_adj_x;
   wire         ex2_b_sign_alt;
   wire         ex2_a_valid;
   wire         ex2_c_valid;
   wire         ex2_b_valid;
   wire         ex2_c_inf;
   wire         ex2_sp_invalid;
   wire         ex3_sp_invalid;
   wire         ex2_c_nan;
   wire         ex2_c_sign;
   wire         ex2_compare;
   wire         ex2_div_beg;
   wire         ex2_est_recip;
   wire         ex2_est_rsqrt;
   wire         ex2_op_rnd_v;
   wire [0:1]   ex2_op_rnd;
   wire         ex2_from_integer;
   wire         ex2_frsp;
   wire         ex2_fsel;
   wire         ex2_inv_sign;
   wire         ex2_lzo_dis;
   wire         ex2_uc_mid;
   wire         ex3_uc_mid;
   wire         ex4_uc_mid;
   wire         ex5_uc_mid;
   wire         ex2_math;
   wire         ex2_move;
   wire         ex2_mv_from_scr;
   wire         ex2_mv_to_scr;
   wire         ex2_p_sign;
   wire         ex2_prenorm;
   wire [0:1]   ex2_sign_ctl;
   wire         ex2_sp;
   wire         ex2_sp_b;
   wire         ex2_sqrt_beg;
   wire         ex2_sub_op;
   wire         ex2_to_integer;
   wire         ex2_ordered;
   wire         ex2_word;
   wire         ex1_uns;
   wire         ex1_sp_conv;
   wire         ex2_uns;
   wire         ex3_uns;
   wire         ex4_uns;
   wire         ex5_uns;
   wire         ex2_sp_conv;
   wire         ex3_a_frac_msb;
   wire         ex3_a_inf;
   wire         ex3_a_nan;
   wire         ex3_a_zero;
   wire         ex3_any_inf;
   wire         ex3_b_frac_msb;
   wire         ex3_b_inf;
   wire         ex3_b_nan;
   wire         ex3_b_sign_adj;
   wire         ex3_to_int_uns_neg;
   wire         ex4_to_int_uns_neg;
   wire         ex5_to_int_uns_neg;
   wire         ex3_wd_ov_x;
   wire         ex3_dw_ov_x;
   wire         ex3_b_sign_alt;
   wire         ex3_b_zero;
   wire         ex4_b_zero;
   wire         ex3_c_frac_msb;
   wire         ex3_c_inf;
   wire         ex3_c_nan;
   wire         ex3_c_zero;
   wire         ex3_cmp_sgnneg;
   wire         ex3_cmp_sgnpos;
   wire         ex3_cmp_zero;
   wire         ex3_compare;
   wire         ex3_div_beg;
   wire         ex4_div_beg;
   wire         ex5_div_beg;
   wire         ex3_est_recip;
   wire         ex3_est_rsqrt;
   wire         ex3_rnd_dis;
   wire [0:1]   ex3_op_rnd;
   wire         ex3_from_integer;
   wire         ex3_frsp;
   wire         ex3_fsel;
   wire         ex3_gen_inf;
   wire         ex3_gen_max;
   wire         ex3_gen_nan;
   wire         ex3_gen_zero;
   wire         ex3_inf_sign;
   wire         ex3_inv_sign;
   wire         ex3_is_eq;
   wire         ex3_is_gt;
   wire         ex3_is_lt;
   wire         ex3_is_nan;
   wire         ex3_lzo_dis;
   wire         ex3_math;
   wire         ex3_move;
   wire         ex3_mv_from_scr;
   wire         ex3_mv_to_scr;
   wire         ex3_neg_sqrt_nz;
   wire         ex3_p_inf;
   wire         ex3_p_sign;
   wire         ex3_p_zero;
   wire         ex3_pass_en;
   wire         ex3_pass_nan;
   wire         ex3_prenorm;
   wire         ex3_quiet;
   wire         ex3_rnd0;
   wire         ex3_rnd1;
   wire         ex3_rnd_inf_ok;
   wire         ex3_rnd_nr;
   wire         ex3_sp;
   wire         ex3_sp_notrunc;
   wire         ex3_sp_o_frsp;
   wire         ex3_spec_sign;
   wire         ex3_sqrt_beg;
   wire         ex4_sqrt_beg;
   wire         ex5_sqrt_beg;
   wire         ex3_sub_op;
   wire         ex3_to_integer;
   wire         ex3_ue;
   wire         ex3_ordered;
   wire         ex3_nonieee;
   wire         ex3_ze;
   wire         ex3_ve;
   wire         ex3_oe;
   wire         ex3_xe;
   wire         ex3_vxcvi;
   wire         ex3_vxidi;
   wire         ex3_vximz;
   wire         ex3_vxisi;
   wire         ex3_vxsnan;
   wire         ex3_vxsqrt;
   wire         ex3_vxvc;
   wire         ex3_vxzdz;
   wire         ex3_word;
   wire         ex3_zx;
   wire         ex4_b_sign_adj;
   wire         ex4_b_sign_alt;
   wire         ex4_cmp_sgnneg;
   wire         ex4_cmp_sgnpos;
   wire         ex4_compare;
   wire         ex4_dw_ov;
   wire         ex4_dw_ov_if;
   wire         ex4_effsub_eac;
   wire         ex5_effsub_eac;
   wire         ex4_est_recip;
   wire         ex4_est_rsqrt;
   wire         ex4_rnd_dis;
   wire         ex4_from_integer;
   wire         ex4_frsp;
   wire         ex4_fsel;
   wire         ex4_gen_inf;
   wire         ex4_gen_inf_mutex;
   wire         ex4_gen_max_mutex;
   wire         ex4_gen_max;
   wire         ex4_gen_nan;
   wire         ex4_gen_nan_mutex;
   wire         ex4_gen_zer_mutex;
   wire         ex4_gen_zero;
   wire         ex4_inv_sign;
   wire         ex4_is_eq;
   wire         ex4_is_gt;
   wire         ex4_is_lt;
   wire         ex4_is_nan;
   wire         ex4_math;
   wire         ex4_move;
   wire         ex4_mv_from_scr;
   wire         ex4_mv_to_scr;
   wire         ex4_oe_x;
   wire         ex4_ov_en;
   wire         ex4_ovf_en_oe0;
   wire         ex4_ovf_en_oe1;
   wire         ex4_p_sign;
   wire         ex4_p_sign_may;
   wire         ex4_prenorm;
   wire         ex4_quiet;
   wire         ex4_sel_byp;
   wire         ex4_sh_ovf;
   wire         ex4_sh_unf;
   wire         ex4_sign_nco;
   wire         ex4_sign_pco;
   wire         ex4_sp;
   wire         ex4_sp_x;
   wire         ex4_sp_conv;
   wire         ex3_sp_conv;
   wire         ex4_spec_sel_e;
   wire         ex4_spec_sel_f;
   wire         ex4_spec_sign;
   wire         ex4_spec_sign_x;
   wire         ex4_spec_sign_sel;
   wire         ex4_sub_op;
   wire         ex4_to_int_dw;
   wire         ex4_to_int_ov;
   wire         ex4_to_int_ov_if;
   wire         ex4_to_int_wd;
   wire         ex4_to_integer;
   wire         ex4_ue_x;
   wire         ex4_uf_en;
   wire         ex4_unf_en_oe0;
   wire         ex4_unf_en_oe1;
   wire         ex4_vxcvi;
   wire         ex4_vxidi;
   wire         ex4_vximz;
   wire         ex4_vxisi;
   wire         ex4_vxsnan;
   wire         ex4_vxsqrt;
   wire         ex4_vxvc;
   wire         ex4_vxzdz;
   wire         ex4_wd_ov;
   wire         ex4_wd_ov_if;
   wire         ex4_word;
   wire         ex4_word_to;
   wire         ex4_zx;
   wire         ex5_compare;
   wire         ex6_compare;
   wire         ex5_en_exact_zero;
   wire         ex5_est_recip;
   wire         ex5_est_rsqrt;
   wire         ex5_rnd_dis;
   wire         ex5_fpr_wr_dis;
   wire         ex5_fprf_pipe_v;
   wire [0:4]   ex5_fprf_spec;
   wire [0:4]   ex5_fprf_spec_x;
   wire         ex5_fr_pipe_v;
   wire         ex5_from_integer;
   wire         ex5_frsp;
   wire         ex6_frsp;
   wire         ex5_fsel;
   wire         ex5_gen_inf;
   wire         ex5_gen_inf_sign;
   wire         ex5_gen_max;
   wire         ex5_gen_nan;
   wire         ex5_pass_nan;
   wire         ex5_gen_zero;
   wire         ex5_inv_sign;
   wire         ex5_invert_sign;
   wire         ex5_k_max_fp;
   wire         ex5_math;
   wire         ex5_move;
   wire         ex5_mv_from_scr;
   wire         ex5_mv_to_scr;
   wire         ex5_ov_en;
   wire         ex5_ovf_en_oe0;
   wire         ex5_ovf_en_oe1;
   wire         ex5_ox_pipe_v;
   wire         ex5_prenorm;
   wire         ex5_quiet;
   wire         ex5_rnd_en;
   wire         ex5_rnd_inf_ok;
   wire         ex5_rnd_pi;
   wire         ex5_rnd_ni;
   wire         ex5_rnd_nr;
   wire         ex5_rnd_zr;
   wire         ex5_rnd_nr_ok;
   wire         ex5_round_sign;
   wire         ex5_round_sign_x;
   wire         ex5_scr_upd_move;
   wire         ex5_scr_upd_pipe;
   wire         ex5_sel_spec_e;
   wire         ex5_sel_spec_f;
   wire         ex5_sel_spec_fr;
   wire         ex5_sign_nco;
   wire         ex5_sign_pco;
   wire         ex5_sign_nco_x;
   wire         ex5_sign_pco_x;
   wire         ex5_sign_nco_xx;
   wire         ex5_sign_pco_xx;
   wire         ex5_sp;
   wire         ex5_spec_sel_e;
   wire         ex5_spec_sel_f;
   wire         ex5_sub_op;
   wire         ex5_to_int_dw;
   wire         ex5_to_int_ov;
   wire         ex5_to_int_ov_if;
   wire         ex5_to_int_wd;
   wire         ex5_to_integer;
   wire         ex5_uf_en;
   wire         ex5_unf_en_oe0;
   wire         ex5_unf_en_oe1;
   wire         ex5_upd_fpscr_ops;
   wire         ex5_vx;
   wire         ex5_vxidi;
   wire         ex5_vximz;
   wire         ex5_vxisi;
   wire         ex5_vxsnan;
   wire         ex5_vxsqrt;
   wire         ex5_vxvc;
   wire         ex5_vxcvi;
   wire         ex5_vxcvi_ov;
   wire         ex5_to_int_ov_all_x;
   wire         ex5_to_int_ov_all;
   wire         ex5_to_int_ov_all_gt;
   wire         ex5_to_int_k_sign;
   wire         ex5_vxzdz;
   wire         ex5_word;
   wire         ex5_zx;
   wire         ex6_en_exact_zero;
   wire         ex6_fpr_wr_dis;
   wire         ex6_fprf_pipe_v;
   wire [0:4]   ex6_fprf_spec;
   wire         ex6_fr_pipe_v;
   wire         ex6_invert_sign;
   wire         ex6_ox_pipe_v;
   wire         ex6_round_sign;
   wire         ex6_scr_upd_move;
   wire         ex6_scr_upd_pipe;
   wire         ex6_vxcvi;
   wire         ex6_vxidi;
   wire         ex6_vximz;
   wire         ex6_vxisi;
   wire         ex6_vxsnan;
   wire         ex6_vxsqrt;
   wire         ex6_vxvc;
   wire         ex6_vxzdz;
   wire         ex6_zx;
   wire         ex6_k_nan;
   wire         ex6_k_inf;
   wire         ex6_k_max;
   wire         ex6_k_zer;
   wire         ex6_k_int_maxpos;
   wire         ex6_k_int_maxneg;
   wire         ex6_k_int_zer;
   wire         ex5_gen_any;
   wire         ex5_k_nan;
   wire         ex5_k_inf;
   wire         ex5_k_max;
   wire         ex5_k_zer;
   wire         ex5_k_int_maxpos;
   wire         ex5_k_int_maxneg;
   wire         ex5_k_int_zer;
   wire         ex5_k_nan_x;
   wire         ex5_k_inf_x;
   wire         ex5_k_max_x;
   wire         ex5_k_zer_x;
   wire         ex3_a_valid;
   wire         ex3_c_valid;
   wire         ex3_b_valid;
   wire         ex3_prod_zero;
   wire         ex5_byp_prod_nz;
   wire         ex4_byp_prod_nz;
   wire         ex4_byp_prod_nz_sub;
   wire         ex4_a_valid;
   wire         ex4_c_valid;
   wire         ex4_b_valid;
   wire         ex4_prod_zero;
   wire         ex5_int_fr;
   wire         ex5_int_fi;
   wire         ex5_fi_spec;
   wire         ex5_fr_spec;
   wire         ex6_fi_spec;
   wire         ex6_fr_spec;
   wire         ex3_toint_genz;
   wire         ex3_a_snan;
   wire         ex3_b_snan;
   wire         ex3_c_snan;
   wire         ex3_a_qnan;
   wire         ex3_b_qnan;
   wire         ex3_nan_op_grp1;
   wire         ex3_nan_op_grp2;
   wire         ex3_compo;
   wire         ex6_fprf_hold;
   wire         ex5_fprf_hold;
   wire         ex5_fprf_hold_ops;
   wire         ex2_bf_10000;
   wire         ex3_bf_10000;
   wire         ex4_bf_10000;

   wire         ex2_rnd_to_int;
   wire         ex3_rnd_to_int;
   wire         ex4_rnd_to_int;
   wire         ex5_rnd_to_int;
   wire         ex4_lt_bias;
   wire         ex4_eq_bias_m1;
   wire         ex4_gen_rnd2int;
   wire         ex4_gen_one_rnd2int;
   wire         ex4_gen_zer_rnd2int;
   wire         ex3_gen_one;
   wire         ex4_gen_one;
   wire         ex4_gen_one_mutex;
   wire         ex5_gen_one;
   wire         ex5_k_one;
   wire         ex6_k_one;
   wire         ex5_k_one_x;
   wire         ex4_rnd2int_up;
   wire         ex5_sel_est;
   wire         ex2_ve;
   wire         ex2_oe;
   wire         ex2_ue;
   wire         ex2_ze;
   wire         ex2_xe;
   wire         ex2_nonieee;
   wire         ex2_rnd0;
   wire         ex2_rnd1;
   wire         ex2_rnd_dis;
   wire         ex1_fsel;
   wire         ex1_from_integer;
   wire         ex1_to_integer;
   wire         ex1_math;
   wire         ex1_est_recip;
   wire         ex1_est_rsqrt;
   wire         ex1_move;
   wire         ex1_compare;
   wire         ex1_prenorm;
   wire         ex1_frsp;
   wire         ex1_mv_to_scr;
   wire         ex1_mv_from_scr;
   wire         ex1_div_beg;
   wire         ex1_sqrt_beg;
   wire         ex1_sp;
   wire         ex1_word;
   wire         ex1_ordered;
   wire         ex1_sub_op;
   wire         ex1_op_rnd_v;
   wire         ex1_inv_sign;
   wire [0:1]   ex1_sign_ctl;
   wire         ex1_sgncpy;
   wire         ex2_sgncpy;
   wire [0:1]   ex1_op_rnd;
   wire         ex1_rnd_to_int;
   wire         ex3_effsub_eac;
   wire         ex2_flush_dis_dp;
   wire         ex2_flush_dis_sp;
   wire         ex5_to_integer_ken;
   wire         ex1_log2e;
   wire         ex1_pow2e;
   wire         ex2_log2e;
   wire         ex2_pow2e;
   wire         ex3_log2e;
   wire         ex3_pow2e;
   wire         ex4_log2e;
   wire         ex4_pow2e;
   wire         ex5_log2e;
   wire         ex5_pow2e;
   wire         ex3_log_ofzero;
   wire         ex3_bexpu_le126;
   wire         ex3_gt126;
   wire         ex3_ge128;
   wire         ex3_gen_nan_log;
   wire         ex3_gen_inf_log;
   wire         ex3_gen_inf_pow;
   wire         ex3_gen_zero_pow;
   wire         ex2_ovf_unf_dis;
   wire         ex3_ovf_unf_dis;
   wire         ex4_ovf_unf_dis;
   wire         ex5_ovf_unf_dis;
   wire         ex3_exact_zero_sign;
   wire         ex3_rnd_ni;
   wire         ex3_gen_inf_sq;
   wire         ex3_gen_inf_dv;
   wire         ex3_gen_zer_sq;
   wire         ex3_gen_zer_dv;
   wire         ex3_gen_nan_sq;
   wire         ex3_gen_nan_dv;
   wire         ex3_prenorm_special;
   wire         ex3_prenorm_sign;

   wire         ex4_uc_inc_lsb;
   wire         ex5_uc_inc_lsb;
   wire         ex6_uc_inc_lsb;
   wire         ex4_uc_guard;
   wire         ex5_uc_guard;
   wire         ex6_uc_guard;
   wire         ex4_uc_sticky;
   wire         ex5_uc_sticky;
   wire         ex6_uc_sticky;
   wire         ex4_uc_gs_v;
   wire         ex5_uc_gs_v;
   wire         ex5_uc_s_v;
   wire         ex5_uc_g_v;
   wire         ex6_uc_s_v;
   wire         ex6_uc_g_v;
   wire         ex3_uc_g_ig;
   wire         ex4_uc_g_ig;
   wire         ex5_uc_g_ig;
   wire         ex2_force_excp_dis;
   wire         ex1_uc_end_nspec;
   wire         ex2_uc_end_nspec;
   wire         ex1_uc_end_spec;
   wire         ex2_uc_end_spec;
   wire         ex3_uc_end_spec;
   wire         ex4_uc_end_spec;
   wire         ex5_uc_end_spec;
   (* analysis_not_referenced="TRUE" *) // unused
   wire         unused;
   wire         ex1_nj_deno_x;
   wire         ex2_nj_deno;
   wire         ex3_nj_deno;
   wire         ex4_nj_deno;
   wire         ex4_nj_deno_x;
   wire         ex5_nj_deno;
   wire         ex1_nj_deni_x;
   wire         ex2_nj_deni;
   wire         ex1_den_ok;
   wire         ex3_gen_nan_pow;
   wire         ex3_inf_and_beyond_sp;
   wire         ex2_ftdiv;
   wire         ex2_ftsqrt;
   wire         ex3_ftdiv;
   wire         ex3_ftsqrt;
   wire         ex3_accuracy;
   wire         ex3_b_imp;

   wire [0:7]   ex2_fpscr_shadow;
   wire [0:1]   ex2_thread;

   ////################################################################
   ////# map block attributes
   ////################################################################


   assign unused = ex4_byp_prod_nz_sub | ex5_sel_spec_f |
	           ex1_act |
                   ex3_op_rnd[0] | ex3_op_rnd[1] | ex4_b_sign_adj | ex4_b_valid |
                   ex4_gen_max | ex4_sh_unf | ex4_sh_ovf | ex5_nonieee | ex5_xe | ex5_fsel | ex5_move |
                   ex5_prenorm | ex5_div_beg | ex5_sqrt_beg | ex5_sub_op | ex5_log2e | ex5_pow2e | ex6_unused;		//lat--

   ////################################################################
   ////# pervasive
   ////################################################################


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

   ////################################################################
   ////# act
   ////################################################################

   //  act_lat:  entity WORK.tri_rlmreg_p generic map (width=> 22, expand_type => expand_type) port map (

   tri_rlmreg_p #(.WIDTH(21)) act_lat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .act(fpu_enable),		//tiup
      .thold_b(thold_0_b),		//tiup,
      .sg(sg_0),		//tidn,
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({spare_unused[0],
            spare_unused[1],
            tiup,		//is2_act,
            f_dcd_ex1_act,		//is2_act,
            f_dcd_ex1_act,		//is2_act,
            f_dcd_ex1_act,		//is2_act,
            f_dcd_ex1_act,		//is2_act,
            tiup,		//is2_act,
            f_dcd_ex1_act,		//rf0_act,
            f_dcd_ex1_act,		//rf0_act,
            f_dcd_ex1_act,		//ex1_act,
            f_dcd_ex1_act,		//ex1_act,
            ex2_act,		//ex1_act,
            ex2_act,
            ex2_act,
            ex3_act,
            ex3_act,
            ex3_act,
            ex4_act,
            spare_unused[2],
            spare_unused[3]}),
      //-----------------
      .dout({spare_unused[0],
             spare_unused[1],
             f_pic_fmt_ex2_act ,
             f_pic_eie_ex2_act ,
             f_pic_mul_ex2_act ,
             f_pic_alg_ex2_act ,
             f_pic_cr2_ex2_act ,
             ex1_act,
             f_pic_tbl_ex2_act ,
             ex2_act,
             ex2_act_add,
             ex2_act_lza,
             ex3_act,
             ex3_act_eov,
             ex3_act_scr,
             ex4_act,
             ex4_act_nrm,
             ex4_act_rnd,
             ex5_act,
             spare_unused[2],
             spare_unused[3]})
   );


   assign f_pic_add_ex2_act_b = (~ex2_act_add);
   assign f_pic_lza_ex2_act_b = (~ex2_act_lza);
   assign f_pic_eov_ex3_act_b = (~ex3_act_eov);
   assign f_pic_scr_ex3_act_b = (~ex3_act_scr);
   assign f_pic_nrm_ex4_act_b = (~ex4_act_nrm);
   assign f_pic_rnd_ex4_act_b = (~ex4_act_rnd);

   ////################################################################
   ////# ex1 logic
   ////################################################################

   ////################################################################
   ////# ex2 latches
   ////################################################################

   assign ex1_fsel = (~f_dcd_ex1_fsel_b);
   assign ex1_from_integer = (~f_dcd_ex1_from_integer_b);
   assign ex1_to_integer = (~f_dcd_ex1_to_integer_b);
   assign ex1_math = (~f_dcd_ex1_math_b);
   assign ex1_est_recip = (~f_dcd_ex1_est_recip_b);
   assign ex1_est_rsqrt = (~f_dcd_ex1_est_rsqrt_b);
   assign ex1_move = (~f_dcd_ex1_move_b);
   assign ex1_compare = (~f_dcd_ex1_compare_b);
   assign ex1_prenorm = (~(f_dcd_ex1_prenorm_b)) | f_dcd_ex1_div_beg | f_dcd_ex1_sqrt_beg;
   assign ex1_frsp = (~f_dcd_ex1_frsp_b);
   assign ex1_mv_to_scr = (~f_dcd_ex1_mv_to_scr_b);
   assign ex1_mv_from_scr = (~f_dcd_ex1_mv_from_scr_b);
   assign ex1_div_beg = f_dcd_ex1_div_beg;
   assign ex1_sqrt_beg = f_dcd_ex1_sqrt_beg;
   assign ex1_sp = (~f_dcd_ex1_sp);
   assign ex1_word = (~f_dcd_ex1_word_b);
   assign ex1_uns = (~f_dcd_ex1_uns_b);
   assign ex1_sp_conv = (~f_dcd_ex1_sp_conv_b);
   assign ex1_ordered = (~f_dcd_ex1_ordered_b);
   assign ex1_sub_op = (~f_dcd_ex1_sub_op_b);
   assign ex1_op_rnd_v = (~f_dcd_ex1_op_rnd_v_b);
   assign ex1_inv_sign = (~f_dcd_ex1_inv_sign_b);
   assign ex1_sign_ctl[0] = (~f_dcd_ex1_sign_ctl_b[0]);
   assign ex1_sign_ctl[1] = (~f_dcd_ex1_sign_ctl_b[1]);
   assign ex1_sgncpy = (~f_dcd_ex1_sgncpy_b);
   assign ex1_op_rnd[0] = (~f_dcd_ex1_op_rnd_b[0]);
   assign ex1_op_rnd[1] = (~f_dcd_ex1_op_rnd_b[1]);
   assign ex1_rnd_to_int = (~f_dcd_ex1_rnd_to_int_b);
   assign ex1_log2e = (~f_dcd_ex1_log2e_b);
   assign ex1_pow2e = (~f_dcd_ex1_pow2e_b);
   assign ex1_uc_end_nspec = f_dcd_ex1_uc_end & (~f_dcd_ex1_uc_special);
   assign ex1_uc_end_spec = f_dcd_ex1_uc_end & f_dcd_ex1_uc_special;

   assign ex1_den_ok = ex1_move | ex1_mv_to_scr | ex1_mv_from_scr | ex1_fsel | f_dcd_ex1_uc_mid;

   assign ex1_nj_deno_x = f_dcd_ex1_nj_deno & (~f_dcd_ex1_div_beg) & (~f_dcd_ex1_sqrt_beg) & (~ex1_to_integer) & (~ex1_den_ok);		// do not want denorm outputs in the middle of a divide

   assign ex1_nj_deni_x = f_dcd_ex1_nj_deni & (~ex1_den_ok);		// do not want denorm outputs in the middle of a divide

   assign ex1_thread = f_dcd_ex1_thread;


   tri_rlmreg_p #(.WIDTH(45)) ex2_ctl_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(f_dcd_ex1_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex2_ctl_so),
      .scin(ex2_ctl_si),
      //-----------------
      .din({  ex1_fsel,
              ex1_from_integer,
              ex1_to_integer,
              ex1_math,
              ex1_est_recip,
              ex1_est_rsqrt,
              ex1_move,
              ex1_compare,
              ex1_prenorm,
              ex1_frsp,
              ex1_mv_to_scr,
              ex1_mv_from_scr,
              ex1_div_beg,
              ex1_sqrt_beg,
              ex1_sp,
              ex1_word,
              ex1_ordered,
              ex1_sub_op,
              f_dcd_ex1_uc_mid,
              ex1_op_rnd_v,
              ex1_inv_sign,
              ex1_sign_ctl[0],
              ex1_sign_ctl[1],
              f_dcd_ex1_aop_valid,
              f_dcd_ex1_cop_valid,
              f_dcd_ex1_bop_valid,
              ex1_op_rnd[0],
              ex1_op_rnd[1],
              ex1_rnd_to_int,
              ex1_uns,
              ex1_sp_conv,
              ex1_sgncpy,
              ex1_log2e,
              ex1_pow2e,
              f_dcd_ex1_uc_ft_pos,
              f_dcd_ex1_uc_ft_neg,
              f_dcd_ex1_force_excp_dis,
              ex1_uc_end_nspec,
              ex1_uc_end_spec,
              ex1_nj_deno_x,
              ex1_nj_deni_x,
              f_dcd_ex1_ftdiv,
              f_dcd_ex1_ftsqrt,
              ex1_thread}),
      //-----------------
      .dout({  ex2_fsel,
               ex2_from_integer,
               ex2_to_integer,
               ex2_math,
               ex2_est_recip,
               ex2_est_rsqrt,
               ex2_move,
               ex2_compare,
               ex2_prenorm,
               ex2_frsp,
               ex2_mv_to_scr,
               ex2_mv_from_scr,
               ex2_div_beg,
               ex2_sqrt_beg,
               ex2_sp_b,
               ex2_word,
               ex2_ordered,
               ex2_sub_op,
               ex2_uc_mid,
               ex2_op_rnd_v,
               ex2_inv_sign,
               ex2_sign_ctl[0],
               ex2_sign_ctl[1],
               ex2_a_valid,
               ex2_c_valid,
               ex2_b_valid,
               ex2_op_rnd[0],
               ex2_op_rnd[1],
               ex2_rnd_to_int,
               ex2_uns,
               ex2_sp_conv,
               ex2_sgncpy,
               ex2_log2e,
               ex2_pow2e,
               ex2_uc_ft_pos,
               ex2_uc_ft_neg,
               ex2_force_excp_dis,
               ex2_uc_end_nspec,
               ex2_uc_end_spec,
               ex2_nj_deno,
               ex2_nj_deni,
               ex2_ftdiv,
               ex2_ftsqrt,
               ex2_thread})
   );

   assign f_pic_ex2_nj_deni = ex2_nj_deni;

   assign ex2_ovf_unf_dis = ex2_uc_mid | ex2_prenorm | ex2_move | ex2_fsel | ex2_mv_to_scr | ex2_mv_from_scr;

   assign ex2_fpscr_shadow = (f_cr2_ex2_fpscr_shadow_thr0 & {8{ex2_thread[0]}}) |
                             (f_cr2_ex2_fpscr_shadow_thr1 & {8{ex2_thread[1]}});

   assign ex2_ve = ex2_fpscr_shadow[0] & (~ex2_force_excp_dis);		// 24
   assign ex2_oe = ex2_fpscr_shadow[1] & (~ex2_force_excp_dis);		// 25
   assign ex2_ue = ex2_fpscr_shadow[2] & (~ex2_force_excp_dis);		// 26
   assign ex2_ze = ex2_fpscr_shadow[3] & (~ex2_force_excp_dis);		// 27
   assign ex2_xe = ex2_fpscr_shadow[4] & (~ex2_force_excp_dis);		// 28
   assign ex2_nonieee = ex2_fpscr_shadow[5];		// 29

   assign ex2_rnd_fpscr[0:1] = ex2_fpscr_shadow[6:7];

   assign ex2_rnd0 = (ex2_fpscr_shadow[6] & (~ex2_op_rnd_v)) | (ex2_op_rnd[0] & ex2_op_rnd_v);		// 30
   assign ex2_rnd1 = (ex2_fpscr_shadow[7] & (~ex2_op_rnd_v)) | (ex2_op_rnd[1] & ex2_op_rnd_v);		// 31
   assign ex2_rnd_dis = tidn & f_fmt_ex2_prod_zero & ex2_nj_deni;		// force truncate "01"

   assign f_pic_ex2_rnd_to_int = ex2_rnd_to_int;		//output--

   // denorm input forced to zero
   assign ex2_flush_dis_sp = ex2_uc_mid | ex2_fsel | ex2_log2e | ex2_pow2e | ex2_prenorm | ex2_move | ex2_to_integer | ex2_frsp;

   assign ex2_flush_dis_dp = ex2_flush_dis_sp | ex2_from_integer | ex2_ftdiv | ex2_ftsqrt | ex2_mv_to_scr;

   assign f_pic_ex2_flush_en_sp = (~ex2_flush_dis_sp);
   assign f_pic_ex2_flush_en_dp = (~ex2_flush_dis_dp);

   assign f_pic_ex2_log2e = ex2_log2e;		//output--
   assign f_pic_ex2_pow2e = ex2_pow2e;		//output--

   ////################################################################
   ////# ex2 logic
   ////################################################################
   // fmr/fneg/fabs/fnabs
   // fsel
   // mffs
   // mcrfs, mtcrf, mtfs*
   // prenorm_sp prenorm_dp
   // fcomp
   // fmul fadd fsub fmadd fmsub fnmsub fnmadd
   // fres,frsqrte
   // frsp
   //-------------------------------------------
   //

   assign f_pic_ex2_from_integer = ex2_from_integer;		//output--
   assign f_pic_ex2_fsel = ex2_fsel;		//output--

   assign f_pic_ex2_sh_ovf_do = ex2_fsel | ex2_move | ex2_prenorm | ex2_mv_to_scr | ex2_mv_from_scr;

   assign f_pic_ex2_sh_ovf_ig_b = (~(ex2_from_integer | (~ex2_b_valid)));		//output--

   assign f_pic_ex2_sh_unf_do = (~ex2_b_valid) | ex2_est_recip | ex2_est_rsqrt;		//output--

   assign f_pic_ex2_sh_unf_ig_b = (~ex2_from_integer);		//output-- --UNSET--

   assign ex2_a_sign = f_byp_pic_ex2_a_sign;
   assign ex2_c_sign = f_byp_pic_ex2_c_sign;
   assign ex2_b_sign = f_byp_pic_ex2_b_sign;

   assign ex2_b_sign_adj_x = ex2_b_sign ^ ex2_sub_op;		//addend sign adjusted
   assign ex2_p_sign = ex2_a_sign ^ ex2_c_sign;		//product sign

   assign ex2_b_sign_adj = (ex2_b_sign_adj_x & ex2_b_valid) | (ex2_p_sign & (~ex2_b_valid));		// multiply/divide always use p-sign

   assign ex2_div_sign = (ex2_a_sign ^ ex2_b_sign) & ex2_div_beg;

   ////#------------------------------------------
   ////# effective subtract
   ////#------------------------------------------

   assign f_pic_ex2_effsub_raw = (ex2_math | ex2_compare) & (ex2_b_sign_adj ^ ex2_p_sign);		//output--

   ////#---------------------------------------------
   ////# sign logic  alter b-sign for funny moves
   ////#---------------------------------------------
   // sign is 0 when not valid

   assign ex2_b_sign_alt = (ex2_a_sign & ex2_move & ex2_sgncpy & ex2_b_valid) | (ex2_b_sign & ex2_move & ex2_sign_ctl[0] & ex2_b_valid & (~ex2_sgncpy)) | ((~ex2_b_sign) & ex2_move & ex2_sign_ctl[1] & ex2_b_valid & (~ex2_sgncpy)) | (f_alg_ex2_sign_frmw & ex2_from_integer & (~ex2_uns) & ex2_word) | (ex2_b_sign & ex2_from_integer & (~ex2_uns) & (~ex2_word)) | (ex2_b_sign_adj & (ex2_math | ex2_compare)) | (ex2_b_sign & (~ex2_move) & (~(ex2_math | ex2_compare)) & ex2_b_valid & (~ex2_from_integer));		// when ! b_valid (mul) use p_sign

   ////################################################################
   ////# ex3 latches
   ////################################################################

   assign ex2_lzo_dis = (ex2_uc_mid) | (ex2_prenorm) | (ex2_fsel) | (ex2_move) | (ex2_from_integer) | (ex2_est_recip) | (ex2_est_rsqrt) | (ex2_to_integer & (~ex2_rnd_to_int));		//f_pic_ex3_to_integer

   assign ex2_a_nan = f_fmt_ex2_a_expo_max & (~f_fmt_ex2_a_frac_zero) & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   assign ex2_c_nan = f_fmt_ex2_c_expo_max & (~f_fmt_ex2_c_frac_zero) & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   assign ex2_b_nan = f_fmt_ex2_b_expo_max & (~f_fmt_ex2_b_frac_zero) & (~ex2_uc_end_nspec) & (~ex2_uc_mid);

   assign ex2_a_inf = f_fmt_ex2_a_expo_max & f_fmt_ex2_a_frac_zero & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   assign ex2_c_inf = f_fmt_ex2_c_expo_max & f_fmt_ex2_c_frac_zero & (~ex2_uc_end_nspec) & (~ex2_uc_mid);
   assign ex2_b_inf = f_fmt_ex2_b_expo_max & f_fmt_ex2_b_frac_zero & (~ex2_uc_end_nspec) & (~ex2_uc_mid);

   assign ex2_bf_10000 = (f_fmt_ex2_b_imp & f_fmt_ex2_b_frac_zero) | (f_fmt_ex2_b_imp & f_fmt_ex2_b_frac_z32 & ex2_word);		// imp=1, frac=0

   assign f_pic_ex2_frsp_ue1 = ex2_frsp & ex2_ue;		//output

   assign ex2_sp = (~ex2_sp_b);
   assign  f_pic_ex2_ftdiv = ex2_ftdiv ;

   tri_rlmreg_p #(.WIDTH(57) ) ex3_ctl_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex2_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex3_ctl_so),
      .scin(ex3_ctl_si),
      //-----------------
      .din({  ex2_fsel,
              ex2_from_integer,
              ex2_to_integer,
              ex2_math,
              ex2_est_recip,
              ex2_est_rsqrt,
              ex2_move,
              ex2_compare,
              ex2_prenorm,
              ex2_frsp,
              ex2_mv_to_scr,
              ex2_mv_from_scr,
              ex2_div_beg,
              ex2_sqrt_beg,
              ex2_sp,
              ex2_word,
              ex2_ordered,
              ex2_sub_op,
              ex2_lzo_dis,
              ex2_rnd_dis,
              ex2_inv_sign,
              ex2_p_sign,
              ex2_b_sign_adj,
              ex2_b_sign_alt,
              ex2_a_sign,
              ex2_a_valid,
              ex2_c_valid,
              ex2_b_valid,
              f_fmt_ex2_prod_zero,
              ex2_rnd0,
              ex2_rnd1,
              ex2_rnd_to_int,
              ex2_ve,
              ex2_oe,
              ex2_ue,
              ex2_ze,
              ex2_xe,
              ex2_nonieee,
              ex2_rnd0,
              ex2_rnd1,
              ex2_sp_conv,
              ex2_uns,
              ex2_log2e,
              ex2_pow2e,
              ex2_ovf_unf_dis,
              ex2_rnd_fpscr[0],
              ex2_rnd_fpscr[1],
              ex2_div_sign,
              ex2_uc_ft_pos,
              ex2_uc_ft_neg,
              ex2_uc_mid,
              ex2_uc_end_spec,
              ex2_nj_deno,
              ex2_ftdiv,
              ex2_ftsqrt,
              tiup,
              f_fmt_ex2_b_imp}),
      //-----------------
       .dout({ ex3_fsel,
               ex3_from_integer,
               ex3_to_integer,
               ex3_math,
               ex3_est_recip,
               ex3_est_rsqrt,
               ex3_move,
               ex3_compare,
               ex3_prenorm,
               ex3_frsp,
               ex3_mv_to_scr,
               ex3_mv_from_scr,
               ex3_div_beg,
               ex3_sqrt_beg,
               ex3_sp,
               ex3_word,
               ex3_ordered,
               ex3_sub_op,
               ex3_lzo_dis,
               ex3_rnd_dis,
               ex3_inv_sign,
               ex3_p_sign,
               ex3_b_sign_adj,
               ex3_b_sign_alt,
               ex3_a_sign,
               ex3_a_valid,
               ex3_c_valid,
               ex3_b_valid,
               ex3_prod_zero,
               ex3_op_rnd[0],
               ex3_op_rnd[1],
               ex3_rnd_to_int,
               ex3_ve,
               ex3_oe,
               ex3_ue,
               ex3_ze,
               ex3_xe,
               ex3_nonieee,
               ex3_rnd0,
               ex3_rnd1,
               ex3_sp_conv,
               ex3_uns,
               ex3_log2e,
               ex3_pow2e,
               ex3_ovf_unf_dis,
               ex3_rnd_fpscr[0],
               ex3_rnd_fpscr[1],
               ex3_div_sign,
               ex3_uc_ft_pos,
               ex3_uc_ft_neg,
               ex3_uc_mid,
               ex3_uc_end_spec,
               ex3_nj_deno,
               ex3_ftdiv,
               ex3_ftsqrt,
               ex3_accuracy,
               ex3_b_imp})
   );

   assign ex3_to_int_uns_neg = ex3_to_integer & (~ex3_rnd_to_int) & ex3_uns & ex3_b_sign_alt;
   assign ex3_wd_ov_x = f_eie_ex3_wd_ov;
   assign ex3_dw_ov_x = f_eie_ex3_dw_ov;

   assign f_pic_ex3_frsp_ue1 = ex3_frsp & ex3_ue;		//output
   assign f_pic_ex3_b_valid = ex3_b_valid;		//output
   assign f_pic_ex3_ue1 = ex3_ue | ex3_ovf_unf_dis;		//output

   assign ex2_sp_invalid = (f_fmt_ex2_sp_invalid & ex2_sp & (~ex2_from_integer) & (~ex2_uc_mid) & (~ex2_uc_end_nspec));


   tri_rlmreg_p #(.WIDTH(18)) ex3_flg_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(tidn),
      .mpw1_b(tidn),
      .mpw2_b(tidn),
      .nclk(nclk),
      .act(ex2_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex3_flg_so),
      .scin(ex3_flg_si),
      //-----------------
       .din({ f_fmt_ex2_a_frac_msb,
              f_fmt_ex2_c_frac_msb,
              f_fmt_ex2_b_frac_msb,
              f_fmt_ex2_a_zero,
              f_fmt_ex2_c_zero,
              f_fmt_ex2_b_zero,
              ex2_a_nan,
              ex2_c_nan,
              ex2_b_nan,
              ex2_a_inf,
              ex2_b_inf,
              ex2_c_inf,
              ex2_sp_invalid,
              ex2_bf_10000,
              f_fmt_ex2_bexpu_le126,
              f_fmt_ex2_gt126,
              f_fmt_ex2_ge128,
              f_fmt_ex2_inf_and_beyond_sp}),
      //-----------------
      .dout({  ex3_a_frac_msb,
               ex3_c_frac_msb,
               ex3_b_frac_msb,
               ex3_a_zero,
               ex3_c_zero,
               ex3_b_zero,
               ex3_a_nan,
               ex3_c_nan,
               ex3_b_nan,
               ex3_a_inf,
               ex3_b_inf,
               ex3_c_inf,
               ex3_sp_invalid,
               ex3_bf_10000,
               ex3_bexpu_le126,
               ex3_gt126,
               ex3_ge128,
               ex3_inf_and_beyond_sp})
   );

   ////################################################################
   ////# ex3 logic
   ////################################################################

   assign f_pic_ex3_sp_b = (~ex3_sp);		//output--
   assign f_pic_ex3_to_integer = ex3_to_integer & (~ex3_rnd_to_int);		//output-- --lza only
   assign f_pic_ex3_prenorm = ex3_prenorm;

   //output--
   assign f_pic_ex3_force_sel_bexp = (ex3_from_integer) | (ex3_move) | (ex3_mv_to_scr) | (ex3_mv_from_scr) | (ex3_prenorm) | (ex3_est_recip) | (ex3_est_rsqrt);

   assign f_pic_ex3_est_recip = ex3_est_recip;		//output--feie
   assign f_pic_ex3_est_rsqrt = ex3_est_rsqrt;		//output--feie

   assign f_pic_ex3_sp_lzo = (ex3_frsp) | (ex3_math & ex3_sp);		//output--

   //output--
   assign f_pic_ex3_lzo_dis_prod = (ex3_math & ex3_ue) | (ex3_frsp & ex3_ue) | (ex3_lzo_dis);		// intermediate steps div/sqrt

   assign f_pic_ex3_math_bzer_b = (~(ex3_math & ex3_b_zero));

   assign ex3_rnd_nr = (~ex3_rnd_dis) & (~ex3_rnd0) & (~ex3_rnd1);
   assign ex3_rnd_inf_ok = (~ex3_rnd_dis) & ex3_rnd0 & (~(ex3_rnd1 ^ ex3_b_sign_alt));

   assign f_pic_ex3_rnd_nr = ex3_rnd_nr;
   assign f_pic_ex3_rnd_inf_ok = ex3_rnd_inf_ok;

   ////#------------------------------------------------------
   ////# special cases from inputs
   ////#------------------------------------------------------
   ////# special cases can force 4 different results: PassNan genNan Inf Zero
   ////#   (the value of inf can be modified based on round-mode)
   ////#
   ////# ...................................................................
   ////#   @@ Specail Cases From inputs (other than NAN)
   ////#   COMPARE : no special cases other than NAN which sets NAN compare
   ////#
   ////#   FROMINT   : BZero          T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=+Zero // all others are +/- NORM
   ////#
   ////#   TOINT     : BZero+         T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
   ////#   TOINT     : BZero-         T=+Zero  FI=0 FR=0 UX=0 OX=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
   ////#   TOINT     : BNan           T=80000  Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
   ////#   TOINT     : BInf+          T=PIPE   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
   ////#   TOINT     : BInf-          T=PIPE   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=00000 (ALL TOINTEGER UX=0 OX=0 FPRF=00000)
   ////#
   ////#   FRES      : BZer+          T=+INF   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=+INF  // ZX (Ve=1: hold FPRF)
   ////#   FRES      : BZer-          T=-INF   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=-INF  // ZX (Ve=1: hold FPRF)
   ////#   FRES      : BInf+          T=+Zer   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=+Zer
   ////#   FRES      : BInf-          T=-Zer   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=-Zer
   ////#   FRES      : BNAN           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=qNAN
   ////#
   ////#   FRSQRTE   : BZer+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf+  // ZX (Ve=1: hold FPRF)
   ////#   FRSQRTE   : BZer-          T=Inf-   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf-  // ZX (Ve=1: hold FPRF)
   ////#   FRSQRTE   : BInf-          T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsqrt
   ////#   FRSQRTE   : B-             T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsqrt
   ////#   FRSQRTE   : BInf+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer+
   ////#   FRSQRTE   : BNan           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
   ////#
   ////#   SQRT_END  : BZer+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer+
   ////#   SQRT_END  : BZer-          T=Zer-   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer-
   ////#   SQRT_END  : BINF-          T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=NAN   // vxsqrt
   ////#   SQRT_END  : B-             T=NAN    Fi=0 Fr=0 Ux=0 Ox=0 FPRF=NAN   // vxsqrt
   ////#   SQRT_END  : BINF+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf+
   ////#   SQRT_END  : BNan           T=PASS   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
   ////#
   ////#   DIV_BEG   : BZer+          T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  // ZX (Ve=1: hold FPRF) (vxZDZ if A=Zer)
   ////#   DIV_BEG   : BZer-          T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  // ZX (Ve=1: hold FPRF) (vxZDZ if A=Zer)
   ////#   DIV_BEG   : BNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=nan   // vxsnan[?12]
   ////#   DIV_BEG   : BInf+          T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //                      (vxIDI if A=Inf)
   ////#   DIV_BEG   : BInf-          T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //                      (vxIDI if A=Inf)
   ////#   DIV_BEG   : Both,AInf      T=Inf?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Inf?  //
   ////#   DIV_BEG   : Both,AZer      T=Zer?   Fi=0 Fr=0 Ux=0 Ox=0 FPRF=Zer?  //
   ////#
   ////#   FRSP      : BZer+          T=Zer+   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Zer+
   ////#   FRSP      : BZer-          T=Zer-   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Zer-
   ////#   FRSP      : BInf+          T=Inf+   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Inf+
   ////#   FRSP      : BInf-          T=Inf-   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Inf-
   ////#   FRSP      : BNan           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
   ////#
   ////#   MATH      : ANAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
   ////#   MATH      : BNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
   ////#   MATH      : CNAN           T=Pass   Fi=0 Fr=0 Ux=0 Ox=0 Fprf=Nan?
   ////#   MATH      : BZer*AZer      T=Zer@@  Fi-0 Fr=0 Ux=0 Ox=0 Fprf=Zer@@  @@:ExactZero Rounding Rule
   ////#   MATH      : BZer*CZer      T=Zer@@  Fi-0 Fr=0 Ux=0 Ox=0 Fprf=Zer@@  @@:ExactZero Rounding Rule
   ////#
   ////#   MATH : AINF|CINF|BINF      T=???    Fi=0 Fr=0 Ux=0 Ox=0 Fprf=???
   ////#
   ////#    A   C   B
   ////#    Z   I   x  => GenNan : vxIMZ
   ////#    I   Z   x  => GenNan : vxIMZ
   ////#    I  !Z   I  => GenNan : vxISI if effsub
   ////#   !Z   I   I  => GenNan : vxISI if effsub
   ////#    I  !Z   I  => INF    :       if effadd // sign = psign
   ////#   !Z   I   I  => INF    :       if effadd // sign = psign
   ////#    I  !Z  !I  => INF    : psign
   ////#   !Z   I  !I  => INF    : psign
   ////#   !ZI !ZI  I  => INF    : bsign xor sub_op
   ////#

   ////#----------------------------------------------------
   ////# pass NAN  (math,est,frsp)
   ////#----------------------------------------------------

   assign ex3_a_snan = ex3_a_nan & (~ex3_a_frac_msb);
   assign ex3_b_snan = ex3_b_nan & (~ex3_b_frac_msb);
   assign ex3_c_snan = ex3_c_nan & (~ex3_c_frac_msb);
   assign ex3_a_qnan = ex3_a_nan & ex3_a_frac_msb;
   assign ex3_b_qnan = ex3_b_nan & ex3_b_frac_msb;
   assign ex3_nan_op_grp1 = ex3_math | ex3_est_recip | ex3_est_rsqrt | ex3_frsp | ex3_compare | ex3_rnd_to_int | ex3_div_beg | ex3_sqrt_beg;
   assign ex3_nan_op_grp2 = ex3_nan_op_grp1 | ex3_to_integer | ex3_div_beg;
   assign ex3_compo = ex3_compare & ex3_ordered;

   assign ex3_pass_en = (ex3_a_nan | ex3_c_nan | ex3_b_nan);
   assign ex3_pass_nan = ex3_nan_op_grp1 & ex3_pass_en;

   //(1)
   assign ex3_vxsnan = (ex3_a_snan & ex3_nan_op_grp1) | (ex3_c_snan & ex3_nan_op_grp1) | (ex3_b_snan & ex3_nan_op_grp2) | (f_dcd_ex3_uc_vxsnan);

   //(2)
   assign ex3_vxvc = (ex3_compo & ex3_a_qnan & (~ex3_b_snan)) | (ex3_compo & ex3_b_qnan & (~ex3_a_snan)) | (ex3_compo & ex3_a_snan & (~ex3_ve)) | (ex3_compo & ex3_b_snan & (~ex3_ve));

   assign ex3_vxcvi = (ex3_to_integer & ex3_b_nan & (~ex3_rnd_to_int)) & (~ex3_sp_invalid);		//(3)

   assign ex3_vxzdz = f_dcd_ex3_uc_vxzdz | (ex3_a_zero & ex3_b_zero & ex3_div_beg & (~ex3_sp_invalid));		//(4) FDIV only

   assign ex3_vxidi = f_dcd_ex3_uc_vxidi | (ex3_a_inf & ex3_b_inf & ex3_div_beg & (~ex3_sp_invalid));		//(5) FDIV only

   ////#----------------------------------------------------
   ////# special case genNAN
   ////#----------------------------------------------------

   assign ex3_p_inf = ex3_a_inf | ex3_c_inf;
   assign ex3_p_zero = ex3_a_zero | ex3_c_zero;

   assign ex3_vximz = (ex3_math & ex3_p_inf & ex3_p_zero) & (~ex3_sp_invalid);		//(6)

   assign ex3_vxisi = (ex3_math & ex3_b_inf & ex3_p_inf & (~ex3_p_zero) & (~f_alg_ex3_effsub_eac_b)) & (~ex3_sp_invalid);		//(7)

   assign ex3_vxsqrt = f_dcd_ex3_uc_vxsqrt | ((ex3_est_rsqrt | ex3_sqrt_beg) & ex3_b_sign_alt & (~ex3_b_zero) & (~ex3_b_nan) & (~ex3_sp_invalid));		//(8)

   assign ex3_gen_nan_dv = (ex3_a_zero & ex3_b_zero & ex3_div_beg) | ((ex3_vxidi | ex3_sp_invalid) & ex3_div_beg);

   assign ex3_gen_nan_sq = (ex3_vxsqrt | ex3_sp_invalid) & ex3_sqrt_beg;

   assign ex3_gen_nan = (ex3_b_nan & ex3_to_integer & (~ex3_rnd_to_int)) | ex3_gen_nan_log | ex3_gen_nan_pow | ex3_vxisi | ex3_vximz | (ex3_a_zero & ex3_b_zero & ex3_div_beg) | ex3_vxsqrt | ex3_vxidi | (ex3_sp_invalid & (~ex3_pow2e) & (~ex3_log2e));
   // sp op requires exponent in sp range (except frsp)

   // NAN             *log:QNAN_PASS   *pow: QNAN_PASS
   // -INF            *log:QNAN_dflt    pow: +0
   // +INF            *log:+INF        *pow: +INF
   //  -0             *log:-INF        *pow: +1
   //  +0             *log:-INF        *pow: +1
   // NEG             *log:QNAN_dflt   *pow: xxxxx
   // -0 <x< 2**-126  *log:-INF        *pow: xxxxx
   // +0 <x< 2**-126  *log: xxxxx      *pow: +1
   // -2**-126 <x<-0  *log: xxxxx      *pow: +1
   // -INF <x<-126    *log: xxxxx       pow: 0

   assign ex3_log_ofzero = (ex3_log2e & ex3_b_zero) | (ex3_log2e & ex3_bexpu_le126);		// +/- denorm

   assign ex3_gen_one = (ex3_pow2e & ex3_b_zero) | (ex3_pow2e & ex3_bexpu_le126);		// small denorms pos/neg

   assign ex3_gen_nan_log = (ex3_log2e & ex3_b_sign_alt & (~ex3_b_zero) & (~ex3_bexpu_le126)) | (ex3_log2e & ex3_b_nan);		//also catches -INF input

   assign ex3_gen_inf_log = ex3_log_ofzero | (ex3_log2e & (~ex3_b_sign_alt) & ex3_b_inf) | (ex3_log2e & (~ex3_b_sign_alt) & ex3_inf_and_beyond_sp);

   assign ex3_gen_inf_pow = (ex3_pow2e & (~ex3_b_sign_alt) & ex3_b_inf) | (ex3_pow2e & (~ex3_b_sign_alt) & ex3_ge128);

   assign ex3_gen_zero_pow = (ex3_pow2e & ex3_b_sign_alt & ex3_b_inf) | (ex3_pow2e & ex3_b_sign_alt & ex3_gt126);

   assign ex3_gen_nan_pow = (ex3_pow2e & ex3_b_nan);

   ////#----------------------------------------------------
   ////# special case genINF
   ////#----------------------------------------------------

   assign ex3_zx = f_dcd_ex3_uc_zx | (ex3_b_zero & (~ex3_a_zero) & (~ex3_a_inf) & (~ex3_a_nan) & (~ex3_sp_invalid) & (ex3_est_recip | ex3_est_rsqrt | ex3_div_beg));

   assign ex3_gen_inf_sq = ex3_sqrt_beg & ex3_b_inf & (~ex3_b_sign_alt);
   assign ex3_gen_inf_dv = (ex3_div_beg & ex3_a_inf & (~ex3_b_inf) & (~ex3_b_nan)) | (ex3_div_beg & ex3_zx & (~ex3_a_inf) & (~ex3_a_nan));

   assign ex3_gen_inf = (ex3_gen_inf_log) | (ex3_gen_inf_pow) | (ex3_to_integer & ex3_b_inf) | (ex3_zx) | (ex3_frsp & ex3_b_inf) | (ex3_math & ex3_any_inf) | (ex3_gen_inf_sq) | (ex3_gen_inf_dv);		// priority will throw away the PassNan/GenNan cases

   // will be "ANDed" with ex3_math
   assign ex3_inf_sign = (ex3_p_inf & ex3_p_sign) | ((~ex3_p_inf) & ex3_b_inf & ex3_b_sign_adj);		// could both be inf (effadd) and ok

   assign ex3_any_inf = ex3_a_inf | ex3_c_inf | ex3_b_inf;

   ////#----------------------------------------------------
   ////# special case genMax
   ////#----------------------------------------------------

   assign ex3_gen_max = (ex3_to_integer & ex3_b_inf & (~ex3_rnd_to_int));		// these are inf/max depending on rnd mode.

   ////#----------------------------------------------------
   ////# special case genZero
   ////#----------------------------------------------------

   assign ex3_gen_zer_sq = ex3_sqrt_beg & ex3_b_zero;
   assign ex3_gen_zer_dv = ex3_div_beg & ex3_b_inf & (~ex3_a_nan) & (~ex3_a_inf);

   assign ex3_gen_zero = (ex3_gen_zero_pow) | (ex3_math & (ex3_a_zero | ex3_c_zero) & ex3_b_zero) | (ex3_to_integer & ex3_b_zero) | (ex3_from_integer & (~ex3_b_sign_alt) & ex3_b_zero) | (ex3_frsp & ex3_b_zero) | (ex3_prenorm & (~ex3_div_beg) & ex3_b_zero) | (ex3_est_recip & ex3_b_inf) | (ex3_est_rsqrt & (~ex3_b_sign_alt) & ex3_b_inf) | (ex3_gen_zer_sq) | (ex3_gen_zer_dv);		// div by zero is INF

   ////#----------------------------------------------------
   ////# special case special sign
   ////#----------------------------------------------------

   assign ex3_neg_sqrt_nz = (ex3_est_rsqrt & ex3_b_sign_alt & (~ex3_b_zero));		// divide must use PSign

   assign ex3_toint_genz = ex3_to_integer & ex3_b_zero;

   assign ex3_toint_nan_sign = ex3_to_integer & (~ex3_rnd_to_int) & (ex3_pass_nan | ex3_gen_nan) & (~ex3_uns);

   assign ex3_pass_x = ex3_pass_nan | ex3_fsel;

   assign ex3_rnd_ni = ex3_rnd0 & ex3_rnd1;
   assign ex3_exact_zero_sign = (ex3_effsub_eac & (ex3_rnd_ni ^ ex3_inv_sign)) | ((~ex3_effsub_eac) & (ex3_p_sign));		// xor ex3_inv_sign

   assign ex3_prenorm_special = ex3_gen_zer_dv | ex3_gen_inf_dv | ex3_gen_nan_dv | ex3_gen_zer_sq | ex3_gen_inf_sq | ex3_gen_nan_sq;

   assign ex3_prenorm_sign = (ex3_div_sign & ex3_gen_zer_dv) | (ex3_div_sign & ex3_gen_inf_dv) | (tidn & ex3_gen_inf_sq) | (tidn & ex3_gen_nan_sq) | (tidn & ex3_gen_nan_dv) | (ex3_b_sign_alt & ex3_gen_zer_sq) | (ex3_b_sign_alt & (~ex3_prenorm_special));

   //
   // exact_zero
   //
   assign ex3_spec_sign = (ex3_pass_x & f_fmt_ex3_pass_sign) | ((~ex3_pass_x) & ex3_prenorm & ex3_prenorm_sign & (~ex3_gen_nan)) | ((~ex3_pass_x) & ex3_math & (ex3_a_zero | ex3_c_zero) & ex3_b_zero & ex3_exact_zero_sign & (~ex3_inf_sign) & (~ex3_gen_nan)) | ((~ex3_pass_x) & ex3_log_ofzero & (~ex3_gen_nan)) | ((~ex3_pass_x) & (~ex3_math) & ex3_b_sign_alt & (~ex3_neg_sqrt_nz) & (~ex3_prenorm) & (~ex3_log2e) & (~ex3_pow2e) & (~ex3_toint_genz) & (~ex3_gen_nan)) | ((~ex3_pass_x) & ex3_math & ex3_inf_sign & (~ex3_gen_nan)) | (ex3_toint_nan_sign) | (ex3_b_sign_alt & ex3_rnd_to_int & (~ex3_gen_nan));

   assign ex3_quiet = ex3_pass_nan & (~f_fmt_ex3_pass_msb) & (ex3_math | ex3_frsp | ex3_rnd_to_int | ex3_est_recip | ex3_est_rsqrt);		// ??? do we really need to know the msb was off ??

   ////#----------------------------------------------------
   ////# set up for compares
   ////#----------------------------------------------------

   assign ex3_cmp_zero = ex3_a_zero & ex3_b_zero;

   // b-sign was already flipped for compares
   assign ex3_is_nan = (ex3_compare & ex3_pass_nan);

   assign ex3_is_eq = (ex3_compare & (~ex3_pass_nan) & ex3_cmp_zero) | ((ex3_ftsqrt | ex3_ftdiv) & ex3_b_zero) | ((ex3_ftsqrt | ex3_ftdiv) & ex3_b_inf) | ((ex3_ftsqrt | ex3_ftdiv) & ex3_b_nan) | (ex3_ftdiv & ex3_a_inf) | (ex3_ftdiv & ex3_a_nan) | (ex3_ftsqrt & ex3_b_sign_alt) | (ex3_ftsqrt & (~f_fmt_ex3_be_ge_54)) | (ex3_ftdiv & (~f_fmt_ex3_ae_ge_54) & (~ex3_a_zero)) | (ex3_ftdiv & (~f_fmt_ex3_be_ge_2)) | (ex3_ftdiv & f_fmt_ex3_be_ge_2044) | (ex3_ftdiv & f_fmt_ex3_tdiv_rng_chk & (~ex3_a_zero));

   assign ex3_is_gt = (ex3_compare & (~ex3_pass_nan) & (~ex3_cmp_zero) & (~ex3_a_sign) & (~ex3_b_sign_alt)) |
                      ((ex3_ftsqrt | ex3_ftdiv) & (~ex3_b_imp)) |
		      ((ex3_ftsqrt | ex3_ftdiv) & f_fmt_ex3_be_den  ) |
                      ((ex3_ftsqrt | ex3_ftdiv) & ex3_b_zero) |
                      ((ex3_ftsqrt | ex3_ftdiv) & ex3_b_inf) |
                                     (ex3_ftdiv & ex3_a_inf);

   assign ex3_is_lt = (ex3_compare & (~ex3_pass_nan) & (~ex3_cmp_zero) & ex3_a_sign & ex3_b_sign_alt) | (ex3_ftdiv & ex3_accuracy) | (ex3_ftsqrt & ex3_accuracy);
   assign ex3_cmp_sgnneg = (ex3_compare & (~ex3_pass_nan) & (~ex3_cmp_zero) & ex3_a_sign & (~ex3_b_sign_alt));
   assign ex3_cmp_sgnpos = (ex3_compare & (~ex3_pass_nan) & (~ex3_cmp_zero) & (~ex3_a_sign) & ex3_b_sign_alt);

   ////################################################################
   ////# ex4 latches
   ////################################################################


   tri_rlmreg_p #(.WIDTH(8)) ex4_scr_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex3_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex4_scr_so),
      .scin(ex4_scr_si),
      //-----------------
      .din({  ex3_ve,
              ex3_oe,
              ex3_ue,
              ex3_ze,
              ex3_xe,
              ex3_nonieee,
              ex3_rnd0,
              ex3_rnd1}),
      //-----------------
      .dout({  ex4_ve,
               ex4_oe,
               ex4_ue,
               ex4_ze,
               ex4_xe,
               ex4_nonieee,
               ex4_rnd0,
               ex4_rnd1})
   );

   ////#----------------------------------------------------
   ////# Don't truncate NaN's to SP on first divide/sqrt pass (*_beg = 1)

   assign ex3_sp_notrunc = ex3_sp & (~((ex3_div_beg & (ex3_a_nan | ex3_b_nan)) | (ex3_sqrt_beg & ex3_b_nan)));

   assign ex3_sp_o_frsp = ex3_sp_notrunc | ex3_frsp;


   tri_rlmreg_p #(.WIDTH(34)) ex4_ctl_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex3_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex4_ctl_so),
      .scin(ex4_ctl_si),
      //-----------------
      .din({  ex3_fsel,
              ex3_from_integer,
              ex3_to_integer,
              ex3_math,
              ex3_est_recip,
              ex3_est_rsqrt,
              ex3_move,
              ex3_compare,
              ex3_prenorm,
              ex3_frsp,
              ex3_mv_to_scr,
              ex3_mv_from_scr,
              ex3_div_beg,
              ex3_sqrt_beg,
              ex3_sp_o_frsp,
              ex3_word,
              ex3_sub_op,
              ex3_rnd_dis,
              ex3_inv_sign,
              ex3_p_sign,
              ex3_b_sign_adj,
              ex3_b_sign_alt,
              ex3_a_valid,
              ex3_c_valid,
              ex3_b_valid,
              ex3_prod_zero,
              ex3_b_zero,
              ex3_rnd_to_int,
              ex3_sp_conv,
              ex3_uns,
              ex3_log2e,
              ex3_pow2e,
              ex3_ovf_unf_dis,
              ex3_nj_deno}),
      //-----------------
      .dout({  ex4_fsel,
               ex4_from_integer,
               ex4_to_integer,
               ex4_math,
               ex4_est_recip,
               ex4_est_rsqrt,
               ex4_move,
               ex4_compare,
               ex4_prenorm,
               ex4_frsp,
               ex4_mv_to_scr,
               ex4_mv_from_scr,
               ex4_div_beg,
               ex4_sqrt_beg,
               ex4_sp,
               ex4_word,
               ex4_sub_op,
               ex4_rnd_dis,
               ex4_inv_sign,
               ex4_p_sign,
               ex4_b_sign_adj,
               ex4_b_sign_alt,
               ex4_a_valid,
               ex4_c_valid,
               ex4_b_valid,
               ex4_prod_zero,
               ex4_b_zero,
               ex4_rnd_to_int,
               ex4_sp_conv,
               ex4_uns,
               ex4_log2e,
               ex4_pow2e,
               ex4_ovf_unf_dis,
               ex4_nj_deno})
   );

   assign ex4_nj_deno_x = ex4_nj_deno & (~ex4_ue);

   assign ex4_byp_prod_nz = (ex4_math & (~ex4_b_zero) & (~ex4_prod_zero) & (ex4_a_valid | ex4_c_valid) & ex4_sel_byp);		// math,b=z cancells byp

   assign ex4_byp_prod_nz_sub = (ex4_math & ex4_effsub_eac & (~ex4_b_zero) & (~ex4_prod_zero) & (ex4_a_valid | ex4_c_valid) & ex4_sel_byp);		// math,b=z cancells byp

   assign ex3_uc_g_ig = (f_mad_ex3_uc_a_expo_den & (~ex3_ue)) | (f_mad_ex3_uc_a_expo_den_sp & (~ex3_ue) & ex3_sp);

   assign ex3_effsub_eac = (~f_alg_ex3_effsub_eac_b);


   tri_rlmreg_p #(.WIDTH(47)) ex4_flg_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex3_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex4_flg_so),
      .scin(ex4_flg_si),
      //-----------------
      .din({  ex3_vxsnan,		//exceptions
              ex3_vxvc,
              ex3_vxcvi,
              ex3_vxzdz,
              ex3_vxidi,
              ex3_vximz,
              ex3_vxisi,
              ex3_vxsqrt,
              ex3_zx,
              ex3_gen_nan,		//sel_k
              ex3_gen_inf,
              ex3_gen_max,
              ex3_gen_zero,
              ex3_spec_sign,		//sign special
              ex3_quiet,
              ex3_is_nan,		//compares
              ex3_is_eq,
              ex3_is_gt,
              ex3_is_lt,
              ex3_cmp_sgnneg,
              ex3_cmp_sgnpos,
              ex3_wd_ov_x,		//f_eie_ex3_wd_ov ,-- flags from toInt exponent
              ex3_dw_ov_x,		//f_eie_ex3_dw_ov ,
              f_eie_ex3_wd_ov_if,
              f_eie_ex3_dw_ov_if,
              ex3_to_int_uns_neg,
              f_alg_ex3_sel_byp,
              ex3_effsub_eac,
              f_alg_ex3_sh_unf,
              f_alg_ex3_sh_ovf,
              ex3_pass_nan,
              ex3_bf_10000,
              f_eie_ex3_lt_bias,
              f_eie_ex3_eq_bias_m1,
              ex3_gen_one,
              ex3_rnd_fpscr[0],
              ex3_rnd_fpscr[1],
              ex3_div_sign,
              ex3_uc_ft_pos,
              ex3_uc_ft_neg,
              f_dcd_ex3_uc_inc_lsb,
              f_dcd_ex3_uc_guard,
              f_dcd_ex3_uc_sticky,
              f_dcd_ex3_uc_gs_v,
              ex3_uc_g_ig,
              ex3_uc_mid,
              ex3_uc_end_spec}),
      //-----------------
      .dout({  ex4_vxsnan,		//exceptions
               ex4_vxvc,
               ex4_vxcvi,
               ex4_vxzdz,
               ex4_vxidi,
               ex4_vximz,
               ex4_vxisi,
               ex4_vxsqrt,
               ex4_zx,
               ex4_gen_nan,		//sel_k
               ex4_gen_inf,
               ex4_gen_max,
               ex4_gen_zero,
               ex4_spec_sign,		//sign special
               ex4_quiet,
               ex4_is_nan,		//compares
               ex4_is_eq,
               ex4_is_gt,
               ex4_is_lt,
               ex4_cmp_sgnneg,
               ex4_cmp_sgnpos,
               ex4_wd_ov,		// flags from toInt exponent
               ex4_dw_ov,
               ex4_wd_ov_if,
               ex4_dw_ov_if,
               ex4_to_int_uns_neg,
               ex4_sel_byp,
               ex4_effsub_eac,
               ex4_sh_unf,
               ex4_sh_ovf,
               ex4_pass_nan,
               ex4_bf_10000,
               ex4_lt_bias,
               ex4_eq_bias_m1,
               ex4_gen_one,
               ex4_rnd_fpscr[0],
               ex4_rnd_fpscr[1],
               ex4_div_sign,
               ex4_uc_ft_pos,
               ex4_uc_ft_neg,
               ex4_uc_inc_lsb,
               ex4_uc_guard,
               ex4_uc_sticky,
               ex4_uc_gs_v,
               ex4_uc_g_ig,
               ex4_uc_mid,
               ex4_uc_end_spec})
   );

   assign f_mad_ex4_uc_round_mode[0:1] = ex4_rnd_fpscr[0:1];		//output--
   assign f_mad_ex4_uc_res_sign = ex4_div_sign;		//output--
   assign f_mad_ex4_uc_zx = ex4_zx & (~ex4_pass_nan);		//output--
   assign f_mad_ex4_uc_special = ex4_pass_nan | ex4_gen_nan | ex4_gen_zero | ex4_gen_inf;		//output--

   assign f_mad_ex4_uc_vxidi = ex4_vxidi;		//output--
   assign f_mad_ex4_uc_vxzdz = ex4_vxzdz;		//output--
   assign f_mad_ex4_uc_vxsqrt = ex4_vxsqrt;		//output--
   assign f_mad_ex4_uc_vxsnan = ex4_vxsnan;		//output--

   assign f_pic_ex4_cmp_sgnneg = ex4_cmp_sgnneg;		//output--
   assign f_pic_ex4_cmp_sgnpos = ex4_cmp_sgnpos;		//output--
   assign f_pic_ex4_is_eq = ex4_is_eq;		//output--
   assign f_pic_ex4_is_gt = ex4_is_gt;		//output--
   assign f_pic_ex4_is_lt = ex4_is_lt;		//output--
   assign f_pic_ex4_is_nan = ex4_is_nan;		//output--

   assign f_pic_ex4_sel_est = ex4_est_recip | ex4_est_rsqrt;		//output--
   assign f_pic_ex4_sp_b = (~ex4_sp);		//output--

   ////################################################################
   ////# ex4 logic
   ////################################################################

   ////##-----------------------------------------
   ////## mutex selects for specials
   ////##-----------------------------------------

   assign ex4_gen_rnd2int = ex4_rnd_to_int & ex4_lt_bias;
   assign ex4_gen_one_rnd2int = ex4_gen_rnd2int & ex4_rnd2int_up;
   assign ex4_gen_zer_rnd2int = ex4_gen_rnd2int & (~ex4_rnd2int_up);

   assign ex4_rnd2int_up = ((~ex4_rnd0) & (~ex4_rnd1) & ex4_eq_bias_m1 & (~ex4_b_zero)) | (ex4_rnd0 & (~ex4_rnd1) & (~ex4_b_sign_alt) & (~ex4_b_zero)) | (ex4_rnd0 & ex4_rnd1 & ex4_b_sign_alt & (~ex4_b_zero));		//pos_inf   --f_alg_ex4_int_fi and **1
   //neg_inf   --f_alg_ex4_int_fi and **1

   // **1 rnd_rnd to int spec does not block round up becuase b is zero. i think that may be a mistake.

   assign ex4_gen_nan_mutex = ex4_gen_nan & (~ex4_pass_nan);
   assign ex4_gen_inf_mutex = ex4_gen_inf & (~ex4_pass_nan) & (~ex4_gen_nan);
   assign ex4_gen_max_mutex = ex4_gen_inf & (~ex4_pass_nan) & (~ex4_gen_nan) & (~ex4_gen_inf);
   assign ex4_gen_zer_mutex = (ex4_gen_zero | ex4_gen_zer_rnd2int) & (~ex4_pass_nan) & (~ex4_gen_nan) & (~ex4_gen_one_rnd2int);
   assign ex4_gen_one_mutex = (ex4_gen_one | ex4_gen_one_rnd2int) & (~ex4_pass_nan) & (~ex4_gen_nan);

   ////##-----------------------------------------
   ////## mutex selects for specials
   ////##-----------------------------------------

   //from eie :
   // ex4_wd_ov       ,-- flags from toInt exponent
   // ex4_dw_ov       ,
   // ex4_wd_ov_if    ,
   // ex4_dw_ov_if    ,

   assign ex4_word_to = ex4_word & ex4_to_integer;
   assign ex4_to_int_wd = ex4_to_integer & ex4_word & (~ex4_rnd_to_int);
   assign ex4_to_int_dw = ex4_to_integer & (~ex4_word) & (~ex4_rnd_to_int);
   assign ex4_to_int_ov = (ex4_to_int_wd & ex4_wd_ov) | (ex4_to_int_dw & ex4_dw_ov) | (ex4_to_int_wd & ex4_wd_ov_if & (~ex4_b_sign_alt) & (~ex4_uns)) | (ex4_to_int_dw & ex4_dw_ov_if & (~ex4_b_sign_alt) & (~ex4_uns)) | (ex4_to_int_wd & ex4_wd_ov_if & ex4_b_sign_alt & (~(ex4_bf_10000 & (~f_alg_ex4_int_fr))) & (~ex4_uns)) | (ex4_to_int_dw & ex4_dw_ov_if & ex4_b_sign_alt & (~(ex4_bf_10000 & (~f_alg_ex4_int_fr))) & (~ex4_uns));		// definitely overflowed

   assign ex4_to_int_ov_if = ex4_to_integer & (~ex4_b_sign_alt);		// -- to_int positive

   assign ex4_spec_sel_e = ex4_gen_rnd2int | ex4_pass_nan | ex4_gen_nan | ex4_gen_inf | ex4_gen_zero | ex4_mv_from_scr;

   assign ex4_spec_sel_f = (ex4_gen_rnd2int & (~ex4_pass_nan)) | (ex4_gen_nan & (~ex4_pass_nan)) | (ex4_gen_inf & (~ex4_pass_nan)) | (ex4_gen_zero & (~ex4_pass_nan));

   assign ex4_ov_en = (ex4_math | ex4_frsp | ex4_est_recip) & (~ex4_ovf_unf_dis);
   assign ex4_uf_en = ex4_ov_en;

   assign ex4_oe_x = ex4_oe & ex4_ov_en;
   assign ex4_ue_x = ex4_ue & ex4_uf_en;

   assign ex4_ovf_en_oe0 = ex4_ov_en & (~ex4_oe);
   assign ex4_ovf_en_oe1 = ex4_ov_en & ex4_oe;
   assign ex4_unf_en_oe0 = ex4_uf_en & (~ex4_ue);
   assign ex4_unf_en_oe1 = ex4_uf_en & ex4_ue;

   ////##-----------------------------------------
   ////## sign logic
   ////##-----------------------------------------
   // multiply always uses p_sign (already replicated)

   assign ex4_spec_sign_sel = ex4_spec_sel_e | ex4_prenorm | ex4_fsel | ex4_mv_from_scr | ex4_rnd_to_int | ex4_log2e | ex4_pow2e | ex4_uc_ft_pos | ex4_uc_ft_neg;		// log2e/pow2e regular sign merged in later

   assign ex4_p_sign_may = ex4_math & ex4_effsub_eac;

   assign ex4_spec_sign_x = (ex4_spec_sign & (~ex4_uc_ft_pos)) | ex4_uc_ft_neg;

   // problem in data flow with lza/norm
   //   ex4_toint_pos_zero <= ex4_to_integer and ex4_lt_bias and not f_alg_ex4_int_fr ;
   //  ex4_b_sign_fix <= ex4_b_sign_alt and not ex4_toint_pos_zero;

   assign ex4_sign_pco = (ex4_spec_sign_sel & ex4_spec_sign_x) | ((~ex4_spec_sign_sel) & ex4_b_sign_alt & (~ex4_p_sign_may)) | ((~ex4_spec_sign_sel) & ex4_p_sign & ex4_p_sign_may & (~(ex4_prod_zero & ex4_math))) | ((~ex4_spec_sign_sel) & ex4_b_sign_alt & ex4_p_sign_may & (ex4_prod_zero & ex4_math));		// favors p-sign

   assign ex4_sign_nco = (ex4_spec_sign_sel & ex4_spec_sign_x) | ((~ex4_spec_sign_sel) & ex4_b_sign_alt & (~(ex4_b_zero & ex4_math))) | ((~ex4_spec_sign_sel) & ex4_p_sign & (ex4_b_zero & ex4_math));		// favors b-sign

   ////################################################################
   ////# ex5 latches
   ////################################################################


   tri_rlmreg_p #(.WIDTH(8)) ex5_scr_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex4_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex5_scr_so),
      .scin(ex5_scr_si),
      //-----------------
       .din({ ex4_ve,
              ex4_oe_x,
              ex4_ue_x,
              ex4_ze,
              ex4_xe,
              ex4_nonieee,
              ex4_rnd0,
              ex4_rnd1}),
      //-----------------
      .dout({  ex5_ve,
               ex5_oe,
               ex5_ue,
               ex5_ze,
               ex5_xe,
               ex5_nonieee,
               ex5_rnd0,
               ex5_rnd1})
   );

   assign ex4_sp_x = ex4_sp | ex4_sp_conv;


   tri_rlmreg_p #(.WIDTH(29)) ex5_ctl_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex4_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex5_ctl_so),
      .scin(ex5_ctl_si),
      //-----------------
       .din({ ex4_fsel,
              ex4_from_integer,
              ex4_to_integer,
              ex4_math,
              ex4_est_recip,
              ex4_est_rsqrt,
              ex4_move,
              ex4_compare,
              ex4_prenorm,
              ex4_frsp,
              ex4_mv_to_scr,
              ex4_mv_from_scr,
              ex4_div_beg,
              ex4_sqrt_beg,
              ex4_sp_x,
              ex4_word_to,
              ex4_sub_op,
              ex4_rnd_dis,
              ex4_inv_sign,
              ex4_sign_pco,
              ex4_sign_nco,
              ex4_byp_prod_nz,
              ex4_effsub_eac,
              ex4_rnd_to_int,
              ex4_uns,
              ex4_log2e,
              ex4_pow2e,
              ex4_ovf_unf_dis,
              ex4_nj_deno_x}),
      //-----------------
      .dout({  ex5_fsel,
               ex5_from_integer,
               ex5_to_integer,
               ex5_math,
               ex5_est_recip,
               ex5_est_rsqrt,
               ex5_move,
               ex5_compare,
               ex5_prenorm,
               ex5_frsp,
               ex5_mv_to_scr,
               ex5_mv_from_scr,
               ex5_div_beg,
               ex5_sqrt_beg,
               ex5_sp,
               ex5_word,
               ex5_sub_op,
               ex5_rnd_dis,
               ex5_inv_sign,
               ex5_sign_pco,
               ex5_sign_nco,
               ex5_byp_prod_nz,
               ex5_effsub_eac,
               ex5_rnd_to_int,
               ex5_uns,
               ex5_log2e,
               ex5_pow2e,
               ex5_ovf_unf_dis,
               ex5_nj_deno})
   );

   assign f_pic_ex5_byp_prod_nz = ex5_byp_prod_nz;

   tri_rlmreg_p #(.WIDTH(38)) ex5_flg_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .nclk(nclk),
      .act(ex4_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex5_flg_so),
      .scin(ex5_flg_si),
      //-----------------
       .din({ ex4_vxsnan,		//exceptions
              ex4_vxvc,
              ex4_vxcvi,
              ex4_vxzdz,
              ex4_vxidi,
              ex4_vximz,
              ex4_vxisi,
              ex4_vxsqrt,
              ex4_zx,
              ex4_gen_nan_mutex,		//sel_k
              ex4_gen_inf_mutex,
              ex4_gen_max_mutex,
              ex4_gen_zer_mutex,
              ex4_gen_one_mutex,
              ex4_quiet,
              ex4_to_int_wd,		// flags from toInt exponent
              ex4_to_int_dw,
              ex4_to_int_ov,
              ex4_to_int_ov_if,
              ex4_to_int_uns_neg,
              ex4_spec_sel_e,
              ex4_spec_sel_f,
              ex4_ov_en,
              ex4_uf_en,
              ex4_ovf_en_oe0,
              ex4_ovf_en_oe1,
              ex4_unf_en_oe0,
              ex4_unf_en_oe1,
              ex4_pass_nan,
              f_alg_ex4_int_fr,
              f_alg_ex4_int_fi,
              ex4_uc_inc_lsb,
              ex4_uc_guard,
              ex4_uc_sticky,
              ex4_uc_gs_v,
              ex4_uc_g_ig,
              ex4_uc_mid,
              ex4_uc_end_spec}),
      //-----------------
      .dout({  ex5_vxsnan,		//exceptions
               ex5_vxvc,
               ex5_vxcvi,
               ex5_vxzdz,
               ex5_vxidi,
               ex5_vximz,
               ex5_vxisi,
               ex5_vxsqrt,
               ex5_zx,
               ex5_gen_nan,		//sel_k
               ex5_gen_inf,
               ex5_gen_max,
               ex5_gen_zero,
               ex5_gen_one,
               ex5_quiet,
               ex5_to_int_wd,		// flags from toInt exponent
               ex5_to_int_dw,
               ex5_to_int_ov,
               ex5_to_int_ov_if,
               ex5_to_int_uns_neg,
               ex5_spec_sel_e,
               ex5_spec_sel_f,
               ex5_ov_en,
               ex5_uf_en,
               ex5_ovf_en_oe0,
               ex5_ovf_en_oe1,
               ex5_unf_en_oe0,
               ex5_unf_en_oe1,
               ex5_pass_nan,
               ex5_int_fr,
               ex5_int_fi,
               ex5_uc_inc_lsb,
               ex5_uc_guard,
               ex5_uc_sticky,
               ex5_uc_gs_v,
               ex5_uc_g_ig,
               ex5_uc_mid,
               ex5_uc_end_spec})
   );

   assign ex5_to_int_ov_all_x = (ex5_to_int_ov) | (f_add_ex5_to_int_ovf_wd[0] & ex5_to_int_wd & ex5_uns & (~ex5_to_int_uns_neg)) | (f_add_ex5_to_int_ovf_dw[0] & ex5_to_int_dw & ex5_uns & (~ex5_to_int_uns_neg)) | (f_add_ex5_to_int_ovf_wd[1] & ex5_to_int_wd & (~ex5_uns) & ex5_to_int_ov_if) | (f_add_ex5_to_int_ovf_dw[1] & ex5_to_int_dw & (~ex5_uns) & ex5_to_int_ov_if);

   // may not set vxcvi ... but the result will be zero
   assign ex5_to_int_ov_all = ex5_to_int_uns_neg | ex5_to_int_ov_all_x;

   // only set flag if dont successfuly round to zero
   // adder bit [99] was not flipped for the negate,
   // so it is the carry-out ... "0" co means negative
   assign ex5_vxcvi_ov = ex5_vxcvi | ex5_to_int_ov_all_x | (ex5_to_int_uns_neg & (~f_add_ex5_to_int_ovf_dw[0]) & ex5_to_int_dw) | (ex5_to_int_uns_neg & (~f_add_ex5_to_int_ovf_dw[0]) & ex5_to_int_wd);
   //------------------------------ since upper word is 1111...11111 still use dw(0)

   assign ex5_fr_spec = (ex5_int_fr & ex5_to_integer & (~ex5_rnd_to_int) & (~ex5_vxcvi_ov));
   assign ex5_fi_spec = (ex5_int_fi & ex5_to_integer & (~ex5_rnd_to_int) & (~ex5_vxcvi_ov));

   assign ex5_sel_est = (ex5_est_recip | ex5_est_rsqrt) & (~(ex5_pass_nan));

   assign f_pic_ex5_quiet_b = (~ex5_quiet);		//output--
   assign f_pic_ex5_sp_b = (~ex5_sp);		//output--
   assign f_pic_ex5_sel_est_b = (~ex5_sel_est);		//output--

   assign f_pic_ex5_to_int_ov_all = ex5_to_int_ov_all;		//output--

   assign f_pic_ex5_to_integer_b = (~(ex5_to_integer & (~ex5_rnd_to_int)));		//output--
   assign f_pic_ex5_word_b = (~ex5_word);		//output--
   assign f_pic_ex5_uns_b = (~ex5_uns);		//output--

   assign f_pic_ex5_spec_sel_k_e = ex5_spec_sel_e;		//output--
   assign f_pic_ex5_spec_sel_k_f = ex5_spec_sel_f;		//output--

   assign f_pic_ex5_sel_fpscr_b = (~ex5_mv_from_scr);		//output--
   assign f_pic_ex5_spec_inf_b = (~ex5_gen_inf);		//output--

   assign f_pic_ex5_oe = ex5_oe;		//output--
   assign f_pic_ex5_ue = ex5_ue;		//output--
   assign f_pic_ex5_ov_en = ex5_ov_en & (~ex5_spec_sel_e);		//output--
   assign f_pic_ex5_uf_en = ex5_uf_en & (~ex5_spec_sel_e);		//output--
   assign f_pic_ex5_ovf_en_oe0_b = (~ex5_ovf_en_oe0);		//output--
   assign f_pic_ex5_unf_en_ue0_b = (~ex5_unf_en_oe0);		//output--

   assign f_pic_ex5_ovf_en_oe1_b = (~(ex5_ovf_en_oe1 & (~ex5_uc_mid)));		//output--
   assign f_pic_ex5_unf_en_ue1_b = (~(ex5_unf_en_oe1 & (~ex5_uc_mid)));		//output--

   ////################################################################
   ////# ex5 logic
   ////################################################################
   // fmr/fneg/fabs/fnabs
   // fsel
   // mffs
   // mcrfs, mtcrf, mtfs*
   // prenorm_sp prenorm_dp
   // fcomp
   // fmul fadd fsub fmadd fmsub fnmsub fnmadd
   // fres,frsqrte
   // frsp

   assign ex5_rnd_nr = (~ex5_rnd0) & (~ex5_rnd1);
   assign ex5_rnd_zr = (~ex5_rnd0) & ex5_rnd1;
   assign ex5_rnd_pi = ex5_rnd0 & (~ex5_rnd1);
   assign ex5_rnd_ni = ex5_rnd0 & ex5_rnd1;

   assign ex5_rnd_en = (~ex5_rnd_dis) & (~ex5_sel_spec_e) & (ex5_math | ex5_frsp | ex5_from_integer);
   assign ex5_rnd_inf_ok = (ex5_rnd_en & ex5_rnd_pi & (~ex5_round_sign)) | (ex5_rnd_en & ex5_rnd_ni & ex5_round_sign);
   assign ex5_rnd_nr_ok = ex5_rnd_en & ex5_rnd_nr;
   assign f_pic_ex5_rnd_inf_ok_b = (~ex5_rnd_inf_ok);		//output--
   assign f_pic_ex5_rnd_ni_b = (~ex5_rnd_ni);		//output--
   assign f_pic_ex5_rnd_nr_b = (~ex5_rnd_nr_ok);		//output--

   //--------------------------

   assign ex5_uc_g_v = ex5_uc_gs_v & (~ex5_uc_g_ig);
   assign ex5_uc_s_v = ex5_uc_gs_v;

   assign f_pic_ex5_nj_deno = ex5_nj_deno;		//output
   assign f_pic_ex6_uc_inc_lsb = ex6_uc_inc_lsb;		//output--
   assign f_pic_ex6_uc_guard = ex6_uc_guard;		//output--
   assign f_pic_ex6_uc_sticky = ex6_uc_sticky;		//output--
   assign f_pic_ex6_uc_g_v = ex6_uc_g_v;		//output--
   assign f_pic_ex6_uc_s_v = ex6_uc_s_v;		//output--
   //--------------------------

   assign ex5_vx = ex5_vxsnan | ex5_vxisi | ex5_vxidi | ex5_vxzdz | ex5_vximz | ex5_vxvc | ex5_vxsqrt | ex5_vxcvi_ov;

   assign ex5_upd_fpscr_ops = (ex5_math & (~ex5_uc_mid)) | ex5_est_recip | ex5_est_rsqrt | ex5_to_integer | ex5_from_integer | ex5_frsp | ex5_rnd_to_int | ex5_compare;		// microcode only changes fpscr on last iteration

   assign ex5_scr_upd_pipe = ex5_upd_fpscr_ops & (~ex5_ovf_unf_dis);
   assign ex5_scr_upd_move = ex5_mv_to_scr;

   // does not include include iu cancel
   //  --(ex5_log2e         ) or
   //  --(ex5_pow2e         ) or
   //  (f_dcd_ex5_cancel  ) or
   //  (ex5_compare       ) or
   //  (ex5_mv_to_scr     ) or
   //  (ex5_mv_from_scr   ) or
   assign ex5_fpr_wr_dis = (ex5_fprf_hold);

   assign ex5_sel_spec_e = ex5_gen_one | ex5_pass_nan | ex5_gen_nan | ex5_gen_inf | ex5_gen_zero;

   assign ex5_sel_spec_f = ex5_gen_one | ex5_gen_nan | ex5_gen_inf | ex5_gen_zero;

   assign ex5_sel_spec_fr = ex5_gen_one | ex5_sel_spec_e | ex5_est_recip | ex5_est_rsqrt | ex5_rnd_to_int;

   //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
   //$$ the spec has changed , overflow <ex5_to_int_ov_all> for to_ineger should now set fr_pipe_v fr=00
   //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

   assign ex5_ox_pipe_v = (~ex5_sel_spec_e) & (~ex5_compare) & (~ex5_to_integer) & (~ex5_from_integer) & (~ex5_rnd_to_int) & (~ex5_uc_end_spec);
   assign ex5_fr_pipe_v = (~ex5_sel_spec_fr) & (~ex5_compare) & (~ex5_to_integer) & (~ex5_rnd_to_int) & (~ex5_uc_end_spec);

   assign ex5_fprf_pipe_v = (~ex5_sel_spec_e) & (~ex5_compare) & (~(ex5_to_integer & (~ex5_rnd_to_int))) & (~ex5_fprf_hold);

   assign ex5_fprf_hold_ops = ex5_to_integer | ex5_frsp | ex5_rnd_to_int | (ex5_math & (~ex5_uc_mid)) | (ex5_est_recip & (~ex5_uc_mid)) | (ex5_est_rsqrt & (~ex5_uc_mid));

   assign ex5_fprf_hold = (ex5_ve & ex5_vx & ex5_fprf_hold_ops) | (ex5_ze & ex5_zx & ex5_fprf_hold_ops);

   // FPRF
   // 1 0 0 0 1  QNAN     [0]  qnan | den | (sign*zero)
   // 0 1 0 0 1 -INF      [1]  sign * !zero
   // 0 1 0 0 0 -norm     [2] !sign * !zero * !qnan
   // 1 1 0 0 0 -den      [3]  zero
   // 1 0 0 1 0 -zero     [4]  inf   | qnan
   // 0 0 0 1 0 +zero
   // 1 0 1 0 0 +den
   // 0 0 1 0 0 +norm
   // 0 0 1 0 1 +inf
   //
   // ex5_pass_nan      10001  @
   // ex5_gen_nan       10001  @
   // ex5_gen_inf  (-)  01001
   // ex5_gen_inf  (+)  00101
   // ex5_gen_zero (-)  10010  @
   // ex5_gen_zero (+)  00010  @
   // ex5_gen_one  (+)  00100  +norm
   // ex5_gen_one  (-)  01000  -norm

   assign ex5_gen_inf_sign = ex5_round_sign ^ (ex5_inv_sign & (~ex5_pass_nan) & (~ex5_gen_nan));

   //[0] nan, -zer, -den, +den ... (spec does not create den)
   assign ex5_fprf_spec_x[0] = ex5_pass_nan | ex5_gen_nan | (ex5_gen_zero & (ex5_math & ex5_effsub_eac) & (ex5_rnd_ni ^ ex5_inv_sign)) | (ex5_gen_zero & (~(ex5_math & ex5_effsub_eac)) & (ex5_round_sign ^ ex5_inv_sign));

   assign ex5_fprf_spec_x[1] = (ex5_gen_inf & ex5_gen_inf_sign) | (ex5_gen_one & ex5_round_sign);
   assign ex5_fprf_spec_x[2] = (ex5_gen_inf & (~ex5_gen_inf_sign)) | (ex5_gen_one & (~ex5_round_sign));
   assign ex5_fprf_spec_x[3] = ex5_gen_zero;
   assign ex5_fprf_spec_x[4] = ex5_pass_nan | ex5_gen_nan | ex5_gen_inf;

   assign ex5_fprf_spec[0:4] = (({tidn, f_add_ex5_fpcc_iu[0:3]}) & {5{ex5_compare}}) |
                               (ex5_fprf_spec_x[0:4] & {5{(~ex5_to_integer_ken)}} & ~{5{(ex5_compare | ex5_fprf_hold)}});

   // selects for constant (pipe and spec) ??? need mayOvf

   // k depends on the rounding mode (also diff for to intetger)
   // NAN : pipe does not create nan
   // +/-   INF frac=0
   // MAX   FP  frac=1
   // MAX +int frac=1
   // MAX -INT frac=0

   assign ex5_may_ovf = f_eov_ex5_may_ovf;

   assign ex5_k_max_fp = (ex5_may_ovf & ex5_rnd_zr) | (ex5_may_ovf & ex5_rnd_pi & ex5_round_sign) | (ex5_may_ovf & ex5_rnd_ni & (~ex5_round_sign));

   //exponent  1 <= tidn (sign)
   //exponent  2 <= tidn (2048)
   //exponent  3 <= msb  (1024) for inf/nan
   //exponent  4 <= sp    (512)
   //exponent  5 <= sp    (256)
   //exponent  6 <= sp    (128)
   //exponent  7 <= mid    (64)
   //exponent  8 <= mid    (64)
   //exponent  9 <= mid    (32)
   //exponent 10 <= mid    (16)
   //exponent 11 <= mid     (8)
   //exponent 12 <= mid     (4)
   //exponent 13 <= lsb     (1)

   assign ex5_gen_any = ex5_gen_nan | ex5_gen_inf | ex5_gen_zero | ex5_gen_one;

   assign ex5_k_nan = (ex5_gen_nan | ex5_pass_nan) & (~ex5_to_integer_ken);

   assign ex5_k_inf = (ex5_gen_inf & (~ex5_to_integer_ken)) | ((~ex5_gen_any) & (~ex5_to_integer_ken) & ex5_may_ovf & (~ex5_k_max_fp));

   assign ex5_k_max = (ex5_gen_max & (~ex5_to_integer_ken)) | ((~ex5_gen_any) & (~ex5_to_integer_ken) & ex5_may_ovf & ex5_k_max_fp);

   assign ex5_k_zer = (ex5_gen_zero & (~ex5_to_integer_ken)) | ((~ex5_gen_any) & (~ex5_to_integer_ken) & (~ex5_may_ovf));

   assign ex5_k_one = ex5_gen_one;

   assign ex5_to_integer_ken = ex5_to_integer & (~ex5_rnd_to_int);

   //uns
   assign ex5_k_int_zer = (ex5_to_integer_ken & ex5_uns & ex5_gen_zero) | (ex5_to_integer_ken & ex5_uns & ex5_gen_nan) | (ex5_to_integer_ken & ex5_uns & ex5_sign_nco) | (ex5_to_integer_ken & (~ex5_uns) & ex5_gen_zero);		//uns
   //sgn

   //uns
   assign ex5_k_int_maxpos = (ex5_to_integer_ken & ex5_uns & (~ex5_gen_zero) & (~ex5_gen_nan) & (~ex5_sign_nco)) | (ex5_to_integer_ken & (~ex5_uns) & (~ex5_gen_zero) & (~ex5_gen_nan) & (~ex5_sign_nco));		//sgn

   //sgn
   assign ex5_k_int_maxneg = (ex5_to_integer_ken & (~ex5_uns) & (~ex5_gen_zero) & ex5_gen_nan) | (ex5_to_integer_ken & (~ex5_uns) & (~ex5_gen_zero) & ex5_sign_nco);		//sgn

   assign ex5_en_exact_zero = ex5_math & ex5_effsub_eac & (~ex5_sel_spec_e);		// nan_pass, gen_nan, gen_inf, gen_zero

   assign ex5_invert_sign = ex5_inv_sign & (~ex5_pass_nan) & (~ex5_gen_nan) & (~(ex5_gen_zero & ex5_effsub_eac));

   assign ex5_sign_pco_x = ((~(ex5_gen_zero & ex5_math & ex5_effsub_eac)) & ex5_sign_pco) | ((ex5_gen_zero & ex5_math & ex5_effsub_eac) & (ex5_rnd_ni ^ ex5_inv_sign));
   assign ex5_sign_nco_x = ((~(ex5_gen_zero & ex5_math & ex5_effsub_eac)) & ex5_sign_nco) | ((ex5_gen_zero & ex5_math & ex5_effsub_eac) & (ex5_rnd_ni ^ ex5_inv_sign));

   assign ex5_round_sign = (f_add_ex5_sign_carry & ex5_sign_pco) | ((~f_add_ex5_sign_carry) & ex5_sign_nco);		// co means a<b (for math only)

   assign ex5_to_int_k_sign = ((~ex5_word) & (~ex5_k_int_zer) & ex5_uns & (~ex5_sign_nco)) | ((~ex5_word) & (~ex5_k_int_zer) & (~ex5_uns) & ex5_sign_nco);		// sign bit in position 32 for word ops

   assign ex5_to_int_ov_all_gt = ex5_to_int_ov_all | ex5_k_int_zer;

   assign ex5_sign_pco_xx = (ex5_sign_pco_x & (~ex5_to_int_ov_all_gt)) | (ex5_to_int_k_sign & ex5_to_int_ov_all_gt);
   assign ex5_sign_nco_xx = (ex5_sign_nco_x & (~ex5_to_int_ov_all_gt)) | (ex5_to_int_k_sign & ex5_to_int_ov_all_gt);

   assign ex5_round_sign_x = (f_add_ex5_sign_carry & ex5_sign_pco_xx) | ((~f_add_ex5_sign_carry) & ex5_sign_nco_xx);		// co means a<b (for math only)

   ////################################################################
   ////# ex6 latches
   ////################################################################

   assign ex5_k_nan_x = (ex5_k_nan & (~ex5_mv_from_scr));
   assign ex5_k_inf_x = (ex5_k_inf & (~ex5_mv_from_scr));
   assign ex5_k_max_x = (ex5_k_max & (~ex5_mv_from_scr));
   assign ex5_k_zer_x = (ex5_k_zer | ex5_mv_from_scr);
   assign ex5_k_one_x = (ex5_k_one & (~ex5_mv_from_scr));


   tri_rlmreg_p #(.WIDTH(42)) ex6_flg_lat(
      .vd(vdd),
      .gd(gnd),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .nclk(nclk),
      .act(ex5_act),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(ex6_flg_so),
      .scin(ex6_flg_si),
      //-----------------
       .din({ ex5_zx,		//exceptions
              ex5_vxsnan,
              ex5_vxisi,
              ex5_vxidi,
              ex5_vxzdz,
              ex5_vximz,
              ex5_vxvc,
              ex5_vxsqrt,
              ex5_vxcvi_ov,
              ex5_scr_upd_move,		// write enables
              ex5_scr_upd_pipe,
              ex5_fpr_wr_dis,
              ex5_ox_pipe_v,		// select pipe value
              ex5_fr_pipe_v,
              ex5_fprf_pipe_v,
              ex5_fprf_spec[0:4],		// generate special value
              ex5_k_nan_x,
              ex5_k_inf_x,
              ex5_k_max_x,
              ex5_k_zer_x,
              ex5_k_one_x,
              ex5_k_int_maxpos,
              ex5_k_int_maxneg,
              ex5_k_int_zer,
              ex5_en_exact_zero,		// sign
              ex5_invert_sign,
              ex5_round_sign_x,
              tidn,
              ex5_compare,
              ex5_frsp,
              ex5_fr_spec,
              ex5_fi_spec,
              ex5_fprf_hold,
              ex5_uc_inc_lsb,
              ex5_uc_guard,
              ex5_uc_sticky,
              ex5_uc_g_v,
              ex5_uc_s_v}),
      //-----------------
        .dout({ex6_zx,		//exceptions
               ex6_vxsnan,
               ex6_vxisi,
               ex6_vxidi,
               ex6_vxzdz,
               ex6_vximz,
               ex6_vxvc,
               ex6_vxsqrt,
               ex6_vxcvi,
               ex6_scr_upd_move,		// write enables
               ex6_scr_upd_pipe,
               ex6_fpr_wr_dis,
               ex6_ox_pipe_v,		// select pipe values
               ex6_fr_pipe_v,
               ex6_fprf_pipe_v,
               ex6_fprf_spec[0:4],		// generate special value
               ex6_k_nan,
               ex6_k_inf,
               ex6_k_max,
               ex6_k_zer,
               ex6_k_one,
               ex6_k_int_maxpos,
               ex6_k_int_maxneg,
               ex6_k_int_zer,
               ex6_en_exact_zero,		// sign
               ex6_invert_sign,
               ex6_round_sign,
               ex6_unused,
               ex6_compare,
               ex6_frsp,
               ex6_fr_spec,
               ex6_fi_spec,
               ex6_fprf_hold,
               ex6_uc_inc_lsb,
               ex6_uc_guard,
               ex6_uc_sticky,
               ex6_uc_g_v,
               ex6_uc_s_v})
   );

   assign f_pic_ex6_frsp = ex6_frsp;

   ////################################################################
   ////# ex6 logic
   ////################################################################

   assign f_pic_ex6_flag_zx_b = (~ex6_zx);		//output-- [05]
   assign f_pic_ex6_flag_vxsnan_b = (~ex6_vxsnan);		//output-- [07]
   assign f_pic_ex6_flag_vxisi_b = (~ex6_vxisi);		//output-- [08]
   assign f_pic_ex6_flag_vxidi_b = (~ex6_vxidi);		//output-- [09]
   assign f_pic_ex6_flag_vxzdz_b = (~ex6_vxzdz);		//output-- [10]
   assign f_pic_ex6_flag_vximz_b = (~ex6_vximz);		//output-- [11]
   assign f_pic_ex6_flag_vxvc_b = (~ex6_vxvc);		//output-- [12]
   assign f_pic_ex6_flag_vxsqrt_b = (~ex6_vxsqrt);		//output-- [22]
   assign f_pic_ex6_flag_vxcvi_b = (~ex6_vxcvi);		//output-- [23]

   assign f_pic_ex6_scr_upd_move_b = (~ex6_scr_upd_move);		//output--
   assign f_pic_ex6_scr_upd_pipe_b = (~ex6_scr_upd_pipe);		//output--
   assign f_pic_ex6_fpr_wr_dis_b = (~ex6_fpr_wr_dis);		//output--
   assign f_pic_ex6_compare_b = (~ex6_compare);		//output--

   assign f_pic_ex6_ox_pipe_v_b = (~ex6_ox_pipe_v);		//output-- [03]
   assign f_pic_ex6_fr_pipe_v_b = (~ex6_fr_pipe_v);		//output-- [13]
   assign f_pic_ex6_fprf_pipe_v_b = (~ex6_fprf_pipe_v);		//output-- [15:19]

   assign f_pic_ex6_fprf_spec_b[0:4] = (~ex6_fprf_spec[0:4]);		//output--

   assign f_pic_ex6_k_nan = ex6_k_nan;		//output--
   assign f_pic_ex6_k_inf = ex6_k_inf;		//output--
   assign f_pic_ex6_k_max = ex6_k_max;		//output--
   assign f_pic_ex6_k_zer = ex6_k_zer;		//output--
   assign f_pic_ex6_k_one = ex6_k_one;		//output--
   assign f_pic_ex6_k_int_maxpos = ex6_k_int_maxpos;		//output--
   assign f_pic_ex6_k_int_maxneg = ex6_k_int_maxneg;		//output--
   assign f_pic_ex6_k_int_zer = ex6_k_int_zer;		//output--

   assign f_pic_ex6_en_exact_zero = ex6_en_exact_zero;		//output--
   assign f_pic_ex6_invert_sign = ex6_invert_sign;		//output--
   assign f_pic_ex6_round_sign = ex6_round_sign;		//output--

   //---------------------------------------------------------

   assign f_pic_ex6_fi_pipe_v_b = (~ex6_fr_pipe_v);		//output-- [14]
   assign f_pic_ex6_ux_pipe_v_b = (~ex6_ox_pipe_v);		//output-- [04]
   assign f_pic_ex6_fprf_hold_b = (~ex6_fprf_hold);		//output-- toint | (ve=1*(math|fprsp)*vx) ... not vxvc
   assign f_pic_ex6_fi_spec_b = (~ex6_fi_spec);		//output--
   assign f_pic_ex6_fr_spec_b = (~ex6_fr_spec);		//output--

   ////################################################################
   ////# scan string
   ////################################################################

   assign ex2_ctl_si[0:44] = {ex2_ctl_so[1:44], f_pic_si};
   assign ex3_ctl_si[0:56] = {ex3_ctl_so[1:56], ex2_ctl_so[0]};
   assign ex3_flg_si[0:17] = {ex3_flg_so[1:17], ex3_ctl_so[0]};
   assign ex4_scr_si[0:7] = {ex4_scr_so[1:7], ex3_flg_so[0]};
   assign ex4_ctl_si[0:33] = {ex4_ctl_so[1:33], ex4_scr_so[0]};
   assign ex4_flg_si[0:46] = {ex4_flg_so[1:46], ex4_ctl_so[0]};
   assign ex5_scr_si[0:7] = {ex5_scr_so[1:7], ex4_flg_so[0]};
   assign ex5_ctl_si[0:28] = {ex5_ctl_so[1:28], ex5_scr_so[0]};
   assign ex5_flg_si[0:37] = {ex5_flg_so[1:37], ex5_ctl_so[0]};
   assign ex6_flg_si[0:41] = {ex6_flg_so[1:41], ex5_flg_so[0]};
   assign act_si[0:20] = {act_so[1:20], ex6_flg_so[0]};
   assign f_pic_so = act_so[0];

endmodule
