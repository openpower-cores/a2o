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

//==##########################################################################
//==###  FU_DIVSQRT.VHDL                                            #########
//==###                                                              #########
//==##########################################################################

   `include "tri_a2o.vh"

module fu_divsqrt(
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
   f_dsq_si,
   f_dsq_so,
   ex0_act_b,
   f_dcd_ex0_div,
   f_dcd_ex0_divs,
   f_dcd_ex0_sqrt,
   f_dcd_ex0_sqrts,
   f_dcd_ex0_record_v,
   f_dcd_ex2_divsqrt_hole_v,
   f_dcd_flush,
   f_dcd_ex1_itag,
   f_dcd_ex1_fpscr_addr,
   f_dcd_ex1_instr_frt,
   f_dcd_ex1_instr_tid,
   f_dcd_ex1_divsqrt_cr_bf,
   f_dcd_axucr0_deno,
   f_scr_ex6_fpscr_rm_thr0,
   f_scr_ex6_fpscr_ee_thr0,
   f_scr_ex6_fpscr_rm_thr1,
   f_scr_ex6_fpscr_ee_thr1,
   f_fmt_ex2_a_sign_div,
   f_fmt_ex2_a_expo_div_b,
   f_fmt_ex2_a_frac_div,
   f_fmt_ex2_b_sign_div,
   f_fmt_ex2_b_expo_div_b,
   f_fmt_ex2_b_frac_div,
   f_fmt_ex2_a_zero,
   f_fmt_ex2_a_zero_dsq,
   f_fmt_ex2_a_expo_max,
   f_fmt_ex2_a_expo_max_dsq,
   f_fmt_ex2_a_frac_zero,
   f_fmt_ex2_b_zero,
   f_fmt_ex2_b_zero_dsq,
   f_fmt_ex2_b_expo_max,
   f_fmt_ex2_b_expo_max_dsq,
   f_fmt_ex2_b_frac_zero,
   f_dsq_ex3_hangcounter_trigger,
   f_dsq_ex5_divsqrt_v,
   f_dsq_ex6_divsqrt_v,
   f_dsq_ex6_divsqrt_record_v,
   f_dsq_ex6_divsqrt_v_suppress,
   f_dsq_ex5_divsqrt_itag,
   f_dsq_ex6_divsqrt_fpscr_addr,
   f_dsq_ex6_divsqrt_instr_frt,
   f_dsq_ex6_divsqrt_instr_tid,
   f_dsq_ex6_divsqrt_cr_bf,
   f_dsq_ex6_divsqrt_sign,
   f_dsq_ex6_divsqrt_exp,
   f_dsq_ex6_divsqrt_fract,
   f_dsq_ex6_divsqrt_flag_fpscr,
   f_dsq_debug
);

   inout          vdd;
   inout          gnd;

   input          clkoff_b;		// tiup
   input          act_dis;		// ??tidn??
   input          flush;		// ??tidn??
   input          delay_lclkr;		// tidn,
   input          mpw1_b;		// tidn,
   input          mpw2_b;		// tidn,
   input          sg_1;
   input          thold_1;
   input          fpu_enable;		//dc_act

   input [0:`NCLK_WIDTH-1]         nclk;

   //--------------------------------------------------------------------------
   input          f_dsq_si;		//perv  scan
   output         f_dsq_so;		//perv  scan
   input          ex0_act_b;
   //--------------------------------------------------------------------------
   input          f_dcd_ex0_div;
   input          f_dcd_ex0_divs;
   input          f_dcd_ex0_sqrt;
   input          f_dcd_ex0_sqrts;
   input          f_dcd_ex0_record_v;
   input          f_dcd_ex2_divsqrt_hole_v;
   //--------------------------------------------------------------------------
   input [0:1]    f_dcd_flush;
   input [0:6]    f_dcd_ex1_itag;
   input [0:5]    f_dcd_ex1_fpscr_addr;
   input [0:5]    f_dcd_ex1_instr_frt;
   input [0:3]    f_dcd_ex1_instr_tid;
   input [0:4]    f_dcd_ex1_divsqrt_cr_bf;
   input          f_dcd_axucr0_deno;

   input [0:1]    f_scr_ex6_fpscr_rm_thr0;
   input [0:4]    f_scr_ex6_fpscr_ee_thr0;		// FPSCR VE,OE,UE,ZE,XE
   input [0:1]    f_scr_ex6_fpscr_rm_thr1;
   input [0:4]    f_scr_ex6_fpscr_ee_thr1;		// FPSCR VE,OE,UE,ZE,XE
   //--------------------------------------------------------------------------

   input          f_fmt_ex2_a_sign_div;		// these operands are actually ex2
   input [01:13]  f_fmt_ex2_a_expo_div_b;
   input [01:52]  f_fmt_ex2_a_frac_div;

   input          f_fmt_ex2_b_sign_div;
   input [01:13]  f_fmt_ex2_b_expo_div_b;
   input [01:52]  f_fmt_ex2_b_frac_div;

   input          f_fmt_ex2_a_zero;
   input          f_fmt_ex2_a_zero_dsq;
   input          f_fmt_ex2_a_expo_max;
   input          f_fmt_ex2_a_expo_max_dsq;
   input          f_fmt_ex2_a_frac_zero;

   input          f_fmt_ex2_b_zero;
   input          f_fmt_ex2_b_zero_dsq;
   input          f_fmt_ex2_b_expo_max;
   input          f_fmt_ex2_b_expo_max_dsq;
   input          f_fmt_ex2_b_frac_zero;

   output         f_dsq_ex3_hangcounter_trigger;

   //--------------------------------------------------------------------------
   output [0:1]   f_dsq_ex5_divsqrt_v;
   output [0:1]   f_dsq_ex6_divsqrt_v;
   output         f_dsq_ex6_divsqrt_record_v;
   output         f_dsq_ex6_divsqrt_v_suppress;
   output [0:6]   f_dsq_ex5_divsqrt_itag;
   output [0:5]   f_dsq_ex6_divsqrt_fpscr_addr;
   output [0:5]   f_dsq_ex6_divsqrt_instr_frt;
   output [0:3]   f_dsq_ex6_divsqrt_instr_tid;
   output [0:4]   f_dsq_ex6_divsqrt_cr_bf;
   output         f_dsq_ex6_divsqrt_sign;		// needs to be right off of a latch
   output [01:13] f_dsq_ex6_divsqrt_exp;		// needs to be right off of a latch
   output [00:52] f_dsq_ex6_divsqrt_fract;		// needs to be right off of a latch
   output [00:15] f_dsq_ex6_divsqrt_flag_fpscr;
   output [00:63] f_dsq_debug;

   //--------------------------------------------------------------------------





   //==################################################

   parameter      tiup = 1'b1;
   parameter      tidn = 1'b0;

   wire           sg_0;
   wire           thold_0_b;
   wire           thold_0;
   wire           force_t;

   //----------------------------------------------------------------------
   // todo items:


   //----------------------------------------------------------------------

   wire [00:56]   zeros;
   wire [00:27]   ones;

   wire           ex0_act;
   wire           ex1_act;
   wire           ex2_act;
   wire           ex3_act;
   wire           ex4_act;
   wire [0:7]     act_so;
   wire [0:7]     act_si;

   wire [0:14]    ex1_div_instr_lat_scin;
   wire [0:14]    ex1_div_instr_lat_scout;
   wire [0:5]     ex2_div_instr_lat_scin;
   wire [0:5]     ex2_div_instr_lat_scout;
   wire [0:8]     ex2_itag_lat_scin;
   wire [0:8]     ex2_itag_lat_scout;
   wire [0:27]    ex2_fpscr_addr_lat_scin;
   wire [0:27]    ex2_fpscr_addr_lat_scout;

   wire [0:18]    ex1_div_ctr_lat_scin;
   wire [0:18]    ex1_div_ctr_lat_scout;
   wire [0:95]    ex5_div_result_lat_scin;
   wire [0:95]    ex5_div_result_lat_scout;
   wire [0:65]    ex6_div_result_lat_scin;
   wire [0:65]    ex6_div_result_lat_scout;
   wire [0:162]   ex5_special_case_lat_scin;
   wire [0:162]   ex5_special_case_lat_scout;
   wire [0:3]     ex5_div_done_lat_scout;
   wire [0:3]     ex5_div_done_lat_scin;
   wire 	  HW165073_bits;
   wire           HW165073_hit;

   wire           ex1_divsqrt_running_d;
   wire           exx_divsqrt_running_q;
   wire           ex1_divsqrt_done;
   wire           ex2_divsqrt_done;
   wire           ex2_divsqrt_done_din;
   wire           ex2_waiting_for_hole;

   wire           ex2_divsqrt_zero;
   wire           ex3_divsqrt_done_din;
   wire           ex4_divsqrt_done_din;
   wire           ex5_divsqrt_done_din;
   wire           ex3_divsqrt_done;
   wire           ex4_divsqrt_done;
   wire           ex4_divsqrt_done_q;
   wire           ex5_divsqrt_done;
   wire           ex6_divsqrt_done;
   wire           ex4_start_a_denorm_result;
   wire           ex4_start_denorm_result;
   wire           ex4_denormalizing_result;
   wire           ex4_denormalizing_result_done;
   wire           ex4_denormalizing_result_done_din;
   wire           ex5_denormalizing_result_done;
   wire           ex4_denormalizing_result_shifting;
   wire           ex4_divsqrt_denorm_hold;
   wire           ex4_denormalizing_result_rounding;
   wire           ex4_start_sp_denorm_result;
   wire           exp_eq_369;
   wire           exp_eq_380;
   wire           exp_eq_368;
   wire           exp_eq_367;
   wire           exp_eq_367to9;
   wire           ex4_force_36A;
   wire           ex4_force;
   wire           ex4_dnr_roundup_incexp;
   wire           ex4_roundup_incexp;

   wire           ex4_x_roundup_incexp;
   wire           ex5_x_roundup_incexp;

   wire [0:70]    ex2_div_a_stage_lat_scout;
   wire [0:70]    ex2_div_a_stage_lat_scin;
   wire [0:70]    ex2_div_b_stage_lat_scout;
   wire [0:70]    ex2_div_b_stage_lat_scin;
   wire [0:113]   ex3_div_PR_sumcarry_lat_scout;
   wire [0:113]   ex3_div_PR_sumcarry_lat_scin;
   wire [0:7]     ex3_div_PR_sum4carry4_lat_scout;
   wire [0:7]     ex3_div_PR_sum4carry4_lat_scin;
   wire [0:113]   ex3_div_Q_QM_lat_scin;
   wire [0:113]   ex3_div_Q_QM_lat_scout;
   wire [0:113]   ex3_div_bQ_QM_lat_scin;
   wire [0:113]   ex3_div_bQ_QM_lat_scout;

   wire [0:167]   ex3_sqrt_bitmask_lat_scin;
   wire [0:167]   ex3_sqrt_bitmask_lat_scout;
   wire [0:51]    ex2_div_exp_lat_scout;
   wire [0:51]    ex2_div_exp_lat_scin;

   wire [0:55]    ex3_denom_lat_scout;
   wire [0:55]    ex3_denom_lat_scin;
   wire [0:26]    exx_div_denorm_lat_scout;
   wire [0:26]    exx_div_denorm_lat_scin;
   wire           ex4_deno_force_zero;

   wire           exx_running_act_d;
   wire           exx_running_act_q;

   (* analysis_not_referenced="TRUE" *)
   wire [0:3]     act_spare_unused;
   (* analysis_not_referenced="TRUE" *)
   wire [0:880]   spare_unused;

   wire           ex0_record_v;
   wire           ex1_record_v;
   wire           ex2_record_v;
   wire           exx_record_v_din;
   wire           exx_record_v_q;
   wire           ex0_div;
   wire           ex0_divs;
   wire           ex0_sqrt;
   wire           ex0_sqrts;
   wire           ex1_div;
   wire           ex1_divs;
   wire           ex1_sqrt;
   wire           ex1_sqrts;
   wire           ex1_div_dout;
   wire           ex1_divs_dout;
   wire           ex1_sqrt_dout;
   wire           ex1_sqrts_dout;

   wire           ex2_div;
   wire           ex2_divs;
   wire           ex2_sqrt;
   wire           ex2_sqrts;
   wire           ex2_sp;
   wire           ex1_instr_v;

   wire           ex2_div_or_divs;
   wire           ex2_sqrt_or_sqrts;
   wire           ex0_anydivsqrt;
   wire           ex1_anydivsqrt;
   wire           ex2_anydivsqrt;
   wire           ex3_anydivsqrt;
   wire           ex4_anydivsqrt;
   wire           ex5_anydivsqrt;
   wire           ex6_anydivsqrt;
   wire [0:6]     ex1_itag_din;
   wire [0:6]     exx_itag_q;
   wire [0:5]     ex1_fpscr_addr_din;
   wire [0:5]     exx_fpscr_addr_q;
   wire [0:5]     ex1_instr_frt_din;
   wire [0:5]     exx_instr_frt_q;
   wire [0:3]     ex1_instr_tid_din;
   wire [0:3]     exx_instr_tid_q;
   wire [0:1]     tid_init;
   wire [0:1]     tid_hold;
   wire [0:1]     tid_clear;
   wire [0:4]     ex1_cr_bf_din;
   wire [0:4]     exx_cr_bf_q;

   wire [0:7]     ex0_op_cyc_count_din;
   wire [0:7]     ex1_op_cyc_count;

   wire [0:7]     ex2_hangcounter_din;
   wire [0:7]     ex3_hangcounter_q;

   wire [0:7] 	  ex3_div_hangcounter_lat_scout;
   wire [0:7] 	  ex3_div_hangcounter_lat_scin;

   wire [0:63] 	  f_dsq_debug_din;
   wire [0:63] 	  f_dsq_debug_q;
   wire [0:63] 	  f_dsq_debug_lat_scin;
   wire [0:63] 	  f_dsq_debug_lat_scout;

   wire           ex2_hangcounter_clear;
   wire           ex2_hangcounter_incr;
   wire           ex3_hangcounter_trigger;

   wire           ex4_sp;
   wire           ex4_dp;
   wire           exx_sp;
   wire           exx_dp;

   wire           ex1_cycles_init;
   wire           ex1_cycles_decr;
   wire           ex1_cycles_hold;
   wire           ex1_cycles_clear;
   wire           exx_single_precision_d;
   wire           exx_single_precision_q;

   wire           ex2_a_zero;
   wire           ex2_a_SPunderflow_zero;
   wire           ex2_a_expo_max;
   wire           ex2_a_SPoverflow_expo_max;
   wire           ex2_b_SPoverflow_expo_max;

   wire           ex2_a_frac_zero;
   wire           ex2_b_zero;
   wire           ex2_b_SPunderflow_zero;

   wire           ex2_b_expo_max;
   wire           ex2_b_frac_zero;

   wire           exx_a_zero_d;
   wire           exx_a_expo_max_d;
   wire           exx_a_frac_zero_d;
   wire           exx_b_zero_d;
   wire           exx_a_SPunderflow_zero_d;
   wire           exx_b_SPunderflow_zero_d;
   wire           exx_a_SPoverflow_expo_max_d;
   wire           exx_b_SPoverflow_expo_max_d;
   wire           exx_a_SPoverflow_expo_max_q;
   wire           exx_b_SPoverflow_expo_max_q;

   wire           exx_b_expo_max_d;
   wire           exx_b_frac_zero_d;

   wire           exx_a_zero_q;
   wire           exx_b_SPunderflow_zero_q;
   wire           exx_a_SPunderflow_zero_q;

   wire           exx_a_expo_max_q;
   wire           exx_a_frac_zero_q;
   wire           exx_b_zero_q;
   wire           exx_b_expo_max_q;
   wire           exx_b_frac_zero_q;

   wire           exx_a_NAN;
   wire           exx_b_NAN;
   wire           exx_a_INF;
   wire           exx_b_INF;
   wire           exx_a_SPoverflowINF;
   wire           exx_b_SPoverflowINF;
   wire           exx_b_ZER;
   wire           exx_a_ZER;
   wire           exx_b_SPunderflowZER;
   wire           exx_a_SPunderflowZER;
   wire           ex4_a_snan;
   wire           ex4_b_snan;
   wire           ex4_snan;
   wire           exx_hard_spec_case;

   wire           ex4_div_by_zero_zx;
   wire           ex4_zero_div_zero;
   wire           ex4_inf_div_inf;
   wire           ex4_sqrt_neg;

   wire           ex4_pass_a_nan;
   wire           ex4_pass_b_nan;
   wire           ex4_pass_nan;
   wire           ex4_pass_a_nan_sp;
   wire           ex4_pass_b_nan_sp;
   wire           ex4_pass_a_nan_dp;
   wire           ex4_pass_b_nan_dp;

   wire           exx_divsqrt_v_suppress_d;
   wire           exx_divsqrt_v_suppress_q;

   wire           ex4_force_zero;
   wire           ex4_force_zeroone;
   wire           ex4_force_inf;
   wire           ex5_force_inf;
   wire           ex4_force_maxnorm;
   wire           ex4_force_maxnorm_sp;
   wire           ex4_force_maxnorm_dp;
   wire           ex4_force_qnan;
   wire           ex4_div_special_case;
   wire           ex5_div_special_case;
   wire           exx_sqrt_d;
   wire           exx_div_d;

   wire [00:03]   exx_div_q;
   wire [00:03]   exx_sqrt_q;
   wire [00:06]   exx_fpscr_din;
   wire [00:06]   exx_fpscr_q;

   wire [00:52]   ex4_divsqrt_fract;
   wire [00:56]   ex4_divsqrt_fract_cur;
   wire [00:56]   ex4_divsqrt_fract_shifted;
   wire [00:56]   ex4_divsqrt_fract_shifted_dp;
   wire [00:56]   ex4_divsqrt_fract_shifted_spmasked;
   wire [00:56]   ex4_divsqrt_fract_stickymask;
   wire [00:53]   ex4_divsqrt_fract_dnr;

   wire           dn_lv1sh00;
   wire           dn_lv1sh01;
   wire           dn_lv1sh10;
   wire           dn_lv1sh11;
   wire           dn_lv2sh00;
   wire           dn_lv2sh01;
   wire           dn_lv2sh10;
   wire           dn_lv2sh11;
   wire           dn_lv3sh00;
   wire           dn_lv3sh01;
   wire           dn_lv3sh10;
   wire           dn_lv3sh11;
   wire           dnsp_lv1sh00;
   wire           dnsp_lv1sh01;
   wire           dnsp_lv1sh10;
   wire           dnsp_lv1sh11;
   wire           dnsp_lv2sh00;
   wire           dnsp_lv2sh01;
   wire           dnsp_lv2sh10;
   wire           dnsp_lv2sh11;
   wire           dnsp_lv3sh00;
   wire           dnsp_lv3sh01;
   wire           dnsp_lv3sh10;
   wire           dnsp_lv3sh11;

   wire [00:59]   ex4_divsqrt_fract_shifted_00to03;
   wire [00:71]   ex4_divsqrt_fract_shifted_00to12;
   wire [00:119]  ex4_divsqrt_fract_shifted_00to48;
   wire [00:56]   ex4_spdenorm_mask;
   wire [00:59]   ex4_spdenorm_mask_shifted_00to03;
   wire [00:71]   ex4_spdenorm_mask_shifted_00to12;
   wire [00:119]  ex4_spdenorm_mask_shifted_00to48;
   wire [00:56]   ex4_spdenorm_mask_lsb;
   wire [00:59]   ex4_spdenorm_mask_lsb_shifted_00to03;
   wire [00:71]   ex4_spdenorm_mask_lsb_shifted_00to12;
   wire [00:119]  ex4_spdenorm_mask_lsb_shifted_00to48;
   wire [00:56]   ex4_spdenorm_mask_guard;
   wire [00:59]   ex4_spdenorm_mask_guard_shifted_00to03;
   wire [00:71]   ex4_spdenorm_mask_guard_shifted_00to12;
   wire [00:119]  ex4_spdenorm_mask_guard_shifted_00to48;
   wire [00:56]   ex4_spdenorm_mask_round;
   wire [00:59]   ex4_spdenorm_mask_round_shifted_00to03;
   wire [00:71]   ex4_spdenorm_mask_round_shifted_00to12;
   wire [00:119]  ex4_spdenorm_mask_round_shifted_00to48;

   wire [00:52]   ex4_divsqrt_fract_special;
   wire [00:52]   ex5_divsqrt_fract_special;
   wire [00:52]   ex5_divsqrt_fract_d;
   wire [00:52]   ex6_divsqrt_fract_q;

   wire [01:13]   ex4_divsqrt_exp;
   wire [01:13]   ex4_divsqrt_exp_special;
   wire [01:13]   ex5_divsqrt_exp_special;
   wire [01:13]   ex5_divsqrt_exp_d;
   wire [01:13]   ex6_divsqrt_exp_q;
   wire           ex4_maxnorm_sign;
   wire           ex4_divsqrt_sign;
   wire           ex4_divsqrt_sign_special;

   wire [1:52]    ex2_b_fract;

   wire [1:52]    ex2_a_fract;

   wire           exx_a_sign_d;
   wire [1:13]    exx_a_biased_13exp_d;
   wire [1:52]    exx_a_fract_d;

   wire           exx_b_sign_d;
   wire [1:13]    exx_b_biased_13exp_d;
   wire [1:52]    exx_b_fract_d;

   wire           exx_a_sign_q;
   wire [1:13]    exx_a_biased_13exp_q;
   wire [1:52]    exx_a_fract_q;

   wire           exx_b_sign_q;
   wire [1:13]    exx_b_biased_13exp_q;
   wire [1:52]    exx_b_fract_q;

   wire [1:13]    exx_exp_ux_adj;
   wire [1:13]    exx_exp_ux_adj_dp;
   wire [1:13]    exx_exp_ux_adj_sp;
   wire [1:13]    exx_exp_ox_adj;
   wire [1:13]    exx_exp_ox_adj_dp;
   wire [1:13]    exx_exp_ox_adj_sp;
   wire           exx_invalid_mixed_precision;

   wire [1:13]    exx_b_ubexp;
   wire [1:13]    exy_b_ubexp;
   wire [1:13]    exx_exp_adj;
   wire [1:13]    exx_exp_adj_p1;
   wire [0:12]    exz_exp_addres_x0;
   wire [0:12]    exx_exp_addres_ux;
   wire [0:12]    exx_exp_addres_ox;
   wire [0:12]    exx_exp_addres;
   wire [0:12]    exx_exp_addres_div_x0;
   wire [0:12]    exx_exp_addres_sqrt_x0;
   wire [0:12]    exy_exp_addres_div_x0;
   wire [0:12]    exy_exp_addres_div_x0_m1;
   wire [0:12]    exz_exp_addres_div_x0_m1;
   wire [0:12]    exz_exp_addres_div_x0_adj;
   wire [0:12]    exy_exp_addres_sqrt_x0;

   wire [0:12]    exx_exp_addres_x0_p1;
   wire [0:12]    exx_exp_addres_ux_p1;
   wire [0:12]    exx_exp_addres_ox_p1;
   wire [0:12]    exy_exp_addres_x0_p1;
   wire [0:12]    exy_exp_addres_ux_p1;
   wire [0:12]    exy_exp_addres_ox_p1;
   wire [0:12]    exy_exp_addres_p1;
   wire [0:12]    exx_exp_addres_div_x0_p1;
   wire [0:12]    exx_exp_addres_sqrt_x0_p1;

   wire           ex4_expresult_zero;
   wire [7:12]    denorm_count_start;
   wire [0:5]     denorm_shift_amt;
   wire [0:5]     denorm_shift_amt_din;
   wire [0:5]     denorm_shift_amt_q;
   wire [0:5]     sp_denorm_shift_amt;
   wire [0:5]     sp_denorm_shift_amt_din;
   wire [0:5]     sp_denorm_shift_amt_q;
   wire           ex2_divsqrt_hole_v_b;


   wire           overflow;
   wire           underflow;
   wire           ueux;
   wire           oeox;
   wire           zezx;
   wire           vevx;
   wire           not_ueux_or_oeox;
   wire           exy_not_ueux_or_oeox;
   wire           exy_oeox;

   wire           overflow_sp;
   wire           sp_overflow_brink_x47E;
   wire           ex4_incexp_to_sp_overflow;
   wire           dp_overflow_brink_x7FE;
   wire           ex4_incexp_to_dp_overflow;
   wire           ex4_incexp_to_overflow;
   wire           underflow_sp;
   wire           overflow_dp;
   wire           underflow_dp;
   wire           underflow_denorm;
   wire           underflow_denorm_dp;
   wire           underflow_denorm_sp;
   wire           underflow_force_zero;
   wire           underflow_force_36A;
   wire           underflow_force_zeroone;
   wire           overflow_force_inf;
   wire           special_force_zero;
   wire           special_force_inf;
   wire           overflow_force_maxnorm;
   wire           underflow_sp_denorm;
   wire           sp_denorm_0x369roundup;
   wire           sp_denorm_underflow_zero;
   wire           sp_denorm_0x380roundup;

   wire           exx_q_bit0;
   wire           exx_q_bit0_cin;
   wire           exx_q_bit1;
   wire           exx_q_bit1_div;
   wire           exx_q_bit1_sqrt;
   wire           exx_q_bit1_cin_div;
   wire           exx_q_bit1_cin_sqrt;
   wire           exx_q_bit2;
   wire           exx_q_bit2_cin;
   wire           exx_q_bit3_div;
   wire           exx_q_bit3_cin_div;
   wire           exx_q_bit3_sqrt;
   wire           exx_q_bit3_cin_sqrt;
   wire           exx_q_bit3;
   wire           exx_nq_bit3;
   wire [0:1]     exx_q_bit22_sel;

   wire           exx_nq_bit0;
   wire           exx_nq_bit1;
   wire           exx_nq_bit1_div;
   wire           exx_nq_bit1_sqrt;
   wire           exx_nq_bit2;
   wire           exx_nq_bit3_div;
   wire           exx_nq_bit3_sqrt;

   wire 	  exx_notqornq_bit1_sqrt;
   wire 	  exx_notqornq_bit2;
   wire 	  exx_notqornq_bit3_sqrt;

   wire 	  exx_notqornq_bit1_div;
   wire 	  exx_notqornq_bit3_div;

   wire           exx_q_bit22;
   wire           exx_nq_bit22;
   wire           exx_q_bit22_div;
   wire           exx_nq_bit22_div;
   wire           exx_q_bit22_sqrt;
   wire           exx_nq_bit22_sqrt;

   wire           exx_notqornq_bit22_sqrt;
   wire           exx_notqornq_bit22_div;

   wire           exx_q_bit0_b;
   wire           exx_nq_bit0_b;
   wire           exx_q_bit0_prebuf;
   wire           exx_nq_bit0_prebuf;


   wire [0:56]    exx_Q_q;
   wire [0:56]    exx_Q_d;
   wire [0:56]    exx_QM_q;
   wire [0:56]    exx_QM_d;
   wire [0:56]    exx_bQ_q;
   wire [0:56]    exx_bQ_d;
   wire [0:56]    exx_bQM_q;
   wire [0:56]    exx_bQM_d;

   wire [0:56]    exx_lev0_csaout_sum;
   wire [0:56]    exx_lev0_csaout_carry;
   wire [0:56]    exx_lev0_csaoutsh_sum;
   wire [0:56]    exx_lev0_csaoutsh_carry;
   wire           exx_lev0_selD;
   wire           exx_lev0_selnD;
   wire           exx_lev0_selneg;
   wire           exx_lev0_selD_b;
   wire           exx_lev0_selnD_b;

   wire           exx_lev0_selQ;
   wire           exx_lev0_selMQ;
   wire           exx_lev0_selQ_b;
   wire           exx_lev0_selMQ_b;

   wire           exx_lev22_selD;
   wire           exx_lev22_selnD;
   wire           exx_lev22_selneg;
   wire           exx_lev22_selQ;
   wire           exx_lev22_selMQ;

   wire [0:56]    exx_lev0_csaout_carryout;

   wire [0:56] 	  exx_lev0_divsqrt_csaout_xor;
   wire [0:56] 	  exx_lev1_divsqrt_csaout_xor;
   wire [0:56] 	  exx_lev3_divsqrt_csaout_xor;


   wire [0:56]    exx_lev1_div_oper;
   wire [0:56]    exx_lev1_sqrt_oper;
   wire [0:56]    exx_lev3_div_oper;
   wire [0:56]    exx_lev3_sqrt_oper;

   wire [0:56]    exx_lev1_div_csaout_sum;
   wire [0:56]    exx_lev1_div_csaout_carry;
   wire [0:56]    exx_lev1_sqrt_csaout_sum;
   wire [0:56]    exx_lev1_sqrt_csaout_carry;

   wire [0:56]    exx_lev2_csaout_sum;
   wire [0:56]    exx_lev2_csaout_carry;

   wire [0:56]    exx_lev3_div_csaout_sum;
   wire [0:56]    exx_lev3_div_csaout_carry;
   wire [0:56]    exx_lev3_sqrt_csaout_sum;
   wire [0:56]    exx_lev3_sqrt_csaout_carry;

   wire [0:56]    exx_lev1_div_csaout_carryout;
   wire [0:56]    exx_lev1_sqrt_csaout_carryout;

   wire [0:56]    exx_lev2_csaout_carryout;
   wire [0:56]    exx_lev3_div_csaout_carryout;
   wire [0:56]    exx_lev3_sqrt_csaout_carryout;
   wire [0:56]    exx_lev22_csaout_carryout_div;
   wire [0:56]    exx_lev22_csaout_carryout_sqrt;
   wire [0:56]    exx_lev22_csaout_sum_sqrt;

   wire [0:56]    exx_lev22_csaout_carry_sqrt;
   wire [0:56]    exx_lev22_csaout_sum_div;

   wire [0:56]    exx_lev22_csaout_carry_div;
   wire [0:56]    exx_lev22_csaout_sum_xor;

   wire [0:56]    exx_PR_sum_d;
   wire [0:56]    exx_PR_sum_q;
   wire [0:56]    exx_PR_sum_d_late;
   wire [0:56]    exx_PR_sum_d_early;
   wire [0:3]     exx_PR_sum4_q;

   wire [0:56]    ex3_divsqrt_remainder;
   wire [0:56]    ex4_divsqrt_remainder;

   wire           ex3_rem_neg;
   wire           ex3_rem_neg_b;

   wire [0:3]     ex4_rem_neg;
   wire [0:3]     ex4_rem_neg_b;

   wire [0:56]    ex4_rem_neg_buf;
   wire [0:56]    ex4_rem_neg_buf_b;

   wire           ex4_rem_nonzero;
   wire           ex4_rem_nonzero_fi;
   wire           underflow_fi;
   wire           ex4_round_up;
   wire           ex4_round_up_underflow;
   wire           ex4_round_up_dnr;
   wire           ex3_norm_shl1;
   wire           ex3_norm_shl1_dp;
   wire           ex3_norm_shl1_sp;
   wire           ex4_norm_shl1;
   wire           ex4_norm_shl1_q;
   wire           ex4_norm_shl1_d;
   wire           ex4_norm_shl1_test;

   wire [0:56]    exx_PR_carry_d;
   wire [0:56]    exx_PR_carry_q;
   wire [0:3]     exx_PR_carry4_q;

   wire [0:56]    exx_PR_sum_shift;
   wire [0:56]    exx_PR_sum_final;
   wire [0:56]    exx_PR_carry_shift;
   wire [0:56]    exx_PR_carry_final;
   wire [0:56]    exx_PR_sum_q_shifted;
   wire [0:56]    exx_PR_carry_q_shifted;

   wire [0:56]    exx_Qin_lev0;
   wire [0:56]    exx_QMin_lev0;
   wire [0:56]    exx_Qin_lev1_sqrt;
   wire [0:56]    exx_QMin_lev1_sqrt;
   wire [0:56]    exx_Qin_lev1_div;
   wire [0:56]    exx_QMin_lev1_div;

   wire [0:56]    exx_bQin_lev1_sqrt;
   wire [0:56]    exx_bQMin_lev1_sqrt;
   wire [0:56]    exx_bQ_q_t;
   wire [0:56]    exx_bQM_q_t;

   wire           exx_Qin_lev0_sel0;
   wire           exx_Qin_lev0_sel1;
   wire           exx_QMin_lev0_sel0;
   wire           exx_QMin_lev0_sel1;
   wire           exx_QMin_lev0_sel2;
   wire           exx_Qin_lev1_sel0_sqrt;
   wire           exx_Qin_lev1_sel1_sqrt;
   wire           exx_Qin_lev1_sel0_div;
   wire           exx_Qin_lev1_sel1_div;

   wire           exx_QMin_lev1_sel0_div;
   wire           exx_QMin_lev1_sel1_div;
   wire           exx_QMin_lev1_sel2_div;
   wire           exx_QMin_lev1_sel0_sqrt;
   wire           exx_QMin_lev1_sel1_sqrt;
   wire           exx_QMin_lev1_sel2_sqrt;

   wire [0:3]     exx_sum4;
   wire [0:3]     exx_sum4_lev1_div;
   wire [0:3]     exx_sum4_lev1_sqrt;
   wire [0:3]     exx_sum4_lev2;
   wire [0:3]     exx_sum4_lev3_div;
   wire [0:3]     exx_sum4_lev3_sqrt;

   wire [0:55]    exx_denom_d;
   wire [0:55]    exx_denom_q;
   wire [0:55]    exx_denomQ_lev0;
   wire [0:55]    exx_denomQ_lev22_div;
   wire [0:55]    exx_denomQ_lev22_sqrt;
   wire [0:55]    exx_denomQ_lev0_nD_b;
   wire [0:55]    exx_denomQ_lev0_D_b;
   wire [0:55]    exx_denomQ_lev0_Q_b;
   wire [0:55]    exx_denomQ_lev0_MQ_b;
   wire [0:55]    exx_sqrtlev0_Q;
   wire [0:55]    exx_sqrtlev0_MQ;
   wire [0:55]    exx_sqrt_newbitmask_din;
   wire [0:55]    exx_sqrt_newbitmask_q;
   wire [0:55]    exx_sqrt_Qbitmask_din;
   wire [0:55]    exx_sqrt_Qbitmask_q;
   wire [0:55]    exx_sqrt_QMbitmask_din;
   wire [0:55]    exx_sqrt_QMbitmask_q;

   wire [0:55]    exx_sqrt_Qmaskvec;
   wire [0:55]    exx_sqrt_QMmaskvec;
   wire           wQ;
   wire           wMQ;
   wire [0:55]    exx_sqrtlev22_Q;
   wire [0:55]    exx_sqrtlev22_MQ;
   wire [0:55]    exx_bQin_lev0;
   wire [0:55]    exx_bQMin_lev0;
   wire [0:55]    exx_bQin_lev0_t;
   wire [0:55]    exx_bQMin_lev0_t;

   wire           ex2_PR_sum_sel0;
   wire           ex2_PR_sum_sel1;
   wire           ex2_PR_sum_sel2;
   wire           ex2_PR_sum_sel3;
   wire           ex2_PR_sum_sel4;
   wire           ex2_PR_sum_sel_late;
   wire           ex2_PR_sum_sel_early;
   wire           ex2_PR_carry_sel0;
   wire           ex2_PR_carry_sel1;
   wire           ex2_PR_carry_sel2;

   wire [00:56]   ex4_divsqrt_fract_preround;
   wire [00:56]   ex4_divsqrt_fract_preround_prenorm;

   wire [00:53]   ex4_divsqrt_fract_p0;
   wire [00:53]   ex4_divsqrt_fract_p1;
   wire [00:53]   ex5_divsqrt_fract_p1;
   wire           ex5_round_up;

   wire [00:53]   ex4_divsqrt_fract_dnr_p0;
   wire [00:53]   ex4_divsqrt_fract_dnr_p1;
   wire [00:53]   ex4_divsqrt_fract_dnr_sp_p0;
   wire [00:53]   ex4_divsqrt_fract_dnr_sp_p1;
   wire [00:53]   ex4_divsqrt_fract_dnr_dp;
   wire [00:53]   ex4_divsqrt_fract_dnr_sp;
   wire [00:53]   ex4_divsqrt_fract_dnr_sp_prem;

   wire           denorm_res_shiftoff_exp;
   wire           denorm_res_shiftoff_din;
   wire           denorm_res_shiftoff_q;
   wire           ex4_denorm_res_shiftoff_zero;
   wire [00:53]   ex4_divsqrt_fract_p0_sp;
   wire [00:53]   ex4_divsqrt_fract_p1_sp;
   wire [00:53]   ex4_divsqrt_fract_p0_dp;
   wire [00:53]   ex4_divsqrt_fract_p1_dp;
   wire [00:53]   ex4_divsqrt_fract_rounded;

   wire           exx_divsqrt_sign_d;
   wire [01:13]   exx_divsqrt_exp_d;
   wire [00:56]   exx_divsqrt_fract_d;
   wire [00:15]   exx_divsqrt_flag_fpscr_d;

   wire           exx_divsqrt_sign_q;
   wire [01:13]   exx_divsqrt_exp_q;
   wire [00:56]   exx_divsqrt_fract_q;
   wire [00:15]   exx_divsqrt_flag_fpscr_q;

   wire           n_flush_d;
   wire           n_flush;

   wire [01:13]   f_fmt_ex2_b_expo_div;
   wire [01:13]   f_fmt_ex2_a_expo_div;

   wire [0:7]     ex1_cycles_d;
   wire [0:7]     ex2_cycles_q;
   wire           lsb;
   wire           guard;
   wire           round;
   wire           sticky;
   wire           sticky_w_underflow;
   wire           denorm_sticky;
   wire           denorm_sticky_q;
   wire           denorm_sticky_din;
   wire           sign;
   wire           denorm_sticky_sp;
   wire           denorm_sticky_sp_q;
   wire           denorm_sticky_sp_din;
   wire           lsb_dnr;
   wire           guard_dnr;
   wire           round_dnr;
   wire           sticky_dnr;
   wire           lsb_dnr_sp;
   wire           guard_dnr_sp;
   wire           round_dnr_sp;
   wire           sticky_dnr_sp;
   wire           ex4_round_up_dnr_sp;

   wire           RNEmode;
   wire           RTZmode;
   wire           RPImode;
   wire           RNImode;

   wire           ex4_sp_inexact_roundbits;
   wire           ex4_denorm_result_det;
   wire           exp_gt_cap;
   wire           ex4_sp_denorm_result_det;
   wire           ex4_exp_le_896;
   wire [00:13]   denorm_exp_addres;
   wire [00:13]   denorm_exp_addres_sp;
   wire [00:05]   denorm_count_din;
   wire [00:05]   denorm_count_q;
   wire           VE;		// FPSCR VE,OE,UE,ZE,XE
   wire           OE;
   wire           UE;
   wire           ZE;
   wire           XE;

   //==##########################################
   //# pervasive
   //==##########################################

   tri_plat  #(.WIDTH(1)) thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(thold_1),
      .q(thold_0)
   );


   tri_plat   #(.WIDTH(1)) sg_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din(sg_1),
      .q(sg_0)
   );


   tri_lcbor         lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(thold_0_b)
   );

   //==##########################################

   assign ex0_act = (~ex0_act_b);

   assign n_flush_d = (f_dcd_flush[0] & exx_instr_tid_q[0]) | (f_dcd_flush[1] & exx_instr_tid_q[1]);

   assign exx_running_act_d = (ex0_anydivsqrt | exx_running_act_q) & (~(ex4_divsqrt_done | n_flush));


   tri_rlmreg_p #(.INIT(0), .WIDTH(8),  .NEEDS_SRESET(0)) act_lat(
      .force_t(force_t),
      .d_mode(tiup),

      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .scout(act_so),
      .scin(act_si),
      //-----------------
      .din({
            exx_running_act_d,
            tidn,
            ex0_act,
            ex1_act,
            ex2_act,
            ex3_act,
            n_flush_d,
            tidn
            }),
      //-----------------
      .dout({
            exx_running_act_q,
            act_spare_unused[1],
            ex1_act,
            ex2_act,
            ex3_act,
            ex4_act,
            n_flush,
            act_spare_unused[3]
           })
   );

   //==##########################################

   assign zeros = {57{1'b0}};
   assign ones = {28{1'b1}};


   assign act_spare_unused[0] = tidn;
   assign act_spare_unused[2] = tidn;

   //----------------------------------------------------------------------
   //----------------------------------------------------------------------
   // Algorithm
   //
   //

   // cyc xx  ex1_divsqrt_done=1, final cycle that the fract path is functioning for the main fract bits
   // cyc xx  ex2_divsqrt_done=1, extra 2 rounding bits generated, initial normalize (possible SHL by 1)
   // cyc xx  ex3_divsqrt_done=1, round
   // cyc xx  ex4_divsqrt_done=1, renormalize after rounding, compute the final exponent (+expadj)
   // cyc xx  ex5_divsqrt_done=1, final result is on the bus, directly off of the latch
   // cyc xx
   //----------------------------------------------------------------------
   //----------------------------------------------------------------------

   //----------------------------------------------------------------------

   assign ex0_div = f_dcd_ex0_div;
   assign ex0_divs = f_dcd_ex0_divs;
   assign ex0_sqrt = f_dcd_ex0_sqrt;
   assign ex0_sqrts = f_dcd_ex0_sqrts;
   assign ex0_record_v = f_dcd_ex0_record_v;

   assign ex0_anydivsqrt = ex0_div | ex0_sqrt | ex0_divs | ex0_sqrts;

   assign ex0_op_cyc_count_din[0:7] = (8'b00011110 & {8{ex0_div}}) |    //0d30
                                      (8'b00010000 & {8{ex0_divs}}) |   //0d16
                                      (8'b00011101 & {8{ex0_sqrt}}) |   //0d29
                                      (8'b00001111 & {8{ex0_sqrts}});   //0d15



   tri_rlmreg_p #(.INIT(0), .WIDTH(15), .NEEDS_SRESET(0)) ex1_div_instr_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex1_div_instr_lat_scout),
      .scin(ex1_div_instr_lat_scin),
      //-----------------
      .din({
               ex0_div,
               ex0_divs,
               ex0_sqrt,
               ex0_sqrts,
               ex0_record_v,
               ex0_op_cyc_count_din,
               ex4_anydivsqrt,
               ex5_anydivsqrt}),
      //-----------------
      .dout({
               ex1_div_dout,
               ex1_divs_dout,
               ex1_sqrt_dout,
               ex1_sqrts_dout,
               ex1_record_v,
               ex1_op_cyc_count,
               ex5_anydivsqrt,
               ex6_anydivsqrt})
   );



   assign ex1_instr_v = |(f_dcd_ex1_instr_tid[0:3]); //or_reduce(f_dcd_ex1_instr_tid[0:3]);
   assign ex1_div = ex1_div_dout & ex1_instr_v;
   assign ex1_divs = ex1_divs_dout & ex1_instr_v;
   assign ex1_sqrt = ex1_sqrt_dout & ex1_instr_v;
   assign ex1_sqrts = ex1_sqrts_dout & ex1_instr_v;

   assign ex1_anydivsqrt = ex1_div | ex1_sqrt | ex1_divs | ex1_sqrts;


   tri_rlmreg_p #(.INIT(0), .WIDTH(6), .NEEDS_SRESET(0)) ex2_div_instr_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex2_div_instr_lat_scout),
      .scin(ex2_div_instr_lat_scin),
      //-----------------
      .din({
            ex1_div,
            ex1_divs,
            ex1_sqrt,
            ex1_sqrts,
            ex1_record_v,
            ex1_anydivsqrt}),
      //-----------------
      .dout({
            ex2_div,
            ex2_divs,
            ex2_sqrt,
            ex2_sqrts,
            ex2_record_v,
            ex2_anydivsqrt})
   );

   assign ex2_div_or_divs = ex2_div | ex2_divs;
   assign ex2_sqrt_or_sqrts = ex2_sqrt | ex2_sqrts;

   assign ex2_sp = ex2_divs | ex2_sqrts;

   //----------------------------------------------------------------------

   assign ex1_itag_din = (f_dcd_ex1_itag & {7{ex1_anydivsqrt}}) | (exx_itag_q & {7{(~ex1_anydivsqrt)}});


   tri_rlmreg_p #(.INIT(0), .WIDTH(9), .NEEDS_SRESET(0)) ex2_div_itag_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex2_itag_lat_scout),
      .scin(ex2_itag_lat_scin),
      //-----------------
      .din({
              ex1_itag_din,
              ex2_anydivsqrt,
              ex3_anydivsqrt}),
      //-----------------
      .dout({
                exx_itag_q,
                ex3_anydivsqrt,
                ex4_anydivsqrt})
   );



   assign ex1_fpscr_addr_din = (f_dcd_ex1_fpscr_addr & {6{ex1_anydivsqrt}}) |
                               (exx_fpscr_addr_q & {6{(~ex1_anydivsqrt)}});

   assign exx_fpscr_din = (({f_scr_ex6_fpscr_ee_thr0, f_scr_ex6_fpscr_rm_thr0}) & {7{(ex6_anydivsqrt & exx_instr_tid_q[0])}}) |
                          (({f_scr_ex6_fpscr_ee_thr1, f_scr_ex6_fpscr_rm_thr1}) & {7{(ex6_anydivsqrt & exx_instr_tid_q[1])}}) |
                          ((exx_fpscr_q) &                                       {7{(~ex6_anydivsqrt)}});

   assign ex1_instr_frt_din = (f_dcd_ex1_instr_frt &  {6{ex1_anydivsqrt}}) |
                               (exx_instr_frt_q &  {6{(~ex1_anydivsqrt)}});

   assign tid_init = {2{(ex1_anydivsqrt)}} & (~f_dcd_flush[0:1]);  // new one can be starting in ex1 while ex6 finishing
   assign tid_hold = {2{((~ex1_anydivsqrt) & (~ex6_divsqrt_done))}} & (~f_dcd_flush[0:1]);
   assign tid_clear = ({2{(~ex1_anydivsqrt)}} & {2{ex6_divsqrt_done}}) | f_dcd_flush[0:1];

   assign ex1_instr_tid_din[0:1] = (f_dcd_ex1_instr_tid[0:1] & tid_init) | (exx_instr_tid_q[0:1] & tid_hold) | (2'b00 & tid_clear);

   assign ex1_instr_tid_din[2:3] = 2'b00;

   assign ex1_cr_bf_din = (f_dcd_ex1_divsqrt_cr_bf & {5{ex1_anydivsqrt}}) |
                                     (exx_cr_bf_q & {5{(~ex1_anydivsqrt)}});


   tri_rlmreg_p #(.INIT(0), .WIDTH(28), .NEEDS_SRESET(1)) ex2_div_fpscr_addr_cr_bf_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex2_fpscr_addr_lat_scout),
      .scin(ex2_fpscr_addr_lat_scin),
      //-----------------
      .din({   ex1_fpscr_addr_din,
               ex1_cr_bf_din,
               ex1_instr_frt_din,
               ex1_instr_tid_din,
               exx_fpscr_din}),
      //-----------------
      .dout({  exx_fpscr_addr_q,
               exx_cr_bf_q,
               exx_instr_frt_q,
               exx_instr_tid_q,
               exx_fpscr_q})
   );

   //----------------------------------------------------------------------

   assign f_fmt_ex2_a_expo_div = (~f_fmt_ex2_a_expo_div_b);
   assign f_fmt_ex2_b_expo_div = (~f_fmt_ex2_b_expo_div_b);

   assign exx_a_sign_d = (f_fmt_ex2_a_sign_div & ex2_anydivsqrt) | (exx_a_sign_q & (~ex2_anydivsqrt));

   assign exx_a_biased_13exp_d = (f_fmt_ex2_a_expo_div & {13{ex2_anydivsqrt}}) |
                                 (exx_a_biased_13exp_q & {13{(~ex2_anydivsqrt)}});

   assign exx_a_fract_d = (f_fmt_ex2_a_frac_div & {52{ex2_anydivsqrt}}) |
                               (exx_a_fract_q & {52{(~ex2_anydivsqrt)}});

   assign ex2_a_zero = f_fmt_ex2_a_zero;
   assign ex2_a_SPunderflow_zero = (f_fmt_ex2_a_zero_dsq & ex2_sp) & (~f_fmt_ex2_a_zero);

   assign ex2_a_expo_max = f_fmt_ex2_a_expo_max;
   assign ex2_a_SPoverflow_expo_max = (f_fmt_ex2_a_expo_max_dsq & ex2_sp) & (~ex2_a_expo_max);

   assign ex2_a_frac_zero = f_fmt_ex2_a_frac_zero;

   assign exx_a_zero_d = (ex2_a_zero & ex2_anydivsqrt) | (exx_a_zero_q & (~ex2_anydivsqrt));
   assign exx_a_SPunderflow_zero_d = (ex2_a_SPunderflow_zero & ex2_anydivsqrt) | (exx_a_SPunderflow_zero_q & (~ex2_anydivsqrt));

   assign exx_a_expo_max_d = (ex2_a_expo_max & ex2_anydivsqrt) | (exx_a_expo_max_q & (~ex2_anydivsqrt));
   assign exx_a_SPoverflow_expo_max_d = (ex2_a_SPoverflow_expo_max & ex2_anydivsqrt) | (exx_a_SPoverflow_expo_max_q & (~ex2_anydivsqrt));

   assign exx_a_frac_zero_d = (ex2_a_frac_zero & ex2_anydivsqrt) | (exx_a_frac_zero_q & (~ex2_anydivsqrt));

   assign VE = exx_fpscr_q[0];
   assign OE = exx_fpscr_q[1];
   assign UE = exx_fpscr_q[2];
   assign ZE = exx_fpscr_q[3];
   assign XE = exx_fpscr_q[4];

   assign spare_unused[0] = XE;

   //---------------------------------------------------------------------

   tri_rlmreg_p #(.INIT(0), .WIDTH(71), .NEEDS_SRESET(0)) ex2_div_a_stage_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex2_div_a_stage_lat_scout),
      .scin(ex2_div_a_stage_lat_scin),
      //-----------------
      .din({
            exx_a_sign_d,
            exx_a_biased_13exp_d,
            exx_a_fract_d,
            exx_a_zero_d,
            exx_a_expo_max_d,
            exx_a_frac_zero_d,
            exx_a_SPunderflow_zero_d,
            exx_a_SPoverflow_expo_max_d}),

      //-----------------
      .dout({
               exx_a_sign_q,
               exx_a_biased_13exp_q,
               exx_a_fract_q,
               exx_a_zero_q,
               exx_a_expo_max_q,
               exx_a_frac_zero_q,
               exx_a_SPunderflow_zero_q,
               exx_a_SPoverflow_expo_max_q})
   );



   assign ex2_a_fract = f_fmt_ex2_a_frac_div[1:52];

   assign exx_b_sign_d = (f_fmt_ex2_b_sign_div & ex2_anydivsqrt) | (exx_b_sign_q & (~ex2_anydivsqrt));

   assign exx_b_biased_13exp_d = (f_fmt_ex2_b_expo_div & {13{ex2_anydivsqrt}}) |
                                 (exx_b_biased_13exp_q & {13{(~ex2_anydivsqrt)}});

   assign exx_b_fract_d = (f_fmt_ex2_b_frac_div & {52{ex2_anydivsqrt}}) |
                           (exx_b_fract_q & {52{(~ex2_anydivsqrt)}});

   assign ex2_b_zero = f_fmt_ex2_b_zero;
   assign ex2_b_SPunderflow_zero = (f_fmt_ex2_b_zero_dsq & ex2_sp) & (~f_fmt_ex2_b_zero);
   assign ex2_b_expo_max = f_fmt_ex2_b_expo_max;
   assign ex2_b_SPoverflow_expo_max = (f_fmt_ex2_b_expo_max_dsq & ex2_sp) & (~ex2_b_expo_max);

   assign ex2_b_frac_zero = f_fmt_ex2_b_frac_zero;

   assign exx_b_zero_d = (ex2_b_zero & ex2_anydivsqrt) | (exx_b_zero_q & (~ex2_anydivsqrt));
   assign exx_b_SPunderflow_zero_d = (ex2_b_SPunderflow_zero & ex2_anydivsqrt) | (exx_b_SPunderflow_zero_q & (~ex2_anydivsqrt));

   assign exx_b_expo_max_d = (ex2_b_expo_max & ex2_anydivsqrt) | (exx_b_expo_max_q & (~ex2_anydivsqrt));
   assign exx_b_SPoverflow_expo_max_d = (ex2_b_SPoverflow_expo_max & ex2_anydivsqrt) | (exx_b_SPoverflow_expo_max_q & (~ex2_anydivsqrt));

   assign exx_b_frac_zero_d = (ex2_b_frac_zero & ex2_anydivsqrt) | (exx_b_frac_zero_q & (~ex2_anydivsqrt));

   //---------------------------------------------------------------------

   tri_rlmreg_p #(.INIT(0), .WIDTH(71), .NEEDS_SRESET(0)) ex2_div_b_stage_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex2_div_b_stage_lat_scout),
      .scin(ex2_div_b_stage_lat_scin),
      //-----------------
      .din({
                exx_b_sign_d,
                exx_b_biased_13exp_d,
                exx_b_fract_d,
                exx_b_zero_d,
                exx_b_expo_max_d,
                exx_b_frac_zero_d,
                exx_b_SPunderflow_zero_d,
                exx_b_SPoverflow_expo_max_d}),
      //-----------------
      .dout({   exx_b_sign_q,
                exx_b_biased_13exp_q,
                exx_b_fract_q,
                exx_b_zero_q,
                exx_b_expo_max_q,
                exx_b_frac_zero_q,
                exx_b_SPunderflow_zero_q,
                exx_b_SPoverflow_expo_max_q})
   );


   assign ex2_b_fract = (f_fmt_ex2_b_frac_div[1:52]);

   //------------------------------------------------------------------------------
   // unbias the exponents
   //------------------------------------------------------------------------------
   // bias is DP, so subtract 1023

   assign exx_b_ubexp = exx_b_biased_13exp_q[1:13] + 13'b1110000000001;


   tri_rlmreg_p #(.INIT(0), .WIDTH(52), .NEEDS_SRESET(0)) ex2_div_exp_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex2_div_exp_lat_scout),
      .scin(ex2_div_exp_lat_scin),
      //-----------------
      .din({     exx_b_ubexp,
                 exx_exp_addres_div_x0,
                 exx_exp_addres_sqrt_x0,
                 exy_exp_addres_div_x0_m1
                 }),
      //-----------------
      .dout({    exy_b_ubexp,
                 exy_exp_addres_div_x0,
                 exy_exp_addres_sqrt_x0,
                 exz_exp_addres_div_x0_m1
                 })
   );

   //------------------------------------------------------------------------------
   // counter/state machine

   assign ex2_divsqrt_hole_v_b = (~f_dcd_ex2_divsqrt_hole_v);

   assign ex1_cycles_init = (ex1_div | ex1_divs | ex1_sqrt | ex1_sqrts) & (~n_flush);
   assign ex1_cycles_hold = (ex2_divsqrt_zero | (ex2_divsqrt_done & ex2_divsqrt_hole_v_b)) & (~ex1_cycles_init) & (~n_flush);
   assign ex1_cycles_decr = exx_divsqrt_running_q & (~ex1_cycles_hold) & (~ex1_cycles_init) & (~n_flush);
   assign ex1_cycles_clear = n_flush;

   //
   assign ex1_cycles_d = (ex1_op_cyc_count &             {8{ex1_cycles_init}})  |
                         (ex2_cycles_q &                 {8{ex1_cycles_hold}})  |
                         (8'b00000000 &                  {8{ex1_cycles_clear}}) |
                         ((ex2_cycles_q - 8'b00000001) & {8{ex1_cycles_decr}});

   assign ex2_divsqrt_zero = (ex2_cycles_q == 8'b00000000) ? 1'b1 :
                             1'b0;
   assign ex1_divsqrt_done = (ex2_cycles_q == 8'b00000010) ? 1'b1 :
                             1'b0;
   assign ex2_divsqrt_done = (ex2_cycles_q == 8'b00000001) ? 1'b1 :
                             1'b0;

   assign ex2_divsqrt_done_din = ex2_divsqrt_done & (~ex2_divsqrt_hole_v_b) & (~n_flush);

   assign ex2_waiting_for_hole = (ex2_divsqrt_done & ex2_divsqrt_hole_v_b) & (~ex1_cycles_init) & (~n_flush);

   assign ex2_hangcounter_incr = ex2_waiting_for_hole & (~ex3_hangcounter_trigger);
   assign ex2_hangcounter_clear = (ex2_divsqrt_done & (~ex2_divsqrt_hole_v_b)) | ex1_cycles_init | ex3_hangcounter_trigger | n_flush;

   assign ex3_hangcounter_trigger = (ex3_hangcounter_q == 8'b00100000) ? 1'b1 :
	                             1'b0;

   assign f_dsq_ex3_hangcounter_trigger = ex3_hangcounter_trigger;

   assign ex2_hangcounter_din  = (8'b00000000 &                       {8{ex2_hangcounter_clear}}) |
                                 ((ex3_hangcounter_q + 8'b00000001) & {8{ex2_hangcounter_incr}});
   assign ex1_divsqrt_running_d = ((ex1_div | ex1_divs | ex1_sqrt | ex1_sqrts) | exx_divsqrt_running_q) & (~(ex2_divsqrt_done_din | n_flush));

   assign exx_single_precision_d = ((ex1_divs | ex1_sqrts) | (exx_single_precision_q & (~ex1_anydivsqrt))) & (~(n_flush));

   assign exx_record_v_din = ((ex1_record_v & ex1_anydivsqrt) | (exx_record_v_q & (~ex1_anydivsqrt))) & (~(n_flush));

   assign ex4_sp = exx_single_precision_q;
   assign ex4_dp = (~exx_single_precision_q);
   assign exx_sp = exx_single_precision_q;
   assign exx_dp = (~exx_single_precision_q);

   assign exx_sqrt_d = ((ex1_sqrt | ex1_sqrts) | (exx_sqrt_q[0] & (~ex1_anydivsqrt))) & (~(n_flush));
   assign exx_div_d = ((ex1_div | ex1_divs)     | (exx_div_q[0] & (~ex1_anydivsqrt))) & (~(n_flush));


   tri_rlmreg_p #(.INIT(0), .WIDTH(8), .NEEDS_SRESET(1)) ex3_div_hangcounter_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex3_div_hangcounter_lat_scout),
      .scin(ex3_div_hangcounter_lat_scin),
      //-----------------
      .din({ex2_hangcounter_din}),
      //-----------------
      .dout({ex3_hangcounter_q})
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(19), .NEEDS_SRESET(1)) ex1_div_ctr_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex1_div_ctr_lat_scout),
      .scin(ex1_div_ctr_lat_scin),
      //-----------------
      .din({   ex1_cycles_d,
               ex1_divsqrt_running_d,
               exx_single_precision_d,
               exx_sqrt_d,
               exx_sqrt_d,
               exx_sqrt_d,
               exx_sqrt_d,
               exx_div_d,
               exx_div_d,
               exx_div_d,
               exx_div_d,
               exx_record_v_din}),
      //-----------------
      .dout({  ex2_cycles_q,
               exx_divsqrt_running_q,
               exx_single_precision_q,
               exx_sqrt_q[0:3],
               exx_div_q[0:3],
               exx_record_v_q})
   );

   //------------------------------------------------------------------------------
   // fraction path
   //------------------------------------------------------------------------------
   //-------------------------------------------------------------------
   // Initial 4-bit add and quotient select
   //-------------------------------------------------------------------

   assign exx_denom_d = (exx_denom_q &                          {56{(exx_divsqrt_running_q & (~ex2_anydivsqrt))}}) |
                        ({{({1'b1, ex2_b_fract, 3'b000})}}                             & {56{(ex2_anydivsqrt)}});

   //------------------------------------------------------------------------------------------------------------------------------------------------
   assign exx_PR_sum_shift = exx_PR_sum_final;

   assign ex2_PR_sum_sel0 = ex2_div_or_divs;		// initialize div
   assign ex2_PR_sum_sel1 = ex2_sqrt_or_sqrts & (~f_fmt_ex2_b_expo_div_b[13]);		// initialize sqrt, even exponent
   assign ex2_PR_sum_sel2 = ex2_sqrt_or_sqrts & f_fmt_ex2_b_expo_div_b[13];		// initialize sqrt, odd exponent
   assign ex2_PR_sum_sel3 = (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b));
   assign ex2_PR_sum_sel4 = ex2_divsqrt_done & ex2_divsqrt_hole_v_b;

   assign ex2_PR_sum_sel_late = ex2_PR_sum_sel3;
   assign ex2_PR_sum_sel_early = ex2_PR_sum_sel0 | ex2_PR_sum_sel1 | ex2_PR_sum_sel2 | ex2_PR_sum_sel4;

   // div
   // sqrt even exponent
   assign exx_PR_sum_d_early = (({4'b0001, ex2_a_fract[1:52], 1'b0}) & {57{ex2_PR_sum_sel0}}) |
                               (({4'b0001, ex2_b_fract[1:52], 1'b0}) & {57{ex2_PR_sum_sel1}}) |
                               (({3'b001, ex2_b_fract[1:52], 2'b00}) & {57{ex2_PR_sum_sel2}}) |
                               (exx_PR_sum_q &                         {57{ex2_PR_sum_sel4}});		// sqrt odd exponent
   // hold

   assign exx_PR_sum_d_late = exx_PR_sum_shift;

   assign exx_PR_sum_d = (exx_PR_sum_d_late &   {57{ex2_PR_sum_sel_late}}) |
                         (exx_PR_sum_d_early &  {57{ex2_PR_sum_sel_early}});

   assign exx_PR_carry_shift = exx_PR_carry_final;

   assign ex2_PR_carry_sel0 = ex2_anydivsqrt;
   assign ex2_PR_carry_sel1 = (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b));
   assign ex2_PR_carry_sel2 = ex2_divsqrt_done & ex2_divsqrt_hole_v_b;		// hold

   assign exx_PR_carry_d = ({57{1'b0}}                  & {57{ex2_PR_carry_sel0}}) |
                           (exx_PR_carry_shift &          {57{ex2_PR_carry_sel1}}) |
                           (exx_PR_carry_q &              {57{ex2_PR_carry_sel2}});


   tri_rlmreg_p #(.INIT(0), .WIDTH(114), .NEEDS_SRESET(0)) ex3_div_PR_sumcarry_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex3_div_PR_sumcarry_lat_scout),
      .scin(ex3_div_PR_sumcarry_lat_scin),
      //-----------------
      .din({exx_PR_sum_d, exx_PR_carry_d}),
      //-----------------
      .dout({exx_PR_sum_q, exx_PR_carry_q})
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(8), .NEEDS_SRESET(0)) ex3_div_PR_sum4carry4_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex3_div_PR_sum4carry4_lat_scout),
      .scin(ex3_div_PR_sum4carry4_lat_scin),
      //-----------------
      .din({exx_PR_sum_d[0:3],exx_PR_carry_d[0:3]}),
      //-----------------
      .dout({exx_PR_sum4_q, exx_PR_carry4_q })
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(114), .NEEDS_SRESET(0)) ex3_div_Q_QM_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex3_div_Q_QM_lat_scout),
      .scin(ex3_div_Q_QM_lat_scin),
      //-----------------
      .din({exx_Q_d, exx_QM_d }),
      //-----------------
      .dout({exx_Q_q, exx_QM_q})
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(114), .NEEDS_SRESET(0)) ex3_div_bQ_QM_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex3_div_bQ_QM_lat_scout),
      .scin(ex3_div_bQ_QM_lat_scin),
      //-----------------
      .din({exx_bQ_d, exx_bQM_d }),
      //-----------------
      .dout({exx_bQ_q,exx_bQM_q })
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(168), .NEEDS_SRESET(0)) ex3_sqrt_bitmask_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex3_sqrt_bitmask_lat_scout),
      .scin(ex3_sqrt_bitmask_lat_scin),
      //-----------------
      .din({exx_sqrt_newbitmask_din,
            exx_sqrt_Qbitmask_din,
            exx_sqrt_QMbitmask_din  }),
      //-----------------
      .dout({exx_sqrt_newbitmask_q,
             exx_sqrt_Qbitmask_q,
             exx_sqrt_QMbitmask_q })
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(56), .NEEDS_SRESET(0)) ex3_div_denom_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex3_denom_lat_scout),
      .scin(ex3_denom_lat_scin),
      //-----------------
      .din(exx_denom_d),
      //-----------------
      .dout(exx_denom_q)
   );

   //----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   fu_divsqrt_add4 lev0_add4(
      .x(exx_PR_sum4_q[0:3]),
      .y(exx_PR_carry4_q[0:3]),
      //------------------------------------------------------
      .s(exx_sum4)
   );

   assign exx_q_bit0_cin = exx_PR_sum_q[5] | exx_PR_carry_q[5];

   fu_divsqrt_q_table lev0_div_q_table(
      .x(exx_sum4[0:3]),
      .cin(exx_q_bit0_cin),
      //------------------------------------------------------
      .q(exx_q_bit0_prebuf)
   );

   fu_divsqrt_nq_table lev0_div_nq_table(
      .x(exx_sum4[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit0_prebuf)
   );


   assign exx_q_bit0_b = (~exx_q_bit0_prebuf);
   assign exx_nq_bit0_b = (~exx_nq_bit0_prebuf);

   assign exx_q_bit0 = (~exx_q_bit0_b);
   assign exx_nq_bit0 = (~exx_nq_bit0_b);

   //----------------------------------------------------------------------------------------------------------------------------------------------------

   //-------------------------------------------------------------------
   // on-the-fly quotient digit conversion logic for level 0
   //-------------------------------------------------------------------
   // Qin=(Q & q) if q >= 0.  Qin=(QM & 1) if q < 0

   assign exx_Qin_lev0_sel0 = exx_q_bit0 | ((~exx_nq_bit0));
   assign exx_Qin_lev0_sel1 = exx_nq_bit0;

   assign exx_Qin_lev0[0:56] = (({exx_Q_q[1:56], exx_q_bit0}) & {57{exx_Qin_lev0_sel0}}) |
                               (({exx_QM_q[1:56], 1'b1})      & {57{exx_Qin_lev0_sel1}});

   // QMin=(Q & 0) if q > 0. QMin=(QM & 0) if q < 0.  QMin=(QM & 1) if q = 0
   assign exx_QMin_lev0_sel0 = exx_q_bit0;
   assign exx_QMin_lev0_sel1 = exx_nq_bit0;
   assign exx_QMin_lev0_sel2 = (~(exx_nq_bit0 | exx_q_bit0));

   assign exx_QMin_lev0[0:56] = (({exx_Q_q[1:56], 1'b0}) &    {57{exx_QMin_lev0_sel0}}) |
                                (({exx_QM_q[1:56], 1'b0}) &   {57{exx_QMin_lev0_sel1}}) |
                                (({exx_QM_q[1:56], 1'b1}) &   {57{exx_QMin_lev0_sel2}});

   // massage Q and QM for use with square root
   //      sel_denom_pre1 = ~(((Q << 2) | 1) << 29-i);
   //      sel_denom_pre3 =  (((QM << 2) | 3) << 29-i);

   assign exx_sqrtlev0_Q[0:55] = exx_bQ_q_t[0:55];
   assign exx_sqrtlev0_MQ[0:55] = exx_bQM_q_t[0:55];
   //-------------------------------------------------------------------
   // Initial Denominator mux and 3:2 CSA
   //-------------------------------------------------------------------

   assign exx_PR_sum_q_shifted = {exx_PR_sum_q[1:56], 1'b0};
   assign exx_PR_carry_q_shifted = {exx_PR_carry_q[1:56], 1'b0};

   assign exx_lev0_selneg = exx_q_bit0 & (~exx_nq_bit0);

   assign exx_lev0_selD_b = (~(exx_nq_bit0 & exx_div_q[0]));
   assign exx_lev0_selnD_b = (~(exx_q_bit0 & exx_div_q[0]));
   assign exx_lev0_selD = (~exx_lev0_selD_b);
   assign exx_lev0_selnD = (~exx_lev0_selnD_b);

   assign exx_lev0_selQ_b = (~(exx_q_bit0 & exx_sqrt_q[0]));
   assign exx_lev0_selMQ_b = (~(exx_nq_bit0 & exx_sqrt_q[0]));
   assign exx_lev0_selQ = (~exx_lev0_selQ_b);
   assign exx_lev0_selMQ = (~exx_lev0_selMQ_b);

   assign exx_denomQ_lev0_nD_b = (~((~exx_denom_q) & {56{exx_lev0_selnD}}));
   assign exx_denomQ_lev0_D_b = (~(exx_denom_q & {56{exx_lev0_selD}}));
   assign exx_denomQ_lev0_Q_b = (~((~exx_sqrtlev0_Q) & {56{exx_lev0_selQ}}));
   assign exx_denomQ_lev0_MQ_b = (~(exx_sqrtlev0_MQ & {56{exx_lev0_selMQ}}));

   assign exx_denomQ_lev0 = (~(exx_denomQ_lev0_nD_b & exx_denomQ_lev0_D_b & exx_denomQ_lev0_Q_b & exx_denomQ_lev0_MQ_b));

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev0_div_csaout_sum(exx_lev0_csaoutsh_sum,
                                                              {exx_lev0_selneg, exx_denomQ_lev0},
                                                               exx_lev0_divsqrt_csaout_xor);

   assign exx_lev0_csaout_carryout = (({exx_lev0_selneg, exx_denomQ_lev0}) & exx_PR_sum_q_shifted) |
                                     (({exx_lev0_selneg, exx_denomQ_lev0}) & exx_PR_carry_q_shifted) |
                                     (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);

   assign exx_lev0_csaoutsh_carry[0:56] = {exx_lev0_csaout_carryout[1:56], exx_lev0_selneg};


   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev0_div_csaout_xor(exx_lev0_divsqrt_csaout_xor,
                                                               exx_PR_sum_q_shifted,
                                                               exx_PR_carry_q_shifted);

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev1_div_csaout_xor(exx_lev1_divsqrt_csaout_xor,
                                                               exx_PR_sum_q_shifted,
                                                               exx_PR_carry_q_shifted);

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev3_div_csaout_xor(exx_lev3_divsqrt_csaout_xor,
                                                               exx_PR_sum_q_shifted,
                                                               exx_PR_carry_q_shifted);


   //-------------------------------------------------------------------
   // Pick -d, 0, +d
   //-------------------------------------------------------------------
   // lev1: neg d, +q ========================================================
   assign exx_lev1_div_oper = ({1'b1, (~exx_denom_q)});
   assign exx_lev1_sqrt_oper = ({1'b1, (~exx_sqrtlev0_Q)});

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev1_div_csaout_sum(exx_lev1_div_csaout_sum,
                                                               exx_lev1_div_oper,
                                                               exx_lev1_divsqrt_csaout_xor);

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev1_sqrt_csaout_sum(exx_lev1_sqrt_csaout_sum,
								exx_lev1_sqrt_oper,
                                                                exx_lev1_divsqrt_csaout_xor);


   assign exx_lev1_div_csaout_carryout = (exx_lev1_div_oper & exx_PR_sum_q_shifted) | (exx_lev1_div_oper & exx_PR_carry_q_shifted) | (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);
   assign exx_lev1_sqrt_csaout_carryout = (exx_lev1_sqrt_oper & exx_PR_sum_q_shifted) | (exx_lev1_sqrt_oper & exx_PR_carry_q_shifted) | (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);

   assign exx_lev1_div_csaout_carry[0:56] = {exx_lev1_div_csaout_carryout[1:56], 1'b1};
   assign exx_lev1_sqrt_csaout_carry[0:56] = {exx_lev1_sqrt_csaout_carryout[1:56], 1'b1};

   fu_divsqrt_add4 lev1_div_add4(
      .x(exx_lev1_div_csaout_sum[0:3]),
      .y(exx_lev1_div_csaout_carry[0:3]),
      //------------------------------------------------------
      .s(exx_sum4_lev1_div)
   );

   fu_divsqrt_add4 lev1_sqrt_add4(
      .x(exx_lev1_sqrt_csaout_sum[0:3]),
      .y(exx_lev1_sqrt_csaout_carry[0:3]),
      //------------------------------------------------------
      .s(exx_sum4_lev1_sqrt)
   );

   assign exx_q_bit1_cin_div = exx_lev1_div_csaout_sum[5] | exx_lev1_div_csaout_carry[5];
   assign exx_q_bit1_cin_sqrt = exx_lev1_sqrt_csaout_sum[5] | exx_lev1_sqrt_csaout_carry[5];

   fu_divsqrt_q_table lev1_div_q_table(
      .x(exx_sum4_lev1_div[0:3]),
      .cin(exx_q_bit1_cin_div),
      //------------------------------------------------------
      .q(exx_q_bit1_div)
   );

   fu_divsqrt_q_table lev1_sqrt_q_table(
      .x(exx_sum4_lev1_sqrt[0:3]),
      .cin(exx_q_bit1_cin_sqrt ),
      //------------------------------------------------------
      .q(exx_q_bit1_sqrt)
   );

   fu_divsqrt_nq_table lev1_div_nq_table(
      .x(exx_sum4_lev1_div[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit1_div )
   );

   fu_divsqrt_nq_table lev1_sqrt_nq_table(
      .x(exx_sum4_lev1_sqrt[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit1_sqrt )
   );




   assign exx_notqornq_bit1_sqrt = ((exx_sum4_lev1_sqrt == 4'b0000) & (~exx_q_bit1_cin_sqrt)) |
	                            (exx_sum4_lev1_sqrt == 4'b1111) ;

   assign exx_notqornq_bit1_div =  ((exx_sum4_lev1_div == 4'b0000) & (~exx_q_bit1_cin_div)) |
	                            (exx_sum4_lev1_div == 4'b1111) ;



   assign exx_q_bit1 = (exx_q_bit1_div & exx_div_q[1]) | (exx_q_bit1_sqrt & exx_sqrt_q[1]);
   assign exx_nq_bit1 = (exx_nq_bit1_div & exx_div_q[1]) | (exx_nq_bit1_sqrt & exx_sqrt_q[1]);

   // zero: lev2  ===========================================================

   assign exx_lev2_csaout_sum = exx_PR_sum_q_shifted ^ exx_PR_carry_q_shifted;

   assign exx_lev2_csaout_carryout = (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);

   assign exx_lev2_csaout_carry[0:56] = {exx_lev2_csaout_carryout[1:56], 1'b0};

   fu_divsqrt_add4 lev2_add4(
      .x(exx_lev2_csaout_sum[0:3]),
      .y(exx_lev2_csaout_carry[0:3]),
      //------------------------------------------------------
      .s(exx_sum4_lev2)
   );

   assign exx_q_bit2_cin = exx_lev2_csaout_sum[5] | exx_lev2_csaout_carry[5];

     fu_divsqrt_q_table lev2_div_q_table(
      .x(exx_sum4_lev2[0:3]),
      .cin(exx_q_bit2_cin),
      //------------------------------------------------------
      .q(exx_q_bit2)
   );

   fu_divsqrt_nq_table lev2_nq_table(
      .x(exx_sum4_lev2[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit2 )
   );


   assign exx_notqornq_bit2 = ((exx_sum4_lev2 == 4'b0000) & (~exx_q_bit2_cin)) |
	                       (exx_sum4_lev2 == 4'b1111) ;




   // pos d, -q: lev3 =======================================================
   assign exx_lev3_div_oper = ({1'b0, exx_denom_q});
   assign exx_lev3_sqrt_oper = ({1'b0, exx_sqrtlev0_MQ});

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev3_div_csaout_sum(exx_lev3_div_csaout_sum,
                                                               exx_lev3_div_oper,
                                                               exx_lev3_divsqrt_csaout_xor);

   tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev3_sqrt_csaout_sum(exx_lev3_sqrt_csaout_sum,
								exx_lev3_sqrt_oper,
                                                                exx_lev3_divsqrt_csaout_xor);





   assign exx_lev3_div_csaout_carryout = (exx_lev3_div_oper & exx_PR_sum_q_shifted) | (exx_lev3_div_oper & exx_PR_carry_q_shifted) | (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);
   assign exx_lev3_sqrt_csaout_carryout = (exx_lev3_sqrt_oper & exx_PR_sum_q_shifted) | (exx_lev3_sqrt_oper & exx_PR_carry_q_shifted) | (exx_PR_sum_q_shifted & exx_PR_carry_q_shifted);

   assign exx_lev3_div_csaout_carry[0:56] = {exx_lev3_div_csaout_carryout[1:56], 1'b0};
   assign exx_lev3_sqrt_csaout_carry[0:56] = {exx_lev3_sqrt_csaout_carryout[1:56], 1'b0};

   fu_divsqrt_add4 lev3_div_add4(
      .x(exx_lev3_div_csaout_sum[0:3]),
      .y(exx_lev3_div_csaout_carry[0:3]),
      //------------------------------------------------------
      .s(exx_sum4_lev3_div)
   );

   fu_divsqrt_add4 lev3_sqrt_add4(
      .x(exx_lev3_sqrt_csaout_sum[0:3]),
      .y(exx_lev3_sqrt_csaout_carry[0:3]),
      //------------------------------------------------------
      .s(exx_sum4_lev3_sqrt)
   );

   assign exx_q_bit3_cin_div = exx_lev3_div_csaout_sum[5] | exx_lev3_div_csaout_carry[5];
   assign exx_q_bit3_cin_sqrt = exx_lev3_sqrt_csaout_sum[5] | exx_lev3_sqrt_csaout_carry[5];

   fu_divsqrt_q_table lev3_div_q_table(
      .x(exx_sum4_lev3_div[0:3]),
      .cin(exx_q_bit3_cin_div),
      //------------------------------------------------------
      .q(exx_q_bit3_div)
   );

   fu_divsqrt_q_table lev3_sqrt_q_table(
      .x(exx_sum4_lev3_sqrt[0:3]),
      .cin(exx_q_bit3_cin_sqrt),
      //------------------------------------------------------
      .q(exx_q_bit3_sqrt)
   );

   fu_divsqrt_nq_table lev3_div_nq_table(
      .x(exx_sum4_lev3_div[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit3_div )
   );

   fu_divsqrt_nq_table lev3_sqrt_nq_table(
      .x(exx_sum4_lev3_sqrt[0:3]),
      //------------------------------------------------------
      .nq(exx_nq_bit3_sqrt )
   );


   assign exx_notqornq_bit3_sqrt = ((exx_sum4_lev3_sqrt == 4'b0000) & (~exx_q_bit3_cin_sqrt)) |
	                            (exx_sum4_lev3_sqrt == 4'b1111) ;
   assign exx_notqornq_bit3_div =  ((exx_sum4_lev3_div == 4'b0000) & (~exx_q_bit3_cin_div)) |
	                            (exx_sum4_lev3_div == 4'b1111) ;



   assign exx_q_bit3 = (exx_q_bit3_div & exx_div_q[2]) | (exx_q_bit3_sqrt & exx_sqrt_q[2]);
   assign exx_nq_bit3 = (exx_nq_bit3_div & exx_div_q[2]) | (exx_nq_bit3_sqrt & exx_sqrt_q[2]);

   //-------------------------------------------------------------------
   // Mux between these three to get the next quotient bit
   //-------------------------------------------------------------------
   assign exx_q_bit22_sel = {exx_q_bit0, exx_nq_bit0};

   assign exx_q_bit22_sqrt = (exx_q_bit22_sel == 2'b10) ? exx_q_bit1_sqrt :
                             (exx_q_bit22_sel == 2'b00) ? exx_q_bit2 :
                             (exx_q_bit22_sel == 2'b01) ? exx_q_bit3_sqrt :
                             1'b0;

   assign exx_nq_bit22_sqrt = (exx_q_bit22_sel == 2'b10) ? exx_nq_bit1_sqrt :
                              (exx_q_bit22_sel == 2'b00) ? exx_nq_bit2 :
                              (exx_q_bit22_sel == 2'b01) ? exx_nq_bit3_sqrt :
                              1'b0;

   assign exx_notqornq_bit22_sqrt = (exx_q_bit22_sel == 2'b10) ? exx_notqornq_bit1_sqrt :
                                    (exx_q_bit22_sel == 2'b00) ? exx_notqornq_bit2 :
                                    (exx_q_bit22_sel == 2'b01) ? exx_notqornq_bit3_sqrt :
                                     1'b0;



   assign exx_q_bit22_div = (exx_q_bit22_sel == 2'b10) ? exx_q_bit1_div :
                            (exx_q_bit22_sel == 2'b00) ? exx_q_bit2 :
                            (exx_q_bit22_sel == 2'b01) ? exx_q_bit3_div :
                            1'b0;

   assign exx_nq_bit22_div = (exx_q_bit22_sel == 2'b10) ? exx_nq_bit1_div :
                             (exx_q_bit22_sel == 2'b00) ? exx_nq_bit2 :
                             (exx_q_bit22_sel == 2'b01) ? exx_nq_bit3_div :
                             1'b0;

   assign exx_notqornq_bit22_div  = (exx_q_bit22_sel == 2'b10) ? exx_notqornq_bit1_div :
                                    (exx_q_bit22_sel == 2'b00) ? exx_notqornq_bit2 :
                                    (exx_q_bit22_sel == 2'b01) ? exx_notqornq_bit3_div :
                                     1'b0;



   assign exx_q_bit22 = (exx_q_bit22_div & exx_div_q[2]) | (exx_q_bit22_sqrt & exx_sqrt_q[2]);
   assign exx_nq_bit22 = (exx_nq_bit22_div & exx_div_q[2]) | (exx_nq_bit22_sqrt & exx_sqrt_q[2]);

   // massage Q and QM for use with square root
   //      sel_denom_pre1 = ~(((Q << 2) | 1) << 29-i);
   //      sel_denom_pre3 =  (((QM << 2) | 3) << 29-i);
   //      sel_denom_1 = ~(((Q << 2) | 1) << 28-i);
   //      sel_denom_3 =  (((QM << 2) | 3) << 28-i);

   assign exx_bQin_lev0[0:55] = ((exx_bQ_q[0:55]) & {56{exx_Qin_lev0_sel0}}) |
                               ((exx_bQM_q[0:55]) & {56{exx_Qin_lev0_sel1}});

   assign exx_bQMin_lev0[0:55] = ((exx_bQ_q[0:55]) & {56{exx_QMin_lev0_sel0}}) |
                                 ((exx_bQM_q[0:55]) & {56{(~exx_QMin_lev0_sel0)}});

   assign exx_bQin_lev0_t[0:55] = exx_bQin_lev0 | ({exx_sqrt_Qbitmask_q[1:55], 1'b0});
   assign exx_bQMin_lev0_t[0:55] = exx_bQMin_lev0 | ({exx_sqrt_QMbitmask_q[1:55], 1'b0});

   assign exx_sqrtlev22_Q[0:55] = (exx_sqrt_Qmaskvec[0:55] & exx_sqrt_newbitmask_q[0:55]) |
                                      ({56{1'b1}} & exx_sqrt_Qbitmask_q[0:55]) |
                                      (exx_bQin_lev0_t[0:55] & (~(exx_sqrt_newbitmask_q[0:55] | exx_sqrt_QMbitmask_q[0:55])));		// need QM for 3 bit mask

   assign exx_sqrtlev22_MQ[0:55] = (exx_sqrt_QMmaskvec[0:55] & exx_sqrt_newbitmask_q[0:55]) |
                                      ({56{1'b1}} & exx_sqrt_QMbitmask_q[0:55]) |
                                      (exx_bQMin_lev0_t[0:55] & (~(exx_sqrt_newbitmask_q[0:55] | exx_sqrt_QMbitmask_q[0:55])));

   assign exx_sqrt_Qmaskvec[0:55] = {56{wQ}};

   assign exx_sqrt_QMmaskvec[0:55] = {56{wMQ}};

   assign wQ = exx_Qin_lev0[56];
   assign wMQ = exx_QMin_lev0[56];

   //-------------------------------------------------------------------
   // Final Denominator mux and 3:2 CSA
   //-------------------------------------------------------------------
   // shift left by 1 again
   assign exx_lev0_csaout_sum[0:56] = {exx_lev0_csaoutsh_sum[1:56], 1'b0};
   assign exx_lev0_csaout_carry[0:56] = {exx_lev0_csaoutsh_carry[1:56], 1'b0};

   assign exx_lev22_selneg = exx_q_bit22;               //exx_q_bit22 & (~exx_nq_bit22);
   assign exx_lev22_selD = exx_nq_bit22_div;		// and not exx_q_bit22_div and exx_div_q(0);
   assign exx_lev22_selnD = exx_q_bit22_div;		// and not exx_nq_bit22_div and exx_div_q(0);

   assign exx_lev22_selQ = exx_q_bit22_sqrt;		// and not exx_nq_bit22_sqrt and exx_sqrt_q(0);
   assign exx_lev22_selMQ = exx_nq_bit22_sqrt;		// and not exx_q_bit22_sqrt and exx_sqrt_q(0);

   assign exx_denomQ_lev22_div = ((~exx_denom_q) & {56{exx_lev22_selnD}}) |
                                 (exx_denom_q &    {56{exx_lev22_selD}});

   assign exx_denomQ_lev22_sqrt = ((~exx_sqrtlev22_Q) & {56{exx_lev22_selQ}}) |
                                 (exx_sqrtlev22_MQ & {56{exx_lev22_selMQ}});

      tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev22_csaout_sum_xor(exx_lev22_csaout_sum_xor,
                                                                   exx_lev0_csaout_sum,
                                                                   exx_lev0_csaout_carry );

      tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev22_csaout_sum_div(exx_lev22_csaout_sum_div,
                                                                  {exx_lev22_selneg, exx_denomQ_lev22_div},
                                                                   exx_lev22_csaout_sum_xor  );

      tri_xor2 #(.WIDTH(57)) DIVSQRT_XOR2_exx_lev22_csaout_sum_sqrt(exx_lev22_csaout_sum_sqrt,
                                                                   {exx_lev22_selneg, exx_denomQ_lev22_sqrt},
                                                                    exx_lev22_csaout_sum_xor );


   assign exx_lev22_csaout_carryout_div = (({exx_lev22_selneg, exx_denomQ_lev22_div}) & exx_lev0_csaout_sum) |
                                          (({exx_lev22_selneg, exx_denomQ_lev22_div}) & exx_lev0_csaout_carry) |
                                          (exx_lev0_csaout_sum & exx_lev0_csaout_carry);

   assign exx_lev22_csaout_carryout_sqrt = (({exx_lev22_selneg, exx_denomQ_lev22_sqrt}) & exx_lev0_csaout_sum) |
                                          (({exx_lev22_selneg, exx_denomQ_lev22_sqrt}) & exx_lev0_csaout_carry) |
                                          (exx_lev0_csaout_sum & exx_lev0_csaout_carry);

   assign exx_lev22_csaout_carry_div[0:56] = {exx_lev22_csaout_carryout_div[1:56], exx_lev22_selneg};
   assign exx_lev22_csaout_carry_sqrt[0:56] = {exx_lev22_csaout_carryout_sqrt[1:56], exx_lev22_selneg};

   assign exx_PR_sum_final = (exx_lev22_csaout_sum_div & {57{exx_div_q[0]}}) |
                             (exx_lev22_csaout_sum_sqrt & {57{exx_sqrt_q[0]}});
   assign exx_PR_carry_final = (exx_lev22_csaout_carry_div & {57{exx_div_q[0]}}) |
                               (exx_lev22_csaout_carry_sqrt & {57{exx_sqrt_q[0]}});

   //-------------------------------------------------------------------
   // on-the-fly quotient digit conversion logic
   //-------------------------------------------------------------------
   // Qin=(Q & q) if q >= 0.  Qin=(QM & 1) if q < 0
   //timing: split out seperate sqrt Q latch?

   assign exx_Qin_lev1_sel0_div = (~exx_nq_bit22_div); // (exx_q_bit22_div | ((~exx_nq_bit22_div)));this combination will never be 11
   assign exx_Qin_lev1_sel1_div = exx_nq_bit22_div;
   assign exx_Qin_lev1_sel0_sqrt = (~exx_nq_bit22_sqrt); // (exx_q_bit22_sqrt | ((~exx_nq_bit22_sqrt))); this combination will never be 11
   assign exx_Qin_lev1_sel1_sqrt = exx_nq_bit22_sqrt;

   assign exx_Qin_lev1_div[0:56] = (({exx_Qin_lev0[1:56], exx_q_bit22_div}) & {57{exx_Qin_lev1_sel0_div}}) |
                                   (({exx_QMin_lev0[1:56], 1'b1}) &           {57{exx_Qin_lev1_sel1_div}});
   assign exx_Qin_lev1_sqrt[0:56] = (({exx_Qin_lev0[1:56], exx_q_bit22_sqrt}) & {57{exx_Qin_lev1_sel0_sqrt}}) |
                                    (({exx_QMin_lev0[1:56], 1'b1}) &            {57{exx_Qin_lev1_sel1_sqrt}});

   // QMin=(Q & 0) if q > 0. QMin=(QM & 0) if q < 0.  QMin=(QM & 1) if q = 0
   assign exx_QMin_lev1_sel0_div = exx_q_bit22_div;
   assign exx_QMin_lev1_sel1_div = exx_nq_bit22_div;
   assign exx_QMin_lev1_sel2_div = exx_notqornq_bit22_div; //((~(exx_nq_bit22_div | exx_q_bit22_div)));
   assign exx_QMin_lev1_sel0_sqrt = exx_q_bit22_sqrt;
   assign exx_QMin_lev1_sel1_sqrt = exx_nq_bit22_sqrt;
   assign exx_QMin_lev1_sel2_sqrt = exx_notqornq_bit22_sqrt;

   assign exx_QMin_lev1_div[0:56] = (({exx_Qin_lev0[1:56], 1'b0}) & {57{exx_QMin_lev1_sel0_div}}) |
                                   (({exx_QMin_lev0[1:56], 1'b0}) & {57{exx_QMin_lev1_sel1_div}}) |
                                   (({exx_QMin_lev0[1:56], 1'b1}) & {57{exx_QMin_lev1_sel2_div}});

   assign exx_QMin_lev1_sqrt[0:56] = (({exx_Qin_lev0[1:56], 1'b0}) & {57{exx_QMin_lev1_sel0_sqrt}}) |
                                    (({exx_QMin_lev0[1:56], 1'b0}) & {57{exx_QMin_lev1_sel1_sqrt}}) |
                                    (({exx_QMin_lev0[1:56], 1'b1}) & {57{exx_QMin_lev1_sel2_sqrt}});

   assign exx_Q_d = (exx_Qin_lev1_div & {57{(exx_div_q[0] & exx_divsqrt_running_q & (~ex3_divsqrt_done) & (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)))}}) |    // normal running mode
                    (exx_Qin_lev1_sqrt & {57{(exx_sqrt_q[0] & exx_divsqrt_running_q & (~ex3_divsqrt_done) & (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)))}}) |    // normal running mode
                    (exx_Q_q &                                 {57{(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)}}) |    // hold
                    (exx_Q_q &                                     {57{(ex3_divsqrt_done & (~ex2_anydivsqrt))}}) | 	// hold for rounding
                    ({57{1'b0}} &                               {57{ex2_anydivsqrt}});                                                     // init


   assign exx_QM_d = (exx_QMin_lev1_div & {57{(exx_div_q[0] & exx_divsqrt_running_q & (~ex3_divsqrt_done) & (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)))}}) |
                     (exx_QMin_lev1_sqrt & {57{(exx_sqrt_q[0] & exx_divsqrt_running_q & (~ex3_divsqrt_done) & (~ex2_anydivsqrt) & (~(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)))}}) |
                     (exx_QM_q & {57{(ex2_divsqrt_done & ex2_divsqrt_hole_v_b)}}) |
                     (exx_QM_q & {57{(ex3_divsqrt_done & (~ex2_anydivsqrt))}}) |
                     ({57{1'b1}} & {57{ex2_anydivsqrt}});		// hold for rounding

   //-------------------------------------------------------------------------------------------------------------
   // massage Q and QM for use with square root
   //      sel_denom_pre1 = ~(((Q << 2) | 1) << 29-i);
   //      sel_denom_pre3 =  (((QM << 2) | 3) << 29-i);

   //          sel_denom_1 = ~(((Q << 2) | 1) << 28-i);
   //          sel_denom_3 = ((QM << 2) | 3) << 28-i;

   // left justify Q, QM and append 01, 11 for use in square root


   //---------------------------------------------------------------------------------------------------------------------------------------------------------------------

   assign exx_bQ_q_t = exx_bQ_q[00:56] | ({exx_sqrt_Qbitmask_q[1:55], 2'b00});
   assign exx_bQM_q_t = exx_bQM_q[00:56] | ({exx_sqrt_QMbitmask_q[1:55], 2'b00});


   assign exx_bQin_lev1_sqrt[0:56] = (({exx_bQin_lev0[00:55], 1'b0}) & {57{exx_Qin_lev1_sel0_sqrt}}) |
                                    (({exx_bQMin_lev0[00:55], 1'b0}) & {57{exx_Qin_lev1_sel1_sqrt}});

   assign exx_bQMin_lev1_sqrt[0:56] = (({exx_bQin_lev0[00:55], 1'b0}) & {57{exx_QMin_lev1_sel0_sqrt}}) |
                                     (({exx_bQMin_lev0[00:55], 1'b0}) & {57{exx_QMin_lev1_sel1_sqrt}}) |
                                     (({exx_bQMin_lev0[00:55], 1'b0}) & {57{exx_QMin_lev1_sel2_sqrt}});

   // lev0
   assign exx_bQ_d[00:56] = (({exx_sqrt_newbitmask_q[0:55], 1'b0}) &           {57{exx_Qin_lev1_sqrt[55]}}) |
                             (({1'b0, exx_sqrt_newbitmask_q[0:55]}) &          {57{exx_Qin_lev1_sqrt[56]}}) |
                             ((exx_bQin_lev1_sqrt) &                           {57{(exx_divsqrt_running_q &  (~ex2_anydivsqrt))}});		// lev1

   // lev0
   assign exx_bQM_d[00:56] = (({exx_sqrt_newbitmask_q[0:55], 1'b0}) &                            {57{exx_QMin_lev1_sqrt[55]}}) |
                             ({{({1'b0, exx_sqrt_newbitmask_q[0:55]})}} &                        {57{exx_QMin_lev1_sqrt[56]}}) |
                             ((exx_bQMin_lev1_sqrt) &                         {57{(exx_divsqrt_running_q & (~ex2_anydivsqrt))}});		// lev1

   assign exx_sqrt_newbitmask_din[0:55] = (({2'b00, exx_sqrt_newbitmask_q[0:53]}) & {56{(exx_divsqrt_running_q & (~ex2_anydivsqrt))}}) |
                                          ({{({1'b1, zeros[1:55]})}}              & {56{ex2_anydivsqrt}});

   assign exx_sqrt_Qbitmask_din[0:55] = (({2'b00, exx_sqrt_Qbitmask_q[0:53]}) & {56{(exx_divsqrt_running_q & (~ex2_anydivsqrt))}}) |
                                        (({3'b001, zeros[3:55]})             & {56{ex2_anydivsqrt}});

   assign exx_sqrt_QMbitmask_din[0:55] = (({2'b00, exx_sqrt_QMbitmask_q[0:53]}) & {56{(exx_divsqrt_running_q & (~ex2_anydivsqrt))}}) |
                                        (({3'b011, zeros[3:55]})                                         & {56{ex2_anydivsqrt}});

   // todo: probably don't need both newbitmask and Qbitmask
   //-------------------------------------------------------------------
   //
   //-------------------------------------------------------------------

   //-------------------------------------------------------------------
   // exponent logic
   //-------------------------------------------------------------------
   assign exx_exp_adj[1:13] = (13'b1111111111111 & {13{(ex4_norm_shl1_d)}}) |
                            (13'b0000000000000 & {13{(~(ex4_norm_shl1_d))}});

   assign exx_exp_addres_div_x0 = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]);

   assign exy_exp_addres_div_x0_m1 = exy_exp_addres_div_x0 - 13'b0000000000001;
   assign exz_exp_addres_div_x0_adj = (exz_exp_addres_div_x0_m1 & {13{(ex4_norm_shl1_d)}}) |
                                      (exy_exp_addres_div_x0 & {13{((~ex4_norm_shl1_d))}});

   assign exx_exp_addres_sqrt_x0 = ({exy_b_ubexp[1], exy_b_ubexp[1:12]}) + 13'b0001111111111;

   assign exz_exp_addres_x0 = (exz_exp_addres_div_x0_adj & {13{exx_div_q[0]}}) |
                              (exy_exp_addres_sqrt_x0 &    {13{exx_sqrt_q[0]}});

   assign exx_exp_addres_ux = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]) + (exx_exp_adj[1:13]) + exx_exp_ux_adj;

   assign exx_exp_addres_ox = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]) + (exx_exp_adj[1:13]) + exx_exp_ox_adj;

   assign exx_exp_adj_p1[1:13] = (13'b0000000000000 & {13{(ex4_norm_shl1_d)}}) |
                                 (13'b0000000000001 & {13{(~(ex4_norm_shl1_d))}});

   assign exx_exp_addres_div_x0_p1 = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]) + (exx_exp_adj_p1[1:13]);

   assign exx_exp_addres_sqrt_x0_p1 = ({exy_b_ubexp[1], exy_b_ubexp[1:12]}) + 13'b0010000000000;

   assign exx_exp_addres_x0_p1 = (exx_exp_addres_div_x0_p1 &  {13{exx_div_q[0]}}) |
                                 (exx_exp_addres_sqrt_x0_p1 & {13{exx_sqrt_q[0]}});

   assign exx_exp_addres_ux_p1 = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]) + (exx_exp_adj_p1[1:13]) + exx_exp_ux_adj;

   assign exx_exp_addres_ox_p1 = (exx_a_biased_13exp_q) - (exy_b_ubexp[1:13]) + (exx_exp_adj_p1[1:13]) + exx_exp_ox_adj;

   assign ueux = (underflow & (~special_force_zero)) & UE;
   assign oeox = (overflow & (~exx_hard_spec_case)) & OE;
   assign zezx = ex4_div_by_zero_zx & ZE;
   assign vevx = (ex4_zero_div_zero | ex4_inf_div_inf | ex4_sqrt_neg | ex4_snan) & VE;

   assign not_ueux_or_oeox = ~(ueux | oeox);

   assign exx_exp_addres = (exz_exp_addres_x0 & {13{(~(ueux | oeox))}}) |
                           (exx_exp_addres_ux & {13{ueux}}) |
                           (exx_exp_addres_ox & {13{oeox}});

   assign ex4_expresult_zero = (~|(exz_exp_addres_x0)); //or_reduce

   //
   assign exx_exp_ux_adj_dp = 13'b0011000000000;		// 1536
   assign exx_exp_ux_adj_sp = 13'b0000011000000;		// 192
   assign exx_exp_ox_adj_dp = 13'b1101000000000;		// -1536
   assign exx_exp_ox_adj_sp = 13'b1111101000000;		// -192

   assign exx_exp_ux_adj = (exx_exp_ux_adj_dp & {13{exx_dp}}) |
                           (exx_exp_ux_adj_sp & {13{exx_sp}});

   assign exx_exp_ox_adj = (exx_exp_ox_adj_dp & {13{exx_dp}}) |
                           (exx_exp_ox_adj_sp & {13{exx_sp}});

   // underflow
   assign underflow_dp = exz_exp_addres_x0[0] | ex4_expresult_zero;

   // neg
   // < -127+1023 0b000000xxxxxxx
   assign underflow_sp = (exz_exp_addres_x0[0]) | (((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & (~exz_exp_addres_x0[2]) & (~exz_exp_addres_x0[3]) & (~exz_exp_addres_x0[4]) & (~exz_exp_addres_x0[5])) & (exz_exp_addres_x0[6] | exz_exp_addres_x0[7] | exz_exp_addres_x0[8] | exz_exp_addres_x0[9] | exz_exp_addres_x0[10] | exz_exp_addres_x0[11] | exz_exp_addres_x0[12])) | (((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & (~exz_exp_addres_x0[2])) & (((exz_exp_addres_x0[3] | exz_exp_addres_x0[4]) & (~exz_exp_addres_x0[5])) | ((exz_exp_addres_x0[5] | exz_exp_addres_x0[3]) & (~exz_exp_addres_x0[4])) | ((exz_exp_addres_x0[4] | exz_exp_addres_x0[5]) & (~exz_exp_addres_x0[3])))) | ((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & (~exz_exp_addres_x0[2]) & exz_exp_addres_x0[3] & exz_exp_addres_x0[4] & exz_exp_addres_x0[5] & (~exz_exp_addres_x0[6]) & (~exz_exp_addres_x0[7]) & (~exz_exp_addres_x0[8]) & (~exz_exp_addres_x0[9]) & (~exz_exp_addres_x0[10]) & (~exz_exp_addres_x0[11]) & (~exz_exp_addres_x0[12]));		// < -127+1023 0b000xxxXXXXXXX
   // -127+1023 0b0001110000000

   assign underflow_denorm_dp = (denorm_sticky | exx_divsqrt_fract_q[53]);		// guard bit also
   assign underflow_denorm_sp = (denorm_sticky_sp | guard_dnr_sp | round_dnr_sp);

   assign underflow_denorm = (underflow_denorm_dp & exx_dp) | (underflow_denorm_sp & exx_sp);

   assign underflow_fi = (underflow & (~ex4_denormalizing_result_done)) | (underflow_denorm & ex4_denormalizing_result_done);

   // overflow
   assign sp_overflow_brink_x47E =  ((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & exz_exp_addres_x0[2] &
                                    (~exz_exp_addres_x0[3]) & (~exz_exp_addres_x0[4]) & (~exz_exp_addres_x0[5]) &
                                     exz_exp_addres_x0[6] & exz_exp_addres_x0[7] & exz_exp_addres_x0[8] & exz_exp_addres_x0[9] & exz_exp_addres_x0[10] & exz_exp_addres_x0[11] & (~exz_exp_addres_x0[12]));
                                                                                                   // 0b0010001111110 128+1023-1

   assign ex4_incexp_to_sp_overflow = ex4_divsqrt_fract_rounded[0] & sp_overflow_brink_x47E & exx_sp;		// rounded up past the implicit bit (which is bit 1 here) and into sp overflow

   assign dp_overflow_brink_x7FE = ((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) &
                                    exz_exp_addres_x0[2] & exz_exp_addres_x0[3] & exz_exp_addres_x0[4] & exz_exp_addres_x0[5] & exz_exp_addres_x0[6] & exz_exp_addres_x0[7] & exz_exp_addres_x0[8] & exz_exp_addres_x0[9] & exz_exp_addres_x0[10] & exz_exp_addres_x0[11] & (~exz_exp_addres_x0[12]));		// 0b0011111111110 1024+1023-1

   assign ex4_incexp_to_dp_overflow = ex4_divsqrt_fract_rounded[0] & dp_overflow_brink_x7FE & exx_dp;

   assign ex4_incexp_to_overflow = ex4_incexp_to_sp_overflow | ex4_incexp_to_dp_overflow;


   assign overflow_dp = ex4_incexp_to_dp_overflow |
                        (((~exz_exp_addres_x0[0]) & exz_exp_addres_x0[1]) |    //  0b01XXXXXXXXXXX > 1024+1023
                        ((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) &
                         exz_exp_addres_x0[2] & exz_exp_addres_x0[3] & exz_exp_addres_x0[4] & exz_exp_addres_x0[5] & exz_exp_addres_x0[6] & exz_exp_addres_x0[7] & exz_exp_addres_x0[8] & exz_exp_addres_x0[9] & exz_exp_addres_x0[10] & exz_exp_addres_x0[11] & exz_exp_addres_x0[12]));		// 0b0011111111111 1024+1023


   assign overflow_sp = ex4_incexp_to_sp_overflow |
                       ((((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & exz_exp_addres_x0[2]) &
                           (exz_exp_addres_x0[3] | exz_exp_addres_x0[4] | exz_exp_addres_x0[5])) | // 0b001xxxXXXXXXX > 128+1023
                        (((~exz_exp_addres_x0[0]) & exz_exp_addres_x0[1])) |                       // 0b01xxxxXXXXXXX > 128+1023
                        ((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) & exz_exp_addres_x0[2] & (~exz_exp_addres_x0[3]) & (~exz_exp_addres_x0[4]) & (~exz_exp_addres_x0[5]) & exz_exp_addres_x0[6] & exz_exp_addres_x0[7] & exz_exp_addres_x0[8] & exz_exp_addres_x0[9] & exz_exp_addres_x0[10] & exz_exp_addres_x0[11] & exz_exp_addres_x0[12]));
                                                                                                   // 0b0010001111111 128+1023


   assign overflow = (overflow_sp & exx_sp) | (overflow_dp & exx_dp);

   assign underflow = (underflow_sp & exx_sp) | (underflow_dp & exx_dp);

   //-------------------------------------------------------------------
   // result staging latch
   //-------------------------------------------------------------------
   assign ex3_divsqrt_done_din = ex3_divsqrt_done & (~n_flush);
   assign ex4_divsqrt_done_din = ex4_divsqrt_done & (~n_flush);
   assign ex5_divsqrt_done_din = ex5_divsqrt_done & (~n_flush);


   tri_rlmreg_p #(.INIT(0), .WIDTH(4), .NEEDS_SRESET(0)) ex4_div_done_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex5_div_done_lat_scout),
      .scin(ex5_div_done_lat_scin),
      //-----------------
      .din({   ex2_divsqrt_done_din,
               ex3_divsqrt_done_din,
               ex4_divsqrt_done_din,
               ex5_divsqrt_done_din}),
      //-----------------
      .dout({  ex3_divsqrt_done,
               ex4_divsqrt_done_q,
               ex5_divsqrt_done,
               ex6_divsqrt_done})
   );

   //------------------------------------------------------------------------------------------------------------------------------------
   // final fixup stages: normalize, round, final staging

   // generate the remainder
   assign ex3_divsqrt_remainder[00:56] = exx_PR_sum_q[0:56] + exx_PR_carry_q[0:56];

   //-----------------------------------------------------------------------
   assign ex4_divsqrt_remainder[00:56] = exx_divsqrt_fract_q[00:56];

   assign ex4_rem_neg_buf[00:14] = {15{ex4_rem_neg[0]}};
   assign ex4_rem_neg_buf[15:28] = {14{ex4_rem_neg[1]}};
   assign ex4_rem_neg_buf[29:42] = {14{ex4_rem_neg[2]}};
   assign ex4_rem_neg_buf[43:56] = {14{ex4_rem_neg[3]}};

   assign ex4_rem_neg_buf_b[00:14] = {15{ex4_rem_neg_b[0]}};
   assign ex4_rem_neg_buf_b[15:28] = {14{ex4_rem_neg_b[1]}};
   assign ex4_rem_neg_buf_b[29:42] = {14{ex4_rem_neg_b[2]}};
   assign ex4_rem_neg_buf_b[43:56] = {14{ex4_rem_neg_b[3]}};


   //assign ex4_rem_neg = ex4_divsqrt_remainder[00];
   assign ex4_rem_nonzero = |(ex4_divsqrt_remainder[00:56]); // or_reduce
   assign ex4_rem_nonzero_fi = (ex4_rem_nonzero | ex4_sp_inexact_roundbits) & (~ex4_denormalizing_result_done);

   assign ex4_divsqrt_fract_preround_prenorm[00:56] = (exx_Q_q[00:56] &   ex4_rem_neg_buf_b ) |
                                                      (exx_QM_q[00:56] &  ex4_rem_neg_buf   );

   assign ex4_norm_shl1_test = (((~ex4_divsqrt_fract_preround_prenorm[00])) & exx_dp) | (((~ex4_divsqrt_fract_preround_prenorm[28])) & exx_sp);		// normalize

   assign ex3_norm_shl1_dp = (exx_Q_d[0] & (~ex3_divsqrt_remainder[0])) | (exx_QM_d[0] & ex3_divsqrt_remainder[0]);
   assign ex3_norm_shl1_sp = (exx_Q_d[28] & (~ex3_divsqrt_remainder[0])) | (exx_QM_d[28] & ex3_divsqrt_remainder[0]);

   assign ex3_norm_shl1 = (~((ex3_norm_shl1_dp & exx_dp) | (ex3_norm_shl1_sp & exx_sp)));

   assign ex4_norm_shl1_d = ((ex4_norm_shl1 & ex4_divsqrt_done_q) | ex4_norm_shl1_q) & (~(n_flush | ex2_anydivsqrt | ex6_divsqrt_done));

   assign ex4_divsqrt_fract_preround[00:56] = (ex4_divsqrt_fract_preround_prenorm[00:56] &       {57{(~ex4_norm_shl1)}}) |
                                              ({ex4_divsqrt_fract_preround_prenorm[01:56], 1'b0} & {57{ex4_norm_shl1}});

   assign ex4_divsqrt_fract_p0_dp = {1'b0, ex4_divsqrt_fract_preround[00:52]};
   assign ex4_divsqrt_fract_p1_dp = ({1'b0, ex4_divsqrt_fract_preround[00:52]}) + ({{53{1'b0}}, 1'b1});

   assign ex4_divsqrt_fract_p0_sp = {1'b0, ex4_divsqrt_fract_preround[28:51], {29{1'b0}}};
   assign ex4_divsqrt_fract_p1_sp = ({1'b0, ex4_divsqrt_fract_preround[28:51], {29{1'b0}}}) +
				    ({{24{1'b0}}, 1'b1, {29{1'b0}}});

   assign HW165073_bits = (ex4_divsqrt_fract_preround_prenorm[52:56] == 5'b10000) ? 1'b1 :
                                                                                    1'b0;

   assign HW165073_hit = HW165073_bits & exx_sp & ex4_divsqrt_done & ex4_norm_shl1;
   assign spare_unused[1] = HW165073_hit;
   assign ex4_sp_inexact_roundbits = |(ex4_divsqrt_fract_preround[52:56]) & ex4_sp; // or_reduce

   assign ex4_divsqrt_fract_p0 = (ex4_divsqrt_fract_p0_sp & {54{exx_sp}}) |
                                 (ex4_divsqrt_fract_p0_dp & {54{exx_dp}});
   assign ex4_divsqrt_fract_p1 = (ex4_divsqrt_fract_p1_sp & {54{exx_sp}}) |
                                 (ex4_divsqrt_fract_p1_dp & {54{exx_dp}});

   assign sign = ex4_divsqrt_sign;		//exx_divsqrt_sign_d;

   assign lsb = (ex4_divsqrt_fract_preround[52] & ex4_dp) | (ex4_divsqrt_fract_preround[51] & ex4_sp);

   assign guard = (ex4_divsqrt_fract_preround[53] & ex4_dp) | (ex4_divsqrt_fract_preround[52] & ex4_sp);

   assign round = sticky | ((ex4_divsqrt_fract_preround[54] & ex4_dp) | (ex4_divsqrt_fract_preround[53] & ex4_sp));

   assign sticky = ex4_rem_nonzero;

   assign sticky_w_underflow = ex4_rem_nonzero | (underflow & (~exx_hard_spec_case) & (~UE));


   assign RNEmode = (~exx_fpscr_q[5]) & (~exx_fpscr_q[6]);		// 00
   assign RTZmode = (~exx_fpscr_q[5]) & exx_fpscr_q[6];		// 01
   assign RPImode = exx_fpscr_q[5] & (~exx_fpscr_q[6]);		// 10
   assign RNImode = exx_fpscr_q[5] & exx_fpscr_q[6];		// 11

   assign ex4_round_up = ((guard & (lsb | round)) & RNEmode) | ((1'b0) & RTZmode) | (((guard | round) & (~sign)) & RPImode) | (((guard | round) & sign) & RNImode);		// round to nearest mode

   assign ex4_round_up_underflow = (((sticky_w_underflow) & (~sign)) & RPImode) | (((sticky_w_underflow) & sign) & RNImode);

   //timing todo: don't need this whole vector
   assign ex4_divsqrt_fract_rounded = (ex4_divsqrt_fract_p0 & {54{(~ex4_round_up)}}) |
                                      (ex4_divsqrt_fract_p1 & {54{ex4_round_up}});

   assign ex4_roundup_incexp = ex4_divsqrt_fract_rounded[0] & (~ex4_start_a_denorm_result) & (~exx_hard_spec_case) & (~ex4_force);		// rounded up past the implicit bit (which is bit 1 here)

   assign ex4_x_roundup_incexp = ex4_dnr_roundup_incexp | ex4_roundup_incexp;


   //-----------------------------------------------------------------------
   // Denormal result handling

   // exx_exp_addres <=  std_ulogic_vector(unsigned((exx_a_biased_13exp_q)   -
   //                                              (exx_b_ubexp(1) & exx_b_ubexp(1) & exx_b_ubexp(1 to 11)) +
   //                                              (exx_exp_adj(1) & exx_exp_adj(1) & exx_exp_adj(1 to 11))));
   // underflow
   // underflow <= exx_exp_addres(0);
   // ex4_divsqrt_denorm_hold

   // exp_gt_cap <= (exx_exp_addres(0 to 12) < "1111111001011"); -- < -53
   // result is too small to denormalize = exp_gt_cap

   assign denorm_exp_addres = (({exz_exp_addres_x0[0], exz_exp_addres_x0[0:12]})) + (14'b00000000110101);
   assign denorm_exp_addres_sp = (({exz_exp_addres_x0[0], exz_exp_addres_x0[0:12]})) + (14'b11110010011001);		//  -(896-25)=-871
   //denorm_exp_addres_sp_lsb <= std_ulogic_vector(((exx_exp_addres_x0(0) & exx_exp_addres_x0(0 to 12))) + ("11110010010111"));  --  -(896-23)=-873

   // denormal result shiftoff zero case
   assign denorm_res_shiftoff_exp = (denorm_exp_addres[0:12] == 13'b0000000000000) ? 1'b1 : 		// 0 or 1: implicit bit shifted to Guard or Round position
                                    1'b0;
   assign denorm_res_shiftoff_din = ((denorm_res_shiftoff_exp & ex4_start_denorm_result) | denorm_res_shiftoff_q) & (~ex2_anydivsqrt);

   assign exp_gt_cap = (denorm_exp_addres[0] & ex4_dp) | (denorm_exp_addres_sp[0] & ex4_sp);

   assign ex4_denorm_result_det = exx_dp & (exz_exp_addres_x0[0] | ex4_expresult_zero) & (~exp_gt_cap);
   assign ex4_sp_denorm_result_det = exx_sp & ex4_exp_le_896 & (~exp_gt_cap);		// if the exponent is in the range [871 to 896] [0x367 to 0x380] 0x369 puts the lsb one to the left of the implicit bit

   assign ex4_exp_le_896 =
((~exz_exp_addres_x0[0]) & (~exz_exp_addres_x0[1]) &
(~exz_exp_addres_x0[2]) & exz_exp_addres_x0[3] &
exz_exp_addres_x0[4] & exz_exp_addres_x0[5] &
(~|(exz_exp_addres_x0[6:12]))) |
((~|(exz_exp_addres_x0[0:2])) &
((~(exz_exp_addres_x0[3] & exz_exp_addres_x0[4] & exz_exp_addres_x0[5])) & (exz_exp_addres_x0[3] | exz_exp_addres_x0[4] | exz_exp_addres_x0[5])));		// =0b0001110000000
   // less than or equal to 0b0001110000000

   assign exp_eq_369 = (exz_exp_addres_x0[0:12] == 13'b0001101101001) ? 1'b1 :
                       1'b0;
   assign exp_eq_368 = (exz_exp_addres_x0[0:12] == 13'b0001101101000) ? 1'b1 :
                       1'b0;
   assign exp_eq_367 = (exz_exp_addres_x0[0:12] == 13'b0001101100111) ? 1'b1 :
                       1'b0;
   assign exp_eq_367to9 = exp_eq_367 | exp_eq_368 | exp_eq_369;
   assign exp_eq_380 = (exz_exp_addres_x0[0:12] == 13'b0001110000000) ? 1'b1 :
                       1'b0;

   assign ex4_start_denorm_result = ((ex4_denorm_result_det & (~UE)) & ex4_divsqrt_done_q & (~exx_hard_spec_case)) & (~n_flush);
   assign ex4_start_sp_denorm_result = ((ex4_sp_denorm_result_det & (~UE)) & ex4_divsqrt_done_q & (~exx_hard_spec_case)) & (~n_flush);
   assign ex4_start_a_denorm_result = (((ex4_sp_denorm_result_det | ex4_denorm_result_det) & (~UE)) & ex4_divsqrt_done_q & (~exx_hard_spec_case)) & (~n_flush);

   assign ex4_denormalizing_result = |(denorm_count_q); // or_reduce

   assign ex4_denormalizing_result_shifting = (denorm_count_q == 6'b000010) ? 1'b1 :
                                              1'b0;
   assign ex4_denormalizing_result_rounding = (denorm_count_q == 6'b000001) ? 1'b1 :
                                              1'b0;
   assign ex4_denormalizing_result_done = (denorm_count_q == 6'b000001) ? 1'b1 :
                                          1'b0;
   assign ex4_divsqrt_denorm_hold = ex4_denormalizing_result;

   assign ex4_denormalizing_result_done_din = ex4_denormalizing_result_done & (~f_dcd_axucr0_deno);

   assign denorm_sticky_din = ((ex4_denormalizing_result & |(ex4_divsqrt_fract_shifted_00to48[54:119])) |
                             denorm_sticky_q | (ex4_rem_nonzero & ex4_start_denorm_result)) & (~ex2_anydivsqrt);

   assign denorm_sticky_sp_din = ((ex4_denormalizing_result & |(ex4_divsqrt_fract_stickymask[0:56])) |
                                   denorm_sticky_sp_q | (ex4_rem_nonzero & ex4_start_sp_denorm_result)) & (~ex2_anydivsqrt);

   assign denorm_sticky = denorm_sticky_q;
   assign denorm_sticky_sp = denorm_sticky_sp_q;

   assign denorm_count_start = 6'b000010;

   assign denorm_shift_amt_din = (((~exz_exp_addres_x0[7:12]) + (6'b000010)));
   assign sp_denorm_shift_amt_din = (((~exz_exp_addres_x0[7:12]) + (6'b000100)));		// exp is in the range [871 to 896]

   assign denorm_shift_amt = denorm_shift_amt_q;
   assign sp_denorm_shift_amt = sp_denorm_shift_amt_q;

   assign denorm_count_din = ((denorm_count_start) & {6{ex4_start_a_denorm_result}}) |
                             (((denorm_count_q) - 6'b000001) & {6{ex4_denormalizing_result}}) |
                             (6'b000000 &            {6{ex4_denormalizing_result_done}});
   //--------------------------------------------------------------------------------------------------------------------------------
   // shift the fraction
   assign ex4_divsqrt_fract_cur[00:56] = exx_divsqrt_fract_q[00:56];

   // lev1
   assign dn_lv1sh00 = (~denorm_shift_amt[4]) & (~denorm_shift_amt[5]);		//00
   assign dn_lv1sh01 = (~denorm_shift_amt[4]) & denorm_shift_amt[5];		//01
   assign dn_lv1sh10 = denorm_shift_amt[4] & (~denorm_shift_amt[5]);		//10
   assign dn_lv1sh11 = denorm_shift_amt[4] & denorm_shift_amt[5];		//11

   assign ex4_divsqrt_fract_shifted_00to03[00:59] = (({ex4_divsqrt_fract_cur[00:56], 3'b000}) & {60{dn_lv1sh00}}) |
                  (({1'b0, ex4_divsqrt_fract_cur[00:56], 2'b00}) &                              {60{dn_lv1sh01}}) |
                  (({2'b00, ex4_divsqrt_fract_cur[00:56], 1'b0}) &                              {60{dn_lv1sh10}}) |
                  (({3'b000, ex4_divsqrt_fract_cur[00:56]}) &                                   {60{dn_lv1sh11}});
   // lev2
   assign dn_lv2sh00 = (~denorm_shift_amt[2]) & (~denorm_shift_amt[3]);		//00
   assign dn_lv2sh01 = (~denorm_shift_amt[2]) & denorm_shift_amt[3];		//01
   assign dn_lv2sh10 = denorm_shift_amt[2] & (~denorm_shift_amt[3]);		//10
   assign dn_lv2sh11 = denorm_shift_amt[2] & denorm_shift_amt[3];		//11

   assign ex4_divsqrt_fract_shifted_00to12[00:71] = (({ex4_divsqrt_fract_shifted_00to03[00:59], 12'b000000000000}) & {72{dn_lv2sh00}}) |
(({4'b0000, ex4_divsqrt_fract_shifted_00to03[00:59], 8'b00000000})                                                 & {72{dn_lv2sh01}}) |
(({8'b00000000, ex4_divsqrt_fract_shifted_00to03[00:59], 4'b0000})                                                 & {72{dn_lv2sh10}}) |
(({12'b000000000000, ex4_divsqrt_fract_shifted_00to03[00:59]})                                                     & {72{dn_lv2sh11}});
   // lev3
   assign dn_lv3sh00 = (~denorm_shift_amt[0]) & (~denorm_shift_amt[1]);		//00
   assign dn_lv3sh01 = (~denorm_shift_amt[0]) & denorm_shift_amt[1];		//01
   assign dn_lv3sh10 = denorm_shift_amt[0] & (~denorm_shift_amt[1]);		//10
   assign dn_lv3sh11 = denorm_shift_amt[0] & denorm_shift_amt[1];		//11

   assign ex4_divsqrt_fract_shifted_00to48[00:119] = (({ex4_divsqrt_fract_shifted_00to12[00:71], {48{1'b0}}}) &               {120{dn_lv3sh00}}) |
                                                     ({{16{1'b0}}, ({ex4_divsqrt_fract_shifted_00to12[00:71], {32{1'b0}}})} & {120{dn_lv3sh01}}) |
                                                     ({{32{1'b0}}, ({ex4_divsqrt_fract_shifted_00to12[00:71], {16{1'b0}}})} & {120{dn_lv3sh10}}) |
                                                     ({{48{1'b0}}, (ex4_divsqrt_fract_shifted_00to12[00:71])}               & {120{dn_lv3sh11}});

   assign ex4_divsqrt_fract_shifted_dp[00:56] = ex4_divsqrt_fract_shifted_00to48[00:56];
   //--------------------------------------------------------------------------------------------------------------------------------
   //--------------------------------------------------------------------------------------------------------------------------------
   // shift the sp denorm mask
   assign ex4_spdenorm_mask[00:56] = {ones[0:27], zeros[28:56]};
   assign ex4_spdenorm_mask_lsb[00:56] = {zeros[0:24], 1'b1, zeros[26:56]};
   assign ex4_spdenorm_mask_guard[00:56] = {zeros[0:25], 1'b1, zeros[27:56]};
   assign ex4_spdenorm_mask_round[00:56] = {zeros[0:26], 1'b1, zeros[28:56]};

   // todo: get rid of the cruft below

   // lev1
   assign dnsp_lv1sh00 = (~sp_denorm_shift_amt[4]) & (~sp_denorm_shift_amt[5]);		//00
   assign dnsp_lv1sh01 = (~sp_denorm_shift_amt[4]) & sp_denorm_shift_amt[5];		//01
   assign dnsp_lv1sh10 = sp_denorm_shift_amt[4] & (~sp_denorm_shift_amt[5]);		//10
   assign dnsp_lv1sh11 = sp_denorm_shift_amt[4] & sp_denorm_shift_amt[5];		//11

   assign ex4_spdenorm_mask_shifted_00to03[00:59] = (({ex4_spdenorm_mask[00:56], 3'b000}) & {60{dnsp_lv1sh00}}) |
                                                   (({ex4_spdenorm_mask[01:56], 4'b0000}) & {60{dnsp_lv1sh01}}) |
                                                   (({ex4_spdenorm_mask[02:56], 5'b00000}) & {60{dnsp_lv1sh10}}) |
                                                   (({ex4_spdenorm_mask[03:56], 6'b000000}) & {60{dnsp_lv1sh11}});

   assign ex4_spdenorm_mask_lsb_shifted_00to03[00:59] = (({ex4_spdenorm_mask_lsb[00:56], 3'b000}) & {60{dnsp_lv1sh00}}) |
                                                   (({ex4_spdenorm_mask_lsb[01:56], 4'b0000}) & {60{dnsp_lv1sh01}}) |
                                                   (({ex4_spdenorm_mask_lsb[02:56], 5'b00000}) & {60{dnsp_lv1sh10}}) |
                                                   (({ex4_spdenorm_mask_lsb[03:56], 6'b000000}) & {60{dnsp_lv1sh11}});

   assign ex4_spdenorm_mask_guard_shifted_00to03[00:59] = (({ex4_spdenorm_mask_guard[00:56], 3'b000}) & {60{dnsp_lv1sh00}}) |
                                                   (({ex4_spdenorm_mask_guard[01:56], 4'b0000}) & {60{dnsp_lv1sh01}}) |
                                                   (({ex4_spdenorm_mask_guard[02:56], 5'b00000}) & {60{dnsp_lv1sh10}}) |
                                                   (({ex4_spdenorm_mask_guard[03:56], 6'b000000}) & {60{dnsp_lv1sh11}});

   assign ex4_spdenorm_mask_round_shifted_00to03[00:59] = (({ex4_spdenorm_mask_round[00:56], 3'b000}) & {60{dnsp_lv1sh00}}) |
                                                   (({ex4_spdenorm_mask_round[01:56], 4'b0000}) & {60{dnsp_lv1sh01}}) |
                                                   (({ex4_spdenorm_mask_round[02:56], 5'b00000}) & {60{dnsp_lv1sh10}}) |
                                                   (({ex4_spdenorm_mask_round[03:56], 6'b000000}) & {60{dnsp_lv1sh11}});

   // lev2
   assign dnsp_lv2sh00 = (~sp_denorm_shift_amt[2]) & (~sp_denorm_shift_amt[3]);		//00
   assign dnsp_lv2sh01 = (~sp_denorm_shift_amt[2]) & sp_denorm_shift_amt[3];		//01
   assign dnsp_lv2sh10 = sp_denorm_shift_amt[2] & (~sp_denorm_shift_amt[3]);		//10
   assign dnsp_lv2sh11 = sp_denorm_shift_amt[2] & sp_denorm_shift_amt[3];		//11

   assign ex4_spdenorm_mask_shifted_00to12[00:71] = (({ex4_spdenorm_mask_shifted_00to03[00:59], 12'b000000000000}) & {72{dnsp_lv2sh00}}) |
                                                (({ex4_spdenorm_mask_shifted_00to03[04:59], 16'b0000000000000000}) & {72{dnsp_lv2sh01}}) |
                                                (({ex4_spdenorm_mask_shifted_00to03[08:59], 20'b00000000000000000000}) & {72{dnsp_lv2sh10}}) |
                                                (({ex4_spdenorm_mask_shifted_00to03[12:59], 24'b000000000000000000000000}) & {72{dnsp_lv2sh11}});

   assign ex4_spdenorm_mask_lsb_shifted_00to12[00:71] = (({ex4_spdenorm_mask_lsb_shifted_00to03[00:59], 12'b000000000000}) & {72{dnsp_lv2sh00}}) |
                                                (({ex4_spdenorm_mask_lsb_shifted_00to03[04:59], 16'b0000000000000000}) & {72{dnsp_lv2sh01}}) |
                                                (({ex4_spdenorm_mask_lsb_shifted_00to03[08:59], 20'b00000000000000000000}) & {72{dnsp_lv2sh10}}) |
                                                (({ex4_spdenorm_mask_lsb_shifted_00to03[12:59], 24'b000000000000000000000000}) & {72{dnsp_lv2sh11}});

   assign ex4_spdenorm_mask_guard_shifted_00to12[00:71] = (({ex4_spdenorm_mask_guard_shifted_00to03[00:59], 12'b000000000000}) & {72{dnsp_lv2sh00}}) |
                                                (({ex4_spdenorm_mask_guard_shifted_00to03[04:59], 16'b0000000000000000}) & {72{dnsp_lv2sh01}}) |
                                                (({ex4_spdenorm_mask_guard_shifted_00to03[08:59], 20'b00000000000000000000}) & {72{dnsp_lv2sh10}}) |
                                                (({ex4_spdenorm_mask_guard_shifted_00to03[12:59], 24'b000000000000000000000000}) & {72{dnsp_lv2sh11}});

   assign ex4_spdenorm_mask_round_shifted_00to12[00:71] = (({ex4_spdenorm_mask_round_shifted_00to03[00:59], 12'b000000000000}) & {72{dnsp_lv2sh00}}) |
                                                (({ex4_spdenorm_mask_round_shifted_00to03[04:59], 16'b0000000000000000}) & {72{dnsp_lv2sh01}}) |
                                                (({ex4_spdenorm_mask_round_shifted_00to03[08:59], 20'b00000000000000000000}) & {72{dnsp_lv2sh10}}) |
                                                (({ex4_spdenorm_mask_round_shifted_00to03[12:59], 24'b000000000000000000000000}) & {72{dnsp_lv2sh11}});

   // lev3
   assign dnsp_lv3sh00 = (~sp_denorm_shift_amt[0]) & (~sp_denorm_shift_amt[1]);		//00
   assign dnsp_lv3sh01 = (~sp_denorm_shift_amt[0]) & sp_denorm_shift_amt[1];		//01
   assign dnsp_lv3sh10 = sp_denorm_shift_amt[0] & (~sp_denorm_shift_amt[1]);		//10
   assign dnsp_lv3sh11 = sp_denorm_shift_amt[0] & sp_denorm_shift_amt[1];		//11

   assign ex4_spdenorm_mask_shifted_00to48[00:119] = (({ex4_spdenorm_mask_shifted_00to12[00:71], {48{1'b0}}}) & {120{dnsp_lv3sh00}}) |
                                                     (({ex4_spdenorm_mask_shifted_00to12[16:71], {64{1'b0}}}) & {120{dnsp_lv3sh01}});

   assign ex4_spdenorm_mask_lsb_shifted_00to48[00:119] = (({ex4_spdenorm_mask_lsb_shifted_00to12[00:71], {48{1'b0}}}) & {120{dnsp_lv3sh00}}) |
                                                         (({ex4_spdenorm_mask_lsb_shifted_00to12[16:71], {64{1'b0}}}) & {120{dnsp_lv3sh01}});

   assign ex4_spdenorm_mask_guard_shifted_00to48[00:119] = (({ex4_spdenorm_mask_guard_shifted_00to12[00:71], {48{1'b0}}}) & {120{dnsp_lv3sh00}}) |
                                                           (({ex4_spdenorm_mask_guard_shifted_00to12[16:71], {64{1'b0}}}) & {120{dnsp_lv3sh01}});

   assign ex4_spdenorm_mask_round_shifted_00to48[00:119] = (({ex4_spdenorm_mask_round_shifted_00to12[00:71], {48{1'b0}}}) & {120{dnsp_lv3sh00}}) |
                                                           (({ex4_spdenorm_mask_round_shifted_00to12[16:71], {64{1'b0}}}) & {120{dnsp_lv3sh01}});

   assign ex4_divsqrt_fract_shifted_spmasked[00:56] = ex4_spdenorm_mask_shifted_00to48[00:56] & ex4_divsqrt_fract_cur[00:56];
   assign ex4_divsqrt_fract_stickymask[00:56] = (~ex4_spdenorm_mask_shifted_00to48[00:56]) & ex4_divsqrt_fract_cur[00:56];

   //--------------------------------------------------------------------------------------------------------------------------------
   assign ex4_divsqrt_fract_shifted[00:56] = (ex4_divsqrt_fract_shifted_spmasked[00:56] & {57{ex4_sp}}) |
                                             (ex4_divsqrt_fract_shifted_dp[00:56] & {57{ex4_dp}});
   //--------------------------------------------------------------------------------------------------------------------------------

   // round after denorm result
   //ex4_denormalizing_result_rounding

   assign ex4_divsqrt_fract_dnr_p0 = {1'b0, exx_divsqrt_fract_q[00:52]};
   assign ex4_divsqrt_fract_dnr_p1 = ({1'b0, exx_divsqrt_fract_q[00:52]}) + ({{53{1'b0}}, 1'b1});

   assign lsb_dnr = exx_divsqrt_fract_q[52];

   assign guard_dnr = exx_divsqrt_fract_q[53];

   assign round_dnr = sticky_dnr | exx_divsqrt_fract_q[54];

   assign sticky_dnr = denorm_sticky;

   assign ex4_round_up_dnr = ((guard_dnr & (lsb_dnr | sticky_dnr | round_dnr)) & RNEmode) | ((1'b0) & RTZmode) | (((guard_dnr | round_dnr) & (~sign)) & RPImode) | (((guard_dnr | round_dnr) & sign) & RNImode);		// round to nearest mode

   assign ex4_divsqrt_fract_dnr_dp = (ex4_divsqrt_fract_dnr_p0 & {54{(~ex4_round_up_dnr)}}) |
                                     (ex4_divsqrt_fract_dnr_p1 & {54{ex4_round_up_dnr}});

   // sp denorm rounding ----------------
   assign ex4_divsqrt_fract_dnr_sp_p0 = {1'b0, exx_divsqrt_fract_q[00:52]};
   assign ex4_divsqrt_fract_dnr_sp_p1 = ({1'b0, exx_divsqrt_fract_q[00:52]}) + ({1'b0, ex4_spdenorm_mask_lsb_shifted_00to48[00:52]});

   assign lsb_dnr_sp = |(ex4_spdenorm_mask_lsb_shifted_00to48[00:25] & exx_divsqrt_fract_q[00:25]);

   assign guard_dnr_sp = |(ex4_spdenorm_mask_guard_shifted_00to48[00:26] & exx_divsqrt_fract_q[00:26]);

   assign round_dnr_sp = sticky_dnr_sp | |(ex4_spdenorm_mask_round_shifted_00to48[00:27] & exx_divsqrt_fract_q[00:27]);

   assign sticky_dnr_sp = denorm_sticky_sp;

   assign ex4_round_up_dnr_sp = ((guard_dnr_sp & (lsb_dnr_sp | sticky_dnr_sp | round_dnr_sp)) & RNEmode) |
                                ((1'b0) & RTZmode) |
                                (((guard_dnr_sp | round_dnr_sp) & (~sign)) & RPImode) |
                                (((guard_dnr_sp | round_dnr_sp) & sign) & RNImode);

   assign ex4_divsqrt_fract_dnr_sp_prem = (ex4_divsqrt_fract_dnr_sp_p0 & {54{(~ex4_round_up_dnr_sp)}}) |
                                          (ex4_divsqrt_fract_dnr_sp_p1 & {54{ex4_round_up_dnr_sp}});

   assign ex4_divsqrt_fract_dnr_sp = ex4_divsqrt_fract_dnr_sp_prem &
                                     (~({1'b0, ex4_spdenorm_mask_guard_shifted_00to48[00:52]})) &
                                     (~({1'b0, ex4_spdenorm_mask_round_shifted_00to48[00:52]}));

   assign ex4_divsqrt_fract_dnr = (ex4_divsqrt_fract_dnr_sp & {54{exx_sp}}) |
                                  (ex4_divsqrt_fract_dnr_dp & {54{exx_dp}});

   assign ex4_dnr_roundup_incexp = ex4_divsqrt_fract_dnr[0] & ex4_denormalizing_result_done & (~exx_hard_spec_case) & (~ex4_force);		// rounded up past the implicit bit (which is bit 1 here)

   assign ex4_denorm_res_shiftoff_zero = denorm_res_shiftoff_q & (~ex4_round_up_dnr) & ex4_denormalizing_result_done;

   //------------------------------------------------------------------------------------------------------------------


   tri_rlmreg_p #(.INIT(0), .WIDTH(27), .NEEDS_SRESET(1)) exx_div_denorm_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(exx_div_denorm_lat_scout),
      .scin(exx_div_denorm_lat_scin),
      //-----------------
      .din({
               denorm_sticky_sp_din,
               ex4_norm_shl1_d,
               denorm_res_shiftoff_din,
               denorm_sticky_din,
               denorm_count_din,
               denorm_shift_amt_din,
               sp_denorm_shift_amt_din,
               ex3_norm_shl1,
               ex4_div_special_case,
               ex4_round_up,
               ex4_denormalizing_result_done_din,
               ex4_force_inf}),
      //-----------------
      .dout({  denorm_sticky_sp_q,
               ex4_norm_shl1_q,
               denorm_res_shiftoff_q,
               denorm_sticky_q,
               denorm_count_q,
               denorm_shift_amt_q,
               sp_denorm_shift_amt_q,
               ex4_norm_shl1,
               ex5_div_special_case,
               ex5_round_up,
               ex5_denormalizing_result_done,
               ex5_force_inf})
   );


   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------
   // Special cases: NaN, etc
   assign exx_a_NAN = exx_a_expo_max_q & (~exx_a_frac_zero_q);
   assign exx_b_NAN = exx_b_expo_max_q & (~exx_b_frac_zero_q);
   assign exx_a_INF = exx_a_expo_max_q & exx_a_frac_zero_q;
   assign exx_b_INF = exx_b_expo_max_q & exx_b_frac_zero_q;
   assign exx_a_SPoverflowINF = exx_a_SPoverflow_expo_max_q;
   assign exx_b_SPoverflowINF = exx_b_SPoverflow_expo_max_q;

   assign exx_b_ZER = exx_b_zero_q;
   assign exx_a_ZER = exx_a_zero_q;
   assign exx_a_SPunderflowZER = exx_a_SPunderflow_zero_q;
   assign exx_b_SPunderflowZER = exx_b_SPunderflow_zero_q;
   assign exx_invalid_mixed_precision = ((exx_b_SPunderflowZER | exx_b_SPoverflowINF) | (exx_div_q[3] & (exx_a_SPunderflowZER | exx_a_SPoverflowINF))) & (~((exx_div_q[3] & (exx_a_NAN | exx_a_INF | exx_a_ZER)) | (exx_b_NAN | exx_b_INF | exx_b_ZER)));

   assign exx_hard_spec_case = (exx_div_q[3] & (exx_a_NAN | exx_a_INF | exx_a_ZER | exx_a_SPunderflowZER | exx_a_SPoverflowINF)) | (exx_b_NAN | exx_b_INF | exx_b_ZER | exx_b_SPunderflowZER | exx_b_SPoverflowINF) | (exx_sqrt_q[3] & exx_b_sign_q);

   assign ex4_div_by_zero_zx = exx_b_ZER & (~(exx_div_q[3] & exx_a_INF)) & (~(exx_a_SPunderflowZER | exx_a_SPoverflowINF)) & (~exx_sqrt_q[3]) & (~ex4_zero_div_zero) & (~ex4_pass_nan);
   assign ex4_zero_div_zero = (exx_a_ZER & exx_b_ZER) & exx_div_q[3];
   assign ex4_inf_div_inf = (exx_a_INF & exx_b_INF) & exx_div_q[3];
   assign ex4_sqrt_neg = exx_sqrt_q[3] & exx_b_sign_q & (~exx_b_ZER) & (~ex4_pass_nan);

   assign ex4_div_special_case = ex4_pass_a_nan |
                                 ex4_pass_b_nan |
                                 ex4_force_qnan |
                                 ex4_force_zero |
                                 ex4_force_zeroone |
                                 ex4_force_36A |
                                 ex4_force_maxnorm;

   assign underflow_force_zero = underflow & exp_gt_cap & (~ex4_round_up_underflow) & (~UE) & (~exx_hard_spec_case);
   assign underflow_force_zeroone = underflow_dp & exp_gt_cap & ex4_round_up_underflow & exx_dp & (~UE) & (~exx_hard_spec_case);
   assign underflow_force_36A = underflow_sp & exp_gt_cap & ex4_round_up_underflow & exx_sp & (~UE) & (~exx_hard_spec_case);

   assign sp_denorm_0x369roundup = ex4_denormalizing_result_rounding & ex4_round_up_dnr_sp & exx_sp & exp_eq_367to9;
   assign sp_denorm_0x380roundup = ex4_denormalizing_result_rounding & ex4_divsqrt_fract_dnr[0] & exx_sp & exp_eq_380;
   assign sp_denorm_underflow_zero = ex4_denormalizing_result_rounding & (~ex4_round_up_dnr_sp) & exx_sp & exp_eq_367to9 & (~UE);

   assign underflow_sp_denorm = underflow & (~exp_gt_cap) & (~UE) & (~exx_hard_spec_case) & ex4_sp;

   assign overflow_force_inf = ((overflow & RNEmode) | (overflow & RPImode & (~ex4_divsqrt_sign)) | (overflow & RNImode & ex4_divsqrt_sign)) & (~exx_hard_spec_case) & (~OE);

   assign overflow_force_maxnorm = ((overflow & RTZmode) | (overflow & RPImode & ex4_divsqrt_sign) | (overflow & RNImode & (~ex4_divsqrt_sign))) & (~exx_hard_spec_case) & (~OE);

   assign ex4_maxnorm_sign = ex4_divsqrt_sign;

   assign special_force_zero = (exx_b_INF & (~exx_sqrt_q[3])) | (exx_a_ZER & (~exx_sqrt_q[3])) | (exx_b_ZER & exx_sqrt_q[3]);
   assign special_force_inf = (exx_a_INF & (~exx_sqrt_q[3])) | (exx_b_ZER & (~exx_sqrt_q[3])) | (exx_b_INF & exx_sqrt_q[3]);

   assign ex4_force_36A = (sp_denorm_0x369roundup | underflow_force_36A) & (~(ex4_force_qnan | ex4_pass_nan));
   assign ex4_force_zeroone = underflow_force_zeroone & (~(ex4_force_qnan | ex4_pass_nan));
   assign ex4_force_zero = (underflow_force_zero | special_force_zero | sp_denorm_underflow_zero | ex4_deno_force_zero) & (~(ex4_force_qnan | ex4_pass_nan));
   assign ex4_force_inf = (overflow_force_inf | special_force_inf) & (~(ex4_force_qnan | ex4_pass_nan));
   assign ex4_force_maxnorm = overflow_force_maxnorm & (~(ex4_force_qnan | ex4_pass_nan));
   assign ex4_force_maxnorm_dp = ex4_force_maxnorm & ex4_dp;
   assign ex4_force_maxnorm_sp = ex4_force_maxnorm & ex4_sp;
   assign ex4_force_qnan = ex4_zero_div_zero | ex4_inf_div_inf | ex4_sqrt_neg | exx_b_SPunderflowZER | exx_b_SPoverflowINF | ((exx_a_SPunderflowZER | exx_a_SPoverflowINF) & exx_div_q[3]);

   assign ex4_force = ex4_force_36A | ex4_force_zeroone | ex4_force_zero | ex4_force_maxnorm | ex4_force_qnan;

   assign ex4_deno_force_zero = ex4_denormalizing_result_done & f_dcd_axucr0_deno;

   assign ex4_pass_a_nan = exx_a_NAN & (~exx_sqrt_q[3]);
   assign ex4_pass_b_nan = exx_b_NAN & (~ex4_pass_a_nan);
   assign ex4_pass_a_nan_sp = ex4_pass_a_nan & exx_sp;
   assign ex4_pass_b_nan_sp = ex4_pass_b_nan & exx_sp;
   assign ex4_pass_a_nan_dp = ex4_pass_a_nan & exx_dp;
   assign ex4_pass_b_nan_dp = ex4_pass_b_nan & exx_dp;

   assign ex4_a_snan = exx_a_NAN & (~exx_a_fract_q[1]) & (~exx_sqrt_q[3]);
   assign ex4_b_snan = exx_b_NAN & (~exx_b_fract_q[1]);
   assign ex4_pass_nan = ex4_pass_a_nan | ex4_pass_b_nan;
   assign ex4_snan = ex4_a_snan | ex4_b_snan;

   assign ex4_divsqrt_sign_special = (exx_a_sign_q & ex4_pass_a_nan) |
                                     (exx_b_sign_q & ex4_pass_b_nan) |
                                     (1'b0 & ex4_force_qnan) |
                                     (ex4_divsqrt_sign & ex4_force_zero) |
                                     (ex4_divsqrt_sign & ex4_force_zeroone) |
                                     (ex4_divsqrt_sign & ex4_force_36A) |
                                     (ex4_divsqrt_sign & ex4_force_inf) |
                                     (ex4_divsqrt_sign & ex4_dnr_roundup_incexp) |
                                     (ex4_divsqrt_sign & ex4_roundup_incexp) |
                                     (ex4_maxnorm_sign & ex4_force_maxnorm);

   assign ex4_divsqrt_exp_special[01:13] = ({13{1'b0}} &                 {13{ex4_force_zero}}) |
                                           ({{12{1'b0}}, 1'b1} &         {13{ex4_force_zeroone}}) |
                                           ({2'b00, ones[03:13]} &       {13{ex4_pass_nan}}) |
                                           ({2'b00, ones[03:13]} &       {13{ex4_force_qnan}}) |
                                           ({2'b00, ones[03:12], 1'b0} & {13{ex4_force_maxnorm_dp}}) |
                                           (13'b0001101101010 &          {13{ex4_force_36A}}) |
                                           (13'b0010001111110 &          {13{ex4_force_maxnorm_sp}});

   assign ex4_divsqrt_fract_special[00:52] = ({53{1'b0}} &                                       {53{ex4_force_zero}}) |
                                             ({{52{1'b0}}, 1'b1} &                               {53{ex4_force_zeroone}}) |
                                             ({1'b1, {52{1'b0}}} &                               {53{ex4_force_36A}}) |
                                             (({2'b11, zeros[2:52]}) &                           {53{ex4_force_qnan}}) |
                                             (({2'b11, exx_a_fract_q[2:23], zeros[24:52]}) &     {53{ex4_pass_a_nan_sp}}) |
                                             (({2'b11, exx_b_fract_q[2:23], zeros[24:52]}) &     {53{ex4_pass_b_nan_sp}}) |
                                             (({2'b11, exx_a_fract_q[2:52]}) &                   {53{ex4_pass_a_nan_dp}}) |
                                             (({2'b11, exx_b_fract_q[2:52]}) &                   {53{ex4_pass_b_nan_dp}}) |
                                             ({53{1'b1}} &                                       {53{ex4_force_maxnorm_dp}}) |
                                             ({{24{1'b1}}, {29{1'b0}}} &                         {53{ex4_force_maxnorm_sp}});

   //-----------------------------------------------------------------------
   // some final result muxing
   //-----------------------------------------------------------------------

   assign ex4_divsqrt_sign = exx_a_sign_q ^ exx_b_sign_q;

   assign exx_divsqrt_sign_d = (ex4_divsqrt_sign & (~ex4_div_special_case)) | (ex4_divsqrt_sign_special & ex4_div_special_case);

   assign ex4_divsqrt_exp = ((exx_exp_addres) & {13{(ex4_divsqrt_done_q & (~ex4_denormalizing_result_done))}}) |
                            ((exx_exp_addres) & {13{(ex4_denormalizing_result_done & ex4_sp)}}) |
                            (13'b0000000000001 & {13{(ex4_denormalizing_result_done & (~ex4_sp))}});

   assign exx_divsqrt_exp_d = ex4_divsqrt_exp;

   assign ex4_divsqrt_fract = ex4_divsqrt_fract_p0[01:53];

   // generate the remainder
   assign exx_divsqrt_fract_d = (ex3_divsqrt_remainder[00:56] &              {57{(ex3_divsqrt_done & (~ex4_denormalizing_result) & (~ex4_start_a_denorm_result))}}) |
                                ({ex4_divsqrt_fract[00:52], 4'b0000} &       {57{(ex4_divsqrt_done_q & (~ex4_denormalizing_result) & (~ex4_start_a_denorm_result))}}) |
                                ({ex4_divsqrt_fract_dnr[01:53], 4'b0000} &   {57{(ex4_denormalizing_result_rounding & (~ex4_denormalizing_result_shifting) & (~ex4_start_a_denorm_result))}}) |
                                (ex4_divsqrt_fract_shifted[00:56] &          {57{(ex4_denormalizing_result_shifting & (~ex4_denormalizing_result_rounding) & (~ex4_start_a_denorm_result))}}) |
                                (ex4_divsqrt_fract_preround[00:56] &         {57{(ex4_start_denorm_result)}}) |
                                (({ex4_divsqrt_fract_preround[28:56], zeros[0:27]}) & {57{(ex4_start_sp_denorm_result)}});		// grab the rounded/corrected result

   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------
   ////#------------------------------------------------------------------------
   ////# decode fprf field for pipe settings
   ////#------------------------------------------------------------------------
   // FPRF
   // 10001  QNAN     [0]  qnan | den | (sign*zero)
   // 01001 -INF      [1]  sign * !zero
   // 01000 -norm     [2] !sign * !zero * !qnan
   // 11000 -den      [3]  zero
   // 10010 -zero     [4]  inf   | qnan
   // 00010 +zero
   // 10100 +den
   // 00100 +norm
   // 00101 +inf

   // FPSCR status bits
   // [ 0] ox 0
   // [ 1] ux 0
   // [ 2] zx 0
   // [ 3] xx 1 (not needed, comes from FI)
   // [ 4] FR 1
   // [ 5] FI 1

   // [ 6] sign
   // [ 7] not sign and not zero, redundant in rnd?
   // [ 8] zer
   // [ 9] inf
   // [10] den
   // [11] vxidi
   // [12] vxzdz
   // [13] vxsqrt
   // [14] nan
   // [15] vxsnan

   assign exx_divsqrt_flag_fpscr_d[0] = overflow & (~exx_hard_spec_case);
   assign exx_divsqrt_flag_fpscr_d[1] = underflow_fi & (~exx_hard_spec_case) & (~ex4_deno_force_zero);
   assign exx_divsqrt_flag_fpscr_d[2] = ex4_div_by_zero_zx;
   assign exx_divsqrt_flag_fpscr_d[3] = ex4_rem_nonzero_fi & (~exx_hard_spec_case) & (~ex4_deno_force_zero);
   assign exx_divsqrt_flag_fpscr_d[4] = ((((ex4_round_up & (~(underflow & (~UE)))) | ex4_force_zeroone | ex4_force_36A) & (~ex4_denormalizing_result_done)) | (((ex4_round_up_dnr & exx_dp) | (ex4_round_up_dnr_sp & exx_sp)) & ex4_denormalizing_result_done) | (overflow & (~OE))) & (~exx_hard_spec_case) & (~ex4_deno_force_zero);		// and not underflow_fi;
   assign exx_divsqrt_flag_fpscr_d[5] = (ex4_rem_nonzero_fi | (overflow & (~OE)) | (underflow_fi & (~UE))) & (~exx_hard_spec_case) & (~ex4_deno_force_zero);
   assign exx_divsqrt_flag_fpscr_d[6] = exx_divsqrt_sign_d;		// and not (ex4_pass_nan or ex4_force_qnan);
   assign exx_divsqrt_flag_fpscr_d[7] = ((~exx_divsqrt_sign_d)) & (~ex4_force_zero) & (~(ex4_pass_nan | ex4_force_qnan));
   assign exx_divsqrt_flag_fpscr_d[8] = (ex4_force_zero | ex4_denorm_res_shiftoff_zero) & (~(ex4_pass_nan | ex4_force_qnan));
   assign exx_divsqrt_flag_fpscr_d[9] = ex4_force_inf;
   assign exx_divsqrt_flag_fpscr_d[10] = ((((ex4_denormalizing_result_done & ((~exx_divsqrt_fract_d[0]) & exx_dp)) | underflow_sp_denorm) & (~sp_denorm_0x380roundup)) | ex4_force_zeroone | ex4_force_36A) & (~ex4_deno_force_zero);
   assign exx_divsqrt_flag_fpscr_d[11] = ex4_inf_div_inf;
   assign exx_divsqrt_flag_fpscr_d[12] = ex4_zero_div_zero;
   assign exx_divsqrt_flag_fpscr_d[13] = ex4_sqrt_neg & (~exx_b_SPunderflow_zero_q) & (~exx_b_SPoverflow_expo_max_q);
   assign exx_divsqrt_flag_fpscr_d[14] = ex4_force_qnan | ex4_pass_nan;
   assign exx_divsqrt_flag_fpscr_d[15] = ex4_snan;

   assign exx_divsqrt_v_suppress_d = (zezx | vevx) & (~exx_invalid_mixed_precision);

   assign ex3_rem_neg   = ex3_divsqrt_remainder[0];
   assign ex3_rem_neg_b = (~ex3_divsqrt_remainder[0]);


   tri_rlmreg_p #(.INIT(0), .WIDTH(96), .NEEDS_SRESET(0)) ex5_div_result_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex5_div_result_lat_scout),
      .scin(ex5_div_result_lat_scin),
      //-----------------
      .din({
               exx_divsqrt_sign_d,
               exx_divsqrt_exp_d,
               exx_divsqrt_fract_d,
               exx_divsqrt_flag_fpscr_d,
               exx_divsqrt_v_suppress_d,
               ex3_rem_neg,
               ex3_rem_neg,
               ex3_rem_neg,
               ex3_rem_neg,
               ex3_rem_neg_b,
               ex3_rem_neg_b,
               ex3_rem_neg_b,
               ex3_rem_neg_b	 }),
      //-----------------
      .dout({  exx_divsqrt_sign_q,
               exx_divsqrt_exp_q[1:13],
               exx_divsqrt_fract_q[00:56],
               exx_divsqrt_flag_fpscr_q,
               exx_divsqrt_v_suppress_q,
               ex4_rem_neg[0],
               ex4_rem_neg[1],
               ex4_rem_neg[2],
               ex4_rem_neg[3],
               ex4_rem_neg_b[0],
               ex4_rem_neg_b[1],
               ex4_rem_neg_b[2],
               ex4_rem_neg_b[3] 	        })
   );

   tri_rlmreg_p #(.INIT(0), .WIDTH(163), .NEEDS_SRESET(0)) ex5_special_case_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(exx_running_act_q),
      //-----------------
      .scout(ex5_special_case_lat_scout),
      .scin(ex5_special_case_lat_scin),
      //-----------------

      .din({ex4_divsqrt_fract_special,
            ex4_divsqrt_fract_p1,
            ex4_divsqrt_exp_special,
	    exx_exp_addres_x0_p1,
	    exx_exp_addres_ux_p1,
	    exx_exp_addres_ox_p1,
	    ueux,
	    oeox,
	    not_ueux_or_oeox,
	    ex4_x_roundup_incexp
          }),
      //-----------------
      .dout({
            ex5_divsqrt_fract_special,
            ex5_divsqrt_fract_p1,
            ex5_divsqrt_exp_special,
	    exy_exp_addres_x0_p1,
	    exy_exp_addres_ux_p1,
	    exy_exp_addres_ox_p1,
	    exy_ueux,
	    exy_oeox,
	    exy_not_ueux_or_oeox,
	    ex5_x_roundup_incexp
            })
   );

     assign exy_exp_addres_p1 = (exy_exp_addres_x0_p1 & {13{exy_not_ueux_or_oeox}}) |
                                (exy_exp_addres_ux_p1 & {13{exy_ueux}}) |
                                (exy_exp_addres_ox_p1 & {13{exy_oeox}});



   assign ex5_divsqrt_fract_d = (exx_divsqrt_fract_q[00:52] &        {53{(((~(ex5_div_special_case | ex5_force_inf | ex5_round_up | ex5_x_roundup_incexp))) | ex5_denormalizing_result_done)}}) |
                                (ex5_divsqrt_fract_special[00:52] &  {53{(ex5_div_special_case & (~ex5_force_inf))}}) |
	                        ({1'b1, {52{1'b0}}} &                {53{ex5_x_roundup_incexp}}) |
                                ({1'b1, {52{1'b0}}} &                {53{(ex5_force_inf)}}) |
                                (ex5_divsqrt_fract_p1[01:53] &       {53{((~(ex5_div_special_case | ex5_force_inf | ex5_x_roundup_incexp)) & ex5_round_up & (~ex5_denormalizing_result_done))}});

   assign ex5_divsqrt_exp_d = (exx_divsqrt_exp_q[01:13] &       {13{((~ex5_denormalizing_result_done) & (~(ex5_div_special_case | ex5_force_inf | ex5_x_roundup_incexp)))}}) |
                              (exx_divsqrt_exp_q[01:13] &       {13{(ex5_denormalizing_result_done & (~(ex5_div_special_case | ex5_force_inf | ex5_x_roundup_incexp)))}}) |
	                      (exy_exp_addres_p1[0:12] &        {13{(ex5_x_roundup_incexp & (~ex5_force_inf))}}) |
			      ({2'b00, ones[03:13]} &           {13{(ex5_force_inf)}}) |
                              (ex5_divsqrt_exp_special[01:13] & {13{(ex5_div_special_case & (~ex5_force_inf))}});


   tri_rlmreg_p #(.INIT(0), .WIDTH(66), .NEEDS_SRESET(0)) ex6_div_result_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(ex6_div_result_lat_scout),
      .scin(ex6_div_result_lat_scin),
      //-----------------

      .din({ex5_divsqrt_fract_d,
            ex5_divsqrt_exp_d}),
      //-----------------
      .dout({ ex6_divsqrt_fract_q,
              ex6_divsqrt_exp_q})
   );

   assign ex4_divsqrt_done = (ex4_divsqrt_done_q | ex4_denormalizing_result_done) & (~ex4_start_a_denorm_result);

   assign f_dsq_ex5_divsqrt_v[0] = ex5_divsqrt_done & exx_instr_tid_q[0];
   assign f_dsq_ex5_divsqrt_v[1] = ex5_divsqrt_done & exx_instr_tid_q[1];
   assign f_dsq_ex6_divsqrt_v[0] = ex6_divsqrt_done & exx_instr_tid_q[0];
   assign f_dsq_ex6_divsqrt_v[1] = ex6_divsqrt_done & exx_instr_tid_q[1];

   assign f_dsq_ex6_divsqrt_record_v = exx_record_v_q & ex6_divsqrt_done;
   assign f_dsq_ex6_divsqrt_v_suppress = exx_divsqrt_v_suppress_q;
   assign f_dsq_ex5_divsqrt_itag = exx_itag_q;
   assign f_dsq_ex6_divsqrt_fpscr_addr = exx_fpscr_addr_q;
   assign f_dsq_ex6_divsqrt_instr_frt = exx_instr_frt_q;
   assign f_dsq_ex6_divsqrt_instr_tid = exx_instr_tid_q;
   assign f_dsq_ex6_divsqrt_cr_bf = exx_cr_bf_q;
   assign f_dsq_ex6_divsqrt_sign = exx_divsqrt_sign_q;
   assign f_dsq_ex6_divsqrt_exp[01:13] = ex6_divsqrt_exp_q;		//exx_divsqrt_exp_q;
   assign f_dsq_ex6_divsqrt_fract[00:52] = ex6_divsqrt_fract_q;		//exx_divsqrt_fract_q(00 to 52);
   assign f_dsq_ex6_divsqrt_flag_fpscr = exx_divsqrt_flag_fpscr_q;

   assign f_dsq_debug_din[00] = ex1_cycles_init; // 0:11 are on trigger group 2, 12:23  on 3
   assign f_dsq_debug_din[01] = ex1_cycles_hold;
   assign f_dsq_debug_din[02] = ex1_divsqrt_done;
   assign f_dsq_debug_din[03] = ex2_divsqrt_done;
   assign f_dsq_debug_din[04] = ex3_divsqrt_done;
   assign f_dsq_debug_din[05] = ex4_divsqrt_done;
   assign f_dsq_debug_din[06] = ex5_divsqrt_done;
   assign f_dsq_debug_din[07] = ex6_divsqrt_done;
   assign f_dsq_debug_din[08] = ex1_cycles_clear;
   assign f_dsq_debug_din[09] = exx_divsqrt_running_q;
   assign f_dsq_debug_din[10] = exx_running_act_q;
   assign f_dsq_debug_din[11] = ex1_sqrt;
   assign f_dsq_debug_din[12] = ex2_cycles_q[0];   // 0:11 are on trigger group 2, 12:23 on 3
   assign f_dsq_debug_din[13] = ex2_cycles_q[1];
   assign f_dsq_debug_din[14] = ex2_cycles_q[2];
   assign f_dsq_debug_din[15] = ex2_cycles_q[3];
   assign f_dsq_debug_din[16] = ex2_cycles_q[4];
   assign f_dsq_debug_din[17] = ex2_cycles_q[5];
   assign f_dsq_debug_din[18] = ex2_cycles_q[6];
   assign f_dsq_debug_din[19] = ex2_cycles_q[7];
   assign f_dsq_debug_din[20] = ex1_cycles_hold;
   assign f_dsq_debug_din[21] = ex1_cycles_init;
   assign f_dsq_debug_din[22] = exx_single_precision_d;
   assign f_dsq_debug_din[23] = exx_sqrt_d;
   assign f_dsq_debug_din[24] = exx_sum4[0];
   assign f_dsq_debug_din[25] = exx_sum4[1];
   assign f_dsq_debug_din[26] = exx_sum4[2];
   assign f_dsq_debug_din[27] = exx_sum4[3];
   assign f_dsq_debug_din[28] = exx_q_bit0_cin;
   assign f_dsq_debug_din[29:63] = exx_Q_q[22:56];


  tri_rlmreg_p #(.INIT(0), .WIDTH(64), .NEEDS_SRESET(0)) f_dsq_debug_lat(
      .force_t(force_t),		.d_mode(tiup),       .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .thold_b(thold_0_b),
      .sg(sg_0),
      //-----------------
      .act(tiup),
      //-----------------
      .scout(f_dsq_debug_lat_scout),
      .scin(f_dsq_debug_lat_scin),
      //-----------------

      .din(f_dsq_debug_din),
      //-----------------
      .dout(f_dsq_debug_q)
   );

   assign f_dsq_debug = f_dsq_debug_q;

   //------------------------------------------------------------------------------
   // sinkless
   //------------------------------------------------------------------------------

assign spare_unused[2] = exx_Qin_lev0[0];
assign spare_unused[3] = exx_QMin_lev0[0];
assign spare_unused[4] = exx_bQ_q_t[56];
assign spare_unused[5] = exx_bQM_q_t[56];
assign spare_unused[6] = exx_lev0_csaout_carryout[0];
assign spare_unused[7] = fpu_enable;
assign spare_unused[8] = exx_lev0_csaoutsh_carry[0];
assign spare_unused[9] = exx_lev1_div_csaout_carryout[0];
assign spare_unused[10] = exx_lev1_sqrt_csaout_carryout[0];
assign spare_unused[11] = exx_lev1_div_csaout_carry[4];
assign spare_unused[12:62] = exx_lev1_div_csaout_carry[6:56];
assign spare_unused[63] = exx_lev1_sqrt_csaout_carry[4];
assign spare_unused[64:114] = exx_lev1_sqrt_csaout_carry[6:56];
assign spare_unused[115] = exx_lev1_div_csaout_sum[4];
assign spare_unused[116:166] = exx_lev1_div_csaout_sum[6:56];
assign spare_unused[167] = exx_lev1_sqrt_csaout_sum[4];
assign spare_unused[168:218] = exx_lev1_sqrt_csaout_sum[6:56];
assign spare_unused[219] = exx_q_bit1;
assign spare_unused[220] = exx_nq_bit1;
assign spare_unused[221] = exx_lev2_csaout_sum[4];
assign spare_unused[222:272] = exx_lev2_csaout_sum[6:56];
assign spare_unused[273] = exx_lev2_csaout_carryout[0];
assign spare_unused[274] = exx_lev2_csaout_carry[4];
assign spare_unused[275:325] = exx_lev2_csaout_carry[6:56];
assign spare_unused[326] = exx_lev3_div_csaout_carryout[0];
assign spare_unused[327] = exx_lev3_sqrt_csaout_carryout[0];
assign spare_unused[328] = exx_lev3_div_csaout_carry[4];
assign spare_unused[329:379] = exx_lev3_div_csaout_carry[6:56];
assign spare_unused[380] = exx_lev3_sqrt_csaout_carry[4];
assign spare_unused[381:431] = exx_lev3_sqrt_csaout_carry[6:56];
assign spare_unused[432] = exx_lev3_div_csaout_sum[4];
assign spare_unused[433:483] = exx_lev3_div_csaout_sum[6:56];
assign spare_unused[484] = exx_lev3_sqrt_csaout_sum[4];
assign spare_unused[485:535] = exx_lev3_sqrt_csaout_sum[6:56];
assign spare_unused[536] = exx_q_bit3;
assign spare_unused[537] = exx_nq_bit3;
assign spare_unused[538] = exx_nq_bit22;
assign spare_unused[539] = exx_lev0_csaoutsh_sum[0];
assign spare_unused[540] = exx_lev22_csaout_carryout_div[0];
assign spare_unused[541] = exx_lev22_csaout_carryout_sqrt[0];
assign spare_unused[542:594] = ex4_divsqrt_fract_rounded[1:53];
assign spare_unused[595] = ex4_incexp_to_overflow;
assign spare_unused[596] = ex4_norm_shl1_test;
assign spare_unused[597] = denorm_exp_addres[13];
assign spare_unused[598:610] = denorm_exp_addres_sp[1:13];
assign spare_unused[611] = ex4_divsqrt_denorm_hold;
assign spare_unused[612] = dnsp_lv3sh10;
assign spare_unused[613] = dnsp_lv3sh11;
assign spare_unused[614:676] = ex4_spdenorm_mask_shifted_00to48[57:119];
assign spare_unused[677:743] = ex4_spdenorm_mask_lsb_shifted_00to48[53:119];
assign spare_unused[744:810] = ex4_spdenorm_mask_guard_shifted_00to48[53:119];
assign spare_unused[811:877] = ex4_spdenorm_mask_round_shifted_00to48[53:119];
assign spare_unused[878] = ex5_divsqrt_fract_p1[0];
assign spare_unused[879] = ex4_act;
assign spare_unused[880] = ex2_record_v;

   //------------------------------------------------------------------------------
   // scan chain
   //------------------------------------------------------------------------------

   assign ex1_div_ctr_lat_scin[0:18] = {ex1_div_ctr_lat_scout[1:18], f_dsq_si};

   assign ex3_div_hangcounter_lat_scin[0:7] = {ex3_div_hangcounter_lat_scout[1:7], ex1_div_ctr_lat_scout[0]};
   assign ex2_div_b_stage_lat_scin[0:70] = {ex2_div_b_stage_lat_scout[1:70], ex3_div_hangcounter_lat_scout[0]};
   assign ex2_div_exp_lat_scin[0:51] = {ex2_div_exp_lat_scout[1:51], ex2_div_b_stage_lat_scout[0]};
   assign ex2_div_a_stage_lat_scin[0:70] = {ex2_div_a_stage_lat_scout[1:70], ex2_div_exp_lat_scout[0]};
   assign ex1_div_instr_lat_scin[0:14] = {ex1_div_instr_lat_scout[1:14], ex2_div_a_stage_lat_scout[0]};
   assign ex2_div_instr_lat_scin[0:5] = {ex2_div_instr_lat_scout[1:5], ex1_div_instr_lat_scout[0]};

   assign ex2_itag_lat_scin[0:8] = {ex2_itag_lat_scout[1:8], ex2_div_instr_lat_scout[0]};

   assign ex2_fpscr_addr_lat_scin[0:27] = {ex2_fpscr_addr_lat_scout[1:27], ex2_itag_lat_scout[0]};
   assign exx_div_denorm_lat_scin[0:26] = {exx_div_denorm_lat_scout[1:26], ex2_fpscr_addr_lat_scout[0]};

   assign ex3_div_PR_sumcarry_lat_scin[0:113] = {ex3_div_PR_sumcarry_lat_scout[1:113], exx_div_denorm_lat_scout[0]};
   assign ex3_div_PR_sum4carry4_lat_scin[0:7] = {ex3_div_PR_sum4carry4_lat_scout[1:7], ex3_div_PR_sumcarry_lat_scout[0]};

   assign ex3_div_Q_QM_lat_scin[0:113] = {ex3_div_Q_QM_lat_scout[1:113], ex3_div_PR_sum4carry4_lat_scout[0]};
   assign ex3_div_bQ_QM_lat_scin[0:113] = {ex3_div_bQ_QM_lat_scout[1:113], ex3_div_Q_QM_lat_scout[0]};

   assign ex3_sqrt_bitmask_lat_scin[0:167] = {ex3_sqrt_bitmask_lat_scout[1:167], ex3_div_bQ_QM_lat_scout[0]};

   assign ex3_denom_lat_scin[0:55] = {ex3_denom_lat_scout[1:55], ex3_sqrt_bitmask_lat_scout[0]};
   assign ex5_div_result_lat_scin[00:95] = {ex5_div_result_lat_scout[01:95], ex3_denom_lat_scout[0]};
   assign ex6_div_result_lat_scin[00:65] = {ex6_div_result_lat_scout[01:65], ex5_div_result_lat_scout[0]};
   assign ex5_special_case_lat_scin[00:162] = {ex5_special_case_lat_scout[01:162], ex6_div_result_lat_scout[0]};

   assign ex5_div_done_lat_scin[0:3] = {ex5_div_done_lat_scout[1:3], ex5_special_case_lat_scout[0]};

   assign act_si[0:7] = {act_so[1:7], ex5_div_done_lat_scout[0]};
   assign f_dsq_debug_lat_scin[0:63] = {f_dsq_debug_lat_scout[1:63], act_so[0]};

   assign f_dsq_so = f_dsq_debug_lat_scout[0];

endmodule
