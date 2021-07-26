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
//* NAME: iuq_rn_top.vhdl
//*
//*********************************************************************

`include "tri_a2o.vh"


module iuq_rn_top(
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
   input [0:1]                    func_scan_in,
   output [0:1]                   func_scan_out,

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
   // SPR values
   //-----------------------------
   input                          spr_high_pri_mask,
   input                          spr_cpcr_we,
   input [0:6]                    spr_cpcr3_cp_cnt,
   input [0:6]                    spr_cpcr5_cp_cnt,
   input                          spr_single_issue,

   //-----------------------------
   // Stall to decode
   //-----------------------------
   output                         frn_fdec_iu5_stall,

   //-----------------------------
   // Stall from dispatch
   //-----------------------------
   input                          fdis_frn_iu6_stall,

   //----------------------------
   // Completion Interface
   //----------------------------
   input                          cp_rn_i0_axu_exception_val,
   input [0:3]                    cp_rn_i0_axu_exception,
   input                          cp_rn_i1_axu_exception_val,
   input [0:3]                    cp_rn_i1_axu_exception,
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

      wire                           au_iu_iu5_stall;
      wire                           iu_au_iu5_send_ok;
      wire [0:`ITAG_SIZE_ENC-1]       iu_au_iu5_next_itag_i0;
      wire [0:`ITAG_SIZE_ENC-1]       iu_au_iu5_next_itag_i1;
      wire                           au_iu_iu5_axu0_send_ok;
      wire                           au_iu_iu5_axu1_send_ok;

      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_t1_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_t2_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_t3_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_s1_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_s2_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i0_s3_p;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i0_s1_itag;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i0_s2_itag;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i0_s3_itag;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_t1_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_t2_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_t3_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_s1_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_s2_p;
      wire [0:`GPR_POOL_ENC-1]        au_iu_iu5_i1_s3_p;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i1_s1_itag;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i1_s2_itag;
      wire [0:`ITAG_SIZE_ENC-1]       au_iu_iu5_i1_s3_itag;
      wire                            au_iu_iu5_i1_s1_dep_hit;
      wire                            au_iu_iu5_i1_s2_dep_hit;
      wire                            au_iu_iu5_i1_s3_dep_hit;


      iuq_rn  fx_rn0(
         .vdd(vdd),
         .gnd(gnd),
         .nclk(nclk),
         .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
         .pc_iu_sg_2(pc_iu_sg_2),
         .clkoff_b(clkoff_b),
         .act_dis(act_dis),
         .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
         .d_mode(d_mode),
         .delay_lclkr(delay_lclkr),
         .mpw1_b(mpw1_b),
         .mpw2_b(mpw2_b),
         .func_scan_in(func_scan_in[0]),
         .func_scan_out(func_scan_out[0]),

         //-------------------------------
         // Performance interface with I$
         //-------------------------------
         .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
         .perf_iu5_stall(perf_iu5_stall),
         .perf_iu5_cpl_credit_stall(perf_iu5_cpl_credit_stall),
         .perf_iu5_gpr_credit_stall(perf_iu5_gpr_credit_stall),
         .perf_iu5_cr_credit_stall(perf_iu5_cr_credit_stall),
         .perf_iu5_lr_credit_stall(perf_iu5_lr_credit_stall),
         .perf_iu5_ctr_credit_stall(perf_iu5_ctr_credit_stall),
         .perf_iu5_xer_credit_stall(perf_iu5_xer_credit_stall),
         .perf_iu5_br_hold_stall(perf_iu5_br_hold_stall),
         .perf_iu5_axu_hold_stall(perf_iu5_axu_hold_stall),

         //-----------------------------
         // Inputs to rename from decode
         //-----------------------------
         .fdec_frn_iu5_i0_vld(fdec_frn_iu5_i0_vld),
         .fdec_frn_iu5_i0_ucode(fdec_frn_iu5_i0_ucode),
         .fdec_frn_iu5_i0_2ucode(fdec_frn_iu5_i0_2ucode),
         .fdec_frn_iu5_i0_fuse_nop(fdec_frn_iu5_i0_fuse_nop),
         .fdec_frn_iu5_i0_rte_lq(fdec_frn_iu5_i0_rte_lq),
         .fdec_frn_iu5_i0_rte_sq(fdec_frn_iu5_i0_rte_sq),
         .fdec_frn_iu5_i0_rte_fx0(fdec_frn_iu5_i0_rte_fx0),
         .fdec_frn_iu5_i0_rte_fx1(fdec_frn_iu5_i0_rte_fx1),
         .fdec_frn_iu5_i0_rte_axu0(fdec_frn_iu5_i0_rte_axu0),
         .fdec_frn_iu5_i0_rte_axu1(fdec_frn_iu5_i0_rte_axu1),
         .fdec_frn_iu5_i0_valop(fdec_frn_iu5_i0_valop),
         .fdec_frn_iu5_i0_ord(fdec_frn_iu5_i0_ord),
         .fdec_frn_iu5_i0_cord(fdec_frn_iu5_i0_cord),
         .fdec_frn_iu5_i0_error(fdec_frn_iu5_i0_error),
         .fdec_frn_iu5_i0_btb_entry(fdec_frn_iu5_i0_btb_entry),
         .fdec_frn_iu5_i0_btb_hist(fdec_frn_iu5_i0_btb_hist),
         .fdec_frn_iu5_i0_bta_val(fdec_frn_iu5_i0_bta_val),
         .fdec_frn_iu5_i0_fusion(fdec_frn_iu5_i0_fusion),
         .fdec_frn_iu5_i0_spec(fdec_frn_iu5_i0_spec),
         .fdec_frn_iu5_i0_type_fp(fdec_frn_iu5_i0_type_fp),
         .fdec_frn_iu5_i0_type_ap(fdec_frn_iu5_i0_type_ap),
         .fdec_frn_iu5_i0_type_spv(fdec_frn_iu5_i0_type_spv),
         .fdec_frn_iu5_i0_type_st(fdec_frn_iu5_i0_type_st),
         .fdec_frn_iu5_i0_async_block(fdec_frn_iu5_i0_async_block),
         .fdec_frn_iu5_i0_np1_flush(fdec_frn_iu5_i0_np1_flush),
         .fdec_frn_iu5_i0_core_block(fdec_frn_iu5_i0_core_block),
         .fdec_frn_iu5_i0_isram(fdec_frn_iu5_i0_isram),
         .fdec_frn_iu5_i0_isload(fdec_frn_iu5_i0_isload),
         .fdec_frn_iu5_i0_isstore(fdec_frn_iu5_i0_isstore),
         .fdec_frn_iu5_i0_instr(fdec_frn_iu5_i0_instr),
         .fdec_frn_iu5_i0_ifar(fdec_frn_iu5_i0_ifar),
         .fdec_frn_iu5_i0_bta(fdec_frn_iu5_i0_bta),
         .fdec_frn_iu5_i0_br_pred(fdec_frn_iu5_i0_br_pred),
         .fdec_frn_iu5_i0_bh_update(fdec_frn_iu5_i0_bh_update),
         .fdec_frn_iu5_i0_bh0_hist(fdec_frn_iu5_i0_bh0_hist),
         .fdec_frn_iu5_i0_bh1_hist(fdec_frn_iu5_i0_bh1_hist),
         .fdec_frn_iu5_i0_bh2_hist(fdec_frn_iu5_i0_bh2_hist),
         .fdec_frn_iu5_i0_gshare(fdec_frn_iu5_i0_gshare),
         .fdec_frn_iu5_i0_ls_ptr(fdec_frn_iu5_i0_ls_ptr),
         .fdec_frn_iu5_i0_match(fdec_frn_iu5_i0_match),
         .fdec_frn_iu5_i0_ilat(fdec_frn_iu5_i0_ilat),
         .fdec_frn_iu5_i0_t1_v(fdec_frn_iu5_i0_t1_v),
         .fdec_frn_iu5_i0_t1_t(fdec_frn_iu5_i0_t1_t),
         .fdec_frn_iu5_i0_t1_a(fdec_frn_iu5_i0_t1_a),
         .fdec_frn_iu5_i0_t2_v(fdec_frn_iu5_i0_t2_v),
         .fdec_frn_iu5_i0_t2_a(fdec_frn_iu5_i0_t2_a),
         .fdec_frn_iu5_i0_t2_t(fdec_frn_iu5_i0_t2_t),
         .fdec_frn_iu5_i0_t3_v(fdec_frn_iu5_i0_t3_v),
         .fdec_frn_iu5_i0_t3_a(fdec_frn_iu5_i0_t3_a),
         .fdec_frn_iu5_i0_t3_t(fdec_frn_iu5_i0_t3_t),
         .fdec_frn_iu5_i0_s1_v(fdec_frn_iu5_i0_s1_v),
         .fdec_frn_iu5_i0_s1_a(fdec_frn_iu5_i0_s1_a),
         .fdec_frn_iu5_i0_s1_t(fdec_frn_iu5_i0_s1_t),
         .fdec_frn_iu5_i0_s2_v(fdec_frn_iu5_i0_s2_v),
         .fdec_frn_iu5_i0_s2_a(fdec_frn_iu5_i0_s2_a),
         .fdec_frn_iu5_i0_s2_t(fdec_frn_iu5_i0_s2_t),
         .fdec_frn_iu5_i0_s3_v(fdec_frn_iu5_i0_s3_v),
         .fdec_frn_iu5_i0_s3_a(fdec_frn_iu5_i0_s3_a),
         .fdec_frn_iu5_i0_s3_t(fdec_frn_iu5_i0_s3_t),

         .fdec_frn_iu5_i1_vld(fdec_frn_iu5_i1_vld),
         .fdec_frn_iu5_i1_ucode(fdec_frn_iu5_i1_ucode),
         .fdec_frn_iu5_i1_fuse_nop(fdec_frn_iu5_i1_fuse_nop),
         .fdec_frn_iu5_i1_rte_lq(fdec_frn_iu5_i1_rte_lq),
         .fdec_frn_iu5_i1_rte_sq(fdec_frn_iu5_i1_rte_sq),
         .fdec_frn_iu5_i1_rte_fx0(fdec_frn_iu5_i1_rte_fx0),
         .fdec_frn_iu5_i1_rte_fx1(fdec_frn_iu5_i1_rte_fx1),
         .fdec_frn_iu5_i1_rte_axu0(fdec_frn_iu5_i1_rte_axu0),
         .fdec_frn_iu5_i1_rte_axu1(fdec_frn_iu5_i1_rte_axu1),
         .fdec_frn_iu5_i1_valop(fdec_frn_iu5_i1_valop),
         .fdec_frn_iu5_i1_ord(fdec_frn_iu5_i1_ord),
         .fdec_frn_iu5_i1_cord(fdec_frn_iu5_i1_cord),
         .fdec_frn_iu5_i1_error(fdec_frn_iu5_i1_error),
         .fdec_frn_iu5_i1_btb_entry(fdec_frn_iu5_i1_btb_entry),
         .fdec_frn_iu5_i1_btb_hist(fdec_frn_iu5_i1_btb_hist),
         .fdec_frn_iu5_i1_bta_val(fdec_frn_iu5_i1_bta_val),
         .fdec_frn_iu5_i1_fusion(fdec_frn_iu5_i1_fusion),
         .fdec_frn_iu5_i1_spec(fdec_frn_iu5_i1_spec),
         .fdec_frn_iu5_i1_type_fp(fdec_frn_iu5_i1_type_fp),
         .fdec_frn_iu5_i1_type_ap(fdec_frn_iu5_i1_type_ap),
         .fdec_frn_iu5_i1_type_spv(fdec_frn_iu5_i1_type_spv),
         .fdec_frn_iu5_i1_type_st(fdec_frn_iu5_i1_type_st),
         .fdec_frn_iu5_i1_async_block(fdec_frn_iu5_i1_async_block),
         .fdec_frn_iu5_i1_np1_flush(fdec_frn_iu5_i1_np1_flush),
         .fdec_frn_iu5_i1_core_block(fdec_frn_iu5_i1_core_block),
         .fdec_frn_iu5_i1_isram(fdec_frn_iu5_i1_isram),
         .fdec_frn_iu5_i1_isload(fdec_frn_iu5_i1_isload),
         .fdec_frn_iu5_i1_isstore(fdec_frn_iu5_i1_isstore),
         .fdec_frn_iu5_i1_instr(fdec_frn_iu5_i1_instr),
         .fdec_frn_iu5_i1_ifar(fdec_frn_iu5_i1_ifar),
         .fdec_frn_iu5_i1_bta(fdec_frn_iu5_i1_bta),
         .fdec_frn_iu5_i1_br_pred(fdec_frn_iu5_i1_br_pred),
         .fdec_frn_iu5_i1_bh_update(fdec_frn_iu5_i1_bh_update),
         .fdec_frn_iu5_i1_bh0_hist(fdec_frn_iu5_i1_bh0_hist),
         .fdec_frn_iu5_i1_bh1_hist(fdec_frn_iu5_i1_bh1_hist),
         .fdec_frn_iu5_i1_bh2_hist(fdec_frn_iu5_i1_bh2_hist),
         .fdec_frn_iu5_i1_gshare(fdec_frn_iu5_i1_gshare),
         .fdec_frn_iu5_i1_ls_ptr(fdec_frn_iu5_i1_ls_ptr),
         .fdec_frn_iu5_i1_match(fdec_frn_iu5_i1_match),
         .fdec_frn_iu5_i1_ilat(fdec_frn_iu5_i1_ilat),
         .fdec_frn_iu5_i1_t1_v(fdec_frn_iu5_i1_t1_v),
         .fdec_frn_iu5_i1_t1_t(fdec_frn_iu5_i1_t1_t),
         .fdec_frn_iu5_i1_t1_a(fdec_frn_iu5_i1_t1_a),
         .fdec_frn_iu5_i1_t2_v(fdec_frn_iu5_i1_t2_v),
         .fdec_frn_iu5_i1_t2_a(fdec_frn_iu5_i1_t2_a),
         .fdec_frn_iu5_i1_t2_t(fdec_frn_iu5_i1_t2_t),
         .fdec_frn_iu5_i1_t3_v(fdec_frn_iu5_i1_t3_v),
         .fdec_frn_iu5_i1_t3_a(fdec_frn_iu5_i1_t3_a),
         .fdec_frn_iu5_i1_t3_t(fdec_frn_iu5_i1_t3_t),
         .fdec_frn_iu5_i1_s1_v(fdec_frn_iu5_i1_s1_v),
         .fdec_frn_iu5_i1_s1_a(fdec_frn_iu5_i1_s1_a),
         .fdec_frn_iu5_i1_s1_t(fdec_frn_iu5_i1_s1_t),
         .fdec_frn_iu5_i1_s2_v(fdec_frn_iu5_i1_s2_v),
         .fdec_frn_iu5_i1_s2_a(fdec_frn_iu5_i1_s2_a),
         .fdec_frn_iu5_i1_s2_t(fdec_frn_iu5_i1_s2_t),
         .fdec_frn_iu5_i1_s3_v(fdec_frn_iu5_i1_s3_v),
         .fdec_frn_iu5_i1_s3_a(fdec_frn_iu5_i1_s3_a),
         .fdec_frn_iu5_i1_s3_t(fdec_frn_iu5_i1_s3_t),

         //-----------------------------
         // SPR values
         //-----------------------------
         .spr_high_pri_mask(spr_high_pri_mask),
         .spr_cpcr_we(spr_cpcr_we),
         .spr_cpcr3_cp_cnt(spr_cpcr3_cp_cnt),
         .spr_cpcr5_cp_cnt(spr_cpcr5_cp_cnt),
         .spr_single_issue(spr_single_issue),

         //-----------------------------
         // Stall to decode
         //-----------------------------
         .frn_fdec_iu5_stall(frn_fdec_iu5_stall),
         .au_iu_iu5_stall(au_iu_iu5_stall),

         //-----------------------------
         // Stall from dispatch
         //-----------------------------
         .fdis_frn_iu6_stall(fdis_frn_iu6_stall),

         //----------------------------
         // Completion Interface
         //----------------------------
         .cp_rn_empty(cp_rn_empty),
         .cp_rn_i0_v(cp_rn_i0_v),
         .cp_rn_i0_itag(cp_rn_i0_itag),
         .cp_rn_i0_t1_v(cp_rn_i0_t1_v),
         .cp_rn_i0_t1_t(cp_rn_i0_t1_t),
         .cp_rn_i0_t1_p(cp_rn_i0_t1_p),
         .cp_rn_i0_t1_a(cp_rn_i0_t1_a),
         .cp_rn_i0_t2_v(cp_rn_i0_t2_v),
         .cp_rn_i0_t2_t(cp_rn_i0_t2_t),
         .cp_rn_i0_t2_p(cp_rn_i0_t2_p),
         .cp_rn_i0_t2_a(cp_rn_i0_t2_a),
         .cp_rn_i0_t3_v(cp_rn_i0_t3_v),
         .cp_rn_i0_t3_t(cp_rn_i0_t3_t),
         .cp_rn_i0_t3_p(cp_rn_i0_t3_p),
         .cp_rn_i0_t3_a(cp_rn_i0_t3_a),

         .cp_rn_i1_v(cp_rn_i1_v),
         .cp_rn_i1_itag(cp_rn_i1_itag),
         .cp_rn_i1_t1_v(cp_rn_i1_t1_v),
         .cp_rn_i1_t1_t(cp_rn_i1_t1_t),
         .cp_rn_i1_t1_p(cp_rn_i1_t1_p),
         .cp_rn_i1_t1_a(cp_rn_i1_t1_a),
         .cp_rn_i1_t2_v(cp_rn_i1_t2_v),
         .cp_rn_i1_t2_t(cp_rn_i1_t2_t),
         .cp_rn_i1_t2_p(cp_rn_i1_t2_p),
         .cp_rn_i1_t2_a(cp_rn_i1_t2_a),
         .cp_rn_i1_t3_v(cp_rn_i1_t3_v),
         .cp_rn_i1_t3_t(cp_rn_i1_t3_t),
         .cp_rn_i1_t3_p(cp_rn_i1_t3_p),
         .cp_rn_i1_t3_a(cp_rn_i1_t3_a),

         .cp_flush(cp_flush),
         .cp_flush_into_uc(cp_flush_into_uc),
         .br_iu_redirect(br_iu_redirect),
         .cp_rn_uc_credit_free(cp_rn_uc_credit_free),

         //----------------------------------------------------------------
         // AXU Interface
         //----------------------------------------------------------------
         .iu_au_iu5_send_ok(iu_au_iu5_send_ok),
         .iu_au_iu5_next_itag_i0(iu_au_iu5_next_itag_i0),
         .iu_au_iu5_next_itag_i1(iu_au_iu5_next_itag_i1),
         .au_iu_iu5_axu0_send_ok(au_iu_iu5_axu0_send_ok),
         .au_iu_iu5_axu1_send_ok(au_iu_iu5_axu1_send_ok),

         .au_iu_iu5_i0_t1_p(au_iu_iu5_i0_t1_p),
         .au_iu_iu5_i0_t2_p(au_iu_iu5_i0_t2_p),
         .au_iu_iu5_i0_t3_p(au_iu_iu5_i0_t3_p),
         .au_iu_iu5_i0_s1_p(au_iu_iu5_i0_s1_p),
         .au_iu_iu5_i0_s2_p(au_iu_iu5_i0_s2_p),
         .au_iu_iu5_i0_s3_p(au_iu_iu5_i0_s3_p),

         .au_iu_iu5_i0_s1_itag(au_iu_iu5_i0_s1_itag),
         .au_iu_iu5_i0_s2_itag(au_iu_iu5_i0_s2_itag),
         .au_iu_iu5_i0_s3_itag(au_iu_iu5_i0_s3_itag),

         .au_iu_iu5_i1_t1_p(au_iu_iu5_i1_t1_p),
         .au_iu_iu5_i1_t2_p(au_iu_iu5_i1_t2_p),
         .au_iu_iu5_i1_t3_p(au_iu_iu5_i1_t3_p),
         .au_iu_iu5_i1_s1_p(au_iu_iu5_i1_s1_p),
         .au_iu_iu5_i1_s2_p(au_iu_iu5_i1_s2_p),
         .au_iu_iu5_i1_s3_p(au_iu_iu5_i1_s3_p),

         .au_iu_iu5_i1_s1_dep_hit(au_iu_iu5_i1_s1_dep_hit),
         .au_iu_iu5_i1_s2_dep_hit(au_iu_iu5_i1_s2_dep_hit),
         .au_iu_iu5_i1_s3_dep_hit(au_iu_iu5_i1_s3_dep_hit),

         .au_iu_iu5_i1_s1_itag(au_iu_iu5_i1_s1_itag),
         .au_iu_iu5_i1_s2_itag(au_iu_iu5_i1_s2_itag),
         .au_iu_iu5_i1_s3_itag(au_iu_iu5_i1_s3_itag),

         //----------------------------------------------------------------
         // Interface to reservation station - Completion is snooping also
         //----------------------------------------------------------------
         .frn_fdis_iu6_i0_vld(frn_fdis_iu6_i0_vld),
         .frn_fdis_iu6_i0_itag(frn_fdis_iu6_i0_itag),
         .frn_fdis_iu6_i0_ucode(frn_fdis_iu6_i0_ucode),
         .frn_fdis_iu6_i0_ucode_cnt(frn_fdis_iu6_i0_ucode_cnt),
         .frn_fdis_iu6_i0_2ucode(frn_fdis_iu6_i0_2ucode),
         .frn_fdis_iu6_i0_fuse_nop(frn_fdis_iu6_i0_fuse_nop),
         .frn_fdis_iu6_i0_rte_lq(frn_fdis_iu6_i0_rte_lq),
         .frn_fdis_iu6_i0_rte_sq(frn_fdis_iu6_i0_rte_sq),
         .frn_fdis_iu6_i0_rte_fx0(frn_fdis_iu6_i0_rte_fx0),
         .frn_fdis_iu6_i0_rte_fx1(frn_fdis_iu6_i0_rte_fx1),
         .frn_fdis_iu6_i0_rte_axu0(frn_fdis_iu6_i0_rte_axu0),
         .frn_fdis_iu6_i0_rte_axu1(frn_fdis_iu6_i0_rte_axu1),
         .frn_fdis_iu6_i0_valop(frn_fdis_iu6_i0_valop),
         .frn_fdis_iu6_i0_ord(frn_fdis_iu6_i0_ord),
         .frn_fdis_iu6_i0_cord(frn_fdis_iu6_i0_cord),
         .frn_fdis_iu6_i0_error(frn_fdis_iu6_i0_error),
         .frn_fdis_iu6_i0_btb_entry(frn_fdis_iu6_i0_btb_entry),
         .frn_fdis_iu6_i0_btb_hist(frn_fdis_iu6_i0_btb_hist),
         .frn_fdis_iu6_i0_bta_val(frn_fdis_iu6_i0_bta_val),
         .frn_fdis_iu6_i0_fusion(frn_fdis_iu6_i0_fusion),
         .frn_fdis_iu6_i0_spec(frn_fdis_iu6_i0_spec),
         .frn_fdis_iu6_i0_type_fp(frn_fdis_iu6_i0_type_fp),
         .frn_fdis_iu6_i0_type_ap(frn_fdis_iu6_i0_type_ap),
         .frn_fdis_iu6_i0_type_spv(frn_fdis_iu6_i0_type_spv),
         .frn_fdis_iu6_i0_type_st(frn_fdis_iu6_i0_type_st),
         .frn_fdis_iu6_i0_async_block(frn_fdis_iu6_i0_async_block),
         .frn_fdis_iu6_i0_np1_flush(frn_fdis_iu6_i0_np1_flush),
         .frn_fdis_iu6_i0_core_block(frn_fdis_iu6_i0_core_block),
         .frn_fdis_iu6_i0_isram(frn_fdis_iu6_i0_isram),
         .frn_fdis_iu6_i0_isload(frn_fdis_iu6_i0_isload),
         .frn_fdis_iu6_i0_isstore(frn_fdis_iu6_i0_isstore),
         .frn_fdis_iu6_i0_instr(frn_fdis_iu6_i0_instr),
         .frn_fdis_iu6_i0_ifar(frn_fdis_iu6_i0_ifar),
         .frn_fdis_iu6_i0_bta(frn_fdis_iu6_i0_bta),
         .frn_fdis_iu6_i0_br_pred(frn_fdis_iu6_i0_br_pred),
         .frn_fdis_iu6_i0_bh_update(frn_fdis_iu6_i0_bh_update),
         .frn_fdis_iu6_i0_bh0_hist(frn_fdis_iu6_i0_bh0_hist),
         .frn_fdis_iu6_i0_bh1_hist(frn_fdis_iu6_i0_bh1_hist),
         .frn_fdis_iu6_i0_bh2_hist(frn_fdis_iu6_i0_bh2_hist),
         .frn_fdis_iu6_i0_gshare(frn_fdis_iu6_i0_gshare),
         .frn_fdis_iu6_i0_ls_ptr(frn_fdis_iu6_i0_ls_ptr),
         .frn_fdis_iu6_i0_match(frn_fdis_iu6_i0_match),
         .frn_fdis_iu6_i0_ilat(frn_fdis_iu6_i0_ilat),
         .frn_fdis_iu6_i0_t1_v(frn_fdis_iu6_i0_t1_v),
         .frn_fdis_iu6_i0_t1_t(frn_fdis_iu6_i0_t1_t),
         .frn_fdis_iu6_i0_t1_a(frn_fdis_iu6_i0_t1_a),
         .frn_fdis_iu6_i0_t1_p(frn_fdis_iu6_i0_t1_p),
         .frn_fdis_iu6_i0_t2_v(frn_fdis_iu6_i0_t2_v),
         .frn_fdis_iu6_i0_t2_a(frn_fdis_iu6_i0_t2_a),
         .frn_fdis_iu6_i0_t2_p(frn_fdis_iu6_i0_t2_p),
         .frn_fdis_iu6_i0_t2_t(frn_fdis_iu6_i0_t2_t),
         .frn_fdis_iu6_i0_t3_v(frn_fdis_iu6_i0_t3_v),
         .frn_fdis_iu6_i0_t3_a(frn_fdis_iu6_i0_t3_a),
         .frn_fdis_iu6_i0_t3_p(frn_fdis_iu6_i0_t3_p),
         .frn_fdis_iu6_i0_t3_t(frn_fdis_iu6_i0_t3_t),
         .frn_fdis_iu6_i0_s1_v(frn_fdis_iu6_i0_s1_v),
         .frn_fdis_iu6_i0_s1_a(frn_fdis_iu6_i0_s1_a),
         .frn_fdis_iu6_i0_s1_p(frn_fdis_iu6_i0_s1_p),
         .frn_fdis_iu6_i0_s1_itag(frn_fdis_iu6_i0_s1_itag),
         .frn_fdis_iu6_i0_s1_t(frn_fdis_iu6_i0_s1_t),
         .frn_fdis_iu6_i0_s2_v(frn_fdis_iu6_i0_s2_v),
         .frn_fdis_iu6_i0_s2_a(frn_fdis_iu6_i0_s2_a),
         .frn_fdis_iu6_i0_s2_p(frn_fdis_iu6_i0_s2_p),
         .frn_fdis_iu6_i0_s2_itag(frn_fdis_iu6_i0_s2_itag),
         .frn_fdis_iu6_i0_s2_t(frn_fdis_iu6_i0_s2_t),
         .frn_fdis_iu6_i0_s3_v(frn_fdis_iu6_i0_s3_v),
         .frn_fdis_iu6_i0_s3_a(frn_fdis_iu6_i0_s3_a),
         .frn_fdis_iu6_i0_s3_p(frn_fdis_iu6_i0_s3_p),
         .frn_fdis_iu6_i0_s3_itag(frn_fdis_iu6_i0_s3_itag),
         .frn_fdis_iu6_i0_s3_t(frn_fdis_iu6_i0_s3_t),

         .frn_fdis_iu6_i1_vld(frn_fdis_iu6_i1_vld),
         .frn_fdis_iu6_i1_itag(frn_fdis_iu6_i1_itag),
         .frn_fdis_iu6_i1_ucode(frn_fdis_iu6_i1_ucode),
         .frn_fdis_iu6_i1_ucode_cnt(frn_fdis_iu6_i1_ucode_cnt),
         .frn_fdis_iu6_i1_fuse_nop(frn_fdis_iu6_i1_fuse_nop),
         .frn_fdis_iu6_i1_rte_lq(frn_fdis_iu6_i1_rte_lq),
         .frn_fdis_iu6_i1_rte_sq(frn_fdis_iu6_i1_rte_sq),
         .frn_fdis_iu6_i1_rte_fx0(frn_fdis_iu6_i1_rte_fx0),
         .frn_fdis_iu6_i1_rte_fx1(frn_fdis_iu6_i1_rte_fx1),
         .frn_fdis_iu6_i1_rte_axu0(frn_fdis_iu6_i1_rte_axu0),
         .frn_fdis_iu6_i1_rte_axu1(frn_fdis_iu6_i1_rte_axu1),
         .frn_fdis_iu6_i1_valop(frn_fdis_iu6_i1_valop),
         .frn_fdis_iu6_i1_ord(frn_fdis_iu6_i1_ord),
         .frn_fdis_iu6_i1_cord(frn_fdis_iu6_i1_cord),
         .frn_fdis_iu6_i1_error(frn_fdis_iu6_i1_error),
         .frn_fdis_iu6_i1_btb_entry(frn_fdis_iu6_i1_btb_entry),
         .frn_fdis_iu6_i1_btb_hist(frn_fdis_iu6_i1_btb_hist),
         .frn_fdis_iu6_i1_bta_val(frn_fdis_iu6_i1_bta_val),
         .frn_fdis_iu6_i1_fusion(frn_fdis_iu6_i1_fusion),
         .frn_fdis_iu6_i1_spec(frn_fdis_iu6_i1_spec),
         .frn_fdis_iu6_i1_type_fp(frn_fdis_iu6_i1_type_fp),
         .frn_fdis_iu6_i1_type_ap(frn_fdis_iu6_i1_type_ap),
         .frn_fdis_iu6_i1_type_spv(frn_fdis_iu6_i1_type_spv),
         .frn_fdis_iu6_i1_type_st(frn_fdis_iu6_i1_type_st),
         .frn_fdis_iu6_i1_async_block(frn_fdis_iu6_i1_async_block),
         .frn_fdis_iu6_i1_np1_flush(frn_fdis_iu6_i1_np1_flush),
         .frn_fdis_iu6_i1_core_block(frn_fdis_iu6_i1_core_block),
         .frn_fdis_iu6_i1_isram(frn_fdis_iu6_i1_isram),
         .frn_fdis_iu6_i1_isload(frn_fdis_iu6_i1_isload),
         .frn_fdis_iu6_i1_isstore(frn_fdis_iu6_i1_isstore),
         .frn_fdis_iu6_i1_instr(frn_fdis_iu6_i1_instr),
         .frn_fdis_iu6_i1_ifar(frn_fdis_iu6_i1_ifar),
         .frn_fdis_iu6_i1_bta(frn_fdis_iu6_i1_bta),
         .frn_fdis_iu6_i1_br_pred(frn_fdis_iu6_i1_br_pred),
         .frn_fdis_iu6_i1_bh_update(frn_fdis_iu6_i1_bh_update),
         .frn_fdis_iu6_i1_bh0_hist(frn_fdis_iu6_i1_bh0_hist),
         .frn_fdis_iu6_i1_bh1_hist(frn_fdis_iu6_i1_bh1_hist),
         .frn_fdis_iu6_i1_bh2_hist(frn_fdis_iu6_i1_bh2_hist),
         .frn_fdis_iu6_i1_gshare(frn_fdis_iu6_i1_gshare),
         .frn_fdis_iu6_i1_ls_ptr(frn_fdis_iu6_i1_ls_ptr),
         .frn_fdis_iu6_i1_match(frn_fdis_iu6_i1_match),
         .frn_fdis_iu6_i1_ilat(frn_fdis_iu6_i1_ilat),
         .frn_fdis_iu6_i1_t1_v(frn_fdis_iu6_i1_t1_v),
         .frn_fdis_iu6_i1_t1_t(frn_fdis_iu6_i1_t1_t),
         .frn_fdis_iu6_i1_t1_a(frn_fdis_iu6_i1_t1_a),
         .frn_fdis_iu6_i1_t1_p(frn_fdis_iu6_i1_t1_p),
         .frn_fdis_iu6_i1_t2_v(frn_fdis_iu6_i1_t2_v),
         .frn_fdis_iu6_i1_t2_a(frn_fdis_iu6_i1_t2_a),
         .frn_fdis_iu6_i1_t2_p(frn_fdis_iu6_i1_t2_p),
         .frn_fdis_iu6_i1_t2_t(frn_fdis_iu6_i1_t2_t),
         .frn_fdis_iu6_i1_t3_v(frn_fdis_iu6_i1_t3_v),
         .frn_fdis_iu6_i1_t3_a(frn_fdis_iu6_i1_t3_a),
         .frn_fdis_iu6_i1_t3_p(frn_fdis_iu6_i1_t3_p),
         .frn_fdis_iu6_i1_t3_t(frn_fdis_iu6_i1_t3_t),
         .frn_fdis_iu6_i1_s1_v(frn_fdis_iu6_i1_s1_v),
         .frn_fdis_iu6_i1_s1_a(frn_fdis_iu6_i1_s1_a),
         .frn_fdis_iu6_i1_s1_p(frn_fdis_iu6_i1_s1_p),
         .frn_fdis_iu6_i1_s1_itag(frn_fdis_iu6_i1_s1_itag),
         .frn_fdis_iu6_i1_s1_t(frn_fdis_iu6_i1_s1_t),
         .frn_fdis_iu6_i1_s1_dep_hit(frn_fdis_iu6_i1_s1_dep_hit),
         .frn_fdis_iu6_i1_s2_v(frn_fdis_iu6_i1_s2_v),
         .frn_fdis_iu6_i1_s2_a(frn_fdis_iu6_i1_s2_a),
         .frn_fdis_iu6_i1_s2_p(frn_fdis_iu6_i1_s2_p),
         .frn_fdis_iu6_i1_s2_itag(frn_fdis_iu6_i1_s2_itag),
         .frn_fdis_iu6_i1_s2_t(frn_fdis_iu6_i1_s2_t),
         .frn_fdis_iu6_i1_s2_dep_hit(frn_fdis_iu6_i1_s2_dep_hit),
         .frn_fdis_iu6_i1_s3_v(frn_fdis_iu6_i1_s3_v),
         .frn_fdis_iu6_i1_s3_a(frn_fdis_iu6_i1_s3_a),
         .frn_fdis_iu6_i1_s3_p(frn_fdis_iu6_i1_s3_p),
         .frn_fdis_iu6_i1_s3_itag(frn_fdis_iu6_i1_s3_itag),
         .frn_fdis_iu6_i1_s3_t(frn_fdis_iu6_i1_s3_t),
         .frn_fdis_iu6_i1_s3_dep_hit(frn_fdis_iu6_i1_s3_dep_hit)

      );


      iuq_axu_fu_rn #(.FPR_POOL(`GPR_POOL), .FPR_UCODE_POOL(4), .FPSCR_POOL_ENC(5)) axu_rn0(
         .vdd(vdd),		// inout power_logic;
         .gnd(gnd),		// inout power_logic;
         .nclk(nclk),		// in clk_logic;
         .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),		// in std_ulogic;                     acts as reset for non-ibm types
         .pc_iu_sg_2(pc_iu_sg_2),		// in std_ulogic;
         .clkoff_b(clkoff_b),		// in  std_ulogic; todo
         .act_dis(act_dis),		// in  std_ulogic; todo
         .tc_ac_ccflush_dc(tc_ac_ccflush_dc),		// in  std_ulogic; todo
         .d_mode(d_mode),		// in std_ulogic;
         .delay_lclkr(delay_lclkr),		// in std_ulogic;
         .mpw1_b(mpw1_b),		// in std_ulogic;
         .mpw2_b(mpw2_b),		// in std_ulogic;
         .func_scan_in(func_scan_in[1]),		// in std_ulogic;  todo: hookup
         .func_scan_out(func_scan_out[1]),		// out std_ulogic;

         .iu_au_iu5_i0_vld(fdec_frn_iu5_i0_vld),
         .iu_au_iu5_i0_ucode(fdec_frn_iu5_i0_ucode),
         .iu_au_iu5_i0_rte_lq(fdec_frn_iu5_i0_rte_lq),
         .iu_au_iu5_i0_rte_sq(fdec_frn_iu5_i0_rte_sq),
         .iu_au_iu5_i0_rte_fx0(fdec_frn_iu5_i0_rte_fx0),
         .iu_au_iu5_i0_rte_fx1(fdec_frn_iu5_i0_rte_fx1),
         .iu_au_iu5_i0_rte_axu0(fdec_frn_iu5_i0_rte_axu0),
         .iu_au_iu5_i0_rte_axu1(fdec_frn_iu5_i0_rte_axu1),
         .iu_au_iu5_i0_ord(fdec_frn_iu5_i0_ord),
         .iu_au_iu5_i0_cord(fdec_frn_iu5_i0_cord),
         .iu_au_iu5_i0_instr(fdec_frn_iu5_i0_instr),
         .iu_au_iu5_i0_ifar(fdec_frn_iu5_i0_ifar),
         .iu_au_iu5_i0_gshare(fdec_frn_iu5_i0_gshare[0:9]),
         .iu_au_iu5_i0_ilat(fdec_frn_iu5_i0_ilat),
         .iu_au_iu5_i0_isload(fdec_frn_iu5_i0_isload),
         .iu_au_iu5_i0_t1_v(fdec_frn_iu5_i0_t1_v),
         .iu_au_iu5_i0_t1_t(fdec_frn_iu5_i0_t1_t),
         .iu_au_iu5_i0_t1_a(fdec_frn_iu5_i0_t1_a),
         .iu_au_iu5_i0_t2_v(fdec_frn_iu5_i0_t2_v),
         .iu_au_iu5_i0_t2_t(fdec_frn_iu5_i0_t2_t),
         .iu_au_iu5_i0_t2_a(fdec_frn_iu5_i0_t2_a),
         .iu_au_iu5_i0_t3_v(fdec_frn_iu5_i0_t3_v),
         .iu_au_iu5_i0_t3_t(fdec_frn_iu5_i0_t3_t),
         .iu_au_iu5_i0_t3_a(fdec_frn_iu5_i0_t3_a),
         .iu_au_iu5_i0_s1_v(fdec_frn_iu5_i0_s1_v),
         .iu_au_iu5_i0_s1_t(fdec_frn_iu5_i0_s1_t),
         .iu_au_iu5_i0_s1_a(fdec_frn_iu5_i0_s1_a),
         .iu_au_iu5_i0_s2_v(fdec_frn_iu5_i0_s2_v),
         .iu_au_iu5_i0_s2_t(fdec_frn_iu5_i0_s2_t),
         .iu_au_iu5_i0_s2_a(fdec_frn_iu5_i0_s2_a),
         .iu_au_iu5_i0_s3_v(fdec_frn_iu5_i0_s3_v),
         .iu_au_iu5_i0_s3_t(fdec_frn_iu5_i0_s3_t),
         .iu_au_iu5_i0_s3_a(fdec_frn_iu5_i0_s3_a),
         .iu_au_iu5_i1_vld(fdec_frn_iu5_i1_vld),
         .iu_au_iu5_i1_ucode(fdec_frn_iu5_i1_ucode),
         .iu_au_iu5_i1_rte_lq(fdec_frn_iu5_i1_rte_lq),
         .iu_au_iu5_i1_rte_sq(fdec_frn_iu5_i1_rte_sq),
         .iu_au_iu5_i1_rte_fx0(fdec_frn_iu5_i1_rte_fx0),
         .iu_au_iu5_i1_rte_fx1(fdec_frn_iu5_i1_rte_fx1),
         .iu_au_iu5_i1_rte_axu0(fdec_frn_iu5_i1_rte_axu0),
         .iu_au_iu5_i1_rte_axu1(fdec_frn_iu5_i1_rte_axu1),
         .iu_au_iu5_i1_ord(fdec_frn_iu5_i1_ord),
         .iu_au_iu5_i1_cord(fdec_frn_iu5_i1_cord),
         .iu_au_iu5_i1_instr(fdec_frn_iu5_i1_instr),
         .iu_au_iu5_i1_ifar(fdec_frn_iu5_i1_ifar),
         .iu_au_iu5_i1_gshare(fdec_frn_iu5_i1_gshare[0:9]),
         .iu_au_iu5_i1_ilat(fdec_frn_iu5_i1_ilat),
         .iu_au_iu5_i1_isload(fdec_frn_iu5_i1_isload),
         .iu_au_iu5_i1_t1_v(fdec_frn_iu5_i1_t1_v),
         .iu_au_iu5_i1_t1_t(fdec_frn_iu5_i1_t1_t),
         .iu_au_iu5_i1_t1_a(fdec_frn_iu5_i1_t1_a),
         .iu_au_iu5_i1_t2_v(fdec_frn_iu5_i1_t2_v),
         .iu_au_iu5_i1_t2_t(fdec_frn_iu5_i1_t2_t),
         .iu_au_iu5_i1_t2_a(fdec_frn_iu5_i1_t2_a),
         .iu_au_iu5_i1_t3_v(fdec_frn_iu5_i1_t3_v),
         .iu_au_iu5_i1_t3_t(fdec_frn_iu5_i1_t3_t),
         .iu_au_iu5_i1_t3_a(fdec_frn_iu5_i1_t3_a),
         .iu_au_iu5_i1_s1_v(fdec_frn_iu5_i1_s1_v),
         .iu_au_iu5_i1_s1_t(fdec_frn_iu5_i1_s1_t),
         .iu_au_iu5_i1_s1_a(fdec_frn_iu5_i1_s1_a),
         .iu_au_iu5_i1_s2_v(fdec_frn_iu5_i1_s2_v),
         .iu_au_iu5_i1_s2_t(fdec_frn_iu5_i1_s2_t),
         .iu_au_iu5_i1_s2_a(fdec_frn_iu5_i1_s2_a),
         .iu_au_iu5_i1_s3_v(fdec_frn_iu5_i1_s3_v),
         .iu_au_iu5_i1_s3_t(fdec_frn_iu5_i1_s3_t),
         .iu_au_iu5_i1_s3_a(fdec_frn_iu5_i1_s3_a),

         .spr_single_issue(1'b0),		// in std_ulogic;

         .au_iu_iu5_stall(au_iu_iu5_stall),		// out std_ulogic;

         .cp_rn_i0_axu_exception_val(cp_rn_i0_axu_exception_val),
         .cp_rn_i0_axu_exception(cp_rn_i0_axu_exception),
         .cp_rn_i0_itag(cp_rn_i0_itag),
         .cp_rn_i0_t1_v(cp_rn_i0_t1_v),		// in std_ulogic;
         .cp_rn_i0_t1_t(cp_rn_i0_t1_t),		// in std_ulogic;
         .cp_rn_i0_t1_p(cp_rn_i0_t1_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i0_t1_a(cp_rn_i0_t1_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i0_t2_v(cp_rn_i0_t2_v),		// in std_ulogic;
         .cp_rn_i0_t2_t(cp_rn_i0_t2_t),		// in std_ulogic_vector(0 to 2);
         .cp_rn_i0_t2_p(cp_rn_i0_t2_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i0_t2_a(cp_rn_i0_t2_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i0_t3_v(cp_rn_i0_t3_v),		// in std_ulogic;
         .cp_rn_i0_t3_t(cp_rn_i0_t3_t),		// in std_ulogic_vector(0 to 2);
         .cp_rn_i0_t3_p(cp_rn_i0_t3_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i0_t3_a(cp_rn_i0_t3_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);

         .cp_rn_i1_axu_exception_val(cp_rn_i1_axu_exception_val),
         .cp_rn_i1_axu_exception(cp_rn_i1_axu_exception),
         .cp_rn_i1_itag(cp_rn_i1_itag),
         .cp_rn_i1_t1_v(cp_rn_i1_t1_v),		// in std_ulogic;
         .cp_rn_i1_t1_t(cp_rn_i1_t1_t),		// in std_ulogic;
         .cp_rn_i1_t1_p(cp_rn_i1_t1_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i1_t1_a(cp_rn_i1_t1_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i1_t2_v(cp_rn_i1_t2_v),		// in std_ulogic;
         .cp_rn_i1_t2_t(cp_rn_i1_t2_t),		// in std_ulogic_vector(0 to 2);
         .cp_rn_i1_t2_p(cp_rn_i1_t2_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i1_t2_a(cp_rn_i1_t2_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i1_t3_v(cp_rn_i1_t3_v),		// in std_ulogic;
         .cp_rn_i1_t3_t(cp_rn_i1_t3_t),		// in std_ulogic_vector(0 to 2);
         .cp_rn_i1_t3_p(cp_rn_i1_t3_p),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);
         .cp_rn_i1_t3_a(cp_rn_i1_t3_a),		// in std_ulogic_vector(0 to FPR_POOL_ENC-1);

         .cp_flush(cp_flush),		// in std_ulogic;
         .br_iu_redirect(br_iu_redirect),
         .iu_au_iu5_send_ok(iu_au_iu5_send_ok),
         .iu_au_iu5_next_itag_i0(iu_au_iu5_next_itag_i0),
         .iu_au_iu5_next_itag_i1(iu_au_iu5_next_itag_i1),
         .au_iu_iu5_axu0_send_ok(au_iu_iu5_axu0_send_ok),
         .au_iu_iu5_axu1_send_ok(au_iu_iu5_axu1_send_ok),
         .au_iu_iu5_i0_t1_p(au_iu_iu5_i0_t1_p),
         .au_iu_iu5_i0_t2_p(au_iu_iu5_i0_t2_p),
         .au_iu_iu5_i0_t3_p(au_iu_iu5_i0_t3_p),
         .au_iu_iu5_i0_s1_p(au_iu_iu5_i0_s1_p),
         .au_iu_iu5_i0_s2_p(au_iu_iu5_i0_s2_p),
         .au_iu_iu5_i0_s3_p(au_iu_iu5_i0_s3_p),
         .au_iu_iu5_i0_s1_itag(au_iu_iu5_i0_s1_itag),
         .au_iu_iu5_i0_s2_itag(au_iu_iu5_i0_s2_itag),
         .au_iu_iu5_i0_s3_itag(au_iu_iu5_i0_s3_itag),
         .au_iu_iu5_i1_t1_p(au_iu_iu5_i1_t1_p),
         .au_iu_iu5_i1_t2_p(au_iu_iu5_i1_t2_p),
         .au_iu_iu5_i1_t3_p(au_iu_iu5_i1_t3_p),
         .au_iu_iu5_i1_s1_p(au_iu_iu5_i1_s1_p),
         .au_iu_iu5_i1_s2_p(au_iu_iu5_i1_s2_p),
         .au_iu_iu5_i1_s3_p(au_iu_iu5_i1_s3_p),
         .au_iu_iu5_i1_s1_dep_hit(au_iu_iu5_i1_s1_dep_hit),
         .au_iu_iu5_i1_s2_dep_hit(au_iu_iu5_i1_s2_dep_hit),
         .au_iu_iu5_i1_s3_dep_hit(au_iu_iu5_i1_s3_dep_hit),
         .au_iu_iu5_i1_s1_itag(au_iu_iu5_i1_s1_itag),
         .au_iu_iu5_i1_s2_itag(au_iu_iu5_i1_s2_itag),
         .au_iu_iu5_i1_s3_itag(au_iu_iu5_i1_s3_itag)
      );

endmodule
