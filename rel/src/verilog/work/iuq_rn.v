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

//********************************************************************
//*
//* TITLE:
//*
//* NAME: iuq_rn.vhdl
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_rn(
   inout                          vdd,
   inout                          gnd,
   input [0:`NCLK_WIDTH-1]        nclk,
   input                          pc_iu_func_sl_thold_2,		// acts as reset for non-ibm types
   input                          pc_iu_sg_2,
   input                          clkoff_b,
   input                          act_dis,
   input                          tc_ac_ccflush_dc,
   input                          d_mode,
   input                          delay_lclkr,
   input                          mpw1_b,
   input                          mpw2_b,
   input                          func_scan_in,
   output                         func_scan_out,

   //-----------------------------
   // SPR connections
   //-----------------------------
   input                          spr_high_pri_mask,
   input                          spr_cpcr_we,
   input [0:6]                    spr_cpcr3_cp_cnt,
   input [0:6]                    spr_cpcr5_cp_cnt,
   input                          spr_single_issue,

   //-------------------------------
   // Performance interface with I$
   //-------------------------------
   input                          pc_iu_event_bus_enable,
   output                         perf_iu5_stall,
   output                         perf_iu5_cpl_credit_stall,
   output                         perf_iu5_gpr_credit_stall,
   output                         perf_iu5_cr_credit_stall,
   output                         perf_iu5_lr_credit_stall,
   output                         perf_iu5_ctr_credit_stall,
   output                         perf_iu5_xer_credit_stall,
   output                         perf_iu5_br_hold_stall,
   output                         perf_iu5_axu_hold_stall,

   //-----------------------------
   // Inputs to rename from decode
   //-----------------------------
   input                          fdec_frn_iu5_i0_vld,
   input [0:2]                    fdec_frn_iu5_i0_ucode,
   input                          fdec_frn_iu5_i0_2ucode,
   input                          fdec_frn_iu5_i0_fuse_nop,
   input                          fdec_frn_iu5_i0_rte_lq,
   input                          fdec_frn_iu5_i0_rte_sq,
   input                          fdec_frn_iu5_i0_rte_fx0,
   input                          fdec_frn_iu5_i0_rte_fx1,
   input                          fdec_frn_iu5_i0_rte_axu0,
   input                          fdec_frn_iu5_i0_rte_axu1,
   input                          fdec_frn_iu5_i0_valop,
   input                          fdec_frn_iu5_i0_ord,
   input                          fdec_frn_iu5_i0_cord,
   input [0:2]                    fdec_frn_iu5_i0_error,
   input                          fdec_frn_iu5_i0_btb_entry,
   input [0:1]                    fdec_frn_iu5_i0_btb_hist,
   input                          fdec_frn_iu5_i0_bta_val,
   input [0:19]                   fdec_frn_iu5_i0_fusion,
   input                          fdec_frn_iu5_i0_spec,
   input                          fdec_frn_iu5_i0_type_fp,
   input                          fdec_frn_iu5_i0_type_ap,
   input                          fdec_frn_iu5_i0_type_spv,
   input                          fdec_frn_iu5_i0_type_st,
   input                          fdec_frn_iu5_i0_async_block,
   input                          fdec_frn_iu5_i0_np1_flush,
   input                          fdec_frn_iu5_i0_core_block,
   input                          fdec_frn_iu5_i0_isram,
   input                          fdec_frn_iu5_i0_isload,
   input                          fdec_frn_iu5_i0_isstore,
   input [0:31]                   fdec_frn_iu5_i0_instr,
   input [62-`EFF_IFAR_WIDTH:61]   fdec_frn_iu5_i0_ifar,
   input [62-`EFF_IFAR_WIDTH:61]   fdec_frn_iu5_i0_bta,
   input                          fdec_frn_iu5_i0_br_pred,
   input                          fdec_frn_iu5_i0_bh_update,
   input [0:1]                    fdec_frn_iu5_i0_bh0_hist,
   input [0:1]                    fdec_frn_iu5_i0_bh1_hist,
   input [0:1]                    fdec_frn_iu5_i0_bh2_hist,
   input [0:17]                    fdec_frn_iu5_i0_gshare,
   input [0:2]                    fdec_frn_iu5_i0_ls_ptr,
   input                          fdec_frn_iu5_i0_match,
   input [0:3]                    fdec_frn_iu5_i0_ilat,
   input                          fdec_frn_iu5_i0_t1_v,
   input [0:2]                    fdec_frn_iu5_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_t1_a,
   input                          fdec_frn_iu5_i0_t2_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_t2_a,
   input [0:2]                    fdec_frn_iu5_i0_t2_t,
   input                          fdec_frn_iu5_i0_t3_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_t3_a,
   input [0:2]                    fdec_frn_iu5_i0_t3_t,
   input                          fdec_frn_iu5_i0_s1_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_s1_a,
   input [0:2]                    fdec_frn_iu5_i0_s1_t,
   input                          fdec_frn_iu5_i0_s2_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_s2_a,
   input [0:2]                    fdec_frn_iu5_i0_s2_t,
   input                          fdec_frn_iu5_i0_s3_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i0_s3_a,
   input [0:2]                    fdec_frn_iu5_i0_s3_t,

   input                          fdec_frn_iu5_i1_vld,
   input [0:2]                    fdec_frn_iu5_i1_ucode,
   input                          fdec_frn_iu5_i1_fuse_nop,
   input                          fdec_frn_iu5_i1_rte_lq,
   input                          fdec_frn_iu5_i1_rte_sq,
   input                          fdec_frn_iu5_i1_rte_fx0,
   input                          fdec_frn_iu5_i1_rte_fx1,
   input                          fdec_frn_iu5_i1_rte_axu0,
   input                          fdec_frn_iu5_i1_rte_axu1,
   input                          fdec_frn_iu5_i1_valop,
   input                          fdec_frn_iu5_i1_ord,
   input                          fdec_frn_iu5_i1_cord,
   input [0:2]                    fdec_frn_iu5_i1_error,
   input                          fdec_frn_iu5_i1_btb_entry,
   input [0:1]                    fdec_frn_iu5_i1_btb_hist,
   input                          fdec_frn_iu5_i1_bta_val,
   input [0:19]                   fdec_frn_iu5_i1_fusion,
   input                          fdec_frn_iu5_i1_spec,
   input                          fdec_frn_iu5_i1_type_fp,
   input                          fdec_frn_iu5_i1_type_ap,
   input                          fdec_frn_iu5_i1_type_spv,
   input                          fdec_frn_iu5_i1_type_st,
   input                          fdec_frn_iu5_i1_async_block,
   input                          fdec_frn_iu5_i1_np1_flush,
   input                          fdec_frn_iu5_i1_core_block,
   input                          fdec_frn_iu5_i1_isram,
   input                          fdec_frn_iu5_i1_isload,
   input                          fdec_frn_iu5_i1_isstore,
   input [0:31]                   fdec_frn_iu5_i1_instr,
   input [62-`EFF_IFAR_WIDTH:61]   fdec_frn_iu5_i1_ifar,
   input [62-`EFF_IFAR_WIDTH:61]   fdec_frn_iu5_i1_bta,
   input                          fdec_frn_iu5_i1_br_pred,
   input                          fdec_frn_iu5_i1_bh_update,
   input [0:1]                    fdec_frn_iu5_i1_bh0_hist,
   input [0:1]                    fdec_frn_iu5_i1_bh1_hist,
   input [0:1]                    fdec_frn_iu5_i1_bh2_hist,
   input [0:17]                    fdec_frn_iu5_i1_gshare,
   input [0:2]                    fdec_frn_iu5_i1_ls_ptr,
   input                          fdec_frn_iu5_i1_match,
   input [0:3]                    fdec_frn_iu5_i1_ilat,
   input                          fdec_frn_iu5_i1_t1_v,
   input [0:2]                    fdec_frn_iu5_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_t1_a,
   input                          fdec_frn_iu5_i1_t2_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_t2_a,
   input [0:2]                    fdec_frn_iu5_i1_t2_t,
   input                          fdec_frn_iu5_i1_t3_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_t3_a,
   input [0:2]                    fdec_frn_iu5_i1_t3_t,
   input                          fdec_frn_iu5_i1_s1_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_s1_a,
   input [0:2]                    fdec_frn_iu5_i1_s1_t,
   input                          fdec_frn_iu5_i1_s2_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_s2_a,
   input [0:2]                    fdec_frn_iu5_i1_s2_t,
   input                          fdec_frn_iu5_i1_s3_v,
   input [0:`GPR_POOL_ENC-1]       fdec_frn_iu5_i1_s3_a,
   input [0:2]                    fdec_frn_iu5_i1_s3_t,

   //-----------------------------
   // Stall to decode
   //-----------------------------
   output                         frn_fdec_iu5_stall,
   input                          au_iu_iu5_stall,		//AXU Rename stall

   //-----------------------------
   // Stall from dispatch
   //-----------------------------
   input                          fdis_frn_iu6_stall,

   //----------------------------
   // Completion Interface
   //----------------------------
   input                          cp_rn_empty,
   input                          cp_rn_i0_v,
   input [0:`ITAG_SIZE_ENC-1]      cp_rn_i0_itag,
   input                          cp_rn_i0_t1_v,
   input [0:2]                    cp_rn_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t1_a,
   input                          cp_rn_i0_t2_v,
   input [0:2]                    cp_rn_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t2_a,
   input                          cp_rn_i0_t3_v,
   input [0:2]                    cp_rn_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i0_t3_a,

   input                          cp_rn_i1_v,
   input [0:`ITAG_SIZE_ENC-1]      cp_rn_i1_itag,
   input                          cp_rn_i1_t1_v,
   input [0:2]                    cp_rn_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t1_a,
   input                          cp_rn_i1_t2_v,
   input [0:2]                    cp_rn_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t2_a,
   input                          cp_rn_i1_t3_v,
   input [0:2]                    cp_rn_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]       cp_rn_i1_t3_a,

   input                          cp_flush,
   input                          cp_flush_into_uc,
   input                          br_iu_redirect,
   input                          cp_rn_uc_credit_free,

   //----------------------------------------------------------------
   // AXU Interface
   //----------------------------------------------------------------
   output                         iu_au_iu5_send_ok,
   output [0:`ITAG_SIZE_ENC-1]     iu_au_iu5_next_itag_i0,
   output [0:`ITAG_SIZE_ENC-1]     iu_au_iu5_next_itag_i1,
   input                          au_iu_iu5_axu0_send_ok,
   input                          au_iu_iu5_axu1_send_ok,

   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_s1_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_s2_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i0_s3_p,

   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i0_s1_itag,
   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i0_s2_itag,
   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i0_s3_itag,

   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_s1_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_s2_p,
   input [0:`GPR_POOL_ENC-1]       au_iu_iu5_i1_s3_p,
   input                           au_iu_iu5_i1_s1_dep_hit,
   input                           au_iu_iu5_i1_s2_dep_hit,
   input                           au_iu_iu5_i1_s3_dep_hit,

   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i1_s1_itag,
   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i1_s2_itag,
   input [0:`ITAG_SIZE_ENC-1]      au_iu_iu5_i1_s3_itag,

   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output                         frn_fdis_iu6_i0_vld,
   output [0:`ITAG_SIZE_ENC-1]     frn_fdis_iu6_i0_itag,
   output [0:2]                   frn_fdis_iu6_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_i0_ucode_cnt,
   output                         frn_fdis_iu6_i0_2ucode,
   output                         frn_fdis_iu6_i0_fuse_nop,
   output                         frn_fdis_iu6_i0_rte_lq,
   output                         frn_fdis_iu6_i0_rte_sq,
   output                         frn_fdis_iu6_i0_rte_fx0,
   output                         frn_fdis_iu6_i0_rte_fx1,
   output                         frn_fdis_iu6_i0_rte_axu0,
   output                         frn_fdis_iu6_i0_rte_axu1,
   output                         frn_fdis_iu6_i0_valop,
   output                         frn_fdis_iu6_i0_ord,
   output                         frn_fdis_iu6_i0_cord,
   output [0:2]                   frn_fdis_iu6_i0_error,
   output                         frn_fdis_iu6_i0_btb_entry,
   output [0:1]                   frn_fdis_iu6_i0_btb_hist,
   output                         frn_fdis_iu6_i0_bta_val,
   output [0:19]                  frn_fdis_iu6_i0_fusion,
   output                         frn_fdis_iu6_i0_spec,
   output                         frn_fdis_iu6_i0_type_fp,
   output                         frn_fdis_iu6_i0_type_ap,
   output                         frn_fdis_iu6_i0_type_spv,
   output                         frn_fdis_iu6_i0_type_st,
   output                         frn_fdis_iu6_i0_async_block,
   output                         frn_fdis_iu6_i0_np1_flush,
   output                         frn_fdis_iu6_i0_core_block,
   output                         frn_fdis_iu6_i0_isram,
   output                         frn_fdis_iu6_i0_isload,
   output                         frn_fdis_iu6_i0_isstore,
   output [0:31]                  frn_fdis_iu6_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]  frn_fdis_iu6_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]  frn_fdis_iu6_i0_bta,
   output                         frn_fdis_iu6_i0_br_pred,
   output                         frn_fdis_iu6_i0_bh_update,
   output [0:1]                   frn_fdis_iu6_i0_bh0_hist,
   output [0:1]                   frn_fdis_iu6_i0_bh1_hist,
   output [0:1]                   frn_fdis_iu6_i0_bh2_hist,
   output [0:17]                   frn_fdis_iu6_i0_gshare,
   output [0:2]                   frn_fdis_iu6_i0_ls_ptr,
   output                         frn_fdis_iu6_i0_match,
   output [0:3]                   frn_fdis_iu6_i0_ilat,
   output                         frn_fdis_iu6_i0_t1_v,
   output [0:2]                   frn_fdis_iu6_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t1_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t1_p,
   output                         frn_fdis_iu6_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t2_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t2_p,
   output [0:2]                   frn_fdis_iu6_i0_t2_t,
   output                         frn_fdis_iu6_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t3_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_t3_p,
   output [0:2]                   frn_fdis_iu6_i0_t3_t,
   output                         frn_fdis_iu6_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s1_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s1_p,
   output [0:`ITAG_SIZE_ENC-1]     frn_fdis_iu6_i0_s1_itag,
   output [0:2]                   frn_fdis_iu6_i0_s1_t,
   output                         frn_fdis_iu6_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s2_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s2_p,
   output [0:`ITAG_SIZE_ENC-1]     frn_fdis_iu6_i0_s2_itag,
   output [0:2]                   frn_fdis_iu6_i0_s2_t,
   output                         frn_fdis_iu6_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s3_a,
   output [0:`GPR_POOL_ENC-1]      frn_fdis_iu6_i0_s3_p,
   output [0:`ITAG_SIZE_ENC-1]     frn_fdis_iu6_i0_s3_itag,
   output [0:2]                   frn_fdis_iu6_i0_s3_t,

   output                         frn_fdis_iu6_i1_vld,
   output [0:`ITAG_SIZE_ENC-1]     frn_fdis_iu6_i1_itag,
   output [0:2]                   frn_fdis_iu6_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_i1_ucode_cnt,
   output                         frn_fdis_iu6_i1_fuse_nop,
   output                         frn_fdis_iu6_i1_rte_lq,
   output                         frn_fdis_iu6_i1_rte_sq,
   output                         frn_fdis_iu6_i1_rte_fx0,
   output                         frn_fdis_iu6_i1_rte_fx1,
   output                         frn_fdis_iu6_i1_rte_axu0,
   output                         frn_fdis_iu6_i1_rte_axu1,
   output                         frn_fdis_iu6_i1_valop,
   output                         frn_fdis_iu6_i1_ord,
   output                         frn_fdis_iu6_i1_cord,
   output [0:2]                   frn_fdis_iu6_i1_error,
   output                         frn_fdis_iu6_i1_btb_entry,
   output [0:1]                   frn_fdis_iu6_i1_btb_hist,
   output                         frn_fdis_iu6_i1_bta_val,
   output [0:19]                  frn_fdis_iu6_i1_fusion,
   output                         frn_fdis_iu6_i1_spec,
   output                         frn_fdis_iu6_i1_type_fp,
   output                         frn_fdis_iu6_i1_type_ap,
   output                         frn_fdis_iu6_i1_type_spv,
   output                         frn_fdis_iu6_i1_type_st,
   output                         frn_fdis_iu6_i1_async_block,
   output                         frn_fdis_iu6_i1_np1_flush,
   output                         frn_fdis_iu6_i1_core_block,
   output                         frn_fdis_iu6_i1_isram,
   output                         frn_fdis_iu6_i1_isload,
   output                         frn_fdis_iu6_i1_isstore,
   output [0:31]                  frn_fdis_iu6_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]  frn_fdis_iu6_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]  frn_fdis_iu6_i1_bta,
   output                         frn_fdis_iu6_i1_br_pred,
   output                         frn_fdis_iu6_i1_bh_update,
   output [0:1]                   frn_fdis_iu6_i1_bh0_hist,
   output [0:1]                   frn_fdis_iu6_i1_bh1_hist,
   output [0:1]                   frn_fdis_iu6_i1_bh2_hist,
   output [0:17]                   frn_fdis_iu6_i1_gshare,
   output [0:2]                   frn_fdis_iu6_i1_ls_ptr,
   output                         frn_fdis_iu6_i1_match,
   output [0:3]                   frn_fdis_iu6_i1_ilat,
   output                         frn_fdis_iu6_i1_t1_v,
   output [0:2]                   frn_fdis_iu6_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t1_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t1_p,
   output                         frn_fdis_iu6_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t2_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t2_p,
   output [0:2]                   frn_fdis_iu6_i1_t2_t,
   output                         frn_fdis_iu6_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t3_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_t3_p,
   output [0:2]                   frn_fdis_iu6_i1_t3_t,
   output                         frn_fdis_iu6_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s1_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s1_p,
   output [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_i1_s1_itag,
   output [0:2]                   frn_fdis_iu6_i1_s1_t,
   output                         frn_fdis_iu6_i1_s1_dep_hit,
   output                         frn_fdis_iu6_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s2_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s2_p,
   output [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_i1_s2_itag,
   output [0:2]                   frn_fdis_iu6_i1_s2_t,
   output                         frn_fdis_iu6_i1_s2_dep_hit,
   output                         frn_fdis_iu6_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s3_a,
   output [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_i1_s3_p,
   output [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_i1_s3_itag,
   output [0:2]                   frn_fdis_iu6_i1_s3_t,
   output                         frn_fdis_iu6_i1_s3_dep_hit

   );

   localparam [0:31]					value_1 = 32'h00000001;
   localparam [0:31]					value_2 = 32'h00000002;

   parameter                      next_itag_0_offset = 0;
   parameter                      next_itag_1_offset = next_itag_0_offset + `ITAG_SIZE_ENC;
   parameter                      cp_high_credit_cnt_offset = next_itag_1_offset + `ITAG_SIZE_ENC;
   parameter                      cp_med_credit_cnt_offset = cp_high_credit_cnt_offset + `CPL_Q_DEPTH_ENC + 1;
   parameter                      ucode_cnt_offset = cp_med_credit_cnt_offset + `CPL_Q_DEPTH_ENC + 1;
   parameter                      ucode_cnt_save_offset = ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                      cp_flush_offset = ucode_cnt_save_offset + `UCODE_ENTRIES_ENC;
   parameter                      cp_flush_into_uc_offset = cp_flush_offset + 1;
   parameter                      br_iu_hold_offset = cp_flush_into_uc_offset + 1;
   parameter                      cp_rn_empty_offset = br_iu_hold_offset + 1;
   parameter                      hold_instructions_offset = cp_rn_empty_offset + 1;
   parameter                      high_pri_mask_offset = hold_instructions_offset + 1;

   parameter                      fdis_frn_iu6_stall_offset = high_pri_mask_offset + 1;

   parameter                      frn_fdis_iu6_i0_vld_offset = fdis_frn_iu6_stall_offset + 19;
   parameter                      frn_fdis_iu6_i0_itag_offset = frn_fdis_iu6_i0_vld_offset + 1;
   parameter                      frn_fdis_iu6_i0_ucode_offset = frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i0_ucode_cnt_offset = frn_fdis_iu6_i0_ucode_offset + 3;
   parameter                      frn_fdis_iu6_i0_2ucode_offset = frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                      frn_fdis_iu6_i0_fuse_nop_offset = frn_fdis_iu6_i0_2ucode_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_lq_offset = frn_fdis_iu6_i0_fuse_nop_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_sq_offset = frn_fdis_iu6_i0_rte_lq_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_fx0_offset = frn_fdis_iu6_i0_rte_sq_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_fx1_offset = frn_fdis_iu6_i0_rte_fx0_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_axu0_offset = frn_fdis_iu6_i0_rte_fx1_offset + 1;
   parameter                      frn_fdis_iu6_i0_rte_axu1_offset = frn_fdis_iu6_i0_rte_axu0_offset + 1;
   parameter                      frn_fdis_iu6_i0_valop_offset = frn_fdis_iu6_i0_rte_axu1_offset + 1;
   parameter                      frn_fdis_iu6_i0_ord_offset = frn_fdis_iu6_i0_valop_offset + 1;
   parameter                      frn_fdis_iu6_i0_cord_offset = frn_fdis_iu6_i0_ord_offset + 1;
   parameter                      frn_fdis_iu6_i0_error_offset = frn_fdis_iu6_i0_cord_offset + 1;
   parameter                      frn_fdis_iu6_i0_btb_entry_offset = frn_fdis_iu6_i0_error_offset + 3;
   parameter                      frn_fdis_iu6_i0_btb_hist_offset = frn_fdis_iu6_i0_btb_entry_offset + 1;
   parameter                      frn_fdis_iu6_i0_bta_val_offset = frn_fdis_iu6_i0_btb_hist_offset + 2;
   parameter                      frn_fdis_iu6_i0_fusion_offset = frn_fdis_iu6_i0_bta_val_offset + 1;
   parameter                      frn_fdis_iu6_i0_spec_offset = frn_fdis_iu6_i0_fusion_offset + 20;
   parameter                      frn_fdis_iu6_i0_type_fp_offset = frn_fdis_iu6_i0_spec_offset + 1;
   parameter                      frn_fdis_iu6_i0_type_ap_offset = frn_fdis_iu6_i0_type_fp_offset + 1;
   parameter                      frn_fdis_iu6_i0_type_spv_offset = frn_fdis_iu6_i0_type_ap_offset + 1;
   parameter                      frn_fdis_iu6_i0_type_st_offset = frn_fdis_iu6_i0_type_spv_offset + 1;
   parameter                      frn_fdis_iu6_i0_async_block_offset = frn_fdis_iu6_i0_type_st_offset + 1;
   parameter                      frn_fdis_iu6_i0_np1_flush_offset = frn_fdis_iu6_i0_async_block_offset + 1;
   parameter                      frn_fdis_iu6_i0_core_block_offset = frn_fdis_iu6_i0_np1_flush_offset + 1;
   parameter                      frn_fdis_iu6_i0_isram_offset = frn_fdis_iu6_i0_core_block_offset + 1;
   parameter                      frn_fdis_iu6_i0_isload_offset = frn_fdis_iu6_i0_isram_offset + 1;
   parameter                      frn_fdis_iu6_i0_isstore_offset = frn_fdis_iu6_i0_isload_offset + 1;
   parameter                      frn_fdis_iu6_i0_instr_offset = frn_fdis_iu6_i0_isstore_offset + 1;
   parameter                      frn_fdis_iu6_i0_ifar_offset = frn_fdis_iu6_i0_instr_offset + 32;
   parameter                      frn_fdis_iu6_i0_bta_offset = frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH);
   parameter                      frn_fdis_iu6_i0_br_pred_offset = frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH);
   parameter                      frn_fdis_iu6_i0_bh_update_offset = frn_fdis_iu6_i0_br_pred_offset + 1;
   parameter                      frn_fdis_iu6_i0_bh0_hist_offset = frn_fdis_iu6_i0_bh_update_offset + 1;
   parameter                      frn_fdis_iu6_i0_bh1_hist_offset = frn_fdis_iu6_i0_bh0_hist_offset + 2;
   parameter                      frn_fdis_iu6_i0_bh2_hist_offset = frn_fdis_iu6_i0_bh1_hist_offset + 2;
   parameter                      frn_fdis_iu6_i0_gshare_offset = frn_fdis_iu6_i0_bh2_hist_offset + 2;
   parameter                      frn_fdis_iu6_i0_ls_ptr_offset = frn_fdis_iu6_i0_gshare_offset + 18;
   parameter                      frn_fdis_iu6_i0_match_offset = frn_fdis_iu6_i0_ls_ptr_offset + 3;
   parameter                      frn_fdis_iu6_i0_ilat_offset = frn_fdis_iu6_i0_match_offset + 1;
   parameter                      frn_fdis_iu6_i0_t1_v_offset = frn_fdis_iu6_i0_ilat_offset + 4;
   parameter                      frn_fdis_iu6_i0_t1_t_offset = frn_fdis_iu6_i0_t1_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_t1_a_offset = frn_fdis_iu6_i0_t1_t_offset + 3;
   parameter                      frn_fdis_iu6_i0_t1_p_offset = frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_t2_v_offset = frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_t2_a_offset = frn_fdis_iu6_i0_t2_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_t2_p_offset = frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_t2_t_offset = frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_t3_v_offset = frn_fdis_iu6_i0_t2_t_offset + 3;
   parameter                      frn_fdis_iu6_i0_t3_a_offset = frn_fdis_iu6_i0_t3_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_t3_p_offset = frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_t3_t_offset = frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s1_v_offset = frn_fdis_iu6_i0_t3_t_offset + 3;
   parameter                      frn_fdis_iu6_i0_s1_a_offset = frn_fdis_iu6_i0_s1_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_s1_p_offset = frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s1_itag_offset = frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s1_t_offset = frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i0_s2_v_offset = frn_fdis_iu6_i0_s1_t_offset + 3;
   parameter                      frn_fdis_iu6_i0_s2_a_offset = frn_fdis_iu6_i0_s2_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_s2_p_offset = frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s2_itag_offset = frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s2_t_offset = frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i0_s3_v_offset = frn_fdis_iu6_i0_s2_t_offset + 3;
   parameter                      frn_fdis_iu6_i0_s3_a_offset = frn_fdis_iu6_i0_s3_v_offset + 1;
   parameter                      frn_fdis_iu6_i0_s3_p_offset = frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s3_itag_offset = frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i0_s3_t_offset = frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i1_vld_offset = frn_fdis_iu6_i0_s3_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_itag_offset = frn_fdis_iu6_i1_vld_offset + 1;
   parameter                      frn_fdis_iu6_i1_ucode_offset = frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i1_ucode_cnt_offset = frn_fdis_iu6_i1_ucode_offset + 3;
   parameter                      frn_fdis_iu6_i1_fuse_nop_offset = frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                      frn_fdis_iu6_i1_rte_lq_offset = frn_fdis_iu6_i1_fuse_nop_offset + 1;
   parameter                      frn_fdis_iu6_i1_rte_sq_offset = frn_fdis_iu6_i1_rte_lq_offset + 1;
   parameter                      frn_fdis_iu6_i1_rte_fx0_offset = frn_fdis_iu6_i1_rte_sq_offset + 1;
   parameter                      frn_fdis_iu6_i1_rte_fx1_offset = frn_fdis_iu6_i1_rte_fx0_offset + 1;
   parameter                      frn_fdis_iu6_i1_rte_axu0_offset = frn_fdis_iu6_i1_rte_fx1_offset + 1;
   parameter                      frn_fdis_iu6_i1_rte_axu1_offset = frn_fdis_iu6_i1_rte_axu0_offset + 1;
   parameter                      frn_fdis_iu6_i1_valop_offset = frn_fdis_iu6_i1_rte_axu1_offset + 1;
   parameter                      frn_fdis_iu6_i1_ord_offset = frn_fdis_iu6_i1_valop_offset + 1;
   parameter                      frn_fdis_iu6_i1_cord_offset = frn_fdis_iu6_i1_ord_offset + 1;
   parameter                      frn_fdis_iu6_i1_error_offset = frn_fdis_iu6_i1_cord_offset + 1;
   parameter                      frn_fdis_iu6_i1_btb_entry_offset = frn_fdis_iu6_i1_error_offset + 3;
   parameter                      frn_fdis_iu6_i1_btb_hist_offset = frn_fdis_iu6_i1_btb_entry_offset + 1;
   parameter                      frn_fdis_iu6_i1_bta_val_offset = frn_fdis_iu6_i1_btb_hist_offset + 2;
   parameter                      frn_fdis_iu6_i1_fusion_offset = frn_fdis_iu6_i1_bta_val_offset + 1;
   parameter                      frn_fdis_iu6_i1_spec_offset = frn_fdis_iu6_i1_fusion_offset + 20;
   parameter                      frn_fdis_iu6_i1_type_fp_offset = frn_fdis_iu6_i1_spec_offset + 1;
   parameter                      frn_fdis_iu6_i1_type_ap_offset = frn_fdis_iu6_i1_type_fp_offset + 1;
   parameter                      frn_fdis_iu6_i1_type_spv_offset = frn_fdis_iu6_i1_type_ap_offset + 1;
   parameter                      frn_fdis_iu6_i1_type_st_offset = frn_fdis_iu6_i1_type_spv_offset + 1;
   parameter                      frn_fdis_iu6_i1_async_block_offset = frn_fdis_iu6_i1_type_st_offset + 1;
   parameter                      frn_fdis_iu6_i1_np1_flush_offset = frn_fdis_iu6_i1_async_block_offset + 1;
   parameter                      frn_fdis_iu6_i1_core_block_offset = frn_fdis_iu6_i1_np1_flush_offset + 1;
   parameter                      frn_fdis_iu6_i1_isram_offset = frn_fdis_iu6_i1_core_block_offset + 1;
   parameter                      frn_fdis_iu6_i1_isload_offset = frn_fdis_iu6_i1_isram_offset + 1;
   parameter                      frn_fdis_iu6_i1_isstore_offset = frn_fdis_iu6_i1_isload_offset + 1;
   parameter                      frn_fdis_iu6_i1_instr_offset = frn_fdis_iu6_i1_isstore_offset + 1;
   parameter                      frn_fdis_iu6_i1_ifar_offset = frn_fdis_iu6_i1_instr_offset + 32;
   parameter                      frn_fdis_iu6_i1_bta_offset = frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH);
   parameter                      frn_fdis_iu6_i1_br_pred_offset = frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH);
   parameter                      frn_fdis_iu6_i1_bh_update_offset = frn_fdis_iu6_i1_br_pred_offset + 1;
   parameter                      frn_fdis_iu6_i1_bh0_hist_offset = frn_fdis_iu6_i1_bh_update_offset + 1;
   parameter                      frn_fdis_iu6_i1_bh1_hist_offset = frn_fdis_iu6_i1_bh0_hist_offset + 2;
   parameter                      frn_fdis_iu6_i1_bh2_hist_offset = frn_fdis_iu6_i1_bh1_hist_offset + 2;
   parameter                      frn_fdis_iu6_i1_gshare_offset = frn_fdis_iu6_i1_bh2_hist_offset + 2;
   parameter                      frn_fdis_iu6_i1_ls_ptr_offset = frn_fdis_iu6_i1_gshare_offset + 18;
   parameter                      frn_fdis_iu6_i1_match_offset = frn_fdis_iu6_i1_ls_ptr_offset + 3;
   parameter                      frn_fdis_iu6_i1_ilat_offset = frn_fdis_iu6_i1_match_offset + 1;
   parameter                      frn_fdis_iu6_i1_t1_v_offset = frn_fdis_iu6_i1_ilat_offset + 4;
   parameter                      frn_fdis_iu6_i1_t1_t_offset = frn_fdis_iu6_i1_t1_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_t1_a_offset = frn_fdis_iu6_i1_t1_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_t1_p_offset = frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_t2_v_offset = frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_t2_a_offset = frn_fdis_iu6_i1_t2_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_t2_p_offset = frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_t2_t_offset = frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_t3_v_offset = frn_fdis_iu6_i1_t2_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_t3_a_offset = frn_fdis_iu6_i1_t3_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_t3_p_offset = frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_t3_t_offset = frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s1_v_offset = frn_fdis_iu6_i1_t3_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_s1_a_offset = frn_fdis_iu6_i1_s1_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_s1_p_offset = frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s1_itag_offset = frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s1_t_offset = frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i1_s1_dep_hit_offset = frn_fdis_iu6_i1_s1_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_s2_v_offset = frn_fdis_iu6_i1_s1_dep_hit_offset + 1;
   parameter                      frn_fdis_iu6_i1_s2_a_offset = frn_fdis_iu6_i1_s2_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_s2_p_offset = frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s2_itag_offset = frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s2_t_offset = frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i1_s2_dep_hit_offset = frn_fdis_iu6_i1_s2_t_offset + 3;
   parameter                      frn_fdis_iu6_i1_s3_v_offset = frn_fdis_iu6_i1_s2_dep_hit_offset + 1;
   parameter                      frn_fdis_iu6_i1_s3_a_offset = frn_fdis_iu6_i1_s3_v_offset + 1;
   parameter                      frn_fdis_iu6_i1_s3_p_offset = frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s3_itag_offset = frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC;
   parameter                      frn_fdis_iu6_i1_s3_t_offset = frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                      frn_fdis_iu6_i1_s3_dep_hit_offset = frn_fdis_iu6_i1_s3_t_offset + 3;

   parameter                      stall_frn_fdis_iu6_i0_vld_offset = frn_fdis_iu6_i1_s3_dep_hit_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_itag_offset = stall_frn_fdis_iu6_i0_vld_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_ucode_offset = stall_frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i0_ucode_cnt_offset = stall_frn_fdis_iu6_i0_ucode_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_fuse_nop_offset = stall_frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                      stall_frn_fdis_iu6_i0_2ucode_offset = stall_frn_fdis_iu6_i0_fuse_nop_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_lq_offset = stall_frn_fdis_iu6_i0_2ucode_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_sq_offset = stall_frn_fdis_iu6_i0_rte_lq_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_fx0_offset = stall_frn_fdis_iu6_i0_rte_sq_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_fx1_offset = stall_frn_fdis_iu6_i0_rte_fx0_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_axu0_offset = stall_frn_fdis_iu6_i0_rte_fx1_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_rte_axu1_offset = stall_frn_fdis_iu6_i0_rte_axu0_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_valop_offset = stall_frn_fdis_iu6_i0_rte_axu1_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_ord_offset = stall_frn_fdis_iu6_i0_valop_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_cord_offset = stall_frn_fdis_iu6_i0_ord_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_error_offset = stall_frn_fdis_iu6_i0_cord_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_btb_entry_offset = stall_frn_fdis_iu6_i0_error_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_btb_hist_offset = stall_frn_fdis_iu6_i0_btb_entry_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_bta_val_offset = stall_frn_fdis_iu6_i0_btb_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i0_fusion_offset = stall_frn_fdis_iu6_i0_bta_val_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_spec_offset = stall_frn_fdis_iu6_i0_fusion_offset + 20;
   parameter                      stall_frn_fdis_iu6_i0_type_fp_offset = stall_frn_fdis_iu6_i0_spec_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_type_ap_offset = stall_frn_fdis_iu6_i0_type_fp_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_type_spv_offset = stall_frn_fdis_iu6_i0_type_ap_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_type_st_offset = stall_frn_fdis_iu6_i0_type_spv_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_async_block_offset = stall_frn_fdis_iu6_i0_type_st_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_np1_flush_offset = stall_frn_fdis_iu6_i0_async_block_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_core_block_offset = stall_frn_fdis_iu6_i0_np1_flush_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_isram_offset = stall_frn_fdis_iu6_i0_core_block_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_isload_offset = stall_frn_fdis_iu6_i0_isram_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_isstore_offset = stall_frn_fdis_iu6_i0_isload_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_instr_offset = stall_frn_fdis_iu6_i0_isstore_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_ifar_offset = stall_frn_fdis_iu6_i0_instr_offset + 32;
   parameter                      stall_frn_fdis_iu6_i0_bta_offset = stall_frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH);
   parameter                      stall_frn_fdis_iu6_i0_br_pred_offset = stall_frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH);
   parameter                      stall_frn_fdis_iu6_i0_bh_update_offset = stall_frn_fdis_iu6_i0_br_pred_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_bh0_hist_offset = stall_frn_fdis_iu6_i0_bh_update_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_bh1_hist_offset = stall_frn_fdis_iu6_i0_bh0_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i0_bh2_hist_offset = stall_frn_fdis_iu6_i0_bh1_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i0_gshare_offset = stall_frn_fdis_iu6_i0_bh2_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i0_ls_ptr_offset = stall_frn_fdis_iu6_i0_gshare_offset + 18;
   parameter                      stall_frn_fdis_iu6_i0_match_offset = stall_frn_fdis_iu6_i0_ls_ptr_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_ilat_offset = stall_frn_fdis_iu6_i0_match_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_t1_v_offset = stall_frn_fdis_iu6_i0_ilat_offset + 4;
   parameter                      stall_frn_fdis_iu6_i0_t1_t_offset = stall_frn_fdis_iu6_i0_t1_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_t1_a_offset = stall_frn_fdis_iu6_i0_t1_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_t1_p_offset = stall_frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_t2_v_offset = stall_frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_t2_a_offset = stall_frn_fdis_iu6_i0_t2_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_t2_p_offset = stall_frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_t2_t_offset = stall_frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_t3_v_offset = stall_frn_fdis_iu6_i0_t2_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_t3_a_offset = stall_frn_fdis_iu6_i0_t3_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_t3_p_offset = stall_frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_t3_t_offset = stall_frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s1_v_offset = stall_frn_fdis_iu6_i0_t3_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_s1_a_offset = stall_frn_fdis_iu6_i0_s1_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_s1_p_offset = stall_frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s1_itag_offset = stall_frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s1_t_offset = stall_frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s2_v_offset = stall_frn_fdis_iu6_i0_s1_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_s2_a_offset = stall_frn_fdis_iu6_i0_s2_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_s2_p_offset = stall_frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s2_itag_offset = stall_frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s2_t_offset = stall_frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s3_v_offset = stall_frn_fdis_iu6_i0_s2_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i0_s3_a_offset = stall_frn_fdis_iu6_i0_s3_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i0_s3_p_offset = stall_frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s3_itag_offset = stall_frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i0_s3_t_offset = stall_frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i1_vld_offset = stall_frn_fdis_iu6_i0_s3_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_itag_offset = stall_frn_fdis_iu6_i1_vld_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_ucode_offset = stall_frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i1_ucode_cnt_offset = stall_frn_fdis_iu6_i1_ucode_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_fuse_nop_offset = stall_frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC;
   parameter                      stall_frn_fdis_iu6_i1_rte_lq_offset = stall_frn_fdis_iu6_i1_fuse_nop_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_rte_sq_offset = stall_frn_fdis_iu6_i1_rte_lq_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_rte_fx0_offset = stall_frn_fdis_iu6_i1_rte_sq_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_rte_fx1_offset = stall_frn_fdis_iu6_i1_rte_fx0_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_rte_axu0_offset = stall_frn_fdis_iu6_i1_rte_fx1_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_rte_axu1_offset = stall_frn_fdis_iu6_i1_rte_axu0_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_valop_offset = stall_frn_fdis_iu6_i1_rte_axu1_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_ord_offset = stall_frn_fdis_iu6_i1_valop_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_cord_offset = stall_frn_fdis_iu6_i1_ord_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_error_offset = stall_frn_fdis_iu6_i1_cord_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_btb_entry_offset = stall_frn_fdis_iu6_i1_error_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_btb_hist_offset = stall_frn_fdis_iu6_i1_btb_entry_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_bta_val_offset = stall_frn_fdis_iu6_i1_btb_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i1_fusion_offset = stall_frn_fdis_iu6_i1_bta_val_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_spec_offset = stall_frn_fdis_iu6_i1_fusion_offset + 20;
   parameter                      stall_frn_fdis_iu6_i1_type_fp_offset = stall_frn_fdis_iu6_i1_spec_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_type_ap_offset = stall_frn_fdis_iu6_i1_type_fp_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_type_spv_offset = stall_frn_fdis_iu6_i1_type_ap_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_type_st_offset = stall_frn_fdis_iu6_i1_type_spv_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_async_block_offset = stall_frn_fdis_iu6_i1_type_st_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_np1_flush_offset = stall_frn_fdis_iu6_i1_async_block_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_core_block_offset = stall_frn_fdis_iu6_i1_np1_flush_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_isram_offset = stall_frn_fdis_iu6_i1_core_block_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_isload_offset = stall_frn_fdis_iu6_i1_isram_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_isstore_offset = stall_frn_fdis_iu6_i1_isload_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_instr_offset = stall_frn_fdis_iu6_i1_isstore_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_ifar_offset = stall_frn_fdis_iu6_i1_instr_offset + 32;
   parameter                      stall_frn_fdis_iu6_i1_bta_offset = stall_frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH);
   parameter                      stall_frn_fdis_iu6_i1_br_pred_offset = stall_frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH);
   parameter                      stall_frn_fdis_iu6_i1_bh_update_offset = stall_frn_fdis_iu6_i1_br_pred_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_bh0_hist_offset = stall_frn_fdis_iu6_i1_bh_update_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_bh1_hist_offset = stall_frn_fdis_iu6_i1_bh0_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i1_bh2_hist_offset = stall_frn_fdis_iu6_i1_bh1_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i1_gshare_offset = stall_frn_fdis_iu6_i1_bh2_hist_offset + 2;
   parameter                      stall_frn_fdis_iu6_i1_ls_ptr_offset = stall_frn_fdis_iu6_i1_gshare_offset + 18;
   parameter                      stall_frn_fdis_iu6_i1_match_offset = stall_frn_fdis_iu6_i1_ls_ptr_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_ilat_offset = stall_frn_fdis_iu6_i1_match_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_t1_v_offset = stall_frn_fdis_iu6_i1_ilat_offset + 4;
   parameter                      stall_frn_fdis_iu6_i1_t1_t_offset = stall_frn_fdis_iu6_i1_t1_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_t1_a_offset = stall_frn_fdis_iu6_i1_t1_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_t1_p_offset = stall_frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_t2_v_offset = stall_frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_t2_a_offset = stall_frn_fdis_iu6_i1_t2_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_t2_p_offset = stall_frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_t2_t_offset = stall_frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_t3_v_offset = stall_frn_fdis_iu6_i1_t2_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_t3_a_offset = stall_frn_fdis_iu6_i1_t3_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_t3_p_offset = stall_frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_t3_t_offset = stall_frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s1_v_offset = stall_frn_fdis_iu6_i1_t3_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_s1_a_offset = stall_frn_fdis_iu6_i1_s1_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_s1_p_offset = stall_frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s1_itag_offset = stall_frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s1_t_offset = stall_frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s1_dep_hit_offset = stall_frn_fdis_iu6_i1_s1_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_s2_v_offset = stall_frn_fdis_iu6_i1_s1_dep_hit_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_s2_a_offset = stall_frn_fdis_iu6_i1_s2_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_s2_p_offset = stall_frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s2_itag_offset = stall_frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s2_t_offset = stall_frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s2_dep_hit_offset = stall_frn_fdis_iu6_i1_s2_t_offset + 3;
   parameter                      stall_frn_fdis_iu6_i1_s3_v_offset = stall_frn_fdis_iu6_i1_s2_dep_hit_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_s3_a_offset = stall_frn_fdis_iu6_i1_s3_v_offset + 1;
   parameter                      stall_frn_fdis_iu6_i1_s3_p_offset = stall_frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s3_itag_offset = stall_frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s3_t_offset = stall_frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC;
   parameter                      stall_frn_fdis_iu6_i1_s3_dep_hit_offset = stall_frn_fdis_iu6_i1_s3_t_offset + 3;
   parameter                      perf_iu5_stall_offset = stall_frn_fdis_iu6_i1_s3_dep_hit_offset + 1;
   parameter                      perf_iu5_cpl_credit_stall_offset = perf_iu5_stall_offset + 1;
   parameter                      perf_iu5_gpr_credit_stall_offset = perf_iu5_cpl_credit_stall_offset + 1;
   parameter                      perf_iu5_cr_credit_stall_offset = perf_iu5_gpr_credit_stall_offset + 1;
   parameter                      perf_iu5_lr_credit_stall_offset = perf_iu5_cr_credit_stall_offset + 1;
   parameter                      perf_iu5_ctr_credit_stall_offset = perf_iu5_lr_credit_stall_offset + 1;
   parameter                      perf_iu5_xer_credit_stall_offset = perf_iu5_ctr_credit_stall_offset + 1;
   parameter                      perf_iu5_br_hold_stall_offset = perf_iu5_xer_credit_stall_offset + 1;
   parameter                      perf_iu5_axu_hold_stall_offset = perf_iu5_br_hold_stall_offset + 1;
   parameter                      scan_right = perf_iu5_axu_hold_stall_offset + 1 - 1;


   // scan
   wire [0:scan_right]            siv;
   wire [0:scan_right]            sov;
   wire [0:4]                     map_siv;
   wire [0:4]                     map_sov;

   wire                           tidn;
   wire                           tiup;

   // iu6 latches
   wire                           frn_fdis_iu6_i0_act;
   wire                           frn_fdis_iu6_i0_vld_d;
   wire                           frn_fdis_iu6_i0_vld_l2;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i0_ucode_d;
   wire [0:2]                     frn_fdis_iu6_i0_ucode_l2;
   wire [0:`UCODE_ENTRIES_ENC-1]   frn_fdis_iu6_i0_ucode_cnt_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   frn_fdis_iu6_i0_ucode_cnt_l2;
   wire                           frn_fdis_iu6_i0_2ucode_d;
   wire                           frn_fdis_iu6_i0_2ucode_l2;
   wire                           frn_fdis_iu6_i0_fuse_nop_d;
   wire                           frn_fdis_iu6_i0_fuse_nop_l2;
   wire                           frn_fdis_iu6_i0_rte_lq_d;
   wire                           frn_fdis_iu6_i0_rte_lq_l2;
   wire                           frn_fdis_iu6_i0_rte_sq_d;
   wire                           frn_fdis_iu6_i0_rte_sq_l2;
   wire                           frn_fdis_iu6_i0_rte_fx0_d;
   wire                           frn_fdis_iu6_i0_rte_fx0_l2;
   wire                           frn_fdis_iu6_i0_rte_fx1_d;
   wire                           frn_fdis_iu6_i0_rte_fx1_l2;
   wire                           frn_fdis_iu6_i0_rte_axu0_d;
   wire                           frn_fdis_iu6_i0_rte_axu0_l2;
   wire                           frn_fdis_iu6_i0_rte_axu1_d;
   wire                           frn_fdis_iu6_i0_rte_axu1_l2;
   wire                           frn_fdis_iu6_i0_valop_d;
   wire                           frn_fdis_iu6_i0_valop_l2;
   wire                           frn_fdis_iu6_i0_ord_d;
   wire                           frn_fdis_iu6_i0_ord_l2;
   wire                           frn_fdis_iu6_i0_cord_d;
   wire                           frn_fdis_iu6_i0_cord_l2;
   wire [0:2]                     frn_fdis_iu6_i0_error_d;
   wire [0:2]                     frn_fdis_iu6_i0_error_l2;
   wire                           frn_fdis_iu6_i0_btb_entry_d;
   wire                           frn_fdis_iu6_i0_btb_entry_l2;
   wire [0:1]                     frn_fdis_iu6_i0_btb_hist_d;
   wire [0:1]                     frn_fdis_iu6_i0_btb_hist_l2;
   wire                           frn_fdis_iu6_i0_bta_val_d;
   wire                           frn_fdis_iu6_i0_bta_val_l2;
   wire [0:19]                    frn_fdis_iu6_i0_fusion_d;
   wire [0:19]                    frn_fdis_iu6_i0_fusion_l2;
   wire                           frn_fdis_iu6_i0_spec_d;
   wire                           frn_fdis_iu6_i0_spec_l2;
   wire                           frn_fdis_iu6_i0_type_fp_d;
   wire                           frn_fdis_iu6_i0_type_fp_l2;
   wire                           frn_fdis_iu6_i0_type_ap_d;
   wire                           frn_fdis_iu6_i0_type_ap_l2;
   wire                           frn_fdis_iu6_i0_type_spv_d;
   wire                           frn_fdis_iu6_i0_type_spv_l2;
   wire                           frn_fdis_iu6_i0_type_st_d;
   wire                           frn_fdis_iu6_i0_type_st_l2;
   wire                           frn_fdis_iu6_i0_async_block_d;
   wire                           frn_fdis_iu6_i0_async_block_l2;
   wire                           frn_fdis_iu6_i0_np1_flush_d;
   wire                           frn_fdis_iu6_i0_np1_flush_l2;
   wire                           frn_fdis_iu6_i0_core_block_d;
   wire                           frn_fdis_iu6_i0_core_block_l2;
   wire                           frn_fdis_iu6_i0_isram_d;
   wire                           frn_fdis_iu6_i0_isram_l2;
   wire                           frn_fdis_iu6_i0_isload_d;
   wire                           frn_fdis_iu6_i0_isload_l2;
   wire                           frn_fdis_iu6_i0_isstore_d;
   wire                           frn_fdis_iu6_i0_isstore_l2;
   wire [0:31]                    frn_fdis_iu6_i0_instr_d;
   wire [0:31]                    frn_fdis_iu6_i0_instr_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i0_ifar_d;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i0_ifar_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i0_bta_d;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i0_bta_l2;
   wire                           frn_fdis_iu6_i0_br_pred_d;
   wire                           frn_fdis_iu6_i0_br_pred_l2;
   wire                           frn_fdis_iu6_i0_bh_update_d;
   wire                           frn_fdis_iu6_i0_bh_update_l2;
   wire [0:1]                     frn_fdis_iu6_i0_bh0_hist_d;
   wire [0:1]                     frn_fdis_iu6_i0_bh0_hist_l2;
   wire [0:1]                     frn_fdis_iu6_i0_bh1_hist_d;
   wire [0:1]                     frn_fdis_iu6_i0_bh1_hist_l2;
   wire [0:1]                     frn_fdis_iu6_i0_bh2_hist_d;
   wire [0:1]                     frn_fdis_iu6_i0_bh2_hist_l2;
   wire [0:17]                     frn_fdis_iu6_i0_gshare_d;
   wire [0:17]                     frn_fdis_iu6_i0_gshare_l2;
   wire [0:2]                     frn_fdis_iu6_i0_ls_ptr_d;
   wire [0:2]                     frn_fdis_iu6_i0_ls_ptr_l2;
   wire                           frn_fdis_iu6_i0_match_d;
   wire                           frn_fdis_iu6_i0_match_l2;
   wire [0:3]                     frn_fdis_iu6_i0_ilat_d;
   wire [0:3]                     frn_fdis_iu6_i0_ilat_l2;
   wire                           frn_fdis_iu6_i0_t1_v_d;
   wire                           frn_fdis_iu6_i0_t1_v_l2;
   wire [0:2]                     frn_fdis_iu6_i0_t1_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_t1_t_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t1_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t1_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t1_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t1_p_l2;
   wire                           frn_fdis_iu6_i0_t2_v_d;
   wire                           frn_fdis_iu6_i0_t2_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t2_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t2_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t2_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t2_p_l2;
   wire [0:2]                     frn_fdis_iu6_i0_t2_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_t2_t_l2;
   wire                           frn_fdis_iu6_i0_t3_v_d;
   wire                           frn_fdis_iu6_i0_t3_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t3_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t3_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t3_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_t3_p_l2;
   wire [0:2]                     frn_fdis_iu6_i0_t3_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_t3_t_l2;
   wire                           frn_fdis_iu6_i0_s1_v_d;
   wire                           frn_fdis_iu6_i0_s1_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s1_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s1_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s1_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s1_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s1_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i0_s1_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_s1_t_l2;
   wire                           frn_fdis_iu6_i0_s2_v_d;
   wire                           frn_fdis_iu6_i0_s2_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s2_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s2_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s2_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s2_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s2_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i0_s2_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_s2_t_l2;
   wire                           frn_fdis_iu6_i0_s3_v_d;
   wire                           frn_fdis_iu6_i0_s3_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s3_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s3_a_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s3_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i0_s3_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i0_s3_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i0_s3_t_d;
   wire [0:2]                     frn_fdis_iu6_i0_s3_t_l2;
   wire                           frn_fdis_iu6_i1_act;
   wire                           frn_fdis_iu6_i1_vld_d;
   wire                           frn_fdis_iu6_i1_vld_l2;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       frn_fdis_iu6_i1_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i1_ucode_d;
   wire [0:2]                     frn_fdis_iu6_i1_ucode_l2;
   wire [0:`UCODE_ENTRIES_ENC-1]   frn_fdis_iu6_i1_ucode_cnt_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   frn_fdis_iu6_i1_ucode_cnt_l2;
   wire                           frn_fdis_iu6_i1_fuse_nop_d;
   wire                           frn_fdis_iu6_i1_fuse_nop_l2;
   wire                           frn_fdis_iu6_i1_rte_lq_d;
   wire                           frn_fdis_iu6_i1_rte_lq_l2;
   wire                           frn_fdis_iu6_i1_rte_sq_d;
   wire                           frn_fdis_iu6_i1_rte_sq_l2;
   wire                           frn_fdis_iu6_i1_rte_fx0_d;
   wire                           frn_fdis_iu6_i1_rte_fx0_l2;
   wire                           frn_fdis_iu6_i1_rte_fx1_d;
   wire                           frn_fdis_iu6_i1_rte_fx1_l2;
   wire                           frn_fdis_iu6_i1_rte_axu0_d;
   wire                           frn_fdis_iu6_i1_rte_axu0_l2;
   wire                           frn_fdis_iu6_i1_rte_axu1_d;
   wire                           frn_fdis_iu6_i1_rte_axu1_l2;
   wire                           frn_fdis_iu6_i1_valop_d;
   wire                           frn_fdis_iu6_i1_valop_l2;
   wire                           frn_fdis_iu6_i1_ord_d;
   wire                           frn_fdis_iu6_i1_ord_l2;
   wire                           frn_fdis_iu6_i1_cord_d;
   wire                           frn_fdis_iu6_i1_cord_l2;
   wire [0:2]                     frn_fdis_iu6_i1_error_d;
   wire [0:2]                     frn_fdis_iu6_i1_error_l2;
   wire                           frn_fdis_iu6_i1_btb_entry_d;
   wire                           frn_fdis_iu6_i1_btb_entry_l2;
   wire [0:1]                     frn_fdis_iu6_i1_btb_hist_d;
   wire [0:1]                     frn_fdis_iu6_i1_btb_hist_l2;
   wire                           frn_fdis_iu6_i1_bta_val_d;
   wire                           frn_fdis_iu6_i1_bta_val_l2;
   wire [0:19]                    frn_fdis_iu6_i1_fusion_d;
   wire [0:19]                    frn_fdis_iu6_i1_fusion_l2;
   wire                           frn_fdis_iu6_i1_spec_d;
   wire                           frn_fdis_iu6_i1_spec_l2;
   wire                           frn_fdis_iu6_i1_type_fp_d;
   wire                           frn_fdis_iu6_i1_type_fp_l2;
   wire                           frn_fdis_iu6_i1_type_ap_d;
   wire                           frn_fdis_iu6_i1_type_ap_l2;
   wire                           frn_fdis_iu6_i1_type_spv_d;
   wire                           frn_fdis_iu6_i1_type_spv_l2;
   wire                           frn_fdis_iu6_i1_type_st_d;
   wire                           frn_fdis_iu6_i1_type_st_l2;
   wire                           frn_fdis_iu6_i1_async_block_d;
   wire                           frn_fdis_iu6_i1_async_block_l2;
   wire                           frn_fdis_iu6_i1_np1_flush_d;
   wire                           frn_fdis_iu6_i1_np1_flush_l2;
   wire                           frn_fdis_iu6_i1_core_block_d;
   wire                           frn_fdis_iu6_i1_core_block_l2;
   wire                           frn_fdis_iu6_i1_isram_d;
   wire                           frn_fdis_iu6_i1_isram_l2;
   wire                           frn_fdis_iu6_i1_isload_d;
   wire                           frn_fdis_iu6_i1_isload_l2;
   wire                           frn_fdis_iu6_i1_isstore_d;
   wire                           frn_fdis_iu6_i1_isstore_l2;
   wire [0:31]                    frn_fdis_iu6_i1_instr_d;
   wire [0:31]                    frn_fdis_iu6_i1_instr_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i1_ifar_d;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i1_ifar_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i1_bta_d;
   wire [62-`EFF_IFAR_WIDTH:61]    frn_fdis_iu6_i1_bta_l2;
   wire                           frn_fdis_iu6_i1_br_pred_d;
   wire                           frn_fdis_iu6_i1_br_pred_l2;
   wire                           frn_fdis_iu6_i1_bh_update_d;
   wire                           frn_fdis_iu6_i1_bh_update_l2;
   wire [0:1]                     frn_fdis_iu6_i1_bh0_hist_d;
   wire [0:1]                     frn_fdis_iu6_i1_bh0_hist_l2;
   wire [0:1]                     frn_fdis_iu6_i1_bh1_hist_d;
   wire [0:1]                     frn_fdis_iu6_i1_bh1_hist_l2;
   wire [0:1]                     frn_fdis_iu6_i1_bh2_hist_d;
   wire [0:1]                     frn_fdis_iu6_i1_bh2_hist_l2;
   wire [0:17]                     frn_fdis_iu6_i1_gshare_d;
   wire [0:17]                     frn_fdis_iu6_i1_gshare_l2;
   wire [0:2]                     frn_fdis_iu6_i1_ls_ptr_d;
   wire [0:2]                     frn_fdis_iu6_i1_ls_ptr_l2;
   wire                           frn_fdis_iu6_i1_match_d;
   wire                           frn_fdis_iu6_i1_match_l2;
   wire [0:3]                     frn_fdis_iu6_i1_ilat_d;
   wire [0:3]                     frn_fdis_iu6_i1_ilat_l2;
   wire                           frn_fdis_iu6_i1_t1_v_d;
   wire                           frn_fdis_iu6_i1_t1_v_l2;
   wire [0:2]                     frn_fdis_iu6_i1_t1_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_t1_t_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t1_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t1_a_l2;
   reg [0:`GPR_POOL_ENC-1]         frn_fdis_iu6_i1_t1_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t1_p_l2;
   wire                           frn_fdis_iu6_i1_t2_v_d;
   wire                           frn_fdis_iu6_i1_t2_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t2_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t2_a_l2;
   reg [0:`GPR_POOL_ENC-1]         frn_fdis_iu6_i1_t2_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t2_p_l2;
   wire [0:2]                     frn_fdis_iu6_i1_t2_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_t2_t_l2;
   wire                           frn_fdis_iu6_i1_t3_v_d;
   wire                           frn_fdis_iu6_i1_t3_v_l2;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t3_a_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t3_a_l2;
   reg [0:`GPR_POOL_ENC-1]         frn_fdis_iu6_i1_t3_p_d;
   wire [0:`GPR_POOL_ENC-1]        frn_fdis_iu6_i1_t3_p_l2;
   wire [0:2]                     frn_fdis_iu6_i1_t3_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_t3_t_l2;
   wire                           frn_fdis_iu6_i1_s1_v_d;
   wire                           frn_fdis_iu6_i1_s1_v_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s1_a_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s1_a_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s1_p_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s1_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s1_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i1_s1_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_s1_t_l2;
   wire                           frn_fdis_iu6_i1_s1_dep_hit_d;
   wire                           frn_fdis_iu6_i1_s1_dep_hit_l2;
   wire                           frn_fdis_iu6_i1_s2_v_d;
   wire                           frn_fdis_iu6_i1_s2_v_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s2_a_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s2_a_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s2_p_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s2_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s2_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i1_s2_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_s2_t_l2;
   wire                           frn_fdis_iu6_i1_s2_dep_hit_d;
   wire                           frn_fdis_iu6_i1_s2_dep_hit_l2;
   wire                           frn_fdis_iu6_i1_s3_v_d;
   wire                           frn_fdis_iu6_i1_s3_v_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s3_a_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s3_a_l2;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s3_p_d;
   wire [0:`GPR_POOL_ENC-1]       frn_fdis_iu6_i1_s3_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      frn_fdis_iu6_i1_s3_itag_l2;
   wire [0:2]                     frn_fdis_iu6_i1_s3_t_d;
   wire [0:2]                     frn_fdis_iu6_i1_s3_t_l2;
   wire                           frn_fdis_iu6_i1_s3_dep_hit_d;
   wire                           frn_fdis_iu6_i1_s3_dep_hit_l2;

   // iu6 stall latches
   wire                           stall_frn_fdis_iu6_i0_act;
   wire                           stall_frn_fdis_iu6_i0_vld_d;
   wire                           stall_frn_fdis_iu6_i0_vld_l2;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_ucode_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_ucode_l2;
   wire [0:`UCODE_ENTRIES_ENC-1]   stall_frn_fdis_iu6_i0_ucode_cnt_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   stall_frn_fdis_iu6_i0_ucode_cnt_l2;
   wire                           stall_frn_fdis_iu6_i0_2ucode_d;
   wire                           stall_frn_fdis_iu6_i0_2ucode_l2;
   wire                           stall_frn_fdis_iu6_i0_fuse_nop_d;
   wire                           stall_frn_fdis_iu6_i0_fuse_nop_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_lq_d;
   wire                           stall_frn_fdis_iu6_i0_rte_lq_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_sq_d;
   wire                           stall_frn_fdis_iu6_i0_rte_sq_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_fx0_d;
   wire                           stall_frn_fdis_iu6_i0_rte_fx0_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_fx1_d;
   wire                           stall_frn_fdis_iu6_i0_rte_fx1_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_axu0_d;
   wire                           stall_frn_fdis_iu6_i0_rte_axu0_l2;
   wire                           stall_frn_fdis_iu6_i0_rte_axu1_d;
   wire                           stall_frn_fdis_iu6_i0_rte_axu1_l2;
   wire                           stall_frn_fdis_iu6_i0_valop_d;
   wire                           stall_frn_fdis_iu6_i0_valop_l2;
   wire                           stall_frn_fdis_iu6_i0_ord_d;
   wire                           stall_frn_fdis_iu6_i0_ord_l2;
   wire                           stall_frn_fdis_iu6_i0_cord_d;
   wire                           stall_frn_fdis_iu6_i0_cord_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_error_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_error_l2;
   wire                           stall_frn_fdis_iu6_i0_btb_entry_d;
   wire                           stall_frn_fdis_iu6_i0_btb_entry_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i0_btb_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i0_btb_hist_l2;
   wire                           stall_frn_fdis_iu6_i0_bta_val_d;
   wire                           stall_frn_fdis_iu6_i0_bta_val_l2;
   wire [0:19]                    stall_frn_fdis_iu6_i0_fusion_d;
   wire [0:19]                    stall_frn_fdis_iu6_i0_fusion_l2;
   wire                           stall_frn_fdis_iu6_i0_spec_d;
   wire                           stall_frn_fdis_iu6_i0_spec_l2;
   wire                           stall_frn_fdis_iu6_i0_type_fp_d;
   wire                           stall_frn_fdis_iu6_i0_type_fp_l2;
   wire                           stall_frn_fdis_iu6_i0_type_ap_d;
   wire                           stall_frn_fdis_iu6_i0_type_ap_l2;
   wire                           stall_frn_fdis_iu6_i0_type_spv_d;
   wire                           stall_frn_fdis_iu6_i0_type_spv_l2;
   wire                           stall_frn_fdis_iu6_i0_type_st_d;
   wire                           stall_frn_fdis_iu6_i0_type_st_l2;
   wire                           stall_frn_fdis_iu6_i0_async_block_d;
   wire                           stall_frn_fdis_iu6_i0_async_block_l2;
   wire                           stall_frn_fdis_iu6_i0_np1_flush_d;
   wire                           stall_frn_fdis_iu6_i0_np1_flush_l2;
   wire                           stall_frn_fdis_iu6_i0_core_block_d;
   wire                           stall_frn_fdis_iu6_i0_core_block_l2;
   wire                           stall_frn_fdis_iu6_i0_isram_d;
   wire                           stall_frn_fdis_iu6_i0_isram_l2;
   wire                           stall_frn_fdis_iu6_i0_isload_d;
   wire                           stall_frn_fdis_iu6_i0_isload_l2;
   wire                           stall_frn_fdis_iu6_i0_isstore_d;
   wire                           stall_frn_fdis_iu6_i0_isstore_l2;
   wire [0:31]                    stall_frn_fdis_iu6_i0_instr_d;
   wire [0:31]                    stall_frn_fdis_iu6_i0_instr_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i0_ifar_d;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i0_ifar_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i0_bta_d;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i0_bta_l2;
   wire                           stall_frn_fdis_iu6_i0_br_pred_d;
   wire                           stall_frn_fdis_iu6_i0_br_pred_l2;
   wire                           stall_frn_fdis_iu6_i0_bh_update_d;
   wire                           stall_frn_fdis_iu6_i0_bh_update_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh0_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh0_hist_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh1_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh1_hist_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh2_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i0_bh2_hist_l2;
   wire [0:17]                     stall_frn_fdis_iu6_i0_gshare_d;
   wire [0:17]                     stall_frn_fdis_iu6_i0_gshare_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_ls_ptr_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_ls_ptr_l2;
   wire                           stall_frn_fdis_iu6_i0_match_d;
   wire                           stall_frn_fdis_iu6_i0_match_l2;
   wire [0:3]                     stall_frn_fdis_iu6_i0_ilat_d;
   wire [0:3]                     stall_frn_fdis_iu6_i0_ilat_l2;
   wire                           stall_frn_fdis_iu6_i0_t1_v_d;
   wire                           stall_frn_fdis_iu6_i0_t1_v_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t1_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t1_t_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t1_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t1_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t1_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t1_p_l2;
   wire                           stall_frn_fdis_iu6_i0_t2_v_d;
   wire                           stall_frn_fdis_iu6_i0_t2_v_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t2_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t2_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t2_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t2_p_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t2_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t2_t_l2;
   wire                           stall_frn_fdis_iu6_i0_t3_v_d;
   wire                           stall_frn_fdis_iu6_i0_t3_v_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t3_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t3_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t3_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_t3_p_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t3_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_t3_t_l2;
   wire                           stall_frn_fdis_iu6_i0_s1_v_d;
   wire                           stall_frn_fdis_iu6_i0_s1_v_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s1_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s1_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s1_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s1_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s1_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s1_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s1_t_l2;
   wire                           stall_frn_fdis_iu6_i0_s2_v_d;
   wire                           stall_frn_fdis_iu6_i0_s2_v_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s2_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s2_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s2_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s2_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s2_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s2_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s2_t_l2;
   wire                           stall_frn_fdis_iu6_i0_s3_v_d;
   wire                           stall_frn_fdis_iu6_i0_s3_v_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s3_a_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s3_a_l2;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s3_p_d;
   wire [0:`GPR_POOL_ENC-1]        stall_frn_fdis_iu6_i0_s3_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i0_s3_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s3_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i0_s3_t_l2;
   wire                           stall_frn_fdis_iu6_i1_act;
   wire                           stall_frn_fdis_iu6_i1_vld_d;
   wire                           stall_frn_fdis_iu6_i1_vld_l2;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]       stall_frn_fdis_iu6_i1_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_ucode_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_ucode_l2;
   wire [0:`UCODE_ENTRIES_ENC-1]   stall_frn_fdis_iu6_i1_ucode_cnt_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   stall_frn_fdis_iu6_i1_ucode_cnt_l2;
   wire                           stall_frn_fdis_iu6_i1_fuse_nop_d;
   wire                           stall_frn_fdis_iu6_i1_fuse_nop_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_lq_d;
   wire                           stall_frn_fdis_iu6_i1_rte_lq_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_sq_d;
   wire                           stall_frn_fdis_iu6_i1_rte_sq_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_fx0_d;
   wire                           stall_frn_fdis_iu6_i1_rte_fx0_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_fx1_d;
   wire                           stall_frn_fdis_iu6_i1_rte_fx1_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_axu0_d;
   wire                           stall_frn_fdis_iu6_i1_rte_axu0_l2;
   wire                           stall_frn_fdis_iu6_i1_rte_axu1_d;
   wire                           stall_frn_fdis_iu6_i1_rte_axu1_l2;
   wire                           stall_frn_fdis_iu6_i1_valop_d;
   wire                           stall_frn_fdis_iu6_i1_valop_l2;
   wire                           stall_frn_fdis_iu6_i1_ord_d;
   wire                           stall_frn_fdis_iu6_i1_ord_l2;
   wire                           stall_frn_fdis_iu6_i1_cord_d;
   wire                           stall_frn_fdis_iu6_i1_cord_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_error_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_error_l2;
   wire                           stall_frn_fdis_iu6_i1_btb_entry_d;
   wire                           stall_frn_fdis_iu6_i1_btb_entry_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i1_btb_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i1_btb_hist_l2;
   wire                           stall_frn_fdis_iu6_i1_bta_val_d;
   wire                           stall_frn_fdis_iu6_i1_bta_val_l2;
   wire [0:19]                    stall_frn_fdis_iu6_i1_fusion_d;
   wire [0:19]                    stall_frn_fdis_iu6_i1_fusion_l2;
   wire                           stall_frn_fdis_iu6_i1_spec_d;
   wire                           stall_frn_fdis_iu6_i1_spec_l2;
   wire                           stall_frn_fdis_iu6_i1_type_fp_d;
   wire                           stall_frn_fdis_iu6_i1_type_fp_l2;
   wire                           stall_frn_fdis_iu6_i1_type_ap_d;
   wire                           stall_frn_fdis_iu6_i1_type_ap_l2;
   wire                           stall_frn_fdis_iu6_i1_type_spv_d;
   wire                           stall_frn_fdis_iu6_i1_type_spv_l2;
   wire                           stall_frn_fdis_iu6_i1_type_st_d;
   wire                           stall_frn_fdis_iu6_i1_type_st_l2;
   wire                           stall_frn_fdis_iu6_i1_async_block_d;
   wire                           stall_frn_fdis_iu6_i1_async_block_l2;
   wire                           stall_frn_fdis_iu6_i1_np1_flush_d;
   wire                           stall_frn_fdis_iu6_i1_np1_flush_l2;
   wire                           stall_frn_fdis_iu6_i1_core_block_d;
   wire                           stall_frn_fdis_iu6_i1_core_block_l2;
   wire                           stall_frn_fdis_iu6_i1_isram_d;
   wire                           stall_frn_fdis_iu6_i1_isram_l2;
   wire                           stall_frn_fdis_iu6_i1_isload_d;
   wire                           stall_frn_fdis_iu6_i1_isload_l2;
   wire                           stall_frn_fdis_iu6_i1_isstore_d;
   wire                           stall_frn_fdis_iu6_i1_isstore_l2;
   wire [0:31]                    stall_frn_fdis_iu6_i1_instr_d;
   wire [0:31]                    stall_frn_fdis_iu6_i1_instr_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i1_ifar_d;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i1_ifar_l2;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i1_bta_d;
   wire [62-`EFF_IFAR_WIDTH:61]    stall_frn_fdis_iu6_i1_bta_l2;
   wire                           stall_frn_fdis_iu6_i1_br_pred_d;
   wire                           stall_frn_fdis_iu6_i1_br_pred_l2;
   wire                           stall_frn_fdis_iu6_i1_bh_update_d;
   wire                           stall_frn_fdis_iu6_i1_bh_update_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh0_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh0_hist_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh1_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh1_hist_l2;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh2_hist_d;
   wire [0:1]                     stall_frn_fdis_iu6_i1_bh2_hist_l2;
   wire [0:17]                     stall_frn_fdis_iu6_i1_gshare_d;
   wire [0:17]                     stall_frn_fdis_iu6_i1_gshare_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_ls_ptr_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_ls_ptr_l2;
   wire                           stall_frn_fdis_iu6_i1_match_d;
   wire                           stall_frn_fdis_iu6_i1_match_l2;
   wire [0:3]                     stall_frn_fdis_iu6_i1_ilat_d;
   wire [0:3]                     stall_frn_fdis_iu6_i1_ilat_l2;
   wire                           stall_frn_fdis_iu6_i1_t1_v_d;
   wire                           stall_frn_fdis_iu6_i1_t1_v_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t1_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t1_t_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t1_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t1_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t1_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t1_p_l2;
   wire                           stall_frn_fdis_iu6_i1_t2_v_d;
   wire                           stall_frn_fdis_iu6_i1_t2_v_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t2_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t2_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t2_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t2_p_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t2_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t2_t_l2;
   wire                           stall_frn_fdis_iu6_i1_t3_v_d;
   wire                           stall_frn_fdis_iu6_i1_t3_v_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t3_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t3_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t3_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_t3_p_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t3_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_t3_t_l2;
   wire                           stall_frn_fdis_iu6_i1_s1_v_d;
   wire                           stall_frn_fdis_iu6_i1_s1_v_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s1_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s1_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s1_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s1_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s1_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s1_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s1_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s1_t_l2;
   wire                           stall_frn_fdis_iu6_i1_s1_dep_hit_d;
   wire                           stall_frn_fdis_iu6_i1_s1_dep_hit_l2;
   wire                           stall_frn_fdis_iu6_i1_s2_v_d;
   wire                           stall_frn_fdis_iu6_i1_s2_v_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s2_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s2_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s2_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s2_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s2_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s2_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s2_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s2_t_l2;
   wire                           stall_frn_fdis_iu6_i1_s2_dep_hit_d;
   wire                           stall_frn_fdis_iu6_i1_s2_dep_hit_l2;
   wire                           stall_frn_fdis_iu6_i1_s3_v_d;
   wire                           stall_frn_fdis_iu6_i1_s3_v_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s3_a_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s3_a_l2;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s3_p_d;
   wire [0:`GPR_POOL_ENC-1]       stall_frn_fdis_iu6_i1_s3_p_l2;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s3_itag_d;
   wire [0:`ITAG_SIZE_ENC-1]      stall_frn_fdis_iu6_i1_s3_itag_l2;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s3_t_d;
   wire [0:2]                     stall_frn_fdis_iu6_i1_s3_t_l2;
   wire                           stall_frn_fdis_iu6_i1_s3_dep_hit_d;
   wire                           stall_frn_fdis_iu6_i1_s3_dep_hit_l2;

   //stall
   wire [0:18]                    fdis_frn_iu6_stall_d;
   wire [0:18]                    fdis_frn_iu6_stall_l2;
   wire                           fdis_frn_iu6_stall_dly;

   // Next Itags
   wire [0:`ITAG_SIZE_ENC-1]       next_itag_0_d;
   wire [0:`ITAG_SIZE_ENC-1]       next_itag_0_l2;
   wire [0:`ITAG_SIZE_ENC-1]       next_itag_1_d;
   wire [0:`ITAG_SIZE_ENC-1]       next_itag_1_l2;
   wire [0:`ITAG_SIZE_ENC-1]       i0_itag_next;
   wire [0:`ITAG_SIZE_ENC-1]       i1_itag_next;
   wire                           inc_0;
   wire                           inc_1;

   // Credit counters
   reg [0:`CPL_Q_DEPTH_ENC]        cp_high_credit_cnt_d;
   wire [0:`CPL_Q_DEPTH_ENC]       cp_high_credit_cnt_l2;
   reg [0:`CPL_Q_DEPTH_ENC]        cp_med_credit_cnt_d;
   wire [0:`CPL_Q_DEPTH_ENC]       cp_med_credit_cnt_l2;

   wire [0:`CPL_Q_DEPTH_ENC]       cp_credit_cnt_mux;

   wire [0:`CPL_Q_DEPTH_ENC]       high_cnt_plus2_temp,  high_cnt_plus2;
   wire [0:`CPL_Q_DEPTH_ENC]       high_cnt_plus1_temp,  high_cnt_plus1;
   wire [0:`CPL_Q_DEPTH_ENC]       high_cnt_minus1_temp, high_cnt_minus1;
   wire [0:`CPL_Q_DEPTH_ENC]       high_cnt_minus2_temp, high_cnt_minus2;
   wire [0:`CPL_Q_DEPTH_ENC]       med_cnt_plus2_temp,  med_cnt_plus2;
   wire [0:`CPL_Q_DEPTH_ENC]       med_cnt_plus1_temp,  med_cnt_plus1;
   wire [0:`CPL_Q_DEPTH_ENC]       med_cnt_minus1_temp, med_cnt_minus1;
   wire [0:`CPL_Q_DEPTH_ENC]       med_cnt_minus2_temp, med_cnt_minus2;

   // Rolling count for ucode instructions
   reg [0:`UCODE_ENTRIES_ENC-1]    ucode_cnt_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   ucode_cnt_l2;
   // Save count to flush to for flushing to ucode
   reg [0:`UCODE_ENTRIES_ENC-1]    ucode_cnt_save_d;
   wire [0:`UCODE_ENTRIES_ENC-1]   ucode_cnt_save_l2;

   // Latch to delay the flush signal
   wire                           cp_flush_d;
   wire                           cp_flush_l2;
   wire                           cp_flush_into_uc_d;
   wire                           cp_flush_into_uc_l2;
   wire                           br_iu_hold_d;
   wire                           br_iu_hold_l2;
   wire                           hold_instructions_d;
   wire                           hold_instructions_l2;

   // completion queue is empty
   wire                           cp_rn_empty_l2;

   wire                           high_pri_mask_l2;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i0_src1_p;
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i0_src2_p;
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i0_src3_p;
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i1_src1_p;
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i1_src2_p;
   wire [0:`GPR_POOL_ENC-1]        gpr_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          gpr_s1_dep_hit;
   wire                          gpr_s2_dep_hit;
   wire                          gpr_s3_dep_hit;

   // Free from completion to the gpr pool
   wire                           gpr_cp_i0_wr_v;
   wire [0:`GPR_POOL_ENC-1]        gpr_cp_i0_wr_a;
   wire [0:`GPR_POOL_ENC-1]        gpr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_cp_i0_wr_itag;
   wire                           gpr_cp_i1_wr_v;
   wire [0:`GPR_POOL_ENC-1]        gpr_cp_i1_wr_a;
   wire [0:`GPR_POOL_ENC-1]        gpr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_cp_i1_wr_itag;

   wire                           gpr_spec_i0_wr_v;
   wire                           gpr_spec_i0_wr_v_fast;
   wire [0:`GPR_POOL_ENC-1]        gpr_spec_i0_wr_a;
   wire [0:`GPR_POOL_ENC-1]        gpr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_spec_i0_wr_itag;
   wire                           gpr_spec_i1_wr_v;
   wire                           gpr_spec_i1_wr_v_fast;
   wire [0:`GPR_POOL_ENC-1]        gpr_spec_i1_wr_a;
   wire [0:`GPR_POOL_ENC-1]        gpr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       gpr_spec_i1_wr_itag;

   wire                           next_gpr_0_v;
   wire [0:`GPR_POOL_ENC-1]        next_gpr_0;
   wire                           next_gpr_1_v;
   wire [0:`GPR_POOL_ENC-1]        next_gpr_1;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i0_src1_p;
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i0_src2_p;
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i0_src3_p;
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i1_src1_p;
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i1_src2_p;
   wire [0:`CR_POOL_ENC-1]         cr_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       cr_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          cr_s1_dep_hit;
   wire                          cr_s2_dep_hit;
   wire                          cr_s3_dep_hit;

   // Free from completion to the cr pool
   wire                           cr_cp_i0_wr_v;
   wire [0:`CR_POOL_ENC-1]         cr_cp_i0_wr_a;
   wire [0:`CR_POOL_ENC-1]         cr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       cr_cp_i0_wr_itag;
   wire                           cr_cp_i1_wr_v;
   wire [0:`CR_POOL_ENC-1]         cr_cp_i1_wr_a;
   wire [0:`CR_POOL_ENC-1]         cr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       cr_cp_i1_wr_itag;

   wire                           cr_spec_i0_wr_v;
   wire                           cr_spec_i0_wr_v_fast;
   wire [0:`CR_POOL_ENC-1]         cr_spec_i0_wr_a;
   wire [0:`CR_POOL_ENC-1]         cr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       cr_spec_i0_wr_itag;
   wire                           cr_spec_i1_wr_v;
   wire                           cr_spec_i1_wr_v_fast;
   wire [0:`CR_POOL_ENC-1]         cr_spec_i1_wr_a;
   wire [0:`CR_POOL_ENC-1]         cr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       cr_spec_i1_wr_itag;

   wire                           next_cr_0_v;
   wire [0:`CR_POOL_ENC-1]         next_cr_0;
   wire                           next_cr_1_v;
   wire [0:`CR_POOL_ENC-1]         next_cr_1;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i0_src1_p;
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i0_src2_p;
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i0_src3_p;
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i1_src1_p;
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i1_src2_p;
   wire [0:`LR_POOL_ENC-1]         lr_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       lr_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          lr_s1_dep_hit;
   wire                          lr_s2_dep_hit;
   wire                          lr_s3_dep_hit;

   // Free from completion to the lr pool
   wire                           lr_cp_i0_wr_v;
   wire [0:`LR_POOL_ENC-1]         lr_cp_i0_wr_a;
   wire [0:`LR_POOL_ENC-1]         lr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       lr_cp_i0_wr_itag;
   wire                           lr_cp_i1_wr_v;
   wire [0:`LR_POOL_ENC-1]         lr_cp_i1_wr_a;
   wire [0:`LR_POOL_ENC-1]         lr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       lr_cp_i1_wr_itag;

   wire                           lr_spec_i0_wr_v;
   wire                           lr_spec_i0_wr_v_fast;
   wire [0:`LR_POOL_ENC-1]         lr_spec_i0_wr_a;
   wire [0:`LR_POOL_ENC-1]         lr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       lr_spec_i0_wr_itag;
   wire                           lr_spec_i1_wr_v;
   wire                           lr_spec_i1_wr_v_fast;
   wire [0:`LR_POOL_ENC-1]         lr_spec_i1_wr_a;
   wire [0:`LR_POOL_ENC-1]         lr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       lr_spec_i1_wr_itag;

   wire                           next_lr_0_v;
   wire [0:`LR_POOL_ENC-1]         next_lr_0;
   wire                           next_lr_1_v;
   wire [0:`LR_POOL_ENC-1]         next_lr_1;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i0_src1_p;
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i0_src2_p;
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i0_src3_p;
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i1_src1_p;
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i1_src2_p;
   wire [0:`CTR_POOL_ENC-1]        ctr_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          ctr_s1_dep_hit;
   wire                          ctr_s2_dep_hit;
   wire                          ctr_s3_dep_hit;

   // Free from completion to the ctr pool
   wire                           ctr_cp_i0_wr_v;
   wire [0:`CTR_POOL_ENC-1]        ctr_cp_i0_wr_a;
   wire [0:`CTR_POOL_ENC-1]        ctr_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_cp_i0_wr_itag;
   wire                           ctr_cp_i1_wr_v;
   wire [0:`CTR_POOL_ENC-1]        ctr_cp_i1_wr_a;
   wire [0:`CTR_POOL_ENC-1]        ctr_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_cp_i1_wr_itag;

   wire                           ctr_spec_i0_wr_v;
   wire                           ctr_spec_i0_wr_v_fast;
   wire [0:`CTR_POOL_ENC-1]        ctr_spec_i0_wr_a;
   wire [0:`CTR_POOL_ENC-1]        ctr_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_spec_i0_wr_itag;
   wire                           ctr_spec_i1_wr_v;
   wire                           ctr_spec_i1_wr_v_fast;
   wire [0:`CTR_POOL_ENC-1]        ctr_spec_i1_wr_a;
   wire [0:`CTR_POOL_ENC-1]        ctr_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       ctr_spec_i1_wr_itag;

   wire                           next_ctr_0_v;
   wire [0:`CTR_POOL_ENC-1]        next_ctr_0;
   wire                           next_ctr_1_v;
   wire [0:`CTR_POOL_ENC-1]        next_ctr_1;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i0_src1_p;
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i0_src2_p;
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i0_src3_p;
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i1_src1_p;
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i1_src2_p;
   wire [0:`XER_POOL_ENC-1]        xer_iu5_i1_src3_p;

   // Source lookups from pools note may not be valid if source if type not of the right type
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i0_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i0_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i0_src3_itag;
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i1_src1_itag;
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i1_src2_itag;
   wire [0:`ITAG_SIZE_ENC-1]       xer_iu5_i1_src3_itag;

   // I1 dependency hit vs I0 for each source this is used by RV
   wire                          xer_s1_dep_hit;
   wire                          xer_s2_dep_hit;
   wire                          xer_s3_dep_hit;

   // Free from completion to the xer pool
   wire                           xer_cp_i0_wr_v;
   wire [0:`XER_POOL_ENC-1]        xer_cp_i0_wr_a;
   wire [0:`XER_POOL_ENC-1]        xer_cp_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       xer_cp_i0_wr_itag;
   wire                           xer_cp_i1_wr_v;
   wire [0:`XER_POOL_ENC-1]        xer_cp_i1_wr_a;
   wire [0:`XER_POOL_ENC-1]        xer_cp_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       xer_cp_i1_wr_itag;

   wire                           xer_spec_i0_wr_v;
   wire                           xer_spec_i0_wr_v_fast;
   wire [0:`XER_POOL_ENC-1]        xer_spec_i0_wr_a;
   wire [0:`XER_POOL_ENC-1]        xer_spec_i0_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       xer_spec_i0_wr_itag;
   wire                           xer_spec_i1_wr_v;
   wire                           xer_spec_i1_wr_v_fast;
   wire [0:`XER_POOL_ENC-1]        xer_spec_i1_wr_a;
   wire [0:`XER_POOL_ENC-1]        xer_spec_i1_wr_p;
   wire [0:`ITAG_SIZE_ENC-1]       xer_spec_i1_wr_itag;

   wire                           next_xer_0_v;
   wire [0:`XER_POOL_ENC-1]        next_xer_0;
   wire                           next_xer_1_v;
   wire [0:`XER_POOL_ENC-1]        next_xer_1;

   wire [0:1]                     gpr_send_cnt;
   wire [0:1]                     cr_send_cnt;
   wire [0:1]                     cr_send_t1_cnt;
   wire [0:1]                     cr_send_t3_cnt;
   wire [0:1]                     lr_send_cnt;
   wire [0:1]                     ctr_send_cnt;
   wire [0:1]                     xer_send_cnt;
   wire [0:1]                     ucode_send_cnt;
   wire [0:`UCODE_ENTRIES_ENC-1]  ucode_cnt_i0;
   wire [0:`UCODE_ENTRIES_ENC-1]  ucode_cnt_i1;

   wire                           cpl_credit_ok;
   wire                           gpr_send_ok;
   wire                           cr_send_ok;
   wire                           lr_send_ok;
   wire                           ctr_send_ok;
   wire                           xer_send_ok;
   wire                           cp_empty_ok;

   wire                           send_instructions;

   // Perfmon
   wire                           perf_iu5_stall_d, perf_iu5_stall_l2;
   wire                           perf_iu5_cpl_credit_stall_d, perf_iu5_cpl_credit_stall_l2;
   wire                           perf_iu5_gpr_credit_stall_d, perf_iu5_gpr_credit_stall_l2;
   wire                           perf_iu5_cr_credit_stall_d, perf_iu5_cr_credit_stall_l2;
   wire                           perf_iu5_lr_credit_stall_d, perf_iu5_lr_credit_stall_l2;
   wire                           perf_iu5_ctr_credit_stall_d, perf_iu5_ctr_credit_stall_l2;
   wire                           perf_iu5_xer_credit_stall_d, perf_iu5_xer_credit_stall_l2;
   wire                           perf_iu5_br_hold_stall_d, perf_iu5_br_hold_stall_l2;
   wire                           perf_iu5_axu_hold_stall_d, perf_iu5_axu_hold_stall_l2;


   // Pervasive
   wire                           pc_iu_func_sl_thold_1;
   wire                           pc_iu_func_sl_thold_0;
   wire                           pc_iu_func_sl_thold_0_b;
   wire                           pc_iu_sg_1;
   wire                           pc_iu_sg_0;
   wire                           force_t;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   // outputs
   assign frn_fdis_iu6_i0_vld = (fdis_frn_iu6_stall_l2[3] == 1'b0) ? frn_fdis_iu6_i0_vld_l2 :
                                stall_frn_fdis_iu6_i0_vld_l2;
   assign frn_fdis_iu6_i0_itag = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_itag_l2 :
                                 stall_frn_fdis_iu6_i0_itag_l2;
   assign frn_fdis_iu6_i0_ucode = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ucode_l2 :
                                  stall_frn_fdis_iu6_i0_ucode_l2;
   assign frn_fdis_iu6_i0_ucode_cnt = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ucode_cnt_l2 :
                                      stall_frn_fdis_iu6_i0_ucode_cnt_l2;
   assign frn_fdis_iu6_i0_2ucode = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_2ucode_l2 :
                                   stall_frn_fdis_iu6_i0_2ucode_l2;
   assign frn_fdis_iu6_i0_fuse_nop = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_fuse_nop_l2 :
                                     stall_frn_fdis_iu6_i0_fuse_nop_l2;
   assign frn_fdis_iu6_i0_rte_lq = (fdis_frn_iu6_stall_l2[5] == 1'b0) ? frn_fdis_iu6_i0_rte_lq_l2 :
                                   stall_frn_fdis_iu6_i0_rte_lq_l2;
   assign frn_fdis_iu6_i0_rte_sq = (fdis_frn_iu6_stall_l2[7] == 1'b0) ? frn_fdis_iu6_i0_rte_sq_l2 :
                                   stall_frn_fdis_iu6_i0_rte_sq_l2;
   assign frn_fdis_iu6_i0_rte_fx0 = (fdis_frn_iu6_stall_l2[9] == 1'b0) ? frn_fdis_iu6_i0_rte_fx0_l2 :
                                    stall_frn_fdis_iu6_i0_rte_fx0_l2;
   assign frn_fdis_iu6_i0_rte_fx1 = (fdis_frn_iu6_stall_l2[11] == 1'b0) ? frn_fdis_iu6_i0_rte_fx1_l2 :
                                    stall_frn_fdis_iu6_i0_rte_fx1_l2;
   assign frn_fdis_iu6_i0_rte_axu0 = (fdis_frn_iu6_stall_l2[13] == 1'b0) ? frn_fdis_iu6_i0_rte_axu0_l2 :
                                     stall_frn_fdis_iu6_i0_rte_axu0_l2;
   assign frn_fdis_iu6_i0_rte_axu1 = (fdis_frn_iu6_stall_l2[15] == 1'b0) ? frn_fdis_iu6_i0_rte_axu1_l2 :
                                     stall_frn_fdis_iu6_i0_rte_axu1_l2;
   assign frn_fdis_iu6_i0_valop = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_valop_l2 :
                                  stall_frn_fdis_iu6_i0_valop_l2;
   assign frn_fdis_iu6_i0_ord = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ord_l2 :
                                stall_frn_fdis_iu6_i0_ord_l2;
   assign frn_fdis_iu6_i0_cord = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_cord_l2 :
                                 stall_frn_fdis_iu6_i0_cord_l2;
   assign frn_fdis_iu6_i0_error = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_error_l2 :
                                  stall_frn_fdis_iu6_i0_error_l2;
   assign frn_fdis_iu6_i0_btb_entry = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_btb_entry_l2 :
                                      stall_frn_fdis_iu6_i0_btb_entry_l2;
   assign frn_fdis_iu6_i0_btb_hist = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_btb_hist_l2 :
                                     stall_frn_fdis_iu6_i0_btb_hist_l2;
   assign frn_fdis_iu6_i0_bta_val = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bta_val_l2 :
                                    stall_frn_fdis_iu6_i0_bta_val_l2;
   assign frn_fdis_iu6_i0_fusion = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_fusion_l2 :
                                   stall_frn_fdis_iu6_i0_fusion_l2;
   assign frn_fdis_iu6_i0_spec = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_spec_l2 :
                                 stall_frn_fdis_iu6_i0_spec_l2;
   assign frn_fdis_iu6_i0_type_fp = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_type_fp_l2 :
                                   stall_frn_fdis_iu6_i0_type_fp_l2;
   assign frn_fdis_iu6_i0_type_ap = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_type_ap_l2 :
                                   stall_frn_fdis_iu6_i0_type_ap_l2;
   assign frn_fdis_iu6_i0_type_spv = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_type_spv_l2 :
                                    stall_frn_fdis_iu6_i0_type_spv_l2;
   assign frn_fdis_iu6_i0_type_st = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_type_st_l2 :
                                   stall_frn_fdis_iu6_i0_type_st_l2;
   assign frn_fdis_iu6_i0_async_block = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_async_block_l2 :
                                        stall_frn_fdis_iu6_i0_async_block_l2;
   assign frn_fdis_iu6_i0_np1_flush = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_np1_flush_l2 :
                                      stall_frn_fdis_iu6_i0_np1_flush_l2;
   assign frn_fdis_iu6_i0_core_block = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_core_block_l2 :
                                       stall_frn_fdis_iu6_i0_core_block_l2;
   assign frn_fdis_iu6_i0_isram = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_isram_l2 :
                                  stall_frn_fdis_iu6_i0_isram_l2;
   assign frn_fdis_iu6_i0_isload = (fdis_frn_iu6_stall_l2[17] == 1'b0) ? frn_fdis_iu6_i0_isload_l2 :
                                   stall_frn_fdis_iu6_i0_isload_l2;
   assign frn_fdis_iu6_i0_isstore = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_isstore_l2 :
                                    stall_frn_fdis_iu6_i0_isstore_l2;
   assign frn_fdis_iu6_i0_instr = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_instr_l2 :
                                  stall_frn_fdis_iu6_i0_instr_l2;
   assign frn_fdis_iu6_i0_ifar = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ifar_l2 :
                                 stall_frn_fdis_iu6_i0_ifar_l2;
   assign frn_fdis_iu6_i0_bta = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bta_l2 :
                                stall_frn_fdis_iu6_i0_bta_l2;
   assign frn_fdis_iu6_i0_br_pred = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_br_pred_l2 :
                                    stall_frn_fdis_iu6_i0_br_pred_l2;
   assign frn_fdis_iu6_i0_bh_update = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bh_update_l2 :
                                      stall_frn_fdis_iu6_i0_bh_update_l2;
   assign frn_fdis_iu6_i0_bh0_hist = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bh0_hist_l2 :
                                     stall_frn_fdis_iu6_i0_bh0_hist_l2;
   assign frn_fdis_iu6_i0_bh1_hist = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bh1_hist_l2 :
                                     stall_frn_fdis_iu6_i0_bh1_hist_l2;
   assign frn_fdis_iu6_i0_bh2_hist = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_bh2_hist_l2 :
                                     stall_frn_fdis_iu6_i0_bh2_hist_l2;
   assign frn_fdis_iu6_i0_gshare = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_gshare_l2 :
                                   stall_frn_fdis_iu6_i0_gshare_l2;
   assign frn_fdis_iu6_i0_ls_ptr = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ls_ptr_l2 :
                                   stall_frn_fdis_iu6_i0_ls_ptr_l2;
   assign frn_fdis_iu6_i0_match = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_match_l2 :
                                  stall_frn_fdis_iu6_i0_match_l2;
   assign frn_fdis_iu6_i0_ilat = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_ilat_l2 :
                                 stall_frn_fdis_iu6_i0_ilat_l2;
   assign frn_fdis_iu6_i0_t1_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t1_v_l2 :
                                 stall_frn_fdis_iu6_i0_t1_v_l2;
   assign frn_fdis_iu6_i0_t1_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t1_t_l2 :
                                 stall_frn_fdis_iu6_i0_t1_t_l2;
   assign frn_fdis_iu6_i0_t1_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t1_a_l2 :
                                 stall_frn_fdis_iu6_i0_t1_a_l2;
   assign frn_fdis_iu6_i0_t1_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t1_p_l2 :
                                 stall_frn_fdis_iu6_i0_t1_p_l2;
   assign frn_fdis_iu6_i0_t2_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t2_v_l2 :
                                 stall_frn_fdis_iu6_i0_t2_v_l2;
   assign frn_fdis_iu6_i0_t2_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t2_a_l2 :
                                 stall_frn_fdis_iu6_i0_t2_a_l2;
   assign frn_fdis_iu6_i0_t2_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t2_p_l2 :
                                 stall_frn_fdis_iu6_i0_t2_p_l2;
   assign frn_fdis_iu6_i0_t2_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t2_t_l2 :
                                 stall_frn_fdis_iu6_i0_t2_t_l2;
   assign frn_fdis_iu6_i0_t3_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t3_v_l2 :
                                 stall_frn_fdis_iu6_i0_t3_v_l2;
   assign frn_fdis_iu6_i0_t3_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t3_a_l2 :
                                 stall_frn_fdis_iu6_i0_t3_a_l2;
   assign frn_fdis_iu6_i0_t3_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t3_p_l2 :
                                 stall_frn_fdis_iu6_i0_t3_p_l2;
   assign frn_fdis_iu6_i0_t3_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_t3_t_l2 :
                                 stall_frn_fdis_iu6_i0_t3_t_l2;
   assign frn_fdis_iu6_i0_s1_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s1_v_l2 :
                                 stall_frn_fdis_iu6_i0_s1_v_l2;
   assign frn_fdis_iu6_i0_s1_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s1_a_l2 :
                                 stall_frn_fdis_iu6_i0_s1_a_l2;
   assign frn_fdis_iu6_i0_s1_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s1_p_l2 :
                                 stall_frn_fdis_iu6_i0_s1_p_l2;
   assign frn_fdis_iu6_i0_s1_itag = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s1_itag_l2 :
                                    stall_frn_fdis_iu6_i0_s1_itag_l2;
   assign frn_fdis_iu6_i0_s1_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s1_t_l2 :
                                 stall_frn_fdis_iu6_i0_s1_t_l2;
   assign frn_fdis_iu6_i0_s2_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s2_v_l2 :
                                 stall_frn_fdis_iu6_i0_s2_v_l2;
   assign frn_fdis_iu6_i0_s2_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s2_a_l2 :
                                 stall_frn_fdis_iu6_i0_s2_a_l2;
   assign frn_fdis_iu6_i0_s2_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s2_p_l2 :
                                 stall_frn_fdis_iu6_i0_s2_p_l2;
   assign frn_fdis_iu6_i0_s2_itag = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s2_itag_l2 :
                                    stall_frn_fdis_iu6_i0_s2_itag_l2;
   assign frn_fdis_iu6_i0_s2_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s2_t_l2 :
                                 stall_frn_fdis_iu6_i0_s2_t_l2;
   assign frn_fdis_iu6_i0_s3_v = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s3_v_l2 :
                                 stall_frn_fdis_iu6_i0_s3_v_l2;
   assign frn_fdis_iu6_i0_s3_a = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s3_a_l2 :
                                 stall_frn_fdis_iu6_i0_s3_a_l2;
   assign frn_fdis_iu6_i0_s3_p = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s3_p_l2 :
                                 stall_frn_fdis_iu6_i0_s3_p_l2;
   assign frn_fdis_iu6_i0_s3_itag = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s3_itag_l2 :
                                    stall_frn_fdis_iu6_i0_s3_itag_l2;
   assign frn_fdis_iu6_i0_s3_t = (fdis_frn_iu6_stall_l2[1] == 1'b0) ? frn_fdis_iu6_i0_s3_t_l2 :
                                 stall_frn_fdis_iu6_i0_s3_t_l2;

   assign frn_fdis_iu6_i1_vld = (fdis_frn_iu6_stall_l2[4] == 1'b0) ? frn_fdis_iu6_i1_vld_l2 :
                                stall_frn_fdis_iu6_i1_vld_l2;
   assign frn_fdis_iu6_i1_itag = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_itag_l2 :
                                 stall_frn_fdis_iu6_i1_itag_l2;
   assign frn_fdis_iu6_i1_ucode = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ucode_l2 :
                                  stall_frn_fdis_iu6_i1_ucode_l2;
   assign frn_fdis_iu6_i1_ucode_cnt = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ucode_cnt_l2 :
                                      stall_frn_fdis_iu6_i1_ucode_cnt_l2;
   assign frn_fdis_iu6_i1_fuse_nop = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_fuse_nop_l2 :
                                     stall_frn_fdis_iu6_i1_fuse_nop_l2;
   assign frn_fdis_iu6_i1_rte_lq = (fdis_frn_iu6_stall_l2[6] == 1'b0) ? frn_fdis_iu6_i1_rte_lq_l2 :
                                   stall_frn_fdis_iu6_i1_rte_lq_l2;
   assign frn_fdis_iu6_i1_rte_sq = (fdis_frn_iu6_stall_l2[8] == 1'b0) ? frn_fdis_iu6_i1_rte_sq_l2 :
                                   stall_frn_fdis_iu6_i1_rte_sq_l2;
   assign frn_fdis_iu6_i1_rte_fx0 = (fdis_frn_iu6_stall_l2[10] == 1'b0) ? frn_fdis_iu6_i1_rte_fx0_l2 :
                                    stall_frn_fdis_iu6_i1_rte_fx0_l2;
   assign frn_fdis_iu6_i1_rte_fx1 = (fdis_frn_iu6_stall_l2[12] == 1'b0) ? frn_fdis_iu6_i1_rte_fx1_l2 :
                                    stall_frn_fdis_iu6_i1_rte_fx1_l2;
   assign frn_fdis_iu6_i1_rte_axu0 = (fdis_frn_iu6_stall_l2[14] == 1'b0) ? frn_fdis_iu6_i1_rte_axu0_l2 :
                                     stall_frn_fdis_iu6_i1_rte_axu0_l2;
   assign frn_fdis_iu6_i1_rte_axu1 = (fdis_frn_iu6_stall_l2[16] == 1'b0) ? frn_fdis_iu6_i1_rte_axu1_l2 :
                                     stall_frn_fdis_iu6_i1_rte_axu1_l2;
   assign frn_fdis_iu6_i1_valop = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_valop_l2 :
                                  stall_frn_fdis_iu6_i1_valop_l2;
   assign frn_fdis_iu6_i1_ord = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ord_l2 :
                                stall_frn_fdis_iu6_i1_ord_l2;
   assign frn_fdis_iu6_i1_cord = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_cord_l2 :
                                 stall_frn_fdis_iu6_i1_cord_l2;
   assign frn_fdis_iu6_i1_error = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_error_l2 :
                                  stall_frn_fdis_iu6_i1_error_l2;
   assign frn_fdis_iu6_i1_btb_entry = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_btb_entry_l2 :
                                      stall_frn_fdis_iu6_i1_btb_entry_l2;
   assign frn_fdis_iu6_i1_btb_hist = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_btb_hist_l2 :
                                     stall_frn_fdis_iu6_i1_btb_hist_l2;
   assign frn_fdis_iu6_i1_bta_val = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bta_val_l2 :
                                    stall_frn_fdis_iu6_i1_bta_val_l2;
   assign frn_fdis_iu6_i1_fusion = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_fusion_l2 :
                                   stall_frn_fdis_iu6_i1_fusion_l2;
   assign frn_fdis_iu6_i1_spec = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_spec_l2 :
                                 stall_frn_fdis_iu6_i1_spec_l2;
   assign frn_fdis_iu6_i1_type_fp = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_type_fp_l2 :
                                   stall_frn_fdis_iu6_i1_type_fp_l2;
   assign frn_fdis_iu6_i1_type_ap = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_type_ap_l2 :
                                   stall_frn_fdis_iu6_i1_type_ap_l2;
   assign frn_fdis_iu6_i1_type_spv = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_type_spv_l2 :
                                    stall_frn_fdis_iu6_i1_type_spv_l2;
   assign frn_fdis_iu6_i1_type_st = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_type_st_l2 :
                                   stall_frn_fdis_iu6_i1_type_st_l2;
   assign frn_fdis_iu6_i1_async_block = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_async_block_l2 :
                                        stall_frn_fdis_iu6_i1_async_block_l2;
   assign frn_fdis_iu6_i1_np1_flush = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_np1_flush_l2 :
                                      stall_frn_fdis_iu6_i1_np1_flush_l2;
   assign frn_fdis_iu6_i1_core_block = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_core_block_l2 :
                                       stall_frn_fdis_iu6_i1_core_block_l2;
   assign frn_fdis_iu6_i1_isram = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_isram_l2 :
                                  stall_frn_fdis_iu6_i1_isram_l2;
   assign frn_fdis_iu6_i1_isload = (fdis_frn_iu6_stall_l2[18] == 1'b0) ? frn_fdis_iu6_i1_isload_l2 :
                                   stall_frn_fdis_iu6_i1_isload_l2;
   assign frn_fdis_iu6_i1_isstore = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_isstore_l2 :
                                    stall_frn_fdis_iu6_i1_isstore_l2;
   assign frn_fdis_iu6_i1_instr = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_instr_l2 :
                                  stall_frn_fdis_iu6_i1_instr_l2;
   assign frn_fdis_iu6_i1_ifar = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ifar_l2 :
                                 stall_frn_fdis_iu6_i1_ifar_l2;
   assign frn_fdis_iu6_i1_bta = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bta_l2 :
                                stall_frn_fdis_iu6_i1_bta_l2;
   assign frn_fdis_iu6_i1_br_pred = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_br_pred_l2 :
                                    stall_frn_fdis_iu6_i1_br_pred_l2;
   assign frn_fdis_iu6_i1_bh_update = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bh_update_l2 :
                                      stall_frn_fdis_iu6_i1_bh_update_l2;
   assign frn_fdis_iu6_i1_bh0_hist = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bh0_hist_l2 :
                                     stall_frn_fdis_iu6_i1_bh0_hist_l2;
   assign frn_fdis_iu6_i1_bh1_hist = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bh1_hist_l2 :
                                     stall_frn_fdis_iu6_i1_bh1_hist_l2;
   assign frn_fdis_iu6_i1_bh2_hist = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_bh2_hist_l2 :
                                     stall_frn_fdis_iu6_i1_bh2_hist_l2;
   assign frn_fdis_iu6_i1_gshare = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_gshare_l2 :
                                   stall_frn_fdis_iu6_i1_gshare_l2;
   assign frn_fdis_iu6_i1_ls_ptr = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ls_ptr_l2 :
                                   stall_frn_fdis_iu6_i1_ls_ptr_l2;
   assign frn_fdis_iu6_i1_match = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_match_l2 :
                                  stall_frn_fdis_iu6_i1_match_l2;
   assign frn_fdis_iu6_i1_ilat = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_ilat_l2 :
                                 stall_frn_fdis_iu6_i1_ilat_l2;
   assign frn_fdis_iu6_i1_t1_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t1_v_l2 :
                                 stall_frn_fdis_iu6_i1_t1_v_l2;
   assign frn_fdis_iu6_i1_t1_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t1_t_l2 :
                                 stall_frn_fdis_iu6_i1_t1_t_l2;
   assign frn_fdis_iu6_i1_t1_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t1_a_l2 :
                                 stall_frn_fdis_iu6_i1_t1_a_l2;
   assign frn_fdis_iu6_i1_t1_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t1_p_l2 :
                                 stall_frn_fdis_iu6_i1_t1_p_l2;
   assign frn_fdis_iu6_i1_t2_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t2_v_l2 :
                                 stall_frn_fdis_iu6_i1_t2_v_l2;
   assign frn_fdis_iu6_i1_t2_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t2_a_l2 :
                                 stall_frn_fdis_iu6_i1_t2_a_l2;
   assign frn_fdis_iu6_i1_t2_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t2_p_l2 :
                                 stall_frn_fdis_iu6_i1_t2_p_l2;
   assign frn_fdis_iu6_i1_t2_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t2_t_l2 :
                                 stall_frn_fdis_iu6_i1_t2_t_l2;
   assign frn_fdis_iu6_i1_t3_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t3_v_l2 :
                                 stall_frn_fdis_iu6_i1_t3_v_l2;
   assign frn_fdis_iu6_i1_t3_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t3_a_l2 :
                                 stall_frn_fdis_iu6_i1_t3_a_l2;
   assign frn_fdis_iu6_i1_t3_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t3_p_l2 :
                                 stall_frn_fdis_iu6_i1_t3_p_l2;
   assign frn_fdis_iu6_i1_t3_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_t3_t_l2 :
                                 stall_frn_fdis_iu6_i1_t3_t_l2;
   assign frn_fdis_iu6_i1_s1_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_v_l2 :
                                 stall_frn_fdis_iu6_i1_s1_v_l2;
   assign frn_fdis_iu6_i1_s1_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_a_l2 :
                                 stall_frn_fdis_iu6_i1_s1_a_l2;
   assign frn_fdis_iu6_i1_s1_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_p_l2 :
                                 stall_frn_fdis_iu6_i1_s1_p_l2;
   assign frn_fdis_iu6_i1_s1_itag = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_itag_l2 :
                                    stall_frn_fdis_iu6_i1_s1_itag_l2;
   assign frn_fdis_iu6_i1_s1_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_t_l2 :
                                 stall_frn_fdis_iu6_i1_s1_t_l2;
   assign frn_fdis_iu6_i1_s1_dep_hit = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s1_dep_hit_l2 :
                                       stall_frn_fdis_iu6_i1_s1_dep_hit_l2;
   assign frn_fdis_iu6_i1_s2_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_v_l2 :
                                 stall_frn_fdis_iu6_i1_s2_v_l2;
   assign frn_fdis_iu6_i1_s2_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_a_l2 :
                                 stall_frn_fdis_iu6_i1_s2_a_l2;
   assign frn_fdis_iu6_i1_s2_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_p_l2 :
                                 stall_frn_fdis_iu6_i1_s2_p_l2;
   assign frn_fdis_iu6_i1_s2_itag = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_itag_l2 :
                                    stall_frn_fdis_iu6_i1_s2_itag_l2;
   assign frn_fdis_iu6_i1_s2_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_t_l2 :
                                 stall_frn_fdis_iu6_i1_s2_t_l2;
   assign frn_fdis_iu6_i1_s2_dep_hit = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s2_dep_hit_l2 :
                                       stall_frn_fdis_iu6_i1_s2_dep_hit_l2;
   assign frn_fdis_iu6_i1_s3_v = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_v_l2 :
                                 stall_frn_fdis_iu6_i1_s3_v_l2;
   assign frn_fdis_iu6_i1_s3_a = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_a_l2 :
                                 stall_frn_fdis_iu6_i1_s3_a_l2;
   assign frn_fdis_iu6_i1_s3_p = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_p_l2 :
                                 stall_frn_fdis_iu6_i1_s3_p_l2;
   assign frn_fdis_iu6_i1_s3_itag = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_itag_l2 :
                                    stall_frn_fdis_iu6_i1_s3_itag_l2;
   assign frn_fdis_iu6_i1_s3_t = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_t_l2 :
                                 stall_frn_fdis_iu6_i1_s3_t_l2;
   assign frn_fdis_iu6_i1_s3_dep_hit = (fdis_frn_iu6_stall_l2[2] == 1'b0) ? frn_fdis_iu6_i1_s3_dep_hit_l2 :
                                       stall_frn_fdis_iu6_i1_s3_dep_hit_l2;

   // output stall
   assign fdis_frn_iu6_stall_d = {19{((frn_fdis_iu6_i0_vld_l2 | fdis_frn_iu6_stall_l2[0]) & fdis_frn_iu6_stall & (~cp_flush_l2))}};
   // validate stall with iu6 vld for all upstream stages to eliminate any bubbles
   assign fdis_frn_iu6_stall_dly = fdis_frn_iu6_stall_l2[0] & frn_fdis_iu6_i0_vld_l2;

   assign stall_frn_fdis_iu6_i0_act = (~fdis_frn_iu6_stall_l2[0]);
   assign stall_frn_fdis_iu6_i0_vld_d = frn_fdis_iu6_i0_vld_l2;
   assign stall_frn_fdis_iu6_i0_itag_d = frn_fdis_iu6_i0_itag_l2;
   assign stall_frn_fdis_iu6_i0_ucode_d = frn_fdis_iu6_i0_ucode_l2;
   assign stall_frn_fdis_iu6_i0_ucode_cnt_d = frn_fdis_iu6_i0_ucode_cnt_l2;
   assign stall_frn_fdis_iu6_i0_2ucode_d = frn_fdis_iu6_i0_2ucode_l2;
   assign stall_frn_fdis_iu6_i0_fuse_nop_d = frn_fdis_iu6_i0_fuse_nop_l2;
   assign stall_frn_fdis_iu6_i0_rte_lq_d = frn_fdis_iu6_i0_rte_lq_l2;
   assign stall_frn_fdis_iu6_i0_rte_sq_d = frn_fdis_iu6_i0_rte_sq_l2;
   assign stall_frn_fdis_iu6_i0_rte_fx0_d = frn_fdis_iu6_i0_rte_fx0_l2;
   assign stall_frn_fdis_iu6_i0_rte_fx1_d = frn_fdis_iu6_i0_rte_fx1_l2;
   assign stall_frn_fdis_iu6_i0_rte_axu0_d = frn_fdis_iu6_i0_rte_axu0_l2;
   assign stall_frn_fdis_iu6_i0_rte_axu1_d = frn_fdis_iu6_i0_rte_axu1_l2;
   assign stall_frn_fdis_iu6_i0_valop_d = frn_fdis_iu6_i0_valop_l2;
   assign stall_frn_fdis_iu6_i0_ord_d = frn_fdis_iu6_i0_ord_l2;
   assign stall_frn_fdis_iu6_i0_cord_d = frn_fdis_iu6_i0_cord_l2;
   assign stall_frn_fdis_iu6_i0_error_d = frn_fdis_iu6_i0_error_l2;
   assign stall_frn_fdis_iu6_i0_btb_entry_d = frn_fdis_iu6_i0_btb_entry_l2;
   assign stall_frn_fdis_iu6_i0_btb_hist_d = frn_fdis_iu6_i0_btb_hist_l2;
   assign stall_frn_fdis_iu6_i0_bta_val_d = frn_fdis_iu6_i0_bta_val_l2;
   assign stall_frn_fdis_iu6_i0_fusion_d = frn_fdis_iu6_i0_fusion_l2;
   assign stall_frn_fdis_iu6_i0_spec_d = frn_fdis_iu6_i0_spec_l2;
   assign stall_frn_fdis_iu6_i0_type_fp_d = frn_fdis_iu6_i0_type_fp_l2;
   assign stall_frn_fdis_iu6_i0_type_ap_d = frn_fdis_iu6_i0_type_ap_l2;
   assign stall_frn_fdis_iu6_i0_type_spv_d = frn_fdis_iu6_i0_type_spv_l2;
   assign stall_frn_fdis_iu6_i0_type_st_d = frn_fdis_iu6_i0_type_st_l2;
   assign stall_frn_fdis_iu6_i0_async_block_d = frn_fdis_iu6_i0_async_block_l2;
   assign stall_frn_fdis_iu6_i0_np1_flush_d = frn_fdis_iu6_i0_np1_flush_l2;
   assign stall_frn_fdis_iu6_i0_core_block_d = frn_fdis_iu6_i0_core_block_l2;
   assign stall_frn_fdis_iu6_i0_isram_d = frn_fdis_iu6_i0_isram_l2;
   assign stall_frn_fdis_iu6_i0_isload_d = frn_fdis_iu6_i0_isload_l2;
   assign stall_frn_fdis_iu6_i0_isstore_d = frn_fdis_iu6_i0_isstore_l2;
   assign stall_frn_fdis_iu6_i0_instr_d = frn_fdis_iu6_i0_instr_l2;
   assign stall_frn_fdis_iu6_i0_ifar_d = frn_fdis_iu6_i0_ifar_l2;
   assign stall_frn_fdis_iu6_i0_bta_d = frn_fdis_iu6_i0_bta_l2;
   assign stall_frn_fdis_iu6_i0_br_pred_d = frn_fdis_iu6_i0_br_pred_l2;
   assign stall_frn_fdis_iu6_i0_bh_update_d = frn_fdis_iu6_i0_bh_update_l2;
   assign stall_frn_fdis_iu6_i0_bh0_hist_d = frn_fdis_iu6_i0_bh0_hist_l2;
   assign stall_frn_fdis_iu6_i0_bh1_hist_d = frn_fdis_iu6_i0_bh1_hist_l2;
   assign stall_frn_fdis_iu6_i0_bh2_hist_d = frn_fdis_iu6_i0_bh2_hist_l2;
   assign stall_frn_fdis_iu6_i0_gshare_d = frn_fdis_iu6_i0_gshare_l2;
   assign stall_frn_fdis_iu6_i0_ls_ptr_d = frn_fdis_iu6_i0_ls_ptr_l2;
   assign stall_frn_fdis_iu6_i0_match_d = frn_fdis_iu6_i0_match_l2;
   assign stall_frn_fdis_iu6_i0_ilat_d = frn_fdis_iu6_i0_ilat_l2;
   assign stall_frn_fdis_iu6_i0_t1_v_d = frn_fdis_iu6_i0_t1_v_l2;
   assign stall_frn_fdis_iu6_i0_t1_t_d = frn_fdis_iu6_i0_t1_t_l2;
   assign stall_frn_fdis_iu6_i0_t1_a_d = frn_fdis_iu6_i0_t1_a_l2;
   assign stall_frn_fdis_iu6_i0_t1_p_d = frn_fdis_iu6_i0_t1_p_l2;
   assign stall_frn_fdis_iu6_i0_t2_v_d = frn_fdis_iu6_i0_t2_v_l2;
   assign stall_frn_fdis_iu6_i0_t2_a_d = frn_fdis_iu6_i0_t2_a_l2;
   assign stall_frn_fdis_iu6_i0_t2_p_d = frn_fdis_iu6_i0_t2_p_l2;
   assign stall_frn_fdis_iu6_i0_t2_t_d = frn_fdis_iu6_i0_t2_t_l2;
   assign stall_frn_fdis_iu6_i0_t3_v_d = frn_fdis_iu6_i0_t3_v_l2;
   assign stall_frn_fdis_iu6_i0_t3_a_d = frn_fdis_iu6_i0_t3_a_l2;
   assign stall_frn_fdis_iu6_i0_t3_p_d = frn_fdis_iu6_i0_t3_p_l2;
   assign stall_frn_fdis_iu6_i0_t3_t_d = frn_fdis_iu6_i0_t3_t_l2;
   assign stall_frn_fdis_iu6_i0_s1_v_d = frn_fdis_iu6_i0_s1_v_l2;
   assign stall_frn_fdis_iu6_i0_s1_a_d = frn_fdis_iu6_i0_s1_a_l2;
   assign stall_frn_fdis_iu6_i0_s1_p_d = frn_fdis_iu6_i0_s1_p_l2;
   assign stall_frn_fdis_iu6_i0_s1_itag_d = frn_fdis_iu6_i0_s1_itag_l2;
   assign stall_frn_fdis_iu6_i0_s1_t_d = frn_fdis_iu6_i0_s1_t_l2;
   assign stall_frn_fdis_iu6_i0_s2_v_d = frn_fdis_iu6_i0_s2_v_l2;
   assign stall_frn_fdis_iu6_i0_s2_a_d = frn_fdis_iu6_i0_s2_a_l2;
   assign stall_frn_fdis_iu6_i0_s2_p_d = frn_fdis_iu6_i0_s2_p_l2;
   assign stall_frn_fdis_iu6_i0_s2_itag_d = frn_fdis_iu6_i0_s2_itag_l2;
   assign stall_frn_fdis_iu6_i0_s2_t_d = frn_fdis_iu6_i0_s2_t_l2;
   assign stall_frn_fdis_iu6_i0_s3_v_d = frn_fdis_iu6_i0_s3_v_l2;
   assign stall_frn_fdis_iu6_i0_s3_a_d = frn_fdis_iu6_i0_s3_a_l2;
   assign stall_frn_fdis_iu6_i0_s3_p_d = frn_fdis_iu6_i0_s3_p_l2;
   assign stall_frn_fdis_iu6_i0_s3_itag_d = frn_fdis_iu6_i0_s3_itag_l2;
   assign stall_frn_fdis_iu6_i0_s3_t_d = frn_fdis_iu6_i0_s3_t_l2;

   assign stall_frn_fdis_iu6_i1_act = (~fdis_frn_iu6_stall_l2[0]);
   assign stall_frn_fdis_iu6_i1_vld_d = frn_fdis_iu6_i1_vld_l2;
   assign stall_frn_fdis_iu6_i1_itag_d = frn_fdis_iu6_i1_itag_l2;
   assign stall_frn_fdis_iu6_i1_ucode_d = frn_fdis_iu6_i1_ucode_l2;
   assign stall_frn_fdis_iu6_i1_ucode_cnt_d = frn_fdis_iu6_i1_ucode_cnt_l2;
   assign stall_frn_fdis_iu6_i1_fuse_nop_d = frn_fdis_iu6_i1_fuse_nop_l2;
   assign stall_frn_fdis_iu6_i1_rte_lq_d = frn_fdis_iu6_i1_rte_lq_l2;
   assign stall_frn_fdis_iu6_i1_rte_sq_d = frn_fdis_iu6_i1_rte_sq_l2;
   assign stall_frn_fdis_iu6_i1_rte_fx0_d = frn_fdis_iu6_i1_rte_fx0_l2;
   assign stall_frn_fdis_iu6_i1_rte_fx1_d = frn_fdis_iu6_i1_rte_fx1_l2;
   assign stall_frn_fdis_iu6_i1_rte_axu0_d = frn_fdis_iu6_i1_rte_axu0_l2;
   assign stall_frn_fdis_iu6_i1_rte_axu1_d = frn_fdis_iu6_i1_rte_axu1_l2;
   assign stall_frn_fdis_iu6_i1_valop_d = frn_fdis_iu6_i1_valop_l2;
   assign stall_frn_fdis_iu6_i1_ord_d = frn_fdis_iu6_i1_ord_l2;
   assign stall_frn_fdis_iu6_i1_cord_d = frn_fdis_iu6_i1_cord_l2;
   assign stall_frn_fdis_iu6_i1_error_d = frn_fdis_iu6_i1_error_l2;
   assign stall_frn_fdis_iu6_i1_btb_entry_d = frn_fdis_iu6_i1_btb_entry_l2;
   assign stall_frn_fdis_iu6_i1_btb_hist_d = frn_fdis_iu6_i1_btb_hist_l2;
   assign stall_frn_fdis_iu6_i1_bta_val_d = frn_fdis_iu6_i1_bta_val_l2;
   assign stall_frn_fdis_iu6_i1_fusion_d = frn_fdis_iu6_i1_fusion_l2;
   assign stall_frn_fdis_iu6_i1_spec_d = frn_fdis_iu6_i1_spec_l2;
   assign stall_frn_fdis_iu6_i1_type_fp_d = frn_fdis_iu6_i1_type_fp_l2;
   assign stall_frn_fdis_iu6_i1_type_ap_d = frn_fdis_iu6_i1_type_ap_l2;
   assign stall_frn_fdis_iu6_i1_type_spv_d = frn_fdis_iu6_i1_type_spv_l2;
   assign stall_frn_fdis_iu6_i1_type_st_d = frn_fdis_iu6_i1_type_st_l2;
   assign stall_frn_fdis_iu6_i1_async_block_d = frn_fdis_iu6_i1_async_block_l2;
   assign stall_frn_fdis_iu6_i1_np1_flush_d = frn_fdis_iu6_i1_np1_flush_l2;
   assign stall_frn_fdis_iu6_i1_core_block_d = frn_fdis_iu6_i1_core_block_l2;
   assign stall_frn_fdis_iu6_i1_isram_d = frn_fdis_iu6_i1_isram_l2;
   assign stall_frn_fdis_iu6_i1_isload_d = frn_fdis_iu6_i1_isload_l2;
   assign stall_frn_fdis_iu6_i1_isstore_d = frn_fdis_iu6_i1_isstore_l2;
   assign stall_frn_fdis_iu6_i1_instr_d = frn_fdis_iu6_i1_instr_l2;
   assign stall_frn_fdis_iu6_i1_ifar_d = frn_fdis_iu6_i1_ifar_l2;
   assign stall_frn_fdis_iu6_i1_bta_d = frn_fdis_iu6_i1_bta_l2;
   assign stall_frn_fdis_iu6_i1_br_pred_d = frn_fdis_iu6_i1_br_pred_l2;
   assign stall_frn_fdis_iu6_i1_bh_update_d = frn_fdis_iu6_i1_bh_update_l2;
   assign stall_frn_fdis_iu6_i1_bh0_hist_d = frn_fdis_iu6_i1_bh0_hist_l2;
   assign stall_frn_fdis_iu6_i1_bh1_hist_d = frn_fdis_iu6_i1_bh1_hist_l2;
   assign stall_frn_fdis_iu6_i1_bh2_hist_d = frn_fdis_iu6_i1_bh2_hist_l2;
   assign stall_frn_fdis_iu6_i1_gshare_d = frn_fdis_iu6_i1_gshare_l2;
   assign stall_frn_fdis_iu6_i1_ls_ptr_d = frn_fdis_iu6_i1_ls_ptr_l2;
   assign stall_frn_fdis_iu6_i1_match_d = frn_fdis_iu6_i1_match_l2;
   assign stall_frn_fdis_iu6_i1_ilat_d = frn_fdis_iu6_i1_ilat_l2;
   assign stall_frn_fdis_iu6_i1_t1_v_d = frn_fdis_iu6_i1_t1_v_l2;
   assign stall_frn_fdis_iu6_i1_t1_t_d = frn_fdis_iu6_i1_t1_t_l2;
   assign stall_frn_fdis_iu6_i1_t1_a_d = frn_fdis_iu6_i1_t1_a_l2;
   assign stall_frn_fdis_iu6_i1_t1_p_d = frn_fdis_iu6_i1_t1_p_l2;
   assign stall_frn_fdis_iu6_i1_t2_v_d = frn_fdis_iu6_i1_t2_v_l2;
   assign stall_frn_fdis_iu6_i1_t2_a_d = frn_fdis_iu6_i1_t2_a_l2;
   assign stall_frn_fdis_iu6_i1_t2_p_d = frn_fdis_iu6_i1_t2_p_l2;
   assign stall_frn_fdis_iu6_i1_t2_t_d = frn_fdis_iu6_i1_t2_t_l2;
   assign stall_frn_fdis_iu6_i1_t3_v_d = frn_fdis_iu6_i1_t3_v_l2;
   assign stall_frn_fdis_iu6_i1_t3_a_d = frn_fdis_iu6_i1_t3_a_l2;
   assign stall_frn_fdis_iu6_i1_t3_p_d = frn_fdis_iu6_i1_t3_p_l2;
   assign stall_frn_fdis_iu6_i1_t3_t_d = frn_fdis_iu6_i1_t3_t_l2;
   assign stall_frn_fdis_iu6_i1_s1_v_d = frn_fdis_iu6_i1_s1_v_l2;
   assign stall_frn_fdis_iu6_i1_s1_a_d = frn_fdis_iu6_i1_s1_a_l2;
   assign stall_frn_fdis_iu6_i1_s1_p_d = frn_fdis_iu6_i1_s1_p_l2;
   assign stall_frn_fdis_iu6_i1_s1_itag_d = frn_fdis_iu6_i1_s1_itag_l2;
   assign stall_frn_fdis_iu6_i1_s1_t_d = frn_fdis_iu6_i1_s1_t_l2;
   assign stall_frn_fdis_iu6_i1_s1_dep_hit_d = frn_fdis_iu6_i1_s1_dep_hit_l2;
   assign stall_frn_fdis_iu6_i1_s2_v_d = frn_fdis_iu6_i1_s2_v_l2;
   assign stall_frn_fdis_iu6_i1_s2_a_d = frn_fdis_iu6_i1_s2_a_l2;
   assign stall_frn_fdis_iu6_i1_s2_p_d = frn_fdis_iu6_i1_s2_p_l2;
   assign stall_frn_fdis_iu6_i1_s2_itag_d = frn_fdis_iu6_i1_s2_itag_l2;
   assign stall_frn_fdis_iu6_i1_s2_t_d = frn_fdis_iu6_i1_s2_t_l2;
   assign stall_frn_fdis_iu6_i1_s2_dep_hit_d = frn_fdis_iu6_i1_s2_dep_hit_l2;
   assign stall_frn_fdis_iu6_i1_s3_v_d = frn_fdis_iu6_i1_s3_v_l2;
   assign stall_frn_fdis_iu6_i1_s3_a_d = frn_fdis_iu6_i1_s3_a_l2;
   assign stall_frn_fdis_iu6_i1_s3_p_d = frn_fdis_iu6_i1_s3_p_l2;
   assign stall_frn_fdis_iu6_i1_s3_itag_d = frn_fdis_iu6_i1_s3_itag_l2;
   assign stall_frn_fdis_iu6_i1_s3_t_d = frn_fdis_iu6_i1_s3_t_l2;
   assign stall_frn_fdis_iu6_i1_s3_dep_hit_d = frn_fdis_iu6_i1_s3_dep_hit_l2;

   assign inc_0 = (fdec_frn_iu5_i0_vld & send_instructions);
   assign inc_1 = (fdec_frn_iu5_i1_vld & send_instructions);


   iuq_cpl_ctrl_inc #(.SIZE(`ITAG_SIZE_ENC), .WRAP(`CPL_Q_DEPTH - 1)) iu6_i0_itag_inc(
      .inc({inc_0, inc_1}),
      .i(next_itag_0_l2),
      .o(i0_itag_next)
   );


   iuq_cpl_ctrl_inc #(.SIZE(`ITAG_SIZE_ENC), .WRAP(`CPL_Q_DEPTH - 1)) iu6_i1_itag_inc(
      .inc({inc_0, inc_1}),
      .i(next_itag_1_l2),
      .o(i1_itag_next)
   );

   assign next_itag_0_d = ((cp_flush_l2) == 1'b1) ? cp_rn_i0_itag :
                          i0_itag_next;

   assign next_itag_1_d = ((cp_flush_l2) == 1'b1) ? cp_rn_i1_itag :
                          i1_itag_next;

   assign cp_flush_d = cp_flush;
   assign cp_flush_into_uc_d = cp_flush_into_uc;
   assign br_iu_hold_d = ((br_iu_redirect | br_iu_hold_l2) |
                          (send_instructions & fdec_frn_iu5_i0_np1_flush) |
                          (send_instructions & fdec_frn_iu5_i1_vld & fdec_frn_iu5_i1_np1_flush)) & (~cp_flush_l2);

   assign gpr_send_cnt = {(fdec_frn_iu5_i0_t1_v & ~fdec_frn_iu5_i0_t1_t[0] & ~fdec_frn_iu5_i0_t1_t[1] & ~fdec_frn_iu5_i0_t1_t[2]),
                          (fdec_frn_iu5_i1_t1_v & ~fdec_frn_iu5_i1_t1_t[0] & ~fdec_frn_iu5_i1_t1_t[1] & ~fdec_frn_iu5_i1_t1_t[2])};

   assign cr_send_cnt = {((fdec_frn_iu5_i0_t3_v & ~fdec_frn_iu5_i0_t3_t[0] & ~fdec_frn_iu5_i0_t3_t[1] & fdec_frn_iu5_i0_t3_t[2]) |
                          (fdec_frn_iu5_i0_t1_v & ~fdec_frn_iu5_i0_t1_t[0] & ~fdec_frn_iu5_i0_t1_t[1] & fdec_frn_iu5_i0_t1_t[2])),
                         ((fdec_frn_iu5_i1_t3_v & ~fdec_frn_iu5_i1_t3_t[0] & ~fdec_frn_iu5_i1_t3_t[1] & fdec_frn_iu5_i1_t3_t[2]) |
                          (fdec_frn_iu5_i1_t1_v & ~fdec_frn_iu5_i1_t1_t[0] & ~fdec_frn_iu5_i1_t1_t[1] & fdec_frn_iu5_i1_t1_t[2]))};

   assign cr_send_t1_cnt = {(fdec_frn_iu5_i0_t1_v & ~fdec_frn_iu5_i0_t1_t[0] & ~fdec_frn_iu5_i0_t1_t[1] & fdec_frn_iu5_i0_t1_t[2]),
                            (fdec_frn_iu5_i1_t1_v & ~fdec_frn_iu5_i1_t1_t[0] & ~fdec_frn_iu5_i1_t1_t[1] & fdec_frn_iu5_i1_t1_t[2])};

   assign cr_send_t3_cnt = {(fdec_frn_iu5_i0_t3_v & ~fdec_frn_iu5_i0_t3_t[0] & ~fdec_frn_iu5_i0_t3_t[1] & fdec_frn_iu5_i0_t3_t[2]),
                            (fdec_frn_iu5_i1_t3_v & ~fdec_frn_iu5_i1_t3_t[0] & ~fdec_frn_iu5_i1_t3_t[1] & fdec_frn_iu5_i1_t3_t[2])};

   assign lr_send_cnt = {(fdec_frn_iu5_i0_t3_v & ~fdec_frn_iu5_i0_t3_t[0] & fdec_frn_iu5_i0_t3_t[1] & ~fdec_frn_iu5_i0_t3_t[2]),
                         (fdec_frn_iu5_i1_t3_v & ~fdec_frn_iu5_i1_t3_t[0] & fdec_frn_iu5_i1_t3_t[1] & ~fdec_frn_iu5_i1_t3_t[2])};

   assign ctr_send_cnt = {(fdec_frn_iu5_i0_t2_v & ~fdec_frn_iu5_i0_t2_t[0] & fdec_frn_iu5_i0_t2_t[1] & fdec_frn_iu5_i0_t2_t[2]),
                          (fdec_frn_iu5_i1_t2_v & ~fdec_frn_iu5_i1_t2_t[0] & fdec_frn_iu5_i1_t2_t[1] & fdec_frn_iu5_i1_t2_t[2])};

   assign xer_send_cnt = {(fdec_frn_iu5_i0_t2_v & fdec_frn_iu5_i0_t2_t[0] & ~fdec_frn_iu5_i0_t2_t[1] & ~fdec_frn_iu5_i0_t2_t[2]),
                          (fdec_frn_iu5_i1_t2_v & fdec_frn_iu5_i1_t2_t[0] & ~fdec_frn_iu5_i1_t2_t[1] & ~fdec_frn_iu5_i1_t2_t[2])};

   assign ucode_send_cnt = {(fdec_frn_iu5_i0_ucode[1]), (fdec_frn_iu5_i1_ucode[1])};

   assign cp_credit_cnt_mux = ({`CPL_Q_DEPTH_ENC{high_pri_mask_l2}} & cp_high_credit_cnt_l2) |
                              ({`CPL_Q_DEPTH_ENC{~high_pri_mask_l2}} & cp_med_credit_cnt_l2);

   assign cpl_credit_ok = ((~fdec_frn_iu5_i0_vld & ~fdec_frn_iu5_i1_vld) |
                           ((fdec_frn_iu5_i0_vld ^ fdec_frn_iu5_i1_vld) & |cp_credit_cnt_mux) |
                           (|cp_credit_cnt_mux[0:`CPL_Q_DEPTH_ENC - 1]));

   assign gpr_send_ok = (~gpr_send_cnt[0] & ~gpr_send_cnt[1]) |
                        ((gpr_send_cnt[0] ^ gpr_send_cnt[1]) & next_gpr_0_v) |
                        (next_gpr_0_v & next_gpr_1_v);

   assign cr_send_ok = (~cr_send_cnt[0] & ~cr_send_cnt[1]) |
                       ((cr_send_cnt[0] ^ cr_send_cnt[1]) & next_cr_0_v) |
                       (next_cr_0_v & next_cr_1_v);

   assign lr_send_ok = (~lr_send_cnt[0] & ~lr_send_cnt[1]) |
                       ((lr_send_cnt[0] ^ lr_send_cnt[1]) & next_lr_0_v) |
                       (next_lr_0_v & next_lr_1_v);

   assign ctr_send_ok = (~ctr_send_cnt[0] & ~ctr_send_cnt[1]) |
                        ((ctr_send_cnt[0] ^ ctr_send_cnt[1]) & next_ctr_0_v) |
                        (next_ctr_0_v & next_ctr_1_v);

   assign xer_send_ok = (~xer_send_cnt[0] & ~xer_send_cnt[1]) |
                        ((xer_send_cnt[0] ^ xer_send_cnt[1]) & next_xer_0_v) |
                        (next_xer_0_v & next_xer_1_v);

   assign cp_empty_ok = (((fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_core_block) | (fdec_frn_iu5_i1_vld & fdec_frn_iu5_i1_core_block)) & cp_rn_empty_l2) |
                        (~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_core_block) & ~(fdec_frn_iu5_i1_vld & fdec_frn_iu5_i1_core_block));

   assign send_instructions = (cpl_credit_ok & gpr_send_ok & cr_send_ok & lr_send_ok & ctr_send_ok & xer_send_ok & cp_empty_ok &
                               au_iu_iu5_axu0_send_ok & au_iu_iu5_axu1_send_ok & fdec_frn_iu5_i0_vld) & (~(hold_instructions_l2));

   assign hold_instructions_d = (fdis_frn_iu6_stall_d[0] & frn_fdis_iu6_i0_vld_d) | br_iu_hold_d | cp_flush_d;


   // To AXU rename
   assign iu_au_iu5_send_ok = (cpl_credit_ok & gpr_send_ok & cr_send_ok & lr_send_ok & ctr_send_ok & xer_send_ok & cp_empty_ok) & (~fdis_frn_iu6_stall_dly);
   assign iu_au_iu5_next_itag_i0 = next_itag_0_l2;
   assign iu_au_iu5_next_itag_i1 = next_itag_1_l2;


   assign high_cnt_plus2_temp = cp_high_credit_cnt_l2 + value_2[31-`CPL_Q_DEPTH_ENC:31];
   assign high_cnt_plus2 = (high_cnt_plus2_temp > spr_cpcr3_cp_cnt) ? spr_cpcr3_cp_cnt :
                            high_cnt_plus2_temp;

   assign high_cnt_plus1_temp = cp_high_credit_cnt_l2 + value_1[31-`CPL_Q_DEPTH_ENC:31];
   assign high_cnt_plus1 = (high_cnt_plus1_temp > spr_cpcr3_cp_cnt) ? spr_cpcr3_cp_cnt :
                            high_cnt_plus1_temp;

   assign high_cnt_minus1_temp = cp_high_credit_cnt_l2 - value_1[31-`CPL_Q_DEPTH_ENC:31];
   assign high_cnt_minus1 = high_cnt_minus1_temp[0] == 1'b1 ? `CPL_Q_DEPTH_ENC'b0 :
                            high_cnt_minus1_temp;

   assign high_cnt_minus2_temp = cp_high_credit_cnt_l2 - value_2[31-`CPL_Q_DEPTH_ENC:31];
   assign high_cnt_minus2 = high_cnt_minus2_temp[0] == 1'b1 ? `CPL_Q_DEPTH_ENC'b0 :
                            high_cnt_minus2_temp;

   assign med_cnt_plus2_temp = cp_med_credit_cnt_l2 + value_2[31-`CPL_Q_DEPTH_ENC:31];
   assign med_cnt_plus2 = (med_cnt_plus2_temp > spr_cpcr5_cp_cnt) ? spr_cpcr5_cp_cnt :
                           med_cnt_plus2_temp;

   assign med_cnt_plus1_temp = cp_med_credit_cnt_l2 + value_1[31-`CPL_Q_DEPTH_ENC:31];
   assign med_cnt_plus1 = (med_cnt_plus1_temp > spr_cpcr5_cp_cnt) ? spr_cpcr5_cp_cnt :
                           med_cnt_plus1_temp;

   assign med_cnt_minus1_temp = cp_med_credit_cnt_l2 - value_1[31-`CPL_Q_DEPTH_ENC:31];
   assign med_cnt_minus1 = med_cnt_minus1_temp[0] == 1'b1 ? `CPL_Q_DEPTH_ENC'b0 :
                           med_cnt_minus1_temp;

   assign med_cnt_minus2_temp = cp_med_credit_cnt_l2 - value_2[31-`CPL_Q_DEPTH_ENC:31];
   assign med_cnt_minus2 = med_cnt_minus2_temp[0] == 1'b1 ? `CPL_Q_DEPTH_ENC'b0 :
                           med_cnt_minus2_temp;


   always @(*)
   begin: cp_credit_proc
      cp_high_credit_cnt_d <= cp_high_credit_cnt_l2;
      cp_med_credit_cnt_d <= cp_med_credit_cnt_l2;

      if (spr_cpcr_we == 1'b1 | cp_flush_l2 == 1'b1)
         if (spr_single_issue == 1'b1)
         begin
            cp_high_credit_cnt_d <= 7'b0000010;
            cp_med_credit_cnt_d <= 7'b0000010;
         end
         else if(spr_cpcr_we == 1'b1)
         begin
            cp_high_credit_cnt_d <= spr_cpcr3_cp_cnt - value_1[31-`CPL_Q_DEPTH_ENC:31];
            cp_med_credit_cnt_d <= spr_cpcr5_cp_cnt - value_1[31-`CPL_Q_DEPTH_ENC:31];
         end
         else
         begin
            cp_high_credit_cnt_d <= spr_cpcr3_cp_cnt;
            cp_med_credit_cnt_d <= spr_cpcr5_cp_cnt;
         end
      else
         if (send_instructions == 1'b0)
         begin
            if (cp_rn_i0_v == 1'b1 ^ cp_rn_i1_v == 1'b1)
            begin
               cp_high_credit_cnt_d <= high_cnt_plus1;
               cp_med_credit_cnt_d <= med_cnt_plus1;
            end
            else if (cp_rn_i0_v == 1'b1 & cp_rn_i1_v == 1'b1)
            begin
               cp_high_credit_cnt_d <= high_cnt_plus2;
               cp_med_credit_cnt_d <= med_cnt_plus2;
            end
         end
         else if (send_instructions == 1'b1)
         begin
            if (fdec_frn_iu5_i1_vld == 1'b1 & (cp_rn_i0_v == 1'b1 ^ cp_rn_i1_v == 1'b1))
            begin
               cp_high_credit_cnt_d <= high_cnt_minus1;
               cp_med_credit_cnt_d <= med_cnt_minus1;
            end
            else if (fdec_frn_iu5_i1_vld == 1'b0 & (cp_rn_i0_v == 1'b1 & cp_rn_i1_v == 1'b1))
            begin
               cp_high_credit_cnt_d <= high_cnt_plus1;
               cp_med_credit_cnt_d <= med_cnt_plus1;
            end
            else if (cp_rn_i0_v == 1'b0 & cp_rn_i1_v == 1'b0)
            begin
               if (fdec_frn_iu5_i1_vld == 1'b1)
               begin
                  cp_high_credit_cnt_d <= high_cnt_minus2;
                  cp_med_credit_cnt_d <= med_cnt_minus2;
               end
               else
               begin
                  cp_high_credit_cnt_d <= high_cnt_minus1;
                  cp_med_credit_cnt_d <= med_cnt_minus1;
               end
            end
         end
   end


   always @(*)
   begin: ucode_cnt_proc
      ucode_cnt_d <= ucode_cnt_l2;

      if (cp_flush_l2 == 1'b1 & cp_flush_into_uc_l2 == 1'b0)
         ucode_cnt_d <= ucode_cnt_save_l2 - value_1[32-`UCODE_ENTRIES_ENC:31];
      else if (cp_flush_l2 == 1'b1 & cp_flush_into_uc_l2 == 1'b1)
         ucode_cnt_d <= ucode_cnt_save_l2;
      else
         if (send_instructions == 1'b1 & (ucode_send_cnt[0] == 1'b1 | ucode_send_cnt[1] == 1'b1))
            ucode_cnt_d <= ucode_cnt_l2 + value_1[32-`UCODE_ENTRIES_ENC:31];
   end


   always @(*)
   begin: ucode_cnt_save_proc
      ucode_cnt_save_d <= ucode_cnt_save_l2;

      if (cp_rn_uc_credit_free == 1'b1)
         ucode_cnt_save_d <= ucode_cnt_save_l2 + value_1[32-`UCODE_ENTRIES_ENC:31];
   end

   assign ucode_cnt_i0 = (ucode_send_cnt[0] == 1'b1) ? ucode_cnt_l2 + value_1[32-`UCODE_ENTRIES_ENC:31] :
                         ucode_cnt_l2;
   assign ucode_cnt_i1 = (ucode_send_cnt[1] == 1'b1) ? ucode_cnt_l2 + value_1[32-`UCODE_ENTRIES_ENC:31] :
                         ucode_cnt_l2;

   //-----------------------------------------------------------------------
   //-- Outputs
   //-----------------------------------------------------------------------

   assign frn_fdec_iu5_stall = (~(cpl_credit_ok & gpr_send_ok & cr_send_ok & lr_send_ok & ctr_send_ok & xer_send_ok & cp_empty_ok)) | br_iu_hold_l2 | au_iu_iu5_stall | (fdec_frn_iu5_i0_vld & fdis_frn_iu6_stall_dly);		// AXU Rename Stall

   assign frn_fdis_iu6_i0_act = fdec_frn_iu5_i0_vld & (~(fdis_frn_iu6_stall_dly));
   assign frn_fdis_iu6_i0_vld_d = ((send_instructions & fdec_frn_iu5_i0_vld) | (frn_fdis_iu6_i0_vld_l2 & fdis_frn_iu6_stall_dly)) & (~(cp_flush_l2));
   assign frn_fdis_iu6_i0_itag_d = next_itag_0_l2;
   assign frn_fdis_iu6_i0_ucode_d = fdec_frn_iu5_i0_ucode;
   assign frn_fdis_iu6_i0_ucode_cnt_d = ucode_cnt_i0;
   assign frn_fdis_iu6_i0_2ucode_d = fdec_frn_iu5_i0_2ucode;
   assign frn_fdis_iu6_i0_fuse_nop_d = fdec_frn_iu5_i0_fuse_nop;
   assign frn_fdis_iu6_i0_rte_fx0_d = fdec_frn_iu5_i0_rte_fx0;
   assign frn_fdis_iu6_i0_rte_fx1_d = fdec_frn_iu5_i0_rte_fx1;
   assign frn_fdis_iu6_i0_rte_lq_d = fdec_frn_iu5_i0_rte_lq;
   assign frn_fdis_iu6_i0_rte_sq_d = fdec_frn_iu5_i0_rte_sq;
   assign frn_fdis_iu6_i0_rte_axu0_d = fdec_frn_iu5_i0_rte_axu0;
   assign frn_fdis_iu6_i0_rte_axu1_d = fdec_frn_iu5_i0_rte_axu1;
   assign frn_fdis_iu6_i0_valop_d = fdec_frn_iu5_i0_valop;
   assign frn_fdis_iu6_i0_ord_d = fdec_frn_iu5_i0_ord;
   assign frn_fdis_iu6_i0_cord_d = fdec_frn_iu5_i0_cord;
   assign frn_fdis_iu6_i0_error_d = fdec_frn_iu5_i0_error;
   assign frn_fdis_iu6_i0_btb_entry_d = fdec_frn_iu5_i0_btb_entry;
   assign frn_fdis_iu6_i0_btb_hist_d = fdec_frn_iu5_i0_btb_hist;
   assign frn_fdis_iu6_i0_bta_val_d = fdec_frn_iu5_i0_bta_val;
   assign frn_fdis_iu6_i0_fusion_d = fdec_frn_iu5_i0_fusion;
   assign frn_fdis_iu6_i0_spec_d = fdec_frn_iu5_i0_spec;
   assign frn_fdis_iu6_i0_type_fp_d = fdec_frn_iu5_i0_type_fp;
   assign frn_fdis_iu6_i0_type_ap_d = fdec_frn_iu5_i0_type_ap;
   assign frn_fdis_iu6_i0_type_spv_d = fdec_frn_iu5_i0_type_spv;
   assign frn_fdis_iu6_i0_type_st_d = fdec_frn_iu5_i0_type_st;
   assign frn_fdis_iu6_i0_async_block_d = fdec_frn_iu5_i0_async_block;
   assign frn_fdis_iu6_i0_np1_flush_d = fdec_frn_iu5_i0_np1_flush;
   assign frn_fdis_iu6_i0_core_block_d = fdec_frn_iu5_i0_core_block;
   assign frn_fdis_iu6_i0_isram_d = fdec_frn_iu5_i0_isram;
   assign frn_fdis_iu6_i0_isload_d = fdec_frn_iu5_i0_rte_lq & fdec_frn_iu5_i0_isload;
   assign frn_fdis_iu6_i0_isstore_d = fdec_frn_iu5_i0_rte_sq & fdec_frn_iu5_i0_isstore;
   assign frn_fdis_iu6_i0_instr_d = fdec_frn_iu5_i0_instr;
   assign frn_fdis_iu6_i0_ifar_d = fdec_frn_iu5_i0_ifar;
   assign frn_fdis_iu6_i0_bta_d = fdec_frn_iu5_i0_bta;
   assign frn_fdis_iu6_i0_br_pred_d = fdec_frn_iu5_i0_br_pred;
   assign frn_fdis_iu6_i0_bh_update_d = fdec_frn_iu5_i0_bh_update;
   assign frn_fdis_iu6_i0_bh0_hist_d = fdec_frn_iu5_i0_bh0_hist;
   assign frn_fdis_iu6_i0_bh1_hist_d = fdec_frn_iu5_i0_bh1_hist;
   assign frn_fdis_iu6_i0_bh2_hist_d = fdec_frn_iu5_i0_bh2_hist;
   assign frn_fdis_iu6_i0_gshare_d = fdec_frn_iu5_i0_gshare;
   assign frn_fdis_iu6_i0_ls_ptr_d = fdec_frn_iu5_i0_ls_ptr;
   assign frn_fdis_iu6_i0_match_d = fdec_frn_iu5_i0_match;
   assign frn_fdis_iu6_i0_ilat_d = fdec_frn_iu5_i0_ilat;
   assign frn_fdis_iu6_i0_t1_v_d = fdec_frn_iu5_i0_t1_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_t1_t_d = fdec_frn_iu5_i0_t1_t;
   assign frn_fdis_iu6_i0_t1_a_d = fdec_frn_iu5_i0_t1_a;
   assign frn_fdis_iu6_i0_t1_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t1_t == `gpr_t)}} & next_gpr_0) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t1_t == `cr_t)}} & {1'b0, next_cr_0}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t1_t == `axu0_t)}} & au_iu_iu5_i0_t1_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t1_t == `axu1_t)}} & au_iu_iu5_i0_t1_p);
   assign frn_fdis_iu6_i0_t2_v_d = fdec_frn_iu5_i0_t2_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_t2_a_d = fdec_frn_iu5_i0_t2_a;
   assign frn_fdis_iu6_i0_t2_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t2_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, next_ctr_0}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t2_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, next_xer_0}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t2_t == `axu0_t)}} & au_iu_iu5_i0_t2_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t2_t == `axu1_t)}} & au_iu_iu5_i0_t2_p);
   assign frn_fdis_iu6_i0_t2_t_d = fdec_frn_iu5_i0_t2_t;
   assign frn_fdis_iu6_i0_t3_v_d = fdec_frn_iu5_i0_t3_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_t3_a_d = fdec_frn_iu5_i0_t3_a;
   assign frn_fdis_iu6_i0_t3_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t3_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, next_lr_0}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_t3_t == `cr_t)}} & {1'b0, next_cr_0});
   assign frn_fdis_iu6_i0_t3_t_d = fdec_frn_iu5_i0_t3_t;

   assign frn_fdis_iu6_i0_s1_v_d = fdec_frn_iu5_i0_s1_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_s1_a_d = fdec_frn_iu5_i0_s1_a;
   assign frn_fdis_iu6_i0_s1_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `gpr_t)}} & gpr_iu5_i0_src1_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i0_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i0_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i0_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i0_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `axu0_t)}} & au_iu_iu5_i0_s1_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s1_t == `axu1_t)}} & au_iu_iu5_i0_s1_p);
   assign frn_fdis_iu6_i0_s1_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `gpr_t)}} & gpr_iu5_i0_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `cr_t)}} & cr_iu5_i0_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `lr_t)}} & lr_iu5_i0_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `ctr_t)}} & ctr_iu5_i0_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `xer_t)}} & xer_iu5_i0_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `axu0_t)}} & au_iu_iu5_i0_s1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s1_t == `axu1_t)}} & au_iu_iu5_i0_s1_itag);
   assign frn_fdis_iu6_i0_s1_t_d = fdec_frn_iu5_i0_s1_t;
   assign frn_fdis_iu6_i0_s2_v_d = fdec_frn_iu5_i0_s2_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_s2_a_d = fdec_frn_iu5_i0_s2_a;
   assign frn_fdis_iu6_i0_s2_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `gpr_t)}} & gpr_iu5_i0_src2_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i0_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i0_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i0_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i0_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `axu0_t)}} & au_iu_iu5_i0_s2_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s2_t == `axu1_t)}} & au_iu_iu5_i0_s2_p);
   assign frn_fdis_iu6_i0_s2_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `gpr_t)}} & gpr_iu5_i0_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `cr_t)}} & cr_iu5_i0_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `lr_t)}} & lr_iu5_i0_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `ctr_t)}} & ctr_iu5_i0_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `xer_t)}} & xer_iu5_i0_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `axu0_t)}} & au_iu_iu5_i0_s2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s2_t == `axu1_t)}} & au_iu_iu5_i0_s2_itag);
   assign frn_fdis_iu6_i0_s2_t_d = fdec_frn_iu5_i0_s2_t;
   assign frn_fdis_iu6_i0_s3_v_d = fdec_frn_iu5_i0_s3_v & (send_instructions & fdec_frn_iu5_i0_vld);
   assign frn_fdis_iu6_i0_s3_a_d = fdec_frn_iu5_i0_s3_a;
   assign frn_fdis_iu6_i0_s3_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `gpr_t)}} & gpr_iu5_i0_src3_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i0_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i0_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i0_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i0_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `axu0_t)}} & au_iu_iu5_i0_s3_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i0_s3_t == `axu1_t)}} & au_iu_iu5_i0_s3_p);
   assign frn_fdis_iu6_i0_s3_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `gpr_t)}} & gpr_iu5_i0_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `cr_t)}} & cr_iu5_i0_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `lr_t)}} & lr_iu5_i0_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `ctr_t)}} & ctr_iu5_i0_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `xer_t)}} & xer_iu5_i0_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `axu0_t)}} & au_iu_iu5_i0_s3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i0_s3_t == `axu1_t)}} & au_iu_iu5_i0_s3_itag);
   assign frn_fdis_iu6_i0_s3_t_d = fdec_frn_iu5_i0_s3_t;

   assign frn_fdis_iu6_i1_act = fdec_frn_iu5_i0_vld & (~(fdis_frn_iu6_stall_dly));		// This is purposely I0 to allow single instruction issue
   assign frn_fdis_iu6_i1_vld_d = (((send_instructions & fdec_frn_iu5_i1_vld) & (~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush))) | (frn_fdis_iu6_i1_vld_l2 & fdis_frn_iu6_stall_dly)) & (~(cp_flush_l2));
   assign frn_fdis_iu6_i1_itag_d = next_itag_1_l2;
   assign frn_fdis_iu6_i1_ucode_d = fdec_frn_iu5_i1_ucode;
   assign frn_fdis_iu6_i1_ucode_cnt_d = ucode_cnt_i1;
   assign frn_fdis_iu6_i1_fuse_nop_d = fdec_frn_iu5_i1_fuse_nop;
   assign frn_fdis_iu6_i1_rte_fx0_d = fdec_frn_iu5_i1_rte_fx0 & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_rte_fx1_d = fdec_frn_iu5_i1_rte_fx1 & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_rte_lq_d = fdec_frn_iu5_i1_rte_lq & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_rte_sq_d = fdec_frn_iu5_i1_rte_sq & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_rte_axu0_d = fdec_frn_iu5_i1_rte_axu0 & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_rte_axu1_d = fdec_frn_iu5_i1_rte_axu1 & ~spr_single_issue & ~(fdec_frn_iu5_i0_vld & fdec_frn_iu5_i0_np1_flush);
   assign frn_fdis_iu6_i1_valop_d = fdec_frn_iu5_i1_valop;
   assign frn_fdis_iu6_i1_ord_d = fdec_frn_iu5_i1_ord;
   assign frn_fdis_iu6_i1_cord_d = fdec_frn_iu5_i1_cord;
   assign frn_fdis_iu6_i1_error_d = fdec_frn_iu5_i1_error;
   assign frn_fdis_iu6_i1_btb_entry_d = fdec_frn_iu5_i1_btb_entry;
   assign frn_fdis_iu6_i1_btb_hist_d = fdec_frn_iu5_i1_btb_hist;
   assign frn_fdis_iu6_i1_bta_val_d = fdec_frn_iu5_i1_bta_val;
   assign frn_fdis_iu6_i1_fusion_d = fdec_frn_iu5_i1_fusion;
   assign frn_fdis_iu6_i1_spec_d = fdec_frn_iu5_i1_spec;
   assign frn_fdis_iu6_i1_type_fp_d = fdec_frn_iu5_i1_type_fp;
   assign frn_fdis_iu6_i1_type_ap_d = fdec_frn_iu5_i1_type_ap;
   assign frn_fdis_iu6_i1_type_spv_d = fdec_frn_iu5_i1_type_spv;
   assign frn_fdis_iu6_i1_type_st_d = fdec_frn_iu5_i1_type_st;
   assign frn_fdis_iu6_i1_async_block_d = fdec_frn_iu5_i1_async_block;
   assign frn_fdis_iu6_i1_np1_flush_d = fdec_frn_iu5_i1_np1_flush;
   assign frn_fdis_iu6_i1_core_block_d = fdec_frn_iu5_i1_core_block;
   assign frn_fdis_iu6_i1_isram_d = fdec_frn_iu5_i1_isram;
   assign frn_fdis_iu6_i1_isload_d = fdec_frn_iu5_i1_rte_lq & fdec_frn_iu5_i1_isload;
   assign frn_fdis_iu6_i1_isstore_d = fdec_frn_iu5_i1_rte_sq & fdec_frn_iu5_i1_isstore;
   assign frn_fdis_iu6_i1_instr_d = fdec_frn_iu5_i1_instr;
   assign frn_fdis_iu6_i1_ifar_d = fdec_frn_iu5_i1_ifar;
   assign frn_fdis_iu6_i1_bta_d = fdec_frn_iu5_i1_bta;
   assign frn_fdis_iu6_i1_br_pred_d = fdec_frn_iu5_i1_br_pred;
   assign frn_fdis_iu6_i1_bh_update_d = fdec_frn_iu5_i1_bh_update;
   assign frn_fdis_iu6_i1_bh0_hist_d = fdec_frn_iu5_i1_bh0_hist;
   assign frn_fdis_iu6_i1_bh1_hist_d = fdec_frn_iu5_i1_bh1_hist;
   assign frn_fdis_iu6_i1_bh2_hist_d = fdec_frn_iu5_i1_bh2_hist;
   assign frn_fdis_iu6_i1_gshare_d = fdec_frn_iu5_i1_gshare;
   assign frn_fdis_iu6_i1_ls_ptr_d = fdec_frn_iu5_i1_ls_ptr;
   assign frn_fdis_iu6_i1_match_d = fdec_frn_iu5_i1_match;
   assign frn_fdis_iu6_i1_ilat_d = fdec_frn_iu5_i1_ilat;
   assign frn_fdis_iu6_i1_t1_v_d = fdec_frn_iu5_i1_t1_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_t1_t_d = fdec_frn_iu5_i1_t1_t;
   assign frn_fdis_iu6_i1_t1_a_d = fdec_frn_iu5_i1_t1_a;
   assign frn_fdis_iu6_i1_t2_v_d = fdec_frn_iu5_i1_t2_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_t2_a_d = fdec_frn_iu5_i1_t2_a;


   always @(fdec_frn_iu5_i0_t1_v or fdec_frn_iu5_i0_t1_t or fdec_frn_iu5_i1_t1_t or fdec_frn_iu5_i1_t1_a or next_gpr_0 or next_gpr_1 or next_cr_1 or next_cr_0 or au_iu_iu5_i0_t1_p or au_iu_iu5_i1_t1_p)
   begin: tar1_proc
      frn_fdis_iu6_i1_t1_p_d <= fdec_frn_iu5_i1_t1_a;
      if (fdec_frn_iu5_i0_t1_v == 1'b1 & fdec_frn_iu5_i0_t1_t == `gpr_t & fdec_frn_iu5_i1_t1_t == `gpr_t)
         frn_fdis_iu6_i1_t1_p_d <= next_gpr_1;
      else if (fdec_frn_iu5_i1_t1_t == `gpr_t)
         frn_fdis_iu6_i1_t1_p_d <= next_gpr_0;
      else if (fdec_frn_iu5_i0_t1_v == 1'b1 & fdec_frn_iu5_i0_t1_t == `cr_t & fdec_frn_iu5_i1_t1_t == `cr_t)
         frn_fdis_iu6_i1_t1_p_d <= {1'b0, next_cr_1};
      else if (fdec_frn_iu5_i1_t1_t == `cr_t)
         frn_fdis_iu6_i1_t1_p_d <= {1'b0, next_cr_0};
      //AXU
      else if (fdec_frn_iu5_i0_t1_v == 1'b1 & fdec_frn_iu5_i0_t1_t == `axu1_t & fdec_frn_iu5_i1_t1_t == `axu1_t)
         frn_fdis_iu6_i1_t1_p_d <= au_iu_iu5_i1_t1_p;
      else if ((fdec_frn_iu5_i1_t1_t == `axu0_t) | (fdec_frn_iu5_i1_t1_t == `axu1_t))
         frn_fdis_iu6_i1_t1_p_d <= au_iu_iu5_i0_t1_p;
   end


   always @(fdec_frn_iu5_i0_t2_v or fdec_frn_iu5_i0_t2_t or fdec_frn_iu5_i1_t2_t or fdec_frn_iu5_i1_t2_a or next_ctr_1 or next_xer_1 or next_ctr_0 or next_xer_0 or au_iu_iu5_i0_t2_p or au_iu_iu5_i1_t2_p)
   begin: tar2_proc
      frn_fdis_iu6_i1_t2_p_d <= fdec_frn_iu5_i1_t2_a;
      if (fdec_frn_iu5_i0_t2_v == 1'b1 & fdec_frn_iu5_i0_t2_t == `ctr_t & fdec_frn_iu5_i1_t2_t == `ctr_t)
         frn_fdis_iu6_i1_t2_p_d <= {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, next_ctr_1};
      else if (fdec_frn_iu5_i0_t2_v == 1'b1 & fdec_frn_iu5_i0_t2_t == `xer_t & fdec_frn_iu5_i1_t2_t == `xer_t)
         frn_fdis_iu6_i1_t2_p_d <= {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, next_xer_1};
      else if (fdec_frn_iu5_i1_t2_t == `ctr_t)
         frn_fdis_iu6_i1_t2_p_d <= {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, next_ctr_0};
      else if (fdec_frn_iu5_i1_t2_t == `xer_t)
         frn_fdis_iu6_i1_t2_p_d <= {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, next_xer_0};
      //AXU
      else if (fdec_frn_iu5_i0_t2_v == 1'b1 & fdec_frn_iu5_i0_t2_t == `axu0_t & fdec_frn_iu5_i1_t2_t == `axu0_t)
         frn_fdis_iu6_i1_t2_p_d <= au_iu_iu5_i1_t2_p;
      else if (fdec_frn_iu5_i1_t2_t == `axu0_t)
         frn_fdis_iu6_i1_t2_p_d <= au_iu_iu5_i0_t2_p;
   end

   assign frn_fdis_iu6_i1_t2_t_d = fdec_frn_iu5_i1_t2_t;
   assign frn_fdis_iu6_i1_t3_v_d = fdec_frn_iu5_i1_t3_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_t3_a_d = fdec_frn_iu5_i1_t3_a;


   always @(fdec_frn_iu5_i0_t3_v or fdec_frn_iu5_i0_t3_t or fdec_frn_iu5_i1_t3_t or fdec_frn_iu5_i1_t3_a or next_lr_1 or next_lr_0 or next_cr_1 or next_cr_0 or fdec_frn_iu5_i0_t1_v or fdec_frn_iu5_i0_t1_t)
   begin: tar3_proc
      frn_fdis_iu6_i1_t3_p_d <= fdec_frn_iu5_i1_t3_a;
      if (fdec_frn_iu5_i0_t3_v == 1'b1 & fdec_frn_iu5_i0_t3_t == `lr_t & fdec_frn_iu5_i1_t3_t == `lr_t)
         frn_fdis_iu6_i1_t3_p_d <= {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, next_lr_1};
      else if (fdec_frn_iu5_i0_t3_v == 1'b1 & fdec_frn_iu5_i0_t3_t == `cr_t & fdec_frn_iu5_i1_t3_t == `cr_t)
         frn_fdis_iu6_i1_t3_p_d <= {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, next_cr_1};
      else if (fdec_frn_iu5_i0_t1_v == 1'b1 & fdec_frn_iu5_i0_t1_t == `cr_t & fdec_frn_iu5_i1_t3_t == `cr_t)
         frn_fdis_iu6_i1_t3_p_d <= {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, next_cr_1};
      else if (fdec_frn_iu5_i1_t3_t == `lr_t)
         frn_fdis_iu6_i1_t3_p_d <= {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, next_lr_0};
      else if (fdec_frn_iu5_i1_t3_t == `cr_t)
         frn_fdis_iu6_i1_t3_p_d <= {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, next_cr_0};
   end

   assign frn_fdis_iu6_i1_t3_t_d = fdec_frn_iu5_i1_t3_t;
   assign frn_fdis_iu6_i1_s1_v_d = fdec_frn_iu5_i1_s1_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_s1_a_d = fdec_frn_iu5_i1_s1_a;
   assign frn_fdis_iu6_i1_s1_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `gpr_t)}} & gpr_iu5_i1_src1_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i1_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i1_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i1_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i1_src1_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `axu0_t)}} & au_iu_iu5_i1_s1_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s1_t == `axu1_t)}} & au_iu_iu5_i1_s1_p);
   assign frn_fdis_iu6_i1_s1_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `gpr_t)}} & gpr_iu5_i1_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `cr_t)}} & cr_iu5_i1_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `lr_t)}} & lr_iu5_i1_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `ctr_t)}} & ctr_iu5_i1_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `xer_t)}} & xer_iu5_i1_src1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `axu0_t)}} & au_iu_iu5_i1_s1_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s1_t == `axu1_t)}} & au_iu_iu5_i1_s1_itag);
   assign frn_fdis_iu6_i1_s1_t_d = fdec_frn_iu5_i1_s1_t;
   assign frn_fdis_iu6_i1_s1_dep_hit_d = ((fdec_frn_iu5_i1_s1_t == `gpr_t) & gpr_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `cr_t) & cr_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `lr_t) & lr_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `ctr_t) & ctr_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `xer_t) & xer_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `axu0_t) & au_iu_iu5_i1_s1_dep_hit) |
                                         ((fdec_frn_iu5_i1_s1_t == `axu1_t) & au_iu_iu5_i1_s1_dep_hit);
   assign frn_fdis_iu6_i1_s2_v_d = fdec_frn_iu5_i1_s2_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_s2_a_d = fdec_frn_iu5_i1_s2_a;
   assign frn_fdis_iu6_i1_s2_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `gpr_t)}} & gpr_iu5_i1_src2_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i1_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i1_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i1_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i1_src2_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `axu0_t)}} & au_iu_iu5_i1_s2_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s2_t == `axu1_t)}} & au_iu_iu5_i1_s2_p);
   assign frn_fdis_iu6_i1_s2_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `gpr_t)}} & gpr_iu5_i1_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `cr_t)}} & cr_iu5_i1_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `lr_t)}} & lr_iu5_i1_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `ctr_t)}} & ctr_iu5_i1_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `xer_t)}} & xer_iu5_i1_src2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `axu0_t)}} & au_iu_iu5_i1_s2_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s2_t == `axu1_t)}} & au_iu_iu5_i1_s2_itag);
   assign frn_fdis_iu6_i1_s2_t_d = fdec_frn_iu5_i1_s2_t;
   assign frn_fdis_iu6_i1_s2_dep_hit_d = ((fdec_frn_iu5_i1_s2_t == `gpr_t) & gpr_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `cr_t) & cr_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `lr_t) & lr_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `ctr_t) & ctr_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `xer_t) & xer_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `axu0_t) & au_iu_iu5_i1_s2_dep_hit) |
                                         ((fdec_frn_iu5_i1_s2_t == `axu1_t) & au_iu_iu5_i1_s2_dep_hit);
   assign frn_fdis_iu6_i1_s3_v_d = fdec_frn_iu5_i1_s3_v & (send_instructions & fdec_frn_iu5_i1_vld);
   assign frn_fdis_iu6_i1_s3_a_d = fdec_frn_iu5_i1_s3_a;
   assign frn_fdis_iu6_i1_s3_p_d = ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `gpr_t)}} & gpr_iu5_i1_src3_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `cr_t)}} & {{`GPR_POOL_ENC-`CR_POOL_ENC{1'b0}}, cr_iu5_i1_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `lr_t)}} & {{`GPR_POOL_ENC-`LR_POOL_ENC{1'b0}}, lr_iu5_i1_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `ctr_t)}} & {{`GPR_POOL_ENC-`CTR_POOL_ENC{1'b0}}, ctr_iu5_i1_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `xer_t)}} & {{`GPR_POOL_ENC-`XER_POOL_ENC{1'b0}}, xer_iu5_i1_src3_p}) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `axu0_t)}} & au_iu_iu5_i1_s3_p) |
                                   ({`GPR_POOL_ENC{(fdec_frn_iu5_i1_s3_t == `axu1_t)}} & au_iu_iu5_i1_s3_p);
   assign frn_fdis_iu6_i1_s3_itag_d = ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `gpr_t)}} & gpr_iu5_i1_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `cr_t)}} & cr_iu5_i1_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `lr_t)}} & lr_iu5_i1_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `ctr_t)}} & ctr_iu5_i1_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `xer_t)}} & xer_iu5_i1_src3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `axu0_t)}} & au_iu_iu5_i1_s3_itag) |
                                      ({`ITAG_SIZE_ENC{(fdec_frn_iu5_i1_s3_t == `axu1_t)}} & au_iu_iu5_i1_s3_itag);
   assign frn_fdis_iu6_i1_s3_t_d = fdec_frn_iu5_i1_s3_t;
   assign frn_fdis_iu6_i1_s3_dep_hit_d = ((fdec_frn_iu5_i1_s3_t == `gpr_t) & gpr_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `cr_t) & cr_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `lr_t) & lr_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `ctr_t) & ctr_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `xer_t) & xer_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `axu0_t) & au_iu_iu5_i1_s3_dep_hit) |
                                         ((fdec_frn_iu5_i1_s3_t == `axu1_t) & au_iu_iu5_i1_s3_dep_hit);

   //-----------------------------------------------------------------------
   //-- GPR Renamer
   //-----------------------------------------------------------------------
   assign gpr_cp_i0_wr_v = cp_rn_i0_t1_v & (cp_rn_i0_t1_t == `gpr_t);
   assign gpr_cp_i0_wr_a = cp_rn_i0_t1_a;
   assign gpr_cp_i0_wr_p = cp_rn_i0_t1_p;
   assign gpr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign gpr_cp_i1_wr_v = cp_rn_i1_t1_v & (cp_rn_i1_t1_t == `gpr_t);
   assign gpr_cp_i1_wr_a = cp_rn_i1_t1_a;
   assign gpr_cp_i1_wr_p = cp_rn_i1_t1_p;
   assign gpr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign gpr_spec_i0_wr_v = send_instructions & (~(gpr_send_cnt[0:1] == 2'b00));
   assign gpr_spec_i0_wr_v_fast = (~(gpr_send_cnt[0:1] == 2'b00));
   assign gpr_spec_i0_wr_a = ({`GPR_POOL_ENC{gpr_send_cnt[0]}} & fdec_frn_iu5_i0_t1_a) |
                             ({`GPR_POOL_ENC{~gpr_send_cnt[0] & gpr_send_cnt[1]}} & fdec_frn_iu5_i1_t1_a);
   assign gpr_spec_i0_wr_p = next_gpr_0;
   assign gpr_spec_i0_wr_itag = ({`ITAG_SIZE_ENC{gpr_send_cnt[0]}} & next_itag_0_l2) |
                                ({`ITAG_SIZE_ENC{~gpr_send_cnt[0] & gpr_send_cnt[1]}} & next_itag_1_l2);
   assign gpr_spec_i1_wr_v = send_instructions & (gpr_send_cnt[0:1] == 2'b11);
   assign gpr_spec_i1_wr_v_fast = (gpr_send_cnt[0:1] == 2'b11);
   assign gpr_spec_i1_wr_a = fdec_frn_iu5_i1_t1_a;
   assign gpr_spec_i1_wr_p = next_gpr_1;
   assign gpr_spec_i1_wr_itag = next_itag_1_l2;

   assign gpr_s1_dep_hit = gpr_spec_i0_wr_v_fast & gpr_send_cnt[0] & (gpr_spec_i0_wr_a == fdec_frn_iu5_i1_s1_a);
   assign gpr_s2_dep_hit = gpr_spec_i0_wr_v_fast & gpr_send_cnt[0] & (gpr_spec_i0_wr_a == fdec_frn_iu5_i1_s2_a);
   assign gpr_s3_dep_hit = gpr_spec_i0_wr_v_fast & gpr_send_cnt[0] & (gpr_spec_i0_wr_a == fdec_frn_iu5_i1_s3_a);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((32 + `GPR_UCODE_POOL)), .REGISTER_RENAME_DEPTH(`GPR_POOL), .STORAGE_WIDTH(`GPR_POOL_ENC)) gpr_rn_map(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(map_siv[0]),
      .func_scan_out(map_sov[0]),

      .take_a(gpr_spec_i0_wr_v),
      .take_b(gpr_spec_i1_wr_v),
      .next_reg_a_val(next_gpr_0_v),
      .next_reg_a(next_gpr_0),
      .next_reg_b_val(next_gpr_1_v),
      .next_reg_b(next_gpr_1),

      .src1_a(fdec_frn_iu5_i0_s1_a),
      .src1_p(gpr_iu5_i0_src1_p),
      .src1_itag(gpr_iu5_i0_src1_itag),
      .src2_a(fdec_frn_iu5_i0_s2_a),
      .src2_p(gpr_iu5_i0_src2_p),
      .src2_itag(gpr_iu5_i0_src2_itag),
      .src3_a(fdec_frn_iu5_i0_s3_a),
      .src3_p(gpr_iu5_i0_src3_p),
      .src3_itag(gpr_iu5_i0_src3_itag),
      .src4_a(fdec_frn_iu5_i1_s1_a),
      .src4_p(gpr_iu5_i1_src1_p),
      .src4_itag(gpr_iu5_i1_src1_itag),
      .src5_a(fdec_frn_iu5_i1_s2_a),
      .src5_p(gpr_iu5_i1_src2_p),
      .src5_itag(gpr_iu5_i1_src2_itag),
      .src6_a(fdec_frn_iu5_i1_s3_a),
      .src6_p(gpr_iu5_i1_src3_p),
      .src6_itag(gpr_iu5_i1_src3_itag),

      .comp_0_wr_val(gpr_cp_i0_wr_v),
      .comp_0_wr_arc(gpr_cp_i0_wr_a),
      .comp_0_wr_rename(gpr_cp_i0_wr_p),
      .comp_0_wr_itag(gpr_cp_i0_wr_itag),

      .comp_1_wr_val(gpr_cp_i1_wr_v),
      .comp_1_wr_arc(gpr_cp_i1_wr_a),
      .comp_1_wr_rename(gpr_cp_i1_wr_p),
      .comp_1_wr_itag(gpr_cp_i1_wr_itag),

      .spec_0_wr_val(gpr_spec_i0_wr_v),
      .spec_0_wr_val_fast(gpr_spec_i0_wr_v_fast),
      .spec_0_wr_arc(gpr_spec_i0_wr_a),
      .spec_0_wr_rename(gpr_spec_i0_wr_p),
      .spec_0_wr_itag(gpr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(gpr_s1_dep_hit),
      .spec_1_dep_hit_s2(gpr_s2_dep_hit),
      .spec_1_dep_hit_s3(gpr_s3_dep_hit),
      .spec_1_wr_val(gpr_spec_i1_wr_v),
      .spec_1_wr_val_fast(gpr_spec_i1_wr_v_fast),
      .spec_1_wr_arc(gpr_spec_i1_wr_a),
      .spec_1_wr_rename(gpr_spec_i1_wr_p),
      .spec_1_wr_itag(gpr_spec_i1_wr_itag),

      .flush_map(cp_flush_l2)
   );

   //---------------------------------------------------------------------
   // CR Renamer
   //---------------------------------------------------------------------
   assign cr_cp_i0_wr_v = (cp_rn_i0_t1_v & (cp_rn_i0_t1_t == `cr_t)) | (cp_rn_i0_t3_v & (cp_rn_i0_t3_t == `cr_t));
   assign cr_cp_i0_wr_a = ({`CR_POOL_ENC{cp_rn_i0_t1_v & (cp_rn_i0_t1_t == `cr_t)}} & cp_rn_i0_t1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                          ({`CR_POOL_ENC{cp_rn_i0_t3_v & (cp_rn_i0_t3_t == `cr_t)}} & cp_rn_i0_t3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_cp_i0_wr_p = ({`CR_POOL_ENC{cp_rn_i0_t1_v & (cp_rn_i0_t1_t == `cr_t)}} & cp_rn_i0_t1_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                          ({`CR_POOL_ENC{cp_rn_i0_t3_v & (cp_rn_i0_t3_t == `cr_t)}} & cp_rn_i0_t3_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign cr_cp_i1_wr_v = (cp_rn_i1_t1_v & (cp_rn_i1_t1_t == `cr_t)) |
                          (cp_rn_i1_t3_v & (cp_rn_i1_t3_t == `cr_t));
   assign cr_cp_i1_wr_a = ({`CR_POOL_ENC{cp_rn_i1_t1_v & (cp_rn_i1_t1_t == `cr_t)}} & cp_rn_i1_t1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                          ({`CR_POOL_ENC{cp_rn_i1_t3_v & (cp_rn_i1_t3_t == `cr_t)}} & cp_rn_i1_t3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_cp_i1_wr_p = ({`CR_POOL_ENC{cp_rn_i1_t1_v & (cp_rn_i1_t1_t == `cr_t)}} & cp_rn_i1_t1_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                          ({`CR_POOL_ENC{cp_rn_i1_t3_v & (cp_rn_i1_t3_t == `cr_t)}} & cp_rn_i1_t3_p[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign cr_spec_i0_wr_v = send_instructions & (~(cr_send_cnt[0:1] == 2'b00));
   assign cr_spec_i0_wr_v_fast = (~(cr_send_cnt[0:1] == 2'b00));
   assign cr_spec_i0_wr_a = ({`CR_POOL_ENC{cr_send_cnt[0]}} & (({`CR_POOL_ENC{cr_send_t1_cnt[0]}} & fdec_frn_iu5_i0_t1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                               ({`CR_POOL_ENC{cr_send_t3_cnt[0]}} & fdec_frn_iu5_i0_t3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]))) |
                            ({`CR_POOL_ENC{~cr_send_cnt[0] & cr_send_cnt[1]}} & (({`CR_POOL_ENC{cr_send_t1_cnt[1]}} & fdec_frn_iu5_i1_t1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                               ({`CR_POOL_ENC{cr_send_t3_cnt[1]}} & fdec_frn_iu5_i1_t3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1])));
   assign cr_spec_i0_wr_p = next_cr_0;
   assign cr_spec_i0_wr_itag = ({`ITAG_SIZE_ENC{cr_send_cnt[0]}} & (({`ITAG_SIZE_ENC{cr_send_t1_cnt[0]}} & next_itag_0_l2) | ({`ITAG_SIZE_ENC{cr_send_t3_cnt[0]}} & next_itag_0_l2))) |
                               ({`ITAG_SIZE_ENC{~cr_send_cnt[0] & cr_send_cnt[1]}} & (({`ITAG_SIZE_ENC{cr_send_t1_cnt[1]}} & next_itag_1_l2) | ({`ITAG_SIZE_ENC{cr_send_t3_cnt[1]}} & next_itag_1_l2)));
   assign cr_spec_i1_wr_v = send_instructions & (cr_send_cnt[0:1] == 2'b11);
   assign cr_spec_i1_wr_v_fast = (cr_send_cnt[0:1] == 2'b11);
   assign cr_spec_i1_wr_a = fdec_frn_iu5_i1_t3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign cr_spec_i1_wr_p = next_cr_1;
   assign cr_spec_i1_wr_itag = next_itag_1_l2;

   assign cr_s1_dep_hit = cr_spec_i0_wr_v_fast & cr_send_cnt[0] & (cr_spec_i0_wr_a == fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_s2_dep_hit = cr_spec_i0_wr_v_fast & cr_send_cnt[0] & (cr_spec_i0_wr_a == fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign cr_s3_dep_hit = cr_spec_i0_wr_v_fast & cr_send_cnt[0] & (cr_spec_i0_wr_a == fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((8 + `CR_UCODE_POOL)), .REGISTER_RENAME_DEPTH(`CR_POOL), .STORAGE_WIDTH(`CR_POOL_ENC)) cr_rn_map(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(map_siv[1]),
      .func_scan_out(map_sov[1]),

      .take_a(cr_spec_i0_wr_v),
      .take_b(cr_spec_i1_wr_v),
      .next_reg_a_val(next_cr_0_v),
      .next_reg_a(next_cr_0),
      .next_reg_b_val(next_cr_1_v),
      .next_reg_b(next_cr_1),

      .src1_a(fdec_frn_iu5_i0_s1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src1_p(cr_iu5_i0_src1_p),
      .src1_itag(cr_iu5_i0_src1_itag),
      .src2_a(fdec_frn_iu5_i0_s2_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src2_p(cr_iu5_i0_src2_p),
      .src2_itag(cr_iu5_i0_src2_itag),
      .src3_a(fdec_frn_iu5_i0_s3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src3_p(cr_iu5_i0_src3_p),
      .src3_itag(cr_iu5_i0_src3_itag),
      .src4_a(fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src4_p(cr_iu5_i1_src1_p),
      .src4_itag(cr_iu5_i1_src1_itag),
      .src5_a(fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src5_p(cr_iu5_i1_src2_p),
      .src5_itag(cr_iu5_i1_src2_itag),
      .src6_a(fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `CR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src6_p(cr_iu5_i1_src3_p),
      .src6_itag(cr_iu5_i1_src3_itag),

      .comp_0_wr_val(cr_cp_i0_wr_v),
      .comp_0_wr_arc(cr_cp_i0_wr_a),
      .comp_0_wr_rename(cr_cp_i0_wr_p),
      .comp_0_wr_itag(cr_cp_i0_wr_itag),

      .comp_1_wr_val(cr_cp_i1_wr_v),
      .comp_1_wr_arc(cr_cp_i1_wr_a),
      .comp_1_wr_rename(cr_cp_i1_wr_p),
      .comp_1_wr_itag(cr_cp_i1_wr_itag),

      .spec_0_wr_val(cr_spec_i0_wr_v),
      .spec_0_wr_val_fast(cr_spec_i0_wr_v_fast),
      .spec_0_wr_arc(cr_spec_i0_wr_a),
      .spec_0_wr_rename(cr_spec_i0_wr_p),
      .spec_0_wr_itag(cr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(cr_s1_dep_hit),
      .spec_1_dep_hit_s2(cr_s2_dep_hit),
      .spec_1_dep_hit_s3(cr_s3_dep_hit),
      .spec_1_wr_val(cr_spec_i1_wr_v),
      .spec_1_wr_val_fast(cr_spec_i1_wr_v_fast),
      .spec_1_wr_arc(cr_spec_i1_wr_a),
      .spec_1_wr_rename(cr_spec_i1_wr_p),
      .spec_1_wr_itag(cr_spec_i1_wr_itag),

      .flush_map(cp_flush_l2)
   );

   //---------------------------------------------------------------------
   // LR Renamer
   //---------------------------------------------------------------------
   assign lr_cp_i0_wr_v = cp_rn_i0_t3_v & (cp_rn_i0_t3_t == `lr_t);
   assign lr_cp_i0_wr_a = cp_rn_i0_t3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign lr_cp_i0_wr_p = cp_rn_i0_t3_p[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign lr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign lr_cp_i1_wr_v = cp_rn_i1_t3_v & (cp_rn_i1_t3_t == `lr_t);
   assign lr_cp_i1_wr_a = cp_rn_i1_t3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign lr_cp_i1_wr_p = cp_rn_i1_t3_p[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign lr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign lr_spec_i0_wr_v = send_instructions & (~(lr_send_cnt[0:1] == 2'b00));
   assign lr_spec_i0_wr_v_fast = (~(lr_send_cnt[0:1] == 2'b00));
   assign lr_spec_i0_wr_a = ({`LR_POOL_ENC{lr_send_cnt[0]}} & fdec_frn_iu5_i0_t3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                            ({`LR_POOL_ENC{~lr_send_cnt[0] & lr_send_cnt[1]}} & fdec_frn_iu5_i1_t3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign lr_spec_i0_wr_p = next_lr_0;
   assign lr_spec_i0_wr_itag = ({`ITAG_SIZE_ENC{lr_send_cnt[0]}} & next_itag_0_l2) |
                               ({`ITAG_SIZE_ENC{~lr_send_cnt[0] & lr_send_cnt[1]}} & next_itag_1_l2);
   assign lr_spec_i1_wr_v = send_instructions & (lr_send_cnt[0:1] == 2'b11);
   assign lr_spec_i1_wr_v_fast = (lr_send_cnt[0:1] == 2'b11);
   assign lr_spec_i1_wr_a = fdec_frn_iu5_i1_t3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign lr_spec_i1_wr_p = next_lr_1;
   assign lr_spec_i1_wr_itag = next_itag_1_l2;

   assign lr_s1_dep_hit = lr_spec_i0_wr_v_fast & lr_send_cnt[0] & (lr_spec_i0_wr_a == fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign lr_s2_dep_hit = lr_spec_i0_wr_v_fast & lr_send_cnt[0] & (lr_spec_i0_wr_a == fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign lr_s3_dep_hit = lr_spec_i0_wr_v_fast & lr_send_cnt[0] & (lr_spec_i0_wr_a == fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((2 + `LR_UCODE_POOL)), .REGISTER_RENAME_DEPTH(`LR_POOL), .STORAGE_WIDTH(`LR_POOL_ENC)) lr_rn_map(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(map_siv[2]),
      .func_scan_out(map_sov[2]),

      .take_a(lr_spec_i0_wr_v),
      .take_b(lr_spec_i1_wr_v),
      .next_reg_a_val(next_lr_0_v),
      .next_reg_a(next_lr_0),
      .next_reg_b_val(next_lr_1_v),
      .next_reg_b(next_lr_1),

      .src1_a(fdec_frn_iu5_i0_s1_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src1_p(lr_iu5_i0_src1_p),
      .src1_itag(lr_iu5_i0_src1_itag),
      .src2_a(fdec_frn_iu5_i0_s2_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src2_p(lr_iu5_i0_src2_p),
      .src2_itag(lr_iu5_i0_src2_itag),
      .src3_a(fdec_frn_iu5_i0_s3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src3_p(lr_iu5_i0_src3_p),
      .src3_itag(lr_iu5_i0_src3_itag),
      .src4_a(fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src4_p(lr_iu5_i1_src1_p),
      .src4_itag(lr_iu5_i1_src1_itag),
      .src5_a(fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src5_p(lr_iu5_i1_src2_p),
      .src5_itag(lr_iu5_i1_src2_itag),
      .src6_a(fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `LR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src6_p(lr_iu5_i1_src3_p),
      .src6_itag(lr_iu5_i1_src3_itag),

      .comp_0_wr_val(lr_cp_i0_wr_v),
      .comp_0_wr_arc(lr_cp_i0_wr_a),
      .comp_0_wr_rename(lr_cp_i0_wr_p),
      .comp_0_wr_itag(lr_cp_i0_wr_itag),

      .comp_1_wr_val(lr_cp_i1_wr_v),
      .comp_1_wr_arc(lr_cp_i1_wr_a),
      .comp_1_wr_rename(lr_cp_i1_wr_p),
      .comp_1_wr_itag(lr_cp_i1_wr_itag),

      .spec_0_wr_val(lr_spec_i0_wr_v),
      .spec_0_wr_val_fast(lr_spec_i0_wr_v_fast),
      .spec_0_wr_arc(lr_spec_i0_wr_a),
      .spec_0_wr_rename(lr_spec_i0_wr_p),
      .spec_0_wr_itag(lr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(lr_s1_dep_hit),
      .spec_1_dep_hit_s2(lr_s2_dep_hit),
      .spec_1_dep_hit_s3(lr_s3_dep_hit),
      .spec_1_wr_val(lr_spec_i1_wr_v),
      .spec_1_wr_val_fast(lr_spec_i1_wr_v_fast),
      .spec_1_wr_arc(lr_spec_i1_wr_a),
      .spec_1_wr_rename(lr_spec_i1_wr_p),
      .spec_1_wr_itag(lr_spec_i1_wr_itag),

      .flush_map(cp_flush_l2)
   );

   //---------------------------------------------------------------------
   // CTR Renamer
   //---------------------------------------------------------------------
   assign ctr_cp_i0_wr_v = cp_rn_i0_t2_v & (cp_rn_i0_t2_t == `ctr_t);
   assign ctr_cp_i0_wr_a = cp_rn_i0_t2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign ctr_cp_i0_wr_p = cp_rn_i0_t2_p[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign ctr_cp_i0_wr_itag = cp_rn_i0_itag;
   assign ctr_cp_i1_wr_v = cp_rn_i1_t2_v & (cp_rn_i1_t2_t == `ctr_t);
   assign ctr_cp_i1_wr_a = cp_rn_i1_t2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign ctr_cp_i1_wr_p = cp_rn_i1_t2_p[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign ctr_cp_i1_wr_itag = cp_rn_i1_itag;

   assign ctr_spec_i0_wr_v = send_instructions & (~(ctr_send_cnt[0:1] == 2'b00));
   assign ctr_spec_i0_wr_v_fast = (~(ctr_send_cnt[0:1] == 2'b00));
   assign ctr_spec_i0_wr_a = ({`CTR_POOL_ENC{ctr_send_cnt[0]}} & fdec_frn_iu5_i0_t2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]) |
                             ({`CTR_POOL_ENC{~ctr_send_cnt[0] & ctr_send_cnt[1]}} & fdec_frn_iu5_i1_t2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign ctr_spec_i0_wr_p = next_ctr_0;
   assign ctr_spec_i0_wr_itag = ({`ITAG_SIZE_ENC{ctr_send_cnt[0]}} & next_itag_0_l2) |
                                ({`ITAG_SIZE_ENC{~ctr_send_cnt[0] & ctr_send_cnt[1]}} & next_itag_1_l2);
   assign ctr_spec_i1_wr_v = send_instructions & (ctr_send_cnt[0:1] == 2'b11);
   assign ctr_spec_i1_wr_v_fast = (ctr_send_cnt[0:1] == 2'b11);
   assign ctr_spec_i1_wr_a = fdec_frn_iu5_i1_t2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1];
   assign ctr_spec_i1_wr_p = next_ctr_1;
   assign ctr_spec_i1_wr_itag = next_itag_1_l2;

   assign ctr_s1_dep_hit = ctr_spec_i0_wr_v_fast & ctr_send_cnt[0] & (ctr_spec_i0_wr_a == fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign ctr_s2_dep_hit = ctr_spec_i0_wr_v_fast & ctr_send_cnt[0] & (ctr_spec_i0_wr_a == fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign ctr_s3_dep_hit = ctr_spec_i0_wr_v_fast & ctr_send_cnt[0] & (ctr_spec_i0_wr_a == fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((1 + `CTR_UCODE_POOL)), .REGISTER_RENAME_DEPTH(`CTR_POOL), .STORAGE_WIDTH(`CTR_POOL_ENC)) ctr_rn_map(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(map_siv[3]),
      .func_scan_out(map_sov[3]),

      .take_a(ctr_spec_i0_wr_v),
      .take_b(ctr_spec_i1_wr_v),
      .next_reg_a_val(next_ctr_0_v),
      .next_reg_a(next_ctr_0),
      .next_reg_b_val(next_ctr_1_v),
      .next_reg_b(next_ctr_1),

      .src1_a(fdec_frn_iu5_i0_s1_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src1_p(ctr_iu5_i0_src1_p),
      .src1_itag(ctr_iu5_i0_src1_itag),
      .src2_a(fdec_frn_iu5_i0_s2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src2_p(ctr_iu5_i0_src2_p),
      .src2_itag(ctr_iu5_i0_src2_itag),
      .src3_a(fdec_frn_iu5_i0_s3_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src3_p(ctr_iu5_i0_src3_p),
      .src3_itag(ctr_iu5_i0_src3_itag),
      .src4_a(fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src4_p(ctr_iu5_i1_src1_p),
      .src4_itag(ctr_iu5_i1_src1_itag),
      .src5_a(fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src5_p(ctr_iu5_i1_src2_p),
      .src5_itag(ctr_iu5_i1_src2_itag),
      .src6_a(fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `CTR_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src6_p(ctr_iu5_i1_src3_p),
      .src6_itag(ctr_iu5_i1_src3_itag),

      .comp_0_wr_val(ctr_cp_i0_wr_v),
      .comp_0_wr_arc(ctr_cp_i0_wr_a),
      .comp_0_wr_rename(ctr_cp_i0_wr_p),
      .comp_0_wr_itag(ctr_cp_i0_wr_itag),

      .comp_1_wr_val(ctr_cp_i1_wr_v),
      .comp_1_wr_arc(ctr_cp_i1_wr_a),
      .comp_1_wr_rename(ctr_cp_i1_wr_p),
      .comp_1_wr_itag(ctr_cp_i1_wr_itag),

      .spec_0_wr_val(ctr_spec_i0_wr_v),
      .spec_0_wr_val_fast(ctr_spec_i0_wr_v_fast),
      .spec_0_wr_arc(ctr_spec_i0_wr_a),
      .spec_0_wr_rename(ctr_spec_i0_wr_p),
      .spec_0_wr_itag(ctr_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(ctr_s1_dep_hit),
      .spec_1_dep_hit_s2(ctr_s2_dep_hit),
      .spec_1_dep_hit_s3(ctr_s3_dep_hit),
      .spec_1_wr_val(ctr_spec_i1_wr_v),
      .spec_1_wr_val_fast(ctr_spec_i1_wr_v_fast),
      .spec_1_wr_arc(ctr_spec_i1_wr_a),
      .spec_1_wr_rename(ctr_spec_i1_wr_p),
      .spec_1_wr_itag(ctr_spec_i1_wr_itag),

      .flush_map(cp_flush_l2)
   );

   //---------------------------------------------------------------------
   // XER Renamer
   //---------------------------------------------------------------------
   assign xer_cp_i0_wr_v = cp_rn_i0_t2_v & (cp_rn_i0_t2_t == `xer_t);
   assign xer_cp_i0_wr_a = cp_rn_i0_t2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1];
   assign xer_cp_i0_wr_p = cp_rn_i0_t2_p[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1];
   assign xer_cp_i0_wr_itag = cp_rn_i0_itag;
   assign xer_cp_i1_wr_v = cp_rn_i1_t2_v & (cp_rn_i1_t2_t == `xer_t);
   assign xer_cp_i1_wr_a = cp_rn_i1_t2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1];
   assign xer_cp_i1_wr_p = cp_rn_i1_t2_p[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1];
   assign xer_cp_i1_wr_itag = cp_rn_i1_itag;

   assign xer_spec_i0_wr_v = send_instructions & (~(xer_send_cnt[0:1] == 2'b00));
   assign xer_spec_i0_wr_v_fast = (~(xer_send_cnt[0:1] == 2'b00));
   assign xer_spec_i0_wr_a = ({`XER_POOL_ENC{xer_send_cnt[0]}} & fdec_frn_iu5_i0_t2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]) |
                             ({`XER_POOL_ENC{~xer_send_cnt[0] & xer_send_cnt[1]}} & fdec_frn_iu5_i1_t2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign xer_spec_i0_wr_p = next_xer_0;
   assign xer_spec_i0_wr_itag = ({`ITAG_SIZE_ENC{xer_send_cnt[0]}} & next_itag_0_l2) |
                                ({`ITAG_SIZE_ENC{~xer_send_cnt[0] & xer_send_cnt[1]}} & next_itag_1_l2);
   assign xer_spec_i1_wr_v = send_instructions & (xer_send_cnt[0:1] == 2'b11);
   assign xer_spec_i1_wr_v_fast = (xer_send_cnt[0:1] == 2'b11);
   assign xer_spec_i1_wr_a = fdec_frn_iu5_i1_t2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1];
   assign xer_spec_i1_wr_p = next_xer_1;
   assign xer_spec_i1_wr_itag = next_itag_1_l2;

   assign xer_s1_dep_hit = xer_spec_i0_wr_v_fast & xer_send_cnt[0] & (xer_spec_i0_wr_a == fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign xer_s2_dep_hit = xer_spec_i0_wr_v_fast & xer_send_cnt[0] & (xer_spec_i0_wr_a == fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]);
   assign xer_s3_dep_hit = xer_spec_i0_wr_v_fast & xer_send_cnt[0] & (xer_spec_i0_wr_a == fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]);

   iuq_rn_map #(.ARCHITECTED_REGISTER_DEPTH((1 + `XER_UCODE_POOL)), .REGISTER_RENAME_DEPTH(`XER_POOL), .STORAGE_WIDTH(`XER_POOL_ENC)) xer_rn_map(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_0_b(pc_iu_func_sl_thold_0_b),
      .pc_iu_sg_0(pc_iu_sg_0),
      .force_t(force_t),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .func_scan_in(map_siv[4]),
      .func_scan_out(map_sov[4]),

      .take_a(xer_spec_i0_wr_v),
      .take_b(xer_spec_i1_wr_v),
      .next_reg_a_val(next_xer_0_v),
      .next_reg_a(next_xer_0),
      .next_reg_b_val(next_xer_1_v),
      .next_reg_b(next_xer_1),

      .src1_a(fdec_frn_iu5_i0_s1_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src1_p(xer_iu5_i0_src1_p),
      .src1_itag(xer_iu5_i0_src1_itag),
      .src2_a(fdec_frn_iu5_i0_s2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src2_p(xer_iu5_i0_src2_p),
      .src2_itag(xer_iu5_i0_src2_itag),
      .src3_a(fdec_frn_iu5_i0_s3_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src3_p(xer_iu5_i0_src3_p),
      .src3_itag(xer_iu5_i0_src3_itag),
      .src4_a(fdec_frn_iu5_i1_s1_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src4_p(xer_iu5_i1_src1_p),
      .src4_itag(xer_iu5_i1_src1_itag),
      .src5_a(fdec_frn_iu5_i1_s2_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src5_p(xer_iu5_i1_src2_p),
      .src5_itag(xer_iu5_i1_src2_itag),
      .src6_a(fdec_frn_iu5_i1_s3_a[`GPR_POOL_ENC - `XER_POOL_ENC:`GPR_POOL_ENC - 1]),
      .src6_p(xer_iu5_i1_src3_p),
      .src6_itag(xer_iu5_i1_src3_itag),

      .comp_0_wr_val(xer_cp_i0_wr_v),
      .comp_0_wr_arc(xer_cp_i0_wr_a),
      .comp_0_wr_rename(xer_cp_i0_wr_p),
      .comp_0_wr_itag(xer_cp_i0_wr_itag),

      .comp_1_wr_val(xer_cp_i1_wr_v),
      .comp_1_wr_arc(xer_cp_i1_wr_a),
      .comp_1_wr_rename(xer_cp_i1_wr_p),
      .comp_1_wr_itag(xer_cp_i1_wr_itag),

      .spec_0_wr_val(xer_spec_i0_wr_v),
      .spec_0_wr_val_fast(xer_spec_i0_wr_v_fast),
      .spec_0_wr_arc(xer_spec_i0_wr_a),
      .spec_0_wr_rename(xer_spec_i0_wr_p),
      .spec_0_wr_itag(xer_spec_i0_wr_itag),

      .spec_1_dep_hit_s1(xer_s1_dep_hit),
      .spec_1_dep_hit_s2(xer_s2_dep_hit),
      .spec_1_dep_hit_s3(xer_s3_dep_hit),
      .spec_1_wr_val(xer_spec_i1_wr_v),
      .spec_1_wr_val_fast(xer_spec_i1_wr_v_fast),
      .spec_1_wr_arc(xer_spec_i1_wr_a),
      .spec_1_wr_rename(xer_spec_i1_wr_p),
      .spec_1_wr_itag(xer_spec_i1_wr_itag),

      .flush_map(cp_flush_l2)
   );


   //---------------------------------------------------------------------
   // Perfmon
   //---------------------------------------------------------------------
   assign perf_iu5_stall_d = (~(cpl_credit_ok & gpr_send_ok & cr_send_ok & lr_send_ok & ctr_send_ok & xer_send_ok & cp_empty_ok)) | br_iu_hold_l2 | au_iu_iu5_stall | (fdec_frn_iu5_i0_vld & fdis_frn_iu6_stall_dly);
   assign perf_iu5_cpl_credit_stall_d = fdec_frn_iu5_i0_vld & ~cpl_credit_ok;
   assign perf_iu5_gpr_credit_stall_d = fdec_frn_iu5_i0_vld & ~gpr_send_ok;
   assign perf_iu5_cr_credit_stall_d = fdec_frn_iu5_i0_vld & ~cr_send_ok;
   assign perf_iu5_lr_credit_stall_d = fdec_frn_iu5_i0_vld & ~lr_send_ok;
   assign perf_iu5_ctr_credit_stall_d = fdec_frn_iu5_i0_vld & ~ctr_send_ok;
   assign perf_iu5_xer_credit_stall_d = fdec_frn_iu5_i0_vld & ~xer_send_ok;
   assign perf_iu5_br_hold_stall_d = fdec_frn_iu5_i0_vld & br_iu_hold_l2;
   assign perf_iu5_axu_hold_stall_d = fdec_frn_iu5_i0_vld & au_iu_iu5_stall;

   assign perf_iu5_stall = perf_iu5_stall_l2;
   assign perf_iu5_cpl_credit_stall = perf_iu5_cpl_credit_stall_l2;
   assign perf_iu5_gpr_credit_stall = perf_iu5_gpr_credit_stall_l2;
   assign perf_iu5_cr_credit_stall = perf_iu5_cr_credit_stall_l2;
   assign perf_iu5_lr_credit_stall = perf_iu5_lr_credit_stall_l2;
   assign perf_iu5_ctr_credit_stall = perf_iu5_ctr_credit_stall_l2;
   assign perf_iu5_xer_credit_stall = perf_iu5_xer_credit_stall_l2;
   assign perf_iu5_br_hold_stall = perf_iu5_br_hold_stall_l2;
   assign perf_iu5_axu_hold_stall = perf_iu5_axu_hold_stall_l2;


   //---------------------------------------------------------------------
   // Latch definitions
   //---------------------------------------------------------------------
   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(`CPL_Q_DEPTH)) next_itag_0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[next_itag_0_offset:next_itag_0_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[next_itag_0_offset:next_itag_0_offset + `ITAG_SIZE_ENC - 1]),
      .din(next_itag_0_d),
      .dout(next_itag_0_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(`CPL_Q_DEPTH)) next_itag_1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[next_itag_1_offset:next_itag_1_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[next_itag_1_offset:next_itag_1_offset + `ITAG_SIZE_ENC - 1]),
      .din(next_itag_1_d),
      .dout(next_itag_1_l2)
   );


   tri_rlmreg_p #(.WIDTH((`CPL_Q_DEPTH_ENC+1)), .INIT(`CPL_Q_DEPTH)) cp_high_credit_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[cp_high_credit_cnt_offset:cp_high_credit_cnt_offset + (`CPL_Q_DEPTH_ENC+1) - 1]),
      .scout(sov[cp_high_credit_cnt_offset:cp_high_credit_cnt_offset + (`CPL_Q_DEPTH_ENC+1) - 1]),
      .din(cp_high_credit_cnt_d),
      .dout(cp_high_credit_cnt_l2)
   );


   tri_rlmreg_p #(.WIDTH((`CPL_Q_DEPTH_ENC+1)), .INIT(`CPL_Q_DEPTH/2)) cp_med_credit_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[cp_med_credit_cnt_offset:cp_med_credit_cnt_offset + (`CPL_Q_DEPTH_ENC+1) - 1]),
      .scout(sov[cp_med_credit_cnt_offset:cp_med_credit_cnt_offset + (`CPL_Q_DEPTH_ENC+1) - 1]),
      .din(cp_med_credit_cnt_d),
      .dout(cp_med_credit_cnt_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) ucode_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[ucode_cnt_offset:ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[ucode_cnt_offset:ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(ucode_cnt_d),
      .dout(ucode_cnt_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) ucode_cnt_save_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(cp_rn_uc_credit_free),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[ucode_cnt_save_offset:ucode_cnt_save_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[ucode_cnt_save_offset:ucode_cnt_save_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(ucode_cnt_save_d),
      .dout(ucode_cnt_save_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) cp_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_offset]),
      .scout(sov[cp_flush_offset]),
      .din(cp_flush_d),
      .dout(cp_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) cp_flush_into_uc_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_flush_into_uc_offset]),
      .scout(sov[cp_flush_into_uc_offset]),
      .din(cp_flush_into_uc_d),
      .dout(cp_flush_into_uc_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) br_iu_hold_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[br_iu_hold_offset]),
      .scout(sov[br_iu_hold_offset]),
      .din(br_iu_hold_d),
      .dout(br_iu_hold_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) hold_instructions_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[hold_instructions_offset]),
      .scout(sov[hold_instructions_offset]),
      .din(hold_instructions_d),
      .dout(hold_instructions_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) cp_rn_empty_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[cp_rn_empty_offset]),
      .scout(sov[cp_rn_empty_offset]),
      .din(cp_rn_empty),
      .dout(cp_rn_empty_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) high_pri_mask_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[high_pri_mask_offset]),
      .scout(sov[high_pri_mask_offset]),
      .din(spr_high_pri_mask),
      .dout(high_pri_mask_l2)
   );

   tri_rlmreg_p #(.WIDTH(19), .INIT(0)) fdis_frn_iu6_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[fdis_frn_iu6_stall_offset:fdis_frn_iu6_stall_offset + 19 - 1]),
      .scout(sov[fdis_frn_iu6_stall_offset:fdis_frn_iu6_stall_offset + 19 - 1]),
      .din(fdis_frn_iu6_stall_d),
      .dout(fdis_frn_iu6_stall_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_vld_offset]),
      .scout(sov[frn_fdis_iu6_i0_vld_offset]),
      .din(frn_fdis_iu6_i0_vld_d),
      .dout(frn_fdis_iu6_i0_vld_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i0_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_itag_offset:frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_itag_offset:frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i0_itag_d),
      .dout(frn_fdis_iu6_i0_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_ucode_offset:frn_fdis_iu6_i0_ucode_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_ucode_offset:frn_fdis_iu6_i0_ucode_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_ucode_d),
      .dout(frn_fdis_iu6_i0_ucode_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) frn_fdis_iu6_i0_ucode_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_ucode_cnt_offset:frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_ucode_cnt_offset:frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(frn_fdis_iu6_i0_ucode_cnt_d),
      .dout(frn_fdis_iu6_i0_ucode_cnt_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_2ucode_offset]),
      .scout(sov[frn_fdis_iu6_i0_2ucode_offset]),
      .din(frn_fdis_iu6_i0_2ucode_d),
      .dout(frn_fdis_iu6_i0_2ucode_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_fuse_nop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_fuse_nop_offset]),
      .scout(sov[frn_fdis_iu6_i0_fuse_nop_offset]),
      .din(frn_fdis_iu6_i0_fuse_nop_d),
      .dout(frn_fdis_iu6_i0_fuse_nop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_lq_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_lq_offset]),
      .din(frn_fdis_iu6_i0_rte_lq_d),
      .dout(frn_fdis_iu6_i0_rte_lq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_sq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_sq_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_sq_offset]),
      .din(frn_fdis_iu6_i0_rte_sq_d),
      .dout(frn_fdis_iu6_i0_rte_sq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_fx0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_fx0_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_fx0_offset]),
      .din(frn_fdis_iu6_i0_rte_fx0_d),
      .dout(frn_fdis_iu6_i0_rte_fx0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_fx1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_fx1_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_fx1_offset]),
      .din(frn_fdis_iu6_i0_rte_fx1_d),
      .dout(frn_fdis_iu6_i0_rte_fx1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_axu0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_axu0_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_axu0_offset]),
      .din(frn_fdis_iu6_i0_rte_axu0_d),
      .dout(frn_fdis_iu6_i0_rte_axu0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_rte_axu1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_rte_axu1_offset]),
      .scout(sov[frn_fdis_iu6_i0_rte_axu1_offset]),
      .din(frn_fdis_iu6_i0_rte_axu1_d),
      .dout(frn_fdis_iu6_i0_rte_axu1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_valop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_valop_offset]),
      .scout(sov[frn_fdis_iu6_i0_valop_offset]),
      .din(frn_fdis_iu6_i0_valop_d),
      .dout(frn_fdis_iu6_i0_valop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_ord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_ord_offset]),
      .scout(sov[frn_fdis_iu6_i0_ord_offset]),
      .din(frn_fdis_iu6_i0_ord_d),
      .dout(frn_fdis_iu6_i0_ord_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_cord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_cord_offset]),
      .scout(sov[frn_fdis_iu6_i0_cord_offset]),
      .din(frn_fdis_iu6_i0_cord_d),
      .dout(frn_fdis_iu6_i0_cord_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_error_offset:frn_fdis_iu6_i0_error_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_error_offset:frn_fdis_iu6_i0_error_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_error_d),
      .dout(frn_fdis_iu6_i0_error_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_btb_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_btb_entry_offset]),
      .scout(sov[frn_fdis_iu6_i0_btb_entry_offset]),
      .din(frn_fdis_iu6_i0_btb_entry_d),
      .dout(frn_fdis_iu6_i0_btb_entry_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i0_btb_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_btb_hist_offset:frn_fdis_iu6_i0_btb_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i0_btb_hist_offset:frn_fdis_iu6_i0_btb_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i0_btb_hist_d),
      .dout(frn_fdis_iu6_i0_btb_hist_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_bta_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_bta_val_offset]),
      .scout(sov[frn_fdis_iu6_i0_bta_val_offset]),
      .din(frn_fdis_iu6_i0_bta_val_d),
      .dout(frn_fdis_iu6_i0_bta_val_l2)
   );


   tri_rlmreg_p #(.WIDTH(20), .INIT(0)) frn_fdis_iu6_i0_fusion_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_fusion_offset:frn_fdis_iu6_i0_fusion_offset + 20 - 1]),
      .scout(sov[frn_fdis_iu6_i0_fusion_offset:frn_fdis_iu6_i0_fusion_offset + 20 - 1]),
      .din(frn_fdis_iu6_i0_fusion_d),
      .dout(frn_fdis_iu6_i0_fusion_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_spec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_spec_offset]),
      .scout(sov[frn_fdis_iu6_i0_spec_offset]),
      .din(frn_fdis_iu6_i0_spec_d),
      .dout(frn_fdis_iu6_i0_spec_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_type_fp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_type_fp_offset]),
      .scout(sov[frn_fdis_iu6_i0_type_fp_offset]),
      .din(frn_fdis_iu6_i0_type_fp_d),
      .dout(frn_fdis_iu6_i0_type_fp_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_type_ap_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_type_ap_offset]),
      .scout(sov[frn_fdis_iu6_i0_type_ap_offset]),
      .din(frn_fdis_iu6_i0_type_ap_d),
      .dout(frn_fdis_iu6_i0_type_ap_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_type_spv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_type_spv_offset]),
      .scout(sov[frn_fdis_iu6_i0_type_spv_offset]),
      .din(frn_fdis_iu6_i0_type_spv_d),
      .dout(frn_fdis_iu6_i0_type_spv_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_type_st_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_type_st_offset]),
      .scout(sov[frn_fdis_iu6_i0_type_st_offset]),
      .din(frn_fdis_iu6_i0_type_st_d),
      .dout(frn_fdis_iu6_i0_type_st_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_async_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_async_block_offset]),
      .scout(sov[frn_fdis_iu6_i0_async_block_offset]),
      .din(frn_fdis_iu6_i0_async_block_d),
      .dout(frn_fdis_iu6_i0_async_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_np1_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_np1_flush_offset]),
      .scout(sov[frn_fdis_iu6_i0_np1_flush_offset]),
      .din(frn_fdis_iu6_i0_np1_flush_d),
      .dout(frn_fdis_iu6_i0_np1_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_core_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_core_block_offset]),
      .scout(sov[frn_fdis_iu6_i0_core_block_offset]),
      .din(frn_fdis_iu6_i0_core_block_d),
      .dout(frn_fdis_iu6_i0_core_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_isram_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_isram_offset]),
      .scout(sov[frn_fdis_iu6_i0_isram_offset]),
      .din(frn_fdis_iu6_i0_isram_d),
      .dout(frn_fdis_iu6_i0_isram_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_isload_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_isload_offset]),
      .scout(sov[frn_fdis_iu6_i0_isload_offset]),
      .din(frn_fdis_iu6_i0_isload_d),
      .dout(frn_fdis_iu6_i0_isload_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_isstore_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_isstore_offset]),
      .scout(sov[frn_fdis_iu6_i0_isstore_offset]),
      .din(frn_fdis_iu6_i0_isstore_d),
      .dout(frn_fdis_iu6_i0_isstore_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) frn_fdis_iu6_i0_instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_instr_offset:frn_fdis_iu6_i0_instr_offset + 32 - 1]),
      .scout(sov[frn_fdis_iu6_i0_instr_offset:frn_fdis_iu6_i0_instr_offset + 32 - 1]),
      .din(frn_fdis_iu6_i0_instr_d),
      .dout(frn_fdis_iu6_i0_instr_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) frn_fdis_iu6_i0_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_ifar_offset:frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[frn_fdis_iu6_i0_ifar_offset:frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(frn_fdis_iu6_i0_ifar_d),
      .dout(frn_fdis_iu6_i0_ifar_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) frn_fdis_iu6_i0_bta_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_bta_offset:frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[frn_fdis_iu6_i0_bta_offset:frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(frn_fdis_iu6_i0_bta_d),
      .dout(frn_fdis_iu6_i0_bta_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_br_pred_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_br_pred_offset]),
      .scout(sov[frn_fdis_iu6_i0_br_pred_offset]),
      .din(frn_fdis_iu6_i0_br_pred_d),
      .dout(frn_fdis_iu6_i0_br_pred_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_bh_update_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_bh_update_offset]),
      .scout(sov[frn_fdis_iu6_i0_bh_update_offset]),
      .din(frn_fdis_iu6_i0_bh_update_d),
      .dout(frn_fdis_iu6_i0_bh_update_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i0_bh0_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_bh0_hist_offset:frn_fdis_iu6_i0_bh0_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i0_bh0_hist_offset:frn_fdis_iu6_i0_bh0_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i0_bh0_hist_d),
      .dout(frn_fdis_iu6_i0_bh0_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i0_bh1_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_bh1_hist_offset:frn_fdis_iu6_i0_bh1_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i0_bh1_hist_offset:frn_fdis_iu6_i0_bh1_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i0_bh1_hist_d),
      .dout(frn_fdis_iu6_i0_bh1_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i0_bh2_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_bh2_hist_offset:frn_fdis_iu6_i0_bh2_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i0_bh2_hist_offset:frn_fdis_iu6_i0_bh2_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i0_bh2_hist_d),
      .dout(frn_fdis_iu6_i0_bh2_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) frn_fdis_iu6_i0_gshare_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_gshare_offset:frn_fdis_iu6_i0_gshare_offset + 18 - 1]),
      .scout(sov[frn_fdis_iu6_i0_gshare_offset:frn_fdis_iu6_i0_gshare_offset + 18 - 1]),
      .din(frn_fdis_iu6_i0_gshare_d),
      .dout(frn_fdis_iu6_i0_gshare_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_ls_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_ls_ptr_offset:frn_fdis_iu6_i0_ls_ptr_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_ls_ptr_offset:frn_fdis_iu6_i0_ls_ptr_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_ls_ptr_d),
      .dout(frn_fdis_iu6_i0_ls_ptr_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_match_offset]),
      .scout(sov[frn_fdis_iu6_i0_match_offset]),
      .din(frn_fdis_iu6_i0_match_d),
      .dout(frn_fdis_iu6_i0_match_l2)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) frn_fdis_iu6_i0_ilat_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_ilat_offset:frn_fdis_iu6_i0_ilat_offset + 4 - 1]),
      .scout(sov[frn_fdis_iu6_i0_ilat_offset:frn_fdis_iu6_i0_ilat_offset + 4 - 1]),
      .din(frn_fdis_iu6_i0_ilat_d),
      .dout(frn_fdis_iu6_i0_ilat_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_t1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_t1_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_t1_v_offset]),
      .din(frn_fdis_iu6_i0_t1_v_d),
      .dout(frn_fdis_iu6_i0_t1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_t1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t1_t_offset:frn_fdis_iu6_i0_t1_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_t1_t_offset:frn_fdis_iu6_i0_t1_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_t1_t_d),
      .dout(frn_fdis_iu6_i0_t1_t_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t1_a_offset:frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t1_a_offset:frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t1_a_d),
      .dout(frn_fdis_iu6_i0_t1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t1_p_offset:frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t1_p_offset:frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t1_p_d),
      .dout(frn_fdis_iu6_i0_t1_p_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_t2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_t2_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_t2_v_offset]),
      .din(frn_fdis_iu6_i0_t2_v_d),
      .dout(frn_fdis_iu6_i0_t2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t2_a_offset:frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t2_a_offset:frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t2_a_d),
      .dout(frn_fdis_iu6_i0_t2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t2_p_offset:frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t2_p_offset:frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t2_p_d),
      .dout(frn_fdis_iu6_i0_t2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_t2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t2_t_offset:frn_fdis_iu6_i0_t2_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_t2_t_offset:frn_fdis_iu6_i0_t2_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_t2_t_d),
      .dout(frn_fdis_iu6_i0_t2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_t3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_t3_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_t3_v_offset]),
      .din(frn_fdis_iu6_i0_t3_v_d),
      .dout(frn_fdis_iu6_i0_t3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t3_a_offset:frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t3_a_offset:frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t3_a_d),
      .dout(frn_fdis_iu6_i0_t3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_t3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t3_p_offset:frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_t3_p_offset:frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_t3_p_d),
      .dout(frn_fdis_iu6_i0_t3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_t3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_t3_t_offset:frn_fdis_iu6_i0_t3_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_t3_t_offset:frn_fdis_iu6_i0_t3_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_t3_t_d),
      .dout(frn_fdis_iu6_i0_t3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_s1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_s1_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_s1_v_offset]),
      .din(frn_fdis_iu6_i0_s1_v_d),
      .dout(frn_fdis_iu6_i0_s1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s1_a_offset:frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s1_a_offset:frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s1_a_d),
      .dout(frn_fdis_iu6_i0_s1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s1_p_offset:frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s1_p_offset:frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s1_p_d),
      .dout(frn_fdis_iu6_i0_s1_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i0_s1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s1_itag_offset:frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s1_itag_offset:frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i0_s1_itag_d),
      .dout(frn_fdis_iu6_i0_s1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_s1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s1_t_offset:frn_fdis_iu6_i0_s1_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_s1_t_offset:frn_fdis_iu6_i0_s1_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_s1_t_d),
      .dout(frn_fdis_iu6_i0_s1_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_s2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_s2_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_s2_v_offset]),
      .din(frn_fdis_iu6_i0_s2_v_d),
      .dout(frn_fdis_iu6_i0_s2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s2_a_offset:frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s2_a_offset:frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s2_a_d),
      .dout(frn_fdis_iu6_i0_s2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s2_p_offset:frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s2_p_offset:frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s2_p_d),
      .dout(frn_fdis_iu6_i0_s2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i0_s2_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s2_itag_offset:frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s2_itag_offset:frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i0_s2_itag_d),
      .dout(frn_fdis_iu6_i0_s2_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_s2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s2_t_offset:frn_fdis_iu6_i0_s2_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_s2_t_offset:frn_fdis_iu6_i0_s2_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_s2_t_d),
      .dout(frn_fdis_iu6_i0_s2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i0_s3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i0_s3_v_offset]),
      .scout(sov[frn_fdis_iu6_i0_s3_v_offset]),
      .din(frn_fdis_iu6_i0_s3_v_d),
      .dout(frn_fdis_iu6_i0_s3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s3_a_offset:frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s3_a_offset:frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s3_a_d),
      .dout(frn_fdis_iu6_i0_s3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i0_s3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s3_p_offset:frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s3_p_offset:frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i0_s3_p_d),
      .dout(frn_fdis_iu6_i0_s3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i0_s3_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s3_itag_offset:frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i0_s3_itag_offset:frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i0_s3_itag_d),
      .dout(frn_fdis_iu6_i0_s3_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i0_s3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i0_s3_t_offset:frn_fdis_iu6_i0_s3_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i0_s3_t_offset:frn_fdis_iu6_i0_s3_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i0_s3_t_d),
      .dout(frn_fdis_iu6_i0_s3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_vld_offset]),
      .scout(sov[frn_fdis_iu6_i1_vld_offset]),
      .din(frn_fdis_iu6_i1_vld_d),
      .dout(frn_fdis_iu6_i1_vld_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_itag_offset:frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_itag_offset:frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i1_itag_d),
      .dout(frn_fdis_iu6_i1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_ucode_offset:frn_fdis_iu6_i1_ucode_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_ucode_offset:frn_fdis_iu6_i1_ucode_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_ucode_d),
      .dout(frn_fdis_iu6_i1_ucode_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) frn_fdis_iu6_i1_ucode_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_ucode_cnt_offset:frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_ucode_cnt_offset:frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(frn_fdis_iu6_i1_ucode_cnt_d),
      .dout(frn_fdis_iu6_i1_ucode_cnt_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_fuse_nop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_fuse_nop_offset]),
      .scout(sov[frn_fdis_iu6_i1_fuse_nop_offset]),
      .din(frn_fdis_iu6_i1_fuse_nop_d),
      .dout(frn_fdis_iu6_i1_fuse_nop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_lq_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_lq_offset]),
      .din(frn_fdis_iu6_i1_rte_lq_d),
      .dout(frn_fdis_iu6_i1_rte_lq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_sq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_sq_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_sq_offset]),
      .din(frn_fdis_iu6_i1_rte_sq_d),
      .dout(frn_fdis_iu6_i1_rte_sq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_fx0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_fx0_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_fx0_offset]),
      .din(frn_fdis_iu6_i1_rte_fx0_d),
      .dout(frn_fdis_iu6_i1_rte_fx0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_fx1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_fx1_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_fx1_offset]),
      .din(frn_fdis_iu6_i1_rte_fx1_d),
      .dout(frn_fdis_iu6_i1_rte_fx1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_axu0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_axu0_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_axu0_offset]),
      .din(frn_fdis_iu6_i1_rte_axu0_d),
      .dout(frn_fdis_iu6_i1_rte_axu0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_rte_axu1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_rte_axu1_offset]),
      .scout(sov[frn_fdis_iu6_i1_rte_axu1_offset]),
      .din(frn_fdis_iu6_i1_rte_axu1_d),
      .dout(frn_fdis_iu6_i1_rte_axu1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_valop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_valop_offset]),
      .scout(sov[frn_fdis_iu6_i1_valop_offset]),
      .din(frn_fdis_iu6_i1_valop_d),
      .dout(frn_fdis_iu6_i1_valop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_ord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_ord_offset]),
      .scout(sov[frn_fdis_iu6_i1_ord_offset]),
      .din(frn_fdis_iu6_i1_ord_d),
      .dout(frn_fdis_iu6_i1_ord_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_cord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_cord_offset]),
      .scout(sov[frn_fdis_iu6_i1_cord_offset]),
      .din(frn_fdis_iu6_i1_cord_d),
      .dout(frn_fdis_iu6_i1_cord_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_error_offset:frn_fdis_iu6_i1_error_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_error_offset:frn_fdis_iu6_i1_error_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_error_d),
      .dout(frn_fdis_iu6_i1_error_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_btb_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_btb_entry_offset]),
      .scout(sov[frn_fdis_iu6_i1_btb_entry_offset]),
      .din(frn_fdis_iu6_i1_btb_entry_d),
      .dout(frn_fdis_iu6_i1_btb_entry_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i1_btb_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_btb_hist_offset:frn_fdis_iu6_i1_btb_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i1_btb_hist_offset:frn_fdis_iu6_i1_btb_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i1_btb_hist_d),
      .dout(frn_fdis_iu6_i1_btb_hist_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_bta_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_bta_val_offset]),
      .scout(sov[frn_fdis_iu6_i1_bta_val_offset]),
      .din(frn_fdis_iu6_i1_bta_val_d),
      .dout(frn_fdis_iu6_i1_bta_val_l2)
   );


   tri_rlmreg_p #(.WIDTH(20), .INIT(0)) frn_fdis_iu6_i1_fusion_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_fusion_offset:frn_fdis_iu6_i1_fusion_offset + 20 - 1]),
      .scout(sov[frn_fdis_iu6_i1_fusion_offset:frn_fdis_iu6_i1_fusion_offset + 20 - 1]),
      .din(frn_fdis_iu6_i1_fusion_d),
      .dout(frn_fdis_iu6_i1_fusion_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_spec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_spec_offset]),
      .scout(sov[frn_fdis_iu6_i1_spec_offset]),
      .din(frn_fdis_iu6_i1_spec_d),
      .dout(frn_fdis_iu6_i1_spec_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_type_fp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_type_fp_offset]),
      .scout(sov[frn_fdis_iu6_i1_type_fp_offset]),
      .din(frn_fdis_iu6_i1_type_fp_d),
      .dout(frn_fdis_iu6_i1_type_fp_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_type_ap_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_type_ap_offset]),
      .scout(sov[frn_fdis_iu6_i1_type_ap_offset]),
      .din(frn_fdis_iu6_i1_type_ap_d),
      .dout(frn_fdis_iu6_i1_type_ap_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_type_spv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_type_spv_offset]),
      .scout(sov[frn_fdis_iu6_i1_type_spv_offset]),
      .din(frn_fdis_iu6_i1_type_spv_d),
      .dout(frn_fdis_iu6_i1_type_spv_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_type_st_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_type_st_offset]),
      .scout(sov[frn_fdis_iu6_i1_type_st_offset]),
      .din(frn_fdis_iu6_i1_type_st_d),
      .dout(frn_fdis_iu6_i1_type_st_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_async_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_async_block_offset]),
      .scout(sov[frn_fdis_iu6_i1_async_block_offset]),
      .din(frn_fdis_iu6_i1_async_block_d),
      .dout(frn_fdis_iu6_i1_async_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_np1_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_np1_flush_offset]),
      .scout(sov[frn_fdis_iu6_i1_np1_flush_offset]),
      .din(frn_fdis_iu6_i1_np1_flush_d),
      .dout(frn_fdis_iu6_i1_np1_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_core_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_core_block_offset]),
      .scout(sov[frn_fdis_iu6_i1_core_block_offset]),
      .din(frn_fdis_iu6_i1_core_block_d),
      .dout(frn_fdis_iu6_i1_core_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_isram_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_isram_offset]),
      .scout(sov[frn_fdis_iu6_i1_isram_offset]),
      .din(frn_fdis_iu6_i1_isram_d),
      .dout(frn_fdis_iu6_i1_isram_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_isload_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_isload_offset]),
      .scout(sov[frn_fdis_iu6_i1_isload_offset]),
      .din(frn_fdis_iu6_i1_isload_d),
      .dout(frn_fdis_iu6_i1_isload_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_isstore_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_isstore_offset]),
      .scout(sov[frn_fdis_iu6_i1_isstore_offset]),
      .din(frn_fdis_iu6_i1_isstore_d),
      .dout(frn_fdis_iu6_i1_isstore_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) frn_fdis_iu6_i1_instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_instr_offset:frn_fdis_iu6_i1_instr_offset + 32 - 1]),
      .scout(sov[frn_fdis_iu6_i1_instr_offset:frn_fdis_iu6_i1_instr_offset + 32 - 1]),
      .din(frn_fdis_iu6_i1_instr_d),
      .dout(frn_fdis_iu6_i1_instr_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) frn_fdis_iu6_i1_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_ifar_offset:frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[frn_fdis_iu6_i1_ifar_offset:frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(frn_fdis_iu6_i1_ifar_d),
      .dout(frn_fdis_iu6_i1_ifar_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) frn_fdis_iu6_i1_bta_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_bta_offset:frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[frn_fdis_iu6_i1_bta_offset:frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(frn_fdis_iu6_i1_bta_d),
      .dout(frn_fdis_iu6_i1_bta_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_br_pred_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_br_pred_offset]),
      .scout(sov[frn_fdis_iu6_i1_br_pred_offset]),
      .din(frn_fdis_iu6_i1_br_pred_d),
      .dout(frn_fdis_iu6_i1_br_pred_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_bh_update_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_bh_update_offset]),
      .scout(sov[frn_fdis_iu6_i1_bh_update_offset]),
      .din(frn_fdis_iu6_i1_bh_update_d),
      .dout(frn_fdis_iu6_i1_bh_update_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i1_bh0_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_bh0_hist_offset:frn_fdis_iu6_i1_bh0_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i1_bh0_hist_offset:frn_fdis_iu6_i1_bh0_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i1_bh0_hist_d),
      .dout(frn_fdis_iu6_i1_bh0_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i1_bh1_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_bh1_hist_offset:frn_fdis_iu6_i1_bh1_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i1_bh1_hist_offset:frn_fdis_iu6_i1_bh1_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i1_bh1_hist_d),
      .dout(frn_fdis_iu6_i1_bh1_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) frn_fdis_iu6_i1_bh2_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_bh2_hist_offset:frn_fdis_iu6_i1_bh2_hist_offset + 2 - 1]),
      .scout(sov[frn_fdis_iu6_i1_bh2_hist_offset:frn_fdis_iu6_i1_bh2_hist_offset + 2 - 1]),
      .din(frn_fdis_iu6_i1_bh2_hist_d),
      .dout(frn_fdis_iu6_i1_bh2_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) frn_fdis_iu6_i1_gshare_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_gshare_offset:frn_fdis_iu6_i1_gshare_offset + 18 - 1]),
      .scout(sov[frn_fdis_iu6_i1_gshare_offset:frn_fdis_iu6_i1_gshare_offset + 18 - 1]),
      .din(frn_fdis_iu6_i1_gshare_d),
      .dout(frn_fdis_iu6_i1_gshare_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_ls_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_ls_ptr_offset:frn_fdis_iu6_i1_ls_ptr_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_ls_ptr_offset:frn_fdis_iu6_i1_ls_ptr_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_ls_ptr_d),
      .dout(frn_fdis_iu6_i1_ls_ptr_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_match_offset]),
      .scout(sov[frn_fdis_iu6_i1_match_offset]),
      .din(frn_fdis_iu6_i1_match_d),
      .dout(frn_fdis_iu6_i1_match_l2)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) frn_fdis_iu6_i1_ilat_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_ilat_offset:frn_fdis_iu6_i1_ilat_offset + 4 - 1]),
      .scout(sov[frn_fdis_iu6_i1_ilat_offset:frn_fdis_iu6_i1_ilat_offset + 4 - 1]),
      .din(frn_fdis_iu6_i1_ilat_d),
      .dout(frn_fdis_iu6_i1_ilat_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_t1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_t1_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_t1_v_offset]),
      .din(frn_fdis_iu6_i1_t1_v_d),
      .dout(frn_fdis_iu6_i1_t1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_t1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t1_t_offset:frn_fdis_iu6_i1_t1_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_t1_t_offset:frn_fdis_iu6_i1_t1_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_t1_t_d),
      .dout(frn_fdis_iu6_i1_t1_t_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t1_a_offset:frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t1_a_offset:frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t1_a_d),
      .dout(frn_fdis_iu6_i1_t1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t1_p_offset:frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t1_p_offset:frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t1_p_d),
      .dout(frn_fdis_iu6_i1_t1_p_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_t2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_t2_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_t2_v_offset]),
      .din(frn_fdis_iu6_i1_t2_v_d),
      .dout(frn_fdis_iu6_i1_t2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t2_a_offset:frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t2_a_offset:frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t2_a_d),
      .dout(frn_fdis_iu6_i1_t2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t2_p_offset:frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t2_p_offset:frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t2_p_d),
      .dout(frn_fdis_iu6_i1_t2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_t2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t2_t_offset:frn_fdis_iu6_i1_t2_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_t2_t_offset:frn_fdis_iu6_i1_t2_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_t2_t_d),
      .dout(frn_fdis_iu6_i1_t2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_t3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_t3_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_t3_v_offset]),
      .din(frn_fdis_iu6_i1_t3_v_d),
      .dout(frn_fdis_iu6_i1_t3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t3_a_offset:frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t3_a_offset:frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t3_a_d),
      .dout(frn_fdis_iu6_i1_t3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_t3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t3_p_offset:frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_t3_p_offset:frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_t3_p_d),
      .dout(frn_fdis_iu6_i1_t3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_t3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_t3_t_offset:frn_fdis_iu6_i1_t3_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_t3_t_offset:frn_fdis_iu6_i1_t3_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_t3_t_d),
      .dout(frn_fdis_iu6_i1_t3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s1_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_s1_v_offset]),
      .din(frn_fdis_iu6_i1_s1_v_d),
      .dout(frn_fdis_iu6_i1_s1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s1_a_offset:frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s1_a_offset:frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s1_a_d),
      .dout(frn_fdis_iu6_i1_s1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s1_p_offset:frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s1_p_offset:frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s1_p_d),
      .dout(frn_fdis_iu6_i1_s1_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i1_s1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s1_itag_offset:frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s1_itag_offset:frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i1_s1_itag_d),
      .dout(frn_fdis_iu6_i1_s1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_s1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s1_t_offset:frn_fdis_iu6_i1_s1_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_s1_t_offset:frn_fdis_iu6_i1_s1_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_s1_t_d),
      .dout(frn_fdis_iu6_i1_s1_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s1_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s1_dep_hit_offset]),
      .scout(sov[frn_fdis_iu6_i1_s1_dep_hit_offset]),
      .din(frn_fdis_iu6_i1_s1_dep_hit_d),
      .dout(frn_fdis_iu6_i1_s1_dep_hit_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s2_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_s2_v_offset]),
      .din(frn_fdis_iu6_i1_s2_v_d),
      .dout(frn_fdis_iu6_i1_s2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s2_a_offset:frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s2_a_offset:frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s2_a_d),
      .dout(frn_fdis_iu6_i1_s2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s2_p_offset:frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s2_p_offset:frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s2_p_d),
      .dout(frn_fdis_iu6_i1_s2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i1_s2_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s2_itag_offset:frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s2_itag_offset:frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i1_s2_itag_d),
      .dout(frn_fdis_iu6_i1_s2_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_s2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s2_t_offset:frn_fdis_iu6_i1_s2_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_s2_t_offset:frn_fdis_iu6_i1_s2_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_s2_t_d),
      .dout(frn_fdis_iu6_i1_s2_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s2_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s2_dep_hit_offset]),
      .scout(sov[frn_fdis_iu6_i1_s2_dep_hit_offset]),
      .din(frn_fdis_iu6_i1_s2_dep_hit_d),
      .dout(frn_fdis_iu6_i1_s2_dep_hit_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s3_v_offset]),
      .scout(sov[frn_fdis_iu6_i1_s3_v_offset]),
      .din(frn_fdis_iu6_i1_s3_v_d),
      .dout(frn_fdis_iu6_i1_s3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s3_a_offset:frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s3_a_offset:frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s3_a_d),
      .dout(frn_fdis_iu6_i1_s3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) frn_fdis_iu6_i1_s3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s3_p_offset:frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s3_p_offset:frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC - 1]),
      .din(frn_fdis_iu6_i1_s3_p_d),
      .dout(frn_fdis_iu6_i1_s3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) frn_fdis_iu6_i1_s3_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s3_itag_offset:frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[frn_fdis_iu6_i1_s3_itag_offset:frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(frn_fdis_iu6_i1_s3_itag_d),
      .dout(frn_fdis_iu6_i1_s3_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) frn_fdis_iu6_i1_s3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[frn_fdis_iu6_i1_s3_t_offset:frn_fdis_iu6_i1_s3_t_offset + 3 - 1]),
      .scout(sov[frn_fdis_iu6_i1_s3_t_offset:frn_fdis_iu6_i1_s3_t_offset + 3 - 1]),
      .din(frn_fdis_iu6_i1_s3_t_d),
      .dout(frn_fdis_iu6_i1_s3_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) frn_fdis_iu6_i1_s3_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[frn_fdis_iu6_i1_s3_dep_hit_offset]),
      .scout(sov[frn_fdis_iu6_i1_s3_dep_hit_offset]),
      .din(frn_fdis_iu6_i1_s3_dep_hit_d),
      .dout(frn_fdis_iu6_i1_s3_dep_hit_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_vld_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_vld_offset]),
      .din(stall_frn_fdis_iu6_i0_vld_d),
      .dout(stall_frn_fdis_iu6_i0_vld_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_itag_offset:stall_frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_itag_offset:stall_frn_fdis_iu6_i0_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_itag_d),
      .dout(stall_frn_fdis_iu6_i0_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_ucode_offset:stall_frn_fdis_iu6_i0_ucode_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_ucode_offset:stall_frn_fdis_iu6_i0_ucode_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_ucode_d),
      .dout(stall_frn_fdis_iu6_i0_ucode_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_ucode_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_ucode_cnt_offset:stall_frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_ucode_cnt_offset:stall_frn_fdis_iu6_i0_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_ucode_cnt_d),
      .dout(stall_frn_fdis_iu6_i0_ucode_cnt_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_2ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_2ucode_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_2ucode_offset]),
      .din(stall_frn_fdis_iu6_i0_2ucode_d),
      .dout(stall_frn_fdis_iu6_i0_2ucode_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_fuse_nop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_fuse_nop_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_fuse_nop_offset]),
      .din(stall_frn_fdis_iu6_i0_fuse_nop_d),
      .dout(stall_frn_fdis_iu6_i0_fuse_nop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_lq_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_lq_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_lq_d),
      .dout(stall_frn_fdis_iu6_i0_rte_lq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_sq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_sq_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_sq_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_sq_d),
      .dout(stall_frn_fdis_iu6_i0_rte_sq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_fx0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_fx0_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_fx0_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_fx0_d),
      .dout(stall_frn_fdis_iu6_i0_rte_fx0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_fx1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_fx1_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_fx1_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_fx1_d),
      .dout(stall_frn_fdis_iu6_i0_rte_fx1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_axu0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_axu0_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_axu0_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_axu0_d),
      .dout(stall_frn_fdis_iu6_i0_rte_axu0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_rte_axu1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_rte_axu1_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_rte_axu1_offset]),
      .din(stall_frn_fdis_iu6_i0_rte_axu1_d),
      .dout(stall_frn_fdis_iu6_i0_rte_axu1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_valop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_valop_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_valop_offset]),
      .din(stall_frn_fdis_iu6_i0_valop_d),
      .dout(stall_frn_fdis_iu6_i0_valop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_ord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_ord_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_ord_offset]),
      .din(stall_frn_fdis_iu6_i0_ord_d),
      .dout(stall_frn_fdis_iu6_i0_ord_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_cord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_cord_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_cord_offset]),
      .din(stall_frn_fdis_iu6_i0_cord_d),
      .dout(stall_frn_fdis_iu6_i0_cord_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_error_offset:stall_frn_fdis_iu6_i0_error_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_error_offset:stall_frn_fdis_iu6_i0_error_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_error_d),
      .dout(stall_frn_fdis_iu6_i0_error_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_btb_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_btb_entry_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_btb_entry_offset]),
      .din(stall_frn_fdis_iu6_i0_btb_entry_d),
      .dout(stall_frn_fdis_iu6_i0_btb_entry_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i0_btb_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_btb_hist_offset:stall_frn_fdis_iu6_i0_btb_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_btb_hist_offset:stall_frn_fdis_iu6_i0_btb_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i0_btb_hist_d),
      .dout(stall_frn_fdis_iu6_i0_btb_hist_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_bta_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_bta_val_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_bta_val_offset]),
      .din(stall_frn_fdis_iu6_i0_bta_val_d),
      .dout(stall_frn_fdis_iu6_i0_bta_val_l2)
   );


   tri_rlmreg_p #(.WIDTH(20), .INIT(0)) stall_frn_fdis_iu6_i0_fusion_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_fusion_offset:stall_frn_fdis_iu6_i0_fusion_offset + 20 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_fusion_offset:stall_frn_fdis_iu6_i0_fusion_offset + 20 - 1]),
      .din(stall_frn_fdis_iu6_i0_fusion_d),
      .dout(stall_frn_fdis_iu6_i0_fusion_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_spec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_spec_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_spec_offset]),
      .din(stall_frn_fdis_iu6_i0_spec_d),
      .dout(stall_frn_fdis_iu6_i0_spec_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_type_fp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_type_fp_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_type_fp_offset]),
      .din(stall_frn_fdis_iu6_i0_type_fp_d),
      .dout(stall_frn_fdis_iu6_i0_type_fp_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_type_ap_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_type_ap_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_type_ap_offset]),
      .din(stall_frn_fdis_iu6_i0_type_ap_d),
      .dout(stall_frn_fdis_iu6_i0_type_ap_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_type_spv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_type_spv_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_type_spv_offset]),
      .din(stall_frn_fdis_iu6_i0_type_spv_d),
      .dout(stall_frn_fdis_iu6_i0_type_spv_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_type_st_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_type_st_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_type_st_offset]),
      .din(stall_frn_fdis_iu6_i0_type_st_d),
      .dout(stall_frn_fdis_iu6_i0_type_st_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_async_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_async_block_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_async_block_offset]),
      .din(stall_frn_fdis_iu6_i0_async_block_d),
      .dout(stall_frn_fdis_iu6_i0_async_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_np1_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_np1_flush_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_np1_flush_offset]),
      .din(stall_frn_fdis_iu6_i0_np1_flush_d),
      .dout(stall_frn_fdis_iu6_i0_np1_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_core_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_core_block_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_core_block_offset]),
      .din(stall_frn_fdis_iu6_i0_core_block_d),
      .dout(stall_frn_fdis_iu6_i0_core_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_isram_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_isram_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_isram_offset]),
      .din(stall_frn_fdis_iu6_i0_isram_d),
      .dout(stall_frn_fdis_iu6_i0_isram_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_isload_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_isload_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_isload_offset]),
      .din(stall_frn_fdis_iu6_i0_isload_d),
      .dout(stall_frn_fdis_iu6_i0_isload_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_isstore_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_isstore_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_isstore_offset]),
      .din(stall_frn_fdis_iu6_i0_isstore_d),
      .dout(stall_frn_fdis_iu6_i0_isstore_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) stall_frn_fdis_iu6_i0_instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_instr_offset:stall_frn_fdis_iu6_i0_instr_offset + 32 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_instr_offset:stall_frn_fdis_iu6_i0_instr_offset + 32 - 1]),
      .din(stall_frn_fdis_iu6_i0_instr_d),
      .dout(stall_frn_fdis_iu6_i0_instr_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) stall_frn_fdis_iu6_i0_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_ifar_offset:stall_frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_ifar_offset:stall_frn_fdis_iu6_i0_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(stall_frn_fdis_iu6_i0_ifar_d),
      .dout(stall_frn_fdis_iu6_i0_ifar_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) stall_frn_fdis_iu6_i0_bta_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_bta_offset:stall_frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_bta_offset:stall_frn_fdis_iu6_i0_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(stall_frn_fdis_iu6_i0_bta_d),
      .dout(stall_frn_fdis_iu6_i0_bta_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_br_pred_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_br_pred_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_br_pred_offset]),
      .din(stall_frn_fdis_iu6_i0_br_pred_d),
      .dout(stall_frn_fdis_iu6_i0_br_pred_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_bh_update_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_bh_update_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_bh_update_offset]),
      .din(stall_frn_fdis_iu6_i0_bh_update_d),
      .dout(stall_frn_fdis_iu6_i0_bh_update_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i0_bh0_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_bh0_hist_offset:stall_frn_fdis_iu6_i0_bh0_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_bh0_hist_offset:stall_frn_fdis_iu6_i0_bh0_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i0_bh0_hist_d),
      .dout(stall_frn_fdis_iu6_i0_bh0_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i0_bh1_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_bh1_hist_offset:stall_frn_fdis_iu6_i0_bh1_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_bh1_hist_offset:stall_frn_fdis_iu6_i0_bh1_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i0_bh1_hist_d),
      .dout(stall_frn_fdis_iu6_i0_bh1_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i0_bh2_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_bh2_hist_offset:stall_frn_fdis_iu6_i0_bh2_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_bh2_hist_offset:stall_frn_fdis_iu6_i0_bh2_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i0_bh2_hist_d),
      .dout(stall_frn_fdis_iu6_i0_bh2_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) stall_frn_fdis_iu6_i0_gshare_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_gshare_offset:stall_frn_fdis_iu6_i0_gshare_offset + 18 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_gshare_offset:stall_frn_fdis_iu6_i0_gshare_offset + 18 - 1]),
      .din(stall_frn_fdis_iu6_i0_gshare_d),
      .dout(stall_frn_fdis_iu6_i0_gshare_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_ls_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_ls_ptr_offset:stall_frn_fdis_iu6_i0_ls_ptr_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_ls_ptr_offset:stall_frn_fdis_iu6_i0_ls_ptr_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_ls_ptr_d),
      .dout(stall_frn_fdis_iu6_i0_ls_ptr_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_match_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_match_offset]),
      .din(stall_frn_fdis_iu6_i0_match_d),
      .dout(stall_frn_fdis_iu6_i0_match_l2)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) stall_frn_fdis_iu6_i0_ilat_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_ilat_offset:stall_frn_fdis_iu6_i0_ilat_offset + 4 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_ilat_offset:stall_frn_fdis_iu6_i0_ilat_offset + 4 - 1]),
      .din(stall_frn_fdis_iu6_i0_ilat_d),
      .dout(stall_frn_fdis_iu6_i0_ilat_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_t1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_t1_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_t1_v_offset]),
      .din(stall_frn_fdis_iu6_i0_t1_v_d),
      .dout(stall_frn_fdis_iu6_i0_t1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_t1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t1_t_offset:stall_frn_fdis_iu6_i0_t1_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t1_t_offset:stall_frn_fdis_iu6_i0_t1_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_t1_t_d),
      .dout(stall_frn_fdis_iu6_i0_t1_t_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t1_a_offset:stall_frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t1_a_offset:stall_frn_fdis_iu6_i0_t1_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t1_a_d),
      .dout(stall_frn_fdis_iu6_i0_t1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t1_p_offset:stall_frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t1_p_offset:stall_frn_fdis_iu6_i0_t1_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t1_p_d),
      .dout(stall_frn_fdis_iu6_i0_t1_p_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_t2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_t2_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_t2_v_offset]),
      .din(stall_frn_fdis_iu6_i0_t2_v_d),
      .dout(stall_frn_fdis_iu6_i0_t2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t2_a_offset:stall_frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t2_a_offset:stall_frn_fdis_iu6_i0_t2_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t2_a_d),
      .dout(stall_frn_fdis_iu6_i0_t2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t2_p_offset:stall_frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t2_p_offset:stall_frn_fdis_iu6_i0_t2_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t2_p_d),
      .dout(stall_frn_fdis_iu6_i0_t2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_t2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t2_t_offset:stall_frn_fdis_iu6_i0_t2_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t2_t_offset:stall_frn_fdis_iu6_i0_t2_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_t2_t_d),
      .dout(stall_frn_fdis_iu6_i0_t2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_t3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_t3_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_t3_v_offset]),
      .din(stall_frn_fdis_iu6_i0_t3_v_d),
      .dout(stall_frn_fdis_iu6_i0_t3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t3_a_offset:stall_frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t3_a_offset:stall_frn_fdis_iu6_i0_t3_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t3_a_d),
      .dout(stall_frn_fdis_iu6_i0_t3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_t3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t3_p_offset:stall_frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t3_p_offset:stall_frn_fdis_iu6_i0_t3_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_t3_p_d),
      .dout(stall_frn_fdis_iu6_i0_t3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_t3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_t3_t_offset:stall_frn_fdis_iu6_i0_t3_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_t3_t_offset:stall_frn_fdis_iu6_i0_t3_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_t3_t_d),
      .dout(stall_frn_fdis_iu6_i0_t3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_s1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_s1_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_s1_v_offset]),
      .din(stall_frn_fdis_iu6_i0_s1_v_d),
      .dout(stall_frn_fdis_iu6_i0_s1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s1_a_offset:stall_frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s1_a_offset:stall_frn_fdis_iu6_i0_s1_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s1_a_d),
      .dout(stall_frn_fdis_iu6_i0_s1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s1_p_offset:stall_frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s1_p_offset:stall_frn_fdis_iu6_i0_s1_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s1_p_d),
      .dout(stall_frn_fdis_iu6_i0_s1_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s1_itag_offset:stall_frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s1_itag_offset:stall_frn_fdis_iu6_i0_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s1_itag_d),
      .dout(stall_frn_fdis_iu6_i0_s1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_s1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s1_t_offset:stall_frn_fdis_iu6_i0_s1_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s1_t_offset:stall_frn_fdis_iu6_i0_s1_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_s1_t_d),
      .dout(stall_frn_fdis_iu6_i0_s1_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_s2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_s2_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_s2_v_offset]),
      .din(stall_frn_fdis_iu6_i0_s2_v_d),
      .dout(stall_frn_fdis_iu6_i0_s2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s2_a_offset:stall_frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s2_a_offset:stall_frn_fdis_iu6_i0_s2_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s2_a_d),
      .dout(stall_frn_fdis_iu6_i0_s2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s2_p_offset:stall_frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s2_p_offset:stall_frn_fdis_iu6_i0_s2_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s2_p_d),
      .dout(stall_frn_fdis_iu6_i0_s2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s2_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s2_itag_offset:stall_frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s2_itag_offset:stall_frn_fdis_iu6_i0_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s2_itag_d),
      .dout(stall_frn_fdis_iu6_i0_s2_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_s2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s2_t_offset:stall_frn_fdis_iu6_i0_s2_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s2_t_offset:stall_frn_fdis_iu6_i0_s2_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_s2_t_d),
      .dout(stall_frn_fdis_iu6_i0_s2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i0_s3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i0_s3_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i0_s3_v_offset]),
      .din(stall_frn_fdis_iu6_i0_s3_v_d),
      .dout(stall_frn_fdis_iu6_i0_s3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s3_a_offset:stall_frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s3_a_offset:stall_frn_fdis_iu6_i0_s3_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s3_a_d),
      .dout(stall_frn_fdis_iu6_i0_s3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s3_p_offset:stall_frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s3_p_offset:stall_frn_fdis_iu6_i0_s3_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s3_p_d),
      .dout(stall_frn_fdis_iu6_i0_s3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i0_s3_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s3_itag_offset:stall_frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s3_itag_offset:stall_frn_fdis_iu6_i0_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i0_s3_itag_d),
      .dout(stall_frn_fdis_iu6_i0_s3_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i0_s3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i0_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i0_s3_t_offset:stall_frn_fdis_iu6_i0_s3_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i0_s3_t_offset:stall_frn_fdis_iu6_i0_s3_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i0_s3_t_d),
      .dout(stall_frn_fdis_iu6_i0_s3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_vld_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_vld_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_vld_offset]),
      .din(stall_frn_fdis_iu6_i1_vld_d),
      .dout(stall_frn_fdis_iu6_i1_vld_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_itag_offset:stall_frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_itag_offset:stall_frn_fdis_iu6_i1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_itag_d),
      .dout(stall_frn_fdis_iu6_i1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_ucode_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_ucode_offset:stall_frn_fdis_iu6_i1_ucode_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_ucode_offset:stall_frn_fdis_iu6_i1_ucode_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_ucode_d),
      .dout(stall_frn_fdis_iu6_i1_ucode_l2)
   );


   tri_rlmreg_p #(.WIDTH(`UCODE_ENTRIES_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_ucode_cnt_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_ucode_cnt_offset:stall_frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_ucode_cnt_offset:stall_frn_fdis_iu6_i1_ucode_cnt_offset + `UCODE_ENTRIES_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_ucode_cnt_d),
      .dout(stall_frn_fdis_iu6_i1_ucode_cnt_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_fuse_nop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_fuse_nop_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_fuse_nop_offset]),
      .din(stall_frn_fdis_iu6_i1_fuse_nop_d),
      .dout(stall_frn_fdis_iu6_i1_fuse_nop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_lq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_lq_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_lq_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_lq_d),
      .dout(stall_frn_fdis_iu6_i1_rte_lq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_sq_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_sq_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_sq_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_sq_d),
      .dout(stall_frn_fdis_iu6_i1_rte_sq_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_fx0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_fx0_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_fx0_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_fx0_d),
      .dout(stall_frn_fdis_iu6_i1_rte_fx0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_fx1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_fx1_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_fx1_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_fx1_d),
      .dout(stall_frn_fdis_iu6_i1_rte_fx1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_axu0_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_axu0_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_axu0_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_axu0_d),
      .dout(stall_frn_fdis_iu6_i1_rte_axu0_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_rte_axu1_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_rte_axu1_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_rte_axu1_offset]),
      .din(stall_frn_fdis_iu6_i1_rte_axu1_d),
      .dout(stall_frn_fdis_iu6_i1_rte_axu1_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_valop_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_valop_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_valop_offset]),
      .din(stall_frn_fdis_iu6_i1_valop_d),
      .dout(stall_frn_fdis_iu6_i1_valop_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_ord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_ord_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_ord_offset]),
      .din(stall_frn_fdis_iu6_i1_ord_d),
      .dout(stall_frn_fdis_iu6_i1_ord_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_cord_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_cord_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_cord_offset]),
      .din(stall_frn_fdis_iu6_i1_cord_d),
      .dout(stall_frn_fdis_iu6_i1_cord_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_error_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_error_offset:stall_frn_fdis_iu6_i1_error_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_error_offset:stall_frn_fdis_iu6_i1_error_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_error_d),
      .dout(stall_frn_fdis_iu6_i1_error_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_btb_entry_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_btb_entry_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_btb_entry_offset]),
      .din(stall_frn_fdis_iu6_i1_btb_entry_d),
      .dout(stall_frn_fdis_iu6_i1_btb_entry_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i1_btb_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_btb_hist_offset:stall_frn_fdis_iu6_i1_btb_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_btb_hist_offset:stall_frn_fdis_iu6_i1_btb_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i1_btb_hist_d),
      .dout(stall_frn_fdis_iu6_i1_btb_hist_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_bta_val_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_bta_val_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_bta_val_offset]),
      .din(stall_frn_fdis_iu6_i1_bta_val_d),
      .dout(stall_frn_fdis_iu6_i1_bta_val_l2)
   );


   tri_rlmreg_p #(.WIDTH(20), .INIT(0)) stall_frn_fdis_iu6_i1_fusion_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_fusion_offset:stall_frn_fdis_iu6_i1_fusion_offset + 20 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_fusion_offset:stall_frn_fdis_iu6_i1_fusion_offset + 20 - 1]),
      .din(stall_frn_fdis_iu6_i1_fusion_d),
      .dout(stall_frn_fdis_iu6_i1_fusion_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_spec_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_spec_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_spec_offset]),
      .din(stall_frn_fdis_iu6_i1_spec_d),
      .dout(stall_frn_fdis_iu6_i1_spec_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_type_fp_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_type_fp_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_type_fp_offset]),
      .din(stall_frn_fdis_iu6_i1_type_fp_d),
      .dout(stall_frn_fdis_iu6_i1_type_fp_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_type_ap_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_type_ap_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_type_ap_offset]),
      .din(stall_frn_fdis_iu6_i1_type_ap_d),
      .dout(stall_frn_fdis_iu6_i1_type_ap_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_type_spv_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_type_spv_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_type_spv_offset]),
      .din(stall_frn_fdis_iu6_i1_type_spv_d),
      .dout(stall_frn_fdis_iu6_i1_type_spv_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_type_st_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_type_st_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_type_st_offset]),
      .din(stall_frn_fdis_iu6_i1_type_st_d),
      .dout(stall_frn_fdis_iu6_i1_type_st_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_async_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_async_block_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_async_block_offset]),
      .din(stall_frn_fdis_iu6_i1_async_block_d),
      .dout(stall_frn_fdis_iu6_i1_async_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_np1_flush_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_np1_flush_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_np1_flush_offset]),
      .din(stall_frn_fdis_iu6_i1_np1_flush_d),
      .dout(stall_frn_fdis_iu6_i1_np1_flush_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_core_block_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_core_block_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_core_block_offset]),
      .din(stall_frn_fdis_iu6_i1_core_block_d),
      .dout(stall_frn_fdis_iu6_i1_core_block_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_isram_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_isram_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_isram_offset]),
      .din(stall_frn_fdis_iu6_i1_isram_d),
      .dout(stall_frn_fdis_iu6_i1_isram_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_isload_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_isload_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_isload_offset]),
      .din(stall_frn_fdis_iu6_i1_isload_d),
      .dout(stall_frn_fdis_iu6_i1_isload_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_isstore_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_isstore_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_isstore_offset]),
      .din(stall_frn_fdis_iu6_i1_isstore_d),
      .dout(stall_frn_fdis_iu6_i1_isstore_l2)
   );


   tri_rlmreg_p #(.WIDTH(32), .INIT(0)) stall_frn_fdis_iu6_i1_instr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_instr_offset:stall_frn_fdis_iu6_i1_instr_offset + 32 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_instr_offset:stall_frn_fdis_iu6_i1_instr_offset + 32 - 1]),
      .din(stall_frn_fdis_iu6_i1_instr_d),
      .dout(stall_frn_fdis_iu6_i1_instr_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) stall_frn_fdis_iu6_i1_ifar_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_ifar_offset:stall_frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_ifar_offset:stall_frn_fdis_iu6_i1_ifar_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(stall_frn_fdis_iu6_i1_ifar_d),
      .dout(stall_frn_fdis_iu6_i1_ifar_l2)
   );


   tri_rlmreg_p #(.WIDTH((`EFF_IFAR_WIDTH)), .INIT(0)) stall_frn_fdis_iu6_i1_bta_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_bta_offset:stall_frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_bta_offset:stall_frn_fdis_iu6_i1_bta_offset + (`EFF_IFAR_WIDTH) - 1]),
      .din(stall_frn_fdis_iu6_i1_bta_d),
      .dout(stall_frn_fdis_iu6_i1_bta_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_br_pred_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_br_pred_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_br_pred_offset]),
      .din(stall_frn_fdis_iu6_i1_br_pred_d),
      .dout(stall_frn_fdis_iu6_i1_br_pred_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_bh_update_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_bh_update_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_bh_update_offset]),
      .din(stall_frn_fdis_iu6_i1_bh_update_d),
      .dout(stall_frn_fdis_iu6_i1_bh_update_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i1_bh0_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_bh0_hist_offset:stall_frn_fdis_iu6_i1_bh0_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_bh0_hist_offset:stall_frn_fdis_iu6_i1_bh0_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i1_bh0_hist_d),
      .dout(stall_frn_fdis_iu6_i1_bh0_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i1_bh1_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_bh1_hist_offset:stall_frn_fdis_iu6_i1_bh1_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_bh1_hist_offset:stall_frn_fdis_iu6_i1_bh1_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i1_bh1_hist_d),
      .dout(stall_frn_fdis_iu6_i1_bh1_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) stall_frn_fdis_iu6_i1_bh2_hist_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_bh2_hist_offset:stall_frn_fdis_iu6_i1_bh2_hist_offset + 2 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_bh2_hist_offset:stall_frn_fdis_iu6_i1_bh2_hist_offset + 2 - 1]),
      .din(stall_frn_fdis_iu6_i1_bh2_hist_d),
      .dout(stall_frn_fdis_iu6_i1_bh2_hist_l2)
   );


   tri_rlmreg_p #(.WIDTH(18), .INIT(0)) stall_frn_fdis_iu6_i1_gshare_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_gshare_offset:stall_frn_fdis_iu6_i1_gshare_offset + 18 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_gshare_offset:stall_frn_fdis_iu6_i1_gshare_offset + 18 - 1]),
      .din(stall_frn_fdis_iu6_i1_gshare_d),
      .dout(stall_frn_fdis_iu6_i1_gshare_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_ls_ptr_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_ls_ptr_offset:stall_frn_fdis_iu6_i1_ls_ptr_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_ls_ptr_offset:stall_frn_fdis_iu6_i1_ls_ptr_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_ls_ptr_d),
      .dout(stall_frn_fdis_iu6_i1_ls_ptr_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_match_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_match_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_match_offset]),
      .din(stall_frn_fdis_iu6_i1_match_d),
      .dout(stall_frn_fdis_iu6_i1_match_l2)
   );


   tri_rlmreg_p #(.WIDTH(4), .INIT(0)) stall_frn_fdis_iu6_i1_ilat_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_ilat_offset:stall_frn_fdis_iu6_i1_ilat_offset + 4 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_ilat_offset:stall_frn_fdis_iu6_i1_ilat_offset + 4 - 1]),
      .din(stall_frn_fdis_iu6_i1_ilat_d),
      .dout(stall_frn_fdis_iu6_i1_ilat_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_t1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_t1_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_t1_v_offset]),
      .din(stall_frn_fdis_iu6_i1_t1_v_d),
      .dout(stall_frn_fdis_iu6_i1_t1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_t1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t1_t_offset:stall_frn_fdis_iu6_i1_t1_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t1_t_offset:stall_frn_fdis_iu6_i1_t1_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_t1_t_d),
      .dout(stall_frn_fdis_iu6_i1_t1_t_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t1_a_offset:stall_frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t1_a_offset:stall_frn_fdis_iu6_i1_t1_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t1_a_d),
      .dout(stall_frn_fdis_iu6_i1_t1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t1_p_offset:stall_frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t1_p_offset:stall_frn_fdis_iu6_i1_t1_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t1_p_d),
      .dout(stall_frn_fdis_iu6_i1_t1_p_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_t2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_t2_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_t2_v_offset]),
      .din(stall_frn_fdis_iu6_i1_t2_v_d),
      .dout(stall_frn_fdis_iu6_i1_t2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t2_a_offset:stall_frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t2_a_offset:stall_frn_fdis_iu6_i1_t2_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t2_a_d),
      .dout(stall_frn_fdis_iu6_i1_t2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t2_p_offset:stall_frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t2_p_offset:stall_frn_fdis_iu6_i1_t2_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t2_p_d),
      .dout(stall_frn_fdis_iu6_i1_t2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_t2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t2_t_offset:stall_frn_fdis_iu6_i1_t2_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t2_t_offset:stall_frn_fdis_iu6_i1_t2_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_t2_t_d),
      .dout(stall_frn_fdis_iu6_i1_t2_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_t3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_t3_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_t3_v_offset]),
      .din(stall_frn_fdis_iu6_i1_t3_v_d),
      .dout(stall_frn_fdis_iu6_i1_t3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t3_a_offset:stall_frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t3_a_offset:stall_frn_fdis_iu6_i1_t3_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t3_a_d),
      .dout(stall_frn_fdis_iu6_i1_t3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_t3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t3_p_offset:stall_frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t3_p_offset:stall_frn_fdis_iu6_i1_t3_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_t3_p_d),
      .dout(stall_frn_fdis_iu6_i1_t3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_t3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_t3_t_offset:stall_frn_fdis_iu6_i1_t3_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_t3_t_offset:stall_frn_fdis_iu6_i1_t3_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_t3_t_d),
      .dout(stall_frn_fdis_iu6_i1_t3_t_l2)
   );


   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s1_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_v_offset]),
      .din(stall_frn_fdis_iu6_i1_s1_v_d),
      .dout(stall_frn_fdis_iu6_i1_s1_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s1_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_a_offset:stall_frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_a_offset:stall_frn_fdis_iu6_i1_s1_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s1_a_d),
      .dout(stall_frn_fdis_iu6_i1_s1_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s1_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_p_offset:stall_frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_p_offset:stall_frn_fdis_iu6_i1_s1_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s1_p_d),
      .dout(stall_frn_fdis_iu6_i1_s1_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s1_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_itag_offset:stall_frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_itag_offset:stall_frn_fdis_iu6_i1_s1_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s1_itag_d),
      .dout(stall_frn_fdis_iu6_i1_s1_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_s1_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_t_offset:stall_frn_fdis_iu6_i1_s1_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_t_offset:stall_frn_fdis_iu6_i1_s1_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_s1_t_d),
      .dout(stall_frn_fdis_iu6_i1_s1_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s1_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s1_dep_hit_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s1_dep_hit_offset]),
      .din(stall_frn_fdis_iu6_i1_s1_dep_hit_d),
      .dout(stall_frn_fdis_iu6_i1_s1_dep_hit_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s2_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_v_offset]),
      .din(stall_frn_fdis_iu6_i1_s2_v_d),
      .dout(stall_frn_fdis_iu6_i1_s2_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s2_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_a_offset:stall_frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_a_offset:stall_frn_fdis_iu6_i1_s2_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s2_a_d),
      .dout(stall_frn_fdis_iu6_i1_s2_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s2_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_p_offset:stall_frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_p_offset:stall_frn_fdis_iu6_i1_s2_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s2_p_d),
      .dout(stall_frn_fdis_iu6_i1_s2_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s2_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_itag_offset:stall_frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_itag_offset:stall_frn_fdis_iu6_i1_s2_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s2_itag_d),
      .dout(stall_frn_fdis_iu6_i1_s2_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_s2_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_t_offset:stall_frn_fdis_iu6_i1_s2_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_t_offset:stall_frn_fdis_iu6_i1_s2_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_s2_t_d),
      .dout(stall_frn_fdis_iu6_i1_s2_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s2_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s2_dep_hit_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s2_dep_hit_offset]),
      .din(stall_frn_fdis_iu6_i1_s2_dep_hit_d),
      .dout(stall_frn_fdis_iu6_i1_s2_dep_hit_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s3_v_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_v_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_v_offset]),
      .din(stall_frn_fdis_iu6_i1_s3_v_d),
      .dout(stall_frn_fdis_iu6_i1_s3_v_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s3_a_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_a_offset:stall_frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_a_offset:stall_frn_fdis_iu6_i1_s3_a_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s3_a_d),
      .dout(stall_frn_fdis_iu6_i1_s3_a_l2)
   );


   tri_rlmreg_p #(.WIDTH(`GPR_POOL_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s3_p_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_p_offset:stall_frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_p_offset:stall_frn_fdis_iu6_i1_s3_p_offset + `GPR_POOL_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s3_p_d),
      .dout(stall_frn_fdis_iu6_i1_s3_p_l2)
   );


   tri_rlmreg_p #(.WIDTH(`ITAG_SIZE_ENC), .INIT(0)) stall_frn_fdis_iu6_i1_s3_itag_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_itag_offset:stall_frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_itag_offset:stall_frn_fdis_iu6_i1_s3_itag_offset + `ITAG_SIZE_ENC - 1]),
      .din(stall_frn_fdis_iu6_i1_s3_itag_d),
      .dout(stall_frn_fdis_iu6_i1_s3_itag_l2)
   );


   tri_rlmreg_p #(.WIDTH(3), .INIT(0)) stall_frn_fdis_iu6_i1_s3_t_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_t_offset:stall_frn_fdis_iu6_i1_s3_t_offset + 3 - 1]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_t_offset:stall_frn_fdis_iu6_i1_s3_t_offset + 3 - 1]),
      .din(stall_frn_fdis_iu6_i1_s3_t_d),
      .dout(stall_frn_fdis_iu6_i1_s3_t_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) stall_frn_fdis_iu6_i1_s3_dep_hit_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(stall_frn_fdis_iu6_i1_act),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[stall_frn_fdis_iu6_i1_s3_dep_hit_offset]),
      .scout(sov[stall_frn_fdis_iu6_i1_s3_dep_hit_offset]),
      .din(stall_frn_fdis_iu6_i1_s3_dep_hit_d),
      .dout(stall_frn_fdis_iu6_i1_s3_dep_hit_l2)
   );

   //-----------------------------------------------
   // performance
   //-----------------------------------------------
   tri_rlmlatch_p #(.INIT(0)) perf_iu5_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_stall_offset]),
      .scout(sov[perf_iu5_stall_offset]),
      .din(perf_iu5_stall_d),
      .dout(perf_iu5_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_cpl_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_cpl_credit_stall_offset]),
      .scout(sov[perf_iu5_cpl_credit_stall_offset]),
      .din(perf_iu5_cpl_credit_stall_d),
      .dout(perf_iu5_cpl_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_gpr_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_gpr_credit_stall_offset]),
      .scout(sov[perf_iu5_gpr_credit_stall_offset]),
      .din(perf_iu5_gpr_credit_stall_d),
      .dout(perf_iu5_gpr_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_cr_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_cr_credit_stall_offset]),
      .scout(sov[perf_iu5_cr_credit_stall_offset]),
      .din(perf_iu5_cr_credit_stall_d),
      .dout(perf_iu5_cr_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_lr_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_lr_credit_stall_offset]),
      .scout(sov[perf_iu5_lr_credit_stall_offset]),
      .din(perf_iu5_lr_credit_stall_d),
      .dout(perf_iu5_lr_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_ctr_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_ctr_credit_stall_offset]),
      .scout(sov[perf_iu5_ctr_credit_stall_offset]),
      .din(perf_iu5_ctr_credit_stall_d),
      .dout(perf_iu5_ctr_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_xer_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_xer_credit_stall_offset]),
      .scout(sov[perf_iu5_xer_credit_stall_offset]),
      .din(perf_iu5_xer_credit_stall_d),
      .dout(perf_iu5_xer_credit_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_br_hold_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_br_hold_stall_offset]),
      .scout(sov[perf_iu5_br_hold_stall_offset]),
      .din(perf_iu5_br_hold_stall_d),
      .dout(perf_iu5_br_hold_stall_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) perf_iu5_axu_hold_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .sg(pc_iu_sg_0),
      .force_t(force_t),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .d_mode(d_mode),
      .scin(siv[perf_iu5_axu_hold_stall_offset]),
      .scout(sov[perf_iu5_axu_hold_stall_offset]),
      .din(perf_iu5_axu_hold_stall_d),
      .dout(perf_iu5_axu_hold_stall_l2)
   );


   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(2)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2,pc_iu_sg_2}),
      .q({pc_iu_func_sl_thold_1,pc_iu_sg_1})
   );


   tri_plat #(.WIDTH(2)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1,pc_iu_sg_1}),
      .q({pc_iu_func_sl_thold_0,pc_iu_sg_0})
   );


   tri_lcbor  perv_lcbor(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], func_scan_in};
   assign map_siv[0] = sov[0];
   assign map_siv[1] = map_sov[0];
   assign map_siv[2] = map_sov[1];
   assign map_siv[3] = map_sov[2];
   assign map_siv[4] = map_sov[3];
   assign func_scan_out = map_sov[4];

endmodule
