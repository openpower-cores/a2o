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
//* NAME: iuq_slice_top.vhdl
//*********************************************************************
`include "tri_a2o.vh"


module iuq_slice_top(
   (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]       	nclk,
   input                         	pc_iu_sg_2,
   input                         	pc_iu_func_sl_thold_2,
   input                            pc_iu_func_slp_sl_thold_2,
   input                         	clkoff_b,
   input                         	act_dis,
   input                         	tc_ac_ccflush_dc,
   input                         	d_mode,
   input                         	delay_lclkr,
   input                         	mpw1_b,
   input                         	mpw2_b,
   input [0:`THREADS*7]          	scan_in,
   output [0:`THREADS*7]         	scan_out,

   output [0:`THREADS-1]        iu_pc_fx0_credit_ok,
   output [0:`THREADS-1]        iu_pc_fx1_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu0_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu1_credit_ok,
   output [0:`THREADS-1]        iu_pc_lq_credit_ok,
   output [0:`THREADS-1]        iu_pc_sq_credit_ok,


   //-------------------------------
   // Performance interface with I$
   //-------------------------------
   input                            pc_iu_event_bus_enable,
   output [0:20]                    slice_ic_t0_perf_events,
 `ifndef THREADS1
   output [0:20]                    slice_ic_t1_perf_events,
 `endif

   input [0:31]                  	spr_dec_mask,
   input [0:31]                  	spr_dec_match,

   input                         	xu_iu_ccr2_ucode_dis,
   input                         	mm_iu_tlbwe_binv,
   input [0:35]                  	rm_ib_iu3_instr,

   input [62-`EFF_IFAR_WIDTH:61]  	bp_ib_iu3_t0_ifar,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t0_0_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t0_1_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t0_2_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t0_3_instr,
   input [62-`EFF_IFAR_WIDTH:61]  	bp_ib_iu3_t0_bta,
 `ifndef THREADS1
   input [62-`EFF_IFAR_WIDTH:61]  	bp_ib_iu3_t1_ifar,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t1_0_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t1_1_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t1_2_instr,
   input [0:`IBUFF_INSTR_WIDTH-1] 	bp_ib_iu3_t1_3_instr,
   input [62-`EFF_IFAR_WIDTH:61]  	bp_ib_iu3_t1_bta,
 `endif

   input [0:`THREADS-1]           	cp_iu_iu4_flush,
   input [0:`THREADS-1]           	cp_flush_into_uc,

   input [0:`THREADS-1]           	xu_iu_epcr_dgtmi,
   input [0:`THREADS-1]           	xu_iu_msrp_uclep,
   input [0:`THREADS-1]           	xu_iu_msr_pr,
   input [0:`THREADS-1]           	xu_iu_msr_gs,
   input [0:`THREADS-1]           	xu_iu_msr_ucle,
   input [0:`THREADS-1]	         	spr_single_issue,

   // Input to dispatch to block due to ivax
   input [0:`THREADS-1]                 cp_dis_ivax,

   //-----------------------------
   // MMU Connections
   //-----------------------------

   input [0:`THREADS-1]         		mm_iu_flush_req,
   output [0:`THREADS-1]        		dp_cp_hold_req,
   input [0:`THREADS-1]         		mm_iu_hold_done,
   input [0:`THREADS-1]         		mm_iu_bus_snoop_hold_req,
   output [0:`THREADS-1]        		dp_cp_bus_snoop_hold_req,
   input [0:`THREADS-1]         		mm_iu_bus_snoop_hold_done,
   input [0:`THREADS-1]         		mm_iu_tlbi_complete,
   //----------------------------
   // Credit Interface with IU
   //----------------------------
   input [0:`THREADS-1]           	rv_iu_fx0_credit_free,
   input [0:`THREADS-1]           	rv_iu_fx1_credit_free,		// Need to add 2nd unit someday
   input [0:`THREADS-1]           	lq_iu_credit_free,
   input [0:`THREADS-1]           	sq_iu_credit_free,
   input [0:`THREADS-1]           	axu0_iu_credit_free,		// credit free from axu reservation station
   input [0:`THREADS-1]           	axu1_iu_credit_free,		// credit free from axu reservation station


   output [0:`THREADS-1]				ib_rm_rdy,
   input [0:`THREADS-1]					rm_ib_iu3_val,
   output [0:`THREADS-1]				ib_uc_rdy,
   input [0:`THREADS-1]					uc_ib_done,


   input [0:`THREADS-1]					iu_flush,
   input [0:`THREADS-1]					cp_flush,
   input [0:`THREADS-1]					br_iu_redirect,
   input [0:`THREADS-1]					uc_ib_iu3_flush_all,
   input [0:`THREADS-1]					cp_rn_uc_credit_free,
   input [0:`THREADS-1]					xu_iu_run_thread,

   output						iu_xu_credits_returned,


//threaded

   //-----------------------------
   // SPR connections
   //-----------------------------
   input [0:`THREADS-1]             spr_cpcr_we,
   input [0:4] 	                  spr_t0_cpcr2_fx0_cnt,
   input [0:4] 	                  spr_t0_cpcr2_fx1_cnt,
   input [0:4]  	                  spr_t0_cpcr2_lq_cnt,
   input [0:4] 		               spr_t0_cpcr2_sq_cnt,
   input [0:4]	                     spr_t0_cpcr3_fu0_cnt,
   input [0:4]	                     spr_t0_cpcr3_fu1_cnt,
   input [0:6]           				spr_t0_cpcr3_cp_cnt,
   input [0:4] 	                  spr_t0_cpcr4_fx0_cnt,
   input [0:4] 	                  spr_t0_cpcr4_fx1_cnt,
   input [0:4]  	                  spr_t0_cpcr4_lq_cnt,
   input [0:4] 		               spr_t0_cpcr4_sq_cnt,
   input [0:4]	                     spr_t0_cpcr5_fu0_cnt,
   input [0:4]	                     spr_t0_cpcr5_fu1_cnt,
   input [0:6]           				spr_t0_cpcr5_cp_cnt,
`ifndef THREADS1
   input [0:4] 	                  spr_t1_cpcr2_fx0_cnt,
   input [0:4] 	                  spr_t1_cpcr2_fx1_cnt,
   input [0:4]  	                  spr_t1_cpcr2_lq_cnt,
   input [0:4] 		               spr_t1_cpcr2_sq_cnt,
   input [0:4]                   	spr_t1_cpcr3_fu0_cnt,
   input [0:4]	                     spr_t1_cpcr3_fu1_cnt,
   input [0:6]           				spr_t1_cpcr3_cp_cnt,
   input [0:4] 	                  spr_t1_cpcr4_fx0_cnt,
   input [0:4] 	                  spr_t1_cpcr4_fx1_cnt,
   input [0:4]  	                  spr_t1_cpcr4_lq_cnt,
   input [0:4] 		               spr_t1_cpcr4_sq_cnt,
   input [0:4]                   	spr_t1_cpcr5_fu0_cnt,
   input [0:4]	                     spr_t1_cpcr5_fu1_cnt,
   input [0:6]           				spr_t1_cpcr5_cp_cnt,
`endif
   input [0:4] 	                  spr_cpcr0_fx0_cnt,
   input [0:4] 	                  spr_cpcr0_fx1_cnt,
   input [0:4]  	                  spr_cpcr0_lq_cnt,
   input [0:4] 		               spr_cpcr0_sq_cnt,
   input [0:4]	                     spr_cpcr1_fu0_cnt,
   input [0:4]	                     spr_cpcr1_fu1_cnt,

   input [0:`THREADS-1]             spr_high_pri_mask,
   input [0:`THREADS-1]             spr_med_pri_mask,
   input [0:5]                      spr_t0_low_pri_count,
`ifndef THREADS1
   input [0:5]                      spr_t1_low_pri_count,
`endif

   //-----------------------------
   // SPR values
   //-----------------------------
   input [0:7]           				iu_au_t0_config_iucr,

   //----------------------------
   // Ucode interface with IB
   //----------------------------
   input [0:3]         					uc_ib_iu3_t0_invalid,
   input [0:1]								uc_ib_t0_val,
   input [0:31]							uc_ib_t0_instr0,
   input [0:31]							uc_ib_t0_instr1,
   input [62-`EFF_IFAR_WIDTH:61]   	uc_ib_t0_ifar0,
   input [62-`EFF_IFAR_WIDTH:61]   	uc_ib_t0_ifar1,
   input [0:3]								uc_ib_t0_ext0,
   input [0:3]								uc_ib_t0_ext1,

   //----------------------------
   // Completion Interface
   //----------------------------
   input [0:`THREADS-1]					cp_rn_empty,
   input										cp_rn_t0_i0_axu_exception_val,
   input [0:3]								cp_rn_t0_i0_axu_exception,
   input										cp_rn_t0_i1_axu_exception_val,
   input [0:3]								cp_rn_t0_i1_axu_exception,
   input										cp_rn_t0_i0_v,
   input [0:`ITAG_SIZE_ENC-1]			cp_rn_t0_i0_itag,
   input										cp_rn_t0_i0_t1_v,
   input [0:2]								cp_rn_t0_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t1_a,
   input										cp_rn_t0_i0_t2_v,
   input [0:2]								cp_rn_t0_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t2_a,
   input										cp_rn_t0_i0_t3_v,
   input [0:2]								cp_rn_t0_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i0_t3_a,

   input										cp_rn_t0_i1_v,
   input [0:`ITAG_SIZE_ENC-1]			cp_rn_t0_i1_itag,
   input										cp_rn_t0_i1_t1_v,
   input [0:2]								cp_rn_t0_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t1_a,
   input										cp_rn_t0_i1_t2_v,
   input [0:2]								cp_rn_t0_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t2_a,
   input										cp_rn_t0_i1_t3_v,
   input [0:2]								cp_rn_t0_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t0_i1_t3_a,

   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output									iu_rv_iu6_t0_i0_vld,
   output									iu_rv_iu6_t0_i0_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i0_itag,
   output [0:2]  							iu_rv_iu6_t0_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t0_i0_ucode_cnt,
   output									iu_rv_iu6_t0_i0_2ucode,
   output									iu_rv_iu6_t0_i0_fuse_nop,
   output									iu_rv_iu6_t0_i0_rte_lq,
   output									iu_rv_iu6_t0_i0_rte_sq,
   output									iu_rv_iu6_t0_i0_rte_fx0,
   output									iu_rv_iu6_t0_i0_rte_fx1,
   output									iu_rv_iu6_t0_i0_rte_axu0,
   output									iu_rv_iu6_t0_i0_rte_axu1,
   output									iu_rv_iu6_t0_i0_valop,
   output									iu_rv_iu6_t0_i0_ord,
   output									iu_rv_iu6_t0_i0_cord,
   output [0:2]         				iu_rv_iu6_t0_i0_error,
   output									iu_rv_iu6_t0_i0_btb_entry,
   output [0:1]							iu_rv_iu6_t0_i0_btb_hist,
   output									iu_rv_iu6_t0_i0_bta_val,
   output [0:19]							iu_rv_iu6_t0_i0_fusion,
   output									iu_rv_iu6_t0_i0_spec,
   output									iu_rv_iu6_t0_i0_type_fp,
   output									iu_rv_iu6_t0_i0_type_ap,
   output									iu_rv_iu6_t0_i0_type_spv,
   output									iu_rv_iu6_t0_i0_type_st,
   output									iu_rv_iu6_t0_i0_async_block,
   output									iu_rv_iu6_t0_i0_np1_flush,
   output									iu_rv_iu6_t0_i0_isram,
   output									iu_rv_iu6_t0_i0_isload,
   output									iu_rv_iu6_t0_i0_isstore,
   output [0:31]							iu_rv_iu6_t0_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i0_bta,
   output									iu_rv_iu6_t0_i0_br_pred,
   output									iu_rv_iu6_t0_i0_bh_update,
   output [0:1]          				iu_rv_iu6_t0_i0_bh0_hist,
   output [0:1] 	         			iu_rv_iu6_t0_i0_bh1_hist,
   output [0:1]							iu_rv_iu6_t0_i0_bh2_hist,
   output [0:17]          				iu_rv_iu6_t0_i0_gshare,
   output [0:2]          				iu_rv_iu6_t0_i0_ls_ptr,
   output									iu_rv_iu6_t0_i0_match,
   output [0:3]          				iu_rv_iu6_t0_i0_ilat,
   output									iu_rv_iu6_t0_i0_t1_v,
   output [0:2]          				iu_rv_iu6_t0_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t1_p,
   output									iu_rv_iu6_t0_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t2_p,
   output [0:2]          				iu_rv_iu6_t0_i0_t2_t,
   output									iu_rv_iu6_t0_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t3_p,
   output [0:2]          				iu_rv_iu6_t0_i0_t3_t,
   output									iu_rv_iu6_t0_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s1_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i0_s1_itag,
   output [0:2]          				iu_rv_iu6_t0_i0_s1_t,
   output									iu_rv_iu6_t0_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s2_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i0_s2_itag,
   output [0:2]          				iu_rv_iu6_t0_i0_s2_t,
   output									iu_rv_iu6_t0_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_s3_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i0_s3_itag,
   output [0:2]          				iu_rv_iu6_t0_i0_s3_t,

   output									iu_rv_iu6_t0_i1_vld,
   output									iu_rv_iu6_t0_i1_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i1_itag,
   output [0:2]  							iu_rv_iu6_t0_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t0_i1_ucode_cnt,
   output									iu_rv_iu6_t0_i1_fuse_nop,
   output									iu_rv_iu6_t0_i1_rte_lq,
   output									iu_rv_iu6_t0_i1_rte_sq,
   output									iu_rv_iu6_t0_i1_rte_fx0,
   output									iu_rv_iu6_t0_i1_rte_fx1,
   output									iu_rv_iu6_t0_i1_rte_axu0,
   output									iu_rv_iu6_t0_i1_rte_axu1,
   output									iu_rv_iu6_t0_i1_valop,
   output									iu_rv_iu6_t0_i1_ord,
   output									iu_rv_iu6_t0_i1_cord,
   output [0:2]         				iu_rv_iu6_t0_i1_error,
   output									iu_rv_iu6_t0_i1_btb_entry,
   output [0:1]          				iu_rv_iu6_t0_i1_btb_hist,
   output									iu_rv_iu6_t0_i1_bta_val,
   output [0:19]							iu_rv_iu6_t0_i1_fusion,
   output									iu_rv_iu6_t0_i1_spec,
   output									iu_rv_iu6_t0_i1_type_fp,
   output									iu_rv_iu6_t0_i1_type_ap,
   output									iu_rv_iu6_t0_i1_type_spv,
   output									iu_rv_iu6_t0_i1_type_st,
   output									iu_rv_iu6_t0_i1_async_block,
   output									iu_rv_iu6_t0_i1_np1_flush,
   output									iu_rv_iu6_t0_i1_isram,
   output									iu_rv_iu6_t0_i1_isload,
   output									iu_rv_iu6_t0_i1_isstore,
   output [0:31]							iu_rv_iu6_t0_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i1_bta,
   output									iu_rv_iu6_t0_i1_br_pred,
   output									iu_rv_iu6_t0_i1_bh_update,
   output [0:1]          				iu_rv_iu6_t0_i1_bh0_hist,
   output [0:1] 	         			iu_rv_iu6_t0_i1_bh1_hist,
   output [0:1]							iu_rv_iu6_t0_i1_bh2_hist,
   output [0:17]          				iu_rv_iu6_t0_i1_gshare,
   output [0:2]          				iu_rv_iu6_t0_i1_ls_ptr,
   output									iu_rv_iu6_t0_i1_match,
   output [0:3]          				iu_rv_iu6_t0_i1_ilat,
   output									iu_rv_iu6_t0_i1_t1_v,
   output [0:2]							iu_rv_iu6_t0_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t1_p,
   output									iu_rv_iu6_t0_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t2_p,
   output [0:2]          				iu_rv_iu6_t0_i1_t2_t,
   output									iu_rv_iu6_t0_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t3_p,
   output [0:2]          				iu_rv_iu6_t0_i1_t3_t,
   output									iu_rv_iu6_t0_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s1_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i1_s1_itag,
   output [0:2]          				iu_rv_iu6_t0_i1_s1_t,
   output									iu_rv_iu6_t0_i1_s1_dep_hit,
   output									iu_rv_iu6_t0_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s2_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i1_s2_itag,
   output [0:2]          				iu_rv_iu6_t0_i1_s2_t,
   output									iu_rv_iu6_t0_i1_s2_dep_hit,
   output									iu_rv_iu6_t0_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_s3_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i1_s3_itag,
   output [0:2]          				iu_rv_iu6_t0_i1_s3_t,
   output									iu_rv_iu6_t0_i1_s3_dep_hit,

`ifndef THREADS1
   //-----------------------------
   // SPR values
   //-----------------------------
   input [0:7]           				iu_au_t1_config_iucr,


   //----------------------------
   // Ifetch with slice
   //----------------------------
   output [0:(`IBUFF_DEPTH/4)-1]		ib_ic_t1_need_fetch,
   input [0:3]								bp_ib_iu3_t1_val,

   //----------------------------
   // Ucode interface with IB
   //----------------------------
   input [0:3]          					uc_ib_iu3_t1_invalid,
   input [0:1]								uc_ib_t1_val,
   input [0:31]							uc_ib_t1_instr0,
   input [0:31]							uc_ib_t1_instr1,
   input [62-`EFF_IFAR_WIDTH:61]   	uc_ib_t1_ifar0,
   input [62-`EFF_IFAR_WIDTH:61]   	uc_ib_t1_ifar1,
   input [0:3]								uc_ib_t1_ext0,
   input [0:3]								uc_ib_t1_ext1,

   //----------------------------
   // Completion Interface
   //----------------------------
   input										cp_rn_t1_i0_axu_exception_val,
   input [0:3]								cp_rn_t1_i0_axu_exception,
   input										cp_rn_t1_i1_axu_exception_val,
   input [0:3]								cp_rn_t1_i1_axu_exception,
   input										cp_rn_t1_i0_v,
   input [0:`ITAG_SIZE_ENC-1]			cp_rn_t1_i0_itag,
   input										cp_rn_t1_i0_t1_v,
   input [0:2]								cp_rn_t1_i0_t1_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t1_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t1_a,
   input										cp_rn_t1_i0_t2_v,
   input [0:2]								cp_rn_t1_i0_t2_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t2_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t2_a,
   input										cp_rn_t1_i0_t3_v,
   input [0:2]								cp_rn_t1_i0_t3_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t3_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i0_t3_a,

   input										cp_rn_t1_i1_v,
   input [0:`ITAG_SIZE_ENC-1]			cp_rn_t1_i1_itag,
   input										cp_rn_t1_i1_t1_v,
   input [0:2]								cp_rn_t1_i1_t1_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t1_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t1_a,
   input										cp_rn_t1_i1_t2_v,
   input [0:2]								cp_rn_t1_i1_t2_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t2_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t2_a,
   input										cp_rn_t1_i1_t3_v,
   input [0:2]								cp_rn_t1_i1_t3_t,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t3_p,
   input [0:`GPR_POOL_ENC-1]			cp_rn_t1_i1_t3_a,


   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output									iu_rv_iu6_t1_i0_vld,
   output									iu_rv_iu6_t1_i0_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i0_itag,
   output [0:2]  							iu_rv_iu6_t1_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t1_i0_ucode_cnt,
   output									iu_rv_iu6_t1_i0_2ucode,
   output									iu_rv_iu6_t1_i0_fuse_nop,
   output									iu_rv_iu6_t1_i0_rte_lq,
   output									iu_rv_iu6_t1_i0_rte_sq,
   output									iu_rv_iu6_t1_i0_rte_fx0,
   output									iu_rv_iu6_t1_i0_rte_fx1,
   output									iu_rv_iu6_t1_i0_rte_axu0,
   output									iu_rv_iu6_t1_i0_rte_axu1,
   output									iu_rv_iu6_t1_i0_valop,
   output									iu_rv_iu6_t1_i0_ord,
   output									iu_rv_iu6_t1_i0_cord,
   output [0:2]         				iu_rv_iu6_t1_i0_error,
   output									iu_rv_iu6_t1_i0_btb_entry,
   output [0:1]							iu_rv_iu6_t1_i0_btb_hist,
   output									iu_rv_iu6_t1_i0_bta_val,
   output [0:19]							iu_rv_iu6_t1_i0_fusion,
   output									iu_rv_iu6_t1_i0_spec,
   output									iu_rv_iu6_t1_i0_type_fp,
   output									iu_rv_iu6_t1_i0_type_ap,
   output									iu_rv_iu6_t1_i0_type_spv,
   output									iu_rv_iu6_t1_i0_type_st,
   output									iu_rv_iu6_t1_i0_async_block,
   output									iu_rv_iu6_t1_i0_np1_flush,
   output									iu_rv_iu6_t1_i0_isram,
   output									iu_rv_iu6_t1_i0_isload,
   output									iu_rv_iu6_t1_i0_isstore,
   output [0:31]							iu_rv_iu6_t1_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i0_bta,
   output									iu_rv_iu6_t1_i0_br_pred,
   output									iu_rv_iu6_t1_i0_bh_update,
   output [0:1]          				iu_rv_iu6_t1_i0_bh0_hist,
   output [0:1] 	         			iu_rv_iu6_t1_i0_bh1_hist,
   output [0:1]							iu_rv_iu6_t1_i0_bh2_hist,
   output [0:17]          				iu_rv_iu6_t1_i0_gshare,
   output [0:2]          				iu_rv_iu6_t1_i0_ls_ptr,
   output									iu_rv_iu6_t1_i0_match,
   output [0:3]          				iu_rv_iu6_t1_i0_ilat,
   output									iu_rv_iu6_t1_i0_t1_v,
   output [0:2]          				iu_rv_iu6_t1_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t1_p,
   output									iu_rv_iu6_t1_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t2_p,
   output [0:2]          				iu_rv_iu6_t1_i0_t2_t,
   output									iu_rv_iu6_t1_i0_t3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t3_p,
   output [0:2]          				iu_rv_iu6_t1_i0_t3_t,
   output									iu_rv_iu6_t1_i0_s1_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s1_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i0_s1_itag,
   output [0:2]          				iu_rv_iu6_t1_i0_s1_t,
   output									iu_rv_iu6_t1_i0_s2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s2_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i0_s2_itag,
   output [0:2]          				iu_rv_iu6_t1_i0_s2_t,
   output									iu_rv_iu6_t1_i0_s3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_s3_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i0_s3_itag,
   output [0:2]          				iu_rv_iu6_t1_i0_s3_t,

   output									iu_rv_iu6_t1_i1_vld,
   output									iu_rv_iu6_t1_i1_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i1_itag,
   output [0:2]  							iu_rv_iu6_t1_i1_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t1_i1_ucode_cnt,
   output									iu_rv_iu6_t1_i1_fuse_nop,
   output									iu_rv_iu6_t1_i1_rte_lq,
   output									iu_rv_iu6_t1_i1_rte_sq,
   output									iu_rv_iu6_t1_i1_rte_fx0,
   output									iu_rv_iu6_t1_i1_rte_fx1,
   output									iu_rv_iu6_t1_i1_rte_axu0,
   output									iu_rv_iu6_t1_i1_rte_axu1,
   output									iu_rv_iu6_t1_i1_valop,
   output									iu_rv_iu6_t1_i1_ord,
   output									iu_rv_iu6_t1_i1_cord,
   output [0:2]         				iu_rv_iu6_t1_i1_error,
   output									iu_rv_iu6_t1_i1_btb_entry,
   output [0:1]          				iu_rv_iu6_t1_i1_btb_hist,
   output									iu_rv_iu6_t1_i1_bta_val,
   output [0:19]							iu_rv_iu6_t1_i1_fusion,
   output									iu_rv_iu6_t1_i1_spec,
   output									iu_rv_iu6_t1_i1_type_fp,
   output									iu_rv_iu6_t1_i1_type_ap,
   output									iu_rv_iu6_t1_i1_type_spv,
   output									iu_rv_iu6_t1_i1_type_st,
   output									iu_rv_iu6_t1_i1_async_block,
   output									iu_rv_iu6_t1_i1_np1_flush,
   output									iu_rv_iu6_t1_i1_isram,
   output									iu_rv_iu6_t1_i1_isload,
   output									iu_rv_iu6_t1_i1_isstore,
   output [0:31]							iu_rv_iu6_t1_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i1_bta,
   output									iu_rv_iu6_t1_i1_br_pred,
   output									iu_rv_iu6_t1_i1_bh_update,
   output [0:1]          				iu_rv_iu6_t1_i1_bh0_hist,
   output [0:1] 	         			iu_rv_iu6_t1_i1_bh1_hist,
   output [0:1]							iu_rv_iu6_t1_i1_bh2_hist,
   output [0:17]          				iu_rv_iu6_t1_i1_gshare,
   output [0:2]          				iu_rv_iu6_t1_i1_ls_ptr,
   output									iu_rv_iu6_t1_i1_match,
   output [0:3]          				iu_rv_iu6_t1_i1_ilat,
   output									iu_rv_iu6_t1_i1_t1_v,
   output [0:2]							iu_rv_iu6_t1_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t1_p,
   output									iu_rv_iu6_t1_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t2_p,
   output [0:2]          				iu_rv_iu6_t1_i1_t2_t,
   output									iu_rv_iu6_t1_i1_t3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t3_p,
   output [0:2]          				iu_rv_iu6_t1_i1_t3_t,
   output									iu_rv_iu6_t1_i1_s1_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s1_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s1_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i1_s1_itag,
   output [0:2]          				iu_rv_iu6_t1_i1_s1_t,
   output									iu_rv_iu6_t1_i1_s1_dep_hit,
   output									iu_rv_iu6_t1_i1_s2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s2_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s2_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i1_s2_itag,
   output [0:2]          				iu_rv_iu6_t1_i1_s2_t,
   output									iu_rv_iu6_t1_i1_s2_dep_hit,
   output									iu_rv_iu6_t1_i1_s3_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s3_a,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_s3_p,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i1_s3_itag,
   output [0:2]          				iu_rv_iu6_t1_i1_s3_t,
   output									iu_rv_iu6_t1_i1_s3_dep_hit,
`endif

   //----------------------------
   // Ifetch with slice
   //----------------------------
   output [0:(`IBUFF_DEPTH/4)-1]		ib_ic_t0_need_fetch,
   input [0:3]								bp_ib_iu3_t0_val

   );

   //----------------------------------------------------------------
   // Interface with rename
   //----------------------------------------------------------------
   wire                         frn_fdis_iu6_t0_i0_vld;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i0_itag;
   wire [0:2]  			         frn_fdis_iu6_t0_i0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t0_i0_ucode_cnt;
   wire                         frn_fdis_iu6_t0_i0_2ucode;
   wire                         frn_fdis_iu6_t0_i0_fuse_nop;
   wire                         frn_fdis_iu6_t0_i0_rte_lq;
   wire                         frn_fdis_iu6_t0_i0_rte_sq;
   wire                         frn_fdis_iu6_t0_i0_rte_fx0;
   wire                         frn_fdis_iu6_t0_i0_rte_fx1;
   wire                         frn_fdis_iu6_t0_i0_rte_axu0;
   wire                         frn_fdis_iu6_t0_i0_rte_axu1;
   wire                         frn_fdis_iu6_t0_i0_valop;
   wire                         frn_fdis_iu6_t0_i0_ord;
   wire                         frn_fdis_iu6_t0_i0_cord;
   wire [0:2]         			   frn_fdis_iu6_t0_i0_error;
   wire                         frn_fdis_iu6_t0_i0_btb_entry;
   wire [0:1]          			frn_fdis_iu6_t0_i0_btb_hist;
   wire                         frn_fdis_iu6_t0_i0_bta_val;
   wire [0:19]                  frn_fdis_iu6_t0_i0_fusion;
   wire                         frn_fdis_iu6_t0_i0_spec;
   wire                         frn_fdis_iu6_t0_i0_type_fp;
   wire                         frn_fdis_iu6_t0_i0_type_ap;
   wire                         frn_fdis_iu6_t0_i0_type_spv;
   wire                         frn_fdis_iu6_t0_i0_type_st;
   wire                         frn_fdis_iu6_t0_i0_async_block;
   wire                         frn_fdis_iu6_t0_i0_np1_flush;
   wire                         frn_fdis_iu6_t0_i0_core_block;
   wire                         frn_fdis_iu6_t0_i0_isram;
   wire                         frn_fdis_iu6_t0_i0_isload;
   wire                         frn_fdis_iu6_t0_i0_isstore;
   wire [0:31]                  frn_fdis_iu6_t0_i0_instr;
   wire [62-`EFF_IFAR_WIDTH:61]	frn_fdis_iu6_t0_i0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]	frn_fdis_iu6_t0_i0_bta;
   wire                         frn_fdis_iu6_t0_i0_br_pred;
   wire                         frn_fdis_iu6_t0_i0_bh_update;
   wire [0:1]          			frn_fdis_iu6_t0_i0_bh0_hist;
   wire [0:1] 	         		frn_fdis_iu6_t0_i0_bh1_hist;
   wire [0:1]                   frn_fdis_iu6_t0_i0_bh2_hist;
   wire [0:17]          			frn_fdis_iu6_t0_i0_gshare;
   wire [0:2]          			frn_fdis_iu6_t0_i0_ls_ptr;
   wire                         frn_fdis_iu6_t0_i0_match;
   wire [0:3]          			frn_fdis_iu6_t0_i0_ilat;
   wire                         frn_fdis_iu6_t0_i0_t1_v;
   wire [0:2]          			frn_fdis_iu6_t0_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t1_p;
   wire                         frn_fdis_iu6_t0_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t2_p;
   wire [0:2]          			frn_fdis_iu6_t0_i0_t2_t;
   wire                         frn_fdis_iu6_t0_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_t3_p;
   wire [0:2]          			frn_fdis_iu6_t0_i0_t3_t;
   wire                         frn_fdis_iu6_t0_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s1_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i0_s1_itag;
   wire [0:2]          			frn_fdis_iu6_t0_i0_s1_t;
   wire                         frn_fdis_iu6_t0_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s2_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i0_s2_itag;
   wire [0:2]          			frn_fdis_iu6_t0_i0_s2_t;
   wire                         frn_fdis_iu6_t0_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i0_s3_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i0_s3_itag;
   wire [0:2]          			frn_fdis_iu6_t0_i0_s3_t;

   wire                         frn_fdis_iu6_t0_i1_vld;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i1_itag;
   wire [0:2]  			         frn_fdis_iu6_t0_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t0_i1_ucode_cnt;
   wire                         frn_fdis_iu6_t0_i1_fuse_nop;
   wire                         frn_fdis_iu6_t0_i1_rte_lq;
   wire                         frn_fdis_iu6_t0_i1_rte_sq;
   wire                         frn_fdis_iu6_t0_i1_rte_fx0;
   wire                         frn_fdis_iu6_t0_i1_rte_fx1;
   wire                         frn_fdis_iu6_t0_i1_rte_axu0;
   wire                         frn_fdis_iu6_t0_i1_rte_axu1;
   wire                         frn_fdis_iu6_t0_i1_valop;
   wire                         frn_fdis_iu6_t0_i1_ord;
   wire                         frn_fdis_iu6_t0_i1_cord;
   wire [0:2]         			  frn_fdis_iu6_t0_i1_error;
   wire                         frn_fdis_iu6_t0_i1_btb_entry;
   wire [0:1]          			  frn_fdis_iu6_t0_i1_btb_hist;
   wire                         frn_fdis_iu6_t0_i1_bta_val;
   wire [0:19]                  frn_fdis_iu6_t0_i1_fusion;
   wire                         frn_fdis_iu6_t0_i1_spec;
   wire                         frn_fdis_iu6_t0_i1_type_fp;
   wire                         frn_fdis_iu6_t0_i1_type_ap;
   wire                         frn_fdis_iu6_t0_i1_type_spv;
   wire                         frn_fdis_iu6_t0_i1_type_st;
   wire                         frn_fdis_iu6_t0_i1_async_block;
   wire                         frn_fdis_iu6_t0_i1_np1_flush;
   wire                         frn_fdis_iu6_t0_i1_core_block;
   wire                         frn_fdis_iu6_t0_i1_isram;
   wire                         frn_fdis_iu6_t0_i1_isload;
   wire                         frn_fdis_iu6_t0_i1_isstore;
   wire [0:31]                  frn_fdis_iu6_t0_i1_instr;
   wire [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i1_ifar;
   wire [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t0_i1_bta;
   wire                         frn_fdis_iu6_t0_i1_br_pred;
   wire                         frn_fdis_iu6_t0_i1_bh_update;
   wire [0:1]          			  frn_fdis_iu6_t0_i1_bh0_hist;
   wire [0:1] 	         		  frn_fdis_iu6_t0_i1_bh1_hist;
   wire [0:1]                   frn_fdis_iu6_t0_i1_bh2_hist;
   wire [0:17]          			  frn_fdis_iu6_t0_i1_gshare;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_ls_ptr;
   wire                         frn_fdis_iu6_t0_i1_match;
   wire [0:3]          			  frn_fdis_iu6_t0_i1_ilat;
   wire                         frn_fdis_iu6_t0_i1_t1_v;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t1_p;
   wire                         frn_fdis_iu6_t0_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t2_p;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_t2_t;
   wire                         frn_fdis_iu6_t0_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_t3_p;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_t3_t;
   wire                         frn_fdis_iu6_t0_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s1_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i1_s1_itag;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_s1_t;
   wire                         frn_fdis_iu6_t0_i1_s1_dep_hit;
   wire                         frn_fdis_iu6_t0_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s2_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i1_s2_itag;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_s2_t;
   wire                         frn_fdis_iu6_t0_i1_s2_dep_hit;
   wire                         frn_fdis_iu6_t0_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t0_i1_s3_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t0_i1_s3_itag;
   wire [0:2]          			  frn_fdis_iu6_t0_i1_s3_t;
   wire                         frn_fdis_iu6_t0_i1_s3_dep_hit;

`ifndef THREADS1
   //----------------------------------------------------------------
   // Interface with rename
   //----------------------------------------------------------------
   wire                         frn_fdis_iu6_t1_i0_vld;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i0_itag;
   wire [0:2]  			         frn_fdis_iu6_t1_i0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t1_i0_ucode_cnt;
   wire                         frn_fdis_iu6_t1_i0_2ucode;
   wire                         frn_fdis_iu6_t1_i0_fuse_nop;
   wire                         frn_fdis_iu6_t1_i0_rte_lq;
   wire                         frn_fdis_iu6_t1_i0_rte_sq;
   wire                         frn_fdis_iu6_t1_i0_rte_fx0;
   wire                         frn_fdis_iu6_t1_i0_rte_fx1;
   wire                         frn_fdis_iu6_t1_i0_rte_axu0;
   wire                         frn_fdis_iu6_t1_i0_rte_axu1;
   wire                         frn_fdis_iu6_t1_i0_valop;
   wire                         frn_fdis_iu6_t1_i0_ord;
   wire                         frn_fdis_iu6_t1_i0_cord;
   wire [0:2]         			   frn_fdis_iu6_t1_i0_error;
   wire                         frn_fdis_iu6_t1_i0_btb_entry;
   wire [0:1]          			frn_fdis_iu6_t1_i0_btb_hist;
   wire                         frn_fdis_iu6_t1_i0_bta_val;
   wire [0:19]                  frn_fdis_iu6_t1_i0_fusion;
   wire                         frn_fdis_iu6_t1_i0_spec;
   wire                         frn_fdis_iu6_t1_i0_type_fp;
   wire                         frn_fdis_iu6_t1_i0_type_ap;
   wire                         frn_fdis_iu6_t1_i0_type_spv;
   wire                         frn_fdis_iu6_t1_i0_type_st;
   wire                         frn_fdis_iu6_t1_i0_async_block;
   wire                         frn_fdis_iu6_t1_i0_np1_flush;
   wire                         frn_fdis_iu6_t1_i0_core_block;
   wire                         frn_fdis_iu6_t1_i0_isram;
   wire                         frn_fdis_iu6_t1_i0_isload;
   wire                         frn_fdis_iu6_t1_i0_isstore;
   wire [0:31]                  frn_fdis_iu6_t1_i0_instr;
   wire [62-`EFF_IFAR_WIDTH:61]	frn_fdis_iu6_t1_i0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]	frn_fdis_iu6_t1_i0_bta;
   wire                         frn_fdis_iu6_t1_i0_br_pred;
   wire                         frn_fdis_iu6_t1_i0_bh_update;
   wire [0:1]          			frn_fdis_iu6_t1_i0_bh0_hist;
   wire [0:1] 	         		frn_fdis_iu6_t1_i0_bh1_hist;
   wire [0:1]                   frn_fdis_iu6_t1_i0_bh2_hist;
   wire [0:17]          			frn_fdis_iu6_t1_i0_gshare;
   wire [0:2]          			frn_fdis_iu6_t1_i0_ls_ptr;
   wire                         frn_fdis_iu6_t1_i0_match;
   wire [0:3]          			frn_fdis_iu6_t1_i0_ilat;
   wire                         frn_fdis_iu6_t1_i0_t1_v;
   wire [0:2]          			frn_fdis_iu6_t1_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t1_p;
   wire                         frn_fdis_iu6_t1_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t2_p;
   wire [0:2]          			frn_fdis_iu6_t1_i0_t2_t;
   wire                         frn_fdis_iu6_t1_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_t3_p;
   wire [0:2]          			frn_fdis_iu6_t1_i0_t3_t;
   wire                         frn_fdis_iu6_t1_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s1_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i0_s1_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i0_s1_t;
   wire                         frn_fdis_iu6_t1_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s2_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i0_s2_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i0_s2_t;
   wire                         frn_fdis_iu6_t1_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i0_s3_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i0_s3_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i0_s3_t;

   wire                         frn_fdis_iu6_t1_i1_vld;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i1_itag;
   wire [0:2]  			frn_fdis_iu6_t1_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] frn_fdis_iu6_t1_i1_ucode_cnt;
   wire                         frn_fdis_iu6_t1_i1_fuse_nop;
   wire                         frn_fdis_iu6_t1_i1_rte_lq;
   wire                         frn_fdis_iu6_t1_i1_rte_sq;
   wire                         frn_fdis_iu6_t1_i1_rte_fx0;
   wire                         frn_fdis_iu6_t1_i1_rte_fx1;
   wire                         frn_fdis_iu6_t1_i1_rte_axu0;
   wire                         frn_fdis_iu6_t1_i1_rte_axu1;
   wire                         frn_fdis_iu6_t1_i1_valop;
   wire                         frn_fdis_iu6_t1_i1_ord;
   wire                         frn_fdis_iu6_t1_i1_cord;
   wire [0:2]         		frn_fdis_iu6_t1_i1_error;
   wire                         frn_fdis_iu6_t1_i1_btb_entry;
   wire [0:1]          		frn_fdis_iu6_t1_i1_btb_hist;
   wire                         frn_fdis_iu6_t1_i1_bta_val;
   wire [0:19]                  frn_fdis_iu6_t1_i1_fusion;
   wire                         frn_fdis_iu6_t1_i1_spec;
   wire                         frn_fdis_iu6_t1_i1_type_fp;
   wire                         frn_fdis_iu6_t1_i1_type_ap;
   wire                         frn_fdis_iu6_t1_i1_type_spv;
   wire                         frn_fdis_iu6_t1_i1_type_st;
   wire                         frn_fdis_iu6_t1_i1_async_block;
   wire                         frn_fdis_iu6_t1_i1_np1_flush;
   wire                         frn_fdis_iu6_t1_i1_core_block;
   wire                         frn_fdis_iu6_t1_i1_isram;
   wire                         frn_fdis_iu6_t1_i1_isload;
   wire                         frn_fdis_iu6_t1_i1_isstore;
   wire [0:31]                  frn_fdis_iu6_t1_i1_instr;
   wire [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i1_ifar;
   wire [62-`EFF_IFAR_WIDTH:61] frn_fdis_iu6_t1_i1_bta;
   wire                         frn_fdis_iu6_t1_i1_br_pred;
   wire                         frn_fdis_iu6_t1_i1_bh_update;
   wire [0:1]          		frn_fdis_iu6_t1_i1_bh0_hist;
   wire [0:1] 	         	frn_fdis_iu6_t1_i1_bh1_hist;
   wire [0:1]                   frn_fdis_iu6_t1_i1_bh2_hist;
   wire [0:17]          		frn_fdis_iu6_t1_i1_gshare;
   wire [0:2]          		frn_fdis_iu6_t1_i1_ls_ptr;
   wire                         frn_fdis_iu6_t1_i1_match;
   wire [0:3]          		frn_fdis_iu6_t1_i1_ilat;
   wire                         frn_fdis_iu6_t1_i1_t1_v;
   wire [0:2]          		frn_fdis_iu6_t1_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t1_p;
   wire                         frn_fdis_iu6_t1_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t2_p;
   wire [0:2]          		frn_fdis_iu6_t1_i1_t2_t;
   wire                         frn_fdis_iu6_t1_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_t3_p;
   wire [0:2]          		frn_fdis_iu6_t1_i1_t3_t;
   wire                         frn_fdis_iu6_t1_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s1_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s1_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i1_s1_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i1_s1_t;
   wire                         frn_fdis_iu6_t1_i1_s1_dep_hit;
   wire                         frn_fdis_iu6_t1_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s2_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s2_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i1_s2_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i1_s2_t;
   wire                         frn_fdis_iu6_t1_i1_s2_dep_hit;
   wire                         frn_fdis_iu6_t1_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s3_a;
   wire [0:`GPR_POOL_ENC-1]     frn_fdis_iu6_t1_i1_s3_p;
   wire [0:`ITAG_SIZE_ENC-1]    frn_fdis_iu6_t1_i1_s3_itag;
   wire [0:2]          		frn_fdis_iu6_t1_i1_s3_t;
   wire                         frn_fdis_iu6_t1_i1_s3_dep_hit;
`endif

   wire [0:`THREADS-1]          fdis_frn_iu6_stall;

   //-------------------------------
   // Performance interface with I$
   //-------------------------------
   wire [0:`THREADS-1]          perf_iu5_stall;
   wire [0:`THREADS-1]          perf_iu5_cpl_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_gpr_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_cr_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_lr_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_ctr_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_xer_credit_stall;
   wire [0:`THREADS-1]          perf_iu5_br_hold_stall;
   wire [0:`THREADS-1]          perf_iu5_axu_hold_stall;
   wire [0:`THREADS-1]          perf_iu6_stall;
   wire [0:`THREADS-1]          perf_iu6_dispatch_fx0;
   wire [0:`THREADS-1]          perf_iu6_dispatch_fx1;
   wire [0:`THREADS-1]          perf_iu6_dispatch_lq;
   wire [0:`THREADS-1]          perf_iu6_dispatch_axu0;
   wire [0:`THREADS-1]          perf_iu6_dispatch_axu1;
   wire [0:`THREADS-1]          perf_iu6_fx0_credit_stall;
   wire [0:`THREADS-1]          perf_iu6_fx1_credit_stall;
   wire [0:`THREADS-1]          perf_iu6_lq_credit_stall;
   wire [0:`THREADS-1]          perf_iu6_sq_credit_stall;
   wire [0:`THREADS-1]          perf_iu6_axu0_credit_stall;
   wire [0:`THREADS-1]          perf_iu6_axu1_credit_stall;

   wire 			   vdd;
   wire 			   gnd;
   assign vdd = 1'b1;
   assign gnd = 1'b0;

   assign slice_ic_t0_perf_events = {perf_iu5_stall[0], perf_iu5_cpl_credit_stall[0], perf_iu5_gpr_credit_stall[0], perf_iu5_cr_credit_stall[0],
                                     perf_iu5_lr_credit_stall[0], perf_iu5_ctr_credit_stall[0], perf_iu5_xer_credit_stall[0], perf_iu5_br_hold_stall[0],
                                     perf_iu5_axu_hold_stall[0], perf_iu6_stall[0], perf_iu6_dispatch_fx0[0], perf_iu6_dispatch_fx1[0], perf_iu6_dispatch_lq[0],
                                     perf_iu6_dispatch_axu0[0], perf_iu6_dispatch_axu1[0], perf_iu6_fx0_credit_stall[0], perf_iu6_fx1_credit_stall[0],
                                     perf_iu6_lq_credit_stall[0], perf_iu6_sq_credit_stall[0], perf_iu6_axu0_credit_stall[0], perf_iu6_axu1_credit_stall[0]};
`ifndef THREADS1
   assign slice_ic_t1_perf_events = {perf_iu5_stall[1], perf_iu5_cpl_credit_stall[1], perf_iu5_gpr_credit_stall[1], perf_iu5_cr_credit_stall[1],
                                     perf_iu5_lr_credit_stall[1], perf_iu5_ctr_credit_stall[1], perf_iu5_xer_credit_stall[1], perf_iu5_br_hold_stall[1],
                                     perf_iu5_axu_hold_stall[1], perf_iu6_stall[1], perf_iu6_dispatch_fx0[1], perf_iu6_dispatch_fx1[1], perf_iu6_dispatch_lq[1],
                                     perf_iu6_dispatch_axu0[1], perf_iu6_dispatch_axu1[1], perf_iu6_fx0_credit_stall[1], perf_iu6_fx1_credit_stall[1],
                                     perf_iu6_lq_credit_stall[1], perf_iu6_sq_credit_stall[1], perf_iu6_axu0_credit_stall[1], perf_iu6_axu1_credit_stall[1]};
`endif


               iuq_slice  slice0(
                  .vdd(vdd),
                  .gnd(gnd),
                  .nclk(nclk),
                  .pc_iu_sg_2(pc_iu_sg_2),
                  .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
                  .clkoff_b(clkoff_b),
                  .act_dis(act_dis),
                  .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
                  .d_mode(d_mode),
                  .delay_lclkr(delay_lclkr),
                  .mpw1_b(mpw1_b),
                  .mpw2_b(mpw2_b),
                  .scan_in(scan_in[1:7]),
                  .scan_out(scan_out[1:7]),

                  //-------------------------------
                  // Performance interface with I$
                  //-------------------------------
                  .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
                  .perf_iu5_stall(perf_iu5_stall[0]),
                  .perf_iu5_cpl_credit_stall(perf_iu5_cpl_credit_stall[0]),
                  .perf_iu5_gpr_credit_stall(perf_iu5_gpr_credit_stall[0]),
                  .perf_iu5_cr_credit_stall(perf_iu5_cr_credit_stall[0]),
                  .perf_iu5_lr_credit_stall(perf_iu5_lr_credit_stall[0]),
                  .perf_iu5_ctr_credit_stall(perf_iu5_ctr_credit_stall[0]),
                  .perf_iu5_xer_credit_stall(perf_iu5_xer_credit_stall[0]),
                  .perf_iu5_br_hold_stall(perf_iu5_br_hold_stall[0]),
                  .perf_iu5_axu_hold_stall(perf_iu5_axu_hold_stall[0]),

                  .cp_iu_iu4_flush(cp_iu_iu4_flush[0]),
                  .cp_flush_into_uc(cp_flush_into_uc[0]),

                  .xu_iu_epcr_dgtmi(xu_iu_epcr_dgtmi[0]),
                  .xu_iu_msrp_uclep(xu_iu_msrp_uclep[0]),
                  .xu_iu_msr_pr(xu_iu_msr_pr[0]),
                  .xu_iu_msr_gs(xu_iu_msr_gs[0]),
                  .xu_iu_msr_ucle(xu_iu_msr_ucle[0]),
                  .xu_iu_ccr2_ucode_dis(xu_iu_ccr2_ucode_dis),

                  //-----------------------------
                  // SPR values
                  //-----------------------------
                  .spr_high_pri_mask(spr_high_pri_mask[0]),
                  .spr_cpcr_we(spr_cpcr_we[0]),
                  .spr_cpcr3_cp_cnt(spr_t0_cpcr3_cp_cnt),
                  .spr_cpcr5_cp_cnt(spr_t0_cpcr5_cp_cnt),
                  .spr_single_issue(spr_single_issue[0]),
                  .spr_dec_mask(spr_dec_mask),
                  .spr_dec_match(spr_dec_match),
                  .iu_au_config_iucr(iu_au_t0_config_iucr),
                  .mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),

                  //----------------------------
                  // Ifetch with slice
                  //----------------------------
                  .ib_rm_rdy(ib_rm_rdy[0]),
                  .rm_ib_iu3_val(rm_ib_iu3_val[0]),
                  .rm_ib_iu3_instr(rm_ib_iu3_instr),

                  .uc_ib_iu3_invalid(uc_ib_iu3_t0_invalid),

                  .ib_ic_need_fetch(ib_ic_t0_need_fetch),

                  .bp_ib_iu3_ifar(bp_ib_iu3_t0_ifar),
                  .bp_ib_iu3_val(bp_ib_iu3_t0_val),
                  .bp_ib_iu3_0_instr(bp_ib_iu3_t0_0_instr),
                  .bp_ib_iu3_1_instr(bp_ib_iu3_t0_1_instr),
                  .bp_ib_iu3_2_instr(bp_ib_iu3_t0_2_instr),
                  .bp_ib_iu3_3_instr(bp_ib_iu3_t0_3_instr),
                  .bp_ib_iu3_bta(bp_ib_iu3_t0_bta),

                  //----------------------------
                  // Ucode interface with IB
                  //----------------------------
                  .ib_uc_rdy(ib_uc_rdy[0]),
                  .uc_ib_val(uc_ib_t0_val),
                  .uc_ib_done(uc_ib_done[0]),
                  .uc_ib_instr0(uc_ib_t0_instr0),
                  .uc_ib_instr1(uc_ib_t0_instr1),
                  .uc_ib_ifar0(uc_ib_t0_ifar0),
                  .uc_ib_ifar1(uc_ib_t0_ifar1),
                  .uc_ib_ext0(uc_ib_t0_ext0),
                  .uc_ib_ext1(uc_ib_t0_ext1),

                  //----------------------------
                  // Completion Interface
                  //----------------------------
                  .cp_rn_i0_axu_exception_val(cp_rn_t0_i0_axu_exception_val),
                  .cp_rn_i0_axu_exception(cp_rn_t0_i0_axu_exception),
                  .cp_rn_i1_axu_exception_val(cp_rn_t0_i1_axu_exception_val),
                  .cp_rn_i1_axu_exception(cp_rn_t0_i1_axu_exception),
                  .cp_rn_empty(cp_rn_empty[0]),
                  .cp_rn_i0_v(cp_rn_t0_i0_v),
                  .cp_rn_i0_itag(cp_rn_t0_i0_itag),
                  .cp_rn_i0_t1_v(cp_rn_t0_i0_t1_v),
                  .cp_rn_i0_t1_t(cp_rn_t0_i0_t1_t),
                  .cp_rn_i0_t1_p(cp_rn_t0_i0_t1_p),
                  .cp_rn_i0_t1_a(cp_rn_t0_i0_t1_a),
                  .cp_rn_i0_t2_v(cp_rn_t0_i0_t2_v),
                  .cp_rn_i0_t2_t(cp_rn_t0_i0_t2_t),
                  .cp_rn_i0_t2_p(cp_rn_t0_i0_t2_p),
                  .cp_rn_i0_t2_a(cp_rn_t0_i0_t2_a),
                  .cp_rn_i0_t3_v(cp_rn_t0_i0_t3_v),
                  .cp_rn_i0_t3_t(cp_rn_t0_i0_t3_t),
                  .cp_rn_i0_t3_p(cp_rn_t0_i0_t3_p),
                  .cp_rn_i0_t3_a(cp_rn_t0_i0_t3_a),

                  .cp_rn_i1_v(cp_rn_t0_i1_v),
                  .cp_rn_i1_itag(cp_rn_t0_i1_itag),
                  .cp_rn_i1_t1_v(cp_rn_t0_i1_t1_v),
                  .cp_rn_i1_t1_t(cp_rn_t0_i1_t1_t),
                  .cp_rn_i1_t1_p(cp_rn_t0_i1_t1_p),
                  .cp_rn_i1_t1_a(cp_rn_t0_i1_t1_a),
                  .cp_rn_i1_t2_v(cp_rn_t0_i1_t2_v),
                  .cp_rn_i1_t2_t(cp_rn_t0_i1_t2_t),
                  .cp_rn_i1_t2_p(cp_rn_t0_i1_t2_p),
                  .cp_rn_i1_t2_a(cp_rn_t0_i1_t2_a),
                  .cp_rn_i1_t3_v(cp_rn_t0_i1_t3_v),
                  .cp_rn_i1_t3_t(cp_rn_t0_i1_t3_t),
                  .cp_rn_i1_t3_p(cp_rn_t0_i1_t3_p),
                  .cp_rn_i1_t3_a(cp_rn_t0_i1_t3_a),

                  .iu_flush(iu_flush[0]),
                  .cp_flush(cp_flush[0]),
                  .br_iu_redirect(br_iu_redirect[0]),
		  .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all[0]),
                  .cp_rn_uc_credit_free(cp_rn_uc_credit_free[0]),

                  //-----------------------------
                  // Stall from dispatch
                  //-----------------------------
                  .fdis_frn_iu6_stall(fdis_frn_iu6_stall[0]),

                  //----------------------------------------------------------------
                  // Interface to reservation station - Completion is snooping also
                  //----------------------------------------------------------------
                  .frn_fdis_iu6_i0_vld(frn_fdis_iu6_t0_i0_vld),
                  .frn_fdis_iu6_i0_itag(frn_fdis_iu6_t0_i0_itag),
                  .frn_fdis_iu6_i0_ucode(frn_fdis_iu6_t0_i0_ucode),
                  .frn_fdis_iu6_i0_ucode_cnt(frn_fdis_iu6_t0_i0_ucode_cnt),
                  .frn_fdis_iu6_i0_2ucode(frn_fdis_iu6_t0_i0_2ucode),
                  .frn_fdis_iu6_i0_fuse_nop(frn_fdis_iu6_t0_i0_fuse_nop),
                  .frn_fdis_iu6_i0_rte_lq(frn_fdis_iu6_t0_i0_rte_lq),
                  .frn_fdis_iu6_i0_rte_sq(frn_fdis_iu6_t0_i0_rte_sq),
                  .frn_fdis_iu6_i0_rte_fx0(frn_fdis_iu6_t0_i0_rte_fx0),
                  .frn_fdis_iu6_i0_rte_fx1(frn_fdis_iu6_t0_i0_rte_fx1),
                  .frn_fdis_iu6_i0_rte_axu0(frn_fdis_iu6_t0_i0_rte_axu0),
                  .frn_fdis_iu6_i0_rte_axu1(frn_fdis_iu6_t0_i0_rte_axu1),
                  .frn_fdis_iu6_i0_valop(frn_fdis_iu6_t0_i0_valop),
                  .frn_fdis_iu6_i0_ord(frn_fdis_iu6_t0_i0_ord),
                  .frn_fdis_iu6_i0_cord(frn_fdis_iu6_t0_i0_cord),
                  .frn_fdis_iu6_i0_error(frn_fdis_iu6_t0_i0_error),
                  .frn_fdis_iu6_i0_fusion(frn_fdis_iu6_t0_i0_fusion),
                  .frn_fdis_iu6_i0_spec(frn_fdis_iu6_t0_i0_spec),
                  .frn_fdis_iu6_i0_type_fp(frn_fdis_iu6_t0_i0_type_fp),
                  .frn_fdis_iu6_i0_type_ap(frn_fdis_iu6_t0_i0_type_ap),
                  .frn_fdis_iu6_i0_type_spv(frn_fdis_iu6_t0_i0_type_spv),
                  .frn_fdis_iu6_i0_type_st(frn_fdis_iu6_t0_i0_type_st),
                  .frn_fdis_iu6_i0_async_block(frn_fdis_iu6_t0_i0_async_block),
                  .frn_fdis_iu6_i0_np1_flush(frn_fdis_iu6_t0_i0_np1_flush),
                  .frn_fdis_iu6_i0_core_block(frn_fdis_iu6_t0_i0_core_block),
                  .frn_fdis_iu6_i0_isram(frn_fdis_iu6_t0_i0_isram),
                  .frn_fdis_iu6_i0_isload(frn_fdis_iu6_t0_i0_isload),
                  .frn_fdis_iu6_i0_isstore(frn_fdis_iu6_t0_i0_isstore),
                  .frn_fdis_iu6_i0_instr(frn_fdis_iu6_t0_i0_instr),
                  .frn_fdis_iu6_i0_ifar(frn_fdis_iu6_t0_i0_ifar),
                  .frn_fdis_iu6_i0_bta(frn_fdis_iu6_t0_i0_bta),
                  .frn_fdis_iu6_i0_br_pred(frn_fdis_iu6_t0_i0_br_pred),
                  .frn_fdis_iu6_i0_bh_update(frn_fdis_iu6_t0_i0_bh_update),
                  .frn_fdis_iu6_i0_bh0_hist(frn_fdis_iu6_t0_i0_bh0_hist),
                  .frn_fdis_iu6_i0_bh1_hist(frn_fdis_iu6_t0_i0_bh1_hist),
                  .frn_fdis_iu6_i0_bh2_hist(frn_fdis_iu6_t0_i0_bh2_hist),
                  .frn_fdis_iu6_i0_gshare(frn_fdis_iu6_t0_i0_gshare),
                  .frn_fdis_iu6_i0_ls_ptr(frn_fdis_iu6_t0_i0_ls_ptr),
                  .frn_fdis_iu6_i0_match(frn_fdis_iu6_t0_i0_match),
                  .frn_fdis_iu6_i0_btb_entry(frn_fdis_iu6_t0_i0_btb_entry),
                  .frn_fdis_iu6_i0_btb_hist(frn_fdis_iu6_t0_i0_btb_hist),
                  .frn_fdis_iu6_i0_bta_val(frn_fdis_iu6_t0_i0_bta_val),
                  .frn_fdis_iu6_i0_ilat(frn_fdis_iu6_t0_i0_ilat),
                  .frn_fdis_iu6_i0_t1_v(frn_fdis_iu6_t0_i0_t1_v),
                  .frn_fdis_iu6_i0_t1_t(frn_fdis_iu6_t0_i0_t1_t),
                  .frn_fdis_iu6_i0_t1_a(frn_fdis_iu6_t0_i0_t1_a),
                  .frn_fdis_iu6_i0_t1_p(frn_fdis_iu6_t0_i0_t1_p),
                  .frn_fdis_iu6_i0_t2_v(frn_fdis_iu6_t0_i0_t2_v),
                  .frn_fdis_iu6_i0_t2_a(frn_fdis_iu6_t0_i0_t2_a),
                  .frn_fdis_iu6_i0_t2_p(frn_fdis_iu6_t0_i0_t2_p),
                  .frn_fdis_iu6_i0_t2_t(frn_fdis_iu6_t0_i0_t2_t),
                  .frn_fdis_iu6_i0_t3_v(frn_fdis_iu6_t0_i0_t3_v),
                  .frn_fdis_iu6_i0_t3_a(frn_fdis_iu6_t0_i0_t3_a),
                  .frn_fdis_iu6_i0_t3_p(frn_fdis_iu6_t0_i0_t3_p),
                  .frn_fdis_iu6_i0_t3_t(frn_fdis_iu6_t0_i0_t3_t),
                  .frn_fdis_iu6_i0_s1_v(frn_fdis_iu6_t0_i0_s1_v),
                  .frn_fdis_iu6_i0_s1_a(frn_fdis_iu6_t0_i0_s1_a),
                  .frn_fdis_iu6_i0_s1_p(frn_fdis_iu6_t0_i0_s1_p),
                  .frn_fdis_iu6_i0_s1_itag(frn_fdis_iu6_t0_i0_s1_itag),
                  .frn_fdis_iu6_i0_s1_t(frn_fdis_iu6_t0_i0_s1_t),
                  .frn_fdis_iu6_i0_s2_v(frn_fdis_iu6_t0_i0_s2_v),
                  .frn_fdis_iu6_i0_s2_a(frn_fdis_iu6_t0_i0_s2_a),
                  .frn_fdis_iu6_i0_s2_p(frn_fdis_iu6_t0_i0_s2_p),
                  .frn_fdis_iu6_i0_s2_itag(frn_fdis_iu6_t0_i0_s2_itag),
                  .frn_fdis_iu6_i0_s2_t(frn_fdis_iu6_t0_i0_s2_t),
                  .frn_fdis_iu6_i0_s3_v(frn_fdis_iu6_t0_i0_s3_v),
                  .frn_fdis_iu6_i0_s3_a(frn_fdis_iu6_t0_i0_s3_a),
                  .frn_fdis_iu6_i0_s3_p(frn_fdis_iu6_t0_i0_s3_p),
                  .frn_fdis_iu6_i0_s3_itag(frn_fdis_iu6_t0_i0_s3_itag),
                  .frn_fdis_iu6_i0_s3_t(frn_fdis_iu6_t0_i0_s3_t),

                  .frn_fdis_iu6_i1_vld(frn_fdis_iu6_t0_i1_vld),
                  .frn_fdis_iu6_i1_itag(frn_fdis_iu6_t0_i1_itag),
                  .frn_fdis_iu6_i1_ucode(frn_fdis_iu6_t0_i1_ucode),
                  .frn_fdis_iu6_i1_ucode_cnt(frn_fdis_iu6_t0_i1_ucode_cnt),
                  .frn_fdis_iu6_i1_fuse_nop(frn_fdis_iu6_t0_i1_fuse_nop),
                  .frn_fdis_iu6_i1_rte_lq(frn_fdis_iu6_t0_i1_rte_lq),
                  .frn_fdis_iu6_i1_rte_sq(frn_fdis_iu6_t0_i1_rte_sq),
                  .frn_fdis_iu6_i1_rte_fx0(frn_fdis_iu6_t0_i1_rte_fx0),
                  .frn_fdis_iu6_i1_rte_fx1(frn_fdis_iu6_t0_i1_rte_fx1),
                  .frn_fdis_iu6_i1_rte_axu0(frn_fdis_iu6_t0_i1_rte_axu0),
                  .frn_fdis_iu6_i1_rte_axu1(frn_fdis_iu6_t0_i1_rte_axu1),
                  .frn_fdis_iu6_i1_valop(frn_fdis_iu6_t0_i1_valop),
                  .frn_fdis_iu6_i1_ord(frn_fdis_iu6_t0_i1_ord),
                  .frn_fdis_iu6_i1_cord(frn_fdis_iu6_t0_i1_cord),
                  .frn_fdis_iu6_i1_error(frn_fdis_iu6_t0_i1_error),
                  .frn_fdis_iu6_i1_fusion(frn_fdis_iu6_t0_i1_fusion),
                  .frn_fdis_iu6_i1_spec(frn_fdis_iu6_t0_i1_spec),
                  .frn_fdis_iu6_i1_type_fp(frn_fdis_iu6_t0_i1_type_fp),
                  .frn_fdis_iu6_i1_type_ap(frn_fdis_iu6_t0_i1_type_ap),
                  .frn_fdis_iu6_i1_type_spv(frn_fdis_iu6_t0_i1_type_spv),
                  .frn_fdis_iu6_i1_type_st(frn_fdis_iu6_t0_i1_type_st),
                  .frn_fdis_iu6_i1_async_block(frn_fdis_iu6_t0_i1_async_block),
                  .frn_fdis_iu6_i1_np1_flush(frn_fdis_iu6_t0_i1_np1_flush),
                  .frn_fdis_iu6_i1_core_block(frn_fdis_iu6_t0_i1_core_block),
                  .frn_fdis_iu6_i1_isram(frn_fdis_iu6_t0_i1_isram),
                  .frn_fdis_iu6_i1_isload(frn_fdis_iu6_t0_i1_isload),
                  .frn_fdis_iu6_i1_isstore(frn_fdis_iu6_t0_i1_isstore),
                  .frn_fdis_iu6_i1_instr(frn_fdis_iu6_t0_i1_instr),
                  .frn_fdis_iu6_i1_ifar(frn_fdis_iu6_t0_i1_ifar),
                  .frn_fdis_iu6_i1_bta(frn_fdis_iu6_t0_i1_bta),
                  .frn_fdis_iu6_i1_br_pred(frn_fdis_iu6_t0_i1_br_pred),
                  .frn_fdis_iu6_i1_bh_update(frn_fdis_iu6_t0_i1_bh_update),
                  .frn_fdis_iu6_i1_bh0_hist(frn_fdis_iu6_t0_i1_bh0_hist),
                  .frn_fdis_iu6_i1_bh1_hist(frn_fdis_iu6_t0_i1_bh1_hist),
                  .frn_fdis_iu6_i1_bh2_hist(frn_fdis_iu6_t0_i1_bh2_hist),
                  .frn_fdis_iu6_i1_gshare(frn_fdis_iu6_t0_i1_gshare),
                  .frn_fdis_iu6_i1_ls_ptr(frn_fdis_iu6_t0_i1_ls_ptr),
                  .frn_fdis_iu6_i1_match(frn_fdis_iu6_t0_i1_match),
                  .frn_fdis_iu6_i1_btb_entry(frn_fdis_iu6_t0_i1_btb_entry),
                  .frn_fdis_iu6_i1_btb_hist(frn_fdis_iu6_t0_i1_btb_hist),
                  .frn_fdis_iu6_i1_bta_val(frn_fdis_iu6_t0_i1_bta_val),
                  .frn_fdis_iu6_i1_ilat(frn_fdis_iu6_t0_i1_ilat),
                  .frn_fdis_iu6_i1_t1_v(frn_fdis_iu6_t0_i1_t1_v),
                  .frn_fdis_iu6_i1_t1_t(frn_fdis_iu6_t0_i1_t1_t),
                  .frn_fdis_iu6_i1_t1_a(frn_fdis_iu6_t0_i1_t1_a),
                  .frn_fdis_iu6_i1_t1_p(frn_fdis_iu6_t0_i1_t1_p),
                  .frn_fdis_iu6_i1_t2_v(frn_fdis_iu6_t0_i1_t2_v),
                  .frn_fdis_iu6_i1_t2_a(frn_fdis_iu6_t0_i1_t2_a),
                  .frn_fdis_iu6_i1_t2_p(frn_fdis_iu6_t0_i1_t2_p),
                  .frn_fdis_iu6_i1_t2_t(frn_fdis_iu6_t0_i1_t2_t),
                  .frn_fdis_iu6_i1_t3_v(frn_fdis_iu6_t0_i1_t3_v),
                  .frn_fdis_iu6_i1_t3_a(frn_fdis_iu6_t0_i1_t3_a),
                  .frn_fdis_iu6_i1_t3_p(frn_fdis_iu6_t0_i1_t3_p),
                  .frn_fdis_iu6_i1_t3_t(frn_fdis_iu6_t0_i1_t3_t),
                  .frn_fdis_iu6_i1_s1_v(frn_fdis_iu6_t0_i1_s1_v),
                  .frn_fdis_iu6_i1_s1_a(frn_fdis_iu6_t0_i1_s1_a),
                  .frn_fdis_iu6_i1_s1_p(frn_fdis_iu6_t0_i1_s1_p),
                  .frn_fdis_iu6_i1_s1_itag(frn_fdis_iu6_t0_i1_s1_itag),
                  .frn_fdis_iu6_i1_s1_t(frn_fdis_iu6_t0_i1_s1_t),
                  .frn_fdis_iu6_i1_s1_dep_hit(frn_fdis_iu6_t0_i1_s1_dep_hit),
                  .frn_fdis_iu6_i1_s2_v(frn_fdis_iu6_t0_i1_s2_v),
                  .frn_fdis_iu6_i1_s2_a(frn_fdis_iu6_t0_i1_s2_a),
                  .frn_fdis_iu6_i1_s2_p(frn_fdis_iu6_t0_i1_s2_p),
                  .frn_fdis_iu6_i1_s2_itag(frn_fdis_iu6_t0_i1_s2_itag),
                  .frn_fdis_iu6_i1_s2_t(frn_fdis_iu6_t0_i1_s2_t),
                  .frn_fdis_iu6_i1_s2_dep_hit(frn_fdis_iu6_t0_i1_s2_dep_hit),
                  .frn_fdis_iu6_i1_s3_v(frn_fdis_iu6_t0_i1_s3_v),
                  .frn_fdis_iu6_i1_s3_a(frn_fdis_iu6_t0_i1_s3_a),
                  .frn_fdis_iu6_i1_s3_p(frn_fdis_iu6_t0_i1_s3_p),
                  .frn_fdis_iu6_i1_s3_itag(frn_fdis_iu6_t0_i1_s3_itag),
                  .frn_fdis_iu6_i1_s3_t(frn_fdis_iu6_t0_i1_s3_t),
                  .frn_fdis_iu6_i1_s3_dep_hit(frn_fdis_iu6_t0_i1_s3_dep_hit)
               );

`ifndef THREADS1
              iuq_slice  slice1(
                  .vdd(vdd),
                  .gnd(gnd),
                  .nclk(nclk),
                  .pc_iu_sg_2(pc_iu_sg_2),
                  .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
                  .clkoff_b(clkoff_b),
                  .act_dis(act_dis),
                  .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
                  .d_mode(d_mode),
                  .delay_lclkr(delay_lclkr),
                  .mpw1_b(mpw1_b),
                  .mpw2_b(mpw2_b),
                  .scan_in(scan_in[8:14]),
                  .scan_out(scan_out[8:14]),

                  //-------------------------------
                  // Performance interface with I$
                  //-------------------------------
                  .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
                  .perf_iu5_stall(perf_iu5_stall[1]),
                  .perf_iu5_cpl_credit_stall(perf_iu5_cpl_credit_stall[1]),
                  .perf_iu5_gpr_credit_stall(perf_iu5_gpr_credit_stall[1]),
                  .perf_iu5_cr_credit_stall(perf_iu5_cr_credit_stall[1]),
                  .perf_iu5_lr_credit_stall(perf_iu5_lr_credit_stall[1]),
                  .perf_iu5_ctr_credit_stall(perf_iu5_ctr_credit_stall[1]),
                  .perf_iu5_xer_credit_stall(perf_iu5_xer_credit_stall[1]),
                  .perf_iu5_br_hold_stall(perf_iu5_br_hold_stall[1]),
                  .perf_iu5_axu_hold_stall(perf_iu5_axu_hold_stall[1]),

                  .cp_iu_iu4_flush(cp_iu_iu4_flush[1]),
                  .cp_flush_into_uc(cp_flush_into_uc[1]),

                  .xu_iu_epcr_dgtmi(xu_iu_epcr_dgtmi[1]),
                  .xu_iu_msrp_uclep(xu_iu_msrp_uclep[1]),
                  .xu_iu_msr_pr(xu_iu_msr_pr[1]),
                  .xu_iu_msr_gs(xu_iu_msr_gs[1]),
                  .xu_iu_msr_ucle(xu_iu_msr_ucle[1]),
                  .xu_iu_ccr2_ucode_dis(xu_iu_ccr2_ucode_dis),

                  //-----------------------------
                  // SPR values
                  //-----------------------------
                  .spr_high_pri_mask(spr_high_pri_mask[1]),
                  .spr_cpcr_we(spr_cpcr_we[1]),
                  .spr_cpcr3_cp_cnt(spr_t1_cpcr3_cp_cnt),
                  .spr_cpcr5_cp_cnt(spr_t1_cpcr5_cp_cnt),
                  .spr_single_issue(spr_single_issue[1]),
                  .spr_dec_mask(spr_dec_mask),
                  .spr_dec_match(spr_dec_match),
                  .iu_au_config_iucr(iu_au_t1_config_iucr),
                  .mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),

                  //----------------------------
                  // Ifetch with slice
                  //----------------------------
                  .ib_rm_rdy(ib_rm_rdy[1]),
                  .rm_ib_iu3_val(rm_ib_iu3_val[1]),
                  .rm_ib_iu3_instr(rm_ib_iu3_instr),

                  .uc_ib_iu3_invalid(uc_ib_iu3_t1_invalid),

                  .ib_ic_need_fetch(ib_ic_t1_need_fetch),

                  .bp_ib_iu3_val(bp_ib_iu3_t1_val),
                  .bp_ib_iu3_ifar(bp_ib_iu3_t1_ifar),
                  .bp_ib_iu3_0_instr(bp_ib_iu3_t1_0_instr),
                  .bp_ib_iu3_1_instr(bp_ib_iu3_t1_1_instr),
                  .bp_ib_iu3_2_instr(bp_ib_iu3_t1_2_instr),
                  .bp_ib_iu3_3_instr(bp_ib_iu3_t1_3_instr),
                  .bp_ib_iu3_bta(bp_ib_iu3_t1_bta),

                  //----------------------------
                  // Ucode interface with IB
                  //----------------------------
                  .ib_uc_rdy(ib_uc_rdy[1]),
                  .uc_ib_val(uc_ib_t1_val),
                  .uc_ib_done(uc_ib_done[1]),
                  .uc_ib_instr0(uc_ib_t1_instr0),
                  .uc_ib_instr1(uc_ib_t1_instr1),
                  .uc_ib_ifar0(uc_ib_t1_ifar0),
                  .uc_ib_ifar1(uc_ib_t1_ifar1),
                  .uc_ib_ext0(uc_ib_t1_ext0),
                  .uc_ib_ext1(uc_ib_t1_ext1),

                  //----------------------------
                  // Completion Interface
                  //----------------------------
                  .cp_rn_i0_axu_exception_val(cp_rn_t1_i0_axu_exception_val),
                  .cp_rn_i0_axu_exception(cp_rn_t1_i0_axu_exception),
                  .cp_rn_i1_axu_exception_val(cp_rn_t1_i1_axu_exception_val),
                  .cp_rn_i1_axu_exception(cp_rn_t1_i1_axu_exception),
                  .cp_rn_empty(cp_rn_empty[1]),
                  .cp_rn_i0_v(cp_rn_t1_i0_v),
                  .cp_rn_i0_itag(cp_rn_t1_i0_itag),
                  .cp_rn_i0_t1_v(cp_rn_t1_i0_t1_v),
                  .cp_rn_i0_t1_t(cp_rn_t1_i0_t1_t),
                  .cp_rn_i0_t1_p(cp_rn_t1_i0_t1_p),
                  .cp_rn_i0_t1_a(cp_rn_t1_i0_t1_a),
                  .cp_rn_i0_t2_v(cp_rn_t1_i0_t2_v),
                  .cp_rn_i0_t2_t(cp_rn_t1_i0_t2_t),
                  .cp_rn_i0_t2_p(cp_rn_t1_i0_t2_p),
                  .cp_rn_i0_t2_a(cp_rn_t1_i0_t2_a),
                  .cp_rn_i0_t3_v(cp_rn_t1_i0_t3_v),
                  .cp_rn_i0_t3_t(cp_rn_t1_i0_t3_t),
                  .cp_rn_i0_t3_p(cp_rn_t1_i0_t3_p),
                  .cp_rn_i0_t3_a(cp_rn_t1_i0_t3_a),

                  .cp_rn_i1_v(cp_rn_t1_i1_v),
                  .cp_rn_i1_itag(cp_rn_t1_i1_itag),
                  .cp_rn_i1_t1_v(cp_rn_t1_i1_t1_v),
                  .cp_rn_i1_t1_t(cp_rn_t1_i1_t1_t),
                  .cp_rn_i1_t1_p(cp_rn_t1_i1_t1_p),
                  .cp_rn_i1_t1_a(cp_rn_t1_i1_t1_a),
                  .cp_rn_i1_t2_v(cp_rn_t1_i1_t2_v),
                  .cp_rn_i1_t2_t(cp_rn_t1_i1_t2_t),
                  .cp_rn_i1_t2_p(cp_rn_t1_i1_t2_p),
                  .cp_rn_i1_t2_a(cp_rn_t1_i1_t2_a),
                  .cp_rn_i1_t3_v(cp_rn_t1_i1_t3_v),
                  .cp_rn_i1_t3_t(cp_rn_t1_i1_t3_t),
                  .cp_rn_i1_t3_p(cp_rn_t1_i1_t3_p),
                  .cp_rn_i1_t3_a(cp_rn_t1_i1_t3_a),

                  .iu_flush(iu_flush[1]),
                  .cp_flush(cp_flush[1]),
                  .br_iu_redirect(br_iu_redirect[1]),
		  .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all[1]),
                  .cp_rn_uc_credit_free(cp_rn_uc_credit_free[1]),

                  //-----------------------------
                  // Stall from dispatch
                  //-----------------------------
                  .fdis_frn_iu6_stall(fdis_frn_iu6_stall[1]),

                  //----------------------------------------------------------------
                  // Interface to reservation station - Completion is snooping also
                  //----------------------------------------------------------------
                  .frn_fdis_iu6_i0_vld(frn_fdis_iu6_t1_i0_vld),
                  .frn_fdis_iu6_i0_itag(frn_fdis_iu6_t1_i0_itag),
                  .frn_fdis_iu6_i0_ucode(frn_fdis_iu6_t1_i0_ucode),
                  .frn_fdis_iu6_i0_ucode_cnt(frn_fdis_iu6_t1_i0_ucode_cnt),
                  .frn_fdis_iu6_i0_2ucode(frn_fdis_iu6_t1_i0_2ucode),
                  .frn_fdis_iu6_i0_fuse_nop(frn_fdis_iu6_t1_i0_fuse_nop),
                  .frn_fdis_iu6_i0_rte_lq(frn_fdis_iu6_t1_i0_rte_lq),
                  .frn_fdis_iu6_i0_rte_sq(frn_fdis_iu6_t1_i0_rte_sq),
                  .frn_fdis_iu6_i0_rte_fx0(frn_fdis_iu6_t1_i0_rte_fx0),
                  .frn_fdis_iu6_i0_rte_fx1(frn_fdis_iu6_t1_i0_rte_fx1),
                  .frn_fdis_iu6_i0_rte_axu0(frn_fdis_iu6_t1_i0_rte_axu0),
                  .frn_fdis_iu6_i0_rte_axu1(frn_fdis_iu6_t1_i0_rte_axu1),
                  .frn_fdis_iu6_i0_valop(frn_fdis_iu6_t1_i0_valop),
                  .frn_fdis_iu6_i0_ord(frn_fdis_iu6_t1_i0_ord),
                  .frn_fdis_iu6_i0_cord(frn_fdis_iu6_t1_i0_cord),
                  .frn_fdis_iu6_i0_error(frn_fdis_iu6_t1_i0_error),
                  .frn_fdis_iu6_i0_fusion(frn_fdis_iu6_t1_i0_fusion),
                  .frn_fdis_iu6_i0_spec(frn_fdis_iu6_t1_i0_spec),
                  .frn_fdis_iu6_i0_type_fp(frn_fdis_iu6_t1_i0_type_fp),
                  .frn_fdis_iu6_i0_type_ap(frn_fdis_iu6_t1_i0_type_ap),
                  .frn_fdis_iu6_i0_type_spv(frn_fdis_iu6_t1_i0_type_spv),
                  .frn_fdis_iu6_i0_type_st(frn_fdis_iu6_t1_i0_type_st),
                  .frn_fdis_iu6_i0_async_block(frn_fdis_iu6_t1_i0_async_block),
                  .frn_fdis_iu6_i0_np1_flush(frn_fdis_iu6_t1_i0_np1_flush),
                  .frn_fdis_iu6_i0_core_block(frn_fdis_iu6_t1_i0_core_block),
                  .frn_fdis_iu6_i0_isram(frn_fdis_iu6_t1_i0_isram),
                  .frn_fdis_iu6_i0_isload(frn_fdis_iu6_t1_i0_isload),
                  .frn_fdis_iu6_i0_isstore(frn_fdis_iu6_t1_i0_isstore),
                  .frn_fdis_iu6_i0_instr(frn_fdis_iu6_t1_i0_instr),
                  .frn_fdis_iu6_i0_ifar(frn_fdis_iu6_t1_i0_ifar),
                  .frn_fdis_iu6_i0_bta(frn_fdis_iu6_t1_i0_bta),
                  .frn_fdis_iu6_i0_br_pred(frn_fdis_iu6_t1_i0_br_pred),
                  .frn_fdis_iu6_i0_bh_update(frn_fdis_iu6_t1_i0_bh_update),
                  .frn_fdis_iu6_i0_bh0_hist(frn_fdis_iu6_t1_i0_bh0_hist),
                  .frn_fdis_iu6_i0_bh1_hist(frn_fdis_iu6_t1_i0_bh1_hist),
                  .frn_fdis_iu6_i0_bh2_hist(frn_fdis_iu6_t1_i0_bh2_hist),
                  .frn_fdis_iu6_i0_gshare(frn_fdis_iu6_t1_i0_gshare),
                  .frn_fdis_iu6_i0_ls_ptr(frn_fdis_iu6_t1_i0_ls_ptr),
                  .frn_fdis_iu6_i0_match(frn_fdis_iu6_t1_i0_match),
                  .frn_fdis_iu6_i0_btb_entry(frn_fdis_iu6_t1_i0_btb_entry),
                  .frn_fdis_iu6_i0_btb_hist(frn_fdis_iu6_t1_i0_btb_hist),
                  .frn_fdis_iu6_i0_bta_val(frn_fdis_iu6_t1_i0_bta_val),
                  .frn_fdis_iu6_i0_ilat(frn_fdis_iu6_t1_i0_ilat),
                  .frn_fdis_iu6_i0_t1_v(frn_fdis_iu6_t1_i0_t1_v),
                  .frn_fdis_iu6_i0_t1_t(frn_fdis_iu6_t1_i0_t1_t),
                  .frn_fdis_iu6_i0_t1_a(frn_fdis_iu6_t1_i0_t1_a),
                  .frn_fdis_iu6_i0_t1_p(frn_fdis_iu6_t1_i0_t1_p),
                  .frn_fdis_iu6_i0_t2_v(frn_fdis_iu6_t1_i0_t2_v),
                  .frn_fdis_iu6_i0_t2_a(frn_fdis_iu6_t1_i0_t2_a),
                  .frn_fdis_iu6_i0_t2_p(frn_fdis_iu6_t1_i0_t2_p),
                  .frn_fdis_iu6_i0_t2_t(frn_fdis_iu6_t1_i0_t2_t),
                  .frn_fdis_iu6_i0_t3_v(frn_fdis_iu6_t1_i0_t3_v),
                  .frn_fdis_iu6_i0_t3_a(frn_fdis_iu6_t1_i0_t3_a),
                  .frn_fdis_iu6_i0_t3_p(frn_fdis_iu6_t1_i0_t3_p),
                  .frn_fdis_iu6_i0_t3_t(frn_fdis_iu6_t1_i0_t3_t),
                  .frn_fdis_iu6_i0_s1_v(frn_fdis_iu6_t1_i0_s1_v),
                  .frn_fdis_iu6_i0_s1_a(frn_fdis_iu6_t1_i0_s1_a),
                  .frn_fdis_iu6_i0_s1_p(frn_fdis_iu6_t1_i0_s1_p),
                  .frn_fdis_iu6_i0_s1_itag(frn_fdis_iu6_t1_i0_s1_itag),
                  .frn_fdis_iu6_i0_s1_t(frn_fdis_iu6_t1_i0_s1_t),
                  .frn_fdis_iu6_i0_s2_v(frn_fdis_iu6_t1_i0_s2_v),
                  .frn_fdis_iu6_i0_s2_a(frn_fdis_iu6_t1_i0_s2_a),
                  .frn_fdis_iu6_i0_s2_p(frn_fdis_iu6_t1_i0_s2_p),
                  .frn_fdis_iu6_i0_s2_itag(frn_fdis_iu6_t1_i0_s2_itag),
                  .frn_fdis_iu6_i0_s2_t(frn_fdis_iu6_t1_i0_s2_t),
                  .frn_fdis_iu6_i0_s3_v(frn_fdis_iu6_t1_i0_s3_v),
                  .frn_fdis_iu6_i0_s3_a(frn_fdis_iu6_t1_i0_s3_a),
                  .frn_fdis_iu6_i0_s3_p(frn_fdis_iu6_t1_i0_s3_p),
                  .frn_fdis_iu6_i0_s3_itag(frn_fdis_iu6_t1_i0_s3_itag),
                  .frn_fdis_iu6_i0_s3_t(frn_fdis_iu6_t1_i0_s3_t),

                  .frn_fdis_iu6_i1_vld(frn_fdis_iu6_t1_i1_vld),
                  .frn_fdis_iu6_i1_itag(frn_fdis_iu6_t1_i1_itag),
                  .frn_fdis_iu6_i1_ucode(frn_fdis_iu6_t1_i1_ucode),
                  .frn_fdis_iu6_i1_ucode_cnt(frn_fdis_iu6_t1_i1_ucode_cnt),
                  .frn_fdis_iu6_i1_fuse_nop(frn_fdis_iu6_t1_i1_fuse_nop),
                  .frn_fdis_iu6_i1_rte_lq(frn_fdis_iu6_t1_i1_rte_lq),
                  .frn_fdis_iu6_i1_rte_sq(frn_fdis_iu6_t1_i1_rte_sq),
                  .frn_fdis_iu6_i1_rte_fx0(frn_fdis_iu6_t1_i1_rte_fx0),
                  .frn_fdis_iu6_i1_rte_fx1(frn_fdis_iu6_t1_i1_rte_fx1),
                  .frn_fdis_iu6_i1_rte_axu0(frn_fdis_iu6_t1_i1_rte_axu0),
                  .frn_fdis_iu6_i1_rte_axu1(frn_fdis_iu6_t1_i1_rte_axu1),
                  .frn_fdis_iu6_i1_valop(frn_fdis_iu6_t1_i1_valop),
                  .frn_fdis_iu6_i1_ord(frn_fdis_iu6_t1_i1_ord),
                  .frn_fdis_iu6_i1_cord(frn_fdis_iu6_t1_i1_cord),
                  .frn_fdis_iu6_i1_error(frn_fdis_iu6_t1_i1_error),
                  .frn_fdis_iu6_i1_fusion(frn_fdis_iu6_t1_i1_fusion),
                  .frn_fdis_iu6_i1_spec(frn_fdis_iu6_t1_i1_spec),
                  .frn_fdis_iu6_i1_type_fp(frn_fdis_iu6_t1_i1_type_fp),
                  .frn_fdis_iu6_i1_type_ap(frn_fdis_iu6_t1_i1_type_ap),
                  .frn_fdis_iu6_i1_type_spv(frn_fdis_iu6_t1_i1_type_spv),
                  .frn_fdis_iu6_i1_type_st(frn_fdis_iu6_t1_i1_type_st),
                  .frn_fdis_iu6_i1_async_block(frn_fdis_iu6_t1_i1_async_block),
                  .frn_fdis_iu6_i1_np1_flush(frn_fdis_iu6_t1_i1_np1_flush),
                  .frn_fdis_iu6_i1_core_block(frn_fdis_iu6_t1_i1_core_block),
                  .frn_fdis_iu6_i1_isram(frn_fdis_iu6_t1_i1_isram),
                  .frn_fdis_iu6_i1_isload(frn_fdis_iu6_t1_i1_isload),
                  .frn_fdis_iu6_i1_isstore(frn_fdis_iu6_t1_i1_isstore),
                  .frn_fdis_iu6_i1_instr(frn_fdis_iu6_t1_i1_instr),
                  .frn_fdis_iu6_i1_ifar(frn_fdis_iu6_t1_i1_ifar),
                  .frn_fdis_iu6_i1_bta(frn_fdis_iu6_t1_i1_bta),
                  .frn_fdis_iu6_i1_br_pred(frn_fdis_iu6_t1_i1_br_pred),
                  .frn_fdis_iu6_i1_bh_update(frn_fdis_iu6_t1_i1_bh_update),
                  .frn_fdis_iu6_i1_bh0_hist(frn_fdis_iu6_t1_i1_bh0_hist),
                  .frn_fdis_iu6_i1_bh1_hist(frn_fdis_iu6_t1_i1_bh1_hist),
                  .frn_fdis_iu6_i1_bh2_hist(frn_fdis_iu6_t1_i1_bh2_hist),
                  .frn_fdis_iu6_i1_gshare(frn_fdis_iu6_t1_i1_gshare),
                  .frn_fdis_iu6_i1_ls_ptr(frn_fdis_iu6_t1_i1_ls_ptr),
                  .frn_fdis_iu6_i1_match(frn_fdis_iu6_t1_i1_match),
                  .frn_fdis_iu6_i1_btb_entry(frn_fdis_iu6_t1_i1_btb_entry),
                  .frn_fdis_iu6_i1_btb_hist(frn_fdis_iu6_t1_i1_btb_hist),
                  .frn_fdis_iu6_i1_bta_val(frn_fdis_iu6_t1_i1_bta_val),
                  .frn_fdis_iu6_i1_ilat(frn_fdis_iu6_t1_i1_ilat),
                  .frn_fdis_iu6_i1_t1_v(frn_fdis_iu6_t1_i1_t1_v),
                  .frn_fdis_iu6_i1_t1_t(frn_fdis_iu6_t1_i1_t1_t),
                  .frn_fdis_iu6_i1_t1_a(frn_fdis_iu6_t1_i1_t1_a),
                  .frn_fdis_iu6_i1_t1_p(frn_fdis_iu6_t1_i1_t1_p),
                  .frn_fdis_iu6_i1_t2_v(frn_fdis_iu6_t1_i1_t2_v),
                  .frn_fdis_iu6_i1_t2_a(frn_fdis_iu6_t1_i1_t2_a),
                  .frn_fdis_iu6_i1_t2_p(frn_fdis_iu6_t1_i1_t2_p),
                  .frn_fdis_iu6_i1_t2_t(frn_fdis_iu6_t1_i1_t2_t),
                  .frn_fdis_iu6_i1_t3_v(frn_fdis_iu6_t1_i1_t3_v),
                  .frn_fdis_iu6_i1_t3_a(frn_fdis_iu6_t1_i1_t3_a),
                  .frn_fdis_iu6_i1_t3_p(frn_fdis_iu6_t1_i1_t3_p),
                  .frn_fdis_iu6_i1_t3_t(frn_fdis_iu6_t1_i1_t3_t),
                  .frn_fdis_iu6_i1_s1_v(frn_fdis_iu6_t1_i1_s1_v),
                  .frn_fdis_iu6_i1_s1_a(frn_fdis_iu6_t1_i1_s1_a),
                  .frn_fdis_iu6_i1_s1_p(frn_fdis_iu6_t1_i1_s1_p),
                  .frn_fdis_iu6_i1_s1_itag(frn_fdis_iu6_t1_i1_s1_itag),
                  .frn_fdis_iu6_i1_s1_t(frn_fdis_iu6_t1_i1_s1_t),
                  .frn_fdis_iu6_i1_s1_dep_hit(frn_fdis_iu6_t1_i1_s1_dep_hit),
                  .frn_fdis_iu6_i1_s2_v(frn_fdis_iu6_t1_i1_s2_v),
                  .frn_fdis_iu6_i1_s2_a(frn_fdis_iu6_t1_i1_s2_a),
                  .frn_fdis_iu6_i1_s2_p(frn_fdis_iu6_t1_i1_s2_p),
                  .frn_fdis_iu6_i1_s2_itag(frn_fdis_iu6_t1_i1_s2_itag),
                  .frn_fdis_iu6_i1_s2_t(frn_fdis_iu6_t1_i1_s2_t),
                  .frn_fdis_iu6_i1_s2_dep_hit(frn_fdis_iu6_t1_i1_s2_dep_hit),
                  .frn_fdis_iu6_i1_s3_v(frn_fdis_iu6_t1_i1_s3_v),
                  .frn_fdis_iu6_i1_s3_a(frn_fdis_iu6_t1_i1_s3_a),
                  .frn_fdis_iu6_i1_s3_p(frn_fdis_iu6_t1_i1_s3_p),
                  .frn_fdis_iu6_i1_s3_itag(frn_fdis_iu6_t1_i1_s3_itag),
                  .frn_fdis_iu6_i1_s3_t(frn_fdis_iu6_t1_i1_s3_t),
                  .frn_fdis_iu6_i1_s3_dep_hit(frn_fdis_iu6_t1_i1_s3_dep_hit)
               );
`endif

         iuq_dispatch dispatch(
            .vdd(vdd),
            .gnd(gnd),
            .nclk(nclk),
            .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
            .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
            .pc_iu_sg_2(pc_iu_sg_2),
            .clkoff_b(clkoff_b),
            .act_dis(act_dis),
            .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
            .d_mode(d_mode),
            .delay_lclkr(delay_lclkr),
            .mpw1_b(mpw1_b),
            .mpw2_b(mpw2_b),
            .scan_in(scan_in[0]),
            .scan_out(scan_out[0]),

            //-----------------------------
            // SPR connections
            //-----------------------------
            .spr_cpcr_we(spr_cpcr_we),
            .spr_t0_cpcr2_fx0_cnt(spr_t0_cpcr2_fx0_cnt),
            .spr_t0_cpcr2_fx1_cnt(spr_t0_cpcr2_fx1_cnt),
            .spr_t0_cpcr2_lq_cnt(spr_t0_cpcr2_lq_cnt),
            .spr_t0_cpcr2_sq_cnt(spr_t0_cpcr2_sq_cnt),
            .spr_t0_cpcr3_fu0_cnt(spr_t0_cpcr3_fu0_cnt),
            .spr_t0_cpcr3_fu1_cnt(spr_t0_cpcr3_fu1_cnt),
            .spr_t0_cpcr4_fx0_cnt(spr_t0_cpcr4_fx0_cnt),
            .spr_t0_cpcr4_fx1_cnt(spr_t0_cpcr4_fx1_cnt),
            .spr_t0_cpcr4_lq_cnt(spr_t0_cpcr4_lq_cnt),
            .spr_t0_cpcr4_sq_cnt(spr_t0_cpcr4_sq_cnt),
            .spr_t0_cpcr5_fu0_cnt(spr_t0_cpcr5_fu0_cnt),
            .spr_t0_cpcr5_fu1_cnt(spr_t0_cpcr5_fu1_cnt),
`ifndef THREADS1
            .spr_t1_cpcr2_fx0_cnt(spr_t1_cpcr2_fx0_cnt),
            .spr_t1_cpcr2_fx1_cnt(spr_t1_cpcr2_fx1_cnt),
            .spr_t1_cpcr2_lq_cnt(spr_t1_cpcr2_lq_cnt),
            .spr_t1_cpcr2_sq_cnt(spr_t1_cpcr2_sq_cnt),
            .spr_t1_cpcr3_fu0_cnt(spr_t1_cpcr3_fu0_cnt),
            .spr_t1_cpcr3_fu1_cnt(spr_t1_cpcr3_fu1_cnt),
            .spr_t1_cpcr4_fx0_cnt(spr_t1_cpcr4_fx0_cnt),
            .spr_t1_cpcr4_fx1_cnt(spr_t1_cpcr4_fx1_cnt),
            .spr_t1_cpcr4_lq_cnt(spr_t1_cpcr4_lq_cnt),
            .spr_t1_cpcr4_sq_cnt(spr_t1_cpcr4_sq_cnt),
            .spr_t1_cpcr5_fu0_cnt(spr_t1_cpcr5_fu0_cnt),
            .spr_t1_cpcr5_fu1_cnt(spr_t1_cpcr5_fu1_cnt),
`endif
            .spr_cpcr0_fx0_cnt(spr_cpcr0_fx0_cnt),
            .spr_cpcr0_fx1_cnt(spr_cpcr0_fx1_cnt),
            .spr_cpcr0_lq_cnt(spr_cpcr0_lq_cnt),
            .spr_cpcr0_sq_cnt(spr_cpcr0_sq_cnt),
            .spr_cpcr1_fu0_cnt(spr_cpcr1_fu0_cnt),
            .spr_cpcr1_fu1_cnt(spr_cpcr1_fu1_cnt),
            .spr_high_pri_mask(spr_high_pri_mask),
            .spr_med_pri_mask(spr_med_pri_mask),
            .spr_t0_low_pri_count(spr_t0_low_pri_count),
`ifndef THREADS1
            .spr_t1_low_pri_count(spr_t1_low_pri_count),
`endif

            //-------------------------------
            // Performance interface with I$
            //-------------------------------
            .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
            .perf_iu6_stall(perf_iu6_stall),
            .perf_iu6_dispatch_fx0(perf_iu6_dispatch_fx0),
            .perf_iu6_dispatch_fx1(perf_iu6_dispatch_fx1),
            .perf_iu6_dispatch_lq(perf_iu6_dispatch_lq),
            .perf_iu6_dispatch_axu0(perf_iu6_dispatch_axu0),
            .perf_iu6_dispatch_axu1(perf_iu6_dispatch_axu1),
            .perf_iu6_fx0_credit_stall(perf_iu6_fx0_credit_stall),
            .perf_iu6_fx1_credit_stall(perf_iu6_fx1_credit_stall),
            .perf_iu6_lq_credit_stall(perf_iu6_lq_credit_stall),
            .perf_iu6_sq_credit_stall(perf_iu6_sq_credit_stall),
            .perf_iu6_axu0_credit_stall(perf_iu6_axu0_credit_stall),
            .perf_iu6_axu1_credit_stall(perf_iu6_axu1_credit_stall),

            .iu_pc_fx0_credit_ok(iu_pc_fx0_credit_ok),
            .iu_pc_fx1_credit_ok(iu_pc_fx1_credit_ok),
            .iu_pc_lq_credit_ok(iu_pc_lq_credit_ok),
            .iu_pc_sq_credit_ok(iu_pc_sq_credit_ok),
            .iu_pc_axu0_credit_ok(iu_pc_axu0_credit_ok),
            .iu_pc_axu1_credit_ok(iu_pc_axu1_credit_ok),

            //----------------------------
            // Credit Interface with IU
            //----------------------------
            .rv_iu_fx0_credit_free(rv_iu_fx0_credit_free),
            .rv_iu_fx1_credit_free(rv_iu_fx1_credit_free),		// Need to add 2nd unit someday
            .lq_iu_credit_free(lq_iu_credit_free),
            .sq_iu_credit_free(sq_iu_credit_free),
            .axu0_iu_credit_free(axu0_iu_credit_free),		// credit free from axu reservation station
            .axu1_iu_credit_free(axu1_iu_credit_free),		// credit free from axu reservation station

            .cp_flush(cp_flush),
            .xu_iu_run_thread(xu_iu_run_thread),
            .iu_xu_credits_returned(iu_xu_credits_returned),

            //----------------------------------------------------------------
            // Interface with rename
            //----------------------------------------------------------------
            .frn_fdis_iu6_t0_i0_vld(frn_fdis_iu6_t0_i0_vld),
            .frn_fdis_iu6_t0_i0_itag(frn_fdis_iu6_t0_i0_itag),
            .frn_fdis_iu6_t0_i0_ucode(frn_fdis_iu6_t0_i0_ucode),
            .frn_fdis_iu6_t0_i0_ucode_cnt(frn_fdis_iu6_t0_i0_ucode_cnt),
            .frn_fdis_iu6_t0_i0_2ucode(frn_fdis_iu6_t0_i0_2ucode),
            .frn_fdis_iu6_t0_i0_fuse_nop(frn_fdis_iu6_t0_i0_fuse_nop),
            .frn_fdis_iu6_t0_i0_rte_lq(frn_fdis_iu6_t0_i0_rte_lq),
            .frn_fdis_iu6_t0_i0_rte_sq(frn_fdis_iu6_t0_i0_rte_sq),
            .frn_fdis_iu6_t0_i0_rte_fx0(frn_fdis_iu6_t0_i0_rte_fx0),
            .frn_fdis_iu6_t0_i0_rte_fx1(frn_fdis_iu6_t0_i0_rte_fx1),
            .frn_fdis_iu6_t0_i0_rte_axu0(frn_fdis_iu6_t0_i0_rte_axu0),
            .frn_fdis_iu6_t0_i0_rte_axu1(frn_fdis_iu6_t0_i0_rte_axu1),
            .frn_fdis_iu6_t0_i0_valop(frn_fdis_iu6_t0_i0_valop),
            .frn_fdis_iu6_t0_i0_ord(frn_fdis_iu6_t0_i0_ord),
            .frn_fdis_iu6_t0_i0_cord(frn_fdis_iu6_t0_i0_cord),
            .frn_fdis_iu6_t0_i0_error(frn_fdis_iu6_t0_i0_error),
            .frn_fdis_iu6_t0_i0_btb_entry(frn_fdis_iu6_t0_i0_btb_entry),
            .frn_fdis_iu6_t0_i0_btb_hist(frn_fdis_iu6_t0_i0_btb_hist),
            .frn_fdis_iu6_t0_i0_bta_val(frn_fdis_iu6_t0_i0_bta_val),
            .frn_fdis_iu6_t0_i0_fusion(frn_fdis_iu6_t0_i0_fusion),
            .frn_fdis_iu6_t0_i0_spec(frn_fdis_iu6_t0_i0_spec),
            .frn_fdis_iu6_t0_i0_type_fp(frn_fdis_iu6_t0_i0_type_fp),
            .frn_fdis_iu6_t0_i0_type_ap(frn_fdis_iu6_t0_i0_type_ap),
            .frn_fdis_iu6_t0_i0_type_spv(frn_fdis_iu6_t0_i0_type_spv),
            .frn_fdis_iu6_t0_i0_type_st(frn_fdis_iu6_t0_i0_type_st),
            .frn_fdis_iu6_t0_i0_async_block(frn_fdis_iu6_t0_i0_async_block),
            .frn_fdis_iu6_t0_i0_np1_flush(frn_fdis_iu6_t0_i0_np1_flush),
            .frn_fdis_iu6_t0_i0_core_block(frn_fdis_iu6_t0_i0_core_block),
            .frn_fdis_iu6_t0_i0_isram(frn_fdis_iu6_t0_i0_isram),
            .frn_fdis_iu6_t0_i0_isload(frn_fdis_iu6_t0_i0_isload),
            .frn_fdis_iu6_t0_i0_isstore(frn_fdis_iu6_t0_i0_isstore),
            .frn_fdis_iu6_t0_i0_instr(frn_fdis_iu6_t0_i0_instr),
            .frn_fdis_iu6_t0_i0_ifar(frn_fdis_iu6_t0_i0_ifar),
            .frn_fdis_iu6_t0_i0_bta(frn_fdis_iu6_t0_i0_bta),
            .frn_fdis_iu6_t0_i0_br_pred(frn_fdis_iu6_t0_i0_br_pred),
            .frn_fdis_iu6_t0_i0_bh_update(frn_fdis_iu6_t0_i0_bh_update),
            .frn_fdis_iu6_t0_i0_bh0_hist(frn_fdis_iu6_t0_i0_bh0_hist),
            .frn_fdis_iu6_t0_i0_bh1_hist(frn_fdis_iu6_t0_i0_bh1_hist),
            .frn_fdis_iu6_t0_i0_bh2_hist(frn_fdis_iu6_t0_i0_bh2_hist),
            .frn_fdis_iu6_t0_i0_gshare(frn_fdis_iu6_t0_i0_gshare),
            .frn_fdis_iu6_t0_i0_ls_ptr(frn_fdis_iu6_t0_i0_ls_ptr),
            .frn_fdis_iu6_t0_i0_match(frn_fdis_iu6_t0_i0_match),
            .frn_fdis_iu6_t0_i0_ilat(frn_fdis_iu6_t0_i0_ilat),
            .frn_fdis_iu6_t0_i0_t1_v(frn_fdis_iu6_t0_i0_t1_v),
            .frn_fdis_iu6_t0_i0_t1_t(frn_fdis_iu6_t0_i0_t1_t),
            .frn_fdis_iu6_t0_i0_t1_a(frn_fdis_iu6_t0_i0_t1_a),
            .frn_fdis_iu6_t0_i0_t1_p(frn_fdis_iu6_t0_i0_t1_p),
            .frn_fdis_iu6_t0_i0_t2_v(frn_fdis_iu6_t0_i0_t2_v),
            .frn_fdis_iu6_t0_i0_t2_a(frn_fdis_iu6_t0_i0_t2_a),
            .frn_fdis_iu6_t0_i0_t2_p(frn_fdis_iu6_t0_i0_t2_p),
            .frn_fdis_iu6_t0_i0_t2_t(frn_fdis_iu6_t0_i0_t2_t),
            .frn_fdis_iu6_t0_i0_t3_v(frn_fdis_iu6_t0_i0_t3_v),
            .frn_fdis_iu6_t0_i0_t3_a(frn_fdis_iu6_t0_i0_t3_a),
            .frn_fdis_iu6_t0_i0_t3_p(frn_fdis_iu6_t0_i0_t3_p),
            .frn_fdis_iu6_t0_i0_t3_t(frn_fdis_iu6_t0_i0_t3_t),
            .frn_fdis_iu6_t0_i0_s1_v(frn_fdis_iu6_t0_i0_s1_v),
            .frn_fdis_iu6_t0_i0_s1_a(frn_fdis_iu6_t0_i0_s1_a),
            .frn_fdis_iu6_t0_i0_s1_p(frn_fdis_iu6_t0_i0_s1_p),
            .frn_fdis_iu6_t0_i0_s1_itag(frn_fdis_iu6_t0_i0_s1_itag),
            .frn_fdis_iu6_t0_i0_s1_t(frn_fdis_iu6_t0_i0_s1_t),
            .frn_fdis_iu6_t0_i0_s2_v(frn_fdis_iu6_t0_i0_s2_v),
            .frn_fdis_iu6_t0_i0_s2_a(frn_fdis_iu6_t0_i0_s2_a),
            .frn_fdis_iu6_t0_i0_s2_p(frn_fdis_iu6_t0_i0_s2_p),
            .frn_fdis_iu6_t0_i0_s2_itag(frn_fdis_iu6_t0_i0_s2_itag),
            .frn_fdis_iu6_t0_i0_s2_t(frn_fdis_iu6_t0_i0_s2_t),
            .frn_fdis_iu6_t0_i0_s3_v(frn_fdis_iu6_t0_i0_s3_v),
            .frn_fdis_iu6_t0_i0_s3_a(frn_fdis_iu6_t0_i0_s3_a),
            .frn_fdis_iu6_t0_i0_s3_p(frn_fdis_iu6_t0_i0_s3_p),
            .frn_fdis_iu6_t0_i0_s3_itag(frn_fdis_iu6_t0_i0_s3_itag),
            .frn_fdis_iu6_t0_i0_s3_t(frn_fdis_iu6_t0_i0_s3_t),

            .frn_fdis_iu6_t0_i1_vld(frn_fdis_iu6_t0_i1_vld),
            .frn_fdis_iu6_t0_i1_itag(frn_fdis_iu6_t0_i1_itag),
            .frn_fdis_iu6_t0_i1_ucode(frn_fdis_iu6_t0_i1_ucode),
            .frn_fdis_iu6_t0_i1_ucode_cnt(frn_fdis_iu6_t0_i1_ucode_cnt),
            .frn_fdis_iu6_t0_i1_fuse_nop(frn_fdis_iu6_t0_i1_fuse_nop),
            .frn_fdis_iu6_t0_i1_rte_lq(frn_fdis_iu6_t0_i1_rte_lq),
            .frn_fdis_iu6_t0_i1_rte_sq(frn_fdis_iu6_t0_i1_rte_sq),
            .frn_fdis_iu6_t0_i1_rte_fx0(frn_fdis_iu6_t0_i1_rte_fx0),
            .frn_fdis_iu6_t0_i1_rte_fx1(frn_fdis_iu6_t0_i1_rte_fx1),
            .frn_fdis_iu6_t0_i1_rte_axu0(frn_fdis_iu6_t0_i1_rte_axu0),
            .frn_fdis_iu6_t0_i1_rte_axu1(frn_fdis_iu6_t0_i1_rte_axu1),
            .frn_fdis_iu6_t0_i1_valop(frn_fdis_iu6_t0_i1_valop),
            .frn_fdis_iu6_t0_i1_ord(frn_fdis_iu6_t0_i1_ord),
            .frn_fdis_iu6_t0_i1_cord(frn_fdis_iu6_t0_i1_cord),
            .frn_fdis_iu6_t0_i1_error(frn_fdis_iu6_t0_i1_error),
            .frn_fdis_iu6_t0_i1_btb_entry(frn_fdis_iu6_t0_i1_btb_entry),
            .frn_fdis_iu6_t0_i1_btb_hist(frn_fdis_iu6_t0_i1_btb_hist),
            .frn_fdis_iu6_t0_i1_bta_val(frn_fdis_iu6_t0_i1_bta_val),
            .frn_fdis_iu6_t0_i1_fusion(frn_fdis_iu6_t0_i1_fusion),
            .frn_fdis_iu6_t0_i1_spec(frn_fdis_iu6_t0_i1_spec),
            .frn_fdis_iu6_t0_i1_type_fp(frn_fdis_iu6_t0_i1_type_fp),
            .frn_fdis_iu6_t0_i1_type_ap(frn_fdis_iu6_t0_i1_type_ap),
            .frn_fdis_iu6_t0_i1_type_spv(frn_fdis_iu6_t0_i1_type_spv),
            .frn_fdis_iu6_t0_i1_type_st(frn_fdis_iu6_t0_i1_type_st),
            .frn_fdis_iu6_t0_i1_async_block(frn_fdis_iu6_t0_i1_async_block),
            .frn_fdis_iu6_t0_i1_np1_flush(frn_fdis_iu6_t0_i1_np1_flush),
            .frn_fdis_iu6_t0_i1_core_block(frn_fdis_iu6_t0_i1_core_block),
            .frn_fdis_iu6_t0_i1_isram(frn_fdis_iu6_t0_i1_isram),
            .frn_fdis_iu6_t0_i1_isload(frn_fdis_iu6_t0_i1_isload),
            .frn_fdis_iu6_t0_i1_isstore(frn_fdis_iu6_t0_i1_isstore),
            .frn_fdis_iu6_t0_i1_instr(frn_fdis_iu6_t0_i1_instr),
            .frn_fdis_iu6_t0_i1_ifar(frn_fdis_iu6_t0_i1_ifar),
            .frn_fdis_iu6_t0_i1_bta(frn_fdis_iu6_t0_i1_bta),
            .frn_fdis_iu6_t0_i1_br_pred(frn_fdis_iu6_t0_i1_br_pred),
            .frn_fdis_iu6_t0_i1_bh_update(frn_fdis_iu6_t0_i1_bh_update),
            .frn_fdis_iu6_t0_i1_bh0_hist(frn_fdis_iu6_t0_i1_bh0_hist),
            .frn_fdis_iu6_t0_i1_bh1_hist(frn_fdis_iu6_t0_i1_bh1_hist),
            .frn_fdis_iu6_t0_i1_bh2_hist(frn_fdis_iu6_t0_i1_bh2_hist),
            .frn_fdis_iu6_t0_i1_gshare(frn_fdis_iu6_t0_i1_gshare),
            .frn_fdis_iu6_t0_i1_ls_ptr(frn_fdis_iu6_t0_i1_ls_ptr),
            .frn_fdis_iu6_t0_i1_match(frn_fdis_iu6_t0_i1_match),
            .frn_fdis_iu6_t0_i1_ilat(frn_fdis_iu6_t0_i1_ilat),
            .frn_fdis_iu6_t0_i1_t1_v(frn_fdis_iu6_t0_i1_t1_v),
            .frn_fdis_iu6_t0_i1_t1_t(frn_fdis_iu6_t0_i1_t1_t),
            .frn_fdis_iu6_t0_i1_t1_a(frn_fdis_iu6_t0_i1_t1_a),
            .frn_fdis_iu6_t0_i1_t1_p(frn_fdis_iu6_t0_i1_t1_p),
            .frn_fdis_iu6_t0_i1_t2_v(frn_fdis_iu6_t0_i1_t2_v),
            .frn_fdis_iu6_t0_i1_t2_a(frn_fdis_iu6_t0_i1_t2_a),
            .frn_fdis_iu6_t0_i1_t2_p(frn_fdis_iu6_t0_i1_t2_p),
            .frn_fdis_iu6_t0_i1_t2_t(frn_fdis_iu6_t0_i1_t2_t),
            .frn_fdis_iu6_t0_i1_t3_v(frn_fdis_iu6_t0_i1_t3_v),
            .frn_fdis_iu6_t0_i1_t3_a(frn_fdis_iu6_t0_i1_t3_a),
            .frn_fdis_iu6_t0_i1_t3_p(frn_fdis_iu6_t0_i1_t3_p),
            .frn_fdis_iu6_t0_i1_t3_t(frn_fdis_iu6_t0_i1_t3_t),
            .frn_fdis_iu6_t0_i1_s1_v(frn_fdis_iu6_t0_i1_s1_v),
            .frn_fdis_iu6_t0_i1_s1_a(frn_fdis_iu6_t0_i1_s1_a),
            .frn_fdis_iu6_t0_i1_s1_p(frn_fdis_iu6_t0_i1_s1_p),
            .frn_fdis_iu6_t0_i1_s1_itag(frn_fdis_iu6_t0_i1_s1_itag),
            .frn_fdis_iu6_t0_i1_s1_t(frn_fdis_iu6_t0_i1_s1_t),
            .frn_fdis_iu6_t0_i1_s1_dep_hit(frn_fdis_iu6_t0_i1_s1_dep_hit),
            .frn_fdis_iu6_t0_i1_s2_v(frn_fdis_iu6_t0_i1_s2_v),
            .frn_fdis_iu6_t0_i1_s2_a(frn_fdis_iu6_t0_i1_s2_a),
            .frn_fdis_iu6_t0_i1_s2_p(frn_fdis_iu6_t0_i1_s2_p),
            .frn_fdis_iu6_t0_i1_s2_itag(frn_fdis_iu6_t0_i1_s2_itag),
            .frn_fdis_iu6_t0_i1_s2_t(frn_fdis_iu6_t0_i1_s2_t),
            .frn_fdis_iu6_t0_i1_s2_dep_hit(frn_fdis_iu6_t0_i1_s2_dep_hit),
            .frn_fdis_iu6_t0_i1_s3_v(frn_fdis_iu6_t0_i1_s3_v),
            .frn_fdis_iu6_t0_i1_s3_a(frn_fdis_iu6_t0_i1_s3_a),
            .frn_fdis_iu6_t0_i1_s3_p(frn_fdis_iu6_t0_i1_s3_p),
            .frn_fdis_iu6_t0_i1_s3_itag(frn_fdis_iu6_t0_i1_s3_itag),
            .frn_fdis_iu6_t0_i1_s3_t(frn_fdis_iu6_t0_i1_s3_t),
            .frn_fdis_iu6_t0_i1_s3_dep_hit(frn_fdis_iu6_t0_i1_s3_dep_hit),
`ifndef THREADS1
            .frn_fdis_iu6_t1_i0_vld(frn_fdis_iu6_t1_i0_vld),
            .frn_fdis_iu6_t1_i0_itag(frn_fdis_iu6_t1_i0_itag),
            .frn_fdis_iu6_t1_i0_ucode(frn_fdis_iu6_t1_i0_ucode),
            .frn_fdis_iu6_t1_i0_ucode_cnt(frn_fdis_iu6_t1_i0_ucode_cnt),
            .frn_fdis_iu6_t1_i0_2ucode(frn_fdis_iu6_t1_i0_2ucode),
            .frn_fdis_iu6_t1_i0_fuse_nop(frn_fdis_iu6_t1_i0_fuse_nop),
            .frn_fdis_iu6_t1_i0_rte_lq(frn_fdis_iu6_t1_i0_rte_lq),
            .frn_fdis_iu6_t1_i0_rte_sq(frn_fdis_iu6_t1_i0_rte_sq),
            .frn_fdis_iu6_t1_i0_rte_fx0(frn_fdis_iu6_t1_i0_rte_fx0),
            .frn_fdis_iu6_t1_i0_rte_fx1(frn_fdis_iu6_t1_i0_rte_fx1),
            .frn_fdis_iu6_t1_i0_rte_axu0(frn_fdis_iu6_t1_i0_rte_axu0),
            .frn_fdis_iu6_t1_i0_rte_axu1(frn_fdis_iu6_t1_i0_rte_axu1),
            .frn_fdis_iu6_t1_i0_valop(frn_fdis_iu6_t1_i0_valop),
            .frn_fdis_iu6_t1_i0_ord(frn_fdis_iu6_t1_i0_ord),
            .frn_fdis_iu6_t1_i0_cord(frn_fdis_iu6_t1_i0_cord),
            .frn_fdis_iu6_t1_i0_error(frn_fdis_iu6_t1_i0_error),
            .frn_fdis_iu6_t1_i0_btb_entry(frn_fdis_iu6_t1_i0_btb_entry),
            .frn_fdis_iu6_t1_i0_btb_hist(frn_fdis_iu6_t1_i0_btb_hist),
            .frn_fdis_iu6_t1_i0_bta_val(frn_fdis_iu6_t1_i0_bta_val),
            .frn_fdis_iu6_t1_i0_fusion(frn_fdis_iu6_t1_i0_fusion),
            .frn_fdis_iu6_t1_i0_spec(frn_fdis_iu6_t1_i0_spec),
            .frn_fdis_iu6_t1_i0_type_fp(frn_fdis_iu6_t1_i0_type_fp),
            .frn_fdis_iu6_t1_i0_type_ap(frn_fdis_iu6_t1_i0_type_ap),
            .frn_fdis_iu6_t1_i0_type_spv(frn_fdis_iu6_t1_i0_type_spv),
            .frn_fdis_iu6_t1_i0_type_st(frn_fdis_iu6_t1_i0_type_st),
            .frn_fdis_iu6_t1_i0_async_block(frn_fdis_iu6_t1_i0_async_block),
            .frn_fdis_iu6_t1_i0_np1_flush(frn_fdis_iu6_t1_i0_np1_flush),
            .frn_fdis_iu6_t1_i0_core_block(frn_fdis_iu6_t1_i0_core_block),
            .frn_fdis_iu6_t1_i0_isram(frn_fdis_iu6_t1_i0_isram),
            .frn_fdis_iu6_t1_i0_isload(frn_fdis_iu6_t1_i0_isload),
            .frn_fdis_iu6_t1_i0_isstore(frn_fdis_iu6_t1_i0_isstore),
            .frn_fdis_iu6_t1_i0_instr(frn_fdis_iu6_t1_i0_instr),
            .frn_fdis_iu6_t1_i0_ifar(frn_fdis_iu6_t1_i0_ifar),
            .frn_fdis_iu6_t1_i0_bta(frn_fdis_iu6_t1_i0_bta),
            .frn_fdis_iu6_t1_i0_br_pred(frn_fdis_iu6_t1_i0_br_pred),
            .frn_fdis_iu6_t1_i0_bh_update(frn_fdis_iu6_t1_i0_bh_update),
            .frn_fdis_iu6_t1_i0_bh0_hist(frn_fdis_iu6_t1_i0_bh0_hist),
            .frn_fdis_iu6_t1_i0_bh1_hist(frn_fdis_iu6_t1_i0_bh1_hist),
            .frn_fdis_iu6_t1_i0_bh2_hist(frn_fdis_iu6_t1_i0_bh2_hist),
            .frn_fdis_iu6_t1_i0_gshare(frn_fdis_iu6_t1_i0_gshare),
            .frn_fdis_iu6_t1_i0_ls_ptr(frn_fdis_iu6_t1_i0_ls_ptr),
            .frn_fdis_iu6_t1_i0_match(frn_fdis_iu6_t1_i0_match),
            .frn_fdis_iu6_t1_i0_ilat(frn_fdis_iu6_t1_i0_ilat),
            .frn_fdis_iu6_t1_i0_t1_v(frn_fdis_iu6_t1_i0_t1_v),
            .frn_fdis_iu6_t1_i0_t1_t(frn_fdis_iu6_t1_i0_t1_t),
            .frn_fdis_iu6_t1_i0_t1_a(frn_fdis_iu6_t1_i0_t1_a),
            .frn_fdis_iu6_t1_i0_t1_p(frn_fdis_iu6_t1_i0_t1_p),
            .frn_fdis_iu6_t1_i0_t2_v(frn_fdis_iu6_t1_i0_t2_v),
            .frn_fdis_iu6_t1_i0_t2_a(frn_fdis_iu6_t1_i0_t2_a),
            .frn_fdis_iu6_t1_i0_t2_p(frn_fdis_iu6_t1_i0_t2_p),
            .frn_fdis_iu6_t1_i0_t2_t(frn_fdis_iu6_t1_i0_t2_t),
            .frn_fdis_iu6_t1_i0_t3_v(frn_fdis_iu6_t1_i0_t3_v),
            .frn_fdis_iu6_t1_i0_t3_a(frn_fdis_iu6_t1_i0_t3_a),
            .frn_fdis_iu6_t1_i0_t3_p(frn_fdis_iu6_t1_i0_t3_p),
            .frn_fdis_iu6_t1_i0_t3_t(frn_fdis_iu6_t1_i0_t3_t),
            .frn_fdis_iu6_t1_i0_s1_v(frn_fdis_iu6_t1_i0_s1_v),
            .frn_fdis_iu6_t1_i0_s1_a(frn_fdis_iu6_t1_i0_s1_a),
            .frn_fdis_iu6_t1_i0_s1_p(frn_fdis_iu6_t1_i0_s1_p),
            .frn_fdis_iu6_t1_i0_s1_itag(frn_fdis_iu6_t1_i0_s1_itag),
            .frn_fdis_iu6_t1_i0_s1_t(frn_fdis_iu6_t1_i0_s1_t),
            .frn_fdis_iu6_t1_i0_s2_v(frn_fdis_iu6_t1_i0_s2_v),
            .frn_fdis_iu6_t1_i0_s2_a(frn_fdis_iu6_t1_i0_s2_a),
            .frn_fdis_iu6_t1_i0_s2_p(frn_fdis_iu6_t1_i0_s2_p),
            .frn_fdis_iu6_t1_i0_s2_itag(frn_fdis_iu6_t1_i0_s2_itag),
            .frn_fdis_iu6_t1_i0_s2_t(frn_fdis_iu6_t1_i0_s2_t),
            .frn_fdis_iu6_t1_i0_s3_v(frn_fdis_iu6_t1_i0_s3_v),
            .frn_fdis_iu6_t1_i0_s3_a(frn_fdis_iu6_t1_i0_s3_a),
            .frn_fdis_iu6_t1_i0_s3_p(frn_fdis_iu6_t1_i0_s3_p),
            .frn_fdis_iu6_t1_i0_s3_itag(frn_fdis_iu6_t1_i0_s3_itag),
            .frn_fdis_iu6_t1_i0_s3_t(frn_fdis_iu6_t1_i0_s3_t),

            .frn_fdis_iu6_t1_i1_vld(frn_fdis_iu6_t1_i1_vld),
            .frn_fdis_iu6_t1_i1_itag(frn_fdis_iu6_t1_i1_itag),
            .frn_fdis_iu6_t1_i1_ucode(frn_fdis_iu6_t1_i1_ucode),
            .frn_fdis_iu6_t1_i1_ucode_cnt(frn_fdis_iu6_t1_i1_ucode_cnt),
            .frn_fdis_iu6_t1_i1_fuse_nop(frn_fdis_iu6_t1_i1_fuse_nop),
            .frn_fdis_iu6_t1_i1_rte_lq(frn_fdis_iu6_t1_i1_rte_lq),
            .frn_fdis_iu6_t1_i1_rte_sq(frn_fdis_iu6_t1_i1_rte_sq),
            .frn_fdis_iu6_t1_i1_rte_fx0(frn_fdis_iu6_t1_i1_rte_fx0),
            .frn_fdis_iu6_t1_i1_rte_fx1(frn_fdis_iu6_t1_i1_rte_fx1),
            .frn_fdis_iu6_t1_i1_rte_axu0(frn_fdis_iu6_t1_i1_rte_axu0),
            .frn_fdis_iu6_t1_i1_rte_axu1(frn_fdis_iu6_t1_i1_rte_axu1),
            .frn_fdis_iu6_t1_i1_valop(frn_fdis_iu6_t1_i1_valop),
            .frn_fdis_iu6_t1_i1_ord(frn_fdis_iu6_t1_i1_ord),
            .frn_fdis_iu6_t1_i1_cord(frn_fdis_iu6_t1_i1_cord),
            .frn_fdis_iu6_t1_i1_error(frn_fdis_iu6_t1_i1_error),
            .frn_fdis_iu6_t1_i1_btb_entry(frn_fdis_iu6_t1_i1_btb_entry),
            .frn_fdis_iu6_t1_i1_btb_hist(frn_fdis_iu6_t1_i1_btb_hist),
            .frn_fdis_iu6_t1_i1_bta_val(frn_fdis_iu6_t1_i1_bta_val),
            .frn_fdis_iu6_t1_i1_fusion(frn_fdis_iu6_t1_i1_fusion),
            .frn_fdis_iu6_t1_i1_spec(frn_fdis_iu6_t1_i1_spec),
            .frn_fdis_iu6_t1_i1_type_fp(frn_fdis_iu6_t1_i1_type_fp),
            .frn_fdis_iu6_t1_i1_type_ap(frn_fdis_iu6_t1_i1_type_ap),
            .frn_fdis_iu6_t1_i1_type_spv(frn_fdis_iu6_t1_i1_type_spv),
            .frn_fdis_iu6_t1_i1_type_st(frn_fdis_iu6_t1_i1_type_st),
            .frn_fdis_iu6_t1_i1_async_block(frn_fdis_iu6_t1_i1_async_block),
            .frn_fdis_iu6_t1_i1_np1_flush(frn_fdis_iu6_t1_i1_np1_flush),
            .frn_fdis_iu6_t1_i1_core_block(frn_fdis_iu6_t1_i1_core_block),
            .frn_fdis_iu6_t1_i1_isram(frn_fdis_iu6_t1_i1_isram),
            .frn_fdis_iu6_t1_i1_isload(frn_fdis_iu6_t1_i1_isload),
            .frn_fdis_iu6_t1_i1_isstore(frn_fdis_iu6_t1_i1_isstore),
            .frn_fdis_iu6_t1_i1_instr(frn_fdis_iu6_t1_i1_instr),
            .frn_fdis_iu6_t1_i1_ifar(frn_fdis_iu6_t1_i1_ifar),
            .frn_fdis_iu6_t1_i1_bta(frn_fdis_iu6_t1_i1_bta),
            .frn_fdis_iu6_t1_i1_br_pred(frn_fdis_iu6_t1_i1_br_pred),
            .frn_fdis_iu6_t1_i1_bh_update(frn_fdis_iu6_t1_i1_bh_update),
            .frn_fdis_iu6_t1_i1_bh0_hist(frn_fdis_iu6_t1_i1_bh0_hist),
            .frn_fdis_iu6_t1_i1_bh1_hist(frn_fdis_iu6_t1_i1_bh1_hist),
            .frn_fdis_iu6_t1_i1_bh2_hist(frn_fdis_iu6_t1_i1_bh2_hist),
            .frn_fdis_iu6_t1_i1_gshare(frn_fdis_iu6_t1_i1_gshare),
            .frn_fdis_iu6_t1_i1_ls_ptr(frn_fdis_iu6_t1_i1_ls_ptr),
            .frn_fdis_iu6_t1_i1_match(frn_fdis_iu6_t1_i1_match),
            .frn_fdis_iu6_t1_i1_ilat(frn_fdis_iu6_t1_i1_ilat),
            .frn_fdis_iu6_t1_i1_t1_v(frn_fdis_iu6_t1_i1_t1_v),
            .frn_fdis_iu6_t1_i1_t1_t(frn_fdis_iu6_t1_i1_t1_t),
            .frn_fdis_iu6_t1_i1_t1_a(frn_fdis_iu6_t1_i1_t1_a),
            .frn_fdis_iu6_t1_i1_t1_p(frn_fdis_iu6_t1_i1_t1_p),
            .frn_fdis_iu6_t1_i1_t2_v(frn_fdis_iu6_t1_i1_t2_v),
            .frn_fdis_iu6_t1_i1_t2_a(frn_fdis_iu6_t1_i1_t2_a),
            .frn_fdis_iu6_t1_i1_t2_p(frn_fdis_iu6_t1_i1_t2_p),
            .frn_fdis_iu6_t1_i1_t2_t(frn_fdis_iu6_t1_i1_t2_t),
            .frn_fdis_iu6_t1_i1_t3_v(frn_fdis_iu6_t1_i1_t3_v),
            .frn_fdis_iu6_t1_i1_t3_a(frn_fdis_iu6_t1_i1_t3_a),
            .frn_fdis_iu6_t1_i1_t3_p(frn_fdis_iu6_t1_i1_t3_p),
            .frn_fdis_iu6_t1_i1_t3_t(frn_fdis_iu6_t1_i1_t3_t),
            .frn_fdis_iu6_t1_i1_s1_v(frn_fdis_iu6_t1_i1_s1_v),
            .frn_fdis_iu6_t1_i1_s1_a(frn_fdis_iu6_t1_i1_s1_a),
            .frn_fdis_iu6_t1_i1_s1_p(frn_fdis_iu6_t1_i1_s1_p),
            .frn_fdis_iu6_t1_i1_s1_itag(frn_fdis_iu6_t1_i1_s1_itag),
            .frn_fdis_iu6_t1_i1_s1_t(frn_fdis_iu6_t1_i1_s1_t),
            .frn_fdis_iu6_t1_i1_s1_dep_hit(frn_fdis_iu6_t1_i1_s1_dep_hit),
            .frn_fdis_iu6_t1_i1_s2_v(frn_fdis_iu6_t1_i1_s2_v),
            .frn_fdis_iu6_t1_i1_s2_a(frn_fdis_iu6_t1_i1_s2_a),
            .frn_fdis_iu6_t1_i1_s2_p(frn_fdis_iu6_t1_i1_s2_p),
            .frn_fdis_iu6_t1_i1_s2_itag(frn_fdis_iu6_t1_i1_s2_itag),
            .frn_fdis_iu6_t1_i1_s2_t(frn_fdis_iu6_t1_i1_s2_t),
            .frn_fdis_iu6_t1_i1_s2_dep_hit(frn_fdis_iu6_t1_i1_s2_dep_hit),
            .frn_fdis_iu6_t1_i1_s3_v(frn_fdis_iu6_t1_i1_s3_v),
            .frn_fdis_iu6_t1_i1_s3_a(frn_fdis_iu6_t1_i1_s3_a),
            .frn_fdis_iu6_t1_i1_s3_p(frn_fdis_iu6_t1_i1_s3_p),
            .frn_fdis_iu6_t1_i1_s3_itag(frn_fdis_iu6_t1_i1_s3_itag),
            .frn_fdis_iu6_t1_i1_s3_t(frn_fdis_iu6_t1_i1_s3_t),
            .frn_fdis_iu6_t1_i1_s3_dep_hit(frn_fdis_iu6_t1_i1_s3_dep_hit),
`endif

            //-----------------------------
            // Stall from dispatch
            //-----------------------------
            .fdis_frn_iu6_stall(fdis_frn_iu6_stall),

            //----------------------------------------------------------------
            // Interface to reservation station - Completion is snooping also
            //----------------------------------------------------------------
            .iu_rv_iu6_t0_i0_vld(iu_rv_iu6_t0_i0_vld),
            .iu_rv_iu6_t0_i0_act(iu_rv_iu6_t0_i0_act),
            .iu_rv_iu6_t0_i0_itag(iu_rv_iu6_t0_i0_itag),
            .iu_rv_iu6_t0_i0_ucode(iu_rv_iu6_t0_i0_ucode),
            .iu_rv_iu6_t0_i0_ucode_cnt(iu_rv_iu6_t0_i0_ucode_cnt),
            .iu_rv_iu6_t0_i0_2ucode(iu_rv_iu6_t0_i0_2ucode),
            .iu_rv_iu6_t0_i0_fuse_nop(iu_rv_iu6_t0_i0_fuse_nop),
            .iu_rv_iu6_t0_i0_rte_lq(iu_rv_iu6_t0_i0_rte_lq),
            .iu_rv_iu6_t0_i0_rte_sq(iu_rv_iu6_t0_i0_rte_sq),
            .iu_rv_iu6_t0_i0_rte_fx0(iu_rv_iu6_t0_i0_rte_fx0),
            .iu_rv_iu6_t0_i0_rte_fx1(iu_rv_iu6_t0_i0_rte_fx1),
            .iu_rv_iu6_t0_i0_rte_axu0(iu_rv_iu6_t0_i0_rte_axu0),
            .iu_rv_iu6_t0_i0_rte_axu1(iu_rv_iu6_t0_i0_rte_axu1),
            .iu_rv_iu6_t0_i0_valop(iu_rv_iu6_t0_i0_valop),
            .iu_rv_iu6_t0_i0_ord(iu_rv_iu6_t0_i0_ord),
            .iu_rv_iu6_t0_i0_cord(iu_rv_iu6_t0_i0_cord),
            .iu_rv_iu6_t0_i0_error(iu_rv_iu6_t0_i0_error),
            .iu_rv_iu6_t0_i0_btb_entry(iu_rv_iu6_t0_i0_btb_entry),
            .iu_rv_iu6_t0_i0_btb_hist(iu_rv_iu6_t0_i0_btb_hist),
            .iu_rv_iu6_t0_i0_bta_val(iu_rv_iu6_t0_i0_bta_val),
            .iu_rv_iu6_t0_i0_fusion(iu_rv_iu6_t0_i0_fusion),
            .iu_rv_iu6_t0_i0_spec(iu_rv_iu6_t0_i0_spec),
            .iu_rv_iu6_t0_i0_type_fp(iu_rv_iu6_t0_i0_type_fp),
            .iu_rv_iu6_t0_i0_type_ap(iu_rv_iu6_t0_i0_type_ap),
            .iu_rv_iu6_t0_i0_type_spv(iu_rv_iu6_t0_i0_type_spv),
            .iu_rv_iu6_t0_i0_type_st(iu_rv_iu6_t0_i0_type_st),
            .iu_rv_iu6_t0_i0_async_block(iu_rv_iu6_t0_i0_async_block),
            .iu_rv_iu6_t0_i0_np1_flush(iu_rv_iu6_t0_i0_np1_flush),
            .iu_rv_iu6_t0_i0_isram(iu_rv_iu6_t0_i0_isram),
            .iu_rv_iu6_t0_i0_isload(iu_rv_iu6_t0_i0_isload),
            .iu_rv_iu6_t0_i0_isstore(iu_rv_iu6_t0_i0_isstore),
            .iu_rv_iu6_t0_i0_instr(iu_rv_iu6_t0_i0_instr),
            .iu_rv_iu6_t0_i0_ifar(iu_rv_iu6_t0_i0_ifar),
            .iu_rv_iu6_t0_i0_bta(iu_rv_iu6_t0_i0_bta),
            .iu_rv_iu6_t0_i0_br_pred(iu_rv_iu6_t0_i0_br_pred),
            .iu_rv_iu6_t0_i0_bh_update(iu_rv_iu6_t0_i0_bh_update),
            .iu_rv_iu6_t0_i0_bh0_hist(iu_rv_iu6_t0_i0_bh0_hist),
            .iu_rv_iu6_t0_i0_bh1_hist(iu_rv_iu6_t0_i0_bh1_hist),
            .iu_rv_iu6_t0_i0_bh2_hist(iu_rv_iu6_t0_i0_bh2_hist),
            .iu_rv_iu6_t0_i0_gshare(iu_rv_iu6_t0_i0_gshare),
            .iu_rv_iu6_t0_i0_ls_ptr(iu_rv_iu6_t0_i0_ls_ptr),
            .iu_rv_iu6_t0_i0_match(iu_rv_iu6_t0_i0_match),
            .iu_rv_iu6_t0_i0_ilat(iu_rv_iu6_t0_i0_ilat),
            .iu_rv_iu6_t0_i0_t1_v(iu_rv_iu6_t0_i0_t1_v),
            .iu_rv_iu6_t0_i0_t1_t(iu_rv_iu6_t0_i0_t1_t),
            .iu_rv_iu6_t0_i0_t1_a(iu_rv_iu6_t0_i0_t1_a),
            .iu_rv_iu6_t0_i0_t1_p(iu_rv_iu6_t0_i0_t1_p),
            .iu_rv_iu6_t0_i0_t2_v(iu_rv_iu6_t0_i0_t2_v),
            .iu_rv_iu6_t0_i0_t2_a(iu_rv_iu6_t0_i0_t2_a),
            .iu_rv_iu6_t0_i0_t2_p(iu_rv_iu6_t0_i0_t2_p),
            .iu_rv_iu6_t0_i0_t2_t(iu_rv_iu6_t0_i0_t2_t),
            .iu_rv_iu6_t0_i0_t3_v(iu_rv_iu6_t0_i0_t3_v),
            .iu_rv_iu6_t0_i0_t3_a(iu_rv_iu6_t0_i0_t3_a),
            .iu_rv_iu6_t0_i0_t3_p(iu_rv_iu6_t0_i0_t3_p),
            .iu_rv_iu6_t0_i0_t3_t(iu_rv_iu6_t0_i0_t3_t),
            .iu_rv_iu6_t0_i0_s1_v(iu_rv_iu6_t0_i0_s1_v),
            .iu_rv_iu6_t0_i0_s1_a(iu_rv_iu6_t0_i0_s1_a),
            .iu_rv_iu6_t0_i0_s1_p(iu_rv_iu6_t0_i0_s1_p),
            .iu_rv_iu6_t0_i0_s1_itag(iu_rv_iu6_t0_i0_s1_itag),
            .iu_rv_iu6_t0_i0_s1_t(iu_rv_iu6_t0_i0_s1_t),
            .iu_rv_iu6_t0_i0_s2_v(iu_rv_iu6_t0_i0_s2_v),
            .iu_rv_iu6_t0_i0_s2_a(iu_rv_iu6_t0_i0_s2_a),
            .iu_rv_iu6_t0_i0_s2_p(iu_rv_iu6_t0_i0_s2_p),
            .iu_rv_iu6_t0_i0_s2_itag(iu_rv_iu6_t0_i0_s2_itag),
            .iu_rv_iu6_t0_i0_s2_t(iu_rv_iu6_t0_i0_s2_t),
            .iu_rv_iu6_t0_i0_s3_v(iu_rv_iu6_t0_i0_s3_v),
            .iu_rv_iu6_t0_i0_s3_a(iu_rv_iu6_t0_i0_s3_a),
            .iu_rv_iu6_t0_i0_s3_p(iu_rv_iu6_t0_i0_s3_p),
            .iu_rv_iu6_t0_i0_s3_itag(iu_rv_iu6_t0_i0_s3_itag),
            .iu_rv_iu6_t0_i0_s3_t(iu_rv_iu6_t0_i0_s3_t),

            .iu_rv_iu6_t0_i1_vld(iu_rv_iu6_t0_i1_vld),
            .iu_rv_iu6_t0_i1_act(iu_rv_iu6_t0_i1_act),
            .iu_rv_iu6_t0_i1_itag(iu_rv_iu6_t0_i1_itag),
            .iu_rv_iu6_t0_i1_ucode(iu_rv_iu6_t0_i1_ucode),
            .iu_rv_iu6_t0_i1_ucode_cnt(iu_rv_iu6_t0_i1_ucode_cnt),
            .iu_rv_iu6_t0_i1_fuse_nop(iu_rv_iu6_t0_i1_fuse_nop),
            .iu_rv_iu6_t0_i1_rte_lq(iu_rv_iu6_t0_i1_rte_lq),
            .iu_rv_iu6_t0_i1_rte_sq(iu_rv_iu6_t0_i1_rte_sq),
            .iu_rv_iu6_t0_i1_rte_fx0(iu_rv_iu6_t0_i1_rte_fx0),
            .iu_rv_iu6_t0_i1_rte_fx1(iu_rv_iu6_t0_i1_rte_fx1),
            .iu_rv_iu6_t0_i1_rte_axu0(iu_rv_iu6_t0_i1_rte_axu0),
            .iu_rv_iu6_t0_i1_rte_axu1(iu_rv_iu6_t0_i1_rte_axu1),
            .iu_rv_iu6_t0_i1_valop(iu_rv_iu6_t0_i1_valop),
            .iu_rv_iu6_t0_i1_ord(iu_rv_iu6_t0_i1_ord),
            .iu_rv_iu6_t0_i1_cord(iu_rv_iu6_t0_i1_cord),
            .iu_rv_iu6_t0_i1_error(iu_rv_iu6_t0_i1_error),
            .iu_rv_iu6_t0_i1_btb_entry(iu_rv_iu6_t0_i1_btb_entry),
            .iu_rv_iu6_t0_i1_btb_hist(iu_rv_iu6_t0_i1_btb_hist),
            .iu_rv_iu6_t0_i1_bta_val(iu_rv_iu6_t0_i1_bta_val),
            .iu_rv_iu6_t0_i1_fusion(iu_rv_iu6_t0_i1_fusion),
            .iu_rv_iu6_t0_i1_spec(iu_rv_iu6_t0_i1_spec),
            .iu_rv_iu6_t0_i1_type_fp(iu_rv_iu6_t0_i1_type_fp),
            .iu_rv_iu6_t0_i1_type_ap(iu_rv_iu6_t0_i1_type_ap),
            .iu_rv_iu6_t0_i1_type_spv(iu_rv_iu6_t0_i1_type_spv),
            .iu_rv_iu6_t0_i1_type_st(iu_rv_iu6_t0_i1_type_st),
            .iu_rv_iu6_t0_i1_async_block(iu_rv_iu6_t0_i1_async_block),
            .iu_rv_iu6_t0_i1_np1_flush(iu_rv_iu6_t0_i1_np1_flush),
            .iu_rv_iu6_t0_i1_isram(iu_rv_iu6_t0_i1_isram),
            .iu_rv_iu6_t0_i1_isload(iu_rv_iu6_t0_i1_isload),
            .iu_rv_iu6_t0_i1_isstore(iu_rv_iu6_t0_i1_isstore),
            .iu_rv_iu6_t0_i1_instr(iu_rv_iu6_t0_i1_instr),
            .iu_rv_iu6_t0_i1_ifar(iu_rv_iu6_t0_i1_ifar),
            .iu_rv_iu6_t0_i1_bta(iu_rv_iu6_t0_i1_bta),
            .iu_rv_iu6_t0_i1_br_pred(iu_rv_iu6_t0_i1_br_pred),
            .iu_rv_iu6_t0_i1_bh_update(iu_rv_iu6_t0_i1_bh_update),
            .iu_rv_iu6_t0_i1_bh0_hist(iu_rv_iu6_t0_i1_bh0_hist),
            .iu_rv_iu6_t0_i1_bh1_hist(iu_rv_iu6_t0_i1_bh1_hist),
            .iu_rv_iu6_t0_i1_bh2_hist(iu_rv_iu6_t0_i1_bh2_hist),
            .iu_rv_iu6_t0_i1_gshare(iu_rv_iu6_t0_i1_gshare),
            .iu_rv_iu6_t0_i1_ls_ptr(iu_rv_iu6_t0_i1_ls_ptr),
            .iu_rv_iu6_t0_i1_match(iu_rv_iu6_t0_i1_match),
            .iu_rv_iu6_t0_i1_ilat(iu_rv_iu6_t0_i1_ilat),
            .iu_rv_iu6_t0_i1_t1_v(iu_rv_iu6_t0_i1_t1_v),
            .iu_rv_iu6_t0_i1_t1_t(iu_rv_iu6_t0_i1_t1_t),
            .iu_rv_iu6_t0_i1_t1_a(iu_rv_iu6_t0_i1_t1_a),
            .iu_rv_iu6_t0_i1_t1_p(iu_rv_iu6_t0_i1_t1_p),
            .iu_rv_iu6_t0_i1_t2_v(iu_rv_iu6_t0_i1_t2_v),
            .iu_rv_iu6_t0_i1_t2_a(iu_rv_iu6_t0_i1_t2_a),
            .iu_rv_iu6_t0_i1_t2_p(iu_rv_iu6_t0_i1_t2_p),
            .iu_rv_iu6_t0_i1_t2_t(iu_rv_iu6_t0_i1_t2_t),
            .iu_rv_iu6_t0_i1_t3_v(iu_rv_iu6_t0_i1_t3_v),
            .iu_rv_iu6_t0_i1_t3_a(iu_rv_iu6_t0_i1_t3_a),
            .iu_rv_iu6_t0_i1_t3_p(iu_rv_iu6_t0_i1_t3_p),
            .iu_rv_iu6_t0_i1_t3_t(iu_rv_iu6_t0_i1_t3_t),
            .iu_rv_iu6_t0_i1_s1_v(iu_rv_iu6_t0_i1_s1_v),
            .iu_rv_iu6_t0_i1_s1_a(iu_rv_iu6_t0_i1_s1_a),
            .iu_rv_iu6_t0_i1_s1_p(iu_rv_iu6_t0_i1_s1_p),
            .iu_rv_iu6_t0_i1_s1_itag(iu_rv_iu6_t0_i1_s1_itag),
            .iu_rv_iu6_t0_i1_s1_t(iu_rv_iu6_t0_i1_s1_t),
            .iu_rv_iu6_t0_i1_s1_dep_hit(iu_rv_iu6_t0_i1_s1_dep_hit),
            .iu_rv_iu6_t0_i1_s2_v(iu_rv_iu6_t0_i1_s2_v),
            .iu_rv_iu6_t0_i1_s2_a(iu_rv_iu6_t0_i1_s2_a),
            .iu_rv_iu6_t0_i1_s2_p(iu_rv_iu6_t0_i1_s2_p),
            .iu_rv_iu6_t0_i1_s2_itag(iu_rv_iu6_t0_i1_s2_itag),
            .iu_rv_iu6_t0_i1_s2_t(iu_rv_iu6_t0_i1_s2_t),
            .iu_rv_iu6_t0_i1_s2_dep_hit(iu_rv_iu6_t0_i1_s2_dep_hit),
            .iu_rv_iu6_t0_i1_s3_v(iu_rv_iu6_t0_i1_s3_v),
            .iu_rv_iu6_t0_i1_s3_a(iu_rv_iu6_t0_i1_s3_a),
            .iu_rv_iu6_t0_i1_s3_p(iu_rv_iu6_t0_i1_s3_p),
            .iu_rv_iu6_t0_i1_s3_itag(iu_rv_iu6_t0_i1_s3_itag),
            .iu_rv_iu6_t0_i1_s3_t(iu_rv_iu6_t0_i1_s3_t),
            .iu_rv_iu6_t0_i1_s3_dep_hit(iu_rv_iu6_t0_i1_s3_dep_hit),
`ifndef THREADS1
            .iu_rv_iu6_t1_i0_vld(iu_rv_iu6_t1_i0_vld),
            .iu_rv_iu6_t1_i0_act(iu_rv_iu6_t1_i0_act),
            .iu_rv_iu6_t1_i0_itag(iu_rv_iu6_t1_i0_itag),
            .iu_rv_iu6_t1_i0_ucode(iu_rv_iu6_t1_i0_ucode),
            .iu_rv_iu6_t1_i0_ucode_cnt(iu_rv_iu6_t1_i0_ucode_cnt),
            .iu_rv_iu6_t1_i0_2ucode(iu_rv_iu6_t1_i0_2ucode),
            .iu_rv_iu6_t1_i0_fuse_nop(iu_rv_iu6_t1_i0_fuse_nop),
            .iu_rv_iu6_t1_i0_rte_lq(iu_rv_iu6_t1_i0_rte_lq),
            .iu_rv_iu6_t1_i0_rte_sq(iu_rv_iu6_t1_i0_rte_sq),
            .iu_rv_iu6_t1_i0_rte_fx0(iu_rv_iu6_t1_i0_rte_fx0),
            .iu_rv_iu6_t1_i0_rte_fx1(iu_rv_iu6_t1_i0_rte_fx1),
            .iu_rv_iu6_t1_i0_rte_axu0(iu_rv_iu6_t1_i0_rte_axu0),
            .iu_rv_iu6_t1_i0_rte_axu1(iu_rv_iu6_t1_i0_rte_axu1),
            .iu_rv_iu6_t1_i0_valop(iu_rv_iu6_t1_i0_valop),
            .iu_rv_iu6_t1_i0_ord(iu_rv_iu6_t1_i0_ord),
            .iu_rv_iu6_t1_i0_cord(iu_rv_iu6_t1_i0_cord),
            .iu_rv_iu6_t1_i0_error(iu_rv_iu6_t1_i0_error),
            .iu_rv_iu6_t1_i0_btb_entry(iu_rv_iu6_t1_i0_btb_entry),
            .iu_rv_iu6_t1_i0_btb_hist(iu_rv_iu6_t1_i0_btb_hist),
            .iu_rv_iu6_t1_i0_bta_val(iu_rv_iu6_t1_i0_bta_val),
            .iu_rv_iu6_t1_i0_fusion(iu_rv_iu6_t1_i0_fusion),
            .iu_rv_iu6_t1_i0_spec(iu_rv_iu6_t1_i0_spec),
            .iu_rv_iu6_t1_i0_type_fp(iu_rv_iu6_t1_i0_type_fp),
            .iu_rv_iu6_t1_i0_type_ap(iu_rv_iu6_t1_i0_type_ap),
            .iu_rv_iu6_t1_i0_type_spv(iu_rv_iu6_t1_i0_type_spv),
            .iu_rv_iu6_t1_i0_type_st(iu_rv_iu6_t1_i0_type_st),
            .iu_rv_iu6_t1_i0_async_block(iu_rv_iu6_t1_i0_async_block),
            .iu_rv_iu6_t1_i0_np1_flush(iu_rv_iu6_t1_i0_np1_flush),
            .iu_rv_iu6_t1_i0_isram(iu_rv_iu6_t1_i0_isram),
            .iu_rv_iu6_t1_i0_isload(iu_rv_iu6_t1_i0_isload),
            .iu_rv_iu6_t1_i0_isstore(iu_rv_iu6_t1_i0_isstore),
            .iu_rv_iu6_t1_i0_instr(iu_rv_iu6_t1_i0_instr),
            .iu_rv_iu6_t1_i0_ifar(iu_rv_iu6_t1_i0_ifar),
            .iu_rv_iu6_t1_i0_bta(iu_rv_iu6_t1_i0_bta),
            .iu_rv_iu6_t1_i0_br_pred(iu_rv_iu6_t1_i0_br_pred),
            .iu_rv_iu6_t1_i0_bh_update(iu_rv_iu6_t1_i0_bh_update),
            .iu_rv_iu6_t1_i0_bh0_hist(iu_rv_iu6_t1_i0_bh0_hist),
            .iu_rv_iu6_t1_i0_bh1_hist(iu_rv_iu6_t1_i0_bh1_hist),
            .iu_rv_iu6_t1_i0_bh2_hist(iu_rv_iu6_t1_i0_bh2_hist),
            .iu_rv_iu6_t1_i0_gshare(iu_rv_iu6_t1_i0_gshare),
            .iu_rv_iu6_t1_i0_ls_ptr(iu_rv_iu6_t1_i0_ls_ptr),
            .iu_rv_iu6_t1_i0_match(iu_rv_iu6_t1_i0_match),
            .iu_rv_iu6_t1_i0_ilat(iu_rv_iu6_t1_i0_ilat),
            .iu_rv_iu6_t1_i0_t1_v(iu_rv_iu6_t1_i0_t1_v),
            .iu_rv_iu6_t1_i0_t1_t(iu_rv_iu6_t1_i0_t1_t),
            .iu_rv_iu6_t1_i0_t1_a(iu_rv_iu6_t1_i0_t1_a),
            .iu_rv_iu6_t1_i0_t1_p(iu_rv_iu6_t1_i0_t1_p),
            .iu_rv_iu6_t1_i0_t2_v(iu_rv_iu6_t1_i0_t2_v),
            .iu_rv_iu6_t1_i0_t2_a(iu_rv_iu6_t1_i0_t2_a),
            .iu_rv_iu6_t1_i0_t2_p(iu_rv_iu6_t1_i0_t2_p),
            .iu_rv_iu6_t1_i0_t2_t(iu_rv_iu6_t1_i0_t2_t),
            .iu_rv_iu6_t1_i0_t3_v(iu_rv_iu6_t1_i0_t3_v),
            .iu_rv_iu6_t1_i0_t3_a(iu_rv_iu6_t1_i0_t3_a),
            .iu_rv_iu6_t1_i0_t3_p(iu_rv_iu6_t1_i0_t3_p),
            .iu_rv_iu6_t1_i0_t3_t(iu_rv_iu6_t1_i0_t3_t),
            .iu_rv_iu6_t1_i0_s1_v(iu_rv_iu6_t1_i0_s1_v),
            .iu_rv_iu6_t1_i0_s1_a(iu_rv_iu6_t1_i0_s1_a),
            .iu_rv_iu6_t1_i0_s1_p(iu_rv_iu6_t1_i0_s1_p),
            .iu_rv_iu6_t1_i0_s1_itag(iu_rv_iu6_t1_i0_s1_itag),
            .iu_rv_iu6_t1_i0_s1_t(iu_rv_iu6_t1_i0_s1_t),
            .iu_rv_iu6_t1_i0_s2_v(iu_rv_iu6_t1_i0_s2_v),
            .iu_rv_iu6_t1_i0_s2_a(iu_rv_iu6_t1_i0_s2_a),
            .iu_rv_iu6_t1_i0_s2_p(iu_rv_iu6_t1_i0_s2_p),
            .iu_rv_iu6_t1_i0_s2_itag(iu_rv_iu6_t1_i0_s2_itag),
            .iu_rv_iu6_t1_i0_s2_t(iu_rv_iu6_t1_i0_s2_t),
            .iu_rv_iu6_t1_i0_s3_v(iu_rv_iu6_t1_i0_s3_v),
            .iu_rv_iu6_t1_i0_s3_a(iu_rv_iu6_t1_i0_s3_a),
            .iu_rv_iu6_t1_i0_s3_p(iu_rv_iu6_t1_i0_s3_p),
            .iu_rv_iu6_t1_i0_s3_itag(iu_rv_iu6_t1_i0_s3_itag),
            .iu_rv_iu6_t1_i0_s3_t(iu_rv_iu6_t1_i0_s3_t),

            .iu_rv_iu6_t1_i1_vld(iu_rv_iu6_t1_i1_vld),
            .iu_rv_iu6_t1_i1_act(iu_rv_iu6_t1_i1_act),
            .iu_rv_iu6_t1_i1_itag(iu_rv_iu6_t1_i1_itag),
            .iu_rv_iu6_t1_i1_ucode(iu_rv_iu6_t1_i1_ucode),
            .iu_rv_iu6_t1_i1_ucode_cnt(iu_rv_iu6_t1_i1_ucode_cnt),
            .iu_rv_iu6_t1_i1_fuse_nop(iu_rv_iu6_t1_i1_fuse_nop),
            .iu_rv_iu6_t1_i1_rte_lq(iu_rv_iu6_t1_i1_rte_lq),
            .iu_rv_iu6_t1_i1_rte_sq(iu_rv_iu6_t1_i1_rte_sq),
            .iu_rv_iu6_t1_i1_rte_fx0(iu_rv_iu6_t1_i1_rte_fx0),
            .iu_rv_iu6_t1_i1_rte_fx1(iu_rv_iu6_t1_i1_rte_fx1),
            .iu_rv_iu6_t1_i1_rte_axu0(iu_rv_iu6_t1_i1_rte_axu0),
            .iu_rv_iu6_t1_i1_rte_axu1(iu_rv_iu6_t1_i1_rte_axu1),
            .iu_rv_iu6_t1_i1_valop(iu_rv_iu6_t1_i1_valop),
            .iu_rv_iu6_t1_i1_ord(iu_rv_iu6_t1_i1_ord),
            .iu_rv_iu6_t1_i1_cord(iu_rv_iu6_t1_i1_cord),
            .iu_rv_iu6_t1_i1_error(iu_rv_iu6_t1_i1_error),
            .iu_rv_iu6_t1_i1_btb_entry(iu_rv_iu6_t1_i1_btb_entry),
            .iu_rv_iu6_t1_i1_btb_hist(iu_rv_iu6_t1_i1_btb_hist),
            .iu_rv_iu6_t1_i1_bta_val(iu_rv_iu6_t1_i1_bta_val),
            .iu_rv_iu6_t1_i1_fusion(iu_rv_iu6_t1_i1_fusion),
            .iu_rv_iu6_t1_i1_spec(iu_rv_iu6_t1_i1_spec),
            .iu_rv_iu6_t1_i1_type_fp(iu_rv_iu6_t1_i1_type_fp),
            .iu_rv_iu6_t1_i1_type_ap(iu_rv_iu6_t1_i1_type_ap),
            .iu_rv_iu6_t1_i1_type_spv(iu_rv_iu6_t1_i1_type_spv),
            .iu_rv_iu6_t1_i1_type_st(iu_rv_iu6_t1_i1_type_st),
            .iu_rv_iu6_t1_i1_async_block(iu_rv_iu6_t1_i1_async_block),
            .iu_rv_iu6_t1_i1_np1_flush(iu_rv_iu6_t1_i1_np1_flush),
            .iu_rv_iu6_t1_i1_isram(iu_rv_iu6_t1_i1_isram),
            .iu_rv_iu6_t1_i1_isload(iu_rv_iu6_t1_i1_isload),
            .iu_rv_iu6_t1_i1_isstore(iu_rv_iu6_t1_i1_isstore),
            .iu_rv_iu6_t1_i1_instr(iu_rv_iu6_t1_i1_instr),
            .iu_rv_iu6_t1_i1_ifar(iu_rv_iu6_t1_i1_ifar),
            .iu_rv_iu6_t1_i1_bta(iu_rv_iu6_t1_i1_bta),
            .iu_rv_iu6_t1_i1_br_pred(iu_rv_iu6_t1_i1_br_pred),
            .iu_rv_iu6_t1_i1_bh_update(iu_rv_iu6_t1_i1_bh_update),
            .iu_rv_iu6_t1_i1_bh0_hist(iu_rv_iu6_t1_i1_bh0_hist),
            .iu_rv_iu6_t1_i1_bh1_hist(iu_rv_iu6_t1_i1_bh1_hist),
            .iu_rv_iu6_t1_i1_bh2_hist(iu_rv_iu6_t1_i1_bh2_hist),
            .iu_rv_iu6_t1_i1_gshare(iu_rv_iu6_t1_i1_gshare),
            .iu_rv_iu6_t1_i1_ls_ptr(iu_rv_iu6_t1_i1_ls_ptr),
            .iu_rv_iu6_t1_i1_match(iu_rv_iu6_t1_i1_match),
            .iu_rv_iu6_t1_i1_ilat(iu_rv_iu6_t1_i1_ilat),
            .iu_rv_iu6_t1_i1_t1_v(iu_rv_iu6_t1_i1_t1_v),
            .iu_rv_iu6_t1_i1_t1_t(iu_rv_iu6_t1_i1_t1_t),
            .iu_rv_iu6_t1_i1_t1_a(iu_rv_iu6_t1_i1_t1_a),
            .iu_rv_iu6_t1_i1_t1_p(iu_rv_iu6_t1_i1_t1_p),
            .iu_rv_iu6_t1_i1_t2_v(iu_rv_iu6_t1_i1_t2_v),
            .iu_rv_iu6_t1_i1_t2_a(iu_rv_iu6_t1_i1_t2_a),
            .iu_rv_iu6_t1_i1_t2_p(iu_rv_iu6_t1_i1_t2_p),
            .iu_rv_iu6_t1_i1_t2_t(iu_rv_iu6_t1_i1_t2_t),
            .iu_rv_iu6_t1_i1_t3_v(iu_rv_iu6_t1_i1_t3_v),
            .iu_rv_iu6_t1_i1_t3_a(iu_rv_iu6_t1_i1_t3_a),
            .iu_rv_iu6_t1_i1_t3_p(iu_rv_iu6_t1_i1_t3_p),
            .iu_rv_iu6_t1_i1_t3_t(iu_rv_iu6_t1_i1_t3_t),
            .iu_rv_iu6_t1_i1_s1_v(iu_rv_iu6_t1_i1_s1_v),
            .iu_rv_iu6_t1_i1_s1_a(iu_rv_iu6_t1_i1_s1_a),
            .iu_rv_iu6_t1_i1_s1_p(iu_rv_iu6_t1_i1_s1_p),
            .iu_rv_iu6_t1_i1_s1_itag(iu_rv_iu6_t1_i1_s1_itag),
            .iu_rv_iu6_t1_i1_s1_t(iu_rv_iu6_t1_i1_s1_t),
            .iu_rv_iu6_t1_i1_s1_dep_hit(iu_rv_iu6_t1_i1_s1_dep_hit),
            .iu_rv_iu6_t1_i1_s2_v(iu_rv_iu6_t1_i1_s2_v),
            .iu_rv_iu6_t1_i1_s2_a(iu_rv_iu6_t1_i1_s2_a),
            .iu_rv_iu6_t1_i1_s2_p(iu_rv_iu6_t1_i1_s2_p),
            .iu_rv_iu6_t1_i1_s2_itag(iu_rv_iu6_t1_i1_s2_itag),
            .iu_rv_iu6_t1_i1_s2_t(iu_rv_iu6_t1_i1_s2_t),
            .iu_rv_iu6_t1_i1_s2_dep_hit(iu_rv_iu6_t1_i1_s2_dep_hit),
            .iu_rv_iu6_t1_i1_s3_v(iu_rv_iu6_t1_i1_s3_v),
            .iu_rv_iu6_t1_i1_s3_a(iu_rv_iu6_t1_i1_s3_a),
            .iu_rv_iu6_t1_i1_s3_p(iu_rv_iu6_t1_i1_s3_p),
            .iu_rv_iu6_t1_i1_s3_itag(iu_rv_iu6_t1_i1_s3_itag),
            .iu_rv_iu6_t1_i1_s3_t(iu_rv_iu6_t1_i1_s3_t),
            .iu_rv_iu6_t1_i1_s3_dep_hit(iu_rv_iu6_t1_i1_s3_dep_hit),
`endif

            // Input to dispatch to block due to ivax
            .cp_dis_ivax(cp_dis_ivax),

            //-----------------------------
            // Stall from MMU
            //-----------------------------

            .mm_iu_flush_req(mm_iu_flush_req),
            .dp_cp_hold_req(dp_cp_hold_req),
            .mm_iu_hold_done(mm_iu_hold_done),
            .mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
            .dp_cp_bus_snoop_hold_req(dp_cp_bus_snoop_hold_req),
            .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
            .mm_iu_tlbi_complete(mm_iu_tlbi_complete)
         );

endmodule
