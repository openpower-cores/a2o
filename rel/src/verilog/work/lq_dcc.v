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

//  Description:  XU LSU L1 Data Cache Control
//
//*****************************************************************************

`include "tri_a2o.vh"



module lq_dcc(
   rv_lq_rv1_i0_vld,
   rv_lq_rv1_i0_ucode_preissue,
   rv_lq_rv1_i0_2ucode,
   rv_lq_rv1_i0_ucode_cnt,
   rv_lq_rv1_i1_vld,
   rv_lq_rv1_i1_ucode_preissue,
   rv_lq_rv1_i1_2ucode,
   rv_lq_rv1_i1_ucode_cnt,
   dec_dcc_ex0_act,
   dec_dcc_ex1_cmd_act,
   dec_dcc_ex1_ucode_val,
   dec_dcc_ex1_ucode_cnt,
   dec_dcc_ex1_ucode_op,
   dec_dcc_ex1_sfx_val,
   dec_dcc_ex1_axu_op_val,
   dec_dcc_ex1_axu_falign,
   dec_dcc_ex1_axu_fexcpt,
   dec_dcc_ex1_axu_instr_type,
   dec_dcc_ex1_cache_acc,
   dec_dcc_ex1_thrd_id,
   dec_dcc_ex1_instr,
   dec_dcc_ex1_optype1,
   dec_dcc_ex1_optype2,
   dec_dcc_ex1_optype4,
   dec_dcc_ex1_optype8,
   dec_dcc_ex1_optype16,
   dec_dcc_ex1_target_gpr,
   dec_dcc_ex1_mtspr_trace,
   dec_dcc_ex1_load_instr,
   dec_dcc_ex1_store_instr,
   dec_dcc_ex1_dcbf_instr,
   dec_dcc_ex1_sync_instr,
   dec_dcc_ex1_l_fld,
   dec_dcc_ex1_dcbi_instr,
   dec_dcc_ex1_dcbz_instr,
   dec_dcc_ex1_dcbt_instr,
   dec_dcc_ex1_pfetch_val,
   dec_dcc_ex1_dcbtst_instr,
   dec_dcc_ex1_th_fld,
   dec_dcc_ex1_dcbtls_instr,
   dec_dcc_ex1_dcbtstls_instr,
   dec_dcc_ex1_dcblc_instr,
   dec_dcc_ex1_dcbst_instr,
   dec_dcc_ex1_icbi_instr,
   dec_dcc_ex1_icblc_instr,
   dec_dcc_ex1_icbt_instr,
   dec_dcc_ex1_icbtls_instr,
   dec_dcc_ex1_icswx_instr,
   dec_dcc_ex1_icswxdot_instr,
   dec_dcc_ex1_icswx_epid,
   dec_dcc_ex1_tlbsync_instr,
   dec_dcc_ex1_ldawx_instr,
   dec_dcc_ex1_wclr_instr,
   dec_dcc_ex1_wchk_instr,
   dec_dcc_ex1_resv_instr,
   dec_dcc_ex1_mutex_hint,
   dec_dcc_ex1_mbar_instr,
   dec_dcc_ex1_makeitso_instr,
   dec_dcc_ex1_is_msgsnd,
   dec_dcc_ex1_dci_instr,
   dec_dcc_ex1_ici_instr,
   dec_dcc_ex1_mword_instr,
   dec_dcc_ex1_algebraic,
   dec_dcc_ex1_strg_index,
   dec_dcc_ex1_src_gpr,
   dec_dcc_ex1_src_axu,
   dec_dcc_ex1_src_dp,
   dec_dcc_ex1_targ_gpr,
   dec_dcc_ex1_targ_axu,
   dec_dcc_ex1_targ_dp,
   dec_dcc_ex1_upd_form,
   dec_dcc_ex1_itag,
   dec_dcc_ex1_cr_fld,
   dec_dcc_ex1_expt_det,
   dec_dcc_ex1_priv_prog,
   dec_dcc_ex1_hypv_prog,
   dec_dcc_ex1_illeg_prog,
   dec_dcc_ex1_dlock_excp,
   dec_dcc_ex1_ilock_excp,
   dec_dcc_ex1_ehpriv_excp,
   dec_dcc_ex2_is_any_load_dac,
   dec_dcc_ex5_req_abort_rpt,
   dec_dcc_ex5_axu_abort_rpt,
   dir_dcc_ex2_eff_addr,
   lsq_ctl_rv0_back_inv,
   derat_rv1_snoop_val,
   dir_dcc_ex4_way_tag_a,
   dir_dcc_ex4_way_tag_b,
   dir_dcc_ex4_way_tag_c,
   dir_dcc_ex4_way_tag_d,
   dir_dcc_ex4_way_tag_e,
   dir_dcc_ex4_way_tag_f,
   dir_dcc_ex4_way_tag_g,
   dir_dcc_ex4_way_tag_h,
   dir_dcc_ex4_way_par_a,
   dir_dcc_ex4_way_par_b,
   dir_dcc_ex4_way_par_c,
   dir_dcc_ex4_way_par_d,
   dir_dcc_ex4_way_par_e,
   dir_dcc_ex4_way_par_f,
   dir_dcc_ex4_way_par_g,
   dir_dcc_ex4_way_par_h,
   dir_dcc_ex5_way_a_dir,
   dir_dcc_ex5_way_b_dir,
   dir_dcc_ex5_way_c_dir,
   dir_dcc_ex5_way_d_dir,
   dir_dcc_ex5_way_e_dir,
   dir_dcc_ex5_way_f_dir,
   dir_dcc_ex5_way_g_dir,
   dir_dcc_ex5_way_h_dir,
   dir_dcc_ex5_dir_lru,
   derat_dcc_ex3_wimge_e,
   derat_dcc_ex3_itagHit,
   derat_dcc_ex4_wimge,
   derat_dcc_ex4_usr_bits,
   derat_dcc_ex4_wlc,
   derat_dcc_ex4_p_addr,
   derat_dcc_ex4_noop_touch,
   derat_dcc_ex4_miss,
   derat_dcc_ex4_tlb_err,
   derat_dcc_ex4_dsi,
   derat_dcc_ex4_vf,
   derat_dcc_ex4_multihit_err_det,
   derat_dcc_ex4_par_err_det,
   derat_dcc_ex4_multihit_err_flush,
   derat_dcc_ex4_par_err_flush,
   derat_dcc_ex4_tlb_inelig,
   derat_dcc_ex4_pt_fault,
   derat_dcc_ex4_lrat_miss,
   derat_dcc_ex4_tlb_multihit,
   derat_dcc_ex4_tlb_par_err,
   derat_dcc_ex4_lru_par_err,
   derat_fir_par_err,
   derat_fir_multihit,
   derat_dcc_ex4_restart,
   derat_dcc_ex4_setHold,
   derat_dcc_clr_hold,
   derat_dcc_emq_idle,
   spr_dcc_ex4_dvc1_en,
   spr_dcc_ex4_dvc2_en,
   spr_dcc_ex4_dacrw1_cmpr,
   spr_dcc_ex4_dacrw2_cmpr,
   spr_dcc_ex4_dacrw3_cmpr,
   spr_dcc_ex4_dacrw4_cmpr,
   spr_dcc_spr_lesr,
   dir_dcc_ex4_hit,
   dir_dcc_ex4_miss,
   dir_dcc_ex4_set_rel_coll,
   dir_dcc_ex4_byp_restart,
   dir_dcc_ex5_dir_perr_det,
   dir_dcc_ex5_dc_perr_det,
   dir_dcc_ex5_dir_perr_flush,
   dir_dcc_ex5_dc_perr_flush,
   dir_dcc_ex5_multihit_det,
   dir_dcc_ex5_multihit_flush,
   dir_dcc_stq4_dir_perr_det,
   dir_dcc_stq4_multihit_det,
   dir_dcc_ex5_stp_flush,
   iu_lq_cp_flush,
   iu_lq_recirc_val,
   iu_lq_cp_next_itag,
   xu_lq_xer_cp_rd,
   fgen_ex1_stg_flush,
   fgen_ex2_stg_flush,
   fgen_ex3_stg_flush,
   fgen_ex4_cp_flush,
   fgen_ex4_stg_flush,
   fgen_ex5_stg_flush,
   dir_dcc_rel3_dcarr_upd,
   xu_lq_spr_ccr2_en_trace,
   xu_lq_spr_ccr2_dfrat,
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
   xu_lq_spr_xucr0_trace_um,
   xu_lq_spr_xucr0_mddp,
   xu_lq_spr_xucr0_mdcp,
   xu_lq_spr_xucr4_mmu_mchk,
   xu_lq_spr_xucr4_mddmh,
   xu_lq_spr_msr_cm,
   xu_lq_spr_msr_fp,
   xu_lq_spr_msr_spv,
   xu_lq_spr_msr_de,
   xu_lq_spr_dbcr0_idm,
   xu_lq_spr_epcr_duvd,
   xu_lq_spr_msr_gs,
   xu_lq_spr_msr_pr,
   xu_lq_spr_msr_ds,
   mm_lq_lsu_lpidr,
   mm_lq_pid,
   lsq_ctl_ex5_ldq_restart,
   lsq_ctl_ex5_stq_restart,
   lsq_ctl_ex5_stq_restart_miss,
   lsq_ctl_ex5_fwd_val,
   lsq_ctl_sync_in_stq,
   lsq_ctl_rv_hold_all,
   lsq_ctl_rv_set_hold,
   lsq_ctl_rv_clr_hold,
   lsq_ctl_stq1_stg_act,
   lsq_ctl_stq1_val,
   lsq_ctl_stq1_thrd_id,
   lsq_ctl_stq1_store_val,
   lsq_ctl_stq1_watch_clr,
   lsq_ctl_stq1_l_fld,
   lsq_ctl_stq1_resv,
   lsq_ctl_stq1_ci,
   lsq_ctl_stq1_axu_val,
   lsq_ctl_stq1_epid_val,
   lsq_ctl_stq1_mftgpr_val,
   lsq_ctl_stq1_mfdpf_val,
   lsq_ctl_stq1_mfdpa_val,
   lsq_ctl_stq2_blk_req,
   lsq_ctl_stq4_xucr0_cul,
   lsq_ctl_stq5_itag,
   lsq_ctl_stq5_tgpr,
   lsq_ctl_rel1_gpr_val,
   lsq_ctl_rel1_ta_gpr,
   lsq_ctl_rel1_upd_gpr,
   lsq_ctl_stq_cpl_ready,
   lsq_ctl_stq_cpl_ready_itag,
   lsq_ctl_stq_cpl_ready_tid,
   lsq_ctl_stq_n_flush,
   lsq_ctl_stq_np1_flush,
   lsq_ctl_stq_exception_val,
   lsq_ctl_stq_exception,
   lsq_ctl_stq_dacrw,
   ctl_lsq_stq_cpl_blk,
   lsq_ctl_ex3_strg_val,
   lsq_ctl_ex3_strg_noop,
   lsq_ctl_ex3_illeg_lswx,
   lsq_ctl_ex3_ct_val,
   lsq_ctl_ex3_be_ct,
   lsq_ctl_ex3_le_ct,
   dir_dcc_stq3_hit,
   dir_dcc_ex5_cr_rslt,
   dcc_dir_ex2_frc_align2,
   dcc_dir_ex2_frc_align4,
   dcc_dir_ex2_frc_align8,
   dcc_dir_ex2_frc_align16,
   dcc_dir_ex2_64bit_agen,
   dcc_dir_ex2_thrd_id,
   dcc_derat_ex3_strg_noop,
   dcc_derat_ex5_blk_tlb_req,
   dcc_derat_ex6_cplt,
   dcc_derat_ex6_cplt_itag,
   dcc_dir_ex3_lru_upd,
   dcc_dir_ex3_cache_acc,
   dcc_dir_ex3_pfetch_val,
   dcc_dir_ex3_lock_set,
   dcc_dir_ex3_th_c,
   dcc_dir_ex3_watch_set,
   dcc_dir_ex3_larx_val,
   dcc_dir_ex3_watch_chk,
   dcc_dir_ex3_ddir_acc,
   dcc_dir_ex4_load_val,
   dcc_spr_ex3_data_val,
   dcc_spr_ex3_eff_addr,
   ctl_dat_ex3_opsize,
   ctl_dat_ex3_le_mode,
   ctl_dat_ex3_le_ld_rotsel,
   ctl_dat_ex3_be_ld_rotsel,
   ctl_dat_ex3_algebraic,
   ctl_dat_ex3_le_alg_rotsel,
   dcc_byp_rel2_stg_act,
   dcc_byp_rel3_stg_act,
   dcc_byp_ram_act,
   byp_dcc_ex2_req_aborted,
   dcc_byp_ex4_moveOp_val,
   dcc_byp_stq6_moveOp_val,
   dcc_byp_ex4_move_data,
   dcc_byp_ex5_lq_req_abort,
   dcc_byp_ex5_byte_mask,
   dcc_byp_ex6_thrd_id,
   dcc_byp_ex6_dvc1_en,
   dcc_byp_ex6_dvc2_en,
   dcc_byp_ex6_dacr_cmpr,
   dcc_dir_ex4_p_addr,
   dcc_dir_stq6_store_val,
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
   ctl_lsq_stq3_icswx_data,
   ctl_lsq_dbg_int_en,
   ctl_lsq_ldp_idle,
   ctl_lsq_rv1_dir_rd_val,
   dcc_dec_arr_rd_rv1_val,
   dcc_dec_arr_rd_congr_cl,
   dcc_dec_stq3_mftgpr_val,
   dcc_dec_stq5_mftgpr_val,
   lq_xu_spr_xucr0_cul,
   dcc_dir_spr_xucr2_rmt,
   spr_dcc_spr_xudbg0_exec,
   spr_dcc_spr_xudbg0_tid,
   spr_dcc_spr_xudbg0_way,
   spr_dcc_spr_xudbg0_row,
   dcc_spr_spr_xudbg0_done,
   dcc_spr_spr_xudbg1_valid,
   dcc_spr_spr_xudbg1_watch,
   dcc_spr_spr_xudbg1_parity,
   dcc_spr_spr_xudbg1_lru,
   dcc_spr_spr_xudbg1_lock,
   dcc_spr_spr_xudbg2_tag,
   spr_dcc_spr_xucr2_rmt,
   spr_dcc_spr_lsucr0_clchk,
   spr_dcc_spr_acop_ct,
   spr_dcc_spr_hacop_ct,
   spr_dcc_epsc_epr,
   spr_dcc_epsc_eas,
   spr_dcc_epsc_egs,
   spr_dcc_epsc_elpid,
   spr_dcc_epsc_epid,
   dcc_dir_ex2_binv_val,
   stq4_dcarr_wren,
   dcc_byp_ram_sel,
   dcc_dec_ex5_wren,
   lq_xu_ex5_abort,
   lq_xu_gpr_ex5_wa,
   lq_rv_gpr_ex6_wa,
   lq_xu_axu_rel_we,
   lq_xu_gpr_rel_we,
   lq_xu_gpr_rel_wa,
   lq_rv_gpr_rel_we,
   lq_rv_gpr_rel_wa,
   lq_xu_cr_ex5_we,
   lq_xu_cr_ex5_wa,
   lq_xu_ex5_cr,
   lq_xu_axu_ex4_addr,
   lq_xu_axu_ex5_we,
   lq_xu_axu_ex5_le,
   lq_rv_itag1_vld,
   lq_rv_itag1,
   lq_rv_itag1_restart,
   lq_rv_itag1_abort,
   lq_rv_itag1_hold,
   lq_rv_itag1_cord,
   lq_rv_clr_hold,
   dcc_dec_hold_all,
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
   dcc_pf_ex5_eff_addr,
   dcc_pf_ex5_req_val_4pf,
   dcc_pf_ex5_act,
   dcc_pf_ex5_thrd_id,
   dcc_pf_ex5_loadmiss,
   dcc_pf_ex5_itag,
   lq_pc_err_derat_parity,
   lq_pc_err_dir_ldp_parity,
   lq_pc_err_dir_stp_parity,
   lq_pc_err_dcache_parity,
   lq_pc_err_derat_multihit,
   lq_pc_err_dir_ldp_multihit,
   lq_pc_err_dir_stp_multihit,
   pc_lq_ram_active,
   lq_pc_ram_data_val,
   ctl_perv_ex6_perf_events,
   ctl_perv_stq4_perf_events,
   dcc_dir_ex2_stg_act,
   dcc_dir_ex3_stg_act,
   dcc_dir_ex4_stg_act,
   dcc_dir_ex5_stg_act,
   dcc_dir_stq1_stg_act,
   dcc_dir_stq2_stg_act,
   dcc_dir_stq3_stg_act,
   dcc_dir_stq4_stg_act,
   dcc_dir_stq5_stg_act,
   dcc_dir_binv2_ex2_stg_act,
   dcc_dir_binv3_ex3_stg_act,
   dcc_dir_binv4_ex4_stg_act,
   dcc_dir_binv5_ex5_stg_act,
   dcc_dir_binv6_ex6_stg_act,
   vdd,
   gnd,
   nclk,
   sg_0,
   func_sl_thold_0_b,
   func_sl_force,
   func_nsl_thold_0_b,
   func_nsl_force,
   func_slp_sl_thold_0_b,
   func_slp_sl_force,
   func_slp_nsl_thold_0_b,
   func_slp_nsl_force,
   d_mode_dc,
   delay_lclkr_dc,
   mpw1_dc_b,
   mpw2_dc_b,
   scan_in,
   scan_out
);

//-------------------------------------------------------------------
// Generics
//-------------------------------------------------------------------
//parameter                                               ITAG_SIZE_ENC = 7;		// Instruction Tag Size
//parameter                                               CR_POOL_ENC = 5;		// Encode of CR rename pool size
//parameter                                               GPR_POOL_ENC = 6;
//parameter                                               THREADS_POOL_ENC = 1;
//parameter                                               UCODE_ENTRIES_ENC = 3;
//parameter                                               REAL_IFAR_WIDTH = 42;		// 42 bit real address
//parameter                                               DC_SIZE = 15;			// 2^15 = 32768 Bytes L1 D$
//parameter                                               AXU_SPARE_ENC = 3;
//parameter                                               GPR_WIDTH_ENC = 6;		// 5 = 32bit mode, 6 = 64bit mode
//parameter                                               `CR_WIDTH = 4;
parameter                                               PARBITS = 4;			// Number of Parity Bits

// IU Dispatch
input [0:`THREADS-1]                                    rv_lq_rv1_i0_vld;
input                                                   rv_lq_rv1_i0_ucode_preissue;
input                                                   rv_lq_rv1_i0_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]                          rv_lq_rv1_i0_ucode_cnt;
input [0:`THREADS-1]                                    rv_lq_rv1_i1_vld;
input                                                   rv_lq_rv1_i1_ucode_preissue;
input                                                   rv_lq_rv1_i1_2ucode;
input [0:`UCODE_ENTRIES_ENC-1]                          rv_lq_rv1_i1_ucode_cnt;

// Execution Pipe Inputs
input                                                   dec_dcc_ex0_act;		// ACT
input                                                   dec_dcc_ex1_cmd_act;		// ACT
input                                                   dec_dcc_ex1_ucode_val;		// PreIssue of Ucode operation is valid
input [0:`UCODE_ENTRIES_ENC-1]                          dec_dcc_ex1_ucode_cnt;
input                                                   dec_dcc_ex1_ucode_op;
input                                                   dec_dcc_ex1_sfx_val;		// Simple FXU operation is valid
input                                                   dec_dcc_ex1_axu_op_val;		// Operation is from the AXU
input                                                   dec_dcc_ex1_axu_falign;		// AXU force alignment indicator
input                                                   dec_dcc_ex1_axu_fexcpt;		// AXU force alignment exception on misaligned access
input [0:2]                                             dec_dcc_ex1_axu_instr_type;
input                                                   dec_dcc_ex1_cache_acc;		// Cache Access is Valid, Op that touches directory
input [0:`THREADS-1]                                    dec_dcc_ex1_thrd_id;
input [0:31]                                            dec_dcc_ex1_instr;
input                                                   dec_dcc_ex1_optype1;		// 1 Byte Load/Store
input                                                   dec_dcc_ex1_optype2;		// 2 Byte Load/Store
input                                                   dec_dcc_ex1_optype4;		// 4 Byte Load/Store
input                                                   dec_dcc_ex1_optype8;		// 8 Byte Load/Store
input                                                   dec_dcc_ex1_optype16;		// 16 Byte Load/Store
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  dec_dcc_ex1_target_gpr;	// Target GPR, needed for reloads
input                                                   dec_dcc_ex1_mtspr_trace;	// Operation is a mtspr trace instruction
input                                                   dec_dcc_ex1_load_instr;		// Operation is a Load instruction
input                                                   dec_dcc_ex1_store_instr;	// Operation is a Store instruction
input                                                   dec_dcc_ex1_dcbf_instr;		// Operation is a DCBF instruction
input                                                   dec_dcc_ex1_sync_instr;		// Operation is a SYNC instruction
input [0:1]                                             dec_dcc_ex1_l_fld;		// DCBF/SYNC L Field
input                                                   dec_dcc_ex1_dcbi_instr;		// Operation is a DCBI instruction
input                                                   dec_dcc_ex1_dcbz_instr;		// Operation is a DCBZ instruction
input                                                   dec_dcc_ex1_dcbt_instr;		// Operation is a DCBT instruction
input                                                   dec_dcc_ex1_pfetch_val;		// Operation is a prefetch
input                                                   dec_dcc_ex1_dcbtst_instr;	// Operation is a DCBTST instruction
input [0:4]                                             dec_dcc_ex1_th_fld;		// TH/CT Field for Cache Management instructions
input                                                   dec_dcc_ex1_dcbtls_instr;
input                                                   dec_dcc_ex1_dcbtstls_instr;
input                                                   dec_dcc_ex1_dcblc_instr;
input                                                   dec_dcc_ex1_dcbst_instr;
input                                                   dec_dcc_ex1_icbi_instr;
input                                                   dec_dcc_ex1_icblc_instr;
input                                                   dec_dcc_ex1_icbt_instr;
input                                                   dec_dcc_ex1_icbtls_instr;
input                                                   dec_dcc_ex1_icswx_instr;
input                                                   dec_dcc_ex1_icswxdot_instr;
input                                                   dec_dcc_ex1_icswx_epid;
input                                                   dec_dcc_ex1_tlbsync_instr;
input                                                   dec_dcc_ex1_ldawx_instr;
input                                                   dec_dcc_ex1_wclr_instr;
input                                                   dec_dcc_ex1_wchk_instr;
input                                                   dec_dcc_ex1_resv_instr;		// Operation is a resv instruction
input                                                   dec_dcc_ex1_mutex_hint;		// Mutex Hint For larx instructions
input                                                   dec_dcc_ex1_mbar_instr;		// Operation is an MBAR instruction
input                                                   dec_dcc_ex1_makeitso_instr;
input                                                   dec_dcc_ex1_is_msgsnd;
input                                                   dec_dcc_ex1_dci_instr;
input                                                   dec_dcc_ex1_ici_instr;
input                                                   dec_dcc_ex1_mword_instr;	// load/store multiple word instruction
input                                                   dec_dcc_ex1_algebraic;		// Operation is an Algebraic Load instruction
input                                                   dec_dcc_ex1_strg_index;		// String Indexed Form
input                                                   dec_dcc_ex1_src_gpr;		// Source is the GPR's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_src_axu;		// Source is the AXU's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_src_dp;		// Source is the BOX's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_targ_gpr;		// Target is the GPR's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_targ_axu;		// Target is the AXU's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_targ_dp;		// Target is the BOX's for mfloat and mDCR ops
input                                                   dec_dcc_ex1_upd_form;
input [0:`ITAG_SIZE_ENC-1]                              dec_dcc_ex1_itag;
input [0:`CR_POOL_ENC-1]                                dec_dcc_ex1_cr_fld;
input                                                   dec_dcc_ex1_expt_det;
input                                                   dec_dcc_ex1_priv_prog;
input                                                   dec_dcc_ex1_hypv_prog;
input                                                   dec_dcc_ex1_illeg_prog;
input                                                   dec_dcc_ex1_dlock_excp;
input                                                   dec_dcc_ex1_ilock_excp;
input                                                   dec_dcc_ex1_ehpriv_excp;
input                                                   dec_dcc_ex2_is_any_load_dac;
input                                                   dec_dcc_ex5_req_abort_rpt;
input                                                   dec_dcc_ex5_axu_abort_rpt;
input [64-(2**`GPR_WIDTH_ENC):63]                       dir_dcc_ex2_eff_addr;

// Directory Back-Invalidate
input                                                   lsq_ctl_rv0_back_inv;		// L2 Back-Invalidate is Valid

// Derat Snoop-Invalidate
input                                                   derat_rv1_snoop_val;

// Directory Read Operation
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_a;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_b;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_c;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_d;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_e;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_f;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_g;
input [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]             dir_dcc_ex4_way_tag_h;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_a;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_b;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_c;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_d;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_e;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_f;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_g;
input [0:PARBITS-1]                                     dir_dcc_ex4_way_par_h;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_a_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_b_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_c_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_d_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_e_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_f_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_g_dir;
input [0:1+`THREADS]                                    dir_dcc_ex5_way_h_dir;
input [0:6]                                             dir_dcc_ex5_dir_lru;

input                                                   derat_dcc_ex3_wimge_e;
input                                                   derat_dcc_ex3_itagHit;
input [0:4]                                             derat_dcc_ex4_wimge;		// Memory Attribute I Bit from ERAT
input [0:3]                                             derat_dcc_ex4_usr_bits;		// User Defined Bits from ERAT
input [0:1]                                             derat_dcc_ex4_wlc;		    // ClassID
input [64-`REAL_IFAR_WIDTH:51]                          derat_dcc_ex4_p_addr;
input                                                   derat_dcc_ex4_noop_touch;
input                                                   derat_dcc_ex4_miss;
input                                                   derat_dcc_ex4_tlb_err;
input                                                   derat_dcc_ex4_dsi;
input                                                   derat_dcc_ex4_vf;
input                                                   derat_dcc_ex4_multihit_err_det;
input                                                   derat_dcc_ex4_par_err_det;
input                                                   derat_dcc_ex4_multihit_err_flush;
input                                                   derat_dcc_ex4_par_err_flush;
input                                                   derat_dcc_ex4_tlb_inelig;
input                                                   derat_dcc_ex4_pt_fault;
input                                                   derat_dcc_ex4_lrat_miss;
input                                                   derat_dcc_ex4_tlb_multihit;
input                                                   derat_dcc_ex4_tlb_par_err;
input                                                   derat_dcc_ex4_lru_par_err;
input                                                   derat_dcc_ex4_restart;
input							derat_fir_par_err;
input							derat_fir_multihit;

// SetHold and ClrHold for itag
input                                                   derat_dcc_ex4_setHold;
input [0:`THREADS-1]                                    derat_dcc_clr_hold;

// EMQ Idle indicator
input [0:`THREADS-1]                                    derat_dcc_emq_idle;

// DEBUG Address Compare Exception
input                                                   spr_dcc_ex4_dvc1_en;
input                                                   spr_dcc_ex4_dvc2_en;
input                                                   spr_dcc_ex4_dacrw1_cmpr;
input                                                   spr_dcc_ex4_dacrw2_cmpr;
input                                                   spr_dcc_ex4_dacrw3_cmpr;
input                                                   spr_dcc_ex4_dacrw4_cmpr;
input [0:47]                                            spr_dcc_spr_lesr;

input                                                   dir_dcc_ex4_hit;		    // ex4 Load/Store Hit
input                                                   dir_dcc_ex4_miss;		    // ex4 Load/Store Miss
input                                                   dir_dcc_ex4_set_rel_coll;	// Resource Conflict, should cause a reject
input                                                   dir_dcc_ex4_byp_restart;	// Directory Bypassed stage that was restarted
input                                                   dir_dcc_ex5_dir_perr_det;	// Data Directory Parity Error Detected
input                                                   dir_dcc_ex5_dc_perr_det;	// Data Cache Parity Error Detected
input                                                   dir_dcc_ex5_dir_perr_flush;	// Data Directory Parity Error Flush
input                                                   dir_dcc_ex5_dc_perr_flush;	// Data Cache Parity Error Flush
input                                                   dir_dcc_ex5_multihit_det;	// Directory Multihit Detected
input                                                   dir_dcc_ex5_multihit_flush;	// Directory Multihit Flush
input                                                   dir_dcc_stq4_dir_perr_det;	// Data Cache Parity Error Detected on the STQ Commit Pipeline
input                                                   dir_dcc_stq4_multihit_det;	// Directory Multihit Detected on the STQ Commit Pipeline
input                                                   dir_dcc_ex5_stp_flush;      // Directory Error detected on the STQ Commit Pipeline with EX5 LDP valid

// Completion Inputs
input [0:`THREADS-1]                                    iu_lq_cp_flush;			// Completion Flush Report
input [0:`THREADS-1]                                    iu_lq_recirc_val;		// Next Itag Completion Report
input [0:`THREADS*`ITAG_SIZE_ENC-1]                     iu_lq_cp_next_itag;		// Next Itag Completion Itag

// XER[SO] Read for CP_NEXT instructions (stcx./icswx./ldawx.)
input [0:`THREADS-1]                                    xu_lq_xer_cp_rd;

// Stage Flush
output                                                  fgen_ex1_stg_flush;		// ex1 Stage Flush
output                                                  fgen_ex2_stg_flush;		// ex2 Stage Flush
output                                                  fgen_ex3_stg_flush;		// ex3 Stage Flush
output                                                  fgen_ex4_cp_flush;      // ex4 CP Flush
output                                                  fgen_ex4_stg_flush;		// ex4 Stage Flush
output                                                  fgen_ex5_stg_flush;		// ex5 Stage Flush

input                                                   dir_dcc_rel3_dcarr_upd;		// Reload Data Array Update Valid

// Data Cache Config
input                                                   xu_lq_spr_ccr2_en_trace;	// MTSPR Trace is Enabled
input                                                   xu_lq_spr_ccr2_dfrat;		// Force Real Address Translation
input                                                   xu_lq_spr_ccr2_ap;		// AP Available
input                                                   xu_lq_spr_ccr2_ucode_dis;	// Ucode Disabled
input                                                   xu_lq_spr_ccr2_notlb;		// MMU is disabled
input                                                   xu_lq_spr_xucr0_clkg_ctl;	// Clock Gating Override
input                                                   xu_lq_spr_xucr0_wlk;		// Data Cache Way Locking Enable
input                                                   xu_lq_spr_xucr0_mbar_ack;	// L2 ACK of membar and lwsync
input                                                   xu_lq_spr_xucr0_tlbsync;	// L2 ACK of tlbsync
input                                                   xu_lq_spr_xucr0_dcdis;		// Data Cache Disable
input                                                   xu_lq_spr_xucr0_aflsta;		// AXU Force Load/Store Alignment interrupt
input                                                   xu_lq_spr_xucr0_flsta;		// FX Force Load/Store Alignment interrupt
input [0:`THREADS-1]                                    xu_lq_spr_xucr0_trace_um;	// TRACE SPR is Enabled in user mode
input                                                   xu_lq_spr_xucr0_mddp;		// Machine Check on Data Cache Directory Parity Error
input                                                   xu_lq_spr_xucr0_mdcp;		// Machine Check on Data Cache Parity Error
input                                                   xu_lq_spr_xucr4_mmu_mchk;	// Machine Check on a Data ERAT Parity or Multihit Error
input                                                   xu_lq_spr_xucr4_mddmh;		// Machine Check on Data Cache Directory Multihit Error

input [0:`THREADS-1]                                    xu_lq_spr_msr_cm;		// 64bit mode enable
input [0:`THREADS-1]                                    xu_lq_spr_msr_fp;		// FP Available
input [0:`THREADS-1]                                    xu_lq_spr_msr_spv;		// VEC Available
input [0:`THREADS-1]                                    xu_lq_spr_msr_de;		// Debug Interrupt Enable
input [0:`THREADS-1]                                    xu_lq_spr_dbcr0_idm;		// Internal Debug Mode Enable
input [0:`THREADS-1]                                    xu_lq_spr_epcr_duvd;		// Disable Hypervisor Debug

// MSR[GS,PR] bits, indicates which state we are running in
input [0:`THREADS-1]                                    xu_lq_spr_msr_gs;		// (MSR.GS)
input [0:`THREADS-1]                                    xu_lq_spr_msr_pr;		// Problem State (MSR.PR)
input [0:`THREADS-1]                                    xu_lq_spr_msr_ds;		// Data Address Space (MSR.DS)
input [0:7]                                             mm_lq_lsu_lpidr;		// the LPIDR register
input [0:14*`THREADS-1]                                 mm_lq_pid;

// RESTART indicator
input                                                   lsq_ctl_ex5_ldq_restart;	// Loadmiss Queue Report
input                                                   lsq_ctl_ex5_stq_restart;	// Store Queue Report
input                                                   lsq_ctl_ex5_stq_restart_miss;

// Store Data Forward
input                                                   lsq_ctl_ex5_fwd_val;

input                                                   lsq_ctl_sync_in_stq;

// Hold RV Indicator
input                                                   lsq_ctl_rv_hold_all;

// Reservation station set barrier indicator
input                                                   lsq_ctl_rv_set_hold;
input [0:`THREADS-1]                                    lsq_ctl_rv_clr_hold;

// Reload/Commit Pipe
input                                                   lsq_ctl_stq1_stg_act;
input                                                   lsq_ctl_stq1_val;
input [0:`THREADS-1]                                    lsq_ctl_stq1_thrd_id;
input                                                   lsq_ctl_stq1_store_val;		// Store Commit instruction
input                                                   lsq_ctl_stq1_watch_clr;	    // Recirc Watch Clear instruction
input [0:1]                                             lsq_ctl_stq1_l_fld;		    // Recirc Watch Clear L-Field
input                                                   lsq_ctl_stq1_resv;
input                                                   lsq_ctl_stq1_ci;
input                                                   lsq_ctl_stq1_axu_val;		// Reload is for a Vector Register
input                                                   lsq_ctl_stq1_epid_val;
input                                                   lsq_ctl_stq1_mftgpr_val;	// MFTGPR instruction Valid
input                                                   lsq_ctl_stq1_mfdpf_val;		// MFDP to the Fixed Point Unit instruction Valid
input                                                   lsq_ctl_stq1_mfdpa_val;		// MFDP to the Auxilary Unit instruction Valid
input                                                   lsq_ctl_stq2_blk_req;		// Block Store due to RV issue
input                                                   lsq_ctl_stq4_xucr0_cul;
input [0:`ITAG_SIZE_ENC-1]                              lsq_ctl_stq5_itag;
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lsq_ctl_stq5_tgpr;
input                                                   lsq_ctl_rel1_gpr_val;
input [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1]  lsq_ctl_rel1_ta_gpr;
input                                                   lsq_ctl_rel1_upd_gpr;		// Reload data should be written to GPR (DCB ops don't write to GPRs)

// Store Queue Completion Report
input                                                   lsq_ctl_stq_cpl_ready;
input [0:`ITAG_SIZE_ENC-1]                              lsq_ctl_stq_cpl_ready_itag;
input [0:`THREADS-1]                                    lsq_ctl_stq_cpl_ready_tid;
input                                                   lsq_ctl_stq_n_flush;
input                                                   lsq_ctl_stq_np1_flush;
input                                                   lsq_ctl_stq_exception_val;
input [0:5]                                             lsq_ctl_stq_exception;
input [0:3]                                             lsq_ctl_stq_dacrw;
output                                                  ctl_lsq_stq_cpl_blk;

// Illegal LSWX has been determined
input                                                   lsq_ctl_ex3_strg_val;		// STQ has checked XER valid
input                                                   lsq_ctl_ex3_strg_noop;		// STQ detected a noop of LSWX/STSWX
input                                                   lsq_ctl_ex3_illeg_lswx;		// STQ detected illegal form of LSWX
input                                                   lsq_ctl_ex3_ct_val;		    // ICSWX Data is valid
input [0:5]                                             lsq_ctl_ex3_be_ct;		    // Big Endian Coprocessor Type Select
input [0:5]                                             lsq_ctl_ex3_le_ct;		    // Little Endian Coprocessor Type Select

// Directory Results Input
input                                                   dir_dcc_stq3_hit;
input                                                   dir_dcc_ex5_cr_rslt;

// EX2 Execution Pipe Outputs
output                                                  dcc_dir_ex2_frc_align2;
output                                                  dcc_dir_ex2_frc_align4;
output                                                  dcc_dir_ex2_frc_align8;
output                                                  dcc_dir_ex2_frc_align16;
output                                                  dcc_dir_ex2_64bit_agen;
output [0:`THREADS-1]                                   dcc_dir_ex2_thrd_id;
output                                                  dcc_derat_ex3_strg_noop;
output                                                  dcc_derat_ex5_blk_tlb_req;	// Higher Priority Interrupt detected, block ERAT miss request from going to MMU
output [0:`THREADS-1]                                   dcc_derat_ex6_cplt;		    // Completion report was sent for EMQ detected interrupts, EMQ entry can be freed
output [0:`ITAG_SIZE_ENC-1]                             dcc_derat_ex6_cplt_itag;	// Completion report ITAG for EMQ detected interrupt

// EX3 Execution Pipe Outputs
output                                                  dcc_dir_ex3_lru_upd;
output                                                  dcc_dir_ex3_cache_acc;		// Cache Access is Valid
output                                                  dcc_dir_ex3_pfetch_val;
output                                                  dcc_dir_ex3_lock_set;		// DCBT[ST]LS Operation is valid
output                                                  dcc_dir_ex3_th_c;		    // DCBT[ST]LS Operation is targeting the L1 Data Cache
output                                                  dcc_dir_ex3_watch_set;		// LDAWX Operation is valid
output                                                  dcc_dir_ex3_larx_val;		// LARX Operation is valid, the directory should be invalidated if hit
output                                                  dcc_dir_ex3_watch_chk;		// WCHK Operation is valid
output                                                  dcc_dir_ex3_ddir_acc;
output                                                  dcc_dir_ex4_load_val;
output                                                  dcc_spr_ex3_data_val;
output [64-(2**`GPR_WIDTH_ENC):63]                      dcc_spr_ex3_eff_addr;

output [0:4]                                            ctl_dat_ex3_opsize;
output                                                  ctl_dat_ex3_le_mode;
output [0:3]                                            ctl_dat_ex3_le_ld_rotsel;
output [0:3]                                            ctl_dat_ex3_be_ld_rotsel;
output                                                  ctl_dat_ex3_algebraic;
output [0:3]                                            ctl_dat_ex3_le_alg_rotsel;

// EX4 Execution Pipe Outputs
output                                                  dcc_byp_rel2_stg_act;
output                                                  dcc_byp_rel3_stg_act;
output                                                  dcc_byp_ram_act;
input                                                   byp_dcc_ex2_req_aborted;
output                                                  dcc_byp_ex4_moveOp_val;
output                                                  dcc_byp_stq6_moveOp_val;
output [64-(2**`GPR_WIDTH_ENC):63]                      dcc_byp_ex4_move_data;
output                                                  dcc_byp_ex5_lq_req_abort;
output [0:((2**`GPR_WIDTH_ENC)/8)-1]                    dcc_byp_ex5_byte_mask;
output [0:`THREADS-1]                                   dcc_byp_ex6_thrd_id;
output                                                  dcc_byp_ex6_dvc1_en;
output                                                  dcc_byp_ex6_dvc2_en;
output [0:3]                                            dcc_byp_ex6_dacr_cmpr;
output [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]            dcc_dir_ex4_p_addr;
output                                                  dcc_dir_stq6_store_val;

// Execution Pipe Outputs
output [0:`THREADS-1]                                   ctl_lsq_ex2_streq_val;
output [0:`ITAG_SIZE_ENC-1]                             ctl_lsq_ex2_itag;
output [0:`THREADS-1]                                   ctl_lsq_ex2_thrd_id;
output [0:`THREADS-1]                                   ctl_lsq_ex3_ldreq_val;
output [0:`THREADS-1]                                   ctl_lsq_ex3_wchkall_val;
output                                                  ctl_lsq_ex3_pfetch_val;
output [0:15]                                           ctl_lsq_ex3_byte_en;
output [58:63]                                          ctl_lsq_ex3_p_addr;
output [0:`THREADS-1]                                   ctl_lsq_ex3_thrd_id;
output                                                  ctl_lsq_ex3_algebraic;
output [0:2]                                            ctl_lsq_ex3_opsize;
output                                                  ctl_lsq_ex4_ldreq_val;
output                                                  ctl_lsq_ex4_binvreq_val;
output                                                  ctl_lsq_ex4_streq_val;
output                                                  ctl_lsq_ex4_othreq_val;
output [64-`REAL_IFAR_WIDTH:57]                         ctl_lsq_ex4_p_addr;
output                                                  ctl_lsq_ex4_dReq_val;
output                                                  ctl_lsq_ex4_gath_load;
output                                                  ctl_lsq_ex4_send_l2;
output                                                  ctl_lsq_ex4_has_data;
output                                                  ctl_lsq_ex4_cline_chk;
output [0:4]                                            ctl_lsq_ex4_wimge;
output                                                  ctl_lsq_ex4_byte_swap;
output                                                  ctl_lsq_ex4_is_sync;
output                                                  ctl_lsq_ex4_all_thrd_chk;
output                                                  ctl_lsq_ex4_is_store;
output                                                  ctl_lsq_ex4_is_resv;
output                                                  ctl_lsq_ex4_is_mfgpr;
output                                                  ctl_lsq_ex4_is_icswxr;
output                                                  ctl_lsq_ex4_is_icbi;
output                                                  ctl_lsq_ex4_watch_clr;
output                                                  ctl_lsq_ex4_watch_clr_all;
output                                                  ctl_lsq_ex4_mtspr_trace;
output                                                  ctl_lsq_ex4_is_inval_op;
output                                                  ctl_lsq_ex4_is_cinval;
output                                                  ctl_lsq_ex5_lock_clr;
output                                                  ctl_lsq_ex5_lock_set;
output                                                  ctl_lsq_ex5_watch_set;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] ctl_lsq_ex5_tgpr;
output                                                  ctl_lsq_ex5_axu_val;		// XU,AXU type operation
output                                                  ctl_lsq_ex5_is_epid;
output [0:3]                                            ctl_lsq_ex5_usr_def;
output                                                  ctl_lsq_ex5_drop_rel;		// L2 only instructions
output                                                  ctl_lsq_ex5_flush_req;		// Flush request from LDQ/STQ
output                                                  ctl_lsq_ex5_flush_pfetch;   // Flush Prefetch in EX5
output [0:10]                                           ctl_lsq_ex5_cmmt_events;
output                                                  ctl_lsq_ex5_perf_val0;
output [0:3]                                            ctl_lsq_ex5_perf_sel0;
output                                                  ctl_lsq_ex5_perf_val1;
output [0:3]                                            ctl_lsq_ex5_perf_sel1;
output                                                  ctl_lsq_ex5_perf_val2;
output [0:3]                                            ctl_lsq_ex5_perf_sel2;
output                                                  ctl_lsq_ex5_perf_val3;
output [0:3]                                            ctl_lsq_ex5_perf_sel3;
output                                                  ctl_lsq_ex5_not_touch;
output [0:1]                                            ctl_lsq_ex5_class_id;
output [0:1]                                            ctl_lsq_ex5_dvc;
output [0:3]                                            ctl_lsq_ex5_dacrw;
output [0:5]                                            ctl_lsq_ex5_ttype;
output [0:1]                                            ctl_lsq_ex5_l_fld;
output                                                  ctl_lsq_ex5_load_hit;
input  [0:3]                                            lsq_ctl_ex6_ldq_events;     // LDQ Pipeline Performance Events
input  [0:1]                                            lsq_ctl_ex6_stq_events;     // LDQ Pipeline Performance Events
output [0:26]                                           ctl_lsq_stq3_icswx_data;
output [0:`THREADS-1]                                   ctl_lsq_dbg_int_en;
output [0:`THREADS-1]                                   ctl_lsq_ldp_idle;

// SPR Directory Read Valid
output                                                  ctl_lsq_rv1_dir_rd_val;

// Directory Read interface
output                                                  dcc_dec_arr_rd_rv1_val;
output [0:5]                                            dcc_dec_arr_rd_congr_cl;

// MFTGPR instruction
output                                                  dcc_dec_stq3_mftgpr_val;
output                                                  dcc_dec_stq5_mftgpr_val;

// SPR status
output                                                  lq_xu_spr_xucr0_cul;		// Cache Lock unable to lock
output [0:31]                                           dcc_dir_spr_xucr2_rmt;
input                                                   spr_dcc_spr_xudbg0_exec;	// Execute Directory Read
input [0:`THREADS-1]                                    spr_dcc_spr_xudbg0_tid;	    // Directory Read Initiated by Thread
input [0:2]                                             spr_dcc_spr_xudbg0_way;		// Directory Read Way
input [0:5]                                             spr_dcc_spr_xudbg0_row;		// Directory Read Congruence Class
output                                                  dcc_spr_spr_xudbg0_done;	// Directory Read Done
output                                                  dcc_spr_spr_xudbg1_valid;	// Directory Valid State
output [0:3]                                            dcc_spr_spr_xudbg1_watch;	// Directory Watch State
output [0:3]                                            dcc_spr_spr_xudbg1_parity;	// Directory Parity
output [0:6]                                            dcc_spr_spr_xudbg1_lru;		// Directory LRU
output                                                  dcc_spr_spr_xudbg1_lock;	// Directory Lock State
output [33:63]                                          dcc_spr_spr_xudbg2_tag;		// Directory Tag
input [32:63]                                           spr_dcc_spr_xucr2_rmt;		// RMT Table
input                                                   spr_dcc_spr_lsucr0_clchk;	// Cacheline Check Enabled
input [0:(32*`THREADS)-1]                               spr_dcc_spr_acop_ct;		// ACOP register for icswx
input [0:(32*`THREADS)-1]                               spr_dcc_spr_hacop_ct;		// HACOP register for icswx
input [0:`THREADS-1]                                    spr_dcc_epsc_epr;
input [0:`THREADS-1]                                    spr_dcc_epsc_eas;
input [0:`THREADS-1]                                    spr_dcc_epsc_egs;
input [0:(8*`THREADS)-1]                                spr_dcc_epsc_elpid;
input [0:(14*`THREADS)-1]                               spr_dcc_epsc_epid;

// Back-invalidate
output                                                  dcc_dir_ex2_binv_val;

// Update Data Array Valid
output                                                  stq4_dcarr_wren;

output                                                  dcc_byp_ram_sel;
output                                                  dcc_dec_ex5_wren;
output                                                  lq_xu_ex5_abort;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lq_xu_gpr_ex5_wa;
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            lq_rv_gpr_ex6_wa;
output                                                  lq_xu_axu_rel_we;
output                                                  lq_xu_gpr_rel_we;
output [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] lq_xu_gpr_rel_wa;
output                                                  lq_rv_gpr_rel_we;
output [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]            lq_rv_gpr_rel_wa;

output                                                  lq_xu_cr_ex5_we;
output [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]             lq_xu_cr_ex5_wa;
output [0:`CR_WIDTH-1]                                  lq_xu_ex5_cr;

// Interface with AXU PassThru with XU
output [59:63]                                          lq_xu_axu_ex4_addr;
output                                                  lq_xu_axu_ex5_we;
output                                                  lq_xu_axu_ex5_le;

// Outputs to Reservation Station
output [0:`THREADS-1]                                   lq_rv_itag1_vld;
output [0:`ITAG_SIZE_ENC-1]                             lq_rv_itag1;
output                                                  lq_rv_itag1_restart;
output                                                  lq_rv_itag1_abort;
output                                                  lq_rv_itag1_hold;
output                                                  lq_rv_itag1_cord;
output [0:`THREADS-1]                                   lq_rv_clr_hold;
output                                                  dcc_dec_hold_all;

// Completion Report
output [0:`THREADS-1]                                   lq0_iu_execute_vld;
output [0:`THREADS-1]                                   lq0_iu_recirc_val;
output [0:`ITAG_SIZE_ENC-1]                             lq0_iu_itag;
output                                                  lq0_iu_flush2ucode;
output                                                  lq0_iu_flush2ucode_type;
output                                                  lq0_iu_exception_val;
output [0:5]                                            lq0_iu_exception;
output [0:`THREADS-1]                                   lq0_iu_dear_val;
output                                                  lq0_iu_n_flush;
output                                                  lq0_iu_np1_flush;
output                                                  lq0_iu_dacr_type;
output [0:3]                                            lq0_iu_dacrw;
output [0:31]                                           lq0_iu_instr;
output [64-(2**`GPR_WIDTH_ENC):63]                      lq0_iu_eff_addr;

// outputs to prefetch
output [64-(2**`GPR_WIDTH_ENC):59]                      dcc_pf_ex5_eff_addr;
output                                                  dcc_pf_ex5_req_val_4pf;
output                                                  dcc_pf_ex5_act;
output [0:`THREADS-1]                                   dcc_pf_ex5_thrd_id;
output                                                  dcc_pf_ex5_loadmiss;
output [0:`ITAG_SIZE_ENC-1]                             dcc_pf_ex5_itag;

// Error Reporting
output                                                  lq_pc_err_derat_parity;
output                                                  lq_pc_err_dir_ldp_parity;
output                                                  lq_pc_err_dir_stp_parity;
output                                                  lq_pc_err_dcache_parity;
output                                                  lq_pc_err_derat_multihit;
output                                                  lq_pc_err_dir_ldp_multihit;
output                                                  lq_pc_err_dir_stp_multihit;

// Ram Mode Control
input [0:`THREADS-1]                                    pc_lq_ram_active;
output                                                  lq_pc_ram_data_val;

// LQ Pervasive
output [0:18+`THREADS-1]                                ctl_perv_ex6_perf_events;
output [0:6+`THREADS-1]                                 ctl_perv_stq4_perf_events;

// ACT's
output                                                  dcc_dir_ex2_stg_act;
output                                                  dcc_dir_ex3_stg_act;
output                                                  dcc_dir_ex4_stg_act;
output                                                  dcc_dir_ex5_stg_act;
output                                                  dcc_dir_stq1_stg_act;
output                                                  dcc_dir_stq2_stg_act;
output                                                  dcc_dir_stq3_stg_act;
output                                                  dcc_dir_stq4_stg_act;
output                                                  dcc_dir_stq5_stg_act;
output                                                  dcc_dir_binv2_ex2_stg_act;
output                                                  dcc_dir_binv3_ex3_stg_act;
output                                                  dcc_dir_binv4_ex4_stg_act;
output                                                  dcc_dir_binv5_ex5_stg_act;
output                                                  dcc_dir_binv6_ex6_stg_act;

// Pervasive


inout                                                   vdd;


inout                                                   gnd;

(* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)

input [0:`NCLK_WIDTH-1]                                 nclk;
input                                                   sg_0;
input                                                   func_sl_thold_0_b;
input                                                   func_sl_force;
input                                                   func_nsl_thold_0_b;
input                                                   func_nsl_force;
input                                                   func_slp_sl_thold_0_b;
input                                                   func_slp_sl_force;
input                                                   func_slp_nsl_thold_0_b;
input                                                   func_slp_nsl_force;
input                                                   d_mode_dc;
input                                                   delay_lclkr_dc;
input                                                   mpw1_dc_b;
input                                                   mpw2_dc_b;

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)

input                                                   scan_in;

(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)

output                                                  scan_out;

//--------------------------
// constants
//--------------------------
parameter                                               TAGSIZE = ((63-(`DC_SIZE-3))-(64-`REAL_IFAR_WIDTH))+1;
parameter                                               AXU_TARGET_ENC = `AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC;

//--------------------------
// components
//--------------------------

parameter [0:4]                                         rot_max_size = 5'b10000;

//--------------------------
// signals
//--------------------------
wire [0:`THREADS-1]                                     iu_lq_recirc_val_d;
wire [0:`THREADS-1]                                     iu_lq_recirc_val_q;
wire [0:`ITAG_SIZE_ENC-1]                               iu_lq_cp_next_itag_q[0:`THREADS-1];
wire [0:`THREADS-1]                                     iu_lq_cp_flush_d;
wire [0:`THREADS-1]                                     iu_lq_cp_flush_q;
wire [0:`THREADS-1]                                     ex0_i0_vld_d;
wire [0:`THREADS-1]                                     ex0_i0_vld_q;
wire                                                    ex0_i0_ucode_preissue_d;
wire                                                    ex0_i0_ucode_preissue_q;
wire                                                    ex0_i0_2ucode_d;
wire                                                    ex0_i0_2ucode_q;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex0_i0_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex0_i0_ucode_cnt_q;
wire [0:`THREADS-1]                                     ex0_i1_vld_d;
wire [0:`THREADS-1]                                     ex0_i1_vld_q;
wire                                                    ex0_i1_ucode_preissue_d;
wire                                                    ex0_i1_ucode_preissue_q;
wire                                                    ex0_i1_2ucode_d;
wire                                                    ex0_i1_2ucode_q;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex0_i1_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex0_i1_ucode_cnt_q;
wire [0:`THREADS-1]                                     xer_lq_cp_rd_so_d;
wire [0:`THREADS-1]                                     xer_lq_cp_rd_so_q;
wire                                                    ex2_optype1_d;
wire                                                    ex2_optype1_q;
wire                                                    ex3_optype1_d;
wire                                                    ex3_optype1_q;
wire                                                    ex2_optype2_d;
wire                                                    ex2_optype2_q;
wire                                                    ex3_optype2_d;
wire                                                    ex3_optype2_q;
wire                                                    ex2_optype4_d;
wire                                                    ex2_optype4_q;
wire                                                    ex3_optype4_d;
wire                                                    ex3_optype4_q;
wire                                                    ex2_optype8_d;
wire                                                    ex2_optype8_q;
wire                                                    ex3_optype8_d;
wire                                                    ex3_optype8_q;
wire                                                    ex2_optype16_d;
wire                                                    ex2_optype16_q;
wire                                                    ex3_optype16_d;
wire                                                    ex3_optype16_q;
wire                                                    ex3_dacr_type_d;
wire                                                    ex3_dacr_type_q;
wire                                                    ex4_dacr_type_d;
wire                                                    ex4_dacr_type_q;
wire                                                    ex5_dacr_type_d;
wire                                                    ex5_dacr_type_q;
wire                                                    ex2_cache_acc_d;
wire                                                    ex2_cache_acc_q;
wire                                                    ex3_cache_acc_d;
wire                                                    ex3_cache_acc_q;
wire                                                    ex4_cache_acc_d;
wire                                                    ex4_cache_acc_q;
wire                                                    ex5_cache_acc_d;
wire                                                    ex5_cache_acc_q;
wire                                                    ex6_cache_acc_d;
wire                                                    ex6_cache_acc_q;
wire [0:`THREADS-1]                                     ex2_thrd_id_d;
wire [0:`THREADS-1]                                     ex2_thrd_id_q;
wire [0:`THREADS-1]                                     ex3_thrd_id_d;
wire [0:`THREADS-1]                                     ex3_thrd_id_q;
wire [0:`THREADS-1]                                     ex4_thrd_id_d;
wire [0:`THREADS-1]                                     ex4_thrd_id_q;
wire [0:`THREADS-1]                                     ex5_thrd_id_d;
wire [0:`THREADS-1]                                     ex5_thrd_id_q;
wire [0:`THREADS-1]                                     ex6_thrd_id_d;
wire [0:`THREADS-1]                                     ex6_thrd_id_q;
wire [0:31]                                             ex2_instr_d;
wire [0:31]                                             ex2_instr_q;
wire [0:31]                                             ex3_instr_d;
wire [0:31]                                             ex3_instr_q;
wire [0:31]                                             ex4_instr_d;
wire [0:31]                                             ex4_instr_q;
wire [0:31]                                             ex5_instr_d;
wire [0:31]                                             ex5_instr_q;
wire [0:AXU_TARGET_ENC-1]                               ex2_target_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               ex2_target_gpr_q;
wire [0:AXU_TARGET_ENC-1]                               ex3_target_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               ex3_target_gpr_q;
wire [0:AXU_TARGET_ENC-1]                               ex4_target_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               ex4_target_gpr_q;
wire [0:AXU_TARGET_ENC-1]                               ex5_target_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               ex5_target_gpr_q;
wire                                                    ex2_dcbt_instr_d;
wire                                                    ex2_dcbt_instr_q;
wire                                                    ex3_dcbt_instr_d;
wire                                                    ex3_dcbt_instr_q;
wire                                                    ex4_dcbt_instr_d;
wire                                                    ex4_dcbt_instr_q;
wire                                                    ex2_pfetch_val_d;
wire                                                    ex2_pfetch_val_q;
wire                                                    ex3_pfetch_val_d;
wire                                                    ex3_pfetch_val_q;
wire                                                    ex4_pfetch_val_d;
wire                                                    ex4_pfetch_val_q;
wire                                                    ex5_pfetch_val_d;
wire                                                    ex5_pfetch_val_q;
wire                                                    ex6_pfetch_val_d;
wire                                                    ex6_pfetch_val_q;
wire [0:`THREADS-1]                                     ldp_pfetch_inPipe;
wire                                                    ex2_dcbtst_instr_d;
wire                                                    ex2_dcbtst_instr_q;
wire                                                    ex3_dcbtst_instr_d;
wire                                                    ex3_dcbtst_instr_q;
wire                                                    ex4_dcbtst_instr_d;
wire                                                    ex4_dcbtst_instr_q;
wire                                                    ex2_store_instr_d;
wire                                                    ex2_store_instr_q;
wire                                                    ex2_wchk_instr_d;
wire                                                    ex2_wchk_instr_q;
wire                                                    ex3_wchk_instr_d;
wire                                                    ex3_wchk_instr_q;
wire                                                    ex4_wchk_instr_d;
wire                                                    ex4_wchk_instr_q;
wire                                                    ex2_dcbst_instr_d;
wire                                                    ex2_dcbst_instr_q;
wire                                                    ex3_dcbst_instr_d;
wire                                                    ex3_dcbst_instr_q;
wire                                                    ex4_dcbst_instr_d;
wire                                                    ex4_dcbst_instr_q;
wire                                                    ex2_dcbf_instr_d;
wire                                                    ex2_dcbf_instr_q;
wire                                                    ex3_dcbf_instr_d;
wire                                                    ex3_dcbf_instr_q;
wire                                                    ex4_dcbf_instr_d;
wire                                                    ex4_dcbf_instr_q;
wire                                                    ex2_mtspr_trace_d;
wire                                                    ex2_mtspr_trace_q;
wire                                                    ex3_mtspr_trace_d;
wire                                                    ex3_mtspr_trace_q;
wire                                                    ex4_mtspr_trace_d;
wire                                                    ex4_mtspr_trace_q;
wire                                                    ex2_sync_instr_d;
wire                                                    ex2_sync_instr_q;
wire                                                    ex3_sync_instr_d;
wire                                                    ex3_sync_instr_q;
wire                                                    ex4_sync_instr_d;
wire                                                    ex4_sync_instr_q;
wire [0:1]                                              ex2_l_fld_d;
wire [0:1]                                              ex2_l_fld_q;
wire [0:1]                                              ex3_l_fld_d;
wire [0:1]                                              ex3_l_fld_q;
wire [0:1]                                              ex4_l_fld_d;
wire [0:1]                                              ex4_l_fld_q;
wire [0:1]                                              ex5_l_fld_d;
wire [0:1]                                              ex5_l_fld_q;
wire [0:3]                                              ex3_l_fld_sel;
wire [0:1]                                              ex3_l_fld_mbar;
wire [0:1]                                              ex3_l_fld_sync;
wire [0:1]                                              ex3_l_fld_tlbsync;
wire [0:1]                                              ex3_l_fld_makeitso;
wire [0:1]                                              ex3_l_fld;
wire                                                    ex2_dcbi_instr_d;
wire                                                    ex2_dcbi_instr_q;
wire                                                    ex3_dcbi_instr_d;
wire                                                    ex3_dcbi_instr_q;
wire                                                    ex4_dcbi_instr_d;
wire                                                    ex4_dcbi_instr_q;
wire                                                    ex2_dcbz_instr_d;
wire                                                    ex2_dcbz_instr_q;
wire                                                    ex3_dcbz_instr_d;
wire                                                    ex3_dcbz_instr_q;
wire                                                    ex4_dcbz_instr_d;
wire                                                    ex4_dcbz_instr_q;
wire                                                    ex2_icbi_instr_d;
wire                                                    ex2_icbi_instr_q;
wire                                                    ex3_icbi_instr_d;
wire                                                    ex3_icbi_instr_q;
wire                                                    ex4_icbi_instr_d;
wire                                                    ex4_icbi_instr_q;
wire                                                    ex2_mbar_instr_d;
wire                                                    ex2_mbar_instr_q;
wire                                                    ex3_mbar_instr_d;
wire                                                    ex3_mbar_instr_q;
wire                                                    ex4_mbar_instr_d;
wire                                                    ex4_mbar_instr_q;
wire                                                    ex2_makeitso_instr_d;
wire                                                    ex2_makeitso_instr_q;
wire                                                    ex3_makeitso_instr_d;
wire                                                    ex3_makeitso_instr_q;
wire                                                    ex4_makeitso_instr_d;
wire                                                    ex4_makeitso_instr_q;
wire                                                    ex2_dci_instr_d;
wire                                                    ex2_dci_instr_q;
wire                                                    ex3_dci_instr_d;
wire                                                    ex3_dci_instr_q;
wire                                                    ex4_dci_instr_d;
wire                                                    ex4_dci_instr_q;
wire                                                    ex4_dci_l2_val;
wire                                                    ex4_is_cinval;
wire                                                    ex4_is_cinval_drop;
wire                                                    ex2_ici_instr_d;
wire                                                    ex2_ici_instr_q;
wire                                                    ex3_ici_instr_d;
wire                                                    ex3_ici_instr_q;
wire                                                    ex4_ici_instr_d;
wire                                                    ex4_ici_instr_q;
wire                                                    ex4_ici_l2_val;
wire                                                    ex2_resv_instr_d;
wire                                                    ex2_resv_instr_q;
wire                                                    ex3_resv_instr_d;
wire                                                    ex3_resv_instr_q;
wire                                                    ex4_resv_instr_d;
wire                                                    ex4_resv_instr_q;
wire                                                    ex2_load_instr_d;
wire                                                    ex2_load_instr_q;
wire                                                    ex3_load_instr_d;
wire                                                    ex3_load_instr_q;
wire                                                    ex4_load_instr_d;
wire                                                    ex4_load_instr_q;
wire                                                    ex3_load_type;
wire                                                    ex4_load_type_d;
wire                                                    ex4_load_type_q;
wire                                                    ex4_gath_load_d;
wire                                                    ex4_gath_load_q;
wire                                                    ex3_store_instr_d;
wire                                                    ex3_store_instr_q;
wire                                                    ex4_store_instr_d;
wire                                                    ex4_store_instr_q;
wire                                                    ex3_le_mode;
wire                                                    ex4_le_mode_d;
wire                                                    ex4_le_mode_q;
wire                                                    ex5_wimge_i_bits_d;
wire                                                    ex5_wimge_i_bits_q;
wire [0:3]                                              ex5_usr_bits_d;
wire [0:3]                                              ex5_usr_bits_q;
wire [0:1]                                              ex5_classid_d;
wire [0:1]                                              ex5_classid_q;
wire                                                    ex5_derat_setHold_d;
wire                                                    ex5_derat_setHold_q;
wire                                                    ex3_icswx_type;
wire                                                    ex4_icswx_type;
wire                                                    ex4_stx_instr;
wire                                                    ex4_larx_instr;
wire                                                    is_mem_bar_op;
wire                                                    is_inval_op;
wire                                                    ex3_l1_lock_set;
wire                                                    is_lock_clr;
wire                                                    ex3_lru_upd;
wire                                                    stq6_tgpr_val;
wire [0:AXU_TARGET_ENC-1]                               reg_upd_ta_gpr;
wire                                                    lq_wren;
wire                                                    ex5_lq_wren;
wire                                                    ex5_lq_wren_d;
wire                                                    ex5_lq_wren_q;
wire                                                    ex6_lq_wren_d;
wire                                                    ex6_lq_wren_q;
wire                                                    axu_wren;
wire                                                    rel2_axu_wren_d;
wire                                                    rel2_axu_wren_q;
wire                                                    stq2_axu_val_d;
wire                                                    stq2_axu_val_q;
wire                                                    stq3_axu_val_d;
wire                                                    stq3_axu_val_q;
wire                                                    stq4_axu_val_d;
wire                                                    stq4_axu_val_q;
wire                                                    stq3_store_hit;
wire                                                    stq3_store_miss;
wire                                                    stq4_store_hit_d;
wire                                                    stq4_store_hit_q;
wire                                                    stq5_store_hit_d;
wire                                                    stq5_store_hit_q;
wire                                                    stq6_store_hit_d;
wire                                                    stq6_store_hit_q;
wire                                                    ex4_load_hit;
wire                                                    ex4_load_miss;
wire                                                    ex5_load_miss_d;
wire                                                    ex5_load_miss_q;
wire                                                    ex5_load_hit_d;
wire                                                    ex5_load_hit_q;
wire                                                    ex6_load_hit_d;
wire                                                    ex6_load_hit_q;
wire                                                    ex2_axu_op_val_d;
wire                                                    ex2_axu_op_val_q;
wire                                                    ex3_axu_op_val_d;
wire                                                    ex3_axu_op_val_q;
wire                                                    ex4_axu_op_val_d;
wire                                                    ex4_axu_op_val_q;
wire                                                    ex5_axu_op_val_d;
wire                                                    ex5_axu_op_val_q;
wire                                                    ex2_upd_form_d;
wire                                                    ex2_upd_form_q;
wire                                                    ex3_upd_form_d;
wire                                                    ex3_upd_form_q;
wire [0:2]                                              ex2_axu_instr_type_d;
wire [0:2]                                              ex2_axu_instr_type_q;
wire [0:2]                                              ex3_axu_instr_type_d;
wire [0:2]                                              ex3_axu_instr_type_q;
wire                                                    ex5_axu_wren_d;
wire                                                    ex5_axu_wren_q;
wire                                                    ex6_axu_wren_d;
wire                                                    ex6_axu_wren_q;
wire [0:AXU_TARGET_ENC-1]                               ex5_lq_ta_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               ex5_lq_ta_gpr_q;
wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]              ex6_lq_ta_gpr_d;
wire [0:`GPR_POOL_ENC+`THREADS_POOL_ENC-1]              ex6_lq_ta_gpr_q;
wire                                                    ex5_load_le_d;
wire                                                    ex5_load_le_q;
wire                                                    ex2_algebraic_d;
wire                                                    ex2_algebraic_q;
wire                                                    ex3_algebraic_d;
wire                                                    ex3_algebraic_q;
wire                                                    ex2_strg_index_d;
wire                                                    ex2_strg_index_q;
wire                                                    ex3_strg_index_d;
wire                                                    ex3_strg_index_q;
wire                                                    ex4_strg_index_d;
wire                                                    ex4_strg_index_q;
wire                                                    ex4_nogpr_upd;
wire                                                    ex1_th_b0;
wire                                                    ex2_th_fld_c_d;
wire                                                    ex2_th_fld_c_q;
wire                                                    ex3_th_fld_c_d;
wire                                                    ex3_th_fld_c_q;
wire                                                    ex4_th_fld_c_d;
wire                                                    ex4_th_fld_c_q;
wire                                                    ex2_th_fld_l2_d;
wire                                                    ex2_th_fld_l2_q;
wire                                                    ex3_th_fld_l2_d;
wire                                                    ex3_th_fld_l2_q;
wire                                                    ex4_th_fld_l2_d;
wire                                                    ex4_th_fld_l2_q;
wire                                                    ex2_undef_touch;
wire                                                    ex3_undef_touch_d;
wire                                                    ex3_undef_touch_q;
wire                                                    ex4_undef_touch_d;
wire                                                    ex4_undef_touch_q;
wire                                                    ex2_dcbtls_instr_d;
wire                                                    ex2_dcbtls_instr_q;
wire                                                    ex3_dcbtls_instr_d;
wire                                                    ex3_dcbtls_instr_q;
wire                                                    ex4_dcbtls_instr_d;
wire                                                    ex4_dcbtls_instr_q;
wire                                                    ex2_dcbtstls_instr_d;
wire                                                    ex2_dcbtstls_instr_q;
wire                                                    ex3_dcbtstls_instr_d;
wire                                                    ex3_dcbtstls_instr_q;
wire                                                    ex4_dcbtstls_instr_d;
wire                                                    ex4_dcbtstls_instr_q;
wire                                                    ex2_dcblc_instr_d;
wire                                                    ex2_dcblc_instr_q;
wire                                                    ex3_dcblc_instr_d;
wire                                                    ex3_dcblc_instr_q;
wire                                                    ex4_dcblc_instr_d;
wire                                                    ex4_dcblc_instr_q;
wire                                                    ex2_icblc_l2_instr_d;
wire                                                    ex2_icblc_l2_instr_q;
wire                                                    ex3_icblc_l2_instr_d;
wire                                                    ex3_icblc_l2_instr_q;
wire                                                    ex4_icblc_l2_instr_d;
wire                                                    ex4_icblc_l2_instr_q;
wire                                                    ex2_icbt_l2_instr_d;
wire                                                    ex2_icbt_l2_instr_q;
wire                                                    ex3_icbt_l2_instr_d;
wire                                                    ex3_icbt_l2_instr_q;
wire                                                    ex4_icbt_l2_instr_d;
wire                                                    ex4_icbt_l2_instr_q;
wire                                                    ex2_icbtls_l2_instr_d;
wire                                                    ex2_icbtls_l2_instr_q;
wire                                                    ex3_icbtls_l2_instr_d;
wire                                                    ex3_icbtls_l2_instr_q;
wire                                                    ex4_icbtls_l2_instr_d;
wire                                                    ex4_icbtls_l2_instr_q;
wire                                                    ex2_tlbsync_instr_d;
wire                                                    ex2_tlbsync_instr_q;
wire                                                    ex3_tlbsync_instr_d;
wire                                                    ex3_tlbsync_instr_q;
wire                                                    ex4_tlbsync_instr_d;
wire                                                    ex4_tlbsync_instr_q;
wire                                                    ex2_ldst_falign_d;
wire                                                    ex2_ldst_falign_q;
wire                                                    ex2_ldst_fexcpt_d;
wire                                                    ex2_ldst_fexcpt_q;
wire                                                    ex3_ldst_fexcpt_d;
wire                                                    ex3_ldst_fexcpt_q;
wire [0:8+`THREADS]                                     xudbg1_dir_reg_d;
wire [0:8+`THREADS]                                     xudbg1_dir_reg_q;
wire [0:PARBITS-1]                                      xudbg1_parity_reg_d;
wire [0:PARBITS-1]                                      xudbg1_parity_reg_q;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]              xudbg2_tag_d;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]              xudbg2_tag_q;
wire [0:24]                                             epsc_t_reg[0:`THREADS-1];
wire [0:23]                                             lesr_t_reg[0:`THREADS-1];
wire [0:31]                                             way_lck_rmt;
wire                                                    spr_ccr2_ap_d;
wire                                                    spr_ccr2_ap_q;
wire                                                    spr_ccr2_en_trace_d;
wire                                                    spr_ccr2_en_trace_q;
wire                                                    spr_ccr2_ucode_dis_d;
wire                                                    spr_ccr2_ucode_dis_q;
wire                                                    spr_ccr2_notlb_d;
wire                                                    spr_ccr2_notlb_q;
wire                                                    clkg_ctl_override_d;
wire                                                    clkg_ctl_override_q;
wire                                                    spr_xucr0_wlk_d;
wire                                                    spr_xucr0_wlk_q;
wire                                                    spr_xucr0_mbar_ack_d;
wire                                                    spr_xucr0_mbar_ack_q;
wire                                                    spr_xucr0_tlbsync_d;
wire                                                    spr_xucr0_tlbsync_q;
wire                                                    spr_xucr0_dcdis_d;
wire                                                    spr_xucr0_dcdis_q;
wire                                                    spr_xucr0_aflsta_d;
wire                                                    spr_xucr0_aflsta_q;
wire                                                    spr_xucr0_flsta_d;
wire                                                    spr_xucr0_flsta_q;
wire                                                    spr_xucr0_mddp_d;
wire                                                    spr_xucr0_mddp_q;
wire                                                    spr_xucr0_mdcp_d;
wire                                                    spr_xucr0_mdcp_q;
wire                                                    spr_xucr4_mmu_mchk_d;
wire                                                    spr_xucr4_mmu_mchk_q;
wire                                                    spr_xucr4_mddmh_d;
wire                                                    spr_xucr4_mddmh_q;
wire [0:`THREADS-1]                                     spr_xucr0_en_trace_um_d;
wire [0:`THREADS-1]                                     spr_xucr0_en_trace_um_q;
wire                                                    ex4_mtspr_trace_tid_en;
wire                                                    ex4_mtspr_trace_en;
wire                                                    ex4_mtspr_trace_dis;
wire                                                    ex1_lsu_64bit_mode;
wire [0:`THREADS-1]                                     ex1_lsu_64bit_mode_d;
wire [0:`THREADS-1]                                     ex1_lsu_64bit_mode_q;
wire                                                    ex2_lsu_64bit_agen_d;
wire                                                    ex2_lsu_64bit_agen_q;
wire                                                    ex3_lsu_64bit_agen_d;
wire                                                    ex3_lsu_64bit_agen_q;
wire                                                    ex4_lsu_64bit_agen_d;
wire                                                    ex4_lsu_64bit_agen_q;
wire                                                    stq4_dcarr_wren_d;
wire                                                    stq4_dcarr_wren_q;
wire                                                    ex2_sgpr_instr_d;
wire                                                    ex2_sgpr_instr_q;
wire                                                    ex2_saxu_instr_d;
wire                                                    ex2_saxu_instr_q;
wire                                                    ex2_sdp_instr_d;
wire                                                    ex2_sdp_instr_q;
wire                                                    ex2_tgpr_instr_d;
wire                                                    ex2_tgpr_instr_q;
wire                                                    ex2_taxu_instr_d;
wire                                                    ex2_taxu_instr_q;
wire                                                    ex2_tdp_instr_d;
wire                                                    ex2_tdp_instr_q;
wire                                                    ex3_sgpr_instr_d;
wire                                                    ex3_sgpr_instr_q;
wire                                                    ex3_saxu_instr_d;
wire                                                    ex3_saxu_instr_q;
wire                                                    ex3_sdp_instr_d;
wire                                                    ex3_sdp_instr_q;
wire                                                    ex3_tgpr_instr_d;
wire                                                    ex3_tgpr_instr_q;
wire                                                    ex3_taxu_instr_d;
wire                                                    ex3_taxu_instr_q;
wire                                                    ex3_tdp_instr_d;
wire                                                    ex3_tdp_instr_q;
wire                                                    ex4_sgpr_instr_d;
wire                                                    ex4_sgpr_instr_q;
wire                                                    ex4_saxu_instr_d;
wire                                                    ex4_saxu_instr_q;
wire                                                    ex4_sdp_instr_d;
wire                                                    ex4_sdp_instr_q;
wire                                                    ex4_tgpr_instr_d;
wire                                                    ex4_tgpr_instr_q;
wire                                                    ex4_taxu_instr_d;
wire                                                    ex4_taxu_instr_q;
wire                                                    ex4_tdp_instr_d;
wire                                                    ex4_tdp_instr_q;
wire                                                    ex4_mfdpa_val;
wire                                                    ex4_mfdpf_val;
wire                                                    ex4_ditc_val;
wire                                                    ex3_mffgpr_val;
wire                                                    ex4_mffgpr_val;
wire                                                    ex4_mftgpr_val;
wire                                                    ex5_mftgpr_val_d;
wire                                                    ex5_mftgpr_val_q;
wire                                                    ex2_mftgpr_val;
wire                                                    ex3_mftgpr_val;
wire                                                    ex3_mfgpr_val;
wire                                                    ex4_moveOp_val_d;
wire                                                    ex4_moveOp_val_q;
wire                                                    stq6_moveOp_val_d;
wire                                                    stq6_moveOp_val_q;
wire                                                    data_touch_op;
wire                                                    inst_touch_op;
wire                                                    all_touch_op;
wire                                                    ddir_acc_instr;
wire                                                    ex4_c_dcbtls;
wire                                                    ex4_c_dcbtstls;
wire                                                    ex4_c_icbtls;
wire                                                    ex4_l2_dcbtls;
wire                                                    ex4_l2_dcbtstls;
wire                                                    ex4_l2_icbtls;
wire                                                    ex4_l2_icblc;
wire                                                    ex4_l2_dcblc;
wire                                                    ex4_blkable_touch_d;
wire                                                    ex4_blkable_touch_q;
wire                                                    ex5_blk_touch_d;
wire                                                    ex5_blk_touch_q;
wire                                                    ex6_blk_touch_d;
wire                                                    ex6_blk_touch_q;
wire                                                    ex4_excp_touch;
wire                                                    ex4_cinh_touch;
wire                                                    ex4_blk_touch;
wire							                        ex4_blk_touch_instr;
wire                                                    ex3_local_dcbf;
wire                                                    ex2_mutex_hint_d;
wire                                                    ex2_mutex_hint_q;
wire                                                    ex3_mutex_hint_d;
wire                                                    ex3_mutex_hint_q;
wire                                                    ex4_mutex_hint_d;
wire                                                    ex4_mutex_hint_q;
wire [64-`REAL_IFAR_WIDTH:63]                           ex4_p_addr;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex3_eff_addr_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex3_eff_addr_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex4_eff_addr_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex4_eff_addr_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex5_eff_addr_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                        ex5_eff_addr_q;
wire                                                    ex2_lockset_instr;
wire                                                    ex3_undef_lockset_d;
wire                                                    ex3_undef_lockset_q;
wire                                                    ex4_undef_lockset_d;
wire                                                    ex4_undef_lockset_q;
wire                                                    ex4_cinh_lockset;
wire                                                    ex4_l1dc_dis_lockset;
wire                                                    ex4_l1dc_dis_lockclr;
wire                                                    ex4_noop_lockset;
wire                                                    ex5_unable_2lock_d;
wire                                                    ex5_unable_2lock_q;
wire                                                    ex6_stq5_unable_2lock_d;
wire                                                    ex6_stq5_unable_2lock_q;
wire                                                    ex2_stq_val_cacc;
wire                                                    ex2_stq_nval_cacc;
wire                                                    ex2_stq_val_req;
wire                                                    ex3_stq_val_req_d;
wire                                                    ex3_stq_val_req_q;
wire                                                    ex4_stq_val_req_d;
wire                                                    ex4_stq_val_req_q;
wire                                                    ex5_load_instr_d;
wire                                                    ex5_load_instr_q;
wire                                                    ex2_mword_instr_d;
wire                                                    ex2_mword_instr_q;
wire                                                    ex3_mword_instr_d;
wire                                                    ex3_mword_instr_q;
wire                                                    stq4_store_miss_d;
wire                                                    stq4_store_miss_q;
wire                                                    ex5_perf_dcbt_d;
wire                                                    ex5_perf_dcbt_q;
reg  [0:23]                                             ex5_spr_lesr;
wire                                                    perf_stq_stores;
wire                                                    perf_stq_store_miss;
wire                                                    perf_stq_stcx_exec;
wire                                                    perf_stq_axu_store;
wire                                                    perf_stq_wclr;
wire                                                    perf_stq_wclr_set;
wire                                                    perf_com_loadmiss;
wire                                                    perf_com_cinh_loads;
wire                                                    perf_com_loads;
wire                                                    perf_com_dcbt_sent;
wire                                                    perf_com_dcbt_hit;
wire                                                    perf_com_axu_load;
wire                                                    perf_com_load_fwd;
wire                                                    perf_ex6_pfetch_iss;
wire                                                    perf_ex6_pfetch_hit;
wire                                                    perf_ex6_pfetch_emiss;
wire                                                    perf_ex6_align_flush;
wire                                                    perf_ex6_dir_restart;
wire                                                    perf_ex6_dec_restart;
wire                                                    perf_ex6_wNComp_restart;
wire                                                    perf_ex6_pfetch_ldq_full;
wire                                                    perf_ex6_pfetch_ldq_hit;
wire                                                    perf_ex6_pfetch_stq;
wire                                                    perf_ex6_ldq_full;
wire                                                    perf_ex6_ldq_hit;
wire                                                    perf_ex6_lgq_full;
wire                                                    perf_ex6_lgq_hit;
wire                                                    perf_ex6_stq_sametid;
wire                                                    perf_ex6_stq_difftid;
wire                                                    perf_ex6_derat_attmpts;
wire [0:10]                                             ex5_cmmt_events;
wire [0:6+`THREADS-1]                                   stq_perf_events;
wire [0:18+`THREADS-1]                                  ex6_dcc_perf_events;
wire                                                    perf_com_watch_set;
wire                                                    perf_com_watch_dup;
wire                                                    perf_com_wchkall;
wire                                                    perf_com_wchkall_succ;
wire                                                    ex3_watch_clr_entry;
wire                                                    ex3_watch_clr_all;
wire                                                    ex4_local_dcbf_d;
wire                                                    ex4_local_dcbf_q;
wire                                                    ex2_msgsnd_instr_d;
wire                                                    ex2_msgsnd_instr_q;
wire                                                    ex3_msgsnd_instr_d;
wire                                                    ex3_msgsnd_instr_q;
wire                                                    ex4_msgsnd_instr_d;
wire                                                    ex4_msgsnd_instr_q;
wire                                                    ex4_l2load_type_d;
wire                                                    ex4_l2load_type_q;
wire                                                    ex2_ldawx_instr_d;
wire                                                    ex2_ldawx_instr_q;
wire                                                    ex3_ldawx_instr_d;
wire                                                    ex3_ldawx_instr_q;
wire                                                    ex4_ldawx_instr_d;
wire                                                    ex4_ldawx_instr_q;
wire                                                    ex5_ldawx_instr_d;
wire                                                    ex5_ldawx_instr_q;
wire                                                    ex2_wclr_instr_d;
wire                                                    ex2_wclr_instr_q;
wire                                                    ex3_wclr_instr_d;
wire                                                    ex3_wclr_instr_q;
wire                                                    ex4_wclr_instr_d;
wire                                                    ex4_wclr_instr_q;
wire                                                    ex4_wclr_all_val;
wire [0:4]                                              ex3_opsize;
wire [0:2]                                              ex3_opsize_enc;
wire [0:2]                                              ex4_opsize_enc_d;
wire [0:2]                                              ex4_opsize_enc_q;
wire [0:2]                                              ex5_opsize_enc_d;
wire [0:2]                                              ex5_opsize_enc_q;
wire [1:4]                                              ex5_opsize;
wire [0:7]                                              ex5_byte_mask;
wire [0:4]                                              ex3_rot_size;
wire [0:4]                                              ex3_rot_sel_non_le;
wire [0:4]                                              ex3_alg_bit_le_sel;
wire [0:`ITAG_SIZE_ENC-1]                               ex2_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex2_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                               ex3_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex3_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                               ex4_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex4_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                               ex5_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex5_itag_q;
wire [0:`ITAG_SIZE_ENC-1]                               ex6_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex6_itag_q;
wire                                                    ex5_drop_rel_d;
wire                                                    ex5_drop_rel_q;
wire                                                    ex2_icswx_instr_d;
wire                                                    ex2_icswx_instr_q;
wire                                                    ex3_icswx_instr_d;
wire                                                    ex3_icswx_instr_q;
wire                                                    ex4_icswx_instr_d;
wire                                                    ex4_icswx_instr_q;
wire                                                    ex2_icswxdot_instr_d;
wire                                                    ex2_icswxdot_instr_q;
wire                                                    ex3_icswxdot_instr_d;
wire                                                    ex3_icswxdot_instr_q;
wire                                                    ex4_icswxdot_instr_d;
wire                                                    ex4_icswxdot_instr_q;
wire                                                    ex2_icswx_epid_d;
wire                                                    ex2_icswx_epid_q;
wire                                                    ex3_icswx_epid_d;
wire                                                    ex3_icswx_epid_q;
wire                                                    ex4_icswx_epid_d;
wire                                                    ex4_icswx_epid_q;
wire                                                    ex5_icswx_epid_d;
wire                                                    ex5_icswx_epid_q;
wire                                                    ex4_c_inh_drop_op_d;
wire                                                    ex4_c_inh_drop_op_q;
wire                                                    ex4_cache_enabled;
wire                                                    ex4_cache_inhibited;
wire [0:8]                                              ex4_mem_attr;
wire [0:AXU_TARGET_ENC-1]                               rel2_ta_gpr_d;
wire [0:AXU_TARGET_ENC-1]                               rel2_ta_gpr_q;
wire                                                    rv1_binv_val_d;
wire                                                    rv1_binv_val_q;
wire                                                    ex0_binv_val_d;
wire                                                    ex0_binv_val_q;
wire                                                    ex1_binv_val_d;
wire                                                    ex1_binv_val_q;
wire                                                    ex2_binv_val_d;
wire                                                    ex2_binv_val_q;
wire                                                    ex3_binv_val_d;
wire                                                    ex3_binv_val_q;
wire                                                    ex4_binv_val_d;
wire                                                    ex4_binv_val_q;
wire                                                    ex0_derat_snoop_val_d;
wire                                                    ex0_derat_snoop_val_q;
wire                                                    ex1_derat_snoop_val_d;
wire                                                    ex1_derat_snoop_val_q;
wire                                                    spr_msr_fp;
wire [0:`THREADS-1]                                     spr_msr_fp_d;
wire [0:`THREADS-1]                                     spr_msr_fp_q;
wire                                                    spr_msr_spv;
wire [0:`THREADS-1]                                     spr_msr_spv_d;
wire [0:`THREADS-1]                                     spr_msr_spv_q;
wire [0:`THREADS-1]                                     spr_msr_gs_d;
wire [0:`THREADS-1]                                     spr_msr_gs_q;
wire [0:`THREADS-1]                                     spr_msr_pr_d;
wire [0:`THREADS-1]                                     spr_msr_pr_q;
wire [0:`THREADS-1]                                     spr_msr_ds_d;
wire [0:`THREADS-1]                                     spr_msr_ds_q;
wire [0:`THREADS-1]                                     spr_msr_de_d;
wire [0:`THREADS-1]                                     spr_msr_de_q;
wire [0:`THREADS-1]                                     spr_dbcr0_idm_d;
wire [0:`THREADS-1]                                     spr_dbcr0_idm_q;
wire [0:`THREADS-1]                                     spr_epcr_duvd_d;
wire [0:`THREADS-1]                                     spr_epcr_duvd_q;
wire [0:7]                                              spr_lpidr_d;
wire [0:7]                                              spr_lpidr_q;
wire [0:13]                                             spr_pid_d[0:`THREADS-1];
wire [0:13]                                             spr_pid_q[0:`THREADS-1];
wire [0:31]                                             spr_acop_ct[0:`THREADS-1];
wire [0:31]                                             spr_hacop_ct[0:`THREADS-1];
wire                                                    ex2_epsc_egs;
wire                                                    ex2_epsc_epr;
wire                                                    ex2_msr_gs;
wire                                                    ex2_msr_pr;
wire                                                    ex3_icswx_gs_d;
wire                                                    ex3_icswx_gs_q;
wire                                                    ex3_icswx_pr_d;
wire                                                    ex3_icswx_pr_q;
wire                                                    ex4_icswx_ct_val_d;
wire                                                    ex4_icswx_ct_val_q;
reg  [32:63]                                            ex3_acop_ct;
reg  [32:63]                                            ex3_hacop_ct;
wire [32:63]                                            ex3_acop_ct_npr;
wire [32:63]                                            ex3_cop_ct;
wire [0:1]                                              ex3_icswx_ct;
wire [0:1]                                              ex4_icswx_ct_d;
wire [0:1]                                              ex4_icswx_ct_q;
wire                                                    ex4_icswx_ct;
wire                                                    ex4_icswx_dsi;
wire [0:`THREADS-1]                                     dbg_int_en_d;
wire [0:`THREADS-1]                                     dbg_int_en_q;
reg  [0:13]                                             stq2_pid;
reg  [0:24]                                             stq2_epsc;
wire [0:24]                                             stq2_icswx_epid;
wire [0:24]                                             stq2_icswx_nepid;
wire [0:24]                                             stq3_icswx_data_d;
wire [0:24]                                             stq3_icswx_data_q;
wire                                                    ex4_spr_msr_pr;
wire [0:`THREADS-1]                                     hypervisor_state;
wire                                                    ex4_load_val;
wire [0:5]                                              ex5_ttype_d;
wire [0:5]                                              ex5_ttype_q;
wire                                                    ex4_store_val;
wire                                                    ex4_othreq_val;
wire                                                    ex3_illeg_lswx;
wire                                                    ex3_strg_index_noop;
wire                                                    ex4_strg_gate_d;
wire                                                    ex4_strg_gate_q;
wire                                                    ex3_wNComp;
wire [0:`THREADS-1]                                     ex3_wNComp_tid;
wire                                                    ex3_wNComp_rcvd;
wire                                                    ex4_wNComp_rcvd_d;
wire                                                    ex4_wNComp_rcvd_q;
wire                                                    ex4_wNComp_d;
wire                                                    ex4_wNComp_q;
wire                                                    ex5_wNComp_d;
wire                                                    ex5_wNComp_q;
wire                                                    ex5_wNComp_cr_upd_d;
wire                                                    ex5_wNComp_cr_upd_q;
wire                                                    ex4_wNComp_excp_restart;
wire                                                    ex4_2younger_restart;
wire                                                    ex5_flush_req;
wire                                                    ex5_blk_tlb_req;
wire                                                    ex5_flush_pfetch;
wire [0:1]                                              ex5_dvc_en_d;
wire [0:1]                                              ex5_dvc_en_q;
wire [0:1]                                              ex6_dvc_en_d;
wire [0:1]                                              ex6_dvc_en_q;
wire                                                    ex4_is_inval_op_d;
wire                                                    ex4_is_inval_op_q;
wire [0:15]                                             op_sel;
wire [0:15]                                             beC840_en;
wire [0:15]                                             be3210_en;
wire [0:15]                                             byte_en;
wire [0:15]                                             ex3_byte_en;
wire                                                    ex2_sfx_val_d;
wire                                                    ex2_sfx_val_q;
wire                                                    ex3_sfx_val_d;
wire                                                    ex3_sfx_val_q;
wire                                                    ex4_sfx_val_d;
wire                                                    ex4_sfx_val_q;
wire                                                    ex2_ucode_val_d;
wire                                                    ex2_ucode_val_q;
wire                                                    ex3_ucode_val_d;
wire                                                    ex3_ucode_val_q;
wire                                                    ex4_ucode_val_d;
wire                                                    ex4_ucode_val_q;
wire                                                    ex6_lq_comp_rpt_d;
wire                                                    ex6_lq_comp_rpt_q;
wire [0:`THREADS-1]                                     lq0_iu_execute_vld_d;
wire [0:`THREADS-1]                                     lq0_iu_execute_vld_q;
wire [0:`ITAG_SIZE_ENC-1]                               lq0_iu_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               lq0_iu_itag_q;
wire                                                    lq0_iu_flush2ucode_type_d;
wire                                                    lq0_iu_flush2ucode_type_q;
wire [0:`THREADS-1]                                     lq0_iu_recirc_val_d;
wire [0:`THREADS-1]                                     lq0_iu_recirc_val_q;
wire                                                    lq0_iu_flush2ucode_d;
wire                                                    lq0_iu_flush2ucode_q;
wire [0:`THREADS-1]                                     lq0_iu_dear_val_d;
wire [0:`THREADS-1]                                     lq0_iu_dear_val_q;
wire [64-(2**`GPR_WIDTH_ENC):63]                        lq0_iu_eff_addr_d;
wire [64-(2**`GPR_WIDTH_ENC):63]                        lq0_iu_eff_addr_q;
wire                                                    lq0_iu_n_flush_d;
wire                                                    lq0_iu_n_flush_q;
wire                                                    lq0_iu_np1_flush_d;
wire                                                    lq0_iu_np1_flush_q;
wire                                                    lq0_iu_exception_val_d;
wire                                                    lq0_iu_exception_val_q;
wire [0:5]                                              lq0_iu_exception_d;
wire [0:5]                                              lq0_iu_exception_q;
wire                                                    lq0_iu_dacr_type_d;
wire                                                    lq0_iu_dacr_type_q;
wire [0:3]                                              lq0_iu_dacrw_d;
wire [0:3]                                              lq0_iu_dacrw_q;
wire [0:31]                                             lq0_iu_instr_d;
wire [0:31]                                             lq0_iu_instr_q;
wire                                                    ex4_spec_load_miss;
wire                                                    ex5_spec_load_miss_d;
wire                                                    ex5_spec_load_miss_q;
wire                                                    ex5_spec_itag_vld_d;
wire                                                    ex5_spec_itag_vld_q;
wire [0:`ITAG_SIZE_ENC-1]                               ex4_spec_itag;
wire [0:`THREADS-1]                                     ex4_spec_thrd_id;
wire [0:`ITAG_SIZE_ENC-1]                               ex5_spec_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               ex5_spec_itag_q;
wire [0:`THREADS-1]                                     ex5_spec_tid_d;
wire [0:`THREADS-1]                                     ex5_spec_tid_q;
wire                                                    ex4_guarded_load;
wire                                                    ex5_blk_pf_load_d;
wire                                                    ex5_blk_pf_load_q;
wire                                                    ex4_lq_wNComp_req;
wire                                                    ex4_wNcomp_oth;
wire                                                    ex4_wNComp_req;
wire                                                    ex5_lq_wNComp_val_d;
wire                                                    ex5_lq_wNComp_val_q;
wire                                                    ex6_lq_wNComp_val_d;
wire                                                    ex6_lq_wNComp_val_q;
wire                                                    ex5_wNComp_ord_d;
wire                                                    ex5_wNComp_ord_q;
wire                                                    ex3_lswx_restart;
wire                                                    ex4_lswx_restart_d;
wire                                                    ex4_lswx_restart_q;
wire                                                    ex3_icswx_restart;
wire                                                    ex4_icswx_restart_d;
wire                                                    ex4_icswx_restart_q;
wire                                                    ex4_restart_val;
wire                                                    ex5_restart_val_d;
wire                                                    ex5_restart_val_q;
wire                                                    ex5_derat_restart_d;
wire                                                    ex5_derat_restart_q;
wire                                                    ex6_derat_restart_d;
wire                                                    ex6_derat_restart_q;
wire                                                    ex5_dir_restart_d;
wire                                                    ex5_dir_restart_q;
wire                                                    ex6_dir_restart_d;
wire                                                    ex6_dir_restart_q;
wire                                                    ex5_dec_restart_d;
wire                                                    ex5_dec_restart_q;
wire                                                    ex6_dec_restart_d;
wire                                                    ex6_dec_restart_q;
wire                                                    ex4_derat_itagHit_d;
wire                                                    ex4_derat_itagHit_q;
wire                                                    ex6_stq_restart_val_d;
wire                                                    ex6_stq_restart_val_q;
wire                                                    ex6_restart_val_d;
wire                                                    ex6_restart_val_q;
wire                                                    ex5_execute_vld;
wire                                                    ex5_execute_vld_d;
wire                                                    ex5_execute_vld_q;
wire                                                    ex5_flush2ucode_type_d;
wire                                                    ex5_flush2ucode_type_q;
wire                                                    ex5_recirc_val;
wire                                                    ex5_recirc_val_d;
wire                                                    ex5_recirc_val_q;
wire [0:`THREADS-1]                                     lq0_rpt_thrd_id;
wire                                                    ex5_wchkall_cplt;
wire                                                    ex5_wchkall_cplt_d;
wire                                                    ex5_wchkall_cplt_q;
wire                                                    ex6_misalign_flush_d;
wire                                                    ex6_misalign_flush_q;
wire [0:`THREADS-1]                                     ldq_idle_d;
wire [0:`THREADS-1]                                     ldq_idle_q;
wire                                                    ex5_lq_comp_rpt_val;
wire                                                    ex5_restart_val;
wire                                                    ex5_lq_req_abort;
wire                                                    ex5_ldq_restart_val;
wire                                                    ex5_stq_restart_miss;
wire                                                    ex5_stq_restart_val;
wire                                                    ex4_is_sync_d;
wire                                                    ex4_is_sync_q;
wire                                                    ex4_l1_lock_set_d;
wire                                                    ex4_l1_lock_set_q;
wire                                                    ex5_l1_lock_set_d;
wire                                                    ex5_l1_lock_set_q;
wire                                                    ex4_lock_clr_d;
wire                                                    ex4_lock_clr_q;
wire                                                    ex5_lock_clr_d;
wire                                                    ex5_lock_clr_q;
wire                                                    rel2_xu_wren_d;
wire                                                    rel2_xu_wren_q;
wire                                                    stq2_store_val_d;
wire                                                    stq2_store_val_q;
wire                                                    stq3_store_val_d;
wire                                                    stq3_store_val_q;
wire                                                    stq4_store_val_d;
wire                                                    stq4_store_val_q;
wire                                                    stq2_ci_d;
wire                                                    stq2_ci_q;
wire                                                    stq3_ci_d;
wire                                                    stq3_ci_q;
wire                                                    stq2_resv_d;
wire                                                    stq2_resv_q;
wire                                                    stq3_resv_d;
wire                                                    stq3_resv_q;
wire                                                    stq2_wclr_val_d;
wire                                                    stq2_wclr_val_q;
wire                                                    stq3_wclr_val_d;
wire                                                    stq3_wclr_val_q;
wire                                                    stq4_wclr_val_d;
wire                                                    stq4_wclr_val_q;
wire                                                    stq2_wclr_all_set_d;
wire                                                    stq2_wclr_all_set_q;
wire                                                    stq3_wclr_all_set_d;
wire                                                    stq3_wclr_all_set_q;
wire                                                    stq4_wclr_all_set_d;
wire                                                    stq4_wclr_all_set_q;
wire                                                    stq4_rec_stcx_d;
wire                                                    stq4_rec_stcx_q;
wire [0:`ITAG_SIZE_ENC-1]                               stq6_itag_d;
wire [0:`ITAG_SIZE_ENC-1]                               stq6_itag_q;
wire [0:AXU_TARGET_ENC-1]                               stq6_tgpr_d;
wire [0:AXU_TARGET_ENC-1]                               stq6_tgpr_q;
wire [0:`THREADS-1]                                     stq2_thrd_id_d;
wire [0:`THREADS-1]                                     stq2_thrd_id_q;
wire [0:`THREADS-1]                                     stq3_thrd_id_d;
wire [0:`THREADS-1]                                     stq3_thrd_id_q;
wire [0:`THREADS-1]                                     stq4_thrd_id_d;
wire [0:`THREADS-1]                                     stq4_thrd_id_q;
wire [0:`THREADS-1]                                     stq5_thrd_id_d;
wire [0:`THREADS-1]                                     stq5_thrd_id_q;
wire [0:`THREADS-1]                                     stq6_thrd_id_d;
wire [0:`THREADS-1]                                     stq6_thrd_id_q;
wire [0:`THREADS-1]                                     stq7_thrd_id_d;
wire [0:`THREADS-1]                                     stq7_thrd_id_q;
wire [0:`THREADS-1]                                     stq8_thrd_id_d;
wire [0:`THREADS-1]                                     stq8_thrd_id_q;
wire                                                    stq2_epid_val_d;
wire                                                    stq2_epid_val_q;
wire                                                    stq2_mftgpr_val_d;
wire                                                    stq2_mftgpr_val_q;
wire                                                    stq3_mftgpr_val_d;
wire                                                    stq3_mftgpr_val_q;
wire                                                    stq4_mftgpr_val_d;
wire                                                    stq4_mftgpr_val_q;
wire                                                    stq5_mftgpr_val_d;
wire                                                    stq5_mftgpr_val_q;
wire                                                    stq6_mftgpr_val_d;
wire                                                    stq6_mftgpr_val_q;
wire                                                    stq7_mftgpr_val_d;
wire                                                    stq7_mftgpr_val_q;
wire                                                    stq8_mftgpr_val_d;
wire                                                    stq8_mftgpr_val_q;
wire                                                    stq2_mfdpf_val_d;
wire                                                    stq2_mfdpf_val_q;
wire                                                    stq3_mfdpf_val_d;
wire                                                    stq3_mfdpf_val_q;
wire                                                    stq4_mfdpf_val_d;
wire                                                    stq4_mfdpf_val_q;
wire                                                    stq5_mfdpf_val_d;
wire                                                    stq5_mfdpf_val_q;
wire                                                    stq2_mfdpa_val_d;
wire                                                    stq2_mfdpa_val_q;
wire                                                    stq3_mfdpa_val_d;
wire                                                    stq3_mfdpa_val_q;
wire                                                    stq4_mfdpa_val_d;
wire                                                    stq4_mfdpa_val_q;
wire                                                    stq5_mfdpa_val_d;
wire                                                    stq5_mfdpa_val_q;
wire                                                    stq6_mfdpa_val_d;
wire                                                    stq6_mfdpa_val_q;
wire [0:`CR_POOL_ENC-1]                                 ex2_cr_fld_d;
wire [0:`CR_POOL_ENC-1]                                 ex2_cr_fld_q;
wire [0:`CR_POOL_ENC-1]                                 ex3_cr_fld_d;
wire [0:`CR_POOL_ENC-1]                                 ex3_cr_fld_q;
wire [0:`CR_POOL_ENC-1]                                 ex4_cr_fld_d;
wire [0:`CR_POOL_ENC-1]                                 ex4_cr_fld_q;
wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]               ex5_cr_fld_d;
wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1]               ex5_cr_fld_q;
wire                                                    ex4_cr_sel;
wire [0:AXU_TARGET_ENC-1]                               ex4_cr_fld;
wire [0:`CR_WIDTH-1]                                    ex5_cr_wd;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex2_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex2_ucode_cnt_q;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex3_ucode_cnt_d;
wire [0:`UCODE_ENTRIES_ENC-1]                           ex3_ucode_cnt_q;
wire                                                    ex2_ucode_op_d;
wire                                                    ex2_ucode_op_q;
wire                                                    ex3_ucode_op_d;
wire                                                    ex3_ucode_op_q;
wire                                                    ex4_ucode_op_d;
wire                                                    ex4_ucode_op_q;
wire                                                    ex4_cline_chk;
wire                                                    ex4_send_l2;
wire                                                    ex4_has_data;
wire                                                    ex4_dReq_val;
wire                                                    ex4_excp_rpt_val;
wire                                                    ex4_ucode_rpt;
wire                                                    ex4_ucode_rpt_val;
wire                                                    ex4_mffgpr_rpt_val;
wire                                                    ex4_ucode_restart;
wire                                                    ex4_sfx_excpt_det;
wire                                                    ex4_excp_det;
wire                                                    ex4_wNComp_excp;
wire                                                    dir_arr_rd_rv1_done;
wire [0:1]                                              dir_arr_rd_cntrl;
wire                                                    dir_arr_rd_val_d;
wire                                                    dir_arr_rd_val_q;
wire [0:`THREADS-1]                                     dir_arr_rd_tid_d;
wire [0:`THREADS-1]                                     dir_arr_rd_tid_q;
wire                                                    dir_arr_rd_rv1_val_d;
wire                                                    dir_arr_rd_rv1_val_q;
wire                                                    dir_arr_rd_ex0_done_d;
wire                                                    dir_arr_rd_ex0_done_q;
wire                                                    dir_arr_rd_ex1_done_d;
wire                                                    dir_arr_rd_ex1_done_q;
wire                                                    dir_arr_rd_ex2_done_d;
wire                                                    dir_arr_rd_ex2_done_q;
wire                                                    dir_arr_rd_ex3_done_d;
wire                                                    dir_arr_rd_ex3_done_q;
wire                                                    dir_arr_rd_ex4_done_d;
wire                                                    dir_arr_rd_ex4_done_q;
wire                                                    dir_arr_rd_ex5_done_d;
wire                                                    dir_arr_rd_ex5_done_q;
wire                                                    dir_arr_rd_ex6_done_d;
wire                                                    dir_arr_rd_ex6_done_q;
wire                                                    dir_arr_rd_busy;
wire [0:`THREADS-1]                                     dir_arr_rd_tid_busy;
wire [64-`REAL_IFAR_WIDTH:63-(`DC_SIZE-3)]              dir_arr_rd_tag;
wire [0:1+`THREADS]                                     dir_arr_rd_directory;
wire [0:PARBITS-1]                                      dir_arr_rd_parity;
wire [0:6]                                              dir_arr_rd_lru;
wire                                                    ex4_dacrw1_cmpr;
wire                                                    ex4_dacrw2_cmpr;
wire                                                    ex4_dacrw3_cmpr;
wire                                                    ex4_dacrw4_cmpr;
wire                                                    ex5_dacrw_rpt_val;
wire [0:3]                                              ex5_dacrw_cmpr;
wire [0:3]                                              ex5_dacrw_cmpr_d;
wire [0:3]                                              ex5_dacrw_cmpr_q;
wire [0:3]                                              ex6_dacrw_cmpr_d;
wire [0:3]                                              ex6_dacrw_cmpr_q;
wire                                                    ex4_dac_int_det;
wire                                                    ex4_dbg_int_en;
wire                                                    ex5_flush2ucode;
wire                                                    ex5_n_flush;
wire                                                    ex5_np1_flush;
wire                                                    ex5_exception_val;
wire [0:5]                                              ex5_exception;
wire [0:`THREADS-1]                                     ex5_dear_val;
wire                                                    ex5_misalign_flush;
wire [0:`THREADS-1]                                     lq_ram_data_val;
wire [0:`THREADS-1]                                     ex6_ram_thrd;
wire [0:`THREADS-1]                                     ex6_ram_active_thrd;
wire [0:`THREADS-1]                                     stq8_ram_thrd;
wire [0:`THREADS-1]                                     stq8_ram_active_thrd;
wire [0:`THREADS-1]                                     rel2_ram_thrd;
wire [0:`THREADS-1]                                     rel2_ram_active_thrd;
wire [0:`THREADS-1]                                     pc_lq_ram_active_d;
wire [0:`THREADS-1]                                     pc_lq_ram_active_q;
wire                                                    lq_pc_ram_data_val_d;
wire                                                    lq_pc_ram_data_val_q;
wire                                                    ex1_instr_act;
wire                                                    ex1_stg_act;
wire                                                    ex1_stg_act_d;
wire                                                    ex1_stg_act_q;
wire                                                    ex2_stg_act_d;
wire                                                    ex2_stg_act_q;
wire                                                    ex3_stg_act_d;
wire                                                    ex3_stg_act_q;
wire                                                    ex4_stg_act_d;
wire                                                    ex4_stg_act_q;
wire                                                    ex5_stg_act_d;
wire                                                    ex5_stg_act_q;
wire                                                    ex6_stg_act_d;
wire                                                    ex6_stg_act_q;
wire                                                    binv1_stg_act;
wire                                                    binv2_stg_act_d;
wire                                                    binv2_stg_act_q;
wire                                                    binv3_stg_act_d;
wire                                                    binv3_stg_act_q;
wire                                                    binv4_stg_act_d;
wire                                                    binv4_stg_act_q;
wire                                                    binv5_stg_act_d;
wire                                                    binv5_stg_act_q;
wire                                                    binv6_stg_act_d;
wire                                                    binv6_stg_act_q;
wire                                                    ex2_binv2_stg_act;
wire                                                    ex3_binv3_stg_act;
wire                                                    ex4_binv4_stg_act;
wire                                                    ex5_binv5_stg_act;
wire                                                    ex6_binv6_stg_act;
wire                                                    ex4_darr_rd_act;
wire                                                    ex5_darr_rd_act;
wire                                                    lq0_iu_act;
wire                                                    stq1_stg_act;
wire                                                    stq2_stg_act_d;
wire                                                    stq2_stg_act_q;
wire                                                    stq3_stg_act_d;
wire                                                    stq3_stg_act_q;
wire                                                    stq4_stg_act_d;
wire                                                    stq4_stg_act_q;
wire                                                    stq5_stg_act_d;
wire                                                    stq5_stg_act_q;

wire                                                    fgen_ex1_stg_flush_int;
wire                                                    fgen_ex2_stg_flush_int;
wire                                                    fgen_ex3_stg_flush_int;
wire                                                    fgen_ex4_stg_flush_int;
wire                                                    fgen_ex5_stg_flush_int;
wire                                                    fgen_ex4_cp_flush_int;
wire                                                    fgen_ex5_cp_flush;
wire                                                    fgen_scan_in;
wire                                                    fgen_scan_out;

//--------------------------
// register constants
//--------------------------
parameter                                               iu_lq_recirc_val_offset = 0;
parameter                                               iu_lq_cp_next_itag_offset = iu_lq_recirc_val_offset + `THREADS;
parameter                                               iu_lq_cp_flush_offset = iu_lq_cp_next_itag_offset + (`THREADS*`ITAG_SIZE_ENC);
parameter                                               xer_lq_cp_rd_so_offset = iu_lq_cp_flush_offset + `THREADS;
parameter                                               ex0_i0_vld_offset = xer_lq_cp_rd_so_offset + `THREADS;
parameter                                               ex0_i0_ucode_preissue_offset = ex0_i0_vld_offset + `THREADS;
parameter                                               ex0_i0_2ucode_offset = ex0_i0_ucode_preissue_offset + 1;
parameter                                               ex0_i0_ucode_cnt_offset = ex0_i0_2ucode_offset + 1;
parameter                                               ex0_i1_vld_offset = ex0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                               ex0_i1_ucode_preissue_offset = ex0_i1_vld_offset + `THREADS;
parameter                                               ex0_i1_2ucode_offset = ex0_i1_ucode_preissue_offset + 1;
parameter                                               ex0_i1_ucode_cnt_offset = ex0_i1_2ucode_offset + 1;
parameter                                               ex2_optype1_offset = ex0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                               ex2_optype2_offset = ex2_optype1_offset + 1;
parameter                                               ex2_optype4_offset = ex2_optype2_offset + 1;
parameter                                               ex2_optype8_offset = ex2_optype4_offset + 1;
parameter                                               ex2_optype16_offset = ex2_optype8_offset + 1;
parameter						                        ex3_optype1_offset = ex2_optype16_offset + 1;
parameter                                               ex3_optype2_offset = ex3_optype1_offset + 1;
parameter                                               ex3_optype4_offset = ex3_optype2_offset + 1;
parameter                                               ex3_optype8_offset = ex3_optype4_offset + 1;
parameter                                               ex3_optype16_offset = ex3_optype8_offset + 1;
parameter						                        ex3_dacr_type_offset = ex3_optype16_offset + 1;
parameter                                               ex4_dacr_type_offset = ex3_dacr_type_offset + 1;
parameter						                        ex5_dacr_type_offset = ex4_dacr_type_offset + 1;
parameter                                               ex2_cache_acc_offset = ex5_dacr_type_offset + 1;
parameter                                               ex3_cache_acc_offset = ex2_cache_acc_offset + 1;
parameter                                               ex4_cache_acc_offset = ex3_cache_acc_offset + 1;
parameter                                               ex5_cache_acc_offset = ex4_cache_acc_offset + 1;
parameter                                               ex6_cache_acc_offset = ex5_cache_acc_offset + 1;
parameter                                               ex2_thrd_id_offset = ex6_cache_acc_offset + 1;
parameter                                               ex3_thrd_id_offset = ex2_thrd_id_offset + `THREADS;
parameter                                               ex4_thrd_id_offset = ex3_thrd_id_offset + `THREADS;
parameter                                               ex5_thrd_id_offset = ex4_thrd_id_offset + `THREADS;
parameter                                               ex6_thrd_id_offset = ex5_thrd_id_offset + `THREADS;
parameter                                               ex2_instr_offset = ex6_thrd_id_offset + `THREADS;
parameter                                               ex3_instr_offset = ex2_instr_offset + 32;
parameter                                               ex4_instr_offset = ex3_instr_offset + 32;
parameter                                               ex5_instr_offset = ex4_instr_offset + 32;
parameter                                               ex2_target_gpr_offset = ex5_instr_offset + 32;
parameter                                               ex3_target_gpr_offset = ex2_target_gpr_offset + AXU_TARGET_ENC;
parameter                                               ex4_target_gpr_offset = ex3_target_gpr_offset + AXU_TARGET_ENC;
parameter                                               ex5_target_gpr_offset = ex4_target_gpr_offset + AXU_TARGET_ENC;
parameter                                               ex2_dcbt_instr_offset = ex5_target_gpr_offset + AXU_TARGET_ENC;
parameter                                               ex3_dcbt_instr_offset = ex2_dcbt_instr_offset + 1;
parameter                                               ex4_dcbt_instr_offset = ex3_dcbt_instr_offset + 1;
parameter                                               ex2_pfetch_val_offset = ex4_dcbt_instr_offset + 1;
parameter                                               ex3_pfetch_val_offset = ex2_pfetch_val_offset + 1;
parameter                                               ex4_pfetch_val_offset = ex3_pfetch_val_offset + 1;
parameter                                               ex5_pfetch_val_offset = ex4_pfetch_val_offset + 1;
parameter                                               ex6_pfetch_val_offset = ex5_pfetch_val_offset + 1;
parameter                                               ex2_dcbtst_instr_offset = ex6_pfetch_val_offset + 1;
parameter                                               ex3_dcbtst_instr_offset = ex2_dcbtst_instr_offset + 1;
parameter                                               ex4_dcbtst_instr_offset = ex3_dcbtst_instr_offset + 1;
parameter                                               ex2_wchk_instr_offset = ex4_dcbtst_instr_offset + 1;
parameter                                               ex3_wchk_instr_offset = ex2_wchk_instr_offset + 1;
parameter                                               ex4_wchk_instr_offset = ex3_wchk_instr_offset + 1;
parameter                                               ex2_dcbst_instr_offset = ex4_wchk_instr_offset + 1;
parameter                                               ex3_dcbst_instr_offset = ex2_dcbst_instr_offset + 1;
parameter                                               ex4_dcbst_instr_offset = ex3_dcbst_instr_offset + 1;
parameter                                               ex2_dcbf_instr_offset = ex4_dcbst_instr_offset + 1;
parameter                                               ex3_dcbf_instr_offset = ex2_dcbf_instr_offset + 1;
parameter                                               ex4_dcbf_instr_offset = ex3_dcbf_instr_offset + 1;
parameter                                               ex2_mtspr_trace_offset = ex4_dcbf_instr_offset + 1;
parameter                                               ex3_mtspr_trace_offset = ex2_mtspr_trace_offset + 1;
parameter                                               ex4_mtspr_trace_offset = ex3_mtspr_trace_offset + 1;
parameter                                               ex2_sync_instr_offset = ex4_mtspr_trace_offset + 1;
parameter                                               ex3_sync_instr_offset = ex2_sync_instr_offset + 1;
parameter                                               ex4_sync_instr_offset = ex3_sync_instr_offset + 1;
parameter                                               ex2_l_fld_offset = ex4_sync_instr_offset + 1;
parameter                                               ex3_l_fld_offset = ex2_l_fld_offset + 2;
parameter                                               ex4_l_fld_offset = ex3_l_fld_offset + 2;
parameter                                               ex5_l_fld_offset = ex4_l_fld_offset + 2;
parameter                                               ex2_dcbi_instr_offset = ex5_l_fld_offset + 2;
parameter                                               ex3_dcbi_instr_offset = ex2_dcbi_instr_offset + 1;
parameter                                               ex4_dcbi_instr_offset = ex3_dcbi_instr_offset + 1;
parameter                                               ex2_dcbz_instr_offset = ex4_dcbi_instr_offset + 1;
parameter                                               ex3_dcbz_instr_offset = ex2_dcbz_instr_offset + 1;
parameter                                               ex4_dcbz_instr_offset = ex3_dcbz_instr_offset + 1;
parameter                                               ex2_icbi_instr_offset = ex4_dcbz_instr_offset + 1;
parameter                                               ex3_icbi_instr_offset = ex2_icbi_instr_offset + 1;
parameter                                               ex4_icbi_instr_offset = ex3_icbi_instr_offset + 1;
parameter                                               ex2_mbar_instr_offset = ex4_icbi_instr_offset + 1;
parameter                                               ex3_mbar_instr_offset = ex2_mbar_instr_offset + 1;
parameter                                               ex4_mbar_instr_offset = ex3_mbar_instr_offset + 1;
parameter                                               ex2_makeitso_instr_offset = ex4_mbar_instr_offset + 1;
parameter                                               ex3_makeitso_instr_offset = ex2_makeitso_instr_offset + 1;
parameter                                               ex4_makeitso_instr_offset = ex3_makeitso_instr_offset + 1;
parameter                                               ex2_dci_instr_offset = ex4_makeitso_instr_offset + 1;
parameter                                               ex3_dci_instr_offset = ex2_dci_instr_offset + 1;
parameter                                               ex4_dci_instr_offset = ex3_dci_instr_offset + 1;
parameter                                               ex2_ici_instr_offset = ex4_dci_instr_offset + 1;
parameter                                               ex3_ici_instr_offset = ex2_ici_instr_offset + 1;
parameter                                               ex4_ici_instr_offset = ex3_ici_instr_offset + 1;
parameter                                               ex2_algebraic_offset = ex4_ici_instr_offset + 1;
parameter                                               ex3_algebraic_offset = ex2_algebraic_offset + 1;
parameter                                               ex2_strg_index_offset = ex3_algebraic_offset + 1;
parameter                                               ex3_strg_index_offset = ex2_strg_index_offset + 1;
parameter                                               ex4_strg_index_offset = ex3_strg_index_offset + 1;
parameter                                               ex2_resv_instr_offset = ex4_strg_index_offset + 1;
parameter                                               ex3_resv_instr_offset = ex2_resv_instr_offset + 1;
parameter                                               ex4_resv_instr_offset = ex3_resv_instr_offset + 1;
parameter                                               ex2_mutex_hint_offset = ex4_resv_instr_offset + 1;
parameter                                               ex3_mutex_hint_offset = ex2_mutex_hint_offset + 1;
parameter                                               ex4_mutex_hint_offset = ex3_mutex_hint_offset + 1;
parameter                                               ex2_load_instr_offset = ex4_mutex_hint_offset + 1;
parameter                                               ex3_load_instr_offset = ex2_load_instr_offset + 1;
parameter                                               ex4_load_instr_offset = ex3_load_instr_offset + 1;
parameter                                               ex2_store_instr_offset = ex4_load_instr_offset + 1;
parameter                                               ex3_store_instr_offset = ex2_store_instr_offset + 1;
parameter                                               ex4_store_instr_offset = ex3_store_instr_offset + 1;
parameter                                               ex4_le_mode_offset = ex4_store_instr_offset + 1;
parameter						                        ex5_wimge_i_bits_offset = ex4_le_mode_offset + 1;
parameter                                               ex2_axu_op_val_offset = ex5_wimge_i_bits_offset + 1;
parameter                                               ex3_axu_op_val_offset = ex2_axu_op_val_offset + 1;
parameter                                               ex4_axu_op_val_offset = ex3_axu_op_val_offset + 1;
parameter                                               ex5_axu_op_val_offset = ex4_axu_op_val_offset + 1;
parameter                                               ex2_upd_form_offset = ex5_axu_op_val_offset + 1;
parameter						                        ex3_upd_form_offset = ex2_upd_form_offset + 1;
parameter                                               ex2_axu_instr_type_offset = ex3_upd_form_offset + 1;
parameter                                               ex3_axu_instr_type_offset = ex2_axu_instr_type_offset + 3;
parameter						                        ex5_load_hit_offset = ex3_axu_instr_type_offset + 3;
parameter                                               ex6_load_hit_offset = ex5_load_hit_offset + 1;
parameter						                        ex5_usr_bits_offset = ex6_load_hit_offset + 1;
parameter						                        ex5_classid_offset = ex5_usr_bits_offset + 4;
parameter						                        ex5_derat_setHold_offset = ex5_classid_offset + 2;
parameter						                        ex5_axu_wren_offset = ex5_derat_setHold_offset + 1;
parameter                                               ex6_axu_wren_offset = ex5_axu_wren_offset + 1;
parameter						                        ex5_lq_ta_gpr_offset = ex6_axu_wren_offset + 1;
parameter                                               ex6_lq_ta_gpr_offset = ex5_lq_ta_gpr_offset + AXU_TARGET_ENC;
parameter						                        ex5_load_le_offset = ex6_lq_ta_gpr_offset + (`GPR_POOL_ENC+`THREADS_POOL_ENC);
parameter                                               ex2_th_fld_c_offset = ex5_load_le_offset + 1;
parameter                                               ex3_th_fld_c_offset = ex2_th_fld_c_offset + 1;
parameter                                               ex4_th_fld_c_offset = ex3_th_fld_c_offset + 1;
parameter                                               ex2_th_fld_l2_offset = ex4_th_fld_c_offset + 1;
parameter                                               ex3_th_fld_l2_offset = ex2_th_fld_l2_offset + 1;
parameter                                               ex4_th_fld_l2_offset = ex3_th_fld_l2_offset + 1;
parameter                                               ex2_dcbtls_instr_offset = ex4_th_fld_l2_offset + 1;
parameter                                               ex3_dcbtls_instr_offset = ex2_dcbtls_instr_offset + 1;
parameter                                               ex4_dcbtls_instr_offset = ex3_dcbtls_instr_offset + 1;
parameter                                               ex2_dcbtstls_instr_offset = ex4_dcbtls_instr_offset + 1;
parameter                                               ex3_dcbtstls_instr_offset = ex2_dcbtstls_instr_offset + 1;
parameter                                               ex4_dcbtstls_instr_offset = ex3_dcbtstls_instr_offset + 1;
parameter                                               ex2_dcblc_instr_offset = ex4_dcbtstls_instr_offset + 1;
parameter                                               ex3_dcblc_instr_offset = ex2_dcblc_instr_offset + 1;
parameter                                               ex4_dcblc_instr_offset = ex3_dcblc_instr_offset + 1;
parameter                                               ex2_icblc_l2_instr_offset = ex4_dcblc_instr_offset + 1;
parameter                                               ex3_icblc_l2_instr_offset = ex2_icblc_l2_instr_offset + 1;
parameter                                               ex4_icblc_l2_instr_offset = ex3_icblc_l2_instr_offset + 1;
parameter                                               ex2_icbt_l2_instr_offset = ex4_icblc_l2_instr_offset + 1;
parameter                                               ex3_icbt_l2_instr_offset = ex2_icbt_l2_instr_offset + 1;
parameter                                               ex4_icbt_l2_instr_offset = ex3_icbt_l2_instr_offset + 1;
parameter                                               ex2_icbtls_l2_instr_offset = ex4_icbt_l2_instr_offset + 1;
parameter                                               ex3_icbtls_l2_instr_offset = ex2_icbtls_l2_instr_offset + 1;
parameter                                               ex4_icbtls_l2_instr_offset = ex3_icbtls_l2_instr_offset + 1;
parameter                                               ex2_tlbsync_instr_offset = ex4_icbtls_l2_instr_offset + 1;
parameter                                               ex3_tlbsync_instr_offset = ex2_tlbsync_instr_offset + 1;
parameter                                               ex4_tlbsync_instr_offset = ex3_tlbsync_instr_offset + 1;
parameter                                               ex2_ldst_falign_offset = ex4_tlbsync_instr_offset + 1;
parameter                                               ex2_ldst_fexcpt_offset = ex2_ldst_falign_offset + 1;
parameter						                        ex3_ldst_fexcpt_offset = ex2_ldst_fexcpt_offset + 1;
parameter						                        ex5_load_miss_offset = ex3_ldst_fexcpt_offset + 1;
parameter                                               xudbg1_dir_reg_offset = ex5_load_miss_offset + 1;
parameter                                               xudbg1_parity_reg_offset = xudbg1_dir_reg_offset + (9+`THREADS);
parameter                                               xudbg2_tag_offset = xudbg1_parity_reg_offset + PARBITS;
parameter                                               stq4_dcarr_wren_offset = xudbg2_tag_offset + TAGSIZE;
parameter                                               ex2_sgpr_instr_offset = stq4_dcarr_wren_offset + 1;
parameter                                               ex2_saxu_instr_offset = ex2_sgpr_instr_offset + 1;
parameter                                               ex2_sdp_instr_offset = ex2_saxu_instr_offset + 1;
parameter                                               ex2_tgpr_instr_offset = ex2_sdp_instr_offset + 1;
parameter                                               ex2_taxu_instr_offset = ex2_tgpr_instr_offset + 1;
parameter                                               ex2_tdp_instr_offset = ex2_taxu_instr_offset + 1;
parameter                                               ex3_sgpr_instr_offset = ex2_tdp_instr_offset + 1;
parameter                                               ex3_saxu_instr_offset = ex3_sgpr_instr_offset + 1;
parameter                                               ex3_sdp_instr_offset = ex3_saxu_instr_offset + 1;
parameter                                               ex3_tgpr_instr_offset = ex3_sdp_instr_offset + 1;
parameter                                               ex3_taxu_instr_offset = ex3_tgpr_instr_offset + 1;
parameter                                               ex3_tdp_instr_offset = ex3_taxu_instr_offset + 1;
parameter                                               ex4_sgpr_instr_offset = ex3_tdp_instr_offset + 1;
parameter                                               ex4_saxu_instr_offset = ex4_sgpr_instr_offset + 1;
parameter                                               ex4_sdp_instr_offset = ex4_saxu_instr_offset + 1;
parameter                                               ex4_tgpr_instr_offset = ex4_sdp_instr_offset + 1;
parameter                                               ex4_taxu_instr_offset = ex4_tgpr_instr_offset + 1;
parameter                                               ex4_tdp_instr_offset = ex4_taxu_instr_offset + 1;
parameter						                        ex5_mftgpr_val_offset = ex4_tdp_instr_offset + 1;
parameter                                               ex4_moveOp_val_offset = ex5_mftgpr_val_offset + 1;
parameter                                               stq6_moveOp_val_offset = ex4_moveOp_val_offset + 1;
parameter						                        ex3_undef_touch_offset = stq6_moveOp_val_offset + 1;
parameter                                               ex4_undef_touch_offset = ex3_undef_touch_offset + 1;
parameter                                               ex4_blkable_touch_offset = ex4_undef_touch_offset + 1;
parameter                                               ex5_blk_touch_offset = ex4_blkable_touch_offset + 1;
parameter                                               ex6_blk_touch_offset = ex5_blk_touch_offset + 1;
parameter                                               ex3_eff_addr_offset = ex6_blk_touch_offset + 1;
parameter                                               ex4_eff_addr_offset = ex3_eff_addr_offset + (2**`GPR_WIDTH_ENC);
parameter                                               ex5_eff_addr_offset = ex4_eff_addr_offset + (2**`GPR_WIDTH_ENC);
parameter						                        ex3_undef_lockset_offset = ex5_eff_addr_offset + (2**`GPR_WIDTH_ENC);
parameter                                               ex4_undef_lockset_offset = ex3_undef_lockset_offset + 1;
parameter						                        ex5_unable_2lock_offset = ex4_undef_lockset_offset + 1;
parameter                                               ex6_stq5_unable_2lock_offset = ex5_unable_2lock_offset + 1;
parameter						                        ex5_dacrw_cmpr_offset = ex6_stq5_unable_2lock_offset + 1;
parameter                                               ex6_dacrw_cmpr_offset = ex5_dacrw_cmpr_offset + 4;
parameter						                        ex3_stq_val_req_offset = ex6_dacrw_cmpr_offset + 4;
parameter                                               ex4_stq_val_req_offset = ex3_stq_val_req_offset + 1;
parameter						                        ex5_load_instr_offset = ex4_stq_val_req_offset + 1;
parameter                                               ex2_mword_instr_offset = ex5_load_instr_offset + 1;
parameter						                        ex3_mword_instr_offset = ex2_mword_instr_offset + 1;
parameter                                               stq4_store_miss_offset = ex3_mword_instr_offset + 1;
parameter						                        ex5_perf_dcbt_offset = stq4_store_miss_offset + 1;
parameter                                               spr_ccr2_ap_offset = ex5_perf_dcbt_offset + 1;
parameter                                               spr_ccr2_en_trace_offset = spr_ccr2_ap_offset + 1;
parameter                                               spr_ccr2_ucode_dis_offset = spr_ccr2_en_trace_offset + 1;
parameter                                               spr_ccr2_notlb_offset = spr_ccr2_ucode_dis_offset + 1;
parameter                                               clkg_ctl_override_offset = spr_ccr2_notlb_offset + 1;
parameter                                               spr_xucr0_wlk_offset = clkg_ctl_override_offset + 1;
parameter                                               spr_xucr0_mbar_ack_offset = spr_xucr0_wlk_offset + 1;
parameter                                               spr_xucr0_tlbsync_offset = spr_xucr0_mbar_ack_offset + 1;
parameter                                               spr_xucr0_dcdis_offset = spr_xucr0_tlbsync_offset + 1;
parameter                                               spr_xucr0_aflsta_offset = spr_xucr0_dcdis_offset + 1;
parameter                                               spr_xucr0_flsta_offset = spr_xucr0_aflsta_offset + 1;
parameter                                               spr_xucr0_mddp_offset = spr_xucr0_flsta_offset + 1;
parameter                                               spr_xucr0_mdcp_offset = spr_xucr0_mddp_offset + 1;
parameter                                               spr_xucr4_mmu_mchk_offset = spr_xucr0_mdcp_offset + 1;
parameter                                               spr_xucr4_mddmh_offset = spr_xucr4_mmu_mchk_offset + 1;
parameter                                               spr_xucr0_en_trace_um_offset = spr_xucr4_mddmh_offset + 1;
parameter						                        ex1_lsu_64bit_mode_offset = spr_xucr0_en_trace_um_offset + `THREADS;
parameter                                               ex2_lsu_64bit_agen_offset = ex1_lsu_64bit_mode_offset + `THREADS;
parameter                                               ex3_lsu_64bit_agen_offset = ex2_lsu_64bit_agen_offset + 1;
parameter                                               ex4_lsu_64bit_agen_offset = ex3_lsu_64bit_agen_offset + 1;
parameter                                               ex4_local_dcbf_offset = ex4_lsu_64bit_agen_offset + 1;
parameter                                               ex2_msgsnd_instr_offset = ex4_local_dcbf_offset + 1;
parameter                                               ex3_msgsnd_instr_offset = ex2_msgsnd_instr_offset + 1;
parameter                                               ex4_msgsnd_instr_offset = ex3_msgsnd_instr_offset + 1;
parameter                                               ex4_load_type_offset = ex4_msgsnd_instr_offset + 1;
parameter                                               ex4_gath_load_offset = ex4_load_type_offset + 1;
parameter                                               ex4_l2load_type_offset = ex4_gath_load_offset + 1;
parameter						                        ex5_lq_wren_offset = ex4_l2load_type_offset + 1;
parameter                                               ex6_lq_wren_offset = ex5_lq_wren_offset + 1;
parameter                                               ex2_ldawx_instr_offset = ex6_lq_wren_offset + 1;
parameter                                               ex3_ldawx_instr_offset = ex2_ldawx_instr_offset + 1;
parameter                                               ex4_ldawx_instr_offset = ex3_ldawx_instr_offset + 1;
parameter                                               ex5_ldawx_instr_offset = ex4_ldawx_instr_offset + 1;
parameter                                               ex2_wclr_instr_offset = ex5_ldawx_instr_offset + 1;
parameter                                               ex3_wclr_instr_offset = ex2_wclr_instr_offset + 1;
parameter                                               ex4_wclr_instr_offset = ex3_wclr_instr_offset + 1;
parameter                                               ex4_opsize_enc_offset = ex4_wclr_instr_offset + 1;
parameter                                               ex5_opsize_enc_offset = ex4_opsize_enc_offset + 3;
parameter                                               ex2_itag_offset = ex5_opsize_enc_offset + 3;
parameter                                               ex3_itag_offset = ex2_itag_offset + `ITAG_SIZE_ENC;
parameter                                               ex4_itag_offset = ex3_itag_offset + `ITAG_SIZE_ENC;
parameter                                               ex5_itag_offset = ex4_itag_offset + `ITAG_SIZE_ENC;
parameter                                               ex6_itag_offset = ex5_itag_offset + `ITAG_SIZE_ENC;
parameter						                        ex5_drop_rel_offset = ex6_itag_offset + `ITAG_SIZE_ENC;
parameter                                               ex2_icswx_instr_offset = ex5_drop_rel_offset + 1;
parameter                                               ex3_icswx_instr_offset = ex2_icswx_instr_offset + 1;
parameter                                               ex4_icswx_instr_offset = ex3_icswx_instr_offset + 1;
parameter                                               ex2_icswxdot_instr_offset = ex4_icswx_instr_offset + 1;
parameter                                               ex3_icswxdot_instr_offset = ex2_icswxdot_instr_offset + 1;
parameter                                               ex4_icswxdot_instr_offset = ex3_icswxdot_instr_offset + 1;
parameter                                               ex2_icswx_epid_offset = ex4_icswxdot_instr_offset + 1;
parameter                                               ex3_icswx_epid_offset = ex2_icswx_epid_offset + 1;
parameter                                               ex4_icswx_epid_offset = ex3_icswx_epid_offset + 1;
parameter                                               ex5_icswx_epid_offset = ex4_icswx_epid_offset + 1;
parameter                                               ex4_c_inh_drop_op_offset = ex5_icswx_epid_offset + 1;
parameter                                               rel2_axu_wren_offset = ex4_c_inh_drop_op_offset + 1;
parameter                                               stq2_axu_val_offset = rel2_axu_wren_offset + 1;
parameter                                               stq3_axu_val_offset = stq2_axu_val_offset + 1;
parameter                                               stq4_axu_val_offset = stq3_axu_val_offset + 1;
parameter                                               stq4_store_hit_offset = stq4_axu_val_offset + 1;
parameter                                               stq5_store_hit_offset = stq4_store_hit_offset + 1;
parameter                                               stq6_store_hit_offset = stq5_store_hit_offset + 1;
parameter                                               rel2_ta_gpr_offset = stq6_store_hit_offset + 1;
parameter						                        rv1_binv_val_offset = rel2_ta_gpr_offset + AXU_TARGET_ENC;
parameter                                               ex0_binv_val_offset = rv1_binv_val_offset + 1;
parameter                                               ex1_binv_val_offset = ex0_binv_val_offset + 1;
parameter                                               ex2_binv_val_offset = ex1_binv_val_offset + 1;
parameter                                               ex3_binv_val_offset = ex2_binv_val_offset + 1;
parameter                                               ex4_binv_val_offset = ex3_binv_val_offset + 1;
parameter                                               ex0_derat_snoop_val_offset = ex4_binv_val_offset + 1;
parameter                                               ex1_derat_snoop_val_offset = ex0_derat_snoop_val_offset + 1;
parameter                                               spr_msr_fp_offset = ex1_derat_snoop_val_offset + 1;
parameter                                               spr_msr_spv_offset = spr_msr_fp_offset + `THREADS;
parameter                                               spr_msr_gs_offset = spr_msr_spv_offset + `THREADS;
parameter                                               spr_msr_pr_offset = spr_msr_gs_offset + `THREADS;
parameter                                               spr_msr_ds_offset = spr_msr_pr_offset + `THREADS;
parameter                                               spr_msr_de_offset = spr_msr_ds_offset + `THREADS;
parameter                                               spr_dbcr0_idm_offset = spr_msr_de_offset + `THREADS;
parameter                                               spr_epcr_duvd_offset = spr_dbcr0_idm_offset + `THREADS;
parameter                                               spr_lpidr_offset = spr_epcr_duvd_offset + `THREADS;
parameter                                               spr_pid_offset = spr_lpidr_offset + 8;
parameter                                               ex3_icswx_gs_offset = spr_pid_offset + (`THREADS*14);
parameter                                               ex3_icswx_pr_offset = ex3_icswx_gs_offset + 1;
parameter                                               ex4_icswx_ct_offset = ex3_icswx_pr_offset + 1;
parameter                                               ex4_icswx_ct_val_offset = ex4_icswx_ct_offset + 2;
parameter                                               dbg_int_en_offset = ex4_icswx_ct_val_offset + 1;
parameter						                        ex5_ttype_offset = dbg_int_en_offset + `THREADS;
parameter                                               ex4_wNComp_rcvd_offset = ex5_ttype_offset + 6;
parameter                                               ex4_wNComp_offset = ex4_wNComp_rcvd_offset + 1;
parameter						                        ex5_wNComp_offset = ex4_wNComp_offset + 1;
parameter						                        ex5_wNComp_cr_upd_offset = ex5_wNComp_offset + 1;
parameter						                        ex5_dvc_en_offset = ex5_wNComp_cr_upd_offset + 1;
parameter                                               ex6_dvc_en_offset = ex5_dvc_en_offset + 2;
parameter                                               ex4_is_inval_op_offset = ex6_dvc_en_offset + 2;
parameter                                               ex4_l1_lock_set_offset = ex4_is_inval_op_offset + 1;
parameter						                        ex5_l1_lock_set_offset = ex4_l1_lock_set_offset + 1;
parameter                                               ex4_lock_clr_offset = ex5_l1_lock_set_offset + 1;
parameter                                               ex5_lock_clr_offset = ex4_lock_clr_offset + 1;
parameter                                               ex2_sfx_val_offset = ex5_lock_clr_offset + 1;
parameter                                               ex3_sfx_val_offset = ex2_sfx_val_offset + 1;
parameter                                               ex4_sfx_val_offset = ex3_sfx_val_offset + 1;
parameter                                               ex2_ucode_val_offset = ex4_sfx_val_offset + 1;
parameter                                               ex3_ucode_val_offset = ex2_ucode_val_offset + 1;
parameter                                               ex4_ucode_val_offset = ex3_ucode_val_offset + 1;
parameter                                               ex2_ucode_cnt_offset = ex4_ucode_val_offset + 1;
parameter                                               ex3_ucode_cnt_offset = ex2_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                               ex2_ucode_op_offset = ex3_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
parameter                                               ex3_ucode_op_offset = ex2_ucode_op_offset + 1;
parameter                                               ex4_ucode_op_offset = ex3_ucode_op_offset + 1;
parameter                                               ex6_lq_comp_rpt_offset = ex4_ucode_op_offset + 1;
parameter                                               lq0_iu_execute_vld_offset = ex6_lq_comp_rpt_offset + 1;
parameter                                               lq0_iu_itag_offset = lq0_iu_execute_vld_offset + `THREADS;
parameter                                               lq0_iu_flush2ucode_type_offset = lq0_iu_itag_offset + `ITAG_SIZE_ENC;
parameter                                               lq0_iu_recirc_val_offset = lq0_iu_flush2ucode_type_offset + 1;
parameter                                               lq0_iu_flush2ucode_offset = lq0_iu_recirc_val_offset + `THREADS;
parameter                                               lq0_iu_dear_val_offset = lq0_iu_flush2ucode_offset + 1;
parameter                                               lq0_iu_eff_addr_offset = lq0_iu_dear_val_offset + `THREADS;
parameter                                               lq0_iu_n_flush_offset = lq0_iu_eff_addr_offset + (2**`GPR_WIDTH_ENC);
parameter                                               lq0_iu_np1_flush_offset = lq0_iu_n_flush_offset + 1;
parameter                                               lq0_iu_exception_val_offset = lq0_iu_np1_flush_offset + 1;
parameter                                               lq0_iu_exception_offset = lq0_iu_exception_val_offset + 1;
parameter                                               lq0_iu_dacr_type_offset = lq0_iu_exception_offset + 6;
parameter                                               lq0_iu_dacrw_offset = lq0_iu_dacr_type_offset + 1;
parameter                                               lq0_iu_instr_offset = lq0_iu_dacrw_offset + 4;
parameter						                        ex5_spec_load_miss_offset = lq0_iu_instr_offset + 32;
parameter                                               ex5_spec_itag_vld_offset = ex5_spec_load_miss_offset + 1;
parameter						                        ex5_spec_itag_offset = ex5_spec_itag_vld_offset + 1;
parameter						                        ex5_spec_tid_offset = ex5_spec_itag_offset + `ITAG_SIZE_ENC;
parameter						                        ex5_blk_pf_load_offset = ex5_spec_tid_offset + `THREADS;
parameter						                        ex5_lq_wNComp_val_offset = ex5_blk_pf_load_offset + 1;
parameter                                               ex6_lq_wNComp_val_offset = ex5_lq_wNComp_val_offset + 1;
parameter						                        ex5_wNComp_ord_offset = ex6_lq_wNComp_val_offset + 1;
parameter						                        ex5_restart_val_offset = ex5_wNComp_ord_offset + 1;
parameter                                               ex5_derat_restart_offset = ex5_restart_val_offset + 1;
parameter                                               ex6_derat_restart_offset = ex5_derat_restart_offset + 1;
parameter                                               ex5_dir_restart_offset = ex6_derat_restart_offset + 1;
parameter                                               ex6_dir_restart_offset = ex5_dir_restart_offset + 1;
parameter                                               ex5_dec_restart_offset = ex6_dir_restart_offset + 1;
parameter                                               ex6_dec_restart_offset = ex5_dec_restart_offset + 1;
parameter                                               ex4_derat_itagHit_offset = ex6_dec_restart_offset + 1;
parameter                                               ex6_stq_restart_val_offset = ex4_derat_itagHit_offset + 1;
parameter                                               ex6_restart_val_offset = ex6_stq_restart_val_offset + 1;
parameter						                        ex5_execute_vld_offset = ex6_restart_val_offset + 1;
parameter						                        ex5_flush2ucode_type_offset = ex5_execute_vld_offset + 1;
parameter						                        ex5_recirc_val_offset = ex5_flush2ucode_type_offset + 1;
parameter						                        ex5_wchkall_cplt_offset = ex5_recirc_val_offset + 1;
parameter                                               ex6_misalign_flush_offset = ex5_wchkall_cplt_offset + 1;
parameter                                               ldq_idle_offset = ex6_misalign_flush_offset + 1;
parameter                                               ex4_strg_gate_offset = ldq_idle_offset + `THREADS;
parameter                                               ex4_lswx_restart_offset = ex4_strg_gate_offset + 1;
parameter                                               ex4_icswx_restart_offset = ex4_lswx_restart_offset + 1;
parameter                                               ex4_is_sync_offset = ex4_icswx_restart_offset + 1;
parameter                                               rel2_xu_wren_offset = ex4_is_sync_offset + 1;
parameter                                               stq2_store_val_offset = rel2_xu_wren_offset + 1;
parameter                                               stq3_store_val_offset = stq2_store_val_offset + 1;
parameter                                               stq4_store_val_offset = stq3_store_val_offset + 1;
parameter                                               stq6_itag_offset = stq4_store_val_offset + 1;
parameter                                               stq6_tgpr_offset = stq6_itag_offset + `ITAG_SIZE_ENC;
parameter                                               stq2_thrd_id_offset = stq6_tgpr_offset + AXU_TARGET_ENC;
parameter                                               stq3_thrd_id_offset = stq2_thrd_id_offset + `THREADS;
parameter                                               stq4_thrd_id_offset = stq3_thrd_id_offset + `THREADS;
parameter                                               stq5_thrd_id_offset = stq4_thrd_id_offset + `THREADS;
parameter                                               stq6_thrd_id_offset = stq5_thrd_id_offset + `THREADS;
parameter                                               stq7_thrd_id_offset = stq6_thrd_id_offset + `THREADS;
parameter                                               stq8_thrd_id_offset = stq7_thrd_id_offset + `THREADS;
parameter                                               stq2_mftgpr_val_offset = stq8_thrd_id_offset + `THREADS;
parameter                                               stq3_mftgpr_val_offset = stq2_mftgpr_val_offset + 1;
parameter                                               stq4_mftgpr_val_offset = stq3_mftgpr_val_offset + 1;
parameter                                               stq5_mftgpr_val_offset = stq4_mftgpr_val_offset + 1;
parameter                                               stq6_mftgpr_val_offset = stq5_mftgpr_val_offset + 1;
parameter                                               stq7_mftgpr_val_offset = stq6_mftgpr_val_offset + 1;
parameter                                               stq8_mftgpr_val_offset = stq7_mftgpr_val_offset + 1;
parameter                                               stq2_mfdpf_val_offset = stq8_mftgpr_val_offset + 1;
parameter                                               stq3_mfdpf_val_offset = stq2_mfdpf_val_offset + 1;
parameter                                               stq4_mfdpf_val_offset = stq3_mfdpf_val_offset + 1;
parameter                                               stq5_mfdpf_val_offset = stq4_mfdpf_val_offset + 1;
parameter                                               stq2_mfdpa_val_offset = stq5_mfdpf_val_offset + 1;
parameter                                               stq3_mfdpa_val_offset = stq2_mfdpa_val_offset + 1;
parameter                                               stq4_mfdpa_val_offset = stq3_mfdpa_val_offset + 1;
parameter                                               stq5_mfdpa_val_offset = stq4_mfdpa_val_offset + 1;
parameter                                               stq6_mfdpa_val_offset = stq5_mfdpa_val_offset + 1;
parameter                                               stq2_ci_offset = stq6_mfdpa_val_offset + 1;
parameter                                               stq3_ci_offset = stq2_ci_offset + 1;
parameter                                               stq2_resv_offset = stq3_ci_offset + 1;
parameter                                               stq3_resv_offset = stq2_resv_offset + 1;
parameter                                               stq2_wclr_val_offset = stq3_resv_offset + 1;
parameter                                               stq3_wclr_val_offset = stq2_wclr_val_offset + 1;
parameter                                               stq4_wclr_val_offset = stq3_wclr_val_offset + 1;
parameter                                               stq2_wclr_all_set_offset = stq4_wclr_val_offset + 1;
parameter                                               stq3_wclr_all_set_offset = stq2_wclr_all_set_offset + 1;
parameter                                               stq4_wclr_all_set_offset = stq3_wclr_all_set_offset + 1;
parameter                                               stq2_epid_val_offset = stq4_wclr_all_set_offset + 1;
parameter                                               stq4_rec_stcx_offset = stq2_epid_val_offset + 1;
parameter						                        stq3_icswx_data_offset = stq4_rec_stcx_offset + 1;
parameter                                               ex2_cr_fld_offset = stq3_icswx_data_offset + 25;
parameter                                               ex3_cr_fld_offset = ex2_cr_fld_offset + `CR_POOL_ENC;
parameter                                               ex4_cr_fld_offset = ex3_cr_fld_offset + `CR_POOL_ENC;
parameter                                               ex5_cr_fld_offset = ex4_cr_fld_offset + `CR_POOL_ENC;
parameter                                               dir_arr_rd_val_offset = ex5_cr_fld_offset + `CR_POOL_ENC+`THREADS_POOL_ENC;
parameter                                               dir_arr_rd_tid_offset = dir_arr_rd_val_offset + 1;
parameter                                               dir_arr_rd_rv1_val_offset = dir_arr_rd_tid_offset + `THREADS;
parameter                                               dir_arr_rd_ex0_done_offset = dir_arr_rd_rv1_val_offset + 1;
parameter                                               dir_arr_rd_ex1_done_offset = dir_arr_rd_ex0_done_offset + 1;
parameter                                               dir_arr_rd_ex2_done_offset = dir_arr_rd_ex1_done_offset + 1;
parameter                                               dir_arr_rd_ex3_done_offset = dir_arr_rd_ex2_done_offset + 1;
parameter                                               dir_arr_rd_ex4_done_offset = dir_arr_rd_ex3_done_offset + 1;
parameter                                               dir_arr_rd_ex5_done_offset = dir_arr_rd_ex4_done_offset + 1;
parameter                                               dir_arr_rd_ex6_done_offset = dir_arr_rd_ex5_done_offset + 1;
parameter                                               pc_lq_ram_active_offset = dir_arr_rd_ex6_done_offset + 1;
parameter                                               lq_pc_ram_data_val_offset = pc_lq_ram_active_offset + `THREADS;
parameter                                               ex1_stg_act_offset = lq_pc_ram_data_val_offset + 1;
parameter                                               ex2_stg_act_offset = ex1_stg_act_offset + 1;
parameter                                               ex3_stg_act_offset = ex2_stg_act_offset + 1;
parameter                                               ex4_stg_act_offset = ex3_stg_act_offset + 1;
parameter                                               ex5_stg_act_offset = ex4_stg_act_offset + 1;
parameter                                               ex6_stg_act_offset = ex5_stg_act_offset + 1;
parameter                                               binv2_stg_act_offset = ex6_stg_act_offset + 1;
parameter                                               binv3_stg_act_offset = binv2_stg_act_offset + 1;
parameter                                               binv4_stg_act_offset = binv3_stg_act_offset + 1;
parameter                                               binv5_stg_act_offset = binv4_stg_act_offset + 1;
parameter                                               binv6_stg_act_offset = binv5_stg_act_offset + 1;
parameter                                               stq2_stg_act_offset = binv6_stg_act_offset + 1;
parameter                                               stq3_stg_act_offset = stq2_stg_act_offset + 1;
parameter                                               stq4_stg_act_offset = stq3_stg_act_offset + 1;
parameter                                               stq5_stg_act_offset = stq4_stg_act_offset + 1;
parameter                                               scan_right = stq5_stg_act_offset + 1 - 1;

wire                                                    tiup;
wire                                                    tidn;
wire [0:scan_right]                                     siv;
wire [0:scan_right]                                     sov;


(* analysis_not_referenced="true" *)
wire                                                    unused;

assign tiup = 1;
assign tidn = 0;
assign unused = ex3_rot_sel_non_le[0] | ex3_alg_bit_le_sel[0] | (|hypervisor_state) | (|ex4_p_addr[58:63]) | tidn | (|spr_dcc_spr_lesr);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Act Signals going to all Latches
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Execution Pipe ACT
assign ex1_stg_act_d = dec_dcc_ex0_act | clkg_ctl_override_q;
assign ex1_stg_act = dec_dcc_ex1_cmd_act | clkg_ctl_override_q;
assign ex2_stg_act_d = ex1_stg_act;
assign ex3_stg_act_d = ex2_stg_act_q;
assign ex4_stg_act_d = ex3_stg_act_q;
assign ex5_stg_act_d = ex4_stg_act_q;
assign ex6_stg_act_d = ex5_stg_act_q;
assign ex1_instr_act = ex1_stg_act_q | dec_dcc_ex1_pfetch_val;

// Back-Invalidate PIPE ACT
assign binv1_stg_act = ex1_binv_val_q | clkg_ctl_override_q;
assign binv2_stg_act_d = binv1_stg_act;
assign binv3_stg_act_d = binv2_stg_act_q;
assign binv4_stg_act_d = binv3_stg_act_q;
assign binv5_stg_act_d = binv4_stg_act_q;
assign binv6_stg_act_d = binv5_stg_act_q;
assign ex2_binv2_stg_act = ex2_stg_act_q | binv2_stg_act_q;
assign ex3_binv3_stg_act = ex3_stg_act_q | binv3_stg_act_q;
assign ex4_binv4_stg_act = ex4_stg_act_q | binv4_stg_act_q;
assign ex5_binv5_stg_act = ex5_stg_act_q | binv5_stg_act_q;
assign ex6_binv6_stg_act = ex6_stg_act_q | binv6_stg_act_q;

// XUDBG PIPE ACT
assign ex4_darr_rd_act = dir_arr_rd_ex4_done_q;
assign ex5_darr_rd_act = dir_arr_rd_ex5_done_q;

// LQ0 Interface Report ACT
assign lq0_iu_act = ex5_stg_act_q | lsq_ctl_stq_cpl_ready;

// REL/STQ Pipe ACT
assign stq1_stg_act = lsq_ctl_stq1_stg_act | clkg_ctl_override_q;
assign stq2_stg_act_d = stq1_stg_act;
assign stq3_stg_act_d = stq2_stg_act_q;
assign stq4_stg_act_d = stq3_stg_act_q;
assign stq5_stg_act_d = stq4_stg_act_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Completion Inputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign iu_lq_recirc_val_d = iu_lq_recirc_val;
assign iu_lq_cp_flush_d = iu_lq_cp_flush;

// XER[SO] bit for CP_NEXT CR update instructions (stcx./icswx./ldawx.)
assign xer_lq_cp_rd_so_d = xu_lq_xer_cp_rd;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// IU Dispatch Inputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign ex0_i0_vld_d = rv_lq_rv1_i0_vld;
assign ex0_i0_ucode_preissue_d = rv_lq_rv1_i0_ucode_preissue;
assign ex0_i0_2ucode_d = rv_lq_rv1_i0_2ucode;
assign ex0_i0_ucode_cnt_d = rv_lq_rv1_i0_ucode_cnt;
assign ex0_i1_vld_d = rv_lq_rv1_i1_vld;
assign ex0_i1_ucode_preissue_d = rv_lq_rv1_i1_ucode_preissue;
assign ex0_i1_2ucode_d = rv_lq_rv1_i1_2ucode;
assign ex0_i1_ucode_cnt_d = rv_lq_rv1_i1_ucode_cnt;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LSU Config Bits
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// CCR2[AP] Auxilary Processor Available
// 1 => Auxilary Processor Available
// 0 => Auxilary Processor Unavailable
assign spr_ccr2_ap_d = xu_lq_spr_ccr2_ap;

// CCR2[EN_TRACE] MTSPR TRACE Enabled
// 1 => MTSPR Trace is enabled
// 0 => MTSPR Trace is disabled
assign spr_ccr2_en_trace_d = xu_lq_spr_ccr2_en_trace;

// CCR2[UCODE_DIS] Ucode Disabled
// 1 => Ucode Disabled
// 0 => Ucode Enabled
assign spr_ccr2_ucode_dis_d = xu_lq_spr_ccr2_ucode_dis;

// CCR2[NOTLB] MMU Disabled
// 1 => MMU Disabled
// 0 => MMU Enabled
assign spr_ccr2_notlb_d = xu_lq_spr_ccr2_notlb;

// XUCR0[TRACE_UM] Enable MTSPR TRACE in user mode
// 1 => Enable MTSPR TRACE in user mode
// 0 => Disable MTSPR TRACE in user mode
assign spr_xucr0_en_trace_um_d = xu_lq_spr_xucr0_trace_um;
assign ex4_mtspr_trace_tid_en = |(spr_xucr0_en_trace_um_q & ex4_thrd_id_q);
assign ex4_mtspr_trace_en = ex4_mtspr_trace_q & spr_ccr2_en_trace_q & (ex4_mtspr_trace_tid_en | ~ex4_spr_msr_pr);
assign ex4_mtspr_trace_dis = ex4_mtspr_trace_q & ~(spr_ccr2_en_trace_q & (ex4_mtspr_trace_tid_en | ~ex4_spr_msr_pr));

// XUCR0[CLKG] Clock Gating Override
// 1 => Override Clock ACT's controls
// 0 => Use Clock Gating controls
assign clkg_ctl_override_d = xu_lq_spr_xucr0_clkg_ctl;

// XUCR0[WLK] Way Locking Enabled
// 1 => Way Locking Enabled
// 0 => Way Locking Disabled
assign spr_xucr0_wlk_d = xu_lq_spr_xucr0_wlk & ~xu_lq_spr_ccr2_dfrat;

assign way_lck_rmt = ~spr_xucr0_wlk_q ? 32'hFFFFFFFF : spr_dcc_spr_xucr2_rmt;

// XUCR0[MBAR_ACK]
// 1 => Wait for L2 Ack of mbar and lwsync
// 0 => Dont wait for L2 Ack of mbar and lwsync
assign spr_xucr0_mbar_ack_d = xu_lq_spr_xucr0_mbar_ack;

// XUCR0[TLBSYNC]
// 1 => Wait for L2 Ack of tlbsync
// 0 => Dont wait for L2 Ack of tlbsync
assign spr_xucr0_tlbsync_d = xu_lq_spr_xucr0_tlbsync;

// XUCR0[DC_DIS] Data Cache Disabled
// 1 => L1 Data Cache Disabled
// 0 => L1 Data Cache Enabled
assign spr_xucr0_dcdis_d = xu_lq_spr_xucr0_dcdis;

// XUCR0[AFLSTA] AXU Force Load/Store Alignment Interrupt
// 1 => Force alingment interrupt if misaligned access
// 0 => Dont force alingment interrupt if misaligned access
assign spr_xucr0_aflsta_d = xu_lq_spr_xucr0_aflsta;

// XUCR0[FLSTA] FX Force Load/Store Alignment Interrupt
// 1 => Force alingment interrupt if misaligned access
// 0 => Dont force alingment interrupt if misaligned access
assign spr_xucr0_flsta_d = xu_lq_spr_xucr0_flsta;

// XUCR0[MDDP] Machine Check on Data Cache Directory Parity Error
// 1 => Cause a machine check on data cache directory parity error
// 0 => Dont cause a machine check on data cache directory parity error, generate an N-Flush
assign spr_xucr0_mddp_d = xu_lq_spr_xucr0_mddp;

// XUCR0[MDCP] Machine Check on Data Cache Parity Error
// 1 => Cause a machine check on data cache parity error
// 0 => Dont cause a machine check on data cache parity error, generate an N-Flush
assign spr_xucr0_mdcp_d = xu_lq_spr_xucr0_mdcp;

// XUCR4[MMU_MCHK] Machine Check on Data ERAT Parity or Multihit Error
// 1 => Cause a machine check on data ERAT parity or multihit error
// 0 => Dont cause a machine check on data ERAT parity or multihit error, generate an N-Flush
assign spr_xucr4_mmu_mchk_d = xu_lq_spr_xucr4_mmu_mchk;

// XUCR4[MDDMH] Machine Check on Data Cache Directory Multihit Error
// 1 => Cause a machine check on data cache directory multihit error
// 0 => Dont cause a machine check on data cache directory multihit error, generate an N-Flush
assign spr_xucr4_mddmh_d = xu_lq_spr_xucr4_mddmh;

// MSR[FP] Floating Point Processor Available
// 1 => Floating Point Processor Available
// 0 => Floating Point Processor Unavailable
assign spr_msr_fp_d = xu_lq_spr_msr_fp;
assign spr_msr_fp = |(spr_msr_fp_q & ex3_thrd_id_q);

// MSR[SPV] Vector Processor Available
// 1 => Vector Processor Available
// 0 => Vector Processor Unavailable
assign spr_msr_spv_d = xu_lq_spr_msr_spv;
assign spr_msr_spv = |(spr_msr_spv_q & ex3_thrd_id_q);

// MSR[GS] Guest State
// 1 => Processor is in Guest State
// 0 => Processor is in Hypervisor State
assign spr_msr_gs_d = xu_lq_spr_msr_gs;

// MSR[PR] Problem State
// 1 => Processor is in User Mode
// 0 => Processor is in Supervisor Mode
assign spr_msr_pr_d = xu_lq_spr_msr_pr;
assign ex4_spr_msr_pr = |(spr_msr_pr_q & ex4_thrd_id_q);

// MSR[DS] Data Address Space
// 1 => Processor directs all data storage accesses to address space 1
// 0 => Processor directs all data storage accesses to address space 0
assign spr_msr_ds_d = xu_lq_spr_msr_ds;

// MSR[DE] Debug Interrupt Enable
// 1 => Processor is allowed to take a debug interrupt
// 0 => Processor is not allowed to take a debug interrupt
assign spr_msr_de_d = xu_lq_spr_msr_de;

// DBCR0[IDM] Internal Debug Mode Enable
// 1 => Enable internal debug mode
// 0 => Disable internal debug mode
assign spr_dbcr0_idm_d = xu_lq_spr_dbcr0_idm;

// EPCR[DUVD] Disable Hypervisor Debug
// 1 => Debug events are suppressed in the hypervisor state
// 0 => Debug events can occur in the hypervisor state
assign spr_epcr_duvd_d = xu_lq_spr_epcr_duvd;

// Logical Partition ID
assign spr_lpidr_d = mm_lq_lsu_lpidr;

// Threaded Registers
generate begin : tidPid
      genvar tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : tidPid
	     assign spr_pid_d[tid]    = mm_lq_pid[14*tid:(14*tid)+13];
         assign spr_acop_ct[tid]  = spr_dcc_spr_acop_ct[32*tid:(32*tid)+31];
         assign spr_hacop_ct[tid] = spr_dcc_spr_hacop_ct[32*tid:(32*tid)+31];
      end
   end
endgenerate

// Determine threads in hypervisor state
// MSR[GS]      | MSR[PR]       | Mode
//------------------------------------------------
// 0            | 0             | Hypervisor
// 0            | 1             | User
// 1            | 0             | Guest Supervisor
// 1            | 1             | Guest User
assign hypervisor_state = ~(spr_msr_gs_q | spr_msr_pr_q);

// Determine if a Debug Interrupt Should Occur
assign dbg_int_en_d = spr_msr_de_q & spr_dbcr0_idm_q & ~(spr_epcr_duvd_q & ~spr_msr_gs_q & ~spr_msr_pr_q);

// 64Bit mode Select
assign ex1_lsu_64bit_mode_d = xu_lq_spr_msr_cm;
assign ex1_lsu_64bit_mode = |(ex1_lsu_64bit_mode_q & dec_dcc_ex1_thrd_id);
assign ex2_lsu_64bit_agen_d = ex1_lsu_64bit_mode | ex1_binv_val_q | ex1_derat_snoop_val_q;
assign ex3_lsu_64bit_agen_d = ex2_lsu_64bit_agen_q;
assign ex4_lsu_64bit_agen_d = ex3_lsu_64bit_agen_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Back-Invalidate Pipe
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Back-Invalidate Address comes from ALU
// it is provided in rv1 and muxed into bypass in ex1
// it is then added with 0 and bypasses the erat translation
assign rv1_binv_val_d = lsq_ctl_rv0_back_inv;
assign ex0_binv_val_d = rv1_binv_val_q;
assign ex1_binv_val_d = ex0_binv_val_q;
assign ex2_binv_val_d = ex1_binv_val_q;
assign ex3_binv_val_d = ex2_binv_val_q;
assign ex4_binv_val_d = ex3_binv_val_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Snoop-Invalidate Pipe
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Snoop-Invalidate Address comes from ALU
// it is provided in rv1 and muxed into bypass in ex1
// it is then added with 0 and goes directly to the erat
assign ex0_derat_snoop_val_d = derat_rv1_snoop_val;
assign ex1_derat_snoop_val_d = ex0_derat_snoop_val_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Execution Instruction Decode Staging
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign ex2_itag_d = dec_dcc_ex1_itag;
assign ex3_itag_d = ex2_itag_q;
assign ex4_itag_d = ex3_itag_q;
assign ex5_itag_d = ex4_itag_q;
assign ex6_itag_d = ex5_itag_q;

assign ex2_optype1_d = dec_dcc_ex1_optype1;
assign ex3_optype1_d = ex2_optype1_q;

assign ex2_optype2_d = dec_dcc_ex1_optype2;
assign ex3_optype2_d = ex2_optype2_q;

assign ex2_optype4_d = dec_dcc_ex1_optype4;
assign ex3_optype4_d = ex2_optype4_q;

assign ex2_optype8_d = dec_dcc_ex1_optype8;
assign ex3_optype8_d = ex2_optype8_q;

assign ex2_optype16_d = dec_dcc_ex1_optype16;
assign ex3_optype16_d = ex2_optype16_q;

assign ex3_dacr_type_d = dec_dcc_ex2_is_any_load_dac;
assign ex4_dacr_type_d = ex3_dacr_type_q;
assign ex5_dacr_type_d = ex4_dacr_type_q;

assign ex3_eff_addr_d = dir_dcc_ex2_eff_addr;
assign ex4_eff_addr_d = ex3_eff_addr_q;

generate
   if (`GPR_WIDTH_ENC == 5) begin : Mode32b
      assign ex5_eff_addr_d = ex4_eff_addr_q;
   end
endgenerate

generate
   if (`GPR_WIDTH_ENC == 6) begin : Mode64b
      assign ex5_eff_addr_d[0:31]  = ex4_eff_addr_q[0:31] & {32{ex4_lsu_64bit_agen_q}};
      assign ex5_eff_addr_d[32:63] = ex4_eff_addr_q[32:63];
   end
endgenerate

assign ex4_p_addr = {derat_dcc_ex4_p_addr, ex4_eff_addr_q[52:63]};

assign ex2_cache_acc_d = dec_dcc_ex1_cache_acc & ~fgen_ex1_stg_flush_int;
assign ex3_cache_acc_d = ex2_cache_acc_q & ~fgen_ex2_stg_flush_int;
assign ex4_cache_acc_d = ex3_cache_acc_q & ~fgen_ex3_stg_flush_int;
assign ex5_cache_acc_d = ex4_cache_acc_q & ~fgen_ex4_stg_flush_int;
assign ex6_cache_acc_d = ex5_cache_acc_q & ~fgen_ex5_cp_flush;          // Different because it only goes to performance event

assign ex2_thrd_id_d = dec_dcc_ex1_thrd_id;
assign ex3_thrd_id_d = ex2_thrd_id_q;
assign ex4_thrd_id_d = ex3_thrd_id_q;
assign ex5_thrd_id_d = ex4_thrd_id_q;
assign ex6_thrd_id_d = ex5_thrd_id_q;

assign ex2_instr_d = dec_dcc_ex1_instr;
assign ex3_instr_d = ex2_instr_q;
assign ex4_instr_d = ex3_instr_q;
assign ex5_instr_d = ex4_instr_q;

assign ex2_target_gpr_d = dec_dcc_ex1_target_gpr;
assign ex3_target_gpr_d = ex2_target_gpr_q;
assign ex4_target_gpr_d = ex3_target_gpr_q;

assign ex4_cr_sel = ex4_icswxdot_instr_q | ex4_stx_instr;

generate
   if (`THREADS_POOL_ENC == 0) begin : threads1
       assign ex4_cr_fld = {({AXU_TARGET_ENC-`CR_POOL_ENC{1'b0}}), ex4_cr_fld_q};
   end
endgenerate

generate
   if (`THREADS_POOL_ENC != 0) begin : threadMulti
       assign ex4_cr_fld = {({AXU_TARGET_ENC-`CR_POOL_ENC-1{1'b0}}), ex4_cr_fld_q, ex4_target_gpr_q[AXU_TARGET_ENC-`THREADS_POOL_ENC:AXU_TARGET_ENC-1]};
   end
endgenerate

assign ex5_target_gpr_d = ex4_cr_sel ? ex4_cr_fld : ex4_target_gpr_q;

assign ex2_dcbt_instr_d = dec_dcc_ex1_dcbt_instr;
assign ex3_dcbt_instr_d = ex2_dcbt_instr_q;
assign ex4_dcbt_instr_d = ex3_dcbt_instr_q;

assign ex2_pfetch_val_d = dec_dcc_ex1_pfetch_val;
assign ex3_pfetch_val_d = ex2_pfetch_val_q;
assign ex4_pfetch_val_d = ex3_pfetch_val_q;
// For the case that an instruction got a Bad Machine Path Error,
// Need to drop prefetch in the pipeline in case it would have
// bypassed a bad state bit
assign ex5_pfetch_val_d = ex4_pfetch_val_q & ~ex4_wNComp_excp_restart;
assign ex6_pfetch_val_d = ex5_pfetch_val_q;
assign ldp_pfetch_inPipe = (dec_dcc_ex1_thrd_id & {`THREADS{dec_dcc_ex1_pfetch_val}}) |
                           (ex2_thrd_id_q       & {`THREADS{ex2_pfetch_val_q}}) |
                           (ex3_thrd_id_q       & {`THREADS{ex3_pfetch_val_q}}) |
                           (ex4_thrd_id_q       & {`THREADS{ex4_pfetch_val_q}}) |
                           (ex5_thrd_id_q       & {`THREADS{ex5_pfetch_val_q}});

assign ex2_dcbtst_instr_d = dec_dcc_ex1_dcbtst_instr;
assign ex3_dcbtst_instr_d = ex2_dcbtst_instr_q;
assign ex4_dcbtst_instr_d = ex3_dcbtst_instr_q;

assign ex5_perf_dcbt_d = ex4_th_fld_c_q & (ex4_dcbtst_instr_q | ex4_dcbt_instr_q | ex4_dcbtstls_instr_q | ex4_dcbtls_instr_q);

assign ex1_th_b0 = dec_dcc_ex1_th_fld[0] & (dec_dcc_ex1_dcbt_instr | dec_dcc_ex1_dcbtst_instr);
assign ex2_th_fld_c_d = ~ex1_th_b0 & ~(|dec_dcc_ex1_th_fld[1:4]);
assign ex3_th_fld_c_d = ex2_th_fld_c_q;
assign ex4_th_fld_c_d = ex3_th_fld_c_q;

assign ex2_th_fld_l2_d = ~ex1_th_b0 & (dec_dcc_ex1_th_fld[1:4] == 4'b0010);
assign ex3_th_fld_l2_d = ex2_th_fld_l2_q;
assign ex4_th_fld_l2_d = ex3_th_fld_l2_q;

// Need to check the L1 and send to the L2      when th=00000
// Need to not check the L1 and send to the L2  when th=00010
assign ex2_dcbtls_instr_d = dec_dcc_ex1_dcbtls_instr;
assign ex3_dcbtls_instr_d = ex2_dcbtls_instr_q;
assign ex4_dcbtls_instr_d = ex3_dcbtls_instr_q;

// Need to check the L1 and send to the L2      when th=00000
// Need to not check the L1 and send to the L2  when th=00010
assign ex2_dcbtstls_instr_d = dec_dcc_ex1_dcbtstls_instr;
assign ex3_dcbtstls_instr_d = ex2_dcbtstls_instr_q;
assign ex4_dcbtstls_instr_d = ex3_dcbtstls_instr_q;

// Need to check the L1 and not send to the L2  when th=00000
// Need to not check the L1 and send to the L2  when th=00010
assign ex2_dcblc_instr_d = dec_dcc_ex1_dcblc_instr;
assign ex3_dcblc_instr_d = ex2_dcblc_instr_q;
assign ex4_dcblc_instr_d = ex3_dcblc_instr_q;

// Need to not check the L1 and not send to the L2  when th=00000
// Need to not check the L1 and send to the L2      when th=00010
assign ex2_icblc_l2_instr_d = dec_dcc_ex1_icblc_instr;
assign ex3_icblc_l2_instr_d = ex2_icblc_l2_instr_q;
assign ex4_icblc_l2_instr_d = ex3_icblc_l2_instr_q;

// Need to not check the L1 and send to the L2
assign ex2_icbt_l2_instr_d = dec_dcc_ex1_icbt_instr;
assign ex3_icbt_l2_instr_d = ex2_icbt_l2_instr_q;
assign ex4_icbt_l2_instr_d = ex3_icbt_l2_instr_q;

// Need to not check the L1 and send to the L2
assign ex2_icbtls_l2_instr_d = dec_dcc_ex1_icbtls_instr;
assign ex3_icbtls_l2_instr_d = ex2_icbtls_l2_instr_q;
assign ex4_icbtls_l2_instr_d = ex3_icbtls_l2_instr_q;

assign ex2_tlbsync_instr_d = dec_dcc_ex1_tlbsync_instr & ~fgen_ex1_stg_flush_int;
assign ex3_tlbsync_instr_d = ex2_tlbsync_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_tlbsync_instr_d = ex3_tlbsync_instr_q & ~fgen_ex3_stg_flush_int;

// Load Double and Set Watch Bit
assign ex2_ldawx_instr_d = dec_dcc_ex1_ldawx_instr;
assign ex3_ldawx_instr_d = ex2_ldawx_instr_q;
assign ex4_ldawx_instr_d = ex3_ldawx_instr_q;
assign ex5_ldawx_instr_d = ex4_ldawx_instr_q;

// ICSWX Non-Record Form Instruction
assign ex2_icswx_instr_d = dec_dcc_ex1_icswx_instr;
assign ex3_icswx_instr_d = ex2_icswx_instr_q;
assign ex4_icswx_instr_d = ex3_icswx_instr_q;

// ICSWX Record Form Instruction
assign ex2_icswxdot_instr_d = dec_dcc_ex1_icswxdot_instr;
assign ex3_icswxdot_instr_d = ex2_icswxdot_instr_q;
assign ex4_icswxdot_instr_d = ex3_icswxdot_instr_q;

// ICSWX External PID Form Instruction
assign ex2_icswx_epid_d = dec_dcc_ex1_icswx_epid;
assign ex3_icswx_epid_d = ex2_icswx_epid_q;
assign ex4_icswx_epid_d = ex3_icswx_epid_q;
assign ex5_icswx_epid_d = ex4_icswx_epid_q;

// Watch Clear
assign ex2_wclr_instr_d = dec_dcc_ex1_wclr_instr;
assign ex3_wclr_instr_d = ex2_wclr_instr_q;
assign ex4_wclr_instr_d = ex3_wclr_instr_q;
assign ex4_wclr_all_val = ex4_wclr_instr_q & ~ex4_l_fld_q[0];

// Watch Check
assign ex2_wchk_instr_d = dec_dcc_ex1_wchk_instr & ~fgen_ex1_stg_flush_int;
assign ex3_wchk_instr_d = ex2_wchk_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_wchk_instr_d = ex3_wchk_instr_q & ~fgen_ex3_stg_flush_int;

assign ex2_dcbst_instr_d = dec_dcc_ex1_dcbst_instr;
assign ex3_dcbst_instr_d = ex2_dcbst_instr_q;
assign ex4_dcbst_instr_d = ex3_dcbst_instr_q;

assign ex2_dcbf_instr_d = dec_dcc_ex1_dcbf_instr;
assign ex3_dcbf_instr_d = ex2_dcbf_instr_q;
assign ex3_local_dcbf = ex3_dcbf_instr_q & (ex3_l_fld_q == 2'b11);
assign ex4_dcbf_instr_d = ex3_dcbf_instr_q;

assign ex2_mtspr_trace_d = dec_dcc_ex1_mtspr_trace & ~fgen_ex1_stg_flush_int;
assign ex3_mtspr_trace_d = ex2_mtspr_trace_q & ~fgen_ex2_stg_flush_int;
assign ex4_mtspr_trace_d = ex3_mtspr_trace_q & ~fgen_ex3_stg_flush_int;

assign ex2_sync_instr_d = dec_dcc_ex1_sync_instr & ~fgen_ex1_stg_flush_int;
assign ex3_sync_instr_d = ex2_sync_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_sync_instr_d = ex3_sync_instr_q & ~fgen_ex3_stg_flush_int;

assign ex2_l_fld_d = dec_dcc_ex1_l_fld;
assign ex3_l_fld_d = ex2_l_fld_q;
assign ex3_l_fld_sel = {ex3_sync_instr_q, ex3_mbar_instr_q, ex3_tlbsync_instr_q, ex3_makeitso_instr_q};
assign ex3_l_fld_mbar = {1'b0, ~spr_xucr0_mbar_ack_q};
assign ex3_l_fld_sync = {1'b0, (ex3_l_fld_q[1] & ~(ex3_l_fld_q[0] | spr_xucr0_mbar_ack_q))};
assign ex3_l_fld_makeitso = 2'b01;

assign ex3_l_fld_tlbsync = (spr_xucr0_tlbsync_q == 1'b0) ? 2'b01 : 2'b00;

assign ex3_l_fld = (ex3_l_fld_sel == 4'b0001) ? ex3_l_fld_makeitso :
                   (ex3_l_fld_sel == 4'b0010) ? ex3_l_fld_tlbsync :
                   (ex3_l_fld_sel == 4'b0100) ? ex3_l_fld_mbar :
                   (ex3_l_fld_sel == 4'b1000) ? ex3_l_fld_sync :
                   ex3_l_fld_q;

assign ex4_l_fld_d = ex3_l_fld;
assign ex5_l_fld_d = ex4_l_fld_q;

assign ex2_dcbi_instr_d = dec_dcc_ex1_dcbi_instr;
assign ex3_dcbi_instr_d = ex2_dcbi_instr_q;
assign ex4_dcbi_instr_d = ex3_dcbi_instr_q;

assign ex2_dcbz_instr_d = dec_dcc_ex1_dcbz_instr;
assign ex3_dcbz_instr_d = ex2_dcbz_instr_q;
assign ex4_dcbz_instr_d = ex3_dcbz_instr_q;

assign ex2_icbi_instr_d = dec_dcc_ex1_icbi_instr;
assign ex3_icbi_instr_d = ex2_icbi_instr_q;
assign ex4_icbi_instr_d = ex3_icbi_instr_q;

assign ex2_mbar_instr_d = dec_dcc_ex1_mbar_instr & ~fgen_ex1_stg_flush_int;
assign ex3_mbar_instr_d = ex2_mbar_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_mbar_instr_d = ex3_mbar_instr_q & ~fgen_ex3_stg_flush_int;

assign ex2_makeitso_instr_d = dec_dcc_ex1_makeitso_instr & ~fgen_ex1_stg_flush_int;
assign ex3_makeitso_instr_d = ex2_makeitso_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_makeitso_instr_d = ex3_makeitso_instr_q & ~fgen_ex3_stg_flush_int;

assign ex2_msgsnd_instr_d = dec_dcc_ex1_is_msgsnd & ~fgen_ex1_stg_flush_int;
assign ex3_msgsnd_instr_d = ex2_msgsnd_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_msgsnd_instr_d = ex3_msgsnd_instr_q & ~fgen_ex3_stg_flush_int;

// DCI with CT=0    -> invalidate L1 only
// DCI with CT=2    -> invalidate L1 and send to L2
// DCI with CT!=0,2 -> No-Op
assign ex2_dci_instr_d = dec_dcc_ex1_dci_instr & ~fgen_ex1_stg_flush_int;
assign ex3_dci_instr_d = ex2_dci_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_dci_instr_d = ex3_dci_instr_q & ~fgen_ex3_stg_flush_int;
assign ex4_dci_l2_val = ex4_dci_instr_q & ex4_th_fld_l2_q;
assign ex4_is_cinval = (ex4_dci_instr_q | ex4_ici_instr_q) & (ex4_th_fld_l2_q | ex4_th_fld_c_q);
assign ex4_is_cinval_drop = (ex4_dci_instr_q | ex4_ici_instr_q) & ~(ex4_th_fld_l2_q | ex4_th_fld_c_q);

// ICI with CT=0    -> invalidate L1 only
// ICI with CT=2    -> invalidate L1 and send to L2
// ICI with CT!=0,2 -> No-Op
assign ex2_ici_instr_d = dec_dcc_ex1_ici_instr & ~fgen_ex1_stg_flush_int;
assign ex3_ici_instr_d = ex2_ici_instr_q & ~fgen_ex2_stg_flush_int;
assign ex4_ici_instr_d = ex3_ici_instr_q & ~fgen_ex3_stg_flush_int;
assign ex4_ici_l2_val = ex4_ici_instr_q & ex4_th_fld_l2_q;

assign ex2_algebraic_d = dec_dcc_ex1_algebraic;
assign ex3_algebraic_d = ex2_algebraic_q;

assign ex2_strg_index_d = dec_dcc_ex1_strg_index;
assign ex3_strg_index_d = ex2_strg_index_q;
assign ex4_strg_index_d = ex3_strg_index_q;

assign ex2_resv_instr_d = dec_dcc_ex1_resv_instr;
assign ex3_resv_instr_d = ex2_resv_instr_q;
assign ex4_resv_instr_d = ex3_resv_instr_q;

assign ex2_mutex_hint_d = dec_dcc_ex1_mutex_hint;
assign ex3_mutex_hint_d = ex2_mutex_hint_q;
assign ex4_mutex_hint_d = ex3_mutex_hint_q;

assign ex2_cr_fld_d = dec_dcc_ex1_cr_fld;
assign ex3_cr_fld_d = ex2_cr_fld_q;
assign ex4_cr_fld_d = ex3_cr_fld_q;
assign ex5_cr_fld_d = ex4_cr_fld[AXU_TARGET_ENC - (`CR_POOL_ENC + `THREADS_POOL_ENC):AXU_TARGET_ENC - 1];

assign ex2_load_instr_d = dec_dcc_ex1_load_instr;
assign ex3_load_instr_d = ex2_load_instr_q;
assign ex4_load_instr_d = ex3_load_instr_q;
assign ex5_load_instr_d = ex4_load_instr_q;
assign ex3_load_type = ex3_load_instr_q | ex3_dcbt_instr_q | ex3_dcbtst_instr_q | ex3_dcbtls_instr_q | ex3_dcbtstls_instr_q;
assign ex4_load_type_d = ex3_load_type;
assign ex4_gath_load_d = ex3_load_instr_q & ~(ex3_resv_instr_q | ex3_ldawx_instr_q);
assign ex4_l2load_type_d = ex3_load_type | ex3_icbt_l2_instr_q | ex3_icbtls_l2_instr_q;

assign ex2_store_instr_d = dec_dcc_ex1_store_instr;
assign ex3_store_instr_d = ex2_store_instr_q;
assign ex4_store_instr_d = ex3_store_instr_q;

assign ex2_axu_op_val_d = dec_dcc_ex1_axu_op_val;
assign ex3_axu_op_val_d = ex2_axu_op_val_q;
assign ex4_axu_op_val_d = ex3_axu_op_val_q;
assign ex5_axu_op_val_d = ex4_axu_op_val_q;

assign ex2_sgpr_instr_d = dec_dcc_ex1_src_gpr  & ~fgen_ex1_stg_flush_int;
assign ex2_saxu_instr_d = dec_dcc_ex1_src_axu  & ~fgen_ex1_stg_flush_int;
assign ex2_sdp_instr_d  = dec_dcc_ex1_src_dp   & ~fgen_ex1_stg_flush_int;
assign ex2_tgpr_instr_d = dec_dcc_ex1_targ_gpr & ~fgen_ex1_stg_flush_int;
assign ex2_taxu_instr_d = dec_dcc_ex1_targ_axu & ~fgen_ex1_stg_flush_int;
assign ex2_tdp_instr_d  = dec_dcc_ex1_targ_dp  & ~fgen_ex1_stg_flush_int;

assign ex3_sgpr_instr_d = ex2_sgpr_instr_q;
assign ex3_saxu_instr_d = ex2_saxu_instr_q;
assign ex3_sdp_instr_d  = ex2_sdp_instr_q;
assign ex4_sgpr_instr_d = ex3_sgpr_instr_q;
assign ex4_saxu_instr_d = ex3_saxu_instr_q;
assign ex4_sdp_instr_d  = ex3_sdp_instr_q;

assign ex3_tgpr_instr_d = ex2_tgpr_instr_q & ~fgen_ex2_stg_flush_int;
assign ex3_taxu_instr_d = ex2_taxu_instr_q & ~fgen_ex2_stg_flush_int;
assign ex3_tdp_instr_d  = ex2_tdp_instr_q  & ~fgen_ex2_stg_flush_int;

assign ex4_tgpr_instr_d = ex3_tgpr_instr_q & ~fgen_ex3_stg_flush_int;
assign ex4_taxu_instr_d = ex3_taxu_instr_q & ~fgen_ex3_stg_flush_int;
assign ex4_tdp_instr_d  = ex3_tdp_instr_q  & ~fgen_ex3_stg_flush_int;

// ditc instructions
assign ex4_mfdpa_val = ex4_sdp_instr_q & ex4_taxu_instr_q;
assign ex4_mfdpf_val = ex4_sdp_instr_q & ex4_tgpr_instr_q;
assign ex4_ditc_val  = ex4_tdp_instr_q | (ex4_sdp_instr_q & (ex4_taxu_instr_q | ex4_tgpr_instr_q));

// All the mf[f,t]gpr instructions
assign ex2_mftgpr_val   = ex2_saxu_instr_q & ex2_tgpr_instr_q;
assign ex3_mftgpr_val   = ex3_saxu_instr_q & ex3_tgpr_instr_q;
assign ex4_mftgpr_val   = ex4_saxu_instr_q & ex4_tgpr_instr_q;
assign ex5_mftgpr_val_d = ex4_mftgpr_val & ~fgen_ex4_stg_flush_int;
assign ex3_mffgpr_val   = ex3_sgpr_instr_q & ex3_taxu_instr_q;
assign ex4_mffgpr_val   = ex4_sgpr_instr_q & ex4_taxu_instr_q;
assign ex3_mfgpr_val    = ex3_tgpr_instr_q | ex3_taxu_instr_q | ex3_tdp_instr_q;

assign ex2_ldst_falign_d = dec_dcc_ex1_axu_falign;
assign ex2_ldst_fexcpt_d = dec_dcc_ex1_axu_fexcpt;
assign ex3_ldst_fexcpt_d = ex2_ldst_fexcpt_q;

assign ex2_mword_instr_d = dec_dcc_ex1_mword_instr;
assign ex3_mword_instr_d = ex2_mword_instr_q;

assign ex2_sfx_val_d = dec_dcc_ex1_sfx_val & ~fgen_ex1_stg_flush_int;
assign ex3_sfx_val_d = ex2_sfx_val_q & ~fgen_ex2_stg_flush_int;
assign ex4_sfx_val_d = ex3_sfx_val_q & ~fgen_ex3_stg_flush_int;

assign ex2_ucode_val_d = dec_dcc_ex1_ucode_val & ~fgen_ex1_stg_flush_int;
assign ex3_ucode_val_d = ex2_ucode_val_q & ~fgen_ex2_stg_flush_int;
assign ex4_ucode_val_d = ex3_ucode_val_q & ~fgen_ex3_stg_flush_int;

assign ex2_ucode_cnt_d = dec_dcc_ex1_ucode_cnt;
assign ex3_ucode_cnt_d = ex2_ucode_cnt_q;

assign ex2_ucode_op_d = dec_dcc_ex1_ucode_op;
assign ex3_ucode_op_d = ex2_ucode_op_q;
assign ex4_ucode_op_d = ex3_ucode_op_q;

assign ex2_upd_form_d = dec_dcc_ex1_upd_form;
assign ex3_upd_form_d = ex2_upd_form_q;

assign ex2_axu_instr_type_d = dec_dcc_ex1_axu_instr_type;
assign ex3_axu_instr_type_d = ex2_axu_instr_type_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Commit Execution Pipe
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign stq2_store_val_d = lsq_ctl_stq1_store_val & lsq_ctl_stq1_val;
assign stq3_store_val_d = stq2_store_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_store_val_d = stq3_store_val_q;
assign stq2_ci_d = lsq_ctl_stq1_ci;
assign stq3_ci_d = stq2_ci_q;
assign stq2_resv_d = lsq_ctl_stq1_resv;
assign stq3_resv_d = stq2_resv_q;
assign stq4_rec_stcx_d = stq3_resv_q & stq3_store_val_q;
assign stq2_wclr_val_d = lsq_ctl_stq1_val & lsq_ctl_stq1_watch_clr;
assign stq3_wclr_val_d = stq2_wclr_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_wclr_val_d = stq3_wclr_val_q;
assign stq2_wclr_all_set_d = lsq_ctl_stq1_watch_clr & ~lsq_ctl_stq1_l_fld[0] & lsq_ctl_stq1_l_fld[1];
assign stq3_wclr_all_set_d = stq2_wclr_all_set_q;
assign stq4_wclr_all_set_d = stq3_wclr_all_set_q;
assign stq6_itag_d = lsq_ctl_stq5_itag;
assign stq6_tgpr_d = lsq_ctl_stq5_tgpr;
assign stq2_epid_val_d = lsq_ctl_stq1_epid_val;
assign stq2_thrd_id_d = lsq_ctl_stq1_thrd_id;
assign stq3_thrd_id_d = stq2_thrd_id_q;
assign stq4_thrd_id_d = stq3_thrd_id_q;
assign stq5_thrd_id_d = stq4_thrd_id_q;
assign stq6_thrd_id_d = stq5_thrd_id_q;
assign stq7_thrd_id_d = stq6_thrd_id_q;
assign stq8_thrd_id_d = stq7_thrd_id_q;

assign stq2_mftgpr_val_d = lsq_ctl_stq1_mftgpr_val & lsq_ctl_stq1_val;
assign stq3_mftgpr_val_d = stq2_mftgpr_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_mftgpr_val_d = stq3_mftgpr_val_q;
assign stq5_mftgpr_val_d = stq4_mftgpr_val_q;
assign stq6_mftgpr_val_d = stq5_mftgpr_val_q;
assign stq7_mftgpr_val_d = stq6_mftgpr_val_q;
assign stq8_mftgpr_val_d = stq7_mftgpr_val_q;

assign stq2_mfdpf_val_d = lsq_ctl_stq1_mfdpf_val & lsq_ctl_stq1_val;
assign stq3_mfdpf_val_d = stq2_mfdpf_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_mfdpf_val_d = stq3_mfdpf_val_q;
assign stq5_mfdpf_val_d = stq4_mfdpf_val_q;

assign stq2_mfdpa_val_d = lsq_ctl_stq1_mfdpa_val & lsq_ctl_stq1_val;
assign stq3_mfdpa_val_d = stq2_mfdpa_val_q & ~lsq_ctl_stq2_blk_req;
assign stq4_mfdpa_val_d = stq3_mfdpa_val_q;
assign stq5_mfdpa_val_d = stq4_mfdpa_val_q;
assign stq6_mfdpa_val_d = stq5_mfdpa_val_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// ICSWX LOGIC
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// ICSWX
assign ex2_epsc_egs   = |(spr_dcc_epsc_egs & ex2_thrd_id_q);
assign ex2_epsc_epr   = |(spr_dcc_epsc_epr & ex2_thrd_id_q);
assign ex2_msr_gs     = |(spr_msr_gs_q & ex2_thrd_id_q);
assign ex2_msr_pr     = |(spr_msr_pr_q & ex2_thrd_id_q);
assign ex3_icswx_gs_d = ex2_icswx_epid_q ? ex2_epsc_egs : ex2_msr_gs;
assign ex3_icswx_pr_d = ex2_icswx_epid_q ? ex2_epsc_epr : ex2_msr_pr;
assign ex4_icswx_ct_val_d = lsq_ctl_ex3_ct_val;

// Only Check ACOP in problem state (PR=1)
assign ex3_acop_ct_npr = ex3_acop_ct | {32{~ex3_icswx_pr_q}};
assign ex3_cop_ct = ex3_hacop_ct & ex3_acop_ct_npr;

// Only Check ACOP/HACOP if not in Hypervisor
assign ex4_icswx_ct_d[0] = ex3_icswx_ct[0] | (~ex3_icswx_pr_q & ~ex3_icswx_gs_q);		// Big Endian
assign ex4_icswx_ct_d[1] = ex3_icswx_ct[1] | (~ex3_icswx_pr_q & ~ex3_icswx_gs_q);		// Little Endian

// ICSWX DSI Generation
assign ex4_icswx_ct = (ex4_icswx_ct_q[0] & ~derat_dcc_ex4_wimge[4]) |   // Big Endian
                      (ex4_icswx_ct_q[1] &  derat_dcc_ex4_wimge[4]);	// Little Endian
assign ex4_icswx_dsi = ex4_cache_acc_q & ex4_icswx_type & ex4_icswx_ct_val_q & ~ex4_icswx_ct;

// Big Endian CT Select
assign ex3_icswx_ct[0] = (lsq_ctl_ex3_be_ct == 6'b100000) ? ex3_cop_ct[32] :
                         (lsq_ctl_ex3_be_ct == 6'b100001) ? ex3_cop_ct[33] :
                         (lsq_ctl_ex3_be_ct == 6'b100010) ? ex3_cop_ct[34] :
                         (lsq_ctl_ex3_be_ct == 6'b100011) ? ex3_cop_ct[35] :
                         (lsq_ctl_ex3_be_ct == 6'b100100) ? ex3_cop_ct[36] :
                         (lsq_ctl_ex3_be_ct == 6'b100101) ? ex3_cop_ct[37] :
                         (lsq_ctl_ex3_be_ct == 6'b100110) ? ex3_cop_ct[38] :
                         (lsq_ctl_ex3_be_ct == 6'b100111) ? ex3_cop_ct[39] :
                         (lsq_ctl_ex3_be_ct == 6'b101000) ? ex3_cop_ct[40] :
                         (lsq_ctl_ex3_be_ct == 6'b101001) ? ex3_cop_ct[41] :
                         (lsq_ctl_ex3_be_ct == 6'b101010) ? ex3_cop_ct[42] :
                         (lsq_ctl_ex3_be_ct == 6'b101011) ? ex3_cop_ct[43] :
                         (lsq_ctl_ex3_be_ct == 6'b101100) ? ex3_cop_ct[44] :
                         (lsq_ctl_ex3_be_ct == 6'b101101) ? ex3_cop_ct[45] :
                         (lsq_ctl_ex3_be_ct == 6'b101110) ? ex3_cop_ct[46] :
                         (lsq_ctl_ex3_be_ct == 6'b101111) ? ex3_cop_ct[47] :
                         (lsq_ctl_ex3_be_ct == 6'b110000) ? ex3_cop_ct[48] :
                         (lsq_ctl_ex3_be_ct == 6'b110001) ? ex3_cop_ct[49] :
                         (lsq_ctl_ex3_be_ct == 6'b110010) ? ex3_cop_ct[50] :
                         (lsq_ctl_ex3_be_ct == 6'b110011) ? ex3_cop_ct[51] :
                         (lsq_ctl_ex3_be_ct == 6'b110100) ? ex3_cop_ct[52] :
                         (lsq_ctl_ex3_be_ct == 6'b110101) ? ex3_cop_ct[53] :
                         (lsq_ctl_ex3_be_ct == 6'b110110) ? ex3_cop_ct[54] :
                         (lsq_ctl_ex3_be_ct == 6'b110111) ? ex3_cop_ct[55] :
                         (lsq_ctl_ex3_be_ct == 6'b111000) ? ex3_cop_ct[56] :
                         (lsq_ctl_ex3_be_ct == 6'b111001) ? ex3_cop_ct[57] :
                         (lsq_ctl_ex3_be_ct == 6'b111010) ? ex3_cop_ct[58] :
                         (lsq_ctl_ex3_be_ct == 6'b111011) ? ex3_cop_ct[59] :
                         (lsq_ctl_ex3_be_ct == 6'b111100) ? ex3_cop_ct[60] :
                         (lsq_ctl_ex3_be_ct == 6'b111101) ? ex3_cop_ct[61] :
                         (lsq_ctl_ex3_be_ct == 6'b111110) ? ex3_cop_ct[62] :
                         (lsq_ctl_ex3_be_ct == 6'b111111) ? ex3_cop_ct[63] :
                         1'b0;

// Little Endian CT Select
assign ex3_icswx_ct[1] = (lsq_ctl_ex3_le_ct == 6'b100000) ? ex3_cop_ct[32] :
                         (lsq_ctl_ex3_le_ct == 6'b100001) ? ex3_cop_ct[33] :
                         (lsq_ctl_ex3_le_ct == 6'b100010) ? ex3_cop_ct[34] :
                         (lsq_ctl_ex3_le_ct == 6'b100011) ? ex3_cop_ct[35] :
                         (lsq_ctl_ex3_le_ct == 6'b100100) ? ex3_cop_ct[36] :
                         (lsq_ctl_ex3_le_ct == 6'b100101) ? ex3_cop_ct[37] :
                         (lsq_ctl_ex3_le_ct == 6'b100110) ? ex3_cop_ct[38] :
                         (lsq_ctl_ex3_le_ct == 6'b100111) ? ex3_cop_ct[39] :
                         (lsq_ctl_ex3_le_ct == 6'b101000) ? ex3_cop_ct[40] :
                         (lsq_ctl_ex3_le_ct == 6'b101001) ? ex3_cop_ct[41] :
                         (lsq_ctl_ex3_le_ct == 6'b101010) ? ex3_cop_ct[42] :
                         (lsq_ctl_ex3_le_ct == 6'b101011) ? ex3_cop_ct[43] :
                         (lsq_ctl_ex3_le_ct == 6'b101100) ? ex3_cop_ct[44] :
                         (lsq_ctl_ex3_le_ct == 6'b101101) ? ex3_cop_ct[45] :
                         (lsq_ctl_ex3_le_ct == 6'b101110) ? ex3_cop_ct[46] :
                         (lsq_ctl_ex3_le_ct == 6'b101111) ? ex3_cop_ct[47] :
                         (lsq_ctl_ex3_le_ct == 6'b110000) ? ex3_cop_ct[48] :
                         (lsq_ctl_ex3_le_ct == 6'b110001) ? ex3_cop_ct[49] :
                         (lsq_ctl_ex3_le_ct == 6'b110010) ? ex3_cop_ct[50] :
                         (lsq_ctl_ex3_le_ct == 6'b110011) ? ex3_cop_ct[51] :
                         (lsq_ctl_ex3_le_ct == 6'b110100) ? ex3_cop_ct[52] :
                         (lsq_ctl_ex3_le_ct == 6'b110101) ? ex3_cop_ct[53] :
                         (lsq_ctl_ex3_le_ct == 6'b110110) ? ex3_cop_ct[54] :
                         (lsq_ctl_ex3_le_ct == 6'b110111) ? ex3_cop_ct[55] :
                         (lsq_ctl_ex3_le_ct == 6'b111000) ? ex3_cop_ct[56] :
                         (lsq_ctl_ex3_le_ct == 6'b111001) ? ex3_cop_ct[57] :
                         (lsq_ctl_ex3_le_ct == 6'b111010) ? ex3_cop_ct[58] :
                         (lsq_ctl_ex3_le_ct == 6'b111011) ? ex3_cop_ct[59] :
                         (lsq_ctl_ex3_le_ct == 6'b111100) ? ex3_cop_ct[60] :
                         (lsq_ctl_ex3_le_ct == 6'b111101) ? ex3_cop_ct[61] :
                         (lsq_ctl_ex3_le_ct == 6'b111110) ? ex3_cop_ct[62] :
                         (lsq_ctl_ex3_le_ct == 6'b111111) ? ex3_cop_ct[63] :
                         1'b0;

generate begin : regConc
      genvar tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : regConc
        // Concatenate Appropriate EPSC fields
        assign epsc_t_reg[tid] = {spr_dcc_epsc_epr[tid], spr_dcc_epsc_eas[tid], spr_dcc_epsc_egs[tid],
	                              spr_dcc_epsc_elpid[tid*8:tid*8+7], spr_dcc_epsc_epid[tid*14:tid*14+13]};
        // Concatenate Appropriate LESR fields
        assign lesr_t_reg[tid] = spr_dcc_spr_lesr[tid*24:(tid*24)+23];
      end
   end
endgenerate

// Thread Register Selection
always @(*)
begin: tidIcswx
   reg [0:13]                                              pid;
   reg [0:24]                                              epsc;
   reg [0:31]                                              acop;
   reg [0:31]                                              hcop;
   reg [0:23]                                              lesr;
   (* analysis_not_referenced="true" *)
   integer                                                 tid;

   pid  = {14{1'b0}};
   epsc = {25{1'b0}};
   acop = {32{1'b0}};
   hcop = {32{1'b0}};
   lesr = {24{1'b0}};
   for (tid=0; tid<`THREADS; tid=tid+1)
   begin
      pid  = (spr_pid_q[tid]    & {14{stq2_thrd_id_q[tid]}}) | pid;
      epsc = (epsc_t_reg[tid]   & {25{stq2_thrd_id_q[tid]}}) | epsc;
      acop = (spr_acop_ct[tid]  & {32{ex3_thrd_id_q[tid]}})  | acop;
      hcop = (spr_hacop_ct[tid] & {32{ex3_thrd_id_q[tid]}})  | hcop;
      lesr = (lesr_t_reg[tid]   & {24{ex5_thrd_id_q[tid]}})  | lesr;
   end
   stq2_pid     <= pid;
   stq2_epsc    <= epsc;
   ex3_acop_ct  <= acop;
   ex3_hacop_ct <= hcop;
   ex5_spr_lesr <= lesr;
end

// ICSWX Store Data
assign stq2_icswx_epid[0:2]   = {~stq2_epsc[2], stq2_epsc[0], stq2_epsc[1]};
assign stq2_icswx_epid[3:24]  = stq2_epsc[3:24];
assign stq2_icswx_nepid[0:2]  = {~(|(spr_msr_gs_q & stq2_thrd_id_q)), |(spr_msr_pr_q & stq2_thrd_id_q), |(spr_msr_ds_q & stq2_thrd_id_q)};
assign stq2_icswx_nepid[3:24] = {spr_lpidr_q, stq2_pid};

// Select between External Pid and non-External Pid ICSWX
assign stq3_icswx_data_d = stq2_epid_val_q ? stq2_icswx_epid : stq2_icswx_nepid;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// CR Update Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// CR Setter
generate begin : crData
      genvar cr;
      for (cr=0; cr<`CR_WIDTH; cr=cr+1) begin : crData
         if (cr == 2) begin : crSet0
            assign ex5_cr_wd[cr] = dir_dcc_ex5_cr_rslt;
         end
         if (cr == 3) begin : crSet1
            assign ex5_cr_wd[cr] = |(xer_lq_cp_rd_so_q & ex5_thrd_id_q);
         end
         if (cr < 2 | cr >= 4) begin : crOff0
            assign ex5_cr_wd[cr] = 1'b0;
         end
      end
   end
endgenerate

//ldawx.        --> 00 || b2 || XER[SO]
//icswx.        --> b0b1b2   || 0
//stcx.         --> 00 || b2 || XER[SO]
//wchkall       ==> 00 || b2 || XER[SO]

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Byte Enable Generation
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Need to generate byte enables for the type of operation
// size1  => 0x8000
// size2  => 0xC000
// size4  => 0xF000
// size8  => 0xFF00
// size16 => 0xFFFF
assign op_sel[0] = ex3_opsize[1] | ex3_opsize[2] | ex3_opsize[3] | ex3_opsize[4];
assign op_sel[1] = ex3_opsize[1] | ex3_opsize[2] | ex3_opsize[3];
assign op_sel[2] = ex3_opsize[1] | ex3_opsize[2];
assign op_sel[3] = ex3_opsize[1] | ex3_opsize[2];
assign op_sel[4] = ex3_opsize[1];
assign op_sel[5] = ex3_opsize[1];
assign op_sel[6] = ex3_opsize[1];
assign op_sel[7] = ex3_opsize[1];
assign op_sel[8:15] = {8{1'b0}};

// 16 Bit Rotator
// Selects between Data rotated by 0, 4, 8, or 12 bits
assign beC840_en = (ex3_eff_addr_q[60:61] == 2'b00) ? op_sel[0:15] :
                   (ex3_eff_addr_q[60:61] == 2'b01) ? {4'h0, op_sel[0:11]} :
                   (ex3_eff_addr_q[60:61] == 2'b10) ? {8'h00, op_sel[0:7]} :
                   {12'h000, op_sel[0:3]};

// Selects between Data rotated by 0, 1, 2, or 3 bits
assign be3210_en = (ex3_eff_addr_q[62:63] == 2'b00) ? beC840_en[0:15] :
                   (ex3_eff_addr_q[62:63] == 2'b01) ? {1'b0, beC840_en[0:14]} :
                   (ex3_eff_addr_q[62:63] == 2'b10) ? {2'b00, beC840_en[0:13]} :
                   {3'b000, beC840_en[0:12]};

// Byte Enables Generated using the opsize and physical_addr(60 to 63)
generate begin : ben_gen
      genvar t;
      for (t=0; t<16; t=t+1) begin : ben_gen
         assign byte_en[t] = ex3_opsize[0] | be3210_en[t];
      end
   end
endgenerate

// Gate off Byte Enables for instructions that have no address checking in the Order Queue
assign ex3_byte_en = byte_en & {16{~(ex3_mfgpr_val | ex3_msgsnd_instr_q)}};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Load Rotate Control Generation
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Table of op_size, Should be 1-hot enabled
// op_size(0) => size16
// op_size(1) => size8
// op_size(2) => size4
// op_size(3) => size2
// op_size(4) => size1
assign ex3_opsize = ex3_mftgpr_val ? 5'b10000 : ({ex3_optype16_q, ex3_optype8_q, ex3_optype4_q, ex3_optype2_q, ex3_optype1_q});

assign ex3_opsize_enc = (ex3_opsize == 5'b10000) ? 3'b110 :
                        (ex3_opsize == 5'b01000) ? 3'b101 :
                        (ex3_opsize == 5'b00100) ? 3'b100 :
                        (ex3_opsize == 5'b00010) ? 3'b010 :
                        (ex3_opsize == 5'b00001) ? 3'b001 :
                        3'b000;

assign ex4_opsize_enc_d = ex3_opsize_enc;
assign ex5_opsize_enc_d = ex4_opsize_enc_q;

assign ex5_opsize = (ex5_opsize_enc_q == 3'b101) ? 4'b1000 :
                    (ex5_opsize_enc_q == 3'b100) ? 4'b0100 :
                    (ex5_opsize_enc_q == 3'b010) ? 4'b0010 :
                    (ex5_opsize_enc_q == 3'b001) ? 4'b0001 :
                    4'b0000;

// Loadhit DVC Compare Byte Valid Generation
assign ex5_byte_mask = (8'h01 /*'*/ & {8{ex5_opsize[4]}}) | (8'h03 & {8{ex5_opsize[3]}}) | (8'h0F /*'*/& {8{ex5_opsize[2]}}) | (8'hFF /*'*/ & {8{ex5_opsize[1]}});

// LOAD PATH LITTLE ENDIAN ROTATOR SELECT CALCULATION
// ld_rot_size   = rot_addr + op_size
// ld_rot_sel_le = rot_addr
// ld_rot_sel    = rot_max_size - ld_rot_size
// ld_rot_sel    = ld_rot_sel_le  => le_mode = 1
//               = ld_rot_sel     => le_mode = 0

// Execution Pipe Rotator Control Calculations
assign ex3_rot_size       = ex3_eff_addr_q[59:63] + ex3_opsize;
assign ex3_rot_sel_non_le = rot_max_size - ex3_rot_size;
assign ex3_alg_bit_le_sel = ex3_rot_size - 5'b00001;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RV Release Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Instruction Report to RV
// Removed SYNC/MBAR/MAKEITSO/TLBSYNC since they are non speculative and they are reported and removed on the LQ_RV_ITAG0 bus
// Work Around for DITC
assign ex5_spec_itag_vld_d = ((ex4_cache_acc_q | ex4_mffgpr_val | ex4_mftgpr_val | ex4_wchk_instr_q | ex4_ditc_val) & ~fgen_ex4_stg_flush_int) |
                                                                               ((ex4_wNComp_excp | ex4_ucode_val_q) & ~fgen_ex4_cp_flush_int)  |
                                                                               stq6_mftgpr_val_q;

assign ex4_spec_itag = stq6_mftgpr_val_q ? stq6_itag_q : ex4_itag_q;
assign ex4_spec_thrd_id = stq6_mftgpr_val_q ? stq6_thrd_id_q : ex4_thrd_id_q;
assign ex5_spec_itag_d = ex4_spec_itag;
assign ex5_spec_tid_d = ex4_spec_thrd_id;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RESTART Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// RESTART_SPEC Indicators
assign ex4_spec_load_miss = (dir_dcc_ex4_miss | derat_dcc_ex4_wimge[1] | spr_xucr0_dcdis_q) & ex4_load_instr_q & ~ex4_blk_touch;
// either a loadmiss, a cache-inhibited load, larx, stcx, or icswx. instructions
assign ex5_spec_load_miss_d = (ex4_spec_load_miss | ex4_resv_instr_q | ex4_icswxdot_instr_q) & ex4_cache_acc_q & ~(fgen_ex4_stg_flush_int | stq6_mftgpr_val_q);

// RESTART Indicators
//  1) STQ   => LSWX that hasn't gotten the XER source
//  2) DIR   => DCBTLS/DCBTSTLS/LDAWX instruction in EX3/EX4 and a reload targetting the same congruence class
//  3) DIR   => Instruction Bypassed Directory results that were restarted
//  4) CTRL  => Request is a CP_NEXT instruction and CP_NEXT_VAL isnt on
//  5) CTRL  => Request is a CP_NEXT exception and CP_NEXT_VAL isnt on
//  6) DERAT => ERATM State machines are all busy
//  7) DERAT => ERATM State machine 0 is busy and oldest itag missed
//  8) DERAT => ERATM State machines 1 to EMQ_ENTRIES are busy and
//              this request is not the oldest
//  9) DERAT => Current Requests ITAG is already using a state machine
// 10) DERAT => Current Requests EPN down to a 4KB page is already using a state machine
// 11) DERAT => Current Requests is sending the NonSpeculative Request to the TLB
// 12) LDQ   => Load hit outstanding LARX for my thread
// 13) LDQ   => New Loadmiss Request to Cache line already in LoadMiss Queue
// 14) LDQ   => New LoadMiss Request and the Queue is full
// 15) LDQ   => New Loadmiss Request and 1 LoadMiss StateMachine available and not the oldest load request
// 16) LDQ   => Load was gathered to a cTag and reload to that cTag started the same cycle
// 17) STQ   => Younger Guarded Load Request collided against an older guarded Store
// 18) STQ   => Younger Load Request hit against an older CP_NEXT store instruction (i.e icbi, sync, stcx, icswx., mftgpr, mfdp)
// 19) STQ   => Younger Load Request Address hit multiple older entries
// 20) STQ   => Younger Load Request Address hit against an older store but endianness differs
// 21) STQ   => Younger Guarded Load Request Address hit against an older store
// 22) STQ   => Younger Load Request Address hit against an older store type with no data associated
// 23) STQ   => Younger Loadmiss Request Cacheline Address hit against older store type
// 24) STQ   => ICSWX that hasn't gotten RS2 data from the FX units
// 25) CTRL  => CP_NEXT instruction needs to be redirected, the 2 younger instructions behind it need a
//              restart since they will bypass from bad instruction
// 26) CTRL  => Ucode PreIssue has not updated the memory attribute bits

assign ex3_lswx_restart     = ex3_ucode_val_q & ex3_load_instr_q & ex3_strg_index_q & ~lsq_ctl_ex3_strg_val;
assign ex4_lswx_restart_d   = ex3_lswx_restart;
assign ex3_icswx_restart    = ex3_cache_acc_q & ex3_icswx_type & ~lsq_ctl_ex3_ct_val;
assign ex4_icswx_restart_d  = ex3_icswx_restart;
assign ex4_2younger_restart = ex4_wNComp_excp_restart & (ex4_cache_acc_q | ex4_ucode_val_q | ex4_wchk_instr_q);
assign ex4_restart_val      = dir_dcc_ex4_set_rel_coll | dir_dcc_ex4_byp_restart | derat_dcc_ex4_restart | ex4_lswx_restart_q | ex4_icswx_restart_q | ex4_2younger_restart | ex4_ucode_restart;
assign ex5_restart_val_d    = ex4_restart_val;
assign ex5_ldq_restart_val  = lsq_ctl_ex5_ldq_restart;
assign ex5_derat_restart_d  = derat_dcc_ex4_restart;
assign ex6_derat_restart_d  = ex5_derat_restart_q;
assign ex5_dir_restart_d    = dir_dcc_ex4_set_rel_coll | dir_dcc_ex4_byp_restart;
assign ex6_dir_restart_d    = ex5_dir_restart_q;
assign ex5_dec_restart_d    = ex4_lswx_restart_q | ex4_icswx_restart_q | ex4_ucode_restart;
assign ex6_dec_restart_d    = ex5_dec_restart_q;
assign ex4_derat_itagHit_d  = derat_dcc_ex3_itagHit;

// Want to restart if loadmiss and didnt forward
assign ex5_stq_restart_miss  = lsq_ctl_ex5_stq_restart_miss & ex5_load_miss_q;
assign ex5_stq_restart_val   = lsq_ctl_ex5_stq_restart | ex5_stq_restart_miss;
assign ex6_stq_restart_val_d = ex5_stq_restart_val;
assign ex5_restart_val       = (ex5_ldq_restart_val | ex5_stq_restart_val | ex5_lq_wNComp_val_q | ex5_restart_val_q) & ex5_spec_itag_vld_q & ~(stq7_mftgpr_val_q | ex5_flush_req);
assign ex6_restart_val_d     = ex5_restart_val;
assign ex5_lq_req_abort      = ((ex5_spec_load_miss_q & ~lsq_ctl_ex5_fwd_val) | ex5_restart_val | ex5_mftgpr_val_q) & ex5_spec_itag_vld_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Completion Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// All instructions that report completion when coming down the pipe
// sfx_val <= src_gpr or src_axu or src_dp   or targ_gpr or targ_axu or targ_dp or mtdp    or mtdpx   or mtdp_dc or mtdpx_dc or mfdp        or
//            mfdpx   or mfdp_dc or mfdpx_dc or mbar     or msgsnd   or sync    or tlbsync or wchkall or dci     or ici      or mtspr_trace or makeitso
assign ex4_excp_rpt_val = (ex4_cache_acc_q | ex4_sfx_val_q | ex4_sfx_excpt_det) & ex4_excp_det;
assign ex4_ucode_rpt = (~ex4_strg_index_q & ~ex4_wNComp_excp & ~(derat_dcc_ex4_restart | ex4_2younger_restart)) | (ex4_excp_det & ~ex4_lswx_restart_q);
assign ex4_ucode_rpt_val = ex4_ucode_val_q & ex4_ucode_rpt;
// I dont think ex4_wNComp_excp_restart needs to be in the equation since mffgpr doesnt use the directory, dataCache, or erats
assign ex4_mffgpr_rpt_val = ex4_mffgpr_val;
assign ex5_execute_vld_d  = (ex4_ucode_rpt_val  |       // Ucode_PreIssue
                             ex4_mffgpr_rpt_val |       // mffgpr
                             ex4_excp_rpt_val)  &       // Exception Detected on a Cache Access
                             ~fgen_ex4_cp_flush_int;

assign ex5_flush2ucode_type_d = ex4_le_mode_q;
assign ex5_recirc_val_d = (ex4_wNComp_req  & ~(ex4_wNComp_rcvd_q | fgen_ex4_stg_flush_int)) |
                          (ex4_wNComp_excp & ~(ex4_wNComp_rcvd_q | fgen_ex4_cp_flush_int));

// Mux between Store Queue Completion Report and Load Pipeline Completion Report
// Load Pipeline has higher priority
assign ex5_lq_comp_rpt_val	  = ( ex5_execute_vld_q | ex5_wchkall_cplt | ex5_flush_req | ex5_recirc_val_q) & ~fgen_ex5_cp_flush;
assign ex6_lq_comp_rpt_d	  = ( ex5_execute_vld_q | ex5_wchkall_cplt | ex5_flush_req)		               & ~fgen_ex5_cp_flush;
assign ex5_execute_vld		  = ((ex5_execute_vld_q | ex5_wchkall_cplt | ex5_flush_req)		               & ~fgen_ex5_cp_flush) |
                                (lsq_ctl_stq_cpl_ready & ~ex5_lq_comp_rpt_val);
assign ex5_recirc_val		  = ex5_recirc_val_q							              & ~(fgen_ex5_cp_flush | ex5_flush_req);
assign lq0_rpt_thrd_id		  = (            ex5_thrd_id_q & {`THREADS{ ex5_lq_comp_rpt_val}}) |
                                (lsq_ctl_stq_cpl_ready_tid & {`THREADS{~ex5_lq_comp_rpt_val}});
assign lq0_iu_execute_vld_d	  = lq0_rpt_thrd_id & {`THREADS{ex5_execute_vld}};
assign lq0_iu_itag_d		  = (                ex5_itag_q & {`ITAG_SIZE_ENC{ ex5_lq_comp_rpt_val}}) |
                                (lsq_ctl_stq_cpl_ready_itag & {`ITAG_SIZE_ENC{~ex5_lq_comp_rpt_val}});
assign lq0_iu_recirc_val_d	  = ex5_thrd_id_q & {`THREADS{ex5_recirc_val}};
assign lq0_iu_flush2ucode_d	  = ex5_flush2ucode & ex5_lq_comp_rpt_val;
assign lq0_iu_flush2ucode_type_d = ex5_flush2ucode_type_q;
assign lq0_iu_dear_val_d	  = ex5_dear_val & {`THREADS{ex5_lq_comp_rpt_val}};
assign lq0_iu_eff_addr_d	  = ex5_eff_addr_q;
assign lq0_iu_n_flush_d		  = (      ex5_n_flush & ex5_lq_comp_rpt_val) | (      lsq_ctl_stq_n_flush & ~ex5_lq_comp_rpt_val);
assign lq0_iu_np1_flush_d	  = (    ex5_np1_flush & ex5_lq_comp_rpt_val) | (    lsq_ctl_stq_np1_flush & ~ex5_lq_comp_rpt_val);
assign lq0_iu_exception_val_d = (ex5_exception_val & ex5_lq_comp_rpt_val) | (lsq_ctl_stq_exception_val & ~ex5_lq_comp_rpt_val);
assign lq0_iu_exception_d	  = (        ex5_exception & {6{ ex5_lq_comp_rpt_val}}) |
                                (lsq_ctl_stq_exception & {6{~ex5_lq_comp_rpt_val}});
assign lq0_iu_dacr_type_d	  = (ex5_dacr_type_q & ex5_lq_comp_rpt_val);
assign lq0_iu_dacrw_d		  = (   ex5_dacrw_cmpr & {4{ ex5_lq_comp_rpt_val}}) |
                                (lsq_ctl_stq_dacrw & {4{~ex5_lq_comp_rpt_val}});
assign lq0_iu_instr_d		  = ex5_instr_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DEBUG ADDRESS COMPARE only report
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Data Address Compare Only Interrupt is detected and reported on LQ0 Completion bus
// Store Pipe Data Value Compare Interrupts are reported on LQ0 Completion bus
// Load Pipe Data Value Compare Interrupts are reported on LQ1 Completion bus
// All Debug Interrupts are PRECISE
assign ex4_dbg_int_en = |(dbg_int_en_q & ex4_thrd_id_q);
assign ex4_dacrw1_cmpr = spr_dcc_ex4_dacrw1_cmpr & ~ex4_blk_touch_instr;
assign ex4_dacrw2_cmpr = spr_dcc_ex4_dacrw2_cmpr & ~ex4_blk_touch_instr;
assign ex4_dacrw3_cmpr = spr_dcc_ex4_dacrw3_cmpr & ~ex4_blk_touch_instr;
assign ex4_dacrw4_cmpr = spr_dcc_ex4_dacrw4_cmpr & ~ex4_blk_touch_instr;
assign ex5_dacrw_cmpr_d = {ex4_dacrw1_cmpr, ex4_dacrw2_cmpr, ex4_dacrw3_cmpr, ex4_dacrw4_cmpr};
assign ex5_dacrw_rpt_val = ~(ex5_flush_req | ex5_flush2ucode);
assign ex5_dacrw_cmpr = ex5_dacrw_cmpr_q & {4{ex5_dacrw_rpt_val}};
assign ex6_dacrw_cmpr_d = ex5_dacrw_cmpr;
assign ex5_dvc_en_d = {spr_dcc_ex4_dvc1_en, spr_dcc_ex4_dvc2_en};
assign ex6_dvc_en_d = ex5_dvc_en_q & {2{ex5_load_hit_q}};

// Debug Address Compare Interrupt detected, Data Value Compare is disabled
// Flushing instructions early
assign ex4_dac_int_det = (ex4_dacrw1_cmpr | ex4_dacrw2_cmpr | ex4_dacrw3_cmpr | ex4_dacrw4_cmpr) &
                        ~(spr_dcc_ex4_dvc1_en | spr_dcc_ex4_dvc2_en) & ex4_dbg_int_en;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// L1 D-Cache Control Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Touch Type Instructions
// ################################################################

// Touch Ops with unsupported TH fields are no-ops
assign ex2_undef_touch = (ex2_dcbt_instr_q    | ex2_dcblc_instr_q    | ex2_dcbtls_instr_q | ex2_dcbtstls_instr_q | ex2_dcbtst_instr_q |
			              ex2_icbt_l2_instr_q | ex2_icblc_l2_instr_q | ex2_icbtls_l2_instr_q) & ~(ex2_th_fld_c_q | ex2_th_fld_l2_q);

assign ex3_undef_touch_d = ex2_undef_touch;
assign ex4_undef_touch_d = ex3_undef_touch_q;

// Cache Unable to Lock Detection
// icblc/dcblc are taken care of by ex4_blk_touch and ex4_l1dc_dis_lockclr
assign ex2_lockset_instr       = ex2_dcbtls_instr_q | ex2_dcbtstls_instr_q | ex2_icbtls_l2_instr_q;
assign ex3_undef_lockset_d     = ex2_lockset_instr & ~(ex2_th_fld_c_q | ex2_th_fld_l2_q);
assign ex4_undef_lockset_d     = ex3_undef_lockset_q;
assign ex4_cinh_lockset        = (ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q | ex4_icbtls_l2_instr_q) & derat_dcc_ex4_wimge[1];
assign ex4_l1dc_dis_lockset    = (ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q) & ex4_th_fld_c_q & spr_xucr0_dcdis_q;
assign ex4_l1dc_dis_lockclr    = ex4_dcblc_instr_q & ex4_th_fld_c_q & spr_xucr0_dcdis_q;
assign ex4_noop_lockset        = (ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q | ex4_icbtls_l2_instr_q) & derat_dcc_ex4_noop_touch;
assign ex5_unable_2lock_d      = (ex4_undef_lockset_q | ex4_cinh_lockset | ex4_l1dc_dis_lockset | ex4_noop_lockset) & ex4_wNComp_rcvd_q & ex4_cache_acc_q & ~fgen_ex4_stg_flush_int;
assign ex6_stq5_unable_2lock_d = (ex5_unable_2lock_q & ~fgen_ex5_stg_flush_int) | lsq_ctl_stq4_xucr0_cul;

// ex3 Data touch ops, DCBT/DCBTST/DCBTLS/DCBTSTLS
assign data_touch_op = ex3_dcbt_instr_q | ex3_dcbtst_instr_q | ex3_dcbtls_instr_q | ex3_dcbtstls_instr_q;
// ex3 Instruction touch ops, ICBT/ICBTLS
assign inst_touch_op = ex3_icbt_l2_instr_q | ex3_icbtls_l2_instr_q;

// Ops that should not execute if translated to cache-inh
assign all_touch_op = data_touch_op | inst_touch_op;

// ex3 DCBTLS/DCBTSTLS instruction that should set the Lock bit for the cacheline
assign ex3_l1_lock_set   = (ex3_dcbtstls_instr_q | ex3_dcbtls_instr_q) & ex3_th_fld_c_q;
assign ex4_l1_lock_set_d = ex3_l1_lock_set;
assign ex5_l1_lock_set_d = ex4_l1_lock_set_q;
assign ex4_c_dcbtls      = ex4_dcbtls_instr_q    & ex4_th_fld_c_q;
assign ex4_c_dcbtstls    = ex4_dcbtstls_instr_q  & ex4_th_fld_c_q;
assign ex4_c_icbtls      = ex4_icbtls_l2_instr_q & ex4_th_fld_c_q;
assign ex4_l2_dcbtls     = ex4_dcbtls_instr_q    & ex4_th_fld_l2_q;
assign ex4_l2_dcbtstls   = ex4_dcbtstls_instr_q  & ex4_th_fld_l2_q;
assign ex4_l2_icbtls     = ex4_icbtls_l2_instr_q & ex4_th_fld_l2_q;
assign ex4_l2_icblc      = ex4_icblc_l2_instr_q  & ex4_th_fld_l2_q;
assign ex4_l2_dcblc      = ex4_dcblc_instr_q     & ex4_th_fld_l2_q;

// ex3 DCBLC/DCBF/DCBI/LWARX/STWCX/DCBZ instruction that should clear the Lock bit for the cacheline
assign is_lock_clr    = (ex3_dcblc_instr_q & ex3_th_fld_c_q) | is_inval_op;
assign ex4_lock_clr_d = is_lock_clr;
assign ex5_lock_clr_d = ex4_lock_clr_q;

// Blockable Touches
assign ex4_c_inh_drop_op_d = (all_touch_op | ex3_icblc_l2_instr_q | ex3_dcblc_instr_q) & ((ex3_cache_acc_q & ~fgen_ex3_stg_flush_int) | ex3_pfetch_val_q);
assign ex4_blkable_touch_d = ex3_dcbt_instr_q | ex3_dcbtst_instr_q | ex3_icbt_l2_instr_q | ex3_undef_touch_q;
assign ex4_excp_touch      = ex4_blkable_touch_q & derat_dcc_ex4_noop_touch;
assign ex4_cinh_touch      = ex4_cache_inhibited & ex4_c_inh_drop_op_q;
assign ex4_blk_touch       = ex4_excp_touch | ex4_cinh_touch | ex4_undef_touch_q | (ex4_pfetch_val_q & (derat_dcc_ex4_wimge[3] | lsq_ctl_sync_in_stq));
assign ex4_blk_touch_instr = ex4_undef_touch_q;
assign ex5_blk_touch_d     = ex4_blk_touch;
assign ex6_blk_touch_d     = ex5_blk_touch_q;

// Sync Type Instructions
// ################################################################

// ex3 HSYNC/LWSYNC/MBAR/TLBSYNC/MAKEITSO
assign is_mem_bar_op = ex3_sync_instr_q | ex3_mbar_instr_q | ex3_tlbsync_instr_q | ex3_makeitso_instr_q;
assign ex4_is_sync_d = is_mem_bar_op & ~fgen_ex3_stg_flush_int;

// Line Invalidating Type Instructions
// ################################################################

// ex3 DCBF/DCBI/LWARX/STWCX/DCBZ/ICSWX instruction that should invalidate the L1 Directory if there is a Hit
assign ex3_icswx_type    = ex3_icswx_instr_q | ex3_icswxdot_instr_q | ex3_icswx_epid_q;
assign ex4_icswx_type    = ex4_icswx_instr_q | ex4_icswxdot_instr_q | ex4_icswx_epid_q;
assign is_inval_op       = ex3_dcbf_instr_q | ex3_dcbi_instr_q | ex3_resv_instr_q | ex3_dcbz_instr_q | ex3_icswx_type;
assign ex4_is_inval_op_d = is_inval_op;

// Hit/Miss Calculation
// ################################################################

// Type of Hit
assign stq3_store_hit    = dir_dcc_stq3_hit & stq3_store_val_q & ~(stq3_ci_q | stq3_resv_q);
assign stq4_store_hit_d  = stq3_store_hit;
assign stq5_store_hit_d  = stq4_store_hit_q;
assign stq6_store_hit_d  = stq5_store_hit_q;
assign ex4_load_hit      = dir_dcc_ex4_hit & ex4_load_type_q & ex4_cache_enabled & ~(fgen_ex4_stg_flush_int | spr_xucr0_dcdis_q | ex4_nogpr_upd);
assign ex5_load_hit_d    = dir_dcc_ex4_hit & ex4_load_type_q & ex4_cache_enabled & ~(spr_xucr0_dcdis_q | ex4_resv_instr_q | ex4_l2_dcbtls | ex4_l2_dcbtstls);
assign ex6_load_hit_d    = ex5_load_hit_q;
assign stq4_dcarr_wren_d = dir_dcc_rel3_dcarr_upd | stq3_store_hit;

// Type of Miss
assign stq3_store_miss   = ~dir_dcc_stq3_hit & (stq3_store_val_q | stq3_resv_q) & ~stq3_ci_q;
assign stq4_store_miss_d = stq3_store_miss;
assign ex4_load_miss     = (dir_dcc_ex4_miss | spr_xucr0_dcdis_q) & ex4_load_type_q & ex4_cache_enabled;
assign ex5_load_miss_d   = ex4_load_miss;
assign ex5_drop_rel_d    = (dir_dcc_ex4_hit & (ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q)) | (ex4_th_fld_l2_q & (ex4_dcbt_instr_q | ex4_dcbtst_instr_q | ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q)) |
                           (ex4_icbt_l2_instr_q | ex4_icbtls_l2_instr_q);

// WIMGE and USR_DEF
// ################################################################

// Cacheline State Bits
assign ex3_le_mode	       = derat_dcc_ex3_wimge_e;
assign ex4_le_mode_d	   = ex3_le_mode;
assign ex5_wimge_i_bits_d  = derat_dcc_ex4_wimge[1];
assign ex5_usr_bits_d	   = derat_dcc_ex4_usr_bits;
assign ex5_classid_d       = derat_dcc_ex4_wlc;
assign ex4_cache_enabled   = (ex4_cache_acc_q | ex4_pfetch_val_q) & ~derat_dcc_ex4_wimge[1];
assign ex4_cache_inhibited = (ex4_cache_acc_q | ex4_pfetch_val_q) &  derat_dcc_ex4_wimge[1];
assign ex4_mem_attr        = {derat_dcc_ex4_usr_bits, derat_dcc_ex4_wimge};
assign ex5_derat_setHold_d = derat_dcc_ex4_setHold;

// Misc. Control
// ################################################################

// LQ Pipe Directory Access Instructions
assign ddir_acc_instr = ex3_load_instr_q | ex3_ldawx_instr_q | data_touch_op;

// Ops that should not update the LRU if a miss or hit
assign ex3_lru_upd = (ex3_load_instr_q & ~ex3_resv_instr_q) | (ex3_ldawx_instr_q & ex3_wNComp_rcvd);

// These instructions should not update the register file but are treated as loads
assign ex4_nogpr_upd = ex4_dcbt_instr_q | ex4_dcbtst_instr_q | ex4_resv_instr_q | ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q;

// Watch Clear if real address matches
assign ex3_watch_clr_entry = ex3_wclr_instr_q &  ex3_l_fld_q[0];
assign ex3_watch_clr_all   = ex3_wclr_instr_q & ~ex3_l_fld_q[0];

// Move Register Type Instructions
assign ex4_moveOp_val_d  = ex3_mffgpr_val | (ex3_upd_form_q & ex3_cache_acc_q);
assign stq6_moveOp_val_d = stq5_mftgpr_val_q | stq5_mfdpf_val_q | stq5_mfdpa_val_q;

// ex4 local dcbf is special, need to check against loadmiss queue,
// but dont want to send request to the L2, since this signal does not set
// ex4_l_s_q_val, need to do an OR statement for setbarr_tid and ex4_n_flush_req
// in case it hits against the loadmiss queue
assign ex4_local_dcbf_d = (ex3_local_dcbf | ex3_watch_clr_entry) & ex3_cache_acc_q & ~fgen_ex3_stg_flush_int;

// Instructions that need to wait for completion
assign ex4_stx_instr  = ex4_store_instr_q & ex4_resv_instr_q;
assign ex4_larx_instr = ex4_load_instr_q & ex4_resv_instr_q;

// misc. instructions
assign ex4_load_val        = ex4_load_instr_q  & ~ex4_resv_instr_q;
assign ex4_store_val       = ex4_store_instr_q & ~ex4_resv_instr_q;
assign ex3_illeg_lswx      = ex3_ucode_val_q & ex3_load_instr_q & ex3_strg_index_q & lsq_ctl_ex3_strg_val & lsq_ctl_ex3_illeg_lswx;
assign ex3_strg_index_noop = ex3_ucode_val_q & ex3_strg_index_q & lsq_ctl_ex3_strg_val & lsq_ctl_ex3_strg_noop;
assign ex4_strg_gate_d     = ex3_lswx_restart | ex3_strg_index_noop;

// Other requests that need to be reported to the ORDERQ
// Work Around for DITC
assign ex4_othreq_val = ex4_mffgpr_val | (ex4_wchk_instr_q & ex4_wNComp_rcvd_q) | ex4_ucode_val_q |
                        ex4_ditc_val;

// wchkall instruction will complete if not flushed or restarted
assign ex5_wchkall_cplt_d = ex4_wchk_instr_q & ex4_wNComp_rcvd_q & ~ex4_restart_val;
assign ex5_wchkall_cplt   = ex5_wchkall_cplt_q & ~lsq_ctl_ex5_stq_restart;

// LoadPipeline is IDLE
assign ldq_idle_d = ~ldp_pfetch_inPipe & ~dir_arr_rd_tid_busy & derat_dcc_emq_idle;

// Performance Event
assign ex6_misalign_flush_d = ex5_cache_acc_q & ex5_misalign_flush & ~fgen_ex5_cp_flush;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LSQ Control Logic
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Ops that flow down the Store Queue and require CACHE_ACC to be valid
assign ex2_stq_val_cacc = (ex2_store_instr_q | ex2_dcbf_instr_q | ex2_dcbi_instr_q  | ex2_dcbz_instr_q     | ex2_wclr_instr_q |
			               ex2_dcbst_instr_q | ex2_icbi_instr_q | ex2_icswx_instr_q | ex2_icswxdot_instr_q | ex2_icswx_epid_q |
			               ex2_dcblc_instr_q | ex2_icblc_l2_instr_q) & ex2_cache_acc_q;

// Ops that flow down the Store Queue and do not require CACHE_ACC to be valid
// Removing DITC
assign ex2_stq_nval_cacc = ex2_msgsnd_instr_q | ex2_mtspr_trace_q   | ex2_dci_instr_q | ex2_ici_instr_q | ex2_sync_instr_q |
                           ex2_mbar_instr_q   | ex2_tlbsync_instr_q | ex2_mftgpr_val  | ex2_makeitso_instr_q;

assign ex2_stq_val_req   = ex2_stq_val_cacc | ex2_stq_nval_cacc | (ex2_strg_index_q & ex2_ucode_val_q);
assign ex3_stq_val_req_d = ex2_stq_val_req   & ~fgen_ex2_stg_flush_int;
assign ex4_stq_val_req_d = ex3_stq_val_req_q & ~fgen_ex3_stg_flush_int;

// Wait for Next Completion Indicator Instructions
generate begin : cpNextItag
      genvar tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : cpNextItag
         assign ex3_wNComp_tid[tid] = ex3_thrd_id_q[tid] & iu_lq_recirc_val_q[tid] & (ex3_itag_q == iu_lq_cp_next_itag_q[tid]);
      end
   end
endgenerate

assign ex3_wNComp_rcvd   = |(ex3_wNComp_tid);
assign ex4_wNComp_rcvd_d = ex3_wNComp_rcvd;
assign ex3_wNComp        = ex3_resv_instr_q      | ex3_icbi_instr_q | ex3_ldawx_instr_q  | ex3_icswx_instr_q    |
                           ex3_icswxdot_instr_q  | ex3_icswx_epid_q | ex3_dcbtls_instr_q | ex3_dcbtstls_instr_q |
                           ex3_icbtls_l2_instr_q | ex3_watch_clr_all;
assign ex4_wNComp_d	 = ex3_wNComp;
assign ex5_wNComp_d	 = ex4_wNComp_q & ~ex4_wNComp_rcvd_q;
assign ex4_guarded_load  = derat_dcc_ex4_wimge[3] & ex4_l2load_type_q;
assign ex5_blk_pf_load_d = (derat_dcc_ex4_wimge[1] | derat_dcc_ex4_wimge[3]) & ex4_l2load_type_q;

// These instructions update a temporary but need to wait for all ops ahead to be completed
// ex4_wchk_instr_q
// These instructions update a temporary and are handled by the load pipe but use the store queue
// ex4_mftgpr_val
// These instructions update a temporary and update a status register
// ex4_mfdpa_val, ex4_mfdpf_val
assign ex4_wNcomp_oth = ex4_wchk_instr_q | ex4_is_sync_q | ex4_mftgpr_val | ex4_mfdpa_val | ex4_mfdpf_val | ex4_is_cinval;
assign ex4_wNComp_req = (((ex4_wNComp_q | ex4_guarded_load) & ex4_cache_acc_q) | ex4_wNcomp_oth);

// Wait for Next Completion Requests that are handled by the LQ Pipe
// These requests are restarted to RV
assign ex4_lq_wNComp_req   = ex4_larx_instr     | ex4_ldawx_instr_q    | ex4_guarded_load      | ex4_wchk_instr_q |
                             ex4_dcbtls_instr_q | ex4_dcbtstls_instr_q | ex4_icbtls_l2_instr_q;
assign ex5_lq_wNComp_val_d = (ex4_wNComp_req & ex4_lq_wNComp_req & ~(ex4_wNComp_rcvd_q | fgen_ex4_stg_flush_int)) |
                             (ex4_wNComp_excp                    & ~(ex4_wNComp_rcvd_q | fgen_ex4_cp_flush_int));
assign ex6_lq_wNComp_val_d = ex5_lq_wNComp_val_q;

// Want to report to RV to hold until CP_NEXT_ITAG matches, then release
// dont want these scenarios to keep recirculating
assign ex5_wNComp_ord_d = ex4_wNComp_req & ex4_lq_wNComp_req & ~(ex4_wNComp_rcvd_q | fgen_ex4_stg_flush_int);

// CR Update is Valid
assign ex5_wNComp_cr_upd_d = ((ex4_ldawx_instr_q & ex4_cache_acc_q) | ex4_wchk_instr_q) & ex4_wNComp_rcvd_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// LSQ Entry Data
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign ex4_cline_chk = (spr_dcc_spr_lsucr0_clchk | ex4_dcbt_instr_q     | ex4_larx_instr        | ex4_dcbtls_instr_q     | ex4_dcbtst_instr_q     |
			            ex4_dcbtstls_instr_q     | ex4_icbt_l2_instr_q  | ex4_icbtls_l2_instr_q | ex4_stx_instr          |
			            ex4_icbi_instr_q         | ex4_dcbf_instr_q     | ex4_dcbi_instr_q      | ex4_dcbz_instr_q       |
			            ex4_dcbst_instr_q        | ex4_icblc_l2_instr_q | ex4_dcblc_instr_q     | derat_dcc_ex4_wimge[1] |
			            ex4_wclr_instr_q         | ex4_ldawx_instr_q    | ex4_icswx_instr_q     | ex4_icswxdot_instr_q   | ex4_icswx_epid_q) &
                        ~(ex4_tgpr_instr_q | ex4_taxu_instr_q | ex4_tdp_instr_q | ex4_msgsnd_instr_q);

// All Store instructions that need to go to the L2
assign ex4_send_l2 = ex4_store_val      | ex4_stx_instr    | (ex4_dcbf_instr_q & (~ex4_local_dcbf_q))   | ex4_dcbi_instr_q | ex4_dcbz_instr_q   | ex4_dcbst_instr_q |
                     ex4_sync_instr_q   | ex4_mbar_instr_q | ex4_tlbsync_instr_q | ex4_l2_icblc         | ex4_l2_dcblc     | ex4_dci_l2_val     | ex4_ici_l2_val    |
                     ex4_msgsnd_instr_q | ex4_icbi_instr_q | ex4_icswx_instr_q   | ex4_icswxdot_instr_q | ex4_icswx_epid_q | ex4_mtspr_trace_en | ex4_makeitso_instr_q;

// All requests that should be dropped
assign ex4_dReq_val = ex4_blk_touch | ex4_ucode_val_q | ex4_mtspr_trace_dis | ex4_is_cinval_drop | ex4_l1dc_dis_lockclr;

// All Store instructions that have data
// Removing DITC
assign ex4_has_data = ex4_store_val | ex4_stx_instr | ex4_icswx_instr_q | ex4_icswxdot_instr_q | ex4_icswx_epid_q | ex4_mftgpr_val | ex4_strg_index_q;

// TTYPE Select
assign ex5_ttype_d = ({6{ex4_load_val}}							                    & 6'b001000) |
		             ({6{ex4_larx_instr}}						                    & ({4'b0010, ex4_mutex_hint_q, 1'b1})) |
		             ({6{((ex4_dcbt_instr_q & ex4_th_fld_c_q) | ex4_c_dcbtls)}}		& 6'b001111) |
                     ({6{(ex4_dcbt_instr_q & ex4_th_fld_l2_q)}}				        & 6'b000111) |
		             ({6{ex4_l2_dcbtls}}						                    & 6'b010111) |
                     ({6{((ex4_dcbtst_instr_q & ex4_th_fld_c_q) | ex4_c_dcbtstls)}}	& 6'b001101) |
		             ({6{(ex4_dcbtst_instr_q & ex4_th_fld_l2_q)}}			        & 6'b000101) |
                     ({6{ex4_l2_dcbtstls}}						                    & 6'b010101) |
		             ({6{(ex4_icbt_l2_instr_q | ex4_c_icbtls)}}				        & 6'b000100) |
                     ({6{ex4_l2_icbtls}}						                    & 6'b010100) |
		             ({6{ex4_store_val}}						                    & 6'b100000) |
                     ({6{ex4_stx_instr}}						                    & 6'b101001) |
		             ({6{ex4_icbi_instr_q}}						                    & 6'b111110) |
                     ({6{(ex4_dcbf_instr_q &  (ex4_l_fld_q == 2'b01))}}			    & 6'b110110) |
                     ({6{(ex4_dcbf_instr_q & ~(ex4_l_fld_q == 2'b01))}}			    & 6'b110111) |
                     ({6{ex4_dcbi_instr_q}}						                    & 6'b111111) |
		             ({6{ex4_dcbz_instr_q}}						                    & 6'b100001) |
		             ({6{ex4_dcbst_instr_q}}						                & 6'b110101) |
		             ({6{(ex4_sync_instr_q & ((ex4_l_fld_q != 2'b01)))}}		    & 6'b101011) |
		             ({6{(ex4_mbar_instr_q &  spr_xucr0_mbar_ack_q)}}			    & 6'b101011) |	//' HWSYNC MODE ENABLED for MBAR
                     ({6{(ex4_mbar_instr_q & ~spr_xucr0_mbar_ack_q)}}			    & 6'b110010) |	//' HWSYNC MODE DISABLED for MBAR
                     ({6{(ex4_sync_instr_q & (ex4_l_fld_q == 2'b01))}}			    & 6'b101010) |
                     ({6{ex4_makeitso_instr_q}}						                & 6'b100011) |
                     ({6{ex4_tlbsync_instr_q}}						                & 6'b111010) |
                     ({6{ex4_icblc_l2_instr_q}}						                & 6'b100100) |
                     ({6{ex4_dcblc_instr_q}}						                & 6'b100101) |
                     ({6{ex4_dci_instr_q}}						                    & 6'b101111) |
                     ({6{ex4_ici_instr_q}}						                    & 6'b101110) |
                     ({6{ex4_msgsnd_instr_q}}						                & 6'b101101) |
                     ({6{ex4_icswx_instr_q}}						                & 6'b100110) |
                     ({6{ex4_icswxdot_instr_q}}						                & 6'b100111) |
                     ({6{ex4_mtspr_trace_q}}						                & 6'b101100) |
                     ({6{ex4_mfdpf_val}}						                    & 6'b011000) |
                     ({6{ex4_mfdpa_val}}						                    & 6'b010000) |
                     ({6{ex4_tdp_instr_q}}						                    & 6'b110000) |
                     ({6{ex4_mftgpr_val}}						                    & 6'b111000);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Directory Read Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

assign dir_arr_rd_cntrl = {spr_dcc_spr_xudbg0_exec, dir_arr_rd_rv1_done};

assign dir_arr_rd_val_d = (dir_arr_rd_cntrl == 2'b10) ? spr_dcc_spr_xudbg0_exec :
                          (dir_arr_rd_cntrl == 2'b01) ? 1'b0 :
                          dir_arr_rd_val_q;

assign dir_arr_rd_tid_d = dir_arr_rd_cntrl[0] ? spr_dcc_spr_xudbg0_tid :
                          dir_arr_rd_tid_q;

// Piping Down Directory Read indicator to match up with need hole request
assign dir_arr_rd_rv1_val_d = dir_arr_rd_val_q;

// Directory Read is done when there isnt a back-invalidate in same stage
// Creating a Pulse, dont want to set done indicator for multiple cycles
assign dir_arr_rd_rv1_done = dir_arr_rd_rv1_val_q & ~(rv1_binv_val_q | dir_arr_rd_ex0_done_q | dir_arr_rd_ex1_done_q | dir_arr_rd_ex2_done_q);

// Piping Down Done indicator to capture directory contents
assign dir_arr_rd_ex0_done_d = dir_arr_rd_rv1_done;
assign dir_arr_rd_ex1_done_d = dir_arr_rd_ex0_done_q;
assign dir_arr_rd_ex2_done_d = dir_arr_rd_ex1_done_q;
assign dir_arr_rd_ex3_done_d = dir_arr_rd_ex2_done_q;
assign dir_arr_rd_ex4_done_d = dir_arr_rd_ex3_done_q;
assign dir_arr_rd_ex5_done_d = dir_arr_rd_ex4_done_q;
assign dir_arr_rd_ex6_done_d = dir_arr_rd_ex5_done_q;

// Directory Read In Progress
assign dir_arr_rd_busy = dir_arr_rd_rv1_val_q  | dir_arr_rd_ex0_done_q | dir_arr_rd_ex1_done_q | dir_arr_rd_ex2_done_q |
                         dir_arr_rd_ex3_done_q | dir_arr_rd_ex4_done_q | dir_arr_rd_ex5_done_q | dir_arr_rd_ex6_done_q;

assign dir_arr_rd_tid_busy = dir_arr_rd_tid_q & {`THREADS{dir_arr_rd_busy}};

// Select Tag
assign dir_arr_rd_tag = (spr_dcc_spr_xudbg0_way == 3'b000) ? dir_dcc_ex4_way_tag_a :
                        (spr_dcc_spr_xudbg0_way == 3'b001) ? dir_dcc_ex4_way_tag_b :
                        (spr_dcc_spr_xudbg0_way == 3'b010) ? dir_dcc_ex4_way_tag_c :
                        (spr_dcc_spr_xudbg0_way == 3'b011) ? dir_dcc_ex4_way_tag_d :
                        (spr_dcc_spr_xudbg0_way == 3'b100) ? dir_dcc_ex4_way_tag_e :
                        (spr_dcc_spr_xudbg0_way == 3'b101) ? dir_dcc_ex4_way_tag_f :
                        (spr_dcc_spr_xudbg0_way == 3'b110) ? dir_dcc_ex4_way_tag_g :
                        dir_dcc_ex4_way_tag_h;

// Select Directory Contents
assign dir_arr_rd_directory = (spr_dcc_spr_xudbg0_way == 3'b000) ? dir_dcc_ex5_way_a_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b001) ? dir_dcc_ex5_way_b_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b010) ? dir_dcc_ex5_way_c_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b011) ? dir_dcc_ex5_way_d_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b100) ? dir_dcc_ex5_way_e_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b101) ? dir_dcc_ex5_way_f_dir :
                              (spr_dcc_spr_xudbg0_way == 3'b110) ? dir_dcc_ex5_way_g_dir :
                              dir_dcc_ex5_way_h_dir;

// Select Directory Tag Parity
assign dir_arr_rd_parity = (spr_dcc_spr_xudbg0_way == 3'b000) ? dir_dcc_ex4_way_par_a :
                           (spr_dcc_spr_xudbg0_way == 3'b001) ? dir_dcc_ex4_way_par_b :
                           (spr_dcc_spr_xudbg0_way == 3'b010) ? dir_dcc_ex4_way_par_c :
                           (spr_dcc_spr_xudbg0_way == 3'b011) ? dir_dcc_ex4_way_par_d :
                           (spr_dcc_spr_xudbg0_way == 3'b100) ? dir_dcc_ex4_way_par_e :
                           (spr_dcc_spr_xudbg0_way == 3'b101) ? dir_dcc_ex4_way_par_f :
                           (spr_dcc_spr_xudbg0_way == 3'b110) ? dir_dcc_ex4_way_par_g :
                           dir_dcc_ex4_way_par_h;

assign dir_arr_rd_lru = dir_dcc_ex5_dir_lru;

// XUDBG0 Register
assign dcc_spr_spr_xudbg0_done = dir_arr_rd_ex5_done_q;

// XUDBG1 Register
assign xudbg1_dir_reg_d    = {dir_arr_rd_directory, dir_arr_rd_lru};
assign xudbg1_parity_reg_d = dir_arr_rd_parity;

generate begin : xudbg1Watch
      genvar tid;
      for (tid=0; tid<4; tid=tid+1) begin : xudbg1Watch
         if (tid < `THREADS) begin : tidVal
            assign dcc_spr_spr_xudbg1_watch[tid] = xudbg1_dir_reg_q[2+tid];
         end
         if (tid >= `THREADS) begin : tidIVal
            assign dcc_spr_spr_xudbg1_watch[tid] = 1'b0;
         end
      end
   end
endgenerate

generate
   if (PARBITS == 4) begin : parityFull
      assign dcc_spr_spr_xudbg1_parity = xudbg1_parity_reg_q;
   end
endgenerate

generate
   if (PARBITS != 4) begin : parityFill
      assign dcc_spr_spr_xudbg1_parity[0:3 - PARBITS] = {4-PARBITS{1'b0}};
      assign dcc_spr_spr_xudbg1_parity[4 - PARBITS:3] = xudbg1_parity_reg_q;
   end
endgenerate

assign dcc_spr_spr_xudbg1_lock  = xudbg1_dir_reg_q[1];
assign dcc_spr_spr_xudbg1_valid = xudbg1_dir_reg_q[0];
assign dcc_spr_spr_xudbg1_lru   = xudbg1_dir_reg_q[2+`THREADS:2+`THREADS+6];

// XUDBG2 Register
assign xudbg2_tag_d = dir_arr_rd_tag;

generate
   if (TAGSIZE == 31) begin : tagFull
      assign dcc_spr_spr_xudbg2_tag = xudbg2_tag_q;
   end
endgenerate
generate
   if (TAGSIZE != 31) begin : tagFill
      assign dcc_spr_spr_xudbg2_tag[33:33+(30-TAGSIZE)] = {31-TAGSIZE{1'b0}};
      assign dcc_spr_spr_xudbg2_tag[33+(31-TAGSIZE):63] = xudbg2_tag_q;
   end
endgenerate

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Register File updates
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

// Staging out Update of AXU on a Reload
assign rel2_axu_wren_d = lsq_ctl_rel1_gpr_val & lsq_ctl_rel1_upd_gpr & lsq_ctl_stq1_axu_val;
assign stq2_axu_val_d  = lsq_ctl_stq1_axu_val;
assign stq3_axu_val_d  = stq2_axu_val_q;
assign stq4_axu_val_d  = stq3_axu_val_q;

assign rel2_ta_gpr_d  = lsq_ctl_rel1_ta_gpr;
assign rel2_xu_wren_d = lsq_ctl_rel1_gpr_val & lsq_ctl_rel1_upd_gpr & (~lsq_ctl_stq1_axu_val);

// Move From DITC to AXU request
// Move Float To GPR request
assign stq6_tgpr_val  = stq6_mfdpa_val_q | stq6_mftgpr_val_q;
assign reg_upd_ta_gpr = stq6_tgpr_val ? stq6_tgpr_q : ex4_target_gpr_q;

assign lq_wren  =  ex4_load_hit & ~ex4_axu_op_val_q;
assign axu_wren = (ex4_load_hit &  ex4_axu_op_val_q) | ex4_mffgpr_val | stq6_mfdpa_val_q;

assign ex5_lq_wren_d   = lq_wren;
assign ex5_lq_wren     = ex5_lq_wren_q | (lsq_ctl_ex5_fwd_val & ~ex5_axu_op_val_q);
assign ex6_lq_wren_d   = ex5_lq_wren;
assign ex5_axu_wren_d  = axu_wren;
assign ex6_axu_wren_d  = ex5_axu_wren_q;
assign ex5_lq_ta_gpr_d = reg_upd_ta_gpr;
assign ex6_lq_ta_gpr_d = ex5_lq_ta_gpr_q[AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC):AXU_TARGET_ENC-1];
assign ex5_load_le_d   = derat_dcc_ex4_wimge[4];

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RAM Control
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// RAM Active Thread
assign pc_lq_ram_active_d = pc_lq_ram_active;

// Active Thread for a pipeline instruction
assign ex6_ram_thrd	       = pc_lq_ram_active_q & ex6_thrd_id_q;
assign ex6_ram_active_thrd = ex6_ram_thrd & {`THREADS{(ex6_lq_wren_q | ex6_axu_wren_q)}};

// Active Thread for a MFTGPR instruction
assign stq8_ram_thrd	    = pc_lq_ram_active_q & stq8_thrd_id_q;
assign stq8_ram_active_thrd = stq8_ram_thrd & {`THREADS{stq8_mftgpr_val_q}};

// Active Thread for a reload
assign rel2_ram_thrd	    = pc_lq_ram_active_q & stq2_thrd_id_q;
assign rel2_ram_active_thrd = rel2_ram_thrd & {`THREADS{(rel2_xu_wren_q | rel2_axu_wren_q)}};

// RAM Data Valid
assign lq_ram_data_val	    = ex6_ram_active_thrd | stq8_ram_active_thrd | rel2_ram_active_thrd;
assign lq_pc_ram_data_val_d = |(lq_ram_data_val);

// RAM Data ACT
assign dcc_byp_ram_act = |(lq_ram_data_val);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Performance Events
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Events that need to be reported to Completion
assign perf_com_loadmiss     = ex5_cache_acc_q  & ex5_load_instr_q  &     ex5_load_miss_q & ~lsq_ctl_ex5_fwd_val;
assign perf_com_loads	     = ex5_cache_acc_q  & ex5_load_instr_q  & ~ex5_wimge_i_bits_q;
assign perf_com_cinh_loads   = ex5_cache_acc_q  & ex5_load_instr_q  &  ex5_wimge_i_bits_q;
assign perf_com_dcbt_hit     = ex5_cache_acc_q  & ex5_perf_dcbt_q   &      ex5_load_hit_q;
assign perf_com_dcbt_sent    = ex5_cache_acc_q  & ex5_perf_dcbt_q   &     ex5_load_miss_q;
assign perf_com_axu_load     = ex5_cache_acc_q  & ex5_axu_op_val_q  &    ex5_load_instr_q;
assign perf_com_load_fwd     = ex5_cache_acc_q  & ex5_load_instr_q  & lsq_ctl_ex5_fwd_val;
assign perf_com_watch_set    = ex5_cache_acc_q  & ex5_ldawx_instr_q;
assign perf_com_watch_dup    = ex5_cache_acc_q  & ex5_ldawx_instr_q & dir_dcc_ex5_cr_rslt;
assign perf_com_wchkall      = ex5_wchkall_cplt;
assign perf_com_wchkall_succ = ex5_wchkall_cplt & ~dir_dcc_ex5_cr_rslt;
assign ex5_cmmt_events       = {perf_com_loads,     perf_com_loadmiss,  perf_com_cinh_loads, perf_com_load_fwd,
                                perf_com_axu_load,  perf_com_dcbt_sent, perf_com_dcbt_hit,   perf_com_watch_set,
                                perf_com_watch_dup, perf_com_wchkall,   perf_com_wchkall_succ};

// STQ Pipeline Events that do not need to be reported to Completion
assign perf_stq_stores	   = stq4_store_val_q;
assign perf_stq_store_miss = stq4_store_miss_q;
assign perf_stq_stcx_exec  = stq4_rec_stcx_q;
assign perf_stq_axu_store  = stq4_store_val_q & stq4_axu_val_q;
assign perf_stq_wclr       = stq4_wclr_val_q;
assign perf_stq_wclr_set   = stq4_wclr_val_q & stq4_wclr_all_set_q;
assign stq_perf_events     = {perf_stq_stores,    perf_stq_store_miss, perf_stq_stcx_exec,
                              perf_stq_axu_store, perf_stq_wclr,       perf_stq_wclr_set, stq4_thrd_id_q};

// LDQ Pipeline Events
assign perf_ex6_derat_attmpts   = 1'b0;
assign perf_ex6_derat_restarts  = ex6_cache_acc_q  & ex6_restart_val_q & ex6_derat_restart_q;
assign perf_ex6_pfetch_iss      = ex6_pfetch_val_q;
assign perf_ex6_pfetch_hit      = ex6_pfetch_val_q & ex6_load_hit_q;
assign perf_ex6_pfetch_emiss    = ex6_pfetch_val_q & ex6_blk_touch_q;
assign perf_ex6_pfetch_ldq_full = ex6_pfetch_val_q & lsq_ctl_ex6_ldq_events[0];
assign perf_ex6_pfetch_ldq_hit  = ex6_pfetch_val_q & lsq_ctl_ex6_ldq_events[1];
assign perf_ex6_pfetch_stq      = ex6_pfetch_val_q & ex6_stq_restart_val_q;
assign perf_ex6_align_flush     = ex6_cache_acc_q  & ex6_misalign_flush_q;
assign perf_ex6_dir_restart     = ex6_cache_acc_q  & ex6_restart_val_q & ex6_dir_restart_q;
assign perf_ex6_dec_restart     = ex6_cache_acc_q  & ex6_restart_val_q & ex6_dec_restart_q;
assign perf_ex6_wNComp_restart  = ex6_cache_acc_q  & ex6_restart_val_q & ex6_lq_wNComp_val_q;
assign perf_ex6_ldq_full        = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_ldq_events[0];
assign perf_ex6_ldq_hit         = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_ldq_events[1];
assign perf_ex6_lgq_full        = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_ldq_events[2];
assign perf_ex6_lgq_hit         = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_ldq_events[3];
assign perf_ex6_stq_sametid     = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_stq_events[0];
assign perf_ex6_stq_difftid     = ex6_cache_acc_q  & ex6_restart_val_q & lsq_ctl_ex6_stq_events[1];

assign ex6_dcc_perf_events     = {perf_ex6_derat_attmpts,  perf_ex6_derat_restarts, perf_ex6_pfetch_iss,
                                  perf_ex6_pfetch_hit,     perf_ex6_pfetch_emiss,   perf_ex6_pfetch_ldq_full,
                                  perf_ex6_pfetch_ldq_hit, perf_ex6_pfetch_stq,     perf_ex6_dir_restart,
                                  perf_ex6_dec_restart,    perf_ex6_wNComp_restart, perf_ex6_ldq_full,
                                  perf_ex6_ldq_hit,        perf_ex6_lgq_full,       perf_ex6_lgq_hit,
                                  perf_ex6_stq_sametid,    perf_ex6_stq_difftid,    perf_ex6_align_flush, ex6_thrd_id_q};

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Flush Generation
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
lq_fgen fgen(

   // IU Dispatch to RV0
   .ex0_i0_vld(ex0_i0_vld_q),
   .ex0_i0_ucode_preissue(ex0_i0_ucode_preissue_q),
   .ex0_i0_2ucode(ex0_i0_2ucode_q),
   .ex0_i0_ucode_cnt(ex0_i0_ucode_cnt_q),
   .ex0_i1_vld(ex0_i1_vld_q),
   .ex0_i1_ucode_preissue(ex0_i1_ucode_preissue_q),
   .ex0_i1_2ucode(ex0_i1_2ucode_q),
   .ex0_i1_ucode_cnt(ex0_i1_ucode_cnt_q),

   // Execution Pipe
   .dec_dcc_ex1_expt_det(dec_dcc_ex1_expt_det),
   .dec_dcc_ex1_priv_prog(dec_dcc_ex1_priv_prog),
   .dec_dcc_ex1_hypv_prog(dec_dcc_ex1_hypv_prog),
   .dec_dcc_ex1_illeg_prog(dec_dcc_ex1_illeg_prog),
   .dec_dcc_ex1_dlock_excp(dec_dcc_ex1_dlock_excp),
   .dec_dcc_ex1_ilock_excp(dec_dcc_ex1_ilock_excp),
   .dec_dcc_ex1_ehpriv_excp(dec_dcc_ex1_ehpriv_excp),
   .byp_dcc_ex2_req_aborted(byp_dcc_ex2_req_aborted),

   // Control
   .ex3_stg_act(ex3_stg_act_q),
   .ex4_stg_act(ex4_stg_act_q),
   .ex1_thrd_id(dec_dcc_ex1_thrd_id),
   .ex2_thrd_id(ex2_thrd_id_q),
   .ex3_thrd_id(ex3_thrd_id_q),
   .ex4_thrd_id(ex4_thrd_id_q),
   .ex5_thrd_id(ex5_thrd_id_q),
   .ex3_cache_acc(ex3_cache_acc_q),
   .ex3_ucode_val(ex3_ucode_val_q),
   .ex3_ucode_cnt(ex3_ucode_cnt_q),
   .ex4_ucode_op(ex4_ucode_op_q),
   .ex4_mem_attr(ex4_mem_attr),
   .ex4_blkable_touch(ex4_blkable_touch_q),
   .ex3_ldst_fexcpt(ex3_ldst_fexcpt_q),
   .ex3_axu_op_val(ex3_axu_op_val_q),
   .ex3_axu_instr_type(ex3_axu_instr_type_q),
   .ex3_optype16(ex3_optype16_q),
   .ex3_optype8(ex3_optype8_q),
   .ex3_optype4(ex3_optype4_q),
   .ex3_optype2(ex3_optype2_q),
   .ex3_eff_addr(ex3_eff_addr_q[57:63]),
   .ex3_icswx_type(ex3_icswx_type),
   .ex3_dcbz_instr(ex3_dcbz_instr_q),
   .ex3_resv_instr(ex3_resv_instr_q),
   .ex3_mword_instr(ex3_mword_instr_q),
   .ex3_ldawx_instr(ex3_ldawx_instr_q),
   .ex3_illeg_lswx(ex3_illeg_lswx),
   .ex4_icswx_dsi(ex4_icswx_dsi),
   .ex4_wclr_all_val(ex4_wclr_all_val),
   .ex4_wNComp_rcvd(ex4_wNComp_rcvd_q),
   .ex4_dac_int_det(ex4_dac_int_det),
   .ex4_strg_gate(ex4_strg_gate_q),
   .ex4_restart_val(ex4_restart_val),
   .ex5_restart_val(ex5_restart_val),

   // SPR Bits
   .spr_ccr2_ucode_dis(spr_ccr2_ucode_dis_q),
   .spr_ccr2_notlb(spr_ccr2_notlb_q),
   .spr_xucr0_mddp(spr_xucr0_mddp_q),
   .spr_xucr0_mdcp(spr_xucr0_mdcp_q),
   .spr_xucr4_mmu_mchk(spr_xucr4_mmu_mchk_q),
   .spr_xucr4_mddmh(spr_xucr4_mddmh_q),

   // ERAT Interface
   .derat_dcc_ex4_restart(derat_dcc_ex4_restart),
   .derat_dcc_ex4_wimge_w(derat_dcc_ex4_wimge[0]),
   .derat_dcc_ex4_wimge_i(derat_dcc_ex4_wimge[1]),
   .derat_dcc_ex4_miss(derat_dcc_ex4_miss),
   .derat_dcc_ex4_tlb_err(derat_dcc_ex4_tlb_err),
   .derat_dcc_ex4_dsi(derat_dcc_ex4_dsi),
   .derat_dcc_ex4_vf(derat_dcc_ex4_vf),
   .derat_dcc_ex4_multihit_err_det(derat_dcc_ex4_multihit_err_det),
   .derat_dcc_ex4_multihit_err_flush(derat_dcc_ex4_multihit_err_flush),
   .derat_dcc_ex4_tlb_inelig(derat_dcc_ex4_tlb_inelig),
   .derat_dcc_ex4_pt_fault(derat_dcc_ex4_pt_fault),
   .derat_dcc_ex4_lrat_miss(derat_dcc_ex4_lrat_miss),
   .derat_dcc_ex4_tlb_multihit(derat_dcc_ex4_tlb_multihit),
   .derat_dcc_ex4_tlb_par_err(derat_dcc_ex4_tlb_par_err),
   .derat_dcc_ex4_lru_par_err(derat_dcc_ex4_lru_par_err),
   .derat_dcc_ex4_par_err_det(derat_dcc_ex4_par_err_det),
   .derat_dcc_ex4_par_err_flush(derat_dcc_ex4_par_err_flush),
   .derat_fir_par_err(derat_fir_par_err),
   .derat_fir_multihit(derat_fir_multihit),

   // D$ Parity Error Detected
   .dir_dcc_ex5_dir_perr_det(dir_dcc_ex5_dir_perr_det),
   .dir_dcc_ex5_dc_perr_det(dir_dcc_ex5_dc_perr_det),
   .dir_dcc_ex5_dir_perr_flush(dir_dcc_ex5_dir_perr_flush),
   .dir_dcc_ex5_dc_perr_flush(dir_dcc_ex5_dc_perr_flush),
   .dir_dcc_ex5_multihit_det(dir_dcc_ex5_multihit_det),
   .dir_dcc_ex5_multihit_flush(dir_dcc_ex5_multihit_flush),
   .dir_dcc_stq4_dir_perr_det(dir_dcc_stq4_dir_perr_det),
   .dir_dcc_stq4_multihit_det(dir_dcc_stq4_multihit_det),
   .dir_dcc_ex5_stp_flush(dir_dcc_ex5_stp_flush),

   // SPR's
   .spr_xucr0_aflsta(spr_xucr0_aflsta_q),
   .spr_xucr0_flsta(spr_xucr0_flsta_q),
   .spr_ccr2_ap(spr_ccr2_ap_q),
   .spr_msr_fp(spr_msr_fp),
   .spr_msr_spv(spr_msr_spv),

   // Instruction Flush
   .iu_lq_cp_flush(iu_lq_cp_flush_q),

   // Flush Pipe Outputs
   .ex4_ucode_restart(ex4_ucode_restart),
   .ex4_sfx_excpt_det(ex4_sfx_excpt_det),
   .ex4_excp_det(ex4_excp_det),
   .ex4_wNComp_excp(ex4_wNComp_excp),
   .ex4_wNComp_excp_restart(ex4_wNComp_excp_restart),
   .ex5_flush_req(ex5_flush_req),
   .ex5_blk_tlb_req(ex5_blk_tlb_req),
   .ex5_flush_pfetch(ex5_flush_pfetch),
   .fgen_ex4_cp_flush(fgen_ex4_cp_flush_int),
   .fgen_ex5_cp_flush(fgen_ex5_cp_flush),
   .fgen_ex1_stg_flush(fgen_ex1_stg_flush_int),
   .fgen_ex2_stg_flush(fgen_ex2_stg_flush_int),
   .fgen_ex3_stg_flush(fgen_ex3_stg_flush_int),
   .fgen_ex4_stg_flush(fgen_ex4_stg_flush_int),
   .fgen_ex5_stg_flush(fgen_ex5_stg_flush_int),

   // Completion Indicators
   .ex5_flush2ucode(ex5_flush2ucode),
   .ex5_n_flush(ex5_n_flush),
   .ex5_np1_flush(ex5_np1_flush),
   .ex5_exception_val(ex5_exception_val),
   .ex5_exception(ex5_exception),
   .ex5_dear_val(ex5_dear_val),

   // Performance Events
   .ex5_misalign_flush(ex5_misalign_flush),

   // Error Reporting
   .lq_pc_err_derat_parity(lq_pc_err_derat_parity),
   .lq_pc_err_dir_ldp_parity(lq_pc_err_dir_ldp_parity),
   .lq_pc_err_dir_stp_parity(lq_pc_err_dir_stp_parity),
   .lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
   .lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
   .lq_pc_err_dir_ldp_multihit(lq_pc_err_dir_ldp_multihit),
   .lq_pc_err_dir_stp_multihit(lq_pc_err_dir_stp_multihit),

   //pervasive
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
   .scan_in(fgen_scan_in),
   .scan_out(fgen_scan_out)
);

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Execution Pipe Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign dcc_dir_ex2_frc_align2  = ex2_ldst_falign_q & ex2_optype2_q;
assign dcc_dir_ex2_frc_align4  = ex2_ldst_falign_q & ex2_optype4_q;
assign dcc_dir_ex2_frc_align8  = ex2_ldst_falign_q & ex2_optype8_q;
assign dcc_dir_ex2_frc_align16 = ex2_ldst_falign_q & ex2_optype16_q;
assign dcc_dir_spr_xucr2_rmt   = way_lck_rmt;
assign dcc_dir_ex2_64bit_agen  = ex2_lsu_64bit_agen_q;
assign dcc_dir_ex4_p_addr      = ex4_p_addr[64-`REAL_IFAR_WIDTH:63-(`DC_SIZE- 3)];

assign ctl_dat_ex3_opsize        = ex3_opsize;
assign ctl_dat_ex3_le_mode       = ex3_le_mode;
assign ctl_dat_ex3_le_ld_rotsel  = ex3_eff_addr_q[60:63];
assign ctl_dat_ex3_be_ld_rotsel  = ex3_rot_sel_non_le[1:4];
assign ctl_dat_ex3_algebraic     = ex3_algebraic_q;
assign ctl_dat_ex3_le_alg_rotsel = ex3_alg_bit_le_sel[1:4];
assign dcc_byp_ex4_moveOp_val    = ex4_moveOp_val_q;
assign dcc_byp_stq6_moveOp_val   = stq6_moveOp_val_q;
assign dcc_byp_ex4_move_data     = ex4_eff_addr_q;
assign dcc_byp_ex5_lq_req_abort  = ex5_lq_req_abort;
assign dcc_byp_ex5_byte_mask     = ex5_byte_mask[(8-((2 ** `GPR_WIDTH_ENC)/8)):7];
assign dcc_byp_ex6_thrd_id       = ex6_thrd_id_q;
assign dcc_byp_ex6_dvc1_en       = ex6_dvc_en_q[0];
assign dcc_byp_ex6_dvc2_en       = ex6_dvc_en_q[1];
assign dcc_byp_ex6_dacr_cmpr     = ex6_dacrw_cmpr_q;
assign dcc_dec_arr_rd_rv1_val    = dir_arr_rd_rv1_done;
assign dcc_dec_arr_rd_congr_cl   = spr_dcc_spr_xudbg0_row;
assign dcc_dec_stq3_mftgpr_val   = stq3_mftgpr_val_q;
assign dcc_dec_stq5_mftgpr_val   = stq5_mftgpr_val_q;
assign ctl_lsq_ex2_streq_val     = ex2_thrd_id_q & {`THREADS{ex2_stq_val_req}};
assign ctl_lsq_ex2_itag          = ex2_itag_q;
assign ctl_lsq_ex2_thrd_id       = ex2_thrd_id_q;
assign ctl_lsq_ex3_ldreq_val     = ex3_thrd_id_q & {`THREADS{(ex3_cache_acc_q & ex4_l2load_type_d)}};
assign ctl_lsq_ex3_wchkall_val   = ex3_thrd_id_q & {`THREADS{ex3_wchk_instr_q}};
assign ctl_lsq_ex3_pfetch_val    = ex3_pfetch_val_q;
assign ctl_lsq_ex3_byte_en	     = ex3_byte_en;
assign ctl_lsq_ex3_p_addr	     = ex3_eff_addr_q[58:63];
assign ctl_lsq_ex3_thrd_id	     = ex3_thrd_id_q;
assign ctl_lsq_ex3_algebraic	 = ex3_algebraic_q;
assign ctl_lsq_ex3_opsize	     = ex3_opsize_enc;

// these should be 1-hot (ex4_ldreq_val & ex4_binvreq_val & ex4_streq_val & ex4_othreq_val)
assign ctl_lsq_ex4_ldreq_val	= ex4_cache_acc_q & ex4_l2load_type_q & (~ex4_wNComp_req | ex4_wNComp_rcvd_q) & ~(fgen_ex4_stg_flush_int | ex4_restart_val);
assign ctl_lsq_ex4_binvreq_val	= ex4_binv_val_q;
assign ctl_lsq_ex4_streq_val	= ex4_stq_val_req_q & ~(fgen_ex4_stg_flush_int | ex4_restart_val);
assign ctl_lsq_ex4_othreq_val	= ex4_othreq_val    & ~(fgen_ex4_stg_flush_int | ex4_restart_val);
assign ctl_lsq_ex4_p_addr	    = ex4_p_addr[64-`REAL_IFAR_WIDTH:57];
assign ctl_lsq_ex4_dReq_val	    = ex4_dReq_val;
assign ctl_lsq_ex4_gath_load	= ex4_gath_load_q;
assign ctl_lsq_ex4_send_l2	    = ex4_send_l2;
assign ctl_lsq_ex4_has_data	    = ex4_has_data;
assign ctl_lsq_ex4_cline_chk	= ex4_cline_chk;
assign ctl_lsq_ex4_wimge	    = derat_dcc_ex4_wimge;
assign ctl_lsq_ex4_byte_swap	= ex4_le_mode_q;
assign ctl_lsq_ex4_is_sync	    = ex4_is_sync_q;
assign ctl_lsq_ex4_all_thrd_chk = ex4_dci_instr_q & (ex4_th_fld_l2_q | ex4_th_fld_c_q);
assign ctl_lsq_ex4_is_store	    = ex4_store_val;
assign ctl_lsq_ex4_is_resv	    = ex4_resv_instr_q;
assign ctl_lsq_ex4_is_mfgpr	    = ex4_mftgpr_val | ex4_mfdpf_val | ex4_mfdpa_val;
assign ctl_lsq_ex4_is_icswxr	= ex4_icswx_instr_q | ex4_icswxdot_instr_q | ex4_icswx_epid_q;
assign ctl_lsq_ex4_is_icbi	    = ex4_icbi_instr_q;
assign ctl_lsq_ex4_watch_clr	= ex4_wclr_instr_q;
assign ctl_lsq_ex4_watch_clr_all = ex4_wclr_all_val;
assign ctl_lsq_ex4_mtspr_trace	= ex4_mtspr_trace_q;
assign ctl_lsq_ex4_is_inval_op	= ex4_is_inval_op_q;
assign ctl_lsq_ex4_is_cinval	= ex4_is_cinval;
assign ctl_lsq_ex5_lock_clr	    = ex5_lock_clr_q;
assign ctl_lsq_ex5_lock_set	    = ex5_l1_lock_set_q;
assign ctl_lsq_ex5_watch_set	= ex5_ldawx_instr_q;
assign ctl_lsq_ex5_tgpr		    = ex5_target_gpr_q;
assign ctl_lsq_ex5_axu_val	    = ex5_axu_op_val_q;
assign ctl_lsq_ex5_is_epid	    = ex5_icswx_epid_q;
assign ctl_lsq_ex5_usr_def	    = ex5_usr_bits_q;
assign ctl_lsq_ex5_not_touch	= ex5_load_instr_q;
assign ctl_lsq_ex5_class_id	    = ex5_classid_q;
assign ctl_lsq_ex5_dvc		    = ex5_dvc_en_q;
assign ctl_lsq_ex5_dacrw	    = ex5_dacrw_cmpr_q;
assign ctl_lsq_ex5_ttype	    = ex5_ttype_q;
assign ctl_lsq_ex5_l_fld	    = ex5_l_fld_q;
assign ctl_lsq_ex5_load_hit	    = ex5_load_hit_q;
assign ctl_lsq_ex5_drop_rel	    = ex5_drop_rel_q;
assign ctl_lsq_ex5_flush_req	= ex5_flush_req;
assign ctl_lsq_ex5_flush_pfetch = ex5_flush_pfetch | ex5_restart_val_q;
assign ctl_lsq_ex5_cmmt_events  = ex5_cmmt_events;
assign ctl_lsq_ex5_perf_val0    = &(ex5_spr_lesr[0:1]);
assign ctl_lsq_ex5_perf_sel0    = ex5_spr_lesr[2:5];
assign ctl_lsq_ex5_perf_val1    = &(ex5_spr_lesr[6:7]);
assign ctl_lsq_ex5_perf_sel1    = ex5_spr_lesr[8:11];
assign ctl_lsq_ex5_perf_val2    = &(ex5_spr_lesr[12:13]);
assign ctl_lsq_ex5_perf_sel2    = ex5_spr_lesr[14:17];
assign ctl_lsq_ex5_perf_val3    = &(ex5_spr_lesr[18:19]);
assign ctl_lsq_ex5_perf_sel3    = ex5_spr_lesr[20:23];
assign ctl_lsq_stq3_icswx_data	= {stq3_icswx_data_q[0:10], 2'b00, stq3_icswx_data_q[11:24]};
assign ctl_lsq_stq_cpl_blk	    = ex5_lq_comp_rpt_val;
assign ctl_lsq_rv1_dir_rd_val	= dir_arr_rd_rv1_done;
assign ctl_lsq_dbg_int_en	    = dbg_int_en_q;
assign ctl_lsq_ldp_idle         = ldq_idle_q;
assign stq4_dcarr_wren		    = stq4_dcarr_wren_q;
assign dcc_byp_ram_sel		    = |(rel2_ram_active_thrd);
assign dcc_dec_ex5_wren		    = ex5_lq_wren;
assign dcc_byp_rel2_stg_act	    = stq2_stg_act_q;
assign dcc_byp_rel3_stg_act	    = stq3_stg_act_q;
assign lq_xu_ex5_abort          = ex5_lq_req_abort | dec_dcc_ex5_req_abort_rpt;
assign lq_xu_gpr_ex5_wa		    = ex5_lq_ta_gpr_q;
assign lq_rv_gpr_ex6_wa		    = ex6_lq_ta_gpr_q;
assign lq_xu_axu_rel_we		    = rel2_axu_wren_q;
assign lq_xu_gpr_rel_we		    = rel2_xu_wren_q;
assign lq_xu_gpr_rel_wa		    = rel2_ta_gpr_q;
assign lq_rv_gpr_rel_we		    = rel2_xu_wren_q;
assign lq_rv_gpr_rel_wa		    = rel2_ta_gpr_q[AXU_TARGET_ENC-(`GPR_POOL_ENC+`THREADS_POOL_ENC):AXU_TARGET_ENC-1];
assign lq_xu_cr_ex5_we		    = ex5_wNComp_cr_upd_q;
assign lq_xu_cr_ex5_wa		    = ex5_cr_fld_q;
assign lq_xu_ex5_cr		        = ex5_cr_wd;
assign dcc_dir_ex2_binv_val	    = ex2_binv_val_q;
assign dcc_dir_ex2_thrd_id	    = ex2_thrd_id_q;
assign dcc_dir_ex3_lru_upd	    = ex3_lru_upd;
assign dcc_dir_ex3_cache_acc	= ex3_cache_acc_q & ex3_load_type;
assign dcc_dir_ex3_pfetch_val	= ex3_pfetch_val_q;
assign dcc_derat_ex3_strg_noop	= ex3_lswx_restart | ex3_strg_index_noop;
assign dcc_derat_ex5_blk_tlb_req = ex5_blk_tlb_req;
assign dcc_derat_ex6_cplt	    = ex6_thrd_id_q & {`THREADS{ex6_lq_comp_rpt_q}};
assign dcc_derat_ex6_cplt_itag	= ex6_itag_q;
assign dcc_dir_ex3_lock_set	    = (ex3_dcbtstls_instr_q | ex3_dcbtls_instr_q) & ex3_cache_acc_q & ex3_wNComp_rcvd;
assign dcc_dir_ex3_th_c		    = ex3_th_fld_c_q;
assign dcc_dir_ex3_watch_set	= ex3_ldawx_instr_q & ex3_cache_acc_q & ex3_wNComp_rcvd;
assign dcc_dir_ex3_larx_val	    = ex3_load_instr_q & ex3_resv_instr_q & ex3_cache_acc_q & ex3_wNComp_rcvd;
assign dcc_dir_ex3_watch_chk	= ex3_wchk_instr_q & ex3_wNComp_rcvd;
assign dcc_dir_ex3_ddir_acc	    = ddir_acc_instr & ((ex3_cache_acc_q & ~(derat_dcc_ex3_itagHit | fgen_ex3_stg_flush_int)) | ex3_pfetch_val_q);
assign dcc_dir_ex4_load_val     = ex4_load_val & ex4_cache_enabled & ~(spr_xucr0_dcdis_q | ex4_derat_itagHit_q);   // Want to gate off parity detection if dcdis=1 or DERAT Itag Hit
assign dcc_spr_ex3_data_val	    = (ex3_load_instr_q | ex3_store_instr_q) & ~ex3_axu_op_val_q;
assign dcc_spr_ex3_eff_addr	    = ex3_eff_addr_q;
assign dcc_dir_stq6_store_val   = stq6_store_hit_q;
assign lq_pc_ram_data_val	    = lq_pc_ram_data_val_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs to LQ Pervasive
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign ctl_perv_ex6_perf_events  = ex6_dcc_perf_events;
assign ctl_perv_stq4_perf_events = stq_perf_events;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs to Reservation Station
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign lq_rv_itag1_vld		= ex5_spec_tid_q & {`THREADS{ex5_spec_itag_vld_q}};
assign lq_rv_itag1		    = ex5_spec_itag_q;
assign lq_rv_itag1_restart	= ex5_restart_val;
assign lq_rv_itag1_abort    = ex5_lq_req_abort;
assign lq_rv_itag1_hold		= (lsq_ctl_rv_set_hold | ex5_derat_setHold_q) & ex5_restart_val;
assign lq_rv_itag1_cord		= ex5_wNComp_ord_q & ~ex5_flush_req;
assign lq_rv_clr_hold		= lsq_ctl_rv_clr_hold | derat_dcc_clr_hold;
assign dcc_dec_hold_all		= dir_arr_rd_val_q | lsq_ctl_rv_hold_all;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs to Completion
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign lq0_iu_execute_vld	= lq0_iu_execute_vld_q;
assign lq0_iu_flush2ucode_type	= lq0_iu_flush2ucode_type_q;
assign lq0_iu_recirc_val	= lq0_iu_recirc_val_q;
assign lq0_iu_itag		    = lq0_iu_itag_q;
assign lq0_iu_flush2ucode	= lq0_iu_flush2ucode_q;
assign lq0_iu_n_flush		= lq0_iu_n_flush_q;
assign lq0_iu_np1_flush		= lq0_iu_np1_flush_q;
assign lq0_iu_exception_val	= lq0_iu_exception_val_q;
assign lq0_iu_exception		= lq0_iu_exception_q;
assign lq0_iu_dear_val		= lq0_iu_dear_val_q;
assign lq0_iu_eff_addr		= lq0_iu_eff_addr_q;
assign lq0_iu_dacr_type		= lq0_iu_dacr_type_q;
assign lq0_iu_dacrw		    = lq0_iu_dacrw_q;
assign lq0_iu_instr		    = lq0_iu_instr_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Outputs to Prefetch
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign dcc_pf_ex5_eff_addr	  = ex5_eff_addr_q[64-(2 ** `GPR_WIDTH_ENC):59];
assign dcc_pf_ex5_req_val_4pf = ex5_cache_acc_q & ex5_load_instr_q & ~ex5_wNComp_q & ~ex5_lq_wNComp_val_q & ~spr_xucr0_dcdis_q & ~ex5_blk_pf_load_q & ~fgen_ex5_stg_flush_int;
assign dcc_pf_ex5_act		  = ex5_cache_acc_q & ex5_load_instr_q & ~ex5_wNComp_q & ~ex5_lq_wNComp_val_q & ~spr_xucr0_dcdis_q;
assign dcc_pf_ex5_thrd_id	  = ex5_thrd_id_q;
assign dcc_pf_ex5_loadmiss	  = ex5_load_miss_q;
assign dcc_pf_ex5_itag		  = ex5_itag_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Stage Flush Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign fgen_ex1_stg_flush = fgen_ex1_stg_flush_int;
assign fgen_ex2_stg_flush = fgen_ex2_stg_flush_int;
assign fgen_ex3_stg_flush = fgen_ex3_stg_flush_int;
assign fgen_ex4_cp_flush  = fgen_ex4_cp_flush_int;
assign fgen_ex4_stg_flush = fgen_ex4_stg_flush_int;
assign fgen_ex5_stg_flush = fgen_ex5_stg_flush_int;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// SPR Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign lq_xu_spr_xucr0_cul = ex6_stq5_unable_2lock_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// AXU Outputs
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign lq_xu_axu_ex4_addr = ex4_eff_addr_q[59:63];
assign lq_xu_axu_ex5_we   = ex5_axu_wren_q | (lsq_ctl_ex5_fwd_val & ex5_axu_op_val_q) | dec_dcc_ex5_axu_abort_rpt;
assign lq_xu_axu_ex5_le   = ex5_load_le_q;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// DIRECTORY ACT Controls
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
assign dcc_dir_ex2_stg_act	 = ex2_stg_act_q;
assign dcc_dir_ex3_stg_act	 = ex3_stg_act_q;
assign dcc_dir_ex4_stg_act	 = ex4_stg_act_q;
assign dcc_dir_ex5_stg_act	 = ex5_stg_act_q;
assign dcc_dir_stq1_stg_act	 = stq1_stg_act;
assign dcc_dir_stq2_stg_act	 = stq2_stg_act_q;
assign dcc_dir_stq3_stg_act	 = stq3_stg_act_q;
assign dcc_dir_stq4_stg_act	 = stq4_stg_act_q;
assign dcc_dir_stq5_stg_act	 = stq5_stg_act_q;
assign dcc_dir_binv2_ex2_stg_act = ex2_binv2_stg_act;
assign dcc_dir_binv3_ex3_stg_act = ex3_binv3_stg_act;
assign dcc_dir_binv4_ex4_stg_act = ex4_binv4_stg_act;
assign dcc_dir_binv5_ex5_stg_act = ex5_binv5_stg_act;
assign dcc_dir_binv6_ex6_stg_act = ex6_binv6_stg_act;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Registers
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) iu_lq_recirc_val_reg(
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
   .scin(siv[iu_lq_recirc_val_offset:iu_lq_recirc_val_offset + `THREADS - 1]),
   .scout(sov[iu_lq_recirc_val_offset:iu_lq_recirc_val_offset + `THREADS - 1]),
   .din(iu_lq_recirc_val_d),
   .dout(iu_lq_recirc_val_q)
);

generate begin : iu_lq_cp_next_itag_tid
      genvar tid;
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
  	    .din(iu_lq_cp_next_itag[tid*`ITAG_SIZE_ENC:tid*`ITAG_SIZE_ENC+(`ITAG_SIZE_ENC-1)]),
            .dout(iu_lq_cp_next_itag_q[tid])
         );
      end
   end
endgenerate

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

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) xer_lq_cp_rd_so_reg(
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
   .scin(siv[xer_lq_cp_rd_so_offset:xer_lq_cp_rd_so_offset + `THREADS - 1]),
   .scout(sov[xer_lq_cp_rd_so_offset:xer_lq_cp_rd_so_offset + `THREADS - 1]),
   .din(xer_lq_cp_rd_so_d),
   .dout(xer_lq_cp_rd_so_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_vld_reg(
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
   .scin(siv[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
   .scout(sov[ex0_i0_vld_offset:ex0_i0_vld_offset + `THREADS - 1]),
   .din(ex0_i0_vld_d),
   .dout(ex0_i0_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_ucode_preissue_reg(
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
   .scin(siv[ex0_i0_ucode_preissue_offset]),
   .scout(sov[ex0_i0_ucode_preissue_offset]),
   .din(ex0_i0_ucode_preissue_d),
   .dout(ex0_i0_ucode_preissue_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i0_2ucode_reg(
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
   .scin(siv[ex0_i0_2ucode_offset]),
   .scout(sov[ex0_i0_2ucode_offset]),
   .din(ex0_i0_2ucode_d),
   .dout(ex0_i0_2ucode_q)
);

tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i0_ucode_cnt_reg(
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
   .scin(siv[ex0_i0_ucode_cnt_offset:ex0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex0_i0_ucode_cnt_offset:ex0_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex0_i0_ucode_cnt_d),
   .dout(ex0_i0_ucode_cnt_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_vld_reg(
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
   .scin(siv[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
   .scout(sov[ex0_i1_vld_offset:ex0_i1_vld_offset + `THREADS - 1]),
   .din(ex0_i1_vld_d),
   .dout(ex0_i1_vld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_ucode_preissue_reg(
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
   .scin(siv[ex0_i1_ucode_preissue_offset]),
   .scout(sov[ex0_i1_ucode_preissue_offset]),
   .din(ex0_i1_ucode_preissue_d),
   .dout(ex0_i1_ucode_preissue_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_i1_2ucode_reg(
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
   .scin(siv[ex0_i1_2ucode_offset]),
   .scout(sov[ex0_i1_2ucode_offset]),
   .din(ex0_i1_2ucode_d),
   .dout(ex0_i1_2ucode_q)
);

tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex0_i1_ucode_cnt_reg(
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
   .scin(siv[ex0_i1_ucode_cnt_offset:ex0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex0_i1_ucode_cnt_offset:ex0_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex0_i1_ucode_cnt_d),
   .dout(ex0_i1_ucode_cnt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_optype1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_optype1_offset]),
   .scout(sov[ex2_optype1_offset]),
   .din(ex2_optype1_d),
   .dout(ex2_optype1_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_optype2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_optype2_offset]),
   .scout(sov[ex2_optype2_offset]),
   .din(ex2_optype2_d),
   .dout(ex2_optype2_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_optype4_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_optype4_offset]),
   .scout(sov[ex2_optype4_offset]),
   .din(ex2_optype4_d),
   .dout(ex2_optype4_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_optype8_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_optype8_offset]),
   .scout(sov[ex2_optype8_offset]),
   .din(ex2_optype8_d),
   .dout(ex2_optype8_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_optype16_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_optype16_offset]),
   .scout(sov[ex2_optype16_offset]),
   .din(ex2_optype16_d),
   .dout(ex2_optype16_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_optype1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_optype1_offset]),
   .scout(sov[ex3_optype1_offset]),
   .din(ex3_optype1_d),
   .dout(ex3_optype1_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_optype2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_optype2_offset]),
   .scout(sov[ex3_optype2_offset]),
   .din(ex3_optype2_d),
   .dout(ex3_optype2_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_optype4_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_optype4_offset]),
   .scout(sov[ex3_optype4_offset]),
   .din(ex3_optype4_d),
   .dout(ex3_optype4_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_optype8_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_optype8_offset]),
   .scout(sov[ex3_optype8_offset]),
   .din(ex3_optype8_d),
   .dout(ex3_optype8_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_optype16_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_optype16_offset]),
   .scout(sov[ex3_optype16_offset]),
   .din(ex3_optype16_d),
   .dout(ex3_optype16_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dacr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dacr_type_offset]),
   .scout(sov[ex3_dacr_type_offset]),
   .din(ex3_dacr_type_d),
   .dout(ex3_dacr_type_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dacr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dacr_type_offset]),
   .scout(sov[ex4_dacr_type_offset]),
   .din(ex4_dacr_type_d),
   .dout(ex4_dacr_type_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_dacr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dacr_type_offset]),
   .scout(sov[ex5_dacr_type_offset]),
   .din(ex5_dacr_type_d),
   .dout(ex5_dacr_type_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_cache_acc_reg(
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
   .scin(siv[ex2_cache_acc_offset]),
   .scout(sov[ex2_cache_acc_offset]),
   .din(ex2_cache_acc_d),
   .dout(ex2_cache_acc_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_cache_acc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_cache_acc_offset]),
   .scout(sov[ex3_cache_acc_offset]),
   .din(ex3_cache_acc_d),
   .dout(ex3_cache_acc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_cache_acc_reg(
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
   .scin(siv[ex4_cache_acc_offset]),
   .scout(sov[ex4_cache_acc_offset]),
   .din(ex4_cache_acc_d),
   .dout(ex4_cache_acc_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_cache_acc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_cache_acc_offset]),
   .scout(sov[ex5_cache_acc_offset]),
   .din(ex5_cache_acc_d),
   .dout(ex5_cache_acc_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_cache_acc_reg(
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
   .scin(siv[ex6_cache_acc_offset]),
   .scout(sov[ex6_cache_acc_offset]),
   .din(ex6_cache_acc_d),
   .dout(ex6_cache_acc_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex2_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_thrd_id_offset:ex2_thrd_id_offset + `THREADS - 1]),
   .scout(sov[ex2_thrd_id_offset:ex2_thrd_id_offset + `THREADS - 1]),
   .din(ex2_thrd_id_d),
   .dout(ex2_thrd_id_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex3_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_thrd_id_offset:ex3_thrd_id_offset + `THREADS - 1]),
   .scout(sov[ex3_thrd_id_offset:ex3_thrd_id_offset + `THREADS - 1]),
   .din(ex3_thrd_id_d),
   .dout(ex3_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex4_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
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

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
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
   .act(ex5_stg_act_q),
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

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) ex2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_instr_offset:ex2_instr_offset + 32 - 1]),
   .scout(sov[ex2_instr_offset:ex2_instr_offset + 32 - 1]),
   .din(ex2_instr_d),
   .dout(ex2_instr_q)
);

tri_regk #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) ex3_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_instr_offset:ex3_instr_offset + 32 - 1]),
   .scout(sov[ex3_instr_offset:ex3_instr_offset + 32 - 1]),
   .din(ex3_instr_d),
   .dout(ex3_instr_q)
);

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) ex4_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_instr_offset:ex4_instr_offset + 32 - 1]),
   .scout(sov[ex4_instr_offset:ex4_instr_offset + 32 - 1]),
   .din(ex4_instr_d),
   .dout(ex4_instr_q)
);

tri_regk #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) ex5_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_instr_offset:ex5_instr_offset + 32 - 1]),
   .scout(sov[ex5_instr_offset:ex5_instr_offset + 32 - 1]),
   .din(ex5_instr_d),
   .dout(ex5_instr_q)
);

tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_target_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_target_gpr_offset:ex2_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ex2_target_gpr_offset:ex2_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(ex2_target_gpr_d),
   .dout(ex2_target_gpr_q)
);

tri_regk #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_target_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_target_gpr_offset:ex3_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ex3_target_gpr_offset:ex3_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(ex3_target_gpr_d),
   .dout(ex3_target_gpr_q)
);

tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_target_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_target_gpr_offset:ex4_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ex4_target_gpr_offset:ex4_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(ex4_target_gpr_d),
   .dout(ex4_target_gpr_q)
);

tri_regk #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_target_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_target_gpr_offset:ex5_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ex5_target_gpr_offset:ex5_target_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(ex5_target_gpr_d),
   .dout(ex5_target_gpr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbt_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbt_instr_offset]),
   .scout(sov[ex2_dcbt_instr_offset]),
   .din(ex2_dcbt_instr_d),
   .dout(ex2_dcbt_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbt_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbt_instr_offset]),
   .scout(sov[ex3_dcbt_instr_offset]),
   .din(ex3_dcbt_instr_d),
   .dout(ex3_dcbt_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbt_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbt_instr_offset]),
   .scout(sov[ex4_dcbt_instr_offset]),
   .din(ex4_dcbt_instr_d),
   .dout(ex4_dcbt_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_pfetch_val_reg(
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
   .scin(siv[ex2_pfetch_val_offset]),
   .scout(sov[ex2_pfetch_val_offset]),
   .din(ex2_pfetch_val_d),
   .dout(ex2_pfetch_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_pfetch_val_reg(
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
   .scin(siv[ex3_pfetch_val_offset]),
   .scout(sov[ex3_pfetch_val_offset]),
   .din(ex3_pfetch_val_d),
   .dout(ex3_pfetch_val_q)
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

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_pfetch_val_reg(
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
   .scin(siv[ex6_pfetch_val_offset]),
   .scout(sov[ex6_pfetch_val_offset]),
   .din(ex6_pfetch_val_d),
   .dout(ex6_pfetch_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbtst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbtst_instr_offset]),
   .scout(sov[ex2_dcbtst_instr_offset]),
   .din(ex2_dcbtst_instr_d),
   .dout(ex2_dcbtst_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbtst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbtst_instr_offset]),
   .scout(sov[ex3_dcbtst_instr_offset]),
   .din(ex3_dcbtst_instr_d),
   .dout(ex3_dcbtst_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbtst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbtst_instr_offset]),
   .scout(sov[ex4_dcbtst_instr_offset]),
   .din(ex4_dcbtst_instr_d),
   .dout(ex4_dcbtst_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_wchk_instr_reg(
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
   .scin(siv[ex2_wchk_instr_offset]),
   .scout(sov[ex2_wchk_instr_offset]),
   .din(ex2_wchk_instr_d),
   .dout(ex2_wchk_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_wchk_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_wchk_instr_offset]),
   .scout(sov[ex3_wchk_instr_offset]),
   .din(ex3_wchk_instr_d),
   .dout(ex3_wchk_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_wchk_instr_reg(
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
   .scin(siv[ex4_wchk_instr_offset]),
   .scout(sov[ex4_wchk_instr_offset]),
   .din(ex4_wchk_instr_d),
   .dout(ex4_wchk_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbst_instr_offset]),
   .scout(sov[ex2_dcbst_instr_offset]),
   .din(ex2_dcbst_instr_d),
   .dout(ex2_dcbst_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbst_instr_offset]),
   .scout(sov[ex3_dcbst_instr_offset]),
   .din(ex3_dcbst_instr_d),
   .dout(ex3_dcbst_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbst_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbst_instr_offset]),
   .scout(sov[ex4_dcbst_instr_offset]),
   .din(ex4_dcbst_instr_d),
   .dout(ex4_dcbst_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbf_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbf_instr_offset]),
   .scout(sov[ex2_dcbf_instr_offset]),
   .din(ex2_dcbf_instr_d),
   .dout(ex2_dcbf_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbf_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbf_instr_offset]),
   .scout(sov[ex3_dcbf_instr_offset]),
   .din(ex3_dcbf_instr_d),
   .dout(ex3_dcbf_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbf_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbf_instr_offset]),
   .scout(sov[ex4_dcbf_instr_offset]),
   .din(ex4_dcbf_instr_d),
   .dout(ex4_dcbf_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mtspr_trace_reg(
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
   .scin(siv[ex2_mtspr_trace_offset]),
   .scout(sov[ex2_mtspr_trace_offset]),
   .din(ex2_mtspr_trace_d),
   .dout(ex2_mtspr_trace_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_mtspr_trace_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_mtspr_trace_offset]),
   .scout(sov[ex3_mtspr_trace_offset]),
   .din(ex3_mtspr_trace_d),
   .dout(ex3_mtspr_trace_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mtspr_trace_reg(
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
   .scin(siv[ex4_mtspr_trace_offset]),
   .scout(sov[ex4_mtspr_trace_offset]),
   .din(ex4_mtspr_trace_d),
   .dout(ex4_mtspr_trace_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sync_instr_reg(
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
   .scin(siv[ex2_sync_instr_offset]),
   .scout(sov[ex2_sync_instr_offset]),
   .din(ex2_sync_instr_d),
   .dout(ex2_sync_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_sync_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_sync_instr_offset]),
   .scout(sov[ex3_sync_instr_offset]),
   .din(ex3_sync_instr_d),
   .dout(ex3_sync_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sync_instr_reg(
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
   .scin(siv[ex4_sync_instr_offset]),
   .scout(sov[ex4_sync_instr_offset]),
   .din(ex4_sync_instr_d),
   .dout(ex4_sync_instr_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex2_l_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_l_fld_offset:ex2_l_fld_offset + 2 - 1]),
   .scout(sov[ex2_l_fld_offset:ex2_l_fld_offset + 2 - 1]),
   .din(ex2_l_fld_d),
   .dout(ex2_l_fld_q)
);

tri_regk #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex3_l_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_l_fld_offset:ex3_l_fld_offset + 2 - 1]),
   .scout(sov[ex3_l_fld_offset:ex3_l_fld_offset + 2 - 1]),
   .din(ex3_l_fld_d),
   .dout(ex3_l_fld_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex4_l_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_l_fld_offset:ex4_l_fld_offset + 2 - 1]),
   .scout(sov[ex4_l_fld_offset:ex4_l_fld_offset + 2 - 1]),
   .din(ex4_l_fld_d),
   .dout(ex4_l_fld_q)
);

tri_regk #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex5_l_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_l_fld_offset:ex5_l_fld_offset + 2 - 1]),
   .scout(sov[ex5_l_fld_offset:ex5_l_fld_offset + 2 - 1]),
   .din(ex5_l_fld_d),
   .dout(ex5_l_fld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbi_instr_offset]),
   .scout(sov[ex2_dcbi_instr_offset]),
   .din(ex2_dcbi_instr_d),
   .dout(ex2_dcbi_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbi_instr_offset]),
   .scout(sov[ex3_dcbi_instr_offset]),
   .din(ex3_dcbi_instr_d),
   .dout(ex3_dcbi_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbi_instr_offset]),
   .scout(sov[ex4_dcbi_instr_offset]),
   .din(ex4_dcbi_instr_d),
   .dout(ex4_dcbi_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbz_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbz_instr_offset]),
   .scout(sov[ex2_dcbz_instr_offset]),
   .din(ex2_dcbz_instr_d),
   .dout(ex2_dcbz_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbz_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbz_instr_offset]),
   .scout(sov[ex3_dcbz_instr_offset]),
   .din(ex3_dcbz_instr_d),
   .dout(ex3_dcbz_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbz_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbz_instr_offset]),
   .scout(sov[ex4_dcbz_instr_offset]),
   .din(ex4_dcbz_instr_d),
   .dout(ex4_dcbz_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icbi_instr_offset]),
   .scout(sov[ex2_icbi_instr_offset]),
   .din(ex2_icbi_instr_d),
   .dout(ex2_icbi_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icbi_instr_offset]),
   .scout(sov[ex3_icbi_instr_offset]),
   .din(ex3_icbi_instr_d),
   .dout(ex3_icbi_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icbi_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icbi_instr_offset]),
   .scout(sov[ex4_icbi_instr_offset]),
   .din(ex4_icbi_instr_d),
   .dout(ex4_icbi_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mbar_instr_reg(
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
   .scin(siv[ex2_mbar_instr_offset]),
   .scout(sov[ex2_mbar_instr_offset]),
   .din(ex2_mbar_instr_d),
   .dout(ex2_mbar_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_mbar_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_mbar_instr_offset]),
   .scout(sov[ex3_mbar_instr_offset]),
   .din(ex3_mbar_instr_d),
   .dout(ex3_mbar_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mbar_instr_reg(
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
   .scin(siv[ex4_mbar_instr_offset]),
   .scout(sov[ex4_mbar_instr_offset]),
   .din(ex4_mbar_instr_d),
   .dout(ex4_mbar_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_makeitso_instr_reg(
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
   .scin(siv[ex2_makeitso_instr_offset]),
   .scout(sov[ex2_makeitso_instr_offset]),
   .din(ex2_makeitso_instr_d),
   .dout(ex2_makeitso_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_makeitso_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_makeitso_instr_offset]),
   .scout(sov[ex3_makeitso_instr_offset]),
   .din(ex3_makeitso_instr_d),
   .dout(ex3_makeitso_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_makeitso_instr_reg(
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
   .scin(siv[ex4_makeitso_instr_offset]),
   .scout(sov[ex4_makeitso_instr_offset]),
   .din(ex4_makeitso_instr_d),
   .dout(ex4_makeitso_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dci_instr_reg(
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
   .scin(siv[ex2_dci_instr_offset]),
   .scout(sov[ex2_dci_instr_offset]),
   .din(ex2_dci_instr_d),
   .dout(ex2_dci_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dci_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dci_instr_offset]),
   .scout(sov[ex3_dci_instr_offset]),
   .din(ex3_dci_instr_d),
   .dout(ex3_dci_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dci_instr_reg(
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
   .scin(siv[ex4_dci_instr_offset]),
   .scout(sov[ex4_dci_instr_offset]),
   .din(ex4_dci_instr_d),
   .dout(ex4_dci_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ici_instr_reg(
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
   .scin(siv[ex2_ici_instr_offset]),
   .scout(sov[ex2_ici_instr_offset]),
   .din(ex2_ici_instr_d),
   .dout(ex2_ici_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_ici_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ici_instr_offset]),
   .scout(sov[ex3_ici_instr_offset]),
   .din(ex3_ici_instr_d),
   .dout(ex3_ici_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ici_instr_reg(
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
   .scin(siv[ex4_ici_instr_offset]),
   .scout(sov[ex4_ici_instr_offset]),
   .din(ex4_ici_instr_d),
   .dout(ex4_ici_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_algebraic_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_algebraic_offset]),
   .scout(sov[ex2_algebraic_offset]),
   .din(ex2_algebraic_d),
   .dout(ex2_algebraic_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_algebraic_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_algebraic_offset]),
   .scout(sov[ex3_algebraic_offset]),
   .din(ex3_algebraic_d),
   .dout(ex3_algebraic_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_strg_index_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_strg_index_offset]),
   .scout(sov[ex2_strg_index_offset]),
   .din(ex2_strg_index_d),
   .dout(ex2_strg_index_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_strg_index_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_strg_index_offset]),
   .scout(sov[ex3_strg_index_offset]),
   .din(ex3_strg_index_d),
   .dout(ex3_strg_index_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_strg_index_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_strg_index_offset]),
   .scout(sov[ex4_strg_index_offset]),
   .din(ex4_strg_index_d),
   .dout(ex4_strg_index_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_resv_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_resv_instr_offset]),
   .scout(sov[ex2_resv_instr_offset]),
   .din(ex2_resv_instr_d),
   .dout(ex2_resv_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_resv_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_resv_instr_offset]),
   .scout(sov[ex3_resv_instr_offset]),
   .din(ex3_resv_instr_d),
   .dout(ex3_resv_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_resv_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_resv_instr_offset]),
   .scout(sov[ex4_resv_instr_offset]),
   .din(ex4_resv_instr_d),
   .dout(ex4_resv_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mutex_hint_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_mutex_hint_offset]),
   .scout(sov[ex2_mutex_hint_offset]),
   .din(ex2_mutex_hint_d),
   .dout(ex2_mutex_hint_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_mutex_hint_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_mutex_hint_offset]),
   .scout(sov[ex3_mutex_hint_offset]),
   .din(ex3_mutex_hint_d),
   .dout(ex3_mutex_hint_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_mutex_hint_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_mutex_hint_offset]),
   .scout(sov[ex4_mutex_hint_offset]),
   .din(ex4_mutex_hint_d),
   .dout(ex4_mutex_hint_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_load_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_load_instr_offset]),
   .scout(sov[ex2_load_instr_offset]),
   .din(ex2_load_instr_d),
   .dout(ex2_load_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_load_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_load_instr_offset]),
   .scout(sov[ex3_load_instr_offset]),
   .din(ex3_load_instr_d),
   .dout(ex3_load_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_load_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_load_instr_offset]),
   .scout(sov[ex4_load_instr_offset]),
   .din(ex4_load_instr_d),
   .dout(ex4_load_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_store_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_store_instr_offset]),
   .scout(sov[ex2_store_instr_offset]),
   .din(ex2_store_instr_d),
   .dout(ex2_store_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_store_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_store_instr_offset]),
   .scout(sov[ex3_store_instr_offset]),
   .din(ex3_store_instr_d),
   .dout(ex3_store_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_store_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_store_instr_offset]),
   .scout(sov[ex4_store_instr_offset]),
   .din(ex4_store_instr_d),
   .dout(ex4_store_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_le_mode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_le_mode_offset]),
   .scout(sov[ex4_le_mode_offset]),
   .din(ex4_le_mode_d),
   .dout(ex4_le_mode_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_wimge_i_bits_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wimge_i_bits_offset]),
   .scout(sov[ex5_wimge_i_bits_offset]),
   .din(ex5_wimge_i_bits_d),
   .dout(ex5_wimge_i_bits_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_axu_op_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_axu_op_val_offset]),
   .scout(sov[ex2_axu_op_val_offset]),
   .din(ex2_axu_op_val_d),
   .dout(ex2_axu_op_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_axu_op_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_axu_op_val_offset]),
   .scout(sov[ex3_axu_op_val_offset]),
   .din(ex3_axu_op_val_d),
   .dout(ex3_axu_op_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_axu_op_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_axu_op_val_offset]),
   .scout(sov[ex4_axu_op_val_offset]),
   .din(ex4_axu_op_val_d),
   .dout(ex4_axu_op_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_axu_op_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_axu_op_val_offset]),
   .scout(sov[ex5_axu_op_val_offset]),
   .din(ex5_axu_op_val_d),
   .dout(ex5_axu_op_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_upd_form_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_upd_form_offset]),
   .scout(sov[ex2_upd_form_offset]),
   .din(ex2_upd_form_d),
   .dout(ex2_upd_form_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_upd_form_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_upd_form_offset]),
   .scout(sov[ex3_upd_form_offset]),
   .din(ex3_upd_form_d),
   .dout(ex3_upd_form_q)
);

tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex2_axu_instr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_axu_instr_type_offset:ex2_axu_instr_type_offset + 3 - 1]),
   .scout(sov[ex2_axu_instr_type_offset:ex2_axu_instr_type_offset + 3 - 1]),
   .din(ex2_axu_instr_type_d),
   .dout(ex2_axu_instr_type_q)
);

tri_regk #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex3_axu_instr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_axu_instr_type_offset:ex3_axu_instr_type_offset + 3 - 1]),
   .scout(sov[ex3_axu_instr_type_offset:ex3_axu_instr_type_offset + 3 - 1]),
   .din(ex3_axu_instr_type_d),
   .dout(ex3_axu_instr_type_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_load_hit_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_load_hit_offset]),
   .scout(sov[ex5_load_hit_offset]),
   .din(ex5_load_hit_d),
   .dout(ex5_load_hit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_load_hit_reg(
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
   .scin(siv[ex6_load_hit_offset]),
   .scout(sov[ex6_load_hit_offset]),
   .din(ex6_load_hit_d),
   .dout(ex6_load_hit_q)
);

tri_regk #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex5_usr_bits_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_usr_bits_offset:ex5_usr_bits_offset + 4 - 1]),
   .scout(sov[ex5_usr_bits_offset:ex5_usr_bits_offset + 4 - 1]),
   .din(ex5_usr_bits_d),
   .dout(ex5_usr_bits_q)
);

tri_regk #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex5_classid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_classid_offset:ex5_classid_offset + 2 - 1]),
   .scout(sov[ex5_classid_offset:ex5_classid_offset + 2 - 1]),
   .din(ex5_classid_d),
   .dout(ex5_classid_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_derat_setHold_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_derat_setHold_offset]),
   .scout(sov[ex5_derat_setHold_offset]),
   .din(ex5_derat_setHold_d),
   .dout(ex5_derat_setHold_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_axu_wren_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_axu_wren_offset]),
   .scout(sov[ex5_axu_wren_offset]),
   .din(ex5_axu_wren_d),
   .dout(ex5_axu_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_axu_wren_reg(
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
   .scin(siv[ex6_axu_wren_offset]),
   .scout(sov[ex6_axu_wren_offset]),
   .din(ex6_axu_wren_d),
   .dout(ex6_axu_wren_q)
);

tri_regk #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_lq_ta_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lq_ta_gpr_offset:ex5_lq_ta_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[ex5_lq_ta_gpr_offset:ex5_lq_ta_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(ex5_lq_ta_gpr_d),
   .dout(ex5_lq_ta_gpr_q)
);

tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_lq_ta_gpr_reg(
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
   .scin(siv[ex6_lq_ta_gpr_offset:ex6_lq_ta_gpr_offset + (`GPR_POOL_ENC+`THREADS_POOL_ENC) - 1]),
   .scout(sov[ex6_lq_ta_gpr_offset:ex6_lq_ta_gpr_offset + (`GPR_POOL_ENC+`THREADS_POOL_ENC) - 1]),
   .din(ex6_lq_ta_gpr_d),
   .dout(ex6_lq_ta_gpr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_load_le_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_load_le_offset]),
   .scout(sov[ex5_load_le_offset]),
   .din(ex5_load_le_d),
   .dout(ex5_load_le_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_th_fld_c_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_th_fld_c_offset]),
   .scout(sov[ex2_th_fld_c_offset]),
   .din(ex2_th_fld_c_d),
   .dout(ex2_th_fld_c_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_th_fld_c_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_th_fld_c_offset]),
   .scout(sov[ex3_th_fld_c_offset]),
   .din(ex3_th_fld_c_d),
   .dout(ex3_th_fld_c_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_th_fld_c_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_th_fld_c_offset]),
   .scout(sov[ex4_th_fld_c_offset]),
   .din(ex4_th_fld_c_d),
   .dout(ex4_th_fld_c_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_th_fld_l2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_th_fld_l2_offset]),
   .scout(sov[ex2_th_fld_l2_offset]),
   .din(ex2_th_fld_l2_d),
   .dout(ex2_th_fld_l2_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_th_fld_l2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_th_fld_l2_offset]),
   .scout(sov[ex3_th_fld_l2_offset]),
   .din(ex3_th_fld_l2_d),
   .dout(ex3_th_fld_l2_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_th_fld_l2_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_th_fld_l2_offset]),
   .scout(sov[ex4_th_fld_l2_offset]),
   .din(ex4_th_fld_l2_d),
   .dout(ex4_th_fld_l2_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbtls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbtls_instr_offset]),
   .scout(sov[ex2_dcbtls_instr_offset]),
   .din(ex2_dcbtls_instr_d),
   .dout(ex2_dcbtls_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbtls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbtls_instr_offset]),
   .scout(sov[ex3_dcbtls_instr_offset]),
   .din(ex3_dcbtls_instr_d),
   .dout(ex3_dcbtls_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbtls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbtls_instr_offset]),
   .scout(sov[ex4_dcbtls_instr_offset]),
   .din(ex4_dcbtls_instr_d),
   .dout(ex4_dcbtls_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcbtstls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcbtstls_instr_offset]),
   .scout(sov[ex2_dcbtstls_instr_offset]),
   .din(ex2_dcbtstls_instr_d),
   .dout(ex2_dcbtstls_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcbtstls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcbtstls_instr_offset]),
   .scout(sov[ex3_dcbtstls_instr_offset]),
   .din(ex3_dcbtstls_instr_d),
   .dout(ex3_dcbtstls_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcbtstls_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcbtstls_instr_offset]),
   .scout(sov[ex4_dcbtstls_instr_offset]),
   .din(ex4_dcbtstls_instr_d),
   .dout(ex4_dcbtstls_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_dcblc_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_dcblc_instr_offset]),
   .scout(sov[ex2_dcblc_instr_offset]),
   .din(ex2_dcblc_instr_d),
   .dout(ex2_dcblc_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_dcblc_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_dcblc_instr_offset]),
   .scout(sov[ex3_dcblc_instr_offset]),
   .din(ex3_dcblc_instr_d),
   .dout(ex3_dcblc_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_dcblc_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_dcblc_instr_offset]),
   .scout(sov[ex4_dcblc_instr_offset]),
   .din(ex4_dcblc_instr_d),
   .dout(ex4_dcblc_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icblc_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icblc_l2_instr_offset]),
   .scout(sov[ex2_icblc_l2_instr_offset]),
   .din(ex2_icblc_l2_instr_d),
   .dout(ex2_icblc_l2_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icblc_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icblc_l2_instr_offset]),
   .scout(sov[ex3_icblc_l2_instr_offset]),
   .din(ex3_icblc_l2_instr_d),
   .dout(ex3_icblc_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icblc_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icblc_l2_instr_offset]),
   .scout(sov[ex4_icblc_l2_instr_offset]),
   .din(ex4_icblc_l2_instr_d),
   .dout(ex4_icblc_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icbt_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icbt_l2_instr_offset]),
   .scout(sov[ex2_icbt_l2_instr_offset]),
   .din(ex2_icbt_l2_instr_d),
   .dout(ex2_icbt_l2_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icbt_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icbt_l2_instr_offset]),
   .scout(sov[ex3_icbt_l2_instr_offset]),
   .din(ex3_icbt_l2_instr_d),
   .dout(ex3_icbt_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icbt_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icbt_l2_instr_offset]),
   .scout(sov[ex4_icbt_l2_instr_offset]),
   .din(ex4_icbt_l2_instr_d),
   .dout(ex4_icbt_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icbtls_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icbtls_l2_instr_offset]),
   .scout(sov[ex2_icbtls_l2_instr_offset]),
   .din(ex2_icbtls_l2_instr_d),
   .dout(ex2_icbtls_l2_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icbtls_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icbtls_l2_instr_offset]),
   .scout(sov[ex3_icbtls_l2_instr_offset]),
   .din(ex3_icbtls_l2_instr_d),
   .dout(ex3_icbtls_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icbtls_l2_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icbtls_l2_instr_offset]),
   .scout(sov[ex4_icbtls_l2_instr_offset]),
   .din(ex4_icbtls_l2_instr_d),
   .dout(ex4_icbtls_l2_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_tlbsync_instr_reg(
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
   .scin(siv[ex2_tlbsync_instr_offset]),
   .scout(sov[ex2_tlbsync_instr_offset]),
   .din(ex2_tlbsync_instr_d),
   .dout(ex2_tlbsync_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_tlbsync_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_tlbsync_instr_offset]),
   .scout(sov[ex3_tlbsync_instr_offset]),
   .din(ex3_tlbsync_instr_d),
   .dout(ex3_tlbsync_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tlbsync_instr_reg(
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
   .scin(siv[ex4_tlbsync_instr_offset]),
   .scout(sov[ex4_tlbsync_instr_offset]),
   .din(ex4_tlbsync_instr_d),
   .dout(ex4_tlbsync_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ldst_falign_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_ldst_falign_offset]),
   .scout(sov[ex2_ldst_falign_offset]),
   .din(ex2_ldst_falign_d),
   .dout(ex2_ldst_falign_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ldst_fexcpt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_ldst_fexcpt_offset]),
   .scout(sov[ex2_ldst_fexcpt_offset]),
   .din(ex2_ldst_fexcpt_d),
   .dout(ex2_ldst_fexcpt_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_ldst_fexcpt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ldst_fexcpt_offset]),
   .scout(sov[ex3_ldst_fexcpt_offset]),
   .din(ex3_ldst_fexcpt_d),
   .dout(ex3_ldst_fexcpt_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_load_miss_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_load_miss_offset]),
   .scout(sov[ex5_load_miss_offset]),
   .din(ex5_load_miss_d),
   .dout(ex5_load_miss_q)
);

tri_ser_rlmreg_p #(.WIDTH((8+`THREADS+1)), .INIT(0), .NEEDS_SRESET(1)) xudbg1_dir_reg_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex5_darr_rd_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[xudbg1_dir_reg_offset:xudbg1_dir_reg_offset + (8+`THREADS+1) - 1]),
   .scout(sov[xudbg1_dir_reg_offset:xudbg1_dir_reg_offset + (8+`THREADS+1) - 1]),
   .din(xudbg1_dir_reg_d),
   .dout(xudbg1_dir_reg_q)
);

tri_ser_rlmreg_p #(.WIDTH(PARBITS), .INIT(0), .NEEDS_SRESET(1)) xudbg1_parity_reg_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_darr_rd_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[xudbg1_parity_reg_offset:xudbg1_parity_reg_offset + PARBITS - 1]),
   .scout(sov[xudbg1_parity_reg_offset:xudbg1_parity_reg_offset + PARBITS - 1]),
   .din(xudbg1_parity_reg_d),
   .dout(xudbg1_parity_reg_q)
);

tri_ser_rlmreg_p #(.WIDTH((63-(`DC_SIZE-3))-(64-`REAL_IFAR_WIDTH)+1), .INIT(0), .NEEDS_SRESET(1)) xudbg2_tag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_darr_rd_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[xudbg2_tag_offset:xudbg2_tag_offset + (63-(`DC_SIZE-3))-(64-`REAL_IFAR_WIDTH)+1 - 1]),
   .scout(sov[xudbg2_tag_offset:xudbg2_tag_offset + (63-(`DC_SIZE-3))-(64-`REAL_IFAR_WIDTH)+1 - 1]),
   .din(xudbg2_tag_d),
   .dout(xudbg2_tag_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_dcarr_wren_reg(
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
   .scin(siv[stq4_dcarr_wren_offset]),
   .scout(sov[stq4_dcarr_wren_offset]),
   .din(stq4_dcarr_wren_d),
   .dout(stq4_dcarr_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sgpr_instr_reg(
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
   .scin(siv[ex2_sgpr_instr_offset]),
   .scout(sov[ex2_sgpr_instr_offset]),
   .din(ex2_sgpr_instr_d),
   .dout(ex2_sgpr_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_saxu_instr_reg(
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
   .scin(siv[ex2_saxu_instr_offset]),
   .scout(sov[ex2_saxu_instr_offset]),
   .din(ex2_saxu_instr_d),
   .dout(ex2_saxu_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sdp_instr_reg(
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
   .scin(siv[ex2_sdp_instr_offset]),
   .scout(sov[ex2_sdp_instr_offset]),
   .din(ex2_sdp_instr_d),
   .dout(ex2_sdp_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_tgpr_instr_reg(
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
   .scin(siv[ex2_tgpr_instr_offset]),
   .scout(sov[ex2_tgpr_instr_offset]),
   .din(ex2_tgpr_instr_d),
   .dout(ex2_tgpr_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_taxu_instr_reg(
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
   .scin(siv[ex2_taxu_instr_offset]),
   .scout(sov[ex2_taxu_instr_offset]),
   .din(ex2_taxu_instr_d),
   .dout(ex2_taxu_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_tdp_instr_reg(
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
   .scin(siv[ex2_tdp_instr_offset]),
   .scout(sov[ex2_tdp_instr_offset]),
   .din(ex2_tdp_instr_d),
   .dout(ex2_tdp_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_sgpr_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_sgpr_instr_offset]),
   .scout(sov[ex3_sgpr_instr_offset]),
   .din(ex3_sgpr_instr_d),
   .dout(ex3_sgpr_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_saxu_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_saxu_instr_offset]),
   .scout(sov[ex3_saxu_instr_offset]),
   .din(ex3_saxu_instr_d),
   .dout(ex3_saxu_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_sdp_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_sdp_instr_offset]),
   .scout(sov[ex3_sdp_instr_offset]),
   .din(ex3_sdp_instr_d),
   .dout(ex3_sdp_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_tgpr_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_tgpr_instr_offset]),
   .scout(sov[ex3_tgpr_instr_offset]),
   .din(ex3_tgpr_instr_d),
   .dout(ex3_tgpr_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_taxu_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_taxu_instr_offset]),
   .scout(sov[ex3_taxu_instr_offset]),
   .din(ex3_taxu_instr_d),
   .dout(ex3_taxu_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_tdp_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_tdp_instr_offset]),
   .scout(sov[ex3_tdp_instr_offset]),
   .din(ex3_tdp_instr_d),
   .dout(ex3_tdp_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sgpr_instr_reg(
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
   .scin(siv[ex4_sgpr_instr_offset]),
   .scout(sov[ex4_sgpr_instr_offset]),
   .din(ex4_sgpr_instr_d),
   .dout(ex4_sgpr_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_saxu_instr_reg(
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
   .scin(siv[ex4_saxu_instr_offset]),
   .scout(sov[ex4_saxu_instr_offset]),
   .din(ex4_saxu_instr_d),
   .dout(ex4_saxu_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sdp_instr_reg(
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
   .scin(siv[ex4_sdp_instr_offset]),
   .scout(sov[ex4_sdp_instr_offset]),
   .din(ex4_sdp_instr_d),
   .dout(ex4_sdp_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tgpr_instr_reg(
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
   .scin(siv[ex4_tgpr_instr_offset]),
   .scout(sov[ex4_tgpr_instr_offset]),
   .din(ex4_tgpr_instr_d),
   .dout(ex4_tgpr_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_taxu_instr_reg(
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
   .scin(siv[ex4_taxu_instr_offset]),
   .scout(sov[ex4_taxu_instr_offset]),
   .din(ex4_taxu_instr_d),
   .dout(ex4_taxu_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_tdp_instr_reg(
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
   .scin(siv[ex4_tdp_instr_offset]),
   .scout(sov[ex4_tdp_instr_offset]),
   .din(ex4_tdp_instr_d),
   .dout(ex4_tdp_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_mftgpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_mftgpr_val_offset]),
   .scout(sov[ex5_mftgpr_val_offset]),
   .din(ex5_mftgpr_val_d),
   .dout(ex5_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_moveOp_val_reg(
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
   .scin(siv[ex4_moveOp_val_offset]),
   .scout(sov[ex4_moveOp_val_offset]),
   .din(ex4_moveOp_val_d),
   .dout(ex4_moveOp_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_moveOp_val_reg(
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
   .scin(siv[stq6_moveOp_val_offset]),
   .scout(sov[stq6_moveOp_val_offset]),
   .din(stq6_moveOp_val_d),
   .dout(stq6_moveOp_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_undef_touch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_undef_touch_offset]),
   .scout(sov[ex3_undef_touch_offset]),
   .din(ex3_undef_touch_d),
   .dout(ex3_undef_touch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_undef_touch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_undef_touch_offset]),
   .scout(sov[ex4_undef_touch_offset]),
   .din(ex4_undef_touch_d),
   .dout(ex4_undef_touch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_blkable_touch_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_blkable_touch_offset]),
   .scout(sov[ex4_blkable_touch_offset]),
   .din(ex4_blkable_touch_d),
   .dout(ex4_blkable_touch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_blk_touch_reg(
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
   .scin(siv[ex5_blk_touch_offset]),
   .scout(sov[ex5_blk_touch_offset]),
   .din(ex5_blk_touch_d),
   .dout(ex5_blk_touch_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_blk_touch_reg(
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
   .scin(siv[ex6_blk_touch_offset]),
   .scout(sov[ex6_blk_touch_offset]),
   .din(ex6_blk_touch_d),
   .dout(ex6_blk_touch_q)
);

tri_regk #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_eff_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_binv2_stg_act),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_eff_addr_offset:ex3_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .scout(sov[ex3_eff_addr_offset:ex3_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .din(ex3_eff_addr_d),
   .dout(ex3_eff_addr_q)
);

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_eff_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_binv3_stg_act),
   .force_t(func_slp_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_eff_addr_offset:ex4_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .scout(sov[ex4_eff_addr_offset:ex4_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .din(ex4_eff_addr_d),
   .dout(ex4_eff_addr_q)
);

tri_regk #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_eff_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_eff_addr_offset:ex5_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .scout(sov[ex5_eff_addr_offset:ex5_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .din(ex5_eff_addr_d),
   .dout(ex5_eff_addr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_undef_lockset_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_undef_lockset_offset]),
   .scout(sov[ex3_undef_lockset_offset]),
   .din(ex3_undef_lockset_d),
   .dout(ex3_undef_lockset_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_undef_lockset_reg(
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
   .scin(siv[ex4_undef_lockset_offset]),
   .scout(sov[ex4_undef_lockset_offset]),
   .din(ex4_undef_lockset_d),
   .dout(ex4_undef_lockset_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_unable_2lock_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_unable_2lock_offset]),
   .scout(sov[ex5_unable_2lock_offset]),
   .din(ex5_unable_2lock_d),
   .dout(ex5_unable_2lock_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stq5_unable_2lock_reg(
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
   .scin(siv[ex6_stq5_unable_2lock_offset]),
   .scout(sov[ex6_stq5_unable_2lock_offset]),
   .din(ex6_stq5_unable_2lock_d),
   .dout(ex6_stq5_unable_2lock_q)
);

tri_regk #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex5_dacrw_cmpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dacrw_cmpr_offset:ex5_dacrw_cmpr_offset + 4 - 1]),
   .scout(sov[ex5_dacrw_cmpr_offset:ex5_dacrw_cmpr_offset + 4 - 1]),
   .din(ex5_dacrw_cmpr_d),
   .dout(ex5_dacrw_cmpr_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) ex6_dacrw_cmpr_reg(
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
   .scin(siv[ex6_dacrw_cmpr_offset:ex6_dacrw_cmpr_offset + 4 - 1]),
   .scout(sov[ex6_dacrw_cmpr_offset:ex6_dacrw_cmpr_offset + 4 - 1]),
   .din(ex6_dacrw_cmpr_d),
   .dout(ex6_dacrw_cmpr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_stq_val_req_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_stq_val_req_offset]),
   .scout(sov[ex3_stq_val_req_offset]),
   .din(ex3_stq_val_req_d),
   .dout(ex3_stq_val_req_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_stq_val_req_reg(
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
   .scin(siv[ex4_stq_val_req_offset]),
   .scout(sov[ex4_stq_val_req_offset]),
   .din(ex4_stq_val_req_d),
   .dout(ex4_stq_val_req_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_load_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_load_instr_offset]),
   .scout(sov[ex5_load_instr_offset]),
   .din(ex5_load_instr_d),
   .dout(ex5_load_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_mword_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_mword_instr_offset]),
   .scout(sov[ex2_mword_instr_offset]),
   .din(ex2_mword_instr_d),
   .dout(ex2_mword_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_mword_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_mword_instr_offset]),
   .scout(sov[ex3_mword_instr_offset]),
   .din(ex3_mword_instr_d),
   .dout(ex3_mword_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_store_miss_reg(
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
   .scin(siv[stq4_store_miss_offset]),
   .scout(sov[stq4_store_miss_offset]),
   .din(stq4_store_miss_d),
   .dout(stq4_store_miss_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_perf_dcbt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_perf_dcbt_offset]),
   .scout(sov[ex5_perf_dcbt_offset]),
   .din(ex5_perf_dcbt_d),
   .dout(ex5_perf_dcbt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_ap_reg(
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
   .scin(siv[spr_ccr2_ap_offset]),
   .scout(sov[spr_ccr2_ap_offset]),
   .din(spr_ccr2_ap_d),
   .dout(spr_ccr2_ap_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_en_trace_reg(
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
   .scin(siv[spr_ccr2_en_trace_offset]),
   .scout(sov[spr_ccr2_en_trace_offset]),
   .din(spr_ccr2_en_trace_d),
   .dout(spr_ccr2_en_trace_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_ucode_dis_reg(
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
   .scin(siv[spr_ccr2_ucode_dis_offset]),
   .scout(sov[spr_ccr2_ucode_dis_offset]),
   .din(spr_ccr2_ucode_dis_d),
   .dout(spr_ccr2_ucode_dis_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_ccr2_notlb_reg(
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
   .scin(siv[spr_ccr2_notlb_offset]),
   .scout(sov[spr_ccr2_notlb_offset]),
   .din(spr_ccr2_notlb_d),
   .dout(spr_ccr2_notlb_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) clkg_ctl_override_reg(
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
   .scin(siv[clkg_ctl_override_offset]),
   .scout(sov[clkg_ctl_override_offset]),
   .din(clkg_ctl_override_d),
   .dout(clkg_ctl_override_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_wlk_reg(
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
   .scin(siv[spr_xucr0_wlk_offset]),
   .scout(sov[spr_xucr0_wlk_offset]),
   .din(spr_xucr0_wlk_d),
   .dout(spr_xucr0_wlk_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_mbar_ack_reg(
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
   .scin(siv[spr_xucr0_mbar_ack_offset]),
   .scout(sov[spr_xucr0_mbar_ack_offset]),
   .din(spr_xucr0_mbar_ack_d),
   .dout(spr_xucr0_mbar_ack_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_tlbsync_reg(
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
   .scin(siv[spr_xucr0_tlbsync_offset]),
   .scout(sov[spr_xucr0_tlbsync_offset]),
   .din(spr_xucr0_tlbsync_d),
   .dout(spr_xucr0_tlbsync_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_dcdis_reg(
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
   .scin(siv[spr_xucr0_dcdis_offset]),
   .scout(sov[spr_xucr0_dcdis_offset]),
   .din(spr_xucr0_dcdis_d),
   .dout(spr_xucr0_dcdis_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_aflsta_reg(
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
   .scin(siv[spr_xucr0_aflsta_offset]),
   .scout(sov[spr_xucr0_aflsta_offset]),
   .din(spr_xucr0_aflsta_d),
   .dout(spr_xucr0_aflsta_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_flsta_reg(
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
   .scin(siv[spr_xucr0_flsta_offset]),
   .scout(sov[spr_xucr0_flsta_offset]),
   .din(spr_xucr0_flsta_d),
   .dout(spr_xucr0_flsta_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_mddp_reg(
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
   .scin(siv[spr_xucr0_mddp_offset]),
   .scout(sov[spr_xucr0_mddp_offset]),
   .din(spr_xucr0_mddp_d),
   .dout(spr_xucr0_mddp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr0_mdcp_reg(
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
   .scin(siv[spr_xucr0_mdcp_offset]),
   .scout(sov[spr_xucr0_mdcp_offset]),
   .din(spr_xucr0_mdcp_d),
   .dout(spr_xucr0_mdcp_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr4_mmu_mchk_reg(
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
   .scin(siv[spr_xucr4_mmu_mchk_offset]),
   .scout(sov[spr_xucr4_mmu_mchk_offset]),
   .din(spr_xucr4_mmu_mchk_d),
   .dout(spr_xucr4_mmu_mchk_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_xucr4_mddmh_reg(
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
   .scin(siv[spr_xucr4_mddmh_offset]),
   .scout(sov[spr_xucr4_mddmh_offset]),
   .din(spr_xucr4_mddmh_d),
   .dout(spr_xucr4_mddmh_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_xucr0_en_trace_um_reg(
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
   .scin(siv[spr_xucr0_en_trace_um_offset:spr_xucr0_en_trace_um_offset + `THREADS - 1]),
   .scout(sov[spr_xucr0_en_trace_um_offset:spr_xucr0_en_trace_um_offset + `THREADS - 1]),
   .din(spr_xucr0_en_trace_um_d),
   .dout(spr_xucr0_en_trace_um_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex1_lsu_64bit_mode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_lsu_64bit_mode_offset:ex1_lsu_64bit_mode_offset + `THREADS - 1]),
   .scout(sov[ex1_lsu_64bit_mode_offset:ex1_lsu_64bit_mode_offset + `THREADS - 1]),
   .din(ex1_lsu_64bit_mode_d),
   .dout(ex1_lsu_64bit_mode_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_lsu_64bit_agen_reg(
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
   .scin(siv[ex2_lsu_64bit_agen_offset]),
   .scout(sov[ex2_lsu_64bit_agen_offset]),
   .din(ex2_lsu_64bit_agen_d),
   .dout(ex2_lsu_64bit_agen_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_lsu_64bit_agen_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_lsu_64bit_agen_offset]),
   .scout(sov[ex3_lsu_64bit_agen_offset]),
   .din(ex3_lsu_64bit_agen_d),
   .dout(ex3_lsu_64bit_agen_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lsu_64bit_agen_reg(
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
   .scin(siv[ex4_lsu_64bit_agen_offset]),
   .scout(sov[ex4_lsu_64bit_agen_offset]),
   .din(ex4_lsu_64bit_agen_d),
   .dout(ex4_lsu_64bit_agen_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_local_dcbf_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_local_dcbf_offset]),
   .scout(sov[ex4_local_dcbf_offset]),
   .din(ex4_local_dcbf_d),
   .dout(ex4_local_dcbf_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_msgsnd_instr_reg(
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
   .scin(siv[ex2_msgsnd_instr_offset]),
   .scout(sov[ex2_msgsnd_instr_offset]),
   .din(ex2_msgsnd_instr_d),
   .dout(ex2_msgsnd_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_msgsnd_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_msgsnd_instr_offset]),
   .scout(sov[ex3_msgsnd_instr_offset]),
   .din(ex3_msgsnd_instr_d),
   .dout(ex3_msgsnd_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_msgsnd_instr_reg(
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
   .scin(siv[ex4_msgsnd_instr_offset]),
   .scout(sov[ex4_msgsnd_instr_offset]),
   .din(ex4_msgsnd_instr_d),
   .dout(ex4_msgsnd_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_load_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_load_type_offset]),
   .scout(sov[ex4_load_type_offset]),
   .din(ex4_load_type_d),
   .dout(ex4_load_type_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_gath_load_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_gath_load_offset]),
   .scout(sov[ex4_gath_load_offset]),
   .din(ex4_gath_load_d),
   .dout(ex4_gath_load_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_l2load_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_l2load_type_offset]),
   .scout(sov[ex4_l2load_type_offset]),
   .din(ex4_l2load_type_d),
   .dout(ex4_l2load_type_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_lq_wren_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lq_wren_offset]),
   .scout(sov[ex5_lq_wren_offset]),
   .din(ex5_lq_wren_d),
   .dout(ex5_lq_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lq_wren_reg(
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
   .scin(siv[ex6_lq_wren_offset]),
   .scout(sov[ex6_lq_wren_offset]),
   .din(ex6_lq_wren_d),
   .dout(ex6_lq_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ldawx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_ldawx_instr_offset]),
   .scout(sov[ex2_ldawx_instr_offset]),
   .din(ex2_ldawx_instr_d),
   .dout(ex2_ldawx_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_ldawx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ldawx_instr_offset]),
   .scout(sov[ex3_ldawx_instr_offset]),
   .din(ex3_ldawx_instr_d),
   .dout(ex3_ldawx_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ldawx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_ldawx_instr_offset]),
   .scout(sov[ex4_ldawx_instr_offset]),
   .din(ex4_ldawx_instr_d),
   .dout(ex4_ldawx_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_ldawx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ldawx_instr_offset]),
   .scout(sov[ex5_ldawx_instr_offset]),
   .din(ex5_ldawx_instr_d),
   .dout(ex5_ldawx_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_wclr_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_wclr_instr_offset]),
   .scout(sov[ex2_wclr_instr_offset]),
   .din(ex2_wclr_instr_d),
   .dout(ex2_wclr_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_wclr_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_wclr_instr_offset]),
   .scout(sov[ex3_wclr_instr_offset]),
   .din(ex3_wclr_instr_d),
   .dout(ex3_wclr_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_wclr_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_wclr_instr_offset]),
   .scout(sov[ex4_wclr_instr_offset]),
   .din(ex4_wclr_instr_d),
   .dout(ex4_wclr_instr_q)
);

tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex4_opsize_enc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_opsize_enc_offset:ex4_opsize_enc_offset + 3 - 1]),
   .scout(sov[ex4_opsize_enc_offset:ex4_opsize_enc_offset + 3 - 1]),
   .din(ex4_opsize_enc_d),
   .dout(ex4_opsize_enc_q)
);

tri_regk #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) ex5_opsize_enc_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_opsize_enc_offset:ex5_opsize_enc_offset + 3 - 1]),
   .scout(sov[ex5_opsize_enc_offset:ex5_opsize_enc_offset + 3 - 1]),
   .din(ex5_opsize_enc_d),
   .dout(ex5_opsize_enc_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex2_itag_offset:ex2_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex2_itag_d),
   .dout(ex2_itag_q)
);

tri_regk #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
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
   .act(ex3_stg_act_q),
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

tri_regk #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex5_itag_offset:ex5_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex5_itag_d),
   .dout(ex5_itag_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex6_itag_reg(
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
   .scin(siv[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex6_itag_offset:ex6_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex6_itag_d),
   .dout(ex6_itag_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_drop_rel_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_drop_rel_offset]),
   .scout(sov[ex5_drop_rel_offset]),
   .din(ex5_drop_rel_d),
   .dout(ex5_drop_rel_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icswx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icswx_instr_offset]),
   .scout(sov[ex2_icswx_instr_offset]),
   .din(ex2_icswx_instr_d),
   .dout(ex2_icswx_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icswx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icswx_instr_offset]),
   .scout(sov[ex3_icswx_instr_offset]),
   .din(ex3_icswx_instr_d),
   .dout(ex3_icswx_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icswx_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icswx_instr_offset]),
   .scout(sov[ex4_icswx_instr_offset]),
   .din(ex4_icswx_instr_d),
   .dout(ex4_icswx_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icswxdot_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icswxdot_instr_offset]),
   .scout(sov[ex2_icswxdot_instr_offset]),
   .din(ex2_icswxdot_instr_d),
   .dout(ex2_icswxdot_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icswxdot_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icswxdot_instr_offset]),
   .scout(sov[ex3_icswxdot_instr_offset]),
   .din(ex3_icswxdot_instr_d),
   .dout(ex3_icswxdot_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icswxdot_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icswxdot_instr_offset]),
   .scout(sov[ex4_icswxdot_instr_offset]),
   .din(ex4_icswxdot_instr_d),
   .dout(ex4_icswxdot_instr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_icswx_epid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_icswx_epid_offset]),
   .scout(sov[ex2_icswx_epid_offset]),
   .din(ex2_icswx_epid_d),
   .dout(ex2_icswx_epid_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_icswx_epid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icswx_epid_offset]),
   .scout(sov[ex3_icswx_epid_offset]),
   .din(ex3_icswx_epid_d),
   .dout(ex3_icswx_epid_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icswx_epid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icswx_epid_offset]),
   .scout(sov[ex4_icswx_epid_offset]),
   .din(ex4_icswx_epid_d),
   .dout(ex4_icswx_epid_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_icswx_epid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_icswx_epid_offset]),
   .scout(sov[ex5_icswx_epid_offset]),
   .din(ex5_icswx_epid_d),
   .dout(ex5_icswx_epid_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_c_inh_drop_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_c_inh_drop_op_offset]),
   .scout(sov[ex4_c_inh_drop_op_offset]),
   .din(ex4_c_inh_drop_op_d),
   .dout(ex4_c_inh_drop_op_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_axu_wren_reg(
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
   .scin(siv[rel2_axu_wren_offset]),
   .scout(sov[rel2_axu_wren_offset]),
   .din(rel2_axu_wren_d),
   .dout(rel2_axu_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_axu_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_axu_val_offset]),
   .scout(sov[stq2_axu_val_offset]),
   .din(stq2_axu_val_d),
   .dout(stq2_axu_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_axu_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_axu_val_offset]),
   .scout(sov[stq3_axu_val_offset]),
   .din(stq3_axu_val_d),
   .dout(stq3_axu_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_axu_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_axu_val_offset]),
   .scout(sov[stq4_axu_val_offset]),
   .din(stq4_axu_val_d),
   .dout(stq4_axu_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_store_hit_reg(
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
   .scin(siv[stq4_store_hit_offset]),
   .scout(sov[stq4_store_hit_offset]),
   .din(stq4_store_hit_d),
   .dout(stq4_store_hit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_store_hit_reg(
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
   .scin(siv[stq5_store_hit_offset]),
   .scout(sov[stq5_store_hit_offset]),
   .din(stq5_store_hit_d),
   .dout(stq5_store_hit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_store_hit_reg(
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
   .scin(siv[stq6_store_hit_offset]),
   .scout(sov[stq6_store_hit_offset]),
   .din(stq6_store_hit_d),
   .dout(stq6_store_hit_q)
);

tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) rel2_ta_gpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rel2_ta_gpr_offset:rel2_ta_gpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[rel2_ta_gpr_offset:rel2_ta_gpr_offset + AXU_TARGET_ENC - 1]),
   .din(rel2_ta_gpr_d),
   .dout(rel2_ta_gpr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) rv1_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[rv1_binv_val_offset]),
   .scout(sov[rv1_binv_val_offset]),
   .din(rv1_binv_val_d),
   .dout(rv1_binv_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_binv_val_reg(
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
   .scin(siv[ex0_binv_val_offset]),
   .scout(sov[ex0_binv_val_offset]),
   .din(ex0_binv_val_d),
   .dout(ex0_binv_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex1_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_binv_val_offset]),
   .scout(sov[ex1_binv_val_offset]),
   .din(ex1_binv_val_d),
   .dout(ex1_binv_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_binv_val_reg(
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
   .scin(siv[ex2_binv_val_offset]),
   .scout(sov[ex2_binv_val_offset]),
   .din(ex2_binv_val_d),
   .dout(ex2_binv_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_binv_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_slp_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_slp_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_binv_val_offset]),
   .scout(sov[ex3_binv_val_offset]),
   .din(ex3_binv_val_d),
   .dout(ex3_binv_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_binv_val_reg(
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
   .scin(siv[ex4_binv_val_offset]),
   .scout(sov[ex4_binv_val_offset]),
   .din(ex4_binv_val_d),
   .dout(ex4_binv_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex0_derat_snoop_val_reg(
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
   .scin(siv[ex0_derat_snoop_val_offset]),
   .scout(sov[ex0_derat_snoop_val_offset]),
   .din(ex0_derat_snoop_val_d),
   .dout(ex0_derat_snoop_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex1_derat_snoop_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex1_derat_snoop_val_offset]),
   .scout(sov[ex1_derat_snoop_val_offset]),
   .din(ex1_derat_snoop_val_d),
   .dout(ex1_derat_snoop_val_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_fp_reg(
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
   .scin(siv[spr_msr_fp_offset:spr_msr_fp_offset + `THREADS - 1]),
   .scout(sov[spr_msr_fp_offset:spr_msr_fp_offset + `THREADS - 1]),
   .din(spr_msr_fp_d),
   .dout(spr_msr_fp_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_spv_reg(
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
   .scin(siv[spr_msr_spv_offset:spr_msr_spv_offset + `THREADS - 1]),
   .scout(sov[spr_msr_spv_offset:spr_msr_spv_offset + `THREADS - 1]),
   .din(spr_msr_spv_d),
   .dout(spr_msr_spv_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_gs_reg(
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
   .scin(siv[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .scout(sov[spr_msr_gs_offset:spr_msr_gs_offset + `THREADS - 1]),
   .din(spr_msr_gs_d),
   .dout(spr_msr_gs_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_pr_reg(
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
   .scin(siv[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .scout(sov[spr_msr_pr_offset:spr_msr_pr_offset + `THREADS - 1]),
   .din(spr_msr_pr_d),
   .dout(spr_msr_pr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_ds_reg(
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
   .scin(siv[spr_msr_ds_offset:spr_msr_ds_offset + `THREADS - 1]),
   .scout(sov[spr_msr_ds_offset:spr_msr_ds_offset + `THREADS - 1]),
   .din(spr_msr_ds_d),
   .dout(spr_msr_ds_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_msr_de_reg(
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
   .scin(siv[spr_msr_de_offset:spr_msr_de_offset + `THREADS - 1]),
   .scout(sov[spr_msr_de_offset:spr_msr_de_offset + `THREADS - 1]),
   .din(spr_msr_de_d),
   .dout(spr_msr_de_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_dbcr0_idm_reg(
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
   .scin(siv[spr_dbcr0_idm_offset:spr_dbcr0_idm_offset + `THREADS - 1]),
   .scout(sov[spr_dbcr0_idm_offset:spr_dbcr0_idm_offset + `THREADS - 1]),
   .din(spr_dbcr0_idm_d),
   .dout(spr_dbcr0_idm_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) spr_epcr_duvd_reg(
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
   .scin(siv[spr_epcr_duvd_offset:spr_epcr_duvd_offset + `THREADS - 1]),
   .scout(sov[spr_epcr_duvd_offset:spr_epcr_duvd_offset + `THREADS - 1]),
   .din(spr_epcr_duvd_d),
   .dout(spr_epcr_duvd_q)
);

tri_rlmreg_p #(.WIDTH(8), .INIT(0), .NEEDS_SRESET(1)) spr_lpidr_reg(
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
   .scin(siv[spr_lpidr_offset:spr_lpidr_offset + 8 - 1]),
   .scout(sov[spr_lpidr_offset:spr_lpidr_offset + 8 - 1]),
   .din(spr_lpidr_d),
   .dout(spr_lpidr_q)
);

generate begin : spr_pid_reg
      genvar tid;
      for (tid=0; tid<`THREADS; tid=tid+1) begin : spr_pid_reg
         tri_ser_rlmreg_p #(.WIDTH(14), .INIT(0), .NEEDS_SRESET(1)) spr_pid_reg(
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
            .scin(siv[spr_pid_offset + 14 * tid:spr_pid_offset + 14 * (tid + 1) - 1]),
            .scout(sov[spr_pid_offset + 14 * tid:spr_pid_offset + 14 * (tid + 1) - 1]),
            .din(spr_pid_d[tid]),
            .dout(spr_pid_q[tid])
         );
      end
   end
endgenerate

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_icswx_gs_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icswx_gs_offset]),
   .scout(sov[ex3_icswx_gs_offset]),
   .din(ex3_icswx_gs_d),
   .dout(ex3_icswx_gs_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_icswx_pr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_icswx_pr_offset]),
   .scout(sov[ex3_icswx_pr_offset]),
   .din(ex3_icswx_pr_d),
   .dout(ex3_icswx_pr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icswx_ct_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icswx_ct_val_offset]),
   .scout(sov[ex4_icswx_ct_val_offset]),
   .din(ex4_icswx_ct_val_d),
   .dout(ex4_icswx_ct_val_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex4_icswx_ct_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_icswx_ct_offset:ex4_icswx_ct_offset + 2 - 1]),
   .scout(sov[ex4_icswx_ct_offset:ex4_icswx_ct_offset + 2 - 1]),
   .din(ex4_icswx_ct_d),
   .dout(ex4_icswx_ct_q)
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

tri_regk #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) ex5_ttype_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_ttype_offset:ex5_ttype_offset + 6 - 1]),
   .scout(sov[ex5_ttype_offset:ex5_ttype_offset + 6 - 1]),
   .din(ex5_ttype_d),
   .dout(ex5_ttype_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_wNComp_rcvd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_wNComp_rcvd_offset]),
   .scout(sov[ex4_wNComp_rcvd_offset]),
   .din(ex4_wNComp_rcvd_d),
   .dout(ex4_wNComp_rcvd_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_wNComp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_wNComp_offset]),
   .scout(sov[ex4_wNComp_offset]),
   .din(ex4_wNComp_d),
   .dout(ex4_wNComp_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_wNComp_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wNComp_offset]),
   .scout(sov[ex5_wNComp_offset]),
   .din(ex5_wNComp_d),
   .dout(ex5_wNComp_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_wNComp_cr_upd_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wNComp_cr_upd_offset]),
   .scout(sov[ex5_wNComp_cr_upd_offset]),
   .din(ex5_wNComp_cr_upd_d),
   .dout(ex5_wNComp_cr_upd_q)
);

tri_regk #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex5_dvc_en_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_dvc_en_offset:ex5_dvc_en_offset + 2 - 1]),
   .scout(sov[ex5_dvc_en_offset:ex5_dvc_en_offset + 2 - 1]),
   .din(ex5_dvc_en_d),
   .dout(ex5_dvc_en_q)
);

tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) ex6_dvc_en_reg(
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
   .scin(siv[ex6_dvc_en_offset:ex6_dvc_en_offset + 2 - 1]),
   .scout(sov[ex6_dvc_en_offset:ex6_dvc_en_offset + 2 - 1]),
   .din(ex6_dvc_en_d),
   .dout(ex6_dvc_en_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_is_inval_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_is_inval_op_offset]),
   .scout(sov[ex4_is_inval_op_offset]),
   .din(ex4_is_inval_op_d),
   .dout(ex4_is_inval_op_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_l1_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_l1_lock_set_offset]),
   .scout(sov[ex4_l1_lock_set_offset]),
   .din(ex4_l1_lock_set_d),
   .dout(ex4_l1_lock_set_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_l1_lock_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_l1_lock_set_offset]),
   .scout(sov[ex5_l1_lock_set_offset]),
   .din(ex5_l1_lock_set_d),
   .dout(ex5_l1_lock_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lock_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_lock_clr_offset]),
   .scout(sov[ex4_lock_clr_offset]),
   .din(ex4_lock_clr_d),
   .dout(ex4_lock_clr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_lock_clr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lock_clr_offset]),
   .scout(sov[ex5_lock_clr_offset]),
   .din(ex5_lock_clr_d),
   .dout(ex5_lock_clr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_sfx_val_reg(
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
   .scin(siv[ex2_sfx_val_offset]),
   .scout(sov[ex2_sfx_val_offset]),
   .din(ex2_sfx_val_d),
   .dout(ex2_sfx_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_sfx_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_sfx_val_offset]),
   .scout(sov[ex3_sfx_val_offset]),
   .din(ex3_sfx_val_d),
   .dout(ex3_sfx_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_sfx_val_reg(
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
   .scin(siv[ex4_sfx_val_offset]),
   .scout(sov[ex4_sfx_val_offset]),
   .din(ex4_sfx_val_d),
   .dout(ex4_sfx_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ucode_val_reg(
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
   .scin(siv[ex2_ucode_val_offset]),
   .scout(sov[ex2_ucode_val_offset]),
   .din(ex2_ucode_val_d),
   .dout(ex2_ucode_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_ucode_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ucode_val_offset]),
   .scout(sov[ex3_ucode_val_offset]),
   .din(ex3_ucode_val_d),
   .dout(ex3_ucode_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ucode_val_reg(
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
   .scin(siv[ex4_ucode_val_offset]),
   .scout(sov[ex4_ucode_val_offset]),
   .din(ex4_ucode_val_d),
   .dout(ex4_ucode_val_q)
);

tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_ucode_cnt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_ucode_cnt_offset:ex2_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex2_ucode_cnt_offset:ex2_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex2_ucode_cnt_d),
   .dout(ex2_ucode_cnt_q)
);

tri_regk #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_ucode_cnt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ucode_cnt_offset:ex3_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .scout(sov[ex3_ucode_cnt_offset:ex3_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
   .din(ex3_ucode_cnt_d),
   .dout(ex3_ucode_cnt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_ucode_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_ucode_op_offset]),
   .scout(sov[ex2_ucode_op_offset]),
   .din(ex2_ucode_op_d),
   .dout(ex2_ucode_op_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex3_ucode_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_ucode_op_offset]),
   .scout(sov[ex3_ucode_op_offset]),
   .din(ex3_ucode_op_d),
   .dout(ex3_ucode_op_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_ucode_op_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_ucode_op_offset]),
   .scout(sov[ex4_ucode_op_offset]),
   .din(ex4_ucode_op_d),
   .dout(ex4_ucode_op_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lq_comp_rpt_reg(
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
   .scin(siv[ex6_lq_comp_rpt_offset]),
   .scout(sov[ex6_lq_comp_rpt_offset]),
   .din(ex6_lq_comp_rpt_d),
   .dout(ex6_lq_comp_rpt_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_execute_vld_reg(
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
   .scin(siv[lq0_iu_execute_vld_offset:lq0_iu_execute_vld_offset + `THREADS - 1]),
   .scout(sov[lq0_iu_execute_vld_offset:lq0_iu_execute_vld_offset + `THREADS - 1]),
   .din(lq0_iu_execute_vld_d),
   .dout(lq0_iu_execute_vld_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_itag_offset:lq0_iu_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[lq0_iu_itag_offset:lq0_iu_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(lq0_iu_itag_d),
   .dout(lq0_iu_itag_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_flush2ucode_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_flush2ucode_type_offset]),
   .scout(sov[lq0_iu_flush2ucode_type_offset]),
   .din(lq0_iu_flush2ucode_type_d),
   .dout(lq0_iu_flush2ucode_type_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_recirc_val_reg(
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
   .scin(siv[lq0_iu_recirc_val_offset:lq0_iu_recirc_val_offset + `THREADS - 1]),
   .scout(sov[lq0_iu_recirc_val_offset:lq0_iu_recirc_val_offset + `THREADS - 1]),
   .din(lq0_iu_recirc_val_d),
   .dout(lq0_iu_recirc_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_flush2ucode_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_flush2ucode_offset]),
   .scout(sov[lq0_iu_flush2ucode_offset]),
   .din(lq0_iu_flush2ucode_d),
   .dout(lq0_iu_flush2ucode_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_dear_val_reg(
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
   .scin(siv[lq0_iu_dear_val_offset:lq0_iu_dear_val_offset + `THREADS - 1]),
   .scout(sov[lq0_iu_dear_val_offset:lq0_iu_dear_val_offset + `THREADS - 1]),
   .din(lq0_iu_dear_val_d),
   .dout(lq0_iu_dear_val_q)
);

tri_rlmreg_p #(.WIDTH(2**`GPR_WIDTH_ENC), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_eff_addr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_eff_addr_offset:lq0_iu_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .scout(sov[lq0_iu_eff_addr_offset:lq0_iu_eff_addr_offset + (2**`GPR_WIDTH_ENC) - 1]),
   .din(lq0_iu_eff_addr_d),
   .dout(lq0_iu_eff_addr_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_n_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_n_flush_offset]),
   .scout(sov[lq0_iu_n_flush_offset]),
   .din(lq0_iu_n_flush_d),
   .dout(lq0_iu_n_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_np1_flush_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_np1_flush_offset]),
   .scout(sov[lq0_iu_np1_flush_offset]),
   .din(lq0_iu_np1_flush_d),
   .dout(lq0_iu_np1_flush_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_exception_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_exception_val_offset]),
   .scout(sov[lq0_iu_exception_val_offset]),
   .din(lq0_iu_exception_val_d),
   .dout(lq0_iu_exception_val_q)
);

tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_exception_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_exception_offset:lq0_iu_exception_offset + 6 - 1]),
   .scout(sov[lq0_iu_exception_offset:lq0_iu_exception_offset + 6 - 1]),
   .din(lq0_iu_exception_d),
   .dout(lq0_iu_exception_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_iu_dacr_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_dacr_type_offset]),
   .scout(sov[lq0_iu_dacr_type_offset]),
   .din(lq0_iu_dacr_type_d),
   .dout(lq0_iu_dacr_type_q)
);

tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_dacrw_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_dacrw_offset:lq0_iu_dacrw_offset + 4 - 1]),
   .scout(sov[lq0_iu_dacrw_offset:lq0_iu_dacrw_offset + 4 - 1]),
   .din(lq0_iu_dacrw_d),
   .dout(lq0_iu_dacrw_q)
);

tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) lq0_iu_instr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(lq0_iu_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[lq0_iu_instr_offset:lq0_iu_instr_offset + 32 - 1]),
   .scout(sov[lq0_iu_instr_offset:lq0_iu_instr_offset + 32 - 1]),
   .din(lq0_iu_instr_d),
   .dout(lq0_iu_instr_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_spec_load_miss_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_spec_load_miss_offset]),
   .scout(sov[ex5_spec_load_miss_offset]),
   .din(ex5_spec_load_miss_d),
   .dout(ex5_spec_load_miss_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_spec_itag_vld_reg(
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
   .scin(siv[ex5_spec_itag_vld_offset]),
   .scout(sov[ex5_spec_itag_vld_offset]),
   .din(ex5_spec_itag_vld_d),
   .dout(ex5_spec_itag_vld_q)
);

tri_regk #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_spec_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_spec_itag_offset:ex5_spec_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[ex5_spec_itag_offset:ex5_spec_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(ex5_spec_itag_d),
   .dout(ex5_spec_itag_q)
);

tri_regk #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ex5_spec_tid_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_spec_tid_offset:ex5_spec_tid_offset + `THREADS - 1]),
   .scout(sov[ex5_spec_tid_offset:ex5_spec_tid_offset + `THREADS - 1]),
   .din(ex5_spec_tid_d),
   .dout(ex5_spec_tid_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_blk_pf_load_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_blk_pf_load_offset]),
   .scout(sov[ex5_blk_pf_load_offset]),
   .din(ex5_blk_pf_load_d),
   .dout(ex5_blk_pf_load_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_lq_wNComp_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_lq_wNComp_val_offset]),
   .scout(sov[ex5_lq_wNComp_val_offset]),
   .din(ex5_lq_wNComp_val_d),
   .dout(ex5_lq_wNComp_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_lq_wNComp_val_reg(
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
   .scin(siv[ex6_lq_wNComp_val_offset]),
   .scout(sov[ex6_lq_wNComp_val_offset]),
   .din(ex6_lq_wNComp_val_d),
   .dout(ex6_lq_wNComp_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_wNComp_ord_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wNComp_ord_offset]),
   .scout(sov[ex5_wNComp_ord_offset]),
   .din(ex5_wNComp_ord_d),
   .dout(ex5_wNComp_ord_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_restart_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_restart_val_offset]),
   .scout(sov[ex5_restart_val_offset]),
   .din(ex5_restart_val_d),
   .dout(ex5_restart_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_derat_restart_reg(
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
   .scin(siv[ex5_derat_restart_offset]),
   .scout(sov[ex5_derat_restart_offset]),
   .din(ex5_derat_restart_d),
   .dout(ex5_derat_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_derat_restart_reg(
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
   .scin(siv[ex6_derat_restart_offset]),
   .scout(sov[ex6_derat_restart_offset]),
   .din(ex6_derat_restart_d),
   .dout(ex6_derat_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dir_restart_reg(
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
   .scin(siv[ex5_dir_restart_offset]),
   .scout(sov[ex5_dir_restart_offset]),
   .din(ex5_dir_restart_d),
   .dout(ex5_dir_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_dir_restart_reg(
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
   .scin(siv[ex6_dir_restart_offset]),
   .scout(sov[ex6_dir_restart_offset]),
   .din(ex6_dir_restart_d),
   .dout(ex6_dir_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex5_dec_restart_reg(
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
   .scin(siv[ex5_dec_restart_offset]),
   .scout(sov[ex5_dec_restart_offset]),
   .din(ex5_dec_restart_d),
   .dout(ex5_dec_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_dec_restart_reg(
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
   .scin(siv[ex6_dec_restart_offset]),
   .scout(sov[ex6_dec_restart_offset]),
   .din(ex6_dec_restart_d),
   .dout(ex6_dec_restart_q)
);


tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_derat_itagHit_reg(
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
   .scin(siv[ex4_derat_itagHit_offset]),
   .scout(sov[ex4_derat_itagHit_offset]),
   .din(ex4_derat_itagHit_d),
   .dout(ex4_derat_itagHit_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stq_restart_val_reg(
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
   .scin(siv[ex6_stq_restart_val_offset]),
   .scout(sov[ex6_stq_restart_val_offset]),
   .din(ex6_stq_restart_val_d),
   .dout(ex6_stq_restart_val_q)
);
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_restart_val_reg(
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
   .scin(siv[ex6_restart_val_offset]),
   .scout(sov[ex6_restart_val_offset]),
   .din(ex6_restart_val_d),
   .dout(ex6_restart_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_execute_vld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_execute_vld_offset]),
   .scout(sov[ex5_execute_vld_offset]),
   .din(ex5_execute_vld_d),
   .dout(ex5_execute_vld_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_flush2ucode_type_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_flush2ucode_type_offset]),
   .scout(sov[ex5_flush2ucode_type_offset]),
   .din(ex5_flush2ucode_type_d),
   .dout(ex5_flush2ucode_type_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_recirc_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_recirc_val_offset]),
   .scout(sov[ex5_recirc_val_offset]),
   .din(ex5_recirc_val_d),
   .dout(ex5_recirc_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) ex5_wchkall_cplt_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_wchkall_cplt_offset]),
   .scout(sov[ex5_wchkall_cplt_offset]),
   .din(ex5_wchkall_cplt_d),
   .dout(ex5_wchkall_cplt_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_misalign_flush_reg(
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
   .scin(siv[ex6_misalign_flush_offset]),
   .scout(sov[ex6_misalign_flush_offset]),
   .din(ex6_misalign_flush_d),
   .dout(ex6_misalign_flush_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) ldq_idle_reg(
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
   .scin(siv[ldq_idle_offset:ldq_idle_offset + `THREADS - 1]),
   .scout(sov[ldq_idle_offset:ldq_idle_offset + `THREADS - 1]),
   .din(ldq_idle_d),
   .dout(ldq_idle_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_strg_gate_reg(
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
   .scin(siv[ex4_strg_gate_offset]),
   .scout(sov[ex4_strg_gate_offset]),
   .din(ex4_strg_gate_d),
   .dout(ex4_strg_gate_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_lswx_restart_reg(
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
   .scin(siv[ex4_lswx_restart_offset]),
   .scout(sov[ex4_lswx_restart_offset]),
   .din(ex4_lswx_restart_d),
   .dout(ex4_lswx_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_icswx_restart_reg(
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
   .scin(siv[ex4_icswx_restart_offset]),
   .scout(sov[ex4_icswx_restart_offset]),
   .din(ex4_icswx_restart_d),
   .dout(ex4_icswx_restart_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex4_is_sync_reg(
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
   .scin(siv[ex4_is_sync_offset]),
   .scout(sov[ex4_is_sync_offset]),
   .din(ex4_is_sync_d),
   .dout(ex4_is_sync_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) rel2_xu_wren_reg(
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
   .scin(siv[rel2_xu_wren_offset]),
   .scout(sov[rel2_xu_wren_offset]),
   .din(rel2_xu_wren_d),
   .dout(rel2_xu_wren_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_store_val_reg(
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
   .scin(siv[stq2_store_val_offset]),
   .scout(sov[stq2_store_val_offset]),
   .din(stq2_store_val_d),
   .dout(stq2_store_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_store_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_store_val_offset]),
   .scout(sov[stq3_store_val_offset]),
   .din(stq3_store_val_d),
   .dout(stq3_store_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_store_val_reg(
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
   .scin(siv[stq4_store_val_offset]),
   .scout(sov[stq4_store_val_offset]),
   .din(stq4_store_val_d),
   .dout(stq4_store_val_q)
);

tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) stq6_itag_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_itag_offset:stq6_itag_offset + `ITAG_SIZE_ENC - 1]),
   .scout(sov[stq6_itag_offset:stq6_itag_offset + `ITAG_SIZE_ENC - 1]),
   .din(stq6_itag_d),
   .dout(stq6_itag_q)
);

tri_rlmreg_p #(.WIDTH(AXU_TARGET_ENC), .INIT(0), .NEEDS_SRESET(1)) stq6_tgpr_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_tgpr_offset:stq6_tgpr_offset + AXU_TARGET_ENC - 1]),
   .scout(sov[stq6_tgpr_offset:stq6_tgpr_offset + AXU_TARGET_ENC - 1]),
   .din(stq6_tgpr_d),
   .dout(stq6_tgpr_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq2_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_thrd_id_offset:stq2_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq2_thrd_id_offset:stq2_thrd_id_offset + `THREADS - 1]),
   .din(stq2_thrd_id_d),
   .dout(stq2_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq3_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_thrd_id_offset:stq3_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq3_thrd_id_offset:stq3_thrd_id_offset + `THREADS - 1]),
   .din(stq3_thrd_id_d),
   .dout(stq3_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq4_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_thrd_id_offset:stq4_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq4_thrd_id_offset:stq4_thrd_id_offset + `THREADS - 1]),
   .din(stq4_thrd_id_d),
   .dout(stq4_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq5_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq4_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_thrd_id_offset:stq5_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq5_thrd_id_offset:stq5_thrd_id_offset + `THREADS - 1]),
   .din(stq5_thrd_id_d),
   .dout(stq5_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq6_thrd_id_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq5_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq6_thrd_id_offset:stq6_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq6_thrd_id_offset:stq6_thrd_id_offset + `THREADS - 1]),
   .din(stq6_thrd_id_d),
   .dout(stq6_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq7_thrd_id_reg(
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
   .scin(siv[stq7_thrd_id_offset:stq7_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq7_thrd_id_offset:stq7_thrd_id_offset + `THREADS - 1]),
   .din(stq7_thrd_id_d),
   .dout(stq7_thrd_id_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) stq8_thrd_id_reg(
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
   .scin(siv[stq8_thrd_id_offset:stq8_thrd_id_offset + `THREADS - 1]),
   .scout(sov[stq8_thrd_id_offset:stq8_thrd_id_offset + `THREADS - 1]),
   .din(stq8_thrd_id_d),
   .dout(stq8_thrd_id_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_mftgpr_val_reg(
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
   .scin(siv[stq2_mftgpr_val_offset]),
   .scout(sov[stq2_mftgpr_val_offset]),
   .din(stq2_mftgpr_val_d),
   .dout(stq2_mftgpr_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_mftgpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_mftgpr_val_offset]),
   .scout(sov[stq3_mftgpr_val_offset]),
   .din(stq3_mftgpr_val_d),
   .dout(stq3_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_mftgpr_val_reg(
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
   .scin(siv[stq4_mftgpr_val_offset]),
   .scout(sov[stq4_mftgpr_val_offset]),
   .din(stq4_mftgpr_val_d),
   .dout(stq4_mftgpr_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq5_mftgpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_mftgpr_val_offset]),
   .scout(sov[stq5_mftgpr_val_offset]),
   .din(stq5_mftgpr_val_d),
   .dout(stq5_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_mftgpr_val_reg(
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
   .scin(siv[stq6_mftgpr_val_offset]),
   .scout(sov[stq6_mftgpr_val_offset]),
   .din(stq6_mftgpr_val_d),
   .dout(stq6_mftgpr_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq7_mftgpr_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq7_mftgpr_val_offset]),
   .scout(sov[stq7_mftgpr_val_offset]),
   .din(stq7_mftgpr_val_d),
   .dout(stq7_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq8_mftgpr_val_reg(
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
   .scin(siv[stq8_mftgpr_val_offset]),
   .scout(sov[stq8_mftgpr_val_offset]),
   .din(stq8_mftgpr_val_d),
   .dout(stq8_mftgpr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_mfdpf_val_reg(
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
   .scin(siv[stq2_mfdpf_val_offset]),
   .scout(sov[stq2_mfdpf_val_offset]),
   .din(stq2_mfdpf_val_d),
   .dout(stq2_mfdpf_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_mfdpf_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_mfdpf_val_offset]),
   .scout(sov[stq3_mfdpf_val_offset]),
   .din(stq3_mfdpf_val_d),
   .dout(stq3_mfdpf_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_mfdpf_val_reg(
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
   .scin(siv[stq4_mfdpf_val_offset]),
   .scout(sov[stq4_mfdpf_val_offset]),
   .din(stq4_mfdpf_val_d),
   .dout(stq4_mfdpf_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq5_mfdpf_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_mfdpf_val_offset]),
   .scout(sov[stq5_mfdpf_val_offset]),
   .din(stq5_mfdpf_val_d),
   .dout(stq5_mfdpf_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_mfdpa_val_reg(
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
   .scin(siv[stq2_mfdpa_val_offset]),
   .scout(sov[stq2_mfdpa_val_offset]),
   .din(stq2_mfdpa_val_d),
   .dout(stq2_mfdpa_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_mfdpa_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_mfdpa_val_offset]),
   .scout(sov[stq3_mfdpa_val_offset]),
   .din(stq3_mfdpa_val_d),
   .dout(stq3_mfdpa_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_mfdpa_val_reg(
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
   .scin(siv[stq4_mfdpa_val_offset]),
   .scout(sov[stq4_mfdpa_val_offset]),
   .din(stq4_mfdpa_val_d),
   .dout(stq4_mfdpa_val_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq5_mfdpa_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq5_mfdpa_val_offset]),
   .scout(sov[stq5_mfdpa_val_offset]),
   .din(stq5_mfdpa_val_d),
   .dout(stq5_mfdpa_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq6_mfdpa_val_reg(
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
   .scin(siv[stq6_mfdpa_val_offset]),
   .scout(sov[stq6_mfdpa_val_offset]),
   .din(stq6_mfdpa_val_d),
   .dout(stq6_mfdpa_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_ci_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_ci_offset]),
   .scout(sov[stq2_ci_offset]),
   .din(stq2_ci_d),
   .dout(stq2_ci_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_ci_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_ci_offset]),
   .scout(sov[stq3_ci_offset]),
   .din(stq3_ci_d),
   .dout(stq3_ci_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_resv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_resv_offset]),
   .scout(sov[stq2_resv_offset]),
   .din(stq2_resv_d),
   .dout(stq2_resv_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_resv_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_resv_offset]),
   .scout(sov[stq3_resv_offset]),
   .din(stq3_resv_d),
   .dout(stq3_resv_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_wclr_val_reg(
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
   .scin(siv[stq2_wclr_val_offset]),
   .scout(sov[stq2_wclr_val_offset]),
   .din(stq2_wclr_val_d),
   .dout(stq2_wclr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_wclr_val_reg(
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
   .scin(siv[stq3_wclr_val_offset]),
   .scout(sov[stq3_wclr_val_offset]),
   .din(stq3_wclr_val_d),
   .dout(stq3_wclr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_wclr_val_reg(
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
   .scin(siv[stq4_wclr_val_offset]),
   .scout(sov[stq4_wclr_val_offset]),
   .din(stq4_wclr_val_d),
   .dout(stq4_wclr_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_wclr_all_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_wclr_all_set_offset]),
   .scout(sov[stq2_wclr_all_set_offset]),
   .din(stq2_wclr_all_set_d),
   .dout(stq2_wclr_all_set_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) stq3_wclr_all_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_wclr_all_set_offset]),
   .scout(sov[stq3_wclr_all_set_offset]),
   .din(stq3_wclr_all_set_d),
   .dout(stq3_wclr_all_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_wclr_all_set_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq4_wclr_all_set_offset]),
   .scout(sov[stq4_wclr_all_set_offset]),
   .din(stq4_wclr_all_set_d),
   .dout(stq4_wclr_all_set_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_epid_val_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq1_stg_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq2_epid_val_offset]),
   .scout(sov[stq2_epid_val_offset]),
   .din(stq2_epid_val_d),
   .dout(stq2_epid_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_rec_stcx_reg(
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
   .scin(siv[stq4_rec_stcx_offset]),
   .scout(sov[stq4_rec_stcx_offset]),
   .din(stq4_rec_stcx_d),
   .dout(stq4_rec_stcx_q)
);

tri_regk #(.WIDTH(25), .INIT(0), .NEEDS_SRESET(1)) stq3_icswx_data_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(stq2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[stq3_icswx_data_offset:stq3_icswx_data_offset + 25 - 1]),
   .scout(sov[stq3_icswx_data_offset:stq3_icswx_data_offset + 25 - 1]),
   .din(stq3_icswx_data_d),
   .dout(stq3_icswx_data_q)
);

tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex2_cr_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex1_instr_act),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex2_cr_fld_offset:ex2_cr_fld_offset + `CR_POOL_ENC - 1]),
   .scout(sov[ex2_cr_fld_offset:ex2_cr_fld_offset + `CR_POOL_ENC - 1]),
   .din(ex2_cr_fld_d),
   .dout(ex2_cr_fld_q)
);

tri_regk #(.WIDTH(`CR_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex3_cr_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex2_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex3_cr_fld_offset:ex3_cr_fld_offset + `CR_POOL_ENC - 1]),
   .scout(sov[ex3_cr_fld_offset:ex3_cr_fld_offset + `CR_POOL_ENC - 1]),
   .din(ex3_cr_fld_d),
   .dout(ex3_cr_fld_q)
);

tri_rlmreg_p #(.WIDTH(`CR_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex4_cr_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex3_stg_act_q),
   .force_t(func_sl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex4_cr_fld_offset:ex4_cr_fld_offset + `CR_POOL_ENC - 1]),
   .scout(sov[ex4_cr_fld_offset:ex4_cr_fld_offset + `CR_POOL_ENC - 1]),
   .din(ex4_cr_fld_d),
   .dout(ex4_cr_fld_q)
);

tri_regk #(.WIDTH(`CR_POOL_ENC+`THREADS_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) ex5_cr_fld_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(ex4_stg_act_q),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[ex5_cr_fld_offset:ex5_cr_fld_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) - 1]),
   .scout(sov[ex5_cr_fld_offset:ex5_cr_fld_offset + (`CR_POOL_ENC+`THREADS_POOL_ENC) - 1]),
   .din(ex5_cr_fld_d),
   .dout(ex5_cr_fld_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_val_reg(
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
   .scin(siv[dir_arr_rd_val_offset]),
   .scout(sov[dir_arr_rd_val_offset]),
   .din(dir_arr_rd_val_d),
   .dout(dir_arr_rd_val_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_tid_reg(
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
   .scin(siv[dir_arr_rd_tid_offset:dir_arr_rd_tid_offset + `THREADS - 1]),
   .scout(sov[dir_arr_rd_tid_offset:dir_arr_rd_tid_offset + `THREADS - 1]),
   .din(dir_arr_rd_tid_d),
   .dout(dir_arr_rd_tid_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_rv1_val_reg(
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
   .scin(siv[dir_arr_rd_rv1_val_offset]),
   .scout(sov[dir_arr_rd_rv1_val_offset]),
   .din(dir_arr_rd_rv1_val_d),
   .dout(dir_arr_rd_rv1_val_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex0_done_reg(
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
   .scin(siv[dir_arr_rd_ex0_done_offset]),
   .scout(sov[dir_arr_rd_ex0_done_offset]),
   .din(dir_arr_rd_ex0_done_d),
   .dout(dir_arr_rd_ex0_done_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex1_done_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[dir_arr_rd_ex1_done_offset]),
   .scout(sov[dir_arr_rd_ex1_done_offset]),
   .din(dir_arr_rd_ex1_done_d),
   .dout(dir_arr_rd_ex1_done_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex2_done_reg(
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
   .scin(siv[dir_arr_rd_ex2_done_offset]),
   .scout(sov[dir_arr_rd_ex2_done_offset]),
   .din(dir_arr_rd_ex2_done_d),
   .dout(dir_arr_rd_ex2_done_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex3_done_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[dir_arr_rd_ex3_done_offset]),
   .scout(sov[dir_arr_rd_ex3_done_offset]),
   .din(dir_arr_rd_ex3_done_d),
   .dout(dir_arr_rd_ex3_done_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex4_done_reg(
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
   .scin(siv[dir_arr_rd_ex4_done_offset]),
   .scout(sov[dir_arr_rd_ex4_done_offset]),
   .din(dir_arr_rd_ex4_done_d),
   .dout(dir_arr_rd_ex4_done_q)
);

tri_regk #(.WIDTH(1), .INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex5_done_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .act(tiup),
   .force_t(func_nsl_force),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_nsl_thold_0_b),
   .sg(sg_0),
   .scin(siv[dir_arr_rd_ex5_done_offset]),
   .scout(sov[dir_arr_rd_ex5_done_offset]),
   .din(dir_arr_rd_ex5_done_d),
   .dout(dir_arr_rd_ex5_done_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dir_arr_rd_ex6_done_reg(
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
   .scin(siv[dir_arr_rd_ex6_done_offset]),
   .scout(sov[dir_arr_rd_ex6_done_offset]),
   .din(dir_arr_rd_ex6_done_d),
   .dout(dir_arr_rd_ex6_done_q)
);

tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0), .NEEDS_SRESET(1)) pc_lq_ram_active_reg(
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
   .scin(siv[pc_lq_ram_active_offset:pc_lq_ram_active_offset + `THREADS - 1]),
   .scout(sov[pc_lq_ram_active_offset:pc_lq_ram_active_offset + `THREADS - 1]),
   .din(pc_lq_ram_active_d),
   .dout(pc_lq_ram_active_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq_pc_ram_data_val_reg(
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
   .scin(siv[lq_pc_ram_data_val_offset]),
   .scout(sov[lq_pc_ram_data_val_offset]),
   .din(lq_pc_ram_data_val_d),
   .dout(lq_pc_ram_data_val_q)
);

//---------------------------------------------------------------------
// ACT's
//---------------------------------------------------------------------
tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex1_stg_act_reg(
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
   .scin(siv[ex1_stg_act_offset]),
   .scout(sov[ex1_stg_act_offset]),
   .din(ex1_stg_act_d),
   .dout(ex1_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex2_stg_act_reg(
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
   .scin(siv[ex2_stg_act_offset]),
   .scout(sov[ex2_stg_act_offset]),
   .din(ex2_stg_act_d),
   .dout(ex2_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex3_stg_act_reg(
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
   .scin(siv[ex3_stg_act_offset]),
   .scout(sov[ex3_stg_act_offset]),
   .din(ex3_stg_act_d),
   .dout(ex3_stg_act_q)
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

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ex6_stg_act_reg(
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
   .scin(siv[ex6_stg_act_offset]),
   .scout(sov[ex6_stg_act_offset]),
   .din(ex6_stg_act_d),
   .dout(ex6_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv2_stg_act_reg(
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
   .scin(siv[binv2_stg_act_offset]),
   .scout(sov[binv2_stg_act_offset]),
   .din(binv2_stg_act_d),
   .dout(binv2_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv3_stg_act_reg(
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
   .scin(siv[binv3_stg_act_offset]),
   .scout(sov[binv3_stg_act_offset]),
   .din(binv3_stg_act_d),
   .dout(binv3_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv4_stg_act_reg(
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
   .scin(siv[binv4_stg_act_offset]),
   .scout(sov[binv4_stg_act_offset]),
   .din(binv4_stg_act_d),
   .dout(binv4_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv5_stg_act_reg(
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
   .scin(siv[binv5_stg_act_offset]),
   .scout(sov[binv5_stg_act_offset]),
   .din(binv5_stg_act_d),
   .dout(binv5_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) binv6_stg_act_reg(
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
   .scin(siv[binv6_stg_act_offset]),
   .scout(sov[binv6_stg_act_offset]),
   .din(binv6_stg_act_d),
   .dout(binv6_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq2_stg_act_reg(
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
   .scin(siv[stq2_stg_act_offset]),
   .scout(sov[stq2_stg_act_offset]),
   .din(stq2_stg_act_d),
   .dout(stq2_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq3_stg_act_reg(
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
   .scin(siv[stq3_stg_act_offset]),
   .scout(sov[stq3_stg_act_offset]),
   .din(stq3_stg_act_d),
   .dout(stq3_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq4_stg_act_reg(
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
   .scin(siv[stq4_stg_act_offset]),
   .scout(sov[stq4_stg_act_offset]),
   .din(stq4_stg_act_d),
   .dout(stq4_stg_act_q)
);

tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) stq5_stg_act_reg(
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
   .scin(siv[stq5_stg_act_offset]),
   .scout(sov[stq5_stg_act_offset]),
   .din(stq5_stg_act_d),
   .dout(stq5_stg_act_q)
);

assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
assign fgen_scan_in = sov[0];
assign scan_out = fgen_scan_out;

endmodule
