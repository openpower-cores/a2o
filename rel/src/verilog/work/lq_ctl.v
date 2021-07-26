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

//  Description:  XU LSU Control
//
//*****************************************************************************

`include "tri_a2o.vh"



module lq_ctl(
   xu_lq_spr_ccr2_en_trace,
   xu_lq_spr_ccr2_en_pc,
   xu_lq_spr_ccr2_en_ditc,
   xu_lq_spr_ccr2_en_icswx,
   xu_lq_spr_ccr2_dfrat,
   xu_lq_spr_ccr2_dfratsc,
   xu_lq_spr_ccr2_ap,
   xu_lq_spr_ccr2_ucode_dis,
   xu_lq_spr_ccr2_notlb,
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
   xu_lq_spr_xucr0_mddp,
   xu_lq_spr_xucr0_mdcp,
   xu_lq_spr_xucr4_mmu_mchk,
   xu_lq_spr_xucr4_mddmh,
   xu_lq_spr_msr_cm,
   xu_lq_spr_msr_ds,
   xu_lq_spr_msr_fp,
   xu_lq_spr_msr_spv,
   xu_lq_spr_msr_gs,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_de,
   xu_lq_spr_msr_ucle,
   xu_lq_spr_msrp_uclep,
   xu_lq_spr_dbcr0_dac1,
   xu_lq_spr_dbcr0_dac2,
   xu_lq_spr_dbcr0_dac3,
   xu_lq_spr_dbcr0_dac4,
   xu_lq_spr_dbcr0_idm,
   xu_lq_spr_epcr_duvd,
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
   iu_lq_cp_next_itag,
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
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_2ucode,
   rv_lq_rv1_i0_ucode_cnt,
   rv_lq_rv1_i0_rte_lq,
   rv_lq_rv1_i0_isLoad,
   rv_lq_rv1_i0_ifar,
   rv_lq_rv1_i0_itag,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_2ucode,
   rv_lq_rv1_i1_ucode_cnt,
   rv_lq_rv1_i1_rte_lq,
   rv_lq_rv1_i1_isLoad,
   rv_lq_rv1_i1_ifar,
   rv_lq_rv1_i1_itag,
   odq_pf_report_tid,
   odq_pf_report_itag,
   odq_pf_resolved,
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
   rv_lq_vld,
   rv_lq_ex0_itag,
   rv_lq_ex0_instr,
   rv_lq_ex0_ucode,
   rv_lq_ex0_ucode_cnt,
   rv_lq_ex0_t1_v,
   rv_lq_ex0_t1_p,
   rv_lq_ex0_t3_p,
   rv_lq_ex0_s1_v,
   rv_lq_ex0_s2_v,
   lq_rv_itag0,
   lq_rv_itag0_vld,
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
   lq_rv_gpr_rel_wa,
   lq_xu_gpr_rel_wa,
   lq_rv_gpr_rel_wd,
   lq_xu_gpr_rel_wd,
   lq_xu_cr_ex5_we,
   lq_xu_cr_ex5_wa,
   xu0_lq_ex3_act,
   xu0_lq_ex3_abort,
   xu0_lq_ex3_rt,
   xu0_lq_ex4_rt,
   xu0_lq_ex6_act,
   xu0_lq_ex6_rt,
   lq_xu_ex5_act,
   lq_xu_ex5_cr,
   lq_xu_ex5_rt,
   lq_xu_ex5_abort,
   xu1_lq_ex3_act,
   xu1_lq_ex3_abort,
   xu1_lq_ex3_rt,
   lq_xu_axu_ex4_addr,
   lq_xu_axu_ex5_we,
   lq_xu_axu_ex5_le,
   mm_lq_hold_req,
   mm_lq_hold_done,
   mm_lq_pid,
   mm_lq_lsu_lpidr,
   mm_lq_mmucr0,
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
   lq_mm_perf_dtlb,
   pc_lq_inj_dcachedir_ldp_parity,
   pc_lq_inj_dcachedir_ldp_multihit,
   pc_lq_inj_dcachedir_stp_parity,
   pc_lq_inj_dcachedir_stp_multihit,
   pc_lq_inj_prefetcher_parity,
   lsq_ctl_oldest_tid,
   lsq_ctl_oldest_itag,
   lsq_ctl_stq1_stg_act,
   lsq_ctl_rv0_back_inv,
   lsq_ctl_rv1_back_inv_addr,
   lsq_ctl_stq_release_itag_vld,
   lsq_ctl_stq_release_itag,
   lsq_ctl_stq_release_tid,
   lsq_ctl_ex5_ldq_restart,
   lsq_ctl_ex5_stq_restart,
   lsq_ctl_ex5_stq_restart_miss,
   lsq_ctl_ex5_fwd_val,
   lsq_ctl_ex5_fwd_data,
   lsq_ctl_rv_hold_all,
   lsq_ctl_rv_set_hold,
   lsq_ctl_rv_clr_hold,
   lsq_ctl_stq1_val,
   lsq_ctl_stq1_mftgpr_val,
   lsq_ctl_stq1_mfdpf_val,
   lsq_ctl_stq1_mfdpa_val,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_rel1_thrd_id,
   lsq_ctl_stq1_resv,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_axu_val,
   lsq_ctl_stq1_epid_val,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq1_lock_clr,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_inval,
   lsq_ctl_stq1_dci_val,
   lsq_ctl_stq1_addr,
   lsq_ctl_stq4_xucr0_cul,
   lsq_ctl_rel1_gpr_val,
   lsq_ctl_rel1_ta_gpr,
   lsq_ctl_rel1_upd_gpr,
   lsq_ctl_rel1_clr_val,
   lsq_ctl_rel1_set_val,
   lsq_ctl_rel1_data_val,
   lsq_ctl_rel1_back_inv,
   lsq_ctl_rel1_tag,
   lsq_ctl_rel1_classid,
   lsq_ctl_rel1_lock_set,
   lsq_ctl_rel1_watch_set,
   lsq_ctl_rel2_blk_req,
   lsq_ctl_rel2_data,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_stq5_itag,
   lsq_ctl_stq5_tgpr,
   lsq_ctl_rel2_upd_val,
   lsq_ctl_rel3_l1dump_val,
   lsq_ctl_rel3_clr_relq,
   ctl_lsq_stq4_perr_reject,
   ctl_dat_stq5_way_perr_inval,
   lsq_ctl_ex3_strg_val,
   lsq_ctl_ex3_strg_noop,
   lsq_ctl_ex3_illeg_lswx,
   lsq_ctl_ex3_ct_val,
   lsq_ctl_ex3_be_ct,
   lsq_ctl_ex3_le_ct,
   lsq_ctl_stq_cpl_ready,
   lsq_ctl_stq_cpl_ready_itag,
   lsq_ctl_stq_cpl_ready_tid,
   lsq_ctl_stq_n_flush,
   lsq_ctl_stq_np1_flush,
   lsq_ctl_stq_exception_val,
   lsq_ctl_stq_exception,
   lsq_ctl_stq_dacrw,
   lsq_ctl_sync_in_stq,
   lsq_ctl_sync_done,
   ctl_lsq_stq_cpl_blk,
   ctl_lsq_ex_pipe_full,
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
   ctl_lsq_ex4_is_store,
   ctl_lsq_ex4_is_resv,
   ctl_lsq_ex4_is_mfgpr,
   ctl_lsq_ex4_is_icswxr,
   ctl_lsq_ex4_is_icbi,
   ctl_lsq_ex4_watch_clr,
   ctl_lsq_ex4_watch_clr_all,
   ctl_lsq_ex4_mtspr_trace,
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
   ctl_lsq_ex6_ldh_dacrw,
   ctl_lsq_stq3_icswx_data,
   ctl_lsq_dbg_int_en,
   ctl_lsq_ldp_idle,
   ctl_lsq_rv1_dir_rd_val,
   ctl_lsq_spr_lsucr0_ford,
   ctl_lsq_spr_lsucr0_b2b,
   ctl_lsq_spr_lsucr0_lge,
   ctl_lsq_spr_lsucr0_lca,
   ctl_lsq_spr_lsucr0_sca,
   ctl_lsq_spr_lsucr0_dfwd,
   ctl_lsq_ex4_xu1_data,
   ctl_lsq_pf_empty,
   dir_arr_wr_enable,
   dir_arr_wr_way,
   dir_arr_wr_addr,
   dir_arr_wr_data,
   dir_arr_rd_data1,
   ctl_dat_ex1_data_act,
   ctl_dat_ex2_eff_addr,
   ctl_dat_ex3_opsize,
   ctl_dat_ex3_le_mode,
   ctl_dat_ex3_le_ld_rotsel,
   ctl_dat_ex3_be_ld_rotsel,
   ctl_dat_ex3_algebraic,
   ctl_dat_ex3_le_alg_rotsel,
   ctl_dat_ex4_way_hit,
   dat_ctl_dcarr_perr_way,
   dat_ctl_ex5_load_data,
   dat_ctl_stq6_axu_data,
   stq4_dcarr_wren,
   stq4_dcarr_way_en,
   ctl_spr_dvc1_dbg,
   ctl_spr_dvc2_dbg,
   ctl_perv_spr_lesr1,
   ctl_perv_spr_lesr2,
   ctl_spr_dbcr2_dvc1be,
   ctl_spr_dbcr2_dvc2be,
   ctl_spr_dbcr2_dvc1m,
   ctl_spr_dbcr2_dvc2m,
   ctl_perv_ex6_perf_events,
   ctl_perv_stq4_perf_events,
   ctl_perv_dir_perf_events,
   lq_pc_err_derat_parity,
   lq_pc_err_dir_ldp_parity,
   lq_pc_err_dir_stp_parity,
   lq_pc_err_dcache_parity,
   lq_pc_err_derat_multihit,
   lq_pc_err_dir_ldp_multihit,
   lq_pc_err_dir_stp_multihit,
   lq_pc_err_prefetcher_parity,
   vcs,
   vdd,
   gnd,
   nclk,
   sg_2,
   fce_2,
   func_sl_thold_2,
   func_nsl_thold_2,
   func_slp_sl_thold_2,
   func_slp_nsl_thold_2,
   pc_lq_init_reset,
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
   cfg_slp_sl_thold_2,
   cfg_sl_thold_2,
   regf_slp_sl_thold_2,
   abst_sl_thold_2,
   abst_slp_sl_thold_2,
   time_sl_thold_2,
   ary_nsl_thold_2,
   ary_slp_nsl_thold_2,
   repr_sl_thold_2,
   bolt_sl_thold_2,
   bo_enable_2,
   an_ac_scan_dis_dc_b,
   an_ac_scan_diag_dc,
   an_ac_lbist_en_dc,
   an_ac_atpg_en_dc,
   an_ac_grffence_en_dc,
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
   pc_lq_ram_active,
   lq_pc_ram_data_val,
   lq_pc_ram_data,
   pc_lq_abist_wl64_comp_ena,
   pc_lq_abist_g8t_wenb,
   pc_lq_abist_g8t1p_renb_0,
   pc_lq_abist_g8t_dcomp,
   pc_lq_abist_g8t_bw_1,
   pc_lq_abist_g8t_bw_0,
   pc_lq_abist_di_0,
   pc_lq_abist_waddr_0,
   pc_lq_abist_raddr_0,
   cam_clkoff_dc_b,
   cam_d_mode_dc,
   cam_act_dis_dc,
   cam_delay_lclkr_dc,
   cam_mpw1_dc_b,
   cam_mpw2_dc_b,
   abst_scan_in,
   time_scan_in,
   repr_scan_in,
   func_scan_in,
   regf_scan_in,
   ccfg_scan_in,
   abst_scan_out,
   time_scan_out,
   repr_scan_out,
   func_scan_out,
   regf_scan_out,
   ccfg_scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                                    EXPAND_TYPE = 2;
//parameter                                                    `GPR_WIDTH_ENC = 6;
//parameter                                                    `XER_POOL_ENC = 4;
//parameter                                                    `CR_POOL_ENC = 5;
//parameter                                                    `GPR_POOL_ENC = 6;
//parameter                                                    `AXU_SPARE_ENC = 3;
//parameter                                                    `THREADS_POOL_ENC = 1;
//parameter                                                    `ITAG_SIZE_ENC = 7;		      // Instruction Tag Size
//parameter                                                    `CR_WIDTH = 4;
//parameter                                                    `UCODE_ENTRIES_ENC = 3;
//parameter                                                    `STQ_DATA_SIZE = 64;		      // 64 or 128 Bit store data sizes supported
//parameter                                                    ``FXU0_PIPE_START = 2;
//parameter                                                    `XU0_PIPE_END = 8;
//parameter                                                    ``FXU1_PIPE_START = 2;
//parameter                                                    `XU1_PIPE_END = 5;
//parameter                                                    `LQ_LOAD_PIPE_START = 4;
//parameter                                                    `LQ_LOAD_PIPE_END = 8;
//parameter                                                    `LQ_REL_PIPE_START = 2;
//parameter                                                    `LQ_REL_PIPE_END = 4;
//parameter                                                    `THREADS = 2;
//parameter                                                    `DC_SIZE = 15;		            // 14 => 16K L1D$, 15 => 32K L1D$
//parameter                                                    `CL_SIZE = 6;
//parameter                                                    `LMQ_ENTRIES = 8;
//parameter                                                    `EMQ_ENTRIES = 4;
//parameter                                                    `REAL_IFAR_WIDTH = 42;		   // 42 bit real address
//parameter                                                    `LDSTQ_ENTRIES = 16;		      // Order Queue Size
//parameter                                                    `PF_IFAR_WIDTH = 12;		      // number of IAR bits used by prefetch
//parameter                                                    `BUILD_PFETCH = 1;		      // 1=> include pfetch in the build, 0=> build without pfetch
//parameter                                                    `PFETCH_INITIAL_DEPTH = 0;		// the initial value for the SPR that determines how many lines to prefetch
//parameter                                                    ``PFETCH_Q_SIZE_ENC = 3;		// number of bits to address queue size (3 => 8 entries, 4 => 16 entries)
//parameter                                                    `PFETCH_Q_SIZE = 8;		      // number of entries in prefetch queue
parameter                                                    WAYDATASIZE = 34;		         // TagSize + Parity Bits
parameter                                                    XU0_PIPE_START = `FXU0_PIPE_START+1;
parameter                                                    XU0_PIPE_END   = `FXU0_PIPE_END;
parameter                                                    XU1_PIPE_START = `FXU1_PIPE_START+1;
parameter                                                    XU1_PIPE_END   = `FXU1_PIPE_END;

//--------------------------------------------------------------
// SPR Interface
//--------------------------------------------------------------
input                                                        xu_lq_spr_ccr2_en_trace;		// MTSPR Trace is Enabled
input                                                        xu_lq_spr_ccr2_en_pc;		   // MSGSND is Enabled
input                                                        xu_lq_spr_ccr2_en_ditc;		// DITC is Enabled
input                                                        xu_lq_spr_ccr2_en_icswx;		// ICSWX is Enabled
input                                                        xu_lq_spr_ccr2_dfrat;		   // Force Real Address Translation
input [0:8]                                                  xu_lq_spr_ccr2_dfratsc;		// 0:4: wimge, 5:8: u0:3
input                                                        xu_lq_spr_ccr2_ap;		      // AP Available
input                                                        xu_lq_spr_ccr2_ucode_dis;		// Ucode Disabled
input                                                        xu_lq_spr_ccr2_notlb;		   // MMU is disabled
input                                                        xu_lq_spr_xucr0_clkg_ctl;		// Clock Gating Override
input                                                        xu_lq_spr_xucr0_wlk;		   // Data Cache Way Locking Enable
input                                                        xu_lq_spr_xucr0_mbar_ack;		// L2 ACK of membar and lwsync
input                                                        xu_lq_spr_xucr0_tlbsync;		// L2 ACK of tlbsync
input                                                        xu_lq_spr_xucr0_dcdis;		   // Data Cache Disable
input                                                        xu_lq_spr_xucr0_aflsta;		// AXU Force Load/Store Alignment interrupt
input                                                        xu_lq_spr_xucr0_flsta;		   // FX Force Load/Store Alignment interrupt
input                                                        xu_lq_spr_xucr0_clfc;		   // Cache Directory Lock Flash Clear
input                                                        xu_lq_spr_xucr0_cls;		   // Cacheline Size = 1 => 128Byte size, 0 => 64Byte size
input [0:`THREADS-1]                                         xu_lq_spr_xucr0_trace_um;		// TRACE SPR is Enabled in user mode
input                                                        xu_lq_spr_xucr0_mddp;		   // Machine Check on Data Cache Directory Parity Error
input                                                        xu_lq_spr_xucr0_mdcp;		   // Machine Check on Data Cache Parity Error
input                                                        xu_lq_spr_xucr4_mmu_mchk;		// Machine Check on a Data ERAT Parity or Multihit Error
input                                                        xu_lq_spr_xucr4_mddmh;		   // Machine Check on Data Cache Directory Multihit Error
input [0:`THREADS-1]                                         xu_lq_spr_msr_cm;		      // 64bit mode enable
input [0:`THREADS-1]                                         xu_lq_spr_msr_ds;		      // Data Address Space
input [0:`THREADS-1]                                         xu_lq_spr_msr_fp;		      // FP Available
input [0:`THREADS-1]                                         xu_lq_spr_msr_spv;		      // VEC Available
input [0:`THREADS-1]                                         xu_lq_spr_msr_gs;		      // Guest State
input [0:`THREADS-1]                                         xu_lq_spr_msr_pr;		      // Problem State
input [0:`THREADS-1]                                         xu_lq_spr_msr_de;		      // Debug Interrupt Enable
input [0:`THREADS-1]                                         xu_lq_spr_msr_ucle;		      // User Cache Locking Enable
input [0:`THREADS-1]                                         xu_lq_spr_msrp_uclep;		   // User Cache Locking Enable Protect
input [0:2*`THREADS-1]                                       xu_lq_spr_dbcr0_dac1;		   // Data Address Compare 1 Debug Event Enable
input [0:2*`THREADS-1]                                       xu_lq_spr_dbcr0_dac2;		   // Data Address Compare 2 Debug Event Enable
input [0:2*`THREADS-1]                                       xu_lq_spr_dbcr0_dac3;		   // Data Address Compare 3 Debug Event Enable
input [0:2*`THREADS-1]                                       xu_lq_spr_dbcr0_dac4;		   // Data Address Compare 4 Debug Event Enable
input [0:`THREADS-1]                                         xu_lq_spr_dbcr0_idm;		   // Internal Debug Mode Enable
input [0:`THREADS-1]                                         xu_lq_spr_epcr_duvd;		   // Disable Hypervisor Debug
output                                                       lq_xu_spr_xucr0_cul;		   // Cache Lock unable to lock
output                                                       lq_xu_spr_xucr0_cslc_xuop;	// Invalidate type instruction invalidated lock
output                                                       lq_xu_spr_xucr0_cslc_binv;	// Back-Invalidate invalidated lock
output                                                       lq_xu_spr_xucr0_clo;		   // Cache Lock instruction caused an overlock
output [0:`THREADS-1]                                        lq_iu_spr_dbcr3_ivc;		   // Instruction Value Compare Enabled
input                                                        slowspr_val_in;
input                                                        slowspr_rw_in;
input [0:1]                                                  slowspr_etid_in;
input [0:9]                                                  slowspr_addr_in;
input [64-(2**`GPR_WIDTH_ENC):63]                            slowspr_data_in;
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
input [0:`THREADS-1]                                         iu_lq_cp_flush;
input [0:`THREADS-1]                                         iu_lq_recirc_val;
input [0:`ITAG_SIZE_ENC*`THREADS-1]                          iu_lq_cp_next_itag;
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

//   IU interface to RV for pfetch predictor table0
// port 0
input [0:`THREADS-1]                                         rv_lq_rv1_i0_vld;
input                                                        rv_lq_rv1_i0_ucode_preissue;
input                                                        rv_lq_rv1_i0_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]                               rv_lq_rv1_i0_ucode_cnt;
input                                                        rv_lq_rv1_i0_rte_lq;
input                                                        rv_lq_rv1_i0_isLoad;
input [61-`PF_IFAR_WIDTH+1:61]                               rv_lq_rv1_i0_ifar;
input [0:`ITAG_SIZE_ENC-1]                                   rv_lq_rv1_i0_itag;

// port 1
input [0:`THREADS-1]                                         rv_lq_rv1_i1_vld;
input                                                        rv_lq_rv1_i1_ucode_preissue;
input                                                        rv_lq_rv1_i1_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]                               rv_lq_rv1_i1_ucode_cnt;
input                                                        rv_lq_rv1_i1_rte_lq;
input                                                        rv_lq_rv1_i1_isLoad;
input [61-`PF_IFAR_WIDTH+1:61]                               rv_lq_rv1_i1_ifar;
input [0:`ITAG_SIZE_ENC-1]                                   rv_lq_rv1_i1_itag;

// release itag to pfetch
input [0:`THREADS-1]                                         odq_pf_report_tid;
input [0:`ITAG_SIZE_ENC-1]                                   odq_pf_report_itag;
input                                                        odq_pf_resolved;

//--------------------------------------------------------------
// Interface with XU DERAT
//--------------------------------------------------------------
input                                                        xu_lq_act;
input [0:`THREADS-1]                                         xu_lq_val;
input                                                        xu_lq_is_eratre;
input                                                        xu_lq_is_eratwe;
input                                                        xu_lq_is_eratsx;
input                                                        xu_lq_is_eratilx;
input [0:1]                                                  xu_lq_ws;
input [0:4]                                                  xu_lq_ra_entry;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu_lq_rs_data;
input                                                        xu_lq_hold_req;
output [64-(2**`GPR_WIDTH_ENC):63]                           lq_xu_ex5_data;
output                                                       lq_xu_ord_par_err;
output                                                       lq_xu_ord_read_done;
output                                                       lq_xu_ord_write_done;

//--------------------------------------------------------------
// Interface with RV
//--------------------------------------------------------------
input [0:`THREADS-1]                                         rv_lq_vld;
input [0:`ITAG_SIZE_ENC-1]                                   rv_lq_ex0_itag;
input [0:31]                                                 rv_lq_ex0_instr;
input [0:1]                                                  rv_lq_ex0_ucode;
input [0:`UCODE_ENTRIES_ENC-1]                               rv_lq_ex0_ucode_cnt;
input                                                        rv_lq_ex0_t1_v;
input [0:`GPR_POOL_ENC-1]                                    rv_lq_ex0_t1_p;
input [0:`GPR_POOL_ENC-1]                                    rv_lq_ex0_t3_p;
input                                                        rv_lq_ex0_s1_v;
input                                                        rv_lq_ex0_s2_v;

output [0:`ITAG_SIZE_ENC-1]                                  lq_rv_itag0;
output [0:`THREADS-1]                                        lq_rv_itag0_vld;
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
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]                 lq_rv_gpr_ex6_wa;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_ex6_wd;
output                                                       lq_xu_gpr_ex5_we;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lq_xu_gpr_ex5_wa;
output                                                       lq_rv_gpr_rel_we;
output                                                       lq_xu_gpr_rel_we;
output                                                       lq_xu_axu_rel_we;
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]                 lq_rv_gpr_rel_wa;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lq_xu_gpr_rel_wa;
output [64-(2**`GPR_WIDTH_ENC):64+(((2**`GPR_WIDTH_ENC)-1)/8)] lq_rv_gpr_rel_wd;
output [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)]     lq_xu_gpr_rel_wd;
output                                                       lq_xu_cr_ex5_we;
output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]                  lq_xu_cr_ex5_wa;

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
output                                                       lq_xu_ex5_abort;

//-------------------------------------------------------------------
// Interface with XU1
//-------------------------------------------------------------------
input                                                        xu1_lq_ex3_act;
input                                                        xu1_lq_ex3_abort;
input [64-(2**`GPR_WIDTH_ENC):63]                            xu1_lq_ex3_rt;

//-------------------------------------------------------------------
// Interface with AXU PassThru with XU
//-------------------------------------------------------------------
output [59:63]                                               lq_xu_axu_ex4_addr;
output                                                       lq_xu_axu_ex5_we;
output                                                       lq_xu_axu_ex5_le;

//--------------------------------------------------------------
// Interface with MMU
//--------------------------------------------------------------
input                                                        mm_lq_hold_req;
input                                                        mm_lq_hold_done;
input [0:`THREADS*14-1]                                      mm_lq_pid;
input [0:7]                                                  mm_lq_lsu_lpidr;		   // the LPIDR register
input [0:`THREADS*20-1]                                      mm_lq_mmucr0;
input [0:9]                                                  mm_lq_mmucr1;
input [0:4]                                                  mm_lq_rel_val;
input [0:131]                                                mm_lq_rel_data;
input [0:`EMQ_ENTRIES-1]                                     mm_lq_rel_emq;
input [0:`ITAG_SIZE_ENC-1]                                   mm_lq_itag;
input [0:`THREADS-1]                                         mm_lq_tlb_miss;		   // Request got a TLB Miss
input [0:`THREADS-1]                                         mm_lq_tlb_inelig;		// Request got a TLB Ineligible
input [0:`THREADS-1]                                         mm_lq_pt_fault;		   // Request got a PT Fault
input [0:`THREADS-1]                                         mm_lq_lrat_miss;		   // Request got an LRAT Miss
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
output [0:`THREADS-1]                                        lq_mm_perf_dtlb;

//--------------------------------------------------------------
// Interface with PC
//--------------------------------------------------------------
input                                                        pc_lq_inj_dcachedir_ldp_parity;
input                                                        pc_lq_inj_dcachedir_ldp_multihit;
input                                                        pc_lq_inj_dcachedir_stp_parity;
input                                                        pc_lq_inj_dcachedir_stp_multihit;
input                                                        pc_lq_inj_prefetcher_parity;

//--------------------------------------------------------------
// Interface with Load/Store Queses
//--------------------------------------------------------------
input [0:`THREADS-1]                                         lsq_ctl_oldest_tid;
input [0:`ITAG_SIZE_ENC-1]                                   lsq_ctl_oldest_itag;
input                                                        lsq_ctl_stq1_stg_act;
input                                                        lsq_ctl_rv0_back_inv;
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      lsq_ctl_rv1_back_inv_addr;
input                                                        lsq_ctl_stq_release_itag_vld;
input [0:`ITAG_SIZE_ENC-1]                                   lsq_ctl_stq_release_itag;
input [0:`THREADS-1]                                         lsq_ctl_stq_release_tid;
input                                                        lsq_ctl_ex5_ldq_restart;
input                                                        lsq_ctl_ex5_stq_restart;
input                                                        lsq_ctl_ex5_stq_restart_miss;
input                                                        lsq_ctl_ex5_fwd_val;
input [(128-`STQ_DATA_SIZE):127]                             lsq_ctl_ex5_fwd_data;
input                                                        lsq_ctl_rv_hold_all;
input                                                        lsq_ctl_rv_set_hold;
input [0:`THREADS-1]                                         lsq_ctl_rv_clr_hold;
input                                                        lsq_ctl_stq1_val;
input                                                        lsq_ctl_stq1_mftgpr_val;
input                                                        lsq_ctl_stq1_mfdpf_val;
input                                                        lsq_ctl_stq1_mfdpa_val;
input [0:`THREADS-1]                                         lsq_ctl_stq1_thrd_id;
input [0:`THREADS-1]                                         lsq_ctl_rel1_thrd_id;
input                                                        lsq_ctl_stq1_resv;
input                                                        lsq_ctl_stq1_ci;
input                                                        lsq_ctl_stq1_axu_val;
input                                                        lsq_ctl_stq1_epid_val;
input                                                        lsq_ctl_stq1_store_val;
input                                                        lsq_ctl_stq1_lock_clr;
input                                                        lsq_ctl_stq1_watch_clr;
input [0:1]                                                  lsq_ctl_stq1_l_fld;
input                                                        lsq_ctl_stq1_inval;
input                                                        lsq_ctl_stq1_dci_val;
input [64-`REAL_IFAR_WIDTH:63-`CL_SIZE]                      lsq_ctl_stq1_addr;
input                                                        lsq_ctl_stq4_xucr0_cul;
input                                                        lsq_ctl_rel1_gpr_val;
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]   lsq_ctl_rel1_ta_gpr;
input                                                        lsq_ctl_rel1_upd_gpr;
input                                                        lsq_ctl_rel1_clr_val;
input                                                        lsq_ctl_rel1_set_val;
input                                                        lsq_ctl_rel1_data_val;
input                                                        lsq_ctl_rel1_back_inv;
input [0:3]                                                  lsq_ctl_rel1_tag;
input [0:1]                                                  lsq_ctl_rel1_classid;
input                                                        lsq_ctl_rel1_lock_set;
input                                                        lsq_ctl_rel1_watch_set;
input                                                        lsq_ctl_rel2_blk_req;		   // Block Reload due to RV issue or Back-Invalidate
input [0:127]                                                lsq_ctl_rel2_data;		      // Reload PRF Update Data
input                                                        lsq_ctl_stq2_blk_req;		   // Block Store due to RV issue
input [0:`ITAG_SIZE_ENC-1]                                   lsq_ctl_stq5_itag;
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]   lsq_ctl_stq5_tgpr;
input                                                        lsq_ctl_rel2_upd_val;
input                                                        lsq_ctl_rel3_l1dump_val;		// Reload Complete for an L1_DUMP reload
input                                                        lsq_ctl_rel3_clr_relq;		   // Reload Complete due to an ECC error
output                                                       ctl_lsq_stq4_perr_reject;    // STQ4 parity error detect, reject STQ2 Commit
output [0:7]                                                 ctl_dat_stq5_way_perr_inval;
input                                                        lsq_ctl_ex3_strg_val;
input                                                        lsq_ctl_ex3_strg_noop;
input                                                        lsq_ctl_ex3_illeg_lswx;
input                                                        lsq_ctl_ex3_ct_val;		      // ICSWX Data is valid
input [0:5]                                                  lsq_ctl_ex3_be_ct;		      // Big Endian Coprocessor Type Select
input [0:5]                                                  lsq_ctl_ex3_le_ct;		      // Little Endian Coprocessor Type Select
input                                                        lsq_ctl_stq_cpl_ready;
input [0:`ITAG_SIZE_ENC-1]                                   lsq_ctl_stq_cpl_ready_itag;
input [0:`THREADS-1]                                         lsq_ctl_stq_cpl_ready_tid;
input                                                        lsq_ctl_stq_n_flush;
input                                                        lsq_ctl_stq_np1_flush;
input                                                        lsq_ctl_stq_exception_val;
input [0:5]                                                  lsq_ctl_stq_exception;
input [0:3]                                                  lsq_ctl_stq_dacrw;
input                                                        lsq_ctl_sync_in_stq;
input                                                        lsq_ctl_sync_done;
output                                                       ctl_lsq_stq_cpl_blk;
output                                                       ctl_lsq_ex_pipe_full;
output [0:`THREADS-1]                                        ctl_lsq_ex2_streq_val;
output [0:`ITAG_SIZE_ENC-1]                                  ctl_lsq_ex2_itag;
output [0:`THREADS-1]                                        ctl_lsq_ex2_thrd_id;
output [0:`THREADS-1]                                        ctl_lsq_ex3_ldreq_val;
output [0:`THREADS-1]                                        ctl_lsq_ex3_wchkall_val;
output                                                       ctl_lsq_ex3_pfetch_val;
output [0:15]                                                ctl_lsq_ex3_byte_en;
output [58:63]                                               ctl_lsq_ex3_p_addr;
output [0:`THREADS-1]                                        ctl_lsq_ex3_thrd_id;
output                                                       ctl_lsq_ex3_algebraic;
output [0:2]                                                 ctl_lsq_ex3_opsize;
output                                                       ctl_lsq_ex4_ldreq_val;
output                                                       ctl_lsq_ex4_binvreq_val;
output                                                       ctl_lsq_ex4_streq_val;
output                                                       ctl_lsq_ex4_othreq_val;
output [64-`REAL_IFAR_WIDTH:57]                              ctl_lsq_ex4_p_addr;
output                                                       ctl_lsq_ex4_dReq_val;
output                                                       ctl_lsq_ex4_gath_load;
output                                                       ctl_lsq_ex4_send_l2;
output                                                       ctl_lsq_ex4_has_data;
output                                                       ctl_lsq_ex4_cline_chk;
output [0:4]                                                 ctl_lsq_ex4_wimge;
output                                                       ctl_lsq_ex4_byte_swap;
output                                                       ctl_lsq_ex4_is_sync;
output                                                       ctl_lsq_ex4_all_thrd_chk;
output                                                       ctl_lsq_ex4_is_store;
output                                                       ctl_lsq_ex4_is_resv;
output                                                       ctl_lsq_ex4_is_mfgpr;
output                                                       ctl_lsq_ex4_is_icswxr;
output                                                       ctl_lsq_ex4_is_icbi;
output                                                       ctl_lsq_ex4_watch_clr;
output                                                       ctl_lsq_ex4_watch_clr_all;
output                                                       ctl_lsq_ex4_mtspr_trace;
output                                                       ctl_lsq_ex4_is_inval_op;
output                                                       ctl_lsq_ex4_is_cinval;
output                                                       ctl_lsq_ex5_lock_clr;
output                                                       ctl_lsq_ex5_lock_set;
output                                                       ctl_lsq_ex5_watch_set;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  ctl_lsq_ex5_tgpr;
output                                                       ctl_lsq_ex5_axu_val;		// XU,AXU type operation
output                                                       ctl_lsq_ex5_is_epid;
output [0:3]                                                 ctl_lsq_ex5_usr_def;
output                                                       ctl_lsq_ex5_drop_rel;		// L2 only instructions
output                                                       ctl_lsq_ex5_flush_req;		// Flush request from LDQ/STQ
output                                                       ctl_lsq_ex5_flush_pfetch; // Flush Prefetch in EX5
output [0:10]                                                ctl_lsq_ex5_cmmt_events;
output                                                       ctl_lsq_ex5_perf_val0;
output [0:3]                                                 ctl_lsq_ex5_perf_sel0;
output                                                       ctl_lsq_ex5_perf_val1;
output [0:3]                                                 ctl_lsq_ex5_perf_sel1;
output                                                       ctl_lsq_ex5_perf_val2;
output [0:3]                                                 ctl_lsq_ex5_perf_sel2;
output                                                       ctl_lsq_ex5_perf_val3;
output [0:3]                                                 ctl_lsq_ex5_perf_sel3;
output                                                       ctl_lsq_ex5_not_touch;
output [0:1]                                                 ctl_lsq_ex5_class_id;
output [0:1]                                                 ctl_lsq_ex5_dvc;
output [0:3]                                                 ctl_lsq_ex5_dacrw;
output [0:5]                                                 ctl_lsq_ex5_ttype;
output [0:1]                                                 ctl_lsq_ex5_l_fld;
output                                                       ctl_lsq_ex5_load_hit;
input  [0:3]                                                 lsq_ctl_ex6_ldq_events;      // LDQ Pipeline Performance Events
input  [0:1]                                                 lsq_ctl_ex6_stq_events;      // LDQ Pipeline Performance Events
output [0:3]                                                 ctl_lsq_ex6_ldh_dacrw;
output [0:26]                                                ctl_lsq_stq3_icswx_data;
output [0:`THREADS-1]                                        ctl_lsq_dbg_int_en;
output [0:`THREADS-1]                                        ctl_lsq_ldp_idle;
output                                                       ctl_lsq_rv1_dir_rd_val;
output                                                       ctl_lsq_spr_lsucr0_ford;
output                                                       ctl_lsq_spr_lsucr0_b2b;		// LSUCR0[B2B] Mode enabled
output                                                       ctl_lsq_spr_lsucr0_lge;
output [0:2]                                                 ctl_lsq_spr_lsucr0_lca;
output [0:2]                                                 ctl_lsq_spr_lsucr0_sca;
output                                                       ctl_lsq_spr_lsucr0_dfwd;
output [64-(2**`GPR_WIDTH_ENC):63]                           ctl_lsq_ex4_xu1_data;
output [0:`THREADS-1]                                        ctl_lsq_pf_empty;

//--------------------------------------------------------------
// Interface with Commit Pipe Directories
//--------------------------------------------------------------
output [0:3]                                                 dir_arr_wr_enable;
output [0:7]                                                 dir_arr_wr_way;
output [64-(`DC_SIZE-3):63-`CL_SIZE]                         dir_arr_wr_addr;
output [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data;
input [0:(8*WAYDATASIZE)-1]                                  dir_arr_rd_data1;

//--------------------------------------------------------------
// Interface with DATA
//--------------------------------------------------------------
output                                                       ctl_dat_ex1_data_act;
output [52:59]                                               ctl_dat_ex2_eff_addr;
output [0:4]                                                 ctl_dat_ex3_opsize;
output                                                       ctl_dat_ex3_le_mode;
output [0:3]                                                 ctl_dat_ex3_le_ld_rotsel;
output [0:3]                                                 ctl_dat_ex3_be_ld_rotsel;
output                                                       ctl_dat_ex3_algebraic;
output [0:3]                                                 ctl_dat_ex3_le_alg_rotsel;
output [0:7]                                                 ctl_dat_ex4_way_hit;
input [0:7]                                                  dat_ctl_dcarr_perr_way;
input [(128-`STQ_DATA_SIZE):127]                             dat_ctl_ex5_load_data;
input [(128-`STQ_DATA_SIZE):127]                             dat_ctl_stq6_axu_data;

output                                                       stq4_dcarr_wren;
output [0:7]                                                 stq4_dcarr_way_en;

//--------------------------------------------------------------
// Common Interface
//--------------------------------------------------------------
output [64-(2**`GPR_WIDTH_ENC):63]                           ctl_spr_dvc1_dbg;
output [64-(2**`GPR_WIDTH_ENC):63]                           ctl_spr_dvc2_dbg;
output [0:23]                                                ctl_perv_spr_lesr1;
output [0:23]                                                ctl_perv_spr_lesr2;
output [0:8*`THREADS-1]                                      ctl_spr_dbcr2_dvc1be;
output [0:8*`THREADS-1]                                      ctl_spr_dbcr2_dvc2be;
output [0:2*`THREADS-1]                                      ctl_spr_dbcr2_dvc1m;
output [0:2*`THREADS-1]                                      ctl_spr_dbcr2_dvc2m;

// LQ Pervasive
output [0:18+`THREADS-1]                                     ctl_perv_ex6_perf_events;
output [0:6+`THREADS-1]                                      ctl_perv_stq4_perf_events;
output [0:(`THREADS*3)+1]                                    ctl_perv_dir_perf_events;

// Error Reporting
output                                                       lq_pc_err_derat_parity;
output                                                       lq_pc_err_dir_ldp_parity;
output                                                       lq_pc_err_dir_stp_parity;
output                                                       lq_pc_err_dcache_parity;
output                                                       lq_pc_err_derat_multihit;
output                                                       lq_pc_err_dir_ldp_multihit;
output                                                       lq_pc_err_dir_stp_multihit;
output                                                       lq_pc_err_prefetcher_parity;

// Pervasive


inout                                                        vcs;


inout                                                        vdd;


inout                                                        gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                      nclk;
input                                                        sg_2;
input                                                        fce_2;
input                                                        func_sl_thold_2;
input                                                        func_nsl_thold_2;
input                                                        func_slp_sl_thold_2;
input                                                        func_slp_nsl_thold_2;
input                                                        pc_lq_init_reset;
input                                                        pc_lq_ccflush_dc;
input                                                        clkoff_dc_b;
input                                                        d_mode_dc;
input [5:9]                                                  delay_lclkr_dc;
input [5:9]                                                  mpw1_dc_b;
input                                                        mpw2_dc_b;
input                                                        g8t_clkoff_dc_b;
input                                                        g8t_d_mode_dc;
input [0:4]                                                  g8t_delay_lclkr_dc;
input [0:4]                                                  g8t_mpw1_dc_b;
input                                                        g8t_mpw2_dc_b;
input                                                        cfg_slp_sl_thold_2;
input                                                        cfg_sl_thold_2;
input                                                        regf_slp_sl_thold_2;
input                                                        abst_sl_thold_2;
input                                                        abst_slp_sl_thold_2;
input                                                        time_sl_thold_2;
input                                                        ary_nsl_thold_2;
input                                                        ary_slp_nsl_thold_2;
input                                                        repr_sl_thold_2;
input                                                        bolt_sl_thold_2;
input                                                        bo_enable_2;
input                                                        an_ac_scan_dis_dc_b;
input                                                        an_ac_scan_diag_dc;
input                                                        an_ac_lbist_en_dc;
input                                                        an_ac_atpg_en_dc;
input                                                        an_ac_grffence_en_dc;
input                                                        an_ac_lbist_ary_wrt_thru_dc;
input                                                        pc_lq_abist_ena_dc;
input                                                        pc_lq_abist_raw_dc_b;
input                                                        pc_lq_bo_unload;
input                                                        pc_lq_bo_repair;
input                                                        pc_lq_bo_reset;
input                                                        pc_lq_bo_shdata;
input [4:7]                                                  pc_lq_bo_select;
output [4:7]                                                 lq_pc_bo_fail;
output [4:7]                                                 lq_pc_bo_diagout;

// RAM Control
input [0:`THREADS-1]                                         pc_lq_ram_active;
output                                                       lq_pc_ram_data_val;
output [64-(2**`GPR_WIDTH_ENC):63]                           lq_pc_ram_data;

// G8T ABIST Control
input                                                        pc_lq_abist_wl64_comp_ena;
input                                                        pc_lq_abist_g8t_wenb;
input                                                        pc_lq_abist_g8t1p_renb_0;
input [0:3]                                                  pc_lq_abist_g8t_dcomp;
input                                                        pc_lq_abist_g8t_bw_1;
input                                                        pc_lq_abist_g8t_bw_0;
input [0:3]                                                  pc_lq_abist_di_0;
input [4:9]                                                  pc_lq_abist_waddr_0;
input [3:8]                                                  pc_lq_abist_raddr_0;

// D-ERAT CAM ABIST Control
input                                                        cam_clkoff_dc_b;
input                                                        cam_d_mode_dc;
input                                                        cam_act_dis_dc;
input [0:4]                                                  cam_delay_lclkr_dc;
input [0:4]                                                  cam_mpw1_dc_b;
input                                                        cam_mpw2_dc_b;

// SCAN Ports

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        abst_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        time_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        repr_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:10]                                                 func_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input [0:6]                                                  regf_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                        ccfg_scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       abst_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       time_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       repr_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:10]                                                func_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output [0:6]                                                 regf_scan_out;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                       ccfg_scan_out;

//--------------------------
// components
//--------------------------

//--------------------------
// constants
//--------------------------
parameter                                                    UPRTAGBIT = 64 - `REAL_IFAR_WIDTH;
parameter                                                    LWRTAGBIT = 63 - (`DC_SIZE - 3);
parameter                                                    TAGSIZE = LWRTAGBIT - UPRTAGBIT + 1;
parameter                                                    PAREXTCALC = 8 - (TAGSIZE % 8);
parameter                                                    PARBITS = (TAGSIZE + PAREXTCALC)/8;
parameter                                                    AXU_TARGET_ENC = `AXU_SPARE_ENC + `GPR_POOL_ENC + `THREADS_POOL_ENC;

//--------------------------
// signals
//--------------------------
wire                                                         dcc_dec_hold_all;
wire                                                         dec_byp_ex1_s1_vld;
wire                                                         dec_byp_ex1_s2_vld;
wire                                                         dec_byp_ex1_use_imm;
wire [64-(2**`GPR_WIDTH_ENC):63]                             dec_byp_ex1_imm;
wire                                                         dec_byp_ex1_rs1_zero;
wire                                                         byp_ex2_req_aborted;
wire                                                         dcc_dec_arr_rd_rv1_val;
wire [0:5]                                                   dcc_dec_arr_rd_congr_cl;
wire                                                         dcc_dec_stq3_mftgpr_val;
wire                                                         dcc_dec_stq5_mftgpr_val;
wire [0:51]                                                  derat_dec_rv1_snoop_addr;
wire                                                         derat_dec_hole_all;
wire                                                         dcc_byp_ram_sel;
wire                                                         dcc_dec_ex5_wren;
wire                                                         dec_dcc_ex1_cmd_act;
wire                                                         dec_derat_ex1_derat_act;
wire                                                         dec_dir_ex2_dir_rd_act;
wire [0:`THREADS-1]                                          dec_derat_ex1_pfetch_val;
wire [0:`THREADS-1]                                          dec_spr_ex1_valid;
wire                                                         dec_dcc_ex1_ucode_val;
wire [0:`UCODE_ENTRIES_ENC-1]                                dec_dcc_ex1_ucode_cnt;
wire                                                         dec_dcc_ex1_ucode_op;
wire                                                         dec_dcc_ex1_sfx_val;
wire                                                         dec_dcc_ex1_axu_op_val;
wire                                                         dec_dcc_ex1_axu_falign;
wire                                                         dec_dcc_ex1_axu_fexcpt;
wire [0:2]                                                   dec_dcc_ex1_axu_instr_type;
wire                                                         dec_dcc_ex1_cache_acc;
wire [0:`THREADS-1]                                          dec_dcc_ex1_thrd_id;
wire [0:31]                                                  dec_dcc_ex1_instr;
wire                                                         dec_dcc_ex1_optype1;
wire                                                         dec_dcc_ex1_optype2;
wire                                                         dec_dcc_ex1_optype4;
wire                                                         dec_dcc_ex1_optype8;
wire                                                         dec_dcc_ex1_optype16;
wire                                                         dec_dcc_ex1_optype32;
wire [0:AXU_TARGET_ENC-1]                                    dec_dcc_ex1_target_gpr;
wire                                                         dec_dcc_ex1_mtspr_trace;
wire                                                         dec_dcc_ex1_load_instr;
wire                                                         dec_dcc_ex1_store_instr;
wire                                                         dec_dcc_ex1_dcbf_instr;
wire                                                         dec_dcc_ex1_sync_instr;
wire [0:1]                                                   dec_dcc_ex1_l_fld;
wire                                                         dec_dcc_ex1_dcbi_instr;
wire                                                         dec_dcc_ex1_dcbz_instr;
wire                                                         dec_dcc_ex1_dcbt_instr;
wire                                                         dec_dcc_ex1_pfetch_val;
wire                                                         dec_dcc_ex1_dcbtst_instr;
wire [0:4]                                                   dec_dcc_ex1_th_fld;
wire                                                         dec_dcc_ex1_dcbtls_instr;
wire                                                         dec_dcc_ex1_dcbtstls_instr;
wire                                                         dec_dcc_ex1_dcblc_instr;
wire                                                         dec_dcc_ex1_dcbst_instr;
wire                                                         dec_dcc_ex1_icbi_instr;
wire                                                         dec_dcc_ex1_icblc_instr;
wire                                                         dec_dcc_ex1_icbt_instr;
wire                                                         dec_dcc_ex1_icbtls_instr;
wire                                                         dec_dcc_ex1_icswx_instr;
wire                                                         dec_dcc_ex1_icswxdot_instr;
wire                                                         dec_dcc_ex1_icswx_epid;
wire                                                         dec_dcc_ex1_tlbsync_instr;
wire                                                         dec_dcc_ex1_ldawx_instr;
wire                                                         dec_dcc_ex1_wclr_instr;
wire                                                         dec_dcc_ex1_wchk_instr;
wire                                                         dec_dcc_ex1_resv_instr;
wire                                                         dec_dcc_ex1_mutex_hint;
wire                                                         dec_dcc_ex1_mbar_instr;
wire                                                         dec_dcc_ex1_makeitso_instr;
wire                                                         dec_dcc_ex1_is_msgsnd;
wire                                                         dec_derat_ex1_is_load;
wire                                                         dec_derat_ex1_is_store;
wire [0:`THREADS-1]                                          dec_derat_ex0_val;
wire                                                         dec_derat_ex0_is_extload;
wire                                                         dec_derat_ex0_is_extstore;
wire                                                         dec_derat_ex1_ra_eq_ea;
wire                                                         dec_derat_ex1_is_touch;
wire                                                         dec_dcc_ex1_dci_instr;
wire                                                         dec_dcc_ex1_ici_instr;
wire                                                         dec_dcc_ex1_mword_instr;
wire                                                         dec_dcc_ex1_algebraic;
wire                                                         dec_derat_ex1_byte_rev;
wire                                                         dec_dcc_ex1_strg_index;
wire                                                         dec_dcc_ex1_src_gpr;
wire                                                         dec_dcc_ex1_src_axu;
wire                                                         dec_dcc_ex1_src_dp;
wire                                                         dec_dcc_ex1_targ_gpr;
wire                                                         dec_dcc_ex1_targ_axu;
wire                                                         dec_dcc_ex1_targ_dp;
wire                                                         dec_dcc_ex1_upd_form;
wire [0:`ITAG_SIZE_ENC-1]                                    dec_dcc_ex1_itag;
wire [0:4]                                                   dec_dcc_ex2_rotsel_ovrd;
wire                                                         dec_dcc_ex3_mtdp_val;
wire                                                         dec_dcc_ex3_mfdp_val;
wire [0:4]                                                   dec_dcc_ex3_ipc_ba;
wire [0:1]                                                   dec_dcc_ex3_ipc_sz;
wire                                                         dec_dcc_ex5_req_abort_rpt;
wire                                                         dec_dcc_ex5_axu_abort_rpt;
wire                                                         dec_ex2_is_any_load_dac;
wire                                                         dec_ex2_is_any_store_dac;
wire [0:`CR_POOL_ENC-1]                                      dec_dcc_ex1_cr_fld;
wire                                                         dec_dcc_ex1_expt_det;
wire                                                         dec_dcc_ex1_priv_prog;
wire                                                         dec_dcc_ex1_hypv_prog;
wire                                                         dec_dcc_ex1_illeg_prog;
wire                                                         dec_dcc_ex1_dlock_excp;
wire                                                         dec_dcc_ex1_ilock_excp;
wire                                                         dec_dcc_ex1_ehpriv_excp;
wire [64-(2**`GPR_WIDTH_ENC):63]                             dir_dcc_ex2_eff_addr;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_a;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_b;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_c;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_d;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_e;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_f;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_g;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dir_dcc_ex4_way_tag_h;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_a;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_b;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_c;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_d;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_e;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_f;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_g;
wire [0:PARBITS-1]                                           dir_dcc_ex4_way_par_h;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_a_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_b_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_c_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_d_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_e_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_f_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_g_dir;
wire [0:1+`THREADS]                                          dir_dcc_ex5_way_h_dir;
wire [0:6]                                                   dir_dcc_ex5_dir_lru;
wire                                                         derat_dcc_ex3_wimge_e;
wire                                                         derat_dcc_ex3_itagHit;
wire [0:4]                                                   derat_dcc_ex4_wimge;
wire [0:3]                                                   derat_dcc_ex4_usr_bits;
wire [0:1]                                                   derat_dcc_ex4_wlc;
wire [22:51]                                                 derat_dcc_ex4_p_addr;
wire                                                         derat_dcc_ex4_noop_touch;
wire                                                         derat_dcc_ex4_miss;
wire                                                         derat_dcc_ex4_tlb_err;
wire                                                         derat_dcc_ex4_dsi;
wire                                                         derat_dcc_ex4_vf;
wire                                                         derat_dcc_ex4_multihit_err_det;
wire                                                         derat_dcc_ex4_multihit_err_flush;
wire                                                         derat_dcc_ex4_par_err_det;
wire                                                         derat_dcc_ex4_par_err_flush;
wire                                                         derat_dcc_ex4_tlb_inelig;
wire                                                         derat_dcc_ex4_pt_fault;
wire                                                         derat_dcc_ex4_lrat_miss;
wire                                                         derat_dcc_ex4_tlb_multihit;
wire                                                         derat_dcc_ex4_tlb_par_err;
wire                                                         derat_dcc_ex4_lru_par_err;
wire                                                         derat_dcc_ex4_restart;
wire                                                         derat_dcc_ex4_setHold;
wire [0:`THREADS-1]                                          derat_dcc_clr_hold;
wire [0:`THREADS-1]                                          derat_dcc_emq_idle;
wire							     derat_fir_par_err;
wire							     derat_fir_multihit;
wire                                                         dir_dcc_ex4_hit;
wire                                                         dir_dcc_ex4_miss;
wire                                                         dir_dcc_ex4_set_rel_coll;
wire                                                         dir_dcc_ex4_byp_restart;
wire                                                         dir_dcc_ex5_dir_perr_det;
wire                                                         dir_dcc_ex5_dc_perr_det;
wire                                                         dir_dcc_ex5_dir_perr_flush;
wire                                                         dir_dcc_ex5_dc_perr_flush;
wire                                                         dir_dcc_ex5_multihit_det;
wire                                                         dir_dcc_ex5_multihit_flush;
wire                                                         dir_dcc_stq4_dir_perr_det;
wire                                                         dir_dcc_stq4_multihit_det;
wire                                                         dir_dcc_ex5_stp_flush;
wire                                                         fgen_ex1_stg_flush;
wire                                                         fgen_ex2_stg_flush;
wire                                                         fgen_ex3_stg_flush;
wire                                                         fgen_ex4_cp_flush;
wire                                                         fgen_ex4_stg_flush;
wire                                                         fgen_ex5_stg_flush;
wire                                                         dir_dcc_rel3_dcarr_upd;
wire                                                         dir_dec_rel3_dir_wr_val;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_dec_rel3_dir_wr_addr;
wire                                                         dir_dcc_stq3_hit;
wire                                                         dir_dcc_ex5_cr_rslt;
wire                                                         dcc_dir_ex2_frc_align2;
wire                                                         dcc_dir_ex2_frc_align4;
wire                                                         dcc_dir_ex2_frc_align8;
wire                                                         dcc_dir_ex2_frc_align16;
wire                                                         dcc_dir_ex2_64bit_agen;
wire [0:`THREADS-1]                                          dcc_dir_ex2_thrd_id;
wire                                                         dcc_dir_ex3_lru_upd;
wire                                                         dcc_dir_ex3_cache_acc;
wire                                                         dcc_derat_ex3_strg_noop;
wire                                                         dcc_derat_ex5_blk_tlb_req;
wire [0:`THREADS-1]                                          dcc_derat_ex6_cplt;
wire [0:`ITAG_SIZE_ENC-1]                                    dcc_derat_ex6_cplt_itag;
wire                                                         dcc_dir_ex3_pfetch_val;
wire                                                         dcc_dir_ex3_lock_set;
wire                                                         dcc_dir_ex3_th_c;
wire                                                         dcc_dir_ex3_watch_set;
wire                                                         dcc_dir_ex3_larx_val;
wire                                                         dcc_dir_ex3_watch_chk;
wire                                                         dcc_dir_ex3_ddir_acc;
wire                                                         dcc_dir_ex4_load_val;
wire                                                         dcc_spr_ex3_data_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                             dcc_spr_ex3_eff_addr;
wire                                                         dcc_byp_rel2_stg_act;
wire                                                         dcc_byp_rel3_stg_act;
wire                                                         dcc_byp_ram_act;
wire                                                         dcc_byp_ex4_moveOp_val;
wire                                                         dcc_byp_stq6_moveOp_val;
wire [64-(2**`GPR_WIDTH_ENC):63]                             dcc_byp_ex4_move_data;
wire                                                         dcc_byp_ex5_lq_req_abort;
wire [0:((2**`GPR_WIDTH_ENC)/8)-1]                           dcc_byp_ex5_byte_mask;
wire [0:`THREADS-1]                                          dcc_byp_ex6_thrd_id;
wire                                                         dcc_byp_ex6_dvc1_en;
wire                                                         dcc_byp_ex6_dvc2_en;
wire [0:3]                                                   dcc_byp_ex6_dacr_cmpr;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]                   dcc_dir_ex4_p_addr;
wire                                                         dcc_dir_stq6_store_val;
wire [0:31]                                                  dcc_dir_spr_xucr2_rmt;
wire                                                         dcc_dir_ex2_binv_val;
wire                                                         derat_rv1_snoop_val;
wire [0:`THREADS-1]                                          spr_derat_epsc_wr;
wire [0:`THREADS-1]                                          spr_derat_eplc_wr;
wire [0:`THREADS-1]                                          spr_derat_eplc_epr;
wire [0:`THREADS-1]                                          spr_derat_eplc_eas;
wire [0:`THREADS-1]                                          spr_derat_eplc_egs;
wire [0:(8*`THREADS)-1]                                      spr_derat_eplc_elpid;
wire [0:(14*`THREADS)-1]                                     spr_derat_eplc_epid;
wire [0:`THREADS-1]                                          spr_derat_epsc_epr;
wire [0:`THREADS-1]                                          spr_derat_epsc_eas;
wire [0:`THREADS-1]                                          spr_derat_epsc_egs;
wire [0:(8*`THREADS)-1]                                      spr_derat_epsc_elpid;
wire [0:(14*`THREADS)-1]                                     spr_derat_epsc_epid;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_rd_addr0_01;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_rd_addr0_23;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_rd_addr0_45;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_rd_addr0_67;
wire [0:(8*WAYDATASIZE)-1]                                   dir_arr_rd_data0;
wire [0:3]                                                   dir_arr_wr_enable_int;
wire [0:7]                                                   dir_arr_wr_way_int;
wire [64-(`DC_SIZE-3):63-`CL_SIZE]                           dir_arr_wr_addr_int;
wire [64-`REAL_IFAR_WIDTH:64-`REAL_IFAR_WIDTH+WAYDATASIZE-1] dir_arr_wr_data_int;
wire [0:51]                                                  dir_derat_ex2_eff_addr;
wire                                                         dec_byp_ex0_stg_act;
wire                                                         dec_byp_ex1_stg_act;
wire                                                         dec_byp_ex5_stg_act;
wire                                                         dec_byp_ex6_stg_act;
wire                                                         dec_byp_ex7_stg_act;
wire [64-(2**`GPR_WIDTH_ENC):59]                             dcc_pf_ex5_eff_addr;
wire                                                         dcc_pf_ex5_req_val_4pf;
wire                                                         dcc_pf_ex5_act;
wire                                                         dcc_pf_ex5_loadmiss;
wire [0:`ITAG_SIZE_ENC-1]                                    dcc_pf_ex5_itag;
wire [64-(2**`GPR_WIDTH_ENC):63-`CL_SIZE]                    pf_dec_req_addr;
wire [0:`THREADS-1]                                          pf_dec_req_thrd;
wire [0:`THREADS-1]                                          dcc_pf_ex5_thrd_id;
wire                                                         pf_dec_req_val;
wire                                                         dec_pf_ack;
wire                                                         ctl_pf_clear_queue;
wire [64-(2**`GPR_WIDTH_ENC):63]                             byp_dir_ex2_rs1;
wire [64-(2**`GPR_WIDTH_ENC):63]                             byp_dir_ex2_rs2;
wire [0:87]                                                  derat_xu_debug_group0;
wire [0:87]                                                  derat_xu_debug_group1;
wire [0:87]                                                  derat_xu_debug_group2;
wire [0:87]                                                  derat_xu_debug_group3;
wire                                                         spr_dcc_ex4_dvc1_en;
wire                                                         spr_dcc_ex4_dvc2_en;
wire                                                         spr_dcc_ex4_dacrw1_cmpr;
wire                                                         spr_dcc_ex4_dacrw2_cmpr;
wire                                                         spr_dcc_ex4_dacrw3_cmpr;
wire                                                         spr_dcc_ex4_dacrw4_cmpr;
wire                                                         spr_dcc_spr_xudbg0_exec;
wire [0:`THREADS-1]                                          spr_dcc_spr_xudbg0_tid;
wire                                                         dcc_spr_spr_xudbg0_done;
wire [0:2]                                                   spr_dcc_spr_xudbg0_way;
wire [0:5]                                                   spr_dcc_spr_xudbg0_row;
wire                                                         dcc_spr_spr_xudbg1_valid;
wire [0:3]                                                   dcc_spr_spr_xudbg1_watch;
wire [0:3]                                                   dcc_spr_spr_xudbg1_parity;
wire [0:6]                                                   dcc_spr_spr_xudbg1_lru;
wire                                                         dcc_spr_spr_xudbg1_lock;
wire [33:63]                                                 dcc_spr_spr_xudbg2_tag;
wire [32:63]                                                 spr_dcc_spr_xucr2_rmt;
wire                                                         spr_dcc_spr_lsucr0_clchk;
wire [0:(32*`THREADS)-1]                                     spr_dcc_spr_acop_ct;
wire [0:(32*`THREADS)-1]                                     spr_dcc_spr_hacop_ct;
wire [0:`THREADS-1]                                          spr_pf_spr_dscr_lsd;
wire [0:`THREADS-1]                                          spr_pf_spr_dscr_snse;
wire [0:`THREADS-1]                                          spr_pf_spr_dscr_sse;
wire [0:3*`THREADS-1]                                        spr_pf_spr_dscr_dpfd;
wire [0:8*`THREADS-1]                                        spr_dbcr2_dvc1be;
wire [0:8*`THREADS-1]                                        spr_dbcr2_dvc2be;
wire [0:2*`THREADS-1]                                        spr_dbcr2_dvc1m;
wire [0:2*`THREADS-1]                                        spr_dbcr2_dvc2m;
wire [64-(2**`GPR_WIDTH_ENC):63]                             spr_dvc1_dbg;
wire [64-(2**`GPR_WIDTH_ENC):63]                             spr_dvc2_dbg;
wire [0:31]						                                  spr_pf_spr_pesr;
wire                                                         dcc_dir_ex2_stg_act;
wire                                                         dcc_dir_ex3_stg_act;
wire                                                         dcc_dir_ex4_stg_act;
wire                                                         dcc_dir_ex5_stg_act;
wire                                                         dcc_dir_stq1_stg_act;
wire                                                         dcc_dir_stq2_stg_act;
wire                                                         dcc_dir_stq3_stg_act;
wire                                                         dcc_dir_stq4_stg_act;
wire                                                         dcc_dir_stq5_stg_act;
wire                                                         dcc_dir_binv2_ex2_stg_act;
wire                                                         dcc_dir_binv3_ex3_stg_act;
wire                                                         dcc_dir_binv4_ex4_stg_act;
wire                                                         dcc_dir_binv5_ex5_stg_act;
wire                                                         dcc_dir_binv6_ex6_stg_act;
wire [0:23]                                                  spr_lesr1;
wire [0:5]                                                   spr_lesr1_muxseleb0;
wire [0:5]                                                   spr_lesr1_muxseleb1;
wire [0:5]                                                   spr_lesr1_muxseleb2;
wire [0:5]                                                   spr_lesr1_muxseleb3;
wire [0:23]                                                  spr_lesr2;
wire [0:5]                                                   spr_lesr2_muxseleb4;
wire [0:5]                                                   spr_lesr2_muxseleb5;
wire [0:5]                                                   spr_lesr2_muxseleb6;
wire [0:5]                                                   spr_lesr2_muxseleb7;
wire [0:47]                                                  spr_dcc_spr_lesr;
wire                                                         func_nsl_thold_1;
wire                                                         func_sl_thold_1;
wire                                                         func_slp_sl_thold_1;
wire                                                         func_slp_nsl_thold_1;
wire                                                         regf_slp_sl_thold_1;
wire                                                         sg_1;
wire                                                         fce_1;
wire                                                         func_nsl_thold_0;
wire                                                         func_sl_thold_0;
wire                                                         func_slp_sl_thold_0;
wire                                                         func_slp_nsl_thold_0;
wire                                                         regf_slp_sl_thold_0;
wire                                                         sg_0;
wire                                                         fce_0;
wire                                                         func_nsl_thold_0_b;
wire                                                         func_sl_thold_0_b;
wire                                                         func_slp_sl_thold_0_b;
wire                                                         func_slp_nsl_thold_0_b;
wire                                                         func_nsl_force;
wire                                                         func_sl_force;
wire                                                         func_slp_sl_force;
wire                                                         func_slp_nsl_force;
wire                                                         tiup;
wire                                                         tidn;
wire                                                         abst_scan_in_q;
wire [0:3]                                                   abst_scan_out_int;
wire [0:2]                                                   abst_scan_out_q;
wire [0:2]                                                   time_scan_in_q;
wire [0:2]                                                   time_scan_out_int;
wire                                                         time_scan_out_q;
wire [0:1]                                                   repr_scan_in_q;
wire [0:1]                                                   repr_scan_out_int;
wire                                                         repr_scan_out_q;
wire [0:10]                                                  func_scan_in_q;
wire [0:10]                                                  func_scan_out_int;
wire [0:10]                                                  func_scan_out_q;
wire [3:7]                                                   dir_func_scan_in;
wire                                                         arr_func_scan_out;
wire [0:6]                                                   regf_scan_in_q;
wire [0:6]                                                   regf_scan_out_int;
wire [0:6]                                                   regf_scan_out_q;
wire                                                         spr_derat_cfg_scan;
wire                                                         spr_pf_func_scan;
wire                                                         ccfg_scan_out_int;
wire [0:24]                                                  abist_siv;
wire [0:24]                                                  abist_sov;
wire                                                         abst_sl_thold_1;
wire                                                         abst_slp_sl_thold_1;
wire                                                         time_sl_thold_1;
wire                                                         ary_nsl_thold_1;
wire                                                         ary_slp_nsl_thold_1;
wire                                                         repr_sl_thold_1;
wire                                                         bolt_sl_thold_1;
wire                                                         cfg_sl_thold_1;
wire                                                         abst_sl_thold_0;
wire                                                         abst_slp_sl_thold_0;
wire                                                         time_sl_thold_0;
wire                                                         ary_nsl_thold_0;
wire                                                         ary_slp_nsl_thold_0;
wire                                                         repr_sl_thold_0;
wire                                                         bolt_sl_thold_0;
wire                                                         cfg_sl_thold_0;
wire                                                         abst_sl_thold_0_b;
wire                                                         abst_sl_force;
wire                                                         cfg_sl_thold_0_b;
wire                                                         cfg_sl_force;
wire                                                         pc_lq_abist_wl64_comp_ena_q;
wire [3:8]                                                   pc_lq_abist_raddr_0_q;
wire                                                         pc_lq_abist_g8t_wenb_q;
wire                                                         pc_lq_abist_g8t1p_renb_0_q;
wire [0:3]                                                   pc_lq_abist_g8t_dcomp_q;
wire                                                         pc_lq_abist_g8t_bw_1_q;
wire                                                         pc_lq_abist_g8t_bw_0_q;
wire [0:3]                                                   pc_lq_abist_di_0_q;
wire [4:9]                                                   pc_lq_abist_waddr_0_q;
wire                                                         slat_force;
wire                                                         abst_slat_thold_b;
wire                                                         abst_slat_d2clk;
wire [0:`NCLK_WIDTH-1]                                       abst_slat_lclk;
wire                                                         time_slat_thold_b;
wire                                                         time_slat_d2clk;
wire [0:`NCLK_WIDTH-1]                                       time_slat_lclk;
wire                                                         repr_slat_thold_b;
wire                                                         repr_slat_d2clk;
wire [0:`NCLK_WIDTH-1]                                       repr_slat_lclk;
wire                                                         func_slat_thold_b;
wire                                                         func_slat_d2clk;
wire [0:`NCLK_WIDTH-1]                                       func_slat_lclk;
wire                                                         regf_slat_thold_b;
wire                                                         regf_slat_d2clk;
wire [0:`NCLK_WIDTH-1]                                       regf_slat_lclk;
wire [0:3]                                                   abst_scan_q;
wire [0:3]                                                   abst_scan_q_b;
wire [0:3]                                                   time_scan_q;
wire [0:3]                                                   time_scan_q_b;
wire [0:2]                                                   repr_scan_q;
wire [0:2]                                                   repr_scan_q_b;
wire [0:21]                                                  func_scan_q;
wire [0:21]                                                  func_scan_q_b;
wire [0:13]                                                  regf_scan_q;
wire [0:13]                                                  regf_scan_q_b;

(* analysis_not_referenced="true" *)
wire                                                         unused;

assign tiup = 1'b1;
assign tidn = 1'b0;
assign unused = |abst_scan_q | |abst_scan_q_b | |time_scan_q | |time_scan_q_b |
                |repr_scan_q | |repr_scan_q_b | |func_scan_q | |func_scan_q_b |
                |regf_scan_q | |regf_scan_q_b;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DECODE
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_dec dec(
   //--------------------------------------------------------------
   // Clocks & Power
   //--------------------------------------------------------------
   .nclk(nclk),
   .vdd(vdd),
   .gnd(gnd),

   //--------------------------------------------------------------
   // Pervasive
   //--------------------------------------------------------------
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5]),
   .mpw1_dc_b(mpw1_dc_b[5]),
   .mpw2_dc_b(mpw2_dc_b),
   .func_sl_force(func_sl_force),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .sg_0(sg_0),
   .scan_in(func_scan_in_q[0]),
   .scan_out(func_scan_out_int[0]),

   //--------------------------------------------------------------
   // SPR Interface
   //--------------------------------------------------------------
   .xu_lq_spr_msr_gs(xu_lq_spr_msr_gs),
   .xu_lq_spr_msr_pr(xu_lq_spr_msr_pr),
   .xu_lq_spr_msr_ucle(xu_lq_spr_msr_ucle),
   .xu_lq_spr_msrp_uclep(xu_lq_spr_msrp_uclep),
   .xu_lq_spr_ccr2_en_pc(xu_lq_spr_ccr2_en_pc),
   .xu_lq_spr_ccr2_en_ditc(xu_lq_spr_ccr2_en_ditc),
   .xu_lq_spr_ccr2_en_icswx(xu_lq_spr_ccr2_en_icswx),

   //--------------------------------------------------------------
   // CP Interface
   //--------------------------------------------------------------
   .iu_lq_cp_flush(iu_lq_cp_flush),

   //-----------------------------------------------------
   // Interface with RV
   //-----------------------------------------------------
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

   .dcc_dec_hold_all(dcc_dec_hold_all),

   .xu_lq_hold_req(xu_lq_hold_req),
   .mm_lq_hold_req(mm_lq_hold_req),
   .mm_lq_hold_done(mm_lq_hold_done),

   .lq_rv_itag0(lq_rv_itag0),
   .lq_rv_itag0_vld(lq_rv_itag0_vld),
   .lq_rv_itag0_abort(lq_rv_itag0_abort),
   .lq_rv_hold_all(lq_rv_hold_all),

   //--------------------------------------------------------------
   // Interface with Regfiles
   //--------------------------------------------------------------
   .lq_rv_gpr_ex6_we(lq_rv_gpr_ex6_we),
   .lq_xu_gpr_ex5_we(lq_xu_gpr_ex5_we),

   //-------------------------------------------------------------------
   // Interface with XU
   //-------------------------------------------------------------------
   .lq_xu_ex5_act(lq_xu_ex5_act),

   //--------------------------------------------------------------
   // Interface with BYP
   //--------------------------------------------------------------
   .dec_byp_ex1_s1_vld(dec_byp_ex1_s1_vld),
   .dec_byp_ex1_s2_vld(dec_byp_ex1_s2_vld),
   .dec_byp_ex1_use_imm(dec_byp_ex1_use_imm),
   .dec_byp_ex1_imm(dec_byp_ex1_imm),
   .dec_byp_ex1_rs1_zero(dec_byp_ex1_rs1_zero),
   .dec_byp_ex0_stg_act(dec_byp_ex0_stg_act),
   .dec_byp_ex1_stg_act(dec_byp_ex1_stg_act),
   .dec_byp_ex5_stg_act(dec_byp_ex5_stg_act),
   .dec_byp_ex6_stg_act(dec_byp_ex6_stg_act),
   .dec_byp_ex7_stg_act(dec_byp_ex7_stg_act),
   .byp_dec_ex2_req_aborted(byp_ex2_req_aborted),
   .byp_dec_ex1_s1_abort(byp_dec_ex1_s1_abort),
   .byp_dec_ex1_s2_abort(byp_dec_ex1_s2_abort),

   //-------------------------------------------------------------------
   // Interface with PreFetch
   //-------------------------------------------------------------------
   .pf_dec_req_addr(pf_dec_req_addr),
   .pf_dec_req_thrd(pf_dec_req_thrd),
   .pf_dec_req_val(pf_dec_req_val),
   .dec_pf_ack(dec_pf_ack),

   .lsq_ctl_sync_in_stq(lsq_ctl_sync_in_stq),

   //--------------------------------------------------------------
   // Reload Itag Complete
   //--------------------------------------------------------------
   .lsq_ctl_stq_release_itag_vld(lsq_ctl_stq_release_itag_vld),
   .lsq_ctl_stq_release_itag(lsq_ctl_stq_release_itag),
   .lsq_ctl_stq_release_tid(lsq_ctl_stq_release_tid),

   //--------------------------------------------------------------
   // LSU Back-Invalidate
   //--------------------------------------------------------------
   // Back-Invalidate Interface
   .lsq_ctl_rv0_back_inv(lsq_ctl_rv0_back_inv),
   .lsq_ctl_rv1_back_inv_addr(lsq_ctl_rv1_back_inv_addr),

   //--------------------------------------------------------------
   // LSU L1 Directory Read Instruction
   //--------------------------------------------------------------
   // Directory Read interface
   .dcc_dec_arr_rd_rv1_val(dcc_dec_arr_rd_rv1_val),
   .dcc_dec_arr_rd_congr_cl(dcc_dec_arr_rd_congr_cl),

   //--------------------------------------------------------------
   // LSU L1 Directory Reload Write
   //--------------------------------------------------------------
   .dir_dec_rel3_dir_wr_val(dir_dec_rel3_dir_wr_val),
   .dir_dec_rel3_dir_wr_addr(dir_dec_rel3_dir_wr_addr),

   //--------------------------------------------------------------
   // MFTGPR Instruction
   //--------------------------------------------------------------
   .dcc_dec_stq3_mftgpr_val(dcc_dec_stq3_mftgpr_val),
   .dcc_dec_stq5_mftgpr_val(dcc_dec_stq5_mftgpr_val),

   //--------------------------------------------------------------
   // DERAT Snoop-Invalidate
   //--------------------------------------------------------------
   // Back-Invalidate Interface
   .derat_rv1_snoop_val(derat_rv1_snoop_val),
   .derat_dec_rv1_snoop_addr(derat_dec_rv1_snoop_addr),
   .derat_dec_hole_all(derat_dec_hole_all),

   //--------------------------------------------------------------
   // LSU Control
   //--------------------------------------------------------------
   .dec_dcc_ex1_cmd_act(dec_dcc_ex1_cmd_act),
   .ctl_dat_ex1_data_act(ctl_dat_ex1_data_act),
   .dec_derat_ex1_derat_act(dec_derat_ex1_derat_act),
   .dec_dir_ex2_dir_rd_act(dec_dir_ex2_dir_rd_act),
   .dec_derat_ex1_pfetch_val(dec_derat_ex1_pfetch_val),
   .dec_spr_ex1_valid(dec_spr_ex1_valid),
   .dec_dcc_ex1_expt_det(dec_dcc_ex1_expt_det),
   .dec_dcc_ex1_priv_prog(dec_dcc_ex1_priv_prog),
   .dec_dcc_ex1_hypv_prog(dec_dcc_ex1_hypv_prog),
   .dec_dcc_ex1_illeg_prog(dec_dcc_ex1_illeg_prog),
   .dec_dcc_ex1_dlock_excp(dec_dcc_ex1_dlock_excp),
   .dec_dcc_ex1_ilock_excp(dec_dcc_ex1_ilock_excp),
   .dec_dcc_ex1_ehpriv_excp(dec_dcc_ex1_ehpriv_excp),
   .dec_dcc_ex1_ucode_val(dec_dcc_ex1_ucode_val),
   .dec_dcc_ex1_ucode_cnt(dec_dcc_ex1_ucode_cnt),
   .dec_dcc_ex1_ucode_op(dec_dcc_ex1_ucode_op),
   .dec_dcc_ex1_sfx_val(dec_dcc_ex1_sfx_val),
   .dec_dcc_ex1_cache_acc(dec_dcc_ex1_cache_acc),
   .dec_dcc_ex1_thrd_id(dec_dcc_ex1_thrd_id),
   .dec_dcc_ex1_instr(dec_dcc_ex1_instr),
   .dec_dcc_ex1_optype1(dec_dcc_ex1_optype1),
   .dec_dcc_ex1_optype2(dec_dcc_ex1_optype2),
   .dec_dcc_ex1_optype4(dec_dcc_ex1_optype4),
   .dec_dcc_ex1_optype8(dec_dcc_ex1_optype8),
   .dec_dcc_ex1_optype16(dec_dcc_ex1_optype16),
   .dec_dcc_ex1_optype32(dec_dcc_ex1_optype32),
   .dec_dcc_ex1_target_gpr(dec_dcc_ex1_target_gpr),
   .dec_dcc_ex1_load_instr(dec_dcc_ex1_load_instr),
   .dec_dcc_ex1_store_instr(dec_dcc_ex1_store_instr),
   .dec_dcc_ex1_dcbf_instr(dec_dcc_ex1_dcbf_instr),
   .dec_dcc_ex1_sync_instr(dec_dcc_ex1_sync_instr),
   .dec_dcc_ex1_mbar_instr(dec_dcc_ex1_mbar_instr),
   .dec_dcc_ex1_makeitso_instr(dec_dcc_ex1_makeitso_instr),
   .dec_dcc_ex1_l_fld(dec_dcc_ex1_l_fld),
   .dec_dcc_ex1_dcbi_instr(dec_dcc_ex1_dcbi_instr),
   .dec_dcc_ex1_dcbz_instr(dec_dcc_ex1_dcbz_instr),
   .dec_dcc_ex1_dcbt_instr(dec_dcc_ex1_dcbt_instr),
   .dec_dcc_ex1_pfetch_val(dec_dcc_ex1_pfetch_val),
   .dec_dcc_ex1_dcbtst_instr(dec_dcc_ex1_dcbtst_instr),
   .dec_dcc_ex1_th_fld(dec_dcc_ex1_th_fld),
   .dec_dcc_ex1_dcbtls_instr(dec_dcc_ex1_dcbtls_instr),
   .dec_dcc_ex1_dcbtstls_instr(dec_dcc_ex1_dcbtstls_instr),
   .dec_dcc_ex1_dcblc_instr(dec_dcc_ex1_dcblc_instr),
   .dec_dcc_ex1_dci_instr(dec_dcc_ex1_dci_instr),
   .dec_dcc_ex1_dcbst_instr(dec_dcc_ex1_dcbst_instr),
   .dec_dcc_ex1_icbi_instr(dec_dcc_ex1_icbi_instr),
   .dec_dcc_ex1_ici_instr(dec_dcc_ex1_ici_instr),
   .dec_dcc_ex1_icblc_instr(dec_dcc_ex1_icblc_instr),
   .dec_dcc_ex1_icbt_instr(dec_dcc_ex1_icbt_instr),
   .dec_dcc_ex1_icbtls_instr(dec_dcc_ex1_icbtls_instr),
   .dec_dcc_ex1_tlbsync_instr(dec_dcc_ex1_tlbsync_instr),
   .dec_dcc_ex1_resv_instr(dec_dcc_ex1_resv_instr),
   .dec_dcc_ex1_cr_fld(dec_dcc_ex1_cr_fld),
   .dec_dcc_ex1_mutex_hint(dec_dcc_ex1_mutex_hint),
   .dec_dcc_ex1_axu_op_val(dec_dcc_ex1_axu_op_val),
   .dec_dcc_ex1_axu_falign(dec_dcc_ex1_axu_falign),
   .dec_dcc_ex1_axu_fexcpt(dec_dcc_ex1_axu_fexcpt),
   .dec_dcc_ex1_axu_instr_type(dec_dcc_ex1_axu_instr_type),
   .dec_dcc_ex1_upd_form(dec_dcc_ex1_upd_form),
   .dec_dcc_ex1_algebraic(dec_dcc_ex1_algebraic),
   .dec_dcc_ex1_strg_index(dec_dcc_ex1_strg_index),
   .dec_dcc_ex1_src_gpr(dec_dcc_ex1_src_gpr),
   .dec_dcc_ex1_src_axu(dec_dcc_ex1_src_axu),
   .dec_dcc_ex1_src_dp(dec_dcc_ex1_src_dp),
   .dec_dcc_ex1_targ_gpr(dec_dcc_ex1_targ_gpr),
   .dec_dcc_ex1_targ_axu(dec_dcc_ex1_targ_axu),
   .dec_dcc_ex1_targ_dp(dec_dcc_ex1_targ_dp),
   .dec_derat_ex1_is_load(dec_derat_ex1_is_load),
   .dec_derat_ex1_is_store(dec_derat_ex1_is_store),
   .dec_derat_ex0_val(dec_derat_ex0_val),
   .dec_derat_ex0_is_extload(dec_derat_ex0_is_extload),
   .dec_derat_ex0_is_extstore(dec_derat_ex0_is_extstore),
   .dec_derat_ex1_ra_eq_ea(dec_derat_ex1_ra_eq_ea),
   .dec_derat_ex1_byte_rev(dec_derat_ex1_byte_rev),
   .dec_derat_ex1_is_touch(dec_derat_ex1_is_touch),
   .dec_dcc_ex1_is_msgsnd(dec_dcc_ex1_is_msgsnd),
   .dec_dcc_ex1_mtspr_trace(dec_dcc_ex1_mtspr_trace),
   .dec_dcc_ex1_mword_instr(dec_dcc_ex1_mword_instr),
   .dec_dcc_ex1_icswx_instr(dec_dcc_ex1_icswx_instr),
   .dec_dcc_ex1_icswxdot_instr(dec_dcc_ex1_icswxdot_instr),
   .dec_dcc_ex1_icswx_epid(dec_dcc_ex1_icswx_epid),
   .dec_dcc_ex1_ldawx_instr(dec_dcc_ex1_ldawx_instr),
   .dec_dcc_ex1_wclr_instr(dec_dcc_ex1_wclr_instr),
   .dec_dcc_ex1_wchk_instr(dec_dcc_ex1_wchk_instr),
   .dec_dcc_ex1_itag(dec_dcc_ex1_itag),
   .dec_dcc_ex2_rotsel_ovrd(dec_dcc_ex2_rotsel_ovrd),
   .dec_dcc_ex3_mtdp_val(dec_dcc_ex3_mtdp_val),
   .dec_dcc_ex3_mfdp_val(dec_dcc_ex3_mfdp_val),
   .dec_dcc_ex3_ipc_ba(dec_dcc_ex3_ipc_ba),
   .dec_dcc_ex3_ipc_sz(dec_dcc_ex3_ipc_sz),
   .dec_dcc_ex5_req_abort_rpt(dec_dcc_ex5_req_abort_rpt),
   .dec_dcc_ex5_axu_abort_rpt(dec_dcc_ex5_axu_abort_rpt),
   .dec_ex2_is_any_load_dac(dec_ex2_is_any_load_dac),
   .dec_ex2_is_any_store_dac(dec_ex2_is_any_store_dac),
   .ctl_lsq_ex_pipe_full(ctl_lsq_ex_pipe_full),

   // FXU Load Hit Store is Valid in ex5
   .dcc_dec_ex5_wren(dcc_dec_ex5_wren)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// BYPASS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_byp byp(
   //-------------------------------------------------------------------
   // Clocks & Power
   //-------------------------------------------------------------------
   .nclk(nclk),
   .vdd(vdd),
   .gnd(gnd),

   //-------------------------------------------------------------------
   // Pervasive
   //-------------------------------------------------------------------
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5]),
   .mpw1_dc_b(mpw1_dc_b[5]),
   .mpw2_dc_b(mpw2_dc_b),
   .func_sl_force(func_sl_force),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .sg_0(sg_0),
   .scan_in(func_scan_in_q[1]),
   .scan_out(func_scan_out_int[1]),

   //-------------------------------------------------------------------
   // Interface with XU
   //-------------------------------------------------------------------
   .xu0_lq_ex3_act(xu0_lq_ex3_act),
   .xu0_lq_ex3_abort(xu0_lq_ex3_abort),
   .xu0_lq_ex3_rt(xu0_lq_ex3_rt),
   .xu0_lq_ex4_rt(xu0_lq_ex4_rt),
   .xu0_lq_ex6_act(xu0_lq_ex6_act),
   .xu0_lq_ex6_rt(xu0_lq_ex6_rt),
   .lq_xu_ex5_rt(lq_xu_ex5_rt),
   .xu1_lq_ex3_act(xu1_lq_ex3_act),
   .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
   .xu1_lq_ex3_rt(xu1_lq_ex3_rt),

   //-------------------------------------------------------------------
   // Interface with DEC
   //-------------------------------------------------------------------
   .dec_byp_ex0_stg_act(dec_byp_ex0_stg_act),
   .dec_byp_ex1_stg_act(dec_byp_ex1_stg_act),
   .dec_byp_ex5_stg_act(dec_byp_ex5_stg_act),
   .dec_byp_ex6_stg_act(dec_byp_ex6_stg_act),
   .dec_byp_ex7_stg_act(dec_byp_ex7_stg_act),
   .dec_byp_ex1_s1_vld(dec_byp_ex1_s1_vld),
   .dec_byp_ex1_s2_vld(dec_byp_ex1_s2_vld),
   .dec_byp_ex1_use_imm(dec_byp_ex1_use_imm),
   .dec_byp_ex1_imm(dec_byp_ex1_imm),
   .dec_byp_ex1_rs1_zero(dec_byp_ex1_rs1_zero),
   .byp_ex2_req_aborted(byp_ex2_req_aborted),
   .byp_dec_ex1_s1_abort(byp_dec_ex1_s1_abort),
   .byp_dec_ex1_s2_abort(byp_dec_ex1_s2_abort),

   //-------------------------------------------------------------------
   // Interface with LQ Pipe
   //-------------------------------------------------------------------
   // Load Pipe
   .ctl_lsq_ex4_xu1_data(ctl_lsq_ex4_xu1_data),
   .ctl_lsq_ex6_ldh_dacrw(ctl_lsq_ex6_ldh_dacrw),
   .lsq_ctl_ex5_fwd_val(lsq_ctl_ex5_fwd_val),
   .lsq_ctl_ex5_fwd_data(lsq_ctl_ex5_fwd_data),
   .lsq_ctl_rel2_data(lsq_ctl_rel2_data),
   .dcc_byp_rel2_stg_act(dcc_byp_rel2_stg_act),
   .dcc_byp_rel3_stg_act(dcc_byp_rel3_stg_act),
   .dcc_byp_ram_act(dcc_byp_ram_act),
   .dcc_byp_ex4_moveOp_val(dcc_byp_ex4_moveOp_val),
   .dcc_byp_stq6_moveOp_val(dcc_byp_stq6_moveOp_val),
   .dcc_byp_ex4_move_data(dcc_byp_ex4_move_data),
   .dcc_byp_ex5_lq_req_abort(dcc_byp_ex5_lq_req_abort),
   .dcc_byp_ex5_byte_mask(dcc_byp_ex5_byte_mask),
   .dcc_byp_ex6_thrd_id(dcc_byp_ex6_thrd_id),
   .dcc_byp_ex6_dvc1_en(dcc_byp_ex6_dvc1_en),
   .dcc_byp_ex6_dvc2_en(dcc_byp_ex6_dvc2_en),
   .dcc_byp_ex6_dacr_cmpr(dcc_byp_ex6_dacr_cmpr),
   .dat_ctl_ex5_load_data(dat_ctl_ex5_load_data),
   .dat_ctl_stq6_axu_data(dat_ctl_stq6_axu_data),
   .dcc_byp_ram_sel(dcc_byp_ram_sel),

   .byp_dir_ex2_rs1(byp_dir_ex2_rs1),
   .byp_dir_ex2_rs2(byp_dir_ex2_rs2),

   //-------------------------------------------------------------------
   // Interface with SPR's
   //-------------------------------------------------------------------
   .spr_byp_spr_dvc1_dbg(spr_dvc1_dbg),
   .spr_byp_spr_dvc2_dbg(spr_dvc2_dbg),
   .spr_byp_spr_dbcr2_dvc1m(spr_dbcr2_dvc1m),
   .spr_byp_spr_dbcr2_dvc1be(spr_dbcr2_dvc1be),
   .spr_byp_spr_dbcr2_dvc2m(spr_dbcr2_dvc2m),
   .spr_byp_spr_dbcr2_dvc2be(spr_dbcr2_dvc2be),

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

   //-------------------------------------------------------------------
   // Interface with PERVASIVE
   //-------------------------------------------------------------------
   .lq_pc_ram_data(lq_pc_ram_data),

   //-------------------------------------------------------------------
   // Interface with GPR
   //-------------------------------------------------------------------
   .rv_lq_gpr_ex1_r0d(rv_lq_gpr_ex1_r0d),
   .rv_lq_gpr_ex1_r1d(rv_lq_gpr_ex1_r1d),
   .lq_rv_gpr_ex6_wd(lq_rv_gpr_ex6_wd),
   .lq_rv_gpr_rel_wd(lq_rv_gpr_rel_wd),
   .lq_xu_gpr_rel_wd(lq_xu_gpr_rel_wd),

   //-------------------------------------------------------------------
   // Interface with RV
   //-------------------------------------------------------------------
   .lq_rv_ex2_s1_abort(lq_rv_ex2_s1_abort),
   .lq_rv_ex2_s2_abort(lq_rv_ex2_s2_abort)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DATA CACHE CONTROL
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_dcc #(.PARBITS(PARBITS)) dcc(

   // IU Dispatch
   .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
   .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
   .rv_lq_rv1_i0_2ucode(rv_lq_rv1_i0_2ucode),
   .rv_lq_rv1_i0_ucode_cnt(rv_lq_rv1_i0_ucode_cnt),
   .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
   .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
   .rv_lq_rv1_i1_2ucode(rv_lq_rv1_i1_2ucode),
   .rv_lq_rv1_i1_ucode_cnt(rv_lq_rv1_i1_ucode_cnt),

   // Execution Pipe Inputs
   .dec_dcc_ex0_act(dec_byp_ex0_stg_act),
   .dec_dcc_ex1_cmd_act(dec_dcc_ex1_cmd_act),
   .dec_dcc_ex1_ucode_val(dec_dcc_ex1_ucode_val),
   .dec_dcc_ex1_ucode_cnt(dec_dcc_ex1_ucode_cnt),
   .dec_dcc_ex1_ucode_op(dec_dcc_ex1_ucode_op),
   .dec_dcc_ex1_sfx_val(dec_dcc_ex1_sfx_val),
   .dec_dcc_ex1_axu_op_val(dec_dcc_ex1_axu_op_val),
   .dec_dcc_ex1_axu_falign(dec_dcc_ex1_axu_falign),
   .dec_dcc_ex1_axu_fexcpt(dec_dcc_ex1_axu_fexcpt),
   .dec_dcc_ex1_axu_instr_type(dec_dcc_ex1_axu_instr_type),
   .dec_dcc_ex1_cache_acc(dec_dcc_ex1_cache_acc),
   .dec_dcc_ex1_thrd_id(dec_dcc_ex1_thrd_id),
   .dec_dcc_ex1_instr(dec_dcc_ex1_instr),
   .dec_dcc_ex1_optype1(dec_dcc_ex1_optype1),
   .dec_dcc_ex1_optype2(dec_dcc_ex1_optype2),
   .dec_dcc_ex1_optype4(dec_dcc_ex1_optype4),
   .dec_dcc_ex1_optype8(dec_dcc_ex1_optype8),
   .dec_dcc_ex1_optype16(dec_dcc_ex1_optype16),
   .dec_dcc_ex1_target_gpr(dec_dcc_ex1_target_gpr),
   .dec_dcc_ex1_mtspr_trace(dec_dcc_ex1_mtspr_trace),
   .dec_dcc_ex1_load_instr(dec_dcc_ex1_load_instr),
   .dec_dcc_ex1_store_instr(dec_dcc_ex1_store_instr),
   .dec_dcc_ex1_dcbf_instr(dec_dcc_ex1_dcbf_instr),
   .dec_dcc_ex1_sync_instr(dec_dcc_ex1_sync_instr),
   .dec_dcc_ex1_l_fld(dec_dcc_ex1_l_fld),
   .dec_dcc_ex1_dcbi_instr(dec_dcc_ex1_dcbi_instr),
   .dec_dcc_ex1_dcbz_instr(dec_dcc_ex1_dcbz_instr),
   .dec_dcc_ex1_dcbt_instr(dec_dcc_ex1_dcbt_instr),
   .dec_dcc_ex1_pfetch_val(dec_dcc_ex1_pfetch_val),
   .dec_dcc_ex1_dcbtst_instr(dec_dcc_ex1_dcbtst_instr),
   .dec_dcc_ex1_th_fld(dec_dcc_ex1_th_fld),
   .dec_dcc_ex1_dcbtls_instr(dec_dcc_ex1_dcbtls_instr),
   .dec_dcc_ex1_dcbtstls_instr(dec_dcc_ex1_dcbtstls_instr),
   .dec_dcc_ex1_dcblc_instr(dec_dcc_ex1_dcblc_instr),
   .dec_dcc_ex1_dcbst_instr(dec_dcc_ex1_dcbst_instr),
   .dec_dcc_ex1_icbi_instr(dec_dcc_ex1_icbi_instr),
   .dec_dcc_ex1_icblc_instr(dec_dcc_ex1_icblc_instr),
   .dec_dcc_ex1_icbt_instr(dec_dcc_ex1_icbt_instr),
   .dec_dcc_ex1_icbtls_instr(dec_dcc_ex1_icbtls_instr),
   .dec_dcc_ex1_icswx_instr(dec_dcc_ex1_icswx_instr),
   .dec_dcc_ex1_icswxdot_instr(dec_dcc_ex1_icswxdot_instr),
   .dec_dcc_ex1_icswx_epid(dec_dcc_ex1_icswx_epid),
   .dec_dcc_ex1_tlbsync_instr(dec_dcc_ex1_tlbsync_instr),
   .dec_dcc_ex1_ldawx_instr(dec_dcc_ex1_ldawx_instr),
   .dec_dcc_ex1_wclr_instr(dec_dcc_ex1_wclr_instr),
   .dec_dcc_ex1_wchk_instr(dec_dcc_ex1_wchk_instr),
   .dec_dcc_ex1_resv_instr(dec_dcc_ex1_resv_instr),
   .dec_dcc_ex1_mutex_hint(dec_dcc_ex1_mutex_hint),
   .dec_dcc_ex1_mbar_instr(dec_dcc_ex1_mbar_instr),
   .dec_dcc_ex1_makeitso_instr(dec_dcc_ex1_makeitso_instr),
   .dec_dcc_ex1_is_msgsnd(dec_dcc_ex1_is_msgsnd),
   .dec_dcc_ex1_dci_instr(dec_dcc_ex1_dci_instr),
   .dec_dcc_ex1_ici_instr(dec_dcc_ex1_ici_instr),
   .dec_dcc_ex1_mword_instr(dec_dcc_ex1_mword_instr),
   .dec_dcc_ex1_algebraic(dec_dcc_ex1_algebraic),
   .dec_dcc_ex1_strg_index(dec_dcc_ex1_strg_index),
   .dec_dcc_ex1_src_gpr(dec_dcc_ex1_src_gpr),
   .dec_dcc_ex1_src_axu(dec_dcc_ex1_src_axu),
   .dec_dcc_ex1_src_dp(dec_dcc_ex1_src_dp),
   .dec_dcc_ex1_targ_gpr(dec_dcc_ex1_targ_gpr),
   .dec_dcc_ex1_targ_axu(dec_dcc_ex1_targ_axu),
   .dec_dcc_ex1_targ_dp(dec_dcc_ex1_targ_dp),
   .dec_dcc_ex1_upd_form(dec_dcc_ex1_upd_form),
   .dec_dcc_ex1_itag(dec_dcc_ex1_itag),
   .dec_dcc_ex1_cr_fld(dec_dcc_ex1_cr_fld),
   .dec_dcc_ex1_expt_det(dec_dcc_ex1_expt_det),
   .dec_dcc_ex1_priv_prog(dec_dcc_ex1_priv_prog),
   .dec_dcc_ex1_hypv_prog(dec_dcc_ex1_hypv_prog),
   .dec_dcc_ex1_illeg_prog(dec_dcc_ex1_illeg_prog),
   .dec_dcc_ex1_dlock_excp(dec_dcc_ex1_dlock_excp),
   .dec_dcc_ex1_ilock_excp(dec_dcc_ex1_ilock_excp),
   .dec_dcc_ex1_ehpriv_excp(dec_dcc_ex1_ehpriv_excp),
   .dec_dcc_ex2_is_any_load_dac(dec_ex2_is_any_load_dac),
   .dec_dcc_ex5_req_abort_rpt(dec_dcc_ex5_req_abort_rpt),
   .dec_dcc_ex5_axu_abort_rpt(dec_dcc_ex5_axu_abort_rpt),
   .dir_dcc_ex2_eff_addr(dir_dcc_ex2_eff_addr),

   // Directory Back-Invalidate
   .lsq_ctl_rv0_back_inv(lsq_ctl_rv0_back_inv),

   // Derat Snoop-Invalidate
   .derat_rv1_snoop_val(derat_rv1_snoop_val),

   // Directory Read Operation
   .dir_dcc_ex4_way_tag_a(dir_dcc_ex4_way_tag_a),
   .dir_dcc_ex4_way_tag_b(dir_dcc_ex4_way_tag_b),
   .dir_dcc_ex4_way_tag_c(dir_dcc_ex4_way_tag_c),
   .dir_dcc_ex4_way_tag_d(dir_dcc_ex4_way_tag_d),
   .dir_dcc_ex4_way_tag_e(dir_dcc_ex4_way_tag_e),
   .dir_dcc_ex4_way_tag_f(dir_dcc_ex4_way_tag_f),
   .dir_dcc_ex4_way_tag_g(dir_dcc_ex4_way_tag_g),
   .dir_dcc_ex4_way_tag_h(dir_dcc_ex4_way_tag_h),
   .dir_dcc_ex4_way_par_a(dir_dcc_ex4_way_par_a),
   .dir_dcc_ex4_way_par_b(dir_dcc_ex4_way_par_b),
   .dir_dcc_ex4_way_par_c(dir_dcc_ex4_way_par_c),
   .dir_dcc_ex4_way_par_d(dir_dcc_ex4_way_par_d),
   .dir_dcc_ex4_way_par_e(dir_dcc_ex4_way_par_e),
   .dir_dcc_ex4_way_par_f(dir_dcc_ex4_way_par_f),
   .dir_dcc_ex4_way_par_g(dir_dcc_ex4_way_par_g),
   .dir_dcc_ex4_way_par_h(dir_dcc_ex4_way_par_h),
   .dir_dcc_ex5_way_a_dir(dir_dcc_ex5_way_a_dir),
   .dir_dcc_ex5_way_b_dir(dir_dcc_ex5_way_b_dir),
   .dir_dcc_ex5_way_c_dir(dir_dcc_ex5_way_c_dir),
   .dir_dcc_ex5_way_d_dir(dir_dcc_ex5_way_d_dir),
   .dir_dcc_ex5_way_e_dir(dir_dcc_ex5_way_e_dir),
   .dir_dcc_ex5_way_f_dir(dir_dcc_ex5_way_f_dir),
   .dir_dcc_ex5_way_g_dir(dir_dcc_ex5_way_g_dir),
   .dir_dcc_ex5_way_h_dir(dir_dcc_ex5_way_h_dir),
   .dir_dcc_ex5_dir_lru(dir_dcc_ex5_dir_lru),

   .derat_dcc_ex3_wimge_e(derat_dcc_ex3_wimge_e),
   .derat_dcc_ex3_itagHit(derat_dcc_ex3_itagHit),
   .derat_dcc_ex4_wimge(derat_dcc_ex4_wimge),
   .derat_dcc_ex4_usr_bits(derat_dcc_ex4_usr_bits),
   .derat_dcc_ex4_wlc(derat_dcc_ex4_wlc),
   .derat_dcc_ex4_p_addr(derat_dcc_ex4_p_addr[64 - `REAL_IFAR_WIDTH:51]),
   .derat_dcc_ex4_noop_touch(derat_dcc_ex4_noop_touch),
   .derat_dcc_ex4_miss(derat_dcc_ex4_miss),
   .derat_dcc_ex4_tlb_err(derat_dcc_ex4_tlb_err),
   .derat_dcc_ex4_dsi(derat_dcc_ex4_dsi),
   .derat_dcc_ex4_vf(derat_dcc_ex4_vf),
   .derat_dcc_ex4_multihit_err_det(derat_dcc_ex4_multihit_err_det),
   .derat_dcc_ex4_multihit_err_flush(derat_dcc_ex4_multihit_err_flush),
   .derat_dcc_ex4_par_err_det(derat_dcc_ex4_par_err_det),
   .derat_dcc_ex4_par_err_flush(derat_dcc_ex4_par_err_flush),
   .derat_dcc_ex4_tlb_inelig(derat_dcc_ex4_tlb_inelig),
   .derat_dcc_ex4_pt_fault(derat_dcc_ex4_pt_fault),
   .derat_dcc_ex4_lrat_miss(derat_dcc_ex4_lrat_miss),
   .derat_dcc_ex4_tlb_multihit(derat_dcc_ex4_tlb_multihit),
   .derat_dcc_ex4_tlb_par_err(derat_dcc_ex4_tlb_par_err),
   .derat_dcc_ex4_lru_par_err(derat_dcc_ex4_lru_par_err),
   .derat_dcc_ex4_restart(derat_dcc_ex4_restart),
   .derat_fir_par_err(derat_fir_par_err),
   .derat_fir_multihit(derat_fir_multihit),

   // SetHold and ClrHold for itag
   .derat_dcc_ex4_setHold(derat_dcc_ex4_setHold),
   .derat_dcc_clr_hold(derat_dcc_clr_hold),
   .derat_dcc_emq_idle(derat_dcc_emq_idle),

   .spr_dcc_ex4_dvc1_en(spr_dcc_ex4_dvc1_en),
   .spr_dcc_ex4_dvc2_en(spr_dcc_ex4_dvc2_en),
   .spr_dcc_ex4_dacrw1_cmpr(spr_dcc_ex4_dacrw1_cmpr),
   .spr_dcc_ex4_dacrw2_cmpr(spr_dcc_ex4_dacrw2_cmpr),
   .spr_dcc_ex4_dacrw3_cmpr(spr_dcc_ex4_dacrw3_cmpr),
   .spr_dcc_ex4_dacrw4_cmpr(spr_dcc_ex4_dacrw4_cmpr),
   .spr_dcc_spr_lesr(spr_dcc_spr_lesr),

   .dir_dcc_ex4_hit(dir_dcc_ex4_hit),
   .dir_dcc_ex4_miss(dir_dcc_ex4_miss),
   .dir_dcc_ex4_set_rel_coll(dir_dcc_ex4_set_rel_coll),
   .dir_dcc_ex4_byp_restart(dir_dcc_ex4_byp_restart),
   .dir_dcc_ex5_dir_perr_det(dir_dcc_ex5_dir_perr_det),
   .dir_dcc_ex5_dc_perr_det(dir_dcc_ex5_dc_perr_det),
   .dir_dcc_ex5_dir_perr_flush(dir_dcc_ex5_dir_perr_flush),
   .dir_dcc_ex5_dc_perr_flush(dir_dcc_ex5_dc_perr_flush),
   .dir_dcc_ex5_multihit_det(dir_dcc_ex5_multihit_det),
   .dir_dcc_ex5_multihit_flush(dir_dcc_ex5_multihit_flush),
   .dir_dcc_stq4_dir_perr_det(dir_dcc_stq4_dir_perr_det),
   .dir_dcc_stq4_multihit_det(dir_dcc_stq4_multihit_det),
   .dir_dcc_ex5_stp_flush(dir_dcc_ex5_stp_flush),

   // Completion Inputs
   .iu_lq_cp_flush(iu_lq_cp_flush),
   .iu_lq_recirc_val(iu_lq_recirc_val),
   .iu_lq_cp_next_itag(iu_lq_cp_next_itag),

   // XER[SO] Read for CP_NEXT instructions (stcx./icswx./ldawx.)
   .xu_lq_xer_cp_rd(xu_lq_xer_cp_rd),

   // Stage Flush
   .fgen_ex1_stg_flush(fgen_ex1_stg_flush),
   .fgen_ex2_stg_flush(fgen_ex2_stg_flush),
   .fgen_ex3_stg_flush(fgen_ex3_stg_flush),
   .fgen_ex4_cp_flush(fgen_ex4_cp_flush),
   .fgen_ex4_stg_flush(fgen_ex4_stg_flush),
   .fgen_ex5_stg_flush(fgen_ex5_stg_flush),

   .dir_dcc_rel3_dcarr_upd(dir_dcc_rel3_dcarr_upd),

   // Data Cache Config
   .xu_lq_spr_ccr2_en_trace(xu_lq_spr_ccr2_en_trace),
   .xu_lq_spr_ccr2_dfrat(xu_lq_spr_ccr2_dfrat),
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
   .xu_lq_spr_xucr0_trace_um(xu_lq_spr_xucr0_trace_um),
   .xu_lq_spr_xucr0_mddp(xu_lq_spr_xucr0_mddp),
   .xu_lq_spr_xucr0_mdcp(xu_lq_spr_xucr0_mdcp),
   .xu_lq_spr_xucr4_mmu_mchk(xu_lq_spr_xucr4_mmu_mchk),
   .xu_lq_spr_xucr4_mddmh(xu_lq_spr_xucr4_mddmh),
   .xu_lq_spr_msr_cm(xu_lq_spr_msr_cm),
   .xu_lq_spr_msr_fp(xu_lq_spr_msr_fp),
   .xu_lq_spr_msr_spv(xu_lq_spr_msr_spv),
   .xu_lq_spr_msr_de(xu_lq_spr_msr_de),
   .xu_lq_spr_dbcr0_idm(xu_lq_spr_dbcr0_idm),
   .xu_lq_spr_epcr_duvd(xu_lq_spr_epcr_duvd),

   // MSR[GS,PR] bits, indicates which state we are running in
   .xu_lq_spr_msr_gs(xu_lq_spr_msr_gs),
   .xu_lq_spr_msr_pr(xu_lq_spr_msr_pr),
   .xu_lq_spr_msr_ds(xu_lq_spr_msr_ds),
   .mm_lq_lsu_lpidr(mm_lq_lsu_lpidr),
   .mm_lq_pid(mm_lq_pid),

   // RESTART indicator
   .lsq_ctl_ex5_ldq_restart(lsq_ctl_ex5_ldq_restart),
   .lsq_ctl_ex5_stq_restart(lsq_ctl_ex5_stq_restart),
   .lsq_ctl_ex5_stq_restart_miss(lsq_ctl_ex5_stq_restart_miss),

   // Store Data Forward
   .lsq_ctl_ex5_fwd_val(lsq_ctl_ex5_fwd_val),

   .lsq_ctl_sync_in_stq(lsq_ctl_sync_in_stq),

   // Hold RV Indicator
   .lsq_ctl_rv_hold_all(lsq_ctl_rv_hold_all),

   // Reservation station set barrier indicator
   .lsq_ctl_rv_set_hold(lsq_ctl_rv_set_hold),
   .lsq_ctl_rv_clr_hold(lsq_ctl_rv_clr_hold),

   // Reload/Commit Pipe
   .lsq_ctl_stq1_stg_act(lsq_ctl_stq1_stg_act),
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),
   .lsq_ctl_stq1_mftgpr_val(lsq_ctl_stq1_mftgpr_val),
   .lsq_ctl_stq1_mfdpf_val(lsq_ctl_stq1_mfdpf_val),
   .lsq_ctl_stq1_mfdpa_val(lsq_ctl_stq1_mfdpa_val),
   .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
   .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
   .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
   .lsq_ctl_stq1_resv(lsq_ctl_stq1_resv),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_axu_val(lsq_ctl_stq1_axu_val),
   .lsq_ctl_stq1_epid_val(lsq_ctl_stq1_epid_val),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_stq4_xucr0_cul(lsq_ctl_stq4_xucr0_cul),
   .lsq_ctl_stq5_itag(lsq_ctl_stq5_itag),
   .lsq_ctl_stq5_tgpr(lsq_ctl_stq5_tgpr),
   .lsq_ctl_rel1_gpr_val(lsq_ctl_rel1_gpr_val),
   .lsq_ctl_rel1_ta_gpr(lsq_ctl_rel1_ta_gpr),
   .lsq_ctl_rel1_upd_gpr(lsq_ctl_rel1_upd_gpr),

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

   // Illegal LSWX has been determined
   .lsq_ctl_ex3_strg_val(lsq_ctl_ex3_strg_val),
   .lsq_ctl_ex3_strg_noop(lsq_ctl_ex3_strg_noop),
   .lsq_ctl_ex3_illeg_lswx(lsq_ctl_ex3_illeg_lswx),
   .lsq_ctl_ex3_ct_val(lsq_ctl_ex3_ct_val),
   .lsq_ctl_ex3_be_ct(lsq_ctl_ex3_be_ct),
   .lsq_ctl_ex3_le_ct(lsq_ctl_ex3_le_ct),

   // Directory Results Input
   .dir_dcc_stq3_hit(dir_dcc_stq3_hit),
   .dir_dcc_ex5_cr_rslt(dir_dcc_ex5_cr_rslt),

   // EX2 Execution Pipe Outputs
   .dcc_dir_ex2_frc_align2(dcc_dir_ex2_frc_align2),
   .dcc_dir_ex2_frc_align4(dcc_dir_ex2_frc_align4),
   .dcc_dir_ex2_frc_align8(dcc_dir_ex2_frc_align8),
   .dcc_dir_ex2_frc_align16(dcc_dir_ex2_frc_align16),
   .dcc_dir_ex2_64bit_agen(dcc_dir_ex2_64bit_agen),
   .dcc_dir_ex2_thrd_id(dcc_dir_ex2_thrd_id),
   .dcc_derat_ex3_strg_noop(dcc_derat_ex3_strg_noop),
   .dcc_derat_ex5_blk_tlb_req(dcc_derat_ex5_blk_tlb_req),
   .dcc_derat_ex6_cplt(dcc_derat_ex6_cplt),
   .dcc_derat_ex6_cplt_itag(dcc_derat_ex6_cplt_itag),

   // EX3 Execution Pipe Outputs
   .dcc_dir_ex3_lru_upd(dcc_dir_ex3_lru_upd),
   .dcc_dir_ex3_cache_acc(dcc_dir_ex3_cache_acc),
   .dcc_dir_ex3_pfetch_val(dcc_dir_ex3_pfetch_val),
   .dcc_dir_ex3_lock_set(dcc_dir_ex3_lock_set),
   .dcc_dir_ex3_th_c(dcc_dir_ex3_th_c),
   .dcc_dir_ex3_watch_set(dcc_dir_ex3_watch_set),
   .dcc_dir_ex3_larx_val(dcc_dir_ex3_larx_val),
   .dcc_dir_ex3_watch_chk(dcc_dir_ex3_watch_chk),
   .dcc_dir_ex3_ddir_acc(dcc_dir_ex3_ddir_acc),
   .dcc_dir_ex4_load_val(dcc_dir_ex4_load_val),
   .dcc_spr_ex3_data_val(dcc_spr_ex3_data_val),
   .dcc_spr_ex3_eff_addr(dcc_spr_ex3_eff_addr),

   .ctl_dat_ex3_opsize(ctl_dat_ex3_opsize),
   .ctl_dat_ex3_le_mode(ctl_dat_ex3_le_mode),
   .ctl_dat_ex3_le_ld_rotsel(ctl_dat_ex3_le_ld_rotsel),
   .ctl_dat_ex3_be_ld_rotsel(ctl_dat_ex3_be_ld_rotsel),
   .ctl_dat_ex3_algebraic(ctl_dat_ex3_algebraic),
   .ctl_dat_ex3_le_alg_rotsel(ctl_dat_ex3_le_alg_rotsel),

   // EX4 Execution Pipe Outputs
   .dcc_byp_rel2_stg_act(dcc_byp_rel2_stg_act),
   .dcc_byp_rel3_stg_act(dcc_byp_rel3_stg_act),
   .dcc_byp_ram_act(dcc_byp_ram_act),
   .byp_dcc_ex2_req_aborted(byp_ex2_req_aborted),
   .dcc_byp_ex4_moveOp_val(dcc_byp_ex4_moveOp_val),
   .dcc_byp_stq6_moveOp_val(dcc_byp_stq6_moveOp_val),
   .dcc_byp_ex4_move_data(dcc_byp_ex4_move_data),
   .dcc_byp_ex5_lq_req_abort(dcc_byp_ex5_lq_req_abort),
   .dcc_byp_ex5_byte_mask(dcc_byp_ex5_byte_mask),
   .dcc_byp_ex6_thrd_id(dcc_byp_ex6_thrd_id),
   .dcc_byp_ex6_dvc1_en(dcc_byp_ex6_dvc1_en),
   .dcc_byp_ex6_dvc2_en(dcc_byp_ex6_dvc2_en),
   .dcc_byp_ex6_dacr_cmpr(dcc_byp_ex6_dacr_cmpr),
   .dcc_dir_ex4_p_addr(dcc_dir_ex4_p_addr),
   .dcc_dir_stq6_store_val(dcc_dir_stq6_store_val),

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
   .ctl_lsq_stq3_icswx_data(ctl_lsq_stq3_icswx_data),
   .ctl_lsq_dbg_int_en(ctl_lsq_dbg_int_en),
   .ctl_lsq_ldp_idle(ctl_lsq_ldp_idle),

   // SPR Directory Read Valid
   .ctl_lsq_rv1_dir_rd_val(ctl_lsq_rv1_dir_rd_val),

   // Directory Read interface
   .dcc_dec_arr_rd_rv1_val(dcc_dec_arr_rd_rv1_val),
   .dcc_dec_arr_rd_congr_cl(dcc_dec_arr_rd_congr_cl),

   // MFTGPR instruction
   .dcc_dec_stq3_mftgpr_val(dcc_dec_stq3_mftgpr_val),
   .dcc_dec_stq5_mftgpr_val(dcc_dec_stq5_mftgpr_val),

   // SPR status
   .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
   .dcc_dir_spr_xucr2_rmt(dcc_dir_spr_xucr2_rmt),
   .spr_dcc_spr_xudbg0_exec(spr_dcc_spr_xudbg0_exec),
   .spr_dcc_spr_xudbg0_tid(spr_dcc_spr_xudbg0_tid),
   .spr_dcc_spr_xudbg0_way(spr_dcc_spr_xudbg0_way),
   .spr_dcc_spr_xudbg0_row(spr_dcc_spr_xudbg0_row),
   .dcc_spr_spr_xudbg0_done(dcc_spr_spr_xudbg0_done),
   .dcc_spr_spr_xudbg1_valid(dcc_spr_spr_xudbg1_valid),
   .dcc_spr_spr_xudbg1_watch(dcc_spr_spr_xudbg1_watch),
   .dcc_spr_spr_xudbg1_parity(dcc_spr_spr_xudbg1_parity),
   .dcc_spr_spr_xudbg1_lru(dcc_spr_spr_xudbg1_lru),
   .dcc_spr_spr_xudbg1_lock(dcc_spr_spr_xudbg1_lock),
   .dcc_spr_spr_xudbg2_tag(dcc_spr_spr_xudbg2_tag),
   .spr_dcc_spr_xucr2_rmt(spr_dcc_spr_xucr2_rmt),
   .spr_dcc_spr_lsucr0_clchk(spr_dcc_spr_lsucr0_clchk),
   .spr_dcc_spr_acop_ct(spr_dcc_spr_acop_ct),
   .spr_dcc_spr_hacop_ct(spr_dcc_spr_hacop_ct),
   .spr_dcc_epsc_epr(spr_derat_epsc_epr),
   .spr_dcc_epsc_eas(spr_derat_epsc_eas),
   .spr_dcc_epsc_egs(spr_derat_epsc_egs),
   .spr_dcc_epsc_elpid(spr_derat_epsc_elpid),
   .spr_dcc_epsc_epid(spr_derat_epsc_epid),

   // Back-invalidate
   .dcc_dir_ex2_binv_val(dcc_dir_ex2_binv_val),

   // Update Data Array Valid
   .stq4_dcarr_wren(stq4_dcarr_wren),

   .dcc_byp_ram_sel(dcc_byp_ram_sel),
   .dcc_dec_ex5_wren(dcc_dec_ex5_wren),
   .lq_xu_gpr_ex5_wa(lq_xu_gpr_ex5_wa),
   .lq_rv_gpr_ex6_wa(lq_rv_gpr_ex6_wa),
   .lq_rv_gpr_rel_we(lq_rv_gpr_rel_we),
   .lq_xu_gpr_rel_we(lq_xu_gpr_rel_we),
   .lq_xu_axu_rel_we(lq_xu_axu_rel_we),
   .lq_rv_gpr_rel_wa(lq_rv_gpr_rel_wa),
   .lq_xu_gpr_rel_wa(lq_xu_gpr_rel_wa),
   .lq_xu_ex5_abort(lq_xu_ex5_abort),

   .lq_xu_cr_ex5_we(lq_xu_cr_ex5_we),
   .lq_xu_cr_ex5_wa(lq_xu_cr_ex5_wa),
   .lq_xu_ex5_cr(lq_xu_ex5_cr),

   // Interface with AXU PassThru with XU
   .lq_xu_axu_ex4_addr(lq_xu_axu_ex4_addr),
   .lq_xu_axu_ex5_we(lq_xu_axu_ex5_we),
   .lq_xu_axu_ex5_le(lq_xu_axu_ex5_le),

   // Outputs to Reservation Station
   .lq_rv_itag1_vld(lq_rv_itag1_vld),
   .lq_rv_itag1(lq_rv_itag1),
   .lq_rv_itag1_restart(lq_rv_itag1_restart),
   .lq_rv_itag1_abort(lq_rv_itag1_abort),
   .lq_rv_itag1_hold(lq_rv_itag1_hold),
   .lq_rv_itag1_cord(lq_rv_itag1_cord),
   .lq_rv_clr_hold(lq_rv_clr_hold),
   .dcc_dec_hold_all(dcc_dec_hold_all),

   // Completion Report
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

   // outputs to prefetch
   .dcc_pf_ex5_eff_addr(dcc_pf_ex5_eff_addr),
   .dcc_pf_ex5_req_val_4pf(dcc_pf_ex5_req_val_4pf),
   .dcc_pf_ex5_act(dcc_pf_ex5_act),
   .dcc_pf_ex5_thrd_id(dcc_pf_ex5_thrd_id),
   .dcc_pf_ex5_loadmiss(dcc_pf_ex5_loadmiss),
   .dcc_pf_ex5_itag(dcc_pf_ex5_itag),

   // Error Reporting
   .lq_pc_err_derat_parity(lq_pc_err_derat_parity),
   .lq_pc_err_dir_ldp_parity(lq_pc_err_dir_ldp_parity),
   .lq_pc_err_dir_stp_parity(lq_pc_err_dir_stp_parity),
   .lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
   .lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
   .lq_pc_err_dir_ldp_multihit(lq_pc_err_dir_ldp_multihit),
   .lq_pc_err_dir_stp_multihit(lq_pc_err_dir_stp_multihit),

   // Ram Mode Control
   .pc_lq_ram_active(pc_lq_ram_active),
   .lq_pc_ram_data_val(lq_pc_ram_data_val),

   // LQ Pervasive
    .ctl_perv_ex6_perf_events(ctl_perv_ex6_perf_events),
    .ctl_perv_stq4_perf_events(ctl_perv_stq4_perf_events),


   // ACT's
   .dcc_dir_ex2_stg_act(dcc_dir_ex2_stg_act),
   .dcc_dir_ex3_stg_act(dcc_dir_ex3_stg_act),
   .dcc_dir_ex4_stg_act(dcc_dir_ex4_stg_act),
   .dcc_dir_ex5_stg_act(dcc_dir_ex5_stg_act),
   .dcc_dir_stq1_stg_act(dcc_dir_stq1_stg_act),
   .dcc_dir_stq2_stg_act(dcc_dir_stq2_stg_act),
   .dcc_dir_stq3_stg_act(dcc_dir_stq3_stg_act),
   .dcc_dir_stq4_stg_act(dcc_dir_stq4_stg_act),
   .dcc_dir_stq5_stg_act(dcc_dir_stq5_stg_act),
   .dcc_dir_binv2_ex2_stg_act(dcc_dir_binv2_ex2_stg_act),
   .dcc_dir_binv3_ex3_stg_act(dcc_dir_binv3_ex3_stg_act),
   .dcc_dir_binv4_ex4_stg_act(dcc_dir_binv4_ex4_stg_act),
   .dcc_dir_binv5_ex5_stg_act(dcc_dir_binv5_ex5_stg_act),
   .dcc_dir_binv6_ex6_stg_act(dcc_dir_binv6_ex6_stg_act),

   // Pervasive
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .func_slp_nsl_thold_0_b(func_slp_nsl_thold_0_b),
   .func_slp_nsl_force(func_slp_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5]),
   .mpw1_dc_b(mpw1_dc_b[5]),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(func_scan_in_q[2]),
   .scan_out(func_scan_out_int[2])
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LQ SPR control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_spr  spr(
   .nclk(nclk),

   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5]),
   .mpw1_dc_b(mpw1_dc_b[5]),
   .mpw2_dc_b(mpw2_dc_b),

   .ccfg_sl_force(cfg_sl_force),
   .ccfg_sl_thold_0_b(cfg_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .sg_0(sg_0),
   .scan_in(func_scan_in_q[10]),
   .scan_out(spr_pf_func_scan),
   .ccfg_scan_in(ccfg_scan_in),
   .ccfg_scan_out(spr_derat_cfg_scan),

   .flush(iu_lq_cp_flush),
   .ex1_valid(dec_spr_ex1_valid),
   .ex3_data_val(dcc_spr_ex3_data_val),
   .ex3_eff_addr(dcc_spr_ex3_eff_addr),

   // SlowSPR Interface
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

   // DAC
   .ex2_is_any_load_dac(dec_ex2_is_any_load_dac),
   .ex2_is_any_store_dac(dec_ex2_is_any_store_dac),

   .spr_dcc_ex4_dvc1_en(spr_dcc_ex4_dvc1_en),
   .spr_dcc_ex4_dvc2_en(spr_dcc_ex4_dvc2_en),
   .spr_dcc_ex4_dacrw1_cmpr(spr_dcc_ex4_dacrw1_cmpr),
   .spr_dcc_ex4_dacrw2_cmpr(spr_dcc_ex4_dacrw2_cmpr),
   .spr_dcc_ex4_dacrw3_cmpr(spr_dcc_ex4_dacrw3_cmpr),
   .spr_dcc_ex4_dacrw4_cmpr(spr_dcc_ex4_dacrw4_cmpr),

   // SPRs
   .spr_msr_pr(xu_lq_spr_msr_pr),
   .spr_msr_gs(xu_lq_spr_msr_gs),
   .spr_msr_ds(xu_lq_spr_msr_ds),
   .spr_dbcr0_dac1(xu_lq_spr_dbcr0_dac1),
   .spr_dbcr0_dac2(xu_lq_spr_dbcr0_dac2),
   .spr_dbcr0_dac3(xu_lq_spr_dbcr0_dac3),
   .spr_dbcr0_dac4(xu_lq_spr_dbcr0_dac4),

   .spr_xudbg0_exec(spr_dcc_spr_xudbg0_exec),
   .spr_xudbg0_tid(spr_dcc_spr_xudbg0_tid),
   .spr_xudbg0_done(dcc_spr_spr_xudbg0_done),
   .spr_xudbg0_way(spr_dcc_spr_xudbg0_way),
   .spr_xudbg0_row(spr_dcc_spr_xudbg0_row),
   .spr_xudbg1_valid(dcc_spr_spr_xudbg1_valid),
   .spr_xudbg1_watch(dcc_spr_spr_xudbg1_watch),
   .spr_xudbg1_parity(dcc_spr_spr_xudbg1_parity),
   .spr_xudbg1_lru(dcc_spr_spr_xudbg1_lru),
   .spr_xudbg1_lock(dcc_spr_spr_xudbg1_lock),
   .spr_xudbg2_tag(dcc_spr_spr_xudbg2_tag),
   .spr_dbcr2_dvc1be(spr_dbcr2_dvc1be),
   .spr_dbcr2_dvc2be(spr_dbcr2_dvc2be),
   .spr_dbcr2_dvc1m(spr_dbcr2_dvc1m),
   .spr_dbcr2_dvc2m(spr_dbcr2_dvc2m),

   .spr_dvc1(spr_dvc1_dbg),
   .spr_dvc2(spr_dvc2_dbg),
   .spr_pesr(spr_pf_spr_pesr),
	.spr_lesr1_muxseleb0(spr_lesr1_muxseleb0),
	.spr_lesr1_muxseleb1(spr_lesr1_muxseleb1),
	.spr_lesr1_muxseleb2(spr_lesr1_muxseleb2),
	.spr_lesr1_muxseleb3(spr_lesr1_muxseleb3),
	.spr_lesr2_muxseleb4(spr_lesr2_muxseleb4),
	.spr_lesr2_muxseleb5(spr_lesr2_muxseleb5),
	.spr_lesr2_muxseleb6(spr_lesr2_muxseleb6),
	.spr_lesr2_muxseleb7(spr_lesr2_muxseleb7),
   .spr_lsucr0_lca(ctl_lsq_spr_lsucr0_lca),
   .spr_lsucr0_sca(ctl_lsq_spr_lsucr0_sca),
   .spr_lsucr0_lge(ctl_lsq_spr_lsucr0_lge),
   .spr_lsucr0_b2b(ctl_lsq_spr_lsucr0_b2b),
   .spr_lsucr0_dfwd(ctl_lsq_spr_lsucr0_dfwd),
   .spr_lsucr0_clchk(spr_dcc_spr_lsucr0_clchk),
   .spr_lsucr0_ford(ctl_lsq_spr_lsucr0_ford),
   .spr_xucr2_rmt3(spr_dcc_spr_xucr2_rmt[32:39]),
   .spr_xucr2_rmt2(spr_dcc_spr_xucr2_rmt[40:47]),
   .spr_xucr2_rmt1(spr_dcc_spr_xucr2_rmt[48:55]),
   .spr_xucr2_rmt0(spr_dcc_spr_xucr2_rmt[56:63]),
   .spr_acop_ct(spr_dcc_spr_acop_ct),
   .spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
   .spr_dscr_lsd(spr_pf_spr_dscr_lsd),
   .spr_dscr_snse(spr_pf_spr_dscr_snse),
   .spr_dscr_sse(spr_pf_spr_dscr_sse),
   .spr_dscr_dpfd(spr_pf_spr_dscr_dpfd),
   .spr_eplc_wr(spr_derat_eplc_wr),
   .spr_epsc_wr(spr_derat_epsc_wr),
   .spr_eplc_epr(spr_derat_eplc_epr),
   .spr_eplc_eas(spr_derat_eplc_eas),
   .spr_eplc_egs(spr_derat_eplc_egs),
   .spr_eplc_elpid(spr_derat_eplc_elpid),
   .spr_eplc_epid(spr_derat_eplc_epid),
   .spr_epsc_epr(spr_derat_epsc_epr),
   .spr_epsc_eas(spr_derat_epsc_eas),
   .spr_epsc_egs(spr_derat_epsc_egs),
   .spr_epsc_elpid(spr_derat_epsc_elpid),
   .spr_epsc_epid(spr_derat_epsc_epid),
   .spr_hacop_ct(spr_dcc_spr_hacop_ct),

   // Power
   .vdd(vdd),
   .gnd(gnd)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DIRECTORY
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_dir #(.WAYDATASIZE(WAYDATASIZE), .PARBITS(PARBITS)) dir(

   // ACT's
   .dcc_dir_ex2_stg_act(dcc_dir_ex2_stg_act),
   .dcc_dir_ex3_stg_act(dcc_dir_ex3_stg_act),
   .dcc_dir_ex4_stg_act(dcc_dir_ex4_stg_act),
   .dcc_dir_ex5_stg_act(dcc_dir_ex5_stg_act),
   .dcc_dir_stq1_stg_act(dcc_dir_stq1_stg_act),
   .dcc_dir_stq2_stg_act(dcc_dir_stq2_stg_act),
   .dcc_dir_stq3_stg_act(dcc_dir_stq3_stg_act),
   .dcc_dir_stq4_stg_act(dcc_dir_stq4_stg_act),
   .dcc_dir_stq5_stg_act(dcc_dir_stq5_stg_act),
   .dcc_dir_binv2_ex2_stg_act(dcc_dir_binv2_ex2_stg_act),
   .dcc_dir_binv3_ex3_stg_act(dcc_dir_binv3_ex3_stg_act),
   .dcc_dir_binv4_ex4_stg_act(dcc_dir_binv4_ex4_stg_act),
   .dcc_dir_binv5_ex5_stg_act(dcc_dir_binv5_ex5_stg_act),
   .dcc_dir_binv6_ex6_stg_act(dcc_dir_binv6_ex6_stg_act),

   // AGEN Sources
   .byp_dir_ex2_rs1(byp_dir_ex2_rs1),
   .byp_dir_ex2_rs2(byp_dir_ex2_rs2),
   .dcc_dir_ex2_64bit_agen(dcc_dir_ex2_64bit_agen),

   // Error Inject
   .pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
   .pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
   .pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),
   .pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),

   .dcc_dir_ex2_binv_val(dcc_dir_ex2_binv_val),
   .dcc_dir_ex2_thrd_id(dcc_dir_ex2_thrd_id),
   .dcc_dir_ex3_cache_acc(dcc_dir_ex3_cache_acc),
   .dcc_dir_ex3_pfetch_val(dcc_dir_ex3_pfetch_val),
   .dcc_dir_ex3_lru_upd(dcc_dir_ex3_lru_upd),
   .dcc_dir_ex3_lock_set(dcc_dir_ex3_lock_set),
   .dcc_dir_ex3_th_c(dcc_dir_ex3_th_c),
   .dcc_dir_ex3_watch_set(dcc_dir_ex3_watch_set),
   .dcc_dir_ex3_larx_val(dcc_dir_ex3_larx_val),
   .dcc_dir_ex3_watch_chk(dcc_dir_ex3_watch_chk),
   .dcc_dir_ex3_ddir_acc(dcc_dir_ex3_ddir_acc),
   .dcc_dir_ex4_load_val(dcc_dir_ex4_load_val),
   .dcc_dir_ex4_p_addr(dcc_dir_ex4_p_addr),
   .derat_dir_ex4_wimge_i(derat_dcc_ex4_wimge[1]),
   .dcc_dir_stq6_store_val(dcc_dir_stq6_store_val),

   .dat_ctl_dcarr_perr_way(dat_ctl_dcarr_perr_way),

   .xu_lq_spr_xucr0_wlk(xu_lq_spr_xucr0_wlk),
   .xu_lq_spr_xucr0_dcdis(xu_lq_spr_xucr0_dcdis),
   .xu_lq_spr_xucr0_clfc(xu_lq_spr_xucr0_clfc),
   .xu_lq_spr_xucr0_cls(xu_lq_spr_xucr0_cls),
   .dcc_dir_spr_xucr2_rmt(dcc_dir_spr_xucr2_rmt),
   .dcc_dir_ex2_frc_align16(dcc_dir_ex2_frc_align16),
   .dcc_dir_ex2_frc_align8(dcc_dir_ex2_frc_align8),
   .dcc_dir_ex2_frc_align4(dcc_dir_ex2_frc_align4),
   .dcc_dir_ex2_frc_align2(dcc_dir_ex2_frc_align2),

   // RELOAD/COMMIT Control
   .lsq_ctl_stq1_val(lsq_ctl_stq1_val),
   .lsq_ctl_stq2_blk_req(lsq_ctl_stq2_blk_req),
   .lsq_ctl_stq1_thrd_id(lsq_ctl_stq1_thrd_id),
   .lsq_ctl_rel1_thrd_id(lsq_ctl_rel1_thrd_id),
   .lsq_ctl_stq1_store_val(lsq_ctl_stq1_store_val),
   .lsq_ctl_stq1_ci(lsq_ctl_stq1_ci),
   .lsq_ctl_stq1_lock_clr(lsq_ctl_stq1_lock_clr),
   .lsq_ctl_stq1_watch_clr(lsq_ctl_stq1_watch_clr),
   .lsq_ctl_stq1_l_fld(lsq_ctl_stq1_l_fld),
   .lsq_ctl_stq1_inval(lsq_ctl_stq1_inval),
   .lsq_ctl_stq1_dci_val(lsq_ctl_stq1_dci_val),
   .lsq_ctl_stq1_addr(lsq_ctl_stq1_addr),
   .lsq_ctl_rel1_clr_val(lsq_ctl_rel1_clr_val),
   .lsq_ctl_rel1_set_val(lsq_ctl_rel1_set_val),
   .lsq_ctl_rel1_data_val(lsq_ctl_rel1_data_val),
   .lsq_ctl_rel1_back_inv(lsq_ctl_rel1_back_inv),
   .lsq_ctl_rel1_tag(lsq_ctl_rel1_tag),
   .lsq_ctl_rel1_classid(lsq_ctl_rel1_classid),
   .lsq_ctl_rel1_lock_set(lsq_ctl_rel1_lock_set),
   .lsq_ctl_rel1_watch_set(lsq_ctl_rel1_watch_set),
   .lsq_ctl_rel2_blk_req(lsq_ctl_rel2_blk_req),
   .lsq_ctl_rel2_upd_val(lsq_ctl_rel2_upd_val),
   .lsq_ctl_rel3_l1dump_val(lsq_ctl_rel3_l1dump_val),
   .lsq_ctl_rel3_clr_relq(lsq_ctl_rel3_clr_relq),
   .ctl_lsq_stq4_perr_reject(ctl_lsq_stq4_perr_reject),
   .ctl_dat_stq5_way_perr_inval(ctl_dat_stq5_way_perr_inval),

   // Instruction Flush
   .fgen_ex3_stg_flush(fgen_ex3_stg_flush),
   .fgen_ex4_cp_flush(fgen_ex4_cp_flush),
   .fgen_ex4_stg_flush(fgen_ex4_stg_flush),
   .fgen_ex5_stg_flush(fgen_ex5_stg_flush),

   // Directory Read Interface
   .dir_arr_rd_addr0_01(dir_arr_rd_addr0_01),
   .dir_arr_rd_addr0_23(dir_arr_rd_addr0_23),
   .dir_arr_rd_addr0_45(dir_arr_rd_addr0_45),
   .dir_arr_rd_addr0_67(dir_arr_rd_addr0_67),
   .dir_arr_rd_data0(dir_arr_rd_data0),
   .dir_arr_rd_data1(dir_arr_rd_data1),

   // Directory Write Interface
   .dir_arr_wr_enable(dir_arr_wr_enable_int),
   .dir_arr_wr_way(dir_arr_wr_way_int),
   .dir_arr_wr_addr(dir_arr_wr_addr_int),
   .dir_arr_wr_data(dir_arr_wr_data_int),

   // LQ Pipe Outputs
   .dir_dcc_ex2_eff_addr(dir_dcc_ex2_eff_addr),
   .dir_derat_ex2_eff_addr(dir_derat_ex2_eff_addr),
   .dir_dcc_ex4_hit(dir_dcc_ex4_hit),
   .dir_dcc_ex4_miss(dir_dcc_ex4_miss),
   .ctl_dat_ex4_way_hit(ctl_dat_ex4_way_hit),

   // COMMIT Pipe Hit indicator
   .dir_dcc_stq3_hit(dir_dcc_stq3_hit),

   // CR results
   .dir_dcc_ex5_cr_rslt(dir_dcc_ex5_cr_rslt),

   // Performance Events
   .ctl_perv_dir_perf_events(ctl_perv_dir_perf_events),

   // Data Array Controls
   .dir_dcc_rel3_dcarr_upd(dir_dcc_rel3_dcarr_upd),
   .dir_dec_rel3_dir_wr_val(dir_dec_rel3_dir_wr_val),
   .dir_dec_rel3_dir_wr_addr(dir_dec_rel3_dir_wr_addr),

   .stq4_dcarr_way_en(stq4_dcarr_way_en),

   // SPR status
   .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
   .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
   .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),

   // L1 Directory Contents
   .dir_dcc_ex4_way_tag_a(dir_dcc_ex4_way_tag_a),
   .dir_dcc_ex4_way_tag_b(dir_dcc_ex4_way_tag_b),
   .dir_dcc_ex4_way_tag_c(dir_dcc_ex4_way_tag_c),
   .dir_dcc_ex4_way_tag_d(dir_dcc_ex4_way_tag_d),
   .dir_dcc_ex4_way_tag_e(dir_dcc_ex4_way_tag_e),
   .dir_dcc_ex4_way_tag_f(dir_dcc_ex4_way_tag_f),
   .dir_dcc_ex4_way_tag_g(dir_dcc_ex4_way_tag_g),
   .dir_dcc_ex4_way_tag_h(dir_dcc_ex4_way_tag_h),
   .dir_dcc_ex4_way_par_a(dir_dcc_ex4_way_par_a),
   .dir_dcc_ex4_way_par_b(dir_dcc_ex4_way_par_b),
   .dir_dcc_ex4_way_par_c(dir_dcc_ex4_way_par_c),
   .dir_dcc_ex4_way_par_d(dir_dcc_ex4_way_par_d),
   .dir_dcc_ex4_way_par_e(dir_dcc_ex4_way_par_e),
   .dir_dcc_ex4_way_par_f(dir_dcc_ex4_way_par_f),
   .dir_dcc_ex4_way_par_g(dir_dcc_ex4_way_par_g),
   .dir_dcc_ex4_way_par_h(dir_dcc_ex4_way_par_h),
   .dir_dcc_ex5_way_a_dir(dir_dcc_ex5_way_a_dir),
   .dir_dcc_ex5_way_b_dir(dir_dcc_ex5_way_b_dir),
   .dir_dcc_ex5_way_c_dir(dir_dcc_ex5_way_c_dir),
   .dir_dcc_ex5_way_d_dir(dir_dcc_ex5_way_d_dir),
   .dir_dcc_ex5_way_e_dir(dir_dcc_ex5_way_e_dir),
   .dir_dcc_ex5_way_f_dir(dir_dcc_ex5_way_f_dir),
   .dir_dcc_ex5_way_g_dir(dir_dcc_ex5_way_g_dir),
   .dir_dcc_ex5_way_h_dir(dir_dcc_ex5_way_h_dir),
   .dir_dcc_ex5_dir_lru(dir_dcc_ex5_dir_lru),

   // Reject Cases
   .dir_dcc_ex4_set_rel_coll(dir_dcc_ex4_set_rel_coll),
   .dir_dcc_ex4_byp_restart(dir_dcc_ex4_byp_restart),
   .dir_dcc_ex5_dir_perr_det(dir_dcc_ex5_dir_perr_det),
   .dir_dcc_ex5_dc_perr_det(dir_dcc_ex5_dc_perr_det),
   .dir_dcc_ex5_dir_perr_flush(dir_dcc_ex5_dir_perr_flush),
   .dir_dcc_ex5_dc_perr_flush(dir_dcc_ex5_dc_perr_flush),
   .dir_dcc_ex5_multihit_det(dir_dcc_ex5_multihit_det),
   .dir_dcc_ex5_multihit_flush(dir_dcc_ex5_multihit_flush),
   .dir_dcc_stq4_dir_perr_det(dir_dcc_stq4_dir_perr_det),
   .dir_dcc_stq4_multihit_det(dir_dcc_stq4_multihit_det),
   .dir_dcc_ex5_stp_flush(dir_dcc_ex5_stp_flush),

   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .sg_0(sg_0),
   .func_sl_thold_0_b(func_sl_thold_0_b),
   .func_sl_force(func_sl_force),
   .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   .func_slp_sl_force(func_slp_sl_force),
   .func_nsl_thold_0_b(func_nsl_thold_0_b),
   .func_nsl_force(func_nsl_force),
   .func_slp_nsl_thold_0_b(func_slp_nsl_thold_0_b),
   .func_slp_nsl_force(func_slp_nsl_force),
   .d_mode_dc(d_mode_dc),
   .delay_lclkr_dc(delay_lclkr_dc[5]),
   .mpw1_dc_b(mpw1_dc_b[5]),
   .mpw2_dc_b(mpw2_dc_b),
   .scan_in(dir_func_scan_in),
   .scan_out(func_scan_out_int[3:7])
);
assign dir_func_scan_in[3:7] = {func_scan_in_q[3:6],arr_func_scan_out};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DIRECTORY ARRAYS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
generate
   if (`DC_SIZE == 15 & `CL_SIZE == 6)
   begin : dc32Kdir64B

      // number of addressable register in this array
      // width of the bus to address all ports (2^portadrbus_width >= addressable_ports)
      // bitwidth of ports
      // number of ways
      tri_64x34_8w_1r1w #(.addressable_ports(64), .addressbus_width(6), .port_bitwidth(WAYDATASIZE), .ways(8)) arr(		// 0 = ibm (Umbra), 1 = non-ibm, 2 = ibm (MPG)
         // POWER PINS
         .vcs(vdd),
         .vdd(vdd),
         .gnd(gnd),

         // CLOCK AND CLOCKCONTROL PORTS
         .nclk(nclk),
         .rd_act(dec_dir_ex2_dir_rd_act),
         .wr_act(tiup),
         .sg_0(sg_0),
         .abst_sl_thold_0(abst_slp_sl_thold_0),          // Need to use Sleep THOLDS, This copy is active while in sleep mode
         .ary_nsl_thold_0(ary_slp_nsl_thold_0),          // Need to use Sleep THOLDS, This copy is active while in sleep mode
         .time_sl_thold_0(time_sl_thold_0),
         .repr_sl_thold_0(repr_sl_thold_0),
         .func_sl_force(func_slp_sl_force),             // Need to use Sleep THOLDS, This copy is active while in sleep mode
         .func_sl_thold_0_b(func_slp_sl_thold_0_b),     // Need to use Sleep THOLDS, This copy is active while in sleep mode
         .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
         .ccflush_dc(pc_lq_ccflush_dc),
         .scan_dis_dc_b(an_ac_scan_dis_dc_b),
         .scan_diag_dc(an_ac_scan_diag_dc),
         .g8t_d_mode_dc(g8t_d_mode_dc),
         .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
         .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
         .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
         .d_mode_dc(d_mode_dc),
         .mpw1_dc_b(mpw1_dc_b[5]),
         .mpw2_dc_b(mpw2_dc_b),
         .delay_lclkr_dc(delay_lclkr_dc[5]),

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
         .time_scan_in(time_scan_in_q[0]),
         .repr_scan_in(repr_scan_in_q[0]),
         .func_scan_in(func_scan_in_q[7]),
         .abst_scan_out(abst_scan_out_int[0]),
         .time_scan_out(time_scan_out_int[0]),
         .repr_scan_out(repr_scan_out_int[0]),
         .func_scan_out(arr_func_scan_out),

         // BOLT-ON
         .lcb_bolt_sl_thold_0(bolt_sl_thold_0),
         .pc_bo_enable_2(bo_enable_2),
         .pc_bo_reset(pc_lq_bo_reset),
         .pc_bo_unload(pc_lq_bo_unload),
         .pc_bo_repair(pc_lq_bo_repair),
         .pc_bo_shdata(pc_lq_bo_shdata),
         .pc_bo_select(pc_lq_bo_select),
         .bo_pc_failout(lq_pc_bo_fail),
         .bo_pc_diagloop(lq_pc_bo_diagout),
         .tri_lcb_mpw1_dc_b(mpw1_dc_b[5]),
         .tri_lcb_mpw2_dc_b(mpw2_dc_b),
         .tri_lcb_delay_lclkr_dc(delay_lclkr_dc[5]),
         .tri_lcb_clkoff_dc_b(clkoff_dc_b),
         .tri_lcb_act_dis_dc(tidn),

         // Write Ports
         .write_enable(dir_arr_wr_enable_int),
         .way(dir_arr_wr_way_int),
         .addr_wr(dir_arr_wr_addr_int),
         .data_in(dir_arr_wr_data_int),

         // Read Ports
         .addr_rd_01(dir_arr_rd_addr0_01),
         .addr_rd_23(dir_arr_rd_addr0_23),
         .addr_rd_45(dir_arr_rd_addr0_45),
         .addr_rd_67(dir_arr_rd_addr0_67),
         .data_out(dir_arr_rd_data0)
      );
   end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// D-ERATS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

lq_derat derat(
   // POWER PINS
   .gnd(gnd),
   .vdd(vdd),
   .vcs(vdd),

   // CLOCK and CLOCK CONTROL ports
   .nclk(nclk),
   .pc_xu_init_reset(pc_lq_init_reset),
   .pc_xu_ccflush_dc(pc_lq_ccflush_dc),
   .tc_scan_dis_dc_b(an_ac_scan_dis_dc_b),
   .tc_scan_diag_dc(an_ac_scan_diag_dc),
   .tc_lbist_en_dc(an_ac_lbist_en_dc),
   .an_ac_atpg_en_dc(an_ac_atpg_en_dc),
   .an_ac_grffence_en_dc(an_ac_grffence_en_dc),

   .lcb_d_mode_dc(d_mode_dc),
   .lcb_clkoff_dc_b(clkoff_dc_b),
   .lcb_act_dis_dc(tidn),
   .lcb_mpw1_dc_b(mpw1_dc_b),
   .lcb_mpw2_dc_b(mpw2_dc_b),
   .lcb_delay_lclkr_dc(delay_lclkr_dc),

   .pc_func_sl_thold_2(func_sl_thold_2),
   .pc_func_slp_sl_thold_2(func_slp_sl_thold_2),
   .pc_func_slp_nsl_thold_2(func_slp_nsl_thold_2),
   .pc_cfg_slp_sl_thold_2(cfg_slp_sl_thold_2),
   .pc_regf_slp_sl_thold_2(regf_slp_sl_thold_2),
   .pc_time_sl_thold_2(time_sl_thold_2),
   .pc_sg_2(sg_2),
   .pc_fce_2(fce_2),

   .cam_clkoff_dc_b(cam_clkoff_dc_b),
   .cam_act_dis_dc(cam_act_dis_dc),
   .cam_d_mode_dc(cam_d_mode_dc),
   .cam_delay_lclkr_dc(cam_delay_lclkr_dc),
   .cam_mpw1_dc_b(cam_mpw1_dc_b),
   .cam_mpw2_dc_b(cam_mpw2_dc_b),

   .ac_func_scan_in(func_scan_in_q[8:9]),
   .ac_func_scan_out(func_scan_out_int[8:9]),
   .ac_ccfg_scan_in(spr_derat_cfg_scan),
   .ac_ccfg_scan_out(ccfg_scan_out_int),
   .time_scan_in(time_scan_in_q[1]),
   .time_scan_out(time_scan_out_int[1]),
   .regf_scan_in(regf_scan_in_q),
   .regf_scan_out(regf_scan_out_int),

   // Functional ports
   // lsu pipelined instructions
   .dec_derat_ex1_derat_act(dec_derat_ex1_derat_act),
   // ttypes
   .dec_derat_ex0_val(dec_derat_ex0_val),
   .dec_derat_ex0_is_extload(dec_derat_ex0_is_extload),
   .dec_derat_ex0_is_extstore(dec_derat_ex0_is_extstore),
   .dec_derat_ex1_pfetch_val(dec_derat_ex1_pfetch_val),
   .dec_derat_ex1_is_load(dec_derat_ex1_is_load),
   .dec_derat_ex1_is_store(dec_derat_ex1_is_store),
   .dec_derat_ex1_is_touch(dec_derat_ex1_is_touch),
   .dec_derat_ex1_icbtls_instr(dec_dcc_ex1_icbtls_instr),
   .dec_derat_ex1_icblc_instr(dec_dcc_ex1_icblc_instr),
   .dec_derat_ex1_ra_eq_ea(dec_derat_ex1_ra_eq_ea),
   .dec_derat_ex1_byte_rev(dec_derat_ex1_byte_rev),
   .byp_derat_ex2_req_aborted(byp_ex2_req_aborted),
   .dcc_derat_ex3_strg_noop(dcc_derat_ex3_strg_noop),
   .dcc_derat_ex5_blk_tlb_req(dcc_derat_ex5_blk_tlb_req),
   .dcc_derat_ex6_cplt(dcc_derat_ex6_cplt),
   .dcc_derat_ex6_cplt_itag(dcc_derat_ex6_cplt_itag),

   .dir_derat_ex2_epn_arr(dir_derat_ex2_eff_addr[64 - (2 ** `GPR_WIDTH_ENC):51]),
   .dir_derat_ex2_epn_nonarr(dir_dcc_ex2_eff_addr[64 - (2 ** `GPR_WIDTH_ENC):51]),
   .iu_lq_recirc_val(iu_lq_recirc_val),
   .iu_lq_cp_next_itag(iu_lq_cp_next_itag),
   .lsq_ctl_oldest_tid(lsq_ctl_oldest_tid),
   .lsq_ctl_oldest_itag(lsq_ctl_oldest_itag),
   .dec_derat_ex1_itag(dec_dcc_ex1_itag),
   .derat_dcc_ex4_restart(derat_dcc_ex4_restart),

   // SetHold and ClrHold for itag
   .derat_dcc_ex4_setHold(derat_dcc_ex4_setHold),
   .derat_dcc_clr_hold(derat_dcc_clr_hold),
   .derat_dcc_emq_idle(derat_dcc_emq_idle),

   // ordered instructions
   .xu_lq_act(xu_lq_act),
   .xu_lq_val(xu_lq_val),
   .xu_lq_is_eratre(xu_lq_is_eratre),
   .xu_lq_is_eratwe(xu_lq_is_eratwe),
   .xu_lq_is_eratsx(xu_lq_is_eratsx),
   .xu_lq_is_eratilx(xu_lq_is_eratilx),
   .xu_lq_ws(xu_lq_ws),
   .xu_lq_ra_entry(xu_lq_ra_entry),
   .xu_lq_rs_data(xu_lq_rs_data),
   .lq_xu_ex5_data(lq_xu_ex5_data),
   .lq_xu_ord_par_err(lq_xu_ord_par_err),
   .lq_xu_ord_read_done(lq_xu_ord_read_done),
   .lq_xu_ord_write_done(lq_xu_ord_write_done),

   // context synchronizing event
   .iu_lq_isync(iu_lq_isync),
   .iu_lq_csync(iu_lq_csync),

   // reload from mmu
   .mm_derat_rel_val(mm_lq_rel_val),
   .mm_derat_rel_data(mm_lq_rel_data),
   .mm_derat_rel_emq(mm_lq_rel_emq),
   .mm_lq_itag(mm_lq_itag),
   .mm_lq_tlb_miss(mm_lq_tlb_miss),
   .mm_lq_tlb_inelig(mm_lq_tlb_inelig),
   .mm_lq_pt_fault(mm_lq_pt_fault),
   .mm_lq_lrat_miss(mm_lq_lrat_miss),
   .mm_lq_tlb_multihit(mm_lq_tlb_multihit),
   .mm_lq_tlb_par_err(mm_lq_tlb_par_err),
   .mm_lq_lru_par_err(mm_lq_lru_par_err),

   // D$ snoop
   .lsq_ctl_rv0_binv_val(lsq_ctl_rv0_back_inv),

   // tlbivax or tlbilx snoop
   .mm_lq_snoop_coming(mm_lq_snoop_coming),
   .mm_lq_snoop_val(mm_lq_snoop_val),
   .mm_lq_snoop_attr(mm_lq_snoop_attr),
   .mm_lq_snoop_vpn(mm_lq_snoop_vpn),
   .lq_mm_snoop_ack(lq_mm_snoop_ack),
   .derat_dec_rv1_snoop_addr(derat_dec_rv1_snoop_addr),
   .derat_rv1_snoop_val(derat_rv1_snoop_val),

   // pipeline controls
   .iu_lq_cp_flush(iu_lq_cp_flush),
   .derat_dec_hole_all(derat_dec_hole_all),

   // cam _np1 ports
   .derat_dcc_ex3_e(derat_dcc_ex3_wimge_e),
   .derat_dcc_ex3_itagHit(derat_dcc_ex3_itagHit),

   // cam _np2 ports
   .derat_dcc_ex4_rpn(derat_dcc_ex4_p_addr),
   .derat_dcc_ex4_wimge(derat_dcc_ex4_wimge),
   .derat_dcc_ex4_u(derat_dcc_ex4_usr_bits),
   .derat_dcc_ex4_wlc(derat_dcc_ex4_wlc),
   .derat_dcc_ex4_attr(),
   .derat_dcc_ex4_vf(derat_dcc_ex4_vf),
   .derat_dcc_ex4_miss(derat_dcc_ex4_miss),
   .derat_dcc_ex4_tlb_err(derat_dcc_ex4_tlb_err),
   .derat_dcc_ex4_dsi(derat_dcc_ex4_dsi),
   .derat_dcc_ex4_par_err_det(derat_dcc_ex4_par_err_det),
   .derat_dcc_ex4_par_err_flush(derat_dcc_ex4_par_err_flush),
   .derat_dcc_ex4_multihit_err_det(derat_dcc_ex4_multihit_err_det),
   .derat_dcc_ex4_multihit_err_flush(derat_dcc_ex4_multihit_err_flush),
   .derat_dcc_ex4_noop_touch(derat_dcc_ex4_noop_touch),
   .derat_dcc_ex4_tlb_inelig(derat_dcc_ex4_tlb_inelig),
   .derat_dcc_ex4_pt_fault(derat_dcc_ex4_pt_fault),
   .derat_dcc_ex4_lrat_miss(derat_dcc_ex4_lrat_miss),
   .derat_dcc_ex4_tlb_multihit(derat_dcc_ex4_tlb_multihit),
   .derat_dcc_ex4_tlb_par_err(derat_dcc_ex4_tlb_par_err),
   .derat_dcc_ex4_lru_par_err(derat_dcc_ex4_lru_par_err),

   .derat_fir_par_err(derat_fir_par_err),
   .derat_fir_multihit(derat_fir_multihit),

   // erat reload request to mmu
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
   .lq_mm_perf_dtlb(lq_mm_perf_dtlb),

   // write interface to mmucr0,1
   .lq_mm_mmucr0_we(lq_mm_mmucr0_we),
   .lq_mm_mmucr0(lq_mm_mmucr0),
   .lq_mm_mmucr1_we(lq_mm_mmucr1_we),
   .lq_mm_mmucr1(lq_mm_mmucr1),

   // spr's
   .spr_xucr0_clkg_ctl_b1(xu_lq_spr_xucr0_clkg_ctl),

   .xu_lq_spr_msr_hv(xu_lq_spr_msr_gs),
   .xu_lq_spr_msr_pr(xu_lq_spr_msr_pr),
   .xu_lq_spr_msr_ds(xu_lq_spr_msr_ds),
   .xu_lq_spr_msr_cm(xu_lq_spr_msr_cm),
   .xu_lq_spr_ccr2_notlb(xu_lq_spr_ccr2_notlb),
   .xu_lq_spr_ccr2_dfrat(xu_lq_spr_ccr2_dfrat),
   .xu_lq_spr_ccr2_dfratsc(xu_lq_spr_ccr2_dfratsc),
   .xu_lq_spr_xucr4_mmu_mchk(xu_lq_spr_xucr4_mmu_mchk),

   .spr_derat_eplc_wr(spr_derat_eplc_wr),
   .spr_derat_eplc_epr(spr_derat_eplc_epr),
   .spr_derat_eplc_eas(spr_derat_eplc_eas),
   .spr_derat_eplc_egs(spr_derat_eplc_egs),
   .spr_derat_eplc_elpid(spr_derat_eplc_elpid),
   .spr_derat_eplc_epid(spr_derat_eplc_epid),

   .spr_derat_epsc_wr(spr_derat_epsc_wr),
   .spr_derat_epsc_epr(spr_derat_epsc_epr),
   .spr_derat_epsc_eas(spr_derat_epsc_eas),
   .spr_derat_epsc_egs(spr_derat_epsc_egs),
   .spr_derat_epsc_elpid(spr_derat_epsc_elpid),
   .spr_derat_epsc_epid(spr_derat_epsc_epid),

   .mm_lq_pid(mm_lq_pid),
   .mm_lq_mmucr0(mm_lq_mmucr0),
   .mm_lq_mmucr1(mm_lq_mmucr1),

   // debug
   .derat_xu_debug_group0(derat_xu_debug_group0),
   .derat_xu_debug_group1(derat_xu_debug_group1),
   .derat_xu_debug_group2(derat_xu_debug_group2),
   .derat_xu_debug_group3(derat_xu_debug_group3)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// PreFetch
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign ctl_pf_clear_queue = lsq_ctl_sync_done;

generate
   if (`BUILD_PFETCH == 1)
   begin : pf

      // Order Queue Size
      lq_pfetch pfetch(		// number of IAR bits used by prefetch

         //   IU interface to RV for pfetch predictor table0
         // port 0
         .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
         .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
         .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
         .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
         .rv_lq_rv1_i0_ifar(rv_lq_rv1_i0_ifar),

         // port 1
         .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
         .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
         .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
         .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
         .rv_lq_rv1_i1_ifar(rv_lq_rv1_i1_ifar),

         // Zap Machine
         .iu_lq_cp_flush(iu_lq_cp_flush),

         .ctl_pf_clear_queue(ctl_pf_clear_queue),

         // release itag to pfetch
         .odq_pf_report_tid(odq_pf_report_tid),
         .odq_pf_report_itag(odq_pf_report_itag),
         .odq_pf_resolved(odq_pf_resolved),

         // EA of load miss that is valid for pre-fetching
         .dcc_pf_ex5_eff_addr(dcc_pf_ex5_eff_addr),
         .dcc_pf_ex5_req_val_4pf(dcc_pf_ex5_req_val_4pf),
         .dcc_pf_ex5_act(dcc_pf_ex5_act),
         .dcc_pf_ex5_thrd_id(dcc_pf_ex5_thrd_id),
         .dcc_pf_ex5_loadmiss(dcc_pf_ex5_loadmiss),
         .dcc_pf_ex5_itag(dcc_pf_ex5_itag),

         .spr_pf_spr_dscr_lsd(spr_pf_spr_dscr_lsd),
         .spr_pf_spr_dscr_snse(spr_pf_spr_dscr_snse),
         .spr_pf_spr_dscr_sse(spr_pf_spr_dscr_sse),
         .spr_pf_spr_dscr_dpfd(spr_pf_spr_dscr_dpfd),
         .spr_pf_spr_pesr(spr_pf_spr_pesr),

         // EA of prefetch request
         .pf_dec_req_addr(pf_dec_req_addr),
         .pf_dec_req_thrd(pf_dec_req_thrd),
         .pf_dec_req_val(pf_dec_req_val),
         .dec_pf_ack(dec_pf_ack),

         .pf_empty(ctl_lsq_pf_empty),

         // EA of prefetch request
         .pc_lq_inj_prefetcher_parity(pc_lq_inj_prefetcher_parity),
         .lq_pc_err_prefetcher_parity(lq_pc_err_prefetcher_parity),

         // Pervasive
         .vcs(vdd),
         .vdd(vdd),
         .gnd(gnd),
         .nclk(nclk),
         .sg_0(sg_0),
         .func_sl_thold_0_b(func_sl_thold_0_b),
         .func_sl_force(func_sl_force),
         .d_mode_dc(d_mode_dc),
         .delay_lclkr_dc(delay_lclkr_dc[5]),
         .clkoff_dc_b(clkoff_dc_b),
         .mpw1_dc_b(mpw1_dc_b[5]),
         .mpw2_dc_b(mpw2_dc_b),
         .scan_in(spr_pf_func_scan),
         .scan_out(func_scan_out_int[10]),

         // array pervasive
         .abst_sl_thold_0(abst_sl_thold_0),
         .ary_nsl_thold_0(ary_nsl_thold_0),
         .time_sl_thold_0(time_sl_thold_0),
         .repr_sl_thold_0(repr_sl_thold_0),
         .g8t_clkoff_dc_b(g8t_clkoff_dc_b),
         .pc_lq_ccflush_dc(pc_lq_ccflush_dc),
         .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
         .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
         .g8t_d_mode_dc(g8t_d_mode_dc),
         .g8t_mpw1_dc_b(g8t_mpw1_dc_b),
         .g8t_mpw2_dc_b(g8t_mpw2_dc_b),
         .g8t_delay_lclkr_dc(g8t_delay_lclkr_dc),
         // ABIST
         .pc_xu_abist_g8t_wenb_q(pc_lq_abist_g8t_wenb_q),
         .pc_xu_abist_g8t1p_renb_0_q(pc_lq_abist_g8t1p_renb_0_q),
         .pc_xu_abist_di_0_q(pc_lq_abist_di_0_q),
         .pc_xu_abist_g8t_bw_1_q(pc_lq_abist_g8t_bw_1_q),
         .pc_xu_abist_g8t_bw_0_q(pc_lq_abist_g8t_bw_0_q),
         .pc_xu_abist_waddr_0_q(5'b00000),
         .pc_xu_abist_raddr_0_q(5'b00000),
         .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
         .pc_xu_abist_ena_dc(pc_lq_abist_ena_dc),
         .pc_xu_abist_wl64_comp_ena_q(pc_lq_abist_wl64_comp_ena_q),
         .pc_xu_abist_raw_dc_b(pc_lq_abist_raw_dc_b),
         .pc_xu_abist_g8t_dcomp_q(pc_lq_abist_g8t_dcomp_q),
         // Scan
         .abst_scan_in({abst_scan_out_q[1], abst_scan_out_int[2]}),
         .time_scan_in(time_scan_in_q[2]),
         .repr_scan_in(repr_scan_in_q[1]),
         .abst_scan_out({abst_scan_out_int[2], abst_scan_out_int[3]}),
         .time_scan_out(time_scan_out_int[2]),
         .repr_scan_out(repr_scan_out_int[1]),
         // BOLT-ON
         .bolt_sl_thold_0(bolt_sl_thold_0),
         .pc_bo_enable_2(bo_enable_2),		// general bolt-on enable
         .pc_xu_bo_reset(pc_lq_bo_reset),		// reset
         .pc_xu_bo_unload(pc_lq_bo_unload),		// unload sticky bits
         .pc_xu_bo_repair(pc_lq_bo_repair),		// execute sticky bit decode
         .pc_xu_bo_shdata(pc_lq_bo_shdata),		// shift data for timing write and diag loop
         .pc_xu_bo_select(2'b00),		// select for mask and hier writes
         .xu_pc_bo_fail(),		// fail/no-fix reg
         .xu_pc_bo_diagout()
      );
   end
endgenerate

generate
   if (`BUILD_PFETCH == 0) begin : nopf
      assign pf_dec_req_addr = {(63 - `CL_SIZE-64 - (2 ** `GPR_WIDTH_ENC))+1{1'b0}};
      assign pf_dec_req_thrd = {`THREADS{1'b0}};
      assign pf_dec_req_val  = 1'b0;
      assign func_scan_out_int[10] = spr_pf_func_scan;
      assign abst_scan_out_int[2]  = abst_scan_out_q[1];
      assign abst_scan_out_int[3]  = abst_scan_out_int[2];
      assign time_scan_out_int[2]  = time_scan_in_q[2];
      assign repr_scan_out_int[1]  = repr_scan_in_q[1];
   end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// OUTPUTS
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign ctl_dat_ex2_eff_addr = dir_dcc_ex2_eff_addr[52:59];
assign dir_arr_wr_enable = dir_arr_wr_enable_int;
assign dir_arr_wr_way = dir_arr_wr_way_int;
assign dir_arr_wr_addr = dir_arr_wr_addr_int;
assign dir_arr_wr_data = dir_arr_wr_data_int;
assign ctl_spr_dbcr2_dvc1be = spr_dbcr2_dvc1be;
assign ctl_spr_dbcr2_dvc2be = spr_dbcr2_dvc2be;
assign ctl_spr_dbcr2_dvc1m = spr_dbcr2_dvc1m;
assign ctl_spr_dbcr2_dvc2m = spr_dbcr2_dvc2m;
assign ctl_spr_dvc1_dbg = spr_dvc1_dbg;
assign ctl_spr_dvc2_dbg = spr_dvc2_dbg;
assign spr_lesr1 = {spr_lesr1_muxseleb0, spr_lesr1_muxseleb1, spr_lesr1_muxseleb2, spr_lesr1_muxseleb3};
assign spr_lesr2 = {spr_lesr2_muxseleb4, spr_lesr2_muxseleb5, spr_lesr2_muxseleb6, spr_lesr2_muxseleb7};

assign spr_dcc_spr_lesr   = {spr_lesr1, spr_lesr2};
assign ctl_perv_spr_lesr1 = spr_lesr1;
assign ctl_perv_spr_lesr2 = spr_lesr2;

// SCAN OUT Gate
assign abst_scan_out = abst_scan_out_q[2] & an_ac_scan_dis_dc_b;
assign time_scan_out = time_scan_out_q & an_ac_scan_dis_dc_b;
assign repr_scan_out = repr_scan_out_q & an_ac_scan_dis_dc_b;
assign func_scan_out = func_scan_out_q & {11{an_ac_scan_dis_dc_b}};
assign regf_scan_out = regf_scan_out_q & {7{an_ac_scan_dis_dc_b}};
assign ccfg_scan_out = ccfg_scan_out_int & an_ac_scan_dis_dc_b;

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
   .delay_lclkr(delay_lclkr_dc[5]),
   .mpw1_b(mpw1_dc_b[5]),
   .mpw2_b(mpw2_dc_b),
   .d_mode(d_mode_dc),
   .scin(abist_siv[0:24]),
   .scout(abist_sov[0:24]),
   .din({pc_lq_abist_wl64_comp_ena,
         pc_lq_abist_g8t_wenb,
         pc_lq_abist_g8t1p_renb_0,
         pc_lq_abist_di_0,
         pc_lq_abist_g8t_dcomp,
         pc_lq_abist_g8t_bw_1,
         pc_lq_abist_g8t_bw_0,
         pc_lq_abist_raddr_0,
         pc_lq_abist_waddr_0}),
   .dout({pc_lq_abist_wl64_comp_ena_q,
          pc_lq_abist_g8t_wenb_q,
          pc_lq_abist_g8t1p_renb_0_q,
          pc_lq_abist_di_0_q,
          pc_lq_abist_g8t_dcomp_q,
          pc_lq_abist_g8t_bw_1_q,
          pc_lq_abist_g8t_bw_0_q,
          pc_lq_abist_raddr_0_q,
          pc_lq_abist_waddr_0_q})
);

//-----------------------------------------------
// Pervasive
//-----------------------------------------------

tri_plat #(.WIDTH(15)) perv_2to1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({func_nsl_thold_2,
         func_sl_thold_2,
         func_slp_sl_thold_2,
         func_slp_nsl_thold_2,
         regf_slp_sl_thold_2,
         ary_nsl_thold_2,
         ary_slp_nsl_thold_2,
         abst_sl_thold_2,
         abst_slp_sl_thold_2,
         time_sl_thold_2,
         repr_sl_thold_2,
         bolt_sl_thold_2,
         sg_2,
         fce_2,
         cfg_sl_thold_2}),
   .q({func_nsl_thold_1,
       func_sl_thold_1,
       func_slp_sl_thold_1,
       func_slp_nsl_thold_1,
       regf_slp_sl_thold_1,
       ary_nsl_thold_1,
       ary_slp_nsl_thold_1,
       abst_sl_thold_1,
       abst_slp_sl_thold_1,
       time_sl_thold_1,
       repr_sl_thold_1,
       bolt_sl_thold_1,
       sg_1,
       fce_1,
       cfg_sl_thold_1})
);

tri_plat #(.WIDTH(15)) perv_1to0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(pc_lq_ccflush_dc),
   .din({func_nsl_thold_1,
         func_sl_thold_1,
         func_slp_sl_thold_1,
         func_slp_nsl_thold_1,
         regf_slp_sl_thold_1,
         ary_nsl_thold_1,
         ary_slp_nsl_thold_1,
         abst_sl_thold_1,
         abst_slp_sl_thold_1,
         time_sl_thold_1,
         repr_sl_thold_1,
         bolt_sl_thold_1,
         sg_1,
         fce_1,
         cfg_sl_thold_1}),
   .q({func_nsl_thold_0,
       func_sl_thold_0,
       func_slp_sl_thold_0,
       func_slp_nsl_thold_0,
       regf_slp_sl_thold_0,
       ary_nsl_thold_0,
       ary_slp_nsl_thold_0,
       abst_sl_thold_0,
       abst_slp_sl_thold_0,
       time_sl_thold_0,
       repr_sl_thold_0,
       bolt_sl_thold_0,
       sg_0,
       fce_0,
       cfg_sl_thold_0})
);


tri_lcbor perv_lcbor_func_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(func_sl_force),
   .thold_b(func_sl_thold_0_b)
);


tri_lcbor perv_lcbor_func_slp_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_slp_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(func_slp_sl_force),
   .thold_b(func_slp_sl_thold_0_b)
);


tri_lcbor perv_lcbor_func_nsl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_nsl_thold_0),
   .sg(fce_0),
   .act_dis(tidn),
   .force_t(func_nsl_force),
   .thold_b(func_nsl_thold_0_b)
);


tri_lcbor perv_lcbor_func_slp_nsl(
   .clkoff_b(clkoff_dc_b),
   .thold(func_slp_nsl_thold_0),
   .sg(fce_0),
   .act_dis(tidn),
   .force_t(func_slp_nsl_force),
   .thold_b(func_slp_nsl_thold_0_b)
);


tri_lcbor perv_lcbor_abst_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(abst_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(abst_sl_force),
   .thold_b(abst_sl_thold_0_b)
);


tri_lcbor perv_lcbor_cfg_sl(
   .clkoff_b(clkoff_dc_b),
   .thold(cfg_sl_thold_0),
   .sg(sg_0),
   .act_dis(tidn),
   .force_t(cfg_sl_force),
   .thold_b(cfg_sl_thold_0_b)
);

// LCBs for scan only staging latches
assign slat_force = sg_0;
assign abst_slat_thold_b = (~abst_sl_thold_0);
assign time_slat_thold_b = (~time_sl_thold_0);
assign repr_slat_thold_b = (~repr_sl_thold_0);
assign func_slat_thold_b = (~func_sl_thold_0);
assign regf_slat_thold_b = (~regf_slp_sl_thold_0);


tri_lcbs perv_lcbs_abst(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc[5]),
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
             abst_scan_out_int[3]}),
   .scan_out({abst_scan_in_q,
              abst_scan_out_q[0],
              abst_scan_out_q[1],
              abst_scan_out_q[2]}),
   .q(abst_scan_q),
   .q_b(abst_scan_q_b)
);

tri_lcbs perv_lcbs_time(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc[5]),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(time_slat_thold_b),
   .dclk(time_slat_d2clk),
   .lclk(time_slat_lclk)
);


tri_slat_scan #(.WIDTH(4), .INIT(4'b0000)) perv_time_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(time_slat_d2clk),
   .lclk(time_slat_lclk),
   .scan_in({time_scan_in,
             time_scan_out_int[0],
             time_scan_out_int[1],
             time_scan_out_int[2]}),
   .scan_out({time_scan_in_q[0],
              time_scan_in_q[1],
              time_scan_in_q[2],
              time_scan_out_q}),
   .q(time_scan_q),
   .q_b(time_scan_q_b)
);

tri_lcbs perv_lcbs_repr(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc[5]),
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
   .scan_out({repr_scan_in_q[0],
              repr_scan_in_q[1],
              repr_scan_out_q}),
   .q(repr_scan_q),
   .q_b(repr_scan_q_b)
);

tri_lcbs perv_lcbs_func(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc[5]),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(func_slat_thold_b),
   .dclk(func_slat_d2clk),
   .lclk(func_slat_lclk)
);

tri_slat_scan #(.WIDTH(22), .INIT(22'b0000000000000000000000)) perv_func_stg(
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
             func_scan_in[7],
             func_scan_in[8],
             func_scan_in[9],
             func_scan_in[10],
             func_scan_out_int[0],
             func_scan_out_int[1],
             func_scan_out_int[2],
             func_scan_out_int[3],
             func_scan_out_int[4],
             func_scan_out_int[5],
             func_scan_out_int[6],
             func_scan_out_int[7],
             func_scan_out_int[8],
             func_scan_out_int[9],
             func_scan_out_int[10]}),
   .scan_out({func_scan_in_q[0],
              func_scan_in_q[1],
              func_scan_in_q[2],
              func_scan_in_q[3],
              func_scan_in_q[4],
              func_scan_in_q[5],
              func_scan_in_q[6],
              func_scan_in_q[7],
              func_scan_in_q[8],
              func_scan_in_q[9],
              func_scan_in_q[10],
              func_scan_out_q[0],
              func_scan_out_q[1],
              func_scan_out_q[2],
              func_scan_out_q[3],
              func_scan_out_q[4],
              func_scan_out_q[5],
              func_scan_out_q[6],
              func_scan_out_q[7],
              func_scan_out_q[8],
              func_scan_out_q[9],
              func_scan_out_q[10]}),
   .q(func_scan_q),
   .q_b(func_scan_q_b)
);

tri_lcbs perv_lcbs_regf(
   .vd(vdd),
   .gd(gnd),
   .delay_lclkr(delay_lclkr_dc[5]),
   .nclk(nclk),
   .force_t(slat_force),
   .thold_b(regf_slat_thold_b),
   .dclk(regf_slat_d2clk),
   .lclk(regf_slat_lclk)
);


tri_slat_scan #(.WIDTH(14), .INIT(14'b00000000000000)) perv_regf_stg(
   .vd(vdd),
   .gd(gnd),
   .dclk(regf_slat_d2clk),
   .lclk(regf_slat_lclk),
   .scan_in({regf_scan_out_int, regf_scan_in}),
   .scan_out({regf_scan_out_q, regf_scan_in_q}),
   .q(regf_scan_q),
   .q_b(regf_scan_q_b)
);

assign abist_siv = {abist_sov[1:24], abst_scan_out_q[0]};
assign abst_scan_out_int[1] = abist_sov[0];

endmodule
