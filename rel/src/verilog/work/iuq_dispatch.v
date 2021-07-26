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
//* NAME: iuq_dispatch.vhdl
//*

`include "tri_a2o.vh"

module iuq_dispatch(
   inout                        vdd,
   inout                        gnd,
   input [0:`NCLK_WIDTH-1]      nclk,
   input                        pc_iu_sg_2,
   input                        pc_iu_func_sl_thold_2,
   input                        pc_iu_func_slp_sl_thold_2,
   input                        clkoff_b,
   input                        act_dis,
   input                        tc_ac_ccflush_dc,
   input                        d_mode,
   input                        delay_lclkr,
   input                        mpw1_b,
   input                        mpw2_b,
   input                        scan_in,
   output                       scan_out,

   //-----------------------------
   // SPR connections
   //-----------------------------
   input [0:`THREADS-1]         spr_cpcr_we,
   input [0:4]                  spr_t0_cpcr2_fx0_cnt,
   input [0:4]                  spr_t0_cpcr2_fx1_cnt,
   input [0:4]                  spr_t0_cpcr2_lq_cnt,
   input [0:4]                  spr_t0_cpcr2_sq_cnt,
   input [0:4]	                 spr_t0_cpcr3_fu0_cnt,
   input [0:4]	                 spr_t0_cpcr3_fu1_cnt,
   input [0:4]                  spr_t0_cpcr4_fx0_cnt,
   input [0:4]                  spr_t0_cpcr4_fx1_cnt,
   input [0:4]                  spr_t0_cpcr4_lq_cnt,
   input [0:4]                  spr_t0_cpcr4_sq_cnt,
   input [0:4]	                 spr_t0_cpcr5_fu0_cnt,
   input [0:4]	                 spr_t0_cpcr5_fu1_cnt,
`ifndef THREADS1
   input [0:4]                  spr_t1_cpcr2_fx0_cnt,
   input [0:4]                  spr_t1_cpcr2_fx1_cnt,
   input [0:4]                  spr_t1_cpcr2_lq_cnt,
   input [0:4]                  spr_t1_cpcr2_sq_cnt,
   input [0:4]	                 spr_t1_cpcr3_fu0_cnt,
   input [0:4]	                 spr_t1_cpcr3_fu1_cnt,
   input [0:4]                  spr_t1_cpcr4_fx0_cnt,
   input [0:4]                  spr_t1_cpcr4_fx1_cnt,
   input [0:4]                  spr_t1_cpcr4_lq_cnt,
   input [0:4]                  spr_t1_cpcr4_sq_cnt,
   input [0:4]	                 spr_t1_cpcr5_fu0_cnt,
   input [0:4]	                 spr_t1_cpcr5_fu1_cnt,
`endif
   input [0:4]                  spr_cpcr0_fx0_cnt,
   input [0:4]                  spr_cpcr0_fx1_cnt,
   input [0:4]  	              spr_cpcr0_lq_cnt,
   input [0:4] 		           spr_cpcr0_sq_cnt,
   input [0:4]	                 spr_cpcr1_fu0_cnt,
   input [0:4]	                 spr_cpcr1_fu1_cnt,

   input [0:`THREADS-1]         spr_high_pri_mask,
   input [0:`THREADS-1]         spr_med_pri_mask,
   input [0:5]                  spr_t0_low_pri_count,
`ifndef THREADS1
   input [0:5]                  spr_t1_low_pri_count,
`endif

   //-------------------------------
   // Performance interface with I$
   //-------------------------------
   input                        pc_iu_event_bus_enable,
   output [0:`THREADS-1]        perf_iu6_stall,
   output [0:`THREADS-1]        perf_iu6_dispatch_fx0,
   output [0:`THREADS-1]        perf_iu6_dispatch_fx1,
   output [0:`THREADS-1]        perf_iu6_dispatch_lq,
   output [0:`THREADS-1]        perf_iu6_dispatch_axu0,
   output [0:`THREADS-1]        perf_iu6_dispatch_axu1,
   output [0:`THREADS-1]        perf_iu6_fx0_credit_stall,
   output [0:`THREADS-1]        perf_iu6_fx1_credit_stall,
   output [0:`THREADS-1]        perf_iu6_lq_credit_stall,
   output [0:`THREADS-1]        perf_iu6_sq_credit_stall,
   output [0:`THREADS-1]        perf_iu6_axu0_credit_stall,
   output [0:`THREADS-1]        perf_iu6_axu1_credit_stall,


   //----------------------------
   // SCOM signals
   //----------------------------
   output [0:`THREADS-1]        iu_pc_fx0_credit_ok,
   output [0:`THREADS-1]        iu_pc_fx1_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu0_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu1_credit_ok,
   output [0:`THREADS-1]        iu_pc_lq_credit_ok,
   output [0:`THREADS-1]        iu_pc_sq_credit_ok,


   //----------------------------
   // Credit Interface with IU
   //----------------------------
   input [0:`THREADS-1]         rv_iu_fx0_credit_free,
   input [0:`THREADS-1]         rv_iu_fx1_credit_free,		// Need to add 2nd unit someday
   input [0:`THREADS-1]         lq_iu_credit_free,
   input [0:`THREADS-1]         sq_iu_credit_free,
   input [0:`THREADS-1]         axu0_iu_credit_free,		// credit free from axu reservation station
   input [0:`THREADS-1]         axu1_iu_credit_free,		// credit free from axu reservation station

   input [0:`THREADS-1]         cp_flush,
   input [0:`THREADS-1]         xu_iu_run_thread,
   output			iu_xu_credits_returned,

   //----------------------------------------------------------------
   // Interface with rename
   //----------------------------------------------------------------
   input                        frn_fdis_iu6_t0_i0_vld,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i0_itag,
   input [0:2]                  frn_fdis_iu6_t0_i0_ucode,
   input [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t0_i0_ucode_cnt,
   input                        frn_fdis_iu6_t0_i0_2ucode,
   input                        frn_fdis_iu6_t0_i0_fuse_nop,
   input                        frn_fdis_iu6_t0_i0_rte_lq,
   input                        frn_fdis_iu6_t0_i0_rte_sq,
   input                        frn_fdis_iu6_t0_i0_rte_fx0,
   input                        frn_fdis_iu6_t0_i0_rte_fx1,
   input                        frn_fdis_iu6_t0_i0_rte_axu0,
   input                        frn_fdis_iu6_t0_i0_rte_axu1,
   input                        frn_fdis_iu6_t0_i0_valop,
   input                        frn_fdis_iu6_t0_i0_ord,
   input                        frn_fdis_iu6_t0_i0_cord,
   input [0:2]                  frn_fdis_iu6_t0_i0_error,
   input                        frn_fdis_iu6_t0_i0_btb_entry,
   input [0:1]                  frn_fdis_iu6_t0_i0_btb_hist,
   input                        frn_fdis_iu6_t0_i0_bta_val,
   input [0:19]                 frn_fdis_iu6_t0_i0_fusion,
   input                        frn_fdis_iu6_t0_i0_spec,
   input                        frn_fdis_iu6_t0_i0_type_fp,
   input                        frn_fdis_iu6_t0_i0_type_ap,
   input                        frn_fdis_iu6_t0_i0_type_spv,
   input                        frn_fdis_iu6_t0_i0_type_st,
   input                        frn_fdis_iu6_t0_i0_async_block,
   input                        frn_fdis_iu6_t0_i0_np1_flush,
   input                        frn_fdis_iu6_t0_i0_core_block,
   input                        frn_fdis_iu6_t0_i0_isram,
   input                        frn_fdis_iu6_t0_i0_isload,
   input                        frn_fdis_iu6_t0_i0_isstore,
   input [0:31]                 frn_fdis_iu6_t0_i0_instr,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i0_ifar,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i0_bta,
   input                        frn_fdis_iu6_t0_i0_br_pred,
   input                        frn_fdis_iu6_t0_i0_bh_update,
   input [0:1]                  frn_fdis_iu6_t0_i0_bh0_hist,
   input [0:1]                  frn_fdis_iu6_t0_i0_bh1_hist,
   input [0:1]                  frn_fdis_iu6_t0_i0_bh2_hist,
   input [0:17]                  frn_fdis_iu6_t0_i0_gshare,
   input [0:2]                  frn_fdis_iu6_t0_i0_ls_ptr,
   input                        frn_fdis_iu6_t0_i0_match,
   input [0:3]                  frn_fdis_iu6_t0_i0_ilat,
   input                        frn_fdis_iu6_t0_i0_t1_v,
   input [0:2]                  frn_fdis_iu6_t0_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t1_p,
   input                        frn_fdis_iu6_t0_i0_t2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t2_p,
   input [0:2]                  frn_fdis_iu6_t0_i0_t2_t,
   input                        frn_fdis_iu6_t0_i0_t3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_t3_p,
   input [0:2]                  frn_fdis_iu6_t0_i0_t3_t,
   input                        frn_fdis_iu6_t0_i0_s1_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s1_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i0_s1_itag,
   input [0:2]                  frn_fdis_iu6_t0_i0_s1_t,
   input                        frn_fdis_iu6_t0_i0_s2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s2_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i0_s2_itag,
   input [0:2]                  frn_fdis_iu6_t0_i0_s2_t,
   input                        frn_fdis_iu6_t0_i0_s3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i0_s3_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i0_s3_itag,
   input [0:2]                  frn_fdis_iu6_t0_i0_s3_t,

   input                        frn_fdis_iu6_t0_i1_vld,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i1_itag,
   input [0:2]                  frn_fdis_iu6_t0_i1_ucode,
   input [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t0_i1_ucode_cnt,
   input                        frn_fdis_iu6_t0_i1_fuse_nop,
   input                        frn_fdis_iu6_t0_i1_rte_lq,
   input                        frn_fdis_iu6_t0_i1_rte_sq,
   input                        frn_fdis_iu6_t0_i1_rte_fx0,
   input                        frn_fdis_iu6_t0_i1_rte_fx1,
   input                        frn_fdis_iu6_t0_i1_rte_axu0,
   input                        frn_fdis_iu6_t0_i1_rte_axu1,
   input                        frn_fdis_iu6_t0_i1_valop,
   input                        frn_fdis_iu6_t0_i1_ord,
   input                        frn_fdis_iu6_t0_i1_cord,
   input [0:2]                  frn_fdis_iu6_t0_i1_error,
   input                        frn_fdis_iu6_t0_i1_btb_entry,
   input [0:1]                  frn_fdis_iu6_t0_i1_btb_hist,
   input                        frn_fdis_iu6_t0_i1_bta_val,
   input [0:19]                 frn_fdis_iu6_t0_i1_fusion,
   input                        frn_fdis_iu6_t0_i1_spec,
   input                        frn_fdis_iu6_t0_i1_type_fp,
   input                        frn_fdis_iu6_t0_i1_type_ap,
   input                        frn_fdis_iu6_t0_i1_type_spv,
   input                        frn_fdis_iu6_t0_i1_type_st,
   input                        frn_fdis_iu6_t0_i1_async_block,
   input                        frn_fdis_iu6_t0_i1_np1_flush,
   input                        frn_fdis_iu6_t0_i1_core_block,
   input                        frn_fdis_iu6_t0_i1_isram,
   input                        frn_fdis_iu6_t0_i1_isload,
   input                        frn_fdis_iu6_t0_i1_isstore,
   input [0:31]                 frn_fdis_iu6_t0_i1_instr,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i1_ifar,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i1_bta,
   input                        frn_fdis_iu6_t0_i1_br_pred,
   input                        frn_fdis_iu6_t0_i1_bh_update,
   input [0:1]                  frn_fdis_iu6_t0_i1_bh0_hist,
   input [0:1]                  frn_fdis_iu6_t0_i1_bh1_hist,
   input [0:1]                  frn_fdis_iu6_t0_i1_bh2_hist,
   input [0:17]                  frn_fdis_iu6_t0_i1_gshare,
   input [0:2]                  frn_fdis_iu6_t0_i1_ls_ptr,
   input                        frn_fdis_iu6_t0_i1_match,
   input [0:3]                  frn_fdis_iu6_t0_i1_ilat,
   input                        frn_fdis_iu6_t0_i1_t1_v,
   input [0:2]                  frn_fdis_iu6_t0_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t1_p,
   input                        frn_fdis_iu6_t0_i1_t2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t2_p,
   input [0:2]                  frn_fdis_iu6_t0_i1_t2_t,
   input                        frn_fdis_iu6_t0_i1_t3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_t3_p,
   input [0:2]                  frn_fdis_iu6_t0_i1_t3_t,
   input                        frn_fdis_iu6_t0_i1_s1_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s1_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i1_s1_itag,
   input [0:2]                  frn_fdis_iu6_t0_i1_s1_t,
   input                        frn_fdis_iu6_t0_i1_s1_dep_hit,
   input                        frn_fdis_iu6_t0_i1_s2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s2_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i1_s2_itag,
   input [0:2]                  frn_fdis_iu6_t0_i1_s2_t,
   input                        frn_fdis_iu6_t0_i1_s2_dep_hit,
   input                        frn_fdis_iu6_t0_i1_s3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t0_i1_s3_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t0_i1_s3_itag,
   input [0:2]                  frn_fdis_iu6_t0_i1_s3_t,
   input                        frn_fdis_iu6_t0_i1_s3_dep_hit,

`ifndef THREADS1
   //----------------------------------------------------------------
   // Interface with rename
   //----------------------------------------------------------------
   input                        frn_fdis_iu6_t1_i0_vld,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i0_itag,
   input [0:2]  		frn_fdis_iu6_t1_i0_ucode,
   input [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t1_i0_ucode_cnt,
   input                        frn_fdis_iu6_t1_i0_2ucode,
   input                        frn_fdis_iu6_t1_i0_fuse_nop,
   input                        frn_fdis_iu6_t1_i0_rte_lq,
   input                        frn_fdis_iu6_t1_i0_rte_sq,
   input                        frn_fdis_iu6_t1_i0_rte_fx0,
   input                        frn_fdis_iu6_t1_i0_rte_fx1,
   input                        frn_fdis_iu6_t1_i0_rte_axu0,
   input                        frn_fdis_iu6_t1_i0_rte_axu1,
   input                        frn_fdis_iu6_t1_i0_valop,
   input                        frn_fdis_iu6_t1_i0_ord,
   input                        frn_fdis_iu6_t1_i0_cord,
   input [0:2]                  frn_fdis_iu6_t1_i0_error,
   input                        frn_fdis_iu6_t1_i0_btb_entry,
   input [0:1]                  frn_fdis_iu6_t1_i0_btb_hist,
   input                        frn_fdis_iu6_t1_i0_bta_val,
   input [0:19]                 frn_fdis_iu6_t1_i0_fusion,
   input                        frn_fdis_iu6_t1_i0_spec,
   input                        frn_fdis_iu6_t1_i0_type_fp,
   input                        frn_fdis_iu6_t1_i0_type_ap,
   input                        frn_fdis_iu6_t1_i0_type_spv,
   input                        frn_fdis_iu6_t1_i0_type_st,
   input                        frn_fdis_iu6_t1_i0_async_block,
   input                        frn_fdis_iu6_t1_i0_np1_flush,
   input                        frn_fdis_iu6_t1_i0_core_block,
   input                        frn_fdis_iu6_t1_i0_isram,
   input                        frn_fdis_iu6_t1_i0_isload,
   input                        frn_fdis_iu6_t1_i0_isstore,
   input [0:31]                 frn_fdis_iu6_t1_i0_instr,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i0_ifar,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i0_bta,
   input                        frn_fdis_iu6_t1_i0_br_pred,
   input                        frn_fdis_iu6_t1_i0_bh_update,
   input [0:1]                  frn_fdis_iu6_t1_i0_bh0_hist,
   input [0:1]                  frn_fdis_iu6_t1_i0_bh1_hist,
   input [0:1]                  frn_fdis_iu6_t1_i0_bh2_hist,
   input [0:17]                  frn_fdis_iu6_t1_i0_gshare,
   input [0:2]                  frn_fdis_iu6_t1_i0_ls_ptr,
   input                        frn_fdis_iu6_t1_i0_match,
   input [0:3]                  frn_fdis_iu6_t1_i0_ilat,
   input                        frn_fdis_iu6_t1_i0_t1_v,
   input [0:2]                  frn_fdis_iu6_t1_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t1_p,
   input                        frn_fdis_iu6_t1_i0_t2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t2_p,
   input [0:2]                  frn_fdis_iu6_t1_i0_t2_t,
   input                        frn_fdis_iu6_t1_i0_t3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_t3_p,
   input [0:2]                  frn_fdis_iu6_t1_i0_t3_t,
   input                        frn_fdis_iu6_t1_i0_s1_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s1_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i0_s1_itag,
   input [0:2]                  frn_fdis_iu6_t1_i0_s1_t,
   input                        frn_fdis_iu6_t1_i0_s2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s2_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i0_s2_itag,
   input [0:2]                  frn_fdis_iu6_t1_i0_s2_t,
   input                        frn_fdis_iu6_t1_i0_s3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i0_s3_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i0_s3_itag,
   input [0:2]                  frn_fdis_iu6_t1_i0_s3_t,

   input                        frn_fdis_iu6_t1_i1_vld,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i1_itag,
   input [0:2]                  frn_fdis_iu6_t1_i1_ucode,
   input [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t1_i1_ucode_cnt,
   input                        frn_fdis_iu6_t1_i1_fuse_nop,
   input                        frn_fdis_iu6_t1_i1_rte_lq,
   input                        frn_fdis_iu6_t1_i1_rte_sq,
   input                        frn_fdis_iu6_t1_i1_rte_fx0,
   input                        frn_fdis_iu6_t1_i1_rte_fx1,
   input                        frn_fdis_iu6_t1_i1_rte_axu0,
   input                        frn_fdis_iu6_t1_i1_rte_axu1,
   input                        frn_fdis_iu6_t1_i1_valop,
   input                        frn_fdis_iu6_t1_i1_ord,
   input                        frn_fdis_iu6_t1_i1_cord,
   input [0:2]                  frn_fdis_iu6_t1_i1_error,
   input                        frn_fdis_iu6_t1_i1_btb_entry,
   input [0:1]                  frn_fdis_iu6_t1_i1_btb_hist,
   input                        frn_fdis_iu6_t1_i1_bta_val,
   input [0:19]                 frn_fdis_iu6_t1_i1_fusion,
   input                        frn_fdis_iu6_t1_i1_spec,
   input                        frn_fdis_iu6_t1_i1_type_fp,
   input                        frn_fdis_iu6_t1_i1_type_ap,
   input                        frn_fdis_iu6_t1_i1_type_spv,
   input                        frn_fdis_iu6_t1_i1_type_st,
   input                        frn_fdis_iu6_t1_i1_async_block,
   input                        frn_fdis_iu6_t1_i1_np1_flush,
   input                        frn_fdis_iu6_t1_i1_core_block,
   input                        frn_fdis_iu6_t1_i1_isram,
   input                        frn_fdis_iu6_t1_i1_isload,
   input                        frn_fdis_iu6_t1_i1_isstore,
   input [0:31]                 frn_fdis_iu6_t1_i1_instr,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i1_ifar,
   input [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i1_bta,
   input                        frn_fdis_iu6_t1_i1_br_pred,
   input                        frn_fdis_iu6_t1_i1_bh_update,
   input [0:1]                  frn_fdis_iu6_t1_i1_bh0_hist,
   input [0:1]                  frn_fdis_iu6_t1_i1_bh1_hist,
   input [0:1]                  frn_fdis_iu6_t1_i1_bh2_hist,
   input [0:17]                  frn_fdis_iu6_t1_i1_gshare,
   input [0:2]                  frn_fdis_iu6_t1_i1_ls_ptr,
   input                        frn_fdis_iu6_t1_i1_match,
   input [0:3]                  frn_fdis_iu6_t1_i1_ilat,
   input                        frn_fdis_iu6_t1_i1_t1_v,
   input [0:2]                  frn_fdis_iu6_t1_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t1_p,
   input                        frn_fdis_iu6_t1_i1_t2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t2_p,
   input [0:2]                  frn_fdis_iu6_t1_i1_t2_t,
   input                        frn_fdis_iu6_t1_i1_t3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_t3_p,
   input [0:2]                  frn_fdis_iu6_t1_i1_t3_t,
   input                        frn_fdis_iu6_t1_i1_s1_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s1_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s1_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i1_s1_itag,
   input [0:2]                  frn_fdis_iu6_t1_i1_s1_t,
   input                        frn_fdis_iu6_t1_i1_s1_dep_hit,
   input                        frn_fdis_iu6_t1_i1_s2_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s2_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s2_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i1_s2_itag,
   input [0:2]                  frn_fdis_iu6_t1_i1_s2_t,
   input                        frn_fdis_iu6_t1_i1_s2_dep_hit,
   input                        frn_fdis_iu6_t1_i1_s3_v,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s3_a,
   input [0:`GPR_POOL_ENC-1]    frn_fdis_iu6_t1_i1_s3_p,
   input [0:`ITAG_SIZE_ENC-1]   frn_fdis_iu6_t1_i1_s3_itag,
   input [0:2]                  frn_fdis_iu6_t1_i1_s3_t,
   input                        frn_fdis_iu6_t1_i1_s3_dep_hit,
`endif

   // Input to dispatch to block due to ivax
   input [0:`THREADS-1]         cp_dis_ivax,

   //-----------------------------
   // Stall from MMU
   //-----------------------------
   input [0:`THREADS-1]         mm_iu_flush_req,
   output [0:`THREADS-1]        dp_cp_hold_req,
   input [0:`THREADS-1]         mm_iu_hold_done,
   input [0:`THREADS-1]         mm_iu_bus_snoop_hold_req,
   output [0:`THREADS-1]        dp_cp_bus_snoop_hold_req,
   input [0:`THREADS-1]         mm_iu_bus_snoop_hold_done,
   input [0:`THREADS-1]         mm_iu_tlbi_complete,

   //-----------------------------
   // Stall from dispatch
   //-----------------------------
   output [0:`THREADS-1]        fdis_frn_iu6_stall,

   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output                       iu_rv_iu6_t0_i0_vld,
   output                       iu_rv_iu6_t0_i0_act,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i0_itag,
   output [0:2]                 iu_rv_iu6_t0_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t0_i0_ucode_cnt,
   output                       iu_rv_iu6_t0_i0_2ucode,
   output                       iu_rv_iu6_t0_i0_fuse_nop,
   output                       iu_rv_iu6_t0_i0_rte_lq,
   output                       iu_rv_iu6_t0_i0_rte_sq,
   output                       iu_rv_iu6_t0_i0_rte_fx0,
   output                       iu_rv_iu6_t0_i0_rte_fx1,
   output                       iu_rv_iu6_t0_i0_rte_axu0,
   output                       iu_rv_iu6_t0_i0_rte_axu1,
   output                       iu_rv_iu6_t0_i0_valop,
   output                       iu_rv_iu6_t0_i0_ord,
   output                       iu_rv_iu6_t0_i0_cord,
   output [0:2]                 iu_rv_iu6_t0_i0_error,
   output                       iu_rv_iu6_t0_i0_btb_entry,
   output [0:1]                 iu_rv_iu6_t0_i0_btb_hist,
   output                       iu_rv_iu6_t0_i0_bta_val,
   output [0:19]                iu_rv_iu6_t0_i0_fusion,
   output                       iu_rv_iu6_t0_i0_spec,
   output                       iu_rv_iu6_t0_i0_type_fp,
   output                       iu_rv_iu6_t0_i0_type_ap,
   output                       iu_rv_iu6_t0_i0_type_spv,
   output                       iu_rv_iu6_t0_i0_type_st,
   output                       iu_rv_iu6_t0_i0_async_block,
   output                       iu_rv_iu6_t0_i0_np1_flush,
   output                       iu_rv_iu6_t0_i0_isram,
   output                       iu_rv_iu6_t0_i0_isload,
   output                       iu_rv_iu6_t0_i0_isstore,
   output [0:31]                iu_rv_iu6_t0_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t0_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t0_i0_bta,
   output                       iu_rv_iu6_t0_i0_br_pred,
   output                       iu_rv_iu6_t0_i0_bh_update,
   output [0:1]                 iu_rv_iu6_t0_i0_bh0_hist,
   output [0:1]                 iu_rv_iu6_t0_i0_bh1_hist,
   output [0:1]                 iu_rv_iu6_t0_i0_bh2_hist,
   output [0:17]                 iu_rv_iu6_t0_i0_gshare,
   output [0:2]                 iu_rv_iu6_t0_i0_ls_ptr,
   output                       iu_rv_iu6_t0_i0_match,
   output [0:3]                 iu_rv_iu6_t0_i0_ilat,
   output                       iu_rv_iu6_t0_i0_t1_v,
   output [0:2]                 iu_rv_iu6_t0_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t1_p,
   output                       iu_rv_iu6_t0_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t2_p,
   output [0:2]                 iu_rv_iu6_t0_i0_t2_t,
   output                       iu_rv_iu6_t0_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_t3_p,
   output [0:2]                 iu_rv_iu6_t0_i0_t3_t,
   output                       iu_rv_iu6_t0_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s1_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i0_s1_itag,
   output [0:2]                 iu_rv_iu6_t0_i0_s1_t,
   output                       iu_rv_iu6_t0_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s2_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i0_s2_itag,
   output [0:2]                 iu_rv_iu6_t0_i0_s2_t,
   output                       iu_rv_iu6_t0_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i0_s3_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i0_s3_itag,
   output [0:2]                 iu_rv_iu6_t0_i0_s3_t,

   output                       iu_rv_iu6_t0_i1_vld,
   output                       iu_rv_iu6_t0_i1_act,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i1_itag,
   output [0:2]                 iu_rv_iu6_t0_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t0_i1_ucode_cnt,
   output                       iu_rv_iu6_t0_i1_fuse_nop,
   output                       iu_rv_iu6_t0_i1_rte_lq,
   output                       iu_rv_iu6_t0_i1_rte_sq,
   output                       iu_rv_iu6_t0_i1_rte_fx0,
   output                       iu_rv_iu6_t0_i1_rte_fx1,
   output                       iu_rv_iu6_t0_i1_rte_axu0,
   output                       iu_rv_iu6_t0_i1_rte_axu1,
   output                       iu_rv_iu6_t0_i1_valop,
   output                       iu_rv_iu6_t0_i1_ord,
   output                       iu_rv_iu6_t0_i1_cord,
   output [0:2]                 iu_rv_iu6_t0_i1_error,
   output                       iu_rv_iu6_t0_i1_btb_entry,
   output [0:1]                 iu_rv_iu6_t0_i1_btb_hist,
   output                       iu_rv_iu6_t0_i1_bta_val,
   output [0:19]                iu_rv_iu6_t0_i1_fusion,
   output                       iu_rv_iu6_t0_i1_spec,
   output                       iu_rv_iu6_t0_i1_type_fp,
   output                       iu_rv_iu6_t0_i1_type_ap,
   output                       iu_rv_iu6_t0_i1_type_spv,
   output                       iu_rv_iu6_t0_i1_type_st,
   output                       iu_rv_iu6_t0_i1_async_block,
   output                       iu_rv_iu6_t0_i1_np1_flush,
   output                       iu_rv_iu6_t0_i1_isram,
   output                       iu_rv_iu6_t0_i1_isload,
   output                       iu_rv_iu6_t0_i1_isstore,
   output [0:31]                iu_rv_iu6_t0_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t0_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t0_i1_bta,
   output                       iu_rv_iu6_t0_i1_br_pred,
   output                       iu_rv_iu6_t0_i1_bh_update,
   output [0:1]                 iu_rv_iu6_t0_i1_bh0_hist,
   output [0:1]                 iu_rv_iu6_t0_i1_bh1_hist,
   output [0:1]                 iu_rv_iu6_t0_i1_bh2_hist,
   output [0:17]                 iu_rv_iu6_t0_i1_gshare,
   output [0:2]                 iu_rv_iu6_t0_i1_ls_ptr,
   output                       iu_rv_iu6_t0_i1_match,
   output [0:3]                 iu_rv_iu6_t0_i1_ilat,
   output                       iu_rv_iu6_t0_i1_t1_v,
   output [0:2]                 iu_rv_iu6_t0_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t1_p,
   output                       iu_rv_iu6_t0_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t2_p,
   output [0:2]                 iu_rv_iu6_t0_i1_t2_t,
   output                       iu_rv_iu6_t0_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_t3_p,
   output [0:2]                 iu_rv_iu6_t0_i1_t3_t,
   output                       iu_rv_iu6_t0_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s1_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i1_s1_itag,
   output [0:2]                 iu_rv_iu6_t0_i1_s1_t,
   output                       iu_rv_iu6_t0_i1_s1_dep_hit,
   output                       iu_rv_iu6_t0_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s2_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i1_s2_itag,
   output [0:2]                 iu_rv_iu6_t0_i1_s2_t,
   output                       iu_rv_iu6_t0_i1_s2_dep_hit,
   output                       iu_rv_iu6_t0_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t0_i1_s3_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t0_i1_s3_itag,
   output [0:2]                 iu_rv_iu6_t0_i1_s3_t,
   output                       iu_rv_iu6_t0_i1_s3_dep_hit,

`ifndef THREADS1
   //----------------------------------------------------------------
   // Interface with rename
   //----------------------------------------------------------------
   output                       iu_rv_iu6_t1_i0_vld,
   output                       iu_rv_iu6_t1_i0_act,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i0_itag,
   output [0:2]  		iu_rv_iu6_t1_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t1_i0_ucode_cnt,
   output                       iu_rv_iu6_t1_i0_2ucode,
   output                       iu_rv_iu6_t1_i0_fuse_nop,
   output                       iu_rv_iu6_t1_i0_rte_lq,
   output                       iu_rv_iu6_t1_i0_rte_sq,
   output                       iu_rv_iu6_t1_i0_rte_fx0,
   output                       iu_rv_iu6_t1_i0_rte_fx1,
   output                       iu_rv_iu6_t1_i0_rte_axu0,
   output                       iu_rv_iu6_t1_i0_rte_axu1,
   output                       iu_rv_iu6_t1_i0_valop,
   output                       iu_rv_iu6_t1_i0_ord,
   output                       iu_rv_iu6_t1_i0_cord,
   output [0:2]                 iu_rv_iu6_t1_i0_error,
   output                       iu_rv_iu6_t1_i0_btb_entry,
   output [0:1]                 iu_rv_iu6_t1_i0_btb_hist,
   output                       iu_rv_iu6_t1_i0_bta_val,
   output [0:19]                iu_rv_iu6_t1_i0_fusion,
   output                       iu_rv_iu6_t1_i0_spec,
   output                       iu_rv_iu6_t1_i0_type_fp,
   output                       iu_rv_iu6_t1_i0_type_ap,
   output                       iu_rv_iu6_t1_i0_type_spv,
   output                       iu_rv_iu6_t1_i0_type_st,
   output                       iu_rv_iu6_t1_i0_async_block,
   output                       iu_rv_iu6_t1_i0_np1_flush,
   output                       iu_rv_iu6_t1_i0_isram,
   output                       iu_rv_iu6_t1_i0_isload,
   output                       iu_rv_iu6_t1_i0_isstore,
   output [0:31]                iu_rv_iu6_t1_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t1_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t1_i0_bta,
   output                       iu_rv_iu6_t1_i0_br_pred,
   output                       iu_rv_iu6_t1_i0_bh_update,
   output [0:1]                 iu_rv_iu6_t1_i0_bh0_hist,
   output [0:1]                 iu_rv_iu6_t1_i0_bh1_hist,
   output [0:1]                 iu_rv_iu6_t1_i0_bh2_hist,
   output [0:17]                 iu_rv_iu6_t1_i0_gshare,
   output [0:2]                 iu_rv_iu6_t1_i0_ls_ptr,
   output                       iu_rv_iu6_t1_i0_match,
   output [0:3]                 iu_rv_iu6_t1_i0_ilat,
   output                       iu_rv_iu6_t1_i0_t1_v,
   output [0:2]                 iu_rv_iu6_t1_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t1_p,
   output                       iu_rv_iu6_t1_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t2_p,
   output [0:2]                 iu_rv_iu6_t1_i0_t2_t,
   output                       iu_rv_iu6_t1_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_t3_p,
   output [0:2]                 iu_rv_iu6_t1_i0_t3_t,
   output                       iu_rv_iu6_t1_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s1_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i0_s1_itag,
   output [0:2]                 iu_rv_iu6_t1_i0_s1_t,
   output                       iu_rv_iu6_t1_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s2_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i0_s2_itag,
   output [0:2]                 iu_rv_iu6_t1_i0_s2_t,
   output                       iu_rv_iu6_t1_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i0_s3_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i0_s3_itag,
   output [0:2]                 iu_rv_iu6_t1_i0_s3_t,

   output                       iu_rv_iu6_t1_i1_vld,
   output                       iu_rv_iu6_t1_i1_act,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i1_itag,
   output [0:2]  		iu_rv_iu6_t1_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t1_i1_ucode_cnt,
   output                       iu_rv_iu6_t1_i1_fuse_nop,
   output                       iu_rv_iu6_t1_i1_rte_lq,
   output                       iu_rv_iu6_t1_i1_rte_sq,
   output                       iu_rv_iu6_t1_i1_rte_fx0,
   output                       iu_rv_iu6_t1_i1_rte_fx1,
   output                       iu_rv_iu6_t1_i1_rte_axu0,
   output                       iu_rv_iu6_t1_i1_rte_axu1,
   output                       iu_rv_iu6_t1_i1_valop,
   output                       iu_rv_iu6_t1_i1_ord,
   output                       iu_rv_iu6_t1_i1_cord,
   output [0:2]                 iu_rv_iu6_t1_i1_error,
   output                       iu_rv_iu6_t1_i1_btb_entry,
   output [0:1]                 iu_rv_iu6_t1_i1_btb_hist,
   output                       iu_rv_iu6_t1_i1_bta_val,
   output [0:19]                iu_rv_iu6_t1_i1_fusion,
   output                       iu_rv_iu6_t1_i1_spec,
   output                       iu_rv_iu6_t1_i1_type_fp,
   output                       iu_rv_iu6_t1_i1_type_ap,
   output                       iu_rv_iu6_t1_i1_type_spv,
   output                       iu_rv_iu6_t1_i1_type_st,
   output                       iu_rv_iu6_t1_i1_async_block,
   output                       iu_rv_iu6_t1_i1_np1_flush,
   output                       iu_rv_iu6_t1_i1_isram,
   output                       iu_rv_iu6_t1_i1_isload,
   output                       iu_rv_iu6_t1_i1_isstore,
   output [0:31]                iu_rv_iu6_t1_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t1_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61] iu_rv_iu6_t1_i1_bta,
   output                       iu_rv_iu6_t1_i1_br_pred,
   output                       iu_rv_iu6_t1_i1_bh_update,
   output [0:1]                 iu_rv_iu6_t1_i1_bh0_hist,
   output [0:1]                 iu_rv_iu6_t1_i1_bh1_hist,
   output [0:1]                 iu_rv_iu6_t1_i1_bh2_hist,
   output [0:17]                 iu_rv_iu6_t1_i1_gshare,
   output [0:2]                 iu_rv_iu6_t1_i1_ls_ptr,
   output                       iu_rv_iu6_t1_i1_match,
   output [0:3]                 iu_rv_iu6_t1_i1_ilat,
   output                       iu_rv_iu6_t1_i1_t1_v,
   output [0:2]                 iu_rv_iu6_t1_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t1_p,
   output                       iu_rv_iu6_t1_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t2_p,
   output [0:2]                 iu_rv_iu6_t1_i1_t2_t,
   output                       iu_rv_iu6_t1_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_t3_p,
   output [0:2]                 iu_rv_iu6_t1_i1_t3_t,
   output                       iu_rv_iu6_t1_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s1_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s1_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i1_s1_itag,
   output [0:2]                 iu_rv_iu6_t1_i1_s1_t,
   output                       iu_rv_iu6_t1_i1_s1_dep_hit,
   output                       iu_rv_iu6_t1_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s2_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s2_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i1_s2_itag,
   output [0:2]                 iu_rv_iu6_t1_i1_s2_t,
   output                       iu_rv_iu6_t1_i1_s2_dep_hit,
   output                       iu_rv_iu6_t1_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s3_a,
   output [0:`GPR_POOL_ENC-1]   iu_rv_iu6_t1_i1_s3_p,
   output [0:`ITAG_SIZE_ENC-1]  iu_rv_iu6_t1_i1_s3_itag,
   output [0:2]                 iu_rv_iu6_t1_i1_s3_t,
   output                       iu_rv_iu6_t1_i1_s3_dep_hit,
`endif
   input [0:`THREADS-1]         spr_cpcr2_we
   );

   localparam [0:31]            value_1 = 32'h00000001;
   localparam [0:31]            value_2 = 32'h00000002;
   localparam [0:31]            value_3 = 32'h00000003;
   localparam [0:31]            value_4 = 32'h00000004;
   parameter                    fx0_high_credit_cnt_offset = 0;
   parameter                    fx1_high_credit_cnt_offset = fx0_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    lq_cmdq_high_credit_cnt_offset = fx1_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    sq_cmdq_high_credit_cnt_offset = lq_cmdq_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    fu0_high_credit_cnt_offset = sq_cmdq_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    fu1_high_credit_cnt_offset = fu0_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    fx0_med_credit_cnt_offset = fu1_high_credit_cnt_offset + 5 * `THREADS;
   parameter                    fx1_med_credit_cnt_offset = fx0_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    lq_cmdq_med_credit_cnt_offset = fx1_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    sq_cmdq_med_credit_cnt_offset = lq_cmdq_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    fu0_med_credit_cnt_offset = sq_cmdq_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    fu1_med_credit_cnt_offset = fu0_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    fx0_total_credit_cnt_offset = fu1_med_credit_cnt_offset + 5 * `THREADS;
   parameter                    fx1_total_credit_cnt_offset = fx0_total_credit_cnt_offset + 5;
   parameter                    lq_cmdq_total_credit_cnt_offset = fx1_total_credit_cnt_offset + 5;
   parameter                    sq_cmdq_total_credit_cnt_offset = lq_cmdq_total_credit_cnt_offset + 5;
   parameter                    fu0_total_credit_cnt_offset = sq_cmdq_total_credit_cnt_offset + 5;
   parameter                    fu1_total_credit_cnt_offset = fu0_total_credit_cnt_offset + 5;
   parameter                    cp_flush_offset = fu1_total_credit_cnt_offset + 5;
   parameter                    xu_iu_run_thread_offset = cp_flush_offset + `THREADS;
   parameter                    iu_xu_credits_returned_offset = xu_iu_run_thread_offset + `THREADS;
   parameter                    dual_issue_use_fx0_offset = iu_xu_credits_returned_offset + 1;
   parameter                    last_thread_offset = dual_issue_use_fx0_offset + 2;
   parameter                    mm_hold_req_offset = last_thread_offset + `THREADS;
   parameter                    mm_hold_done_offset = mm_hold_req_offset + `THREADS;
   parameter                    mm_bus_snoop_hold_req_offset = mm_hold_done_offset + `THREADS;
   parameter                    mm_bus_snoop_hold_done_offset = mm_bus_snoop_hold_req_offset + `THREADS;
   parameter                    hold_instructions_offset = mm_bus_snoop_hold_done_offset + `THREADS;
   parameter                    hold_req_offset = hold_instructions_offset + 1;
   parameter                    hold_done_offset = hold_req_offset + `THREADS;
   parameter                    ivax_hold_req_offset = hold_done_offset + `THREADS;
   parameter                    mm_iu_flush_req_offset = ivax_hold_req_offset + `THREADS;
   parameter                    mm_iu_hold_done_offset = mm_iu_flush_req_offset + `THREADS;
   parameter                    mm_iu_bus_snoop_hold_req_offset = mm_iu_hold_done_offset + `THREADS;
   parameter                    mm_iu_bus_snoop_hold_done_offset = mm_iu_bus_snoop_hold_req_offset + `THREADS;
   parameter                    in_ucode_offset = mm_iu_bus_snoop_hold_done_offset + `THREADS;
   parameter                    in_fusion_offset = in_ucode_offset + `THREADS;
   parameter                    total_pri_mask_offset = in_fusion_offset + `THREADS;
   parameter                    high_pri_mask_offset = total_pri_mask_offset + `THREADS;
   parameter                    med_pri_mask_offset = high_pri_mask_offset + `THREADS;
   parameter                    low_pri_mask_offset = med_pri_mask_offset + `THREADS;
   parameter                    low_pri_cnt_offset = low_pri_mask_offset + `THREADS;
   parameter                    low_pri_max_offset = low_pri_cnt_offset + 8 * `THREADS;
   parameter                    perf_iu6_stall_offset = low_pri_max_offset + (6 * `THREADS);
   parameter                    perf_iu6_dispatch_fx0_offset = perf_iu6_stall_offset + `THREADS;
   parameter                    perf_iu6_dispatch_fx1_offset = perf_iu6_dispatch_fx0_offset + 2*`THREADS;
   parameter                    perf_iu6_dispatch_lq_offset = perf_iu6_dispatch_fx1_offset + 2*`THREADS;
   parameter                    perf_iu6_dispatch_axu0_offset = perf_iu6_dispatch_lq_offset + 2*`THREADS;
   parameter                    perf_iu6_dispatch_axu1_offset = perf_iu6_dispatch_axu0_offset + 2*`THREADS;
   parameter                    perf_iu6_fx0_credit_stall_offset = perf_iu6_dispatch_axu1_offset + 2*`THREADS;
   parameter                    perf_iu6_fx1_credit_stall_offset = perf_iu6_fx0_credit_stall_offset + `THREADS;
   parameter                    perf_iu6_lq_credit_stall_offset = perf_iu6_fx1_credit_stall_offset + `THREADS;
   parameter                    perf_iu6_sq_credit_stall_offset = perf_iu6_lq_credit_stall_offset + `THREADS;
   parameter                    perf_iu6_axu0_credit_stall_offset = perf_iu6_sq_credit_stall_offset + `THREADS;
   parameter                    perf_iu6_axu1_credit_stall_offset = perf_iu6_axu0_credit_stall_offset + `THREADS;
   parameter                    iu_pc_fx0_credit_ok_offset = perf_iu6_axu1_credit_stall_offset + `THREADS;
   parameter                    iu_pc_fx1_credit_ok_offset = iu_pc_fx0_credit_ok_offset + `THREADS;
   parameter                    iu_pc_lq_credit_ok_offset = iu_pc_fx1_credit_ok_offset + `THREADS;
   parameter                    iu_pc_sq_credit_ok_offset = iu_pc_lq_credit_ok_offset + `THREADS;
   parameter                    iu_pc_axu0_credit_ok_offset = iu_pc_sq_credit_ok_offset + `THREADS;
   parameter                    iu_pc_axu1_credit_ok_offset = iu_pc_axu0_credit_ok_offset + `THREADS;
   parameter                    scan_right = iu_pc_axu1_credit_ok_offset + `THREADS - 1;

   // scan
   wire [0:scan_right]          siv;
   wire [0:scan_right]          sov;

   wire                         tiup;

   // MMU hold request
   wire [0:`THREADS-1]           mm_hold_req_d;
   wire [0:`THREADS-1]           mm_hold_req_l2;
   wire [0:`THREADS-1]           mm_hold_done_d;
   wire [0:`THREADS-1]           mm_hold_done_l2;
   wire [0:`THREADS-1]           hold_req_d;
   wire [0:`THREADS-1]           hold_req_l2;
   wire [0:`THREADS-1]           hold_done_d;
   wire [0:`THREADS-1]           hold_done_l2;
   wire [0:`THREADS-1]           mm_bus_snoop_hold_req_d;
   wire [0:`THREADS-1]           mm_bus_snoop_hold_req_l2;
   wire [0:`THREADS-1]           mm_bus_snoop_hold_done_d;
   wire [0:`THREADS-1]           mm_bus_snoop_hold_done_l2;
   wire [0:`THREADS-1]           ivax_hold_req_d;
   wire [0:`THREADS-1]           ivax_hold_req_l2;

   wire [0:`THREADS-1]           mm_iu_flush_req_d;
   wire [0:`THREADS-1]           mm_iu_flush_req_l2;
   wire [0:`THREADS-1]           mm_iu_hold_done_l2;
   wire [0:`THREADS-1]           mm_iu_bus_snoop_hold_req_d;
   wire [0:`THREADS-1]           mm_iu_bus_snoop_hold_req_l2;
   wire [0:`THREADS-1]           mm_iu_bus_snoop_hold_done_l2;
   wire [0:`THREADS-1]           in_ucode_d;
   wire [0:`THREADS-1]           in_ucode_l2;
   wire [0:`THREADS-1]           in_fusion_d;
   wire [0:`THREADS-1]           in_fusion_l2;

   wire				hold_instructions_d;
   wire				hold_instructions_l2;


   // Credit counters
   wire [0:4]           fx0_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fx0_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fx0_high_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fx1_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fx1_high_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            lq_cmdq_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           lq_cmdq_high_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            sq_cmdq_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           sq_cmdq_high_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fu0_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fu0_high_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fu1_high_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fu1_high_credit_cnt_l2[0:`THREADS-1];

   wire [0:4]           fx0_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fx0_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fx0_med_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fx1_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fx1_med_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            lq_cmdq_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           lq_cmdq_med_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            sq_cmdq_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           sq_cmdq_med_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fu0_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fu0_med_credit_cnt_l2[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_plus1_temp[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_plus1[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_minus1_temp[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_minus1[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_minus2_temp[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_minus2[0:`THREADS-1];
   reg [0:4]            fu1_med_credit_cnt_d[0:`THREADS-1];
   wire [0:4]           fu1_med_credit_cnt_l2[0:`THREADS-1];

   wire [0:4]           fx0_credit_cnt_mux[0:`THREADS-1];
   wire [0:4]           fx1_credit_cnt_mux[0:`THREADS-1];
   wire [0:4]           lq_cmdq_credit_cnt_mux[0:`THREADS-1];
   wire [0:4]           sq_cmdq_credit_cnt_mux[0:`THREADS-1];
   wire [0:4]           fu0_credit_cnt_mux[0:`THREADS-1];
   wire [0:4]           fu1_credit_cnt_mux[0:`THREADS-1];

   reg [0:4]            fx0_total_credit_cnt_d;
   wire [0:4]           fx0_total_credit_cnt_l2;
   reg [0:4]            fx1_total_credit_cnt_d;
   wire [0:4]           fx1_total_credit_cnt_l2;
   reg [0:4]            lq_cmdq_total_credit_cnt_d;
   wire [0:4]           lq_cmdq_total_credit_cnt_l2;
   reg [0:4]            sq_cmdq_total_credit_cnt_d;
   wire [0:4]           sq_cmdq_total_credit_cnt_l2;
   reg [0:4]            fu0_total_credit_cnt_d;
   wire [0:4]           fu0_total_credit_cnt_l2;
   reg [0:4]            fu1_total_credit_cnt_d;
   wire [0:4]           fu1_total_credit_cnt_l2;

   wire [0:`THREADS-1]  total_pri_mask_d;
   wire [0:`THREADS-1]  total_pri_mask_l2;
   wire [0:`THREADS-1]  high_pri_mask_d;
   wire [0:`THREADS-1]  high_pri_mask_l2;
   wire [0:`THREADS-1]  med_pri_mask_d;
   wire [0:`THREADS-1]  med_pri_mask_l2;
   wire [0:`THREADS-1]  low_pri_mask_d;
   wire [0:`THREADS-1]  low_pri_mask_l2;
   wire [0:7]           low_pri_cnt_d[0:`THREADS-1];
   wire [0:7]           low_pri_cnt_l2[0:`THREADS-1];
   wire [0:5]           low_pri_max_d[0:`THREADS-1];
   wire [0:5]           low_pri_max_l2[0:`THREADS-1];
   wire [0:`THREADS-1]  low_pri_cnt_act;
   wire [0:`THREADS-1]  low_pri_en;

   // Perf count latches
   wire [0:`THREADS-1]  perf_iu6_stall_d;
   wire [0:`THREADS-1]  perf_iu6_stall_l2;
   wire [0:1]           perf_iu6_dispatch_fx0_d[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_fx0_l2[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_fx1_d[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_fx1_l2[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_lq_d[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_lq_l2[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_axu0_d[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_axu0_l2[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_axu1_d[0:`THREADS-1];
   wire [0:1]           perf_iu6_dispatch_axu1_l2[0:`THREADS-1];
   wire [0:`THREADS-1]  perf_iu6_fx0_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_fx0_credit_stall_l2;
   wire [0:`THREADS-1]  perf_iu6_fx1_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_fx1_credit_stall_l2;
   wire [0:`THREADS-1]  perf_iu6_lq_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_lq_credit_stall_l2;
   wire [0:`THREADS-1]  perf_iu6_sq_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_sq_credit_stall_l2;
   wire [0:`THREADS-1]  perf_iu6_axu0_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_axu0_credit_stall_l2;
   wire [0:`THREADS-1]  perf_iu6_axu1_credit_stall_d;
   wire [0:`THREADS-1]  perf_iu6_axu1_credit_stall_l2;

   wire [0:`THREADS-1]  iu_pc_fx0_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_fx0_credit_ok_l2;
   wire [0:`THREADS-1]  iu_pc_fx1_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_fx1_credit_ok_l2;
   wire [0:`THREADS-1]  iu_pc_lq_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_lq_credit_ok_l2;
   wire [0:`THREADS-1]  iu_pc_sq_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_sq_credit_ok_l2;
   wire [0:`THREADS-1]  iu_pc_axu0_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_axu0_credit_ok_l2;
   wire [0:`THREADS-1]  iu_pc_axu1_credit_ok_d;
   wire [0:`THREADS-1]  iu_pc_axu1_credit_ok_l2;

   // Counts used for total counts
   reg [0:1]            fx0_credit_cnt_minus_1;
   reg [0:1]            fx0_credit_cnt_minus_2;
   reg [0:1]            fx0_credit_cnt_plus_1;
   reg [0:1]            fx0_credit_cnt_zero;
   reg [0:1]            fx1_credit_cnt_minus_1;
   reg [0:1]            fx1_credit_cnt_minus_2;
   reg [0:1]            fx1_credit_cnt_plus_1;
   reg [0:1]            fx1_credit_cnt_zero;
   reg [0:1]            lq_cmdq_credit_cnt_minus_1;
   reg [0:1]            lq_cmdq_credit_cnt_minus_2;
   reg [0:1]            lq_cmdq_credit_cnt_plus_1;
   reg [0:1]            lq_cmdq_credit_cnt_zero;
   reg [0:1]            sq_cmdq_credit_cnt_minus_1;
   reg [0:1]            sq_cmdq_credit_cnt_minus_2;
   reg [0:1]            sq_cmdq_credit_cnt_plus_1;
   reg [0:1]            sq_cmdq_credit_cnt_zero;
   reg [0:1]            fu0_credit_cnt_minus_1;
   reg [0:1]            fu0_credit_cnt_minus_2;
   reg [0:1]            fu0_credit_cnt_plus_1;
   reg [0:1]            fu0_credit_cnt_zero;
   reg [0:1]            fu1_credit_cnt_minus_1;
   reg [0:1]            fu1_credit_cnt_minus_2;
   reg [0:1]            fu1_credit_cnt_plus_1;
   reg [0:1]            fu1_credit_cnt_zero;

   // Latch to delay the flush signal
   wire [0:`THREADS-1]  cp_flush_l2;
   wire [0:`THREADS-1]  xu_iu_run_thread_l2;

   wire                 iu_xu_credits_returned_d;
   wire                 iu_xu_credits_returned_l2;

   // Rotating bit to determine in a tie which thread will issue
   wire [0:`THREADS-1]  last_thread_d;
   wire [0:`THREADS-1]  last_thread_l2;
   wire                 last_thread_act;

   // This signal compares credits left and issues FX0 and FX1 instructions to FX0 when set
   reg  [0:1]           dual_issue_use_fx0_d;
   wire [0:1]           dual_issue_use_fx0_l2;

   wire [0:1]           fx0_send_cnt[0:`THREADS-1];
   wire [0:1]           fx1_send_cnt[0:`THREADS-1];
   wire [0:1]           lq_cmdq_send_cnt[0:`THREADS-1];
   wire [0:1]           sq_cmdq_send_cnt[0:`THREADS-1];
   wire [0:1]           fu0_send_cnt[0:`THREADS-1];
   wire [0:1]           fu1_send_cnt[0:`THREADS-1];

   wire [0:`THREADS-1]  core_block_ok;
   // Check credits if only issue individual thread
   wire [0:`THREADS-1]  fx0_local_credit_ok;
   wire [0:`THREADS-1]  fx1_local_credit_ok;
   wire [0:`THREADS-1]  lq_cmdq_local_credit_ok;
   wire [0:`THREADS-1]  sq_cmdq_local_credit_ok;
   wire [0:`THREADS-1]  fu0_local_credit_ok;
   wire [0:`THREADS-1]  fu1_local_credit_ok;
   // Check total credits if only issue individual thread
   wire [0:`THREADS-1]  fx0_credit_ok;
   wire [0:`THREADS-1]  fx1_credit_ok;
   wire [0:`THREADS-1]  lq_cmdq_credit_ok;
   wire [0:`THREADS-1]  sq_cmdq_credit_ok;
   wire [0:`THREADS-1]  fu0_credit_ok;
   wire [0:`THREADS-1]  fu1_credit_ok;
   // Check total credits if issue all `THREADS
   wire                 fx0_both_credit_ok;
   wire                 fx1_both_credit_ok;
   wire                 lq_cmdq_both_credit_ok;
   wire                 sq_cmdq_both_credit_ok;
   wire                 fu0_both_credit_ok;
   wire                 fu1_both_credit_ok;

   wire [0:`THREADS-1]  core_block;

   wire [0:`THREADS-1]  send_instructions_all;
   wire [0:`THREADS-1]  send_instructions_local;
   wire [0:`THREADS-1]  send_instructions;

   // signals to be used internal to vhdl
   wire [0:`THREADS-1]  iu_rv_iu6_i0_vld_int;
   wire [0:`THREADS-1]  iu_rv_iu6_i1_vld_int;

   // Pervasive
   wire                 pc_iu_func_sl_thold_1;
   wire                 pc_iu_func_sl_thold_0;
   wire                 pc_iu_func_sl_thold_0_b;
   wire                 pc_iu_func_slp_sl_thold_1;
   wire                 pc_iu_func_slp_sl_thold_0;
   wire                 pc_iu_func_slp_sl_thold_0_b;
   wire                 pc_iu_sg_1;
   wire                 pc_iu_sg_0;
   wire                 force_t;

   wire [0:4]           spr_high_fx0_cnt[0:`THREADS-1];
   wire [0:4]           spr_high_fx1_cnt[0:`THREADS-1];
   wire [0:4]           spr_high_lq_cnt[0:`THREADS-1];
   wire [0:4]           spr_high_sq_cnt[0:`THREADS-1];
   wire [0:4]           spr_high_fu0_cnt[0:`THREADS-1];
   wire [0:4]           spr_high_fu1_cnt[0:`THREADS-1];

   wire [0:4]           spr_med_fx0_cnt[0:`THREADS-1];
   wire [0:4]           spr_med_fx1_cnt[0:`THREADS-1];
   wire [0:4]           spr_med_lq_cnt[0:`THREADS-1];
   wire [0:4]           spr_med_sq_cnt[0:`THREADS-1];
   wire [0:4]           spr_med_fu0_cnt[0:`THREADS-1];
   wire [0:4]           spr_med_fu1_cnt[0:`THREADS-1];

   wire [0:5]           spr_low_pri_count[0:`THREADS-1];

   // Wires to more to 2D arrays
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_vld;
   wire [0:`ITAG_SIZE_ENC-1]   		frn_fdis_iu6_i0_itag[0:`THREADS-1];
   wire [0:2]				        		frn_fdis_iu6_i0_ucode[0:`THREADS-1];
   wire [0:`UCODE_ENTRIES_ENC-1]		frn_fdis_iu6_i0_ucode_cnt[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_2ucode;
   wire [0:`THREADS-1]            	frn_fdis_iu6_i0_fuse_nop;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_lq;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_sq;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_fx0;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_fx1;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_axu0;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_rte_axu1;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_valop;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_ord;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i0_cord;
   wire [0:2]        					frn_fdis_iu6_i0_error[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_btb_entry;
   wire [0:1]         					frn_fdis_iu6_i0_btb_hist[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_bta_val;
   wire [0:19]         	       		frn_fdis_iu6_i0_fusion[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_spec;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_type_fp;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_type_ap;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_type_spv;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_type_st;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_async_block;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_np1_flush;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_core_block;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_isram;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_isload;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_isstore;
   wire [0:31]         					frn_fdis_iu6_i0_instr[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]    	frn_fdis_iu6_i0_ifar[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]    	frn_fdis_iu6_i0_bta[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_br_pred;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_bh_update;
   wire [0:1]     			     		frn_fdis_iu6_i0_bh0_hist[0:`THREADS-1];
   wire [0:1]         					frn_fdis_iu6_i0_bh1_hist[0:`THREADS-1];
   wire [0:1]         					frn_fdis_iu6_i0_bh2_hist[0:`THREADS-1];
   wire [0:17]         					frn_fdis_iu6_i0_gshare[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_ls_ptr[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_match;
   wire [0:3]         					frn_fdis_iu6_i0_ilat[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_t1_v;
   wire [0:2]         					frn_fdis_iu6_i0_t1_t[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t1_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t1_p[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t2_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t2_p[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_t2_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t3_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_t3_p[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_t3_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_s1_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_s1_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i0_s1_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_s1_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s1_dep_hit;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1]       	frn_fdis_iu6_i0_s2_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_s2_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i0_s2_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_s2_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s2_dep_hit;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_s3_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i0_s3_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i0_s3_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i0_s3_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i0_s3_dep_hit;

   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_vld;
   wire [0:`ITAG_SIZE_ENC-1]   		frn_fdis_iu6_i1_itag[0:`THREADS-1];
   wire [0:2]				        		frn_fdis_iu6_i1_ucode[0:`THREADS-1];
   wire [0:`UCODE_ENTRIES_ENC-1]		frn_fdis_iu6_i1_ucode_cnt[0:`THREADS-1];
   wire [0:`THREADS-1]            	frn_fdis_iu6_i1_fuse_nop;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_lq;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_sq;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_fx0;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_fx1;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_axu0;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_rte_axu1;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_valop;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_ord;
   wire [0:`THREADS-1]             	frn_fdis_iu6_i1_cord;
   wire [0:2]        					frn_fdis_iu6_i1_error[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_btb_entry;
   wire [0:1]         					frn_fdis_iu6_i1_btb_hist[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_bta_val;
   wire [0:19]         	       		frn_fdis_iu6_i1_fusion[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_spec;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_type_fp;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_type_ap;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_type_spv;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_type_st;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_async_block;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_np1_flush;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_core_block;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_isram;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_isload;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_isstore;
   wire [0:31]         					frn_fdis_iu6_i1_instr[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]    	frn_fdis_iu6_i1_ifar[0:`THREADS-1];
   wire [62-`EFF_IFAR_WIDTH:61]    	frn_fdis_iu6_i1_bta[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_br_pred;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_bh_update;
   wire [0:1]     			     		frn_fdis_iu6_i1_bh0_hist[0:`THREADS-1];
   wire [0:1]         					frn_fdis_iu6_i1_bh1_hist[0:`THREADS-1];
   wire [0:1]         					frn_fdis_iu6_i1_bh2_hist[0:`THREADS-1];
   wire [0:17]         					frn_fdis_iu6_i1_gshare[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_ls_ptr[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_match;
   wire [0:3]         					frn_fdis_iu6_i1_ilat[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_t1_v;
   wire [0:2]         					frn_fdis_iu6_i1_t1_t[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t1_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t1_p[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t2_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t2_p[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_t2_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t3_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_t3_p[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_t3_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_s1_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_s1_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i1_s1_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_s1_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s1_dep_hit;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1]       	frn_fdis_iu6_i1_s2_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_s2_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i1_s2_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_s2_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s2_dep_hit;
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_s3_a[0:`THREADS-1];
   wire [0:`GPR_POOL_ENC-1]        	frn_fdis_iu6_i1_s3_p[0:`THREADS-1];
   wire [0:`ITAG_SIZE_ENC-1]       	frn_fdis_iu6_i1_s3_itag[0:`THREADS-1];
   wire [0:2]         					frn_fdis_iu6_i1_s3_t[0:`THREADS-1];
   wire [0:`THREADS-1]         		frn_fdis_iu6_i1_s3_dep_hit;

   wire [0:`THREADS-1] fx0_send_cnt_zero;
   wire [0:`THREADS-1] fx0_send_cnt_one;
   wire [0:`THREADS-1] fx1_send_cnt_zero;
   wire [0:`THREADS-1] fx1_send_cnt_one;
   wire [0:`THREADS-1] fu0_send_cnt_zero;
   wire [0:`THREADS-1] fu0_send_cnt_one;
   wire [0:`THREADS-1] fu1_send_cnt_zero;
   wire [0:`THREADS-1] fu1_send_cnt_one;
   wire [0:`THREADS-1] lq_cmdq_send_cnt_zero;
   wire [0:`THREADS-1] lq_cmdq_send_cnt_one;
   wire [0:`THREADS-1] sq_cmdq_send_cnt_zero;
   wire [0:`THREADS-1] sq_cmdq_send_cnt_one;


   //!! Bugspray Include: iuq_dispatch

   assign spr_high_fx0_cnt[0] 				= spr_t0_cpcr2_fx0_cnt;
   assign spr_high_fx1_cnt[0] 				= spr_t0_cpcr2_fx1_cnt;
   assign spr_high_lq_cnt[0]					= spr_t0_cpcr2_lq_cnt;
   assign spr_high_sq_cnt[0]					= spr_t0_cpcr2_sq_cnt;
   assign spr_high_fu0_cnt[0]				   = spr_t0_cpcr3_fu0_cnt;
   assign spr_high_fu1_cnt[0]				   = spr_t0_cpcr3_fu1_cnt;
   assign spr_med_fx0_cnt[0] 		         = spr_t0_cpcr4_fx0_cnt;
   assign spr_med_fx1_cnt[0] 		         = spr_t0_cpcr4_fx1_cnt;
   assign spr_med_lq_cnt[0]		         = spr_t0_cpcr4_lq_cnt;
   assign spr_med_sq_cnt[0]		         = spr_t0_cpcr4_sq_cnt;
   assign spr_med_fu0_cnt[0]		         = spr_t0_cpcr5_fu0_cnt;
   assign spr_med_fu1_cnt[0]		         = spr_t0_cpcr5_fu1_cnt;
   assign spr_low_pri_count[0]            = spr_t0_low_pri_count;
`ifndef THREADS1
   assign spr_high_fx0_cnt[1]             = spr_t1_cpcr2_fx0_cnt;
   assign spr_high_fx1_cnt[1]             = spr_t1_cpcr2_fx1_cnt;
   assign spr_high_lq_cnt[1]	            = spr_t1_cpcr2_lq_cnt;
   assign spr_high_sq_cnt[1]	            = spr_t1_cpcr2_sq_cnt;
   assign spr_high_fu0_cnt[1]	            = spr_t1_cpcr3_fu0_cnt;
   assign spr_high_fu1_cnt[1]	            = spr_t1_cpcr3_fu1_cnt;
   assign spr_med_fx0_cnt[1] 	            = spr_t1_cpcr4_fx0_cnt;
   assign spr_med_fx1_cnt[1] 	            = spr_t1_cpcr4_fx1_cnt;
   assign spr_med_lq_cnt[1]	            = spr_t1_cpcr4_lq_cnt;
   assign spr_med_sq_cnt[1]	            = spr_t1_cpcr4_sq_cnt;
   assign spr_med_fu0_cnt[1]	            = spr_t1_cpcr5_fu0_cnt;
   assign spr_med_fu1_cnt[1]	            = spr_t1_cpcr5_fu1_cnt;
   assign spr_low_pri_count[1]            = spr_t1_low_pri_count;
`endif

	assign frn_fdis_iu6_i0_vld[0] 			= frn_fdis_iu6_t0_i0_vld;
   assign frn_fdis_iu6_i0_itag[0] 			= frn_fdis_iu6_t0_i0_itag;
   assign frn_fdis_iu6_i0_ucode[0] 			= frn_fdis_iu6_t0_i0_ucode;
   assign frn_fdis_iu6_i0_ucode_cnt[0] 	= frn_fdis_iu6_t0_i0_ucode_cnt;
   assign frn_fdis_iu6_i0_2ucode[0] 		= frn_fdis_iu6_t0_i0_2ucode;
   assign frn_fdis_iu6_i0_fuse_nop[0] 		= frn_fdis_iu6_t0_i0_fuse_nop;
   assign frn_fdis_iu6_i0_rte_lq[0]			= frn_fdis_iu6_t0_i0_rte_lq;
   assign frn_fdis_iu6_i0_rte_sq[0]			= frn_fdis_iu6_t0_i0_rte_sq;
   assign frn_fdis_iu6_i0_rte_fx0[0]		= frn_fdis_iu6_t0_i0_rte_fx0;
   assign frn_fdis_iu6_i0_rte_fx1[0]		= frn_fdis_iu6_t0_i0_rte_fx1;
   assign frn_fdis_iu6_i0_rte_axu0[0]		= frn_fdis_iu6_t0_i0_rte_axu0;
   assign frn_fdis_iu6_i0_rte_axu1[0]		= frn_fdis_iu6_t0_i0_rte_axu1;
   assign frn_fdis_iu6_i0_valop[0]			= frn_fdis_iu6_t0_i0_valop;
   assign frn_fdis_iu6_i0_ord[0]				= frn_fdis_iu6_t0_i0_ord;
   assign frn_fdis_iu6_i0_cord[0]			= frn_fdis_iu6_t0_i0_cord;
   assign frn_fdis_iu6_i0_error[0]			= frn_fdis_iu6_t0_i0_error;
   assign frn_fdis_iu6_i0_btb_entry[0]		= frn_fdis_iu6_t0_i0_btb_entry;
   assign frn_fdis_iu6_i0_btb_hist[0]		= frn_fdis_iu6_t0_i0_btb_hist;
   assign frn_fdis_iu6_i0_bta_val[0]		= frn_fdis_iu6_t0_i0_bta_val;
   assign frn_fdis_iu6_i0_fusion[0]			= frn_fdis_iu6_t0_i0_fusion;
   assign frn_fdis_iu6_i0_spec[0]			= frn_fdis_iu6_t0_i0_spec;
   assign frn_fdis_iu6_i0_type_fp[0]		= frn_fdis_iu6_t0_i0_type_fp;
   assign frn_fdis_iu6_i0_type_ap[0]		= frn_fdis_iu6_t0_i0_type_ap;
   assign frn_fdis_iu6_i0_type_spv[0]		= frn_fdis_iu6_t0_i0_type_spv;
   assign frn_fdis_iu6_i0_type_st[0]		= frn_fdis_iu6_t0_i0_type_st;
   assign frn_fdis_iu6_i0_async_block[0]	= frn_fdis_iu6_t0_i0_async_block;
   assign frn_fdis_iu6_i0_np1_flush[0]		= frn_fdis_iu6_t0_i0_np1_flush;
   assign frn_fdis_iu6_i0_core_block[0]	= frn_fdis_iu6_t0_i0_core_block;
   assign frn_fdis_iu6_i0_isram[0]			= frn_fdis_iu6_t0_i0_isram;
   assign frn_fdis_iu6_i0_isload[0]			= frn_fdis_iu6_t0_i0_isload;
   assign frn_fdis_iu6_i0_isstore[0]		= frn_fdis_iu6_t0_i0_isstore;
   assign frn_fdis_iu6_i0_instr[0]			= frn_fdis_iu6_t0_i0_instr;
   assign frn_fdis_iu6_i0_ifar[0]			= frn_fdis_iu6_t0_i0_ifar;
   assign frn_fdis_iu6_i0_bta[0]				= frn_fdis_iu6_t0_i0_bta;
   assign frn_fdis_iu6_i0_br_pred[0]		= frn_fdis_iu6_t0_i0_br_pred;
   assign frn_fdis_iu6_i0_bh_update[0]		= frn_fdis_iu6_t0_i0_bh_update;
   assign frn_fdis_iu6_i0_bh0_hist[0]     = frn_fdis_iu6_t0_i0_bh0_hist;
   assign frn_fdis_iu6_i0_bh1_hist[0]     = frn_fdis_iu6_t0_i0_bh1_hist;
   assign frn_fdis_iu6_i0_bh2_hist[0]     = frn_fdis_iu6_t0_i0_bh2_hist;
   assign frn_fdis_iu6_i0_gshare[0]       = frn_fdis_iu6_t0_i0_gshare;
   assign frn_fdis_iu6_i0_ls_ptr[0]       = frn_fdis_iu6_t0_i0_ls_ptr;
   assign frn_fdis_iu6_i0_match[0]        = frn_fdis_iu6_t0_i0_match;
   assign frn_fdis_iu6_i0_ilat[0]         = frn_fdis_iu6_t0_i0_ilat;
   assign frn_fdis_iu6_i0_t1_v[0]         = frn_fdis_iu6_t0_i0_t1_v;
   assign frn_fdis_iu6_i0_t1_t[0]         = frn_fdis_iu6_t0_i0_t1_t;
   assign frn_fdis_iu6_i0_t1_a[0]         = frn_fdis_iu6_t0_i0_t1_a;
   assign frn_fdis_iu6_i0_t1_p[0]         = frn_fdis_iu6_t0_i0_t1_p;
   assign frn_fdis_iu6_i0_t2_v[0]         = frn_fdis_iu6_t0_i0_t2_v;
   assign frn_fdis_iu6_i0_t2_a[0]         = frn_fdis_iu6_t0_i0_t2_a;
   assign frn_fdis_iu6_i0_t2_p[0]         = frn_fdis_iu6_t0_i0_t2_p;
   assign frn_fdis_iu6_i0_t2_t[0]         = frn_fdis_iu6_t0_i0_t2_t;
   assign frn_fdis_iu6_i0_t3_v[0]         = frn_fdis_iu6_t0_i0_t3_v;
   assign frn_fdis_iu6_i0_t3_a[0]         = frn_fdis_iu6_t0_i0_t3_a;
   assign frn_fdis_iu6_i0_t3_p[0]         = frn_fdis_iu6_t0_i0_t3_p;
   assign frn_fdis_iu6_i0_t3_t[0]         = frn_fdis_iu6_t0_i0_t3_t;
   assign frn_fdis_iu6_i0_s1_v[0]         = frn_fdis_iu6_t0_i0_s1_v;
   assign frn_fdis_iu6_i0_s1_a[0]         = frn_fdis_iu6_t0_i0_s1_a;
   assign frn_fdis_iu6_i0_s1_p[0]         = frn_fdis_iu6_t0_i0_s1_p;
   assign frn_fdis_iu6_i0_s1_itag[0]      = frn_fdis_iu6_t0_i0_s1_itag;
   assign frn_fdis_iu6_i0_s1_t[0]         = frn_fdis_iu6_t0_i0_s1_t;
   assign frn_fdis_iu6_i0_s2_v[0]         = frn_fdis_iu6_t0_i0_s2_v;
   assign frn_fdis_iu6_i0_s2_a[0]         = frn_fdis_iu6_t0_i0_s2_a;
   assign frn_fdis_iu6_i0_s2_p[0]         = frn_fdis_iu6_t0_i0_s2_p;
   assign frn_fdis_iu6_i0_s2_itag[0]      = frn_fdis_iu6_t0_i0_s2_itag;
   assign frn_fdis_iu6_i0_s2_t[0]         = frn_fdis_iu6_t0_i0_s2_t;
   assign frn_fdis_iu6_i0_s3_v[0]         = frn_fdis_iu6_t0_i0_s3_v;
   assign frn_fdis_iu6_i0_s3_a[0]         = frn_fdis_iu6_t0_i0_s3_a;
   assign frn_fdis_iu6_i0_s3_p[0]         = frn_fdis_iu6_t0_i0_s3_p;
   assign frn_fdis_iu6_i0_s3_itag[0]      = frn_fdis_iu6_t0_i0_s3_itag;
   assign frn_fdis_iu6_i0_s3_t[0]         = frn_fdis_iu6_t0_i0_s3_t;

   assign frn_fdis_iu6_i1_vld[0]                = frn_fdis_iu6_t0_i1_vld;
   assign frn_fdis_iu6_i1_itag[0]               = frn_fdis_iu6_t0_i1_itag;
   assign frn_fdis_iu6_i1_ucode[0]              = frn_fdis_iu6_t0_i1_ucode;
   assign frn_fdis_iu6_i1_ucode_cnt[0]          = frn_fdis_iu6_t0_i1_ucode_cnt;
   assign frn_fdis_iu6_i1_fuse_nop[0]           = frn_fdis_iu6_t0_i1_fuse_nop;
   assign frn_fdis_iu6_i1_rte_lq[0]             = frn_fdis_iu6_t0_i1_rte_lq;
   assign frn_fdis_iu6_i1_rte_sq[0]             = frn_fdis_iu6_t0_i1_rte_sq;
   assign frn_fdis_iu6_i1_rte_fx0[0]            = frn_fdis_iu6_t0_i1_rte_fx0;
   assign frn_fdis_iu6_i1_rte_fx1[0]            = frn_fdis_iu6_t0_i1_rte_fx1;
   assign frn_fdis_iu6_i1_rte_axu0[0]           = frn_fdis_iu6_t0_i1_rte_axu0;
   assign frn_fdis_iu6_i1_rte_axu1[0]           = frn_fdis_iu6_t0_i1_rte_axu1;
   assign frn_fdis_iu6_i1_valop[0]              = frn_fdis_iu6_t0_i1_valop;
   assign frn_fdis_iu6_i1_ord[0]                = frn_fdis_iu6_t0_i1_ord;
   assign frn_fdis_iu6_i1_cord[0]               = frn_fdis_iu6_t0_i1_cord;
   assign frn_fdis_iu6_i1_error[0]              = frn_fdis_iu6_t0_i1_error;
   assign frn_fdis_iu6_i1_btb_entry[0]          = frn_fdis_iu6_t0_i1_btb_entry;
   assign frn_fdis_iu6_i1_btb_hist[0]           = frn_fdis_iu6_t0_i1_btb_hist;
   assign frn_fdis_iu6_i1_bta_val[0]            = frn_fdis_iu6_t0_i1_bta_val;
   assign frn_fdis_iu6_i1_fusion[0]             = frn_fdis_iu6_t0_i1_fusion;
   assign frn_fdis_iu6_i1_spec[0]               = frn_fdis_iu6_t0_i1_spec;
   assign frn_fdis_iu6_i1_type_fp[0]            = frn_fdis_iu6_t0_i1_type_fp;
   assign frn_fdis_iu6_i1_type_ap[0]            = frn_fdis_iu6_t0_i1_type_ap;
   assign frn_fdis_iu6_i1_type_spv[0]           = frn_fdis_iu6_t0_i1_type_spv;
   assign frn_fdis_iu6_i1_type_st[0]            = frn_fdis_iu6_t0_i1_type_st;
   assign frn_fdis_iu6_i1_async_block[0]        = frn_fdis_iu6_t0_i1_async_block;
   assign frn_fdis_iu6_i1_np1_flush[0]          = frn_fdis_iu6_t0_i1_np1_flush;
   assign frn_fdis_iu6_i1_core_block[0]         = frn_fdis_iu6_t0_i1_core_block;
   assign frn_fdis_iu6_i1_isram[0]              = frn_fdis_iu6_t0_i1_isram;
   assign frn_fdis_iu6_i1_isload[0]             = frn_fdis_iu6_t0_i1_isload;
   assign frn_fdis_iu6_i1_isstore[0]            = frn_fdis_iu6_t0_i1_isstore;
   assign frn_fdis_iu6_i1_instr[0]              = frn_fdis_iu6_t0_i1_instr;
   assign frn_fdis_iu6_i1_ifar[0]               = frn_fdis_iu6_t0_i1_ifar;
   assign frn_fdis_iu6_i1_bta[0]                = frn_fdis_iu6_t0_i1_bta;
   assign frn_fdis_iu6_i1_br_pred[0]            = frn_fdis_iu6_t0_i1_br_pred;
   assign frn_fdis_iu6_i1_bh_update[0]          = frn_fdis_iu6_t0_i1_bh_update;
   assign frn_fdis_iu6_i1_bh0_hist[0]           = frn_fdis_iu6_t0_i1_bh0_hist;
   assign frn_fdis_iu6_i1_bh1_hist[0]           = frn_fdis_iu6_t0_i1_bh1_hist;
   assign frn_fdis_iu6_i1_bh2_hist[0]           = frn_fdis_iu6_t0_i1_bh2_hist;
   assign frn_fdis_iu6_i1_gshare[0]             = frn_fdis_iu6_t0_i1_gshare;
   assign frn_fdis_iu6_i1_ls_ptr[0]             = frn_fdis_iu6_t0_i1_ls_ptr;
   assign frn_fdis_iu6_i1_match[0]              = frn_fdis_iu6_t0_i1_match;
   assign frn_fdis_iu6_i1_ilat[0]               = frn_fdis_iu6_t0_i1_ilat;
   assign frn_fdis_iu6_i1_t1_v[0]               = frn_fdis_iu6_t0_i1_t1_v;
   assign frn_fdis_iu6_i1_t1_t[0]               = frn_fdis_iu6_t0_i1_t1_t;
   assign frn_fdis_iu6_i1_t1_a[0]               = frn_fdis_iu6_t0_i1_t1_a;
   assign frn_fdis_iu6_i1_t1_p[0]               = frn_fdis_iu6_t0_i1_t1_p;
   assign frn_fdis_iu6_i1_t2_v[0]               = frn_fdis_iu6_t0_i1_t2_v;
   assign frn_fdis_iu6_i1_t2_a[0]               = frn_fdis_iu6_t0_i1_t2_a;
   assign frn_fdis_iu6_i1_t2_p[0]               = frn_fdis_iu6_t0_i1_t2_p;
   assign frn_fdis_iu6_i1_t2_t[0]               = frn_fdis_iu6_t0_i1_t2_t;
   assign frn_fdis_iu6_i1_t3_v[0]               = frn_fdis_iu6_t0_i1_t3_v;
   assign frn_fdis_iu6_i1_t3_a[0]               = frn_fdis_iu6_t0_i1_t3_a;
   assign frn_fdis_iu6_i1_t3_p[0]               = frn_fdis_iu6_t0_i1_t3_p;
   assign frn_fdis_iu6_i1_t3_t[0]               = frn_fdis_iu6_t0_i1_t3_t;
   assign frn_fdis_iu6_i1_s1_v[0]               = frn_fdis_iu6_t0_i1_s1_v;
   assign frn_fdis_iu6_i1_s1_a[0]               = frn_fdis_iu6_t0_i1_s1_a;
   assign frn_fdis_iu6_i1_s1_p[0]               = frn_fdis_iu6_t0_i1_s1_p;
   assign frn_fdis_iu6_i1_s1_itag[0]            = frn_fdis_iu6_t0_i1_s1_itag;
   assign frn_fdis_iu6_i1_s1_t[0]               = frn_fdis_iu6_t0_i1_s1_t;
   assign frn_fdis_iu6_i1_s1_dep_hit[0]         = frn_fdis_iu6_t0_i1_s1_dep_hit;
   assign frn_fdis_iu6_i1_s2_v[0]               = frn_fdis_iu6_t0_i1_s2_v;
   assign frn_fdis_iu6_i1_s2_a[0]               = frn_fdis_iu6_t0_i1_s2_a;
   assign frn_fdis_iu6_i1_s2_p[0]               = frn_fdis_iu6_t0_i1_s2_p;
   assign frn_fdis_iu6_i1_s2_itag[0]            = frn_fdis_iu6_t0_i1_s2_itag;
   assign frn_fdis_iu6_i1_s2_t[0]               = frn_fdis_iu6_t0_i1_s2_t;
   assign frn_fdis_iu6_i1_s2_dep_hit[0]         = frn_fdis_iu6_t0_i1_s2_dep_hit;
   assign frn_fdis_iu6_i1_s3_v[0]               = frn_fdis_iu6_t0_i1_s3_v;
   assign frn_fdis_iu6_i1_s3_a[0]               = frn_fdis_iu6_t0_i1_s3_a;
   assign frn_fdis_iu6_i1_s3_p[0]               = frn_fdis_iu6_t0_i1_s3_p;
   assign frn_fdis_iu6_i1_s3_itag[0]            = frn_fdis_iu6_t0_i1_s3_itag;
   assign frn_fdis_iu6_i1_s3_t[0]               = frn_fdis_iu6_t0_i1_s3_t;
   assign frn_fdis_iu6_i1_s3_dep_hit[0]         = frn_fdis_iu6_t0_i1_s3_dep_hit;

`ifndef THREADS1
   assign frn_fdis_iu6_i0_vld[1]                = frn_fdis_iu6_t1_i0_vld;
   assign frn_fdis_iu6_i0_itag[1]               = frn_fdis_iu6_t1_i0_itag;
   assign frn_fdis_iu6_i0_ucode[1]              = frn_fdis_iu6_t1_i0_ucode;
   assign frn_fdis_iu6_i0_ucode_cnt[1]          = frn_fdis_iu6_t1_i0_ucode_cnt;
   assign frn_fdis_iu6_i0_2ucode[1]             = frn_fdis_iu6_t1_i0_2ucode;
   assign frn_fdis_iu6_i0_fuse_nop[1]           = frn_fdis_iu6_t1_i0_fuse_nop;
   assign frn_fdis_iu6_i0_rte_lq[1]             = frn_fdis_iu6_t1_i0_rte_lq;
   assign frn_fdis_iu6_i0_rte_sq[1]             = frn_fdis_iu6_t1_i0_rte_sq;
   assign frn_fdis_iu6_i0_rte_fx0[1]            = frn_fdis_iu6_t1_i0_rte_fx0;
   assign frn_fdis_iu6_i0_rte_fx1[1]            = frn_fdis_iu6_t1_i0_rte_fx1;
   assign frn_fdis_iu6_i0_rte_axu0[1]           = frn_fdis_iu6_t1_i0_rte_axu0;
   assign frn_fdis_iu6_i0_rte_axu1[1]           = frn_fdis_iu6_t1_i0_rte_axu1;
   assign frn_fdis_iu6_i0_valop[1]              = frn_fdis_iu6_t1_i0_valop;
   assign frn_fdis_iu6_i0_ord[1]                = frn_fdis_iu6_t1_i0_ord;
   assign frn_fdis_iu6_i0_cord[1]               = frn_fdis_iu6_t1_i0_cord;
   assign frn_fdis_iu6_i0_error[1]              = frn_fdis_iu6_t1_i0_error;
   assign frn_fdis_iu6_i0_btb_entry[1]          = frn_fdis_iu6_t1_i0_btb_entry;
   assign frn_fdis_iu6_i0_btb_hist[1]           = frn_fdis_iu6_t1_i0_btb_hist;
   assign frn_fdis_iu6_i0_bta_val[1]            = frn_fdis_iu6_t1_i0_bta_val;
   assign frn_fdis_iu6_i0_fusion[1]             = frn_fdis_iu6_t1_i0_fusion;
   assign frn_fdis_iu6_i0_spec[1]               = frn_fdis_iu6_t1_i0_spec;
   assign frn_fdis_iu6_i0_type_fp[1]            = frn_fdis_iu6_t1_i0_type_fp;
   assign frn_fdis_iu6_i0_type_ap[1]            = frn_fdis_iu6_t1_i0_type_ap;
   assign frn_fdis_iu6_i0_type_spv[1]           = frn_fdis_iu6_t1_i0_type_spv;
   assign frn_fdis_iu6_i0_type_st[1]            = frn_fdis_iu6_t1_i0_type_st;
   assign frn_fdis_iu6_i0_async_block[1]        = frn_fdis_iu6_t1_i0_async_block;
   assign frn_fdis_iu6_i0_np1_flush[1]          = frn_fdis_iu6_t1_i0_np1_flush;
   assign frn_fdis_iu6_i0_core_block[1]         = frn_fdis_iu6_t1_i0_core_block;
   assign frn_fdis_iu6_i0_isram[1]              = frn_fdis_iu6_t1_i0_isram;
   assign frn_fdis_iu6_i0_isload[1]             = frn_fdis_iu6_t1_i0_isload;
   assign frn_fdis_iu6_i0_isstore[1]            = frn_fdis_iu6_t1_i0_isstore;
   assign frn_fdis_iu6_i0_instr[1]              = frn_fdis_iu6_t1_i0_instr;
   assign frn_fdis_iu6_i0_ifar[1]               = frn_fdis_iu6_t1_i0_ifar;
   assign frn_fdis_iu6_i0_bta[1]                = frn_fdis_iu6_t1_i0_bta;
   assign frn_fdis_iu6_i0_br_pred[1]            = frn_fdis_iu6_t1_i0_br_pred;
   assign frn_fdis_iu6_i0_bh_update[1]          = frn_fdis_iu6_t1_i0_bh_update;
   assign frn_fdis_iu6_i0_bh0_hist[1]           = frn_fdis_iu6_t1_i0_bh0_hist;
   assign frn_fdis_iu6_i0_bh1_hist[1]           = frn_fdis_iu6_t1_i0_bh1_hist;
   assign frn_fdis_iu6_i0_bh2_hist[1]           = frn_fdis_iu6_t1_i0_bh2_hist;
   assign frn_fdis_iu6_i0_gshare[1]             = frn_fdis_iu6_t1_i0_gshare;
   assign frn_fdis_iu6_i0_ls_ptr[1]             = frn_fdis_iu6_t1_i0_ls_ptr;
   assign frn_fdis_iu6_i0_match[1]              = frn_fdis_iu6_t1_i0_match;
   assign frn_fdis_iu6_i0_ilat[1]               = frn_fdis_iu6_t1_i0_ilat;
   assign frn_fdis_iu6_i0_t1_v[1]               = frn_fdis_iu6_t1_i0_t1_v;
   assign frn_fdis_iu6_i0_t1_t[1]               = frn_fdis_iu6_t1_i0_t1_t;
   assign frn_fdis_iu6_i0_t1_a[1]               = frn_fdis_iu6_t1_i0_t1_a;
   assign frn_fdis_iu6_i0_t1_p[1]               = frn_fdis_iu6_t1_i0_t1_p;
   assign frn_fdis_iu6_i0_t2_v[1]               = frn_fdis_iu6_t1_i0_t2_v;
   assign frn_fdis_iu6_i0_t2_a[1]               = frn_fdis_iu6_t1_i0_t2_a;
   assign frn_fdis_iu6_i0_t2_p[1]               = frn_fdis_iu6_t1_i0_t2_p;
   assign frn_fdis_iu6_i0_t2_t[1]               = frn_fdis_iu6_t1_i0_t2_t;
   assign frn_fdis_iu6_i0_t3_v[1]               = frn_fdis_iu6_t1_i0_t3_v;
   assign frn_fdis_iu6_i0_t3_a[1]               = frn_fdis_iu6_t1_i0_t3_a;
   assign frn_fdis_iu6_i0_t3_p[1]               = frn_fdis_iu6_t1_i0_t3_p;
   assign frn_fdis_iu6_i0_t3_t[1]               = frn_fdis_iu6_t1_i0_t3_t;
   assign frn_fdis_iu6_i0_s1_v[1]               = frn_fdis_iu6_t1_i0_s1_v;
   assign frn_fdis_iu6_i0_s1_a[1]               = frn_fdis_iu6_t1_i0_s1_a;
   assign frn_fdis_iu6_i0_s1_p[1]               = frn_fdis_iu6_t1_i0_s1_p;
   assign frn_fdis_iu6_i0_s1_itag[1]            = frn_fdis_iu6_t1_i0_s1_itag;
   assign frn_fdis_iu6_i0_s1_t[1]               = frn_fdis_iu6_t1_i0_s1_t;
   assign frn_fdis_iu6_i0_s2_v[1]               = frn_fdis_iu6_t1_i0_s2_v;
   assign frn_fdis_iu6_i0_s2_a[1]               = frn_fdis_iu6_t1_i0_s2_a;
   assign frn_fdis_iu6_i0_s2_p[1]               = frn_fdis_iu6_t1_i0_s2_p;
   assign frn_fdis_iu6_i0_s2_itag[1]            = frn_fdis_iu6_t1_i0_s2_itag;
   assign frn_fdis_iu6_i0_s2_t[1]               = frn_fdis_iu6_t1_i0_s2_t;
   assign frn_fdis_iu6_i0_s3_v[1]               = frn_fdis_iu6_t1_i0_s3_v;
   assign frn_fdis_iu6_i0_s3_a[1]               = frn_fdis_iu6_t1_i0_s3_a;
   assign frn_fdis_iu6_i0_s3_p[1]               = frn_fdis_iu6_t1_i0_s3_p;
   assign frn_fdis_iu6_i0_s3_itag[1]            = frn_fdis_iu6_t1_i0_s3_itag;
   assign frn_fdis_iu6_i0_s3_t[1]               = frn_fdis_iu6_t1_i0_s3_t;

   assign frn_fdis_iu6_i1_vld[1]                = frn_fdis_iu6_t1_i1_vld;
   assign frn_fdis_iu6_i1_itag[1]               = frn_fdis_iu6_t1_i1_itag;
   assign frn_fdis_iu6_i1_ucode[1]              = frn_fdis_iu6_t1_i1_ucode;
   assign frn_fdis_iu6_i1_ucode_cnt[1]          = frn_fdis_iu6_t1_i1_ucode_cnt;
   assign frn_fdis_iu6_i1_fuse_nop[1]           = frn_fdis_iu6_t1_i1_fuse_nop;
   assign frn_fdis_iu6_i1_rte_lq[1]             = frn_fdis_iu6_t1_i1_rte_lq;
   assign frn_fdis_iu6_i1_rte_sq[1]             = frn_fdis_iu6_t1_i1_rte_sq;
   assign frn_fdis_iu6_i1_rte_fx0[1]            = frn_fdis_iu6_t1_i1_rte_fx0;
   assign frn_fdis_iu6_i1_rte_fx1[1]            = frn_fdis_iu6_t1_i1_rte_fx1;
   assign frn_fdis_iu6_i1_rte_axu0[1]           = frn_fdis_iu6_t1_i1_rte_axu0;
   assign frn_fdis_iu6_i1_rte_axu1[1]           = frn_fdis_iu6_t1_i1_rte_axu1;
   assign frn_fdis_iu6_i1_valop[1]              = frn_fdis_iu6_t1_i1_valop;
   assign frn_fdis_iu6_i1_ord[1]                = frn_fdis_iu6_t1_i1_ord;
   assign frn_fdis_iu6_i1_cord[1]               = frn_fdis_iu6_t1_i1_cord;
   assign frn_fdis_iu6_i1_error[1]              = frn_fdis_iu6_t1_i1_error;
   assign frn_fdis_iu6_i1_btb_entry[1]          = frn_fdis_iu6_t1_i1_btb_entry;
   assign frn_fdis_iu6_i1_btb_hist[1]           = frn_fdis_iu6_t1_i1_btb_hist;
   assign frn_fdis_iu6_i1_bta_val[1]            = frn_fdis_iu6_t1_i1_bta_val;
   assign frn_fdis_iu6_i1_fusion[1]             = frn_fdis_iu6_t1_i1_fusion;
   assign frn_fdis_iu6_i1_spec[1]               = frn_fdis_iu6_t1_i1_spec;
   assign frn_fdis_iu6_i1_type_fp[1]            = frn_fdis_iu6_t1_i1_type_fp;
   assign frn_fdis_iu6_i1_type_ap[1]            = frn_fdis_iu6_t1_i1_type_ap;
   assign frn_fdis_iu6_i1_type_spv[1]           = frn_fdis_iu6_t1_i1_type_spv;
   assign frn_fdis_iu6_i1_type_st[1]            = frn_fdis_iu6_t1_i1_type_st;
   assign frn_fdis_iu6_i1_async_block[1]        = frn_fdis_iu6_t1_i1_async_block;
   assign frn_fdis_iu6_i1_np1_flush[1]          = frn_fdis_iu6_t1_i1_np1_flush;
   assign frn_fdis_iu6_i1_core_block[1]         = frn_fdis_iu6_t1_i1_core_block;
   assign frn_fdis_iu6_i1_isram[1]              = frn_fdis_iu6_t1_i1_isram;
   assign frn_fdis_iu6_i1_isload[1]             = frn_fdis_iu6_t1_i1_isload;
   assign frn_fdis_iu6_i1_isstore[1]            = frn_fdis_iu6_t1_i1_isstore;
   assign frn_fdis_iu6_i1_instr[1]              = frn_fdis_iu6_t1_i1_instr;
   assign frn_fdis_iu6_i1_ifar[1]               = frn_fdis_iu6_t1_i1_ifar;
   assign frn_fdis_iu6_i1_bta[1]                = frn_fdis_iu6_t1_i1_bta;
   assign frn_fdis_iu6_i1_br_pred[1]            = frn_fdis_iu6_t1_i1_br_pred;
   assign frn_fdis_iu6_i1_bh_update[1]          = frn_fdis_iu6_t1_i1_bh_update;
   assign frn_fdis_iu6_i1_bh0_hist[1]           = frn_fdis_iu6_t1_i1_bh0_hist;
   assign frn_fdis_iu6_i1_bh1_hist[1]           = frn_fdis_iu6_t1_i1_bh1_hist;
   assign frn_fdis_iu6_i1_bh2_hist[1]           = frn_fdis_iu6_t1_i1_bh2_hist;
   assign frn_fdis_iu6_i1_gshare[1]             = frn_fdis_iu6_t1_i1_gshare;
   assign frn_fdis_iu6_i1_ls_ptr[1]             = frn_fdis_iu6_t1_i1_ls_ptr;
   assign frn_fdis_iu6_i1_match[1]              = frn_fdis_iu6_t1_i1_match;
   assign frn_fdis_iu6_i1_ilat[1]               = frn_fdis_iu6_t1_i1_ilat;
   assign frn_fdis_iu6_i1_t1_v[1]               = frn_fdis_iu6_t1_i1_t1_v;
   assign frn_fdis_iu6_i1_t1_t[1]               = frn_fdis_iu6_t1_i1_t1_t;
   assign frn_fdis_iu6_i1_t1_a[1]               = frn_fdis_iu6_t1_i1_t1_a;
   assign frn_fdis_iu6_i1_t1_p[1]               = frn_fdis_iu6_t1_i1_t1_p;
   assign frn_fdis_iu6_i1_t2_v[1]               = frn_fdis_iu6_t1_i1_t2_v;
   assign frn_fdis_iu6_i1_t2_a[1]               = frn_fdis_iu6_t1_i1_t2_a;
   assign frn_fdis_iu6_i1_t2_p[1]               = frn_fdis_iu6_t1_i1_t2_p;
   assign frn_fdis_iu6_i1_t2_t[1]               = frn_fdis_iu6_t1_i1_t2_t;
   assign frn_fdis_iu6_i1_t3_v[1]               = frn_fdis_iu6_t1_i1_t3_v;
   assign frn_fdis_iu6_i1_t3_a[1]               = frn_fdis_iu6_t1_i1_t3_a;
   assign frn_fdis_iu6_i1_t3_p[1]               = frn_fdis_iu6_t1_i1_t3_p;
   assign frn_fdis_iu6_i1_t3_t[1]               = frn_fdis_iu6_t1_i1_t3_t;
   assign frn_fdis_iu6_i1_s1_v[1]               = frn_fdis_iu6_t1_i1_s1_v;
   assign frn_fdis_iu6_i1_s1_a[1]               = frn_fdis_iu6_t1_i1_s1_a;
   assign frn_fdis_iu6_i1_s1_p[1]               = frn_fdis_iu6_t1_i1_s1_p;
   assign frn_fdis_iu6_i1_s1_itag[1]            = frn_fdis_iu6_t1_i1_s1_itag;
   assign frn_fdis_iu6_i1_s1_t[1]               = frn_fdis_iu6_t1_i1_s1_t;
   assign frn_fdis_iu6_i1_s1_dep_hit[1]         = frn_fdis_iu6_t1_i1_s1_dep_hit;
   assign frn_fdis_iu6_i1_s2_v[1]               = frn_fdis_iu6_t1_i1_s2_v;
   assign frn_fdis_iu6_i1_s2_a[1]               = frn_fdis_iu6_t1_i1_s2_a;
   assign frn_fdis_iu6_i1_s2_p[1]               = frn_fdis_iu6_t1_i1_s2_p;
   assign frn_fdis_iu6_i1_s2_itag[1]            = frn_fdis_iu6_t1_i1_s2_itag;
   assign frn_fdis_iu6_i1_s2_t[1]               = frn_fdis_iu6_t1_i1_s2_t;
   assign frn_fdis_iu6_i1_s2_dep_hit[1]         = frn_fdis_iu6_t1_i1_s2_dep_hit;
   assign frn_fdis_iu6_i1_s3_v[1]               = frn_fdis_iu6_t1_i1_s3_v;
   assign frn_fdis_iu6_i1_s3_a[1]               = frn_fdis_iu6_t1_i1_s3_a;
   assign frn_fdis_iu6_i1_s3_p[1]               = frn_fdis_iu6_t1_i1_s3_p;
   assign frn_fdis_iu6_i1_s3_itag[1]            = frn_fdis_iu6_t1_i1_s3_itag;
   assign frn_fdis_iu6_i1_s3_t[1]               = frn_fdis_iu6_t1_i1_s3_t;
   assign frn_fdis_iu6_i1_s3_dep_hit[1]         = frn_fdis_iu6_t1_i1_s3_dep_hit;
`endif


   assign tiup = 1'b1;

   assign dp_cp_hold_req = (mm_iu_flush_req_l2 & ~(in_ucode_l2 | in_fusion_l2));
   assign dp_cp_bus_snoop_hold_req = (mm_iu_bus_snoop_hold_req_l2 & ~(in_ucode_l2 | in_fusion_l2));
   assign mm_iu_flush_req_d = mm_iu_flush_req | (mm_iu_flush_req_l2 & (in_ucode_l2 | in_fusion_l2));
   assign mm_iu_bus_snoop_hold_req_d = mm_iu_bus_snoop_hold_req | (mm_iu_bus_snoop_hold_req_l2 & (in_ucode_l2 | in_fusion_l2));

   // Added logic for Erat invalidates to stop dispatch
   generate
   	begin : xhdl1
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : send_cnt
            //IN V0 12 V1 12 | IN
            // -  1 1-  0 -- |  1
            // -  - --  1 1- |  1
            // -  1 -1  0 -- |  0
            // -  - --  1 -1 |  0
            assign in_ucode_d[i] = (cp_flush_l2[i] == 1'b1) ? 1'b0 :
                                   (iu_rv_iu6_i0_vld_int[i] == 1'b1 & frn_fdis_iu6_i0_ucode[i][1] == 1'b1 & iu_rv_iu6_i1_vld_int[i] == 1'b0) ? 1'b1 :
                                   (iu_rv_iu6_i1_vld_int[i] == 1'b1 & frn_fdis_iu6_i1_ucode[i][1] == 1'b1) ? 1'b1 :
                                   (iu_rv_iu6_i0_vld_int[i] == 1'b1 & frn_fdis_iu6_i0_ucode[i][2] == 1'b1 & iu_rv_iu6_i1_vld_int[i] == 1'b0) ? 1'b0 :
                                   (iu_rv_iu6_i1_vld_int[i] == 1'b1 & frn_fdis_iu6_i1_ucode[i][2] == 1'b1) ? 1'b0 :
                                   in_ucode_l2[i];

            //IN V0 F V1 F | IN
            // -  1 1  0 - |  1
            // -  - -  1 1 |  1
            // -  1 0  0 - |  0
            // -  - -  1 0 |  0
            assign in_fusion_d[i] = (cp_flush_l2[i] == 1'b1) ? 1'b0 :
                                    (iu_rv_iu6_i0_vld_int[i] == 1'b1 & frn_fdis_iu6_i0_fuse_nop[i] == 1'b1 & iu_rv_iu6_i1_vld_int[i] == 1'b0) ? 1'b1 :
                                    (iu_rv_iu6_i1_vld_int[i] == 1'b1 & frn_fdis_iu6_i1_fuse_nop[i] == 1'b1) ? 1'b1 :
                                    (iu_rv_iu6_i0_vld_int[i] == 1'b1 & frn_fdis_iu6_i0_fuse_nop[i] == 1'b0 & iu_rv_iu6_i1_vld_int[i] == 1'b0) ? 1'b0 :
                                    (iu_rv_iu6_i1_vld_int[i] == 1'b1 & frn_fdis_iu6_i1_fuse_nop[i] == 1'b0) ? 1'b0 :
                                    in_fusion_l2[i];

            assign mm_hold_req_d[i] = (mm_iu_flush_req_l2[i] & ~(in_ucode_l2[i] | in_fusion_l2[i])) |
                                      (mm_hold_req_l2[i] & ~mm_hold_done_l2[i]);

            assign mm_hold_done_d[i] = mm_iu_hold_done_l2[i];

            assign mm_bus_snoop_hold_req_d[i] = (mm_iu_bus_snoop_hold_req_l2[i] & ~(in_ucode_l2[i] | in_fusion_l2[i])) |
                                                (mm_bus_snoop_hold_req_l2[i] & ~mm_bus_snoop_hold_done_l2[i]);

            assign mm_bus_snoop_hold_done_d[i] = mm_iu_bus_snoop_hold_done_l2[i];

            assign hold_req_d[i] = (send_instructions[i] & core_block[i]) |
                                   (hold_req_l2[i] & ~hold_done_l2[i]);

            assign hold_done_d[i] = cp_flush_l2[i];

            assign ivax_hold_req_d[i] = (cp_dis_ivax[i]) |
                                        (ivax_hold_req_l2[i] & ~mm_iu_tlbi_complete[i]);

            assign fx0_send_cnt[i] = {(frn_fdis_iu6_i0_rte_fx0[i] & (~frn_fdis_iu6_i0_rte_fx1[i] | dual_issue_use_fx0_l2[0])),
                                      (frn_fdis_iu6_i1_rte_fx0[i] & (~frn_fdis_iu6_i1_rte_fx1[i] | dual_issue_use_fx0_l2[1]))};

            assign fx1_send_cnt[i] = {(frn_fdis_iu6_i0_rte_fx1[i] & (~frn_fdis_iu6_i0_rte_fx0[i] | ~dual_issue_use_fx0_l2[0])),
                                      (frn_fdis_iu6_i1_rte_fx1[i] & (~frn_fdis_iu6_i1_rte_fx0[i] | ~dual_issue_use_fx0_l2[1]))};

            assign lq_cmdq_send_cnt[i] = {frn_fdis_iu6_i0_rte_lq[i], frn_fdis_iu6_i1_rte_lq[i]};

            assign sq_cmdq_send_cnt[i] = {frn_fdis_iu6_i0_rte_sq[i], frn_fdis_iu6_i1_rte_sq[i]};

            assign fu0_send_cnt[i] = {(frn_fdis_iu6_i0_rte_axu0[i] & ~(frn_fdis_iu6_i0_rte_lq[i] & frn_fdis_iu6_i0_isload[i])),
                                      (frn_fdis_iu6_i1_rte_axu0[i] & ~(frn_fdis_iu6_i1_rte_lq[i] & frn_fdis_iu6_i1_isload[i]))};

            assign fu1_send_cnt[i] = {(frn_fdis_iu6_i0_rte_axu1[i] & ~(frn_fdis_iu6_i0_rte_lq[i] & frn_fdis_iu6_i0_isload[i])),
                                      (frn_fdis_iu6_i1_rte_axu1[i] & ~(frn_fdis_iu6_i1_rte_lq[i] & frn_fdis_iu6_i1_isload[i]))};

            assign core_block[i] = (frn_fdis_iu6_i0_core_block[i] | frn_fdis_iu6_i1_core_block[i]);
         end
      end
   endgenerate

   generate
      begin : primux
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : credit_mux
            assign fx0_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & fx0_total_credit_cnt_l2) |
                                           ({5{high_pri_mask_l2[i]}} & fx0_high_credit_cnt_l2[i]) |
                                           ({5{med_pri_mask_l2[i]}} & fx0_med_credit_cnt_l2[i]);

            assign fx1_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & fx1_total_credit_cnt_l2) |
                                           ({5{high_pri_mask_l2[i]}} & fx1_high_credit_cnt_l2[i]) |
                                           ({5{med_pri_mask_l2[i]}} & fx1_med_credit_cnt_l2[i]);

            assign lq_cmdq_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & lq_cmdq_total_credit_cnt_l2) |
                                               ({5{high_pri_mask_l2[i]}} & lq_cmdq_high_credit_cnt_l2[i]) |
                                               ({5{med_pri_mask_l2[i]}} & lq_cmdq_med_credit_cnt_l2[i]);

            assign sq_cmdq_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & sq_cmdq_total_credit_cnt_l2) |
                                               ({5{high_pri_mask_l2[i]}} & sq_cmdq_high_credit_cnt_l2[i]) |
                                               ({5{med_pri_mask_l2[i]}} & sq_cmdq_med_credit_cnt_l2[i]);

            assign fu0_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & fu0_total_credit_cnt_l2) |
                                           ({5{high_pri_mask_l2[i]}} & fu0_high_credit_cnt_l2[i]) |
                                           ({5{med_pri_mask_l2[i]}} & fu0_med_credit_cnt_l2[i]);

            assign fu1_credit_cnt_mux[i] = ({5{total_pri_mask_l2[i]}} & fu1_total_credit_cnt_l2) |
                                           ({5{high_pri_mask_l2[i]}} & fu1_high_credit_cnt_l2[i]) |
                                           ({5{med_pri_mask_l2[i]}} & fu1_med_credit_cnt_l2[i]);
         end
      end
   endgenerate

`ifdef THREADS1
   // Checking to make sure we aren't in ucode so we can issue a core blocker
   assign core_block_ok[0] = 1'b1;
`endif
`ifndef THREADS1
   assign core_block_ok[0] = ~(core_block[0] & (in_ucode_l2[1] | in_fusion_l2[1]));
   assign core_block_ok[1] = ~(core_block[1] & (in_ucode_l2[0] | in_fusion_l2[0]));
`endif

tri_nor2 fx0_send_cnt_t0_zero(fx0_send_cnt_zero[0], fx0_send_cnt[0][0], fx0_send_cnt[0][1]);
tri_xor2 fx0_send_cnt_t0_one (fx0_send_cnt_one[0],  fx0_send_cnt[0][0], fx0_send_cnt[0][1]);
tri_nor2 fx1_send_cnt_t0_zero(fx1_send_cnt_zero[0], fx1_send_cnt[0][0], fx1_send_cnt[0][1]);
tri_xor2 fx1_send_cnt_t0_one (fx1_send_cnt_one[0],  fx1_send_cnt[0][0], fx1_send_cnt[0][1]);
tri_nor2 fu0_send_cnt_t0_zero(fu0_send_cnt_zero[0], fu0_send_cnt[0][0], fu0_send_cnt[0][1]);
tri_xor2 fu0_send_cnt_t0_one (fu0_send_cnt_one[0],  fu0_send_cnt[0][0], fu0_send_cnt[0][1]);
tri_nor2 fu1_send_cnt_t0_zero(fu1_send_cnt_zero[0], fu1_send_cnt[0][0], fu1_send_cnt[0][1]);
tri_xor2 fu1_send_cnt_t0_one (fu1_send_cnt_one[0],  fu1_send_cnt[0][0], fu1_send_cnt[0][1]);
tri_nor2 lq_cmdq_send_cnt_t0_zero(lq_cmdq_send_cnt_zero[0], lq_cmdq_send_cnt[0][0], lq_cmdq_send_cnt[0][1]);
tri_xor2 lq_cmdq_send_cnt_t0_one (lq_cmdq_send_cnt_one[0],  lq_cmdq_send_cnt[0][0], lq_cmdq_send_cnt[0][1]);
tri_nor2 sq_cmdq_send_cnt_t0_zero(sq_cmdq_send_cnt_zero[0], sq_cmdq_send_cnt[0][0], sq_cmdq_send_cnt[0][1]);
tri_xor2 sq_cmdq_send_cnt_t0_one (sq_cmdq_send_cnt_one[0],  sq_cmdq_send_cnt[0][0], sq_cmdq_send_cnt[0][1]);

`ifndef THREADS1
tri_nor2 fx0_send_cnt_t1_zero(fx0_send_cnt_zero[1], fx0_send_cnt[1][0], fx0_send_cnt[1][1]);
tri_xor2 fx0_send_cnt_t1_one (fx0_send_cnt_one[1],  fx0_send_cnt[1][0], fx0_send_cnt[1][1]);
tri_nor2 fx1_send_cnt_t1_zero(fx1_send_cnt_zero[1], fx1_send_cnt[1][0], fx1_send_cnt[1][1]);
tri_xor2 fx1_send_cnt_t1_one (fx1_send_cnt_one[1],  fx1_send_cnt[1][0], fx1_send_cnt[1][1]);
tri_nor2 fu0_send_cnt_t1_zero(fu0_send_cnt_zero[1], fu0_send_cnt[1][0], fu0_send_cnt[1][1]);
tri_xor2 fu0_send_cnt_t1_one (fu0_send_cnt_one[1],  fu0_send_cnt[1][0], fu0_send_cnt[1][1]);
tri_nor2 fu1_send_cnt_t1_zero(fu1_send_cnt_zero[1], fu1_send_cnt[1][0], fu1_send_cnt[1][1]);
tri_xor2 fu1_send_cnt_t1_one (fu1_send_cnt_one[1],  fu1_send_cnt[1][0], fu1_send_cnt[1][1]);
tri_nor2 lq_cmdq_send_cnt_t1_zero(lq_cmdq_send_cnt_zero[1], lq_cmdq_send_cnt[1][0], lq_cmdq_send_cnt[1][1]);
tri_xor2 lq_cmdq_send_cnt_t1_one (lq_cmdq_send_cnt_one[1],  lq_cmdq_send_cnt[1][0], lq_cmdq_send_cnt[1][1]);
tri_nor2 sq_cmdq_send_cnt_t1_zero(sq_cmdq_send_cnt_zero[1], sq_cmdq_send_cnt[1][0], sq_cmdq_send_cnt[1][1]);
tri_xor2 sq_cmdq_send_cnt_t1_one (sq_cmdq_send_cnt_one[1],  sq_cmdq_send_cnt[1][0], sq_cmdq_send_cnt[1][1]);
`endif

   generate
      begin : xhdl2
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : credit_ok
            // Checking the credits allocated for each thread
            assign fx0_local_credit_ok[i] = ((fx0_send_cnt_zero[i]) |
                                            ((fx0_send_cnt_one[i]) & |fx0_credit_cnt_mux[i]) |
                                            (|fx0_credit_cnt_mux[i][0:3]));

            assign fx1_local_credit_ok[i] = ((fx1_send_cnt_zero[i]) |
                                            ((fx1_send_cnt_one[i]) & |fx1_credit_cnt_mux[i]) |
                                            (|fx1_credit_cnt_mux[i][0:3]));

            assign lq_cmdq_local_credit_ok[i] = ((lq_cmdq_send_cnt_zero[i]) |
                                                ((lq_cmdq_send_cnt_one[i]) & |lq_cmdq_credit_cnt_mux[i]) |
                                                (|lq_cmdq_credit_cnt_mux[i][0:3]));

            assign sq_cmdq_local_credit_ok[i] = ((sq_cmdq_send_cnt_zero[i]) |
                                                ((sq_cmdq_send_cnt_one[i]) & |sq_cmdq_credit_cnt_mux[i]) |
                                                (|sq_cmdq_credit_cnt_mux[i][0:3]));

            assign fu0_local_credit_ok[i] = ((fu0_send_cnt_zero[i]) |
                                            ((fu0_send_cnt_one[i]) & |fu0_credit_cnt_mux[i]) |
                                            (|fu0_credit_cnt_mux[i][0:3]));

            assign fu1_local_credit_ok[i] = ((fu1_send_cnt_zero[i]) |
                                            ((fu1_send_cnt_one[i]) & |fu1_credit_cnt_mux[i]) |
                                            (|fu1_credit_cnt_mux[i][0:3]));

            // Checking total credits if only issuing each thread individually
            assign fx0_credit_ok[i] = ((fx0_send_cnt_zero[i]) |
                                      ((fx0_send_cnt_one[i]) & |fx0_total_credit_cnt_l2) |
                                      (|fx0_total_credit_cnt_l2[0:3]));

            assign fx1_credit_ok[i] = ((fx1_send_cnt_zero[i]) |
                                      ((fx1_send_cnt_one[i]) & |fx1_total_credit_cnt_l2) |
                                      (|fx1_total_credit_cnt_l2[0:3]));

            assign lq_cmdq_credit_ok[i] = ((lq_cmdq_send_cnt_zero[i]) |
                                          ((lq_cmdq_send_cnt_one[i]) & |lq_cmdq_total_credit_cnt_l2) |
                                          (|lq_cmdq_total_credit_cnt_l2[0:3]));

            assign sq_cmdq_credit_ok[i] = ((sq_cmdq_send_cnt_zero[i]) |
                                          ((sq_cmdq_send_cnt_one[i]) & |sq_cmdq_total_credit_cnt_l2) |
                                          (|sq_cmdq_total_credit_cnt_l2[0:3]));

            assign fu0_credit_ok[i] = ((fu0_send_cnt_zero[i]) |
                                      ((fu0_send_cnt_one[i]) & |fu0_total_credit_cnt_l2) |
                                      (|fu0_total_credit_cnt_l2[0:3]));

            assign fu1_credit_ok[i] = ((fu1_send_cnt_zero[i]) |
                                      ((fu1_send_cnt_one[i]) & |fu1_total_credit_cnt_l2) |
                                      (|fu1_total_credit_cnt_l2[0:3]));

         end
      end
   endgenerate



   generate
      if (`THREADS == 1)
      begin : thread_gen_1
         assign fx0_both_credit_ok = 1'b0;
         assign fx1_both_credit_ok = 1'b0;
         assign lq_cmdq_both_credit_ok = 1'b0;
         assign sq_cmdq_both_credit_ok = 1'b0;
         assign fu0_both_credit_ok = 1'b0;
         assign fu1_both_credit_ok = 1'b0;
      end
   endgenerate

   generate
      if (`THREADS == 2)
      begin : thread_gen_2
         assign fx0_both_credit_ok = (fx0_send_cnt_zero[0] & fx0_send_cnt_zero[1]) |
                                   (((fx0_send_cnt_zero[0] & fx0_send_cnt_one[1] ) | (fx0_send_cnt_zero[1] & fx0_send_cnt_one[0])) & (~(fx0_total_credit_cnt_l2 == {5{1'b0}}))) |
                                   (((fx0_send_cnt_zero[0] | fx0_send_cnt_zero[1]) | (fx0_send_cnt_one[0]  & fx0_send_cnt_one[1])) & |fx0_total_credit_cnt_l2[0:3]);

         assign fx1_both_credit_ok = (fx1_send_cnt_zero[0] & fx1_send_cnt_zero[1]) |
                                   (((fx1_send_cnt_zero[0] & fx1_send_cnt_one[1] ) | (fx1_send_cnt_zero[1] & fx1_send_cnt_one[0])) & (~(fx1_total_credit_cnt_l2 == {5{1'b0}}))) |
                                   (((fx1_send_cnt_zero[0] | fx1_send_cnt_zero[1]) | (fx1_send_cnt_one[0]  & fx1_send_cnt_one[1])) & |fx1_total_credit_cnt_l2[0:3]);

         assign lq_cmdq_both_credit_ok = (lq_cmdq_send_cnt_zero[0] & lq_cmdq_send_cnt_zero[1]) |
                                       (((lq_cmdq_send_cnt_zero[0] & lq_cmdq_send_cnt_one[1] ) | (lq_cmdq_send_cnt_zero[1] & lq_cmdq_send_cnt_one[0])) & (~(lq_cmdq_total_credit_cnt_l2 == {5{1'b0}}))) |
                                       (((lq_cmdq_send_cnt_zero[0] | lq_cmdq_send_cnt_zero[1]) | (lq_cmdq_send_cnt_one[0]  & lq_cmdq_send_cnt_one[1])) & |lq_cmdq_total_credit_cnt_l2[0:3]);

         assign sq_cmdq_both_credit_ok = (sq_cmdq_send_cnt_zero[0] & sq_cmdq_send_cnt_zero[1]) |
                                       (((sq_cmdq_send_cnt_zero[0] & sq_cmdq_send_cnt_one[1] ) | (sq_cmdq_send_cnt_zero[1] & sq_cmdq_send_cnt_one[0])) & (~(sq_cmdq_total_credit_cnt_l2 == {5{1'b0}}))) |
                                       (((sq_cmdq_send_cnt_zero[0] | sq_cmdq_send_cnt_zero[1]) | (sq_cmdq_send_cnt_one[0]  & sq_cmdq_send_cnt_one[1])) & |sq_cmdq_total_credit_cnt_l2[0:3]);


         assign fu0_both_credit_ok = (fu0_send_cnt_zero[0] & fu0_send_cnt_zero[1]) |
                                   (((fu0_send_cnt_zero[0] & fu0_send_cnt_one[1] ) | (fu0_send_cnt_zero[1] & fu0_send_cnt_one[0])) & (~(fu0_total_credit_cnt_l2 == {5{1'b0}}))) |
                                   (((fu0_send_cnt_zero[0] | fu0_send_cnt_zero[1]) | (fu0_send_cnt_one[0]  & fu0_send_cnt_one[1])) & |fu0_total_credit_cnt_l2[0:3]);

         assign fu1_both_credit_ok = (fu1_send_cnt_zero[0] & fu1_send_cnt_zero[1]) |
                                   (((fu1_send_cnt_zero[0] & fu1_send_cnt_one[1] ) | (fu1_send_cnt_zero[1] & fu1_send_cnt_one[0])) & (~(fu1_total_credit_cnt_l2 == {5{1'b0}}))) |
                                   (((fu1_send_cnt_zero[0] | fu1_send_cnt_zero[1]) | (fu1_send_cnt_one[0]  & fu1_send_cnt_one[1])) & |fu1_total_credit_cnt_l2[0:3]);

      end
   endgenerate

   generate
      begin : xhdl3
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : send_ok
            assign send_instructions_all[i] = (fx0_both_credit_ok & fx1_both_credit_ok & lq_cmdq_both_credit_ok & sq_cmdq_both_credit_ok & fu0_both_credit_ok & fu1_both_credit_ok) &
                                              (core_block_ok[i] & fx0_local_credit_ok[i] & fx1_local_credit_ok[i] & lq_cmdq_local_credit_ok[i] & sq_cmdq_local_credit_ok[i] &
                                                fu0_local_credit_ok[i] & fu1_local_credit_ok[i] & (low_pri_mask_l2[i] & frn_fdis_iu6_i0_vld[i])) &
                                          (~(|(core_block) | hold_instructions_l2));

            assign send_instructions_local[i] = ((fx0_credit_ok[i] & fx1_credit_ok[i] & lq_cmdq_credit_ok[i] & sq_cmdq_credit_ok[i] & fu0_credit_ok[i] & fu1_credit_ok[i]) &
                                                 (core_block_ok[i] & fx0_local_credit_ok[i] & fx1_local_credit_ok[i] & lq_cmdq_local_credit_ok[i] & sq_cmdq_local_credit_ok[i] &
                                                   fu0_local_credit_ok[i] & fu1_local_credit_ok[i] & (low_pri_mask_l2[i] & frn_fdis_iu6_i0_vld[i])) &
                                                 (frn_fdis_iu6_i0_ucode[i][0] | (~(hold_instructions_l2))));
         end
      end
   endgenerate

   assign hold_instructions_d = |(mm_hold_req_d | hold_req_d | ivax_hold_req_d);


   generate
      if (`THREADS == 1)
      begin : send_thread_gen_1
         assign send_instructions[0] = (send_instructions_all[0] | send_instructions_local[0]) & frn_fdis_iu6_i0_vld[0];
      end
   endgenerate

   generate
      if (`THREADS == 2)
      begin : send_thread_gen_2
         assign send_instructions[0] = (send_instructions_all[0] | (last_thread_l2[1] & send_instructions_local[0]) | (~send_instructions_local[1] & send_instructions_local[0])) & frn_fdis_iu6_i0_vld[0];

         assign send_instructions[1] = (send_instructions_all[1] | (last_thread_l2[0] & send_instructions_local[1]) | (~send_instructions_local[0] & send_instructions_local[1])) & frn_fdis_iu6_i0_vld[1];
      end
   endgenerate

   assign fdis_frn_iu6_stall = frn_fdis_iu6_i0_vld & (~send_instructions);

   assign last_thread_act = |send_instructions;
 `ifdef THREADS1
   assign last_thread_d = last_thread_l2[0];
 `endif
 `ifndef THREADS1
   assign last_thread_d = {last_thread_l2[1:`THREADS - 1], last_thread_l2[0]};
 `endif


   generate
      begin : local_credit_calc
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : local_credit_calc_thread
            assign fx0_high_credit_cnt_plus1_temp[i]  = fx0_high_credit_cnt_l2[i] + value_1[27:31];
            assign fx0_high_credit_cnt_minus1_temp[i] = fx0_high_credit_cnt_l2[i] - value_1[27:31];
            assign fx0_high_credit_cnt_minus2_temp[i] = fx0_high_credit_cnt_l2[i] - value_2[27:31];
            assign fx0_med_credit_cnt_plus1_temp[i]   = fx0_med_credit_cnt_l2[i] + value_1[27:31];
            assign fx0_med_credit_cnt_minus1_temp[i]  = fx0_med_credit_cnt_l2[i] - value_1[27:31];
            assign fx0_med_credit_cnt_minus2_temp[i]  = fx0_med_credit_cnt_l2[i] - value_2[27:31];

            assign fx1_high_credit_cnt_plus1_temp[i]  = fx1_high_credit_cnt_l2[i] + value_1[27:31];
            assign fx1_high_credit_cnt_minus1_temp[i] = fx1_high_credit_cnt_l2[i] - value_1[27:31];
            assign fx1_high_credit_cnt_minus2_temp[i] = fx1_high_credit_cnt_l2[i] - value_2[27:31];
            assign fx1_med_credit_cnt_plus1_temp[i]   = fx1_med_credit_cnt_l2[i] + value_1[27:31];
            assign fx1_med_credit_cnt_minus1_temp[i]  = fx1_med_credit_cnt_l2[i] - value_1[27:31];
            assign fx1_med_credit_cnt_minus2_temp[i]  = fx1_med_credit_cnt_l2[i] - value_2[27:31];

            assign lq_cmdq_high_credit_cnt_plus1_temp[i]  = lq_cmdq_high_credit_cnt_l2[i] + value_1[27:31];
            assign lq_cmdq_high_credit_cnt_minus1_temp[i] = lq_cmdq_high_credit_cnt_l2[i] - value_1[27:31];
            assign lq_cmdq_high_credit_cnt_minus2_temp[i] = lq_cmdq_high_credit_cnt_l2[i] - value_2[27:31];
            assign lq_cmdq_med_credit_cnt_plus1_temp[i]   = lq_cmdq_med_credit_cnt_l2[i] + value_1[27:31];
            assign lq_cmdq_med_credit_cnt_minus1_temp[i]  = lq_cmdq_med_credit_cnt_l2[i] - value_1[27:31];
            assign lq_cmdq_med_credit_cnt_minus2_temp[i]  = lq_cmdq_med_credit_cnt_l2[i] - value_2[27:31];

            assign sq_cmdq_high_credit_cnt_plus1_temp[i]  = sq_cmdq_high_credit_cnt_l2[i] + value_1[27:31];
            assign sq_cmdq_high_credit_cnt_minus1_temp[i] = sq_cmdq_high_credit_cnt_l2[i] - value_1[27:31];
            assign sq_cmdq_high_credit_cnt_minus2_temp[i] = sq_cmdq_high_credit_cnt_l2[i] - value_2[27:31];
            assign sq_cmdq_med_credit_cnt_plus1_temp[i]   = sq_cmdq_med_credit_cnt_l2[i] + value_1[27:31];
            assign sq_cmdq_med_credit_cnt_minus1_temp[i]  = sq_cmdq_med_credit_cnt_l2[i] - value_1[27:31];
            assign sq_cmdq_med_credit_cnt_minus2_temp[i]  = sq_cmdq_med_credit_cnt_l2[i] - value_2[27:31];

            assign fu0_high_credit_cnt_plus1_temp[i]  = fu0_high_credit_cnt_l2[i] + value_1[27:31];
            assign fu0_high_credit_cnt_minus1_temp[i] = fu0_high_credit_cnt_l2[i] - value_1[27:31];
            assign fu0_high_credit_cnt_minus2_temp[i] = fu0_high_credit_cnt_l2[i] - value_2[27:31];
            assign fu0_med_credit_cnt_plus1_temp[i]   = fu0_med_credit_cnt_l2[i] + value_1[27:31];
            assign fu0_med_credit_cnt_minus1_temp[i]  = fu0_med_credit_cnt_l2[i] - value_1[27:31];
            assign fu0_med_credit_cnt_minus2_temp[i]  = fu0_med_credit_cnt_l2[i] - value_2[27:31];

            assign fu1_high_credit_cnt_plus1_temp[i]  = fu1_high_credit_cnt_l2[i] + value_1[27:31];
            assign fu1_high_credit_cnt_minus1_temp[i] = fu1_high_credit_cnt_l2[i] - value_1[27:31];
            assign fu1_high_credit_cnt_minus2_temp[i] = fu1_high_credit_cnt_l2[i] - value_2[27:31];
            assign fu1_med_credit_cnt_plus1_temp[i]   = fu1_med_credit_cnt_l2[i] + value_1[27:31];
            assign fu1_med_credit_cnt_minus1_temp[i]  = fu1_med_credit_cnt_l2[i] - value_1[27:31];
            assign fu1_med_credit_cnt_minus2_temp[i]  = fu1_med_credit_cnt_l2[i] - value_2[27:31];

            assign fx0_high_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx0_cnt[i] :
                                                  (fx0_high_credit_cnt_plus1_temp[i] > spr_high_fx0_cnt[i]) ? spr_high_fx0_cnt[i] :
                                                   fx0_high_credit_cnt_plus1_temp[i];

            assign fx0_high_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx0_cnt[i] :
                                                   (fx0_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fx0_high_credit_cnt_minus1_temp[i];

            assign fx0_high_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx0_cnt[i] :
                                                   (fx0_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fx0_high_credit_cnt_minus2_temp[i];

            assign fx0_med_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx0_cnt[i] :
                                                 (fx0_med_credit_cnt_plus1_temp[i] > spr_med_fx0_cnt[i]) ? spr_med_fx0_cnt[i] :
                                                  fx0_med_credit_cnt_plus1_temp[i];

            assign fx0_med_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx0_cnt[i] :
                                                  (fx0_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fx0_med_credit_cnt_minus1_temp[i];

            assign fx0_med_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx0_cnt[i] :
                                                  (fx0_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fx0_med_credit_cnt_minus2_temp[i];

            assign fx1_high_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx1_cnt[i] :
                                                  (fx1_high_credit_cnt_plus1_temp[i] > spr_high_fx1_cnt[i]) ? spr_high_fx1_cnt[i] :
                                                   fx1_high_credit_cnt_plus1_temp[i];

            assign fx1_high_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx1_cnt[i] :
                                                   (fx1_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fx1_high_credit_cnt_minus1_temp[i];

            assign fx1_high_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx1_cnt[i] :
                                                   (fx1_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fx1_high_credit_cnt_minus2_temp[i];

            assign fx1_med_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx1_cnt[i] :
                                                 (fx1_med_credit_cnt_plus1_temp[i] > spr_med_fx1_cnt[i]) ? spr_med_fx1_cnt[i] :
                                                  fx1_med_credit_cnt_plus1_temp[i];

            assign fx1_med_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx1_cnt[i] :
                                                  (fx1_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fx1_med_credit_cnt_minus1_temp[i];

            assign fx1_med_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx1_cnt[i] :
                                                  (fx1_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fx1_med_credit_cnt_minus2_temp[i];

            assign lq_cmdq_high_credit_cnt_plus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_lq_cnt[i] :
                                                      (lq_cmdq_high_credit_cnt_plus1_temp[i] > spr_high_lq_cnt[i]) ? spr_high_lq_cnt[i] :
                                                       lq_cmdq_high_credit_cnt_plus1_temp[i];

            assign lq_cmdq_high_credit_cnt_minus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_lq_cnt[i] :
                                                       (lq_cmdq_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                        lq_cmdq_high_credit_cnt_minus1_temp[i];

            assign lq_cmdq_high_credit_cnt_minus2[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_lq_cnt[i] :
                                                       (lq_cmdq_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                        lq_cmdq_high_credit_cnt_minus2_temp[i];

            assign lq_cmdq_med_credit_cnt_plus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_lq_cnt[i] :
                                                     (lq_cmdq_med_credit_cnt_plus1_temp[i] > spr_med_lq_cnt[i]) ? spr_med_lq_cnt[i] :
                                                      lq_cmdq_med_credit_cnt_plus1_temp[i];

            assign lq_cmdq_med_credit_cnt_minus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_lq_cnt[i] :
                                                      (lq_cmdq_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                       lq_cmdq_med_credit_cnt_minus1_temp[i];

            assign lq_cmdq_med_credit_cnt_minus2[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_lq_cnt[i] :
                                                      (lq_cmdq_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                       lq_cmdq_med_credit_cnt_minus2_temp[i];

            assign sq_cmdq_high_credit_cnt_plus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_sq_cnt[i] :
                                                      (sq_cmdq_high_credit_cnt_plus1_temp[i] > spr_high_sq_cnt[i]) ? spr_high_sq_cnt[i] :
                                                       sq_cmdq_high_credit_cnt_plus1_temp[i];

            assign sq_cmdq_high_credit_cnt_minus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_sq_cnt[i] :
                                                       (sq_cmdq_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                        sq_cmdq_high_credit_cnt_minus1_temp[i];

            assign sq_cmdq_high_credit_cnt_minus2[i] = (spr_cpcr_we[i] == 1'b1) ? spr_high_sq_cnt[i] :
                                                       (sq_cmdq_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                        sq_cmdq_high_credit_cnt_minus2_temp[i];

            assign sq_cmdq_med_credit_cnt_plus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_sq_cnt[i] :
                                                     (sq_cmdq_med_credit_cnt_plus1_temp[i] > spr_med_sq_cnt[i]) ? spr_med_sq_cnt[i] :
                                                      sq_cmdq_med_credit_cnt_plus1_temp[i];

            assign sq_cmdq_med_credit_cnt_minus1[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_sq_cnt[i] :
                                                      (sq_cmdq_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                       sq_cmdq_med_credit_cnt_minus1_temp[i];

            assign sq_cmdq_med_credit_cnt_minus2[i] = (spr_cpcr_we[i] == 1'b1) ? spr_med_sq_cnt[i] :
                                                      (sq_cmdq_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                       sq_cmdq_med_credit_cnt_minus2_temp[i];

            assign fu0_high_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu0_cnt[i] :
                                                  (fu0_high_credit_cnt_plus1_temp[i] > spr_high_fu0_cnt[i]) ? spr_high_fu0_cnt[i] :
                                                   fu0_high_credit_cnt_plus1_temp[i];

            assign fu0_high_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu0_cnt[i] :
                                                   (fu0_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fu0_high_credit_cnt_minus1_temp[i];

            assign fu0_high_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu0_cnt[i] :
                                                   (fu0_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fu0_high_credit_cnt_minus2_temp[i];

            assign fu0_med_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu0_cnt[i] :
                                                 (fu0_med_credit_cnt_plus1_temp[i] > spr_med_fu0_cnt[i]) ? spr_med_fu0_cnt[i] :
                                                  fu0_med_credit_cnt_plus1_temp[i];

            assign fu0_med_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu0_cnt[i] :
                                                  (fu0_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fu0_med_credit_cnt_minus1_temp[i];

            assign fu0_med_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu0_cnt[i] :
                                                  (fu0_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fu0_med_credit_cnt_minus2_temp[i];

            assign fu1_high_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu1_cnt[i] :
                                                  (fu1_high_credit_cnt_plus1_temp[i] > spr_high_fu1_cnt[i]) ? spr_high_fu1_cnt[i] :
                                                   fu1_high_credit_cnt_plus1_temp[i];

            assign fu1_high_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu1_cnt[i] :
                                                   (fu1_high_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fu1_high_credit_cnt_minus1_temp[i];

            assign fu1_high_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu1_cnt[i] :
                                                   (fu1_high_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                    fu1_high_credit_cnt_minus2_temp[i];

            assign fu1_med_credit_cnt_plus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu1_cnt[i] :
                                                 (fu1_med_credit_cnt_plus1_temp[i] > spr_med_fu1_cnt[i]) ? spr_med_fu1_cnt[i] :
                                                  fu1_med_credit_cnt_plus1_temp[i];

            assign fu1_med_credit_cnt_minus1[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu1_cnt[i] :
                                                  (fu1_med_credit_cnt_minus1_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fu1_med_credit_cnt_minus1_temp[i];

            assign fu1_med_credit_cnt_minus2[i] = ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu1_cnt[i] :
                                                  (fu1_med_credit_cnt_minus2_temp[i][0] == 1'b1) ? 5'b0 :
                                                   fu1_med_credit_cnt_minus2_temp[i];
         end
      end
   endgenerate


   generate
      begin : xhdl4
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : credit_proc
            always @(*)
            begin: fx0_credit_proc
               fx0_high_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx0_cnt[i] : fx0_high_credit_cnt_l2[i];
               fx0_med_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx0_cnt[i] : fx0_med_credit_cnt_l2[i];
               fx0_credit_cnt_minus_1[i] <= 1'b0;
               fx0_credit_cnt_minus_2[i] <= 1'b0;
               fx0_credit_cnt_plus_1[i] <= 1'b0;
               fx0_credit_cnt_zero[i] <= 1'b1;

               if (rv_iu_fx0_credit_free[i] == 1'b1 & (send_instructions[i] == 1'b0 | fx0_send_cnt[i] == 2'b00))
               begin
                  fx0_high_credit_cnt_d[i] <= fx0_high_credit_cnt_plus1[i];
                  fx0_med_credit_cnt_d[i] <= fx0_med_credit_cnt_plus1[i];
                  fx0_credit_cnt_plus_1[i] <= 1'b1;
                  fx0_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((fx0_send_cnt[i][0] == 1'b1 ^ fx0_send_cnt[i][1] == 1'b1) & rv_iu_fx0_credit_free[i] == 1'b0) | ((fx0_send_cnt[i] == 2'b11) & rv_iu_fx0_credit_free[i] == 1'b1)))
               begin
                  fx0_high_credit_cnt_d[i] <= fx0_high_credit_cnt_minus1[i];
                  fx0_med_credit_cnt_d[i] <= fx0_med_credit_cnt_minus1[i];
                  fx0_credit_cnt_minus_1[i] <= 1'b1;
                  fx0_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & fx0_send_cnt[i] == 2'b11 & rv_iu_fx0_credit_free[i] == 1'b0)
               begin
                  fx0_high_credit_cnt_d[i] <= fx0_high_credit_cnt_minus2[i];
                  fx0_med_credit_cnt_d[i] <= fx0_med_credit_cnt_minus2[i];
                  fx0_credit_cnt_minus_2[i] <= 1'b1;
                  fx0_credit_cnt_zero[i] <= 1'b0;
               end
            end

            always @(*)
            begin: fx1_credit_proc
               fx1_high_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fx1_cnt[i] : fx1_high_credit_cnt_l2[i];
               fx1_med_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fx1_cnt[i] : fx1_med_credit_cnt_l2[i];
               fx1_credit_cnt_minus_1[i] <= 1'b0;
               fx1_credit_cnt_minus_2[i] <= 1'b0;
               fx1_credit_cnt_plus_1[i] <= 1'b0;
               fx1_credit_cnt_zero[i] <= 1'b1;

               if ((rv_iu_fx1_credit_free[i] == 1'b1) & (send_instructions[i] == 1'b0 | fx1_send_cnt[i] == 2'b00))
               begin
                  fx1_high_credit_cnt_d[i] <= fx1_high_credit_cnt_plus1[i];
                  fx1_med_credit_cnt_d[i] <= fx1_med_credit_cnt_plus1[i];
                  fx1_credit_cnt_plus_1[i] <= 1'b1;
                  fx1_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((fx1_send_cnt[i][0] == 1'b1 ^ fx1_send_cnt[i][1] == 1'b1) & rv_iu_fx1_credit_free[i] == 1'b0) | ((fx1_send_cnt[i] == 2'b11) & rv_iu_fx1_credit_free[i] == 1'b1)))
               begin
                  fx1_high_credit_cnt_d[i] <= fx1_high_credit_cnt_minus1[i];
                  fx1_med_credit_cnt_d[i] <= fx1_med_credit_cnt_minus1[i];
                  fx1_credit_cnt_minus_1[i] <= 1'b1;
                  fx1_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & fx1_send_cnt[i] == 2'b11 & rv_iu_fx1_credit_free[i] == 1'b0)
               begin
                  fx1_high_credit_cnt_d[i] <= fx1_high_credit_cnt_minus2[i];
                  fx1_med_credit_cnt_d[i] <= fx1_med_credit_cnt_minus2[i];
                  fx1_credit_cnt_minus_2[i] <= 1'b1;
                  fx1_credit_cnt_zero[i] <= 1'b0;
               end

            end

            always @(*)
            begin: lq_cmdq_credit_proc
               lq_cmdq_high_credit_cnt_d[i] <= (spr_cpcr_we[i] == 1'b1) ? spr_high_lq_cnt[i] : lq_cmdq_high_credit_cnt_l2[i];
               lq_cmdq_med_credit_cnt_d[i] <= (spr_cpcr_we[i] == 1'b1) ? spr_med_lq_cnt[i] : lq_cmdq_med_credit_cnt_l2[i];
               lq_cmdq_credit_cnt_minus_1[i] <= 1'b0;
               lq_cmdq_credit_cnt_minus_2[i] <= 1'b0;
               lq_cmdq_credit_cnt_plus_1[i] <= 1'b0;
               lq_cmdq_credit_cnt_zero[i] <= 1'b1;

               if ((lq_iu_credit_free[i] == 1'b1) & (send_instructions[i] == 1'b0 | lq_cmdq_send_cnt[i] == 2'b00))
               begin
                  lq_cmdq_high_credit_cnt_d[i] <= lq_cmdq_high_credit_cnt_plus1[i];
                  lq_cmdq_med_credit_cnt_d[i] <= lq_cmdq_med_credit_cnt_plus1[i];
                  lq_cmdq_credit_cnt_plus_1[i] <= 1'b1;
                  lq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((lq_cmdq_send_cnt[i][0] == 1'b1 ^ lq_cmdq_send_cnt[i][1] == 1'b1) & lq_iu_credit_free[i] == 1'b0) | ((lq_cmdq_send_cnt[i] == 2'b11) & lq_iu_credit_free[i] == 1'b1)))
               begin
                  lq_cmdq_high_credit_cnt_d[i] <= lq_cmdq_high_credit_cnt_minus1[i];
                  lq_cmdq_med_credit_cnt_d[i] <= lq_cmdq_med_credit_cnt_minus1[i];
                  lq_cmdq_credit_cnt_minus_1[i] <= 1'b1;
                  lq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & lq_cmdq_send_cnt[i] == 2'b11 & lq_iu_credit_free[i] == 1'b0)
               begin
                  lq_cmdq_high_credit_cnt_d[i] <= lq_cmdq_high_credit_cnt_minus2[i];
                  lq_cmdq_med_credit_cnt_d[i] <= lq_cmdq_med_credit_cnt_minus2[i];
                  lq_cmdq_credit_cnt_minus_2[i] <= 1'b1;
                  lq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
            end

            always @(*)
            begin: sq_cmdq_credit_proc
               sq_cmdq_high_credit_cnt_d[i] <= (spr_cpcr_we[i] == 1'b1) ? spr_high_sq_cnt[i] : sq_cmdq_high_credit_cnt_l2[i];
               sq_cmdq_med_credit_cnt_d[i] <= (spr_cpcr_we[i] == 1'b1) ? spr_med_sq_cnt[i] : sq_cmdq_med_credit_cnt_l2[i];
               sq_cmdq_credit_cnt_minus_1[i] <= 1'b0;
               sq_cmdq_credit_cnt_minus_2[i] <= 1'b0;
               sq_cmdq_credit_cnt_plus_1[i] <= 1'b0;
               sq_cmdq_credit_cnt_zero[i] <= 1'b1;

               if ((sq_iu_credit_free[i] == 1'b1) & (send_instructions[i] == 1'b0 | sq_cmdq_send_cnt[i] == 2'b00))
               begin
                  sq_cmdq_high_credit_cnt_d[i] <= sq_cmdq_high_credit_cnt_plus1[i];
                  sq_cmdq_med_credit_cnt_d[i] <= sq_cmdq_med_credit_cnt_plus1[i];
                  sq_cmdq_credit_cnt_plus_1[i] <= 1'b1;
                  sq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((sq_cmdq_send_cnt[i][0] == 1'b1 ^ sq_cmdq_send_cnt[i][1] == 1'b1) & sq_iu_credit_free[i] == 1'b0) | ((sq_cmdq_send_cnt[i] == 2'b11) & sq_iu_credit_free[i] == 1'b1)))
               begin
                  sq_cmdq_high_credit_cnt_d[i] <= sq_cmdq_high_credit_cnt_minus1[i];
                  sq_cmdq_med_credit_cnt_d[i] <= sq_cmdq_med_credit_cnt_minus1[i];
                  sq_cmdq_credit_cnt_minus_1[i] <= 1'b1;
                  sq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & sq_cmdq_send_cnt[i] == 2'b11 & sq_iu_credit_free[i] == 1'b0)
               begin
                  sq_cmdq_high_credit_cnt_d[i] <= sq_cmdq_high_credit_cnt_minus2[i];
                  sq_cmdq_med_credit_cnt_d[i] <= sq_cmdq_med_credit_cnt_minus2[i];
                  sq_cmdq_credit_cnt_minus_2[i] <= 1'b1;
                  sq_cmdq_credit_cnt_zero[i] <= 1'b0;
               end
            end

            always @(*)
            begin: fu0_credit_proc
               fu0_high_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu0_cnt[i] : fu0_high_credit_cnt_l2[i];
               fu0_med_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu0_cnt[i] : fu0_med_credit_cnt_l2[i];
               fu0_credit_cnt_minus_1[i] <= 1'b0;
               fu0_credit_cnt_minus_2[i] <= 1'b0;
               fu0_credit_cnt_plus_1[i] <= 1'b0;
               fu0_credit_cnt_zero[i] <= 1'b1;

               if ((axu0_iu_credit_free[i] == 1'b1) & (send_instructions[i] == 1'b0 | fu0_send_cnt[i] == 2'b00))
               begin
                  fu0_high_credit_cnt_d[i] <= fu0_high_credit_cnt_plus1[i];
                  fu0_med_credit_cnt_d[i] <= fu0_med_credit_cnt_plus1[i];
                  fu0_credit_cnt_plus_1[i] <= 1'b1;
                  fu0_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((fu0_send_cnt[i][0] == 1'b1 ^ fu0_send_cnt[i][1] == 1'b1) & axu0_iu_credit_free[i] == 1'b0) | ((fu0_send_cnt[i] == 2'b11) & axu0_iu_credit_free[i] == 1'b1)))
               begin
                  fu0_high_credit_cnt_d[i] <= fu0_high_credit_cnt_minus1[i];
                  fu0_med_credit_cnt_d[i] <= fu0_med_credit_cnt_minus1[i];
                  fu0_credit_cnt_minus_1[i] <= 1'b1;
                  fu0_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & fu0_send_cnt[i] == 2'b11 & axu0_iu_credit_free[i] == 1'b0)
               begin
                  fu0_high_credit_cnt_d[i] <= fu0_high_credit_cnt_minus2[i];
                  fu0_med_credit_cnt_d[i] <= fu0_med_credit_cnt_minus2[i];
                  fu0_credit_cnt_minus_2[i] <= 1'b1;
                  fu0_credit_cnt_zero[i] <= 1'b0;
               end
            end

            always @(*)
            begin: fu1_credit_proc
               fu1_high_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_high_fu1_cnt[i] : fu1_high_credit_cnt_l2[i];
               fu1_med_credit_cnt_d[i] <= ((spr_cpcr_we[i] == 1'b1) | (&cp_flush_l2 == 1'b1)) ? spr_med_fu1_cnt[i] : fu1_med_credit_cnt_l2[i];
               fu1_credit_cnt_minus_1[i] <= 1'b0;
               fu1_credit_cnt_minus_2[i] <= 1'b0;
               fu1_credit_cnt_plus_1[i] <= 1'b0;
               fu1_credit_cnt_zero[i] <= 1'b1;

               if ((axu1_iu_credit_free[i] == 1'b1) & (send_instructions[i] == 1'b0 | fu1_send_cnt[i] == 2'b00))
               begin
                  fu1_high_credit_cnt_d[i] <= fu1_high_credit_cnt_plus1[i];
                  fu1_med_credit_cnt_d[i] <= fu1_med_credit_cnt_plus1[i];
                  fu1_credit_cnt_plus_1[i] <= 1'b1;
                  fu1_credit_cnt_zero[i] <= 1'b0;
               end
               if ((send_instructions[i] == 1'b1) & (((fu1_send_cnt[i][0] == 1'b1 ^ fu1_send_cnt[i][1] == 1'b1) & axu1_iu_credit_free[i] == 1'b0) | ((fu1_send_cnt[i] == 2'b11) & axu1_iu_credit_free[i] == 1'b1)))
               begin
                  fu1_high_credit_cnt_d[i] <= fu1_high_credit_cnt_minus1[i];
                  fu1_med_credit_cnt_d[i] <= fu1_med_credit_cnt_minus1[i];
                  fu1_credit_cnt_minus_1[i] <= 1'b1;
                  fu1_credit_cnt_zero[i] <= 1'b0;
               end
               if (send_instructions[i] == 1'b1 & fu1_send_cnt[i] == 2'b11 & axu1_iu_credit_free[i] == 1'b0)
               begin
                  fu1_high_credit_cnt_d[i] <= fu1_high_credit_cnt_minus2[i];
                  fu1_med_credit_cnt_d[i] <= fu1_med_credit_cnt_minus2[i];
                  fu1_credit_cnt_minus_2[i] <= 1'b1;
                  fu1_credit_cnt_zero[i] <= 1'b0;
               end
            end
         end
      end
   endgenerate

`ifdef THREADS1
   always @(*)
   begin: thread1_credit_proc
      fx0_credit_cnt_minus_1[1] <= 1'b0;
      fx0_credit_cnt_minus_2[1] <= 1'b0;
      fx0_credit_cnt_plus_1[1] <= 1'b0;
      fx0_credit_cnt_zero[1] <= 1'b1;
      fx1_credit_cnt_minus_1[1] <= 1'b0;
      fx1_credit_cnt_minus_2[1] <= 1'b0;
      fx1_credit_cnt_plus_1[1] <= 1'b0;
      fx1_credit_cnt_zero[1] <= 1'b1;
      lq_cmdq_credit_cnt_minus_1[1] <= 1'b0;
      lq_cmdq_credit_cnt_minus_2[1] <= 1'b0;
      lq_cmdq_credit_cnt_plus_1[1] <= 1'b0;
      lq_cmdq_credit_cnt_zero[1] <= 1'b1;
      sq_cmdq_credit_cnt_minus_1[1] <= 1'b0;
      sq_cmdq_credit_cnt_minus_2[1] <= 1'b0;
      sq_cmdq_credit_cnt_plus_1[1] <= 1'b0;
      sq_cmdq_credit_cnt_zero[1] <= 1'b1;
      fu0_credit_cnt_minus_1[1] <= 1'b0;
      fu0_credit_cnt_minus_2[1] <= 1'b0;
      fu0_credit_cnt_plus_1[1] <= 1'b0;
      fu0_credit_cnt_zero[1] <= 1'b1;
      fu1_credit_cnt_minus_1[1] <= 1'b0;
      fu1_credit_cnt_minus_2[1] <= 1'b0;
      fu1_credit_cnt_plus_1[1] <= 1'b0;
      fu1_credit_cnt_zero[1] <= 1'b1;
   end
`endif

   always @(*)
   begin: fx0_total_credit_proc

      fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1 | &cp_flush_l2 == 1'b1)
         fx0_total_credit_cnt_d <= spr_cpcr0_fx0_cnt;
      else
      begin
         if(fx0_credit_cnt_minus_2[0] & fx0_credit_cnt_minus_2[1])
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 - value_4[27:31];
         if((fx0_credit_cnt_minus_2[0] & fx0_credit_cnt_minus_1[1]) | (fx0_credit_cnt_minus_1[0] & fx0_credit_cnt_minus_2[1]))
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 - value_3[27:31];
         if((fx0_credit_cnt_minus_2[0] & fx0_credit_cnt_zero[1]) | (fx0_credit_cnt_minus_1[0] & fx0_credit_cnt_minus_1[1]) | (fx0_credit_cnt_zero[0] & fx0_credit_cnt_minus_2[1]))
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 - value_2[27:31];
         if((fx0_credit_cnt_minus_2[0] & fx0_credit_cnt_plus_1[1]) | (fx0_credit_cnt_minus_1[0] & fx0_credit_cnt_zero[1]) | (fx0_credit_cnt_zero[0] & fx0_credit_cnt_minus_1[1]) | (fx0_credit_cnt_plus_1[0] & fx0_credit_cnt_minus_2[1]))
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 - value_1[27:31];
         if((fx0_credit_cnt_zero[0] & fx0_credit_cnt_plus_1[1]) | (fx0_credit_cnt_plus_1[0] & fx0_credit_cnt_zero[1]))
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 + value_1[27:31];
         if(fx0_credit_cnt_plus_1[0] & fx0_credit_cnt_plus_1[1])
            fx0_total_credit_cnt_d <= fx0_total_credit_cnt_l2 + value_2[27:31];
      end
   end

   always @(*)
   begin: fx1_total_credit_proc

      fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1 | &cp_flush_l2 == 1'b1)
         fx1_total_credit_cnt_d <= spr_cpcr0_fx1_cnt;
      else
      begin
         if(fx1_credit_cnt_minus_2[0] & fx1_credit_cnt_minus_2[1])
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 - value_4[27:31];
         if((fx1_credit_cnt_minus_2[0] & fx1_credit_cnt_minus_1[1]) | (fx1_credit_cnt_minus_1[0] & fx1_credit_cnt_minus_2[1]))
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 - value_3[27:31];
         if((fx1_credit_cnt_minus_2[0] & fx1_credit_cnt_zero[1]) | (fx1_credit_cnt_minus_1[0] & fx1_credit_cnt_minus_1[1]) | (fx1_credit_cnt_zero[0] & fx1_credit_cnt_minus_2[1]))
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 - value_2[27:31];
         if((fx1_credit_cnt_minus_2[0] & fx1_credit_cnt_plus_1[1]) | (fx1_credit_cnt_minus_1[0] & fx1_credit_cnt_zero[1]) | (fx1_credit_cnt_zero[0] & fx1_credit_cnt_minus_1[1]) | (fx1_credit_cnt_plus_1[0] & fx1_credit_cnt_minus_2[1]))
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 - value_1[27:31];
         if((fx1_credit_cnt_zero[0] & fx1_credit_cnt_plus_1[1]) | (fx1_credit_cnt_plus_1[0] & fx1_credit_cnt_zero[1]))
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 + value_1[27:31];
         if(fx1_credit_cnt_plus_1[0] & fx1_credit_cnt_plus_1[1])
            fx1_total_credit_cnt_d <= fx1_total_credit_cnt_l2 + value_2[27:31];
      end
   end

   always @(*)
   begin: lq_cmdq_total_credit_proc

      lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1)
         lq_cmdq_total_credit_cnt_d <= spr_cpcr0_lq_cnt;
      else
      begin
         if(lq_cmdq_credit_cnt_minus_2[0] & lq_cmdq_credit_cnt_minus_2[1])
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 - value_4[27:31];
         if((lq_cmdq_credit_cnt_minus_2[0] & lq_cmdq_credit_cnt_minus_1[1]) | (lq_cmdq_credit_cnt_minus_1[0] & lq_cmdq_credit_cnt_minus_2[1]))
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 - value_3[27:31];
         if((lq_cmdq_credit_cnt_minus_2[0] & lq_cmdq_credit_cnt_zero[1]) | (lq_cmdq_credit_cnt_minus_1[0] & lq_cmdq_credit_cnt_minus_1[1]) | (lq_cmdq_credit_cnt_zero[0] &    lq_cmdq_credit_cnt_minus_2[1]))
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 - value_2[27:31];
         if((lq_cmdq_credit_cnt_minus_2[0] & lq_cmdq_credit_cnt_plus_1[1]) | (lq_cmdq_credit_cnt_minus_1[0] & lq_cmdq_credit_cnt_zero[1]) | (lq_cmdq_credit_cnt_zero[0] & lq_cmdq_credit_cnt_minus_1[1]) |
            (lq_cmdq_credit_cnt_plus_1[0] & lq_cmdq_credit_cnt_minus_2[1]))
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 - value_1[27:31];
         if((lq_cmdq_credit_cnt_zero[0] & lq_cmdq_credit_cnt_plus_1[1]) | (lq_cmdq_credit_cnt_plus_1[0] & lq_cmdq_credit_cnt_zero[1]))
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 + value_1[27:31];
         if(lq_cmdq_credit_cnt_plus_1[0] & lq_cmdq_credit_cnt_plus_1[1])
            lq_cmdq_total_credit_cnt_d <= lq_cmdq_total_credit_cnt_l2 + value_2[27:31];
      end
   end

   always @(*)
   begin: sq_cmdq_total_credit_proc

      sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1)
         sq_cmdq_total_credit_cnt_d <= spr_cpcr0_sq_cnt;
      else
      begin
         if(sq_cmdq_credit_cnt_minus_2[0] & sq_cmdq_credit_cnt_minus_2[1])
            sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 - value_4[27:31];
         if((sq_cmdq_credit_cnt_minus_2[0] & sq_cmdq_credit_cnt_minus_1[1]) | (sq_cmdq_credit_cnt_minus_1[0] & sq_cmdq_credit_cnt_minus_2[1]))
            sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 - value_3[27:31];
         if((sq_cmdq_credit_cnt_minus_2[0] & sq_cmdq_credit_cnt_zero[1]) | (sq_cmdq_credit_cnt_minus_1[0] & sq_cmdq_credit_cnt_minus_1[1]) |
            (sq_cmdq_credit_cnt_zero[0] & sq_cmdq_credit_cnt_minus_2[1]))
            sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 - value_2[27:31];
         if((sq_cmdq_credit_cnt_minus_2[0] & sq_cmdq_credit_cnt_plus_1[1]) | (sq_cmdq_credit_cnt_minus_1[0] & sq_cmdq_credit_cnt_zero[1]) |
            (sq_cmdq_credit_cnt_zero[0] & sq_cmdq_credit_cnt_minus_1[1]) | (sq_cmdq_credit_cnt_plus_1[0] & sq_cmdq_credit_cnt_minus_2[1]))
            sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 - value_1[27:31];
         if((sq_cmdq_credit_cnt_zero[0] & sq_cmdq_credit_cnt_plus_1[1]) | (sq_cmdq_credit_cnt_plus_1[0] & sq_cmdq_credit_cnt_zero[1]))
            sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 + value_1[27:31];
         if(sq_cmdq_credit_cnt_plus_1[0] & sq_cmdq_credit_cnt_plus_1[1])
             sq_cmdq_total_credit_cnt_d <= sq_cmdq_total_credit_cnt_l2 + value_2[27:31];
      end
   end

   always @(*)
   begin: fu0_total_credit_proc

      fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1 | &cp_flush_l2 == 1'b1)
         fu0_total_credit_cnt_d <= spr_cpcr1_fu0_cnt;
      else
      begin
         if(fu0_credit_cnt_minus_2[0] & fu0_credit_cnt_minus_2[1])
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 - value_4[27:31];
         if((fu0_credit_cnt_minus_2[0] & fu0_credit_cnt_minus_1[1]) | (fu0_credit_cnt_minus_1[0] & fu0_credit_cnt_minus_2[1]))
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 - value_3[27:31];
         if((fu0_credit_cnt_minus_2[0] & fu0_credit_cnt_zero[1]) | (fu0_credit_cnt_minus_1[0] & fu0_credit_cnt_minus_1[1]) | (fu0_credit_cnt_zero[0] & fu0_credit_cnt_minus_2[1]))
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 - value_2[27:31];
         if((fu0_credit_cnt_minus_2[0] & fu0_credit_cnt_plus_1[1]) | (fu0_credit_cnt_minus_1[0] & fu0_credit_cnt_zero[1]) | (fu0_credit_cnt_zero[0] & fu0_credit_cnt_minus_1[1]) | (fu0_credit_cnt_plus_1[0] & fu0_credit_cnt_minus_2[1]))
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 - value_1[27:31];
         if((fu0_credit_cnt_zero[0] & fu0_credit_cnt_plus_1[1]) | (fu0_credit_cnt_plus_1[0] & fu0_credit_cnt_zero[1]))
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 + value_1[27:31];
         if(fu0_credit_cnt_plus_1[0] & fu0_credit_cnt_plus_1[1])
            fu0_total_credit_cnt_d <= fu0_total_credit_cnt_l2 + value_2[27:31];
      end
   end

   always @(*)
   begin: fu1_total_credit_proc

      fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2;

      if (|spr_cpcr_we == 1'b1 | &cp_flush_l2 == 1'b1)
         fu1_total_credit_cnt_d <= spr_cpcr1_fu1_cnt;
      else
      begin
         if(fu1_credit_cnt_minus_2[0] & fu1_credit_cnt_minus_2[1])
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 - value_4[27:31];
         if((fu1_credit_cnt_minus_2[0] & fu1_credit_cnt_minus_1[1]) | (fu1_credit_cnt_minus_1[0] & fu1_credit_cnt_minus_2[1]))
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 - value_3[27:31];
         if((fu1_credit_cnt_minus_2[0] & fu1_credit_cnt_zero[1]) | (fu1_credit_cnt_minus_1[0] & fu1_credit_cnt_minus_1[1]) | (fu1_credit_cnt_zero[0] & fu1_credit_cnt_minus_2[1]))
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 - value_2[27:31];
         if((fu1_credit_cnt_minus_2[0] & fu1_credit_cnt_plus_1[1]) | (fu1_credit_cnt_minus_1[0] & fu1_credit_cnt_zero[1]) | (fu1_credit_cnt_zero[0] & fu1_credit_cnt_minus_1[1]) | (fu1_credit_cnt_plus_1[0] & fu1_credit_cnt_minus_2[1]))
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 - value_1[27:31];
         if((fu1_credit_cnt_zero[0] & fu1_credit_cnt_plus_1[1]) | (fu1_credit_cnt_plus_1[0] & fu1_credit_cnt_zero[1]))
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 + value_1[27:31];
         if(fu1_credit_cnt_plus_1[0] & fu1_credit_cnt_plus_1[1])
            fu1_total_credit_cnt_d <= fu1_total_credit_cnt_l2 + value_2[27:31];
      end
   end

assign iu_xu_credits_returned_d = (fx0_total_credit_cnt_l2     == spr_cpcr0_fx0_cnt) &
                                  (fx1_total_credit_cnt_l2     == spr_cpcr0_fx1_cnt) &
                                  (lq_cmdq_total_credit_cnt_l2 == spr_cpcr0_lq_cnt ) &
                                  (sq_cmdq_total_credit_cnt_l2 == spr_cpcr0_sq_cnt ) &
                                  (fu0_total_credit_cnt_l2     == spr_cpcr1_fu0_cnt) &
                                  (fu1_total_credit_cnt_l2     == spr_cpcr1_fu1_cnt) ;

assign iu_xu_credits_returned = iu_xu_credits_returned_l2;

`ifdef THREADS1
   assign total_pri_mask_d[0] = (spr_high_pri_mask[0] | spr_med_pri_mask[0]);
   assign high_pri_mask_d[0] = 1'b0;
   assign med_pri_mask_d[0] = (~spr_high_pri_mask[0] & ~spr_med_pri_mask[0] & low_pri_en[0]);
   assign low_pri_mask_d[0] = spr_high_pri_mask[0] | spr_med_pri_mask[0] | (~spr_high_pri_mask[0] & ~spr_med_pri_mask[0] & low_pri_en[0]);
`endif
`ifndef THREADS1
   assign total_pri_mask_d[0] = (spr_high_pri_mask[0] | spr_med_pri_mask[0]) & ~xu_iu_run_thread_l2[1];
   assign high_pri_mask_d[0] = spr_high_pri_mask[0] & xu_iu_run_thread_l2[1];
   assign med_pri_mask_d[0] = (~spr_high_pri_mask[0] & ~spr_med_pri_mask[0] & low_pri_en[0]) | (spr_med_pri_mask[0] & xu_iu_run_thread_l2[1]);
   assign low_pri_mask_d[0] = spr_high_pri_mask[0] | spr_med_pri_mask[0] | (~spr_high_pri_mask[0] & ~spr_med_pri_mask[0] & low_pri_en[0]);

   assign total_pri_mask_d[1] = (spr_high_pri_mask[1] | spr_med_pri_mask[1]) & ~xu_iu_run_thread_l2[0];
   assign high_pri_mask_d[1] = spr_high_pri_mask[1] & xu_iu_run_thread_l2[0];
   assign med_pri_mask_d[1] = (~spr_high_pri_mask[1] & ~spr_med_pri_mask[1] & low_pri_en[1]) | (spr_med_pri_mask[1] & xu_iu_run_thread_l2[0]);
   assign low_pri_mask_d[1] = spr_high_pri_mask[1] | spr_med_pri_mask[1] | (~spr_high_pri_mask[1] & ~spr_med_pri_mask[1] & low_pri_en[1]);
`endif

   generate
      begin : pri_mask
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : pri_mask_set
            assign low_pri_max_d[i] = spr_low_pri_count[i];

            assign low_pri_cnt_d[i] = (iu_rv_iu6_i0_vld_int[i]) ? {8{1'b0}} :
                                      low_pri_cnt_l2[i] + value_1[24:31];

            assign low_pri_cnt_act[i] = ((low_pri_cnt_l2[i][0:5] != low_pri_max_l2[i]) |
                                        iu_rv_iu6_i0_vld_int[i]) & ~spr_high_pri_mask[i] & ~spr_med_pri_mask[i];

            assign low_pri_en[i] = (low_pri_max_l2[i] == low_pri_cnt_l2[i][0:5]) & ~iu_rv_iu6_i0_vld_int[i] & ~spr_high_pri_mask[i] & ~spr_med_pri_mask[i];
         end
      end
   endgenerate

   always @(*)
   begin: dual_iss_fx0_proc
      dual_issue_use_fx0_d <= 2'b11;
      if (`FXU1_ENABLE == 1 & fx0_total_credit_cnt_l2 < fx1_total_credit_cnt_l2)
         dual_issue_use_fx0_d <= 2'b00;
      if (`FXU1_ENABLE == 1 & fx0_total_credit_cnt_l2 == fx1_total_credit_cnt_l2)
         dual_issue_use_fx0_d <= 2'b10;
   end


   assign iu_rv_iu6_i0_vld_int = send_instructions & frn_fdis_iu6_i0_vld;
   assign iu_rv_iu6_i1_vld_int = send_instructions & frn_fdis_iu6_i1_vld;

   assign iu_rv_iu6_t0_i0_vld = iu_rv_iu6_i0_vld_int[0];
   assign iu_rv_iu6_t0_i0_act = frn_fdis_iu6_i0_vld[0];
   assign iu_rv_iu6_t0_i0_itag = frn_fdis_iu6_i0_itag[0];
   assign iu_rv_iu6_t0_i0_rte_lq = frn_fdis_iu6_i0_rte_lq[0];
   assign iu_rv_iu6_t0_i0_rte_sq = frn_fdis_iu6_i0_rte_sq[0];
   assign iu_rv_iu6_t0_i0_rte_fx0 = fx0_send_cnt[0][0] & frn_fdis_iu6_i0_rte_fx0[0];
   assign iu_rv_iu6_t0_i0_rte_fx1 = fx1_send_cnt[0][0] & frn_fdis_iu6_i0_rte_fx1[0];
   assign iu_rv_iu6_t0_i0_rte_axu0 = frn_fdis_iu6_i0_rte_axu0[0];
   assign iu_rv_iu6_t0_i0_rte_axu1 = frn_fdis_iu6_i0_rte_axu1[0];
   assign iu_rv_iu6_t0_i0_ucode = frn_fdis_iu6_i0_ucode[0];
   assign iu_rv_iu6_t0_i0_ucode_cnt = frn_fdis_iu6_i0_ucode_cnt[0];
   assign iu_rv_iu6_t0_i0_2ucode = frn_fdis_iu6_i0_2ucode[0];
   assign iu_rv_iu6_t0_i0_fuse_nop = frn_fdis_iu6_i0_fuse_nop[0];
   assign iu_rv_iu6_t0_i0_valop = frn_fdis_iu6_i0_valop[0];
   assign iu_rv_iu6_t0_i0_ord = frn_fdis_iu6_i0_ord[0];
   assign iu_rv_iu6_t0_i0_cord = frn_fdis_iu6_i0_cord[0];
   assign iu_rv_iu6_t0_i0_error = frn_fdis_iu6_i0_error[0];
   assign iu_rv_iu6_t0_i0_btb_entry = frn_fdis_iu6_i0_btb_entry[0];
   assign iu_rv_iu6_t0_i0_btb_hist = frn_fdis_iu6_i0_btb_hist[0];
   assign iu_rv_iu6_t0_i0_bta_val = frn_fdis_iu6_i0_bta_val[0];
   assign iu_rv_iu6_t0_i0_fusion = frn_fdis_iu6_i0_fusion[0];
   assign iu_rv_iu6_t0_i0_spec = frn_fdis_iu6_i0_spec[0];
   assign iu_rv_iu6_t0_i0_type_fp = frn_fdis_iu6_i0_type_fp[0];
   assign iu_rv_iu6_t0_i0_type_ap = frn_fdis_iu6_i0_type_ap[0];
   assign iu_rv_iu6_t0_i0_type_spv = frn_fdis_iu6_i0_type_spv[0];
   assign iu_rv_iu6_t0_i0_type_st = frn_fdis_iu6_i0_type_st[0];
   assign iu_rv_iu6_t0_i0_async_block = frn_fdis_iu6_i0_async_block[0];
   assign iu_rv_iu6_t0_i0_np1_flush = frn_fdis_iu6_i0_np1_flush[0];
   assign iu_rv_iu6_t0_i0_isram = frn_fdis_iu6_i0_isram[0];
   assign iu_rv_iu6_t0_i0_isload = frn_fdis_iu6_i0_isload[0];
   assign iu_rv_iu6_t0_i0_isstore = frn_fdis_iu6_i0_isstore[0];
   assign iu_rv_iu6_t0_i0_instr = frn_fdis_iu6_i0_instr[0];
   assign iu_rv_iu6_t0_i0_ifar = frn_fdis_iu6_i0_ifar[0];
   assign iu_rv_iu6_t0_i0_bta = frn_fdis_iu6_i0_bta[0];
   assign iu_rv_iu6_t0_i0_br_pred = frn_fdis_iu6_i0_br_pred[0];
   assign iu_rv_iu6_t0_i0_bh_update = frn_fdis_iu6_i0_bh_update[0];
   assign iu_rv_iu6_t0_i0_bh0_hist = frn_fdis_iu6_i0_bh0_hist[0];
   assign iu_rv_iu6_t0_i0_bh1_hist = frn_fdis_iu6_i0_bh1_hist[0];
   assign iu_rv_iu6_t0_i0_bh2_hist = frn_fdis_iu6_i0_bh2_hist[0];
   assign iu_rv_iu6_t0_i0_gshare = frn_fdis_iu6_i0_gshare[0];
   assign iu_rv_iu6_t0_i0_ls_ptr = frn_fdis_iu6_i0_ls_ptr[0];
   assign iu_rv_iu6_t0_i0_match = frn_fdis_iu6_i0_match[0];
   assign iu_rv_iu6_t0_i0_ilat = frn_fdis_iu6_i0_ilat[0];
   assign iu_rv_iu6_t0_i0_t1_v = frn_fdis_iu6_i0_t1_v[0];
   assign iu_rv_iu6_t0_i0_t1_t = frn_fdis_iu6_i0_t1_t[0];
   assign iu_rv_iu6_t0_i0_t1_a = frn_fdis_iu6_i0_t1_a[0];
   assign iu_rv_iu6_t0_i0_t1_p = frn_fdis_iu6_i0_t1_p[0];
   assign iu_rv_iu6_t0_i0_t2_v = frn_fdis_iu6_i0_t2_v[0];
   assign iu_rv_iu6_t0_i0_t2_a = frn_fdis_iu6_i0_t2_a[0];
   assign iu_rv_iu6_t0_i0_t2_p = frn_fdis_iu6_i0_t2_p[0];
   assign iu_rv_iu6_t0_i0_t2_t = frn_fdis_iu6_i0_t2_t[0];
   assign iu_rv_iu6_t0_i0_t3_v = frn_fdis_iu6_i0_t3_v[0];
   assign iu_rv_iu6_t0_i0_t3_a = frn_fdis_iu6_i0_t3_a[0];
   assign iu_rv_iu6_t0_i0_t3_p = frn_fdis_iu6_i0_t3_p[0];
   assign iu_rv_iu6_t0_i0_t3_t = frn_fdis_iu6_i0_t3_t[0];
   assign iu_rv_iu6_t0_i0_s1_v = frn_fdis_iu6_i0_s1_v[0];
   assign iu_rv_iu6_t0_i0_s1_a = frn_fdis_iu6_i0_s1_a[0];
   assign iu_rv_iu6_t0_i0_s1_p = frn_fdis_iu6_i0_s1_p[0];
   assign iu_rv_iu6_t0_i0_s1_itag = frn_fdis_iu6_i0_s1_itag[0];
   assign iu_rv_iu6_t0_i0_s1_t = frn_fdis_iu6_i0_s1_t[0];
   assign iu_rv_iu6_t0_i0_s2_v = frn_fdis_iu6_i0_s2_v[0];
   assign iu_rv_iu6_t0_i0_s2_a = frn_fdis_iu6_i0_s2_a[0];
   assign iu_rv_iu6_t0_i0_s2_p = frn_fdis_iu6_i0_s2_p[0];
   assign iu_rv_iu6_t0_i0_s2_itag = frn_fdis_iu6_i0_s2_itag[0];
   assign iu_rv_iu6_t0_i0_s2_t = frn_fdis_iu6_i0_s2_t[0];
   assign iu_rv_iu6_t0_i0_s3_v = frn_fdis_iu6_i0_s3_v[0];
   assign iu_rv_iu6_t0_i0_s3_a = frn_fdis_iu6_i0_s3_a[0];
   assign iu_rv_iu6_t0_i0_s3_p = frn_fdis_iu6_i0_s3_p[0];
   assign iu_rv_iu6_t0_i0_s3_itag = frn_fdis_iu6_i0_s3_itag[0];
   assign iu_rv_iu6_t0_i0_s3_t = frn_fdis_iu6_i0_s3_t[0];
   assign iu_rv_iu6_t0_i1_vld = iu_rv_iu6_i1_vld_int[0];
   assign iu_rv_iu6_t0_i1_act = frn_fdis_iu6_i1_vld[0];
   assign iu_rv_iu6_t0_i1_itag = frn_fdis_iu6_i1_itag[0];
   assign iu_rv_iu6_t0_i1_rte_lq = frn_fdis_iu6_i1_rte_lq[0];
   assign iu_rv_iu6_t0_i1_rte_sq = frn_fdis_iu6_i1_rte_sq[0];
   assign iu_rv_iu6_t0_i1_rte_fx0 = fx0_send_cnt[0][1] & frn_fdis_iu6_i1_rte_fx0[0];
   assign iu_rv_iu6_t0_i1_rte_fx1 = fx1_send_cnt[0][1] & frn_fdis_iu6_i1_rte_fx1[0];
   assign iu_rv_iu6_t0_i1_rte_axu0 = frn_fdis_iu6_i1_rte_axu0[0];
   assign iu_rv_iu6_t0_i1_rte_axu1 = frn_fdis_iu6_i1_rte_axu1[0];
   assign iu_rv_iu6_t0_i1_ucode = frn_fdis_iu6_i1_ucode[0];
   assign iu_rv_iu6_t0_i1_ucode_cnt = frn_fdis_iu6_i1_ucode_cnt[0];
   assign iu_rv_iu6_t0_i1_fuse_nop = frn_fdis_iu6_i1_fuse_nop[0];
   assign iu_rv_iu6_t0_i1_valop = frn_fdis_iu6_i1_valop[0];
   assign iu_rv_iu6_t0_i1_ord = frn_fdis_iu6_i1_ord[0];
   assign iu_rv_iu6_t0_i1_cord = frn_fdis_iu6_i1_cord[0];
   assign iu_rv_iu6_t0_i1_error = frn_fdis_iu6_i1_error[0];
   assign iu_rv_iu6_t0_i1_btb_entry = frn_fdis_iu6_i1_btb_entry[0];
   assign iu_rv_iu6_t0_i1_btb_hist = frn_fdis_iu6_i1_btb_hist[0];
   assign iu_rv_iu6_t0_i1_bta_val = frn_fdis_iu6_i1_bta_val[0];
   assign iu_rv_iu6_t0_i1_fusion = frn_fdis_iu6_i1_fusion[0];
   assign iu_rv_iu6_t0_i1_spec = frn_fdis_iu6_i1_spec[0];
   assign iu_rv_iu6_t0_i1_type_fp = frn_fdis_iu6_i1_type_fp[0];
   assign iu_rv_iu6_t0_i1_type_ap = frn_fdis_iu6_i1_type_ap[0];
   assign iu_rv_iu6_t0_i1_type_spv = frn_fdis_iu6_i1_type_spv[0];
   assign iu_rv_iu6_t0_i1_type_st = frn_fdis_iu6_i1_type_st[0];
   assign iu_rv_iu6_t0_i1_async_block = frn_fdis_iu6_i1_async_block[0];
   assign iu_rv_iu6_t0_i1_np1_flush = frn_fdis_iu6_i1_np1_flush[0];
   assign iu_rv_iu6_t0_i1_isram = frn_fdis_iu6_i1_isram[0];
   assign iu_rv_iu6_t0_i1_isload = frn_fdis_iu6_i1_isload[0];
   assign iu_rv_iu6_t0_i1_isstore = frn_fdis_iu6_i1_isstore[0];
   assign iu_rv_iu6_t0_i1_instr = frn_fdis_iu6_i1_instr[0];
   assign iu_rv_iu6_t0_i1_ifar = frn_fdis_iu6_i1_ifar[0];
   assign iu_rv_iu6_t0_i1_bta = frn_fdis_iu6_i1_bta[0];
   assign iu_rv_iu6_t0_i1_br_pred = frn_fdis_iu6_i1_br_pred[0];
   assign iu_rv_iu6_t0_i1_bh_update = frn_fdis_iu6_i1_bh_update[0];
   assign iu_rv_iu6_t0_i1_bh0_hist = frn_fdis_iu6_i1_bh0_hist[0];
   assign iu_rv_iu6_t0_i1_bh1_hist = frn_fdis_iu6_i1_bh1_hist[0];
   assign iu_rv_iu6_t0_i1_bh2_hist = frn_fdis_iu6_i1_bh2_hist[0];
   assign iu_rv_iu6_t0_i1_gshare = frn_fdis_iu6_i1_gshare[0];
   assign iu_rv_iu6_t0_i1_ls_ptr = frn_fdis_iu6_i1_ls_ptr[0];
   assign iu_rv_iu6_t0_i1_match = frn_fdis_iu6_i1_match[0];
   assign iu_rv_iu6_t0_i1_ilat = frn_fdis_iu6_i1_ilat[0];
   assign iu_rv_iu6_t0_i1_t1_v = frn_fdis_iu6_i1_t1_v[0];
   assign iu_rv_iu6_t0_i1_t1_t = frn_fdis_iu6_i1_t1_t[0];
   assign iu_rv_iu6_t0_i1_t1_a = frn_fdis_iu6_i1_t1_a[0];
   assign iu_rv_iu6_t0_i1_t1_p = frn_fdis_iu6_i1_t1_p[0];
   assign iu_rv_iu6_t0_i1_t2_v = frn_fdis_iu6_i1_t2_v[0];
   assign iu_rv_iu6_t0_i1_t2_a = frn_fdis_iu6_i1_t2_a[0];
   assign iu_rv_iu6_t0_i1_t2_p = frn_fdis_iu6_i1_t2_p[0];
   assign iu_rv_iu6_t0_i1_t2_t = frn_fdis_iu6_i1_t2_t[0];
   assign iu_rv_iu6_t0_i1_t3_v = frn_fdis_iu6_i1_t3_v[0];
   assign iu_rv_iu6_t0_i1_t3_a = frn_fdis_iu6_i1_t3_a[0];
   assign iu_rv_iu6_t0_i1_t3_p = frn_fdis_iu6_i1_t3_p[0];
   assign iu_rv_iu6_t0_i1_t3_t = frn_fdis_iu6_i1_t3_t[0];
   assign iu_rv_iu6_t0_i1_s1_v = frn_fdis_iu6_i1_s1_v[0];
   assign iu_rv_iu6_t0_i1_s1_a = frn_fdis_iu6_i1_s1_a[0];
   assign iu_rv_iu6_t0_i1_s1_p = frn_fdis_iu6_i1_s1_p[0];
   assign iu_rv_iu6_t0_i1_s1_itag = frn_fdis_iu6_i1_s1_itag[0];
   assign iu_rv_iu6_t0_i1_s1_t = frn_fdis_iu6_i1_s1_t[0];
   assign iu_rv_iu6_t0_i1_s1_dep_hit = frn_fdis_iu6_i1_s1_dep_hit[0];
   assign iu_rv_iu6_t0_i1_s2_v = frn_fdis_iu6_i1_s2_v[0];
   assign iu_rv_iu6_t0_i1_s2_a = frn_fdis_iu6_i1_s2_a[0];
   assign iu_rv_iu6_t0_i1_s2_p = frn_fdis_iu6_i1_s2_p[0];
   assign iu_rv_iu6_t0_i1_s2_itag = frn_fdis_iu6_i1_s2_itag[0];
   assign iu_rv_iu6_t0_i1_s2_t = frn_fdis_iu6_i1_s2_t[0];
   assign iu_rv_iu6_t0_i1_s2_dep_hit = frn_fdis_iu6_i1_s2_dep_hit[0];
   assign iu_rv_iu6_t0_i1_s3_v = frn_fdis_iu6_i1_s3_v[0];
   assign iu_rv_iu6_t0_i1_s3_a = frn_fdis_iu6_i1_s3_a[0];
   assign iu_rv_iu6_t0_i1_s3_p = frn_fdis_iu6_i1_s3_p[0];
   assign iu_rv_iu6_t0_i1_s3_itag = frn_fdis_iu6_i1_s3_itag[0];
   assign iu_rv_iu6_t0_i1_s3_t = frn_fdis_iu6_i1_s3_t[0];
   assign iu_rv_iu6_t0_i1_s3_dep_hit = frn_fdis_iu6_i1_s3_dep_hit[0];

`ifndef THREADS1
   assign iu_rv_iu6_t1_i0_vld = iu_rv_iu6_i0_vld_int[1];
   assign iu_rv_iu6_t1_i0_act = frn_fdis_iu6_i0_vld[1];
   assign iu_rv_iu6_t1_i0_itag = frn_fdis_iu6_i0_itag[1];
   assign iu_rv_iu6_t1_i0_rte_lq = frn_fdis_iu6_i0_rte_lq[1];
   assign iu_rv_iu6_t1_i0_rte_sq = frn_fdis_iu6_i0_rte_sq[1];
   assign iu_rv_iu6_t1_i0_rte_fx0 = fx0_send_cnt[1][0] & frn_fdis_iu6_i0_rte_fx0[1];
   assign iu_rv_iu6_t1_i0_rte_fx1 = fx1_send_cnt[1][0] & frn_fdis_iu6_i0_rte_fx1[1];
   assign iu_rv_iu6_t1_i0_rte_axu0 = frn_fdis_iu6_i0_rte_axu0[1];
   assign iu_rv_iu6_t1_i0_rte_axu1 = frn_fdis_iu6_i0_rte_axu1[1];
   assign iu_rv_iu6_t1_i0_ucode = frn_fdis_iu6_i0_ucode[1];
   assign iu_rv_iu6_t1_i0_ucode_cnt = frn_fdis_iu6_i0_ucode_cnt[1];
   assign iu_rv_iu6_t1_i0_2ucode = frn_fdis_iu6_i0_2ucode[1];
   assign iu_rv_iu6_t1_i0_fuse_nop = frn_fdis_iu6_i0_fuse_nop[1];
   assign iu_rv_iu6_t1_i0_valop = frn_fdis_iu6_i0_valop[1];
   assign iu_rv_iu6_t1_i0_ord = frn_fdis_iu6_i0_ord[1];
   assign iu_rv_iu6_t1_i0_cord = frn_fdis_iu6_i0_cord[1];
   assign iu_rv_iu6_t1_i0_error = frn_fdis_iu6_i0_error[1];
   assign iu_rv_iu6_t1_i0_btb_entry = frn_fdis_iu6_i0_btb_entry[1];
   assign iu_rv_iu6_t1_i0_btb_hist = frn_fdis_iu6_i0_btb_hist[1];
   assign iu_rv_iu6_t1_i0_bta_val = frn_fdis_iu6_i0_bta_val[1];
   assign iu_rv_iu6_t1_i0_fusion = frn_fdis_iu6_i0_fusion[1];
   assign iu_rv_iu6_t1_i0_spec = frn_fdis_iu6_i0_spec[1];
   assign iu_rv_iu6_t1_i0_type_fp = frn_fdis_iu6_i0_type_fp[1];
   assign iu_rv_iu6_t1_i0_type_ap = frn_fdis_iu6_i0_type_ap[1];
   assign iu_rv_iu6_t1_i0_type_spv = frn_fdis_iu6_i0_type_spv[1];
   assign iu_rv_iu6_t1_i0_type_st = frn_fdis_iu6_i0_type_st[1];
   assign iu_rv_iu6_t1_i0_async_block = frn_fdis_iu6_i0_async_block[1];
   assign iu_rv_iu6_t1_i0_np1_flush = frn_fdis_iu6_i0_np1_flush[1];
   assign iu_rv_iu6_t1_i0_isram = frn_fdis_iu6_i0_isram[1];
   assign iu_rv_iu6_t1_i0_isload = frn_fdis_iu6_i0_isload[1];
   assign iu_rv_iu6_t1_i0_isstore = frn_fdis_iu6_i0_isstore[1];
   assign iu_rv_iu6_t1_i0_instr = frn_fdis_iu6_i0_instr[1];
   assign iu_rv_iu6_t1_i0_ifar = frn_fdis_iu6_i0_ifar[1];
   assign iu_rv_iu6_t1_i0_bta = frn_fdis_iu6_i0_bta[1];
   assign iu_rv_iu6_t1_i0_br_pred = frn_fdis_iu6_i0_br_pred[1];
   assign iu_rv_iu6_t1_i0_bh_update = frn_fdis_iu6_i0_bh_update[1];
   assign iu_rv_iu6_t1_i0_bh0_hist = frn_fdis_iu6_i0_bh0_hist[1];
   assign iu_rv_iu6_t1_i0_bh1_hist = frn_fdis_iu6_i0_bh1_hist[1];
   assign iu_rv_iu6_t1_i0_bh2_hist = frn_fdis_iu6_i0_bh2_hist[1];
   assign iu_rv_iu6_t1_i0_gshare = frn_fdis_iu6_i0_gshare[1];
   assign iu_rv_iu6_t1_i0_ls_ptr = frn_fdis_iu6_i0_ls_ptr[1];
   assign iu_rv_iu6_t1_i0_match = frn_fdis_iu6_i0_match[1];
   assign iu_rv_iu6_t1_i0_ilat = frn_fdis_iu6_i0_ilat[1];
   assign iu_rv_iu6_t1_i0_t1_v = frn_fdis_iu6_i0_t1_v[1];
   assign iu_rv_iu6_t1_i0_t1_t = frn_fdis_iu6_i0_t1_t[1];
   assign iu_rv_iu6_t1_i0_t1_a = frn_fdis_iu6_i0_t1_a[1];
   assign iu_rv_iu6_t1_i0_t1_p = frn_fdis_iu6_i0_t1_p[1];
   assign iu_rv_iu6_t1_i0_t2_v = frn_fdis_iu6_i0_t2_v[1];
   assign iu_rv_iu6_t1_i0_t2_a = frn_fdis_iu6_i0_t2_a[1];
   assign iu_rv_iu6_t1_i0_t2_p = frn_fdis_iu6_i0_t2_p[1];
   assign iu_rv_iu6_t1_i0_t2_t = frn_fdis_iu6_i0_t2_t[1];
   assign iu_rv_iu6_t1_i0_t3_v = frn_fdis_iu6_i0_t3_v[1];
   assign iu_rv_iu6_t1_i0_t3_a = frn_fdis_iu6_i0_t3_a[1];
   assign iu_rv_iu6_t1_i0_t3_p = frn_fdis_iu6_i0_t3_p[1];
   assign iu_rv_iu6_t1_i0_t3_t = frn_fdis_iu6_i0_t3_t[1];
   assign iu_rv_iu6_t1_i0_s1_v = frn_fdis_iu6_i0_s1_v[1];
   assign iu_rv_iu6_t1_i0_s1_a = frn_fdis_iu6_i0_s1_a[1];
   assign iu_rv_iu6_t1_i0_s1_p = frn_fdis_iu6_i0_s1_p[1];
   assign iu_rv_iu6_t1_i0_s1_itag = frn_fdis_iu6_i0_s1_itag[1];
   assign iu_rv_iu6_t1_i0_s1_t = frn_fdis_iu6_i0_s1_t[1];
   assign iu_rv_iu6_t1_i0_s2_v = frn_fdis_iu6_i0_s2_v[1];
   assign iu_rv_iu6_t1_i0_s2_a = frn_fdis_iu6_i0_s2_a[1];
   assign iu_rv_iu6_t1_i0_s2_p = frn_fdis_iu6_i0_s2_p[1];
   assign iu_rv_iu6_t1_i0_s2_itag = frn_fdis_iu6_i0_s2_itag[1];
   assign iu_rv_iu6_t1_i0_s2_t = frn_fdis_iu6_i0_s2_t[1];
   assign iu_rv_iu6_t1_i0_s3_v = frn_fdis_iu6_i0_s3_v[1];
   assign iu_rv_iu6_t1_i0_s3_a = frn_fdis_iu6_i0_s3_a[1];
   assign iu_rv_iu6_t1_i0_s3_p = frn_fdis_iu6_i0_s3_p[1];
   assign iu_rv_iu6_t1_i0_s3_itag = frn_fdis_iu6_i0_s3_itag[1];
   assign iu_rv_iu6_t1_i0_s3_t = frn_fdis_iu6_i0_s3_t[1];
   assign iu_rv_iu6_t1_i1_vld = iu_rv_iu6_i1_vld_int[1];
   assign iu_rv_iu6_t1_i1_act = frn_fdis_iu6_i1_vld[1];
   assign iu_rv_iu6_t1_i1_itag = frn_fdis_iu6_i1_itag[1];
   assign iu_rv_iu6_t1_i1_rte_lq = frn_fdis_iu6_i1_rte_lq[1];
   assign iu_rv_iu6_t1_i1_rte_sq = frn_fdis_iu6_i1_rte_sq[1];
   assign iu_rv_iu6_t1_i1_rte_fx0 = fx0_send_cnt[1][1] & frn_fdis_iu6_i1_rte_fx0[1];
   assign iu_rv_iu6_t1_i1_rte_fx1 = fx1_send_cnt[1][1] & frn_fdis_iu6_i1_rte_fx1[1];
   assign iu_rv_iu6_t1_i1_rte_axu0 = frn_fdis_iu6_i1_rte_axu0[1];
   assign iu_rv_iu6_t1_i1_rte_axu1 = frn_fdis_iu6_i1_rte_axu1[1];
   assign iu_rv_iu6_t1_i1_ucode = frn_fdis_iu6_i1_ucode[1];
   assign iu_rv_iu6_t1_i1_ucode_cnt = frn_fdis_iu6_i1_ucode_cnt[1];
   assign iu_rv_iu6_t1_i1_fuse_nop = frn_fdis_iu6_i1_fuse_nop[1];
   assign iu_rv_iu6_t1_i1_valop = frn_fdis_iu6_i1_valop[1];
   assign iu_rv_iu6_t1_i1_ord = frn_fdis_iu6_i1_ord[1];
   assign iu_rv_iu6_t1_i1_cord = frn_fdis_iu6_i1_cord[1];
   assign iu_rv_iu6_t1_i1_error = frn_fdis_iu6_i1_error[1];
   assign iu_rv_iu6_t1_i1_btb_entry = frn_fdis_iu6_i1_btb_entry[1];
   assign iu_rv_iu6_t1_i1_btb_hist = frn_fdis_iu6_i1_btb_hist[1];
   assign iu_rv_iu6_t1_i1_bta_val = frn_fdis_iu6_i1_bta_val[1];
   assign iu_rv_iu6_t1_i1_fusion = frn_fdis_iu6_i1_fusion[1];
   assign iu_rv_iu6_t1_i1_spec = frn_fdis_iu6_i1_spec[1];
   assign iu_rv_iu6_t1_i1_type_fp = frn_fdis_iu6_i1_type_fp[1];
   assign iu_rv_iu6_t1_i1_type_ap = frn_fdis_iu6_i1_type_ap[1];
   assign iu_rv_iu6_t1_i1_type_spv = frn_fdis_iu6_i1_type_spv[1];
   assign iu_rv_iu6_t1_i1_type_st = frn_fdis_iu6_i1_type_st[1];
   assign iu_rv_iu6_t1_i1_async_block = frn_fdis_iu6_i1_async_block[1];
   assign iu_rv_iu6_t1_i1_np1_flush = frn_fdis_iu6_i1_np1_flush[1];
   assign iu_rv_iu6_t1_i1_isram = frn_fdis_iu6_i1_isram[1];
   assign iu_rv_iu6_t1_i1_isload = frn_fdis_iu6_i1_isload[1];
   assign iu_rv_iu6_t1_i1_isstore = frn_fdis_iu6_i1_isstore[1];
   assign iu_rv_iu6_t1_i1_instr = frn_fdis_iu6_i1_instr[1];
   assign iu_rv_iu6_t1_i1_ifar = frn_fdis_iu6_i1_ifar[1];
   assign iu_rv_iu6_t1_i1_bta = frn_fdis_iu6_i1_bta[1];
   assign iu_rv_iu6_t1_i1_br_pred = frn_fdis_iu6_i1_br_pred[1];
   assign iu_rv_iu6_t1_i1_bh_update = frn_fdis_iu6_i1_bh_update[1];
   assign iu_rv_iu6_t1_i1_bh0_hist = frn_fdis_iu6_i1_bh0_hist[1];
   assign iu_rv_iu6_t1_i1_bh1_hist = frn_fdis_iu6_i1_bh1_hist[1];
   assign iu_rv_iu6_t1_i1_bh2_hist = frn_fdis_iu6_i1_bh2_hist[1];
   assign iu_rv_iu6_t1_i1_gshare = frn_fdis_iu6_i1_gshare[1];
   assign iu_rv_iu6_t1_i1_ls_ptr = frn_fdis_iu6_i1_ls_ptr[1];
   assign iu_rv_iu6_t1_i1_match = frn_fdis_iu6_i1_match[1];
   assign iu_rv_iu6_t1_i1_ilat = frn_fdis_iu6_i1_ilat[1];
   assign iu_rv_iu6_t1_i1_t1_v = frn_fdis_iu6_i1_t1_v[1];
   assign iu_rv_iu6_t1_i1_t1_t = frn_fdis_iu6_i1_t1_t[1];
   assign iu_rv_iu6_t1_i1_t1_a = frn_fdis_iu6_i1_t1_a[1];
   assign iu_rv_iu6_t1_i1_t1_p = frn_fdis_iu6_i1_t1_p[1];
   assign iu_rv_iu6_t1_i1_t2_v = frn_fdis_iu6_i1_t2_v[1];
   assign iu_rv_iu6_t1_i1_t2_a = frn_fdis_iu6_i1_t2_a[1];
   assign iu_rv_iu6_t1_i1_t2_p = frn_fdis_iu6_i1_t2_p[1];
   assign iu_rv_iu6_t1_i1_t2_t = frn_fdis_iu6_i1_t2_t[1];
   assign iu_rv_iu6_t1_i1_t3_v = frn_fdis_iu6_i1_t3_v[1];
   assign iu_rv_iu6_t1_i1_t3_a = frn_fdis_iu6_i1_t3_a[1];
   assign iu_rv_iu6_t1_i1_t3_p = frn_fdis_iu6_i1_t3_p[1];
   assign iu_rv_iu6_t1_i1_t3_t = frn_fdis_iu6_i1_t3_t[1];
   assign iu_rv_iu6_t1_i1_s1_v = frn_fdis_iu6_i1_s1_v[1];
   assign iu_rv_iu6_t1_i1_s1_a = frn_fdis_iu6_i1_s1_a[1];
   assign iu_rv_iu6_t1_i1_s1_p = frn_fdis_iu6_i1_s1_p[1];
   assign iu_rv_iu6_t1_i1_s1_itag = frn_fdis_iu6_i1_s1_itag[1];
   assign iu_rv_iu6_t1_i1_s1_t = frn_fdis_iu6_i1_s1_t[1];
   assign iu_rv_iu6_t1_i1_s1_dep_hit = frn_fdis_iu6_i1_s1_dep_hit[1];
   assign iu_rv_iu6_t1_i1_s2_v = frn_fdis_iu6_i1_s2_v[1];
   assign iu_rv_iu6_t1_i1_s2_a = frn_fdis_iu6_i1_s2_a[1];
   assign iu_rv_iu6_t1_i1_s2_p = frn_fdis_iu6_i1_s2_p[1];
   assign iu_rv_iu6_t1_i1_s2_itag = frn_fdis_iu6_i1_s2_itag[1];
   assign iu_rv_iu6_t1_i1_s2_t = frn_fdis_iu6_i1_s2_t[1];
   assign iu_rv_iu6_t1_i1_s2_dep_hit = frn_fdis_iu6_i1_s2_dep_hit[1];
   assign iu_rv_iu6_t1_i1_s3_v = frn_fdis_iu6_i1_s3_v[1];
   assign iu_rv_iu6_t1_i1_s3_a = frn_fdis_iu6_i1_s3_a[1];
   assign iu_rv_iu6_t1_i1_s3_p = frn_fdis_iu6_i1_s3_p[1];
   assign iu_rv_iu6_t1_i1_s3_itag = frn_fdis_iu6_i1_s3_itag[1];
   assign iu_rv_iu6_t1_i1_s3_t = frn_fdis_iu6_i1_s3_t[1];
   assign iu_rv_iu6_t1_i1_s3_dep_hit = frn_fdis_iu6_i1_s3_dep_hit[1];
`endif





   // Perf counters
   generate
      begin : perf_set
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : perf_mask_set
            assign perf_iu6_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~send_instructions[i]);

            assign perf_iu6_dispatch_fx0_d[i][0] = ((iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                   (iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & (iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]);

            assign perf_iu6_dispatch_fx0_d[i][1] = (~(iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & ~(iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                   (~(iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & (iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & ~(iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx0_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx0[i]) & (iu_rv_iu6_i1_vld_int[i] & fx0_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx0[i]) & perf_iu6_dispatch_fx0_l2[i][1]);

            assign perf_iu6_dispatch_fx1_d[i][0] = ((iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                   (iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & (iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]);

            assign perf_iu6_dispatch_fx1_d[i][1] = (~(iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & ~(iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                   (~(iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & (iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]) & ~perf_iu6_dispatch_fx1_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & ~(iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]) & ~perf_iu6_dispatch_fx1_l2[i][1]) |
                                                   ((iu_rv_iu6_i0_vld_int[i] & fx1_send_cnt[i][0] & frn_fdis_iu6_i0_rte_fx1[i]) & (iu_rv_iu6_i1_vld_int[i] & fx1_send_cnt[i][1] & frn_fdis_iu6_i1_rte_fx1[i]) & perf_iu6_dispatch_fx1_l2[i][1]);

            assign perf_iu6_dispatch_lq_d[i][0] = ((iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                  ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                  (iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]);

            assign perf_iu6_dispatch_lq_d[i][1] = (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                  (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                  ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                  ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_lq[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_lq[i]) & perf_iu6_dispatch_fx0_l2[i][1]);

            assign perf_iu6_dispatch_axu0_d[i][0] = ((iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                    (iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]);

            assign perf_iu6_dispatch_axu0_d[i][1] = (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu0[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu0[i]) & perf_iu6_dispatch_fx0_l2[i][1]);

            assign perf_iu6_dispatch_axu1_d[i][0] = ((iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & perf_iu6_dispatch_fx1_l2[i][1]) |
                                                    (iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]);

            assign perf_iu6_dispatch_axu1_d[i][1] = (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]) & perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    (~(iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & ~(iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]) & ~perf_iu6_dispatch_fx0_l2[i][1]) |
                                                    ((iu_rv_iu6_i0_vld_int[i] & frn_fdis_iu6_i0_rte_axu1[i]) & (iu_rv_iu6_i1_vld_int[i] & frn_fdis_iu6_i1_rte_axu1[i]) & perf_iu6_dispatch_fx0_l2[i][1]);

            assign perf_iu6_fx0_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~fx0_credit_ok[i] | ~fx0_local_credit_ok[i]);
            assign perf_iu6_fx1_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~fx1_credit_ok[i] | ~fx1_local_credit_ok[i]);
            assign perf_iu6_lq_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~lq_cmdq_credit_ok[i] | ~lq_cmdq_local_credit_ok[i]);
            assign perf_iu6_sq_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~sq_cmdq_credit_ok[i] | ~sq_cmdq_local_credit_ok[i]);
            assign perf_iu6_axu0_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~fu0_credit_ok[i] | ~fu0_local_credit_ok[i]);
            assign perf_iu6_axu1_credit_stall_d[i] = frn_fdis_iu6_i0_vld[i] & (~fu1_credit_ok[i] | ~fu1_local_credit_ok[i]);

            assign iu_pc_fx0_credit_ok_d[i]	=	fx0_credit_ok[i]	& fx0_local_credit_ok[i];
            assign iu_pc_fx1_credit_ok_d[i]	=	fx1_credit_ok[i]	& fx1_local_credit_ok[i];
            assign iu_pc_lq_credit_ok_d[i]	=	lq_cmdq_credit_ok[i]	& lq_cmdq_local_credit_ok[i];
            assign iu_pc_sq_credit_ok_d[i]	=	sq_cmdq_credit_ok[i]	& sq_cmdq_local_credit_ok[i];
            assign iu_pc_axu0_credit_ok_d[i]	=	fu0_credit_ok[i]	& fu0_local_credit_ok[i];
            assign iu_pc_axu1_credit_ok_d[i]	=	fu1_credit_ok[i]	& fu1_local_credit_ok[i];

         end
      end
   endgenerate


   assign perf_iu6_stall = perf_iu6_stall_l2;
`ifdef THREADS1
   assign perf_iu6_dispatch_fx0 = perf_iu6_dispatch_fx0_l2[0][0];
   assign perf_iu6_dispatch_fx1 = perf_iu6_dispatch_fx1_l2[0][0];
   assign perf_iu6_dispatch_lq = perf_iu6_dispatch_lq_l2[0][0];
   assign perf_iu6_dispatch_axu0 = perf_iu6_dispatch_axu0_l2[0][0];
   assign perf_iu6_dispatch_axu1 = perf_iu6_dispatch_axu1_l2[0][0];
`endif
`ifndef THREADS1
   assign perf_iu6_dispatch_fx0 = {perf_iu6_dispatch_fx0_l2[0][0], perf_iu6_dispatch_fx0_l2[1][0]};
   assign perf_iu6_dispatch_fx1 = {perf_iu6_dispatch_fx1_l2[0][0], perf_iu6_dispatch_fx1_l2[1][0]};
   assign perf_iu6_dispatch_lq = {perf_iu6_dispatch_lq_l2[0][0], perf_iu6_dispatch_lq_l2[1][0]};
   assign perf_iu6_dispatch_axu0 = {perf_iu6_dispatch_axu0_l2[0][0], perf_iu6_dispatch_axu0_l2[1][0]};
   assign perf_iu6_dispatch_axu1 = {perf_iu6_dispatch_axu1_l2[0][0], perf_iu6_dispatch_axu1_l2[1][0]};
`endif
   assign perf_iu6_fx0_credit_stall = perf_iu6_fx0_credit_stall_l2;
   assign perf_iu6_fx1_credit_stall = perf_iu6_fx1_credit_stall_l2;
   assign perf_iu6_lq_credit_stall = perf_iu6_lq_credit_stall_l2;
   assign perf_iu6_sq_credit_stall = perf_iu6_sq_credit_stall_l2;
   assign perf_iu6_axu0_credit_stall = perf_iu6_axu0_credit_stall_l2;
   assign perf_iu6_axu1_credit_stall = perf_iu6_axu1_credit_stall_l2;

   assign iu_pc_fx0_credit_ok	= iu_pc_fx0_credit_ok_l2;
   assign iu_pc_fx1_credit_ok	= iu_pc_fx1_credit_ok_l2;
   assign iu_pc_axu0_credit_ok	= iu_pc_axu0_credit_ok_l2;
   assign iu_pc_axu1_credit_ok	= iu_pc_axu1_credit_ok_l2;
   assign iu_pc_lq_credit_ok	= iu_pc_lq_credit_ok_l2;
   assign iu_pc_sq_credit_ok	= iu_pc_sq_credit_ok_l2;


   generate
      begin : xhdl7
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : thread_latches
            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX0_ENTRIES - 2)) fx0_high_credit_cnt_latch(
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
               .scin(siv[fx0_high_credit_cnt_offset + 5 * i:fx0_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fx0_high_credit_cnt_offset + 5 * i:fx0_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fx0_high_credit_cnt_d[i]),
               .dout(fx0_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX1_ENTRIES - 2)) fx1_high_credit_cnt_latch(
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
               .scin(siv[fx1_high_credit_cnt_offset + 5 * i:fx1_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fx1_high_credit_cnt_offset + 5 * i:fx1_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fx1_high_credit_cnt_d[i]),
               .dout(fx1_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`LDSTQ_ENTRIES - 2)) lq_cmdq_high_cnt_latch(
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
               .scin(siv[lq_cmdq_high_credit_cnt_offset + 5 * i:lq_cmdq_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[lq_cmdq_high_credit_cnt_offset + 5 * i:lq_cmdq_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(lq_cmdq_high_credit_cnt_d[i]),
               .dout(lq_cmdq_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`STQ_ENTRIES - 2)) sq_cmdq_high_cnt_latch(
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
               .scin(siv[sq_cmdq_high_credit_cnt_offset + 5 * i:sq_cmdq_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[sq_cmdq_high_credit_cnt_offset + 5 * i:sq_cmdq_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(sq_cmdq_high_credit_cnt_d[i]),
               .dout(sq_cmdq_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU0_ENTRIES - 2)) fu0_high_credit_cnt_latch(
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
               .scin(siv[fu0_high_credit_cnt_offset + 5 * i:fu0_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fu0_high_credit_cnt_offset + 5 * i:fu0_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fu0_high_credit_cnt_d[i]),
               .dout(fu0_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU1_ENTRIES - 2)) fu1_high_credit_cnt_latch(
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
               .scin(siv[fu1_high_credit_cnt_offset + 5 * i:fu1_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fu1_high_credit_cnt_offset + 5 * i:fu1_high_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fu1_high_credit_cnt_d[i]),
               .dout(fu1_high_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX0_ENTRIES / 2)) fx0_med_credit_cnt_latch(
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
               .scin(siv[fx0_med_credit_cnt_offset + 5 * i:fx0_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fx0_med_credit_cnt_offset + 5 * i:fx0_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fx0_med_credit_cnt_d[i]),
               .dout(fx0_med_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX1_ENTRIES / 2)) fx1_med_credit_cnt_latch(
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
               .scin(siv[fx1_med_credit_cnt_offset + 5 * i:fx1_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fx1_med_credit_cnt_offset + 5 * i:fx1_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fx1_med_credit_cnt_d[i]),
               .dout(fx1_med_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`LDSTQ_ENTRIES / 2)) lq_cmdq_med_cnt_latch(
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
               .scin(siv[lq_cmdq_med_credit_cnt_offset + 5 * i:lq_cmdq_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[lq_cmdq_med_credit_cnt_offset + 5 * i:lq_cmdq_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(lq_cmdq_med_credit_cnt_d[i]),
               .dout(lq_cmdq_med_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`STQ_ENTRIES / 2)) sq_cmdq_med_cnt_latch(
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
               .scin(siv[sq_cmdq_med_credit_cnt_offset + 5 * i:sq_cmdq_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[sq_cmdq_med_credit_cnt_offset + 5 * i:sq_cmdq_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(sq_cmdq_med_credit_cnt_d[i]),
               .dout(sq_cmdq_med_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU0_ENTRIES / 2)) fu0_med_credit_cnt_latch(
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
               .scin(siv[fu0_med_credit_cnt_offset + 5 * i:fu0_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fu0_med_credit_cnt_offset + 5 * i:fu0_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fu0_med_credit_cnt_d[i]),
               .dout(fu0_med_credit_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU1_ENTRIES / 2)) fu1_med_credit_cnt_latch(
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
               .scin(siv[fu1_med_credit_cnt_offset + 5 * i:fu1_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .scout(sov[fu1_med_credit_cnt_offset + 5 * i:fu1_med_credit_cnt_offset + (5 * (i + 1)-1)]),
               .din(fu1_med_credit_cnt_d[i]),
               .dout(fu1_med_credit_cnt_l2[i])
            );
         end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX0_ENTRIES)) fx0_total_credit_cnt_latch(
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
      .scin(siv[fx0_total_credit_cnt_offset:fx0_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[fx0_total_credit_cnt_offset:fx0_total_credit_cnt_offset + 5 - 1]),
      .din(fx0_total_credit_cnt_d),
      .dout(fx0_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_FX1_ENTRIES)) fx1_total_credit_cnt_latch(
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
      .scin(siv[fx1_total_credit_cnt_offset:fx1_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[fx1_total_credit_cnt_offset:fx1_total_credit_cnt_offset + 5 - 1]),
      .din(fx1_total_credit_cnt_d),
      .dout(fx1_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(`LDSTQ_ENTRIES)) lq_cmdq_total_cnt_latch(
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
      .scin(siv[lq_cmdq_total_credit_cnt_offset:lq_cmdq_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[lq_cmdq_total_credit_cnt_offset:lq_cmdq_total_credit_cnt_offset + 5 - 1]),
      .din(lq_cmdq_total_credit_cnt_d),
      .dout(lq_cmdq_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(`STQ_ENTRIES)) sq_cmdq_total_cnt_latch(
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
      .scin(siv[sq_cmdq_total_credit_cnt_offset:sq_cmdq_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[sq_cmdq_total_credit_cnt_offset:sq_cmdq_total_credit_cnt_offset + 5 - 1]),
      .din(sq_cmdq_total_credit_cnt_d),
      .dout(sq_cmdq_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU0_ENTRIES)) fu0_total_credit_cnt_latch(
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
      .scin(siv[fu0_total_credit_cnt_offset:fu0_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[fu0_total_credit_cnt_offset:fu0_total_credit_cnt_offset + 5 - 1]),
      .din(fu0_total_credit_cnt_d),
      .dout(fu0_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(5), .INIT(`RV_AXU1_ENTRIES)) fu1_total_credit_cnt_latch(
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
      .scin(siv[fu1_total_credit_cnt_offset:fu1_total_credit_cnt_offset + 5 - 1]),
      .scout(sov[fu1_total_credit_cnt_offset:fu1_total_credit_cnt_offset + 5 - 1]),
      .din(fu1_total_credit_cnt_d),
      .dout(fu1_total_credit_cnt_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) cp_flush_latch(
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
      .scin(siv[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .scout(sov[cp_flush_offset:cp_flush_offset + `THREADS - 1]),
      .din(cp_flush),
      .dout(cp_flush_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) xu_iu_run_thread_latch(
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
      .scin(siv[xu_iu_run_thread_offset:xu_iu_run_thread_offset + `THREADS - 1]),
      .scout(sov[xu_iu_run_thread_offset:xu_iu_run_thread_offset + `THREADS - 1]),
      .din(xu_iu_run_thread),
      .dout(xu_iu_run_thread_l2)
   );

   tri_rlmlatch_p #(.INIT(0)) iu_xu_credits_returned_latch(
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
      .scin(siv[iu_xu_credits_returned_offset]),
      .scout(sov[iu_xu_credits_returned_offset]),
      .din(iu_xu_credits_returned_d),
      .dout(iu_xu_credits_returned_l2)
   );


   tri_rlmreg_p #(.WIDTH(2), .INIT(0)) dual_issue_use_fx0_latch(
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
      .scin(siv[dual_issue_use_fx0_offset:dual_issue_use_fx0_offset + 2 - 1]),
      .scout(sov[dual_issue_use_fx0_offset:dual_issue_use_fx0_offset + 2 - 1]),
      .din(dual_issue_use_fx0_d),
      .dout(dual_issue_use_fx0_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(1)) last_thread_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(last_thread_act),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[last_thread_offset:last_thread_offset + `THREADS - 1]),
      .scout(sov[last_thread_offset:last_thread_offset + `THREADS - 1]),
      .din(last_thread_d),
      .dout(last_thread_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_hold_req_offset:mm_hold_req_offset + `THREADS - 1]),
      .scout(sov[mm_hold_req_offset:mm_hold_req_offset + `THREADS - 1]),
      .din(mm_hold_req_d),
      .dout(mm_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_hold_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_hold_done_offset:mm_hold_done_offset + `THREADS - 1]),
      .scout(sov[mm_hold_done_offset:mm_hold_done_offset + `THREADS - 1]),
      .din(mm_hold_done_d),
      .dout(mm_hold_done_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_bus_snoop_hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_bus_snoop_hold_req_offset:mm_bus_snoop_hold_req_offset + `THREADS - 1]),
      .scout(sov[mm_bus_snoop_hold_req_offset:mm_bus_snoop_hold_req_offset + `THREADS - 1]),
      .din(mm_bus_snoop_hold_req_d),
      .dout(mm_bus_snoop_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_bus_snoop_hold_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_bus_snoop_hold_done_offset:mm_bus_snoop_hold_done_offset + `THREADS - 1]),
      .scout(sov[mm_bus_snoop_hold_done_offset:mm_bus_snoop_hold_done_offset + `THREADS - 1]),
      .din(mm_bus_snoop_hold_done_d),
      .dout(mm_bus_snoop_hold_done_l2)
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

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) hold_req_latch(
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
      .scin(siv[hold_req_offset:hold_req_offset + `THREADS - 1]),
      .scout(sov[hold_req_offset:hold_req_offset + `THREADS - 1]),
      .din(hold_req_d),
      .dout(hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) ivax_hold_req_latch(
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
      .scin(siv[ivax_hold_req_offset:ivax_hold_req_offset + `THREADS - 1]),
      .scout(sov[ivax_hold_req_offset:ivax_hold_req_offset + `THREADS - 1]),
      .din(ivax_hold_req_d),
      .dout(ivax_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) hold_done_latch(
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
      .scin(siv[hold_done_offset:hold_done_offset + `THREADS - 1]),
      .scout(sov[hold_done_offset:hold_done_offset + `THREADS - 1]),
      .din(hold_done_d),
      .dout(hold_done_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_iu_flush_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_iu_flush_req_offset:mm_iu_flush_req_offset + `THREADS - 1]),
      .scout(sov[mm_iu_flush_req_offset:mm_iu_flush_req_offset + `THREADS - 1]),
      .din(mm_iu_flush_req_d),
      .dout(mm_iu_flush_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_iu_hold_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_iu_hold_done_offset:mm_iu_hold_done_offset + `THREADS - 1]),
      .scout(sov[mm_iu_hold_done_offset:mm_iu_hold_done_offset + `THREADS - 1]),
      .din(mm_iu_hold_done),
      .dout(mm_iu_hold_done_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_iu_bus_snoop_hold_req_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_iu_bus_snoop_hold_req_offset:mm_iu_bus_snoop_hold_req_offset + `THREADS - 1]),
      .scout(sov[mm_iu_bus_snoop_hold_req_offset:mm_iu_bus_snoop_hold_req_offset + `THREADS - 1]),
      .din(mm_iu_bus_snoop_hold_req_d),
      .dout(mm_iu_bus_snoop_hold_req_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) mm_iu_bus_snoop_hold_done_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[mm_iu_bus_snoop_hold_done_offset:mm_iu_bus_snoop_hold_done_offset + `THREADS - 1]),
      .scout(sov[mm_iu_bus_snoop_hold_done_offset:mm_iu_bus_snoop_hold_done_offset + `THREADS - 1]),
      .din(mm_iu_bus_snoop_hold_done),
      .dout(mm_iu_bus_snoop_hold_done_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) in_ucode_latch(
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
      .scin(siv[in_ucode_offset:in_ucode_offset + `THREADS - 1]),
      .scout(sov[in_ucode_offset:in_ucode_offset + `THREADS - 1]),
      .din(in_ucode_d),
      .dout(in_ucode_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) in_fusion_latch(
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
      .scin(siv[in_fusion_offset:in_fusion_offset + `THREADS - 1]),
      .scout(sov[in_fusion_offset:in_fusion_offset + `THREADS - 1]),
      .din(in_fusion_d),
      .dout(in_fusion_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) total_pri_mask_latch(
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
      .scin(siv[total_pri_mask_offset:total_pri_mask_offset + `THREADS - 1]),
      .scout(sov[total_pri_mask_offset:total_pri_mask_offset + `THREADS - 1]),
      .din(total_pri_mask_d),
      .dout(total_pri_mask_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) high_pri_mask_latch(
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
      .scin(siv[high_pri_mask_offset:high_pri_mask_offset + `THREADS - 1]),
      .scout(sov[high_pri_mask_offset:high_pri_mask_offset + `THREADS - 1]),
      .din(high_pri_mask_d),
      .dout(high_pri_mask_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) med_pri_mask_latch(
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
      .scin(siv[med_pri_mask_offset:med_pri_mask_offset + `THREADS - 1]),
      .scout(sov[med_pri_mask_offset:med_pri_mask_offset + `THREADS - 1]),
      .din(med_pri_mask_d),
      .dout(med_pri_mask_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) low_pri_mask_latch(
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
      .scin(siv[low_pri_mask_offset:low_pri_mask_offset + `THREADS - 1]),
      .scout(sov[low_pri_mask_offset:low_pri_mask_offset + `THREADS - 1]),
      .din(low_pri_mask_d),
      .dout(low_pri_mask_l2)
   );

   generate
      begin : low_pri_counts
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : thread_latches
            tri_rlmreg_p #(.WIDTH(8), .INIT(0)) low_pri_cnt_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(low_pri_cnt_act[i]),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[low_pri_cnt_offset + 8 * i:low_pri_cnt_offset + (8 * (i + 1)-1)]),
               .scout(sov[low_pri_cnt_offset + 8 * i:low_pri_cnt_offset + (8 * (i + 1)-1)]),
               .din(low_pri_cnt_d[i]),
               .dout(low_pri_cnt_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(6), .INIT(0)) low_pri_max_latch(
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
               .scin(siv[low_pri_max_offset + 6 * i:low_pri_max_offset + (6 * (i + 1)-1)]),
               .scout(sov[low_pri_max_offset + 6 * i:low_pri_max_offset + (6 * (i + 1)-1)]),
               .din(low_pri_max_d[i]),
               .dout(low_pri_max_l2[i])
            );
         end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_stall_offset:perf_iu6_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_stall_offset:perf_iu6_stall_offset + `THREADS - 1]),
      .din(perf_iu6_stall_d),
      .dout(perf_iu6_stall_l2)
   );

   generate
      begin : perf_counts
         genvar i;
         for (i = 0; i <= `THREADS - 1; i = i + 1)
         begin : thread_latches
            tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_iu6_dispatch_fx0_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(pc_iu_event_bus_enable),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[perf_iu6_dispatch_fx0_offset+2*i:perf_iu6_dispatch_fx0_offset + (2 * (i + 1)-1)]),
               .scout(sov[perf_iu6_dispatch_fx0_offset+2*i:perf_iu6_dispatch_fx0_offset + (2 * (i + 1)-1)]),
               .din(perf_iu6_dispatch_fx0_d[i]),
               .dout(perf_iu6_dispatch_fx0_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_iu6_dispatch_fx1_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(pc_iu_event_bus_enable),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[perf_iu6_dispatch_fx1_offset+2*i:perf_iu6_dispatch_fx1_offset + (2 * (i + 1)-1)]),
               .scout(sov[perf_iu6_dispatch_fx1_offset+2*i:perf_iu6_dispatch_fx1_offset + (2 * (i + 1)-1)]),
               .din(perf_iu6_dispatch_fx1_d[i]),
               .dout(perf_iu6_dispatch_fx1_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_iu6_dispatch_lq_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(pc_iu_event_bus_enable),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[perf_iu6_dispatch_lq_offset+2*i:perf_iu6_dispatch_lq_offset + (2 * (i + 1)-1)]),
               .scout(sov[perf_iu6_dispatch_lq_offset+2*i:perf_iu6_dispatch_lq_offset + (2 * (i + 1)-1)]),
               .din(perf_iu6_dispatch_lq_d[i]),
               .dout(perf_iu6_dispatch_lq_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_iu6_dispatch_axu0_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(pc_iu_event_bus_enable),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[perf_iu6_dispatch_axu0_offset+2*i:perf_iu6_dispatch_axu0_offset + (2 * (i + 1)-1)]),
               .scout(sov[perf_iu6_dispatch_axu0_offset+2*i:perf_iu6_dispatch_axu0_offset + (2 * (i + 1)-1)]),
               .din(perf_iu6_dispatch_axu0_d[i]),
               .dout(perf_iu6_dispatch_axu0_l2[i])
            );

            tri_rlmreg_p #(.WIDTH(2), .INIT(0)) perf_iu6_dispatch_axu1_latch(
               .vd(vdd),
               .gd(gnd),
               .nclk(nclk),
               .act(pc_iu_event_bus_enable),
               .force_t(force_t),
               .thold_b(pc_iu_func_sl_thold_0_b),
               .d_mode(d_mode),
               .sg(pc_iu_sg_0),
               .delay_lclkr(delay_lclkr),
               .mpw1_b(mpw1_b),
               .mpw2_b(mpw2_b),
               .scin(siv[perf_iu6_dispatch_axu1_offset+2*i:perf_iu6_dispatch_axu1_offset + (2 * (i + 1)-1)]),
               .scout(sov[perf_iu6_dispatch_axu1_offset+2*i:perf_iu6_dispatch_axu1_offset + (2 * (i + 1)-1)]),
               .din(perf_iu6_dispatch_axu1_d[i]),
               .dout(perf_iu6_dispatch_axu1_l2[i])
            );
         end
      end
   endgenerate

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_fx0_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_fx0_credit_stall_offset:perf_iu6_fx0_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_fx0_credit_stall_offset:perf_iu6_fx0_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_fx0_credit_stall_d),
      .dout(perf_iu6_fx0_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_fx1_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_fx1_credit_stall_offset:perf_iu6_fx1_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_fx1_credit_stall_offset:perf_iu6_fx1_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_fx1_credit_stall_d),
      .dout(perf_iu6_fx1_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_lq_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_lq_credit_stall_offset:perf_iu6_lq_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_lq_credit_stall_offset:perf_iu6_lq_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_lq_credit_stall_d),
      .dout(perf_iu6_lq_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_sq_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_sq_credit_stall_offset:perf_iu6_sq_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_sq_credit_stall_offset:perf_iu6_sq_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_sq_credit_stall_d),
      .dout(perf_iu6_sq_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_axu0_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_axu0_credit_stall_offset:perf_iu6_axu0_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_axu0_credit_stall_offset:perf_iu6_axu0_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_axu0_credit_stall_d),
      .dout(perf_iu6_axu0_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) perf_iu6_axu1_credit_stall_latch(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(pc_iu_event_bus_enable),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b),
      .d_mode(d_mode),
      .sg(pc_iu_sg_0),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scin(siv[perf_iu6_axu1_credit_stall_offset:perf_iu6_axu1_credit_stall_offset + `THREADS - 1]),
      .scout(sov[perf_iu6_axu1_credit_stall_offset:perf_iu6_axu1_credit_stall_offset + `THREADS - 1]),
      .din(perf_iu6_axu1_credit_stall_d),
      .dout(perf_iu6_axu1_credit_stall_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_fx0_credit_ok_latch(
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
      .scin(siv[iu_pc_fx0_credit_ok_offset:iu_pc_fx0_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_fx0_credit_ok_offset:iu_pc_fx0_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_fx0_credit_ok_d),
      .dout(iu_pc_fx0_credit_ok_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_fx1_credit_ok_latch(
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
      .scin(siv[iu_pc_fx1_credit_ok_offset:iu_pc_fx1_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_fx1_credit_ok_offset:iu_pc_fx1_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_fx1_credit_ok_d),
      .dout(iu_pc_fx1_credit_ok_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_lq_credit_ok_latch(
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
      .scin(siv[iu_pc_lq_credit_ok_offset:iu_pc_lq_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_lq_credit_ok_offset:iu_pc_lq_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_lq_credit_ok_d),
      .dout(iu_pc_lq_credit_ok_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_sq_credit_ok_latch(
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
      .scin(siv[iu_pc_sq_credit_ok_offset:iu_pc_sq_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_sq_credit_ok_offset:iu_pc_sq_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_sq_credit_ok_d),
      .dout(iu_pc_sq_credit_ok_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_axu0_credit_ok_latch(
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
      .scin(siv[iu_pc_axu0_credit_ok_offset:iu_pc_axu0_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_axu0_credit_ok_offset:iu_pc_axu0_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_axu0_credit_ok_d),
      .dout(iu_pc_axu0_credit_ok_l2)
   );

   tri_rlmreg_p #(.WIDTH(`THREADS), .INIT(0)) iu_pc_axu1_credit_ok_latch(
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
      .scin(siv[iu_pc_axu1_credit_ok_offset:iu_pc_axu1_credit_ok_offset + `THREADS - 1]),
      .scout(sov[iu_pc_axu1_credit_ok_offset:iu_pc_axu1_credit_ok_offset + `THREADS - 1]),
      .din(iu_pc_axu1_credit_ok_d),
      .dout(iu_pc_axu1_credit_ok_l2)
   );



   //-----------------------------------------------
   // pervasive
   //-----------------------------------------------

   tri_plat #(.WIDTH(3)) perv_2to1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_2, pc_iu_func_slp_sl_thold_2, pc_iu_sg_2}),
      .q({pc_iu_func_sl_thold_1, pc_iu_func_slp_sl_thold_1, pc_iu_sg_1})
   );

   tri_plat #(.WIDTH(3)) perv_1to0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_sl_thold_1, pc_iu_func_slp_sl_thold_1, pc_iu_sg_1}),
      .q({pc_iu_func_sl_thold_0, pc_iu_func_slp_sl_thold_0, pc_iu_sg_0})
   );

   tri_lcbor perv_lcbor_sl(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(force_t),
      .thold_b(pc_iu_func_sl_thold_0_b)
   );

   tri_lcbor perv_lcbor_slp_sl(
      .clkoff_b(clkoff_b),
      .thold(pc_iu_func_slp_sl_thold_0),
      .sg(pc_iu_sg_0),
      .act_dis(act_dis),
      .force_t(funcslp_force),
      .thold_b(pc_iu_func_slp_sl_thold_0_b)
   );

   //---------------------------------------------------------------------
   // Scan
   //---------------------------------------------------------------------
   assign siv[0:scan_right] = {sov[1:scan_right], scan_in};
   assign scan_out = sov[0];
endmodule
