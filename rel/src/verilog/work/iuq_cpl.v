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

//  Description:  Completion Unit
//
//*****************************************************************************

`include "tri_a2o.vh"

module iuq_cpl(
   // Clocks
   input [0:`NCLK_WIDTH-1]       nclk,

   // Pervasive
   input                         tc_ac_ccflush_dc,
   input                         clkoff_dc_b,
   input                         d_mode_dc,
   input                         delay_lclkr_dc,
   input                         mpw1_dc_b,
   input                         mpw2_dc_b,
   input                         func_sl_thold_2,
   input                         func_slp_sl_thold_2,
   input                         sg_2,
   input                         scan_in,
   output                        scan_out,

   // Perfomance selectors
   input                         pc_iu_event_bus_enable,
   input [0:2]		         pc_iu_event_count_mode,
   input [0:15]                  spr_cp_perf_event_mux_ctrls,
   input [0:3]                   event_bus_in,
   output [0:3]                  event_bus_out,

   // Instruction 0 Issue
   input                         rn_cp_iu6_i0_vld,
   input [1:`ITAG_SIZE_ENC-1]    rn_cp_iu6_i0_itag,
   input [0:2]                   rn_cp_iu6_i0_ucode,
   input                         rn_cp_iu6_i0_fuse_nop,
   input                         rn_cp_iu6_i0_rte_lq,
   input                         rn_cp_iu6_i0_rte_sq,
   input                         rn_cp_iu6_i0_rte_fx0,
   input                         rn_cp_iu6_i0_rte_fx1,
   input                         rn_cp_iu6_i0_rte_axu0,
   input                         rn_cp_iu6_i0_rte_axu1,

   input [62-`EFF_IFAR_WIDTH:61] rn_cp_iu6_i0_ifar,
   input [62-`EFF_IFAR_WIDTH:61] rn_cp_iu6_i0_bta,
   input                         rn_cp_iu6_i0_isram,
   input [0:31]                  rn_cp_iu6_i0_instr,

   input                         rn_cp_iu6_i0_valop,
   input [0:2]                   rn_cp_iu6_i0_error,
   input                         rn_cp_iu6_i0_br_pred,
   input                         rn_cp_iu6_i0_bh_update,
   input [0:1]                   rn_cp_iu6_i0_bh0_hist,
   input [0:1]                   rn_cp_iu6_i0_bh1_hist,
   input [0:1]                   rn_cp_iu6_i0_bh2_hist,
   input [0:9]                   rn_cp_iu6_i0_gshare,
   input [0:2]                   rn_cp_iu6_i0_ls_ptr,
   input                         rn_cp_iu6_i0_match,

   input                         rn_cp_iu6_i0_type_fp,
   input                         rn_cp_iu6_i0_type_ap,
   input                         rn_cp_iu6_i0_type_spv,
   input                         rn_cp_iu6_i0_type_st,
   input                         rn_cp_iu6_i0_async_block,
   input                         rn_cp_iu6_i0_np1_flush,

   input                         rn_cp_iu6_i0_t1_v,
   input [0:`TYPE_WIDTH-1]       rn_cp_iu6_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t1_a,

   input                         rn_cp_iu6_i0_t2_v,
   input [0:`TYPE_WIDTH-1]        rn_cp_iu6_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t2_a,

   input                         rn_cp_iu6_i0_t3_v,
   input [0:`TYPE_WIDTH-1]        rn_cp_iu6_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i0_t3_a,

   input                         rn_cp_iu6_i0_btb_entry,
   input [0:1]                   rn_cp_iu6_i0_btb_hist,
   input                         rn_cp_iu6_i0_bta_val,

   // Instruction 1 Issue
   input                         rn_cp_iu6_i1_vld,
   input [1:`ITAG_SIZE_ENC-1]    rn_cp_iu6_i1_itag,
   input [0:2]                   rn_cp_iu6_i1_ucode,
   input                         rn_cp_iu6_i1_fuse_nop,
   input                         rn_cp_iu6_i1_rte_lq,
   input                         rn_cp_iu6_i1_rte_sq,
   input                         rn_cp_iu6_i1_rte_fx0,
   input                         rn_cp_iu6_i1_rte_fx1,
   input                         rn_cp_iu6_i1_rte_axu0,
   input                         rn_cp_iu6_i1_rte_axu1,

   input [62-`EFF_IFAR_WIDTH:61] rn_cp_iu6_i1_ifar,
   input [62-`EFF_IFAR_WIDTH:61] rn_cp_iu6_i1_bta,
   input                         rn_cp_iu6_i1_isram,
   input [0:31]                  rn_cp_iu6_i1_instr,

   input                         rn_cp_iu6_i1_valop,
   input [0:2]                   rn_cp_iu6_i1_error,
   input                         rn_cp_iu6_i1_br_pred,
   input                         rn_cp_iu6_i1_bh_update,
   input [0:1]                   rn_cp_iu6_i1_bh0_hist,
   input [0:1]                   rn_cp_iu6_i1_bh1_hist,
   input [0:1]                   rn_cp_iu6_i1_bh2_hist,
   input [0:9]                   rn_cp_iu6_i1_gshare,
   input [0:2]                   rn_cp_iu6_i1_ls_ptr,
   input                         rn_cp_iu6_i1_match,

   input                         rn_cp_iu6_i1_type_fp,
   input                         rn_cp_iu6_i1_type_ap,
   input                         rn_cp_iu6_i1_type_spv,
   input                         rn_cp_iu6_i1_type_st,
   input                         rn_cp_iu6_i1_async_block,
   input                         rn_cp_iu6_i1_np1_flush,

   input                         rn_cp_iu6_i1_t1_v,
   input [0:`TYPE_WIDTH-1]       rn_cp_iu6_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t1_a,

   input                         rn_cp_iu6_i1_t2_v,
   input [0:`TYPE_WIDTH-1]       rn_cp_iu6_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t2_a,

   input                         rn_cp_iu6_i1_t3_v,
   input [0:`TYPE_WIDTH-1]       rn_cp_iu6_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]     rn_cp_iu6_i1_t3_a,

   input                         rn_cp_iu6_i1_btb_entry,
   input [0:1]                   rn_cp_iu6_i1_btb_hist,
   input                         rn_cp_iu6_i1_bta_val,

   // completion empty
   output                        cp_rn_empty,
   output                        cp_async_block,

   // Instruction 0 Complete
   output                        cp_rn_i0_v,
   output                        cp_rn_i0_axu_exception_val,
   output [0:3]                  cp_rn_i0_axu_exception,
   output                        cp_rn_i0_t1_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t1_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t1_a,

   output                        cp_rn_i0_t2_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i0_t2_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t2_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t2_a,

   output                        cp_rn_i0_t3_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i0_t3_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t3_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i0_t3_a,

   // Instruction 1 Complete
   output                        cp_rn_i1_v,
   output                        cp_rn_i1_axu_exception_val,
   output [0:3]                  cp_rn_i1_axu_exception,
   output                        cp_rn_i1_t1_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t1_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t1_a,

   output                        cp_rn_i1_t2_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i1_t2_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t2_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t2_a,

   output                        cp_rn_i1_t3_v,
   output [0:`TYPE_WIDTH-1]      cp_rn_i1_t3_t,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t3_p,
   output [0:`GPR_POOL_ENC-1]    cp_rn_i1_t3_a,

   // Branch Prediction Complete
   output                        cp_bp_val,
   output [62-`EFF_IFAR_WIDTH:61] cp_bp_ifar,
   output [0:1]                  cp_bp_bh0_hist,
   output [0:1]                  cp_bp_bh1_hist,
   output [0:1]                  cp_bp_bh2_hist,
   output                        cp_bp_br_pred,
   output                        cp_bp_br_taken,
   output                        cp_bp_bh_update,
   output                        cp_bp_bcctr,
   output                        cp_bp_bclr,
   output                        cp_bp_lk,
   output [0:1]                  cp_bp_bh,
   output [0:9]                  cp_bp_gshare,
   output [0:2]                  cp_bp_ls_ptr,
   output [62-`EFF_IFAR_WIDTH:61] cp_bp_ctr,
   output                        cp_bp_btb_entry,
   output [0:1]                  cp_bp_btb_hist,
   output                        cp_bp_getnia,
   output                        cp_bp_group,

   // Output to dispatch to block due to ivax
   output                        cp_dis_ivax,

   // LQ Instruction Executed
   input                         lq0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    lq0_iu_itag,
   input                         lq0_iu_n_flush,
   input                         lq0_iu_np1_flush,
   input                         lq0_iu_dacr_type,
   input [0:3]                   lq0_iu_dacrw,
   input [0:31]                  lq0_iu_instr,
   input [64-`GPR_WIDTH:63]      lq0_iu_eff_addr,
   input                         lq0_iu_exception_val,
   input [0:5]                   lq0_iu_exception,
   input                         lq0_iu_flush2ucode,
   input                         lq0_iu_flush2ucode_type,
   input                         lq0_iu_recirc_val,
   input                         lq0_iu_dear_val,

   input                         lq1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    lq1_iu_itag,
   input                         lq1_iu_n_flush,
   input                         lq1_iu_np1_flush,
   input                         lq1_iu_exception_val,
   input [0:5]                   lq1_iu_exception,
   input                         lq1_iu_dacr_type,
   input [0:3]                   lq1_iu_dacrw,
   input [0:3]                   lq1_iu_perf_events,

   output                        iu_lq_i0_completed,
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_i0_completed_itag,
   output                        iu_lq_i1_completed,
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_i1_completed_itag,

   output                        iu_lq_recirc_val,

   // BR Instruction Executed
   input                         br_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    br_iu_itag,
   input                         br_iu_redirect,
   input [62-`EFF_IFAR_ARCH:61]  br_iu_bta,
   input                         br_iu_taken,
   input [0:3]                   br_iu_perf_events,

   // XU0 Instruction Executed
   input                         xu_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    xu_iu_itag,
   input                         xu_iu_n_flush,
   input                         xu_iu_np1_flush,
   input                         xu_iu_flush2ucode,
   input                         xu_iu_exception_val,
   input [0:4]                   xu_iu_exception,
   input                         xu_iu_mtiar,
   input [62-`EFF_IFAR_ARCH:61]  xu_iu_bta,
   input [0:3]                   xu_iu_perf_events,

   // XU0 Instruction Executed
   input                         xu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    xu1_iu_itag,

   // AXU0 Instruction Executed
   input                         axu0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    axu0_iu_itag,
   input                         axu0_iu_n_flush,
   input                         axu0_iu_np1_flush,
   input                         axu0_iu_n_np1_flush,
   input                         axu0_iu_flush2ucode,
   input                         axu0_iu_flush2ucode_type,
   input                         axu0_iu_exception_val,
   input [0:3]                   axu0_iu_exception,
   input [0:3]                   axu0_iu_perf_events,

   // AXU1 Instruction Executed
   input                         axu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]    axu1_iu_itag,
   input                         axu1_iu_n_flush,
   input                         axu1_iu_np1_flush,
   input                         axu1_iu_flush2ucode,
   input                         axu1_iu_flush2ucode_type,
   input                         axu1_iu_exception_val,
   input [0:3]                   axu1_iu_exception,
   input [0:3]                   axu1_iu_perf_events,

   // Interrupts
   input                         an_ac_uncond_dbg_event,
   input                         xu_iu_external_mchk,
   input                         xu_iu_ext_interrupt,
   input                         xu_iu_dec_interrupt,
   input                         xu_iu_udec_interrupt,
   input                         xu_iu_perf_interrupt,
   input                         xu_iu_fit_interrupt,
   input                         xu_iu_crit_interrupt,
   input                         xu_iu_wdog_interrupt,
   input                         xu_iu_gwdog_interrupt,
   input                         xu_iu_gfit_interrupt,
   input                         xu_iu_gdec_interrupt,
   input                         xu_iu_dbell_interrupt,
   input                         xu_iu_cdbell_interrupt,
   input                         xu_iu_gdbell_interrupt,
   input                         xu_iu_gcdbell_interrupt,
   input                         xu_iu_gmcdbell_interrupt,
   input                         xu_iu_dbsr_ide,

   input [62-`EFF_IFAR_ARCH:61]  xu_iu_rest_ifar,
   input                         axu0_iu_async_fex,

   // To Ierats
   output                        cp_is_isync,
   output                        cp_is_csync,

   // Flushes
   output                        iu_flush,
   output                        cp_flush_into_uc,
   output [43:61]                cp_uc_flush_ifar,
   output                        cp_uc_np1_flush,
   output                        cp_flush,
   output [0:`ITAG_SIZE_ENC-1]   cp_next_itag,
   output [0:`ITAG_SIZE_ENC-1]   cp_flush_itag,
   output [62-`EFF_IFAR_ARCH:61] cp_flush_ifar,
   output                        cp_iu0_flush_2ucode,
   output                        cp_iu0_flush_2ucode_type,
   output                        cp_iu0_flush_nonspec,
   input                         pc_iu_init_reset,
   output                        cp_rn_uc_credit_free,

   // Signals to SPR partition
   output                        iu_xu_rfi,
   output                        iu_xu_rfgi,
   output                        iu_xu_rfci,
   output                        iu_xu_rfmci,
   output                        iu_xu_int,
   output                        iu_xu_gint,
   output                        iu_xu_cint,
   output                        iu_xu_mcint,
   output [62-`EFF_IFAR_ARCH:61] iu_xu_nia,
   output [0:16]                 iu_xu_esr,
   output [0:14]                 iu_xu_mcsr,
   output [0:18]                 iu_xu_dbsr,
   output                        iu_xu_dear_update,
   output [64-`GPR_WIDTH:63]     iu_xu_dear,
   output                        iu_xu_dbsr_update,
   output                        iu_xu_dbsr_ude,
   output                        iu_xu_dbsr_ide,
   output                        iu_xu_esr_update,
   output                        iu_xu_act,
   output                        iu_xu_dbell_taken,
   output                        iu_xu_cdbell_taken,
   output                        iu_xu_gdbell_taken,
   output                        iu_xu_gcdbell_taken,
   output                        iu_xu_gmcdbell_taken,
   output                        iu_xu_instr_cpl,
   input                         xu_iu_np1_async_flush,
   output                        iu_xu_async_complete,
   input                         dp_cp_hold_req,
   output                        iu_mm_hold_ack,
   input                         dp_cp_bus_snoop_hold_req,
   output                        iu_mm_bus_snoop_hold_ack,
   output                        iu_spr_eheir_update,
   output [0:31]                 iu_spr_eheir,
   input                         xu_iu_msr_de,
   input                         xu_iu_msr_pr,
   input                         xu_iu_msr_cm,
   input                         xu_iu_msr_gs,
   input                         xu_iu_msr_me,
   input                         xu_iu_dbcr0_edm,
   input                         xu_iu_dbcr0_idm,
   input                         xu_iu_dbcr0_icmp,
   input                         xu_iu_dbcr0_brt,
   input                         xu_iu_dbcr0_irpt,
   input                         xu_iu_dbcr0_trap,
   input                         xu_iu_iac1_en,
   input                         xu_iu_iac2_en,
   input                         xu_iu_iac3_en,
   input                         xu_iu_iac4_en,
   input [0:1]                   xu_iu_dbcr0_dac1,
   input [0:1]                   xu_iu_dbcr0_dac2,
   input [0:1]                   xu_iu_dbcr0_dac3,
   input [0:1]                   xu_iu_dbcr0_dac4,
   input                         xu_iu_dbcr0_ret,
   input                         xu_iu_dbcr1_iac12m,
   input                         xu_iu_dbcr1_iac34m,
   input                         lq_iu_spr_dbcr3_ivc,
   input                         xu_iu_epcr_extgs,
   input                         xu_iu_epcr_dtlbgs,
   input                         xu_iu_epcr_itlbgs,
   input                         xu_iu_epcr_dsigs,
   input                         xu_iu_epcr_isigs,
   input                         xu_iu_epcr_duvd,
   input                         xu_iu_epcr_icm,
   input                         xu_iu_epcr_gicm,
   input                         xu_iu_ccr2_en_dcr,
   input                         xu_iu_ccr2_ucode_dis,
   input                         xu_iu_hid_mmu_mode,
   input                         xu_iu_xucr4_mmu_mchk,

   output                        iu_xu_quiesce,
   output                        iu_pc_quiesce,

   // MMU Errors
   input                         mm_iu_ierat_rel_val,
   input                         mm_iu_ierat_pt_fault,
   input                         mm_iu_ierat_lrat_miss,
   input                         mm_iu_ierat_tlb_inelig,
   input                         mm_iu_tlb_multihit_err,
   input                         mm_iu_tlb_par_err,
   input                         mm_iu_lru_par_err,
   input                         mm_iu_tlb_miss,
   input                         mm_iu_reload_hit,
   input [3:4]                   mm_iu_ierat_mmucr1,
   input                         ic_cp_nonspec_hit,

   output [0:5]                  cp_mm_except_taken,

   // SPRs
   input                         xu_iu_single_instr_mode,
   input                         spr_single_issue,
   input [64-`GPR_WIDTH:51]      spr_ivpr,
   input [64-`GPR_WIDTH:51]      spr_givpr,
   input [62-`EFF_IFAR_ARCH:61]  spr_iac1,
   input [62-`EFF_IFAR_ARCH:61]  spr_iac2,
   input [62-`EFF_IFAR_ARCH:61]  spr_iac3,
   input [62-`EFF_IFAR_ARCH:61]  spr_iac4,

   // XER read bus to RF for store conditionals
   output [0:`XER_POOL_ENC-1]    iu_rf_xer_p,

   // Signals from pervasive
   input                         pc_iu_ram_active,
   input                         pc_iu_ram_flush_thread,
   input                         xu_iu_msrovride_enab,
   output                        iu_pc_ram_done,
   output                        iu_pc_ram_interrupt,
   output                        iu_pc_ram_unsupported,
   input                         pc_iu_stop,
   input                         pc_iu_step,
   input [0:2]                   pc_iu_dbg_action,
   output                        iu_pc_step_done,
   output [0:`THREADS-1]         iu_pc_stop_dbg_event,
   output                        iu_pc_err_debug_event,
   output                        iu_pc_attention_instr,
   output                        iu_pc_err_mchk_disabled,
   output                        ac_an_debug_trigger,
   output                        iu_xu_stop,

   // Power
   inout                         vdd,
   inout                         gnd);




   // Define Offsets for the Queue Entry
   parameter                     entry_ifar_offset = 0;
   parameter                     entry_bp_val_offset = entry_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                     entry_bp_bcctr_offset = entry_bp_val_offset + 1;
   parameter                     entry_bp_bclr_offset = entry_bp_bcctr_offset + 1;
   parameter                     entry_bp_bta_offset = entry_bp_bclr_offset + 1;
   parameter                     entry_rfi_offset = entry_bp_bta_offset + `EFF_IFAR_WIDTH;
   parameter                     entry_rfgi_offset = entry_rfi_offset + 1;
   parameter                     entry_rfci_offset = entry_rfgi_offset + 1;
   parameter                     entry_rfmci_offset = entry_rfci_offset + 1;
   parameter                     entry_ivax_offset = entry_rfmci_offset + 1;
   parameter                     entry_sc_offset = entry_ivax_offset + 1;
   parameter                     entry_mtiar_offset = entry_sc_offset + 1;
   parameter                     entry_rollover_offset = entry_mtiar_offset + 1;
   parameter                     entry_is_csync_offset = entry_rollover_offset + 1;
   parameter                     entry_is_isync_offset = entry_is_csync_offset + 1;
   parameter                     entry_bh_update_offset = entry_is_isync_offset + 1;
   parameter                     entry_bh0_hist_offset = entry_bh_update_offset + 1;
   parameter                     entry_bh1_hist_offset = entry_bh0_hist_offset + 2;
   parameter                     entry_bh2_hist_offset = entry_bh1_hist_offset + 2;
   parameter                     entry_gshare_offset = entry_bh2_hist_offset + 2;
   parameter                     entry_ls_ptr_offset = entry_gshare_offset + 10;
   parameter                     entry_isram_offset = entry_ls_ptr_offset + 3;
   parameter                     entry_lk_offset = entry_isram_offset + 1;
   parameter                     entry_bh_offset = entry_lk_offset + 1;
   parameter                     entry_getnia_offset = entry_bh_offset + 2;
   parameter                     entry_ld_offset = entry_getnia_offset + 1;
   parameter                     entry_st_offset = entry_ld_offset + 1;
   parameter                     entry_epid_offset = entry_st_offset + 1;
   parameter                     entry_ucode_offset = entry_epid_offset + 1;
   parameter                     entry_type_fp_offset = entry_ucode_offset + 3;
   parameter                     entry_type_ap_offset = entry_type_fp_offset + 1;
   parameter                     entry_type_spv_offset = entry_type_ap_offset + 1;
   parameter                     entry_type_st_offset = entry_type_spv_offset + 1;
   parameter                     entry_attn_offset = entry_type_st_offset + 1;
   parameter                     entry_fuse_nop_offset = entry_attn_offset + 1;
   parameter                     entry_icmp_block_offset = entry_fuse_nop_offset + 1;
   parameter                     entry_nonspec_offset = entry_icmp_block_offset + 1;
   parameter                     entry_t1_v_offset = entry_nonspec_offset + 1;
   parameter                     entry_t1_t_offset = entry_t1_v_offset + 1;
   parameter                     entry_t1_p_offset = entry_t1_t_offset + `TYPE_WIDTH;
   parameter                     entry_t1_a_offset = entry_t1_p_offset + `GPR_POOL_ENC;
   parameter                     entry_t2_v_offset = entry_t1_a_offset + `GPR_POOL_ENC;
   parameter                     entry_t2_t_offset = entry_t2_v_offset + 1;
   parameter                     entry_t2_p_offset = entry_t2_t_offset + `TYPE_WIDTH;
   parameter                     entry_t2_a_offset = entry_t2_p_offset + `GPR_POOL_ENC;
   parameter                     entry_t3_v_offset = entry_t2_a_offset + `GPR_POOL_ENC;
   parameter                     entry_t3_t_offset = entry_t3_v_offset + 1;
   parameter                     entry_t3_p_offset = entry_t3_t_offset + `TYPE_WIDTH;
   parameter                     entry_t3_a_offset = entry_t3_p_offset + `GPR_POOL_ENC;
   parameter                     entry_btb_entry_offset = entry_t3_a_offset + `GPR_POOL_ENC;
   parameter                     entry_btb_hist_offset = entry_btb_entry_offset + 1;
   parameter                     entry_length = entry_btb_hist_offset + 2;
   // Signals
   wire                          tidn;
   wire                          tiup;
   wire                          func_sl_thold_1;
   wire                          func_slp_sl_thold_1;
   wire                          sg_1;
   wire                          func_sl_force;
   wire                          func_sl_thold_0;
   wire                          func_sl_thold_0_b;
   wire                          func_slp_sl_force;
   wire                          func_slp_sl_thold_0;
   wire                          func_slp_sl_thold_0_b;
   wire                          sg_0;
   wire                          we0;
   wire                          we1;
   wire                          re0;
   wire                          re1;
   wire [0:`ITAG_SIZE_ENC-2]      wa0;
   wire [0:`ITAG_SIZE_ENC-2]      wa1;
   wire [0:`ITAG_SIZE_ENC-2]      ra0;
   wire [0:`ITAG_SIZE_ENC-2]      ra1;
   wire [0:entry_length-1]       di0;
   wire [0:entry_length-1]       di1;
   wire [0:entry_length-1]       do0;
   wire [0:entry_length-1]       do1;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i1_ifar;
   wire                          cp2_i0_bp_pred;
   wire                          cp2_i1_bp_pred;
   wire                          cp2_i0_br_pred;
   wire                          cp2_i1_br_pred;
   wire                          cp2_i0_bp_val;
   wire                          cp2_i1_bp_val;
   wire                          cp2_i0_bp_bcctr;
   wire                          cp2_i1_bp_bcctr;
   wire                          cp2_i0_bp_bclr;
   wire                          cp2_i1_bp_bclr;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i0_bp_bta;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i1_bp_bta;
   wire                          cp2_i0_rfi;
   wire                          cp2_i1_rfi;
   wire                          cp2_i0_rfgi;
   wire                          cp2_i1_rfgi;
   wire                          cp2_i0_rfci;
   wire                          cp2_i1_rfci;
   wire                          cp2_i0_rfmci;
   wire                          cp2_i1_rfmci;
   wire                          cp2_i0_ivax;
   wire                          cp2_i1_ivax;
   wire                          cp2_i0_sc;
   wire                          cp2_i1_sc;
   wire                          cp2_i0_mtiar;
   wire                          cp2_i1_mtiar;
   wire                          cp2_i0_rollover;
   wire                          cp2_i1_rollover;
   wire                          cp2_i0_is_csync;
   wire                          cp2_i1_is_csync;
   wire                          cp2_i0_is_isync;
   wire                          cp2_i1_is_isync;
   wire                          cp2_i0_bh_update;
   wire                          cp2_i1_bh_update;
   wire [0:1]                    cp2_i0_bh0_hist;
   wire [0:1]                    cp2_i1_bh0_hist;
   wire [0:1]                    cp2_i0_bh1_hist;
   wire [0:1]                    cp2_i1_bh1_hist;
   wire [0:1]                    cp2_i0_bh2_hist;
   wire [0:1]                    cp2_i1_bh2_hist;
   wire [0:9]                    cp2_i0_gshare;
   wire [0:9]                    cp2_i1_gshare;
   wire [0:2]                    cp2_i0_ls_ptr;
   wire [0:2]                    cp2_i1_ls_ptr;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i0_bta;
   wire [62-`EFF_IFAR_WIDTH:61]   cp2_i1_bta;
   wire                          cp2_i0_isram;
   wire                          cp2_i1_isram;
   wire                          cp2_i0_lk;
   wire                          cp2_i1_lk;
   wire [0:1]                    cp2_i0_bh;
   wire [0:1]                    cp2_i1_bh;
   wire                          cp2_i0_getnia;
   wire                          cp2_i1_getnia;
   wire                          cp2_i0_ld;
   wire                          cp2_i1_ld;
   wire                          cp2_i0_st;
   wire                          cp2_i1_st;
   wire                          cp2_i0_epid;
   wire                          cp2_i1_epid;
   wire [0:2]                    cp2_i0_ucode;
   wire [0:2]                    cp2_i1_ucode;
   wire                          cp2_i0_type_fp;
   wire                          cp2_i1_type_fp;
   wire                          cp2_i0_type_ap;
   wire                          cp2_i1_type_ap;
   wire                          cp2_i0_type_spv;
   wire                          cp2_i1_type_spv;
   wire                          cp2_i0_type_st;
   wire                          cp2_i1_type_st;
   wire                          cp2_i0_attn;
   wire                          cp2_i1_attn;
   wire                          cp2_i0_fuse_nop;
   wire                          cp2_i1_fuse_nop;
   wire                          cp2_i0_icmp_block;
   wire                          cp2_i1_icmp_block;
   wire                          cp2_i0_nonspec;
   wire                          cp2_i1_nonspec;
   wire                          cp2_i0_t1_v;
   wire                          cp2_i1_t1_v;
   wire [0:`TYPE_WIDTH-1]         cp2_i0_t1_t;
   wire [0:`TYPE_WIDTH-1]         cp2_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t1_a;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t1_a;
   wire                          cp2_i0_t2_v;
   wire                          cp2_i1_t2_v;
   wire [0:`TYPE_WIDTH-1]         cp2_i0_t2_t;
   wire [0:`TYPE_WIDTH-1]         cp2_i1_t2_t;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t2_a;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t2_a;
   wire                          cp2_i0_t3_v;
   wire                          cp2_i1_t3_v;
   wire [0:`TYPE_WIDTH-1]         cp2_i0_t3_t;
   wire [0:`TYPE_WIDTH-1]         cp2_i1_t3_t;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t3_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t3_p;
   wire [0:`GPR_POOL_ENC-1]       cp2_i0_t3_a;
   wire [0:`GPR_POOL_ENC-1]       cp2_i1_t3_a;
   wire                          cp2_i0_btb_entry;
   wire                          cp2_i1_btb_entry;
   wire [0:1]                    cp2_i0_btb_hist;
   wire [0:1]                    cp2_i1_btb_hist;
   wire                          cp2_i0_completed;
   wire                          cp2_i1_completed;
   wire [1:`ITAG_SIZE_ENC-1]      cp0_i0_completed_itag;
   wire [1:`ITAG_SIZE_ENC-1]      cp0_i1_completed_itag;
   wire                          cp2_i0_axu_exception_val;
   wire [0:3]                    cp2_i0_axu_exception;
   wire                          cp2_i1_axu_exception_val;
   wire [0:3]                    cp2_i1_axu_exception;

   wire                          b_i0;
   wire                          bc_i0;
   wire                          bclr_i0;
   wire                          bcctr_i0;
   wire                          br_val_i0;
   wire                          br_add_chk_i0;
   wire                          rfi_i0;
   wire                          rfgi_i0;
   wire                          rfci_i0;
   wire                          rfmci_i0;
   wire                          mtiar_i0;
   wire                          isync_i0;
   wire                          sc_i0;
   wire                          sc_hyp_i0;
   wire                          sc_illegal_i0;
   wire                          dcr_illegal_i0;
   wire                          attn_i0;
   wire                          icmp_block_i0;
   wire                          nonspec_i0;
   wire                          ehpriv_i0;
   wire                          mtmsr_i0;
   wire                          ivax_i0;
   wire                          mtpid_i0;
   wire                          mtlpidr_i0;
   wire                          async_block_i0;
   wire                          i0_np1_flush;
   wire                          is_csync_i0;
   wire                          is_isync_i0;
   wire                          b_i1;
   wire                          bc_i1;
   wire                          bclr_i1;
   wire                          bcctr_i1;
   wire                          br_val_i1;
   wire                          br_add_chk_i1;
   wire                          rfi_i1;
   wire                          rfgi_i1;
   wire                          rfci_i1;
   wire                          rfmci_i1;
   wire                          mtiar_i1;
   wire                          isync_i1;
   wire                          sc_i1;
   wire                          sc_hyp_i1;
   wire                          sc_illegal_i1;
   wire                          dcr_illegal_i1;
   wire                          attn_i1;
   wire                          icmp_block_i1;
   wire                          nonspec_i1;
   wire                          ehpriv_i1;
   wire                          mtmsr_i1;
   wire                          ivax_i1;
   wire                          mtpid_i1;
   wire                          mtlpidr_i1;
   wire                          async_block_i1;
   wire                          i1_np1_flush;
   wire                          is_csync_i1;
   wire                          is_isync_i1;
   wire                          folded_op_i0;
   wire                          folded_op_i1;
   wire                          rollover_i0;
   wire                          rollover_i1;

   wire [0:`XER_POOL_ENC-1]       xer_cp_p_q;
   wire [0:`XER_POOL_ENC-1]       xer_cp_p_d;

   // Branch predict calcs
   wire [62-`EFF_IFAR_WIDTH:61]   bta_bd_i0;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_bd_i1;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_li_i0;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_li_i1;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_abs_i0;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_abs_i1;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_off_i0;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_off_i1;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_i0;
   wire [62-`EFF_IFAR_WIDTH:61]   bta_i1;

   wire                           cp_i0_lk;
   wire [0:1]                     cp_i0_bh;
   wire                           cp_i0_getnia;
   wire                           cp_i0_ld;
   wire                           cp_i0_st;
   wire                           cp_i0_epid;

   wire                           cp_i1_lk;
   wire [0:1]                     cp_i1_bh;
   wire                           cp_i1_getnia;
   wire                           cp_i1_ld;
   wire                           cp_i1_st;
   wire                           cp_i1_epid;

   wire                           iu_xu_quiesce_int;
   wire                           cpl_perr;

   // Scanchains
   parameter                     xer_cp_p_offset = 0;
   parameter                     scan_right = xer_cp_p_offset + `XER_POOL_ENC;
   wire [0:scan_right-1]         siv;
   wire [0:scan_right-1]         sov;
   wire                          scan_con_a;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   assign siv = {scan_right{1'b0}};

   assign iu_xu_quiesce = iu_xu_quiesce_int;
   assign iu_pc_quiesce = iu_xu_quiesce_int;

   assign xer_cp_p_d = (cp2_i1_t2_v == 1'b1 & cp2_i1_completed == 1'b1 & cp2_i1_t2_t == 3'b100) ? cp2_i1_t2_p[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1] :
                       (cp2_i0_t2_v == 1'b1 & cp2_i0_completed == 1'b1 & cp2_i0_t2_t == 3'b100) ? cp2_i0_t2_p[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1] :
                       xer_cp_p_q;
   assign iu_rf_xer_p = xer_cp_p_q;

   assign is_csync_i0 = (~mm_iu_ierat_mmucr1[3] & ~xu_iu_hid_mmu_mode) &
                        (sc_i0 | ehpriv_i0 | mtmsr_i0 | mtpid_i0 | mtlpidr_i0 | rfi_i0 | rfgi_i0 | rfci_i0 | rfmci_i0);
   assign is_csync_i1 = (~mm_iu_ierat_mmucr1[3] & ~xu_iu_hid_mmu_mode) &
                        (sc_i1 | ehpriv_i1 | mtmsr_i1 | mtpid_i1 | mtlpidr_i1 | rfi_i1 | rfgi_i1 | rfci_i1 | rfmci_i1);

   assign is_isync_i0 = (~mm_iu_ierat_mmucr1[4] & ~xu_iu_hid_mmu_mode) & isync_i0;
   assign is_isync_i1 = (~mm_iu_ierat_mmucr1[4] & ~xu_iu_hid_mmu_mode) & isync_i1;

   assign b_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010010;
   assign bc_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010000;
   assign bclr_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0000010000;
   assign bcctr_i0 = (rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b1000010000) |
                     (rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b1000110000);		//bctar
   assign br_val_i0 = b_i0 | bc_i0 | bclr_i0 | bcctr_i0;
   assign br_add_chk_i0 = rn_cp_iu6_i0_bta_val;
   assign rfi_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0000110010 & (~(xu_iu_msr_gs == 1'b1 & xu_iu_msr_pr == 1'b0));
   assign rfgi_i0 = (rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0001100110) |
                    (rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0000110010 & xu_iu_msr_gs == 1'b1 & xu_iu_msr_pr == 1'b0);
   assign rfci_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0000110011;
   assign rfmci_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0000100110;
   assign mtiar_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[11:20] == 10'b1001011011 & rn_cp_iu6_i0_instr[21:30] == 10'b0111010011;
   assign isync_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010011 & rn_cp_iu6_i0_instr[21:30] == 10'b0010010110;
   assign sc_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010001 & rn_cp_iu6_i0_instr[20:26] == 7'b0000000 & rn_cp_iu6_i0_instr[30] == 1'b1;
   assign sc_hyp_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010001 & rn_cp_iu6_i0_instr[20:26] == 7'b0000001 & rn_cp_iu6_i0_instr[30] == 1'b1;
   assign sc_illegal_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b010001 & |(rn_cp_iu6_i0_instr[20:25]) & rn_cp_iu6_i0_instr[30] == 1'b1;
   assign dcr_illegal_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & xu_iu_ccr2_en_dcr == 1'b1 &
                            (rn_cp_iu6_i0_instr[21:30] == 10'b0101000011 | rn_cp_iu6_i0_instr[21:30] == 10'b0111000011 |
                             rn_cp_iu6_i0_instr[21:30] == 10'b0100100011 | rn_cp_iu6_i0_instr[21:30] == 10'b0110100011 |
                             rn_cp_iu6_i0_instr[21:30] == 10'b0100000011 | rn_cp_iu6_i0_instr[21:30] == 10'b0110000011);
   assign attn_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b000000 & rn_cp_iu6_i0_instr[21:30] == 10'b0100000000;
   assign icmp_block_i0 = sc_i0 | sc_hyp_i0 | ehpriv_i0 | attn_i0;
   assign nonspec_i0 = rn_cp_iu6_i0_error == 3'b111 & ~rn_cp_iu6_i0_isram;
   assign ehpriv_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b0100001110;
   assign mtmsr_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b0010010010;		// mtmsr

   assign ivax_i0 = (rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b1100110011) |
                    (rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b1100010010);
   assign mtpid_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b0111010011 & rn_cp_iu6_i0_instr[11:20] == 10'b1000000001;
   assign mtlpidr_i0 = rn_cp_iu6_i0_instr[0:5] == 6'b011111 & rn_cp_iu6_i0_instr[21:30] == 10'b0111010011 & rn_cp_iu6_i0_instr[11:20] == 10'b1001001010;

   assign cp_i0_lk     = rn_cp_iu6_i0_instr[31];
   assign cp_i0_bh     = rn_cp_iu6_i0_instr[19:20];
   assign cp_i0_getnia = rn_cp_iu6_i0_instr[0:31] == 32'b01000010100111110000000000000101;

   iuq_cpl_dec iuq_cpl_dec0(
      // Exception Decode input
      .cp2_instr(rn_cp_iu6_i0_instr),
      // Exception Decode output
      .cp2_ld(cp_i0_ld),
      .cp2_st(cp_i0_st),
      .cp2_epid(cp_i0_epid)
   );

   assign async_block_i0 = rn_cp_iu6_i0_async_block;
   assign i0_np1_flush = rn_cp_iu6_i0_np1_flush;

   // Folded ops complete on issue
   assign folded_op_i0 = (~rn_cp_iu6_i0_rte_lq & ~rn_cp_iu6_i0_rte_sq & ~rn_cp_iu6_i0_rte_fx0 &
                          ~rn_cp_iu6_i0_rte_fx1 & ~rn_cp_iu6_i0_rte_axu0 & ~rn_cp_iu6_i0_rte_axu1) | ~rn_cp_iu6_i0_valop | (rn_cp_iu6_i0_error != 3'b000);

   assign b_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010010;
   assign bc_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010000;
   assign bclr_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0000010000;
   assign bcctr_i1 = (rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b1000010000) |
                     (rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b1000110000);		//bctar
   assign br_val_i1 = b_i1 | bc_i1 | bclr_i1 | bcctr_i1;
   assign br_add_chk_i1 = rn_cp_iu6_i1_bta_val;
   assign rfi_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0000110010 & (~(xu_iu_msr_gs == 1'b1 & xu_iu_msr_pr == 1'b0));
   assign rfgi_i1 = (rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0001100110) |
                    (rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0000110010 & xu_iu_msr_gs == 1'b1 & xu_iu_msr_pr == 1'b0);
   assign rfci_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0000110011;
   assign rfmci_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0000100110;
   assign mtiar_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[11:20] == 10'b1001011011 & rn_cp_iu6_i1_instr[21:30] == 10'b0111010011;
   assign isync_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010011 & rn_cp_iu6_i1_instr[21:30] == 10'b0010010110;
   assign sc_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010001 & rn_cp_iu6_i1_instr[20:26] == 7'b0000000 & rn_cp_iu6_i1_instr[30] == 1'b1;
   assign sc_hyp_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010001 & rn_cp_iu6_i1_instr[20:26] == 7'b0000001 & rn_cp_iu6_i1_instr[30] == 1'b1;
   assign sc_illegal_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b010001 & |rn_cp_iu6_i1_instr[20:25] & rn_cp_iu6_i1_instr[30] == 1'b1;
   assign dcr_illegal_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & xu_iu_ccr2_en_dcr == 1'b1 &
                            (rn_cp_iu6_i1_instr[21:30] == 10'b0101000011 | rn_cp_iu6_i1_instr[21:30] == 10'b0111000011 |
                             rn_cp_iu6_i1_instr[21:30] == 10'b0100100011 | rn_cp_iu6_i1_instr[21:30] == 10'b0110100011 |
                             rn_cp_iu6_i1_instr[21:30] == 10'b0100000011 | rn_cp_iu6_i1_instr[21:30] == 10'b0110000011);
   assign attn_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b000000 & rn_cp_iu6_i1_instr[21:30] == 10'b0100000000;
   assign icmp_block_i1 = sc_i1 | sc_hyp_i1 | ehpriv_i1 | attn_i1;
   assign nonspec_i1 = rn_cp_iu6_i1_error == 3'b111 & ~rn_cp_iu6_i1_isram;
   assign ehpriv_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b0100001110;
   assign mtmsr_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b0010010010;		// mtmsr
   assign ivax_i1 = (rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b1100110011) |
                    (rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b1100010010);
   assign mtpid_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b0111010011 & rn_cp_iu6_i1_instr[11:20] == 10'b1000000001;
   assign mtlpidr_i1 = rn_cp_iu6_i1_instr[0:5] == 6'b011111 & rn_cp_iu6_i1_instr[21:30] == 10'b0111010011 & rn_cp_iu6_i1_instr[11:20] == 10'b1001001010;

   assign cp_i1_lk     = rn_cp_iu6_i1_instr[31];
   assign cp_i1_bh     = rn_cp_iu6_i1_instr[19:20];
   assign cp_i1_getnia = rn_cp_iu6_i1_instr[0:31] == 32'b01000010100111110000000000000101;

   iuq_cpl_dec iuq_cpl_dec1(
      // Exception Decode input
      .cp2_instr(rn_cp_iu6_i1_instr),
      // Exception Decode output
      .cp2_ld(cp_i1_ld),
      .cp2_st(cp_i1_st),
      .cp2_epid(cp_i1_epid)
   );

   assign async_block_i1 = rn_cp_iu6_i1_async_block;
   assign i1_np1_flush = rn_cp_iu6_i1_np1_flush;

   // Folded ops complete on issue
   assign folded_op_i1 = (~rn_cp_iu6_i1_rte_lq & ~rn_cp_iu6_i1_rte_sq & ~rn_cp_iu6_i1_rte_fx0 & ~rn_cp_iu6_i1_rte_fx1 &
                          ~rn_cp_iu6_i1_rte_axu0 & ~rn_cp_iu6_i1_rte_axu1) | ~rn_cp_iu6_i1_valop | (rn_cp_iu6_i1_error != 3'b000);

   assign rollover_i0 = (rn_cp_iu6_i0_ifar == {`EFF_IFAR_WIDTH{1'b1}});
   assign rollover_i1 = (rn_cp_iu6_i1_ifar == {`EFF_IFAR_WIDTH{1'b1}});

   //-----------------------------------------------
   // calculate branch target address
   //-----------------------------------------------
   generate
   	begin : xhdl0
   		genvar i;
   		for (i = 62 - `EFF_IFAR_WIDTH; i <= 61; i = i + 1)
   		begin : sign_extend_i0
   			if (i < 48)
   			begin : bd_i0_0
   				assign bta_bd_i0[i] = rn_cp_iu6_i0_instr[16];
   			end
            if (i > 47)
            begin : bd_i0_1
            	assign bta_bd_i0[i] = rn_cp_iu6_i0_instr[i - 32];
            end
            if (i < 38)
            begin : li_i0_0
            	assign bta_li_i0[i] = rn_cp_iu6_i0_instr[6];
            end
            if (i > 37)
            begin : li_i0_1
            	assign bta_li_i0[i] = rn_cp_iu6_i0_instr[i - 32];
            end
         end
      end
   endgenerate

   assign bta_abs_i0[62 - `EFF_IFAR_WIDTH:61] = (b_i0 == 1'b1) ? bta_li_i0[62 - `EFF_IFAR_WIDTH:61] :
                                               bta_bd_i0[62 - `EFF_IFAR_WIDTH:61];

   assign bta_off_i0[62 - `EFF_IFAR_WIDTH:61] = bta_abs_i0[62 - `EFF_IFAR_WIDTH:61] + rn_cp_iu6_i0_ifar[62 - `EFF_IFAR_WIDTH:61];

   assign bta_i0[62 - `EFF_IFAR_WIDTH:61] = (rn_cp_iu6_i0_bta_val == 1'b1) ? rn_cp_iu6_i0_bta :
                                           (rn_cp_iu6_i0_instr[30] == 1'b1) ? bta_abs_i0[62 - `EFF_IFAR_WIDTH:61] :
                                           bta_off_i0[62 - `EFF_IFAR_WIDTH:61];

   generate
      begin : xhdl1
      	genvar                        i;
      	for (i = 62 - `EFF_IFAR_WIDTH; i <= 61; i = i + 1)
      	begin : sign_extend_i1
      		if (i < 48)
      		begin : bd_i1_0
      			assign bta_bd_i1[i] = rn_cp_iu6_i1_instr[16];
      		end
      		if (i > 47)
      		begin : bd_i1_1
      			assign bta_bd_i1[i] = rn_cp_iu6_i1_instr[i - 32];
      		end
      		if (i < 38)
      		begin : li_i1_0
      			assign bta_li_i1[i] = rn_cp_iu6_i1_instr[6];
      		end
      		if (i > 37)
      		begin : li_i1_1
      			assign bta_li_i1[i] = rn_cp_iu6_i1_instr[i - 32];
      		end
      	end
      end
   endgenerate

   assign bta_abs_i1[62 - `EFF_IFAR_WIDTH:61] = (b_i1 == 1'b1) ? bta_li_i1[62 - `EFF_IFAR_WIDTH:61] :
                                               bta_bd_i1[62 - `EFF_IFAR_WIDTH:61];

   assign bta_off_i1[62 - `EFF_IFAR_WIDTH:61] = bta_abs_i1[62 - `EFF_IFAR_WIDTH:61] + rn_cp_iu6_i1_ifar[62 - `EFF_IFAR_WIDTH:61];

   assign bta_i1[62 - `EFF_IFAR_WIDTH:61] = (rn_cp_iu6_i1_bta_val == 1'b1) ? rn_cp_iu6_i1_bta :
                                           (rn_cp_iu6_i1_instr[30] == 1'b1) ? bta_abs_i1[62 - `EFF_IFAR_WIDTH:61] :
                                           bta_off_i1[62 - `EFF_IFAR_WIDTH:61];


   iuq_cpl_ctrl iuq_cpl_ctrl(
   	.nclk(nclk),
   	.d_mode_dc(d_mode_dc),
   	.delay_lclkr_dc(delay_lclkr_dc),
   	.mpw1_dc_b(mpw1_dc_b),
   	.mpw2_dc_b(mpw2_dc_b),
   	.func_sl_force(func_sl_force),
   	.func_sl_thold_0_b(func_sl_thold_0_b),
   	.func_slp_sl_force(func_slp_sl_force),
   	.func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
   	.sg_0(sg_0),
   	.scan_in(scan_in),
   	.scan_out(scan_con_a),
        .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
        .pc_iu_event_count_mode(pc_iu_event_count_mode),
        .spr_cp_perf_event_mux_ctrls(spr_cp_perf_event_mux_ctrls),
        .event_bus_in(event_bus_in),
        .event_bus_out(event_bus_out),
   	.rn_cp_iu6_i0_vld(rn_cp_iu6_i0_vld),
   	.rn_cp_iu6_i0_itag(rn_cp_iu6_i0_itag),
   	.rn_cp_iu6_i0_ifar(rn_cp_iu6_i0_ifar),
   	.rn_cp_iu6_i0_instr(rn_cp_iu6_i0_instr),
   	.rn_cp_iu6_i0_ucode(rn_cp_iu6_i0_ucode),
   	.rn_cp_iu6_i0_fuse_nop(rn_cp_iu6_i0_fuse_nop),
   	.rn_cp_iu6_i0_error(rn_cp_iu6_i0_error),
   	.rn_cp_iu6_i0_valop(rn_cp_iu6_i0_valop),
   	.rn_cp_iu6_i0_is_rfi(rfi_i0),
   	.rn_cp_iu6_i0_is_rfgi(rfgi_i0),
   	.rn_cp_iu6_i0_is_rfci(rfci_i0),
   	.rn_cp_iu6_i0_is_rfmci(rfmci_i0),
   	.rn_cp_iu6_i0_is_isync(isync_i0),
   	.rn_cp_iu6_i0_is_sc(sc_i0),
   	.rn_cp_iu6_i0_is_np1_flush(i0_np1_flush),
   	.rn_cp_iu6_i0_is_sc_hyp(sc_hyp_i0),
   	.rn_cp_iu6_i0_is_sc_ill(sc_illegal_i0),
   	.rn_cp_iu6_i0_is_dcr_ill(dcr_illegal_i0),
   	.rn_cp_iu6_i0_is_attn(attn_i0),
   	.rn_cp_iu6_i0_is_ehpriv(ehpriv_i0),
   	.rn_cp_iu6_i0_is_folded(folded_op_i0),
   	.rn_cp_iu6_i0_async_block(async_block_i0),
   	.rn_cp_iu6_i0_is_br(br_val_i0),
   	.rn_cp_iu6_i0_br_add_chk(br_add_chk_i0),
   	.rn_cp_iu6_i0_pred(rn_cp_iu6_i0_br_pred),
   	.rn_cp_iu6_i0_rollover(rollover_i0),
   	.rn_cp_iu6_i0_isram(rn_cp_iu6_i0_isram),
   	.rn_cp_iu6_i0_match(rn_cp_iu6_i0_match),
   	.rn_cp_iu6_i1_vld(rn_cp_iu6_i1_vld),
   	.rn_cp_iu6_i1_itag(rn_cp_iu6_i1_itag),
   	.rn_cp_iu6_i1_ifar(rn_cp_iu6_i1_ifar),
   	.rn_cp_iu6_i1_instr(rn_cp_iu6_i1_instr),
   	.rn_cp_iu6_i1_ucode(rn_cp_iu6_i1_ucode),
   	.rn_cp_iu6_i1_fuse_nop(rn_cp_iu6_i1_fuse_nop),
   	.rn_cp_iu6_i1_error(rn_cp_iu6_i1_error),
   	.rn_cp_iu6_i1_valop(rn_cp_iu6_i1_valop),
   	.rn_cp_iu6_i1_is_rfi(rfi_i1),
   	.rn_cp_iu6_i1_is_rfgi(rfgi_i1),
   	.rn_cp_iu6_i1_is_rfci(rfci_i1),
   	.rn_cp_iu6_i1_is_rfmci(rfmci_i1),
   	.rn_cp_iu6_i1_is_isync(isync_i1),
   	.rn_cp_iu6_i1_is_sc(sc_i1),
   	.rn_cp_iu6_i1_is_np1_flush(i1_np1_flush),
   	.rn_cp_iu6_i1_is_sc_hyp(sc_hyp_i1),
   	.rn_cp_iu6_i1_is_sc_ill(sc_illegal_i1),
   	.rn_cp_iu6_i1_is_dcr_ill(dcr_illegal_i1),
   	.rn_cp_iu6_i1_is_attn(attn_i1),
   	.rn_cp_iu6_i1_is_ehpriv(ehpriv_i1),
   	.rn_cp_iu6_i1_is_folded(folded_op_i1),
   	.rn_cp_iu6_i1_async_block(async_block_i1),
   	.rn_cp_iu6_i1_is_br(br_val_i1),
   	.rn_cp_iu6_i1_br_add_chk(br_add_chk_i1),
   	.rn_cp_iu6_i1_pred(rn_cp_iu6_i1_br_pred),
   	.rn_cp_iu6_i1_rollover(rollover_i1),
   	.rn_cp_iu6_i1_isram(rn_cp_iu6_i1_isram),
   	.rn_cp_iu6_i1_match(rn_cp_iu6_i1_match),
   	.cp2_i0_completed(cp2_i0_completed),
   	.cp2_i1_completed(cp2_i1_completed),
   	.cp0_i0_completed_itag(cp0_i0_completed_itag),
   	.cp0_i1_completed_itag(cp0_i1_completed_itag),
   	.cp2_i0_ifar(cp2_i0_ifar),
   	.cp2_i1_ifar(cp2_i1_ifar),
   	.cp2_i0_bp_bta(cp2_i0_bp_bta),
   	.cp2_i1_bp_bta(cp2_i1_bp_bta),
   	.cp2_i0_rfi(cp2_i0_rfi),
   	.cp2_i0_rfgi(cp2_i0_rfgi),
   	.cp2_i0_rfci(cp2_i0_rfci),
   	.cp2_i0_rfmci(cp2_i0_rfmci),
   	.cp2_i0_sc(cp2_i0_sc),
   	.cp2_i0_mtiar(cp2_i0_mtiar),
   	.cp2_i0_rollover(cp2_i0_rollover),
   	.cp2_i1_rfi(cp2_i1_rfi),
   	.cp2_i1_rfgi(cp2_i1_rfgi),
   	.cp2_i1_rfci(cp2_i1_rfci),
   	.cp2_i1_rfmci(cp2_i1_rfmci),
   	.cp2_i1_sc(cp2_i1_sc),
   	.cp2_i1_mtiar(cp2_i1_mtiar),
   	.cp2_i1_rollover(cp2_i1_rollover),
   	.cp2_i0_bp_pred(cp2_i0_bp_pred),
   	.cp2_i1_bp_pred(cp2_i1_bp_pred),
   	.cp2_i0_br_pred(cp2_i0_br_pred),
   	.cp2_i1_br_pred(cp2_i1_br_pred),
   	.cp2_i0_bta(cp2_i0_bta),
   	.cp2_i1_bta(cp2_i1_bta),
   	.cp2_i0_isram(cp2_i0_isram),
   	.cp2_i1_isram(cp2_i1_isram),
           .cp2_i0_ld(cp2_i0_ld),
           .cp2_i1_ld(cp2_i1_ld),
           .cp2_i0_st(cp2_i0_st),
           .cp2_i1_st(cp2_i1_st),
           .cp2_i0_epid(cp2_i0_epid),
           .cp2_i1_epid(cp2_i1_epid),
   	.cp2_i0_ucode(cp2_i0_ucode),
   	.cp2_i1_ucode(cp2_i1_ucode),
   	.cp2_i0_type_fp(cp2_i0_type_fp),
   	.cp2_i1_type_fp(cp2_i1_type_fp),
   	.cp2_i0_type_ap(cp2_i0_type_ap),
   	.cp2_i1_type_ap(cp2_i1_type_ap),
   	.cp2_i0_type_spv(cp2_i0_type_spv),
   	.cp2_i1_type_spv(cp2_i1_type_spv),
   	.cp2_i0_type_st(cp2_i0_type_st),
   	.cp2_i1_type_st(cp2_i1_type_st),
   	.cp2_i0_attn(cp2_i0_attn),
   	.cp2_i1_attn(cp2_i1_attn),
   	.cp2_i0_fuse_nop(cp2_i0_fuse_nop),
   	.cp2_i1_fuse_nop(cp2_i1_fuse_nop),
   	.cp2_i0_icmp_block(cp2_i0_icmp_block),
   	.cp2_i1_icmp_block(cp2_i1_icmp_block),
   	.cp2_i0_axu_exception_val(cp2_i0_axu_exception_val),
   	.cp2_i0_axu_exception(cp2_i0_axu_exception),
   	.cp2_i1_axu_exception_val(cp2_i1_axu_exception_val),
   	.cp2_i1_axu_exception(cp2_i1_axu_exception),
   	.cp2_i0_nonspec(cp2_i0_nonspec),
   	.cp2_i1_nonspec(cp2_i1_nonspec),
   	.lq0_iu_execute_vld(lq0_iu_execute_vld),
   	.lq0_iu_itag(lq0_iu_itag),
   	.lq0_iu_n_flush(lq0_iu_n_flush),
   	.lq0_iu_np1_flush(lq0_iu_np1_flush),
   	.lq0_iu_dacr_type(lq0_iu_dacr_type),
   	.lq0_iu_dacrw(lq0_iu_dacrw),
   	.lq0_iu_instr(lq0_iu_instr),
   	.lq0_iu_eff_addr(lq0_iu_eff_addr),
   	.lq0_iu_exception_val(lq0_iu_exception_val),
   	.lq0_iu_exception(lq0_iu_exception),
   	.lq0_iu_flush2ucode(lq0_iu_flush2ucode),
   	.lq0_iu_flush2ucode_type(lq0_iu_flush2ucode_type),
   	.lq0_iu_recirc_val(lq0_iu_recirc_val),
   	.lq0_iu_dear_val(lq0_iu_dear_val),
   	.lq1_iu_execute_vld(lq1_iu_execute_vld),
   	.lq1_iu_itag(lq1_iu_itag),
   	.lq1_iu_n_flush(lq1_iu_n_flush),
   	.lq1_iu_np1_flush(lq1_iu_np1_flush),
   	.lq1_iu_exception_val(lq1_iu_exception_val),
   	.lq1_iu_exception(lq1_iu_exception),
   	.lq1_iu_dacr_type(lq1_iu_dacr_type),
   	.lq1_iu_dacrw(lq1_iu_dacrw),
      .lq1_iu_perf_events(lq1_iu_perf_events),
   	.iu_lq_i0_completed(iu_lq_i0_completed),
   	.iu_lq_i0_completed_itag(iu_lq_i0_completed_itag),
   	.iu_lq_i1_completed(iu_lq_i1_completed),
   	.iu_lq_i1_completed_itag(iu_lq_i1_completed_itag),
   	.iu_lq_recirc_val(iu_lq_recirc_val),
   	.br_iu_execute_vld(br_iu_execute_vld),
   	.br_iu_itag(br_iu_itag),
   	.br_iu_redirect(br_iu_redirect),
   	.br_iu_bta(br_iu_bta),
   	.br_iu_taken(br_iu_taken),
      .br_iu_perf_events(br_iu_perf_events),
   	.xu_iu_execute_vld(xu_iu_execute_vld),
   	.xu_iu_itag(xu_iu_itag),
   	.xu_iu_n_flush(xu_iu_n_flush),
   	.xu_iu_np1_flush(xu_iu_np1_flush),
   	.xu_iu_flush2ucode(xu_iu_flush2ucode),
   	.xu_iu_exception_val(xu_iu_exception_val),
   	.xu_iu_exception(xu_iu_exception),
   	.xu_iu_mtiar(xu_iu_mtiar),
   	.xu_iu_bta(xu_iu_bta),
   	.xu1_iu_execute_vld(xu1_iu_execute_vld),
   	.xu1_iu_itag(xu1_iu_itag),
   	.xu_iu_rest_ifar(xu_iu_rest_ifar),
   	.xu_iu_perf_events(xu_iu_perf_events),
   	.axu0_iu_async_fex(axu0_iu_async_fex),
   	.axu0_iu_execute_vld(axu0_iu_execute_vld),
   	.axu0_iu_itag(axu0_iu_itag),
   	.axu0_iu_n_flush(axu0_iu_n_flush),
   	.axu0_iu_np1_flush(axu0_iu_np1_flush),
   	.axu0_iu_n_np1_flush(axu0_iu_n_np1_flush),
   	.axu0_iu_flush2ucode(axu0_iu_flush2ucode),
   	.axu0_iu_flush2ucode_type(axu0_iu_flush2ucode_type),
   	.axu0_iu_exception_val(axu0_iu_exception_val),
   	.axu0_iu_exception(axu0_iu_exception),
      .axu0_iu_perf_events(axu0_iu_perf_events),
   	.axu1_iu_execute_vld(axu1_iu_execute_vld),
   	.axu1_iu_itag(axu1_iu_itag),
   	.axu1_iu_n_flush(axu1_iu_n_flush),
   	.axu1_iu_np1_flush(axu1_iu_np1_flush),
   	.axu1_iu_n_np1_flush(1'b0),
   	.axu1_iu_flush2ucode(axu1_iu_flush2ucode),
   	.axu1_iu_flush2ucode_type(axu1_iu_flush2ucode_type),
   	.axu1_iu_exception_val(axu1_iu_exception_val),
   	.axu1_iu_exception(axu1_iu_exception),
      .axu1_iu_perf_events(axu1_iu_perf_events),
   	.iu_xu_rfi(iu_xu_rfi),
   	.iu_xu_rfgi(iu_xu_rfgi),
   	.iu_xu_rfci(iu_xu_rfci),
   	.iu_xu_rfmci(iu_xu_rfmci),
   	.iu_xu_int(iu_xu_int),
   	.iu_xu_gint(iu_xu_gint),
   	.iu_xu_cint(iu_xu_cint),
   	.iu_xu_mcint(iu_xu_mcint),
   	.iu_xu_nia(iu_xu_nia),
   	.iu_xu_esr(iu_xu_esr),
   	.iu_xu_mcsr(iu_xu_mcsr),
   	.iu_xu_dbsr(iu_xu_dbsr),
   	.iu_xu_dear_update(iu_xu_dear_update),
   	.iu_xu_dear(iu_xu_dear),
   	.iu_xu_dbsr_update(iu_xu_dbsr_update),
   	.iu_xu_dbsr_ude(iu_xu_dbsr_ude),
   	.iu_xu_dbsr_ide(iu_xu_dbsr_ide),
   	.iu_xu_esr_update(iu_xu_esr_update),
   	.iu_xu_act(iu_xu_act),
   	.iu_xu_dbell_taken(iu_xu_dbell_taken),
   	.iu_xu_cdbell_taken(iu_xu_cdbell_taken),
   	.iu_xu_gdbell_taken(iu_xu_gdbell_taken),
   	.iu_xu_gcdbell_taken(iu_xu_gcdbell_taken),
   	.iu_xu_gmcdbell_taken(iu_xu_gmcdbell_taken),
   	.iu_xu_instr_cpl(iu_xu_instr_cpl),
   	.xu_iu_np1_async_flush(xu_iu_np1_async_flush),
   	.iu_xu_async_complete(iu_xu_async_complete),
   	.dp_cp_hold_req(dp_cp_hold_req),
   	.iu_mm_hold_ack(iu_mm_hold_ack),
   	.dp_cp_bus_snoop_hold_req(dp_cp_bus_snoop_hold_req),
   	.iu_mm_bus_snoop_hold_ack(iu_mm_bus_snoop_hold_ack),
   	.iu_spr_eheir_update(iu_spr_eheir_update),
   	.iu_spr_eheir(iu_spr_eheir),
   	.xu_iu_msr_de(xu_iu_msr_de),
   	.xu_iu_msr_pr(xu_iu_msr_pr),
   	.xu_iu_msr_cm(xu_iu_msr_cm),
   	.xu_iu_msr_gs(xu_iu_msr_gs),
   	.xu_iu_msr_me(xu_iu_msr_me),
   	.xu_iu_dbcr0_edm(xu_iu_dbcr0_edm),
   	.xu_iu_dbcr0_idm(xu_iu_dbcr0_idm),
   	.xu_iu_dbcr0_icmp(xu_iu_dbcr0_icmp),
   	.xu_iu_dbcr0_brt(xu_iu_dbcr0_brt),
   	.xu_iu_dbcr0_irpt(xu_iu_dbcr0_irpt),
   	.xu_iu_dbcr0_trap(xu_iu_dbcr0_trap),
   	.xu_iu_iac1_en(xu_iu_iac1_en),
   	.xu_iu_iac2_en(xu_iu_iac2_en),
   	.xu_iu_iac3_en(xu_iu_iac3_en),
   	.xu_iu_iac4_en(xu_iu_iac4_en),
   	.xu_iu_dbcr0_dac1(xu_iu_dbcr0_dac1),
   	.xu_iu_dbcr0_dac2(xu_iu_dbcr0_dac2),
   	.xu_iu_dbcr0_dac3(xu_iu_dbcr0_dac3),
   	.xu_iu_dbcr0_dac4(xu_iu_dbcr0_dac4),
   	.xu_iu_dbcr0_ret(xu_iu_dbcr0_ret),
   	.xu_iu_dbcr1_iac12m(xu_iu_dbcr1_iac12m),
   	.xu_iu_dbcr1_iac34m(xu_iu_dbcr1_iac34m),
   	.lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
   	.xu_iu_epcr_extgs(xu_iu_epcr_extgs),
   	.xu_iu_epcr_dtlbgs(xu_iu_epcr_dtlbgs),
   	.xu_iu_epcr_itlbgs(xu_iu_epcr_itlbgs),
   	.xu_iu_epcr_dsigs(xu_iu_epcr_dsigs),
   	.xu_iu_epcr_isigs(xu_iu_epcr_isigs),
   	.xu_iu_epcr_duvd(xu_iu_epcr_duvd),
   	.xu_iu_epcr_icm(xu_iu_epcr_icm),
   	.xu_iu_epcr_gicm(xu_iu_epcr_gicm),
   	.xu_iu_ccr2_ucode_dis(xu_iu_ccr2_ucode_dis),
   	.xu_iu_hid_mmu_mode(xu_iu_hid_mmu_mode),
        .xu_iu_xucr4_mmu_mchk(xu_iu_xucr4_mmu_mchk),
        .an_ac_uncond_dbg_event(an_ac_uncond_dbg_event),
   	.xu_iu_external_mchk(xu_iu_external_mchk),
   	.xu_iu_ext_interrupt(xu_iu_ext_interrupt),
   	.xu_iu_dec_interrupt(xu_iu_dec_interrupt),
   	.xu_iu_udec_interrupt(xu_iu_udec_interrupt),
   	.xu_iu_perf_interrupt(xu_iu_perf_interrupt),
   	.xu_iu_fit_interrupt(xu_iu_fit_interrupt),
   	.xu_iu_crit_interrupt(xu_iu_crit_interrupt),
   	.xu_iu_wdog_interrupt(xu_iu_wdog_interrupt),
   	.xu_iu_gwdog_interrupt(xu_iu_gwdog_interrupt),
   	.xu_iu_gfit_interrupt(xu_iu_gfit_interrupt),
   	.xu_iu_gdec_interrupt(xu_iu_gdec_interrupt),
   	.xu_iu_dbell_interrupt(xu_iu_dbell_interrupt),
   	.xu_iu_cdbell_interrupt(xu_iu_cdbell_interrupt),
   	.xu_iu_gdbell_interrupt(xu_iu_gdbell_interrupt),
   	.xu_iu_gcdbell_interrupt(xu_iu_gcdbell_interrupt),
   	.xu_iu_gmcdbell_interrupt(xu_iu_gmcdbell_interrupt),
   	.xu_iu_dbsr_ide(xu_iu_dbsr_ide),
   	.iu_flush(iu_flush),
   	.cp_flush_into_uc(cp_flush_into_uc),
   	.cp_uc_flush_ifar(cp_uc_flush_ifar),
   	.cp_uc_np1_flush(cp_uc_np1_flush),
   	.cp_flush(cp_flush),
   	.cp_next_itag(cp_next_itag),
   	.cp_flush_itag(cp_flush_itag),
   	.cp_flush_ifar(cp_flush_ifar),
   	.cp_iu0_flush_2ucode(cp_iu0_flush_2ucode),
   	.cp_iu0_flush_2ucode_type(cp_iu0_flush_2ucode_type),
   	.cp_iu0_flush_nonspec(cp_iu0_flush_nonspec),
   	.pc_iu_init_reset(pc_iu_init_reset),
   	.xu_iu_single_instr_mode(xu_iu_single_instr_mode),
   	.spr_single_issue(spr_single_issue),
   	.spr_ivpr(spr_ivpr),
   	.spr_givpr(spr_givpr),
   	.spr_iac1(spr_iac1),
   	.spr_iac2(spr_iac2),
   	.spr_iac3(spr_iac3),
   	.spr_iac4(spr_iac4),
   	.pc_iu_ram_active(pc_iu_ram_active),
   	.pc_iu_ram_flush_thread(pc_iu_ram_flush_thread),
   	.xu_iu_msrovride_enab(xu_iu_msrovride_enab),
   	.iu_pc_ram_done(iu_pc_ram_done),
   	.iu_pc_ram_interrupt(iu_pc_ram_interrupt),
   	.iu_pc_ram_unsupported(iu_pc_ram_unsupported),
   	.pc_iu_stop(pc_iu_stop),
   	.pc_iu_step(pc_iu_step),
   	.pc_iu_dbg_action(pc_iu_dbg_action),
   	.iu_pc_step_done(iu_pc_step_done),
   	.iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
   	.iu_pc_err_debug_event(iu_pc_err_debug_event),
   	.iu_pc_attention_instr(iu_pc_attention_instr),
   	.iu_pc_err_mchk_disabled(iu_pc_err_mchk_disabled),
   	.ac_an_debug_trigger(ac_an_debug_trigger),
   	.iu_xu_stop(iu_xu_stop),
   	.iu_xu_quiesce(iu_xu_quiesce_int),
   	.mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
   	.mm_iu_ierat_pt_fault(mm_iu_ierat_pt_fault),
   	.mm_iu_ierat_lrat_miss(mm_iu_ierat_lrat_miss),
   	.mm_iu_ierat_tlb_inelig(mm_iu_ierat_tlb_inelig),
   	.mm_iu_tlb_multihit_err(mm_iu_tlb_multihit_err),
   	.mm_iu_tlb_par_err(mm_iu_tlb_par_err),
   	.mm_iu_lru_par_err(mm_iu_lru_par_err),
        .mm_iu_tlb_miss(mm_iu_tlb_miss),
        .mm_iu_reload_hit(mm_iu_reload_hit),
        .ic_cp_nonspec_hit(ic_cp_nonspec_hit),
   	.cp_mm_except_taken(cp_mm_except_taken),
   	// completion empty
   	.cp_rn_empty(cp_rn_empty),
   	.cp_async_block(cp_async_block),

   	.vdd(vdd),
   	.gnd(gnd)
   );

   assign re0 = 1'b1;
   assign ra0 = cp0_i0_completed_itag;

   assign re1 = 1'b1;
   assign ra1 = cp0_i1_completed_itag;

   assign we0 = rn_cp_iu6_i0_vld;
   assign wa0 = rn_cp_iu6_i0_itag[1:`ITAG_SIZE_ENC - 1];
   assign di0 = {rn_cp_iu6_i0_ifar, br_val_i0, bcctr_i0, bclr_i0, bta_i0, rfi_i0, rfgi_i0, rfci_i0, rfmci_i0, ivax_i0, (sc_i0 | sc_hyp_i0), mtiar_i0, rollover_i0, is_csync_i0, is_isync_i0, rn_cp_iu6_i0_bh_update, rn_cp_iu6_i0_bh0_hist, rn_cp_iu6_i0_bh1_hist, rn_cp_iu6_i0_bh2_hist, rn_cp_iu6_i0_gshare, rn_cp_iu6_i0_ls_ptr, rn_cp_iu6_i0_isram, cp_i0_lk, cp_i0_bh, cp_i0_getnia, cp_i0_ld, cp_i0_st, cp_i0_epid, rn_cp_iu6_i0_ucode, rn_cp_iu6_i0_type_fp, rn_cp_iu6_i0_type_ap, rn_cp_iu6_i0_type_spv, rn_cp_iu6_i0_type_st, attn_i0, rn_cp_iu6_i0_fuse_nop, icmp_block_i0, nonspec_i0, rn_cp_iu6_i0_t1_v, rn_cp_iu6_i0_t1_t, rn_cp_iu6_i0_t1_p, rn_cp_iu6_i0_t1_a, rn_cp_iu6_i0_t2_v, rn_cp_iu6_i0_t2_t, rn_cp_iu6_i0_t2_p, rn_cp_iu6_i0_t2_a, rn_cp_iu6_i0_t3_v, rn_cp_iu6_i0_t3_t, rn_cp_iu6_i0_t3_p, rn_cp_iu6_i0_t3_a, rn_cp_iu6_i0_btb_entry, rn_cp_iu6_i0_btb_hist};


   assign we1 = rn_cp_iu6_i1_vld;
   assign wa1 = rn_cp_iu6_i1_itag[1:`ITAG_SIZE_ENC - 1];
   assign di1 = {rn_cp_iu6_i1_ifar, br_val_i1, bcctr_i1, bclr_i1, bta_i1, rfi_i1, rfgi_i1, rfci_i1, rfmci_i1, ivax_i1, (sc_i1 | sc_hyp_i1), mtiar_i1, rollover_i1, is_csync_i1, is_isync_i1, rn_cp_iu6_i1_bh_update, rn_cp_iu6_i1_bh0_hist, rn_cp_iu6_i1_bh1_hist, rn_cp_iu6_i1_bh2_hist, rn_cp_iu6_i1_gshare, rn_cp_iu6_i1_ls_ptr, rn_cp_iu6_i1_isram, cp_i1_lk, cp_i1_bh, cp_i1_getnia, cp_i1_ld, cp_i1_st, cp_i1_epid, rn_cp_iu6_i1_ucode, rn_cp_iu6_i1_type_fp, rn_cp_iu6_i1_type_ap, rn_cp_iu6_i1_type_spv, rn_cp_iu6_i1_type_st, attn_i1, rn_cp_iu6_i1_fuse_nop, icmp_block_i1, nonspec_i1, rn_cp_iu6_i1_t1_v, rn_cp_iu6_i1_t1_t, rn_cp_iu6_i1_t1_p, rn_cp_iu6_i1_t1_a, rn_cp_iu6_i1_t2_v, rn_cp_iu6_i1_t2_t, rn_cp_iu6_i1_t2_p, rn_cp_iu6_i1_t2_a, rn_cp_iu6_i1_t3_v, rn_cp_iu6_i1_t3_t, rn_cp_iu6_i1_t3_p, rn_cp_iu6_i1_t3_a, rn_cp_iu6_i1_btb_entry, rn_cp_iu6_i1_btb_hist};

   assign cp2_i0_ifar = do0[entry_ifar_offset:entry_ifar_offset + `EFF_IFAR_WIDTH-1];
   assign cp2_i0_bp_val = do0[entry_bp_val_offset];
   assign cp2_i0_bp_bcctr = do0[entry_bp_bcctr_offset];
   assign cp2_i0_bp_bclr = do0[entry_bp_bclr_offset];
   assign cp2_i0_bp_bta = do0[entry_bp_bta_offset:entry_bp_bta_offset + `EFF_IFAR_WIDTH-1];
   assign cp2_i0_rfi = do0[entry_rfi_offset];
   assign cp2_i0_rfgi = do0[entry_rfgi_offset];
   assign cp2_i0_rfci = do0[entry_rfci_offset];
   assign cp2_i0_rfmci = do0[entry_rfmci_offset];
   assign cp2_i0_ivax = do0[entry_ivax_offset];
   assign cp2_i0_sc = do0[entry_sc_offset];
   assign cp2_i0_mtiar = do0[entry_mtiar_offset];
   assign cp2_i0_rollover = do0[entry_rollover_offset];
   assign cp2_i0_is_csync = do0[entry_is_csync_offset];
   assign cp2_i0_is_isync = do0[entry_is_isync_offset];
   assign cp2_i0_bh_update = do0[entry_bh_update_offset];
   assign cp2_i0_bh0_hist = do0[entry_bh0_hist_offset:entry_bh0_hist_offset + 2 - 1];
   assign cp2_i0_bh1_hist = do0[entry_bh1_hist_offset:entry_bh1_hist_offset + 2 - 1];
   assign cp2_i0_bh2_hist = do0[entry_bh2_hist_offset:entry_bh2_hist_offset + 2 - 1];
   assign cp2_i0_gshare = do0[entry_gshare_offset:entry_gshare_offset + 10 - 1];
   assign cp2_i0_ls_ptr = do0[entry_ls_ptr_offset:entry_ls_ptr_offset + 3 - 1];
   assign cp2_i0_isram = do0[entry_isram_offset];
   assign cp2_i0_lk     = do0[entry_lk_offset];
   assign cp2_i0_bh     = do0[entry_bh_offset:entry_bh_offset + 2 - 1];
   assign cp2_i0_getnia = do0[entry_getnia_offset];
   assign cp2_i0_ld     = do0[entry_ld_offset];
   assign cp2_i0_st     = do0[entry_st_offset];
   assign cp2_i0_epid   = do0[entry_epid_offset];
   assign cp2_i0_ucode = do0[entry_ucode_offset:entry_ucode_offset + 3 - 1];
   assign cp2_i0_type_fp = do0[entry_type_fp_offset];
   assign cp2_i0_type_ap = do0[entry_type_ap_offset];
   assign cp2_i0_type_spv = do0[entry_type_spv_offset];
   assign cp2_i0_type_st = do0[entry_type_st_offset];
   assign cp2_i0_attn = do0[entry_attn_offset];
   assign cp2_i0_fuse_nop = do0[entry_fuse_nop_offset];
   assign cp2_i0_icmp_block = do0[entry_icmp_block_offset];
   assign cp2_i0_nonspec = do0[entry_nonspec_offset];
   assign cp2_i0_t1_v = do0[entry_t1_v_offset];
   assign cp2_i0_t1_t = do0[entry_t1_t_offset:entry_t1_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i0_t1_p = do0[entry_t1_p_offset:entry_t1_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_t1_a = do0[entry_t1_a_offset:entry_t1_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_t2_v = do0[entry_t2_v_offset];
   assign cp2_i0_t2_t = do0[entry_t2_t_offset:entry_t2_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i0_t2_p = do0[entry_t2_p_offset:entry_t2_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_t2_a = do0[entry_t2_a_offset:entry_t2_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_t3_v = do0[entry_t3_v_offset];
   assign cp2_i0_t3_t = do0[entry_t3_t_offset:entry_t3_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i0_t3_p = do0[entry_t3_p_offset:entry_t3_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_t3_a = do0[entry_t3_a_offset:entry_t3_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i0_btb_entry = do0[entry_btb_entry_offset];
   assign cp2_i0_btb_hist = do0[entry_btb_hist_offset:entry_btb_hist_offset + 2 - 1];

   assign cp2_i1_ifar = do1[entry_ifar_offset:entry_ifar_offset + `EFF_IFAR_WIDTH - 1];
   assign cp2_i1_bp_val = do1[entry_bp_val_offset];
   assign cp2_i1_bp_bcctr = do1[entry_bp_bcctr_offset];
   assign cp2_i1_bp_bclr = do1[entry_bp_bclr_offset];
   assign cp2_i1_bp_bta = do1[entry_bp_bta_offset:entry_bp_bta_offset + `EFF_IFAR_WIDTH - 1];
   assign cp2_i1_rfi = do1[entry_rfi_offset];
   assign cp2_i1_rfgi = do1[entry_rfgi_offset];
   assign cp2_i1_rfci = do1[entry_rfci_offset];
   assign cp2_i1_rfmci = do1[entry_rfmci_offset];
   assign cp2_i1_ivax = do1[entry_ivax_offset];
   assign cp2_i1_sc = do1[entry_sc_offset];
   assign cp2_i1_mtiar = do1[entry_mtiar_offset];
   assign cp2_i1_rollover = do1[entry_rollover_offset];
   assign cp2_i1_is_csync = do1[entry_is_csync_offset];
   assign cp2_i1_is_isync = do1[entry_is_isync_offset];
   assign cp2_i1_bh_update = do1[entry_bh_update_offset];
   assign cp2_i1_bh0_hist = do1[entry_bh0_hist_offset:entry_bh0_hist_offset + 2 - 1];
   assign cp2_i1_bh1_hist = do1[entry_bh1_hist_offset:entry_bh1_hist_offset + 2 - 1];
   assign cp2_i1_bh2_hist = do1[entry_bh2_hist_offset:entry_bh2_hist_offset + 2 - 1];
   assign cp2_i1_gshare = do1[entry_gshare_offset:entry_gshare_offset + 10 - 1];
   assign cp2_i1_ls_ptr = do1[entry_ls_ptr_offset:entry_ls_ptr_offset + 3 - 1];
   assign cp2_i1_isram = do1[entry_isram_offset];
   assign cp2_i1_lk     = do1[entry_lk_offset];
   assign cp2_i1_bh     = do1[entry_bh_offset:entry_bh_offset + 2 - 1];
   assign cp2_i1_getnia = do1[entry_getnia_offset];
   assign cp2_i1_ld     = do1[entry_ld_offset];
   assign cp2_i1_st     = do1[entry_st_offset];
   assign cp2_i1_epid   = do1[entry_epid_offset];
   assign cp2_i1_ucode = do1[entry_ucode_offset:entry_ucode_offset + 3 - 1];
   assign cp2_i1_type_fp = do1[entry_type_fp_offset];
   assign cp2_i1_type_ap = do1[entry_type_ap_offset];
   assign cp2_i1_type_spv = do1[entry_type_spv_offset];
   assign cp2_i1_type_st = do1[entry_type_st_offset];
   assign cp2_i1_attn = do1[entry_attn_offset];
   assign cp2_i1_fuse_nop = do1[entry_fuse_nop_offset];
   assign cp2_i1_icmp_block = do1[entry_icmp_block_offset];
   assign cp2_i1_nonspec = do1[entry_nonspec_offset];
   assign cp2_i1_t1_v = do1[entry_t1_v_offset];
   assign cp2_i1_t1_t = do1[entry_t1_t_offset:entry_t1_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i1_t1_p = do1[entry_t1_p_offset:entry_t1_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_t1_a = do1[entry_t1_a_offset:entry_t1_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_t2_v = do1[entry_t2_v_offset];
   assign cp2_i1_t2_t = do1[entry_t2_t_offset:entry_t2_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i1_t2_p = do1[entry_t2_p_offset:entry_t2_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_t2_a = do1[entry_t2_a_offset:entry_t2_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_t3_v = do1[entry_t3_v_offset];
   assign cp2_i1_t3_t = do1[entry_t3_t_offset:entry_t3_t_offset + `TYPE_WIDTH - 1];
   assign cp2_i1_t3_p = do1[entry_t3_p_offset:entry_t3_p_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_t3_a = do1[entry_t3_a_offset:entry_t3_a_offset + `GPR_POOL_ENC - 1];
   assign cp2_i1_btb_entry = do1[entry_btb_entry_offset];
   assign cp2_i1_btb_hist = do1[entry_btb_hist_offset:entry_btb_hist_offset + 2 - 1];

   assign cp_rn_i0_v = cp2_i0_completed;
   assign cp_rn_i0_axu_exception_val = cp2_i0_axu_exception_val;
   assign cp_rn_i0_axu_exception = cp2_i0_axu_exception;
   assign cp_rn_i0_t1_v = cp2_i0_t1_v & cp2_i0_completed;
   assign cp_rn_i0_t1_t = cp2_i0_t1_t;
   assign cp_rn_i0_t1_p = cp2_i0_t1_p;
   assign cp_rn_i0_t1_a = cp2_i0_t1_a;

   assign cp_rn_i0_t2_v = cp2_i0_t2_v & cp2_i0_completed;
   assign cp_rn_i0_t2_t = cp2_i0_t2_t;
   assign cp_rn_i0_t2_p = cp2_i0_t2_p;
   assign cp_rn_i0_t2_a = cp2_i0_t2_a;

   assign cp_rn_i0_t3_v = cp2_i0_t3_v & cp2_i0_completed;
   assign cp_rn_i0_t3_t = cp2_i0_t3_t;
   assign cp_rn_i0_t3_p = cp2_i0_t3_p;
   assign cp_rn_i0_t3_a = cp2_i0_t3_a;

   assign cp_rn_i1_v = cp2_i1_completed;
   assign cp_rn_i1_axu_exception_val = cp2_i1_axu_exception_val;
   assign cp_rn_i1_axu_exception = cp2_i1_axu_exception;
   assign cp_rn_i1_t1_v = cp2_i1_t1_v & cp2_i1_completed;
   assign cp_rn_i1_t1_t = cp2_i1_t1_t;
   assign cp_rn_i1_t1_p = cp2_i1_t1_p;
   assign cp_rn_i1_t1_a = cp2_i1_t1_a;

   assign cp_rn_i1_t2_v = cp2_i1_t2_v & cp2_i1_completed;
   assign cp_rn_i1_t2_t = cp2_i1_t2_t;
   assign cp_rn_i1_t2_p = cp2_i1_t2_p;
   assign cp_rn_i1_t2_a = cp2_i1_t2_a;

   assign cp_rn_i1_t3_v = cp2_i1_t3_v & cp2_i1_completed;
   assign cp_rn_i1_t3_t = cp2_i1_t3_t;
   assign cp_rn_i1_t3_p = cp2_i1_t3_p;
   assign cp_rn_i1_t3_a = cp2_i1_t3_a;

   assign cp_rn_uc_credit_free = (cp2_i0_completed & (cp2_i0_ucode == 3'b101)) |
                                 (cp2_i1_completed & (cp2_i1_ucode == 3'b101));
   assign cp_bp_val = (cp2_i0_bp_val & cp2_i0_completed) |
                      (cp2_i1_bp_val & cp2_i1_completed);
   assign cp_bp_bcctr = (cp2_i0_bp_val & cp2_i0_bp_bcctr & cp2_i0_completed) |
                        (cp2_i1_bp_val & cp2_i1_bp_bcctr & cp2_i1_completed);
   assign cp_bp_bclr = (cp2_i0_bp_val & cp2_i0_bp_bclr & cp2_i0_completed) |
                       (cp2_i1_bp_val & cp2_i1_bp_bclr & cp2_i1_completed);
   assign cp_bp_br_pred = (cp2_i0_bp_val & cp2_i0_bp_pred & cp2_i0_completed) |
                          (cp2_i1_bp_val & cp2_i1_bp_pred & cp2_i1_completed);
   assign cp_bp_br_taken = (cp2_i0_bp_val & cp2_i0_br_pred & cp2_i0_completed) |
                           (cp2_i1_bp_val & cp2_i1_br_pred & cp2_i1_completed);
   assign cp_bp_ifar = ({`EFF_IFAR_WIDTH{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_ifar) |
                       ({`EFF_IFAR_WIDTH{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_ifar);
   assign cp_bp_bh0_hist = ({2{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_bh0_hist) |
                           ({2{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_bh0_hist);
   assign cp_bp_bh1_hist = ({2{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_bh1_hist) |
                           ({2{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_bh1_hist);
   assign cp_bp_bh2_hist = ({2{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_bh2_hist) |
                           ({2{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_bh2_hist);
   assign cp_bp_bh_update = (cp2_i0_bp_val & cp2_i0_bh_update & cp2_i0_completed) |
                            (cp2_i1_bp_val & cp2_i1_bh_update & cp2_i1_completed);
   assign cp_bp_lk = (cp2_i0_bp_val & cp2_i0_lk & cp2_i0_completed) |
                     (cp2_i1_bp_val & cp2_i1_lk & cp2_i1_completed);
   assign cp_bp_bh = ({2{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_bh) |
                     ({2{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_bh);
   assign cp_bp_gshare = ({10{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_gshare) |
                         ({10{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_gshare);
   assign cp_bp_ls_ptr = ({3{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_ls_ptr) |
                         ({3{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_ls_ptr);
   assign cp_bp_ctr = ({`EFF_IFAR_WIDTH{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_bta) |
                      ({`EFF_IFAR_WIDTH{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_bta);
   assign cp_bp_btb_entry = (cp2_i0_bp_val & cp2_i0_btb_entry & cp2_i0_completed) |
                            (cp2_i1_bp_val & cp2_i1_btb_entry & cp2_i1_completed);
   assign cp_bp_btb_hist = ({2{cp2_i0_bp_val & cp2_i0_completed}} & cp2_i0_btb_hist) |
                           ({2{cp2_i1_bp_val & cp2_i1_completed}} & cp2_i1_btb_hist);
   assign cp_is_csync = (cp2_i0_completed & cp2_i0_is_csync) |
                        (cp2_i1_completed & cp2_i1_is_csync);
   assign cp_is_isync = (cp2_i0_completed & cp2_i0_is_isync) |
                        (cp2_i1_completed & cp2_i1_is_isync);
   assign cp_bp_getnia = (cp2_i0_bp_val & cp2_i0_getnia & cp2_i0_completed) |
                         (cp2_i1_bp_val & cp2_i1_getnia & cp2_i1_completed);
   assign cp_dis_ivax = (cp2_i0_completed & cp2_i0_ivax) |
                        (cp2_i1_completed & cp2_i0_ivax);

   //end of fetch group completion
   assign cp_bp_group = (cp2_i0_completed & cp2_i0_ifar[60:61]==2'b11) |
                        (cp2_i1_completed & cp2_i1_ifar[60:61]==2'b11);

	// number of addressable register in this array
   // width of the bus to address all ports (2^addressbus_width >= addressable_ports)
   tri_iuq_cpl_arr #(.ADDRESSABLE_PORTS(64), .ADDRESSBUS_WIDTH(6), .PORT_BITWIDTH(entry_length), .LATCHED_READ(1'b1),                 .LATCHED_READ_DATA(1'b1), .LATCHED_WRITE(1'b1))
   iuq_cpl_arr(		// bitwidth of ports
        .gnd(gnd),
        .vdd(vdd),
        .nclk(nclk),
        .delay_lclkr_dc(delay_lclkr_dc),
        .mpw1_dc_b(mpw1_dc_b),
        .mpw2_dc_b(mpw2_dc_b),
        .force_t(force_t),
        .thold_0_b(thold_0_b),
        .sg_0(sg_0),
        .scan_in(scan_con_a),
        .scan_out(scan_out),
   	.re0(re0),
   	.ra0(ra0),
   	.do0(do0),
   	.re1(re1),
   	.ra1(ra1),
   	.do1(do1),
   	.we0(we0),
   	.wa0(wa0),
   	.di0(di0),
   	.we1(we1),
   	.wa1(wa1),
   	.di1(di1),
        .perr(cpl_perr)
   );

   // Latch Instances

   tri_rlmreg_p #(.WIDTH(`XER_POOL_ENC), .INIT(0), .NEEDS_SRESET(1)) xer_cp_p_latch(
   .nclk(nclk),
   .vd(vdd),
   .gd(gnd),
   .act(tiup),
   .d_mode(d_mode_dc),
   .delay_lclkr(delay_lclkr_dc),
   .mpw1_b(mpw1_dc_b),
   .mpw2_b(mpw2_dc_b),
   .thold_b(func_sl_thold_0_b),
   .sg(sg_0),
   .force_t(func_sl_force),
   .scin(siv[xer_cp_p_offset:xer_cp_p_offset + `XER_POOL_ENC - 1]),
   .scout(sov[xer_cp_p_offset:xer_cp_p_offset + `XER_POOL_ENC - 1]),
   .din(xer_cp_p_d),
   .dout(xer_cp_p_q)
   );

   //-----------------------------------------------
   // Pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(3)) perv_2to1_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(tc_ac_ccflush_dc),
   .din({func_sl_thold_2, func_slp_sl_thold_2, sg_2}),
   .q({func_sl_thold_1, func_slp_sl_thold_1, sg_1})
   );

   tri_plat #(.WIDTH(3)) perv_1to0_reg(
   .vd(vdd),
   .gd(gnd),
   .nclk(nclk),
   .flush(tc_ac_ccflush_dc),
   .din({func_sl_thold_1, func_slp_sl_thold_1, sg_1}),
   .q({func_sl_thold_0, func_slp_sl_thold_0, sg_0})
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

endmodule
