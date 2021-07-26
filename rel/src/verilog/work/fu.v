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
//*  TITLE: fu
//*
//*  NAME:  fu.vhdl
//*
//*  DESC:   OO Top level Double Precision Floating Point Unit
//*
//*****************************************************************************

   `include "tri_a2o.vh"


module fu(
   abst_scan_in,
   an_ac_lbist_en_dc,
   bcfg_scan_in,
   ccfg_scan_in,
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
   cp_flush,
   cp_t0_next_itag,
   cp_t1_next_itag,

   dcfg_scan_in,
   func_scan_in,
   gptr_scan_in,
   iu_xx_t0_zap_itag,
   iu_xx_t1_zap_itag,

   debug_bus_in,
   coretrace_ctrls_in,
   debug_bus_out,
   coretrace_ctrls_out,
   event_bus_in,
   event_bus_out,
   lq_fu_ex4_eff_addr,
   lq_fu_ex5_load_data,
   lq_fu_ex5_load_le,
   lq_fu_ex5_load_tag,
   lq_fu_ex5_load_val,
   lq_fu_ex5_abort,
   fu_lq_ex3_abort,
   axu0_rv_ex2_s1_abort,
   axu0_rv_ex2_s2_abort,
   axu0_rv_ex2_s3_abort,
   lq_gpr_rel_we,
   lq_gpr_rel_le,
   lq_gpr_rel_wa,
   lq_gpr_rel_wd,
   lq_rv_itag0,
   lq_rv_itag0_spec,
   lq_rv_itag0_vld,
   lq_rv_itag1_restart,
   nclk,
   pc_fu_abist_di_0,
   pc_fu_abist_di_1,
   pc_fu_abist_ena_dc,
   pc_fu_abist_grf_renb_0,
   pc_fu_abist_grf_renb_1,
   pc_fu_abist_grf_wenb_0,
   pc_fu_abist_grf_wenb_1,
   pc_fu_abist_raddr_0,
   pc_fu_abist_raddr_1,
   pc_fu_abist_raw_dc_b,
   pc_fu_abist_waddr_0,
   pc_fu_abist_waddr_1,
   pc_fu_abist_wl144_comp_ena,
   pc_fu_abst_sl_thold_3,
   pc_fu_abst_slp_sl_thold_3,
   pc_fu_ary_nsl_thold_3,
   pc_fu_ary_slp_nsl_thold_3,
   pc_fu_ccflush_dc,
   pc_fu_cfg_sl_thold_3,
   pc_fu_cfg_slp_sl_thold_3,
   pc_fu_debug_mux_ctrls,
   pc_fu_event_count_mode,
   pc_fu_fce_3,
   pc_fu_func_nsl_thold_3,
   pc_fu_func_sl_thold_3,
   pc_fu_func_slp_nsl_thold_3,
   pc_fu_func_slp_sl_thold_3,
   pc_fu_gptr_sl_thold_3,
   pc_fu_inj_regfile_parity,
   pc_fu_ram_active,
   pc_fu_repr_sl_thold_3,
   pc_fu_sg_3,
   pc_fu_time_sl_thold_3,
   pc_fu_trace_bus_enable,
   pc_fu_event_bus_enable,
   pc_fu_instr_trace_mode,
   pc_fu_instr_trace_tid,
   repr_scan_in,

   rv_axu0_ex0_instr,
   rv_axu0_ex0_itag,
   rv_axu0_s1_p,
   rv_axu0_s1_t,
   rv_axu0_s1_v,
   rv_axu0_s2_p,
   rv_axu0_s2_t,
   rv_axu0_s2_v,
   rv_axu0_s3_p,
   rv_axu0_s3_t,
   rv_axu0_s3_v,
   rv_axu0_ex0_t1_p,
   rv_axu0_ex0_t1_v,
   rv_axu0_ex0_t2_p,
   rv_axu0_ex0_t3_p,
   rv_axu0_ex0_ucode,
   rv_axu0_vld,
   slowspr_addr_in,
   slowspr_data_in,
   slowspr_done_in,
   slowspr_etid_in,
   slowspr_rw_in,
   slowspr_val_in,
   tc_ac_scan_diag_dc,
   tc_ac_scan_dis_dc_b,
   time_scan_in,

   xu_fu_msr_fe0,
   xu_fu_msr_fe1,
   xu_fu_msr_fp,
   xu_fu_msr_gs,
   xu_fu_msr_pr,

//   gnd,
//   vcs,
//   vdd,
   abst_scan_out,
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
   axu0_rv_hold_all,

   axu1_iu_exception,
   axu1_iu_exception_val,
   axu1_iu_execute_vld,
   axu1_iu_flush2ucode,
   axu1_iu_flush2ucode_type,
   axu1_iu_itag,
   axu1_iu_n_flush,
   axu1_iu_np1_flush,
   axu1_rv_itag,
   axu1_rv_itag_vld,
   axu1_rv_itag_abort,
   axu1_iu_perf_events,
   axu1_rv_hold_all,

   bcfg_scan_out,
   ccfg_scan_out,
   dcfg_scan_out,
   fu_lq_ex2_store_data_val,
   fu_lq_ex2_store_itag,
   fu_lq_ex3_store_data,
   fu_lq_ex3_sto_parity_err,
   fu_pc_err_regfile_parity,
   fu_pc_err_regfile_ue,

   fu_pc_ram_data,
   fu_pc_ram_data_val,

   func_scan_out,
   gptr_scan_out,
   repr_scan_out,
   slowspr_addr_out,
   slowspr_data_out,
   slowspr_done_out,
   slowspr_etid_out,
   slowspr_rw_out,
   slowspr_val_out,
   time_scan_out
);
//   parameter                                expand_type = 2;		// 0 - ibm tech, 1 - other, 2 - MPG);
//   parameter                                EFF_IFAR = 20;
//   parameter                                EFF_IFAR_WIDTH = 20;
//   parameter                                ITAG_SIZE_ENC = 7;
//   parameter                                THREADS = 2;
//   parameter                                FPR_POOL_ENC = 6;
//   parameter                                FPR_POOL = 64;
//   parameter                                THREAD_POOL_ENC = 1;
//   parameter                                CR_POOL_ENC = 5;
//   parameter                                AXU_SPARE_ENC = 3;
//   parameter                                UCODE_ENTRIES_ENC = 3;
//   parameter                                REGMODE = 6;		//32 or 64 bit mode
   //INPUTS
   input                                    abst_scan_in;
   input                                    an_ac_lbist_en_dc;
   input                                    bcfg_scan_in;
   input                                    ccfg_scan_in;

   // Pass Thru Debug Trace Bus
  // input [0:11]                             trace_triggers_in;
   input [0:31]                             debug_bus_in;
   input [0:3]                              coretrace_ctrls_in;

  // output [0:11]                            trace_triggers_out;
   output [0:31]                            debug_bus_out;
   output [0:3]                             coretrace_ctrls_out;

   input  [0:4*`THREADS-1] 		    event_bus_in;
   output [0:4*`THREADS-1] 		    event_bus_out;


   input [0:`THREADS-1] cp_axu_i0_t1_v;
   input [0:2] 	       cp_axu_i0_t0_t1_t;
   input [0:2] 	       cp_axu_i0_t1_t1_t;
   input [0:5] 	       cp_axu_i0_t0_t1_p;
   input [0:5] 	       cp_axu_i0_t1_t1_p;

   input [0:`THREADS-1] cp_axu_i1_t1_v;
   input [0:2] 	       cp_axu_i1_t0_t1_t;
   input [0:2] 	       cp_axu_i1_t1_t1_t;
   input [0:5] 	       cp_axu_i1_t0_t1_p;
   input [0:5] 	       cp_axu_i1_t1_t1_p;


   input [0:`THREADS-1]                      cp_flush;
   input [0:6]                      cp_t0_next_itag;		//: in std_ulogic_vector(0 to 6);
   input [0:6]                      cp_t1_next_itag;		//: in std_ulogic_vector(0 to 6);

   input                                    dcfg_scan_in;
   input [0:3]                              func_scan_in;
   input                                    gptr_scan_in;
   input [0:6]                      iu_xx_t0_zap_itag;
   input [0:6]                      iu_xx_t1_zap_itag;

   input [59:63]                            lq_fu_ex4_eff_addr;
   input [192:255]                          lq_fu_ex5_load_data;
   input                                    lq_fu_ex5_load_le;
   input [0:7+`THREADS]                      lq_fu_ex5_load_tag;		// 0 to 9 for 2 threads
   input                                    lq_fu_ex5_load_val;

   input                                    lq_fu_ex5_abort;
   output                                   fu_lq_ex3_abort;
   output                                   axu0_rv_ex2_s1_abort;
   output                                   axu0_rv_ex2_s2_abort;
   output                                   axu0_rv_ex2_s3_abort;

   input                                    lq_gpr_rel_we;
   input                                    lq_gpr_rel_le;
   input [0:7+`THREADS]                      lq_gpr_rel_wa;
   input [64:127]                           lq_gpr_rel_wd;		//      :out std_ulogic_vector((128-STQ_DATA_SIZE) to 127);

   input [0:`ITAG_SIZE_ENC-1]                lq_rv_itag0;
   input                                    lq_rv_itag0_spec;
   input                                    lq_rv_itag0_vld;
   input                                    lq_rv_itag1_restart;
   (* PIN_DATA="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input [0:`NCLK_WIDTH-1]                                   nclk;
   input [0:3]                              pc_fu_abist_di_0;
   input [0:3]                              pc_fu_abist_di_1;
   input                                    pc_fu_abist_ena_dc;
   input                                    pc_fu_abist_grf_renb_0;
   input                                    pc_fu_abist_grf_renb_1;
   input                                    pc_fu_abist_grf_wenb_0;
   input                                    pc_fu_abist_grf_wenb_1;
   input [0:9]                              pc_fu_abist_raddr_0;
   input [0:9]                              pc_fu_abist_raddr_1;
   input                                    pc_fu_abist_raw_dc_b;
   input [0:9]                              pc_fu_abist_waddr_0;
   input [0:9]                              pc_fu_abist_waddr_1;
   input                                    pc_fu_abist_wl144_comp_ena;
   input                                    pc_fu_abst_sl_thold_3;
   input                                    pc_fu_abst_slp_sl_thold_3;
   input                                    pc_fu_ary_nsl_thold_3;
   input                                    pc_fu_ary_slp_nsl_thold_3;
   input                                    pc_fu_ccflush_dc;
   input                                    pc_fu_cfg_sl_thold_3;
   input                                    pc_fu_cfg_slp_sl_thold_3;
   input [0:10]                             pc_fu_debug_mux_ctrls;
   input [0:2]                              pc_fu_event_count_mode;
   input                                    pc_fu_fce_3;
   input                                    pc_fu_func_nsl_thold_3;
   input [0:1]                              pc_fu_func_sl_thold_3;
   input                                    pc_fu_func_slp_nsl_thold_3;
   input [0:1]                              pc_fu_func_slp_sl_thold_3;
   input                                    pc_fu_gptr_sl_thold_3;
   input [0:`THREADS-1]                     pc_fu_inj_regfile_parity;
   input [0:`THREADS-1]                      pc_fu_ram_active;
   input                                    pc_fu_repr_sl_thold_3;
   input [0:1]                              pc_fu_sg_3;
   input                                    pc_fu_time_sl_thold_3;
   input                                    pc_fu_trace_bus_enable;
   input                                    pc_fu_event_bus_enable;
   input                                    pc_fu_instr_trace_mode;
   input [0:1]                              pc_fu_instr_trace_tid;

   input                                    repr_scan_in;

   input [0:31]                             rv_axu0_ex0_instr;
   input [0:`ITAG_SIZE_ENC-1] 		    rv_axu0_ex0_itag;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_s1_p;
   input [0:2]                              rv_axu0_s1_t;
   input                                    rv_axu0_s1_v;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_s2_p;
   input [0:2]                              rv_axu0_s2_t;
   input                                    rv_axu0_s2_v;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_s3_p;
   input [0:2]                              rv_axu0_s3_t;
   input                                    rv_axu0_s3_v;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_ex0_t1_p;
   input                                    rv_axu0_ex0_t1_v;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_ex0_t2_p;
   input [0:`FPR_POOL_ENC-1]                 rv_axu0_ex0_t3_p;
   input [0:2]                              rv_axu0_ex0_ucode;
   input [0:`THREADS-1]                      rv_axu0_vld;
   input [0:9]                              slowspr_addr_in;
   input [64-(2**`REGMODE):63]               slowspr_data_in;
   input                                    slowspr_done_in;
   input [0:1]                              slowspr_etid_in;
   input                                    slowspr_rw_in;
   input                                    slowspr_val_in;
   input                                    tc_ac_scan_diag_dc;
   input                                    tc_ac_scan_dis_dc_b;
   input                                    time_scan_in;

   input [0:`THREADS-1]                      xu_fu_msr_fe0;
   input [0:`THREADS-1]                      xu_fu_msr_fe1;
   input [0:`THREADS-1]                      xu_fu_msr_fp;
   input [0:`THREADS-1]                      xu_fu_msr_gs;
   input [0:`THREADS-1]                      xu_fu_msr_pr;


   //OUTPUTS
   output                                   abst_scan_out;
   output [0:`CR_POOL_ENC+`THREAD_POOL_ENC-1] axu0_cr_w4a;		//: out std_ulogic_vector(0 to 4);
   output [0:3]                             axu0_cr_w4d;
   output                                   axu0_cr_w4e;
   output [0:`THREADS-1]                    axu0_iu_async_fex;
   output [0:3]                             axu0_iu_perf_events;

   output [0:3]                             axu0_iu_exception;
   output                                   axu0_iu_exception_val;
   output [0:`THREADS-1]                     axu0_iu_execute_vld;
   output                                   axu0_iu_flush2ucode;
   output                                   axu0_iu_flush2ucode_type;
   output [0:`ITAG_SIZE_ENC-1]               axu0_iu_itag;
   output                                   axu0_iu_n_flush;
   output                                   axu0_iu_n_np1_flush;
   output                                   axu0_iu_np1_flush;
   output [0:`ITAG_SIZE_ENC-1]               axu0_rv_itag;
   output [0:`THREADS-1]                     axu0_rv_itag_vld;
   output 				     axu0_rv_itag_abort;
   output                                   axu0_rv_ord_complete;
   output                                   axu0_rv_hold_all;

   output [0:3]                             axu1_iu_exception;
   output                                   axu1_iu_exception_val;
   output [0:`THREADS-1]                     axu1_iu_execute_vld;
   output                                   axu1_iu_flush2ucode;
   output                                   axu1_iu_flush2ucode_type;
   output [0:`ITAG_SIZE_ENC-1]               axu1_iu_itag;
   output                                   axu1_iu_n_flush;
   output                                   axu1_iu_np1_flush;
   output [0:`ITAG_SIZE_ENC-1]               axu1_rv_itag;
   output [0:`THREADS-1]                     axu1_rv_itag_vld;
   output 				     axu1_rv_itag_abort;
   output [0:3]                             axu1_iu_perf_events;
   output                                   axu1_rv_hold_all;

   output                                   bcfg_scan_out;
   output                                   ccfg_scan_out;
   output                                   dcfg_scan_out;
   output [0:`THREADS-1]                     fu_lq_ex2_store_data_val;
   output [0:`ITAG_SIZE_ENC-1]               fu_lq_ex2_store_itag;
   output [0:63]                            fu_lq_ex3_store_data;
   output                                   fu_lq_ex3_sto_parity_err;

   output [0:`THREADS-1]                    fu_pc_err_regfile_parity;
   output [0:`THREADS-1]                    fu_pc_err_regfile_ue;

   output [0:63]                            fu_pc_ram_data;
   output                                   fu_pc_ram_data_val;

   output [0:3]                             func_scan_out;
   output                                   gptr_scan_out;
   output                                   repr_scan_out;
   output [0:9]                             slowspr_addr_out;
   output [64-(2**`REGMODE):63]              slowspr_data_out;
   output                                   slowspr_done_out;
   output [0:1]                             slowspr_etid_out;
   output                                   slowspr_rw_out;
   output                                   slowspr_val_out;
   output                                   time_scan_out;


   // ###################### CONSTANTS ###################### --

   // ####################### SIGNALS ####################### --
   wire                                     vdd;
   wire                                     gnd;
   wire                                     vcs;


   wire                                     abst_sl_thold_1;
   wire                                     act_dis;
   wire                                     ary_nsl_thold_1;
   wire                                     cfg_sl_thold_1;
   wire                                     clkoff_dc_b;
   wire                                     gptr_scan_io;
   wire [0:9]                               delay_lclkr_dc;
   wire [0:3]                               f_add_ex5_fpcc_iu;
   wire [1:11]                              f_byp_ex1_s_expo;
   wire [0:52]                              f_byp_ex1_s_frac;
   wire                                     f_byp_ex1_s_sign;
   wire                                     f_dcd_ex1_act;
   wire                                     f_dcd_ex1_aop_valid;
   wire                                     f_dcd_ex1_bop_valid;
   wire [0:1]                               f_dcd_ex1_thread;
   wire                                     f_dcd_ex1_bypsel_a_load0;
   wire                                     f_dcd_ex1_bypsel_a_load1;
   wire                                     f_dcd_ex1_bypsel_a_load2;
   wire                                     f_dcd_ex1_bypsel_a_reload0;
   wire                                     f_dcd_ex1_bypsel_a_reload1;
   wire                                     f_dcd_ex1_bypsel_a_reload2;

   wire                                     f_dcd_ex1_bypsel_a_res0;
   wire                                     f_dcd_ex1_bypsel_a_res1;
   wire                                     f_dcd_ex1_bypsel_a_res2;
   wire                                     f_dcd_ex1_bypsel_b_load0;
   wire                                     f_dcd_ex1_bypsel_b_load1;
   wire                                     f_dcd_ex1_bypsel_b_load2;
   wire                                     f_dcd_ex1_bypsel_b_reload0;
   wire                                     f_dcd_ex1_bypsel_b_reload1;
   wire                                     f_dcd_ex1_bypsel_b_reload2;

   wire                                     f_dcd_ex1_bypsel_b_res0;
   wire                                     f_dcd_ex1_bypsel_b_res1;
   wire                                     f_dcd_ex1_bypsel_b_res2;
   wire                                     f_dcd_ex1_bypsel_c_load0;
   wire                                     f_dcd_ex1_bypsel_c_load1;
   wire                                     f_dcd_ex1_bypsel_c_load2;
   wire                                     f_dcd_ex1_bypsel_c_reload0;
   wire                                     f_dcd_ex1_bypsel_c_reload1;
   wire                                     f_dcd_ex1_bypsel_c_reload2;

   wire                                     f_dcd_ex1_bypsel_c_res0;
   wire                                     f_dcd_ex1_bypsel_c_res1;
   wire                                     f_dcd_ex1_bypsel_c_res2;
   wire                                     f_dcd_ex1_bypsel_s_load0;
   wire                                     f_dcd_ex1_bypsel_s_load1;
   wire                                     f_dcd_ex1_bypsel_s_load2;
   wire                                     f_dcd_ex1_bypsel_s_reload0;
   wire                                     f_dcd_ex1_bypsel_s_reload1;
   wire                                     f_dcd_ex1_bypsel_s_reload2;
   wire                                     f_dcd_msr_fp_act;

   wire                                     f_dcd_ex1_bypsel_s_res0;
   wire                                     f_dcd_ex1_bypsel_s_res1;
   wire                                     f_dcd_ex1_bypsel_s_res2;
   wire                                     f_dcd_ex1_compare_b;		// fcomp*
   wire                                     f_dcd_ex1_cop_valid;
   wire [0:4]                               f_dcd_ex1_divsqrt_cr_bf;
   wire                                     f_dcd_axucr0_deno;

   wire                                     f_dcd_ex1_emin_dp;		// prenorm_dp
   wire                                     f_dcd_ex1_emin_sp;		// prenorm_sp, frsp
   wire                                     f_dcd_ex1_est_recip_b;		// fres
   wire                                     f_dcd_ex1_est_rsqrt_b;		// frsqrte
   wire                                     f_dcd_ex1_force_excp_dis;		//
   wire                                     f_dcd_ex1_force_pass_b;		// fmr,fnabbs,fabs,fneg,mtfsf
   wire [0:5]                               f_dcd_ex1_fpscr_addr;
   wire [0:3]                               f_dcd_ex1_fpscr_bit_data_b;		// data to write to nibble (other than mtfsf)
   wire [0:3]                               f_dcd_ex1_fpscr_bit_mask_b;		// enable update of bit with the nibble
   wire [0:8]                               f_dcd_ex1_fpscr_nib_mask_b;		// enable update of this nibble
   wire                                     f_dcd_ex1_from_integer_b;		// fcfid (signed integer)
   wire                                     f_dcd_ex1_frsp_b;		// round-to-sgle-precision ?? need
   wire                                     f_dcd_ex1_fsel_b;		// fsel
   wire                                     f_dcd_ex1_ftdiv;
   wire                                     f_dcd_ex1_ftsqrt;
   wire [0:5]                               f_dcd_ex1_instr_frt;
   wire [0:3]                               f_dcd_ex1_instr_tid;
   wire                                     f_dcd_ex1_inv_sign_b;		// fnmsub fnmadd
   wire [0:6]                               f_dcd_ex1_itag;
   wire                                     f_dcd_ex1_log2e_b;
   wire                                     f_dcd_ex1_math_b;		// fmul,fmad,fmsub,fadd,fsub,fnmsub,fnmadd
   wire                                     f_dcd_ex1_mcrfs_b;		// move fpscr field to cr and reset exceptions
   wire                                     f_dcd_ex1_move_b;		// fmr,fneg,fabs,fnabs
   wire                                     f_dcd_ex1_mtfsbx_b;		// fpscr set bit, reset bit
   wire                                     f_dcd_ex1_mtfsf_b;		// move fpr data to fpscr
   wire                                     f_dcd_ex1_mtfsfi_b;		// move immediate data to fpscr
   wire                                     f_dcd_ex1_mv_from_scr_b;		// mffs
   wire                                     f_dcd_ex1_mv_to_scr_b;		// mcrfs,mtfsf,mtfsfi,mtfsb0,mtfsb1
   wire                                     f_dcd_ex1_nj_deni;		// force output den to zero
   wire                                     f_dcd_ex1_nj_deno;		// force output den to zero
   wire [0:1]                               f_dcd_ex1_op_rnd_b;		// roundg mode = positive infinity
   wire                                     f_dcd_ex1_op_rnd_v_b;		// roundg mode = nearest
   wire                                     f_dcd_ex1_ordered_b;		// fcompo
   wire                                     f_dcd_ex1_pow2e_b;
   wire                                     f_dcd_ex1_prenorm_b;		// prenorm ?? need
   wire                                     f_dcd_ex1_rnd_to_int_b;		// fri*
   wire                                     f_dcd_ex1_sgncpy_b;		// for sgncpy instruction :
   wire [0:1]                               f_dcd_ex1_sign_ctl_b;		// 0:fmr/fneg  1:fneg/fnabs
   wire                                     f_dcd_ex1_sp;		// off for frsp
   wire                                     f_dcd_ex1_sp_conv_b;		// for sp/dp convert
   wire                                     f_dcd_ex1_sto_dp;
   wire                                     f_dcd_ex1_sto_sp;
   wire                                     f_dcd_ex1_sto_wd;
   wire                                     f_dcd_ex1_sub_op_b;		// fsub, fnmsub, fmsub
   wire [0:3]                               f_dcd_ex1_thread_b;
   wire                                     f_dcd_ex1_to_integer_b;		// fcti* (signed integer 32/64)
   wire                                     f_dcd_ex1_uc_end;
   wire                                     f_dcd_ex1_uc_fa_pos;
   wire                                     f_dcd_ex1_uc_fb_0_5;
   wire                                     f_dcd_ex1_uc_fb_0_75;
   wire                                     f_dcd_ex1_uc_fb_1_0;
   wire                                     f_dcd_ex1_uc_fb_pos;
   wire                                     f_dcd_ex1_uc_fc_0_5;
   wire                                     f_dcd_ex1_uc_fc_1_0;
   wire                                     f_dcd_ex1_uc_fc_1_minus;
   wire                                     f_dcd_ex1_uc_fc_hulp;
   wire                                     f_dcd_ex1_uc_fc_pos;
   wire                                     f_dcd_ex1_uc_ft_neg;
   wire                                     f_dcd_ex1_uc_ft_pos;
   wire                                     f_dcd_ex1_uc_mid;
   wire                                     f_dcd_ex1_uc_special;
   wire                                     f_dcd_ex1_uns_b;		// for converts unsigned
   wire                                     f_dcd_ex1_word_b;		// fctiw*
   wire                                     f_dcd_ex2_divsqrt_v;
   wire                                     f_dcd_ex2_divsqrt_hole_v;
   wire [0:1]                               f_dcd_ex3_uc_gs;
   wire                                     f_dcd_ex3_uc_gs_v;
   wire                                     f_dcd_ex3_uc_inc_lsb;
   wire                                     f_dcd_ex3_uc_vxidi;
   wire                                     f_dcd_ex3_uc_vxsnan;
   wire                                     f_dcd_ex3_uc_vxsqrt;
   wire                                     f_dcd_ex3_uc_vxzdz;
   wire                                     f_dcd_ex3_uc_zx;
   wire [0:1]                               f_dcd_ex6_frt_tid;
   wire                                     f_dcd_ex7_cancel;
   wire [0:5]                               f_dcd_ex7_fpscr_addr;
   wire                                     f_dcd_ex7_fpscr_wr;
   wire [0:5]                               f_dcd_ex7_frt_addr;
   wire [0:1]                               f_dcd_ex7_frt_tid;
   wire                                     f_dcd_ex7_frt_wen;
   wire [0:1]                               f_dcd_flush;
   wire [0:5]                               f_dcd_rf0_fra;
   wire [0:5]                               f_dcd_rf0_frb;
   wire [0:5]                               f_dcd_rf0_frc;
   wire [0:1]                               f_dcd_rf0_tid;
   wire                                     f_dcd_ex0_div;
   wire                                     f_dcd_ex0_divs;
   wire                                     f_dcd_ex0_record_v;
   wire                                     f_dcd_ex0_sqrt;
   wire                                     f_dcd_ex0_sqrts;
   wire                                     f_dcd_si;
   wire                                     f_dcd_so;
   wire [0:6]                               f_dsq_ex5_divsqrt_itag;
   wire [0:1]                               f_dsq_ex5_divsqrt_v;
   wire [0:4]                               f_dsq_ex6_divsqrt_cr_bf;
   wire [0:5]                               f_dsq_ex6_divsqrt_fpscr_addr;
   wire [0:5]                               f_dsq_ex6_divsqrt_instr_frt;
   wire [0:3]                               f_dsq_ex6_divsqrt_instr_tid;
   wire                                     f_dsq_ex3_hangcounter_trigger_int;
   wire                                     f_dcd_rv_hold_all_int;


   wire                                     f_dsq_ex6_divsqrt_record_v;
   wire [0:1]                               f_dsq_ex6_divsqrt_v;
   wire                                     f_dsq_ex6_divsqrt_v_suppress;
   wire [0:63]				    f_dsq_debug;

   wire                                     f_ex3_b_den_flush;
   wire [1:13]                              f_fpr_ex1_a_expo;
   wire [0:52]                              f_fpr_ex1_a_frac;
   wire                                     f_fpr_ex1_a_sign;
   wire [1:13]                              f_fpr_ex1_b_expo;
   wire [0:52]                              f_fpr_ex1_b_frac;
   wire                                     f_fpr_ex1_b_sign;
   wire [1:13]                              f_fpr_ex1_c_expo;
   wire [0:52]                              f_fpr_ex1_c_frac;
   wire                                     f_fpr_ex1_c_sign;
   wire [1:11]                              f_fpr_ex1_s_expo;
   wire [0:52]                              f_fpr_ex1_s_frac;
   wire                                     f_fpr_ex1_s_sign;
   wire [0:7]                               f_fpr_ex2_a_par;
   wire [0:7]                               f_fpr_ex2_b_par;
   wire [0:7]                               f_fpr_ex2_c_par;
   wire [0:1]                               f_fpr_ex2_s_expo_extra;
   wire [0:7]                               f_fpr_ex2_s_par;
   wire [0:7]                               f_fpr_ex6_load_addr;
   wire [3:13]                              f_fpr_ex6_load_expo;
   wire [0:52]                              f_fpr_ex6_load_frac;
   wire                                     f_fpr_ex6_load_sign;
   wire                                     f_fpr_ex6_load_v;
   wire [3:13]                              f_fpr_ex7_load_expo;
   wire [0:52]                              f_fpr_ex7_load_frac;
   wire                                     f_fpr_ex7_load_sign;
   wire [3:13]                              f_fpr_ex8_load_expo;
   wire [0:52]                              f_fpr_ex8_load_frac;
   wire                                     f_fpr_ex8_load_sign;

   wire [1:13]                              f_fpr_ex8_frt_expo;
   wire [0:52]                              f_fpr_ex8_frt_frac;
   wire                                     f_fpr_ex8_frt_sign;


   wire                                     f_fpr_ex6_reload_v;
   wire [0:7]                               f_fpr_ex6_reload_addr;

   wire [3:13]                              f_fpr_ex6_reload_expo;
   wire [0:52]                              f_fpr_ex6_reload_frac;
   wire                                     f_fpr_ex6_reload_sign;
   wire [3:13]                              f_fpr_ex7_reload_expo;
   wire [0:52]                              f_fpr_ex7_reload_frac;
   wire                                     f_fpr_ex7_reload_sign;
   wire [3:13]                              f_fpr_ex8_reload_expo;
   wire [0:52]                              f_fpr_ex8_reload_frac;
   wire                                     f_fpr_ex8_reload_sign;

   wire                                     f_dcd_ex1_sto_act;
   wire                                     f_dcd_ex1_mad_act;


   wire [1:13]                              f_fpr_ex9_frt_expo;
   wire [0:52]                              f_fpr_ex9_frt_frac;
   wire                                     f_fpr_ex9_frt_sign;
   wire                                     f_fpr_si;
   wire                                     f_fpr_so;
   wire                                     f_mad_ex3_a_parity_check;
   wire                                     f_mad_ex3_b_parity_check;
   wire                                     f_mad_ex3_c_parity_check;
   wire                                     f_mad_ex4_uc_res_sign;
   wire [0:1]                               f_mad_ex4_uc_round_mode;
   wire                                     f_mad_ex4_uc_special;
   wire                                     f_mad_ex4_uc_vxidi;
   wire                                     f_mad_ex4_uc_vxsnan;
   wire                                     f_mad_ex4_uc_vxsqrt;
   wire                                     f_mad_ex4_uc_vxzdz;
   wire                                     f_mad_ex4_uc_zx;
   wire                                     f_mad_ex7_uc_sign;
   wire                                     f_mad_ex7_uc_zero;
   wire [0:18]                              f_mad_si;
   wire [0:18]                              f_mad_so;
   wire                                     f_pic_ex6_fpr_wr_dis_b;
   wire                                     f_pic_ex6_scr_upd_move_b;
   wire [1:13]                              f_rnd_ex7_res_expo;
   wire [0:52]                              f_rnd_ex7_res_frac;
   wire                                     f_rnd_ex7_res_sign;
   wire                                     f_rv_si;
   wire                                     f_rv_so;
   wire [0:3]                               f_scr_cpl_fx_thread0;
   wire [0:3]                               f_scr_cpl_fx_thread1;
   wire [0:3]                               f_scr_ex8_cr_fld;
   wire [0:3]                               f_scr_ex8_fx_thread0;
   wire [0:3]                               f_scr_ex8_fx_thread1;
   wire                                     f_scr_ex6_fpscr_ni_thr0_int;
   wire                                     f_scr_ex6_fpscr_ni_thr1_int;
   wire                                     f_sto_ex3_s_parity_check;
   wire                                     f_sto_si;
   wire                                     f_sto_so;
   wire                                     fce_1;
   wire                                     fpu_enable;		//dc_act
   wire [0:1]                               func_sl_thold_1;

   wire                                     gptr_sl_thold_0;
   wire                                     func_slp_sl_thold_1;

   wire [0:3]                               axu0_iu_perf_events_int;
   wire [0:3]                               axu1_iu_perf_events_int;

   wire                                      iu_fu_rf0_instr_match;
   wire [0:`THREADS-1]                       iu_fu_rf0_instr_v;
   wire [0:`THREADS-1]                       iu_fu_rf0_tid;
   wire [0:6]                               iu_fu_ex0_itag;
   wire [0:9]                               iu_fu_rf0_ldst_tag;
   wire [0:9]                               mpw1_dc_b;
   wire [0:1]                               mpw2_dc_b;
   wire [0:1]                               sg_1;
   wire                                     tidn;
   wire                                     time_sl_thold_1;
   wire                                     tiup;
   wire                                     rf0_act_b;

   wire                                     f_dcd_perr_sm_running;
   wire                                     f_dcd_ex2_perr_force_c;
   wire                                     f_dcd_ex2_perr_fsel_ovrd;

   //----------------------------------------------------------------------
   //-------------------------------------------------------------------------------------------------
   //-------------------------------------------------------------------------------------------------
   assign tidn = 1'b0;
   assign tiup = 1'b1;

   assign vdd = 1'b1;
   assign vcs = 1'b1;
   assign gnd = 1'b0;


   // TEMP TEMP todo
   assign iu_fu_rf0_instr_match = tidn;

   generate
      if (`THREADS == 1)
      begin : addr_gen_1
         assign iu_fu_rf0_ldst_tag[0:9] = {4'b0000, rv_axu0_s3_p[0:5]};
      end
   endgenerate

   generate
      if (`THREADS == 2)
      begin : addr_gen_2
         assign iu_fu_rf0_ldst_tag[0:9] = {3'b000, rv_axu0_s3_p[0:5], rv_axu0_vld[1]};
      end
   endgenerate

   //----------------------------------------------------------------------
   // Floating Point Pervasive staging, lcbctrl's

   fu_perv  prv(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_fu_sg_3(pc_fu_sg_3),
      .pc_fu_abst_sl_thold_3(pc_fu_abst_sl_thold_3),
      .pc_fu_func_sl_thold_3(pc_fu_func_sl_thold_3),
      .pc_fu_func_slp_sl_thold_3(pc_fu_func_slp_sl_thold_3),
      .pc_fu_gptr_sl_thold_3(pc_fu_gptr_sl_thold_3),
      .pc_fu_time_sl_thold_3(pc_fu_time_sl_thold_3),
      .pc_fu_ary_nsl_thold_3(pc_fu_ary_nsl_thold_3),
      .pc_fu_cfg_sl_thold_3(pc_fu_cfg_sl_thold_3),
      .pc_fu_repr_sl_thold_3(pc_fu_repr_sl_thold_3),
      .pc_fu_fce_3(pc_fu_fce_3),
      .gptr_sl_thold_0(gptr_sl_thold_0),
      .func_slp_sl_thold_1(func_slp_sl_thold_1),
      .tc_ac_ccflush_dc(pc_fu_ccflush_dc),
      .tc_ac_scan_diag_dc(tc_ac_scan_diag_dc),
      .abst_sl_thold_1(abst_sl_thold_1),
      .func_sl_thold_1(func_sl_thold_1),
      .time_sl_thold_1(time_sl_thold_1),
      .ary_nsl_thold_1(ary_nsl_thold_1),
      .cfg_sl_thold_1(cfg_sl_thold_1),
      .fce_1(fce_1),
      .sg_1(sg_1),
      .clkoff_dc_b(clkoff_dc_b),
      .act_dis(act_dis),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .repr_scan_in(repr_scan_in),
      .repr_scan_out(repr_scan_out),
      .gptr_scan_in(gptr_scan_in),
      .gptr_scan_out(gptr_scan_out)
   );

   //----------------------------------------------------------------------
   // Floating Point Register, ex0

   fu_fpr #( .fpr_pool(`FPR_POOL * `THREADS), .fpr_pool_enc(`FPR_POOL_ENC + `THREAD_POOL_ENC), .axu_spare_enc(`AXU_SPARE_ENC), .threads(`THREADS)) fpr(
      .nclk(nclk),
      .clkoff_b(clkoff_dc_b),
      .act_dis(act_dis),
      .flush(pc_fu_ccflush_dc),
      .delay_lclkra(delay_lclkr_dc[0:1]),
      .delay_lclkrb(delay_lclkr_dc[6:7]),
      .mpw1_ba(mpw1_dc_b[0:1]),
      .mpw1_bb(mpw1_dc_b[6:7]),
      .mpw2_b(mpw2_dc_b),
      .sg_1(sg_1[1]),
      .abst_sl_thold_1(abst_sl_thold_1),
      .time_sl_thold_1(time_sl_thold_1),
      .ary_nsl_thold_1(ary_nsl_thold_1),
      .gptr_sl_thold_0(gptr_sl_thold_0),
      .fce_1(fce_1),
      .thold_1(func_sl_thold_1[1]),
      .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .lbist_en_dc(an_ac_lbist_en_dc),
      .f_fpr_si(f_fpr_si),
      .f_fpr_so(f_fpr_so),
      .f_fpr_ab_si(abst_scan_in),
      .f_fpr_ab_so(abst_scan_out),
      .time_scan_in(time_scan_in),
      .time_scan_out(time_scan_out),
      .vdd(vdd),
      //.vcs(vcs),
      .gnd(gnd),
      .pc_fu_abist_di_0(pc_fu_abist_di_0),
      .pc_fu_abist_di_1(pc_fu_abist_di_1),
      .pc_fu_abist_ena_dc(pc_fu_abist_ena_dc),
      .pc_fu_abist_grf_renb_0(pc_fu_abist_grf_renb_0),
      .pc_fu_abist_grf_renb_1(pc_fu_abist_grf_renb_1),
      .pc_fu_abist_grf_wenb_0(pc_fu_abist_grf_wenb_0),
      .pc_fu_abist_grf_wenb_1(pc_fu_abist_grf_wenb_1),
      .pc_fu_abist_raddr_0(pc_fu_abist_raddr_0),
      .pc_fu_abist_raddr_1(pc_fu_abist_raddr_1),
      .pc_fu_abist_raw_dc_b(pc_fu_abist_raw_dc_b),
      .pc_fu_abist_waddr_0(pc_fu_abist_waddr_0),
      .pc_fu_abist_waddr_1(pc_fu_abist_waddr_1),
      .pc_fu_abist_wl144_comp_ena(pc_fu_abist_wl144_comp_ena),
      .pc_fu_inj_regfile_parity(pc_fu_inj_regfile_parity),
      .f_dcd_msr_fp_act(f_dcd_msr_fp_act),
      .iu_fu_rf0_fra_v(rv_axu0_s1_v),
      .iu_fu_rf0_frb_v(rv_axu0_s2_v),
      .iu_fu_rf0_frc_v(rv_axu0_s3_v),
      .iu_fu_rf0_str_v(tiup),   //todo act
      .iu_fu_rf0_tid(iu_fu_rf0_tid),
      .f_dcd_rf0_fra(f_dcd_rf0_fra),
      .f_dcd_rf0_frb(f_dcd_rf0_frb),
      .f_dcd_rf0_frc(f_dcd_rf0_frc),
      .f_dcd_rf0_tid(f_dcd_rf0_tid),
      .iu_fu_rf0_ldst_tag(iu_fu_rf0_ldst_tag),
      .f_dcd_ex7_frt_addr(f_dcd_ex7_frt_addr),
      .f_dcd_ex6_frt_tid(f_dcd_ex6_frt_tid),
      .f_dcd_ex7_frt_tid(f_dcd_ex7_frt_tid),
      .f_dcd_ex7_frt_wen(f_dcd_ex7_frt_wen),
      .f_rnd_ex7_res_expo(f_rnd_ex7_res_expo),
      .f_rnd_ex7_res_frac(f_rnd_ex7_res_frac),
      .f_rnd_ex7_res_sign(f_rnd_ex7_res_sign),
      .xu_fu_ex5_load_tag(lq_fu_ex5_load_tag),
      .xu_fu_ex5_load_val(lq_fu_ex5_load_val),
      .xu_fu_ex5_load_data(lq_fu_ex5_load_data),
      .lq_gpr_rel_we(lq_gpr_rel_we),
      .lq_gpr_rel_le(lq_gpr_rel_le),
      .lq_gpr_rel_wa(lq_gpr_rel_wa),
      .lq_gpr_rel_wd(lq_gpr_rel_wd),
      .f_fpr_ex6_load_addr(f_fpr_ex6_load_addr),
      .f_fpr_ex6_load_v(f_fpr_ex6_load_v),
      .f_fpr_ex6_reload_addr(f_fpr_ex6_reload_addr),
      .f_fpr_ex6_reload_v(f_fpr_ex6_reload_v),
      .f_fpr_ex6_load_sign(f_fpr_ex6_load_sign),
      .f_fpr_ex6_load_expo(f_fpr_ex6_load_expo),
      .f_fpr_ex6_load_frac(f_fpr_ex6_load_frac),
      .f_fpr_ex7_load_sign(f_fpr_ex7_load_sign),
      .f_fpr_ex7_load_expo(f_fpr_ex7_load_expo),
      .f_fpr_ex7_load_frac(f_fpr_ex7_load_frac),
      .f_fpr_ex8_load_sign(f_fpr_ex8_load_sign),
      .f_fpr_ex8_load_expo(f_fpr_ex8_load_expo),
      .f_fpr_ex8_load_frac(f_fpr_ex8_load_frac),
      .f_fpr_ex6_reload_sign(f_fpr_ex6_reload_sign),
      .f_fpr_ex6_reload_expo(f_fpr_ex6_reload_expo),
      .f_fpr_ex6_reload_frac(f_fpr_ex6_reload_frac),
      .f_fpr_ex7_reload_sign(f_fpr_ex7_reload_sign),
      .f_fpr_ex7_reload_expo(f_fpr_ex7_reload_expo),
      .f_fpr_ex7_reload_frac(f_fpr_ex7_reload_frac),
      .f_fpr_ex8_reload_sign(f_fpr_ex8_reload_sign),
      .f_fpr_ex8_reload_expo(f_fpr_ex8_reload_expo),
      .f_fpr_ex8_reload_frac(f_fpr_ex8_reload_frac),
      .f_fpr_ex1_s_sign(f_fpr_ex1_s_sign),
      .f_fpr_ex1_s_expo(f_fpr_ex1_s_expo),
      .f_fpr_ex1_s_frac(f_fpr_ex1_s_frac),
      .f_fpr_ex1_a_sign(f_fpr_ex1_a_sign),
      .f_fpr_ex1_a_expo(f_fpr_ex1_a_expo),
      .f_fpr_ex1_a_frac(f_fpr_ex1_a_frac),
      .f_fpr_ex1_c_sign(f_fpr_ex1_c_sign),
      .f_fpr_ex1_c_expo(f_fpr_ex1_c_expo),
      .f_fpr_ex1_c_frac(f_fpr_ex1_c_frac),
      .f_fpr_ex1_b_sign(f_fpr_ex1_b_sign),
      .f_fpr_ex1_b_expo(f_fpr_ex1_b_expo),
      .f_fpr_ex1_b_frac(f_fpr_ex1_b_frac),
      .f_fpr_ex8_frt_sign(f_fpr_ex8_frt_sign),
      .f_fpr_ex8_frt_expo(f_fpr_ex8_frt_expo),
      .f_fpr_ex8_frt_frac(f_fpr_ex8_frt_frac),
      .f_fpr_ex9_frt_sign(f_fpr_ex9_frt_sign),
      .f_fpr_ex9_frt_expo(f_fpr_ex9_frt_expo),
      .f_fpr_ex9_frt_frac(f_fpr_ex9_frt_frac),

      .f_fpr_ex2_s_expo_extra(f_fpr_ex2_s_expo_extra),
      .f_fpr_ex2_s_par(f_fpr_ex2_s_par),
      .f_fpr_ex2_a_par(f_fpr_ex2_a_par),
      .f_fpr_ex2_b_par(f_fpr_ex2_b_par),
      .f_fpr_ex2_c_par(f_fpr_ex2_c_par)
   );

   //----------------------------------------------------------------------
   // Store

   fu_sto sto(
      .vdd(vdd),
      .gnd(gnd),
      .clkoff_b(clkoff_dc_b),
      .act_dis(act_dis),
      .flush(pc_fu_ccflush_dc),
      .delay_lclkr(delay_lclkr_dc[1:2]),
      .mpw1_b(mpw1_dc_b[1:2]),
      .mpw2_b(mpw2_dc_b[0:0]),
      .sg_1(sg_1[1]),
      .thold_1(func_sl_thold_1[1]),
      .fpu_enable(fpu_enable),
      .nclk(nclk),
      .f_sto_si(f_sto_si),
      .f_sto_so(f_sto_so),
      .f_dcd_ex1_sto_act(f_dcd_ex1_sto_act),
      .f_dcd_ex1_sto_v(f_dcd_ex1_sto_v),
      .f_fpr_ex2_s_expo_extra(f_fpr_ex2_s_expo_extra),
      .f_fpr_ex2_s_par(f_fpr_ex2_s_par),
      .f_sto_ex3_s_parity_check(f_sto_ex3_s_parity_check),
      .f_dcd_ex1_sto_dp(f_dcd_ex1_sto_dp),
      .f_dcd_ex1_sto_sp(f_dcd_ex1_sto_sp),
      .f_dcd_ex1_sto_wd(f_dcd_ex1_sto_wd),
      .f_byp_ex1_s_sign(f_byp_ex1_s_sign),
      .f_byp_ex1_s_expo(f_byp_ex1_s_expo),
      .f_byp_ex1_s_frac(f_byp_ex1_s_frac),
      .f_sto_ex3_sto_data(fu_lq_ex3_store_data)
   );

   //----------------------------------------------------------------------
   // Main Pipe

   assign fpu_enable = f_dcd_msr_fp_act;




   fu_mad #( .THREADS(`THREADS)) mad(
      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),
      .f_dcd_ex1_bypsel_a_res0(f_dcd_ex1_bypsel_a_res0),
      .f_dcd_ex1_bypsel_a_res1(f_dcd_ex1_bypsel_a_res1),
      .f_dcd_ex1_bypsel_a_res2(f_dcd_ex1_bypsel_a_res2),
      .f_dcd_ex1_bypsel_a_load0(f_dcd_ex1_bypsel_a_load0),
      .f_dcd_ex1_bypsel_a_load1(f_dcd_ex1_bypsel_a_load1),
      .f_dcd_ex1_bypsel_a_load2(f_dcd_ex1_bypsel_a_load2),
      .f_dcd_ex1_bypsel_a_reload0(f_dcd_ex1_bypsel_a_reload0),
      .f_dcd_ex1_bypsel_a_reload1(f_dcd_ex1_bypsel_a_reload1),
      .f_dcd_ex1_bypsel_a_reload2(f_dcd_ex1_bypsel_a_reload2),

      .f_dcd_ex1_bypsel_b_res0(f_dcd_ex1_bypsel_b_res0),
      .f_dcd_ex1_bypsel_b_res1(f_dcd_ex1_bypsel_b_res1),
      .f_dcd_ex1_bypsel_b_res2(f_dcd_ex1_bypsel_b_res2),
      .f_dcd_ex1_bypsel_b_load0(f_dcd_ex1_bypsel_b_load0),
      .f_dcd_ex1_bypsel_b_load1(f_dcd_ex1_bypsel_b_load1),
      .f_dcd_ex1_bypsel_b_load2(f_dcd_ex1_bypsel_b_load2),
      .f_dcd_ex1_bypsel_b_reload0(f_dcd_ex1_bypsel_b_reload0),
      .f_dcd_ex1_bypsel_b_reload1(f_dcd_ex1_bypsel_b_reload1),
      .f_dcd_ex1_bypsel_b_reload2(f_dcd_ex1_bypsel_b_reload2),

      .f_dcd_ex1_bypsel_c_res0(f_dcd_ex1_bypsel_c_res0),
      .f_dcd_ex1_bypsel_c_res1(f_dcd_ex1_bypsel_c_res1),
      .f_dcd_ex1_bypsel_c_res2(f_dcd_ex1_bypsel_c_res2),
      .f_dcd_ex1_bypsel_c_load0(f_dcd_ex1_bypsel_c_load0),
      .f_dcd_ex1_bypsel_c_load1(f_dcd_ex1_bypsel_c_load1),
      .f_dcd_ex1_bypsel_c_load2(f_dcd_ex1_bypsel_c_load2),
      .f_dcd_ex1_bypsel_c_reload0(f_dcd_ex1_bypsel_c_reload0),
      .f_dcd_ex1_bypsel_c_reload1(f_dcd_ex1_bypsel_c_reload1),
      .f_dcd_ex1_bypsel_c_reload2(f_dcd_ex1_bypsel_c_reload2),

      .f_dcd_ex1_bypsel_s_res0(f_dcd_ex1_bypsel_s_res0),
      .f_dcd_ex1_bypsel_s_res1(f_dcd_ex1_bypsel_s_res1),
      .f_dcd_ex1_bypsel_s_res2(f_dcd_ex1_bypsel_s_res2),
      .f_dcd_ex1_bypsel_s_load0(f_dcd_ex1_bypsel_s_load0),
      .f_dcd_ex1_bypsel_s_load1(f_dcd_ex1_bypsel_s_load1),
      .f_dcd_ex1_bypsel_s_load2(f_dcd_ex1_bypsel_s_load2),
      .f_dcd_ex1_bypsel_s_reload0(f_dcd_ex1_bypsel_s_reload0),
      .f_dcd_ex1_bypsel_s_reload1(f_dcd_ex1_bypsel_s_reload1),
      .f_dcd_ex1_bypsel_s_reload2(f_dcd_ex1_bypsel_s_reload2),

      .f_dcd_ex2_perr_force_c(f_dcd_ex2_perr_force_c),
      .f_dcd_ex2_perr_fsel_ovrd(f_dcd_ex2_perr_fsel_ovrd),

      .f_fpr_ex1_s_sign(f_fpr_ex1_s_sign),
      .f_fpr_ex1_s_expo(f_fpr_ex1_s_expo[1:11]),
      .f_fpr_ex1_s_frac(f_fpr_ex1_s_frac),
      .f_byp_ex1_s_sign(f_byp_ex1_s_sign),
      .f_byp_ex1_s_expo(f_byp_ex1_s_expo[1:11]),
      .f_byp_ex1_s_frac(f_byp_ex1_s_frac),
      .f_dcd_ex1_force_excp_dis(f_dcd_ex1_force_excp_dis),
      //----------------------------------------------
      .f_fpr_ex8_frt_sign(f_fpr_ex8_frt_sign),
      .f_fpr_ex8_frt_expo(f_fpr_ex8_frt_expo[1:13]),
      .f_fpr_ex8_frt_frac(f_fpr_ex8_frt_frac[0:52]),
      .f_fpr_ex9_frt_sign(f_fpr_ex9_frt_sign),
      .f_fpr_ex9_frt_expo(f_fpr_ex9_frt_expo[1:13]),
      .f_fpr_ex9_frt_frac(f_fpr_ex9_frt_frac[0:52]),

      .f_fpr_ex6_load_sign(f_fpr_ex6_load_sign),
      .f_fpr_ex6_load_expo(f_fpr_ex6_load_expo),
      .f_fpr_ex6_load_frac(f_fpr_ex6_load_frac),
      .f_fpr_ex7_load_sign(f_fpr_ex7_load_sign),
      .f_fpr_ex7_load_expo(f_fpr_ex7_load_expo[3:13]),
      .f_fpr_ex7_load_frac(f_fpr_ex7_load_frac[0:52]),
      .f_fpr_ex8_load_sign(f_fpr_ex8_load_sign),
      .f_fpr_ex8_load_expo(f_fpr_ex8_load_expo[3:13]),
      .f_fpr_ex8_load_frac(f_fpr_ex8_load_frac[0:52]),
      .f_fpr_ex6_reload_sign(f_fpr_ex6_reload_sign),
      .f_fpr_ex6_reload_expo(f_fpr_ex6_reload_expo),
      .f_fpr_ex6_reload_frac(f_fpr_ex6_reload_frac),
      .f_fpr_ex7_reload_sign(f_fpr_ex7_reload_sign),
      .f_fpr_ex7_reload_expo(f_fpr_ex7_reload_expo[3:13]),
      .f_fpr_ex7_reload_frac(f_fpr_ex7_reload_frac[0:52]),
      .f_fpr_ex8_reload_sign(f_fpr_ex8_reload_sign),
      .f_fpr_ex8_reload_expo(f_fpr_ex8_reload_expo[3:13]),
      .f_fpr_ex8_reload_frac(f_fpr_ex8_reload_frac[0:52]),
      //----------------------------------------------

      .f_fpr_ex1_a_sign(f_fpr_ex1_a_sign),
      .f_fpr_ex1_a_expo(f_fpr_ex1_a_expo),
      .f_fpr_ex1_a_frac(f_fpr_ex1_a_frac),
      .f_fpr_ex1_c_sign(f_fpr_ex1_c_sign),
      .f_fpr_ex1_c_expo(f_fpr_ex1_c_expo),
      .f_fpr_ex1_c_frac(f_fpr_ex1_c_frac),
      .f_fpr_ex1_b_sign(f_fpr_ex1_b_sign),
      .f_fpr_ex1_b_expo(f_fpr_ex1_b_expo),
      .f_fpr_ex1_b_frac(f_fpr_ex1_b_frac),
      //----------------------------------------------
      .f_dcd_ex1_instr_frt(f_dcd_ex1_instr_frt),
      .f_dcd_ex1_instr_tid(f_dcd_ex1_instr_tid),
      .f_dsq_ex6_divsqrt_instr_frt(f_dsq_ex6_divsqrt_instr_frt),
      .f_dsq_ex6_divsqrt_instr_tid(f_dsq_ex6_divsqrt_instr_tid),
      .f_dsq_ex3_hangcounter_trigger(f_dsq_ex3_hangcounter_trigger_int),
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),
      .f_dcd_ex1_thread(f_dcd_ex1_thread),
      .f_dcd_ex1_sp(f_dcd_ex1_sp),
      .f_dcd_ex1_emin_dp(f_dcd_ex1_emin_dp),
      .f_dcd_ex1_emin_sp(f_dcd_ex1_emin_sp),
      .f_dcd_ex1_force_pass_b(f_dcd_ex1_force_pass_b),
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),
      .f_dcd_ex1_rnd_to_int_b(f_dcd_ex1_rnd_to_int_b),
      .f_dcd_ex1_math_b(f_dcd_ex1_math_b),
      .f_dcd_ex1_est_recip_b(f_dcd_ex1_est_recip_b),
      .f_dcd_ex1_est_rsqrt_b(f_dcd_ex1_est_rsqrt_b),
      .f_dcd_ex1_move_b(f_dcd_ex1_move_b),
      .f_dcd_ex1_prenorm_b(f_dcd_ex1_prenorm_b),
      .f_dcd_ex1_frsp_b(f_dcd_ex1_frsp_b),
      .f_dcd_ex1_compare_b(f_dcd_ex1_compare_b),
      .f_dcd_ex1_ordered_b(f_dcd_ex1_ordered_b),
      .f_dcd_ex1_nj_deni(f_dcd_ex1_nj_deni),
      .f_dcd_ex1_nj_deno(f_dcd_ex1_nj_deno),
      .f_dcd_ex1_sp_conv_b(f_dcd_ex1_sp_conv_b),
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),
      .f_dcd_ex1_sub_op_b(f_dcd_ex1_sub_op_b),
      .f_dcd_ex1_op_rnd_v_b(f_dcd_ex1_op_rnd_v_b),
      .f_dcd_ex1_op_rnd_b(f_dcd_ex1_op_rnd_b),
      .f_dcd_ex1_inv_sign_b(f_dcd_ex1_inv_sign_b),
      .f_dcd_ex1_sign_ctl_b(f_dcd_ex1_sign_ctl_b),
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),
      .f_dcd_ex1_fpscr_bit_data_b(f_dcd_ex1_fpscr_bit_data_b),
      .f_dcd_ex1_fpscr_bit_mask_b(f_dcd_ex1_fpscr_bit_mask_b),
      .f_dcd_ex1_fpscr_nib_mask_b(f_dcd_ex1_fpscr_nib_mask_b),
      .f_dcd_ex1_mv_to_scr_b(f_dcd_ex1_mv_to_scr_b),
      .f_dcd_ex1_mv_from_scr_b(f_dcd_ex1_mv_from_scr_b),
      .f_dcd_ex1_mtfsbx_b(f_dcd_ex1_mtfsbx_b),
      .f_dcd_ex1_mcrfs_b(f_dcd_ex1_mcrfs_b),
      .f_dcd_ex1_mtfsf_b(f_dcd_ex1_mtfsf_b),
      .f_dcd_ex1_mtfsfi_b(f_dcd_ex1_mtfsfi_b),
      .f_dcd_ex1_log2e_b(f_dcd_ex1_log2e_b),
      .f_dcd_ex1_pow2e_b(f_dcd_ex1_pow2e_b),
      .f_dcd_ex1_ftdiv(f_dcd_ex1_ftdiv),
      .f_dcd_ex1_ftsqrt(f_dcd_ex1_ftsqrt),
      .f_dcd_ex0_div(f_dcd_ex0_div),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_divs(f_dcd_ex0_divs),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_sqrt(f_dcd_ex0_sqrt),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_sqrts(f_dcd_ex0_sqrts),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex0_record_v(f_dcd_ex0_record_v),		//i--fdsq  --  :in  std_ulogic;
      .f_dcd_ex2_divsqrt_v(f_dcd_ex2_divsqrt_v),
      .f_dcd_ex2_divsqrt_hole_v(f_dcd_ex2_divsqrt_hole_v),		//i--fdsq
      .f_dcd_flush(f_dcd_flush),		//i--fdsq  --  :in std_ulogic;
      .f_dcd_ex1_itag(f_dcd_ex1_itag),		//i--fdsq  --  :in std_ulogic_vector(0 to 6);
      .f_dcd_ex1_fpscr_addr(f_dcd_ex1_fpscr_addr),		//i--fdsq  --  :in std_ulogic_vector(0 to 6);
      .f_dsq_ex5_divsqrt_v(f_dsq_ex5_divsqrt_v),
      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_suppress),
      .f_dsq_debug(f_dsq_debug),
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v),
      .f_dsq_ex6_divsqrt_record_v(f_dsq_ex6_divsqrt_record_v),
      .f_dsq_ex5_divsqrt_itag(f_dsq_ex5_divsqrt_itag),
      .f_dsq_ex6_divsqrt_fpscr_addr(f_dsq_ex6_divsqrt_fpscr_addr),
      .f_dcd_ex1_divsqrt_cr_bf(f_dcd_ex1_divsqrt_cr_bf),		//i--fdsq
      .f_dcd_axucr0_deno(f_dcd_axucr0_deno),
      .f_dsq_ex6_divsqrt_cr_bf(f_dsq_ex6_divsqrt_cr_bf),
      .f_add_ex5_fpcc_iu(f_add_ex5_fpcc_iu),
      .f_pic_ex6_fpr_wr_dis_b(f_pic_ex6_fpr_wr_dis_b),
      .f_scr_ex8_cr_fld(f_scr_ex8_cr_fld),
      .f_scr_ex6_fpscr_ni_thr0(f_scr_ex6_fpscr_ni_thr0_int),
      .f_scr_ex6_fpscr_ni_thr1(f_scr_ex6_fpscr_ni_thr1_int),
      .f_rnd_ex7_res_expo(f_rnd_ex7_res_expo),
      .f_rnd_ex7_res_frac(f_rnd_ex7_res_frac),
      .f_rnd_ex7_res_sign(f_rnd_ex7_res_sign),
      .f_ex3_b_den_flush(f_ex3_b_den_flush),
      .f_scr_ex8_fx_thread0(f_scr_ex8_fx_thread0),
      .f_scr_ex8_fx_thread1(f_scr_ex8_fx_thread1),
      .f_scr_cpl_fx_thread0(f_scr_cpl_fx_thread0),
      .f_scr_cpl_fx_thread1(f_scr_cpl_fx_thread1),
      //----------------------------------------------
      .f_dcd_ex1_uc_ft_pos(f_dcd_ex1_uc_ft_pos),		//i--mad
      .f_dcd_ex1_uc_ft_neg(f_dcd_ex1_uc_ft_neg),		//i--mad
      .f_dcd_ex1_uc_fa_pos(f_dcd_ex1_uc_fa_pos),		//i--mad
      .f_dcd_ex1_uc_fc_pos(f_dcd_ex1_uc_fc_pos),		//i--mad
      .f_dcd_ex1_uc_fb_pos(f_dcd_ex1_uc_fb_pos),		//i--mad
      .f_dcd_ex1_uc_fc_hulp(f_dcd_ex1_uc_fc_hulp),		//i--mad
      .f_dcd_ex1_uc_fc_0_5(f_dcd_ex1_uc_fc_0_5),		//i--mad
      .f_dcd_ex1_uc_fc_1_0(f_dcd_ex1_uc_fc_1_0),		//i--mad
      .f_dcd_ex1_uc_fc_1_minus(f_dcd_ex1_uc_fc_1_minus),		//i--mad
      .f_dcd_ex1_uc_fb_1_0(f_dcd_ex1_uc_fb_1_0),		//i--mad
      .f_dcd_ex1_uc_fb_0_75(f_dcd_ex1_uc_fb_0_75),		//i--mad
      .f_dcd_ex1_uc_fb_0_5(f_dcd_ex1_uc_fb_0_5),		//i--mad
      .f_dcd_ex3_uc_inc_lsb(f_dcd_ex3_uc_inc_lsb),		//i--mad
      .f_dcd_ex3_uc_gs_v(f_dcd_ex3_uc_gs_v),		//i--mad
      .f_dcd_ex3_uc_gs(f_dcd_ex3_uc_gs),		//i--mad

      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),		//i--mad
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),		//i--mad
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),		//i--mad
      .f_dcd_ex3_uc_vxsnan(f_dcd_ex3_uc_vxsnan),
      .f_dcd_ex3_uc_zx(f_dcd_ex3_uc_zx),		//i--mad
      .f_dcd_ex3_uc_vxidi(f_dcd_ex3_uc_vxidi),		//i--mad
      .f_dcd_ex3_uc_vxzdz(f_dcd_ex3_uc_vxzdz),		//i--mad
      .f_dcd_ex3_uc_vxsqrt(f_dcd_ex3_uc_vxsqrt),		//i--mad
      //----------------------------------------------------------------
      .f_mad_ex7_uc_sign(f_mad_ex7_uc_sign),		//o--mad
      .f_mad_ex7_uc_zero(f_mad_ex7_uc_zero),		//o--mad
      .f_mad_ex4_uc_special(f_mad_ex4_uc_special),		//o--mad
      .f_mad_ex4_uc_vxsnan(f_mad_ex4_uc_vxsnan),
      .f_mad_ex4_uc_zx(f_mad_ex4_uc_zx),		//o--mad
      .f_mad_ex4_uc_vxsqrt(f_mad_ex4_uc_vxsqrt),		//o--mad
      .f_mad_ex4_uc_vxidi(f_mad_ex4_uc_vxidi),		//o--mad
      .f_mad_ex4_uc_vxzdz(f_mad_ex4_uc_vxzdz),		//o--mad
      .f_mad_ex4_uc_res_sign(f_mad_ex4_uc_res_sign),		//o--mad
      .f_mad_ex4_uc_round_mode(f_mad_ex4_uc_round_mode[0:1]),		//o--mad
      //-----------------------------------------
      .f_fpr_ex2_a_par(f_fpr_ex2_a_par),
      .f_fpr_ex2_b_par(f_fpr_ex2_b_par),
      .f_fpr_ex2_c_par(f_fpr_ex2_c_par),
      .f_mad_ex3_a_parity_check(f_mad_ex3_a_parity_check),
      .f_mad_ex3_c_parity_check(f_mad_ex3_c_parity_check),
      .f_mad_ex3_b_parity_check(f_mad_ex3_b_parity_check),
      //----------------------------------------------
      .ex1_thread_b(f_dcd_ex1_thread_b),
      .f_dcd_ex7_fpscr_wr(f_dcd_ex7_fpscr_wr),
      .f_dcd_ex7_fpscr_addr(f_dcd_ex7_fpscr_addr),
      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b),

      .cp_axu_i0_t1_v(cp_axu_i0_t1_v),
      .cp_axu_i0_t0_t1_t(cp_axu_i0_t0_t1_t),
      .cp_axu_i0_t1_t1_t(cp_axu_i0_t1_t1_t),
      .cp_axu_i0_t0_t1_p(cp_axu_i0_t0_t1_p),
      .cp_axu_i0_t1_t1_p(cp_axu_i0_t1_t1_p),
      .cp_axu_i1_t1_v(cp_axu_i1_t1_v),
      .cp_axu_i1_t0_t1_t(cp_axu_i1_t0_t1_t),
      .cp_axu_i1_t1_t1_t(cp_axu_i1_t1_t1_t),
      .cp_axu_i1_t0_t1_p(cp_axu_i1_t0_t1_p),
      .cp_axu_i1_t1_t1_p(cp_axu_i1_t1_t1_p),
      //--------------------------------------------
      .vdd(vdd),
      .gnd(gnd),
      .scan_in(f_mad_si[0:18]),
      .scan_out(f_mad_so[0:18]),
      .clkoff_b(clkoff_dc_b),
      .act_dis(act_dis),
      .flush(pc_fu_ccflush_dc),
      .delay_lclkr(delay_lclkr_dc[1:7]),
      .mpw1_b(mpw1_dc_b[1:7]),
      .mpw2_b(mpw2_dc_b[0:1]),
      .sg_1(sg_1[0]),
      .thold_1(func_sl_thold_1[0]),
      .fpu_enable(fpu_enable),
      .f_dcd_ex1_act(f_dcd_ex1_mad_act),
      .nclk(nclk)
   );

   //Needed for RTX
   assign iu_fu_ex0_itag = rv_axu0_ex0_itag;
   assign iu_fu_rf0_instr_v = rv_axu0_vld;
   assign iu_fu_rf0_tid = rv_axu0_vld;		// one hot

   assign axu0_rv_hold_all = f_dcd_rv_hold_all_int;

   assign axu1_rv_hold_all = tidn;

   //----------------------------------------------------------------------
   // Control and Decode

   fu_dcd #(.ITAG_SIZE_ENC(`ITAG_SIZE_ENC), .EFF_IFAR(`EFF_IFAR), .REGMODE(`REGMODE), .THREAD_POOL_ENC(`THREAD_POOL_ENC), .CR_POOL_ENC(`CR_POOL_ENC), .THREADS(`THREADS)) dcd(
      // INPUTS
      .act_dis(act_dis),
      .bcfg_scan_in(bcfg_scan_in),
      .ccfg_scan_in(ccfg_scan_in),
      .cfg_sl_thold_1(cfg_sl_thold_1),
      .func_slp_sl_thold_1(func_slp_sl_thold_1),
      .clkoff_b(clkoff_dc_b),
      .cp_flush(cp_flush),
      .dcfg_scan_in(dcfg_scan_in),
	         // Trace/Debug Bus
      .debug_bus_in(debug_bus_in),
      .debug_bus_out(debug_bus_out),
      .coretrace_ctrls_in(coretrace_ctrls_in),
      .coretrace_ctrls_out(coretrace_ctrls_out),
      .event_bus_in(event_bus_in),
      .event_bus_out(event_bus_out),

      .f_dcd_perr_sm_running(f_dcd_perr_sm_running),
      .f_dcd_ex2_perr_force_c(f_dcd_ex2_perr_force_c),
      .f_dcd_ex2_perr_fsel_ovrd(f_dcd_ex2_perr_fsel_ovrd),


      .delay_lclkr(delay_lclkr_dc[0:9]),
      .f_add_ex5_fpcc_iu(f_add_ex5_fpcc_iu),
      .f_dcd_si(f_dcd_si),
      .f_dsq_ex5_divsqrt_itag(f_dsq_ex5_divsqrt_itag),
      .f_dsq_ex5_divsqrt_v(f_dsq_ex5_divsqrt_v),
      .f_dsq_ex6_divsqrt_cr_bf(f_dsq_ex6_divsqrt_cr_bf),
      .f_dsq_ex6_divsqrt_fpscr_addr(f_dsq_ex6_divsqrt_fpscr_addr),
      .f_dsq_ex6_divsqrt_instr_frt(f_dsq_ex6_divsqrt_instr_frt),
      .f_dsq_ex6_divsqrt_instr_tid(f_dsq_ex6_divsqrt_instr_tid),
      .f_dsq_ex6_divsqrt_record_v(f_dsq_ex6_divsqrt_record_v),
      .f_dsq_ex6_divsqrt_v(f_dsq_ex6_divsqrt_v),
      .f_dsq_ex6_divsqrt_v_suppress(f_dsq_ex6_divsqrt_v_suppress),
      .f_dsq_ex3_hangcounter_trigger(f_dsq_ex3_hangcounter_trigger_int),
      .f_dcd_rv_hold_all(f_dcd_rv_hold_all_int),
      .f_dsq_debug(f_dsq_debug),
      .f_ex3_b_den_flush(f_ex3_b_den_flush),
      .f_fpr_ex6_load_addr(f_fpr_ex6_load_addr),
      .f_fpr_ex6_load_v(f_fpr_ex6_load_v),
      .f_fpr_ex6_reload_addr(f_fpr_ex6_reload_addr),
      .f_fpr_ex6_reload_v(f_fpr_ex6_reload_v),
      .f_mad_ex3_a_parity_check(f_mad_ex3_a_parity_check),
      .f_mad_ex3_b_parity_check(f_mad_ex3_b_parity_check),
      .f_mad_ex3_c_parity_check(f_mad_ex3_c_parity_check),
      .f_mad_ex4_uc_res_sign(f_mad_ex4_uc_res_sign),
      .f_mad_ex4_uc_round_mode(f_mad_ex4_uc_round_mode),
      .f_mad_ex4_uc_special(f_mad_ex4_uc_special),
      .f_mad_ex4_uc_vxidi(f_mad_ex4_uc_vxidi),
      .f_mad_ex4_uc_vxsnan(f_mad_ex4_uc_vxsnan),
      .f_mad_ex4_uc_vxsqrt(f_mad_ex4_uc_vxsqrt),
      .f_mad_ex4_uc_vxzdz(f_mad_ex4_uc_vxzdz),
      .f_mad_ex4_uc_zx(f_mad_ex4_uc_zx),
      .f_mad_ex7_uc_sign(f_mad_ex7_uc_sign),
      .f_mad_ex7_uc_zero(f_mad_ex7_uc_zero),
      .f_pic_ex6_fpr_wr_dis_b(f_pic_ex6_fpr_wr_dis_b),
      .f_pic_ex6_scr_upd_move_b(f_pic_ex6_scr_upd_move_b),
      .f_rnd_ex7_res_expo(f_rnd_ex7_res_expo),
      .f_rnd_ex7_res_frac(f_rnd_ex7_res_frac),
      .f_rnd_ex7_res_sign(f_rnd_ex7_res_sign),
      .f_scr_cpl_fx_thread0(f_scr_cpl_fx_thread0),
      .f_scr_cpl_fx_thread1(f_scr_cpl_fx_thread1),
      .f_scr_ex8_cr_fld(f_scr_ex8_cr_fld),
      .f_scr_ex8_fx_thread0(f_scr_ex8_fx_thread0),
      .f_scr_ex8_fx_thread1(f_scr_ex8_fx_thread1),
      .f_scr_ex6_fpscr_ni_thr0(f_scr_ex6_fpscr_ni_thr0_int),
      .f_scr_ex6_fpscr_ni_thr1(f_scr_ex6_fpscr_ni_thr1_int),
      .f_sto_ex3_s_parity_check(f_sto_ex3_s_parity_check),
      .flush(pc_fu_ccflush_dc),
      .rv_axu0_ex0_t3_p(rv_axu0_ex0_t3_p),
      .iu_fu_rf0_tid(iu_fu_rf0_tid),
      .iu_fu_rf0_fra(rv_axu0_s1_p),
      .iu_fu_rf0_fra_v(rv_axu0_s1_v),
      .iu_fu_rf0_frb(rv_axu0_s2_p),
      .iu_fu_rf0_frb_v(rv_axu0_s2_v),
      .iu_fu_rf0_frc(rv_axu0_s3_p),
      .iu_fu_rf0_frc_v(rv_axu0_s3_v),
      .rv_axu0_ex0_t2_p(rv_axu0_ex0_t2_p),
      .iu_fu_rf0_instr_match(iu_fu_rf0_instr_match),
      .mpw1_b(mpw1_dc_b[0:9]),
      .mpw2_b(mpw2_dc_b[0:1]),
      .nclk(nclk),
      .pc_fu_debug_mux_ctrls(pc_fu_debug_mux_ctrls),
      .pc_fu_event_count_mode(pc_fu_event_count_mode),
      .pc_fu_ram_active(pc_fu_ram_active),
      .pc_fu_trace_bus_enable(pc_fu_trace_bus_enable),
      .pc_fu_event_bus_enable(pc_fu_event_bus_enable),
      .pc_fu_instr_trace_mode(pc_fu_instr_trace_mode),
      .pc_fu_instr_trace_tid(pc_fu_instr_trace_tid),
      .fu_lq_ex3_sto_parity_err(fu_lq_ex3_sto_parity_err),
      .rv_axu0_ex0_instr(rv_axu0_ex0_instr),
      .rv_axu0_ex0_itag(rv_axu0_ex0_itag),
      .rv_axu0_ex0_t1_p(rv_axu0_ex0_t1_p),
      .rv_axu0_ex0_t1_v(rv_axu0_ex0_t1_v),
      .rv_axu0_ex0_ucode(rv_axu0_ex0_ucode),
      .rv_axu0_vld(rv_axu0_vld),
      .sg_1(sg_1[1]),
      .slowspr_addr_in(slowspr_addr_in),
      .slowspr_data_in(slowspr_data_in),
      .slowspr_done_in(slowspr_done_in),
      .slowspr_etid_in(slowspr_etid_in),
      .slowspr_rw_in(slowspr_rw_in),
      .slowspr_val_in(slowspr_val_in),
      .thold_1(func_sl_thold_1[1]),

      .lq_fu_ex5_abort(lq_fu_ex5_abort),
      .fu_lq_ex3_abort(fu_lq_ex3_abort),
      .axu0_rv_ex2_s1_abort(axu0_rv_ex2_s1_abort),
      .axu0_rv_ex2_s2_abort(axu0_rv_ex2_s2_abort),
      .axu0_rv_ex2_s3_abort(axu0_rv_ex2_s3_abort),

      .xu_fu_ex4_eff_addr(lq_fu_ex4_eff_addr),
      .xu_fu_msr_fe0(xu_fu_msr_fe0),
      .xu_fu_msr_fe1(xu_fu_msr_fe1),
      .xu_fu_msr_fp(xu_fu_msr_fp),
      .xu_fu_msr_gs(xu_fu_msr_gs),
      .xu_fu_msr_pr(xu_fu_msr_pr),


      // INOUTS
      .vdd(vdd),
      .gnd(gnd),
      // OUTPUTS
      .axu0_cr_w4a(axu0_cr_w4a),
      .axu0_cr_w4d(axu0_cr_w4d),
      .axu0_cr_w4e(axu0_cr_w4e),
      .axu0_iu_async_fex(axu0_iu_async_fex),
      .axu0_iu_exception(axu0_iu_exception),
      .axu0_iu_exception_val(axu0_iu_exception_val),
      .axu0_iu_execute_vld(axu0_iu_execute_vld),
      .axu0_iu_flush2ucode(axu0_iu_flush2ucode),
      .axu0_iu_flush2ucode_type(axu0_iu_flush2ucode_type),
      .axu0_iu_itag(axu0_iu_itag),
      .axu0_iu_n_flush(axu0_iu_n_flush),
      .axu0_iu_n_np1_flush(axu0_iu_n_np1_flush),
      .axu0_iu_np1_flush(axu0_iu_np1_flush),
      .axu0_iu_perf_events(axu0_iu_perf_events_int),
      .axu0_rv_itag(axu0_rv_itag),
      .axu0_rv_itag_vld(axu0_rv_itag_vld),
      .axu0_rv_itag_abort(axu0_rv_itag_abort),
      .axu0_rv_ord_complete(axu0_rv_ord_complete),
      .axu1_iu_exception(axu1_iu_exception),
      .axu1_iu_exception_val(axu1_iu_exception_val),
      .axu1_iu_execute_vld(axu1_iu_execute_vld),
      .axu1_iu_flush2ucode(axu1_iu_flush2ucode),
      .axu1_iu_flush2ucode_type(axu1_iu_flush2ucode_type),
      .axu1_iu_itag(axu1_iu_itag),
      .axu1_iu_n_flush(axu1_iu_n_flush),
      .axu1_iu_np1_flush(axu1_iu_np1_flush),
      .axu1_rv_itag(axu1_rv_itag),
      .axu1_rv_itag_vld(axu1_rv_itag_vld),
      .axu1_rv_itag_abort(axu1_rv_itag_abort),
      .axu1_iu_perf_events(axu1_iu_perf_events_int),
      .bcfg_scan_out(bcfg_scan_out),
      .ccfg_scan_out(ccfg_scan_out),
      .dcfg_scan_out(dcfg_scan_out),
      .f_dcd_ex1_sto_act(f_dcd_ex1_sto_act),
      .f_dcd_ex1_mad_act(f_dcd_ex1_mad_act),
      .f_dcd_msr_fp_act(f_dcd_msr_fp_act),
      .f_dcd_ex1_aop_valid(f_dcd_ex1_aop_valid),
      .f_dcd_ex1_bop_valid(f_dcd_ex1_bop_valid),
      .f_dcd_ex1_thread(f_dcd_ex1_thread),
      .f_dcd_ex1_bypsel_a_load0(f_dcd_ex1_bypsel_a_load0),
      .f_dcd_ex1_bypsel_a_load1(f_dcd_ex1_bypsel_a_load1),
      .f_dcd_ex1_bypsel_a_load2(f_dcd_ex1_bypsel_a_load2),
      .f_dcd_ex1_bypsel_a_reload0(f_dcd_ex1_bypsel_a_reload0),
      .f_dcd_ex1_bypsel_a_reload1(f_dcd_ex1_bypsel_a_reload1),
      .f_dcd_ex1_bypsel_a_reload2(f_dcd_ex1_bypsel_a_reload2),

      .f_dcd_ex1_bypsel_a_res0(f_dcd_ex1_bypsel_a_res0),
      .f_dcd_ex1_bypsel_a_res1(f_dcd_ex1_bypsel_a_res1),
      .f_dcd_ex1_bypsel_a_res2(f_dcd_ex1_bypsel_a_res2),
      .f_dcd_ex1_bypsel_b_load0(f_dcd_ex1_bypsel_b_load0),
      .f_dcd_ex1_bypsel_b_load1(f_dcd_ex1_bypsel_b_load1),
      .f_dcd_ex1_bypsel_b_load2(f_dcd_ex1_bypsel_b_load2),
      .f_dcd_ex1_bypsel_b_reload0(f_dcd_ex1_bypsel_b_reload0),
      .f_dcd_ex1_bypsel_b_reload1(f_dcd_ex1_bypsel_b_reload1),
      .f_dcd_ex1_bypsel_b_reload2(f_dcd_ex1_bypsel_b_reload2),

      .f_dcd_ex1_bypsel_b_res0(f_dcd_ex1_bypsel_b_res0),
      .f_dcd_ex1_bypsel_b_res1(f_dcd_ex1_bypsel_b_res1),
      .f_dcd_ex1_bypsel_b_res2(f_dcd_ex1_bypsel_b_res2),
      .f_dcd_ex1_bypsel_c_load0(f_dcd_ex1_bypsel_c_load0),
      .f_dcd_ex1_bypsel_c_load1(f_dcd_ex1_bypsel_c_load1),
      .f_dcd_ex1_bypsel_c_load2(f_dcd_ex1_bypsel_c_load2),
      .f_dcd_ex1_bypsel_c_reload0(f_dcd_ex1_bypsel_c_reload0),
      .f_dcd_ex1_bypsel_c_reload1(f_dcd_ex1_bypsel_c_reload1),
      .f_dcd_ex1_bypsel_c_reload2(f_dcd_ex1_bypsel_c_reload2),

      .f_dcd_ex1_bypsel_c_res0(f_dcd_ex1_bypsel_c_res0),
      .f_dcd_ex1_bypsel_c_res1(f_dcd_ex1_bypsel_c_res1),
      .f_dcd_ex1_bypsel_c_res2(f_dcd_ex1_bypsel_c_res2),
      .f_dcd_ex1_bypsel_s_load0(f_dcd_ex1_bypsel_s_load0),
      .f_dcd_ex1_bypsel_s_load1(f_dcd_ex1_bypsel_s_load1),
      .f_dcd_ex1_bypsel_s_load2(f_dcd_ex1_bypsel_s_load2),
      .f_dcd_ex1_bypsel_s_reload0(f_dcd_ex1_bypsel_s_reload0),
      .f_dcd_ex1_bypsel_s_reload1(f_dcd_ex1_bypsel_s_reload1),
      .f_dcd_ex1_bypsel_s_reload2(f_dcd_ex1_bypsel_s_reload2),

      .f_dcd_ex1_bypsel_s_res0(f_dcd_ex1_bypsel_s_res0),
      .f_dcd_ex1_bypsel_s_res1(f_dcd_ex1_bypsel_s_res1),
      .f_dcd_ex1_bypsel_s_res2(f_dcd_ex1_bypsel_s_res2),
      .f_dcd_ex1_compare_b(f_dcd_ex1_compare_b),
      .f_dcd_ex1_cop_valid(f_dcd_ex1_cop_valid),
      .f_dcd_ex1_divsqrt_cr_bf(f_dcd_ex1_divsqrt_cr_bf),
      .f_dcd_axucr0_deno(f_dcd_axucr0_deno),
      .f_dcd_ex1_emin_dp(f_dcd_ex1_emin_dp),
      .f_dcd_ex1_emin_sp(f_dcd_ex1_emin_sp),
      .f_dcd_ex1_est_recip_b(f_dcd_ex1_est_recip_b),
      .f_dcd_ex1_est_rsqrt_b(f_dcd_ex1_est_rsqrt_b),
      .f_dcd_ex1_force_excp_dis(f_dcd_ex1_force_excp_dis),
      .f_dcd_ex1_force_pass_b(f_dcd_ex1_force_pass_b),
      .f_dcd_ex1_fpscr_addr(f_dcd_ex1_fpscr_addr),
      .f_dcd_ex1_fpscr_bit_data_b(f_dcd_ex1_fpscr_bit_data_b),
      .f_dcd_ex1_fpscr_bit_mask_b(f_dcd_ex1_fpscr_bit_mask_b),
      .f_dcd_ex1_fpscr_nib_mask_b(f_dcd_ex1_fpscr_nib_mask_b),
      .f_dcd_ex1_from_integer_b(f_dcd_ex1_from_integer_b),
      .f_dcd_ex1_frsp_b(f_dcd_ex1_frsp_b),
      .f_dcd_ex1_fsel_b(f_dcd_ex1_fsel_b),
      .f_dcd_ex1_ftdiv(f_dcd_ex1_ftdiv),
      .f_dcd_ex1_ftsqrt(f_dcd_ex1_ftsqrt),
      .f_dcd_ex1_instr_frt(f_dcd_ex1_instr_frt),
      .f_dcd_ex1_instr_tid(f_dcd_ex1_instr_tid),
      .f_dcd_ex1_inv_sign_b(f_dcd_ex1_inv_sign_b),
      .f_dcd_ex1_itag(f_dcd_ex1_itag),
      .f_dcd_ex1_log2e_b(f_dcd_ex1_log2e_b),
      .f_dcd_ex1_math_b(f_dcd_ex1_math_b),
      .f_dcd_ex1_mcrfs_b(f_dcd_ex1_mcrfs_b),
      .f_dcd_ex1_move_b(f_dcd_ex1_move_b),
      .f_dcd_ex1_mtfsbx_b(f_dcd_ex1_mtfsbx_b),
      .f_dcd_ex1_mtfsf_b(f_dcd_ex1_mtfsf_b),
      .f_dcd_ex1_mtfsfi_b(f_dcd_ex1_mtfsfi_b),
      .f_dcd_ex1_mv_from_scr_b(f_dcd_ex1_mv_from_scr_b),
      .f_dcd_ex1_mv_to_scr_b(f_dcd_ex1_mv_to_scr_b),
      .f_dcd_ex1_nj_deni(f_dcd_ex1_nj_deni),
      .f_dcd_ex1_nj_deno(f_dcd_ex1_nj_deno),
      .f_dcd_ex1_op_rnd_b(f_dcd_ex1_op_rnd_b),
      .f_dcd_ex1_op_rnd_v_b(f_dcd_ex1_op_rnd_v_b),
      .f_dcd_ex1_ordered_b(f_dcd_ex1_ordered_b),
      .f_dcd_ex1_pow2e_b(f_dcd_ex1_pow2e_b),
      .f_dcd_ex1_prenorm_b(f_dcd_ex1_prenorm_b),
      .f_dcd_ex1_rnd_to_int_b(f_dcd_ex1_rnd_to_int_b),
      .f_dcd_ex1_sgncpy_b(f_dcd_ex1_sgncpy_b),
      .f_dcd_ex1_sign_ctl_b(f_dcd_ex1_sign_ctl_b),
      .f_dcd_ex1_sp(f_dcd_ex1_sp),
      .f_dcd_ex1_sp_conv_b(f_dcd_ex1_sp_conv_b),
      .f_dcd_ex1_sto_dp(f_dcd_ex1_sto_dp),
      .f_dcd_ex1_sto_sp(f_dcd_ex1_sto_sp),
      .f_dcd_ex1_sto_wd(f_dcd_ex1_sto_wd),
      .f_dcd_ex1_sub_op_b(f_dcd_ex1_sub_op_b),
      .f_dcd_ex1_thread_b(f_dcd_ex1_thread_b),
      .f_dcd_ex1_to_integer_b(f_dcd_ex1_to_integer_b),
      .f_dcd_ex1_uc_end(f_dcd_ex1_uc_end),
      .f_dcd_ex1_uc_fa_pos(f_dcd_ex1_uc_fa_pos),
      .f_dcd_ex1_uc_fb_0_5(f_dcd_ex1_uc_fb_0_5),
      .f_dcd_ex1_uc_fb_0_75(f_dcd_ex1_uc_fb_0_75),
      .f_dcd_ex1_uc_fb_1_0(f_dcd_ex1_uc_fb_1_0),
      .f_dcd_ex1_uc_fb_pos(f_dcd_ex1_uc_fb_pos),
      .f_dcd_ex1_uc_fc_0_5(f_dcd_ex1_uc_fc_0_5),
      .f_dcd_ex1_uc_fc_1_0(f_dcd_ex1_uc_fc_1_0),
      .f_dcd_ex1_uc_fc_1_minus(f_dcd_ex1_uc_fc_1_minus),
      .f_dcd_ex1_uc_fc_hulp(f_dcd_ex1_uc_fc_hulp),
      .f_dcd_ex1_uc_fc_pos(f_dcd_ex1_uc_fc_pos),
      .f_dcd_ex1_uc_ft_neg(f_dcd_ex1_uc_ft_neg),
      .f_dcd_ex1_uc_ft_pos(f_dcd_ex1_uc_ft_pos),
      .f_dcd_ex1_uc_mid(f_dcd_ex1_uc_mid),
      .f_dcd_ex1_uc_special(f_dcd_ex1_uc_special),
      .f_dcd_ex1_uns_b(f_dcd_ex1_uns_b),
      .f_dcd_ex1_word_b(f_dcd_ex1_word_b),
      .f_dcd_ex2_divsqrt_v(f_dcd_ex2_divsqrt_v),
      .f_dcd_ex2_divsqrt_hole_v(f_dcd_ex2_divsqrt_hole_v),
      .f_dcd_ex3_uc_gs(f_dcd_ex3_uc_gs),
      .f_dcd_ex3_uc_gs_v(f_dcd_ex3_uc_gs_v),
      .f_dcd_ex3_uc_inc_lsb(f_dcd_ex3_uc_inc_lsb),
      .f_dcd_ex3_uc_vxidi(f_dcd_ex3_uc_vxidi),
      .f_dcd_ex3_uc_vxsnan(f_dcd_ex3_uc_vxsnan),
      .f_dcd_ex3_uc_vxsqrt(f_dcd_ex3_uc_vxsqrt),
      .f_dcd_ex3_uc_vxzdz(f_dcd_ex3_uc_vxzdz),
      .f_dcd_ex3_uc_zx(f_dcd_ex3_uc_zx),
      .f_dcd_ex6_frt_tid(f_dcd_ex6_frt_tid),
      .f_dcd_ex7_cancel(f_dcd_ex7_cancel),
      .f_dcd_ex7_fpscr_addr(f_dcd_ex7_fpscr_addr),
      .f_dcd_ex7_fpscr_wr(f_dcd_ex7_fpscr_wr),
      .f_dcd_ex7_frt_addr(f_dcd_ex7_frt_addr),
      .f_dcd_ex7_frt_tid(f_dcd_ex7_frt_tid),
      .f_dcd_ex7_frt_wen(f_dcd_ex7_frt_wen),
      .f_dcd_flush(f_dcd_flush),
      .f_dcd_rf0_fra(f_dcd_rf0_fra),
      .f_dcd_rf0_frb(f_dcd_rf0_frb),
      .f_dcd_rf0_frc(f_dcd_rf0_frc),
      .f_dcd_rf0_tid(f_dcd_rf0_tid),
      .f_dcd_ex0_div(f_dcd_ex0_div),
      .f_dcd_ex0_divs(f_dcd_ex0_divs),
      .f_dcd_ex0_record_v(f_dcd_ex0_record_v),
      .f_dcd_ex0_sqrt(f_dcd_ex0_sqrt),
      .f_dcd_ex0_sqrts(f_dcd_ex0_sqrts),
      .f_dcd_ex1_sto_v(f_dcd_ex1_sto_v),
      .f_dcd_so(f_dcd_so),
      .fu_lq_ex2_store_data_val(fu_lq_ex2_store_data_val),
      .fu_lq_ex2_store_itag(fu_lq_ex2_store_itag),
      .fu_pc_err_regfile_parity(fu_pc_err_regfile_parity),
      .fu_pc_err_regfile_ue(fu_pc_err_regfile_ue),

      .fu_pc_ram_data(fu_pc_ram_data),
      .fu_pc_ram_data_val(fu_pc_ram_data_val),

      .slowspr_addr_out(slowspr_addr_out),
      .slowspr_data_out(slowspr_data_out),
      .slowspr_done_out(slowspr_done_out),
      .slowspr_etid_out(slowspr_etid_out),
      .slowspr_rw_out(slowspr_rw_out),
      .slowspr_val_out(slowspr_val_out),

      .rf0_act_b(rf0_act_b)
   );

   assign axu0_iu_perf_events = axu0_iu_perf_events_int;
   assign axu1_iu_perf_events = axu1_iu_perf_events_int;

   //----------------------------------------------------------------------
   // Scan Chains

   assign f_fpr_si = func_scan_in[0];
   assign f_sto_si = f_fpr_so;
   assign f_dcd_si = f_sto_so;
   assign func_scan_out[0] = tc_ac_scan_dis_dc_b & f_dcd_so;

   assign f_mad_si[0] = func_scan_in[1];
   assign f_mad_si[1] = f_mad_so[0];
   assign f_mad_si[2] = f_mad_so[1];
   assign f_mad_si[3] = f_mad_so[2];
   assign f_mad_si[4] = f_mad_so[3];
   assign f_mad_si[5] = f_mad_so[4];
   assign func_scan_out[1] = tc_ac_scan_dis_dc_b & f_mad_so[5];

   assign f_mad_si[6] = func_scan_in[2];
   assign f_mad_si[7] = f_mad_so[6];
   assign f_mad_si[8] = f_mad_so[7];
   assign f_mad_si[9] = f_mad_so[8];
   assign f_mad_si[10] = f_mad_so[9];
   assign f_mad_si[11] = f_mad_so[10];
   assign func_scan_out[2] = tc_ac_scan_dis_dc_b & f_mad_so[11];

   assign f_mad_si[12] = func_scan_in[3];
   assign f_mad_si[13] = f_mad_so[12];
   assign f_mad_si[14] = f_mad_so[13];
   assign f_mad_si[15] = f_mad_so[14];
   assign f_mad_si[16] = f_mad_so[15];
   assign f_mad_si[17] = f_mad_so[16];
   assign f_mad_si[18] = f_mad_so[17];

   assign f_rv_si = f_mad_so[18];
   assign f_rv_so = f_rv_si;

   assign func_scan_out[3] = tc_ac_scan_dis_dc_b & f_rv_so;

endmodule
