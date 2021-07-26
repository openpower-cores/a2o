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

//*****************************************************************************
//*
//*  TITLE: F_DP_DCD
//*
//*  NAME:  fuq_dcd.vhdl
//*
//*  DESC:   This is Control and Decode
//*
//*****************************************************************************
   `include "tri_a2o.vh"

module fu_dcd(
   act_dis,
   bcfg_scan_in,
   ccfg_scan_in,
   cfg_sl_thold_1,
   func_slp_sl_thold_1,
   clkoff_b,
   cp_flush,
   dcfg_scan_in,

   debug_bus_in,
   coretrace_ctrls_in,
   debug_bus_out,
   coretrace_ctrls_out,

   f_dcd_perr_sm_running,
   f_dcd_ex2_perr_force_c,
   f_dcd_ex2_perr_fsel_ovrd,


   delay_lclkr,
   f_add_ex5_fpcc_iu,
   f_dcd_si,
   f_dsq_ex5_divsqrt_itag,
   f_dsq_ex5_divsqrt_v,
   f_dsq_ex6_divsqrt_cr_bf,
   f_dsq_ex6_divsqrt_fpscr_addr,
   f_dsq_ex6_divsqrt_instr_frt,
   f_dsq_ex6_divsqrt_instr_tid,
   f_dsq_ex6_divsqrt_record_v,
   f_dsq_ex6_divsqrt_v,
   f_dsq_ex6_divsqrt_v_suppress,
   f_dcd_rv_hold_all,
   f_dsq_ex3_hangcounter_trigger,
   f_dsq_debug,
   f_ex3_b_den_flush,
   f_fpr_ex6_load_addr,
   f_fpr_ex6_load_v,
   f_fpr_ex6_reload_addr,
   f_fpr_ex6_reload_v,
   f_mad_ex3_a_parity_check,
   f_mad_ex3_b_parity_check,
   f_mad_ex3_c_parity_check,
   f_mad_ex4_uc_res_sign,
   f_mad_ex4_uc_round_mode,
   f_mad_ex4_uc_special,
   f_mad_ex4_uc_vxidi,
   f_mad_ex4_uc_vxsnan,
   f_mad_ex4_uc_vxsqrt,
   f_mad_ex4_uc_vxzdz,
   f_mad_ex4_uc_zx,
   f_mad_ex7_uc_sign,
   f_mad_ex7_uc_zero,
   f_pic_ex6_fpr_wr_dis_b,
   f_pic_ex6_scr_upd_move_b,
   f_rnd_ex7_res_expo,
   f_rnd_ex7_res_frac,
   f_rnd_ex7_res_sign,
   f_scr_cpl_fx_thread0,
   f_scr_cpl_fx_thread1,
   f_scr_ex8_cr_fld,
   f_scr_ex8_fx_thread0,
   f_scr_ex8_fx_thread1,
   f_scr_ex6_fpscr_ni_thr0,
   f_scr_ex6_fpscr_ni_thr1,
   f_sto_ex3_s_parity_check,
   flush,
   iu_fu_rf0_tid,
   iu_fu_rf0_fra,
   iu_fu_rf0_fra_v,
   iu_fu_rf0_frb,
   iu_fu_rf0_frb_v,
   iu_fu_rf0_frc,
   iu_fu_rf0_frc_v,
   iu_fu_rf0_instr_match,
   mpw1_b,
   mpw2_b,
   nclk,
   pc_fu_debug_mux_ctrls,
   pc_fu_event_count_mode,
   pc_fu_instr_trace_mode,
   pc_fu_instr_trace_tid,
   pc_fu_ram_active,
   pc_fu_trace_bus_enable,
   pc_fu_event_bus_enable,
   event_bus_in,
   event_bus_out,
   rv_axu0_ex0_instr,

   rv_axu0_ex0_t1_p,
   rv_axu0_ex0_t1_v,
   rv_axu0_ex0_t2_p,
   rv_axu0_ex0_t3_p,
   rv_axu0_ex0_ucode,

   rv_axu0_ex0_itag,
   rv_axu0_vld,
   sg_1,
   slowspr_addr_in,
   slowspr_data_in,
   slowspr_done_in,
   slowspr_etid_in,
   slowspr_rw_in,
   slowspr_val_in,
   thold_1,

   lq_fu_ex5_abort,
   xu_fu_ex4_eff_addr,
   xu_fu_msr_fe0,
   xu_fu_msr_fe1,
   xu_fu_msr_fp,
   xu_fu_msr_gs,
   xu_fu_msr_pr,


   gnd,

   vdd,

   axu0_cr_w4a,
   axu0_cr_w4d,
   axu0_cr_w4e,
   axu0_iu_async_fex,
   axu0_iu_exception,
   axu0_iu_exception_val,
   axu0_iu_execute_vld,
   axu0_iu_flush2ucode,
   axu0_iu_flush2ucode_type,
   axu0_iu_itag,
   axu0_iu_n_flush,
   axu0_iu_n_np1_flush,
   axu0_iu_np1_flush,
   axu0_iu_perf_events,
   axu0_rv_itag,
   axu0_rv_itag_vld,
   axu0_rv_itag_abort,
   axu0_rv_ord_complete,
   axu1_iu_exception,
   axu1_iu_exception_val,
   axu1_iu_execute_vld,
   axu1_iu_flush2ucode,
   axu1_iu_flush2ucode_type,
   axu1_iu_itag,
   axu1_iu_n_flush,
   axu1_iu_np1_flush,
   axu1_iu_perf_events,
   axu1_rv_itag,
   axu1_rv_itag_vld,
   axu1_rv_itag_abort,
   bcfg_scan_out,
   ccfg_scan_out,
   dcfg_scan_out,
   f_dcd_msr_fp_act,
   f_dcd_ex1_sto_act,
   f_dcd_ex1_mad_act,

   f_dcd_ex1_aop_valid,
   f_dcd_ex1_bop_valid,
   f_dcd_ex1_thread,
   f_dcd_ex1_bypsel_a_load0,
   f_dcd_ex1_bypsel_a_load1,
   f_dcd_ex1_bypsel_a_load2,
   f_dcd_ex1_bypsel_a_reload0,
   f_dcd_ex1_bypsel_a_reload1,
   f_dcd_ex1_bypsel_a_reload2,

   f_dcd_ex1_bypsel_a_res0,
   f_dcd_ex1_bypsel_a_res1,
   f_dcd_ex1_bypsel_a_res2,
   f_dcd_ex1_bypsel_b_load0,
   f_dcd_ex1_bypsel_b_load1,
   f_dcd_ex1_bypsel_b_load2,
   f_dcd_ex1_bypsel_b_reload0,
   f_dcd_ex1_bypsel_b_reload1,
   f_dcd_ex1_bypsel_b_reload2,

   f_dcd_ex1_bypsel_b_res0,
   f_dcd_ex1_bypsel_b_res1,
   f_dcd_ex1_bypsel_b_res2,
   f_dcd_ex1_bypsel_c_load0,
   f_dcd_ex1_bypsel_c_load1,
   f_dcd_ex1_bypsel_c_load2,
   f_dcd_ex1_bypsel_c_reload0,
   f_dcd_ex1_bypsel_c_reload1,
   f_dcd_ex1_bypsel_c_reload2,

   f_dcd_ex1_bypsel_c_res0,
   f_dcd_ex1_bypsel_c_res1,
   f_dcd_ex1_bypsel_c_res2,
   f_dcd_ex1_bypsel_s_load0,
   f_dcd_ex1_bypsel_s_load1,
   f_dcd_ex1_bypsel_s_load2,
   f_dcd_ex1_bypsel_s_reload0,
   f_dcd_ex1_bypsel_s_reload1,
   f_dcd_ex1_bypsel_s_reload2,

   f_dcd_ex1_bypsel_s_res0,
   f_dcd_ex1_bypsel_s_res1,
   f_dcd_ex1_bypsel_s_res2,
   f_dcd_ex1_compare_b,
   f_dcd_ex1_cop_valid,
   f_dcd_ex1_divsqrt_cr_bf,
   f_dcd_axucr0_deno,
   f_dcd_ex1_emin_dp,
   f_dcd_ex1_emin_sp,
   f_dcd_ex1_est_recip_b,
   f_dcd_ex1_est_rsqrt_b,
   f_dcd_ex1_force_excp_dis,
   f_dcd_ex1_force_pass_b,
   f_dcd_ex1_fpscr_addr,
   f_dcd_ex1_fpscr_bit_data_b,
   f_dcd_ex1_fpscr_bit_mask_b,
   f_dcd_ex1_fpscr_nib_mask_b,
   f_dcd_ex1_from_integer_b,
   f_dcd_ex1_frsp_b,
   f_dcd_ex1_fsel_b,
   f_dcd_ex1_ftdiv,
   f_dcd_ex1_ftsqrt,
   f_dcd_ex1_instr_frt,
   f_dcd_ex1_instr_tid,
   f_dcd_ex1_inv_sign_b,
   f_dcd_ex1_itag,
   f_dcd_ex1_log2e_b,
   f_dcd_ex1_math_b,
   f_dcd_ex1_mcrfs_b,
   f_dcd_ex1_move_b,
   f_dcd_ex1_mtfsbx_b,
   f_dcd_ex1_mtfsf_b,
   f_dcd_ex1_mtfsfi_b,
   f_dcd_ex1_mv_from_scr_b,
   f_dcd_ex1_mv_to_scr_b,
   f_dcd_ex1_nj_deni,
   f_dcd_ex1_nj_deno,
   f_dcd_ex1_op_rnd_b,
   f_dcd_ex1_op_rnd_v_b,
   f_dcd_ex1_ordered_b,
   f_dcd_ex1_pow2e_b,
   f_dcd_ex1_prenorm_b,
   f_dcd_ex1_rnd_to_int_b,
   f_dcd_ex1_sgncpy_b,
   f_dcd_ex1_sign_ctl_b,
   f_dcd_ex1_sp,
   f_dcd_ex1_sp_conv_b,
   f_dcd_ex1_sto_dp,
   f_dcd_ex1_sto_sp,
   f_dcd_ex1_sto_wd,
   f_dcd_ex1_sub_op_b,
   f_dcd_ex1_thread_b,
   f_dcd_ex1_to_integer_b,
   f_dcd_ex1_uc_end,
   f_dcd_ex1_uc_fa_pos,
   f_dcd_ex1_uc_fb_0_5,
   f_dcd_ex1_uc_fb_0_75,
   f_dcd_ex1_uc_fb_1_0,
   f_dcd_ex1_uc_fb_pos,
   f_dcd_ex1_uc_fc_0_5,
   f_dcd_ex1_uc_fc_1_0,
   f_dcd_ex1_uc_fc_1_minus,
   f_dcd_ex1_uc_fc_hulp,
   f_dcd_ex1_uc_fc_pos,
   f_dcd_ex1_uc_ft_neg,
   f_dcd_ex1_uc_ft_pos,
   f_dcd_ex1_uc_mid,
   f_dcd_ex1_uc_special,
   f_dcd_ex1_uns_b,
   f_dcd_ex1_word_b,
   f_dcd_ex2_divsqrt_v,
   f_dcd_ex2_divsqrt_hole_v,
   f_dcd_ex3_uc_gs,
   f_dcd_ex3_uc_gs_v,
   f_dcd_ex3_uc_inc_lsb,
   f_dcd_ex3_uc_vxidi,
   f_dcd_ex3_uc_vxsnan,
   f_dcd_ex3_uc_vxsqrt,
   f_dcd_ex3_uc_vxzdz,
   f_dcd_ex3_uc_zx,
   f_dcd_ex6_frt_tid,
   f_dcd_ex7_cancel,
   f_dcd_ex7_fpscr_addr,
   f_dcd_ex7_fpscr_wr,
   f_dcd_ex7_frt_addr,
   f_dcd_ex7_frt_tid,
   f_dcd_ex7_frt_wen,
   f_dcd_flush,
   f_dcd_rf0_fra,
   f_dcd_rf0_frb,
   f_dcd_rf0_frc,
   f_dcd_rf0_tid,
   f_dcd_ex0_div,
   f_dcd_ex0_divs,
   f_dcd_ex0_record_v,
   f_dcd_ex0_sqrt,
   f_dcd_ex0_sqrts,
   f_dcd_ex1_sto_v,
   f_dcd_so,
   fu_lq_ex2_store_data_val,
   fu_lq_ex2_store_itag,
   fu_lq_ex3_abort,
   fu_lq_ex3_sto_parity_err,
   axu0_rv_ex2_s1_abort,
   axu0_rv_ex2_s2_abort,
   axu0_rv_ex2_s3_abort,

   fu_pc_err_regfile_parity,
   fu_pc_err_regfile_ue,

   fu_pc_ram_data,
   fu_pc_ram_data_val,

   slowspr_addr_out,
   slowspr_data_out,
   slowspr_done_out,
   slowspr_etid_out,
   slowspr_rw_out,
   slowspr_val_out,
   rf0_act_b
);
   parameter                                EFF_IFAR = 62;
   parameter                                THREADS = 2;
   parameter                                ITAG_SIZE_ENC = 7;
   parameter                                THREAD_POOL_ENC = 1;
   parameter                                CR_POOL_ENC = 5;
   parameter                                REGMODE = 6;		//32 or 64 bit mode
   // INPUTS
   input                                    act_dis;
   input                                    bcfg_scan_in;
   input                                    ccfg_scan_in;
   input                                    cfg_sl_thold_1;
   input                                    func_slp_sl_thold_1;

   input                                    clkoff_b;		// tiup
   input [0:`THREADS-1]                      cp_flush;
   input                                    dcfg_scan_in;

   // Pass Thru Debug Trace Bus
   input [0:31]                             debug_bus_in;
   input [0:3]                              coretrace_ctrls_in;

   output [0:31]                            debug_bus_out;
   output [0:3]                             coretrace_ctrls_out;

   output                                   f_dcd_perr_sm_running;
   output                                   f_dcd_ex2_perr_force_c;
   output                                   f_dcd_ex2_perr_fsel_ovrd;


   input [0:9]                              delay_lclkr;		// tidn,
   input [0:3]                              f_add_ex5_fpcc_iu;
   input                                    f_dcd_si;
   input [0:6]                              f_dsq_ex5_divsqrt_itag;
   input [0:1]                              f_dsq_ex5_divsqrt_v;
   input [0:4]                              f_dsq_ex6_divsqrt_cr_bf;
   input [0:5]                              f_dsq_ex6_divsqrt_fpscr_addr;
   input [0:5]                              f_dsq_ex6_divsqrt_instr_frt;
   input [0:3]                              f_dsq_ex6_divsqrt_instr_tid;
   input                                    f_dsq_ex6_divsqrt_record_v;
   input [0:1]                              f_dsq_ex6_divsqrt_v;
   input                                    f_dsq_ex6_divsqrt_v_suppress;

   input [0:63] 			    f_dsq_debug;

   input                                    f_dsq_ex3_hangcounter_trigger;

   output                                   f_dcd_rv_hold_all;


   input                                    f_ex3_b_den_flush;
   input [0:7]                              f_fpr_ex6_load_addr;
   input                                    f_fpr_ex6_load_v;
   input [0:7]                              f_fpr_ex6_reload_addr;
   input                                    f_fpr_ex6_reload_v;
   input                                    f_mad_ex3_a_parity_check;
   input                                    f_mad_ex3_b_parity_check;
   input                                    f_mad_ex3_c_parity_check;
   input                                    f_mad_ex4_uc_res_sign;
   input [0:1]                              f_mad_ex4_uc_round_mode;
   input                                    f_mad_ex4_uc_special;
   input                                    f_mad_ex4_uc_vxidi;
   input                                    f_mad_ex4_uc_vxsnan;
   input                                    f_mad_ex4_uc_vxsqrt;
   input                                    f_mad_ex4_uc_vxzdz;
   input                                    f_mad_ex4_uc_zx;
   input                                    f_mad_ex7_uc_sign;
   input                                    f_mad_ex7_uc_zero;
   input                                    f_pic_ex6_fpr_wr_dis_b;
   input                                    f_pic_ex6_scr_upd_move_b;
   input [1:13]                             f_rnd_ex7_res_expo;
   input [0:52]                             f_rnd_ex7_res_frac;
   input                                    f_rnd_ex7_res_sign;
   input [0:3]                              f_scr_cpl_fx_thread0;
   input [0:3]                              f_scr_cpl_fx_thread1;
   input [0:3]                              f_scr_ex8_cr_fld;
   input [0:3]                              f_scr_ex8_fx_thread0;
   input [0:3]                              f_scr_ex8_fx_thread1;
   input                                    f_scr_ex6_fpscr_ni_thr0;
   input                                    f_scr_ex6_fpscr_ni_thr1;
   input                                    f_sto_ex3_s_parity_check;
   input                                    flush;		// ??tidn??
   input [0:`THREADS-1]                      iu_fu_rf0_tid;
   input [0:5]                              iu_fu_rf0_fra;
   input                                    iu_fu_rf0_fra_v;
   input [0:5]                              iu_fu_rf0_frb;
   input                                    iu_fu_rf0_frb_v;
   input [0:5]                              iu_fu_rf0_frc;
   input                                    iu_fu_rf0_frc_v;
   input                                    iu_fu_rf0_instr_match;
   input [0:9]                              mpw1_b;
   input [0:1]                              mpw2_b;
   input  [0:`NCLK_WIDTH-1]                 nclk;
   input [0:10]                             pc_fu_debug_mux_ctrls;
   input [0:2]                              pc_fu_event_count_mode;
   input                                    pc_fu_instr_trace_mode;
   input [0:1]                              pc_fu_instr_trace_tid;
   input [0:`THREADS-1]                      pc_fu_ram_active;
   input                                    pc_fu_trace_bus_enable;
   input                                    pc_fu_event_bus_enable;
   input  [0:4*`THREADS-1] 		    event_bus_in;
   output [0:4*`THREADS-1] 		    event_bus_out;


   input [0:31]                             rv_axu0_ex0_instr;

   input [0:5]                              rv_axu0_ex0_t1_p;
   input                                    rv_axu0_ex0_t1_v;
   input [0:5]                              rv_axu0_ex0_t2_p;
   input [0:5]                              rv_axu0_ex0_t3_p;
   input [0:2]                              rv_axu0_ex0_ucode;

   input [0:6]                              rv_axu0_ex0_itag;
   input [0:`THREADS-1]                      rv_axu0_vld;
   input                                    sg_1;
   input [0:9]                              slowspr_addr_in;
   input [64-(2**REGMODE):63]               slowspr_data_in;
   input                                    slowspr_done_in;
   input [0:1]                              slowspr_etid_in;
   input                                    slowspr_rw_in;
   input                                    slowspr_val_in;
   input                                    thold_1;

   input [59:63]                            xu_fu_ex4_eff_addr;
   input [0:`THREADS-1]                      xu_fu_msr_fe0;
   input [0:`THREADS-1]                      xu_fu_msr_fe1;
   input [0:`THREADS-1]                      xu_fu_msr_fp;
   input [0:`THREADS-1]                      xu_fu_msr_gs;
   input [0:`THREADS-1]                      xu_fu_msr_pr;

   input                                    lq_fu_ex5_abort;

   // INOUTS
   inout                                    gnd;
   inout                                    vdd;

   // OUTPUTS
   output [0:CR_POOL_ENC+THREAD_POOL_ENC-1] axu0_cr_w4a;		//: out std_ulogic_vector(0 to 4);
   output [0:3]                             axu0_cr_w4d;
   output                                   axu0_cr_w4e;
   output [0:`THREADS-1]                     axu0_iu_async_fex;
   output [0:3]                             axu0_iu_exception;
   output                                   axu0_iu_exception_val;
   output [0:`THREADS-1]                     axu0_iu_execute_vld;
   output                                   axu0_iu_flush2ucode;
   output                                   axu0_iu_flush2ucode_type;
   output [0:6]                             axu0_iu_itag;
   output                                   axu0_iu_n_flush;
   output                                   axu0_iu_n_np1_flush;
   output                                   axu0_iu_np1_flush;
   output [0:6]                             axu0_rv_itag;
   output [0:`THREADS-1]                     axu0_rv_itag_vld;
   output 				    axu0_rv_itag_abort;
   output                                   axu0_rv_ord_complete;
   output [0:3]                             axu0_iu_perf_events;

   output [0:3]                             axu1_iu_exception;
   output                                   axu1_iu_exception_val;
   output [0:`THREADS-1]                     axu1_iu_execute_vld;
   output                                   axu1_iu_flush2ucode;
   output                                   axu1_iu_flush2ucode_type;
   output [0:6]                             axu1_iu_itag;
   output                                   axu1_iu_n_flush;
   output                                   axu1_iu_np1_flush;
   output [0:6]                             axu1_rv_itag;
   output [0:`THREADS-1]                     axu1_rv_itag_vld;
   output 				    axu1_rv_itag_abort;
   output [0:3]                             axu1_iu_perf_events;

   output                                   bcfg_scan_out;
   output                                   ccfg_scan_out;
   output                                   dcfg_scan_out;
   output                                   f_dcd_ex1_sto_act;
   output                                   f_dcd_ex1_mad_act;
   output                                   f_dcd_msr_fp_act;

   output                                   f_dcd_ex1_aop_valid;
   output                                   f_dcd_ex1_bop_valid;
   output [0:1]                             f_dcd_ex1_thread;
   output                                   f_dcd_ex1_bypsel_a_load0;
   output                                   f_dcd_ex1_bypsel_a_load1;
   output                                   f_dcd_ex1_bypsel_a_load2;
   output                                   f_dcd_ex1_bypsel_a_reload0;
   output                                   f_dcd_ex1_bypsel_a_reload1;
   output                                   f_dcd_ex1_bypsel_a_reload2;

   output                                   f_dcd_ex1_bypsel_a_res0;
   output                                   f_dcd_ex1_bypsel_a_res1;
   output                                   f_dcd_ex1_bypsel_a_res2;
   output                                   f_dcd_ex1_bypsel_b_load0;
   output                                   f_dcd_ex1_bypsel_b_load1;
   output                                   f_dcd_ex1_bypsel_b_load2;
   output                                   f_dcd_ex1_bypsel_b_reload0;
   output                                   f_dcd_ex1_bypsel_b_reload1;
   output                                   f_dcd_ex1_bypsel_b_reload2;

   output                                   f_dcd_ex1_bypsel_b_res0;
   output                                   f_dcd_ex1_bypsel_b_res1;
   output                                   f_dcd_ex1_bypsel_b_res2;
   output                                   f_dcd_ex1_bypsel_c_load0;
   output                                   f_dcd_ex1_bypsel_c_load1;
   output                                   f_dcd_ex1_bypsel_c_load2;
   output                                   f_dcd_ex1_bypsel_c_reload0;
   output                                   f_dcd_ex1_bypsel_c_reload1;
   output                                   f_dcd_ex1_bypsel_c_reload2;

   output                                   f_dcd_ex1_bypsel_c_res0;
   output                                   f_dcd_ex1_bypsel_c_res1;
   output                                   f_dcd_ex1_bypsel_c_res2;
   output                                   f_dcd_ex1_bypsel_s_load0;
   output                                   f_dcd_ex1_bypsel_s_load1;
   output                                   f_dcd_ex1_bypsel_s_load2;
   output                                   f_dcd_ex1_bypsel_s_reload0;
   output                                   f_dcd_ex1_bypsel_s_reload1;
   output                                   f_dcd_ex1_bypsel_s_reload2;

   output                                   f_dcd_ex1_bypsel_s_res0;
   output                                   f_dcd_ex1_bypsel_s_res1;
   output                                   f_dcd_ex1_bypsel_s_res2;
   output                                   f_dcd_ex1_compare_b;		// fcomp*
   output                                   f_dcd_ex1_cop_valid;
   output [0:4]                             f_dcd_ex1_divsqrt_cr_bf;
   output                                   f_dcd_axucr0_deno;

   output                                   f_dcd_ex1_emin_dp;		// prenorm_dp
   output                                   f_dcd_ex1_emin_sp;		// prenorm_sp, frsp
   output                                   f_dcd_ex1_est_recip_b;		// fres
   output                                   f_dcd_ex1_est_rsqrt_b;		// frsqrte
   output                                   f_dcd_ex1_force_excp_dis;		// force all exceptions disabled


   output                                   f_dcd_ex1_force_pass_b;		// fmr,fnabbs,fabs,fneg,mtfsf
   output [0:5]                             f_dcd_ex1_fpscr_addr;
   output [0:3]                             f_dcd_ex1_fpscr_bit_data_b;		//data to write to nibble (other than mtfsf)
   output [0:3]                             f_dcd_ex1_fpscr_bit_mask_b;		//enable update of bit within the nibble
   output [0:8]                             f_dcd_ex1_fpscr_nib_mask_b;		//enable update of this nibble
   output                                   f_dcd_ex1_from_integer_b;		// fcfid (signed integer)
   output                                   f_dcd_ex1_frsp_b;		// round-to-single-precision ?? need
   output                                   f_dcd_ex1_fsel_b;		// fsel
   output                                   f_dcd_ex1_ftdiv;
   output                                   f_dcd_ex1_ftsqrt;
   output [0:5]                             f_dcd_ex1_instr_frt;
   output [0:3]                             f_dcd_ex1_instr_tid;
   output                                   f_dcd_ex1_inv_sign_b;		// fnmsub fnmadd
   output [0:6]                             f_dcd_ex1_itag;
   output                                   f_dcd_ex1_log2e_b;
   output                                   f_dcd_ex1_math_b;		// fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
   output                                   f_dcd_ex1_mcrfs_b;		//move fpscr field to cr and reset exceptions
   output                                   f_dcd_ex1_move_b;		// fmr,fneg,fabs,fnabs
   output                                   f_dcd_ex1_mtfsbx_b;		//fpscr set bit, reset bit
   output                                   f_dcd_ex1_mtfsf_b;		//move fpr data to fpscr
   output                                   f_dcd_ex1_mtfsfi_b;		//move immediate data to fpscr
   output                                   f_dcd_ex1_mv_from_scr_b;		//mffs
   output                                   f_dcd_ex1_mv_to_scr_b;		//mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
   output                                   f_dcd_ex1_nj_deni;		// force input den to zero
   output                                   f_dcd_ex1_nj_deno;		// force output den to zero
   output [0:1]                             f_dcd_ex1_op_rnd_b;		// rounding mode = positive infinity
   output                                   f_dcd_ex1_op_rnd_v_b;		// rounding mode = nearest
   output                                   f_dcd_ex1_ordered_b;		// fcompo
   output                                   f_dcd_ex1_pow2e_b;
   output                                   f_dcd_ex1_prenorm_b;		// prenorm ?? need
   output                                   f_dcd_ex1_rnd_to_int_b;		// fri*
   output                                   f_dcd_ex1_sgncpy_b;		// for sgncpy instruction :
   output [0:1]                             f_dcd_ex1_sign_ctl_b;		// 0:fmr/fnabs  1:fneg/fnabs
   output                                   f_dcd_ex1_sp;		// off for frsp
   output                                   f_dcd_ex1_sp_conv_b;		// for sp/dp convert
   output                                   f_dcd_ex1_sto_dp;
   output                                   f_dcd_ex1_sto_sp;
   output                                   f_dcd_ex1_sto_wd;
   output                                   f_dcd_ex1_sub_op_b;		// fsub, fnmsub, fmsub
   output [0:3]                             f_dcd_ex1_thread_b;
   output                                   f_dcd_ex1_to_integer_b;		// fcti* (signed integer 32/64)
   output                                   f_dcd_ex1_uc_end;
   output                                   f_dcd_ex1_uc_fa_pos;
   output                                   f_dcd_ex1_uc_fb_0_5;
   output                                   f_dcd_ex1_uc_fb_0_75;
   output                                   f_dcd_ex1_uc_fb_1_0;
   output                                   f_dcd_ex1_uc_fb_pos;
   output                                   f_dcd_ex1_uc_fc_0_5;
   output                                   f_dcd_ex1_uc_fc_1_0;
   output                                   f_dcd_ex1_uc_fc_1_minus;
   output                                   f_dcd_ex1_uc_fc_hulp;
   output                                   f_dcd_ex1_uc_fc_pos;
   output                                   f_dcd_ex1_uc_ft_neg;
   output                                   f_dcd_ex1_uc_ft_pos;
   output                                   f_dcd_ex1_uc_mid;
   output                                   f_dcd_ex1_uc_special;
   output                                   f_dcd_ex1_uns_b;		// for converts unsigned
   output                                   f_dcd_ex1_word_b;		// fctiw*
   output                                   f_dcd_ex2_divsqrt_v;
   output                                   f_dcd_ex2_divsqrt_hole_v;
   output [0:1]                             f_dcd_ex3_uc_gs;
   output                                   f_dcd_ex3_uc_gs_v;
   output                                   f_dcd_ex3_uc_inc_lsb;
   output                                   f_dcd_ex3_uc_vxidi;
   output                                   f_dcd_ex3_uc_vxsnan;
   output                                   f_dcd_ex3_uc_vxsqrt;
   output                                   f_dcd_ex3_uc_vxzdz;
   output                                   f_dcd_ex3_uc_zx;
   output [0:1]                             f_dcd_ex6_frt_tid;
   output                                   f_dcd_ex7_cancel;
   output [0:5]                             f_dcd_ex7_fpscr_addr;
   output                                   f_dcd_ex7_fpscr_wr;
   output [0:5]                             f_dcd_ex7_frt_addr;
   output [0:1]                             f_dcd_ex7_frt_tid;
   output                                   f_dcd_ex7_frt_wen;
   output [0:1]                             f_dcd_flush;
   output [0:5]                             f_dcd_rf0_fra;
   output [0:5]                             f_dcd_rf0_frb;
   output [0:5]                             f_dcd_rf0_frc;
   output [0:1] 			    f_dcd_rf0_tid;

   output                                   f_dcd_ex0_div;
   output                                   f_dcd_ex0_divs;
   output                                   f_dcd_ex0_record_v;
   output                                   f_dcd_ex0_sqrt;
   output                                   f_dcd_ex0_sqrts;
   output                                   f_dcd_ex1_sto_v;

   output                                   f_dcd_so;
   output [0:`THREADS-1]                     fu_lq_ex2_store_data_val;
   output [0:ITAG_SIZE_ENC-1]               fu_lq_ex2_store_itag;
   output                                   fu_lq_ex3_abort;
   output                                   fu_lq_ex3_sto_parity_err;
   output                                   axu0_rv_ex2_s1_abort;
   output                                   axu0_rv_ex2_s2_abort;
   output                                   axu0_rv_ex2_s3_abort;
   output [0:`THREADS-1]                    fu_pc_err_regfile_parity;
   output [0:`THREADS-1]                    fu_pc_err_regfile_ue;

   output [0:63]                            fu_pc_ram_data;
   output                                   fu_pc_ram_data_val;

   output [0:9]                             slowspr_addr_out;
   output [64-(2**REGMODE):63]              slowspr_data_out;
   output                                   slowspr_done_out;
   output [0:1]                             slowspr_etid_out;
   output                                   slowspr_rw_out;
   output                                   slowspr_val_out;

   output                                   rf0_act_b;
   // This entity contains macros


   // ###################### CONSTANTS ###################### --
   parameter [32:63]                        EVENTMUX_32_MASK = 32'b11111111111111111111111111111111;

   // ####################### SIGNALS ####################### --
   wire [0:7]                               act_lat_si;
   wire [0:7]                               act_lat_so;
   wire [0:3]                               axu_ex_si;
   wire [0:3]                               axu_ex_so;
   wire                                     cp_flush_reg0_si;
   wire                                     cp_flush_reg0_so;
   wire                                     cp_flush_reg1_si;
   wire                                     cp_flush_reg1_so;
   wire                                     axucr0_dec;
   wire [60:63]                             axucr0_din;
   wire [0:3]                               axucr0_lat_si;
   wire [0:3]                               axucr0_lat_so;
   wire [60:63]                             axucr0_q;
   wire [32:63]                             axucr0_out;
   wire                                     axucr0_rd;
   wire                                     axucr0_wr;
   wire                                     a0esr_dec;
   wire [32:63]                             a0esr_din;
   wire [0:31]                              a0esr_lat_si;
   wire [0:31]                              a0esr_lat_so;
   wire [32:63]                             a0esr_q;
   wire                                     a0esr_rd;
   wire                                     a0esr_wr;
   wire [0:31]                              a0esr_event_mux_ctrls;

   wire                                     cfg_sl_force;
   wire                                     cfg_sl_thold_0;
   wire                                     cfg_sl_thold_0_b;
   wire [0:1]                               cp_flush_q;
   wire [0:1]                               cp_flush_int;
   wire                                     dbg0_act;
   wire                                     event_act;

   wire [0:67]                              dbg0_data_si;
   wire [0:67]                              dbg0_data_so;

   wire [0:4]                               dbg1_data_si;
   wire [0:4]                               dbg1_data_so;
   wire [0:63]                              dbg_group0;
   wire [0:63]                              dbg_group1;
   wire [0:63]                              dbg_group2;
   wire [0:63]                              dbg_group3;
   wire [0:31]                              dbg_group3_din;
   wire [0:31]                              dbg_group3_q;

   wire [0:31]                              debug_data_d;
   wire [0:31]                              debug_data_q;
   wire [0:10]                              debug_mux_ctrls_muxed;
   wire [0:10]                              debug_mux_ctrls_q;
   wire [0:10]                              debug_mux_ctrls_d;

   wire [0:3]                               coretrace_ctrls_out_d;
   wire [0:3]                               coretrace_ctrls_out_q;


   wire [0:1]                               evnt_axu_cr_cmt;
   wire [0:1]                               evnt_axu_idle;
   wire [0:1]                               evnt_axu_instr_cmt;
   wire [0:1]                               evnt_denrm_flush;
   wire [0:1]                               evnt_div_sqrt_ip;
   wire [0:1]                               evnt_fpu_fex;
   wire [0:1]                               evnt_fpu_fx;
   wire [0:1]                               evnt_fpu_cpl_fex;
   wire [0:1]                               evnt_fpu_cpl_fx;

   wire                                     ex2_axu_v;


   wire [0:1]                               evnt_uc_instr_cmt;


   wire [0:23]                              ex0_frt_si;
   wire [0:23]                              ex0_frt_so;

   wire [0:5]                               ex0_instr_fra;
   wire                                     ex0_instr_fra_v;
   wire [0:5]                               ex0_instr_frb;
   wire                                     ex0_instr_frb_v;
   wire [0:5]                               ex0_instr_frc;
   wire                                     ex0_instr_frc_v;
   wire [0:5]                               ex0_instr_frs;
   wire                                     ex0_instr_match;
   wire                                     ex1_instr_act;

   wire [0:3]                               ex0_instr_v;
   wire [0:3]                               ex0_instr_valid;
   wire                                     ex0_instr_vld;
   wire                                     ex0_isRam;
   wire                                     ex0_is_ucode;
   wire [0:6]                               ex0_itag;

   wire [64-(2**REGMODE):63]                slowspr_data_out_int;
   wire                                     slowspr_done_out_int;

   wire [0:7]                               ex0_iu_si;
   wire [0:7]                               ex0_iu_so;

   wire                                     ex0_ucode_preissue;

   wire                                     ex1_axu_v;
   wire                                     ex1_byp_a;
   wire                                     ex1_byp_b;
   wire                                     ex1_byp_c;

   wire                                     ex1_bypsel_a_load3;
   wire                                     ex1_bypsel_b_load3;
   wire                                     ex1_bypsel_c_load3;
   wire                                     ex1_bypsel_s_load3;

   wire                                     ex1_bypsel_a_load0;
   wire                                     ex1_bypsel_a_load1;
   wire                                     ex1_bypsel_a_load2;
   wire                                     ex1_bypsel_a_reload0;
   wire                                     ex1_bypsel_a_reload1;
   wire                                     ex1_bypsel_a_reload2;

   wire                                     ex1_bypsel_a_res0;
   wire                                     ex1_bypsel_a_res1;
   wire                                     ex1_bypsel_a_res2;
   wire                                     ex1_bypsel_b_load0;
   wire                                     ex1_bypsel_b_load1;
   wire                                     ex1_bypsel_b_load2;
   wire                                     ex1_bypsel_b_reload0;
   wire                                     ex1_bypsel_b_reload1;
   wire                                     ex1_bypsel_b_reload2;

   wire                                     ex1_bypsel_b_res0;
   wire                                     ex1_bypsel_b_res1;
   wire                                     ex1_bypsel_b_res2;
   wire                                     ex1_bypsel_c_load0;
   wire                                     ex1_bypsel_c_load1;
   wire                                     ex1_bypsel_c_load2;
   wire                                     ex1_bypsel_c_reload0;
   wire                                     ex1_bypsel_c_reload1;
   wire                                     ex1_bypsel_c_reload2;

   wire                                     ex1_bypsel_c_res0;
   wire                                     ex1_bypsel_c_res1;
   wire                                     ex1_bypsel_c_res2;
   wire                                     ex1_bypsel_s_load0;
   wire                                     ex1_bypsel_s_load1;
   wire                                     ex1_bypsel_s_load2;
   wire                                     ex1_bypsel_s_reload0;
   wire                                     ex1_bypsel_s_reload1;
   wire                                     ex1_bypsel_s_reload2;

   wire                                     ex1_bypsel_s_res0;
   wire                                     ex1_bypsel_s_res1;
   wire                                     ex1_bypsel_s_res2;
   wire [0:4]                               ex1_cr_bf;
   wire                                     ex1_cr_val;
   wire [0:4]                               ex1_crbf_si;
   wire [0:4]                               ex1_crbf_so;

   wire                                     ex1_dp;
   wire                                     ex1_dporsp;
   wire                                     ex1_expte;
   wire                                     ex1_fabs;
   wire                                     ex1_fadd;
   wire                                     ex1_fcfid;
   wire                                     ex1_fcfids;
   wire                                     ex1_fcfidu;
   wire                                     ex1_fcfidus;
   wire                                     ex1_fcfiwu;
   wire                                     ex1_fcfiwus;
   wire                                     ex1_fcmpo;
   wire                                     ex1_fcmpu;
   wire                                     ex1_fcpsgn;
   wire                                     ex1_fctid;
   wire                                     ex1_fctidu;
   wire                                     ex1_fctiduz;
   wire                                     ex1_fctidz;
   wire                                     ex1_fctiw;
   wire                                     ex1_fctiwu;
   wire                                     ex1_fctiwuz;
   wire                                     ex1_fctiwz;
   wire                                     ex1_fdiv;
   wire                                     ex1_fdivs;
   wire [0:1]                               ex1_fdivsqrt_start;
   wire [0:1]                               ex1_fdivsqrt_start_din;
   wire                                     ex1_fmadd;
   wire                                     ex1_fmr;
   wire                                     ex1_fmsub;
   wire                                     ex1_fmul;
   wire                                     ex1_fnabs;
   wire                                     ex1_fneg;
   wire                                     ex1_fnmadd;
   wire                                     ex1_fnmsub;
   wire [0:5]                               ex1_fpscr_addr;
   wire [0:3]                               ex1_fpscr_bit_data;
   wire [0:3]                               ex1_fpscr_bit_mask;
   wire                                     ex1_fpscr_moves;
   wire [0:8]                               ex1_fpscr_nib_mask;
   wire                                     ex1_fpscr_wen;
   wire                                     ex1_fpscr_wen_din;
   wire                                     ex1_fra_v;
   wire                                     ex1_frb_v;
   wire                                     ex1_frc_v;
   wire                                     ex1_fres;
   wire                                     ex1_frim;
   wire                                     ex1_frin;
   wire                                     ex1_frip;
   wire                                     ex1_friz;
   wire                                     ex1_from_ints;
   wire                                     ex1_frs_byp;
   wire                                     ex1_frsp;
   wire                                     ex1_frsqrte;
   wire [0:29]                              ex1_frt_si;
   wire [0:29]                              ex1_frt_so;
   wire                                     ex1_fsel;
   wire                                     ex1_fsqrt;
   wire                                     ex1_fsqrts;
   wire                                     ex1_fsub;
   wire                                     ex1_ftdiv;
   wire                                     ex1_ftsqrt;

   wire [0:31]                              ex1_instl_si;
   wire [0:31]                              ex1_instl_so;
   wire [0:31]                              ex1_instr;
   wire [0:5]                               ex1_instr_fra;
   wire                                     ex1_instr_fra_v;
   wire [0:5]                               ex1_instr_frb;
   wire                                     ex1_instr_frb_v;
   wire [0:5]                               ex1_instr_frc;
   wire                                     ex1_instr_frc_v;
   wire [0:5]                               ex1_instr_frs;
   wire [0:5]                               ex1_instr_frt;
   wire                                     ex1_instr_match;
   wire [0:3]                               ex1_instr_v;
   wire [0:3]                               ex1_instr_valid;

   wire                                     ex1_instr_v1_bufw;
   wire                                     ex1_instr_v1_bufx;
   wire                                     ex1_instr_v1_bufy;
   wire                                     ex1_instr_v1_bufz;

   wire                                     ex1_isRam;
   wire                                     ex1_is_ucode;
   wire [0:6]                               ex1_itag;
   wire [0:13]                              ex1_itag_si;
   wire [0:13]                              ex1_itag_so;
   wire [0:14]                              ex1_iu_si;
   wire [0:14]                              ex1_iu_so;
   wire                                     ex1_kill_wen;


   wire                                     ex1_instr_vld;

   wire                                     ex1_loge;

   wire                                     ex1_mcrfs;
   wire [0:7]                               ex1_mcrfs_bfa;
   wire                                     ex1_mffs;
   wire                                     ex1_moves;
   wire [0:7]                               ex1_mtfs_bf;
   wire                                     ex1_mtfsb0;
   wire                                     ex1_mtfsb1;
   wire [0:3]                               ex1_mtfsb_bt;
   wire                                     ex1_mtfsf;
   wire                                     ex1_mtfsf_l;
   wire [0:7]                               ex1_mtfsf_nib;
   wire                                     ex1_mtfsf_w;
   wire                                     ex1_mtfsfi;

   wire                                     ex1_prenorm;
   wire [0:5]                               ex1_primary;
   wire                                     ex1_record;

   wire                                     ex1_rnd0;
   wire                                     ex1_rnd1;
   wire [0:4]                               ex1_sec_aform;
   wire [0:9]                               ex1_sec_xform;
   wire                                     ex1_sp;
   wire                                     ex1_str_v;
   wire [0:1]                               ex1_tid;
   wire [0:1]                               ex1_tid_bufw;
   wire [0:1]                               ex1_tid_bufx;
   wire [0:1]                               ex1_tid_bufy;
   wire [0:1]                               ex1_tid_bufz ;

   wire                                     ex1_to_ints;

   wire                                     ex1_ucode_preissue;
   wire                                     ex1_ucode_preissue_din;
   wire                                     ex1_v;
   wire [0:4]                               ex2_cr_bf;
   wire                                     ex2_cr_val;
   wire                                     ex2_cr_val_din;
   wire [0:4]                               ex2_crbf_si;
   wire [0:4]                               ex2_crbf_so;
   wire [0:20]                              ex2_ctl_si;
   wire [0:20]                              ex2_ctl_so;
   wire [0:1]                               ex2_fdivsqrt_start;
   wire [0:1]                               ex2_fdivsqrt_start_din;
   wire [0:5]                               ex2_fpscr_addr;
   wire                                     ex2_fpscr_wen;
   wire                                     ex2_fra_v;
   wire                                     ex2_fra_valid;
   wire                                     ex2_frb_v;
   wire                                     ex2_frb_valid;
   wire                                     ex2_frc_v;
   wire                                     ex2_frc_valid;
   wire                                     ex2_frs_byp;
   wire                                     ex2_frs_byp_din;
   wire [0:5]                               ex2_frt_si;
   wire [0:5]                               ex2_frt_so;

   wire [0:3]                               ex2_ifar_val;

   wire [0:5]                               ex2_instr_frt;
   wire                                     ex2_instr_match;
   wire [0:3]                               ex2_instr_v;
   wire [0:3]                               ex2_instr_valid;
   wire                                     ex2_instr_vld;
   wire                                     ex2_isRam;
   wire                                     ex2_is_ucode;
   wire [0:6]                               ex2_itag;
   wire [0:15]                              ex2_itag_si;
   wire [0:15]                              ex2_itag_so;
   wire                                     ex2_kill_wen;

   wire                                     ex2_mcrfs;

   wire                                     ex2_record;
   wire                                     ex2_str_v;
   wire                                     ex2_str_valid;

   wire                                     ex2_ucode_preissue;
   wire                                     ex2_ucode_preissue_din;
   wire                                     ex2_v;

   wire [0:4]                               ex3_cr_bf;
   wire                                     ex3_cr_val;
   wire [0:4]                               ex3_crbf_si;
   wire [0:4]                               ex3_crbf_so;
   wire [0:6]                               ex3_ctlng_si;
   wire [0:6]                               ex3_ctlng_so;
   wire [0:23]                              ex3_ctl_si;
   wire [0:23]                              ex3_ctl_so;

   wire [0:1]                               ex3_fdivsqrt_start;


   wire [0:1]                               ex3_fdivsqrt_start_din;
   wire [0:3]                               ex3_flush2ucode;




   wire [0:5]                               ex3_fpscr_addr;
   wire                                     ex3_fpscr_wen;
   wire                                     ex3_fra_v;
   wire                                     ex3_frb_v;
   wire                                     ex3_frc_v;
   wire                                     ex3_frs_byp;

   wire [0:3]                               ex3_ifar_val;

   wire [0:5]                               ex3_instr_frt;
   wire                                     ex3_instr_match;
   wire [0:3]                               ex3_instr_v;
   wire [0:3]                               ex3_instr_vns;

   wire                                     ex3_instr_vld;
   wire                                     ex4_instr_vld;
   wire                                     ex5_instr_vld;
   wire                                     ex6_instr_vld;
   wire                                     ex7_instr_vld;
   wire                                     ex8_instr_vld;
   wire                                     ex9_instr_vld;

   wire [0:7] 				    event_bus_d;
   wire [0:7] 				    event_bus_q;

   wire [0:3]                               ex3_instr_valid;
   wire                                     ex3_isRam;
   wire                                     ex3_is_ucode;
   wire [0:6]                               ex3_itag;
   wire [0:15]                              ex3_itag_si;
   wire [0:15]                              ex3_itag_so;
   wire                                     ex3_kill_wen;
   wire                                     ex3_mcrfs;
   wire [0:3]                               ex3_n_flush;

   wire                                     ex3_record;


   wire                                     ex3_stdv_si;
   wire                                     ex3_stdv_so;

   wire                                     ex3_store_v;
   wire                                     ex3_store_valid;
   wire                                     ex3_str_v;
   wire                                     ex3_ucode_preissue;
   wire                                     ex3_ucode_preissue_din;
   wire                                     ex4_b_den_flush;
   wire [0:4]                               ex4_cr_bf;
   wire                                     ex4_cr_val;
   wire [0:4]                               ex4_crbf_si;
   wire [0:4]                               ex4_crbf_so;
   wire [0:29]                              ex4_ctl_si;
   wire [0:29]                              ex4_ctl_so;
   wire [0:6]                               ex5_divsqrt_itag;
   wire [0:1]                               ex4_fdivsqrt_start;
   wire [0:1]                               ex4_fdivsqrt_start_din;
   wire [0:3]                               ex4_flush2ucode;
   wire [0:5]                               ex4_fpscr_addr;
   wire                                     ex4_fpscr_wen;
   wire [0:5]                               ex4_instr_frt;
   wire                                     ex4_instr_match;
   wire [0:3]                               ex4_instr_v;
   wire [0:3]                               ex4_instr_vns;
   wire [0:3]                               ex5_instr_vns;
   wire                                     ex3_instr_vns_taken;
   wire                                     ex4_instr_vns_taken_din;
   wire                                     ex4_instr_vns_taken;
   wire                                     ex5_instr_vns_taken;

   wire [0:3]                               ex4_instr_valid;
   wire                                     ex4_isRam;
   wire                                     ex4_is_ucode;
   wire [0:6]                               ex4_itag;
   wire [0:15]                              ex4_itag_si;
   wire [0:15]                              ex4_itag_so;
   wire                                     ex4_kill_wen;
   wire                                     ex4_mcrfs;
   wire [0:3]                               ex4_n_flush;
   wire                                     ex4_record;
   wire                                     ex7_perr_cancel;


   // parity err ---------
   wire                                     perr_sm_running;
   wire [0:5] 				    perr_addr_l2;

   wire [0:1]                               ex4_regfile_err_det;
   wire [0:1]                               ex5_regfile_err_det;
   wire [0:1]                               ex6_regfile_err_det;
   wire [0:1]                               ex7_regfile_err_det;
   wire [0:1]                               ex8_regfile_err_det;

   wire                                     ex0_regfile_ce;
   wire                                     ex0_regfile_ue;

   wire                                     ex1_perr_sm_instr_v;
   wire                                     ex2_perr_sm_instr_v;
   wire                                     ex3_perr_sm_instr_v;
   wire                                     ex4_perr_sm_instr_v;
   wire                                     ex5_perr_sm_instr_v;
   wire                                     ex6_perr_sm_instr_v;
   wire                                     ex7_perr_sm_instr_v;
   wire                                     ex8_perr_sm_instr_v;

   wire [0:2]                               perr_sm_l2;

   wire [0:1]                               perr_tid_l2;

   wire                                     ex7_is_fixperr;

   wire                                     perr_si;
   wire                                     perr_so;

   //------------- end parity

   wire                                     ex4_store_valid;
   wire                                     ex4_ucode_preissue;
   wire                                     ex4_ucode_preissue_din;
   wire                                     ex5_b_den_flush;
   wire                                     ex5_b_den_flush_din;
   wire [0:3]                               ex5_cr;
   wire [0:4]                               ex5_cr_bf;
   wire                                     ex5_cr_val;
   wire                                     ex5_cr_val_cp;
   wire [0:4]                               ex5_crbf_si;
   wire [0:4]                               ex5_crbf_so;
   wire [0:21]                              ex5_ctl_si;
   wire [0:21]                              ex5_ctl_so;
   wire [0:5]                               ex6_divsqrt_fpscr_addr;
   wire [59:63]                             ex5_eff_addr;
   wire [0:1]                               ex5_fdivsqrt_start;
   wire [0:1]                               ex5_fdivsqrt_start_din;
   wire [0:5]                               ex5_fpscr_addr;
   wire                                     ex5_fpscr_wen;
   wire                                     ex5_fu_unavail;
   wire [0:5]                               ex5_instr_frt;
   wire [0:1]                               ex5_instr_tid;
   wire [0:3]                               ex5_instr_v;
   wire [0:1]                               ex5_cr_or_divsqrt_v;
   wire [0:3]                               ex5_instr_valid;
   wire                                     ex5_isRam;
   wire                                     ex5_is_ucode;
   wire [0:6]                               ex5_itag;
   wire [0:6]                               ex5_itag_din;
   wire [0:16]                              ex5_itag_si;
   wire [0:16]                              ex5_itag_so;
   wire                                     ex5_kill_wen;
   wire                                     ex5_mcrfs;

   wire                                     ex5_record;
   wire                                     ex5_ucode_preissue;
   wire                                     ex5_ucode_preissue_din;

   wire                                     ex1_abort_a_din;
   wire                                     ex1_abort_b_din;
   wire                                     ex1_abort_c_din;
   wire                                     ex1_abort_s_din;
   wire                                     ex2_abort_a_din;
   wire                                     ex2_abort_b_din;
   wire                                     ex2_abort_c_din;
   wire                                     ex2_abort_s_din;
   wire                                     ex2_abort_a;
   wire                                     ex2_abort_b;
   wire                                     ex2_abort_c;
   wire                                     ex2_abort_s;
   wire                                     ex2_abort_a_q;
   wire                                     ex2_abort_b_q;
   wire                                     ex2_abort_c_q;
   wire                                     ex2_abort_s_q;

   wire                                     ex3_abort_a;
   wire                                     ex3_abort_b;
   wire                                     ex3_abort_c;
   wire                                     ex3_abort_s;
   wire                                     ex3_abort_din;
   wire                                     ex4_abort;

   wire                                     ex5_abort_l2;
   wire                                     ex6_abort;
   wire                                     ex6_abort_lq;
   wire                                     ex7_abort;
   wire                                     ex7_abort_lq;
   wire                                     ex8_abort;
   wire                                     ex8_abort_lq;
   wire                                     ex9_abort;
   wire                                     ex9_abort_q;
   wire                                     ex9_abort_lq;
   wire                                     ex4_abort_din;
   wire                                     ex5_abort_din;
   wire                                     ex5_abort_lq_din;
   wire                                     ex6_abort_din;
   wire                                     ex7_abort_din;
   wire                                     ex8_abort_din;


   wire                                     ex6_b_den_flush;
   wire [0:3]                               ex6_cr;
   wire [0:4]                               ex6_cr_bf;
   wire [0:4]                               ex6_cr_bf_din;
   wire                                     ex6_cr_val;
   wire                                     ex5_cr_val_din;
   wire [0:8]                               ex6_crbf_si;
   wire [0:8]                               ex6_crbf_so;
   wire [0:20]                              ex6_ctl_si;
   wire [0:20]                              ex6_ctl_so;
   wire [0:1]                               ex6_fdivsqrt_start;
   wire [0:1]                               ex6_fdivsqrt_start_din;
   wire                                     ex6_fpr_wr_dis;
   wire [0:5]                               ex6_fpscr_addr;
   wire [0:5]                               ex6_fpscr_addr_din;
   wire                                     ex6_fpscr_move;
   wire                                     ex6_fpscr_wen;
   wire                                     ex6_fpscr_wen_din;
   wire                                     ex6_fu_unavail;
   wire                                     ex6_iflush_01;
   wire                                     ex6_iflush_23;
   wire [0:3]                               ex6_iflush_b;
   wire [0:3]                               ex6_instr_bypval;
   wire                                     ex6_instr_flush;
   wire                                     ex6_instr_flush_b;
   wire [0:5]                               ex6_instr_frt;
   wire [0:5]                               ex5_instr_frt_din;
   wire [0:1]                               ex6_instr_tid;
   wire [0:3]                               ex6_instr_v;
   wire [0:3]                               ex6_instr_valid;
   wire [0:3]                               ex5_instr_valid_din;
   wire [0:3]                               ex6_instr_valid_din;
   wire                                     ex6_isRam;
   wire                                     ex6_is_ucode;
   wire [0:6]                               ex6_itag;
   wire [0:16]                              ex6_itag_si;
   wire [0:16]                              ex6_itag_so;
   wire                                     ex6_kill_wen;
   wire                                     ex5_kill_wen_din;
   wire                                     ex6_kill_wen_q;
   wire [0:7]                               ex6_load_addr;
   wire                                     ex6_load_v;
   wire [0:7]                               ex6_reload_addr;
   wire                                     ex6_reload_v;
   wire                                     ex6_mcrfs;
   wire                                     ex5_mcrfs_din;
   wire                                     ex6_record;
   wire                                     ex5_record_din;


   wire                                     ex6_ucode_preissue;
   wire                                     ex6_ucode_preissue_din;
   wire [0:1]                               ex7_ram_active;
   wire                                     ex7_b_den_flush;
   wire [0:3]                               ex7_cr;
   wire [0:4]                               ex7_cr_bf;
   wire                                     ex7_cr_val;
   wire                                     ex7_cr_val_din;
   wire [0:8]                               ex7_crbf_si;
   wire [0:8]                               ex7_crbf_so;
   wire [0:22]                              ex7_ctl_si;
   wire [0:22]                              ex7_ctl_so;
   wire [0:1]                               ex7_fdivsqrt_start;
   wire [0:1]                               ex7_fdivsqrt_start_din;
   wire                                     ex7_fpr_wr_dis;
   wire [0:5]                               ex7_fpscr_addr;
   wire                                     ex7_fpscr_move;
   wire                                     ex7_fpscr_wen;
   wire                                     ex7_fu_unavail;
   wire [0:5]                               ex7_instr_frt;
   wire [0:5]                               ex7_instr_frt_din;
   wire [0:1]                               ex7_instr_tid;
   wire [0:3]                               ex7_instr_v;
   wire [0:1]                               ex7_instr_v_din;
   wire                                     ex7_instr_valid;
   wire                                     ex7_isRam;
   wire                                     ex7_is_ucode;
   wire [0:6]                               ex7_itag;
   wire [0:17]                              ex7_itag_si;
   wire [0:17]                              ex7_itag_so;
   wire                                     ex7_kill_wen;
   wire                                     ex6_kill_wen_din;
   wire [0:17]                              ex7_laddr_si;
   wire [0:17]                              ex7_laddr_so;
   wire [0:7]                               ex7_load_addr;
   wire                                     ex7_load_v;
   wire [0:7]                               ex7_reload_addr;
   wire                                     ex7_reload_v;
   wire                                     ex7_mcrfs;
   wire                                     ex7_mcrfs_din;
   wire                                     ex7_ram_done;
   wire [3:13]                              ex7_ram_expo;
   wire [0:52]                              ex7_ram_frac;
   wire                                     ex7_ram_sign;
   wire                                     ex7_record;
   wire                                     ex7_record_din;
   wire                                     ex7_record_v;
   wire                                     ex7_ucode_preissue;
   wire                                     ex7_ucode_preissue_din;

   wire                                     ex8_b_den_flush;
   wire                                     ex8_b_den_flush_din;
   wire [0:3]                               ex8_cr;
   wire [0:4]                               ex8_cr_bf;
   wire                                     ex8_cr_val;
   wire [0:31]                              ex8_ctl_si;
   wire [0:31]                              ex8_ctl_so;
   wire [0:1]                               ex8_fdivsqrt_start;
   wire [0:1]                               ex8_fdivsqrt_start_din;
   wire [0:1]                               ex9_fdivsqrt_start;
   wire [0:1]                               ex8_fp_enabled;
   wire                                     ex8_fpr_wr_dis;
   wire                                     ex8_fpr_wr_dis_din;
   wire                                     ex8_fpscr_move;
   wire                                     ex8_fpscr_move_din;
   wire [0:1]                               ex8_fu_unavail;
   wire [0:5]                               ex8_instr_frt;
   wire [0:1]                               ex8_instr_tid;
   wire                                     ex8_instr_v;
   wire [0:1]                               ex8_instr_valid;

   wire [0:6]                               ex8_itag;
   wire [0:7]                               ex8_itag_si;
   wire [0:7]                               ex8_itag_so;
   wire                                     ex8_kill_wen;
   wire [0:17]                              ex8_laddr_si;
   wire [0:17]                              ex8_laddr_so;
   wire [0:8]                               ex9_laddr_si;
   wire [0:8]                               ex9_laddr_so;
   wire [0:7]                               ex8_load_addr;
   wire [0:7]                               ex9_load_addr;
   wire                                     ex9_load_v;
   wire                                     ex8_load_v;
   wire [0:7]                               ex8_reload_addr;
   wire                                     ex8_reload_v;
   wire [0:63]                              ex8_ram_data;
   wire                                     ex8_ram_done;
   wire [3:13]                              ex8_ram_expo;
   wire [0:52]                              ex8_ram_frac;
   wire                                     ex8_ram_sign;
   wire                                     ex8_record_v;
   wire                                     ex8_ucode_preissue;
   wire                                     ex8_ucode_preissue_din;

   wire [0:13]                              ex9_ctl_si;
   wire [0:13]                              ex9_ctl_so;
   wire [0:5]                               ex9_instr_frt;
   wire [0:1]                               ex9_instr_tid;
   wire                                     ex9_instr_v;
   wire [0:1]                               ex9_instr_valid;
   wire                                     ex9_kill_wen;

   wire                                     force_t;
   wire [0:1]                               fp_async_fex_d;
   wire [0:1]                               fp_async_fex_q;
   wire [0:1]                               fp_except_en_d;
   wire [0:1]                               fp_except_en_q;
   wire [0:1]                               fp_except_fex;
   wire [0:1]                               fp_except_fex_async;
   wire [0:1]                               fp_except_fx;

   wire                                     int_word_ldst;
   wire                                     sign_ext_ldst;

   wire [0:1]                               msr_fe0;
   wire [0:1]                               msr_fe1;
   wire [0:1]                               msr_fp;
   wire [0:1]                               fu_msr_fe0;
   wire [0:1]                               fu_msr_fe1;
   wire [0:1]                               fu_msr_fp;

   wire                                     msr_fp_act;
   wire [0:1]                               msr_gs_q;
   wire [0:1]                               msr_pr_q;
   wire [0:1]                               msr_gs_d;
   wire [0:1]                               msr_pr_d;


   wire [0:5]                               pri_ex1;
   wire [0:64]                              ram_data_si;
   wire [0:64]                              ram_data_so;
   wire [0:34]                              perf_data_si;
   wire [0:34]                              perf_data_so;
   wire [0:7]                               event_bus_out_si;
   wire [0:7]                               event_bus_out_so;
   wire [0:0]                               ram_datav_si;
   wire [0:0]                               ram_datav_so;

   wire [0:5]                               rf0_instr_fra;
   wire [0:5]                               rf0_instr_frb;
   wire [0:5]                               rf0_instr_frc;
   wire [0:5]                               rf0_instr_frs;
   wire                                     rf0_instr_match;
   wire [0:3]                               rf0_instr_tid_1hot;
   wire [0:3]                               rf1_instr_iss;
   wire [0:3]                               ex1_instr_iss;
   wire [0:3]                               ex2_instr_iss;

   wire [0:3]                               rf0_instr_valid;

   wire [0:31] 				    dbg_group3_lat_si;
   wire [0:31] 				    dbg_group3_lat_so;

   wire [0:1]                               rf0_tid;
   wire                                     ex0_fdiv;
   wire                                     ex0_fdivs;
   wire                                     ex0_fsqrt;
   wire                                     ex0_fsqrts;
   wire [20:31]                             sec_ex1;
   wire                                     sg_0;
   wire                                     single_precision_ldst;
   wire [0:9]                               slowspr_in_addr;
   wire [64-(2**REGMODE):63]                slowspr_in_data;
   wire                                     slowspr_in_done;
   wire [0:1]                               slowspr_in_etid;
   wire                                     slowspr_in_rw;
   wire                                     slowspr_in_val;
   wire [0:9]                               slowspr_out_addr;
   wire [64-(2**REGMODE):63]                slowspr_out_data;
   wire                                     slowspr_out_done;
   wire [0:1]                               slowspr_out_etid;
   wire                                     slowspr_out_rw;
   wire                                     slowspr_out_val;
   wire                                     slowspr_val_in_int;
   wire [64-(2**REGMODE):63]                slowspr_data_in_int;

   (* analysis_not_referenced="TRUE" *) // unused
   wire [0:47]                              spare_unused;
   wire [0:14]                              spr_ctl_si;
   wire [0:14]                              spr_ctl_so;
   wire [64-(2**REGMODE):63]                spr_data_si;
   wire [64-(2**REGMODE):63]                spr_data_so;
   wire                                     st_ex1;
   wire [0:3]                               event_en_d;
   wire [0:3]                               event_en_q;
   wire [0:2] 				    event_count_mode_q;

   wire [0:14]				    unit_bus_in_t0;
   wire [0:14]				    unit_bus_in_t1;
   wire [0:3] 				    event_bus_out_t0;
   wire [0:3] 				    event_bus_out_t1;


   wire [0:14]                              t0_events;
   wire [0:14]                              t1_events;

   wire                                     instr_trace_mode_q;
   wire [0:1] 				    instr_trace_tid_q;

   wire                                     thold_0;
   wire                                     thold_0_b;
   wire                                     tihi;
   wire                                     tiup;
   wire                                     tilo;
   wire                                     tidn;
   wire [0:31]                              trace_data_in;
   wire [0:31]                              trace_data_out;
   wire [0:11]                              trg_group0;
   wire [0:11]                              trg_group1;
   wire [0:11]                              trg_group2;
   wire [0:11]                              trg_group3;
   wire [0:63]                              divsqrt_debug;
   wire [0:3]                               xu_ex0_flush;
   wire [0:3]                               xu_ex1_flush;
   wire [0:3]                               xu_ex2_flush;
   wire [0:3]                               xu_ex3_flush;
   wire [0:3]                               xu_ex4_flush;
   wire [0:3]                               xu_ex5_flush;
   wire [0:3]                               xu_ex6_flush;
   wire [0:3]                               xu_ex7_flush;
   wire [0:3]                               xu_ex8_flush;
   wire [0:3]                               xu_ex9_flush;
   wire [0:3]                               xu_rf0_flush;
   wire                                     ex6_divsqrt_v;
   wire                                     ex6_divsqrt_v_suppress;
   wire                                     ex5_divsqrt_v;
   wire                                     ex5_any_cr_v;

   wire                                     func_slp_sl_thold_0;
   wire                                     func_slp_sl_force;
   wire                                     func_slp_sl_thold_0_b;
   wire                                     cfg_slat_d2clk;
   wire [0:`NCLK_WIDTH-1]                   cfg_slat_lclk;

   assign tilo = 1'b0;
   assign tihi = 1'b1;
   assign tidn = 1'b0;
   assign tiup = 1'b1;


   assign rf0_act_b = ~(|(rv_axu0_vld));

   // cp flush
   assign cp_flush_int[0] = cp_flush[0];

   generate
      if (THREADS == 1)
      begin : dcd_flush_thr1_1
         assign  cp_flush_int[1] = tilo;
      end
   endgenerate
   generate
      if (THREADS == 2)
      begin : dcd_flush_thr2_1
         assign  cp_flush_int[1] = cp_flush[1];
      end
   endgenerate

   // Latches

   tri_rlmlatch_p #(.INIT(0) ) cp_flush_reg0(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr[9]),
      .d_mode(tiup),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(cp_flush_reg0_si),
      .scout(cp_flush_reg0_so),
      //-------------------------------------------
      .din(cp_flush_int[0]),
      //-------------------------------------------
      .dout(cp_flush_q[0])
   );
   //-------------------------------------------

   // Latches

   tri_rlmlatch_p #(.INIT(0) ) cp_flush_reg1(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr[9]),
      .d_mode(tiup),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(cp_flush_reg1_si),
      .scout(cp_flush_reg1_so),
      //-------------------------------------------
      .din(cp_flush_int[1]),
      //-------------------------------------------
      .dout(cp_flush_q[1])
   );
   //-------------------------------------------

   generate
      if (THREADS == 1)
      begin : dcd_flush_thr1_2
         assign  xu_rf0_flush[0] = cp_flush_q[0];
         assign  xu_ex0_flush[0] = cp_flush_q[0];
         assign  xu_ex1_flush[0] = cp_flush_q[0];
         assign  xu_ex2_flush[0] = cp_flush_q[0];
         assign  xu_ex3_flush[0] = cp_flush_q[0];
         assign  xu_ex4_flush[0] = cp_flush_q[0];
         assign  xu_ex5_flush[0] = cp_flush_q[0];
         assign  xu_ex6_flush[0] = cp_flush_q[0];
         assign  xu_ex7_flush[0] = cp_flush_q[0];
         assign  xu_ex8_flush[0] = cp_flush_q[0];
         assign  xu_ex9_flush[0] = cp_flush_q[0];
         assign  xu_rf0_flush[1:3] = {3{tilo}};
         assign  xu_ex0_flush[1:3] = {3{tilo}};
         assign  xu_ex1_flush[1:3] = {3{tilo}};
         assign  xu_ex2_flush[1:3] = {3{tilo}};
         assign  xu_ex3_flush[1:3] = {3{tilo}};
         assign  xu_ex4_flush[1:3] = {3{tilo}};
         assign  xu_ex5_flush[1:3] = {3{tilo}};
         assign  xu_ex6_flush[1:3] = {3{tilo}};
         assign  xu_ex7_flush[1:3] = {3{tilo}};
         assign  xu_ex8_flush[1:3] = {3{tilo}};
         assign  xu_ex9_flush[1:3] = {3{tilo}};
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_flush_thr2_2
         assign  xu_rf0_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex0_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex1_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex2_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex3_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex4_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex5_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex6_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex7_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex8_flush[0:1] = cp_flush_q[0:1];
         assign  xu_ex9_flush[0:1] = cp_flush_q[0:1];
         assign  xu_rf0_flush[2:3] = {2{tilo}};
         assign  xu_ex0_flush[2:3] = {2{tilo}};
         assign  xu_ex1_flush[2:3] = {2{tilo}};
         assign  xu_ex2_flush[2:3] = {2{tilo}};
         assign  xu_ex3_flush[2:3] = {2{tilo}};
         assign  xu_ex4_flush[2:3] = {2{tilo}};
         assign  xu_ex5_flush[2:3] = {2{tilo}};
         assign  xu_ex6_flush[2:3] = {2{tilo}};
         assign  xu_ex7_flush[2:3] = {2{tilo}};
         assign  xu_ex8_flush[2:3] = {2{tilo}};
         assign  xu_ex9_flush[2:3] = {2{tilo}};
      end
   endgenerate

   //----------------------------------------------------------------------
   // Pervasive


   tri_plat #( .WIDTH(3)) thold_reg_0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(flush),
      .din({thold_1,
            cfg_sl_thold_1,
            func_slp_sl_thold_1}),
      .q({thold_0,
          cfg_sl_thold_0,
          func_slp_sl_thold_0})
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


   tri_lcbor  cfg_sl_lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(cfg_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(cfg_sl_force),
      .thold_b(cfg_sl_thold_0_b)
   );

   tri_lcbor  func_slp_sl_lcbor_0(
      .clkoff_b(clkoff_b),
      .thold(func_slp_sl_thold_0),
      .sg(sg_0),
      .act_dis(act_dis),
      .force_t(func_slp_sl_force),
      .thold_b(func_slp_sl_thold_0_b)
   );

   tri_lcbs  lcbs_cfg(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr[9]),
      .nclk(nclk),
      .force_t(cfg_sl_force),
      .thold_b(cfg_sl_thold_0_b),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk)
   );

   tri_slat_scan #(.WIDTH(2), .INIT(0), .RESET_INVERTS_SCAN(1'b1)) cfg_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk),
      .scan_in({ccfg_scan_in, bcfg_scan_in}),
      .scan_out({ccfg_scan_out,bcfg_scan_out})
   );


   //----------------------------------------------------------------------
   // Act Latches

   generate
      if (THREADS == 1)
      begin : dcd_msr_bits_thr1_2
         assign  fu_msr_fp[0] = xu_fu_msr_fp[0];
         assign  fu_msr_fp[1] = tidn;
         assign  fu_msr_fe0[0] = xu_fu_msr_fe0[0];
         assign  fu_msr_fe0[1] = tidn;
         assign  fu_msr_fe1[0] = xu_fu_msr_fe1[0];
         assign  fu_msr_fe1[1] = tidn;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_msr_bits_thr2_2
         assign  fu_msr_fp = xu_fu_msr_fp;
         assign  fu_msr_fe0 = xu_fu_msr_fe0;
         assign  fu_msr_fe1 = xu_fu_msr_fe1;
      end
   endgenerate

   tri_rlmreg_p #(.INIT(0),  .WIDTH(8)) act_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(act_lat_si[0:7]),
      .scout(act_lat_so[0:7]),
      .din({ pc_fu_trace_bus_enable,
             pc_fu_event_bus_enable,
	     fu_msr_fp,
	     fu_msr_fe0,
             fu_msr_fe1
             }),
      .dout({dbg0_act,
             event_act,
	     msr_fp,
	     msr_fe0,
             msr_fe1})
   );

   assign msr_fp_act = |(msr_fp) | axucr0_q[60]; // note this was defaulted the other way in A2i
   assign f_dcd_msr_fp_act =  msr_fp_act;

   //----------------------------------------------------------------------
   // RF0



   assign rf0_instr_match = iu_fu_rf0_instr_match;

   generate
      if (THREADS == 1)
      begin : dcd_tid_thr1_1
         assign  rf0_tid[0] = iu_fu_rf0_tid[0];
         assign  rf0_tid[1] = tidn;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_tid_thr2_1
         assign  rf0_tid[0:1] = iu_fu_rf0_tid[0:1];
      end
   endgenerate

   generate
      if (THREADS == 1)
      begin : dcd_axu0_vld_thr1_1
         assign  rf0_instr_tid_1hot[0] = rv_axu0_vld[0];
         assign  rf0_instr_tid_1hot[1] = 1'b0;		//rv_axu0_v(1);
         assign  rf0_instr_tid_1hot[2] = 1'b0;
         assign  rf0_instr_tid_1hot[3] = 1'b0;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_axu0_vld_thr2_1
         assign  rf0_instr_tid_1hot[0] = rv_axu0_vld[0];
         assign  rf0_instr_tid_1hot[1] = rv_axu0_vld[1];		//rv_axu0_v(1);
         assign  rf0_instr_tid_1hot[2] = 1'b0;
         assign  rf0_instr_tid_1hot[3] = 1'b0;
      end
   endgenerate

   assign rf0_instr_valid[0:3] = rf0_instr_tid_1hot[0:3] & (~xu_rf0_flush[0:3]);


   assign rf0_instr_fra[0:5] = iu_fu_rf0_fra[0:5];
   assign rf0_instr_frb[0:5] = iu_fu_rf0_frb[0:5];
   assign rf0_instr_frc[0:5] = iu_fu_rf0_frc[0:5];
   assign rf0_instr_frs[0:5] = iu_fu_rf0_frc[0:5];		// Store rides on s3!! (frc)

   //----------------------------------------------------------------------
   // EX0
   assign ex0_is_ucode = (rv_axu0_ex0_ucode[0] | rv_axu0_ex0_ucode[1]) & (~rv_axu0_ex0_ucode[2]);
   assign ex0_ucode_preissue = rv_axu0_ex0_ucode[1] & ex0_instr_vld;

   // Flush Due to Speculative Loadhit

   // Latches


   tri_rlmreg_p #(.INIT(0),  .WIDTH(8), .NEEDS_SRESET(1)) ex0_iu(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr[0]),
      .d_mode(tiup),
      .mpw1_b(mpw1_b[0]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex0_iu_si[0:7]),
      .scout(ex0_iu_so[0:7]),
      //-------------------------------------------
      .din({iu_fu_rf0_fra_v,
            iu_fu_rf0_frb_v,
            iu_fu_rf0_frc_v,
	    rf0_instr_valid[0:3],
            rf0_instr_match
            }),
      //-------------------------------------------
      .dout({ex0_instr_fra_v,
             ex0_instr_frb_v,
             ex0_instr_frc_v,
	     ex0_instr_v[0:3],
             ex0_instr_match
            })
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0),  .WIDTH(24)) ex0_frt(
      .nclk(nclk),
      .act(msr_fp_act),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[0]),
      .mpw1_b(mpw1_b[0]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex0_frt_si[0:23]),
      .scout(ex0_frt_so[0:23]),
      .din({rf0_instr_fra[0:5],
            rf0_instr_frb[0:5],
            rf0_instr_frc[0:5],
            rf0_instr_frs[0:5]}),
      //-------------------------------------------
      .dout({ex0_instr_fra[0:5],
             ex0_instr_frb[0:5],
             ex0_instr_frc[0:5],
             ex0_instr_frs[0:5]
             })
   );
   //-------------------------------------------



   assign ex0_itag = rv_axu0_ex0_itag;

   assign ex0_instr_valid[0:3] = ex0_instr_v[0:3] & (~xu_ex0_flush[0:3]);

   assign ex1_fpscr_wen_din = rv_axu0_ex0_t1_v & (~ex0_ucode_preissue);

   //----------------------------------------------------------------------
   // EX1

   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(15), .NEEDS_SRESET(1)) ex1_iu(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_iu_si[0:14]),
      .scout(ex1_iu_so[0:14]),
      //-------------------------------------------
      .din({ex0_instr_fra_v,
            ex0_instr_frb_v,
            ex0_instr_frc_v,
            ex0_instr_valid[0:3],
            ex0_instr_match,
            ex0_is_ucode,
            ex0_ucode_preissue,
            ex0_isRam,
	    ex0_instr_valid[1],
	    ex0_instr_valid[1],
            ex0_instr_valid[1],
	    ex0_instr_valid[1]
             }),
      //-------------------------------------------
      .dout({   ex1_instr_fra_v,
                ex1_instr_frb_v,
                ex1_instr_frc_v,
                ex1_instr_v[0:3],
                ex1_instr_match,
                ex1_is_ucode,
                ex1_ucode_preissue,
                ex1_isRam,
                ex1_instr_v1_bufw,
                ex1_instr_v1_bufx,
                ex1_instr_v1_bufy,
                ex1_instr_v1_bufz
})
   );
   //-------------------------------------------

   assign ex0_isRam = tidn;




   tri_rlmreg_p #(.INIT(0), .WIDTH(30)) ex1_frt(
      .nclk(nclk),
      .act(ex1_instr_act),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_frt_si[0:29]),
      .scout(ex1_frt_so[0:29]),
      .din({    rv_axu0_ex0_t2_p[0:5],
                ex0_instr_fra[0:5],
                ex0_instr_frb[0:5],
                ex0_instr_frc[0:5],
                ex0_instr_frs[0:5]}),
      //-------------------------------------------
      .dout({   ex1_instr_frt[0:5],
                ex1_instr_fra[0:5],
		ex1_instr_frb[0:5],
		ex1_instr_frc[0:5],
                ex1_instr_frs[0:5]})
   );
   //-------------------------------------------

   assign ex1_instr_act = ex0_instr_v[0] | ex0_instr_v[1] | ex1_instr_v[0] | ex1_instr_v[1];


   tri_rlmreg_p #(.INIT(0), .WIDTH(32)) ex1_instl(
      .nclk(nclk),
      .act(ex1_instr_act),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_instl_si[0:31]),
      .scout(ex1_instl_so[0:31]),
      .din(rv_axu0_ex0_instr[0:31]),
      .dout(ex1_instr[0:31])
   );


   tri_rlmreg_p #(.INIT(0), .WIDTH(14)) ex1_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_itag_si),
      .scout(ex1_itag_so),
      //-------------------------------------------
      .din({ex0_itag[0:6],
            rv_axu0_ex0_t1_p[0:5],
            ex1_fpscr_wen_din}),
      //-------------------------------------------
      .dout({ex1_itag[0:6],
             ex1_fpscr_addr[0:5],
             ex1_fpscr_wen})
   );
   //-------------------------------------------

   assign f_dcd_ex1_fpscr_addr = ex1_fpscr_addr;
   assign f_dcd_ex1_instr_frt = ex1_instr_frt;
   assign f_dcd_ex1_instr_tid = ex1_instr_v[0:3] & (~xu_ex1_flush[0:3]);
   assign f_dcd_ex1_divsqrt_cr_bf = ex1_cr_bf;


   tri_rlmreg_p #(.INIT(0), .WIDTH(5)) ex1_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[1]),
      .mpw1_b(mpw1_b[1]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex1_crbf_si[0:4]),
      .scout(ex1_crbf_so[0:4]),
      .din(rv_axu0_ex0_t3_p[1:5]),
      .dout(ex1_cr_bf[0:4])
   );

   // Flushes

   assign ex1_instr_valid[0:3] = ex1_instr_v[0:3] & (~xu_ex1_flush[0:3])  & {4{((~|(ex1_fdivsqrt_start)) | ex1_ucode_preissue)}};

   assign ex1_instr_vld = (ex1_instr_v[0] & (~xu_ex1_flush[0])) | (ex1_instr_v[1] & (~xu_ex1_flush[1])) ;
   assign ex1_str_v = |(ex1_instr_valid[0:3]) & st_ex1;
   assign f_dcd_ex1_sto_v =  ex1_str_v;

// temp: assumes only 2 threads for timing (this is encoded)
   assign ex1_tid[0] = tidn;
   assign ex1_tid[1] = ex1_instr_v[1];

   assign ex1_tid_bufw[0] = tidn;
   assign ex1_tid_bufw[1] = ex1_instr_v1_bufw;

   assign ex1_tid_bufx[0] = tidn;
   assign ex1_tid_bufx[1] = ex1_instr_v1_bufx;

   assign ex1_tid_bufy[0] = tidn;
   assign ex1_tid_bufy[1] = ex1_instr_v1_bufy;

   assign ex1_tid_bufz[0] = tidn;
   assign ex1_tid_bufz[1] = ex1_instr_v1_bufz;

   //----------------------------------------------------------------------
   // Bypass Writethru Detect in EX1

   //   000000  <=  FPR                     lev0
   //   100000  <=  ex7 load bypass into A  lev1
   //   010000  <=  ex7 load bypass into c  lev1
   //   001000  <=  ex7 load bypass into B  lev1
   //   000100  <=  ex7 bypass into A       lev1
   //   000010  <=  ex7 bypass into c       lev1
   //   000001  <=  ex7 bypass into B       lev1

   // Result Bypass, res EX7 and dep in EX1
   assign ex1_bypsel_a_res0 = ({ex7_instr_tid[0:1], ex7_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_fra[0:5]}) & (ex7_instr_valid & (~ex7_kill_wen)) & ex1_instr_fra_v;
   assign ex1_bypsel_c_res0 = ({ex7_instr_tid[0:1], ex7_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frc[0:5]}) & (ex7_instr_valid & (~ex7_kill_wen)) & ex1_instr_frc_v;
   assign ex1_bypsel_b_res0 = ({ex7_instr_tid[0:1], ex7_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frb[0:5]}) & (ex7_instr_valid & (~ex7_kill_wen)) & ex1_instr_frb_v;

   assign ex1_bypsel_s_res0 = ({ex7_instr_tid[0:1], ex7_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frs[0:5]}) & (ex7_instr_valid & (~ex7_kill_wen)) & ex1_str_v;

   // Writethru case, res EX8 dep EX1
   assign ex1_bypsel_a_res1 = ({ex8_instr_tid[0:1], ex8_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_fra[0:5]}) & ex8_instr_v & (~ex8_kill_wen) & ex1_instr_fra_v & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load0);
   assign ex1_bypsel_c_res1 = ({ex8_instr_tid[0:1], ex8_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frc[0:5]}) & ex8_instr_v & (~ex8_kill_wen) & ex1_instr_frc_v & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load0);
   assign ex1_bypsel_b_res1 = ({ex8_instr_tid[0:1], ex8_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frb[0:5]}) & ex8_instr_v & (~ex8_kill_wen) & ex1_instr_frb_v & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load0);

   assign ex1_bypsel_s_res1 = ({ex8_instr_tid[0:1], ex8_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frs[0:5]}) & ex8_instr_v & (~ex8_kill_wen) & ex1_str_v;

   // Writethru case, res EX9 dep EX1
   assign ex1_bypsel_a_res2 = ({ex9_instr_tid[0:1], ex9_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_fra[0:5]}) & ex9_instr_v & (~ex9_kill_wen) & ex1_instr_fra_v & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res1) & (~ex1_bypsel_a_load1);
   assign ex1_bypsel_c_res2 = ({ex9_instr_tid[0:1], ex9_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frc[0:5]}) & ex9_instr_v & (~ex9_kill_wen) & ex1_instr_frc_v & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res1) & (~ex1_bypsel_c_load1);
   assign ex1_bypsel_b_res2 = ({ex9_instr_tid[0:1], ex9_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frb[0:5]}) & ex9_instr_v & (~ex9_kill_wen) & ex1_instr_frb_v & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res1) & (~ex1_bypsel_b_load1);

   assign ex1_bypsel_s_res2 = ({ex9_instr_tid[0:1], ex9_instr_frt[0:5]}) == ({ex1_tid_bufw[0:1], ex1_instr_frs[0:5]}) & ex9_instr_v & (~ex9_kill_wen) & ex1_str_v;

   // LOADS

   generate
      if (THREADS == 1)
      begin : dcd_loadaddr_thr_1
         assign  ex6_load_addr[0:7] = f_fpr_ex6_load_addr[0:7];		// no tid bit
         assign  ex6_reload_addr[0:7] = f_fpr_ex6_reload_addr[0:7];		// no tid bit
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_loadaddr_thr_2
         assign  ex6_load_addr[0:7] = {f_fpr_ex6_load_addr[0], f_fpr_ex6_load_addr[7], f_fpr_ex6_load_addr[1:6]};		// bit 7 is the tid but only in the 2 thread model
         assign  ex6_reload_addr[0:7] = {f_fpr_ex6_reload_addr[0], f_fpr_ex6_reload_addr[7], f_fpr_ex6_reload_addr[1:6]};		// bit 7 is the tid but only in the 2 thread model

      end
   endgenerate

   assign ex6_load_v = f_fpr_ex6_load_v;

   assign ex6_reload_v = f_fpr_ex6_reload_v;

   // Load Bypass, Load in EX6, dep EX1  ==> Load Use = 5 cycles, 4 bubbles
   assign ex1_bypsel_a_load0 = (ex6_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_fra[0:5]}) & ex6_load_v & ex1_instr_fra_v;
   assign ex1_bypsel_c_load0 = (ex6_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frc[0:5]}) & ex6_load_v & ex1_instr_frc_v;
   assign ex1_bypsel_b_load0 = (ex6_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frb[0:5]}) & ex6_load_v & ex1_instr_frb_v;
   assign ex1_bypsel_s_load0 = (ex6_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frs[0:5]}) & ex6_load_v & ex1_str_v;

   // Writethru case, Load EX7 dep EX1
   assign ex1_bypsel_a_load1 = (ex7_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_fra[0:5]}) & ex7_load_v & ex1_instr_fra_v & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res0);
   assign ex1_bypsel_c_load1 = (ex7_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frc[0:5]}) & ex7_load_v & ex1_instr_frc_v & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res0);
   assign ex1_bypsel_b_load1 = (ex7_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frb[0:5]}) & ex7_load_v & ex1_instr_frb_v & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res0);
   assign ex1_bypsel_s_load1 = (ex7_load_addr[0:7]) == ({ex1_tid_bufx[0:1], ex1_instr_frs[0:5]}) & ex7_load_v & ex1_str_v;

   // Writethru case, Load EX8 dep EX1
   assign ex1_bypsel_a_load2 = (ex8_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_fra[0:5]}) & ex8_load_v & ex1_instr_fra_v & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load1) & (~ex1_bypsel_a_res1);
   assign ex1_bypsel_c_load2 = (ex8_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frc[0:5]}) & ex8_load_v & ex1_instr_frc_v & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load1) & (~ex1_bypsel_c_res1);
   assign ex1_bypsel_b_load2 = (ex8_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frb[0:5]}) & ex8_load_v & ex1_instr_frb_v & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load1) & (~ex1_bypsel_b_res1);
   assign ex1_bypsel_s_load2 = (ex8_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frs[0:5]}) & ex8_load_v & ex1_str_v;

   // Writethru case, just for abort, Load EX9 dep EX1
   assign ex1_bypsel_a_load3 = (ex9_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_fra[0:5]}) & ex9_load_v & ex1_instr_fra_v ;
   assign ex1_bypsel_c_load3 = (ex9_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frc[0:5]}) & ex9_load_v & ex1_instr_frc_v ;
   assign ex1_bypsel_b_load3 = (ex9_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frb[0:5]}) & ex9_load_v & ex1_instr_frb_v ;
   assign ex1_bypsel_s_load3 = (ex9_load_addr[0:7]) == ({ex1_tid_bufy[0:1], ex1_instr_frs[0:5]}) & ex9_load_v & ex1_str_v;



   // reLoad Bypass, Load in EX6, dep EX1  ==> Load Use = 5 cycles, 4 bubbles
   assign ex1_bypsel_a_reload0 = (ex6_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_fra[0:5]}) & ex6_reload_v & ex1_instr_fra_v & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load1) & (~ex1_bypsel_a_res1);
   assign ex1_bypsel_c_reload0 = (ex6_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frc[0:5]}) & ex6_reload_v & ex1_instr_frc_v & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load1) & (~ex1_bypsel_c_res1);
   assign ex1_bypsel_b_reload0 = (ex6_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frb[0:5]}) & ex6_reload_v & ex1_instr_frb_v & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load1) & (~ex1_bypsel_b_res1);
   assign ex1_bypsel_s_reload0 = (ex6_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frs[0:5]}) & ex6_reload_v & ex1_str_v;

   // reLoad Writethru case, Load EX7 dep EX1
   assign ex1_bypsel_a_reload1 = (ex7_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_fra[0:5]}) & ex7_reload_v & ex1_instr_fra_v & (~ex1_bypsel_a_reload0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load1) & (~ex1_bypsel_a_res1);
   assign ex1_bypsel_c_reload1 = (ex7_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frc[0:5]}) & ex7_reload_v & ex1_instr_frc_v & (~ex1_bypsel_c_reload0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load1) & (~ex1_bypsel_c_res1);
   assign ex1_bypsel_b_reload1 = (ex7_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frb[0:5]}) & ex7_reload_v & ex1_instr_frb_v & (~ex1_bypsel_b_reload0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load1) & (~ex1_bypsel_b_res1);
   assign ex1_bypsel_s_reload1 = (ex7_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frs[0:5]}) & ex7_reload_v & ex1_str_v;

   // reLoad Writethru case, Load EX8 dep EX1
   assign ex1_bypsel_a_reload2 = (ex8_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_fra[0:5]}) & ex8_reload_v & ex1_instr_fra_v & (~ex1_bypsel_a_reload0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_reload1) & (~ex1_bypsel_a_res1) & (~ex1_bypsel_a_load0) & (~ex1_bypsel_a_res0) & (~ex1_bypsel_a_load1) & (~ex1_bypsel_a_res1);
   assign ex1_bypsel_c_reload2 = (ex8_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frc[0:5]}) & ex8_reload_v & ex1_instr_frc_v & (~ex1_bypsel_c_reload0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_reload1) & (~ex1_bypsel_c_res1) & (~ex1_bypsel_c_load0) & (~ex1_bypsel_c_res0) & (~ex1_bypsel_c_load1) & (~ex1_bypsel_c_res1);
   assign ex1_bypsel_b_reload2 = (ex8_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frb[0:5]}) & ex8_reload_v & ex1_instr_frb_v & (~ex1_bypsel_b_reload0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_reload1) & (~ex1_bypsel_b_res1) & (~ex1_bypsel_b_load0) & (~ex1_bypsel_b_res0) & (~ex1_bypsel_b_load1) & (~ex1_bypsel_b_res1);
   assign ex1_bypsel_s_reload2 = (ex8_reload_addr[0:7]) == ({ex1_tid_bufz[0:1], ex1_instr_frs[0:5]}) & ex8_reload_v & ex1_str_v;




   assign f_dcd_ex1_bypsel_a_res1 = ex1_bypsel_a_res1;
   assign f_dcd_ex1_bypsel_b_res1 = ex1_bypsel_b_res1;
   assign f_dcd_ex1_bypsel_c_res1 = ex1_bypsel_c_res1;
   assign f_dcd_ex1_bypsel_a_load1 = ex1_bypsel_a_load1;
   assign f_dcd_ex1_bypsel_b_load1 = ex1_bypsel_b_load1;
   assign f_dcd_ex1_bypsel_c_load1 = ex1_bypsel_c_load1;
   assign f_dcd_ex1_bypsel_a_reload1 = ex1_bypsel_a_reload1;
   assign f_dcd_ex1_bypsel_b_reload1 = ex1_bypsel_b_reload1;
   assign f_dcd_ex1_bypsel_c_reload1 = ex1_bypsel_c_reload1;

   assign f_dcd_ex1_bypsel_s_res1 = ex1_bypsel_s_res1;
   assign f_dcd_ex1_bypsel_s_load1 = ex1_bypsel_s_load1;
   assign f_dcd_ex1_bypsel_s_reload1 = ex1_bypsel_s_reload1;

   assign f_dcd_ex1_bypsel_a_res2 = ex1_bypsel_a_res2;
   assign f_dcd_ex1_bypsel_b_res2 = ex1_bypsel_b_res2;
   assign f_dcd_ex1_bypsel_c_res2 = ex1_bypsel_c_res2;
   assign f_dcd_ex1_bypsel_a_load2 = ex1_bypsel_a_load2;
   assign f_dcd_ex1_bypsel_b_load2 = ex1_bypsel_b_load2;
   assign f_dcd_ex1_bypsel_c_load2 = ex1_bypsel_c_load2;
   assign f_dcd_ex1_bypsel_a_reload2 = ex1_bypsel_a_reload2;
   assign f_dcd_ex1_bypsel_b_reload2 = ex1_bypsel_b_reload2;
   assign f_dcd_ex1_bypsel_c_reload2 = ex1_bypsel_c_reload2;

   assign f_dcd_ex1_bypsel_s_res2 = ex1_bypsel_s_res2;
   assign f_dcd_ex1_bypsel_s_load2 = ex1_bypsel_s_load2;
   assign f_dcd_ex1_bypsel_s_reload2 = ex1_bypsel_s_reload2;


   assign f_dcd_ex1_bypsel_a_res0 = ex1_bypsel_a_res0;
   assign f_dcd_ex1_bypsel_a_load0 = ex1_bypsel_a_load0;
   assign f_dcd_ex1_bypsel_a_reload0 = ex1_bypsel_a_reload0;

   assign f_dcd_ex1_bypsel_b_res0 = ex1_bypsel_b_res0;
   assign f_dcd_ex1_bypsel_b_load0 = ex1_bypsel_b_load0;
   assign f_dcd_ex1_bypsel_b_reload0 = ex1_bypsel_b_reload0;

   assign f_dcd_ex1_bypsel_c_res0 = ex1_bypsel_c_res0;
   assign f_dcd_ex1_bypsel_c_load0 = ex1_bypsel_c_load0;
   assign f_dcd_ex1_bypsel_c_reload0 = ex1_bypsel_c_reload0;

   assign f_dcd_ex1_bypsel_s_res0 = ex1_bypsel_s_res0;
   assign f_dcd_ex1_bypsel_s_load0 = ex1_bypsel_s_load0;
   assign f_dcd_ex1_bypsel_s_reload0 = ex1_bypsel_s_reload0;

   // operand valids for parity checking
   assign ex1_byp_a = ex1_bypsel_a_res0 | ex1_bypsel_a_res1 | ex1_bypsel_a_res2 | ex1_bypsel_a_load0 | ex1_bypsel_a_load1 | ex1_bypsel_a_load2 | ex1_bypsel_a_reload0 | ex1_bypsel_a_reload1 | ex1_bypsel_a_reload2;
   assign ex1_byp_b = ex1_bypsel_b_res0 | ex1_bypsel_b_res1 | ex1_bypsel_b_res2 | ex1_bypsel_b_load0 | ex1_bypsel_b_load1 | ex1_bypsel_b_load2 | ex1_bypsel_b_reload0 | ex1_bypsel_b_reload1 | ex1_bypsel_b_reload2;
   assign ex1_byp_c = ex1_bypsel_c_res0 | ex1_bypsel_c_res1 | ex1_bypsel_c_res2 | ex1_bypsel_c_load0 | ex1_bypsel_c_load1 | ex1_bypsel_c_load2 | ex1_bypsel_c_reload0 | ex1_bypsel_c_reload1 | ex1_bypsel_c_reload2;
   assign ex1_fra_v = ex1_instr_fra_v & (~ex1_byp_a);
   assign ex1_frb_v = ex1_instr_frb_v & (~ex1_byp_b);
   assign ex1_frc_v = ex1_instr_frc_v & (~ex1_byp_c);
   assign ex1_frs_byp = ex1_bypsel_s_res0 | ex1_bypsel_s_res1 | ex1_bypsel_s_res2 |
                        ex1_bypsel_s_load0 | ex1_bypsel_s_load1 | ex1_bypsel_s_load2 |
                        ex1_bypsel_s_reload0 | ex1_bypsel_s_reload1 | ex1_bypsel_s_reload2;

   assign ex2_frs_byp_din = ex1_frs_byp & ex1_str_v;

   // grandchild stuff
   assign ex1_abort_a_din = ((ex1_bypsel_a_load0 & ex6_abort_lq) | (ex1_bypsel_a_load1 & ex7_abort_lq) | (ex1_bypsel_a_load2 & ex8_abort_lq) | (ex1_bypsel_a_load3 & ex9_abort_lq) |
                             (ex1_bypsel_a_res0 & ex7_abort)     | (ex1_bypsel_a_res1 & ex8_abort)     | (ex1_bypsel_a_res2 & ex9_abort)) & ex1_instr_vld   ;

   assign ex1_abort_b_din = ((ex1_bypsel_b_load0 & ex6_abort_lq) | (ex1_bypsel_b_load1 & ex7_abort_lq) | (ex1_bypsel_b_load2 & ex8_abort_lq) | (ex1_bypsel_b_load3 & ex9_abort_lq) |
                             (ex1_bypsel_b_res0 & ex7_abort)     | (ex1_bypsel_b_res1 & ex8_abort)     | (ex1_bypsel_b_res2 & ex9_abort)) & ex1_instr_vld    ;

   assign ex1_abort_c_din = ((ex1_bypsel_c_load0 & ex6_abort_lq) | (ex1_bypsel_c_load1 & ex7_abort_lq) | (ex1_bypsel_c_load2 & ex8_abort_lq) | (ex1_bypsel_c_load3 & ex9_abort_lq) |
                             (ex1_bypsel_c_res0 & ex7_abort)     | (ex1_bypsel_c_res1 & ex8_abort)     | (ex1_bypsel_c_res2 & ex9_abort)) & ex1_instr_vld    ;

   assign ex1_abort_s_din = ((ex1_bypsel_s_load0 & ex6_abort_lq) | (ex1_bypsel_s_load1 & ex7_abort_lq) | (ex1_bypsel_s_load2 & ex8_abort_lq) | (ex1_bypsel_s_load3 & ex9_abort_lq) |
                             (ex1_bypsel_s_res0 & ex7_abort)     | (ex1_bypsel_s_res1 & ex8_abort)     | (ex1_bypsel_s_res2 & ex9_abort)) & ex1_instr_vld    ;




   //-------------------------------------------------------------------
   // Decode IOP

   assign ex1_primary[0:5] = ex1_instr[0:5];
   assign ex1_sec_xform[0:9] = ex1_instr[21:30];
   assign ex1_sec_aform[0:4] = ex1_instr[26:30];
   assign ex1_v = ex1_instr_v[0] | ex1_instr_v[1];
   assign ex1_axu_v = ex1_v |  ex1_perr_sm_instr_v;
   assign ex1_dp = (ex1_primary[0:5] == 6'b111111) & ex1_v & (~ex1_perr_sm_instr_v);
   assign ex1_sp = (ex1_primary[0:5] == 6'b111011) & ex1_v & (~ex1_perr_sm_instr_v);
   assign ex1_dporsp = ex1_dp | ex1_sp;

   assign ex1_fabs = ex1_dp & (ex1_sec_xform[0:9] == 10'b0100001000);
   assign ex1_fadd = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b10101);
   assign ex1_fcfid = ex1_dp & (ex1_sec_xform[0:9] == 10'b1101001110);
   assign ex1_fcfidu = ex1_dp & (ex1_sec_xform[0:9] == 10'b1111001110);
   assign ex1_fcfids = ex1_sp & (ex1_sec_xform[0:9] == 10'b1101001110);
   assign ex1_fcfidus = ex1_sp & (ex1_sec_xform[0:9] == 10'b1111001110);
   assign ex1_fcfiwu = ex1_dp & (ex1_sec_xform[0:9] == 10'b0011001110);
   assign ex1_fcfiwus = ex1_sp & (ex1_sec_xform[0:9] == 10'b0011001110);
   assign ex1_fcmpo = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000100000);
   assign ex1_fcmpu = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000000000);
   assign ex1_fcpsgn = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000001000);
   assign ex1_fctid = ex1_dp & (ex1_sec_xform[0:9] == 10'b1100101110);
   assign ex1_fctidu = ex1_dp & (ex1_sec_xform[0:9] == 10'b1110101110);
   assign ex1_fctidz = ex1_dp & (ex1_sec_xform[0:9] == 10'b1100101111);
   assign ex1_fctiduz = ex1_dp & (ex1_sec_xform[0:9] == 10'b1110101111);
   assign ex1_fctiw = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000001110);
   assign ex1_fctiwu = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010001110);
   assign ex1_fctiwz = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000001111);
   assign ex1_fctiwuz = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010001111);
   assign ex1_fdiv = ex1_dp & (ex1_sec_aform[0:4] == 5'b10010);
   assign ex1_fdivs = ex1_sp & (ex1_sec_aform[0:4] == 5'b10010);
   assign ex0_fdiv = (rv_axu0_ex0_instr[0:5] == 6'b111111) & (rv_axu0_ex0_instr[26:30] == 5'b10010);
   assign ex0_fdivs = (rv_axu0_ex0_instr[0:5] == 6'b111011) & (rv_axu0_ex0_instr[26:30] == 5'b10010);

   assign ex1_fmadd = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11101);
   assign ex1_fmr = ex1_dp & (ex1_sec_xform[0:9] == 10'b0001001000);
   assign ex1_fmsub = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11100);
   assign ex1_fmul = ex1_dporsp & ((ex1_sec_aform[0:4] == 5'b11001) | (ex1_sec_aform[0:4] == 5'b10001));		//This is for the last divide op
   assign ex1_fnabs = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010001000);
   assign ex1_fneg = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000101000);
   assign ex1_fnmadd = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11111);
   assign ex1_fnmsub = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11110);
   assign ex1_fres = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11000);
   assign ex1_frim = ex1_dp & (ex1_sec_xform[0:9] == 10'b0111101000);
   assign ex1_frin = ex1_dp & (ex1_sec_xform[0:9] == 10'b0110001000);
   assign ex1_frip = ex1_dp & (ex1_sec_xform[0:9] == 10'b0111001000);
   assign ex1_friz = ex1_dp & (ex1_sec_xform[0:9] == 10'b0110101000);
   assign ex1_frsp = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000001100);
   assign ex1_frsqrte = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b11010);
   assign ex1_fsel = (ex1_dp & (ex1_sec_aform[0:4] == 5'b10111)) | (~perr_sm_l2[0]);  // perr_insert

   assign ex1_fsqrt = ex1_dp & (ex1_sec_aform[0:4] == 5'b10110);
   assign ex1_fsqrts = ex1_sp & (ex1_sec_aform[0:4] == 5'b10110);
   assign ex0_fsqrt = (rv_axu0_ex0_instr[0:5] == 6'b111111) & (rv_axu0_ex0_instr[26:30] == 5'b10110);
   assign ex0_fsqrts = (rv_axu0_ex0_instr[0:5] == 6'b111011) & (rv_axu0_ex0_instr[26:30] == 5'b10110);

   assign ex1_fsub = ex1_dporsp & (ex1_sec_aform[0:4] == 5'b10100);
   assign ex1_mcrfs = ex1_dp & (ex1_sec_xform[0:9] == 10'b0001000000);
   assign ex1_mffs = ex1_dp & (ex1_sec_xform[0:9] == 10'b1001000111);
   assign ex1_mtfsb0 = ex1_dp & (ex1_sec_xform[0:9] == 10'b0001000110);
   assign ex1_mtfsb1 = ex1_dp & (ex1_sec_xform[0:9] == 10'b0000100110);
   assign ex1_mtfsf = ex1_dp & (ex1_sec_xform[0:9] == 10'b1011000111);
   assign ex1_mtfsfi = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010000110);
   assign ex1_loge = ex1_dporsp & (ex1_sec_xform[0:9] == 10'b0011100101);
   assign ex1_expte = ex1_dporsp & (ex1_sec_xform[0:9] == 10'b0011000101);
   assign ex1_prenorm = ex1_dporsp & (ex1_sec_xform[5:9] == 5'b10000);

   assign ex1_ftdiv = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010000000);
   assign ex1_ftsqrt = ex1_dp & (ex1_sec_xform[0:9] == 10'b0010100000);

   assign ex1_cr_val = ex1_fcmpu | ex1_fcmpo;
   assign ex1_record = (ex1_dporsp & ex1_instr[31]) & (~ex1_cr_val) & (~ex1_mcrfs) & (~ex1_ftdiv) & (~ex1_ftsqrt);

   assign ex1_moves = ex1_fmr | ex1_fabs | ex1_fnabs | ex1_fneg | ex1_fcpsgn; // | ((~perr_sm_l2[0]));		//perr state machine, don't update the fpscr, only move.

   assign ex1_to_ints = ex1_fctid | ex1_fctidu | ex1_fctidz | ex1_fctiduz | ex1_fctiw | ex1_fctiwu | ex1_fctiwz | ex1_fctiwuz;
   assign ex1_from_ints = ex1_fcfid | ex1_fcfidu | ex1_fcfids | ex1_fcfidus | ex1_fcfiwu | ex1_fcfiwus;
   assign ex1_fpscr_moves = ex1_mtfsb0 | ex1_mtfsb1 | ex1_mtfsf | ex1_mtfsfi | ex1_mcrfs;

   assign ex1_kill_wen = ex1_cr_val | ex1_fpscr_moves | ex1_ftdiv | ex1_ftsqrt | ex1_ucode_preissue;

   assign ex1_fdivsqrt_start[0] = (ex1_fdiv | ex1_fdivs | ex1_fsqrt | ex1_fsqrts) & ex1_instr_v[0] & (~xu_ex1_flush[0]);
   assign ex1_fdivsqrt_start[1] = (ex1_fdiv | ex1_fdivs | ex1_fsqrt | ex1_fsqrts) & ex1_instr_v[1] & (~xu_ex1_flush[1]);

   assign ex1_fdivsqrt_start_din = ex1_fdivsqrt_start & {2{(~ex1_ucode_preissue)}};

   // ex1_instr_imm defs
   assign ex1_mtfsb_bt[0] = (~ex1_instr[9]) & (~ex1_instr[10]);		//00
   assign ex1_mtfsb_bt[1] = (~ex1_instr[9]) & ex1_instr[10];		//01
   assign ex1_mtfsb_bt[2] = ex1_instr[9] & (~ex1_instr[10]);		//10
   assign ex1_mtfsb_bt[3] = ex1_instr[9] & ex1_instr[10];		//11

   assign ex1_mtfs_bf[0] = (~ex1_instr[6]) & (~ex1_instr[7]) & (~ex1_instr[8]);		//000
   assign ex1_mtfs_bf[1] = (~ex1_instr[6]) & (~ex1_instr[7]) & ex1_instr[8];		//001
   assign ex1_mtfs_bf[2] = (~ex1_instr[6]) & ex1_instr[7] & (~ex1_instr[8]);		//010
   assign ex1_mtfs_bf[3] = (~ex1_instr[6]) & ex1_instr[7] & ex1_instr[8];		//011
   assign ex1_mtfs_bf[4] = ex1_instr[6] & (~ex1_instr[7]) & (~ex1_instr[8]);		//100
   assign ex1_mtfs_bf[5] = ex1_instr[6] & (~ex1_instr[7]) & ex1_instr[8];		//101
   assign ex1_mtfs_bf[6] = ex1_instr[6] & ex1_instr[7] & (~ex1_instr[8]);		//110
   assign ex1_mtfs_bf[7] = ex1_instr[6] & ex1_instr[7] & ex1_instr[8];		//111

   assign ex1_mcrfs_bfa[0] = (~ex1_instr[11]) & (~ex1_instr[12]) & (~ex1_instr[13]);		//000
   assign ex1_mcrfs_bfa[1] = (~ex1_instr[11]) & (~ex1_instr[12]) & ex1_instr[13];		//001
   assign ex1_mcrfs_bfa[2] = (~ex1_instr[11]) & ex1_instr[12] & (~ex1_instr[13]);		//010
   assign ex1_mcrfs_bfa[3] = (~ex1_instr[11]) & ex1_instr[12] & ex1_instr[13];		//011
   assign ex1_mcrfs_bfa[4] = ex1_instr[11] & (~ex1_instr[12]) & (~ex1_instr[13]);		//100
   assign ex1_mcrfs_bfa[5] = ex1_instr[11] & (~ex1_instr[12]) & ex1_instr[13];		//101
   assign ex1_mcrfs_bfa[6] = ex1_instr[11] & ex1_instr[12] & (~ex1_instr[13]);		//110
   assign ex1_mcrfs_bfa[7] = ex1_instr[11] & ex1_instr[12] & ex1_instr[13];		//111

   assign ex1_mtfsf_l = ex1_instr[6];
   assign ex1_mtfsf_w = ex1_instr[15];

   // Instr     bitdata         bitmask                 nibmask
   // mtfsb1    1111            dcd(instr[9:10])        dcd(instr[6:8])
   // mtfsb0    0000            dcd(instr[9:10])        dcd(instr[6:8])
   // mtfsfi    nstr[16:19]     1111                    dcd(instr[6:8])
   // mtfsf     0000            1111                    instr[7:14]
   // mcrfs     0000            1111                    dcd(instr[11:13])

   assign ex1_fpscr_bit_data[0:3] = (ex1_instr[16:19] | {4{ex1_mtfsb1}}) & {4{~(ex1_mtfsb0 | ex1_mtfsf | ex1_mcrfs)}};

   assign ex1_fpscr_bit_mask[0:3] = ex1_mtfsb_bt[0:3] | {4{ex1_mtfsfi}} | {4{ex1_mtfsf}} | {4{ex1_mcrfs}};

   assign ex1_fpscr_nib_mask[0:7] = (ex1_mtfs_bf[0:7] & {8{(ex1_mtfsb1 | ex1_mtfsb0)}}) |
                                    (ex1_mtfs_bf[0:7] & {8{(ex1_mtfsfi & (~ex1_mtfsf_w))}}) |
                                    (ex1_mtfsf_nib[0:7] & {8{ex1_mtfsf}}) |
                                    (ex1_mcrfs_bfa[0:7] & {8{ex1_mcrfs}});

   // nib mask[8] is "0"   except :
   // if (mtfsfi and W=0)         : nib_mask[0:7] <= dcd(BF);    nib_mask[8] <= 0
   // if (mtfsfi and W=1)         : nib_mask[0:7] <= 0000_0000;  nib_mask[8] <= dcd(BF)=="111"
   // if (mtfsff and L=1)         : nib_mask[0:7] <= 1111_1111;  nib_mask[8] <= 1
   // if (mtfsff and L=0 and W=0) : nib_mask[0:7] <= FLM[0:7];   nib_mask[8] <= 0
   // if (mtfsff and L=0 and W=1) : nib_mask[0:7] <= 0000_0000;  nib_mask[8] <= FLM[7]

   assign ex1_mtfsf_nib[0:7] = (ex1_instr[7:14] | {8{ex1_mtfsf_l}}) &
                               (~({8{((~ex1_mtfsf_l) & ex1_mtfsf_w)}}));

   assign ex1_fpscr_nib_mask[8] = (ex1_mtfsfi & ex1_mtfsf_w & ex1_mtfs_bf[7]) | (ex1_mtfsf & ex1_mtfsf_l) | (ex1_mtfsf & (~ex1_mtfsf_l) & ex1_mtfsf_w & ex1_instr[14]);

   assign f_dcd_ex1_fpscr_bit_data_b[0:3] = (~ex1_fpscr_bit_data[0:3]);
   assign f_dcd_ex1_fpscr_bit_mask_b[0:3] = (~ex1_fpscr_bit_mask[0:3]);
   assign f_dcd_ex1_fpscr_nib_mask_b[0:8] = (~ex1_fpscr_nib_mask[0:8]);

   //-------------------------------------------------------------------
   // Outputs to Mad
   assign f_dcd_ex1_thread = ex1_instr_v[0:1];		// one hot

   assign f_dcd_ex1_aop_valid = ex1_instr_fra_v;
   assign f_dcd_ex1_cop_valid = ex1_instr_frc_v | ((~perr_sm_l2[0]) & ex1_perr_sm_instr_v);		//Reading out parity  // perr_insert

   assign f_dcd_ex1_bop_valid = ex1_instr_frb_v | ((~perr_sm_l2[0]) & ex1_perr_sm_instr_v);		//Reading out parity  // perr_insert


   assign f_dcd_ex1_sp = ex1_sp & (~(ex1_fcfids | ex1_fcfiwus | ex1_fcfidus));
   assign f_dcd_ex1_emin_dp = tilo;
   assign f_dcd_ex1_emin_sp = ex1_frsp;
   assign f_dcd_ex1_force_pass_b = (~(ex1_fmr | ex1_fabs | ex1_fnabs | ex1_fneg | ex1_mtfsf | ex1_fcpsgn));
   assign f_dcd_ex1_fsel_b = (~ex1_fsel);
   assign f_dcd_ex1_from_integer_b = (~ex1_from_ints);
   assign f_dcd_ex1_to_integer_b = (~(ex1_to_ints | ex1_frim | ex1_frin | ex1_frip | ex1_friz));
   assign f_dcd_ex1_rnd_to_int_b = (~(ex1_frim | ex1_frin | ex1_frip | ex1_friz));
   assign f_dcd_ex1_math_b = (~(ex1_fmul | ex1_fmadd | ex1_fmsub | ex1_fadd | ex1_fsub | ex1_fnmsub | ex1_fnmadd));
   assign f_dcd_ex1_est_recip_b = (~ex1_fres);
   assign f_dcd_ex1_est_rsqrt_b = (~ex1_frsqrte);
   assign f_dcd_ex1_move_b = (~(ex1_moves));
   assign f_dcd_ex1_prenorm_b = (~(ex1_prenorm));
   assign f_dcd_ex1_frsp_b = (~ex1_frsp);
   assign f_dcd_ex1_compare_b = (~ex1_cr_val);
   assign f_dcd_ex1_ordered_b = (~ex1_fcmpo);
   assign f_dcd_ex1_sp_conv_b = (~(ex1_fcfids | ex1_fcfidus | ex1_fcfiwus));
   assign f_dcd_ex1_uns_b = (~(ex1_fcfidu | ex1_fcfidus | ex1_fcfiwu | ex1_fcfiwus | ex1_fctidu | ex1_fctiduz | ex1_fctiwu | ex1_fctiwuz));
   assign f_dcd_ex1_word_b = (~(ex1_fctiw | ex1_fctiwu | ex1_fctiwz | ex1_fctiwuz | ex1_fcfiwu | ex1_fcfiwus));
   assign f_dcd_ex1_sub_op_b = (~(ex1_fsub | ex1_fmsub | ex1_fnmsub | ex1_cr_val));
   assign f_dcd_ex1_inv_sign_b = (~(ex1_fnmadd | ex1_fnmsub));
   assign f_dcd_ex1_sign_ctl_b[0] = (~(ex1_fmr | ex1_fnabs));
   assign f_dcd_ex1_sign_ctl_b[1] = (~(ex1_fneg | ex1_fnabs));
   assign f_dcd_ex1_sgncpy_b = (~ex1_fcpsgn);
   assign f_dcd_ex1_mv_to_scr_b = (~(ex1_mcrfs | ex1_mtfsf | ex1_mtfsfi | ex1_mtfsb0 | ex1_mtfsb1));
   assign f_dcd_ex1_mv_from_scr_b = (~ex1_mffs);
   assign f_dcd_ex1_mtfsbx_b = (~(ex1_mtfsb0 | ex1_mtfsb1));
   assign f_dcd_ex1_mcrfs_b = (~ex1_mcrfs);
   assign f_dcd_ex1_mtfsf_b = (~ex1_mtfsf);
   assign f_dcd_ex1_mtfsfi_b = (~ex1_mtfsfi);

   assign ex0_instr_vld = |(ex0_instr_valid[0:3]);
   assign f_dcd_ex0_div = ex0_fdiv & ex0_instr_vld & (~ex0_ucode_preissue);
   assign f_dcd_ex0_divs = ex0_fdivs & ex0_instr_vld & (~ex0_ucode_preissue);
   assign f_dcd_ex0_sqrt = ex0_fsqrt & ex0_instr_vld & (~ex0_ucode_preissue);
   assign f_dcd_ex0_sqrts = ex0_fsqrts & ex0_instr_vld & (~ex0_ucode_preissue);
   assign f_dcd_ex0_record_v = rv_axu0_ex0_instr[31];

   assign f_dcd_ex2_divsqrt_v = |(ex2_fdivsqrt_start);

   assign f_dcd_ex1_itag = ex1_itag;

   assign f_dcd_flush[0:1] = cp_flush_q |
                             xu_ex3_flush[0:1] |
                             (ex3_fdivsqrt_start & {2{f_ex3_b_den_flush}}) |
	                     (ex3_fdivsqrt_start & {2{(ex3_abort_a | ex3_abort_b)}}); // kill fdiv/fsqrt on an abort

   assign f_dcd_ex1_mad_act = ex1_v | ex2_axu_v | ex1_perr_sm_instr_v;
   assign f_dcd_ex1_sto_act = ex1_str_v;


   // Force rounding mode.
   // 00 - round to nearest
   // 01 - round toward zero
   // 10 - round toward +Inf
   // 11 - round toward -Inf
   assign ex1_rnd0 = (ex1_frim | ex1_frip);

   assign ex1_rnd1 = (ex1_fctidz | ex1_fctiwz | ex1_fctiduz | ex1_fctiwuz | ex1_friz | ex1_frim);

   assign f_dcd_ex1_op_rnd_v_b = (~(ex1_fctidz | ex1_fctiwz | ex1_fctiduz | ex1_fctiwuz | ex1_frim | ex1_frin | ex1_frip | ex1_friz));
   assign f_dcd_ex1_op_rnd_b[0:1] = (~({ex1_rnd0, ex1_rnd1}));

   assign f_dcd_ex1_thread_b[0:3] = (~ex1_instr_v[0:3]);

   //----------------------------------------------------------------------
   // Store Decode
   assign pri_ex1[0:5] = ex1_instr[0:5];
   assign sec_ex1[20:31] = ex1_instr[20:31];

   assign st_ex1 = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[21]) & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[24] & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & sec_ex1[25] & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[29]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & sec_ex1[27] & sec_ex1[28] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & sec_ex1[23] & sec_ex1[24] & (~sec_ex1[25]) & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[23] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | (pri_ex1[0] & pri_ex1[1] & (~pri_ex1[2]) & pri_ex1[3]);
   assign single_precision_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & sec_ex1[28] & sec_ex1[29] & (~sec_ex1[30])) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[24])) | (pri_ex1[0] & (~pri_ex1[2]) & (~pri_ex1[4]));

   assign int_word_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[20] & (~sec_ex1[22]) & (~sec_ex1[23]) & (~sec_ex1[26]) & (~sec_ex1[27]) & (~sec_ex1[28]) & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[22] & sec_ex1[24] & sec_ex1[26] & (~sec_ex1[27]) & sec_ex1[28] & sec_ex1[29] & sec_ex1[30]) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28] & (~sec_ex1[29])) | ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] & (~sec_ex1[25]) & (~sec_ex1[29]));

   // store_tag[0:1]
   //          00 store DP
   //          10 store SP
   //          11 store SP Word
   assign f_dcd_ex1_sto_dp = (~single_precision_ldst);
   assign f_dcd_ex1_sto_sp = single_precision_ldst & (~int_word_ldst);
   assign f_dcd_ex1_sto_wd = single_precision_ldst & int_word_ldst;

   assign sign_ext_ldst = ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[21] &
                        (~sec_ex1[22]) & (~sec_ex1[23]) & sec_ex1[28] & (~sec_ex1[29]) & (~sec_ex1[30])) |
                        ((~pri_ex1[0]) & pri_ex1[1] & pri_ex1[2] & pri_ex1[3] & pri_ex1[4] & pri_ex1[5] & sec_ex1[22] &
                        (~sec_ex1[23]) & sec_ex1[24] & (~sec_ex1[25]));
   assign f_dcd_ex1_log2e_b = (~ex1_loge);
   assign f_dcd_ex1_pow2e_b = (~ex1_expte);

   assign f_dcd_ex1_ftdiv = ex1_ftdiv;
   assign f_dcd_ex1_ftsqrt = ex1_ftsqrt;

   //----------------------------------------------------------------------
   // ex2

   assign ex2_cr_val_din = ex1_cr_val | ex1_ftdiv | ex1_ftsqrt;

   // Latches



   tri_rlmreg_p #(.INIT(0), .WIDTH(21)) ex2_ctl(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex2_ctl_si[0:20]),
      .scout(ex2_ctl_so[0:20]),
      //-------------------------------------------
      .din({    ex1_instr_valid[0:3],
                ex2_cr_val_din,
                ex1_record,
                ex1_kill_wen,
                ex1_mcrfs,
                ex1_instr_match,
                ex1_is_ucode,
                ex1_fdivsqrt_start_din,
                ex1_fra_v,
                ex1_frb_v,
                ex1_frc_v,
                ex1_str_v,
                ex2_frs_byp_din,
                ex1_abort_a_din,
                ex1_abort_b_din,
                ex1_abort_c_din,
                ex1_abort_s_din}),
      //-------------------------------------------
      .dout({   ex2_instr_v[0:3],
                ex2_cr_val,
                ex2_record,
                ex2_kill_wen,
                ex2_mcrfs,
                ex2_instr_match,
                ex2_is_ucode,
                ex2_fdivsqrt_start,
                ex2_fra_v,
                ex2_frb_v,
                ex2_frc_v,
                ex2_str_v,
                ex2_frs_byp,
                ex2_abort_a_q,
                ex2_abort_b_q,
                ex2_abort_c_q,
                ex2_abort_s_q})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0), .WIDTH(6)) ex2_frt(
      .nclk(nclk),
      .act(ex1_v),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex2_frt_si[0:5]),
      .scout(ex2_frt_so[0:5]),
      //-------------------------------------------
      .din(ex1_instr_frt[0:5]),
      //-------------------------------------------
      .dout(ex2_instr_frt[0:5])
   );
   //-------------------------------------------




   assign ex1_ucode_preissue_din = ex1_ucode_preissue & |(ex1_instr_valid);


   tri_rlmreg_p #(.INIT(0), .WIDTH(16)) ex2_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex2_itag_si),
      .scout(ex2_itag_so),
      //-------------------------------------------
      .din({    ex1_itag[0:6],
                ex1_fpscr_addr[0:5],
                ex1_fpscr_wen,
                ex1_ucode_preissue_din,
                ex1_isRam}),
      //-------------------------------------------
      .dout({   ex2_itag[0:6],
                ex2_fpscr_addr[0:5],
                ex2_fpscr_wen,
                ex2_ucode_preissue,
                ex2_isRam})
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0), .WIDTH(5)) ex2_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[2]),
      .mpw1_b(mpw1_b[2]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex2_crbf_si[0:4]),
      .scout(ex2_crbf_so[0:4]),
      .din(ex1_cr_bf[0:4]),
      .dout(ex2_cr_bf[0:4])
   );

   // Flushes
   assign ex2_instr_valid[0:3] = ex2_instr_v[0:3] & (~xu_ex2_flush[0:3]);
   assign ex2_v = ex2_instr_v[0] | ex2_instr_v[1];
   assign ex2_axu_v = ex2_v | ex2_fdivsqrt_start[0] | ex2_fdivsqrt_start[1];

   assign ex2_instr_vld = (ex2_instr_v[0] & (~xu_ex2_flush[0])) | (ex2_instr_v[1] & (~xu_ex2_flush[1])) ;

   // Loads/Stores


   assign ex2_str_valid = ex2_str_v & |(ex2_instr_valid[0:3]);
   assign ex2_fra_valid = ex2_fra_v & ( |(ex2_instr_valid[0:3]) | |(ex2_fdivsqrt_start));
   assign ex2_frb_valid = ex2_frb_v & ( |(ex2_instr_valid[0:3]) | |(ex2_fdivsqrt_start));
   assign ex2_frc_valid = ex2_frc_v & |(ex2_instr_valid[0:3]);

   // Completion to XU
   assign ex2_ifar_val[0:3] = ex2_instr_valid[0:3];

   generate
      if (THREADS == 1)
      begin : dcd_store_data_val_thr1_1
         assign  fu_lq_ex2_store_data_val[0] = ex2_str_valid & ex2_instr_valid[0] & (~ex2_ucode_preissue) & (~ex2_abort_s);
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_store_data_val_thr2_1
         assign  fu_lq_ex2_store_data_val[0] = ex2_str_valid & ex2_instr_valid[0] & (~ex2_ucode_preissue) & (~ex2_abort_s);
         assign  fu_lq_ex2_store_data_val[1] = ex2_str_valid & ex2_instr_valid[1] & (~ex2_ucode_preissue) & (~ex2_abort_s);
      end
   endgenerate

   assign fu_lq_ex2_store_itag = ex2_itag;

   assign ex2_fdivsqrt_start_din = ex2_fdivsqrt_start & (~xu_ex2_flush[0:1]);

   assign ex2_abort_a = ex2_abort_a_q;
   assign ex2_abort_b = ex2_abort_b_q;
   assign ex2_abort_c = ex2_abort_c_q;
   assign ex2_abort_s = ex2_abort_s_q;

   assign ex2_abort_a_din = ex2_abort_a & (ex2_instr_vld | |(ex2_fdivsqrt_start_din));
   assign ex2_abort_b_din = ex2_abort_b & (ex2_instr_vld | |(ex2_fdivsqrt_start_din));
   assign ex2_abort_c_din = ex2_abort_c & ex2_instr_vld;
   assign ex2_abort_s_din = ex2_abort_s & ex2_instr_vld;

   assign axu0_rv_ex2_s1_abort = ex2_abort_a;  // these do not need to be gated with cp_flush
   assign axu0_rv_ex2_s2_abort = ex2_abort_b;
   assign axu0_rv_ex2_s3_abort = ex2_abort_c | ex2_abort_s;

   //----------------------------------------------------------------------
   // ex3

   // Latches

   tri_rlmreg_p #(.INIT(0), .WIDTH(7)) ex3_ctlng_lat(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_ctlng_si[0:6]),
      .scout(ex3_ctlng_so[0:6]),
      //-------------------------------------------
      .din({    ex2_instr_valid[0:3],
                ex2_instr_match,
                ex2_fdivsqrt_start_din[0:1]}),
      //-------------------------------------------
      .dout({   ex3_instr_v[0:3],
                ex3_instr_match,
                ex3_fdivsqrt_start[0:1] })
   );

   //-------------------------------------------
    tri_rlmreg_p #(.INIT(0), .WIDTH(24)) ex3_ctl_lat(
      .nclk(nclk),
      .act(ex2_axu_v),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_ctl_si[0:23]),
      .scout(ex3_ctl_so[0:23]),
      //-------------------------------------------
      .din({
		ex2_instr_frt[0:5],
		ex2_cr_val,
                ex2_record,
                ex2_str_valid,
                ex2_kill_wen,
                ex2_mcrfs,
                ex2_is_ucode,
                ex2_ifar_val[0:3],
                ex2_fra_valid,
                ex2_frb_valid,
                ex2_frc_valid,
                ex2_frs_byp,
                ex2_abort_a_din,
		ex2_abort_b_din,
		ex2_abort_c_din,
		ex2_abort_s_din}),
      //-------------------------------------------
      .dout({
		ex3_instr_frt[0:5],
		ex3_cr_val,
                ex3_record,
                ex3_str_v,
                ex3_kill_wen,
                ex3_mcrfs,
                ex3_is_ucode,
                ex3_ifar_val[0:3],
                ex3_fra_v,
                ex3_frb_v,
                ex3_frc_v,
                ex3_frs_byp,
                ex3_abort_a,
                ex3_abort_b,
                ex3_abort_c,
                ex3_abort_s })
   );

   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0), .WIDTH(1)) ex3_stdv_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
       .d_mode(tiup),
     .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_stdv_si),
      .scout(ex3_stdv_so),
      //-------------------------------------------
      .din(ex2_str_valid),
      .dout(ex3_store_v)
   );

   assign ex2_ucode_preissue_din = ex2_ucode_preissue & |(ex2_instr_valid);


   tri_rlmreg_p #(.INIT(0), .WIDTH(16)) ex3_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_itag_si),
      .scout(ex3_itag_so),
      //-------------------------------------------
      .din({    ex2_itag[0:6],
                ex2_fpscr_addr[0:5],
                ex2_fpscr_wen,
                ex2_ucode_preissue_din,
                ex2_isRam}),
      //-------------------------------------------
      .dout({  ex3_itag[0:6],
                ex3_fpscr_addr[0:5],
                ex3_fpscr_wen,
                ex3_ucode_preissue,
                ex3_isRam})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0), .WIDTH(5)) ex3_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[3]),
      .mpw1_b(mpw1_b[3]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex3_crbf_si[0:4]),
      .scout(ex3_crbf_so[0:4]),
      .din(ex2_cr_bf[0:4]),
      .dout(ex3_cr_bf[0:4])
   );



   // Flushes
   assign ex3_instr_valid[0:3] = ex3_instr_v[0:3] & (~xu_ex3_flush[0:3]);
   assign f_dcd_ex2_divsqrt_hole_v = ((~|(ex2_instr_v[0:3]))) & ((~|(ex0_instr_v[0:3]))) & (perr_sm_l2[0]);		// in case there is a denormal result, need both cycles free

   // The n flush for next cycle
   // The N flush can come from either an FU instruction, or a load in the XU pipe

   assign ex3_n_flush[0:3] = ((ex3_instr_valid[0:3] | {4{|({4{ex3_fdivsqrt_start}})}}) & {4{f_ex3_b_den_flush}} & (~({4{ex3_ucode_preissue}})));

   // flush2ucode
   assign ex3_flush2ucode[0:3] = (ex3_instr_v[0:3] | {4{|({4{ex3_fdivsqrt_start}})}}) & {4{f_ex3_b_den_flush}}  & (~xu_ex3_flush[0:3]);

   assign ex3_store_valid = ex3_store_v;

   assign ex3_fdivsqrt_start_din = ex3_fdivsqrt_start & (~xu_ex3_flush[0:1]);

   assign ex3_instr_vld = |((ex3_instr_v[0:1] & (~xu_ex3_flush[0:1])) | (ex3_fdivsqrt_start & (~xu_ex3_flush[0:1])));
   assign ex3_abort_din = (ex3_abort_a | ex3_abort_b | ex3_abort_c | ex3_abort_s) & ex3_instr_vld;

   assign fu_lq_ex3_abort = ex3_abort_s;

   //----------------------------------------------------------------------
   // ex4

   // Latches

   tri_rlmreg_p #(.INIT(0), .WIDTH(30)) ex4_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex4_ctl_si[0:29]),
      .scout(ex4_ctl_so[0:29]),
      //-------------------------------------------
      .din({    ex3_instr_valid[0:3],
                ex3_instr_frt[0:5],
                ex3_cr_val,
                ex3_record,
                f_ex3_b_den_flush,
                ex3_kill_wen,
                ex3_mcrfs,
                ex3_instr_match,
                ex3_is_ucode,
                ex3_n_flush[0:3],
                ex3_flush2ucode[0:3],
                ex3_store_valid,
                ex3_fdivsqrt_start_din,
                ex3_instr_vns_taken,
                ex3_abort_din}),
      //-------------------------------------------
      .dout(  { ex4_instr_v[0:3],
                ex4_instr_frt[0:5],
                ex4_cr_val,
                ex4_record,
                ex4_b_den_flush,
                ex4_kill_wen,
                ex4_mcrfs,
                ex4_instr_match,
                ex4_is_ucode,
		ex4_n_flush[0:3],
                ex4_flush2ucode[0:3],
                ex4_store_valid,
                ex4_fdivsqrt_start,
                ex4_instr_vns_taken,
                ex4_abort})
   );
   //-------------------------------------------

   assign ex3_ucode_preissue_din = ex3_ucode_preissue & |(ex3_instr_valid);


   tri_rlmreg_p #(.INIT(0), .WIDTH(16)) ex4_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex4_itag_si),
      .scout(ex4_itag_so),
      //-------------------------------------------
      .din({    ex3_itag[0:6],
                ex3_fpscr_addr[0:5],
                ex3_fpscr_wen,
                ex3_ucode_preissue_din,
                ex3_isRam}),
      //-------------------------------------------
      .dout({   ex4_itag[0:6],
                ex4_fpscr_addr[0:5],
                ex4_fpscr_wen,
                ex4_ucode_preissue,
                ex4_isRam})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(5)) ex4_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[4]),
      .mpw1_b(mpw1_b[4]),
      .mpw2_b(mpw2_b[0]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex4_crbf_si[0:4]),
      .scout(ex4_crbf_so[0:4]),
      .din(ex3_cr_bf[0:4]),
      .dout(ex4_cr_bf[0:4])
   );

   // Flushes
   assign ex4_instr_valid[0:3] = ex4_instr_v[0:3] & (~xu_ex4_flush[0:3]) & (~({4{ex4_store_valid}}));

   assign ex4_fdivsqrt_start_din = ex4_fdivsqrt_start & (~xu_ex4_flush[0:1]);


   // Outputs
   assign ex4_instr_vld = |((ex4_instr_v[0:1] & (~xu_ex4_flush[0:1])) | (ex4_fdivsqrt_start & (~xu_ex4_flush[0:1])));
   assign ex4_abort_din = ex4_abort & ex4_instr_vld;


   //----------------------------------------------------------------------
   // ex5

   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(22)) ex5_ctl_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex5_ctl_si),
      .scout(ex5_ctl_so),
      //-------------------------------------------
      .din({    ex4_instr_valid[0:3],
                ex4_instr_frt[0:5],
                ex4_cr_val,
                ex4_cr_val,
                ex4_record,
                ex4_kill_wen,
                ex4_mcrfs,
                ex4_is_ucode,
                ex4_fdivsqrt_start_din,
                ex4_instr_vns_taken_din,
                ex4_abort_din,
                spare_unused[22:23] }),

      //-------------------------------------------
      .dout({   ex5_instr_v[0:3],
                ex5_instr_frt[0:5],
                ex5_cr_val,
                ex5_cr_val_cp,
                ex5_record,
                ex5_kill_wen,
                ex5_mcrfs,
                ex5_is_ucode,
                ex5_fdivsqrt_start,
                ex5_instr_vns_taken,
                ex5_abort_l2,
                spare_unused[22:23] })
   );
   //-------------------------------------------
   assign ex4_ucode_preissue_din = ex4_ucode_preissue & |(ex4_instr_valid);


   tri_rlmreg_p #(.INIT(0),  .WIDTH(17)) ex5_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex5_itag_si),
      .scout(ex5_itag_so),
      //-------------------------------------------
      .din({    ex4_itag[0:6],
                ex5_b_den_flush_din,
                ex4_fpscr_addr[0:5],
                ex4_fpscr_wen,
                ex4_ucode_preissue_din,
                ex4_isRam}),
      //-------------------------------------------
      .dout({   ex5_itag[0:6],
                ex5_b_den_flush,
                ex5_fpscr_addr[0:5],
                ex5_fpscr_wen,
                ex5_ucode_preissue,
                ex5_isRam})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(5)) ex5_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[5]),
      .mpw1_b(mpw1_b[5]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex5_crbf_si[0:4]),
      .scout(ex5_crbf_so[0:4]),
      .din(ex4_cr_bf[0:4]),
      .dout(ex5_cr_bf[0:4])
   );

   // Pipe the CR
   assign ex5_cr[0:3] = f_add_ex5_fpcc_iu[0:3];

   // Flushes
   assign ex5_instr_valid[0:3] = (ex5_instr_v[0:3]) & (~xu_ex5_flush[0:3]);

   // This creates ex5_cr_val, make sure it wasn't flushed
   assign ex5_record_din = ex5_record & |(ex5_instr_valid[0:3]);
   assign ex5_mcrfs_din = ex5_mcrfs & |(ex5_instr_valid[0:3]);
   assign ex5_cr_val_din = ex5_cr_val & |(ex5_instr_valid[0:3]);

   assign ex5_instr_tid[0] = ex5_instr_v[2] | ex5_instr_v[3];
   assign ex5_instr_tid[1] = ex5_instr_v[1] | ex5_instr_v[3];

   //   ex6_kill_wen_din   <= ex5_kill_wen or ex5_uc_special;--Preserve s1 on special fdiv/fsqrt
   assign ex5_kill_wen_din = ex5_kill_wen;		//Preserve s1 on special fdiv/fsqrt


   assign ex5_instr_valid_din[0] = ex5_instr_valid[0];
   assign ex5_instr_valid_din[1] = ex5_instr_valid[1];
   assign ex5_instr_valid_din[2] = ex5_instr_valid[2];
   assign ex5_instr_valid_din[3] = ex5_instr_valid[3];

   assign ex5_instr_frt_din[0:5] = (ex5_instr_frt[0:5] & (~{6{perr_sm_l2[2]}})) | (perr_addr_l2[0:5] & {6{perr_sm_l2[2]}}); // perr_insert


   assign ex5_fdivsqrt_start_din = ex5_fdivsqrt_start & (~xu_ex5_flush[0:1]);

   assign ex5_instr_vld = |((ex5_instr_v[0:1] & (~xu_ex5_flush[0:1])) | (ex5_fdivsqrt_start & (~xu_ex5_flush[0:1])));
   assign ex5_abort_din = ex5_abort_l2 & ex5_instr_vld;
   assign ex5_abort_lq_din = lq_fu_ex5_abort ;

   //----------------------------------------------------------------------
   // ex6

   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(21)) ex6_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex6_ctl_si[0:20]),
      .scout(ex6_ctl_so[0:20]),
      //-------------------------------------------
      .din({    ex5_instr_valid_din[0:3],
                ex5_instr_frt_din[0:5],
                ex5_record_din,
                ex5_mcrfs_din,
                ex5_is_ucode,
                ex5_cr_val_din,
                ex5_kill_wen_din,
                ex5_fdivsqrt_start_din,
                ex5_abort_din,
                ex5_abort_lq_din,
                spare_unused[24:25]}),
      //-------------------------------------------
      .dout({   ex6_instr_v[0:3],
                ex6_instr_frt[0:5],
                ex6_record,
                ex6_mcrfs,
                ex6_is_ucode,
                ex6_cr_val,
                ex6_kill_wen_q,
                ex6_fdivsqrt_start,
                ex6_abort,
                ex6_abort_lq,
                spare_unused[24:25]})
   );
   //-------------------------------------------

   assign ex5_ucode_preissue_din = ex5_ucode_preissue & |(ex5_instr_valid);


   tri_rlmreg_p #(.INIT(0),  .WIDTH(17)) ex6_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex6_itag_si),
      .scout(ex6_itag_so),
      //-------------------------------------------
      .din({    ex5_itag_din[0:6],
                ex5_b_den_flush,
                ex5_fpscr_addr[0:5],
                ex5_fpscr_wen,
                ex5_ucode_preissue_din,
                ex5_isRam}),
      //-------------------------------------------
      .dout({   ex6_itag[0:6],
                ex6_b_den_flush,
                ex6_fpscr_addr[0:5],
                ex6_fpscr_wen,
                ex6_ucode_preissue,
                ex6_isRam})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(9)) ex6_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[6]),
      .mpw1_b(mpw1_b[6]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex6_crbf_si[0:8]),
      .scout(ex6_crbf_so[0:8]),
      .din({   ex5_cr_bf[0:4],
               ex5_cr[0:3]}),
      .dout({  ex6_cr_bf[0:4],
               ex6_cr[0:3]})
   );

   assign ex6_instr_tid[0] = ((ex6_instr_v[0] | (f_dsq_ex6_divsqrt_instr_tid[0] & ex6_divsqrt_v)) & (~xu_ex6_flush[0]));
   assign ex6_instr_tid[1] = ((ex6_instr_v[1] | (f_dsq_ex6_divsqrt_instr_tid[1] & ex6_divsqrt_v)) & (~xu_ex6_flush[1]));

   assign ex6_iflush_b[0] = (~(xu_ex6_flush[0] & ex6_instr_v[0]));		//big
   assign ex6_iflush_b[1] = (~(xu_ex6_flush[1] & ex6_instr_v[1]));		//big
   assign ex6_iflush_b[2] = (~(xu_ex6_flush[2] & ex6_instr_v[2]));		//big
   assign ex6_iflush_b[3] = (~(xu_ex6_flush[3] & ex6_instr_v[3]));		//big

   assign ex6_iflush_01 = (~(ex6_iflush_b[0] & ex6_iflush_b[1]));
   assign ex6_iflush_23 = (~(ex6_iflush_b[2] & ex6_iflush_b[3]));

   assign ex6_instr_flush_b = (~(ex6_iflush_01 | ex6_iflush_23));

   assign ex6_instr_flush = (~ex6_instr_flush_b);		//small

   assign ex6_divsqrt_v = |(f_dsq_ex6_divsqrt_v);
   assign ex6_divsqrt_v_suppress = f_dsq_ex6_divsqrt_v_suppress;

   // perr_insert
   assign ex6_instr_valid[0] = ((ex6_instr_v[0] | (f_dsq_ex6_divsqrt_instr_tid[0] & ex6_divsqrt_v)) & (~xu_ex6_flush[0]))  | (perr_sm_l2[2] & ex6_perr_sm_instr_v & perr_tid_l2[0:1] == 2'b10);
   assign ex6_instr_valid[1] = ((ex6_instr_v[1] | (f_dsq_ex6_divsqrt_instr_tid[1] & ex6_divsqrt_v)) & (~xu_ex6_flush[1]))  | (perr_sm_l2[2] & ex6_perr_sm_instr_v & perr_tid_l2[0:1] == 2'b01);
   assign ex6_instr_valid[2] = ((ex6_instr_v[2] | (f_dsq_ex6_divsqrt_instr_tid[2] & ex6_divsqrt_v)) & (~xu_ex6_flush[2]))  ;
   assign ex6_instr_valid[3] = ((ex6_instr_v[3] | (f_dsq_ex6_divsqrt_instr_tid[3] & ex6_divsqrt_v)) & (~xu_ex6_flush[3]))  ;

   assign ex6_instr_valid_din[0] = ex6_instr_valid[0];
   assign ex6_instr_valid_din[1] = ex6_instr_valid[1];
   assign ex6_instr_valid_din[2] = ex6_instr_valid[2];
   assign ex6_instr_valid_din[3] = ex6_instr_valid[3];


   assign ex6_kill_wen = (ex6_kill_wen_q & (~(ex6_divsqrt_v & (~ex6_divsqrt_v_suppress)))) | (ex6_divsqrt_v & ex6_divsqrt_v_suppress);

   assign ex6_kill_wen_din = (ex6_kill_wen | (((~f_pic_ex6_fpr_wr_dis_b)) & (~ex6_divsqrt_v))) & (~(perr_sm_l2[2] & ex6_perr_sm_instr_v)); // parity merge
   assign ex6_fpr_wr_dis = ((((~f_pic_ex6_fpr_wr_dis_b)) & (~ex6_divsqrt_v)) & (~ex6_kill_wen)) | (ex6_divsqrt_v & ex6_divsqrt_v_suppress);

   //Make a copy without the flush for bypass
   assign ex6_instr_bypval[0] = ex6_instr_v[0] & f_pic_ex6_fpr_wr_dis_b & (~ex6_kill_wen);
   assign ex6_instr_bypval[1] = ex6_instr_v[1] & f_pic_ex6_fpr_wr_dis_b & (~ex6_kill_wen);
   assign ex6_instr_bypval[2] = ex6_instr_v[2] & f_pic_ex6_fpr_wr_dis_b & (~ex6_kill_wen);
   assign ex6_instr_bypval[3] = ex6_instr_v[3] & f_pic_ex6_fpr_wr_dis_b & (~ex6_kill_wen);

   assign f_dcd_ex6_frt_tid[0:1] = ex6_instr_tid[0:1];

   // Don't update CR during certain exceptions
   assign ex7_record_din = (ex6_record | (ex6_divsqrt_v & f_dsq_ex6_divsqrt_record_v)) & (~ex6_instr_flush);
   assign ex7_mcrfs_din = ex6_mcrfs & (~ex6_instr_flush);
   assign ex7_cr_val_din = ex6_cr_val & (~ex6_instr_flush);

   assign ex6_cr_bf_din = (ex6_cr_bf & {5{(~ex6_divsqrt_v)}}) | (f_dsq_ex6_divsqrt_cr_bf & {5{ex6_divsqrt_v}});
   // Outputs
   assign ex6_fpscr_move = (~(f_pic_ex6_scr_upd_move_b));

   assign ex6_fdivsqrt_start_din = ex6_fdivsqrt_start & (~xu_ex6_flush[0:1]);

   assign ex6_instr_vld = |((ex6_instr_v[0:1] & (~xu_ex6_flush[0:1])) | (ex6_fdivsqrt_start & (~xu_ex6_flush[0:1])));
   assign ex6_abort_din = ex6_abort & ex6_instr_vld;

   //----------------------------------------------------------------------
   // ex7

   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(23)) ex7_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_ctl_si[0:22]),
      .scout(ex7_ctl_so[0:22]),
      //-------------------------------------------
      .din({    ex6_instr_valid_din[0:3],
                ex7_instr_frt_din[0:5],
                ex7_record_din,
                ex7_mcrfs_din,
                ex6_is_ucode,
                ex7_cr_val_din,
                ex6_kill_wen_din,
                ex6_fpr_wr_dis,
                ex6_fdivsqrt_start_din,
                ex6_abort_din,
                ex6_abort_lq,
                spare_unused[26:27],
                spare_unused[30]}),
      //-------------------------------------------
      .dout({   ex7_instr_v[0:3],
                ex7_instr_frt[0:5],
                ex7_record,
                ex7_mcrfs,
                ex7_is_ucode,
                ex7_cr_val,
                ex7_kill_wen,
                ex7_fpr_wr_dis,
                ex7_fdivsqrt_start,
                ex7_abort,
                ex7_abort_lq,
                spare_unused[26:27],
                spare_unused[30] })
   );
   //-------------------------------------------

   assign ex7_fdivsqrt_start_din = ex7_fdivsqrt_start & (~xu_ex7_flush[0:1]);

   assign ex6_ucode_preissue_din = ex6_ucode_preissue & |(ex6_instr_valid);


   tri_rlmreg_p #(.INIT(0),  .WIDTH(18)) ex7_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_itag_si),
      .scout(ex7_itag_so),
      //-------------------------------------------
      .din({    ex6_itag[0:6],
                ex6_b_den_flush,
                ex6_fpscr_addr_din[0:5],
                ex6_fpscr_wen_din,
                ex6_fpscr_move,
                ex6_ucode_preissue_din,
                ex6_isRam}),
      //-------------------------------------------
      .dout({   ex7_itag[0:6],
                ex7_b_den_flush,
                ex7_fpscr_addr[0:5],
                ex7_fpscr_wen,
                ex7_fpscr_move,
                ex7_ucode_preissue,
                ex7_isRam})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(18)) ex7_la(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_laddr_si),
      .scout(ex7_laddr_so),
      //-------------------------------------------
      .din({    ex6_load_addr[0:7],
		ex6_reload_addr[0:7],
                ex6_load_v,
                ex6_reload_v		}),
      //-------------------------------------------
      .dout({   ex7_load_addr[0:7],
		ex7_reload_addr[0:7],
                ex7_load_v,
                ex7_reload_v})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(9)) ex7_crbf(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[7]),
      .mpw1_b(mpw1_b[7]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex7_crbf_si[0:8]),
      .scout(ex7_crbf_so[0:8]),
      .din({ ex6_cr_bf_din[0:4],
             ex6_cr[0:3]}),
      .dout({  ex7_cr_bf[0:4],
               ex7_cr[0:3]})
   );

   assign ex7_instr_tid[0] = ex7_instr_v[2] | ex7_instr_v[3];
   assign ex7_instr_tid[1] = ex7_instr_v[1] | ex7_instr_v[3];

   // Flushes -  flushes in ex7

   // perr_insert
   assign ex7_instr_valid = |(ex7_instr_v[0:1] & (~cp_flush_q[0:1])) | (perr_sm_l2[2] & ex7_perr_sm_instr_v);

   assign ex7_instr_v_din[0] = (ex7_instr_v[0] & (~cp_flush_q[0])) | (perr_sm_l2[2] & ex7_perr_sm_instr_v & perr_tid_l2[0]);
   assign ex7_instr_v_din[1] = (ex7_instr_v[1] & (~cp_flush_q[1])) | (perr_sm_l2[2] & ex7_perr_sm_instr_v & perr_tid_l2[1]);

   // Outputs ex7
   assign f_dcd_ex7_frt_addr[0:5] = ex7_instr_frt[0:5];
   assign f_dcd_ex7_frt_tid[0:1] = ex7_instr_tid[0:1];
   assign f_dcd_ex7_frt_wen = ex7_instr_valid & (~ex7_kill_wen) & (~ex7_ucode_preissue) & (~ex7_fu_unavail) & (~ex7_abort) & (~ex7_perr_cancel);

   assign f_dcd_ex7_fpscr_wr = ex7_fpscr_wen & ex7_instr_valid & (~ex7_ucode_preissue) & (~ex7_fu_unavail) & (~ex7_abort);
   assign f_dcd_ex7_fpscr_addr[0:5] = ex7_fpscr_addr[0:5];

   assign ex7_perr_cancel = |(ex7_regfile_err_det[0:1] & ex7_instr_v[0:1]);

   assign f_dcd_ex7_cancel = ((~ex7_instr_valid)) | ex7_ucode_preissue | ex7_fu_unavail | ex7_b_den_flush | ex7_perr_cancel;

   // Records
   assign ex7_record_v = ex7_instr_valid & (ex7_record | ex7_mcrfs);

   assign ex8_b_den_flush_din = ex7_b_den_flush & (ex7_instr_valid | |(ex7_fdivsqrt_start));

   assign ex8_fpr_wr_dis_din = ex7_fpr_wr_dis & ex7_instr_valid & (~ex7_fu_unavail);

   assign ex8_fpscr_move_din = ex7_fpscr_move & ex7_instr_valid;

   //----------------------------------------------------------------------
   // ex8 FPSCR, Record Forms

   assign ex7_ucode_preissue_din = ex7_ucode_preissue & ex7_instr_valid;
   assign ex7_instr_vld = |((ex7_instr_v[0:1] & (~xu_ex7_flush[0:1])) | (ex7_fdivsqrt_start & (~xu_ex7_flush[0:1])));
   assign ex7_abort_din = ex7_abort & ex7_instr_vld;


   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(32)) ex8_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[8]),
      .mpw1_b(mpw1_b[8]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex8_ctl_si[0:31]),
      .scout(ex8_ctl_so[0:31]),
      //-------------------------------------------
      .din({    ex7_record_v,
                ex7_cr_bf[0:4],
                ex7_instr_valid,
                ex7_instr_frt[0:5],
                ex7_cr[0:3],
                ex7_cr_val,
		ex7_instr_tid[0:1],
		ex8_fpr_wr_dis_din,
                ex7_kill_wen,
                ex8_fpscr_move_din,
                ex7_ucode_preissue_din,
		ex7_fdivsqrt_start_din,
                ex7_instr_v_din[0:1],
                ex7_abort_din,
                ex7_abort_lq,
                spare_unused[28:29]
             }),

      //-------------------------------------------
      .dout({   ex8_record_v,
                ex8_cr_bf[0:4],
                ex8_instr_v,
                ex8_instr_frt[0:5],
                ex8_cr[0:3],
                ex8_cr_val,
                ex8_instr_tid[0:1],
                ex8_fpr_wr_dis,
                ex8_kill_wen,
                ex8_fpscr_move,
                ex8_ucode_preissue,
                ex8_fdivsqrt_start,
                ex8_instr_valid,
                ex8_abort,
                ex8_abort_lq,
                spare_unused[28:29]
                })
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(8)) ex8_itagl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[8]),
      .mpw1_b(mpw1_b[8]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex8_itag_si),
      .scout(ex8_itag_so),
      //-------------------------------------------
      .din({    ex7_itag[0:6],
                ex8_b_den_flush_din}),
      //-------------------------------------------
      .dout({   ex8_itag[0:6],
                ex8_b_den_flush})
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0),  .WIDTH(18)) ex8_la(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[8]),
      .mpw1_b(mpw1_b[8]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex8_laddr_si),
      .scout(ex8_laddr_so),
      //-------------------------------------------
      .din({    ex7_load_addr[0:7],
		ex7_reload_addr[0:7],
                ex7_load_v,
                ex7_reload_v}),
      //-------------------------------------------
      .dout({   ex8_load_addr[0:7],
		ex8_reload_addr[0:7],
                ex8_load_v,
                ex8_reload_v})
   );
   //-------------------------------------------

   //----------------------------------------------------------------------
   // ex9

   // Latches
   assign ex8_instr_vld = |((ex8_instr_valid[0:1] & (~xu_ex8_flush[0:1])) | (ex8_fdivsqrt_start & (~xu_ex8_flush[0:1])));
   assign ex8_abort_din = ex8_abort & ex8_instr_vld;

   assign ex8_fdivsqrt_start_din = ex8_fdivsqrt_start & (~xu_ex8_flush[0:1]);


   tri_rlmreg_p #(.INIT(0),  .WIDTH(14)) ex9_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex9_ctl_si[0:13]),
      .scout(ex9_ctl_so[0:13]),
      //-------------------------------------------
      .din({ ex8_instr_v,
             ex8_instr_frt[0:5],
             ex8_instr_tid[0:1],
             ex8_kill_wen,
             ex8_abort_din,
             ex8_abort_lq,
             ex8_fdivsqrt_start_din}),
      //-------------------------------------------
      .dout({   ex9_instr_v,
                ex9_instr_frt[0:5],
                ex9_instr_tid[0:1],
                ex9_kill_wen,
                ex9_abort_q,
                ex9_abort_lq,
                ex9_fdivsqrt_start})
   );
   //-------------------------------------------
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0),  .WIDTH(9)) ex9_la(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ex9_laddr_si),
      .scout(ex9_laddr_so),
      //-------------------------------------------
      .din({    ex8_load_addr[0:7],
                ex8_load_v
            }),
      //-------------------------------------------
      .dout({   ex9_load_addr[0:7],
                ex9_load_v
            })
   );
   //-------------------------------------------
   assign ex9_instr_valid[0:1] = {(ex9_instr_v & (~ex9_instr_tid[1])),(ex9_instr_v & (ex9_instr_tid[1]))};

   assign ex9_instr_vld = |((ex9_instr_valid[0:1] & (~xu_ex9_flush[0:1])) | (ex9_fdivsqrt_start & (~xu_ex9_flush[0:1])));
   assign ex9_abort = ex9_abort_q & ex9_instr_vld;

   //----------------------------------------------------------------------
   // COMPLETION

   // Send update to completion at ealiest bypass point

   // CR
   assign axu0_cr_w4e = ex8_cr_val | ex8_record_v;

   generate
      if (THREADS == 1)
      begin : dcd_cr_w4a_thr1_1
         assign  axu0_cr_w4a[0:4] = ex8_cr_bf[0:4];
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_cr_w4a_thr2_1
         assign  axu0_cr_w4a[0:5] = {ex8_cr_bf[0:4], ex8_instr_tid[1]};
      end
   endgenerate

   assign axu0_cr_w4d[0:3] = (f_scr_ex8_cr_fld[0:3] & {4{ex8_record_v}}) | (ex8_cr[0:3] & ({4{~ex8_record_v}}));

   assign ex5_divsqrt_itag[0:6] = f_dsq_ex5_divsqrt_itag;
   assign ex6_divsqrt_fpscr_addr[0:5] = f_dsq_ex6_divsqrt_fpscr_addr;

   assign ex3_instr_vns_taken = (ex3_instr_vns[0] & (~|(ex4_instr_vns)) & (~|(ex5_cr_or_divsqrt_v))) | (ex3_instr_vns[1] & (~|(ex4_instr_vns)) & (~|(ex5_cr_or_divsqrt_v)));

   assign ex4_instr_vns_taken_din = ex4_instr_vns_taken | ((ex4_instr_vns[0] & (~|(ex5_cr_or_divsqrt_v))) | (ex4_instr_vns[1] & (~|(ex5_cr_or_divsqrt_v))));

   assign ex3_instr_vns = ex3_instr_v  & (~{4{ex3_store_valid}}) & {4{~(ex3_cr_val | ex3_record | ex3_mcrfs)}};
   assign ex4_instr_vns = ex4_instr_v  & (~{4{ex4_store_valid}}) & {4{~(ex4_cr_val | ex4_record | ex4_mcrfs)}} & (~{4{ex4_instr_vns_taken}});
   assign ex5_instr_vns = ex5_instr_v  & {4{(~ex5_cr_val | ex5_record | ex5_mcrfs)}} & (~{4{ex5_instr_vns_taken}}); // ex5_instr_v was gated off by ex4_store_valid the prev cycle

   assign ex5_cr_or_divsqrt_v[0] = f_dsq_ex5_divsqrt_v[0] | (ex5_instr_v[0]  & (ex5_cr_val | ex5_record | ex5_mcrfs)) | ex5_instr_vns[0];
   assign ex5_cr_or_divsqrt_v[1] = f_dsq_ex5_divsqrt_v[1] | (ex5_instr_v[1]  & (ex5_cr_val | ex5_record | ex5_mcrfs)) | ex5_instr_vns[1];
   assign ex5_any_cr_v = (|(ex5_instr_v) & (~ex5_divsqrt_v)) & (ex5_cr_val | ex5_record | ex5_mcrfs);

   generate
      if (THREADS == 1)
      begin : dcd_axu0_itag_vld_thr1_1

         assign  axu0_rv_itag_vld[0] = (ex3_instr_vns[0] & (~ex4_instr_vns[0]) & (~ex5_cr_or_divsqrt_v[0])) |
                                       (ex4_instr_vns[0] & (~ex5_cr_or_divsqrt_v[0])) |
                                       (ex5_cr_or_divsqrt_v[0]);
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_axu0_itag_vld_thr2_1

         assign  axu0_rv_itag_vld[0] = (ex3_instr_vns[0] & (~(|(ex4_instr_vns))) & (~(|(ex5_cr_or_divsqrt_v)))) |
                                       (ex4_instr_vns[0] & (~(|(ex5_cr_or_divsqrt_v)))) |
                                       (ex5_cr_or_divsqrt_v[0]);

         assign  axu0_rv_itag_vld[1] = (ex3_instr_vns[1] & (~(|(ex4_instr_vns))) & (~(|(ex5_cr_or_divsqrt_v)))) |
                                       (ex4_instr_vns[1] & (~(|(ex5_cr_or_divsqrt_v)))) |
                                       (ex5_cr_or_divsqrt_v[1]);
      end
   endgenerate

   assign axu0_rv_itag = (ex3_itag[0:6] &         {7{ ((~(ex5_divsqrt_v | ex5_any_cr_v | |(ex5_instr_vns))) & (~|(ex4_instr_vns)) & |(ex3_instr_vns)) }} ) |
                         (ex4_itag[0:6] &         {7{ ((~(ex5_divsqrt_v | ex5_any_cr_v | |(ex5_instr_vns))) & |(ex4_instr_vns))}} ) |
                         (ex5_itag[0:6] &         {7{ ((ex5_any_cr_v | |(ex5_instr_vns)) & (~ex5_divsqrt_v))}} ) |
                         (ex5_divsqrt_itag[0:6] & {7{ (ex5_divsqrt_v)}});

   assign axu0_rv_itag_abort = (ex3_abort_din &  ((~(ex5_divsqrt_v | ex5_any_cr_v | |(ex5_instr_vns))) & (~|(ex4_instr_vns)) & |(ex3_instr_vns))  ) |
                               (ex4_abort &      ((~(ex5_divsqrt_v | ex5_any_cr_v | |(ex5_instr_vns))) & |(ex4_instr_vns)) ) |
                               (ex5_abort_l2 &   ((ex5_any_cr_v | |(ex5_instr_vns)) & (~ex5_divsqrt_v)) ) ;

   assign ex5_divsqrt_v = |(f_dsq_ex5_divsqrt_v);
   assign axu0_rv_ord_complete = ex5_divsqrt_v;

   assign ex5_itag_din = (ex5_itag[0:6] &           {7{ (~ex5_divsqrt_v)}}) |
                         (ex5_divsqrt_itag[0:6] &   {7{   ex5_divsqrt_v}});

   assign ex6_fpscr_wen_din = ex6_fpscr_wen | ex6_divsqrt_v;
   assign ex6_fpscr_addr_din = (ex6_fpscr_addr &           {6{(~ex6_divsqrt_v)}}) |
                               (ex6_divsqrt_fpscr_addr &   {6{ex6_divsqrt_v}});

   assign ex7_instr_frt_din = (ex6_instr_frt &                {6{(~ex6_divsqrt_v)}}) |
                              (f_dsq_ex6_divsqrt_instr_frt &  {6{  ex6_divsqrt_v}});

   generate
      if (THREADS == 1)
      begin : dcd_itag_vld_thr1_1
         assign  axu1_rv_itag_vld[0] = tidn;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_itag_vld_thr2_1
         assign  axu1_rv_itag_vld = 2'b00;
      end
   endgenerate

   assign axu1_rv_itag = 7'b0000000;
   assign axu1_rv_itag_abort = 1'b0;

   assign ex5_fu_unavail = |((ex5_instr_v[0:1] | ex5_fdivsqrt_start_din[0:1]) & (~msr_fp[0:1]));
   assign ex6_fu_unavail = |((ex6_instr_v[0:1] | ex6_fdivsqrt_start_din[0:1]) & (~msr_fp[0:1]));
   assign ex7_fu_unavail = |((ex7_instr_v[0:1] | ex7_fdivsqrt_start_din[0:1]) & (~msr_fp[0:1]));
   assign ex8_fu_unavail = (ex8_instr_valid[0:1] | ex8_fdivsqrt_start_din[0:1]) & (~msr_fp[0:1]);

   // AXU0 Instruction Executed
   generate
      if (THREADS == 2)
      begin : dcd_exe0_vld_thr2_1
         assign  axu0_iu_execute_vld[0] = (ex8_instr_valid[0] | (ex8_fdivsqrt_start[0] & (ex8_b_den_flush | ex8_regfile_err_det[0]))) & (~ex8_abort) & (~ex8_perr_sm_instr_v);
         assign  axu0_iu_execute_vld[1] = (ex8_instr_valid[1] | (ex8_fdivsqrt_start[1] & (ex8_b_den_flush | ex8_regfile_err_det[1]))) & (~ex8_abort) & (~ex8_perr_sm_instr_v);
      end
   endgenerate
   generate
      if (THREADS == 1)
      begin : dcd_exe0_vld_thr1_1
         assign  axu0_iu_execute_vld[0] = (ex8_instr_valid[0] | (ex8_fdivsqrt_start[0] & (ex8_b_den_flush | ex8_regfile_err_det[0]))) & (~ex8_abort)  & (~ex8_perr_sm_instr_v);
      end
   endgenerate

   assign ex8_ucode_preissue_din = ex8_ucode_preissue & |(ex8_instr_valid);

   assign axu0_iu_itag = ex8_itag[0:6];
   assign axu0_iu_n_flush = (|(ex8_fu_unavail) | ex8_b_den_flush | |(ex8_regfile_err_det) ) & (~ex8_ucode_preissue);
   assign axu0_iu_np1_flush = (ex8_fpr_wr_dis | |(ex8_fp_enabled) | ex8_fpscr_move) & (~ex8_ucode_preissue);
   assign axu0_iu_n_np1_flush = |(ex8_fp_enabled) & (~ex8_ucode_preissue);
   assign axu0_iu_flush2ucode = ex8_b_den_flush & (~ex8_ucode_preissue) & (~|(ex8_fu_unavail));
   assign axu0_iu_flush2ucode_type = 1'b0;

   // Exception vector encodes
   //| 1 0000   AP Unavailable
   //| 1 0001   FP Unavailable
   //| 1 0010   Vector Unavailable
   //| 1 0011   Progam AP Enabled
   //| 1 0100   Progam FP Enabled
   //| 1 0101   Progam FP Enabled, gate FPR write

   assign fp_except_fx[0] = f_scr_ex8_fx_thread0[0];
   assign fp_except_fx[1] = f_scr_ex8_fx_thread1[0];
   assign fp_except_fex[0] = f_scr_ex8_fx_thread0[1];
   assign fp_except_fex[1] = f_scr_ex8_fx_thread1[1];
   assign fp_except_fex_async[0] = f_scr_cpl_fx_thread0[1];
   assign fp_except_fex_async[1] = f_scr_cpl_fx_thread1[1];

   // Denorm flushes take priority over fp_enabled exceptions
   assign ex8_fp_enabled = ex8_instr_valid & fp_except_en_q & fp_except_fex & (~ex8_fu_unavail) & (~{2{(ex8_b_den_flush)}});

   // async fex (AP Enabled) exception occurs when the fex bit was set previously, but exceptions weren't enabled
   //  until a later time.  This exception is imprecise.
   //rising edge sets
   assign fp_async_fex_d = (fp_except_fex_async & fp_except_en_d & (~fp_except_en_q)) | (fp_async_fex_q & (~(fp_except_en_q & (~fp_except_en_d))));		//falling edge clears

   assign axu0_iu_exception_val = (|(ex8_fu_unavail) | |(ex8_fp_enabled)) & (~ex8_ucode_preissue);
   assign axu0_iu_exception[0:3] = {1'b0,
                                   (|(ex8_fp_enabled) | ex8_fpr_wr_dis),
                                    1'b0,
                                    (|(ex8_fu_unavail) | ex8_fpr_wr_dis)};

   generate
      if (THREADS == 1)
      begin : dcd_async_fex_thr1_1
         assign  axu0_iu_async_fex[0] = fp_async_fex_q[0];
         assign  spare_unused[12] = fp_async_fex_q[1];
	 assign  msr_pr_d[0] = xu_fu_msr_pr[0];
	 assign  msr_pr_d[1] = tidn;
	 assign  msr_gs_d[0] = xu_fu_msr_gs[0];
	 assign  msr_gs_d[1] = tidn;

      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_async_fex_thr2_1
         assign  axu0_iu_async_fex[0] = fp_async_fex_q[0];
         assign  axu0_iu_async_fex[1] = fp_async_fex_q[1];
         assign  spare_unused[12] = tidn;
	 assign  msr_pr_d[0] = xu_fu_msr_pr[0];
	 assign  msr_pr_d[1] = xu_fu_msr_pr[1];
	 assign  msr_gs_d[0] = xu_fu_msr_gs[0];
	 assign  msr_gs_d[1] = xu_fu_msr_gs[1];

      end
   endgenerate

   assign fp_except_en_d = msr_fe0 | msr_fe1;


   tri_rlmreg_p #(.INIT(0),  .WIDTH(4)) axu_ex(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(axu_ex_si[0:3]),
      .scout(axu_ex_so[0:3]),
      //-------------------------------------------
      .din({fp_except_en_d,
            fp_async_fex_d }),
      //-------------------------------------------
      .dout({ fp_except_en_q,
              fp_async_fex_q})
   );
   //-------------------------------------------

   // AXU1 Instruction Executed
   generate
      if (THREADS == 1)
      begin : dcd_exe_vld_thr1_1
         assign  axu1_iu_execute_vld = 1'b0;
      end
   endgenerate

   generate
      if (THREADS == 2)
      begin : dcd_exe_vld_thr2_1
         assign  axu1_iu_execute_vld = 2'b00;
      end
   endgenerate

   assign axu1_iu_itag = 7'b0000000;
   assign axu1_iu_n_flush = 1'b0;
   assign axu1_iu_np1_flush = 1'b0;
   assign axu1_iu_exception[0:3] = 4'b0000;
   assign axu1_iu_flush2ucode = 1'b0;
   assign axu1_iu_flush2ucode_type = 1'b0;
   assign axu1_iu_exception_val = 1'b0;

   //----------------------------------------------------------------------
   // Parity State Machine / parity section

   tri_parity_recovery #(.THREADS(`THREADS)) fu_parity_recovery(
    .perr_si(perr_si),
    .perr_so(perr_so),
    .mpw1_b(mpw1_b),
    .mpw2_b(mpw2_b),
    .nclk(nclk),
    .force_t(force_t),
    .thold_0_b(thold_0_b),
    .sg_0(sg_0),
    .gnd(gnd),
    .vdd(vdd),

    .ex3_hangcounter_trigger(f_dsq_ex3_hangcounter_trigger),

    .ex3_a_parity_check(f_mad_ex3_a_parity_check),
    .ex3_b_parity_check(f_mad_ex3_b_parity_check),
    .ex3_c_parity_check(f_mad_ex3_c_parity_check),
    .ex3_s_parity_check(f_sto_ex3_s_parity_check),

    .rf0_instr_fra(rf0_instr_fra),
    .rf0_instr_frb(rf0_instr_frb),
    .rf0_instr_frc(rf0_instr_frc),
    .rf0_tid(rf0_tid),

    .rf0_dcd_fra(f_dcd_rf0_fra),
    .rf0_dcd_frb(f_dcd_rf0_frb),
    .rf0_dcd_frc(f_dcd_rf0_frc),
    .rf0_dcd_tid(f_dcd_rf0_tid),

    .ex1_instr_fra(ex1_instr_fra),
    .ex1_instr_frb(ex1_instr_frb),
    .ex1_instr_frc(ex1_instr_frc),
    .ex1_instr_frs(ex1_instr_frs),

    .ex3_fra_v(ex3_fra_v),
    .ex3_frb_v(ex3_frb_v),
    .ex3_frc_v(ex3_frc_v),
    .ex3_str_v(ex3_str_v),
    .ex3_frs_byp(ex3_frs_byp),

    .ex3_fdivsqrt_start(ex3_fdivsqrt_start),
    .ex3_instr_v(ex3_instr_v[0:1]),
    .msr_fp_act(msr_fp_act),
    .cp_flush_1d(cp_flush_q),

    .ex7_is_fixperr(ex7_is_fixperr),

    .xx_ex4_regfile_err_det(ex4_regfile_err_det),
    .xx_ex5_regfile_err_det(ex5_regfile_err_det),
    .xx_ex6_regfile_err_det(ex6_regfile_err_det),
    .xx_ex7_regfile_err_det(ex7_regfile_err_det),
    .xx_ex8_regfile_err_det(ex8_regfile_err_det),

    .xx_ex1_perr_sm_instr_v(ex1_perr_sm_instr_v),
    .xx_ex2_perr_sm_instr_v(ex2_perr_sm_instr_v),
    .xx_ex3_perr_sm_instr_v(ex3_perr_sm_instr_v),
    .xx_ex4_perr_sm_instr_v(ex4_perr_sm_instr_v),
    .xx_ex5_perr_sm_instr_v(ex5_perr_sm_instr_v),
    .xx_ex6_perr_sm_instr_v(ex6_perr_sm_instr_v),
    .xx_ex7_perr_sm_instr_v(ex7_perr_sm_instr_v),
    .xx_ex8_perr_sm_instr_v(ex8_perr_sm_instr_v),

    .xx_perr_sm_running(perr_sm_running),

    .xx_ex2_perr_force_c(f_dcd_ex2_perr_force_c),
    .xx_ex2_perr_fsel_ovrd(f_dcd_ex2_perr_fsel_ovrd),

    .xx_perr_tid_l2(perr_tid_l2),
    .xx_perr_sm_l2(perr_sm_l2),
    .xx_perr_addr_l2(perr_addr_l2),

    .ex3_sto_parity_err(fu_lq_ex3_sto_parity_err),
    .xx_rv_hold_all(f_dcd_rv_hold_all),

    .xx_ex0_regfile_ue(ex0_regfile_ue),
    .xx_ex0_regfile_ce(ex0_regfile_ce),

    .xx_pc_err_regfile_parity(fu_pc_err_regfile_parity),
    .xx_pc_err_regfile_ue(fu_pc_err_regfile_ue)


   );

   assign f_dcd_perr_sm_running = perr_sm_running;

   //----------------------------------------------------------------------
   // Microcode Hooks for Divide and Square Root

   //removed uc_hooks for a2o

   // Buffer outputs

   assign f_dcd_ex1_uc_ft_pos = 1'b0;
   assign f_dcd_ex1_uc_ft_neg = 1'b0;
   assign f_dcd_ex1_uc_fa_pos = 1'b0;
   assign f_dcd_ex1_uc_fc_pos = 1'b0;
   assign f_dcd_ex1_uc_fb_pos = 1'b0;
   assign f_dcd_ex1_uc_fc_hulp = 1'b0;
   assign f_dcd_ex1_uc_fc_0_5 = 1'b0;
   assign f_dcd_ex1_uc_fc_1_0 = 1'b0;
   assign f_dcd_ex1_uc_fc_1_minus = 1'b0;
   assign f_dcd_ex1_uc_fb_1_0 = 1'b0;
   assign f_dcd_ex1_uc_fb_0_75 = 1'b0;
   assign f_dcd_ex1_uc_fb_0_5 = 1'b0;
   assign f_dcd_ex1_uc_mid = 1'b0;
   assign f_dcd_ex1_uc_end = 1'b0;
   assign f_dcd_ex1_uc_special = 1'b0;

   assign f_dcd_ex3_uc_inc_lsb = 1'b0;
   assign f_dcd_ex3_uc_gs_v = 1'b0;
   assign f_dcd_ex3_uc_gs = 2'b00;
   assign f_dcd_ex3_uc_vxsnan = 1'b0;
   assign f_dcd_ex3_uc_zx = 1'b0;
   assign f_dcd_ex3_uc_vxidi = 1'b0;
   assign f_dcd_ex3_uc_vxzdz = 1'b0;
   assign f_dcd_ex3_uc_vxsqrt = 1'b0;

   //----------------------------------------------------------------------
   // Slow SPR Bus

   // Latches

   tri_rlmreg_p #(.INIT(0),  .WIDTH(15)) spr_ctl(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
       .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(spr_ctl_si[0:14]),
      .scout(spr_ctl_so[0:14]),
      //-------------------------------------------
      .din({   slowspr_in_val,
               slowspr_in_rw,
               slowspr_in_etid[0:1],
               slowspr_in_addr[0:9],
               slowspr_in_done}),
      //-------------------------------------------
      .dout({  slowspr_out_val,
               slowspr_out_rw,
               slowspr_out_etid[0:1],
               slowspr_out_addr[0:9],
               slowspr_out_done})
   );
   //-------------------------------------------

   tri_rlmreg_p #(.INIT(0),  .WIDTH(2 ** REGMODE)) spr_data(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(spr_data_si[64 - (2 ** REGMODE):63]),
      .scout(spr_data_so[64 - (2 ** REGMODE):63]),
      //-------------------------------------------
      .din(slowspr_in_data),
      //-------------------------------------------
      .dout(slowspr_out_data)
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(4)) axucr0_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(cfg_sl_force),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(cfg_sl_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(axucr0_lat_si[0:3]),
      .scout(axucr0_lat_so[0:3]),
      //-------------------------------------------
      .din(axucr0_din[60:63]),
      //-------------------------------------------
      .dout(  axucr0_q[60:63])
   );
   //-------------------------------------------


   tri_ser_rlmreg_p #(.WIDTH(32), .INIT(0)) a0esr_lat(
      .nclk(nclk),
      .act(a0esr_wr),
      .force_t(cfg_sl_force),
      .delay_lclkr(delay_lclkr[9]),
      .d_mode(tiup),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(cfg_sl_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(a0esr_lat_si[0:31]),
      .scout(a0esr_lat_so[0:31]),
      .din(a0esr_din),
      .dout(a0esr_q)
   );

   assign f_dcd_ex1_force_excp_dis = axucr0_q[61];
   assign f_dcd_ex1_nj_deni = axucr0_q[62] ;
   assign f_dcd_ex1_nj_deno = axucr0_q[63] ;
   assign f_dcd_axucr0_deno = axucr0_q[63] ;

   assign a0esr_event_mux_ctrls = a0esr_q[32:63];

   // slowSPR bus inputs
   //      slowspr_in_val              <= slowspr_val_in  and not ((cp_flush_q(0) and slowspr_etid_in(0)) or
   //                                                              (cp_flush_q(1) and slowspr_etid_in(1)));
   assign slowspr_in_val = slowspr_val_in & (~((cp_flush_q[0] & (~slowspr_etid_in[1])) | (cp_flush_q[1] & slowspr_etid_in[1])));		// etid is encoded tid, not one hot
   assign slowspr_in_rw = slowspr_rw_in;
   assign slowspr_in_etid = slowspr_etid_in;
   assign slowspr_in_addr = slowspr_addr_in;
   assign slowspr_in_data = slowspr_data_in;
   assign slowspr_in_done = slowspr_done_in;

   // for RTX
   assign slowspr_val_in_int  = slowspr_val_in;
   assign slowspr_data_in_int = slowspr_in_data;


   // AXUCR0 is SPR 976
   assign axucr0_dec = slowspr_out_addr[0:9] == 10'b1111010000;
   assign axucr0_rd = slowspr_out_val & axucr0_dec & slowspr_out_rw;
   assign axucr0_wr = slowspr_out_val & axucr0_dec & (~slowspr_out_rw);

   assign axucr0_din[60:63] = (slowspr_out_data[60:63] & {4{axucr0_wr}}) |
                              (axucr0_q[60:63] &        {4{(~axucr0_wr)}});

   assign axucr0_out[32:63] = {slowspr_out_data[32:59], axucr0_q[60:63]};

   // AOESR is SPR 913
   assign a0esr_dec = slowspr_out_addr[0:9] == 10'b1110010001;
   assign a0esr_rd = slowspr_out_val & a0esr_dec & slowspr_out_rw;
   assign a0esr_wr = slowspr_out_val & a0esr_dec & (~slowspr_out_rw);

   assign a0esr_din[32:63] = (slowspr_out_data[32:63] & {32{a0esr_wr}}) |
                             (a0esr_q[32:63]        & {32{(~a0esr_wr)}});

   // slowSPR bus outputs
   generate
      if (2 ** REGMODE > 32)
      begin : r64
         assign  slowspr_data_out_int[0:31] = slowspr_out_data[0:31];
	 assign  slowspr_data_out[0:31] = slowspr_data_out_int[0:31];

      end
   endgenerate

   assign  slowspr_data_out_int[32:63] = (axucr0_rd == 1'b1) ? axucr0_out[32:63] :
                                          (a0esr_rd == 1'b1) ? a0esr_q[32:63] :
                                          slowspr_out_data[32:63];
   assign  slowspr_data_out[32:63] = slowspr_data_out_int[32:63];

   assign slowspr_val_out = slowspr_out_val;
   assign slowspr_rw_out = slowspr_out_rw;
   assign slowspr_etid_out = slowspr_out_etid;
   assign slowspr_addr_out = slowspr_out_addr;
   assign slowspr_done_out_int = slowspr_out_done | axucr0_rd | axucr0_wr | a0esr_rd | a0esr_wr;
   assign slowspr_done_out = slowspr_done_out_int;

   //----------------------------------------------------------------------
   // RAM

   assign ex7_ram_sign = f_rnd_ex7_res_sign;
   assign ex7_ram_frac[0:52] = f_rnd_ex7_res_frac[0:52];
   assign ex7_ram_expo[3:13] = f_rnd_ex7_res_expo[3:13];

   generate
      if (THREADS == 1)
      begin : dcd_ramactive_thr1_1
         assign  ex7_ram_active[0] = pc_fu_ram_active[0];
         assign  ex7_ram_active[1] = tilo;
      end
   endgenerate
   generate
      if (THREADS == 2)
      begin : dcd_ramactive_thr2_1
         assign  ex7_ram_active[0] = pc_fu_ram_active[0];
         assign  ex7_ram_active[1] = pc_fu_ram_active[1];
      end
   endgenerate

   // Better be the only instr in the pipe for that thread.  Bugspray event fail if not
   //and not pc_fu_ram_thread -- (pc_fu_ram_thread(0 to 1) = ex7_instr_tid(0 to 1))
   assign ex7_ram_done = |(ex7_ram_active & (ex7_instr_v[0:1] & (~cp_flush_q[0:1]))) & (~ex7_is_ucode) & (~ex7_is_fixperr);		// Only report the end of the ucode seq


   tri_rlmreg_p #(.INIT(0),  .WIDTH(65)) ex8_ram_lat(
      .nclk(nclk),
      .act(ex7_instr_valid),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ram_data_si[0:64]),
      .scout(ram_data_so[0:64]),
      //-------------------------------------------
      .din({   ex7_ram_sign,
               ex7_ram_expo[3:13],
               ex7_ram_frac[0:52]}),
      //-------------------------------------------
      .dout({   ex8_ram_sign,
                ex8_ram_expo[3:13],
                ex8_ram_frac[0:52]})
   );
   //-------------------------------------------


   tri_rlmreg_p #(.INIT(0),  .WIDTH(1)) ex8_ramv_lat(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(ram_datav_si[0]),
      .scout(ram_datav_so[0]),
      //-------------------------------------------
      .din(ex7_ram_done),
      //-------------------------------------------
      .dout(ex8_ram_done)
   );

   assign ex8_ram_data[0] = ex8_ram_sign;
   assign ex8_ram_data[1:11] = ex8_ram_expo[3:13] & {11{ex8_ram_frac[0]}};
   assign ex8_ram_data[12:63] = ex8_ram_frac[1:52];

   assign fu_pc_ram_data_val = ex8_ram_done & ex8_instr_v;
   assign fu_pc_ram_data[0:63] = ex8_ram_data[0:63];

   //----------------------------------------------------------------------
   // Event Bus


   // Perf events
   assign evnt_axu_instr_cmt[0] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b00) & (~ex7_is_ucode) & (~ex7_is_fixperr);
   assign evnt_axu_instr_cmt[1] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b01) & (~ex7_is_ucode) & (~ex7_is_fixperr);

   assign evnt_axu_cr_cmt[0] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b00) & (ex7_cr_val | ex7_record | ex7_mcrfs);
   assign evnt_axu_cr_cmt[1] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b01) & (ex7_cr_val | ex7_record | ex7_mcrfs);

   assign evnt_axu_idle[0] = (ex7_instr_tid[0:1] == 2'b00) & (~(ex7_instr_valid | ex7_cr_val | ex7_record | ex7_mcrfs));		//includes ucode
   assign evnt_axu_idle[1] = (ex7_instr_tid[0:1] == 2'b01) & (~(ex7_instr_valid | ex7_cr_val | ex7_record | ex7_mcrfs));		//includes ucode

   assign evnt_denrm_flush[0] = (ex5_instr_tid[0:1] == 2'b00) & ex5_b_den_flush;
   assign evnt_denrm_flush[1] = (ex5_instr_tid[0:1] == 2'b01) & ex5_b_den_flush;

   assign evnt_uc_instr_cmt[0] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b00) & ex7_is_ucode;
   assign evnt_uc_instr_cmt[1] = ex7_instr_valid & (ex7_instr_tid[0:1] == 2'b01) & ex7_is_ucode;

   assign evnt_fpu_fx[0:1] = {f_scr_ex8_fx_thread0[0], f_scr_ex8_fx_thread1[0]};
   assign evnt_fpu_fex[0:1] = {f_scr_ex8_fx_thread0[1], f_scr_ex8_fx_thread1[1]};

   assign evnt_fpu_cpl_fx[0:1] = {f_scr_cpl_fx_thread0[0], f_scr_cpl_fx_thread1[0]};
   assign evnt_fpu_cpl_fex[0:1] = {f_scr_cpl_fx_thread0[1], f_scr_cpl_fx_thread1[1]};

   assign evnt_div_sqrt_ip[0] = (ex5_instr_tid[0:1] == 2'b00) & f_dsq_debug[10]; // todo: need to cover later cycles?  this is only up to ex5
   assign evnt_div_sqrt_ip[1] = (ex5_instr_tid[0:1] == 2'b01) & f_dsq_debug[10];

   assign event_en_d[0:1] = (  msr_pr_q  &               {2{event_count_mode_q[0]}}) |  //-- User
                            ((~msr_pr_q) &   msr_gs_q  & {2{event_count_mode_q[1]}}) |  //-- Guest Supervisor
                            ((~msr_pr_q) & (~msr_gs_q) & {2{event_count_mode_q[2]}});   //-- Hypervisor
   assign event_en_d[2:3] = {2{tidn}};


   assign t0_events[0:14] = {evnt_axu_instr_cmt[0], evnt_axu_cr_cmt[0], evnt_axu_idle[0], evnt_div_sqrt_ip[0], evnt_denrm_flush[0], evnt_uc_instr_cmt[0], evnt_fpu_fx[0], evnt_fpu_fex[0],
                             evnt_fpu_cpl_fx[0], evnt_fpu_cpl_fex[0], tidn, tidn, tidn, tidn, tidn} & {16{event_en_q[0]}};

   assign t1_events[0:14] = {evnt_axu_instr_cmt[1], evnt_axu_cr_cmt[1], evnt_axu_idle[1], evnt_div_sqrt_ip[1], evnt_denrm_flush[1], evnt_uc_instr_cmt[1], evnt_fpu_fx[1], evnt_fpu_fex[1],
                             evnt_fpu_cpl_fx[1], evnt_fpu_cpl_fex[1], tidn, tidn, tidn, tidn, tidn} & {16{event_en_q[1]}};

   // perf event mux
   assign unit_bus_in_t0 = t0_events[0:14] ;
   assign unit_bus_in_t1 = t1_events[0:14] ;


   tri_event_mux1t #(.EVENTS_IN(16), .EVENTS_OUT(4))
   event_mux_t0(
	     .vd(vdd),
	     .gd(gnd),
	     .unit_events_in(unit_bus_in_t0),
	     .select_bits(a0esr_event_mux_ctrls[0:15]),
	     .event_bus_in(event_bus_in[0:3]),
	     .event_bus_out(event_bus_d[0:3])
	     );

`ifndef THREADS1

   tri_event_mux1t #(.EVENTS_IN(16), .EVENTS_OUT(4))
   event_mux_t1(
	     .vd(vdd),
	     .gd(gnd),
	     .unit_events_in(unit_bus_in_t1),
	     .select_bits(a0esr_event_mux_ctrls[16:31]),
	     .event_bus_in(event_bus_in[4:7]),
	     .event_bus_out(event_bus_d[4:7])
	     );

   assign event_bus_out[0:7] = event_bus_q[0:7];


 `else

   assign event_bus_d[4:7] = {4{tidn}};
   assign event_bus_out[0:3] = event_bus_q[0:3];

 `endif



   tri_rlmreg_p #(.INIT(0),  .WIDTH(8)) event_bus_out_lat(
      .nclk(nclk),
      .act(event_act),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(event_bus_out_si),
      .scout(event_bus_out_so),
      //-------------------------------------------
      .din({event_bus_d   }),
      //-------------------------------------------
      .dout({event_bus_q  })
   );




   tri_rlmreg_p #(.INIT(0),  .WIDTH(35)) perf_data(
      .nclk(nclk),
      .act(event_act),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(perf_data_si),
      .scout(perf_data_so),
      //-------------------------------------------
      .din({ spare_unused[13:20],
             event_en_d[0:3],
             spare_unused[4],
             pc_fu_event_count_mode[0:2],
             msr_pr_d[0:1],
             msr_gs_d[0:1],
             pc_fu_instr_trace_mode,
             pc_fu_instr_trace_tid[0:1],
             rf0_instr_tid_1hot[0:3],
             rf1_instr_iss[0:3],
             ex1_instr_iss[0:3]  }),
      //-------------------------------------------
      .dout({spare_unused[13:20],
             event_en_q[0:3],
             spare_unused[4],
             event_count_mode_q[0:2],
             msr_pr_q[0:1],
             msr_gs_q[0:1],
             instr_trace_mode_q,  // todo
             instr_trace_tid_q[0:1], // todo
             rf1_instr_iss[0:3],
             ex1_instr_iss[0:3],
             ex2_instr_iss[0:3]   })
   );


   //----------------------------------------------------------------------
   // Debug Bus

   tri_rlmreg_p #(.INIT(0),  .WIDTH(32)) dbg_group3_lat(
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(dbg_group3_lat_si),
      .scout(dbg_group3_lat_so),
      //-------------------------------------------
      .din({ dbg_group3_din[00:31]  }),
      //-------------------------------------------
      .dout({ dbg_group3_q[00:31] })
   );




   assign divsqrt_debug[0:63] = f_dsq_debug;


   // FU is the first unit in the DBG chain
   //assign trace_data_in[0:87] = debug_data_in[0:87];
   assign trace_data_in[0:31] = debug_bus_in[0:31];
   //assign trigger_data_in[0:11] = trace_triggers_in[0:11];

   // Debug Events
   // todo: width is only 32 bits now, might want to reorder this stuff

   assign dbg_group0[0:63] = ex8_ram_data[0:63];

   assign dbg_group1[0:63] = divsqrt_debug[0:63];

   assign dbg_group2[0:31] = ex1_instr[0:31] & {32{ (instr_trace_mode_q & (instr_trace_tid_q != ex1_tid)) }}; // gate instr if not tid;

   assign dbg_group2[32:35] = (f_scr_ex8_fx_thread0[0:3] & (~{4{instr_trace_mode_q}}));
   assign dbg_group2[36:39] = (f_scr_ex8_fx_thread1[0:3] & (~{4{instr_trace_mode_q}})) | (4'b1010 & (~{4{instr_trace_mode_q}})); //a
   assign dbg_group2[40:43] = (f_scr_cpl_fx_thread0[0:3] & (~{4{instr_trace_mode_q}})) | (4'b1011 & (~{4{instr_trace_mode_q}})); //b
   assign dbg_group2[44:47] = (f_scr_cpl_fx_thread1[0:3] & (~{4{instr_trace_mode_q}})) | (4'b1100 & (~{4{instr_trace_mode_q}})); //c
   assign dbg_group2[48:51] = (ex5_eff_addr[59:62] & (~{4{instr_trace_mode_q}})) | (4'b1101 & (~{4{instr_trace_mode_q}}));       //d

   assign dbg_group2[52:55] = ({ex5_eff_addr[63], perr_sm_l2[0:2]} & (~{4{instr_trace_mode_q}})) | (4'b1110 & (~{4{instr_trace_mode_q}}));//e
   assign dbg_group2[56:61] = perr_addr_l2[0:5] & (~{6{instr_trace_mode_q}});
   assign dbg_group2[62:63] = perr_tid_l2[0:1] & (~{2{instr_trace_mode_q}});

   assign dbg_group3_din[00] = ex0_regfile_ce;
   assign dbg_group3_din[01] = ex0_regfile_ue;
   assign dbg_group3_din[02] = ex1_bypsel_a_res0;
   assign dbg_group3_din[03] = ex1_bypsel_c_res0;
   assign dbg_group3_din[04] = ex1_bypsel_b_res0;
   assign dbg_group3_din[05] = ex1_bypsel_a_res1;
   assign dbg_group3_din[06] = ex1_bypsel_c_res1;
   assign dbg_group3_din[07] = ex1_bypsel_b_res1;
   assign dbg_group3_din[08] = ex1_bypsel_a_load0;
   assign dbg_group3_din[09] = ex1_bypsel_c_load0;
   assign dbg_group3_din[10] = ex1_bypsel_b_load0;
   assign dbg_group3_din[11] = ex1_bypsel_a_load1;
   assign dbg_group3_din[12] = ex1_bypsel_c_load1;
   assign dbg_group3_din[13] = ex1_bypsel_b_load1;
   assign dbg_group3_din[14] = ex1_frs_byp;
   assign dbg_group3_din[15] = ex1_v;
   assign dbg_group3_din[16] = ex1_bypsel_a_res2;
   assign dbg_group3_din[17] = ex1_bypsel_c_res2;
   assign dbg_group3_din[18] = ex1_bypsel_b_res2;
   assign dbg_group3_din[19] = ex1_bypsel_a_load2;
   assign dbg_group3_din[20] = ex1_bypsel_c_load2;
   assign dbg_group3_din[21] = ex1_bypsel_b_load2;
   assign dbg_group3_din[22] = ex1_bypsel_a_load3;
   assign dbg_group3_din[23] = ex1_bypsel_c_load3;
   assign dbg_group3_din[24] = ex1_bypsel_b_load3;
   assign dbg_group3_din[25] = ex1_bypsel_a_reload0;
   assign dbg_group3_din[26] = ex1_bypsel_c_reload0;
   assign dbg_group3_din[27] = ex1_bypsel_b_reload0;
   assign dbg_group3_din[28] = ex1_bypsel_a_reload1;
   assign dbg_group3_din[29] = ex1_bypsel_c_reload1;
   assign dbg_group3_din[30] = ex1_bypsel_b_reload1;
   assign dbg_group3_din[31] = tidn;

   assign dbg_group3[00:31]  = dbg_group3_q[00:31];

   assign dbg_group3[32:63] = {t0_events[0:7], t1_events[0:7], {16{tidn}} };

   assign trg_group0[0:1] = evnt_fpu_fx[0:1];
   assign trg_group0[2:3] = evnt_fpu_cpl_fx[0:1];

   assign trg_group0[4:5] = evnt_fpu_fex[0:1];
   assign trg_group0[6:7] = evnt_fpu_cpl_fex[0:1];
   assign trg_group0[8] = ex7_instr_valid;
   assign trg_group0[9] = ex7_is_ucode;
   assign trg_group0[10:11] = ex7_instr_tid[0:1];

   assign trg_group1[0:2] = perr_sm_l2[0:2];
   assign trg_group1[3] = ex0_regfile_ce;
   assign trg_group1[4] = ex0_regfile_ue;
   assign trg_group1[5] = ex7_instr_valid;
   assign trg_group1[6:7] = ex7_instr_tid[0:1];
   assign trg_group1[8] = ex4_instr_match;
   assign trg_group1[9] = ex7_record;
   assign trg_group1[10] = ex7_mcrfs;
   assign trg_group1[11] = ex5_b_den_flush;

   assign trg_group2[0:11] = divsqrt_debug[0:11];
   assign trg_group3[0:11] = divsqrt_debug[12:23];


   assign debug_mux_ctrls_d = pc_fu_debug_mux_ctrls;  // ARDSR[32:47]

   //sel2   unused  rot     sel     tsel   trot   trigssel
   assign debug_mux_ctrls_muxed[0:10] =  debug_mux_ctrls_q[0:10];

   //
   tri_debug_mux4 #(.DBG_WIDTH(32)) dbgmux(
      //.vd(vdd),
      //.gd(gnd),
      .select_bits(debug_mux_ctrls_muxed),
      .dbg_group0(dbg_group0[0:31]),
      .dbg_group1(dbg_group1[0:31]),
      .dbg_group2(dbg_group2[0:31]),
      .dbg_group3(dbg_group3[0:31]),
      .trace_data_in(trace_data_in[0:31]),
      .trace_data_out(trace_data_out[0:31]),
      .coretrace_ctrls_in(coretrace_ctrls_in),
      .coretrace_ctrls_out(coretrace_ctrls_out_d[0:3])


   );

   assign debug_data_d[0:31] = trace_data_out[0:31];

   assign coretrace_ctrls_out[0:3] = coretrace_ctrls_out_q;


   assign ex5_b_den_flush_din = ex4_b_den_flush & |({ex4_instr_v[0:3], ex4_fdivsqrt_start}) & (~ex4_is_ucode);		//don't flush on ucode preIssue

   // Trace Bus latches, using pc_fu_trace_bus_enable for act

   tri_rlmreg_p #(.INIT(0),  .WIDTH(68)) dbg0_data(
      .nclk(nclk),
      .act(dbg0_act),
      .force_t(func_slp_sl_force),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(dbg0_data_si[0:67]),
      .scout(dbg0_data_so[0:67]),
      //-------------------------------------------
      .din({   debug_data_d[0:31],
               spare_unused[0:3],
               spare_unused[31:42],//debug_trig_d[0:11],
               coretrace_ctrls_out_d[0:3],
               debug_mux_ctrls_d[0:10],
               spare_unused[43:47]}),
      //-------------------------------------------
      .dout({   debug_data_q[0:31],
                spare_unused[0:3],
                spare_unused[31:42],//debug_trig_q[0:11],
                coretrace_ctrls_out_q[0:3],
                debug_mux_ctrls_q[0:10],
                spare_unused[43:47]})
   );
   //-------------------------------------------
   //Another set, closer to the I/O on the bottom

   tri_rlmreg_p #(.INIT(0),  .WIDTH(5)) dbg1_data(
      .nclk(nclk),
      .act(tihi),
      .force_t(force_t),
      .d_mode(tiup),
      .delay_lclkr(delay_lclkr[9]),
      .mpw1_b(mpw1_b[9]),
      .mpw2_b(mpw2_b[1]),
      .thold_b(thold_0_b),
      .sg(sg_0),
      .vd(vdd),
      .gd(gnd),
      .scin(dbg1_data_si[0:4]),
      .scout(dbg1_data_so[0:4]),
      //-------------------------------------------
      .din(xu_fu_ex4_eff_addr[59:63]),
      //-------------------------------------------
      .dout(ex5_eff_addr[59:63])
   );
   //-------------------------------------------

   // To MMU, i'm the first in the chain
   //assign debug_data_out[0:87] = debug_data_q[0:87];
   assign debug_bus_out[0:31] = debug_data_q[0:31];

   assign axu0_iu_perf_events      = {4{1'b0}};
   assign axu1_iu_perf_events      = {4{1'b0}};


   //----------------------------------------------------------------------
   // unused
   //todo
   assign spare_unused[5:8] = {4{tidn}};
   assign spare_unused[9:11] = {3{tidn}};

   //----------------------------------------------------------------------
   // Scan Connections

   assign ex1_iu_si[0:14] = {ex1_iu_so[1:14], f_dcd_si};
   assign act_lat_si[0:7] = {act_lat_so[1:7], ex1_iu_so[0]};
   assign cp_flush_reg0_si = act_lat_so[0];
   assign cp_flush_reg1_si = cp_flush_reg0_so;
   assign ex1_frt_si[0:29] = {ex1_frt_so[1:29], cp_flush_reg1_so};
   assign ex1_instl_si[0:31] = {ex1_instl_so[1:31], ex1_frt_so[0]};
   assign ex1_itag_si[0:13] = {ex1_itag_so[1:13],ex1_instl_so[0]};
   assign ex2_itag_si[0:15] = {ex2_itag_so[1:15],ex1_itag_so[0]};
   assign ex3_itag_si[0:15] = {ex3_itag_so[1:15],ex2_itag_so[0]};
   assign ex4_itag_si[0:15] = {ex4_itag_so[1:15],ex3_itag_so[0]};
   assign ex5_itag_si[0:16] = {ex5_itag_so[1:16],ex4_itag_so[0]};
   assign ex6_itag_si[0:16] = {ex6_itag_so[1:16],ex5_itag_so[0]};
   assign ex7_itag_si[0:17] = {ex7_itag_so[1:17],ex6_itag_so[0]};
   assign ex8_itag_si[0:7]  = {ex8_itag_so[1:7],ex7_itag_so[0]};

   assign ex1_crbf_si[0:4] = {ex1_crbf_so[1:4],ex8_itag_so[0]};
   assign ex2_crbf_si[0:4] = {ex2_crbf_so[1:4],ex1_crbf_so[0]};
   assign ex3_crbf_si[0:4] = {ex3_crbf_so[1:4],ex2_crbf_so[0]};
   assign ex4_crbf_si[0:4] = {ex4_crbf_so[1:4],ex3_crbf_so[0]};
   assign ex5_crbf_si[0:4] = {ex5_crbf_so[1:4],ex4_crbf_so[0]};
   assign ex6_crbf_si[0:8] = {ex6_crbf_so[1:8],ex5_crbf_so[0]};
   assign ex7_crbf_si[0:8] = {ex7_crbf_so[1:8],ex6_crbf_so[0]};


   assign ex2_ctl_si[0:20] = {ex2_ctl_so[1:20], ex7_crbf_so[0]};
   assign ex2_frt_si[0:5] = {ex2_frt_so[1:5], ex2_ctl_so[0]};

   assign ex0_iu_si[0:7] = {ex0_iu_so[1:7], ex2_frt_so[0]};
   assign ex0_frt_si[0:23] = {ex0_frt_so[1:23], ex0_iu_so[0]};

   assign ex3_ctl_si[0:23] = {ex3_ctl_so[1:23], ex0_frt_so[0]};
   assign ex3_ctlng_si[0:6] = {ex3_ctlng_so[1:6], ex3_ctl_so[0]};

   assign ex3_stdv_si = ex3_ctlng_so[0];
   assign ex4_ctl_si[0:29] = {ex4_ctl_so[1:29], ex3_stdv_so};
   assign ex5_ctl_si[0:21] = {ex5_ctl_so[1:21], ex4_ctl_so[0]};
   assign ex6_ctl_si[0:20] = {ex6_ctl_so[1:20], ex5_ctl_so[0]};
   assign ex7_ctl_si[0:22] = {ex7_ctl_so[1:22], ex6_ctl_so[0]};
   assign ex8_ctl_si[0:31] = {ex8_ctl_so[1:31], ex7_ctl_so[0]};
   assign ex9_ctl_si[0:13] = {ex9_ctl_so[1:13], ex8_ctl_so[0]};

   assign ex7_laddr_si[0:17] = {ex7_laddr_so[1:17],ex9_ctl_so[0]};
   assign ex8_laddr_si[0:17] = {ex8_laddr_so[1:17],ex7_laddr_so[0]};
   assign ex9_laddr_si[0:8] = {ex9_laddr_so[1:8],ex8_laddr_so[0]};

   assign axu_ex_si[0:3] = {axu_ex_so[1:3],ex9_laddr_so[0]};


   assign perr_si = axu_ex_so[0];

   assign spr_ctl_si[0:14] = {spr_ctl_so[1:14], perr_so};
   assign spr_data_si[64 - (2 ** REGMODE):63] = {spr_data_so[65 - (2 ** REGMODE):63], spr_ctl_so[0]};
   assign ram_data_si[0:64] = {ram_data_so[1:64], spr_data_so[64 - (2 ** REGMODE)]};
   assign ram_datav_si[0] = ram_data_so[0];
   assign perf_data_si[0:34] = {perf_data_so[1:34], ram_datav_so[0]};
   assign event_bus_out_si[0:7] = {event_bus_out_so[1:7], perf_data_so[0]};
   assign dbg0_data_si[0:67] = {dbg0_data_so[1:67], event_bus_out_so[0]};
   assign dbg1_data_si[0:4] = {dbg1_data_so[1:4], dbg0_data_so[0]};

   assign dbg_group3_lat_si[00:31] = {dbg_group3_lat_so[1:31], dbg1_data_so[0]};

   assign f_dcd_so = dbg_group3_lat_so[0];

   //dcfg ring
   assign axucr0_lat_si[0:3] = {axucr0_lat_so[1:3], dcfg_scan_in};
   assign a0esr_lat_si[0:31] = {a0esr_lat_so[1:31], axucr0_lat_so[0]};
   assign dcfg_scan_out = a0esr_lat_so[0];

endmodule
