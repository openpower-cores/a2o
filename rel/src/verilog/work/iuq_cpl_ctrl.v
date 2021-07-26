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

module iuq_cpl_ctrl(
   // Clocks
   input [0:`NCLK_WIDTH-1]                   nclk,

   // Pervasive
   input                                     d_mode_dc,
   input                                     delay_lclkr_dc,
   input                                     mpw1_dc_b,
   input                                     mpw2_dc_b,
   input                                     func_sl_force,
   input                                     func_sl_thold_0_b,
   input                                     func_slp_sl_force,
   input                                     func_slp_sl_thold_0_b,
   input                                     sg_0,
   input                                     scan_in,
   output                                    scan_out,

   // Perfomance selectors
   input                                     pc_iu_event_bus_enable,
   input [0:2]                               pc_iu_event_count_mode,
   input [0:15]                              spr_cp_perf_event_mux_ctrls,
   input [0:3]                               event_bus_in,
   output [0:3]                              event_bus_out,

   // Instruction Dispatch
   input                                     rn_cp_iu6_i0_vld,
   input [1:`ITAG_SIZE_ENC-1]                rn_cp_iu6_i0_itag,
   input [62-`EFF_IFAR_WIDTH:61]             rn_cp_iu6_i0_ifar,
   input [0:31]                              rn_cp_iu6_i0_instr,
   input [0:2]                               rn_cp_iu6_i0_ucode,
   input                                     rn_cp_iu6_i0_fuse_nop,
   input [0:2]                               rn_cp_iu6_i0_error,
   input                                     rn_cp_iu6_i0_valop,
   input                                     rn_cp_iu6_i0_is_rfi,
   input                                     rn_cp_iu6_i0_is_rfgi,
   input                                     rn_cp_iu6_i0_is_rfci,
   input                                     rn_cp_iu6_i0_is_rfmci,
   input                                     rn_cp_iu6_i0_is_isync,
   input                                     rn_cp_iu6_i0_is_sc,
   input                                     rn_cp_iu6_i0_is_np1_flush,
   input                                     rn_cp_iu6_i0_is_sc_hyp,
   input                                     rn_cp_iu6_i0_is_sc_ill,
   input                                     rn_cp_iu6_i0_is_dcr_ill,
   input                                     rn_cp_iu6_i0_is_attn,
   input                                     rn_cp_iu6_i0_is_ehpriv,
   input                                     rn_cp_iu6_i0_is_folded,
   input                                     rn_cp_iu6_i0_async_block,
   input                                     rn_cp_iu6_i0_is_br,
   input                                     rn_cp_iu6_i0_br_add_chk,
   input                                     rn_cp_iu6_i0_pred,
   input                                     rn_cp_iu6_i0_rollover,
   input                                     rn_cp_iu6_i0_isram,
   input                                     rn_cp_iu6_i0_match,
   input                                     rn_cp_iu6_i1_vld,
   input [1:`ITAG_SIZE_ENC-1]                rn_cp_iu6_i1_itag,
   input [62-`EFF_IFAR_WIDTH:61]             rn_cp_iu6_i1_ifar,
   input [0:31]                              rn_cp_iu6_i1_instr,
   input [0:2]                               rn_cp_iu6_i1_ucode,
   input                                     rn_cp_iu6_i1_fuse_nop,
   input [0:2]                               rn_cp_iu6_i1_error,
   input                                     rn_cp_iu6_i1_valop,
   input                                     rn_cp_iu6_i1_is_rfi,
   input                                     rn_cp_iu6_i1_is_rfgi,
   input                                     rn_cp_iu6_i1_is_rfci,
   input                                     rn_cp_iu6_i1_is_rfmci,
   input                                     rn_cp_iu6_i1_is_isync,
   input                                     rn_cp_iu6_i1_is_sc,
   input                                     rn_cp_iu6_i1_is_np1_flush,
   input                                     rn_cp_iu6_i1_is_sc_hyp,
   input                                     rn_cp_iu6_i1_is_sc_ill,
   input                                     rn_cp_iu6_i1_is_dcr_ill,
   input                                     rn_cp_iu6_i1_is_attn,
   input                                     rn_cp_iu6_i1_is_ehpriv,
   input                                     rn_cp_iu6_i1_is_folded,
   input                                     rn_cp_iu6_i1_async_block,
   input                                     rn_cp_iu6_i1_is_br,
   input                                     rn_cp_iu6_i1_br_add_chk,
   input                                     rn_cp_iu6_i1_pred,
   input                                     rn_cp_iu6_i1_rollover,
   input                                     rn_cp_iu6_i1_isram,
   input                                     rn_cp_iu6_i1_match,

   // Instruction Completed
   output                                    cp2_i0_completed,
   output                                    cp2_i1_completed,
   output [1:`ITAG_SIZE_ENC-1]               cp0_i0_completed_itag,
   output [1:`ITAG_SIZE_ENC-1]               cp0_i1_completed_itag,
   input [62-`EFF_IFAR_WIDTH:61]             cp2_i0_ifar,
   input [62-`EFF_IFAR_WIDTH:61]             cp2_i1_ifar,
   input [62-`EFF_IFAR_WIDTH:61]             cp2_i0_bp_bta,
   input [62-`EFF_IFAR_WIDTH:61]             cp2_i1_bp_bta,
   input                                     cp2_i0_rfi,
   input                                     cp2_i0_rfgi,
   input                                     cp2_i0_rfci,
   input                                     cp2_i0_rfmci,
   input                                     cp2_i0_sc,
   input                                     cp2_i0_mtiar,
   input                                     cp2_i0_rollover,
   input                                     cp2_i1_rfi,
   input                                     cp2_i1_rfgi,
   input                                     cp2_i1_rfci,
   input                                     cp2_i1_rfmci,
   input                                     cp2_i1_sc,
   input                                     cp2_i1_mtiar,
   input                                     cp2_i1_rollover,
   output                                    cp2_i0_bp_pred,
   output                                    cp2_i1_bp_pred,
   output                                    cp2_i0_br_pred,
   output                                    cp2_i1_br_pred,
   output [62-`EFF_IFAR_WIDTH:61]            cp2_i0_bta,
   output [62-`EFF_IFAR_WIDTH:61]            cp2_i1_bta,
   input                                     cp2_i0_isram,
   input                                     cp2_i1_isram,
   input                                     cp2_i0_ld,
   input                                     cp2_i1_ld,
   input                                     cp2_i0_st,
   input                                     cp2_i1_st,
   input                                     cp2_i0_epid,
   input                                     cp2_i1_epid,
   input [0:2]                               cp2_i0_ucode,
   input [0:2]                               cp2_i1_ucode,
   input                                     cp2_i0_type_fp,
   input                                     cp2_i1_type_fp,
   input                                     cp2_i0_type_ap,
   input                                     cp2_i1_type_ap,
   input                                     cp2_i0_type_spv,
   input                                     cp2_i1_type_spv,
   input                                     cp2_i0_type_st,
   input                                     cp2_i1_type_st,
   input                                     cp2_i0_attn,
   input                                     cp2_i1_attn,
   input                                     cp2_i0_fuse_nop,
   input                                     cp2_i1_fuse_nop,
   input                                     cp2_i0_icmp_block,
   input                                     cp2_i1_icmp_block,
   output                                    cp2_i0_axu_exception_val,
   output [0:3]                              cp2_i0_axu_exception,
   output                                    cp2_i1_axu_exception_val,
   output [0:3]                              cp2_i1_axu_exception,
   input                                     cp2_i0_nonspec,
   input                                     cp2_i1_nonspec,

   // LQ Instruction Executed
   input                                     lq0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                lq0_iu_itag,
   input                                     lq0_iu_n_flush,
   input                                     lq0_iu_np1_flush,
   input                                     lq0_iu_dacr_type,
   input [0:3]                               lq0_iu_dacrw,
   input [0:31]                              lq0_iu_instr,
   input [64-`GPR_WIDTH:63]                  lq0_iu_eff_addr,
   input                                     lq0_iu_exception_val,
   input [0:5]                               lq0_iu_exception,
   input                                     lq0_iu_flush2ucode,
   input                                     lq0_iu_flush2ucode_type,
   input                                     lq0_iu_recirc_val,
   input                                     lq0_iu_dear_val,

   input                                     lq1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                lq1_iu_itag,
   input                                     lq1_iu_n_flush,
   input                                     lq1_iu_np1_flush,
   input                                     lq1_iu_exception_val,
   input [0:5]                               lq1_iu_exception,
   input                                     lq1_iu_dacr_type,
   input [0:3]                               lq1_iu_dacrw,
   input [0:3]                               lq1_iu_perf_events,

   output                                    iu_lq_i0_completed,
   output [0:`ITAG_SIZE_ENC-1]               iu_lq_i0_completed_itag,
   output                                    iu_lq_i1_completed,
   output [0:`ITAG_SIZE_ENC-1]               iu_lq_i1_completed_itag,

   output                                    iu_lq_recirc_val,

   // BR Instruction Executed
   input                                     br_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                br_iu_itag,
   input                                     br_iu_redirect,
   input [62-`EFF_IFAR_ARCH:61]              br_iu_bta,
   input                                     br_iu_taken,
   input [0:3]                               br_iu_perf_events,

   // XU0 Instruction Executed
   input                                     xu_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                xu_iu_itag,
   input                                     xu_iu_n_flush,
   input                                     xu_iu_np1_flush,
   input                                     xu_iu_flush2ucode,
   input                                     xu_iu_exception_val,
   input [0:4]                               xu_iu_exception,
   input                                     xu_iu_mtiar,
   input [62-`EFF_IFAR_ARCH:61]              xu_iu_bta,
   input [62-`EFF_IFAR_ARCH:61]              xu_iu_rest_ifar,
   input [0:3]                               xu_iu_perf_events,

   // XU1 Instruction Executed
   input                                     xu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                xu1_iu_itag,

   // AXU0 Instruction Executed
   input                                     axu0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                axu0_iu_itag,
   input                                     axu0_iu_n_flush,
   input                                     axu0_iu_np1_flush,
   input                                     axu0_iu_n_np1_flush,
   input                                     axu0_iu_flush2ucode,
   input                                     axu0_iu_flush2ucode_type,
   input                                     axu0_iu_exception_val,
   input [0:3]                               axu0_iu_exception,
   input [0:3]                               axu0_iu_perf_events,

   // AXU0 Instruction Executed
   input                                     axu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]                axu1_iu_itag,
   input                                     axu1_iu_n_flush,
   input                                     axu1_iu_np1_flush,
   input                                     axu1_iu_n_np1_flush,
   input                                     axu1_iu_flush2ucode,
   input                                     axu1_iu_flush2ucode_type,
   input                                     axu1_iu_exception_val,
   input [0:3]                               axu1_iu_exception,
   input [0:3]                               axu1_iu_perf_events,

   // Signals to SPR partition
   output                                    iu_xu_rfi,
   output                                    iu_xu_rfgi,
   output                                    iu_xu_rfci,
   output                                    iu_xu_rfmci,
   output                                    iu_xu_int,
   output                                    iu_xu_gint,
   output                                    iu_xu_cint,
   output                                    iu_xu_mcint,
   output [62-`EFF_IFAR_ARCH:61]             iu_xu_nia,
   output [0:16]                             iu_xu_esr,
   output [0:14]                             iu_xu_mcsr,
   output [0:18]                             iu_xu_dbsr,
   output                                    iu_xu_dear_update,
   output [64-`GPR_WIDTH:63]                 iu_xu_dear,
   output                                    iu_xu_dbsr_update,
   output                                    iu_xu_dbsr_ude,
   output                                    iu_xu_dbsr_ide,
   output                                    iu_xu_esr_update,
   output                                    iu_xu_act,
   output                                    iu_xu_dbell_taken,
   output                                    iu_xu_cdbell_taken,
   output                                    iu_xu_gdbell_taken,
   output                                    iu_xu_gcdbell_taken,
   output                                    iu_xu_gmcdbell_taken,
   output                                    iu_xu_instr_cpl,
   input                                     xu_iu_np1_async_flush,
   output                                    iu_xu_async_complete,
   input                                     dp_cp_hold_req,
   output                                    iu_mm_hold_ack,
   input                                     dp_cp_bus_snoop_hold_req,
   output                                    iu_mm_bus_snoop_hold_ack,
   output                                    iu_spr_eheir_update,
   output [0:31]                             iu_spr_eheir,
   input                                     xu_iu_msr_de,
   input                                     xu_iu_msr_pr,
   input                                     xu_iu_msr_cm,
   input                                     xu_iu_msr_gs,
   input                                     xu_iu_msr_me,
   input                                     xu_iu_dbcr0_edm,
   input                                     xu_iu_dbcr0_idm,
   input                                     xu_iu_dbcr0_icmp,
   input                                     xu_iu_dbcr0_brt,
   input                                     xu_iu_dbcr0_irpt,
   input                                     xu_iu_dbcr0_trap,
   input                                     xu_iu_iac1_en,
   input                                     xu_iu_iac2_en,
   input                                     xu_iu_iac3_en,
   input                                     xu_iu_iac4_en,
   input [0:1]                               xu_iu_dbcr0_dac1,
   input [0:1]                               xu_iu_dbcr0_dac2,
   input [0:1]                               xu_iu_dbcr0_dac3,
   input [0:1]                               xu_iu_dbcr0_dac4,
   input                                     xu_iu_dbcr0_ret,
   input                                     xu_iu_dbcr1_iac12m,
   input                                     xu_iu_dbcr1_iac34m,
   input                                     lq_iu_spr_dbcr3_ivc,
   input                                     xu_iu_epcr_extgs,
   input                                     xu_iu_epcr_dtlbgs,
   input                                     xu_iu_epcr_itlbgs,
   input                                     xu_iu_epcr_dsigs,
   input                                     xu_iu_epcr_isigs,
   input                                     xu_iu_epcr_duvd,
   input                                     xu_iu_epcr_icm,
   input                                     xu_iu_epcr_gicm,
   input                                     xu_iu_ccr2_ucode_dis,
   input                                     xu_iu_hid_mmu_mode,
   input                                     xu_iu_xucr4_mmu_mchk,

   // Interrupts
	input                                     an_ac_uncond_dbg_event,
   input                                     xu_iu_external_mchk,
   input                                     xu_iu_ext_interrupt,
   input                                     xu_iu_dec_interrupt,
   input                                     xu_iu_udec_interrupt,
   input                                     xu_iu_perf_interrupt,
   input                                     xu_iu_fit_interrupt,
   input                                     xu_iu_crit_interrupt,
   input                                     xu_iu_wdog_interrupt,
   input                                     xu_iu_gwdog_interrupt,
   input                                     xu_iu_gfit_interrupt,
   input                                     xu_iu_gdec_interrupt,
   input                                     xu_iu_dbell_interrupt,
   input                                     xu_iu_cdbell_interrupt,
   input                                     xu_iu_gdbell_interrupt,
   input                                     xu_iu_gcdbell_interrupt,
   input                                     xu_iu_gmcdbell_interrupt,
   input                                     xu_iu_dbsr_ide,
   input                                     axu0_iu_async_fex,

   // Flushes
   output                                    iu_flush,
   output                                    cp_flush_into_uc,
   output [43:61]                            cp_uc_flush_ifar,
   output                                    cp_uc_np1_flush,
   output                                    cp_flush,
   output [0:`ITAG_SIZE_ENC-1]               cp_next_itag,
   output [0:`ITAG_SIZE_ENC-1]               cp_flush_itag,
   output [62-`EFF_IFAR_ARCH:61]             cp_flush_ifar,
   output                                    cp_iu0_flush_2ucode,
   output                                    cp_iu0_flush_2ucode_type,
   output                                    cp_iu0_flush_nonspec,
   input                                     pc_iu_init_reset,

   // SPRs
   input                                     xu_iu_single_instr_mode,
   input                                     spr_single_issue,
   input [64-`GPR_WIDTH:51]                  spr_ivpr,
   input [64-`GPR_WIDTH:51]                  spr_givpr,
   input [62-`EFF_IFAR_ARCH:61]              spr_iac1,
   input [62-`EFF_IFAR_ARCH:61]              spr_iac2,
   input [62-`EFF_IFAR_ARCH:61]              spr_iac3,
   input [62-`EFF_IFAR_ARCH:61]              spr_iac4,

   // Signals from pervasive
   input                                     pc_iu_ram_active,
   input                                     pc_iu_ram_flush_thread,
   input                                     xu_iu_msrovride_enab,
   output                                    iu_pc_ram_done,
   output                                    iu_pc_ram_interrupt,
   output                                    iu_pc_ram_unsupported,
   input                                     pc_iu_stop,
   input                                     pc_iu_step,
   input [0:2]                               pc_iu_dbg_action,
   output                                    iu_pc_step_done,
   output [0:`THREADS-1]                     iu_pc_stop_dbg_event,
   output                                    iu_pc_err_debug_event,
   output                                    iu_pc_attention_instr,
   output                                    iu_pc_err_mchk_disabled,
   output                                    ac_an_debug_trigger,
   output                                    iu_xu_stop,
   output                                    iu_xu_quiesce,

   // MMU Errors
   input                                     mm_iu_ierat_rel_val,
   input                                     mm_iu_ierat_pt_fault,
   input                                     mm_iu_ierat_lrat_miss,
   input                                     mm_iu_ierat_tlb_inelig,
   input                                     mm_iu_tlb_multihit_err,
   input                                     mm_iu_tlb_par_err,
   input                                     mm_iu_lru_par_err,
   input                                     mm_iu_tlb_miss,
   input                                     mm_iu_reload_hit,
   input                                     ic_cp_nonspec_hit,

   output [0:5]                              cp_mm_except_taken,

   // completion empty
   output                                    cp_rn_empty,
   output                                    cp_async_block,

   // Power
   inout                                     vdd,
   inout                                     gnd);

   // Latches
   wire [1:`ITAG_SIZE_ENC-1]                 iu6_i0_itag_q;
   wire [1:`ITAG_SIZE_ENC-1]                 iu6_i1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp1_i0_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp0_i0_itag;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_ptr_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_i0_ptr;
   wire [0:`ITAG_SIZE_ENC-1]                 cp1_i1_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp0_i1_itag;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i1_ptr_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_i1_ptr;
   wire [0:`ITAG_SIZE_ENC-1]                 cp2_i0_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp2_i1_itag_q;
   wire                                      cp2_async_int_val_q;
   wire                                      cp1_async_int_val;
   wire [0:31]                               cp2_async_int_q;
   wire [0:31]                               cp1_async_int;
   wire                                      cp2_i0_complete_q;
   wire                                      cp1_i0_complete;
   wire                                      cp2_i1_complete_q;
   wire                                      cp1_i1_complete;
   wire                                      cp2_i0_np1_flush_q;
   wire                                      cp1_i0_np1_flush;
   wire                                      cp2_i1_np1_flush_q;
   wire                                      cp1_i1_np1_flush;
   wire                                      cp2_i0_n_np1_flush_q;
   wire                                      cp1_i0_n_np1_flush;
   wire                                      cp2_i1_n_np1_flush_q;
   wire                                      cp1_i1_n_np1_flush;
   wire                                      cp2_i0_bp_pred_q;
   wire                                      cp1_i0_bp_pred;
   wire                                      cp2_i1_bp_pred_q;
   wire                                      cp1_i1_bp_pred;
   wire                                      cp2_i0_br_pred_q;
   wire                                      cp1_i0_br_pred;
   wire                                      cp2_i1_br_pred_q;
   wire                                      cp1_i1_br_pred;
   wire                                      cp2_i0_br_miss_q;
   wire                                      cp1_i0_br_miss;
   wire                                      cp2_i1_br_miss_q;
   wire                                      cp1_i1_br_miss;
   wire                                      cp2_i0_flush2ucode_q;
   wire                                      cp1_i0_flush2ucode;
   wire                                      cp2_i0_flush2ucode_type_q;
   wire                                      cp1_i0_flush2ucode_type;
   wire                                      cp2_i1_flush2ucode_q;
   wire                                      cp1_i1_flush2ucode;
   wire                                      cp2_i1_flush2ucode_type_q;
   wire                                      cp1_i1_flush2ucode_type;
   wire [62-`EFF_IFAR_ARCH:61]               cp2_i_bta_q;
   wire [62-`EFF_IFAR_ARCH:61]               cp1_i_bta;
   wire                                      cp2_i0_iu_excvec_val_q;
   wire                                      cp1_i0_iu_excvec_val;
   wire [0:3]                                cp2_i0_iu_excvec_q;
   reg [0:3]                                 cp1_i0_iu_excvec;
   wire                                      cp2_i1_iu_excvec_val_q;
   wire                                      cp1_i1_iu_excvec_val;
   wire [0:3]                                cp2_i1_iu_excvec_q;
   reg [0:3]                                 cp1_i1_iu_excvec;
   wire                                      cp2_i0_lq_excvec_val_q;
   wire                                      cp1_i0_lq_excvec_val;
   wire [0:5]                                cp2_i0_lq_excvec_q;
   reg [0:5]                                 cp1_i0_lq_excvec;
   wire                                      cp2_i1_lq_excvec_val_q;
   wire                                      cp1_i1_lq_excvec_val;
   wire [0:5]                                cp2_i1_lq_excvec_q;
   reg [0:5]                                 cp1_i1_lq_excvec;
   wire                                      cp2_i0_xu_excvec_val_q;
   wire                                      cp1_i0_xu_excvec_val;
   wire [0:4]                                cp2_i0_xu_excvec_q;
   reg [0:4]                                 cp1_i0_xu_excvec;
   wire                                      cp2_i1_xu_excvec_val_q;
   wire                                      cp1_i1_xu_excvec_val;
   wire [0:4]                                cp2_i1_xu_excvec_q;
   reg [0:4]                                 cp1_i1_xu_excvec;
   wire                                      cp2_i0_axu_excvec_val_q;
   wire                                      cp1_i0_axu_excvec_val;
   wire [0:3]                                cp2_i0_axu_excvec_q;
   reg [0:3]                                 cp1_i0_axu_excvec;
   wire                                      cp2_i1_axu_excvec_val_q;
   wire                                      cp1_i1_axu_excvec_val;
   wire [0:3]                                cp2_i1_axu_excvec_q;
   reg [0:3]                                 cp1_i1_axu_excvec;
   wire                                      cp2_i0_db_val_q;
   wire                                      cp1_i0_db_val;
   wire [0:18]                               cp2_i0_db_events_q;
   reg [0:18]                                cp1_i0_db_events;
   wire                                      cp2_i1_db_val_q;
   wire                                      cp1_i1_db_val;
   wire [0:18]                               cp2_i1_db_events_q;
   reg [0:18]                                cp1_i1_db_events;
   wire [0:3]                                cp2_i0_perf_events_q;
   reg [0:3]                                 cp1_i0_perf_events;
   wire [0:3]                                cp2_i1_perf_events_q;
   reg [0:3]                                 cp1_i1_perf_events;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_executed_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_executed;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_dispatched_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_dispatched;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_n_flush_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_n_flush;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_np1_flush_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_np1_flush;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_n_np1_flush_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_n_np1_flush;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_flush2ucode_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_flush2ucode;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_flush2ucode_type_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_flush2ucode_type;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_recirc_vld_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_recirc_vld;
   wire [0:3]                                cp1_perf_events_q[0:`CPL_Q_DEPTH-1];
   wire [0:3]                                cp0_perf_events[0:`CPL_Q_DEPTH-1];
   wire [0:`CPL_Q_DEPTH-1]                   cp1_iu_excvec_val_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_iu_excvec_val;
   wire [0:3]                                cp1_iu_excvec_q[0:`CPL_Q_DEPTH-1];
   wire [0:3]                                cp0_iu_excvec[0:`CPL_Q_DEPTH-1];
   wire [0:`CPL_Q_DEPTH-1]                   cp1_lq_excvec_val_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_lq_excvec_val;
   wire [0:5]                                cp1_lq_excvec_q[0:`CPL_Q_DEPTH-1];
   wire [0:5]                                cp0_lq_excvec[0:`CPL_Q_DEPTH-1];
   wire [0:`CPL_Q_DEPTH-1]                   cp1_xu_excvec_val_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_xu_excvec_val;
   wire [0:4]                                cp1_xu_excvec_q[0:`CPL_Q_DEPTH-1];
   wire [0:4]                                cp0_xu_excvec[0:`CPL_Q_DEPTH-1];
   wire [0:`CPL_Q_DEPTH-1]                   cp1_axu_excvec_val_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_axu_excvec_val;
   wire [0:3]                                cp1_axu_excvec_q[0:`CPL_Q_DEPTH-1];
   wire [0:3]                                cp0_axu_excvec[0:`CPL_Q_DEPTH-1];
   wire [0:18]                               cp1_db_events_q[0:`CPL_Q_DEPTH-1];
   wire [0:18]                               cp0_db_events[0:`CPL_Q_DEPTH-1];
   wire [0:`CPL_Q_DEPTH-1]                   cp1_db_IAC_IVC_event;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_async_block_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_async_block;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_is_br_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_is_br;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_br_add_chk_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_br_add_chk;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_bp_pred_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_bp_pred;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_br_pred_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_br_pred;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_br_miss_q;
   wire [0:`CPL_Q_DEPTH-1]                   cp0_br_miss;
   wire                                      cp0_br_bta_act;
   wire [62-`EFF_IFAR_ARCH:61]               cp1_br_bta_q;
   wire [62-`EFF_IFAR_ARCH:61]               cp0_br_bta;
   reg  [62-`EFF_IFAR_ARCH:61]               cp0_br_bta_tmp;
   wire                                      cp1_br_bta_v_q;
   reg                                       cp0_br_bta_v;
   wire [0:`ITAG_SIZE_ENC-1]                 cp1_br_bta_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp0_br_bta_itag;
   reg  [0:`ITAG_SIZE_ENC-1]                 cp0_br_bta_itag_tmp;
   wire                                      iu6_i0_dispatched_d;	// rn_cp_iu6_i0_vld
   wire                                      iu6_i1_dispatched_d;	// rn_cp_iu6_i1_vld
   wire                                      iu6_i0_dispatched_q;	// rn_cp_iu6_i0_vld
   wire                                      iu6_i1_dispatched_q;	// rn_cp_iu6_i1_vld
   wire [62-`EFF_IFAR_WIDTH:61]              iu6_i0_ifar_q;		// rn_cp_iu6_i0_ifar
   wire [0:2]                                iu6_i0_ucode_q;		// rn_cp_iu6_i0_ucode
   wire                                      iu6_i0_fuse_nop_q;   // rn_cp_iu6_i0_fuse_nop
   wire [0:2]                                iu6_i0_error_q;		// rn_cp_iu6_i0_error
   wire                                      iu6_i0_valop_q;		// rn_cp_iu6_i0_valop
   wire                                      iu6_i0_is_rfi_q;		// rn_cp_iu6_i0_is_rfi
   wire                                      iu6_i0_is_rfgi_q;		// rn_cp_iu6_i0_is_rfgi
   wire                                      iu6_i0_is_rfci_q;		// rn_cp_iu6_i0_is_rfci
   wire                                      iu6_i0_is_rfmci_q;		// rn_cp_iu6_i0_is_rfmci
   wire                                      iu6_i0_is_isync_q;		// rn_cp_iu6_i0_is_isync
   wire                                      iu6_i0_is_sc_q;		// rn_cp_iu6_i0_is_sc
   wire                                      iu6_i0_is_np1_flush_q;	// rn_cp_iu6_i0_is_np1_flush
   wire                                      iu6_i0_is_sc_hyp_q;	// rn_cp_iu6_i0_is_sc_hyp
   wire                                      iu6_i0_is_sc_ill_q;	// rn_cp_iu6_i0_is_sc_ill
   wire                                      iu6_i0_is_dcr_ill_q;	// rn_cp_iu6_i0_is_dcr_ill
   wire                                      iu6_i0_is_attn_q;		// rn_cp_iu6_i0_is_attn
   wire                                      iu6_i0_is_ehpriv_q;	// rn_cp_iu6_i0_is_ehpriv
   wire                                      iu6_i0_is_folded_q;	// rn_cp_iu6_i0_is_folded
   wire                                      iu6_i0_async_block_q;	// rn_cp_iu6_i0_async_block
   wire                                      iu6_i0_is_br_q;		// rn_cp_iu6_i0_is_br
   wire                                      iu6_i0_br_add_chk_q;	// rn_cp_iu6_i0_br_add_chk
   wire                                      iu6_i0_bp_pred_q;		// rn_cp_iu6_i0_pred
   wire                                      iu6_i0_rollover_q;		// rn_cp_iu6_i0_rollover
   wire                                      iu6_i0_isram_q;		// rn_cp_iu6_i0_isram
   wire                                      iu6_i0_match_q;		// rn_cp_iu6_i0_match
   wire [62-`EFF_IFAR_WIDTH:61]              iu6_i1_ifar_q;		// rn_cp_iu6_i1_ifar
   wire [0:2]                                iu6_i1_ucode_q;		// rn_cp_iu6_i1_ucode
   wire                                      iu6_i1_fuse_nop_q;   // rn_cp_iu6_i1_fuse_nop
   wire [0:2]                                iu6_i1_error_q;		// rn_cp_iu6_i1_error
   wire                                      iu6_i1_valop_q;		// rn_cp_iu6_i1_valop
   wire                                      iu6_i1_is_rfi_q;		// rn_cp_iu6_i1_is_rfi
   wire                                      iu6_i1_is_rfgi_q;		// rn_cp_iu6_i1_is_rfgi
   wire                                      iu6_i1_is_rfci_q;		// rn_cp_iu6_i1_is_rfci
   wire                                      iu6_i1_is_rfmci_q;		// rn_cp_iu6_i1_is_rfmci
   wire                                      iu6_i1_is_isync_q;		// rn_cp_iu6_i1_is_isync
   wire                                      iu6_i1_is_sc_q;		// rn_cp_iu6_i1_is_sc
   wire                                      iu6_i1_is_np1_flush_q;	// rn_cp_iu6_i1_is_np1_flush
   wire                                      iu6_i1_is_sc_hyp_q;	// rn_cp_iu6_i1_is_sc_hyp
   wire                                      iu6_i1_is_sc_ill_q;	// rn_cp_iu6_i1_is_sc_ill
   wire                                      iu6_i1_is_dcr_ill_q;	// rn_cp_iu6_i1_is_dcr_ill
   wire                                      iu6_i1_is_attn_q;		// rn_cp_iu6_i1_is_attn
   wire                                      iu6_i1_is_ehpriv_q;	// rn_cp_iu6_i1_is_ehpriv
   wire                                      iu6_i1_is_folded_q;	// rn_cp_iu6_i1_is_folded
   wire                                      iu6_i1_async_block_q;	// rn_cp_iu6_i1_async_block
   wire                                      iu6_i1_is_br_q;		// rn_cp_iu6_i1_is_br
   wire                                      iu6_i1_br_add_chk_q;	// rn_cp_iu6_i1_br_add_chk
   wire                                      iu6_i1_bp_pred_q;		// rn_cp_iu6_i1_pred
   wire                                      iu6_i1_rollover_q;		// rn_cp_iu6_i1_rollover
   wire                                      iu6_i1_isram_q;		// rn_cp_iu6_i1_isram
   wire                                      iu6_i1_match_q;		// rn_cp_iu6_i1_match
   wire                                      iu6_uc_hold_rollover_q;
   wire                                      iu6_uc_hold_rollover_d;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_dispatched_delay_q;		// Added these to delay checking for completion due to completion array write for I1
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_dispatched_delay_d;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i1_dispatched_delay_q;		// Added these to delay checking for completion due to completion array write for I1
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i1_dispatched_delay_d;
   wire                                      iu7_i0_is_folded_q;		// Added these to delay checking for completion due to completion array write for I1
   wire                                      iu7_i0_is_folded_d;
   wire                                      iu7_i1_is_folded_q;		// Added these to delay checking for completion due to completion array write for I1
   wire                                      iu7_i1_is_folded_d;
   wire                                      lq0_execute_vld_d;		// lq0_iu_execute_vld
   wire                                      lq0_execute_vld_q;		// lq0_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 lq0_itag_q;		// lq0_iu_itag
   wire                                      lq0_n_flush_q;		// lq0_iu_n_flush
   wire                                      lq0_np1_flush_q;		// lq0_iu_np1_flush
   wire                                      lq0_dacr_type_q;		// lq0_iu_dacr_type
   wire [0:3]                                lq0_dacrw_q;		// lq0_iu_dacrw
   wire [0:31]                               lq0_instr_q;		// lq0_iu_instr
   wire [64-`GPR_WIDTH:63]                   lq0_eff_addr_q;		// lq0_iu_eff_addr
   wire                                      lq0_exception_val_d;
   wire                                      lq0_exception_val_q;       // lq0_iu_exception_val
   wire [0:5]                                lq0_exception_q;		// lq0_iu_exception
   wire                                      lq0_flush2ucode_q;		// lq0_iu_flush2ucode
   wire                                      lq0_flush2ucode_type_q;		// lq0_iu_flush2ucode_type
   wire                                      lq0_recirc_val_q;		// lq0_iu_recirc_val
   wire                                      lq1_execute_vld_d;		// lq1_iu_execute_vld
   wire                                      lq1_execute_vld_q;		// lq1_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 lq1_itag_q;		// lq1_iu_itag
   wire                                      lq1_n_flush_q;		// lq1_iu_n_flush
   wire                                      lq1_np1_flush_q;		// lq1_iu_np1_flush
   wire                                      lq1_exception_val_q;		// lq1_iu_exception_val
   wire [0:5]                                lq1_exception_q;		// lq1_iu_exception
   wire                                      lq1_dacr_type_q;
   wire [0:3]                                lq1_dacrw_q;
   wire [0:3]                                lq1_perf_events_q;
   wire                                      br_execute_vld_d;		// br_iu_execute_vld
   wire                                      br_execute_vld_q;		// br_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 br_itag_q;		// br_iu_itag
   wire                                      br_taken_q;		// br_iu_taken
   wire                                      br_redirect_q;		// br_iu_redirect
   wire [62-`EFF_IFAR_ARCH:61]               br_bta_q;		// br_iu_bta
   wire [62-`EFF_IFAR_ARCH:61]               br_bta_d;
   wire [0:3]                                br_perf_events_q;
   wire                                      xu_execute_vld_d;		// xu_iu_execute_vld
   wire                                      xu_execute_vld_q;		// xu_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 xu_itag_q;		// xu_iu_itag
   wire                                      xu_n_flush_q;		// xu_iu_n_flush
   wire                                      xu_np1_flush_q;		// xu_iu_np1_flush
   wire                                      xu_flush2ucode_q;		// xu_iu_flush2ucode
   wire                                      xu_exception_val_q;		// xu_iu_exception_val
   wire                                      xu_exception_val_d;
   wire [0:4]                                xu_exception_q;		// xu_iu_exception
   wire                                      xu_mtiar_q;		// xu_iu_mtiar
   wire [62-`EFF_IFAR_ARCH:61]               xu_bta_q;		// xu_iu_bta
   wire [0:3]                                xu_perf_events_q;
   wire                                      xu1_execute_vld_d;		// xu1_iu_execute_vld
   wire                                      xu1_execute_vld_q;		// xu1_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 xu1_itag_q;		// xu1_iu_itag
   wire                                      axu0_execute_vld_d;		// axu0_iu_execute_vld
   wire                                      axu0_execute_vld_q;		// axu0_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 axu0_itag_q;		// axu0_iu_itag
   wire                                      axu0_n_flush_q;		// axu0_iu_n_flush
   wire                                      axu0_np1_flush_q;		// axu0_iu_np1_flush
   wire                                      axu0_n_np1_flush_q;		// axu0_iu_n_np1_flush
   wire                                      axu0_flush2ucode_q;		// axu0_iu_flush2ucode
   wire                                      axu0_flush2ucode_type_q;		// axu0_iu_flush2ucode_type
   wire                                      axu0_exception_val_q;		// axu0_iu_exception_val
   wire [0:3]                                axu0_exception_q;		// axu0_iu_exception
   wire [0:3]                                axu0_perf_events_q;
   wire                                      axu1_execute_vld_d;		// axu1_iu_execute_vld
   wire                                      axu1_execute_vld_q;		// axu1_iu_execute_vld
   wire [0:`ITAG_SIZE_ENC-1]                 axu1_itag_q;		// axu1_iu_itag
   wire                                      axu1_n_flush_q;		// axu1_iu_n_flush
   wire                                      axu1_np1_flush_q;		// axu1_iu_np1_flush
   wire                                      axu1_n_np1_flush_q;		// axu1_iu_n_np1_flush
   wire                                      axu1_flush2ucode_q;		// axu1_iu_flush2ucode
   wire                                      axu1_flush2ucode_type_q;		// axu1_iu_flush2ucode_type
   wire                                      axu1_exception_val_q;		// axu1_iu_exception_val
   wire [0:3]                                axu1_exception_q;		// axu1_iu_exception
   wire [0:3]                                axu1_perf_events_q;
   wire                                      iu_xu_cp3_rfi_q;
   wire                                      iu_xu_cp2_rfi_d;
   wire                                      iu_xu_cp3_rfgi_q;
   wire                                      iu_xu_cp2_rfgi_d;
   wire                                      iu_xu_cp3_rfci_q;
   wire                                      iu_xu_cp2_rfci_d;
   wire                                      iu_xu_cp3_rfmci_q;
   wire                                      iu_xu_cp2_rfmci_d;
   wire                                      iu_xu_cp4_rfi_q;
   wire                                      iu_xu_cp4_rfgi_q;
   wire                                      iu_xu_cp4_rfci_q;
   wire                                      iu_xu_cp4_rfmci_q;
   wire                                      cp3_ld_save_q;
   wire                                      cp3_ld_save_d;
   wire                                      cp3_st_save_q;
   wire                                      cp3_st_save_d;
   wire                                      cp3_fp_save_q;
   wire                                      cp3_fp_save_d;
   wire                                      cp3_ap_save_q;
   wire                                      cp3_ap_save_d;
   wire                                      cp3_spv_save_q;
   wire                                      cp3_spv_save_d;
   wire                                      cp3_epid_save_q;
   wire                                      cp3_epid_save_d;
   wire                                      cp3_async_hold_q;
   wire                                      cp3_async_hold_d;
   wire                                      cp2_async_hold;
   wire                                      cp2_flush_q;
   wire                                      cp1_flush;
   wire                                      cp3_flush_q;		// cp3_flush_q
   wire                                      cp3_flush_d;
   wire                                      cp4_flush_q;		// cp4_flush_q used to gate off incoming executes
   wire                                      cp3_rfi_q;		// cp3_rfi_q
   wire                                      cp2_rfi;
   wire                                      cp3_attn_q;		// cp3_attn_q
   wire                                      cp2_attn;
   wire                                      cp3_sc_q;		// cp3_sc_q
   wire                                      cp2_sc;
   wire                                      cp3_icmp_block_q;		// cp2_icmp_block
   wire                                      cp2_icmp_block;
   wire                                      cp3_async_int_val_q;
   wire [0:31]                               cp3_async_int_q;
   wire                                      cp3_iu_excvec_val_q;
   wire                                      cp2_iu_excvec_val;
   wire [0:3]                                cp3_iu_excvec_q;
   wire [0:3]                                cp2_iu_excvec;
   wire                                      cp3_lq_excvec_val_q;
   wire                                      cp2_lq_excvec_val;
   wire [0:5]                                cp3_lq_excvec_q;
   wire [0:5]                                cp2_lq_excvec;
   wire                                      cp3_xu_excvec_val_q;
   wire                                      cp2_xu_excvec_val;
   wire [0:4]                                cp3_xu_excvec_q;
   wire [0:4]                                cp2_xu_excvec;
   wire                                      cp3_axu_excvec_val_q;
   wire                                      cp2_axu_excvec_val;
   wire [0:3]                                cp3_axu_excvec_q;
   wire [0:3]                                cp2_axu_excvec;
   wire                                      cp3_db_val_q;
   wire                                      cp2_db_val;
   wire [0:18]                               cp3_db_events_q;
   wire [0:18]                               cp2_db_events;
   wire                                      cp3_ld_q;
   wire                                      cp2_ld;
   wire                                      cp3_st_q;
   wire                                      cp2_st;
   wire                                      cp3_fp_q;
   wire                                      cp2_fp;
   wire                                      cp3_ap_q;
   wire                                      cp2_ap;
   wire                                      cp3_spv_q;
   wire                                      cp2_spv;
   wire                                      cp3_epid_q;
   wire                                      cp2_epid;
   wire [43:61]                              cp3_ifar_q;
   wire [43:61]                              cp2_ifar;
   wire                                      cp3_np1_flush_q;
   wire                                      cp2_np1_flush;
   wire                                      cp3_ucode_q;
   wire                                      cp3_preissue_q;
   wire                                      cp2_ucode;
   wire                                      cp2_preissue;
   wire                                      cp3_nia_act;
   wire [62-`EFF_IFAR_ARCH:61]               cp3_nia_q;
   wire [62-`EFF_IFAR_ARCH:61]               cp2_nia;
   wire [62-`EFF_IFAR_ARCH:61]               nia_mask;
   wire                                      cp3_flush2ucode_q;
   wire                                      cp2_flush2ucode;
   wire                                      cp3_flush2ucode_type_q;
   wire                                      cp2_flush2ucode_type;
   wire                                      cp3_flush_nonspec_q;
   wire                                      cp2_flush_nonspec;
   wire                                      cp3_mispredict_q;
   wire                                      cp2_mispredict;
   wire                                      cp4_rfi_q;
   wire                                      cp3_rfi;
   wire                                      cp5_rfi_q;
   wire                                      cp6_rfi_q;
   wire                                      cp7_rfi_q;
   wire                                      cp8_rfi_q;
   wire                                      cp4_excvec_val_q;
   wire                                      cp4_excvec_val;
   wire                                      cp3_excvec_val;
   wire                                      cp4_dp_cp_async_flush_q;
   wire                                      cp3_dp_cp_async_flush;
   wire                                      cp4_dp_cp_async_bus_snoop_flush_q;
   wire                                      cp3_dp_cp_async_bus_snoop_flush;
   wire                                      cp4_async_np1_q;
   wire                                      cp3_async_np1;
   wire                                      cp3_async_n;
   wire                                      cp4_async_n_q;
   wire                                      cp3_mm_iu_exception;
   wire                                      cp4_pc_stop_q;
   wire                                      cp3_pc_stop;
   wire                                      pc_stop_hold_q;
   wire                                      pc_stop_hold_d;
   wire                                      cp4_mc_int_q;
   wire                                      cp3_mc_int;
   wire                                      cp4_g_int_q;
   wire                                      cp3_g_int;
   wire                                      cp4_c_int_q;
   wire                                      cp3_c_int;
   wire                                      cp4_dbell_int_q;
   wire                                      cp3_dbell_int;
   wire                                      cp4_cdbell_int_q;
   wire                                      cp3_cdbell_int;
   wire                                      cp4_gdbell_int_q;
   wire                                      cp3_gdbell_int;
   wire                                      cp4_gcdbell_int_q;
   wire                                      cp3_gcdbell_int;
   wire                                      cp4_gmcdbell_int_q;
   wire                                      cp3_gmcdbell_int;
   wire                                      cp4_dbsr_update_q;
   wire                                      cp3_dbsr_update;
   wire                                      cp4_eheir_update_q;
   wire                                      cp3_eheir_update;
   wire [0:18]                               cp4_dbsr_q;
   wire [0:18]                               cp3_dbsr;
   wire                                      cp4_esr_update_q;
   wire                                      cp3_esr_update;
   wire [0:16]                               cp4_exc_esr_q;
   wire [0:16]                               cp3_exc_esr;
   wire [0:14]                               cp4_exc_mcsr_q;
   wire [0:14]                               cp3_exc_mcsr;
   wire                                      cp4_asyn_irpt_needed_q;
   wire                                      cp4_asyn_irpt_needed_d;
   wire                                      cp4_asyn_icmp_needed_q;
   wire                                      cp4_asyn_icmp_needed_d;
   wire [62-`EFF_IFAR_ARCH:61]               cp4_exc_nia_q;
   wire [62-`EFF_IFAR_ARCH:61]               cp3_exc_nia;
   wire                                      cp4_mchk_disabled_q;
   wire                                      cp3_mchk_disabled;
   wire                                      cp4_dear_update_q;
   wire                                      cp3_dear_update;
   wire [0:1]                                flush_hold_q;
   wire [0:1]                                flush_hold_d;
   wire                                      flush_hold;
   wire                                      pc_iu_init_reset_q;
   wire                                      dp_cp_async_flush_q;
   wire                                      dp_cp_async_flush_d;
   wire                                      dp_cp_async_bus_snoop_flush_q;
   wire                                      dp_cp_async_bus_snoop_flush_d;
   wire                                      np1_async_flush_q;
   wire                                      np1_async_flush_d;
   wire                                      msr_de_q;
   wire                                      msr_pr_q;
   wire                                      msr_cm_q;
   wire                                      msr_cm_noact_q;
   wire                                      msr_gs_q;
   wire                                      msr_me_q;
   wire                                      dbcr0_edm_q;
   wire                                      dbcr0_idm_q;
   wire                                      dbcr0_icmp_q;
   wire                                      dbcr0_brt_q;
   wire                                      dbcr0_irpt_q;
   wire                                      dbcr0_trap_q;
   wire                                      iac1_en_q;
   wire                                      iac2_en_q;
   wire                                      iac3_en_q;
   wire                                      iac4_en_q;
   wire [0:1]                                dbcr0_dac1_q;
   wire [0:1]                                dbcr0_dac2_q;
   wire [0:1]                                dbcr0_dac3_q;
   wire [0:1]                                dbcr0_dac4_q;
   wire                                      dbcr0_ret_q;
   wire                                      dbcr1_iac12m_q;
   wire                                      dbcr1_iac34m_q;
   wire                                      dbcr3_ivc_q;
   wire                                      epcr_extgs_q;
   wire                                      epcr_dtlbgs_q;
   wire                                      epcr_itlbgs_q;
   wire                                      epcr_dsigs_q;
   wire                                      epcr_isigs_q;
   wire                                      epcr_duvd_q;
   wire                                      epcr_icm_q;
   wire                                      epcr_gicm_q;
   wire                                      ccr2_ucode_dis_q;
   wire                                      ccr2_mmu_mode_q;
   wire                                      xu_iu_xucr4_mmu_mchk_q;
   wire                                      pc_iu_ram_active_q;
   wire                                      pc_iu_ram_flush_thread_q;
   wire                                      xu_iu_msrovride_enab_q;
   wire                                      pc_iu_stop_q;
   wire                                      pc_iu_step_q;
   wire [0:15]                               spr_perf_mux_ctrls_q;
   wire [0:2]                                pc_iu_dbg_action_q;
   wire                                      xu_iu_single_instr_q;
   wire                                      spr_single_issue_q;
   wire [64-`GPR_WIDTH:51]                   spr_ivpr_q;
   wire [64-`GPR_WIDTH:51]                   spr_givpr_q;
   wire [62-`EFF_IFAR_ARCH:61]               spr_iac1_q;
   wire [62-`EFF_IFAR_ARCH:61]               spr_iac2_q;
   wire [62-`EFF_IFAR_ARCH:61]               spr_iac3_q;
   wire [62-`EFF_IFAR_ARCH:61]               spr_iac4_q;
   wire                                      iu_pc_step_done_q;
   wire                                      iu_pc_step_done_d;
   wire                                      uncond_dbg_event_q;
   wire                                      external_mchk_q;
   wire                                      ext_interrupt_q;
   wire                                      dec_interrupt_q;
   wire                                      udec_interrupt_q;
   wire                                      perf_interrupt_q;
   wire                                      fit_interrupt_q;
   wire                                      crit_interrupt_q;
   wire                                      wdog_interrupt_q;
   wire                                      gwdog_interrupt_q;
   wire                                      gfit_interrupt_q;
   wire                                      gdec_interrupt_q;
   wire                                      dbell_interrupt_q;
   wire                                      cdbell_interrupt_q;
   wire                                      gdbell_interrupt_q;
   wire                                      gcdbell_interrupt_q;
   wire                                      gmcdbell_interrupt_q;
   wire                                      dbsr_interrupt_q;
   wire                                      fex_interrupt_q;
   wire [0:2]                                async_delay_cnt_q;
   wire [0:2]                                async_delay_cnt_d;
   wire                                      iu_lq_recirc_val_q;
   wire                                      iu_lq_recirc_val_d;
   wire [0:`ITAG_SIZE_ENC-1]                 cp_next_itag_q;
   wire [0:`ITAG_SIZE_ENC-1]                 cp_next_itag_d;
   wire [62-`EFF_IFAR_ARCH:61]               xu_iu_rest_ifar_q;
   wire                                      attn_hold_q;
   wire                                      attn_hold_d;
   wire [0:1]                                flush_delay_q;
   wire [0:1]                                flush_delay_d;
   wire                                      iu_nonspec_q;
   wire                                      iu_nonspec_d;
   wire                                      nonspec_release;
   wire                                      ierat_pt_fault_q;
   wire                                      ierat_pt_fault_d;
   wire                                      ierat_lrat_miss_q;
   wire                                      ierat_lrat_miss_d;
   wire                                      ierat_tlb_inelig_q;
   wire                                      ierat_tlb_inelig_d;
   wire                                      tlb_multihit_err_q;
   wire                                      tlb_multihit_err_d;
   wire                                      tlb_par_err_q;
   wire                                      tlb_par_err_d;
   wire                                      lru_par_err_q;
   wire                                      lru_par_err_d;
   wire                                      tlb_miss_q;
   wire                                      tlb_miss_d;
   wire                                      reload_hit_d;
   wire                                      reload_hit_q;
   wire                                      nonspec_hit_d;
   wire                                      nonspec_hit_q;

   wire [0:5]                                cp_mm_except_taken_d;
   wire [0:5]                                cp_mm_except_taken_q;

   wire                                      eheir_val_d;
   wire                                      eheir_val_q;

   wire [0:3]                                event_bus_out_d;
   wire [0:3]                                event_bus_out_q;

   // External Debug
   wire                                      ext_dbg_stop_d;
   wire                                      ext_dbg_stop_q;
   wire                                      ext_dbg_stop_other_d;
   wire                                      ext_dbg_stop_other_q;
   wire                                      ext_dbg_act_err_d;
   wire                                      ext_dbg_act_err_q;
   wire                                      ext_dbg_act_ext_d;
   wire                                      ext_dbg_act_ext_q;
   wire                                      dbg_int_en_d;
   wire                                      dbg_int_en_q;
   wire                                      dbg_flush_en;
   wire                                      dbg_event_en_d;
   wire                                      dbg_event_en_q;

   // Scanchains
   parameter                                 iu6_i0_itag_offset = 0;
   parameter                                 iu6_i1_itag_offset = iu6_i0_itag_offset + `ITAG_SIZE_ENC-1;
   parameter                                 cp1_i0_itag_offset = iu6_i1_itag_offset + `ITAG_SIZE_ENC-1;
   parameter                                 cp1_i0_ptr_offset = cp1_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp1_i1_itag_offset = cp1_i0_ptr_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_i1_ptr_offset = cp1_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp2_i0_itag_offset = cp1_i1_ptr_offset + `CPL_Q_DEPTH;
   parameter                                 cp2_i1_itag_offset = cp2_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp2_async_int_val_offset = cp2_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp2_async_int_offset = cp2_async_int_val_offset + 1;
   parameter                                 cp2_i0_completed_offset = cp2_async_int_offset + 32;
   parameter                                 cp2_i1_completed_offset = cp2_i0_completed_offset + 1;
   parameter                                 cp2_i0_np1_flush_offset = cp2_i1_completed_offset + 1;
   parameter                                 cp2_i1_np1_flush_offset = cp2_i0_np1_flush_offset + 1;
   parameter                                 cp2_i0_n_np1_flush_offset = cp2_i1_np1_flush_offset + 1;
   parameter                                 cp2_i1_n_np1_flush_offset = cp2_i0_n_np1_flush_offset + 1;
   parameter                                 cp2_i0_bp_pred_offset = cp2_i1_n_np1_flush_offset + 1;
   parameter                                 cp2_i1_bp_pred_offset = cp2_i0_bp_pred_offset + 1;
   parameter                                 cp2_i0_br_pred_offset = cp2_i1_bp_pred_offset + 1;
   parameter                                 cp2_i1_br_pred_offset = cp2_i0_br_pred_offset + 1;
   parameter                                 cp2_i0_br_miss_offset = cp2_i1_br_pred_offset + 1;
   parameter                                 cp2_i1_br_miss_offset = cp2_i0_br_miss_offset + 1;
   parameter                                 cp2_i0_db_val_offset = cp2_i1_br_miss_offset + 1;
   parameter                                 cp2_i0_db_events_offset = cp2_i0_db_val_offset + 1;
   parameter                                 cp2_i1_db_val_offset = cp2_i0_db_events_offset + 19;
   parameter                                 cp2_i1_db_events_offset = cp2_i1_db_val_offset + 1;
   parameter                                 cp2_i0_perf_events_offset = cp2_i1_db_events_offset + 19;
   parameter                                 cp2_i1_perf_events_offset = cp2_i0_perf_events_offset + 4;
   parameter                                 cp2_i0_flush2ucode_offset = cp2_i1_perf_events_offset + 4;
   parameter                                 cp2_i0_flush2ucode_type_offset = cp2_i0_flush2ucode_offset + 1;
   parameter                                 cp2_i1_flush2ucode_offset = cp2_i0_flush2ucode_type_offset + 1;
   parameter                                 cp2_i1_flush2ucode_type_offset = cp2_i1_flush2ucode_offset + 1;
   parameter                                 cp2_i_bta_offset = cp2_i1_flush2ucode_type_offset + 1;
   parameter                                 cp2_i0_iu_excvec_val_offset = cp2_i_bta_offset + `EFF_IFAR_ARCH;
   parameter                                 cp2_i0_iu_excvec_offset = cp2_i0_iu_excvec_val_offset + 1;
   parameter                                 cp2_i1_iu_excvec_val_offset = cp2_i0_iu_excvec_offset + 4;
   parameter                                 cp2_i1_iu_excvec_offset = cp2_i1_iu_excvec_val_offset + 1;
   parameter                                 cp2_i0_lq_excvec_val_offset = cp2_i1_iu_excvec_offset + 4;
   parameter                                 cp2_i0_lq_excvec_offset = cp2_i0_lq_excvec_val_offset + 1;
   parameter                                 cp2_i1_lq_excvec_val_offset = cp2_i0_lq_excvec_offset + 6;
   parameter                                 cp2_i1_lq_excvec_offset = cp2_i1_lq_excvec_val_offset + 1;
   parameter                                 cp2_i0_xu_excvec_val_offset = cp2_i1_lq_excvec_offset + 6;
   parameter                                 cp2_i0_xu_excvec_offset = cp2_i0_xu_excvec_val_offset + 1;
   parameter                                 cp2_i1_xu_excvec_val_offset = cp2_i0_xu_excvec_offset + 5;
   parameter                                 cp2_i1_xu_excvec_offset = cp2_i1_xu_excvec_val_offset + 1;
   parameter                                 cp2_i0_axu_excvec_val_offset = cp2_i1_xu_excvec_offset + 5;
   parameter                                 cp2_i0_axu_excvec_offset = cp2_i0_axu_excvec_val_offset + 1;
   parameter                                 cp2_i1_axu_excvec_val_offset = cp2_i0_axu_excvec_offset + 4;
   parameter                                 cp2_i1_axu_excvec_offset = cp2_i1_axu_excvec_val_offset + 1;
   parameter                                 cp1_executed_offset = cp2_i1_axu_excvec_offset + 4;
   parameter                                 cp1_dispatched_offset = cp1_executed_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_n_flush_offset = cp1_dispatched_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_np1_flush_offset = cp1_n_flush_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_n_np1_flush_offset = cp1_np1_flush_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_flush2ucode_offset = cp1_n_np1_flush_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_flush2ucode_type_offset = cp1_flush2ucode_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_perf_events_offset = cp1_flush2ucode_type_offset + `CPL_Q_DEPTH;
   parameter                                 cp1_iu_excvec_val_offset = cp1_perf_events_offset + 4 * `CPL_Q_DEPTH;
   parameter                                 cp1_iu_excvec_offset = cp1_iu_excvec_val_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_lq_excvec_val_offset = cp1_iu_excvec_offset + 4 * `CPL_Q_DEPTH;
   parameter                                 cp1_lq_excvec_offset = cp1_lq_excvec_val_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_xu_excvec_val_offset = cp1_lq_excvec_offset + 6 * `CPL_Q_DEPTH;
   parameter                                 cp1_xu_excvec_offset = cp1_xu_excvec_val_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_axu_excvec_val_offset = cp1_xu_excvec_offset + 5 * `CPL_Q_DEPTH;
   parameter                                 cp1_axu_excvec_offset = cp1_axu_excvec_val_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_db_events_offset = cp1_axu_excvec_offset + 4 * `CPL_Q_DEPTH;
   parameter                                 cp1_recirc_vld_offset = cp1_db_events_offset + 19 * `CPL_Q_DEPTH;
   parameter                                 cp1_async_block_offset = cp1_recirc_vld_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_is_br_offset = cp1_async_block_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_br_add_chk_offset = cp1_is_br_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_bp_pred_offset = cp1_br_add_chk_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_br_pred_offset = cp1_bp_pred_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_br_miss_offset = cp1_br_pred_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_br_bta_offset = cp1_br_miss_offset + 1 * `CPL_Q_DEPTH;
   parameter                                 cp1_br_bta_v_offset = cp1_br_bta_offset + `EFF_IFAR_ARCH;
   parameter                                 cp1_br_bta_itag_offset = cp1_br_bta_v_offset + 1;
   parameter                                 cp0_i0_dispatched_offset = cp1_br_bta_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 cp0_i1_dispatched_offset = cp0_i0_dispatched_offset + 1;
   parameter                                 cp0_i0_ifar_offset = cp0_i1_dispatched_offset + 1;
   parameter                                 cp0_i0_ucode_offset = cp0_i0_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                                 cp0_i0_fuse_nop_offset = cp0_i0_ucode_offset + 3;
   parameter                                 cp0_i0_error_offset = cp0_i0_fuse_nop_offset + 1;
   parameter                                 cp0_i0_valop_offset = cp0_i0_error_offset + 3;
   parameter                                 cp0_i0_is_rfi_offset = cp0_i0_valop_offset + 1;
   parameter                                 cp0_i0_is_rfgi_offset = cp0_i0_is_rfi_offset + 1;
   parameter                                 cp0_i0_is_rfci_offset = cp0_i0_is_rfgi_offset + 1;
   parameter                                 cp0_i0_is_rfmci_offset = cp0_i0_is_rfci_offset + 1;
   parameter                                 cp0_i0_is_isync_offset = cp0_i0_is_rfmci_offset + 1;
   parameter                                 cp0_i0_is_sc_offset = cp0_i0_is_isync_offset + 1;
   parameter                                 cp0_i0_is_np1_flush_offset = cp0_i0_is_sc_offset + 1;
   parameter                                 cp0_i0_is_sc_hyp_offset = cp0_i0_is_np1_flush_offset + 1;
   parameter                                 cp0_i0_is_sc_ill_offset = cp0_i0_is_sc_hyp_offset + 1;
   parameter                                 cp0_i0_is_dcr_ill_offset = cp0_i0_is_sc_ill_offset + 1;
   parameter                                 cp0_i0_is_attn_offset = cp0_i0_is_dcr_ill_offset + 1;
   parameter                                 cp0_i0_is_ehpriv_offset = cp0_i0_is_attn_offset + 1;
   parameter                                 cp0_i0_is_folded_offset = cp0_i0_is_ehpriv_offset + 1;
   parameter                                 cp0_i0_async_block_offset = cp0_i0_is_folded_offset + 1;
   parameter                                 cp0_i0_is_br_offset = cp0_i0_async_block_offset + 1;
   parameter                                 cp0_i0_br_add_chk_offset = cp0_i0_is_br_offset + 1;
   parameter                                 cp0_i0_bp_pred_offset = cp0_i0_br_add_chk_offset + 1;
   parameter                                 cp0_i0_rollover_offset = cp0_i0_bp_pred_offset + 1;
   parameter                                 cp0_i0_isram_offset = cp0_i0_rollover_offset + 1;
   parameter                                 cp0_i0_match_offset = cp0_i0_isram_offset + 1;
   parameter                                 cp0_i1_ifar_offset = cp0_i0_match_offset + 1;
   parameter                                 cp0_i1_ucode_offset = cp0_i1_ifar_offset + `EFF_IFAR_WIDTH;
   parameter                                 cp0_i1_fuse_nop_offset = cp0_i1_ucode_offset + 3;
   parameter                                 cp0_i1_error_offset = cp0_i1_fuse_nop_offset + 1;
   parameter                                 cp0_i1_valop_offset = cp0_i1_error_offset + 3;
   parameter                                 cp0_i1_is_rfi_offset = cp0_i1_valop_offset + 1;
   parameter                                 cp0_i1_is_rfgi_offset = cp0_i1_is_rfi_offset + 1;
   parameter                                 cp0_i1_is_rfci_offset = cp0_i1_is_rfgi_offset + 1;
   parameter                                 cp0_i1_is_rfmci_offset = cp0_i1_is_rfci_offset + 1;
   parameter                                 cp0_i1_is_isync_offset = cp0_i1_is_rfmci_offset + 1;
   parameter                                 cp0_i1_is_sc_offset = cp0_i1_is_isync_offset + 1;
   parameter                                 cp0_i1_is_np1_flush_offset = cp0_i1_is_sc_offset + 1;
   parameter                                 cp0_i1_is_sc_hyp_offset = cp0_i1_is_np1_flush_offset + 1;
   parameter                                 cp0_i1_is_sc_ill_offset = cp0_i1_is_sc_hyp_offset + 1;
   parameter                                 cp0_i1_is_dcr_ill_offset = cp0_i1_is_sc_ill_offset + 1;
   parameter                                 cp0_i1_is_attn_offset = cp0_i1_is_dcr_ill_offset + 1;
   parameter                                 cp0_i1_is_ehpriv_offset = cp0_i1_is_attn_offset + 1;
   parameter                                 cp0_i1_is_folded_offset = cp0_i1_is_ehpriv_offset + 1;
   parameter                                 cp0_i1_async_block_offset = cp0_i1_is_folded_offset + 1;
   parameter                                 cp0_i1_is_br_offset = cp0_i1_async_block_offset + 1;
   parameter                                 cp0_i1_br_add_chk_offset = cp0_i1_is_br_offset + 1;
   parameter                                 cp0_i1_bp_pred_offset = cp0_i1_br_add_chk_offset + 1;
   parameter                                 cp0_i1_rollover_offset = cp0_i1_bp_pred_offset + 1;
   parameter                                 cp0_i1_isram_offset = cp0_i1_rollover_offset + 1;
   parameter                                 cp0_i1_match_offset = cp0_i1_isram_offset + 1;
   parameter                                 cp0_uc_hold_rollover_offset = cp0_i1_match_offset + 1;
   parameter                                 lq0_execute_vld_offset = cp0_uc_hold_rollover_offset + 1;
   parameter                                 lq0_itag_offset = lq0_execute_vld_offset + 1;
   parameter                                 lq0_n_flush_offset = lq0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 lq0_np1_flush_offset = lq0_n_flush_offset + 1;
   parameter                                 lq0_dacr_type_offset = lq0_np1_flush_offset + 1;
   parameter                                 lq0_dacrw_offset = lq0_dacr_type_offset + 1;
   parameter                                 lq0_instr_offset = lq0_dacrw_offset + 4;
   parameter                                 lq0_eff_addr_offset = lq0_instr_offset + 32;
   parameter                                 lq0_exception_val_offset = lq0_eff_addr_offset + `GPR_WIDTH;
   parameter                                 lq0_exception_offset = lq0_exception_val_offset + 1;
   parameter                                 lq0_flush2ucode_offset = lq0_exception_offset + 6;
   parameter                                 lq0_flush2ucode_type_offset = lq0_flush2ucode_offset + 1;
   parameter                                 lq0_recirc_val_offset = lq0_flush2ucode_type_offset + 1;
   parameter                                 lq1_execute_vld_offset = lq0_recirc_val_offset + 1;
   parameter                                 lq1_itag_offset = lq1_execute_vld_offset + 1;
   parameter                                 lq1_n_flush_offset = lq1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 lq1_np1_flush_offset = lq1_n_flush_offset + 1;
   parameter                                 lq1_exception_val_offset = lq1_np1_flush_offset + 1;
   parameter                                 lq1_exception_offset = lq1_exception_val_offset + 1;
   parameter                                 lq1_dacr_type_offset = lq1_exception_offset + 6;
   parameter                                 lq1_dacrw_offset = lq1_dacr_type_offset + 1;
   parameter                                 lq1_perf_events_offset = lq1_dacrw_offset + 4;
   parameter                                 br_perf_events_offset = lq1_perf_events_offset + 4;
   parameter                                 axu0_perf_events_offset = br_perf_events_offset + 4;
   parameter                                 axu1_perf_events_offset = axu0_perf_events_offset + 4;
   parameter                                 br_execute_vld_offset = axu1_perf_events_offset + 4;
   parameter                                 br_itag_offset = br_execute_vld_offset + 1;
   parameter                                 br_taken_offset = br_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 br_redirect_offset = br_taken_offset + 1;
   parameter                                 br_bta_offset = br_redirect_offset + 1;
   parameter                                 xu_execute_vld_offset = br_bta_offset + `EFF_IFAR_ARCH;
   parameter                                 xu_itag_offset = xu_execute_vld_offset + 1;
   parameter                                 xu_n_flush_offset = xu_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 xu_np1_flush_offset = xu_n_flush_offset + 1;
   parameter                                 xu_flush2ucode_offset = xu_np1_flush_offset + 1;
   parameter                                 xu_exception_val_offset = xu_flush2ucode_offset + 1;
   parameter                                 xu_exception_offset = xu_exception_val_offset + 1;
   parameter                                 xu_mtiar_offset = xu_exception_offset + 5;
   parameter                                 xu_bta_offset = xu_mtiar_offset + 1;
   parameter                                 xu_perf_events_offset = xu_bta_offset + `EFF_IFAR_ARCH;
   parameter                                 xu1_execute_vld_offset = xu_perf_events_offset + 4;
   parameter                                 xu1_itag_offset = xu1_execute_vld_offset + 1;
   parameter                                 axu0_execute_vld_offset = xu1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 axu0_itag_offset = axu0_execute_vld_offset + 1;
   parameter                                 axu0_n_flush_offset = axu0_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 axu0_np1_flush_offset = axu0_n_flush_offset + 1;
   parameter                                 axu0_n_np1_flush_offset = axu0_np1_flush_offset + 1;
   parameter                                 axu0_flush2ucode_offset = axu0_n_np1_flush_offset + 1;
   parameter                                 axu0_flush2ucode_type_offset = axu0_flush2ucode_offset + 1;
   parameter                                 axu0_exception_val_offset = axu0_flush2ucode_type_offset + 1;
   parameter                                 axu0_exception_offset = axu0_exception_val_offset + 1;
   parameter                                 axu1_execute_vld_offset = axu0_exception_offset + 4;
   parameter                                 axu1_itag_offset = axu1_execute_vld_offset + 1;
   parameter                                 axu1_n_flush_offset = axu1_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 axu1_np1_flush_offset = axu1_n_flush_offset + 1;
   parameter                                 axu1_n_np1_flush_offset = axu1_np1_flush_offset + 1;
   parameter                                 axu1_flush2ucode_offset = axu1_n_np1_flush_offset + 1;
   parameter                                 axu1_flush2ucode_type_offset = axu1_flush2ucode_offset + 1;
   parameter                                 axu1_exception_val_offset = axu1_flush2ucode_type_offset + 1;
   parameter                                 axu1_exception_offset = axu1_exception_val_offset + 1;
   parameter                                 iu_xu_cp3_rfi_offset = axu1_exception_offset + 4;
   parameter                                 iu_xu_cp3_rfgi_offset = iu_xu_cp3_rfi_offset + 1;
   parameter                                 iu_xu_cp3_rfci_offset = iu_xu_cp3_rfgi_offset + 1;
   parameter                                 iu_xu_cp3_rfmci_offset = iu_xu_cp3_rfci_offset + 1;
   parameter                                 iu_xu_cp4_rfi_offset = iu_xu_cp3_rfmci_offset + 1;
   parameter                                 iu_xu_cp4_rfgi_offset = iu_xu_cp4_rfi_offset + 1;
   parameter                                 iu_xu_cp4_rfci_offset = iu_xu_cp4_rfgi_offset + 1;
   parameter                                 iu_xu_cp4_rfmci_offset = iu_xu_cp4_rfci_offset + 1;
   parameter                                 cp3_ld_save_offset = iu_xu_cp4_rfmci_offset + 1;
   parameter                                 cp3_st_save_offset = cp3_ld_save_offset + 1;
   parameter                                 cp3_fp_save_offset = cp3_st_save_offset + 1;
   parameter                                 cp3_ap_save_offset = cp3_fp_save_offset + 1;
   parameter                                 cp3_spv_save_offset = cp3_ap_save_offset + 1;
   parameter                                 cp3_epid_save_offset = cp3_spv_save_offset + 1;
   parameter                                 cp3_async_hold_offset = cp3_epid_save_offset + 1;
   parameter                                 cp2_flush_offset = cp3_async_hold_offset + 1;
   parameter                                 cp3_flush_offset = cp2_flush_offset + 1;
   parameter                                 cp4_flush_offset = cp3_flush_offset + 1;
   parameter                                 cp3_rfi_offset = cp4_flush_offset + 1;
   parameter                                 cp3_attn_offset = cp3_rfi_offset + 1;
   parameter                                 cp3_sc_offset = cp3_attn_offset + 1;
   parameter                                 cp3_icmp_block_offset = cp3_sc_offset + 1;
   parameter                                 cp3_flush2ucode_offset = cp3_icmp_block_offset + 1;
   parameter                                 cp3_flush2ucode_type_offset = cp3_flush2ucode_offset + 1;
   parameter                                 cp3_flush_nonspec_offset = cp3_flush2ucode_type_offset + 1;
   parameter                                 cp3_mispredict_offset = cp3_flush_nonspec_offset + 1;
   parameter                                 cp3_async_int_val_offset = cp3_mispredict_offset + 1;
   parameter                                 cp3_async_int_offset = cp3_async_int_val_offset + 1;
   parameter                                 cp3_iu_excvec_val_offset = cp3_async_int_offset + 32;
   parameter                                 cp3_iu_excvec_offset = cp3_iu_excvec_val_offset + 1;
   parameter                                 cp3_lq_excvec_val_offset = cp3_iu_excvec_offset + 4;
   parameter                                 cp3_lq_excvec_offset = cp3_lq_excvec_val_offset + 1;
   parameter                                 cp3_xu_excvec_val_offset = cp3_lq_excvec_offset + 6;
   parameter                                 cp3_xu_excvec_offset = cp3_xu_excvec_val_offset + 1;
   parameter                                 cp3_axu_excvec_val_offset = cp3_xu_excvec_offset + 5;
   parameter                                 cp3_axu_excvec_offset = cp3_axu_excvec_val_offset + 1;
   parameter                                 cp3_db_val_offset = cp3_axu_excvec_offset + 4;
   parameter                                 cp3_db_events_offset = cp3_db_val_offset + 1;
   parameter                                 cp3_ld_offset = cp3_db_events_offset + 19;
   parameter                                 cp3_st_offset = cp3_ld_offset + 1;
   parameter                                 cp3_fp_offset = cp3_st_offset + 1;
   parameter                                 cp3_ap_offset = cp3_fp_offset + 1;
   parameter                                 cp3_spv_offset = cp3_ap_offset + 1;
   parameter                                 cp3_epid_offset = cp3_spv_offset + 1;
   parameter                                 cp3_ifar_offset = cp3_epid_offset + 1;
   parameter                                 cp3_np1_flush_offset = cp3_ifar_offset + 19;
   parameter                                 cp3_ucode_offset = cp3_np1_flush_offset + 1;
   parameter                                 cp3_preissue_offset = cp3_ucode_offset + 1;
   parameter                                 cp3_nia_offset = cp3_preissue_offset + 1;
   parameter                                 cp4_rfi_offset = cp3_nia_offset + `EFF_IFAR_ARCH;
   parameter                                 cp5_rfi_offset = cp4_rfi_offset + 1;
   parameter                                 cp6_rfi_offset = cp5_rfi_offset + 1;
   parameter                                 cp7_rfi_offset = cp6_rfi_offset + 1;
   parameter                                 cp8_rfi_offset = cp7_rfi_offset + 1;
   parameter                                 cp4_exc_val_offset = cp8_rfi_offset + 1;
   parameter                                 flush_hold_offset = cp4_exc_val_offset + 1;
   parameter                                 cp4_dp_cp_async_flush_offset = flush_hold_offset + 2;
   parameter                                 cp4_dp_cp_async_bus_snoop_flush_offset = cp4_dp_cp_async_flush_offset + 1;
   parameter                                 cp4_async_np1_offset = cp4_dp_cp_async_bus_snoop_flush_offset + 1;
   parameter                                 cp4_async_n_offset = cp4_async_np1_offset + 1;
   parameter                                 cp4_pc_stop_offset = cp4_async_n_offset + 1;
   parameter                                 pc_stop_hold_offset = cp4_pc_stop_offset + 1;
   parameter                                 cp4_mc_int_offset = pc_stop_hold_offset + 1;
   parameter                                 cp4_mchk_disabled_offset = cp4_mc_int_offset + 1;
   parameter                                 cp4_g_int_offset = cp4_mchk_disabled_offset + 1;
   parameter                                 cp4_c_int_offset = cp4_g_int_offset + 1;
   parameter                                 cp4_dbell_int_offset = cp4_c_int_offset + 1;
   parameter                                 cp4_cdbell_int_offset = cp4_dbell_int_offset + 1;
   parameter                                 cp4_gdbell_int_offset = cp4_cdbell_int_offset + 1;
   parameter                                 cp4_gcdbell_int_offset = cp4_gdbell_int_offset + 1;
   parameter                                 cp4_gmcdbell_int_offset = cp4_gcdbell_int_offset + 1;
   parameter                                 cp4_dbsr_update_offset = cp4_gmcdbell_int_offset + 1;
   parameter                                 cp4_dbsr_offset = cp4_dbsr_update_offset + 1;
   parameter                                 cp4_eheir_update_offset = cp4_dbsr_offset + 19;
   parameter                                 cp4_esr_update_offset = cp4_eheir_update_offset + 1;
   parameter                                 cp4_exc_esr_offset = cp4_esr_update_offset + 1;
   parameter                                 cp4_exc_mcsr_offset = cp4_exc_esr_offset + 17;
   parameter                                 cp4_asyn_irpt_needed_offset = cp4_exc_mcsr_offset + 15;
   parameter                                 cp4_asyn_icmp_needed_offset = cp4_asyn_irpt_needed_offset + 1;
   parameter                                 cp4_exc_nia_offset = cp4_asyn_icmp_needed_offset + 1;
   parameter                                 cp4_dear_update_offset = cp4_exc_nia_offset + `EFF_IFAR_ARCH;
   parameter                                 cp_next_itag_offset = cp4_dear_update_offset + 1;
   parameter                                 pc_iu_init_reset_offset = cp_next_itag_offset + `ITAG_SIZE_ENC;
   parameter                                 np1_async_flush_offset = pc_iu_init_reset_offset + 1;
   parameter                                 dp_cp_async_flush_offset = np1_async_flush_offset + 1;
   parameter                                 dp_cp_async_bus_snoop_flush_offset = dp_cp_async_flush_offset + 1;
   parameter                                 msr_de_offset = dp_cp_async_bus_snoop_flush_offset + 1;
   parameter                                 msr_pr_offset = msr_de_offset + 1;
   parameter                                 msr_cm_offset = msr_pr_offset + 1;
   parameter                                 msr_cm_noact_offset = msr_cm_offset + 1;
   parameter                                 msr_gs_offset = msr_cm_noact_offset + 1;
   parameter                                 msr_me_offset = msr_gs_offset + 1;
   parameter                                 dbcr0_edm_offset = msr_me_offset + 1;
   parameter                                 dbcr0_idm_offset = dbcr0_edm_offset + 1;
   parameter                                 dbcr0_icmp_offset = dbcr0_idm_offset + 1;
   parameter                                 dbcr0_brt_offset = dbcr0_icmp_offset + 1;
   parameter                                 dbcr0_irpt_offset = dbcr0_brt_offset + 1;
   parameter                                 dbcr0_trap_offset = dbcr0_irpt_offset + 1;
   parameter                                 iac1_en_offset = dbcr0_trap_offset + 1;
   parameter                                 iac2_en_offset = iac1_en_offset + 1;
   parameter                                 iac3_en_offset = iac2_en_offset + 1;
   parameter                                 iac4_en_offset = iac3_en_offset + 1;
   parameter                                 dbcr0_dac1_offset = iac4_en_offset + 1;
   parameter                                 dbcr0_dac2_offset = dbcr0_dac1_offset + 2;
   parameter                                 dbcr0_dac3_offset = dbcr0_dac2_offset + 2;
   parameter                                 dbcr0_dac4_offset = dbcr0_dac3_offset + 2;
   parameter                                 dbcr0_ret_offset = dbcr0_dac4_offset + 2;
   parameter                                 dbcr1_iac12m_offset = dbcr0_ret_offset + 1;
   parameter                                 dbcr1_iac34m_offset = dbcr1_iac12m_offset + 1;
   parameter                                 dbcr3_ivc_offset = dbcr1_iac34m_offset + 1;
   parameter                                 epcr_extgs_offset = dbcr3_ivc_offset + 1;
   parameter                                 epcr_dtlbgs_offset = epcr_extgs_offset + 1;
   parameter                                 epcr_itlbgs_offset = epcr_dtlbgs_offset + 1;
   parameter                                 epcr_dsigs_offset = epcr_itlbgs_offset + 1;
   parameter                                 epcr_isigs_offset = epcr_dsigs_offset + 1;
   parameter                                 epcr_duvd_offset = epcr_isigs_offset + 1;
   parameter                                 epcr_icm_offset = epcr_duvd_offset + 1;
   parameter                                 epcr_gicm_offset = epcr_icm_offset + 1;
   parameter                                 ccr2_ucode_dis_offset = epcr_gicm_offset + 1;
   parameter                                 ccr2_mmu_mode_offset = ccr2_ucode_dis_offset + 1;
   parameter                                 pc_iu_ram_active_offset = ccr2_mmu_mode_offset + 1;
   parameter                                 xu_iu_xucr4_mmu_mchk_offset = pc_iu_ram_active_offset + 1;
   parameter                                 pc_iu_ram_flush_thread_offset = xu_iu_xucr4_mmu_mchk_offset + 1;
   parameter                                 xu_iu_msrovride_enab_offset = pc_iu_ram_flush_thread_offset + 1;
   parameter                                 pc_iu_stop_offset = xu_iu_msrovride_enab_offset + 1;
   parameter                                 pc_iu_step_offset = pc_iu_stop_offset + 1;
   parameter                                 xu_iu_single_instr_offset = pc_iu_step_offset + 1;
   parameter                                 spr_single_issue_offset = xu_iu_single_instr_offset + 1;
   parameter                                 spr_ivpr_offset = spr_single_issue_offset + 1;
   parameter                                 spr_givpr_offset = spr_ivpr_offset + `GPR_WIDTH-12;
   parameter                                 spr_iac1_offset = spr_givpr_offset + `GPR_WIDTH-12;
   parameter                                 spr_iac2_offset = spr_iac1_offset + `EFF_IFAR_ARCH;
   parameter                                 spr_iac3_offset = spr_iac2_offset + `EFF_IFAR_ARCH;
   parameter                                 spr_iac4_offset = spr_iac3_offset + `EFF_IFAR_ARCH;
   parameter                                 spr_perf_mux_ctrls_offset = spr_iac4_offset + `EFF_IFAR_ARCH;
   parameter                                 pc_iu_dbg_action_offset = spr_perf_mux_ctrls_offset + 16;
   parameter                                 iu_pc_step_done_offset = pc_iu_dbg_action_offset + 3;
   parameter                                 uncond_dbg_event_offset = iu_pc_step_done_offset + 1;
   parameter                                 external_mchk_offset = uncond_dbg_event_offset + 1;
   parameter                                 ext_interrupt_offset = external_mchk_offset + 1;
   parameter                                 dec_interrupt_offset = ext_interrupt_offset + 1;
   parameter                                 udec_interrupt_offset = dec_interrupt_offset + 1;
   parameter                                 perf_interrupt_offset = udec_interrupt_offset + 1;
   parameter                                 fit_interrupt_offset = perf_interrupt_offset + 1;
   parameter                                 crit_interrupt_offset = fit_interrupt_offset + 1;
   parameter                                 wdog_interrupt_offset = crit_interrupt_offset + 1;
   parameter                                 gwdog_interrupt_offset = wdog_interrupt_offset + 1;
   parameter                                 gfit_interrupt_offset = gwdog_interrupt_offset + 1;
   parameter                                 gdec_interrupt_offset = gfit_interrupt_offset + 1;
   parameter                                 dbell_interrupt_offset = gdec_interrupt_offset + 1;
   parameter                                 cdbell_interrupt_offset = dbell_interrupt_offset + 1;
   parameter                                 gdbell_interrupt_offset = cdbell_interrupt_offset + 1;
   parameter                                 gcdbell_interrupt_offset = gdbell_interrupt_offset + 1;
   parameter                                 gmcdbell_interrupt_offset = gcdbell_interrupt_offset + 1;
   parameter                                 dbsr_interrupt_offset = gmcdbell_interrupt_offset + 1;
   parameter                                 fex_interrupt_offset = dbsr_interrupt_offset + 1;
   parameter                                 async_delay_cnt_offset = fex_interrupt_offset + 1;
   parameter                                 iu_lq_recirc_val_offset = async_delay_cnt_offset + 3;
   parameter                                 ext_dbg_stop_offset = iu_lq_recirc_val_offset + 1;
   parameter                                 ext_dbg_stop_other_offset = ext_dbg_stop_offset + 1;
   parameter                                 ext_dbg_act_err_offset = ext_dbg_stop_other_offset + 1;
   parameter                                 ext_dbg_act_ext_offset = ext_dbg_act_err_offset + 1;
   parameter                                 dbg_int_en_offset = ext_dbg_act_ext_offset + 1;
   parameter                                 dbg_event_en_offset = dbg_int_en_offset + 1;
   parameter                                 cp1_i0_dispatched_offset = dbg_event_en_offset + 1;
   parameter                                 cp1_i1_dispatched_offset = cp1_i0_dispatched_offset + `CPL_Q_DEPTH;
   parameter                                 iu7_i0_is_folded_offset = cp1_i1_dispatched_offset + `CPL_Q_DEPTH;
   parameter                                 iu7_i1_is_folded_offset = iu7_i0_is_folded_offset + 1;
   parameter                                 select_reset_offset = iu7_i1_is_folded_offset + 1;
   parameter                                 xu_iu_rest_ifar_offset = select_reset_offset + 1;
   parameter                                 attn_hold_offset = xu_iu_rest_ifar_offset + `EFF_IFAR_ARCH;
   parameter                                 flush_delay_offset = attn_hold_offset + 1;
   parameter                                 iu_nonspec_offset = flush_delay_offset + 2;
   parameter                                 ierat_pt_fault_offset = iu_nonspec_offset + 1;
   parameter                                 ierat_lrat_miss_offset = ierat_pt_fault_offset + 1;
   parameter                                 ierat_tlb_inelig_offset = ierat_lrat_miss_offset + 1;
   parameter                                 tlb_multihit_err_offset = ierat_tlb_inelig_offset + 1;
   parameter                                 tlb_par_err_offset = tlb_multihit_err_offset + 1;
   parameter                                 lru_par_err_offset = tlb_par_err_offset + 1;
   parameter                                 tlb_miss_offset = lru_par_err_offset + 1;
   parameter                                 reload_hit_offset = tlb_miss_offset + 1;
   parameter                                 nonspec_hit_offset = reload_hit_offset + 1;
   parameter                                 cp_mm_except_taken_offset = nonspec_hit_offset + 1;
   parameter                                 eheir_val_offset = cp_mm_except_taken_offset + 6;
   parameter                                 perf_bus_offset = eheir_val_offset + 1;
   parameter                                 scan_right = perf_bus_offset + 4;
   wire [0:scan_right-1]                     siv;
   wire [0:scan_right-1]                     sov;
   // Signals
   wire                                      tidn;
   wire                                      tiup;
   wire [0:`CPL_Q_DEPTH-1]                   lq0_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   lq0_recirc_vld;
   wire [0:`CPL_Q_DEPTH-1]                   lq1_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   br_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   fold_i0_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   fold_i1_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   xu_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   xu1_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   axu0_execute_vld;
   wire [0:`CPL_Q_DEPTH-1]                   axu1_execute_vld;
   wire                                      excvec_act;
   wire [0:`CPL_Q_DEPTH-1]                   excvec_act_v;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_compl_ready;
   wire [0:`CPL_Q_DEPTH-1]                   iu6_i0_ptr;
   wire [0:`CPL_Q_DEPTH-1]                   iu6_i1_ptr;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_dispatched;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i1_dispatched;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_completed;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i1_completed;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_i0_completed_ror;
   wire [0:`CPL_Q_DEPTH-1]                   exx_executed;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_completed;
   wire [0:`CPL_Q_DEPTH-1]                   cp1_flushed;
   wire [62-`EFF_IFAR_ARCH:61-`EFF_IFAR_WIDTH] cp3_ifor;

   // Reasons to not complete I1
   wire                                      cp1_i01_comp_is_br;		// Can't complete 2 branches in a cycle due to BHT writes
   wire                                      cp1_i0_comp_is_flush;		// If you flush I0 don't complete I1

   // Signal for NIA selection
   wire                                      select_i0_p1;
   wire                                      select_i1_p1;
   wire                                      select_i0_bta;
   wire                                      select_i1_bta;
   wire                                      select_i0_bp_bta;
   wire                                      select_i1_bp_bta;
   wire                                      select_ucode_p1;
   wire                                      select_reset;
   wire                                      select_reset_q;
   wire                                      select_mtiar;

   // IU exception calculations
   reg                                       iu6_i0_exception_val;
   reg                                       iu6_i1_exception_val;
   reg [0:3]                                 iu6_i0_exception;
   reg [0:3]                                 iu6_i1_exception;
   reg                                       iu6_i0_n_flush;
   reg                                       iu6_i1_n_flush;
   reg                                       iu6_i0_np1_flush;
   reg                                       iu6_i1_np1_flush;

   // Exception decode outputs
   wire                                      cp2_i0_iu_excvec_val;
   wire                                      cp2_i1_iu_excvec_val;
   wire                                      cp2_i0_lq_excvec_val;
   wire                                      cp2_i1_lq_excvec_val;
   wire                                      cp2_i0_xu_excvec_val;
   wire                                      cp2_i1_xu_excvec_val;
   wire                                      cp2_i0_axu_excvec_val;
   wire                                      cp2_i1_axu_excvec_val;
   wire                                      cp2_i0_db_events_val;
   wire                                      cp2_i1_db_events_val;
   wire                                      cp2_i0_exc_val;
   wire                                      cp2_i1_exc_val;
   wire                                      cp2_i0_ram_excvec_val;
   wire                                      cp1_async_block;
   wire                                      cp2_open_async;
   wire                                      iu_flush_cond;
   wire                                      flush_cond;

   // Instruction Address Compares
   wire [62-`EFF_IFAR_ARCH:61]               iac2_mask;
   wire [62-`EFF_IFAR_ARCH:61]               iac4_mask;
   wire [0:1]                                iac1_cmprh;
   wire [0:1]                                iac2_cmprh;
   wire [0:1]                                iac3_cmprh;
   wire [0:1]                                iac4_cmprh;
   wire [0:1]                                iac1_cmprl;
   wire [0:1]                                iac2_cmprl;
   wire [0:1]                                iac3_cmprl;
   wire [0:1]                                iac4_cmprl;
   wire [0:1]                                iac1_cmpr;
   wire [0:1]                                iac2_cmpr;
   wire [0:1]                                iac3_cmpr;
   wire [0:1]                                iac4_cmpr;
   wire [0:1]                                iac1_cmpr_sel;
   wire [0:1]                                iac2_cmpr_sel;
   wire [0:1]                                iac3_cmpr_sel;
   wire [0:1]                                iac4_cmpr_sel;
   wire [0:1]                                ivc_cmpr_sel;
   wire                                      ude_dbg_event;
   wire [0:1]                                icmp_dbg_event;
   wire [0:1]                                iac1_dbg_event;
   wire [0:1]                                iac2_dbg_event;
   wire [0:1]                                iac3_dbg_event;
   wire [0:1]                                iac4_dbg_event;
   wire [0:1]                                ret_sel;
   wire [0:1]                                rfi_dbg_event;
   wire [0:1]                                ivc_dbg_event;
   wire                                      trap_dbg_event;
   wire                                      brt_dbg_event;
   wire [0:1]                                iu_irpt_dbg_event;
   wire                                      xu_irpt_dbg_event;
   wire                                      axu0_irpt_dbg_event;
   wire                                      axu1_irpt_dbg_event;
   wire                                      lq0_irpt_dbg_event;
   wire                                      lq1_irpt_dbg_event;
   wire                                      iac_i0_n_flush;
   wire                                      iac_i1_n_flush;
   wire                                      dac_lq0_n_flush;
   wire                                      dac_lq1_n_flush;
   wire [0:1]                                dac1r_dbg_event;
   wire [0:1]                                dac1w_dbg_event;
   wire [0:1]                                dac2r_dbg_event;
   wire [0:1]                                dac2w_dbg_event;
   wire [0:1]                                dac3r_dbg_event;
   wire [0:1]                                dac3w_dbg_event;
   wire [0:1]                                dac4r_dbg_event;
   wire [0:1]                                dac4w_dbg_event;
   wire [0:1]                                dacr_dbg_event;
   wire                                      icmp_enable;
   wire                                      irpt_enable;
   wire                                      cp3_asyn_irpt_taken;
   wire                                      cp3_asyn_irpt_needed;
   wire                                      cp3_asyn_icmp_taken;
   wire                                      cp3_asyn_icmp_needed;
   wire                                      cp3_db_events_masked_reduced;
   wire [0:1]                                iu6_dbg_flush_en;
   wire                                      cp2_complete_act;
   wire                                      cp2_msr_act;

   wire                                      iu6_i0_db_IAC_IVC_event;
   wire                                      iu6_i1_db_IAC_IVC_event;
   wire [62-`EFF_IFAR_ARCH:61]               iu6_ifar[0:1];
   wire                                      cp_iu0_flush_2ucode_int;
   wire                                      cp_flush_into_uc_int;
   wire                                      iu_xu_dbsr_ude_int;

   // act signals
   wire                                      rn_cp_iu6_i0_act;
   wire                                      rn_cp_iu6_i1_act;

   // Signals for itag comparison
   wire                                      br_older_xu;
   wire                                      br_older_lq;
   wire                                      br_older_save;
   wire                                      xu_older_lq;
   wire                                      xu_older_save;
   wire                                      lq_older_save;
   wire                                      select_br;
   wire                                      select_xu;
   wire                                      select_lq;
   wire [1:32]                               save_table_pt;

   // temp signals
   wire                                      iu_pc_i0_comp_temp;
   wire                                      iu_pc_i1_comp_temp;

   wire                                      cp_mm_itlb_miss;
   wire                                      cp_mm_dtlb_miss;
   wire                                      cp_mm_isi;
   wire                                      cp_mm_dsi;
   wire                                      cp_mm_ilrat_miss;
   wire                                      cp_mm_dlrat_miss;
   wire                                      cp_mm_imchk;
   wire                                      cp_mm_dmchk;

   wire                                      dis_mm_mchk;

   wire                                      eheir_val;
   wire [1:`ITAG_SIZE_ENC-1]                 eheir_itag;
   wire [0:31]                               eheir_instr;

   wire                                      cp_events_en;
   wire [0:15]                               cp_events_in;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   function [0:`CPL_Q_DEPTH-1] decode_a;
   	input [1:`ITAG_SIZE_ENC-1] decode_input;

   	(* analysis_not_referenced="true" *)

   	integer i;
   	for(i = 0; i < `CPL_Q_DEPTH; i = i + 1)
   	begin
   		if({{32-`ITAG_SIZE_ENC+1{1'b0}},decode_input} == i)
   			decode_a[i] = 1'b1;
   		else
   			decode_a[i] = 1'b0;
   	end
   endfunction

   //-----------------------------------------------------------------------------
   // Temporary
   //-----------------------------------------------------------------------------
   assign iu_pc_i0_comp = iu_pc_i0_comp_temp;
   assign iu_pc_i1_comp = iu_pc_i1_comp_temp;
   assign iu_pc_i0_br_miss = iu_pc_i0_comp_temp & cp2_i0_br_miss_q;
   assign iu_pc_i1_br_miss = iu_pc_i1_comp_temp & cp2_i1_br_miss_q;
   assign iu_pc_i0_br_pred = iu_pc_i0_comp_temp & cp2_i0_bp_pred_q;
   assign iu_pc_i1_br_pred = iu_pc_i1_comp_temp & cp2_i1_bp_pred_q;
   assign iu_pc_flush_cnt = flush_cond;

   //-----------------------------------------------------------------------------
   // Status Control
   //-----------------------------------------------------------------------------
   assign iu6_i0_ptr = decode_a(iu6_i0_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign iu6_i1_ptr = decode_a(iu6_i1_itag_q[1:`ITAG_SIZE_ENC - 1]);

   assign cp1_i0_dispatched = iu6_i0_dispatched_q ? iu6_i0_ptr : 0;
   assign cp1_i1_dispatched = iu6_i1_dispatched_q ? iu6_i1_ptr : 0;
   assign cp1_i0_dispatched_delay_d = {`CPL_Q_DEPTH{~(cp3_flush_q | cp2_flush_q)}} & cp1_i0_dispatched;
   assign cp1_i1_dispatched_delay_d = {`CPL_Q_DEPTH{~(cp3_flush_q | cp2_flush_q)}} & cp1_i1_dispatched;

   assign cp0_dispatched = ({`CPL_Q_DEPTH{~cp3_flush_q}} & ((cp1_dispatched_q & (~cp1_completed)) | (cp1_i0_dispatched_delay_q | cp1_i1_dispatched_delay_q)));

   assign exx_executed = lq0_execute_vld | lq1_execute_vld | br_execute_vld | xu_execute_vld | xu1_execute_vld |
                         axu0_execute_vld | axu1_execute_vld | fold_i0_execute_vld | fold_i1_execute_vld;

   assign cp0_executed = (({`CPL_Q_DEPTH{~cp3_flush_q}}) & ((cp1_executed_q & (~cp1_completed)) | exx_executed));

   assign cp1_compl_ready = cp1_dispatched_q & cp1_executed_q;

   assign cp1_i0_completed = ({`CPL_Q_DEPTH{~cp2_flush_q & ~cp3_flush_q}} & (cp1_i0_ptr_q & cp1_compl_ready & ~cp1_n_flush_q));
   assign cp1_i0_completed_ror = {cp1_i0_completed[`CPL_Q_DEPTH - 1], cp1_i0_completed[0:`CPL_Q_DEPTH - 2]};
   assign cp1_i01_comp_is_br = (|(cp1_i0_ptr_q & cp1_is_br_q) & |(cp1_i1_ptr_q & cp1_is_br_q));
   assign cp1_i0_comp_is_flush = |(cp1_i0_ptr_q & (cp1_n_flush_q | cp1_np1_flush_q));
   assign cp1_i1_completed = ({`CPL_Q_DEPTH{~cp2_flush_q & ~cp3_flush_q & ~cp1_i01_comp_is_br & ~cp1_i0_comp_is_flush}} &
                              (cp1_i1_ptr_q & cp1_compl_ready & (~cp1_n_flush_q) & cp1_i0_completed_ror));

   assign cp1_completed = cp1_i0_completed | cp1_i1_completed | cp1_flushed;

   assign cp1_i0_complete = |(cp1_i0_completed) & ~cp1_async_int_val;
   assign cp1_i1_complete = |(cp1_i1_completed) & ~cp1_async_int_val;

   assign cp1_flushed = (cp1_i0_ptr_q | cp1_i0_completed_ror) & cp1_compl_ready & (cp1_n_flush_q | cp1_np1_flush_q);
   assign cp1_flush = (|(cp1_flushed) | cp1_async_int_val) & ~cp2_flush_q & ~cp3_flush_q;

   assign cp1_i0_np1_flush = |(cp1_i0_ptr_q & cp1_np1_flush_q) & ~cp1_async_int_val;
   assign cp1_i1_np1_flush = |(cp1_i1_ptr_q & cp1_np1_flush_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_n_np1_flush = |(cp1_i0_ptr_q & cp1_n_np1_flush_q) & ~cp1_async_int_val;
   assign cp1_i1_n_np1_flush = |(cp1_i1_ptr_q & cp1_n_np1_flush_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_bp_pred = |(cp1_i0_ptr_q & cp1_bp_pred_q) & ~cp1_async_int_val;
   assign cp1_i1_bp_pred = |(cp1_i1_ptr_q & cp1_bp_pred_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_br_pred = |(cp1_i0_ptr_q & cp1_br_pred_q) & ~cp1_async_int_val;
   assign cp1_i1_br_pred = |(cp1_i1_ptr_q & cp1_br_pred_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_br_miss = |(cp1_i0_ptr_q & cp1_br_miss_q) & ~cp1_async_int_val;
   assign cp1_i1_br_miss = |(cp1_i1_ptr_q & cp1_br_miss_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_flush2ucode = |(cp1_i0_ptr_q & cp1_flush2ucode_q) & ~cp1_async_int_val;
   assign cp1_i0_flush2ucode_type = |(cp1_i0_ptr_q & cp1_flush2ucode_type_q) & ~cp1_async_int_val;
   assign cp1_i1_flush2ucode = |(cp1_i1_ptr_q & cp1_flush2ucode_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i1_flush2ucode_type = |(cp1_i1_ptr_q & cp1_flush2ucode_type_q) & ~cp1_i0_comp_is_flush & ~cp1_async_int_val;
   assign cp1_i0_iu_excvec_val = |(cp1_i0_ptr_q & cp1_dispatched_q & cp1_iu_excvec_val_q) & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i1_iu_excvec_val = |(cp1_i1_ptr_q & cp1_dispatched_q & cp1_iu_excvec_val_q) & ~cp1_i0_comp_is_flush & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i0_lq_excvec_val = |(cp1_i0_ptr_q & cp1_dispatched_q & cp1_lq_excvec_val_q) & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i1_lq_excvec_val = |(cp1_i1_ptr_q & cp1_dispatched_q & cp1_lq_excvec_val_q) & ~cp1_i0_comp_is_flush & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i0_xu_excvec_val = |(cp1_i0_ptr_q & cp1_dispatched_q & cp1_xu_excvec_val_q) & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i1_xu_excvec_val = |(cp1_i1_ptr_q & cp1_dispatched_q & cp1_xu_excvec_val_q) & ~cp1_i0_comp_is_flush & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i0_axu_excvec_val = |(cp1_i0_ptr_q & cp1_dispatched_q & cp1_axu_excvec_val_q) & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i1_axu_excvec_val = |(cp1_i1_ptr_q & cp1_dispatched_q & cp1_axu_excvec_val_q) & ~cp1_i0_comp_is_flush & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i0_db_val = |(cp1_i0_ptr_q & cp1_compl_ready) & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i1_db_val = |(cp1_i1_ptr_q & cp1_compl_ready & cp1_i0_completed_ror) & ~cp1_i0_comp_is_flush & ~cp2_flush_q & ~cp3_flush_q & ~cp1_async_int_val;
   assign cp1_i_bta = cp1_br_bta_q;


//   always @(cp1_i0_ptr_q or cp1_i1_ptr_q or cp1_iu_excvec_q or cp1_lq_excvec_q or cp1_xu_excvec_q or cp1_axu_excvec_q or cp1_db_events_q)
   always @(*)
   begin: cp1_excvec_proc

      (* analysis_not_referenced="true" *)

      integer e;
      cp1_i0_iu_excvec <= 0;
      cp1_i1_iu_excvec <= 0;
      cp1_i0_lq_excvec <= 0;
      cp1_i1_lq_excvec <= 0;
      cp1_i0_xu_excvec <= 0;
      cp1_i1_xu_excvec <= 0;
      cp1_i0_axu_excvec <= 0;
      cp1_i1_axu_excvec <= 0;
      cp1_i0_db_events <= 0;
      cp1_i1_db_events <= 0;
      cp1_i0_perf_events <= 0;
      cp1_i1_perf_events <= 0;

      for (e = 0; e < `CPL_Q_DEPTH; e = e + 1)
      begin
         if (cp1_i0_ptr_q[e] == 1'b1)
         begin
            cp1_i0_iu_excvec <= cp1_iu_excvec_q[e];
            cp1_i0_lq_excvec <= cp1_lq_excvec_q[e];
            cp1_i0_xu_excvec <= cp1_xu_excvec_q[e];
            cp1_i0_axu_excvec <= cp1_axu_excvec_q[e];
            cp1_i0_db_events <= cp1_db_events_q[e];
            cp1_i0_perf_events <= cp1_perf_events_q[e];
         end
         if (cp1_i1_ptr_q[e] == 1'b1)
         begin
            cp1_i1_iu_excvec <= cp1_iu_excvec_q[e];
            cp1_i1_lq_excvec <= cp1_lq_excvec_q[e];
            cp1_i1_xu_excvec <= cp1_xu_excvec_q[e];
            cp1_i1_axu_excvec <= cp1_axu_excvec_q[e];
            cp1_i1_db_events <= cp1_db_events_q[e];
            cp1_i1_perf_events <= cp1_perf_events_q[e];
         end
      end
   end

//   The following table is for the cp2_async_hold and cp2_async_open logic
//   cp2_i0_complete_q                |
//   | cp2_i1_complete_q              |
//   | |   in_ucode_i0                |
//   | |   | ucode_end_i0             |
//   | |   | | nop_i0                 |
//   | |   | | |  in_ucode_i1         |  open
//   | |   | | |  | ucode_end_i1      |  | hold
//   | |   | | |  | | nop_i1          |  | |
//   | |   | | |  | | |               |  | |
//   -------------------------------------------
//   0 0   - - -  - - -               |  0 0
//   1 0   0 - 0  - - -               |  1 0 -- new
//   1 0   1 0 -  - - -               |  0 1
//   1 0   1 1 -  - - -               |  1 0
//   1 0   - - 1  - - -               |  0 1
//   1 1   1 0 -  1 0 -               |  0 1
//   1 1   1 0 -  1 1 -               |  1 0
//   1 1   - - -  0 - 0               |  1 0 -- changed
//   1 1   - - -  0 - 1               |  0 1 -- changed
//   1 1   1 1 -  1 - -               |  1 1
   assign cp3_async_hold_d = (cp2_async_hold | (cp3_async_hold_q & ~cp2_open_async)) & ~(iu_flush_cond & ~cp_flush_into_uc_int);
   assign cp2_async_hold = (cp2_i0_complete_q & ~cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & ~cp2_i0_ucode[2]) |
                           (cp2_i0_complete_q & ~cp2_i1_complete_q & cp2_i0_fuse_nop) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & ~cp2_i0_ucode[2] & (cp2_i1_ucode[0] | cp2_i1_ucode[1]) & ~cp2_i1_ucode[2]) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & ~(cp2_i1_ucode[0] | cp2_i1_ucode[1]) & cp2_i1_fuse_nop) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & cp2_i0_ucode[2] & (cp2_i1_ucode[0] | cp2_i1_ucode[1]));
   assign cp2_open_async = (cp2_i0_complete_q & ~cp2_i1_complete_q & ~(cp2_i0_ucode[0] | cp2_i0_ucode[1]) & ~cp2_i0_fuse_nop) |
                           (cp2_i0_complete_q & ~cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & cp2_i0_ucode[2]) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & ~cp2_i0_ucode[2] & (cp2_i1_ucode[0] | cp2_i1_ucode[1]) & cp2_i1_ucode[2]) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & ~(cp2_i1_ucode[0] | cp2_i1_ucode[1]) & ~cp2_i1_fuse_nop) |
                           (cp2_i0_complete_q & cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & cp2_i0_ucode[2] & (cp2_i1_ucode[0] | cp2_i1_ucode[1]));
   assign cp1_async_block = (((|(cp1_i0_ptr_q & cp1_dispatched_q & (cp1_async_block_q | cp1_recirc_vld_q))) | (cp2_async_hold | cp3_async_hold_q)) & ~cp2_open_async) | iu_nonspec_q;
   assign cp1_async_int = {(                         {tlb_miss_q, lru_par_err_q, tlb_par_err_q, tlb_multihit_err_q, ierat_pt_fault_q,
                                                      ierat_tlb_inelig_q, ierat_lrat_miss_q}),
                           ({25{~cp1_async_block}} & {cp4_asyn_icmp_needed_q, cp4_asyn_irpt_needed_q, dp_cp_async_flush_q, dp_cp_async_bus_snoop_flush_q,
                                                      np1_async_flush_q, pc_iu_stop_q, dbsr_interrupt_q, fex_interrupt_q, external_mchk_q, gmcdbell_interrupt_q,
                                                      ude_dbg_event, crit_interrupt_q, wdog_interrupt_q, gwdog_interrupt_q, cdbell_interrupt_q,
                                                      gcdbell_interrupt_q, ext_interrupt_q, fit_interrupt_q, gfit_interrupt_q, dec_interrupt_q,
                                                      gdec_interrupt_q, dbell_interrupt_q, gdbell_interrupt_q, udec_interrupt_q, perf_interrupt_q})};
   assign cp1_async_int_val = |(cp1_async_int) & ~cp2_flush_q & ~cp3_flush_q & (async_delay_cnt_q == 3'b0) & ~flush_hold;

   assign iu_lq_recirc_val_d = |(cp1_i0_ptr_q & cp1_dispatched_q & cp1_recirc_vld_q);

   //-----------------------------------------------------------------------------
   // IFAR/ITAG Tracking
   //-----------------------------------------------------------------------------
   assign iu_xu_cp2_rfi_d = (cp2_i0_complete_q & cp2_i0_rfi & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                            (cp2_i1_complete_q & cp2_i1_rfi & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));
   assign iu_xu_cp2_rfgi_d = (cp2_i0_complete_q & cp2_i0_rfgi & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                             (cp2_i1_complete_q & cp2_i1_rfgi & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));
   assign iu_xu_cp2_rfci_d = (cp2_i0_complete_q & cp2_i0_rfci & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                             (cp2_i1_complete_q & cp2_i1_rfci & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));
   assign iu_xu_cp2_rfmci_d = (cp2_i0_complete_q & cp2_i0_rfmci & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                              (cp2_i1_complete_q & cp2_i1_rfmci & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));

   assign iu_xu_rfi = iu_xu_cp4_rfi_q;
   assign iu_xu_rfgi = iu_xu_cp4_rfgi_q;
   assign iu_xu_rfci = iu_xu_cp4_rfci_q;
   assign iu_xu_rfmci = iu_xu_cp4_rfmci_q;

   assign cp2_rfi = (cp2_i0_complete_q & cp2_i0_rfi & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                    (cp2_i1_complete_q & cp2_i1_rfi & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]}))) |
                    (cp2_i0_complete_q & cp2_i0_rfgi & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                    (cp2_i1_complete_q & cp2_i1_rfgi & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]}))) |
                    (cp2_i0_complete_q & cp2_i0_rfci & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                    (cp2_i1_complete_q & cp2_i1_rfci & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]}))) |
                    (cp2_i0_complete_q & cp2_i0_rfmci & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                    (cp2_i1_complete_q & cp2_i1_rfmci & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));

   assign cp2_attn = (cp2_i0_complete_q & cp2_i0_attn & ~(cp2_db_val & |({cp2_i0_db_events_q[0], cp2_i0_db_events_q[2:18]}))) |
                     (cp2_i1_complete_q & cp2_i1_attn & ~(cp2_db_val & |({cp2_i1_db_events_q[0], cp2_i1_db_events_q[2:18]})));

   assign cp2_sc = (cp2_i0_complete_q & cp2_i0_sc) |
                   (cp2_i1_complete_q & cp2_i1_sc);



   iuq_cpl_table iuq_cpl_table(
      // NIA table inputs
      .i0_complete(cp2_i0_complete_q),
      .i0_bp_pred(cp2_i0_bp_pred_q),
      .i0_br_miss(cp2_i0_br_miss_q),
      .i0_ucode(cp2_i0_ucode),
      .i0_isram(cp2_i0_isram),
      .i0_mtiar(cp2_i0_mtiar),
      .i0_rollover(cp2_i0_rollover),
      .i0_rfi(cp6_rfi_q),
      .i0_n_np1_flush(cp2_i0_n_np1_flush_q),
      .i1_complete(cp2_i1_complete_q),
      .i1_bp_pred(cp2_i1_bp_pred_q),
      .i1_br_miss(cp2_i1_br_miss_q),
      .i1_ucode(cp2_i1_ucode),
      .i1_isram(cp2_i1_isram),
      .i1_mtiar(cp2_i1_mtiar),
      .i1_rollover(cp2_i1_rollover),
      .i1_rfi(tidn),
      .i1_n_np1_flush(cp2_i1_n_np1_flush_q),

      // Temp perf
      .iu_pc_i0_comp(iu_pc_i0_comp_temp),
      .iu_pc_i1_comp(iu_pc_i1_comp_temp),

      .icmp_enable(icmp_enable),
      .irpt_enable(irpt_enable),

      // NIA output selectors
      .select_i0_p1(select_i0_p1),
      .select_i1_p1(select_i1_p1),
      .select_i0_bta(select_i0_bta),
      .select_i1_bta(select_i1_bta),
      .select_i0_bp_bta(select_i0_bp_bta),
      .select_i1_bp_bta(select_i1_bp_bta),
      .select_ucode_p1(select_ucode_p1),
      .select_reset(select_reset),
      .select_mtiar(select_mtiar),		// only used to gate off the branch mispredict

      // Async list
      .cp3_async_int_val(cp3_async_int_val_q),
      .cp3_async_int(cp3_async_int_q),
      // IU execption list
      .cp3_iu_excvec_val(cp3_iu_excvec_val_q),
      .cp3_iu_excvec(cp3_iu_excvec_q),
      // LQ execption list
      .cp3_lq_excvec_val(cp3_lq_excvec_val_q),
      .cp3_lq_excvec(cp3_lq_excvec_q),
      // XU execption list
      .cp3_xu_excvec_val(cp3_xu_excvec_val_q),
      .cp3_xu_excvec(cp3_xu_excvec_q),
      // AXU execption list
      .cp3_axu_excvec_val(cp3_axu_excvec_val_q),
      .cp3_axu_excvec(cp3_axu_excvec_q),
      // Debug events
      .cp3_db_val(cp3_db_val_q),
      .cp3_db_events(cp3_db_events_q),
      // Instruction info
      .cp3_ld(cp3_ld_q),
      .cp3_st(cp3_st_q),
      .cp3_fp(cp3_fp_q),
      .cp3_ap(cp3_ap_q),
      .cp3_spv(cp3_spv_q),
      .cp3_epid(cp3_epid_q),
      .cp3_rfi(cp3_rfi_q),
      .cp3_attn(cp3_attn_q),
      .cp3_sc(cp3_sc_q),
      .cp3_icmp_block(cp3_icmp_block_q),
      // Debug interrupt taken
      .cp3_asyn_irpt_taken(cp3_asyn_irpt_taken),
      .cp3_asyn_irpt_needed(cp3_asyn_irpt_needed),
      .cp3_asyn_icmp_taken(cp3_asyn_icmp_taken),
      .cp3_asyn_icmp_needed(cp3_asyn_icmp_needed),
      .cp3_db_events_masked_reduced(cp3_db_events_masked_reduced),
      // Execption output
      .cp3_exc_nia(cp3_exc_nia),
      .cp3_mchk_disabled(cp3_mchk_disabled),
      // SPR bits
      .spr_ivpr(spr_ivpr),
      .spr_givpr(spr_givpr),
      .msr_gs(msr_gs_q),
      .msr_me(msr_me_q),
      .dbg_int_en(dbg_int_en_q),
      .dbcr0_irpt(dbcr0_irpt_q),
      .epcr_duvd(epcr_duvd_q),
      .epcr_extgs(epcr_extgs_q),
      .epcr_dtlbgs(epcr_dtlbgs_q),
      .epcr_itlbgs(epcr_itlbgs_q),
      .epcr_dsigs(epcr_dsigs_q),
      .epcr_isigs(epcr_isigs_q),
      .epcr_icm(epcr_icm_q),
      .epcr_gicm(epcr_gicm_q),
      // Type of exception
      .dp_cp_async_flush(cp3_dp_cp_async_flush),
      .dp_cp_async_bus_snoop_flush(cp3_dp_cp_async_bus_snoop_flush),
      .async_np1_flush(cp3_async_np1),
      .async_n_flush(cp3_async_n),
      .mm_iu_exception(cp3_mm_iu_exception),
      .pc_iu_stop(cp3_pc_stop),
      .mc_int(cp3_mc_int),
      .g_int(cp3_g_int),
      .c_int(cp3_c_int),
      .dbell_taken(cp3_dbell_int),
      .cdbell_taken(cp3_cdbell_int),
      .gdbell_taken(cp3_gdbell_int),
      .gcdbell_taken(cp3_gcdbell_int),
      .gmcdbell_taken(cp3_gmcdbell_int),
      // Update bits to SPR parititon
      .dear_update(cp3_dear_update),
      .dbsr_update(cp3_dbsr_update),
      .eheir_update(cp3_eheir_update),
      .cp3_dbsr(cp3_dbsr),
      // ESR bits
      .esr_update(cp3_esr_update),
      .cp3_exc_esr(cp3_exc_esr),

      .cp3_exc_mcsr(cp3_exc_mcsr),

      .cp_mm_itlb_miss(cp_mm_itlb_miss),
      .cp_mm_dtlb_miss(cp_mm_dtlb_miss),
      .cp_mm_isi(cp_mm_isi),
      .cp_mm_dsi(cp_mm_dsi),
      .cp_mm_ilrat_miss(cp_mm_ilrat_miss),
      .cp_mm_dlrat_miss(cp_mm_dlrat_miss),
      .cp_mm_imchk(cp_mm_imchk),
      .cp_mm_dmchk(cp_mm_dmchk),
      .dis_mm_mchk(dis_mm_mchk)

   );

   assign cp2_ifar = ({19{~cp2_i0_complete_q | cp2_i0_np1_flush_q}} & cp2_i0_ifar[43:61]) |
                     ({19{cp2_i0_complete_q & ~cp2_i0_np1_flush_q}} & cp2_i1_ifar[43:61]);
   assign cp2_np1_flush = (cp2_i0_complete_q & cp2_i0_np1_flush_q) |
                          (~cp2_i0_np1_flush_q & cp2_i1_complete_q & cp2_i1_np1_flush_q);
   assign cp2_ucode = (~cp2_i0_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1] | cp2_i0_ucode[2])) |
                      (cp2_i0_complete_q & ~cp2_i1_complete_q & (cp2_i0_ucode[0] | cp2_i0_ucode[1]) & ~cp2_i0_ucode[2]);

   assign cp2_preissue = (cp2_i0_ucode == 3'b010);


   assign iu_pc_step_done_d = (pc_iu_step_q & cp2_flush_q & ~(cp2_flush2ucode | cp2_ucode | cp2_flush_nonspec)) |
                              (iu_pc_step_done_q & pc_iu_step_q);
   assign cp3_flush_d = cp2_flush_q;

   assign nia_mask = ~msr_cm_noact_q ? {{`EFF_IFAR_ARCH-30{1'b0}}, {30{1'b1}}} : {`EFF_IFAR_ARCH{1'b1}};

   assign cp4_excvec_val = ((~(cp4_async_np1_q | cp4_async_n_q | cp4_pc_stop_q | cp4_dp_cp_async_flush_q | cp4_dp_cp_async_bus_snoop_flush_q)) & cp4_excvec_val_q);

   assign cp2_nia = ({`EFF_IFAR_ARCH{select_i0_p1}}     & (nia_mask & ({cp3_ifor, cp2_i0_ifar} + 1))) |
                    ({`EFF_IFAR_ARCH{select_i1_p1}}     & (nia_mask & ({cp3_ifor, cp2_i1_ifar} + 1))) |
                    ({`EFF_IFAR_ARCH{select_i0_bta}}    & (nia_mask & cp2_i_bta_q)) |
                    ({`EFF_IFAR_ARCH{select_i1_bta}}    & (nia_mask & cp2_i_bta_q)) |
                    ({`EFF_IFAR_ARCH{select_i0_bp_bta}} & (nia_mask & {cp3_ifor, cp2_i0_bp_bta})) |
                    ({`EFF_IFAR_ARCH{select_i1_bp_bta}} & (nia_mask & {cp3_ifor, cp2_i1_bp_bta})) |
                    ({`EFF_IFAR_ARCH{select_ucode_p1}}  & (nia_mask & (cp3_nia_q + 1))) |
                    ({`EFF_IFAR_ARCH{select_reset_q}}   & xu_iu_rest_ifar_q) |
                    ({`EFF_IFAR_ARCH{cp4_excvec_val}}   & cp4_exc_nia_q);

   assign cp3_nia_act = (select_i0_p1 | select_i1_p1 | select_i0_bta | select_i1_bta | select_i0_bp_bta | select_i1_bp_bta | select_ucode_p1 | select_reset_q | cp4_excvec_val);

   assign cp3_ifor = cp3_nia_q[62-`EFF_IFAR_ARCH:61-`EFF_IFAR_WIDTH];

   //-----------------------------------------------------------------------------
   // Exception Handler (Work in progress)
   //-----------------------------------------------------------------------------
   assign cp2_i0_iu_excvec_val = cp2_i0_iu_excvec_val_q & (~(cp2_i0_isram));
   assign cp2_i1_iu_excvec_val = cp2_i1_iu_excvec_val_q & (~(cp2_i1_isram));
   assign cp2_i0_lq_excvec_val = cp2_i0_lq_excvec_val_q & (~(cp2_i0_isram));
   assign cp2_i1_lq_excvec_val = cp2_i1_lq_excvec_val_q & (~(cp2_i1_isram));
   assign cp2_i0_xu_excvec_val = cp2_i0_xu_excvec_val_q & (~(cp2_i0_isram));
   assign cp2_i1_xu_excvec_val = cp2_i1_xu_excvec_val_q & (~(cp2_i1_isram));
   assign cp2_i0_axu_excvec_val = cp2_i0_axu_excvec_val_q & (~(cp2_i0_isram));
   assign cp2_i1_axu_excvec_val = cp2_i1_axu_excvec_val_q & (~(cp2_i1_isram));
   assign cp2_i0_db_events_val = cp2_i0_db_val_q & (~(cp2_i0_isram));
   assign cp2_i1_db_events_val = cp2_i1_db_val_q & (~(cp2_i1_isram));
   assign cp2_i0_exc_val = cp2_i0_iu_excvec_val | cp2_i0_lq_excvec_val | cp2_i0_xu_excvec_val | cp2_i0_axu_excvec_val;
   assign cp2_i1_exc_val = cp2_i1_iu_excvec_val | cp2_i1_lq_excvec_val | cp2_i1_xu_excvec_val | cp2_i1_axu_excvec_val;
   assign cp2_i0_ram_excvec_val = cp2_i0_iu_excvec_val_q | cp2_i0_lq_excvec_val_q | cp2_i0_xu_excvec_val_q | cp2_i0_axu_excvec_val_q;

   assign cp2_iu_excvec_val = ((cp2_i0_complete_q | (~cp2_i0_complete_q & cp3_flush_d)) & cp2_i0_iu_excvec_val) |
                              ((cp2_i1_complete_q | (cp2_i0_complete_q & ~select_i0_bta & cp3_flush_d)) & cp2_i1_iu_excvec_val);
   assign cp2_iu_excvec = ({4{cp2_i0_iu_excvec_val_q}} & cp2_i0_iu_excvec_q) |
                          ({4{~cp2_i0_iu_excvec_val_q & cp2_i1_iu_excvec_val_q}} & cp2_i1_iu_excvec_q);

   assign cp2_lq_excvec_val = ((cp2_i0_complete_q | (~cp2_i0_complete_q & cp3_flush_d)) & cp2_i0_lq_excvec_val) |
                              ((cp2_i1_complete_q | (cp2_i0_complete_q & ~select_i0_bta & cp3_flush_d)) & cp2_i1_lq_excvec_val);
   assign cp2_lq_excvec = ({6{cp2_i0_lq_excvec_val_q}} & cp2_i0_lq_excvec_q) |
                          ({6{~cp2_i0_lq_excvec_val_q & cp2_i1_lq_excvec_val_q}} & cp2_i1_lq_excvec_q);

   assign cp2_xu_excvec_val = ((cp2_i0_complete_q | (~cp2_i0_complete_q & cp3_flush_d)) & cp2_i0_xu_excvec_val) |
                              ((cp2_i1_complete_q | (cp2_i0_complete_q & ~select_i0_bta & cp3_flush_d)) & cp2_i1_xu_excvec_val);
   assign cp2_xu_excvec = ({5{cp2_i0_xu_excvec_val_q}} & cp2_i0_xu_excvec_q) |
                          ({5{~cp2_i0_xu_excvec_val_q & cp2_i1_xu_excvec_val_q}} & cp2_i1_xu_excvec_q);

   assign cp2_axu_excvec_val = ((cp2_i0_complete_q | (~cp2_i0_complete_q & cp3_flush_d)) & cp2_i0_axu_excvec_val) |
                               ((cp2_i1_complete_q | (cp2_i0_complete_q & ~select_i0_bta & cp3_flush_d)) & cp2_i1_axu_excvec_val);
   assign cp2_axu_excvec = ({4{cp2_i0_axu_excvec_val_q}} & cp2_i0_axu_excvec_q) |
                           ({4{~cp2_i0_axu_excvec_val_q & cp2_i1_axu_excvec_val_q}} & cp2_i1_axu_excvec_q);

   assign cp2_i0_axu_exception_val = cp2_i0_axu_excvec_val & cp2_i0_complete_q;
   assign cp2_i0_axu_exception = cp2_i0_axu_excvec_q;
   assign cp2_i1_axu_exception_val = cp2_i1_axu_excvec_val & cp2_i1_complete_q;
   assign cp2_i1_axu_exception = cp2_i1_axu_excvec_q;

   assign cp2_db_val = (((cp2_i0_complete_q | (~cp2_i0_complete_q & cp3_flush_d)) & cp2_i0_db_events_val) |
                        ((cp2_i1_complete_q | (cp2_i0_complete_q & ~select_i0_bta & cp3_flush_d)) & cp2_i1_db_events_val)) & msr_de_q;
   assign cp2_db_events = ({19{cp2_i0_db_events_val}} & cp2_i0_db_events_q) |
                          ({19{cp2_i1_db_events_val}} & cp2_i1_db_events_q);

   // Hold ucode values
   assign cp3_ld_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? cp2_i1_ld :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? cp2_i0_ld :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                          cp3_ld_save_q;

   assign cp3_st_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? (cp2_i1_st | cp2_i1_type_st) :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? (cp2_i0_st | cp2_i0_type_st) :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                          cp3_st_save_q;

   assign cp3_fp_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? cp2_i1_type_fp :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? cp2_i0_type_fp :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                          cp3_fp_save_q;

   assign cp3_ap_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? cp2_i1_type_ap :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? cp2_i0_type_ap :
                          ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                          ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                          cp3_ap_save_q;

   assign cp3_spv_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                           ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? cp2_i1_type_spv :
                           ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? cp2_i0_type_spv :
                           ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                           ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                           cp3_spv_save_q;

   assign cp3_epid_save_d = ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[0] == 1'b1 & cp2_i1_ucode[2] == 1'b1)) ? 1'b0 :
                            ((cp2_i0_complete_q == 1'b1 & cp2_i1_complete_q == 1'b1 & cp2_i1_ucode[1] == 1'b1)) ? cp2_i1_epid :
                            ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[1] == 1'b1)) ? cp2_i0_epid :
                            ((cp2_i0_complete_q == 1'b1 & cp2_i0_ucode[0] == 1'b1 & cp2_i0_ucode[2] == 1'b1)) ? 1'b0 :
                            ((cp3_flush_q == 1'b1 & cp_flush_into_uc_int == 1'b0)) ? 1'b0 :
                            cp3_epid_save_q;

   assign cp2_ld = (cp2_i0_exc_val & (cp3_ld_save_q | cp2_i0_ld)) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_ld_save_q) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & cp2_i1_ld);

   assign cp2_st = (cp2_i0_exc_val & (cp3_st_save_q | cp2_i0_st | cp2_i0_type_st)) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_st_save_q) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & (cp2_i1_st | cp2_i1_type_st));

   assign cp2_fp = (cp2_i0_exc_val & (cp3_fp_save_q | cp2_i0_type_fp)) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_fp_save_q) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & cp2_i1_type_fp);

   assign cp2_ap = (cp2_i0_exc_val & (cp3_ap_save_q | cp2_i0_type_ap)) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_ap_save_q) |
                   ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & cp2_i1_type_ap);

   assign cp2_spv = (cp2_i0_exc_val & (cp3_spv_save_q | cp2_i0_type_spv)) |
                    ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_spv_save_q) |
                    ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & cp2_i1_type_spv);

   assign cp2_epid = (cp2_i0_exc_val & (cp3_epid_save_q | cp2_i0_epid)) |
                     ((~cp2_i0_exc_val & cp2_i1_exc_val & cp2_i1_ucode[0]) & cp3_epid_save_q) |
                     ((~cp2_i0_exc_val & cp2_i1_exc_val & ~cp2_i1_ucode[0]) & cp2_i1_epid);

   assign cp2_icmp_block = (cp2_i0_db_events_val & cp2_i0_icmp_block) | (cp2_i1_db_events_val & cp2_i1_icmp_block);

   assign cp2_flush2ucode = ((cp2_i0_flush2ucode_q) | (cp2_i0_complete_q & ~cp2_i0_np1_flush_q & cp2_i1_flush2ucode_q)) & cp2_flush_q;
   assign cp2_flush2ucode_type = ((cp2_i0_flush2ucode_type_q) | (cp2_i0_complete_q & ~cp2_i0_np1_flush_q & cp2_i1_flush2ucode_type_q)) & cp2_flush_q;
   assign cp2_flush_nonspec = ((cp2_i0_nonspec) | (cp2_i0_complete_q & ~cp2_i0_np1_flush_q & cp2_i1_nonspec)) & cp2_flush_q;
   assign cp2_mispredict = (select_i0_bta | select_i1_bta) & (~(select_mtiar));

   // Async debug interrupt
   assign cp4_asyn_irpt_needed_d = (cp4_asyn_irpt_needed_q & dbg_event_en_q & (~(cp3_asyn_irpt_taken))) | cp3_asyn_irpt_needed;
   assign cp4_asyn_icmp_needed_d = (cp4_asyn_icmp_needed_q & (~(cp3_asyn_icmp_taken))) | cp3_asyn_icmp_needed;

   // Delayed for table lookups
   assign cp3_excvec_val = (cp3_iu_excvec_val_q | cp3_lq_excvec_val_q | cp3_xu_excvec_val_q |
                            cp3_axu_excvec_val_q | (cp3_db_val_q & cp3_db_events_masked_reduced) | cp3_async_int_val_q) & ~cp3_mchk_disabled;

   // Just or all exceptions here
   assign cp3_rfi = cp3_rfi_q;		// need to check if we are in the right state someday

   assign flush_hold_d[0] = cp4_excvec_val_q | attn_hold_q;		// Need to hold exceptions longer to make sure updates have occured.
   assign flush_hold_d[1] = flush_hold_q[0];		// Need to hold exceptions longer to make sure updates have occured.
   assign flush_hold = |flush_hold_q;

   assign np1_async_flush_d = (np1_async_flush_q & (~(cp4_async_np1_q))) | xu_iu_np1_async_flush;

   assign pc_iu_stop_d = (pc_iu_stop_q & (~(cp4_pc_stop_q | pc_stop_hold_q))) | (pc_iu_stop & ~pc_stop_hold_q);
   assign pc_stop_hold_d = (pc_stop_hold_q & pc_iu_stop) | cp4_pc_stop_q;

   assign dp_cp_async_flush_d = (dp_cp_async_flush_q & (~(cp4_dp_cp_async_flush_q))) | dp_cp_hold_req;
   assign dp_cp_async_bus_snoop_flush_d = (dp_cp_async_bus_snoop_flush_q & (~(cp4_dp_cp_async_bus_snoop_flush_q))) | dp_cp_bus_snoop_hold_req;

   assign iu_xu_int = cp4_excvec_val_q & (~(cp4_g_int_q | cp4_c_int_q | cp4_mc_int_q | cp4_async_np1_q | cp4_async_n_q | cp4_pc_stop_q | cp4_dp_cp_async_flush_q | cp4_dp_cp_async_bus_snoop_flush_q));
   assign iu_xu_async_complete = cp4_async_np1_q;
   assign iu_mm_hold_ack = cp4_dp_cp_async_flush_q;
   assign iu_mm_bus_snoop_hold_ack = cp4_dp_cp_async_bus_snoop_flush_q;
   assign iu_xu_gint = cp4_g_int_q;
   assign iu_xu_cint = cp4_c_int_q;
   assign iu_xu_mcint = cp4_mc_int_q;
   assign iu_xu_nia = cp3_nia_q;
   assign iu_xu_esr_update = cp4_esr_update_q;
   assign iu_xu_esr = cp4_exc_esr_q;
   assign iu_xu_mcsr = cp4_exc_mcsr_q;
   assign iu_xu_dbsr_update = cp4_dbsr_update_q;
   assign iu_xu_dbsr = cp4_dbsr_q;
   assign iu_xu_dear_update = cp4_dear_update_q;
   assign iu_xu_dear = lq0_eff_addr_q;
   assign iu_xu_stop = cp4_pc_stop_q | pc_stop_hold_q;
   assign iu_xu_quiesce = ~|cp1_dispatched_q;
   assign iu_xu_act = cp4_excvec_val_q | cp4_dbsr_update_q;
   assign iu_xu_dbell_taken = cp4_dbell_int_q;
   assign iu_xu_cdbell_taken = cp4_cdbell_int_q;
   assign iu_xu_gdbell_taken = cp4_gdbell_int_q;
   assign iu_xu_gcdbell_taken = cp4_gcdbell_int_q;
   assign iu_xu_gmcdbell_taken = cp4_gmcdbell_int_q;
   assign iu_xu_instr_cpl = iu_pc_i0_comp_temp | iu_pc_i1_comp_temp;
   assign iu_spr_eheir_update = cp4_eheir_update_q;
   assign iu_spr_eheir = cp1_br_bta_q[30:61];
   assign iu_pc_step_done = iu_pc_step_done_q;
   assign iu_pc_attention_instr = (cp2_i0_complete_q & cp2_i0_attn) | (cp2_i1_complete_q & cp2_i1_attn);
   assign iu_pc_err_mchk_disabled = cp4_mchk_disabled_q;
   assign attn_hold_d = (cp2_i0_complete_q & cp2_i0_attn) | (cp2_i1_complete_q & cp2_i1_attn) | (attn_hold_q & (~(pc_iu_stop_q)));

   assign async_delay_cnt_d = (cp3_excvec_val == 1'b1 | cp3_rfi_q == 1'b1 | async_delay_cnt_q != 3'b0) ? async_delay_cnt_q + 3'b001 : async_delay_cnt_q;

 `ifdef THREADS1
   assign iu_pc_stop_dbg_event = ext_dbg_stop_q & (cp4_dbsr_update_q | iu_xu_dbsr_ude_int);
 `endif
 `ifndef THREADS1
   assign iu_pc_stop_dbg_event = {(ext_dbg_stop_q & (cp4_dbsr_update_q | iu_xu_dbsr_ude_int)),
                                  (ext_dbg_stop_other_q & (cp4_dbsr_update_q | iu_xu_dbsr_ude_int))};
 `endif
   assign iu_pc_err_debug_event = ext_dbg_act_err_q & (cp4_dbsr_update_q | iu_xu_dbsr_ude_int);
   assign ac_an_debug_trigger = ext_dbg_act_ext_q & (cp4_dbsr_update_q | iu_xu_dbsr_ude_int);
   assign iu_pc_ram_done = (cp2_i0_complete_q | cp2_i0_ram_excvec_val | (cp2_flush_q & cp2_flush2ucode)) & cp2_i0_isram;
   assign iu_pc_ram_interrupt = cp2_i0_ram_excvec_val & ~&cp2_iu_excvec & cp2_i0_isram;
   assign iu_pc_ram_unsupported = ((cp2_i0_ram_excvec_val & (&cp2_iu_excvec)) | (cp2_flush_q & cp2_flush2ucode)) & cp2_i0_isram;

   assign cp_async_block = cp3_async_hold_q;

   //-----------------------------------------------------------------------------
   // ACT
   //-----------------------------------------------------------------------------
   assign cp2_complete_act = cp2_i0_complete_q | cp2_i1_complete_q | flush_cond | flush_delay_q[0];
   assign cp2_msr_act = xu_iu_msrovride_enab_q | cp2_complete_act;

   //-----------------------------------------------------------------------------
   // Next ITAG to complete
   //-----------------------------------------------------------------------------
   assign cp_next_itag_d = ~(cp2_flush_q | cp3_flush_q) ? cp2_i0_itag_q : {`ITAG_SIZE_ENC{1'b1}}; 		// Had to match this time with the flush time for mispredict to a cp_next
   assign cp_next_itag = cp_next_itag_q;

   assign iu_lq_i0_completed = cp2_i0_complete_q;
   assign iu_lq_i0_completed_itag = cp2_i0_itag_q;
   assign iu_lq_i1_completed = cp2_i1_complete_q;
   assign iu_lq_i1_completed_itag = cp2_i1_itag_q;

   //-----------------------------------------------------------------------------
   // Flush
   //-----------------------------------------------------------------------------
   assign flush_cond = cp3_flush_q | pc_iu_init_reset_q | cp4_excvec_val_q | cp4_rfi_q | cp5_rfi_q | cp6_rfi_q | cp7_rfi_q | cp8_rfi_q | iu_pc_step_done_q | pc_iu_ram_flush_thread_q | flush_hold;
   assign iu_flush_cond = (cp3_flush_q & ~cp3_mispredict_q) | pc_iu_init_reset_q | cp4_excvec_val_q | cp4_rfi_q | cp5_rfi_q | cp6_rfi_q | cp7_rfi_q | cp8_rfi_q | iu_pc_step_done_q | pc_iu_ram_flush_thread_q | flush_hold;
   assign iu_flush = iu_flush_cond;
   assign cp_flush_into_uc_int = cp3_flush_q & (~(cp3_flush2ucode_q)) & cp3_ucode_q & (~(cp3_preissue_q));
   assign cp_flush_into_uc = cp_flush_into_uc_int;
   assign cp_uc_flush_ifar = cp3_ifar_q[43:61];
   assign cp_uc_np1_flush = cp3_np1_flush_q;
   assign cp_flush = flush_cond;
   assign cp_flush_itag = cp1_i0_itag_q;
   assign cp_flush_ifar = ({cp8_rfi_q, cp4_excvec_val_q} == 2'b10) ? cp3_nia_q :
                          ({cp8_rfi_q, cp4_excvec_val_q} == 2'b00) ? cp3_nia_q :
                          cp4_exc_nia_q;
   assign cp_iu0_flush_2ucode = cp_iu0_flush_2ucode_int;
   assign cp_iu0_flush_2ucode_int = cp3_flush2ucode_q & ~(pc_iu_init_reset_q | cp4_excvec_val_q | cp4_rfi_q | cp5_rfi_q | cp6_rfi_q | cp7_rfi_q | cp8_rfi_q | pc_iu_ram_flush_thread_q);
   assign cp_iu0_flush_2ucode_type = cp3_flush2ucode_type_q & ~(pc_iu_init_reset_q | cp4_excvec_val_q | cp4_rfi_q | cp5_rfi_q | cp6_rfi_q | cp7_rfi_q | cp8_rfi_q | pc_iu_ram_flush_thread_q);
   assign cp_iu0_flush_nonspec = iu_flush_cond & cp3_flush_nonspec_q & ~(pc_iu_init_reset_q | cp4_excvec_val_q | cp4_rfi_q | cp5_rfi_q | cp6_rfi_q | cp7_rfi_q | cp8_rfi_q | pc_iu_ram_flush_thread_q);

   // Have a hole today for a few cycles from rename till when dispatched is set
   assign cp_rn_empty = ~|cp1_dispatched_q;

   assign nonspec_release = (nonspec_hit_d | reload_hit_q | ierat_pt_fault_q | ierat_lrat_miss_q | ierat_tlb_inelig_q |
                             tlb_multihit_err_q | tlb_par_err_q | lru_par_err_q | tlb_miss_q);

   assign iu_nonspec_d = ((iu_flush_cond & cp3_flush_nonspec_q) | (~iu_flush_cond & iu_nonspec_q)) & ~nonspec_release;
   assign ierat_pt_fault_d = (mm_iu_ierat_rel_val & mm_iu_ierat_pt_fault) | (ierat_pt_fault_q & ~cp3_mm_iu_exception) ;
   assign ierat_lrat_miss_d = (mm_iu_ierat_rel_val & mm_iu_ierat_lrat_miss) | (ierat_lrat_miss_q & ~cp3_mm_iu_exception);
   assign ierat_tlb_inelig_d = (mm_iu_ierat_rel_val & mm_iu_ierat_tlb_inelig) | (ierat_tlb_inelig_q & ~cp3_mm_iu_exception);
   assign tlb_multihit_err_d = (mm_iu_ierat_rel_val & mm_iu_tlb_multihit_err) | (tlb_multihit_err_q & ~cp3_mm_iu_exception);
   assign tlb_par_err_d = (mm_iu_ierat_rel_val & mm_iu_tlb_par_err) | (tlb_par_err_q & ~cp3_mm_iu_exception);
   assign lru_par_err_d = (mm_iu_ierat_rel_val & mm_iu_lru_par_err) | (lru_par_err_q & ~cp3_mm_iu_exception);
   assign tlb_miss_d = (mm_iu_ierat_rel_val & mm_iu_tlb_miss) | (tlb_miss_q & ~cp3_mm_iu_exception);
   assign reload_hit_d = mm_iu_reload_hit;
   assign nonspec_hit_d = ic_cp_nonspec_hit;

   assign lq0_execute_vld_d = lq0_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign lq1_execute_vld_d = lq1_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign br_execute_vld_d = br_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign xu_execute_vld_d = xu_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign xu1_execute_vld_d = xu1_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign axu0_execute_vld_d = axu0_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);
   assign axu1_execute_vld_d = axu1_iu_execute_vld & ~(cp3_flush_q | cp4_flush_q);

   //-----------------------------------------------------------------------------
   // ITAG Decode
   //-----------------------------------------------------------------------------
   assign lq0_execute_vld = {`CPL_Q_DEPTH{lq0_execute_vld_q}} & decode_a(lq0_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign lq0_recirc_vld = {`CPL_Q_DEPTH{lq0_recirc_val_q}} & decode_a(lq0_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign lq1_execute_vld = {`CPL_Q_DEPTH{lq1_execute_vld_q}} & decode_a(lq1_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign br_execute_vld = {`CPL_Q_DEPTH{br_execute_vld_q}} & decode_a(br_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign xu_execute_vld = {`CPL_Q_DEPTH{xu_execute_vld_q}} & decode_a(xu_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign xu1_execute_vld = {`CPL_Q_DEPTH{xu1_execute_vld_q}} & decode_a(xu1_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign axu0_execute_vld = {`CPL_Q_DEPTH{axu0_execute_vld_q}} & decode_a(axu0_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign axu1_execute_vld = {`CPL_Q_DEPTH{axu1_execute_vld_q}} & decode_a(axu1_itag_q[1:`ITAG_SIZE_ENC - 1]);
   assign fold_i0_execute_vld = {`CPL_Q_DEPTH{iu7_i0_is_folded_q}} & cp1_i0_dispatched_delay_q;
   assign fold_i1_execute_vld = {`CPL_Q_DEPTH{iu7_i1_is_folded_q}} & cp1_i1_dispatched_delay_q;

   assign excvec_act = lq0_execute_vld_q | lq0_recirc_val_q | lq1_execute_vld_q | br_execute_vld_q | xu_execute_vld_q |
                       xu1_execute_vld_q | axu0_execute_vld_q | axu1_execute_vld_q | iu6_i0_dispatched_q | iu6_i1_dispatched_q;

   //-----------------------------------------------------------------------------
   // Update Fields on Dispatch
   //-----------------------------------------------------------------------------
   generate
  	   begin : xhdl0
  	      genvar e;
         for (e = 0; e < `CPL_Q_DEPTH ; e = e + 1)
         begin : dispatch_update_gen
            assign cp0_iu_excvec_val[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_exception_val :
                                          ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_exception_val :
                                           cp1_iu_excvec_val_q[e];

            assign cp0_iu_excvec[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_exception :
                                      ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_exception :
                                       cp1_iu_excvec_q[e];

            assign cp0_async_block[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_async_block_q :
                                        ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_async_block_q :
                                         cp1_async_block_q[e];

            assign cp0_is_br[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_is_br_q :
                                  ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_is_br_q :
                                   cp1_is_br_q[e];

            assign cp0_br_add_chk[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_br_add_chk_q :
                                       ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_br_add_chk_q :
                                        cp1_br_add_chk_q[e];

            assign cp0_bp_pred[e] = ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b10) ? iu6_i0_bp_pred_q :
                                    ({cp1_i0_dispatched[e], cp1_i1_dispatched[e]} == 2'b01) ? iu6_i1_bp_pred_q :
                                     cp1_bp_pred_q[e];
         end
      end
   endgenerate

   // Debug is special because it is updates on dispatch and completion
   // 0    - Unconditional         implemented
   // 1    - Instruction Complete  RTX
   // 2    - Branch Taken          implemented
   // 3    - Interrupt Taken       RTX
   // 4    - Trap Instruction      implemented
   // 5:8  - IAC1-4                implemented
   // 9:10 - DAC1R, DAC1W          implemented
   // 11:12- DAC2R, DAC2W          implemented
   // 13   - Return                implemented
   // 14:15 - DAC3R, DAC3W         implemented
   // 16:17- DAC4R, DAC4W          implemented
   // 18   - Instr Value Comp      implemented
   assign iu6_i0_db_IAC_IVC_event = iac1_dbg_event[0] | iac2_dbg_event[0] | iac3_dbg_event[0] | iac4_dbg_event[0] | ivc_dbg_event[0];
   assign iu6_i1_db_IAC_IVC_event = iac1_dbg_event[1] | iac2_dbg_event[1] | iac3_dbg_event[1] | iac4_dbg_event[1] | ivc_dbg_event[1];

   generate
      begin : xhdl1
         genvar e;
         for (e = 0; e < `CPL_Q_DEPTH; e = e + 1)
         begin : db_event_cp_gen
            assign cp1_db_IAC_IVC_event[e] = cp1_db_events_q[e][5] | cp1_db_events_q[e][6] | cp1_db_events_q[e][7] | cp1_db_events_q[e][8] | cp1_db_events_q[e][18];

            assign cp0_db_events[e][0] = 1'b0;

            assign cp0_db_events[e][1] = cp1_i0_dispatched[e] 	? (icmp_dbg_event[0] & ~iu6_i0_n_flush & ~iu6_i0_db_IAC_IVC_event) :
                                         cp1_i1_dispatched[e] 	? (icmp_dbg_event[1] & ~iu6_i1_n_flush & ~iu6_i1_db_IAC_IVC_event) :
                                         lq0_execute_vld[e] 	? (cp1_db_events_q[e][1] & ~lq0_n_flush_q & ~cp1_db_IAC_IVC_event[e]) :
                                         lq1_execute_vld[e] 	? (cp1_db_events_q[e][1] & ~lq1_n_flush_q & ~cp1_db_IAC_IVC_event[e]) :
                                         xu_execute_vld[e] 	? (cp1_db_events_q[e][1] & ~xu_n_flush_q & ~cp1_db_IAC_IVC_event[e]) :
                                         xu1_execute_vld[e] 	? (cp1_db_events_q[e][1] & ~cp1_db_IAC_IVC_event[e]) :
                                         axu0_execute_vld[e] 	? (cp1_db_events_q[e][1] & ~axu0_n_flush_q & ~cp1_db_IAC_IVC_event[e]) :
                                         axu1_execute_vld[e]  	? (cp1_db_events_q[e][1] & ~axu1_n_flush_q & ~cp1_db_IAC_IVC_event[e]) :
                                         br_execute_vld[e]	? (cp1_db_events_q[e][1] & ~cp1_db_IAC_IVC_event[e] & ~brt_dbg_event) :
                                         cp1_db_events_q[e][1];

            assign cp0_db_events[e][2] = cp1_i0_dispatched[e]	? 1'b0 :
                                         cp1_i1_dispatched[e] 	? 1'b0 :
                                         br_execute_vld[e]	? (brt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         cp1_db_events_q[e][2];

            assign cp0_db_events[e][3] = cp1_i0_dispatched[e]	? (iu_irpt_dbg_event[0] & ~iu6_i0_db_IAC_IVC_event) :
                                         cp1_i1_dispatched[e] 	? (iu_irpt_dbg_event[1] & ~iu6_i1_db_IAC_IVC_event) :
                                         lq0_execute_vld[e] 	? (lq0_irpt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         lq1_execute_vld[e] 	? (lq1_irpt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         xu_execute_vld[e] 	? (xu_irpt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         axu0_execute_vld[e] 	? (axu0_irpt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         axu1_execute_vld[e] 	? (axu1_irpt_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         cp1_db_events_q[e][3];

            assign cp0_db_events[e][4] = cp1_i0_dispatched[e]	? 1'b0 :
                                         cp1_i1_dispatched[e] 	? 1'b0 :
                                         xu_execute_vld[e] 	? (trap_dbg_event & ~cp1_db_IAC_IVC_event[e]) :
                                         cp1_db_events_q[e][4];

            assign cp0_db_events[e][5] = cp1_i0_dispatched[e] 	? iac1_dbg_event[0] :
                                         cp1_i1_dispatched[e] 	? iac1_dbg_event[1] :
                                         cp1_db_events_q[e][5];

            assign cp0_db_events[e][6] = cp1_i0_dispatched[e] 	? iac2_dbg_event[0] :
                                         cp1_i1_dispatched[e] 	? iac2_dbg_event[1] :
                                         cp1_db_events_q[e][6];

            assign cp0_db_events[e][7] = cp1_i0_dispatched[e] 	? iac3_dbg_event[0] :
                                         cp1_i1_dispatched[e] 	? iac3_dbg_event[1] :
                                         cp1_db_events_q[e][7];

            assign cp0_db_events[e][8] = cp1_i0_dispatched[e] 	? iac4_dbg_event[0] :
                                         cp1_i1_dispatched[e] 	? iac4_dbg_event[1] :
                                         cp1_db_events_q[e][8];

            assign cp0_db_events[e][9] = cp1_i0_dispatched[e] 	? 1'b0 :
                                         cp1_i1_dispatched[e] 	? 1'b0 :
                                         lq0_execute_vld[e] 	? (dac1r_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                         lq1_execute_vld[e] 	? (dac1r_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                         cp1_db_events_q[e][9];

            assign cp0_db_events[e][10] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac1w_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac1w_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][10];

            assign cp0_db_events[e][11] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac2r_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac2r_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][11];

            assign cp0_db_events[e][12] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac2w_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac2w_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][12];

            assign cp0_db_events[e][13] = cp1_i0_dispatched[e]	? (rfi_dbg_event[0] & ~iu6_i0_db_IAC_IVC_event) :
                                          cp1_i1_dispatched[e]	? (rfi_dbg_event[1] & ~iu6_i1_db_IAC_IVC_event) :
                                          cp1_db_events_q[e][13];

            assign cp0_db_events[e][14] = cp1_i0_dispatched[e] 	? 1'b0 :
                                          cp1_i1_dispatched[e] 	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac3r_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac3r_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][14];

            assign cp0_db_events[e][15] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac3w_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac3w_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][15];

            assign cp0_db_events[e][16] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac4r_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac4r_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][16];

            assign cp0_db_events[e][17] = cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          lq0_execute_vld[e] 	? (dac4w_dbg_event[0] & ~cp1_db_IAC_IVC_event[e]) :
                                          lq1_execute_vld[e] 	? (dac4w_dbg_event[1] & ~cp1_db_IAC_IVC_event[e]) :
                                          cp1_db_events_q[e][17];

            assign cp0_db_events[e][18] = cp1_i0_dispatched[e]	? ivc_dbg_event[0] :
                                          cp1_i1_dispatched[e]	? ivc_dbg_event[1] :
                                          cp1_db_events_q[e][18];
         end
      end
   endgenerate

   assign rn_cp_iu6_i0_act = rn_cp_iu6_i0_vld;
   assign rn_cp_iu6_i1_act = rn_cp_iu6_i0_vld;
   assign iu6_i0_dispatched_d = rn_cp_iu6_i0_vld & ~(cp3_flush_d | cp3_flush_q | cp4_flush_q);
   assign iu6_i1_dispatched_d = rn_cp_iu6_i1_vld & ~(cp3_flush_d | cp3_flush_q | cp4_flush_q);

   //-----------------------------------------------------------------------------
   // Update Fields on Execution
   //-----------------------------------------------------------------------------
   generate
      begin : xhdl2
         genvar e;
         for (e = 0; e < `CPL_Q_DEPTH; e = e + 1)
         begin : cp1_executed_update_gen

            assign excvec_act_v[e] = lq0_execute_vld[e] | lq0_recirc_vld[e] | lq1_execute_vld[e] | br_execute_vld[e] | xu_execute_vld[e] | xu1_execute_vld[e] | axu0_execute_vld[e] | axu1_execute_vld[e] | cp1_i0_dispatched[e] | cp1_i1_dispatched[e];

            assign cp0_lq_excvec_val[e] = lq0_execute_vld[e] 	? lq0_exception_val_q :
                                          lq1_execute_vld[e] 	? lq1_exception_val_q :
                                          cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          cp1_lq_excvec_val_q[e];

            assign cp0_lq_excvec[e] = lq0_execute_vld[e] 	? lq0_exception_q :
                                      lq1_execute_vld[e] 	? lq1_exception_q :
                                      cp1_i0_dispatched[e] 	? 6'b0 :
                                      cp1_i1_dispatched[e] 	? 6'b0 :
                                      cp1_lq_excvec_q[e];

            assign cp0_xu_excvec_val[e] = xu_execute_vld[e] 	? xu_exception_val_q :
                                          cp1_i0_dispatched[e]	? 1'b0 :
                                          cp1_i1_dispatched[e]	? 1'b0 :
                                          cp1_xu_excvec_val_q[e];

            assign cp0_xu_excvec[e] = xu_execute_vld[e] 		? xu_exception_q :
                                      cp1_i0_dispatched[e] 	? 5'b0 :
                                      cp1_i1_dispatched[e] 	? 5'b0 :
                                      cp1_xu_excvec_q[e];

            assign cp0_axu_excvec_val[e] = axu0_execute_vld[e] 	? axu0_exception_val_q :
                                           axu1_execute_vld[e] 	? axu1_exception_val_q :
                                           cp1_i0_dispatched[e] 	? 1'b0 :
                                           cp1_i1_dispatched[e] 	? 1'b0 :
                                           cp1_axu_excvec_val_q[e];

            assign cp0_axu_excvec[e] = axu0_execute_vld[e]	? axu0_exception_q :
                                       axu1_execute_vld[e] 	? axu1_exception_q :
                                       cp1_i0_dispatched[e]	? 4'b0 :
                                       cp1_i1_dispatched[e]	? 4'b0 :
                                       cp1_axu_excvec_q[e];

            assign cp0_n_flush[e] = lq0_execute_vld[e] 	? (cp1_n_flush_q[e] | lq0_n_flush_q | (dac_lq0_n_flush & dbg_flush_en)) :
                                    lq1_execute_vld[e] 	? (cp1_n_flush_q[e] | lq1_n_flush_q | (dac_lq1_n_flush & dbg_flush_en)) :
                                    br_execute_vld[e] 	? (cp1_n_flush_q[e] | (brt_dbg_event & dbg_flush_en)) :
                                    xu_execute_vld[e] 	? (cp1_n_flush_q[e] | xu_n_flush_q | (trap_dbg_event & dbg_flush_en)) :
                                    axu0_execute_vld[e] 	? (cp1_n_flush_q[e] | axu0_n_flush_q) :
                                    axu1_execute_vld[e] 	? (cp1_n_flush_q[e] | axu1_n_flush_q) :
                                    cp1_i0_dispatched[e]	? (iu6_i0_n_flush | iac_i0_n_flush) :
                                    cp1_i1_dispatched[e]	? (iu6_i1_n_flush | iac_i1_n_flush) :
                                    cp1_n_flush_q[e];

            assign cp0_np1_flush[e] = lq0_execute_vld[e] 	? (cp1_np1_flush_q[e] | lq0_np1_flush_q) :
                                      lq1_execute_vld[e] 	? (cp1_np1_flush_q[e] | lq1_np1_flush_q) :
                                      br_execute_vld[e] 		? (cp1_np1_flush_q[e] | br_redirect_q) :
                                      xu_execute_vld[e] 		? (cp1_np1_flush_q[e] | xu_np1_flush_q | xu_mtiar_q) :
                                      axu0_execute_vld[e] 	? (cp1_np1_flush_q[e] | axu0_np1_flush_q) :
                                      axu1_execute_vld[e] 	? (cp1_np1_flush_q[e] | axu1_np1_flush_q) :
                                      cp1_i0_dispatched[e] 	? (iu6_i0_np1_flush | spr_single_issue_q):
                                      cp1_i1_dispatched[e] 	? (iu6_i1_np1_flush | spr_single_issue_q):
                                      cp1_np1_flush_q[e];

            assign cp0_perf_events[e] = lq0_execute_vld[e] 	 ? (cp1_perf_events_q[e] | {(spr_cp_perf_event_mux_ctrls[0:3]===4'b1100),
                                                                                        (spr_cp_perf_event_mux_ctrls[4:7]===4'b1100),
                                                                                        (spr_cp_perf_event_mux_ctrls[8:11]===4'b1100),
                                                                                        (spr_cp_perf_event_mux_ctrls[12:15]===4'b1100)}) :
                                        lq1_execute_vld[e]   ? (cp1_perf_events_q[e] | lq1_perf_events_q) :
                                        br_execute_vld[e]    ? (cp1_perf_events_q[e] | br_perf_events_q) :
                                        xu_execute_vld[e] 	 ? (cp1_perf_events_q[e] | xu_perf_events_q) :
                                        xu1_execute_vld[e]   ? (cp1_perf_events_q[e] | {(spr_cp_perf_event_mux_ctrls[0:3]===4'b1011),
                                                                                        (spr_cp_perf_event_mux_ctrls[4:7]===4'b1011),
                                                                                        (spr_cp_perf_event_mux_ctrls[8:11]===4'b1011),
                                                                                        (spr_cp_perf_event_mux_ctrls[12:15]===4'b1011)}) :
                                        axu0_execute_vld[e]  ? (cp1_perf_events_q[e] | axu0_perf_events_q) :
                                        axu1_execute_vld[e]  ? (cp1_perf_events_q[e] | axu1_perf_events_q) :
                                        cp1_i0_dispatched[e] ? 4'b0 :
                                        cp1_i1_dispatched[e] ? 4'b0 :
                                        cp1_perf_events_q[e];

            // This should probably be cleared on a flush so async aren't blocked as long.
            assign cp0_n_np1_flush[e] = axu0_execute_vld[e] 	? (cp1_n_np1_flush_q[e] | axu0_n_np1_flush_q) : 	// clear on dispatch
                                        axu1_execute_vld[e] 	? (cp1_n_np1_flush_q[e] | axu1_n_np1_flush_q) :
                                        cp1_i0_dispatched[e] 	? 1'b0 :
                                        cp1_i1_dispatched[e] 	? 1'b0 :
                                        cp1_n_np1_flush_q[e];

            assign cp0_recirc_vld[e] = cp1_i0_dispatched[e]	? 1'b0 : 		// clear on dispatch
                                       cp1_i1_dispatched[e]	? 1'b0 :
                                       lq0_recirc_vld[e] 	? 1'b1 :
                                       cp1_recirc_vld_q[e];

            assign cp0_flush2ucode[e] = cp1_i0_dispatched[e] 	? 1'b0 : 		// clear on dispatch
                                        cp1_i1_dispatched[e] 	? 1'b0 :
                                        lq0_execute_vld[e] 		? lq0_flush2ucode_q :
                                        xu_execute_vld[e] 		? xu_flush2ucode_q :
                                        axu0_execute_vld[e]		? axu0_flush2ucode_q :
                                        axu1_execute_vld[e] 	? axu1_flush2ucode_q :
                                        cp1_flush2ucode_q[e];

            assign cp0_flush2ucode_type[e] = cp1_i0_dispatched[e]	? 1'b0 :
                                             cp1_i1_dispatched[e]	? 1'b0 :
                                             lq0_execute_vld[e] 	? (lq0_flush2ucode_q & lq0_flush2ucode_type_q) :
                                             axu0_execute_vld[e] 	? (axu0_flush2ucode_q & axu0_flush2ucode_type_q) :
                                             axu1_execute_vld[e] 	? (axu1_flush2ucode_q & axu1_flush2ucode_type_q) :
                                             cp1_flush2ucode_type_q[e];

            assign cp0_br_pred[e] = br_execute_vld[e] ? br_taken_q : cp1_br_pred_q[e];

            assign cp0_br_miss[e] = cp1_i0_dispatched[e]	? 1'b0 :
                                    cp1_i1_dispatched[e]	? 1'b0 :
                                    br_execute_vld[e] 	? br_redirect_q :
                                    xu_execute_vld[e] 	? xu_mtiar_q :
                                    cp1_br_miss_q[e];
         end
      end
   endgenerate


   //-----------------------------------------------------------------------------
   // BTA calculations
   //-----------------------------------------------------------------------------
   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) br_xu_cmp(
      .a(xu_itag_q),
      .b(br_itag_q),
      .a_newer_b(br_older_xu)
   );

   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) br_lq_cmp(
      .a(lq0_itag_q),
      .b(br_itag_q),
      .a_newer_b(br_older_lq)
   );

   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) br_save_cmp(
      .a(cp1_br_bta_itag_q),
      .b(br_itag_q),
      .a_newer_b(br_older_save)
   );

   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) xu_lq_cmp(
      .a(lq0_itag_q),
      .b(xu_itag_q),
      .a_newer_b(xu_older_lq)
   );

   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) xu_save_cmp(
      .a(cp1_br_bta_itag_q),
      .b(xu_itag_q),
      .a_newer_b(xu_older_save)
   );

   tri_agecmp #(.SIZE(`ITAG_SIZE_ENC)) lq_save_cmp(
      .a(cp1_br_bta_itag_q),
      .b(lq0_itag_q),
      .a_newer_b(lq_older_save)
   );



   assign cp0_br_bta_act = br_redirect_q | xu_mtiar_q | xu_exception_val_q | lq0_exception_val_q | eheir_val | cp1_br_bta_v_q;

//table_start
//
//?TABLE SAVE_TABLE LISTING(final) OPTIMIZE PARMS(ON-SET,DC-SET);
//*INPUTS*=================================*OUTPUTS*=============*
//|                                        |                     |
//| br_redirect_q                          |                     |
//| | xu_mtiar_q                           |                     |
//| | | xu_exception_val_q                 |                     |
//| | | | lq0_exception_val_q              |                     |
//| | | | | cp1_br_bta_v_q                 |                     |
//| | | | | |                              |                     |
//| | | | | |   br_older_xu                |                     |
//| | | | | |   | br_older_lq              | select_br           |
//| | | | | |   | | br_older_save          | | select_xu         |
//| | | | | |   | | | xu_older_lq          | | | select_lq       |
//| | | | | |   | | | | xu_older_save      | | | |               |
//| | | | | |   | | | | | lq_older_save    | | | |               |
//| | | | | |   | | | | | |                | | | |               |
//| | | | | |   | | | | | |                | | | |               |
//| | | | | |   | | | | | |                | | | |               |
//| | | | | |   | | | | | |                | | | |               |
//| | | | | |   | | | | | |                | | | |               |
//*TYPE*===================================+=====================+
//| P P P P P   P P P P P P                | S S S               |
//*TERMS*==================================+=====================+
//| 0 0 0 0 0   - - - - - -                | 0 0 0               | # No Valid
//| 1 0 0 0 0   - - - - - -                | 1 0 0               | # Single Valid - BR
//| 0 P P 0 0   - - - - - -                | 0 1 0               | # Single Valid - XU
//| 0 0 0 1 0   - - - - - -                | 0 0 1               | # Single Valid - LQ
//| 0 0 0 0 1   - - - - - -                | 0 0 0               | # Single Valid - SAVE
//| 1 P P 0 0   1 - - - - -                | 1 0 0               | # Double Valid - BR,XU
//| 1 P P 0 0   0 - - - - -                | 0 1 0               | # Double Valid - BR,XU
//| 1 0 0 1 0   - 1 - - - -                | 1 0 0               | # Double Valid - BR,LQ
//| 1 0 0 1 0   - 0 - - - -                | 0 0 1               | # Double Valid - BR,LQ
//| 1 0 0 0 1   - - 1 - - -                | 1 0 0               | # Double Valid - BR,SAVE
//| 1 0 0 0 1   - - 0 - - -                | 0 0 0               | # Double Valid - BR,SAVE
//| 0 P P 1 0   - - - 1 - -                | 1 0 0               | # Double Valid - XU,LQ
//| 0 P P 1 0   - - - 0 - -                | 0 0 1               | # Double Valid - XU,LQ
//| 0 P P 0 1   - - - - 1 -                | 0 1 0               | # Double Valid - XU,SAVE
//| 0 P P 0 1   - - - - 0 -                | 0 0 0               | # Double Valid - XU,SAVE
//| 0 0 0 1 1   - - - - - 1                | 0 0 1               | # Double Valid - LQ,SAVE
//| 0 0 0 1 1   - - - - - 0                | 0 0 0               | # Double Valid - LQ,SAVE
//| 1 P P 1 0   - 0 - 0 - -                | 0 0 1               | # Triple Valid - BR,XU,LQ - LQ
//| 1 P P 1 0   0 - - 1 - -                | 0 1 0               | # Triple Valid - BR,XU,LQ - XU
//| 1 P P 1 0   1 1 - - - -                | 1 0 0               | # Triple Valid - BR,XU,LQ - BR
//| 1 P P 0 1   - - 0 - 0 -                | 0 0 0               | # Triple Valid - BR,XU,SAVE - SAVE
//| 1 P P 0 1   0 - - - 1 -                | 0 1 0               | # Triple Valid - BR,XU,SAVE - XU
//| 1 P P 0 1   1 - 1 - - -                | 1 0 0               | # Triple Valid - BR,XU,SAVE - BR
//| 1 0 0 1 1   - - 0 - - 0                | 0 0 0               | # Triple Valid - BR,LQ,SAVE - SAVE
//| 1 0 0 1 1   - 0 - - - 1                | 0 0 1               | # Triple Valid - BR,LQ,SAVE - LQ
//| 1 0 0 1 1   - 1 1 - - -                | 1 0 0               | # Triple Valid - BR,LQ,SAVE - BR
//| 0 P P 1 1   - - - - 0 0                | 0 0 0               | # Triple Valid - XU,LQ,SAVE - SAVE
//| 0 P P 1 1   - - - 0 - 1                | 0 0 1               | # Triple Valid - XU,LQ,SAVE - LQ
//| 0 P P 1 1   - - - 1 1 -                | 0 1 0               | # Triple Valid - XU,LQ,SAVE - XU
//| 1 P P 1 1   1 1 1 - - -                | 1 0 0               | # Quad Valid - BR
//| 1 P P 1 1   0 - - 1 1 -                | 0 1 0               | # Quad Valid - XU
//| 1 P P 1 1   - 0 - 0 - 1                | 0 0 1               | # Quad Valid - LQ
//| 1 P P 1 1   - - 0 - 0 0                | 0 0 0               | # Quad Valid - SAVE
//*END*====================================+=====================+
//?TABLE END SAVE_TABLE ;
//table_end

//assign_start

assign save_table_pt[1] =
    (({ br_redirect_q , xu_mtiar_q ,
    br_older_xu , xu_older_lq ,
    xu_older_save }) === 5'b11011);
assign save_table_pt[2] =
    (({ br_redirect_q , xu_exception_val_q ,
    br_older_xu , xu_older_lq ,
    xu_older_save }) === 5'b11011);
assign save_table_pt[3] =
    (({ xu_mtiar_q , xu_exception_val_q ,
    lq0_exception_val_q , br_older_lq ,
    lq_older_save }) === 5'b00101);
assign save_table_pt[4] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , br_older_lq ,
    br_older_save }) === 5'b10011);
assign save_table_pt[5] =
    (({ lq0_exception_val_q , br_older_lq ,
    xu_older_lq , lq_older_save
     }) === 4'b1001);
assign save_table_pt[6] =
    (({ br_redirect_q , br_older_xu ,
    br_older_lq , br_older_save
     }) === 4'b1111);
assign save_table_pt[7] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , lq0_exception_val_q ,
    lq_older_save }) === 5'b00011);
assign save_table_pt[8] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , lq0_exception_val_q ,
    br_older_save }) === 5'b10001);
assign save_table_pt[9] =
    (({ br_redirect_q , lq0_exception_val_q ,
    xu_older_lq , lq_older_save
     }) === 4'b0101);
assign save_table_pt[10] =
    (({ br_redirect_q , lq0_exception_val_q ,
    br_older_xu , br_older_save
     }) === 4'b1011);
assign save_table_pt[11] =
    (({ br_redirect_q , xu_exception_val_q ,
    cp1_br_bta_v_q , xu_older_lq ,
    xu_older_save }) === 5'b01111);
assign save_table_pt[12] =
    (({ br_redirect_q , xu_mtiar_q ,
    cp1_br_bta_v_q , xu_older_lq ,
    xu_older_save }) === 5'b01111);
assign save_table_pt[13] =
    (({ xu_exception_val_q , lq0_exception_val_q ,
    br_older_xu , xu_older_save
     }) === 4'b1001);
assign save_table_pt[14] =
    (({ xu_mtiar_q , lq0_exception_val_q ,
    br_older_xu , xu_older_save
     }) === 4'b1001);
assign save_table_pt[15] =
    (({ xu_mtiar_q , xu_exception_val_q ,
    lq0_exception_val_q , cp1_br_bta_v_q ,
    br_older_lq }) === 5'b00100);
assign save_table_pt[16] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , cp1_br_bta_v_q ,
    br_older_lq }) === 5'b10001);
assign save_table_pt[17] =
    (({ lq0_exception_val_q , cp1_br_bta_v_q ,
    br_older_lq , xu_older_lq
     }) === 4'b1000);
assign save_table_pt[18] =
    (({ br_redirect_q , cp1_br_bta_v_q ,
    br_older_xu , br_older_lq
     }) === 4'b1011);
assign save_table_pt[19] =
    (({ br_redirect_q , xu_exception_val_q ,
    cp1_br_bta_v_q , br_older_xu ,
    xu_older_lq }) === 5'b11001);
assign save_table_pt[20] =
    (({ br_redirect_q , xu_mtiar_q ,
    cp1_br_bta_v_q , br_older_xu ,
    xu_older_lq }) === 5'b11001);
assign save_table_pt[21] =
    (({ br_redirect_q , xu_exception_val_q ,
    lq0_exception_val_q , xu_older_save
     }) === 4'b0101);
assign save_table_pt[22] =
    (({ br_redirect_q , xu_mtiar_q ,
    lq0_exception_val_q , xu_older_save
     }) === 4'b0101);
assign save_table_pt[23] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , lq0_exception_val_q ,
    cp1_br_bta_v_q }) === 5'b00010);
assign save_table_pt[24] =
    (({ br_redirect_q , xu_mtiar_q ,
    xu_exception_val_q , lq0_exception_val_q ,
    cp1_br_bta_v_q }) === 5'b10000);
assign save_table_pt[25] =
    (({ br_redirect_q , lq0_exception_val_q ,
    cp1_br_bta_v_q , xu_older_lq
     }) === 4'b0100);
assign save_table_pt[26] =
    (({ br_redirect_q , xu_exception_val_q ,
    lq0_exception_val_q , cp1_br_bta_v_q ,
    xu_older_lq }) === 5'b01101);
assign save_table_pt[27] =
    (({ br_redirect_q , xu_mtiar_q ,
    lq0_exception_val_q , cp1_br_bta_v_q ,
    xu_older_lq }) === 5'b01101);
assign save_table_pt[28] =
    (({ br_redirect_q , lq0_exception_val_q ,
    cp1_br_bta_v_q , br_older_xu
     }) === 4'b1001);
assign save_table_pt[29] =
    (({ xu_exception_val_q , lq0_exception_val_q ,
    cp1_br_bta_v_q , br_older_xu
     }) === 4'b1000);
assign save_table_pt[30] =
    (({ xu_mtiar_q , lq0_exception_val_q ,
    cp1_br_bta_v_q , br_older_xu
     }) === 4'b1000);
assign save_table_pt[31] =
    (({ br_redirect_q , xu_exception_val_q ,
    lq0_exception_val_q , cp1_br_bta_v_q
     }) === 4'b0100);
assign save_table_pt[32] =
    (({ br_redirect_q , xu_mtiar_q ,
    lq0_exception_val_q , cp1_br_bta_v_q
     }) === 4'b0100);
assign select_br =
    (save_table_pt[4] | save_table_pt[6]
     | save_table_pt[8] | save_table_pt[10]
     | save_table_pt[16] | save_table_pt[18]
     | save_table_pt[24] | save_table_pt[26]
     | save_table_pt[27] | save_table_pt[28]
    );
assign select_xu =
    (save_table_pt[1] | save_table_pt[2]
     | save_table_pt[11] | save_table_pt[12]
     | save_table_pt[13] | save_table_pt[14]
     | save_table_pt[19] | save_table_pt[20]
     | save_table_pt[21] | save_table_pt[22]
     | save_table_pt[29] | save_table_pt[30]
     | save_table_pt[31] | save_table_pt[32]
    );
assign select_lq =
    (save_table_pt[3] | save_table_pt[5]
     | save_table_pt[7] | save_table_pt[9]
     | save_table_pt[15] | save_table_pt[17]
     | save_table_pt[23] | save_table_pt[25]
    );

//assign_end

   // EHEIR instruction value is passed in the bta field to conserve resources
   always @(*)
   begin: bta_proc
      cp0_br_bta_v        <= cp1_br_bta_v_q;
      cp0_br_bta_itag_tmp <= cp1_br_bta_itag_q;
      cp0_br_bta_tmp      <= cp1_br_bta_q;

      if (flush_delay_q[1] == 1'b1)		// This flush must match the flush the units see
         cp0_br_bta_v <= 1'b0;
      else
      begin
         if(select_br == 1'b1)
         begin
            cp0_br_bta_v <= 1'b1;
            cp0_br_bta_itag_tmp <= br_itag_q;
            cp0_br_bta_tmp      <= br_bta_q;
         end
         if(select_xu == 1'b1)
         begin
            cp0_br_bta_v <= 1'b1;
            cp0_br_bta_itag_tmp <= xu_itag_q;
            cp0_br_bta_tmp      <= xu_bta_q;
         end
         if(select_lq == 1'b1)
         begin
            cp0_br_bta_v <= 1'b1;
            cp0_br_bta_itag_tmp   <= lq0_itag_q;
	    cp0_br_bta_tmp[30:61] <= lq0_instr_q;
         end
      end
   end

   assign eheir_val_d = (( ( (rn_cp_iu6_i0_is_rfci | rn_cp_iu6_i0_is_rfmci ) |
                           (rn_cp_iu6_i1_is_rfci | rn_cp_iu6_i1_is_rfmci ) ) &
                            xu_iu_msr_gs ) | (eheir_val_q & ~flush_delay_q[1]));

   // this will come on once for a single cycle and not come on again until the flush occurs.
   // since this is looking at dispatch, the first one is the oldest one.
   assign eheir_val = eheir_val_d & ~ eheir_val_q;


   assign eheir_instr = ((rn_cp_iu6_i0_is_rfci | rn_cp_iu6_i0_is_rfmci ) & xu_iu_msr_gs ) ? rn_cp_iu6_i0_instr : rn_cp_iu6_i1_instr;
   assign eheir_itag  = ((rn_cp_iu6_i0_is_rfci | rn_cp_iu6_i0_is_rfmci ) & xu_iu_msr_gs ) ? rn_cp_iu6_i0_itag  : rn_cp_iu6_i1_itag;

   // this logic works on the notion that instuctions seen at dispatch will always
   // be older than ones which update on a completion report.  Therefore I will only
   // update the bta from iu if it has not already been updated from the other sources,
   // br, xu, lq.
   assign cp0_br_bta[62-`EFF_IFAR_ARCH:29] = cp0_br_bta_tmp[62-`EFF_IFAR_ARCH:29];
   assign cp0_br_bta[30:61] = (cp0_br_bta_v == 1'b0) ? eheir_instr : cp0_br_bta_tmp[30:61];
   assign cp0_br_bta_itag   = (cp0_br_bta_v == 1'b0) ? { 1'b0, eheir_itag }  : cp0_br_bta_itag_tmp;



   //-----------------------------------------------------------------------------
   // ITAG Incrementers
   //-----------------------------------------------------------------------------
   iuq_cpl_itag #(.SIZE(`ITAG_SIZE_ENC), .WRAP(`CPL_Q_DEPTH - 1)) cp1_i0_itag_inc(
      .inc({cp1_i0_complete, cp1_i1_complete}),
      .i(cp1_i0_itag_q),
      .o(cp0_i0_itag)
   );

   iuq_cpl_itag #(.SIZE(`ITAG_SIZE_ENC), .WRAP(`CPL_Q_DEPTH - 1)) cp1_i1_itag_inc(
      .inc({cp1_i0_complete, cp1_i1_complete}),
      .i(cp1_i1_itag_q),
      .o(cp0_i1_itag)
   );

   // Added  for timing

   assign cp0_i0_ptr = ({cp1_i0_complete, cp1_i1_complete} == 2'b10) ? {cp1_i0_ptr_q[`CPL_Q_DEPTH - 1], cp1_i0_ptr_q[0:`CPL_Q_DEPTH - 2]} :
                       ({cp1_i0_complete, cp1_i1_complete} == 2'b11) ? {cp1_i0_ptr_q[`CPL_Q_DEPTH - 2:`CPL_Q_DEPTH - 1], cp1_i0_ptr_q[0:`CPL_Q_DEPTH - 3]} :
                       cp1_i0_ptr_q;

   assign cp0_i1_ptr = ({cp1_i0_complete, cp1_i1_complete} == 2'b10) ? {cp1_i1_ptr_q[`CPL_Q_DEPTH - 1], cp1_i1_ptr_q[0:`CPL_Q_DEPTH - 2]} :
                       ({cp1_i0_complete, cp1_i1_complete} == 2'b11) ? {cp1_i1_ptr_q[`CPL_Q_DEPTH - 2:`CPL_Q_DEPTH - 1], cp1_i1_ptr_q[0:`CPL_Q_DEPTH - 3]} :
                       cp1_i1_ptr_q;

   //-----------------------------------------------------------------------------
   // IAC Compare
   //-----------------------------------------------------------------------------
   // Debug Enables
   assign iu6_ifar[0] = {cp3_nia_q[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH], iu6_i0_ifar_q};
   assign iu6_ifar[1] = {cp3_nia_q[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH], iu6_i1_ifar_q};

   generate
      begin : xhdl3
         genvar e;
         for (e = 0; e < `EFF_IFAR_ARCH; e = e + 1)
         begin : iac_mask_gen
         	assign iac2_mask[e] = spr_iac2_q[e] | (~(dbcr1_iac12m_q));
            assign iac4_mask[e] = spr_iac4_q[e] | (~(dbcr1_iac34m_q));
         end
      end
   endgenerate

   generate
      begin : xhdl4
         genvar t;
         for (t = 0; t <= 1; t = t + 1)
         begin : ifar_cmp
            if (`EFF_IFAR_ARCH > 32)		// ui=62-eff_ifar
            begin : iac_cmprh_gen0
               assign iac1_cmprh[t] = &((iu6_ifar[t][62-`EFF_IFAR_ARCH:31] ~^ spr_iac1_q[62-`EFF_IFAR_ARCH:31]) | (~iac2_mask[62-`EFF_IFAR_ARCH:31]));
               assign iac2_cmprh[t] = &(iu6_ifar[t][62-`EFF_IFAR_ARCH:31] ~^ spr_iac2_q[62-`EFF_IFAR_ARCH:31]);
               assign iac3_cmprh[t] = &((iu6_ifar[t][62-`EFF_IFAR_ARCH:31] ~^ spr_iac3_q[62-`EFF_IFAR_ARCH:31]) | (~iac4_mask[62-`EFF_IFAR_ARCH:31]));
               assign iac4_cmprh[t] = &(iu6_ifar[t][62-`EFF_IFAR_ARCH:31] ~^ spr_iac4_q[62-`EFF_IFAR_ARCH:31]);
               assign iac1_cmprl[t] = &((iu6_ifar[t][32:61] ~^ spr_iac1_q[32:61]) | (~iac2_mask[32:61]));
               assign iac2_cmprl[t] = &(iu6_ifar[t][32:61] ~^ spr_iac2_q[32:61]);
               assign iac3_cmprl[t] = &((iu6_ifar[t][32:61] ~^ spr_iac3_q[32:61]) | (~iac4_mask[32:61]));
               assign iac4_cmprl[t] = &(iu6_ifar[t][32:61] ~^ spr_iac4_q[32:61]);
               assign iac1_cmpr[t] = iac1_cmprl[t] & (iac1_cmprh[t] | ~msr_cm_q);
               assign iac2_cmpr[t] = iac2_cmprl[t] & (iac2_cmprh[t] | ~msr_cm_q);
               assign iac3_cmpr[t] = iac3_cmprl[t] & (iac3_cmprh[t] | ~msr_cm_q);
               assign iac4_cmpr[t] = iac4_cmprl[t] & (iac4_cmprh[t] | ~msr_cm_q);
            end

            if (`EFF_IFAR_ARCH <= 32)		// ui=62-eff_ifar
            begin : iac_cmprh_gen1
               assign iac1_cmprl[t] = &((iu6_ifar[t][62-`EFF_IFAR_ARCH:61] ~^ spr_iac1_q[62-`EFF_IFAR_ARCH:61]) | (~iac2_mask[62-`EFF_IFAR_ARCH:61]));
               assign iac2_cmprl[t] = &(iu6_ifar[t][62-`EFF_IFAR_ARCH:61] ~^ spr_iac2_q[62-`EFF_IFAR_ARCH:61]);
               assign iac3_cmprl[t] = &((iu6_ifar[t][62-`EFF_IFAR_ARCH:61] ~^ spr_iac3_q[62-`EFF_IFAR_ARCH:61]) | (~iac4_mask[62-`EFF_IFAR_ARCH:61]));
               assign iac4_cmprl[t] = &(iu6_ifar[t][62-`EFF_IFAR_ARCH:61] ~^ spr_iac4_q[62-`EFF_IFAR_ARCH:61]);
               assign iac1_cmpr[t] = iac1_cmprl[t];
               assign iac2_cmpr[t] = iac2_cmprl[t];
               assign iac3_cmpr[t] = iac3_cmprl[t];
               assign iac4_cmpr[t] = iac4_cmprl[t];
            end

            assign iac1_cmpr_sel[t] = (iac1_cmpr[t] & iac1_en_q);
            assign iac2_cmpr_sel[t] = (dbcr1_iac12m_q == 1'b0) ? (iac2_cmpr[t] & iac2_en_q) :
                                      (iac1_cmpr[t] & iac2_en_q);
            assign iac3_cmpr_sel[t] = (iac3_cmpr[t] & iac3_en_q);
            assign iac4_cmpr_sel[t] = (dbcr1_iac34m_q == 1'b0) ? (iac4_cmpr[t] & iac4_en_q) :
                                      (iac3_cmpr[t] & iac4_en_q);
         end
      end
   endgenerate

   assign ivc_cmpr_sel[0] = iu6_i0_match_q & dbcr3_ivc_q;
   assign ivc_cmpr_sel[1] = iu6_i1_match_q & dbcr3_ivc_q;

   assign ext_dbg_stop_d = dbcr0_edm_q & ((pc_iu_dbg_action_q == 3'b010) | (pc_iu_dbg_action_q == 3'b011) | (pc_iu_dbg_action_q == 3'b110) | (pc_iu_dbg_action_q == 3'b111));
   assign ext_dbg_stop_other_d = dbcr0_edm_q & ((pc_iu_dbg_action_q == 3'b011) | (pc_iu_dbg_action_q == 3'b111));
   assign ext_dbg_act_err_d = dbcr0_edm_q & (pc_iu_dbg_action_q == 3'b100);
   assign ext_dbg_act_ext_d = dbcr0_edm_q & ((pc_iu_dbg_action_q == 3'b101) | (pc_iu_dbg_action_q == 3'b110) | (pc_iu_dbg_action_q == 3'b111));
   assign iu6_dbg_flush_en[0] = dbg_flush_en & (~(iu6_i0_is_sc_q | iu6_i0_is_sc_hyp_q | iu6_i0_is_ehpriv_q | iu6_i0_is_attn_q));
   assign iu6_dbg_flush_en[1] = dbg_flush_en & (~(iu6_i1_is_sc_q | iu6_i1_is_sc_hyp_q | iu6_i1_is_ehpriv_q | iu6_i1_is_attn_q));
   assign dbg_event_en_d = (~(epcr_duvd_q & (~msr_gs_q) & (~msr_pr_q)));
   assign dbg_int_en_d = msr_de_q & dbcr0_idm_q & (~ext_dbg_stop_q);		// shouldn't stop be replaced with edm
   assign dbg_flush_en = (msr_de_q & dbcr0_idm_q) | ext_dbg_stop_q;

   assign iu6_uc_hold_rollover_d = (iu6_uc_hold_rollover_q | (iu6_i0_rollover_q & iu6_i0_ucode_q == 3'b010) | (iu6_i1_rollover_q & iu6_i1_ucode_q == 3'b010)) &
                                   (~(cp3_flush_q & (~(cp_flush_into_uc_int))));

   assign ret_sel[0] = (iu6_i0_is_rfi_q | iu6_i0_is_rfgi_q) & dbcr0_ret_q;
   assign ret_sel[1] = (iu6_i1_is_rfi_q | iu6_i1_is_rfgi_q) & dbcr0_ret_q;

   assign ude_dbg_event = (msr_de_q & dbcr0_idm_q & dbg_event_en_q & uncond_dbg_event_q);
   assign iu_xu_dbsr_ude_int = ((~msr_de_q | ~dbcr0_idm_q) & dbg_event_en_q & uncond_dbg_event_q);
   assign iu_xu_dbsr_ude = iu_xu_dbsr_ude_int;
   assign iu_xu_dbsr_ide = (~msr_de_q & dbg_event_en_q & uncond_dbg_event_q);
   assign icmp_dbg_event[0] = (msr_de_q & dbg_event_en_q & dbcr0_icmp_q & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b101));
   assign icmp_dbg_event[1] = (msr_de_q & dbg_event_en_q & dbcr0_icmp_q & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b101));
   assign iac1_dbg_event[0] = (dbg_event_en_q & iac1_cmpr_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign iac1_dbg_event[1] = (dbg_event_en_q & iac1_cmpr_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign iac2_dbg_event[0] = (dbg_event_en_q & iac2_cmpr_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign iac2_dbg_event[1] = (dbg_event_en_q & iac2_cmpr_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign iac3_dbg_event[0] = (dbg_event_en_q & iac3_cmpr_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign iac3_dbg_event[1] = (dbg_event_en_q & iac3_cmpr_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign iac4_dbg_event[0] = (dbg_event_en_q & iac4_cmpr_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign iac4_dbg_event[1] = (dbg_event_en_q & iac4_cmpr_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign dac1r_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[0] & dacr_dbg_event[0]);
   assign dac1r_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[0] & dacr_dbg_event[1]);
   assign dac1w_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[0] & ~dacr_dbg_event[0]);
   assign dac1w_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[0] & ~dacr_dbg_event[1]);
   assign dac2r_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[1] & dacr_dbg_event[0]);
   assign dac2r_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[1] & dacr_dbg_event[1]);
   assign dac2w_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[1] & ~dacr_dbg_event[0]);
   assign dac2w_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[1] & ~dacr_dbg_event[1]);
   assign dac3r_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[2] & dacr_dbg_event[0]);
   assign dac3r_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[2] & dacr_dbg_event[1]);
   assign dac3w_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[2] & ~dacr_dbg_event[0]);
   assign dac3w_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[2] & ~dacr_dbg_event[1]);
   assign dac4r_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[3] & dacr_dbg_event[0]);
   assign dac4r_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[3] & dacr_dbg_event[1]);
   assign dac4w_dbg_event[0] = (dbg_event_en_q & lq0_dacrw_q[3] & ~dacr_dbg_event[0]);
   assign dac4w_dbg_event[1] = (dbg_event_en_q & lq1_dacrw_q[3] & ~dacr_dbg_event[1]);
   assign dacr_dbg_event[0] = (dbg_event_en_q & lq0_dacr_type_q);
   assign dacr_dbg_event[1] = (dbg_event_en_q & lq1_dacr_type_q);
   assign rfi_dbg_event[0] = (dbg_event_en_q & ret_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign rfi_dbg_event[1] = (dbg_event_en_q & ret_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign ivc_dbg_event[0] = (dbg_event_en_q & ivc_cmpr_sel[0] & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b010));
   assign ivc_dbg_event[1] = (dbg_event_en_q & ivc_cmpr_sel[1] & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b010));
   assign trap_dbg_event = dbg_event_en_q & (xu_exception_val_q & xu_exception_q == 5'b01110) & dbcr0_trap_q;
   assign iu_irpt_dbg_event[0] = (dbg_event_en_q & iu6_i0_exception_val & dbcr0_irpt_q);
   assign iu_irpt_dbg_event[1] = (dbg_event_en_q & iu6_i1_exception_val & dbcr0_irpt_q);
   assign xu_irpt_dbg_event = (dbg_event_en_q & xu_exception_val_q & dbcr0_irpt_q);
   assign axu0_irpt_dbg_event = (dbg_event_en_q & axu0_exception_val_q & dbcr0_irpt_q);
   assign axu1_irpt_dbg_event = (dbg_event_en_q & axu1_exception_val_q & dbcr0_irpt_q);
   assign lq0_irpt_dbg_event = (dbg_event_en_q & lq0_exception_val_q & dbcr0_irpt_q);
   assign lq1_irpt_dbg_event = (dbg_event_en_q & lq1_exception_val_q & dbcr0_irpt_q);
   assign brt_dbg_event = msr_de_q & dbg_event_en_q & (br_execute_vld_q & br_taken_q) & dbcr0_brt_q;
   assign iac_i0_n_flush = (iac1_dbg_event[0] | iac2_dbg_event[0] | iac3_dbg_event[0] | iac4_dbg_event[0] | ivc_dbg_event[0]) & dbg_flush_en;
   assign iac_i1_n_flush = (iac1_dbg_event[1] | iac2_dbg_event[1] | iac3_dbg_event[1] | iac4_dbg_event[1] | ivc_dbg_event[1]) & dbg_flush_en;
   assign dac_lq0_n_flush = dac1r_dbg_event[0] | dac1w_dbg_event[0] | dac2r_dbg_event[0] | dac2w_dbg_event[0] |
                            dac3r_dbg_event[0] | dac3w_dbg_event[0] | dac4r_dbg_event[0] | dac4w_dbg_event[0];
   assign dac_lq1_n_flush = dac1r_dbg_event[1] | dac1w_dbg_event[1] | dac2r_dbg_event[1] | dac2w_dbg_event[1] |
                            dac3r_dbg_event[1] | dac3w_dbg_event[1] | dac4r_dbg_event[1] | dac4w_dbg_event[1];
   assign icmp_enable = dbg_event_en_q & dbcr0_icmp_q;
   assign irpt_enable = dbg_event_en_q & dbcr0_irpt_q;

   assign iu7_i0_is_folded_d = iu6_i0_is_folded_q | iac_i0_n_flush;
   assign iu7_i1_is_folded_d = iu6_i1_is_folded_q | iac_i1_n_flush;

   //-----------------------------------------------------------------------------
   // IU ERROR Calculations and Folded ops
   //-----------------------------------------------------------------------------
   //Machine Check         I-ERAT Parity Error                     N	iu_err = "101"          0
   //Machine Check         I-Side L2 ECC error                     N	iu_err = "010"          1
   //Machine Check         IERAT Multi-hit Error                   N	iu_err = "110"          2
   //Debug                 Instruction Address Compare Event	N	iu_cp_eff_match         3
   //Debug                 Instruction Value Compare Event	Yes	N	iu_cp_value_match	4
   //Instruction           TLB	ERAT Miss			N	iu_err = "111"          5
   //Instruction Storage	Execution Access Violation		N	iu_err = "100"          6
   //Priviledge                                                    N                               7  removed
   //Hyper Priviledge                                              N                               8  removed
   //System Call           System Call                             NP1	sc                      9
   //System Call           System Call Hypervisor                  NP1	sc_hyp                  10
   //Program               Unimplemented Op                        N  	valop = '0'             11
   //Program               Unimplemented SC                        N  	sc_ill                  12


   always @(*)
   begin: iu6_i0_exec_proc
      iu6_i0_exception_val <= 1'b0;
      iu6_i0_exception <= 4'b0000;
      iu6_i0_n_flush <= (iu6_dbg_flush_en[0] & (iac1_dbg_event[0] | iac2_dbg_event[0] | iac3_dbg_event[0] | iac4_dbg_event[0] | ivc_dbg_event[0] | rfi_dbg_event[0])) & (~(iu6_i0_isram_q));
      iu6_i0_np1_flush <= (((iu6_dbg_flush_en[0] & dbcr0_icmp_q) | ((xu_iu_single_instr_q | pc_iu_step_q) & ~iu6_i0_fuse_nop_q)) & (iu6_i0_ucode_q == 3'b000 | iu6_i0_ucode_q == 3'b101)) |
                          (iu6_i0_rollover_q & (~(iu6_i0_ucode_q == 3'b010 | iu6_i0_ucode_q == 3'b100))) |
                          (iu6_uc_hold_rollover_q & iu6_i0_ucode_q == 3'b101) |
                          iu6_i0_is_np1_flush_q;

      if (iu6_i0_error_q == 3'b101)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0000;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b010)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0001;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b110)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0010;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b111 & ccr2_mmu_mode_q == 1'b1 & iu6_i0_isram_q == 1'b0)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0101;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b111 & ccr2_mmu_mode_q == 1'b0 & iu_nonspec_q == 1'b1 & iu6_i0_isram_q == 1'b0)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0101;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b111 & ccr2_mmu_mode_q == 1'b0 & iu_nonspec_q == 1'b0 & iu6_i0_isram_q == 1'b0)
      begin
         iu6_i0_exception_val <= 1'b0;
         iu6_i0_exception <= 4'b0000;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b111 & iu6_i0_isram_q == 1'b1)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b1111;
         iu6_i0_n_flush <= 1'b1;
      end
      else if (iu6_i0_error_q == 3'b100)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0110;
         iu6_i0_n_flush <= 1'b1;
      end
      else if ((iu6_i0_is_rfi_q == 1'b1 | iu6_i0_is_rfci_q == 1'b1 | iu6_i0_is_rfmci_q == 1'b1 | iu6_i0_is_rfgi_q == 1'b1) & msr_pr_q == 1'b1)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b0111;
         iu6_i0_n_flush <= 1'b1;
      end
      else if ((iu6_i0_is_rfci_q == 1'b1 | iu6_i0_is_rfmci_q == 1'b1) & msr_gs_q == 1'b1)
      begin
         iu6_i0_exception_val <= 1'b1;
         iu6_i0_exception <= 4'b1000;
         iu6_i0_n_flush <= 1'b1;
      end
      else
         if (iu6_i0_is_sc_q == 1'b1)
         begin
            iu6_i0_exception_val <= 1'b1;
            iu6_i0_exception <= 4'b1001;
            iu6_i0_np1_flush <= 1'b1;
         end
         else if (iu6_i0_is_sc_hyp_q == 1'b1)
         begin
            iu6_i0_exception_val <= 1'b1;
            iu6_i0_exception <= 4'b1010;
            iu6_i0_np1_flush <= 1'b1;
         end
         else if (iu6_i0_ucode_q[1] == 1'b1 & ccr2_ucode_dis_q == 1'b1)
         begin
            iu6_i0_exception_val <= 1'b1;
            iu6_i0_exception <= 4'b1011;
            iu6_i0_n_flush <= 1'b1;
         end
         else if (iu6_i0_is_sc_ill_q == 1'b1 | iu6_i0_is_dcr_ill_q == 1'b1)
         begin
            iu6_i0_exception_val <= 1'b1;
            iu6_i0_exception <= 4'b1100;
            iu6_i0_n_flush <= 1'b1;
         end
         else if (iu6_i0_is_isync_q == 1'b1)
            iu6_i0_np1_flush <= 1'b1;
         else if (iu6_i0_is_rfi_q == 1'b1 | iu6_i0_is_rfci_q == 1'b1 | iu6_i0_is_rfmci_q == 1'b1 | iu6_i0_is_rfgi_q == 1'b1)
            iu6_i0_np1_flush <= 1'b1;
         else if (iu6_i0_valop_q == 1'b0)
         begin
            iu6_i0_exception_val <= 1'b1;
            iu6_i0_exception <= 4'b1100;
            iu6_i0_n_flush <= 1'b1;
         end
   end

   always @(*)
   begin: iu6_i1_exec_proc
      iu6_i1_exception_val <= 1'b0;
      iu6_i1_exception <= 4'b0000;
      iu6_i1_n_flush <= (iu6_dbg_flush_en[1] & (iac1_dbg_event[1] | iac2_dbg_event[1] | iac3_dbg_event[1] | iac4_dbg_event[1] | ivc_dbg_event[1] | rfi_dbg_event[1])) & (~(iu6_i1_isram_q));
      iu6_i1_np1_flush <= (((iu6_dbg_flush_en[1] & dbcr0_icmp_q) | ((xu_iu_single_instr_q | pc_iu_step_q) & ~iu6_i1_fuse_nop_q)) & (iu6_i1_ucode_q == 3'b000 | iu6_i1_ucode_q == 3'b101)) |
                          (iu6_i1_rollover_q & (~(iu6_i1_ucode_q == 3'b010 | iu6_i1_ucode_q == 3'b100))) |
                          (iu6_uc_hold_rollover_q & iu6_i1_ucode_q == 3'b101) |
                          iu6_i1_is_np1_flush_q;

      if (iu6_i1_error_q == 3'b101)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0000;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b010)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0001;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b110)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0010;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b111 & ccr2_mmu_mode_q == 1'b1 & iu6_i1_isram_q == 1'b0)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0101;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b111 & ccr2_mmu_mode_q == 1'b0 & iu6_i1_isram_q == 1'b0)
      begin
         iu6_i1_exception_val <= 1'b0;
         iu6_i1_exception <= 4'b0000;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b111 & iu6_i1_isram_q == 1'b1)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b1111;
         iu6_i1_n_flush <= 1'b1;
      end
      else if (iu6_i1_error_q == 3'b100)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0110;
         iu6_i1_n_flush <= 1'b1;
      end
      else if ((iu6_i1_is_rfi_q == 1'b1 | iu6_i1_is_rfci_q == 1'b1 | iu6_i1_is_rfmci_q == 1'b1 | iu6_i1_is_rfgi_q == 1'b1) & msr_pr_q == 1'b1)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b0111;
         iu6_i1_n_flush <= 1'b1;
      end
      else if ((iu6_i1_is_rfci_q == 1'b1 | iu6_i1_is_rfmci_q == 1'b1) & msr_gs_q == 1'b1)
      begin
         iu6_i1_exception_val <= 1'b1;
         iu6_i1_exception <= 4'b1000;
         iu6_i1_n_flush <= 1'b1;
      end
      else
         if (iu6_i1_is_sc_q == 1'b1)
         begin
            iu6_i1_exception_val <= 1'b1;
            iu6_i1_exception <= 4'b1001;
            iu6_i1_np1_flush <= 1'b1;
         end
         else if (iu6_i1_is_sc_hyp_q == 1'b1)
         begin
            iu6_i1_exception_val <= 1'b1;
            iu6_i1_exception <= 4'b1010;
            iu6_i1_np1_flush <= 1'b1;
         end
         else if (iu6_i1_ucode_q[1] == 1'b1 & ccr2_ucode_dis_q == 1'b1)
         begin
            iu6_i1_exception_val <= 1'b1;
            iu6_i1_exception <= 4'b1011;
            iu6_i1_n_flush <= 1'b1;
         end
         else if (iu6_i1_is_sc_ill_q == 1'b1 | iu6_i1_is_dcr_ill_q == 1'b1)
         begin
            iu6_i1_exception_val <= 1'b1;
            iu6_i1_exception <= 4'b1100;
            iu6_i1_n_flush <= 1'b1;
         end
         else if (iu6_i1_is_isync_q == 1'b1)
            iu6_i1_np1_flush <= 1'b1;
         else if (iu6_i1_is_rfi_q == 1'b1 | iu6_i1_is_rfci_q == 1'b1 | iu6_i1_is_rfmci_q == 1'b1 | iu6_i1_is_rfgi_q == 1'b1)
            iu6_i1_np1_flush <= 1'b1;
         else if (iu6_i1_valop_q == 1'b0)
         begin
            iu6_i1_exception_val <= 1'b1;
            iu6_i1_exception <= 4'b1100;
            iu6_i1_n_flush <= 1'b1;
         end
   end

   // Create the cp_mm_exept_taken bus which tells mmu info on the exception taken
   assign cp_mm_except_taken_d[0] = (cp_mm_dtlb_miss | cp_mm_dsi | cp_mm_dlrat_miss | cp_mm_dmchk | cp_mm_itlb_miss | cp_mm_isi | cp_mm_ilrat_miss | cp_mm_imchk);
   assign cp_mm_except_taken_d[1] = (cp_mm_dtlb_miss | cp_mm_dsi | cp_mm_dlrat_miss | cp_mm_dmchk);
   assign cp_mm_except_taken_d[2] = (cp_mm_itlb_miss  | cp_mm_dtlb_miss);
   assign cp_mm_except_taken_d[3] = (cp_mm_isi        | cp_mm_dsi);
   assign cp_mm_except_taken_d[4] = (cp_mm_ilrat_miss | cp_mm_dlrat_miss);
   assign cp_mm_except_taken_d[5] = (cp_mm_imchk | cp_mm_dmchk);


   assign cp_mm_except_taken = cp_mm_except_taken_q;

   //-----------------------------------------------------------------------------
   // I0 Assignments
   //-----------------------------------------------------------------------------
   assign iu_lq_recirc_val = iu_lq_recirc_val_q;
   assign cp2_i0_completed = cp2_i0_complete_q;
   assign cp2_i1_completed = cp2_i1_complete_q;
   assign cp2_i0_bp_pred = cp2_i0_bp_pred_q;
   assign cp2_i1_bp_pred = cp2_i1_bp_pred_q;
   assign cp2_i0_br_pred = cp2_i0_br_pred_q;
   assign cp2_i1_br_pred = cp2_i1_br_pred_q;
   assign cp2_i0_bta = ({`EFF_IFAR_WIDTH{~select_i0_bta}} & cp2_i0_bp_bta) |
                       ({`EFF_IFAR_WIDTH{select_i0_bta}} & cp2_i_bta_q[62 - `EFF_IFAR_WIDTH:61]);
   assign cp2_i1_bta = ({`EFF_IFAR_WIDTH{~select_i1_bta}} & cp2_i1_bp_bta) |
                       ({`EFF_IFAR_WIDTH{select_i1_bta}} & cp2_i_bta_q[62 - `EFF_IFAR_WIDTH:61]);
   assign cp0_i0_completed_itag = cp0_i0_itag[1:`ITAG_SIZE_ENC - 1];
   assign cp0_i1_completed_itag = cp0_i1_itag[1:`ITAG_SIZE_ENC - 1];

   assign dis_mm_mchk = ((~xu_iu_xucr4_mmu_mchk_q) & (~ccr2_mmu_mode_q));


   //-----------------------------------------------
   // performance events
   //-----------------------------------------------
   assign cp_events_en = (pc_iu_event_count_mode[0] &  xu_iu_msr_pr                ) |	//problem state
                         (pc_iu_event_count_mode[1] & ~xu_iu_msr_pr &  xu_iu_msr_gs) |	//guest supervisor state
                         (pc_iu_event_count_mode[2] & ~xu_iu_msr_pr & ~xu_iu_msr_gs) ;	//hypervisor state

   // events are set here
   // Question: Should I be gating the speculative events based on pc_iu_event_count_mode? If they are already being
   //           gated in the units, then it should not be needed.
   assign   cp_events_in = ({1'b0, cp2_i0_perf_events_q, 11'b00000000000} & {16{cp_events_en}});

  // we are discussing how to handle the i1 events.  Right now I think we are going to have
  // a second 4 bits per thread which will be added to the corresponding bit of the main event bus
  // to count events which can happen two per cycle.




   tri_event_mux1t #(.EVENTS_IN(16), .EVENTS_OUT(4)) iuq_cp_perf(
       .vd(vdd),
       .gd(gnd),
       .select_bits(spr_cp_perf_event_mux_ctrls),
       .unit_events_in(cp_events_in[1:15]),
       .event_bus_in(event_bus_in),
       .event_bus_out(event_bus_out_d)
   );

   assign event_bus_out = event_bus_out_q;


   //-----------------------------------------------
   // Latch Instances
   //-----------------------------------------------
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-1), .INIT(0), .NEEDS_SRESET(1)) iu6_i0_itag_latch(
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
      .scin(siv[iu6_i0_itag_offset:iu6_i0_itag_offset + `ITAG_SIZE_ENC - 2]),
      .scout(sov[iu6_i0_itag_offset:iu6_i0_itag_offset + `ITAG_SIZE_ENC - 2]),
      .din(rn_cp_iu6_i0_itag),
      .dout(iu6_i0_itag_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC-1), .INIT(1), .NEEDS_SRESET(1)) iu6_i1_itag_latch(
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
      .scin(siv[iu6_i1_itag_offset:iu6_i1_itag_offset + `ITAG_SIZE_ENC - 2]),
      .scout(sov[iu6_i1_itag_offset:iu6_i1_itag_offset + `ITAG_SIZE_ENC - 2]),
      .din(rn_cp_iu6_i1_itag),
      .dout(iu6_i1_itag_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp1_i0_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i0_itag_offset:cp1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp1_i0_itag_offset:cp1_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp0_i0_itag),
      .dout(cp1_i0_itag_q)
   );

   tri_rlmreg_p #(.WIDTH(1), .INIT(1), .NEEDS_SRESET(1)) cp1_i0_ptr0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i0_ptr_offset:cp1_i0_ptr_offset]),
      .scout(sov[cp1_i0_ptr_offset:cp1_i0_ptr_offset]),
      .din(cp0_i0_ptr[0:0]),
      .dout(cp1_i0_ptr_q[0:0])
   );

   tri_rlmreg_p #(.WIDTH((`CPL_Q_DEPTH - 1)), .INIT(0), .NEEDS_SRESET(1)) cp1_i0_ptr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i0_ptr_offset + 1:cp1_i0_ptr_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_i0_ptr_offset + 1:cp1_i0_ptr_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_i0_ptr[1:`CPL_Q_DEPTH - 1]),
      .dout(cp1_i0_ptr_q[1:`CPL_Q_DEPTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_i0_complete_q),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_itag_offset:cp2_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp2_i0_itag_offset:cp2_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp1_i0_itag_q),
      .dout(cp2_i0_itag_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(1), .NEEDS_SRESET(1)) cp1_i1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i1_itag_offset:cp1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp1_i1_itag_offset:cp1_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp0_i1_itag),
      .dout(cp1_i1_itag_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(1), .NEEDS_SRESET(1)) cp1_i1_ptr0_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i1_ptr_offset:cp1_i1_ptr_offset + 1]),
      .scout(sov[cp1_i1_ptr_offset:cp1_i1_ptr_offset + 1]),
      .din(cp0_i1_ptr[0:1]),
      .dout(cp1_i1_ptr_q[0:1])
   );

   tri_rlmreg_p #(.WIDTH((`CPL_Q_DEPTH - 2)), .INIT(0), .NEEDS_SRESET(1)) cp1_i1_ptr1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_complete),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_i1_ptr_offset + 2:cp1_i1_ptr_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_i1_ptr_offset + 2:cp1_i1_ptr_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_i1_ptr[2:`CPL_Q_DEPTH - 1]),
      .dout(cp1_i1_ptr_q[2:`CPL_Q_DEPTH - 1])
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(1), .NEEDS_SRESET(1)) cp2_i1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_i0_complete_q),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_itag_offset:cp2_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp2_i1_itag_offset:cp2_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp1_i1_itag_q),
      .dout(cp2_i1_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_async_int_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp2_async_int_val_offset]),
      .scout(sov[cp2_async_int_val_offset]),
      .din(cp1_async_int_val),
      .dout(cp2_async_int_val_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(1), .NEEDS_SRESET(1)) cp2_async_int_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_async_int_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp2_async_int_offset:cp2_async_int_offset + 32 - 1]),
      .scout(sov[cp2_async_int_offset:cp2_async_int_offset + 32 - 1]),
      .din(cp1_async_int),
      .dout(cp2_async_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_completed_latch(
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
      .scin(siv[cp2_i0_completed_offset]),
      .scout(sov[cp2_i0_completed_offset]),
      .din(cp1_i0_complete),
      .dout(cp2_i0_complete_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_completed_latch(
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
      .scin(siv[cp2_i1_completed_offset]),
      .scout(sov[cp2_i1_completed_offset]),
      .din(cp1_i1_complete),
      .dout(cp2_i1_complete_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_np1_flush_latch(
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
      .scin(siv[cp2_i0_np1_flush_offset]),
      .scout(sov[cp2_i0_np1_flush_offset]),
      .din(cp1_i0_np1_flush),
      .dout(cp2_i0_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_np1_flush_latch(
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
      .scin(siv[cp2_i1_np1_flush_offset]),
      .scout(sov[cp2_i1_np1_flush_offset]),
      .din(cp1_i1_np1_flush),
      .dout(cp2_i1_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_n_np1_flush_latch(
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
      .scin(siv[cp2_i0_n_np1_flush_offset]),
      .scout(sov[cp2_i0_n_np1_flush_offset]),
      .din(cp1_i0_n_np1_flush),
      .dout(cp2_i0_n_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_n_np1_flush_latch(
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
      .scin(siv[cp2_i1_n_np1_flush_offset]),
      .scout(sov[cp2_i1_n_np1_flush_offset]),
      .din(cp1_i1_n_np1_flush),
      .dout(cp2_i1_n_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_bp_pred_latch(
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
      .scin(siv[cp2_i0_bp_pred_offset]),
      .scout(sov[cp2_i0_bp_pred_offset]),
      .din(cp1_i0_bp_pred),
      .dout(cp2_i0_bp_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_bp_pred_latch(
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
      .scin(siv[cp2_i1_bp_pred_offset]),
      .scout(sov[cp2_i1_bp_pred_offset]),
      .din(cp1_i1_bp_pred),
      .dout(cp2_i1_bp_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_br_pred_latch(
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
      .scin(siv[cp2_i0_br_pred_offset]),
      .scout(sov[cp2_i0_br_pred_offset]),
      .din(cp1_i0_br_pred),
      .dout(cp2_i0_br_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_br_pred_latch(
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
      .scin(siv[cp2_i1_br_pred_offset]),
      .scout(sov[cp2_i1_br_pred_offset]),
      .din(cp1_i1_br_pred),
      .dout(cp2_i1_br_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_br_miss_latch(
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
      .scin(siv[cp2_i0_br_miss_offset]),
      .scout(sov[cp2_i0_br_miss_offset]),
      .din(cp1_i0_br_miss),
      .dout(cp2_i0_br_miss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_br_miss_latch(
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
      .scin(siv[cp2_i1_br_miss_offset]),
      .scout(sov[cp2_i1_br_miss_offset]),
      .din(cp1_i1_br_miss),
      .dout(cp2_i1_br_miss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_db_val_latch(
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
      .scin(siv[cp2_i0_db_val_offset]),
      .scout(sov[cp2_i0_db_val_offset]),
      .din(cp1_i0_db_val),
      .dout(cp2_i0_db_val_q)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_db_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_db_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_db_events_offset:cp2_i0_db_events_offset + 19 - 1]),
      .scout(sov[cp2_i0_db_events_offset:cp2_i0_db_events_offset + 19 - 1]),
      .din(cp1_i0_db_events),
      .dout(cp2_i0_db_events_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_db_val_latch(
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
      .scin(siv[cp2_i1_db_val_offset]),
      .scout(sov[cp2_i1_db_val_offset]),
      .din(cp1_i1_db_val),
      .dout(cp2_i1_db_val_q)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_db_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i1_db_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_db_events_offset:cp2_i1_db_events_offset + 19 - 1]),
      .scout(sov[cp2_i1_db_events_offset:cp2_i1_db_events_offset + 19 - 1]),
      .din(cp1_i1_db_events),
      .dout(cp2_i1_db_events_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_perf_events_latch(
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
      .scin(siv[cp2_i0_perf_events_offset:cp2_i0_perf_events_offset + 4 - 1]),
      .scout(sov[cp2_i0_perf_events_offset:cp2_i0_perf_events_offset + 4 - 1]),
      .din(cp1_i0_perf_events),
      .dout(cp2_i0_perf_events_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_perf_events_latch(
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
      .scin(siv[cp2_i1_perf_events_offset:cp2_i1_perf_events_offset + 4 - 1]),
      .scout(sov[cp2_i1_perf_events_offset:cp2_i1_perf_events_offset + 4 - 1]),
      .din(cp1_i1_perf_events),
      .dout(cp2_i1_perf_events_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_flush2ucode_latch(
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
      .scin(siv[cp2_i0_flush2ucode_offset]),
      .scout(sov[cp2_i0_flush2ucode_offset]),
      .din(cp1_i0_flush2ucode),
      .dout(cp2_i0_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_flush2ucode_type_latch(
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
      .scin(siv[cp2_i0_flush2ucode_type_offset]),
      .scout(sov[cp2_i0_flush2ucode_type_offset]),
      .din(cp1_i0_flush2ucode_type),
      .dout(cp2_i0_flush2ucode_type_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_flush2ucode_latch(
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
      .scin(siv[cp2_i1_flush2ucode_offset]),
      .scout(sov[cp2_i1_flush2ucode_offset]),
      .din(cp1_i1_flush2ucode),
      .dout(cp2_i1_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_flush2ucode_type_latch(
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
      .scin(siv[cp2_i1_flush2ucode_type_offset]),
      .scout(sov[cp2_i1_flush2ucode_type_offset]),
      .din(cp1_i1_flush2ucode_type),
      .dout(cp2_i1_flush2ucode_type_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) cp2_i_bta_latch(
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
      .scin(siv[cp2_i_bta_offset:cp2_i_bta_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[cp2_i_bta_offset:cp2_i_bta_offset + `EFF_IFAR_ARCH - 1]),
      .din(cp1_i_bta),
      .dout(cp2_i_bta_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_iu_excvec_val_latch(
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
      .scin(siv[cp2_i0_iu_excvec_val_offset]),
      .scout(sov[cp2_i0_iu_excvec_val_offset]),
      .din(cp1_i0_iu_excvec_val),
      .dout(cp2_i0_iu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_iu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_iu_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_iu_excvec_offset:cp2_i0_iu_excvec_offset + 4 - 1]),
      .scout(sov[cp2_i0_iu_excvec_offset:cp2_i0_iu_excvec_offset + 4 - 1]),
      .din(cp1_i0_iu_excvec),
      .dout(cp2_i0_iu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_iu_excvec_val_latch(
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
      .scin(siv[cp2_i1_iu_excvec_val_offset]),
      .scout(sov[cp2_i1_iu_excvec_val_offset]),
      .din(cp1_i1_iu_excvec_val),
      .dout(cp2_i1_iu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_iu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i1_iu_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_iu_excvec_offset:cp2_i1_iu_excvec_offset + 4 - 1]),
      .scout(sov[cp2_i1_iu_excvec_offset:cp2_i1_iu_excvec_offset + 4 - 1]),
      .din(cp1_i1_iu_excvec),
      .dout(cp2_i1_iu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_lq_excvec_val_latch(
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
      .scin(siv[cp2_i0_lq_excvec_val_offset]),
      .scout(sov[cp2_i0_lq_excvec_val_offset]),
      .din(cp1_i0_lq_excvec_val),
      .dout(cp2_i0_lq_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_lq_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_lq_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_lq_excvec_offset:cp2_i0_lq_excvec_offset + 6 - 1]),
      .scout(sov[cp2_i0_lq_excvec_offset:cp2_i0_lq_excvec_offset + 6 - 1]),
      .din(cp1_i0_lq_excvec),
      .dout(cp2_i0_lq_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_lq_excvec_val_latch(
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
      .scin(siv[cp2_i1_lq_excvec_val_offset]),
      .scout(sov[cp2_i1_lq_excvec_val_offset]),
      .din(cp1_i1_lq_excvec_val),
      .dout(cp2_i1_lq_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_lq_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i1_lq_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_lq_excvec_offset:cp2_i1_lq_excvec_offset + 6 - 1]),
      .scout(sov[cp2_i1_lq_excvec_offset:cp2_i1_lq_excvec_offset + 6 - 1]),
      .din(cp1_i1_lq_excvec),
      .dout(cp2_i1_lq_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_xu_excvec_val_latch(
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
      .scin(siv[cp2_i0_xu_excvec_val_offset]),
      .scout(sov[cp2_i0_xu_excvec_val_offset]),
      .din(cp1_i0_xu_excvec_val),
      .dout(cp2_i0_xu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_xu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i0_xu_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_xu_excvec_offset:cp2_i0_xu_excvec_offset + 5 - 1]),
      .scout(sov[cp2_i0_xu_excvec_offset:cp2_i0_xu_excvec_offset + 5 - 1]),
      .din(cp1_i0_xu_excvec),
      .dout(cp2_i0_xu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_xu_excvec_val_latch(
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
      .scin(siv[cp2_i1_xu_excvec_val_offset]),
      .scout(sov[cp2_i1_xu_excvec_val_offset]),
      .din(cp1_i1_xu_excvec_val),
      .dout(cp2_i1_xu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_xu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp1_i1_xu_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_xu_excvec_offset:cp2_i1_xu_excvec_offset + 5 - 1]),
      .scout(sov[cp2_i1_xu_excvec_offset:cp2_i1_xu_excvec_offset + 5 - 1]),
      .din(cp1_i1_xu_excvec),
      .dout(cp2_i1_xu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i0_axu_excvec_val_latch(
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
      .scin(siv[cp2_i0_axu_excvec_val_offset]),
      .scout(sov[cp2_i0_axu_excvec_val_offset]),
      .din(cp1_i0_axu_excvec_val),
      .dout(cp2_i0_axu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i0_axu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),		// Has to be tiup because axu doesn't need a valid to have a exception
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i0_axu_excvec_offset:cp2_i0_axu_excvec_offset + 4 - 1]),
      .scout(sov[cp2_i0_axu_excvec_offset:cp2_i0_axu_excvec_offset + 4 - 1]),
      .din(cp1_i0_axu_excvec),
      .dout(cp2_i0_axu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_i1_axu_excvec_val_latch(
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
      .scin(siv[cp2_i1_axu_excvec_val_offset]),
      .scout(sov[cp2_i1_axu_excvec_val_offset]),
      .din(cp1_i1_axu_excvec_val),
      .dout(cp2_i1_axu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp2_i1_axu_excvec_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),		// Has to be tiup because axu doesn't need a valid to have a exception
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp2_i1_axu_excvec_offset:cp2_i1_axu_excvec_offset + 4 - 1]),
      .scout(sov[cp2_i1_axu_excvec_offset:cp2_i1_axu_excvec_offset + 4 - 1]),
      .din(cp1_i1_axu_excvec),
      .dout(cp2_i1_axu_excvec_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_executed_latch(
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
      .scin(siv[cp1_executed_offset:cp1_executed_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_executed_offset:cp1_executed_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_executed),
      .dout(cp1_executed_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_dispatched_latch(
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
      .scin(siv[cp1_dispatched_offset:cp1_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_dispatched_offset:cp1_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_dispatched),
      .dout(cp1_dispatched_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(excvec_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_n_flush_offset:cp1_n_flush_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_n_flush_offset:cp1_n_flush_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_n_flush),
      .dout(cp1_n_flush_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(excvec_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_np1_flush_offset:cp1_np1_flush_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_np1_flush_offset:cp1_np1_flush_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_np1_flush),
      .dout(cp1_np1_flush_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_n_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(excvec_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_n_np1_flush_offset:cp1_n_np1_flush_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_n_np1_flush_offset:cp1_n_np1_flush_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_n_np1_flush),
      .dout(cp1_n_np1_flush_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_flush2ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(excvec_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_flush2ucode_offset:cp1_flush2ucode_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_flush2ucode_offset:cp1_flush2ucode_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_flush2ucode),
      .dout(cp1_flush2ucode_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_flush2ucode_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(excvec_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_flush2ucode_type_offset:cp1_flush2ucode_type_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_flush2ucode_type_offset:cp1_flush2ucode_type_offset + `CPL_Q_DEPTH - 1]),
      .din(cp0_flush2ucode_type),
      .dout(cp1_flush2ucode_type_q)
   );

   generate
      begin : xhdl5
         genvar i;
         for (i = 0; i <= `CPL_Q_DEPTH - 1; i = i + 1)
         begin : q_depth_gen
            tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp1_perf_events_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_perf_events_offset + 4 * i:cp1_perf_events_offset + 4 * (i + 1) - 1]),
               .scout(sov[cp1_perf_events_offset + 4 * i:cp1_perf_events_offset + 4 * (i + 1) - 1]),
               .din(cp0_perf_events[i]),
               .dout(cp1_perf_events_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_iu_excvec_val_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_iu_excvec_val_offset + i]),
               .scout(sov[cp1_iu_excvec_val_offset + i]),
               .din(cp0_iu_excvec_val[i]),
               .dout(cp1_iu_excvec_val_q[i])
            );

            tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp1_iu_excvec_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_iu_excvec_offset + 4 * i:cp1_iu_excvec_offset + 4 * (i + 1) - 1]),
               .scout(sov[cp1_iu_excvec_offset + 4 * i:cp1_iu_excvec_offset + 4 * (i + 1) - 1]),
               .din(cp0_iu_excvec[i]),
               .dout(cp1_iu_excvec_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_lq_excvec_val_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_lq_excvec_val_offset + i]),
               .scout(sov[cp1_lq_excvec_val_offset + i]),
               .din(cp0_lq_excvec_val[i]),
               .dout(cp1_lq_excvec_val_q[i])
            );

            tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp1_lq_excvec_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_lq_excvec_offset + 6 * i:cp1_lq_excvec_offset + 6 * (i + 1) - 1]),
               .scout(sov[cp1_lq_excvec_offset + 6 * i:cp1_lq_excvec_offset + 6 * (i + 1) - 1]),
               .din(cp0_lq_excvec[i]),
               .dout(cp1_lq_excvec_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_xu_excvec_val_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_xu_excvec_val_offset + i]),
               .scout(sov[cp1_xu_excvec_val_offset + i]),
               .din(cp0_xu_excvec_val[i]),
               .dout(cp1_xu_excvec_val_q[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) cp1_xu_excvec_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_xu_excvec_offset + 5 * i:cp1_xu_excvec_offset + 5 * (i + 1) - 1]),
               .scout(sov[cp1_xu_excvec_offset + 5 * i:cp1_xu_excvec_offset + 5 * (i + 1) - 1]),
               .din(cp0_xu_excvec[i]),
               .dout(cp1_xu_excvec_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_axu_excvec_val_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_axu_excvec_val_offset + i]),
               .scout(sov[cp1_axu_excvec_val_offset + i]),
               .din(cp0_axu_excvec_val[i]),
               .dout(cp1_axu_excvec_val_q[i])
            );

            tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp1_axu_excvec_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_axu_excvec_offset + 4 * i:cp1_axu_excvec_offset + 4 * (i + 1) - 1]),
               .scout(sov[cp1_axu_excvec_offset + 4 * i:cp1_axu_excvec_offset + 4 * (i + 1) - 1]),
               .din(cp0_axu_excvec[i]),
               .dout(cp1_axu_excvec_q[i])
            );

            tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp1_db_events_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_db_events_offset + 19 * i:cp1_db_events_offset + 19 * (i + 1) - 1]),
               .scout(sov[cp1_db_events_offset + 19 * i:cp1_db_events_offset + 19 * (i + 1) - 1]),
               .din(cp0_db_events[i]),
               .dout(cp1_db_events_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_recirc_vld_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_recirc_vld_offset + i]),
               .scout(sov[cp1_recirc_vld_offset + i]),
               .din(cp0_recirc_vld[i]),
               .dout(cp1_recirc_vld_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_async_block_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_async_block_offset + i]),
               .scout(sov[cp1_async_block_offset + i]),
               .din(cp0_async_block[i]),
               .dout(cp1_async_block_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_is_br_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_is_br_offset + i]),
               .scout(sov[cp1_is_br_offset + i]),
               .din(cp0_is_br[i]),
               .dout(cp1_is_br_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_br_add_chk_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_br_add_chk_offset + i]),
               .scout(sov[cp1_br_add_chk_offset + i]),
               .din(cp0_br_add_chk[i]),
               .dout(cp1_br_add_chk_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_bp_pred_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_bp_pred_offset + i]),
               .scout(sov[cp1_bp_pred_offset + i]),
               .din(cp0_bp_pred[i]),
               .dout(cp1_bp_pred_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_br_pred_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_br_pred_offset + i]),
               .scout(sov[cp1_br_pred_offset + i]),
               .din(cp0_br_pred[i]),
               .dout(cp1_br_pred_q[i])
            );

            tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_br_miss_latch(
               .nclk(nclk),
               .vd(vdd),
               .gd(gnd),
               .act(excvec_act_v[i]),
               .d_mode(d_mode_dc),
               .delay_lclkr(delay_lclkr_dc),
               .mpw1_b(mpw1_dc_b),
               .mpw2_b(mpw2_dc_b),
               .thold_b(func_sl_thold_0_b),
               .sg(sg_0),
               .force_t(func_sl_force),
               .scin(siv[cp1_br_miss_offset + i]),
               .scout(sov[cp1_br_miss_offset + i]),
               .din(cp0_br_miss[i]),
               .dout(cp1_br_miss_q[i])
            );
         end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) cp1_br_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp0_br_bta_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_br_bta_offset:cp1_br_bta_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[cp1_br_bta_offset:cp1_br_bta_offset + `EFF_IFAR_ARCH - 1]),
      .din(cp0_br_bta),
      .dout(cp1_br_bta_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp1_br_bta_v_latch(
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
      .scin(siv[cp1_br_bta_v_offset]),
      .scout(sov[cp1_br_bta_v_offset]),
      .din(cp0_br_bta_v),
      .dout(cp1_br_bta_v_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp1_br_bta_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp0_br_bta_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp1_br_bta_itag_offset:cp1_br_bta_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp1_br_bta_itag_offset:cp1_br_bta_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp0_br_bta_itag),
      .dout(cp1_br_bta_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_dispatched_latch(
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
      .scin(siv[cp0_i0_dispatched_offset]),
      .scout(sov[cp0_i0_dispatched_offset]),
      .din(iu6_i0_dispatched_d),
      .dout(iu6_i0_dispatched_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_dispatched_latch(
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
      .scin(siv[cp0_i1_dispatched_offset]),
      .scout(sov[cp0_i1_dispatched_offset]),
      .din(iu6_i1_dispatched_d),
      .dout(iu6_i1_dispatched_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) iu6_i0_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_ifar_offset:cp0_i0_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov[cp0_i0_ifar_offset:cp0_i0_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(rn_cp_iu6_i0_ifar),
      .dout(iu6_i0_ifar_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iu6_i0_ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_ucode_offset:cp0_i0_ucode_offset + 3 - 1]),
      .scout(sov[cp0_i0_ucode_offset:cp0_i0_ucode_offset + 3 - 1]),
      .din(rn_cp_iu6_i0_ucode),
      .dout(iu6_i0_ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_fuse_nop_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_fuse_nop_offset]),
      .scout(sov[cp0_i0_fuse_nop_offset]),
      .din(rn_cp_iu6_i0_fuse_nop),
      .dout(iu6_i0_fuse_nop_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iu6_i0_error_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_error_offset:cp0_i0_error_offset + 3 - 1]),
      .scout(sov[cp0_i0_error_offset:cp0_i0_error_offset + 3 - 1]),
      .din(rn_cp_iu6_i0_error),
      .dout(iu6_i0_error_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_valop_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_valop_offset]),
      .scout(sov[cp0_i0_valop_offset]),
      .din(rn_cp_iu6_i0_valop),
      .dout(iu6_i0_valop_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_rfi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_rfi_offset]),
      .scout(sov[cp0_i0_is_rfi_offset]),
      .din(rn_cp_iu6_i0_is_rfi),
      .dout(iu6_i0_is_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_rfgi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_rfgi_offset]),
      .scout(sov[cp0_i0_is_rfgi_offset]),
      .din(rn_cp_iu6_i0_is_rfgi),
      .dout(iu6_i0_is_rfgi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_rfci_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_rfci_offset]),
      .scout(sov[cp0_i0_is_rfci_offset]),
      .din(rn_cp_iu6_i0_is_rfci),
      .dout(iu6_i0_is_rfci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_rfmci_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_rfmci_offset]),
      .scout(sov[cp0_i0_is_rfmci_offset]),
      .din(rn_cp_iu6_i0_is_rfmci),
      .dout(iu6_i0_is_rfmci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_isync_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_isync_offset]),
      .scout(sov[cp0_i0_is_isync_offset]),
      .din(rn_cp_iu6_i0_is_isync),
      .dout(iu6_i0_is_isync_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_sc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_sc_offset]),
      .scout(sov[cp0_i0_is_sc_offset]),
      .din(rn_cp_iu6_i0_is_sc),
      .dout(iu6_i0_is_sc_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_np1_flush_offset]),
      .scout(sov[cp0_i0_is_np1_flush_offset]),
      .din(rn_cp_iu6_i0_is_np1_flush),
      .dout(iu6_i0_is_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_sc_hyp_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_sc_hyp_offset]),
      .scout(sov[cp0_i0_is_sc_hyp_offset]),
      .din(rn_cp_iu6_i0_is_sc_hyp),
      .dout(iu6_i0_is_sc_hyp_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_sc_ill_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_sc_ill_offset]),
      .scout(sov[cp0_i0_is_sc_ill_offset]),
      .din(rn_cp_iu6_i0_is_sc_ill),
      .dout(iu6_i0_is_sc_ill_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_dcr_ill_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_dcr_ill_offset]),
      .scout(sov[cp0_i0_is_dcr_ill_offset]),
      .din(rn_cp_iu6_i0_is_dcr_ill),
      .dout(iu6_i0_is_dcr_ill_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_attn_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_attn_offset]),
      .scout(sov[cp0_i0_is_attn_offset]),
      .din(rn_cp_iu6_i0_is_attn),
      .dout(iu6_i0_is_attn_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_ehpriv_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_ehpriv_offset]),
      .scout(sov[cp0_i0_is_ehpriv_offset]),
      .din(rn_cp_iu6_i0_is_ehpriv),
      .dout(iu6_i0_is_ehpriv_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_folded_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_folded_offset]),
      .scout(sov[cp0_i0_is_folded_offset]),
      .din(rn_cp_iu6_i0_is_folded),
      .dout(iu6_i0_is_folded_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_async_block_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_async_block_offset]),
      .scout(sov[cp0_i0_async_block_offset]),
      .din(rn_cp_iu6_i0_async_block),
      .dout(iu6_i0_async_block_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_is_br_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_is_br_offset]),
      .scout(sov[cp0_i0_is_br_offset]),
      .din(rn_cp_iu6_i0_is_br),
      .dout(iu6_i0_is_br_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_br_add_chk_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_br_add_chk_offset]),
      .scout(sov[cp0_i0_br_add_chk_offset]),
      .din(rn_cp_iu6_i0_br_add_chk),
      .dout(iu6_i0_br_add_chk_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_bp_pred_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_bp_pred_offset]),
      .scout(sov[cp0_i0_bp_pred_offset]),
      .din(rn_cp_iu6_i0_pred),
      .dout(iu6_i0_bp_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_rollover_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_rollover_offset]),
      .scout(sov[cp0_i0_rollover_offset]),
      .din(rn_cp_iu6_i0_rollover),
      .dout(iu6_i0_rollover_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_isram_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_isram_offset]),
      .scout(sov[cp0_i0_isram_offset]),
      .din(rn_cp_iu6_i0_isram),
      .dout(iu6_i0_isram_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i0_match_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i0_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i0_match_offset]),
      .scout(sov[cp0_i0_match_offset]),
      .din(rn_cp_iu6_i0_match),
      .dout(iu6_i0_match_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) iu6_i1_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_ifar_offset:cp0_i1_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .scout(sov[cp0_i1_ifar_offset:cp0_i1_ifar_offset + `EFF_IFAR_WIDTH - 1]),
      .din(rn_cp_iu6_i1_ifar),
      .dout(iu6_i1_ifar_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iu6_i1_ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_ucode_offset:cp0_i1_ucode_offset + 3 - 1]),
      .scout(sov[cp0_i1_ucode_offset:cp0_i1_ucode_offset + 3 - 1]),
      .din(rn_cp_iu6_i1_ucode),
      .dout(iu6_i1_ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_fuse_nop_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_fuse_nop_offset]),
      .scout(sov[cp0_i1_fuse_nop_offset]),
      .din(rn_cp_iu6_i1_fuse_nop),
      .dout(iu6_i1_fuse_nop_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) iu6_i1_error_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_error_offset:cp0_i1_error_offset + 3 - 1]),
      .scout(sov[cp0_i1_error_offset:cp0_i1_error_offset + 3 - 1]),
      .din(rn_cp_iu6_i1_error),
      .dout(iu6_i1_error_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_valop_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_valop_offset]),
      .scout(sov[cp0_i1_valop_offset]),
      .din(rn_cp_iu6_i1_valop),
      .dout(iu6_i1_valop_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_rfi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_rfi_offset]),
      .scout(sov[cp0_i1_is_rfi_offset]),
      .din(rn_cp_iu6_i1_is_rfi),
      .dout(iu6_i1_is_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_rfgi_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_rfgi_offset]),
      .scout(sov[cp0_i1_is_rfgi_offset]),
      .din(rn_cp_iu6_i1_is_rfgi),
      .dout(iu6_i1_is_rfgi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_rfci_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_rfci_offset]),
      .scout(sov[cp0_i1_is_rfci_offset]),
      .din(rn_cp_iu6_i1_is_rfci),
      .dout(iu6_i1_is_rfci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_rfmci_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_rfmci_offset]),
      .scout(sov[cp0_i1_is_rfmci_offset]),
      .din(rn_cp_iu6_i1_is_rfmci),
      .dout(iu6_i1_is_rfmci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_isync_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_isync_offset]),
      .scout(sov[cp0_i1_is_isync_offset]),
      .din(rn_cp_iu6_i1_is_isync),
      .dout(iu6_i1_is_isync_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_sc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_sc_offset]),
      .scout(sov[cp0_i1_is_sc_offset]),
      .din(rn_cp_iu6_i1_is_sc),
      .dout(iu6_i1_is_sc_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_np1_flush_offset]),
      .scout(sov[cp0_i1_is_np1_flush_offset]),
      .din(rn_cp_iu6_i1_is_np1_flush),
      .dout(iu6_i1_is_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_sc_hyp_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_sc_hyp_offset]),
      .scout(sov[cp0_i1_is_sc_hyp_offset]),
      .din(rn_cp_iu6_i1_is_sc_hyp),
      .dout(iu6_i1_is_sc_hyp_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_sc_ill_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_sc_ill_offset]),
      .scout(sov[cp0_i1_is_sc_ill_offset]),
      .din(rn_cp_iu6_i1_is_sc_ill),
      .dout(iu6_i1_is_sc_ill_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_dcr_ill_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_dcr_ill_offset]),
      .scout(sov[cp0_i1_is_dcr_ill_offset]),
      .din(rn_cp_iu6_i1_is_dcr_ill),
      .dout(iu6_i1_is_dcr_ill_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_attn_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_attn_offset]),
      .scout(sov[cp0_i1_is_attn_offset]),
      .din(rn_cp_iu6_i1_is_attn),
      .dout(iu6_i1_is_attn_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_ehpriv_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_ehpriv_offset]),
      .scout(sov[cp0_i1_is_ehpriv_offset]),
      .din(rn_cp_iu6_i1_is_ehpriv),
      .dout(iu6_i1_is_ehpriv_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_folded_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_folded_offset]),
      .scout(sov[cp0_i1_is_folded_offset]),
      .din(rn_cp_iu6_i1_is_folded),
      .dout(iu6_i1_is_folded_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_async_block_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_async_block_offset]),
      .scout(sov[cp0_i1_async_block_offset]),
      .din(rn_cp_iu6_i1_async_block),
      .dout(iu6_i1_async_block_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_is_br_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_is_br_offset]),
      .scout(sov[cp0_i1_is_br_offset]),
      .din(rn_cp_iu6_i1_is_br),
      .dout(iu6_i1_is_br_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_br_add_chk_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_br_add_chk_offset]),
      .scout(sov[cp0_i1_br_add_chk_offset]),
      .din(rn_cp_iu6_i1_br_add_chk),
      .dout(iu6_i1_br_add_chk_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_bp_pred_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_bp_pred_offset]),
      .scout(sov[cp0_i1_bp_pred_offset]),
      .din(rn_cp_iu6_i1_pred),
      .dout(iu6_i1_bp_pred_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_rollover_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_rollover_offset]),
      .scout(sov[cp0_i1_rollover_offset]),
      .din(rn_cp_iu6_i1_rollover),
      .dout(iu6_i1_rollover_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_isram_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_isram_offset]),
      .scout(sov[cp0_i1_isram_offset]),
      .din(rn_cp_iu6_i1_isram),
      .dout(iu6_i1_isram_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_i1_match_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(rn_cp_iu6_i1_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp0_i1_match_offset]),
      .scout(sov[cp0_i1_match_offset]),
      .din(rn_cp_iu6_i1_match),
      .dout(iu6_i1_match_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu6_uc_hold_rollover_latch(
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
      .scin(siv[cp0_uc_hold_rollover_offset]),
      .scout(sov[cp0_uc_hold_rollover_offset]),
      .din(iu6_uc_hold_rollover_d),
      .dout(iu6_uc_hold_rollover_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_execute_vld_latch(
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
      .scin(siv[lq0_execute_vld_offset]),
      .scout(sov[lq0_execute_vld_offset]),
      .din(lq0_execute_vld_d),
      .dout(lq0_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) lq0_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),		// can gate if I use lq0_iu_execute_vld or lq0_iu_recirc_val
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_itag_offset:lq0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[lq0_itag_offset:lq0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(lq0_iu_itag),
      .dout(lq0_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_n_flush_offset]),
      .scout(sov[lq0_n_flush_offset]),
      .din(lq0_iu_n_flush),
      .dout(lq0_n_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_np1_flush_offset]),
      .scout(sov[lq0_np1_flush_offset]),
      .din(lq0_iu_np1_flush),
      .dout(lq0_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_dacr_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_dacr_type_offset]),
      .scout(sov[lq0_dacr_type_offset]),
      .din(lq0_iu_dacr_type),
      .dout(lq0_dacr_type_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq0_dacrw_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_dacrw_offset:lq0_dacrw_offset + 4 - 1]),
      .scout(sov[lq0_dacrw_offset:lq0_dacrw_offset + 4 - 1]),
      .din(lq0_iu_dacrw),
      .dout(lq0_dacrw_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) lq0_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_instr_offset:lq0_instr_offset + 32 - 1]),
      .scout(sov[lq0_instr_offset:lq0_instr_offset + 32 - 1]),
      .din(lq0_iu_instr),
      .dout(lq0_instr_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH), .INIT(0), .NEEDS_SRESET(1)) lq0_eff_addr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_dear_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_eff_addr_offset:lq0_eff_addr_offset + `GPR_WIDTH - 1]),
      .scout(sov[lq0_eff_addr_offset:lq0_eff_addr_offset + `GPR_WIDTH - 1]),
      .din(lq0_iu_eff_addr),
      .dout(lq0_eff_addr_q)
   );

   assign lq0_exception_val_d = lq0_iu_execute_vld & lq0_iu_exception_val;

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_exception_val_latch(
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
      .scin(siv[lq0_exception_val_offset]),
      .scout(sov[lq0_exception_val_offset]),
      .din(lq0_exception_val_d),
      .dout(lq0_exception_val_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) lq0_exception_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_exception_offset:lq0_exception_offset + 6 - 1]),
      .scout(sov[lq0_exception_offset:lq0_exception_offset + 6 - 1]),
      .din(lq0_iu_exception),
      .dout(lq0_exception_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_flush2ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_flush2ucode_offset]),
      .scout(sov[lq0_flush2ucode_offset]),
      .din(lq0_iu_flush2ucode),
      .dout(lq0_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_flush2ucode_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq0_flush2ucode_type_offset]),
      .scout(sov[lq0_flush2ucode_type_offset]),
      .din(lq0_iu_flush2ucode_type),
      .dout(lq0_flush2ucode_type_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq0_recirc_val_latch(
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
      .scin(siv[lq0_recirc_val_offset]),
      .scout(sov[lq0_recirc_val_offset]),
      .din(lq0_iu_recirc_val),
      .dout(lq0_recirc_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_execute_vld_latch(
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
      .scin(siv[lq1_execute_vld_offset]),
      .scout(sov[lq1_execute_vld_offset]),
      .din(lq1_execute_vld_d),
      .dout(lq1_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) lq1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_itag_offset:lq1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[lq1_itag_offset:lq1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(lq1_iu_itag),
      .dout(lq1_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_n_flush_offset]),
      .scout(sov[lq1_n_flush_offset]),
      .din(lq1_iu_n_flush),
      .dout(lq1_n_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_np1_flush_offset]),
      .scout(sov[lq1_np1_flush_offset]),
      .din(lq1_iu_np1_flush),
      .dout(lq1_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_exception_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_exception_val_offset]),
      .scout(sov[lq1_exception_val_offset]),
      .din(lq1_iu_exception_val),
      .dout(lq1_exception_val_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) lq1_exception_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_exception_offset:lq1_exception_offset + 6 - 1]),
      .scout(sov[lq1_exception_offset:lq1_exception_offset + 6 - 1]),
      .din(lq1_iu_exception),
      .dout(lq1_exception_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lq1_dacr_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_dacr_type_offset]),
      .scout(sov[lq1_dacr_type_offset]),
      .din(lq1_iu_dacr_type),
      .dout(lq1_dacr_type_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq1_dacrw_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_dacrw_offset:lq1_dacrw_offset + 4 - 1]),
      .scout(sov[lq1_dacrw_offset:lq1_dacrw_offset + 4 - 1]),
      .din(lq1_iu_dacrw),
      .dout(lq1_dacrw_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) lq1_perf_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(lq1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[lq1_perf_events_offset:lq1_perf_events_offset + 4 - 1]),
      .scout(sov[lq1_perf_events_offset:lq1_perf_events_offset + 4 - 1]),
      .din(lq1_iu_perf_events),
      .dout(lq1_perf_events_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) br_perf_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(br_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[br_perf_events_offset:br_perf_events_offset + 4 - 1]),
      .scout(sov[br_perf_events_offset:br_perf_events_offset + 4 - 1]),
      .din(br_iu_perf_events),
      .dout(br_perf_events_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) axu0_perf_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_perf_events_offset:axu0_perf_events_offset + 4 - 1]),
      .scout(sov[axu0_perf_events_offset:axu0_perf_events_offset + 4 - 1]),
      .din(axu0_iu_perf_events),
      .dout(axu0_perf_events_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) axu1_perf_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_perf_events_offset:axu1_perf_events_offset + 4 - 1]),
      .scout(sov[axu1_perf_events_offset:axu1_perf_events_offset + 4 - 1]),
      .din(axu1_iu_perf_events),
      .dout(axu1_perf_events_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_execute_vld_latch(
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
      .scin(siv[br_execute_vld_offset]),
      .scout(sov[br_execute_vld_offset]),
      .din(br_execute_vld_d),
      .dout(br_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) br_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(br_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[br_itag_offset:br_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[br_itag_offset:br_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(br_iu_itag),
      .dout(br_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_taken_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(br_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[br_taken_offset]),
      .scout(sov[br_taken_offset]),
      .din(br_iu_taken),
      .dout(br_taken_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) br_redirect_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),		// removed br_iu_execute_vld
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[br_redirect_offset]),
      .scout(sov[br_redirect_offset]),
      .din(br_iu_redirect),
      .dout(br_redirect_q)
   );

   assign br_bta_d = {({`EFF_IFAR_ARCH-30{msr_cm_q}} & br_iu_bta[62 - `EFF_IFAR_ARCH:31]), br_iu_bta[32:61]};

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) br_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(br_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[br_bta_offset:br_bta_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[br_bta_offset:br_bta_offset + `EFF_IFAR_ARCH - 1]),
      .din(br_bta_d),
      .dout(br_bta_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_execute_vld_latch(
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
      .scin(siv[xu_execute_vld_offset]),
      .scout(sov[xu_execute_vld_offset]),
      .din(xu_execute_vld_d),
      .dout(xu_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) xu_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_itag_offset:xu_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[xu_itag_offset:xu_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(xu_iu_itag),
      .dout(xu_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_n_flush_offset]),
      .scout(sov[xu_n_flush_offset]),
      .din(xu_iu_n_flush),
      .dout(xu_n_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_np1_flush_offset]),
      .scout(sov[xu_np1_flush_offset]),
      .din(xu_iu_np1_flush),
      .dout(xu_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_flush2ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_flush2ucode_offset]),
      .scout(sov[xu_flush2ucode_offset]),
      .din(xu_iu_flush2ucode),
      .dout(xu_flush2ucode_q)
   );

   assign xu_exception_val_d = xu_iu_execute_vld & xu_iu_exception_val;

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_exception_val_latch(
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
      .scin(siv[xu_exception_val_offset]),
      .scout(sov[xu_exception_val_offset]),
      .din(xu_exception_val_d),
      .dout(xu_exception_val_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) xu_exception_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_exception_offset:xu_exception_offset + 5 - 1]),
      .scout(sov[xu_exception_offset:xu_exception_offset + 5 - 1]),
      .din(xu_iu_exception),
      .dout(xu_exception_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_mtiar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),		// removed xu_iu_execute_vld because used in branches
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_mtiar_offset]),
      .scout(sov[xu_mtiar_offset]),
      .din(xu_iu_mtiar),
      .dout(xu_mtiar_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) xu_bta_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_bta_offset:xu_bta_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[xu_bta_offset:xu_bta_offset + `EFF_IFAR_ARCH - 1]),
      .din(xu_iu_bta),
      .dout(xu_bta_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) xu_perf_events_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_perf_events_offset:xu_perf_events_offset + 4 - 1]),
      .scout(sov[xu_perf_events_offset:xu_perf_events_offset + 4 - 1]),
      .din(xu_iu_perf_events),
      .dout(xu_perf_events_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu1_execute_vld_latch(
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
      .scin(siv[xu1_execute_vld_offset]),
      .scout(sov[xu1_execute_vld_offset]),
      .din(xu1_execute_vld_d),
      .dout(xu1_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) xu1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(xu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu1_itag_offset:xu1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[xu1_itag_offset:xu1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(xu1_iu_itag),
      .dout(xu1_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_execute_vld_latch(
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
      .scin(siv[axu0_execute_vld_offset]),
      .scout(sov[axu0_execute_vld_offset]),
      .din(axu0_execute_vld_d),
      .dout(axu0_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) axu0_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_itag_offset:axu0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[axu0_itag_offset:axu0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(axu0_iu_itag),
      .dout(axu0_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_n_flush_offset]),
      .scout(sov[axu0_n_flush_offset]),
      .din(axu0_iu_n_flush),
      .dout(axu0_n_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_np1_flush_offset]),
      .scout(sov[axu0_np1_flush_offset]),
      .din(axu0_iu_np1_flush),
      .dout(axu0_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_n_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_n_np1_flush_offset]),
      .scout(sov[axu0_n_np1_flush_offset]),
      .din(axu0_iu_n_np1_flush),
      .dout(axu0_n_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_flush2ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_flush2ucode_offset]),
      .scout(sov[axu0_flush2ucode_offset]),
      .din(axu0_iu_flush2ucode),
      .dout(axu0_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_flush2ucode_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_flush2ucode_type_offset]),
      .scout(sov[axu0_flush2ucode_type_offset]),
      .din(axu0_iu_flush2ucode_type),
      .dout(axu0_flush2ucode_type_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu0_exception_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_exception_val_offset]),
      .scout(sov[axu0_exception_val_offset]),
      .din(axu0_iu_exception_val),
      .dout(axu0_exception_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) axu0_exception_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu0_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu0_exception_offset:axu0_exception_offset + 4 - 1]),
      .scout(sov[axu0_exception_offset:axu0_exception_offset + 4 - 1]),
      .din(axu0_iu_exception),
      .dout(axu0_exception_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_execute_vld_latch(
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
      .scin(siv[axu1_execute_vld_offset]),
      .scout(sov[axu1_execute_vld_offset]),
      .din(axu1_execute_vld_d),
      .dout(axu1_execute_vld_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) axu1_itag_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_itag_offset:axu1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[axu1_itag_offset:axu1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(axu1_iu_itag),
      .dout(axu1_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_n_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_n_flush_offset]),
      .scout(sov[axu1_n_flush_offset]),
      .din(axu1_iu_n_flush),
      .dout(axu1_n_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_np1_flush_offset]),
      .scout(sov[axu1_np1_flush_offset]),
      .din(axu1_iu_np1_flush),
      .dout(axu1_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_n_np1_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_n_np1_flush_offset]),
      .scout(sov[axu1_n_np1_flush_offset]),
      .din(axu1_iu_n_np1_flush),
      .dout(axu1_n_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_flush2ucode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_flush2ucode_offset]),
      .scout(sov[axu1_flush2ucode_offset]),
      .din(axu1_iu_flush2ucode),
      .dout(axu1_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_flush2ucode_type_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_flush2ucode_type_offset]),
      .scout(sov[axu1_flush2ucode_type_offset]),
      .din(axu1_iu_flush2ucode_type),
      .dout(axu1_flush2ucode_type_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) axu1_exception_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_exception_val_offset]),
      .scout(sov[axu1_exception_val_offset]),
      .din(axu1_iu_exception_val),
      .dout(axu1_exception_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) axu1_exception_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(axu1_iu_execute_vld),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[axu1_exception_offset:axu1_exception_offset + 4 - 1]),
      .scout(sov[axu1_exception_offset:axu1_exception_offset + 4 - 1]),
      .din(axu1_iu_exception),
      .dout(axu1_exception_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp3_rfi_latch(
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
      .scin(siv[iu_xu_cp3_rfi_offset]),
      .scout(sov[iu_xu_cp3_rfi_offset]),
      .din(iu_xu_cp2_rfi_d),
      .dout(iu_xu_cp3_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp3_rfgi_latch(
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
      .scin(siv[iu_xu_cp3_rfgi_offset]),
      .scout(sov[iu_xu_cp3_rfgi_offset]),
      .din(iu_xu_cp2_rfgi_d),
      .dout(iu_xu_cp3_rfgi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp3_rfci_latch(
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
      .scin(siv[iu_xu_cp3_rfci_offset]),
      .scout(sov[iu_xu_cp3_rfci_offset]),
      .din(iu_xu_cp2_rfci_d),
      .dout(iu_xu_cp3_rfci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp3_rfmci_latch(
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
      .scin(siv[iu_xu_cp3_rfmci_offset]),
      .scout(sov[iu_xu_cp3_rfmci_offset]),
      .din(iu_xu_cp2_rfmci_d),
      .dout(iu_xu_cp3_rfmci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp4_rfi_latch(
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
      .scin(siv[iu_xu_cp4_rfi_offset]),
      .scout(sov[iu_xu_cp4_rfi_offset]),
      .din(iu_xu_cp3_rfi_q),
      .dout(iu_xu_cp4_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp4_rfgi_latch(
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
      .scin(siv[iu_xu_cp4_rfgi_offset]),
      .scout(sov[iu_xu_cp4_rfgi_offset]),
      .din(iu_xu_cp3_rfgi_q),
      .dout(iu_xu_cp4_rfgi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp4_rfci_latch(
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
      .scin(siv[iu_xu_cp4_rfci_offset]),
      .scout(sov[iu_xu_cp4_rfci_offset]),
      .din(iu_xu_cp3_rfci_q),
      .dout(iu_xu_cp4_rfci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_xu_cp4_rfmci_latch(
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
      .scin(siv[iu_xu_cp4_rfmci_offset]),
      .scout(sov[iu_xu_cp4_rfmci_offset]),
      .din(iu_xu_cp3_rfmci_q),
      .dout(iu_xu_cp4_rfmci_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_ld_save_latch(
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
      .scin(siv[cp3_ld_save_offset]),
      .scout(sov[cp3_ld_save_offset]),
      .din(cp3_ld_save_d),
      .dout(cp3_ld_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_st_save_latch(
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
      .scin(siv[cp3_st_save_offset]),
      .scout(sov[cp3_st_save_offset]),
      .din(cp3_st_save_d),
      .dout(cp3_st_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_fp_save_latch(
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
      .scin(siv[cp3_fp_save_offset]),
      .scout(sov[cp3_fp_save_offset]),
      .din(cp3_fp_save_d),
      .dout(cp3_fp_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_ap_save_latch(
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
      .scin(siv[cp3_ap_save_offset]),
      .scout(sov[cp3_ap_save_offset]),
      .din(cp3_ap_save_d),
      .dout(cp3_ap_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_spv_save_latch(
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
      .scin(siv[cp3_spv_save_offset]),
      .scout(sov[cp3_spv_save_offset]),
      .din(cp3_spv_save_d),
      .dout(cp3_spv_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_epid_save_latch(
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
      .scin(siv[cp3_epid_save_offset]),
      .scout(sov[cp3_epid_save_offset]),
      .din(cp3_epid_save_d),
      .dout(cp3_epid_save_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_async_hold_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp3_async_hold_offset]),
      .scout(sov[cp3_async_hold_offset]),
      .din(cp3_async_hold_d),
      .dout(cp3_async_hold_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp2_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp2_flush_offset]),
      .scout(sov[cp2_flush_offset]),
      .din(cp1_flush),
      .dout(cp2_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp3_flush_offset]),
      .scout(sov[cp3_flush_offset]),
      .din(cp3_flush_d),
      .dout(cp3_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_flush_offset]),
      .scout(sov[cp4_flush_offset]),
      .din(cp3_flush_q),
      .dout(cp4_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_rfi_latch(
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
      .scin(siv[cp3_rfi_offset]),
      .scout(sov[cp3_rfi_offset]),
      .din(cp2_rfi),
      .dout(cp3_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_attn_latch(
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
      .scin(siv[cp3_attn_offset]),
      .scout(sov[cp3_attn_offset]),
      .din(cp2_attn),
      .dout(cp3_attn_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_sc_latch(
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
      .scin(siv[cp3_sc_offset]),
      .scout(sov[cp3_sc_offset]),
      .din(cp2_sc),
      .dout(cp3_sc_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_icmp_block_latch(
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
      .scin(siv[cp3_icmp_block_offset]),
      .scout(sov[cp3_icmp_block_offset]),
      .din(cp2_icmp_block),
      .dout(cp3_icmp_block_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_flush2ucode_latch(
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
      .scin(siv[cp3_flush2ucode_offset]),
      .scout(sov[cp3_flush2ucode_offset]),
      .din(cp2_flush2ucode),
      .dout(cp3_flush2ucode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_flush2ucode_type_latch(
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
      .scin(siv[cp3_flush2ucode_type_offset]),
      .scout(sov[cp3_flush2ucode_type_offset]),
      .din(cp2_flush2ucode_type),
      .dout(cp3_flush2ucode_type_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_flush_nonspec_latch(
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
      .scin(siv[cp3_flush_nonspec_offset]),
      .scout(sov[cp3_flush_nonspec_offset]),
      .din(cp2_flush_nonspec),
      .dout(cp3_flush_nonspec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_mispredict_latch(
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
      .scin(siv[cp3_mispredict_offset]),
      .scout(sov[cp3_mispredict_offset]),
      .din(cp2_mispredict),
      .dout(cp3_mispredict_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_async_int_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp3_async_int_val_offset]),
      .scout(sov[cp3_async_int_val_offset]),
      .din(cp2_async_int_val_q),
      .dout(cp3_async_int_val_q)
   );

   tri_rlmreg_p #(.WIDTH(32), .INIT(0), .NEEDS_SRESET(1)) cp3_async_int_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp3_async_int_offset:cp3_async_int_offset + 32 - 1]),
      .scout(sov[cp3_async_int_offset:cp3_async_int_offset + 32 - 1]),
      .din(cp2_async_int_q),
      .dout(cp3_async_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_iu_excvec_val_latch(
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
      .scin(siv[cp3_iu_excvec_val_offset]),
      .scout(sov[cp3_iu_excvec_val_offset]),
      .din(cp2_iu_excvec_val),
      .dout(cp3_iu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp3_iu_excvec_latch(
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
      .scin(siv[cp3_iu_excvec_offset:cp3_iu_excvec_offset + 4 - 1]),
      .scout(sov[cp3_iu_excvec_offset:cp3_iu_excvec_offset + 4 - 1]),
      .din(cp2_iu_excvec),
      .dout(cp3_iu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_lq_excvec_val_latch(
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
      .scin(siv[cp3_lq_excvec_val_offset]),
      .scout(sov[cp3_lq_excvec_val_offset]),
      .din(cp2_lq_excvec_val),
      .dout(cp3_lq_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp3_lq_excvec_latch(
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
      .scin(siv[cp3_lq_excvec_offset:cp3_lq_excvec_offset + 6 - 1]),
      .scout(sov[cp3_lq_excvec_offset:cp3_lq_excvec_offset + 6 - 1]),
      .din(cp2_lq_excvec),
      .dout(cp3_lq_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_xu_excvec_val_latch(
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
      .scin(siv[cp3_xu_excvec_val_offset]),
      .scout(sov[cp3_xu_excvec_val_offset]),
      .din(cp2_xu_excvec_val),
      .dout(cp3_xu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(0), .NEEDS_SRESET(1)) cp3_xu_excvec_latch(
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
      .scin(siv[cp3_xu_excvec_offset:cp3_xu_excvec_offset + 5 - 1]),
      .scout(sov[cp3_xu_excvec_offset:cp3_xu_excvec_offset + 5 - 1]),
      .din(cp2_xu_excvec),
      .dout(cp3_xu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_axu_excvec_val_latch(
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
      .scin(siv[cp3_axu_excvec_val_offset]),
      .scout(sov[cp3_axu_excvec_val_offset]),
      .din(cp2_axu_excvec_val),
      .dout(cp3_axu_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(1)) cp3_axu_excvec_latch(
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
      .scin(siv[cp3_axu_excvec_offset:cp3_axu_excvec_offset + 4 - 1]),
      .scout(sov[cp3_axu_excvec_offset:cp3_axu_excvec_offset + 4 - 1]),
      .din(cp2_axu_excvec),
      .dout(cp3_axu_excvec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_db_val_latch(
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
      .scin(siv[cp3_db_val_offset]),
      .scout(sov[cp3_db_val_offset]),
      .din(cp2_db_val),
      .dout(cp3_db_val_q)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp3_db_events_latch(
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
      .scin(siv[cp3_db_events_offset:cp3_db_events_offset + 19 - 1]),
      .scout(sov[cp3_db_events_offset:cp3_db_events_offset + 19 - 1]),
      .din(cp2_db_events),
      .dout(cp3_db_events_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_ld_latch(
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
      .scin(siv[cp3_ld_offset]),
      .scout(sov[cp3_ld_offset]),
      .din(cp2_ld),
      .dout(cp3_ld_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_st_latch(
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
      .scin(siv[cp3_st_offset]),
      .scout(sov[cp3_st_offset]),
      .din(cp2_st),
      .dout(cp3_st_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_fp_latch(
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
      .scin(siv[cp3_fp_offset]),
      .scout(sov[cp3_fp_offset]),
      .din(cp2_fp),
      .dout(cp3_fp_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_ap_latch(
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
      .scin(siv[cp3_ap_offset]),
      .scout(sov[cp3_ap_offset]),
      .din(cp2_ap),
      .dout(cp3_ap_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_spv_latch(
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
      .scin(siv[cp3_spv_offset]),
      .scout(sov[cp3_spv_offset]),
      .din(cp2_spv),
      .dout(cp3_spv_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_epid_latch(
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
      .scin(siv[cp3_epid_offset]),
      .scout(sov[cp3_epid_offset]),
      .din(cp2_epid),
      .dout(cp3_epid_q)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp3_ifar_latch(
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
      .scin(siv[cp3_ifar_offset:cp3_ifar_offset + 18]),
      .scout(sov[cp3_ifar_offset:cp3_ifar_offset + 18]),
      .din(cp2_ifar),
      .dout(cp3_ifar_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_np1_flush_latch(
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
      .scin(siv[cp3_np1_flush_offset]),
      .scout(sov[cp3_np1_flush_offset]),
      .din(cp2_np1_flush),
      .dout(cp3_np1_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_ucode_latch(
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
      .scin(siv[cp3_ucode_offset]),
      .scout(sov[cp3_ucode_offset]),
      .din(cp2_ucode),
      .dout(cp3_ucode_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_preissue_latch(
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
      .scin(siv[cp3_preissue_offset]),
      .scout(sov[cp3_preissue_offset]),
      .din(cp2_preissue),
      .dout(cp3_preissue_q)
   );


   generate
      begin : xhdl6
         genvar i;
         for (i = 0; i < `EFF_IFAR_ARCH; i = i + 1)
         begin : q_depth_gen
            if((62-`EFF_IFAR_ARCH+i) > 31)
               tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) cp3_nia_a_latch(
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(cp3_nia_act),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .force_t(func_sl_force),
                  .scin(siv[cp3_nia_offset + i]),
                  .scout(sov[cp3_nia_offset + i]),
                  .din(cp2_nia[(62-`EFF_IFAR_ARCH+i)]),
                  .dout(cp3_nia_q[(62-`EFF_IFAR_ARCH+i)])
               );
            else
               tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp3_nia_a_latch(
                  .nclk(nclk),
                  .vd(vdd),
                  .gd(gnd),
                  .act(cp3_nia_act),
                  .d_mode(d_mode_dc),
                  .delay_lclkr(delay_lclkr_dc),
                  .mpw1_b(mpw1_dc_b),
                  .mpw2_b(mpw2_dc_b),
                  .thold_b(func_sl_thold_0_b),
                  .sg(sg_0),
                  .force_t(func_sl_force),
                  .scin(siv[cp3_nia_offset + i]),
                  .scout(sov[cp3_nia_offset + i]),
                  .din(cp2_nia[(62-`EFF_IFAR_ARCH+i)]),
                  .dout(cp3_nia_q[(62-`EFF_IFAR_ARCH+i)])
               );
         end
      end
   endgenerate

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_rfi_latch(
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
      .scin(siv[cp4_rfi_offset]),
      .scout(sov[cp4_rfi_offset]),
      .din(cp3_rfi),
      .dout(cp4_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp5_rfi_latch(
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
      .scin(siv[cp5_rfi_offset]),
      .scout(sov[cp5_rfi_offset]),
      .din(cp4_rfi_q),
      .dout(cp5_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp6_rfi_latch(
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
      .scin(siv[cp6_rfi_offset]),
      .scout(sov[cp6_rfi_offset]),
      .din(cp5_rfi_q),
      .dout(cp6_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp7_rfi_latch(
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
      .scin(siv[cp7_rfi_offset]),
      .scout(sov[cp7_rfi_offset]),
      .din(cp6_rfi_q),
      .dout(cp7_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp8_rfi_latch(
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
      .scin(siv[cp8_rfi_offset]),
      .scout(sov[cp8_rfi_offset]),
      .din(cp7_rfi_q),
      .dout(cp8_rfi_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_exc_val_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_exc_val_offset]),
      .scout(sov[cp4_exc_val_offset]),
      .din(cp3_excvec_val),
      .dout(cp4_excvec_val_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) flush_hold_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[flush_hold_offset:flush_hold_offset + 1]),
      .scout(sov[flush_hold_offset:flush_hold_offset + 1]),
      .din(flush_hold_d),
      .dout(flush_hold_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_dp_cp_async_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_dp_cp_async_flush_offset]),
      .scout(sov[cp4_dp_cp_async_flush_offset]),
      .din(cp3_dp_cp_async_flush),
      .dout(cp4_dp_cp_async_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_dp_cp_async_bus_snoop_flush_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_dp_cp_async_bus_snoop_flush_offset]),
      .scout(sov[cp4_dp_cp_async_bus_snoop_flush_offset]),
      .din(cp3_dp_cp_async_bus_snoop_flush),
      .dout(cp4_dp_cp_async_bus_snoop_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_async_np1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_async_np1_offset]),
      .scout(sov[cp4_async_np1_offset]),
      .din(cp3_async_np1),
      .dout(cp4_async_np1_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_async_n_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[cp4_async_n_offset]),
      .scout(sov[cp4_async_n_offset]),
      .din(cp3_async_n),
      .dout(cp4_async_n_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_pc_stop_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp4_pc_stop_offset]),
      .scout(sov[cp4_pc_stop_offset]),
      .din(cp3_pc_stop),
      .dout(cp4_pc_stop_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_stop_hold_latch(
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
      .scin(siv[pc_stop_hold_offset]),
      .scout(sov[pc_stop_hold_offset]),
      .din(pc_stop_hold_d),
      .dout(pc_stop_hold_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_mchk_disabled_latch(
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
      .scin(siv[cp4_mchk_disabled_offset]),
      .scout(sov[cp4_mchk_disabled_offset]),
      .din(cp3_mchk_disabled),
      .dout(cp4_mchk_disabled_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_mc_int_latch(
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
      .scin(siv[cp4_mc_int_offset]),
      .scout(sov[cp4_mc_int_offset]),
      .din(cp3_mc_int),
      .dout(cp4_mc_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_g_int_latch(
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
      .scin(siv[cp4_g_int_offset]),
      .scout(sov[cp4_g_int_offset]),
      .din(cp3_g_int),
      .dout(cp4_g_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_c_int_latch(
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
      .scin(siv[cp4_c_int_offset]),
      .scout(sov[cp4_c_int_offset]),
      .din(cp3_c_int),
      .dout(cp4_c_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_dbell_int_latch(
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
      .scin(siv[cp4_dbell_int_offset]),
      .scout(sov[cp4_dbell_int_offset]),
      .din(cp3_dbell_int),
      .dout(cp4_dbell_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_cdbell_int_latch(
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
      .scin(siv[cp4_cdbell_int_offset]),
      .scout(sov[cp4_cdbell_int_offset]),
      .din(cp3_cdbell_int),
      .dout(cp4_cdbell_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_gdbell_int_latch(
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
      .scin(siv[cp4_gdbell_int_offset]),
      .scout(sov[cp4_gdbell_int_offset]),
      .din(cp3_gdbell_int),
      .dout(cp4_gdbell_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_gcdbell_int_latch(
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
      .scin(siv[cp4_gcdbell_int_offset]),
      .scout(sov[cp4_gcdbell_int_offset]),
      .din(cp3_gcdbell_int),
      .dout(cp4_gcdbell_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_gmcdbell_int_latch(
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
      .scin(siv[cp4_gmcdbell_int_offset]),
      .scout(sov[cp4_gmcdbell_int_offset]),
      .din(cp3_gmcdbell_int),
      .dout(cp4_gmcdbell_int_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_dbsr_update_latch(
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
      .scin(siv[cp4_dbsr_update_offset]),
      .scout(sov[cp4_dbsr_update_offset]),
      .din(cp3_dbsr_update),
      .dout(cp4_dbsr_update_q)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0), .NEEDS_SRESET(1)) cp4_dbsr_latch(
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
      .scin(siv[cp4_dbsr_offset:cp4_dbsr_offset + 19 - 1]),
      .scout(sov[cp4_dbsr_offset:cp4_dbsr_offset + 19 - 1]),
      .din(cp3_dbsr),
      .dout(cp4_dbsr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_eheir_update_latch(
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
      .scin(siv[cp4_eheir_update_offset]),
      .scout(sov[cp4_eheir_update_offset]),
      .din(cp3_eheir_update),
      .dout(cp4_eheir_update_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_esr_update_latch(
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
      .scin(siv[cp4_esr_update_offset]),
      .scout(sov[cp4_esr_update_offset]),
      .din(cp3_esr_update),
      .dout(cp4_esr_update_q)
   );

   tri_rlmreg_p #(.WIDTH(17), .INIT(0), .NEEDS_SRESET(1)) cp4_exc_esr_latch(
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
      .scin(siv[cp4_exc_esr_offset:cp4_exc_esr_offset + 17 - 1]),
      .scout(sov[cp4_exc_esr_offset:cp4_exc_esr_offset + 17 - 1]),
      .din(cp3_exc_esr),
      .dout(cp4_exc_esr_q)
   );

   tri_rlmreg_p #(.WIDTH(15), .INIT(0), .NEEDS_SRESET(1)) cp4_exc_mcsr_latch(
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
      .scin(siv[cp4_exc_mcsr_offset:cp4_exc_mcsr_offset + 15 - 1]),
      .scout(sov[cp4_exc_mcsr_offset:cp4_exc_mcsr_offset + 15 - 1]),
      .din(cp3_exc_mcsr),
      .dout(cp4_exc_mcsr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_asyn_irpt_needed_latch(
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
      .scin(siv[cp4_asyn_irpt_needed_offset]),
      .scout(sov[cp4_asyn_irpt_needed_offset]),
      .din(cp4_asyn_irpt_needed_d),
      .dout(cp4_asyn_irpt_needed_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_asyn_icmp_needed_latch(
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
      .scin(siv[cp4_asyn_icmp_needed_offset]),
      .scout(sov[cp4_asyn_icmp_needed_offset]),
      .din(cp4_asyn_icmp_needed_d),
      .dout(cp4_asyn_icmp_needed_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) cp4_exc_nia_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp3_excvec_val),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[cp4_exc_nia_offset:cp4_exc_nia_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[cp4_exc_nia_offset:cp4_exc_nia_offset + `EFF_IFAR_ARCH - 1]),
      .din(cp3_exc_nia),
      .dout(cp4_exc_nia_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cp4_dear_update_latch(
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
      .scin(siv[cp4_dear_update_offset]),
      .scout(sov[cp4_dear_update_offset]),
      .din(cp3_dear_update),
      .dout(cp4_dear_update_q)
   );

   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0), .NEEDS_SRESET(1)) cp_next_itag_latch(
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
      .scin(siv[cp_next_itag_offset:cp_next_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[cp_next_itag_offset:cp_next_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(cp_next_itag_d),
      .dout(cp_next_itag_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_iu_init_reset_latch(
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
      .scin(siv[pc_iu_init_reset_offset]),
      .scout(sov[pc_iu_init_reset_offset]),
      .din(pc_iu_init_reset),
      .dout(pc_iu_init_reset_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_np1_async_flush_latch(
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
      .scin(siv[np1_async_flush_offset]),
      .scout(sov[np1_async_flush_offset]),
      .din(np1_async_flush_d),
      .dout(np1_async_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dp_cp_hold_req_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[dp_cp_async_flush_offset]),
      .scout(sov[dp_cp_async_flush_offset]),
      .din(dp_cp_async_flush_d),
      .dout(dp_cp_async_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dp_cp_bus_snoop_hold_req_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[dp_cp_async_bus_snoop_flush_offset]),
      .scout(sov[dp_cp_async_bus_snoop_flush_offset]),
      .din(dp_cp_async_bus_snoop_flush_d),
      .dout(dp_cp_async_bus_snoop_flush_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_de_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_msr_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[msr_de_offset]),
      .scout(sov[msr_de_offset]),
      .din(xu_iu_msr_de),
      .dout(msr_de_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_pr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_msr_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[msr_pr_offset]),
      .scout(sov[msr_pr_offset]),
      .din(xu_iu_msr_pr),
      .dout(msr_pr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_cm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_msr_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[msr_cm_offset]),
      .scout(sov[msr_cm_offset]),
      .din(xu_iu_msr_cm),
      .dout(msr_cm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_cm_noact_latch(
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
      .scin(siv[msr_cm_noact_offset]),
      .scout(sov[msr_cm_noact_offset]),
      .din(xu_iu_msr_cm),
      .dout(msr_cm_noact_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_gs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_msr_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[msr_gs_offset]),
      .scout(sov[msr_gs_offset]),
      .din(xu_iu_msr_gs),
      .dout(msr_gs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) msr_me_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_msr_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[msr_me_offset]),
      .scout(sov[msr_me_offset]),
      .din(xu_iu_msr_me),
      .dout(msr_me_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_edm_latch(
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
      .scin(siv[dbcr0_edm_offset]),
      .scout(sov[dbcr0_edm_offset]),
      .din(xu_iu_dbcr0_edm),
      .dout(dbcr0_edm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_idm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_idm_offset]),
      .scout(sov[dbcr0_idm_offset]),
      .din(xu_iu_dbcr0_idm),
      .dout(dbcr0_idm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_icmp_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_icmp_offset]),
      .scout(sov[dbcr0_icmp_offset]),
      .din(xu_iu_dbcr0_icmp),
      .dout(dbcr0_icmp_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_brt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_brt_offset]),
      .scout(sov[dbcr0_brt_offset]),
      .din(xu_iu_dbcr0_brt),
      .dout(dbcr0_brt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_irpt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_irpt_offset]),
      .scout(sov[dbcr0_irpt_offset]),
      .din(xu_iu_dbcr0_irpt),
      .dout(dbcr0_irpt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_trap_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_trap_offset]),
      .scout(sov[dbcr0_trap_offset]),
      .din(xu_iu_dbcr0_trap),
      .dout(dbcr0_trap_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac1_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[iac1_en_offset]),
      .scout(sov[iac1_en_offset]),
      .din(xu_iu_iac1_en),
      .dout(iac1_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac2_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[iac2_en_offset]),
      .scout(sov[iac2_en_offset]),
      .din(xu_iu_iac2_en),
      .dout(iac2_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac3_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[iac3_en_offset]),
      .scout(sov[iac3_en_offset]),
      .din(xu_iu_iac3_en),
      .dout(iac3_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iac4_en_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[iac4_en_offset]),
      .scout(sov[iac4_en_offset]),
      .din(xu_iu_iac4_en),
      .dout(iac4_en_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_dac1_offset:dbcr0_dac1_offset + 2 - 1]),
      .scout(sov[dbcr0_dac1_offset:dbcr0_dac1_offset + 2 - 1]),
      .din(xu_iu_dbcr0_dac1),
      .dout(dbcr0_dac1_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_dac2_offset:dbcr0_dac2_offset + 2 - 1]),
      .scout(sov[dbcr0_dac2_offset:dbcr0_dac2_offset + 2 - 1]),
      .din(xu_iu_dbcr0_dac2),
      .dout(dbcr0_dac2_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_dac3_offset:dbcr0_dac3_offset + 2 - 1]),
      .scout(sov[dbcr0_dac3_offset:dbcr0_dac3_offset + 2 - 1]),
      .din(xu_iu_dbcr0_dac3),
      .dout(dbcr0_dac3_q)
   );

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) dbcr0_dac4_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_dac4_offset:dbcr0_dac4_offset + 2 - 1]),
      .scout(sov[dbcr0_dac4_offset:dbcr0_dac4_offset + 2 - 1]),
      .din(xu_iu_dbcr0_dac4),
      .dout(dbcr0_dac4_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr0_ret_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr0_ret_offset]),
      .scout(sov[dbcr0_ret_offset]),
      .din(xu_iu_dbcr0_ret),
      .dout(dbcr0_ret_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr1_iac12m_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr1_iac12m_offset]),
      .scout(sov[dbcr1_iac12m_offset]),
      .din(xu_iu_dbcr1_iac12m),
      .dout(dbcr1_iac12m_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr1_iac34m_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr1_iac34m_offset]),
      .scout(sov[dbcr1_iac34m_offset]),
      .din(xu_iu_dbcr1_iac34m),
      .dout(dbcr1_iac34m_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbcr3_ivc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[dbcr3_ivc_offset]),
      .scout(sov[dbcr3_ivc_offset]),
      .din(lq_iu_spr_dbcr3_ivc),
      .dout(dbcr3_ivc_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_extgs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_extgs_offset]),
      .scout(sov[epcr_extgs_offset]),
      .din(xu_iu_epcr_extgs),
      .dout(epcr_extgs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_dtlbgs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_dtlbgs_offset]),
      .scout(sov[epcr_dtlbgs_offset]),
      .din(xu_iu_epcr_dtlbgs),
      .dout(epcr_dtlbgs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_itlbgs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_itlbgs_offset]),
      .scout(sov[epcr_itlbgs_offset]),
      .din(xu_iu_epcr_itlbgs),
      .dout(epcr_itlbgs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_dsigs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_dsigs_offset]),
      .scout(sov[epcr_dsigs_offset]),
      .din(xu_iu_epcr_dsigs),
      .dout(epcr_dsigs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_isigs_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_isigs_offset]),
      .scout(sov[epcr_isigs_offset]),
      .din(xu_iu_epcr_isigs),
      .dout(epcr_isigs_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_duvd_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_duvd_offset]),
      .scout(sov[epcr_duvd_offset]),
      .din(xu_iu_epcr_duvd),
      .dout(epcr_duvd_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_icm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_icm_offset]),
      .scout(sov[epcr_icm_offset]),
      .din(xu_iu_epcr_icm),
      .dout(epcr_icm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) epcr_gicm_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[epcr_gicm_offset]),
      .scout(sov[epcr_gicm_offset]),
      .din(xu_iu_epcr_gicm),
      .dout(epcr_gicm_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ccr2_ucode_dis_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[ccr2_ucode_dis_offset]),
      .scout(sov[ccr2_ucode_dis_offset]),
      .din(xu_iu_ccr2_ucode_dis),
      .dout(ccr2_ucode_dis_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) mmu_mode_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[ccr2_mmu_mode_offset]),
      .scout(sov[ccr2_mmu_mode_offset]),
      .din(xu_iu_hid_mmu_mode),
      .dout(ccr2_mmu_mode_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_xucr4_mmu_mchk_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_iu_xucr4_mmu_mchk_offset]),
      .scout(sov[xu_iu_xucr4_mmu_mchk_offset]),
      .din(xu_iu_xucr4_mmu_mchk),
      .dout(xu_iu_xucr4_mmu_mchk_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_iu_ram_active_latch(
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
      .scin(siv[pc_iu_ram_active_offset]),
      .scout(sov[pc_iu_ram_active_offset]),
      .din(pc_iu_ram_active),
      .dout(pc_iu_ram_active_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_iu_ram_flush_thread_latch(
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
      .scin(siv[pc_iu_ram_flush_thread_offset]),
      .scout(sov[pc_iu_ram_flush_thread_offset]),
      .din(pc_iu_ram_flush_thread),
      .dout(pc_iu_ram_flush_thread_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_msrovride_enab_latch(
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
      .scin(siv[xu_iu_msrovride_enab_offset]),
      .scout(sov[xu_iu_msrovride_enab_offset]),
      .din(xu_iu_msrovride_enab),
      .dout(xu_iu_msrovride_enab_q)
   );

   tri_rlmlatch_p #(.INIT(1), .NEEDS_SRESET(1)) pc_iu_stop_latch(
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
      .scin(siv[pc_iu_stop_offset]),
      .scout(sov[pc_iu_stop_offset]),
      .din(pc_iu_stop_d),
      .dout(pc_iu_stop_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) pc_iu_step_latch(
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
      .scin(siv[pc_iu_step_offset]),
      .scout(sov[pc_iu_step_offset]),
      .din(pc_iu_step),
      .dout(pc_iu_step_q)
   );

   tri_rlmreg_p #(.WIDTH(16), .INIT(0), .NEEDS_SRESET(1)) spr_perf_mux_ctrls_latch(
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
      .scin(siv[spr_perf_mux_ctrls_offset:spr_perf_mux_ctrls_offset + 16 - 1]),
      .scout(sov[spr_perf_mux_ctrls_offset:spr_perf_mux_ctrls_offset + 16 - 1]),
      .din(spr_cp_perf_event_mux_ctrls),
      .dout(spr_perf_mux_ctrls_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) pc_iu_dbg_action_latch(
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
      .scin(siv[pc_iu_dbg_action_offset:pc_iu_dbg_action_offset + 3 - 1]),
      .scout(sov[pc_iu_dbg_action_offset:pc_iu_dbg_action_offset + 3 - 1]),
      .din(pc_iu_dbg_action),
      .dout(pc_iu_dbg_action_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) xu_iu_single_instr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_iu_single_instr_offset]),
      .scout(sov[xu_iu_single_instr_offset]),
      .din(xu_iu_single_instr_mode),
      .dout(xu_iu_single_instr_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) spr_single_issue_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_single_issue_offset]),
      .scout(sov[spr_single_issue_offset]),
      .din(spr_single_issue),
      .dout(spr_single_issue_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH-12), .INIT(0), .NEEDS_SRESET(1)) spr_ivpr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_ivpr_offset:spr_ivpr_offset + (`GPR_WIDTH-12) - 1]),
      .scout(sov[spr_ivpr_offset:spr_ivpr_offset + (`GPR_WIDTH-12) - 1]),
      .din(spr_ivpr),
      .dout(spr_ivpr_q)
   );

   tri_rlmreg_p #(.WIDTH(`GPR_WIDTH-12), .INIT(0), .NEEDS_SRESET(1)) spr_givpr_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_givpr_offset:spr_givpr_offset + (`GPR_WIDTH-12) - 1]),
      .scout(sov[spr_givpr_offset:spr_givpr_offset + (`GPR_WIDTH-12) - 1]),
      .din(spr_givpr),
      .dout(spr_givpr_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) spr_iac1_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_iac1_offset:spr_iac1_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[spr_iac1_offset:spr_iac1_offset + `EFF_IFAR_ARCH - 1]),
      .din(spr_iac1),
      .dout(spr_iac1_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) spr_iac2_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_iac2_offset:spr_iac2_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[spr_iac2_offset:spr_iac2_offset + `EFF_IFAR_ARCH - 1]),
      .din(spr_iac2),
      .dout(spr_iac2_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) spr_iac3_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_iac3_offset:spr_iac3_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[spr_iac3_offset:spr_iac3_offset + `EFF_IFAR_ARCH - 1]),
      .din(spr_iac3),
      .dout(spr_iac3_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) spr_iac4_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(cp2_complete_act),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[spr_iac4_offset:spr_iac4_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[spr_iac4_offset:spr_iac4_offset + `EFF_IFAR_ARCH - 1]),
      .din(spr_iac4),
      .dout(spr_iac4_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_pc_step_done_latch(
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
      .scin(siv[iu_pc_step_done_offset]),
      .scout(sov[iu_pc_step_done_offset]),
      .din(iu_pc_step_done_d),
      .dout(iu_pc_step_done_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) uncond_dbg_event_latch(
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
      .scin(siv[uncond_dbg_event_offset]),
      .scout(sov[uncond_dbg_event_offset]),
      .din(an_ac_uncond_dbg_event),
      .dout(uncond_dbg_event_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) external_mchk_latch(
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
      .scin(siv[external_mchk_offset]),
      .scout(sov[external_mchk_offset]),
      .din(xu_iu_external_mchk),
      .dout(external_mchk_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_int_latch(
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
      .scin(siv[ext_interrupt_offset]),
      .scout(sov[ext_interrupt_offset]),
      .din(xu_iu_ext_interrupt),
      .dout(ext_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dec_int_latch(
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
      .scin(siv[dec_interrupt_offset]),
      .scout(sov[dec_interrupt_offset]),
      .din(xu_iu_dec_interrupt),
      .dout(dec_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) udec_int_latch(
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
      .scin(siv[udec_interrupt_offset]),
      .scout(sov[udec_interrupt_offset]),
      .din(xu_iu_udec_interrupt),
      .dout(udec_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) perf_int_latch(
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
      .scin(siv[perf_interrupt_offset]),
      .scout(sov[perf_interrupt_offset]),
      .din(xu_iu_perf_interrupt),
      .dout(perf_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) fit_int_latch(
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
      .scin(siv[fit_interrupt_offset]),
      .scout(sov[fit_interrupt_offset]),
      .din(xu_iu_fit_interrupt),
      .dout(fit_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) crit_int_latch(
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
      .scin(siv[crit_interrupt_offset]),
      .scout(sov[crit_interrupt_offset]),
      .din(xu_iu_crit_interrupt),
      .dout(crit_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) wdog_int_latch(
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
      .scin(siv[wdog_interrupt_offset]),
      .scout(sov[wdog_interrupt_offset]),
      .din(xu_iu_wdog_interrupt),
      .dout(wdog_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gwdog_int_latch(
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
      .scin(siv[gwdog_interrupt_offset]),
      .scout(sov[gwdog_interrupt_offset]),
      .din(xu_iu_gwdog_interrupt),
      .dout(gwdog_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gfit_int_latch(
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
      .scin(siv[gfit_interrupt_offset]),
      .scout(sov[gfit_interrupt_offset]),
      .din(xu_iu_gfit_interrupt),
      .dout(gfit_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gdec_int_latch(
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
      .scin(siv[gdec_interrupt_offset]),
      .scout(sov[gdec_interrupt_offset]),
      .din(xu_iu_gdec_interrupt),
      .dout(gdec_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbell_int_latch(
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
      .scin(siv[dbell_interrupt_offset]),
      .scout(sov[dbell_interrupt_offset]),
      .din(xu_iu_dbell_interrupt),
      .dout(dbell_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) cdbell_int_latch(
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
      .scin(siv[cdbell_interrupt_offset]),
      .scout(sov[cdbell_interrupt_offset]),
      .din(xu_iu_cdbell_interrupt),
      .dout(cdbell_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gdbell_int_latch(
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
      .scin(siv[gdbell_interrupt_offset]),
      .scout(sov[gdbell_interrupt_offset]),
      .din(xu_iu_gdbell_interrupt),
      .dout(gdbell_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gcdbell_int_latch(
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
      .scin(siv[gcdbell_interrupt_offset]),
      .scout(sov[gcdbell_interrupt_offset]),
      .din(xu_iu_gcdbell_interrupt),
      .dout(gcdbell_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) gmcdbell_int_latch(
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
      .scin(siv[gmcdbell_interrupt_offset]),
      .scout(sov[gmcdbell_interrupt_offset]),
      .din(xu_iu_gmcdbell_interrupt),
      .dout(gmcdbell_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbsr_int_latch(
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
      .scin(siv[dbsr_interrupt_offset]),
      .scout(sov[dbsr_interrupt_offset]),
      .din(xu_iu_dbsr_ide),
      .dout(dbsr_interrupt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) fex_int_latch(
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
      .scin(siv[fex_interrupt_offset]),
      .scout(sov[fex_interrupt_offset]),
      .din(axu0_iu_async_fex),
      .dout(fex_interrupt_q)
   );

   tri_rlmreg_p #(.WIDTH(3), .INIT(0), .NEEDS_SRESET(1)) async_delay_cnt_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[async_delay_cnt_offset:async_delay_cnt_offset + 3 - 1]),
      .scout(sov[async_delay_cnt_offset:async_delay_cnt_offset + 3 - 1]),
      .din(async_delay_cnt_d),
      .dout(async_delay_cnt_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_lq_recirc_val_latch(
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
      .scin(siv[iu_lq_recirc_val_offset]),
      .scout(sov[iu_lq_recirc_val_offset]),
      .din(iu_lq_recirc_val_d),
      .dout(iu_lq_recirc_val_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_dbg_stop_latch(
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
      .scin(siv[ext_dbg_stop_offset]),
      .scout(sov[ext_dbg_stop_offset]),
      .din(ext_dbg_stop_d),
      .dout(ext_dbg_stop_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_dbg_stop_other_latch(
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
      .scin(siv[ext_dbg_stop_other_offset]),
      .scout(sov[ext_dbg_stop_other_offset]),
      .din(ext_dbg_stop_other_d),
      .dout(ext_dbg_stop_other_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_dbg_act_err_latch(
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
      .scin(siv[ext_dbg_act_err_offset]),
      .scout(sov[ext_dbg_act_err_offset]),
      .din(ext_dbg_act_err_d),
      .dout(ext_dbg_act_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ext_dbg_act_ext_latch(
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
      .scin(siv[ext_dbg_act_ext_offset]),
      .scout(sov[ext_dbg_act_ext_offset]),
      .din(ext_dbg_act_ext_d),
      .dout(ext_dbg_act_ext_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbg_int_en_latch(
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
      .scin(siv[dbg_int_en_offset]),
      .scout(sov[dbg_int_en_offset]),
      .din(dbg_int_en_d),
      .dout(dbg_int_en_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) dbg_event_en_latch(
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
      .scin(siv[dbg_event_en_offset]),
      .scout(sov[dbg_event_en_offset]),
      .din(dbg_event_en_d),
      .dout(dbg_event_en_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_i0_dispatched_delay_latch(
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
      .scin(siv[cp1_i0_dispatched_offset:cp1_i0_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_i0_dispatched_offset:cp1_i0_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .din(cp1_i0_dispatched_delay_d),
      .dout(cp1_i0_dispatched_delay_q)
   );

   tri_rlmreg_p #(.WIDTH(`CPL_Q_DEPTH), .INIT(0), .NEEDS_SRESET(1)) cp1_i1_dispatched_delay_latch(
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
      .scin(siv[cp1_i1_dispatched_offset:cp1_i1_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .scout(sov[cp1_i1_dispatched_offset:cp1_i1_dispatched_offset + `CPL_Q_DEPTH - 1]),
      .din(cp1_i1_dispatched_delay_d),
      .dout(cp1_i1_dispatched_delay_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu7_i0_is_folded_latch(
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
      .scin(siv[iu7_i0_is_folded_offset]),
      .scout(sov[iu7_i0_is_folded_offset]),
      .din(iu7_i0_is_folded_d),
      .dout(iu7_i0_is_folded_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu7_i1_is_folded_latch(
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
      .scin(siv[iu7_i1_is_folded_offset]),
      .scout(sov[iu7_i1_is_folded_offset]),
      .din(iu7_i1_is_folded_d),
      .dout(iu7_i1_is_folded_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) select_reset_latch(
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
      .scin(siv[select_reset_offset]),
      .scout(sov[select_reset_offset]),
      .din(select_reset),
      .dout(select_reset_q)
   );

   tri_rlmreg_p #(.WIDTH(`EFF_IFAR_ARCH), .INIT(0), .NEEDS_SRESET(1)) xu_iu_rest_ifar_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(select_reset),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .scin(siv[xu_iu_rest_ifar_offset:xu_iu_rest_ifar_offset + `EFF_IFAR_ARCH - 1]),
      .scout(sov[xu_iu_rest_ifar_offset:xu_iu_rest_ifar_offset + `EFF_IFAR_ARCH - 1]),
      .din(xu_iu_rest_ifar),
      .dout(xu_iu_rest_ifar_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) attn_hold_latch(
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
      .scin(siv[attn_hold_offset]),
      .scout(sov[attn_hold_offset]),
      .din(attn_hold_d),
      .dout(attn_hold_q)
   );
   assign flush_delay_d = {flush_cond, flush_delay_q[0]};

   tri_rlmreg_p #(.WIDTH(2), .INIT(0), .NEEDS_SRESET(1)) flush_delay_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .d_mode(d_mode_dc),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw2_dc_b),
      .thold_b(func_slp_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_slp_sl_force),
      .scin(siv[flush_delay_offset:flush_delay_offset + 2 - 1]),
      .scout(sov[flush_delay_offset:flush_delay_offset + 2 - 1]),
      .din(flush_delay_d),
      .dout(flush_delay_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) iu_nonspec_latch(
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
      .scin(siv[iu_nonspec_offset]),
      .scout(sov[iu_nonspec_offset]),
      .din(iu_nonspec_d),
      .dout(iu_nonspec_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_pt_fault_latch(
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
      .scin(siv[ierat_pt_fault_offset]),
      .scout(sov[ierat_pt_fault_offset]),
      .din(ierat_pt_fault_d),
      .dout(ierat_pt_fault_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_lrat_miss_latch(
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
      .scin(siv[ierat_lrat_miss_offset]),
      .scout(sov[ierat_lrat_miss_offset]),
      .din(ierat_lrat_miss_d),
      .dout(ierat_lrat_miss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) ierat_tlb_inelig_latch(
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
      .scin(siv[ierat_tlb_inelig_offset]),
      .scout(sov[ierat_tlb_inelig_offset]),
      .din(ierat_tlb_inelig_d),
      .dout(ierat_tlb_inelig_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_multihit_err_latch(
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
      .scin(siv[tlb_multihit_err_offset]),
      .scout(sov[tlb_multihit_err_offset]),
      .din(tlb_multihit_err_d),
      .dout(tlb_multihit_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_par_err_latch(
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
      .scin(siv[tlb_par_err_offset]),
      .scout(sov[tlb_par_err_offset]),
      .din(tlb_par_err_d),
      .dout(tlb_par_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) lru_par_err_latch(
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
      .scin(siv[lru_par_err_offset]),
      .scout(sov[lru_par_err_offset]),
      .din(lru_par_err_d),
      .dout(lru_par_err_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) tlb_miss_latch(
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
      .scin(siv[tlb_miss_offset]),
      .scout(sov[tlb_miss_offset]),
      .din(tlb_miss_d),
      .dout(tlb_miss_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) reload_hit_latch(
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
      .scin(siv[reload_hit_offset]),
      .scout(sov[reload_hit_offset]),
      .din(reload_hit_d),
      .dout(reload_hit_q)
   );

   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) nonspec_hit_latch(
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
      .scin(siv[nonspec_hit_offset]),
      .scout(sov[nonspec_hit_offset]),
      .din(nonspec_hit_d),
      .dout(nonspec_hit_q)
   );


   tri_rlmreg_p #(.WIDTH(6), .INIT(0), .NEEDS_SRESET(1)) cp_mm_except_taken_latch(
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
      .scin(siv[cp_mm_except_taken_offset:cp_mm_except_taken_offset + 5]),
      .scout(sov[cp_mm_except_taken_offset:cp_mm_except_taken_offset + 5]),
      .din(cp_mm_except_taken_d),
      .dout(cp_mm_except_taken_q)
   );


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(1)) eheir_val_latch(
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
      .scin(siv[eheir_val_offset]),
      .scout(sov[eheir_val_offset]),
      .din(eheir_val_d),
      .dout(eheir_val_q)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) perf_bus_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(func_sl_thold_0_b),
      .sg(sg_0),
      .force_t(func_sl_force),
      .delay_lclkr(delay_lclkr_dc),
      .mpw1_b(mpw1_dc_b),
      .mpw2_b(mpw1_dc_b),
      .d_mode(d_mode_dc),
      .scin(siv[perf_bus_offset:perf_bus_offset + 3]),
      .scout(sov[perf_bus_offset:perf_bus_offset + 3]),
      .din(event_bus_out_d),
      .dout(event_bus_out_q)
   );


   assign siv[0:scan_right - 1] = {sov[1:scan_right - 1], scan_in};
   assign scan_out = sov[0];

endmodule
