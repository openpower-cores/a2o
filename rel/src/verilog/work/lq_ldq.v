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

//
//  Description:  XU LSU Store Data Rotator Wrapper
//
//*****************************************************************************

// ##########################################################################################
// Contents
// 1) Load Queue
// 2) Store Queue
// 3) Load/Store Queue Control
// ##########################################################################################

`include "tri_a2o.vh"

module lq_ldq(
   rv_lq_vld,
   rv_lq_isLoad,
   rv_lq_rvs_empty,
   ctl_lsq_rv1_dir_rd_val,
   l2_back_inv_val,
   l2_back_inv_addr,
   ctl_lsq_ex3_ldreq_val,
   ctl_lsq_ex3_pfetch_val,
   ctl_lsq_ex4_ldreq_val,
   ctl_lsq_ex4_streq_val,
   ctl_lsq_ex4_othreq_val,
   ctl_lsq_ex4_p_addr,
   ctl_lsq_ex4_itag,
   ctl_lsq_ex4_dReq_val,
   ctl_lsq_ex4_gath_load,
   ctl_lsq_ex4_wimge,
   ctl_lsq_ex4_is_sync,
   ctl_lsq_ex4_all_thrd_chk,
   ctl_lsq_ex4_byte_swap,
   ctl_lsq_ex4_is_resv,
   ctl_lsq_ex4_thrd_id,
   ctl_lsq_ex5_lock_set,
   ctl_lsq_ex5_watch_set,
   ctl_lsq_ex5_thrd_id,
   ctl_lsq_ex5_load_hit,
   ctl_lsq_ex5_opsize,
   ctl_lsq_ex5_tgpr,
   ctl_lsq_ex5_axu_val,
   ctl_lsq_ex5_usr_def,
   ctl_lsq_ex5_drop_rel,
   ctl_lsq_ex5_flush_req,
   ctl_lsq_ex5_flush_pfetch,
   ctl_lsq_ex5_cmmt_events,
   ctl_lsq_ex5_perf_val0,
   ctl_lsq_ex5_perf_sel0,
   ctl_lsq_ex5_perf_val1,
   ctl_lsq_ex5_perf_sel1,
   ctl_lsq_ex5_perf_val2,
   ctl_lsq_ex5_perf_sel2,
   ctl_lsq_ex5_perf_val3,
   ctl_lsq_ex5_perf_sel3,
   ctl_lsq_ex5_not_touch,
   ctl_lsq_ex5_algebraic,
   ctl_lsq_ex5_class_id,
   ctl_lsq_ex5_dvc,
   ctl_lsq_ex5_ttype,
   ctl_lsq_ex5_dacrw,
   lsq_ctl_ex6_ldq_events,
   lsq_perv_ex7_events,
   lsq_perv_ldq_events,
   ctl_lsq_ex7_thrd_id,
   ctl_lsq_pf_empty,
   ctl_lsq_spr_dvc1_dbg,
   ctl_lsq_spr_dvc2_dbg,
   ctl_lsq_spr_dbcr2_dvc1m,
   ctl_lsq_spr_dbcr2_dvc1be,
   ctl_lsq_spr_dbcr2_dvc2m,
   ctl_lsq_spr_dbcr2_dvc2be,
   ctl_lsq_dbg_int_en,
   ctl_lsq_ldp_idle,
   stq_ldq_ex5_stq_restart,
   stq_ldq_ex5_stq_restart_miss,
   stq_ldq_ex5_fwd_val,
   odq_ldq_resolved,
   odq_ldq_report_needed,
   odq_ldq_report_itag,
   odq_ldq_n_flush,
   odq_ldq_np1_flush,
   odq_ldq_report_tid,
   odq_ldq_report_dacrw,
   odq_ldq_report_eccue,
   odq_ldq_report_pEvents,
   odq_ldq_oldest_ld_tid,
   odq_ldq_oldest_ld_itag,
   odq_ldq_ex7_pfetch_blk,
   stq_ldq_empty,
   iu_lq_cp_flush,
   iu_lq_cp_next_itag,
   arb_ldq_ldq_unit_sel,
   l2_lsq_resp_isComing,
   l2_lsq_resp_val,
   l2_lsq_resp_cTag,
   l2_lsq_resp_qw,
   l2_lsq_resp_crit_qw,
   l2_lsq_resp_l1_dump,
   l2_lsq_resp_data,
   l2_lsq_resp_ecc_err,
   l2_lsq_resp_ecc_err_ue,
   xu_lq_spr_xucr0_cls,
   ctl_lsq_spr_lsucr0_lge,
   ctl_lsq_spr_lsucr0_lca,
   pc_lq_inj_relq_parity,
   ldq_stq_rel1_blk_store,
   ldq_stq_ex5_ldm_hit,
   ldq_stq_ex5_ldm_entry,
   ldq_stq_ldm_cpl,
   ldq_stq_stq4_dir_upd,
   ldq_stq_stq4_cclass,
   lq_rv_itag2_vld,
   lq_rv_itag2,
   ldq_rel2_byte_swap,
   ldq_rel2_data,
   ldq_odq_vld,
   ldq_odq_pfetch_vld,
   ldq_odq_wimge_i,
   ldq_odq_ex6_pEvents,
   ldq_odq_upd_val,
   ldq_odq_upd_itag,
   ldq_odq_upd_nFlush,
   ldq_odq_upd_np1Flush,
   ldq_odq_upd_tid,
   ldq_odq_upd_dacrw,
   ldq_odq_upd_eccue,
   ldq_odq_upd_pEvents,
   lq1_iu_execute_vld,
   lq1_iu_itag,
   lq1_iu_exception_val,
   lq1_iu_exception,
   lq1_iu_n_flush,
   lq1_iu_np1_flush,
   lq1_iu_dacr_type,
   lq1_iu_dacrw,
   lq1_iu_perf_events,
   ldq_hold_all_req,
   ldq_rv_set_hold,
   ldq_rv_clr_hold,
   lsq_ctl_ex5_ldq_restart,
   ldq_arb_ld_req_pwrToken,
   ldq_arb_ld_req_avail,
   ldq_arb_tid,
   ldq_arb_usr_def,
   ldq_arb_wimge,
   ldq_arb_p_addr,
   ldq_arb_ttype,
   ldq_arb_opsize,
   ldq_arb_cTag,
   ldq_dat_stq1_stg_act,
   lsq_dat_rel1_data_val,
   lsq_dat_rel1_qw,
   ldq_ctl_stq1_stg_act,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_data_val,
   lsq_ctl_rel1_thrd_id,
   lsq_ctl_rel1_back_inv,
   lsq_ctl_rel1_tag,
   lsq_ctl_rel1_classid,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_watch_set,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_rel2_upd_val,
   lsq_ctl_rel3_l1dump_val,
   lsq_ctl_rel3_clr_relq,
   ldq_arb_rel1_data_sel,
   ldq_arb_rel1_axu_val,
   ldq_arb_rel1_op_size,
   ldq_arb_rel1_addr,
   ldq_arb_rel1_ci,
   ldq_arb_rel1_byte_swap,
   ldq_arb_rel1_thrd_id,
   ldq_arb_rel1_data,
   ldq_arb_rel2_rdat_sel,
   ldq_arb_rel2_rd_data,
   arb_ldq_rel2_wrt_data,
   lsq_ctl_rel1_gpr_val,
   lsq_ctl_rel1_ta_gpr,
   lsq_ctl_rel1_upd_gpr,
   lq_pc_err_invld_reld,
   lq_pc_err_l2intrf_ecc,
   lq_pc_err_l2intrf_ue,
   lq_pc_err_relq_parity,
   lq_mm_lmq_stq_empty,
   lq_xu_quiesce,
   lq_pc_ldq_quiesce,
   lq_pc_stq_quiesce,
   lq_pc_pfetch_quiesce,
   bo_enable_2,
   clkoff_dc_b,
   g8t_clkoff_dc_b,
   g8t_d_mode_dc,
   g8t_delay_lclkr_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   pc_lq_ccflush_dc,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_lq_abist_ena_dc,
   pc_lq_abist_raw_dc_b,
   pc_lq_abist_wl64_comp_ena,
   pc_lq_abist_raddr_0,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_bo_unload,
   pc_lq_bo_repair,
   pc_lq_bo_reset,
   pc_lq_bo_shdata,
   pc_lq_bo_select,
   lq_pc_bo_fail,
   lq_pc_bo_diagout,
   vcs,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_nsl_thold_0_b,
   func_nsl_force,
   abst_sl_thold_0,
   ary_nsl_thold_0,
   time_sl_thold_0,
   repr_sl_thold_0,
   bolt_sl_thold_0,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   scan_out,
   abst_scan_out,
   time_scan_out,
   repr_scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                               EXPAND_TYPE = 2;		   // 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//parameter                                               `THREADS = 2;		      // Number of `THREADS in the System
//parameter                                               `GPR_WIDTH_ENC = 6;		// Register Mode 5 = 32bit, 6 = 64bit
//parameter                                               `GPR_POOL_ENC = 6;
//parameter                                               `AXU_SPARE_ENC = 3;
//parameter                                               `THREADS_POOL_ENC = 1;
//parameter                                               `LMQ_ENTRIES = 8;		// Load/Store Queue Size
//parameter                                               `LGQ_ENTRIES = 8;		// Load Gather Queue Size
//parameter                                               `ITAG_SIZE_ENC = 7;		// ITAG size
//parameter                                               `DC_SIZE = 15;		   // 14 => 16K L1D$, 15 => 32K L1D$
//parameter                                               `CL_SIZE = 6;		      // 6 => 64B CLINE, 7 => 128B CLINE
//parameter                                               `REAL_IFAR_WIDTH = 42;	// real addressing bits

// RV1 RV Issue Valid
input [0:`THREADS-1]                                        rv_lq_vld;
input                                                       rv_lq_isLoad;

// RV is empty indicator
input [0:`THREADS-1]                                        rv_lq_rvs_empty;

// SPR Directory Read Valid
input                                                       ctl_lsq_rv1_dir_rd_val;

// Back-Invalidate Valid
input                                                       l2_back_inv_val;
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                     l2_back_inv_addr;

// Load Request Interface
input                                                       ctl_lsq_ex3_ldreq_val;
input                                                       ctl_lsq_ex3_pfetch_val;
input                                                       ctl_lsq_ex4_ldreq_val;
input                                                       ctl_lsq_ex4_streq_val;
input                                                       ctl_lsq_ex4_othreq_val;
input [64-`REAL_IFAR_WIDTH:63]                              ctl_lsq_ex4_p_addr;
input [0:`ITAG_SIZE_ENC-1]                                  ctl_lsq_ex4_itag;
input                                                       ctl_lsq_ex4_dReq_val;
input                                                       ctl_lsq_ex4_gath_load;
input [0:4]                                                 ctl_lsq_ex4_wimge;
input                                                       ctl_lsq_ex4_is_sync;
input                                                       ctl_lsq_ex4_all_thrd_chk;
input                                                       ctl_lsq_ex4_byte_swap;
input                                                       ctl_lsq_ex4_is_resv;
input [0:`THREADS-1]                                        ctl_lsq_ex4_thrd_id;
input                                                       ctl_lsq_ex5_lock_set;
input                                                       ctl_lsq_ex5_watch_set;
input [0:`THREADS-1]                                        ctl_lsq_ex5_thrd_id;
input                                                       ctl_lsq_ex5_load_hit;
input [0:2]                                                 ctl_lsq_ex5_opsize;
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  ctl_lsq_ex5_tgpr;
input                                                       ctl_lsq_ex5_axu_val;		// XU,AXU type operation
input [0:3]                                                 ctl_lsq_ex5_usr_def;
input                                                       ctl_lsq_ex5_drop_rel;		// L2 only instructions
input                                                       ctl_lsq_ex5_flush_req;		// Flush request from LDQ/STQ
input                                                       ctl_lsq_ex5_flush_pfetch;   // Flush Prefetch in EX5
input [0:10]                                                ctl_lsq_ex5_cmmt_events;
input                                                       ctl_lsq_ex5_perf_val0;
input [0:3]                                                 ctl_lsq_ex5_perf_sel0;
input                                                       ctl_lsq_ex5_perf_val1;
input [0:3]                                                 ctl_lsq_ex5_perf_sel1;
input                                                       ctl_lsq_ex5_perf_val2;
input [0:3]                                                 ctl_lsq_ex5_perf_sel2;
input                                                       ctl_lsq_ex5_perf_val3;
input [0:3]                                                 ctl_lsq_ex5_perf_sel3;
input                                                       ctl_lsq_ex5_not_touch;
input                                                       ctl_lsq_ex5_algebraic;
input [0:1]                                                 ctl_lsq_ex5_class_id;
input [0:1]                                                 ctl_lsq_ex5_dvc;
input [0:5]                                                 ctl_lsq_ex5_ttype;
input [0:3]                                                 ctl_lsq_ex5_dacrw;
output [0:3]                                                lsq_ctl_ex6_ldq_events;       // LDQ Pipeline Performance Events
output [0:`THREADS-1]                                       lsq_perv_ex7_events;          // LDQ Pipeline Performance Events
output [0:(2*`THREADS)+3]                                   lsq_perv_ldq_events;          // REL Pipeline Performance Events
input [0:`THREADS-1]                                        ctl_lsq_ex7_thrd_id;

input [0:`THREADS-1]                                        ctl_lsq_pf_empty;

// Interface with Local SPR's
input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc1_dbg;
input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc2_dbg;
input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1m;
input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1be;
input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2m;
input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2be;
input [0:`THREADS-1]                                        ctl_lsq_dbg_int_en;
input [0:`THREADS-1]                                        ctl_lsq_ldp_idle;

input                                                       stq_ldq_ex5_stq_restart;
input                                                       stq_ldq_ex5_stq_restart_miss;
input                                                       stq_ldq_ex5_fwd_val;

// OrderQ Inputs
input                                                       odq_ldq_resolved;
input                                                       odq_ldq_report_needed;
input [0:`ITAG_SIZE_ENC-1]                                  odq_ldq_report_itag;
input                                                       odq_ldq_n_flush;
input                                                       odq_ldq_np1_flush;
input [0:`THREADS-1]                                        odq_ldq_report_tid;
input [0:3]                                                 odq_ldq_report_dacrw;
input                                                       odq_ldq_report_eccue;
input [0:3]                                                 odq_ldq_report_pEvents;
input [0:`THREADS-1]                                        odq_ldq_oldest_ld_tid;
input [0:`ITAG_SIZE_ENC-1]                                  odq_ldq_oldest_ld_itag;
input                                                       odq_ldq_ex7_pfetch_blk;

// Store Queue is Empty
input [0:`THREADS-1]                                        stq_ldq_empty;

// Completion Inputs
input [0:`THREADS-1]                                        iu_lq_cp_flush;
input [0:`ITAG_SIZE_ENC*`THREADS-1]                         iu_lq_cp_next_itag;

// L2 Request Sent
input                                                       arb_ldq_ldq_unit_sel;

// L2 Reload
input                                                       l2_lsq_resp_isComing;
input                                                       l2_lsq_resp_val;
input [0:4]                                                 l2_lsq_resp_cTag;
input [57:59]                                               l2_lsq_resp_qw;
input                                                       l2_lsq_resp_crit_qw;
input                                                       l2_lsq_resp_l1_dump;
input [0:127]                                               l2_lsq_resp_data;
input                                                       l2_lsq_resp_ecc_err;
input                                                       l2_lsq_resp_ecc_err_ue;

// Data Cache Config
input                                                       xu_lq_spr_xucr0_cls;		// Data Cache Line Size Mode

// Load Gather Enable Config
input                                                       ctl_lsq_spr_lsucr0_lge;
input [0:2]                                                 ctl_lsq_spr_lsucr0_lca;

// Inject Reload Data Array Parity Error
input                                                       pc_lq_inj_relq_parity;

// Interface to Store Queue
output                                                      ldq_stq_rel1_blk_store;

// Store Hit LoadMiss Queue Entries
output [0:`LMQ_ENTRIES-1]                                   ldq_stq_ex5_ldm_hit;
output [0:`LMQ_ENTRIES-1]                                   ldq_stq_ex5_ldm_entry;
output [0:`LMQ_ENTRIES-1]                                   ldq_stq_ldm_cpl;

// Directory Congruence Class Updated
output                                                      ldq_stq_stq4_dir_upd;
output [64-(`DC_SIZE-3):57]                                 ldq_stq_stq4_cclass;

// RV Reload Release Dependent ITAGs
output [0:`THREADS-1]                                       lq_rv_itag2_vld;
output [0:`ITAG_SIZE_ENC-1]                                 lq_rv_itag2;

// Physical Register File update data for Reloads
output                                                      ldq_rel2_byte_swap;
output [0:127]                                              ldq_rel2_data;

// Load/Store Request was not restarted
output                                                      ldq_odq_vld;
output                                                      ldq_odq_pfetch_vld;
output                                                      ldq_odq_wimge_i;
output [0:3]                                                ldq_odq_ex6_pEvents;

// Update Order Queue Entry when reload is complete and itag is not resolved
output                                                      ldq_odq_upd_val;
output [0:`ITAG_SIZE_ENC-1]                                 ldq_odq_upd_itag;
output                                                      ldq_odq_upd_nFlush;
output                                                      ldq_odq_upd_np1Flush;
output [0:`THREADS-1]                                       ldq_odq_upd_tid;
output [0:3]                                                ldq_odq_upd_dacrw;
output                                                      ldq_odq_upd_eccue;
output [0:3]                                                ldq_odq_upd_pEvents;

// Interface to Completion
output [0:`THREADS-1]                                       lq1_iu_execute_vld;
output [0:`ITAG_SIZE_ENC-1]                                 lq1_iu_itag;
output                                                      lq1_iu_exception_val;
output [0:5]                                                lq1_iu_exception;
output                                                      lq1_iu_n_flush;
output                                                      lq1_iu_np1_flush;
output                                                      lq1_iu_dacr_type;
output [0:3]                                                lq1_iu_dacrw;
output [0:3]                                                lq1_iu_perf_events;

// Reservation station hold indicator
output                                                      ldq_hold_all_req;

// Reservation station set barrier indicator
output                                                      ldq_rv_set_hold;
output [0:`THREADS-1]                                       ldq_rv_clr_hold;

// LOADMISS Queue RESTART indicator
output                                                      lsq_ctl_ex5_ldq_restart;

// LDQ Request to the L2
output                                                      ldq_arb_ld_req_pwrToken;
output                                                      ldq_arb_ld_req_avail;
output [0:1]                                                ldq_arb_tid;
output [0:3]                                                ldq_arb_usr_def;
output [0:4]                                                ldq_arb_wimge;
output [64-`REAL_IFAR_WIDTH:63]                             ldq_arb_p_addr;
output [0:5]                                                ldq_arb_ttype;
output [0:2]                                                ldq_arb_opsize;
output [0:4]                                                ldq_arb_cTag;

// RELOAD Data Control
output                                                      ldq_dat_stq1_stg_act;		// ACT Pin for DAT
output                                                      lsq_dat_rel1_data_val;
output [57:59]                                              lsq_dat_rel1_qw;		      // RELOAD Data Quadword

// RELOAD Directory Control
output                                                      ldq_ctl_stq1_stg_act;		// ACT Pin for CTL
output                                                      lsq_ctl_rel1_clr_val;		// Reload Data is valid, need to Pick a Way to update
output                                                      lsq_ctl_rel1_set_val;		// Reload Data is valid for last beat, update Directory Contents and set Valid
output                                                      lsq_ctl_rel1_data_val;		// Reload Data is Valid, need to update Way in Data Cache
output [0:`THREADS-1]                                       lsq_ctl_rel1_thrd_id;		// Reload Thread ID for initial requester
output                                                      lsq_ctl_rel1_back_inv;		// Reload was Back-Invalidated
output [0:3]                                                lsq_ctl_rel1_tag;		      // Reload Tag
output [0:1]                                                lsq_ctl_rel1_classid;		// Used to index into xucr2 RMT table
output                                                      lsq_ctl_rel1_lock_set;		// Reload is for a dcbt[st]ls instruction
output                                                      lsq_ctl_rel1_watch_set;		// Reload is for a ldawx. instruction
output                                                      lsq_ctl_rel2_blk_req;		// Block Reload due to RV issue or Back-Invalidate
output                                                      lsq_ctl_rel2_upd_val;		// all 8 data beats have transferred without error, set valid in dir
output                                                      lsq_ctl_rel3_l1dump_val;	// Reload Complete for an L1_DUMP reload
output                                                      lsq_ctl_rel3_clr_relq;		// Reload Complete due to an ECC error

// Control Common to Reload and Commit Pipes
output                                                      ldq_arb_rel1_data_sel;
output                                                      ldq_arb_rel1_axu_val;
output [0:2]                                                ldq_arb_rel1_op_size;
output [64-`REAL_IFAR_WIDTH:63]                             ldq_arb_rel1_addr;
output                                                      ldq_arb_rel1_ci;
output                                                      ldq_arb_rel1_byte_swap;
output [0:`THREADS-1]                                       ldq_arb_rel1_thrd_id;
output [0:127]                                              ldq_arb_rel1_data;
output                                                      ldq_arb_rel2_rdat_sel;
output [0:143]                                              ldq_arb_rel2_rd_data;
input [0:143]                                               arb_ldq_rel2_wrt_data;

// RELOAD Register Control
output                                                      lsq_ctl_rel1_gpr_val;		// Critical Quadword requires an update of the Regfile
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lsq_ctl_rel1_ta_gpr;		   // Reload Target Register
output                                                      lsq_ctl_rel1_upd_gpr;		// Critical Quadword did not get and ECC error in REL1

// Interface to Pervasive Unit
output                                                      lq_pc_err_invld_reld;		// Reload detected without Loadmiss waiting for reload or got extra beats for cacheable request
output                                                      lq_pc_err_l2intrf_ecc;		// Reload detected with an ECC error
output                                                      lq_pc_err_l2intrf_ue;		// Reload detected with an uncorrectable ECC error
output                                                      lq_pc_err_relq_parity;     // Reload Data Queue Parity Error Detected

// Thread Quiesced
output [0:`THREADS-1]                                       lq_xu_quiesce;		         // Thread is Quiesced
output [0:`THREADS-1]                                       lq_pc_ldq_quiesce;
output [0:`THREADS-1]                                       lq_pc_stq_quiesce;
output [0:`THREADS-1]                                       lq_pc_pfetch_quiesce;

// Interface to MMU
output                                                      lq_mm_lmq_stq_empty;       // Load and Store Queue is empty

// Array Pervasive Controls
input                                                       bo_enable_2;
input                                                       clkoff_dc_b;
input                                                       g8t_clkoff_dc_b;
input                                                       g8t_d_mode_dc;
input [0:4]                                                 g8t_delay_lclkr_dc;
input [0:4]                                                 g8t_mpw1_dc_b;
input                                                       g8t_mpw2_dc_b;
input                                                       pc_lq_ccflush_dc;
input                                                       an_ac_scan_dis_dc_b;
input                                                       an_ac_scan_diag_dc;
input                                                       an_ac_lbist_ary_wrt_thru_dc;
input                                                       pc_lq_abist_ena_dc;
input                                                       pc_lq_abist_raw_dc_b;
input                                                       pc_lq_abist_wl64_comp_ena;
input [3:8]                                                 pc_lq_abist_raddr_0;
input                                                       pc_lq_abist_g8t_wenb;
input                                                       pc_lq_abist_g8t1p_renb_0;
input [0:3]                                                 pc_lq_abist_g8t_dcomp;
input                                                       pc_lq_abist_g8t_bw_1;
input                                                       pc_lq_abist_g8t_bw_0;
input [0:3]                                                 pc_lq_abist_di_0;
input [4:9]                                                 pc_lq_abist_waddr_0;
input                                                       pc_lq_bo_unload;
input                                                       pc_lq_bo_repair;
input                                                       pc_lq_bo_reset;
input                                                       pc_lq_bo_shdata;
input [8:9]                                                 pc_lq_bo_select;
output [8:9]                                                lq_pc_bo_fail;
output [8:9]                                                lq_pc_bo_diagout;

// Pervasive
inout                                                       vcs;
inout                                                       vdd;
inout                                                       gnd;
(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]                                     nclk;
input                                                       sg_0;
input                                                       func_sl_thold_0_b;
input                                                       func_sl_force;
input                                                       func_nsl_thold_0_b;
input                                                       func_nsl_force;
input                                                       abst_sl_thold_0;
input                                                       ary_nsl_thold_0;
input                                                       time_sl_thold_0;
input                                                       repr_sl_thold_0;
input                                                       bolt_sl_thold_0;
input                                                       d_mode_dc;
input                                                       delay_lclkr_dc;
input                                                       mpw1_dc_b;
input                                                       mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       abst_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       time_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
input                                                       repr_scan_in;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      abst_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      time_scan_out;
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
output                                                      repr_scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// signals
//--------------------------
parameter                                                   numGrps = ((((`LMQ_ENTRIES-1)/4)+1)*4);
parameter                                                   AXU_TARGET_ENC = `AXU_SPARE_ENC + `GPR_POOL_ENC + `THREADS_POOL_ENC;

wire [0:`LMQ_ENTRIES-1]                                     ldqe_dRel_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_dRel_q;
wire [0:1]                                                  ldqe_dGpr_cntrl[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_dGpr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_dGpr_q;
wire [0:`THREADS-1]                                         ldqe_thrd_id_d[0:`LMQ_ENTRIES-1];
wire [0:`THREADS-1]                                         ldqe_thrd_id_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_wimge_i;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_wimge_g;
wire [0:4]                                                  ldqe_wimge_d[0:`LMQ_ENTRIES-1];
wire [0:4]                                                  ldqe_wimge_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_byte_swap_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_byte_swap_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resv_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resv_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_pfetch_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_pfetch_q;
wire [0:2]                                                  ldqe_op_size_d[0:`LMQ_ENTRIES-1];
wire [0:2]                                                  ldqe_op_size_q[0:`LMQ_ENTRIES-1];
wire [0:AXU_TARGET_ENC-1]                                   ldqe_tgpr_d[0:`LMQ_ENTRIES-1];
wire [0:AXU_TARGET_ENC-1]                                   ldqe_tgpr_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_axu_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_axu_q;
wire [0:3]                                                  ldqe_usr_def_d[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_usr_def_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_lock_set_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_lock_set_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_watch_set_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_watch_set_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_algebraic_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_algebraic_q;
wire [0:1]                                                  ldqe_class_id_d[0:`LMQ_ENTRIES-1];
wire [0:1]                                                  ldqe_class_id_q[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_perf_events_d[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_perf_events_q[0:`LMQ_ENTRIES-1];
wire [0:1]                                                  ldqe_set_gpr_done[0:`LMQ_ENTRIES-1];
wire [0:1]                                                  ldqe_dvc_d[0:`LMQ_ENTRIES-1];
wire [0:1]                                                  ldqe_dvc_q[0:`LMQ_ENTRIES-1];
wire [0:5]                                                  ldqe_ttype_d[0:`LMQ_ENTRIES-1];
wire [0:5]                                                  ldqe_ttype_q[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_dacrw_d[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_dacrw_q[0:`LMQ_ENTRIES-1];
wire [0:`ITAG_SIZE_ENC-1]                                   ldqe_itag_d[0:`LMQ_ENTRIES-1];
wire [0:`ITAG_SIZE_ENC-1]                                   ldqe_itag_q[0:`LMQ_ENTRIES-1];
wire [64-`REAL_IFAR_WIDTH:57]                               ldqe_p_addr_msk[0:`LMQ_ENTRIES-1];
wire [64-`REAL_IFAR_WIDTH:63]                               ldqe_p_addr_d[0:`LMQ_ENTRIES-1];
wire [64-`REAL_IFAR_WIDTH:63]                               ldqe_p_addr_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_cp_flush;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_odq_flush;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_pfetch_flush;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_flush;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_kill;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_mkill;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_mkill_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_mkill_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resolved;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resolved_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resolved_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_nFlush_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_nFlush_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_np1Flush_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_np1Flush_q;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldm_hit_d;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldm_hit_q;
wire                                                        spr_xucr0_cls_d;
wire                                                        spr_xucr0_cls_q;
wire                                                        spr_lsucr0_lge_d;
wire                                                        spr_lsucr0_lge_q;
wire [0:2]                                                  spr_lsucr0_lca_d;
wire [0:2]                                                  spr_lsucr0_lca_q;
wire                                                        spr_lsucr0_lca_zero;
wire [0:2]                                                  spr_lsucr0_lca_ovrd;
wire [0:`THREADS-1]                                         iu_lq_cp_flush_d;
wire [0:`THREADS-1]                                         iu_lq_cp_flush_q;
wire [0:`ITAG_SIZE_ENC-1]                                   iu_lq_cp_next_itag_q[0:`THREADS-1];
wire                                                        ex4_stg_flush;
wire                                                        ex5_stg_flush;
wire                                                        odq_ldq_n_flush_d;
wire                                                        odq_ldq_n_flush_q;
wire                                                        odq_ldq_resolved_d;
wire                                                        odq_ldq_resolved_q;
wire [0:`ITAG_SIZE_ENC-1]                                   odq_ldq_report_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                                   odq_ldq_report_itag_q;
wire [0:`THREADS-1]                                         odq_ldq_report_tid_d;
wire [0:`THREADS-1]                                         odq_ldq_report_tid_q;
wire [0:`THREADS-1]                                         rv_lq_rvs_empty_d;
wire [0:`THREADS-1]                                         rv_lq_rvs_empty_q;
wire                                                        ldq_rel1_set_rviss_dir_coll;
wire                                                        ldq_rel1_set_binv_dir_coll;
wire                                                        ldq_rel1_set_rd_dir_coll;
wire                                                        rel2_blk_req_d;
wire                                                        rel2_blk_req_q;
wire                                                        rel2_rviss_blk_d;
wire                                                        rel2_rviss_blk_q;
wire [64-`REAL_IFAR_WIDTH:57]                               l2_back_inv_addr_msk;
wire [64-`REAL_IFAR_WIDTH:57]                               ex4_p_addr_msk;
wire                                                        ex4_ldreq_d;
wire                                                        ex4_ldreq_q;
wire                                                        ex5_ldreq_val;
wire                                                        ex5_ldreq_val_d;
wire                                                        ex5_ldreq_val_q;
wire                                                        ex5_ldreq_flushed;
wire                                                        ex4_pfetch_val_d;
wire                                                        ex4_pfetch_val_q;
wire                                                        ex5_pfetch_val;
wire                                                        ex5_pfetch_val_d;
wire                                                        ex5_pfetch_val_q;
wire                                                        ex5_pfetch_flushed;
wire                                                        ex5_odq_ldreq_val_d;
wire                                                        ex5_odq_ldreq_val_q;
wire                                                        ex5_streq_val_d;
wire                                                        ex5_streq_val_q;
wire                                                        ex5_othreq_val_d;
wire                                                        ex5_othreq_val_q;
wire [64-`REAL_IFAR_WIDTH:63]                               ex5_p_addr_d;
wire [64-`REAL_IFAR_WIDTH:63]                               ex5_p_addr_q;
wire [0:4]                                                  ex5_wimge_d;
wire [0:4]                                                  ex5_wimge_q;
wire [0:11]                                                 ex5_cmmt_events;
wire [0:3]                                                  ex5_cmmt_perf_events;
wire [0:3]                                                  ex6_cmmt_perf_events_d;
wire [0:3]                                                  ex6_cmmt_perf_events_q;
wire [0:`LMQ_ENTRIES-1]                                     ex4_ldqe_set_val;
wire [0:`LMQ_ENTRIES-1]                                     ex4_ldqe_set_all;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldqe_set_all_d;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldqe_set_all_q;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldqe_set_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldqe_set_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ex6_ldqe_pfetch_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ex6_ldqe_pfetch_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ex7_ldqe_pfetch_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ex7_ldqe_pfetch_val_q;
wire                                                        ex7_pfetch_blk_val;
wire [0:`THREADS-1]                                         ex7_pfetch_blk_tid;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldm_entry;
reg [0:`THREADS-1]                                          ldq_all_req_home;
wire [0:`THREADS-1]                                         lq_xu_quiesce_d;
wire [0:`THREADS-1]                                         lq_xu_quiesce_q;
wire                                                        lq_mm_lmq_stq_empty_d;
wire                                                        lq_mm_lmq_stq_empty_q;
wire [0:`THREADS-1]                                         lq_pc_ldq_quiesce_d;
wire [0:`THREADS-1]                                         lq_pc_ldq_quiesce_q;
wire [0:`THREADS-1]                                         lq_pc_stq_quiesce_d;
wire [0:`THREADS-1]                                         lq_pc_stq_quiesce_q;
wire [0:`THREADS-1]                                         lq_pc_pfetch_quiesce_d;
wire [0:`THREADS-1]                                         lq_pc_pfetch_quiesce_q;
reg [0:3]                                                   ex5_cTag;
reg [0:1]                                                   ex5_tid_enc;
wire [0:3]                                                  ldqe_beat_init;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_wrt_ptr;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_opposite_ptr;
wire                                                        ex4_one_machine_avail;
wire                                                        ex4_oldest_load;
wire                                                        ex4_reserved_taken;
wire                                                        ex5_reserved_taken_d;
wire                                                        ex5_reserved_taken_q;
wire                                                        ex4_resv_taken_restart;
wire                                                        ex5_resv_taken_restart_d;
wire                                                        ex5_resv_taken_restart_q;
wire [0:`LMQ_ENTRIES+`LGQ_ENTRIES-1]                        ldqe_cpl_sel;
wire [0:`LMQ_ENTRIES+`LGQ_ENTRIES-1]                        ldqe_cpl_sent;
wire [0:`LMQ_ENTRIES-1]                                     ex5_inv_ldqe;
wire                                                        ex4_ldq_full;
wire                                                        ex5_ldq_full_d;
wire                                                        ex5_ldq_full_q;
wire                                                        ex4_ldq_full_restart;
wire                                                        ex5_ldq_full_restart_d;
wire                                                        ex5_ldq_full_restart_q;
wire                                                        ex4_ldq_hit;
wire                                                        ex5_ldq_hit_d;
wire                                                        ex5_ldq_hit_q;
wire                                                        ldq_full_qHit_held_set;
wire                                                        ldq_full_qHit_held_clr;
wire [0:1]                                                  ldq_full_qHit_held_ctrl;
wire                                                        ldq_full_qHit_held_d;
wire                                                        ldq_full_qHit_held_q;
wire                                                        ldq_resv_qHit_held_set;
wire                                                        ldq_resv_qHit_held_clr;
wire [0:1]                                                  ldq_resv_qHit_held_ctrl;
wire                                                        ldq_resv_qHit_held_d;
wire                                                        ldq_resv_qHit_held_q;
wire                                                        ldq_oth_qHit_clr_d;
wire                                                        ldq_oth_qHit_clr_q;
wire                                                        ex5_ldq_set_hold_d;
wire                                                        ex5_ldq_set_hold_q;
wire                                                        ex5_ldq_full_set_hold;
wire                                                        ex5_setHold;
wire                                                        ldq_clrHold;
wire [0:`THREADS-1]                                         ldq_clrHold_tid;
wire [0:`THREADS-1]                                         ldq_setHold_tid;
wire [0:`THREADS-1]                                         ldq_hold_tid;
wire [0:`THREADS-1]                                         ldq_hold_tid_d;
wire [0:`THREADS-1]                                         ldq_hold_tid_q;
wire                                                        ex5_ldq_restart;
wire                                                        ex5_ldq_restart_d;
wire                                                        ex5_ldq_restart_q;
wire                                                        ex6_ldq_full_d;
wire                                                        ex6_ldq_full_q;
wire                                                        ex6_ldq_hit_d;
wire                                                        ex6_ldq_hit_q;
wire                                                        ex5_lgq_full_d;
wire                                                        ex5_lgq_full_q;
wire                                                        ex6_lgq_full_d;
wire                                                        ex6_lgq_full_q;
wire                                                        ex5_lgq_qwhit_d;
wire                                                        ex5_lgq_qwhit_q;
wire                                                        ex6_lgq_qwhit_d;
wire                                                        ex6_lgq_qwhit_q;
wire                                                        ex5_restart_val;
wire                                                        ex5_drop_req_val;
wire                                                        ex5_drop_gath;
wire                                                        perf_ex6_ldq_full_restart;
wire                                                        perf_ex6_ldq_hit_restart;
wire                                                        perf_ex6_lgq_full_restart;
wire                                                        perf_ex6_lgq_qwhit_restart;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_inuse;
wire [0:`THREADS-1]                                         ldqe_tid_inuse[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_req_outstanding;
wire [0:`THREADS-1]                                         ldqe_tid_req_outstanding[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_req_able_to_hold;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_blk_qHit_held;
wire [0:`LMQ_ENTRIES-1]                                     ex4_load_qHit_upd;
wire [0:`LMQ_ENTRIES-1]                                     ex4_addr_m_queue;
wire [0:`LMQ_ENTRIES-1]                                     ex4_qw_hit_queue;
reg [0:`LMQ_ENTRIES-1]                                      ex4_lgq_qw_hit;
wire                                                        ex5_ld_gath_d;
wire                                                        ex5_ld_gath_q;
wire                                                        ex4_ld_gath;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_entry_gatherable;
wire [0:`LMQ_ENTRIES-1]                                     ex4_entry_gatherable;
wire [0:`LMQ_ENTRIES-1]                                     ex4_entry_gath_ld;
wire [0:`LMQ_ENTRIES-1]                                     ex4_entry_gath_full;
wire [0:`LMQ_ENTRIES-1]                                     ex4_entry_gath_qwhit;
wire [0:`LMQ_ENTRIES-1]                                     ex4_thrd_id_m;
wire [0:`LMQ_ENTRIES-1]                                     ex4_larx_hit;
wire [0:`LMQ_ENTRIES-1]                                     ex4_guarded_hit;
wire [0:`LMQ_ENTRIES-1]                                     ex4_req_hit_ldq;
wire [0:`LMQ_ENTRIES-1]                                     ex4_entry_load_qHit;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_back_inv_flush_upd;
wire [0:`THREADS-1]                                         ldqe_cpNext_tid[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_cpNext_val;
wire [0:((((`LMQ_ENTRIES-1)/4)+1)*4)-1]                     ldqe_sent;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_req_cmpl_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_req_cmpl_q;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_ctrl_act;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_inprog;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_zap;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_need_l2send;
wire [0:1]                                                  ldqe_beat_ctrl[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_beat_incr[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_beat_cntr_d[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_beat_cntr_q[0:`LMQ_ENTRIES-1];
wire                                                        ex5_upd_fifo_val;
wire                                                        fifo_ldq_act;
wire                                                        fifo_ldq_req_compr_val;
wire                                                        fifo_ldq_req_sent;
wire                                                        fifo_ldq_req0_mkill;
wire                                                        fifo_ldq_req0_avail;
wire [0:1]                                                  fifo_ldq_wrt_ptr_cntrl;
wire                                                        fifo_ldq_reset_ptr;
wire [0:`LMQ_ENTRIES]                                       fifo_ldq_req_nxt_ptr;
wire [0:`LMQ_ENTRIES]                                       fifo_ldq_req_nxt_ptr_d;
wire [0:`LMQ_ENTRIES]                                       fifo_ldq_req_nxt_ptr_q;
wire [0:`LMQ_ENTRIES]                                       fifo_ldq_req_wrt_ptr;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_upd;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_empty_entry;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_push;
wire [0:1]                                                  fifo_ldq_req_cntrl[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_val;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_val_d;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_val_q;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_pfetch_match;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_pfetch_send;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_pfetch;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_pfetch_d;
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_pfetch_q;
wire [0:`THREADS-1]                                         fifo_ldq_req_tid_d[0:`LMQ_ENTRIES-1];
wire [0:`THREADS-1]                                         fifo_ldq_req_tid_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_d[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     fifo_ldq_req_q[0:`LMQ_ENTRIES-1];
reg [0:3]                                                   ldq_mux_usr_def;
reg [0:4]                                                   ldq_mux_wimge;
reg [64-`REAL_IFAR_WIDTH:63]                                ldq_mux_p_addr;
reg [0:5]                                                   ldq_mux_ttype;
reg [0:2]                                                   ldq_mux_opsize;
reg [0:`THREADS-1]                                          ldq_mux_tid;
reg [0:1]                                                   ldq_mux_tid_enc;
reg [0:3]                                                   ldq_mux_cTag;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relmin1_cTag;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel0_cTag;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel1_cTag;
wire [0:`LMQ_ENTRIES-1]                                     ldq_relmin1_l2_val;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_l2_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_relmin1_l2_inval;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel_l2_l1dumpBlk;
wire [0:`LMQ_ENTRIES-1]                                     ldq_relmin1_l2_qHitBlk;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_cpNext_ecc_err;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_nFlush_ecc_err;
reg [0:6]                                                   ldqe_nxt_state[0:`LMQ_ENTRIES-1];
wire [0:6]                                                  ldqe_state_d[0:`LMQ_ENTRIES-1];
wire [0:6]                                                  ldqe_state_q[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldq_resp_cTag;
wire [57:59]                                                ldq_resp_qw;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_beats_home;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_beats_home_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_beats_home_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_beats_home_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_beats_home_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_beats_home_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_beats_home_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_beats_home_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_beats_home_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_entrySent;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_entrySent_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_entrySent_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_entrySent_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_entrySent_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_entrySent_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_entrySent_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_sentL1_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_sentL1_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_sentL1_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_sentL1_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_req_noL1done;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_req_done;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel6_req_done_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel6_req_done_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_ci_done;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_drel_done;
wire                                                        ldq_rel1_val_d;
wire                                                        ldq_rel1_val_q;
wire                                                        ldq_rel1_arb_val_d;
wire                                                        ldq_rel1_arb_val_q;
wire                                                        ldq_rel0_rdat_sel;
wire [0:2]                                                  ldq_rel0_rdat_qw;
wire                                                        ldq_rel1_l1_dump_d;
wire                                                        ldq_rel1_l1_dump_q;
wire                                                        ldq_rel2_l1_dump_d;
wire                                                        ldq_rel2_l1_dump_q;
wire                                                        ldq_rel3_l1_dump_d;
wire                                                        ldq_rel3_l1_dump_q;
wire                                                        ldq_rel3_l1_dump_val;
wire                                                        ldq_rel3_clr_relq_d;
wire                                                        ldq_rel3_clr_relq_q;
wire [0:2]                                                  ldq_rel1_resp_qw_d;
wire [0:2]                                                  ldq_rel1_resp_qw_q;
wire [0:3]                                                  ldq_rel1_cTag_d;
wire [0:3]                                                  ldq_rel1_cTag_q;
wire                                                        l2_rel1_resp_val_d;
wire                                                        l2_rel1_resp_val_q;
wire                                                        l2_rel2_resp_val_d;
wire                                                        l2_rel2_resp_val_q;
wire                                                        ldq_err_inval_rel_d;
wire                                                        ldq_err_inval_rel_q;
wire                                                        ldq_err_ecc_det_d;
wire                                                        ldq_err_ecc_det_q;
wire                                                        ldq_err_ue_det_d;
wire                                                        ldq_err_ue_det_q;
wire                                                        ldq_rel3_rdat_par_err;
reg [0:2]                                                   ldq_rel_mux_opsize;
reg                                                         ldq_rel_mux_wimge_i;
reg                                                         ldq_rel_mux_byte_swap;
reg [64-`REAL_IFAR_WIDTH:63]                                ldq_rel_mux_p_addr;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel_mux_p_addr_msk;
reg [0:1]                                                   ldq_rel_mux_dvcEn;
reg                                                         ldq_rel_mux_lockSet;
reg                                                         ldq_rel_mux_watchSet;
reg [0:AXU_TARGET_ENC-1]                                    ldq_rel_mux_tGpr;
reg                                                         ldq_rel_mux_axu;
reg                                                         ldq_rel_mux_algEn;
reg [0:1]                                                   ldq_rel_mux_classID;
reg [0:`THREADS-1]                                          ldq_rel_mux_tid;
reg                                                         ldq_rel1_mux_back_inv;
reg [0:2]                                                   lgq_rel_mux_opsize;
reg [59:63]                                                 lgq_rel_mux_p_addr;
reg                                                         lgq_rel_mux_byte_swap;
reg [0:1]                                                   lgq_rel_mux_dvcEn;
reg [0:AXU_TARGET_ENC-1]                                    lgq_rel_mux_tGpr;
reg                                                         lgq_rel_mux_axu;
reg                                                         lgq_rel_mux_algEn;
reg [0:`THREADS-1]                                          lgq_rel_mux_tid;
wire [0:2]                                                  ldq_rel1_opsize_d;
wire [0:2]                                                  ldq_rel1_opsize_q;
wire                                                        ldq_rel1_wimge_i_d;
wire                                                        ldq_rel1_wimge_i_q;
wire                                                        ldq_rel1_byte_swap_d;
wire                                                        ldq_rel1_byte_swap_q;
wire                                                        ldq_rel2_byte_swap_d;
wire                                                        ldq_rel2_byte_swap_q;
wire [64-`REAL_IFAR_WIDTH:63]                               ldq_rel1_p_addr_d;
wire [64-`REAL_IFAR_WIDTH:63]                               ldq_rel1_p_addr_q;
wire [0:1]                                                  ldq_rel1_dvcEn_d;
wire [0:1]                                                  ldq_rel1_dvcEn_q;
wire                                                        ldq_rel1_lockSet_d;
wire                                                        ldq_rel1_lockSet_q;
wire                                                        ldq_rel1_watchSet_d;
wire                                                        ldq_rel1_watchSet_q;
wire [0:AXU_TARGET_ENC-1]                                   ldq_rel1_tGpr_d;
wire [0:AXU_TARGET_ENC-1]                                   ldq_rel1_tGpr_q;
wire                                                        ldq_rel1_axu_d;
wire                                                        ldq_rel1_axu_q;
wire                                                        ldq_rel1_algEn_d;
wire                                                        ldq_rel1_algEn_q;
wire [0:1]                                                  ldq_rel1_classID_d;
wire [0:1]                                                  ldq_rel1_classID_q;
wire [0:`THREADS-1]                                         ldq_rel1_tid_d;
wire [0:`THREADS-1]                                         ldq_rel1_tid_q;
wire [0:`THREADS-1]                                         ldq_rel2_tid_d;
wire [0:`THREADS-1]                                         ldq_rel2_tid_q;
wire [0:`THREADS-1]                                         ldq_rel1_dir_tid_d;
wire [0:`THREADS-1]                                         ldq_rel1_dir_tid_q;
reg [0:`ITAG_SIZE_ENC-1]                                    ldqe_relmin1_iTag;
reg [0:`THREADS-1]                                          ldqe_relmin1_tid;
reg [0:`ITAG_SIZE_ENC-1]                                    lgqe_relmin1_iTag;
reg [0:`THREADS-1]                                          lgqe_relmin1_tid;
wire [0:`THREADS-1]                                         ldq_relmin1_tid;
wire [0:`ITAG_SIZE_ENC-1]                                   ldq_relmin1_iTag;
wire [0:7]                                                  ldq_rel0_beat_upd;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_sentL1;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_sentL1_blk;
wire [0:1]                                                  ldqe_sentRel_ctrl[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_sentRel_incr[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_sentRel_cntr_d[0:`LMQ_ENTRIES-1];
wire [0:3]                                                  ldqe_sentRel_cntr_q[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_sentL1;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_last_beat;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel2_l1upd_cmpl;
wire [0:1]                                                  ldqe_rel_start_ctrl[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relDir_start;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relDir_start_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relDir_start_q;
wire                                                        ldq_rel0_arb_val;
wire [0:3]                                                  ldq_rel0_arb_cTag;
wire                                                        ldq_rel0_arb_thresh;
wire [0:2]                                                  ldq_rel0_arb_qw;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_arb_sent;
wire                                                        ldq_rel0_arr_wren;
wire                                                        ldq_rel1_clr_val;
wire                                                        ldq_l2_rel0_qHitBlk_d;
wire                                                        ldq_l2_rel0_qHitBlk_q;
wire                                                        ldq_l2_resp_hold_all;
wire                                                        ldq_rel_arb_hold_all;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel2_cclass_d;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel2_cclass_q;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel3_cclass_d;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel3_cclass_q;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel4_cclass_d;
wire [64-(`DC_SIZE-3):57]                                   ldq_rel4_cclass_q;
wire                                                        ldq_rel1_set_val;
wire                                                        ldq_rel2_set_val_d;
wire                                                        ldq_rel2_set_val_q;
wire                                                        ldq_rel3_set_val_d;
wire                                                        ldq_rel3_set_val_q;
wire                                                        ldq_rel4_set_val_d;
wire                                                        ldq_rel4_set_val_q;
wire                                                        ldq_rel1_data_val;
wire                                                        ldq_rel1_data_sel_d;
wire                                                        ldq_rel1_data_sel_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_l2_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_l2_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_l2_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_l2_val_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_l2_val_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_l2_val_q;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_cntr_reset_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_cntr_reset_q;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_resent_ecc_err_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_resent_ecc_err_q;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_reset_cpl_rpt_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_reset_cpl_rpt_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_rdat_perr;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_ecc_err_dgpr;
reg [0:`LMQ_ENTRIES-1]                                      ldqe_rst_eccdet;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rst_eccdet_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rst_eccdet_q;
wire [0:1]                                                  ldqe_rel_eccdet_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet_ue;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet_ue_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel_eccdet_ue_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_gpr_ecc_err;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_gpr_eccue_err;
wire [0:1]                                                  ldqe_upd_gpr_ecc_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_ecc;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_ecc_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_ecc_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_eccue;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_eccue_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_upd_gpr_eccue_q;
wire                                                        rel0_stg_act;
wire                                                        ldq_reload_val;
wire [0:1]                                                  ldqe_rel_l1_dump_ctrl[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_drop_reload_val;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel_l1_dump;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_l1_dump_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_l1_dump_q;
wire [57:59]                                                ldq_reload_qw;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_relmin1_upd_gpr;
wire                                                        ldq_itag2_rel_val;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_crit_qw;
wire                                                        ldq_rel1_gpr_val;
wire                                                        ldq_rel1_gpr_val_d;
wire                                                        ldq_rel1_gpr_val_q;
wire                                                        rel2_eccdet;
wire                                                        rel2_eccdet_ue;
wire                                                        rel2_eccdet_err;
wire                                                        ldq_rel2_rdat_perr;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_upd_gpr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel0_upd_gpr_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_upd_gpr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_upd_gpr_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_upd_gpr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_upd_gpr_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_upd_gpr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_upd_gpr_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_upd_gpr;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel2_drop_cpl_rpt;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel3_drop_cpl_rpt_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_rel3_drop_cpl_rpt_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_reld_cpl_rpt;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_send_cpl_ok;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel6_send_cpl_ok;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel_send_cpl_ok;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_odq_cpl;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_odq_cpl_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel4_odq_cpl_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_odq_cpl_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_odq_cpl_q;
wire                                                        ldq_l2_req_need_send;
wire                                                        ldq_rel0_updating_cache;
wire                                                        ldq_rel1_collide_binv_d;
wire                                                        ldq_rel1_collide_binv_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel1_dbeat_val;
wire                                                        ldq_stq_rel1_blk_store_d;
wire                                                        ldq_stq_rel1_blk_store_q;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel2_qHit_clr;
wire [0:1]                                                  ldqe_qHit_clr_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel_qHit_clr_d;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel_qHit_clr_q;
wire [0:1]                                                  ldqe_qHit_held_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_qHit_held_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_qHit_held_q;
wire                                                        ldq_rel2_rv_clr_hold;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_available;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_cpl_rpt_done;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_need_cpl_rst;
wire [0:1]                                                  ldqe_need_cpl_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_need_cpl_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_need_cpl_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_send_cpl;
wire [0:1]                                                  ldqe_sent_cpl_sel[0:`LMQ_ENTRIES-1];
wire [0:`LMQ_ENTRIES-1]                                     ldqe_sent_cpl_d;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_sent_cpl_q;
wire [0:`LMQ_ENTRIES-1]                                     ldqe_complete;
wire [0:`LMQ_ENTRIES+`LGQ_ENTRIES-1]                        ldqe_remove;
wire [0:3]                                                  cpl_grpEntry_val[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
wire [0:3]                                                  cpl_grpEntry_sel[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
wire [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                    cpl_grpEntry_sent;
wire [0:3]                                                  cpl_grpEntry_last_sel_d[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
wire [0:3]                                                  cpl_grpEntry_last_sel_q[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:`ITAG_SIZE_ENC-1]                                    cpl_grpEntry_iTag[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                     cpl_grpEntry_ecc;
reg [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                     cpl_grpEntry_eccue;
reg [0:1]                                                   cpl_grpEntry_dvc[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:3]                                                   cpl_grpEntry_dacrw[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:`THREADS-1]                                          cpl_grpEntry_tid[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                     cpl_grpEntry_nFlush;
reg [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                     cpl_grpEntry_np1Flush;
reg [0:3]                                                   cpl_grpEntry_pEvents[0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4];
reg [0:(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4]                     cpl_grpEntry_larx;
wire [0:3]                                                  cpl_group_val;
wire [0:3]                                                  cpl_group_sel;
wire [0:3]                                                  cpl_group_last_sel_d;
wire [0:3]                                                  cpl_group_last_sel_q;
wire                                                        cpl_credit_sent;
reg [0:`ITAG_SIZE_ENC-1]                                    cpl_send_itag;
reg                                                         cpl_ecc_dec;
reg                                                         cpl_eccue_dec;
reg [0:1]                                                   cpl_dvc;
reg [0:3]                                                   cpl_dacrw;
reg [0:`THREADS-1]                                          cpl_tid;
reg                                                         cpl_nFlush;
reg                                                         cpl_np1Flush;
reg [0:3]                                                   cpl_pEvents;
reg                                                         cpl_larx;
wire                                                        ldq_cpl_odq_zap;
wire                                                        ldq_cpl_odq_val;
wire                                                        ldq_cpl_odq_dbg_int_en;
wire                                                        ldq_cpl_odq_n_flush;
wire [0:3]                                                  ldq_cpl_odq_dacrw;
wire                                                        ldq_cpl_odq_eccue;
wire                                                        ldq_cpl_pending;
wire [0:`THREADS-1]                                         ldq_execute_vld;
wire [0:`THREADS-1]                                         odq_execute_vld;
wire [0:`THREADS-1]                                         lq1_iu_execute_vld_d;
wire [0:`THREADS-1]                                         lq1_iu_execute_vld_q;
wire [0:`ITAG_SIZE_ENC-1]                                   lq1_iu_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                                   lq1_iu_itag_q;
wire                                                        lq1_iu_n_flush_d;
wire                                                        lq1_iu_n_flush_q;
wire                                                        lq1_iu_np1_flush_d;
wire                                                        lq1_iu_np1_flush_q;
wire                                                        lq1_iu_exception_val_d;
wire                                                        lq1_iu_exception_val_q;
wire                                                        ldq_cpl_dbg_int_en;
wire                                                        ldq_cpl_oth_flush;
wire                                                        ldq_cpl_n_flush;
wire                                                        ldq_cpl_np1_flush;
wire [0:1]                                                  ldq_cpl_dvc;
wire [0:3]                                                  ldq_cpl_dacrw;
wire [0:3]                                                  lq1_iu_dacrw_d;
wire [0:3]                                                  lq1_iu_dacrw_q;
wire [0:3]                                                  lq1_iu_perf_events_d;
wire [0:3]                                                  lq1_iu_perf_events_q;
wire [0:`THREADS-1]                                         ldq_cpl_larx_d;
wire [0:`THREADS-1]                                         ldq_cpl_larx_q;
wire [0:`THREADS-1]                                         ldq_cpl_binv_d;
wire [0:`THREADS-1]                                         ldq_cpl_binv_q;
wire                                                        ldq_rel_cmmt_d;
wire                                                        ldq_rel_cmmt_q;
wire                                                        ldq_rel_need_hole_d;
wire                                                        ldq_rel_need_hole_q;
wire                                                        ldq_rel_latency_d;
wire                                                        ldq_rel_latency_q;
wire [0:`THREADS-1]                                         perf_ldq_cpl_larx;
wire [0:`THREADS-1]                                         perf_ldq_cpl_binv;
wire                                                        perf_ldq_rel_attmpt;
wire                                                        perf_ldq_rel_cmmt;
wire                                                        perf_ldq_rel_need_hole;
wire                                                        perf_ldq_rel_latency;
wire                                                        ex4_stg_act_d;
wire                                                        ex4_stg_act_q;
wire                                                        ex5_stg_act_d;
wire                                                        ex5_stg_act_q;
wire [0:`LMQ_ENTRIES-1]                                     ex4_ldqe_act;
wire [0:`LMQ_ENTRIES-1]                                     ex5_ldqe_act;
wire [0:`LMQ_ENTRIES-1]                                     ex4_lgqe_act;
wire [0:`LMQ_ENTRIES-1]                                     ex5_lgqe_act;
reg [0:3]                                                   ldq_gath_Tag;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_wrt_ptr;
wire                                                        ld_gath_not_full;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_available;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_cpl_sent;
wire [0:`LGQ_ENTRIES-1]                                     lgq_reset_val;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_odq_flush;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_cp_flush;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_kill;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_valid_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_valid_q;
wire                                                        ex4_gath_val;
wire [0:`LGQ_ENTRIES-1]                                     ex4_lgqe_set_val;
wire [0:`LGQ_ENTRIES-1]                                     ex4_lgqe_set_all;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_set_all_d;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_set_all_q;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_set_val_d;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_set_val_q;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_restart;
wire [0:`LGQ_ENTRIES-1]                                     ex5_lgqe_drop;
wire                                                        ex5_lgq_restart;
wire [0:`THREADS-1]                                         lgqe_thrd_id_d[0:`LGQ_ENTRIES-1];
wire [0:`THREADS-1]                                         lgqe_thrd_id_q[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_byte_swap_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_byte_swap_q;
wire [0:`LGQ_ENTRIES-1]                                     lqg_qw_match;
wire [0:2]                                                  lgqe_set_op_size[0:`LGQ_ENTRIES-1];
wire [0:2]                                                  lgqe_op_size_d[0:`LGQ_ENTRIES-1];
wire [0:2]                                                  lgqe_op_size_q[0:`LGQ_ENTRIES-1];
wire [0:AXU_TARGET_ENC-1]                                   lgqe_set_tgpr[0:`LGQ_ENTRIES-1];
wire [0:AXU_TARGET_ENC-1]                                   lgqe_tgpr_d[0:`LGQ_ENTRIES-1];
wire [0:AXU_TARGET_ENC-1]                                   lgqe_tgpr_q[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_set_axu;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_axu_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_axu_q;
wire [0:3]                                                  lgqe_perf_events_d[0:`LGQ_ENTRIES-1];
wire [0:3]                                                  lgqe_perf_events_q[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_set_algebraic;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_algebraic_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_algebraic_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_gpr_done_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_gpr_done_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_resolved;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_resolved_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_resolved_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_back_inv_nFlush_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_back_inv_nFlush_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_back_inv_np1Flush_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_back_inv_np1Flush_q;
wire [0:1]                                                  lgqe_set_gpr_done[0:`LGQ_ENTRIES-1];
wire [0:1]                                                  lgqe_set_dvc[0:`LGQ_ENTRIES-1];
wire [0:1]                                                  lgqe_dvc_d[0:`LGQ_ENTRIES-1];
wire [0:1]                                                  lgqe_dvc_q[0:`LGQ_ENTRIES-1];
wire [0:3]                                                  lgqe_dacrw_d[0:`LGQ_ENTRIES-1];
wire [0:3]                                                  lgqe_dacrw_q[0:`LGQ_ENTRIES-1];
wire [0:`ITAG_SIZE_ENC-1]                                   lgqe_itag_d[0:`LGQ_ENTRIES-1];
wire [0:`ITAG_SIZE_ENC-1]                                   lgqe_itag_q[0:`LGQ_ENTRIES-1];
wire [57:63]                                                lgqe_p_addr_d[0:`LGQ_ENTRIES-1];
wire [57:63]                                                lgqe_p_addr_q[0:`LGQ_ENTRIES-1];
wire [0:3]                                                  lgqe_ldTag_d[0:`LGQ_ENTRIES-1];
wire [0:3]                                                  lgqe_ldTag_q[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     ldq_gath_Tag_1hot[0:`LMQ_ENTRIES-1];
reg [0:`LMQ_ENTRIES-1]                                      ldqe_gather_done;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_back_inv_flush_upd;
wire [0:`THREADS-1]                                         lgqe_cpNext_tid[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_cpNext_val;
wire [0:1]                                                  lgqe_upd_gpr_ecc_sel[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_ecc;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_ecc_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_ecc_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_eccue;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_eccue_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_upd_gpr_eccue_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_cpl_rpt_done;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_need_cpl_rst;
wire [0:1]                                                  lgqe_need_cpl_sel[0:`LGQ_ENTRIES-1];
wire [0:`LGQ_ENTRIES-1]                                     lgqe_need_cpl_d;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_need_cpl_q;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_send_cpl;
wire                                                        lgq_rel1_gpr_val_d;
wire                                                        lgq_rel1_gpr_val_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel0_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel0_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel1_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel1_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel2_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel2_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel3_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel3_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel4_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel4_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel5_upd_gpr_d;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel5_upd_gpr_q;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel1_upd_gpr;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel2_upd_gpr;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_relmin1_match;
wire [0:`LGQ_ENTRIES-1]                                     lgqe_relmin1_upd_gpr;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel2_send_cpl_ok;
reg [0:`ITAG_SIZE_ENC-1]                                    ldq_rel3_odq_itag;
reg                                                         ldq_rel3_odq_ecc;
reg                                                         ldq_rel3_odq_eccue;
reg [0:1]                                                   ldq_rel3_odq_dvc;
reg [0:3]                                                   ldq_rel3_odq_dacrw;
reg [0:`THREADS-1]                                          ldq_rel3_odq_tid;
reg                                                         ldq_rel3_odq_nFlush;
reg                                                         ldq_rel3_odq_np1Flush;
reg [0:3]                                                   ldq_rel3_odq_pEvents;
wire                                                        ldq_rel3_odq_dbg_int_en;
wire                                                        ldq_rel3_odq_oth_flush;
wire [0:3]                                                  ldq_rel3_dacrw;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel3_odq_val;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel3_odq_val;
wire [0:`LMQ_ENTRIES-1]                                     ldq_rel5_odq_cpl;
wire [0:`LGQ_ENTRIES-1]                                     lgq_rel5_odq_cpl;
wire                                                        ldq_state_machines_idle;
wire                                                        ldq_relmin1_ldq_val;
wire [0:3]                                                  ldq_relmin1_cTag;
wire                                                        l2_rel0_resp_val_d;
wire                                                        l2_rel0_resp_val_q;
wire                                                        l2_rel0_resp_ldq_val_d;
wire                                                        l2_rel0_resp_ldq_val_q;
wire [0:3]                                                  l2_rel0_resp_cTag_d;
wire [0:3]                                                  l2_rel0_resp_cTag_q;
wire [57:59]                                                l2_rel0_resp_qw_d;
wire [57:59]                                                l2_rel0_resp_qw_q;
wire                                                        l2_rel0_resp_crit_qw_d;
wire                                                        l2_rel0_resp_crit_qw_q;
wire                                                        l2_rel0_resp_l1_dump_d;
wire                                                        l2_rel0_resp_l1_dump_q;
wire [0:2]                                                  ldq_rel0_opsize;
wire [59:63]                                                ldq_rel0_p_addr;
wire [0:4]                                                  ldq_rel0_opsize_1hot;
wire [0:4]                                                  ldq_rel0_rot_size;
wire [0:4]                                                  ldq_rel0_rot_max_size_le;
wire [0:4]                                                  ldq_rel0_rot_sel_le;
wire [0:3]                                                  ldq_rel0_rot_sel;
wire                                                        ldq_rel0_byte_swap;
wire [0:3]                                                  ldq_rel1_algebraic_sel_d;
wire [0:3]                                                  ldq_rel1_algebraic_sel_q;
wire                                                        lvl1_sel;
wire [0:1]                                                  lvl2_sel;
wire [0:1]                                                  lvl3_sel;
wire [0:1]                                                  rotate_sel1;
wire [0:3]                                                  rotate_sel2;
wire [0:3]                                                  rotate_sel3;
wire [0:7]                                                  ldq_rel1_rot_sel1_d;
wire [0:7]                                                  ldq_rel1_rot_sel1_q;
wire [0:7]                                                  ldq_rel1_rot_sel2_d;
wire [0:7]                                                  ldq_rel1_rot_sel2_q;
wire [0:7]                                                  ldq_rel1_rot_sel3_d;
wire [0:7]                                                  ldq_rel1_rot_sel3_q;
wire [0:127]                                                ldq_rel1_data;
wire [0:127]                                                ldq_rel2_rot_data;
wire [0:1]                                                  ldq_rel2_dvc;
wire [0:`THREADS-1]                                         dbg_int_en_d;
wire [0:`THREADS-1]                                         dbg_int_en_q;
wire                                                        rdat_scan_in;
wire                                                        rdat_scan_out;

//--------------------------
// constants
//--------------------------
parameter                                                  spr_xucr0_cls_offset = 0;
parameter                                                  spr_lsucr0_lge_offset = spr_xucr0_cls_offset + 1;
parameter                                                  spr_lsucr0_lca_offset = spr_lsucr0_lge_offset + 1;
parameter                                                  l2_rel0_resp_val_offset = spr_lsucr0_lca_offset + 3;
parameter                                                  l2_rel0_resp_ldq_val_offset = l2_rel0_resp_val_offset + 1;
parameter                                                  l2_rel0_resp_cTag_offset = l2_rel0_resp_ldq_val_offset + 1;
parameter                                                  l2_rel0_resp_qw_offset = l2_rel0_resp_cTag_offset + 4;
parameter                                                  l2_rel0_resp_crit_qw_offset = l2_rel0_resp_qw_offset + 3;
parameter                                                  l2_rel0_resp_l1_dump_offset = l2_rel0_resp_crit_qw_offset + 1;
parameter                                                  ldq_rel1_algebraic_sel_offset = l2_rel0_resp_l1_dump_offset + 1;
parameter                                                  ldq_rel1_rot_sel1_offset = ldq_rel1_algebraic_sel_offset + 4;
parameter                                                  ldq_rel1_rot_sel2_offset = ldq_rel1_rot_sel1_offset + 8;
parameter                                                  ldq_rel1_rot_sel3_offset = ldq_rel1_rot_sel2_offset + 8;
parameter                                                  iu_lq_cp_flush_offset = ldq_rel1_rot_sel3_offset + 8;
parameter                                                  iu_lq_cp_next_itag_offset = iu_lq_cp_flush_offset + `THREADS;
parameter                                                  odq_ldq_n_flush_offset = iu_lq_cp_next_itag_offset + (`THREADS) * (`ITAG_SIZE_ENC);
parameter                                                  odq_ldq_resolved_offset = odq_ldq_n_flush_offset + 1;
parameter                                                  odq_ldq_report_itag_offset = odq_ldq_resolved_offset + 1;
parameter                                                  odq_ldq_report_tid_offset = odq_ldq_report_itag_offset + `ITAG_SIZE_ENC;
parameter                                                  rv_lq_rvs_empty_offset = odq_ldq_report_tid_offset + `THREADS;
parameter                                                  rel2_blk_req_offset = rv_lq_rvs_empty_offset + `THREADS;
parameter                                                  rel2_rviss_blk_offset = rel2_blk_req_offset + 1;
parameter                                                  ldq_rel1_collide_binv_offset = rel2_rviss_blk_offset + 1;
parameter                                                  ldq_stq_rel1_blk_store_offset = ldq_rel1_collide_binv_offset + 1;
parameter                                                  ex4_ldreq_offset = ldq_stq_rel1_blk_store_offset + 1;
parameter                                                  ex5_ldreq_val_offset = ex4_ldreq_offset + 1;
parameter                                                  ex4_pfetch_val_offset = ex5_ldreq_val_offset + 1;
parameter                                                  ex5_pfetch_val_offset = ex4_pfetch_val_offset + 1;
parameter                                                  ex5_odq_ldreq_val_offset = ex5_pfetch_val_offset + 1;
parameter                                                  ex5_streq_val_offset = ex5_odq_ldreq_val_offset + 1;
parameter                                                  ex5_othreq_val_offset = ex5_streq_val_offset + 1;
parameter                                                  ex5_reserved_taken_offset = ex5_othreq_val_offset + 1;
parameter                                                  ex5_resv_taken_restart_offset = ex5_reserved_taken_offset + 1;
parameter                                                  lq_xu_quiesce_offset = ex5_resv_taken_restart_offset + 1;
parameter                                                  lq_pc_ldq_quiesce_offset = lq_xu_quiesce_offset + `THREADS;
parameter                                                  lq_pc_stq_quiesce_offset = lq_pc_ldq_quiesce_offset + `THREADS;
parameter                                                  lq_pc_pfetch_quiesce_offset = lq_pc_stq_quiesce_offset + `THREADS;
parameter                                                  lq_mm_lmq_stq_empty_offset = lq_pc_pfetch_quiesce_offset + `THREADS;
parameter                                                  ex5_ldq_full_offset = lq_mm_lmq_stq_empty_offset + 1;
parameter                                                  ex5_ldq_full_restart_offset = ex5_ldq_full_offset + 1;
parameter                                                  ex5_ldq_hit_offset = ex5_ldq_full_restart_offset + 1;
parameter                                                  ex5_ld_gath_offset = ex5_ldq_hit_offset + 1;
parameter                                                  ldq_full_qHit_held_offset = ex5_ld_gath_offset + 1;
parameter                                                  ldq_resv_qHit_held_offset = ldq_full_qHit_held_offset + 1;
parameter                                                  ldq_oth_qHit_clr_offset = ldq_resv_qHit_held_offset + 1;
parameter                                                  ex5_ldq_set_hold_offset = ldq_oth_qHit_clr_offset + 1;
parameter                                                  ex5_ldq_restart_offset = ex5_ldq_set_hold_offset + 1;
parameter                                                  ex6_ldq_full_offset = ex5_ldq_restart_offset + 1;
parameter                                                  ex6_ldq_hit_offset = ex6_ldq_full_offset + 1;
parameter                                                  ex5_lgq_full_offset = ex6_ldq_hit_offset + 1;
parameter                                                  ex6_lgq_full_offset = ex5_lgq_full_offset + 1;
parameter                                                  ex5_lgq_qwhit_offset = ex6_lgq_full_offset + 1;
parameter                                                  ex6_lgq_qwhit_offset = ex5_lgq_qwhit_offset + 1;
parameter                                                  ex5_p_addr_offset = ex6_lgq_qwhit_offset + 1;
parameter                                                  ex5_wimge_offset = ex5_p_addr_offset + `REAL_IFAR_WIDTH;
parameter                                                  ex6_cmmt_perf_events_offset = ex5_wimge_offset + 5;
parameter                                                  ex5_ldqe_set_all_offset = ex6_cmmt_perf_events_offset + 4;
parameter                                                  ex5_ldqe_set_val_offset = ex5_ldqe_set_all_offset + `LMQ_ENTRIES;
parameter                                                  ex6_ldqe_pfetch_val_offset = ex5_ldqe_set_val_offset + `LMQ_ENTRIES;
parameter                                                  ex7_ldqe_pfetch_val_offset = ex6_ldqe_pfetch_val_offset + `LMQ_ENTRIES;
parameter                                                  ex5_ldm_hit_offset = ex7_ldqe_pfetch_val_offset + `LMQ_ENTRIES;
parameter                                                  ldq_hold_tid_offset = ex5_ldm_hit_offset + `LMQ_ENTRIES;
parameter                                                  fifo_ldq_req_nxt_ptr_offset = ldq_hold_tid_offset + `THREADS;
parameter                                                  fifo_ldq_req_val_offset = fifo_ldq_req_nxt_ptr_offset + `LMQ_ENTRIES + 1;
parameter                                                  fifo_ldq_req_pfetch_offset = fifo_ldq_req_val_offset + `LMQ_ENTRIES;
parameter                                                  fifo_ldq_req_tid_offset = fifo_ldq_req_pfetch_offset + `LMQ_ENTRIES;
parameter                                                  fifo_ldq_req_offset = fifo_ldq_req_tid_offset + (`THREADS) * `LMQ_ENTRIES;
parameter                                                  ldqe_val_offset = fifo_ldq_req_offset + (`LMQ_ENTRIES) * `LMQ_ENTRIES;
parameter                                                  ldqe_req_cmpl_offset = ldqe_val_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_cntr_reset_offset = ldqe_req_cmpl_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_resent_ecc_err_offset = ldqe_cntr_reset_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_reset_cpl_rpt_offset = ldqe_resent_ecc_err_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_itag_offset = ldqe_reset_cpl_rpt_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_thrd_id_offset = ldqe_itag_offset + (`ITAG_SIZE_ENC) * `LMQ_ENTRIES;
parameter                                                  ldqe_wimge_offset = ldqe_thrd_id_offset + `THREADS * `LMQ_ENTRIES;
parameter                                                  ldqe_byte_swap_offset = ldqe_wimge_offset + 5 * `LMQ_ENTRIES;
parameter                                                  ldqe_resv_offset = ldqe_byte_swap_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_pfetch_offset = ldqe_resv_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_op_size_offset = ldqe_pfetch_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_tgpr_offset = ldqe_op_size_offset + 3 * `LMQ_ENTRIES;
parameter                                                  ldqe_usr_def_offset = ldqe_tgpr_offset + (`LMQ_ENTRIES) * (AXU_TARGET_ENC);
parameter                                                  ldqe_class_id_offset = ldqe_usr_def_offset + 4 * `LMQ_ENTRIES;
parameter                                                  ldqe_perf_events_offset = ldqe_class_id_offset + 2 * `LMQ_ENTRIES;
parameter                                                  ldqe_dvc_offset = ldqe_perf_events_offset + 4 * `LMQ_ENTRIES;
parameter                                                  ldqe_ttype_offset = ldqe_dvc_offset + 2 * `LMQ_ENTRIES;
parameter                                                  ldqe_dacrw_offset = ldqe_ttype_offset + 6 * `LMQ_ENTRIES;
parameter                                                  ldqe_p_addr_offset = ldqe_dacrw_offset + 4 * `LMQ_ENTRIES;
parameter                                                  ldqe_mkill_offset = ldqe_p_addr_offset + `REAL_IFAR_WIDTH * `LMQ_ENTRIES;
parameter                                                  ldqe_resolved_offset = ldqe_mkill_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_back_inv_offset = ldqe_resolved_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_back_inv_nFlush_offset = ldqe_back_inv_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_back_inv_np1Flush_offset = ldqe_back_inv_nFlush_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_beat_cntr_offset = ldqe_back_inv_np1Flush_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_dRel_offset = ldqe_beat_cntr_offset + 4 * `LMQ_ENTRIES;
parameter                                                  ldqe_l1_dump_offset = ldqe_dRel_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_dGpr_offset = ldqe_l1_dump_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_axu_offset = ldqe_dGpr_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_lock_set_offset = ldqe_axu_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_watch_set_offset = ldqe_lock_set_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_algebraic_offset = ldqe_watch_set_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_state_offset = ldqe_algebraic_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_sentRel_cntr_offset = ldqe_state_offset + 7 * `LMQ_ENTRIES;
parameter                                                  ex5_lgqe_set_all_offset = ldqe_sentRel_cntr_offset + 4 * `LMQ_ENTRIES;
parameter                                                  ex5_lgqe_set_val_offset = ex5_lgqe_set_all_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_valid_offset = ex5_lgqe_set_val_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_iTag_offset = lgqe_valid_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_ldTag_offset = lgqe_iTag_offset + (`ITAG_SIZE_ENC) * `LGQ_ENTRIES;
parameter                                                  lgqe_thrd_id_offset = lgqe_ldTag_offset + 4 * `LGQ_ENTRIES;
parameter                                                  lgqe_byte_swap_offset = lgqe_thrd_id_offset + `THREADS * `LGQ_ENTRIES;
parameter                                                  lgqe_op_size_offset = lgqe_byte_swap_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_tgpr_offset = lgqe_op_size_offset + 3 * `LGQ_ENTRIES;
parameter                                                  lgqe_gpr_done_offset = lgqe_tgpr_offset + (`LGQ_ENTRIES) * (AXU_TARGET_ENC);
parameter                                                  lgqe_resolved_offset = lgqe_gpr_done_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_back_inv_nFlush_offset = lgqe_resolved_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_back_inv_np1Flush_offset = lgqe_back_inv_nFlush_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_dacrw_offset = lgqe_back_inv_np1Flush_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_dvc_offset = lgqe_dacrw_offset + 4 * `LGQ_ENTRIES;
parameter                                                  lgqe_p_addr_offset = lgqe_dvc_offset + 2 * `LGQ_ENTRIES;
parameter                                                  lgqe_axu_offset = lgqe_p_addr_offset + 7 * `LGQ_ENTRIES;
parameter                                                  lgqe_perf_events_offset = lgqe_axu_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_upd_gpr_ecc_offset = lgqe_perf_events_offset + 4 * `LGQ_ENTRIES;
parameter                                                  lgqe_upd_gpr_eccue_offset = lgqe_upd_gpr_ecc_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_need_cpl_offset = lgqe_upd_gpr_eccue_offset + `LGQ_ENTRIES;
parameter                                                  lgqe_algebraic_offset = lgqe_need_cpl_offset + `LGQ_ENTRIES;
parameter                                                  ldqe_rst_eccdet_offset = lgqe_algebraic_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel2_beats_home_offset = ldqe_rst_eccdet_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel3_beats_home_offset = ldq_rel2_beats_home_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel4_beats_home_offset = ldq_rel3_beats_home_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel5_beats_home_offset = ldq_rel4_beats_home_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel1_entrySent_offset = ldq_rel5_beats_home_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel2_entrySent_offset = ldq_rel1_entrySent_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel3_entrySent_offset = ldq_rel2_entrySent_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel4_sentL1_offset = ldq_rel3_entrySent_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel5_sentL1_offset = ldq_rel4_sentL1_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel6_req_done_offset = ldq_rel5_sentL1_offset + `LMQ_ENTRIES;
parameter                                                  l2_rel1_resp_val_offset = ldq_rel6_req_done_offset + `LMQ_ENTRIES;
parameter                                                  l2_rel2_resp_val_offset = l2_rel1_resp_val_offset + 1;
parameter                                                  ldq_err_inval_rel_offset = l2_rel2_resp_val_offset + 1;
parameter                                                  ldq_err_ecc_det_offset = ldq_err_inval_rel_offset + 1;
parameter                                                  ldq_err_ue_det_offset = ldq_err_ecc_det_offset + 1;
parameter                                                  ldq_rel1_val_offset = ldq_err_ue_det_offset + 1;
parameter                                                  ldq_rel1_arb_val_offset = ldq_rel1_val_offset + 1;
parameter                                                  ldq_rel1_l1_dump_offset = ldq_rel1_arb_val_offset + 1;
parameter                                                  ldq_rel2_l1_dump_offset = ldq_rel1_l1_dump_offset + 1;
parameter                                                  ldq_rel3_l1_dump_offset = ldq_rel2_l1_dump_offset + 1;
parameter                                                  ldq_rel3_clr_relq_offset = ldq_rel3_l1_dump_offset + 1;
parameter                                                  ldq_rel1_resp_qw_offset = ldq_rel3_clr_relq_offset + 1;
parameter                                                  ldq_rel1_cTag_offset = ldq_rel1_resp_qw_offset + 3;
parameter                                                  ldq_rel1_opsize_offset = ldq_rel1_cTag_offset + 4;
parameter                                                  ldq_rel1_wimge_i_offset = ldq_rel1_opsize_offset + 3;
parameter                                                  ldq_rel1_byte_swap_offset = ldq_rel1_wimge_i_offset + 1;
parameter                                                  ldq_rel2_byte_swap_offset = ldq_rel1_byte_swap_offset + 1;
parameter                                                  ldq_rel1_p_addr_offset = ldq_rel2_byte_swap_offset + 1;
parameter                                                  ldq_rel1_dvcEn_offset = ldq_rel1_p_addr_offset + `REAL_IFAR_WIDTH;
parameter                                                  ldq_rel1_lockSet_offset = ldq_rel1_dvcEn_offset + 2;
parameter                                                  ldq_rel1_watchSet_offset = ldq_rel1_lockSet_offset + 1;
parameter                                                  ldq_rel1_tGpr_offset = ldq_rel1_watchSet_offset + 1;
parameter                                                  ldq_rel1_axu_offset = ldq_rel1_tGpr_offset + AXU_TARGET_ENC;
parameter                                                  ldq_rel1_algEn_offset = ldq_rel1_axu_offset + 1;
parameter                                                  ldq_rel1_classID_offset = ldq_rel1_algEn_offset + 1;
parameter                                                  ldq_rel1_tid_offset = ldq_rel1_classID_offset + 2;
parameter                                                  ldq_rel2_tid_offset = ldq_rel1_tid_offset + `THREADS;
parameter                                                  ldq_rel1_dir_tid_offset = ldq_rel2_tid_offset + `THREADS;
parameter                                                  ldqe_relDir_start_offset = ldq_rel1_dir_tid_offset + `THREADS;
parameter                                                  ldq_rel2_set_val_offset = ldqe_relDir_start_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel3_set_val_offset = ldq_rel2_set_val_offset + 1;
parameter                                                  ldq_rel4_set_val_offset = ldq_rel3_set_val_offset + 1;
parameter                                                  ldq_rel2_cclass_offset = ldq_rel4_set_val_offset + 1;
parameter                                                  ldq_rel3_cclass_offset = ldq_rel2_cclass_offset + (57-(64-(`DC_SIZE-3))+1);
parameter                                                  ldq_rel4_cclass_offset = ldq_rel3_cclass_offset + (57-(64-(`DC_SIZE-3))+1);
parameter                                                  ldq_rel1_data_sel_offset = ldq_rel4_cclass_offset + (57-(64-(`DC_SIZE-3))+1);
parameter                                                  ldq_rel0_l2_val_offset = ldq_rel1_data_sel_offset + 1;
parameter                                                  ldq_rel1_l2_val_offset = ldq_rel0_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel2_l2_val_offset = ldq_rel1_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel3_l2_val_offset = ldq_rel2_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel4_l2_val_offset = ldq_rel3_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel5_l2_val_offset = ldq_rel4_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_rel_eccdet_offset = ldq_rel5_l2_val_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_rel_eccdet_ue_offset = ldqe_rel_eccdet_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_upd_gpr_ecc_offset = ldqe_rel_eccdet_ue_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_upd_gpr_eccue_offset = ldqe_upd_gpr_ecc_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_need_cpl_offset = ldqe_upd_gpr_eccue_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_sent_cpl_offset = ldqe_need_cpl_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel1_gpr_val_offset = ldqe_sent_cpl_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel0_upd_gpr_offset = ldq_rel1_gpr_val_offset + 1;
parameter                                                  ldq_rel1_upd_gpr_offset = ldq_rel0_upd_gpr_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel2_upd_gpr_offset = ldq_rel1_upd_gpr_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel3_upd_gpr_offset = ldq_rel2_upd_gpr_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_rel3_drop_cpl_rpt_offset = ldq_rel3_upd_gpr_offset + `LMQ_ENTRIES;
parameter                                                  ldq_l2_rel0_qHitBlk_offset = ldqe_rel3_drop_cpl_rpt_offset + `LMQ_ENTRIES;
parameter                                                  lgq_rel1_gpr_val_offset = ldq_l2_rel0_qHitBlk_offset + 1;
parameter                                                  lgq_rel0_upd_gpr_offset = lgq_rel1_gpr_val_offset + 1;
parameter                                                  lgq_rel1_upd_gpr_offset = lgq_rel0_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  lgq_rel2_upd_gpr_offset = lgq_rel1_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  lgq_rel3_upd_gpr_offset = lgq_rel2_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  lgq_rel4_upd_gpr_offset = lgq_rel3_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  lgq_rel5_upd_gpr_offset = lgq_rel4_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  ldq_rel4_odq_cpl_offset = lgq_rel5_upd_gpr_offset + `LGQ_ENTRIES;
parameter                                                  ldq_rel5_odq_cpl_offset = ldq_rel4_odq_cpl_offset + `LMQ_ENTRIES;
parameter                                                  ldq_rel_qHit_clr_offset = ldq_rel5_odq_cpl_offset + `LMQ_ENTRIES;
parameter                                                  ldqe_qHit_held_offset = ldq_rel_qHit_clr_offset + `LMQ_ENTRIES;
parameter                                                  cpl_grpEntry_last_sel_offset = ldqe_qHit_held_offset + `LMQ_ENTRIES;
parameter                                                  cpl_group_last_sel_offset = cpl_grpEntry_last_sel_offset + 4 * (((`LMQ_ENTRIES + `LGQ_ENTRIES - 1)/4) + 1);
parameter                                                  lq1_iu_execute_vld_offset = cpl_group_last_sel_offset + 4;
parameter                                                  lq1_iu_itag_offset = lq1_iu_execute_vld_offset + `THREADS;
parameter                                                  lq1_iu_n_flush_offset = lq1_iu_itag_offset + `ITAG_SIZE_ENC;
parameter                                                  lq1_iu_np1_flush_offset = lq1_iu_n_flush_offset + 1;
parameter                                                  lq1_iu_exception_val_offset = lq1_iu_np1_flush_offset + 1;
parameter                                                  lq1_iu_dacrw_offset = lq1_iu_exception_val_offset + 1;
parameter                                                  lq1_iu_perf_events_offset = lq1_iu_dacrw_offset + 4;
parameter                                                  ldq_cpl_larx_offset = lq1_iu_perf_events_offset + 4;
parameter                                                  ldq_cpl_binv_offset = ldq_cpl_larx_offset + `THREADS;
parameter                                                  ldq_rel_cmmt_offset = ldq_cpl_binv_offset + `THREADS;
parameter                                                  ldq_rel_need_hole_offset = ldq_rel_cmmt_offset + 1;
parameter                                                  ldq_rel_latency_offset = ldq_rel_need_hole_offset + 1;
parameter                                                  dbg_int_en_offset = ldq_rel_latency_offset + 1;
parameter                                                  ex4_stg_act_offset = dbg_int_en_offset + `THREADS;
parameter                                                  ex5_stg_act_offset = ex4_stg_act_offset + 1;
parameter                                                  rrot_scan_offset = ex5_stg_act_offset + 1;
parameter                                                  scan_right = rrot_scan_offset + 1 - 1;

parameter [0:6]                                            LDQ_IDLE   = 7'b1000000;		// Idle State, Wait for valid request
parameter [0:6]                                            LDQ_VAL    = 7'b0100000;		// Valid Request, need to send request to L2
parameter [0:6]                                            LDQ_RPEN   = 7'b0010000;		// Waiting for Reload
parameter [0:6]                                            LDQ_BEATM  = 7'b0001000;		// Mulitple Beat Request and all have arrived
parameter [0:6]                                            LDQ_ECC    = 7'b0000100;		// Check for ECC error
parameter [0:6]                                            LDQ_DCACHE = 7'b0000010;		// Reload updated L1D$ with all its beats
parameter [0:6]                                            LDQ_CMPL   = 7'b0000001;		// Report ITAG completion
parameter [0:4]                                            rot_max_size = 5'b10000;

wire                                                       tiup;
wire                                                       tidn;
wire [0:scan_right]                                        siv;
wire [0:scan_right]                                        sov;


(* analysis_not_referenced="true" *)
wire                                                       unused;

//!! Bugspray Include: lq_ldq

assign tiup = 1'b1;
assign tidn = 1'b0;

assign unused = l2_lsq_resp_isComing | tidn | ldq_rel0_rot_sel_le[0] | fifo_ldq_req_wrt_ptr[8] | ldq_state_machines_idle;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ACT Generation
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign ex4_stg_act_d = ctl_lsq_ex3_ldreq_val | ctl_lsq_ex3_pfetch_val;
assign ex5_stg_act_d = ex4_stg_act_q;

// EX4 Loadmiss Queue Entry Update ACT
assign ex4_ldqe_act = ldqe_wrt_ptr       & {`LMQ_ENTRIES{ex4_stg_act_q}};
assign ex5_ldqe_act = ex5_ldqe_set_all_q & {`LMQ_ENTRIES{ex5_stg_act_q}};
assign ex4_lgqe_act = lgqe_wrt_ptr       & {`LMQ_ENTRIES{ex4_stg_act_q}};
assign ex5_lgqe_act = ex5_lgqe_set_all_q & {`LMQ_ENTRIES{ex5_stg_act_q}};

// Reload Pipeline ACT
assign rel0_stg_act = ldq_reload_val;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XU Config Bits
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XUCR0[CLS] 128 Byte Cacheline Enabled
// 1 => 128 Byte Cacheline
// 0 => 64 Byte Cacheline
assign spr_xucr0_cls_d = xu_lq_spr_xucr0_cls;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LSU Config Bits
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// LSUCR0[LGE] Load gather Enable
// 1 => load gathering enabled
// 0 => load gathering disabled
assign spr_lsucr0_lge_d = ctl_lsq_spr_lsucr0_lge;

// LSUCR0[LCA] Loadmiss Reload Attempts Count
assign spr_lsucr0_lca_d = ctl_lsq_spr_lsucr0_lca;
assign spr_lsucr0_lca_zero = ~(|(spr_lsucr0_lca_q));
assign spr_lsucr0_lca_ovrd = spr_lsucr0_lca_zero ? 3'b001 : spr_lsucr0_lca_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Completion Interface
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign iu_lq_cp_flush_d = iu_lq_cp_flush;
assign ex4_stg_flush    = |(ctl_lsq_ex4_thrd_id & iu_lq_cp_flush_q);
assign ex5_stg_flush    = |(ctl_lsq_ex5_thrd_id & iu_lq_cp_flush_q) | ctl_lsq_ex5_flush_req;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ODQ->LDQ Resolved Interface
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign odq_ldq_n_flush_d      = odq_ldq_resolved & odq_ldq_n_flush & ~ldq_cpl_odq_zap;
//odq_ldq_np1_flush_d   <= odq_ldq_resolved and not odq_ldq_report_needed and odq_ldq_np1_flush;
assign odq_ldq_resolved_d     = odq_ldq_resolved & (~odq_ldq_report_needed) & ~ldq_cpl_odq_zap;
assign odq_ldq_report_itag_d  = odq_ldq_report_itag;
assign odq_ldq_report_tid_d   = odq_ldq_report_tid;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// L2 Reload Interface
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// cTag(1) = 1 => either an IU reload or MMU reload
assign l2_rel0_resp_val_d     = l2_lsq_resp_val;
assign l2_rel0_resp_ldq_val_d = ldq_relmin1_ldq_val;
assign l2_rel0_resp_cTag_d    = ldq_relmin1_cTag;
assign l2_rel0_resp_qw_d      = l2_lsq_resp_qw;
assign l2_rel0_resp_crit_qw_d = l2_lsq_resp_crit_qw;
assign l2_rel0_resp_l1_dump_d = l2_lsq_resp_l1_dump;
assign ldq_relmin1_ldq_val    = l2_lsq_resp_val & (~l2_lsq_resp_cTag[1]);
assign ldq_relmin1_cTag       = {l2_lsq_resp_cTag[0], l2_lsq_resp_cTag[2:4]};
assign ldq_rel1_data          = l2_lsq_resp_data;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LOAD QUEUE
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// RV is empty indicator
assign rv_lq_rvs_empty_d = rv_lq_rvs_empty;

// Need to block reloads
// 1) RV issued an instruction
// 2) Back-Invalidate Congruence Class collided with Valid Reload Set/Clear Congruence Class
// 3) SPR Directory Read Operation
// 4) REL1 attempt and ECC error detected for same core Tag

// Need to block reloads
// 1) RV issued an instruction with valid reload set congruence class
assign ldq_rel1_set_rviss_dir_coll = |(rv_lq_vld) & rv_lq_isLoad & ldq_rel1_set_val;
// 2) Back-Invalidate Congruence Class collided with Valid Reload Set/Clear Congruence Class
assign ldq_rel1_set_binv_dir_coll = ldq_rel1_collide_binv_q & ldq_rel1_set_val;
// 3) SPR Directory Read Operation and valid reload set congruence class
assign ldq_rel1_set_rd_dir_coll = ctl_lsq_rv1_dir_rd_val & ldq_rel1_set_val;
assign rel2_blk_req_d   = ldq_rel1_set_rviss_dir_coll | ldq_rel1_set_binv_dir_coll | ldq_rel1_set_rd_dir_coll;
assign rel2_rviss_blk_d = ldq_rel1_set_rviss_dir_coll;

// EX4 Address that is used to compare against all loadmiss queue entries
assign ex4_ldreq_d         = ctl_lsq_ex3_ldreq_val;
assign ex4_pfetch_val_d    = ctl_lsq_ex3_pfetch_val;
assign ex4_p_addr_msk      = {ctl_lsq_ex4_p_addr[64-`REAL_IFAR_WIDTH:56], (ctl_lsq_ex4_p_addr[57] | spr_xucr0_cls_q)};
assign ex5_ldreq_val_d     = ctl_lsq_ex4_ldreq_val  & (~(ex4_ldq_full | ctl_lsq_ex4_dReq_val | ex4_stg_flush));
assign ex5_ldreq_val       = ex5_ldreq_val_q & ~ex5_stg_flush;
assign ex5_ldreq_flushed   = ex5_ldreq_val_q &  ex5_stg_flush;
assign ex5_pfetch_val_d    = ex4_pfetch_val_q       & (~(ex4_ldq_full | ctl_lsq_ex4_dReq_val));
assign ex5_pfetch_val      = ex5_pfetch_val_q & ~ctl_lsq_ex5_flush_pfetch;
assign ex5_pfetch_flushed  = ex5_pfetch_val_q &  ctl_lsq_ex5_flush_pfetch;
assign ex5_odq_ldreq_val_d = ctl_lsq_ex4_ldreq_val  & (~ex4_stg_flush);
assign ex5_streq_val_d     = ctl_lsq_ex4_streq_val  & (~ex4_stg_flush);
assign ex5_othreq_val_d    = ctl_lsq_ex4_othreq_val & (~ex4_stg_flush);
assign ex5_p_addr_d        = ctl_lsq_ex4_p_addr;
assign ex5_wimge_d         = ctl_lsq_ex4_wimge;

// Performance Events that need to go to the Completion Unit
assign ex5_cmmt_events         = {ctl_lsq_ex5_cmmt_events, ex5_ld_gath_q};
assign ex5_cmmt_perf_events[0] = ctl_lsq_ex5_perf_val0 & ((ctl_lsq_ex5_perf_sel0 == 4'b1111) ? ex5_cmmt_events[11] :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1110) ? ex5_cmmt_events[10] :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1101) ? ex5_cmmt_events[9]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1100) ? ex5_cmmt_events[8]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1011) ? ex5_cmmt_events[7]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1010) ? ex5_cmmt_events[6]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1001) ? ex5_cmmt_events[5]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b1000) ? ex5_cmmt_events[4]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b0111) ? ex5_cmmt_events[3]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b0110) ? ex5_cmmt_events[2]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b0101) ? ex5_cmmt_events[1]  :
                                                          (ctl_lsq_ex5_perf_sel0 == 4'b0100) ? ex5_cmmt_events[0]  :
                                                          1'b0);
assign ex5_cmmt_perf_events[1] = ctl_lsq_ex5_perf_val1 & ((ctl_lsq_ex5_perf_sel1 == 4'b1111) ? ex5_cmmt_events[11] :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1110) ? ex5_cmmt_events[10] :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1101) ? ex5_cmmt_events[9]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1100) ? ex5_cmmt_events[8]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1011) ? ex5_cmmt_events[7]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1010) ? ex5_cmmt_events[6]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1001) ? ex5_cmmt_events[5]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b1000) ? ex5_cmmt_events[4]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b0111) ? ex5_cmmt_events[3]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b0110) ? ex5_cmmt_events[2]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b0101) ? ex5_cmmt_events[1]  :
                                                          (ctl_lsq_ex5_perf_sel1 == 4'b0100) ? ex5_cmmt_events[0]  :
                                                          1'b0);
assign ex5_cmmt_perf_events[2] = ctl_lsq_ex5_perf_val2 & ((ctl_lsq_ex5_perf_sel2 == 4'b1111) ? ex5_cmmt_events[11] :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1110) ? ex5_cmmt_events[10] :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1101) ? ex5_cmmt_events[9]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1100) ? ex5_cmmt_events[8]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1011) ? ex5_cmmt_events[7]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1010) ? ex5_cmmt_events[6]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1001) ? ex5_cmmt_events[5]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b1000) ? ex5_cmmt_events[4]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b0111) ? ex5_cmmt_events[3]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b0110) ? ex5_cmmt_events[2]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b0101) ? ex5_cmmt_events[1]  :
                                                          (ctl_lsq_ex5_perf_sel2 == 4'b0100) ? ex5_cmmt_events[0]  :
                                                          1'b0);
assign ex5_cmmt_perf_events[3] = ctl_lsq_ex5_perf_val3 & ((ctl_lsq_ex5_perf_sel3 == 4'b1111) ? ex5_cmmt_events[11] :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1110) ? ex5_cmmt_events[10] :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1101) ? ex5_cmmt_events[9]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1100) ? ex5_cmmt_events[8]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1011) ? ex5_cmmt_events[7]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1010) ? ex5_cmmt_events[6]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1001) ? ex5_cmmt_events[5]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b1000) ? ex5_cmmt_events[4]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b0111) ? ex5_cmmt_events[3]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b0110) ? ex5_cmmt_events[2]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b0101) ? ex5_cmmt_events[1]  :
                                                          (ctl_lsq_ex5_perf_sel3 == 4'b0100) ? ex5_cmmt_events[0]  :
                                                          1'b0);
assign ex6_cmmt_perf_events_d = ex5_cmmt_perf_events;


// Need to Mask off bit 57 of Back-Invalidate Address depending on the Cacheline Size we are running with
assign l2_back_inv_addr_msk = l2_back_inv_addr[64 - `REAL_IFAR_WIDTH:57];

// Init Number of expected Beats
assign ldqe_beat_init = {1'b0, ((~spr_xucr0_cls_q)), 2'b00};

// LDQ Entry WRT Pointer Logic
// Look for first IDLE state machine from LOADMISSQ(0) -> LOADMISSQ(`LMQ_ENTRIES-1)
assign ldqe_wrt_ptr[0] = ldqe_available[0];
generate begin : LdPriWrt
      genvar                                                  ldq;
      for (ldq=1; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : LdPriWrt
         assign ldqe_wrt_ptr[ldq] = &((~ldqe_available[0:ldq - 1])) & ldqe_available[ldq];
      end
   end
endgenerate

// Check for only 1 entry available
// Look for first IDLE state machine from LOADMISSQ(`LMQ_ENTRIES-1) -> LOADMISSQ(0)
assign ldqe_opposite_ptr[`LMQ_ENTRIES - 1] = ldqe_available[`LMQ_ENTRIES - 1];
generate begin : lastMach
      genvar                                                  ldq;
      for (ldq = 0; ldq <= `LMQ_ENTRIES-2; ldq=ldq+1) begin : lastMach
         assign ldqe_opposite_ptr[ldq] = &((~ldqe_available[ldq + 1:`LMQ_ENTRIES - 1])) & ldqe_available[ldq];
      end
   end
endgenerate

assign ex4_one_machine_avail = |(ldqe_wrt_ptr & ldqe_opposite_ptr);

// Oldest Load can use state machine
assign ex4_oldest_load        = (odq_ldq_oldest_ld_itag == ctl_lsq_ex4_itag) & |(odq_ldq_oldest_ld_tid & ctl_lsq_ex4_thrd_id);
assign ex4_reserved_taken     = (ctl_lsq_ex4_ldreq_val | ex4_pfetch_val_q) & ex4_one_machine_avail & (~ex4_oldest_load);
assign ex5_reserved_taken_d   = ex4_reserved_taken;
assign ex4_resv_taken_restart = ctl_lsq_ex4_ldreq_val & ex4_one_machine_avail & (~(ex4_oldest_load | ex4_stg_flush));
assign ex5_resv_taken_restart_d = ex4_resv_taken_restart;

// Load Queue Entry Update Control
assign ex4_ldqe_set_val      = ldqe_wrt_ptr & {`LMQ_ENTRIES{((ctl_lsq_ex4_ldreq_val & (~ex4_stg_flush)) | ex4_pfetch_val_q)}};
assign ex4_ldqe_set_all      = ldqe_wrt_ptr & {`LMQ_ENTRIES{(ex4_ldreq_q | ex4_pfetch_val_q)}};
assign ex5_ldqe_set_all_d    = ex4_ldqe_set_all;
assign ex5_ldqe_set_val_d    = ex4_ldqe_set_val;
assign ex5_ldm_entry         = ex5_ldqe_set_val_q & {`LMQ_ENTRIES{(ex5_ldreq_val_q | ex5_pfetch_val_q)}};
assign ex6_ldqe_pfetch_val_d = ex5_ldqe_set_all_q & {`LMQ_ENTRIES{(ex5_pfetch_val & ~ex5_drop_req_val)}};
assign ex7_ldqe_pfetch_val_d = ex6_ldqe_pfetch_val_q;
assign ex7_pfetch_blk_val    = |(ex7_ldqe_pfetch_val_q) & odq_ldq_ex7_pfetch_blk;
assign ex7_pfetch_blk_tid    = ctl_lsq_ex7_thrd_id & {`THREADS{ex7_pfetch_blk_val}};

// Thread Quiesced OR reduce
always @(*) begin: tidQuiesce
   reg [0:`THREADS-1]                                      tidQ;

   (* analysis_not_referenced="true" *)

   integer                                                 ldq;
   tidQ = {`THREADS{1'b0}};
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin
      tidQ = (ldqe_tid_inuse[ldq]) | tidQ;
   end
   ldq_all_req_home <= ~tidQ;
end

assign lq_xu_quiesce_d        =   ldq_all_req_home & stq_ldq_empty & rv_lq_rvs_empty_q & ctl_lsq_pf_empty & ctl_lsq_ldp_idle;
assign lq_mm_lmq_stq_empty_d  = &(ldq_all_req_home & stq_ldq_empty & rv_lq_rvs_empty_q & ctl_lsq_pf_empty & ctl_lsq_ldp_idle);
assign lq_pc_ldq_quiesce_d    = ldq_all_req_home & ctl_lsq_ldp_idle;
assign lq_pc_stq_quiesce_d    = stq_ldq_empty;
assign lq_pc_pfetch_quiesce_d = ctl_lsq_pf_empty;

generate begin : loadQ
      genvar                                                  ldq;
      for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : loadQ
         wire [0:3]  ldqDummy;
         assign ldqDummy = ldq[3:0];

         // ##############################################
         // ##############################################
         // LDQ ENTRY State Machine
         // ##############################################
         // ##############################################

         assign ldqe_complete[ldq] = (ldqe_sent_cpl_q[ldq] | ldqe_kill[ldq]) & ldqe_gather_done[ldq];

         always @(*) begin: ldqState
            ldqe_nxt_state[ldq]        <= LDQ_IDLE;
            ldqe_val_d[ldq]            <= ldqe_val_q[ldq];
            ldqe_req_cmpl_d[ldq]       <= 1'b0;
            ldqe_rst_eccdet[ldq]       <= 1'b0;
            ldqe_cntr_reset_d[ldq]     <= 1'b0;
            ldqe_resent_ecc_err_d[ldq] <= ldqe_resent_ecc_err_q[ldq];
            ldqe_ecc_err_dgpr[ldq]     <= 1'b0;
            ldqe_reset_cpl_rpt_d[ldq]  <= 1'b0;

            case (ldqe_state_q[ldq])

               // IDLE State
               LDQ_IDLE :		                                                                // STATE(0)
                  if (ex4_ldqe_set_val[ldq] == 1'b1 & ctl_lsq_ex4_dReq_val == 1'b0)	begin       // Instructions going to L2
                     ldqe_nxt_state[ldq]        <= LDQ_VAL;
                     ldqe_val_d[ldq]            <= 1'b1;
                     ldqe_cntr_reset_d[ldq]     <= 1'b1;
                     ldqe_resent_ecc_err_d[ldq] <= 1'b0;
                     ldqe_reset_cpl_rpt_d[ldq]  <= 1'b1;
                  end
                  else
                  begin
                     ldqe_nxt_state[ldq]        <= LDQ_IDLE;
                     ldqe_val_d[ldq]            <= 1'b0;
                     ldqe_cntr_reset_d[ldq]     <= 1'b0;
                     ldqe_resent_ecc_err_d[ldq] <= 1'b0;
                     ldqe_reset_cpl_rpt_d[ldq]  <= 1'b1;
                  end

               // VALID State
               LDQ_VAL :		                                                                // STATE(1)
                  if (ex4_ldqe_set_val[ldq] == 1'b1 & ctl_lsq_ex4_dReq_val == 1'b0)	begin       // Load Hit in the L1D$ and back-to-back load wants to use same entry
                     ldqe_nxt_state[ldq]           <= LDQ_VAL;
                     ldqe_val_d[ldq]               <= 1'b1;
                  end
                  else if (ldqe_zap[ldq] == 1'b1 & ldqe_sent[ldq] == 1'b0)	begin             // Entry Zap and havent Sent
                     ldqe_nxt_state[ldq]           <= LDQ_IDLE;
                     ldqe_req_cmpl_d[ldq]          <= 1'b1;
                     ldqe_val_d[ldq]               <= 1'b0;
                  end
                  else if (ldqe_sent[ldq] == 1'b1)	begin                                     // Request sent to L2
                     ldqe_nxt_state[ldq]           <= LDQ_RPEN;
                     ldqe_val_d[ldq]               <= 1'b0;
                  end
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_VAL;

               // RELOAD PENDING State
               LDQ_RPEN :		                                                               // STATE(2)
                  if (ldqe_wimge_q[ldq][1] == 1'b1 & ldq_relmin1_l2_val[ldq] == 1'b1)		   // Cache-Inhibited Reload
                     ldqe_nxt_state[ldq]           <= LDQ_ECC;
                  else if (ldqe_wimge_q[ldq][1] == 1'b0 & ldq_relmin1_l2_val[ldq] == 1'b1)	// Cacheable Reload Beat0 Received
                     ldqe_nxt_state[ldq]           <= LDQ_BEATM;
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_RPEN;

               // RELOAD MULTIPLE BEATS State
               LDQ_BEATM :		                                                               // STATE(3)
                  if (ldq_rel1_beats_home[ldq] == 1'b1 & ldq_rel1_l2_val_q[ldq] == 1'b1)
                     ldqe_nxt_state[ldq]           <= LDQ_ECC;
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_BEATM;

               // RELOAD CHECK ECC State
               LDQ_ECC :		                                                               // STATE(4)
                  if (ldq_rel2_l2_val_q[ldq] == 1'b1 & ldqe_rel_eccdet[ldq] == 1'b1) begin   // Correctable ECC Error detected on any Beats
                     ldqe_nxt_state[ldq]           <= LDQ_RPEN;
                     ldqe_rst_eccdet[ldq]          <= 1'b1;
                     ldqe_cntr_reset_d[ldq]        <= 1'b1;
                     ldqe_resent_ecc_err_d[ldq]    <= 1'b1;
                     ldqe_ecc_err_dgpr[ldq]        <= 1'b1;
                  end
                  else if (ldq_rel2_l2_val_q[ldq] == 1'b1)		                              // Uncorrectable or Reload Complete
                     ldqe_nxt_state[ldq]           <= LDQ_DCACHE;
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_ECC;

               // RELOAD UPDATE CACHE State
               LDQ_DCACHE :		                                                            // STATE(5)
                  if (ldq_rel6_req_done_q[ldq] == 1'b1) begin                                // Data Cache and Directory has been updated
                     if (ldqe_complete[ldq] == 1'b1) begin                                   // Entry was Machine Killed or Already sent completion report
                        ldqe_nxt_state[ldq]        <= LDQ_IDLE;
                        ldqe_reset_cpl_rpt_d[ldq]  <= 1'b1;
                        ldqe_resent_ecc_err_d[ldq] <= 1'b0;
                        ldqe_req_cmpl_d[ldq]       <= 1'b1;
                        ldqe_rst_eccdet[ldq]       <= 1'b1;		                              // Reset ECC Error Indicator
                     end
                     else
                        // Entry has not been Machine Killed
                        ldqe_nxt_state[ldq]        <= LDQ_CMPL;
                  end
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_DCACHE;

               // COMPLETION REPORT
               LDQ_CMPL :		                                                               // STATE(6)
                  if (ldqe_complete[ldq] == 1'b1) begin                                      // Entry was Machine Killed or Completion report returned
                     ldqe_nxt_state[ldq]           <= LDQ_IDLE;
                     ldqe_reset_cpl_rpt_d[ldq]     <= 1'b1;
                     ldqe_resent_ecc_err_d[ldq]    <= 1'b0;
                     ldqe_req_cmpl_d[ldq]          <= 1'b1;
                     ldqe_rst_eccdet[ldq]          <= 1'b1;	                                 // Reset ECC Error Indicator
                  end
                  else
                     ldqe_nxt_state[ldq]           <= LDQ_CMPL;

               default :
                  begin
                     ldqe_nxt_state[ldq]           <= LDQ_IDLE;
                     ldqe_val_d[ldq]               <= ldqe_val_q[ldq];
                     ldqe_req_cmpl_d[ldq]          <= 1'b0;
                     ldqe_rst_eccdet[ldq]          <= 1'b0;
                     ldqe_cntr_reset_d[ldq]        <= 1'b0;
                     ldqe_resent_ecc_err_d[ldq]    <= ldqe_resent_ecc_err_q[ldq];
                     ldqe_ecc_err_dgpr[ldq]        <= 1'b0;
                     ldqe_reset_cpl_rpt_d[ldq]     <= 1'b0;
                  end
            endcase
         end

         assign ldqe_state_d[ldq]      = ldqe_nxt_state[ldq];
         assign ldqe_rst_eccdet_d[ldq] = ldqe_rst_eccdet[ldq];

         // ##############################################
         // Load Queue Contents

         // Drop Reload
         assign ldqe_dRel_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_drop_rel : ldqe_dRel_q[ldq];

         // Instructions ITAG
         assign ldqe_itag_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_itag : ldqe_itag_q[ldq];

         // Request Physical Address Bits
         assign ldqe_p_addr_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_p_addr : ldqe_p_addr_q[ldq];

         // WIMGE Bits
         assign ldqe_wimge_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_wimge : ldqe_wimge_q[ldq];

         assign ldqe_wimge_i[ldq] = ldqe_wimge_q[ldq][1];
         assign ldqe_wimge_g[ldq] = ldqe_wimge_q[ldq][3];

         // Byte Swap Bits
         assign ldqe_byte_swap_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_byte_swap : ldqe_byte_swap_q[ldq];

         // LARX Bits
         assign ldqe_resv_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_is_resv : ldqe_resv_q[ldq];

         // PreFetch Valid Bits
         assign ldqe_pfetch_d[ldq] = ex4_ldqe_set_all[ldq] ? ex4_pfetch_val_q : ldqe_pfetch_q[ldq];

         // `THREADS Bits
         assign ldqe_thrd_id_d[ldq] = ex4_ldqe_set_all[ldq] ? ctl_lsq_ex4_thrd_id : ldqe_thrd_id_q[ldq];

         // lock_set Bits
         assign ldqe_lock_set_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_lock_set : ldqe_lock_set_q[ldq];

         // watch_set Bits
         assign ldqe_watch_set_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_watch_set : ldqe_watch_set_q[ldq];

         // op_size Bits
         assign ldqe_op_size_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_opsize : ldqe_op_size_q[ldq];

         // tgpr Bits
         assign ldqe_tgpr_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_tgpr : ldqe_tgpr_q[ldq];

         // axu Bits
         assign ldqe_axu_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_axu_val : ldqe_axu_q[ldq];

         // usr_def Bits
         assign ldqe_usr_def_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_usr_def : ldqe_usr_def_q[ldq];

         // algebraic Bits
         assign ldqe_algebraic_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_algebraic : ldqe_algebraic_q[ldq];

         // class_id Bits
         assign ldqe_class_id_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_class_id : ldqe_class_id_q[ldq];

         // performance events
         assign ldqe_perf_events_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ex5_cmmt_perf_events : ldqe_perf_events_q[ldq];

         // GPR Update is done
         // ldqe_set_gpr_done = "11"         => This should never occur, will need bugspray here
         assign ldqe_set_gpr_done[ldq] = {ex5_ldqe_set_all_q[ldq], ldq_rel2_upd_gpr_q[ldq]};

         // DVC Bits
         assign ldqe_dvc_d[ldq] = (ldqe_set_gpr_done[ldq] == 2'b01) ? ldq_rel2_dvc :
                                  (ldqe_set_gpr_done[ldq] == 2'b00) ? ldqe_dvc_q[ldq] :
                                  ctl_lsq_ex5_dvc;

         // ttype Bits
         assign ldqe_ttype_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_ttype : ldqe_ttype_q[ldq];

         // DAC Status Bits
         assign ldqe_dacrw_d[ldq] = ex5_ldqe_set_all_q[ldq] ? ctl_lsq_ex5_dacrw : ldqe_dacrw_q[ldq];

         // Load Request was restarted due to load-hit-load
         assign ldqe_qHit_held_sel[ldq] = {ex4_load_qHit_upd[ldq], ldq_rel2_qHit_clr[ldq]};

         assign ldqe_qHit_held_d[ldq] = (ldqe_qHit_held_sel[ldq] == 2'b00) ? ldqe_qHit_held_q[ldq] :
                                        (ldqe_qHit_held_sel[ldq] == 2'b10) ? 1'b1 :
                                        1'b0;

         // ##############################################

         // ##############################################
         // ##############################################
         // LDQ Control
         // ##############################################
         // ##############################################

         // Request Hit Detect Logic
         // Detecting QHits for loads hitting against other loadmisses, used for the entry snoop detection
         assign ldqe_p_addr_msk[ldq]  = {ldqe_p_addr_q[ldq][64 - `REAL_IFAR_WIDTH:56], (ldqe_p_addr_q[ldq][57] | spr_xucr0_cls_q)};
         assign ex4_addr_m_queue[ldq] = (ldqe_p_addr_msk[ldq] == ex4_p_addr_msk);
         assign ex4_qw_hit_queue[ldq] = ~spr_xucr0_cls_q ? (ldqe_p_addr_q[ldq][58:59] == ctl_lsq_ex4_p_addr[58:59]) :
                                                           (ldqe_p_addr_q[ldq][57:59] == ctl_lsq_ex4_p_addr[57:59]);
         assign ex4_thrd_id_m[ldq]   = |(ldqe_thrd_id_q[ldq] & ctl_lsq_ex4_thrd_id);
         assign ex4_larx_hit[ldq]    = ex4_thrd_id_m[ldq] & ldqe_resv_q[ldq];
         assign ex4_guarded_hit[ldq] = ex4_thrd_id_m[ldq] & ldqe_wimge_g[ldq] & ctl_lsq_ex4_wimge[3];
         assign ex4_req_hit_ldq[ldq] = ex4_larx_hit[ldq] | ex4_guarded_hit[ldq] | ex4_addr_m_queue[ldq];

         // Want to only gather from request that hasnt been sent to the L2 only if the thread matches, if the thread doesnt match,
         // the request in ldm queue may get flushed and the gathered request will still be valid which causes the gathered request
         // to match on an invalid reload.
         // It is not thread dependent if the request has already been sent to the L2, we are guaranteed to get data back if the request in ldm queue
         // is flushed.
         assign ldqe_entry_gatherable[ldq] = ((ldqe_state_q[ldq][1] & ex4_thrd_id_m[ldq] & (~ex5_inv_ldqe[ldq])) | ldqe_state_q[ldq][2]) &
                                             (~(ldq_relmin1_l2_val[ldq] | ldqe_wimge_q[ldq][1] | ldqe_resv_q[ldq]));
         assign ex4_entry_gatherable[ldq]  = ex4_addr_m_queue[ldq] & ctl_lsq_ex4_gath_load & spr_lsucr0_lge_q & ~ex4_qw_hit_queue[ldq];
         assign ex4_entry_gath_ld[ldq]     = ex4_entry_gatherable[ldq] & ldqe_entry_gatherable[ldq] &  ld_gath_not_full & ~ex4_lgq_qw_hit[ldq];
         // Performance Events
         assign ex4_entry_gath_full[ldq]   = ex4_entry_gatherable[ldq] & ldqe_entry_gatherable[ldq] & ~ld_gath_not_full;
         assign ex4_entry_gath_qwhit[ldq]  = ex4_entry_gatherable[ldq] & ldqe_entry_gatherable[ldq] &  ld_gath_not_full &  ex4_lgq_qw_hit[ldq];

         // THIS STATEMENT CHANGES WHEN THE LDQ DOESNT HOLD UNRESOLVED ITAGS WHEN THE RELOAD IS COMPLETE
         // WILL HAVE TO CHANGE LDQE_STATE_Q(LDQ)(2 TO 6)
         //    ldqe_inuse(ldq)             = (ldqe_state_q(ldq)(1) and not ex5_inv_ldqe(ldq)) or or_reduce(ldqe_state_q(ldq)(2 to 5));
         assign ldqe_inuse[ldq]               = (ldqe_state_q[ldq][1] & (~ex5_inv_ldqe[ldq])) | |(ldqe_state_q[ldq][2:6]);
         assign ldqe_tid_inuse[ldq]           = (ldqe_thrd_id_q[ldq] & {`THREADS{ldqe_inuse[ldq]}});
         assign ldqe_req_outstanding[ldq]     = (ldqe_state_q[ldq][1] & (~ex5_inv_ldqe[ldq])) | |(ldqe_state_q[ldq][2:5]);
         assign ldqe_tid_req_outstanding[ldq] = ldqe_thrd_id_q[ldq] & {`THREADS{ldqe_req_outstanding[ldq]}};
         assign ldqe_req_able_to_hold[ldq]    = (ldqe_state_q[ldq][1] & ex4_thrd_id_m[ldq] & (~ex5_inv_ldqe[ldq])) | |(ldqe_state_q[ldq][2:5]);
         assign ex4_entry_load_qHit[ldq]      = ldqe_req_outstanding[ldq] & ex4_req_hit_ldq[ldq] & (ctl_lsq_ex4_ldreq_val | ex4_pfetch_val_q) & (~ctl_lsq_ex4_dReq_val);

         // Detect when to update qHit_held and when to report SET_HOLD to RV for a particular itag
         assign ldqe_rel_blk_qHit_held[ldq] = ldq_rel2_qHit_clr[ldq] | ldq_rel_qHit_clr_q[ldq] | ex4_entry_gath_ld[ldq];
         assign ex4_load_qHit_upd[ldq]      = ldqe_req_able_to_hold[ldq] & ex4_req_hit_ldq[ldq] & (~ldqe_rel_blk_qHit_held[ldq]) & ctl_lsq_ex4_ldreq_val & (~ctl_lsq_ex4_dReq_val);

         // Store Request Hit against outstanding Loadmiss Request
         // It shouldnt matter if the outstanding load was zapped, the sync still needs to wait for the reload to complete if the request was sent out
         // this is the case where a load went out, took forever to come back, got zapped while waiting for reload, sync came down the pipe,
         // sync cant go out until reload is back, dci needs to look at all threads with outstanding requests, dci needs to wait until they are all back
         assign ex5_ldm_hit_d[ldq] = ctl_lsq_ex4_streq_val & ldqe_req_outstanding[ldq] & (ex4_req_hit_ldq[ldq] | (ex4_thrd_id_m[ldq] & ctl_lsq_ex4_is_sync) | ctl_lsq_ex4_all_thrd_chk);

         // Entry Was Back-Invalidated
         assign ldqe_back_inv[ldq] = (ldqe_p_addr_msk[ldq] == l2_back_inv_addr_msk) & ldqe_inuse[ldq] & l2_back_inv_val;

         assign ldqe_back_inv_d[ldq] = ({ex4_ldqe_set_all[ldq], ldqe_back_inv[ldq]} == 2'b00) ? ldqe_back_inv_q[ldq] :
                                       ({ex4_ldqe_set_all[ldq], ldqe_back_inv[ldq]} == 2'b01) ? 1'b1 :
                                       1'b0;

         // Determine if this entry was for the CP_NEXT itag
         begin : ldqeItagTid
            genvar                                                  tid;
            for (tid=0; tid<`THREADS; tid=tid+1) begin : ldqeItagTid
               assign ldqe_cpNext_tid[ldq][tid] = ldqe_thrd_id_q[ldq][tid] & (ldqe_itag_q[ldq] == iu_lq_cp_next_itag_q[tid]);
            end
         end

         assign ldqe_cpNext_val[ldq] = |(ldqe_cpNext_tid[ldq]);

         // Want to Flush if the loadqueue was back-invalidated or the L1 Dump signal is on for the reload
         assign ldqe_back_inv_flush_upd[ldq] = ldqe_back_inv[ldq] | ldq_rel_l1_dump[ldq];

         // NEED TO REVISIT THIS STATEMENT, I BELIEVE THIS SCENARIO ONLY EXISTS IF THE LDQ HOLDS UNRESOLVED ITAGS WHEN THE RELOAD IS COMPLETE
         // Want to only capture the first back-invalidate
         // There is a hole where it was a cp_next itag when the back-invalidate hit
         // then an older loadmiss went to the L2, got newer data
         // another back-invalidate comes in and sets the cpnext_val indicator causing an NP1 flush
         // when we really wanted an N flush
         assign ldqe_back_inv_nFlush_d[ldq] = ({ex4_ldqe_set_all[ldq], ldqe_back_inv_flush_upd[ldq]} == 2'b00) ? ldqe_back_inv_nFlush_q[ldq] :
                                              ({ex4_ldqe_set_all[ldq], ldqe_back_inv_flush_upd[ldq]} == 2'b01) ? (ldqe_back_inv_nFlush_q[ldq] | ((~ldqe_cpNext_val[ldq]))) :
                                              1'b0;

         assign ldqe_back_inv_np1Flush_d[ldq] = ({ex4_ldqe_set_all[ldq], ldqe_back_inv_flush_upd[ldq]} == 2'b00) ? ldqe_back_inv_np1Flush_q[ldq] :
                                                ({ex4_ldqe_set_all[ldq], ldqe_back_inv_flush_upd[ldq]} == 2'b01) ? (ldqe_back_inv_np1Flush_q[ldq] | ldqe_cpNext_val[ldq]) :
                                                1'b0;

         // Load Request access to L2 Available
         assign ldqe_need_l2send[ldq] = ldqe_val_q[ldq] & (~ex5_ldqe_set_all_q[ldq]);

         // Load Entry Sent to L2
         assign ldqe_sent[ldq] = ((fifo_ldq_req0_avail & fifo_ldq_req_q[0][ldq]) |                    // Sent from FIFO
                                 ((ex5_ldreq_val | ex5_pfetch_val) & ex5_ldqe_set_all_q[ldq] &
                                  (~(ex5_drop_req_val | ldq_l2_req_need_send)))) &                    // Sent from Pipe
                                  arb_ldq_ldq_unit_sel;

         // entry needs to be invalidated
         // 1) Load was a Load Hit in the L1D$
         // 2) There was only 1 state machine and non oldest load took it
         assign ex5_inv_ldqe[ldq] = ex5_ldqe_set_all_q[ldq] & (ex5_drop_req_val | ex5_ldreq_flushed | ex5_pfetch_flushed);

         // Determine if Entry should be Flushed
         // CP Flush
         assign ldqe_cp_flush[ldq] = |(iu_lq_cp_flush_q & ldqe_thrd_id_q[ldq]) & ~ldqe_pfetch_q[ldq];

         // OrderQ Flush
         assign ldqe_odq_flush[ldq] = (odq_ldq_report_itag_q == ldqe_itag_q[ldq]) & |(odq_ldq_report_tid_q & ldqe_thrd_id_q[ldq]) & odq_ldq_n_flush_q;

         // OrderQ Prefetch Block due to the prefetch would have caused an NFlush of user code
         assign ldqe_pfetch_flush[ldq] = ex7_ldqe_pfetch_val_q[ldq] & odq_ldq_ex7_pfetch_blk;

         assign ldqe_flush[ldq] = (ldqe_cp_flush[ldq] | ldqe_odq_flush[ldq] | ldqe_pfetch_flush[ldq]) & (~ldqe_state_q[ldq][0]);

         // Entry is Deleted when the entry is flushed or when we determine the entry was a load hit
         assign ldqe_mkill[ldq] = ldqe_flush[ldq];
         assign ldqe_kill[ldq]  = ldqe_mkill[ldq] | ldqe_mkill_q[ldq];
         assign ldqe_zap[ldq]   = ldqe_mkill[ldq] | ex5_inv_ldqe[ldq];

         // Load Request got Machine Killed
         assign ldqe_mkill_d[ldq] = ({ex4_ldqe_set_all[ldq], ldqe_mkill[ldq]} == 2'b00) ? ldqe_mkill_q[ldq] :
                                    ({ex4_ldqe_set_all[ldq], ldqe_mkill[ldq]} == 2'b01) ? 1'b1 :
                                    1'b0;

         // Load Entry Has Resolved In Order Queue
         assign ldqe_resolved[ldq] = (ldqe_itag_q[ldq] == odq_ldq_report_itag_q) & |(odq_ldq_report_tid_q & ldqe_thrd_id_q[ldq]) & odq_ldq_resolved_q & (~ldqe_state_q[ldq][0]);

         assign ldqe_resolved_d[ldq] = ({ex4_ldqe_set_all[ldq], ldqe_resolved[ldq]} == 2'b00) ? ldqe_resolved_q[ldq] :
                                       ({ex4_ldqe_set_all[ldq], ldqe_resolved[ldq]} == 2'b01) ? 1'b1 :
                                       1'b0;

         // ##############################################
         // ##############################################
         // LDQ Reload Control
         // ##############################################
         // ##############################################

         // Reload for Entry is valid
         assign ldqe_ctrl_act[ldq]           = ~ldqe_state_q[ldq][0];
         assign ldqe_rel_inprog[ldq]         = |(ldqe_state_q[ldq][2:3]);
         assign ldqe_rel0_cTag[ldq]          = (ldqDummy == ldq_resp_cTag);
         assign ldqe_rel1_cTag[ldq]          = (ldqDummy == ldq_rel1_cTag_q);
         assign ldqe_relmin1_cTag[ldq]       = (ldqDummy == ldq_relmin1_cTag);
         assign ldq_relmin1_l2_val[ldq]      = ldq_relmin1_ldq_val & ldqe_relmin1_cTag[ldq] & ldqe_rel_inprog[ldq];
         assign ldq_rel0_l2_val_d[ldq]       = ldq_relmin1_l2_val[ldq];
         assign ldq_relmin1_l2_inval[ldq]    = ldq_relmin1_ldq_val & ldqe_relmin1_cTag[ldq] & (~ldqe_rel_inprog[ldq]);
         assign ldq_rel_l1_dump[ldq]         = ldq_rel0_l2_val_q[ldq] & l2_rel0_resp_l1_dump_q;
         assign ldq_rel0_arb_sent[ldq]       = ldq_rel0_arb_val & ldqe_rel0_cTag[ldq];
         assign ldq_rel_l2_l1dumpBlk[ldq]    = ldq_rel0_l2_val_q[ldq] & l2_rel0_resp_l1_dump_q & (ldqe_watch_set_q[ldq] | ldqe_lock_set_q[ldq]);
         assign ldq_relmin1_l2_qHitBlk[ldq]  = ldqe_relmin1_cTag[ldq] & ldqe_qHit_held_q[ldq];
         // Reload Data Queue Parity Error should cause an NFlush only if the request was a DCBT[ST]LS or an LDAWX
         assign ldqe_cpNext_ecc_err[ldq]     = (ldqe_lock_set_q[ldq] | ldqe_watch_set_q[ldq]) & (ldqe_resent_ecc_err_q[ldq] | ldqe_rel_rdat_perr[ldq]);

         // Either L2 Reload or Reload ARB is valid
         assign ldq_rel0_entrySent[ldq]    = ldq_reload_val & ldqe_rel0_cTag[ldq] & (~(ldqe_wimge_i[ldq] | ldqe_drop_reload_val[ldq] | ldq_rel_l1_dump[ldq]));
         assign ldq_rel1_entrySent_d[ldq] = ldq_rel0_entrySent[ldq]    & ~ldqe_rst_eccdet_q[ldq];
         assign ldq_rel2_entrySent_d[ldq] = ldq_rel1_entrySent_q[ldq] & ~ldqe_rst_eccdet_q[ldq];
         assign ldq_rel3_entrySent_d[ldq] = ldq_rel2_entrySent_q[ldq] & ~ldqe_rst_eccdet_q[ldq];

         // L2 reload is valid
         assign ldq_rel1_l2_val_d[ldq]     = ldq_rel0_l2_val_q[ldq];
         assign ldq_rel2_l2_val_d[ldq]     = ldq_rel1_l2_val_q[ldq];
         assign ldq_rel3_l2_val_d[ldq]     = ldq_rel2_l2_val_q[ldq] & (~ldqe_rel_eccdet[ldq]);
         assign ldq_rel4_l2_val_d[ldq]     = ldq_rel3_l2_val_q[ldq];
         assign ldq_rel5_l2_val_d[ldq]     = ldq_rel4_l2_val_q[ldq];

         // L1 Reload is complete, Data Cache has been updated
         assign ldq_rel4_sentL1_d[ldq] = ldq_rel3_entrySent_q[ldq] & ldqe_sentL1[ldq];
         assign ldq_rel5_sentL1_d[ldq] = ldq_rel4_sentL1_q[ldq];

         // Request is complete for REL6 type requests
         //                                                          I=1 load                L2 only load
         assign ldq_rel5_req_noL1done[ldq] = ldq_rel5_l2_val_q[ldq] & (ldqe_wimge_i[ldq] | (ldqe_drop_reload_val[ldq] & ldq_rel5_beats_home_q[ldq]));
         //                                   I=0 L1 Load
         assign ldq_rel5_req_done[ldq]     = ldq_rel5_sentL1_q[ldq] | ldq_rel5_req_noL1done[ldq];
         assign ldq_rel6_req_done_d[ldq]   = ldq_rel5_req_done[ldq];

         // Cache-Inhibited Reload is complete
         assign ldq_rel2_ci_done[ldq] = ldq_rel2_l2_val_q[ldq] & ldqe_wimge_i[ldq];

         // Drop Cacheable Reload is complete
         assign ldq_rel2_drel_done[ldq] = ldq_rel2_l2_val_q[ldq] & ldqe_drop_reload_val[ldq] & ldq_rel2_beats_home_q[ldq];

         // Increment Beat Counter
         assign ldqe_beat_ctrl[ldq] = {ldqe_cntr_reset_q[ldq], ldq_rel0_l2_val_q[ldq]};
         assign ldqe_beat_incr[ldq] = ldqe_beat_cntr_q[ldq] + 4'b0001;

         assign ldqe_beat_cntr_d[ldq] = (ldqe_beat_ctrl[ldq] == 2'b01) ? ldqe_beat_incr[ldq] :
                                        (ldqe_beat_ctrl[ldq] == 2'b00) ? ldqe_beat_cntr_q[ldq] :
                                        ldqe_beat_init;

         // All Reload Data Beats Recieved
         assign ldq_rel1_beats_home[ldq]   = ldqe_beat_cntr_q[ldq][0];
         assign ldq_rel2_beats_home_d[ldq] = ldq_rel1_beats_home[ldq];
         assign ldq_rel3_beats_home_d[ldq] = ldq_rel2_beats_home_q[ldq];
         assign ldq_rel4_beats_home_d[ldq] = ldq_rel3_beats_home_q[ldq];
         assign ldq_rel5_beats_home_d[ldq] = ldq_rel4_beats_home_q[ldq];

         // Reload Critical Quadword beat valid, update regfile
         assign ldqe_relmin1_upd_gpr[ldq] = l2_lsq_resp_crit_qw & ldq_relmin1_l2_val[ldq] & (~ldqe_dGpr_q[ldq]);
         assign ldq_rel0_upd_gpr_d[ldq]   = ldqe_relmin1_upd_gpr[ldq];
         assign ldq_rel0_crit_qw[ldq]     = l2_rel0_resp_crit_qw_q & ldq_rel0_l2_val_q[ldq];

         // Need to Drop Regfile update when the LDQ entry is zapped or if its a touch type operation or
         // first reload got an ecc error
         assign ldqe_dGpr_cntrl[ldq][0] = ldqe_zap[ldq] | ldqe_ecc_err_dgpr[ldq];
         assign ldqe_dGpr_cntrl[ldq][1] = ex5_ldqe_set_all_q[ldq];

         assign ldqe_dGpr_d[ldq] = (ldqe_dGpr_cntrl[ldq] == 2'b01) ? (~ctl_lsq_ex5_not_touch) :
                                   (ldqe_dGpr_cntrl[ldq] == 2'b00) ? ldqe_dGpr_q[ldq] :
                                   1'b1;

         // ECC Error Detect Logic
         assign ldqe_rel_eccdet_sel[ldq] = {ldq_rel2_l2_val_q[ldq], ldqe_rst_eccdet_q[ldq]};

         assign ldqe_rel_eccdet[ldq] = (ldqe_rel_eccdet_sel[ldq] == 2'b10) ? (ldqe_rel_eccdet_q[ldq] | l2_lsq_resp_ecc_err) :
                                       (ldqe_rel_eccdet_sel[ldq] == 2'b00) ? ldqe_rel_eccdet_q[ldq] :
                                       1'b0;
         assign ldqe_rel_eccdet_d[ldq] = ldqe_rel_eccdet[ldq];

         assign ldqe_rel_eccdet_ue[ldq] = (ldqe_rel_eccdet_sel[ldq] == 2'b10) ? (ldqe_rel_eccdet_ue_q[ldq] | l2_lsq_resp_ecc_err_ue) :
                                          (ldqe_rel_eccdet_sel[ldq] == 2'b00) ? ldqe_rel_eccdet_ue_q[ldq] :
                                          1'b0;
         assign ldqe_rel_eccdet_ue_d[ldq] = ldqe_rel_eccdet_ue[ldq];

         // ECC Error was detected on the GPR update
         assign ldqe_upd_gpr_ecc_sel[ldq] = {ldq_rel2_l2_val_q[ldq], ldqe_reset_cpl_rpt_q[ldq]};

         assign ldqe_upd_gpr_ecc[ldq] = (ldqe_upd_gpr_ecc_sel[ldq] == 2'b10) ? (ldqe_upd_gpr_ecc_q[ldq] | ldq_rel2_gpr_ecc_err[ldq]) :
                                        (ldqe_upd_gpr_ecc_sel[ldq] == 2'b00) ? ldqe_upd_gpr_ecc_q[ldq] :
                                        1'b0;
         assign ldqe_upd_gpr_ecc_d[ldq] = ldqe_upd_gpr_ecc[ldq];

         assign ldqe_upd_gpr_eccue[ldq] = (ldqe_upd_gpr_ecc_sel[ldq] == 2'b10) ? (ldqe_upd_gpr_eccue_q[ldq] | ldq_rel2_gpr_eccue_err[ldq]) :
                                          (ldqe_upd_gpr_ecc_sel[ldq] == 2'b00) ? ldqe_upd_gpr_eccue_q[ldq] :
                                          1'b0;
         assign ldqe_upd_gpr_eccue_d[ldq] = ldqe_upd_gpr_eccue[ldq];

         // ECC error detected, need to create an NFlush
         assign ldqe_nFlush_ecc_err[ldq] = ldqe_upd_gpr_ecc_q[ldq] | ldqe_cpNext_ecc_err[ldq];

         // LoadQ Available, State Machine is IDLE
         assign ldqe_available[ldq] = ldqe_state_q[ldq][0] | (ldqe_state_q[ldq][1] & ex5_inv_ldqe[ldq]);

         // LoadQ Entry is complete, Waiting to send Completion Report
         assign ldqe_cpl_rpt_done[ldq] = ldqe_cpl_sent[ldq] | ldq_rel5_odq_cpl[ldq];
         assign ldqe_need_cpl_rst[ldq] = ldqe_cpl_rpt_done[ldq] | ldqe_kill[ldq];
         assign ldqe_need_cpl_sel[ldq] = {ldqe_need_cpl_rst[ldq], ldq_rel_send_cpl_ok[ldq]};

         assign ldqe_need_cpl_d[ldq] = (ldqe_need_cpl_sel[ldq] == 2'b00) ? ldqe_need_cpl_q[ldq] :
                                       (ldqe_need_cpl_sel[ldq] == 2'b01) ? 1'b1 :
                                       1'b0;

         assign ldqe_send_cpl[ldq] = ldqe_need_cpl_q[ldq] & ldqe_resolved_q[ldq];

         // LoadQ Entry Sent Completion Report Indicator
         assign ldqe_sent_cpl_sel[ldq] = {ldqe_reset_cpl_rpt_q[ldq], ldqe_cpl_rpt_done[ldq]};

         assign ldqe_sent_cpl_d[ldq] = (ldqe_sent_cpl_sel[ldq] == 2'b00) ? ldqe_sent_cpl_q[ldq] :
                                       (ldqe_sent_cpl_sel[ldq] == 2'b01) ? 1'b1 :
                                       1'b0;

         // Block the setting of qHit_held if reload is completeing and is in rel2 until the state machine is freed up
         assign ldqe_qHit_clr_sel[ldq] = {ldq_rel2_qHit_clr[ldq], ldqe_reset_cpl_rpt_q[ldq]};

         assign ldq_rel_qHit_clr_d[ldq] = (ldqe_qHit_clr_sel[ldq] == 2'b00) ? ldq_rel_qHit_clr_q[ldq] :
                                          (ldqe_qHit_clr_sel[ldq] == 2'b10) ? 1'b1 :
                                          1'b0;

         // Drop Reload due to L1 Dump
         assign ldqe_rel_l1_dump_ctrl[ldq] = {ldq_rel_l1_dump[ldq], ldqe_cntr_reset_q[ldq]};
         assign ldqe_l1_dump_d[ldq] = (ldqe_rel_l1_dump_ctrl[ldq] == 2'b10) ? ldq_rel_l1_dump[ldq] :
                                      (ldqe_rel_l1_dump_ctrl[ldq] == 2'b00) ? ldqe_l1_dump_q[ldq] :
                                      1'b0;

         assign ldqe_drop_reload_val[ldq] = ldqe_l1_dump_q[ldq] | ldqe_dRel_q[ldq];

         // Reload Data Beat is Valid
         assign ldq_rel1_dbeat_val[ldq]  = ldq_rel1_l2_val_q[ldq] & (~(ldqe_wimge_i[ldq] | ldqe_drop_reload_val[ldq]));

         // Reload Queue Entry was not restarted
         assign ldq_rel2_sentL1[ldq]     = ldq_rel2_entrySent_q[ldq] & (~rel2_blk_req_q);

         // Reload Queue Entry was restarted
         assign ldq_rel2_sentL1_blk[ldq] = ldq_rel2_entrySent_q[ldq] & rel2_rviss_blk_q;

         // Sent to L1 Beat Counter
         // Should indicate when all data beats have been sent to the L1
         // including beats coming from both L2 Reload and Reload Arbiters
         assign ldqe_sentRel_ctrl[ldq]   = {ldqe_cntr_reset_q[ldq], ldq_rel2_sentL1[ldq]};
         assign ldqe_sentRel_incr[ldq]   = ldqe_sentRel_cntr_q[ldq] + 4'b0001;

         assign ldqe_sentRel_cntr_d[ldq] = (ldqe_sentRel_ctrl[ldq] == 2'b00) ? ldqe_sentRel_cntr_q[ldq] :
                                           (ldqe_sentRel_ctrl[ldq] == 2'b01) ? ldqe_sentRel_incr[ldq] :
                                           ldqe_beat_init;

         // All Reload Data Beats Recieved
         assign ldqe_sentL1[ldq] = ldqe_sentRel_cntr_q[ldq][0];

         // L1 Data Cache has been updated, Send CLR_HOLD report to RV
         assign ldqe_rel2_l1upd_cmpl[ldq] = ldq_rel2_sentL1[ldq] & &(ldqe_sentRel_cntr_q[ldq][1:3]);

         // Need to Determine Last Data Beat to be sent to the L1
         // The last beat missing is when the cntr=7
         assign ldqe_last_beat[ldq] = &(ldqe_sentRel_cntr_d[ldq][1:3]);

         // Reload has Determined a Way to update
         assign ldqe_rel_start_ctrl[ldq][0] = ldqe_cntr_reset_q[ldq];
         assign ldqe_rel_start_ctrl[ldq][1] = ldq_rel2_sentL1[ldq] & (~ldqe_relDir_start_q[ldq]);
         assign ldqe_relDir_start[ldq] = (ldqe_rel_start_ctrl[ldq] == 2'b00) ? ldqe_relDir_start_q[ldq] :
                                         (ldqe_rel_start_ctrl[ldq] == 2'b01) ? 1'b1 :
                                         1'b0;

         assign ldqe_relDir_start_d[ldq] = ldqe_relDir_start[ldq];
      end
   end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LOAD GATHERING QUEUE
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// determine load tag for the ldq entry that will be gathered into

always @(*) begin: ldq_gath_Tag_P
   reg [0:3]                                               tag;

   (* analysis_not_referenced="true" *)

   integer                                             ldq;
   tag = 4'b0000;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1)
      tag = (ldq[3:0] & {4{ex4_entry_gath_ld[ldq]}}) | tag;
   ldq_gath_Tag <= tag;
end

// determine if the ex4 load hits against the load gather queue

always @(*) begin: lgq_qw_hit_P
   reg [0:`LMQ_ENTRIES-1]                                   hit;

   (* analysis_not_referenced="true" *)

   integer                                                  lgq;
   hit = {`LMQ_ENTRIES{1'b0}};
   for (lgq=0; lgq<`LGQ_ENTRIES; lgq=lgq+1)
      hit = (ldq_gath_Tag_1hot[lgq] & {`LMQ_ENTRIES{(lgqe_valid_q[lgq] & lqg_qw_match[lgq])}}) | hit;
   ex4_lgq_qw_hit <= hit;
end

// LGQ Entry WRT Pointer Logic
// Look for first available entry
assign lgqe_available = (~lgqe_valid_q);

assign lgqe_wrt_ptr[0] = lgqe_available[0];
generate begin : LgPriWrt
      genvar                                                  lgq;
      for (lgq=1; lgq<`LGQ_ENTRIES; lgq=lgq+1) begin : LgPriWrt
         assign lgqe_wrt_ptr[lgq] = &((~lgqe_available[0:lgq - 1])) & lgqe_available[lgq];
      end
   end
endgenerate

assign ld_gath_not_full = |(lgqe_available);

// removed prefetcher from the equation
// should never gather a prefetch
assign ex4_gath_val        = ctl_lsq_ex4_ldreq_val & ex4_ld_gath & (~ex4_stg_flush);
assign ex4_lgqe_set_val    = lgqe_wrt_ptr & {`LGQ_ENTRIES{ex4_gath_val}};
assign ex4_lgqe_set_all    = lgqe_wrt_ptr & {`LGQ_ENTRIES{ex4_ldreq_q}};
assign ex5_lgqe_set_all_d  = ex4_lgqe_set_all;
assign ex5_lgqe_set_val_d  = ex4_lgqe_set_val;

generate begin : load_gath_Q
      genvar                                                  lgq;
      for (lgq=0; lgq<`LGQ_ENTRIES; lgq=lgq+1) begin : load_gath_Q

         // Gathered and Reload at same cycle, need to restart gathered entry
         assign ex5_lgqe_restart[lgq] = ex5_lgqe_set_val_q[lgq] & ldq_relmin1_ldq_val & (lgqe_ldTag_q[lgq] == ldq_relmin1_cTag);
         assign ex5_lgqe_drop[lgq]    = ex5_lgqe_set_val_q[lgq] & ex5_drop_gath;

         // Determine if Entry should be Flushed
         // CP Flush
         assign lgqe_cp_flush[lgq] = |(iu_lq_cp_flush_q & lgqe_thrd_id_q[lgq]) & lgqe_valid_q[lgq];

         // OrderQ Flush
         assign lgqe_odq_flush[lgq] = (odq_ldq_report_itag_q == lgqe_itag_q[lgq]) & |(odq_ldq_report_tid_q & lgqe_thrd_id_q[lgq]) & odq_ldq_n_flush_q;
         assign lgqe_kill[lgq]      = lgqe_cp_flush[lgq] | lgqe_odq_flush[lgq];

         assign lgq_reset_val[lgq] = lgqe_cpl_rpt_done[lgq] | ex5_lgqe_drop[lgq] | lgqe_kill[lgq];

         assign lgqe_valid_d[lgq] = ex4_lgqe_set_val[lgq] ? 1'b1 :
                                       lgq_reset_val[lgq] ? 1'b0 : lgqe_valid_q[lgq];

         // Instructions ITAG
         assign lgqe_itag_d[lgq] = ex4_lgqe_set_all[lgq] ? ctl_lsq_ex4_itag : lgqe_itag_q[lgq];

         // `THREADS Bits
         assign lgqe_thrd_id_d[lgq] = ex4_lgqe_set_all[lgq] ? ctl_lsq_ex4_thrd_id : lgqe_thrd_id_q[lgq];

         // Core TAG of load entry being gathered into
         assign lgqe_ldTag_d[lgq] = ex4_lgqe_set_all[lgq] ? ldq_gath_Tag : lgqe_ldTag_q[lgq];

         // create a 1-hot core tag for each gather queue entry
         begin : ldq_gath_Tag_1hot_G
            genvar                                                  ldq;
            for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : ldq_gath_Tag_1hot_G
               wire [0:3]  ldqDummy;
               assign ldqDummy = ldq[3:0];
               assign ldq_gath_Tag_1hot[lgq][ldq] = lgqe_ldTag_q[lgq] == ldqDummy;
            end
         end

         // Request Physical Address QW select Bits
         assign lgqe_p_addr_d[lgq] = ex4_lgqe_set_all[lgq] ? ctl_lsq_ex4_p_addr[57:63] : lgqe_p_addr_q[lgq];

         assign lqg_qw_match[lgq] = ~spr_xucr0_cls_q ? (lgqe_p_addr_q[lgq][58:59] == ctl_lsq_ex4_p_addr[58:59]) :
                                                       (lgqe_p_addr_q[lgq][57:59] == ctl_lsq_ex4_p_addr[57:59]);

         // Byte Swap Bits
         assign lgqe_byte_swap_d[lgq] = ex4_lgqe_set_all[lgq] ? ctl_lsq_ex4_byte_swap : lgqe_byte_swap_q[lgq];

         // GPR Update is done
         // lgqe_set_gpr_done = "11"         => This should never occur, will need bugspray here
         assign lgqe_set_gpr_done[lgq] = {ex4_lgqe_set_all[lgq], lgq_rel2_upd_gpr_q[lgq]};

         // GPR Update is Done Indicator
         assign lgqe_gpr_done_d[lgq] = (lgqe_set_gpr_done[lgq] == 2'b00) ? lgqe_gpr_done_q[lgq] :
                                       (lgqe_set_gpr_done[lgq] == 2'b01) ? 1'b1 :
                                       1'b0;

         // op_size Bits
         assign lgqe_set_op_size[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_opsize : lgqe_op_size_q[lgq];

         assign lgqe_op_size_d[lgq] = lgqe_set_op_size[lgq];

         // tgpr Bits
         assign lgqe_set_tgpr[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_tgpr : lgqe_tgpr_q[lgq];

         assign lgqe_tgpr_d[lgq] = lgqe_set_tgpr[lgq];

         // axu Bits
         assign lgqe_set_axu[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_axu_val : lgqe_axu_q[lgq];

         assign lgqe_axu_d[lgq] = lgqe_set_axu[lgq];

         // performance events
         assign lgqe_perf_events_d[lgq] = ex5_lgqe_set_all_q[lgq] ? ex5_cmmt_perf_events : lgqe_perf_events_q[lgq];

         // algebraic Bits
         assign lgqe_set_algebraic[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_algebraic : lgqe_algebraic_q[lgq];

         assign lgqe_algebraic_d[lgq] = lgqe_set_algebraic[lgq];

         // DAC Status Bits
         assign lgqe_dacrw_d[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_dacrw : lgqe_dacrw_q[lgq];

         // DVC Bits
         // Need to split it out for timing since we can be setting in ex5 and
         // the quadword reload is valid the same cycle
         // Should never see ex5_lgqe_set_all_q = '1' and lgq_rel4_upd_gpr_q = '1' at the same time
         assign lgqe_set_dvc[lgq] = ex5_lgqe_set_all_q[lgq] ? ctl_lsq_ex5_dvc : lgqe_dvc_q[lgq];

         assign lgqe_dvc_d[lgq] = lgq_rel2_upd_gpr_q[lgq] ? ldq_rel2_dvc : lgqe_set_dvc[lgq];

         // Want to Flush if the loadqueue was back-invalidated or the L1 Dump signal is on for the reload
         // Use back inv bits from the corresponding lmq entry
         assign lgqe_back_inv_flush_upd[lgq] = |((ldqe_back_inv_q | ldq_rel_l1_dump) & ldq_gath_Tag_1hot[lgq]);

         // Determine if request is CP_NEXT itag
         begin : lgqeItagTid
            genvar                                                  tid;
            for (tid=0; tid<`THREADS; tid=tid+1) begin : lgqeItagTid
               assign lgqe_cpNext_tid[lgq][tid] = lgqe_thrd_id_q[lgq][tid] & (lgqe_itag_q[lgq] == iu_lq_cp_next_itag_q[tid]);
            end
         end

         assign lgqe_cpNext_val[lgq] = |(lgqe_cpNext_tid[lgq]);

         // NEED TO REVISIT THIS STATEMENT, I BELIEVE THIS SCENARIO ONLY EXISTS IF THE LDQ HOLDS UNRESOLVED ITAGS WHEN THE RELOAD IS COMPLETE
         // Want to only capture the first back-invalidate
         // There is a hole where it was a cp_next itag when the back-invalidate hit
         // then an older loadmiss went to the L2, got newer data
         // another back-invalidate comes in and sets the cpnext_val indicator causing an NP1 flush
         // when we really wanted an N flush

         // Take a snapshot of the CP_NEXT check whenever the loadmiss queue entry was back-invalidated
         assign lgqe_back_inv_nFlush_d[lgq] = ({ex4_lgqe_set_all[lgq], lgqe_back_inv_flush_upd[lgq]} == 2'b00) ? lgqe_back_inv_nFlush_q[lgq] :
                                              ({ex4_lgqe_set_all[lgq], lgqe_back_inv_flush_upd[lgq]} == 2'b01) ? (lgqe_back_inv_nFlush_q[lgq] | ((~lgqe_cpNext_val[lgq]))) :
                                              1'b0;

         assign lgqe_back_inv_np1Flush_d[lgq] = ({ex4_lgqe_set_all[lgq], lgqe_back_inv_flush_upd[lgq]} == 2'b00) ? lgqe_back_inv_np1Flush_q[lgq] :
                                                ({ex4_lgqe_set_all[lgq], lgqe_back_inv_flush_upd[lgq]} == 2'b01) ? (lgqe_back_inv_np1Flush_q[lgq] | lgqe_cpNext_val[lgq]) :
                                                1'b0;

         // ##############################################
         // LGQ Reload Control
         // ##############################################
         assign lgqe_relmin1_match[lgq]   = (ldq_relmin1_cTag == lgqe_ldTag_q[lgq]) &
                                            ((l2_lsq_resp_qw[57] == lgqe_p_addr_q[lgq][57]) | (~spr_xucr0_cls_q)) &
                                            (l2_lsq_resp_qw[58:59] == lgqe_p_addr_q[lgq][58:59]) & lgqe_valid_q[lgq];
         assign lgqe_relmin1_upd_gpr[lgq] = lgqe_relmin1_match[lgq] & ldq_relmin1_ldq_val & (~(lgqe_gpr_done_q[lgq] | ex5_lgqe_set_val_q[lgq]));
         assign lgq_rel0_upd_gpr_d[lgq]   = lgqe_relmin1_upd_gpr[lgq] & (~lgqe_kill[lgq]);

         // Load Gather Entry Has Resolved In Order Queue
         assign lgqe_resolved[lgq] = (lgqe_itag_q[lgq] == odq_ldq_report_itag_q) & |(odq_ldq_report_tid_q & lgqe_thrd_id_q[lgq]) & odq_ldq_resolved_q & lgqe_valid_q[lgq];

         assign lgqe_resolved_d[lgq] = ({ex4_lgqe_set_all[lgq], lgqe_resolved[lgq]} == 2'b00) ? lgqe_resolved_q[lgq] :
                                       ({ex4_lgqe_set_all[lgq], lgqe_resolved[lgq]} == 2'b01) ? 1'b1 :
                                       1'b0;

         // LoadQ Entry is complete, Waiting to send Completion Report
         assign lgqe_cpl_rpt_done[lgq] = lgqe_cpl_sent[lgq] | (lgqe_need_cpl_q[lgq] & lgq_rel5_odq_cpl[lgq]);
         assign lgqe_need_cpl_rst[lgq] = lgqe_cpl_rpt_done[lgq] | lgqe_kill[lgq];
         // Need to delay the completion report to cover the window where i am trying to update an FPR register
         // and the gather queue entry got flushed, need to gate the FPR update
         assign lgqe_need_cpl_sel[lgq] = {lgqe_need_cpl_rst[lgq], lgq_rel2_send_cpl_ok[lgq]};

         assign lgqe_need_cpl_d[lgq] = (lgqe_need_cpl_sel[lgq] == 2'b00) ? lgqe_need_cpl_q[lgq] :
                                       (lgqe_need_cpl_sel[lgq] == 2'b01) ? 1'b1 :
                                       1'b0;

         // Dont really think we need to wait for the full reload to be done on the interface
         // We were waiting for the case that the L2 is sending a reload with newer data and a
         // back-invalidate is seen for the previous data at the same cycle that the reload is
         // occuring, the L2 should never do this, we should always either see the back-invalidate first
         // followed by the reload with newer data, or we should see a reload with older data and the back-invalidate
         // at the same time. For the second case, we should be covered for the scenario that eventually we get an older
         // loadmiss to the same line that would bring in newer data because the younger loadmiss is sitting in the order queue
         // and would have been flushed due to the back-invalidate hitting against the order queue. The older instruction may not
         // have been resolved yet, so the older instruction would not get flushed.
         assign lgqe_send_cpl[lgq] = lgqe_need_cpl_q[lgq] & lgqe_resolved_q[lgq] & lgqe_valid_q[lgq];

         // ECC Error was detected on the GPR update
         assign lgqe_upd_gpr_ecc_sel[lgq] = {lgq_rel2_upd_gpr[lgq], lgqe_need_cpl_rst[lgq]};

         assign lgqe_upd_gpr_ecc[lgq] = (lgqe_upd_gpr_ecc_sel[lgq] == 2'b10) ? (lgqe_upd_gpr_ecc_q[lgq] | l2_lsq_resp_ecc_err | l2_lsq_resp_ecc_err_ue) :
                                        (lgqe_upd_gpr_ecc_sel[lgq] == 2'b00) ? lgqe_upd_gpr_ecc_q[lgq] :
                                        1'b0;
         assign lgqe_upd_gpr_ecc_d[lgq] = lgqe_upd_gpr_ecc[lgq];

         assign lgqe_upd_gpr_eccue[lgq] = (lgqe_upd_gpr_ecc_sel[lgq] == 2'b10) ? (lgqe_upd_gpr_eccue_q[lgq] | l2_lsq_resp_ecc_err_ue) :
                                          (lgqe_upd_gpr_ecc_sel[lgq] == 2'b00) ? lgqe_upd_gpr_eccue_q[lgq] :
                                          1'b0;
         assign lgqe_upd_gpr_eccue_d[lgq] = lgqe_upd_gpr_eccue[lgq];

      end
   end
endgenerate

// determine when lmq entries do not have any more active gathers

always @(*) begin: ldq_gath_done_P
   reg [0:`LMQ_ENTRIES-1]                                  active;

   (* analysis_not_referenced="true" *)

   integer                                                 lgq;
   active = {`LMQ_ENTRIES{1'b0}};
   for (lgq=0; lgq<`LGQ_ENTRIES; lgq=lgq+1)
      active = (ldq_gath_Tag_1hot[lgq] & {`LGQ_ENTRIES{lgqe_valid_q[lgq]}}) | active;
   ldqe_gather_done <= (~active);
end

assign lgq_rel1_gpr_val_d = |(lgq_rel0_upd_gpr_q & (~(ex5_lgqe_drop | lgqe_kill)));
assign lgq_rel1_upd_gpr_d = lgq_rel0_upd_gpr_q & (~(ex5_lgqe_drop | lgqe_kill));
assign lgq_rel2_upd_gpr_d = lgq_rel1_upd_gpr_q & (~lgqe_kill);
assign lgq_rel3_upd_gpr_d = lgq_rel2_upd_gpr_q & (~lgqe_kill);
assign lgq_rel1_upd_gpr = lgq_rel1_upd_gpr_q & lgqe_valid_q & (~lgqe_kill);
assign lgq_rel2_upd_gpr = lgq_rel2_upd_gpr_q & lgqe_valid_q;

// Need to Send Completion Report
assign lgq_rel2_send_cpl_ok = lgq_rel2_upd_gpr_q & lgqe_valid_q & (~lgqe_need_cpl_q);

// LDQ has a Loadmiss Request to send
assign ldq_l2_req_need_send = |(ldqe_need_l2send);

// Reload will try to update Cache contents
assign ldq_rel0_updating_cache  = |(ldq_rel0_entrySent);
assign ldq_stq_rel1_blk_store_d = ldq_rel0_updating_cache | |(ldq_rel_l2_l1dumpBlk) | |(ldq_rel0_upd_gpr_q) | |(lgq_rel0_upd_gpr_q & (~ex5_lgqe_drop));

// Clear qHit indicator when reload is about to complete
assign ldq_rel2_qHit_clr    = ldqe_rel2_l1upd_cmpl | ldq_rel2_ci_done | ldq_rel2_drel_done;
assign ldq_rel2_rv_clr_hold = |(ldq_rel2_qHit_clr & ldqe_qHit_held_q);
assign ldq_clrHold          = ldq_rel2_rv_clr_hold | ldq_oth_qHit_clr_q;
assign ldq_clrHold_tid      = ldq_hold_tid & {`THREADS{ldq_clrHold}};

// Load Queue Full
assign ex4_ldq_full           = &(~ldqe_available);
assign ex5_ldq_full_d         = ex4_ldq_full;
assign ex4_ldq_full_restart   = ctl_lsq_ex4_ldreq_val & ex4_ldq_full & (~ex4_stg_flush);
assign ex5_ldq_full_restart_d = ex4_ldq_full_restart;

// Load Queue Full SET_HOLD and CLR_HOLD logic to the reservation station
// Want to clear when the load queue isnt full
assign ldq_full_qHit_held_set  = ex5_ldq_full_restart_q & (~(ctl_lsq_ex5_load_hit | stq_ldq_ex5_fwd_val));
assign ldq_full_qHit_held_clr  = ldq_full_qHit_held_q & (~ex4_ldq_full);
assign ldq_full_qHit_held_ctrl = {ldq_full_qHit_held_set, ldq_full_qHit_held_clr};

assign ldq_full_qHit_held_d = (ldq_full_qHit_held_ctrl == 2'b00) ? ldq_full_qHit_held_q :
                              (ldq_full_qHit_held_ctrl == 2'b10) ? 1'b1 :
                              1'b0;

// Load Queue Entry Reserved SET_HOLD and CLR_HOLD logic to the reservation station
// Want to clear when the load queue isnt full or there is one entry available
assign ldq_resv_qHit_held_set  = ex5_resv_taken_restart_q & (~(ctl_lsq_ex5_load_hit | stq_ldq_ex5_fwd_val));
assign ldq_resv_qHit_held_clr  = ldq_resv_qHit_held_q & (~(ex4_one_machine_avail | ex4_ldq_full));
assign ldq_resv_qHit_held_ctrl = {ldq_resv_qHit_held_set, ldq_resv_qHit_held_clr};

assign ldq_resv_qHit_held_d = (ldq_resv_qHit_held_ctrl == 2'b00) ? ldq_resv_qHit_held_q :
                              (ldq_resv_qHit_held_ctrl == 2'b10) ? 1'b1 :
                              1'b0;

// CLR_HOLD indicator for LDQ Full or LDQ Reserved
assign ldq_oth_qHit_clr_d = ldq_full_qHit_held_clr | ldq_resv_qHit_held_clr;

// SET_HOLD due to LDQ Full or 1 Entry left and is reserved
assign ex5_ldq_full_set_hold = (ex5_ldq_full_restart_q | ex5_resv_taken_restart_q) & (~(ctl_lsq_ex5_load_hit | stq_ldq_ex5_fwd_val));

// Queue Hit Indicators
assign ex4_ldq_hit   = |(ex4_entry_load_qHit);
assign ex5_ldq_hit_d = ex4_ldq_hit;

// Load Gathered Indicators
assign ex4_ld_gath   = |(ex4_entry_gath_ld);
assign ex5_ld_gath_d = ex4_ld_gath;

// Set Hold on a LDQ restart
assign ex5_ldq_set_hold_d = |(ex4_load_qHit_upd);
assign ex5_setHold        = ex5_ldq_set_hold_q | ex5_ldq_full_set_hold;

// Set Thread Held Indicator
assign ldq_setHold_tid = ldq_hold_tid_q | {`THREADS{ex5_setHold}};
generate begin : holdTid
      genvar                                                  tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : holdTid
         assign ldq_hold_tid[tid] = ctl_lsq_ex5_thrd_id[tid] ? ldq_setHold_tid[tid] : ldq_hold_tid_q[tid];
      end
   end
endgenerate

assign ldq_hold_tid_d = ldq_hold_tid & (~ldq_clrHold_tid);

// EX5 Request needs to be dropped
assign ex5_drop_req_val = ctl_lsq_ex5_load_hit        |     // request was a load hit
                          ex5_reserved_taken_q        |     // queue entry is reserved for oldest load
                          ex5_ldq_hit_q               |     // request hit outstanding request
                          stq_ldq_ex5_fwd_val         |     // STQ Forwarded Load Data, dont need to send an L1 Miss request
                          stq_ldq_ex5_stq_restart     |     // STQ Restarted Load due to every other reason
                          stq_ldq_ex5_stq_restart_miss;		// STQ Restarted Load due to loadmiss that didnt forward specifically

assign ex5_drop_gath = ctl_lsq_ex5_load_hit           |     // request was a load hit
                       ex5_stg_flush                  |     // request was CP_FLUSHed or will be
                       ex5_lgq_restart                |     // request was gathered in EX5 and reload to cTag the same cycle
                       stq_ldq_ex5_fwd_val            |     // STQ Forwarded Load Data, dont need to send an L1 Miss request
                       stq_ldq_ex5_stq_restart        |     // STQ Restarted Load due to every other reason
                       stq_ldq_ex5_stq_restart_miss;	    // STQ Restarted Load due to loadmiss that didnt forward specifically


// State Machines are idle
// Simulation uses this signal, dont delete
assign ldq_state_machines_idle = &(ldqe_available);

// RESTART Request
// 1) Request to Cache line already in LoadMiss Queue
// 2) LoadMiss Queue is full and new loadmiss request
// 3) 1 LoadMiss StateMachine available and not the oldest load request and a loadmiss
assign ex5_ldq_restart_d = (ex4_ldq_full_restart | ex4_reserved_taken) & (~ex4_ld_gath);
assign ex5_lgq_restart   = |(ex5_lgqe_restart);
assign ex5_ldq_restart   = (ex5_ldq_hit_q & (~ex5_ld_gath_q)) | (ex5_odq_ldreq_val_q & ex5_ldq_restart_q & (~ctl_lsq_ex5_load_hit)) | ex5_lgq_restart;
assign ex6_ldq_full_d    = (ex5_ldq_full_q | ex5_reserved_taken_q) & ~ex5_ld_gath_q;
assign ex6_ldq_hit_d     = ex5_ldq_hit_q & ~ex5_ld_gath_q;
assign ex5_lgq_full_d    = |(ex4_entry_gath_full);
assign ex6_lgq_full_d    = ex5_lgq_full_q;
assign ex5_lgq_qwhit_d   = |(ex4_entry_gath_qwhit);
assign ex6_lgq_qwhit_d   = ex5_lgq_qwhit_q;
assign perf_ex6_ldq_full_restart  = ex6_ldq_full_q;
assign perf_ex6_ldq_hit_restart   = ex6_ldq_hit_q;
assign perf_ex6_lgq_full_restart  = ex6_lgq_full_q;
assign perf_ex6_lgq_qwhit_restart = ex6_lgq_qwhit_q;

// RESTART Due to LoadmissQ and StoreQ
assign ex5_restart_val = ex5_ldq_restart | stq_ldq_ex5_stq_restart | (stq_ldq_ex5_stq_restart_miss & (~ctl_lsq_ex5_load_hit));
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Reload Rotator Select Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// 1-Hot opsize
assign ldq_rel0_opsize_1hot = (ldq_rel0_opsize == 3'b110) ? 5'b10000 : 		// 16Bytes
                              (ldq_rel0_opsize == 3'b101) ? 5'b01000 : 		// 8Bytes
                              (ldq_rel0_opsize == 3'b100) ? 5'b00100 : 		// 4Bytes
                              (ldq_rel0_opsize == 3'b010) ? 5'b00010 : 		// 2Bytes
                              (ldq_rel0_opsize == 3'b001) ? 5'b00001 : 		// 1Bytes
                              5'b00000;

// Store/Reload Pipe Rotator Control Calculations
assign ldq_rel0_rot_size         = ldq_rel0_p_addr[59:63] + ldq_rel0_opsize_1hot;
assign ldq_rel0_rot_max_size_le  = rot_max_size | ldq_rel0_opsize_1hot;
assign ldq_rel0_rot_sel_le       = ldq_rel0_rot_max_size_le - ldq_rel0_rot_size;

// RELOAD PATH LITTLE ENDIAN ROTATOR SELECT CALCULATION
// rel_rot_size = rot_addr + op_size
// rel_rot_sel_le = (rot_max_size or le_op_size) - rel_rot_size
// rel_rot_sel = rel_rot_sel_le  => le_mode = 1
//             = rel_rot_size    => le_mode = 0

// Little Endian Support Reload Data Rotate Select
assign ldq_rel0_rot_sel = ldq_rel0_byte_swap ? ldq_rel0_rot_sel_le[1:4] : ldq_rel0_rot_size[1:4];

// Calculate Algebraic Mux control
assign ldq_rel1_algebraic_sel_d = ldq_rel0_rot_sel - ldq_rel0_opsize_1hot[1:4];

// Calculate Reload Rotator Mux control
assign lvl1_sel = ldq_rel0_byte_swap;
assign lvl2_sel = ldq_rel0_rot_sel[0:1];
assign lvl3_sel = ldq_rel0_rot_sel[2:3];

assign rotate_sel1 = (lvl1_sel == 1'b0) ? 2'b10 :
                     2'b01;

assign rotate_sel2 = (lvl2_sel == 2'b00) ? 4'b1000 :
                     (lvl2_sel == 2'b01) ? 4'b0100 :
                     (lvl2_sel == 2'b10) ? 4'b0010 :
                     4'b0001;

assign rotate_sel3 = (lvl3_sel == 2'b00) ? 4'b1000 :
                     (lvl3_sel == 2'b01) ? 4'b0100 :
                     (lvl3_sel == 2'b10) ? 4'b0010 :
                     4'b0001;

assign ldq_rel1_rot_sel1_d = {rotate_sel1, rotate_sel1, rotate_sel1, rotate_sel1};
assign ldq_rel1_rot_sel2_d = {rotate_sel2, rotate_sel2};
assign ldq_rel1_rot_sel3_d = {rotate_sel3, rotate_sel3};
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Reload Rotator Select Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_ldq_rot rrotl(

   // ACT
   .ldq_rel1_stg_act(ldq_rel1_val_q),

   // Reload Rotator Control
   .ldq_rel1_rot_sel1(ldq_rel1_rot_sel1_q),
   .ldq_rel1_rot_sel2(ldq_rel1_rot_sel2_q),
   .ldq_rel1_rot_sel3(ldq_rel1_rot_sel3_q),
   .ldq_rel1_data(ldq_rel1_data),

   // Reload Data Fixup Control
   .ldq_rel1_opsize(ldq_rel1_opsize_q),
   .ldq_rel1_byte_swap(ldq_rel1_byte_swap_q),
   .ldq_rel1_algebraic(ldq_rel1_algEn_q),
   .ldq_rel1_algebraic_sel(ldq_rel1_algebraic_sel_q),
   .ldq_rel1_gpr_val(ldq_rel1_gpr_val),
   .ldq_rel1_dvc1_en(ldq_rel1_dvcEn_q[0]),
   .ldq_rel1_dvc2_en(ldq_rel1_dvcEn_q[1]),
   .ldq_rel2_thrd_id(ldq_rel2_tid_q),

   // Data Value Compare Registers
   .ctl_lsq_spr_dvc1_dbg(ctl_lsq_spr_dvc1_dbg),
   .ctl_lsq_spr_dvc2_dbg(ctl_lsq_spr_dvc2_dbg),
   .ctl_lsq_spr_dbcr2_dvc1be(ctl_lsq_spr_dbcr2_dvc1be),
   .ctl_lsq_spr_dbcr2_dvc1m(ctl_lsq_spr_dbcr2_dvc1m),
   .ctl_lsq_spr_dbcr2_dvc2be(ctl_lsq_spr_dbcr2_dvc2be),
   .ctl_lsq_spr_dbcr2_dvc2m(ctl_lsq_spr_dbcr2_dvc2m),

   // Reload Rotator Output
   .ldq_rel2_rot_data(ldq_rel2_rot_data),
   .ldq_rel2_dvc(ldq_rel2_dvc),

   // Pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(siv[rrot_scan_offset]),
   .scan_out(sov[rrot_scan_offset])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LOADMISS REQUEST ARBITRATION
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Doing a FIFO scheme
// Request at the bottom will be sent out first
// New Requests should always behind the last valid request

// New request going to FIFO
assign ex5_upd_fifo_val = (ex5_ldreq_val | ex5_pfetch_val) & ~ex5_drop_req_val & (~arb_ldq_ldq_unit_sel | fifo_ldq_req_val_q[0]);

// FIFO ACT
// Want to turn on ACT for the following reasons
// 1) request needs to be sent, will cause a compression
// 2) need to compress in the middle
// 3) new loadmiss might be updating fifo
assign fifo_ldq_act = fifo_ldq_req_val_q[0] | |(fifo_ldq_req_empty_entry) | ex5_ldreq_val_q | ex5_pfetch_val_q;

// FIFO needs compression for 2 reasons
// 1) Bottom of FIFO request was sent
// 2) Entry in between Bottom and Top of FIFO was zapped
assign fifo_ldq_req_compr_val = fifo_ldq_req_sent | |(fifo_ldq_req_empty_entry);

// FIFO Entry WRT Pointer Logic
assign fifo_ldq_req_wrt_ptr = fifo_ldq_req_compr_val ? ({fifo_ldq_req_nxt_ptr_q[1:`LMQ_ENTRIES], 1'b0}) : fifo_ldq_req_nxt_ptr_q;

// FIFO Entry WRT Pointer Logic
assign fifo_ldq_wrt_ptr_cntrl = {fifo_ldq_req_compr_val, ex5_upd_fifo_val};
assign fifo_ldq_req_nxt_ptr   = (fifo_ldq_wrt_ptr_cntrl == 2'b10) ? ({fifo_ldq_req_nxt_ptr_q[1:`LMQ_ENTRIES], 1'b0}) :
                                (fifo_ldq_wrt_ptr_cntrl == 2'b01) ? ({1'b0, fifo_ldq_req_nxt_ptr_q[0:`LMQ_ENTRIES - 1]}) :
                                 fifo_ldq_req_nxt_ptr_q;

// FIFO Reset when write pointer is not at entry 0 and fifo empty
assign fifo_ldq_reset_ptr                     = (~fifo_ldq_req_wrt_ptr[0]) & (~(|fifo_ldq_req_val)) & (~ex5_upd_fifo_val);
assign fifo_ldq_req_nxt_ptr_d[0]              = fifo_ldq_reset_ptr ? 1'b1 : fifo_ldq_req_nxt_ptr[0];
assign fifo_ldq_req_nxt_ptr_d[1:`LMQ_ENTRIES] = fifo_ldq_reset_ptr ? {`LMQ_ENTRIES{1'b0}} : fifo_ldq_req_nxt_ptr[1:`LMQ_ENTRIES];

// FIFO Entry Sent
assign fifo_ldq_req_sent   = fifo_ldq_req_val_q[0] & arb_ldq_ldq_unit_sel;
assign fifo_ldq_req0_mkill = |(fifo_ldq_req_tid_q[0] & iu_lq_cp_flush_q);
assign fifo_ldq_req0_avail = (fifo_ldq_req_val_q[0] & ~fifo_ldq_req0_mkill) & ~fifo_ldq_req_pfetch_q[0];

// FIFO Control
generate begin : fifoCtrl
      genvar                                                  fifo;
      for (fifo=0; fifo<`LMQ_ENTRIES; fifo=fifo+1) begin : fifoCtrl
         // Fifo Entry Was Zapped
         assign fifo_ldq_req_val[fifo] = fifo_ldq_req_val_q[fifo] & |(fifo_ldq_req_q[fifo] & (~ldqe_mkill));

         // Fifo Entry Prefetch is allowed to be sent status from ODQ
         assign fifo_ldq_req_pfetch_match[fifo] = |(fifo_ldq_req_q[fifo] & ex7_ldqe_pfetch_val_q);
         assign fifo_ldq_req_pfetch_send[fifo]  = fifo_ldq_req_pfetch_match[fifo] & ~odq_ldq_ex7_pfetch_blk;
         assign fifo_ldq_req_pfetch[fifo] = (fifo_ldq_req_pfetch_q[fifo] & ~fifo_ldq_req_pfetch_send[fifo]) | (fifo_ldq_req_pfetch_q[fifo] & ~fifo_ldq_req_pfetch_match[fifo]);

         // Figure out if entry behind me is valid and i am not valid, need to push my entry and all entries after mine
         if (fifo < `LMQ_ENTRIES - 1) begin : emptyFifo
            assign fifo_ldq_req_empty_entry[fifo] = (~fifo_ldq_req_val_q[fifo]) & fifo_ldq_req_val_q[fifo + 1];
         end
         if (fifo == `LMQ_ENTRIES - 1) begin : lastFifo
            assign fifo_ldq_req_empty_entry[fifo] = 1'b0;
         end

         assign fifo_ldq_req_upd[fifo]   = fifo_ldq_req_wrt_ptr[fifo] & ex5_upd_fifo_val;
         assign fifo_ldq_req_push[fifo]  = |(fifo_ldq_req_empty_entry[0:fifo]) | fifo_ldq_req_sent;
         assign fifo_ldq_req_cntrl[fifo] = {fifo_ldq_req_upd[fifo], fifo_ldq_req_push[fifo]};
      end
   end
endgenerate

// Last entry of FIFO
assign fifo_ldq_req_tid_d[`LMQ_ENTRIES-1]    = ~fifo_ldq_req_cntrl[`LMQ_ENTRIES-1][0] ? fifo_ldq_req_tid_q[`LMQ_ENTRIES-1] : ctl_lsq_ex5_thrd_id;
assign fifo_ldq_req_d[`LMQ_ENTRIES-1]        = ~fifo_ldq_req_cntrl[`LMQ_ENTRIES-1][0] ? fifo_ldq_req_q[`LMQ_ENTRIES-1] : ex5_ldqe_set_all_q;
assign fifo_ldq_req_pfetch_d[`LMQ_ENTRIES-1] = (fifo_ldq_req_cntrl[`LMQ_ENTRIES-1] == 2'b00) ? fifo_ldq_req_pfetch[`LMQ_ENTRIES-1] :
                                               (fifo_ldq_req_cntrl[`LMQ_ENTRIES-1] == 2'b01) ? 1'b0 :
                                                ex5_pfetch_val_q;
assign fifo_ldq_req_val_d[`LMQ_ENTRIES-1]    = (fifo_ldq_req_cntrl[`LMQ_ENTRIES-1] == 2'b00) ? fifo_ldq_req_val[`LMQ_ENTRIES-1] :
                                               (fifo_ldq_req_cntrl[`LMQ_ENTRIES-1] == 2'b01) ? 1'b0 :
                                                1'b1;

// Rest of the entries of FIFO
generate begin : ldqFifo
      genvar                                                  fifo;
      for (fifo=0; fifo<=`LMQ_ENTRIES-2; fifo=fifo+1) begin : ldqFifo
         assign fifo_ldq_req_tid_d[fifo] = (fifo_ldq_req_cntrl[fifo] == 2'b00) ? fifo_ldq_req_tid_q[fifo] :
                                           (fifo_ldq_req_cntrl[fifo] == 2'b01) ? fifo_ldq_req_tid_q[fifo+1] :
                                           ctl_lsq_ex5_thrd_id;

         assign fifo_ldq_req_d[fifo] = (fifo_ldq_req_cntrl[fifo] == 2'b00) ? fifo_ldq_req_q[fifo] :
                                       (fifo_ldq_req_cntrl[fifo] == 2'b01) ? fifo_ldq_req_q[fifo+1] :
                                       ex5_ldqe_set_all_q;

         assign fifo_ldq_req_pfetch_d[fifo] = (fifo_ldq_req_cntrl[fifo] == 2'b00) ? fifo_ldq_req_pfetch[fifo] :
                                              (fifo_ldq_req_cntrl[fifo] == 2'b01) ? fifo_ldq_req_pfetch[fifo+1] :
                                              ex5_pfetch_val_q;

         assign fifo_ldq_req_val_d[fifo] = (fifo_ldq_req_cntrl[fifo] == 2'b00) ? fifo_ldq_req_val[fifo] :
                                           (fifo_ldq_req_cntrl[fifo] == 2'b01) ? fifo_ldq_req_val[fifo+1] :
                                           1'b1;
      end
   end
endgenerate

// Muxing Load Request to send to the L2
always @(*) begin: ldqMux
   reg [0:3]                                               usrDef;
   reg [0:4]                                               wimge;
   reg [64-`REAL_IFAR_WIDTH:63]                            pAddr;
   reg [0:5]                                               tType;
   reg [0:2]                                               opsize;
   reg [0:`THREADS-1]                                      tid;

   (* analysis_not_referenced="true" *)

   integer                                                 ldq;
   usrDef = {4{1'b0}};
   wimge  = {5{1'b0}};
   pAddr  = {`REAL_IFAR_WIDTH{1'b0}};
   tType  = {6{1'b0}};
   opsize = {3{1'b0}};
   tid    = {`THREADS{1'b0}};
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin
      usrDef = (ldqe_usr_def_q[ldq] & {               4{fifo_ldq_req_q[0][ldq]}}) | usrDef;
      wimge  = (ldqe_wimge_q[ldq]   & {               5{fifo_ldq_req_q[0][ldq]}}) | wimge;
      pAddr  = (ldqe_p_addr_q[ldq]  & {`REAL_IFAR_WIDTH{fifo_ldq_req_q[0][ldq]}}) | pAddr;
      tType  = (ldqe_ttype_q[ldq]   & {               6{fifo_ldq_req_q[0][ldq]}}) | tType;
      opsize = (ldqe_op_size_q[ldq] & {               3{fifo_ldq_req_q[0][ldq]}}) | opsize;
      tid    = (ldqe_thrd_id_q[ldq] & {        `THREADS{fifo_ldq_req_q[0][ldq]}}) | tid;
   end
   ldq_mux_usr_def <= usrDef;
   ldq_mux_wimge   <= wimge;
   ldq_mux_p_addr  <= pAddr;
   ldq_mux_ttype   <= tType;
   ldq_mux_opsize  <= opsize;
   ldq_mux_tid     <= tid;
end

// Generate Encode Thread ID
always @(*) begin: tidMulti
   reg [0:1]                                               ex5Tid;
   reg [0:1]                                               ldqTid;

   (* analysis_not_referenced="true" *)

   integer                                             tid;
   ex5Tid = {2{1'b0}};
   ldqTid = {2{1'b0}};
   for (tid=1; tid<`THREADS; tid=tid+1) begin
      ex5Tid = (tid[1:0] & {2{ctl_lsq_ex5_thrd_id[tid]}}) | ex5Tid;
      ldqTid = (tid[1:0] & {2{        ldq_mux_tid[tid]}}) | ldqTid;
   end
   ex5_tid_enc     <= ex5Tid;
   ldq_mux_tid_enc <= ldqTid;
end

// Generate Core Tag
always @(*) begin: ldqcTag
   reg [0:3]                                               entryF;
   reg [0:3]                                               entryP;

   (* analysis_not_referenced="true" *)

   integer                                             ldq;
   entryF = 4'b0000;
   entryP = 4'b0000;
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin
      entryF = (ldq[3:0] & {4{ fifo_ldq_req_q[0][ldq]}}) | entryF;
      entryP = (ldq[3:0] & {4{ex5_ldqe_set_all_q[ldq]}}) | entryP;
   end
   ldq_mux_cTag <= entryF;
   ex5_cTag     <= entryP;
end

// Select between entry already in LOADMISSQ and
// entry going into LOADMISSQ
assign ldq_arb_usr_def  = fifo_ldq_req_val_q[0] ? ldq_mux_usr_def : ctl_lsq_ex5_usr_def;
assign ldq_arb_tid      = fifo_ldq_req_val_q[0] ? ldq_mux_tid_enc : ex5_tid_enc;
assign ldq_arb_wimge    = fifo_ldq_req_val_q[0] ? ldq_mux_wimge : ex5_wimge_q;
assign ldq_arb_p_addr   = fifo_ldq_req_val_q[0] ? ldq_mux_p_addr : ex5_p_addr_q;
assign ldq_arb_ttype    = fifo_ldq_req_val_q[0] ? ldq_mux_ttype : ctl_lsq_ex5_ttype;
assign ldq_arb_opsize   = fifo_ldq_req_val_q[0] ? ldq_mux_opsize : ctl_lsq_ex5_opsize;
assign ldq_arb_cTag     = fifo_ldq_req_val_q[0] ? {ldq_mux_cTag[0], 1'b0, ldq_mux_cTag[1:3]} : {ex5_cTag[0], 1'b0, ex5_cTag[1:3]};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RELOAD DATA BEATS ARBITER
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Select Between L2 Reload and Reload Queue
assign ldq_resp_cTag = l2_rel0_resp_ldq_val_q ? l2_rel0_resp_cTag_q : ldq_rel0_arb_cTag;
assign ldq_resp_qw   = l2_rel0_resp_ldq_val_q ? l2_rel0_resp_qw_q : ldq_rel0_arb_qw;

// Reload Valid
assign ldq_reload_qw       = ldq_resp_qw[57:59];
assign ldq_reload_val      = l2_rel0_resp_ldq_val_q | ldq_rel0_arb_val;
assign ldq_rel1_arb_val_d  = ldq_rel0_arb_val & ~l2_rel0_resp_ldq_val_q;
assign ldq_rel1_val_d      = ldq_reload_val;
assign ldq_rel0_rdat_sel   = ldq_rel0_arb_val & (~l2_rel0_resp_ldq_val_q);
assign ldq_rel0_rdat_qw    = ldq_reload_qw[57:59];
assign ldq_rel0_arr_wren   = |(ldq_rel0_l2_val_q);
assign ldq_rel1_l1_dump_d  = l2_rel0_resp_ldq_val_q & l2_rel0_resp_l1_dump_q;
assign ldq_rel2_l1_dump_d  = ldq_rel1_l1_dump_q;
assign ldq_rel3_l1_dump_d  = ldq_rel2_l1_dump_q & |(ldq_rel2_l2_val_q & ldq_rel2_beats_home_q & (~(ldqe_wimge_i | ldqe_rel_eccdet)));
assign ldq_rel3_l1_dump_val = ldq_rel3_l1_dump_q;
assign ldq_rel3_clr_relq_d = |(ldq_rel2_beats_home_q & ldq_rel2_l2_val_q & ldqe_rel_eccdet);
assign ldq_rel1_resp_qw_d  = spr_xucr0_cls_q ? ldq_reload_qw[57:59] : {ldq_rel_mux_p_addr[57], ldq_reload_qw[58:59]};
assign ldq_rel1_cTag_d     = ldq_resp_cTag;
assign l2_rel1_resp_val_d  = l2_rel0_resp_val_q;
assign l2_rel2_resp_val_d  = l2_rel1_resp_val_q;
assign ldq_err_inval_rel_d = |(ldq_relmin1_l2_inval);
assign ldq_err_ecc_det_d   = l2_rel2_resp_val_q & l2_lsq_resp_ecc_err;
assign ldq_err_ue_det_d    = l2_rel2_resp_val_q & l2_lsq_resp_ecc_err_ue;

// 1-hot of quadword updated
generate begin : relDat
      genvar                                                  beat;
      for (beat=0; beat<8; beat=beat+1) begin : relDat
         wire [0:2]     beatDummy;
         assign beatDummy = beat[2:0];
         assign ldq_rel0_beat_upd[beat] = (beatDummy == ldq_reload_qw);
      end
   end
endgenerate

lq_ldq_relq relq(
   // ACT's
   .ldq_rel0_stg_act(rel0_stg_act),
   .ldq_rel1_stg_act(ldq_rel1_val_q),
   .ldqe_ctrl_act(ldqe_ctrl_act),

   // Reload Data Beats Control
   .ldq_rel0_arb_sent(ldq_rel0_arb_sent),
   .ldq_rel0_beat_upd(ldq_rel0_beat_upd),
   .ldq_rel0_arr_wren(ldq_rel0_arr_wren),
   .ldq_rel0_rdat_qw(ldq_rel0_rdat_qw),
   .ldq_rel1_cTag(ldq_rel1_cTag_q),
   .ldq_rel1_dbeat_val(ldq_rel1_dbeat_val),
   .ldq_rel1_beats_home(ldq_rel1_beats_home),
   .ldq_rel2_entrySent(ldq_rel2_entrySent_q),
   .ldq_rel2_blk_req(rel2_blk_req_q),
   .ldq_rel2_sentL1(ldq_rel2_sentL1),
   .ldq_rel2_sentL1_blk(ldq_rel2_sentL1_blk),
   .ldqe_rel_eccdet(ldqe_rel_eccdet),
   .ldqe_rst_eccdet(ldqe_rst_eccdet_q),

   // Reload Data Select Valid
   .ldq_rel0_rdat_sel(ldq_rel0_rdat_sel),
   .arb_ldq_rel2_wrt_data(arb_ldq_rel2_wrt_data),

   // Reload Arbiter Control Outputs
   .ldq_rel0_arb_val(ldq_rel0_arb_val),
   .ldq_rel0_arb_qw(ldq_rel0_arb_qw),
   .ldq_rel0_arb_cTag(ldq_rel0_arb_cTag),
   .ldq_rel0_arb_thresh(ldq_rel0_arb_thresh),
   .ldq_rel2_rdat_perr(ldq_rel2_rdat_perr),
   .ldq_rel3_rdat_par_err(ldq_rel3_rdat_par_err),
   .ldqe_rel_rdat_perr(ldqe_rel_rdat_perr),

   // Reload Data Arbiter Data
   .ldq_arb_rel2_rdat_sel(ldq_arb_rel2_rdat_sel),
   .ldq_arb_rel2_rd_data(ldq_arb_rel2_rd_data),

   // SPR's
   .pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),
   .spr_lsucr0_lca_ovrd(spr_lsucr0_lca_ovrd),

   // Array Pervasive Controls
   .bo_enable_2(bo_enable_2),
   .clkoff_dc_b(clkoff_dc_b),
   .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
   .g8t_d_mode_dc(g8t_d_mode_dc),
   .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
   .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
   .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
   .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
   .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
   .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
   .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
   .pc_lq_abist_ena_dc(pc_lq_abist_ena_dc),
   .pc_lq_abist_raw_dc_b(pc_lq_abist_raw_dc_b),
   .pc_lq_abist_wl64_comp_ena(pc_lq_abist_wl64_comp_ena),
   .pc_lq_abist_raddr_0(pc_lq_abist_raddr_0),
   .pc_lq_abist_g8t_wenb(pc_lq_abist_g8t_wenb),
   .pc_lq_abist_g8t1p_renb_0(pc_lq_abist_g8t1p_renb_0),
   .pc_lq_abist_g8t_dcomp(pc_lq_abist_g8t_dcomp),
   .pc_lq_abist_g8t_bw_1(pc_lq_abist_g8t_bw_1),
   .pc_lq_abist_g8t_bw_0(pc_lq_abist_g8t_bw_0),
   .pc_lq_abist_di_0(pc_lq_abist_di_0),
   .pc_lq_abist_waddr_0(pc_lq_abist_waddr_0),
   .pc_lq_bo_unload(pc_lq_bo_unload),
   .pc_lq_bo_repair(pc_lq_bo_repair),
   .pc_lq_bo_reset(pc_lq_bo_reset),
   .pc_lq_bo_shdata(pc_lq_bo_shdata),
   .pc_lq_bo_select(pc_lq_bo_select),
   .lq_pc_bo_fail(lq_pc_bo_fail),
   .lq_pc_bo_diagout(lq_pc_bo_diagout),

   //Pervasive
   .vcs(vcs),
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .abst_sl_thold_0(abst_sl_thold_0),
   .ary_nsl_thold_0(ary_nsl_thold_0),
   .time_sl_thold_0(time_sl_thold_0),
   .repr_sl_thold_0(repr_sl_thold_0),
   .bolt_sl_thold_0(bolt_sl_thold_0),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(rdat_scan_in),
   .abst_scan_in(abst_scan_in),
   .time_scan_in(time_scan_in),
   .repr_scan_in(repr_scan_in),
   .scan_out(rdat_scan_out),
   .abst_scan_out(abst_scan_out),
   .time_scan_out(time_scan_out),
   .repr_scan_out(repr_scan_out)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RELOAD QUEUE ENTRY SELECT
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Muxing Reload Request to send to the L1
always @(*) begin: relMux
   reg [0:2]                                               opsize;
   reg                                                     wimge_i;
   reg                                                     byte_swap;
   reg [64-`REAL_IFAR_WIDTH:63]                            pAddr;
   reg [0:1]                                               dvcEn;
   reg                                                     lockSet;
   reg                                                     watchSet;
   reg [0:AXU_TARGET_ENC-1]                                tGpr;
   reg                                                     axu;
   reg                                                     algEn;
   reg [0:1]                                               classID;
   reg                                                     binv;
   reg [0:`THREADS-1]                                      tid;
   reg [0:`ITAG_SIZE_ENC-1]                                iTagM1;
   reg [0:`THREADS-1]                                      tidM1;

   (* analysis_not_referenced="true" *)

   integer                                                 ldq;
   opsize      = {3{1'b0}};
   wimge_i     = 1'b0;
   byte_swap   = 1'b0;
   pAddr       = {`REAL_IFAR_WIDTH{1'b0}};
   dvcEn       = {2{1'b0}};
   lockSet     = 1'b0;
   watchSet    = 1'b0;
   tGpr        = {AXU_TARGET_ENC{1'b0}};
   axu         = 1'b0;
   algEn       = 1'b0;
   classID     = {2{1'b0}};
   binv        = 1'b0;
   tid         = {`THREADS{1'b0}};
   iTagM1      = {`ITAG_SIZE_ENC{1'b0}};
   tidM1       = {`THREADS{1'b0}};
   for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin
      opsize      = (ldqe_op_size_q[ldq]                 & {               3{ldqe_rel0_cTag[ldq]}}) | opsize;
      wimge_i     = (ldqe_wimge_i[ldq]                   &                   ldqe_rel0_cTag[ldq])   | wimge_i;
      byte_swap   = (ldqe_byte_swap_q[ldq]               &                   ldqe_rel0_cTag[ldq])   | byte_swap;
      pAddr       = (ldqe_p_addr_q[ldq]                  & {`REAL_IFAR_WIDTH{ldqe_rel0_cTag[ldq]}}) | pAddr;
      dvcEn       = (ldqe_dvc_q[ldq]                     & {               2{ldqe_rel0_cTag[ldq]}}) | dvcEn;
      lockSet     = (ldqe_lock_set_q[ldq]  & (~ldqe_resent_ecc_err_q[ldq]) & ldqe_rel0_cTag[ldq])   | lockSet;
      watchSet    = (ldqe_watch_set_q[ldq] & (~ldqe_resent_ecc_err_q[ldq]) & ldqe_rel0_cTag[ldq])   | watchSet;
      tGpr        = (ldqe_tgpr_q[ldq]                    & {  AXU_TARGET_ENC{ldqe_rel0_cTag[ldq]}}) | tGpr;
      axu         = (ldqe_axu_q[ldq]                     &                   ldqe_rel0_cTag[ldq])   | axu;
      algEn       = (ldqe_algebraic_q[ldq]               &                   ldqe_rel0_cTag[ldq])   | algEn;
      classID     = (ldqe_class_id_q[ldq]                & {               2{ldqe_rel0_cTag[ldq]}}) | classID;
      tid         = (ldqe_thrd_id_q[ldq]                 & {        `THREADS{ldqe_rel0_cTag[ldq]}}) | tid;
      binv        = (ldqe_back_inv_q[ldq]                &                   ldqe_rel1_cTag[ldq])   | binv;
      iTagM1      = (ldqe_itag_q[ldq]                   & {`ITAG_SIZE_ENC{ldqe_relmin1_cTag[ldq]}}) | iTagM1;
      tidM1       = (ldqe_thrd_id_q[ldq]                 & {     `THREADS{ldqe_relmin1_cTag[ldq]}}) | tidM1;
   end
   ldq_rel_mux_opsize      <= opsize;
   ldq_rel_mux_wimge_i     <= wimge_i;
   ldq_rel_mux_byte_swap   <= byte_swap;
   ldq_rel_mux_p_addr      <= pAddr;
   ldq_rel_mux_dvcEn       <= dvcEn;
   ldq_rel_mux_lockSet     <= lockSet;
   ldq_rel_mux_watchSet    <= watchSet;
   ldq_rel_mux_tGpr        <= tGpr;
   ldq_rel_mux_axu         <= axu;
   ldq_rel_mux_algEn       <= algEn;
   ldq_rel_mux_classID     <= classID;
   ldq_rel_mux_tid         <= tid;
   ldq_rel1_mux_back_inv   <= binv;
   ldqe_relmin1_iTag       <= iTagM1;
   ldqe_relmin1_tid        <= tidM1;
end

// Muxing Reload Request from Gather Queue to send to the L1
always @(*) begin: gath_relMux
   reg [0:2]                                               opsize;
   reg                                                     byte_swap;
   reg [0:1]                                               dvcEn;
   reg [0:AXU_TARGET_ENC-1]                                tGpr;
   reg                                                     axu;
   reg                                                     algEn;
   reg [0:`THREADS-1]                                      tid;
   reg [59:63]                                             addr;
   reg [0:`ITAG_SIZE_ENC-1]                                iTagM1;
   reg [0:`THREADS-1]                                      tidM1;

   (* analysis_not_referenced="true" *)

   integer                                                 lgq;
   opsize      = {3{1'b0}};
   byte_swap   = 1'b0;
   dvcEn       = {2{1'b0}};
   tGpr        = {AXU_TARGET_ENC{1'b0}};
   axu         = 1'b0;
   algEn       = 1'b0;
   tid         = {`THREADS{1'b0}};
   addr        = {5{1'b0}};
   iTagM1      = {`ITAG_SIZE_ENC{1'b0}};
   tidM1       = {`THREADS{1'b0}};
   for (lgq=0; lgq<`LGQ_ENTRIES; lgq=lgq+1) begin
      opsize      = (lgqe_op_size_q[lgq]       & {             3{lgq_rel0_upd_gpr_q[lgq]}}) | opsize;
      byte_swap   = (lgqe_byte_swap_q[lgq]     &                 lgq_rel0_upd_gpr_q[lgq])   | byte_swap;
      dvcEn       = (lgqe_dvc_q[lgq]           & {             2{lgq_rel0_upd_gpr_q[lgq]}}) | dvcEn;
      tGpr        = (lgqe_tgpr_q[lgq]          & {AXU_TARGET_ENC{lgq_rel0_upd_gpr_q[lgq]}}) | tGpr;
      axu         = (lgqe_axu_q[lgq]           &                 lgq_rel0_upd_gpr_q[lgq])   | axu;
      algEn       = (lgqe_algebraic_q[lgq]     &                 lgq_rel0_upd_gpr_q[lgq])   | algEn;
      tid         = (lgqe_thrd_id_q[lgq]       & {      `THREADS{lgq_rel0_upd_gpr_q[lgq]}}) | tid;
      addr        = (lgqe_p_addr_q[lgq][59:63] & {             5{lgq_rel0_upd_gpr_q[lgq]}}) | addr;
      iTagM1      = (lgqe_itag_q[lgq]          & {`ITAG_SIZE_ENC{lgqe_relmin1_match[lgq]}}) | iTagM1;
      tidM1       = (lgqe_thrd_id_q[lgq]       & {      `THREADS{lgqe_relmin1_match[lgq]}}) | tidM1;
   end
   lgq_rel_mux_opsize    <= opsize;
   lgq_rel_mux_byte_swap <= byte_swap;
   lgq_rel_mux_dvcEn     <= dvcEn;
   lgq_rel_mux_tGpr      <= tGpr;
   lgq_rel_mux_axu       <= axu;
   lgq_rel_mux_algEn     <= algEn;
   lgq_rel_mux_tid       <= tid;
   lgq_rel_mux_p_addr    <= addr;
   lgqe_relmin1_iTag     <= iTagM1;
   lgqe_relmin1_tid      <= tidM1;
end

// Latch up Reload Interface to other units
assign ldq_rel0_opsize                             = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_opsize : lgq_rel_mux_opsize;
assign ldq_rel1_opsize_d                           = ldq_rel0_opsize;
assign ldq_rel1_wimge_i_d                          = ldq_rel_mux_wimge_i;
assign ldq_rel0_byte_swap                          = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_byte_swap : lgq_rel_mux_byte_swap;
assign ldq_rel1_byte_swap_d                        = ldq_rel0_byte_swap;
assign ldq_rel2_byte_swap_d                        = ldq_rel1_byte_swap_q;
assign ldq_rel1_p_addr_d[64 - `REAL_IFAR_WIDTH:58] = ldq_rel_mux_p_addr[64 - `REAL_IFAR_WIDTH:58];
assign ldq_rel0_p_addr[59:63]                      = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_p_addr[59:63] : lgq_rel_mux_p_addr;
assign ldq_rel1_p_addr_d[59:63]                    = ldq_rel0_p_addr[59:63];
assign ldq_rel1_dvcEn_d                            = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_dvcEn : lgq_rel_mux_dvcEn;
assign ldq_rel1_lockSet_d                          = ldq_rel_mux_lockSet;
assign ldq_rel1_watchSet_d                         = ldq_rel_mux_watchSet;
assign ldq_rel1_tGpr_d                             = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_tGpr : lgq_rel_mux_tGpr;
assign ldq_rel1_axu_d                              = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_axu : lgq_rel_mux_axu;
assign ldq_rel1_algEn_d                            = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_algEn : lgq_rel_mux_algEn;
assign ldq_rel1_classID_d                          = ldq_rel_mux_classID;
assign ldq_rel1_tid_d                              = l2_rel0_resp_crit_qw_q ? ldq_rel_mux_tid : lgq_rel_mux_tid;
assign ldq_rel1_dir_tid_d                          = ldq_rel_mux_tid;
assign ldq_rel2_tid_d                              = ldq_rel1_tid_q;
assign ldq_relmin1_iTag                            = l2_lsq_resp_crit_qw ? ldqe_relmin1_iTag : lgqe_relmin1_iTag;
assign ldq_relmin1_tid                             = l2_lsq_resp_crit_qw ? ldqe_relmin1_tid : lgqe_relmin1_tid;

// Need to Mask off bit 57 of Reload Address depending on the Cacheline Size we are running with
assign ldq_rel_mux_p_addr_msk = {ldq_rel_mux_p_addr[64 - (`DC_SIZE - 3):56], (ldq_rel_mux_p_addr[57] | spr_xucr0_cls_q)};

// Back-Invalidate Congruence Class collided with Reload Congruence Class
assign ldq_rel1_collide_binv_d = l2_back_inv_val & ldq_rel0_updating_cache & (l2_back_inv_addr_msk[64-(`DC_SIZE-3):63-`CL_SIZE] == ldq_rel_mux_p_addr_msk);

// Check to see if any of the data beats got any ECC type errors on the reload
assign rel2_eccdet      = |(ldqe_rel_eccdet & ldq_rel2_entrySent_q);
assign rel2_eccdet_ue   = |(ldqe_rel_eccdet_ue & ldq_rel2_entrySent_q);
assign rel2_eccdet_err  = rel2_eccdet | rel2_eccdet_ue;

// Need to lookup in the directory to determine which way to update
// Added ldqe_rst_eccdet_q to cover the case where the last beat on the reload interface
// is in rel3 and it got an ECC error on that beat and the reload_dataq is sending a request
// that is currently in the rel1 stage
assign ldq_rel1_clr_val    = |(ldq_rel1_entrySent_q & ~(ldqe_relDir_start | ldqe_rst_eccdet_q));
assign ldq_rel2_cclass_d   = {ldq_rel1_p_addr_q[64-(`DC_SIZE-3):56], (ldq_rel1_p_addr_q[57] | spr_xucr0_cls_q)};
assign ldq_rel3_cclass_d   = ldq_rel2_cclass_q;
assign ldq_rel4_cclass_d   = ldq_rel3_cclass_q;

assign ldq_rel1_set_val    = |(ldq_rel1_entrySent_q & ldqe_last_beat & ~ldqe_rst_eccdet_q);
assign ldq_rel2_set_val_d  = ldq_rel1_set_val;
assign ldq_rel3_set_val_d  = ldq_rel2_set_val_q & (~rel2_blk_req_q);
assign ldq_rel4_set_val_d  = ldq_rel3_set_val_q;
// reloadQueue included, dont want to block if the arb is sending request since
// it would be the reload queue sending
// if reloadQueue is not included, want to block data_val since arb is only trying to
// update the directory state, the data cache should have already been updated
assign ldq_rel1_data_val   = (|(ldq_rel1_entrySent_q & ~ldqe_rst_eccdet_q)) & ~ldq_rel1_arb_val_q;
assign ldq_rel1_data_sel_d = ldq_rel0_updating_cache;
assign ldq_rel1_gpr_val_d  = |(ldq_rel0_upd_gpr_q);

// loadmiss statemachine set itagHold, want to force reload through
// instead of using reload arbitration
assign ldq_l2_rel0_qHitBlk_d = |(ldq_relmin1_l2_qHitBlk);

// Update GPR detection
assign ldq_rel1_upd_gpr_d     = ldq_rel0_crit_qw;
assign ldq_rel2_upd_gpr_d     = ldq_rel1_upd_gpr_q;
assign ldq_rel3_upd_gpr_d     = ldq_rel2_upd_gpr_q;
assign ldq_rel2_gpr_ecc_err   = (ldq_rel2_upd_gpr_q & ~ldqe_dGpr_q) & {`LMQ_ENTRIES{l2_lsq_resp_ecc_err | l2_lsq_resp_ecc_err_ue}};
assign ldq_rel2_gpr_eccue_err = (ldq_rel2_upd_gpr_q & ~ldqe_dGpr_q) & {`LMQ_ENTRIES{l2_lsq_resp_ecc_err_ue}};
assign ldq_rel1_upd_gpr       = ldq_rel1_upd_gpr_q & (~(ldqe_dGpr_q | ldqe_kill));

// Instruction Complete detection, completion report is dependent on the instruction
assign ldqe_rel2_drop_cpl_rpt    = ldqe_lock_set_q | ldqe_watch_set_q | ldqe_resv_q | ldqe_sent_cpl_q | ldqe_need_cpl_q;
assign ldqe_rel3_drop_cpl_rpt_d  = ldqe_rel2_drop_cpl_rpt;
assign ldqe_reld_cpl_rpt         = (ldqe_lock_set_q | ldqe_watch_set_q | ldqe_resv_q) & (~(ldqe_sent_cpl_q | ldqe_need_cpl_q));
assign ldq_rel2_send_cpl_ok      = ldq_rel2_upd_gpr_q & (~ldqe_rel2_drop_cpl_rpt);
assign ldq_rel6_send_cpl_ok      = ldq_rel6_req_done_q & ldqe_reld_cpl_rpt;
assign ldq_rel_send_cpl_ok       = ldq_rel2_send_cpl_ok | ldq_rel6_send_cpl_ok;
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ORDER QUEUE REPORT COMPLETE CONTROL
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Need to pipe down reload complete indicator to rel3, at rel3,
// we have all the information we need for the reload completion report
// ldawx, dcbt[st]ls, and larx will never send there complete report
// back to the order queue
assign ldq_rel3_odq_cpl = ldq_rel3_upd_gpr_q & (~ldqe_rel3_drop_cpl_rpt_q);

// Muxing Reload Request from LoadMiss Queue and Gather Queue to send to the Order Queue
always @(*) begin: odqCplMux
   reg [0:`ITAG_SIZE_ENC-1]                                iTag;
   reg                                                     ecc;
   reg                                                     eccue;
   reg [0:1]                                               dvcEn;
   reg [0:3]                                               dacrw;
   reg [0:`THREADS-1]                                      tid;
   reg                                                     nFlush;
   reg                                                     np1Flush;
   reg [0:3]                                               pEvents;
   (* analysis_not_referenced="true" *)
   integer                                                 ldq;

   iTag     = {`ITAG_SIZE_ENC{1'b0}};
   ecc      = 1'b0;
   eccue    = 1'b0;
   dvcEn    = {2{1'b0}};
   dacrw    = {4{1'b0}};
   tid      = {`THREADS{1'b0}};
   nFlush   = 1'b0;
   np1Flush = 1'b0;
   pEvents  = {4{1'b0}};
  for (ldq=0; ldq<=(`LMQ_ENTRIES+`LGQ_ENTRIES)-1; ldq=ldq+1) begin : odqCplMux
      if (ldq < `LMQ_ENTRIES) begin : lmqEntry
        iTag     = (ldqe_itag_q[ldq]              & {`ITAG_SIZE_ENC{ldq_rel3_odq_cpl[ldq]}}) | iTag;
        ecc      = (ldqe_upd_gpr_ecc_q[ldq]       &                 ldq_rel3_odq_cpl[ldq])   | ecc;
        eccue    = (ldqe_upd_gpr_eccue_q[ldq]    &                  ldq_rel3_odq_cpl[ldq])   | eccue;
        dvcEn    = (ldqe_dvc_q[ldq]               &              {2{ldq_rel3_odq_cpl[ldq]}}) | dvcEn;
        dacrw    = (ldqe_dacrw_q[ldq]             &              {4{ldq_rel3_odq_cpl[ldq]}}) | dacrw;
        tid      = (ldqe_thrd_id_q[ldq]           &       {`THREADS{ldq_rel3_odq_cpl[ldq]}}) | tid;
        nFlush   = (ldqe_back_inv_nFlush_q[ldq]   &                 ldq_rel3_odq_cpl[ldq])   | nFlush;
        np1Flush = (ldqe_back_inv_np1Flush_q[ldq] &                 ldq_rel3_odq_cpl[ldq])   | np1Flush;
        pEvents  = (ldqe_perf_events_q[ldq]       &              {4{ldq_rel3_odq_cpl[ldq]}}) | pEvents;
      end
      if (ldq >= `LMQ_ENTRIES) begin : lgqEntry
        iTag     = (lgqe_itag_q[ldq-`LMQ_ENTRIES]              & {`ITAG_SIZE_ENC{lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES]}}) | iTag;
        ecc      = (lgqe_upd_gpr_ecc_q[ldq-`LMQ_ENTRIES]       &                 lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES])   | ecc;
        eccue    = (lgqe_upd_gpr_eccue_q[ldq-`LMQ_ENTRIES]    &                  lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES])   | eccue;
        dvcEn    = (lgqe_dvc_q[ldq-`LMQ_ENTRIES]               &              {2{lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES]}}) | dvcEn;
        dacrw    = (lgqe_dacrw_q[ldq-`LMQ_ENTRIES]             &              {4{lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES]}}) | dacrw;
        tid      = (lgqe_thrd_id_q[ldq-`LMQ_ENTRIES]           &       {`THREADS{lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES]}}) | tid;
        nFlush   = (lgqe_back_inv_nFlush_q[ldq-`LMQ_ENTRIES]   &                 lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES])   | nFlush;
        np1Flush = (lgqe_back_inv_np1Flush_q[ldq-`LMQ_ENTRIES] &                 lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES])   | np1Flush;
        pEvents  = (lgqe_perf_events_q[ldq-`LMQ_ENTRIES]       &              {4{lgq_rel3_upd_gpr_q[ldq-`LMQ_ENTRIES]}}) | pEvents;
      end
   end
   ldq_rel3_odq_itag     <= iTag;
   ldq_rel3_odq_ecc      <= ecc;
   ldq_rel3_odq_eccue    <= eccue;
   ldq_rel3_odq_dvc      <= dvcEn;
   ldq_rel3_odq_dacrw    <= dacrw;
   ldq_rel3_odq_tid      <= tid;
   ldq_rel3_odq_nFlush   <= nFlush;
   ldq_rel3_odq_np1Flush <= np1Flush;
   ldq_rel3_odq_pEvents  <= pEvents;
end

// Determine if we should be taking a debug interrupt
assign dbg_int_en_d = ctl_lsq_dbg_int_en;
assign ldq_rel3_odq_dbg_int_en = |(ldq_rel3_odq_tid & dbg_int_en_q);

//                        CritQW got ECC          Back-Invalidate and not CP_NEXT
assign ldq_rel3_odq_oth_flush = ldq_rel3_odq_ecc | ldq_rel3_odq_nFlush;
assign ldq_rel3_dacrw[0:1]    = (ldq_rel3_odq_dacrw[0:1] | ldq_rel3_odq_dvc) & {2{~(ldq_rel3_odq_oth_flush | ldq_rel3_odq_np1Flush)}};
assign ldq_rel3_dacrw[2:3]    =  ldq_rel3_odq_dacrw[2:3]                     & {2{~(ldq_rel3_odq_oth_flush | ldq_rel3_odq_np1Flush)}};
assign ldq_rel3_odq_val       = ldq_rel3_odq_cpl & (~(ldqe_resolved_q | ldqe_kill));
assign lgq_rel3_odq_val       = lgq_rel3_upd_gpr_q & lgqe_valid_q & (~(lgqe_resolved_q | lgqe_kill));

// Need to pipeline ODQ update for a few cycles
// Need to check at the end to cover the window
// where the Order Queue already reported resolved
assign ldq_rel4_odq_cpl_d = ldq_rel3_odq_val;
assign ldq_rel5_odq_cpl_d = ldq_rel4_odq_cpl_q & (~ldqe_resolved);
assign ldq_rel5_odq_cpl   = ldq_rel5_odq_cpl_q & (~ldqe_resolved_q);
assign lgq_rel4_upd_gpr_d = lgq_rel3_upd_gpr_q & (~lgqe_kill);
assign lgq_rel5_upd_gpr_d = lgq_rel4_upd_gpr_q & (~lgqe_kill);
assign lgq_rel5_odq_cpl   = lgq_rel5_upd_gpr_q & lgqe_valid_q & (~(lgqe_resolved_q | lgqe_kill));

// Report to ODQ, ODQ needs to update its entry with the following information
assign ldq_odq_upd_val      = |(ldq_rel3_odq_val | lgq_rel3_odq_val);
assign ldq_odq_upd_itag     = ldq_rel3_odq_itag;
assign ldq_odq_upd_nFlush   = ldq_rel3_odq_oth_flush | |(ldq_rel3_dacrw & {4{ldq_rel3_odq_dbg_int_en}});
assign ldq_odq_upd_np1Flush = ldq_rel3_odq_np1Flush;
assign ldq_odq_upd_dacrw    = ldq_rel3_dacrw;
assign ldq_odq_upd_tid      = ldq_rel3_odq_tid;
assign ldq_odq_upd_pEvents  = ldq_rel3_odq_pEvents;
assign ldq_odq_upd_eccue    = ldq_rel3_odq_eccue;
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ENTRY REMOVAL and CREDIT RETURN ARBITRATION
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Doing a Round Robin Scheme within each 4 entries (called Groups)
// followed by a Round Robin Scheme within each Group

// Expand LDQ to max supported
generate begin : cplExp
      genvar                                                  grp;
      for (grp=0; grp<=(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4; grp=grp+1) begin : cplExp
         genvar bit;
         for (bit=0; bit<4; bit=bit+1) begin : bitSel
            if ((grp*4)+bit < `LMQ_ENTRIES) begin : ldqExst
               assign ldqe_remove[(grp*4)+bit] = ldqe_send_cpl[(grp*4)+bit];
            end
            if (((grp*4)+bit >= `LMQ_ENTRIES) && ((grp*4)+bit < `LMQ_ENTRIES+`LGQ_ENTRIES)) begin : lgqExst
               assign ldqe_remove[(grp*4)+bit] = lgqe_send_cpl[(grp*4)+bit-`LMQ_ENTRIES];
            end
            if ((grp*4)+bit >= `LMQ_ENTRIES+`LGQ_ENTRIES) begin : ldqNExst
               assign ldqe_remove[(grp*4)+bit] = 1'b0;
            end
         end
      end
   end
endgenerate

// Entry Select within Group
// Round Robin Scheme within each 4 entries in a Group
generate begin : cplGrpEntry
      genvar                                                  grp;
      for (grp = 0; grp <= (`LMQ_ENTRIES + `LGQ_ENTRIES - 1)/4; grp = grp + 1) begin : cplGrpEntry
         assign cpl_grpEntry_val[grp]    = ldqe_remove[grp * 4:(grp * 4) + 3];

         assign cpl_grpEntry_sel[grp][0] = (cpl_grpEntry_last_sel_q[grp][0] & ~(|cpl_grpEntry_val[grp][1:3]) & cpl_grpEntry_val[grp][0]) |
                                           (cpl_grpEntry_last_sel_q[grp][1] & ~(|cpl_grpEntry_val[grp][2:3]) & cpl_grpEntry_val[grp][0]) |
                                           (cpl_grpEntry_last_sel_q[grp][2] &   ~cpl_grpEntry_val[grp][3]    & cpl_grpEntry_val[grp][0]) |
                                           (cpl_grpEntry_last_sel_q[grp][3] &                                  cpl_grpEntry_val[grp][0]);

         assign cpl_grpEntry_sel[grp][1] = (cpl_grpEntry_last_sel_q[grp][0] &                                                              cpl_grpEntry_val[grp][1]) |
                                           (cpl_grpEntry_last_sel_q[grp][1] & ~(|{cpl_grpEntry_val[grp][0], cpl_grpEntry_val[grp][2:3]}) & cpl_grpEntry_val[grp][1]) |
                                           (cpl_grpEntry_last_sel_q[grp][2] & ~(|{cpl_grpEntry_val[grp][0], cpl_grpEntry_val[grp][3]})   & cpl_grpEntry_val[grp][1]) |
                                           (cpl_grpEntry_last_sel_q[grp][3] &    ~cpl_grpEntry_val[grp][0]                               & cpl_grpEntry_val[grp][1]);

         assign cpl_grpEntry_sel[grp][2] = (cpl_grpEntry_last_sel_q[grp][0] &    ~cpl_grpEntry_val[grp][1]                               & cpl_grpEntry_val[grp][2]) |
                                           (cpl_grpEntry_last_sel_q[grp][1] &                                                              cpl_grpEntry_val[grp][2]) |
                                           (cpl_grpEntry_last_sel_q[grp][2] & ~(|{cpl_grpEntry_val[grp][0:1], cpl_grpEntry_val[grp][3]}) & cpl_grpEntry_val[grp][2]) |
                                           (cpl_grpEntry_last_sel_q[grp][3] &  ~(|cpl_grpEntry_val[grp][0:1])                            & cpl_grpEntry_val[grp][2]);

         assign cpl_grpEntry_sel[grp][3] = (cpl_grpEntry_last_sel_q[grp][0] & ~(|cpl_grpEntry_val[grp][1:2]) & cpl_grpEntry_val[grp][3]) |
                                           (cpl_grpEntry_last_sel_q[grp][1] &   ~cpl_grpEntry_val[grp][2]    & cpl_grpEntry_val[grp][3]) |
                                           (cpl_grpEntry_last_sel_q[grp][2] &                                  cpl_grpEntry_val[grp][3]) |
                                           (cpl_grpEntry_last_sel_q[grp][3] & ~(|cpl_grpEntry_val[grp][0:2]) & cpl_grpEntry_val[grp][3]);

         // Load Queue Group Selected
         assign cpl_grpEntry_sent[grp]       = |(ldqe_cpl_sent[grp*4:(grp*4)+3]);
         assign cpl_grpEntry_last_sel_d[grp] = cpl_grpEntry_sent[grp] ? cpl_grpEntry_sel[grp] : cpl_grpEntry_last_sel_q[grp];

         // Mux Load Queue Entry within a Group
         always @(*) begin: cplMux
            reg [0:`ITAG_SIZE_ENC-1]                                iTag;
            reg                                                     ecc;
            reg                                                     eccue;
            reg [0:3]                                               dacrw;
            reg [0:1]                                               dvc;
            reg [0:`THREADS-1]                                      tid;
            reg                                                     nFlush;
            reg                                                     np1Flush;
            reg [0:3]                                               pEvents;
            reg                                                     larx;
            (* analysis_not_referenced="true" *)
            integer                                                 ldq;

            iTag     = {`ITAG_SIZE_ENC{1'b0}};
            ecc      = 1'b0;
            eccue    = 1'b0;
            dvc      = {2{1'b0}};
            dacrw    = {4{1'b0}};
            tid      = {`THREADS{1'b0}};
            nFlush   = 1'b0;
            np1Flush = 1'b0;
            pEvents  = {4{1'b0}};
            larx     = 1'b0;
            for (ldq=0; ldq<4; ldq=ldq+1) begin : cplMux
              if ((grp*4)+ldq < `LMQ_ENTRIES) begin : ldqExst
                 iTag     = (ldqe_itag_q[(grp*4)+ldq]              & {`ITAG_SIZE_ENC{cpl_grpEntry_sel[grp][ldq]}}) | iTag;
                 ecc      = (ldqe_nFlush_ecc_err[(grp*4)+ldq]      &                 cpl_grpEntry_sel[grp][ldq])   | ecc;
                 eccue    = (ldqe_upd_gpr_eccue_q[(grp*4)+ldq]     &                 cpl_grpEntry_sel[grp][ldq])   | eccue;
                 dvc      = (ldqe_dvc_q[(grp*4)+ldq]               &              {2{cpl_grpEntry_sel[grp][ldq]}}) | dvc;
                 dacrw    = (ldqe_dacrw_q[(grp*4)+ldq]             &              {4{cpl_grpEntry_sel[grp][ldq]}}) | dacrw;
                 tid      = (ldqe_thrd_id_q[(grp*4)+ldq]           &       {`THREADS{cpl_grpEntry_sel[grp][ldq]}}) | tid;
                 nFlush   = (ldqe_back_inv_nFlush_q[(grp*4)+ldq]   &                 cpl_grpEntry_sel[grp][ldq])   | nFlush;
                 np1Flush = (ldqe_back_inv_np1Flush_q[(grp*4)+ldq] &                 cpl_grpEntry_sel[grp][ldq])   | np1Flush;
                 pEvents  = (ldqe_perf_events_q[(grp*4)+ldq]       &              {4{cpl_grpEntry_sel[grp][ldq]}}) | pEvents;
                 larx     = (ldqe_resv_q[(grp*4)+ldq]              &                 cpl_grpEntry_sel[grp][ldq])   | larx;
              end
              if (((grp*4)+ldq >= `LMQ_ENTRIES) && ((grp*4)+ldq < `LMQ_ENTRIES+`LGQ_ENTRIES)) begin : lgqExst
                 iTag     = (lgqe_itag_q[(grp*4)+ldq-`LMQ_ENTRIES]              & {`ITAG_SIZE_ENC{cpl_grpEntry_sel[grp][ldq]}}) | iTag;
                 ecc      = (lgqe_upd_gpr_ecc_q[(grp*4)+ldq-`LMQ_ENTRIES]       &                 cpl_grpEntry_sel[grp][ldq])   | ecc;
                 eccue    = (lgqe_upd_gpr_eccue_q[(grp*4)+ldq-`LMQ_ENTRIES]     &                 cpl_grpEntry_sel[grp][ldq])   | eccue;
                 dvc      = (lgqe_dvc_q[(grp*4)+ldq-`LMQ_ENTRIES]               &              {2{cpl_grpEntry_sel[grp][ldq]}}) | dvc;
                 dacrw    = (lgqe_dacrw_q[(grp*4)+ldq-`LMQ_ENTRIES]             &              {4{cpl_grpEntry_sel[grp][ldq]}}) | dacrw;
                 tid      = (lgqe_thrd_id_q[(grp*4)+ldq-`LMQ_ENTRIES]           &       {`THREADS{cpl_grpEntry_sel[grp][ldq]}}) | tid;
                 nFlush   = (lgqe_back_inv_nFlush_q[(grp*4)+ldq-`LMQ_ENTRIES]   &                 cpl_grpEntry_sel[grp][ldq])   | nFlush;
                 np1Flush = (lgqe_back_inv_np1Flush_q[(grp*4)+ldq-`LMQ_ENTRIES] &                 cpl_grpEntry_sel[grp][ldq])   | np1Flush;
                 pEvents  = (lgqe_perf_events_q[(grp*4)+ldq-`LMQ_ENTRIES]       &              {4{cpl_grpEntry_sel[grp][ldq]}}) | pEvents;
              end
            end
            cpl_grpEntry_iTag[grp]     <= iTag;
            cpl_grpEntry_ecc[grp]      <= ecc;
            cpl_grpEntry_eccue[grp]    <= eccue;
            cpl_grpEntry_dvc[grp]      <= dvc;
            cpl_grpEntry_dacrw[grp]    <= dacrw;
            cpl_grpEntry_tid[grp]      <= tid;
            cpl_grpEntry_nFlush[grp]   <= nFlush;
            cpl_grpEntry_np1Flush[grp] <= np1Flush;
            cpl_grpEntry_pEvents[grp]  <= pEvents;
            cpl_grpEntry_larx[grp]     <= larx;
         end
      end
   end
endgenerate

// Group Select Between all Groups
// Round Robin Scheme within Groups
generate begin : cplGrp
      genvar                                                  grp;
      for (grp=0; grp<=3; grp=grp+1) begin : cplGrp
         if (grp <= (`LMQ_ENTRIES+`LGQ_ENTRIES- 1)/4) begin : grpExst
            assign cpl_group_val[grp] = |(cpl_grpEntry_val[grp]);
         end
         if (grp > (`LMQ_ENTRIES+`LGQ_ENTRIES- 1)/4) begin : grpNExst
            assign cpl_group_val[grp] = 1'b0;
         end
      end
   end
endgenerate

assign cpl_group_sel[0] = (cpl_group_last_sel_q[0] & ~(|cpl_group_val[1:3]) & cpl_group_val[0]) |
                          (cpl_group_last_sel_q[1] & ~(|cpl_group_val[2:3]) & cpl_group_val[0]) |
                          (cpl_group_last_sel_q[2] &   ~cpl_group_val[3]    & cpl_group_val[0]) |
                          (cpl_group_last_sel_q[3] &                          cpl_group_val[0]);

assign cpl_group_sel[1] = (cpl_group_last_sel_q[0] &                                              cpl_group_val[1]) |
                          (cpl_group_last_sel_q[1] & ~(|{cpl_group_val[0], cpl_group_val[2:3]}) & cpl_group_val[1]) |
                          (cpl_group_last_sel_q[2] & ~(|{cpl_group_val[0], cpl_group_val[3]})   & cpl_group_val[1]) |
                          (cpl_group_last_sel_q[3] &    ~cpl_group_val[0]                       & cpl_group_val[1]);

assign cpl_group_sel[2] = (cpl_group_last_sel_q[0] &    ~cpl_group_val[1]                       & cpl_group_val[2]) |
                          (cpl_group_last_sel_q[1] &                                              cpl_group_val[2]) |
                          (cpl_group_last_sel_q[2] & ~(|{cpl_group_val[0:1], cpl_group_val[3]}) & cpl_group_val[2]) |
                          (cpl_group_last_sel_q[3] &  ~(|cpl_group_val[0:1])                    & cpl_group_val[2]);

assign cpl_group_sel[3] = (cpl_group_last_sel_q[0] & ~(|cpl_group_val[1:2]) & cpl_group_val[3]) |
                          (cpl_group_last_sel_q[1] &   ~cpl_group_val[2]    & cpl_group_val[3]) |
                          (cpl_group_last_sel_q[2] &                          cpl_group_val[3]) |
                          (cpl_group_last_sel_q[3] & ~(|cpl_group_val[0:2]) & cpl_group_val[3]);

assign cpl_credit_sent = |(ldqe_cpl_sent);

assign cpl_group_last_sel_d = cpl_credit_sent ? cpl_group_sel : cpl_group_last_sel_q;

// Mux Load Queue Entry between Groups

always @(*) begin: cplGrpLqMux
   reg [0:`ITAG_SIZE_ENC-1]                                iTag;
   reg                                                     ecc;
   reg                                                     eccue;
   reg [0:1]                                               dvc;
   reg [0:3]                                               dacrw;
   reg [0:`THREADS-1]                                      tid;
   reg                                                     nFlush;
   reg                                                     np1Flush;
   reg [0:3]                                               pEvents;
   reg                                                     larx;
   (* analysis_not_referenced="true" *)
   integer                                                 grp;

   iTag     = {`ITAG_SIZE_ENC{1'b0}};
   ecc      = 1'b0;
   eccue    = 1'b0;
   dvc      = {2{1'b0}};
   dacrw    = {4{1'b0}};
   tid      = {`THREADS{1'b0}};
   nFlush   = 1'b0;
   np1Flush = 1'b0;
   pEvents  = {4{1'b0}};
   larx     = 1'b0;
   for (grp=0; grp<4; grp=grp+1) begin : cplGrpLqMux
      if (grp <= (`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4) begin : GrpExst
        iTag     = (cpl_grpEntry_iTag[grp]     & {`ITAG_SIZE_ENC{cpl_group_sel[grp]}}) | iTag;
        ecc      = (cpl_grpEntry_ecc[grp]      &                 cpl_group_sel[grp])   | ecc;
        eccue    = (cpl_grpEntry_eccue[grp]    &                 cpl_group_sel[grp])   | eccue;
        dvc      = (cpl_grpEntry_dvc[grp]      &              {2{cpl_group_sel[grp]}}) | dvc;
        dacrw    = (cpl_grpEntry_dacrw[grp]    &              {4{cpl_group_sel[grp]}}) | dacrw;
        tid      = (cpl_grpEntry_tid[grp]      &       {`THREADS{cpl_group_sel[grp]}}) | tid;
        nFlush   = (cpl_grpEntry_nFlush[grp]   &                 cpl_group_sel[grp])   | nFlush;
        np1Flush = (cpl_grpEntry_np1Flush[grp] &                 cpl_group_sel[grp])   | np1Flush;
        pEvents  = (cpl_grpEntry_pEvents[grp]  &              {4{cpl_group_sel[grp]}}) | pEvents;
        larx     = (cpl_grpEntry_larx[grp]     &                 cpl_group_sel[grp])   | larx;
      end
   end
   cpl_send_itag  <= iTag;
   cpl_ecc_dec    <= ecc;
   cpl_eccue_dec  <= eccue;
   cpl_dvc        <= dvc;
   cpl_dacrw      <= dacrw;
   cpl_tid        <= tid;
   cpl_nFlush     <= nFlush;
   cpl_np1Flush   <= np1Flush;
   cpl_pEvents    <= pEvents;
   cpl_larx       <= larx;
end

// Completion Report has been sent
generate begin : credSent
      genvar                                                  grp;
      for (grp = 0; grp <= (`LMQ_ENTRIES + `LGQ_ENTRIES - 1)/4; grp = grp + 1) begin : credSent
         genvar                                                  ldq;
         for (ldq=0; ldq<=3; ldq=ldq+1) begin : ldqEntry
            assign ldqe_cpl_sel[ldq+(grp*4)] = cpl_grpEntry_sel[grp][ldq] & cpl_group_sel[grp];

            if ((grp*4)+ldq < `LMQ_ENTRIES) begin : ldq_cpl
               assign ldqe_cpl_sent[ldq+(grp*4)] = ldqe_cpl_sel[ldq+(grp*4)] & ~(ldqe_kill[ldq+(grp*4)] | ldq_cpl_odq_val);
            end

            if ((grp*4)+ldq >= `LMQ_ENTRIES) begin : lgq_cpl
               assign ldqe_cpl_sent[ldq+(grp*4)]              = ldqe_cpl_sel[ldq+(grp*4)] & ~(lgqe_kill[ldq+(grp*4)-`LMQ_ENTRIES] | ldq_cpl_odq_val);
               assign lgqe_cpl_sent[ldq+(grp*4)-`LMQ_ENTRIES] = ldqe_cpl_sent[ldq+(grp*4)];
            end
         end
      end
   end
endgenerate

// Completion Report bus for exceptions, loadhits, orderq flush, loadmisses, loadmiss with ecc, and storetypes
// Priority Selection
// 1) ORDERQ has highest priority (loadhits or flushes)
// 2) LDQ has last priority (loadmisses)
assign ldq_cpl_odq_zap        = |(odq_ldq_report_tid & iu_lq_cp_flush_q);
assign ldq_cpl_odq_val        = odq_ldq_resolved & (odq_ldq_n_flush | odq_ldq_report_needed) & (~ldq_cpl_odq_zap);
assign ldq_cpl_odq_dbg_int_en = |(odq_ldq_report_tid & dbg_int_en_q);
assign ldq_cpl_odq_n_flush    = |(odq_ldq_report_dacrw &{4{ldq_cpl_odq_dbg_int_en}}) | odq_ldq_n_flush;
assign ldq_cpl_odq_dacrw      = odq_ldq_report_dacrw &{4{~odq_ldq_n_flush}};
assign ldq_cpl_odq_eccue      = odq_ldq_report_eccue;
assign ldq_cpl_pending        = |(ldqe_cpl_sent);
assign ldq_execute_vld        = cpl_tid            & {`THREADS{ldq_cpl_pending}};
assign odq_execute_vld        = odq_ldq_report_tid & {`THREADS{ldq_cpl_odq_val}};
assign lq1_iu_execute_vld_d   = ldq_execute_vld | odq_execute_vld;

assign lq1_iu_n_flush_d   = (ldq_cpl_odq_val & ldq_cpl_odq_n_flush) |                           // ODQ N flush report
                            (ldq_cpl_pending & ldq_cpl_n_flush);		                           // LDQ N flush report

assign lq1_iu_np1_flush_d = (ldq_cpl_odq_val & odq_ldq_np1_flush) |                             // ODQ NP1 flush report
                            (ldq_cpl_pending & ldq_cpl_np1_flush);		                        // LDQ NP1 flush report

assign lq1_iu_exception_val_d = (ldq_cpl_odq_val & ldq_cpl_odq_eccue) |                         // ODQ MCHK report
                                (ldq_cpl_pending & cpl_eccue_dec);		                        // LDQ MCHK report

assign lq1_iu_itag_d = ldq_cpl_odq_val ? odq_ldq_report_itag : cpl_send_itag;

// Need to report pipelined DVC compare results when completion report is piped reload
assign ldq_cpl_dbg_int_en = |(cpl_tid & dbg_int_en_q);
//                  CritQW got ECC      Back-Invalidate and not CP_NEXT
assign ldq_cpl_oth_flush = cpl_ecc_dec | cpl_nFlush;
//                                      DEBUG INTERRUPT
assign ldq_cpl_n_flush   = |(ldq_cpl_dacrw & {4{ldq_cpl_dbg_int_en}}) | ldq_cpl_oth_flush;
assign ldq_cpl_np1_flush = cpl_np1Flush;

// Select LDQ DVC
assign ldq_cpl_dvc = cpl_dvc;

assign ldq_cpl_dacrw[0:1] = (cpl_dacrw[0:1] | ldq_cpl_dvc) & {2{~(ldq_cpl_oth_flush | ldq_cpl_np1_flush)}};
assign ldq_cpl_dacrw[2:3] =  cpl_dacrw[2:3]                & {2{~(ldq_cpl_oth_flush | ldq_cpl_np1_flush)}};

// DACR report for piped reload
assign lq1_iu_dacrw_d       = ldq_cpl_odq_val ? ldq_cpl_odq_dacrw      : ldq_cpl_dacrw;
assign lq1_iu_perf_events_d = ldq_cpl_odq_val ? odq_ldq_report_pEvents : cpl_pEvents;
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Performance Events
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LARX Finished Performance Event
assign ldq_cpl_larx_d      = ldq_execute_vld & {`THREADS{cpl_larx}};
assign ldq_cpl_binv_d      = ldq_execute_vld & {`THREADS{cpl_nFlush}};
assign ldq_rel_cmmt_d      = |(ldq_rel2_sentL1);
assign ldq_rel_need_hole_d = ldq_l2_resp_hold_all | ldq_rel_arb_hold_all;
assign ldq_rel_latency_d   = ldqe_req_outstanding[0];

assign perf_ldq_cpl_larx      = ldq_cpl_larx_q;
assign perf_ldq_cpl_binv      = ldq_cpl_binv_q;
assign perf_ldq_rel_attmpt    = |ldq_rel1_entrySent_q;
assign perf_ldq_rel_cmmt      = ldq_rel_cmmt_q;
assign perf_ldq_rel_need_hole = ldq_rel_need_hole_q;
assign perf_ldq_rel_latency   = ldq_rel_latency_q;
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Pervasive Error Reporting
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
tri_direct_err_rpt #(.WIDTH(4)) err_rpt(
   .vd(vdd),
   .gd(gnd),
   .err_in({ldq_err_inval_rel_q,
            ldq_err_ecc_det_q,
            ldq_err_ue_det_q,
            ldq_rel3_rdat_par_err}),
   .err_out({lq_pc_err_invld_reld,
             lq_pc_err_l2intrf_ecc,
             lq_pc_err_l2intrf_ue,
             lq_pc_err_relq_parity})
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// OUTPUTS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// RV Control
assign ldq_l2_resp_hold_all      = l2_rel0_resp_ldq_val_q & ldq_l2_rel0_qHitBlk_q;
assign ldq_rel_arb_hold_all      = ldq_rel0_arb_thresh & (~l2_rel0_resp_ldq_val_q);
assign ldq_hold_all_req          = ldq_l2_resp_hold_all | ldq_rel_arb_hold_all | l2_back_inv_val;
assign ldq_rel1_gpr_val          = ldq_rel1_gpr_val_q | lgq_rel1_gpr_val_q;
assign lsq_ctl_ex5_ldq_restart   = ex5_ldq_restart;
assign ldq_rv_set_hold           = ex5_setHold;
assign ldq_rv_clr_hold           = ldq_clrHold_tid;

// RV Release Dependent ITAGs
assign ldq_itag2_rel_val = |(ldqe_relmin1_upd_gpr | lgqe_relmin1_upd_gpr);
assign lq_rv_itag2_vld   = ldq_relmin1_tid & {`THREADS{ldq_itag2_rel_val}};
assign lq_rv_itag2       = ldq_relmin1_iTag;

// Physical Register File update data
assign ldq_rel2_byte_swap = ldq_rel2_byte_swap_q;
assign ldq_rel2_data      = ldq_rel2_rot_data;

// Interface to Completion
assign lq1_iu_execute_vld   = lq1_iu_execute_vld_q;
assign lq1_iu_itag          = lq1_iu_itag_q;
assign lq1_iu_exception_val = lq1_iu_exception_val_q;
assign lq1_iu_exception     = 6'b011010;
assign lq1_iu_n_flush       = lq1_iu_n_flush_q;
assign lq1_iu_np1_flush     = lq1_iu_np1_flush_q;
assign lq1_iu_dacr_type     = 1'b1;
assign lq1_iu_dacrw         = lq1_iu_dacrw_q;
assign lq1_iu_perf_events   = lq1_iu_perf_events_q;

// Performance Events
assign lsq_ctl_ex6_ldq_events = {perf_ex6_ldq_full_restart, perf_ex6_ldq_hit_restart,
                                 perf_ex6_lgq_full_restart, perf_ex6_lgq_qwhit_restart};
assign lsq_perv_ex7_events    = ex7_pfetch_blk_tid;

assign lsq_perv_ldq_events    = {perf_ldq_rel_attmpt,  perf_ldq_rel_cmmt, perf_ldq_rel_need_hole,
                                 perf_ldq_rel_latency, perf_ldq_cpl_larx, perf_ldq_cpl_binv};

// Interface to Store Queue
assign ldq_stq_rel1_blk_store = ldq_stq_rel1_blk_store_q;

// Store Hit LoadMiss Queue Entry
assign ldq_stq_ex5_ldm_hit    = ex5_ldm_hit_q;
assign ldq_stq_ex5_ldm_entry  = ex5_ldm_entry & {`LMQ_ENTRIES{~(ex5_drop_req_val | ex5_ldreq_flushed | ex5_pfetch_flushed)}};
assign ldq_stq_ldm_cpl        = ldqe_req_cmpl_q;
assign ldq_stq_stq4_dir_upd   = ldq_rel4_set_val_q;
assign ldq_stq_stq4_cclass    = ldq_rel4_cclass_q;

// Reload Update L1 Data Cache
assign ldq_dat_stq1_stg_act  = ldq_rel1_val_q;
assign lsq_dat_rel1_data_val = ldq_rel1_data_val;
assign lsq_dat_rel1_qw       = ldq_rel1_resp_qw_q;

// Reload Update L1 Directory
assign ldq_ctl_stq1_stg_act    = ldq_rel1_val_q;
assign lsq_ctl_rel1_clr_val    = ldq_rel1_clr_val;
assign lsq_ctl_rel1_set_val    = ldq_rel1_set_val;
assign lsq_ctl_rel2_upd_val    = ldq_rel2_set_val_q & ~(rel2_eccdet_err | ldq_rel2_rdat_perr);
assign lsq_ctl_rel1_data_val   = ldq_rel1_data_val;
assign lsq_ctl_rel1_thrd_id    = ldq_rel1_dir_tid_q;
assign lsq_ctl_rel1_back_inv   = ldq_rel1_mux_back_inv;
assign lsq_ctl_rel1_tag        = ldq_rel1_cTag_q;
assign lsq_ctl_rel1_classid    = ldq_rel1_classID_q;
assign lsq_ctl_rel1_lock_set   = ldq_rel1_lockSet_q;
assign lsq_ctl_rel1_watch_set  = ldq_rel1_watchSet_q;
assign lsq_ctl_rel3_l1dump_val = ldq_rel3_l1_dump_val;
assign lsq_ctl_rel3_clr_relq   = ldq_rel3_clr_relq_q;

// Common between Reload and COMMIT Pipe
assign ldq_arb_rel1_data_sel  = ldq_rel1_data_sel_q | ldq_rel1_gpr_val;
assign ldq_arb_rel1_axu_val   = ldq_rel1_axu_q;
assign ldq_arb_rel1_op_size   = ldq_rel1_opsize_q;
assign ldq_arb_rel1_addr      = ldq_rel1_p_addr_q;
assign ldq_arb_rel1_ci        = ldq_rel1_wimge_i_q;
assign ldq_arb_rel1_byte_swap = ldq_rel1_byte_swap_q;
assign ldq_arb_rel1_thrd_id   = ldq_rel1_tid_q;
assign ldq_arb_rel1_data      = ldq_rel1_data;

// Reload Update Physical Register
assign lsq_ctl_rel1_gpr_val = ldq_rel1_gpr_val;
assign lsq_ctl_rel1_ta_gpr  = ldq_rel1_tGpr_q;
assign lsq_ctl_rel1_upd_gpr = |(ldq_rel1_upd_gpr) | |(lgq_rel1_upd_gpr);

// Need to block Reloads and Reissue Stores if Load Queue has issued instructions
assign lsq_ctl_rel2_blk_req = rel2_blk_req_q;

// L2 request Available
assign ldq_arb_ld_req_pwrToken = ((ex5_ldreq_val_q | ex5_pfetch_val_q) & (~ldq_l2_req_need_send)) | fifo_ldq_req_val_q[0];
assign ldq_arb_ld_req_avail = (ex5_ldreq_val & (~(ex5_drop_req_val | ldq_l2_req_need_send))) |
                              fifo_ldq_req0_avail;
assign ldq_odq_vld          = ((ex5_odq_ldreq_val_q & (~ex5_restart_val)) | ex5_streq_val_q | (ex5_othreq_val_q & (~ex5_restart_val))) & (~ex5_stg_flush);
assign ldq_odq_pfetch_vld   = ex5_pfetch_val;
assign ldq_odq_wimge_i      = ex5_wimge_q[1];
assign ldq_odq_ex6_pEvents  = ex6_cmmt_perf_events_q;

// All reloads for each Load Queue Entries have completed
assign lq_xu_quiesce        = lq_xu_quiesce_q;
assign lq_mm_lmq_stq_empty  = lq_mm_lmq_stq_empty_q;
assign lq_pc_ldq_quiesce    = lq_pc_ldq_quiesce_q;
assign lq_pc_stq_quiesce    = lq_pc_stq_quiesce_q;
assign lq_pc_pfetch_quiesce = lq_pc_pfetch_quiesce_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// REGISTERS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_cls_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_xucr0_cls_offset]),
   .scout(sov[spr_xucr0_cls_offset]),
   .din(spr_xucr0_cls_d),
   .dout(spr_xucr0_cls_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_lsucr0_lge_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_lsucr0_lge_offset]),
   .scout(sov[spr_lsucr0_lge_offset]),
   .din(spr_lsucr0_lge_d),
   .dout(spr_lsucr0_lge_q)
);


tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) spr_lsucr0_lca_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[spr_lsucr0_lca_offset:spr_lsucr0_lca_offset + 3 - 1]),
   .scout(sov[spr_lsucr0_lca_offset:spr_lsucr0_lca_offset + 3 - 1]),
   .din(spr_lsucr0_lca_d),
   .dout(spr_lsucr0_lca_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_val_offset]),
   .scout(sov[l2_rel0_resp_val_offset]),
   .din(l2_rel0_resp_val_d),
   .dout(l2_rel0_resp_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_ldq_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_ldq_val_offset]),
   .scout(sov[l2_rel0_resp_ldq_val_offset]),
   .din(l2_rel0_resp_ldq_val_d),
   .dout(l2_rel0_resp_ldq_val_q)
);


tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_cTag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_cTag_offset:l2_rel0_resp_cTag_offset + 4 - 1]),
   .scout(sov[l2_rel0_resp_cTag_offset:l2_rel0_resp_cTag_offset + 4 - 1]),
   .din(l2_rel0_resp_cTag_d),
   .dout(l2_rel0_resp_cTag_q)
);


tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_qw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_qw_offset:l2_rel0_resp_qw_offset + 3 - 1]),
   .scout(sov[l2_rel0_resp_qw_offset:l2_rel0_resp_qw_offset + 3 - 1]),
   .din(l2_rel0_resp_qw_d),
   .dout(l2_rel0_resp_qw_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_crit_qw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_crit_qw_offset]),
   .scout(sov[l2_rel0_resp_crit_qw_offset]),
   .din(l2_rel0_resp_crit_qw_d),
   .dout(l2_rel0_resp_crit_qw_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel0_resp_l1_dump_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel0_resp_l1_dump_offset]),
   .scout(sov[l2_rel0_resp_l1_dump_offset]),
   .din(l2_rel0_resp_l1_dump_d),
   .dout(l2_rel0_resp_l1_dump_q)
);


tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_algebraic_sel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_algebraic_sel_offset:ldq_rel1_algebraic_sel_offset + 4 - 1]),
   .scout(sov[ldq_rel1_algebraic_sel_offset:ldq_rel1_algebraic_sel_offset + 4 - 1]),
   .din(ldq_rel1_algebraic_sel_d),
   .dout(ldq_rel1_algebraic_sel_q)
);


tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_rot_sel1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_rot_sel1_offset:ldq_rel1_rot_sel1_offset + 8 - 1]),
   .scout(sov[ldq_rel1_rot_sel1_offset:ldq_rel1_rot_sel1_offset + 8 - 1]),
   .din(ldq_rel1_rot_sel1_d),
   .dout(ldq_rel1_rot_sel1_q)
);


tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_rot_sel2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_rot_sel2_offset:ldq_rel1_rot_sel2_offset + 8 - 1]),
   .scout(sov[ldq_rel1_rot_sel2_offset:ldq_rel1_rot_sel2_offset + 8 - 1]),
   .din(ldq_rel1_rot_sel2_d),
   .dout(ldq_rel1_rot_sel2_q)
);


tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_rot_sel3_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_rot_sel3_offset:ldq_rel1_rot_sel3_offset + 8 - 1]),
   .scout(sov[ldq_rel1_rot_sel3_offset:ldq_rel1_rot_sel3_offset + 8 - 1]),
   .din(ldq_rel1_rot_sel3_d),
   .dout(ldq_rel1_rot_sel3_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_lq_cp_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[iu_lq_cp_flush_offset:iu_lq_cp_flush_offset + `THREADS - 1]),
   .scout(sov[iu_lq_cp_flush_offset:iu_lq_cp_flush_offset + `THREADS - 1]),
   .din(iu_lq_cp_flush_d),
   .dout(iu_lq_cp_flush_q)
);

generate begin : iu_lq_cp_next_itag_tid
      genvar                                                  tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : iu_lq_cp_next_itag_tid
         tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) iu_lq_cp_next_itag_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[iu_lq_cp_next_itag_offset + `ITAG_SIZE_ENC * tid:iu_lq_cp_next_itag_offset + `ITAG_SIZE_ENC * (tid + 1) - 1]),
            .scout(sov[iu_lq_cp_next_itag_offset + `ITAG_SIZE_ENC * tid:iu_lq_cp_next_itag_offset + `ITAG_SIZE_ENC * (tid + 1) - 1]),
            .din(iu_lq_cp_next_itag[`ITAG_SIZE_ENC*tid:`ITAG_SIZE_ENC*(tid+1)-1]),
            .dout(iu_lq_cp_next_itag_q[tid])
         );
      end
   end
endgenerate


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) odq_ldq_n_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[odq_ldq_n_flush_offset]),
   .scout(sov[odq_ldq_n_flush_offset]),
   .din(odq_ldq_n_flush_d),
   .dout(odq_ldq_n_flush_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) odq_ldq_resolved_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[odq_ldq_resolved_offset]),
   .scout(sov[odq_ldq_resolved_offset]),
   .din(odq_ldq_resolved_d),
   .dout(odq_ldq_resolved_q)
);


tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) odq_ldq_report_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[odq_ldq_report_itag_offset:odq_ldq_report_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[odq_ldq_report_itag_offset:odq_ldq_report_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(odq_ldq_report_itag_d),
   .dout(odq_ldq_report_itag_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) odq_ldq_report_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[odq_ldq_report_tid_offset:odq_ldq_report_tid_offset + `THREADS - 1]),
   .scout(sov[odq_ldq_report_tid_offset:odq_ldq_report_tid_offset + `THREADS - 1]),
   .din(odq_ldq_report_tid_d),
   .dout(odq_ldq_report_tid_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) rv_lq_rvs_empty_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv_lq_rvs_empty_offset:rv_lq_rvs_empty_offset + `THREADS - 1]),
   .scout(sov[rv_lq_rvs_empty_offset:rv_lq_rvs_empty_offset + `THREADS - 1]),
   .din(rv_lq_rvs_empty_d),
   .dout(rv_lq_rvs_empty_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_blk_req_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_blk_req_offset]),
   .scout(sov[rel2_blk_req_offset]),
   .din(rel2_blk_req_d),
   .dout(rel2_blk_req_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_rviss_blk_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_rviss_blk_offset]),
   .scout(sov[rel2_rviss_blk_offset]),
   .din(rel2_rviss_blk_d),
   .dout(rel2_rviss_blk_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_collide_binv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_collide_binv_offset]),
   .scout(sov[ldq_rel1_collide_binv_offset]),
   .din(ldq_rel1_collide_binv_d),
   .dout(ldq_rel1_collide_binv_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_stq_rel1_blk_store_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_stq_rel1_blk_store_offset]),
   .scout(sov[ldq_stq_rel1_blk_store_offset]),
   .din(ldq_stq_rel1_blk_store_d),
   .dout(ldq_stq_rel1_blk_store_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ldreq_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_ldreq_offset]),
   .scout(sov[ex4_ldreq_offset]),
   .din(ex4_ldreq_d),
   .dout(ex4_ldreq_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldreq_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldreq_val_offset]),
   .scout(sov[ex5_ldreq_val_offset]),
   .din(ex5_ldreq_val_d),
   .dout(ex5_ldreq_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_pfetch_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_pfetch_val_offset]),
   .scout(sov[ex4_pfetch_val_offset]),
   .din(ex4_pfetch_val_d),
   .dout(ex4_pfetch_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_pfetch_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_pfetch_val_offset]),
   .scout(sov[ex5_pfetch_val_offset]),
   .din(ex5_pfetch_val_d),
   .dout(ex5_pfetch_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_odq_ldreq_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_odq_ldreq_val_offset]),
   .scout(sov[ex5_odq_ldreq_val_offset]),
   .din(ex5_odq_ldreq_val_d),
   .dout(ex5_odq_ldreq_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_streq_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_streq_val_offset]),
   .scout(sov[ex5_streq_val_offset]),
   .din(ex5_streq_val_d),
   .dout(ex5_streq_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_othreq_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_othreq_val_offset]),
   .scout(sov[ex5_othreq_val_offset]),
   .din(ex5_othreq_val_d),
   .dout(ex5_othreq_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_reserved_taken_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_reserved_taken_offset]),
   .scout(sov[ex5_reserved_taken_offset]),
   .din(ex5_reserved_taken_d),
   .dout(ex5_reserved_taken_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_resv_taken_restart_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_resv_taken_restart_offset]),
   .scout(sov[ex5_resv_taken_restart_offset]),
   .din(ex5_resv_taken_restart_d),
   .dout(ex5_resv_taken_restart_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq_xu_quiesce_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_xu_quiesce_offset:lq_xu_quiesce_offset + `THREADS - 1]),
   .scout(sov[lq_xu_quiesce_offset:lq_xu_quiesce_offset + `THREADS - 1]),
   .din(lq_xu_quiesce_d),
   .dout(lq_xu_quiesce_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq_pc_ldq_quiesce_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_pc_ldq_quiesce_offset:lq_pc_ldq_quiesce_offset + `THREADS - 1]),
   .scout(sov[lq_pc_ldq_quiesce_offset:lq_pc_ldq_quiesce_offset + `THREADS - 1]),
   .din(lq_pc_ldq_quiesce_d),
   .dout(lq_pc_ldq_quiesce_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq_pc_stq_quiesce_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_pc_stq_quiesce_offset:lq_pc_stq_quiesce_offset + `THREADS - 1]),
   .scout(sov[lq_pc_stq_quiesce_offset:lq_pc_stq_quiesce_offset + `THREADS - 1]),
   .din(lq_pc_stq_quiesce_d),
   .dout(lq_pc_stq_quiesce_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq_pc_pfetch_quiesce_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_pc_pfetch_quiesce_offset:lq_pc_pfetch_quiesce_offset + `THREADS - 1]),
   .scout(sov[lq_pc_pfetch_quiesce_offset:lq_pc_pfetch_quiesce_offset + `THREADS - 1]),
   .din(lq_pc_pfetch_quiesce_d),
   .dout(lq_pc_pfetch_quiesce_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_mm_lmq_stq_empty_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq_mm_lmq_stq_empty_offset]),
   .scout(sov[lq_mm_lmq_stq_empty_offset]),
   .din(lq_mm_lmq_stq_empty_d),
   .dout(lq_mm_lmq_stq_empty_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldq_full_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldq_full_offset]),
   .scout(sov[ex5_ldq_full_offset]),
   .din(ex5_ldq_full_d),
   .dout(ex5_ldq_full_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldq_full_restart_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldq_full_restart_offset]),
   .scout(sov[ex5_ldq_full_restart_offset]),
   .din(ex5_ldq_full_restart_d),
   .dout(ex5_ldq_full_restart_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldq_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldq_hit_offset]),
   .scout(sov[ex5_ldq_hit_offset]),
   .din(ex5_ldq_hit_d),
   .dout(ex5_ldq_hit_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ld_gath_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ld_gath_offset]),
   .scout(sov[ex5_ld_gath_offset]),
   .din(ex5_ld_gath_d),
   .dout(ex5_ld_gath_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_full_qHit_held_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_full_qHit_held_offset]),
   .scout(sov[ldq_full_qHit_held_offset]),
   .din(ldq_full_qHit_held_d),
   .dout(ldq_full_qHit_held_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_resv_qHit_held_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_resv_qHit_held_offset]),
   .scout(sov[ldq_resv_qHit_held_offset]),
   .din(ldq_resv_qHit_held_d),
   .dout(ldq_resv_qHit_held_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_oth_qHit_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_oth_qHit_clr_offset]),
   .scout(sov[ldq_oth_qHit_clr_offset]),
   .din(ldq_oth_qHit_clr_d),
   .dout(ldq_oth_qHit_clr_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldq_set_hold_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldq_set_hold_offset]),
   .scout(sov[ex5_ldq_set_hold_offset]),
   .din(ex5_ldq_set_hold_d),
   .dout(ex5_ldq_set_hold_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_ldq_restart_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldq_restart_offset]),
   .scout(sov[ex5_ldq_restart_offset]),
   .din(ex5_ldq_restart_d),
   .dout(ex5_ldq_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ldq_full_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_ldq_full_offset]),
   .scout(sov[ex6_ldq_full_offset]),
   .din(ex6_ldq_full_d),
   .dout(ex6_ldq_full_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_ldq_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_ldq_hit_offset]),
   .scout(sov[ex6_ldq_hit_offset]),
   .din(ex6_ldq_hit_d),
   .dout(ex6_ldq_hit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_lgq_full_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lgq_full_offset]),
   .scout(sov[ex5_lgq_full_offset]),
   .din(ex5_lgq_full_d),
   .dout(ex5_lgq_full_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lgq_full_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_lgq_full_offset]),
   .scout(sov[ex6_lgq_full_offset]),
   .din(ex6_lgq_full_d),
   .dout(ex6_lgq_full_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_lgq_qwhit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lgq_qwhit_offset]),
   .scout(sov[ex5_lgq_qwhit_offset]),
   .din(ex5_lgq_qwhit_d),
   .dout(ex5_lgq_qwhit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lgq_qwhit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_lgq_qwhit_offset]),
   .scout(sov[ex6_lgq_qwhit_offset]),
   .din(ex6_lgq_qwhit_d),
   .dout(ex6_lgq_qwhit_q)
);

tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ex5_p_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_p_addr_offset:ex5_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
   .scout(sov[ex5_p_addr_offset:ex5_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
   .din(ex5_p_addr_d),
   .dout(ex5_p_addr_q)
);


tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ex5_wimge_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wimge_offset:ex5_wimge_offset + 5 - 1]),
   .scout(sov[ex5_wimge_offset:ex5_wimge_offset + 5 - 1]),
   .din(ex5_wimge_d),
   .dout(ex5_wimge_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex6_cmmt_perf_events_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_cmmt_perf_events_offset:ex6_cmmt_perf_events_offset + 4 - 1]),
   .scout(sov[ex6_cmmt_perf_events_offset:ex6_cmmt_perf_events_offset + 4 - 1]),
   .din(ex6_cmmt_perf_events_d),
   .dout(ex6_cmmt_perf_events_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_ldqe_set_all_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldqe_set_all_offset:ex5_ldqe_set_all_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ex5_ldqe_set_all_offset:ex5_ldqe_set_all_offset + `LMQ_ENTRIES - 1]),
   .din(ex5_ldqe_set_all_d),
   .dout(ex5_ldqe_set_all_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_ldqe_set_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldqe_set_val_offset:ex5_ldqe_set_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ex5_ldqe_set_val_offset:ex5_ldqe_set_val_offset + `LMQ_ENTRIES - 1]),
   .din(ex5_ldqe_set_val_d),
   .dout(ex5_ldqe_set_val_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex6_ldqe_pfetch_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex6_ldqe_pfetch_val_offset:ex6_ldqe_pfetch_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ex6_ldqe_pfetch_val_offset:ex6_ldqe_pfetch_val_offset + `LMQ_ENTRIES - 1]),
   .din(ex6_ldqe_pfetch_val_d),
   .dout(ex6_ldqe_pfetch_val_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex7_ldqe_pfetch_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex7_ldqe_pfetch_val_offset:ex7_ldqe_pfetch_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ex7_ldqe_pfetch_val_offset:ex7_ldqe_pfetch_val_offset + `LMQ_ENTRIES - 1]),
   .din(ex7_ldqe_pfetch_val_d),
   .dout(ex7_ldqe_pfetch_val_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_ldm_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldm_hit_offset:ex5_ldm_hit_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ex5_ldm_hit_offset:ex5_ldm_hit_offset + `LMQ_ENTRIES - 1]),
   .din(ex5_ldm_hit_d),
   .dout(ex5_ldm_hit_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_hold_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_hold_tid_offset:ldq_hold_tid_offset + `THREADS - 1]),
   .scout(sov[ldq_hold_tid_offset:ldq_hold_tid_offset + `THREADS - 1]),
   .din(ldq_hold_tid_d),
   .dout(ldq_hold_tid_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES + 1), .INIT(2 ** (`LMQ_ENTRIES)), .NEEDS_SRESET(1)) fifo_ldq_req_nxt_ptr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[fifo_ldq_req_nxt_ptr_offset:fifo_ldq_req_nxt_ptr_offset + (`LMQ_ENTRIES+1) - 1]),
   .scout(sov[fifo_ldq_req_nxt_ptr_offset:fifo_ldq_req_nxt_ptr_offset + (`LMQ_ENTRIES+1) - 1]),
   .din(fifo_ldq_req_nxt_ptr_d),
   .dout(fifo_ldq_req_nxt_ptr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) fifo_ldq_req_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[fifo_ldq_req_val_offset:fifo_ldq_req_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[fifo_ldq_req_val_offset:fifo_ldq_req_val_offset + `LMQ_ENTRIES - 1]),
   .din(fifo_ldq_req_val_d),
   .dout(fifo_ldq_req_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) fifo_ldq_req_pfetch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[fifo_ldq_req_pfetch_offset:fifo_ldq_req_pfetch_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[fifo_ldq_req_pfetch_offset:fifo_ldq_req_pfetch_offset + `LMQ_ENTRIES - 1]),
   .din(fifo_ldq_req_pfetch_d),
   .dout(fifo_ldq_req_pfetch_q)
);

generate begin : fifo_ldq_req_tid
      genvar                                                  ldq;
      for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : fifo_ldq_req_tid
         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) fifo_ldq_req_tid_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(fifo_ldq_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[fifo_ldq_req_tid_offset + (`THREADS * ldq):fifo_ldq_req_tid_offset + (`THREADS * (ldq + 1)) - 1]),
            .scout(sov[fifo_ldq_req_tid_offset + (`THREADS * ldq):fifo_ldq_req_tid_offset + (`THREADS * (ldq + 1)) - 1]),
            .din(fifo_ldq_req_tid_d[ldq]),
            .dout(fifo_ldq_req_tid_q[ldq])
         );
      end
   end
endgenerate

generate begin : fifo_ldq_req
      genvar                                                  ldq0;
      for (ldq0=0; ldq0<`LMQ_ENTRIES; ldq0=ldq0+1) begin : fifo_ldq_req
         tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) fifo_ldq_req_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(fifo_ldq_act),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[fifo_ldq_req_offset + (`LMQ_ENTRIES * ldq0):fifo_ldq_req_offset + (`LMQ_ENTRIES * (ldq0 + 1)) - 1]),
            .scout(sov[fifo_ldq_req_offset + (`LMQ_ENTRIES * ldq0):fifo_ldq_req_offset + (`LMQ_ENTRIES * (ldq0 + 1)) - 1]),
            .din(fifo_ldq_req_d[ldq0]),
            .dout(fifo_ldq_req_q[ldq0])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_val_offset:ldqe_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_val_offset:ldqe_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_val_d),
   .dout(ldqe_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_req_cmpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_req_cmpl_offset:ldqe_req_cmpl_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_req_cmpl_offset:ldqe_req_cmpl_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_req_cmpl_d),
   .dout(ldqe_req_cmpl_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_cntr_reset_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_cntr_reset_offset:ldqe_cntr_reset_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_cntr_reset_offset:ldqe_cntr_reset_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_cntr_reset_d),
   .dout(ldqe_cntr_reset_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_resent_ecc_err_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_resent_ecc_err_offset:ldqe_resent_ecc_err_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_resent_ecc_err_offset:ldqe_resent_ecc_err_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_resent_ecc_err_d),
   .dout(ldqe_resent_ecc_err_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_reset_cpl_rpt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_reset_cpl_rpt_offset:ldqe_reset_cpl_rpt_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_reset_cpl_rpt_offset:ldqe_reset_cpl_rpt_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_reset_cpl_rpt_d),
   .dout(ldqe_reset_cpl_rpt_q)
);

generate begin : ldqe_iTag
      genvar                                                  ldq1;
      for (ldq1=0; ldq1<`LMQ_ENTRIES; ldq1=ldq1+1) begin : ldqe_iTag
         tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ldqe_iTag_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_ldqe_act[ldq1]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_itag_offset + (`ITAG_SIZE_ENC * ldq1):ldqe_itag_offset + (`ITAG_SIZE_ENC * (ldq1 + 1)) - 1]),
            .scout(sov[ldqe_itag_offset + (`ITAG_SIZE_ENC * ldq1):ldqe_itag_offset + (`ITAG_SIZE_ENC * (ldq1 + 1)) - 1]),
            .din(ldqe_itag_d[ldq1]),
            .dout(ldqe_itag_q[ldq1])
         );
      end
   end
endgenerate

generate begin : ldqe_thrd_id
      genvar                                                  ldq2;
      for (ldq2=0; ldq2<`LMQ_ENTRIES; ldq2=ldq2+1) begin : ldqe_thrd_id
         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldqe_thrd_id_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_ldqe_act[ldq2]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_thrd_id_offset + (`THREADS * ldq2):ldqe_thrd_id_offset + (`THREADS * (ldq2 + 1)) - 1]),
            .scout(sov[ldqe_thrd_id_offset + (`THREADS * ldq2):ldqe_thrd_id_offset + (`THREADS * (ldq2 + 1)) - 1]),
            .din(ldqe_thrd_id_d[ldq2]),
            .dout(ldqe_thrd_id_q[ldq2])
         );
      end
   end
endgenerate

generate begin : ldqe_wimge
      genvar                                                  ldq3;
      for (ldq3=0; ldq3<`LMQ_ENTRIES; ldq3=ldq3+1) begin : ldqe_wimge
         tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) ldqe_wimge_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_ldqe_act[ldq3]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_wimge_offset + (5 * ldq3):ldqe_wimge_offset + (5 * (ldq3 + 1)) - 1]),
            .scout(sov[ldqe_wimge_offset + (5 * ldq3):ldqe_wimge_offset + (5 * (ldq3 + 1)) - 1]),
            .din(ldqe_wimge_d[ldq3]),
            .dout(ldqe_wimge_q[ldq3])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_byte_swap_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_byte_swap_offset:ldqe_byte_swap_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_byte_swap_offset:ldqe_byte_swap_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_byte_swap_d),
   .dout(ldqe_byte_swap_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_resv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_resv_offset:ldqe_resv_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_resv_offset:ldqe_resv_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_resv_d),
   .dout(ldqe_resv_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_pfetch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_pfetch_offset:ldqe_pfetch_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_pfetch_offset:ldqe_pfetch_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_pfetch_d),
   .dout(ldqe_pfetch_q)
);

generate begin : ldqe_op_size
      genvar                                                  ldq4;
      for (ldq4=0; ldq4<`LMQ_ENTRIES; ldq4=ldq4+1) begin : ldqe_op_size
         tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ldqe_op_size_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq4]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_op_size_offset + (3 * ldq4):ldqe_op_size_offset + (3 * (ldq4 + 1)) - 1]),
            .scout(sov[ldqe_op_size_offset + (3 * ldq4):ldqe_op_size_offset + (3 * (ldq4 + 1)) - 1]),
            .din(ldqe_op_size_d[ldq4]),
            .dout(ldqe_op_size_q[ldq4])
         );
      end
   end
endgenerate

generate begin : ldqe_tgpr
      genvar                                                  ldq5;
      for (ldq5=0; ldq5<`LMQ_ENTRIES; ldq5=ldq5+1) begin : ldqe_tgpr
         tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ldqe_tgpr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq5]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_tgpr_offset + (AXU_TARGET_ENC * ldq5):ldqe_tgpr_offset + (AXU_TARGET_ENC * (ldq5 + 1)) - 1]),
            .scout(sov[ldqe_tgpr_offset + (AXU_TARGET_ENC * ldq5):ldqe_tgpr_offset + (AXU_TARGET_ENC * (ldq5 + 1)) - 1]),
            .din(ldqe_tgpr_d[ldq5]),
            .dout(ldqe_tgpr_q[ldq5])
         );
      end
   end
endgenerate

generate begin : ldqe_usr_def
      genvar                                                  ldq6;
      for (ldq6=0; ldq6<`LMQ_ENTRIES; ldq6=ldq6+1) begin : ldqe_usr_def
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldqe_usr_def_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq6]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_usr_def_offset + (4 * ldq6):ldqe_usr_def_offset + (4 * (ldq6 + 1)) - 1]),
            .scout(sov[ldqe_usr_def_offset + (4 * ldq6):ldqe_usr_def_offset + (4 * (ldq6 + 1)) - 1]),
            .din(ldqe_usr_def_d[ldq6]),
            .dout(ldqe_usr_def_q[ldq6])
         );
      end
   end
endgenerate

generate begin : ldqe_class_id
      genvar                                                  ldq7;
      for (ldq7=0; ldq7<`LMQ_ENTRIES; ldq7=ldq7+1) begin : ldqe_class_id
         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ldqe_class_id_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq7]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_class_id_offset + (2 * ldq7):ldqe_class_id_offset + (2 * (ldq7 + 1)) - 1]),
            .scout(sov[ldqe_class_id_offset + (2 * ldq7):ldqe_class_id_offset + (2 * (ldq7 + 1)) - 1]),
            .din(ldqe_class_id_d[ldq7]),
            .dout(ldqe_class_id_q[ldq7])
         );
      end
   end
endgenerate

generate begin : ldqe_perf_events
      genvar                                                  ldq7;
      for (ldq7=0; ldq7<`LMQ_ENTRIES; ldq7=ldq7+1) begin : ldqe_perf_events
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldqe_perf_events_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq7]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_perf_events_offset + (4 * ldq7):ldqe_perf_events_offset + (4 * (ldq7 + 1)) - 1]),
            .scout(sov[ldqe_perf_events_offset + (4 * ldq7):ldqe_perf_events_offset + (4 * (ldq7 + 1)) - 1]),
            .din(ldqe_perf_events_d[ldq7]),
            .dout(ldqe_perf_events_q[ldq7])
         );
      end
   end
endgenerate

generate begin : ldqe_dvc
      genvar                                                  ldq8;
      for (ldq8=0; ldq8<`LMQ_ENTRIES; ldq8=ldq8+1) begin : ldqe_dvc
         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ldqe_dvc_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ldqe_ctrl_act[ldq8]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_dvc_offset + (2 * ldq8):ldqe_dvc_offset + (2 * (ldq8 + 1)) - 1]),
            .scout(sov[ldqe_dvc_offset + (2 * ldq8):ldqe_dvc_offset + (2 * (ldq8 + 1)) - 1]),
            .din(ldqe_dvc_d[ldq8]),
            .dout(ldqe_dvc_q[ldq8])
         );
      end
   end
endgenerate

generate begin : ldqe_ttype
      genvar                                                  ldq9;
      for (ldq9=0; ldq9<`LMQ_ENTRIES; ldq9=ldq9+1) begin : ldqe_ttype
         tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ldqe_ttype_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq9]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_ttype_offset + (6 * ldq9):ldqe_ttype_offset + (6 * (ldq9 + 1)) - 1]),
            .scout(sov[ldqe_ttype_offset + (6 * ldq9):ldqe_ttype_offset + (6 * (ldq9 + 1)) - 1]),
            .din(ldqe_ttype_d[ldq9]),
            .dout(ldqe_ttype_q[ldq9])
         );
      end
   end
endgenerate

generate begin : ldqe_dacrw
      genvar                                                  ldq10;
      for (ldq10=0; ldq10<`LMQ_ENTRIES; ldq10=ldq10+1) begin : ldqe_dacrw
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldqe_dacrw_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_ldqe_act[ldq10]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_dacrw_offset + (4 * ldq10):ldqe_dacrw_offset + (4 * (ldq10 + 1)) - 1]),
            .scout(sov[ldqe_dacrw_offset + (4 * ldq10):ldqe_dacrw_offset + (4 * (ldq10 + 1)) - 1]),
            .din(ldqe_dacrw_d[ldq10]),
            .dout(ldqe_dacrw_q[ldq10])
         );
      end
   end
endgenerate

generate begin : ldqe_p_addr
      genvar                                                  ldq11;
      for (ldq11=0; ldq11<`LMQ_ENTRIES; ldq11=ldq11+1) begin : ldqe_p_addr
         tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ldqe_p_addr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_ldqe_act[ldq11]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_p_addr_offset + (`REAL_IFAR_WIDTH * ldq11):ldqe_p_addr_offset + (`REAL_IFAR_WIDTH * (ldq11 + 1)) - 1]),
            .scout(sov[ldqe_p_addr_offset + (`REAL_IFAR_WIDTH * ldq11):ldqe_p_addr_offset + (`REAL_IFAR_WIDTH * (ldq11 + 1)) - 1]),
            .din(ldqe_p_addr_d[ldq11]),
            .dout(ldqe_p_addr_q[ldq11])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_mkill_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_mkill_offset:ldqe_mkill_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_mkill_offset:ldqe_mkill_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_mkill_d),
   .dout(ldqe_mkill_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_resolved_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_resolved_offset:ldqe_resolved_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_resolved_offset:ldqe_resolved_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_resolved_d),
   .dout(ldqe_resolved_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_back_inv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_back_inv_offset:ldqe_back_inv_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_back_inv_offset:ldqe_back_inv_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_back_inv_d),
   .dout(ldqe_back_inv_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_back_inv_nFlush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_back_inv_nFlush_offset:ldqe_back_inv_nFlush_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_back_inv_nFlush_offset:ldqe_back_inv_nFlush_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_back_inv_nFlush_d),
   .dout(ldqe_back_inv_nFlush_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_back_inv_np1Flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_back_inv_np1Flush_offset:ldqe_back_inv_np1Flush_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_back_inv_np1Flush_offset:ldqe_back_inv_np1Flush_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_back_inv_np1Flush_d),
   .dout(ldqe_back_inv_np1Flush_q)
);

generate begin : ldqe_beat_cntr
      genvar                                                  ldq12;
      for (ldq12=0; ldq12<`LMQ_ENTRIES; ldq12=ldq12+1) begin : ldqe_beat_cntr
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldqe_beat_cntr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ldqe_ctrl_act[ldq12]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_beat_cntr_offset + (4 * ldq12):ldqe_beat_cntr_offset + (4 * (ldq12 + 1)) - 1]),
            .scout(sov[ldqe_beat_cntr_offset + (4 * ldq12):ldqe_beat_cntr_offset + (4 * (ldq12 + 1)) - 1]),
            .din(ldqe_beat_cntr_d[ldq12]),
            .dout(ldqe_beat_cntr_q[ldq12])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_dRel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_dRel_offset:ldqe_dRel_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_dRel_offset:ldqe_dRel_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_dRel_d),
   .dout(ldqe_dRel_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_l1_dump_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_l1_dump_offset:ldqe_l1_dump_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_l1_dump_offset:ldqe_l1_dump_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_l1_dump_d),
   .dout(ldqe_l1_dump_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_dGpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_dGpr_offset:ldqe_dGpr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_dGpr_offset:ldqe_dGpr_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_dGpr_d),
   .dout(ldqe_dGpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_axu_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_axu_offset:ldqe_axu_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_axu_offset:ldqe_axu_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_axu_d),
   .dout(ldqe_axu_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_lock_set_offset:ldqe_lock_set_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_lock_set_offset:ldqe_lock_set_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_lock_set_d),
   .dout(ldqe_lock_set_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_watch_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_watch_set_offset:ldqe_watch_set_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_watch_set_offset:ldqe_watch_set_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_watch_set_d),
   .dout(ldqe_watch_set_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_algebraic_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_algebraic_offset:ldqe_algebraic_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_algebraic_offset:ldqe_algebraic_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_algebraic_d),
   .dout(ldqe_algebraic_q)
);

generate begin : ldqe_state
      genvar                                                  ldq13;
      for (ldq13=0; ldq13<`LMQ_ENTRIES; ldq13=ldq13+1) begin : ldqe_state
         tri_rlmreg_p #(.WIDTH(7), .INIT(64), .NEEDS_SRESET(1)) ldqe_state_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_state_offset + (7 * ldq13):ldqe_state_offset + (7 * (ldq13 + 1)) - 1]),
            .scout(sov[ldqe_state_offset + (7 * ldq13):ldqe_state_offset + (7 * (ldq13 + 1)) - 1]),
            .din(ldqe_state_d[ldq13]),
            .dout(ldqe_state_q[ldq13])
         );
      end
   end
endgenerate

generate begin : ldqe_sentRel_cntr
      genvar                                                  ldq;
      for (ldq=0; ldq<`LMQ_ENTRIES; ldq=ldq+1) begin : ldqe_sentRel_cntr
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldqe_sentRel_cntr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ldqe_ctrl_act[ldq]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[ldqe_sentRel_cntr_offset + (4 * ldq):ldqe_sentRel_cntr_offset + (4 * (ldq + 1)) - 1]),
            .scout(sov[ldqe_sentRel_cntr_offset + (4 * ldq):ldqe_sentRel_cntr_offset + (4 * (ldq + 1)) - 1]),
            .din(ldqe_sentRel_cntr_d[ldq]),
            .dout(ldqe_sentRel_cntr_q[ldq])
         );
      end
   end
endgenerate

tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_lgqe_set_all_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lgqe_set_all_offset:ex5_lgqe_set_all_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[ex5_lgqe_set_all_offset:ex5_lgqe_set_all_offset + `LGQ_ENTRIES - 1]),
   .din(ex5_lgqe_set_all_d),
   .dout(ex5_lgqe_set_all_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ex5_lgqe_set_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lgqe_set_val_offset:ex5_lgqe_set_val_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[ex5_lgqe_set_val_offset:ex5_lgqe_set_val_offset + `LGQ_ENTRIES - 1]),
   .din(ex5_lgqe_set_val_d),
   .dout(ex5_lgqe_set_val_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_valid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_valid_offset:lgqe_valid_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_valid_offset:lgqe_valid_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_valid_d),
   .dout(lgqe_valid_q)
);

generate begin : lgqe_iTag
      genvar                                                  lgq;
      for (lgq=0; lgq<`LGQ_ENTRIES; lgq=lgq+1) begin : lgqe_iTag
         tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) lgqe_iTag_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_lgqe_act[lgq]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_iTag_offset + (`ITAG_SIZE_ENC * lgq):lgqe_iTag_offset + (`ITAG_SIZE_ENC * (lgq + 1)) - 1]),
            .scout(sov[lgqe_iTag_offset + (`ITAG_SIZE_ENC * lgq):lgqe_iTag_offset + (`ITAG_SIZE_ENC * (lgq + 1)) - 1]),
            .din(lgqe_itag_d[lgq]),
            .dout(lgqe_itag_q[lgq])
         );
      end
   end
endgenerate

generate begin : lgqe_ldTag
      genvar                                                  lgq0;
      for (lgq0=0; lgq0<`LGQ_ENTRIES; lgq0=lgq0+1) begin : lgqe_ldTag
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lgqe_ldTag_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_lgqe_act[lgq0]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_ldTag_offset + (4 * lgq0):lgqe_ldTag_offset + (4 * (lgq0 + 1)) - 1]),
            .scout(sov[lgqe_ldTag_offset + (4 * lgq0):lgqe_ldTag_offset + (4 * (lgq0 + 1)) - 1]),
            .din(lgqe_ldTag_d[lgq0]),
            .dout(lgqe_ldTag_q[lgq0])
         );
      end
   end
endgenerate

generate begin : lgqe_thrd_id
      genvar                                                  lgq1;
      for (lgq1=0; lgq1<`LGQ_ENTRIES; lgq1=lgq1+1) begin : lgqe_thrd_id
         tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lgqe_thrd_id_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_lgqe_act[lgq1]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_thrd_id_offset + (`THREADS * lgq1):lgqe_thrd_id_offset + (`THREADS * (lgq1 + 1)) - 1]),
            .scout(sov[lgqe_thrd_id_offset + (`THREADS * lgq1):lgqe_thrd_id_offset + (`THREADS * (lgq1 + 1)) - 1]),
            .din(lgqe_thrd_id_d[lgq1]),
            .dout(lgqe_thrd_id_q[lgq1])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_byte_swap_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_byte_swap_offset:lgqe_byte_swap_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_byte_swap_offset:lgqe_byte_swap_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_byte_swap_d),
   .dout(lgqe_byte_swap_q)
);

generate begin : lgqe_op_size
      genvar                                                  lgq2;
      for (lgq2=0; lgq2<`LGQ_ENTRIES; lgq2=lgq2+1) begin : lgqe_op_size
         tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) lgqe_op_size_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_lgqe_act[lgq2]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_op_size_offset + (3 * lgq2):lgqe_op_size_offset + (3 * (lgq2 + 1)) - 1]),
            .scout(sov[lgqe_op_size_offset + (3 * lgq2):lgqe_op_size_offset + (3 * (lgq2 + 1)) - 1]),
            .din(lgqe_op_size_d[lgq2]),
            .dout(lgqe_op_size_q[lgq2])
         );
      end
   end
endgenerate

generate begin : lgqe_tgpr
      genvar                                                  lgq3;
      for (lgq3=0; lgq3<`LGQ_ENTRIES; lgq3=lgq3+1) begin : lgqe_tgpr
         tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) lgqe_tgpr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_lgqe_act[lgq3]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_tgpr_offset + (AXU_TARGET_ENC * lgq3):lgqe_tgpr_offset + (AXU_TARGET_ENC * (lgq3 + 1)) - 1]),
            .scout(sov[lgqe_tgpr_offset + (AXU_TARGET_ENC * lgq3):lgqe_tgpr_offset + (AXU_TARGET_ENC * (lgq3 + 1)) - 1]),
            .din(lgqe_tgpr_d[lgq3]),
            .dout(lgqe_tgpr_q[lgq3])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_gpr_done_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_gpr_done_offset:lgqe_gpr_done_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_gpr_done_offset:lgqe_gpr_done_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_gpr_done_d),
   .dout(lgqe_gpr_done_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_resolved_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_resolved_offset:lgqe_resolved_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_resolved_offset:lgqe_resolved_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_resolved_d),
   .dout(lgqe_resolved_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_back_inv_nFlush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_back_inv_nFlush_offset:lgqe_back_inv_nFlush_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_back_inv_nFlush_offset:lgqe_back_inv_nFlush_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_back_inv_nFlush_d),
   .dout(lgqe_back_inv_nFlush_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_back_inv_np1Flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_back_inv_np1Flush_offset:lgqe_back_inv_np1Flush_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_back_inv_np1Flush_offset:lgqe_back_inv_np1Flush_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_back_inv_np1Flush_d),
   .dout(lgqe_back_inv_np1Flush_q)
);

generate begin : lgqe_dacrw
      genvar                                                  lgq4;
      for (lgq4=0; lgq4<`LGQ_ENTRIES; lgq4=lgq4+1) begin : lgqe_dacrw
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lgqe_dacrw_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex5_lgqe_act[lgq4]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_dacrw_offset + (4 * lgq4):lgqe_dacrw_offset + (4 * (lgq4 + 1)) - 1]),
            .scout(sov[lgqe_dacrw_offset + (4 * lgq4):lgqe_dacrw_offset + (4 * (lgq4 + 1)) - 1]),
            .din(lgqe_dacrw_d[lgq4]),
            .dout(lgqe_dacrw_q[lgq4])
         );
      end
   end
endgenerate

generate begin : lgqe_dvc
      genvar                                                  lgq5;
      for (lgq5=0; lgq5<`LGQ_ENTRIES; lgq5=lgq5+1) begin : lgqe_dvc
         tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) lgqe_dvc_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_dvc_offset + (2 * lgq5):lgqe_dvc_offset + (2 * (lgq5 + 1)) - 1]),
            .scout(sov[lgqe_dvc_offset + (2 * lgq5):lgqe_dvc_offset + (2 * (lgq5 + 1)) - 1]),
            .din(lgqe_dvc_d[lgq5]),
            .dout(lgqe_dvc_q[lgq5])
         );
      end
   end
endgenerate

generate begin : lgqe_p_addr
      genvar                                                  lgq6;
      for (lgq6=0; lgq6<`LGQ_ENTRIES; lgq6=lgq6+1) begin : lgqe_p_addr
         tri_rlmreg_p #(.WIDTH(7), .INIT(0), .NEEDS_SRESET(1)) lgqe_p_addr_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_lgqe_act[lgq6]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_p_addr_offset + (7 * lgq6):lgqe_p_addr_offset + (7 * (lgq6 + 1)) - 1]),
            .scout(sov[lgqe_p_addr_offset + (7 * lgq6):lgqe_p_addr_offset + (7 * (lgq6 + 1)) - 1]),
            .din(lgqe_p_addr_d[lgq6]),
            .dout(lgqe_p_addr_q[lgq6])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_algebraic_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_algebraic_offset:lgqe_algebraic_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_algebraic_offset:lgqe_algebraic_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_algebraic_d),
   .dout(lgqe_algebraic_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_axu_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_axu_offset:lgqe_axu_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_axu_offset:lgqe_axu_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_axu_d),
   .dout(lgqe_axu_q)
);

generate begin : lgqe_perf_events
      genvar                                                  lgq6;
      for (lgq6=0; lgq6<`LGQ_ENTRIES; lgq6=lgq6+1) begin : lgqe_perf_events
         tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lgqe_perf_events_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(ex4_lgqe_act[lgq6]),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[lgqe_perf_events_offset + (4 * lgq6):lgqe_perf_events_offset + (4 * (lgq6 + 1)) - 1]),
            .scout(sov[lgqe_perf_events_offset + (4 * lgq6):lgqe_perf_events_offset + (4 * (lgq6 + 1)) - 1]),
            .din(lgqe_perf_events_d[lgq6]),
            .dout(lgqe_perf_events_q[lgq6])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_upd_gpr_ecc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_upd_gpr_ecc_offset:lgqe_upd_gpr_ecc_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_upd_gpr_ecc_offset:lgqe_upd_gpr_ecc_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_upd_gpr_ecc_d),
   .dout(lgqe_upd_gpr_ecc_q)
);

tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_upd_gpr_eccue_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_upd_gpr_eccue_offset:lgqe_upd_gpr_eccue_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_upd_gpr_eccue_offset:lgqe_upd_gpr_eccue_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_upd_gpr_eccue_d),
   .dout(lgqe_upd_gpr_eccue_q)
);

tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgqe_need_cpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgqe_need_cpl_offset:lgqe_need_cpl_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgqe_need_cpl_offset:lgqe_need_cpl_offset + `LGQ_ENTRIES - 1]),
   .din(lgqe_need_cpl_d),
   .dout(lgqe_need_cpl_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_rst_eccdet_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_rst_eccdet_offset:ldqe_rst_eccdet_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_rst_eccdet_offset:ldqe_rst_eccdet_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_rst_eccdet_d),
   .dout(ldqe_rst_eccdet_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_beats_home_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_beats_home_offset:ldq_rel2_beats_home_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel2_beats_home_offset:ldq_rel2_beats_home_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel2_beats_home_d),
   .dout(ldq_rel2_beats_home_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel3_beats_home_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_beats_home_offset:ldq_rel3_beats_home_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel3_beats_home_offset:ldq_rel3_beats_home_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel3_beats_home_d),
   .dout(ldq_rel3_beats_home_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel4_beats_home_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_beats_home_offset:ldq_rel4_beats_home_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel4_beats_home_offset:ldq_rel4_beats_home_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel4_beats_home_d),
   .dout(ldq_rel4_beats_home_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel5_beats_home_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel5_beats_home_offset:ldq_rel5_beats_home_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel5_beats_home_offset:ldq_rel5_beats_home_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel5_beats_home_d),
   .dout(ldq_rel5_beats_home_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_entrySent_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_entrySent_offset:ldq_rel1_entrySent_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel1_entrySent_offset:ldq_rel1_entrySent_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel1_entrySent_d),
   .dout(ldq_rel1_entrySent_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_entrySent_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_entrySent_offset:ldq_rel2_entrySent_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel2_entrySent_offset:ldq_rel2_entrySent_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel2_entrySent_d),
   .dout(ldq_rel2_entrySent_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel3_entrySent_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_entrySent_offset:ldq_rel3_entrySent_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel3_entrySent_offset:ldq_rel3_entrySent_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel3_entrySent_d),
   .dout(ldq_rel3_entrySent_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel4_sentL1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_sentL1_offset:ldq_rel4_sentL1_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel4_sentL1_offset:ldq_rel4_sentL1_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel4_sentL1_d),
   .dout(ldq_rel4_sentL1_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel5_sentL1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel5_sentL1_offset:ldq_rel5_sentL1_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel5_sentL1_offset:ldq_rel5_sentL1_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel5_sentL1_d),
   .dout(ldq_rel5_sentL1_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel6_req_done_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel6_req_done_offset:ldq_rel6_req_done_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel6_req_done_offset:ldq_rel6_req_done_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel6_req_done_d),
   .dout(ldq_rel6_req_done_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel1_resp_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel1_resp_val_offset]),
   .scout(sov[l2_rel1_resp_val_offset]),
   .din(l2_rel1_resp_val_d),
   .dout(l2_rel1_resp_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_rel2_resp_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[l2_rel2_resp_val_offset]),
   .scout(sov[l2_rel2_resp_val_offset]),
   .din(l2_rel2_resp_val_d),
   .dout(l2_rel2_resp_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_err_inval_rel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_err_inval_rel_offset]),
   .scout(sov[ldq_err_inval_rel_offset]),
   .din(ldq_err_inval_rel_d),
   .dout(ldq_err_inval_rel_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_err_ecc_det_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_err_ecc_det_offset]),
   .scout(sov[ldq_err_ecc_det_offset]),
   .din(ldq_err_ecc_det_d),
   .dout(ldq_err_ecc_det_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_err_ue_det_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_err_ue_det_offset]),
   .scout(sov[ldq_err_ue_det_offset]),
   .din(ldq_err_ue_det_d),
   .dout(ldq_err_ue_det_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_val_offset]),
   .scout(sov[ldq_rel1_val_offset]),
   .din(ldq_rel1_val_d),
   .dout(ldq_rel1_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_arb_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_arb_val_offset]),
   .scout(sov[ldq_rel1_arb_val_offset]),
   .din(ldq_rel1_arb_val_d),
   .dout(ldq_rel1_arb_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_l1_dump_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_l1_dump_offset]),
   .scout(sov[ldq_rel1_l1_dump_offset]),
   .din(ldq_rel1_l1_dump_d),
   .dout(ldq_rel1_l1_dump_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel2_l1_dump_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_l1_dump_offset]),
   .scout(sov[ldq_rel2_l1_dump_offset]),
   .din(ldq_rel2_l1_dump_d),
   .dout(ldq_rel2_l1_dump_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel3_l1_dump_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_l1_dump_offset]),
   .scout(sov[ldq_rel3_l1_dump_offset]),
   .din(ldq_rel3_l1_dump_d),
   .dout(ldq_rel3_l1_dump_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel3_clr_relq_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_clr_relq_offset]),
   .scout(sov[ldq_rel3_clr_relq_offset]),
   .din(ldq_rel3_clr_relq_d),
   .dout(ldq_rel3_clr_relq_q)
);


tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_resp_qw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_resp_qw_offset:ldq_rel1_resp_qw_offset + 3 - 1]),
   .scout(sov[ldq_rel1_resp_qw_offset:ldq_rel1_resp_qw_offset + 3 - 1]),
   .din(ldq_rel1_resp_qw_d),
   .dout(ldq_rel1_resp_qw_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_cTag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_cTag_offset:ldq_rel1_cTag_offset + 4 - 1]),
   .scout(sov[ldq_rel1_cTag_offset:ldq_rel1_cTag_offset + 4 - 1]),
   .din(ldq_rel1_cTag_d),
   .dout(ldq_rel1_cTag_q)
);


tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_opsize_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_opsize_offset:ldq_rel1_opsize_offset + 3 - 1]),
   .scout(sov[ldq_rel1_opsize_offset:ldq_rel1_opsize_offset + 3 - 1]),
   .din(ldq_rel1_opsize_d),
   .dout(ldq_rel1_opsize_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_wimge_i_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_wimge_i_offset]),
   .scout(sov[ldq_rel1_wimge_i_offset]),
   .din(ldq_rel1_wimge_i_d),
   .dout(ldq_rel1_wimge_i_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_byte_swap_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_byte_swap_offset]),
   .scout(sov[ldq_rel1_byte_swap_offset]),
   .din(ldq_rel1_byte_swap_d),
   .dout(ldq_rel1_byte_swap_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel2_byte_swap_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_byte_swap_offset]),
   .scout(sov[ldq_rel2_byte_swap_offset]),
   .din(ldq_rel2_byte_swap_d),
   .dout(ldq_rel2_byte_swap_q)
);


tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_p_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_p_addr_offset:ldq_rel1_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
   .scout(sov[ldq_rel1_p_addr_offset:ldq_rel1_p_addr_offset + `REAL_IFAR_WIDTH - 1]),
   .din(ldq_rel1_p_addr_d),
   .dout(ldq_rel1_p_addr_q)
);


tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_dvcEn_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_dvcEn_offset:ldq_rel1_dvcEn_offset + 2 - 1]),
   .scout(sov[ldq_rel1_dvcEn_offset:ldq_rel1_dvcEn_offset + 2 - 1]),
   .din(ldq_rel1_dvcEn_d),
   .dout(ldq_rel1_dvcEn_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_lockSet_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_lockSet_offset]),
   .scout(sov[ldq_rel1_lockSet_offset]),
   .din(ldq_rel1_lockSet_d),
   .dout(ldq_rel1_lockSet_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_watchSet_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_watchSet_offset]),
   .scout(sov[ldq_rel1_watchSet_offset]),
   .din(ldq_rel1_watchSet_d),
   .dout(ldq_rel1_watchSet_q)
);


tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_tGpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_tGpr_offset:ldq_rel1_tGpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ldq_rel1_tGpr_offset:ldq_rel1_tGpr_offset + AXU_TARGET_ENC - 1]),
   .din(ldq_rel1_tGpr_d),
   .dout(ldq_rel1_tGpr_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_axu_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_axu_offset]),
   .scout(sov[ldq_rel1_axu_offset]),
   .din(ldq_rel1_axu_d),
   .dout(ldq_rel1_axu_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_algEn_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_algEn_offset]),
   .scout(sov[ldq_rel1_algEn_offset]),
   .din(ldq_rel1_algEn_d),
   .dout(ldq_rel1_algEn_q)
);


tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_classID_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_classID_offset:ldq_rel1_classID_offset + 2 - 1]),
   .scout(sov[ldq_rel1_classID_offset:ldq_rel1_classID_offset + 2 - 1]),
   .din(ldq_rel1_classID_d),
   .dout(ldq_rel1_classID_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_tid_offset:ldq_rel1_tid_offset + `THREADS - 1]),
   .scout(sov[ldq_rel1_tid_offset:ldq_rel1_tid_offset + `THREADS - 1]),
   .din(ldq_rel1_tid_d),
   .dout(ldq_rel1_tid_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel1_val_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_tid_offset:ldq_rel2_tid_offset + `THREADS - 1]),
   .scout(sov[ldq_rel2_tid_offset:ldq_rel2_tid_offset + `THREADS - 1]),
   .din(ldq_rel2_tid_d),
   .dout(ldq_rel2_tid_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_dir_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(rel0_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_dir_tid_offset:ldq_rel1_dir_tid_offset + `THREADS - 1]),
   .scout(sov[ldq_rel1_dir_tid_offset:ldq_rel1_dir_tid_offset + `THREADS - 1]),
   .din(ldq_rel1_dir_tid_d),
   .dout(ldq_rel1_dir_tid_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_relDir_start_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_relDir_start_offset:ldqe_relDir_start_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_relDir_start_offset:ldqe_relDir_start_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_relDir_start_d),
   .dout(ldqe_relDir_start_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel2_set_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_set_val_offset]),
   .scout(sov[ldq_rel2_set_val_offset]),
   .din(ldq_rel2_set_val_d),
   .dout(ldq_rel2_set_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel3_set_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_set_val_offset]),
   .scout(sov[ldq_rel3_set_val_offset]),
   .din(ldq_rel3_set_val_d),
   .dout(ldq_rel3_set_val_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel4_set_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_set_val_offset]),
   .scout(sov[ldq_rel4_set_val_offset]),
   .din(ldq_rel4_set_val_d),
   .dout(ldq_rel4_set_val_q)
);


tri_rlmreg_p #(.WIDTH((57-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_cclass_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ldq_rel1_val_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_cclass_offset:ldq_rel2_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .scout(sov[ldq_rel2_cclass_offset:ldq_rel2_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .din(ldq_rel2_cclass_d),
   .dout(ldq_rel2_cclass_q)
);


tri_rlmreg_p #(.WIDTH((57-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1)) ldq_rel3_cclass_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_cclass_offset:ldq_rel3_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .scout(sov[ldq_rel3_cclass_offset:ldq_rel3_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .din(ldq_rel3_cclass_d),
   .dout(ldq_rel3_cclass_q)
);


tri_rlmreg_p #(.WIDTH((57-(64-(`DC_SIZE-3))+1)), .INIT(0), .NEEDS_SRESET(1)) ldq_rel4_cclass_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_cclass_offset:ldq_rel4_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .scout(sov[ldq_rel4_cclass_offset:ldq_rel4_cclass_offset + (57-(64-(`DC_SIZE-3))+1) - 1]),
   .din(ldq_rel4_cclass_d),
   .dout(ldq_rel4_cclass_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_data_sel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_data_sel_offset]),
   .scout(sov[ldq_rel1_data_sel_offset]),
   .din(ldq_rel1_data_sel_d),
   .dout(ldq_rel1_data_sel_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel0_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel0_l2_val_offset:ldq_rel0_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel0_l2_val_offset:ldq_rel0_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel0_l2_val_d),
   .dout(ldq_rel0_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_l2_val_offset:ldq_rel1_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel1_l2_val_offset:ldq_rel1_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel1_l2_val_d),
   .dout(ldq_rel1_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_l2_val_offset:ldq_rel2_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel2_l2_val_offset:ldq_rel2_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel2_l2_val_d),
   .dout(ldq_rel2_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel3_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_l2_val_offset:ldq_rel3_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel3_l2_val_offset:ldq_rel3_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel3_l2_val_d),
   .dout(ldq_rel3_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel4_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_l2_val_offset:ldq_rel4_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel4_l2_val_offset:ldq_rel4_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel4_l2_val_d),
   .dout(ldq_rel4_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel5_l2_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel5_l2_val_offset:ldq_rel5_l2_val_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel5_l2_val_offset:ldq_rel5_l2_val_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel5_l2_val_d),
   .dout(ldq_rel5_l2_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_rel_eccdet_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_rel_eccdet_offset:ldqe_rel_eccdet_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_rel_eccdet_offset:ldqe_rel_eccdet_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_rel_eccdet_d),
   .dout(ldqe_rel_eccdet_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_rel_eccdet_ue_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_rel_eccdet_ue_offset:ldqe_rel_eccdet_ue_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_rel_eccdet_ue_offset:ldqe_rel_eccdet_ue_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_rel_eccdet_ue_d),
   .dout(ldqe_rel_eccdet_ue_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_upd_gpr_ecc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_upd_gpr_ecc_offset:ldqe_upd_gpr_ecc_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_upd_gpr_ecc_offset:ldqe_upd_gpr_ecc_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_upd_gpr_ecc_d),
   .dout(ldqe_upd_gpr_ecc_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_upd_gpr_eccue_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_upd_gpr_eccue_offset:ldqe_upd_gpr_eccue_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_upd_gpr_eccue_offset:ldqe_upd_gpr_eccue_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_upd_gpr_eccue_d),
   .dout(ldqe_upd_gpr_eccue_q)
);

tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_need_cpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_need_cpl_offset:ldqe_need_cpl_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_need_cpl_offset:ldqe_need_cpl_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_need_cpl_d),
   .dout(ldqe_need_cpl_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_sent_cpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_sent_cpl_offset:ldqe_sent_cpl_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_sent_cpl_offset:ldqe_sent_cpl_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_sent_cpl_d),
   .dout(ldqe_sent_cpl_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel1_gpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_gpr_val_offset]),
   .scout(sov[ldq_rel1_gpr_val_offset]),
   .din(ldq_rel1_gpr_val_d),
   .dout(ldq_rel1_gpr_val_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel0_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel0_upd_gpr_offset:ldq_rel0_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel0_upd_gpr_offset:ldq_rel0_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel0_upd_gpr_d),
   .dout(ldq_rel0_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel1_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel1_upd_gpr_offset:ldq_rel1_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel1_upd_gpr_offset:ldq_rel1_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel1_upd_gpr_d),
   .dout(ldq_rel1_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel2_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel2_upd_gpr_offset:ldq_rel2_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel2_upd_gpr_offset:ldq_rel2_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel2_upd_gpr_d),
   .dout(ldq_rel2_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel3_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel3_upd_gpr_offset:ldq_rel3_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel3_upd_gpr_offset:ldq_rel3_upd_gpr_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel3_upd_gpr_d),
   .dout(ldq_rel3_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_rel3_drop_cpl_rpt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_rel3_drop_cpl_rpt_offset:ldqe_rel3_drop_cpl_rpt_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_rel3_drop_cpl_rpt_offset:ldqe_rel3_drop_cpl_rpt_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_rel3_drop_cpl_rpt_d),
   .dout(ldqe_rel3_drop_cpl_rpt_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_l2_rel0_qHitBlk_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_l2_rel0_qHitBlk_offset]),
   .scout(sov[ldq_l2_rel0_qHitBlk_offset]),
   .din(ldq_l2_rel0_qHitBlk_d),
   .dout(ldq_l2_rel0_qHitBlk_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lgq_rel1_gpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel1_gpr_val_offset]),
   .scout(sov[lgq_rel1_gpr_val_offset]),
   .din(lgq_rel1_gpr_val_d),
   .dout(lgq_rel1_gpr_val_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel0_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel0_upd_gpr_offset:lgq_rel0_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel0_upd_gpr_offset:lgq_rel0_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel0_upd_gpr_d),
   .dout(lgq_rel0_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel1_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel1_upd_gpr_offset:lgq_rel1_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel1_upd_gpr_offset:lgq_rel1_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel1_upd_gpr_d),
   .dout(lgq_rel1_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel2_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel2_upd_gpr_offset:lgq_rel2_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel2_upd_gpr_offset:lgq_rel2_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel2_upd_gpr_d),
   .dout(lgq_rel2_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel3_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel3_upd_gpr_offset:lgq_rel3_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel3_upd_gpr_offset:lgq_rel3_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel3_upd_gpr_d),
   .dout(lgq_rel3_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel4_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel4_upd_gpr_offset:lgq_rel4_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel4_upd_gpr_offset:lgq_rel4_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel4_upd_gpr_d),
   .dout(lgq_rel4_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LGQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) lgq_rel5_upd_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lgq_rel5_upd_gpr_offset:lgq_rel5_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .scout(sov[lgq_rel5_upd_gpr_offset:lgq_rel5_upd_gpr_offset + `LGQ_ENTRIES - 1]),
   .din(lgq_rel5_upd_gpr_d),
   .dout(lgq_rel5_upd_gpr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel4_odq_cpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel4_odq_cpl_offset:ldq_rel4_odq_cpl_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel4_odq_cpl_offset:ldq_rel4_odq_cpl_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel4_odq_cpl_d),
   .dout(ldq_rel4_odq_cpl_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel5_odq_cpl_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel5_odq_cpl_offset:ldq_rel5_odq_cpl_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel5_odq_cpl_offset:ldq_rel5_odq_cpl_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel5_odq_cpl_d),
   .dout(ldq_rel5_odq_cpl_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldq_rel_qHit_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel_qHit_clr_offset:ldq_rel_qHit_clr_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldq_rel_qHit_clr_offset:ldq_rel_qHit_clr_offset + `LMQ_ENTRIES - 1]),
   .din(ldq_rel_qHit_clr_d),
   .dout(ldq_rel_qHit_clr_q)
);


tri_rlmreg_p #(.WIDTH(`LMQ_ENTRIES), .INIT(0), .NEEDS_SRESET(1)) ldqe_qHit_held_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldqe_qHit_held_offset:ldqe_qHit_held_offset + `LMQ_ENTRIES - 1]),
   .scout(sov[ldqe_qHit_held_offset:ldqe_qHit_held_offset + `LMQ_ENTRIES - 1]),
   .din(ldqe_qHit_held_d),
   .dout(ldqe_qHit_held_q)
);

generate begin : cpl_grpEntry_last_sel
      genvar                                                  grp0;
      for (grp0=0; grp0<=(`LMQ_ENTRIES+`LGQ_ENTRIES-1)/4; grp0=grp0+1) begin : cpl_grpEntry_last_sel
         tri_rlmreg_p #(.WIDTH(4), .INIT(8), .NEEDS_SRESET(1)) cpl_grpEntry_last_sel_reg(
            .vd(vdd),
            .gd(gnd),
            .nclk(nclk),
            .act(tiup),
            .force_t(func_sl_force),
            .d_mode(d_mode_dc),
            .delay_lclkr(delay_lclkr_dc),
            .mpw1_b(mpw1_dc_b),
            .mpw2_b(mpw2_dc_b),
            .thold_b(func_sl_thold_0_b),
            .sg(sg_0),
            .scin(siv[cpl_grpEntry_last_sel_offset + (4 * grp0):cpl_grpEntry_last_sel_offset + (4 * (grp0 + 1)) - 1]),
            .scout(sov[cpl_grpEntry_last_sel_offset + (4 * grp0):cpl_grpEntry_last_sel_offset + (4 * (grp0 + 1)) - 1]),
            .din(cpl_grpEntry_last_sel_d[grp0]),
            .dout(cpl_grpEntry_last_sel_q[grp0])
         );
      end
   end
endgenerate


tri_rlmreg_p #(.WIDTH(4), .INIT(8), .NEEDS_SRESET(1)) cpl_group_last_sel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[cpl_group_last_sel_offset:cpl_group_last_sel_offset + 4 - 1]),
   .scout(sov[cpl_group_last_sel_offset:cpl_group_last_sel_offset + 4 - 1]),
   .din(cpl_group_last_sel_d),
   .dout(cpl_group_last_sel_q)
);


tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq1_iu_execute_vld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_execute_vld_offset:lq1_iu_execute_vld_offset + `THREADS - 1]),
   .scout(sov[lq1_iu_execute_vld_offset:lq1_iu_execute_vld_offset + `THREADS - 1]),
   .din(lq1_iu_execute_vld_d),
   .dout(lq1_iu_execute_vld_q)
);


tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(1), .NEEDS_SRESET(1)) lq1_iu_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_itag_offset:lq1_iu_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[lq1_iu_itag_offset:lq1_iu_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(lq1_iu_itag_d),
   .dout(lq1_iu_itag_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_iu_n_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_n_flush_offset]),
   .scout(sov[lq1_iu_n_flush_offset]),
   .din(lq1_iu_n_flush_d),
   .dout(lq1_iu_n_flush_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_iu_np1_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_np1_flush_offset]),
   .scout(sov[lq1_iu_np1_flush_offset]),
   .din(lq1_iu_np1_flush_d),
   .dout(lq1_iu_np1_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_iu_exception_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_exception_val_offset]),
   .scout(sov[lq1_iu_exception_val_offset]),
   .din(lq1_iu_exception_val_d),
   .dout(lq1_iu_exception_val_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq1_iu_dacrw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_dacrw_offset:lq1_iu_dacrw_offset + 4 - 1]),
   .scout(sov[lq1_iu_dacrw_offset:lq1_iu_dacrw_offset + 4 - 1]),
   .din(lq1_iu_dacrw_d),
   .dout(lq1_iu_dacrw_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq1_iu_perf_events_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq1_iu_perf_events_offset:lq1_iu_perf_events_offset + 4 - 1]),
   .scout(sov[lq1_iu_perf_events_offset:lq1_iu_perf_events_offset + 4 - 1]),
   .din(lq1_iu_perf_events_d),
   .dout(lq1_iu_perf_events_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_cpl_larx_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_cpl_larx_offset:ldq_cpl_larx_offset + `THREADS - 1]),
   .scout(sov[ldq_cpl_larx_offset:ldq_cpl_larx_offset + `THREADS - 1]),
   .din(ldq_cpl_larx_d),
   .dout(ldq_cpl_larx_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_cpl_binv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_cpl_binv_offset:ldq_cpl_binv_offset + `THREADS - 1]),
   .scout(sov[ldq_cpl_binv_offset:ldq_cpl_binv_offset + `THREADS - 1]),
   .din(ldq_cpl_binv_d),
   .dout(ldq_cpl_binv_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel_cmmt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel_cmmt_offset]),
   .scout(sov[ldq_rel_cmmt_offset]),
   .din(ldq_rel_cmmt_d),
   .dout(ldq_rel_cmmt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel_need_hole_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel_need_hole_offset]),
   .scout(sov[ldq_rel_need_hole_offset]),
   .din(ldq_rel_need_hole_d),
   .dout(ldq_rel_need_hole_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_rel_latency_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ldq_rel_latency_offset]),
   .scout(sov[ldq_rel_latency_offset]),
   .din(ldq_rel_latency_d),
   .dout(ldq_rel_latency_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) dbg_int_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[dbg_int_en_offset:dbg_int_en_offset + `THREADS - 1]),
   .scout(sov[dbg_int_en_offset:dbg_int_en_offset + `THREADS - 1]),
   .din(dbg_int_en_d),
   .dout(dbg_int_en_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stg_act_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_stg_act_offset]),
   .scout(sov[ex4_stg_act_offset]),
   .din(ex4_stg_act_d),
   .dout(ex4_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_stg_act_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_stg_act_offset]),
   .scout(sov[ex5_stg_act_offset]),
   .din(ex5_stg_act_d),
   .dout(ex5_stg_act_q)
);

assign rdat_scan_in = scan_in;
assign siv[0:scan_right] = {sov[1:scan_right], rdat_scan_out};
assign scan_out = sov[0];

endmodule
