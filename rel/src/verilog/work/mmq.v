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

//********************************************************************
//* TITLE: Memory Management Unit Top Level
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"
`define            ERAT_STATE_WIDTH             4    // this is erat->tlb state width

(* recursive_synthesis="0" *)
module mmq(

    (* pin_data = "PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *)
   input [0:`NCLK_WIDTH-1]                 nclk,

   input                                 tc_ac_ccflush_dc,
   input                                 tc_ac_scan_dis_dc_b,
   input                                 tc_ac_scan_diag_dc,
   input                                 tc_ac_lbist_en_dc,
   input                                 pc_mm_gptr_sl_thold_3,
   input                                 pc_mm_time_sl_thold_3,
   input                                 pc_mm_repr_sl_thold_3,
   input                                 pc_mm_abst_sl_thold_3,
   input                                 pc_mm_abst_slp_sl_thold_3,
   input [0:1]                           pc_mm_func_sl_thold_3,
   input [0:1]                           pc_mm_func_slp_sl_thold_3,
   input                                 pc_mm_cfg_sl_thold_3,
   input                                 pc_mm_cfg_slp_sl_thold_3,
   input                                 pc_mm_func_nsl_thold_3,
   input                                 pc_mm_func_slp_nsl_thold_3,
   input                                 pc_mm_ary_nsl_thold_3,
   input                                 pc_mm_ary_slp_nsl_thold_3,
   input [0:1]                           pc_mm_sg_3,
   input                                 pc_mm_fce_3,

   input [0:`DEBUG_TRACE_WIDTH-1]        debug_bus_in,
   output [0:`DEBUG_TRACE_WIDTH-1]       debug_bus_out,

   // Instruction Trace (HTM) Control Signals:
   //  0    - ac_an_coretrace_first_valid
   //  1    - ac_an_coretrace_valid
   //  2:3  - ac_an_coretrace_type[0:1]
   input  [0:3]                          coretrace_ctrls_in,
   output [0:3]                          coretrace_ctrls_out,

   input [0:10]                          pc_mm_debug_mux1_ctrls,
   input                                 pc_mm_trace_bus_enable,

   input [0:2]                           pc_mm_event_count_mode,
   input                                 rp_mm_event_bus_enable_q,

   input  [0:`PERF_EVENT_WIDTH*`THREADS-1]       mm_event_bus_in,
   output [0:`PERF_EVENT_WIDTH*`THREADS-1]       mm_event_bus_out,

   input [0:3]                           pc_mm_abist_dcomp_g6t_2r,
   input [0:3]                           pc_mm_abist_di_0,
   input [0:3]                           pc_mm_abist_di_g6t_2r,
   input                                 pc_mm_abist_ena_dc,
   input                                 pc_mm_abist_g6t_r_wb,
   input                                 pc_mm_abist_g8t1p_renb_0,
   input                                 pc_mm_abist_g8t_bw_0,
   input                                 pc_mm_abist_g8t_bw_1,
   input [0:3]                           pc_mm_abist_g8t_dcomp,
   input                                 pc_mm_abist_g8t_wenb,
   input [0:9]                           pc_mm_abist_raddr_0,
   input                                 pc_mm_abist_raw_dc_b,
   input [0:9]                           pc_mm_abist_waddr_0,
   input                                 pc_mm_abist_wl128_comp_ena,
   input                                 pc_mm_bolt_sl_thold_3,
   input                                 pc_mm_bo_enable_3,
   input                                 pc_mm_bo_reset,
   input                                 pc_mm_bo_unload,
   input                                 pc_mm_bo_repair,
   input                                 pc_mm_bo_shdata,
   input [0:4]                           pc_mm_bo_select,
   output [0:4]                          mm_pc_bo_fail,
   output [0:4]                          mm_pc_bo_diagout,
   input                                 iu_mm_ierat_req,
   input [0:51]                          iu_mm_ierat_epn,
   input [0:`THREADS-1]                  iu_mm_ierat_thdid,
   input [0:`ERAT_STATE_WIDTH-1]         iu_mm_ierat_state,
   input [0:`PID_WIDTH-1]                iu_mm_ierat_tid,
   input                                 iu_mm_ierat_req_nonspec,
   input [0:`THREADS-1]                  iu_mm_ierat_flush,
   output [0:4]                          mm_iu_ierat_rel_val,
   output [0:`ERAT_REL_DATA_WIDTH-1]     mm_iu_ierat_rel_data,
   output                                mm_iu_ierat_snoop_coming,
   output                                mm_iu_ierat_snoop_val,
   output [0:25]                         mm_iu_ierat_snoop_attr,
   output [52-`EPN_WIDTH:51]             mm_iu_ierat_snoop_vpn,
   input                                 iu_mm_ierat_snoop_ack,

   output [0:`PID_WIDTH-1]               mm_iu_t0_ierat_pid,
   output [0:`MMUCR0_WIDTH-1]            mm_iu_t0_ierat_mmucr0,
`ifdef MM_THREADS2
   output [0:`PID_WIDTH-1]               mm_iu_t1_ierat_pid,
   output [0:`MMUCR0_WIDTH-1]            mm_iu_t1_ierat_mmucr0,
`endif

   input [0:17]                          iu_mm_ierat_mmucr0,
   input [0:`THREADS-1]                  iu_mm_ierat_mmucr0_we,
   output [0:8]                          mm_iu_ierat_mmucr1,
   output                                mm_iu_tlbwe_binv,
   input [0:3]                           iu_mm_ierat_mmucr1,
   input [0:`THREADS-1]                  iu_mm_ierat_mmucr1_we,

   input                                 xu_mm_derat_req,
   input [64-`RS_DATA_WIDTH:51]          xu_mm_derat_epn,
   input [0:`THREADS-1]                  xu_mm_derat_thdid,
   input [0:1]                           xu_mm_derat_ttype,
   input [0:`ERAT_STATE_WIDTH-1]         xu_mm_derat_state,
   input [0:`LPID_WIDTH-1]               xu_mm_derat_lpid,
   input [0:`PID_WIDTH-1]                xu_mm_derat_tid,
   input                                 lq_mm_derat_req_nonspec,
   input [0:`ITAG_SIZE_ENC-1]            lq_mm_derat_req_itag,
   input [0:`EMQ_ENTRIES-1]              lq_mm_derat_req_emq,
   output [0:4]                          mm_xu_derat_rel_val,
   output [0:`ERAT_REL_DATA_WIDTH-1]     mm_xu_derat_rel_data,
   output [0:`ITAG_SIZE_ENC-1]           mm_xu_derat_rel_itag,
   output [0:`EMQ_ENTRIES-1]             mm_xu_derat_rel_emq,
   output                                mm_xu_derat_snoop_coming,
   output                                mm_xu_derat_snoop_val,
   output [0:25]                         mm_xu_derat_snoop_attr,
   output [52-`EPN_WIDTH:51]             mm_xu_derat_snoop_vpn,
   input                                 xu_mm_derat_snoop_ack,

   output [0:`PID_WIDTH-1]               mm_xu_t0_derat_pid,
   output [0:`MMUCR0_WIDTH-1]            mm_xu_t0_derat_mmucr0,
`ifdef MM_THREADS2
   output [0:`PID_WIDTH-1]               mm_xu_t1_derat_pid,
   output [0:`MMUCR0_WIDTH-1]            mm_xu_t1_derat_mmucr0,
`endif
   input [0:17]                          xu_mm_derat_mmucr0,
   input [0:`THREADS-1]                  xu_mm_derat_mmucr0_we,
   output [0:9]                          mm_xu_derat_mmucr1,
   input [0:4]                           xu_mm_derat_mmucr1,
   input [0:`THREADS-1]                  xu_mm_derat_mmucr1_we,

   input [0:`THREADS-1]                  xu_mm_rf1_val,
   input                                 xu_mm_rf1_is_tlbre,
   input                                 xu_mm_rf1_is_tlbwe,
   input                                 xu_mm_rf1_is_tlbsx,
   input                                 xu_mm_rf1_is_tlbsxr,
   input                                 xu_mm_rf1_is_tlbsrx,
   input                                 xu_mm_rf1_is_tlbivax,
   input                                 xu_mm_rf1_is_tlbilx,
   input                                 xu_mm_rf1_is_erativax,
   input                                 xu_mm_rf1_is_eratilx,
   input                                 xu_mm_ex1_is_isync,
   input                                 xu_mm_ex1_is_csync,
   input [0:2]                           xu_mm_rf1_t,
   input [0:8]                           xu_mm_ex1_rs_is,
   input [64-`RS_DATA_WIDTH:63]          xu_mm_ex2_eff_addr,
   input [0:`THREADS-1]                  xu_mm_msr_gs,
   input [0:`THREADS-1]                  xu_mm_msr_pr,
   input [0:`THREADS-1]                  xu_mm_msr_is,
   input [0:`THREADS-1]                  xu_mm_msr_ds,
   input [0:`THREADS-1]                  xu_mm_msr_cm,
   input [0:`THREADS-1]                  xu_mm_spr_epcr_dmiuh,
   input [0:`THREADS-1]                  xu_mm_spr_epcr_dgtmi,
   input                                 xu_mm_hid_mmu_mode,
   input                                 xu_mm_xucr4_mmu_mchk,
   input                                 xu_mm_lmq_stq_empty,
   input                                 iu_mm_lmq_empty,
   input [0:`THREADS-1]                  xu_rf1_flush,
   input [0:`THREADS-1]                  xu_ex1_flush,
   input [0:`THREADS-1]                  xu_ex2_flush,
   input [0:`THREADS-1]                  xu_ex3_flush,
   input [0:`THREADS-1]                  xu_ex4_flush,
   input [0:`THREADS-1]                  xu_ex5_flush,
   input [0:`THREADS-1]                  xu_mm_ex4_flush,
   input [0:`THREADS-1]                  xu_mm_ex5_flush,
   input [0:`THREADS-1]                  xu_mm_ierat_miss,
   input [0:`THREADS-1]                  xu_mm_ierat_flush,
   input [0:`THREADS-1]                  lq_mm_perf_dtlb,
   input [0:`THREADS-1]                  iu_mm_perf_itlb,

   output [0:`THREADS-1]                 mm_xu_eratmiss_done,
   output [0:`THREADS-1]                 mm_xu_cr0_eq,
   output [0:`THREADS-1]                 mm_xu_cr0_eq_valid,
   output [0:`THREADS-1]                 mm_xu_tlb_miss,
   output [0:`THREADS-1]                 mm_xu_lrat_miss,
   output [0:`THREADS-1]                 mm_xu_tlb_inelig,
   output [0:`THREADS-1]                 mm_xu_pt_fault,
   output [0:`THREADS-1]                 mm_xu_hv_priv,
   output [0:`THREADS-1]                 mm_xu_illeg_instr,
   output [0:`THREADS-1]                 mm_xu_esr_pt,
   output [0:`THREADS-1]                 mm_xu_esr_data,
   output [0:`THREADS-1]                 mm_xu_esr_epid,
   output [0:`THREADS-1]                 mm_xu_esr_st,
   output [0:`THREADS-1]                 mm_xu_tlb_multihit_err,
   output [0:`THREADS-1]                 mm_xu_tlb_par_err,
   output [0:`THREADS-1]                 mm_xu_lru_par_err,
   output [0:`THREADS-1]                 mm_xu_local_snoop_reject,

   output                                mm_xu_ord_tlb_multihit,
   output                                mm_xu_ord_tlb_par_err,
   output                                mm_xu_ord_lru_par_err,

   output                                mm_xu_tlb_miss_ored,
   output                                mm_xu_lrat_miss_ored,
   output                                mm_xu_tlb_inelig_ored,
   output                                mm_xu_pt_fault_ored,
   output                                mm_xu_hv_priv_ored,
   output                                mm_xu_illeg_instr_ored,
   output                                mm_xu_cr0_eq_ored,
   output                                mm_xu_cr0_eq_valid_ored,
   output                                mm_pc_tlb_multihit_err_ored,
   output                                mm_pc_tlb_par_err_ored,
   output                                mm_pc_lru_par_err_ored,
   output                                mm_pc_local_snoop_reject_ored,

   input [0:`ITAG_SIZE_ENC-1]            xu_mm_rf1_itag,
   output [0:`THREADS-1]                 mm_xu_ord_n_flush_req,
   output [0:`THREADS-1]                 mm_xu_ord_np1_flush_req,
   output [0:`THREADS-1]                 mm_xu_ord_read_done,
   output [0:`THREADS-1]                 mm_xu_ord_write_done,
   output                                mm_xu_ord_n_flush_req_ored,
   output                                mm_xu_ord_np1_flush_req_ored,
   output                                mm_xu_ord_read_done_ored,
   output                                mm_xu_ord_write_done_ored,
   output [0:`ITAG_SIZE_ENC-1]           mm_xu_itag,

   input [0:`THREADS-1]                  iu_mm_hold_ack,
   output [0:`THREADS-1]                 mm_iu_hold_req,
   output [0:`THREADS-1]                 mm_iu_hold_done,
   output [0:`THREADS-1]                 mm_iu_flush_req,
   input [0:`THREADS-1]                  iu_mm_bus_snoop_hold_ack,
   output [0:`THREADS-1]                 mm_iu_bus_snoop_hold_req,
   output [0:`THREADS-1]                 mm_iu_bus_snoop_hold_done,
   output [0:`THREADS-1]                 mm_iu_tlbi_complete,
   output [0:`THREADS-1]                 mm_xu_ex3_flush_req,
   output [0:`THREADS-1]                 mm_xu_quiesce,
   output [0:`THREADS-1]                 mm_pc_tlb_req_quiesce,
   output [0:`THREADS-1]                 mm_pc_tlb_ctl_quiesce,
   output [0:`THREADS-1]                 mm_pc_htw_quiesce,
   output [0:`THREADS-1]                 mm_pc_inval_quiesce,

`ifdef WAIT_UPDATES
   input  [0:5]               cp_mm_except_taken_t0,
`ifndef THREADS1
   input  [0:5]               cp_mm_except_taken_t1,
`endif
   // 0   - val
   // 1   - I=0/D=1
   // 2   - TLB miss
   // 3   - Storage int (TLBI/PTfault)
   // 4   - LRAT miss
   // 5   - Mcheck
`endif

   output [0:`THREADS-1]                 mm_xu_lsu_req,
   output [0:1]                          mm_xu_lsu_ttype,
   output [0:4]                          mm_xu_lsu_wimge,
   output [0:3]                          mm_xu_lsu_u,
   output [64-`REAL_ADDR_WIDTH:63]       mm_xu_lsu_addr,
   output [0:7]                          mm_xu_lsu_lpid,
   output [0:7]                          mm_xu_lsu_lpidr,
   output                                mm_xu_lsu_gs,
   output                                mm_xu_lsu_ind,
   output                                mm_xu_lsu_lbit,
   input                                 xu_mm_lsu_token,

   input                                 slowspr_val_in,
   input                                 slowspr_rw_in,
   input [0:1]                           slowspr_etid_in,
   input [0:9]                           slowspr_addr_in,
   input [64-`SPR_DATA_WIDTH:63]         slowspr_data_in,
   input                                 slowspr_done_in,
   output                                slowspr_val_out,
   output                                slowspr_rw_out,
   output [0:1]                          slowspr_etid_out,
   output [0:9]                          slowspr_addr_out,
   output [64-`SPR_DATA_WIDTH:63]        slowspr_data_out,
   output                                slowspr_done_out,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 gptr_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 time_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 repr_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:1]                           abst_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input [0:9]                           func_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 bcfg_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 ccfg_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                                 dcfg_scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:1]                          abst_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output [0:9]                          func_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                gptr_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                repr_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                time_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                bcfg_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                ccfg_scan_out,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                                dcfg_scan_out,

   input                                 ac_an_power_managed_imm,
   input                                 an_ac_lbist_ary_wrt_thru_dc,
   input                                 an_ac_back_inv,
   input                                 an_ac_back_inv_target,
   input [64-`REAL_ADDR_WIDTH:63]         an_ac_back_inv_addr,
   input                                 an_ac_back_inv_local,
   input                                 an_ac_back_inv_lbit,
   input                                 an_ac_back_inv_gs,
   input                                 an_ac_back_inv_ind,
   input [0:`LPID_WIDTH-1]                an_ac_back_inv_lpar_id,
   output                                ac_an_back_inv_reject,
   output [0:`LPID_WIDTH-1]               ac_an_lpar_id,
   input [0:4]                           an_ac_reld_core_tag,
   input [0:127]                         an_ac_reld_data,
   input                                 an_ac_reld_data_vld,
   input                                 an_ac_reld_ecc_err,
   input                                 an_ac_reld_ecc_err_ue,
   input [58:59]                         an_ac_reld_qw,
   input                                 an_ac_reld_ditc,
   input                                 an_ac_reld_crit_qw

);

   parameter                            BCFG_MMUCR1_VALUE = 201326592;  // mmucr1 32-bits boot value, 201326592 -> bits 4:5 csinv="11"
   parameter                            BCFG_MMUCR2_VALUE = 685361;     // mmucr2 32-bits boot value, 0xa7531
   parameter                            BCFG_MMUCR3_VALUE = 15;         // mmucr2 15-bits boot value, 0x000f
   parameter                            BCFG_MMUCFG_VALUE = 3;          // mmucfg lrat|twc bits boot value
   parameter                            BCFG_TLB0CFG_VALUE = 7;         // tlb0cfg pt|ind|gtwe bits boot value
   parameter                            MMQ_SPR_CSWITCH_0TO3 = 8;       // chicken switch values: 8=disable mmucr1 read clear, 4=disable mmucr1.tlbwe_binv
   parameter                            MMQ_INVAL_CSWITCH_0TO3 = 0;
   parameter                            MMQ_TLB_CMP_CSWITCH_0TO7 = 0;

   parameter                            LRAT_NUM_ENTRY_LOG2 = 3;

      parameter                             MMU_Mode_Value = 1'b0;
      parameter [0:1]                       TlbSel_Tlb = 2'b00;
      parameter [0:1]                       TlbSel_IErat = 2'b10;
      parameter [0:1]                       TlbSel_DErat = 2'b11;

      // func scan bit 0 is mmq_inval (701), mmq_spr(0) non-mas (439)  ~1140
      // func scan bit 1 is mmq_spr(1) mas regs (1017)  ~1017
      // func scan bit 2 is tlb_req  ~1196
      // func scan bit 3 is tlb_ctl ~1101
      // func scan bit 4 is tlb_cmp(0) ~1134
      // func scan bit 5 is tlb_cmp(1) ~1134
      // func scan bit 6 is tlb_lrat ~1059
      // func scan bit 7 is tlb_htw(0)  ~802
      // func scan bit 8 is tlb_htw(1)  ~663
      // func scan bit 9 is tlb_cmp(2), perf (60), debug daisy chain (134) ~636

      parameter                             mmq_inval_offset = 0;
      parameter                             mmq_spr_offset_0 = mmq_inval_offset + 1;
      parameter                             scan_right_0 = mmq_spr_offset_0;
      parameter                             tlb_cmp2_offset = 0;
      parameter                             mmq_perf_offset = tlb_cmp2_offset + 1;
      parameter                             mmq_dbg_offset = mmq_perf_offset + 1;
      parameter                             scan_right_1 = mmq_dbg_offset;
      parameter                             mmq_spr_bcfg_offset = 0;
      parameter                             boot_scan_right = mmq_spr_bcfg_offset + 1 - 1;

      // genvar statements
      genvar                                tid;

      // Power signals
      wire 			            vdd;
      wire 			            gnd;
      assign vdd = 1'b1;
      assign gnd = 1'b0;

      // local spr signals
      wire [0:`MM_THREADS-1]                 cp_flush_p1;
      wire [0:`PID_WIDTH-1]                  pid0_sig;
      wire [0:`MMUCR0_WIDTH-1]               mmucr0_0_sig;
      wire [64-`MMUCR3_WIDTH:63]             mmucr3_0_sig;
      wire [1:3]                             tstmode4k_0_sig;
`ifdef MM_THREADS2
      wire [0:`PID_WIDTH-1]                  pid1_sig;
      wire [0:`MMUCR0_WIDTH-1]               mmucr0_1_sig;
      wire [64-`MMUCR3_WIDTH:63]             mmucr3_1_sig;
      wire [1:3]                             tstmode4k_1_sig;
`endif
      wire [0:`MMUCR1_WIDTH-1]              mmucr1_sig;
      wire [0:`MMUCR2_WIDTH-1]              mmucr2_sig;
      wire [0:`LPID_WIDTH-1]                lpidr_sig;
      wire [0:`MESR1_WIDTH+`MESR2_WIDTH-1]  mmq_spr_event_mux_ctrls_sig;
      wire [0:`LPID_WIDTH-1]                ac_an_lpar_id_sig;
      wire [0:4]                            mm_iu_ierat_rel_val_sig;
      wire [0:`ERAT_REL_DATA_WIDTH-1]       mm_iu_ierat_rel_data_sig;
      wire [0:4]                            mm_xu_derat_rel_val_sig;
      wire [0:`ERAT_REL_DATA_WIDTH-1]       mm_xu_derat_rel_data_sig;
      wire [0:`MM_THREADS-1]                mm_iu_hold_req_sig;
      wire [0:`MM_THREADS-1]                mm_iu_hold_done_sig;
      wire [0:`MM_THREADS-1]                mm_iu_flush_req_sig;
      wire [0:`MM_THREADS-1]                mm_iu_bus_snoop_hold_req_sig;
      wire [0:`MM_THREADS-1]                mm_iu_bus_snoop_hold_done_sig;
      wire [0:`MM_THREADS-1]                mm_iu_tlbi_complete_sig;
      wire [0:6]                            tlb_cmp_ierat_dup_val_sig;
      wire [0:6]                            tlb_cmp_derat_dup_val_sig;
      wire [0:1]                            tlb_cmp_erat_dup_wait_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_ex2_flush_req_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_ex2_illeg_instr_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_barrier_done_sig;
      wire [0:2]                            tlb_ctl_ord_type;
      wire [0:`ITAG_SIZE_ENC-1]             tlb_ctl_ex2_itag_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_ex6_illeg_instr_sig;
      wire [0:`MM_THREADS-1]                mm_xu_ex3_flush_req_sig;
      wire [0:`MM_THREADS-1]                mm_xu_quiesce_sig;
      wire [0:`MM_THREADS-1]                mm_pc_tlb_req_quiesce_sig;
      wire [0:`MM_THREADS-1]                mm_pc_tlb_ctl_quiesce_sig;
      wire [0:`MM_THREADS-1]                mm_pc_htw_quiesce_sig;
      wire [0:`MM_THREADS-1]                mm_pc_inval_quiesce_sig;
      wire [0:`MM_THREADS-1]                mm_xu_eratmiss_done_sig;
      wire [0:`MM_THREADS-1]                mm_xu_tlb_miss_sig;
      wire [0:`MM_THREADS-1]                mm_xu_lrat_miss_sig;
      wire [0:`MM_THREADS-1]                mm_xu_pt_fault_sig;
      wire [0:`MM_THREADS-1]                mm_xu_hv_priv_sig;
      wire [0:`MM_THREADS-1]                mm_xu_illeg_instr_sig;
      wire [0:`MM_THREADS-1]                mm_xu_tlb_inelig_sig;
      wire [0:`MM_THREADS-1]                mm_xu_esr_pt_sig;
      wire [0:`MM_THREADS-1]                mm_xu_esr_data_sig;
      wire [0:`MM_THREADS-1]                mm_xu_esr_epid_sig;
      wire [0:`MM_THREADS-1]                mm_xu_esr_st_sig;
      wire [0:`MM_THREADS-1]                mm_xu_cr0_eq_sig;
      wire [0:`MM_THREADS-1]                mm_xu_cr0_eq_valid_sig;
      wire [0:`MM_THREADS-1]                mm_xu_local_snoop_reject_sig;
      //signal mm_pc_err_local_snoop_reject_sig     : std_ulogic_vector(0 to  (`MM_THREADS-1));
      wire [0:`THDID_WIDTH-1]               tlb_req_quiesce_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_quiesce_sig;
      wire [0:`THDID_WIDTH-1]               htw_quiesce_sig;
      wire [1:12]                           xu_mm_ccr2_notlb_b;
      wire [0:`MM_THREADS-1]                xu_mm_epcr_dgtmi_sig;
      wire                                  xu_mm_xucr4_mmu_mchk_q;
      wire                                  mm_xu_tlb_miss_ored_sig;
      wire                                  mm_xu_lrat_miss_ored_sig;
      wire                                  mm_xu_tlb_inelig_ored_sig;
      wire                                  mm_xu_pt_fault_ored_sig;
      wire                                  mm_xu_hv_priv_ored_sig;
      wire                                  mm_xu_cr0_eq_ored_sig;
      wire                                  mm_xu_cr0_eq_valid_ored_sig;
      wire                                  mm_pc_tlb_multihit_err_ored_sig;
      wire                                  mm_pc_tlb_par_err_ored_sig;
      wire                                  mm_pc_lru_par_err_ored_sig;
      wire                                  mm_pc_local_snoop_reject_ored_sig;
      // Internal signals
      wire [0:`LRU_WIDTH-1]                  lru_write;
      wire [0:`TLB_ADDR_WIDTH-1]             lru_wr_addr;
      wire [0:`TLB_ADDR_WIDTH-1]             lru_rd_addr;
      wire [0:`LRU_WIDTH-1]                  lru_datain;
      wire [0:`LRU_WIDTH-1]                  lru_dataout;
      wire [0:`TLB_TAG_WIDTH-1]              tlb_tag2_sig;
      wire [0:`TLB_ADDR_WIDTH-1]             tlb_addr2_sig;
      wire [0:`TLB_ADDR_WIDTH-1]             tlb_addr4;
      wire [0:`TLB_WAYS-1]                   tlb_write;
      //signal tlb_way                 : std_ulogic_vector(0 to `TLB_WAYS-1);
      wire [0:`TLB_ADDR_WIDTH-1]             tlb_addr;
      wire [0:`TLB_WAY_WIDTH-1]              tlb_dataina;
      wire [0:`TLB_WAY_WIDTH-1]              tlb_datainb;
      wire [0:`TLB_WAY_WIDTH*`TLB_WAYS-1]    tlb_dataout;
      wire [0:15]                           lru_tag4_dataout;
      wire [0:2]                            tlb_tag4_esel;
      wire [0:1]                            tlb_tag4_wq;
      wire [0:1]                            tlb_tag4_is;
      wire                                  tlb_tag4_gs;
      wire                                  tlb_tag4_pr;
      wire                                  tlb_tag4_hes;
      wire                                  tlb_tag4_atsel;
      wire                                  tlb_tag4_pt;
      wire                                  tlb_tag4_cmp_hit;
      wire                                  tlb_tag4_way_ind;
      wire                                  tlb_tag4_ptereload;
      wire                                  tlb_tag4_endflag;
      wire                                  tlb_tag4_parerr;
      wire [0:`TLB_WAYS-1]                  tlb_tag4_parerr_write;
      wire                                  tlb_tag5_parerr_zeroize;
      wire [0:`MM_THREADS-1]                tlb_tag5_except;
      wire [0:`ITAG_SIZE_ENC-1]             tlb_tag4_itag_sig;
      wire [0:`ITAG_SIZE_ENC-1]             tlb_tag5_itag_sig;
      wire [0:`EMQ_ENTRIES-1]               tlb_tag5_emq_sig;
      wire [0:`PTE_WIDTH-1]                 ptereload_req_pte_lat;
      wire [0:1]                            ex6_illeg_instr;        // bad op tlbre/we indication from tlb_ctl
      wire [0:`MM_THREADS-1]                tlb_ctl_tag2_flush_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_tag3_flush_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_tag4_flush_sig;
      wire [0:`MM_THREADS-1]                tlb_resv_match_vec_sig;
      wire [0:`MM_THREADS-1]                tlb_ctl_ex3_valid_sig;
      wire [0:4]                            tlb_ctl_ex3_ttype_sig;
      wire                                  tlb_ctl_ex3_hv_state_sig;
      wire                                  ierat_req_taken;
      wire                                  derat_req_taken;
      wire                                  tlb_seq_ierat_req;
      wire                                  tlb_seq_derat_req;
      wire                                  tlb_seq_ierat_done;
      wire                                  tlb_seq_derat_done;
      wire                                  tlb_seq_idle;
      wire [0:`EPN_WIDTH-1]              ierat_req_epn;
      wire [0:`PID_WIDTH-1]                  ierat_req_pid;
      wire [0:`ERAT_STATE_WIDTH-1]           ierat_req_state;
      wire [0:`THDID_WIDTH-1]                ierat_req_thdid;
      wire [0:1]                            ierat_req_dup;
      wire                                  ierat_req_nonspec;
      wire [0:`EPN_WIDTH-1]              derat_req_epn;
      wire [0:`PID_WIDTH-1]                  derat_req_pid;
      wire [0:`LPID_WIDTH-1]                 derat_req_lpid;
      wire [0:`ERAT_STATE_WIDTH-1]           derat_req_state;
      wire [0:1]                            derat_req_ttype;
      wire [0:`THDID_WIDTH-1]                derat_req_thdid;
      wire [0:1]                            derat_req_dup;
      wire [0:`ITAG_SIZE_ENC-1]              derat_req_itag;
      wire [0:`EMQ_ENTRIES-1]                derat_req_emq;
      wire                                  derat_req_nonspec;
      wire                                  ptereload_req_valid;
      wire [0:`TLB_TAG_WIDTH-1]              ptereload_req_tag;
      wire [0:`PTE_WIDTH-1]                  ptereload_req_pte;
      wire                                  ptereload_req_taken;
      wire                                  tlb_htw_req_valid;
      wire [0:`TLB_TAG_WIDTH-1]              tlb_htw_req_tag;
      wire [`TLB_WORD_WIDTH:`TLB_WAY_WIDTH-1] tlb_htw_req_way;
      wire                                  htw_lsu_req_valid;
      wire [0:`THDID_WIDTH-1]                htw_lsu_thdid;
      wire [0:1]                            htw_dbg_lsu_thdid;
      // 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
      wire [0:1]                            htw_lsu_ttype;
      wire [0:4]                            htw_lsu_wimge;
      wire [0:3]                            htw_lsu_u;
      wire [64-`REAL_ADDR_WIDTH:63]         htw_lsu_addr;
      wire                                  htw_lsu_req_taken;
      wire                                  htw_req0_valid;
      wire [0:`THDID_WIDTH-1]               htw_req0_thdid;
      wire [0:1]                            htw_req0_type;
      wire                                  htw_req1_valid;
      wire [0:`THDID_WIDTH-1]               htw_req1_thdid;
      wire [0:1]                            htw_req1_type;
      wire                                  htw_req2_valid;
      wire [0:`THDID_WIDTH-1]               htw_req2_thdid;
      wire [0:1]                            htw_req2_type;
      wire                                  htw_req3_valid;
      wire [0:`THDID_WIDTH-1]               htw_req3_thdid;
      wire [0:1]                            htw_req3_type;
      wire [0:`MM_THREADS-1]                mm_xu_lsu_req_sig;
      wire [0:1]                            mm_xu_lsu_ttype_sig;
      wire [0:4]                            mm_xu_lsu_wimge_sig;
      wire [0:3]                            mm_xu_lsu_u_sig;
      wire [64-`REAL_ADDR_WIDTH:63]         mm_xu_lsu_addr_sig;
      wire [0:7]                            mm_xu_lsu_lpid_sig;
      //signal mm_xu_lsu_lpidr_sig            :   std_ulogic_vector(0 to 7); -- lpidr spr to lsu
      wire                                  mm_xu_lsu_gs_sig;
      wire                                  mm_xu_lsu_ind_sig;
      wire                                  mm_xu_lsu_lbit_sig;
      wire [64-`RS_DATA_WIDTH:63]            xu_mm_ex2_eff_addr_sig;
      wire [0:5]                            repr_scan_int;
      wire [0:5]                            time_scan_int;
      wire [0:6]                            abst_scan_int;
      wire                                  tlbwe_back_inv_valid_sig;
      wire [0:`MM_THREADS-1]                tlbwe_back_inv_thdid_sig;
      wire [52-`EPN_WIDTH:51]               tlbwe_back_inv_addr_sig;
      wire [0:34]                           tlbwe_back_inv_attr_sig;
      wire                                  tlbwe_back_inv_pending_sig;
      wire                                  tlb_tag5_write;
      //  these are needed regardless of tlb existence
      wire                                  tlb_snoop_coming;
      wire                                  tlb_snoop_val;
      wire [0:34]                           tlb_snoop_attr;
      wire [52-`EPN_WIDTH:51]                tlb_snoop_vpn;
      wire                                  tlb_snoop_ack;
      wire                                  mas0_0_atsel;
      wire [0:2]                            mas0_0_esel;
      wire                                  mas0_0_hes;
      wire [0:1]                            mas0_0_wq;
      wire                                  mas1_0_v;
      wire                                  mas1_0_iprot;
      wire [0:13]                           mas1_0_tid;
      wire                                  mas1_0_ind;
      wire                                  mas1_0_ts;
      wire [0:3]                            mas1_0_tsize;
      wire [0:51]                           mas2_0_epn;
      wire [0:4]                            mas2_0_wimge;
      wire [32:52]                          mas3_0_rpnl;
      wire [0:3]                            mas3_0_ubits;
      wire [0:5]                            mas3_0_usxwr;
      wire                                  mas5_0_sgs;
      wire [0:7]                            mas5_0_slpid;
      wire [0:13]                           mas6_0_spid;
      wire [0:3]                            mas6_0_isize;
      wire                                  mas6_0_sind;
      wire                                  mas6_0_sas;
      wire [22:31]                          mas7_0_rpnu;
      wire                                  mas8_0_tgs;
      wire                                  mas8_0_vf;
      wire [0:7]                            mas8_0_tlpid;
`ifdef MM_THREADS2
      wire                                  mas0_1_atsel;
      wire [0:2]                            mas0_1_esel;
      wire                                  mas0_1_hes;
      wire [0:1]                            mas0_1_wq;
      wire                                  mas1_1_v;
      wire                                  mas1_1_iprot;
      wire [0:13]                           mas1_1_tid;
      wire                                  mas1_1_ind;
      wire                                  mas1_1_ts;
      wire [0:3]                            mas1_1_tsize;
      wire [0:51]                           mas2_1_epn;
      wire [0:4]                            mas2_1_wimge;
      wire [32:52]                          mas3_1_rpnl;
      wire [0:3]                            mas3_1_ubits;
      wire [0:5]                            mas3_1_usxwr;
      wire                                  mas5_1_sgs;
      wire [0:7]                            mas5_1_slpid;
      wire [0:13]                           mas6_1_spid;
      wire [0:3]                            mas6_1_isize;
      wire                                  mas6_1_sind;
      wire                                  mas6_1_sas;
      wire [22:31]                          mas7_1_rpnu;
      wire                                  mas8_1_tgs;
      wire                                  mas8_1_vf;
      wire [0:7]                            mas8_1_tlpid;
`endif
      wire                                  mmucfg_lrat;
      wire                                  mmucfg_twc;
      wire                                  mmucsr0_tlb0fi;
      wire                                  mmq_inval_tlb0fi_done;
      wire                                  tlb0cfg_pt;
      wire                                  tlb0cfg_ind;
      wire                                  tlb0cfg_gtwe;
      wire [0:2]                            tlb_mas0_esel;
      wire                                  tlb_mas1_v;
      wire                                  tlb_mas1_iprot;
      wire [0:`PID_WIDTH-1]                 tlb_mas1_tid;
      wire [0:`PID_WIDTH-1]                 tlb_mas1_tid_error;
      wire                                  tlb_mas1_ind;
      wire                                  tlb_mas1_ts;
      wire                                  tlb_mas1_ts_error;
      wire [0:3]                            tlb_mas1_tsize;
      wire [0:51]                           tlb_mas2_epn;
      wire [0:51]                           tlb_mas2_epn_error;
      wire [0:4]                            tlb_mas2_wimge;
      wire [32:51]                          tlb_mas3_rpnl;
      wire [0:3]                            tlb_mas3_ubits;
      wire [0:5]                            tlb_mas3_usxwr;
      wire [22:31]                          tlb_mas7_rpnu;
      wire                                  tlb_mas8_tgs;
      wire                                  tlb_mas8_vf;
      wire [0:7]                            tlb_mas8_tlpid;
      wire [0:8]                            tlb_mmucr1_een;
      wire                                  tlb_mmucr1_we;
      wire [0:`THDID_WIDTH-1]               tlb_mmucr3_thdid;
      wire                                  tlb_mmucr3_resvattr;
      wire [0:1]                            tlb_mmucr3_wlc;
      wire [0:`CLASS_WIDTH-1]               tlb_mmucr3_class;
      wire [0:`EXTCLASS_WIDTH-1]            tlb_mmucr3_extclass;
      wire [0:1]                            tlb_mmucr3_rc;
      wire                                  tlb_mmucr3_x;
      wire                                  tlb_mas_tlbre;
      wire                                  tlb_mas_tlbsx_hit;
      wire                                  tlb_mas_tlbsx_miss;
      wire                                  tlb_mas_dtlb_error;
      wire                                  tlb_mas_itlb_error;
      wire [0:`MM_THREADS-1]                tlb_mas_thdid;
      wire [0:`THDID_WIDTH-1]               tlb_mas_thdid_dbg;
      wire [0:2]                            lrat_mas0_esel;
      wire                                  lrat_mas1_v;
      wire [0:3]                            lrat_mas1_tsize;
      wire [0:51]                           lrat_mas2_epn;
      wire [32:51]                          lrat_mas3_rpnl;
      wire [22:31]                          lrat_mas7_rpnu;
      wire [0:`LPID_WIDTH-1]                lrat_mas8_tlpid;
      wire                                  lrat_mmucr3_x;
      wire                                  lrat_mas_tlbre;
      wire                                  lrat_mas_tlbsx_hit;
      wire                                  lrat_mas_tlbsx_miss;
      wire [0:`MM_THREADS-1]                lrat_mas_thdid;
      wire [0:`THDID_WIDTH-1]               lrat_mas_thdid_dbg;
      wire [64-`REAL_ADDR_WIDTH:51]         lrat_tag3_lpn;
      wire [64-`REAL_ADDR_WIDTH:51]         lrat_tag3_rpn;
      wire [0:3]                            lrat_tag3_hit_status;
      wire [0:LRAT_NUM_ENTRY_LOG2-1]        lrat_tag3_hit_entry;
      wire [64-`REAL_ADDR_WIDTH:51]         lrat_tag4_lpn;
      wire [64-`REAL_ADDR_WIDTH:51]         lrat_tag4_rpn;
      wire [0:3]                            lrat_tag4_hit_status;
      wire [0:LRAT_NUM_ENTRY_LOG2-1]        lrat_tag4_hit_entry;
      wire [52-`EPN_WIDTH:51]               tlb_tag0_epn;
      wire [0:`THDID_WIDTH-1]               tlb_tag0_thdid;
      wire [0:7]                            tlb_tag0_type;
      wire [0:`LPID_WIDTH-1]                tlb_tag0_lpid;
      wire                                  tlb_tag0_atsel;
      wire [0:3]                            tlb_tag0_size;
      wire                                  tlb_tag0_addr_cap;
      wire                                  tlb_tag0_nonspec;
      wire                                  tlb_tag4_nonspec;
      wire [64-`REAL_ADDR_WIDTH:51]         pte_tag0_lpn;
      wire [0:`LPID_WIDTH-1]                pte_tag0_lpid;
      wire [64-`REAL_ADDR_WIDTH:51]         tlb_lper_lpn;
      wire [60:63]                          tlb_lper_lps;
      wire [0:`MM_THREADS-1]                tlb_lper_we;
      wire [0:`PID_WIDTH-1]                 ierat_req0_pid_sig;
      wire                                  ierat_req0_as_sig;
      wire                                  ierat_req0_gs_sig;
      wire [0:`EPN_WIDTH-1]                 ierat_req0_epn_sig;
      wire [0:`THDID_WIDTH-1]               ierat_req0_thdid_sig;
      wire                                  ierat_req0_valid_sig;
      wire                                  ierat_req0_nonspec_sig;
      wire [0:`PID_WIDTH-1]                 ierat_req1_pid_sig;
      wire                                  ierat_req1_as_sig;
      wire                                  ierat_req1_gs_sig;
      wire [0:`EPN_WIDTH-1]                 ierat_req1_epn_sig;
      wire [0:`THDID_WIDTH-1]               ierat_req1_thdid_sig;
      wire                                  ierat_req1_valid_sig;
      wire                                  ierat_req1_nonspec_sig;
      wire [0:`PID_WIDTH-1]                 ierat_req2_pid_sig;
      wire                                  ierat_req2_as_sig;
      wire                                  ierat_req2_gs_sig;
      wire [0:`EPN_WIDTH-1]                 ierat_req2_epn_sig;
      wire [0:`THDID_WIDTH-1]               ierat_req2_thdid_sig;
      wire                                  ierat_req2_valid_sig;
      wire                                  ierat_req2_nonspec_sig;
      wire [0:`PID_WIDTH-1]                  ierat_req3_pid_sig;
      wire                                  ierat_req3_as_sig;
      wire                                  ierat_req3_gs_sig;
      wire [0:`EPN_WIDTH-1]                  ierat_req3_epn_sig;
      wire [0:`THDID_WIDTH-1]                ierat_req3_thdid_sig;
      wire                                  ierat_req3_valid_sig;
      wire                                  ierat_req3_nonspec_sig;
      wire [0:`PID_WIDTH-1]                  ierat_iu4_pid_sig;
      wire                                  ierat_iu4_gs_sig;
      wire                                  ierat_iu4_as_sig;
      wire [0:`EPN_WIDTH-1]                  ierat_iu4_epn_sig;
      wire [0:`THDID_WIDTH-1]                ierat_iu4_thdid_sig;
      wire                                  ierat_iu4_valid_sig;
      wire [0:`LPID_WIDTH-1]                 derat_req0_lpid_sig;
      wire [0:`PID_WIDTH-1]                  derat_req0_pid_sig;
      wire                                  derat_req0_as_sig;
      wire                                  derat_req0_gs_sig;
      wire [0:`EPN_WIDTH-1]                  derat_req0_epn_sig;
      wire [0:`THDID_WIDTH-1]                derat_req0_thdid_sig;
      wire [0:`EMQ_ENTRIES-1]                derat_req0_emq_sig;
      wire                                  derat_req0_valid_sig;
      wire                                  derat_req0_nonspec_sig;
      wire [0:`LPID_WIDTH-1]                 derat_req1_lpid_sig;
      wire [0:`PID_WIDTH-1]                  derat_req1_pid_sig;
      wire                                  derat_req1_as_sig;
      wire                                  derat_req1_gs_sig;
      wire [0:`EPN_WIDTH-1]                  derat_req1_epn_sig;
      wire [0:`THDID_WIDTH-1]                derat_req1_thdid_sig;
      wire [0:`EMQ_ENTRIES-1]                derat_req1_emq_sig;
      wire                                  derat_req1_valid_sig;
      wire                                  derat_req1_nonspec_sig;
      wire [0:`LPID_WIDTH-1]                 derat_req2_lpid_sig;
      wire [0:`PID_WIDTH-1]                  derat_req2_pid_sig;
      wire                                  derat_req2_as_sig;
      wire                                  derat_req2_gs_sig;
      wire [0:`EPN_WIDTH-1]                  derat_req2_epn_sig;
      wire [0:`THDID_WIDTH-1]                derat_req2_thdid_sig;
      wire [0:`EMQ_ENTRIES-1]                derat_req2_emq_sig;
      wire                                  derat_req2_valid_sig;
      wire                                  derat_req2_nonspec_sig;
      wire [0:`LPID_WIDTH-1]                 derat_req3_lpid_sig;
      wire [0:`PID_WIDTH-1]                  derat_req3_pid_sig;
      wire                                  derat_req3_as_sig;
      wire                                  derat_req3_gs_sig;
      wire [0:`EPN_WIDTH-1]                  derat_req3_epn_sig;
      wire [0:`THDID_WIDTH-1]                derat_req3_thdid_sig;
      wire [0:`EMQ_ENTRIES-1]                derat_req3_emq_sig;
      wire                                  derat_req3_valid_sig;
      wire                                  derat_req3_nonspec_sig;
      wire [0:`LPID_WIDTH-1]                 derat_ex5_lpid_sig;
      wire [0:`PID_WIDTH-1]                  derat_ex5_pid_sig;
      wire                                  derat_ex5_gs_sig;
      wire                                  derat_ex5_as_sig;
      wire [0:`EPN_WIDTH-1]                  derat_ex5_epn_sig;
      wire [0:`THDID_WIDTH-1]                derat_ex5_thdid_sig;
      wire                                  derat_ex5_valid_sig;
      wire [0:9]                            tlb_cmp_perf_event_t0;
      wire [0:9]                            tlb_cmp_perf_event_t1;
      wire [0:1]                            tlb_cmp_perf_state;
      wire                                  tlb_cmp_perf_miss_direct;
      wire                                  tlb_cmp_perf_hit_direct;
      wire                                  tlb_cmp_perf_hit_indirect;
      wire                                  tlb_cmp_perf_hit_first_page;
      wire                                  tlb_cmp_perf_ptereload;
      wire                                  tlb_cmp_perf_ptereload_noexcep;
      wire                                  tlb_cmp_perf_lrat_request;
      wire                                  tlb_cmp_perf_lrat_miss;
      wire                                  tlb_cmp_perf_pt_fault;
      wire                                  tlb_cmp_perf_pt_inelig;
      wire                                  tlb_ctl_perf_tlbwec_resv;
      wire                                  tlb_ctl_perf_tlbwec_noresv;
      wire                                  inval_perf_tlbilx;
      wire                                  inval_perf_tlbivax;
      wire                                  inval_perf_tlbivax_snoop;
      wire                                  inval_perf_tlb_flush;
`ifdef WAIT_UPDATES
      wire [0:`MM_THREADS+5-1]              cp_mm_perf_except_taken_q;
`endif

      //--------- debug signals
      wire                                  spr_dbg_match_64b;
      wire                                  spr_dbg_match_any_mmu;
      wire                                  spr_dbg_match_any_mas;
      wire                                  spr_dbg_match_pid;
      wire                                  spr_dbg_match_lpidr;
      wire                                  spr_dbg_match_mmucr0;
      wire                                  spr_dbg_match_mmucr1;
      wire                                  spr_dbg_match_mmucr2;
      wire                                  spr_dbg_match_mmucr3;
      wire                                  spr_dbg_match_mmucsr0;
      wire                                  spr_dbg_match_mmucfg;
      wire                                  spr_dbg_match_tlb0cfg;
      wire                                  spr_dbg_match_tlb0ps;
      wire                                  spr_dbg_match_lratcfg;
      wire                                  spr_dbg_match_lratps;
      wire                                  spr_dbg_match_eptcfg;
      wire                                  spr_dbg_match_lper;
      wire                                  spr_dbg_match_lperu;
      wire                                  spr_dbg_match_mas0;
      wire                                  spr_dbg_match_mas1;
      wire                                  spr_dbg_match_mas2;
      wire                                  spr_dbg_match_mas2u;
      wire                                  spr_dbg_match_mas3;
      wire                                  spr_dbg_match_mas4;
      wire                                  spr_dbg_match_mas5;
      wire                                  spr_dbg_match_mas6;
      wire                                  spr_dbg_match_mas7;
      wire                                  spr_dbg_match_mas8;
      wire                                  spr_dbg_match_mas01_64b;
      wire                                  spr_dbg_match_mas56_64b;
      wire                                  spr_dbg_match_mas73_64b;
      wire                                  spr_dbg_match_mas81_64b;
      wire                                  spr_dbg_slowspr_val_int;
      wire                                  spr_dbg_slowspr_rw_int;
      wire [0:1]                            spr_dbg_slowspr_etid_int;
      wire [0:9]                            spr_dbg_slowspr_addr_int;
      wire                                  spr_dbg_slowspr_val_out;
      wire                                  spr_dbg_slowspr_done_out;
      wire [64-`SPR_DATA_WIDTH:63]           spr_dbg_slowspr_data_out;
      wire [0:4]                            inval_dbg_seq_q;
      wire                                  inval_dbg_seq_idle;
      wire                                  inval_dbg_seq_snoop_inprogress;
      wire                                  inval_dbg_seq_snoop_done;
      wire                                  inval_dbg_seq_local_done;
      wire                                  inval_dbg_seq_tlb0fi_done;
      wire                                  inval_dbg_seq_tlbwe_snoop_done;
      wire                                  inval_dbg_ex6_valid;
      wire [0:1]                            inval_dbg_ex6_thdid;
      wire [0:2]                            inval_dbg_ex6_ttype;
      wire                                  inval_dbg_snoop_forme;
      wire                                  inval_dbg_snoop_local_reject;
      wire [2:8]                            inval_dbg_an_ac_back_inv_q;
      wire [0:7]                            inval_dbg_an_ac_back_inv_lpar_id_q;
      wire [22:63]                          inval_dbg_an_ac_back_inv_addr_q;
      wire [0:2]                            inval_dbg_snoop_valid_q;
      wire [0:2]                            inval_dbg_snoop_ack_q;
      wire [0:34]                           inval_dbg_snoop_attr_q;
      wire [18:19]                          inval_dbg_snoop_attr_tlb_spec_q;
      wire [17:51]                          inval_dbg_snoop_vpn_q;
      wire [0:1]                            inval_dbg_lsu_tokens_q;
      wire                                  tlb_req_dbg_ierat_iu5_valid_q;
      wire [0:1]                            tlb_req_dbg_ierat_iu5_thdid;
      wire [0:3]                            tlb_req_dbg_ierat_iu5_state_q;
      wire [0:1]                            tlb_req_dbg_ierat_inptr_q;
      wire [0:1]                            tlb_req_dbg_ierat_outptr_q;
      wire [0:3]                            tlb_req_dbg_ierat_req_valid_q;
      wire [0:3]                            tlb_req_dbg_ierat_req_nonspec_q;
      wire [0:7]                            tlb_req_dbg_ierat_req_thdid;
      wire [0:3]                            tlb_req_dbg_ierat_req_dup_q;
      wire                                  tlb_req_dbg_derat_ex6_valid_q;
      wire [0:1]                            tlb_req_dbg_derat_ex6_thdid;
      wire [0:3]                            tlb_req_dbg_derat_ex6_state_q;
      wire [0:1]                            tlb_req_dbg_derat_inptr_q;
      wire [0:1]                            tlb_req_dbg_derat_outptr_q;
      wire [0:3]                            tlb_req_dbg_derat_req_valid_q;
      wire [0:7]                            tlb_req_dbg_derat_req_thdid;
      wire [0:7]                            tlb_req_dbg_derat_req_ttype_q;
      wire [0:3]                            tlb_req_dbg_derat_req_dup_q;
      wire [0:5]                            tlb_ctl_dbg_seq_q;
      wire                                  tlb_ctl_dbg_seq_idle;
      wire                                  tlb_ctl_dbg_seq_any_done_sig;
      wire                                  tlb_ctl_dbg_seq_abort;
      wire                                  tlb_ctl_dbg_any_tlb_req_sig;
      wire                                  tlb_ctl_dbg_any_req_taken_sig;
      wire                                  tlb_ctl_dbg_tag0_valid;
      wire [0:1]                            tlb_ctl_dbg_tag0_thdid;
      wire [0:2]                            tlb_ctl_dbg_tag0_type;
      wire [0:1]                            tlb_ctl_dbg_tag0_wq;
      wire                                  tlb_ctl_dbg_tag0_gs;
      wire                                  tlb_ctl_dbg_tag0_pr;
      wire                                  tlb_ctl_dbg_tag0_atsel;
      wire [0:3]                            tlb_ctl_dbg_tag5_tlb_write_q;
      wire [0:3]                            tlb_ctl_dbg_resv_valid;
      wire [0:3]                            tlb_ctl_dbg_set_resv;
      wire [0:3]                            tlb_ctl_dbg_resv_match_vec_q;
      wire                                  tlb_ctl_dbg_any_tag_flush_sig;
      wire                                  tlb_ctl_dbg_resv0_tag0_lpid_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_pid_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_as_snoop_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_gs_snoop_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_as_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_ind_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_epn_loc_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_epn_glob_match;
      wire                                  tlb_ctl_dbg_resv0_tag0_class_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_lpid_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_pid_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_as_snoop_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_gs_snoop_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_as_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_ind_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_epn_loc_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_epn_glob_match;
      wire                                  tlb_ctl_dbg_resv1_tag0_class_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_lpid_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_pid_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_as_snoop_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_gs_snoop_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_as_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_ind_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_epn_loc_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_epn_glob_match;
      wire                                  tlb_ctl_dbg_resv2_tag0_class_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_lpid_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_pid_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_as_snoop_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_gs_snoop_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_as_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_ind_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_epn_loc_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_epn_glob_match;
      wire                                  tlb_ctl_dbg_resv3_tag0_class_match;
      wire [0:3]                            tlb_ctl_dbg_clr_resv_q;
      wire [0:3]                            tlb_ctl_dbg_clr_resv_terms;
      wire [0:`TLB_TAG_WIDTH-1]              tlb_cmp_dbg_tag4;
      wire [0:`TLB_WAYS]                     tlb_cmp_dbg_tag4_wayhit;
      wire [0:`TLB_ADDR_WIDTH-1]             tlb_cmp_dbg_addr4;
      wire [0:`TLB_WAY_WIDTH-1]              tlb_cmp_dbg_tag4_way;
      wire [0:4]                            tlb_cmp_dbg_tag4_parerr;
      wire [0:`LRU_WIDTH-5]                  tlb_cmp_dbg_tag4_lru_dataout_q;
      wire [0:`TLB_WAY_WIDTH-1]              tlb_cmp_dbg_tag5_tlb_datain_q;
      wire [0:`LRU_WIDTH-5]                  tlb_cmp_dbg_tag5_lru_datain_q;
      wire                                  tlb_cmp_dbg_tag5_lru_write;
      wire                                  tlb_cmp_dbg_tag5_any_exception;
      wire [0:3]                            tlb_cmp_dbg_tag5_except_type_q;
      wire [0:1]                            tlb_cmp_dbg_tag5_except_thdid_q;
      wire [0:9]                            tlb_cmp_dbg_tag5_erat_rel_val;
      wire [0:131]                          tlb_cmp_dbg_tag5_erat_rel_data;
      wire [0:19]                           tlb_cmp_dbg_erat_dup_q;
      wire [0:8]                            tlb_cmp_dbg_addr_enable;
      wire                                  tlb_cmp_dbg_pgsize_enable;
      wire                                  tlb_cmp_dbg_class_enable;
      wire [0:1]                            tlb_cmp_dbg_extclass_enable;
      wire [0:1]                            tlb_cmp_dbg_state_enable;
      wire                                  tlb_cmp_dbg_thdid_enable;
      wire                                  tlb_cmp_dbg_pid_enable;
      wire                                  tlb_cmp_dbg_lpid_enable;
      wire                                  tlb_cmp_dbg_ind_enable;
      wire                                  tlb_cmp_dbg_iprot_enable;
      wire                                  tlb_cmp_dbg_way0_entry_v;
      wire                                  tlb_cmp_dbg_way0_addr_match;
      wire                                  tlb_cmp_dbg_way0_pgsize_match;
      wire                                  tlb_cmp_dbg_way0_class_match;
      wire                                  tlb_cmp_dbg_way0_extclass_match;
      wire                                  tlb_cmp_dbg_way0_state_match;
      wire                                  tlb_cmp_dbg_way0_thdid_match;
      wire                                  tlb_cmp_dbg_way0_pid_match;
      wire                                  tlb_cmp_dbg_way0_lpid_match;
      wire                                  tlb_cmp_dbg_way0_ind_match;
      wire                                  tlb_cmp_dbg_way0_iprot_match;
      wire                                  tlb_cmp_dbg_way1_entry_v;
      wire                                  tlb_cmp_dbg_way1_addr_match;
      wire                                  tlb_cmp_dbg_way1_pgsize_match;
      wire                                  tlb_cmp_dbg_way1_class_match;
      wire                                  tlb_cmp_dbg_way1_extclass_match;
      wire                                  tlb_cmp_dbg_way1_state_match;
      wire                                  tlb_cmp_dbg_way1_thdid_match;
      wire                                  tlb_cmp_dbg_way1_pid_match;
      wire                                  tlb_cmp_dbg_way1_lpid_match;
      wire                                  tlb_cmp_dbg_way1_ind_match;
      wire                                  tlb_cmp_dbg_way1_iprot_match;
      wire                                  tlb_cmp_dbg_way2_entry_v;
      wire                                  tlb_cmp_dbg_way2_addr_match;
      wire                                  tlb_cmp_dbg_way2_pgsize_match;
      wire                                  tlb_cmp_dbg_way2_class_match;
      wire                                  tlb_cmp_dbg_way2_extclass_match;
      wire                                  tlb_cmp_dbg_way2_state_match;
      wire                                  tlb_cmp_dbg_way2_thdid_match;
      wire                                  tlb_cmp_dbg_way2_pid_match;
      wire                                  tlb_cmp_dbg_way2_lpid_match;
      wire                                  tlb_cmp_dbg_way2_ind_match;
      wire                                  tlb_cmp_dbg_way2_iprot_match;
      wire                                  tlb_cmp_dbg_way3_entry_v;
      wire                                  tlb_cmp_dbg_way3_addr_match;
      wire                                  tlb_cmp_dbg_way3_pgsize_match;
      wire                                  tlb_cmp_dbg_way3_class_match;
      wire                                  tlb_cmp_dbg_way3_extclass_match;
      wire                                  tlb_cmp_dbg_way3_state_match;
      wire                                  tlb_cmp_dbg_way3_thdid_match;
      wire                                  tlb_cmp_dbg_way3_pid_match;
      wire                                  tlb_cmp_dbg_way3_lpid_match;
      wire                                  tlb_cmp_dbg_way3_ind_match;
      wire                                  tlb_cmp_dbg_way3_iprot_match;
      wire                                  lrat_dbg_tag1_addr_enable;
      wire [0:7]                            lrat_dbg_tag2_matchline_q;
      wire                                  lrat_dbg_entry0_addr_match;
      wire                                  lrat_dbg_entry0_lpid_match;
      wire                                  lrat_dbg_entry0_entry_v;
      wire                                  lrat_dbg_entry0_entry_x;
      wire [0:3]                            lrat_dbg_entry0_size;
      wire                                  lrat_dbg_entry1_addr_match;
      wire                                  lrat_dbg_entry1_lpid_match;
      wire                                  lrat_dbg_entry1_entry_v;
      wire                                  lrat_dbg_entry1_entry_x;
      wire [0:3]                            lrat_dbg_entry1_size;
      wire                                  lrat_dbg_entry2_addr_match;
      wire                                  lrat_dbg_entry2_lpid_match;
      wire                                  lrat_dbg_entry2_entry_v;
      wire                                  lrat_dbg_entry2_entry_x;
      wire [0:3]                            lrat_dbg_entry2_size;
      wire                                  lrat_dbg_entry3_addr_match;
      wire                                  lrat_dbg_entry3_lpid_match;
      wire                                  lrat_dbg_entry3_entry_v;
      wire                                  lrat_dbg_entry3_entry_x;
      wire [0:3]                            lrat_dbg_entry3_size;
      wire                                  lrat_dbg_entry4_addr_match;
      wire                                  lrat_dbg_entry4_lpid_match;
      wire                                  lrat_dbg_entry4_entry_v;
      wire                                  lrat_dbg_entry4_entry_x;
      wire [0:3]                            lrat_dbg_entry4_size;
      wire                                  lrat_dbg_entry5_addr_match;
      wire                                  lrat_dbg_entry5_lpid_match;
      wire                                  lrat_dbg_entry5_entry_v;
      wire                                  lrat_dbg_entry5_entry_x;
      wire [0:3]                            lrat_dbg_entry5_size;
      wire                                  lrat_dbg_entry6_addr_match;
      wire                                  lrat_dbg_entry6_lpid_match;
      wire                                  lrat_dbg_entry6_entry_v;
      wire                                  lrat_dbg_entry6_entry_x;
      wire [0:3]                            lrat_dbg_entry6_size;
      wire                                  lrat_dbg_entry7_addr_match;
      wire                                  lrat_dbg_entry7_lpid_match;
      wire                                  lrat_dbg_entry7_entry_v;
      wire                                  lrat_dbg_entry7_entry_x;
      wire [0:3]                            lrat_dbg_entry7_size;
      wire                                  htw_dbg_seq_idle;
      wire                                  htw_dbg_pte0_seq_idle;
      wire                                  htw_dbg_pte1_seq_idle;
      wire [0:1]                            htw_dbg_seq_q;
      wire [0:1]                            htw_dbg_inptr_q;
      wire [0:2]                            htw_dbg_pte0_seq_q;
      wire [0:2]                            htw_dbg_pte1_seq_q;
      wire                                  htw_dbg_ptereload_ptr_q;
      wire [0:1]                            htw_dbg_lsuptr_q;
      wire [0:3]                            htw_dbg_req_valid_q;
      wire [0:3]                            htw_dbg_resv_valid_vec;
      wire [0:3]                            htw_dbg_tag4_clr_resv_q;
      wire [0:3]                            htw_dbg_tag4_clr_resv_terms;
      wire [0:1]                            htw_dbg_pte0_score_ptr_q;
      wire [58:60]                          htw_dbg_pte0_score_cl_offset_q;
      wire [0:2]                            htw_dbg_pte0_score_error_q;
      wire [0:3]                            htw_dbg_pte0_score_qwbeat_q;
      wire                                  htw_dbg_pte0_score_pending_q;
      wire                                  htw_dbg_pte0_score_ibit_q;
      wire                                  htw_dbg_pte0_score_dataval_q;
      wire                                  htw_dbg_pte0_reld_for_me_tm1;
      wire [0:1]                            htw_dbg_pte1_score_ptr_q;
      wire [58:60]                          htw_dbg_pte1_score_cl_offset_q;
      wire [0:2]                            htw_dbg_pte1_score_error_q;
      wire [0:3]                            htw_dbg_pte1_score_qwbeat_q;
      wire                                  htw_dbg_pte1_score_pending_q;
      wire                                  htw_dbg_pte1_score_ibit_q;
      wire                                  htw_dbg_pte1_score_dataval_q;
      wire                                  htw_dbg_pte1_reld_for_me_tm1;
      // power clock gating sigs
      wire [9:33]                           tlb_delayed_act;

      (* analysis_not_referenced="true" *)
      wire [0:71+`MM_THREADS-`THREADS]            unused_dc;

      (* analysis_not_referenced="true" *)
      wire [0:0]                            unused_dc_array_scan;

      // Pervasive
      wire                                  lcb_clkoff_dc_b;
      wire                                  lcb_act_dis_dc;
      wire                                  lcb_d_mode_dc;
      wire [0:4]                            lcb_delay_lclkr_dc;
      wire [0:4]                            lcb_mpw1_dc_b;
      wire                                  lcb_mpw2_dc_b;
      wire                                  g6t_gptr_lcb_clkoff_dc_b;
      wire                                  g6t_gptr_lcb_act_dis_dc;
      wire                                  g6t_gptr_lcb_d_mode_dc;
      wire [0:4]                            g6t_gptr_lcb_delay_lclkr_dc;
      wire [0:4]                            g6t_gptr_lcb_mpw1_dc_b;
      wire                                  g6t_gptr_lcb_mpw2_dc_b;
      wire                                  g8t_gptr_lcb_clkoff_dc_b;
      wire                                  g8t_gptr_lcb_act_dis_dc;
      wire                                  g8t_gptr_lcb_d_mode_dc;
      wire [0:4]                            g8t_gptr_lcb_delay_lclkr_dc;
      wire [0:4]                            g8t_gptr_lcb_mpw1_dc_b;
      wire                                  g8t_gptr_lcb_mpw2_dc_b;
      wire [0:1]                            pc_func_sl_thold_2;
      wire [0:1]                            pc_func_slp_sl_thold_2;
      wire                                  pc_func_slp_nsl_thold_2;
      wire                                  pc_fce_2;
      wire                                  pc_cfg_sl_thold_2;
      wire                                  pc_cfg_slp_sl_thold_2;
      wire [0:1]                            pc_sg_2;
      wire [0:1]                            pc_sg_1;
      wire [0:1]                            pc_sg_0;
      wire [0:1]                            pc_func_sl_thold_0;
      wire [0:1]                            pc_func_sl_thold_0_b;
      wire [0:1]                            pc_func_slp_sl_thold_0;
      wire [0:1]                            pc_func_slp_sl_thold_0_b;
      wire                                  pc_abst_sl_thold_0;
      wire                                  pc_abst_slp_sl_thold_0;
      wire                                  pc_repr_sl_thold_0;
      wire                                  pc_time_sl_thold_0;
      wire                                  pc_ary_nsl_thold_0;
      wire                                  pc_ary_slp_nsl_thold_0;
      wire                                  pc_mm_bolt_sl_thold_0;
      wire                                  pc_mm_bo_enable_2;
      wire                                  pc_mm_abist_g8t_wenb_q;
      wire                                  pc_mm_abist_g8t1p_renb_0_q;
      wire [0:3]                            pc_mm_abist_di_0_q;
      wire                                  pc_mm_abist_g8t_bw_1_q;
      wire                                  pc_mm_abist_g8t_bw_0_q;
      wire [0:9]                            pc_mm_abist_waddr_0_q;
      wire [0:9]                            pc_mm_abist_raddr_0_q;
      wire                                  pc_mm_abist_wl128_comp_ena_q;
      wire [0:3]                            pc_mm_abist_g8t_dcomp_q;
      wire [0:3]                            pc_mm_abist_dcomp_g6t_2r_q;
      wire [0:3]                            pc_mm_abist_di_g6t_2r_q;
      wire                                  pc_mm_abist_g6t_r_wb_q;
      wire                                  time_scan_in_int;
      wire                                  time_scan_out_int;
      wire [0:9]                            func_scan_in_int;
      wire [0:9]                            func_scan_out_int;
      wire                                  repr_scan_in_int;
      wire                                  repr_scan_out_int;
      wire [0:1]                            abst_scan_in_int;
      wire [0:1]                            abst_scan_out_int;
      wire                                  bcfg_scan_in_int;
      wire                                  bcfg_scan_out_int;
      wire                                  ccfg_scan_in_int;
      wire                                  ccfg_scan_out_int;
      wire                                  dcfg_scan_in_int;
      wire                                  dcfg_scan_out_int;
      wire [0:scan_right_0]                 siv_0;
      wire [0:scan_right_0]                 sov_0;
      wire [0:scan_right_1]                 siv_1;
      wire [0:scan_right_1]                 sov_1;
      wire [0:boot_scan_right]              bsiv;
      wire [0:boot_scan_right]              bsov;
      wire                                  tidn;
      wire                                  tiup;
      // threading generic conversion sigs
      wire [0:`THDID_WIDTH-1]               iu_mm_ierat_thdid_sig;
      wire [0:`THDID_WIDTH-1]               iu_mm_ierat_flush_sig;
      wire [0:`MM_THREADS-1]                iu_mm_ierat_mmucr0_we_sig;
      wire [0:`MM_THREADS-1]                iu_mm_ierat_mmucr1_we_sig;
      wire [0:`MM_THREADS-1]                iu_mm_hold_ack_sig;
      wire [0:`MM_THREADS-1]                iu_mm_bus_snoop_hold_ack_sig;
      wire [0:`MM_THREADS-1]                xu_mm_derat_mmucr0_we_sig;
      wire [0:`MM_THREADS-1]                xu_mm_derat_mmucr1_we_sig;
      wire [0:`THDID_WIDTH-1]               xu_mm_derat_thdid_sig;
      wire [0:`MM_THREADS-1]                mm_xu_ord_n_flush_req_sig;
      wire [0:`MM_THREADS-1]                mm_xu_ord_np1_flush_req_sig;
      wire [0:`MM_THREADS-1]                mm_xu_ord_read_done_sig;
      wire [0:`MM_THREADS-1]                mm_xu_ord_write_done_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_msr_gs_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_msr_pr_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_msr_is_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_msr_ds_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_msr_cm_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_spr_epcr_dgtmi_sig;
      wire [0:`MM_THREADS-1]                 xu_mm_spr_epcr_dmiuh_sig;
      wire [0:`MM_THREADS-1]                 xu_rf1_flush_sig;
      wire [0:`MM_THREADS-1]                 xu_ex1_flush_sig;
      wire [0:`MM_THREADS-1]                 xu_ex2_flush_sig;
      wire [0:`THDID_WIDTH-1]                xu_ex3_flush_sig;
      wire [0:`MM_THREADS-1]                 xu_ex4_flush_sig;
      wire [0:`MM_THREADS-1]                 xu_ex5_flush_sig;
      wire [0:`THDID_WIDTH-1]                xu_mm_ex4_flush_sig;
      wire [0:`THDID_WIDTH-1]                xu_mm_ex5_flush_sig;
      wire [0:`THDID_WIDTH-1]                xu_mm_ierat_flush_sig;
      wire [0:`THDID_WIDTH-1]                xu_mm_ierat_miss_sig;
      wire [0:`MM_THREADS-1]                 mm_xu_tlb_multihit_err_sig;
      wire [0:`MM_THREADS-1]                 mm_xu_tlb_par_err_sig;
      wire [0:`MM_THREADS-1]                 mm_xu_lru_par_err_sig;

      wire                                   mm_xu_ord_tlb_multihit_sig;
      wire                                   mm_xu_ord_tlb_par_err_sig;
      wire                                   mm_xu_ord_lru_par_err_sig;

      wire [0:`MM_THREADS-1]                 xu_mm_rf1_val_sig;
      wire [0:`THDID_WIDTH-1]                lq_mm_perf_dtlb_sig;
      wire [0:`THDID_WIDTH-1]                iu_mm_perf_itlb_sig;
      wire [0:`THDID_WIDTH-1]                xu_mm_msr_gs_perf;
      wire [0:`THDID_WIDTH-1]                xu_mm_msr_pr_perf;

      wire [0:`PID_WIDTH-1]                 mm_iu_ierat_pid_sig     [0:`MM_THREADS-1];
      wire [0:`PID_WIDTH-1]                 mm_xu_derat_pid_sig     [0:`MM_THREADS-1];

      wire [0:`MMUCR0_WIDTH-1]              mm_iu_ierat_mmucr0_sig  [0:`MM_THREADS-1];
      wire [0:`MMUCR0_WIDTH-1]              mm_xu_derat_mmucr0_sig  [0:`MM_THREADS-1];

`ifdef WAIT_UPDATES
      wire [0:5]                          cp_mm_except_taken_t0_sig;
      wire [0:5]                          cp_mm_except_taken_t1_sig;
`endif

      //---------------------------------------------------------------------
      // common stuff for tlb and erat-only modes
      //---------------------------------------------------------------------
      assign tidn = 1'b0;
      assign tiup = 1'b1;

      assign ac_an_lpar_id = ac_an_lpar_id_sig;
      assign mm_xu_lsu_lpidr = lpidr_sig;

`ifdef WAIT_UPDATES
   assign cp_mm_except_taken_t0_sig = cp_mm_except_taken_t0;
`ifndef THREADS1
   assign cp_mm_except_taken_t1_sig = cp_mm_except_taken_t1;
`else
   assign cp_mm_except_taken_t1_sig = 6'b0;
`endif
`endif


      // input port  threadwise widening  `THREADS(n) -> `MM_THREADS(m)
      generate
         begin : xhdl0
//            genvar                                tid;
            for (tid = 0; tid <= `MM_THREADS-1; tid = tid + 1)
            begin : mmThreads
               if (tid < `THREADS)
               begin : tidExist
                  assign iu_mm_ierat_mmucr0_we_sig[tid] = iu_mm_ierat_mmucr0_we[tid];
                  assign iu_mm_ierat_mmucr1_we_sig[tid] = iu_mm_ierat_mmucr1_we[tid];
                  assign xu_mm_derat_mmucr0_we_sig[tid] = xu_mm_derat_mmucr0_we[tid];
                  assign xu_mm_derat_mmucr1_we_sig[tid] = xu_mm_derat_mmucr1_we[tid];
                  assign iu_mm_hold_ack_sig[tid] = iu_mm_hold_ack[tid];
                  assign iu_mm_bus_snoop_hold_ack_sig[tid] = iu_mm_bus_snoop_hold_ack[tid];
                  assign xu_mm_msr_gs_sig[tid] = xu_mm_msr_gs[tid];
                  assign xu_mm_msr_pr_sig[tid] = xu_mm_msr_pr[tid];
                  assign xu_mm_msr_is_sig[tid] = xu_mm_msr_is[tid];
                  assign xu_mm_msr_ds_sig[tid] = xu_mm_msr_ds[tid];
                  assign xu_mm_msr_cm_sig[tid] = xu_mm_msr_cm[tid];
                  assign xu_mm_spr_epcr_dgtmi_sig[tid] = xu_mm_spr_epcr_dgtmi[tid];
                  assign xu_mm_spr_epcr_dmiuh_sig[tid] = xu_mm_spr_epcr_dmiuh[tid];
                  assign xu_rf1_flush_sig[tid] = xu_rf1_flush[tid];
                  assign xu_ex1_flush_sig[tid] = xu_ex1_flush[tid];
                  assign xu_ex2_flush_sig[tid] = xu_ex2_flush[tid];
                  assign xu_ex4_flush_sig[tid] = xu_ex4_flush[tid];
                  assign xu_ex5_flush_sig[tid] = xu_ex5_flush[tid];
                  assign xu_mm_rf1_val_sig[tid] = xu_mm_rf1_val[tid];
               end
            if (tid >= `THREADS)
            begin : tidNExist
               assign iu_mm_ierat_mmucr0_we_sig[tid] = tidn;
               assign iu_mm_ierat_mmucr1_we_sig[tid] = tidn;
               assign xu_mm_derat_mmucr0_we_sig[tid] = tidn;
               assign xu_mm_derat_mmucr1_we_sig[tid] = tidn;
               assign iu_mm_hold_ack_sig[tid] = tiup;
               assign iu_mm_bus_snoop_hold_ack_sig[tid] = tiup;
               assign xu_mm_msr_gs_sig[tid] = tidn;
               assign xu_mm_msr_pr_sig[tid] = tidn;
               assign xu_mm_msr_is_sig[tid] = tidn;
               assign xu_mm_msr_ds_sig[tid] = tidn;
               assign xu_mm_msr_cm_sig[tid] = tidn;
               assign xu_mm_spr_epcr_dgtmi_sig[tid] = tidn;
                assign xu_mm_spr_epcr_dmiuh_sig[tid] = tidn;
               assign xu_rf1_flush_sig[tid] = tidn;
               assign xu_ex1_flush_sig[tid] = tidn;
               assign xu_ex2_flush_sig[tid] = tidn;
               assign xu_ex4_flush_sig[tid] = tidn;
               assign xu_ex5_flush_sig[tid] = tidn;
               assign xu_mm_rf1_val_sig[tid] = tidn;
            end
      end
   end
   endgenerate

   generate
      begin : xhdl1
//         genvar                                tid;
         for (tid = 0; tid <= `THDID_WIDTH - 1; tid = tid + 1)
         begin : mmDbgThreads
            if (tid < `MM_THREADS)
            begin : tidDbgExist
               assign tlb_mas_thdid_dbg[tid] = tlb_mas_thdid[tid];
               assign lrat_mas_thdid_dbg[tid] = lrat_mas_thdid[tid];
            end
         if (tid >= `MM_THREADS)
         begin : tidDbgNExist
            assign tlb_mas_thdid_dbg[tid] = tidn;
            assign lrat_mas_thdid_dbg[tid] = tidn;
         end
   end
end
endgenerate

generate
   begin : xhdl2
//      genvar                                tid;
      for (tid = 0; tid <= `THDID_WIDTH - 1; tid = tid + 1)
      begin : mmperfThreads
         if (tid < `THREADS)
         begin : tidperfExist
            assign xu_mm_msr_gs_perf[tid] = xu_mm_msr_gs[tid];
            assign xu_mm_msr_pr_perf[tid] = xu_mm_msr_gs[tid];
            assign xu_ex3_flush_sig[tid] = xu_ex3_flush[tid];
            assign xu_mm_ex4_flush_sig[tid] = xu_mm_ex4_flush[tid];
            assign xu_mm_ex5_flush_sig[tid] = xu_mm_ex5_flush[tid];
            assign lq_mm_perf_dtlb_sig[tid] = lq_mm_perf_dtlb[tid];
            assign iu_mm_perf_itlb_sig[tid] = iu_mm_perf_itlb[tid];
            assign xu_mm_derat_thdid_sig[tid] = xu_mm_derat_thdid[tid];
            assign xu_mm_ierat_flush_sig[tid] = xu_mm_ierat_flush[tid];
            assign xu_mm_ierat_miss_sig[tid] = xu_mm_ierat_miss[tid];
            assign iu_mm_ierat_thdid_sig[tid] = iu_mm_ierat_thdid[tid];
            assign iu_mm_ierat_flush_sig[tid] = iu_mm_ierat_flush[tid];
         end
      if (tid >= `THREADS)
      begin : tidperfNExist
         assign xu_mm_msr_gs_perf[tid] = tidn;
         assign xu_mm_msr_pr_perf[tid] = tidn;
         assign xu_ex3_flush_sig[tid] = tidn;
         assign xu_mm_ex4_flush_sig[tid] = tidn;
         assign xu_mm_ex5_flush_sig[tid] = tidn;
         assign lq_mm_perf_dtlb_sig[tid] = tidn;
         assign iu_mm_perf_itlb_sig[tid] = tidn;
         assign xu_mm_derat_thdid_sig[tid] = tidn;
         assign xu_mm_ierat_flush_sig[tid] = tidn;
         assign xu_mm_ierat_miss_sig[tid] = tidn;
         assign iu_mm_ierat_thdid_sig[tid] = tidn;
         assign iu_mm_ierat_flush_sig[tid] = tidn;
      end
end
end
endgenerate

//---------------------------------------------------------------------
// Invalidate Component Instantiation
//---------------------------------------------------------------------

mmq_inval #(.MMQ_INVAL_CSWITCH_0TO3(MMQ_INVAL_CSWITCH_0TO3)) mmq_inval(
  .vdd(vdd),
  .gnd(gnd),
  .nclk(nclk),
  .tc_ccflush_dc(tc_ac_ccflush_dc),
  .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
  .tc_scan_diag_dc(tc_ac_scan_diag_dc),
  .tc_lbist_en_dc(tc_ac_lbist_en_dc),

  .lcb_d_mode_dc(lcb_d_mode_dc),
  .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
  .lcb_act_dis_dc(lcb_act_dis_dc),
  .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
  .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
  .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

  .ac_func_scan_in(siv_0[mmq_inval_offset]),
  .ac_func_scan_out(sov_0[mmq_inval_offset]),

  .pc_sg_2(pc_sg_2[0]),
  .pc_func_sl_thold_2(pc_func_sl_thold_2[0]),
  .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[0]),
  .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
  .pc_fce_2(pc_fce_2),
  .mmucr2_act_override(mmucr2_sig[7]),
  .xu_mm_ccr2_notlb(xu_mm_hid_mmu_mode),
  .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b),

  .mm_iu_ierat_snoop_coming(mm_iu_ierat_snoop_coming),
  .mm_iu_ierat_snoop_val(mm_iu_ierat_snoop_val),
  .mm_iu_ierat_snoop_attr(mm_iu_ierat_snoop_attr),
  .mm_iu_ierat_snoop_vpn(mm_iu_ierat_snoop_vpn),
  .iu_mm_ierat_snoop_ack(iu_mm_ierat_snoop_ack),

  .mm_xu_derat_snoop_coming(mm_xu_derat_snoop_coming),
  .mm_xu_derat_snoop_val(mm_xu_derat_snoop_val),
  .mm_xu_derat_snoop_attr(mm_xu_derat_snoop_attr),
  .mm_xu_derat_snoop_vpn(mm_xu_derat_snoop_vpn),
  .xu_mm_derat_snoop_ack(xu_mm_derat_snoop_ack),

  .tlb_snoop_coming(tlb_snoop_coming),
  .tlb_snoop_val(tlb_snoop_val),
  .tlb_snoop_attr(tlb_snoop_attr),
  .tlb_snoop_vpn(tlb_snoop_vpn),
  .tlb_snoop_ack(tlb_snoop_ack),

  .tlb_ctl_barrier_done(tlb_ctl_barrier_done_sig),
  .tlb_ctl_ex2_flush_req(tlb_ctl_ex2_flush_req_sig),
  .tlb_ctl_ex2_illeg_instr(tlb_ctl_ex2_illeg_instr_sig),
  .tlb_ctl_ex6_illeg_instr(tlb_ctl_ex6_illeg_instr_sig),
  .tlb_ctl_ex2_itag(tlb_ctl_ex2_itag_sig),
  .tlb_ctl_ord_type(tlb_ctl_ord_type),
  .tlb_tag4_itag(tlb_tag4_itag_sig),
  .tlb_tag5_except(tlb_tag5_except),
  .tlb_ctl_quiesce(tlb_ctl_quiesce_sig),
  .tlb_req_quiesce(tlb_req_quiesce_sig[0:`MM_THREADS-1]),

  .mm_xu_ex3_flush_req(mm_xu_ex3_flush_req_sig),
  .mm_xu_illeg_instr(mm_xu_illeg_instr_sig),
  .mm_xu_local_snoop_reject(mm_xu_local_snoop_reject_sig),
  .mm_xu_ord_n_flush_req(mm_xu_ord_n_flush_req_sig),
  .mm_xu_ord_np1_flush_req(mm_xu_ord_np1_flush_req_sig),
  .mm_xu_ord_read_done(mm_xu_ord_read_done_sig),
  .mm_xu_ord_write_done(mm_xu_ord_write_done_sig),
  .mm_xu_illeg_instr_ored(mm_xu_illeg_instr_ored),
  .mm_xu_ord_n_flush_req_ored(mm_xu_ord_n_flush_req_ored),
  .mm_xu_ord_np1_flush_req_ored(mm_xu_ord_np1_flush_req_ored),
  .mm_xu_ord_read_done_ored(mm_xu_ord_read_done_ored),
  .mm_xu_ord_write_done_ored(mm_xu_ord_write_done_ored),

  .mm_xu_itag(mm_xu_itag),

  .mm_pc_local_snoop_reject_ored(mm_pc_local_snoop_reject_ored_sig),

  .an_ac_back_inv(an_ac_back_inv),
  .an_ac_back_inv_target(an_ac_back_inv_target),
  .an_ac_back_inv_local(an_ac_back_inv_local),
  .an_ac_back_inv_lbit(an_ac_back_inv_lbit),
  .an_ac_back_inv_gs(an_ac_back_inv_gs),
  .an_ac_back_inv_ind(an_ac_back_inv_ind),
  .an_ac_back_inv_addr(an_ac_back_inv_addr),
  .an_ac_back_inv_lpar_id(an_ac_back_inv_lpar_id),
  .ac_an_back_inv_reject(ac_an_back_inv_reject),
  .ac_an_power_managed(ac_an_power_managed_imm),
  .lpidr(lpidr_sig),
  .mas5_0_sgs(mas5_0_sgs),
  .mas5_0_slpid(mas5_0_slpid),
  .mas6_0_spid(mas6_0_spid),
  .mas6_0_isize(mas6_0_isize),
  .mas6_0_sind(mas6_0_sind),
  .mas6_0_sas(mas6_0_sas),
  .mmucr0_0(mmucr0_0_sig[2:19]),
`ifdef MM_THREADS2
  .mas5_1_sgs(mas5_1_sgs),
  .mas5_1_slpid(mas5_1_slpid),
  .mas6_1_spid(mas6_1_spid),
  .mas6_1_isize(mas6_1_isize),
  .mas6_1_sind(mas6_1_sind),
  .mas6_1_sas(mas6_1_sas),
  .mmucr0_1(mmucr0_1_sig[2:19]),
`endif
  .mmucr1(mmucr1_sig[12:19]),
  .mmucr1_csinv(mmucr1_sig[4:5]),
  .mmucsr0_tlb0fi(mmucsr0_tlb0fi),
  .mmq_inval_tlb0fi_done(mmq_inval_tlb0fi_done),

  .xu_mm_rf1_val(xu_mm_rf1_val_sig),
  .xu_mm_rf1_is_tlbivax(xu_mm_rf1_is_tlbivax),
  .xu_mm_rf1_is_tlbilx(xu_mm_rf1_is_tlbilx),
  .xu_mm_rf1_is_erativax(xu_mm_rf1_is_erativax),
  .xu_mm_rf1_is_eratilx(xu_mm_rf1_is_eratilx),
  .xu_mm_ex1_rs_is(xu_mm_ex1_rs_is),
  .xu_mm_ex1_is_isync(xu_mm_ex1_is_isync),
  .xu_mm_ex1_is_csync(xu_mm_ex1_is_csync),
  .xu_mm_ex2_eff_addr(xu_mm_ex2_eff_addr_sig),
  .xu_mm_rf1_t(xu_mm_rf1_t),
  .xu_mm_rf1_itag(xu_mm_rf1_itag),
  .xu_mm_msr_gs(xu_mm_msr_gs_sig),
  .xu_mm_msr_pr(xu_mm_msr_pr_sig),
  .xu_mm_spr_epcr_dgtmi(xu_mm_spr_epcr_dgtmi_sig),
  .xu_mm_epcr_dgtmi(xu_mm_epcr_dgtmi_sig),
  .xu_rf1_flush(xu_rf1_flush_sig),
  .xu_ex1_flush(xu_ex1_flush_sig),
  .xu_ex2_flush(xu_ex2_flush_sig),
  .xu_ex3_flush(xu_ex3_flush_sig[0:`MM_THREADS-1]),
  .xu_ex4_flush(xu_ex4_flush_sig),
  .xu_ex5_flush(xu_ex5_flush_sig),
  .xu_mm_lmq_stq_empty(xu_mm_lmq_stq_empty),
  .iu_mm_lmq_empty(iu_mm_lmq_empty),
  .iu_mm_hold_ack(iu_mm_hold_ack_sig),
  .mm_iu_hold_req(mm_iu_hold_req_sig),
  .mm_iu_hold_done(mm_iu_hold_done_sig),
  .mm_iu_flush_req(mm_iu_flush_req_sig),
  .iu_mm_bus_snoop_hold_ack(iu_mm_bus_snoop_hold_ack_sig),
  .mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req_sig),
  .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done_sig),
  .mm_iu_tlbi_complete(mm_iu_tlbi_complete_sig),

  .mm_xu_quiesce(mm_xu_quiesce_sig),
  .mm_pc_tlb_req_quiesce(mm_pc_tlb_req_quiesce_sig),
  .mm_pc_tlb_ctl_quiesce(mm_pc_tlb_ctl_quiesce_sig),
  .mm_pc_htw_quiesce(mm_pc_htw_quiesce_sig),
  .mm_pc_inval_quiesce(mm_pc_inval_quiesce_sig),
  .inval_perf_tlbilx(inval_perf_tlbilx),
  .inval_perf_tlbivax(inval_perf_tlbivax),
  .inval_perf_tlbivax_snoop(inval_perf_tlbivax_snoop),
  .inval_perf_tlb_flush(inval_perf_tlb_flush),

  .htw_lsu_req_valid(htw_lsu_req_valid),
  .htw_lsu_thdid(htw_lsu_thdid[0:`MM_THREADS-1]),
  .htw_lsu_ttype(htw_lsu_ttype),
  .htw_lsu_wimge(htw_lsu_wimge),
  .htw_lsu_u(htw_lsu_u),
  .htw_lsu_addr(htw_lsu_addr),
  .htw_lsu_req_taken(htw_lsu_req_taken),
  .htw_quiesce(htw_quiesce_sig[0:`MM_THREADS-1]),

  .tlbwe_back_inv_valid(tlbwe_back_inv_valid_sig),
  .tlbwe_back_inv_thdid(tlbwe_back_inv_thdid_sig),
  .tlbwe_back_inv_addr(tlbwe_back_inv_addr_sig),
  .tlbwe_back_inv_attr(tlbwe_back_inv_attr_sig),
  .tlbwe_back_inv_pending(tlbwe_back_inv_pending_sig),
  .tlb_tag5_write(tlb_tag5_write),

  .mm_xu_lsu_req(mm_xu_lsu_req_sig),
  .mm_xu_lsu_ttype(mm_xu_lsu_ttype_sig),
  .mm_xu_lsu_wimge(mm_xu_lsu_wimge_sig),
  .mm_xu_lsu_u(mm_xu_lsu_u_sig),
  .mm_xu_lsu_addr(mm_xu_lsu_addr_sig),
  .mm_xu_lsu_lpid(mm_xu_lsu_lpid_sig),
  .mm_xu_lsu_gs(mm_xu_lsu_gs_sig),
  .mm_xu_lsu_ind(mm_xu_lsu_ind_sig),
  .mm_xu_lsu_lbit(mm_xu_lsu_lbit_sig),
  .xu_mm_lsu_token(xu_mm_lsu_token),

  .inval_dbg_seq_q(inval_dbg_seq_q),
  .inval_dbg_seq_idle(inval_dbg_seq_idle),
  .inval_dbg_seq_snoop_inprogress(inval_dbg_seq_snoop_inprogress),
  .inval_dbg_seq_snoop_done(inval_dbg_seq_snoop_done),
  .inval_dbg_seq_local_done(inval_dbg_seq_local_done),
  .inval_dbg_seq_tlb0fi_done(inval_dbg_seq_tlb0fi_done),
  .inval_dbg_seq_tlbwe_snoop_done(inval_dbg_seq_tlbwe_snoop_done),
  .inval_dbg_ex6_valid(inval_dbg_ex6_valid),
  .inval_dbg_ex6_thdid(inval_dbg_ex6_thdid),
  .inval_dbg_ex6_ttype(inval_dbg_ex6_ttype),
  .inval_dbg_snoop_forme(inval_dbg_snoop_forme),
  .inval_dbg_snoop_local_reject(inval_dbg_snoop_local_reject),
  .inval_dbg_an_ac_back_inv_q(inval_dbg_an_ac_back_inv_q),
  .inval_dbg_an_ac_back_inv_lpar_id_q(inval_dbg_an_ac_back_inv_lpar_id_q),
  .inval_dbg_an_ac_back_inv_addr_q(inval_dbg_an_ac_back_inv_addr_q),
  .inval_dbg_snoop_valid_q(inval_dbg_snoop_valid_q),
  .inval_dbg_snoop_ack_q(inval_dbg_snoop_ack_q),
  .inval_dbg_snoop_attr_q(inval_dbg_snoop_attr_q),
  .inval_dbg_snoop_attr_tlb_spec_q(inval_dbg_snoop_attr_tlb_spec_q),
  .inval_dbg_snoop_vpn_q(inval_dbg_snoop_vpn_q),
  .inval_dbg_lsu_tokens_q(inval_dbg_lsu_tokens_q)
);
// End of mmq_inval component instantiation

//---------------------------------------------------------------------
// Special Purpose Register Component Instantiation
//---------------------------------------------------------------------

mmq_spr #(.BCFG_MMUCR1_VALUE(BCFG_MMUCR1_VALUE), .BCFG_MMUCR2_VALUE(BCFG_MMUCR2_VALUE), .BCFG_MMUCR3_VALUE(BCFG_MMUCR3_VALUE),
          .BCFG_MMUCFG_VALUE(BCFG_MMUCFG_VALUE), .BCFG_TLB0CFG_VALUE(BCFG_TLB0CFG_VALUE), .MMQ_SPR_CSWITCH_0TO3(MMQ_SPR_CSWITCH_0TO3)) mmq_spr(
  .vdd(vdd),
  .gnd(gnd),
  .nclk(nclk),
  .cp_flush(xu_ex5_flush[0:`THREADS - 1]),
  .cp_flush_p1(cp_flush_p1),
  .tc_ccflush_dc(tc_ac_ccflush_dc),
  .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
  .tc_scan_diag_dc(tc_ac_scan_diag_dc),
  .tc_lbist_en_dc(tc_ac_lbist_en_dc),

  .lcb_d_mode_dc(lcb_d_mode_dc),
  .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
  .lcb_act_dis_dc(lcb_act_dis_dc),
  .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
  .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
  .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

  .ac_func_scan_in( {siv_0[mmq_spr_offset_0], func_scan_in_int[1]} ),
  .ac_func_scan_out( {sov_0[mmq_spr_offset_0], func_scan_out_int[1]} ),
  .ac_bcfg_scan_in(bsiv[mmq_spr_bcfg_offset]),
  .ac_bcfg_scan_out(bsov[mmq_spr_bcfg_offset]),

  .pc_sg_2(pc_sg_2[0]),
  .pc_func_sl_thold_2(pc_func_sl_thold_2[0]),
  .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[0]),
  .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
  .pc_cfg_sl_thold_2(pc_cfg_sl_thold_2),
  .pc_cfg_slp_sl_thold_2(pc_cfg_slp_sl_thold_2),
  .pc_fce_2(pc_fce_2),
  .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[1]),
  .mmucr2_act_override(mmucr2_sig[5:6]),

  .tlb_delayed_act(tlb_delayed_act[29:29 + `MM_THREADS-1]),

`ifdef WAIT_UPDATES
  .cp_mm_except_taken_t0(cp_mm_except_taken_t0_sig),
`ifdef MM_THREADS2
  .cp_mm_except_taken_t1(cp_mm_except_taken_t1_sig),
`endif
  .cp_mm_perf_except_taken_q(cp_mm_perf_except_taken_q),
`endif

  .mm_iu_ierat_pid0(mm_iu_ierat_pid_sig[0]),
  .mm_iu_ierat_mmucr0_0(mm_iu_ierat_mmucr0_sig[0]),
`ifdef MM_THREADS2
  .mm_iu_ierat_pid1(mm_iu_ierat_pid_sig[1]),
  .mm_iu_ierat_mmucr0_1(mm_iu_ierat_mmucr0_sig[1]),
`endif
  .iu_mm_ierat_mmucr0(iu_mm_ierat_mmucr0),
  .iu_mm_ierat_mmucr0_we(iu_mm_ierat_mmucr0_we_sig),
  .mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1),
  .iu_mm_ierat_mmucr1(iu_mm_ierat_mmucr1),
  .iu_mm_ierat_mmucr1_we(iu_mm_ierat_mmucr1_we_sig),

  .mm_xu_derat_pid0(mm_xu_derat_pid_sig[0]),
  .mm_xu_derat_mmucr0_0(mm_xu_derat_mmucr0_sig[0]),
`ifdef MM_THREADS2
  .mm_xu_derat_pid1(mm_xu_derat_pid_sig[1]),
  .mm_xu_derat_mmucr0_1(mm_xu_derat_mmucr0_sig[1]),
`endif
  .xu_mm_derat_mmucr0(xu_mm_derat_mmucr0),
  .xu_mm_derat_mmucr0_we(xu_mm_derat_mmucr0_we_sig),
  .mm_xu_derat_mmucr1(mm_xu_derat_mmucr1),
  .xu_mm_derat_mmucr1(xu_mm_derat_mmucr1),
  .xu_mm_derat_mmucr1_we(xu_mm_derat_mmucr1_we_sig),

  .pid0(pid0_sig),
  .mmucr0_0(mmucr0_0_sig),
  .mmucr3_0(mmucr3_0_sig),
  .tstmode4k_0(tstmode4k_0_sig),
`ifdef MM_THREADS2
  .pid1(pid1_sig),
  .mmucr0_1(mmucr0_1_sig),
  .mmucr3_1(mmucr3_1_sig),
  .tstmode4k_1(tstmode4k_1_sig),
`endif
  .mmucr1(mmucr1_sig),
  .mmucr2(mmucr2_sig),
  .mmucfg_lrat(mmucfg_lrat),
  .mmucfg_twc(mmucfg_twc),
  .tlb0cfg_pt(tlb0cfg_pt),
  .tlb0cfg_ind(tlb0cfg_ind),
  .tlb0cfg_gtwe(tlb0cfg_gtwe),
  .mmq_spr_event_mux_ctrls(mmq_spr_event_mux_ctrls_sig),
  .mas0_0_atsel(mas0_0_atsel),
  .mas0_0_esel(mas0_0_esel),
  .mas0_0_hes(mas0_0_hes),
  .mas0_0_wq(mas0_0_wq),
  .mas1_0_v(mas1_0_v),
  .mas1_0_iprot(mas1_0_iprot),
  .mas1_0_tid(mas1_0_tid),
  .mas1_0_ind(mas1_0_ind),
  .mas1_0_ts(mas1_0_ts),
  .mas1_0_tsize(mas1_0_tsize),
  .mas2_0_epn(mas2_0_epn),
  .mas2_0_wimge(mas2_0_wimge),
  .mas3_0_rpnl(mas3_0_rpnl),
  .mas3_0_ubits(mas3_0_ubits),
  .mas3_0_usxwr(mas3_0_usxwr),
  .mas5_0_sgs(mas5_0_sgs),
  .mas5_0_slpid(mas5_0_slpid),
  .mas6_0_spid(mas6_0_spid),
  .mas6_0_isize(mas6_0_isize),
  .mas6_0_sind(mas6_0_sind),
  .mas6_0_sas(mas6_0_sas),
  .mas7_0_rpnu(mas7_0_rpnu),
  .mas8_0_tgs(mas8_0_tgs),
  .mas8_0_vf(mas8_0_vf),
  .mas8_0_tlpid(mas8_0_tlpid),
`ifdef MM_THREADS2
  .mas0_1_atsel(mas0_1_atsel),
  .mas0_1_esel(mas0_1_esel),
  .mas0_1_hes(mas0_1_hes),
  .mas0_1_wq(mas0_1_wq),
  .mas1_1_v(mas1_1_v),
  .mas1_1_iprot(mas1_1_iprot),
  .mas1_1_tid(mas1_1_tid),
  .mas1_1_ind(mas1_1_ind),
  .mas1_1_ts(mas1_1_ts),
  .mas1_1_tsize(mas1_1_tsize),
  .mas2_1_epn(mas2_1_epn),
  .mas2_1_wimge(mas2_1_wimge),
  .mas3_1_rpnl(mas3_1_rpnl),
  .mas3_1_ubits(mas3_1_ubits),
  .mas3_1_usxwr(mas3_1_usxwr),
  .mas5_1_sgs(mas5_1_sgs),
  .mas5_1_slpid(mas5_1_slpid),
  .mas6_1_spid(mas6_1_spid),
  .mas6_1_isize(mas6_1_isize),
  .mas6_1_sind(mas6_1_sind),
  .mas6_1_sas(mas6_1_sas),
  .mas7_1_rpnu(mas7_1_rpnu),
  .mas8_1_tgs(mas8_1_tgs),
  .mas8_1_vf(mas8_1_vf),
  .mas8_1_tlpid(mas8_1_tlpid),
`endif
  .tlb_mas0_esel(tlb_mas0_esel),
  .tlb_mas1_v(tlb_mas1_v),
  .tlb_mas1_iprot(tlb_mas1_iprot),
  .tlb_mas1_tid(tlb_mas1_tid),
  .tlb_mas1_tid_error(tlb_mas1_tid_error),
  .tlb_mas1_ind(tlb_mas1_ind),
  .tlb_mas1_ts(tlb_mas1_ts),
  .tlb_mas1_ts_error(tlb_mas1_ts_error),
  .tlb_mas1_tsize(tlb_mas1_tsize),
  .tlb_mas2_epn(tlb_mas2_epn),
  .tlb_mas2_epn_error(tlb_mas2_epn_error),
  .tlb_mas2_wimge(tlb_mas2_wimge),
  .tlb_mas3_rpnl(tlb_mas3_rpnl),
  .tlb_mas3_ubits(tlb_mas3_ubits),
  .tlb_mas3_usxwr(tlb_mas3_usxwr),
  .tlb_mas7_rpnu(tlb_mas7_rpnu),
  .tlb_mas8_tgs(tlb_mas8_tgs),
  .tlb_mas8_vf(tlb_mas8_vf),
  .tlb_mas8_tlpid(tlb_mas8_tlpid),

  .tlb_mmucr1_een(tlb_mmucr1_een),
  .tlb_mmucr1_we(tlb_mmucr1_we),
  .tlb_mmucr3_thdid(tlb_mmucr3_thdid),
  .tlb_mmucr3_resvattr(tlb_mmucr3_resvattr),
  .tlb_mmucr3_wlc(tlb_mmucr3_wlc),
  .tlb_mmucr3_class(tlb_mmucr3_class),
  .tlb_mmucr3_extclass(tlb_mmucr3_extclass),
  .tlb_mmucr3_rc(tlb_mmucr3_rc),
  .tlb_mmucr3_x(tlb_mmucr3_x),
  .tlb_mas_tlbre(tlb_mas_tlbre),
  .tlb_mas_tlbsx_hit(tlb_mas_tlbsx_hit),
  .tlb_mas_tlbsx_miss(tlb_mas_tlbsx_miss),
  .tlb_mas_dtlb_error(tlb_mas_dtlb_error),
  .tlb_mas_itlb_error(tlb_mas_itlb_error),
  .tlb_mas_thdid(tlb_mas_thdid),

  .mmucsr0_tlb0fi(mmucsr0_tlb0fi),
  .mmq_inval_tlb0fi_done(mmq_inval_tlb0fi_done),

  .lrat_mmucr3_x(lrat_mmucr3_x),
  .lrat_mas0_esel(lrat_mas0_esel),
  .lrat_mas1_v(lrat_mas1_v),
  .lrat_mas1_tsize(lrat_mas1_tsize),
  .lrat_mas2_epn(lrat_mas2_epn),
  .lrat_mas3_rpnl(lrat_mas3_rpnl),
  .lrat_mas7_rpnu(lrat_mas7_rpnu),
  .lrat_mas8_tlpid(lrat_mas8_tlpid),
  .lrat_mas_tlbre(lrat_mas_tlbre),
  .lrat_mas_tlbsx_hit(lrat_mas_tlbsx_hit),
  .lrat_mas_tlbsx_miss(lrat_mas_tlbsx_miss),
  .lrat_mas_thdid(lrat_mas_thdid),
  .lrat_tag4_hit_entry(lrat_tag4_hit_entry),

  .tlb_lper_lpn(tlb_lper_lpn),
  .tlb_lper_lps(tlb_lper_lps),
  .tlb_lper_we(tlb_lper_we),

  .lpidr(lpidr_sig),
  .ac_an_lpar_id(ac_an_lpar_id_sig),

  .spr_dbg_match_64b(spr_dbg_match_64b),
  .spr_dbg_match_any_mmu(spr_dbg_match_any_mmu),
  .spr_dbg_match_any_mas(spr_dbg_match_any_mas),
  .spr_dbg_match_pid(spr_dbg_match_pid),
  .spr_dbg_match_lpidr(spr_dbg_match_lpidr),
  .spr_dbg_match_mmucr0(spr_dbg_match_mmucr0),
  .spr_dbg_match_mmucr1(spr_dbg_match_mmucr1),
  .spr_dbg_match_mmucr2(spr_dbg_match_mmucr2),
  .spr_dbg_match_mmucr3(spr_dbg_match_mmucr3),

  .spr_dbg_match_mmucsr0(spr_dbg_match_mmucsr0),
  .spr_dbg_match_mmucfg(spr_dbg_match_mmucfg),
  .spr_dbg_match_tlb0cfg(spr_dbg_match_tlb0cfg),
  .spr_dbg_match_tlb0ps(spr_dbg_match_tlb0ps),
  .spr_dbg_match_lratcfg(spr_dbg_match_lratcfg),
  .spr_dbg_match_lratps(spr_dbg_match_lratps),
  .spr_dbg_match_eptcfg(spr_dbg_match_eptcfg),
  .spr_dbg_match_lper(spr_dbg_match_lper),
  .spr_dbg_match_lperu(spr_dbg_match_lperu),

  .spr_dbg_match_mas0(spr_dbg_match_mas0),
  .spr_dbg_match_mas1(spr_dbg_match_mas1),
  .spr_dbg_match_mas2(spr_dbg_match_mas2),
  .spr_dbg_match_mas2u(spr_dbg_match_mas2u),
  .spr_dbg_match_mas3(spr_dbg_match_mas3),
  .spr_dbg_match_mas4(spr_dbg_match_mas4),
  .spr_dbg_match_mas5(spr_dbg_match_mas5),
  .spr_dbg_match_mas6(spr_dbg_match_mas6),
  .spr_dbg_match_mas7(spr_dbg_match_mas7),
  .spr_dbg_match_mas8(spr_dbg_match_mas8),
  .spr_dbg_match_mas01_64b(spr_dbg_match_mas01_64b),
  .spr_dbg_match_mas56_64b(spr_dbg_match_mas56_64b),
  .spr_dbg_match_mas73_64b(spr_dbg_match_mas73_64b),
  .spr_dbg_match_mas81_64b(spr_dbg_match_mas81_64b),

  .spr_dbg_slowspr_val_int(spr_dbg_slowspr_val_int),
  .spr_dbg_slowspr_rw_int(spr_dbg_slowspr_rw_int),
  .spr_dbg_slowspr_etid_int(spr_dbg_slowspr_etid_int),
  .spr_dbg_slowspr_addr_int(spr_dbg_slowspr_addr_int),
  .spr_dbg_slowspr_val_out(spr_dbg_slowspr_val_out),
  .spr_dbg_slowspr_done_out(spr_dbg_slowspr_done_out),
  .spr_dbg_slowspr_data_out(spr_dbg_slowspr_data_out),

  .xu_mm_slowspr_val(slowspr_val_in),
  .xu_mm_slowspr_rw(slowspr_rw_in),
  .xu_mm_slowspr_etid(slowspr_etid_in),
  .xu_mm_slowspr_addr(slowspr_addr_in),
  .xu_mm_slowspr_data(slowspr_data_in),
  .xu_mm_slowspr_done(slowspr_done_in),

  .mm_iu_slowspr_val(slowspr_val_out),
  .mm_iu_slowspr_rw(slowspr_rw_out),
  .mm_iu_slowspr_etid(slowspr_etid_out),
  .mm_iu_slowspr_addr(slowspr_addr_out),
  .mm_iu_slowspr_data(slowspr_data_out),

  .mm_iu_slowspr_done(slowspr_done_out)

);
// End of mmq_spr component instantiation


//---------------------------------------------------------------------
// Debug Trace component instantiation
//---------------------------------------------------------------------

//work.mmq_dbg #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`TLB_TAG_WIDTH(`TLB_TAG_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_dbg(
mmq_dbg  mmq_dbg(
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[0]),
   .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
   .pc_sg_2(pc_sg_2[0]),
   .pc_fce_2(pc_fce_2),
   .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
   .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
   .lcb_act_dis_dc(lcb_act_dis_dc),
   .lcb_d_mode_dc(lcb_d_mode_dc),
   .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
   .lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
   .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
   .scan_in(siv_1[mmq_dbg_offset]),
   .scan_out(sov_1[mmq_dbg_offset]),

   .mmucr2(mmucr2_sig[8:11]),
   .pc_mm_trace_bus_enable(pc_mm_trace_bus_enable),
   .pc_mm_debug_mux1_ctrls(pc_mm_debug_mux1_ctrls),

   .debug_bus_in(debug_bus_in),
   .debug_bus_out(debug_bus_out),

// Instruction Trace (HTM) Control Signals:
//  0    - ac_an_coretrace_first_valid
//  1    - ac_an_coretrace_valid
//  2:3  - ac_an_coretrace_type[0:1]
   .coretrace_ctrls_in(coretrace_ctrls_in),           // input  [0:3]
   .coretrace_ctrls_out(coretrace_ctrls_out),         // output [0:3]

   .spr_dbg_match_64b(spr_dbg_match_64b),
   .spr_dbg_match_any_mmu(spr_dbg_match_any_mmu),
   .spr_dbg_match_any_mas(spr_dbg_match_any_mas),
   .spr_dbg_match_pid(spr_dbg_match_pid),
   .spr_dbg_match_lpidr(spr_dbg_match_lpidr),
   .spr_dbg_match_mmucr0(spr_dbg_match_mmucr0),
   .spr_dbg_match_mmucr1(spr_dbg_match_mmucr1),
   .spr_dbg_match_mmucr2(spr_dbg_match_mmucr2),
   .spr_dbg_match_mmucr3(spr_dbg_match_mmucr3),

   .spr_dbg_match_mmucsr0(spr_dbg_match_mmucsr0),
   .spr_dbg_match_mmucfg(spr_dbg_match_mmucfg),
   .spr_dbg_match_tlb0cfg(spr_dbg_match_tlb0cfg),
   .spr_dbg_match_tlb0ps(spr_dbg_match_tlb0ps),
   .spr_dbg_match_lratcfg(spr_dbg_match_lratcfg),
   .spr_dbg_match_lratps(spr_dbg_match_lratps),
   .spr_dbg_match_eptcfg(spr_dbg_match_eptcfg),
   .spr_dbg_match_lper(spr_dbg_match_lper),
   .spr_dbg_match_lperu(spr_dbg_match_lperu),

   .spr_dbg_match_mas0(spr_dbg_match_mas0),
   .spr_dbg_match_mas1(spr_dbg_match_mas1),
   .spr_dbg_match_mas2(spr_dbg_match_mas2),
   .spr_dbg_match_mas2u(spr_dbg_match_mas2u),
   .spr_dbg_match_mas3(spr_dbg_match_mas3),
   .spr_dbg_match_mas4(spr_dbg_match_mas4),
   .spr_dbg_match_mas5(spr_dbg_match_mas5),
   .spr_dbg_match_mas6(spr_dbg_match_mas6),
   .spr_dbg_match_mas7(spr_dbg_match_mas7),
   .spr_dbg_match_mas8(spr_dbg_match_mas8),
   .spr_dbg_match_mas01_64b(spr_dbg_match_mas01_64b),
   .spr_dbg_match_mas56_64b(spr_dbg_match_mas56_64b),
   .spr_dbg_match_mas73_64b(spr_dbg_match_mas73_64b),
   .spr_dbg_match_mas81_64b(spr_dbg_match_mas81_64b),

   .spr_dbg_slowspr_val_int(spr_dbg_slowspr_val_int),
   .spr_dbg_slowspr_rw_int(spr_dbg_slowspr_rw_int),
   .spr_dbg_slowspr_etid_int(spr_dbg_slowspr_etid_int),
   .spr_dbg_slowspr_addr_int(spr_dbg_slowspr_addr_int),
   .spr_dbg_slowspr_val_out(spr_dbg_slowspr_val_out),
   .spr_dbg_slowspr_done_out(spr_dbg_slowspr_done_out),
   .spr_dbg_slowspr_data_out(spr_dbg_slowspr_data_out),
   .inval_dbg_seq_q(inval_dbg_seq_q),
   .inval_dbg_seq_idle(inval_dbg_seq_idle),
   .inval_dbg_seq_snoop_inprogress(inval_dbg_seq_snoop_inprogress),
   .inval_dbg_seq_snoop_done(inval_dbg_seq_snoop_done),
   .inval_dbg_seq_local_done(inval_dbg_seq_local_done),
   .inval_dbg_seq_tlb0fi_done(inval_dbg_seq_tlb0fi_done),
   .inval_dbg_seq_tlbwe_snoop_done(inval_dbg_seq_tlbwe_snoop_done),
   .inval_dbg_ex6_valid(inval_dbg_ex6_valid),
   .inval_dbg_ex6_thdid(inval_dbg_ex6_thdid),
   .inval_dbg_ex6_ttype(inval_dbg_ex6_ttype),
   .inval_dbg_snoop_forme(inval_dbg_snoop_forme),
   .inval_dbg_snoop_local_reject(inval_dbg_snoop_local_reject),
   .inval_dbg_an_ac_back_inv_q(inval_dbg_an_ac_back_inv_q),
   .inval_dbg_an_ac_back_inv_lpar_id_q(inval_dbg_an_ac_back_inv_lpar_id_q),
   .inval_dbg_an_ac_back_inv_addr_q(inval_dbg_an_ac_back_inv_addr_q),
   .inval_dbg_snoop_valid_q(inval_dbg_snoop_valid_q),
   .inval_dbg_snoop_ack_q(inval_dbg_snoop_ack_q),
   .inval_dbg_snoop_attr_q(inval_dbg_snoop_attr_q),
   .inval_dbg_snoop_attr_tlb_spec_q(inval_dbg_snoop_attr_tlb_spec_q),
   .inval_dbg_snoop_vpn_q(inval_dbg_snoop_vpn_q),
   .inval_dbg_lsu_tokens_q(inval_dbg_lsu_tokens_q),
   .tlb_req_dbg_ierat_iu5_valid_q(tlb_req_dbg_ierat_iu5_valid_q),
   .tlb_req_dbg_ierat_iu5_thdid(tlb_req_dbg_ierat_iu5_thdid),
   .tlb_req_dbg_ierat_iu5_state_q(tlb_req_dbg_ierat_iu5_state_q),
   .tlb_req_dbg_ierat_inptr_q(tlb_req_dbg_ierat_inptr_q),
   .tlb_req_dbg_ierat_outptr_q(tlb_req_dbg_ierat_outptr_q),
   .tlb_req_dbg_ierat_req_valid_q(tlb_req_dbg_ierat_req_valid_q),
   .tlb_req_dbg_ierat_req_nonspec_q(tlb_req_dbg_ierat_req_nonspec_q),
   .tlb_req_dbg_ierat_req_thdid(tlb_req_dbg_ierat_req_thdid),
   .tlb_req_dbg_ierat_req_dup_q(tlb_req_dbg_ierat_req_dup_q),
   .tlb_req_dbg_derat_ex6_valid_q(tlb_req_dbg_derat_ex6_valid_q),
   .tlb_req_dbg_derat_ex6_thdid(tlb_req_dbg_derat_ex6_thdid),
   .tlb_req_dbg_derat_ex6_state_q(tlb_req_dbg_derat_ex6_state_q),
   .tlb_req_dbg_derat_inptr_q(tlb_req_dbg_derat_inptr_q),
   .tlb_req_dbg_derat_outptr_q(tlb_req_dbg_derat_outptr_q),
   .tlb_req_dbg_derat_req_valid_q(tlb_req_dbg_derat_req_valid_q),
   .tlb_req_dbg_derat_req_thdid(tlb_req_dbg_derat_req_thdid),
   .tlb_req_dbg_derat_req_ttype_q(tlb_req_dbg_derat_req_ttype_q),
   .tlb_req_dbg_derat_req_dup_q(tlb_req_dbg_derat_req_dup_q),

   .tlb_ctl_dbg_seq_q(tlb_ctl_dbg_seq_q),
   .tlb_ctl_dbg_seq_idle(tlb_ctl_dbg_seq_idle),
   .tlb_ctl_dbg_seq_any_done_sig(tlb_ctl_dbg_seq_any_done_sig),
   .tlb_ctl_dbg_seq_abort(tlb_ctl_dbg_seq_abort),
   .tlb_ctl_dbg_any_tlb_req_sig(tlb_ctl_dbg_any_tlb_req_sig),
   .tlb_ctl_dbg_any_req_taken_sig(tlb_ctl_dbg_any_req_taken_sig),
   .tlb_ctl_dbg_tag0_valid(tlb_ctl_dbg_tag0_valid),
   .tlb_ctl_dbg_tag0_thdid(tlb_ctl_dbg_tag0_thdid),
   .tlb_ctl_dbg_tag0_type(tlb_ctl_dbg_tag0_type),
   .tlb_ctl_dbg_tag0_wq(tlb_ctl_dbg_tag0_wq),
   .tlb_ctl_dbg_tag0_gs(tlb_ctl_dbg_tag0_gs),
   .tlb_ctl_dbg_tag0_pr(tlb_ctl_dbg_tag0_pr),
   .tlb_ctl_dbg_tag0_atsel(tlb_ctl_dbg_tag0_atsel),
   .tlb_ctl_dbg_tag5_tlb_write_q(tlb_ctl_dbg_tag5_tlb_write_q),
   .tlb_ctl_dbg_resv_valid(tlb_ctl_dbg_resv_valid),
   .tlb_ctl_dbg_set_resv(tlb_ctl_dbg_set_resv),
   .tlb_ctl_dbg_resv_match_vec_q(tlb_ctl_dbg_resv_match_vec_q),
   .tlb_ctl_dbg_any_tag_flush_sig(tlb_ctl_dbg_any_tag_flush_sig),
   .tlb_ctl_dbg_resv0_tag0_lpid_match(tlb_ctl_dbg_resv0_tag0_lpid_match),
   .tlb_ctl_dbg_resv0_tag0_pid_match(tlb_ctl_dbg_resv0_tag0_pid_match),
   .tlb_ctl_dbg_resv0_tag0_as_snoop_match(tlb_ctl_dbg_resv0_tag0_as_snoop_match),
   .tlb_ctl_dbg_resv0_tag0_gs_snoop_match(tlb_ctl_dbg_resv0_tag0_gs_snoop_match),
   .tlb_ctl_dbg_resv0_tag0_as_tlbwe_match(tlb_ctl_dbg_resv0_tag0_as_tlbwe_match),
   .tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match),
   .tlb_ctl_dbg_resv0_tag0_ind_match(tlb_ctl_dbg_resv0_tag0_ind_match),
   .tlb_ctl_dbg_resv0_tag0_epn_loc_match(tlb_ctl_dbg_resv0_tag0_epn_loc_match),
   .tlb_ctl_dbg_resv0_tag0_epn_glob_match(tlb_ctl_dbg_resv0_tag0_epn_glob_match),
   .tlb_ctl_dbg_resv0_tag0_class_match(tlb_ctl_dbg_resv0_tag0_class_match),
   .tlb_ctl_dbg_resv1_tag0_lpid_match(tlb_ctl_dbg_resv1_tag0_lpid_match),
   .tlb_ctl_dbg_resv1_tag0_pid_match(tlb_ctl_dbg_resv1_tag0_pid_match),
   .tlb_ctl_dbg_resv1_tag0_as_snoop_match(tlb_ctl_dbg_resv1_tag0_as_snoop_match),
   .tlb_ctl_dbg_resv1_tag0_gs_snoop_match(tlb_ctl_dbg_resv1_tag0_gs_snoop_match),
   .tlb_ctl_dbg_resv1_tag0_as_tlbwe_match(tlb_ctl_dbg_resv1_tag0_as_tlbwe_match),
   .tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match),
   .tlb_ctl_dbg_resv1_tag0_ind_match(tlb_ctl_dbg_resv1_tag0_ind_match),
   .tlb_ctl_dbg_resv1_tag0_epn_loc_match(tlb_ctl_dbg_resv1_tag0_epn_loc_match),
   .tlb_ctl_dbg_resv1_tag0_epn_glob_match(tlb_ctl_dbg_resv1_tag0_epn_glob_match),
   .tlb_ctl_dbg_resv1_tag0_class_match(tlb_ctl_dbg_resv1_tag0_class_match),
   .tlb_ctl_dbg_resv2_tag0_lpid_match(tlb_ctl_dbg_resv2_tag0_lpid_match),
   .tlb_ctl_dbg_resv2_tag0_pid_match(tlb_ctl_dbg_resv2_tag0_pid_match),
   .tlb_ctl_dbg_resv2_tag0_as_snoop_match(tlb_ctl_dbg_resv2_tag0_as_snoop_match),
   .tlb_ctl_dbg_resv2_tag0_gs_snoop_match(tlb_ctl_dbg_resv2_tag0_gs_snoop_match),
   .tlb_ctl_dbg_resv2_tag0_as_tlbwe_match(tlb_ctl_dbg_resv2_tag0_as_tlbwe_match),
   .tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match),
   .tlb_ctl_dbg_resv2_tag0_ind_match(tlb_ctl_dbg_resv2_tag0_ind_match),
   .tlb_ctl_dbg_resv2_tag0_epn_loc_match(tlb_ctl_dbg_resv2_tag0_epn_loc_match),
   .tlb_ctl_dbg_resv2_tag0_epn_glob_match(tlb_ctl_dbg_resv2_tag0_epn_glob_match),
   .tlb_ctl_dbg_resv2_tag0_class_match(tlb_ctl_dbg_resv2_tag0_class_match),
   .tlb_ctl_dbg_resv3_tag0_lpid_match(tlb_ctl_dbg_resv3_tag0_lpid_match),
   .tlb_ctl_dbg_resv3_tag0_pid_match(tlb_ctl_dbg_resv3_tag0_pid_match),
   .tlb_ctl_dbg_resv3_tag0_as_snoop_match(tlb_ctl_dbg_resv3_tag0_as_snoop_match),
   .tlb_ctl_dbg_resv3_tag0_gs_snoop_match(tlb_ctl_dbg_resv3_tag0_gs_snoop_match),
   .tlb_ctl_dbg_resv3_tag0_as_tlbwe_match(tlb_ctl_dbg_resv3_tag0_as_tlbwe_match),
   .tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match),
   .tlb_ctl_dbg_resv3_tag0_ind_match(tlb_ctl_dbg_resv3_tag0_ind_match),
   .tlb_ctl_dbg_resv3_tag0_epn_loc_match(tlb_ctl_dbg_resv3_tag0_epn_loc_match),
   .tlb_ctl_dbg_resv3_tag0_epn_glob_match(tlb_ctl_dbg_resv3_tag0_epn_glob_match),
   .tlb_ctl_dbg_resv3_tag0_class_match(tlb_ctl_dbg_resv3_tag0_class_match),
   .tlb_ctl_dbg_clr_resv_q(tlb_ctl_dbg_clr_resv_q),
   .tlb_ctl_dbg_clr_resv_terms(tlb_ctl_dbg_clr_resv_terms),
   .tlb_cmp_dbg_tag4(tlb_cmp_dbg_tag4),
   .tlb_cmp_dbg_tag4_wayhit(tlb_cmp_dbg_tag4_wayhit),
   .tlb_cmp_dbg_addr4(tlb_cmp_dbg_addr4),
   .tlb_cmp_dbg_tag4_way(tlb_cmp_dbg_tag4_way),
   .tlb_cmp_dbg_tag4_parerr(tlb_cmp_dbg_tag4_parerr),
   .tlb_cmp_dbg_tag4_lru_dataout_q(tlb_cmp_dbg_tag4_lru_dataout_q),
   .tlb_cmp_dbg_tag5_tlb_datain_q(tlb_cmp_dbg_tag5_tlb_datain_q),
   .tlb_cmp_dbg_tag5_lru_datain_q(tlb_cmp_dbg_tag5_lru_datain_q),
   .tlb_cmp_dbg_tag5_lru_write(tlb_cmp_dbg_tag5_lru_write),
   .tlb_cmp_dbg_tag5_any_exception(tlb_cmp_dbg_tag5_any_exception),
   .tlb_cmp_dbg_tag5_except_type_q(tlb_cmp_dbg_tag5_except_type_q),
   .tlb_cmp_dbg_tag5_except_thdid_q(tlb_cmp_dbg_tag5_except_thdid_q),
   .tlb_cmp_dbg_tag5_erat_rel_val(tlb_cmp_dbg_tag5_erat_rel_val),
   .tlb_cmp_dbg_tag5_erat_rel_data(tlb_cmp_dbg_tag5_erat_rel_data),
   .tlb_cmp_dbg_erat_dup_q(tlb_cmp_dbg_erat_dup_q),
   .tlb_cmp_dbg_addr_enable(tlb_cmp_dbg_addr_enable),
   .tlb_cmp_dbg_pgsize_enable(tlb_cmp_dbg_pgsize_enable),
   .tlb_cmp_dbg_class_enable(tlb_cmp_dbg_class_enable),
   .tlb_cmp_dbg_extclass_enable(tlb_cmp_dbg_extclass_enable),
   .tlb_cmp_dbg_state_enable(tlb_cmp_dbg_state_enable),
   .tlb_cmp_dbg_thdid_enable(tlb_cmp_dbg_thdid_enable),
   .tlb_cmp_dbg_pid_enable(tlb_cmp_dbg_pid_enable),
   .tlb_cmp_dbg_lpid_enable(tlb_cmp_dbg_lpid_enable),
   .tlb_cmp_dbg_ind_enable(tlb_cmp_dbg_ind_enable),
   .tlb_cmp_dbg_iprot_enable(tlb_cmp_dbg_iprot_enable),
   .tlb_cmp_dbg_way0_entry_v(tlb_cmp_dbg_way0_entry_v),
   .tlb_cmp_dbg_way0_addr_match(tlb_cmp_dbg_way0_addr_match),
   .tlb_cmp_dbg_way0_pgsize_match(tlb_cmp_dbg_way0_pgsize_match),
   .tlb_cmp_dbg_way0_class_match(tlb_cmp_dbg_way0_class_match),
   .tlb_cmp_dbg_way0_extclass_match(tlb_cmp_dbg_way0_extclass_match),
   .tlb_cmp_dbg_way0_state_match(tlb_cmp_dbg_way0_state_match),
   .tlb_cmp_dbg_way0_thdid_match(tlb_cmp_dbg_way0_thdid_match),
   .tlb_cmp_dbg_way0_pid_match(tlb_cmp_dbg_way0_pid_match),
   .tlb_cmp_dbg_way0_lpid_match(tlb_cmp_dbg_way0_lpid_match),
   .tlb_cmp_dbg_way0_ind_match(tlb_cmp_dbg_way0_ind_match),
   .tlb_cmp_dbg_way0_iprot_match(tlb_cmp_dbg_way0_iprot_match),
   .tlb_cmp_dbg_way1_entry_v(tlb_cmp_dbg_way1_entry_v),
   .tlb_cmp_dbg_way1_addr_match(tlb_cmp_dbg_way1_addr_match),
   .tlb_cmp_dbg_way1_pgsize_match(tlb_cmp_dbg_way1_pgsize_match),
   .tlb_cmp_dbg_way1_class_match(tlb_cmp_dbg_way1_class_match),
   .tlb_cmp_dbg_way1_extclass_match(tlb_cmp_dbg_way1_extclass_match),
   .tlb_cmp_dbg_way1_state_match(tlb_cmp_dbg_way1_state_match),
   .tlb_cmp_dbg_way1_thdid_match(tlb_cmp_dbg_way1_thdid_match),
   .tlb_cmp_dbg_way1_pid_match(tlb_cmp_dbg_way1_pid_match),
   .tlb_cmp_dbg_way1_lpid_match(tlb_cmp_dbg_way1_lpid_match),
   .tlb_cmp_dbg_way1_ind_match(tlb_cmp_dbg_way1_ind_match),
   .tlb_cmp_dbg_way1_iprot_match(tlb_cmp_dbg_way1_iprot_match),
   .tlb_cmp_dbg_way2_entry_v(tlb_cmp_dbg_way2_entry_v),
   .tlb_cmp_dbg_way2_addr_match(tlb_cmp_dbg_way2_addr_match),
   .tlb_cmp_dbg_way2_pgsize_match(tlb_cmp_dbg_way2_pgsize_match),
   .tlb_cmp_dbg_way2_class_match(tlb_cmp_dbg_way2_class_match),
   .tlb_cmp_dbg_way2_extclass_match(tlb_cmp_dbg_way2_extclass_match),
   .tlb_cmp_dbg_way2_state_match(tlb_cmp_dbg_way2_state_match),
   .tlb_cmp_dbg_way2_thdid_match(tlb_cmp_dbg_way2_thdid_match),
   .tlb_cmp_dbg_way2_pid_match(tlb_cmp_dbg_way2_pid_match),
   .tlb_cmp_dbg_way2_lpid_match(tlb_cmp_dbg_way2_lpid_match),
   .tlb_cmp_dbg_way2_ind_match(tlb_cmp_dbg_way2_ind_match),
   .tlb_cmp_dbg_way2_iprot_match(tlb_cmp_dbg_way2_iprot_match),
   .tlb_cmp_dbg_way3_entry_v(tlb_cmp_dbg_way3_entry_v),
   .tlb_cmp_dbg_way3_addr_match(tlb_cmp_dbg_way3_addr_match),
   .tlb_cmp_dbg_way3_pgsize_match(tlb_cmp_dbg_way3_pgsize_match),
   .tlb_cmp_dbg_way3_class_match(tlb_cmp_dbg_way3_class_match),
   .tlb_cmp_dbg_way3_extclass_match(tlb_cmp_dbg_way3_extclass_match),
   .tlb_cmp_dbg_way3_state_match(tlb_cmp_dbg_way3_state_match),
   .tlb_cmp_dbg_way3_thdid_match(tlb_cmp_dbg_way3_thdid_match),
   .tlb_cmp_dbg_way3_pid_match(tlb_cmp_dbg_way3_pid_match),
   .tlb_cmp_dbg_way3_lpid_match(tlb_cmp_dbg_way3_lpid_match),
   .tlb_cmp_dbg_way3_ind_match(tlb_cmp_dbg_way3_ind_match),
   .tlb_cmp_dbg_way3_iprot_match(tlb_cmp_dbg_way3_iprot_match),

   .lrat_dbg_tag1_addr_enable(lrat_dbg_tag1_addr_enable),
   .lrat_dbg_tag2_matchline_q(lrat_dbg_tag2_matchline_q),
   .lrat_dbg_entry0_addr_match(lrat_dbg_entry0_addr_match),
   .lrat_dbg_entry0_lpid_match(lrat_dbg_entry0_lpid_match),
   .lrat_dbg_entry0_entry_v(lrat_dbg_entry0_entry_v),
   .lrat_dbg_entry0_entry_x(lrat_dbg_entry0_entry_x),
   .lrat_dbg_entry0_size(lrat_dbg_entry0_size),
   .lrat_dbg_entry1_addr_match(lrat_dbg_entry1_addr_match),
   .lrat_dbg_entry1_lpid_match(lrat_dbg_entry1_lpid_match),
   .lrat_dbg_entry1_entry_v(lrat_dbg_entry1_entry_v),
   .lrat_dbg_entry1_entry_x(lrat_dbg_entry1_entry_x),
   .lrat_dbg_entry1_size(lrat_dbg_entry1_size),
   .lrat_dbg_entry2_addr_match(lrat_dbg_entry2_addr_match),
   .lrat_dbg_entry2_lpid_match(lrat_dbg_entry2_lpid_match),
   .lrat_dbg_entry2_entry_v(lrat_dbg_entry2_entry_v),
   .lrat_dbg_entry2_entry_x(lrat_dbg_entry2_entry_x),
   .lrat_dbg_entry2_size(lrat_dbg_entry2_size),
   .lrat_dbg_entry3_addr_match(lrat_dbg_entry3_addr_match),
   .lrat_dbg_entry3_lpid_match(lrat_dbg_entry3_lpid_match),
   .lrat_dbg_entry3_entry_v(lrat_dbg_entry3_entry_v),
   .lrat_dbg_entry3_entry_x(lrat_dbg_entry3_entry_x),
   .lrat_dbg_entry3_size(lrat_dbg_entry3_size),
   .lrat_dbg_entry4_addr_match(lrat_dbg_entry4_addr_match),
   .lrat_dbg_entry4_lpid_match(lrat_dbg_entry4_lpid_match),
   .lrat_dbg_entry4_entry_v(lrat_dbg_entry4_entry_v),
   .lrat_dbg_entry4_entry_x(lrat_dbg_entry4_entry_x),
   .lrat_dbg_entry4_size(lrat_dbg_entry4_size),
   .lrat_dbg_entry5_addr_match(lrat_dbg_entry5_addr_match),
   .lrat_dbg_entry5_lpid_match(lrat_dbg_entry5_lpid_match),
   .lrat_dbg_entry5_entry_v(lrat_dbg_entry5_entry_v),
   .lrat_dbg_entry5_entry_x(lrat_dbg_entry5_entry_x),
   .lrat_dbg_entry5_size(lrat_dbg_entry5_size),
   .lrat_dbg_entry6_addr_match(lrat_dbg_entry6_addr_match),
   .lrat_dbg_entry6_lpid_match(lrat_dbg_entry6_lpid_match),
   .lrat_dbg_entry6_entry_v(lrat_dbg_entry6_entry_v),
   .lrat_dbg_entry6_entry_x(lrat_dbg_entry6_entry_x),
   .lrat_dbg_entry6_size(lrat_dbg_entry6_size),
   .lrat_dbg_entry7_addr_match(lrat_dbg_entry7_addr_match),
   .lrat_dbg_entry7_lpid_match(lrat_dbg_entry7_lpid_match),
   .lrat_dbg_entry7_entry_v(lrat_dbg_entry7_entry_v),
   .lrat_dbg_entry7_entry_x(lrat_dbg_entry7_entry_x),
   .lrat_dbg_entry7_size(lrat_dbg_entry7_size),
   .htw_dbg_seq_idle(htw_dbg_seq_idle),
   .htw_dbg_pte0_seq_idle(htw_dbg_pte0_seq_idle),
   .htw_dbg_pte1_seq_idle(htw_dbg_pte1_seq_idle),
   .htw_dbg_seq_q(htw_dbg_seq_q),
   .htw_dbg_inptr_q(htw_dbg_inptr_q),
   .htw_dbg_pte0_seq_q(htw_dbg_pte0_seq_q),
   .htw_dbg_pte1_seq_q(htw_dbg_pte1_seq_q),
   .htw_dbg_ptereload_ptr_q(htw_dbg_ptereload_ptr_q),
   .htw_dbg_lsuptr_q(htw_dbg_lsuptr_q),
   .htw_dbg_req_valid_q(htw_dbg_req_valid_q),
   .htw_dbg_resv_valid_vec(htw_dbg_resv_valid_vec),
   .htw_dbg_tag4_clr_resv_q(htw_dbg_tag4_clr_resv_q),
   .htw_dbg_tag4_clr_resv_terms(htw_dbg_tag4_clr_resv_terms),
   .htw_dbg_pte0_score_ptr_q(htw_dbg_pte0_score_ptr_q),
   .htw_dbg_pte0_score_cl_offset_q(htw_dbg_pte0_score_cl_offset_q),
   .htw_dbg_pte0_score_error_q(htw_dbg_pte0_score_error_q),
   .htw_dbg_pte0_score_qwbeat_q(htw_dbg_pte0_score_qwbeat_q),
   .htw_dbg_pte0_score_pending_q(htw_dbg_pte0_score_pending_q),
   .htw_dbg_pte0_score_ibit_q(htw_dbg_pte0_score_ibit_q),
   .htw_dbg_pte0_score_dataval_q(htw_dbg_pte0_score_dataval_q),
   .htw_dbg_pte0_reld_for_me_tm1(htw_dbg_pte0_reld_for_me_tm1),
   .htw_dbg_pte1_score_ptr_q(htw_dbg_pte1_score_ptr_q),
   .htw_dbg_pte1_score_cl_offset_q(htw_dbg_pte1_score_cl_offset_q),
   .htw_dbg_pte1_score_error_q(htw_dbg_pte1_score_error_q),
   .htw_dbg_pte1_score_qwbeat_q(htw_dbg_pte1_score_qwbeat_q),
   .htw_dbg_pte1_score_pending_q(htw_dbg_pte1_score_pending_q),
   .htw_dbg_pte1_score_ibit_q(htw_dbg_pte1_score_ibit_q),
   .htw_dbg_pte1_score_dataval_q(htw_dbg_pte1_score_dataval_q),
   .htw_dbg_pte1_reld_for_me_tm1(htw_dbg_pte1_reld_for_me_tm1),

   .mm_xu_lsu_req(mm_xu_lsu_req_sig[0:`THREADS - 1]),
   .mm_xu_lsu_ttype(mm_xu_lsu_ttype_sig),
   .mm_xu_lsu_wimge(mm_xu_lsu_wimge_sig),
   .mm_xu_lsu_u(mm_xu_lsu_u_sig),
   .mm_xu_lsu_addr(mm_xu_lsu_addr_sig),
   .mm_xu_lsu_lpid(mm_xu_lsu_lpid_sig),
   .mm_xu_lsu_gs(mm_xu_lsu_gs_sig),
   .mm_xu_lsu_ind(mm_xu_lsu_ind_sig),
   .mm_xu_lsu_lbit(mm_xu_lsu_lbit_sig),
   .xu_mm_lsu_token(xu_mm_lsu_token),
   .tlb_mas_tlbre(tlb_mas_tlbre),
   .tlb_mas_tlbsx_hit(tlb_mas_tlbsx_hit),
   .tlb_mas_tlbsx_miss(tlb_mas_tlbsx_miss),
   .tlb_mas_dtlb_error(tlb_mas_dtlb_error),
   .tlb_mas_itlb_error(tlb_mas_itlb_error),
   .tlb_mas_thdid(tlb_mas_thdid_dbg),
   .lrat_mas_tlbre(lrat_mas_tlbre),
   .lrat_mas_tlbsx_hit(lrat_mas_tlbsx_hit),
   .lrat_mas_tlbsx_miss(lrat_mas_tlbsx_miss),
   .lrat_mas_thdid(lrat_mas_thdid_dbg),
   .lrat_tag3_hit_status(lrat_tag3_hit_status),
   .lrat_tag3_hit_entry(lrat_tag3_hit_entry),

   .tlb_seq_ierat_req(tlb_seq_ierat_req),
   .tlb_seq_derat_req(tlb_seq_derat_req),
   .mm_xu_hold_req(mm_iu_hold_req_sig[0:`THREADS - 1]),
   .xu_mm_hold_ack(iu_mm_hold_ack_sig[0:`THREADS - 1]),
   .mm_xu_hold_done(mm_iu_hold_done_sig[0:`THREADS - 1]),
   .mm_iu_barrier_done(mm_iu_tlbi_complete_sig[0:`THREADS - 1]),
   .mmucsr0_tlb0fi(mmucsr0_tlb0fi),
   .tlbwe_back_inv_valid(tlbwe_back_inv_valid_sig),
   .tlbwe_back_inv_attr(tlbwe_back_inv_attr_sig[18:19]),
   .xu_mm_lmq_stq_empty(xu_mm_lmq_stq_empty),
   .iu_mm_lmq_empty(iu_mm_lmq_empty),
   .mm_xu_eratmiss_done(mm_xu_eratmiss_done_sig[0:`THREADS - 1]),
   .mm_xu_ex3_flush_req(mm_xu_ex3_flush_req_sig[0:`THREADS - 1]),
   .mm_xu_illeg_instr(mm_xu_illeg_instr_sig[0:`THREADS - 1]),
   .lrat_tag4_hit_status(lrat_tag4_hit_status),
   .lrat_tag4_hit_entry(lrat_tag4_hit_entry),
   .mm_xu_cr0_eq(mm_xu_cr0_eq_sig[0:`THREADS - 1]),
   .mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid_sig[0:`THREADS - 1]),
   .tlb_htw_req_valid(tlb_htw_req_valid),
   .htw_lsu_req_valid(htw_lsu_req_valid),
   .htw_dbg_lsu_thdid(htw_dbg_lsu_thdid),
   .htw_lsu_ttype(htw_lsu_ttype),
   .htw_lsu_addr(htw_lsu_addr),
   .ptereload_req_taken(ptereload_req_taken),
   .ptereload_req_pte(ptereload_req_pte)
);
// End of mmq_dbg component instantiation


//---------------------------------------------------------------------
// Performance Event component instantiation
//---------------------------------------------------------------------

//work.mmq_perf #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_perf(
mmq_perf  mmq_perf(
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .pc_func_sl_thold_2(pc_func_sl_thold_2[0]),
   .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
   .pc_sg_2(pc_sg_2[0]),
   .pc_fce_2(pc_fce_2),
   .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
   .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
   .lcb_act_dis_dc(lcb_act_dis_dc),
   .lcb_d_mode_dc(lcb_d_mode_dc),
   .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
   .lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
   .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
   .scan_in(siv_1[mmq_perf_offset]),
   .scan_out(sov_1[mmq_perf_offset]),
   .cp_flush_p1(cp_flush_p1),

   .xu_mm_msr_gs(xu_mm_msr_gs_perf),
   .xu_mm_msr_pr(xu_mm_msr_pr_perf),
   .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[2]),

// count event inputs
   .iu_mm_perf_itlb(iu_mm_perf_itlb_sig),
   .lq_mm_perf_dtlb(lq_mm_perf_dtlb_sig),
   .iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
   .lq_mm_derat_req_nonspec(lq_mm_derat_req_nonspec),

   .tlb_cmp_perf_event_t0(tlb_cmp_perf_event_t0),
   .tlb_cmp_perf_event_t1(tlb_cmp_perf_event_t1),
   .tlb_cmp_perf_state(tlb_cmp_perf_state),

   .derat_req0_thdid(derat_req0_thdid_sig),
   .derat_req0_valid(derat_req0_valid_sig),
   .derat_req0_nonspec(derat_req0_nonspec_sig),
   .derat_req1_thdid(derat_req1_thdid_sig),
   .derat_req1_valid(derat_req1_valid_sig),
   .derat_req1_nonspec(derat_req1_nonspec_sig),
   .derat_req2_thdid(derat_req2_thdid_sig),
   .derat_req2_valid(derat_req2_valid_sig),
   .derat_req2_nonspec(derat_req2_nonspec_sig),
   .derat_req3_thdid(derat_req3_thdid_sig),
   .derat_req3_valid(derat_req3_valid_sig),
   .derat_req3_nonspec(derat_req3_nonspec_sig),
   .ierat_req0_thdid(ierat_req0_thdid_sig),
   .ierat_req0_valid(ierat_req0_valid_sig),
   .ierat_req0_nonspec(ierat_req0_nonspec_sig),
   .ierat_req1_thdid(ierat_req1_thdid_sig),
   .ierat_req1_valid(ierat_req1_valid_sig),
   .ierat_req1_nonspec(ierat_req1_nonspec_sig),
   .ierat_req2_thdid(ierat_req2_thdid_sig),
   .ierat_req2_valid(ierat_req2_valid_sig),
   .ierat_req2_nonspec(ierat_req2_nonspec_sig),
   .ierat_req3_thdid(ierat_req3_thdid_sig),
   .ierat_req3_valid(ierat_req3_valid_sig),
   .ierat_req3_nonspec(ierat_req3_nonspec_sig),
   .ierat_req_taken(ierat_req_taken),
   .derat_req_taken(derat_req_taken),

   .tlb_tag0_thdid(tlb_tag0_thdid),
   .tlb_tag0_type(tlb_tag0_type[0:1]),
   .tlb_tag0_nonspec(tlb_tag0_nonspec),
   .tlb_tag4_nonspec(tlb_tag4_nonspec),
   .tlb_seq_idle(tlb_seq_idle),

   .inval_perf_tlbilx(inval_perf_tlbilx),
   .inval_perf_tlbivax(inval_perf_tlbivax),
   .inval_perf_tlbivax_snoop(inval_perf_tlbivax_snoop),
   .inval_perf_tlb_flush(inval_perf_tlb_flush),

   .htw_req0_valid(htw_req0_valid),
   .htw_req0_thdid(htw_req0_thdid),
   .htw_req0_type(htw_req0_type),
   .htw_req1_valid(htw_req1_valid),
   .htw_req1_thdid(htw_req1_thdid),
   .htw_req1_type(htw_req1_type),
   .htw_req2_valid(htw_req2_valid),
   .htw_req2_thdid(htw_req2_thdid),
   .htw_req2_type(htw_req2_type),
   .htw_req3_valid(htw_req3_valid),
   .htw_req3_thdid(htw_req3_thdid),
   .htw_req3_type(htw_req3_type),
`ifdef WAIT_UPDATES
  .cp_mm_perf_except_taken_q(cp_mm_perf_except_taken_q),
`endif

   .tlb_cmp_perf_miss_direct(tlb_cmp_perf_miss_direct),
   .tlb_cmp_perf_hit_direct(tlb_cmp_perf_hit_direct),
   .tlb_cmp_perf_hit_indirect(tlb_cmp_perf_hit_indirect),
   .tlb_cmp_perf_hit_first_page(tlb_cmp_perf_hit_first_page),
   .tlb_cmp_perf_ptereload(tlb_cmp_perf_ptereload),
   .tlb_cmp_perf_ptereload_noexcep(tlb_cmp_perf_ptereload_noexcep),
   .tlb_cmp_perf_lrat_request(tlb_cmp_perf_lrat_request),
   .tlb_cmp_perf_lrat_miss(tlb_cmp_perf_lrat_miss),
   .tlb_cmp_perf_pt_fault(tlb_cmp_perf_pt_fault),
   .tlb_cmp_perf_pt_inelig(tlb_cmp_perf_pt_inelig),
   .tlb_ctl_perf_tlbwec_resv(tlb_ctl_perf_tlbwec_resv),
   .tlb_ctl_perf_tlbwec_noresv(tlb_ctl_perf_tlbwec_noresv),

// control inputs
   .mmq_spr_event_mux_ctrls(mmq_spr_event_mux_ctrls_sig[0:`MESR1_WIDTH*`THREADS-1]),
   .pc_mm_event_count_mode(pc_mm_event_count_mode[0:2]),
   .rp_mm_event_bus_enable_q(rp_mm_event_bus_enable_q),
   .mm_event_bus_in(mm_event_bus_in),
   .mm_event_bus_out(mm_event_bus_out)
);
// End of mmq_perf component instantiation


//---------------------------------------------------------------------
// Pervasive and LCB Control Component Instantiation
//---------------------------------------------------------------------

//work.mmq_perv #(.`EXPAND_TYPE(`EXPAND_TYPE)) mmq_perv(
mmq_perv  mmq_perv(
   .vdd(vdd),
   .gnd(gnd),
   .nclk(nclk),
   .pc_mm_sg_3(pc_mm_sg_3),
   .pc_mm_func_sl_thold_3(pc_mm_func_sl_thold_3),
   .pc_mm_func_slp_sl_thold_3(pc_mm_func_slp_sl_thold_3),
   .pc_mm_gptr_sl_thold_3(pc_mm_gptr_sl_thold_3),
   .pc_mm_fce_3(pc_mm_fce_3),
   .pc_mm_time_sl_thold_3(pc_mm_time_sl_thold_3),
   .pc_mm_repr_sl_thold_3(pc_mm_repr_sl_thold_3),
   .pc_mm_abst_sl_thold_3(pc_mm_abst_sl_thold_3),
   .pc_mm_abst_slp_sl_thold_3(pc_mm_abst_slp_sl_thold_3),
   .pc_mm_cfg_sl_thold_3(pc_mm_cfg_sl_thold_3),
   .pc_mm_cfg_slp_sl_thold_3(pc_mm_cfg_slp_sl_thold_3),
   .pc_mm_func_nsl_thold_3(pc_mm_func_nsl_thold_3),
   .pc_mm_func_slp_nsl_thold_3(pc_mm_func_slp_nsl_thold_3),
   .pc_mm_ary_nsl_thold_3(pc_mm_ary_nsl_thold_3),
   .pc_mm_ary_slp_nsl_thold_3(pc_mm_ary_slp_nsl_thold_3),
   .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
   .tc_scan_diag_dc(tc_ac_scan_diag_dc),
   .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),

   .pc_sg_0(pc_sg_0),
   .pc_sg_1(pc_sg_1),
   .pc_sg_2(pc_sg_2),
   .pc_func_sl_thold_2(pc_func_sl_thold_2),
   .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2),
   .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
   .pc_cfg_sl_thold_2(pc_cfg_sl_thold_2),
   .pc_cfg_slp_sl_thold_2(pc_cfg_slp_sl_thold_2),
   .pc_fce_2(pc_fce_2),
   .pc_time_sl_thold_0(pc_time_sl_thold_0),
   .pc_repr_sl_thold_0(pc_repr_sl_thold_0),
   .pc_abst_sl_thold_0(pc_abst_sl_thold_0),
   .pc_abst_slp_sl_thold_0(pc_abst_slp_sl_thold_0),
   .pc_ary_nsl_thold_0(pc_ary_nsl_thold_0),
   .pc_ary_slp_nsl_thold_0(pc_ary_slp_nsl_thold_0),
   .pc_func_sl_thold_0(pc_func_sl_thold_0),
   .pc_func_sl_thold_0_b(pc_func_sl_thold_0_b),
   .pc_func_slp_sl_thold_0(pc_func_slp_sl_thold_0),
   .pc_func_slp_sl_thold_0_b(pc_func_slp_sl_thold_0_b),
   .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
   .lcb_act_dis_dc(lcb_act_dis_dc),
   .lcb_d_mode_dc(lcb_d_mode_dc),
   .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
   .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
   .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
   .g8t_gptr_lcb_clkoff_dc_b(g8t_gptr_lcb_clkoff_dc_b),
   .g8t_gptr_lcb_act_dis_dc(g8t_gptr_lcb_act_dis_dc),
   .g8t_gptr_lcb_d_mode_dc(g8t_gptr_lcb_d_mode_dc),
   .g8t_gptr_lcb_delay_lclkr_dc(g8t_gptr_lcb_delay_lclkr_dc),
   .g8t_gptr_lcb_mpw1_dc_b(g8t_gptr_lcb_mpw1_dc_b),
   .g8t_gptr_lcb_mpw2_dc_b(g8t_gptr_lcb_mpw2_dc_b),
   .g6t_gptr_lcb_clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
   .g6t_gptr_lcb_act_dis_dc(g6t_gptr_lcb_act_dis_dc),
   .g6t_gptr_lcb_d_mode_dc(g6t_gptr_lcb_d_mode_dc),
   .g6t_gptr_lcb_delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc),
   .g6t_gptr_lcb_mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b),
   .g6t_gptr_lcb_mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),

   .pc_mm_abist_dcomp_g6t_2r(pc_mm_abist_dcomp_g6t_2r),
   .pc_mm_abist_di_0(pc_mm_abist_di_0),
   .pc_mm_abist_di_g6t_2r(pc_mm_abist_di_g6t_2r),
   .pc_mm_abist_ena_dc(pc_mm_abist_ena_dc),
   .pc_mm_abist_g6t_r_wb(pc_mm_abist_g6t_r_wb),
   .pc_mm_abist_g8t1p_renb_0(pc_mm_abist_g8t1p_renb_0),
   .pc_mm_abist_g8t_bw_0(pc_mm_abist_g8t_bw_0),
   .pc_mm_abist_g8t_bw_1(pc_mm_abist_g8t_bw_1),
   .pc_mm_abist_g8t_dcomp(pc_mm_abist_g8t_dcomp),
   .pc_mm_abist_g8t_wenb(pc_mm_abist_g8t_wenb),
   .pc_mm_abist_raddr_0(pc_mm_abist_raddr_0),
   .pc_mm_abist_waddr_0(pc_mm_abist_waddr_0),
   .pc_mm_abist_wl128_comp_ena(pc_mm_abist_wl128_comp_ena),

   .pc_mm_abist_g8t_wenb_q(pc_mm_abist_g8t_wenb_q),
   .pc_mm_abist_g8t1p_renb_0_q(pc_mm_abist_g8t1p_renb_0_q),
   .pc_mm_abist_di_0_q(pc_mm_abist_di_0_q),
   .pc_mm_abist_g8t_bw_1_q(pc_mm_abist_g8t_bw_1_q),
   .pc_mm_abist_g8t_bw_0_q(pc_mm_abist_g8t_bw_0_q),
   .pc_mm_abist_waddr_0_q(pc_mm_abist_waddr_0_q),
   .pc_mm_abist_raddr_0_q(pc_mm_abist_raddr_0_q),
   .pc_mm_abist_wl128_comp_ena_q(pc_mm_abist_wl128_comp_ena_q),
   .pc_mm_abist_g8t_dcomp_q(pc_mm_abist_g8t_dcomp_q),
   .pc_mm_abist_dcomp_g6t_2r_q(pc_mm_abist_dcomp_g6t_2r_q),
   .pc_mm_abist_di_g6t_2r_q(pc_mm_abist_di_g6t_2r_q),
   .pc_mm_abist_g6t_r_wb_q(pc_mm_abist_g6t_r_wb_q),

   .pc_mm_bolt_sl_thold_3(pc_mm_bolt_sl_thold_3),
   .pc_mm_bo_enable_3(pc_mm_bo_enable_3),
   .pc_mm_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
   .pc_mm_bo_enable_2(pc_mm_bo_enable_2),

   .gptr_scan_in(gptr_scan_in),
   .gptr_scan_out(gptr_scan_out),

   .time_scan_in(time_scan_in),
   .time_scan_in_int(time_scan_in_int),
   .time_scan_out_int(time_scan_out_int),
   .time_scan_out(time_scan_out),

   .func_scan_in({func_scan_in[0:8], func_scan_in[9]}),
   .func_scan_in_int(func_scan_in_int),
   .func_scan_out_int(func_scan_out_int),
   .func_scan_out({func_scan_out[0:8], func_scan_out[9]}),

   .repr_scan_in(repr_scan_in),
   .repr_scan_in_int(repr_scan_in_int),
   .repr_scan_out_int(repr_scan_out_int),
   .repr_scan_out(repr_scan_out),

   .abst_scan_in(abst_scan_in[0:1]),
   .abst_scan_in_int(abst_scan_in_int),
   .abst_scan_out_int(abst_scan_out_int),
   .abst_scan_out(abst_scan_out[0:1]),

   .bcfg_scan_in(bcfg_scan_in),
   .bcfg_scan_in_int(bcfg_scan_in_int),
   .bcfg_scan_out_int(bcfg_scan_out_int),
   .bcfg_scan_out(bcfg_scan_out),

   .ccfg_scan_in(ccfg_scan_in),
   .ccfg_scan_in_int(ccfg_scan_in_int),
   .ccfg_scan_out_int(ccfg_scan_out_int),
   .ccfg_scan_out(ccfg_scan_out),

   .dcfg_scan_in(dcfg_scan_in),
   .dcfg_scan_in_int(dcfg_scan_in_int),
   .dcfg_scan_out_int(dcfg_scan_out_int),
   .dcfg_scan_out(dcfg_scan_out)
);
// End of mmq_perv component instantiation


//---------------------------------------------------------------------
// output assignments
//---------------------------------------------------------------------
// tie off undriven ports when tlb components are not present
//  keep this here for people that like to control TLB existence with generics
generate
if (`EXPAND_TLB_TYPE == 0)
begin : eratonly_tieoffs_gen
   assign mm_iu_ierat_rel_val_sig = {-3{1'b0}};
   assign mm_iu_ierat_rel_data_sig = {`ERAT_REL_DATA_WIDTH{1'b0}};
   assign mm_xu_derat_rel_val_sig = {-3{1'b0}};
   assign mm_xu_derat_rel_data_sig = {`ERAT_REL_DATA_WIDTH{1'b0}};
   assign tlb_cmp_ierat_dup_val_sig = {-5{1'b0}};
   assign tlb_cmp_derat_dup_val_sig = {-5{1'b0}};
   assign tlb_cmp_erat_dup_wait_sig = {0{1'b0}};
   assign tlb_ctl_barrier_done_sig = {0{1'b0}};
   assign tlb_ctl_ex2_flush_req_sig = {0{1'b0}};
   assign tlb_ctl_ex2_illeg_instr_sig = {0{1'b0}};
   assign tlb_ctl_ex6_illeg_instr_sig = {0{1'b0}};
   assign tlb_ctl_ex2_itag_sig = {`ITAG_SIZE_ENC{1'b0}};
   assign tlb_ctl_ord_type = {-1{1'b0}};
   assign tlb_tag4_itag_sig = {`ITAG_SIZE_ENC{1'b0}};
   assign tlb_tag5_itag_sig = {`ITAG_SIZE_ENC{1'b0}};
   assign tlb_tag5_emq_sig = {`EMQ_ENTRIES{1'b0}};
   assign tlb_tag5_except = {0{1'b0}};
   assign tlb_req_quiesce_sig = {`THDID_WIDTH{1'b1}};
   assign tlb_ctl_quiesce_sig = {`MM_THREADS{1'b1}};
   assign htw_quiesce_sig = {`THDID_WIDTH{1'b1}};
   // missing perf count signals
   assign tlb_cmp_perf_event_t0 = {10{1'b0}};
   assign tlb_cmp_perf_event_t1 = {10{1'b0}};
   assign tlb_cmp_perf_state = {0{1'b0}};
   assign derat_req0_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign derat_req0_emq_sig = {`EMQ_ENTRIES{1'b0}};
   assign derat_req0_valid_sig = 1'b0;
   assign derat_req0_nonspec_sig = 1'b0;
   assign derat_req1_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign derat_req1_emq_sig = {`EMQ_ENTRIES{1'b0}};
   assign derat_req1_valid_sig = 1'b0;
   assign derat_req1_nonspec_sig = 1'b0;
   assign derat_req2_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign derat_req2_emq_sig = {`EMQ_ENTRIES{1'b0}};
   assign derat_req2_valid_sig = 1'b0;
   assign derat_req2_nonspec_sig = 1'b0;
   assign derat_req3_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign derat_req3_emq_sig = {`EMQ_ENTRIES{1'b0}};
   assign derat_req3_valid_sig = 1'b0;
   assign derat_req3_nonspec_sig = 1'b0;
   assign ierat_req0_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign ierat_req0_valid_sig = 1'b0;
   assign ierat_req0_nonspec_sig = 1'b0;
   assign ierat_req1_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign ierat_req1_valid_sig = 1'b0;
   assign ierat_req1_nonspec_sig = 1'b0;
   assign ierat_req2_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign ierat_req2_valid_sig = 1'b0;
   assign ierat_req2_nonspec_sig = 1'b0;
   assign ierat_req3_thdid_sig = {`THDID_WIDTH{1'b0}};
   assign ierat_req3_valid_sig = 1'b0;
   assign ierat_req3_nonspec_sig = 1'b0;
   assign tlb_tag0_thdid = {`THDID_WIDTH{1'b0}};
   assign tlb_tag0_type = {-6{1'b0}};
   assign tlb_seq_idle = 1'b0;
   assign htw_req0_valid = 1'b0;
   assign htw_req0_thdid = {`THDID_WIDTH{1'b0}};
   assign htw_req0_type = {0{1'b0}};
   assign htw_req1_valid = 1'b0;
   assign htw_req1_thdid = {`THDID_WIDTH{1'b0}};
   assign htw_req1_type = {0{1'b0}};
   assign htw_req2_valid = 1'b0;
   assign htw_req2_thdid = {`THDID_WIDTH{1'b0}};
   assign htw_req2_type = {0{1'b0}};
   assign htw_req3_valid = 1'b0;
   assign htw_req3_thdid = {`THDID_WIDTH{1'b0}};
   assign htw_req3_type = {0{1'b0}};
   assign tlb_cmp_perf_miss_direct = 1'b0;
   assign tlb_cmp_perf_hit_direct = 1'b0;
   assign tlb_cmp_perf_hit_indirect = 1'b0;
   assign tlb_cmp_perf_hit_first_page = 1'b0;
   assign tlb_cmp_perf_ptereload = 1'b0;
   assign tlb_cmp_perf_ptereload_noexcep = 1'b0;
   assign tlb_cmp_perf_lrat_request = 1'b0;
   assign tlb_cmp_perf_lrat_miss = 1'b0;
   assign tlb_cmp_perf_pt_fault = 1'b0;
   assign tlb_cmp_perf_pt_inelig = 1'b0;
   assign tlb_ctl_perf_tlbwec_resv = 1'b0;
   assign tlb_ctl_perf_tlbwec_noresv = 1'b0;
   // missing debug signals
   assign tlb_cmp_dbg_tag4 = {`TLB_TAG_WIDTH{1'b0}};
   assign tlb_cmp_dbg_tag4_wayhit = {`TLB_WAYS+1{1'b0}};
   assign tlb_cmp_dbg_addr4 = {`TLB_ADDR_WIDTH{1'b0}};
   assign tlb_cmp_dbg_tag4_way = {`TLB_WAY_WIDTH{1'b0}};
   assign mm_xu_eratmiss_done_sig = {0{1'b0}};
   assign mm_xu_tlb_miss_sig = {0{1'b0}};
   assign mm_xu_lrat_miss_sig = {0{1'b0}};
   assign mm_xu_tlb_inelig_sig = {0{1'b0}};
   assign mm_xu_pt_fault_sig = {0{1'b0}};
   assign mm_xu_hv_priv_sig = {0{1'b0}};
   assign mm_xu_cr0_eq_sig = {0{1'b0}};
   assign mm_xu_cr0_eq_valid_sig = {0{1'b0}};
   assign mm_xu_esr_pt_sig = {0{1'b0}};
   assign mm_xu_esr_data_sig = {0{1'b0}};
   assign mm_xu_esr_epid_sig = {0{1'b0}};
   assign mm_xu_esr_st_sig = {0{1'b0}};
   assign mm_xu_tlb_miss_ored_sig = 1'b0;
   assign mm_xu_lrat_miss_ored_sig = 1'b0;
   assign mm_xu_tlb_inelig_ored_sig = 1'b0;
   assign mm_xu_pt_fault_ored_sig = 1'b0;
   assign mm_xu_hv_priv_ored_sig = 1'b0;
   assign mm_xu_cr0_eq_ored_sig = 1'b0;
   assign mm_xu_cr0_eq_valid_ored_sig = 1'b0;
   assign mm_xu_tlb_multihit_err_sig = {0{1'b0}};
   assign mm_xu_tlb_par_err_sig = {0{1'b0}};
   assign mm_xu_lru_par_err_sig = {0{1'b0}};
   assign mm_xu_ord_tlb_multihit_sig = {0{1'b0}};
   assign mm_xu_ord_tlb_par_err_sig = {0{1'b0}};
   assign mm_xu_ord_lru_par_err_sig = {0{1'b0}};
   assign mm_pc_tlb_multihit_err_ored_sig = 1'b0;
   assign mm_pc_tlb_par_err_ored_sig = 1'b0;
   assign mm_pc_lru_par_err_ored_sig = 1'b0;
   assign tlb_snoop_ack = 1'b0;
end
endgenerate

assign mm_iu_ierat_rel_val = mm_iu_ierat_rel_val_sig;
assign mm_iu_ierat_rel_data = mm_iu_ierat_rel_data_sig;
assign mm_xu_derat_rel_val = mm_xu_derat_rel_val_sig;
assign mm_xu_derat_rel_data = mm_xu_derat_rel_data_sig;
assign mm_xu_ord_n_flush_req = mm_xu_ord_n_flush_req_sig[0:`THREADS - 1];
assign mm_xu_ord_np1_flush_req = mm_xu_ord_np1_flush_req_sig[0:`THREADS - 1];
assign mm_xu_ord_read_done = mm_xu_ord_read_done_sig[0:`THREADS - 1];
assign mm_xu_ord_write_done = mm_xu_ord_write_done_sig[0:`THREADS - 1];

   assign mm_iu_hold_req = mm_iu_hold_req_sig[0:`THREADS - 1];
   assign mm_iu_hold_done = mm_iu_hold_done_sig[0:`THREADS - 1];
   assign mm_iu_flush_req = mm_iu_flush_req_sig[0:`THREADS - 1];
   assign mm_iu_bus_snoop_hold_req = mm_iu_bus_snoop_hold_req_sig[0:`THREADS - 1];
   assign mm_iu_bus_snoop_hold_done = mm_iu_bus_snoop_hold_done_sig[0:`THREADS - 1];
   assign mm_iu_tlbi_complete = mm_iu_tlbi_complete_sig[0:`THREADS - 1];
   assign mm_xu_ex3_flush_req = mm_xu_ex3_flush_req_sig[0:`THREADS - 1];
   assign mm_xu_eratmiss_done = mm_xu_eratmiss_done_sig[0:`THREADS - 1];
   assign mm_xu_tlb_miss = mm_xu_tlb_miss_sig[0:`THREADS - 1];
   assign mm_xu_lrat_miss = mm_xu_lrat_miss_sig[0:`THREADS - 1];
   assign mm_xu_tlb_inelig = mm_xu_tlb_inelig_sig[0:`THREADS - 1];
   assign mm_xu_pt_fault = mm_xu_pt_fault_sig[0:`THREADS - 1];
   assign mm_xu_hv_priv = mm_xu_hv_priv_sig[0:`THREADS - 1];
   assign mm_xu_illeg_instr = mm_xu_illeg_instr_sig[0:`THREADS - 1];
   assign mm_xu_esr_pt = mm_xu_esr_pt_sig[0:`THREADS - 1];
   assign mm_xu_esr_data = mm_xu_esr_data_sig[0:`THREADS - 1];
   assign mm_xu_esr_epid = mm_xu_esr_epid_sig[0:`THREADS - 1];
   assign mm_xu_esr_st = mm_xu_esr_st_sig[0:`THREADS - 1];
   assign mm_xu_cr0_eq = mm_xu_cr0_eq_sig[0:`THREADS - 1];
   assign mm_xu_cr0_eq_valid = mm_xu_cr0_eq_valid_sig[0:`THREADS - 1];
   assign mm_xu_quiesce = mm_xu_quiesce_sig[0:`THREADS - 1];
   assign mm_pc_tlb_req_quiesce = mm_pc_tlb_req_quiesce_sig[0:`THREADS - 1];
   assign mm_pc_tlb_ctl_quiesce = mm_pc_tlb_ctl_quiesce_sig[0:`THREADS - 1];
   assign mm_pc_htw_quiesce = mm_pc_htw_quiesce_sig[0:`THREADS - 1];
   assign mm_pc_inval_quiesce = mm_pc_inval_quiesce_sig[0:`THREADS - 1];

   assign mm_xu_local_snoop_reject = mm_xu_local_snoop_reject_sig[0:`THREADS - 1];
   assign mm_xu_tlb_multihit_err = mm_xu_tlb_multihit_err_sig[0:`THREADS - 1];
   assign mm_xu_tlb_par_err = mm_xu_tlb_par_err_sig[0:`THREADS - 1];
   assign mm_xu_lru_par_err = mm_xu_lru_par_err_sig[0:`THREADS - 1];

   assign mm_xu_ord_tlb_multihit = mm_xu_ord_tlb_multihit_sig;
   assign mm_xu_ord_tlb_par_err = mm_xu_ord_tlb_par_err_sig;
   assign mm_xu_ord_lru_par_err = mm_xu_ord_lru_par_err_sig;

   assign mm_xu_tlb_miss_ored = mm_xu_tlb_miss_ored_sig;
   assign mm_xu_lrat_miss_ored = mm_xu_lrat_miss_ored_sig;
   assign mm_xu_tlb_inelig_ored = mm_xu_tlb_inelig_ored_sig;
   assign mm_xu_pt_fault_ored = mm_xu_pt_fault_ored_sig;
   assign mm_xu_hv_priv_ored = mm_xu_hv_priv_ored_sig;
   assign mm_xu_cr0_eq_ored = mm_xu_cr0_eq_ored_sig;
   assign mm_xu_cr0_eq_valid_ored = mm_xu_cr0_eq_valid_ored_sig;
   assign mm_pc_local_snoop_reject_ored = mm_pc_local_snoop_reject_ored_sig;
   assign mm_pc_tlb_multihit_err_ored = mm_pc_tlb_multihit_err_ored_sig;
   assign mm_pc_tlb_par_err_ored = mm_pc_tlb_par_err_ored_sig;
   assign mm_pc_lru_par_err_ored = mm_pc_lru_par_err_ored_sig;
   assign mm_iu_tlbwe_binv = mmucr1_sig[17];
   assign mm_xu_lsu_req = mm_xu_lsu_req_sig[0:`THREADS - 1];
   assign mm_xu_lsu_ttype = mm_xu_lsu_ttype_sig;
   assign mm_xu_lsu_wimge = mm_xu_lsu_wimge_sig;
   assign mm_xu_lsu_u = mm_xu_lsu_u_sig;
   assign mm_xu_lsu_addr = mm_xu_lsu_addr_sig;
   assign mm_xu_lsu_lpid = mm_xu_lsu_lpid_sig;
   assign mm_xu_lsu_gs = mm_xu_lsu_gs_sig;
   assign mm_xu_lsu_ind = mm_xu_lsu_ind_sig;
   assign mm_xu_lsu_lbit = mm_xu_lsu_lbit_sig;

// using ifdef's now for t0/t1 assignment to iu,lq in top level
      assign mm_iu_t0_ierat_pid = mm_iu_ierat_pid_sig[0];
      assign mm_xu_t0_derat_pid = mm_xu_derat_pid_sig[0];
      assign mm_iu_t0_ierat_mmucr0 = mm_iu_ierat_mmucr0_sig[0];
      assign mm_xu_t0_derat_mmucr0 = mm_xu_derat_mmucr0_sig[0];
`ifdef MM_THREADS2
      assign mm_iu_t1_ierat_pid = mm_iu_ierat_pid_sig[1];
      assign mm_xu_t1_derat_pid = mm_xu_derat_pid_sig[1];
      assign mm_iu_t1_ierat_mmucr0 = mm_iu_ierat_mmucr0_sig[1];
      assign mm_xu_t1_derat_mmucr0 = mm_xu_derat_mmucr0_sig[1];
`endif



   //------------------ end of common stuff for both erat-only and tlb -------------


   //---------------------------------------------------------------------
   // Start of TLB logic
   //---------------------------------------------------------------------
   generate
      if (`EXPAND_TLB_TYPE > 0)
      begin : tlb_gen_logic

   //---------------------------------------------------------------------
   // TLB Request Queue Component Instantiation
   //---------------------------------------------------------------------
         //work.mmq_tlb_req #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`PID_WIDTH(`PID_WIDTH), .`PID_WIDTH_erat(`PID_WIDTH_erat), .`LPID_WIDTH(`LPID_WIDTH), .`EPN_WIDTH(`EPN_WIDTH), .`RS_DATA_WIDTH(`RS_DATA_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_tlb_req(
         mmq_tlb_req  mmq_tlb_req(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .tc_ccflush_dc(tc_ac_ccflush_dc),
            .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .tc_scan_diag_dc(tc_ac_scan_diag_dc),
            .tc_lbist_en_dc(tc_ac_lbist_en_dc),

            .lcb_d_mode_dc(lcb_d_mode_dc),
            .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .lcb_act_dis_dc(lcb_act_dis_dc),
            .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

            .ac_func_scan_in(func_scan_in_int[2]),
            .ac_func_scan_out(func_scan_out_int[2]),

            .pc_sg_2(pc_sg_2[1]),
            .pc_func_sl_thold_2(pc_func_sl_thold_2[1]),
            .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[1]),
            .pid0(pid0_sig),
`ifdef MM_THREADS2
            .pid1(pid1_sig),
`endif
            .lpidr(lpidr_sig),
            .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[3]),
            .mmucr2_act_override(mmucr2_sig[0]),
            .iu_mm_ierat_req(iu_mm_ierat_req),
            .iu_mm_ierat_epn(iu_mm_ierat_epn),
            .iu_mm_ierat_thdid(iu_mm_ierat_thdid_sig),
            .iu_mm_ierat_state(iu_mm_ierat_state),
            .iu_mm_ierat_tid(iu_mm_ierat_tid),
            .iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
            .iu_mm_ierat_flush(iu_mm_ierat_flush_sig),

            .xu_mm_derat_req(xu_mm_derat_req),
            .xu_mm_derat_epn(xu_mm_derat_epn),
            .xu_mm_derat_thdid(xu_mm_derat_thdid_sig),
            .xu_mm_derat_ttype(xu_mm_derat_ttype),
            .xu_mm_derat_state(xu_mm_derat_state),
            .xu_mm_derat_tid(xu_mm_derat_tid),
            .xu_mm_derat_lpid(xu_mm_derat_lpid),
            .lq_mm_derat_req_nonspec(lq_mm_derat_req_nonspec),
            .lq_mm_derat_req_itag(lq_mm_derat_req_itag),
            .lq_mm_derat_req_emq(lq_mm_derat_req_emq),

            .ierat_req0_pid(ierat_req0_pid_sig),
            .ierat_req0_as(ierat_req0_as_sig),
            .ierat_req0_gs(ierat_req0_gs_sig),
            .ierat_req0_epn(ierat_req0_epn_sig),
            .ierat_req0_thdid(ierat_req0_thdid_sig),
            .ierat_req0_valid(ierat_req0_valid_sig),
            .ierat_req0_nonspec(ierat_req0_nonspec_sig),
            .ierat_req1_pid(ierat_req1_pid_sig),
            .ierat_req1_as(ierat_req1_as_sig),
            .ierat_req1_gs(ierat_req1_gs_sig),
            .ierat_req1_epn(ierat_req1_epn_sig),
            .ierat_req1_thdid(ierat_req1_thdid_sig),
            .ierat_req1_valid(ierat_req1_valid_sig),
            .ierat_req1_nonspec(ierat_req1_nonspec_sig),
            .ierat_req2_pid(ierat_req2_pid_sig),
            .ierat_req2_as(ierat_req2_as_sig),
            .ierat_req2_gs(ierat_req2_gs_sig),
            .ierat_req2_epn(ierat_req2_epn_sig),
            .ierat_req2_thdid(ierat_req2_thdid_sig),
            .ierat_req2_valid(ierat_req2_valid_sig),
            .ierat_req2_nonspec(ierat_req2_nonspec_sig),
            .ierat_req3_pid(ierat_req3_pid_sig),
            .ierat_req3_as(ierat_req3_as_sig),
            .ierat_req3_gs(ierat_req3_gs_sig),
            .ierat_req3_epn(ierat_req3_epn_sig),
            .ierat_req3_thdid(ierat_req3_thdid_sig),
            .ierat_req3_valid(ierat_req3_valid_sig),
            .ierat_req3_nonspec(ierat_req3_nonspec_sig),
            .ierat_iu4_pid(ierat_iu4_pid_sig),
            .ierat_iu4_gs(ierat_iu4_gs_sig),
            .ierat_iu4_as(ierat_iu4_as_sig),
            .ierat_iu4_epn(ierat_iu4_epn_sig),
            .ierat_iu4_thdid(ierat_iu4_thdid_sig),
            .ierat_iu4_valid(ierat_iu4_valid_sig),

            .derat_req0_lpid(derat_req0_lpid_sig),
            .derat_req0_pid(derat_req0_pid_sig),
            .derat_req0_as(derat_req0_as_sig),
            .derat_req0_gs(derat_req0_gs_sig),
            .derat_req0_epn(derat_req0_epn_sig),
            .derat_req0_thdid(derat_req0_thdid_sig),
            .derat_req0_emq(derat_req0_emq_sig),
            .derat_req0_valid(derat_req0_valid_sig),
            .derat_req0_nonspec(derat_req0_nonspec_sig),
            .derat_req1_lpid(derat_req1_lpid_sig),
            .derat_req1_pid(derat_req1_pid_sig),
            .derat_req1_as(derat_req1_as_sig),
            .derat_req1_gs(derat_req1_gs_sig),
            .derat_req1_epn(derat_req1_epn_sig),
            .derat_req1_thdid(derat_req1_thdid_sig),
            .derat_req1_emq(derat_req1_emq_sig),
            .derat_req1_valid(derat_req1_valid_sig),
            .derat_req1_nonspec(derat_req1_nonspec_sig),
            .derat_req2_lpid(derat_req2_lpid_sig),
            .derat_req2_pid(derat_req2_pid_sig),
            .derat_req2_as(derat_req2_as_sig),
            .derat_req2_gs(derat_req2_gs_sig),
            .derat_req2_epn(derat_req2_epn_sig),
            .derat_req2_thdid(derat_req2_thdid_sig),
            .derat_req2_emq(derat_req2_emq_sig),
            .derat_req2_valid(derat_req2_valid_sig),
            .derat_req2_nonspec(derat_req2_nonspec_sig),
            .derat_req3_lpid(derat_req3_lpid_sig),
            .derat_req3_pid(derat_req3_pid_sig),
            .derat_req3_as(derat_req3_as_sig),
            .derat_req3_gs(derat_req3_gs_sig),
            .derat_req3_epn(derat_req3_epn_sig),
            .derat_req3_thdid(derat_req3_thdid_sig),
            .derat_req3_emq(derat_req3_emq_sig),
            .derat_req3_valid(derat_req3_valid_sig),
            .derat_req3_nonspec(derat_req3_nonspec_sig),
            .derat_ex5_lpid(derat_ex5_lpid_sig),
            .derat_ex5_pid(derat_ex5_pid_sig),
            .derat_ex5_gs(derat_ex5_gs_sig),
            .derat_ex5_as(derat_ex5_as_sig),
            .derat_ex5_epn(derat_ex5_epn_sig),
            .derat_ex5_thdid(derat_ex5_thdid_sig),
            .derat_ex5_valid(derat_ex5_valid_sig),

            .xu_ex3_flush(xu_ex3_flush_sig),
            .xu_mm_ex4_flush(xu_mm_ex4_flush_sig),
            .xu_mm_ex5_flush(xu_mm_ex5_flush_sig),
            .xu_mm_ierat_flush(xu_mm_ierat_flush_sig),
            .xu_mm_ierat_miss(xu_mm_ierat_miss_sig),

            .tlb_cmp_ierat_dup_val(tlb_cmp_ierat_dup_val_sig),
            .tlb_cmp_derat_dup_val(tlb_cmp_derat_dup_val_sig),

            .tlb_seq_ierat_req(tlb_seq_ierat_req),
            .tlb_seq_derat_req(tlb_seq_derat_req),
            .tlb_seq_ierat_done(tlb_seq_ierat_done),
            .tlb_seq_derat_done(tlb_seq_derat_done),
            .ierat_req_taken(ierat_req_taken),
            .derat_req_taken(derat_req_taken),
            .ierat_req_epn(ierat_req_epn),
            .ierat_req_pid(ierat_req_pid),
            .ierat_req_state(ierat_req_state),
            .ierat_req_thdid(ierat_req_thdid),
            .ierat_req_dup(ierat_req_dup),
            .ierat_req_nonspec(ierat_req_nonspec),
            .derat_req_epn(derat_req_epn),
            .derat_req_pid(derat_req_pid),
            .derat_req_lpid(derat_req_lpid),
            .derat_req_state(derat_req_state),
            .derat_req_ttype(derat_req_ttype),
            .derat_req_thdid(derat_req_thdid),
            .derat_req_dup(derat_req_dup),
            .derat_req_itag(derat_req_itag),
            .derat_req_emq(derat_req_emq),
            .derat_req_nonspec(derat_req_nonspec),

            .tlb_req_quiesce(tlb_req_quiesce_sig),

            .tlb_req_dbg_ierat_iu5_valid_q(tlb_req_dbg_ierat_iu5_valid_q),
            .tlb_req_dbg_ierat_iu5_thdid(tlb_req_dbg_ierat_iu5_thdid),
            .tlb_req_dbg_ierat_iu5_state_q(tlb_req_dbg_ierat_iu5_state_q),
            .tlb_req_dbg_ierat_inptr_q(tlb_req_dbg_ierat_inptr_q),
            .tlb_req_dbg_ierat_outptr_q(tlb_req_dbg_ierat_outptr_q),
            .tlb_req_dbg_ierat_req_valid_q(tlb_req_dbg_ierat_req_valid_q),
            .tlb_req_dbg_ierat_req_nonspec_q(tlb_req_dbg_ierat_req_nonspec_q),
            .tlb_req_dbg_ierat_req_thdid(tlb_req_dbg_ierat_req_thdid),
            .tlb_req_dbg_ierat_req_dup_q(tlb_req_dbg_ierat_req_dup_q),
            .tlb_req_dbg_derat_ex6_valid_q(tlb_req_dbg_derat_ex6_valid_q),
            .tlb_req_dbg_derat_ex6_thdid(tlb_req_dbg_derat_ex6_thdid),
            .tlb_req_dbg_derat_ex6_state_q(tlb_req_dbg_derat_ex6_state_q),
            .tlb_req_dbg_derat_inptr_q(tlb_req_dbg_derat_inptr_q),
            .tlb_req_dbg_derat_outptr_q(tlb_req_dbg_derat_outptr_q),
            .tlb_req_dbg_derat_req_valid_q(tlb_req_dbg_derat_req_valid_q),
            .tlb_req_dbg_derat_req_thdid(tlb_req_dbg_derat_req_thdid),
            .tlb_req_dbg_derat_req_ttype_q(tlb_req_dbg_derat_req_ttype_q),
            .tlb_req_dbg_derat_req_dup_q(tlb_req_dbg_derat_req_dup_q)
         );
         // End of mmq_tlb_req component instantiation


         //---------------------------------------------------------------------
         // TLB Control Logic Component Instantiation
         //---------------------------------------------------------------------

         //work.mmq_tlb_ctl #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`EPN_WIDTH(`EPN_WIDTH), .`PID_WIDTH(`PID_WIDTH), .`REAL_ADDR_WIDTH(`REAL_ADDR_WIDTH), .`RS_DATA_WIDTH(`RS_DATA_WIDTH), .`DATA_OUT_WIDTH(`DATA_OUT_WIDTH), .`TLB_TAG_WIDTH(`TLB_TAG_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_tlb_ctl(
         mmq_tlb_ctl  mmq_tlb_ctl(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .tc_ccflush_dc(tc_ac_ccflush_dc),
            .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .tc_scan_diag_dc(tc_ac_scan_diag_dc),
            .tc_lbist_en_dc(tc_ac_lbist_en_dc),

            .lcb_d_mode_dc(lcb_d_mode_dc),
            .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .lcb_act_dis_dc(lcb_act_dis_dc),
            .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

            .ac_func_scan_in(func_scan_in_int[3]),
            .ac_func_scan_out(func_scan_out_int[3]),

            .pc_sg_2(pc_sg_2[1]),
            .pc_func_sl_thold_2(pc_func_sl_thold_2[1]),
            .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[1]),
            .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
            .pc_fce_2(pc_fce_2),
            .xu_mm_rf1_val(xu_mm_rf1_val_sig),
            .xu_mm_rf1_is_tlbre(xu_mm_rf1_is_tlbre),
            .xu_mm_rf1_is_tlbwe(xu_mm_rf1_is_tlbwe),
            .xu_mm_rf1_is_tlbsx(xu_mm_rf1_is_tlbsx),
            .xu_mm_rf1_is_tlbsxr(xu_mm_rf1_is_tlbsxr),
            .xu_mm_rf1_is_tlbsrx(xu_mm_rf1_is_tlbsrx),
            .xu_mm_ex2_epn(xu_mm_ex2_eff_addr_sig[64 - `RS_DATA_WIDTH:51]),
            .xu_mm_rf1_itag(xu_mm_rf1_itag),

            .xu_mm_msr_gs(xu_mm_msr_gs_sig),
            .xu_mm_msr_pr(xu_mm_msr_pr_sig),
            .xu_mm_msr_is(xu_mm_msr_is_sig),
            .xu_mm_msr_ds(xu_mm_msr_ds_sig),
            .xu_mm_msr_cm(xu_mm_msr_cm_sig),

            .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[4]),
            .xu_mm_epcr_dgtmi(xu_mm_epcr_dgtmi_sig),
            .xu_mm_xucr4_mmu_mchk(xu_mm_xucr4_mmu_mchk),
            .xu_mm_xucr4_mmu_mchk_q(xu_mm_xucr4_mmu_mchk_q),
            .xu_rf1_flush(xu_rf1_flush_sig),
            .xu_ex1_flush(xu_ex1_flush_sig),
            .xu_ex2_flush(xu_ex2_flush_sig),
            .xu_ex3_flush(xu_ex3_flush_sig[0:`MM_THREADS-1]),
            .xu_ex4_flush(xu_ex4_flush_sig),
            .xu_ex5_flush(xu_ex5_flush_sig),

            .tlb_ctl_ex3_valid(tlb_ctl_ex3_valid_sig),
            .tlb_ctl_ex3_ttype(tlb_ctl_ex3_ttype_sig),
            .tlb_ctl_ex3_hv_state(tlb_ctl_ex3_hv_state_sig),

            .tlb_ctl_tag2_flush(tlb_ctl_tag2_flush_sig),
            .tlb_ctl_tag3_flush(tlb_ctl_tag3_flush_sig),
            .tlb_ctl_tag4_flush(tlb_ctl_tag4_flush_sig),
            .tlb_resv_match_vec(tlb_resv_match_vec_sig),
            .tlb_ctl_barrier_done(tlb_ctl_barrier_done_sig),
            .tlb_ctl_ex2_flush_req(tlb_ctl_ex2_flush_req_sig),
            .tlb_ctl_ord_type(tlb_ctl_ord_type),
            .tlb_ctl_ex2_itag(tlb_ctl_ex2_itag_sig),
            .tlb_ctl_ex6_illeg_instr(tlb_ctl_ex6_illeg_instr_sig),
            .tlb_ctl_ex2_illeg_instr(tlb_ctl_ex2_illeg_instr_sig),
            .tlb_ctl_quiesce(tlb_ctl_quiesce_sig),
            .ex6_illeg_instr(ex6_illeg_instr),

            .mm_xu_eratmiss_done(mm_xu_eratmiss_done_sig),
            .mm_xu_tlb_miss(mm_xu_tlb_miss_sig),
            .mm_xu_tlb_inelig(mm_xu_tlb_inelig_sig),

            .tlbwe_back_inv_pending(tlbwe_back_inv_pending_sig),
            .pid0(pid0_sig),
`ifdef MM_THREADS2
            .pid1(pid1_sig),
`endif
            .mmucr1_tlbi_msb(mmucr1_sig[18]),
            .mmucr1_tlbwe_binv(mmucr1_sig[17]),
            .mmucr2(mmucr2_sig),
            .mmucr3_0(mmucr3_0_sig),
`ifdef MM_THREADS2
            .mmucr3_1(mmucr3_1_sig),
`endif
            .lpidr(lpidr_sig),
            .mmucfg_lrat(mmucfg_lrat),
            .mmucfg_twc(mmucfg_twc),
            .mmucsr0_tlb0fi(mmucsr0_tlb0fi),
            .tlb0cfg_pt(tlb0cfg_pt),
            .tlb0cfg_ind(tlb0cfg_ind),
            .tlb0cfg_gtwe(tlb0cfg_gtwe),

            .mas0_0_atsel(mas0_0_atsel),
            .mas0_0_esel(mas0_0_esel),
            .mas0_0_hes(mas0_0_hes),
            .mas0_0_wq(mas0_0_wq),
            .mas1_0_v(mas1_0_v),
            .mas1_0_iprot(mas1_0_iprot),
            .mas1_0_tid(mas1_0_tid),
            .mas1_0_ind(mas1_0_ind),
            .mas1_0_ts(mas1_0_ts),
            .mas1_0_tsize(mas1_0_tsize),
            .mas2_0_epn(mas2_0_epn),
            .mas2_0_wimge(mas2_0_wimge),
            .mas3_0_usxwr(mas3_0_usxwr[0:3]),
            .mas5_0_sgs(mas5_0_sgs),
            .mas5_0_slpid(mas5_0_slpid),
            .mas6_0_spid(mas6_0_spid),
            .mas6_0_sind(mas6_0_sind),
            .mas6_0_sas(mas6_0_sas),
            .mas8_0_tgs(mas8_0_tgs),
            .mas8_0_tlpid(mas8_0_tlpid),
`ifdef MM_THREADS2
            .mas0_1_atsel(mas0_1_atsel),
            .mas0_1_esel(mas0_1_esel),
            .mas0_1_hes(mas0_1_hes),
            .mas0_1_wq(mas0_1_wq),
            .mas1_1_v(mas1_1_v),
            .mas1_1_iprot(mas1_1_iprot),
            .mas1_1_tid(mas1_1_tid),
            .mas1_1_ind(mas1_1_ind),
            .mas1_1_ts(mas1_1_ts),
            .mas1_1_tsize(mas1_1_tsize),
            .mas2_1_epn(mas2_1_epn),
            .mas2_1_wimge(mas2_1_wimge),
            .mas3_1_usxwr(mas3_1_usxwr[0:3]),
            .mas5_1_sgs(mas5_1_sgs),
            .mas5_1_slpid(mas5_1_slpid),
            .mas6_1_spid(mas6_1_spid),
            .mas6_1_sind(mas6_1_sind),
            .mas6_1_sas(mas6_1_sas),
            .mas8_1_tgs(mas8_1_tgs),
            .mas8_1_tlpid(mas8_1_tlpid),
`endif

            .tlb_seq_ierat_req(tlb_seq_ierat_req),
            .tlb_seq_derat_req(tlb_seq_derat_req),
            .tlb_seq_ierat_done(tlb_seq_ierat_done),
            .tlb_seq_derat_done(tlb_seq_derat_done),
            .tlb_seq_idle(tlb_seq_idle),
            .ierat_req_taken(ierat_req_taken),
            .derat_req_taken(derat_req_taken),
            .ierat_req_epn(ierat_req_epn),
            .ierat_req_pid(ierat_req_pid),
            .ierat_req_state(ierat_req_state),
            .ierat_req_thdid(ierat_req_thdid),
            .ierat_req_dup(ierat_req_dup),
            .ierat_req_nonspec(ierat_req_nonspec),
            .derat_req_epn(derat_req_epn),
            .derat_req_pid(derat_req_pid),
            .derat_req_lpid(derat_req_lpid),
            .derat_req_state(derat_req_state),
            .derat_req_ttype(derat_req_ttype),
            .derat_req_thdid(derat_req_thdid),
            .derat_req_dup(derat_req_dup),
            .derat_req_itag(derat_req_itag),
            .derat_req_emq(derat_req_emq),
            .derat_req_nonspec(derat_req_nonspec),
            .ptereload_req_valid(ptereload_req_valid),
            .ptereload_req_tag(ptereload_req_tag),
            .ptereload_req_pte(ptereload_req_pte),
            .ptereload_req_taken(ptereload_req_taken),

            .tlb_snoop_coming(tlb_snoop_coming),
            .tlb_snoop_val(tlb_snoop_val),
            .tlb_snoop_attr(tlb_snoop_attr),
            .tlb_snoop_vpn(tlb_snoop_vpn),
            .tlb_snoop_ack(tlb_snoop_ack),

            .lru_rd_addr(lru_rd_addr),
            .lru_tag4_dataout(lru_tag4_dataout),
            .tlb_addr4(tlb_addr4),
            .tlb_tag4_esel(tlb_tag4_esel),
            .tlb_tag4_wq(tlb_tag4_wq),
            .tlb_tag4_is(tlb_tag4_is),
            .tlb_tag4_gs(tlb_tag4_gs),
            .tlb_tag4_pr(tlb_tag4_pr),
            .tlb_tag4_hes(tlb_tag4_hes),
            .tlb_tag4_atsel(tlb_tag4_atsel),
            .tlb_tag4_pt(tlb_tag4_pt),
            .tlb_tag4_cmp_hit(tlb_tag4_cmp_hit),
            .tlb_tag4_way_ind(tlb_tag4_way_ind),
            .tlb_tag4_ptereload(tlb_tag4_ptereload),
            .tlb_tag4_endflag(tlb_tag4_endflag),
            .tlb_tag4_parerr(tlb_tag4_parerr),
            .tlb_tag4_parerr_write(tlb_tag4_parerr_write),
            .tlb_tag5_parerr_zeroize(tlb_tag5_parerr_zeroize),
            .tlb_tag5_except(tlb_tag5_except),
            .tlb_cmp_erat_dup_wait(tlb_cmp_erat_dup_wait_sig),

            .tlb_tag0_epn(tlb_tag0_epn),
            .tlb_tag0_thdid(tlb_tag0_thdid),
            .tlb_tag0_type(tlb_tag0_type),
            .tlb_tag0_lpid(tlb_tag0_lpid),
            .tlb_tag0_atsel(tlb_tag0_atsel),
            .tlb_tag0_size(tlb_tag0_size),
            .tlb_tag0_addr_cap(tlb_tag0_addr_cap),
            .tlb_tag0_nonspec(tlb_tag0_nonspec),

            .tlb_tag2(tlb_tag2_sig),
            .tlb_addr2(tlb_addr2_sig),

            .tlb_ctl_perf_tlbwec_resv(tlb_ctl_perf_tlbwec_resv),
            .tlb_ctl_perf_tlbwec_noresv(tlb_ctl_perf_tlbwec_noresv),

            .lrat_tag4_hit_status(lrat_tag4_hit_status),

            .tlb_lper_lpn(tlb_lper_lpn),
            .tlb_lper_lps(tlb_lper_lps),
            .tlb_lper_we(tlb_lper_we),

            .ptereload_req_pte_lat(ptereload_req_pte_lat),
            .pte_tag0_lpn(pte_tag0_lpn[64 - `REAL_ADDR_WIDTH:51]),
            .pte_tag0_lpid(pte_tag0_lpid),

            .tlb_write(tlb_write),
            .tlb_addr(tlb_addr),
            .tlb_tag5_write(tlb_tag5_write),
            .tlb_delayed_act(tlb_delayed_act),

            .tlb_ctl_dbg_seq_q(tlb_ctl_dbg_seq_q),
            .tlb_ctl_dbg_seq_idle(tlb_ctl_dbg_seq_idle),
            .tlb_ctl_dbg_seq_any_done_sig(tlb_ctl_dbg_seq_any_done_sig),
            .tlb_ctl_dbg_seq_abort(tlb_ctl_dbg_seq_abort),
            .tlb_ctl_dbg_any_tlb_req_sig(tlb_ctl_dbg_any_tlb_req_sig),
            .tlb_ctl_dbg_any_req_taken_sig(tlb_ctl_dbg_any_req_taken_sig),
            .tlb_ctl_dbg_tag0_valid(tlb_ctl_dbg_tag0_valid),
            .tlb_ctl_dbg_tag0_thdid(tlb_ctl_dbg_tag0_thdid),
            .tlb_ctl_dbg_tag0_type(tlb_ctl_dbg_tag0_type),
            .tlb_ctl_dbg_tag0_wq(tlb_ctl_dbg_tag0_wq),
            .tlb_ctl_dbg_tag0_gs(tlb_ctl_dbg_tag0_gs),
            .tlb_ctl_dbg_tag0_pr(tlb_ctl_dbg_tag0_pr),
            .tlb_ctl_dbg_tag0_atsel(tlb_ctl_dbg_tag0_atsel),
            .tlb_ctl_dbg_tag5_tlb_write_q(tlb_ctl_dbg_tag5_tlb_write_q),
            .tlb_ctl_dbg_resv_valid(tlb_ctl_dbg_resv_valid),
            .tlb_ctl_dbg_set_resv(tlb_ctl_dbg_set_resv),
            .tlb_ctl_dbg_resv_match_vec_q(tlb_ctl_dbg_resv_match_vec_q),
            .tlb_ctl_dbg_any_tag_flush_sig(tlb_ctl_dbg_any_tag_flush_sig),
            .tlb_ctl_dbg_resv0_tag0_lpid_match(tlb_ctl_dbg_resv0_tag0_lpid_match),
            .tlb_ctl_dbg_resv0_tag0_pid_match(tlb_ctl_dbg_resv0_tag0_pid_match),
            .tlb_ctl_dbg_resv0_tag0_as_snoop_match(tlb_ctl_dbg_resv0_tag0_as_snoop_match),
            .tlb_ctl_dbg_resv0_tag0_gs_snoop_match(tlb_ctl_dbg_resv0_tag0_gs_snoop_match),
            .tlb_ctl_dbg_resv0_tag0_as_tlbwe_match(tlb_ctl_dbg_resv0_tag0_as_tlbwe_match),
            .tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match),
            .tlb_ctl_dbg_resv0_tag0_ind_match(tlb_ctl_dbg_resv0_tag0_ind_match),
            .tlb_ctl_dbg_resv0_tag0_epn_loc_match(tlb_ctl_dbg_resv0_tag0_epn_loc_match),
            .tlb_ctl_dbg_resv0_tag0_epn_glob_match(tlb_ctl_dbg_resv0_tag0_epn_glob_match),
            .tlb_ctl_dbg_resv0_tag0_class_match(tlb_ctl_dbg_resv0_tag0_class_match),
            .tlb_ctl_dbg_resv1_tag0_lpid_match(tlb_ctl_dbg_resv1_tag0_lpid_match),
            .tlb_ctl_dbg_resv1_tag0_pid_match(tlb_ctl_dbg_resv1_tag0_pid_match),
            .tlb_ctl_dbg_resv1_tag0_as_snoop_match(tlb_ctl_dbg_resv1_tag0_as_snoop_match),
            .tlb_ctl_dbg_resv1_tag0_gs_snoop_match(tlb_ctl_dbg_resv1_tag0_gs_snoop_match),
            .tlb_ctl_dbg_resv1_tag0_as_tlbwe_match(tlb_ctl_dbg_resv1_tag0_as_tlbwe_match),
            .tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match),
            .tlb_ctl_dbg_resv1_tag0_ind_match(tlb_ctl_dbg_resv1_tag0_ind_match),
            .tlb_ctl_dbg_resv1_tag0_epn_loc_match(tlb_ctl_dbg_resv1_tag0_epn_loc_match),
            .tlb_ctl_dbg_resv1_tag0_epn_glob_match(tlb_ctl_dbg_resv1_tag0_epn_glob_match),
            .tlb_ctl_dbg_resv1_tag0_class_match(tlb_ctl_dbg_resv1_tag0_class_match),
            .tlb_ctl_dbg_resv2_tag0_lpid_match(tlb_ctl_dbg_resv2_tag0_lpid_match),
            .tlb_ctl_dbg_resv2_tag0_pid_match(tlb_ctl_dbg_resv2_tag0_pid_match),
            .tlb_ctl_dbg_resv2_tag0_as_snoop_match(tlb_ctl_dbg_resv2_tag0_as_snoop_match),
            .tlb_ctl_dbg_resv2_tag0_gs_snoop_match(tlb_ctl_dbg_resv2_tag0_gs_snoop_match),
            .tlb_ctl_dbg_resv2_tag0_as_tlbwe_match(tlb_ctl_dbg_resv2_tag0_as_tlbwe_match),
            .tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match),
            .tlb_ctl_dbg_resv2_tag0_ind_match(tlb_ctl_dbg_resv2_tag0_ind_match),
            .tlb_ctl_dbg_resv2_tag0_epn_loc_match(tlb_ctl_dbg_resv2_tag0_epn_loc_match),
            .tlb_ctl_dbg_resv2_tag0_epn_glob_match(tlb_ctl_dbg_resv2_tag0_epn_glob_match),
            .tlb_ctl_dbg_resv2_tag0_class_match(tlb_ctl_dbg_resv2_tag0_class_match),
            .tlb_ctl_dbg_resv3_tag0_lpid_match(tlb_ctl_dbg_resv3_tag0_lpid_match),
            .tlb_ctl_dbg_resv3_tag0_pid_match(tlb_ctl_dbg_resv3_tag0_pid_match),
            .tlb_ctl_dbg_resv3_tag0_as_snoop_match(tlb_ctl_dbg_resv3_tag0_as_snoop_match),
            .tlb_ctl_dbg_resv3_tag0_gs_snoop_match(tlb_ctl_dbg_resv3_tag0_gs_snoop_match),
            .tlb_ctl_dbg_resv3_tag0_as_tlbwe_match(tlb_ctl_dbg_resv3_tag0_as_tlbwe_match),
            .tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match(tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match),
            .tlb_ctl_dbg_resv3_tag0_ind_match(tlb_ctl_dbg_resv3_tag0_ind_match),
            .tlb_ctl_dbg_resv3_tag0_epn_loc_match(tlb_ctl_dbg_resv3_tag0_epn_loc_match),
            .tlb_ctl_dbg_resv3_tag0_epn_glob_match(tlb_ctl_dbg_resv3_tag0_epn_glob_match),
            .tlb_ctl_dbg_resv3_tag0_class_match(tlb_ctl_dbg_resv3_tag0_class_match),
            .tlb_ctl_dbg_clr_resv_q(tlb_ctl_dbg_clr_resv_q),
            .tlb_ctl_dbg_clr_resv_terms(tlb_ctl_dbg_clr_resv_terms)
         );
         // End of mmq_tlb_ctl component instantiation


         //---------------------------------------------------------------------
         // TLB Compare Logic Component Instantiation
         //---------------------------------------------------------------------

         mmq_tlb_cmp #(.MMQ_TLB_CMP_CSWITCH_0TO7(MMQ_TLB_CMP_CSWITCH_0TO7)) mmq_tlb_cmp(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .tc_ccflush_dc(tc_ac_ccflush_dc),
            .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .tc_scan_diag_dc(tc_ac_scan_diag_dc),
            .tc_lbist_en_dc(tc_ac_lbist_en_dc),

            .lcb_d_mode_dc(lcb_d_mode_dc),
            .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .lcb_act_dis_dc(lcb_act_dis_dc),
            .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

            .ac_func_scan_in( {func_scan_in_int[4], func_scan_in_int[5], siv_1[tlb_cmp2_offset]} ),
            .ac_func_scan_out( {func_scan_out_int[4], func_scan_out_int[5], sov_1[tlb_cmp2_offset]} ),

            .pc_sg_2(pc_sg_2[1]),
            .pc_func_sl_thold_2(pc_func_sl_thold_2[1]),
            .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[1]),
            .pc_func_slp_nsl_thold_2(pc_func_slp_nsl_thold_2),
            .pc_fce_2(pc_fce_2),
            .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[5]),
            .xu_mm_spr_epcr_dmiuh(xu_mm_spr_epcr_dmiuh_sig),
            .xu_mm_epcr_dgtmi(xu_mm_epcr_dgtmi_sig),
            .xu_mm_msr_gs(xu_mm_msr_gs_sig),
            .xu_mm_msr_pr(xu_mm_msr_pr_sig),
            .xu_mm_xucr4_mmu_mchk_q(xu_mm_xucr4_mmu_mchk_q),
            .lpidr(lpidr_sig),
            .mmucr1(mmucr1_sig[10:18]),
            .mmucr3_0(mmucr3_0_sig),
            .tstmode4k_0(tstmode4k_0_sig),
`ifdef MM_THREADS2
            .mmucr3_1(mmucr3_1_sig),
            .tstmode4k_1(tstmode4k_1_sig),
`endif
            .mm_iu_ierat_rel_val(mm_iu_ierat_rel_val_sig),
            .mm_iu_ierat_rel_data(mm_iu_ierat_rel_data_sig),

            .mm_xu_derat_rel_val(mm_xu_derat_rel_val_sig),
            .mm_xu_derat_rel_data(mm_xu_derat_rel_data_sig),
            .tlb_cmp_ierat_dup_val(tlb_cmp_ierat_dup_val_sig),
            .tlb_cmp_derat_dup_val(tlb_cmp_derat_dup_val_sig),
            .tlb_cmp_erat_dup_wait(tlb_cmp_erat_dup_wait_sig),
            .ierat_req0_pid(ierat_req0_pid_sig),
            .ierat_req0_as(ierat_req0_as_sig),
            .ierat_req0_gs(ierat_req0_gs_sig),
            .ierat_req0_epn(ierat_req0_epn_sig),
            .ierat_req0_thdid(ierat_req0_thdid_sig),
            .ierat_req0_valid(ierat_req0_valid_sig),
            .ierat_req0_nonspec(ierat_req0_nonspec_sig),
            .ierat_req1_pid(ierat_req1_pid_sig),
            .ierat_req1_as(ierat_req1_as_sig),
            .ierat_req1_gs(ierat_req1_gs_sig),
            .ierat_req1_epn(ierat_req1_epn_sig),
            .ierat_req1_thdid(ierat_req1_thdid_sig),
            .ierat_req1_valid(ierat_req1_valid_sig),
            .ierat_req1_nonspec(ierat_req1_nonspec_sig),
            .ierat_req2_pid(ierat_req2_pid_sig),
            .ierat_req2_as(ierat_req2_as_sig),
            .ierat_req2_gs(ierat_req2_gs_sig),
            .ierat_req2_epn(ierat_req2_epn_sig),
            .ierat_req2_thdid(ierat_req2_thdid_sig),
            .ierat_req2_valid(ierat_req2_valid_sig),
            .ierat_req2_nonspec(ierat_req2_nonspec_sig),
            .ierat_req3_pid(ierat_req3_pid_sig),
            .ierat_req3_as(ierat_req3_as_sig),
            .ierat_req3_gs(ierat_req3_gs_sig),
            .ierat_req3_epn(ierat_req3_epn_sig),
            .ierat_req3_thdid(ierat_req3_thdid_sig),
            .ierat_req3_valid(ierat_req3_valid_sig),
            .ierat_req3_nonspec(ierat_req3_nonspec_sig),
            .ierat_iu4_pid(ierat_iu4_pid_sig),
            .ierat_iu4_gs(ierat_iu4_gs_sig),
            .ierat_iu4_as(ierat_iu4_as_sig),
            .ierat_iu4_epn(ierat_iu4_epn_sig),
            .ierat_iu4_thdid(ierat_iu4_thdid_sig),
            .ierat_iu4_valid(ierat_iu4_valid_sig),

            .derat_req0_lpid(derat_req0_lpid_sig),
            .derat_req0_pid(derat_req0_pid_sig),
            .derat_req0_as(derat_req0_as_sig),
            .derat_req0_gs(derat_req0_gs_sig),
            .derat_req0_epn(derat_req0_epn_sig),
            .derat_req0_thdid(derat_req0_thdid_sig),
            .derat_req0_emq(derat_req0_emq_sig),
            .derat_req0_valid(derat_req0_valid_sig),
            .derat_req1_lpid(derat_req1_lpid_sig),
            .derat_req1_pid(derat_req1_pid_sig),
            .derat_req1_as(derat_req1_as_sig),
            .derat_req1_gs(derat_req1_gs_sig),
            .derat_req1_epn(derat_req1_epn_sig),
            .derat_req1_thdid(derat_req1_thdid_sig),
            .derat_req1_emq(derat_req1_emq_sig),
            .derat_req1_valid(derat_req1_valid_sig),
            .derat_req2_lpid(derat_req2_lpid_sig),
            .derat_req2_pid(derat_req2_pid_sig),
            .derat_req2_as(derat_req2_as_sig),
            .derat_req2_gs(derat_req2_gs_sig),
            .derat_req2_epn(derat_req2_epn_sig),
            .derat_req2_thdid(derat_req2_thdid_sig),
            .derat_req2_emq(derat_req2_emq_sig),
            .derat_req2_valid(derat_req2_valid_sig),
            .derat_req3_lpid(derat_req3_lpid_sig),
            .derat_req3_pid(derat_req3_pid_sig),
            .derat_req3_as(derat_req3_as_sig),
            .derat_req3_gs(derat_req3_gs_sig),
            .derat_req3_epn(derat_req3_epn_sig),
            .derat_req3_thdid(derat_req3_thdid_sig),
            .derat_req3_emq(derat_req3_emq_sig),
            .derat_req3_valid(derat_req3_valid_sig),
            .derat_ex5_lpid(derat_ex5_lpid_sig),
            .derat_ex5_pid(derat_ex5_pid_sig),
            .derat_ex5_gs(derat_ex5_gs_sig),
            .derat_ex5_as(derat_ex5_as_sig),
            .derat_ex5_epn(derat_ex5_epn_sig),
            .derat_ex5_thdid(derat_ex5_thdid_sig),
            .derat_ex5_valid(derat_ex5_valid_sig),

            .tlb_tag2(tlb_tag2_sig),
            .tlb_addr2(tlb_addr2_sig),
            .ex6_illeg_instr(ex6_illeg_instr),

            .ierat_req_taken(ierat_req_taken),
            .derat_req_taken(derat_req_taken),
            .ptereload_req_taken(ptereload_req_taken),
            .tlb_tag0_type(tlb_tag0_type[0:1]),

            .lru_dataout(lru_dataout[0:15]),
            .tlb_dataout(tlb_dataout),
            .tlb_dataina(tlb_dataina),
            .tlb_datainb(tlb_datainb),
            .lru_write(lru_write[0:15]),
            .lru_wr_addr(lru_wr_addr),
            .lru_datain(lru_datain[0:15]),
            .lru_tag4_dataout(lru_tag4_dataout),
            .tlb_addr4(tlb_addr4),
            .tlb_tag4_esel(tlb_tag4_esel),
            .tlb_tag4_wq(tlb_tag4_wq),
            .tlb_tag4_is(tlb_tag4_is),
            .tlb_tag4_gs(tlb_tag4_gs),
            .tlb_tag4_pr(tlb_tag4_pr),
            .tlb_tag4_hes(tlb_tag4_hes),
            .tlb_tag4_atsel(tlb_tag4_atsel),
            .tlb_tag4_pt(tlb_tag4_pt),
            .tlb_tag4_cmp_hit(tlb_tag4_cmp_hit),
            .tlb_tag4_way_ind(tlb_tag4_way_ind),
            .tlb_tag4_ptereload(tlb_tag4_ptereload),
            .tlb_tag4_endflag(tlb_tag4_endflag),
            .tlb_tag4_parerr(tlb_tag4_parerr),
            .tlb_tag4_parerr_write(tlb_tag4_parerr_write),
            .tlb_tag5_parerr_zeroize(tlb_tag5_parerr_zeroize),
            .tlb_tag4_nonspec(tlb_tag4_nonspec),
            .tlb_tag5_except(tlb_tag5_except),
            .tlb_tag4_itag(tlb_tag4_itag_sig),
            .tlb_tag5_itag(tlb_tag5_itag_sig),
            .tlb_tag5_emq(tlb_tag5_emq_sig),

            .mmucfg_twc(mmucfg_twc),
            .mmucfg_lrat(mmucfg_lrat),
            .tlb0cfg_pt(tlb0cfg_pt),
            .tlb0cfg_gtwe(tlb0cfg_gtwe),
            .tlb0cfg_ind(tlb0cfg_ind),

            .mas2_0_wimge(mas2_0_wimge),
            .mas3_0_rpnl(mas3_0_rpnl),
            .mas3_0_ubits(mas3_0_ubits),
            .mas3_0_usxwr(mas3_0_usxwr),
            .mas7_0_rpnu(mas7_0_rpnu),
            .mas8_0_vf(mas8_0_vf),
`ifdef MM_THREADS2
            .mas2_1_wimge(mas2_1_wimge),
            .mas3_1_rpnl(mas3_1_rpnl),
            .mas3_1_ubits(mas3_1_ubits),
            .mas3_1_usxwr(mas3_1_usxwr),
            .mas7_1_rpnu(mas7_1_rpnu),
            .mas8_1_vf(mas8_1_vf),
`endif
            .tlb_mas0_esel(tlb_mas0_esel),
            .tlb_mas1_v(tlb_mas1_v),
            .tlb_mas1_iprot(tlb_mas1_iprot),
            .tlb_mas1_tid(tlb_mas1_tid),
            .tlb_mas1_tid_error(tlb_mas1_tid_error),
            .tlb_mas1_ind(tlb_mas1_ind),
            .tlb_mas1_ts(tlb_mas1_ts),
            .tlb_mas1_ts_error(tlb_mas1_ts_error),
            .tlb_mas1_tsize(tlb_mas1_tsize),
            .tlb_mas2_epn(tlb_mas2_epn),
            .tlb_mas2_epn_error(tlb_mas2_epn_error),
            .tlb_mas2_wimge(tlb_mas2_wimge),
            .tlb_mas3_rpnl(tlb_mas3_rpnl),
            .tlb_mas3_ubits(tlb_mas3_ubits),
            .tlb_mas3_usxwr(tlb_mas3_usxwr),
            .tlb_mas7_rpnu(tlb_mas7_rpnu),
            .tlb_mas8_tgs(tlb_mas8_tgs),
            .tlb_mas8_vf(tlb_mas8_vf),
            .tlb_mas8_tlpid(tlb_mas8_tlpid),

            .tlb_mmucr1_een(tlb_mmucr1_een),
            .tlb_mmucr1_we(tlb_mmucr1_we),
            .tlb_mmucr3_thdid(tlb_mmucr3_thdid),
            .tlb_mmucr3_resvattr(tlb_mmucr3_resvattr),
            .tlb_mmucr3_wlc(tlb_mmucr3_wlc),
            .tlb_mmucr3_class(tlb_mmucr3_class),
            .tlb_mmucr3_extclass(tlb_mmucr3_extclass),
            .tlb_mmucr3_rc(tlb_mmucr3_rc),
            .tlb_mmucr3_x(tlb_mmucr3_x),
            .tlb_mas_tlbre(tlb_mas_tlbre),
            .tlb_mas_tlbsx_hit(tlb_mas_tlbsx_hit),
            .tlb_mas_tlbsx_miss(tlb_mas_tlbsx_miss),
            .tlb_mas_dtlb_error(tlb_mas_dtlb_error),
            .tlb_mas_itlb_error(tlb_mas_itlb_error),
            .tlb_mas_thdid(tlb_mas_thdid),
            .lrat_tag3_lpn(lrat_tag3_lpn),
            .lrat_tag3_rpn(lrat_tag3_rpn),
            .lrat_tag3_hit_status(lrat_tag3_hit_status),
            .lrat_tag3_hit_entry(lrat_tag3_hit_entry),
            .lrat_tag4_lpn(lrat_tag4_lpn),
            .lrat_tag4_rpn(lrat_tag4_rpn),
            .lrat_tag4_hit_status(lrat_tag4_hit_status),
            .lrat_tag4_hit_entry(lrat_tag4_hit_entry),

            .tlb_htw_req_valid(tlb_htw_req_valid),
            .tlb_htw_req_tag(tlb_htw_req_tag),
            .tlb_htw_req_way(tlb_htw_req_way),

            .tlbwe_back_inv_valid(tlbwe_back_inv_valid_sig),
            .tlbwe_back_inv_thdid(tlbwe_back_inv_thdid_sig),
            .tlbwe_back_inv_addr(tlbwe_back_inv_addr_sig),
            .tlbwe_back_inv_attr(tlbwe_back_inv_attr_sig),

            .ptereload_req_pte_lat(ptereload_req_pte_lat),

            .tlb_ctl_tag2_flush(tlb_ctl_tag2_flush_sig),
            .tlb_ctl_tag3_flush(tlb_ctl_tag3_flush_sig),
            .tlb_ctl_tag4_flush(tlb_ctl_tag4_flush_sig),
            .tlb_resv_match_vec(tlb_resv_match_vec_sig),

            .mm_xu_eratmiss_done(mm_xu_eratmiss_done_sig),
            .mm_xu_tlb_miss(mm_xu_tlb_miss_sig),
            .mm_xu_tlb_inelig(mm_xu_tlb_inelig_sig),

            .mm_xu_lrat_miss(mm_xu_lrat_miss_sig),
            .mm_xu_pt_fault(mm_xu_pt_fault_sig),
            .mm_xu_hv_priv(mm_xu_hv_priv_sig),

            .mm_xu_esr_pt(mm_xu_esr_pt_sig),
            .mm_xu_esr_data(mm_xu_esr_data_sig),
            .mm_xu_esr_epid(mm_xu_esr_epid_sig),
            .mm_xu_esr_st(mm_xu_esr_st_sig),

            .mm_xu_cr0_eq(mm_xu_cr0_eq_sig),
            .mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid_sig),

            .mm_xu_tlb_multihit_err(mm_xu_tlb_multihit_err_sig),
            .mm_xu_tlb_par_err(mm_xu_tlb_par_err_sig),
            .mm_xu_lru_par_err(mm_xu_lru_par_err_sig),

            .mm_xu_ord_tlb_multihit(mm_xu_ord_tlb_multihit_sig),
            .mm_xu_ord_tlb_par_err(mm_xu_ord_tlb_par_err_sig),
            .mm_xu_ord_lru_par_err(mm_xu_ord_lru_par_err_sig),

            .mm_xu_tlb_miss_ored(mm_xu_tlb_miss_ored_sig),
            .mm_xu_lrat_miss_ored(mm_xu_lrat_miss_ored_sig),
            .mm_xu_tlb_inelig_ored(mm_xu_tlb_inelig_ored_sig),
            .mm_xu_pt_fault_ored(mm_xu_pt_fault_ored_sig),
            .mm_xu_hv_priv_ored(mm_xu_hv_priv_ored_sig),
            .mm_xu_cr0_eq_ored(mm_xu_cr0_eq_ored_sig),
            .mm_xu_cr0_eq_valid_ored(mm_xu_cr0_eq_valid_ored_sig),

            .mm_pc_tlb_multihit_err_ored(mm_pc_tlb_multihit_err_ored_sig),
            .mm_pc_tlb_par_err_ored(mm_pc_tlb_par_err_ored_sig),
            .mm_pc_lru_par_err_ored(mm_pc_lru_par_err_ored_sig),

            .tlb_delayed_act(tlb_delayed_act[9:16]),

            .tlb_cmp_perf_event_t0(tlb_cmp_perf_event_t0),
            .tlb_cmp_perf_event_t1(tlb_cmp_perf_event_t1),
            .tlb_cmp_perf_state(tlb_cmp_perf_state),

            .tlb_cmp_perf_miss_direct(tlb_cmp_perf_miss_direct),
            .tlb_cmp_perf_hit_direct(tlb_cmp_perf_hit_direct),
            .tlb_cmp_perf_hit_indirect(tlb_cmp_perf_hit_indirect),
            .tlb_cmp_perf_hit_first_page(tlb_cmp_perf_hit_first_page),
            .tlb_cmp_perf_ptereload(tlb_cmp_perf_ptereload),
            .tlb_cmp_perf_ptereload_noexcep(tlb_cmp_perf_ptereload_noexcep),
            .tlb_cmp_perf_lrat_request(tlb_cmp_perf_lrat_request),
            .tlb_cmp_perf_lrat_miss(tlb_cmp_perf_lrat_miss),
            .tlb_cmp_perf_pt_fault(tlb_cmp_perf_pt_fault),
            .tlb_cmp_perf_pt_inelig(tlb_cmp_perf_pt_inelig),

            .tlb_cmp_dbg_tag4(tlb_cmp_dbg_tag4),
            .tlb_cmp_dbg_tag4_wayhit(tlb_cmp_dbg_tag4_wayhit),
            .tlb_cmp_dbg_addr4(tlb_cmp_dbg_addr4),
            .tlb_cmp_dbg_tag4_way(tlb_cmp_dbg_tag4_way),
            .tlb_cmp_dbg_tag4_parerr(tlb_cmp_dbg_tag4_parerr),
            .tlb_cmp_dbg_tag4_lru_dataout_q(tlb_cmp_dbg_tag4_lru_dataout_q),
            .tlb_cmp_dbg_tag5_tlb_datain_q(tlb_cmp_dbg_tag5_tlb_datain_q),
            .tlb_cmp_dbg_tag5_lru_datain_q(tlb_cmp_dbg_tag5_lru_datain_q),
            .tlb_cmp_dbg_tag5_lru_write(tlb_cmp_dbg_tag5_lru_write),
            .tlb_cmp_dbg_tag5_any_exception(tlb_cmp_dbg_tag5_any_exception),
            .tlb_cmp_dbg_tag5_except_type_q(tlb_cmp_dbg_tag5_except_type_q),
            .tlb_cmp_dbg_tag5_except_thdid_q(tlb_cmp_dbg_tag5_except_thdid_q),
            .tlb_cmp_dbg_tag5_erat_rel_val(tlb_cmp_dbg_tag5_erat_rel_val),
            .tlb_cmp_dbg_tag5_erat_rel_data(tlb_cmp_dbg_tag5_erat_rel_data),
            .tlb_cmp_dbg_erat_dup_q(tlb_cmp_dbg_erat_dup_q),
            .tlb_cmp_dbg_addr_enable(tlb_cmp_dbg_addr_enable),
            .tlb_cmp_dbg_pgsize_enable(tlb_cmp_dbg_pgsize_enable),
            .tlb_cmp_dbg_class_enable(tlb_cmp_dbg_class_enable),
            .tlb_cmp_dbg_extclass_enable(tlb_cmp_dbg_extclass_enable),
            .tlb_cmp_dbg_state_enable(tlb_cmp_dbg_state_enable),
            .tlb_cmp_dbg_thdid_enable(tlb_cmp_dbg_thdid_enable),
            .tlb_cmp_dbg_pid_enable(tlb_cmp_dbg_pid_enable),
            .tlb_cmp_dbg_lpid_enable(tlb_cmp_dbg_lpid_enable),
            .tlb_cmp_dbg_ind_enable(tlb_cmp_dbg_ind_enable),
            .tlb_cmp_dbg_iprot_enable(tlb_cmp_dbg_iprot_enable),
            .tlb_cmp_dbg_way0_entry_v(tlb_cmp_dbg_way0_entry_v),
            .tlb_cmp_dbg_way0_addr_match(tlb_cmp_dbg_way0_addr_match),
            .tlb_cmp_dbg_way0_pgsize_match(tlb_cmp_dbg_way0_pgsize_match),
            .tlb_cmp_dbg_way0_class_match(tlb_cmp_dbg_way0_class_match),
            .tlb_cmp_dbg_way0_extclass_match(tlb_cmp_dbg_way0_extclass_match),
            .tlb_cmp_dbg_way0_state_match(tlb_cmp_dbg_way0_state_match),
            .tlb_cmp_dbg_way0_thdid_match(tlb_cmp_dbg_way0_thdid_match),
            .tlb_cmp_dbg_way0_pid_match(tlb_cmp_dbg_way0_pid_match),
            .tlb_cmp_dbg_way0_lpid_match(tlb_cmp_dbg_way0_lpid_match),
            .tlb_cmp_dbg_way0_ind_match(tlb_cmp_dbg_way0_ind_match),
            .tlb_cmp_dbg_way0_iprot_match(tlb_cmp_dbg_way0_iprot_match),
            .tlb_cmp_dbg_way1_entry_v(tlb_cmp_dbg_way1_entry_v),
            .tlb_cmp_dbg_way1_addr_match(tlb_cmp_dbg_way1_addr_match),
            .tlb_cmp_dbg_way1_pgsize_match(tlb_cmp_dbg_way1_pgsize_match),
            .tlb_cmp_dbg_way1_class_match(tlb_cmp_dbg_way1_class_match),
            .tlb_cmp_dbg_way1_extclass_match(tlb_cmp_dbg_way1_extclass_match),
            .tlb_cmp_dbg_way1_state_match(tlb_cmp_dbg_way1_state_match),
            .tlb_cmp_dbg_way1_thdid_match(tlb_cmp_dbg_way1_thdid_match),
            .tlb_cmp_dbg_way1_pid_match(tlb_cmp_dbg_way1_pid_match),
            .tlb_cmp_dbg_way1_lpid_match(tlb_cmp_dbg_way1_lpid_match),
            .tlb_cmp_dbg_way1_ind_match(tlb_cmp_dbg_way1_ind_match),
            .tlb_cmp_dbg_way1_iprot_match(tlb_cmp_dbg_way1_iprot_match),
            .tlb_cmp_dbg_way2_entry_v(tlb_cmp_dbg_way2_entry_v),
            .tlb_cmp_dbg_way2_addr_match(tlb_cmp_dbg_way2_addr_match),
            .tlb_cmp_dbg_way2_pgsize_match(tlb_cmp_dbg_way2_pgsize_match),
            .tlb_cmp_dbg_way2_class_match(tlb_cmp_dbg_way2_class_match),
            .tlb_cmp_dbg_way2_extclass_match(tlb_cmp_dbg_way2_extclass_match),
            .tlb_cmp_dbg_way2_state_match(tlb_cmp_dbg_way2_state_match),
            .tlb_cmp_dbg_way2_thdid_match(tlb_cmp_dbg_way2_thdid_match),
            .tlb_cmp_dbg_way2_pid_match(tlb_cmp_dbg_way2_pid_match),
            .tlb_cmp_dbg_way2_lpid_match(tlb_cmp_dbg_way2_lpid_match),
            .tlb_cmp_dbg_way2_ind_match(tlb_cmp_dbg_way2_ind_match),
            .tlb_cmp_dbg_way2_iprot_match(tlb_cmp_dbg_way2_iprot_match),
            .tlb_cmp_dbg_way3_entry_v(tlb_cmp_dbg_way3_entry_v),
            .tlb_cmp_dbg_way3_addr_match(tlb_cmp_dbg_way3_addr_match),
            .tlb_cmp_dbg_way3_pgsize_match(tlb_cmp_dbg_way3_pgsize_match),
            .tlb_cmp_dbg_way3_class_match(tlb_cmp_dbg_way3_class_match),
            .tlb_cmp_dbg_way3_extclass_match(tlb_cmp_dbg_way3_extclass_match),
            .tlb_cmp_dbg_way3_state_match(tlb_cmp_dbg_way3_state_match),
            .tlb_cmp_dbg_way3_thdid_match(tlb_cmp_dbg_way3_thdid_match),
            .tlb_cmp_dbg_way3_pid_match(tlb_cmp_dbg_way3_pid_match),
            .tlb_cmp_dbg_way3_lpid_match(tlb_cmp_dbg_way3_lpid_match),
            .tlb_cmp_dbg_way3_ind_match(tlb_cmp_dbg_way3_ind_match),

            .tlb_cmp_dbg_way3_iprot_match(tlb_cmp_dbg_way3_iprot_match)
         );
         // End of mmq_tlb_cmp component instantiation


         //---------------------------------------------------------------------
         // TLB Logical to Real Address Translation Logic Component Instantiation
         //---------------------------------------------------------------------

         //work.mmq_tlb_lrat #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`EPN_WIDTH(`EPN_WIDTH), .`SPR_DATA_WIDTH(`SPR_DATA_WIDTH), .`REAL_ADDR_WIDTH(`REAL_ADDR_WIDTH), .`RPN_WIDTH(`RPN_WIDTH), .`LPID_WIDTH(`LPID_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_tlb_lrat(
         mmq_tlb_lrat  mmq_tlb_lrat(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .tc_ccflush_dc(tc_ac_ccflush_dc),
            .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .tc_scan_diag_dc(tc_ac_scan_diag_dc),
            .tc_lbist_en_dc(tc_ac_lbist_en_dc),

            .lcb_d_mode_dc(lcb_d_mode_dc),
            .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .lcb_act_dis_dc(lcb_act_dis_dc),
            .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

            .ac_func_scan_in(func_scan_in_int[6]),
            .ac_func_scan_out(func_scan_out_int[6]),

            .pc_sg_2(pc_sg_2[1]),
            .pc_func_sl_thold_2(pc_func_sl_thold_2[1]),
            .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[1]),

            .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[6]),
            .tlb_delayed_act(tlb_delayed_act[20:23]),
            .mmucr2_act_override(mmucr2_sig[3]),

            .tlb_ctl_ex3_valid(tlb_ctl_ex3_valid_sig),
            .tlb_ctl_ex3_ttype(tlb_ctl_ex3_ttype_sig),
            .tlb_ctl_ex3_hv_state(tlb_ctl_ex3_hv_state_sig),
            .xu_ex3_flush(xu_ex3_flush_sig[0:`MM_THREADS-1]),
            .xu_ex4_flush(xu_ex4_flush_sig),
            .xu_ex5_flush(xu_ex5_flush_sig),
            .tlb_tag0_epn(tlb_tag0_epn[64 - `REAL_ADDR_WIDTH:51]),
            .tlb_tag0_thdid(tlb_tag0_thdid),
            .tlb_tag0_type(tlb_tag0_type),
            .tlb_tag0_lpid(tlb_tag0_lpid),
            .tlb_tag0_atsel(tlb_tag0_atsel),
            .tlb_tag0_size(tlb_tag0_size),
            .tlb_tag0_addr_cap(tlb_tag0_addr_cap),
            .ex6_illeg_instr(ex6_illeg_instr),

            .pte_tag0_lpn(pte_tag0_lpn[64 - `REAL_ADDR_WIDTH:51]),
            .pte_tag0_lpid(pte_tag0_lpid),
            .mas0_0_atsel(mas0_0_atsel),
            .mas0_0_esel(mas0_0_esel),
            .mas0_0_hes(mas0_0_hes),
            .mas0_0_wq(mas0_0_wq),
            .mas1_0_v(mas1_0_v),
            .mas1_0_tsize(mas1_0_tsize),
            .mas2_0_epn(mas2_0_epn[64 - `REAL_ADDR_WIDTH:51]),
            .mas7_0_rpnu(mas7_0_rpnu),
            .mas3_0_rpnl(mas3_0_rpnl[32:51]),
            .mas8_0_tlpid(mas8_0_tlpid),
            .mmucr3_0_x(mmucr3_0_sig[49]),
`ifdef MM_THREADS2
            .mas0_1_atsel(mas0_1_atsel),
            .mas0_1_esel(mas0_1_esel),
            .mas0_1_hes(mas0_1_hes),
            .mas0_1_wq(mas0_1_wq),
            .mas1_1_v(mas1_1_v),
            .mas1_1_tsize(mas1_1_tsize),
            .mas2_1_epn(mas2_1_epn[64 - `REAL_ADDR_WIDTH:51]),
            .mas7_1_rpnu(mas7_1_rpnu),
            .mas3_1_rpnl(mas3_1_rpnl[32:51]),
            .mas8_1_tlpid(mas8_1_tlpid),
            .mmucr3_1_x(mmucr3_1_sig[49]),
`endif
            .lrat_mmucr3_x(lrat_mmucr3_x),
            .lrat_mas0_esel(lrat_mas0_esel),
            .lrat_mas1_v(lrat_mas1_v),
            .lrat_mas1_tsize(lrat_mas1_tsize),
            .lrat_mas2_epn(lrat_mas2_epn),
            .lrat_mas3_rpnl(lrat_mas3_rpnl),
            .lrat_mas7_rpnu(lrat_mas7_rpnu),
            .lrat_mas8_tlpid(lrat_mas8_tlpid),
            .lrat_mas_tlbre(lrat_mas_tlbre),
            .lrat_mas_tlbsx_hit(lrat_mas_tlbsx_hit),
            .lrat_mas_tlbsx_miss(lrat_mas_tlbsx_miss),
            .lrat_mas_thdid(lrat_mas_thdid),

            .lrat_tag3_lpn(lrat_tag3_lpn),
            .lrat_tag3_rpn(lrat_tag3_rpn),
            .lrat_tag3_hit_status(lrat_tag3_hit_status),
            .lrat_tag3_hit_entry(lrat_tag3_hit_entry),
            .lrat_tag4_lpn(lrat_tag4_lpn),
            .lrat_tag4_rpn(lrat_tag4_rpn),
            .lrat_tag4_hit_status(lrat_tag4_hit_status),
            .lrat_tag4_hit_entry(lrat_tag4_hit_entry),

            .lrat_dbg_tag1_addr_enable(lrat_dbg_tag1_addr_enable),
            .lrat_dbg_tag2_matchline_q(lrat_dbg_tag2_matchline_q),
            .lrat_dbg_entry0_addr_match(lrat_dbg_entry0_addr_match),
            .lrat_dbg_entry0_lpid_match(lrat_dbg_entry0_lpid_match),
            .lrat_dbg_entry0_entry_v(lrat_dbg_entry0_entry_v),
            .lrat_dbg_entry0_entry_x(lrat_dbg_entry0_entry_x),
            .lrat_dbg_entry0_size(lrat_dbg_entry0_size),
            .lrat_dbg_entry1_addr_match(lrat_dbg_entry1_addr_match),
            .lrat_dbg_entry1_lpid_match(lrat_dbg_entry1_lpid_match),
            .lrat_dbg_entry1_entry_v(lrat_dbg_entry1_entry_v),
            .lrat_dbg_entry1_entry_x(lrat_dbg_entry1_entry_x),
            .lrat_dbg_entry1_size(lrat_dbg_entry1_size),
            .lrat_dbg_entry2_addr_match(lrat_dbg_entry2_addr_match),
            .lrat_dbg_entry2_lpid_match(lrat_dbg_entry2_lpid_match),
            .lrat_dbg_entry2_entry_v(lrat_dbg_entry2_entry_v),
            .lrat_dbg_entry2_entry_x(lrat_dbg_entry2_entry_x),
            .lrat_dbg_entry2_size(lrat_dbg_entry2_size),
            .lrat_dbg_entry3_addr_match(lrat_dbg_entry3_addr_match),
            .lrat_dbg_entry3_lpid_match(lrat_dbg_entry3_lpid_match),
            .lrat_dbg_entry3_entry_v(lrat_dbg_entry3_entry_v),
            .lrat_dbg_entry3_entry_x(lrat_dbg_entry3_entry_x),
            .lrat_dbg_entry3_size(lrat_dbg_entry3_size),
            .lrat_dbg_entry4_addr_match(lrat_dbg_entry4_addr_match),
            .lrat_dbg_entry4_lpid_match(lrat_dbg_entry4_lpid_match),
            .lrat_dbg_entry4_entry_v(lrat_dbg_entry4_entry_v),
            .lrat_dbg_entry4_entry_x(lrat_dbg_entry4_entry_x),
            .lrat_dbg_entry4_size(lrat_dbg_entry4_size),
            .lrat_dbg_entry5_addr_match(lrat_dbg_entry5_addr_match),
            .lrat_dbg_entry5_lpid_match(lrat_dbg_entry5_lpid_match),
            .lrat_dbg_entry5_entry_v(lrat_dbg_entry5_entry_v),
            .lrat_dbg_entry5_entry_x(lrat_dbg_entry5_entry_x),
            .lrat_dbg_entry5_size(lrat_dbg_entry5_size),
            .lrat_dbg_entry6_addr_match(lrat_dbg_entry6_addr_match),
            .lrat_dbg_entry6_lpid_match(lrat_dbg_entry6_lpid_match),
            .lrat_dbg_entry6_entry_v(lrat_dbg_entry6_entry_v),
            .lrat_dbg_entry6_entry_x(lrat_dbg_entry6_entry_x),
            .lrat_dbg_entry6_size(lrat_dbg_entry6_size),
            .lrat_dbg_entry7_addr_match(lrat_dbg_entry7_addr_match),
            .lrat_dbg_entry7_lpid_match(lrat_dbg_entry7_lpid_match),
            .lrat_dbg_entry7_entry_v(lrat_dbg_entry7_entry_v),
            .lrat_dbg_entry7_entry_x(lrat_dbg_entry7_entry_x),
            .lrat_dbg_entry7_size(lrat_dbg_entry7_size)
         );
         // End of mmq_tlb_lrat component instantiation


         //---------------------------------------------------------------------
         // Hardware Table Walker Logic Component Instantiation
         //---------------------------------------------------------------------

         //work.mmq_htw #(.`THREADS(`THREADS), .`THDID_WIDTH(`THDID_WIDTH), .`PID_WIDTH(`PID_WIDTH), .`LPID_WIDTH(`LPID_WIDTH), .`EPN_WIDTH(`EPN_WIDTH), .`REAL_ADDR_WIDTH(`REAL_ADDR_WIDTH), .`RPN_WIDTH(`RPN_WIDTH), .`TLB_WAY_WIDTH(`TLB_WAY_WIDTH), .`TLB_WORD_WIDTH(`TLB_WORD_WIDTH), .`TLB_TAG_WIDTH(`TLB_TAG_WIDTH), .`PTE_WIDTH(`PTE_WIDTH), .`EXPAND_TYPE(`EXPAND_TYPE)) mmq_htw(
         mmq_htw  mmq_htw(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .tc_ccflush_dc(tc_ac_ccflush_dc),
            .tc_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .tc_scan_diag_dc(tc_ac_scan_diag_dc),
            .tc_lbist_en_dc(tc_ac_lbist_en_dc),

            .lcb_d_mode_dc(lcb_d_mode_dc),
            .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .lcb_act_dis_dc(lcb_act_dis_dc),
            .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),

            .ac_func_scan_in( func_scan_in_int[7:8] ),
            .ac_func_scan_out( func_scan_out_int[7:8] ),

            .pc_sg_2(pc_sg_2[1]),
            .pc_func_sl_thold_2(pc_func_sl_thold_2[1]),
            .pc_func_slp_sl_thold_2(pc_func_slp_sl_thold_2[1]),

            .xu_mm_ccr2_notlb_b(xu_mm_ccr2_notlb_b[7]),

            .tlb_delayed_act(tlb_delayed_act[24:28]),
            .mmucr2_act_override(mmucr2_sig[4]),

            .tlb_ctl_tag2_flush(tlb_ctl_tag2_flush_sig),
            .tlb_ctl_tag3_flush(tlb_ctl_tag3_flush_sig),
            .tlb_ctl_tag4_flush(tlb_ctl_tag4_flush_sig),

            .tlb_tag2(tlb_tag2_sig),
            .tlb_tag5_except(tlb_tag5_except),

            .tlb_htw_req_valid(tlb_htw_req_valid),
            .tlb_htw_req_tag(tlb_htw_req_tag),
            .tlb_htw_req_way(tlb_htw_req_way),
            .htw_lsu_req_valid(htw_lsu_req_valid),
            .htw_lsu_thdid(htw_lsu_thdid),
            .htw_dbg_lsu_thdid(htw_dbg_lsu_thdid),
            .htw_lsu_ttype(htw_lsu_ttype),
            .htw_lsu_wimge(htw_lsu_wimge),
            .htw_lsu_u(htw_lsu_u),
            .htw_lsu_addr(htw_lsu_addr),
            .htw_lsu_req_taken(htw_lsu_req_taken),
            .htw_quiesce(htw_quiesce_sig),

            .htw_req0_valid(htw_req0_valid),
            .htw_req0_thdid(htw_req0_thdid),
            .htw_req0_type(htw_req0_type),
            .htw_req1_valid(htw_req1_valid),
            .htw_req1_thdid(htw_req1_thdid),
            .htw_req1_type(htw_req1_type),
            .htw_req2_valid(htw_req2_valid),
            .htw_req2_thdid(htw_req2_thdid),
            .htw_req2_type(htw_req2_type),
            .htw_req3_valid(htw_req3_valid),
            .htw_req3_thdid(htw_req3_thdid),
            .htw_req3_type(htw_req3_type),
            .ptereload_req_valid(ptereload_req_valid),
            .ptereload_req_tag(ptereload_req_tag),
            .ptereload_req_pte(ptereload_req_pte),
            .ptereload_req_taken(ptereload_req_taken),
            .an_ac_reld_core_tag(an_ac_reld_core_tag),
            .an_ac_reld_data(an_ac_reld_data),
            .an_ac_reld_data_vld(an_ac_reld_data_vld),
            .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
            .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
            .an_ac_reld_qw(an_ac_reld_qw[58:59]),
            .an_ac_reld_ditc(an_ac_reld_ditc),
            .an_ac_reld_crit_qw(an_ac_reld_crit_qw),

            .htw_dbg_seq_idle(htw_dbg_seq_idle),
            .htw_dbg_pte0_seq_idle(htw_dbg_pte0_seq_idle),
            .htw_dbg_pte1_seq_idle(htw_dbg_pte1_seq_idle),
            .htw_dbg_seq_q(htw_dbg_seq_q),
            .htw_dbg_inptr_q(htw_dbg_inptr_q),
            .htw_dbg_pte0_seq_q(htw_dbg_pte0_seq_q),
            .htw_dbg_pte1_seq_q(htw_dbg_pte1_seq_q),
            .htw_dbg_ptereload_ptr_q(htw_dbg_ptereload_ptr_q),
            .htw_dbg_lsuptr_q(htw_dbg_lsuptr_q),
            .htw_dbg_req_valid_q(htw_dbg_req_valid_q),
            .htw_dbg_resv_valid_vec(htw_dbg_resv_valid_vec),
            .htw_dbg_tag4_clr_resv_q(htw_dbg_tag4_clr_resv_q),
            .htw_dbg_tag4_clr_resv_terms(htw_dbg_tag4_clr_resv_terms),
            .htw_dbg_pte0_score_ptr_q(htw_dbg_pte0_score_ptr_q),
            .htw_dbg_pte0_score_cl_offset_q(htw_dbg_pte0_score_cl_offset_q),
            .htw_dbg_pte0_score_error_q(htw_dbg_pte0_score_error_q),
            .htw_dbg_pte0_score_qwbeat_q(htw_dbg_pte0_score_qwbeat_q),
            .htw_dbg_pte0_score_pending_q(htw_dbg_pte0_score_pending_q),
            .htw_dbg_pte0_score_ibit_q(htw_dbg_pte0_score_ibit_q),
            .htw_dbg_pte0_score_dataval_q(htw_dbg_pte0_score_dataval_q),
            .htw_dbg_pte0_reld_for_me_tm1(htw_dbg_pte0_reld_for_me_tm1),
            .htw_dbg_pte1_score_ptr_q(htw_dbg_pte1_score_ptr_q),
            .htw_dbg_pte1_score_cl_offset_q(htw_dbg_pte1_score_cl_offset_q),
            .htw_dbg_pte1_score_error_q(htw_dbg_pte1_score_error_q),
            .htw_dbg_pte1_score_qwbeat_q(htw_dbg_pte1_score_qwbeat_q),
            .htw_dbg_pte1_score_pending_q(htw_dbg_pte1_score_pending_q),
            .htw_dbg_pte1_score_ibit_q(htw_dbg_pte1_score_ibit_q),
            .htw_dbg_pte1_score_dataval_q(htw_dbg_pte1_score_dataval_q),

            .htw_dbg_pte1_reld_for_me_tm1(htw_dbg_pte1_reld_for_me_tm1)
         );
      end
   endgenerate
   // End of mmq_htw component instantiation

   generate
      if (`EXPAND_TLB_TYPE == 1)
      begin : tlb_gen_noarrays
         assign tlb_dataout[0:`TLB_WAY_WIDTH - 1] = tlb_dataina;
         assign tlb_dataout[`TLB_WAY_WIDTH:2 * `TLB_WAY_WIDTH - 1] = tlb_dataina;
         assign tlb_dataout[2 * `TLB_WAY_WIDTH:3 * `TLB_WAY_WIDTH - 1] = tlb_dataina;
         assign tlb_dataout[3 * `TLB_WAY_WIDTH:4 * `TLB_WAY_WIDTH - 1] = tlb_dataina;
         assign lru_dataout = lru_datain;
         assign time_scan_int[1:5] = {5{1'b0}};
         assign repr_scan_int[1:5] = {5{1'b0}};
         assign abst_scan_int[1:6] = {6{1'b0}};
      end
   endgenerate

   //---------------------------------------------------------------------
   // TLB Instantiation
   //---------------------------------------------------------------------
   generate
      if (`EXPAND_TLB_TYPE == 2)
      begin : tlb_gen_instance

         //tri.tri_128x168_1w_0 #(.`EXPAND_TYPE(`EXPAND_TYPE)) tlb_array0(
         tri_128x168_1w_0  tlb_array0(
            .gnd(gnd),
            .vdd(vdd),
            .vcs(vdd),
            .nclk(nclk),
            .act(tlb_delayed_act[17]),
            .ccflush_dc(tc_ac_ccflush_dc),
            .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .scan_diag_dc(tc_ac_scan_diag_dc),
            .repr_scan_in(repr_scan_int[0]),
            .time_scan_in(time_scan_int[0]),
            .abst_scan_in(abst_scan_int[0]),
            .repr_scan_out(repr_scan_int[1]),
            .time_scan_out(time_scan_int[1]),
            .abst_scan_out(abst_scan_int[1]),
            .lcb_d_mode_dc(g6t_gptr_lcb_d_mode_dc),
            .lcb_clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
            .lcb_act_dis_dc(g6t_gptr_lcb_act_dis_dc),
            .lcb_mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc),

            .tri_lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
            .tri_lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
            .tri_lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .tri_lcb_act_dis_dc(lcb_act_dis_dc),

            .lcb_sg_1(pc_sg_1[0]),
            .lcb_time_sg_0(pc_sg_0[0]),
            .lcb_repr_sg_0(pc_sg_0[0]),
            .lcb_abst_sl_thold_0(pc_abst_sl_thold_0),
            .lcb_repr_sl_thold_0(pc_repr_sl_thold_0),
            .lcb_time_sl_thold_0(pc_time_sl_thold_0),
            .lcb_ary_nsl_thold_0(pc_ary_slp_nsl_thold_0),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_en_1(pc_mm_abist_ena_dc),
            .din_abist(pc_mm_abist_di_g6t_2r_q),
            .abist_cmp_en(pc_mm_abist_wl128_comp_ena_q),
            .abist_raw_b_dc(pc_mm_abist_raw_dc_b),
            .data_cmp_abist(pc_mm_abist_dcomp_g6t_2r_q),
            .addr_abist(pc_mm_abist_raddr_0_q[3:9]),
            .r_wb_abist(pc_mm_abist_g6t_r_wb_q),
            .lcb_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
            .pc_bo_enable_2(pc_mm_bo_enable_2),
            .pc_bo_reset(pc_mm_bo_reset),
            .pc_bo_unload(pc_mm_bo_unload),
            .pc_bo_repair(pc_mm_bo_repair),
            .pc_bo_shdata(pc_mm_bo_shdata),
            .pc_bo_select(pc_mm_bo_select[0]),
            .bo_pc_failout(mm_pc_bo_fail[0]),
            .bo_pc_diagloop(mm_pc_bo_diagout[0]),

            .write_enable(tlb_write[0]),
            .addr(tlb_addr),
            .data_in(tlb_dataina),
            .data_out(tlb_dataout[0:`TLB_WAY_WIDTH - 1])
         );

         //tri.tri_128x168_1w_0 #(.`EXPAND_TYPE(`EXPAND_TYPE)) tlb_array1(
         tri_128x168_1w_0  tlb_array1(
            .gnd(gnd),
            .vdd(vdd),
            .vcs(vdd),
            .nclk(nclk),
            .act(tlb_delayed_act[17]),

            .ccflush_dc(tc_ac_ccflush_dc),
            .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .scan_diag_dc(tc_ac_scan_diag_dc),
            .repr_scan_in(repr_scan_int[1]),
            .time_scan_in(time_scan_int[1]),
            .abst_scan_in(abst_scan_int[1]),
            .repr_scan_out(repr_scan_int[2]),
            .time_scan_out(time_scan_int[2]),
            .abst_scan_out(abst_scan_int[2]),
            .lcb_d_mode_dc(g6t_gptr_lcb_d_mode_dc),
            .lcb_clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
            .lcb_act_dis_dc(g6t_gptr_lcb_act_dis_dc),
            .lcb_mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc),

            .tri_lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
            .tri_lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
            .tri_lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .tri_lcb_act_dis_dc(lcb_act_dis_dc),

            .lcb_sg_1(pc_sg_1[0]),
            .lcb_time_sg_0(pc_sg_0[0]),
            .lcb_repr_sg_0(pc_sg_0[0]),
            .lcb_abst_sl_thold_0(pc_abst_sl_thold_0),
            .lcb_repr_sl_thold_0(pc_repr_sl_thold_0),
            .lcb_time_sl_thold_0(pc_time_sl_thold_0),
            .lcb_ary_nsl_thold_0(pc_ary_slp_nsl_thold_0),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_en_1(pc_mm_abist_ena_dc),
            .din_abist(pc_mm_abist_di_g6t_2r_q),
            .abist_cmp_en(pc_mm_abist_wl128_comp_ena_q),
            .abist_raw_b_dc(pc_mm_abist_raw_dc_b),
            .data_cmp_abist(pc_mm_abist_dcomp_g6t_2r_q),
            .addr_abist(pc_mm_abist_raddr_0_q[3:9]),
            .r_wb_abist(pc_mm_abist_g6t_r_wb_q),
            .lcb_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
            .pc_bo_enable_2(pc_mm_bo_enable_2),
            .pc_bo_reset(pc_mm_bo_reset),
            .pc_bo_unload(pc_mm_bo_unload),
            .pc_bo_repair(pc_mm_bo_repair),
            .pc_bo_shdata(pc_mm_bo_shdata),
            .pc_bo_select(pc_mm_bo_select[1]),
            .bo_pc_failout(mm_pc_bo_fail[1]),
            .bo_pc_diagloop(mm_pc_bo_diagout[1]),

            .write_enable(tlb_write[1]),
            .addr(tlb_addr),
            .data_in(tlb_dataina),
            .data_out(tlb_dataout[`TLB_WAY_WIDTH:2 * `TLB_WAY_WIDTH - 1])
         );

         //tri.tri_128x168_1w_0 #(.`EXPAND_TYPE(`EXPAND_TYPE)) tlb_array2(
         tri_128x168_1w_0  tlb_array2(
            .gnd(gnd),
            .vdd(vdd),
            .vcs(vdd),
            .nclk(nclk),
            .act(tlb_delayed_act[18]),
            .ccflush_dc(tc_ac_ccflush_dc),
            .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .scan_diag_dc(tc_ac_scan_diag_dc),
            .repr_scan_in(repr_scan_int[2]),
            .time_scan_in(time_scan_int[2]),
            .abst_scan_in(abst_scan_int[3]),
            .repr_scan_out(repr_scan_int[3]),
            .time_scan_out(time_scan_int[3]),
            .abst_scan_out(abst_scan_int[4]),
            .lcb_d_mode_dc(g6t_gptr_lcb_d_mode_dc),
            .lcb_clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
            .lcb_act_dis_dc(g6t_gptr_lcb_act_dis_dc),
            .lcb_mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc),

            .tri_lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
            .tri_lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
            .tri_lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .tri_lcb_act_dis_dc(lcb_act_dis_dc),

            .lcb_sg_1(pc_sg_1[1]),
            .lcb_time_sg_0(pc_sg_0[1]),
            .lcb_repr_sg_0(pc_sg_0[1]),
            .lcb_abst_sl_thold_0(pc_abst_sl_thold_0),
            .lcb_repr_sl_thold_0(pc_repr_sl_thold_0),
            .lcb_time_sl_thold_0(pc_time_sl_thold_0),
            .lcb_ary_nsl_thold_0(pc_ary_slp_nsl_thold_0),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_en_1(pc_mm_abist_ena_dc),
            .din_abist(pc_mm_abist_di_g6t_2r_q),
            .abist_cmp_en(pc_mm_abist_wl128_comp_ena_q),
            .abist_raw_b_dc(pc_mm_abist_raw_dc_b),
            .data_cmp_abist(pc_mm_abist_dcomp_g6t_2r_q),
            .addr_abist(pc_mm_abist_raddr_0_q[3:9]),
            .r_wb_abist(pc_mm_abist_g6t_r_wb_q),
            .lcb_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
            .pc_bo_enable_2(pc_mm_bo_enable_2),
            .pc_bo_reset(pc_mm_bo_reset),
            .pc_bo_unload(pc_mm_bo_unload),
            .pc_bo_repair(pc_mm_bo_repair),
            .pc_bo_shdata(pc_mm_bo_shdata),
            .pc_bo_select(pc_mm_bo_select[2]),
            .bo_pc_failout(mm_pc_bo_fail[2]),
            .bo_pc_diagloop(mm_pc_bo_diagout[2]),

            .write_enable(tlb_write[2]),
            .addr(tlb_addr),
            .data_in(tlb_datainb),
            .data_out(tlb_dataout[2 * `TLB_WAY_WIDTH:3 * `TLB_WAY_WIDTH - 1])
         );

         //tri.tri_128x168_1w_0 #(.`EXPAND_TYPE(`EXPAND_TYPE)) tlb_array3(
         tri_128x168_1w_0  tlb_array3(
            .gnd(gnd),
            .vdd(vdd),
            .vcs(vdd),
            .nclk(nclk),
            .act(tlb_delayed_act[18]),

            .ccflush_dc(tc_ac_ccflush_dc),
            .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .scan_diag_dc(tc_ac_scan_diag_dc),
            .repr_scan_in(repr_scan_int[3]),
            .time_scan_in(time_scan_int[3]),
            .abst_scan_in(abst_scan_int[4]),
            .repr_scan_out(repr_scan_int[4]),
            .time_scan_out(time_scan_int[4]),
            .abst_scan_out(abst_scan_int[5]),
            .lcb_d_mode_dc(g6t_gptr_lcb_d_mode_dc),
            .lcb_clkoff_dc_b(g6t_gptr_lcb_clkoff_dc_b),
            .lcb_act_dis_dc(g6t_gptr_lcb_act_dis_dc),
            .lcb_mpw1_dc_b(g6t_gptr_lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(g6t_gptr_lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(g6t_gptr_lcb_delay_lclkr_dc),

            .tri_lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
            .tri_lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
            .tri_lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .tri_lcb_act_dis_dc(lcb_act_dis_dc),

            .lcb_sg_1(pc_sg_1[1]),
            .lcb_time_sg_0(pc_sg_0[1]),
            .lcb_repr_sg_0(pc_sg_0[1]),
            .lcb_abst_sl_thold_0(pc_abst_sl_thold_0),
            .lcb_repr_sl_thold_0(pc_repr_sl_thold_0),
            .lcb_time_sl_thold_0(pc_time_sl_thold_0),
            .lcb_ary_nsl_thold_0(pc_ary_slp_nsl_thold_0),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_en_1(pc_mm_abist_ena_dc),
            .din_abist(pc_mm_abist_di_g6t_2r_q),
            .abist_cmp_en(pc_mm_abist_wl128_comp_ena_q),
            .abist_raw_b_dc(pc_mm_abist_raw_dc_b),
            .data_cmp_abist(pc_mm_abist_dcomp_g6t_2r_q),
            .addr_abist(pc_mm_abist_raddr_0_q[3:9]),
            .r_wb_abist(pc_mm_abist_g6t_r_wb_q),
            .lcb_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
            .pc_bo_enable_2(pc_mm_bo_enable_2),
            .pc_bo_reset(pc_mm_bo_reset),
            .pc_bo_unload(pc_mm_bo_unload),
            .pc_bo_repair(pc_mm_bo_repair),
            .pc_bo_shdata(pc_mm_bo_shdata),
            .pc_bo_select(pc_mm_bo_select[3]),
            .bo_pc_failout(mm_pc_bo_fail[3]),
            .bo_pc_diagloop(mm_pc_bo_diagout[3]),

            .write_enable(tlb_write[3]),
            .addr(tlb_addr),
            .data_in(tlb_datainb),
            .data_out(tlb_dataout[3 * `TLB_WAY_WIDTH:4 * `TLB_WAY_WIDTH - 1])
         );

         //---------------------------------------------------------------------
         // LRU Instantiation
         //---------------------------------------------------------------------

         //tri.tri_128x16_1r1w_1 #(.`EXPAND_TYPE(`EXPAND_TYPE)) lru_array0(
         tri_128x16_1r1w_1  lru_array0(
            .gnd(gnd),
            .vdd(vdd),
            .vcs(vdd),
            .nclk(nclk),
            .rd_act(tlb_delayed_act[19]),
            .wr_act(tlb_delayed_act[33]),

            .lcb_d_mode_dc(g8t_gptr_lcb_d_mode_dc),
            .lcb_clkoff_dc_b(g8t_gptr_lcb_clkoff_dc_b),
            .lcb_mpw1_dc_b(g8t_gptr_lcb_mpw1_dc_b),
            .lcb_mpw2_dc_b(g8t_gptr_lcb_mpw2_dc_b),
            .lcb_delay_lclkr_dc(g8t_gptr_lcb_delay_lclkr_dc),
            .tri_lcb_mpw1_dc_b(lcb_mpw1_dc_b[0]),
            .tri_lcb_mpw2_dc_b(lcb_mpw2_dc_b),
            .tri_lcb_delay_lclkr_dc(lcb_delay_lclkr_dc[0]),
            .tri_lcb_clkoff_dc_b(lcb_clkoff_dc_b),
            .tri_lcb_act_dis_dc(lcb_act_dis_dc),

            .ccflush_dc(tc_ac_ccflush_dc),
            .scan_dis_dc_b(tc_ac_scan_dis_dc_b),
            .scan_diag_dc(tc_ac_scan_diag_dc),
            .func_scan_in(tidn),
            .func_scan_out(unused_dc_array_scan[0]),

            .lcb_sg_0(pc_sg_0[1]),
            .lcb_sl_thold_0_b(pc_func_slp_sl_thold_0_b[1]),

            .lcb_time_sl_thold_0(pc_time_sl_thold_0),
            .lcb_abst_sl_thold_0(pc_abst_slp_sl_thold_0),
            .lcb_repr_sl_thold_0(pc_repr_sl_thold_0),
            .lcb_ary_nsl_thold_0(pc_ary_slp_nsl_thold_0),

            .time_scan_in(time_scan_int[4]),
            .time_scan_out(time_scan_int[5]),
            .repr_scan_in(repr_scan_int[4]),
            .repr_scan_out(repr_scan_int[5]),
            .abst_scan_in(abst_scan_int[5]),
            .abst_scan_out(abst_scan_int[6]),

            .abist_di(pc_mm_abist_di_0_q),
            .abist_bw_odd(pc_mm_abist_g8t_bw_1_q),
            .abist_bw_even(pc_mm_abist_g8t_bw_0_q),
            .abist_wr_adr(pc_mm_abist_waddr_0_q[3:9]),
            .wr_abst_act(pc_mm_abist_g8t_wenb_q),
            .abist_rd0_adr(pc_mm_abist_raddr_0_q[3:9]),
            .rd0_abst_act(pc_mm_abist_g8t1p_renb_0_q),
            .tc_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
            .abist_ena_1(pc_mm_abist_ena_dc),
            .abist_g8t_rd0_comp_ena(pc_mm_abist_wl128_comp_ena_q),
            .abist_raw_dc_b(pc_mm_abist_raw_dc_b),
            .obs0_abist_cmp(pc_mm_abist_g8t_dcomp_q),

            .lcb_bolt_sl_thold_0(pc_mm_bolt_sl_thold_0),
            .pc_bo_enable_2(pc_mm_bo_enable_2),
            .pc_bo_reset(pc_mm_bo_reset),
            .pc_bo_unload(pc_mm_bo_unload),
            .pc_bo_repair(pc_mm_bo_repair),
            .pc_bo_shdata(pc_mm_bo_shdata),
            .pc_bo_select(pc_mm_bo_select[4]),
            .bo_pc_failout(mm_pc_bo_fail[4]),
            .bo_pc_diagloop(mm_pc_bo_diagout[4]),

            .bw(lru_write[0:`LRU_WIDTH - 1]),
            .wr_adr(lru_wr_addr),
            .rd_adr(lru_rd_addr),
            .di(lru_datain[0:`LRU_WIDTH - 1]),
            .do(lru_dataout[0:`LRU_WIDTH - 1])
         );
      end
   endgenerate

   assign xu_mm_ex2_eff_addr_sig = xu_mm_ex2_eff_addr;
   //---------------------------------------------------------------------
   // end of TLB logic
   //---------------------------------------------------------------------

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv_0[0:scan_right_0] = {sov_0[1:scan_right_0], func_scan_in_int[0]};
   assign func_scan_out_int[0] = sov_0[0];
   assign siv_1[0:scan_right_1] = {sov_1[1:scan_right_1], func_scan_in_int[9]};
   assign func_scan_out_int[9] = sov_1[0];
   assign time_scan_int[0] = time_scan_in_int;
   assign repr_scan_int[0] = repr_scan_in_int;
   assign abst_scan_int[0] = abst_scan_in_int[0];
   assign abst_scan_int[3] = abst_scan_in_int[1];
   assign abst_scan_out_int[0] = abst_scan_int[2];
   assign abst_scan_out_int[1] = abst_scan_int[6];
   assign time_scan_out_int = time_scan_int[5];
   assign repr_scan_out_int = repr_scan_int[5];
   assign bcfg_scan_out_int = bcfg_scan_in_int;
   assign dcfg_scan_out_int = dcfg_scan_in_int;
   assign bsiv[0] = ccfg_scan_in_int;
   assign ccfg_scan_out_int = bsov[boot_scan_right];
   assign unused_dc[0] = 1'b0;
   assign unused_dc[1] = pc_ary_nsl_thold_0;
   assign unused_dc[2:3] = pc_func_sl_thold_0[0:1];
   assign unused_dc[4:5] = pc_func_sl_thold_0_b[0:1];
   assign unused_dc[6:7] = pc_func_slp_sl_thold_0[0:1];
   assign unused_dc[8] = g8t_gptr_lcb_act_dis_dc;
   assign unused_dc[9:11] = pc_mm_abist_raddr_0_q[0:2];
   assign unused_dc[12:14] = pc_mm_abist_waddr_0_q[0:2];
   assign unused_dc[15] = pc_func_slp_sl_thold_0_b[0];
`ifdef MM_THREADS2
   assign unused_dc[16] = |(mmucr0_0_sig[0:1]) | |(mmucr0_1_sig[0:1]);
`else
   assign unused_dc[16] = |(mmucr0_0_sig[0:1]);
`endif

   generate
      if (`MM_THREADS - `THREADS == 1)
      begin : mmUnusedDCThreads1
         assign unused_dc[17] = |(mm_iu_ierat_pid_sig[`MM_THREADS-1]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-1]) | |(mm_xu_derat_pid_sig[`MM_THREADS-1]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-1]);
         assign unused_dc[18:19] = {2{1'b0}};
      end
   endgenerate

   generate
      if (`MM_THREADS - `THREADS == 2)
      begin : mmUnusedDCThreads2
         assign unused_dc[17] = |(mm_iu_ierat_pid_sig[`MM_THREADS-2]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-2]) | |(mm_xu_derat_pid_sig[`MM_THREADS-2]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-2]);
         assign unused_dc[18] = |(mm_iu_ierat_pid_sig[`MM_THREADS-1]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-1]) | |(mm_xu_derat_pid_sig[`MM_THREADS-1]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-1]);
         assign unused_dc[19] = 1'b0;
      end
   endgenerate

   generate
      if (`MM_THREADS - `THREADS == 3)
      begin : mmUnusedDCThreads3
         assign unused_dc[17] = |(mm_iu_ierat_pid_sig[`MM_THREADS-3]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-3]) | |(mm_xu_derat_pid_sig[`MM_THREADS-3]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-3]);
         assign unused_dc[18] = |(mm_iu_ierat_pid_sig[`MM_THREADS-2]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-2]) | |(mm_xu_derat_pid_sig[`MM_THREADS-2]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-2]);
         assign unused_dc[19] = |(mm_iu_ierat_pid_sig[`MM_THREADS-1]) | |(mm_iu_ierat_mmucr0_sig[`MM_THREADS-1]) | |(mm_xu_derat_pid_sig[`MM_THREADS-1]) | |(mm_xu_derat_mmucr0_sig[`MM_THREADS-1]);
      end
   endgenerate

   generate
      if (`THREADS == `MM_THREADS)
      begin : mmUnusedDCThreadsEQ
         assign unused_dc[17:19] = {3{1'b0}};
      end
   endgenerate

   generate
      if (`MM_THREADS < 4)
      begin : mmUnusedACT
         assign unused_dc[20] = |(tlb_delayed_act[29 + `MM_THREADS:32]);
         assign unused_dc[21] = |(tlb_req_quiesce_sig[`MM_THREADS:3]);
         assign unused_dc[22] = |(htw_quiesce_sig[`MM_THREADS:3]);
         assign unused_dc[23] = |(htw_lsu_thdid[`MM_THREADS:3]);
      end
   endgenerate

   generate
      if (`MM_THREADS == 4)
      begin : mmUsedACT
         assign unused_dc[20:23] = {4{1'b0}};
      end
   endgenerate

   assign unused_dc[24:27] = mmucr1_sig[0:3];
   assign unused_dc[28:31] = mmucr1_sig[6:9];
   assign unused_dc[32:43] = mmucr1_sig[20:31];
   assign unused_dc[44:65] = tlb_tag0_epn[0:21];
   assign unused_dc[66:70] = xu_mm_ccr2_notlb_b[8:12];

`ifdef THREADS1
   assign unused_dc[71] = |(cp_mm_except_taken_t1_sig);
`else
   assign unused_dc[71] = 1'b0;
`endif

   generate
      if (`THREADS < `MM_THREADS)
      begin : mmUnusedDCThreads
         assign unused_dc[72:72 + `MM_THREADS-`THREADS-1] = mm_xu_ord_n_flush_req_sig[`THREADS:`MM_THREADS-1] | mm_xu_ord_np1_flush_req_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_ord_read_done_sig[`THREADS:`MM_THREADS-1] | mm_xu_ord_write_done_sig[`THREADS:`MM_THREADS-1] | mm_xu_lrat_miss_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_pt_fault_sig[`THREADS:`MM_THREADS-1] | mm_xu_hv_priv_sig[`THREADS:`MM_THREADS-1] | mm_xu_esr_pt_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_esr_data_sig[`THREADS:`MM_THREADS-1] | mm_xu_esr_epid_sig[`THREADS:`MM_THREADS-1] | mm_xu_esr_st_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_quiesce_sig[`THREADS:`MM_THREADS-1] | mm_pc_tlb_req_quiesce_sig[`THREADS:`MM_THREADS-1] | mm_pc_tlb_ctl_quiesce_sig[`THREADS:`MM_THREADS-1] |
            mm_pc_htw_quiesce_sig[`THREADS:`MM_THREADS-1] | mm_pc_inval_quiesce_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_local_snoop_reject_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_tlb_multihit_err_sig[`THREADS:`MM_THREADS-1] | mm_xu_tlb_par_err_sig[`THREADS:`MM_THREADS-1] | mm_xu_lru_par_err_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_ex3_flush_req_sig[`THREADS:`MM_THREADS-1] | mm_iu_hold_req_sig[`THREADS:`MM_THREADS-1] |
            mm_iu_hold_done_sig[`THREADS:`MM_THREADS-1] | mm_iu_bus_snoop_hold_req_sig[`THREADS:`MM_THREADS-1] | mm_iu_bus_snoop_hold_done_sig[`THREADS:`MM_THREADS-1] |
            mm_iu_flush_req_sig[`THREADS:`MM_THREADS-1] | mm_iu_tlbi_complete_sig[`THREADS:`MM_THREADS-1] | mm_xu_illeg_instr_sig[`THREADS:`MM_THREADS-1] |
            mm_xu_cr0_eq_sig[`THREADS:`MM_THREADS-1] | mm_xu_cr0_eq_valid_sig[`THREADS:`MM_THREADS-1] | mm_xu_lsu_req_sig[`THREADS:`MM_THREADS-1];
      end
   endgenerate

   assign mm_xu_derat_rel_itag = tlb_tag5_itag_sig;
   assign mm_xu_derat_rel_emq = tlb_tag5_emq_sig;

endmodule
