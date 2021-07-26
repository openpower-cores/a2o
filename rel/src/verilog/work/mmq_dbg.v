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
//*
//* TITLE: debug event mux
//*
//* NAME: mmq_dbg.v
//*
//*********************************************************************

`timescale 1 ns / 1 ns

`include "tri_a2o.vh"
`include "mmu_a2o.vh"


module mmq_dbg(

   inout                      vdd,
   inout                      gnd,
   (* pin_data ="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]    nclk,

   input                      pc_func_slp_sl_thold_2,
   input                      pc_func_slp_nsl_thold_2,
   input                      pc_sg_2,
   input                      pc_fce_2,
   input                      tc_ac_ccflush_dc,

   input                      lcb_clkoff_dc_b,
   input                      lcb_act_dis_dc,
   input                      lcb_d_mode_dc,
   input                      lcb_delay_lclkr_dc,
   input                      lcb_mpw1_dc_b,
   input                      lcb_mpw2_dc_b,

(* pin_data="PIN_FUNCTION=/SCAN_IN/" *)
   input                      scan_in,
(* pin_data="PIN_FUNCTION=/SCAN_OUT/" *)
   output                     scan_out,

   input [8:11]               mmucr2,

   input                      pc_mm_trace_bus_enable,
   input [0:10]               pc_mm_debug_mux1_ctrls,

   input [0:`DEBUG_TRACE_WIDTH-1]               debug_bus_in,
   output [0:`DEBUG_TRACE_WIDTH-1]              debug_bus_out,

   // Instruction Trace (HTM) Control Signals:
   //  0    - ac_an_coretrace_first_valid
   //  1    - ac_an_coretrace_valid
   //  2:3  - ac_an_coretrace_type[0:1]
   input  [0:3]           coretrace_ctrls_in,
   output [0:3]           coretrace_ctrls_out,

   //--------- spr debug signals
   input                      spr_dbg_match_64b,		// these match sigs are spr_int phase
   input                      spr_dbg_match_any_mmu,
   input                      spr_dbg_match_any_mas,
   input                      spr_dbg_match_pid,
   input                      spr_dbg_match_lpidr,
   input                      spr_dbg_match_mmucr0,
   input                      spr_dbg_match_mmucr1,
   input                      spr_dbg_match_mmucr2,
   input                      spr_dbg_match_mmucr3,

   input                      spr_dbg_match_mmucsr0,
   input                      spr_dbg_match_mmucfg,
   input                      spr_dbg_match_tlb0cfg,
   input                      spr_dbg_match_tlb0ps,
   input                      spr_dbg_match_lratcfg,
   input                      spr_dbg_match_lratps,
   input                      spr_dbg_match_eptcfg,
   input                      spr_dbg_match_lper,
   input                      spr_dbg_match_lperu,

   input                      spr_dbg_match_mas0,
   input                      spr_dbg_match_mas1,
   input                      spr_dbg_match_mas2,
   input                      spr_dbg_match_mas2u,
   input                      spr_dbg_match_mas3,
   input                      spr_dbg_match_mas4,
   input                      spr_dbg_match_mas5,
   input                      spr_dbg_match_mas6,
   input                      spr_dbg_match_mas7,
   input                      spr_dbg_match_mas8,
   input                      spr_dbg_match_mas01_64b,
   input                      spr_dbg_match_mas56_64b,
   input                      spr_dbg_match_mas73_64b,
   input                      spr_dbg_match_mas81_64b,

   input                      spr_dbg_slowspr_val_int,		// spr_int phase
   input                      spr_dbg_slowspr_rw_int,
   input [0:1]                spr_dbg_slowspr_etid_int,
   input [0:9]                spr_dbg_slowspr_addr_int,
   input                      spr_dbg_slowspr_val_out,		// spr_out phase
   input                      spr_dbg_slowspr_done_out,
   input [0:63]               spr_dbg_slowspr_data_out,

   //--------- mmq_inval debug signals
   input [0:4]                inval_dbg_seq_q,
   input                      inval_dbg_seq_idle,
   input                      inval_dbg_seq_snoop_inprogress,
   input                      inval_dbg_seq_snoop_done,
   input                      inval_dbg_seq_local_done,
   input                      inval_dbg_seq_tlb0fi_done,
   input                      inval_dbg_seq_tlbwe_snoop_done,
   input                      inval_dbg_ex6_valid,
   input [0:1]                inval_dbg_ex6_thdid,		// encoded
   input [0:2]                inval_dbg_ex6_ttype,		// encoded
   input                      inval_dbg_snoop_forme,
   input                      inval_dbg_snoop_local_reject,
   input [2:8]                inval_dbg_an_ac_back_inv_q,		// 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
   input [0:7]                inval_dbg_an_ac_back_inv_lpar_id_q,
   input [22:63]              inval_dbg_an_ac_back_inv_addr_q,
   input [0:2]                inval_dbg_snoop_valid_q,
   input [0:2]                inval_dbg_snoop_ack_q,
   input [0:34]               inval_dbg_snoop_attr_q,
   input [18:19]              inval_dbg_snoop_attr_tlb_spec_q,
   input [17:51]              inval_dbg_snoop_vpn_q,
   input [0:1]                inval_dbg_lsu_tokens_q,

   //--------- tlb_req debug signals
   input                      tlb_req_dbg_ierat_iu5_valid_q,
   input [0:1]                tlb_req_dbg_ierat_iu5_thdid,
   input [0:3]                tlb_req_dbg_ierat_iu5_state_q,
   input [0:1]                tlb_req_dbg_ierat_inptr_q,
   input [0:1]                tlb_req_dbg_ierat_outptr_q,
   input [0:3]                tlb_req_dbg_ierat_req_valid_q,
   input [0:3]                tlb_req_dbg_ierat_req_nonspec_q,
   input [0:7]                tlb_req_dbg_ierat_req_thdid,		// encoded
   input [0:3]                tlb_req_dbg_ierat_req_dup_q,
   input                      tlb_req_dbg_derat_ex6_valid_q,
   input [0:1]                tlb_req_dbg_derat_ex6_thdid,		// encoded
   input [0:3]                tlb_req_dbg_derat_ex6_state_q,
   input [0:1]                tlb_req_dbg_derat_inptr_q,
   input [0:1]                tlb_req_dbg_derat_outptr_q,
   input [0:3]                tlb_req_dbg_derat_req_valid_q,
   input [0:7]                tlb_req_dbg_derat_req_thdid,		// encoded
   input [0:7]                tlb_req_dbg_derat_req_ttype_q,
   input [0:3]                tlb_req_dbg_derat_req_dup_q,

   //--------- tlb_ctl debug signals
   input [0:5]                tlb_ctl_dbg_seq_q,		// tlb_seq_q
   input                      tlb_ctl_dbg_seq_idle,
   input                      tlb_ctl_dbg_seq_any_done_sig,
   input                      tlb_ctl_dbg_seq_abort,
   input                      tlb_ctl_dbg_any_tlb_req_sig,
   input                      tlb_ctl_dbg_any_req_taken_sig,
   input                      tlb_ctl_dbg_tag0_valid,
   input [0:1]                tlb_ctl_dbg_tag0_thdid,		// encoded
   input [0:2]                tlb_ctl_dbg_tag0_type,		// encoded
   input [0:1]                tlb_ctl_dbg_tag0_wq,		// encoded
   input                      tlb_ctl_dbg_tag0_gs,
   input                      tlb_ctl_dbg_tag0_pr,
   input                      tlb_ctl_dbg_tag0_atsel,
   input [0:3]                tlb_ctl_dbg_tag5_tlb_write_q,
   input [0:3]                tlb_ctl_dbg_resv_valid,
   input [0:3]                tlb_ctl_dbg_set_resv,
   input [0:3]                tlb_ctl_dbg_resv_match_vec_q,
   input                      tlb_ctl_dbg_any_tag_flush_sig,
   input                      tlb_ctl_dbg_resv0_tag0_lpid_match,
   input                      tlb_ctl_dbg_resv0_tag0_pid_match,
   input                      tlb_ctl_dbg_resv0_tag0_as_snoop_match,
   input                      tlb_ctl_dbg_resv0_tag0_gs_snoop_match,
   input                      tlb_ctl_dbg_resv0_tag0_as_tlbwe_match,
   input                      tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match,
   input                      tlb_ctl_dbg_resv0_tag0_ind_match,
   input                      tlb_ctl_dbg_resv0_tag0_epn_loc_match,
   input                      tlb_ctl_dbg_resv0_tag0_epn_glob_match,
   input                      tlb_ctl_dbg_resv0_tag0_class_match,
   input                      tlb_ctl_dbg_resv1_tag0_lpid_match,
   input                      tlb_ctl_dbg_resv1_tag0_pid_match,
   input                      tlb_ctl_dbg_resv1_tag0_as_snoop_match,
   input                      tlb_ctl_dbg_resv1_tag0_gs_snoop_match,
   input                      tlb_ctl_dbg_resv1_tag0_as_tlbwe_match,
   input                      tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match,
   input                      tlb_ctl_dbg_resv1_tag0_ind_match,
   input                      tlb_ctl_dbg_resv1_tag0_epn_loc_match,
   input                      tlb_ctl_dbg_resv1_tag0_epn_glob_match,
   input                      tlb_ctl_dbg_resv1_tag0_class_match,
   input                      tlb_ctl_dbg_resv2_tag0_lpid_match,
   input                      tlb_ctl_dbg_resv2_tag0_pid_match,
   input                      tlb_ctl_dbg_resv2_tag0_as_snoop_match,
   input                      tlb_ctl_dbg_resv2_tag0_gs_snoop_match,
   input                      tlb_ctl_dbg_resv2_tag0_as_tlbwe_match,
   input                      tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match,
   input                      tlb_ctl_dbg_resv2_tag0_ind_match,
   input                      tlb_ctl_dbg_resv2_tag0_epn_loc_match,
   input                      tlb_ctl_dbg_resv2_tag0_epn_glob_match,
   input                      tlb_ctl_dbg_resv2_tag0_class_match,
   input                      tlb_ctl_dbg_resv3_tag0_lpid_match,
   input                      tlb_ctl_dbg_resv3_tag0_pid_match,
   input                      tlb_ctl_dbg_resv3_tag0_as_snoop_match,
   input                      tlb_ctl_dbg_resv3_tag0_gs_snoop_match,
   input                      tlb_ctl_dbg_resv3_tag0_as_tlbwe_match,
   input                      tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match,
   input                      tlb_ctl_dbg_resv3_tag0_ind_match,
   input                      tlb_ctl_dbg_resv3_tag0_epn_loc_match,
   input                      tlb_ctl_dbg_resv3_tag0_epn_glob_match,
   input                      tlb_ctl_dbg_resv3_tag0_class_match,
   input [0:3]                tlb_ctl_dbg_clr_resv_q,		// tag5
   input [0:3]                tlb_ctl_dbg_clr_resv_terms,		// tag5, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload

   //--------- tlb_cmp debug signals
   input [0:`TLB_TAG_WIDTH-1]  tlb_cmp_dbg_tag4,
   input [0:`TLB_WAYS]         tlb_cmp_dbg_tag4_wayhit,
   input [0:`TLB_ADDR_WIDTH-1] tlb_cmp_dbg_addr4,
   input [0:`TLB_WAY_WIDTH-1]  tlb_cmp_dbg_tag4_way,
   input [0:4]                 tlb_cmp_dbg_tag4_parerr,
   input [0:`LRU_WIDTH-5]      tlb_cmp_dbg_tag4_lru_dataout_q,
   input [0:`TLB_WAY_WIDTH-1]  tlb_cmp_dbg_tag5_tlb_datain_q,
   input [0:`LRU_WIDTH-5]      tlb_cmp_dbg_tag5_lru_datain_q,
   input                       tlb_cmp_dbg_tag5_lru_write,
   input                       tlb_cmp_dbg_tag5_any_exception,
   input [0:3]                 tlb_cmp_dbg_tag5_except_type_q,
   input [0:1]                 tlb_cmp_dbg_tag5_except_thdid_q,
   input [0:9]                 tlb_cmp_dbg_tag5_erat_rel_val,
   input [0:131]               tlb_cmp_dbg_tag5_erat_rel_data,
   input [0:19]                tlb_cmp_dbg_erat_dup_q,

   input [0:8]                tlb_cmp_dbg_addr_enable,
   input                      tlb_cmp_dbg_pgsize_enable,
   input                      tlb_cmp_dbg_class_enable,
   input [0:1]                tlb_cmp_dbg_extclass_enable,
   input [0:1]                tlb_cmp_dbg_state_enable,
   input                      tlb_cmp_dbg_thdid_enable,
   input                      tlb_cmp_dbg_pid_enable,
   input                      tlb_cmp_dbg_lpid_enable,
   input                      tlb_cmp_dbg_ind_enable,
   input                      tlb_cmp_dbg_iprot_enable,
   input                      tlb_cmp_dbg_way0_entry_v,		// these are tag3 versions
   input                      tlb_cmp_dbg_way0_addr_match,
   input                      tlb_cmp_dbg_way0_pgsize_match,
   input                      tlb_cmp_dbg_way0_class_match,
   input                      tlb_cmp_dbg_way0_extclass_match,
   input                      tlb_cmp_dbg_way0_state_match,
   input                      tlb_cmp_dbg_way0_thdid_match,
   input                      tlb_cmp_dbg_way0_pid_match,
   input                      tlb_cmp_dbg_way0_lpid_match,
   input                      tlb_cmp_dbg_way0_ind_match,
   input                      tlb_cmp_dbg_way0_iprot_match,
   input                      tlb_cmp_dbg_way1_entry_v,
   input                      tlb_cmp_dbg_way1_addr_match,
   input                      tlb_cmp_dbg_way1_pgsize_match,
   input                      tlb_cmp_dbg_way1_class_match,
   input                      tlb_cmp_dbg_way1_extclass_match,
   input                      tlb_cmp_dbg_way1_state_match,
   input                      tlb_cmp_dbg_way1_thdid_match,
   input                      tlb_cmp_dbg_way1_pid_match,
   input                      tlb_cmp_dbg_way1_lpid_match,
   input                      tlb_cmp_dbg_way1_ind_match,
   input                      tlb_cmp_dbg_way1_iprot_match,
   input                      tlb_cmp_dbg_way2_entry_v,
   input                      tlb_cmp_dbg_way2_addr_match,
   input                      tlb_cmp_dbg_way2_pgsize_match,
   input                      tlb_cmp_dbg_way2_class_match,
   input                      tlb_cmp_dbg_way2_extclass_match,
   input                      tlb_cmp_dbg_way2_state_match,
   input                      tlb_cmp_dbg_way2_thdid_match,
   input                      tlb_cmp_dbg_way2_pid_match,
   input                      tlb_cmp_dbg_way2_lpid_match,
   input                      tlb_cmp_dbg_way2_ind_match,
   input                      tlb_cmp_dbg_way2_iprot_match,
   input                      tlb_cmp_dbg_way3_entry_v,
   input                      tlb_cmp_dbg_way3_addr_match,
   input                      tlb_cmp_dbg_way3_pgsize_match,
   input                      tlb_cmp_dbg_way3_class_match,
   input                      tlb_cmp_dbg_way3_extclass_match,
   input                      tlb_cmp_dbg_way3_state_match,
   input                      tlb_cmp_dbg_way3_thdid_match,
   input                      tlb_cmp_dbg_way3_pid_match,
   input                      tlb_cmp_dbg_way3_lpid_match,
   input                      tlb_cmp_dbg_way3_ind_match,
   input                      tlb_cmp_dbg_way3_iprot_match,

   //--------- lrat debug signals
   input                      lrat_dbg_tag1_addr_enable,
   input [0:7]                lrat_dbg_tag2_matchline_q,
   input                      lrat_dbg_entry0_addr_match,		// tag2
   input                      lrat_dbg_entry0_lpid_match,
   input                      lrat_dbg_entry0_entry_v,
   input                      lrat_dbg_entry0_entry_x,
   input [0:3]                lrat_dbg_entry0_size,
   input                      lrat_dbg_entry1_addr_match,		// tag2
   input                      lrat_dbg_entry1_lpid_match,
   input                      lrat_dbg_entry1_entry_v,
   input                      lrat_dbg_entry1_entry_x,
   input [0:3]                lrat_dbg_entry1_size,
   input                      lrat_dbg_entry2_addr_match,		// tag2
   input                      lrat_dbg_entry2_lpid_match,
   input                      lrat_dbg_entry2_entry_v,
   input                      lrat_dbg_entry2_entry_x,
   input [0:3]                lrat_dbg_entry2_size,
   input                      lrat_dbg_entry3_addr_match,		// tag2
   input                      lrat_dbg_entry3_lpid_match,
   input                      lrat_dbg_entry3_entry_v,
   input                      lrat_dbg_entry3_entry_x,
   input [0:3]                lrat_dbg_entry3_size,
   input                      lrat_dbg_entry4_addr_match,		// tag2
   input                      lrat_dbg_entry4_lpid_match,
   input                      lrat_dbg_entry4_entry_v,
   input                      lrat_dbg_entry4_entry_x,
   input [0:3]                lrat_dbg_entry4_size,
   input                      lrat_dbg_entry5_addr_match,		// tag2
   input                      lrat_dbg_entry5_lpid_match,
   input                      lrat_dbg_entry5_entry_v,
   input                      lrat_dbg_entry5_entry_x,
   input [0:3]                lrat_dbg_entry5_size,
   input                      lrat_dbg_entry6_addr_match,		// tag2
   input                      lrat_dbg_entry6_lpid_match,
   input                      lrat_dbg_entry6_entry_v,
   input                      lrat_dbg_entry6_entry_x,
   input [0:3]                lrat_dbg_entry6_size,
   input                      lrat_dbg_entry7_addr_match,		// tag2
   input                      lrat_dbg_entry7_lpid_match,
   input                      lrat_dbg_entry7_entry_v,
   input                      lrat_dbg_entry7_entry_x,
   input [0:3]                lrat_dbg_entry7_size,

   //--------- mmq_htw debug signals
   input                      htw_dbg_seq_idle,
   input                      htw_dbg_pte0_seq_idle,
   input                      htw_dbg_pte1_seq_idle,
   input [0:1]                htw_dbg_seq_q,
   input [0:1]                htw_dbg_inptr_q,
   input [0:2]                htw_dbg_pte0_seq_q,
   input [0:2]                htw_dbg_pte1_seq_q,
   input                      htw_dbg_ptereload_ptr_q,
   input [0:1]                htw_dbg_lsuptr_q,
   input [0:3]                htw_dbg_req_valid_q,
   input [0:3]                htw_dbg_resv_valid_vec,
   input [0:3]                htw_dbg_tag4_clr_resv_q,
   input [0:3]                htw_dbg_tag4_clr_resv_terms,		// tag4, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload
   input [0:1]                htw_dbg_pte0_score_ptr_q,
   input [58:60]              htw_dbg_pte0_score_cl_offset_q,
   input [0:2]                htw_dbg_pte0_score_error_q,
   input [0:3]                htw_dbg_pte0_score_qwbeat_q,		// 4 beats of data per CL
   input                      htw_dbg_pte0_score_pending_q,
   input                      htw_dbg_pte0_score_ibit_q,
   input                      htw_dbg_pte0_score_dataval_q,
   input                      htw_dbg_pte0_reld_for_me_tm1,
   input [0:1]                htw_dbg_pte1_score_ptr_q,
   input [58:60]              htw_dbg_pte1_score_cl_offset_q,
   input [0:2]                htw_dbg_pte1_score_error_q,
   input [0:3]                htw_dbg_pte1_score_qwbeat_q,		// 4 beats of data per CL
   input                      htw_dbg_pte1_score_pending_q,
   input                      htw_dbg_pte1_score_ibit_q,
   input                      htw_dbg_pte1_score_dataval_q,
   input                      htw_dbg_pte1_reld_for_me_tm1,

   //--------- lsu debug signals
   input [0:`THREADS-1]       mm_xu_lsu_req,
   // 0=tlbivax_op, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
   input [0:1]                mm_xu_lsu_ttype,
   input [0:4]                mm_xu_lsu_wimge,
   input [0:3]                mm_xu_lsu_u,
   input [22:63]              mm_xu_lsu_addr,
   input [0:7]                mm_xu_lsu_lpid,		// tlbivax data
   input                      mm_xu_lsu_gs,		// tlbivax data
   input                      mm_xu_lsu_ind,		// tlbivax data
   input                      mm_xu_lsu_lbit,		// -- tlbivax data, "L" bit, for large vs. small
   input                      xu_mm_lsu_token,

   //--------- misc top level debug signals
   input                      tlb_mas_tlbre,
   input                      tlb_mas_tlbsx_hit,
   input                      tlb_mas_tlbsx_miss,
   input                      tlb_mas_dtlb_error,
   input                      tlb_mas_itlb_error,
   input [0:`THDID_WIDTH-1]   tlb_mas_thdid,
   input                      lrat_mas_tlbre,
   input                      lrat_mas_tlbsx_hit,
   input                      lrat_mas_tlbsx_miss,
   input [0:`THDID_WIDTH-1]   lrat_mas_thdid,
   input [0:3]                lrat_tag3_hit_status,		// val,hit,multihit,inval_pgsize
   input [0:2]                lrat_tag3_hit_entry,

   input                      tlb_seq_ierat_req,
   input                      tlb_seq_derat_req,
   input [0:`THREADS-1]       mm_xu_hold_req,
   input [0:`THREADS-1]       xu_mm_hold_ack,
   input [0:`THREADS-1]       mm_xu_hold_done,
   input                      mmucsr0_tlb0fi,
   input                      tlbwe_back_inv_valid,
   input [18:19]              tlbwe_back_inv_attr,
   input                      xu_mm_lmq_stq_empty,
   input                      iu_mm_lmq_empty,
   input [0:`THREADS-1]       mm_xu_eratmiss_done,
   input [0:`THREADS-1]       mm_iu_barrier_done,
   input [0:`THREADS-1]       mm_xu_ex3_flush_req,
   input [0:`THREADS-1]       mm_xu_illeg_instr,
   input [0:3]                lrat_tag4_hit_status,
   input [0:2]                lrat_tag4_hit_entry,
   input [0:`THREADS-1]       mm_xu_cr0_eq,		// for record forms
   input [0:`THREADS-1]       mm_xu_cr0_eq_valid,	// for record forms
   input                      tlb_htw_req_valid,
   input                      htw_lsu_req_valid,
   input [0:1]                htw_dbg_lsu_thdid,
   input [0:1]                htw_lsu_ttype,
   input [22:63]              htw_lsu_addr,
   input                      ptereload_req_taken,

   input [0:63]               ptereload_req_pte		// pte entry

);


      parameter                 DEBUG_LATCH_WIDTH = 372;
      parameter                 TRIGGER_LATCH_WIDTH = 48;

      wire                       pc_mm_trace_bus_enable_q;		// input=>pc_mm_trace_bus_enable, sleep=>Y,   needs_sreset=>0
//========================================================================================
      wire [0:10]                pc_mm_debug_mux1_ctrls_q;		// input=>pc_mm_debug_mux1_ctrls,  act=>pc_mm_trace_bus_enable_q, sleep=>Y, needs_sreset=>0
      wire [0:10]                pc_mm_debug_mux1_ctrls_loc_d;
      wire [0:10]                pc_mm_debug_mux1_ctrls_loc_q;
      wire [0:`DEBUG_TRIGGER_WIDTH-1]              trigger_data_out_d;
      wire [0:`DEBUG_TRIGGER_WIDTH-1]              trigger_data_out_q;
      wire [0:`DEBUG_TRACE_WIDTH-1]                trace_data_out_d;
      wire [0:`DEBUG_TRACE_WIDTH-1]                trace_data_out_q;
      wire [0:7]                 trace_data_out_int_q;
      wire [0:DEBUG_LATCH_WIDTH-1]    debug_d;		// act=>pc_mm_trace_bus_enable_q,  sleep=>Y,  needs_sreset=>0, scan=>N
      wire [0:DEBUG_LATCH_WIDTH-1]    debug_q;
      wire [0:TRIGGER_LATCH_WIDTH-1]  trigger_d;		// act=>pc_mm_trace_bus_enable_q,  sleep=>Y,  needs_sreset=>0, scan=>N
      wire [0:TRIGGER_LATCH_WIDTH-1]  trigger_q;
      wire [0:`DEBUG_TRACE_WIDTH-1]      debug_bus_in_q;
      wire [0:`DEBUG_TRIGGER_WIDTH-1]    trace_triggers_in_q;
      wire [0:3]    coretrace_ctrls_in_q;
      wire [0:3]    coretrace_ctrls_out_d, coretrace_ctrls_out_q;

      parameter                  trace_bus_enable_offset = 0;
      parameter                  debug_mux1_ctrls_offset = trace_bus_enable_offset + 1;
      parameter                  debug_mux1_ctrls_loc_offset = debug_mux1_ctrls_offset + 11;
      parameter                  trigger_data_out_offset = debug_mux1_ctrls_loc_offset + 11;
      parameter                  trace_data_out_offset = trigger_data_out_offset + `DEBUG_TRIGGER_WIDTH;
      parameter                  trace_data_out_int_offset = trace_data_out_offset + `DEBUG_TRACE_WIDTH;
      parameter                  coretrace_ctrls_out_offset = trace_data_out_int_offset + 8;
      parameter                  scan_right = coretrace_ctrls_out_offset + 4 - 1;
//========================================================================================
      // non-scan latches

      wire [0:87]                dbg_group0;
      wire [0:87]                dbg_group1;
      wire [0:87]                dbg_group2;
      wire [0:87]                dbg_group3;
      wire [0:87]                dbg_group4;
      wire [0:87]                dbg_group5;
      wire [0:87]                dbg_group6;
      wire [0:87]                dbg_group7;
      wire [0:87]                dbg_group8;
      wire [0:87]                dbg_group9;

      wire [0:87]                dbg_group10a;
      wire [0:87]                dbg_group11a;
      wire [0:87]                dbg_group12a;
      wire [0:87]                dbg_group13a;
      wire [0:87]                dbg_group14a;
      wire [0:87]                dbg_group15a;
      wire [0:87]                dbg_group10b;
      wire [0:87]                dbg_group11b;
      wire [0:87]                dbg_group12b;
      wire [0:87]                dbg_group13b;
      wire [0:87]                dbg_group14b;
      wire [0:87]                dbg_group15b;
      wire [0:87]                dbg_group10;
      wire [0:87]                dbg_group11;
      wire [0:87]                dbg_group12;
      wire [0:87]                dbg_group13;
      wire [0:87]                dbg_group14;
      wire [0:87]                dbg_group15;

      parameter                  group12_offset = 68;
      parameter                  group13_offset = 112;

      wire [0:11]                trg_group0;
      wire [0:11]                trg_group1;
      wire [0:11]                trg_group2;
      wire [0:11]                trg_group3a;
      wire [0:11]                trg_group3b;
      wire [0:11]                trg_group3;

      wire [24:55]               dbg_group0a;

      wire                       tlb_ctl_dbg_tag1_valid;
      wire [0:1]                 tlb_ctl_dbg_tag1_thdid;
      wire [0:2]                 tlb_ctl_dbg_tag1_type;
      wire [0:1]                 tlb_ctl_dbg_tag1_wq;
      wire                       tlb_ctl_dbg_tag1_gs;
      wire                       tlb_ctl_dbg_tag1_pr;
      wire                       tlb_ctl_dbg_tag1_atsel;
      wire [0:1]                 tlb_cmp_dbg_tag4_thdid;	// encoded
      wire [0:2]                 tlb_cmp_dbg_tag4_type;		// encoded
      wire                       tlb_cmp_dbg_tag4_valid;
      wire [0:`TLB_WAYS]          tlb_cmp_dbg_tag5_wayhit;
      wire [0:1]                 tlb_cmp_dbg_tag5_thdid;	// encoded
      wire [0:2]                 tlb_cmp_dbg_tag5_type;		// encoded
      wire [0:1]                 tlb_cmp_dbg_tag5_class;		// what kind of derat is it?
      wire                       tlb_cmp_dbg_tag5_iorderat_rel_val;		// i or d
      wire                       tlb_cmp_dbg_tag5_iorderat_rel_hit;		// i or d
      wire [0:167]               tlb_cmp_dbg_tag5_way;
      wire [0:11]                tlb_cmp_dbg_tag5_lru_dataout;

      (* analysis_not_referenced="true" *)
      wire [0:11]                unused_dc;

      wire [0:DEBUG_LATCH_WIDTH-1]     unused_debug_latch_scan;
      wire [0:TRIGGER_LATCH_WIDTH-1]   unused_trigger_latch_scan;
      wire [0:`DEBUG_TRACE_WIDTH-1]       unused_busin_latch_scan;
      wire [0:`DEBUG_TRIGGER_WIDTH-1]     unused_trigin_latch_scan;
      wire [0:3]         unused_coretrace_ctrls_in_latch_scan;

      // Pervasive
      wire                       pc_func_slp_sl_thold_1;
      wire                       pc_func_slp_sl_thold_0;
      wire                       pc_func_slp_sl_thold_0_b;
      wire                       pc_func_slp_sl_force;
      wire                       pc_func_slp_nsl_thold_1;
      wire                       pc_func_slp_nsl_thold_0;
      wire                       pc_func_slp_nsl_thold_0_b;
      wire                       pc_func_slp_nsl_force;
      wire                       pc_sg_1;
      wire                       pc_sg_0;
      wire                       pc_fce_1;
      wire                       pc_fce_0;

      wire [0:scan_right]        siv;
      wire [0:scan_right]        sov;

      wire                       tidn;
      wire                       tiup;

      //---------------------------------------------------------------------
      // Logic
      //---------------------------------------------------------------------

      assign tidn = 1'b0;
      assign tiup = 1'b1;

      assign pc_mm_debug_mux1_ctrls_loc_d = pc_mm_debug_mux1_ctrls_q;		// local timing latches

      //---------------------------------------------------------------------
      // debug input signals from various logic entities
      //---------------------------------------------------------------------
      assign debug_d[12] = tlb_ctl_dbg_tag0_valid;
      assign debug_d[13:14] = tlb_ctl_dbg_tag0_thdid[0:1];
      assign debug_d[15:17] = tlb_ctl_dbg_tag0_type[0:2];
      assign debug_d[18:19] = tlb_ctl_dbg_tag0_wq[0:1];
      assign debug_d[20] = tlb_ctl_dbg_tag0_gs;
      assign debug_d[21] = tlb_ctl_dbg_tag0_pr;
      assign debug_d[22] = tlb_ctl_dbg_tag0_atsel;
      assign debug_d[23] = 1'b0;

      assign tlb_ctl_dbg_tag1_valid = debug_q[12];
      assign tlb_ctl_dbg_tag1_thdid[0:1] = debug_q[13:14];
      assign tlb_ctl_dbg_tag1_type[0:2] = debug_q[15:17];
      assign tlb_ctl_dbg_tag1_wq[0:1] = debug_q[18:19];
      assign tlb_ctl_dbg_tag1_gs = debug_q[20];
      assign tlb_ctl_dbg_tag1_pr = debug_q[21];
      assign tlb_ctl_dbg_tag1_atsel = debug_q[22];

      // tlb_low_data
      // [0:51] - EPN
      // [52:55] - SIZE (4b)
      // [56:59] - ThdID
      // [60:61] - Class
      // [62] - ExtClass
      // [63] - TID_NZ
      // [64:65] - reserved (2b)
      // [66:73] - 8b for LPID
      // [74:83] - parity 10bits
      assign debug_d[192:275] = tlb_cmp_dbg_tag4_way[0:83];
      assign tlb_cmp_dbg_tag5_way[0:83] = debug_q[192:275];

      // tlb_high_data
      // [84]      - [0]     - X-bit
      // [85:87]   - [1:3]   - reserved (3b)
      // [88:117]  - [4:33]  - RPN (30b)
      // [118:119] - [34:35] - R,C
      // [120:121] - [36:37] - WLC (2b)
      // [122]     - [38]    - ResvAttr
      // [123]     - [39]    - VF
      // [124]     - [40]    - IND
      // [125:128] - [41:44] - U0-U3
      // [129:133] - [45:49] - WIMGE
      // [134:135] - [50:51] - UX,SX
      // [136:137] - [52:53] - UW,SW
      // [138:139] - [54:55] - UR,SR
      // [140]     - [56] - GS
      // [141]     - [57] - TS
      // [142:143] - [58:59] - reserved (2b)
      // [144:149] - [60:65] - 6b TID msbs
      // [150:157] - [66:73] - 8b TID lsbs
      // [158:167] - [74:83] - parity 10bits
      assign debug_d[276:359] = tlb_cmp_dbg_tag4_way[84:167];
      assign tlb_cmp_dbg_tag5_way[84:167] = debug_q[276:359];

      // lru data format
      //  [0:3] - valid(0:3)
      //  [4:6] - LRU
      //  [7] - parity
      //  [8:11] - iprot(0:3)
      //  [12:14] - reserved
      //  [15] - parity
      assign debug_d[360:371] = tlb_cmp_dbg_tag4_lru_dataout_q[0:11];
      assign tlb_cmp_dbg_tag5_lru_dataout[0:11] = debug_q[360:371];

      assign trigger_d[0:11] = {12{1'b0}};
      assign trigger_d[12:23] = {12{1'b0}};
      assign trigger_d[24:35] = {12{1'b0}};
      assign trigger_d[36:47] = {12{1'b0}};

      //group0   (slowspr interface)
      assign dbg_group0[0] = spr_dbg_slowspr_val_int;		// spr_int phase
      assign dbg_group0[1] = spr_dbg_slowspr_rw_int;
      assign dbg_group0[2:3] = spr_dbg_slowspr_etid_int;
      assign dbg_group0[4:13] = spr_dbg_slowspr_addr_int;
      assign dbg_group0[14] = spr_dbg_slowspr_done_out;		// spr_out phase
      assign dbg_group0[15] = spr_dbg_match_any_mmu;		// spr_int phase
      assign dbg_group0[16] = spr_dbg_match_any_mas;
      assign dbg_group0[17] = spr_dbg_match_pid;
      assign dbg_group0[18] = spr_dbg_match_lpidr;
      assign dbg_group0[19] = spr_dbg_match_mas2;
      assign dbg_group0[20] = spr_dbg_match_mas01_64b;
      assign dbg_group0[21] = spr_dbg_match_mas56_64b;
      assign dbg_group0[22] = spr_dbg_match_mas73_64b;
      assign dbg_group0[23] = spr_dbg_match_mas81_64b;

      // alternate bit muxes when 64b decodes 19:23=00000
      assign dbg_group0a[24] = spr_dbg_match_mmucr0;
      assign dbg_group0a[25] = spr_dbg_match_mmucr1;
      assign dbg_group0a[26] = spr_dbg_match_mmucr2;
      assign dbg_group0a[27] = spr_dbg_match_mmucr3;
      assign dbg_group0a[28] = spr_dbg_match_mmucsr0;
      assign dbg_group0a[29] = spr_dbg_match_mmucfg;
      assign dbg_group0a[30] = spr_dbg_match_tlb0cfg;
      assign dbg_group0a[31] = spr_dbg_match_tlb0ps;
      assign dbg_group0a[32] = spr_dbg_match_lratcfg;
      assign dbg_group0a[33] = spr_dbg_match_lratps;
      assign dbg_group0a[34] = spr_dbg_match_eptcfg;
      assign dbg_group0a[35] = spr_dbg_match_lper;
      assign dbg_group0a[36] = spr_dbg_match_lperu;
      assign dbg_group0a[37] = spr_dbg_match_mas0;
      assign dbg_group0a[38] = spr_dbg_match_mas1;
      assign dbg_group0a[39] = spr_dbg_match_mas2u;
      assign dbg_group0a[40] = spr_dbg_match_mas3;
      assign dbg_group0a[41] = spr_dbg_match_mas4;
      assign dbg_group0a[42] = spr_dbg_match_mas5;
      assign dbg_group0a[43] = spr_dbg_match_mas6;
      assign dbg_group0a[44] = spr_dbg_match_mas7;
      assign dbg_group0a[45] = spr_dbg_match_mas8;
      assign dbg_group0a[46] = tlb_mas_tlbre;
      assign dbg_group0a[47] = tlb_mas_tlbsx_hit;
      assign dbg_group0a[48] = tlb_mas_tlbsx_miss;
      assign dbg_group0a[49] = tlb_mas_dtlb_error;
      assign dbg_group0a[50] = tlb_mas_itlb_error;
      assign dbg_group0a[51] = tlb_mas_thdid[2] | tlb_mas_thdid[3];		// encoded
      assign dbg_group0a[52] = tlb_mas_thdid[1] | tlb_mas_thdid[3];		// encoded
      assign dbg_group0a[53] = lrat_mas_tlbre;
      assign dbg_group0a[54] = lrat_mas_thdid[2] | lrat_mas_thdid[3];		// encoded
      assign dbg_group0a[55] = lrat_mas_thdid[1] | lrat_mas_thdid[3];		// encoded
      // alternate bit muxes when 64b decodes 19:23/=00000
      assign dbg_group0[24:55] = ({55-24+1{spr_dbg_match_64b}} & spr_dbg_slowspr_data_out[0:31]) |
                                   ({55-24+1{(~(spr_dbg_match_64b))}} & dbg_group0a[24:55]);
      assign dbg_group0[56:87] = spr_dbg_slowspr_data_out[32:63];

      // snoop_attr:
      //          0 -> Local
      //        1:3 -> IS/Class: 0=all, 1=tid, 2=gs, 3=epn, 4=class0, 5=class1, 6=class2, 7=class3
      //        4:5 -> GS/TS
      //       6:13 -> TID(6:13)
      //      14:17 -> Size
      //      18    -> reserved for tlb, extclass_enable(0) for erats
      //      19    -> mmucsr0.tlb0fi for tlb, or TID_NZ for erats
      //      20:25 -> TID(0:5)
      //      26:33 -> LPID
      //      34    -> IND

      //group1   (invalidate, local generation)
      assign dbg_group1[0:4] = inval_dbg_seq_q[0:4];
      assign dbg_group1[5] = inval_dbg_ex6_valid;
      assign dbg_group1[6:7] = inval_dbg_ex6_thdid[0:1];		// encoded
      assign dbg_group1[8:9] = inval_dbg_ex6_ttype[1:2];		// encoded
      assign dbg_group1[10] = htw_lsu_req_valid;
      assign dbg_group1[11] = mmucsr0_tlb0fi;
      assign dbg_group1[12] = tlbwe_back_inv_valid;
      assign dbg_group1[13] = inval_dbg_snoop_forme;
      assign dbg_group1[14] = inval_dbg_an_ac_back_inv_q[4];		// L bit
      assign dbg_group1[15] = inval_dbg_an_ac_back_inv_q[7];		// local bit
      assign dbg_group1[16:50] = inval_dbg_snoop_attr_q[0:34];
      assign dbg_group1[51:52] = inval_dbg_snoop_attr_tlb_spec_q[18:19];
      assign dbg_group1[53:87] = inval_dbg_snoop_vpn_q[17:51];

      //group2   (invalidate, bus snoops)
      assign dbg_group2[0:4] = inval_dbg_seq_q[0:4];
      assign dbg_group2[5] = inval_dbg_snoop_forme;
      assign dbg_group2[6] = inval_dbg_snoop_local_reject;
      assign dbg_group2[7:13] = inval_dbg_an_ac_back_inv_q[2:8];		// 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
      assign dbg_group2[14:21] = inval_dbg_an_ac_back_inv_lpar_id_q[0:7];
      assign dbg_group2[22:63] = inval_dbg_an_ac_back_inv_addr_q[22:63];
      assign dbg_group2[64:66] = inval_dbg_snoop_valid_q[0:2];
      assign dbg_group2[67:87] = {inval_dbg_snoop_attr_q[0:19], inval_dbg_snoop_attr_q[34]};

      //group3   (lsu interface)
      assign dbg_group3[0:4] = inval_dbg_seq_q[0:4];
      assign dbg_group3[5] = inval_dbg_ex6_valid;
      assign dbg_group3[6:7] = inval_dbg_ex6_thdid[0:1];		// encoded
      assign dbg_group3[8:9] = inval_dbg_ex6_ttype[1:2];		// encoded
      assign dbg_group3[10] = inval_dbg_snoop_forme;
      assign dbg_group3[11] = inval_dbg_an_ac_back_inv_q[7];		// 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
      assign dbg_group3[12] = xu_mm_lmq_stq_empty;
      assign dbg_group3[13] = iu_mm_lmq_empty;
      assign dbg_group3[14:15] = htw_dbg_seq_q[0:1];
      assign dbg_group3[16] = htw_lsu_req_valid;
      assign dbg_group3[17:18] = htw_dbg_lsu_thdid[0:1];
      assign dbg_group3[19:20] = htw_lsu_ttype[0:1];
      assign dbg_group3[21] = xu_mm_lsu_token;
      assign dbg_group3[22] = inval_dbg_lsu_tokens_q[1];
      assign dbg_group3[23] = |(mm_xu_lsu_req);
      assign dbg_group3[24:25] = mm_xu_lsu_ttype;		// 0=tlbivax_op L=0, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
      assign dbg_group3[26:30] = mm_xu_lsu_wimge;
      assign dbg_group3[31] = mm_xu_lsu_ind;		// tlbivax sec enc data
      assign dbg_group3[32] = mm_xu_lsu_gs;		// tlbivax sec enc data
      assign dbg_group3[33] = mm_xu_lsu_lbit;		// tlbivax sec enc data, "L" bit, for large vs. small
      assign dbg_group3[34:37] = mm_xu_lsu_u;
      assign dbg_group3[38:45] = mm_xu_lsu_lpid;		// tlbivax lpar id data
      assign dbg_group3[46:87] = mm_xu_lsu_addr[22:63];

      //  `tagpos_epn      : natural  := 0;
      //  `tagpos_pid      : natural  := 52; -- 14 bits
      //  `tagpos_is       : natural  := 66;
      //  `tagpos_class    : natural  := 68;
      //  `tagpos_state    : natural  := 70; -- state: 0:pr 1:gs 2:as 3:cm
      //  `tagpos_thdid    : natural  := 74;
      //  `tagpos_size     : natural  := 78;
      //  `tagpos_type     : natural  := 82; -- derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
      //  `tagpos_lpid     : natural  := 90;
      //  `tagpos_ind      : natural  := 98;
      //  `tagpos_atsel    : natural  := 99;
      //  `tagpos_esel     : natural  := 100;
      //  `tagpos_hes      : natural  := 103;
      //  `tagpos_wq       : natural  := 104;
      //  `tagpos_lrat     : natural  := 106;
      //  `tagpos_pt       : natural  := 107;
      //  `tagpos_recform  : natural  := 108;
      //  `tagpos_endflag  : natural  := 109;

      assign tlb_cmp_dbg_tag5_iorderat_rel_val = |(tlb_cmp_dbg_tag5_erat_rel_val[0:3] | tlb_cmp_dbg_tag5_erat_rel_val[5:8]);	// i or d
      assign tlb_cmp_dbg_tag5_iorderat_rel_hit = tlb_cmp_dbg_tag5_erat_rel_val[4] | tlb_cmp_dbg_tag5_erat_rel_val[9];		// i or d

      //group4   (sequencers, the big picture)
      assign dbg_group4[0:5] = tlb_ctl_dbg_seq_q[0:5];		// tlb_seq_q
      assign dbg_group4[6:7] = tlb_ctl_dbg_tag0_thdid[0:1];		// encoded
      assign dbg_group4[8:10] = tlb_ctl_dbg_tag0_type[0:2];		// encoded
      assign dbg_group4[11] = tlb_ctl_dbg_any_tag_flush_sig;
      assign dbg_group4[12:15] = tlb_cmp_dbg_tag4_wayhit[0:3];
      //assign dbg_group4(16 to 19) = mm_xu_eratmiss_done[0:3];
      //assign dbg_group4[20 to 23) = mm_iu_barrier_done[0:3];
      //assign dbg_group4[24 to 27) = mm_xu_ex3_flush_req[0:3];
      assign dbg_group4[28] = tlb_cmp_dbg_tag5_iorderat_rel_val;		// i or d
      assign dbg_group4[29] = tlb_cmp_dbg_tag5_iorderat_rel_hit;		// i or d
      assign dbg_group4[30:31] = htw_dbg_seq_q[0:1];
      assign dbg_group4[32:34] = htw_dbg_pte0_seq_q[0:2];
      assign dbg_group4[35:37] = htw_dbg_pte1_seq_q[0:2];
      assign dbg_group4[38:42] = inval_dbg_seq_q[0:4];
      assign dbg_group4[43] = mmucsr0_tlb0fi;
      assign dbg_group4[44] = inval_dbg_ex6_valid;
      assign dbg_group4[45:46] = inval_dbg_ex6_thdid[0:1];		// encoded
      assign dbg_group4[47:49] = inval_dbg_ex6_ttype[0:2];		// encoded  tlbilx & tlbivax & eratilx & erativax, csync, isync
      assign dbg_group4[50] = inval_dbg_snoop_forme;
      assign dbg_group4[51:57] = inval_dbg_an_ac_back_inv_q[2:8];		// 2=valid b, 3=target b, 4=L, 5=GS, 6=IND, 7=local, 8=reject
      assign dbg_group4[58] = xu_mm_lmq_stq_empty;
      assign dbg_group4[59] = iu_mm_lmq_empty;

      generate
         begin : xhdl0
            genvar                     tid;
            for (tid = 0; tid <= 3; tid = tid + 1)
            begin : Grp4Threads
               if (tid < `THREADS)
               begin : Grp4Exist
                  assign dbg_group4[16 + tid] = mm_xu_eratmiss_done[tid];
                  assign dbg_group4[20 + tid] = mm_iu_barrier_done[tid];
                  assign dbg_group4[24 + tid] = mm_xu_ex3_flush_req[tid];
                  assign dbg_group4[60 + tid] = mm_xu_hold_req[tid];
                  assign dbg_group4[64 + tid] = xu_mm_hold_ack[tid];
                  assign dbg_group4[68 + tid] = mm_xu_hold_done[tid];
               end
            if (tid >= `THREADS)
            begin : Grp4NExist
               assign dbg_group4[16 + tid] = tidn;
               assign dbg_group4[20 + tid] = tidn;
               assign dbg_group4[24 + tid] = tidn;
               assign dbg_group4[60 + tid] = tidn;
               assign dbg_group4[64 + tid] = tidn;
               assign dbg_group4[68 + tid] = tidn;
            end
      end
   end
   endgenerate

   assign dbg_group4[72:74] = inval_dbg_snoop_valid_q[0:2];
   assign dbg_group4[75:77] = inval_dbg_snoop_ack_q[0:2];
   assign dbg_group4[78] = |(mm_xu_lsu_req);
   assign dbg_group4[79:80] = mm_xu_lsu_ttype;		// 0=tlbivax_op L=0, 1=tlbi_complete, 2=mmu read with core_tag=01100, 3=mmu read with core_tag=01101
   assign dbg_group4[81] = |(mm_xu_illeg_instr);
   assign dbg_group4[82:85] = tlb_cmp_dbg_tag5_except_type_q[0:3];		// tag5 except valid/type, (hv_priv | lrat_miss | pt_fault | pt_inelig)
   assign dbg_group4[86:87] = tlb_cmp_dbg_tag5_except_thdid_q[0:1];		// tag5 encoded thdid

   //group5 (tlb_req)
   assign dbg_group5[0] = tlb_req_dbg_ierat_iu5_valid_q;
   assign dbg_group5[1:2] = tlb_req_dbg_ierat_iu5_thdid[0:1];		// encoded
   assign dbg_group5[3:6] = tlb_req_dbg_ierat_iu5_state_q[0:3];
   assign dbg_group5[7] = tlb_seq_ierat_req;
   assign dbg_group5[8:9] = tlb_req_dbg_ierat_inptr_q[0:1];
   assign dbg_group5[10:11] = tlb_req_dbg_ierat_outptr_q[0:1];
   assign dbg_group5[12:15] = tlb_req_dbg_ierat_req_valid_q[0:3];
   assign dbg_group5[16:19] = tlb_req_dbg_ierat_req_nonspec_q[0:3];
   assign dbg_group5[20:27] = tlb_req_dbg_ierat_req_thdid[0:7];		// encoded
   assign dbg_group5[28:31] = tlb_req_dbg_ierat_req_dup_q[0:3];
   assign dbg_group5[32] = tlb_req_dbg_derat_ex6_valid_q;
   assign dbg_group5[33:34] = tlb_req_dbg_derat_ex6_thdid[0:1];		// encoded
   assign dbg_group5[35:38] = tlb_req_dbg_derat_ex6_state_q[0:3];
   assign dbg_group5[39] = tlb_seq_derat_req;
   assign dbg_group5[40:41] = tlb_req_dbg_derat_inptr_q[0:1];
   assign dbg_group5[42:43] = tlb_req_dbg_derat_outptr_q[0:1];
   assign dbg_group5[44:47] = tlb_req_dbg_derat_req_valid_q[0:3];
   assign dbg_group5[48:55] = tlb_req_dbg_derat_req_thdid[0:7];		// encoded
   assign dbg_group5[56:63] = tlb_req_dbg_derat_req_ttype_q[0:7];
   assign dbg_group5[64:67] = tlb_req_dbg_derat_req_dup_q[0:3];
   assign dbg_group5[68:87] = tlb_cmp_dbg_erat_dup_q[0:19];

   // unused tag bits for certain ops are re-purposed as below:
   //  unused `tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
   //  unused `tagpos_pt, `tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
   //  unused `tagpos_atsel | `tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
   //  unused `tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
   //  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
   //  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
   //  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries

   // some encoding of debug sigs
   // ttype:  derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload
   assign tlb_cmp_dbg_tag4_valid = |(tlb_cmp_dbg_tag4[`tagpos_thdid:`tagpos_thdid + 3]);

   assign tlb_cmp_dbg_tag4_thdid[0] = (tlb_cmp_dbg_tag4[`tagpos_thdid + 2] | tlb_cmp_dbg_tag4[`tagpos_thdid + 3]);		// encoded
   assign tlb_cmp_dbg_tag4_thdid[1] = (tlb_cmp_dbg_tag4[`tagpos_thdid + 1] | tlb_cmp_dbg_tag4[`tagpos_thdid + 3]);		// encoded

   assign tlb_cmp_dbg_tag4_type[0] = (tlb_cmp_dbg_tag4[`tagpos_type_snoop] | tlb_cmp_dbg_tag4[`tagpos_type_tlbre] | tlb_cmp_dbg_tag4[`tagpos_type_tlbwe] | tlb_cmp_dbg_tag4[`tagpos_type_ptereload]);		// encoded
   assign tlb_cmp_dbg_tag4_type[1] = (tlb_cmp_dbg_tag4[`tagpos_type_tlbsx] | tlb_cmp_dbg_tag4[`tagpos_type_tlbsrx] | tlb_cmp_dbg_tag4[`tagpos_type_tlbwe] | tlb_cmp_dbg_tag4[`tagpos_type_ptereload]);		// encoded
   assign tlb_cmp_dbg_tag4_type[2] = (tlb_cmp_dbg_tag4[`tagpos_type_ierat] | tlb_cmp_dbg_tag4[`tagpos_type_tlbsrx] | tlb_cmp_dbg_tag4[`tagpos_type_tlbre] | tlb_cmp_dbg_tag4[`tagpos_type_ptereload]);		// encoded

   //group6   (general erat and search compare values, truncated epn)
   assign dbg_group6[0] = tlb_cmp_dbg_tag4_valid;		// or_reduce of thdid;
   assign dbg_group6[1:2] = tlb_cmp_dbg_tag4_thdid[0:1];		// encoded
   assign dbg_group6[3:5] = tlb_cmp_dbg_tag4_type[0:2];		// encoded
   assign dbg_group6[6:7] = tlb_cmp_dbg_tag4[`tagpos_class:`tagpos_class + 1];
   assign dbg_group6[8:9] = tlb_cmp_dbg_tag4[`tagpos_is:`tagpos_is + 1];
   assign dbg_group6[10:12] = tlb_cmp_dbg_tag4[`tagpos_esel:`tagpos_esel + 2];
   assign dbg_group6[13] = tlb_cmp_dbg_tag4[`tagpos_cm];
   assign dbg_group6[14] = tlb_cmp_dbg_tag4[`tagpos_pr];
   assign dbg_group6[15] = tlb_cmp_dbg_tag4[`tagpos_ind];
   assign dbg_group6[16] = tlb_cmp_dbg_tag4[`tagpos_endflag];
   assign dbg_group6[17:23] = tlb_cmp_dbg_addr4[0:6];
   assign dbg_group6[24:27] = tlb_cmp_dbg_tag4_wayhit[0:`TLB_WAYS - 1];
   assign dbg_group6[28] = tlb_cmp_dbg_tag4[`tagpos_gs];
   assign dbg_group6[29:36] = tlb_cmp_dbg_tag4[`tagpos_lpid:`tagpos_lpid + 7];
   assign dbg_group6[37] = tlb_cmp_dbg_tag4[`tagpos_as];
   assign dbg_group6[38:51] = tlb_cmp_dbg_tag4[`tagpos_pid:`tagpos_pid + 13];
   assign dbg_group6[52:87] = tlb_cmp_dbg_tag4[`tagpos_epn + 16:`tagpos_epn + 51];

   //  match <=          addr_match and                       --  Address compare
   //                    pgsize_match and                     --  Size compare
   //                    class_match and                      --  Class compare
   //                    extclass_match and                   --  ExtClass compare
   //                    state_match and                      --  State compare
   //                    thdid_match and                      --  ThdID compare
   //                    pid_match and                        --  PID compare
   //                    lpid_match and                       --  LPID compare
   //                    ind_match and                        --  indirect compare
   //                    iprot_match and                      --  inval prot compare
   //                    entry_v;                             --  Valid

   //group7 (detailed compare/match)
   assign dbg_group7[0] = tlb_cmp_dbg_tag4_valid;
   assign dbg_group7[1:2] = tlb_cmp_dbg_tag4_thdid[0:1];
   assign dbg_group7[3:5] = tlb_cmp_dbg_tag4_type[0:2];
   assign dbg_group7[6:7] = tlb_cmp_dbg_tag4[`tagpos_is:`tagpos_is + 1];
   assign dbg_group7[8:9] = tlb_cmp_dbg_tag4[`tagpos_class:`tagpos_class + 1];
   assign dbg_group7[10:12] = tlb_cmp_dbg_tag4[`tagpos_esel:`tagpos_esel + 2];
   assign dbg_group7[13:19] = tlb_cmp_dbg_addr4[0:6];
   assign dbg_group7[20:23] = tlb_cmp_dbg_tag4_wayhit[0:3];

   assign debug_d[24:32] = tlb_cmp_dbg_addr_enable[0:8];		// these are tag3 versions coming in
   assign debug_d[33] = tlb_cmp_dbg_pgsize_enable;
   assign debug_d[34] = tlb_cmp_dbg_class_enable;
   assign debug_d[35:36] = tlb_cmp_dbg_extclass_enable[0:1];
   assign debug_d[37:38] = tlb_cmp_dbg_state_enable[0:1];
   assign debug_d[39] = tlb_cmp_dbg_thdid_enable;
   assign debug_d[40] = tlb_cmp_dbg_pid_enable;
   assign debug_d[41] = tlb_cmp_dbg_lpid_enable;
   assign debug_d[42] = tlb_cmp_dbg_ind_enable;
   assign debug_d[43] = tlb_cmp_dbg_iprot_enable;
   assign debug_d[44] = tlb_cmp_dbg_way0_entry_v;
   assign debug_d[45] = tlb_cmp_dbg_way0_addr_match;
   assign debug_d[46] = tlb_cmp_dbg_way0_pgsize_match;
   assign debug_d[47] = tlb_cmp_dbg_way0_class_match;
   assign debug_d[48] = tlb_cmp_dbg_way0_extclass_match;
   assign debug_d[49] = tlb_cmp_dbg_way0_state_match;
   assign debug_d[50] = tlb_cmp_dbg_way0_thdid_match;
   assign debug_d[51] = tlb_cmp_dbg_way0_pid_match;
   assign debug_d[52] = tlb_cmp_dbg_way0_lpid_match;
   assign debug_d[53] = tlb_cmp_dbg_way0_ind_match;
   assign debug_d[54] = tlb_cmp_dbg_way0_iprot_match;
   assign debug_d[55] = tlb_cmp_dbg_way1_entry_v;
   assign debug_d[56] = tlb_cmp_dbg_way1_addr_match;
   assign debug_d[57] = tlb_cmp_dbg_way1_pgsize_match;
   assign debug_d[58] = tlb_cmp_dbg_way1_class_match;
   assign debug_d[59] = tlb_cmp_dbg_way1_extclass_match;
   assign debug_d[60] = tlb_cmp_dbg_way1_state_match;
   assign debug_d[61] = tlb_cmp_dbg_way1_thdid_match;
   assign debug_d[62] = tlb_cmp_dbg_way1_pid_match;
   assign debug_d[63] = tlb_cmp_dbg_way1_lpid_match;
   assign debug_d[64] = tlb_cmp_dbg_way1_ind_match;
   assign debug_d[65] = tlb_cmp_dbg_way1_iprot_match;
   assign debug_d[66] = tlb_cmp_dbg_way2_entry_v;
   assign debug_d[67] = tlb_cmp_dbg_way2_addr_match;
   assign debug_d[68] = tlb_cmp_dbg_way2_pgsize_match;
   assign debug_d[69] = tlb_cmp_dbg_way2_class_match;
   assign debug_d[70] = tlb_cmp_dbg_way2_extclass_match;
   assign debug_d[71] = tlb_cmp_dbg_way2_state_match;
   assign debug_d[72] = tlb_cmp_dbg_way2_thdid_match;
   assign debug_d[73] = tlb_cmp_dbg_way2_pid_match;
   assign debug_d[74] = tlb_cmp_dbg_way2_lpid_match;
   assign debug_d[75] = tlb_cmp_dbg_way2_ind_match;
   assign debug_d[76] = tlb_cmp_dbg_way2_iprot_match;
   assign debug_d[77] = tlb_cmp_dbg_way3_entry_v;
   assign debug_d[78] = tlb_cmp_dbg_way3_addr_match;
   assign debug_d[79] = tlb_cmp_dbg_way3_pgsize_match;
   assign debug_d[80] = tlb_cmp_dbg_way3_class_match;
   assign debug_d[81] = tlb_cmp_dbg_way3_extclass_match;
   assign debug_d[82] = tlb_cmp_dbg_way3_state_match;
   assign debug_d[83] = tlb_cmp_dbg_way3_thdid_match;
   assign debug_d[84] = tlb_cmp_dbg_way3_pid_match;
   assign debug_d[85] = tlb_cmp_dbg_way3_lpid_match;
   assign debug_d[86] = tlb_cmp_dbg_way3_ind_match;
   assign debug_d[87] = tlb_cmp_dbg_way3_iprot_match;

   assign dbg_group7[24:87] = debug_q[24:87];		// tag4 phase, see below

   // unused tag bits for certain ops are re-purposed as below:
   //  unused `tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
   //  unused `tagpos_pt, `tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
   //  unused `tagpos_atsel | `tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
   //  unused `tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
   //  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
   //  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
   //  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries
   //  unused class is derat ttype for derat miss, 0=load,1=store,2=epid load,3=epid store

   //group8   (erat miss, tlbre, tlbsx mas updates and parerr)
   assign dbg_group8[0] = tlb_cmp_dbg_tag4_valid;
   assign dbg_group8[1:2] = tlb_cmp_dbg_tag4_thdid[0:1];
   assign dbg_group8[3:5] = tlb_cmp_dbg_tag4_type[0:2];
   assign dbg_group8[6:7] = tlb_cmp_dbg_tag4[`tagpos_class:`tagpos_class + 1];
   assign dbg_group8[8] = tlb_cmp_dbg_tag4[`tagpos_cm];
   assign dbg_group8[9] = tlb_cmp_dbg_tag4[`tagpos_gs];
   assign dbg_group8[10] = tlb_cmp_dbg_tag4[`tagpos_pr];
   assign dbg_group8[11] = tlb_cmp_dbg_tag4[`tagpos_endflag];
   assign dbg_group8[12] = tlb_cmp_dbg_tag4[`tagpos_atsel];
   assign dbg_group8[13:15] = tlb_cmp_dbg_tag4[`tagpos_esel:`tagpos_esel + 2];
   assign dbg_group8[16:19] = tlb_cmp_dbg_tag4[`tagpos_size:`tagpos_size + 3];
   assign dbg_group8[20:33] = tlb_cmp_dbg_tag4[`tagpos_pid:`tagpos_pid + 13];
   assign dbg_group8[34:58] = tlb_cmp_dbg_tag4[`tagpos_epn + 27:`tagpos_epn + 51];
   assign dbg_group8[59:65] = tlb_cmp_dbg_addr4[0:6];
   assign dbg_group8[66:69] = tlb_cmp_dbg_tag4_wayhit[0:`TLB_WAYS - 1];
   assign dbg_group8[70] = tlb_mas_dtlb_error;
   assign dbg_group8[71] = tlb_mas_itlb_error;
   assign dbg_group8[72] = tlb_mas_tlbsx_hit;
   assign dbg_group8[73] = tlb_mas_tlbsx_miss;
   assign dbg_group8[74] = tlb_mas_tlbre;
   assign dbg_group8[75] = lrat_mas_tlbre;
   assign dbg_group8[76] = lrat_mas_tlbsx_hit;
   assign dbg_group8[77] = lrat_mas_tlbsx_miss;
   assign dbg_group8[78:80] = lrat_tag4_hit_entry[0:2];
   assign dbg_group8[81:85] = tlb_cmp_dbg_tag4_parerr[0:4];		// way0 to 3, lru
   assign dbg_group8[86] = |(mm_xu_cr0_eq_valid);
   assign dbg_group8[87] = |(mm_xu_cr0_eq & mm_xu_cr0_eq_valid);

   //group9   (tlbwe, ptereload write control)
   assign dbg_group9[0] = tlb_cmp_dbg_tag4_valid;
   assign dbg_group9[1:2] = tlb_cmp_dbg_tag4_thdid[0:1];
   assign dbg_group9[3:5] = tlb_cmp_dbg_tag4_type[0:2];
   assign dbg_group9[6] = tlb_cmp_dbg_tag4[`tagpos_gs];
   assign dbg_group9[7] = tlb_cmp_dbg_tag4[`tagpos_pr];
   assign dbg_group9[8] = tlb_cmp_dbg_tag4[`tagpos_cm];
   assign dbg_group9[9] = tlb_cmp_dbg_tag4[`tagpos_hes];
   assign dbg_group9[10:11] = tlb_cmp_dbg_tag4[`tagpos_wq:`tagpos_wq + 1];
   assign dbg_group9[12] = tlb_cmp_dbg_tag4[`tagpos_atsel];
   assign dbg_group9[13:15] = tlb_cmp_dbg_tag4[`tagpos_esel:`tagpos_esel + 2];
   assign dbg_group9[16:17] = tlb_cmp_dbg_tag4[`tagpos_is:`tagpos_is + 1];
   assign dbg_group9[18] = tlb_cmp_dbg_tag4[`tagpos_pt];
   assign dbg_group9[19] = tlb_cmp_dbg_tag4[`tagpos_recform];
   assign dbg_group9[20] = tlb_cmp_dbg_tag4[`tagpos_ind];
   assign dbg_group9[21:27] = tlb_cmp_dbg_addr4[0:6];
   assign dbg_group9[28:31] = tlb_cmp_dbg_tag4_wayhit[0:`TLB_WAYS - 1];
   assign dbg_group9[32:43] = tlb_cmp_dbg_tag4_lru_dataout_q[0:11];		// current valid. lru, iprot
   assign dbg_group9[44:47] = lrat_tag4_hit_status[0:3];
   assign dbg_group9[48:50] = lrat_tag4_hit_entry[0:2];
   assign dbg_group9[51] = |(mm_iu_barrier_done);
   assign dbg_group9[52:55] = tlb_ctl_dbg_resv_valid[0:3];
   assign dbg_group9[56:59] = tlb_ctl_dbg_resv_match_vec_q[0:3];		// tag4
   assign dbg_group9[60:63] = tlb_ctl_dbg_tag5_tlb_write_q[0:3];		// tag5
   assign dbg_group9[64:75] = tlb_cmp_dbg_tag5_lru_datain_q[0:11];		// tag5
   assign dbg_group9[76] = tlb_cmp_dbg_tag5_lru_write;		// all bits the same
   assign dbg_group9[77] = |(mm_xu_illeg_instr);
   assign dbg_group9[78:81] = tlb_cmp_dbg_tag5_except_type_q[0:3];		// tag5 except valid/type, (hv_priv | lrat_miss | pt_fault | pt_inelig)
   assign dbg_group9[82:83] = tlb_cmp_dbg_tag5_except_thdid_q[0:1];		// tag5 encoded thdid
   assign dbg_group9[84] = tlbwe_back_inv_valid;		// valid
   assign dbg_group9[85] = tlbwe_back_inv_attr[18];		// not extclass enable
   assign dbg_group9[86] = tlbwe_back_inv_attr[19];		// tid_nz
   assign dbg_group9[87] = 1'b0;

   // constant `eratpos_epn      : natural  := 0;
   // constant `eratpos_x        : natural  := 52;
   // constant `eratpos_size     : natural  := 53;
   // constant `eratpos_v        : natural  := 56;
   // constant `eratpos_thdid    : natural  := 57;
   // constant `eratpos_class    : natural  := 61;
   // constant `eratpos_extclass : natural  := 63;
   // constant `eratpos_wren     : natural  := 65;
   // constant `eratpos_rpnrsvd  : natural  := 66;
   // constant `eratpos_rpn      : natural  := 70;
   // constant `eratpos_r        : natural  := 100;
   // constant `eratpos_c        : natural  := 101;
   // constant `eratpos_rsv      : natural  := 102;
   // constant `eratpos_wlc      : natural  := 103;
   // constant `eratpos_resvattr : natural  := 105;
   // constant `eratpos_vf       : natural  := 106;
   // constant `eratpos_ubits    : natural  := 107;
   // constant `eratpos_wimge    : natural  := 111;
   // constant `eratpos_usxwr    : natural  := 116;
   // constant `eratpos_gs       : natural  := 122;
   // constant `eratpos_ts       : natural  := 123;
   // constant `eratpos_tid      : natural  := 124;  -- 8 bits

   assign debug_d[0:1] = tlb_cmp_dbg_tag4_thdid;		// tag5 thdid encoded
   assign debug_d[2:4] = tlb_cmp_dbg_tag4_type;		// tag5 type encoded
   assign debug_d[5:6] = tlb_cmp_dbg_tag4[`tagpos_class:`tagpos_class + 1];		// what kind of derat is it?
   assign debug_d[7:11] = tlb_cmp_dbg_tag4_wayhit[0:`TLB_WAYS];

   assign tlb_cmp_dbg_tag5_thdid[0:1] = debug_q[0:1];
   assign tlb_cmp_dbg_tag5_type[0:2] = debug_q[2:4];
   assign tlb_cmp_dbg_tag5_class[0:1] = debug_q[5:6];
   assign tlb_cmp_dbg_tag5_wayhit[0:4] = debug_q[7:11];

   //group10   (erat reload bus, epn) --------> can mux tlb_datain(0:83) epn for tlbwe/ptereload ops
   assign dbg_group10a[0] = tlb_cmp_dbg_tag5_iorderat_rel_val;
   assign dbg_group10a[1:2] = tlb_cmp_dbg_tag5_thdid[0:1];
   assign dbg_group10a[3:5] = tlb_cmp_dbg_tag5_type[0:2];
   assign dbg_group10a[6:7] = tlb_cmp_dbg_tag5_class[0:1];		// what kind of derat is it?
   assign dbg_group10a[8:11] = tlb_cmp_dbg_tag5_wayhit[0:`TLB_WAYS - 1];
   assign dbg_group10a[12:21] = tlb_cmp_dbg_tag5_erat_rel_val[0:9];
   assign dbg_group10a[22:87] = tlb_cmp_dbg_tag5_erat_rel_data[`eratpos_epn:`eratpos_wren];

   // tlb_low_data
   // [0:51] - EPN
   // [52:55] - SIZE (4b)
   // [56:59] - ThdID
   // [60:61] - Class
   // [62] - ExtClass
   // [63] - TID_NZ
   // [64:65] - reserved (2b)
   // [66:73] - 8b for LPID
   // [74:83] - parity 10bits
   assign dbg_group10b[0:83] = tlb_cmp_dbg_tag5_tlb_datain_q[0:83];		// tlb_datain epn
   assign dbg_group10b[84] = (tlb_cmp_dbg_tag5_type[0:2] == 3'b110) & |(tlb_ctl_dbg_tag5_tlb_write_q);		// tlbwe
   assign dbg_group10b[85] = (tlb_cmp_dbg_tag5_type[0:2] == 3'b111) & |(tlb_ctl_dbg_tag5_tlb_write_q);		// ptereload
   assign dbg_group10b[86] = (tlb_ctl_dbg_tag5_tlb_write_q[2] | tlb_ctl_dbg_tag5_tlb_write_q[3]);
   assign dbg_group10b[87] = (tlb_ctl_dbg_tag5_tlb_write_q[1] | tlb_ctl_dbg_tag5_tlb_write_q[3]);

   assign dbg_group10 = (mmucr2[8] == 1'b1) ? dbg_group10b :
                        dbg_group10a;

   //group11   (erat reload bus, rpn) --------> can mux tlb_datain(84:167) rpn for tlbwe/ptereload ops
   assign dbg_group11a[0] = tlb_cmp_dbg_tag5_iorderat_rel_val;
   assign dbg_group11a[1:2] = tlb_cmp_dbg_tag5_thdid[0:1];
   assign dbg_group11a[3:5] = tlb_cmp_dbg_tag5_type[0:2];
   assign dbg_group11a[6:7] = tlb_cmp_dbg_tag5_class[0:1];		// what kind of derat is it?
   assign dbg_group11a[8:11] = tlb_cmp_dbg_tag5_wayhit[0:`TLB_WAYS - 1];
   assign dbg_group11a[12:21] = tlb_cmp_dbg_tag5_erat_rel_val[0:9];
   assign dbg_group11a[22:87] = tlb_cmp_dbg_tag5_erat_rel_data[`eratpos_rpnrsvd:`eratpos_tid + 7];

   // tlb_high_data
   // [84]      - [0]     - X-bit
   // [85:87]   - [1:3]   - reserved (3b)
   // [88:117]  - [4:33]  - RPN (30b)
   // [118:119] - [34:35] - R,C
   // [120:121] - [36:37] - WLC (2b)
   // [122]     - [38]    - ResvAttr
   // [123]     - [39]    - VF
   // [124]     - [40]    - IND
   // [125:128] - [41:44] - U0-U3
   // [129:133] - [45:49] - WIMGE
   // [134:135] - [50:51] - UX,SX
   // [136:137] - [52:53] - UW,SW
   // [138:139] - [54:55] - UR,SR
   // [140]     - [56] - GS
   // [141]     - [57] - TS
   // [142:143] - [58:59] - reserved (2b)
   // [144:149] - [60:65] - 6b TID msbs
   // [150:157] - [66:73] - 8b TID lsbs
   // [158:167] - [74:83] - parity 10bits
   assign dbg_group11b[0:83] = tlb_cmp_dbg_tag5_tlb_datain_q[84:167];		// tlb_datain rpn
   assign dbg_group11b[84] = (tlb_cmp_dbg_tag5_type[0:2] == 3'b110) & |(tlb_ctl_dbg_tag5_tlb_write_q);		// tlbwe
   assign dbg_group11b[85] = (tlb_cmp_dbg_tag5_type[0:2] == 3'b111) & |(tlb_ctl_dbg_tag5_tlb_write_q);		// ptereload
   assign dbg_group11b[86] = (tlb_ctl_dbg_tag5_tlb_write_q[2] | tlb_ctl_dbg_tag5_tlb_write_q[3]);
   assign dbg_group11b[87] = (tlb_ctl_dbg_tag5_tlb_write_q[1] | tlb_ctl_dbg_tag5_tlb_write_q[3]);

   assign dbg_group11 = (mmucr2[8] == 1'b1) ? dbg_group11b :
                        dbg_group11a;

   //group12   (reservations)
   assign dbg_group12a[0] = tlb_ctl_dbg_tag1_valid;
   assign dbg_group12a[1:2] = tlb_ctl_dbg_tag1_thdid[0:1];
   assign dbg_group12a[3:5] = tlb_ctl_dbg_tag1_type[0:2];
   assign dbg_group12a[6:7] = tlb_ctl_dbg_tag1_wq[0:1];

   assign dbg_group12a[8:11] = tlb_ctl_dbg_resv_valid[0:3];
   assign dbg_group12a[12:15] = tlb_ctl_dbg_set_resv[0:3];
   assign dbg_group12a[16:19] = tlb_ctl_dbg_resv_match_vec_q[0:3];		// tag4

   assign debug_d[group12_offset + 20] = tlb_ctl_dbg_resv0_tag0_lpid_match;
   assign debug_d[group12_offset + 21] = tlb_ctl_dbg_resv0_tag0_pid_match;
   assign debug_d[group12_offset + 22] = tlb_ctl_dbg_resv0_tag0_as_snoop_match;
   assign debug_d[group12_offset + 23] = tlb_ctl_dbg_resv0_tag0_gs_snoop_match;
   assign debug_d[group12_offset + 24] = tlb_ctl_dbg_resv0_tag0_as_tlbwe_match;
   assign debug_d[group12_offset + 25] = tlb_ctl_dbg_resv0_tag0_gs_tlbwe_match;
   assign debug_d[group12_offset + 26] = tlb_ctl_dbg_resv0_tag0_ind_match;
   assign debug_d[group12_offset + 27] = tlb_ctl_dbg_resv0_tag0_epn_loc_match;
   assign debug_d[group12_offset + 28] = tlb_ctl_dbg_resv0_tag0_epn_glob_match;
   assign debug_d[group12_offset + 29] = tlb_ctl_dbg_resv0_tag0_class_match;
   assign debug_d[group12_offset + 30] = tlb_ctl_dbg_resv1_tag0_lpid_match;
   assign debug_d[group12_offset + 31] = tlb_ctl_dbg_resv1_tag0_pid_match;
   assign debug_d[group12_offset + 32] = tlb_ctl_dbg_resv1_tag0_as_snoop_match;
   assign debug_d[group12_offset + 33] = tlb_ctl_dbg_resv1_tag0_gs_snoop_match;
   assign debug_d[group12_offset + 34] = tlb_ctl_dbg_resv1_tag0_as_tlbwe_match;
   assign debug_d[group12_offset + 35] = tlb_ctl_dbg_resv1_tag0_gs_tlbwe_match;
   assign debug_d[group12_offset + 36] = tlb_ctl_dbg_resv1_tag0_ind_match;
   assign debug_d[group12_offset + 37] = tlb_ctl_dbg_resv1_tag0_epn_loc_match;
   assign debug_d[group12_offset + 38] = tlb_ctl_dbg_resv1_tag0_epn_glob_match;
   assign debug_d[group12_offset + 39] = tlb_ctl_dbg_resv1_tag0_class_match;
   assign debug_d[group12_offset + 40] = tlb_ctl_dbg_resv2_tag0_lpid_match;
   assign debug_d[group12_offset + 41] = tlb_ctl_dbg_resv2_tag0_pid_match;
   assign debug_d[group12_offset + 42] = tlb_ctl_dbg_resv2_tag0_as_snoop_match;
   assign debug_d[group12_offset + 43] = tlb_ctl_dbg_resv2_tag0_gs_snoop_match;
   assign debug_d[group12_offset + 44] = tlb_ctl_dbg_resv2_tag0_as_tlbwe_match;
   assign debug_d[group12_offset + 45] = tlb_ctl_dbg_resv2_tag0_gs_tlbwe_match;
   assign debug_d[group12_offset + 46] = tlb_ctl_dbg_resv2_tag0_ind_match;
   assign debug_d[group12_offset + 47] = tlb_ctl_dbg_resv2_tag0_epn_loc_match;
   assign debug_d[group12_offset + 48] = tlb_ctl_dbg_resv2_tag0_epn_glob_match;
   assign debug_d[group12_offset + 49] = tlb_ctl_dbg_resv2_tag0_class_match;
   assign debug_d[group12_offset + 50] = tlb_ctl_dbg_resv3_tag0_lpid_match;
   assign debug_d[group12_offset + 51] = tlb_ctl_dbg_resv3_tag0_pid_match;
   assign debug_d[group12_offset + 52] = tlb_ctl_dbg_resv3_tag0_as_snoop_match;
   assign debug_d[group12_offset + 53] = tlb_ctl_dbg_resv3_tag0_gs_snoop_match;
   assign debug_d[group12_offset + 54] = tlb_ctl_dbg_resv3_tag0_as_tlbwe_match;
   assign debug_d[group12_offset + 55] = tlb_ctl_dbg_resv3_tag0_gs_tlbwe_match;
   assign debug_d[group12_offset + 56] = tlb_ctl_dbg_resv3_tag0_ind_match;
   assign debug_d[group12_offset + 57] = tlb_ctl_dbg_resv3_tag0_epn_loc_match;
   assign debug_d[group12_offset + 58] = tlb_ctl_dbg_resv3_tag0_epn_glob_match;
   assign debug_d[group12_offset + 59] = tlb_ctl_dbg_resv3_tag0_class_match;

   assign dbg_group12a[20:59] = debug_q[group12_offset + 20:group12_offset + 59];		// tag1

   assign dbg_group12a[60:63] = tlb_ctl_dbg_clr_resv_q[0:3];		// tag5
   assign dbg_group12a[64:67] = tlb_ctl_dbg_clr_resv_terms[0:3];		// tag5, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload

   assign dbg_group12a[68:71] = htw_dbg_req_valid_q[0:3];
   assign dbg_group12a[72:75] = htw_dbg_resv_valid_vec[0:3];
   assign dbg_group12a[76:79] = htw_dbg_tag4_clr_resv_q[0:3];
   assign dbg_group12a[80:83] = htw_dbg_tag4_clr_resv_terms[0:3];		// tag4, threadwise condensed into to  tlbivax, tlbilx, tlbwe, ptereload
   assign dbg_group12a[84:87] = 4'b0000;

   // tlb_low_data
   // [0:51] - EPN
   // [52:55] - SIZE (4b)
   // [56:59] - ThdID
   // [60:61] - Class
   // [62] - ExtClass
   // [63] - TID_NZ
   // [64:65] - reserved (2b)
   // [66:73] - 8b for LPID
   // [74:83] - parity 10bits
   assign dbg_group12b[0:83] = tlb_cmp_dbg_tag5_way[0:83];		// tag5 way epn
   assign dbg_group12b[84] = (tlb_cmp_dbg_tag5_lru_dataout[0] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[1] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[2] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[3] & tlb_cmp_dbg_tag5_wayhit[3]);		// valid
   assign dbg_group12b[85] = (tlb_cmp_dbg_tag5_lru_dataout[8] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[9] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[10] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[11] & tlb_cmp_dbg_tag5_wayhit[3]);		// iprot
   assign dbg_group12b[86] = tlb_cmp_dbg_tag5_lru_dataout[4];		// encoded lru way msb
   assign dbg_group12b[87] = ((~(tlb_cmp_dbg_tag5_lru_dataout[4])) & tlb_cmp_dbg_tag5_lru_dataout[5]) | (tlb_cmp_dbg_tag5_lru_dataout[4] & tlb_cmp_dbg_tag5_lru_dataout[6]);		// encoded lru way lsb

   assign dbg_group12 = (mmucr2[9] == 1'b1) ? dbg_group12b :
                        dbg_group12a;

   // unused tag bits for certain ops are re-purposed as below:
   //  unused `tagpos_is def is mas1_v, mas1_iprot for tlbwe, and is pte.valid & 0 for ptereloads
   //  unused `tagpos_pt, `tagpos_recform def are mas8_tgs, mas1_ts for tlbwe
   //  unused `tagpos_atsel | `tagpos_esel used as indirect entry's thdid to update tlb_entry.thdid for ptereloads
   //  unused `tagpos_wq used as htw reserv write enab & dup bits (set in htw) for ptereloads
   //  unused esel for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number (1 thru 5)
   //  unused "is" for derat,ierat,tlbsx,tlbsrx becomes tlb_seq page size attempted number msb (9 thru 13, or 17 thru 21)
   //  unused HES bit for snoops is used as mmucsr0.tlb0fi full invalidate of all non-protected entries
   //  unused class is derat ttype for derat miss, 0=load,1=store,2=epid load,3=epid store

   // type: derat,ierat,tlbsx,tlbsrx,snoop,tlbre,tlbwe,ptereload

   //group13   (lrat match logic)
   assign dbg_group13a[0] = lrat_dbg_tag1_addr_enable;		// tlb_addr_cap_q(1)
   assign dbg_group13a[1] = tlb_ctl_dbg_tag1_valid;
   assign dbg_group13a[2:3] = tlb_ctl_dbg_tag1_thdid[0:1];
   assign dbg_group13a[4:5] = {(tlb_ctl_dbg_tag1_type[0] & tlb_ctl_dbg_tag1_type[1]), (tlb_ctl_dbg_tag1_type[0] & tlb_ctl_dbg_tag1_type[2])};		// tlbsx,tlbre,tlbwe,ptereload
   assign dbg_group13a[6] = tlb_ctl_dbg_tag1_gs;
   assign dbg_group13a[7] = tlb_ctl_dbg_tag1_pr;
   assign dbg_group13a[8] = tlb_ctl_dbg_tag1_atsel;
   assign dbg_group13a[9:11] = lrat_tag3_hit_entry[0:2];
   assign dbg_group13a[12:15] = lrat_tag3_hit_status[0:3];		// hit_status to  val,hit,multihit,inval_pgsize

   assign debug_d[group13_offset + 16] = lrat_dbg_entry0_addr_match;		// tag1
   assign debug_d[group13_offset + 17] = lrat_dbg_entry0_lpid_match;
   assign debug_d[group13_offset + 18] = lrat_dbg_entry0_entry_v;
   assign debug_d[group13_offset + 19] = lrat_dbg_entry0_entry_x;
   assign debug_d[group13_offset + 20:group13_offset + 23] = lrat_dbg_entry0_size[0:3];
   assign debug_d[group13_offset + 24] = lrat_dbg_entry1_addr_match;		// tag1
   assign debug_d[group13_offset + 25] = lrat_dbg_entry1_lpid_match;
   assign debug_d[group13_offset + 26] = lrat_dbg_entry1_entry_v;
   assign debug_d[group13_offset + 27] = lrat_dbg_entry1_entry_x;
   assign debug_d[group13_offset + 28:group13_offset + 31] = lrat_dbg_entry1_size[0:3];
   assign debug_d[group13_offset + 32] = lrat_dbg_entry2_addr_match;		// tag1
   assign debug_d[group13_offset + 33] = lrat_dbg_entry2_lpid_match;
   assign debug_d[group13_offset + 34] = lrat_dbg_entry2_entry_v;
   assign debug_d[group13_offset + 35] = lrat_dbg_entry2_entry_x;
   assign debug_d[group13_offset + 36:group13_offset + 39] = lrat_dbg_entry2_size[0:3];
   assign debug_d[group13_offset + 40] = lrat_dbg_entry3_addr_match;		// tag1
   assign debug_d[group13_offset + 41] = lrat_dbg_entry3_lpid_match;
   assign debug_d[group13_offset + 42] = lrat_dbg_entry3_entry_v;
   assign debug_d[group13_offset + 43] = lrat_dbg_entry3_entry_x;
   assign debug_d[group13_offset + 44:group13_offset + 47] = lrat_dbg_entry3_size[0:3];
   assign debug_d[group13_offset + 48] = lrat_dbg_entry4_addr_match;		// tag1
   assign debug_d[group13_offset + 49] = lrat_dbg_entry4_lpid_match;
   assign debug_d[group13_offset + 50] = lrat_dbg_entry4_entry_v;
   assign debug_d[group13_offset + 51] = lrat_dbg_entry4_entry_x;
   assign debug_d[group13_offset + 52:group13_offset + 55] = lrat_dbg_entry4_size[0:3];
   assign debug_d[group13_offset + 56] = lrat_dbg_entry5_addr_match;		// tag1
   assign debug_d[group13_offset + 57] = lrat_dbg_entry5_lpid_match;
   assign debug_d[group13_offset + 58] = lrat_dbg_entry5_entry_v;
   assign debug_d[group13_offset + 59] = lrat_dbg_entry5_entry_x;
   assign debug_d[group13_offset + 60:group13_offset + 63] = lrat_dbg_entry5_size[0:3];
   assign debug_d[group13_offset + 64] = lrat_dbg_entry6_addr_match;		// tag1
   assign debug_d[group13_offset + 65] = lrat_dbg_entry6_lpid_match;
   assign debug_d[group13_offset + 66] = lrat_dbg_entry6_entry_v;
   assign debug_d[group13_offset + 67] = lrat_dbg_entry6_entry_x;
   assign debug_d[group13_offset + 68:group13_offset + 71] = lrat_dbg_entry6_size[0:3];
   assign debug_d[group13_offset + 72] = lrat_dbg_entry7_addr_match;		// tag1
   assign debug_d[group13_offset + 73] = lrat_dbg_entry7_lpid_match;
   assign debug_d[group13_offset + 74] = lrat_dbg_entry7_entry_v;
   assign debug_d[group13_offset + 75] = lrat_dbg_entry7_entry_x;
   assign debug_d[group13_offset + 76:group13_offset + 79] = lrat_dbg_entry7_size[0:3];

   assign dbg_group13a[16:79] = debug_q[group13_offset + 16:group13_offset + 79];		// tag2
   assign dbg_group13a[80:87] = lrat_dbg_tag2_matchline_q[0:7];

   // tlb_high_data
   // [84]      - [0]     - X-bit
   // [85:87]   - [1:3]   - reserved (3b)
   // [88:117]  - [4:33]  - RPN (30b)
   // [118:119] - [34:35] - R,C
   // [120:121] - [36:37] - WLC (2b)
   // [122]     - [38]    - ResvAttr
   // [123]     - [39]    - VF
   // [124]     - [40]    - IND
   // [125:128] - [41:44] - U0-U3
   // [129:133] - [45:49] - WIMGE
   // [134:135] - [50:51] - UX,SX
   // [136:137] - [52:53] - UW,SW
   // [138:139] - [54:55] - UR,SR
   // [140]     - [56] - GS
   // [141]     - [57] - TS
   // [142:143] - [58:59] - reserved (2b)
   // [144:149] - [60:65] - 6b TID msbs
   // [150:157] - [66:73] - 8b TID lsbs
   // [158:167] - [74:83] - parity 10bits
   assign dbg_group13b[0:83] = tlb_cmp_dbg_tag5_way[84:167];		// tag5 way rpn
   assign dbg_group13b[84] = (tlb_cmp_dbg_tag5_lru_dataout[0] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[1] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[2] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[3] & tlb_cmp_dbg_tag5_wayhit[3]);		// valid
   assign dbg_group13b[85] = (tlb_cmp_dbg_tag5_lru_dataout[8] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[9] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[10] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[11] & tlb_cmp_dbg_tag5_wayhit[3]);		// iprot
   assign dbg_group13b[86] = tlb_cmp_dbg_tag5_lru_dataout[4];		// encoded lru way msb
   assign dbg_group13b[87] = ((~(tlb_cmp_dbg_tag5_lru_dataout[4])) & tlb_cmp_dbg_tag5_lru_dataout[5]) | (tlb_cmp_dbg_tag5_lru_dataout[4] & tlb_cmp_dbg_tag5_lru_dataout[6]);		// encoded lru way lsb

   assign dbg_group13 = (mmucr2[9] == 1'b1) ? dbg_group13b :
                        dbg_group13a;

   //group14   (htw control)
   assign dbg_group14a[0:1] = htw_dbg_seq_q[0:1];
   assign dbg_group14a[2:3] = htw_dbg_inptr_q[0:1];
   assign dbg_group14a[4] = htw_dbg_ptereload_ptr_q;
   assign dbg_group14a[5:6] = htw_dbg_lsuptr_q[0:1];
   assign dbg_group14a[7] = htw_lsu_ttype[1];
   assign dbg_group14a[8:9] = htw_dbg_lsu_thdid[0:1];		// encoded
   assign dbg_group14a[10:51] = htw_lsu_addr[22:63];
   assign dbg_group14a[52:54] = htw_dbg_pte0_seq_q[0:2];
   assign dbg_group14a[55:56] = htw_dbg_pte0_score_ptr_q[0:1];
   assign dbg_group14a[57:59] = htw_dbg_pte0_score_cl_offset_q[58:60];
   assign dbg_group14a[60:62] = htw_dbg_pte0_score_error_q[0:2];
   assign dbg_group14a[63:66] = htw_dbg_pte0_score_qwbeat_q[0:3];		// 4 beats of data per CL
   assign dbg_group14a[67] = htw_dbg_pte0_score_pending_q;
   assign dbg_group14a[68] = htw_dbg_pte0_score_ibit_q;
   assign dbg_group14a[69] = htw_dbg_pte0_score_dataval_q;
   assign dbg_group14a[70:72] = htw_dbg_pte1_seq_q[0:2];
   assign dbg_group14a[73:74] = htw_dbg_pte1_score_ptr_q[0:1];
   assign dbg_group14a[75:77] = htw_dbg_pte1_score_cl_offset_q[58:60];
   assign dbg_group14a[78:80] = htw_dbg_pte1_score_error_q[0:2];
   assign dbg_group14a[81:84] = htw_dbg_pte1_score_qwbeat_q[0:3];		// 4 beats of data per CL
   assign dbg_group14a[85] = htw_dbg_pte1_score_pending_q;
   assign dbg_group14a[86] = htw_dbg_pte1_score_ibit_q;
   assign dbg_group14a[87] = htw_dbg_pte1_score_dataval_q;

   // tlb_low_data
   // [0:51] - EPN
   // [52:55] - SIZE (4b)
   // [56:59] - ThdID
   // [60:61] - Class
   // [62] - ExtClass
   // [63] - TID_NZ
   // [64:65] - reserved (2b)
   // [66:73] - 8b for LPID
   // [74:83] - parity 10bits

   // tlb_high_data
   // [84]      - [0]     - X-bit
   // [85:87]   - [1:3]   - reserved (3b)
   // [88:117]  - [4:33]  - RPN (30b)
   // [118:119] - [34:35] - R,C
   // [120:121] - [36:37] - WLC (2b)
   // [122]     - [38]    - ResvAttr
   // [123]     - [39]    - VF
   // [124]     - [40]    - IND
   // [125:128] - [41:44] - U0-U3
   // [129:133] - [45:49] - WIMGE
   // [134:135] - [50:51] - UX,SX
   // [136:137] - [52:53] - UW,SW
   // [138:139] - [54:55] - UR,SR
   // [140]     - [56] - GS
   // [141]     - [57] - TS
   // [142:143] - [58:59] - reserved (2b)
   // [144:149] - [60:65] - 6b TID msbs
   // [150:157] - [66:73] - 8b TID lsbs
   // [158:167] - [74:83] - parity 10bits
   assign dbg_group14b[0] = (tlb_cmp_dbg_tag5_lru_dataout[0] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[1] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[2] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[3] & tlb_cmp_dbg_tag5_wayhit[3]);		// valid
   assign dbg_group14b[1] = (tlb_cmp_dbg_tag5_lru_dataout[8] & tlb_cmp_dbg_tag5_wayhit[0]) | (tlb_cmp_dbg_tag5_lru_dataout[9] & tlb_cmp_dbg_tag5_wayhit[1]) | (tlb_cmp_dbg_tag5_lru_dataout[10] & tlb_cmp_dbg_tag5_wayhit[2]) | (tlb_cmp_dbg_tag5_lru_dataout[11] & tlb_cmp_dbg_tag5_wayhit[3]);		// iprot

   assign dbg_group14b[2] = tlb_cmp_dbg_tag5_way[140];		// gs
   assign dbg_group14b[3] = tlb_cmp_dbg_tag5_way[141];		// ts
   assign dbg_group14b[4:11] = tlb_cmp_dbg_tag5_way[66:73];		// tlpid
   assign dbg_group14b[12:25] = tlb_cmp_dbg_tag5_way[144:157];		// tid, 14bits
   assign dbg_group14b[26:45] = tlb_cmp_dbg_tag5_way[32:51];		// epn truncated to lower 20b
   assign dbg_group14b[46:49] = tlb_cmp_dbg_tag5_way[52:55];		// size
   assign dbg_group14b[50:53] = tlb_cmp_dbg_tag5_way[56:59];		// thdid
   assign dbg_group14b[54] = tlb_cmp_dbg_tag5_way[84];		// xbit
   assign dbg_group14b[55] = tlb_cmp_dbg_tag5_way[40];		// ind
   assign dbg_group14b[56:57] = tlb_cmp_dbg_tag5_way[60:61];		// class
   assign dbg_group14b[58:77] = tlb_cmp_dbg_tag5_way[98:117];		// rpn truncated to lower 20b
   assign dbg_group14b[78:81] = tlb_cmp_dbg_tag5_way[130:133];		// imge
   assign dbg_group14b[82:87] = tlb_cmp_dbg_tag5_way[134:139];		// user/sup prot bits

   assign dbg_group14 = (mmucr2[10] == 1'b1) ? dbg_group14b :
                        dbg_group14a;

   //group15   (ptereload pte)
   assign dbg_group15a[0:1] = htw_dbg_seq_q[0:1];
   assign dbg_group15a[2:4] = htw_dbg_pte0_seq_q[0:2];
   assign dbg_group15a[5:7] = htw_dbg_pte1_seq_q[0:2];
   assign dbg_group15a[8] = htw_lsu_req_valid;
   assign dbg_group15a[9:21] = htw_lsu_addr[48:60];
   assign dbg_group15a[22] = htw_dbg_ptereload_ptr_q;
   assign dbg_group15a[23] = ptereload_req_taken;
   assign dbg_group15a[24:87] = ptereload_req_pte[0:63];		// pte entry

   assign dbg_group15b[0:73] = tlb_cmp_dbg_tag5_way[0:73];		// tag5 way epn
   assign dbg_group15b[74:77] = tlb_cmp_dbg_tag5_lru_dataout[0:3];
   assign dbg_group15b[78:81] = tlb_cmp_dbg_tag5_lru_dataout[8:11];
   assign dbg_group15b[82] = tlb_cmp_dbg_tag5_lru_dataout[4];		// encoded lsu way msb
   assign dbg_group15b[83] = ((~(tlb_cmp_dbg_tag5_lru_dataout[4])) & tlb_cmp_dbg_tag5_lru_dataout[5]) | (tlb_cmp_dbg_tag5_lru_dataout[4] & tlb_cmp_dbg_tag5_lru_dataout[6]);		// encoded lsu way lsb
   assign dbg_group15b[84:87] = tlb_cmp_dbg_tag5_wayhit[0:3];

   assign dbg_group15 = (mmucr2[10] == 1'b1) ? dbg_group15b :
                        dbg_group15a;

   // trigger group0
   assign trg_group0[0] = (~(tlb_ctl_dbg_seq_idle));
   assign trg_group0[1:2] = tlb_ctl_dbg_tag0_thdid[0:1];		// encoded
   assign trg_group0[3:5] = tlb_ctl_dbg_tag0_type[0:2];		// encoded
   assign trg_group0[6] = (~(inval_dbg_seq_idle));
   assign trg_group0[7] = inval_dbg_seq_snoop_inprogress;		// bus snoop
   assign trg_group0[8] = (~(htw_dbg_seq_idle));
   assign trg_group0[9] = (~(htw_dbg_pte0_seq_idle));
   assign trg_group0[10] = (~(htw_dbg_pte1_seq_idle));
   assign trg_group0[11] = tlb_cmp_dbg_tag5_any_exception;		// big or gate

   // trigger group1
   assign trg_group1[0:5] = tlb_ctl_dbg_seq_q[0:5];
   assign trg_group1[6:10] = inval_dbg_seq_q[0:4];
   assign trg_group1[11] = tlb_ctl_dbg_seq_any_done_sig | tlb_ctl_dbg_seq_abort | inval_dbg_seq_snoop_done | inval_dbg_seq_local_done | inval_dbg_seq_tlb0fi_done | inval_dbg_seq_tlbwe_snoop_done;

   // trigger group2
   assign trg_group2[0] = tlb_req_dbg_ierat_iu5_valid_q;
   assign trg_group2[1] = tlb_req_dbg_derat_ex6_valid_q;
   assign trg_group2[2] = tlb_ctl_dbg_any_tlb_req_sig;
   assign trg_group2[3] = tlb_ctl_dbg_any_req_taken_sig;
   assign trg_group2[4] = tlb_ctl_dbg_seq_any_done_sig | tlb_ctl_dbg_seq_abort;
   assign trg_group2[5] = inval_dbg_ex6_valid;		//-------------->  need tlbivax/erativax indication?
   assign trg_group2[6] = mmucsr0_tlb0fi;
   assign trg_group2[7] = inval_dbg_snoop_forme;
   assign trg_group2[8] = tlbwe_back_inv_valid;
   assign trg_group2[9] = htw_lsu_req_valid;
   assign trg_group2[10] = inval_dbg_seq_snoop_done | inval_dbg_seq_local_done | inval_dbg_seq_tlb0fi_done | inval_dbg_seq_tlbwe_snoop_done;
   assign trg_group2[11] = |(mm_xu_lsu_req);

   // trigger group3
   assign trg_group3a[0] = spr_dbg_slowspr_val_int;
   assign trg_group3a[1] = spr_dbg_slowspr_rw_int;
   assign trg_group3a[2:3] = spr_dbg_slowspr_etid_int;
   assign trg_group3a[4] = spr_dbg_match_64b;
   assign trg_group3a[5] = spr_dbg_match_any_mmu;		// int phase
   assign trg_group3a[6] = spr_dbg_match_any_mas;
   assign trg_group3a[7] = spr_dbg_match_mmucr0 | spr_dbg_match_mmucr1 | spr_dbg_match_mmucr2 | spr_dbg_match_mmucr3;
   assign trg_group3a[8] = spr_dbg_match_pid | spr_dbg_match_lpidr;
   assign trg_group3a[9] = spr_dbg_match_lper | spr_dbg_match_lperu;
   assign trg_group3a[10] = spr_dbg_slowspr_val_out;
   assign trg_group3a[11] = spr_dbg_slowspr_done_out;

   assign trg_group3b[0] = tlb_htw_req_valid;
   assign trg_group3b[1:2] = htw_dbg_seq_q[0:1];
   assign trg_group3b[3:5] = htw_dbg_pte0_seq_q[0:2];
   assign trg_group3b[6:8] = htw_dbg_pte1_seq_q[0:2];
   assign trg_group3b[9] = htw_dbg_pte0_reld_for_me_tm1 | htw_dbg_pte1_reld_for_me_tm1;
   assign trg_group3b[10] = |(htw_dbg_pte0_score_error_q | htw_dbg_pte1_score_error_q);
   assign trg_group3b[11] = tlb_cmp_dbg_tag5_any_exception;

   assign trg_group3 = (mmucr2[11] == 1'b1) ? trg_group3b :
                       trg_group3a;

   tri_debug_mux16 #(.DBG_WIDTH(`DEBUG_TRACE_WIDTH)) dbg_mux0(
      .select_bits(pc_mm_debug_mux1_ctrls_loc_q),
      .trace_data_in(debug_bus_in_q),

      .dbg_group0(dbg_group0[0:31]),
      .dbg_group1(dbg_group1[0:31]),
      .dbg_group2(dbg_group2[0:31]),
      .dbg_group3(dbg_group3[0:31]),
      .dbg_group4(dbg_group4[0:31]),
      .dbg_group5(dbg_group5[0:31]),
      .dbg_group6(dbg_group6[0:31]),
      .dbg_group7(dbg_group7[0:31]),
      .dbg_group8(dbg_group8[0:31]),
      .dbg_group9(dbg_group9[0:31]),
      .dbg_group10(dbg_group10[0:31]),
      .dbg_group11(dbg_group11[0:31]),
      .dbg_group12(dbg_group12[0:31]),
      .dbg_group13(dbg_group13[0:31]),
      .dbg_group14(dbg_group14[0:31]),
      .dbg_group15(dbg_group15[0:31]),

      .trace_data_out(trace_data_out_d),

     // Instruction Trace (HTM) Control Signals:
     //  0    - ac_an_coretrace_first_valid
     //  1    - ac_an_coretrace_valid
     //  2:3  - ac_an_coretrace_type[0:1]
      .coretrace_ctrls_in(coretrace_ctrls_in_q),    // input  [0:3]
      .coretrace_ctrls_out(coretrace_ctrls_out_d)   // output [0:3]

   );

   assign debug_bus_out = trace_data_out_q;
   assign coretrace_ctrls_out = coretrace_ctrls_out_q;


   // unused spare signal assignments
   assign unused_dc[0] = tlb_mas_thdid[0];
   assign unused_dc[1] = lrat_mas_thdid[0];
   assign unused_dc[2] = lrat_mas_thdid[0];
   assign unused_dc[3] = inval_dbg_lsu_tokens_q[0];
   assign unused_dc[4] = tlb_cmp_dbg_tag4[82];		// `tagpos_derat, not used for type encoding of '0'
   assign unused_dc[5] = tlb_cmp_dbg_tag4[106];		// `tagpos_lrat

   assign unused_dc[6] = |(tlb_cmp_dbg_tag4[0:7]);		// `tagpos_epn
   assign unused_dc[7] = |(tlb_cmp_dbg_tag4[8:15]);
   assign unused_dc[8] = tlb_cmp_dbg_tag5_wayhit[4];

   generate
      if (`TLB_TAG_WIDTH > 110)
      begin : itagExist
         assign unused_dc[9] = debug_q[23] | |(tlb_cmp_dbg_tag4[110:`TLB_TAG_WIDTH - 1]);		// tag bits
      end
   endgenerate

   generate
      if (`TLB_TAG_WIDTH < 111)
      begin : itagNExist
         assign unused_dc[9] = debug_q[23];		// tag bits
      end
   endgenerate

   assign unused_dc[10] = |(trigger_q[0:47]);
   assign unused_dc[11] = tlb_cmp_dbg_tag5_lru_dataout[7];		// lru parity bit

   //---------------------------------------------------------------------
   // Latches
   //---------------------------------------------------------------------


   tri_rlmlatch_p #(.INIT(0), .NEEDS_SRESET(0)) trace_bus_enable_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .force_t(pc_func_slp_sl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .scin(siv[trace_bus_enable_offset]),
      .scout(sov[trace_bus_enable_offset]),
      .din(pc_mm_trace_bus_enable),
      .dout(pc_mm_trace_bus_enable_q)
   );

//========================================================================================
   tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(0)) debug_mux1_ctrls_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .force_t(pc_func_slp_sl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .scin(siv[debug_mux1_ctrls_offset:debug_mux1_ctrls_offset + 11 - 1]),
      .scout(sov[debug_mux1_ctrls_offset:debug_mux1_ctrls_offset + 11 - 1]),
      .din(pc_mm_debug_mux1_ctrls),
      .dout(pc_mm_debug_mux1_ctrls_q)
   );

   tri_rlmreg_p #(.WIDTH(11), .INIT(0), .NEEDS_SRESET(0)) debug_mux1_ctrls_loc_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .force_t(pc_func_slp_sl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .scin(siv[debug_mux1_ctrls_loc_offset:debug_mux1_ctrls_loc_offset + 11 - 1]),
      .scout(sov[debug_mux1_ctrls_loc_offset:debug_mux1_ctrls_loc_offset + 11 - 1]),
      .din(pc_mm_debug_mux1_ctrls_loc_d),
      .dout(pc_mm_debug_mux1_ctrls_loc_q)
   );
//========================================================================================

   tri_rlmreg_p #(.WIDTH(`DEBUG_TRIGGER_WIDTH), .INIT(0)) trigger_data_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_mm_trace_bus_enable_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv[trigger_data_out_offset:trigger_data_out_offset + 12 - 1]),
      .scout(sov[trigger_data_out_offset:trigger_data_out_offset + 12 - 1]),
      .din({12{1'b0}}),
      .dout(trigger_data_out_q)
   );


   tri_rlmreg_p #(.WIDTH(`DEBUG_TRACE_WIDTH), .INIT(0)) trace_data_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_mm_trace_bus_enable_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv[trace_data_out_offset:trace_data_out_offset + `DEBUG_TRACE_WIDTH - 1]),
      .scout(sov[trace_data_out_offset:trace_data_out_offset + `DEBUG_TRACE_WIDTH - 1]),
      .din(trace_data_out_d),
      .dout(trace_data_out_q)
   );


   tri_rlmreg_p #(.WIDTH(8), .INIT(0)) trace_data_out_int_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_mm_trace_bus_enable_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv[trace_data_out_int_offset:trace_data_out_int_offset + 8 - 1]),
      .scout(sov[trace_data_out_int_offset:trace_data_out_int_offset + 8 - 1]),
      .din(trace_data_out_d[0:7]),
      .dout(trace_data_out_int_q)
   );

   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) coretrace_ctrls_out_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_mm_trace_bus_enable_q),
      .thold_b(pc_func_slp_sl_thold_0_b),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_sl_force),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .d_mode(lcb_d_mode_dc),
      .scin(siv[coretrace_ctrls_out_offset:coretrace_ctrls_out_offset + 4 - 1]),
      .scout(sov[coretrace_ctrls_out_offset:coretrace_ctrls_out_offset + 4 - 1]),
      .din(coretrace_ctrls_out_d),
      .dout(coretrace_ctrls_out_q)
   );


   tri_regk #(.WIDTH(DEBUG_LATCH_WIDTH), .INIT(0), .NEEDS_SRESET(0)) debug_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(unused_debug_latch_scan),
      .scout(unused_debug_latch_scan),
      .din(debug_d),
      .dout(debug_q)
   );


   tri_regk #(.WIDTH(TRIGGER_LATCH_WIDTH), .INIT(0), .NEEDS_SRESET(0)) trigger_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(unused_trigger_latch_scan),
      .scout(unused_trigger_latch_scan),
      .din(trigger_d),
      .dout(trigger_q)
   );


   tri_regk #(.WIDTH(`DEBUG_TRACE_WIDTH), .INIT(0), .NEEDS_SRESET(0)) debug_bus_in_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .sg(pc_sg_0),
      .force_t(pc_func_slp_nsl_force),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(unused_busin_latch_scan),
      .scout(unused_busin_latch_scan),
      .din(debug_bus_in),
      .dout(debug_bus_in_q)
   );


   tri_regk #(.WIDTH(`DEBUG_TRIGGER_WIDTH), .INIT(0), .NEEDS_SRESET(0)) trace_triggers_in_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .force_t(pc_func_slp_nsl_force),
      .sg(pc_sg_0),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(unused_trigin_latch_scan),
      .scout(unused_trigin_latch_scan),
      .din({12{1'b0}}),
      .dout(trace_triggers_in_q)
   );

   tri_regk #(.WIDTH(4), .INIT(0), .NEEDS_SRESET(0)) coretrace_ctrls_in_latch(
      .nclk(nclk),
      .vd(vdd),
      .gd(gnd),
      .act(pc_mm_trace_bus_enable_q),
      .force_t(pc_func_slp_nsl_force),
      .sg(pc_sg_0),
      .d_mode(lcb_d_mode_dc),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .thold_b(pc_func_slp_nsl_thold_0_b),
      .scin(unused_coretrace_ctrls_in_latch_scan),
      .scout(unused_coretrace_ctrls_in_latch_scan),
      .din(coretrace_ctrls_in),
      .dout(coretrace_ctrls_in_q)
   );

   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------


   tri_plat #(.WIDTH(4)) perv_2to1_plat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din( {pc_func_slp_sl_thold_2, pc_func_slp_nsl_thold_2, pc_sg_2, pc_fce_2} ),
      .q( {pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} )
   );


   tri_plat #(.WIDTH(4)) perv_1to0_plat(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din( {pc_func_slp_sl_thold_1, pc_func_slp_nsl_thold_1, pc_sg_1, pc_fce_1} ),
      .q( {pc_func_slp_sl_thold_0, pc_func_slp_nsl_thold_0, pc_sg_0, pc_fce_0} )
   );


   tri_lcbor  perv_sl_lcbor(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_sl_thold_0),
      .sg(pc_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(pc_func_slp_sl_force),
      .thold_b(pc_func_slp_sl_thold_0_b)
   );


   tri_lcbor  perv_nsl_lcbor(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(pc_func_slp_nsl_thold_0),
      .sg(pc_fce_0),
      .act_dis(tidn),
      .force_t(pc_func_slp_nsl_force),
      .thold_b(pc_func_slp_nsl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];


endmodule
