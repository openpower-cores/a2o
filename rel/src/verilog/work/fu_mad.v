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

module fu_mad(
   f_dcd_ex7_cancel,
   f_dcd_ex1_bypsel_a_res0,
   f_dcd_ex1_bypsel_a_res1,
   f_dcd_ex1_bypsel_a_res2,
   f_dcd_ex1_bypsel_a_load0,
   f_dcd_ex1_bypsel_a_load1,
   f_dcd_ex1_bypsel_a_load2,
   f_dcd_ex1_bypsel_a_reload0,
   f_dcd_ex1_bypsel_a_reload1,
   f_dcd_ex1_bypsel_a_reload2,

   f_dcd_ex1_bypsel_b_res0,
   f_dcd_ex1_bypsel_b_res1,
   f_dcd_ex1_bypsel_b_res2,
   f_dcd_ex1_bypsel_b_load0,
   f_dcd_ex1_bypsel_b_load1,
   f_dcd_ex1_bypsel_b_load2,
   f_dcd_ex1_bypsel_b_reload0,
   f_dcd_ex1_bypsel_b_reload1,
   f_dcd_ex1_bypsel_b_reload2,

   f_dcd_ex1_bypsel_c_res0,
   f_dcd_ex1_bypsel_c_res1,
   f_dcd_ex1_bypsel_c_res2,
   f_dcd_ex1_bypsel_c_load0,
   f_dcd_ex1_bypsel_c_load1,
   f_dcd_ex1_bypsel_c_load2,
   f_dcd_ex1_bypsel_c_reload0,
   f_dcd_ex1_bypsel_c_reload1,
   f_dcd_ex1_bypsel_c_reload2,

   f_dcd_ex1_bypsel_s_res0,
   f_dcd_ex1_bypsel_s_res1,
   f_dcd_ex1_bypsel_s_res2,
   f_dcd_ex1_bypsel_s_load0,
   f_dcd_ex1_bypsel_s_load1,
   f_dcd_ex1_bypsel_s_load2,
   f_dcd_ex1_bypsel_s_reload0,
   f_dcd_ex1_bypsel_s_reload1,
   f_dcd_ex1_bypsel_s_reload2,

   f_dcd_ex2_perr_force_c,
   f_dcd_ex2_perr_fsel_ovrd,

   f_fpr_ex8_frt_sign,
   f_fpr_ex8_frt_expo,
   f_fpr_ex8_frt_frac,
   f_fpr_ex9_frt_sign,
   f_fpr_ex9_frt_expo,
   f_fpr_ex9_frt_frac,

   f_fpr_ex6_load_sign,
   f_fpr_ex6_load_expo,
   f_fpr_ex6_load_frac,
   f_fpr_ex7_load_sign,
   f_fpr_ex7_load_expo,
   f_fpr_ex7_load_frac,
   f_fpr_ex8_load_sign,
   f_fpr_ex8_load_expo,
   f_fpr_ex8_load_frac,
   f_fpr_ex6_reload_sign,
   f_fpr_ex6_reload_expo,
   f_fpr_ex6_reload_frac,
   f_fpr_ex7_reload_sign,
   f_fpr_ex7_reload_expo,
   f_fpr_ex7_reload_frac,
   f_fpr_ex8_reload_sign,
   f_fpr_ex8_reload_expo,
   f_fpr_ex8_reload_frac,

   f_fpr_ex1_s_sign,
   f_fpr_ex1_s_expo,
   f_fpr_ex1_s_frac,
   f_byp_ex1_s_sign,
   f_byp_ex1_s_expo,
   f_byp_ex1_s_frac,
   f_pic_ex6_scr_upd_move_b,
   f_dcd_ex7_fpscr_wr,
   f_dcd_ex7_fpscr_addr,
   f_dsq_debug,
   cp_axu_i0_t1_v,
   cp_axu_i0_t0_t1_t,
   cp_axu_i0_t1_t1_t,
   cp_axu_i0_t0_t1_p,
   cp_axu_i0_t1_t1_p,
   cp_axu_i1_t1_v,
   cp_axu_i1_t0_t1_t,
   cp_axu_i1_t1_t1_t,
   cp_axu_i1_t0_t1_p,
   cp_axu_i1_t1_t1_p,

   f_fpr_ex1_a_sign,
   f_fpr_ex1_a_expo,
   f_fpr_ex1_a_frac,
   f_fpr_ex2_a_par,
   f_fpr_ex1_c_sign,
   f_fpr_ex1_c_expo,
   f_fpr_ex1_c_frac,
   f_fpr_ex2_c_par,
   f_fpr_ex1_b_sign,
   f_fpr_ex1_b_expo,
   f_fpr_ex1_b_frac,
   f_fpr_ex2_b_par,
   f_dcd_ex1_aop_valid,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_thread,
   f_dcd_ex1_sp,
   f_dcd_ex1_emin_dp,
   f_dcd_ex1_emin_sp,
   f_dcd_ex1_force_pass_b,
   f_dcd_ex1_fsel_b,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_rnd_to_int_b,
   f_dcd_ex1_math_b,
   f_dcd_ex1_est_recip_b,
   f_dcd_ex1_est_rsqrt_b,
   f_dcd_ex1_move_b,
   f_dcd_ex1_prenorm_b,
   f_dcd_ex1_frsp_b,
   f_dcd_ex1_compare_b,
   f_dcd_ex1_ordered_b,
   f_dcd_ex1_pow2e_b,
   f_dcd_ex1_log2e_b,
   f_dcd_ex1_ftdiv,
   f_dcd_ex1_ftsqrt,
   f_dcd_ex1_nj_deno,
   f_dcd_ex1_nj_deni,
   f_dcd_ex1_sp_conv_b,
   f_dcd_ex1_word_b,
   f_dcd_ex1_uns_b,
   f_dcd_ex1_sub_op_b,
   f_dcd_ex1_force_excp_dis,
   f_dcd_ex1_op_rnd_v_b,
   f_dcd_ex1_op_rnd_b,
   f_dcd_ex1_inv_sign_b,
   f_dcd_ex1_sign_ctl_b,
   f_dcd_ex1_sgncpy_b,
   f_dcd_ex1_fpscr_bit_data_b,
   f_dcd_ex1_fpscr_bit_mask_b,
   f_dcd_ex1_fpscr_nib_mask_b,
   f_dcd_ex1_mv_to_scr_b,
   f_dcd_ex1_mv_from_scr_b,
   f_dcd_ex1_mtfsbx_b,
   f_dcd_ex1_mcrfs_b,
   f_dcd_ex1_mtfsf_b,
   f_dcd_ex1_mtfsfi_b,
   f_dcd_ex1_uc_fc_hulp,
   f_dcd_ex1_uc_fa_pos,
   f_dcd_ex1_uc_fc_pos,
   f_dcd_ex1_uc_fb_pos,
   f_dcd_ex1_uc_fc_0_5,
   f_dcd_ex1_uc_fc_1_0,
   f_dcd_ex1_uc_fc_1_minus,
   f_dcd_ex1_uc_fb_1_0,
   f_dcd_ex1_uc_fb_0_75,
   f_dcd_ex1_uc_fb_0_5,
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
   f_dcd_ex3_uc_inc_lsb,
   f_dcd_ex3_uc_gs_v,
   f_dcd_ex3_uc_gs,
   f_mad_ex7_uc_sign,
   f_mad_ex7_uc_zero,
   f_mad_ex4_uc_special,
   f_mad_ex4_uc_zx,
   f_mad_ex4_uc_vxidi,
   f_mad_ex4_uc_vxzdz,
   f_mad_ex4_uc_vxsqrt,
   f_mad_ex4_uc_vxsnan,
   f_mad_ex4_uc_res_sign,
   f_mad_ex4_uc_round_mode,
   f_mad_ex3_a_parity_check,
   f_mad_ex3_c_parity_check,
   f_mad_ex3_b_parity_check,
   f_dcd_ex0_div,
   f_dcd_ex0_divs,
   f_dcd_ex0_sqrt,
   f_dcd_ex0_sqrts,
   f_dcd_ex0_record_v,
   f_dcd_ex2_divsqrt_v,
   f_dcd_ex2_divsqrt_hole_v,
   f_dcd_flush,
   f_dcd_ex1_itag,
   f_dcd_ex1_fpscr_addr,
   f_dcd_ex1_instr_frt,
   f_dcd_ex1_instr_tid,
   f_dcd_ex1_divsqrt_cr_bf,
   f_dcd_axucr0_deno,
   f_dsq_ex5_divsqrt_v,
   f_dsq_ex6_divsqrt_v,
   f_dsq_ex6_divsqrt_record_v,
   f_dsq_ex6_divsqrt_cr_bf,
   f_dsq_ex6_divsqrt_v_suppress,
   f_dsq_ex5_divsqrt_itag,
   f_dsq_ex6_divsqrt_fpscr_addr,
   f_dsq_ex6_divsqrt_instr_frt,
   f_dsq_ex6_divsqrt_instr_tid,
   f_dsq_ex3_hangcounter_trigger,
   f_ex3_b_den_flush,
   f_scr_ex8_cr_fld,
   f_scr_ex6_fpscr_ni_thr0,
   f_scr_ex6_fpscr_ni_thr1,
   f_add_ex5_fpcc_iu,
   f_pic_ex6_fpr_wr_dis_b,
   f_rnd_ex7_res_expo,
   f_rnd_ex7_res_frac,
   f_rnd_ex7_res_sign,
   f_scr_ex8_fx_thread0,
   f_scr_ex8_fx_thread1,
   f_scr_cpl_fx_thread0,
   f_scr_cpl_fx_thread1,
   ex1_thread_b,
   f_dcd_ex1_act,
   vdd,
   gnd,
   scan_in,
   scan_out,
   clkoff_b,
   act_dis,
   flush,
   delay_lclkr,
   mpw1_b,
   mpw2_b,
   thold_1,
   sg_1,
   fpu_enable,
   nclk
);
   parameter           THREADS = 2;
   input               f_dcd_ex7_cancel;
   input               f_dcd_ex1_bypsel_a_res0;
   input               f_dcd_ex1_bypsel_a_res1;
   input               f_dcd_ex1_bypsel_a_res2;
   input               f_dcd_ex1_bypsel_a_load0;
   input               f_dcd_ex1_bypsel_a_load1;
   input               f_dcd_ex1_bypsel_a_load2;
   input               f_dcd_ex1_bypsel_a_reload0;
   input               f_dcd_ex1_bypsel_a_reload1;
   input               f_dcd_ex1_bypsel_a_reload2;

   input               f_dcd_ex1_bypsel_b_res0;
   input               f_dcd_ex1_bypsel_b_res1;
   input               f_dcd_ex1_bypsel_b_res2;
   input               f_dcd_ex1_bypsel_b_load0;
   input               f_dcd_ex1_bypsel_b_load1;
   input               f_dcd_ex1_bypsel_b_load2;
   input               f_dcd_ex1_bypsel_b_reload0;
   input               f_dcd_ex1_bypsel_b_reload1;
   input               f_dcd_ex1_bypsel_b_reload2;

   input               f_dcd_ex1_bypsel_c_res0;
   input               f_dcd_ex1_bypsel_c_res1;
   input               f_dcd_ex1_bypsel_c_res2;
   input               f_dcd_ex1_bypsel_c_load0;
   input               f_dcd_ex1_bypsel_c_load1;
   input               f_dcd_ex1_bypsel_c_load2;
   input               f_dcd_ex1_bypsel_c_reload0;
   input               f_dcd_ex1_bypsel_c_reload1;
   input               f_dcd_ex1_bypsel_c_reload2;

   input               f_dcd_ex1_bypsel_s_res0;
   input               f_dcd_ex1_bypsel_s_res1;
   input               f_dcd_ex1_bypsel_s_res2;
   input               f_dcd_ex1_bypsel_s_load0;
   input               f_dcd_ex1_bypsel_s_load1;
   input               f_dcd_ex1_bypsel_s_load2;
   input               f_dcd_ex1_bypsel_s_reload0;
   input               f_dcd_ex1_bypsel_s_reload1;
   input               f_dcd_ex1_bypsel_s_reload2;

   input               f_dcd_ex2_perr_force_c;

   input               f_dcd_ex2_perr_fsel_ovrd;


   input               f_fpr_ex8_frt_sign;
   input [1:13]        f_fpr_ex8_frt_expo;
   input [0:52]        f_fpr_ex8_frt_frac;
   input               f_fpr_ex9_frt_sign;
   input [1:13]        f_fpr_ex9_frt_expo;
   input [0:52]        f_fpr_ex9_frt_frac;
   input               f_fpr_ex6_load_sign;
   input [3:13]        f_fpr_ex6_load_expo;
   input [0:52]        f_fpr_ex6_load_frac;
   input               f_fpr_ex7_load_sign;
   input [3:13]        f_fpr_ex7_load_expo;
   input [0:52]        f_fpr_ex7_load_frac;
   input               f_fpr_ex8_load_sign;
   input [3:13]        f_fpr_ex8_load_expo;
   input [0:52]        f_fpr_ex8_load_frac;

   input               f_fpr_ex6_reload_sign;
   input [3:13]        f_fpr_ex6_reload_expo;
   input [0:52]        f_fpr_ex6_reload_frac;
   input               f_fpr_ex7_reload_sign;
   input [3:13]        f_fpr_ex7_reload_expo;
   input [0:52]        f_fpr_ex7_reload_frac;
   input               f_fpr_ex8_reload_sign;
   input [3:13]        f_fpr_ex8_reload_expo;
   input [0:52]        f_fpr_ex8_reload_frac;

   input               f_fpr_ex1_s_sign;
   input [3:13]        f_fpr_ex1_s_expo;
   input [0:52]        f_fpr_ex1_s_frac;		//[0] is implicit bit

   output              f_byp_ex1_s_sign;
   output [3:13]       f_byp_ex1_s_expo;
   output [0:52]       f_byp_ex1_s_frac;

   output              f_pic_ex6_scr_upd_move_b;
   input               f_dcd_ex7_fpscr_wr;
   input [0:5]         f_dcd_ex7_fpscr_addr;
   output [0:63]       f_dsq_debug;

   input [0:THREADS-1] cp_axu_i0_t1_v;
   input [0:2] 	       cp_axu_i0_t0_t1_t;
   input [0:2] 	       cp_axu_i0_t1_t1_t;
   input [0:5] 	       cp_axu_i0_t0_t1_p;
   input [0:5] 	       cp_axu_i0_t1_t1_p;

   input [0:THREADS-1] cp_axu_i1_t1_v;
   input [0:2] 	       cp_axu_i1_t0_t1_t;
   input [0:2] 	       cp_axu_i1_t1_t1_t;
   input [0:5] 	       cp_axu_i1_t0_t1_p;
   input [0:5] 	       cp_axu_i1_t1_t1_p;

   //--------------------------------------------------------------------------

   input               f_fpr_ex1_a_sign;
   input [1:13]        f_fpr_ex1_a_expo;
   input [0:52]        f_fpr_ex1_a_frac;
   input [0:7]         f_fpr_ex2_a_par;
   input               f_fpr_ex1_c_sign;
   input [1:13]        f_fpr_ex1_c_expo;
   input [0:52]        f_fpr_ex1_c_frac;
   input [0:7]         f_fpr_ex2_c_par;
   input               f_fpr_ex1_b_sign;
   input [1:13]        f_fpr_ex1_b_expo;
   input [0:52]        f_fpr_ex1_b_frac;
   input [0:7]         f_fpr_ex2_b_par;
   //--------------------------------------------------------------------------
   input               f_dcd_ex1_aop_valid;
   input               f_dcd_ex1_cop_valid;
   input               f_dcd_ex1_bop_valid;
   input [0:1]         f_dcd_ex1_thread;
   input               f_dcd_ex1_sp;		// off for frsp
   input               f_dcd_ex1_emin_dp;		// prenorm_dp
   input               f_dcd_ex1_emin_sp;		// prenorm_sp, frsp
   input               f_dcd_ex1_force_pass_b;		// fmr,fnabbs,fabs,fneg,mtfsf

   input               f_dcd_ex1_fsel_b;		// fsel
   input               f_dcd_ex1_from_integer_b;		// fcfid (signed integer)
   input               f_dcd_ex1_to_integer_b;		// fcti* (signed integer 32/64)
   input               f_dcd_ex1_rnd_to_int_b;		// fri*
   input               f_dcd_ex1_math_b;		// fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
   input               f_dcd_ex1_est_recip_b;		// fres
   input               f_dcd_ex1_est_rsqrt_b;		// frsqrte
   input               f_dcd_ex1_move_b;		// fmr,fneg,fabs,fnabs
   input               f_dcd_ex1_prenorm_b;		// prenorm ?? need
   input               f_dcd_ex1_frsp_b;		// round-to-single-precision ?? need
   input               f_dcd_ex1_compare_b;		// fcomp*
   input               f_dcd_ex1_ordered_b;		// fcompo

   input               f_dcd_ex1_pow2e_b;		// pow2e  sp,  den==>0
   input               f_dcd_ex1_log2e_b;		// log2e  sp,  den==>0

   input               f_dcd_ex1_ftdiv;		// ftdiv
   input               f_dcd_ex1_ftsqrt;		// ftsqrt

   input               f_dcd_ex1_nj_deno;		// force output den to zero
   input               f_dcd_ex1_nj_deni;		// force  input den to zero

   input               f_dcd_ex1_sp_conv_b;		// for sp/dp convert
   input               f_dcd_ex1_word_b;		// for converts word/dw
   input               f_dcd_ex1_uns_b;		// for converts unsigned
   input               f_dcd_ex1_sub_op_b;		// fsub, fnmsub, fmsub

   input               f_dcd_ex1_force_excp_dis;

   input               f_dcd_ex1_op_rnd_v_b;		// rounding mode = nearest
   input [0:1]         f_dcd_ex1_op_rnd_b;		// rounding mode = positive infinity
   input               f_dcd_ex1_inv_sign_b;		// fnmsub fnmadd
   input [0:1]         f_dcd_ex1_sign_ctl_b;		// 0:fmr/fneg  1:fneg/fnabs
   input               f_dcd_ex1_sgncpy_b;		// for sgncpy instruction :
   // BValid=1 Avalid=0 move=1 sgncpy=1
   // sgnctl=fabs=00 <11 for _b>
   // force pass, rnd_v=0, ovf_unf_dis,

   input [0:3]         f_dcd_ex1_fpscr_bit_data_b;		//data to write to nibble (other than mtfsf)
   input [0:3]         f_dcd_ex1_fpscr_bit_mask_b;		//enable update of bit within the nibble
   input [0:8]         f_dcd_ex1_fpscr_nib_mask_b;		//enable update of this nibble
   // [8] = 0 except
   //  if (mtfsi AND w=1 AND bf=000 )                 <= 0000_0000_1
   //  if (mtfsf AND L==1)                            <= 1111_1111_1
   //  if (mtfsf AND L=0 and w=1 and flm=xxxx_xxxx_1) <= 0000_0000_1
   //  if (mtfsf AND L=0 and w=1 and flm=xxxx_xxxx_0) <= 0000_0000_0
   //  if (mtfsf AND L=0 and w=0 and flm=xxxx_xxxx_1) <= dddd_dddd_0

   input               f_dcd_ex1_mv_to_scr_b;		//mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
   input               f_dcd_ex1_mv_from_scr_b;		//mffs
   input               f_dcd_ex1_mtfsbx_b;		//fpscr set bit, reset bit
   input               f_dcd_ex1_mcrfs_b;		//move fpscr field to cr and reset exceptions
   input               f_dcd_ex1_mtfsf_b;		//move fpr data to fpscr
   input               f_dcd_ex1_mtfsfi_b;		//move immediate data to fpscr

   input               f_dcd_ex1_uc_fc_hulp;		//byp  : bit 53 of multiplier
   input               f_dcd_ex1_uc_fa_pos;		//byp  : immediate data
   input               f_dcd_ex1_uc_fc_pos;		//byp  : immediate data
   input               f_dcd_ex1_uc_fb_pos;		//byp  : immediate data
   input               f_dcd_ex1_uc_fc_0_5;		//byp  : immediate data
   input               f_dcd_ex1_uc_fc_1_0;		//byp  : immediate data
   input               f_dcd_ex1_uc_fc_1_minus;		//byp  : immediate data
   input               f_dcd_ex1_uc_fb_1_0;		//byp  : immediate data
   input               f_dcd_ex1_uc_fb_0_75;		//byp  : immediate data
   input               f_dcd_ex1_uc_fb_0_5;		//byp  : immediate data
   input               f_dcd_ex1_uc_ft_pos;		//pic
   input               f_dcd_ex1_uc_ft_neg;		//pic

   input               f_dcd_ex1_uc_mid;
   input               f_dcd_ex1_uc_end;
   input               f_dcd_ex1_uc_special;
   input               f_dcd_ex3_uc_zx;
   input               f_dcd_ex3_uc_vxidi;
   input               f_dcd_ex3_uc_vxzdz;
   input               f_dcd_ex3_uc_vxsqrt;
   input               f_dcd_ex3_uc_vxsnan;

   input               f_dcd_ex3_uc_inc_lsb;
   input               f_dcd_ex3_uc_gs_v;
   input [0:1]         f_dcd_ex3_uc_gs;

   output              f_mad_ex7_uc_sign;
   output              f_mad_ex7_uc_zero;
   output              f_mad_ex4_uc_special;
   output              f_mad_ex4_uc_zx;
   output              f_mad_ex4_uc_vxidi;
   output              f_mad_ex4_uc_vxzdz;
   output              f_mad_ex4_uc_vxsqrt;
   output              f_mad_ex4_uc_vxsnan;
   output              f_mad_ex4_uc_res_sign;
   output [0:1]        f_mad_ex4_uc_round_mode;

   output              f_mad_ex3_a_parity_check;
   output              f_mad_ex3_c_parity_check;
   output              f_mad_ex3_b_parity_check;
   input               f_dcd_ex0_div;
   input               f_dcd_ex0_divs;
   input               f_dcd_ex0_sqrt;
   input               f_dcd_ex0_sqrts;
   input               f_dcd_ex0_record_v;
   input               f_dcd_ex2_divsqrt_v;

   input               f_dcd_ex2_divsqrt_hole_v;
   input [0:1]         f_dcd_flush;
   input [0:6]         f_dcd_ex1_itag;
   input [0:5]         f_dcd_ex1_fpscr_addr;
   input [0:5]         f_dcd_ex1_instr_frt;
   input [0:3]         f_dcd_ex1_instr_tid;

   input [0:4]         f_dcd_ex1_divsqrt_cr_bf;
   input               f_dcd_axucr0_deno;

   output [0:1]        f_dsq_ex5_divsqrt_v;
   output [0:1]        f_dsq_ex6_divsqrt_v;
   output              f_dsq_ex6_divsqrt_record_v;
   output [0:4]        f_dsq_ex6_divsqrt_cr_bf;

   output              f_dsq_ex6_divsqrt_v_suppress;
   output [0:6]        f_dsq_ex5_divsqrt_itag;
   output [0:5]        f_dsq_ex6_divsqrt_fpscr_addr;
   output [0:5]        f_dsq_ex6_divsqrt_instr_frt;
   output [0:3]        f_dsq_ex6_divsqrt_instr_tid;
   output              f_dsq_ex3_hangcounter_trigger;

   output              f_ex3_b_den_flush;		//iu (does not include all gating) ???

   output [0:3]        f_scr_ex8_cr_fld;		//o--
   output              f_scr_ex6_fpscr_ni_thr0;
   output              f_scr_ex6_fpscr_ni_thr1;
   output [0:3]        f_add_ex5_fpcc_iu;		//o--
   output              f_pic_ex6_fpr_wr_dis_b;		//o--
   output [1:13]       f_rnd_ex7_res_expo;		//o--
   output [0:52]       f_rnd_ex7_res_frac;		//o--
   output              f_rnd_ex7_res_sign;		//o--
   output [0:3]        f_scr_ex8_fx_thread0;		//o--
   output [0:3]        f_scr_ex8_fx_thread1;		//o--
   output [0:3]        f_scr_cpl_fx_thread0;		//o--
   output [0:3]        f_scr_cpl_fx_thread1;		//o--

   //--------------------------------------------------------------------------
   input [0:3]         ex1_thread_b;
   input               f_dcd_ex1_act;
   //--------------------------------------------------------------------------
   inout               vdd;
   inout               gnd;
   input [0:18]        scan_in;
   output [0:18]       scan_out;
   input               clkoff_b;		// tiup
   input               act_dis;		// ??tidn??
   input               flush;		// ??tidn??
   input [1:7]         delay_lclkr;		// tidn,
   input [1:7]         mpw1_b;		// tidn,
   input [0:1]         mpw2_b;		// tidn,
   input               thold_1;
   input               sg_1;
   input               fpu_enable;
   input  [0:`NCLK_WIDTH-1]              nclk;
   // This entity contains macros

   parameter           tiup = 1'b1;
   parameter           tidn = 1'b0;

   wire                f_fmt_ex2_inf_and_beyond_sp;
   wire                perv_eie_sg_1;		//PERV--
   wire                perv_eov_sg_1;		//PERV--
   wire                perv_fmt_sg_1;		//PERV--
   wire                perv_mul_sg_1;		//PERV--
   wire                perv_alg_sg_1;		//PERV--
   wire                perv_add_sg_1;		//PERV--
   wire                perv_lza_sg_1;		//PERV--
   wire                perv_nrm_sg_1;		//PERV--
   wire                perv_rnd_sg_1;		//PERV--
   wire                perv_scr_sg_1;		//PERV--
   wire                perv_pic_sg_1;		//PERV--
   wire                perv_cr2_sg_1;		//PERV--
   wire                perv_eie_thold_1;		//PERV--
   wire                perv_eov_thold_1;		//PERV--
   wire                perv_fmt_thold_1;		//PERV--
   wire                perv_mul_thold_1;		//PERV--
   wire                perv_alg_thold_1;		//PERV--
   wire                perv_add_thold_1;		//PERV--
   wire                perv_lza_thold_1;		//PERV--
   wire                perv_nrm_thold_1;		//PERV--
   wire                perv_rnd_thold_1;		//PERV--
   wire                perv_scr_thold_1;		//PERV--
   wire                perv_pic_thold_1;		//PERV--
   wire                perv_cr2_thold_1;		//PERV--
   wire                perv_eie_fpu_enable;		//PERV--
   wire                perv_eov_fpu_enable;		//PERV--
   wire                perv_fmt_fpu_enable;		//PERV--
   wire                perv_mul_fpu_enable;		//PERV--
   wire                perv_alg_fpu_enable;		//PERV--
   wire                perv_add_fpu_enable;		//PERV--
   wire                perv_lza_fpu_enable;		//PERV--
   wire                perv_nrm_fpu_enable;		//PERV--
   wire                perv_rnd_fpu_enable;		//PERV--
   wire                perv_scr_fpu_enable;		//PERV--
   wire                perv_pic_fpu_enable;		//PERV--
   wire                perv_cr2_fpu_enable;		//PERV--

   wire                f_eov_ex5_may_ovf;
   wire                f_add_ex5_flag_eq;		//o--
   wire                f_add_ex5_flag_gt;		//o--
   wire                f_add_ex5_flag_lt;		//o--
   wire                f_add_ex5_flag_nan;		//o--
   wire [0:162]        f_add_ex5_res;		//o--
   wire                f_add_ex5_sign_carry;		//o--
   wire                f_add_ex5_sticky;		//o--
   wire [0:1]          f_add_ex5_to_int_ovf_dw;		//o--
   wire [0:1]          f_add_ex5_to_int_ovf_wd;		//o--
   wire                f_alg_ex3_effsub_eac_b;		//o--
   wire                f_alg_ex3_prod_z;		//o--
   wire [0:162]        f_alg_ex3_res;		//o--
   wire                f_alg_ex3_sel_byp;		//o--
   wire                f_alg_ex3_sh_ovf;		//o--
   wire                f_alg_ex3_sh_unf;		//o--
   wire                f_alg_ex4_frc_sel_p1;		//o--
   wire                f_alg_ex4_int_fi;		//o--
   wire                f_alg_ex4_int_fr;		//o--
   wire                f_alg_ex4_sticky;		//o--

   wire [0:7]          f_scr_fpscr_ctrl_thr0;
   wire [0:7]          f_scr_fpscr_ctrl_thr1;

   wire [1:13]         f_byp_fmt_ex2_a_expo;		//o--
   wire [1:13]         f_byp_eie_ex2_a_expo;		//o--
   wire [1:13]         f_byp_alg_ex2_a_expo;		//o--
   wire [1:13]         f_byp_fmt_ex2_b_expo;		//o--
   wire [1:13]         f_byp_eie_ex2_b_expo;		//o--
   wire [1:13]         f_byp_alg_ex2_b_expo;		//o--
   wire [1:13]         f_byp_fmt_ex2_c_expo;		//o--
   wire [1:13]         f_byp_eie_ex2_c_expo;		//o--
   wire [1:13]         f_byp_alg_ex2_c_expo;		//o--
   wire [0:52]         f_byp_fmt_ex2_a_frac;		//o--
   wire [0:52]         f_byp_fmt_ex2_c_frac;		//o--
   wire [0:52]         f_byp_fmt_ex2_b_frac;		//o--
   wire [0:52]         f_byp_mul_ex2_a_frac;		//o--
   wire                f_byp_mul_ex2_a_frac_17;		//o--
   wire                f_byp_mul_ex2_a_frac_35;		//o--
   wire [0:53]         f_byp_mul_ex2_c_frac;		//o--
   wire [0:52]         f_byp_alg_ex2_b_frac;		//o--
   wire                f_byp_fmt_ex2_a_sign;		//o--
   wire                f_byp_fmt_ex2_b_sign;		//o--
   wire                f_byp_fmt_ex2_c_sign;		//o--
   wire                f_byp_pic_ex2_a_sign;		//o--
   wire                f_byp_pic_ex2_b_sign;		//o--
   wire                f_byp_pic_ex2_c_sign;		//o--
   wire                f_byp_alg_ex2_b_sign;		//o--

   wire [0:7]          f_cr2_ex2_fpscr_shadow;		//o--
   wire                f_pic_ex3_rnd_inf_ok;		//o--
   wire                f_pic_ex3_rnd_nr;		//o--
   wire [0:3]          f_cr2_ex4_fpscr_bit_data_b;
   wire [0:3]          f_cr2_ex4_fpscr_bit_mask_b;
   wire [0:8]          f_cr2_ex4_fpscr_nib_mask_b;
   wire                f_cr2_ex4_mcrfs_b;		//o--
   wire                f_cr2_ex4_mtfsbx_b;		//o--
   wire                f_cr2_ex4_mtfsf_b;		//o--
   wire                f_cr2_ex4_mtfsfi_b;		//o--
   wire [0:3]          f_cr2_ex4_thread_b;		//o--
   wire                f_pic_add_ex2_act_b;		//o--
   wire                f_pic_eov_ex3_act_b;		//o--
   wire                f_pic_ex2_effsub_raw;		//o--
   wire                f_pic_ex2_from_integer;		//o--
   wire                f_pic_ex2_fsel;		//o--
   wire                f_pic_ex2_sh_ovf_do;		//o--
   wire                f_pic_ex2_sh_ovf_ig_b;		//o--
   wire                f_pic_ex2_sh_unf_do;		//o--
   wire                f_pic_ex2_sh_unf_ig_b;		//o--
   wire                f_pic_ex3_force_sel_bexp;		//o--
   wire                f_pic_ex3_lzo_dis_prod;		//o--
   wire                f_pic_ex3_sp_b;		//o--
   wire                f_pic_ex3_sp_lzo;		//o--
   wire                f_pic_ex3_to_integer;		//o--
   wire                f_pic_ex3_prenorm;		//o--
   wire                f_pic_ex4_cmp_sgnneg;		//o--
   wire                f_pic_ex4_cmp_sgnpos;		//o--
   wire                f_pic_ex4_is_eq;		//o--
   wire                f_pic_ex4_is_gt;		//o--
   wire                f_pic_ex4_is_lt;		//o--
   wire                f_pic_ex4_is_nan;		//o--
   wire                f_pic_ex4_sel_est;		//o--
   wire                f_pic_ex4_sp_b;		//o--
   wire                f_pic_ex5_nj_deno;		//o--
   wire                f_pic_ex5_oe;		//o--
   wire                f_pic_ex5_ov_en;		//o--
   wire                f_pic_ex5_ovf_en_oe0_b;		//o--
   wire                f_pic_ex5_ovf_en_oe1_b;		//o--
   wire                f_pic_ex5_quiet_b;		//o--
   wire                f_pic_ex6_uc_inc_lsb;		//o--
   wire                f_pic_ex6_uc_guard;		//o--
   wire                f_pic_ex6_uc_sticky;		//o--
   wire                f_pic_ex6_uc_g_v;		//o--
   wire                f_pic_ex6_uc_s_v;		//o--
   wire                f_pic_ex5_rnd_inf_ok_b;		//o--
   wire                f_pic_ex5_rnd_ni_b;		//o--
   wire                f_pic_ex5_rnd_nr_b;		//o--
   wire                f_pic_ex5_sel_est_b;		//o--
   wire                f_pic_ex5_sel_fpscr_b;		//o--
   wire                f_pic_ex5_sp_b;		//o--
   wire                f_pic_ex5_spec_inf_b;		//o--
   wire                f_pic_ex5_spec_sel_k_e;		//o--
   wire                f_pic_ex5_spec_sel_k_f;		//o--
   wire                f_pic_ex5_to_int_ov_all;		//o--
   wire                f_pic_ex5_to_integer_b;		//o--
   wire                f_pic_ex5_word_b;		//o--
   wire                f_pic_ex5_uns_b;		//o--
   wire                f_pic_ex5_ue;		//o--
   wire                f_pic_ex5_uf_en;		//o--
   wire                f_pic_ex5_unf_en_ue0_b;		//o--
   wire                f_pic_ex5_unf_en_ue1_b;		//o--
   wire                f_pic_ex6_en_exact_zero;		//o--
   wire                f_pic_ex6_compare_b;		//o--
   wire                f_pic_ex3_ue1;		//o--
   wire                f_pic_ex3_frsp_ue1;		//o--
   wire                f_pic_ex2_frsp_ue1;		//o--
   wire                f_pic_ex6_frsp;		//o--
   wire                f_pic_ex6_fi_pipe_v_b;		//o--
   wire                f_pic_ex6_fi_spec_b;		//o--
   wire                f_pic_ex6_flag_vxcvi_b;		//o--
   wire                f_pic_ex6_flag_vxidi_b;		//o--
   wire                f_pic_ex6_flag_vximz_b;		//o--
   wire                f_pic_ex6_flag_vxisi_b;		//o--
   wire                f_pic_ex6_flag_vxsnan_b;		//o--
   wire                f_pic_ex6_flag_vxsqrt_b;		//o--
   wire                f_pic_ex6_flag_vxvc_b;		//o--
   wire                f_pic_ex6_flag_vxzdz_b;		//o--
   wire                f_pic_ex6_flag_zx_b;		//o--
   wire                f_pic_ex6_fprf_hold_b;		//o--
   wire                f_pic_ex6_fprf_pipe_v_b;		//o--
   wire [0:4]          f_pic_ex6_fprf_spec_b;		//o--
   wire                f_pic_ex6_fr_pipe_v_b;		//o--
   wire                f_pic_ex6_fr_spec_b;		//o--
   wire                f_pic_ex6_invert_sign;		//o--
   wire                f_pic_ex5_byp_prod_nz;		//o--
   wire                f_pic_ex6_k_nan;
   wire                f_pic_ex6_k_inf;
   wire                f_pic_ex6_k_max;
   wire                f_pic_ex6_k_zer;
   wire                f_pic_ex6_k_one;
   wire                f_pic_ex6_k_int_maxpos;
   wire                f_pic_ex6_k_int_maxneg;
   wire                f_pic_ex6_k_int_zer;
   wire                f_pic_ex6_ox_pipe_v_b;		//o--
   wire                f_pic_ex6_round_sign;		//o--
   wire                f_pic_ex6_scr_upd_move_b_int;		//o--
   wire                f_pic_ex6_scr_upd_pipe_b;		//o--
   wire                f_pic_ex6_ux_pipe_v_b;		//o--
   wire                f_pic_lza_ex2_act_b;		//o--
   wire                f_pic_mul_ex2_act;		//o--
   wire                f_pic_fmt_ex2_act;
   wire                f_pic_eie_ex2_act;
   wire                f_pic_alg_ex2_act;
   wire                f_pic_cr2_ex2_act;
   wire                f_fmt_ex3_be_den;

   wire                f_pic_nrm_ex4_act_b;		//o--
   wire                f_pic_rnd_ex4_act_b;		//o--
   wire                f_pic_scr_ex3_act_b;		//o--
   wire                f_eie_ex3_dw_ov;		//o--
   wire                f_eie_ex3_dw_ov_if;		//o--
   wire [1:13]         f_eie_ex3_lzo_expo;		//o--
   wire [1:13]         f_eie_ex3_b_expo;		//o--
   wire [1:13]         f_eie_ex3_tbl_expo;		//o--
   wire                f_eie_ex3_wd_ov;		//o--
   wire                f_eie_ex3_wd_ov_if;		//o--
   wire [1:13]         f_eie_ex4_iexp;		//o--
   wire [1:13]         f_eov_ex6_expo_p0;		//o--
   wire [3:7]          f_eov_ex6_expo_p0_ue1oe1;		//o--
   wire [1:13]         f_eov_ex6_expo_p1;		//o--
   wire [3:7]          f_eov_ex6_expo_p1_ue1oe1;		//o--
   wire                f_eov_ex6_ovf_expo;		//o--
   wire                f_eov_ex6_ovf_if_expo;		//o--
   wire                f_eov_ex6_sel_k_e;		//o--
   wire                f_eov_ex6_sel_k_f;		//o--
   wire                f_eov_ex6_sel_kif_e;		//o--
   wire                f_eov_ex6_sel_kif_f;		//o--
   wire                f_eov_ex6_unf_expo;		//o--
   wire                f_fmt_ex2_a_expo_max;		//o--
   wire                f_fmt_ex2_a_expo_max_dsq;		//o--
   wire                f_fmt_ex2_a_zero;		//o--
   wire                f_fmt_ex2_a_zero_dsq;		//o--
   wire                f_fmt_ex2_a_frac_msb;		//o--
   wire                f_fmt_ex2_a_frac_zero;		//o--
   wire                f_fmt_ex2_b_expo_max;		//o--
   wire                f_fmt_ex2_b_expo_max_dsq;		//o--
   wire                f_fmt_ex2_b_zero;		//o--
   wire                f_fmt_ex2_b_zero_dsq;		//o--
   wire                f_fmt_ex2_b_frac_msb;		//o--
   wire                f_fmt_ex2_b_frac_z32;
   wire                f_fmt_ex2_b_frac_zero;		//o--
   wire [45:52]        f_fmt_ex2_bop_byt;		//o--
   wire                f_fmt_ex2_c_expo_max;		//o--
   wire                f_fmt_ex2_c_zero;		//o--
   wire                f_fmt_ex2_c_frac_msb;		//o--
   wire                f_fmt_ex2_c_frac_zero;		//o--
   wire                f_fmt_ex2_sp_invalid;		//o--
   wire                f_fmt_ex2_pass_sel;		//o--
   wire                f_fmt_ex2_prod_zero;		//o--
   wire                f_fmt_ex3_fsel_bsel;		//o--
   wire [0:52]         f_fmt_ex3_pass_frac;		//o--
   wire                f_fmt_ex3_pass_sign;		//o--
   wire                f_fmt_ex3_pass_msb;		//o--
   wire                f_fmt_ex2_b_imp;		//o--
   wire [0:7]          f_lza_ex5_lza_amt;		//o--
   wire [0:2]          f_lza_ex5_lza_dcd64_cp1;
   wire [0:1]          f_lza_ex5_lza_dcd64_cp2;
   wire [0:0]          f_lza_ex5_lza_dcd64_cp3;
   wire                f_lza_ex5_sh_rgt_en;
   wire                f_lza_ex5_sh_rgt_en_eov;
   wire [0:7]          f_lza_ex5_lza_amt_eov;		//o--
   wire                f_lza_ex5_no_lza_edge;		//o--
   wire [1:108]        f_mul_ex3_car;		//o--
   wire [1:108]        f_mul_ex3_sum;		//o--
   wire                f_nrm_ex5_extra_shift;		//o--
   wire                f_nrm_ex6_exact_zero;		//o--
   wire [0:31]         f_nrm_ex6_fpscr_wr_dat;		//o--
   wire [0:3]          f_nrm_ex6_fpscr_wr_dat_dfp;		//o--
   wire [1:12]         f_nrm_ex6_int_lsbs;		//o--
   wire                f_nrm_ex6_int_sign;
   wire                f_nrm_ex6_nrm_guard_dp;		//o--
   wire                f_nrm_ex6_nrm_guard_sp;		//o--
   wire                f_nrm_ex6_nrm_lsb_dp;		//o--
   wire                f_nrm_ex6_nrm_lsb_sp;		//o--
   wire                f_nrm_ex6_nrm_sticky_dp;		//o--
   wire                f_nrm_ex6_nrm_sticky_sp;		//o--
   wire [0:52]         f_nrm_ex6_res;		//o--
   wire                f_rnd_ex7_flag_den;		//o--
   wire                f_rnd_ex7_flag_fi;		//o--
   wire                f_rnd_ex7_flag_inf;		//o--
   wire                f_rnd_ex7_flag_ox;		//o--
   wire                f_rnd_ex7_flag_sgn;		//o--
   wire                f_rnd_ex7_flag_up;		//o--
   wire                f_rnd_ex7_flag_ux;		//o--
   wire                f_rnd_ex7_flag_zer;		//o--
   wire [53:161]       f_sa3_ex4_c_lza;		//o--
   wire [0:162]        f_sa3_ex4_s_lza;		//o--
   wire [53:161]       f_sa3_ex4_c_add;		//o--
   wire [0:162]        f_sa3_ex4_s_add;		//o--
   wire [0:3]          f_scr_ex6_fpscr_rd_dat_dfp;		//o--
   wire [0:31]         f_scr_ex6_fpscr_rd_dat;		//o--
   wire [0:1]          f_scr_ex6_fpscr_rm_thr0;		//o--
   wire [0:4]          f_scr_ex6_fpscr_ee_thr0;		//o--
   wire                f_scr_ex6_fpscr_ni_thr0_int;		//o--

   wire [0:1]          f_scr_ex6_fpscr_rm_thr1;		//o--
   wire [0:4]          f_scr_ex6_fpscr_ee_thr1;		//o--
   wire                f_scr_ex6_fpscr_ni_thr1_int;		//o--

   wire [24:31]        f_cr2_ex6_fpscr_rd_dat;		//o--
   wire [24:31]        f_cr2_ex7_fpscr_rd_dat;		//o--
   wire                f_pic_tbl_ex2_act;
   wire                f_pic_ex2_ftdiv;

   wire                f_pic_ex3_math_bzer_b;
   wire                perv_sa3_thold_1;
   wire                perv_sa3_sg_1;
   wire                perv_sa3_fpu_enable;
   wire                f_pic_ex3_b_valid;
   wire                f_alg_ex3_byp_nonflip;
   wire                f_pic_ex2_rnd_to_int;
   wire                f_eie_ex3_lt_bias;
   wire                f_eie_ex3_eq_bias_m1;
   wire                f_pic_ex3_est_recip;
   wire                f_pic_ex3_est_rsqrt;
   wire                f_tbe_ex4_may_ov;
   wire [1:13]         f_tbe_ex4_res_expo;
   wire                perv_tbe_sg_1;
   wire                perv_tbe_thold_1;
   wire                perv_tbe_fpu_enable;
   wire                perv_tbl_sg_1;
   wire                perv_tbl_thold_1;
   wire                perv_tbl_fpu_enable;
   wire                f_tbe_ex4_recip_2046;
   wire                f_tbe_ex4_recip_2045;
   wire [1:19]         f_fmt_ex2_b_frac;
   wire [0:26]         f_tbl_ex6_est_frac;
   wire                f_tbl_ex6_recip_den;
   wire                f_eie_ex3_use_bexp;
   wire                rnd_ex7_res_sign;
   wire [1:13]         rnd_ex7_res_expo;
   wire [0:52]         rnd_ex7_res_frac;
   wire                f_pic_ex2_flush_en_dp;
   wire                f_pic_ex2_flush_en_sp;
   wire                f_fmt_ex3_lu_den_recip;
   wire                f_fmt_ex3_lu_den_rsqrto;
   wire                f_tbe_ex4_recip_2044;
   wire                f_tbe_ex4_lu_sh;

   wire [0:162]        f_lze_ex3_lzo_din;
   wire [0:7]          f_lze_ex4_sh_rgt_amt;
   wire                f_lze_ex4_sh_rgt_en;
   wire                f_alg_ex2_sign_frmw;
   wire                f_tbe_ex4_match_en_sp;
   wire                f_tbe_ex4_match_en_dp;
   wire                f_tbl_ex5_unf_expo;
   wire                f_tbe_ex4_recip_ue1;
   wire                f_fmt_ex2_bexpu_le126;
   wire                f_fmt_ex2_gt126;
   wire                f_fmt_ex2_ge128;
   wire                f_gst_ex6_logexp_v;
   wire                f_gst_ex6_logexp_sign;
   wire [1:11]         f_gst_ex6_logexp_exp;
   wire [0:19]         f_gst_ex6_logexp_fract;
   wire                f_fmt_ex2_b_sign_gst;
   wire [1:13]         f_fmt_ex2_b_expo_gst_b;
   wire                f_pic_ex2_log2e;
   wire                f_pic_ex2_pow2e;
   wire                f_fmt_ex2_a_sign_div;
   wire [01:13]        f_fmt_ex2_a_expo_div_b;
   wire [01:52]        f_fmt_ex2_a_frac_div;
   wire                f_fmt_ex2_b_sign_div;
   wire [01:13]        f_fmt_ex2_b_expo_div_b;
   wire [01:52]        f_fmt_ex2_b_frac_div;

   wire                f_dsq_ex6_divsqrt_v_int_suppress;
   wire [0:1]          f_dsq_ex6_divsqrt_v_int;
   wire                f_dsq_ex6_divsqrt_record_v_int;
   wire [0:1]          f_dsq_ex5_divsqrt_v_int;
   wire [0:6]          f_dsq_ex5_divsqrt_itag_int;

   wire [0:5]          f_dsq_ex6_divsqrt_fpscr_addr_int;
   wire [0:5]          f_dsq_ex6_divsqrt_instr_frt_int;
   wire [0:3]          f_dsq_ex6_divsqrt_instr_tid_int;
   wire                f_dsq_ex3_hangcounter_trigger_int;


   wire [0:4]          f_dsq_ex6_divsqrt_cr_bf_int;

   wire                f_dsq_ex6_divsqrt_sign;
   wire [01:13]        f_dsq_ex6_divsqrt_exp;
   wire [00:52]        f_dsq_ex6_divsqrt_fract;

   wire [00:15]        f_dsq_ex6_divsqrt_flag_fpscr;

   wire                f_mad_ex3_uc_a_expo_den;		// a exponent <= 0
   wire                f_mad_ex3_uc_a_expo_den_sp;
   wire                f_pic_ex2_nj_deni;
   wire                f_fmt_ex3_ae_ge_54;
   wire                f_fmt_ex3_be_ge_54;
   wire                f_fmt_ex3_be_ge_2;
   wire                f_fmt_ex3_be_ge_2044;
   wire                f_fmt_ex3_tdiv_rng_chk;

//   assign unused = tidn; // todo


   		// fuq_byp.vhdl
   fu_byp  fbyp(
      //--------------------------------------------------------- -- fuq_byp.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1]),		//i--
      .mpw1_b(mpw1_b[1]),		//i--
      .mpw2_b(mpw2_b[0]),		//i--
      .thold_1(perv_fmt_thold_1),		//i--
      .sg_1(perv_fmt_sg_1),		//i--
      .fpu_enable(perv_fmt_fpu_enable),		//i--

      .f_byp_si(scan_in[0]),		//i--fbyp
      .f_byp_so(scan_out[0]),		//o--fbyp
      .ex1_act(f_dcd_ex1_act),		//i--fbyp

      .f_fpr_ex8_frt_sign(f_fpr_ex8_frt_sign),		//i--mad
      .f_fpr_ex8_frt_expo(f_fpr_ex8_frt_expo[1:13]),		//i--mad
      .f_fpr_ex8_frt_frac(f_fpr_ex8_frt_frac[0:52]),		//i--mad
      .f_fpr_ex9_frt_sign(f_fpr_ex9_frt_sign),		//i--mad
      .f_fpr_ex9_frt_expo(f_fpr_ex9_frt_expo[1:13]),		//i--mad
      .f_fpr_ex9_frt_frac(f_fpr_ex9_frt_frac[0:52]),		//i--mad

      .f_fpr_ex6_load_sign(f_fpr_ex6_load_sign),		//i--fbyp
      .f_fpr_ex6_load_expo(f_fpr_ex6_load_expo[3:13]),		//i--fbyp
      .f_fpr_ex6_load_frac(f_fpr_ex6_load_frac[0:52]),		//i--fbyp
      .f_fpr_ex7_load_sign(f_fpr_ex7_load_sign),		//i--mad
      .f_fpr_ex7_load_expo(f_fpr_ex7_load_expo[3:13]),		//i--mad
      .f_fpr_ex7_load_frac(f_fpr_ex7_load_frac[0:52]),		//i--mad
      .f_fpr_ex8_load_sign(f_fpr_ex8_load_sign),		//i--mad
      .f_fpr_ex8_load_expo(f_fpr_ex8_load_expo[3:13]),		//i--mad
      .f_fpr_ex8_load_frac(f_fpr_ex8_load_frac[0:52]),		//i--mad

      .f_fpr_ex6_reload_sign(f_fpr_ex6_reload_sign),		//i--fbyp
      .f_fpr_ex6_reload_expo(f_fpr_ex6_reload_expo[3:13]),		//i--fbyp
      .f_fpr_ex6_reload_frac(f_fpr_ex6_reload_frac[0:52]),		//i--fbyp
      .f_fpr_ex7_reload_sign(f_fpr_ex7_reload_sign),		//i--mad
      .f_fpr_ex7_reload_expo(f_fpr_ex7_reload_expo[3:13]),		//i--mad
      .f_fpr_ex7_reload_frac(f_fpr_ex7_reload_frac[0:52]),		//i--mad
      .f_fpr_ex8_reload_sign(f_fpr_ex8_reload_sign),		//i--mad
      .f_fpr_ex8_reload_expo(f_fpr_ex8_reload_expo[3:13]),		//i--mad
      .f_fpr_ex8_reload_frac(f_fpr_ex8_reload_frac[0:52]),		//i--mad


      .f_fpr_ex1_s_sign(f_fpr_ex1_s_sign),
      .f_fpr_ex1_s_expo(f_fpr_ex1_s_expo),
      .f_fpr_ex1_s_frac(f_fpr_ex1_s_frac),
      .f_byp_ex1_s_sign(f_byp_ex1_s_sign),
      .f_byp_ex1_s_expo(f_byp_ex1_s_expo),
      .f_byp_ex1_s_frac(f_byp_ex1_s_frac),

      .f_dcd_ex1_div_beg(tidn),		//i--fbyp

      .f_dcd_ex1_uc_fa_pos(f_dcd_ex1_uc_fa_pos),		//i--fbyp
      .f_dcd_ex1_uc_fc_pos(f_dcd_ex1_uc_fc_pos),		//i--fbyp
      .f_dcd_ex1_uc_fb_pos(f_dcd_ex1_uc_fb_pos),		//i--fbyp
      .f_dcd_ex1_uc_fc_0_5(f_dcd_ex1_uc_fc_0_5),		//i--fbyp
      .f_dcd_ex1_uc_fc_1_0(f_dcd_ex1_uc_fc_1_0),		//i--fbyp
      .f_dcd_ex1_uc_fc_1_minus(f_dcd_ex1_uc_fc_1_minus),		//i--fbyp
      .f_dcd_ex1_uc_fb_1_0(f_dcd_ex1_uc_fb_1_0),		//i--fbyp
      .f_dcd_ex1_uc_fb_0_75(f_dcd_ex1_uc_fb_0_75),		//i--fbyp
      .f_dcd_ex1_uc_fb_0_5(f_dcd_ex1_uc_fb_0_5),		//i--fbyp

      .f_dcd_ex1_uc_fc_hulp(f_dcd_ex1_uc_fc_hulp),		//i--fbyp
      .f_dcd_ex1_bypsel_a_res0(f_dcd_ex1_bypsel_a_res0),		//i--fbyp
      .f_dcd_ex1_bypsel_a_res1(f_dcd_ex1_bypsel_a_res1),		//i--fbyp
      .f_dcd_ex1_bypsel_a_load0(f_dcd_ex1_bypsel_a_load0),		//i--fbyp
      .f_dcd_ex1_bypsel_a_load1(f_dcd_ex1_bypsel_a_load1),		//i--fbyp
      .f_dcd_ex1_bypsel_a_load2(f_dcd_ex1_bypsel_a_load2),
      .f_dcd_ex1_bypsel_a_reload0(f_dcd_ex1_bypsel_a_reload0),		//i--fbyp
      .f_dcd_ex1_bypsel_a_reload1(f_dcd_ex1_bypsel_a_reload1),		//i--fbyp
      .f_dcd_ex1_bypsel_a_reload2(f_dcd_ex1_bypsel_a_reload2),

      .f_dcd_ex1_bypsel_b_res0(f_dcd_ex1_bypsel_b_res0),		//i--fbyp
      .f_dcd_ex1_bypsel_b_res1(f_dcd_ex1_bypsel_b_res1),		//i--fbyp
      .f_dcd_ex1_bypsel_b_load0(f_dcd_ex1_bypsel_b_load0),		//i--fbyp
      .f_dcd_ex1_bypsel_b_load1(f_dcd_ex1_bypsel_b_load1),		//i--fbyp
      .f_dcd_ex1_bypsel_b_load2(f_dcd_ex1_bypsel_b_load2),
      .f_dcd_ex1_bypsel_b_reload0(f_dcd_ex1_bypsel_b_reload0),		//i--fbyp
      .f_dcd_ex1_bypsel_b_reload1(f_dcd_ex1_bypsel_b_reload1),		//i--fbyp
      .f_dcd_ex1_bypsel_b_reload2(f_dcd_ex1_bypsel_b_reload2),

      .f_dcd_ex1_bypsel_c_res0(f_dcd_ex1_bypsel_c_res0),		//i--fbyp
      .f_dcd_ex1_bypsel_c_res1(f_dcd_ex1_bypsel_c_res1),		//i--fbyp
      .f_dcd_ex1_bypsel_c_load0(f_dcd_ex1_bypsel_c_load0),		//i--fbyp
      .f_dcd_ex1_bypsel_c_load1(f_dcd_ex1_bypsel_c_load1),		//i--fbyp
      .f_dcd_ex1_bypsel_c_load2(f_dcd_ex1_bypsel_c_load2),
      .f_dcd_ex1_bypsel_c_reload0(f_dcd_ex1_bypsel_c_reload0),		//i--fbyp
      .f_dcd_ex1_bypsel_c_reload1(f_dcd_ex1_bypsel_c_reload1),		//i--fbyp
      .f_dcd_ex1_bypsel_c_reload2(f_dcd_ex1_bypsel_c_reload2),

      .f_dcd_ex1_bypsel_a_res2(f_dcd_ex1_bypsel_a_res2),
      .f_dcd_ex1_bypsel_b_res2(f_dcd_ex1_bypsel_b_res2),
      .f_dcd_ex1_bypsel_c_res2(f_dcd_ex1_bypsel_c_res2),
      .f_dcd_ex1_bypsel_s_res0(f_dcd_ex1_bypsel_s_res0),
      .f_dcd_ex1_bypsel_s_res1(f_dcd_ex1_bypsel_s_res1),
      .f_dcd_ex1_bypsel_s_res2(f_dcd_ex1_bypsel_s_res2),
      .f_dcd_ex1_bypsel_s_load0(f_dcd_ex1_bypsel_s_load0),
      .f_dcd_ex1_bypsel_s_load1(f_dcd_ex1_bypsel_s_load1),
      .f_dcd_ex1_bypsel_s_load2(f_dcd_ex1_bypsel_s_load2),
      .f_dcd_ex1_bypsel_s_reload0(f_dcd_ex1_bypsel_s_reload0),
      .f_dcd_ex1_bypsel_s_reload1(f_dcd_ex1_bypsel_s_reload1),
      .f_dcd_ex1_bypsel_s_reload2(f_dcd_ex1_bypsel_s_reload2),

      .f_rnd_ex7_res_sign(rnd_ex7_res_sign),		//i--fbyp
      .f_rnd_ex7_res_expo(rnd_ex7_res_expo[1:13]),		//i--fbyp
      .f_rnd_ex7_res_frac(rnd_ex7_res_frac[0:52]),		//i--fbyp

      .f_fpr_ex1_a_sign(f_fpr_ex1_a_sign),		//i--fbyp
      .f_fpr_ex1_a_expo(f_fpr_ex1_a_expo[1:13]),		//i--fbyp
      .f_fpr_ex1_a_frac(f_fpr_ex1_a_frac[0:52]),		//i--fbyp
      .f_fpr_ex1_c_sign(f_fpr_ex1_c_sign),		//i--fbyp
      .f_fpr_ex1_c_expo(f_fpr_ex1_c_expo[1:13]),		//i--fbyp
      .f_fpr_ex1_c_frac(f_fpr_ex1_c_frac[0:52]),		//i--fbyp
      .f_fpr_ex1_b_sign(f_fpr_ex1_b_sign),		//i--fbyp
      .f_fpr_ex1_b_expo(f_fpr_ex1_b_expo[1:13]),		//i--fbyp
      .f_fpr_ex1_b_frac(f_fpr_ex1_b_frac[0:52]),		//i--fbyp
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		//i--fbyp
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		//i--fbyp
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		//i--fbyp
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		//i--fbyp
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		//i--fbyp
      .f_dcd_ex1_emin_dp(f_dcd_ex1_emin_dp),		//i--fbyp
      .f_dcd_ex1_emin_sp(f_dcd_ex1_emin_sp),		//i--fbyp

      .f_byp_fmt_ex2_a_expo(f_byp_fmt_ex2_a_expo[1:13]),		//o--fbyp
      .f_byp_eie_ex2_a_expo(f_byp_eie_ex2_a_expo[1:13]),		//o--fbyp
      .f_byp_alg_ex2_a_expo(f_byp_alg_ex2_a_expo[1:13]),		//o--fbyp
      .f_byp_fmt_ex2_c_expo(f_byp_fmt_ex2_c_expo[1:13]),		//o--fbyp
      .f_byp_eie_ex2_c_expo(f_byp_eie_ex2_c_expo[1:13]),		//o--fbyp
      .f_byp_alg_ex2_c_expo(f_byp_alg_ex2_c_expo[1:13]),		//o--fbyp
      .f_byp_fmt_ex2_b_expo(f_byp_fmt_ex2_b_expo[1:13]),		//o--fbyp
      .f_byp_eie_ex2_b_expo(f_byp_eie_ex2_b_expo[1:13]),		//o--fbyp
      .f_byp_alg_ex2_b_expo(f_byp_alg_ex2_b_expo[1:13]),		//o--fbyp
      .f_byp_fmt_ex2_a_sign(f_byp_fmt_ex2_a_sign),		//o--fbyp
      .f_byp_fmt_ex2_c_sign(f_byp_fmt_ex2_c_sign),		//o--fbyp
      .f_byp_fmt_ex2_b_sign(f_byp_fmt_ex2_b_sign),		//o--fbyp
      .f_byp_pic_ex2_a_sign(f_byp_pic_ex2_a_sign),		//o--fbyp
      .f_byp_pic_ex2_c_sign(f_byp_pic_ex2_c_sign),		//o--fbyp
      .f_byp_pic_ex2_b_sign(f_byp_pic_ex2_b_sign),		//o--fbyp
      .f_byp_alg_ex2_b_sign(f_byp_alg_ex2_b_sign),		//o--fbyp
      .f_byp_mul_ex2_a_frac_17(f_byp_mul_ex2_a_frac_17),		//o--fbyp
      .f_byp_mul_ex2_a_frac_35(f_byp_mul_ex2_a_frac_35),		//o--fbyp
      .f_byp_mul_ex2_a_frac(f_byp_mul_ex2_a_frac[0:52]),		//o--fbyp
      .f_byp_fmt_ex2_a_frac(f_byp_fmt_ex2_a_frac[0:52]),		//o--fbyp
      .f_byp_mul_ex2_c_frac({f_byp_mul_ex2_c_frac[0:52], f_byp_mul_ex2_c_frac[53]}),		//o--fbyp
      .f_byp_fmt_ex2_c_frac(f_byp_fmt_ex2_c_frac[0:52]),		//o--fbyp
      .f_byp_alg_ex2_b_frac(f_byp_alg_ex2_b_frac[0:52]),		//o--fbyp
      .f_byp_fmt_ex2_b_frac(f_byp_fmt_ex2_b_frac[0:52])		//o--fbyp
   );
   //--------------------------------------------------------- -- fuq_byp.vhdl



   		// fu_fmt.vhdl
   fu_fmt  ffmt(
      //----------------------------------------------------------- fu_fmt.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1:2]),		//i--
      .mpw1_b(mpw1_b[1:2]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_fmt_thold_1),		//i--
      .sg_1(perv_fmt_sg_1),		//i--
      .fpu_enable(perv_fmt_fpu_enable),		//i--

      .f_fmt_si(scan_in[1]),		//i--ffmt
      .f_fmt_so(scan_out[1]),		//o--ffmt
      .ex1_act(f_dcd_ex1_act),
      .ex2_act(f_pic_fmt_ex2_act),

      .f_dcd_ex2_perr_force_c(f_dcd_ex2_perr_force_c),
      .f_dcd_ex2_perr_fsel_ovrd(f_dcd_ex2_perr_fsel_ovrd),
      .f_pic_ex2_ftdiv(f_pic_ex2_ftdiv),
      .f_fmt_ex3_be_den(f_fmt_ex3_be_den),
      .f_fpr_ex2_a_par(f_fpr_ex2_a_par[0:7]),		//i--ffmt
      .f_fpr_ex2_c_par(f_fpr_ex2_c_par[0:7]),		//i--ffmt
      .f_fpr_ex2_b_par(f_fpr_ex2_b_par[0:7]),		//i--ffmt

      .f_mad_ex3_a_parity_check(f_mad_ex3_a_parity_check),		//o--ffmt
      .f_mad_ex3_c_parity_check(f_mad_ex3_c_parity_check),		//o--ffmt
      .f_mad_ex3_b_parity_check(f_mad_ex3_b_parity_check),		//o--ffmt
      .f_fmt_ex3_ae_ge_54(f_fmt_ex3_ae_ge_54),		//o--ffmt
      .f_fmt_ex3_be_ge_54(f_fmt_ex3_be_ge_54),		//o--ffmt
      .f_fmt_ex3_be_ge_2(f_fmt_ex3_be_ge_2),		//o--ffmt
      .f_fmt_ex3_be_ge_2044(f_fmt_ex3_be_ge_2044),		//o--ffmt
      .f_fmt_ex3_tdiv_rng_chk(f_fmt_ex3_tdiv_rng_chk),		//o--ffmt

      .f_byp_fmt_ex2_a_sign(f_byp_fmt_ex2_a_sign),		//i--ffmt
      .f_byp_fmt_ex2_c_sign(f_byp_fmt_ex2_c_sign),		//i--ffmt
      .f_byp_fmt_ex2_b_sign(f_byp_fmt_ex2_b_sign),		//i--ffmt
      .f_byp_fmt_ex2_a_expo(f_byp_fmt_ex2_a_expo[1:13]),		//i--ffmt
      .f_byp_fmt_ex2_c_expo(f_byp_fmt_ex2_c_expo[1:13]),		//i--ffmt
      .f_byp_fmt_ex2_b_expo(f_byp_fmt_ex2_b_expo[1:13]),		//i--ffmt

      .f_byp_fmt_ex2_a_frac(f_byp_fmt_ex2_a_frac[0:52]),		//i--ffmt
      .f_byp_fmt_ex2_c_frac(f_byp_fmt_ex2_c_frac[0:52]),		//i--ffmt
      .f_byp_fmt_ex2_b_frac(f_byp_fmt_ex2_b_frac[0:52]),		//i--ffmt

      .f_dcd_ex1_sp(f_dcd_ex1_sp),		//i--ffmt
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		//i--ffmt
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),		//i--ffmt
      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),		//i--ffmt
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),		//i--ffmt
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),		//i--ffmt
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		//i--ffmt
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		//i--ffmt
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		//i--ffmt
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),		//i--ffmt
      .f_dcd_ex1_force_pass_b(f_dcd_ex1_force_pass_b),		//i--ffmt
      .f_dcd_ex2_divsqrt_v(f_dcd_ex2_divsqrt_v),		//i--ffmt
      .f_pic_ex2_flush_en_sp(f_pic_ex2_flush_en_sp),		//i--ffmt
      .f_pic_ex2_flush_en_dp(f_pic_ex2_flush_en_dp),		//i--ffmt
      .f_pic_ex2_nj_deni(f_pic_ex2_nj_deni),		//i--ffmt (connect)
      .f_fmt_ex3_lu_den_recip(f_fmt_ex3_lu_den_recip),		//o--ffmt
      .f_fmt_ex3_lu_den_rsqrto(f_fmt_ex3_lu_den_rsqrto),		//o--ffmt
      .f_fmt_ex2_bop_byt(f_fmt_ex2_bop_byt[45:52]),		//o--ffmt
      .f_fmt_ex2_b_frac(f_fmt_ex2_b_frac[1:19]),		//o--ffmt

      .f_fmt_ex2_a_sign_div(f_fmt_ex2_a_sign_div),		//o--fdsq  --  :in std_ulogic;
      .f_fmt_ex2_a_expo_div_b(f_fmt_ex2_a_expo_div_b),		//o--fdsq  --  :in std_ulogic_vector(01 to 13);
      .f_fmt_ex2_a_frac_div(f_fmt_ex2_a_frac_div),		//o--fdsq  --  :in std_ulogic_vector(01 to 52);

      .f_fmt_ex2_b_sign_div(f_fmt_ex2_b_sign_div),		//o--fdsq  --  :in std_ulogic;
      .f_fmt_ex2_b_expo_div_b(f_fmt_ex2_b_expo_div_b),		//o--fdsq  --  :in std_ulogic_vector(01 to 13);
      .f_fmt_ex2_b_frac_div(f_fmt_ex2_b_frac_div),		//o--fdsq  --  :in std_ulogic_vector(01 to 52);

      .f_fmt_ex2_bexpu_le126(f_fmt_ex2_bexpu_le126),		//o--ffmt
      .f_fmt_ex2_gt126(f_fmt_ex2_gt126),		//o--ffmt
      .f_fmt_ex2_ge128(f_fmt_ex2_ge128),		//o--ffmt
      .f_fmt_ex2_inf_and_beyond_sp(f_fmt_ex2_inf_and_beyond_sp),		//o--ffmt

      .f_fmt_ex2_b_sign_gst(f_fmt_ex2_b_sign_gst),		//o--ffmt
      .f_fmt_ex2_b_expo_gst_b(f_fmt_ex2_b_expo_gst_b[1:13]),		//o--ffmt
      .f_mad_ex3_uc_a_expo_den(f_mad_ex3_uc_a_expo_den),		//o--ffmt
      .f_mad_ex3_uc_a_expo_den_sp(f_mad_ex3_uc_a_expo_den_sp),		//o--ffmt
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		//o--ffmt
      .f_fmt_ex2_a_zero_dsq(f_fmt_ex2_a_zero_dsq),		//o--ffmt
      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		//o--ffmt
      .f_fmt_ex2_a_expo_max_dsq(f_fmt_ex2_a_expo_max_dsq),		//o--ffmt
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		//o--ffmt
      .f_fmt_ex2_a_frac_msb(f_fmt_ex2_a_frac_msb),		//o--ffmt
      .f_fmt_ex2_c_zero(f_fmt_ex2_c_zero),		//o--ffmt
      .f_fmt_ex2_c_expo_max(f_fmt_ex2_c_expo_max),		//o--ffmt
      .f_fmt_ex2_c_frac_zero(f_fmt_ex2_c_frac_zero),		//o--ffmt
      .f_fmt_ex2_c_frac_msb(f_fmt_ex2_c_frac_msb),		//o--ffmt
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		//o--ffmt
      .f_fmt_ex2_b_zero_dsq(f_fmt_ex2_b_zero_dsq),		//o--ffmt
      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		//o--ffmt
      .f_fmt_ex2_b_expo_max_dsq(f_fmt_ex2_b_expo_max_dsq),		//o--ffmt
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		//o--ffmt
      .f_fmt_ex2_b_frac_msb(f_fmt_ex2_b_frac_msb),		//o--ffmt
      .f_fmt_ex2_b_frac_z32(f_fmt_ex2_b_frac_z32),		//o--ffmt
      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		//o--ffmt
      .f_fmt_ex2_pass_sel(f_fmt_ex2_pass_sel),		//o--ffmt
      .f_fmt_ex2_sp_invalid(f_fmt_ex2_sp_invalid),		//o--ffmt
      .f_ex3_b_den_flush(f_ex3_b_den_flush),		//o--ffmt
      .f_fmt_ex3_fsel_bsel(f_fmt_ex3_fsel_bsel),		//o--ffmt
      .f_fmt_ex3_pass_sign(f_fmt_ex3_pass_sign),		//o--ffmt
      .f_fmt_ex3_pass_msb(f_fmt_ex3_pass_msb),		//o--ffmt
      .f_fmt_ex2_b_imp(f_fmt_ex2_b_imp),		//o--ffmt
      .f_fmt_ex3_pass_frac(f_fmt_ex3_pass_frac[0:52])		//o--ffmt
   );
   //----------------------------------------------------------- fu_fmt.vhdl

   		// fu_eie.vhdl
   fu_eie  feie(
      //----------------------------------------------------------- fu_eie.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:3]),		//i--
      .mpw1_b(mpw1_b[2:3]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_eie_thold_1),		//i--
      .sg_1(perv_eie_sg_1),		//i--
      .fpu_enable(perv_eie_fpu_enable),		//i--

      .f_eie_si(scan_in[2]),		//i--feie
      .f_eie_so(scan_out[2]),		//o--feie
      .ex2_act(f_pic_eie_ex2_act),		//i--feie
      .f_byp_eie_ex2_a_expo(f_byp_eie_ex2_a_expo[1:13]),		//i--feie
      .f_byp_eie_ex2_c_expo(f_byp_eie_ex2_c_expo[1:13]),		//i--feie
      .f_byp_eie_ex2_b_expo(f_byp_eie_ex2_b_expo[1:13]),		//i--feie
      .f_pic_ex2_from_integer(f_pic_ex2_from_integer),		//i--feie
      .f_pic_ex2_fsel(f_pic_ex2_fsel),		//i--feie
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		//i--feie
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		//i--feie
      .f_fmt_ex3_fsel_bsel(f_fmt_ex3_fsel_bsel),		//i--feie
      .f_pic_ex3_force_sel_bexp(f_pic_ex3_force_sel_bexp),		//i--feie
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		//i--feie
      .f_pic_ex3_math_bzer_b(f_pic_ex3_math_bzer_b),		//i--feie
      .f_eie_ex3_lt_bias(f_eie_ex3_lt_bias),		//o--feie
      .f_eie_ex3_eq_bias_m1(f_eie_ex3_eq_bias_m1),		//o--feie
      .f_eie_ex3_wd_ov(f_eie_ex3_wd_ov),		//o--feie
      .f_eie_ex3_dw_ov(f_eie_ex3_dw_ov),		//o--feie
      .f_eie_ex3_wd_ov_if(f_eie_ex3_wd_ov_if),		//o--feie
      .f_eie_ex3_dw_ov_if(f_eie_ex3_dw_ov_if),		//o--feie
      .f_eie_ex3_lzo_expo(f_eie_ex3_lzo_expo[1:13]),		//o--feie
      .f_eie_ex3_b_expo(f_eie_ex3_b_expo[1:13]),		//o--feie
      .f_eie_ex3_use_bexp(f_eie_ex3_use_bexp),		//o--feie
      .f_eie_ex3_tbl_expo(f_eie_ex3_tbl_expo[1:13]),		//o--feie
      .f_eie_ex4_iexp(f_eie_ex4_iexp[1:13])		//o--feie
   );
   //----------------------------------------------------------- fu_eie.vhdl

   		// fu_eov.vhdl
   fu_eov  feov(
      //----------------------------------------------------------- fu_eov.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[4:5]),		//i--
      .mpw1_b(mpw1_b[4:5]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_eov_thold_1),		//i--
      .sg_1(perv_eov_sg_1),		//i--
      .fpu_enable(perv_eov_fpu_enable),		//i--

      .f_eov_si(scan_in[3]),		//i--feov
      .f_eov_so(scan_out[3]),		//o--feov
      .ex3_act_b(f_pic_eov_ex3_act_b),		//i--feov
      .f_tbl_ex5_unf_expo(f_tbl_ex5_unf_expo),		//i--feov
      .f_tbe_ex4_may_ov(f_tbe_ex4_may_ov),		//i--feov
      .f_tbe_ex4_expo(f_tbe_ex4_res_expo[1:13]),		//i--feov
      .f_pic_ex4_sel_est(f_pic_ex4_sel_est),		//i--feov
      .f_eie_ex4_iexp(f_eie_ex4_iexp[1:13]),		//i--feov
      .f_pic_ex4_sp_b(f_pic_ex4_sp_b),		//i--feov
      .f_lza_ex5_sh_rgt_en_eov(f_lza_ex5_sh_rgt_en_eov),		//i--feov
      .f_pic_ex5_oe(f_pic_ex5_oe),		//i--feov
      .f_pic_ex5_ue(f_pic_ex5_ue),		//i--feov
      .f_pic_ex5_ov_en(f_pic_ex5_ov_en),		//i--feov
      .f_pic_ex5_uf_en(f_pic_ex5_uf_en),		//i--feov
      .f_pic_ex5_spec_sel_k_e(f_pic_ex5_spec_sel_k_e),		//i--feov
      .f_pic_ex5_spec_sel_k_f(f_pic_ex5_spec_sel_k_f),		//i--feov
      .f_pic_ex5_sel_ov_spec(tidn),		//i--feov  UNUSED DELETE

      .f_pic_ex5_to_int_ov_all(f_pic_ex5_to_int_ov_all),		//i--feov

      .f_lza_ex5_no_lza_edge(f_lza_ex5_no_lza_edge),		//i--feov
      .f_lza_ex5_lza_amt_eov(f_lza_ex5_lza_amt_eov[0:7]),		//i--feov
      .f_nrm_ex5_extra_shift(f_nrm_ex5_extra_shift),		//i--feov
      .f_eov_ex5_may_ovf(f_eov_ex5_may_ovf),		//o--feov
      .f_eov_ex6_sel_k_f(f_eov_ex6_sel_k_f),		//o--feov
      .f_eov_ex6_sel_k_e(f_eov_ex6_sel_k_e),		//o--feov
      .f_eov_ex6_sel_kif_f(f_eov_ex6_sel_kif_f),		//o--feov
      .f_eov_ex6_sel_kif_e(f_eov_ex6_sel_kif_e),		//o--feov
      .f_eov_ex6_unf_expo(f_eov_ex6_unf_expo),		//o--feov
      .f_eov_ex6_ovf_expo(f_eov_ex6_ovf_expo),		//o--feov
      .f_eov_ex6_ovf_if_expo(f_eov_ex6_ovf_if_expo),		//o--feov
      .f_eov_ex6_expo_p0(f_eov_ex6_expo_p0[1:13]),		//o--feov
      .f_eov_ex6_expo_p1(f_eov_ex6_expo_p1[1:13]),		//o--feov
      .f_eov_ex6_expo_p0_ue1oe1(f_eov_ex6_expo_p0_ue1oe1[3:7]),		//o--feov
      .f_eov_ex6_expo_p1_ue1oe1(f_eov_ex6_expo_p1_ue1oe1[3:7])		//o--feov
   );
   //----------------------------------------------------------- fu_eov.vhdl



   		// fu_mul.vhdl
   tri_fu_mul  fmul(
      //----------------------------------------------------------- fu_mul.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2]),		//i--
      .mpw1_b(mpw1_b[2]),		//i--
      .mpw2_b(mpw2_b[0]),		//i--
      .thold_1(perv_mul_thold_1),		//i--
      .sg_1(perv_mul_sg_1),		//i--
      .fpu_enable(perv_mul_fpu_enable),		//i--

      .f_mul_si(scan_in[4]),		//i--fmul
      .f_mul_so(scan_out[4]),		//o--fmul
      .ex2_act(f_pic_mul_ex2_act),		//i--fmul
      .f_fmt_ex2_a_frac(f_byp_mul_ex2_a_frac[0:52]),		//i--fmul
      .f_fmt_ex2_a_frac_17(f_byp_mul_ex2_a_frac_17),		//i--fmul
      .f_fmt_ex2_a_frac_35(f_byp_mul_ex2_a_frac_35),		//i--fmul
      .f_fmt_ex2_c_frac(f_byp_mul_ex2_c_frac[0:53]),		//i--fmul
      .f_mul_ex3_sum(f_mul_ex3_sum[1:108]),		//o--fmul
      .f_mul_ex3_car(f_mul_ex3_car[1:108])		//o--fmul
   );
   //----------------------------------------------------------- fu_mul.vhdl

   		// fu_alg.vhdl
   fu_alg  falg(
      //----------------------------------------------------------- fu_alg.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1:3]),		//i--
      .mpw1_b(mpw1_b[1:3]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_alg_thold_1),		//i--
      .sg_1(perv_alg_sg_1),		//i--
      .fpu_enable(perv_alg_fpu_enable),		//i--

      .f_alg_si(scan_in[5]),		//i--falg
      .f_alg_so(scan_out[5]),		//o--falg
      .ex1_act(f_dcd_ex1_act),		//i--falg
      .ex2_act(f_pic_alg_ex2_act),		//i--falg
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		//i--falg

      .f_pic_ex2_frsp_ue1(f_pic_ex2_frsp_ue1),		//i--feie WRONG cycle (move to ex2)

      .f_byp_alg_ex2_b_frac(f_byp_alg_ex2_b_frac[0:52]),		//i--falg
      .f_byp_alg_ex2_b_sign(f_byp_alg_ex2_b_sign),		//i--falg
      .f_byp_alg_ex2_b_expo(f_byp_alg_ex2_b_expo[1:13]),		//i--falg
      .f_byp_alg_ex2_a_expo(f_byp_alg_ex2_a_expo[1:13]),		//i--falg
      .f_byp_alg_ex2_c_expo(f_byp_alg_ex2_c_expo[1:13]),		//i--falg

      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		//i--falg
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		//i--falg
      .f_fmt_ex2_pass_sel(f_fmt_ex2_pass_sel),		//i--falg
      .f_fmt_ex3_pass_frac(f_fmt_ex3_pass_frac[0:52]),		//i--falg
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),		//i--falg
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),		//i--falg
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		//i--falg
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		//i--falg
      .f_pic_ex2_rnd_to_int(f_pic_ex2_rnd_to_int),		//i--falg
      .f_pic_ex2_effsub_raw(f_pic_ex2_effsub_raw),		//i--falg
      .f_pic_ex2_sh_unf_ig_b(f_pic_ex2_sh_unf_ig_b),		//i--falg
      .f_pic_ex2_sh_unf_do(f_pic_ex2_sh_unf_do),		//i--falg
      .f_pic_ex2_sh_ovf_ig_b(f_pic_ex2_sh_ovf_ig_b),		//i--falg
      .f_pic_ex2_sh_ovf_do(f_pic_ex2_sh_ovf_do),		//i--falg
      .f_pic_ex3_rnd_nr(f_pic_ex3_rnd_nr),		//i--falg
      .f_pic_ex3_rnd_inf_ok(f_pic_ex3_rnd_inf_ok),		//i--falg
      .f_alg_ex2_sign_frmw(f_alg_ex2_sign_frmw),		//o--falg
      .f_alg_ex3_res(f_alg_ex3_res[0:162]),		//o--falg
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		//o--falg
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		//o--falg
      .f_alg_ex3_prod_z(f_alg_ex3_prod_z),		//o--falg
      .f_alg_ex3_sh_unf(f_alg_ex3_sh_unf),		//o--falg
      .f_alg_ex3_sh_ovf(f_alg_ex3_sh_ovf),		//o--falg
      .f_alg_ex3_byp_nonflip(f_alg_ex3_byp_nonflip),		//o--falg
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		//o--falg
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		//o--falg
      .f_alg_ex4_int_fr(f_alg_ex4_int_fr),		//o--falg
      .f_alg_ex4_int_fi(f_alg_ex4_int_fi)		//o--falg
   );
   //----------------------------------------------------------- fu_alg.vhdl

   		// fuq_sa3.vhdl
   fu_sa3  fsa3(
      //----------------------------------------------------------- fuq_sa3.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:3]),		//i--
      .mpw1_b(mpw1_b[2:3]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_sa3_thold_1),		//i--
      .sg_1(perv_sa3_sg_1),		//i--
      .fpu_enable(perv_sa3_fpu_enable),		//i--

      .f_sa3_si(scan_in[6]),		//i--fsa3
      .f_sa3_so(scan_out[6]),		//o--fsa3
      .ex2_act_b(f_pic_add_ex2_act_b),		//i--fsa3
      .f_mul_ex3_sum(f_mul_ex3_sum[1:108]),		//i--fsa3
      .f_mul_ex3_car(f_mul_ex3_car[1:108]),		//i--fsa3
      .f_alg_ex3_res(f_alg_ex3_res[0:162]),		//i--fsa3
      .f_sa3_ex4_s_lza(f_sa3_ex4_s_lza[0:162]),		//o--fsa3
      .f_sa3_ex4_c_lza(f_sa3_ex4_c_lza[53:161]),		//o--fsa3
      .f_sa3_ex4_s_add(f_sa3_ex4_s_add[0:162]),		//o--fsa3
      .f_sa3_ex4_c_add(f_sa3_ex4_c_add[53:161])		//o--fsa3
   );
   //----------------------------------------------------------- fuq_sa3.vhdl

   		// fu_add.vhdl
   fu_add  fadd(
      //----------------------------------------------------------- fu_add.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[3:4]),		//i--
      .mpw1_b(mpw1_b[3:4]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_add_thold_1),		//i--
      .sg_1(perv_add_sg_1),		//i--
      .fpu_enable(perv_add_fpu_enable),		//i--

      .f_add_si(scan_in[7]),		//i--fadd
      .f_add_so(scan_out[7]),		//o--fadd
      .ex2_act_b(f_pic_add_ex2_act_b),		//i--fadd
      .f_sa3_ex4_s(f_sa3_ex4_s_add[0:162]),		//i--fadd
      .f_sa3_ex4_c(f_sa3_ex4_c_add[53:161]),		//i--fadd
      .f_alg_ex4_frc_sel_p1(f_alg_ex4_frc_sel_p1),		//i--fadd
      .f_alg_ex4_sticky(f_alg_ex4_sticky),		//i--fadd
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		//i--fadd
      .f_alg_ex3_prod_z(f_alg_ex3_prod_z),		//i--fadd
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		//i--fadd
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		//i--fadd
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		//i--fadd
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		//i--fadd
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		//i--fadd
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		//i--fadd
      .f_add_ex5_res(f_add_ex5_res[0:162]),		//o--fadd
      .f_add_ex5_flag_nan(f_add_ex5_flag_nan),		//o--fadd
      .f_add_ex5_flag_gt(f_add_ex5_flag_gt),		//o--fadd
      .f_add_ex5_flag_lt(f_add_ex5_flag_lt),		//o--fadd
      .f_add_ex5_flag_eq(f_add_ex5_flag_eq),		//o--fadd
      .f_add_ex5_fpcc_iu(f_add_ex5_fpcc_iu[0:3]),		//o--fadd
      .f_add_ex5_sign_carry(f_add_ex5_sign_carry),		//o--fadd
      .f_add_ex5_to_int_ovf_wd(f_add_ex5_to_int_ovf_wd[0:1]),		//o--fadd
      .f_add_ex5_to_int_ovf_dw(f_add_ex5_to_int_ovf_dw[0:1]),		//o--fadd
      .f_add_ex5_sticky(f_add_ex5_sticky)		//o--fadd
   );
   //----------------------------------------------------------- fu_add.vhdl

   		// fu_lze.vhdl
   fu_lze  flze(
      //----------------------------------------------------------- fu_lze.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:3]),		//i--
      .mpw1_b(mpw1_b[2:3]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_lza_thold_1),		//i--
      .sg_1(perv_lza_sg_1),		//i--
      .fpu_enable(perv_lza_fpu_enable),		//i--

      .f_lze_si(scan_in[8]),		//i--flze
      .f_lze_so(scan_out[8]),		//o--flze
      .ex2_act_b(f_pic_lza_ex2_act_b),		//i--flze
      .f_eie_ex3_lzo_expo(f_eie_ex3_lzo_expo[1:13]),		//i--flze
      .f_eie_ex3_b_expo(f_eie_ex3_b_expo[1:13]),		//i--flze
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		//i--flze
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		//i--flze
      .f_alg_ex3_byp_nonflip(f_alg_ex3_byp_nonflip),		//i--flze
      .f_eie_ex3_use_bexp(f_eie_ex3_use_bexp),		//i--flze
      .f_pic_ex3_b_valid(f_pic_ex3_b_valid),		//i--flze
      .f_pic_ex3_lzo_dis_prod(f_pic_ex3_lzo_dis_prod),		//i--flze
      .f_pic_ex3_sp_lzo(f_pic_ex3_sp_lzo),		//i--flze
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		//i--flze
      .f_fmt_ex3_pass_msb_dp(f_fmt_ex3_pass_frac[0]),		//i--flze
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		//i--flze
      .f_pic_ex3_to_integer(f_pic_ex3_to_integer),		//i--flze
      .f_pic_ex3_prenorm(f_pic_ex3_prenorm),		//i--flze

      .f_lze_ex3_lzo_din(f_lze_ex3_lzo_din[0:162]),		//o--flze
      .f_lze_ex4_sh_rgt_amt(f_lze_ex4_sh_rgt_amt[0:7]),		//o--flze
      .f_lze_ex4_sh_rgt_en(f_lze_ex4_sh_rgt_en)		//o--flze
   );

   //----------------------------------------------------------- fu_lze vhdl

   		// fu_lza.vhdl
   fu_lza  flza(
      //----------------------------------------------------------- fu_lza.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[3:4]),		//i--
      .mpw1_b(mpw1_b[3:4]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_lza_thold_1),		//i--
      .sg_1(perv_lza_sg_1),		//i--
      .fpu_enable(perv_lza_fpu_enable),		//i--

      .f_lza_si(scan_in[9]),		//i--flza
      .f_lza_so(scan_out[9]),		//o--flza
      .ex2_act_b(f_pic_lza_ex2_act_b),		//i--flza
      .f_sa3_ex4_s(f_sa3_ex4_s_lza[0:162]),		//i--flza
      .f_sa3_ex4_c(f_sa3_ex4_c_lza[53:161]),		//i--flza
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		//i--flza

      .f_lze_ex3_lzo_din(f_lze_ex3_lzo_din[0:162]),		//i--flza
      .f_lze_ex4_sh_rgt_amt(f_lze_ex4_sh_rgt_amt[0:7]),		//i--flza
      .f_lze_ex4_sh_rgt_en(f_lze_ex4_sh_rgt_en),		//i--flza

      .f_lza_ex5_no_lza_edge(f_lza_ex5_no_lza_edge),		//o--flza
      .f_lza_ex5_lza_amt(f_lza_ex5_lza_amt[0:7]),		//o--flza
      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		//o--flza
      .f_lza_ex5_sh_rgt_en_eov(f_lza_ex5_sh_rgt_en_eov),		//o--flza
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		//o--flza
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		//o--flza
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0]),		//o--flza

      .f_lza_ex5_lza_amt_eov(f_lza_ex5_lza_amt_eov[0:7])		//o--flza
   );
   //----------------------------------------------------------- fu_lza vhdl

   		// fu_nrm.vhdl
   fu_nrm  fnrm(
      //----------------------------------------------------------- fu_nrm.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[4:5]),		//i--
      .mpw1_b(mpw1_b[4:5]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_nrm_thold_1),		//i--
      .sg_1(perv_nrm_sg_1),		//i--
      .fpu_enable(perv_nrm_fpu_enable),		//i--

      .f_nrm_si(scan_in[10]),		//i--fnrm
      .f_nrm_so(scan_out[10]),		//o--fnrm
      .ex4_act_b(f_pic_nrm_ex4_act_b),		//i--fnrm

      .f_lza_ex5_sh_rgt_en(f_lza_ex5_sh_rgt_en),		//i--fnrm
      .f_lza_ex5_lza_amt_cp1(f_lza_ex5_lza_amt[0:7]),		//i--fnrm
      .f_lza_ex5_lza_dcd64_cp1(f_lza_ex5_lza_dcd64_cp1[0:2]),		//o--fnrm
      .f_lza_ex5_lza_dcd64_cp2(f_lza_ex5_lza_dcd64_cp2[0:1]),		//o--fnrm
      .f_lza_ex5_lza_dcd64_cp3(f_lza_ex5_lza_dcd64_cp3[0]),		//o--fnrm

      .f_add_ex5_res(f_add_ex5_res[0:162]),		//i--fnrm
      .f_add_ex5_sticky(f_add_ex5_sticky),		//i--fnrm
      .f_pic_ex5_byp_prod_nz(f_pic_ex5_byp_prod_nz),		//i--fnrm
      .f_nrm_ex6_res(f_nrm_ex6_res[0:52]),		//o--fnrm
      .f_nrm_ex6_int_lsbs(f_nrm_ex6_int_lsbs[1:12]),		//o--fnrm
      .f_nrm_ex6_int_sign(f_nrm_ex6_int_sign),		//o--fnrm
      .f_nrm_ex6_nrm_sticky_dp(f_nrm_ex6_nrm_sticky_dp),		//o--fnrm
      .f_nrm_ex6_nrm_guard_dp(f_nrm_ex6_nrm_guard_dp),		//o--fnrm
      .f_nrm_ex6_nrm_lsb_dp(f_nrm_ex6_nrm_lsb_dp),		//o--fnrm
      .f_nrm_ex6_nrm_sticky_sp(f_nrm_ex6_nrm_sticky_sp),		//o--fnrm
      .f_nrm_ex6_nrm_guard_sp(f_nrm_ex6_nrm_guard_sp),		//o--fnrm
      .f_nrm_ex6_nrm_lsb_sp(f_nrm_ex6_nrm_lsb_sp),		//o--fnrm
      .f_nrm_ex6_exact_zero(f_nrm_ex6_exact_zero),		//o--fnrm
      .f_nrm_ex5_extra_shift(f_nrm_ex5_extra_shift),		//o--fnrm
      .f_nrm_ex6_fpscr_wr_dat_dfp(f_nrm_ex6_fpscr_wr_dat_dfp[0:3]),		//o--fnrm
      .f_nrm_ex6_fpscr_wr_dat(f_nrm_ex6_fpscr_wr_dat[0:31])		//o--fnrm
   );
   //----------------------------------------------------------- fu_nrm.vhdl

   		// fu_rnd.vhdl
   fu_rnd  frnd(
      //----------------------------------------------------------- fu_rnd.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[5:6]),		//i--
      .mpw1_b(mpw1_b[5:6]),		//i--
      .mpw2_b(mpw2_b[1:1]),		//i--
      .thold_1(perv_rnd_thold_1),		//i--
      .sg_1(perv_rnd_sg_1),		//i--
      .fpu_enable(perv_rnd_fpu_enable),		//i--

      .f_rnd_si(scan_in[11]),		//i--frnd
      .f_rnd_so(scan_out[11]),		//o--frnd
      .ex4_act_b(f_pic_rnd_ex4_act_b),		//i--frnd
      .f_pic_ex5_sel_est_b(f_pic_ex5_sel_est_b),		//i--frnd
      .f_tbl_ex6_est_frac(f_tbl_ex6_est_frac[0:26]),		//i--frnd
      .f_nrm_ex6_res(f_nrm_ex6_res[0:52]),		//i--frnd
      .f_nrm_ex6_int_lsbs(f_nrm_ex6_int_lsbs[1:12]),		//i--frnd
      .f_nrm_ex6_int_sign(f_nrm_ex6_int_sign),		//i--frnd
      .f_nrm_ex6_nrm_sticky_dp(f_nrm_ex6_nrm_sticky_dp),		//i--frnd
      .f_nrm_ex6_nrm_guard_dp(f_nrm_ex6_nrm_guard_dp),		//i--frnd
      .f_nrm_ex6_nrm_lsb_dp(f_nrm_ex6_nrm_lsb_dp),		//i--frnd
      .f_nrm_ex6_nrm_sticky_sp(f_nrm_ex6_nrm_sticky_sp),		//i--frnd
      .f_nrm_ex6_nrm_guard_sp(f_nrm_ex6_nrm_guard_sp),		//i--frnd
      .f_nrm_ex6_nrm_lsb_sp(f_nrm_ex6_nrm_lsb_sp),		//i--frnd
      .f_nrm_ex6_exact_zero(f_nrm_ex6_exact_zero),		//i--frnd
      .f_pic_ex6_invert_sign(f_pic_ex6_invert_sign),		//i--frnd
      .f_pic_ex6_en_exact_zero(f_pic_ex6_en_exact_zero),		//i--frnd
      .f_pic_ex6_k_nan(f_pic_ex6_k_nan),		//i--frnd
      .f_pic_ex6_k_inf(f_pic_ex6_k_inf),		//i--frnd
      .f_pic_ex6_k_max(f_pic_ex6_k_max),		//i--frnd
      .f_pic_ex6_k_zer(f_pic_ex6_k_zer),		//i--frnd
      .f_pic_ex6_k_one(f_pic_ex6_k_one),		//i--frnd
      .f_pic_ex6_k_int_maxpos(f_pic_ex6_k_int_maxpos),		//i--frnd
      .f_pic_ex6_k_int_maxneg(f_pic_ex6_k_int_maxneg),		//i--frnd
      .f_pic_ex6_k_int_zer(f_pic_ex6_k_int_zer),		//i--frnd
      .f_tbl_ex6_recip_den(f_tbl_ex6_recip_den),		//i--frnd
      .f_pic_ex5_rnd_ni_b(f_pic_ex5_rnd_ni_b),		//i--frnd
      .f_pic_ex5_rnd_nr_b(f_pic_ex5_rnd_nr_b),		//i--frnd
      .f_pic_ex5_rnd_inf_ok_b(f_pic_ex5_rnd_inf_ok_b),		//i--frnd
      .f_pic_ex6_uc_inc_lsb(f_pic_ex6_uc_inc_lsb),		//i--frnd
      .f_pic_ex6_uc_guard(f_pic_ex6_uc_guard),		//i--frnd
      .f_pic_ex6_uc_sticky(f_pic_ex6_uc_sticky),		//i--frnd
      .f_pic_ex6_uc_g_v(f_pic_ex6_uc_g_v),		//i--frnd
      .f_pic_ex6_uc_s_v(f_pic_ex6_uc_s_v),		//i--frnd
      .f_pic_ex5_sel_fpscr_b(f_pic_ex5_sel_fpscr_b),		//i--frnd
      .f_pic_ex5_to_integer_b(f_pic_ex5_to_integer_b),		//i--frnd
      .f_pic_ex5_word_b(f_pic_ex5_word_b),		//i--frnd
      .f_pic_ex5_uns_b(f_pic_ex5_uns_b),		//i--frnd
      .f_pic_ex5_sp_b(f_pic_ex5_sp_b),		//i--frnd
      .f_pic_ex5_spec_inf_b(f_pic_ex5_spec_inf_b),		//i--frnd
      .f_pic_ex5_quiet_b(f_pic_ex5_quiet_b),		//i--frnd
      .f_pic_ex5_nj_deno(f_pic_ex5_nj_deno),		//i--frnd
      .f_pic_ex5_unf_en_ue0_b(f_pic_ex5_unf_en_ue0_b),		//i--frnd
      .f_pic_ex5_unf_en_ue1_b(f_pic_ex5_unf_en_ue1_b),		//i--frnd
      .f_pic_ex5_ovf_en_oe0_b(f_pic_ex5_ovf_en_oe0_b),		//i--frnd
      .f_pic_ex5_ovf_en_oe1_b(f_pic_ex5_ovf_en_oe1_b),		//i--frnd
      .f_pic_ex6_round_sign(f_pic_ex6_round_sign),		//i--frnd
      .f_scr_ex6_fpscr_rd_dat_dfp(f_scr_ex6_fpscr_rd_dat_dfp[0:3]),		//i--frnd
      .f_scr_ex6_fpscr_rd_dat(f_scr_ex6_fpscr_rd_dat[0:31]),		//i--frnd
      .f_eov_ex6_sel_k_f(f_eov_ex6_sel_k_f),		//i--frnd
      .f_eov_ex6_sel_k_e(f_eov_ex6_sel_k_e),		//i--frnd
      .f_eov_ex6_sel_kif_f(f_eov_ex6_sel_kif_f),		//i--frnd
      .f_eov_ex6_sel_kif_e(f_eov_ex6_sel_kif_e),		//i--frnd
      .f_eov_ex6_ovf_expo(f_eov_ex6_ovf_expo),		//i--frnd
      .f_eov_ex6_ovf_if_expo(f_eov_ex6_ovf_if_expo),		//i--frnd
      .f_eov_ex6_unf_expo(f_eov_ex6_unf_expo),		//i--frnd
      .f_pic_ex6_frsp(f_pic_ex6_frsp),		//i--frnd
      .f_eov_ex6_expo_p0(f_eov_ex6_expo_p0[1:13]),		//i--frnd
      .f_eov_ex6_expo_p1(f_eov_ex6_expo_p1[1:13]),		//i--frnd
      .f_eov_ex6_expo_p0_ue1oe1(f_eov_ex6_expo_p0_ue1oe1[3:7]),		//i--frnd
      .f_eov_ex6_expo_p1_ue1oe1(f_eov_ex6_expo_p1_ue1oe1[3:7]),		//i--frnd
      .f_gst_ex6_logexp_v(f_gst_ex6_logexp_v),		//i--frnd
      .f_gst_ex6_logexp_sign(f_gst_ex6_logexp_sign),		//i--frnd
      .f_gst_ex6_logexp_exp(f_gst_ex6_logexp_exp[1:11]),		//i--frnd
      .f_gst_ex6_logexp_fract(f_gst_ex6_logexp_fract[0:19]),		//i--frnd
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		//i--fdsq  --   :out std_ulogic;

      .f_dsq_ex6_divsqrt_sign(f_dsq_ex6_divsqrt_sign),		//i--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_exp(f_dsq_ex6_divsqrt_exp),		//i--fdsq  --   :out std_ulogic_vector(01 to 13);
      .f_dsq_ex6_divsqrt_fract(f_dsq_ex6_divsqrt_fract),		//i--fdsq  --   :out std_ulogic_vector(00 to 52)
      .f_dsq_ex6_divsqrt_flag_fpscr(f_dsq_ex6_divsqrt_flag_fpscr[0:10]),		//i--fdsq  --   :out std_ulogic_vector(00 to 09)

      .f_mad_ex7_uc_sign(f_mad_ex7_uc_sign),		//o--frnd
      .f_mad_ex7_uc_zero(f_mad_ex7_uc_zero),		//o--frnd
      .f_rnd_ex7_res_sign(rnd_ex7_res_sign),		//o--frnd
      .f_rnd_ex7_res_expo(rnd_ex7_res_expo[1:13]),		//o--frnd
      .f_rnd_ex7_res_frac(rnd_ex7_res_frac[0:52]),		//o--frnd
      .f_rnd_ex7_flag_up(f_rnd_ex7_flag_up),		//o--frnd
      .f_rnd_ex7_flag_fi(f_rnd_ex7_flag_fi),		//o--frnd
      .f_rnd_ex7_flag_ox(f_rnd_ex7_flag_ox),		//o--frnd
      .f_rnd_ex7_flag_den(f_rnd_ex7_flag_den),		//o--frnd
      .f_rnd_ex7_flag_sgn(f_rnd_ex7_flag_sgn),		//o--frnd
      .f_rnd_ex7_flag_inf(f_rnd_ex7_flag_inf),		//o--frnd
      .f_rnd_ex7_flag_zer(f_rnd_ex7_flag_zer),		//o--frnd
      .f_rnd_ex7_flag_ux(f_rnd_ex7_flag_ux)		//o--frnd
   );
   //----------------------------------------------------------- fu_rnd.vhdl

   assign f_rnd_ex7_res_sign = rnd_ex7_res_sign;
   assign f_rnd_ex7_res_expo[1:13] = rnd_ex7_res_expo[1:13];
   assign f_rnd_ex7_res_frac[0:52] = rnd_ex7_res_frac[0:52];

   		// fu_gst.vhdl
   fu_gst  fgst(
      //----------------------------------------------------------- fu_gst.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:5]),		//i--
      .mpw1_b(mpw1_b[2:5]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_rnd_thold_1),		//i--
      .sg_1(perv_rnd_sg_1),		//i--
      .fpu_enable(perv_rnd_fpu_enable),		//i--

      .f_gst_si(scan_in[12]),		//i--fgst
      .f_gst_so(scan_out[12]),		//o--fgst
      .ex1_act(f_dcd_ex1_act),		//i--fgst  (connect)
      .f_fmt_ex2_b_sign_gst(f_fmt_ex2_b_sign_gst),		//i--fgst
      .f_fmt_ex2_b_expo_gst_b(f_fmt_ex2_b_expo_gst_b[1:13]),		//i--fgst
      .f_fmt_ex2_b_frac_gst(f_fmt_ex2_b_frac[1:19]),		//i--fgst
      .f_pic_ex2_floges(f_pic_ex2_log2e),		//i--fgst
      .f_pic_ex2_fexptes(f_pic_ex2_pow2e),		//i--fgst
      .f_gst_ex6_logexp_v(f_gst_ex6_logexp_v),		//o--fgst
      .f_gst_ex6_logexp_sign(f_gst_ex6_logexp_sign),		//o--fgst
      .f_gst_ex6_logexp_exp(f_gst_ex6_logexp_exp[1:11]),		//o--fgst
      .f_gst_ex6_logexp_fract(f_gst_ex6_logexp_fract[0:19])		//o--fgst
   );
   //----------------------------------------------------------- fuq_gst.vhdl

   		// fu_divsqrt.vhdl
   fu_divsqrt  fdsq(
      //----------------------------------------------------------- fu_divsqrt.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1]),		//i--
      .mpw1_b(mpw1_b[1]),		//i--
      .mpw2_b(mpw2_b[0]),		//i--
      .thold_1(perv_rnd_thold_1),		//i--
      .sg_1(perv_rnd_sg_1),		//i--
      .fpu_enable(perv_rnd_fpu_enable),		//i--

      .f_dsq_si(scan_in[13]),		//i--fdsq
      .f_dsq_so(scan_out[13]),		//o--fdsq
      .ex0_act_b(tidn),		//i--fdsq  (connect)

      .f_dcd_ex0_div(f_dcd_ex0_div),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_divs(f_dcd_ex0_divs),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_sqrt(f_dcd_ex0_sqrt),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_sqrts(f_dcd_ex0_sqrts),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_record_v(f_dcd_ex0_record_v),		//i--fdsq  --  :in  std_ulogic;

      .f_dcd_ex2_divsqrt_hole_v(f_dcd_ex2_divsqrt_hole_v),		//i--fdsq
      .f_dcd_flush(f_dcd_flush),		//i--fdsq  --  :in std_ulogic;
      .f_dcd_ex1_itag(f_dcd_ex1_itag),		//i--fdsq  --  :in std_ulogic_vector(0 to 6);
      .f_dcd_ex1_fpscr_addr(f_dcd_ex1_fpscr_addr),		//i--fdsq  --  :in std_ulogic_vector(0 to 5);
      .f_dcd_ex1_instr_frt(f_dcd_ex1_instr_frt),		//i--fdsq  --  :in std_ulogic_vector(0 to 5);
      .f_dcd_ex1_instr_tid(f_dcd_ex1_instr_tid),		//i--fdsq  --  :in std_ulogic_vector(0 to 5);

      .f_dcd_ex1_divsqrt_cr_bf(f_dcd_ex1_divsqrt_cr_bf),		//i--fdsq  --  :in std_ulogic_vector(0 to 5);
      .f_dcd_axucr0_deno(f_dcd_axucr0_deno),
      .f_fmt_ex2_a_sign_div(f_fmt_ex2_a_sign_div),		//i--fdsq  --  :in std_ulogic;
      .f_fmt_ex2_a_expo_div_b(f_fmt_ex2_a_expo_div_b),		//i--fdsq  --  :in std_ulogic_vector(01 to 13);
      .f_fmt_ex2_a_frac_div(f_fmt_ex2_a_frac_div),		//i--fdsq  --  :in std_ulogic_vector(01 to 52);

      .f_fmt_ex2_b_sign_div(f_fmt_ex2_b_sign_div),		//i--fdsq  --  :in std_ulogic;
      .f_fmt_ex2_b_expo_div_b(f_fmt_ex2_b_expo_div_b),		//i--fdsq  --  :in std_ulogic_vector(01 to 13);
      .f_fmt_ex2_b_frac_div(f_fmt_ex2_b_frac_div),		//i--fdsq  --  :in std_ulogic_vector(01 to 52);
      .f_fmt_ex2_a_zero_dsq(f_fmt_ex2_a_zero_dsq),		//i--fdsq
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		//i--fdsq

      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		//i--fdsq
      .f_fmt_ex2_a_expo_max_dsq(f_fmt_ex2_a_expo_max_dsq),		//i--fdsq
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		//i--fdsq
      .f_fmt_ex2_b_zero_dsq(f_fmt_ex2_b_zero_dsq),		//i--fdsq
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		//i--fdsq

      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		//i--fdsq
      .f_fmt_ex2_b_expo_max_dsq(f_fmt_ex2_b_expo_max_dsq),		//i--fdsq
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		//i--fdsq
      .f_dsq_ex3_hangcounter_trigger(f_dsq_ex3_hangcounter_trigger_int),
      .f_dsq_ex5_divsqrt_v(f_dsq_ex5_divsqrt_v_int),		//o--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		//o--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_record_v(f_dsq_ex6_divsqrt_record_v_int),		//o--fdsq  --   :out std_ulogic;

      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_int_suppress),		//o--fdsq  --   :out std_ulogic;

      .f_dsq_ex5_divsqrt_itag(f_dsq_ex5_divsqrt_itag_int),		//i--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_fpscr_addr(f_dsq_ex6_divsqrt_fpscr_addr_int),		//i--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_instr_frt(f_dsq_ex6_divsqrt_instr_frt_int),		//i--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_instr_tid(f_dsq_ex6_divsqrt_instr_tid_int),		//i--fdsq  --   :out std_ulogic;

      .f_dsq_ex6_divsqrt_cr_bf(f_dsq_ex6_divsqrt_cr_bf_int),		//i--fdsq  --   :out std_ulogic;

      .f_scr_ex6_fpscr_rm_thr0(f_scr_ex6_fpscr_rm_thr0),		//i--fdsq
      .f_scr_ex6_fpscr_ee_thr0(f_scr_ex6_fpscr_ee_thr0),		//i--fdsq
      .f_scr_ex6_fpscr_rm_thr1(f_scr_ex6_fpscr_rm_thr1),		//i--fdsq
      .f_scr_ex6_fpscr_ee_thr1(f_scr_ex6_fpscr_ee_thr1),		//i--fdsq

      .f_dsq_ex6_divsqrt_sign(f_dsq_ex6_divsqrt_sign),		//o--fdsq  --   :out std_ulogic;
      .f_dsq_ex6_divsqrt_exp(f_dsq_ex6_divsqrt_exp),		//o--fdsq  --   :out std_ulogic_vector(01 to 13);
      .f_dsq_ex6_divsqrt_fract(f_dsq_ex6_divsqrt_fract),		//o--fdsq  --   :out std_ulogic_vector(00 to 52)
      .f_dsq_ex6_divsqrt_flag_fpscr(f_dsq_ex6_divsqrt_flag_fpscr),//o--fdsq  --   :out std_ulogic_vector(00 to 09)
      .f_dsq_debug(f_dsq_debug)
   );

   //----------------------------------------------------------- fu_divsqrt.vhdl
   assign f_dsq_ex5_divsqrt_v = f_dsq_ex5_divsqrt_v_int;
   assign f_dsq_ex6_divsqrt_v = f_dsq_ex6_divsqrt_v_int;
   assign f_dsq_ex6_divsqrt_record_v = f_dsq_ex6_divsqrt_record_v_int;
   assign f_dsq_ex6_divsqrt_v_suppress = f_dsq_ex6_divsqrt_v_int_suppress;
   assign f_dsq_ex5_divsqrt_itag = f_dsq_ex5_divsqrt_itag_int;
   assign f_dsq_ex6_divsqrt_fpscr_addr = f_dsq_ex6_divsqrt_fpscr_addr_int;
   assign f_dsq_ex6_divsqrt_instr_frt = f_dsq_ex6_divsqrt_instr_frt_int;
   assign f_dsq_ex6_divsqrt_instr_tid = f_dsq_ex6_divsqrt_instr_tid_int;
   assign f_dsq_ex3_hangcounter_trigger = f_dsq_ex3_hangcounter_trigger_int;

   assign f_dsq_ex6_divsqrt_cr_bf = f_dsq_ex6_divsqrt_cr_bf_int;

   		// fu_pic.vhdl
   fu_pic  fpic(
      //----------------------------------------------------------- fu_pic.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1:5]),		//i--
      .mpw1_b(mpw1_b[1:5]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_pic_thold_1),		//i--
      .sg_1(perv_pic_sg_1),		//i--
      .fpu_enable(perv_pic_fpu_enable),		//i--

      .f_pic_si(scan_in[14]),		//i--fpic
      .f_pic_so(scan_out[14]),		//o--fpic
      .f_dcd_ex1_act(f_dcd_ex1_act),		//i--fpic
      .f_cr2_ex2_fpscr_shadow_thr0(f_scr_fpscr_ctrl_thr0),		//i--fpic
      .f_cr2_ex2_fpscr_shadow_thr1(f_scr_fpscr_ctrl_thr1),		//i--fpic
      .f_dcd_ex1_pow2e_b(f_dcd_ex1_pow2e_b),		//i--fpic
      .f_dcd_ex1_log2e_b(f_dcd_ex1_log2e_b),		//i--fpic
      .f_byp_pic_ex2_a_sign(f_byp_pic_ex2_a_sign),		//i--fpic
      .f_byp_pic_ex2_c_sign(f_byp_pic_ex2_c_sign),		//i--fpic
      .f_byp_pic_ex2_b_sign(f_byp_pic_ex2_b_sign),		//i--fpic
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),		//i--fpic
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),		//i--fpic
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),		//i--fpic
      .f_dcd_ex1_thread(f_dcd_ex1_thread),		//i--fpic

      .f_dcd_ex1_uc_ft_neg(f_dcd_ex1_uc_ft_neg),		//i--fpic
      .f_dcd_ex1_uc_ft_pos(f_dcd_ex1_uc_ft_pos),		//i--fpic
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),		//i--fpic
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),		//i--fpic
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),		//i--fpic
      .f_dcd_ex1_rnd_to_int_b(f_dcd_ex1_rnd_to_int_b),		//i--fpic
      .f_dcd_ex1_math_b(f_dcd_ex1_math_b),		//i--fpic
      .f_dcd_ex1_est_recip_b(f_dcd_ex1_est_recip_b),		//i--fpic
      .f_dcd_ex1_ftdiv(f_dcd_ex1_ftdiv),		//i--fpic
      .f_dcd_ex1_ftsqrt(f_dcd_ex1_ftsqrt),		//i--fpic
      .f_fmt_ex3_ae_ge_54(f_fmt_ex3_ae_ge_54),		//i--fpic
      .f_fmt_ex3_be_ge_54(f_fmt_ex3_be_ge_54),		//i--fpic
      .f_fmt_ex3_be_ge_2(f_fmt_ex3_be_ge_2),		//i--fpic
      .f_fmt_ex3_be_ge_2044(f_fmt_ex3_be_ge_2044),		//i--fpic
      .f_fmt_ex3_tdiv_rng_chk(f_fmt_ex3_tdiv_rng_chk),		//i--fpic

      .f_dcd_ex1_est_rsqrt_b(f_dcd_ex1_est_rsqrt_b),		//i--fpic
      .f_dcd_ex1_move_b(f_dcd_ex1_move_b),		//i--fpic
      .f_dcd_ex1_prenorm_b(f_dcd_ex1_prenorm_b),		//i--fpic
      .f_dcd_ex1_frsp_b(f_dcd_ex1_frsp_b),		//i--fpic
      .f_dcd_ex1_sp(f_dcd_ex1_sp),		//i--fpic
      .f_dcd_ex1_sp_conv_b(f_dcd_ex1_sp_conv_b),		//i--fpic
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),		//i--fpic
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),		//i--fpic
      .f_dcd_ex1_sub_op_b(f_dcd_ex1_sub_op_b),		//i--fpic
      .f_dcd_ex1_op_rnd_v_b(f_dcd_ex1_op_rnd_v_b),		//i--fpic
      .f_dcd_ex1_op_rnd_b(f_dcd_ex1_op_rnd_b[0:1]),		//i--fpic
      .f_dcd_ex1_inv_sign_b(f_dcd_ex1_inv_sign_b),		//i--fpic
      .f_dcd_ex1_sign_ctl_b(f_dcd_ex1_sign_ctl_b[0:1]),		//i--fpic
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),		//i--fpic
      .f_dcd_ex1_nj_deno(f_dcd_ex1_nj_deno),		//i--fpic
      .f_dcd_ex1_mv_to_scr_b(f_dcd_ex1_mv_to_scr_b),		//i--fpic
      .f_dcd_ex1_mv_from_scr_b(f_dcd_ex1_mv_from_scr_b),		//i--fpic
      .f_dcd_ex1_compare_b(f_dcd_ex1_compare_b),		//i--fpic
      .f_dcd_ex1_ordered_b(f_dcd_ex1_ordered_b),		//i--fpic
      .f_alg_ex2_sign_frmw(f_alg_ex2_sign_frmw),		//i--fpic
      .f_dcd_ex1_force_excp_dis(f_dcd_ex1_force_excp_dis),		//i--fpic
      .f_pic_ex2_log2e(f_pic_ex2_log2e),		//i--fpic
      .f_pic_ex2_pow2e(f_pic_ex2_pow2e),		//i--fpic
      .f_fmt_ex2_bexpu_le126(f_fmt_ex2_bexpu_le126),		//i--fpic
      .f_fmt_ex2_gt126(f_fmt_ex2_gt126),		//i--fpic
      .f_fmt_ex2_ge128(f_fmt_ex2_ge128),		//i--fpic
      .f_fmt_ex2_inf_and_beyond_sp(f_fmt_ex2_inf_and_beyond_sp),		//i--fpic
      .f_fmt_ex2_sp_invalid(f_fmt_ex2_sp_invalid),		//i--fpic
      .f_fmt_ex2_a_zero(f_fmt_ex2_a_zero),		//i--fpic
      .f_fmt_ex2_a_expo_max(f_fmt_ex2_a_expo_max),		//i--fpic
      .f_fmt_ex2_a_frac_zero(f_fmt_ex2_a_frac_zero),		//i--fpic
      .f_fmt_ex2_a_frac_msb(f_fmt_ex2_a_frac_msb),		//i--fpic
      .f_fmt_ex2_c_zero(f_fmt_ex2_c_zero),		//i--fpic
      .f_fmt_ex2_c_expo_max(f_fmt_ex2_c_expo_max),		//i--fpic
      .f_fmt_ex2_c_frac_zero(f_fmt_ex2_c_frac_zero),		//i--fpic
      .f_fmt_ex2_c_frac_msb(f_fmt_ex2_c_frac_msb),		//i--fpic
      .f_fmt_ex2_b_zero(f_fmt_ex2_b_zero),		//i--fpic
      .f_fmt_ex2_b_expo_max(f_fmt_ex2_b_expo_max),		//i--fpic
      .f_fmt_ex2_b_frac_zero(f_fmt_ex2_b_frac_zero),		//i--fpic
      .f_fmt_ex2_b_frac_msb(f_fmt_ex2_b_frac_msb),		//i--fpic
      .f_fmt_ex2_prod_zero(f_fmt_ex2_prod_zero),		//i--fpic
      .f_fmt_ex3_pass_sign(f_fmt_ex3_pass_sign),		//i--fpic
      .f_fmt_ex3_pass_msb(f_fmt_ex3_pass_msb),		//i--fpic
      .f_fmt_ex2_b_frac_z32(f_fmt_ex2_b_frac_z32),		//i--fpic
      .f_fmt_ex2_b_imp(f_fmt_ex2_b_imp),		//i--fpic
      .f_eie_ex3_wd_ov(f_eie_ex3_wd_ov),		//i--fpic
      .f_eie_ex3_dw_ov(f_eie_ex3_dw_ov),		//i--fpic
      .f_eie_ex3_wd_ov_if(f_eie_ex3_wd_ov_if),		//i--fpic
      .f_eie_ex3_dw_ov_if(f_eie_ex3_dw_ov_if),		//i--fpic
      .f_eie_ex3_lt_bias(f_eie_ex3_lt_bias),		//i--fpic
      .f_eie_ex3_eq_bias_m1(f_eie_ex3_eq_bias_m1),		//i--fpic
      .f_alg_ex3_sel_byp(f_alg_ex3_sel_byp),		//i--fpic
      .f_alg_ex3_effsub_eac_b(f_alg_ex3_effsub_eac_b),		//i--fpic
      .f_alg_ex3_sh_unf(f_alg_ex3_sh_unf),		//i--fpic
      .f_alg_ex3_sh_ovf(f_alg_ex3_sh_ovf),		//i--fpic
      .f_alg_ex4_int_fr(f_alg_ex4_int_fr),		//i--fpic
      .f_alg_ex4_int_fi(f_alg_ex4_int_fi),		//i--fpic
      .f_eov_ex5_may_ovf(f_eov_ex5_may_ovf),		//i--fpic
      .f_add_ex5_fpcc_iu({f_add_ex5_flag_lt, f_add_ex5_flag_gt, f_add_ex5_flag_eq, f_add_ex5_flag_nan}),		//o--fadd
      .f_add_ex5_sign_carry(f_add_ex5_sign_carry),		//i--fpic
      .f_dcd_ex1_div_beg(tidn),		//i--fpic
      .f_dcd_ex1_sqrt_beg(tidn),		//i--fpic
      .f_pic_ex6_fpr_wr_dis_b(f_pic_ex6_fpr_wr_dis_b),		//o--fpic
      .f_add_ex5_to_int_ovf_wd(f_add_ex5_to_int_ovf_wd[0:1]),		//i--fpic
      .f_add_ex5_to_int_ovf_dw(f_add_ex5_to_int_ovf_dw[0:1]),		//i--fpic
      .f_pic_ex2_flush_en_sp(f_pic_ex2_flush_en_sp),		//o--fpic
      .f_pic_ex2_flush_en_dp(f_pic_ex2_flush_en_dp),		//o--fpic
      .f_pic_ex2_rnd_to_int(f_pic_ex2_rnd_to_int),		//o--fpic


      .f_fmt_ex3_be_den (f_fmt_ex3_be_den) ,	//i--ffmt
      .f_pic_fmt_ex2_act(f_pic_fmt_ex2_act),	//o--fpic
      .f_pic_eie_ex2_act(f_pic_eie_ex2_act),	//o--fpic
      .f_pic_mul_ex2_act(f_pic_mul_ex2_act),	//o--fpic
      .f_pic_alg_ex2_act(f_pic_alg_ex2_act),	//o--fpic
      .f_pic_cr2_ex2_act(f_pic_cr2_ex2_act),	//o--fpic
      .f_pic_tbl_ex2_act(f_pic_tbl_ex2_act),	//o--fpic
      .f_pic_ex2_ftdiv  (f_pic_ex2_ftdiv  ),	//o--fpic to fmt


      .f_pic_add_ex2_act_b(f_pic_add_ex2_act_b),		//o--fpic
      .f_pic_lza_ex2_act_b(f_pic_lza_ex2_act_b),		//o--fpic
      .f_pic_eov_ex3_act_b(f_pic_eov_ex3_act_b),		//o--fpic
      .f_pic_nrm_ex4_act_b(f_pic_nrm_ex4_act_b),		//o--fpic
      .f_pic_rnd_ex4_act_b(f_pic_rnd_ex4_act_b),		//o--fpic
      .f_pic_scr_ex3_act_b(f_pic_scr_ex3_act_b),		//o--fpic
      .f_pic_ex2_effsub_raw(f_pic_ex2_effsub_raw),		//o--fpic
      .f_pic_ex4_sel_est(f_pic_ex4_sel_est),		//o--fpic
      .f_pic_ex2_from_integer(f_pic_ex2_from_integer),		//o--fpic
      .f_pic_ex3_ue1(f_pic_ex3_ue1),		//o--fpic
      .f_pic_ex3_frsp_ue1(f_pic_ex3_frsp_ue1),		//o--fpic
      .f_pic_ex2_frsp_ue1(f_pic_ex2_frsp_ue1),		//o--fpic --wrong cycle (temporary)
      .f_pic_ex2_fsel(f_pic_ex2_fsel),		//o--fpic
      .f_pic_ex2_sh_ovf_do(f_pic_ex2_sh_ovf_do),		//o--fpic
      .f_pic_ex2_sh_ovf_ig_b(f_pic_ex2_sh_ovf_ig_b),		//o--fpic
      .f_pic_ex2_sh_unf_do(f_pic_ex2_sh_unf_do),		//o--fpic
      .f_pic_ex2_sh_unf_ig_b(f_pic_ex2_sh_unf_ig_b),		//o--fpic
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		//o--fpic
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		//o--fpic
      .f_pic_ex3_force_sel_bexp(f_pic_ex3_force_sel_bexp),		//o--fpic
      .f_pic_ex3_lzo_dis_prod(f_pic_ex3_lzo_dis_prod),		//o--fpic
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		//o--fpic
      .f_pic_ex3_sp_lzo(f_pic_ex3_sp_lzo),		//o--fpic
      .f_pic_ex3_to_integer(f_pic_ex3_to_integer),		//o--fpic
      .f_pic_ex3_prenorm(f_pic_ex3_prenorm),		//o--fpic
      .f_pic_ex3_b_valid(f_pic_ex3_b_valid),		//i--fpic
      .f_pic_ex3_rnd_nr(f_pic_ex3_rnd_nr),		//i--falg
      .f_pic_ex3_rnd_inf_ok(f_pic_ex3_rnd_inf_ok),		//i--falg
      .f_pic_ex3_math_bzer_b(f_pic_ex3_math_bzer_b),		//o--fpic
      .f_pic_ex4_cmp_sgnneg(f_pic_ex4_cmp_sgnneg),		//o--fpic
      .f_pic_ex4_cmp_sgnpos(f_pic_ex4_cmp_sgnpos),		//o--fpic
      .f_pic_ex4_is_eq(f_pic_ex4_is_eq),		//o--fpic
      .f_pic_ex4_is_gt(f_pic_ex4_is_gt),		//o--fpic
      .f_pic_ex4_is_lt(f_pic_ex4_is_lt),		//o--fpic
      .f_pic_ex4_is_nan(f_pic_ex4_is_nan),		//o--fpic
      .f_pic_ex4_sp_b(f_pic_ex4_sp_b),		//o--fpic
      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),		//i--fpic
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),		//i--fpic
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),		//i--fpic
      .f_mad_ex3_uc_a_expo_den_sp(f_mad_ex3_uc_a_expo_den_sp),		//i--fpic
      .f_mad_ex3_uc_a_expo_den(f_mad_ex3_uc_a_expo_den),		//i--fpic
      .f_dcd_ex3_uc_zx(f_dcd_ex3_uc_zx),		//i--fpic
      .f_dcd_ex3_uc_vxidi(f_dcd_ex3_uc_vxidi),		//i--fpic
      .f_dcd_ex3_uc_vxzdz(f_dcd_ex3_uc_vxzdz),		//i--fpic
      .f_dcd_ex3_uc_vxsqrt(f_dcd_ex3_uc_vxsqrt),		//i--fpic
      .f_dcd_ex3_uc_vxsnan(f_dcd_ex3_uc_vxsnan),		//i--fpic
      .f_mad_ex4_uc_special(f_mad_ex4_uc_special),		//o--fpic
      .f_mad_ex4_uc_zx(f_mad_ex4_uc_zx),		//o--fpic
      .f_mad_ex4_uc_vxidi(f_mad_ex4_uc_vxidi),		//o--fpic
      .f_mad_ex4_uc_vxzdz(f_mad_ex4_uc_vxzdz),		//o--fpic
      .f_mad_ex4_uc_vxsqrt(f_mad_ex4_uc_vxsqrt),		//o--fpic
      .f_mad_ex4_uc_vxsnan(f_mad_ex4_uc_vxsnan),		//o--fpic
      .f_mad_ex4_uc_res_sign(f_mad_ex4_uc_res_sign),		//o--fpic
      .f_mad_ex4_uc_round_mode(f_mad_ex4_uc_round_mode[0:1]),		//o--fpic
      .f_pic_ex5_byp_prod_nz(f_pic_ex5_byp_prod_nz),		//o--fpic
      .f_pic_ex5_sel_est_b(f_pic_ex5_sel_est_b),		//o--fpic
      .f_pic_ex5_nj_deno(f_pic_ex5_nj_deno),		//o--fpic
      .f_pic_ex5_oe(f_pic_ex5_oe),		//o--fpic
      .f_pic_ex5_ov_en(f_pic_ex5_ov_en),		//o--fpic
      .f_pic_ex5_ovf_en_oe0_b(f_pic_ex5_ovf_en_oe0_b),		//o--fpic
      .f_pic_ex5_ovf_en_oe1_b(f_pic_ex5_ovf_en_oe1_b),		//o--fpic
      .f_pic_ex5_quiet_b(f_pic_ex5_quiet_b),		//o--fpic
      .f_pic_ex5_rnd_inf_ok_b(f_pic_ex5_rnd_inf_ok_b),		//o--fpic
      .f_pic_ex5_rnd_ni_b(f_pic_ex5_rnd_ni_b),		//o--fpic
      .f_pic_ex5_rnd_nr_b(f_pic_ex5_rnd_nr_b),		//o--fpic
      .f_pic_ex5_sel_fpscr_b(f_pic_ex5_sel_fpscr_b),		//o--fpic
      .f_pic_ex5_sp_b(f_pic_ex5_sp_b),		//o--fpic
      .f_pic_ex5_spec_inf_b(f_pic_ex5_spec_inf_b),		//o--fpic
      .f_pic_ex5_spec_sel_k_e(f_pic_ex5_spec_sel_k_e),		//o--fpic
      .f_pic_ex5_spec_sel_k_f(f_pic_ex5_spec_sel_k_f),		//o--fpic
      .f_dcd_ex3_uc_inc_lsb(f_dcd_ex3_uc_inc_lsb),		//i--fpic
      .f_dcd_ex3_uc_guard(f_dcd_ex3_uc_gs[0]),		//i--fpic
      .f_dcd_ex3_uc_sticky(f_dcd_ex3_uc_gs[1]),		//i--fpic
      .f_dcd_ex3_uc_gs_v(f_dcd_ex3_uc_gs_v),		//i--fpic
      .f_pic_ex6_uc_inc_lsb(f_pic_ex6_uc_inc_lsb),		//o--fpic
      .f_pic_ex6_uc_guard(f_pic_ex6_uc_guard),		//o--fpic
      .f_pic_ex6_uc_sticky(f_pic_ex6_uc_sticky),		//o--fpic
      .f_pic_ex6_uc_g_v(f_pic_ex6_uc_g_v),		//o--fpic
      .f_pic_ex6_uc_s_v(f_pic_ex6_uc_s_v),		//o--fpic
      .f_pic_ex5_to_int_ov_all(f_pic_ex5_to_int_ov_all),		//o--fpic
      .f_pic_ex5_to_integer_b(f_pic_ex5_to_integer_b),		//o--fpic
      .f_pic_ex5_word_b(f_pic_ex5_word_b),		//o--fpic
      .f_pic_ex5_uns_b(f_pic_ex5_uns_b),		//o--fpic
      .f_pic_ex5_ue(f_pic_ex5_ue),		//o--fpic
      .f_pic_ex5_uf_en(f_pic_ex5_uf_en),		//o--fpic
      .f_pic_ex5_unf_en_ue0_b(f_pic_ex5_unf_en_ue0_b),		//o--fpic
      .f_pic_ex5_unf_en_ue1_b(f_pic_ex5_unf_en_ue1_b),		//o--fpic
      .f_pic_ex6_en_exact_zero(f_pic_ex6_en_exact_zero),		//o--fpic
      .f_pic_ex6_compare_b(f_pic_ex6_compare_b),		//o--fpic
      .f_pic_ex6_frsp(f_pic_ex6_frsp),		//o--fpic
      .f_pic_ex6_fi_pipe_v_b(f_pic_ex6_fi_pipe_v_b),		//o--fpic
      .f_pic_ex6_fi_spec_b(f_pic_ex6_fi_spec_b),		//o--fpic
      .f_pic_ex6_flag_vxcvi_b(f_pic_ex6_flag_vxcvi_b),		//o--fpic
      .f_pic_ex6_flag_vxidi_b(f_pic_ex6_flag_vxidi_b),		//o--fpic
      .f_pic_ex6_flag_vximz_b(f_pic_ex6_flag_vximz_b),		//o--fpic
      .f_pic_ex6_flag_vxisi_b(f_pic_ex6_flag_vxisi_b),		//o--fpic
      .f_pic_ex6_flag_vxsnan_b(f_pic_ex6_flag_vxsnan_b),		//o--fpic
      .f_pic_ex6_flag_vxsqrt_b(f_pic_ex6_flag_vxsqrt_b),		//o--fpic
      .f_pic_ex6_flag_vxvc_b(f_pic_ex6_flag_vxvc_b),		//o--fpic
      .f_pic_ex6_flag_vxzdz_b(f_pic_ex6_flag_vxzdz_b),		//o--fpic
      .f_pic_ex6_flag_zx_b(f_pic_ex6_flag_zx_b),		//o--fpic
      .f_pic_ex6_fprf_hold_b(f_pic_ex6_fprf_hold_b),		//o--fpic
      .f_pic_ex6_fprf_pipe_v_b(f_pic_ex6_fprf_pipe_v_b),		//o--fpic
      .f_pic_ex6_fprf_spec_b(f_pic_ex6_fprf_spec_b[0:4]),		//o--fpic
      .f_pic_ex6_fr_pipe_v_b(f_pic_ex6_fr_pipe_v_b),		//o--fpic
      .f_pic_ex6_fr_spec_b(f_pic_ex6_fr_spec_b),		//o--fpic
      .f_pic_ex6_invert_sign(f_pic_ex6_invert_sign),		//o--fpic
      .f_pic_ex6_k_nan(f_pic_ex6_k_nan),		//o--fpic
      .f_pic_ex6_k_inf(f_pic_ex6_k_inf),		//o--fpic
      .f_pic_ex6_k_max(f_pic_ex6_k_max),		//o--fpic
      .f_pic_ex6_k_zer(f_pic_ex6_k_zer),		//o--fpic
      .f_pic_ex6_k_one(f_pic_ex6_k_one),		//o--fpic
      .f_pic_ex6_k_int_maxpos(f_pic_ex6_k_int_maxpos),		//o--fpic
      .f_pic_ex6_k_int_maxneg(f_pic_ex6_k_int_maxneg),		//o--fpic
      .f_pic_ex6_k_int_zer(f_pic_ex6_k_int_zer),		//o--fpic
      .f_pic_ex6_ox_pipe_v_b(f_pic_ex6_ox_pipe_v_b),		//o--fpic
      .f_pic_ex6_round_sign(f_pic_ex6_round_sign),		//o--fpic
      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b_int),		//o--fpic
      .f_pic_ex6_scr_upd_pipe_b(f_pic_ex6_scr_upd_pipe_b),		//o--fpic
      .f_pic_ex2_nj_deni(f_pic_ex2_nj_deni),		//o--fpic
      .f_dcd_ex1_nj_deni(f_dcd_ex1_nj_deni),		//i--fpic
      .f_pic_ex6_ux_pipe_v_b(f_pic_ex6_ux_pipe_v_b)		//o--fpic
   );
   //----------------------------------------------------------- fu_pic.vhdl

   assign f_pic_ex6_scr_upd_move_b = f_pic_ex6_scr_upd_move_b_int;

   		// fu_cr2.vhdl
   fu_cr2  fcr2(
      //----------------------------------------------------------- fu_cr2.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[1:7]),		//i--
      .mpw1_b(mpw1_b[1:7]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_cr2_thold_1),		//i--
      .sg_1(perv_cr2_sg_1),		//i--
      .fpu_enable(perv_cr2_fpu_enable),		//i--

      .f_cr2_si(scan_in[15]),		//i--fcr2
      .f_cr2_so(scan_out[15]),		//o--fcr2
      .ex1_act(f_dcd_ex1_act),		//i--fcr2
      .ex2_act(f_pic_cr2_ex2_act),		//i--fcr2
      .ex1_thread_b(ex1_thread_b[0:3]),		//i--fcr2
      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),		//i--fcr2
      .f_fmt_ex2_bop_byt(f_fmt_ex2_bop_byt[45:52]),		//i--fcr2 for mtfsf to shadow reg
      .f_dcd_ex1_fpscr_bit_data_b(f_dcd_ex1_fpscr_bit_data_b[0:3]),		//i--fcr2 data to write to nibble (other than mtfsf)
      .f_dcd_ex1_fpscr_bit_mask_b(f_dcd_ex1_fpscr_bit_mask_b[0:3]),		//i--fcr2 enable update of bit within the nibble
      .f_dcd_ex1_fpscr_nib_mask_b(f_dcd_ex1_fpscr_nib_mask_b[0:8]),		//i--fcr2 enable update of this nibble
      .f_dcd_ex1_mtfsbx_b(f_dcd_ex1_mtfsbx_b),		//i--fcr2 fpscr set bit, reset bit
      .f_dcd_ex1_mcrfs_b(f_dcd_ex1_mcrfs_b),		//i--fcr2 move fpscr field to cr and reset exceptions
      .f_dcd_ex1_mtfsf_b(f_dcd_ex1_mtfsf_b),		//i--fcr2 move fpr data to fpscr
      .f_dcd_ex1_mtfsfi_b(f_dcd_ex1_mtfsfi_b),		//i--fcr2 move immediate data to fpscr
      .f_cr2_ex4_thread_b(f_cr2_ex4_thread_b[0:3]),		//o--fcr2
      .f_cr2_ex4_fpscr_bit_data_b(f_cr2_ex4_fpscr_bit_data_b[0:3]),		//o--fcr2 data to write to nibble (other than mtfsf)
      .f_cr2_ex4_fpscr_bit_mask_b(f_cr2_ex4_fpscr_bit_mask_b[0:3]),		//o--fcr2 enable update of bit within the nibble
      .f_cr2_ex4_fpscr_nib_mask_b(f_cr2_ex4_fpscr_nib_mask_b[0:8]),		//o--fcr2 enable update of this nibble
      .f_cr2_ex4_mtfsbx_b(f_cr2_ex4_mtfsbx_b),		//o--fcr2 fpscr set bit, reset bit
      .f_cr2_ex4_mcrfs_b(f_cr2_ex4_mcrfs_b),		//o--fcr2 move fpscr field to cr and reset exceptions
      .f_cr2_ex4_mtfsf_b(f_cr2_ex4_mtfsf_b),		//o--fcr2 move fpr data to fpscr
      .f_cr2_ex4_mtfsfi_b(f_cr2_ex4_mtfsfi_b),		//o--fcr2 move immediate data to fpscr
      .f_cr2_ex6_fpscr_rd_dat(f_cr2_ex6_fpscr_rd_dat[24:31]),		//o--fcr2
      .f_cr2_ex7_fpscr_rd_dat(f_cr2_ex7_fpscr_rd_dat[24:31])		//o--fcr2
   );
   //f_cr2_ex1_fpscr_shadow(0 to 7)                   => f_cr2_ex1_fpscr_shadow(0 to 7)        );--o--fcr2
   //----------------------------------------------------------- fu_cr2.vhdl

   assign f_cr2_ex2_fpscr_shadow[0:7] = f_scr_ex6_fpscr_rd_dat[24:31];		// no forwarding


   fu_oscr #( .THREADS(THREADS)) fscr(
      //----------------------------------------------------------- fuq_scr.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[4:7]),		//i--
      .mpw1_b(mpw1_b[4:7]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_scr_thold_1),		//i--
      .sg_1(perv_scr_sg_1),		//i--
      .fpu_enable(perv_scr_fpu_enable),		//i--

      .f_scr_si(scan_in[16]),		//i--fscr
      .f_scr_so(scan_out[16]),		//o--fscr
      .ex3_act_b(f_pic_scr_ex3_act_b),		//i--fscr
      .f_cr2_ex4_thread_b(f_cr2_ex4_thread_b[0:3]),		//i--fscr

      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),		//i--fcr2

      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b_int),		//i--fscr
      .f_pic_ex6_scr_upd_pipe_b(f_pic_ex6_scr_upd_pipe_b),		//i--fscr
      .f_pic_ex6_fprf_spec_b(f_pic_ex6_fprf_spec_b[0:4]),		//i--fscr
      .f_pic_ex6_compare_b(f_pic_ex6_compare_b),		//i--fscr
      .f_pic_ex6_fprf_pipe_v_b(f_pic_ex6_fprf_pipe_v_b),		//i--fscr
      .f_pic_ex6_fprf_hold_b(f_pic_ex6_fprf_hold_b),		//i--fscr
      .f_pic_ex6_fi_spec_b(f_pic_ex6_fi_spec_b),		//i--fscr
      .f_pic_ex6_fi_pipe_v_b(f_pic_ex6_fi_pipe_v_b),		//i--fscr
      .f_pic_ex6_fr_spec_b(f_pic_ex6_fr_spec_b),		//i--fscr
      .f_pic_ex6_fr_pipe_v_b(f_pic_ex6_fr_pipe_v_b),		//i--fscr
      .f_pic_ex6_ox_spec_b(tiup),		//i--fscr
      .f_pic_ex6_ox_pipe_v_b(f_pic_ex6_ox_pipe_v_b),		//i--fscr
      .f_pic_ex6_ux_spec_b(tiup),		//i--fscr
      .f_pic_ex6_ux_pipe_v_b(f_pic_ex6_ux_pipe_v_b),		//i--fscr
      .f_pic_ex6_flag_vxsnan_b(f_pic_ex6_flag_vxsnan_b),		//i--fscr
      .f_pic_ex6_flag_vxisi_b(f_pic_ex6_flag_vxisi_b),		//i--fscr
      .f_pic_ex6_flag_vxidi_b(f_pic_ex6_flag_vxidi_b),		//i--fscr
      .f_pic_ex6_flag_vxzdz_b(f_pic_ex6_flag_vxzdz_b),		//i--fscr
      .f_pic_ex6_flag_vximz_b(f_pic_ex6_flag_vximz_b),		//i--fscr
      .f_pic_ex6_flag_vxvc_b(f_pic_ex6_flag_vxvc_b),		//i--fscr
      .f_pic_ex6_flag_vxsqrt_b(f_pic_ex6_flag_vxsqrt_b),		//i--fscr
      .f_pic_ex6_flag_vxcvi_b(f_pic_ex6_flag_vxcvi_b),		//i--fscr
      .f_pic_ex6_flag_zx_b(f_pic_ex6_flag_zx_b),		//i--fscr
      .f_nrm_ex6_fpscr_wr_dat_dfp(f_nrm_ex6_fpscr_wr_dat_dfp[0:3]),		//i--fscr
      .f_nrm_ex6_fpscr_wr_dat(f_nrm_ex6_fpscr_wr_dat[0:31]),		//i--fscr
      .f_cr2_ex4_fpscr_bit_data_b(f_cr2_ex4_fpscr_bit_data_b[0:3]),		//o--fscr data to write to nibble (other than mtfsf)
      .f_cr2_ex4_fpscr_bit_mask_b(f_cr2_ex4_fpscr_bit_mask_b[0:3]),		//o--fscr enable update of bit within the nibble
      .f_cr2_ex4_fpscr_nib_mask_b(f_cr2_ex4_fpscr_nib_mask_b[0:8]),		//o--fscr enable update of this nibble
      .f_cr2_ex4_mtfsbx_b(f_cr2_ex4_mtfsbx_b),		//o--fscr fpscr set bit, reset bit
      .f_cr2_ex4_mcrfs_b(f_cr2_ex4_mcrfs_b),		//o--fscr move fpscr field to cr and reset exceptions
      .f_cr2_ex4_mtfsf_b(f_cr2_ex4_mtfsf_b),		//o--fscr move fpr data to fpscr
      .f_cr2_ex4_mtfsfi_b(f_cr2_ex4_mtfsfi_b),		//o--fscr move immediate data to fpscr
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v_int),		//i--fdsq  --   :in std_ulogic;
      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_int_suppress),		//i--fdsq  --   :in std_ulogic;

      .f_dsq_ex6_divsqrt_flag_fpscr_zx(f_dsq_ex6_divsqrt_flag_fpscr[2]),		//i--fdsq
      .f_dsq_ex6_divsqrt_flag_fpscr_idi(f_dsq_ex6_divsqrt_flag_fpscr[11]),		//i--fdsq
      .f_dsq_ex6_divsqrt_flag_fpscr_zdz(f_dsq_ex6_divsqrt_flag_fpscr[12]),		//i--fdsq
      .f_dsq_ex6_divsqrt_flag_fpscr_sqrt(f_dsq_ex6_divsqrt_flag_fpscr[13]),		//i--fdsq
      .f_dsq_ex6_divsqrt_flag_fpscr_nan(f_dsq_ex6_divsqrt_flag_fpscr[14]),		//i--fdsq
      .f_dsq_ex6_divsqrt_flag_fpscr_snan(f_dsq_ex6_divsqrt_flag_fpscr[15]),		//i--fdsq

      .f_rnd_ex7_flag_up(f_rnd_ex7_flag_up),		//i--fscr
      .f_rnd_ex7_flag_fi(f_rnd_ex7_flag_fi),		//i--fscr
      .f_rnd_ex7_flag_ox(f_rnd_ex7_flag_ox),		//i--fscr
      .f_rnd_ex7_flag_den(f_rnd_ex7_flag_den),		//i--fscr
      .f_rnd_ex7_flag_sgn(f_rnd_ex7_flag_sgn),		//i--fscr
      .f_rnd_ex7_flag_inf(f_rnd_ex7_flag_inf),		//i--fscr
      .f_rnd_ex7_flag_zer(f_rnd_ex7_flag_zer),		//i--fscr
      .f_rnd_ex7_flag_ux(f_rnd_ex7_flag_ux),		//i--fscr
      .f_cr2_ex7_fpscr_rd_dat(f_cr2_ex7_fpscr_rd_dat[24:31]),		//i--fscr
      .f_cr2_ex6_fpscr_rd_dat(f_cr2_ex6_fpscr_rd_dat[24:31]),		//i--fscr
      .f_dcd_ex7_fpscr_wr(f_dcd_ex7_fpscr_wr),		//i--fscr
      .f_dcd_ex7_fpscr_addr(f_dcd_ex7_fpscr_addr),		//i--fscr
      .cp_axu_i0_t1_v(cp_axu_i0_t1_v),
      .cp_axu_i0_t0_t1_t(cp_axu_i0_t0_t1_t),
      .cp_axu_i0_t1_t1_t(cp_axu_i0_t1_t1_t),
      .cp_axu_i0_t0_t1_p(cp_axu_i0_t0_t1_p),
      .cp_axu_i0_t1_t1_p(cp_axu_i0_t1_t1_p),
								     //
      .cp_axu_i1_t1_v(cp_axu_i1_t1_v),
      .cp_axu_i1_t0_t1_t(cp_axu_i1_t0_t1_t),
      .cp_axu_i1_t1_t1_t(cp_axu_i1_t1_t1_t),
      .cp_axu_i1_t0_t1_p(cp_axu_i1_t0_t1_p),
      .cp_axu_i1_t1_t1_p(cp_axu_i1_t1_t1_p),

      .f_scr_ex6_fpscr_rd_dat(f_scr_ex6_fpscr_rd_dat[0:31]),		//o--fscr
      .f_scr_fpscr_ctrl_thr0(f_scr_fpscr_ctrl_thr0),
      .f_scr_fpscr_ctrl_thr1(f_scr_fpscr_ctrl_thr1),
      .f_scr_ex6_fpscr_rd_dat_dfp(f_scr_ex6_fpscr_rd_dat_dfp[0:3]),		//o--fscr
      .f_scr_ex6_fpscr_rm_thr0(f_scr_ex6_fpscr_rm_thr0),		//o--fscr
      .f_scr_ex6_fpscr_ee_thr0(f_scr_ex6_fpscr_ee_thr0),		//o--fscr
      .f_scr_ex6_fpscr_ni_thr0(f_scr_ex6_fpscr_ni_thr0_int),		//o--fscr

      .f_scr_ex6_fpscr_rm_thr1(f_scr_ex6_fpscr_rm_thr1),		//o--fscr
      .f_scr_ex6_fpscr_ee_thr1(f_scr_ex6_fpscr_ee_thr1),		//o--fscr
      .f_scr_ex6_fpscr_ni_thr1(f_scr_ex6_fpscr_ni_thr1_int),		//o--fscr

      .f_scr_ex8_cr_fld(f_scr_ex8_cr_fld[0:3]),		//o--fscr
      .f_scr_ex8_fx_thread0(f_scr_ex8_fx_thread0[0:3]),		//o--fscr --UNUSED ??
      .f_scr_ex8_fx_thread1(f_scr_ex8_fx_thread1[0:3]),		//o--fscr --UNUSED ??
      .f_scr_cpl_fx_thread0(f_scr_cpl_fx_thread0[0:3]),		//o--fscr --UNUSED ??
      .f_scr_cpl_fx_thread1(f_scr_cpl_fx_thread1[0:3])		//o--fscr --UNUSED ??
   );
   //----------------------------------------------------------- fuq_scr.vhdl

   assign f_scr_ex6_fpscr_ni_thr0 = f_scr_ex6_fpscr_ni_thr0_int;
   assign f_scr_ex6_fpscr_ni_thr1 = f_scr_ex6_fpscr_ni_thr1_int;


   		// exponent for table lookups
   fu_tblexp  ftbe(
      //----------------------------------------------------------- fuq_tblexp.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:3]),		//i--
      .mpw1_b(mpw1_b[2:3]),		//i--
      .mpw2_b(mpw2_b[0:0]),		//i--
      .thold_1(perv_tbe_thold_1),		//i--
      .sg_1(perv_tbe_sg_1),		//i--
      .fpu_enable(perv_tbe_fpu_enable),		//i--

      .si(scan_in[17]),		//i--ftbe
      .so(scan_out[17]),		//o--ftbe
      .ex2_act_b(f_pic_lza_ex2_act_b),		//i--ftbe
      .f_pic_ex3_ue1(f_pic_ex3_ue1),		//i--ftbe
      .f_pic_ex3_sp_b(f_pic_ex3_sp_b),		//i--ftbe
      .f_pic_ex3_est_recip(f_pic_ex3_est_recip),		//i--ftbe
      .f_pic_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		//i--ftbe
      .f_eie_ex3_tbl_expo(f_eie_ex3_tbl_expo[1:13]),		//i--ftbe
      .f_fmt_ex3_lu_den_recip(f_fmt_ex3_lu_den_recip),		//i--ftbe
      .f_fmt_ex3_lu_den_rsqrto(f_fmt_ex3_lu_den_rsqrto),		//i--ftbe
      .f_tbe_ex4_match_en_sp(f_tbe_ex4_match_en_sp),		//o--ftbe
      .f_tbe_ex4_match_en_dp(f_tbe_ex4_match_en_dp),		//o--ftbe
      .f_tbe_ex4_recip_2046(f_tbe_ex4_recip_2046),		//o--ftbe
      .f_tbe_ex4_recip_2045(f_tbe_ex4_recip_2045),		//o--ftbe
      .f_tbe_ex4_recip_2044(f_tbe_ex4_recip_2044),		//o--ftbe
      .f_tbe_ex4_lu_sh(f_tbe_ex4_lu_sh),		//o--ftbe
      .f_tbe_ex4_recip_ue1(f_tbe_ex4_recip_ue1),		//o--ftbe
      .f_tbe_ex4_may_ov(f_tbe_ex4_may_ov),		//o--ftbe
      .f_tbe_ex4_res_expo(f_tbe_ex4_res_expo[1:13])		//o--ftbe
   );


   fu_tbllut  ftbl(
      //----------------------------------------------------------- fuq_tbllut.vhdl
      .vdd(vdd),		//i--
      .gnd(gnd),		//i--
      .nclk(nclk),		//i--
      .clkoff_b(clkoff_b),		//i--
      .act_dis(act_dis),		//i--
      .flush(flush),		//i--
      .delay_lclkr(delay_lclkr[2:5]),		//i--
      .mpw1_b(mpw1_b[2:5]),		//i--
      .mpw2_b(mpw2_b[0:1]),		//i--
      .thold_1(perv_tbl_thold_1),		//i--
      .sg_1(perv_tbl_sg_1),		//i--
      .fpu_enable(perv_tbl_fpu_enable),		//i--

      .si(scan_in[18]),		//i--ftbl
      .so(scan_out[18]),		//o--ftbl
      .ex2_act(f_pic_tbl_ex2_act),		//i--ftbl
      .f_fmt_ex2_b_frac(f_fmt_ex2_b_frac[1:6]),		//i--ftbl
      .f_fmt_ex3_b_frac(f_fmt_ex3_pass_frac[7:22]),		//i--ftbl
      .f_tbe_ex3_expo_lsb(f_eie_ex3_tbl_expo[13]),		//i--ftbl
      .f_tbe_ex3_est_recip(f_pic_ex3_est_recip),		//i--ftbl
      .f_tbe_ex3_est_rsqrt(f_pic_ex3_est_rsqrt),		//i--ftbl
      .f_tbe_ex4_recip_ue1(f_tbe_ex4_recip_ue1),		//i--ftbl
      .f_tbe_ex4_lu_sh(f_tbe_ex4_lu_sh),		//i--ftbl
      .f_tbe_ex4_match_en_sp(f_tbe_ex4_match_en_sp),		//i--ftbl
      .f_tbe_ex4_match_en_dp(f_tbe_ex4_match_en_dp),		//i--ftbl
      .f_tbe_ex4_recip_2046(f_tbe_ex4_recip_2046),		//i--ftbl
      .f_tbe_ex4_recip_2045(f_tbe_ex4_recip_2045),		//i--ftbl
      .f_tbe_ex4_recip_2044(f_tbe_ex4_recip_2044),		//i--ftbl
      .f_tbl_ex6_est_frac(f_tbl_ex6_est_frac[0:26]),		//o--ftbl
      .f_tbl_ex5_unf_expo(f_tbl_ex5_unf_expo),		//o--ftbl
      .f_tbl_ex6_recip_den(f_tbl_ex6_recip_den)		//o--ftbl
   );
   //----------------------------------------------------------- fuq_tbllut.vhdl

   //-------------------------------------------
   // pervasive
   //-------------------------------------------

   assign perv_tbl_sg_1 = sg_1;
   assign perv_tbe_sg_1 = sg_1;
   assign perv_eie_sg_1 = sg_1;
   assign perv_eov_sg_1 = sg_1;
   assign perv_fmt_sg_1 = sg_1;
   assign perv_mul_sg_1 = sg_1;
   assign perv_alg_sg_1 = sg_1;
   assign perv_sa3_sg_1 = sg_1;
   assign perv_add_sg_1 = sg_1;
   assign perv_lza_sg_1 = sg_1;
   assign perv_nrm_sg_1 = sg_1;
   assign perv_rnd_sg_1 = sg_1;
   assign perv_scr_sg_1 = sg_1;
   assign perv_pic_sg_1 = sg_1;
   assign perv_cr2_sg_1 = sg_1;

   assign perv_tbl_thold_1 = thold_1;
   assign perv_tbe_thold_1 = thold_1;
   assign perv_eie_thold_1 = thold_1;
   assign perv_eov_thold_1 = thold_1;
   assign perv_fmt_thold_1 = thold_1;
   assign perv_mul_thold_1 = thold_1;
   assign perv_alg_thold_1 = thold_1;
   assign perv_sa3_thold_1 = thold_1;
   assign perv_add_thold_1 = thold_1;
   assign perv_lza_thold_1 = thold_1;
   assign perv_nrm_thold_1 = thold_1;
   assign perv_rnd_thold_1 = thold_1;
   assign perv_scr_thold_1 = thold_1;
   assign perv_pic_thold_1 = thold_1;
   assign perv_cr2_thold_1 = thold_1;

   assign perv_tbl_fpu_enable = fpu_enable;
   assign perv_tbe_fpu_enable = fpu_enable;
   assign perv_eie_fpu_enable = fpu_enable;
   assign perv_eov_fpu_enable = fpu_enable;
   assign perv_fmt_fpu_enable = fpu_enable;
   assign perv_mul_fpu_enable = fpu_enable;
   assign perv_alg_fpu_enable = fpu_enable;
   assign perv_sa3_fpu_enable = fpu_enable;
   assign perv_add_fpu_enable = fpu_enable;
   assign perv_lza_fpu_enable = fpu_enable;
   assign perv_nrm_fpu_enable = fpu_enable;
   assign perv_rnd_fpu_enable = fpu_enable;
   assign perv_scr_fpu_enable = fpu_enable;
   assign perv_pic_fpu_enable = fpu_enable;
   assign perv_cr2_fpu_enable = fpu_enable;

endmodule
