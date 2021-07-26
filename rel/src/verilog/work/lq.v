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

//  Description:  lq Top
//
//*****************************************************************************

`include "tri_a2o.vh"

(* recursive_synthesis="0" *)

module lq(
   xu_lq_spr_ccr2_en_trace,
   xu_lq_spr_ccr2_en_pc,
   xu_lq_spr_ccr2_en_ditc,
   xu_lq_spr_ccr2_en_icswx,
   xu_lq_spr_ccr2_dfrat,
   xu_lq_spr_ccr2_dfratsc,
   xu_lq_spr_ccr2_ap,
   xu_lq_spr_ccr2_ucode_dis,
   xu_lq_spr_ccr2_notlb,
   xu_lq_spr_xucr4_mmu_mchk,
   xu_lq_spr_xucr4_mddmh,
   xu_lq_spr_xucr0_clkg_ctl,
   xu_lq_spr_xucr0_wlk,
   xu_lq_spr_xucr0_mbar_ack,
   xu_lq_spr_xucr0_tlbsync,
   xu_lq_spr_xucr0_dcdis,
   xu_lq_spr_xucr0_aflsta,
   xu_lq_spr_xucr0_flsta,
   xu_lq_spr_xucr0_clfc,
   xu_lq_spr_xucr0_cls,
   xu_lq_spr_xucr0_trace_um,
   xu_lq_spr_xucr0_cred,
   xu_lq_spr_xucr0_mddp,
   xu_lq_spr_xucr0_mdcp,
   xu_lq_spr_dbcr0_dac1,
   xu_lq_spr_dbcr0_dac2,
   xu_lq_spr_dbcr0_dac3,
   xu_lq_spr_dbcr0_dac4,
   xu_lq_spr_dbcr0_idm,
   xu_lq_spr_epcr_duvd,
   xu_lq_spr_msr_cm,
   xu_lq_spr_msr_fp,
   xu_lq_spr_msr_spv,
   xu_lq_spr_msr_gs,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_ds,
   xu_lq_spr_msr_de,
   xu_lq_spr_msr_ucle,
   xu_lq_spr_msrp_uclep,
   iu_lq_spr_iucr0_icbi_ack,
   lq_xu_spr_xucr0_cul,
   lq_xu_spr_xucr0_cslc_xuop,
   lq_xu_spr_xucr0_cslc_binv,
   lq_xu_spr_xucr0_clo,
   lq_iu_spr_dbcr3_ivc,
   slowspr_val_in,
   slowspr_rw_in,
   slowspr_etid_in,
   slowspr_addr_in,
   slowspr_data_in,
   slowspr_done_in,
   slowspr_val_out,
   slowspr_rw_out,
   slowspr_etid_out,
   slowspr_addr_out,
   slowspr_data_out,
   slowspr_done_out,
   iu_lq_cp_flush,
   iu_lq_recirc_val,
   iu_lq_cp_next_itag_t0,
   `ifndef THREADS1
      iu_lq_cp_next_itag_t1,
   `endif
   iu_lq_isync,
   iu_lq_csync,
   lq0_iu_execute_vld,
   lq0_iu_recirc_val,
   lq0_iu_itag,
   lq0_iu_flush2ucode,
   lq0_iu_flush2ucode_type,
   lq0_iu_exception_val,
   lq0_iu_exception,
   lq0_iu_dear_val,
   lq0_iu_n_flush,
   lq0_iu_np1_flush,
   lq0_iu_dacr_type,
   lq0_iu_dacrw,
   lq0_iu_instr,
   lq0_iu_eff_addr,
   lq1_iu_execute_vld,
   lq1_iu_itag,
   lq1_iu_exception_val,
   lq1_iu_exception,
   lq1_iu_n_flush,
   lq1_iu_np1_flush,
   lq1_iu_dacr_type,
   lq1_iu_dacrw,
   lq1_iu_perf_events,
   lq_iu_credit_free,
   sq_iu_credit_free,
   iu_lq_i0_completed,
   iu_lq_i0_completed_itag_t0,
   `ifndef THREADS1
      iu_lq_i0_completed_itag_t1,
   `endif
   iu_lq_i1_completed,
   iu_lq_i1_completed_itag_t0,
   `ifndef THREADS1
      iu_lq_i1_completed_itag_t1,
   `endif
   iu_lq_request,
   iu_lq_cTag,
   iu_lq_ra,
   iu_lq_wimge,
   iu_lq_userdef,
   lq_iu_icbi_val,
   lq_iu_icbi_addr,
   iu_lq_icbi_complete,
   lq_iu_ici_val,
   xu_lq_act,
   xu_lq_val,
   xu_lq_is_eratre,
   xu_lq_is_eratwe,
   xu_lq_is_eratsx,
   xu_lq_is_eratilx,
   xu_lq_ws,
   xu_lq_ra_entry,
   xu_lq_rs_data,
   xu_lq_hold_req,
   lq_xu_ex5_data,
   lq_xu_ord_par_err,
   lq_xu_ord_read_done,
   lq_xu_ord_write_done,
   lq_xu_dbell_val,
   lq_xu_dbell_type,
   lq_xu_dbell_brdcast,
   lq_xu_dbell_lpid_match,
   lq_xu_dbell_pirtag,
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_2ucode,
   rv_lq_rv1_i0_ucode_cnt,
   rv_lq_rv1_i0_s3_t,
   rv_lq_rv1_i0_isLoad,
   rv_lq_rv1_i0_isStore,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i0_rte_lq,
   rv_lq_rv1_i0_rte_sq,
   rv_lq_rv1_i0_ifar,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_2ucode,
   rv_lq_rv1_i1_ucode_cnt,
   rv_lq_rv1_i1_s3_t,
   rv_lq_rv1_i1_isLoad,
   rv_lq_rv1_i1_isStore,
   rv_lq_rv1_i1_itag,
   rv_lq_rv1_i1_rte_lq,
   rv_lq_rv1_i1_rte_sq,
   rv_lq_rv1_i1_ifar,
   rv_lq_rvs_empty,
   rv_lq_vld,
   rv_lq_isLoad,
   rv_lq_ex0_itag,
   rv_lq_ex0_instr,
   rv_lq_ex0_ucode,
   rv_lq_ex0_ucode_cnt,
   rv_lq_ex0_t1_v,
   rv_lq_ex0_t1_p,
   rv_lq_ex0_t3_p,
   rv_lq_ex0_s1_v,
   rv_lq_ex0_s2_v,
   lq_rv_itag0_vld,
   lq_rv_itag0,
   lq_rv_itag0_abort,
   lq_rv_ex2_s1_abort,
   lq_rv_ex2_s2_abort,
   lq_rv_hold_all,
   lq_rv_itag1_vld,
   lq_rv_itag1,
   lq_rv_itag1_restart,
   lq_rv_itag1_abort,
   lq_rv_itag1_hold,
   lq_rv_itag1_cord,
   lq_rv_itag2_vld,
   lq_rv_itag2,
   lq_rv_clr_hold,
   rv_lq_ex0_s1_xu0_sel,
   rv_lq_ex0_s2_xu0_sel,
   rv_lq_ex0_s1_xu1_sel,
   rv_lq_ex0_s2_xu1_sel,
   rv_lq_ex0_s1_lq_sel,
   rv_lq_ex0_s2_lq_sel,
   rv_lq_ex0_s1_rel_sel,
   rv_lq_ex0_s2_rel_sel,
   xu_lq_xer_cp_rd,
   rv_lq_gpr_ex1_r0d,
   rv_lq_gpr_ex1_r1d,
   lq_rv_gpr_ex6_we,
   lq_rv_gpr_ex6_wa,
   lq_rv_gpr_ex6_wd,
   lq_xu_gpr_ex5_we,
   lq_xu_gpr_ex5_wa,
   lq_rv_gpr_rel_we,
   lq_xu_gpr_rel_we,
   lq_xu_axu_rel_we,
   lq_xu_axu_rel_le,
   lq_rv_gpr_rel_wa,
   lq_xu_gpr_rel_wa,
   lq_rv_gpr_rel_wd,
   lq_xu_gpr_rel_wd,
   lq_xu_cr_l2_we,
   lq_xu_cr_l2_wa,
   lq_xu_cr_l2_wd,
   lq_xu_cr_ex5_we,
   lq_xu_cr_ex5_wa,
   lq_xu_ex5_abort,
   xu0_lq_ex3_act,
   xu0_lq_ex3_abort,
   xu0_lq_ex3_rt,
   xu0_lq_ex4_rt,
   xu0_lq_ex6_act,
   xu0_lq_ex6_rt,
   lq_xu_ex5_act,
   lq_xu_ex5_cr,
   lq_xu_ex5_rt,
   xu1_lq_ex3_act,
   xu1_lq_ex3_abort,
   xu1_lq_ex3_rt,
   xu1_lq_ex2_stq_val,
   xu1_lq_ex2_stq_itag,
   xu1_lq_ex2_stq_size,
   xu1_lq_ex2_stq_dvc1_cmp,
   xu1_lq_ex2_stq_dvc2_cmp,
   xu1_lq_ex3_illeg_lswx,
   xu1_lq_ex3_strg_noop,
   xu_lq_axu_ex_stq_val,
   xu_lq_axu_ex_stq_itag,
   xu_lq_axu_exp1_stq_data,
   lq_xu_axu_ex4_addr,
   lq_xu_axu_ex5_we,
   lq_xu_axu_ex5_le,
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
   mm_lq_hold_req,
   mm_lq_hold_done,
   mm_lq_pid_t0,
   mm_lq_mmucr0_t0,
   `ifndef THREADS1
      mm_lq_pid_t1,
      mm_lq_mmucr0_t1,
   `endif
   mm_lq_mmucr1,
   mm_lq_rel_val,
   mm_lq_rel_data,
   mm_lq_rel_emq,
   mm_lq_itag,
   mm_lq_tlb_miss,
   mm_lq_tlb_inelig,
   mm_lq_pt_fault,
   mm_lq_lrat_miss,
   mm_lq_tlb_multihit,
   mm_lq_tlb_par_err,
   mm_lq_lru_par_err,
   mm_lq_snoop_coming,
   mm_lq_snoop_val,
   mm_lq_snoop_attr,
   mm_lq_snoop_vpn,
   lq_mm_snoop_ack,
   lq_mm_req,
   lq_mm_req_nonspec,
   lq_mm_req_itag,
   lq_mm_req_epn,
   lq_mm_thdid,
   lq_mm_req_emq,
   lq_mm_ttype,
   lq_mm_state,
   lq_mm_lpid,
   lq_mm_tid,
   lq_mm_mmucr0_we,
   lq_mm_mmucr0,
   lq_mm_mmucr1_we,
   lq_mm_mmucr1,
   lq_mm_lmq_stq_empty,
   lq_mm_perf_dtlb,
   lq_xu_quiesce,
   lq_pc_ldq_quiesce,
   lq_pc_stq_quiesce,
   lq_pc_pfetch_quiesce,
   pc_lq_inj_dcachedir_ldp_parity,
   pc_lq_inj_dcachedir_ldp_multihit,
   pc_lq_inj_dcachedir_stp_parity,
   pc_lq_inj_dcachedir_stp_multihit,
   pc_lq_inj_dcache_parity,
   pc_lq_inj_prefetcher_parity,
   pc_lq_inj_relq_parity,
   lq_pc_err_derat_parity,
   lq_pc_err_dir_ldp_parity,
   lq_pc_err_dir_stp_parity,
   lq_pc_err_relq_parity,
   lq_pc_err_dcache_parity,
   lq_pc_err_derat_multihit,
   lq_pc_err_dir_ldp_multihit,
   lq_pc_err_dir_stp_multihit,
   lq_pc_err_invld_reld,
   lq_pc_err_l2intrf_ecc,
   lq_pc_err_l2intrf_ue,
   lq_pc_err_l2credit_overrun,
   pc_lq_ram_active,
   lq_pc_ram_data_val,
   lq_pc_ram_data,
   lq_pc_err_prefetcher_parity,
   pc_lq_trace_bus_enable,
   pc_lq_debug_mux1_ctrls,
   pc_lq_debug_mux2_ctrls,
   pc_lq_instr_trace_mode,
   pc_lq_instr_trace_tid,
   debug_bus_in,
   coretrace_ctrls_in,
   debug_bus_out,
   coretrace_ctrls_out,
   pc_lq_event_bus_enable,
   pc_lq_event_count_mode,
   event_bus_in,
   event_bus_out,
   an_ac_coreid,
   an_ac_sync_ack,
   an_ac_stcx_complete,
   an_ac_stcx_pass,
   an_ac_icbi_ack,
   an_ac_icbi_ack_thread,
   an_ac_back_inv,
   an_ac_back_inv_addr,
   an_ac_back_inv_target_bit1,
   an_ac_back_inv_target_bit3,
   an_ac_back_inv_target_bit4,
   an_ac_flh2l2_gate,
   an_ac_req_ld_pop,
   an_ac_req_st_pop,
   an_ac_req_st_gather,
   an_ac_reld_data_vld,
   an_ac_reld_core_tag,
   an_ac_reld_data,
   an_ac_reld_qw,
   an_ac_reld_ecc_err,
   an_ac_reld_ecc_err_ue,
   an_ac_reld_data_coming,
   an_ac_reld_ditc,
   an_ac_reld_crit_qw,
   an_ac_reld_l1_dump,
   an_ac_req_spare_ctrl_a1,
   ac_an_req_pwr_token,
   ac_an_req,
   ac_an_req_ra,
   ac_an_req_ttype,
   ac_an_req_thread,
   ac_an_req_wimg_w,
   ac_an_req_wimg_i,
   ac_an_req_wimg_m,
   ac_an_req_wimg_g,
   ac_an_req_user_defined,
   ac_an_req_spare_ctrl_a0,
   ac_an_req_ld_core_tag,
   ac_an_req_ld_xfr_len,
   ac_an_st_byte_enbl,
   ac_an_st_data,
   ac_an_req_endian,
   ac_an_st_data_pwr_token,
//   vcs,
//   vdd,
//   gnd,
   nclk,
   pc_lq_init_reset,
   pc_lq_ccflush_dc,
   pc_lq_gptr_sl_thold_3,
   pc_lq_time_sl_thold_3,
   pc_lq_repr_sl_thold_3,
   pc_lq_bolt_sl_thold_3,
   pc_lq_abst_sl_thold_3,
   pc_lq_abst_slp_sl_thold_3,
   pc_lq_func_sl_thold_3,
   pc_lq_func_slp_sl_thold_3,
   pc_lq_cfg_sl_thold_3,
   pc_lq_cfg_slp_sl_thold_3,
   pc_lq_regf_slp_sl_thold_3,
   pc_lq_func_nsl_thold_3,
   pc_lq_func_slp_nsl_thold_3,
   pc_lq_ary_nsl_thold_3,
   pc_lq_ary_slp_nsl_thold_3,
   pc_lq_sg_3,
   pc_lq_fce_3,
   pc_lq_abist_wl64_comp_ena,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_abist_ena_dc,
   pc_lq_abist_raw_dc_b,
   pc_lq_abist_g6t_bw,
   pc_lq_abist_di_g6t_2r,
   pc_lq_abist_wl256_comp_ena,
   pc_lq_abist_dcomp_g6t_2r,
   pc_lq_abist_raddr_0,
   pc_lq_abist_g6t_r_wb,
   pc_lq_bo_enable_3,
   pc_lq_bo_unload,
   pc_lq_bo_repair,
   pc_lq_bo_reset,
   pc_lq_bo_shdata,
   pc_lq_bo_select,
   lq_pc_bo_fail,
   lq_pc_bo_diagout,
   an_ac_lbist_ary_wrt_thru_dc,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_en_dc,
   an_ac_atpg_en_dc,
   an_ac_grffence_en_dc,
   gptr_scan_in,
   gptr_scan_out,
   abst_scan_in,
   abst_scan_out,
   time_scan_in,
   time_scan_out,
   repr_scan_in,
   repr_scan_out,
   regf_scan_in,
   regf_scan_out,
   ccfg_scan_in,
   ccfg_scan_out,
   func_scan_in,
   func_scan_out
);

// Parameters used from tri_a2o.vh
//   parameter                                                    `THREADS = 2;
//   parameter                                                    THREAD_POOL_ENC = 1;
//   parameter                                                    EFF_IFAR_WIDTH = 20;
//   parameter                                                    EFF_IFAR = 62;
//   parameter                                                    ITAG_SIZE_ENC = 7;
//   parameter                                                    GPR_WIDTH = 64;
//   parameter                                                    GPR_WIDTH_ENC = 6;
//   parameter                                                    GPR_POOL_ENC = 6;
//   parameter                                                    AXU_SPARE_ENC = 3;
//   parameter                                                    XER_WIDTH = 10;
//   parameter                                                    XER_POOL_ENC = 4;
//   parameter                                                    CR_WIDTH = 4;
//   parameter                                                    CR_POOL_ENC = 5;
//   parameter                                                    XU0_PIPE_START = 2;
//   parameter                                                    XU0_PIPE_END = 8;
//   parameter                                                    XU1_PIPE_START = 2;
//   parameter                                                    XU1_PIPE_END = 5;
//   parameter                                                    LQ_LOAD_PIPE_START = 4;
//   parameter                                                    LQ_LOAD_PIPE_END = 8;
//   parameter                                                    LQ_REL_PIPE_START = 2;
//   parameter                                                    LQ_REL_PIPE_END = 4;
//   parameter                                                    EMQ_ENTRIES = 4;
//   parameter                                                    LMQ_ENTRIES = 8;
//   parameter                                                    LMQ_ENTRIES_ENC = 3;
//   parameter                                                    LGQ_ENTRIES = 8;		// Load Gather Queue Size
//   parameter                                                    STQ_ENTRIES = 12;
//   parameter                                                    STQ_FWD_ENTRIES = 4;
//   parameter                                                    STQ_ENTRIES_ENC = 4;
//   parameter                                                    STQ_DATA_SIZE = 64;		// 64 or 128 Bit store data sizes supported
//   parameter                                                    LDSTQ_ENTRIES = 16;
//   parameter                                                    LDSTQ_ENTRIES_ENC = 4;
//   parameter                                                    IUQ_ENTRIES = 4;
//   parameter                                                    MMQ_ENTRIES = 1;
//   parameter                                                    REAL_IFAR_WIDTH = 42;
//   parameter                                                    L_ENDIAN_M = 1;
//   parameter                                                    DC_SIZE = 15;
//   parameter                                                    CL_SIZE = 6;
//   parameter                                                    LOAD_CREDITS = 8;
//   parameter                                                    STORE_CREDITS = 32;
//   parameter                                                    UCODE_ENTRIES_ENC = 3;
//   parameter                                                    BUILD_PFETCH = 1;		// 1=> include pfetch in the build, 0=> build without pfetch
//   parameter                                                    PF_IFAR_WIDTH = 12;		// number of IAR bits used by prefetch
//   parameter                                                    PFETCH_INITIAL_DEPTH = 0;		// the initial value for the SPR that determines how many lines to prefetch
//   parameter                                                    PFETCH_Q_SIZE_ENC = 3;		// number of bits to address queue size (3 => 8 entries, 4 => 16 entries)
//   parameter                                                    PFETCH_Q_SIZE = 8;		// number of entries in prefetch queue
parameter                                                   XU0_PIPE_START = `FXU0_PIPE_START+1;
parameter                                                   XU0_PIPE_END   = `FXU0_PIPE_END;
parameter                                                   XU1_PIPE_START = `FXU1_PIPE_START+1;
parameter                                                   XU1_PIPE_END   = `FXU1_PIPE_END;

//--------------------------------------------------------------
// SPR Interface
//--------------------------------------------------------------
input                                                        xu_lq_spr_ccr2_en_trace;    // MTSPR Trace is Enabled
input                                                        xu_lq_spr_ccr2_en_pc;		// MSGSND is Enabled
input                                                        xu_lq_spr_ccr2_en_ditc;		// DITC is Enabled
input                                                        xu_lq_spr_ccr2_en_icswx;    // ICSWX is Enabled
input                                                        xu_lq_spr_ccr2_dfrat;		// Force Real Address Translation
input  [0:8]                                                 xu_lq_spr_ccr2_dfratsc;		// 0:4: wimge, 5:8: u0:3
input                                                        xu_lq_spr_ccr2_ap;		    // AP Available
input                                                        xu_lq_spr_ccr2_ucode_dis;   // Ucode Disabled
input                                                        xu_lq_spr_ccr2_notlb;		// MMU is disabled
input                                                        xu_lq_spr_xucr4_mmu_mchk;   // Machine Check on a Data ERAT Parity or Multihit Error
input                                                        xu_lq_spr_xucr4_mddmh;		// Machine Check on Data Cache Directory Multihit Error
input                                                        xu_lq_spr_xucr0_clkg_ctl;   // Clock Gating Override
input                                                        xu_lq_spr_xucr0_wlk;		// Data Cache Way Locking Enable
input                                                        xu_lq_spr_xucr0_mbar_ack;	// L2 ACK of membar and lwsync
input                                                        xu_lq_spr_xucr0_tlbsync;	// L2 ACK of tlbsync
input                                                        xu_lq_spr_xucr0_dcdis;		// Data Cache Disable
input                                                        xu_lq_spr_xucr0_aflsta;		// AXU Force Load/Store Alignment interrupt
input                                                        xu_lq_spr_xucr0_flsta;		// FX Force Load/Store Alignment interrupt
input                                                        xu_lq_spr_xucr0_clfc;		// Cache Directory Lock Flash Clear
input                                                        xu_lq_spr_xucr0_cls;		// Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
input  [0:`THREADS-1]                                        xu_lq_spr_xucr0_trace_um;	// TRACE SPR is Enabled in user mode
input                                                        xu_lq_spr_xucr0_cred;		// L2 Credit Control
input                                                        xu_lq_spr_xucr0_mddp;		// Machine Check on Data Cache Directory Parity Error
input                                                        xu_lq_spr_xucr0_mdcp;		// Machine Check on Data Cache Parity Error

 // JK Multidimmensional port
input  [0:(`THREADS*2)-1]                                    xu_lq_spr_dbcr0_dac1;		// Data Address Compare 1 Debug Event Enable
input  [0:(`THREADS*2)-1]                                    xu_lq_spr_dbcr0_dac2;		// Data Address Compare 2 Debug Event Enable
input  [0:(`THREADS*2)-1]                                    xu_lq_spr_dbcr0_dac3;		// Data Address Compare 3 Debug Event Enable
input  [0:(`THREADS*2)-1]                                    xu_lq_spr_dbcr0_dac4;		// Data Address Compare 4 Debug Event Enable


input  [0:`THREADS-1]                                        xu_lq_spr_dbcr0_idm;		// Internal Debug Mode Enable
input  [0:`THREADS-1]                                        xu_lq_spr_epcr_duvd;		// Disable Hypervisor Debug
input  [0:`THREADS-1]                                        xu_lq_spr_msr_cm;		    // 64bit mode enable
input  [0:`THREADS-1]                                        xu_lq_spr_msr_fp;		    // FP Available
input  [0:`THREADS-1]                                        xu_lq_spr_msr_spv;		    // VEC Available
input  [0:`THREADS-1]                                        xu_lq_spr_msr_gs;		    // Guest State
input  [0:`THREADS-1]                                        xu_lq_spr_msr_pr;	        // Problem State
input  [0:`THREADS-1]                                        xu_lq_spr_msr_ds;		    // Data Address Space
input  [0:`THREADS-1]                                        xu_lq_spr_msr_de;		    // Debug Interrupt Enable
input  [0:`THREADS-1]                                        xu_lq_spr_msr_ucle;         // User Cache Locking Enable
input  [0:`THREADS-1]                                        xu_lq_spr_msrp_uclep;		// User Cache Locking Enable Protect
input                                                        iu_lq_spr_iucr0_icbi_ack;	// L2 ICBI ACK Enable
output                                                       lq_xu_spr_xucr0_cul;		// Cache Lock unable to lock
output                                                       lq_xu_spr_xucr0_cslc_xuop;	// Invalidate type instruction invalidated lock
output                                                       lq_xu_spr_xucr0_cslc_binv;	// Back-Invalidate invalidated lock
output                                                       lq_xu_spr_xucr0_clo;		// Cache Lock instruction caused an overlock
output [0:`THREADS-1]                                        lq_iu_spr_dbcr3_ivc;		// Instruction Value Compare Enabled
input                                                        slowspr_val_in;
input                                                        slowspr_rw_in;
input  [0:1]                                                 slowspr_etid_in;
input  [0:9]                                                 slowspr_addr_in;
input  [64-(2**`GPR_WIDTH_ENC):63]                           slowspr_data_in;
input                                                        slowspr_done_in;
output                                                       slowspr_val_out;
output                                                       slowspr_rw_out;
output [0:1]                                                 slowspr_etid_out;
output [0:9]                                                 slowspr_addr_out;
output [64-(2**`GPR_WIDTH_ENC):63]                           slowspr_data_out;
output                                                       slowspr_done_out;

//--------------------------------------------------------------
// CP Interface
//--------------------------------------------------------------
input  [0:`THREADS-1]                                        iu_lq_cp_flush;
input  [0:`THREADS-1]                                        iu_lq_recirc_val;
 // JK Multidimmensional port
input  [0:`ITAG_SIZE_ENC-1]                                  iu_lq_cp_next_itag_t0;
`ifndef THREADS1
   input  [0:`ITAG_SIZE_ENC-1]                               iu_lq_cp_next_itag_t1;
`endif

input                                                        iu_lq_isync;
input                                                        iu_lq_csync;
output [0:`THREADS-1]                                        lq0_iu_execute_vld;
output [0:`THREADS-1]                                        lq0_iu_recirc_val;
output [0:`ITAG_SIZE_ENC-1]                                  lq0_iu_itag;
output                                                       lq0_iu_flush2ucode;
output                                                       lq0_iu_flush2ucode_type;
output                                                       lq0_iu_exception_val;
output [0:5]                                                 lq0_iu_exception;
output [0:`THREADS-1]                                        lq0_iu_dear_val;
output                                                       lq0_iu_n_flush;
output                                                       lq0_iu_np1_flush;
output                                                       lq0_iu_dacr_type;
output [0:3]                                                 lq0_iu_dacrw;
output [0:31]                                                lq0_iu_instr;
output [64-(2**`GPR_WIDTH_ENC):63]                           lq0_iu_eff_addr;
output [0:`THREADS-1]                                        lq1_iu_execute_vld;
output [0:`ITAG_SIZE_ENC-1]                                  lq1_iu_itag;
output                                                       lq1_iu_exception_val;
output [0:5]                                                 lq1_iu_exception;
output                                                       lq1_iu_n_flush;
output                                                       lq1_iu_np1_flush;
output                                                       lq1_iu_dacr_type;
output [0:3]                                                 lq1_iu_dacrw;
output [0:3]                                                 lq1_iu_perf_events;
output [0:`THREADS-1]                                        lq_iu_credit_free;
output [0:`THREADS-1]                                        sq_iu_credit_free;

input  [0:`THREADS-1]                                        iu_lq_i0_completed;
 // JK Multidimmensional port
input  [0:`ITAG_SIZE_ENC-1]                                  iu_lq_i0_completed_itag_t0;
`ifndef THREADS1
   input  [0:`ITAG_SIZE_ENC-1]                               iu_lq_i0_completed_itag_t1;
`endif
input  [0:`THREADS-1]                                        iu_lq_i1_completed;
 // JK Multidimmensional port
input  [0:`ITAG_SIZE_ENC-1]                                  iu_lq_i1_completed_itag_t0;
`ifndef THREADS1
   input  [0:`ITAG_SIZE_ENC-1]                               iu_lq_i1_completed_itag_t1;
`endif
input  [0:`THREADS-1]                                        iu_lq_request;
input  [0:1]                                                 iu_lq_cTag;
input  [64-`REAL_IFAR_WIDTH:59]                              iu_lq_ra;
input  [0:4]                                                 iu_lq_wimge;
input  [0:3]                                                 iu_lq_userdef;
output [0:`THREADS-1]                                        lq_iu_icbi_val;
output [64-`REAL_IFAR_WIDTH:57]                              lq_iu_icbi_addr;
input [0:`THREADS-1]                                         iu_lq_icbi_complete;
output                                                       lq_iu_ici_val;

//--------------------------------------------------------------
// Interface with XU DERAT
//--------------------------------------------------------------
input                                                        xu_lq_act;
input  [0:`THREADS-1]                                        xu_lq_val;
input                                                        xu_lq_is_eratre;
input                                                        xu_lq_is_eratwe;
input                                                        xu_lq_is_eratsx;
input                                                        xu_lq_is_eratilx;
input  [0:1]                                                 xu_lq_ws;
input  [0:4]                                                 xu_lq_ra_entry;
input  [64-(2**`GPR_WIDTH_ENC):63]                           xu_lq_rs_data;
input                                                        xu_lq_hold_req;
output [64-(2**`GPR_WIDTH_ENC):63]                           lq_xu_ex5_data;
output                                                       lq_xu_ord_par_err;
output                                                       lq_xu_ord_read_done;
output                                                       lq_xu_ord_write_done;

//--------------------------------------------------------------
// Doorbell Interface with XU
//--------------------------------------------------------------
output                                                       lq_xu_dbell_val;
output [0:4]                                                 lq_xu_dbell_type;
output                                                       lq_xu_dbell_brdcast;
output                                                       lq_xu_dbell_lpid_match;
output [50:63]                                               lq_xu_dbell_pirtag;

//--------------------------------------------------------------
// Interface with RV
//--------------------------------------------------------------
input  [0:`THREADS-1]                                        rv_lq_rv1_i0_vld;
input                                                        rv_lq_rv1_i0_ucode_preissue;
input                                                        rv_lq_rv1_i0_2ucode;
input  [0:`UCODE_ENTRIES_ENC-1]                              rv_lq_rv1_i0_ucode_cnt;
input  [0:2]                                                 rv_lq_rv1_i0_s3_t;
input                                                        rv_lq_rv1_i0_isLoad;
input                                                        rv_lq_rv1_i0_isStore;
input  [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i0_itag;
input                                                        rv_lq_rv1_i0_rte_lq;
input                                                        rv_lq_rv1_i0_rte_sq;
input  [61-`PF_IFAR_WIDTH+1:61]                              rv_lq_rv1_i0_ifar;
input  [0:`THREADS-1]                                        rv_lq_rv1_i1_vld;
input                                                        rv_lq_rv1_i1_ucode_preissue;
input                                                        rv_lq_rv1_i1_2ucode;
input  [0:`UCODE_ENTRIES_ENC-1]                              rv_lq_rv1_i1_ucode_cnt;
input  [0:2]                                                 rv_lq_rv1_i1_s3_t;
input                                                        rv_lq_rv1_i1_isLoad;
input                                                        rv_lq_rv1_i1_isStore;
input  [0:`ITAG_SIZE_ENC-1]                                  rv_lq_rv1_i1_itag;
input                                                        rv_lq_rv1_i1_rte_lq;
input                                                        rv_lq_rv1_i1_rte_sq;
input  [61-`PF_IFAR_WIDTH+1:61]                              rv_lq_rv1_i1_ifar;

input  [0:`THREADS-1]                                        rv_lq_rvs_empty;
input  [0:`THREADS-1]                                        rv_lq_vld;
input                                                        rv_lq_isLoad;
input  [0:`ITAG_SIZE_ENC-1]                                  rv_lq_ex0_itag;
input  [0:31]                                                rv_lq_ex0_instr;
input  [0:1]                                                 rv_lq_ex0_ucode;
input  [0:`UCODE_ENTRIES_ENC-1]                              rv_lq_ex0_ucode_cnt;
input                                                        rv_lq_ex0_t1_v;
input  [0:`GPR_POOL_ENC-1]                                   rv_lq_ex0_t1_p;
input  [0:`GPR_POOL_ENC-1]                                   rv_lq_ex0_t3_p;
input                                                        rv_lq_ex0_s1_v;
input                                                        rv_lq_ex0_s2_v;

output [0:`THREADS-1]                                        lq_rv_itag0_vld;
output [0:`ITAG_SIZE_ENC-1]                                  lq_rv_itag0;
output                                                       lq_rv_itag0_abort;
output                                                       lq_rv_ex2_s1_abort;
output                                                       lq_rv_ex2_s2_abort;
output                                                       lq_rv_hold_all;
output [0:`THREADS-1]                                        lq_rv_itag1_vld;
output [0:`ITAG_SIZE_ENC-1]                                  lq_rv_itag1;
output                                                       lq_rv_itag1_restart;
output                                                       lq_rv_itag1_abort;
output                                                       lq_rv_itag1_hold;
output                                                       lq_rv_itag1_cord;
output [0:`THREADS-1]                                        lq_rv_itag2_vld;
output [0:`ITAG_SIZE_ENC-1]                                  lq_rv_itag2;
output [0:`THREADS-1]                                        lq_rv_clr_hold;

//-------------------------------------------------------------------
// Interface with Bypass Controller
//-------------------------------------------------------------------
input [2:12]                                                 rv_lq_ex0_s1_xu0_sel;
input [2:12]                                                 rv_lq_ex0_s2_xu0_sel;
input [2:7]                                                  rv_lq_ex0_s1_xu1_sel;
input [2:7]                                                  rv_lq_ex0_s2_xu1_sel;
input [4:8]                                                  rv_lq_ex0_s1_lq_sel;
input [4:8]                                                  rv_lq_ex0_s2_lq_sel;
input [2:3]                                                  rv_lq_ex0_s1_rel_sel;
input [2:3]                                                  rv_lq_ex0_s2_rel_sel;

//--------------------------------------------------------------
// Interface with Regfiles
//--------------------------------------------------------------
input [0:`THREADS-1]                                         xu_lq_xer_cp_rd;
input [64-(2**`GPR_WIDTH_ENC):63]                            rv_lq_gpr_ex1_r0d;
input [64-(2**`GPR_WIDTH_ENC):63]                            rv_lq_gpr_ex1_r1d;
output                                                       lq_rv_gpr_ex6_we;
output [0:`GPR_POOL_ENC+`THREAD_POOL_ENC-1]                   lq_rv_gpr_ex6_wa;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_ex6_wd;
output                                                       lq_xu_gpr_ex5_we;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREAD_POOL_ENC-1]   lq_xu_gpr_ex5_wa;
output                                                       lq_rv_gpr_rel_we;
output                                                       lq_xu_gpr_rel_we;
output                                                       lq_xu_axu_rel_we;
output                                                       lq_xu_axu_rel_le;
output [0:`GPR_POOL_ENC+`THREAD_POOL_ENC-1]                  lq_rv_gpr_rel_wa;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREAD_POOL_ENC-1]   lq_xu_gpr_rel_wa;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_rel_wd;
output [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)]     lq_xu_gpr_rel_wd;
output                                                       lq_xu_cr_l2_we;
output [0:`CR_POOL_ENC+`THREAD_POOL_ENC-1]                   lq_xu_cr_l2_wa;
output [0:`CR_WIDTH-1]                                       lq_xu_cr_l2_wd;
output                                                       lq_xu_cr_ex5_we;
output [0:`CR_POOL_ENC+`THREAD_POOL_ENC-1]                   lq_xu_cr_ex5_wa;
output                                                       lq_xu_ex5_abort;

//-------------------------------------------------------------------
// Interface with XU0
//-------------------------------------------------------------------
input                                                        xu0_lq_ex3_act;
input                                                        xu0_lq_ex3_abort;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu0_lq_ex3_rt;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu0_lq_ex4_rt;
input                                                        xu0_lq_ex6_act;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu0_lq_ex6_rt;
output                                                       lq_xu_ex5_act;
output [0:`CR_WIDTH-1]                                       lq_xu_ex5_cr;
output [(128-`STQ_DATA_SIZE):127]                            lq_xu_ex5_rt;

//-------------------------------------------------------------------
// Interface with XU1
//-------------------------------------------------------------------
input                                                        xu1_lq_ex3_act;
input                                                        xu1_lq_ex3_abort;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu1_lq_ex3_rt;
input [0:`THREADS-1]                                         xu1_lq_ex2_stq_val;
input [0:`ITAG_SIZE_ENC-1]                                   xu1_lq_ex2_stq_itag;
input [1:4]                                                  xu1_lq_ex2_stq_size;
input [(64-(2**`GPR_WIDTH_ENC))/8:7]                         xu1_lq_ex2_stq_dvc1_cmp;
input [(64-(2**`GPR_WIDTH_ENC))/8:7]                         xu1_lq_ex2_stq_dvc2_cmp;
input                                                        xu1_lq_ex3_illeg_lswx;
input                                                        xu1_lq_ex3_strg_noop;

//-------------------------------------------------------------------
// Interface with AXU PassThru with XU
//-------------------------------------------------------------------
input [0:`THREADS-1]                                         xu_lq_axu_ex_stq_val;
input [0:`ITAG_SIZE_ENC-1]                                   xu_lq_axu_ex_stq_itag;
input [(128-`STQ_DATA_SIZE):127]                             xu_lq_axu_exp1_stq_data;
output [59:63]                                               lq_xu_axu_ex4_addr;
output                                                       lq_xu_axu_ex5_we;
output                                                       lq_xu_axu_ex5_le;

//--------------------------------------------------------------
// Interface with MMU
//--------------------------------------------------------------
input [0:`THREADS-1]                                         mm_lq_lsu_req;
input [0:1]                                                  mm_lq_lsu_ttype;
input [0:4]                                                  mm_lq_lsu_wimge;
input [0:3]                                                  mm_lq_lsu_u;
input [64-`REAL_IFAR_WIDTH:63]                               mm_lq_lsu_addr;
input [0:7]                                                  mm_lq_lsu_lpid;
input                                                        mm_lq_lsu_gs;
input                                                        mm_lq_lsu_ind;
input                                                        mm_lq_lsu_lbit;
input [0:7]                                                  mm_lq_lsu_lpidr;
output                                                       lq_mm_lsu_token;
input                                                        mm_lq_hold_req;
input                                                        mm_lq_hold_done;
 // JK Multidimmensional port
input [0:13]                                                 mm_lq_pid_t0;
input [0:19]                                                 mm_lq_mmucr0_t0;
`ifndef THREADS1
   input [0:13]                                              mm_lq_pid_t1;
   input [0:19]                                              mm_lq_mmucr0_t1;
`endif

input [0:9]                                                  mm_lq_mmucr1;
input [0:4]                                                  mm_lq_rel_val;
input [0:131]                                                mm_lq_rel_data;
input [0:`EMQ_ENTRIES-1]                                     mm_lq_rel_emq;
input [0:`ITAG_SIZE_ENC-1]                                   mm_lq_itag;
input [0:`THREADS-1]                                         mm_lq_tlb_miss;		    // Request got a TLB Miss
input [0:`THREADS-1]                                         mm_lq_tlb_inelig;		// Request got a TLB Ineligible
input [0:`THREADS-1]                                         mm_lq_pt_fault;		    // Request got a PT Fault
input [0:`THREADS-1]                                         mm_lq_lrat_miss;		// Request got an LRAT Miss
input [0:`THREADS-1]                                         mm_lq_tlb_multihit;		// Request got a TLB Multihit Error
input [0:`THREADS-1]                                         mm_lq_tlb_par_err;		// Request got a TLB Parity Error
input [0:`THREADS-1]                                         mm_lq_lru_par_err;		// Request got a LRU Parity Error
input                                                        mm_lq_snoop_coming;
input                                                        mm_lq_snoop_val;
input [0:25]                                                 mm_lq_snoop_attr;
input [0:51]                                                 mm_lq_snoop_vpn;
output                                                       lq_mm_snoop_ack;
output                                                       lq_mm_req;
output                                                       lq_mm_req_nonspec;
output [0:`ITAG_SIZE_ENC-1]                                  lq_mm_req_itag;
output [64-(2**`GPR_WIDTH_ENC):51]                           lq_mm_req_epn;
output [0:`THREADS-1]                                        lq_mm_thdid;
output [0:`EMQ_ENTRIES-1]                                    lq_mm_req_emq;
output [0:1]                                                 lq_mm_ttype;
output [0:3]                                                 lq_mm_state;
output [0:7]                                                 lq_mm_lpid;
output [0:13]                                                lq_mm_tid;
output [0:`THREADS-1]                                        lq_mm_mmucr0_we;
output [0:17]                                                lq_mm_mmucr0;
output [0:`THREADS-1]                                        lq_mm_mmucr1_we;
output [0:4]                                                 lq_mm_mmucr1;
output [0:`THREADS-1]                                        lq_xu_quiesce;		// Load and Store Queue is empty
output [0:`THREADS-1]                                        lq_pc_ldq_quiesce;
output [0:`THREADS-1]                                        lq_pc_stq_quiesce;
output [0:`THREADS-1]                                        lq_pc_pfetch_quiesce;
output                                                       lq_mm_lmq_stq_empty;
output [0:`THREADS-1]                                        lq_mm_perf_dtlb;

//--------------------------------------------------------------
// Interface with PC
//--------------------------------------------------------------
input                                                        pc_lq_inj_dcachedir_ldp_parity;
input                                                        pc_lq_inj_dcachedir_ldp_multihit;
input                                                        pc_lq_inj_dcachedir_stp_parity;
input                                                        pc_lq_inj_dcachedir_stp_multihit;
input                                                        pc_lq_inj_dcache_parity;
input                                                        pc_lq_inj_prefetcher_parity;
input                                                        pc_lq_inj_relq_parity;
output                                                       lq_pc_err_derat_parity;
output                                                       lq_pc_err_dir_ldp_parity;
output                                                       lq_pc_err_dir_stp_parity;
output                                                       lq_pc_err_relq_parity;
output                                                       lq_pc_err_dcache_parity;
output                                                       lq_pc_err_derat_multihit;
output                                                       lq_pc_err_dir_ldp_multihit;
output                                                       lq_pc_err_dir_stp_multihit;
output                                                       lq_pc_err_invld_reld;		    // Reload detected without Loadmiss waiting for reload or got extra beats for cacheable request
output                                                       lq_pc_err_l2intrf_ecc;		    // Reload detected with an ECC error
output                                                       lq_pc_err_l2intrf_ue;		    // Reload detected with an uncorrectable ECC error
output                                                       lq_pc_err_l2credit_overrun;    // L2 Credits were Overrun
input  [0:`THREADS-1]                                        pc_lq_ram_active;              // Thread is in RAM mode
output                                                       lq_pc_ram_data_val;
output [64-(2**`GPR_WIDTH_ENC):63]                           lq_pc_ram_data;
output                                                       lq_pc_err_prefetcher_parity;

//--------------------------------------------------------------
// Debug Bus Control
//--------------------------------------------------------------
// Pervasive Debug Control
input                                                        pc_lq_trace_bus_enable;
input [0:10]                                                 pc_lq_debug_mux1_ctrls;
input [0:10]                                                 pc_lq_debug_mux2_ctrls;
input                                                        pc_lq_instr_trace_mode;
input [0:`THREADS-1]                                         pc_lq_instr_trace_tid;

// Pass Thru Debug Trace Bus
input [0:31]                                                 debug_bus_in;
input [0:3]                                                  coretrace_ctrls_in;

output [0:31]                                                debug_bus_out;
output [0:3]                                                 coretrace_ctrls_out;

//--------------------------------------------------------------
// Performance Event Control
//--------------------------------------------------------------
input                                                        pc_lq_event_bus_enable;
input [0:2]                                                  pc_lq_event_count_mode;
input [0:(4*`THREADS)-1]                                     event_bus_in;
output [0:(4*`THREADS)-1]                                    event_bus_out;

//--------------------------------------------------------------
// Interface with L2
//--------------------------------------------------------------
input  [6:7]                                                 an_ac_coreid;
input  [0:`THREADS-1]                                        an_ac_sync_ack;
input  [0:`THREADS-1]                                        an_ac_stcx_complete;
input  [0:`THREADS-1]                                        an_ac_stcx_pass;
input                                                        an_ac_icbi_ack;
input  [0:1]                                                 an_ac_icbi_ack_thread;
input                                                        an_ac_back_inv;
input  [64-`REAL_IFAR_WIDTH:63]                              an_ac_back_inv_addr;
input                                                        an_ac_back_inv_target_bit1;
input                                                        an_ac_back_inv_target_bit3;
input                                                        an_ac_back_inv_target_bit4;
input                                                        an_ac_flh2l2_gate;
input                                                        an_ac_req_ld_pop;
input                                                        an_ac_req_st_pop;
input                                                        an_ac_req_st_gather;
input                                                        an_ac_reld_data_vld;
input  [0:4]                                                 an_ac_reld_core_tag;
input  [0:127]                                               an_ac_reld_data;
input  [58:59]                                               an_ac_reld_qw;
input                                                        an_ac_reld_ecc_err;
input                                                        an_ac_reld_ecc_err_ue;
input                                                        an_ac_reld_data_coming;
input                                                        an_ac_reld_ditc;
input                                                        an_ac_reld_crit_qw;
input                                                        an_ac_reld_l1_dump;
input  [0:3]                                                 an_ac_req_spare_ctrl_a1;
output                                                       ac_an_req_pwr_token;
output                                                       ac_an_req;
output [64-`REAL_IFAR_WIDTH:63]                              ac_an_req_ra;
output [0:5]                                                 ac_an_req_ttype;
output [0:2]                                                 ac_an_req_thread;
output                                                       ac_an_req_wimg_w;
output                                                       ac_an_req_wimg_i;
output                                                       ac_an_req_wimg_m;
output                                                       ac_an_req_wimg_g;
output [0:3]                                                 ac_an_req_user_defined;
output [0:3]                                                 ac_an_req_spare_ctrl_a0;
output [0:4]                                                 ac_an_req_ld_core_tag;
output [0:2]                                                 ac_an_req_ld_xfr_len;
output [0:31]                                                ac_an_st_byte_enbl;
output [0:255]                                               ac_an_st_data;
output                                                       ac_an_req_endian;
output                                                       ac_an_st_data_pwr_token;

// Pervasive

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
input [0:`NCLK_WIDTH-1]                                      nclk;

// Thold inputs
input                                                        pc_lq_init_reset;
input                                                        pc_lq_ccflush_dc;
input                                                        pc_lq_gptr_sl_thold_3;
input                                                        pc_lq_time_sl_thold_3;
input                                                        pc_lq_repr_sl_thold_3;
input                                                        pc_lq_bolt_sl_thold_3;
input                                                        pc_lq_abst_sl_thold_3;
input                                                        pc_lq_abst_slp_sl_thold_3;
input                                                        pc_lq_func_sl_thold_3;
input                                                        pc_lq_func_slp_sl_thold_3;
input                                                        pc_lq_cfg_sl_thold_3;
input                                                        pc_lq_cfg_slp_sl_thold_3;
input                                                        pc_lq_regf_slp_sl_thold_3;
input                                                        pc_lq_func_nsl_thold_3;
input                                                        pc_lq_func_slp_nsl_thold_3;
input                                                        pc_lq_ary_nsl_thold_3;
input                                                        pc_lq_ary_slp_nsl_thold_3;
input                                                        pc_lq_sg_3;
input                                                        pc_lq_fce_3;

// G8T ABIST Control
input                                                        pc_lq_abist_wl64_comp_ena;
input                                                        pc_lq_abist_g8t_wenb;
input                                                        pc_lq_abist_g8t1p_renb_0;
input [0:3]                                                  pc_lq_abist_g8t_dcomp;
input                                                        pc_lq_abist_g8t_bw_1;
input                                                        pc_lq_abist_g8t_bw_0;
input [0:3]                                                  pc_lq_abist_di_0;
input [2:9]                                                  pc_lq_abist_waddr_0;

// G6T ABIST Control
input                                                        pc_lq_abist_ena_dc;
input                                                        pc_lq_abist_raw_dc_b;
input [0:1]                                                  pc_lq_abist_g6t_bw;
input [0:3]                                                  pc_lq_abist_di_g6t_2r;
input                                                        pc_lq_abist_wl256_comp_ena;
input [0:3]                                                  pc_lq_abist_dcomp_g6t_2r;
input [1:8]                                                  pc_lq_abist_raddr_0;
input                                                        pc_lq_abist_g6t_r_wb;

input                                                        pc_lq_bo_enable_3;
input                                                        pc_lq_bo_unload;
input                                                        pc_lq_bo_repair;
input                                                        pc_lq_bo_reset;
input                                                        pc_lq_bo_shdata;
input [0:13]                                                 pc_lq_bo_select;
output [0:13]                                                lq_pc_bo_fail;
output [0:13]                                                lq_pc_bo_diagout;

// Core Level Signals
input                                                        an_ac_lbist_ary_wrt_thru_dc;
input                                                        an_ac_scan_dis_dc_b;
input                                                        an_ac_scan_diag_dc;
input                                                        an_ac_lbist_en_dc;
input                                                        an_ac_atpg_en_dc;
input                                                        an_ac_grffence_en_dc;

// SCAN

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        gptr_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       gptr_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:5]                                                  abst_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:5]                                                 abst_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        time_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       time_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        repr_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       repr_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:6]                                                  regf_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:6]                                                 regf_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        ccfg_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       ccfg_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:24]                                                 func_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:24]                                                func_scan_out;


parameter                                                    tiup = 1'b1;
parameter                                                    tidn = 1'b0;
parameter                                                    UPRTAGBIT = 64 - `REAL_IFAR_WIDTH;
parameter                                                    LWRTAGBIT = 63 - (`DC_SIZE - 3);
parameter                                                    TAGSIZE = LWRTAGBIT - UPRTAGBIT + 1;
parameter                                                    PAREXTCALC = 8 - (TAGSIZE % 8);
parameter                                                    PARBITS = (TAGSIZE + PAREXTCALC)/8;
parameter                                                    WAYDATASIZE = TAGSIZE + PARBITS;
parameter                                                    AXU_TARGET_ENC = `AXU_SPARE_ENC + `GPR_POOL_ENC + `THREAD_POOL_ENC;

wire                                                         lsq_ctl_stq1_stg_act;
wire [0:`THREADS-1]                                          lsq_ctl_oldest_tid;
wire [0:`ITAG_SIZE_ENC-1]                                    lsq_ctl_oldest_itag;
wire                                                         lsq_ctl_rv0_back_inv;
wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                       lsq_ctl_rv1_back_inv_addr;
wire                                                         lsq_ctl_stq_release_itag_vld;
wire [0:`ITAG_SIZE_ENC-1]                                    lsq_ctl_stq_release_itag;
wire [0:`THREADS-1]                                          lsq_ctl_stq_release_tid;
wire                                                         lsq_ctl_ex5_ldq_restart;
wire                                                         lsq_ctl_ex5_stq_restart;
wire                                                         lsq_ctl_ex5_stq_restart_miss;
wire                                                         lsq_ctl_ex5_fwd_val;
wire [(128-`STQ_DATA_SIZE):127]                              lsq_ctl_ex5_fwd_data;
wire                                                         lsq_ctl_rv_hold_all;
wire                                                         lsq_ctl_rv_set_hold;
wire [0:`THREADS-1]                                          lsq_ctl_rv_clr_hold;
wire                                                         lsq_ctl_stq1_val;
wire [0:`ITAG_SIZE_ENC-1]                                    lsq_ctl_stq5_itag;
wire [0:AXU_TARGET_ENC-1]                                    lsq_ctl_stq5_tgpr;
wire                                                         lsq_ctl_stq1_mftgpr_val;
wire                                                         lsq_ctl_stq1_mfdpf_val;
wire                                                         lsq_ctl_stq1_mfdpa_val;
wire [0:`THREADS-1]                                          lsq_ctl_stq1_thrd_id;
wire [0:`THREADS-1]                                          lsq_ctl_rel1_thrd_id;
wire                                                         lsq_ctl_stq1_resv;
wire                                                         lsq_ctl_stq1_ci;
wire                                                         lsq_ctl_stq1_axu_val;
wire                                                         lsq_ctl_stq1_epid_val;
wire                                                         lsq_ctl_stq1_store_val;
wire                                                         lsq_ctl_stq1_lock_clr;
wire                                                         lsq_ctl_stq1_watch_clr;
wire [0:1]                                                   lsq_ctl_stq1_l_fld;
wire                                                         lsq_ctl_stq1_inval;
wire                                                         lsq_ctl_stq1_dci_val;
wire [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                       lsq_ctl_stq1_addr;
wire                                                         lsq_ctl_stq4_xucr0_cul;
wire                                                         lsq_ctl_rel1_gpr_val;
wire [0:AXU_TARGET_ENC-1]                                    lsq_ctl_rel1_ta_gpr;
wire                                                         lsq_ctl_rel1_upd_gpr;
wire                                                         lsq_ctl_rel1_clr_val;
wire                                                         lsq_ctl_rel1_set_val;
wire                                                         lsq_ctl_rel1_data_val;
wire                                                         lsq_ctl_rel1_back_inv;
wire [0:3]                                                   lsq_ctl_rel1_tag;
wire [0:1]                                                   lsq_ctl_rel1_classid;
wire                                                         lsq_ctl_rel1_lock_set;
wire                                                         lsq_ctl_rel1_watch_set;
wire                                                         lsq_ctl_rel2_blk_req;
wire                                                         lsq_ctl_stq2_blk_req;
wire                                                         lsq_ctl_rel2_upd_val;
wire [0:127]                                                 lsq_ctl_rel2_data;
wire                                                         lsq_ctl_rel3_l1dump_val;
wire                                                         lsq_ctl_rel3_clr_relq;
wire                                                         ctl_lsq_stq4_perr_reject;
wire [0:7]                                                   ctl_dat_stq5_way_perr_inval;
wire                                                         lsq_ctl_ex3_strg_val;
wire                                                         lsq_ctl_ex3_strg_noop;
wire                                                         lsq_ctl_ex3_illeg_lswx;
wire                                                         lsq_ctl_ex3_ct_val;
wire [0:5]                                                   lsq_ctl_ex3_be_ct;
wire [0:5]                                                   lsq_ctl_ex3_le_ct;
wire                                                         lsq_ctl_stq_cpl_ready;
wire [0:`ITAG_SIZE_ENC-1]                                     lsq_ctl_stq_cpl_ready_itag;
wire [0:`THREADS-1]                                           lsq_ctl_stq_cpl_ready_tid;
wire                                                         lsq_ctl_stq_n_flush;
wire                                                         lsq_ctl_stq_np1_flush;
wire                                                         lsq_ctl_stq_exception_val;
wire [0:5]                                                   lsq_ctl_stq_exception;
wire [0:3]                                                   lsq_ctl_stq_dacrw;
wire                                                         lsq_ctl_sync_in_stq;
wire                                                         lsq_ctl_sync_done;
wire                                                         ctl_lsq_stq_cpl_blk;
wire                                                         ctl_lsq_ex_pipe_full;
wire [0:`THREADS-1]                                           ctl_lsq_ex2_streq_val;
wire [0:`ITAG_SIZE_ENC-1]                                     ctl_lsq_ex2_itag;
wire [0:`THREADS-1]                                           ctl_lsq_ex2_thrd_id;
wire [0:`THREADS-1]                                           ctl_lsq_ex3_ldreq_val;
wire [0:`THREADS-1]                                           ctl_lsq_ex3_wchkall_val;
wire                                                         ctl_lsq_ex3_pfetch_val;
wire [0:15]                                                  ctl_lsq_ex3_byte_en;
wire [58:63]                                                 ctl_lsq_ex3_p_addr;
wire [0:`THREADS-1]                                           ctl_lsq_ex3_thrd_id;
wire                                                         ctl_lsq_ex3_algebraic;
wire [0:2]                                                   ctl_lsq_ex3_opsize;
wire                                                         ctl_lsq_ex4_ldreq_val;
wire                                                         ctl_lsq_ex4_binvreq_val;
wire                                                         ctl_lsq_ex4_streq_val;
wire                                                         ctl_lsq_ex4_othreq_val;
wire [64-`REAL_IFAR_WIDTH:57]                                 ctl_lsq_ex4_p_addr;
wire                                                         ctl_lsq_ex4_dReq_val;
wire                                                         ctl_lsq_ex4_gath_load;
wire                                                         ctl_lsq_ex4_send_l2;
wire                                                         ctl_lsq_ex4_has_data;
wire                                                         ctl_lsq_ex4_cline_chk;
wire [0:4]                                                   ctl_lsq_ex4_wimge;
wire                                                         ctl_lsq_ex4_byte_swap;
wire                                                         ctl_lsq_ex4_is_sync;
wire                                                         ctl_lsq_ex4_all_thrd_chk;
wire                                                         ctl_lsq_ex4_is_store;
wire                                                         ctl_lsq_ex4_is_resv;
wire                                                         ctl_lsq_ex4_is_mfgpr;
wire                                                         ctl_lsq_ex4_is_icswxr;
wire                                                         ctl_lsq_ex4_is_icbi;
wire                                                         ctl_lsq_ex4_watch_clr;
wire                                                         ctl_lsq_ex4_watch_clr_all;
wire                                                         ctl_lsq_ex4_mtspr_trace;
wire                                                         ctl_lsq_ex4_is_inval_op;
wire                                                         ctl_lsq_ex4_is_cinval;
wire                                                         ctl_lsq_ex5_lock_clr;
wire                                                         ctl_lsq_ex5_lock_set;
wire                                                         ctl_lsq_ex5_watch_set;
wire [0:AXU_TARGET_ENC-1]                                    ctl_lsq_ex5_tgpr;
wire                                                         ctl_lsq_ex5_axu_val;
wire                                                         ctl_lsq_ex5_is_epid;
wire [0:3]                                                   ctl_lsq_ex5_usr_def;
wire                                                         ctl_lsq_ex5_drop_rel;
wire                                                         ctl_lsq_ex5_flush_req;
wire                                                         ctl_lsq_ex5_flush_pfetch;
wire [0:10]                                                  ctl_lsq_ex5_cmmt_events;
wire                                                         ctl_lsq_ex5_perf_val0;
wire [0:3]                                                   ctl_lsq_ex5_perf_sel0;
wire                                                         ctl_lsq_ex5_perf_val1;
wire [0:3]                                                   ctl_lsq_ex5_perf_sel1;
wire                                                         ctl_lsq_ex5_perf_val2;
wire [0:3]                                                   ctl_lsq_ex5_perf_sel2;
wire                                                         ctl_lsq_ex5_perf_val3;
wire [0:3]                                                   ctl_lsq_ex5_perf_sel3;
wire                                                         ctl_lsq_ex5_not_touch;
wire [0:1]                                                   ctl_lsq_ex5_class_id;
wire [0:1]                                                   ctl_lsq_ex5_dvc;
wire [0:3]                                                   ctl_lsq_ex5_dacrw;
wire [0:5]                                                   ctl_lsq_ex5_ttype;
wire [0:1]                                                   ctl_lsq_ex5_l_fld;
wire                                                         ctl_lsq_ex5_load_hit;
wire [0:3]                                                   lsq_ctl_ex6_ldq_events;
wire [0:1]                                                   lsq_ctl_ex6_stq_events;
wire [0:`THREADS-1]                                          lsq_perv_ex7_events;
wire [0:(2*`THREADS)+3]                                      lsq_perv_ldq_events;
wire [0:(3*`THREADS)+2]                                      lsq_perv_stq_events;
wire [0:4+`THREADS-1]                                        lsq_perv_odq_events;
wire [0:3]                                                   ctl_lsq_ex6_ldh_dacrw;
wire [0:26]                                                  ctl_lsq_stq3_icswx_data;
wire [0:`THREADS-1]                                          ctl_lsq_dbg_int_en;
wire [0:`THREADS-1]                                          ctl_lsq_ldp_idle;
wire                                                         ctl_lsq_spr_lsucr0_b2b;
wire                                                         ctl_lsq_spr_lsucr0_lge;
wire [0:2]                                                   ctl_lsq_spr_lsucr0_lca;
wire [0:2]                                                   ctl_lsq_spr_lsucr0_sca;
wire                                                         ctl_lsq_spr_lsucr0_dfwd;
wire                                                         ctl_lsq_rv1_dir_rd_val;
wire                                                         ctl_lsq_spr_lsucr0_ford;
wire [64-(2**`GPR_WIDTH_ENC):63]                             ctl_lsq_ex4_xu1_data;
wire [0:`THREADS-1]                                          ctl_lsq_pf_empty;

wire [0:3]                                                   dir_arr_wr_enable;
wire [0:7]                                                   dir_arr_wr_way;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_wr_addr;
wire [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;
wire [0:(8*WAYDATASIZE)-1]                                   dir_arr_rd_data1;
wire                                                         ctl_dat_ex1_data_act;
wire [52:59]                                                 ctl_dat_ex2_eff_addr;
wire [0:4]                                                   ctl_dat_ex3_opsize;
wire                                                         ctl_dat_ex3_le_mode;
wire [0:3]                                                   ctl_dat_ex3_le_ld_rotsel;
wire [0:3]                                                   ctl_dat_ex3_be_ld_rotsel;
wire                                                         ctl_dat_ex3_algebraic;
wire [0:3]                                                   ctl_dat_ex3_le_alg_rotsel;
wire [64-(2**`GPR_WIDTH_ENC):63]                             ctl_spr_dvc1_dbg;
wire [64-(2**`GPR_WIDTH_ENC):63]                             ctl_spr_dvc2_dbg;

 // JK Multidimmensional wire
wire [0:(`THREADS*8)-1]                                      ctl_spr_dbcr2_dvc1be;
wire [0:(`THREADS*8)-1]                                      ctl_spr_dbcr2_dvc2be;
wire [0:(`THREADS*2)-1]                                      ctl_spr_dbcr2_dvc1m;
wire [0:(`THREADS*2)-1]                                      ctl_spr_dbcr2_dvc2m;

// LQ Pervasive
wire [0:18+`THREADS-1]                                       ctl_perv_ex6_perf_events;
wire [0:6+`THREADS-1]                                        ctl_perv_stq4_perf_events;
wire [0:(`THREADS*3)+1]                                      ctl_perv_dir_perf_events;

wire [0:7]                                                   ctl_dat_ex4_way_hit;
wire [0:7]                                                   dat_ctl_dcarr_perr_way;
wire [(128-`STQ_DATA_SIZE):127]                              dat_ctl_ex5_load_data;
wire [(128-`STQ_DATA_SIZE):127]                              dat_ctl_stq6_axu_data;
wire                                                         stq4_dcarr_wren;
wire [0:7]                                                   stq4_dcarr_way_en;
wire                                                         lsq_dat_stq1_stg_act;
wire                                                         lsq_dat_stq1_val;
wire                                                         lsq_dat_stq1_mftgpr_val;
wire                                                         lsq_dat_stq1_store_val;
wire [0:15]                                                  lsq_dat_stq1_byte_en;
wire [0:2]                                                   lsq_dat_stq1_op_size;
wire                                                         lsq_dat_stq1_le_mode;
wire [52:63]                                                 lsq_dat_stq1_addr;
wire                                                         lsq_dat_stq2_blk_req;
wire [0:143]                                                 lsq_dat_stq2_store_data;
wire                                                         lsq_dat_rel1_data_val;
wire [57:59]                                                 lsq_dat_rel1_qw;
wire [0:127]                                                 dat_lsq_stq4_128data;
wire [0:`THREADS-1]                                          odq_pf_report_tid;
wire [0:`ITAG_SIZE_ENC-1]                                    odq_pf_report_itag;
wire                                                         odq_pf_resolved;

wire                                                         bo_enable_2;
wire                                                         sg_2;
wire                                                         func_sl_thold_2;
wire                                                         func_nsl_thold_2;
wire                                                         func_slp_sl_thold_2;
wire                                                         func_slp_nsl_thold_2;
wire                                                         ary_nsl_thold_2;
wire                                                         ary_slp_nsl_thold_2;
wire                                                         time_sl_thold_2;
wire                                                         abst_sl_thold_2;
wire                                                         abst_slp_sl_thold_2;
wire                                                         repr_sl_thold_2;
wire                                                         bolt_sl_thold_2;
wire                                                         cfg_sl_thold_2;
wire                                                         cfg_slp_sl_thold_2;
wire                                                         regf_slp_sl_thold_2;
wire                                                         fce_2;
wire                                                         clkoff_dc_b;
wire                                                         d_mode_dc;
wire [0:9]                                                   delay_lclkr_dc;
wire [0:9]                                                   mpw1_dc_b;
wire                                                         mpw2_dc_b;
wire                                                         g6t_clkoff_dc_b;
wire                                                         g6t_d_mode_dc;
wire [0:4]                                                   g6t_delay_lclkr_dc;
wire [0:4]                                                   g6t_mpw1_dc_b;
wire                                                         g6t_mpw2_dc_b;
wire                                                         g8t_clkoff_dc_b;
wire                                                         g8t_d_mode_dc;
wire [0:4]                                                   g8t_delay_lclkr_dc;
wire [0:4]                                                   g8t_mpw1_dc_b;
wire                                                         g8t_mpw2_dc_b;
wire                                                         cam_clkoff_dc_b;
wire                                                         cam_d_mode_dc;
wire [0:4]                                                   cam_delay_lclkr_dc;
wire                                                         cam_act_dis_dc;
wire [0:4]                                                   cam_mpw1_dc_b;
wire                                                         cam_mpw2_dc_b;
wire                                                         ctl_time_scan_out;
wire                                                         dat_time_scan_out;
wire                                                         ctl_repr_scan_out;
wire                                                         dat_repr_scan_out;

wire  [0:(`THREADS*`ITAG_SIZE_ENC)-1]                        iu_lq_cp_next_itag;
wire  [0:(`THREADS*`ITAG_SIZE_ENC)-1]                        iu_lq_i0_completed_itag;
wire  [0:(`THREADS*`ITAG_SIZE_ENC)-1]                        iu_lq_i1_completed_itag;
wire  [0:(`THREADS*14)-1]                                    mm_lq_pid;
wire  [0:(`THREADS*20)-1]                                    mm_lq_mmucr0;
wire  [18:24]                                                lsq_func_scan_out;
wire                                                         perv_func_scan_in;
wire                                                         perv_func_scan_out;
wire [0:23]                                                  ctl_perv_spr_lesr1;
wire [0:23]                                                  ctl_perv_spr_lesr2;
wire [0:31]                                                  lq_debug_bus0;
wire							     vdd;
wire							     gnd;

`ifdef THREADS1
    assign iu_lq_cp_next_itag = iu_lq_cp_next_itag_t0;
    assign iu_lq_i0_completed_itag = iu_lq_i0_completed_itag_t0;
    assign iu_lq_i1_completed_itag = iu_lq_i1_completed_itag_t0;
    assign mm_lq_pid = mm_lq_pid_t0;
    assign mm_lq_mmucr0 = mm_lq_mmucr0_t0;
`endif
`ifndef THREADS1
   assign iu_lq_cp_next_itag = {iu_lq_cp_next_itag_t0, iu_lq_cp_next_itag_t1};
   assign iu_lq_i0_completed_itag = {iu_lq_i0_completed_itag_t0, iu_lq_i0_completed_itag_t1};
   assign iu_lq_i1_completed_itag = {iu_lq_i1_completed_itag_t0, iu_lq_i1_completed_itag_t1};
   assign mm_lq_pid = {mm_lq_pid_t0, mm_lq_pid_t1};
   assign mm_lq_mmucr0 = {mm_lq_mmucr0_t0, mm_lq_mmucr0_t1};
`endif

assign vdd = 1'b1;
//assign vcs = 1'b1;
assign gnd = 1'b0;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LQ CONTROL
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Order Queue Size
lq_ctl #(.XU0_PIPE_START(XU0_PIPE_START), .XU0_PIPE_END(XU0_PIPE_END), .XU1_PIPE_START(XU1_PIPE_START), .XU1_PIPE_END(XU1_PIPE_END), .WAYDATASIZE(WAYDATASIZE)) ctl(

   //--------------------------------------------------------------
   // SPR Interface
   //--------------------------------------------------------------
   .xu_lq_spr_ccr2_en_trace(xu_lq_spr_ccr2_en_trace),
   .xu_lq_spr_ccr2_en_pc(xu_lq_spr_ccr2_en_pc),
   .xu_lq_spr_ccr2_en_ditc(xu_lq_spr_ccr2_en_ditc),
   .xu_lq_spr_ccr2_en_icswx(xu_lq_spr_ccr2_en_icswx),
   .xu_lq_spr_ccr2_dfrat(xu_lq_spr_ccr2_dfrat),
   .xu_lq_spr_ccr2_dfratsc(xu_lq_spr_ccr2_dfratsc),
   .xu_lq_spr_ccr2_ap(xu_lq_spr_ccr2_ap),
   .xu_lq_spr_ccr2_ucode_dis(xu_lq_spr_ccr2_ucode_dis),
   .xu_lq_spr_ccr2_notlb(xu_lq_spr_ccr2_notlb),
   .xu_lq_spr_xucr0_clkg_ctl(xu_lq_spr_xucr0_clkg_ctl),
   .xu_lq_spr_xucr0_wlk(xu_lq_spr_xucr0_wlk),
   .xu_lq_spr_xucr0_mbar_ack(xu_lq_spr_xucr0_mbar_ack),
   .xu_lq_spr_xucr0_tlbsync(xu_lq_spr_xucr0_tlbsync),
   .xu_lq_spr_xucr0_dcdis(xu_lq_spr_xucr0_dcdis),
   .xu_lq_spr_xucr0_aflsta(xu_lq_spr_xucr0_aflsta),
   .xu_lq_spr_xucr0_flsta(xu_lq_spr_xucr0_flsta),
   .xu_lq_spr_xucr0_clfc(xu_lq_spr_xucr0_clfc),
   .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),
   .xu_lq_spr_xucr0_trace_um(xu_lq_spr_xucr0_trace_um),
   .xu_lq_spr_xucr0_mddp(xu_lq_spr_xucr0_mddp),
   .xu_lq_spr_xucr0_mdcp(xu_lq_spr_xucr0_mdcp),
   .xu_lq_spr_xucr4_mmu_mchk(xu_lq_spr_xucr4_mmu_mchk),
   .xu_lq_spr_xucr4_mddmh(xu_lq_spr_xucr4_mddmh),
   .xu_lq_spr_msr_cm(xu_lq_spr_msr_cm),
   .xu_lq_spr_msr_fp(xu_lq_spr_msr_fp),
   .xu_lq_spr_msr_spv(xu_lq_spr_msr_spv),
   .xu_lq_spr_msr_gs(xu_lq_spr_msr_gs),
   .xu_lq_spr_msr_pr(xu_lq_spr_msr_pr),
   .xu_lq_spr_msr_ds(xu_lq_spr_msr_ds),
   .xu_lq_spr_msr_de(xu_lq_spr_msr_de),
   .xu_lq_spr_msr_ucle(xu_lq_spr_msr_ucle),
   .xu_lq_spr_msrp_uclep(xu_lq_spr_msrp_uclep),
   .xu_lq_spr_dbcr0_dac1(xu_lq_spr_dbcr0_dac1),
   .xu_lq_spr_dbcr0_dac2(xu_lq_spr_dbcr0_dac2),
   .xu_lq_spr_dbcr0_dac3(xu_lq_spr_dbcr0_dac3),
   .xu_lq_spr_dbcr0_dac4(xu_lq_spr_dbcr0_dac4),
   .xu_lq_spr_dbcr0_idm(xu_lq_spr_dbcr0_idm),
   .xu_lq_spr_epcr_duvd(xu_lq_spr_epcr_duvd),
   .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
   .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
   .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
   .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),
   .lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
   .slowspr_val_in(slowspr_val_in),
   .slowspr_rw_in(slowspr_rw_in),
   .slowspr_etid_in(slowspr_etid_in),
   .slowspr_addr_in(slowspr_addr_in),
   .slowspr_data_in(slowspr_data_in),
   .slowspr_done_in(slowspr_done_in),
   .slowspr_val_out(slowspr_val_out),
   .slowspr_rw_out(slowspr_rw_out),
   .slowspr_etid_out(slowspr_etid_out),
   .slowspr_addr_out(slowspr_addr_out),
   .slowspr_data_out(slowspr_data_out),
   .slowspr_done_out(slowspr_done_out),

   //--------------------------------------------------------------
   // Interface with IU
   //--------------------------------------------------------------
   .iu_lq_cp_flush(iu_lq_cp_flush),
   .iu_lq_recirc_val(iu_lq_recirc_val),
   .iu_lq_cp_next_itag(iu_lq_cp_next_itag),
   .iu_lq_isync(iu_lq_isync),
   .iu_lq_csync(iu_lq_csync),
   .lq0_iu_execute_vld(lq0_iu_execute_vld),
   .lq0_iu_recirc_val(lq0_iu_recirc_val),
   .lq0_iu_itag(lq0_iu_itag),
   .lq0_iu_flush2ucode(lq0_iu_flush2ucode),
   .lq0_iu_flush2ucode_type(lq0_iu_flush2ucode_type),
   .lq0_iu_exception_val(lq0_iu_exception_val),
   .lq0_iu_exception(lq0_iu_exception),
   .lq0_iu_dear_val(lq0_iu_dear_val),
   .lq0_iu_n_flush(lq0_iu_n_flush),
   .lq0_iu_np1_flush(lq0_iu_np1_flush),
   .lq0_iu_dacr_type(lq0_iu_dacr_type),
   .lq0_iu_dacrw(lq0_iu_dacrw),
   .lq0_iu_instr(lq0_iu_instr),
   .lq0_iu_eff_addr(lq0_iu_eff_addr),

   //   IU interface to RV for pfetch predictor table0
   // port 0
   .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
   .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
   .rv_lq_rv1_i0_2ucode(rv_lq_rv1_i0_2ucode),
   .rv_lq_rv1_i0_ucode_cnt(rv_lq_rv1_i0_ucode_cnt),
   .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
   .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
   .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
   .rv_lq_rv1_i0_ifar(rv_lq_rv1_i0_ifar),

   // port 1
   .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
   .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
   .rv_lq_rv1_i1_2ucode(rv_lq_rv1_i1_2ucode),
   .rv_lq_rv1_i1_ucode_cnt(rv_lq_rv1_i1_ucode_cnt),
   .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
   .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
   .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
   .rv_lq_rv1_i1_ifar(rv_lq_rv1_i1_ifar),

   // release itag to pfetch
   .odq_pf_report_tid(odq_pf_report_tid),
   .odq_pf_report_itag(odq_pf_report_itag),
   .odq_pf_resolved(odq_pf_resolved),

   //--------------------------------------------------------------
   // Interface with XU DERAT
   //--------------------------------------------------------------
   .xu_lq_act(xu_lq_act),
   .xu_lq_val(xu_lq_val),
   .xu_lq_is_eratre(xu_lq_is_eratre),
   .xu_lq_is_eratwe(xu_lq_is_eratwe),
   .xu_lq_is_eratsx(xu_lq_is_eratsx),
   .xu_lq_is_eratilx(xu_lq_is_eratilx),
   .xu_lq_ws(xu_lq_ws),
   .xu_lq_ra_entry(xu_lq_ra_entry),
   .xu_lq_rs_data(xu_lq_rs_data),
   .xu_lq_hold_req(xu_lq_hold_req),
   .lq_xu_ex5_data(lq_xu_ex5_data),
   .lq_xu_ord_par_err(lq_xu_ord_par_err),
   .lq_xu_ord_read_done(lq_xu_ord_read_done),
   .lq_xu_ord_write_done(lq_xu_ord_write_done),

   //--------------------------------------------------------------
   // Interface with RV
   //--------------------------------------------------------------
   .rv_lq_vld(rv_lq_vld),
   .rv_lq_ex0_itag(rv_lq_ex0_itag),
   .rv_lq_ex0_instr(rv_lq_ex0_instr),
   .rv_lq_ex0_ucode(rv_lq_ex0_ucode),
   .rv_lq_ex0_ucode_cnt(rv_lq_ex0_ucode_cnt),
   .rv_lq_ex0_t1_v(rv_lq_ex0_t1_v),
   .rv_lq_ex0_t1_p(rv_lq_ex0_t1_p),
   .rv_lq_ex0_t3_p(rv_lq_ex0_t3_p),
   .rv_lq_ex0_s1_v(rv_lq_ex0_s1_v),
   .rv_lq_ex0_s2_v(rv_lq_ex0_s2_v),

   .lq_rv_itag0(lq_rv_itag0),
   .lq_rv_itag0_vld(lq_rv_itag0_vld),
   .lq_rv_itag0_abort(lq_rv_itag0_abort),
   .lq_rv_ex2_s1_abort(lq_rv_ex2_s1_abort),
   .lq_rv_ex2_s2_abort(lq_rv_ex2_s2_abort),
   .lq_rv_hold_all(lq_rv_hold_all),
   .lq_rv_itag1_vld(lq_rv_itag1_vld),
   .lq_rv_itag1(lq_rv_itag1),
   .lq_rv_itag1_restart(lq_rv_itag1_restart),
   .lq_rv_itag1_abort(lq_rv_itag1_abort),
   .lq_rv_itag1_hold(lq_rv_itag1_hold),
   .lq_rv_itag1_cord(lq_rv_itag1_cord),
   .lq_rv_clr_hold(lq_rv_clr_hold),

   //-------------------------------------------------------------------
   // Interface with Bypass Controller
   //-------------------------------------------------------------------
   .rv_lq_ex0_s1_xu0_sel(rv_lq_ex0_s1_xu0_sel),
   .rv_lq_ex0_s2_xu0_sel(rv_lq_ex0_s2_xu0_sel),
   .rv_lq_ex0_s1_xu1_sel(rv_lq_ex0_s1_xu1_sel),
   .rv_lq_ex0_s2_xu1_sel(rv_lq_ex0_s2_xu1_sel),
   .rv_lq_ex0_s1_lq_sel(rv_lq_ex0_s1_lq_sel),
   .rv_lq_ex0_s2_lq_sel(rv_lq_ex0_s2_lq_sel),
   .rv_lq_ex0_s1_rel_sel(rv_lq_ex0_s1_rel_sel),
   .rv_lq_ex0_s2_rel_sel(rv_lq_ex0_s2_rel_sel),

   //--------------------------------------------------------------
   // Interface with Regfiles
   //--------------------------------------------------------------
   .xu_lq_xer_cp_rd(xu_lq_xer_cp_rd),
   .rv_lq_gpr_ex1_r0d(rv_lq_gpr_ex1_r0d),
   .rv_lq_gpr_ex1_r1d(rv_lq_gpr_ex1_r1d),
   .lq_rv_gpr_ex6_we(lq_rv_gpr_ex6_we),
   .lq_rv_gpr_ex6_wa(lq_rv_gpr_ex6_wa),
   .lq_rv_gpr_ex6_wd(lq_rv_gpr_ex6_wd),
   .lq_xu_gpr_ex5_we(lq_xu_gpr_ex5_we),
   .lq_xu_gpr_ex5_wa(lq_xu_gpr_ex5_wa),
   .lq_rv_gpr_rel_we(lq_rv_gpr_rel_we),
   .lq_xu_gpr_rel_we(lq_xu_gpr_rel_we),
   .lq_xu_axu_rel_we(lq_xu_axu_rel_we),
   .lq_rv_gpr_rel_wa(lq_rv_gpr_rel_wa),
   .lq_xu_gpr_rel_wa(lq_xu_gpr_rel_wa),
   .lq_rv_gpr_rel_wd(lq_rv_gpr_rel_wd),
   .lq_xu_gpr_rel_wd(lq_xu_gpr_rel_wd),
   .lq_xu_cr_ex5_we(lq_xu_cr_ex5_we),
   .lq_xu_cr_ex5_wa(lq_xu_cr_ex5_wa),

   //-------------------------------------------------------------------
   // Interface with XU0
   //-------------------------------------------------------------------
   .xu0_lq_ex3_act(xu0_lq_ex3_act),
   .xu0_lq_ex3_abort(xu0_lq_ex3_abort),
   .xu0_lq_ex3_rt(xu0_lq_ex3_rt),
   .xu0_lq_ex4_rt(xu0_lq_ex4_rt),
   .xu0_lq_ex6_act(xu0_lq_ex6_act),
   .xu0_lq_ex6_rt(xu0_lq_ex6_rt),
   .lq_xu_ex5_act(lq_xu_ex5_act),
   .lq_xu_ex5_cr(lq_xu_ex5_cr),
   .lq_xu_ex5_rt(lq_xu_ex5_rt),
   .lq_xu_ex5_abort(lq_xu_ex5_abort),

   //-------------------------------------------------------------------
   // Interface with XU1
   //-------------------------------------------------------------------
   .xu1_lq_ex3_act(xu1_lq_ex3_act),
   .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
   .xu1_lq_ex3_rt(xu1_lq_ex3_rt),

   //-------------------------------------------------------------------
   // Interface with AXU PassThru with XU
   //-------------------------------------------------------------------
   .lq_xu_axu_ex4_addr(lq_xu_axu_ex4_addr),
   .lq_xu_axu_ex5_we(lq_xu_axu_ex5_we),
   .lq_xu_axu_ex5_le(lq_xu_axu_ex5_le),

   //--------------------------------------------------------------
   // Interface with MMU
   //--------------------------------------------------------------
   .mm_lq_hold_req(mm_lq_hold_req),
   .mm_lq_hold_done(mm_lq_hold_done),
   .mm_lq_pid(mm_lq_pid),
   .mm_lq_lsu_lpidr(mm_lq_lsu_lpidr),
   .mm_lq_mmucr0(mm_lq_mmucr0),
   .mm_lq_mmucr1(mm_lq_mmucr1),
   .mm_lq_rel_val(mm_lq_rel_val),
   .mm_lq_rel_data(mm_lq_rel_data),
   .mm_lq_rel_emq(mm_lq_rel_emq),
   .mm_lq_itag(mm_lq_itag),
   .mm_lq_tlb_miss(mm_lq_tlb_miss),
   .mm_lq_tlb_inelig(mm_lq_tlb_inelig),
   .mm_lq_pt_fault(mm_lq_pt_fault),
   .mm_lq_lrat_miss(mm_lq_lrat_miss),
   .mm_lq_tlb_multihit(mm_lq_tlb_multihit),
   .mm_lq_tlb_par_err(mm_lq_tlb_par_err),
   .mm_lq_lru_par_err(mm_lq_lru_par_err),
   .mm_lq_snoop_coming(mm_lq_snoop_coming),
   .mm_lq_snoop_val(mm_lq_snoop_val),
   .mm_lq_snoop_attr(mm_lq_snoop_attr),
   .mm_lq_snoop_vpn(mm_lq_snoop_vpn),
   .lq_mm_snoop_ack(lq_mm_snoop_ack),
   .lq_mm_req(lq_mm_req),
   .lq_mm_req_nonspec(lq_mm_req_nonspec),
   .lq_mm_req_itag(lq_mm_req_itag),
   .lq_mm_req_epn(lq_mm_req_epn),
   .lq_mm_thdid(lq_mm_thdid),
   .lq_mm_req_emq(lq_mm_req_emq),
   .lq_mm_ttype(lq_mm_ttype),
   .lq_mm_state(lq_mm_state),
   .lq_mm_lpid(lq_mm_lpid),
   .lq_mm_tid(lq_mm_tid),
   .lq_mm_mmucr0_we(lq_mm_mmucr0_we),
   .lq_mm_mmucr0(lq_mm_mmucr0),
   .lq_mm_mmucr1_we(lq_mm_mmucr1_we),
   .lq_mm_mmucr1(lq_mm_mmucr1),
   .lq_mm_perf_dtlb(lq_mm_perf_dtlb),

   //--------------------------------------------------------------
   // Interface with PC
   //--------------------------------------------------------------
   .pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
   .pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
   .pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),
   .pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),

   //--------------------------------------------------------------
   // Interface with Load/Store Queses
   //--------------------------------------------------------------
   .lsq_ctl_oldest_tid(lsq_ctl_oldest_tid),
   .lsq_ctl_oldest_itag(lsq_ctl_oldest_itag),
   .lsq_ctl_stq1_stg_act(lsq_ctl_stq1_stg_act),
   .lsq_ctl_rv0_back_inv(lsq_ctl_rv0_back_inv),
   .lsq_ctl_rv1_back_inv_addr(lsq_ctl_rv1_back_inv_addr),
   .lsq_ctl_stq_release_itag_vld(lsq_ctl_stq_release_itag_vld),
   .lsq_ctl_stq_release_itag(lsq_ctl_stq_release_itag),
   .lsq_ctl_stq_release_tid(lsq_ctl_stq_release_tid),
   .lsq_ctl_ex5_ldq_restart(lsq_ctl_ex5_ldq_restart),
   .lsq_ctl_ex5_stq_restart(lsq_ctl_ex5_stq_restart),
   .lsq_ctl_ex5_stq_restart_miss(lsq_ctl_ex5_stq_restart_miss),
   .lsq_ctl_ex5_fwd_val(lsq_ctl_ex5_fwd_val),
   .lsq_ctl_ex5_fwd_data(lsq_ctl_ex5_fwd_data),
   .lsq_ctl_rv_hold_all(lsq_ctl_rv_hold_all),
   .lsq_ctl_rv_set_hold(lsq_ctl_rv_set_hold),
   .lsq_ctl_rv_clr_hold(lsq_ctl_rv_clr_hold),
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq1_mftgpr_val(lsq_ctl_stq1_mftgpr_val),
   .lsq_ctl_stq1_mfdpf_val(lsq_ctl_stq1_mfdpf_val),
   .lsq_ctl_stq1_mfdpa_val(lsq_ctl_stq1_mfdpa_val),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_stq5_itag(lsq_ctl_stq5_itag),
   .lsq_ctl_stq5_tgpr(lsq_ctl_stq5_tgpr),
   .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),
   .lsq_ctl_rel1_thrd_id(lsq_ctl_rel1_thrd_id),
   .lsq_ctl_stq1_resv(lsq_ctl_stq1_resv),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_axu_val(lsq_ctl_stq1_axu_val),
   .lsq_ctl_stq1_epid_val(lsq_ctl_stq1_epid_val),
   .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
   .lsq_ctl_stq1_lock_clr(lsq_ctl_stq1_lock_clr),
   .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
   .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
   .lsq_ctl_stq1_inval(lsq_ctl_stq1_inval),
   .lsq_ctl_stq1_dci_val(lsq_ctl_stq1_dci_val),
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr),
   .lsq_ctl_stq4_xucr0_cul(lsq_ctl_stq4_xucr0_cul),
   .lsq_ctl_rel1_gpr_val(lsq_ctl_rel1_gpr_val),
   .lsq_ctl_rel1_ta_gpr(lsq_ctl_rel1_ta_gpr),
   .lsq_ctl_rel1_upd_gpr(lsq_ctl_rel1_upd_gpr),
   .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
   .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
   .lsq_ctl_rel1_data_val(lsq_ctl_rel1_data_val),
   .lsq_ctl_rel1_back_inv(lsq_ctl_rel1_back_inv),
   .lsq_ctl_rel2_blk_req(lsq_ctl_rel2_blk_req),
   .lsq_ctl_rel1_tag(lsq_ctl_rel1_tag),
   .lsq_ctl_rel1_classid(lsq_ctl_rel1_classid),
   .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
   .lsq_ctl_rel1_watch_set(lsq_ctl_rel1_watch_set),
   .lsq_ctl_rel2_upd_val(lsq_ctl_rel2_upd_val),
   .lsq_ctl_rel2_data(lsq_ctl_rel2_data),
   .lsq_ctl_rel3_l1dump_val(lsq_ctl_rel3_l1dump_val),
   .lsq_ctl_rel3_clr_relq(lsq_ctl_rel3_clr_relq),
   .ctl_lsq_stq4_perr_reject(ctl_lsq_stq4_perr_reject),
   .ctl_dat_stq5_way_perr_inval(ctl_dat_stq5_way_perr_inval),
   .lsq_ctl_ex3_strg_val(lsq_ctl_ex3_strg_val),
   .lsq_ctl_ex3_strg_noop(lsq_ctl_ex3_strg_noop),
   .lsq_ctl_ex3_illeg_lswx(lsq_ctl_ex3_illeg_lswx),
   .lsq_ctl_ex3_ct_val(lsq_ctl_ex3_ct_val),
   .lsq_ctl_ex3_be_ct(lsq_ctl_ex3_be_ct),
   .lsq_ctl_ex3_le_ct(lsq_ctl_ex3_le_ct),
   .lsq_ctl_stq_cpl_ready(lsq_ctl_stq_cpl_ready),
   .lsq_ctl_stq_cpl_ready_itag(lsq_ctl_stq_cpl_ready_itag),
   .lsq_ctl_stq_cpl_ready_tid(lsq_ctl_stq_cpl_ready_tid),
   .lsq_ctl_stq_n_flush(lsq_ctl_stq_n_flush),
   .lsq_ctl_stq_np1_flush(lsq_ctl_stq_np1_flush),
   .lsq_ctl_stq_exception_val(lsq_ctl_stq_exception_val),
   .lsq_ctl_stq_exception(lsq_ctl_stq_exception),
   .lsq_ctl_stq_dacrw(lsq_ctl_stq_dacrw),
   .lsq_ctl_sync_in_stq(lsq_ctl_sync_in_stq),
   .lsq_ctl_sync_done(lsq_ctl_sync_done),
   .ctl_lsq_stq_cpl_blk(ctl_lsq_stq_cpl_blk),
   .ctl_lsq_ex_pipe_full(ctl_lsq_ex_pipe_full),
   .ctl_lsq_ex2_streq_val(ctl_lsq_ex2_streq_val),
   .ctl_lsq_ex2_itag(ctl_lsq_ex2_itag),
   .ctl_lsq_ex2_thrd_id(ctl_lsq_ex2_thrd_id),
   .ctl_lsq_ex3_ldreq_val(ctl_lsq_ex3_ldreq_val),
   .ctl_lsq_ex3_wchkall_val(ctl_lsq_ex3_wchkall_val),
   .ctl_lsq_ex3_pfetch_val(ctl_lsq_ex3_pfetch_val),
   .ctl_lsq_ex3_byte_en(ctl_lsq_ex3_byte_en),
   .ctl_lsq_ex3_p_addr(ctl_lsq_ex3_p_addr),
   .ctl_lsq_ex3_thrd_id(ctl_lsq_ex3_thrd_id),
   .ctl_lsq_ex3_algebraic(ctl_lsq_ex3_algebraic),
   .ctl_lsq_ex3_opsize(ctl_lsq_ex3_opsize),
   .ctl_lsq_ex4_ldreq_val(ctl_lsq_ex4_ldreq_val),
   .ctl_lsq_ex4_binvreq_val(ctl_lsq_ex4_binvreq_val),
   .ctl_lsq_ex4_streq_val(ctl_lsq_ex4_streq_val),
   .ctl_lsq_ex4_othreq_val(ctl_lsq_ex4_othreq_val),
   .ctl_lsq_ex4_p_addr(ctl_lsq_ex4_p_addr),
   .ctl_lsq_ex4_dReq_val(ctl_lsq_ex4_dReq_val),
   .ctl_lsq_ex4_gath_load(ctl_lsq_ex4_gath_load),
   .ctl_lsq_ex4_send_l2(ctl_lsq_ex4_send_l2),
   .ctl_lsq_ex4_has_data(ctl_lsq_ex4_has_data),
   .ctl_lsq_ex4_cline_chk(ctl_lsq_ex4_cline_chk),
   .ctl_lsq_ex4_wimge(ctl_lsq_ex4_wimge),
   .ctl_lsq_ex4_byte_swap(ctl_lsq_ex4_byte_swap),
   .ctl_lsq_ex4_is_sync(ctl_lsq_ex4_is_sync),
   .ctl_lsq_ex4_all_thrd_chk(ctl_lsq_ex4_all_thrd_chk),
   .ctl_lsq_ex4_is_store(ctl_lsq_ex4_is_store),
   .ctl_lsq_ex4_is_resv(ctl_lsq_ex4_is_resv),
   .ctl_lsq_ex4_is_mfgpr(ctl_lsq_ex4_is_mfgpr),
   .ctl_lsq_ex4_is_icswxr(ctl_lsq_ex4_is_icswxr),
   .ctl_lsq_ex4_is_icbi(ctl_lsq_ex4_is_icbi),
   .ctl_lsq_ex4_watch_clr(ctl_lsq_ex4_watch_clr),
   .ctl_lsq_ex4_watch_clr_all(ctl_lsq_ex4_watch_clr_all),
   .ctl_lsq_ex4_mtspr_trace(ctl_lsq_ex4_mtspr_trace),
   .ctl_lsq_ex4_is_inval_op(ctl_lsq_ex4_is_inval_op),
   .ctl_lsq_ex4_is_cinval(ctl_lsq_ex4_is_cinval),
   .ctl_lsq_ex5_lock_clr(ctl_lsq_ex5_lock_clr),
   .ctl_lsq_ex5_lock_set(ctl_lsq_ex5_lock_set),
   .ctl_lsq_ex5_watch_set(ctl_lsq_ex5_watch_set),
   .ctl_lsq_ex5_tgpr(ctl_lsq_ex5_tgpr),
   .ctl_lsq_ex5_axu_val(ctl_lsq_ex5_axu_val),
   .ctl_lsq_ex5_is_epid(ctl_lsq_ex5_is_epid),
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
   .ctl_lsq_ex5_class_id(ctl_lsq_ex5_class_id),
   .ctl_lsq_ex5_dvc(ctl_lsq_ex5_dvc),
   .ctl_lsq_ex5_dacrw(ctl_lsq_ex5_dacrw),
   .ctl_lsq_ex5_ttype(ctl_lsq_ex5_ttype),
   .ctl_lsq_ex5_l_fld(ctl_lsq_ex5_l_fld),
   .ctl_lsq_ex5_load_hit(ctl_lsq_ex5_load_hit),
   .lsq_ctl_ex6_ldq_events(lsq_ctl_ex6_ldq_events),
   .lsq_ctl_ex6_stq_events(lsq_ctl_ex6_stq_events),
   .ctl_lsq_ex6_ldh_dacrw(ctl_lsq_ex6_ldh_dacrw),
   .ctl_lsq_stq3_icswx_data(ctl_lsq_stq3_icswx_data),
   .ctl_lsq_dbg_int_en(ctl_lsq_dbg_int_en),
   .ctl_lsq_ldp_idle(ctl_lsq_ldp_idle),
   .ctl_lsq_rv1_dir_rd_val(ctl_lsq_rv1_dir_rd_val),
   .ctl_lsq_spr_lsucr0_ford(ctl_lsq_spr_lsucr0_ford),
   .ctl_lsq_spr_lsucr0_b2b(ctl_lsq_spr_lsucr0_b2b),
   .ctl_lsq_spr_lsucr0_lge(ctl_lsq_spr_lsucr0_lge),
   .ctl_lsq_spr_lsucr0_lca(ctl_lsq_spr_lsucr0_lca),
   .ctl_lsq_spr_lsucr0_sca(ctl_lsq_spr_lsucr0_sca),
   .ctl_lsq_spr_lsucr0_dfwd(ctl_lsq_spr_lsucr0_dfwd),
   .ctl_lsq_ex4_xu1_data(ctl_lsq_ex4_xu1_data),

   .ctl_lsq_pf_empty(ctl_lsq_pf_empty),

   //--------------------------------------------------------------
   // Interface with Commit Pipe Directories
   //--------------------------------------------------------------
   .dir_arr_wr_enable(dir_arr_wr_enable),
   .dir_arr_wr_way(dir_arr_wr_way),
   .dir_arr_wr_addr(dir_arr_wr_addr),
   .dir_arr_wr_data(dir_arr_wr_data),
   .dir_arr_rd_data1(dir_arr_rd_data1),

   //--------------------------------------------------------------
   // Interface with DATA
   //--------------------------------------------------------------
   .ctl_dat_ex1_data_act(ctl_dat_ex1_data_act),
   .ctl_dat_ex2_eff_addr(ctl_dat_ex2_eff_addr),
   .ctl_dat_ex3_opsize(ctl_dat_ex3_opsize),
   .ctl_dat_ex3_le_mode(ctl_dat_ex3_le_mode),
   .ctl_dat_ex3_le_ld_rotsel(ctl_dat_ex3_le_ld_rotsel),
   .ctl_dat_ex3_be_ld_rotsel(ctl_dat_ex3_be_ld_rotsel),
   .ctl_dat_ex3_algebraic(ctl_dat_ex3_algebraic),
   .ctl_dat_ex3_le_alg_rotsel(ctl_dat_ex3_le_alg_rotsel),
   .ctl_dat_ex4_way_hit(ctl_dat_ex4_way_hit),
   .dat_ctl_dcarr_perr_way(dat_ctl_dcarr_perr_way),
   .dat_ctl_ex5_load_data(dat_ctl_ex5_load_data),
   .dat_ctl_stq6_axu_data(dat_ctl_stq6_axu_data),

   .stq4_dcarr_wren(stq4_dcarr_wren),
   .stq4_dcarr_way_en(stq4_dcarr_way_en),

   //--------------------------------------------------------------
   // Common Interface
   //--------------------------------------------------------------
   .ctl_spr_dvc1_dbg(ctl_spr_dvc1_dbg),
   .ctl_spr_dvc2_dbg(ctl_spr_dvc2_dbg),
   .ctl_perv_spr_lesr1(ctl_perv_spr_lesr1),
   .ctl_perv_spr_lesr2(ctl_perv_spr_lesr2),
   .ctl_spr_dbcr2_dvc1be(ctl_spr_dbcr2_dvc1be),
   .ctl_spr_dbcr2_dvc2be(ctl_spr_dbcr2_dvc2be),
   .ctl_spr_dbcr2_dvc1m(ctl_spr_dbcr2_dvc1m),
   .ctl_spr_dbcr2_dvc2m(ctl_spr_dbcr2_dvc2m),

   // LQ Pervasive
   .ctl_perv_ex6_perf_events(ctl_perv_ex6_perf_events),
   .ctl_perv_stq4_perf_events(ctl_perv_stq4_perf_events),
   .ctl_perv_dir_perf_events(ctl_perv_dir_perf_events),

   // Error Reporting
   .lq_pc_err_derat_parity(lq_pc_err_derat_parity),
   .lq_pc_err_dir_ldp_parity(lq_pc_err_dir_ldp_parity),
   .lq_pc_err_dir_stp_parity(lq_pc_err_dir_stp_parity),
   .lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
   .lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
   .lq_pc_err_dir_ldp_multihit(lq_pc_err_dir_ldp_multihit),
   .lq_pc_err_dir_stp_multihit(lq_pc_err_dir_stp_multihit),
   .pc_lq_inj_prefetcher_parity(pc_lq_inj_prefetcher_parity),
   .lq_pc_err_prefetcher_parity(lq_pc_err_prefetcher_parity),

   // Pervasive
   .vcs(vdd),
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_2(sg_2),
   .fce_2(fce_2),
   .func_sl_thold_2(func_sl_thold_2),
   .func_nsl_thold_2(func_nsl_thold_2),
   .func_slp_sl_thold_2(func_slp_sl_thold_2),
   .func_slp_nsl_thold_2(func_slp_nsl_thold_2),
   .pc_lq_init_reset(pc_lq_init_reset),
   .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
   .clkoff_dc_b(clkoff_dc_b),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5:9]),
   .mpw1_dc_b(mpw1_dc_b[5:9]),
   .mpw2_dc_b(mpw2_dc_b),
   .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
   .g8t_d_mode_dc(g8t_d_mode_dc),
   .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
   .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
   .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
   .cfg_slp_sl_thold_2(cfg_slp_sl_thold_2),
   .cfg_sl_thold_2(cfg_sl_thold_2),
   .regf_slp_sl_thold_2(regf_slp_sl_thold_2),
   .abst_sl_thold_2(abst_sl_thold_2),
   .abst_slp_sl_thold_2(abst_slp_sl_thold_2),
   .time_sl_thold_2(time_sl_thold_2),
   .ary_nsl_thold_2(ary_nsl_thold_2),
   .ary_slp_nsl_thold_2(ary_slp_nsl_thold_2),
   .repr_sl_thold_2(repr_sl_thold_2),
   .bolt_sl_thold_2(bolt_sl_thold_2),
   .bo_enable_2(bo_enable_2),
   .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
   .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
   .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
   .an_ac_atpg_en_dc(an_ac_atpg_en_dc),
   .an_ac_grffence_en_dc(an_ac_grffence_en_dc),
   .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
   .pc_lq_abist_ena_dc(pc_lq_abist_ena_dc),
   .pc_lq_abist_raw_dc_b(pc_lq_abist_raw_dc_b),
   .pc_lq_bo_unload(pc_lq_bo_unload),
   .pc_lq_bo_repair(pc_lq_bo_repair),
   .pc_lq_bo_reset(pc_lq_bo_reset),
   .pc_lq_bo_shdata(pc_lq_bo_shdata),
   .pc_lq_bo_select(pc_lq_bo_select[4:7]),
   .lq_pc_bo_fail(lq_pc_bo_fail[4:7]),
   .lq_pc_bo_diagout(lq_pc_bo_diagout[4:7]),

   // RAM Control
   .pc_lq_ram_active(pc_lq_ram_active),
   .lq_pc_ram_data_val(lq_pc_ram_data_val),
   .lq_pc_ram_data(lq_pc_ram_data),

   // G8T ABIST Control
   .pc_lq_abist_wl64_comp_ena(pc_lq_abist_wl64_comp_ena),
   .pc_lq_abist_g8t_wenb(pc_lq_abist_g8t_wenb),
   .pc_lq_abist_g8t1p_renb_0(pc_lq_abist_g8t1p_renb_0),
   .pc_lq_abist_g8t_dcomp(pc_lq_abist_g8t_dcomp),
   .pc_lq_abist_g8t_bw_1(pc_lq_abist_g8t_bw_1),
   .pc_lq_abist_g8t_bw_0(pc_lq_abist_g8t_bw_0),
   .pc_lq_abist_di_0(pc_lq_abist_di_0),
   .pc_lq_abist_waddr_0(pc_lq_abist_waddr_0[4:9]),
   .pc_lq_abist_raddr_0(pc_lq_abist_raddr_0[3:8]),

   // D-ERAT CAM ABIST Control
   .cam_clkoff_dc_b(cam_clkoff_dc_b),
   .cam_d_mode_dc(cam_d_mode_dc),
   .cam_act_dis_dc(cam_act_dis_dc),
   .cam_delay_lclkr_dc(cam_delay_lclkr_dc),
   .cam_mpw1_dc_b(cam_mpw1_dc_b),
   .cam_mpw2_dc_b(cam_mpw2_dc_b),

   // SCAN Ports
   .abst_scan_in(abst_scan_in[4]),
   .time_scan_in(time_scan_in),
   .repr_scan_in(repr_scan_in),
   .func_scan_in(func_scan_in[0:10]),
   .regf_scan_in(regf_scan_in),
   .ccfg_scan_in(ccfg_scan_in),
   .abst_scan_out(abst_scan_out[4]),
   .time_scan_out(ctl_time_scan_out),
   .repr_scan_out(ctl_repr_scan_out),
   .func_scan_out(func_scan_out[0:10]),
   .regf_scan_out(regf_scan_out),
   .ccfg_scan_out(ccfg_scan_out)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DATA
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_data  dat(

   // Execution Pipe
   .ctl_dat_ex1_data_act(ctl_dat_ex1_data_act),
   .ctl_dat_ex2_eff_addr(ctl_dat_ex2_eff_addr),
   .ctl_dat_ex3_opsize(ctl_dat_ex3_opsize),
   .ctl_dat_ex3_le_ld_rotsel(ctl_dat_ex3_le_ld_rotsel),
   .ctl_dat_ex3_be_ld_rotsel(ctl_dat_ex3_be_ld_rotsel),
   .ctl_dat_ex3_algebraic(ctl_dat_ex3_algebraic),
   .ctl_dat_ex3_le_alg_rotsel(ctl_dat_ex3_le_alg_rotsel),
   .ctl_dat_ex3_le_mode(ctl_dat_ex3_le_mode),
   .ctl_dat_ex4_way_hit(ctl_dat_ex4_way_hit),

   // Config Bits
   .xu_lq_spr_xucr0_dcdis(xu_lq_spr_xucr0_dcdis),

   // RELOAD/STORE PIPE
   .lsq_dat_stq1_stg_act(lsq_dat_stq1_stg_act),
   .lsq_dat_stq1_val(lsq_dat_stq1_val),
   .lsq_dat_stq1_mftgpr_val(lsq_dat_stq1_mftgpr_val),
   .lsq_dat_stq1_store_val(lsq_dat_stq1_store_val),
   .lsq_dat_stq1_byte_en(lsq_dat_stq1_byte_en),
   .lsq_dat_stq1_op_size(lsq_dat_stq1_op_size),
   .lsq_dat_stq1_le_mode(lsq_dat_stq1_le_mode),
   .lsq_dat_stq1_addr(lsq_dat_stq1_addr),
   .lsq_dat_stq2_blk_req(lsq_dat_stq2_blk_req),
   .lsq_dat_stq2_store_data(lsq_dat_stq2_store_data),
   .lsq_dat_rel1_data_val(lsq_dat_rel1_data_val),
   .lsq_dat_rel1_qw(lsq_dat_rel1_qw),

   // L1 D$ update Enable
   .stq4_dcarr_wren(stq4_dcarr_wren),
   .stq4_dcarr_way_en(stq4_dcarr_way_en),
   .ctl_dat_stq5_way_perr_inval(ctl_dat_stq5_way_perr_inval),

   // Execution Pipe Outputs
   .dat_ctl_dcarr_perr_way(dat_ctl_dcarr_perr_way),

   //Rotated Data
   .dat_ctl_ex5_load_data(dat_ctl_ex5_load_data),
   .dat_ctl_stq6_axu_data(dat_ctl_stq6_axu_data),

   // Debug Data Compare
   .dat_lsq_stq4_128data(dat_lsq_stq4_128data),

   // Error Inject
   .pc_lq_inj_dcache_parity(pc_lq_inj_dcache_parity),

   //pervasive
   .vdd(vdd),
   .gnd(gnd),
   .vcs(vdd),
   .nclk(nclk),
   .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
   .sg_2(sg_2),
   .fce_2(fce_2),
   .func_sl_thold_2(func_sl_thold_2),
   .func_nsl_thold_2(func_nsl_thold_2),
   .clkoff_dc_b(clkoff_dc_b),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[0]),
   .mpw1_dc_b(mpw1_dc_b[0]),
   .mpw2_dc_b(mpw2_dc_b),
   .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
   .g8t_d_mode_dc(g8t_d_mode_dc),
   .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
   .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
   .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
   .abst_sl_thold_2(abst_sl_thold_2),
   .time_sl_thold_2(time_sl_thold_2),
   .ary_nsl_thold_2(ary_nsl_thold_2),
   .repr_sl_thold_2(repr_sl_thold_2),
   .bolt_sl_thold_2(bolt_sl_thold_2),
   .bo_enable_2(bo_enable_2),
   .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
   .an_ac_scan_diag_dc(an_ac_scan_diag_dc),

   // G6T ABIST Control
   .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
   .pc_lq_abist_ena_dc(pc_lq_abist_ena_dc),
   .pc_lq_abist_raw_dc_b(pc_lq_abist_raw_dc_b),
   .pc_lq_abist_wl256_comp_ena(pc_lq_abist_wl256_comp_ena),
   .pc_lq_abist_g8t_wenb(pc_lq_abist_g8t_wenb),
   .pc_lq_abist_g8t1p_renb_0(pc_lq_abist_g8t1p_renb_0),
   .pc_lq_abist_g8t_dcomp(pc_lq_abist_g8t_dcomp),
   .pc_lq_abist_g8t_bw_1(pc_lq_abist_g8t_bw_1),
   .pc_lq_abist_g8t_bw_0(pc_lq_abist_g8t_bw_0),
   .pc_lq_abist_di_0(pc_lq_abist_di_0),
   .pc_lq_abist_waddr_0(pc_lq_abist_waddr_0),
   .pc_lq_abist_raddr_0(pc_lq_abist_raddr_0),
   .pc_lq_bo_unload(pc_lq_bo_unload),
   .pc_lq_bo_repair(pc_lq_bo_repair),
   .pc_lq_bo_reset(pc_lq_bo_reset),
   .pc_lq_bo_shdata(pc_lq_bo_shdata),
   .pc_lq_bo_select(pc_lq_bo_select[0:3]),
   .lq_pc_bo_fail(lq_pc_bo_fail[0:3]),
   .lq_pc_bo_diagout(lq_pc_bo_diagout[0:3]),

   // SCAN Ports
   .abst_scan_in(abst_scan_in[0:3]),
   .time_scan_in(ctl_time_scan_out),
   .repr_scan_in(ctl_repr_scan_out),
   .func_scan_in(func_scan_in[11:17]),
   .abst_scan_out(abst_scan_out[0:3]),
   .time_scan_out(dat_time_scan_out),
   .repr_scan_out(dat_repr_scan_out),
   .func_scan_out(func_scan_out[11:17])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LOADMISS/STORE QUEUES
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_lsq  lsq(

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

   // RV1 RV Issue Valid
   .rv_lq_vld(rv_lq_vld),
   .rv_lq_isLoad(rv_lq_isLoad),

   // RV is empty indicator
   .rv_lq_rvs_empty(rv_lq_rvs_empty),

   // SPR Directory Read Valid
   .ctl_lsq_rv1_dir_rd_val(ctl_lsq_rv1_dir_rd_val),

   // Execution Pipe Outputs
   .ctl_lsq_ex2_streq_val(ctl_lsq_ex2_streq_val),
   .ctl_lsq_ex2_itag(ctl_lsq_ex2_itag),
   .ctl_lsq_ex2_thrd_id(ctl_lsq_ex2_thrd_id),
   .ctl_lsq_ex3_ldreq_val(ctl_lsq_ex3_ldreq_val),
   .ctl_lsq_ex3_wchkall_val(ctl_lsq_ex3_wchkall_val),
   .ctl_lsq_ex3_pfetch_val(ctl_lsq_ex3_pfetch_val),
   .ctl_lsq_ex3_byte_en(ctl_lsq_ex3_byte_en),
   .ctl_lsq_ex3_p_addr(ctl_lsq_ex3_p_addr),
   .ctl_lsq_ex3_thrd_id(ctl_lsq_ex3_thrd_id),
   .ctl_lsq_ex3_algebraic(ctl_lsq_ex3_algebraic),
   .ctl_lsq_ex3_opsize(ctl_lsq_ex3_opsize),
   .ctl_lsq_ex4_ldreq_val(ctl_lsq_ex4_ldreq_val),
   .ctl_lsq_ex4_binvreq_val(ctl_lsq_ex4_binvreq_val),
   .ctl_lsq_ex4_streq_val(ctl_lsq_ex4_streq_val),
   .ctl_lsq_ex4_othreq_val(ctl_lsq_ex4_othreq_val),
   .ctl_lsq_ex4_p_addr(ctl_lsq_ex4_p_addr),
   .ctl_lsq_ex4_dReq_val(ctl_lsq_ex4_dReq_val),
   .ctl_lsq_ex4_gath_load(ctl_lsq_ex4_gath_load),
   .ctl_lsq_ex4_send_l2(ctl_lsq_ex4_send_l2),
   .ctl_lsq_ex4_has_data(ctl_lsq_ex4_has_data),
   .ctl_lsq_ex4_cline_chk(ctl_lsq_ex4_cline_chk),
   .ctl_lsq_ex4_wimge(ctl_lsq_ex4_wimge),
   .ctl_lsq_ex4_byte_swap(ctl_lsq_ex4_byte_swap),
   .ctl_lsq_ex4_is_sync(ctl_lsq_ex4_is_sync),
   .ctl_lsq_ex4_all_thrd_chk(ctl_lsq_ex4_all_thrd_chk),
   .ctl_lsq_ex4_is_store(ctl_lsq_ex4_is_store),
   .ctl_lsq_ex4_is_resv(ctl_lsq_ex4_is_resv),
   .ctl_lsq_ex4_is_mfgpr(ctl_lsq_ex4_is_mfgpr),
   .ctl_lsq_ex4_is_icswxr(ctl_lsq_ex4_is_icswxr),
   .ctl_lsq_ex4_is_icbi(ctl_lsq_ex4_is_icbi),
   .ctl_lsq_ex4_watch_clr(ctl_lsq_ex4_watch_clr),
   .ctl_lsq_ex4_watch_clr_all(ctl_lsq_ex4_watch_clr_all),
   .ctl_lsq_ex4_mtspr_trace(ctl_lsq_ex4_mtspr_trace),
   .ctl_lsq_ex4_is_inval_op(ctl_lsq_ex4_is_inval_op),
   .ctl_lsq_ex4_is_cinval(ctl_lsq_ex4_is_cinval),
   .ctl_lsq_ex5_lock_clr(ctl_lsq_ex5_lock_clr),
   .ctl_lsq_ex5_lock_set(ctl_lsq_ex5_lock_set),
   .ctl_lsq_ex5_watch_set(ctl_lsq_ex5_watch_set),
   .ctl_lsq_ex5_tgpr(ctl_lsq_ex5_tgpr),
   .ctl_lsq_ex5_axu_val(ctl_lsq_ex5_axu_val),
   .ctl_lsq_ex5_is_epid(ctl_lsq_ex5_is_epid),
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
   .ctl_lsq_ex5_class_id(ctl_lsq_ex5_class_id),
   .ctl_lsq_ex5_dvc(ctl_lsq_ex5_dvc),
   .ctl_lsq_ex5_dacrw(ctl_lsq_ex5_dacrw),
   .ctl_lsq_ex5_ttype(ctl_lsq_ex5_ttype),
   .ctl_lsq_ex5_l_fld(ctl_lsq_ex5_l_fld),
   .ctl_lsq_ex5_load_hit(ctl_lsq_ex5_load_hit),
   .lsq_ctl_ex6_ldq_events(lsq_ctl_ex6_ldq_events),
   .lsq_ctl_ex6_stq_events(lsq_ctl_ex6_stq_events),
   .lsq_perv_ex7_events(lsq_perv_ex7_events),
   .lsq_perv_ldq_events(lsq_perv_ldq_events),
   .lsq_perv_stq_events(lsq_perv_stq_events),
   .lsq_perv_odq_events(lsq_perv_odq_events),
   .ctl_lsq_ex6_ldh_dacrw(ctl_lsq_ex6_ldh_dacrw),
   .ctl_lsq_dbg_int_en(ctl_lsq_dbg_int_en),
   .ctl_lsq_ldp_idle(ctl_lsq_ldp_idle),

   // ICSWX Data to be sent to the L2
   .ctl_lsq_stq3_icswx_data(ctl_lsq_stq3_icswx_data),

   // Interface with Local SPR's
   .ctl_lsq_spr_dvc1_dbg(ctl_spr_dvc1_dbg),
   .ctl_lsq_spr_dvc2_dbg(ctl_spr_dvc2_dbg),
   .ctl_lsq_spr_dbcr2_dvc1m(ctl_spr_dbcr2_dvc1m),
   .ctl_lsq_spr_dbcr2_dvc1be(ctl_spr_dbcr2_dvc1be),
   .ctl_lsq_spr_dbcr2_dvc2m(ctl_spr_dbcr2_dvc2m),
   .ctl_lsq_spr_dbcr2_dvc2be(ctl_spr_dbcr2_dvc2be),
   .ctl_lsq_spr_lsucr0_b2b(ctl_lsq_spr_lsucr0_b2b),
   .ctl_lsq_spr_lsucr0_lge(ctl_lsq_spr_lsucr0_lge),
   .ctl_lsq_spr_lsucr0_lca(ctl_lsq_spr_lsucr0_lca),
   .ctl_lsq_spr_lsucr0_sca(ctl_lsq_spr_lsucr0_sca),
   .ctl_lsq_spr_lsucr0_dfwd(ctl_lsq_spr_lsucr0_dfwd),

   .ctl_lsq_pf_empty(ctl_lsq_pf_empty),

   //--------------------------------------------------------------
   // Interface with Commit Pipe Directories
   //--------------------------------------------------------------
   .dir_arr_wr_enable(dir_arr_wr_enable),
   .dir_arr_wr_way(dir_arr_wr_way),
   .dir_arr_wr_addr(dir_arr_wr_addr),
   .dir_arr_wr_data(dir_arr_wr_data),
   .dir_arr_rd_data1(dir_arr_rd_data1),

   // Data Cache Config
   .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),
   .xu_lq_spr_xucr0_cred(xu_lq_spr_xucr0_cred),

   // ICBI ACK Enable
   .iu_lq_spr_iucr0_icbi_ack(iu_lq_spr_iucr0_icbi_ack),

   // STQ4 Data for L2 write
   .dat_lsq_stq4_128data(dat_lsq_stq4_128data),

   // Instruction Fetches
   .iu_lq_request(iu_lq_request),
   .iu_lq_cTag(iu_lq_cTag),
   .iu_lq_ra(iu_lq_ra),
   .iu_lq_wimge(iu_lq_wimge),
   .iu_lq_userdef(iu_lq_userdef),

   // ICBI Interface to IU
   .lq_iu_icbi_val(lq_iu_icbi_val),
   .lq_iu_icbi_addr(lq_iu_icbi_addr),
   .iu_lq_icbi_complete(iu_lq_icbi_complete),

   // ICI Interace
   .lq_iu_ici_val(lq_iu_ici_val),

   // MMU instruction interface
   .mm_lq_lsu_req(mm_lq_lsu_req),
   .mm_lq_lsu_ttype(mm_lq_lsu_ttype),
   .mm_lq_lsu_wimge(mm_lq_lsu_wimge),
   .mm_lq_lsu_u(mm_lq_lsu_u),
   .mm_lq_lsu_addr(mm_lq_lsu_addr),

   // TLBI_COMPLETE is address-less
   .mm_lq_lsu_lpid(mm_lq_lsu_lpid),
   .mm_lq_lsu_gs(mm_lq_lsu_gs),
   .mm_lq_lsu_ind(mm_lq_lsu_ind),
   .mm_lq_lsu_lbit(mm_lq_lsu_lbit),
   .mm_lq_lsu_lpidr(mm_lq_lsu_lpidr),
   .lq_mm_lsu_token(lq_mm_lsu_token),
   .lq_xu_quiesce(lq_xu_quiesce),
   .lq_pc_ldq_quiesce(lq_pc_ldq_quiesce),
   .lq_pc_stq_quiesce(lq_pc_stq_quiesce),
   .lq_pc_pfetch_quiesce(lq_pc_pfetch_quiesce),
   .lq_mm_lmq_stq_empty(lq_mm_lmq_stq_empty),

   // Zap Machine
   .iu_lq_cp_flush(iu_lq_cp_flush),

   // Next Itag Completion
   .iu_lq_recirc_val(iu_lq_recirc_val),
   .iu_lq_cp_next_itag(iu_lq_cp_next_itag),

   // Complete iTag
   .iu_lq_i0_completed(iu_lq_i0_completed),
   .iu_lq_i0_completed_itag(iu_lq_i0_completed_itag),
   .iu_lq_i1_completed(iu_lq_i1_completed),
   .iu_lq_i1_completed_itag(iu_lq_i1_completed_itag),

   // XER Read for long latency CP_NEXT ops stcx./icswx.
   .xu_lq_xer_cp_rd(xu_lq_xer_cp_rd),

   // Sync Ack
   .an_ac_sync_ack(an_ac_sync_ack),

   // Stcx Complete
   .an_ac_stcx_complete(an_ac_stcx_complete),
   .an_ac_stcx_pass(an_ac_stcx_pass),

   // ICBI ACK
   .an_ac_icbi_ack(an_ac_icbi_ack),
   .an_ac_icbi_ack_thread(an_ac_icbi_ack_thread),

   // Core ID
   .an_ac_coreid(an_ac_coreid),

   // L2 Interface Credit Control
   .an_ac_req_ld_pop(an_ac_req_ld_pop),
   .an_ac_req_st_pop(an_ac_req_st_pop),
   .an_ac_req_st_gather(an_ac_req_st_gather),

   // L2 Interface Reload
   .an_ac_reld_data_vld(an_ac_reld_data_vld),
   .an_ac_reld_core_tag(an_ac_reld_core_tag),
   .an_ac_reld_qw(an_ac_reld_qw),
   .an_ac_reld_data(an_ac_reld_data),
   .an_ac_reld_data_coming(an_ac_reld_data_coming),
   .an_ac_reld_ditc(an_ac_reld_ditc),
   .an_ac_reld_crit_qw(an_ac_reld_crit_qw),
   .an_ac_reld_l1_dump(an_ac_reld_l1_dump),
   .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
   .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),

   // L2 Interface Back Invalidate
   .an_ac_back_inv(an_ac_back_inv),
   .an_ac_back_inv_addr(an_ac_back_inv_addr),
   .an_ac_back_inv_target_bit1(an_ac_back_inv_target_bit1),
   .an_ac_back_inv_target_bit3(an_ac_back_inv_target_bit3),
   .an_ac_back_inv_target_bit4(an_ac_back_inv_target_bit4),
   .an_ac_req_spare_ctrl_a1(an_ac_req_spare_ctrl_a1),

   // Credit Release to IU
   .lq_iu_credit_free(lq_iu_credit_free),
   .sq_iu_credit_free(sq_iu_credit_free),

   // Reservation Station Hold indicator
   .lsq_ctl_rv_hold_all(lsq_ctl_rv_hold_all),

   // Reservation station set barrier indicator
   .lsq_ctl_rv_set_hold(lsq_ctl_rv_set_hold),
   .lsq_ctl_rv_clr_hold(lsq_ctl_rv_clr_hold),

   // Reload Itag Complete
   .lsq_ctl_stq_release_itag_vld(lsq_ctl_stq_release_itag_vld),
   .lsq_ctl_stq_release_itag(lsq_ctl_stq_release_itag),
   .lsq_ctl_stq_release_tid(lsq_ctl_stq_release_tid),

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

   // LOADMISS Queue RESTART indicator
   .lsq_ctl_ex5_ldq_restart(lsq_ctl_ex5_ldq_restart),

   // Store Data Forward
   .lsq_ctl_ex5_fwd_val(lsq_ctl_ex5_fwd_val),
   .lsq_ctl_ex5_fwd_data(lsq_ctl_ex5_fwd_data),

   .lsq_ctl_sync_in_stq(lsq_ctl_sync_in_stq),
   .lsq_ctl_sync_done(lsq_ctl_sync_done),

   // Store Queue RESTART indicator
   .lsq_ctl_ex5_stq_restart(lsq_ctl_ex5_stq_restart),
   .lsq_ctl_ex5_stq_restart_miss(lsq_ctl_ex5_stq_restart_miss),

   // Interface to completion
   .lq1_iu_execute_vld(lq1_iu_execute_vld),
   .lq1_iu_itag(lq1_iu_itag),
   .lq1_iu_exception_val(lq1_iu_exception_val),
   .lq1_iu_exception(lq1_iu_exception),
   .lq1_iu_n_flush(lq1_iu_n_flush),
   .lq1_iu_np1_flush(lq1_iu_np1_flush),
   .lq1_iu_dacr_type(lq1_iu_dacr_type),
   .lq1_iu_dacrw(lq1_iu_dacrw),
   .lq1_iu_perf_events(lq1_iu_perf_events),

   // RELOAD/COMMIT Data Control
   .lsq_dat_stq1_stg_act(lsq_dat_stq1_stg_act),
   .lsq_dat_rel1_data_val(lsq_dat_rel1_data_val),
   .lsq_dat_rel1_qw(lsq_dat_rel1_qw),
   .lsq_dat_stq1_val(lsq_dat_stq1_val),
   .lsq_dat_stq1_mftgpr_val(lsq_dat_stq1_mftgpr_val),
   .lsq_dat_stq1_store_val(lsq_dat_stq1_store_val),
   .lsq_dat_stq1_byte_en(lsq_dat_stq1_byte_en),
   .lsq_dat_stq1_op_size(lsq_dat_stq1_op_size),
   .lsq_dat_stq1_addr(lsq_dat_stq1_addr),
   .lsq_dat_stq1_le_mode(lsq_dat_stq1_le_mode),
   .lsq_dat_stq2_blk_req(lsq_dat_stq2_blk_req),
   .lsq_dat_stq2_store_data(lsq_dat_stq2_store_data),

   // RELOAD/COMMIT Directory Control
   .lsq_ctl_stq1_stg_act(lsq_ctl_stq1_stg_act),
   .lsq_ctl_oldest_tid(lsq_ctl_oldest_tid),
   .lsq_ctl_oldest_itag(lsq_ctl_oldest_itag),
   .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
   .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
   .lsq_ctl_rel1_data_val(lsq_ctl_rel1_data_val),
   .lsq_ctl_rel1_back_inv(lsq_ctl_rel1_back_inv),
   .lsq_ctl_rel1_tag(lsq_ctl_rel1_tag),
   .lsq_ctl_rel1_classid(lsq_ctl_rel1_classid),
   .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
   .lsq_ctl_rel1_watch_set(lsq_ctl_rel1_watch_set),
   .lsq_ctl_rel2_blk_req(lsq_ctl_rel2_blk_req),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_rel2_upd_val(lsq_ctl_rel2_upd_val),
   .lsq_ctl_rel2_data(lsq_ctl_rel2_data),
   .lsq_ctl_rel3_l1dump_val(lsq_ctl_rel3_l1dump_val),
   .lsq_ctl_rel3_clr_relq(lsq_ctl_rel3_clr_relq),
   .ctl_lsq_stq4_perr_reject(ctl_lsq_stq4_perr_reject),
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq1_mftgpr_val(lsq_ctl_stq1_mftgpr_val),
   .lsq_ctl_stq1_mfdpf_val(lsq_ctl_stq1_mfdpf_val),
   .lsq_ctl_stq1_mfdpa_val(lsq_ctl_stq1_mfdpa_val),
   .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),
   .lsq_ctl_rel1_thrd_id(lsq_ctl_rel1_thrd_id),
   .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
   .lsq_ctl_stq1_lock_clr(lsq_ctl_stq1_lock_clr),
   .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
   .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
   .lsq_ctl_stq1_inval(lsq_ctl_stq1_inval),
   .lsq_ctl_stq1_dci_val(lsq_ctl_stq1_dci_val),
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_axu_val(lsq_ctl_stq1_axu_val),
   .lsq_ctl_stq1_epid_val(lsq_ctl_stq1_epid_val),
   .lsq_ctl_stq4_xucr0_cul(lsq_ctl_stq4_xucr0_cul),
   .lsq_ctl_stq5_itag(lsq_ctl_stq5_itag),
   .lsq_ctl_stq5_tgpr(lsq_ctl_stq5_tgpr),

   // RELOAD Register Control
   .lsq_ctl_rel1_gpr_val(lsq_ctl_rel1_gpr_val),
   .lsq_ctl_rel1_ta_gpr(lsq_ctl_rel1_ta_gpr),
   .lsq_ctl_rel1_upd_gpr(lsq_ctl_rel1_upd_gpr),
   .lsq_ctl_stq1_resv(lsq_ctl_stq1_resv),

   // Illegal LSWX has been determined
   .lsq_ctl_ex3_strg_val(lsq_ctl_ex3_strg_val),
   .lsq_ctl_ex3_strg_noop(lsq_ctl_ex3_strg_noop),
   .lsq_ctl_ex3_illeg_lswx(lsq_ctl_ex3_illeg_lswx),
   .lsq_ctl_ex3_ct_val(lsq_ctl_ex3_ct_val),
   .lsq_ctl_ex3_be_ct(lsq_ctl_ex3_be_ct),
   .lsq_ctl_ex3_le_ct(lsq_ctl_ex3_le_ct),

   // release itag to pfetch
   .odq_pf_report_tid(odq_pf_report_tid),
   .odq_pf_report_itag(odq_pf_report_itag),
   .odq_pf_resolved(odq_pf_resolved),

   // STCX Update
   .lq_xu_cr_l2_we(lq_xu_cr_l2_we),
   .lq_xu_cr_l2_wa(lq_xu_cr_l2_wa),
   .lq_xu_cr_l2_wd(lq_xu_cr_l2_wd),

   // PRF update for reloads
   .lq_xu_axu_rel_le(lq_xu_axu_rel_le),

   // Back-Invalidate
   .lsq_ctl_rv0_back_inv(lsq_ctl_rv0_back_inv),
   .lsq_ctl_rv1_back_inv_addr(lsq_ctl_rv1_back_inv_addr),

   // RV Reload Release Dependent ITAGs
   .lq_rv_itag2_vld(lq_rv_itag2_vld),
   .lq_rv_itag2(lq_rv_itag2),

   // Doorbell Interface
   .lq_xu_dbell_val(lq_xu_dbell_val),
   .lq_xu_dbell_type(lq_xu_dbell_type),
   .lq_xu_dbell_brdcast(lq_xu_dbell_brdcast),
   .lq_xu_dbell_lpid_match(lq_xu_dbell_lpid_match),
   .lq_xu_dbell_pirtag(lq_xu_dbell_pirtag),

   // L2 Interface Outputs
   .ac_an_req_pwr_token(ac_an_req_pwr_token),
   .ac_an_req(ac_an_req),
   .ac_an_req_ra(ac_an_req_ra),
   .ac_an_req_ttype(ac_an_req_ttype),
   .ac_an_req_thread(ac_an_req_thread),
   .ac_an_req_wimg_w(ac_an_req_wimg_w),
   .ac_an_req_wimg_i(ac_an_req_wimg_i),
   .ac_an_req_wimg_m(ac_an_req_wimg_m),
   .ac_an_req_wimg_g(ac_an_req_wimg_g),
   .ac_an_req_endian(ac_an_req_endian),
   .ac_an_req_user_defined(ac_an_req_user_defined),
   .ac_an_req_spare_ctrl_a0(ac_an_req_spare_ctrl_a0),
   .ac_an_req_ld_core_tag(ac_an_req_ld_core_tag),
   .ac_an_req_ld_xfr_len(ac_an_req_ld_xfr_len),
   .ac_an_st_byte_enbl(ac_an_st_byte_enbl),
   .ac_an_st_data(ac_an_st_data),
   .ac_an_st_data_pwr_token(ac_an_st_data_pwr_token),

   // Interface to Pervasive Unit
   .pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),
   .lq_pc_err_relq_parity(lq_pc_err_relq_parity),
   .lq_pc_err_invld_reld(lq_pc_err_invld_reld),
   .lq_pc_err_l2intrf_ecc(lq_pc_err_l2intrf_ecc),
   .lq_pc_err_l2intrf_ue(lq_pc_err_l2intrf_ue),
   .lq_pc_err_l2credit_overrun(lq_pc_err_l2credit_overrun),

   // Pervasive
   .vcs(vdd),
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
   .sg_2(sg_2),
   .fce_2(fce_2),
   .func_sl_thold_2(func_sl_thold_2),
   .func_nsl_thold_2(func_nsl_thold_2),
   .func_slp_sl_thold_2(func_slp_sl_thold_2),
   .clkoff_dc_b(clkoff_dc_b),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[0]),
   .mpw1_dc_b(mpw1_dc_b[0]),
   .mpw2_dc_b(mpw2_dc_b),
   .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
   .g8t_d_mode_dc(g8t_d_mode_dc),
   .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
   .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
   .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
   .abst_sl_thold_2(abst_sl_thold_2),
   .time_sl_thold_2(time_sl_thold_2),
   .ary_nsl_thold_2(ary_nsl_thold_2),
   .repr_sl_thold_2(repr_sl_thold_2),
   .bolt_sl_thold_2(bolt_sl_thold_2),
   .bo_enable_2(bo_enable_2),
   .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
   .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
   .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
   .pc_lq_abist_ena_dc(pc_lq_abist_ena_dc),
   .pc_lq_abist_raw_dc_b(pc_lq_abist_raw_dc_b),
   .pc_lq_bo_unload(pc_lq_bo_unload),
   .pc_lq_bo_repair(pc_lq_bo_repair),
   .pc_lq_bo_reset(pc_lq_bo_reset),
   .pc_lq_bo_shdata(pc_lq_bo_shdata),
   .pc_lq_bo_select(pc_lq_bo_select[8:13]),
   .lq_pc_bo_fail(lq_pc_bo_fail[8:13]),
   .lq_pc_bo_diagout(lq_pc_bo_diagout[8:13]),

   // G8T ABIST Control
   .pc_lq_abist_wl64_comp_ena(pc_lq_abist_wl64_comp_ena),
   .pc_lq_abist_g8t_wenb(pc_lq_abist_g8t_wenb),
   .pc_lq_abist_g8t1p_renb_0(pc_lq_abist_g8t1p_renb_0),
   .pc_lq_abist_g8t_dcomp(pc_lq_abist_g8t_dcomp),
   .pc_lq_abist_g8t_bw_1(pc_lq_abist_g8t_bw_1),
   .pc_lq_abist_g8t_bw_0(pc_lq_abist_g8t_bw_0),
   .pc_lq_abist_di_0(pc_lq_abist_di_0),
   .pc_lq_abist_waddr_0(pc_lq_abist_waddr_0[4:9]),
   .pc_lq_abist_raddr_0(pc_lq_abist_raddr_0[3:8]),

   // SCAN Ports
   .abst_scan_in(abst_scan_in[5]),
   .time_scan_in(dat_time_scan_out),
   .repr_scan_in(dat_repr_scan_out),
   .func_scan_in(func_scan_in[18:24]),
   .abst_scan_out(abst_scan_out[5]),
   .time_scan_out(time_scan_out),
   .repr_scan_out(repr_scan_out),
   .func_scan_out(lsq_func_scan_out[18:24])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LOCAL PERVASIVE
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign perv_func_scan_in = lsq_func_scan_out[24];
assign lq_debug_bus0 = 32'h00000000;

lq_perv lq_perv(
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .pc_lq_trace_bus_enable(pc_lq_trace_bus_enable),
   .pc_lq_debug_mux1_ctrls(pc_lq_debug_mux1_ctrls),
   .pc_lq_debug_mux2_ctrls(pc_lq_debug_mux2_ctrls),
   .pc_lq_instr_trace_mode(pc_lq_instr_trace_mode),
   .pc_lq_instr_trace_tid(pc_lq_instr_trace_tid),
   .debug_bus_in(debug_bus_in),
   .coretrace_ctrls_in(coretrace_ctrls_in),
   .lq_debug_bus0(lq_debug_bus0),
   .debug_bus_out(debug_bus_out),
   .coretrace_ctrls_out(coretrace_ctrls_out),
   .pc_lq_event_bus_enable(pc_lq_event_bus_enable),
   .pc_lq_event_count_mode(pc_lq_event_count_mode),
   .ctl_perv_spr_lesr1(ctl_perv_spr_lesr1),
   .ctl_perv_spr_lesr2(ctl_perv_spr_lesr2),
   .ctl_perv_ex6_perf_events(ctl_perv_ex6_perf_events),
   .ctl_perv_stq4_perf_events(ctl_perv_stq4_perf_events),
   .ctl_perv_dir_perf_events(ctl_perv_dir_perf_events),
   .lsq_perv_ex7_events(lsq_perv_ex7_events),
   .lsq_perv_ldq_events(lsq_perv_ldq_events),
   .lsq_perv_stq_events(lsq_perv_stq_events),
   .lsq_perv_odq_events(lsq_perv_odq_events),
   .xu_lq_spr_msr_pr(xu_lq_spr_msr_pr),
   .xu_lq_spr_msr_gs(xu_lq_spr_msr_gs),
   .event_bus_in(event_bus_in),
   .event_bus_out(event_bus_out),
   .pc_lq_sg_3(pc_lq_sg_3),
   .pc_lq_func_sl_thold_3(pc_lq_func_sl_thold_3),
   .pc_lq_func_slp_sl_thold_3(pc_lq_func_slp_sl_thold_3),
   .pc_lq_gptr_sl_thold_3(pc_lq_gptr_sl_thold_3),
   .pc_lq_func_nsl_thold_3(pc_lq_func_nsl_thold_3),
   .pc_lq_func_slp_nsl_thold_3(pc_lq_func_slp_nsl_thold_3),
   .pc_lq_abst_sl_thold_3(pc_lq_abst_sl_thold_3),
   .pc_lq_abst_slp_sl_thold_3(pc_lq_abst_slp_sl_thold_3),
   .pc_lq_time_sl_thold_3(pc_lq_time_sl_thold_3),
   .pc_lq_repr_sl_thold_3(pc_lq_repr_sl_thold_3),
   .pc_lq_bolt_sl_thold_3(pc_lq_bolt_sl_thold_3),
   .pc_lq_cfg_slp_sl_thold_3(pc_lq_cfg_slp_sl_thold_3),
   .pc_lq_regf_slp_sl_thold_3(pc_lq_regf_slp_sl_thold_3),
   .pc_lq_ary_nsl_thold_3(pc_lq_ary_nsl_thold_3),
   .pc_lq_ary_slp_nsl_thold_3(pc_lq_ary_slp_nsl_thold_3),
   .pc_lq_cfg_sl_thold_3(pc_lq_cfg_sl_thold_3),
   .pc_lq_fce_3(pc_lq_fce_3),
   .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
   .pc_lq_bo_enable_3(pc_lq_bo_enable_3),
   .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
   .bo_enable_2(bo_enable_2),
   .sg_2(sg_2),
   .func_sl_thold_2(func_sl_thold_2),
   .func_slp_sl_thold_2(func_slp_sl_thold_2),
   .func_nsl_thold_2(func_nsl_thold_2),
   .func_slp_nsl_thold_2(func_slp_nsl_thold_2),
   .ary_nsl_thold_2(ary_nsl_thold_2),
   .ary_slp_nsl_thold_2(ary_slp_nsl_thold_2),
   .time_sl_thold_2(time_sl_thold_2),
   .repr_sl_thold_2(repr_sl_thold_2),
   .bolt_sl_thold_2(bolt_sl_thold_2),
   .cfg_slp_sl_thold_2(cfg_slp_sl_thold_2),
   .regf_slp_sl_thold_2(regf_slp_sl_thold_2),
   .abst_sl_thold_2(abst_sl_thold_2),
   .abst_slp_sl_thold_2(abst_slp_sl_thold_2),
   .cfg_sl_thold_2(cfg_sl_thold_2),
   .fce_2(fce_2),
   .clkoff_dc_b(clkoff_dc_b),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc),
   .mpw1_dc_b(mpw1_dc_b),
   .mpw2_dc_b(mpw2_dc_b),
   .g6t_clkoff_dc_b(g6t_clkoff_dc_b),
   .g6t_d_mode_dc(g6t_d_mode_dc),
   .g6t_delay_lclkr_dc(g6t_delay_lclkr_dc),
   .g6t_mpw1_dc_b(g6t_mpw1_dc_b),
   .g6t_mpw2_dc_b(g6t_mpw2_dc_b),
   .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
   .g8t_d_mode_dc(g8t_d_mode_dc),
   .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
   .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
   .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
   .cam_clkoff_dc_b(cam_clkoff_dc_b),
   .cam_d_mode_dc(cam_d_mode_dc),
   .cam_act_dis_dc(cam_act_dis_dc),
   .cam_delay_lclkr_dc(cam_delay_lclkr_dc),
   .cam_mpw1_dc_b(cam_mpw1_dc_b),
   .cam_mpw2_dc_b(cam_mpw2_dc_b),
   .gptr_scan_in(gptr_scan_in),
   .gptr_scan_out(gptr_scan_out),
   .func_scan_in(perv_func_scan_in),
   .func_scan_out(perv_func_scan_out)
);

assign func_scan_out[18:24] = {lsq_func_scan_out[18:23], perv_func_scan_out};

endmodule
