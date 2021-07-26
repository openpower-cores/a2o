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

//  Description:  XU LSU L2 Command Queue
//
//*****************************************************************************

`include "tri_a2o.vh"

module lq_lsq(
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_s3_t,
   rv_lq_rv1_i0_isLoad,
   rv_lq_rv1_i0_isStore,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i0_rte_lq,
   rv_lq_rv1_i0_rte_sq,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_s3_t,
   rv_lq_rv1_i1_isLoad,
   rv_lq_rv1_i1_isStore,
   rv_lq_rv1_i1_itag,
   rv_lq_rv1_i1_rte_lq,
   rv_lq_rv1_i1_rte_sq,
   xu1_lq_ex2_stq_val,
   xu1_lq_ex2_stq_itag,
   xu1_lq_ex2_stq_dvc1_cmp,
   xu1_lq_ex2_stq_dvc2_cmp,
   ctl_lsq_ex4_xu1_data,
   xu1_lq_ex3_illeg_lswx,
   xu1_lq_ex3_strg_noop,
   xu_lq_axu_ex_stq_val,
   xu_lq_axu_ex_stq_itag,
   xu_lq_axu_exp1_stq_data,
   rv_lq_vld,
   rv_lq_isLoad,
   rv_lq_rvs_empty,
   ctl_lsq_rv1_dir_rd_val,
   ctl_lsq_ex2_streq_val,
   ctl_lsq_ex2_itag,
   ctl_lsq_ex2_thrd_id,
   ctl_lsq_ex3_ldreq_val,
   ctl_lsq_ex3_wchkall_val,
   ctl_lsq_ex3_pfetch_val,
   ctl_lsq_ex3_byte_en,
   ctl_lsq_ex3_p_addr,
   ctl_lsq_ex3_thrd_id,
   ctl_lsq_ex3_algebraic,
   ctl_lsq_ex3_opsize,
   ctl_lsq_ex4_ldreq_val,
   ctl_lsq_ex4_binvreq_val,
   ctl_lsq_ex4_streq_val,
   ctl_lsq_ex4_othreq_val,
   ctl_lsq_ex4_p_addr,
   ctl_lsq_ex4_dReq_val,
   ctl_lsq_ex4_gath_load,
   ctl_lsq_ex4_send_l2,
   ctl_lsq_ex4_has_data,
   ctl_lsq_ex4_cline_chk,
   ctl_lsq_ex4_wimge,
   ctl_lsq_ex4_byte_swap,
   ctl_lsq_ex4_is_sync,
   ctl_lsq_ex4_all_thrd_chk,
   ctl_lsq_ex4_is_icbi,
   ctl_lsq_ex4_watch_clr,
   ctl_lsq_ex4_watch_clr_all,
   ctl_lsq_ex4_mtspr_trace,
   ctl_lsq_ex4_is_resv,
   ctl_lsq_ex4_is_mfgpr,
   ctl_lsq_ex4_is_icswxr,
   ctl_lsq_ex4_is_store,
   ctl_lsq_ex4_is_inval_op,
   ctl_lsq_ex4_is_cinval,
   ctl_lsq_ex5_lock_clr,
   ctl_lsq_ex5_lock_set,
   ctl_lsq_ex5_watch_set,
   ctl_lsq_ex5_tgpr,
   ctl_lsq_ex5_axu_val,
   ctl_lsq_ex5_is_epid,
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
   ctl_lsq_ex5_class_id,
   ctl_lsq_ex5_dvc,
   ctl_lsq_ex5_dacrw,
   ctl_lsq_ex5_ttype,
   ctl_lsq_ex5_l_fld,
   ctl_lsq_ex5_load_hit,
   lsq_ctl_ex6_ldq_events,
   lsq_ctl_ex6_stq_events,
   lsq_perv_ex7_events,
   lsq_perv_ldq_events,
   lsq_perv_stq_events,
   lsq_perv_odq_events,
   ctl_lsq_ex6_ldh_dacrw,
   ctl_lsq_stq3_icswx_data,
   ctl_lsq_spr_dvc1_dbg,
   ctl_lsq_spr_dvc2_dbg,
   ctl_lsq_spr_dbcr2_dvc1m,
   ctl_lsq_spr_dbcr2_dvc1be,
   ctl_lsq_spr_dbcr2_dvc2m,
   ctl_lsq_spr_dbcr2_dvc2be,
   ctl_lsq_dbg_int_en,
   ctl_lsq_ldp_idle,
   ctl_lsq_spr_lsucr0_b2b,
   ctl_lsq_spr_lsucr0_lge,
   ctl_lsq_spr_lsucr0_lca,
   ctl_lsq_spr_lsucr0_sca,
   ctl_lsq_spr_lsucr0_dfwd,
   ctl_lsq_pf_empty,
   dir_arr_wr_enable,
   dir_arr_wr_way,
   dir_arr_wr_addr,
   dir_arr_wr_data,
   dir_arr_rd_data1,
   xu_lq_spr_xucr0_cls,
   xu_lq_spr_xucr0_cred,
   iu_lq_spr_iucr0_icbi_ack,
   dat_lsq_stq4_128data,
   iu_lq_request,
   iu_lq_cTag,
   iu_lq_ra,
   iu_lq_wimge,
   iu_lq_userdef,
   lq_iu_icbi_val,
   lq_iu_icbi_addr,
   iu_lq_icbi_complete,
   lq_iu_ici_val,
   mm_lq_lsu_req,
   mm_lq_lsu_ttype,
   mm_lq_lsu_wimge,
   mm_lq_lsu_u,
   mm_lq_lsu_addr,
   mm_lq_lsu_lpid,
   mm_lq_lsu_gs,
   mm_lq_lsu_ind,
   mm_lq_lsu_lbit,
   mm_lq_lsu_lpidr,
   lq_mm_lsu_token,
   lq_mm_lmq_stq_empty,
   lq_xu_quiesce,
   lq_pc_ldq_quiesce,
   lq_pc_stq_quiesce,
   lq_pc_pfetch_quiesce,
   iu_lq_cp_flush,
   iu_lq_recirc_val,
   iu_lq_cp_next_itag,
   iu_lq_i0_completed,
   iu_lq_i0_completed_itag,
   iu_lq_i1_completed,
   iu_lq_i1_completed_itag,
   xu_lq_xer_cp_rd,
   an_ac_sync_ack,
   an_ac_stcx_complete,
   an_ac_stcx_pass,
   an_ac_icbi_ack,
   an_ac_icbi_ack_thread,
   an_ac_coreid,
   an_ac_req_ld_pop,
   an_ac_req_st_pop,
   an_ac_req_st_gather,
   an_ac_reld_data_vld,
   an_ac_reld_core_tag,
   an_ac_reld_qw,
   an_ac_reld_data,
   an_ac_reld_data_coming,
   an_ac_reld_ditc,
   an_ac_reld_crit_qw,
   an_ac_reld_l1_dump,
   an_ac_reld_ecc_err,
   an_ac_reld_ecc_err_ue,
   an_ac_back_inv,
   an_ac_back_inv_addr,
   an_ac_back_inv_target_bit1,
   an_ac_back_inv_target_bit3,
   an_ac_back_inv_target_bit4,
   an_ac_req_spare_ctrl_a1,
   lq_iu_credit_free,
   sq_iu_credit_free,
   lsq_ctl_rv_hold_all,
   lsq_ctl_rv_set_hold,
   lsq_ctl_rv_clr_hold,
   lsq_ctl_stq_release_itag_vld,
   lsq_ctl_stq_release_itag,
   lsq_ctl_stq_release_tid,
   lsq_ctl_stq_cpl_ready,
   lsq_ctl_stq_cpl_ready_itag,
   lsq_ctl_stq_cpl_ready_tid,
   lsq_ctl_stq_n_flush,
   lsq_ctl_stq_np1_flush,
   lsq_ctl_stq_exception_val,
   lsq_ctl_stq_exception,
   lsq_ctl_stq_dacrw,
   ctl_lsq_stq_cpl_blk,
   ctl_lsq_ex_pipe_full,
   lsq_ctl_ex5_ldq_restart,
   lsq_ctl_ex5_stq_restart,
   lsq_ctl_ex5_stq_restart_miss,
   lsq_ctl_ex5_fwd_val,
   lsq_ctl_ex5_fwd_data,
   lsq_ctl_sync_in_stq,
   lsq_ctl_sync_done,
   lq1_iu_execute_vld,
   lq1_iu_itag,
   lq1_iu_exception_val,
   lq1_iu_exception,
   lq1_iu_n_flush,
   lq1_iu_np1_flush,
   lq1_iu_dacr_type,
   lq1_iu_dacrw,
   lq1_iu_perf_events,
   lsq_dat_stq1_stg_act,
   lsq_dat_rel1_data_val,
   lsq_dat_rel1_qw,
   lsq_dat_stq1_val,
   lsq_dat_stq1_mftgpr_val,
   lsq_dat_stq1_store_val,
   lsq_dat_stq1_byte_en,
   lsq_dat_stq1_op_size,
   lsq_dat_stq1_addr,
   lsq_dat_stq1_le_mode,
   lsq_dat_stq2_blk_req,
   lsq_dat_stq2_store_data,
   lsq_ctl_stq1_stg_act,
   lsq_ctl_oldest_tid,
   lsq_ctl_oldest_itag,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_data_val,
   lsq_ctl_rel1_back_inv,
   lsq_ctl_rel1_tag,
   lsq_ctl_rel1_classid,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_watch_set,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_rel2_upd_val,
   lsq_ctl_rel2_data,
   lsq_ctl_rel3_l1dump_val,
   lsq_ctl_rel3_clr_relq,
   ctl_lsq_stq4_perr_reject,
   lsq_ctl_stq1_val,
   lsq_ctl_stq1_mftgpr_val,
   lsq_ctl_stq1_mfdpf_val,
   lsq_ctl_stq1_mfdpa_val,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_rel1_thrd_id,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq1_lock_clr,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_inval,
   lsq_ctl_stq1_dci_val,
   lsq_ctl_stq1_addr,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_axu_val,
   lsq_ctl_stq1_epid_val,
   lsq_ctl_stq4_xucr0_cul,
   lsq_ctl_stq5_itag,
   lsq_ctl_stq5_tgpr,
   lsq_ctl_rel1_gpr_val,
   lsq_ctl_rel1_ta_gpr,
   lsq_ctl_rel1_upd_gpr,
   lsq_ctl_stq1_resv,
   lsq_ctl_ex3_strg_val,
   lsq_ctl_ex3_strg_noop,
   lsq_ctl_ex3_illeg_lswx,
   lsq_ctl_ex3_ct_val,
   lsq_ctl_ex3_be_ct,
   lsq_ctl_ex3_le_ct,
   odq_pf_report_tid,
   odq_pf_report_itag,
   odq_pf_resolved,
   lq_xu_cr_l2_we,
   lq_xu_cr_l2_wa,
   lq_xu_cr_l2_wd,
   lq_xu_axu_rel_le,
   lsq_ctl_rv0_back_inv,
   lsq_ctl_rv1_back_inv_addr,
   lq_rv_itag2_vld,
   lq_rv_itag2,
   lq_xu_dbell_val,
   lq_xu_dbell_type,
   lq_xu_dbell_brdcast,
   lq_xu_dbell_lpid_match,
   lq_xu_dbell_pirtag,
   ac_an_req_pwr_token,
   ac_an_req,
   ac_an_req_ra,
   ac_an_req_ttype,
   ac_an_req_thread,
   ac_an_req_wimg_w,
   ac_an_req_wimg_i,
   ac_an_req_wimg_m,
   ac_an_req_wimg_g,
   ac_an_req_endian,
   ac_an_req_user_defined,
   ac_an_req_spare_ctrl_a0,
   ac_an_req_ld_core_tag,
   ac_an_req_ld_xfr_len,
   ac_an_st_byte_enbl,
   ac_an_st_data,
   ac_an_st_data_pwr_token,
   pc_lq_inj_relq_parity,
   lq_pc_err_relq_parity,
   lq_pc_err_invld_reld,
   lq_pc_err_l2intrf_ecc,
   lq_pc_err_l2intrf_ue,
   lq_pc_err_l2credit_overrun,
   vcs,
   vdd,
   gnd,
   nclk,
   sg_2,
   fce_2,
   func_sl_thold_2,
   func_nsl_thold_2,
   func_slp_sl_thold_2,
   pc_lq_ccflush_dc,
   clkoff_dc_b,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   g8t_clkoff_dc_b,
   g8t_d_mode_dc,
   g8t_delay_lclkr_dc,
   g8t_mpw1_dc_b,
   g8t_mpw2_dc_b,
   abst_sl_thold_2,
   time_sl_thold_2,
   ary_nsl_thold_2,
   repr_sl_thold_2,
   bolt_sl_thold_2,
   bo_enable_2,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_ary_wrt_thru_dc,
   pc_lq_abist_ena_dc,
   pc_lq_abist_raw_dc_b,
   pc_lq_bo_unload,
   pc_lq_bo_repair,
   pc_lq_bo_reset,
   pc_lq_bo_shdata,
   pc_lq_bo_select,
   lq_pc_bo_fail,
   lq_pc_bo_diagout,
   pc_lq_abist_wl64_comp_ena,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_abist_raddr_0,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   func_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   func_scan_out
);
//   parameter                                                   EXPAND_TYPE = 2;		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
//   parameter                                                   GPR_WIDTH_ENC = 6;		// Register Mode 5 = 32bit, 6 = 64bit
//   parameter                                                   LDSTQ_ENTRIES = 16;		// Order Queue Size
//   parameter                                                   LDSTQ_ENTRIES_ENC = 4;		// Order Queue Size Encoded
//   parameter                                                   LMQ_ENTRIES = 8;		// Loadmiss Queue Size
//   parameter                                                   LMQ_ENTRIES_ENC = 3;		// Loadmiss Queue Size Encoded
//   parameter                                                   LGQ_ENTRIES = 8;		// Load Gather Queue Size
//   parameter                                                   STQ_ENTRIES = 12;		// Store Queue Size
//   parameter                                                   STQ_ENTRIES_ENC = 4;		// Store Queue Size Encoded
//   parameter                                                   STQ_FWD_ENTRIES = 4;		// number of stq entries that can be forwarded from
//   parameter                                                   STQ_DATA_SIZE = 64;		// 64 or 128 Bit store data sizes supported
//   parameter                                                   IUQ_ENTRIES = 4;		// Instruction Fetch Queue Size
//   parameter                                                   MMQ_ENTRIES = 1;		// Memory Management Queue Size
//   parameter                                                   ITAG_SIZE_ENC = 7;		// ITAG size
//   parameter                                                   CR_POOL_ENC = 5;		// Encode of CR rename pool size
//   parameter                                                   GPR_POOL_ENC = 6;
//   parameter                                                   AXU_SPARE_ENC = 3;
//   parameter                                                   THREADS_POOL_ENC = 1;
//   parameter                                                   DC_SIZE = 15;		// 14 => 16K L1D$, 15 => 32K L1D
//   parameter                                                   CL_SIZE = 6;		// 6 => 64B CLINE, 7 => 128B CLINE
//   parameter                                                   LOAD_CREDITS = 8;
//   parameter                                                   STORE_CREDITS = 32;
//   parameter                                                   THREADS = 2;		// Number of Threads in the System
//   parameter                                                   CR_WIDTH = 4;
//   parameter                                                   REAL_IFAR_WIDTH = 42;		// real addressing bits
   parameter                                                   WAYDATASIZE = 34;		// TagSize + Parity Bits

   //   IU interface to RV for instruction insertion
   // port 0
   input [0:`THREADS-1]                                        rv_lq_rv1_i0_vld;
   input                                                       rv_lq_rv1_i0_ucode_preissue;
   input [0:2]                                                 rv_lq_rv1_i0_s3_t;
   input                                                       rv_lq_rv1_i0_isLoad;
   input                                                       rv_lq_rv1_i0_isStore;
   input [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i0_itag;
   input                                                       rv_lq_rv1_i0_rte_lq;
   input                                                       rv_lq_rv1_i0_rte_sq;

   // port 1
   input [0:`THREADS-1]                                        rv_lq_rv1_i1_vld;
   input                                                       rv_lq_rv1_i1_ucode_preissue;
   input [0:2]                                                 rv_lq_rv1_i1_s3_t;
   input                                                       rv_lq_rv1_i1_isLoad;
   input                                                       rv_lq_rv1_i1_isStore;
   input [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i1_itag;
   input                                                       rv_lq_rv1_i1_rte_lq;
   input                                                       rv_lq_rv1_i1_rte_sq;

   // FXU0 Data interface
   input [0:`THREADS-1]                                        xu1_lq_ex2_stq_val;
   input [0:`ITAG_SIZE_ENC-1]                                  xu1_lq_ex2_stq_itag;
   input [(64-(2**`GPR_WIDTH_ENC))/8:7]                        xu1_lq_ex2_stq_dvc1_cmp;
   input [(64-(2**`GPR_WIDTH_ENC))/8:7]                        xu1_lq_ex2_stq_dvc2_cmp;
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_ex4_xu1_data;
   input                                                       xu1_lq_ex3_illeg_lswx;
   input                                                       xu1_lq_ex3_strg_noop;

   // AXU Data interface
   input [0:`THREADS-1]                                        xu_lq_axu_ex_stq_val;
   input [0:`ITAG_SIZE_ENC-1]                                  xu_lq_axu_ex_stq_itag;
   input [(128-`STQ_DATA_SIZE):127]                            xu_lq_axu_exp1_stq_data;

   // RV1 RV Issue Valid
   input [0:`THREADS-1]                                        rv_lq_vld;
   input                                                       rv_lq_isLoad;

   // RV is empty indicator
   input [0:`THREADS-1]                                        rv_lq_rvs_empty;

   // SPR Directory Read Valid
   input                                                       ctl_lsq_rv1_dir_rd_val;

   // Execution Pipe Outputs
   input [0:`THREADS-1]                                        ctl_lsq_ex2_streq_val;
   input [0:`ITAG_SIZE_ENC-1]                                  ctl_lsq_ex2_itag;
   input [0:`THREADS-1]                                        ctl_lsq_ex2_thrd_id;
   input [0:`THREADS-1]                                        ctl_lsq_ex3_ldreq_val;
   input [0:`THREADS-1]                                        ctl_lsq_ex3_wchkall_val;
   input                                                       ctl_lsq_ex3_pfetch_val;
   input [0:15]                                                ctl_lsq_ex3_byte_en;
   input [58:63]                                               ctl_lsq_ex3_p_addr;
   input [0:`THREADS-1]                                        ctl_lsq_ex3_thrd_id;
   input                                                       ctl_lsq_ex3_algebraic;
   input [0:2]                                                 ctl_lsq_ex3_opsize;
   input                                                       ctl_lsq_ex4_ldreq_val;
   input                                                       ctl_lsq_ex4_binvreq_val;
   input                                                       ctl_lsq_ex4_streq_val;
   input                                                       ctl_lsq_ex4_othreq_val;
   input [64-`REAL_IFAR_WIDTH:57]                              ctl_lsq_ex4_p_addr;
   input                                                       ctl_lsq_ex4_dReq_val;
   input                                                       ctl_lsq_ex4_gath_load;
   input                                                       ctl_lsq_ex4_send_l2;
   input                                                       ctl_lsq_ex4_has_data;
   input                                                       ctl_lsq_ex4_cline_chk;
   input [0:4]                                                 ctl_lsq_ex4_wimge;
   input                                                       ctl_lsq_ex4_byte_swap;
   input                                                       ctl_lsq_ex4_is_sync;
   input                                                       ctl_lsq_ex4_all_thrd_chk;
   input                                                       ctl_lsq_ex4_is_icbi;
   input                                                       ctl_lsq_ex4_watch_clr;
   input                                                       ctl_lsq_ex4_watch_clr_all;
   input                                                       ctl_lsq_ex4_mtspr_trace;
   input                                                       ctl_lsq_ex4_is_resv;
   input                                                       ctl_lsq_ex4_is_mfgpr;
   input                                                       ctl_lsq_ex4_is_icswxr;
   input                                                       ctl_lsq_ex4_is_store;
   input                                                       ctl_lsq_ex4_is_inval_op;
   input                                                       ctl_lsq_ex4_is_cinval;
   input                                                       ctl_lsq_ex5_lock_clr;
   input                                                       ctl_lsq_ex5_lock_set;
   input                                                       ctl_lsq_ex5_watch_set;
   input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  ctl_lsq_ex5_tgpr;
   input                                                       ctl_lsq_ex5_axu_val;
   input                                                       ctl_lsq_ex5_is_epid;
   input [0:3]                                                 ctl_lsq_ex5_usr_def;
   input                                                       ctl_lsq_ex5_drop_rel;
   input                                                       ctl_lsq_ex5_flush_req;		// Flush request from LDQ/STQ
   input                                                       ctl_lsq_ex5_flush_pfetch;  // Flush Prefetch in EX5
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
   input [0:1]                                                 ctl_lsq_ex5_class_id;
   input [0:1]                                                 ctl_lsq_ex5_dvc;
   input [0:3]                                                 ctl_lsq_ex5_dacrw;
   input [0:5]                                                 ctl_lsq_ex5_ttype;
   input [0:1]                                                 ctl_lsq_ex5_l_fld;
   input                                                       ctl_lsq_ex5_load_hit;
   output [0:3]                                                lsq_ctl_ex6_ldq_events;    // LDQ Pipeline Performance Events
   output [0:1]                                                lsq_ctl_ex6_stq_events;    // LDQ Pipeline Performance Events
   output [0:`THREADS-1]                                       lsq_perv_ex7_events;       // LDQ Pipeline Performance Events
   output [0:(2*`THREADS)+3]                                   lsq_perv_ldq_events;       // REL Pipeline Performance Events
   output [0:(3*`THREADS)+2]                                   lsq_perv_stq_events;       // STQ Pipeline Performance Events
   output [0:4+`THREADS-1]                                     lsq_perv_odq_events;       // ODQ Pipeline Performance Events
   input [0:3]                                                 ctl_lsq_ex6_ldh_dacrw;

   // ICSWX Data to be sent to the L2
   input [0:26]                                                ctl_lsq_stq3_icswx_data;

   // Interface with Local SPR's
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc1_dbg;
   input [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_spr_dvc2_dbg;
   input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1m;
   input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc1be;
   input [0:2*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2m;
   input [0:8*`THREADS-1]                                      ctl_lsq_spr_dbcr2_dvc2be;
   input [0:`THREADS-1]                                        ctl_lsq_dbg_int_en;
   input [0:`THREADS-1]                                        ctl_lsq_ldp_idle;
   input                                                       ctl_lsq_spr_lsucr0_b2b;		// LSUCR0[B2B] Mode enabled
   input                                                       ctl_lsq_spr_lsucr0_lge;		// LSUCR0[LGE] Load Gather Enable
   input [0:2]                                                 ctl_lsq_spr_lsucr0_lca;
   input [0:2]                                                 ctl_lsq_spr_lsucr0_sca;
   input                                                       ctl_lsq_spr_lsucr0_dfwd;   // LSUCR0[DFWD] Store Forwarding Disabled

   input [0:`THREADS-1]                                        ctl_lsq_pf_empty;

   //--------------------------------------------------------------
   // Interface with Commit Pipe Directories
   //--------------------------------------------------------------
   input [0:3]                                                 dir_arr_wr_enable;
   input [0:7]                                                 dir_arr_wr_way;
   input [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_wr_addr;
   input [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;
   output [0:(8*WAYDATASIZE)-1]                                dir_arr_rd_data1;

   // Data Cache Config
   input                                                       xu_lq_spr_xucr0_cls;		// Data Cache Line Size Mode
   input                                                       xu_lq_spr_xucr0_cred;   // L2 Credit Control

   // ICBI ACK Enable
   input                                                       iu_lq_spr_iucr0_icbi_ack;

   // STQ4 Data for L2 write
   input [0:127]                                               dat_lsq_stq4_128data;

   // Instruction Fetches
   input [0:`THREADS-1]                                        iu_lq_request;
   input [0:1]                                                 iu_lq_cTag;
   input [64-`REAL_IFAR_WIDTH:59]                              iu_lq_ra;
   input [0:4]                                                 iu_lq_wimge;
   input [0:3]                                                 iu_lq_userdef;

   // ICBI Interface to IU
   output [0:`THREADS-1]                                       lq_iu_icbi_val;
   output [64-`REAL_IFAR_WIDTH:57]                             lq_iu_icbi_addr;
   input [0:`THREADS-1]                                        iu_lq_icbi_complete;

   // ICI Interace
   output                                                      lq_iu_ici_val;

   // MMU instruction interface
   input [0:`THREADS-1]                                        mm_lq_lsu_req;		   // will only pulse when mm has at least 1 token (1 bit per thread)
   input [0:1]                                                 mm_lq_lsu_ttype;		// 0=TLBIVAX, 1=TLBI_COMPLETE, 2=LOAD (tag=01100), 3=LOAD (tag=01101)
   input [0:4]                                                 mm_lq_lsu_wimge;
   input [0:3]                                                 mm_lq_lsu_u;		   // user defined bits
   input [64-`REAL_IFAR_WIDTH:63]                              mm_lq_lsu_addr;		// address for TLBI (or loads, maybe),

   // TLBI_COMPLETE is address-less
   input [0:7]                                                 mm_lq_lsu_lpid;		// muxed LPID for the thread of the mmu command
   input                                                       mm_lq_lsu_gs;
   input                                                       mm_lq_lsu_ind;
   input                                                       mm_lq_lsu_lbit;		// "L" bit, for large vs. small
   input [0:7]                                                 mm_lq_lsu_lpidr;
   output                                                      lq_mm_lsu_token;
   output [0:`THREADS-1]                                       lq_xu_quiesce;		   // Load and Store Queue is empty
   output [0:`THREADS-1]                                       lq_pc_ldq_quiesce;
   output [0:`THREADS-1]                                       lq_pc_stq_quiesce;
   output [0:`THREADS-1]                                       lq_pc_pfetch_quiesce;
   output                                                      lq_mm_lmq_stq_empty;

   // Zap Machine
   input [0:`THREADS-1]                                        iu_lq_cp_flush;

   // Next Itag Completion
   input [0:`THREADS-1]                                        iu_lq_recirc_val;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_cp_next_itag;

   // Complete iTag
   input [0:`THREADS-1]                                        iu_lq_i0_completed;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_i0_completed_itag;
   input [0:`THREADS-1]                                        iu_lq_i1_completed;
   input [0:(`ITAG_SIZE_ENC*`THREADS)-1]                       iu_lq_i1_completed_itag;

   // XER Read for long latency CP_NEXT ops stcx./icswx.
   input [0:`THREADS-1]                                        xu_lq_xer_cp_rd;

   // Sync Ack
   input [0:`THREADS-1]                                        an_ac_sync_ack;

   // Stcx Complete
   input [0:`THREADS-1]                                        an_ac_stcx_complete;
   input [0:`THREADS-1]                                        an_ac_stcx_pass;

   // ICBI ACK
   input                                                       an_ac_icbi_ack;
   input [0:1]                                                 an_ac_icbi_ack_thread;

   // Core ID
   input [6:7]                                                 an_ac_coreid;

   // L2 Interface Credit Control
   input                                                       an_ac_req_ld_pop;
   input                                                       an_ac_req_st_pop;
   input                                                       an_ac_req_st_gather;

   // L2 Interface Reload
   input                                                       an_ac_reld_data_vld;
   input [0:4]                                                 an_ac_reld_core_tag;
   input [58:59]                                               an_ac_reld_qw;
   input [0:127]                                               an_ac_reld_data;
   input                                                       an_ac_reld_data_coming;
   input                                                       an_ac_reld_ditc;
   input                                                       an_ac_reld_crit_qw;
   input                                                       an_ac_reld_l1_dump;
   input                                                       an_ac_reld_ecc_err;
   input                                                       an_ac_reld_ecc_err_ue;

   // L2 Interface Back Invalidate
   input                                                       an_ac_back_inv;
   input [64-`REAL_IFAR_WIDTH:63]                              an_ac_back_inv_addr;
   input                                                       an_ac_back_inv_target_bit1;
   input                                                       an_ac_back_inv_target_bit3;
   input                                                       an_ac_back_inv_target_bit4;
   input [0:3]                                                 an_ac_req_spare_ctrl_a1;

   // Credit Release to IU
   output [0:`THREADS-1]                                       lq_iu_credit_free;
   output [0:`THREADS-1]                                       sq_iu_credit_free;

   // Reservation Station Hold indicator
   output                                                      lsq_ctl_rv_hold_all;

   // Reservation station set barrier indicator
   output                                                      lsq_ctl_rv_set_hold;
   output [0:`THREADS-1]                                       lsq_ctl_rv_clr_hold;

   // STCX/ICSWX Itag Complete
   output                                                      lsq_ctl_stq_release_itag_vld;
   output [0:`ITAG_SIZE_ENC-1]                                 lsq_ctl_stq_release_itag;
   output [0:`THREADS-1]                                       lsq_ctl_stq_release_tid;

   // Store Queue Completion Report
   output                                                      lsq_ctl_stq_cpl_ready;
   output [0:`ITAG_SIZE_ENC-1]                                 lsq_ctl_stq_cpl_ready_itag;
   output [0:`THREADS-1]                                       lsq_ctl_stq_cpl_ready_tid;
   output                                                      lsq_ctl_stq_n_flush;
   output                                                      lsq_ctl_stq_np1_flush;
   output                                                      lsq_ctl_stq_exception_val;
   output [0:5]                                                lsq_ctl_stq_exception;
   output [0:3]                                                lsq_ctl_stq_dacrw;
   input                                                       ctl_lsq_stq_cpl_blk;
   input                                                       ctl_lsq_ex_pipe_full;

   // LOADMISS Queue RESTART indicator
   output                                                      lsq_ctl_ex5_ldq_restart;

   // Store Queue RESTART indicator
   output                                                      lsq_ctl_ex5_stq_restart;
   output                                                      lsq_ctl_ex5_stq_restart_miss;

   // Store Data Forward
   output                                                      lsq_ctl_ex5_fwd_val;
   output [(128-`STQ_DATA_SIZE):127]                           lsq_ctl_ex5_fwd_data;

   output                                                      lsq_ctl_sync_in_stq;
   output                                                      lsq_ctl_sync_done;

   // Interface to completion
   output [0:`THREADS-1]                                       lq1_iu_execute_vld;
   output [0:`ITAG_SIZE_ENC-1]                                 lq1_iu_itag;
   output                                                      lq1_iu_exception_val;
   output [0:5]                                                lq1_iu_exception;
   output                                                      lq1_iu_n_flush;
   output                                                      lq1_iu_np1_flush;
   output                                                      lq1_iu_dacr_type;
   output [0:3]                                                lq1_iu_dacrw;
   output [0:3]                                                lq1_iu_perf_events;

   // RELOAD/COMMIT Data Control
   output                                                      lsq_dat_stq1_stg_act;
   output                                                      lsq_dat_rel1_data_val;
   output [57:59]                                              lsq_dat_rel1_qw;		      // RELOAD Data Quadword
   output                                                      lsq_dat_stq1_val;
   output                                                      lsq_dat_stq1_mftgpr_val;
   output                                                      lsq_dat_stq1_store_val;
   output [0:15]                                               lsq_dat_stq1_byte_en;
   output [0:2]                                                lsq_dat_stq1_op_size;
   output [52:63]                                              lsq_dat_stq1_addr;
   output                                                      lsq_dat_stq1_le_mode;
   output                                                      lsq_dat_stq2_blk_req;
   output [0:143]                                              lsq_dat_stq2_store_data;

   // RELOAD/COMMIT Directory Control
   output                                                      lsq_ctl_stq1_stg_act;
   output [0:`THREADS-1]                                       lsq_ctl_oldest_tid;
   output [0:`ITAG_SIZE_ENC-1]                                 lsq_ctl_oldest_itag;
   output                                                      lsq_ctl_rel1_clr_val;		// Reload Data is valid, need to Pick a Way to update
   output                                                      lsq_ctl_rel1_set_val;		// Reload Data is valid for last beat, update Directory Contents and set Valid
   output                                                      lsq_ctl_rel1_data_val;		// Reload Data is Valid, need to update Way in Data Cache
   output                                                      lsq_ctl_rel1_back_inv;		// Reload was Back-Invalidated
   output [0:3]                                                lsq_ctl_rel1_tag;		      // Reload Tag
   output [0:1]                                                lsq_ctl_rel1_classid;		// Used to index into xucr2 RMT table
   output                                                      lsq_ctl_rel1_lock_set;		// Reload is for a dcbt[st]ls instruction
   output                                                      lsq_ctl_rel1_watch_set;		// Reload is for a ldawx. instruction
   output                                                      lsq_ctl_rel2_blk_req;		// Block Reload due to RV issue or Back-Invalidate
   output                                                      lsq_ctl_stq2_blk_req;		// Block Store due to RV issue
   output                                                      lsq_ctl_rel2_upd_val;		// all 8 data beats have transferred without error, set valid in dir
   output [0:127]                                              lsq_ctl_rel2_data;		   // Reload PRF update data
   output                                                      lsq_ctl_rel3_l1dump_val;	// Reload Complete for an L1_DUMP reload
   output                                                      lsq_ctl_rel3_clr_relq;		// Reload Complete due to an ECC error
   input                                                       ctl_lsq_stq4_perr_reject;  // STQ4 parity error detect, reject STQ2 Commit
   output                                                      lsq_ctl_stq1_val;
   output                                                      lsq_ctl_stq1_mftgpr_val;
   output                                                      lsq_ctl_stq1_mfdpf_val;
   output                                                      lsq_ctl_stq1_mfdpa_val;
   output [0:`THREADS-1]                                       lsq_ctl_stq1_thrd_id;
   output [0:`THREADS-1]                                       lsq_ctl_rel1_thrd_id;
   output                                                      lsq_ctl_stq1_store_val;
   output                                                      lsq_ctl_stq1_lock_clr;
   output                                                      lsq_ctl_stq1_watch_clr;
   output [0:1]                                                lsq_ctl_stq1_l_fld;
   output                                                      lsq_ctl_stq1_inval;
   output                                                      lsq_ctl_stq1_dci_val;
   output [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                    lsq_ctl_stq1_addr;
   output                                                      lsq_ctl_stq1_ci;
   output                                                      lsq_ctl_stq1_axu_val;
   output                                                      lsq_ctl_stq1_epid_val;
   output                                                      lsq_ctl_stq4_xucr0_cul;
   output [0:`ITAG_SIZE_ENC-1]                                 lsq_ctl_stq5_itag;
   output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lsq_ctl_stq5_tgpr;

   // RELOAD Register Control
   output                                                      lsq_ctl_rel1_gpr_val;		// Critical Quadword requires an update of the Regfile
   output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lsq_ctl_rel1_ta_gpr;		   // Reload Target Register
   output                                                      lsq_ctl_rel1_upd_gpr;		// Critical Quadword did not get and ECC error in REL1
   output                                                      lsq_ctl_stq1_resv;

   // Illegal LSWX has been determined
   output                                                      lsq_ctl_ex3_strg_val;		// STQ has checked XER valid
   output                                                      lsq_ctl_ex3_strg_noop;		// STQ detected a noop of LSWX/STSWX
   output                                                      lsq_ctl_ex3_illeg_lswx;		// STQ detected illegal form of LSWX
   output                                                      lsq_ctl_ex3_ct_val;		   // ICSWX Data is valid
   output [0:5]                                                lsq_ctl_ex3_be_ct;		   // Big Endian Coprocessor Type Select
   output [0:5]                                                lsq_ctl_ex3_le_ct;		   // Little Endian Coprocessor Type Select

   // release itag to pfetch
   output [0:`THREADS-1]                                       odq_pf_report_tid;
   output [0:`ITAG_SIZE_ENC-1]                                 odq_pf_report_itag;
   output                                                      odq_pf_resolved;

   // STCX Update
   output                                                      lq_xu_cr_l2_we;
   output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                 lq_xu_cr_l2_wa;
   output [0:`CR_WIDTH-1]                                      lq_xu_cr_l2_wd;

   // PRF update for reloads
   output                                                      lq_xu_axu_rel_le;

   // Back-Invalidate
   output                                                      lsq_ctl_rv0_back_inv;
   output [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                    lsq_ctl_rv1_back_inv_addr;

   // RV Reload Release Dependent ITAGs
   output [0:`THREADS-1]                                       lq_rv_itag2_vld;
   output [0:`ITAG_SIZE_ENC-1]                                 lq_rv_itag2;

   // Doorbell Interface
   output                                                      lq_xu_dbell_val;
   output [0:4]                                                lq_xu_dbell_type;
   output                                                      lq_xu_dbell_brdcast;
   output                                                      lq_xu_dbell_lpid_match;
   output [50:63]                                              lq_xu_dbell_pirtag;

   // L2 Interface Outputs
   output                                                      ac_an_req_pwr_token;
   output                                                      ac_an_req;
   output [64-`REAL_IFAR_WIDTH:63]                             ac_an_req_ra;
   output [0:5]                                                ac_an_req_ttype;
   output [0:2]                                                ac_an_req_thread;
   output                                                      ac_an_req_wimg_w;
   output                                                      ac_an_req_wimg_i;
   output                                                      ac_an_req_wimg_m;
   output                                                      ac_an_req_wimg_g;
   output                                                      ac_an_req_endian;
   output [0:3]                                                ac_an_req_user_defined;
   output [0:3]                                                ac_an_req_spare_ctrl_a0;
   output [0:4]                                                ac_an_req_ld_core_tag;
   output [0:2]                                                ac_an_req_ld_xfr_len;
   output [0:31]                                               ac_an_st_byte_enbl;
   output [0:255]                                              ac_an_st_data;
   output                                                      ac_an_st_data_pwr_token;

   // Interface to Pervasive Unit
   input                                                       pc_lq_inj_relq_parity;        // Inject Parity Error on the Reload Data Queue
   output                                                      lq_pc_err_relq_parity;        // Reload Data Queue Parity Error Detected
   output                                                      lq_pc_err_invld_reld;		   // Reload detected without Loadmiss waiting for reload or got extra beats for cacheable request
   output                                                      lq_pc_err_l2intrf_ecc;		   // Reload detected with an ECC error
   output                                                      lq_pc_err_l2intrf_ue;		   // Reload detected with an uncorrectable ECC error
   output                                                      lq_pc_err_l2credit_overrun;   // L2 Credits were Overrun

   // Pervasive


   inout                                                       vcs;


   inout                                                       vdd;


   inout                                                       gnd;

   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

   input [0:`NCLK_WIDTH-1]                                     nclk;
   input                                                       sg_2;
   input                                                       fce_2;
   input                                                       func_sl_thold_2;
   input                                                       func_nsl_thold_2;
   input                                                       func_slp_sl_thold_2;
   input                                                       pc_lq_ccflush_dc;
   input                                                       clkoff_dc_b;
   input                                                       d_mode_dc;
   input                                                       delay_lclkr_dc;
   input                                                       mpw1_dc_b;
   input                                                       mpw2_dc_b;
   input                                                       g8t_clkoff_dc_b;
   input                                                       g8t_d_mode_dc;
   input [0:4]                                                 g8t_delay_lclkr_dc;
   input [0:4]                                                 g8t_mpw1_dc_b;
   input                                                       g8t_mpw2_dc_b;
   input                                                       abst_sl_thold_2;
   input                                                       time_sl_thold_2;
   input                                                       ary_nsl_thold_2;
   input                                                       repr_sl_thold_2;
   input                                                       bolt_sl_thold_2;
   input                                                       bo_enable_2;
   input                                                       an_ac_scan_dis_dc_b;
   input                                                       an_ac_scan_diag_dc;
   input                                                       an_ac_lbist_ary_wrt_thru_dc;
   input                                                       pc_lq_abist_ena_dc;
   input                                                       pc_lq_abist_raw_dc_b;
   input                                                       pc_lq_bo_unload;
   input                                                       pc_lq_bo_repair;
   input                                                       pc_lq_bo_reset;
   input                                                       pc_lq_bo_shdata;
   input [8:13]                                                pc_lq_bo_select;
   output [8:13]                                               lq_pc_bo_fail;
   output [8:13]                                               lq_pc_bo_diagout;

   // G8T ABIST Control
   input                                                       pc_lq_abist_wl64_comp_ena;
   input                                                       pc_lq_abist_g8t_wenb;
   input                                                       pc_lq_abist_g8t1p_renb_0;
   input [0:3]                                                 pc_lq_abist_g8t_dcomp;
   input                                                       pc_lq_abist_g8t_bw_1;
   input                                                       pc_lq_abist_g8t_bw_0;
   input [0:3]                                                 pc_lq_abist_di_0;
   input [4:9]                                                 pc_lq_abist_waddr_0;
   input [3:8]                                                 pc_lq_abist_raddr_0;

   // SCAN Ports
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                                       abst_scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                                       time_scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                                       repr_scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:6]                                                 func_scan_in;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                                      abst_scan_out;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                                      time_scan_out;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                                      repr_scan_out;
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:6]                                                func_scan_out;

   //--------------------------
   // signals
   //--------------------------
   wire                                                        spr_xucr0_cls_d;
   wire                                                        spr_xucr0_cls_q;
   wire                                                        lsq_l2_pwrToken;
   wire                                                        lsq_l2_valid;
   wire [0:1]                                                  lsq_l2_tid;
   wire [64-`REAL_IFAR_WIDTH:63]                               lsq_l2_p_addr;
   wire [0:4]                                                  lsq_l2_wimge;
   wire [0:3]                                                  lsq_l2_usrDef;
   wire [0:15]                                                 lsq_l2_byteEn;
   wire [0:5]                                                  lsq_l2_ttype;
   wire [0:2]                                                  lsq_l2_opSize;
   wire [0:4]                                                  lsq_l2_coreTag;
   wire                                                        lsq_l2_dataToken;
   wire [0:127]                                                lsq_l2_st_data;
   wire                                                        an_ac_req_ld_pop_d;
   wire                                                        an_ac_req_ld_pop_q;
   wire                                                        an_ac_req_st_pop_d;
   wire                                                        an_ac_req_st_pop_q;
   wire                                                        an_ac_req_st_gather_d;
   wire                                                        an_ac_req_st_gather_q;
   wire                                                        an_ac_reld_data_vld_d;
   wire                                                        an_ac_reld_data_vld_q;
   wire                                                        an_ac_reld_data_vld_stg1_d;
   wire                                                        an_ac_reld_data_vld_stg1_q;
   wire [0:4]                                                  an_ac_reld_core_tag_d;
   wire [0:4]                                                  an_ac_reld_core_tag_q;
   wire [58:59]                                                an_ac_reld_qw_d;
   wire [58:59]                                                an_ac_reld_qw_q;
   wire [0:127]                                                an_ac_reld_data_d;
   wire [0:127]                                                an_ac_reld_data_q;
   wire                                                        an_ac_reld_data_coming_d;
   wire                                                        an_ac_reld_data_coming_q;
   wire                                                        an_ac_reld_ditc_d;
   wire                                                        an_ac_reld_ditc_q;
   wire                                                        an_ac_reld_crit_qw_d;
   wire                                                        an_ac_reld_crit_qw_q;
   wire                                                        an_ac_reld_l1_dump_d;
   wire                                                        an_ac_reld_l1_dump_q;
   wire                                                        an_ac_reld_ecc_err_d;
   wire                                                        an_ac_reld_ecc_err_q;
   wire                                                        an_ac_reld_ecc_err_ue_d;
   wire                                                        an_ac_reld_ecc_err_ue_q;
   wire                                                        an_ac_back_inv_d;
   wire                                                        an_ac_back_inv_q;
   wire [64-`REAL_IFAR_WIDTH:63]                               an_ac_back_inv_addr_d;
   wire [64-`REAL_IFAR_WIDTH:63]                               an_ac_back_inv_addr_q;
   wire                                                        an_ac_back_inv_target_bit1_d;
   wire                                                        an_ac_back_inv_target_bit1_q;
   wire                                                        an_ac_back_inv_target_bit3_d;
   wire                                                        an_ac_back_inv_target_bit3_q;
   wire                                                        an_ac_back_inv_target_bit4_d;
   wire                                                        an_ac_back_inv_target_bit4_q;
   wire [0:7]                                                  mm_lq_lsu_lpidr_d;
   wire [0:7]                                                  mm_lq_lsu_lpidr_q;
   wire                                                        l2_dbell_val_d;
   wire                                                        l2_dbell_val_q;
   wire                                                        l2_back_inv_val_d;
   wire                                                        l2_back_inv_val_q;
   wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      l2_back_inv_addr;
   wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      rv1_back_inv_addr_d;
   wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      rv1_back_inv_addr_q;
   wire [0:3]                                                  an_ac_req_spare_ctrl_a1_d;
   wire [0:3]                                                  an_ac_req_spare_ctrl_a1_q;
   wire                                                        l2_lsq_resp_isComing;
   wire                                                        l2_lsq_resp_val;
   wire [0:4]                                                  l2_lsq_resp_cTag;
   wire [57:59]                                                l2_lsq_resp_qw;
   wire                                                        l2_lsq_resp_crit_qw;
   wire                                                        l2_lsq_resp_l1_dump;
   wire [0:127]                                                l2_lsq_resp_data;
   wire                                                        l2_lsq_resp_ecc_err;
   wire                                                        l2_lsq_resp_ecc_err_ue;
   wire                                                        arb_stq_cred_avail;
   wire                                                        odq_ldq_n_flush;
   wire                                                        odq_ldq_np1_flush;
   wire                                                        odq_ldq_resolved;
   wire                                                        odq_ldq_report_needed;
   wire [0:`THREADS-1]                                         odq_ldq_report_tid;
   wire [0:3]                                                  odq_ldq_report_pEvents;
   wire [0:`ITAG_SIZE_ENC-1]                                   odq_ldq_report_itag;
   wire [0:3]                                                  odq_ldq_report_dacrw;
   wire                                                        odq_ldq_report_eccue;
   wire [0:`THREADS-1]                                         odq_ldq_oldest_ld_tid;
   wire [0:`ITAG_SIZE_ENC-1]                                   odq_ldq_oldest_ld_itag;
   wire                                                        odq_ldq_ex7_pfetch_blk;
   wire                                                        odq_stq_resolved;
   wire [0:`STQ_ENTRIES-1]                                     odq_stq_stTag;
   wire [0:`THREADS-1]                                         stq_ldq_empty;
   wire                                                        arb_ldq_ldq_unit_sel;
   wire                                                        arb_imq_iuq_unit_sel;
   wire                                                        arb_imq_mmq_unit_sel;
   wire                                                        imq_arb_iuq_ld_req_avail;
   wire [0:1]                                                  imq_arb_iuq_tid;
   wire [0:3]                                                  imq_arb_iuq_usr_def;
   wire [0:4]                                                  imq_arb_iuq_wimge;
   wire [64-`REAL_IFAR_WIDTH:63]                               imq_arb_iuq_p_addr;
   wire [0:5]                                                  imq_arb_iuq_ttype;
   wire [0:2]                                                  imq_arb_iuq_opSize;
   wire [0:4]                                                  imq_arb_iuq_cTag;
   wire                                                        imq_arb_mmq_ld_req_avail;
   wire                                                        imq_arb_mmq_st_req_avail;
   wire [0:1]                                                  imq_arb_mmq_tid;
   wire [0:3]                                                  imq_arb_mmq_usr_def;
   wire [0:4]                                                  imq_arb_mmq_wimge;
   wire [64-`REAL_IFAR_WIDTH:63]                               imq_arb_mmq_p_addr;
   wire [0:5]                                                  imq_arb_mmq_ttype;
   wire [0:2]                                                  imq_arb_mmq_opSize;
   wire [0:4]                                                  imq_arb_mmq_cTag;
   wire [0:15]                                                 imq_arb_mmq_st_data;
   wire                                                        ldq_arb_ld_req_pwrToken;
   wire                                                        ldq_arb_ld_req_avail;
   wire [0:1]                                                  ldq_arb_tid;
   wire [0:3]                                                  ldq_arb_usr_def;
   wire [0:4]                                                  ldq_arb_wimge;
   wire [64-`REAL_IFAR_WIDTH:63]                               ldq_arb_p_addr;
   wire [0:5]                                                  ldq_arb_ttype;
   wire [0:2]                                                  ldq_arb_opsize;
   wire [0:4]                                                  ldq_arb_cTag;
   wire                                                        stq_arb_st_req_avail;
   wire                                                        stq_arb_stq3_cmmt_val;
   wire                                                        stq_arb_stq3_cmmt_reject;
   wire                                                        stq_arb_stq3_req_val;
   wire [0:1]                                                  stq_arb_stq3_tid;
   wire [0:3]                                                  stq_arb_stq3_usrDef;
   wire [0:4]                                                  stq_arb_stq3_wimge;
   wire [64-`REAL_IFAR_WIDTH:63]                               stq_arb_stq3_p_addr;
   wire [0:5]                                                  stq_arb_stq3_ttype;
   wire [0:2]                                                  stq_arb_stq3_opSize;
   wire [0:15]                                                 stq_arb_stq3_byteEn;
   wire [0:4]                                                  stq_arb_stq3_cTag;
   wire [0:`LMQ_ENTRIES-1]                                     ldq_stq_ex5_ldm_hit;
   wire [0:`LMQ_ENTRIES-1]                                     ldq_stq_ex5_ldm_entry;
   wire [0:`LMQ_ENTRIES-1]                                     ldq_stq_ldm_cpl;
   wire                                                        ldq_stq_stq4_dir_upd;
   wire [64-(`DC_SIZE-3):57]                                   ldq_stq_stq4_cclass;
   wire [0:`STQ_ENTRIES_ENC-1]                                 stq_odq_i0_stTag;
   wire [0:`STQ_ENTRIES_ENC-1]                                 stq_odq_i1_stTag;
   wire                                                        stq_odq_stq4_stTag_inval;
   wire [0:`STQ_ENTRIES_ENC-1]                                 stq_odq_stq4_stTag;
   wire                                                        odq_stq_ex2_nxt_oldest_val;
   wire [0:`STQ_ENTRIES-1]                                     odq_stq_ex2_nxt_oldest_stTag;
   wire                                                        odq_stq_ex2_nxt_youngest_val;
   wire [0:`STQ_ENTRIES-1]                                     odq_stq_ex2_nxt_youngest_stTag;
   wire                                                        ldq_stq_rel1_blk_store;
   wire [0:127]                                                ldq_arb_rel1_data;
   wire                                                        ldq_arb_rel1_axu_val;
   wire [0:2]                                                  ldq_arb_rel1_op_size;
   wire [64-`REAL_IFAR_WIDTH:63]                               ldq_arb_rel1_addr;
   wire                                                        ldq_arb_rel1_ci;
   wire                                                        ldq_arb_rel1_byte_swap;
   wire [0:`THREADS-1]                                         ldq_arb_rel1_thrd_id;
   wire                                                        ldq_arb_rel2_rdat_sel;
   wire [0:143]                                                ldq_arb_rel2_rd_data;
   wire [0:143]                                                arb_ldq_rel2_wrt_data;
   wire                                                        stq_arb_stq1_axu_val;
   wire                                                        stq_arb_stq1_epid_val;
   wire [0:2]                                                  stq_arb_stq1_opSize;
   wire [64-`REAL_IFAR_WIDTH:63]                               stq_arb_stq1_p_addr;
   wire                                                        stq_arb_stq1_wimge_i;
   wire [(128-`STQ_DATA_SIZE):127]                             stq_arb_stq1_store_data;
   wire                                                        stq_arb_stq1_byte_swap;
   wire [0:`THREADS-1]                                         stq_arb_stq1_thrd_id;
   wire                                                        stq_arb_release_itag_vld;
   wire [0:`ITAG_SIZE_ENC-1]                                   stq_arb_release_itag;
   wire [0:`THREADS-1]                                         stq_arb_release_tid;
   wire                                                        ldq_rel2_blk_req;
   wire                                                        stq_stq2_blk_req;
   wire                                                        ldq_hold_all_req;
   wire                                                        stq_hold_all_req;
   wire                                                        ldq_rv_set_hold;
   wire                                                        stq_rv_set_hold;
   wire [0:`THREADS-1]                                         ldq_rv_clr_hold;
   wire [0:`THREADS-1]                                         stq_rv_clr_hold;
   wire [0:`THREADS-1]                                         an_ac_sync_ack_d;
   wire [0:`THREADS-1]                                         an_ac_sync_ack_q;
   wire [0:`THREADS-1]                                         an_ac_stcx_complete_d;
   wire [0:`THREADS-1]                                         an_ac_stcx_complete_q;
   wire [0:`THREADS-1]                                         an_ac_stcx_pass_d;
   wire [0:`THREADS-1]                                         an_ac_stcx_pass_q;
   wire                                                        an_ac_icbi_ack_d;
   wire                                                        an_ac_icbi_ack_q;
   wire [0:1]                                                  an_ac_icbi_ack_thread_d;
   wire [0:1]                                                  an_ac_icbi_ack_thread_q;
   wire [6:7]                                                  an_ac_coreid_d;
   wire [6:7]                                                  an_ac_coreid_q;
   wire                                                        ldq_odq_vld;
   wire                                                        ldq_odq_pfetch_vld;
   wire                                                        ldq_odq_wimge_i;
   wire [0:3]                                                  ldq_odq_ex6_pEvents;
   wire                                                        ldq_odq_hit;
   wire                                                        ldq_odq_fwd;
   wire                                                        ldq_odq_inv_d;
   wire                                                        ldq_odq_inv_q;
   wire [64-`REAL_IFAR_WIDTH:59]                               ldq_odq_addr_d;
   wire [64-`REAL_IFAR_WIDTH:59]                               ldq_odq_addr_q;
   wire [0:`ITAG_SIZE_ENC-1]                                   ldq_odq_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]                                   ldq_odq_itag_q;
   wire                                                        ldq_odq_cline_chk_d;
   wire                                                        ldq_odq_cline_chk_q;
   wire                                                        ldq_odq_upd_val;
   wire [0:`ITAG_SIZE_ENC-1]                                   ldq_odq_upd_itag;
   wire                                                        ldq_odq_upd_nFlush;
   wire                                                        ldq_odq_upd_np1Flush;
   wire [0:`THREADS-1]                                         ldq_odq_upd_tid;
   wire [0:3]                                                  ldq_odq_upd_dacrw;
   wire                                                        ldq_odq_upd_eccue;
   wire [0:3]                                                  ldq_odq_upd_pEvents;
   wire                                                        ldq_rel2_byte_swap;
   wire [0:127]                                                ldq_rel2_data;
   wire                                                        stq_ldq_ex5_stq_restart;
   wire                                                        stq_ldq_ex5_stq_restart_miss;
   wire                                                        stq_ldq_ex5_fwd_val;
   wire [0:`ITAG_SIZE_ENC-1]                                   ex3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]                                   ex3_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                                   ex4_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]                                   ex4_itag_q;
   wire [0:15]                                                 ex4_byte_en_d;
   wire [0:15]                                                 ex4_byte_en_q;
   wire [0:15]                                                 ex5_byte_en_d;
   wire [0:15]                                                 ex5_byte_en_q;
   wire [64-`REAL_IFAR_WIDTH:63]                               ex4_p_addr;
   wire [58:63]                                                ex4_p_addr_d;
   wire [58:63]                                                ex4_p_addr_q;
   wire [0:`THREADS-1]                                         ex4_thrd_id_d;
   wire [0:`THREADS-1]                                         ex4_thrd_id_q;
   wire [0:`THREADS-1]                                         ex5_thrd_id_d;
   wire [0:`THREADS-1]                                         ex5_thrd_id_q;
   wire [0:`THREADS-1]                                         ex6_thrd_id_d;
   wire [0:`THREADS-1]                                         ex6_thrd_id_q;
   wire [0:`THREADS-1]                                         ex7_thrd_id_d;
   wire [0:`THREADS-1]                                         ex7_thrd_id_q;
   wire [0:`THREADS-1]                                         ex4_streq_val;
   wire                                                        ex3_ldreq_val;
   wire                                                        ex4_algebraic_d;
   wire                                                        ex4_algebraic_q;
   wire                                                        ex5_algebraic_d;
   wire                                                        ex5_algebraic_q;
   wire [0:2]                                                  ex4_opsize_d;
   wire [0:2]                                                  ex4_opsize_q;
   wire [0:2]                                                  ex5_opsize_d;
   wire [0:2]                                                  ex5_opsize_q;
   wire                                                        ex5_dreq_val_d;
   wire                                                        ex5_dreq_val_q;
   wire [64-(`DC_SIZE-3):63-`CL_SIZE]                          dir_arr_rd_addr1;
   wire                                                        ldq_arb_rel1_data_sel;
   wire                                                        ldq_ctl_stq1_stg_act;
   wire                                                        stq_ctl_stq1_stg_act;
   wire                                                        ldq_dat_stq1_stg_act;
   wire                                                        stq_dat_stq1_stg_act;

   wire                                                        func_nsl_thold_1;
   wire                                                        func_sl_thold_1;
   wire                                                        func_slp_sl_thold_1;
   wire                                                        sg_1;
   wire                                                        fce_1;
   wire                                                        func_nsl_thold_0;
   wire                                                        func_sl_thold_0;
   wire                                                        func_slp_sl_thold_0;
   wire                                                        sg_0;
   wire                                                        fce_0;
   wire                                                        func_nsl_thold_0_b;
   wire                                                        func_sl_thold_0_b;
   wire                                                        func_slp_sl_thold_0_b;
   wire                                                        func_nsl_force;
   wire                                                        func_sl_force;
   wire                                                        func_slp_sl_force;
   wire                                                        abst_scan_in_q;
   wire [0:2]                                                  abst_scan_out_int;
   wire [0:2]                                                  abst_scan_out_q;
   wire                                                        time_scan_in_q;
   wire [0:1]                                                  time_scan_out_int;
   wire [0:1]                                                  time_scan_out_q;
   wire                                                        repr_scan_in_q;
   wire [0:1]                                                  repr_scan_out_int;
   wire [0:1]                                                  repr_scan_out_q;
   wire [0:6]                                                  func_scan_in_q;
   wire [0:6]                                                  func_scan_out_int;
   wire [0:6]                                                  func_scan_out_q;
   wire                                                        arb_func_scan_out;
   wire [0:24]                                                 abist_siv;
   wire [0:24]                                                 abist_sov;
   wire                                                        abst_sl_thold_1;
   wire                                                        time_sl_thold_1;
   wire                                                        ary_nsl_thold_1;
   wire                                                        repr_sl_thold_1;
   wire                                                        bolt_sl_thold_1;
   wire                                                        abst_sl_thold_0;
   wire                                                        time_sl_thold_0;
   wire                                                        ary_nsl_thold_0;
   wire                                                        repr_sl_thold_0;
   wire                                                        bolt_sl_thold_0;
   wire                                                        abst_sl_thold_0_b;
   wire                                                        abst_sl_force;
   wire                                                        pc_lq_abist_wl64_comp_ena_q;
   wire [3:8]                                                  pc_lq_abist_raddr_0_q;
   wire                                                        pc_lq_abist_g8t_wenb_q;
   wire                                                        pc_lq_abist_g8t1p_renb_0_q;
   wire [0:3]                                                  pc_lq_abist_g8t_dcomp_q;
   wire                                                        pc_lq_abist_g8t_bw_1_q;
   wire                                                        pc_lq_abist_g8t_bw_0_q;
   wire [0:3]                                                  pc_lq_abist_di_0_q;
   wire [4:9]                                                  pc_lq_abist_waddr_0_q;
   wire                                                        slat_force;
   wire                                                        abst_slat_thold_b;
   wire                                                        abst_slat_d2clk;
   wire  [0:`NCLK_WIDTH-1]                                     abst_slat_lclk;
   wire                                                        time_slat_thold_b;
   wire                                                        time_slat_d2clk;
   wire  [0:`NCLK_WIDTH-1]                                     time_slat_lclk;
   wire                                                        repr_slat_thold_b;
   wire                                                        repr_slat_d2clk;
   wire  [0:`NCLK_WIDTH-1]                                     repr_slat_lclk;
   wire                                                        func_slat_thold_b;
   wire                                                        func_slat_d2clk;
   wire  [0:`NCLK_WIDTH-1]                                     func_slat_lclk;

   wire [0:3]                                                   abst_scan_q;
   wire [0:3]                                                   abst_scan_q_b;
   wire [0:2]                                                   time_scan_q;
   wire [0:2]                                                   time_scan_q_b;
   wire [0:2]                                                   repr_scan_q;
   wire [0:2]                                                   repr_scan_q_b;
   wire [0:13]                                                  func_scan_q;
   wire [0:13]                                                  func_scan_q_b;

   //--------------------------
   // constants
   //--------------------------

   parameter                                                   ldq_odq_inv_offset = 0;
   parameter                                                   ldq_odq_addr_offset = ldq_odq_inv_offset + 1;
   parameter                                                   ldq_odq_itag_offset = ldq_odq_addr_offset + (`REAL_IFAR_WIDTH-4);
   parameter                                                   ldq_odq_cline_chk_offset = ldq_odq_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex3_itag_offset = ldq_odq_cline_chk_offset + 1;
   parameter                                                   ex4_itag_offset = ex3_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex4_byte_en_offset = ex4_itag_offset + `ITAG_SIZE_ENC;
   parameter                                                   ex5_byte_en_offset = ex4_byte_en_offset + 16;
   parameter                                                   ex4_p_addr_offset = ex5_byte_en_offset + 16;
   parameter                                                   ex4_thrd_id_offset = ex4_p_addr_offset + 6;
   parameter                                                   ex5_thrd_id_offset = ex4_thrd_id_offset + `THREADS;
   parameter                                                   ex6_thrd_id_offset = ex5_thrd_id_offset + `THREADS;
   parameter                                                   ex7_thrd_id_offset = ex6_thrd_id_offset + `THREADS;
   parameter                                                   ex4_algebraic_offset = ex7_thrd_id_offset + `THREADS;
   parameter                                                   ex5_algebraic_offset = ex4_algebraic_offset + 1;
   parameter                                                   ex4_opsize_offset = ex5_algebraic_offset + 1;
   parameter                                                   ex5_opsize_offset = ex4_opsize_offset + 3;
   parameter                                                   ex5_dreq_val_offset = ex5_opsize_offset + 3;
   parameter                                                   spr_xucr0_cls_offset = ex5_dreq_val_offset + 1;
   parameter                                                   an_ac_req_ld_pop_offset = spr_xucr0_cls_offset + 1;
   parameter                                                   an_ac_req_st_pop_offset = an_ac_req_ld_pop_offset + 1;
   parameter                                                   an_ac_req_st_gather_offset = an_ac_req_st_pop_offset + 1;
   parameter                                                   an_ac_reld_data_vld_offset = an_ac_req_st_gather_offset + 1;
   parameter                                                   an_ac_reld_data_vld_stg1_offset = an_ac_reld_data_vld_offset + 1;
   parameter                                                   an_ac_reld_data_coming_offset = an_ac_reld_data_vld_stg1_offset + 1;
   parameter                                                   an_ac_reld_ditc_offset = an_ac_reld_data_coming_offset + 1;
   parameter                                                   an_ac_reld_crit_qw_offset = an_ac_reld_ditc_offset + 1;
   parameter                                                   an_ac_reld_l1_dump_offset = an_ac_reld_crit_qw_offset + 1;
   parameter                                                   an_ac_reld_ecc_err_offset = an_ac_reld_l1_dump_offset + 1;
   parameter                                                   an_ac_reld_ecc_err_ue_offset = an_ac_reld_ecc_err_offset + 1;
   parameter                                                   an_ac_back_inv_offset = an_ac_reld_ecc_err_ue_offset + 1;
   parameter                                                   an_ac_back_inv_target_bit1_offset = an_ac_back_inv_offset + 1;
   parameter                                                   an_ac_back_inv_target_bit3_offset = an_ac_back_inv_target_bit1_offset + 1;
   parameter                                                   an_ac_back_inv_target_bit4_offset = an_ac_back_inv_target_bit3_offset + 1;
   parameter                                                   mm_lq_lsu_lpidr_offset = an_ac_back_inv_target_bit4_offset + 1;
   parameter                                                   l2_dbell_val_offset = mm_lq_lsu_lpidr_offset + 8;
   parameter                                                   l2_back_inv_val_offset = l2_dbell_val_offset + 1;
   parameter                                                   rv1_back_inv_addr_offset = l2_back_inv_val_offset + 1;
   parameter                                                   an_ac_req_spare_ctrl_a1_offset = rv1_back_inv_addr_offset + (63-`CL_SIZE-(64-`REAL_IFAR_WIDTH)+1);
   parameter                                                   an_ac_reld_core_tag_offset = an_ac_req_spare_ctrl_a1_offset + 4;
   parameter                                                   an_ac_reld_qw_offset = an_ac_reld_core_tag_offset + 5;
   parameter                                                   an_ac_reld_data_offset = an_ac_reld_qw_offset + 2;
   parameter                                                   an_ac_back_inv_addr_offset = an_ac_reld_data_offset + 128;
   parameter                                                   an_ac_sync_ack_offset = an_ac_back_inv_addr_offset + `REAL_IFAR_WIDTH;
   parameter                                                   an_ac_stcx_complete_offset = an_ac_sync_ack_offset + `THREADS;
   parameter                                                   an_ac_stcx_pass_offset = an_ac_stcx_complete_offset + `THREADS;
   parameter                                                   an_ac_icbi_ack_offset = an_ac_stcx_pass_offset + `THREADS;
   parameter                                                   an_ac_icbi_ack_thread_offset = an_ac_icbi_ack_offset + 1;
   parameter                                                   an_ac_coreid_offset = an_ac_icbi_ack_thread_offset + 2;
   parameter                                                   scan_right = an_ac_coreid_offset + 2 - 1;

   wire [0:scan_right]                                         siv;
   wire [0:scan_right]                                         sov;
   wire                                                        tiup;
   wire                                                        tidn;

   (* analysis_not_referenced="true" *)
   wire                                                        unused;


   //!! Bugspray Include: lq_lsq

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Inputs
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   assign tiup = 1'b1;
   assign tidn = 1'b0;

   assign unused = |abst_scan_q | |abst_scan_q_b | |time_scan_q | |time_scan_q_b |
                   |repr_scan_q | |repr_scan_q_b | |func_scan_q | |func_scan_q_b;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // XU Config Bits
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   // XUCR0[CLS] 128 Byte Cacheline Enabled
   // 1 => 128 Byte Cacheline
   // 0 => 64 Byte Cacheline
   assign spr_xucr0_cls_d = xu_lq_spr_xucr0_cls;

   assign an_ac_sync_ack_d        = an_ac_sync_ack;
   assign an_ac_stcx_complete_d   = an_ac_stcx_complete;
   assign an_ac_stcx_pass_d       = an_ac_stcx_pass;
   assign an_ac_icbi_ack_d        = an_ac_icbi_ack;
   assign an_ac_icbi_ack_thread_d = an_ac_icbi_ack_thread;
   assign an_ac_coreid_d          = an_ac_coreid;
   assign an_ac_req_ld_pop_d      = an_ac_req_ld_pop;
   assign an_ac_req_st_pop_d      = an_ac_req_st_pop;
   assign an_ac_req_st_gather_d   = an_ac_req_st_gather;

   assign an_ac_reld_data_vld_d    = an_ac_reld_data_vld;
   assign an_ac_reld_core_tag_d    = an_ac_reld_core_tag;
   assign an_ac_reld_qw_d          = an_ac_reld_qw;
   assign an_ac_reld_data_d        = an_ac_reld_data;
   assign an_ac_reld_data_coming_d = an_ac_reld_data_coming;
   assign an_ac_reld_ditc_d        = an_ac_reld_ditc;
   assign an_ac_reld_crit_qw_d     = an_ac_reld_crit_qw;
   assign an_ac_reld_l1_dump_d     = an_ac_reld_l1_dump;
   assign an_ac_reld_ecc_err_d     = an_ac_reld_ecc_err;
   assign an_ac_reld_ecc_err_ue_d  = an_ac_reld_ecc_err_ue;

   assign an_ac_back_inv_d             = an_ac_back_inv;
   assign an_ac_back_inv_addr_d        = an_ac_back_inv_addr;
   assign an_ac_back_inv_target_bit1_d = an_ac_back_inv_target_bit1;
   assign an_ac_back_inv_target_bit3_d = an_ac_back_inv_target_bit3;
   assign an_ac_back_inv_target_bit4_d = an_ac_back_inv_target_bit4;
   assign an_ac_req_spare_ctrl_a1_d    = an_ac_req_spare_ctrl_a1;
   assign l2_back_inv_val_d            = an_ac_back_inv_q & an_ac_back_inv_target_bit1_q;
   // Forcing bit (57) to 1 when running in 128Byte cache line mode
   assign l2_back_inv_addr    = {an_ac_back_inv_addr_q[64 - `REAL_IFAR_WIDTH:63 - `CL_SIZE - 1], (an_ac_back_inv_addr_q[63 - `CL_SIZE] | spr_xucr0_cls_q)};
   assign rv1_back_inv_addr_d = l2_back_inv_addr;

   // Early inputs to LSQ
   assign ex3_itag_d      = ctl_lsq_ex2_itag;
   assign ex4_itag_d      = ex3_itag_q;
   assign ex4_byte_en_d   = ctl_lsq_ex3_byte_en;
   assign ex5_byte_en_d   = ex4_byte_en_q;
   assign ex4_p_addr_d    = ctl_lsq_ex3_p_addr;
   assign ex4_p_addr      = {ctl_lsq_ex4_p_addr, ex4_p_addr_q[58:63]};
   assign ex4_thrd_id_d   = ctl_lsq_ex3_thrd_id;
   assign ex5_thrd_id_d   = ex4_thrd_id_q;
   assign ex6_thrd_id_d   = ex5_thrd_id_q;
   assign ex7_thrd_id_d   = ex6_thrd_id_q;
   assign ex4_streq_val   = ex4_thrd_id_q & {`THREADS{ctl_lsq_ex4_streq_val}};
   assign ex3_ldreq_val   = |(ctl_lsq_ex3_ldreq_val);
   assign ex4_algebraic_d = ctl_lsq_ex3_algebraic;
   assign ex5_algebraic_d = ex4_algebraic_q;
   assign ex4_opsize_d    = ctl_lsq_ex3_opsize;
   assign ex5_opsize_d    = ex4_opsize_q;
   assign ex5_dreq_val_d  = ctl_lsq_ex4_dReq_val;

   // Order Queue Inputs
   assign ldq_odq_hit         = ctl_lsq_ex5_load_hit | ex5_dreq_val_q | stq_ldq_ex5_fwd_val;
   assign ldq_odq_fwd         = stq_ldq_ex5_fwd_val;
   assign ldq_odq_inv_d       = ctl_lsq_ex4_binvreq_val;
   assign ldq_odq_addr_d      = ex4_p_addr[64 - `REAL_IFAR_WIDTH:59];
   assign ldq_odq_itag_d      = ex4_itag_q;
   assign ldq_odq_cline_chk_d = ctl_lsq_ex4_cline_chk;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // DOORBELL DETECT
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   assign mm_lq_lsu_lpidr_d      = mm_lq_lsu_lpidr;
   assign l2_dbell_val_d         = an_ac_back_inv_q & an_ac_back_inv_target_bit4_q;
   assign lq_xu_dbell_val        = l2_dbell_val_q;
   assign lq_xu_dbell_type       = an_ac_back_inv_addr_q[32:36];
   assign lq_xu_dbell_brdcast    = an_ac_back_inv_addr_q[37];
   assign lq_xu_dbell_lpid_match = (an_ac_back_inv_addr_q[42:49] == mm_lq_lsu_lpidr_q) | ((~(|(an_ac_back_inv_addr_q[42:49]))));
   assign lq_xu_dbell_pirtag     = an_ac_back_inv_addr_q[50:63];

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // DIRECTORY ARRAYS
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   assign dir_arr_rd_addr1 = stq_arb_stq1_p_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE];

   generate
      if (`DC_SIZE == 15 & `CL_SIZE == 6)
      begin : dc32Kdir64B

         // number of addressable register in this array
         // width of the bus to address all ports (2^portadrbus_width >= addressable_ports)
         // bitwidth of ports
         // number of ways
         tri_64x34_8w_1r1w #(.addressable_ports(64), .addressbus_width(6), .port_bitwidth(WAYDATASIZE), .ways(8)) arr(
            // POWER PINS
            .vcs(vdd),
            .vdd(vdd),
            .gnd(gnd),

            // CLOCK AND CLOCKCONTROL PORTS
            .nclk(nclk),
            .rd_act(stq_ctl_stq1_stg_act),
            .wr_act(tiup),
            .sg_0(sg_0),
            .abst_sl_thold_0(abst_sl_thold_0),
            .ary_nsl_thold_0(ary_nsl_thold_0),
            .time_sl_thold_0(time_sl_thold_0),
            .repr_sl_thold_0(repr_sl_thold_0),
            .func_sl_force(func_sl_force),               // Does not use Sleep THOLDS, This copy is not active while in sleep mode
            .func_sl_thold_0_b(func_sl_thold_0_b),       // Does not use Sleep THOLDS, This copy is not active while in sleep mode
            .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
            .ccflush_dc(pc_lq_ccflush_dc),
            .scan_dis_dc_b(an_ac_scan_dis_dc_b),
            .scan_diag_dc(an_ac_scan_diag_dc),
            .g8t_d_mode_dc(g8t_d_mode_dc),
            .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
            .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
            .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
            .d_mode_dc(d_mode_dc),
            .mpw1_dc_b(mpw1_dc_b),
            .mpw2_dc_b(mpw2_dc_b),
            .delay_lclkr_dc(delay_lclkr_dc),

            // ABIST
            .wr_abst_act(pc_lq_abist_g8t_wenb_q),
            .rd0_abst_act(pc_lq_abist_g8t1p_renb_0_q),
            .abist_di(pc_lq_abist_di_0_q),
            .abist_bw_odd(pc_lq_abist_g8t_bw_1_q),
            .abist_bw_even(pc_lq_abist_g8t_bw_0_q),
            .abist_wr_adr(pc_lq_abist_waddr_0_q),
            .abist_rd0_adr(pc_lq_abist_raddr_0_q[3:8]),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_ena_1(pc_lq_abist_ena_dc),
            .abist_g8t_rd0_comp_ena(pc_lq_abist_wl64_comp_ena_q),
            .abist_raw_dc_b(pc_lq_abist_raw_dc_b),
            .obs0_abist_cmp(pc_lq_abist_g8t_dcomp_q),

            // SCAN PORTS
            .abst_scan_in(abst_scan_in_q),
            .time_scan_in(time_scan_in_q),
            .repr_scan_in(repr_scan_in_q),
            .func_scan_in(arb_func_scan_out),
            .abst_scan_out(abst_scan_out_int[0]),
            .time_scan_out(time_scan_out_int[0]),
            .repr_scan_out(repr_scan_out_int[0]),
            .func_scan_out(func_scan_out_int[4]),

            // BOLT-ON
            .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
            .pc_bo_enable_2(bo_enable_2),
            .pc_bo_reset(pc_lq_bo_reset),
            .pc_bo_unload(pc_lq_bo_unload),
            .pc_bo_repair(pc_lq_bo_repair),
            .pc_bo_shdata(pc_lq_bo_shdata),
            .pc_bo_select(pc_lq_bo_select[10:13]),
            .bo_pc_failout(lq_pc_bo_fail[10:13]),
            .bo_pc_diagloop(lq_pc_bo_diagout[10:13]),
            .tri_lcb_mpw1_dc_b(mpw1_dc_b),
            .tri_lcb_mpw2_dc_b(mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(delay_lclkr_dc),
            .tri_lcb_clkoff_dc_b(clkoff_dc_b),
            .tri_lcb_act_dis_dc(tidn),

            // Write Ports
            .write_enable(dir_arr_wr_enable),
            .way(dir_arr_wr_way),
            .addr_wr(dir_arr_wr_addr),
            .data_in(dir_arr_wr_data),

            // Read Ports
            .addr_rd_01(dir_arr_rd_addr1),
            .addr_rd_23(dir_arr_rd_addr1),
            .addr_rd_45(dir_arr_rd_addr1),
            .addr_rd_67(dir_arr_rd_addr1),
            .data_out(dir_arr_rd_data1)
         );
      end
   endgenerate

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // ORDER QUEUE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   lq_odq  odq(

      //   IU interface to RV for instruction insertion
      // port 0
      .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
      .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
      .rv_lq_rv1_i0_s3_t(rv_lq_rv1_i0_s3_t),
      .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
      .rv_lq_rv1_i0_isStore(rv_lq_rv1_i0_isStore),
      .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
      .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
      .rv_lq_rv1_i0_rte_sq(rv_lq_rv1_i0_rte_sq),

      // port 1
      .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
      .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
      .rv_lq_rv1_i1_s3_t(rv_lq_rv1_i1_s3_t),
      .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
      .rv_lq_rv1_i1_isStore(rv_lq_rv1_i1_isStore),
      .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
      .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
      .rv_lq_rv1_i1_rte_sq(rv_lq_rv1_i1_rte_sq),

      .ldq_odq_vld(ldq_odq_vld),
      .ldq_odq_pfetch_vld(ldq_odq_pfetch_vld),
      .ldq_odq_tid(ex5_thrd_id_q),
      .ldq_odq_wimge_i(ldq_odq_wimge_i),
      .ldq_odq_inv(ldq_odq_inv_q),
      .ldq_odq_hit(ldq_odq_hit),
      .ldq_odq_fwd(ldq_odq_fwd),
      .ldq_odq_addr(ldq_odq_addr_q),
      .ldq_odq_bytemask(ex5_byte_en_q),
      .ldq_odq_itag(ldq_odq_itag_q),
      .ldq_odq_cline_chk(ldq_odq_cline_chk_q),
      .ldq_odq_ex6_pEvents(ldq_odq_ex6_pEvents),
      .ctl_lsq_ex6_ldh_dacrw(ctl_lsq_ex6_ldh_dacrw),

      // Update Order Queue Entry when reload is complete and itag is not resolved
      .ldq_odq_upd_val(ldq_odq_upd_val),
      .ldq_odq_upd_itag(ldq_odq_upd_itag),
      .ldq_odq_upd_nFlush(ldq_odq_upd_nFlush),
      .ldq_odq_upd_np1Flush(ldq_odq_upd_np1Flush),
      .ldq_odq_upd_tid(ldq_odq_upd_tid),
      .ldq_odq_upd_dacrw(ldq_odq_upd_dacrw),
      .ldq_odq_upd_eccue(ldq_odq_upd_eccue),
      .ldq_odq_upd_pEvents(ldq_odq_upd_pEvents),

      .odq_ldq_n_flush(odq_ldq_n_flush),
      .odq_ldq_np1_flush(odq_ldq_np1_flush),
      .odq_ldq_resolved(odq_ldq_resolved),
      .odq_ldq_report_needed(odq_ldq_report_needed),
      .odq_ldq_report_itag(odq_ldq_report_itag),
      .odq_ldq_oldest_ld_tid(odq_ldq_oldest_ld_tid),
      .odq_ldq_oldest_ld_itag(odq_ldq_oldest_ld_itag),
      .odq_ldq_ex7_pfetch_blk(odq_ldq_ex7_pfetch_blk),
      .odq_ldq_report_tid(odq_ldq_report_tid),
      .odq_ldq_report_dacrw(odq_ldq_report_dacrw),
      .odq_ldq_report_eccue(odq_ldq_report_eccue),
      .odq_ldq_report_pEvents(odq_ldq_report_pEvents),
      .odq_stq_resolved(odq_stq_resolved),
      .odq_stq_stTag(odq_stq_stTag),
      .lsq_ctl_oldest_tid(lsq_ctl_oldest_tid),
      .lsq_ctl_oldest_itag(lsq_ctl_oldest_itag),

      // Age Detection
      // need to determine age for this load in ex2
      .ctl_lsq_ex2_thrd_id(ctl_lsq_ex2_thrd_id),
      .ctl_lsq_ex2_itag(ctl_lsq_ex2_itag),

      // store tag used when instruction was inserted to store queue
      .stq_odq_i0_stTag(stq_odq_i0_stTag),
      .stq_odq_i1_stTag(stq_odq_i1_stTag),

      // store tag is committed, remove from order queue and dont compare against it
      .stq_odq_stq4_stTag_inval(stq_odq_stq4_stTag_inval),
      .stq_odq_stq4_stTag(stq_odq_stq4_stTag),

      // order queue closest oldest store to the ex2 load request
      .odq_stq_ex2_nxt_oldest_val(odq_stq_ex2_nxt_oldest_val),
      .odq_stq_ex2_nxt_oldest_stTag(odq_stq_ex2_nxt_oldest_stTag),

      // order queue closest youngest store to the ex2 load request
      .odq_stq_ex2_nxt_youngest_val(odq_stq_ex2_nxt_youngest_val),
      .odq_stq_ex2_nxt_youngest_stTag(odq_stq_ex2_nxt_youngest_stTag),

      // CP_NEXT Itag
      .iu_lq_cp_next_itag(iu_lq_cp_next_itag),

      // Commit Report
      .iu_lq_i0_completed(iu_lq_i0_completed),
      .iu_lq_i0_completed_itag(iu_lq_i0_completed_itag),
      .iu_lq_i1_completed(iu_lq_i1_completed),
      .iu_lq_i1_completed_itag(iu_lq_i1_completed_itag),

      // Back-Invalidate Valid
      .l2_back_inv_val(l2_back_inv_val_q),
      .l2_back_inv_addr(l2_back_inv_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),

      // Zap Machine
      .iu_lq_cp_flush(iu_lq_cp_flush),

      // return credit to iu
      .lq_iu_credit_free(lq_iu_credit_free),

      // mode bit
      .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),

      // Performance Events
      .lsq_perv_odq_events(lsq_perv_odq_events),

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
      .scan_in(func_scan_in_q[0]),
      .scan_out(func_scan_out_int[0])
   );

   assign odq_pf_resolved    = odq_ldq_resolved;
   assign odq_pf_report_tid  = odq_ldq_report_tid;
   assign odq_pf_report_itag = odq_ldq_report_itag;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // LOADMISS QUEUE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   lq_ldq  ldq(

      // RV1 RV Issue Valid
      .rv_lq_vld(rv_lq_vld),
      .rv_lq_isLoad(rv_lq_isLoad),

      // RV is empty indicator
      .rv_lq_rvs_empty(rv_lq_rvs_empty),

      // SPR Directory Read Valid
      .ctl_lsq_rv1_dir_rd_val(ctl_lsq_rv1_dir_rd_val),

      // Back-Invalidate Valid
      .l2_back_inv_val(l2_back_inv_val_q),
      .l2_back_inv_addr(l2_back_inv_addr[64-`REAL_IFAR_WIDTH:63-`CL_SIZE]),

      // Load Request Interface
      .ctl_lsq_ex3_ldreq_val(ex3_ldreq_val),
      .ctl_lsq_ex3_pfetch_val(ctl_lsq_ex3_pfetch_val),
      .ctl_lsq_ex4_ldreq_val(ctl_lsq_ex4_ldreq_val),
      .ctl_lsq_ex4_streq_val(ctl_lsq_ex4_streq_val),
      .ctl_lsq_ex4_othreq_val(ctl_lsq_ex4_othreq_val),
      .ctl_lsq_ex4_p_addr(ex4_p_addr),
      .ctl_lsq_ex4_itag(ex4_itag_q),
      .ctl_lsq_ex4_dReq_val(ctl_lsq_ex4_dReq_val),
      .ctl_lsq_ex4_gath_load(ctl_lsq_ex4_gath_load),
      .ctl_lsq_ex4_wimge(ctl_lsq_ex4_wimge),
      .ctl_lsq_ex4_byte_swap(ctl_lsq_ex4_byte_swap),
      .ctl_lsq_ex4_is_resv(ctl_lsq_ex4_is_resv),
      .ctl_lsq_ex4_is_sync(ctl_lsq_ex4_is_sync),
      .ctl_lsq_ex4_all_thrd_chk(ctl_lsq_ex4_all_thrd_chk),
      .ctl_lsq_ex4_thrd_id(ex4_thrd_id_q),
      .ctl_lsq_ex5_lock_set(ctl_lsq_ex5_lock_set),
      .ctl_lsq_ex5_watch_set(ctl_lsq_ex5_watch_set),
      .ctl_lsq_ex5_thrd_id(ex5_thrd_id_q),
      .ctl_lsq_ex5_load_hit(ctl_lsq_ex5_load_hit),
      .ctl_lsq_ex5_opsize(ex5_opsize_q),
      .ctl_lsq_ex5_tgpr(ctl_lsq_ex5_tgpr),
      .ctl_lsq_ex5_axu_val(ctl_lsq_ex5_axu_val),
      .ctl_lsq_ex5_usr_def(ctl_lsq_ex5_usr_def),
      .ctl_lsq_ex5_drop_rel(ctl_lsq_ex5_drop_rel),
      .ctl_lsq_ex5_flush_req(ctl_lsq_ex5_flush_req),
      .ctl_lsq_ex5_flush_pfetch(ctl_lsq_ex5_flush_pfetch),
      .ctl_lsq_ex5_cmmt_events(ctl_lsq_ex5_cmmt_events),
      .ctl_lsq_ex5_perf_val0(ctl_lsq_ex5_perf_val0),
      .ctl_lsq_ex5_perf_sel0(ctl_lsq_ex5_perf_sel0),
      .ctl_lsq_ex5_perf_val1(ctl_lsq_ex5_perf_val1),
      .ctl_lsq_ex5_perf_sel1(ctl_lsq_ex5_perf_sel1),
      .ctl_lsq_ex5_perf_val2(ctl_lsq_ex5_perf_val2),
      .ctl_lsq_ex5_perf_sel2(ctl_lsq_ex5_perf_sel2),
      .ctl_lsq_ex5_perf_val3(ctl_lsq_ex5_perf_val3),
      .ctl_lsq_ex5_perf_sel3(ctl_lsq_ex5_perf_sel3),
      .ctl_lsq_ex5_not_touch(ctl_lsq_ex5_not_touch),
      .ctl_lsq_ex5_algebraic(ex5_algebraic_q),
      .ctl_lsq_ex5_class_id(ctl_lsq_ex5_class_id),
      .ctl_lsq_ex5_dvc(ctl_lsq_ex5_dvc),
      .ctl_lsq_ex5_dacrw(ctl_lsq_ex5_dacrw),
      .ctl_lsq_ex5_ttype(ctl_lsq_ex5_ttype),
      .lsq_ctl_ex6_ldq_events(lsq_ctl_ex6_ldq_events),
      .lsq_perv_ex7_events(lsq_perv_ex7_events),
      .lsq_perv_ldq_events(lsq_perv_ldq_events),
      .ctl_lsq_ex7_thrd_id(ex7_thrd_id_q),

      .ctl_lsq_pf_empty(ctl_lsq_pf_empty),

      // Interface with Local SPR's
      .ctl_lsq_spr_dvc1_dbg(ctl_lsq_spr_dvc1_dbg),
      .ctl_lsq_spr_dvc2_dbg(ctl_lsq_spr_dvc2_dbg),
      .ctl_lsq_spr_dbcr2_dvc1m(ctl_lsq_spr_dbcr2_dvc1m),
      .ctl_lsq_spr_dbcr2_dvc1be(ctl_lsq_spr_dbcr2_dvc1be),
      .ctl_lsq_spr_dbcr2_dvc2m(ctl_lsq_spr_dbcr2_dvc2m),
      .ctl_lsq_spr_dbcr2_dvc2be(ctl_lsq_spr_dbcr2_dvc2be),
      .ctl_lsq_dbg_int_en(ctl_lsq_dbg_int_en),
      .ctl_lsq_ldp_idle(ctl_lsq_ldp_idle),

      .stq_ldq_ex5_stq_restart(stq_ldq_ex5_stq_restart),
      .stq_ldq_ex5_stq_restart_miss(stq_ldq_ex5_stq_restart_miss),
      .stq_ldq_ex5_fwd_val(stq_ldq_ex5_fwd_val),

      // OrderQ Inputs
      .odq_ldq_n_flush(odq_ldq_n_flush),
      .odq_ldq_np1_flush(odq_ldq_np1_flush),
      .odq_ldq_resolved(odq_ldq_resolved),
      .odq_ldq_report_needed(odq_ldq_report_needed),
      .odq_ldq_report_tid(odq_ldq_report_tid),
      .odq_ldq_report_itag(odq_ldq_report_itag),
      .odq_ldq_report_dacrw(odq_ldq_report_dacrw),
      .odq_ldq_report_eccue(odq_ldq_report_eccue),
      .odq_ldq_report_pEvents(odq_ldq_report_pEvents),
      .odq_ldq_oldest_ld_tid(odq_ldq_oldest_ld_tid),
      .odq_ldq_oldest_ld_itag(odq_ldq_oldest_ld_itag),
      .odq_ldq_ex7_pfetch_blk(odq_ldq_ex7_pfetch_blk),

      // Store Queue is Empty
      .stq_ldq_empty(stq_ldq_empty),

      // Completion Inputs
      .iu_lq_cp_flush(iu_lq_cp_flush),
      .iu_lq_cp_next_itag(iu_lq_cp_next_itag),

      // L2 Request Sent
      .arb_ldq_ldq_unit_sel(arb_ldq_ldq_unit_sel),

      // L2 Reload
      .l2_lsq_resp_isComing(l2_lsq_resp_isComing),
      .l2_lsq_resp_val(l2_lsq_resp_val),
      .l2_lsq_resp_cTag(l2_lsq_resp_cTag),
      .l2_lsq_resp_qw(l2_lsq_resp_qw),
      .l2_lsq_resp_crit_qw(l2_lsq_resp_crit_qw),
      .l2_lsq_resp_l1_dump(l2_lsq_resp_l1_dump),
      .l2_lsq_resp_data(l2_lsq_resp_data),
      .l2_lsq_resp_ecc_err(l2_lsq_resp_ecc_err),
      .l2_lsq_resp_ecc_err_ue(l2_lsq_resp_ecc_err_ue),

      // Data Cache Config
      .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),

      // LSU Config
      .ctl_lsq_spr_lsucr0_lge(ctl_lsq_spr_lsucr0_lge),
      .ctl_lsq_spr_lsucr0_lca(ctl_lsq_spr_lsucr0_lca),

      // Inject Reload Data Array Parity Error
      .pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),

      // Interface to Store Queue
      .ldq_stq_rel1_blk_store(ldq_stq_rel1_blk_store),

      // Store Hit LoadMiss Queue Entries
      .ldq_stq_ex5_ldm_hit(ldq_stq_ex5_ldm_hit),
      .ldq_stq_ex5_ldm_entry(ldq_stq_ex5_ldm_entry),
      .ldq_stq_ldm_cpl(ldq_stq_ldm_cpl),

      // RV Reload Release Dependent ITAGs
      .lq_rv_itag2_vld(lq_rv_itag2_vld),
      .lq_rv_itag2(lq_rv_itag2),

      // PRF update for reloads
      .ldq_rel2_byte_swap(ldq_rel2_byte_swap),
      .ldq_rel2_data(ldq_rel2_data),

      // Directory Congruence Class Updated
      .ldq_stq_stq4_dir_upd(ldq_stq_stq4_dir_upd),
      .ldq_stq_stq4_cclass(ldq_stq_stq4_cclass),

      // Load Request was not restarted
      .ldq_odq_vld(ldq_odq_vld),
      .ldq_odq_pfetch_vld(ldq_odq_pfetch_vld),
      .ldq_odq_wimge_i(ldq_odq_wimge_i),
      .ldq_odq_ex6_pEvents(ldq_odq_ex6_pEvents),

      // Update Order Queue Entry when reload is complete and itag is not resolved
      .ldq_odq_upd_val(ldq_odq_upd_val),
      .ldq_odq_upd_itag(ldq_odq_upd_itag),
      .ldq_odq_upd_nFlush(ldq_odq_upd_nFlush),
      .ldq_odq_upd_np1Flush(ldq_odq_upd_np1Flush),
      .ldq_odq_upd_tid(ldq_odq_upd_tid),
      .ldq_odq_upd_dacrw(ldq_odq_upd_dacrw),
      .ldq_odq_upd_eccue(ldq_odq_upd_eccue),
      .ldq_odq_upd_pEvents(ldq_odq_upd_pEvents),

      // Interface to Completion
      .lq1_iu_execute_vld(lq1_iu_execute_vld),
      .lq1_iu_itag(lq1_iu_itag),
      .lq1_iu_exception_val(lq1_iu_exception_val),
      .lq1_iu_exception(lq1_iu_exception),
      .lq1_iu_n_flush(lq1_iu_n_flush),
      .lq1_iu_np1_flush(lq1_iu_np1_flush),
      .lq1_iu_dacr_type(lq1_iu_dacr_type),
      .lq1_iu_dacrw(lq1_iu_dacrw),
      .lq1_iu_perf_events(lq1_iu_perf_events),

      // Reservation station hold indicator
      .ldq_hold_all_req(ldq_hold_all_req),

      // Reservation station set barrier indicator
      .ldq_rv_set_hold(ldq_rv_set_hold),
      .ldq_rv_clr_hold(ldq_rv_clr_hold),

      // LOADMISS Queue RESTART indicator
      .lsq_ctl_ex5_ldq_restart(lsq_ctl_ex5_ldq_restart),

      // LDQ Request to the L2
      .ldq_arb_ld_req_pwrToken(ldq_arb_ld_req_pwrToken),
      .ldq_arb_ld_req_avail(ldq_arb_ld_req_avail),
      .ldq_arb_tid(ldq_arb_tid),
      .ldq_arb_usr_def(ldq_arb_usr_def),
      .ldq_arb_wimge(ldq_arb_wimge),
      .ldq_arb_p_addr(ldq_arb_p_addr),
      .ldq_arb_ttype(ldq_arb_ttype),
      .ldq_arb_opsize(ldq_arb_opsize),
      .ldq_arb_cTag(ldq_arb_cTag),

      // RELOAD Data Control
      .ldq_dat_stq1_stg_act(ldq_dat_stq1_stg_act),
      .lsq_dat_rel1_data_val(lsq_dat_rel1_data_val),
      .lsq_dat_rel1_qw(lsq_dat_rel1_qw),

      // RELOAD Directory Control
      .ldq_ctl_stq1_stg_act(ldq_ctl_stq1_stg_act),
      .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
      .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
      .lsq_ctl_rel1_data_val(lsq_ctl_rel1_data_val),
      .lsq_ctl_rel1_thrd_id(lsq_ctl_rel1_thrd_id),
      .lsq_ctl_rel1_back_inv(lsq_ctl_rel1_back_inv),
      .lsq_ctl_rel1_tag(lsq_ctl_rel1_tag),
      .lsq_ctl_rel1_classid(lsq_ctl_rel1_classid),
      .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
      .lsq_ctl_rel1_watch_set(lsq_ctl_rel1_watch_set),
      .lsq_ctl_rel2_blk_req(ldq_rel2_blk_req),
      .lsq_ctl_rel2_upd_val(lsq_ctl_rel2_upd_val),
      .lsq_ctl_rel3_l1dump_val(lsq_ctl_rel3_l1dump_val),
      .lsq_ctl_rel3_clr_relq(lsq_ctl_rel3_clr_relq),

      // Control Common to Reload and Commit Pipes
      .ldq_arb_rel1_data_sel(ldq_arb_rel1_data_sel),
      .ldq_arb_rel1_axu_val(ldq_arb_rel1_axu_val),
      .ldq_arb_rel1_op_size(ldq_arb_rel1_op_size),
      .ldq_arb_rel1_addr(ldq_arb_rel1_addr),
      .ldq_arb_rel1_ci(ldq_arb_rel1_ci),
      .ldq_arb_rel1_byte_swap(ldq_arb_rel1_byte_swap),
      .ldq_arb_rel1_thrd_id(ldq_arb_rel1_thrd_id),
      .ldq_arb_rel1_data(ldq_arb_rel1_data),
      .ldq_arb_rel2_rdat_sel(ldq_arb_rel2_rdat_sel),
      .ldq_arb_rel2_rd_data(ldq_arb_rel2_rd_data),
      .arb_ldq_rel2_wrt_data(arb_ldq_rel2_wrt_data),

      // RELOAD Register Control
      .lsq_ctl_rel1_gpr_val(lsq_ctl_rel1_gpr_val),
      .lsq_ctl_rel1_ta_gpr(lsq_ctl_rel1_ta_gpr),
      .lsq_ctl_rel1_upd_gpr(lsq_ctl_rel1_upd_gpr),

      // Interface to Pervasive Unit
      .lq_pc_err_invld_reld(lq_pc_err_invld_reld),
      .lq_pc_err_l2intrf_ecc(lq_pc_err_l2intrf_ecc),
      .lq_pc_err_l2intrf_ue(lq_pc_err_l2intrf_ue),
      .lq_pc_err_relq_parity(lq_pc_err_relq_parity),

      // LQ is Quiesced
      .lq_xu_quiesce(lq_xu_quiesce),
      .lq_pc_ldq_quiesce(lq_pc_ldq_quiesce),
      .lq_pc_stq_quiesce(lq_pc_stq_quiesce),
      .lq_pc_pfetch_quiesce(lq_pc_pfetch_quiesce),
      .lq_mm_lmq_stq_empty(lq_mm_lmq_stq_empty),

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
      .pc_lq_abist_raddr_0(pc_lq_abist_raddr_0[3:8]),
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
      .pc_lq_bo_select(pc_lq_bo_select[8:9]),
      .lq_pc_bo_fail(lq_pc_bo_fail[8:9]),
      .lq_pc_bo_diagout(lq_pc_bo_diagout[8:9]),

      // Pervasive
      .vcs(vdd),
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .sg_0(sg_0),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_sl_force(func_sl_force),
      .func_nsl_thold_0_b(func_nsl_thold_0_b),
      .func_nsl_force(func_nsl_force),
      .abst_sl_thold_0(abst_sl_thold_0),
      .ary_nsl_thold_0(ary_nsl_thold_0),
      .time_sl_thold_0(time_sl_thold_0),
      .repr_sl_thold_0(repr_sl_thold_0),
      .bolt_sl_thold_0(bolt_sl_thold_0),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .scan_in(func_scan_in_q[1]),
      .abst_scan_in(abst_scan_out_q[1]),
      .time_scan_in(time_scan_out_q[0]),
      .repr_scan_in(repr_scan_out_q[0]),
      .scan_out(func_scan_out_int[1]),
      .abst_scan_out(abst_scan_out_int[2]),
      .time_scan_out(time_scan_out_int[1]),
      .repr_scan_out(repr_scan_out_int[1])
   );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // STORE QUEUE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   lq_stq  stq(

      //   IU interface to RV for instruction insertion
      // port 0
      .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
      .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
      .rv_lq_rv1_i0_s3_t(rv_lq_rv1_i0_s3_t),
      .rv_lq_rv1_i0_rte_sq(rv_lq_rv1_i0_rte_sq),
      .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),

      // port 1
      .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
      .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
      .rv_lq_rv1_i1_s3_t(rv_lq_rv1_i1_s3_t),
      .rv_lq_rv1_i1_rte_sq(rv_lq_rv1_i1_rte_sq),
      .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),

      // RV1 RV Issue Valid
      .rv_lq_vld(rv_lq_vld),
      .rv_lq_isLoad(rv_lq_isLoad),

      // FXU0 Data interface
      .xu1_lq_ex2_stq_val(xu1_lq_ex2_stq_val),
      .xu1_lq_ex2_stq_itag(xu1_lq_ex2_stq_itag),
      //     xu1_lq_ex2_stq_size                => xu1_lq_ex2_stq_size,
      .xu1_lq_ex2_stq_dvc1_cmp(xu1_lq_ex2_stq_dvc1_cmp),
      .xu1_lq_ex2_stq_dvc2_cmp(xu1_lq_ex2_stq_dvc2_cmp),
      .ctl_lsq_ex4_xu1_data(ctl_lsq_ex4_xu1_data),
      .xu1_lq_ex3_illeg_lswx(xu1_lq_ex3_illeg_lswx),
      .xu1_lq_ex3_strg_noop(xu1_lq_ex3_strg_noop),

      // AXU Data interface
      .xu_lq_axu_ex_stq_val(xu_lq_axu_ex_stq_val),
      .xu_lq_axu_ex_stq_itag(xu_lq_axu_ex_stq_itag),
      .xu_lq_axu_exp1_stq_data(xu_lq_axu_exp1_stq_data),

      // Load Request Interface
      .ctl_lsq_ex2_streq_val(ctl_lsq_ex2_streq_val),
      .ctl_lsq_ex2_itag(ctl_lsq_ex2_itag),
      .ctl_lsq_ex2_thrd_id(ctl_lsq_ex2_thrd_id),
      .ctl_lsq_ex3_ldreq_val(ctl_lsq_ex3_ldreq_val),
      .ctl_lsq_ex3_pfetch_val(ctl_lsq_ex3_pfetch_val),
      .ctl_lsq_ex3_wchkall_val(ctl_lsq_ex3_wchkall_val),
      .ctl_lsq_ex3_byte_en(ctl_lsq_ex3_byte_en),
      .ctl_lsq_ex3_p_addr(ctl_lsq_ex3_p_addr),
      .ctl_lsq_ex3_opsize(ctl_lsq_ex3_opsize),
      .ctl_lsq_ex3_algebraic(ctl_lsq_ex3_algebraic),
      .ctl_lsq_ex4_streq_val(ex4_streq_val),
      .ctl_lsq_ex4_p_addr(ex4_p_addr),
      .ctl_lsq_ex4_cline_chk(ctl_lsq_ex4_cline_chk),
      .ctl_lsq_ex4_dreq_val(ctl_lsq_ex4_dReq_val),
      .ctl_lsq_ex4_send_l2(ctl_lsq_ex4_send_l2),
      .ctl_lsq_ex4_has_data(ctl_lsq_ex4_has_data),
      .ctl_lsq_ex4_wimge(ctl_lsq_ex4_wimge),
      .ctl_lsq_ex4_byte_swap(ctl_lsq_ex4_byte_swap),
      .ctl_lsq_ex4_is_sync(ctl_lsq_ex4_is_sync),
      .ctl_lsq_ex4_all_thrd_chk(ctl_lsq_ex4_all_thrd_chk),
      .ctl_lsq_ex4_is_store(ctl_lsq_ex4_is_store),
      .ctl_lsq_ex4_is_resv(ctl_lsq_ex4_is_resv),
      .ctl_lsq_ex4_is_mfgpr(ctl_lsq_ex4_is_mfgpr),
      .ctl_lsq_ex4_is_icswxr(ctl_lsq_ex4_is_icswxr),
      .ctl_lsq_ex4_is_icbi(ctl_lsq_ex4_is_icbi),
      .ctl_lsq_ex4_is_inval_op(ctl_lsq_ex4_is_inval_op),
      .ctl_lsq_ex4_watch_clr(ctl_lsq_ex4_watch_clr),
      .ctl_lsq_ex4_watch_clr_all(ctl_lsq_ex4_watch_clr_all),
      .ctl_lsq_ex4_mtspr_trace(ctl_lsq_ex4_mtspr_trace),
      .ctl_lsq_ex4_is_cinval(ctl_lsq_ex4_is_cinval),
      .ctl_lsq_ex5_lock_clr(ctl_lsq_ex5_lock_clr),
      .ctl_lsq_ex5_ttype(ctl_lsq_ex5_ttype),
      .ctl_lsq_ex5_axu_val(ctl_lsq_ex5_axu_val),
      .ctl_lsq_ex5_is_epid(ctl_lsq_ex5_is_epid),
      .ctl_lsq_ex5_usr_def(ctl_lsq_ex5_usr_def),
      .ctl_lsq_ex5_l_fld(ctl_lsq_ex5_l_fld),
      .ctl_lsq_ex5_tgpr(ctl_lsq_ex5_tgpr),
      .ctl_lsq_ex5_dvc(ctl_lsq_ex5_dvc),
      .ctl_lsq_ex5_load_hit(ctl_lsq_ex5_load_hit),
      .ctl_lsq_ex5_dacrw(ctl_lsq_ex5_dacrw),
      .ctl_lsq_ex5_flush_req(ctl_lsq_ex5_flush_req),
      .ctl_lsq_rv1_dir_rd_val(ctl_lsq_rv1_dir_rd_val),

      // Interface with Local SPR's
      .ctl_lsq_spr_dvc1_dbg(ctl_lsq_spr_dvc1_dbg),
      .ctl_lsq_spr_dvc2_dbg(ctl_lsq_spr_dvc2_dbg),
      .ctl_lsq_spr_dbcr2_dvc1m(ctl_lsq_spr_dbcr2_dvc1m),
      .ctl_lsq_spr_dbcr2_dvc1be(ctl_lsq_spr_dbcr2_dvc1be),
      .ctl_lsq_spr_dbcr2_dvc2m(ctl_lsq_spr_dbcr2_dvc2m),
      .ctl_lsq_spr_dbcr2_dvc2be(ctl_lsq_spr_dbcr2_dvc2be),
      .ctl_lsq_dbg_int_en(ctl_lsq_dbg_int_en),

      // Next Itag Completion
      .iu_lq_cp_next_val(iu_lq_recirc_val),
      .iu_lq_cp_next_itag(iu_lq_cp_next_itag),

      // Completion Inputs
      .iu_lq_cp_flush(iu_lq_cp_flush),
      .iu_lq_i0_completed(iu_lq_i0_completed),
      .iu_lq_i0_completed_itag(iu_lq_i0_completed_itag),
      .iu_lq_i1_completed(iu_lq_i1_completed),
      .iu_lq_i1_completed_itag(iu_lq_i1_completed_itag),

      // Store Queue Completion Report
      .lsq_ctl_stq_cpl_ready(lsq_ctl_stq_cpl_ready),
      .lsq_ctl_stq_cpl_ready_itag(lsq_ctl_stq_cpl_ready_itag),
      .lsq_ctl_stq_cpl_ready_tid(lsq_ctl_stq_cpl_ready_tid),
      .lsq_ctl_stq_n_flush(lsq_ctl_stq_n_flush),
      .lsq_ctl_stq_np1_flush(lsq_ctl_stq_np1_flush),
      .lsq_ctl_stq_exception_val(lsq_ctl_stq_exception_val),
      .lsq_ctl_stq_exception(lsq_ctl_stq_exception),
      .lsq_ctl_stq_dacrw(lsq_ctl_stq_dacrw),
      .ctl_lsq_stq_cpl_blk(ctl_lsq_stq_cpl_blk),
      .ctl_lsq_ex_pipe_full(ctl_lsq_ex_pipe_full),

      // Store Queue is Empty
      .stq_ldq_empty(stq_ldq_empty),

      // L2 Store Credit Available
      .arb_stq_cred_avail(arb_stq_cred_avail),

      // Data Cache Config
      .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),

      // ICBI ACK Enable
      .iu_lq_spr_iucr0_icbi_ack(iu_lq_spr_iucr0_icbi_ack),

      // LSUCR0 Config Bits
      .ctl_lsq_spr_lsucr0_sca(ctl_lsq_spr_lsucr0_sca),
      .ctl_lsq_spr_lsucr0_dfwd(ctl_lsq_spr_lsucr0_dfwd),

      // Interface to Store Queue
      .ldq_stq_rel1_blk_store(ldq_stq_rel1_blk_store),

      .ldq_stq_ex5_ldm_hit(ldq_stq_ex5_ldm_hit),
      .ldq_stq_ex5_ldm_entry(ldq_stq_ex5_ldm_entry),
      .ldq_stq_ldm_cpl(ldq_stq_ldm_cpl),

      .ldq_stq_stq4_dir_upd(ldq_stq_stq4_dir_upd),
      .ldq_stq_stq4_cclass(ldq_stq_stq4_cclass),

      // Age Detection
      // store tag used when instruction was inserted to store queue
      .stq_odq_i0_stTag(stq_odq_i0_stTag),
      .stq_odq_i1_stTag(stq_odq_i1_stTag),

      // store tag is committed, remove from order queue and dont compare against it
      .stq_odq_stq4_stTag_inval(stq_odq_stq4_stTag_inval),
      .stq_odq_stq4_stTag(stq_odq_stq4_stTag),

      // order queue closest oldest store to the ex2 load request
      .odq_stq_ex2_nxt_oldest_val(odq_stq_ex2_nxt_oldest_val),
      .odq_stq_ex2_nxt_oldest_stTag(odq_stq_ex2_nxt_oldest_stTag),

      // order queue closest youngest store to the ex2 load request
      .odq_stq_ex2_nxt_youngest_val(odq_stq_ex2_nxt_youngest_val),
      .odq_stq_ex2_nxt_youngest_stTag(odq_stq_ex2_nxt_youngest_stTag),

      // store tag is resolved from odq allow stq to commit
      .odq_stq_resolved(odq_stq_resolved),
      .odq_stq_stTag(odq_stq_stTag),

      // Reservation station hold indicator
      .stq_hold_all_req(stq_hold_all_req),

      // Reservation station set barrier indicator
      .stq_rv_set_hold(stq_rv_set_hold),
      .stq_rv_clr_hold(stq_rv_clr_hold),

      // STORE Queue RESTART indicator
      .lsq_ctl_ex5_stq_restart(stq_ldq_ex5_stq_restart),
      .lsq_ctl_ex5_stq_restart_miss(stq_ldq_ex5_stq_restart_miss),

      // STQ Request to the L2
      .stq_arb_st_req_avail(stq_arb_st_req_avail),
      .stq_arb_stq3_cmmt_val(stq_arb_stq3_cmmt_val),
      .stq_arb_stq3_cmmt_reject(stq_arb_stq3_cmmt_reject),
      .stq_arb_stq3_req_val(stq_arb_stq3_req_val),
      .stq_arb_stq3_tid(stq_arb_stq3_tid),
      .stq_arb_stq3_usrDef(stq_arb_stq3_usrDef),
      .stq_arb_stq3_wimge(stq_arb_stq3_wimge),
      .stq_arb_stq3_p_addr(stq_arb_stq3_p_addr),
      .stq_arb_stq3_ttype(stq_arb_stq3_ttype),
      .stq_arb_stq3_opSize(stq_arb_stq3_opSize),
      .stq_arb_stq3_byteEn(stq_arb_stq3_byteEn),
      .stq_arb_stq3_cTag(stq_arb_stq3_cTag),

      // Store Commit Data Control
      .stq_dat_stq1_stg_act(stq_dat_stq1_stg_act),
      .lsq_dat_stq1_val(lsq_dat_stq1_val),
      .lsq_dat_stq1_mftgpr_val(lsq_dat_stq1_mftgpr_val),
      .lsq_dat_stq1_store_val(lsq_dat_stq1_store_val),
      .lsq_dat_stq1_byte_en(lsq_dat_stq1_byte_en),
      .stq_arb_stq1_axu_val(stq_arb_stq1_axu_val),
      .stq_arb_stq1_epid_val(stq_arb_stq1_epid_val),
      .stq_arb_stq1_opSize(stq_arb_stq1_opSize),
      .stq_arb_stq1_p_addr(stq_arb_stq1_p_addr),
      .stq_arb_stq1_wimge_i(stq_arb_stq1_wimge_i),
      .stq_arb_stq1_store_data(stq_arb_stq1_store_data),
      .stq_arb_stq1_thrd_id(stq_arb_stq1_thrd_id),
      .stq_arb_stq1_byte_swap(stq_arb_stq1_byte_swap),

      // Store Commit Directory Control
      .stq_ctl_stq1_stg_act(stq_ctl_stq1_stg_act),
      .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
      .lsq_ctl_stq1_mftgpr_val(lsq_ctl_stq1_mftgpr_val),
      .lsq_ctl_stq1_mfdpf_val(lsq_ctl_stq1_mfdpf_val),
      .lsq_ctl_stq1_mfdpa_val(lsq_ctl_stq1_mfdpa_val),
      .lsq_ctl_stq1_lock_clr(lsq_ctl_stq1_lock_clr),
      .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
      .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
      .lsq_ctl_stq1_inval(lsq_ctl_stq1_inval),
      .lsq_ctl_stq1_dci_val(lsq_ctl_stq1_dci_val),
      .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
      .lsq_ctl_stq4_xucr0_cul(lsq_ctl_stq4_xucr0_cul),
      .lsq_ctl_stq5_itag(lsq_ctl_stq5_itag),
      .lsq_ctl_stq5_tgpr(lsq_ctl_stq5_tgpr),
      .ctl_lsq_stq4_perr_reject(ctl_lsq_stq4_perr_reject),

      // Illegal LSWX has been determined
      .lsq_ctl_ex3_strg_val(lsq_ctl_ex3_strg_val),
      .lsq_ctl_ex3_strg_noop(lsq_ctl_ex3_strg_noop),
      .lsq_ctl_ex3_illeg_lswx(lsq_ctl_ex3_illeg_lswx),
      .lsq_ctl_ex3_ct_val(lsq_ctl_ex3_ct_val),
      .lsq_ctl_ex3_be_ct(lsq_ctl_ex3_be_ct),
      .lsq_ctl_ex3_le_ct(lsq_ctl_ex3_le_ct),

      // Store Commit Control
      .lsq_ctl_stq1_resv(lsq_ctl_stq1_resv),
      .stq_stq2_blk_req(stq_stq2_blk_req),

      .lsq_ctl_sync_in_stq(lsq_ctl_sync_in_stq),
      .lsq_ctl_sync_done(lsq_ctl_sync_done),

      // Store Data Forward
      .lsq_ctl_ex5_fwd_val(stq_ldq_ex5_fwd_val),
      .lsq_ctl_ex5_fwd_data(lsq_ctl_ex5_fwd_data),
      .lsq_ctl_ex6_stq_events(lsq_ctl_ex6_stq_events),
      .lsq_perv_stq_events(lsq_perv_stq_events),

      // Store Credit Return
      .sq_iu_credit_free(sq_iu_credit_free),

      .an_ac_sync_ack(an_ac_sync_ack),

      // ICBI interface
      .lq_iu_icbi_val(lq_iu_icbi_val),
      .lq_iu_icbi_addr(lq_iu_icbi_addr),
      .iu_lq_icbi_complete(iu_lq_icbi_complete),

      // ICI Interace
      .lq_iu_ici_val(lq_iu_ici_val),

      // Back-Invalidate Valid
      .l2_back_inv_val(l2_back_inv_val_q),
      .l2_back_inv_addr(l2_back_inv_addr[64 - (`DC_SIZE - 3):63 - `CL_SIZE]),

      // L2 Interface Back Invalidate
      .an_ac_back_inv(an_ac_back_inv_q),
      .an_ac_back_inv_target_bit3(an_ac_back_inv_target_bit3_q),
      .an_ac_back_inv_addr(an_ac_back_inv_addr_q[58:60]),
      .an_ac_back_inv_addr_lo(an_ac_back_inv_addr_q[62:63]),

      // Stcx Complete
      .an_ac_stcx_complete(an_ac_stcx_complete_q),
      .an_ac_stcx_pass(an_ac_stcx_pass_q),

      // ICBI ACK
      .an_ac_icbi_ack(an_ac_icbi_ack_q),
      .an_ac_icbi_ack_thread(an_ac_icbi_ack_thread_q),

      // Core ID
      .an_ac_coreid(an_ac_coreid_q),

      // STCX/ICSWX CR Update
      .lq_xu_cr_l2_we(lq_xu_cr_l2_we),
      .lq_xu_cr_l2_wa(lq_xu_cr_l2_wa),
      .lq_xu_cr_l2_wd(lq_xu_cr_l2_wd),

      // XER Read for long latency CP_NEXT ops stcx./icswx.
      .xu_lq_xer_cp_rd(xu_lq_xer_cp_rd),

      // Reload Itag Complete
      .stq_arb_release_itag_vld(stq_arb_release_itag_vld),
      .stq_arb_release_itag(stq_arb_release_itag),
      .stq_arb_release_tid(stq_arb_release_tid),

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
      .scan_in(func_scan_in_q[2]),
      .scan_out(func_scan_out_int[2])
   );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // INSTRUCTION/MMU QUEUE
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   lq_imq  imq(

      // Instruction Fetches
      .iu_lq_request(iu_lq_request),
      .iu_lq_cTag(iu_lq_cTag),
      .iu_lq_ra(iu_lq_ra),
      .iu_lq_wimge(iu_lq_wimge),
      .iu_lq_userdef(iu_lq_userdef),

      // MMU instruction interface
      .mm_lq_lsu_req(mm_lq_lsu_req),
      .mm_lq_lsu_ttype(mm_lq_lsu_ttype),
      .mm_lq_lsu_wimge(mm_lq_lsu_wimge),
      .mm_lq_lsu_u(mm_lq_lsu_u),
      .mm_lq_lsu_addr(mm_lq_lsu_addr),

      // TLBI_COMPLETE is addressless
      .mm_lq_lsu_lpid(mm_lq_lsu_lpid),
      .mm_lq_lsu_gs(mm_lq_lsu_gs),
      .mm_lq_lsu_ind(mm_lq_lsu_ind),
      .mm_lq_lsu_lbit(mm_lq_lsu_lbit),
      .lq_mm_lsu_token(lq_mm_lsu_token),

      // IUQ Request Sent
      .arb_imq_iuq_unit_sel(arb_imq_iuq_unit_sel),
      .arb_imq_mmq_unit_sel(arb_imq_mmq_unit_sel),

      // IUQ Request to the L2
      .imq_arb_iuq_ld_req_avail(imq_arb_iuq_ld_req_avail),
      .imq_arb_iuq_tid(imq_arb_iuq_tid),
      .imq_arb_iuq_usr_def(imq_arb_iuq_usr_def),
      .imq_arb_iuq_wimge(imq_arb_iuq_wimge),
      .imq_arb_iuq_p_addr(imq_arb_iuq_p_addr),
      .imq_arb_iuq_ttype(imq_arb_iuq_ttype),
      .imq_arb_iuq_opSize(imq_arb_iuq_opSize),
      .imq_arb_iuq_cTag(imq_arb_iuq_cTag),

      // MMQ Request to the L2
      .imq_arb_mmq_ld_req_avail(imq_arb_mmq_ld_req_avail),
      .imq_arb_mmq_st_req_avail(imq_arb_mmq_st_req_avail),
      .imq_arb_mmq_tid(imq_arb_mmq_tid),
      .imq_arb_mmq_usr_def(imq_arb_mmq_usr_def),
      .imq_arb_mmq_wimge(imq_arb_mmq_wimge),
      .imq_arb_mmq_p_addr(imq_arb_mmq_p_addr),
      .imq_arb_mmq_ttype(imq_arb_mmq_ttype),
      .imq_arb_mmq_opSize(imq_arb_mmq_opSize),
      .imq_arb_mmq_cTag(imq_arb_mmq_cTag),
      .imq_arb_mmq_st_data(imq_arb_mmq_st_data),

      // Pervasive
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .sg_0(sg_0),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_sl_force(func_sl_force),
      .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
      .func_slp_sl_force(func_slp_sl_force),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .scan_in(func_scan_in_q[3]),
      .scan_out(func_scan_out_int[3])
   );

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // L2 REQUEST ARBITER
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   lq_arb  arb(

      // IUQ Request to the L2
      .imq_arb_iuq_ld_req_avail(imq_arb_iuq_ld_req_avail),
      .imq_arb_iuq_tid(imq_arb_iuq_tid),
      .imq_arb_iuq_usr_def(imq_arb_iuq_usr_def),
      .imq_arb_iuq_wimge(imq_arb_iuq_wimge),
      .imq_arb_iuq_p_addr(imq_arb_iuq_p_addr),
      .imq_arb_iuq_ttype(imq_arb_iuq_ttype),
      .imq_arb_iuq_opSize(imq_arb_iuq_opSize),
      .imq_arb_iuq_cTag(imq_arb_iuq_cTag),

      // MMQ Request to the L2
      .imq_arb_mmq_ld_req_avail(imq_arb_mmq_ld_req_avail),
      .imq_arb_mmq_st_req_avail(imq_arb_mmq_st_req_avail),
      .imq_arb_mmq_tid(imq_arb_mmq_tid),
      .imq_arb_mmq_usr_def(imq_arb_mmq_usr_def),
      .imq_arb_mmq_wimge(imq_arb_mmq_wimge),
      .imq_arb_mmq_p_addr(imq_arb_mmq_p_addr),
      .imq_arb_mmq_ttype(imq_arb_mmq_ttype),
      .imq_arb_mmq_opSize(imq_arb_mmq_opSize),
      .imq_arb_mmq_cTag(imq_arb_mmq_cTag),
      .imq_arb_mmq_st_data(imq_arb_mmq_st_data),

      // ldq Request to the L2
      .ldq_arb_ld_req_pwrToken(ldq_arb_ld_req_pwrToken),
      .ldq_arb_ld_req_avail(ldq_arb_ld_req_avail),
      .ldq_arb_tid(ldq_arb_tid),
      .ldq_arb_usr_def(ldq_arb_usr_def),
      .ldq_arb_wimge(ldq_arb_wimge),
      .ldq_arb_p_addr(ldq_arb_p_addr),
      .ldq_arb_ttype(ldq_arb_ttype),
      .ldq_arb_opSize(ldq_arb_opsize),
      .ldq_arb_cTag(ldq_arb_cTag),

      // Store Type Request to L2
      .stq_arb_stq1_stg_act(stq_dat_stq1_stg_act),
      .stq_arb_st_req_avail(stq_arb_st_req_avail),
      .stq_arb_stq3_cmmt_val(stq_arb_stq3_cmmt_val),
      .stq_arb_stq3_cmmt_reject(stq_arb_stq3_cmmt_reject),
      .stq_arb_stq3_req_val(stq_arb_stq3_req_val),
      .stq_arb_stq3_tid(stq_arb_stq3_tid),
      .stq_arb_stq3_usrDef(stq_arb_stq3_usrDef),
      .stq_arb_stq3_wimge(stq_arb_stq3_wimge),
      .stq_arb_stq3_p_addr(stq_arb_stq3_p_addr),
      .stq_arb_stq3_ttype(stq_arb_stq3_ttype),
      .stq_arb_stq3_opSize(stq_arb_stq3_opSize),
      .stq_arb_stq3_byteEn(stq_arb_stq3_byteEn),
      .stq_arb_stq3_cTag(stq_arb_stq3_cTag),
      .dat_lsq_stq4_128data(dat_lsq_stq4_128data),

      // Common Between LDQ and STQ
      .ldq_arb_rel1_stg_act(ldq_ctl_stq1_stg_act),
      .ldq_arb_rel1_data_sel(ldq_arb_rel1_data_sel),
      .ldq_arb_rel1_data(ldq_arb_rel1_data),
      .ldq_arb_rel1_blk_store(ldq_stq_rel1_blk_store),
      .ldq_arb_rel1_axu_val(ldq_arb_rel1_axu_val),
      .ldq_arb_rel1_op_size(ldq_arb_rel1_op_size),
      .ldq_arb_rel1_addr(ldq_arb_rel1_addr),
      .ldq_arb_rel1_ci(ldq_arb_rel1_ci),
      .ldq_arb_rel1_byte_swap(ldq_arb_rel1_byte_swap),
      .ldq_arb_rel1_thrd_id(ldq_arb_rel1_thrd_id),
      .ldq_arb_rel2_rdat_sel(ldq_arb_rel2_rdat_sel),
      .stq_arb_stq1_axu_val(stq_arb_stq1_axu_val),
      .stq_arb_stq1_epid_val(stq_arb_stq1_epid_val),
      .stq_arb_stq1_opSize(stq_arb_stq1_opSize),
      .stq_arb_stq1_p_addr(stq_arb_stq1_p_addr),
      .stq_arb_stq1_wimge_i(stq_arb_stq1_wimge_i),
      .stq_arb_stq1_store_data(stq_arb_stq1_store_data),
      .stq_arb_stq1_byte_swap(stq_arb_stq1_byte_swap),
      .stq_arb_stq1_thrd_id(stq_arb_stq1_thrd_id),
      .stq_arb_release_itag_vld(stq_arb_release_itag_vld),
      .stq_arb_release_itag(stq_arb_release_itag),
      .stq_arb_release_tid(stq_arb_release_tid),

      // L2 Credit Control
      .l2_lsq_req_ld_pop(an_ac_req_ld_pop_q),
      .l2_lsq_req_st_pop(an_ac_req_st_pop_q),
      .l2_lsq_req_st_gather(an_ac_req_st_gather_q),

      // ICSWX Data to be sent to the L2
      .ctl_lsq_stq3_icswx_data(ctl_lsq_stq3_icswx_data),

      // Interface with Reload Data Queue
      .ldq_arb_rel2_rd_data(ldq_arb_rel2_rd_data),
      .arb_ldq_rel2_wrt_data(arb_ldq_rel2_wrt_data),

      // L2 Credits Available
      .arb_stq_cred_avail(arb_stq_cred_avail),

      // Unit Selected to Send Request to the L2
      .arb_ldq_ldq_unit_sel(arb_ldq_ldq_unit_sel),
      .arb_imq_iuq_unit_sel(arb_imq_iuq_unit_sel),
      .arb_imq_mmq_unit_sel(arb_imq_mmq_unit_sel),

      // Common Between LDQ and STQ
      .lsq_ctl_stq1_axu_val(lsq_ctl_stq1_axu_val),
      .lsq_ctl_stq1_epid_val(lsq_ctl_stq1_epid_val),
      .lsq_dat_stq1_op_size(lsq_dat_stq1_op_size),
      .lsq_dat_stq1_addr(lsq_dat_stq1_addr),
      .lsq_dat_stq1_le_mode(lsq_dat_stq1_le_mode),
      .lsq_dat_stq2_store_data(lsq_dat_stq2_store_data),
      .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr),
      .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
      .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),

      // STCX/ICSWX Itag Complete
      .lsq_ctl_stq_release_itag_vld(lsq_ctl_stq_release_itag_vld),
      .lsq_ctl_stq_release_itag(lsq_ctl_stq_release_itag),
      .lsq_ctl_stq_release_tid(lsq_ctl_stq_release_tid),

      // L2 Request Signals
      .lsq_l2_pwrToken(lsq_l2_pwrToken),
      .lsq_l2_valid(lsq_l2_valid),
      .lsq_l2_tid(lsq_l2_tid),
      .lsq_l2_p_addr(lsq_l2_p_addr),
      .lsq_l2_wimge(lsq_l2_wimge),
      .lsq_l2_usrDef(lsq_l2_usrDef),
      .lsq_l2_byteEn(lsq_l2_byteEn),
      .lsq_l2_ttype(lsq_l2_ttype),
      .lsq_l2_opSize(lsq_l2_opSize),
      .lsq_l2_coreTag(lsq_l2_coreTag),
      .lsq_l2_dataToken(lsq_l2_dataToken),
      .lsq_l2_st_data(lsq_l2_st_data),

      // SPR Bits
      .ctl_lsq_spr_lsucr0_b2b(ctl_lsq_spr_lsucr0_b2b),
      .xu_lq_spr_xucr0_cred(xu_lq_spr_xucr0_cred),
      .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),

      // Pervasive Error Report
      .lq_pc_err_l2credit_overrun(lq_pc_err_l2credit_overrun),

      // Pervasive
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .sg_0(sg_0),
      .func_sl_thold_0_b(func_sl_thold_0_b),
      .func_sl_force(func_sl_force),
      .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
      .func_slp_sl_force(func_slp_sl_force),
      .d_mode_dc(d_mode_dc),
      .delay_lclkr_dc(delay_lclkr_dc),
      .mpw1_dc_b(mpw1_dc_b),
      .mpw2_dc_b(mpw2_dc_b),
      .scan_in(func_scan_in_q[4]),
      .scan_out(arb_func_scan_out)
   );

   assign an_ac_reld_data_vld_stg1_d = an_ac_reld_data_vld_q;

   assign l2_lsq_resp_isComing   = an_ac_reld_data_coming_q;
   assign l2_lsq_resp_val        = an_ac_reld_data_vld_q;
   assign l2_lsq_resp_cTag       = an_ac_reld_core_tag_q;
   assign l2_lsq_resp_qw         = {1'b0, an_ac_reld_qw_q};
   assign l2_lsq_resp_crit_qw    = an_ac_reld_crit_qw_q;
   assign l2_lsq_resp_l1_dump    = an_ac_reld_l1_dump_q;
   assign l2_lsq_resp_data       = an_ac_reld_data_q;
   assign l2_lsq_resp_ecc_err    = an_ac_reld_ecc_err_q;
   assign l2_lsq_resp_ecc_err_ue = an_ac_reld_ecc_err_ue_q;

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // Outputs
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

   assign ac_an_req_pwr_token          = lsq_l2_pwrToken;
   assign ac_an_req                    = lsq_l2_valid;
   assign ac_an_req_ra                 = lsq_l2_p_addr;
   assign ac_an_req_ttype              = lsq_l2_ttype;
   assign ac_an_req_thread[0:1]        = lsq_l2_tid;
   assign ac_an_req_thread[2]          = 1'b0;		// DITC Indicator
   assign ac_an_req_wimg_w             = lsq_l2_wimge[0];
   assign ac_an_req_wimg_i             = lsq_l2_wimge[1];
   assign ac_an_req_wimg_m             = lsq_l2_wimge[2];
   assign ac_an_req_wimg_g             = lsq_l2_wimge[3];
   assign ac_an_req_endian             = lsq_l2_wimge[4];
   assign ac_an_req_user_defined       = lsq_l2_usrDef;
   assign ac_an_req_spare_ctrl_a0      = {4{1'b0}};
   assign ac_an_req_ld_core_tag        = lsq_l2_coreTag;
   assign ac_an_req_ld_xfr_len         = lsq_l2_opSize;
   assign ac_an_st_byte_enbl[0:15]     = lsq_l2_byteEn;
   assign ac_an_st_byte_enbl[16:31]    = {16{1'b0}};
   assign ac_an_st_data[0:127]         = lsq_l2_st_data;
   assign ac_an_st_data[128:255]       = {128{1'b0}};
   assign ac_an_st_data_pwr_token      = lsq_l2_dataToken;
   assign lsq_ctl_stq1_stg_act         = ldq_ctl_stq1_stg_act | stq_ctl_stq1_stg_act;
   assign lsq_dat_stq1_stg_act         = ldq_dat_stq1_stg_act | stq_dat_stq1_stg_act;
   assign lsq_ctl_rel2_blk_req         = ldq_rel2_blk_req;
   assign lsq_ctl_stq2_blk_req         = stq_stq2_blk_req;
   assign lsq_dat_stq2_blk_req         = ldq_rel2_blk_req | stq_stq2_blk_req;
   assign lsq_ctl_rv_hold_all          = ldq_hold_all_req | stq_hold_all_req;
   assign lsq_ctl_rv_set_hold          = ldq_rv_set_hold | stq_rv_set_hold;
   assign lsq_ctl_rv_clr_hold          = ldq_rv_clr_hold | stq_rv_clr_hold;
   assign lsq_ctl_rv0_back_inv         = l2_back_inv_val_q;
   assign lsq_ctl_rv1_back_inv_addr    = rv1_back_inv_addr_q;
   assign lsq_ctl_ex5_stq_restart      = stq_ldq_ex5_stq_restart;
   assign lsq_ctl_ex5_stq_restart_miss = stq_ldq_ex5_stq_restart_miss;
   assign lsq_ctl_ex5_fwd_val          = stq_ldq_ex5_fwd_val;
   assign lq_xu_axu_rel_le             = ldq_rel2_byte_swap;
   assign lsq_ctl_rel2_data            = ldq_rel2_data;

   // SCAN OUT Gate
   assign abst_scan_out = abst_scan_out_q[2] &    an_ac_scan_dis_dc_b;
   assign time_scan_out = time_scan_out_q[1] &    an_ac_scan_dis_dc_b;
   assign repr_scan_out = repr_scan_out_q[1] &    an_ac_scan_dis_dc_b;
   assign func_scan_out = func_scan_out_q    & {7{an_ac_scan_dis_dc_b}};

   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   // REGISTERS
   // XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_inv_reg(
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
      .scin(siv[ldq_odq_inv_offset]),
      .scout(sov[ldq_odq_inv_offset]),
      .din(ldq_odq_inv_d),
      .dout(ldq_odq_inv_q)
   );


   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH-4), .INIT(0), .NEEDS_SRESET(1)) ldq_odq_addr_reg(
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
      .scin(siv[ldq_odq_addr_offset:ldq_odq_addr_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .scout(sov[ldq_odq_addr_offset:ldq_odq_addr_offset + (`REAL_IFAR_WIDTH-4) - 1]),
      .din(ldq_odq_addr_d),
      .dout(ldq_odq_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ldq_odq_itag_reg(
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
      .scin(siv[ldq_odq_itag_offset:ldq_odq_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ldq_odq_itag_offset:ldq_odq_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ldq_odq_itag_d),
      .dout(ldq_odq_itag_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ldq_odq_cline_chk_reg(
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
      .scin(siv[ldq_odq_cline_chk_offset]),
      .scout(sov[ldq_odq_cline_chk_offset]),
      .din(ldq_odq_cline_chk_d),
      .dout(ldq_odq_cline_chk_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_itag_reg(
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
      .scin(siv[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex3_itag_offset:ex3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex3_itag_d),
      .dout(ex3_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_itag_reg(
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
      .scin(siv[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[ex4_itag_offset:ex4_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(ex4_itag_d),
      .dout(ex4_itag_q)
   );


   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) ex4_byte_en_reg(
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
      .scin(siv[ex4_byte_en_offset:ex4_byte_en_offset + 16 - 1]),
      .scout(sov[ex4_byte_en_offset:ex4_byte_en_offset + 16 - 1]),
      .din(ex4_byte_en_d),
      .dout(ex4_byte_en_q)
   );


   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) ex5_byte_en_reg(
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
      .scin(siv[ex5_byte_en_offset:ex5_byte_en_offset + 16 - 1]),
      .scout(sov[ex5_byte_en_offset:ex5_byte_en_offset + 16 - 1]),
      .din(ex5_byte_en_d),
      .dout(ex5_byte_en_q)
   );


   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex4_p_addr_reg(
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
      .scin(siv[ex4_p_addr_offset:ex4_p_addr_offset + 6 - 1]),
      .scout(sov[ex4_p_addr_offset:ex4_p_addr_offset + 6 - 1]),
      .din(ex4_p_addr_d),
      .dout(ex4_p_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_thrd_id_reg(
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
      .scin(siv[ex4_thrd_id_offset:ex4_thrd_id_offset + `THREADS - 1]),
      .scout(sov[ex4_thrd_id_offset:ex4_thrd_id_offset + `THREADS - 1]),
      .din(ex4_thrd_id_d),
      .dout(ex4_thrd_id_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_thrd_id_reg(
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
      .scin(siv[ex5_thrd_id_offset:ex5_thrd_id_offset + `THREADS - 1]),
      .scout(sov[ex5_thrd_id_offset:ex5_thrd_id_offset + `THREADS - 1]),
      .din(ex5_thrd_id_d),
      .dout(ex5_thrd_id_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex6_thrd_id_reg(
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
      .scin(siv[ex6_thrd_id_offset:ex6_thrd_id_offset + `THREADS - 1]),
      .scout(sov[ex6_thrd_id_offset:ex6_thrd_id_offset + `THREADS - 1]),
      .din(ex6_thrd_id_d),
      .dout(ex6_thrd_id_q)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex7_thrd_id_reg(
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
      .scin(siv[ex7_thrd_id_offset:ex7_thrd_id_offset + `THREADS - 1]),
      .scout(sov[ex7_thrd_id_offset:ex7_thrd_id_offset + `THREADS - 1]),
      .din(ex7_thrd_id_d),
      .dout(ex7_thrd_id_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_algebraic_reg(
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
      .scin(siv[ex4_algebraic_offset]),
      .scout(sov[ex4_algebraic_offset]),
      .din(ex4_algebraic_d),
      .dout(ex4_algebraic_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_algebraic_reg(
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
      .scin(siv[ex5_algebraic_offset]),
      .scout(sov[ex5_algebraic_offset]),
      .din(ex5_algebraic_d),
      .dout(ex5_algebraic_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex4_opsize_reg(
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
      .scin(siv[ex4_opsize_offset:ex4_opsize_offset + 3 - 1]),
      .scout(sov[ex4_opsize_offset:ex4_opsize_offset + 3 - 1]),
      .din(ex4_opsize_d),
      .dout(ex4_opsize_q)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex5_opsize_reg(
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
      .scin(siv[ex5_opsize_offset:ex5_opsize_offset + 3 - 1]),
      .scout(sov[ex5_opsize_offset:ex5_opsize_offset + 3 - 1]),
      .din(ex5_opsize_d),
      .dout(ex5_opsize_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dreq_val_reg(
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
      .scin(siv[ex5_dreq_val_offset]),
      .scout(sov[ex5_dreq_val_offset]),
      .din(ex5_dreq_val_d),
      .dout(ex5_dreq_val_q)
   );


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


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_req_ld_pop_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_req_ld_pop_offset]),
      .scout(sov[an_ac_req_ld_pop_offset]),
      .din(an_ac_req_ld_pop_d),
      .dout(an_ac_req_ld_pop_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_req_st_pop_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_req_st_pop_offset]),
      .scout(sov[an_ac_req_st_pop_offset]),
      .din(an_ac_req_st_pop_d),
      .dout(an_ac_req_st_pop_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_req_st_gather_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_req_st_gather_offset]),
      .scout(sov[an_ac_req_st_gather_offset]),
      .din(an_ac_req_st_gather_d),
      .dout(an_ac_req_st_gather_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_data_vld_reg(
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
      .scin(siv[an_ac_reld_data_vld_offset]),
      .scout(sov[an_ac_reld_data_vld_offset]),
      .din(an_ac_reld_data_vld_d),
      .dout(an_ac_reld_data_vld_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_data_vld_stg1_reg(
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
      .scin(siv[an_ac_reld_data_vld_stg1_offset]),
      .scout(sov[an_ac_reld_data_vld_stg1_offset]),
      .din(an_ac_reld_data_vld_stg1_d),
      .dout(an_ac_reld_data_vld_stg1_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_data_coming_reg(
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
      .scin(siv[an_ac_reld_data_coming_offset]),
      .scout(sov[an_ac_reld_data_coming_offset]),
      .din(an_ac_reld_data_coming_d),
      .dout(an_ac_reld_data_coming_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_ditc_reg(
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
      .scin(siv[an_ac_reld_ditc_offset]),
      .scout(sov[an_ac_reld_ditc_offset]),
      .din(an_ac_reld_ditc_d),
      .dout(an_ac_reld_ditc_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_crit_qw_reg(
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
      .scin(siv[an_ac_reld_crit_qw_offset]),
      .scout(sov[an_ac_reld_crit_qw_offset]),
      .din(an_ac_reld_crit_qw_d),
      .dout(an_ac_reld_crit_qw_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_l1_dump_reg(
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
      .scin(siv[an_ac_reld_l1_dump_offset]),
      .scout(sov[an_ac_reld_l1_dump_offset]),
      .din(an_ac_reld_l1_dump_d),
      .dout(an_ac_reld_l1_dump_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_ecc_err_reg(
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
      .scin(siv[an_ac_reld_ecc_err_offset]),
      .scout(sov[an_ac_reld_ecc_err_offset]),
      .din(an_ac_reld_ecc_err_d),
      .dout(an_ac_reld_ecc_err_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_reld_ecc_err_ue_reg(
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
      .scin(siv[an_ac_reld_ecc_err_ue_offset]),
      .scout(sov[an_ac_reld_ecc_err_ue_offset]),
      .din(an_ac_reld_ecc_err_ue_d),
      .dout(an_ac_reld_ecc_err_ue_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_back_inv_offset]),
      .scout(sov[an_ac_back_inv_offset]),
      .din(an_ac_back_inv_d),
      .dout(an_ac_back_inv_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_target_bit1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_back_inv_target_bit1_offset]),
      .scout(sov[an_ac_back_inv_target_bit1_offset]),
      .din(an_ac_back_inv_target_bit1_d),
      .dout(an_ac_back_inv_target_bit1_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_target_bit3_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_back_inv_target_bit3_offset]),
      .scout(sov[an_ac_back_inv_target_bit3_offset]),
      .din(an_ac_back_inv_target_bit3_d),
      .dout(an_ac_back_inv_target_bit3_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_target_bit4_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_back_inv_target_bit4_offset]),
      .scout(sov[an_ac_back_inv_target_bit4_offset]),
      .din(an_ac_back_inv_target_bit4_d),
      .dout(an_ac_back_inv_target_bit4_q)
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) mm_lq_lsu_lpidr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[mm_lq_lsu_lpidr_offset:mm_lq_lsu_lpidr_offset + 8 - 1]),
      .scout(sov[mm_lq_lsu_lpidr_offset:mm_lq_lsu_lpidr_offset + 8 - 1]),
      .din(mm_lq_lsu_lpidr_d),
      .dout(mm_lq_lsu_lpidr_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_dbell_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[l2_dbell_val_offset]),
      .scout(sov[l2_dbell_val_offset]),
      .din(l2_dbell_val_d),
      .dout(l2_dbell_val_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) l2_back_inv_val_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[l2_back_inv_val_offset]),
      .scout(sov[l2_back_inv_val_offset]),
      .din(l2_back_inv_val_d),
      .dout(l2_back_inv_val_q)
   );


   tri_rlmreg_p #(.WIDTH((63-`CL_SIZE-(64-`REAL_IFAR_WIDTH)+1)), .INIT(0), .NEEDS_SRESET(1)) rv1_back_inv_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(l2_back_inv_val_q),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[rv1_back_inv_addr_offset:rv1_back_inv_addr_offset + (63-`CL_SIZE-(64-`REAL_IFAR_WIDTH)+1) - 1]),
      .scout(sov[rv1_back_inv_addr_offset:rv1_back_inv_addr_offset + (63-`CL_SIZE-(64-`REAL_IFAR_WIDTH)+1) - 1]),
      .din(rv1_back_inv_addr_d),
      .dout(rv1_back_inv_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) an_ac_req_spare_ctrl_a1_reg(
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
      .scin(siv[an_ac_req_spare_ctrl_a1_offset:an_ac_req_spare_ctrl_a1_offset + 4 - 1]),
      .scout(sov[an_ac_req_spare_ctrl_a1_offset:an_ac_req_spare_ctrl_a1_offset + 4 - 1]),
      .din(an_ac_req_spare_ctrl_a1_d),
      .dout(an_ac_req_spare_ctrl_a1_q)
   );


   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) an_ac_reld_core_tag_reg(
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
      .scin(siv[an_ac_reld_core_tag_offset:an_ac_reld_core_tag_offset + 5 - 1]),
      .scout(sov[an_ac_reld_core_tag_offset:an_ac_reld_core_tag_offset + 5 - 1]),
      .din(an_ac_reld_core_tag_d),
      .dout(an_ac_reld_core_tag_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) an_ac_reld_qw_reg(
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
      .scin(siv[an_ac_reld_qw_offset:an_ac_reld_qw_offset + 2 - 1]),
      .scout(sov[an_ac_reld_qw_offset:an_ac_reld_qw_offset + 2 - 1]),
      .din(an_ac_reld_qw_d),
      .dout(an_ac_reld_qw_q)
   );


   tri_rlmreg_p #(.WIDTH(128), .INIT(0), .NEEDS_SRESET(1)) an_ac_reld_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(an_ac_reld_data_vld_stg1_q),
      .force_t(func_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_reld_data_offset:an_ac_reld_data_offset + 128 - 1]),
      .scout(sov[an_ac_reld_data_offset:an_ac_reld_data_offset + 128 - 1]),
      .din(an_ac_reld_data_d),
      .dout(an_ac_reld_data_q)
   );


   tri_rlmreg_p #(.WIDTH(`REAL_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) an_ac_back_inv_addr_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(an_ac_back_inv_q),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .scout(sov[an_ac_back_inv_addr_offset:an_ac_back_inv_addr_offset + `REAL_IFAR_WIDTH - 1]),
      .din(an_ac_back_inv_addr_d),
      .dout(an_ac_back_inv_addr_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) an_ac_sync_ack_reg(
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
      .scin(siv[an_ac_sync_ack_offset:an_ac_sync_ack_offset + `THREADS - 1]),
      .scout(sov[an_ac_sync_ack_offset:an_ac_sync_ack_offset + `THREADS - 1]),
      .din(an_ac_sync_ack_d),
      .dout(an_ac_sync_ack_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) an_ac_stcx_complete_reg(
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
      .scin(siv[an_ac_stcx_complete_offset:an_ac_stcx_complete_offset + `THREADS - 1]),
      .scout(sov[an_ac_stcx_complete_offset:an_ac_stcx_complete_offset + `THREADS - 1]),
      .din(an_ac_stcx_complete_d),
      .dout(an_ac_stcx_complete_q)
   );


   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) an_ac_stcx_pass_reg(
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
      .scin(siv[an_ac_stcx_pass_offset:an_ac_stcx_pass_offset + `THREADS - 1]),
      .scout(sov[an_ac_stcx_pass_offset:an_ac_stcx_pass_offset + `THREADS - 1]),
      .din(an_ac_stcx_pass_d),
      .dout(an_ac_stcx_pass_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) an_ac_icbi_ack_reg(
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
      .scin(siv[an_ac_icbi_ack_offset]),
      .scout(sov[an_ac_icbi_ack_offset]),
      .din(an_ac_icbi_ack_d),
      .dout(an_ac_icbi_ack_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) an_ac_icbi_ack_thread_reg(
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
      .scin(siv[an_ac_icbi_ack_thread_offset:an_ac_icbi_ack_thread_offset + 2 - 1]),
      .scout(sov[an_ac_icbi_ack_thread_offset:an_ac_icbi_ack_thread_offset + 2 - 1]),
      .din(an_ac_icbi_ack_thread_d),
      .dout(an_ac_icbi_ack_thread_q)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) an_ac_coreid_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(func_slp_sl_force),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .scin(siv[an_ac_coreid_offset:an_ac_coreid_offset + 2 - 1]),
      .scout(sov[an_ac_coreid_offset:an_ac_coreid_offset + 2 - 1]),
      .din(an_ac_coreid_d),
      .dout(an_ac_coreid_q)
   );

   //---------------------------------------------------------------------
   // abist latches
   //---------------------------------------------------------------------

   tri_rlmreg_p #(.INIT(0), .WIDTH(25), .NEEDS_SRESET(1)) abist_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_lq_abist_ena_dc),
      .thold_b(abst_sl_thold_0_b),
      .sg(sg_0),
      .force_t(abst_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .d_mode(d_mode_dc),
      .scin(abist_siv[0:24]),
      .scout(abist_sov[0:24]),
      .din({pc_lq_abist_wl64_comp_ena,
            pc_lq_abist_g8t_wenb,
            pc_lq_abist_g8t1p_renb_0,
            pc_lq_abist_g8t_dcomp,
            pc_lq_abist_g8t_bw_1,
            pc_lq_abist_g8t_bw_0,
            pc_lq_abist_di_0,
            pc_lq_abist_waddr_0,
            pc_lq_abist_raddr_0}),
      .dout({pc_lq_abist_wl64_comp_ena_q,
             pc_lq_abist_g8t_wenb_q,
             pc_lq_abist_g8t1p_renb_0_q,
             pc_lq_abist_g8t_dcomp_q,
             pc_lq_abist_g8t_bw_1_q,
             pc_lq_abist_g8t_bw_0_q,
             pc_lq_abist_di_0_q,
             pc_lq_abist_waddr_0_q,
             pc_lq_abist_raddr_0_q})
   );

   //-----------------------------------------------
   // Pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(10)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_lq_ccflush_dc),
      .din({func_nsl_thold_2,
            func_sl_thold_2,
            func_slp_sl_thold_2,
            ary_nsl_thold_2,
            abst_sl_thold_2,
            time_sl_thold_2,
            repr_sl_thold_2,
            bolt_sl_thold_2,
            sg_2,
            fce_2}),
      .q({func_nsl_thold_1,
          func_sl_thold_1,
          func_slp_sl_thold_1,
          ary_nsl_thold_1,
          abst_sl_thold_1,
          time_sl_thold_1,
          repr_sl_thold_1,
          bolt_sl_thold_1,
          sg_1,
          fce_1})
   );


   tri_plat #(.WIDTH(10)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(pc_lq_ccflush_dc),
      .din({func_nsl_thold_1,
            func_sl_thold_1,
            func_slp_sl_thold_1,
            ary_nsl_thold_1,
            abst_sl_thold_1,
            time_sl_thold_1,
            repr_sl_thold_1,
            bolt_sl_thold_1,
            sg_1,
            fce_1}),
      .q({func_nsl_thold_0,
          func_sl_thold_0,
          func_slp_sl_thold_0,
          ary_nsl_thold_0,
          abst_sl_thold_0,
          time_sl_thold_0,
          repr_sl_thold_0,
          bolt_sl_thold_0,
          sg_0,
          fce_0})
   );


   tri_lcbor  perv_lcbor_func_sl(
      .clkoff_b(clkoff_dc_b),
      .thold(func_sl_thold_0),
      .sg(sg_0),
      .act_dis(tidn),
      .force_t(func_sl_force),
      .thold_b(func_sl_thold_0_b)
   );


   tri_lcbor  perv_lcbor_func_slp_sl(
      .clkoff_b(clkoff_dc_b),
      .thold(func_slp_sl_thold_0),
      .sg(sg_0),
      .act_dis(tidn),
      .force_t(func_slp_sl_force),
      .thold_b(func_slp_sl_thold_0_b)
   );


   tri_lcbor  perv_lcbor_func_nsl(
      .clkoff_b(clkoff_dc_b),
      .thold(func_nsl_thold_0),
      .sg(fce_0),
      .act_dis(tidn),
      .force_t(func_nsl_force),
      .thold_b(func_nsl_thold_0_b)
   );


   tri_lcbor  perv_lcbor_abst_sl(
      .clkoff_b(clkoff_dc_b),
      .thold(abst_sl_thold_0),
      .sg(sg_0),
      .act_dis(tidn),
      .force_t(abst_sl_force),
      .thold_b(abst_sl_thold_0_b)
   );

   // LCBs for scan only staging latches
   assign slat_force = sg_0;
   assign abst_slat_thold_b = (~abst_sl_thold_0);
   assign time_slat_thold_b = (~time_sl_thold_0);
   assign repr_slat_thold_b = (~repr_sl_thold_0);
   assign func_slat_thold_b = (~func_sl_thold_0);


   tri_lcbs  perv_lcbs_abst(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr_dc),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(abst_slat_thold_b),
      .dclk(abst_slat_d2clk),
      .lclk(abst_slat_lclk)
   );


   tri_slat_scan #(.WIDTH(4), .INIT(4'b0000)) perv_abst_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(abst_slat_d2clk),
      .lclk(abst_slat_lclk),
      .scan_in({abst_scan_in,
                abst_scan_out_int[0],
                abst_scan_out_int[1],
                abst_scan_out_int[2]}),
      .scan_out({abst_scan_in_q,
                 abst_scan_out_q[0],
                 abst_scan_out_q[1],
                 abst_scan_out_q[2]}),
      .q(abst_scan_q),
      .q_b(abst_scan_q_b)
   );


   tri_lcbs  perv_lcbs_time(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr_dc),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(time_slat_thold_b),
      .dclk(time_slat_d2clk),
      .lclk(time_slat_lclk)
   );


   tri_slat_scan #(.WIDTH(3), .INIT(3'b000)) perv_time_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(time_slat_d2clk),
      .lclk(time_slat_lclk),
      .scan_in({time_scan_in,
                time_scan_out_int[0],
                time_scan_out_int[1]}),
      .scan_out({time_scan_in_q,
                 time_scan_out_q[0],
                 time_scan_out_q[1]}),
      .q(time_scan_q),
      .q_b(time_scan_q_b)
   );


   tri_lcbs  perv_lcbs_repr(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr_dc),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(repr_slat_thold_b),
      .dclk(repr_slat_d2clk),
      .lclk(repr_slat_lclk)
   );


   tri_slat_scan #(.WIDTH(3), .INIT(3'b000)) perv_repr_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(repr_slat_d2clk),
      .lclk(repr_slat_lclk),
      .scan_in({repr_scan_in,
                repr_scan_out_int[0],
                repr_scan_out_int[1]}),
      .scan_out({repr_scan_in_q,
                 repr_scan_out_q[0],
                 repr_scan_out_q[1]}),
      .q(repr_scan_q),
      .q_b(repr_scan_q_b)
   );


   tri_lcbs  perv_lcbs_func(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(delay_lclkr_dc),
      .nclk(nclk),
      .force_t(slat_force),
      .thold_b(func_slat_thold_b),
      .dclk(func_slat_d2clk),
      .lclk(func_slat_lclk)
   );


   tri_slat_scan #(.WIDTH(14), .INIT(14'b00000000000000)) perv_func_stg(
      .vd(vdd),
      .gd(gnd),
      .dclk(func_slat_d2clk),
      .lclk(func_slat_lclk),
      .scan_in({func_scan_in[0],
                func_scan_in[1],
                func_scan_in[2],
                func_scan_in[3],
                func_scan_in[4],
                func_scan_in[5],
                func_scan_in[6],
                func_scan_out_int[0],
                func_scan_out_int[1],
                func_scan_out_int[2],
                func_scan_out_int[3],
                func_scan_out_int[4],
                func_scan_out_int[5],
                func_scan_out_int[6]}),
      .scan_out({func_scan_in_q[0],
                 func_scan_in_q[1],
                 func_scan_in_q[2],
                 func_scan_in_q[3],
                 func_scan_in_q[4],
                 func_scan_in_q[5],
                 func_scan_in_q[6],
                 func_scan_out_q[0],
                 func_scan_out_q[1],
                 func_scan_out_q[2],
                 func_scan_out_q[3],
                 func_scan_out_q[4],
                 func_scan_out_q[5],
                 func_scan_out_q[6]}),
      .q(func_scan_q),
      .q_b(func_scan_q_b)
   );

   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in_q[5]};
   assign func_scan_out_int[5] = sov[0];

   assign func_scan_out_int[6] = func_scan_in_q[6];

   assign abist_siv = {abist_sov[1:24], abst_scan_out_q[0]};
   assign abst_scan_out_int[1] = abist_sov[0];

endmodule
