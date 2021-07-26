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
//* TITLE: Instruction Buffer
//*
//* NAME: iuq.v
//*
//*********************************************************************

(* recursive_synthesis="0" *)
`include "tri_a2o.vh"

module iuq(
   (* pin_data="PIN_FUNCTION=/G_CLK/" *)
   input [0:`NCLK_WIDTH-1]        nclk,
   input                          pc_iu_sg_3,
   input                          pc_iu_fce_3,
   input                          pc_iu_func_slp_sl_thold_3,	// was: chip_b_sl_2_thold_3_b
   input                          pc_iu_func_nsl_thold_3,		// added for custom cam
   input                          pc_iu_cfg_slp_sl_thold_3,		// for boot config slats
   input                          pc_iu_regf_slp_sl_thold_3,
   input                          pc_iu_func_sl_thold_3,
   input                          pc_iu_time_sl_thold_3,
   input                          pc_iu_abst_sl_thold_3,
   input                          pc_iu_abst_slp_sl_thold_3,
   input                          pc_iu_repr_sl_thold_3,
   input                          pc_iu_ary_nsl_thold_3,
   input                          pc_iu_ary_slp_nsl_thold_3,
   input                          pc_iu_func_slp_nsl_thold_3,
   input                          pc_iu_bolt_sl_thold_3,
   input                          clkoff_b,
   input                          act_dis,
   input                          tc_ac_ccflush_dc,
   input                          tc_ac_scan_dis_dc_b,
   input                          tc_ac_scan_diag_dc,
   input                          d_mode,
   input                          delay_lclkr,
   input                          mpw1_b,
   input                          mpw2_b,
   input                          scan_in,
   output                         scan_out,

   input [0:3]                    pc_iu_abist_dcomp_g6t_2r,
   input [0:3]                    pc_iu_abist_di_0,
   input [0:3]                    pc_iu_abist_di_g6t_2r,
   input                          pc_iu_abist_ena_dc,
   input [0:1]                    pc_iu_abist_g6t_bw,
   input                          pc_iu_abist_g6t_r_wb,
   input                          pc_iu_abist_g8t1p_renb_0,
   input                          pc_iu_abist_g8t_bw_0,
   input                          pc_iu_abist_g8t_bw_1,
   input [0:3]                    pc_iu_abist_g8t_dcomp,
   input                          pc_iu_abist_g8t_wenb,
   input [1:9]                    pc_iu_abist_raddr_0,
   input                          pc_iu_abist_raw_dc_b,
   input [3:9]                    pc_iu_abist_waddr_0,
   input                          pc_iu_abist_wl512_comp_ena,
   input                          pc_iu_abist_wl128_comp_ena,
   input                          an_ac_lbist_ary_wrt_thru_dc,
   input                          an_ac_lbist_en_dc,
   input                          an_ac_atpg_en_dc,
   input                          an_ac_grffence_en_dc,

   input                          pc_iu_bo_enable_3,		// bolt-on ABIST
   input                          pc_iu_bo_reset,
   input                          pc_iu_bo_unload,
   input                          pc_iu_bo_repair,
   input                          pc_iu_bo_shdata,
   input [0:4]                    pc_iu_bo_select,
   output [0:4]                   iu_pc_bo_fail,
   output [0:4]                   iu_pc_bo_diagout,

   output [0:`THREADS-1]          iu_pc_err_ucode_illegal,

   // Cache inject
   output                         iu_pc_err_icache_parity,
   output                         iu_pc_err_icachedir_parity,
   output                         iu_pc_err_icachedir_multihit,
   output                         iu_pc_err_ierat_multihit,
   output                         iu_pc_err_ierat_parity,
   input                          pc_iu_inj_icache_parity,
   input                          pc_iu_inj_icachedir_parity,
   input                          pc_iu_inj_icachedir_multihit,
   input                          pc_iu_init_reset,

   // spr ring
   input                          iu_slowspr_val_in,
   input                          iu_slowspr_rw_in,
   input [0:1]                    iu_slowspr_etid_in,
   input [0:9]                    iu_slowspr_addr_in,
   input [64-`GPR_WIDTH:63]       iu_slowspr_data_in,
   input                          iu_slowspr_done_in,
   output                         iu_slowspr_val_out,
   output                         iu_slowspr_rw_out,
   output [0:1]                   iu_slowspr_etid_out,
   output [0:9]                   iu_slowspr_addr_out,
   output [64-`GPR_WIDTH:63]      iu_slowspr_data_out,
   output                         iu_slowspr_done_out,

   input [0:`THREADS-1]           xu_iu_msr_ucle,
   input [0:`THREADS-1]           xu_iu_msr_de,
   input [0:`THREADS-1]           xu_iu_msr_pr,
   input [0:`THREADS-1]           xu_iu_msr_is,
   input [0:`THREADS-1]           xu_iu_msr_cm,
   input [0:`THREADS-1]           xu_iu_msr_gs,
   input [0:`THREADS-1]           xu_iu_msr_me,
   input [0:`THREADS-1]           xu_iu_dbcr0_edm,
   input [0:`THREADS-1]           xu_iu_dbcr0_idm,
   input [0:`THREADS-1]           xu_iu_dbcr0_icmp,
   input [0:`THREADS-1]           xu_iu_dbcr0_brt,
   input [0:`THREADS-1]           xu_iu_dbcr0_irpt,
   input [0:`THREADS-1]           xu_iu_dbcr0_trap,
   input [0:`THREADS-1]           xu_iu_iac1_en,
   input [0:`THREADS-1]           xu_iu_iac2_en,
   input [0:`THREADS-1]           xu_iu_iac3_en,
   input [0:`THREADS-1]           xu_iu_iac4_en,
   input [0:1]                    xu_iu_t0_dbcr0_dac1,
   input [0:1]                    xu_iu_t0_dbcr0_dac2,
   input [0:1]                    xu_iu_t0_dbcr0_dac3,
   input [0:1]                    xu_iu_t0_dbcr0_dac4,
`ifndef THREADS1
   input [0:1]                    xu_iu_t1_dbcr0_dac1,
   input [0:1]                    xu_iu_t1_dbcr0_dac2,
   input [0:1]                    xu_iu_t1_dbcr0_dac3,
   input [0:1]                    xu_iu_t1_dbcr0_dac4,
`endif
   input [0:`THREADS-1]           xu_iu_dbcr0_ret,
   input [0:`THREADS-1]           xu_iu_dbcr1_iac12m,
   input [0:`THREADS-1]           xu_iu_dbcr1_iac34m,
   input [0:`THREADS-1]           lq_iu_spr_dbcr3_ivc,
   input [0:`THREADS-1]           xu_iu_epcr_extgs,
   input [0:`THREADS-1]           xu_iu_epcr_dtlbgs,
   input [0:`THREADS-1]           xu_iu_epcr_itlbgs,
   input [0:`THREADS-1]           xu_iu_epcr_dsigs,
   input [0:`THREADS-1]           xu_iu_epcr_isigs,
   input [0:`THREADS-1]           xu_iu_epcr_duvd,
   input [0:`THREADS-1]           xu_iu_epcr_dgtmi,
   input [0:`THREADS-1]           xu_iu_epcr_icm,
   input [0:`THREADS-1]           xu_iu_epcr_gicm,
   input [0:`THREADS-1]           xu_iu_msrp_uclep,
   input                          xu_iu_hid_mmu_mode,
   input                          xu_iu_spr_ccr2_en_dcr,
   input                          xu_iu_spr_ccr2_ifrat,
   input [0:8]                    xu_iu_spr_ccr2_ifratsc,		// 0:4: wimge, 5:8: u0:3
   input                          xu_iu_spr_ccr2_ucode_dis,
   input                          xu_iu_xucr4_mmu_mchk,

   output                         iu_mm_ierat_req,
   output                         iu_mm_ierat_req_nonspec,
   output [0:51]                  iu_mm_ierat_epn,
   output [0:`THREADS-1]          iu_mm_ierat_thdid,
   output [0:3]                   iu_mm_ierat_state,
   output [0:13]                  iu_mm_ierat_tid,
   output [0:`THREADS-1]          iu_mm_ierat_flush,
   output [0:`THREADS-1]          iu_mm_perf_itlb,

   input [0:4]                    mm_iu_ierat_rel_val,
   input [0:131]                  mm_iu_ierat_rel_data,
   input [0:`THREADS-1]           mm_iu_ierat_pt_fault,
   input [0:`THREADS-1]           mm_iu_ierat_lrat_miss,
   input [0:`THREADS-1]           mm_iu_ierat_tlb_inelig,
   input [0:`THREADS-1]           mm_iu_tlb_multihit_err,
   input [0:`THREADS-1]           mm_iu_tlb_par_err,
   input [0:`THREADS-1]           mm_iu_lru_par_err,
   input [0:`THREADS-1]           mm_iu_tlb_miss,

   input [0:13]                   mm_iu_t0_ierat_pid,
   input [0:19]                   mm_iu_t0_ierat_mmucr0,
`ifndef THREADS1
   input [0:13]                   mm_iu_t1_ierat_pid,
   input [0:19]                   mm_iu_t1_ierat_mmucr0,
`endif
   output [0:17]                  iu_mm_ierat_mmucr0,
   output [0:`THREADS-1]          iu_mm_ierat_mmucr0_we,
   input [0:8]                    mm_iu_ierat_mmucr1,
   output [0:3]                   iu_mm_ierat_mmucr1,
   output                         iu_mm_ierat_mmucr1_we,

   input                          mm_iu_ierat_snoop_coming,
   input                          mm_iu_ierat_snoop_val,
   input [0:25]                   mm_iu_ierat_snoop_attr,
   input [(62-`EFF_IFAR_ARCH):51] mm_iu_ierat_snoop_vpn,
   output                         iu_mm_ierat_snoop_ack,

   output [0:`THREADS-1]          iu_mm_hold_ack,
   input [0:`THREADS-1]           mm_iu_hold_req,
   input [0:`THREADS-1]           mm_iu_flush_req,
   input [0:`THREADS-1]           mm_iu_hold_done,

   output [0:`THREADS-1]          iu_mm_bus_snoop_hold_ack,
   input [0:`THREADS-1]           mm_iu_bus_snoop_hold_req,
   input [0:`THREADS-1]           mm_iu_bus_snoop_hold_done,

   input [0:`THREADS-1]           mm_iu_tlbi_complete,

   input                          mm_iu_tlbwe_binv,

   output [0:5]                   cp_mm_except_taken_t0,
`ifndef THREADS1
   output [0:5]                   cp_mm_except_taken_t1,
`endif

   input                          an_ac_back_inv,
   input [64-`REAL_IFAR_WIDTH:57] an_ac_back_inv_addr,
   input                          an_ac_back_inv_target,		// connect to bit(0)

   output [0:`THREADS-1]          iu_lq_request,
   output [0:1]                   iu_lq_ctag,
   output [64-`REAL_IFAR_WIDTH:59] iu_lq_ra,
   output [0:4]                   iu_lq_wimge,
   output [0:3]                   iu_lq_userdef,

   input                          an_ac_reld_data_vld,
   input [0:4]                    an_ac_reld_core_tag,
   input [58:59]                  an_ac_reld_qw,
   input [0:127]                  an_ac_reld_data,
   input                          an_ac_reld_ecc_err,
   input                          an_ac_reld_ecc_err_ue,

   output                         iu_mm_lmq_empty,
   output [0:`THREADS-1]          iu_xu_icache_quiesce,
   output [0:`THREADS-1]          iu_pc_icache_quiesce,

   output			  iu_pc_err_btb_parity,


   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output									iu_rv_iu6_t0_i0_vld,
   output									iu_rv_iu6_t0_i0_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t0_i0_itag,
   output [0:2]  							iu_rv_iu6_t0_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t0_i0_ucode_cnt,
   output									iu_rv_iu6_t0_i0_2ucode,
   output									iu_rv_iu6_t0_i0_rte_lq,
   output									iu_rv_iu6_t0_i0_rte_sq,
   output									iu_rv_iu6_t0_i0_rte_fx0,
   output									iu_rv_iu6_t0_i0_rte_fx1,
   output									iu_rv_iu6_t0_i0_rte_axu0,
   output									iu_rv_iu6_t0_i0_rte_axu1,
   output									iu_rv_iu6_t0_i0_ord,
   output									iu_rv_iu6_t0_i0_cord,
   output									iu_rv_iu6_t0_i0_bta_val,
   output [0:19]							iu_rv_iu6_t0_i0_fusion,
   output									iu_rv_iu6_t0_i0_spec,
   output									iu_rv_iu6_t0_i0_isload,
   output									iu_rv_iu6_t0_i0_isstore,
   output [0:31]							iu_rv_iu6_t0_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i0_bta,
   output									iu_rv_iu6_t0_i0_br_pred,
   output									iu_rv_iu6_t0_i0_bh_update,
   output [0:17]          				iu_rv_iu6_t0_i0_gshare,
   output [0:2]          				iu_rv_iu6_t0_i0_ls_ptr,
   output [0:3]          				iu_rv_iu6_t0_i0_ilat,
   output									iu_rv_iu6_t0_i0_t1_v,
   output [0:2]          				iu_rv_iu6_t0_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t1_p,
   output									iu_rv_iu6_t0_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i0_t2_p,
   output [0:2]          				iu_rv_iu6_t0_i0_t2_t,
   output									iu_rv_iu6_t0_i0_t3_v,
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
   output									iu_rv_iu6_t0_i1_rte_lq,
   output									iu_rv_iu6_t0_i1_rte_sq,
   output									iu_rv_iu6_t0_i1_rte_fx0,
   output									iu_rv_iu6_t0_i1_rte_fx1,
   output									iu_rv_iu6_t0_i1_rte_axu0,
   output									iu_rv_iu6_t0_i1_rte_axu1,
   output									iu_rv_iu6_t0_i1_ord,
   output									iu_rv_iu6_t0_i1_cord,
   output									iu_rv_iu6_t0_i1_bta_val,
   output [0:19]							iu_rv_iu6_t0_i1_fusion,
   output									iu_rv_iu6_t0_i1_spec,
   output									iu_rv_iu6_t0_i1_isload,
   output									iu_rv_iu6_t0_i1_isstore,
   output [0:31]							iu_rv_iu6_t0_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t0_i1_bta,
   output									iu_rv_iu6_t0_i1_br_pred,
   output									iu_rv_iu6_t0_i1_bh_update,
   output [0:17]          				iu_rv_iu6_t0_i1_gshare,
   output [0:2]          				iu_rv_iu6_t0_i1_ls_ptr,
   output [0:3]          				iu_rv_iu6_t0_i1_ilat,
   output									iu_rv_iu6_t0_i1_t1_v,
   output [0:2]							iu_rv_iu6_t0_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t1_p,
   output									iu_rv_iu6_t0_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t0_i1_t2_p,
   output [0:2]          				iu_rv_iu6_t0_i1_t2_t,
   output									iu_rv_iu6_t0_i1_t3_v,
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
   //----------------------------------------------------------------
   // Interface to reservation station - Completion is snooping also
   //----------------------------------------------------------------
   output									iu_rv_iu6_t1_i0_vld,
   output									iu_rv_iu6_t1_i0_act,
   output [0:`ITAG_SIZE_ENC-1]		iu_rv_iu6_t1_i0_itag,
   output [0:2]  							iu_rv_iu6_t1_i0_ucode,
   output [0:`UCODE_ENTRIES_ENC-1]	iu_rv_iu6_t1_i0_ucode_cnt,
   output									iu_rv_iu6_t1_i0_2ucode,
   output									iu_rv_iu6_t1_i0_rte_lq,
   output									iu_rv_iu6_t1_i0_rte_sq,
   output									iu_rv_iu6_t1_i0_rte_fx0,
   output									iu_rv_iu6_t1_i0_rte_fx1,
   output									iu_rv_iu6_t1_i0_rte_axu0,
   output									iu_rv_iu6_t1_i0_rte_axu1,
   output									iu_rv_iu6_t1_i0_ord,
   output									iu_rv_iu6_t1_i0_cord,
   output									iu_rv_iu6_t1_i0_bta_val,
   output [0:19]							iu_rv_iu6_t1_i0_fusion,
   output									iu_rv_iu6_t1_i0_spec,
   output									iu_rv_iu6_t1_i0_isload,
   output									iu_rv_iu6_t1_i0_isstore,
   output [0:31]							iu_rv_iu6_t1_i0_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i0_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i0_bta,
   output									iu_rv_iu6_t1_i0_br_pred,
   output									iu_rv_iu6_t1_i0_bh_update,
   output [0:17]          				iu_rv_iu6_t1_i0_gshare,
   output [0:2]          				iu_rv_iu6_t1_i0_ls_ptr,
   output [0:3]          				iu_rv_iu6_t1_i0_ilat,
   output									iu_rv_iu6_t1_i0_t1_v,
   output [0:2]          				iu_rv_iu6_t1_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t1_p,
   output									iu_rv_iu6_t1_i0_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i0_t2_p,
   output [0:2]          				iu_rv_iu6_t1_i0_t2_t,
   output									iu_rv_iu6_t1_i0_t3_v,
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
   output									iu_rv_iu6_t1_i1_rte_lq,
   output									iu_rv_iu6_t1_i1_rte_sq,
   output									iu_rv_iu6_t1_i1_rte_fx0,
   output									iu_rv_iu6_t1_i1_rte_fx1,
   output									iu_rv_iu6_t1_i1_rte_axu0,
   output									iu_rv_iu6_t1_i1_rte_axu1,
   output									iu_rv_iu6_t1_i1_ord,
   output									iu_rv_iu6_t1_i1_cord,
   output									iu_rv_iu6_t1_i1_bta_val,
   output [0:19]							iu_rv_iu6_t1_i1_fusion,
   output									iu_rv_iu6_t1_i1_spec,
   output									iu_rv_iu6_t1_i1_isload,
   output									iu_rv_iu6_t1_i1_isstore,
   output [0:31]							iu_rv_iu6_t1_i1_instr,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i1_ifar,
   output [62-`EFF_IFAR_WIDTH:61]	iu_rv_iu6_t1_i1_bta,
   output									iu_rv_iu6_t1_i1_br_pred,
   output									iu_rv_iu6_t1_i1_bh_update,
   output [0:17]          				iu_rv_iu6_t1_i1_gshare,
   output [0:2]          				iu_rv_iu6_t1_i1_ls_ptr,
   output [0:3]          				iu_rv_iu6_t1_i1_ilat,
   output									iu_rv_iu6_t1_i1_t1_v,
   output [0:2]							iu_rv_iu6_t1_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t1_p,
   output									iu_rv_iu6_t1_i1_t2_v,
   output [0:`GPR_POOL_ENC-1]			iu_rv_iu6_t1_i1_t2_p,
   output [0:2]          				iu_rv_iu6_t1_i1_t2_t,
   output									iu_rv_iu6_t1_i1_t3_v,
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

   // XER read bus to RF for store conditionals
   output [0:`XER_POOL_ENC-1]     iu_rf_t0_xer_p,
`ifndef THREADS1
   output [0:`XER_POOL_ENC-1]     iu_rf_t1_xer_p,
`endif

   // Credit Interface with IU
   input [0:`THREADS-1]           rv_iu_fx0_credit_free,
   input [0:`THREADS-1]           rv_iu_fx1_credit_free,
   input [0:`THREADS-1]           axu0_iu_credit_free,
   input [0:`THREADS-1]           axu1_iu_credit_free,

   // LQ Instruction Executed
   input [0:`THREADS-1]           lq0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     lq0_iu_itag,
   input                          lq0_iu_n_flush,
   input                          lq0_iu_np1_flush,
   input                          lq0_iu_dacr_type,
   input [0:3]                    lq0_iu_dacrw,
   input [0:31]                   lq0_iu_instr,
   input [64-`GPR_WIDTH:63]       lq0_iu_eff_addr,
   input                          lq0_iu_exception_val,
   input [0:5]                    lq0_iu_exception,
   input                          lq0_iu_flush2ucode,
   input                          lq0_iu_flush2ucode_type,
   input [0:`THREADS-1]           lq0_iu_recirc_val,
   input [0:`THREADS-1]           lq0_iu_dear_val,

   input [0:`THREADS-1]           lq1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     lq1_iu_itag,
   input                          lq1_iu_n_flush,
   input                          lq1_iu_np1_flush,
   input                          lq1_iu_exception_val,
   input [0:5]                    lq1_iu_exception,
   input                          lq1_iu_dacr_type,
   input [0:3]                    lq1_iu_dacrw,
   input [0:3]                    lq1_iu_perf_events,

   input [0:`THREADS-1]           lq_iu_credit_free,
   input [0:`THREADS-1]           sq_iu_credit_free,

   // Interface IU ucode
   input [0:`THREADS-1]           xu_iu_ucode_xer_val,
   input [57:63]                  xu_iu_ucode_xer,

   // Complete iTag
   output [0:`THREADS-1]          iu_lq_i0_completed,
   output [0:`THREADS-1]          iu_lq_i1_completed,
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_t0_i0_completed_itag,
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_t0_i1_completed_itag,
`ifndef THREADS1
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_t1_i0_completed_itag,
   output [0:`ITAG_SIZE_ENC-1]   iu_lq_t1_i1_completed_itag,
`endif
   output [0:`THREADS-1]          iu_lq_recirc_val,

   // ICBI Interface to IU
   input [0:`THREADS-1]           lq_iu_icbi_val,
   input [64-`REAL_IFAR_WIDTH:57] lq_iu_icbi_addr,
   output [0:`THREADS-1]          iu_lq_icbi_complete,
   input                          lq_iu_ici_val,
   output                         iu_lq_spr_iucr0_icbi_ack,

   // BR Instruction Executed
   input [0:`THREADS-1]           br_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     br_iu_itag,
   input [62-`EFF_IFAR_ARCH:61]   br_iu_bta,
   input                          br_iu_taken,
   input [0:`THREADS-1]           br_iu_redirect,
   input [0:3]			             br_iu_perf_events,

   //br unit repairs
   input [0:17]                   br_iu_gshare,
   input [0:2]                    br_iu_ls_ptr,
   input [62-`EFF_IFAR_WIDTH:61]  br_iu_ls_data,
   input                          br_iu_ls_update,

   // XU0 Instruction Executed
   input [0:`THREADS-1]           xu_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     xu_iu_itag,
   input                          xu_iu_n_flush,
   input                          xu_iu_np1_flush,
   input                          xu_iu_flush2ucode,
   input                          xu_iu_exception_val,
   input [0:4]                    xu_iu_exception,
   input [0:`THREADS-1]           xu_iu_mtiar,
   input [62-`EFF_IFAR_ARCH:61]   xu_iu_bta,
   input [0:3]                    xu_iu_perf_events,

   // XU1 Instruction Executed
   input [0:`THREADS-1]           xu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     xu1_iu_itag,

   // XU IERAT interface
   input [0:`THREADS-1]           xu_iu_val,
   input [0:`THREADS-1]           xu_iu_pri_val,
   input [0:2]                    xu_iu_pri,
   input                          xu_iu_is_eratre,
   input                          xu_iu_is_eratwe,
   input                          xu_iu_is_eratsx,
   input                          xu_iu_is_eratilx,
   input [0:1]                    xu_iu_ws,
   input [0:3]                    xu_iu_ra_entry,
   input [64-`GPR_WIDTH:51]       xu_iu_rb,
   input [64-`GPR_WIDTH:63]       xu_iu_rs_data,
   output                         iu_xu_ord_read_done,
   output                         iu_xu_ord_write_done,
   output                         iu_xu_ord_par_err,
   output                         iu_xu_ord_n_flush_req,
   output [64-`GPR_WIDTH:63]      iu_xu_ex5_data,

   // AXU0 Instruction Executed
   input [0:`THREADS-1]           axu0_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     axu0_iu_itag,
   input                          axu0_iu_n_flush,
   input                          axu0_iu_np1_flush,
   input                          axu0_iu_n_np1_flush,
   input [0:3]                    axu0_iu_exception,
   input                          axu0_iu_flush2ucode,
   input                          axu0_iu_flush2ucode_type,
   input                          axu0_iu_exception_val,
   input [0:`THREADS-1]           axu0_iu_async_fex,
   input [0:3]                    axu0_iu_perf_events,

   // AXU1 Instruction Executed
   input [0:`THREADS-1]           axu1_iu_execute_vld,
   input [0:`ITAG_SIZE_ENC-1]     axu1_iu_itag,
   input                          axu1_iu_n_flush,
   input                          axu1_iu_np1_flush,
   input [0:3]                    axu1_iu_exception,
   input                          axu1_iu_flush2ucode,
   input                          axu1_iu_flush2ucode_type,
   input                          axu1_iu_exception_val,
   input [0:3]                    axu1_iu_perf_events,

   // Completion and XU
   // Run State
   output [0:`THREADS-1]          iu_xu_stop,
   input [0:`THREADS-1]           xu_iu_run_thread,
   output			  iu_xu_credits_returned,
   input [0:`THREADS-1]           xu_iu_single_instr_mode,
   input [0:`THREADS-1]           xu_iu_raise_iss_pri,
   output [0:`THREADS-1]          iu_xu_quiesce,
   output [0:`THREADS-1]          iu_pc_quiesce,
   // Interrupt Interface
   output [0:`THREADS-1]          iu_xu_rfi,
   output [0:`THREADS-1]          iu_xu_rfgi,
   output [0:`THREADS-1]          iu_xu_rfci,
   output [0:`THREADS-1]          iu_xu_rfmci,
   output [0:`THREADS-1]          iu_xu_int,
   output [0:`THREADS-1]          iu_xu_gint,
   output [0:`THREADS-1]          iu_xu_cint,
   output [0:`THREADS-1]          iu_xu_mcint,
   output [0:`THREADS-1]          iu_xu_dear_update,
   output [62-`EFF_IFAR_ARCH:61]  iu_xu_t0_nia,
   output [0:16]                  iu_xu_t0_esr,
   output [0:14]                  iu_xu_t0_mcsr,
   output [0:18]                  iu_xu_t0_dbsr,
   output [64-`GPR_WIDTH:63]      iu_xu_t0_dear,
`ifndef THREADS1
   output [62-`EFF_IFAR_ARCH:61]  iu_xu_t1_nia,
   output [0:16]                  iu_xu_t1_esr,
   output [0:14]                  iu_xu_t1_mcsr,
   output [0:18]                  iu_xu_t1_dbsr,
   output [64-`GPR_WIDTH:63]      iu_xu_t1_dear,
`endif
   output [0:`THREADS-1]          iu_xu_dbsr_update,
   output [0:`THREADS-1]          iu_xu_dbsr_ude,
   output [0:`THREADS-1]          iu_xu_dbsr_ide,
   output [0:`THREADS-1]          iu_xu_esr_update,
   output [0:`THREADS-1]          iu_xu_act,
   output [0:`THREADS-1]          iu_xu_dbell_taken,
   output [0:`THREADS-1]          iu_xu_cdbell_taken,
   output [0:`THREADS-1]          iu_xu_gdbell_taken,
   output [0:`THREADS-1]          iu_xu_gcdbell_taken,
   output [0:`THREADS-1]          iu_xu_gmcdbell_taken,
   output [0:`THREADS-1]          iu_xu_instr_cpl,
   input [0:`THREADS-1]           xu_iu_np1_async_flush,
   output [0:`THREADS-1]          iu_xu_async_complete,

   // Interrupts
	input [0:`THREADS-1]           an_ac_uncond_dbg_event,
   input [0:`THREADS-1]           xu_iu_external_mchk,
   input [0:`THREADS-1]           xu_iu_ext_interrupt,
   input [0:`THREADS-1]           xu_iu_dec_interrupt,
   input [0:`THREADS-1]           xu_iu_udec_interrupt,
   input [0:`THREADS-1]           xu_iu_perf_interrupt,
   input [0:`THREADS-1]           xu_iu_fit_interrupt,
   input [0:`THREADS-1]           xu_iu_crit_interrupt,
   input [0:`THREADS-1]           xu_iu_wdog_interrupt,
   input [0:`THREADS-1]           xu_iu_gwdog_interrupt,
   input [0:`THREADS-1]           xu_iu_gfit_interrupt,
   input [0:`THREADS-1]           xu_iu_gdec_interrupt,
   input [0:`THREADS-1]           xu_iu_dbell_interrupt,
   input [0:`THREADS-1]           xu_iu_cdbell_interrupt,
   input [0:`THREADS-1]           xu_iu_gdbell_interrupt,
   input [0:`THREADS-1]           xu_iu_gcdbell_interrupt,
   input [0:`THREADS-1]           xu_iu_gmcdbell_interrupt,
   input [0:`THREADS-1]           xu_iu_dbsr_ide,
   input [62-`EFF_IFAR_ARCH:61]   xu_iu_t0_rest_ifar,
`ifndef THREADS1
   input [62-`EFF_IFAR_ARCH:61]   xu_iu_t1_rest_ifar,
`endif


   input [0:`THREADS-1]           pc_iu_pm_fetch_halt,
   //Ram interface
   input [0:31]                   pc_iu_ram_instr,
   input [0:3]                    pc_iu_ram_instr_ext,
   input                          pc_iu_ram_issue,
   output                         iu_pc_ram_done,
   output                         iu_pc_ram_interrupt,
   output                         iu_pc_ram_unsupported,
   input [0:`THREADS-1]           pc_iu_ram_active,
   input [0:`THREADS-1]           pc_iu_ram_flush_thread,
   input [0:`THREADS-1]           xu_iu_msrovride_enab,
   input [0:`THREADS-1]           pc_iu_stop,
   input [0:`THREADS-1]           pc_iu_step,
   input [0:2]                    pc_iu_t0_dbg_action,
`ifndef THREADS1
   input [0:2]                    pc_iu_t1_dbg_action,
`endif
   output [0:`THREADS-1]          iu_pc_step_done,
   output [0:`THREADS-1]          iu_pc_stop_dbg_event,
   output [0:`THREADS-1]          iu_pc_err_debug_event,
   output [0:`THREADS-1]          iu_pc_attention_instr,
   output [0:`THREADS-1]          iu_pc_err_mchk_disabled,
   output [0:`THREADS-1]          ac_an_debug_trigger,

   output [0:`THREADS-1]          cp_axu_i0_t1_v,
   output [0:`THREADS-1]          cp_axu_i1_t1_v,
   output [0:`TYPE_WIDTH-1]       cp_axu_t0_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]     cp_axu_t0_i0_t1_p,
   output [0:`TYPE_WIDTH-1]       cp_axu_t0_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]     cp_axu_t0_i1_t1_p,
`ifndef THREADS1
   output [0:`TYPE_WIDTH-1]       cp_axu_t1_i0_t1_t,
   output [0:`GPR_POOL_ENC-1]     cp_axu_t1_i0_t1_p,
   output [0:`TYPE_WIDTH-1]       cp_axu_t1_i1_t1_t,
   output [0:`GPR_POOL_ENC-1]     cp_axu_t1_i1_t1_p,
`endif

   output                         cp_is_isync,
   output                         cp_is_csync,

   // Completion flush
   output [0:`THREADS-1]          cp_flush,
`ifndef THREADS1
   output [0:`ITAG_SIZE_ENC-1]    cp_t1_next_itag,
   output [0:`ITAG_SIZE_ENC-1]    cp_t1_flush_itag,
   output [62-`EFF_IFAR_ARCH:61]  cp_t1_flush_ifar,
`endif
   output [0:`ITAG_SIZE_ENC-1]    cp_t0_next_itag,
   output [0:`ITAG_SIZE_ENC-1]    cp_t0_flush_itag,
   output [62-`EFF_IFAR_ARCH:61]  cp_t0_flush_ifar,

   // Performance
   input                          pc_iu_event_bus_enable,
   input [0:2]			  pc_iu_event_count_mode,
   input [0:4*`THREADS-1]         iu_event_bus_in,
   output [0:4*`THREADS-1]        iu_event_bus_out,

   output [0:`THREADS-1]        iu_pc_fx0_credit_ok,
   output [0:`THREADS-1]        iu_pc_fx1_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu0_credit_ok,
   output [0:`THREADS-1]        iu_pc_axu1_credit_ok,
   output [0:`THREADS-1]        iu_pc_lq_credit_ok,
   output [0:`THREADS-1]        iu_pc_sq_credit_ok,


   // Debug Trace
   input                          pc_iu_trace_bus_enable,
   input  [0:10]                  pc_iu_debug_mux1_ctrls,
   input  [0:10]                  pc_iu_debug_mux2_ctrls,

   input  [0:31]                  debug_bus_in,
   output [0:31]                  debug_bus_out,
   input  [0:3]                   coretrace_ctrls_in,
   output [0:3]                   coretrace_ctrls_out
   );

   // scan
   wire                           btb_scan_in;
   wire                           btb_scan_out;
   wire                           bh0_scan_in;
   wire                           bh0_scan_out;
   wire                           bh1_scan_in;
   wire                           bh1_scan_out;
   wire                           bh2_scan_in;
   wire                           bh2_scan_out;
   wire [0:2*`THREADS-1]          bp_scan_in;
   wire [0:2*`THREADS-1]          bp_scan_out;
   wire [0:`THREADS*7]            slice_scan_in;
   wire [0:`THREADS*7]            slice_scan_out;
   wire [0:`THREADS]              cp_scan_in;
   wire [0:`THREADS]              cp_scan_out;
   wire                           func_scan_in;
   wire                           func_scan_out;
   wire                           ac_ccfg_scan_in;
   wire                           ac_ccfg_scan_out;
   wire                           time_scan_in;
   wire                           time_scan_out;
   wire                           repr_scan_in;
   wire                           repr_scan_out;
   wire [0:2]                     abst_scan_in;
   wire [0:2]                     abst_scan_out;
   wire [0:4]                     regf_scan_in;
   wire [0:4]                     regf_scan_out;
   wire [0:`THREADS-1]            uc_scan_in;
   wire [0:`THREADS-1]            uc_scan_out;
   wire                           ram_scan_in;
   wire                           ram_scan_out;
   wire                           dbg1_scan_in;
   wire                           dbg1_scan_out;

   wire [0:`THREADS-1]            cp_async_block;

   // ERAT connections to these need to be cleaned up for A2O
   wire                           cp_ic_is_isync;
   wire                           cp_ic_is_csync;
   // bp
   wire [0:1]                     iu2_0_bh0_rd_data;
   wire [0:1]                     iu2_1_bh0_rd_data;
   wire [0:1]                     iu2_2_bh0_rd_data;
   wire [0:1]                     iu2_3_bh0_rd_data;
   wire [0:1]                     iu2_0_bh1_rd_data;
   wire [0:1]                     iu2_1_bh1_rd_data;
   wire [0:1]                     iu2_2_bh1_rd_data;
   wire [0:1]                     iu2_3_bh1_rd_data;
   wire				  iu2_0_bh2_rd_data;
   wire				  iu2_1_bh2_rd_data;
   wire				  iu2_2_bh2_rd_data;
   wire				  iu2_3_bh2_rd_data;
   wire [0:9]                     iu0_bh0_rd_addr;
   wire [0:9]                     iu0_bh1_rd_addr;
   wire [0:8]                     iu0_bh2_rd_addr;
   wire                           iu0_bh0_rd_act;
   wire                           iu0_bh1_rd_act;
   wire                           iu0_bh2_rd_act;
   wire [0:1]                     ex5_bh0_wr_data;
   wire [0:1]                     ex5_bh1_wr_data;
   wire				  ex5_bh2_wr_data;
   wire [0:9]                     ex5_bh0_wr_addr;
   wire [0:9]                     ex5_bh1_wr_addr;
   wire [0:8]                     ex5_bh2_wr_addr;
   wire [0:3]                     ex5_bh0_wr_act;
   wire [0:3]                     ex5_bh1_wr_act;
   wire [0:3]                     ex5_bh2_wr_act;
   wire [0:5]                     iu0_btb_rd_addr;
   wire                           iu0_btb_rd_act;
   wire [0:63]			  iu2_btb_rd_data;
   wire [0:5]                     ex5_btb_wr_addr;
   wire                           ex5_btb_wr_act;
   wire [0:63]			  ex5_btb_wr_data;
   wire [0:`THREADS-1]             cp_bp_val;
   wire [62-`EFF_IFAR_WIDTH:61]    cp_bp_t0_ifar;
   wire [0:1]                      cp_bp_t0_bh0_hist;
   wire [0:1]                      cp_bp_t0_bh1_hist;
   wire [0:1]                      cp_bp_t0_bh2_hist;
   wire [0:`THREADS-1]             cp_bp_br_pred;
   wire [0:`THREADS-1]             cp_bp_br_taken;
   wire [0:`THREADS-1]             cp_bp_bh_update;
   wire [0:`THREADS-1]             cp_bp_bcctr;
   wire [0:`THREADS-1]             cp_bp_bclr;
   wire [0:`THREADS-1]             cp_bp_getNIA;
   wire [0:`THREADS-1]             cp_bp_group;
   wire [0:`THREADS-1]             cp_bp_lk;
   wire [0:1]                      cp_bp_t0_bh;
   wire [62-`EFF_IFAR_WIDTH:61]    cp_bp_t0_ctr;
   wire [0:9]                      cp_bp_t0_gshare;
   wire [0:2]                      cp_bp_t0_ls_ptr;
   wire [0:`THREADS-1]             cp_bp_btb_entry;
   wire [0:1]                      cp_bp_t0_btb_hist;
`ifndef THREADS1
   wire [62-`EFF_IFAR_WIDTH:61]    cp_bp_t1_ifar;
   wire [0:1]                      cp_bp_t1_bh0_hist;
   wire [0:1]                      cp_bp_t1_bh1_hist;
   wire [0:1]                      cp_bp_t1_bh2_hist;
   wire [0:1]                      cp_bp_t1_bh;
   wire [62-`EFF_IFAR_WIDTH:61]    cp_bp_t1_ctr;
   wire [0:9]                      cp_bp_t1_gshare;
   wire [0:2]                      cp_bp_t1_ls_ptr;
   wire [0:1]                      cp_bp_t1_btb_hist;
`endif
   // ibuf
   wire [0:`IBUFF_DEPTH/4-1]       ib_ic_t0_need_fetch;
   wire [0:3]                      bp_ib_iu3_t0_val;
   wire [62-`EFF_IFAR_WIDTH:61]    bp_ib_iu3_t0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    bp_ib_iu3_t0_bta;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t0_0_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t0_1_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t0_2_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t0_3_instr;
`ifndef THREADS1
   wire [0:`IBUFF_DEPTH/4-1]       ib_ic_t1_need_fetch;
   wire [0:3]                      bp_ib_iu3_t1_val;
   wire [62-`EFF_IFAR_WIDTH:61]    bp_ib_iu3_t1_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    bp_ib_iu3_t1_bta;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t1_0_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t1_1_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t1_2_instr;
   wire [0:`IBUFF_INSTR_WIDTH-1]   bp_ib_iu3_t1_3_instr;
`endif

   // idec
   wire [0:31]                     spr_dec_mask;
   wire [0:31]                     spr_dec_match;

   // rn
   wire [0:`THREADS-1]             spr_single_issue;
   wire [0:`THREADS-1]             cp_rn_empty;
   wire [0:`THREADS-1]             iu_flush;
   wire [0:`THREADS-1]             cp_iu0_flush_2ucode;
   wire [0:`THREADS-1]             cp_iu0_flush_2ucode_type;
   wire [0:`THREADS-1]             cp_iu0_flush_nonspec;
   wire [0:`THREADS-1]             ic_cp_nonspec_hit;

   // Output to dispatch to block due to ivax
   wire [0:`THREADS-1]             cp_dis_ivax;

   // Instruction 0 Complete
   wire                            cp_rn_t0_i0_v;
   wire                            cp_rn_t0_i0_axu_exception_val;
   wire [0:3]                      cp_rn_t0_i0_axu_exception;
   wire                            cp_rn_t0_i0_t1_v;
   wire [0:2]                      cp_rn_t0_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t1_a;

   wire                            cp_rn_t0_i0_t2_v;
   wire [0:2]                      cp_rn_t0_i0_t2_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t2_a;

   wire                            cp_rn_t0_i0_t3_v;
   wire [0:2]                      cp_rn_t0_i0_t3_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t3_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i0_t3_a;

   // Instruction 1 Complete
   wire                            cp_rn_t0_i1_v;
   wire                            cp_rn_t0_i1_axu_exception_val;
   wire [0:3]                      cp_rn_t0_i1_axu_exception;
   wire                            cp_rn_t0_i1_t1_v;
   wire [0:2]                      cp_rn_t0_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t1_a;

   wire                            cp_rn_t0_i1_t2_v;
   wire [0:2]                      cp_rn_t0_i1_t2_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t2_a;

   wire                            cp_rn_t0_i1_t3_v;
   wire [0:2]                      cp_rn_t0_i1_t3_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t3_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t0_i1_t3_a;
`ifndef THREADS1
   // Instruction 0 Complete
   wire                            cp_rn_t1_i0_v;
   wire                            cp_rn_t1_i0_axu_exception_val;
   wire [0:3]                      cp_rn_t1_i0_axu_exception;
   wire                            cp_rn_t1_i0_t1_v;
   wire [0:2]                      cp_rn_t1_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t1_a;

   wire                            cp_rn_t1_i0_t2_v;
   wire [0:2]                      cp_rn_t1_i0_t2_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t2_a;

   wire                            cp_rn_t1_i0_t3_v;
   wire [0:2]                      cp_rn_t1_i0_t3_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t3_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i0_t3_a;

   // Instruction 1 Complete
   wire                            cp_rn_t1_i1_v;
   wire                            cp_rn_t1_i1_axu_exception_val;
   wire [0:3]                      cp_rn_t1_i1_axu_exception;
   wire                            cp_rn_t1_i1_t1_v;
   wire [0:2]                      cp_rn_t1_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t1_a;

   wire                            cp_rn_t1_i1_t2_v;
   wire [0:2]                      cp_rn_t1_i1_t2_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t2_a;

   wire                            cp_rn_t1_i1_t3_v;
   wire [0:2]                      cp_rn_t1_i1_t3_t;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t3_p;
   wire [0:`GPR_POOL_ENC-1]        cp_rn_t1_i1_t3_a;
`endif
   // Instruction 0 Issue
   wire                            rn_cp_iu6_t0_i0_vld;
   wire [0:`ITAG_SIZE_ENC-1]       rn_cp_iu6_t0_i0_itag;
   wire [0:2]                      rn_cp_iu6_t0_i0_ucode;
   wire                            rn_cp_iu6_t0_i0_fuse_nop;
   wire                            rn_cp_iu6_t0_i0_rte_lq;
   wire                            rn_cp_iu6_t0_i0_rte_sq;
   wire                            rn_cp_iu6_t0_i0_rte_fx0;
   wire                            rn_cp_iu6_t0_i0_rte_fx1;
   wire                            rn_cp_iu6_t0_i0_rte_axu0;
   wire                            rn_cp_iu6_t0_i0_rte_axu1;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t0_i0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t0_i0_bta;
   wire                            rn_cp_iu6_t0_i0_isram;
   wire [0:31]                     rn_cp_iu6_t0_i0_instr;
   wire                            rn_cp_iu6_t0_i0_valop;
   wire [0:2]                      rn_cp_iu6_t0_i0_error;
   wire                            rn_cp_iu6_t0_i0_br_pred;
   wire                            rn_cp_iu6_t0_i0_bh_update;
   wire [0:1]                      rn_cp_iu6_t0_i0_bh0_hist;
   wire [0:1]                      rn_cp_iu6_t0_i0_bh1_hist;
   wire [0:1]                      rn_cp_iu6_t0_i0_bh2_hist;
   wire [0:17]                      rn_cp_iu6_t0_i0_gshare;
   wire [0:2]                      rn_cp_iu6_t0_i0_ls_ptr;
   wire                            rn_cp_iu6_t0_i0_match;
   wire                            rn_cp_iu6_t0_i0_type_fp;
   wire                            rn_cp_iu6_t0_i0_type_ap;
   wire                            rn_cp_iu6_t0_i0_type_spv;
   wire                            rn_cp_iu6_t0_i0_type_st;
   wire                            rn_cp_iu6_t0_i0_async_block;
   wire                            rn_cp_iu6_t0_i0_np1_flush;
   wire                            rn_cp_iu6_t0_i0_t1_v;
   wire [0:2]                      rn_cp_iu6_t0_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t1_a;
   wire                            rn_cp_iu6_t0_i0_t2_v;
   wire [0:2]                      rn_cp_iu6_t0_i0_t2_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t2_a;
   wire                            rn_cp_iu6_t0_i0_t3_v;
   wire [0:2]                      rn_cp_iu6_t0_i0_t3_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t3_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i0_t3_a;
   wire                            rn_cp_iu6_t0_i0_btb_entry;
   wire [0:1]                      rn_cp_iu6_t0_i0_btb_hist;
   wire                            rn_cp_iu6_t0_i0_bta_val;
   // Instruction 1 Issue
   wire                            rn_cp_iu6_t0_i1_vld;
   wire [0:`ITAG_SIZE_ENC-1]       rn_cp_iu6_t0_i1_itag;
   wire [0:2]                      rn_cp_iu6_t0_i1_ucode;
   wire                            rn_cp_iu6_t0_i1_fuse_nop;
   wire                            rn_cp_iu6_t0_i1_rte_lq;
   wire                            rn_cp_iu6_t0_i1_rte_sq;
   wire                            rn_cp_iu6_t0_i1_rte_fx0;
   wire                            rn_cp_iu6_t0_i1_rte_fx1;
   wire                            rn_cp_iu6_t0_i1_rte_axu0;
   wire                            rn_cp_iu6_t0_i1_rte_axu1;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t0_i1_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t0_i1_bta;
   wire                            rn_cp_iu6_t0_i1_isram;
   wire [0:31]                     rn_cp_iu6_t0_i1_instr;
   wire                            rn_cp_iu6_t0_i1_valop;
   wire [0:2]                      rn_cp_iu6_t0_i1_error;
   wire                            rn_cp_iu6_t0_i1_br_pred;
   wire                            rn_cp_iu6_t0_i1_bh_update;
   wire [0:1]                      rn_cp_iu6_t0_i1_bh0_hist;
   wire [0:1]                      rn_cp_iu6_t0_i1_bh1_hist;
   wire [0:1]                      rn_cp_iu6_t0_i1_bh2_hist;
   wire [0:17]                      rn_cp_iu6_t0_i1_gshare;
   wire [0:2]                      rn_cp_iu6_t0_i1_ls_ptr;
   wire                            rn_cp_iu6_t0_i1_match;
   wire                            rn_cp_iu6_t0_i1_type_fp;
   wire                            rn_cp_iu6_t0_i1_type_ap;
   wire                            rn_cp_iu6_t0_i1_type_spv;
   wire                            rn_cp_iu6_t0_i1_type_st;
   wire                            rn_cp_iu6_t0_i1_async_block;
   wire                            rn_cp_iu6_t0_i1_np1_flush;
   wire                            rn_cp_iu6_t0_i1_t1_v;
   wire [0:2]                      rn_cp_iu6_t0_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t1_a;
   wire                            rn_cp_iu6_t0_i1_t2_v;
   wire [0:2]                      rn_cp_iu6_t0_i1_t2_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t2_a;
   wire                            rn_cp_iu6_t0_i1_t3_v;
   wire [0:2]                      rn_cp_iu6_t0_i1_t3_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t3_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t0_i1_t3_a;
   wire                            rn_cp_iu6_t0_i1_btb_entry;
   wire [0:1]                      rn_cp_iu6_t0_i1_btb_hist;
   wire                            rn_cp_iu6_t0_i1_bta_val;
`ifndef THREADS1
   // Instruction 0 Issue
   wire                            rn_cp_iu6_t1_i0_vld;
   wire [0:`ITAG_SIZE_ENC-1]       rn_cp_iu6_t1_i0_itag;
   wire [0:2]                      rn_cp_iu6_t1_i0_ucode;
   wire                            rn_cp_iu6_t1_i0_fuse_nop;
   wire                            rn_cp_iu6_t1_i0_rte_lq;
   wire                            rn_cp_iu6_t1_i0_rte_sq;
   wire                            rn_cp_iu6_t1_i0_rte_fx0;
   wire                            rn_cp_iu6_t1_i0_rte_fx1;
   wire                            rn_cp_iu6_t1_i0_rte_axu0;
   wire                            rn_cp_iu6_t1_i0_rte_axu1;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t1_i0_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t1_i0_bta;
   wire                            rn_cp_iu6_t1_i0_isram;
   wire [0:31]                     rn_cp_iu6_t1_i0_instr;
   wire                            rn_cp_iu6_t1_i0_valop;
   wire [0:2]                      rn_cp_iu6_t1_i0_error;
   wire                            rn_cp_iu6_t1_i0_br_pred;
   wire                            rn_cp_iu6_t1_i0_bh_update;
   wire [0:1]                      rn_cp_iu6_t1_i0_bh0_hist;
   wire [0:1]                      rn_cp_iu6_t1_i0_bh1_hist;
   wire [0:1]                      rn_cp_iu6_t1_i0_bh2_hist;
   wire [0:17]                      rn_cp_iu6_t1_i0_gshare;
   wire [0:2]                      rn_cp_iu6_t1_i0_ls_ptr;
   wire                            rn_cp_iu6_t1_i0_match;
   wire                            rn_cp_iu6_t1_i0_type_fp;
   wire                            rn_cp_iu6_t1_i0_type_ap;
   wire                            rn_cp_iu6_t1_i0_type_spv;
   wire                            rn_cp_iu6_t1_i0_type_st;
   wire                            rn_cp_iu6_t1_i0_async_block;
   wire                            rn_cp_iu6_t1_i0_np1_flush;
   wire                            rn_cp_iu6_t1_i0_t1_v;
   wire [0:2]                      rn_cp_iu6_t1_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t1_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t1_a;
   wire                            rn_cp_iu6_t1_i0_t2_v;
   wire [0:2]                      rn_cp_iu6_t1_i0_t2_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t2_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t2_a;
   wire                            rn_cp_iu6_t1_i0_t3_v;
   wire [0:2]                      rn_cp_iu6_t1_i0_t3_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t3_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i0_t3_a;
   wire                            rn_cp_iu6_t1_i0_btb_entry;
   wire [0:1]                      rn_cp_iu6_t1_i0_btb_hist;
   wire                            rn_cp_iu6_t1_i0_bta_val;
   // Instruction 1 Issue
   wire                            rn_cp_iu6_t1_i1_vld;
   wire [0:`ITAG_SIZE_ENC-1]       rn_cp_iu6_t1_i1_itag;
   wire [0:2]                      rn_cp_iu6_t1_i1_ucode;
   wire                            rn_cp_iu6_t1_i1_fuse_nop;
   wire                            rn_cp_iu6_t1_i1_rte_lq;
   wire                            rn_cp_iu6_t1_i1_rte_sq;
   wire                            rn_cp_iu6_t1_i1_rte_fx0;
   wire                            rn_cp_iu6_t1_i1_rte_fx1;
   wire                            rn_cp_iu6_t1_i1_rte_axu0;
   wire                            rn_cp_iu6_t1_i1_rte_axu1;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t1_i1_ifar;
   wire [62-`EFF_IFAR_WIDTH:61]    rn_cp_iu6_t1_i1_bta;
   wire                            rn_cp_iu6_t1_i1_isram;
   wire [0:31]                     rn_cp_iu6_t1_i1_instr;
   wire                            rn_cp_iu6_t1_i1_valop;
   wire [0:2]                      rn_cp_iu6_t1_i1_error;
   wire                            rn_cp_iu6_t1_i1_br_pred;
   wire                            rn_cp_iu6_t1_i1_bh_update;
   wire [0:1]                      rn_cp_iu6_t1_i1_bh0_hist;
   wire [0:1]                      rn_cp_iu6_t1_i1_bh1_hist;
   wire [0:1]                      rn_cp_iu6_t1_i1_bh2_hist;
   wire [0:17]                      rn_cp_iu6_t1_i1_gshare;
   wire [0:2]                      rn_cp_iu6_t1_i1_ls_ptr;
   wire                            rn_cp_iu6_t1_i1_match;
   wire                            rn_cp_iu6_t1_i1_type_fp;
   wire                            rn_cp_iu6_t1_i1_type_ap;
   wire                            rn_cp_iu6_t1_i1_type_spv;
   wire                            rn_cp_iu6_t1_i1_type_st;
   wire                            rn_cp_iu6_t1_i1_async_block;
   wire                            rn_cp_iu6_t1_i1_np1_flush;
   wire                            rn_cp_iu6_t1_i1_t1_v;
   wire [0:2]                      rn_cp_iu6_t1_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t1_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t1_a;
   wire                            rn_cp_iu6_t1_i1_t2_v;
   wire [0:2]                      rn_cp_iu6_t1_i1_t2_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t2_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t2_a;
   wire                            rn_cp_iu6_t1_i1_t3_v;
   wire [0:2]                      rn_cp_iu6_t1_i1_t3_t;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t3_p;
   wire [0:`GPR_POOL_ENC-1]        rn_cp_iu6_t1_i1_t3_a;
   wire                            rn_cp_iu6_t1_i1_btb_entry;
   wire [0:1]                      rn_cp_iu6_t1_i1_btb_hist;
   wire                            rn_cp_iu6_t1_i1_bta_val;
`endif
   wire [64-`GPR_WIDTH:51]         spr_ivpr;
   wire [64-`GPR_WIDTH:51]         spr_givpr;
   wire [62-`EFF_IFAR_ARCH:61]     spr_iac1;
   wire [62-`EFF_IFAR_ARCH:61]     spr_iac2;
   wire [62-`EFF_IFAR_ARCH:61]     spr_iac3;
   wire [62-`EFF_IFAR_ARCH:61]     spr_iac4;

   wire [0:`THREADS-1]             spr_cpcr_we;

   wire [0:4]                      spr_t0_cpcr2_fx0_cnt;
   wire [0:4]                      spr_t0_cpcr2_fx1_cnt;
   wire [0:4]                      spr_t0_cpcr2_lq_cnt;
   wire [0:4]                      spr_t0_cpcr2_sq_cnt;
   wire [0:4]                      spr_t0_cpcr3_fu0_cnt;
   wire [0:4]                      spr_t0_cpcr3_fu1_cnt;
   wire [0:6]                      spr_t0_cpcr3_cp_cnt;
   wire [0:4]                      spr_t0_cpcr4_fx0_cnt;
   wire [0:4]                      spr_t0_cpcr4_fx1_cnt;
   wire [0:4]                      spr_t0_cpcr4_lq_cnt;
   wire [0:4]                      spr_t0_cpcr4_sq_cnt;
   wire [0:4]                      spr_t0_cpcr5_fu0_cnt;
   wire [0:4]                      spr_t0_cpcr5_fu1_cnt;
   wire [0:6]                      spr_t0_cpcr5_cp_cnt;
`ifndef THREADS1
   wire [0:4]                      spr_t1_cpcr2_fx0_cnt;
   wire [0:4]                      spr_t1_cpcr2_fx1_cnt;
   wire [0:4]                      spr_t1_cpcr2_lq_cnt;
   wire [0:4]                      spr_t1_cpcr2_sq_cnt;
   wire [0:4]                      spr_t1_cpcr3_fu0_cnt;
   wire [0:4]                      spr_t1_cpcr3_fu1_cnt;
   wire [0:6]                      spr_t1_cpcr3_cp_cnt;
   wire [0:4]                      spr_t1_cpcr4_fx0_cnt;
   wire [0:4]                      spr_t1_cpcr4_fx1_cnt;
   wire [0:4]                      spr_t1_cpcr4_lq_cnt;
   wire [0:4]                      spr_t1_cpcr4_sq_cnt;
   wire [0:4]                      spr_t1_cpcr5_fu0_cnt;
   wire [0:4]                      spr_t1_cpcr5_fu1_cnt;
   wire [0:6]                      spr_t1_cpcr5_cp_cnt;
`endif
   wire [0:4]                      spr_cpcr0_fx0_cnt;
   wire [0:4]                      spr_cpcr0_fx1_cnt;
   wire [0:4]                      spr_cpcr0_lq_cnt;
   wire [0:4]                      spr_cpcr0_sq_cnt;
   wire [0:4]                      spr_cpcr1_fu0_cnt;
   wire [0:4]                      spr_cpcr1_fu1_cnt;

   wire [0:`THREADS-1]             spr_high_pri_mask;
   wire [0:`THREADS-1]             spr_med_pri_mask;
   wire [0:5]                      spr_t0_low_pri_count;
`ifndef THREADS1
   wire [0:5]                      spr_t1_low_pri_count;
`endif

   wire [0:`THREADS-1]             cp_rn_uc_credit_free;
   wire [0:`THREADS-1]             dp_cp_hold_req;
   wire [0:`THREADS-1]             dp_cp_bus_snoop_hold_req;

   wire [0:`THREADS-1]             iu_spr_eheir_update;
   wire [0:31]                     iu_spr_t0_eheir;
`ifndef THREADS1
   wire [0:31]                     iu_spr_t1_eheir;
`endif

   // axu
   wire [0:7]                      iu_au_t0_config_iucr;
`ifndef THREADS1
   wire [0:7]                      iu_au_t1_config_iucr;
`endif

   wire [0:`THREADS-1]             ib_uc_rdy;
   wire [0:3]                      uc_ib_iu3_t0_invalid;
   wire [0:1]                      uc_ib_t0_val;
   wire [0:`THREADS-1]             uc_ib_done;
   wire [0:`THREADS-1]             uc_ib_iu3_flush_all;
   wire [0:31]                     uc_ib_t0_instr0;
   wire [0:31]                     uc_ib_t0_instr1;
   wire [62-`EFF_IFAR_WIDTH:61]    uc_ib_t0_ifar0;
   wire [62-`EFF_IFAR_WIDTH:61]    uc_ib_t0_ifar1;
   wire [0:3]                      uc_ib_t0_ext0;		//RT, S1, S2, S3
   wire [0:3]                      uc_ib_t0_ext1;		//RT, S1, S2, S3
`ifndef THREADS1
   wire [0:3]                      uc_ib_iu3_t1_invalid;
   wire [0:1]                      uc_ib_t1_val;
   wire [0:31]                     uc_ib_t1_instr0;
   wire [0:31]                     uc_ib_t1_instr1;
   wire [62-`EFF_IFAR_WIDTH:61]    uc_ib_t1_ifar0;
   wire [62-`EFF_IFAR_WIDTH:61]    uc_ib_t1_ifar1;
   wire [0:3]                      uc_ib_t1_ext0;		//RT, S1, S2, S3
   wire [0:3]                      uc_ib_t1_ext1;		//RT, S1, S2, S3
`endif

   wire                           iu_pc_ram_done_int;
   wire [0:`THREADS-1]             ib_rm_rdy;
   wire [0:`THREADS-1]             rm_ib_iu3_val;
   wire [0:35]                    rm_ib_iu3_instr;

   wire [0:`THREADS-1]           cp_flush_internal;
   wire [0:`THREADS-1]           iu_xu_stop_internal;
   wire [62-`EFF_IFAR_ARCH:61]   cp_t0_flush_ifar_internal;
`ifndef THREADS1
   wire [62-`EFF_IFAR_ARCH:61]   cp_t1_flush_ifar_internal;
`endif
   wire [0:`THREADS-1]           iu_mm_bus_snoop_hold_ack_int;

   wire [0:`THREADS-1]           cp_flush_into_uc;
   wire [43:61]                  cp_uc_t0_flush_ifar;
`ifndef THREADS1
   wire [43:61]                  cp_uc_t1_flush_ifar;
`endif
   wire [0:`THREADS-1]           cp_uc_np1_flush;

   wire                           g8t_clkoff_b;
   wire                           g8t_d_mode;
   wire [0:4]                     g8t_delay_lclkr;
   wire [0:4]                     g8t_mpw1_b;
   wire                           g8t_mpw2_b;
   wire                           g6t_clkoff_b;
   wire                           g6t_act_dis;
   wire                           g6t_d_mode;
   wire [0:3]                     g6t_delay_lclkr;
   wire [0:4]                     g6t_mpw1_b;
   wire                           g6t_mpw2_b;
   wire                           cam_clkoff_b;
   wire                           cam_act_dis;
   wire                           cam_d_mode;
   wire [0:4]                     cam_delay_lclkr;
   wire [0:4]                     cam_mpw1_b;
   wire                           cam_mpw2_b;
   wire [0:`THREADS-1]            mm_iu_reload_hit;

   wire [0:31]                    ifetch_debug_bus_out;
   wire [0:3]                     ifetch_coretrace_ctrls_out;

   //-------------------------------
   // Slice performance interface with I$
   //-------------------------------
   wire [0:20]                    slice_ic_t0_perf_events;
`ifndef THREADS1
   wire [0:20]                    slice_ic_t1_perf_events;
`endif

   wire [0:31]                    spr_cp_perf_event_mux_ctrls;

   wire                           tidn;
   wire                           tiup;

   //need to remove only here for the facs
   wire [0:`THREADS-1]             cp_ib_iu4_hold;

   wire [0:`ITAG_SIZE_ENC-1]             iu_lq_t0_i0_completed_itag_int;
   wire [0:`ITAG_SIZE_ENC-1]             iu_lq_t0_i1_completed_itag_int;
`ifndef THREADS1
   wire [0:`ITAG_SIZE_ENC-1]             iu_lq_t1_i0_completed_itag_int;
   wire [0:`ITAG_SIZE_ENC-1]             iu_lq_t1_i1_completed_itag_int;
`endif

   wire                           pc_iu_func_slp_sl_thold_2;
   wire                           pc_iu_func_nsl_thold_2;
   wire                           pc_iu_cfg_slp_sl_thold_2;
   wire                           pc_iu_regf_slp_sl_thold_2;
   wire                           pc_iu_func_sl_thold_2;
   wire                           pc_iu_time_sl_thold_2;
   wire                           pc_iu_abst_sl_thold_2;
   wire                           pc_iu_abst_slp_sl_thold_2;
   wire                           pc_iu_repr_sl_thold_2;
   wire                           pc_iu_ary_nsl_thold_2;
   wire                           pc_iu_ary_slp_nsl_thold_2;
   wire                           pc_iu_func_slp_nsl_thold_2;
   wire                           pc_iu_bolt_sl_thold_2;
   wire                           pc_iu_sg_2;
   wire                           pc_iu_fce_2;

   wire [0:4*`THREADS-1]          event_bus_in[0:1];
   wire [0:4*`THREADS-1]          event_bus_out[0:1];

   wire                           vdd;
   wire                           gnd;

   assign vdd = 1'b1;
   assign gnd = 1'b0;

   // Temp should be driven by external mode debug compare decodes
   assign mm_iu_reload_hit[0] = mm_iu_ierat_rel_val[0] & mm_iu_ierat_rel_val[4];
`ifndef THREADS1
   assign mm_iu_reload_hit[1] = mm_iu_ierat_rel_val[1] & mm_iu_ierat_rel_val[4];
`endif

   assign cp_flush = cp_flush_internal;
   assign iu_xu_stop = iu_xu_stop_internal;
   assign cp_t0_flush_ifar = cp_t0_flush_ifar_internal;
`ifndef THREADS1
   assign cp_t1_flush_ifar = cp_t1_flush_ifar_internal;
`endif
   assign iu_mm_bus_snoop_hold_ack = iu_mm_bus_snoop_hold_ack_int;

   assign tidn = 1'b0;
   assign tiup = 1'b1;

   assign cp_ib_iu4_hold = {`THREADS{1'b0}};

   assign cp_is_isync = cp_ic_is_isync;
   assign cp_is_csync = cp_ic_is_csync;

   assign iu_lq_t0_i0_completed_itag = iu_lq_t0_i0_completed_itag_int;
   assign iu_lq_t0_i1_completed_itag = iu_lq_t0_i1_completed_itag_int;
`ifndef THREADS1
   assign iu_lq_t1_i0_completed_itag = iu_lq_t1_i0_completed_itag_int;
   assign iu_lq_t1_i1_completed_itag = iu_lq_t1_i1_completed_itag_int;
`endif

   assign event_bus_in[0]  = iu_event_bus_in;
   assign iu_event_bus_out = event_bus_out[1];
   assign event_bus_in[1]  = event_bus_out[0];


   iuq_btb iuq_btb0(
//    tri_btb_64x64_1r1w iuq_btb0(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_fce_2(pc_iu_fce_2),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(btb_scan_in),
      .scan_out(btb_scan_out),
      .r_act(iu0_btb_rd_act),
      .w_act(ex5_btb_wr_act),
      .r_addr(iu0_btb_rd_addr),
      .w_addr(ex5_btb_wr_addr),
      .data_in(ex5_btb_wr_data[0:42]),
      .data_out(iu2_btb_rd_data[0:42]),
      .pc_iu_init_reset(pc_iu_init_reset)
   );


   iuq_ifetch iuq_ifetch0(
      //.vcs(vdd),
      //.vdd(vdd),
      //.gnd(gnd),
      .nclk(nclk),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .tc_ac_scan_diag_dc(tc_ac_scan_diag_dc),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .pc_iu_func_nsl_thold_2(pc_iu_func_nsl_thold_2),
      .pc_iu_cfg_slp_sl_thold_2(pc_iu_cfg_slp_sl_thold_2),
      .pc_iu_regf_slp_sl_thold_2(pc_iu_regf_slp_sl_thold_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_abst_sl_thold_2(pc_iu_abst_sl_thold_2),
      .pc_iu_abst_slp_sl_thold_2(pc_iu_abst_slp_sl_thold_2),
      .pc_iu_repr_sl_thold_2(pc_iu_repr_sl_thold_2),
      .pc_iu_ary_nsl_thold_2(pc_iu_ary_nsl_thold_2),
      .pc_iu_ary_slp_nsl_thold_2(pc_iu_ary_slp_nsl_thold_2),
      .pc_iu_func_slp_nsl_thold_2(pc_iu_func_slp_nsl_thold_2),
      .pc_iu_bolt_sl_thold_2(pc_iu_bolt_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_fce_2(pc_iu_fce_2),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .g8t_clkoff_b(g8t_clkoff_b),
      .g8t_d_mode(g8t_d_mode),
      .g8t_delay_lclkr(g8t_delay_lclkr),
      .g8t_mpw1_b(g8t_mpw1_b),
      .g8t_mpw2_b(g8t_mpw2_b),
      .g6t_clkoff_b(g6t_clkoff_b),
      .g6t_act_dis(g6t_act_dis),
      .g6t_d_mode(g6t_d_mode),
      .g6t_delay_lclkr(g6t_delay_lclkr),
      .g6t_mpw1_b(g6t_mpw1_b),
      .g6t_mpw2_b(g6t_mpw2_b),
      .cam_clkoff_b(cam_clkoff_b),
      .cam_act_dis(cam_act_dis),
      .cam_d_mode(cam_d_mode),
      .cam_delay_lclkr(cam_delay_lclkr),
      .cam_mpw1_b(cam_mpw1_b),
      .cam_mpw2_b(cam_mpw2_b),
      .func_scan_in(func_scan_in),
      .func_scan_out(func_scan_out),
      .ac_ccfg_scan_in(ac_ccfg_scan_in),
      .ac_ccfg_scan_out(ac_ccfg_scan_out),
      .time_scan_in(time_scan_in),
      .time_scan_out(time_scan_out),
      .repr_scan_in(repr_scan_in),
      .repr_scan_out(repr_scan_out),
      .abst_scan_in(abst_scan_in),
      .abst_scan_out(abst_scan_out),
      .regf_scan_in(regf_scan_in),
      .regf_scan_out(regf_scan_out),
      .iu_pc_err_icache_parity(iu_pc_err_icache_parity),
      .iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
      .iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
      .iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
      .iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),
      .pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
      .pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
      .pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
      .pc_iu_abist_g8t_wenb(pc_iu_abist_g8t_wenb),
      .pc_iu_abist_g8t1p_renb_0(pc_iu_abist_g8t1p_renb_0),
      .pc_iu_abist_di_0(pc_iu_abist_di_0),
      .pc_iu_abist_g8t_bw_1(pc_iu_abist_g8t_bw_1),
      .pc_iu_abist_g8t_bw_0(pc_iu_abist_g8t_bw_0),
      .pc_iu_abist_waddr_0(pc_iu_abist_waddr_0),
      .pc_iu_abist_raddr_0(pc_iu_abist_raddr_0),
      .pc_iu_abist_ena_dc(pc_iu_abist_ena_dc),
      .pc_iu_abist_wl128_comp_ena(pc_iu_abist_wl128_comp_ena),
      .pc_iu_abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .pc_iu_abist_g8t_dcomp(pc_iu_abist_g8t_dcomp),
      .pc_iu_abist_g6t_bw(pc_iu_abist_g6t_bw),
      .pc_iu_abist_di_g6t_2r(pc_iu_abist_di_g6t_2r),
      .pc_iu_abist_wl512_comp_ena(pc_iu_abist_wl512_comp_ena),
      .pc_iu_abist_dcomp_g6t_2r(pc_iu_abist_dcomp_g6t_2r),
      .pc_iu_abist_g6t_r_wb(pc_iu_abist_g6t_r_wb),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
      .an_ac_atpg_en_dc(an_ac_atpg_en_dc),
      .an_ac_grffence_en_dc(an_ac_grffence_en_dc),
      .pc_iu_bo_enable_3(pc_iu_bo_enable_3),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select[0:3]),
      .iu_pc_bo_fail(iu_pc_bo_fail[0:3]),
      .iu_pc_bo_diagout(iu_pc_bo_diagout[0:3]),
      .lq_iu_icbi_val(lq_iu_icbi_val),
      .lq_iu_icbi_addr(lq_iu_icbi_addr),
      .iu_lq_icbi_complete(iu_lq_icbi_complete),
      .lq_iu_ici_val(lq_iu_ici_val),
      .iu_lq_spr_iucr0_icbi_ack(iu_lq_spr_iucr0_icbi_ack),
      .pc_iu_init_reset(pc_iu_init_reset),
      .xu_iu_val(xu_iu_val),
      .xu_iu_is_eratre(xu_iu_is_eratre),
      .xu_iu_is_eratwe(xu_iu_is_eratwe),
      .xu_iu_is_eratsx(xu_iu_is_eratsx),
      .xu_iu_is_eratilx(xu_iu_is_eratilx),
      .cp_is_isync(cp_ic_is_isync),
      .cp_is_csync(cp_ic_is_csync),
      .xu_iu_ws(xu_iu_ws),
      .xu_iu_ra_entry(xu_iu_ra_entry),
      .xu_iu_rb(xu_iu_rb),
      .xu_iu_rs_data(xu_iu_rs_data),
      .iu_xu_ord_read_done(iu_xu_ord_read_done),
      .iu_xu_ord_write_done(iu_xu_ord_write_done),
      .iu_xu_ord_par_err(iu_xu_ord_par_err),
      .iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),
      .xu_iu_msr_gs(xu_iu_msr_gs),
      .xu_iu_msr_pr(xu_iu_msr_pr),
      .xu_iu_msr_is(xu_iu_msr_is),
      .xu_iu_hid_mmu_mode(xu_iu_hid_mmu_mode),
      .xu_iu_spr_ccr2_ifrat(xu_iu_spr_ccr2_ifrat),
      .xu_iu_spr_ccr2_ifratsc(xu_iu_spr_ccr2_ifratsc),
      .xu_iu_xucr4_mmu_mchk(xu_iu_xucr4_mmu_mchk),
      .iu_xu_ex5_data(iu_xu_ex5_data),
      .iu_mm_ierat_req(iu_mm_ierat_req),
      .iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
      .iu_mm_ierat_epn(iu_mm_ierat_epn),
      .iu_mm_ierat_thdid(iu_mm_ierat_thdid),
      .iu_mm_ierat_state(iu_mm_ierat_state),
      .iu_mm_ierat_tid(iu_mm_ierat_tid),
      .iu_mm_ierat_flush(iu_mm_ierat_flush),
      .iu_mm_perf_itlb(iu_mm_perf_itlb),
      .mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
      .mm_iu_ierat_rel_data(mm_iu_ierat_rel_data),
      .mm_iu_t0_ierat_pid(mm_iu_t0_ierat_pid),
      .mm_iu_t0_ierat_mmucr0(mm_iu_t0_ierat_mmucr0),
`ifndef THREADS1
      .mm_iu_t1_ierat_pid(mm_iu_t1_ierat_pid),
      .mm_iu_t1_ierat_mmucr0(mm_iu_t1_ierat_mmucr0),
`endif
      .iu_mm_ierat_mmucr0(iu_mm_ierat_mmucr0),
      .iu_mm_ierat_mmucr0_we(iu_mm_ierat_mmucr0_we),
      .mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1),
      .iu_mm_ierat_mmucr1(iu_mm_ierat_mmucr1),
      .iu_mm_ierat_mmucr1_we(iu_mm_ierat_mmucr1_we),
      .mm_iu_ierat_snoop_coming(mm_iu_ierat_snoop_coming),
      .mm_iu_ierat_snoop_val(mm_iu_ierat_snoop_val),
      .mm_iu_ierat_snoop_attr(mm_iu_ierat_snoop_attr),
      .mm_iu_ierat_snoop_vpn(mm_iu_ierat_snoop_vpn),
      .iu_mm_ierat_snoop_ack(iu_mm_ierat_snoop_ack),
      .mm_iu_hold_req(mm_iu_hold_req),
      .mm_iu_hold_done(mm_iu_hold_done),
      .mm_iu_bus_snoop_hold_req(iu_mm_bus_snoop_hold_ack_int),
      .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
      .pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
      .xu_iu_run_thread(xu_iu_run_thread),
      .cp_ic_stop(iu_xu_stop_internal),
      .xu_iu_msr_cm(xu_iu_msr_cm),
      .iu_flush(iu_flush),
      .br_iu_redirect(br_iu_redirect),
      .br_iu_bta(br_iu_bta),
      .cp_flush_into_uc(cp_flush_into_uc),
      .cp_uc_t0_flush_ifar(cp_uc_t0_flush_ifar),
`ifndef THREADS1
      .cp_uc_t1_flush_ifar(cp_uc_t1_flush_ifar),
`endif
      .cp_uc_np1_flush(cp_uc_np1_flush),
      .cp_uc_credit_free(cp_rn_uc_credit_free),
      .cp_flush(cp_flush_internal),
      .cp_iu0_t0_flush_ifar(cp_t0_flush_ifar_internal),
`ifndef THREADS1
      .cp_iu0_t1_flush_ifar(cp_t1_flush_ifar_internal),
`endif
      .cp_iu0_flush_2ucode(cp_iu0_flush_2ucode),
      .cp_iu0_flush_2ucode_type(cp_iu0_flush_2ucode_type),
      .cp_iu0_flush_nonspec(cp_iu0_flush_nonspec),
      .ic_cp_nonspec_hit(ic_cp_nonspec_hit),
      .an_ac_back_inv(an_ac_back_inv),
      .an_ac_back_inv_addr(an_ac_back_inv_addr),
      .an_ac_back_inv_target(an_ac_back_inv_target),
      .iu_lq_request(iu_lq_request),
      .iu_lq_ctag(iu_lq_ctag),
      .iu_lq_ra(iu_lq_ra),
      .iu_lq_wimge(iu_lq_wimge),
      .iu_lq_userdef(iu_lq_userdef),
      .an_ac_reld_data_vld(an_ac_reld_data_vld),
      .an_ac_reld_core_tag(an_ac_reld_core_tag),
      .an_ac_reld_qw(an_ac_reld_qw),
      .an_ac_reld_data(an_ac_reld_data),
      .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
      .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
      .ib_ic_t0_need_fetch(ib_ic_t0_need_fetch),
`ifndef THREADS1
      .ib_ic_t1_need_fetch(ib_ic_t1_need_fetch),
`endif
      .cp_async_block(cp_async_block),
      .iu_mm_lmq_empty(iu_mm_lmq_empty),
      .iu_xu_icache_quiesce(iu_xu_icache_quiesce),
      .iu_pc_icache_quiesce(iu_pc_icache_quiesce),
      .iu2_0_bh0_rd_data(iu2_0_bh0_rd_data),
      .iu2_1_bh0_rd_data(iu2_1_bh0_rd_data),
      .iu2_2_bh0_rd_data(iu2_2_bh0_rd_data),
      .iu2_3_bh0_rd_data(iu2_3_bh0_rd_data),
      .iu2_0_bh1_rd_data(iu2_0_bh1_rd_data),
      .iu2_1_bh1_rd_data(iu2_1_bh1_rd_data),
      .iu2_2_bh1_rd_data(iu2_2_bh1_rd_data),
      .iu2_3_bh1_rd_data(iu2_3_bh1_rd_data),
      .iu2_0_bh2_rd_data(iu2_0_bh2_rd_data),
      .iu2_1_bh2_rd_data(iu2_1_bh2_rd_data),
      .iu2_2_bh2_rd_data(iu2_2_bh2_rd_data),
      .iu2_3_bh2_rd_data(iu2_3_bh2_rd_data),
      .iu0_bh0_rd_addr(iu0_bh0_rd_addr),
      .iu0_bh1_rd_addr(iu0_bh1_rd_addr),
      .iu0_bh2_rd_addr(iu0_bh2_rd_addr),
      .iu0_bh0_rd_act(iu0_bh0_rd_act),
      .iu0_bh1_rd_act(iu0_bh1_rd_act),
      .iu0_bh2_rd_act(iu0_bh2_rd_act),
      .ex5_bh0_wr_data(ex5_bh0_wr_data),
      .ex5_bh1_wr_data(ex5_bh1_wr_data),
      .ex5_bh2_wr_data(ex5_bh2_wr_data),
      .ex5_bh0_wr_addr(ex5_bh0_wr_addr),
      .ex5_bh1_wr_addr(ex5_bh1_wr_addr),
      .ex5_bh2_wr_addr(ex5_bh2_wr_addr),
      .ex5_bh0_wr_act(ex5_bh0_wr_act),
      .ex5_bh1_wr_act(ex5_bh1_wr_act),
      .ex5_bh2_wr_act(ex5_bh2_wr_act),
      .iu0_btb_rd_addr(iu0_btb_rd_addr),
      .iu0_btb_rd_act(iu0_btb_rd_act),
      .iu2_btb_rd_data(iu2_btb_rd_data),
      .ex5_btb_wr_addr(ex5_btb_wr_addr),
      .ex5_btb_wr_act(ex5_btb_wr_act),
      .ex5_btb_wr_data(ex5_btb_wr_data),
      .bp_ib_iu3_t0_val(bp_ib_iu3_t0_val),
      .bp_ib_iu3_t0_ifar(bp_ib_iu3_t0_ifar),
      .bp_ib_iu3_t0_bta(bp_ib_iu3_t0_bta),
      .bp_ib_iu3_t0_0_instr(bp_ib_iu3_t0_0_instr),
      .bp_ib_iu3_t0_1_instr(bp_ib_iu3_t0_1_instr),
      .bp_ib_iu3_t0_2_instr(bp_ib_iu3_t0_2_instr),
      .bp_ib_iu3_t0_3_instr(bp_ib_iu3_t0_3_instr),
`ifndef THREADS1
      .bp_ib_iu3_t1_val(bp_ib_iu3_t1_val),
      .bp_ib_iu3_t1_ifar(bp_ib_iu3_t1_ifar),
      .bp_ib_iu3_t1_bta(bp_ib_iu3_t1_bta),
      .bp_ib_iu3_t1_0_instr(bp_ib_iu3_t1_0_instr),
      .bp_ib_iu3_t1_1_instr(bp_ib_iu3_t1_1_instr),
      .bp_ib_iu3_t1_2_instr(bp_ib_iu3_t1_2_instr),
      .bp_ib_iu3_t1_3_instr(bp_ib_iu3_t1_3_instr),
`endif
      .cp_bp_val(cp_bp_val),
      .cp_bp_t0_ifar(cp_bp_t0_ifar),
      .cp_bp_t0_bh0_hist(cp_bp_t0_bh0_hist),
      .cp_bp_t0_bh1_hist(cp_bp_t0_bh1_hist),
      .cp_bp_t0_bh2_hist(cp_bp_t0_bh2_hist),
`ifndef THREADS1
      .cp_bp_t1_ifar(cp_bp_t1_ifar),
      .cp_bp_t1_bh0_hist(cp_bp_t1_bh0_hist),
      .cp_bp_t1_bh1_hist(cp_bp_t1_bh1_hist),
      .cp_bp_t1_bh2_hist(cp_bp_t1_bh2_hist),
`endif
      .cp_bp_br_pred(cp_bp_br_pred),
      .cp_bp_br_taken(cp_bp_br_taken),
      .cp_bp_bh_update(cp_bp_bh_update),
      .cp_bp_bcctr(cp_bp_bcctr),
      .cp_bp_bclr(cp_bp_bclr),
      .cp_bp_getNIA(cp_bp_getNIA),
      .cp_bp_group(cp_bp_group),
      .cp_bp_lk(cp_bp_lk),
      .cp_bp_t0_bh(cp_bp_t0_bh),
      .cp_bp_t0_bta(cp_bp_t0_ctr),
      .cp_bp_t0_gshare(cp_bp_t0_gshare),
      .cp_bp_t0_ls_ptr(cp_bp_t0_ls_ptr),
      .cp_bp_t0_btb_hist(cp_bp_t0_btb_hist),
`ifndef THREADS1
      .cp_bp_t1_bh(cp_bp_t1_bh),
      .cp_bp_t1_bta(cp_bp_t1_ctr),
      .cp_bp_t1_gshare(cp_bp_t1_gshare),
      .cp_bp_t1_ls_ptr(cp_bp_t1_ls_ptr),
      .cp_bp_t1_btb_hist(cp_bp_t1_btb_hist),
`endif
      .cp_bp_btb_entry(cp_bp_btb_entry),
      .br_iu_gshare(br_iu_gshare),
      .br_iu_ls_ptr(br_iu_ls_ptr),
      .br_iu_ls_data(br_iu_ls_data),
      .br_iu_ls_update(br_iu_ls_update),
      .xu_iu_msr_de(xu_iu_msr_de),
      .xu_iu_dbcr0_icmp(xu_iu_dbcr0_icmp),
      .xu_iu_dbcr0_brt(xu_iu_dbcr0_brt),
      .xu_iu_iac1_en(xu_iu_iac1_en),
      .xu_iu_iac2_en(xu_iu_iac2_en),
      .xu_iu_iac3_en(xu_iu_iac3_en),
      .xu_iu_iac4_en(xu_iu_iac4_en),
      .lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
      .xu_iu_single_instr_mode(xu_iu_single_instr_mode),
      .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri),
      .bp_scan_in(bp_scan_in),
      .bp_scan_out(bp_scan_out),
      .pc_iu_ram_instr(pc_iu_ram_instr),
      .pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
      .pc_iu_ram_issue(pc_iu_ram_issue),
      .pc_iu_ram_active(pc_iu_ram_active),
      .iu_pc_ram_done(iu_pc_ram_done_int),
      .ib_rm_rdy(ib_rm_rdy),
      .rm_ib_iu3_val(rm_ib_iu3_val),
      .rm_ib_iu3_instr(rm_ib_iu3_instr),
      .ram_scan_in(ram_scan_in),
      .ram_scan_out(ram_scan_out),
      .uc_scan_in(uc_scan_in),
      .uc_scan_out(uc_scan_out),
      .iu_pc_err_ucode_illegal(iu_pc_err_ucode_illegal),
      .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
      .xu_iu_ucode_xer(xu_iu_ucode_xer),
      .ib_uc_rdy(ib_uc_rdy),
      .uc_ib_iu3_t0_invalid(uc_ib_iu3_t0_invalid),
      .uc_ib_t0_val(uc_ib_t0_val),
`ifndef THREADS1
      .uc_ib_iu3_t1_invalid(uc_ib_iu3_t1_invalid),
      .uc_ib_t1_val(uc_ib_t1_val),
`endif
      .uc_ib_done(uc_ib_done),
      .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all),
      .uc_ib_t0_instr0(uc_ib_t0_instr0),
      .uc_ib_t0_instr1(uc_ib_t0_instr1),
      .uc_ib_t0_ifar0(uc_ib_t0_ifar0),
      .uc_ib_t0_ifar1(uc_ib_t0_ifar1),
      .uc_ib_t0_ext0(uc_ib_t0_ext0),
      .uc_ib_t0_ext1(uc_ib_t0_ext1),
`ifndef THREADS1
      .uc_ib_t1_instr0(uc_ib_t1_instr0),
      .uc_ib_t1_instr1(uc_ib_t1_instr1),
      .uc_ib_t1_ifar0(uc_ib_t1_ifar0),
      .uc_ib_t1_ifar1(uc_ib_t1_ifar1),
      .uc_ib_t1_ext0(uc_ib_t1_ext0),
      .uc_ib_t1_ext1(uc_ib_t1_ext1),
`endif
      .iu_slowspr_val_in(iu_slowspr_val_in),
      .iu_slowspr_rw_in(iu_slowspr_rw_in),
      .iu_slowspr_etid_in(iu_slowspr_etid_in),
      .iu_slowspr_addr_in(iu_slowspr_addr_in),
      .iu_slowspr_data_in(iu_slowspr_data_in),
      .iu_slowspr_done_in(iu_slowspr_done_in),
      .iu_slowspr_val_out(iu_slowspr_val_out),
      .iu_slowspr_rw_out(iu_slowspr_rw_out),
      .iu_slowspr_etid_out(iu_slowspr_etid_out),
      .iu_slowspr_addr_out(iu_slowspr_addr_out),
      .iu_slowspr_data_out(iu_slowspr_data_out),
      .iu_slowspr_done_out(iu_slowspr_done_out),
      .spr_dec_mask(spr_dec_mask),
      .spr_dec_match(spr_dec_match),
      .spr_single_issue(spr_single_issue),
      .iu_au_t0_config_iucr(iu_au_t0_config_iucr),
`ifndef THREADS1
      .iu_au_t1_config_iucr(iu_au_t1_config_iucr),
`endif
      .xu_iu_pri_val(xu_iu_pri_val),
      .xu_iu_pri(xu_iu_pri),
      .spr_cp_perf_event_mux_ctrls(spr_cp_perf_event_mux_ctrls),
      .slice_ic_t0_perf_events(slice_ic_t0_perf_events),
`ifndef THREADS1
      .slice_ic_t1_perf_events(slice_ic_t1_perf_events),
`endif
      .spr_ivpr(spr_ivpr),
      .spr_givpr(spr_givpr),
      .spr_iac1(spr_iac1),
      .spr_iac2(spr_iac2),
      .spr_iac3(spr_iac3),
      .spr_iac4(spr_iac4),
      .spr_cpcr_we(spr_cpcr_we),
      .spr_t0_cpcr2_fx0_cnt(spr_t0_cpcr2_fx0_cnt),
      .spr_t0_cpcr2_fx1_cnt(spr_t0_cpcr2_fx1_cnt),
      .spr_t0_cpcr2_lq_cnt(spr_t0_cpcr2_lq_cnt),
      .spr_t0_cpcr2_sq_cnt(spr_t0_cpcr2_sq_cnt),
      .spr_t0_cpcr3_fu0_cnt(spr_t0_cpcr3_fu0_cnt),
      .spr_t0_cpcr3_fu1_cnt(spr_t0_cpcr3_fu1_cnt),
      .spr_t0_cpcr3_cp_cnt(spr_t0_cpcr3_cp_cnt),
      .spr_t0_cpcr4_fx0_cnt(spr_t0_cpcr4_fx0_cnt),
      .spr_t0_cpcr4_fx1_cnt(spr_t0_cpcr4_fx1_cnt),
      .spr_t0_cpcr4_lq_cnt(spr_t0_cpcr4_lq_cnt),
      .spr_t0_cpcr4_sq_cnt(spr_t0_cpcr4_sq_cnt),
      .spr_t0_cpcr5_fu0_cnt(spr_t0_cpcr5_fu0_cnt),
      .spr_t0_cpcr5_fu1_cnt(spr_t0_cpcr5_fu1_cnt),
      .spr_t0_cpcr5_cp_cnt(spr_t0_cpcr5_cp_cnt),
`ifndef THREADS1
      .spr_t1_cpcr2_fx0_cnt(spr_t1_cpcr2_fx0_cnt),
      .spr_t1_cpcr2_fx1_cnt(spr_t1_cpcr2_fx1_cnt),
      .spr_t1_cpcr2_lq_cnt(spr_t1_cpcr2_lq_cnt),
      .spr_t1_cpcr2_sq_cnt(spr_t1_cpcr2_sq_cnt),
      .spr_t1_cpcr3_fu0_cnt(spr_t1_cpcr3_fu0_cnt),
      .spr_t1_cpcr3_fu1_cnt(spr_t1_cpcr3_fu1_cnt),
      .spr_t1_cpcr3_cp_cnt(spr_t1_cpcr3_cp_cnt),
      .spr_t1_cpcr4_fx0_cnt(spr_t1_cpcr4_fx0_cnt),
      .spr_t1_cpcr4_fx1_cnt(spr_t1_cpcr4_fx1_cnt),
      .spr_t1_cpcr4_lq_cnt(spr_t1_cpcr4_lq_cnt),
      .spr_t1_cpcr4_sq_cnt(spr_t1_cpcr4_sq_cnt),
      .spr_t1_cpcr5_fu0_cnt(spr_t1_cpcr5_fu0_cnt),
      .spr_t1_cpcr5_fu1_cnt(spr_t1_cpcr5_fu1_cnt),
      .spr_t1_cpcr5_cp_cnt(spr_t1_cpcr5_cp_cnt),
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
      .iu_spr_eheir_update(iu_spr_eheir_update),
      .iu_spr_t0_eheir(iu_spr_t0_eheir),
`ifndef THREADS1
      .iu_spr_t1_eheir(iu_spr_t1_eheir),
`endif
      .spr_scan_in(scan_in),
      .spr_scan_out(scan_out),
      .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
      .pc_iu_event_count_mode(pc_iu_event_count_mode),
      .event_bus_in(event_bus_in[0]),
      .event_bus_out(event_bus_out[0]),
      .dbg1_scan_in(dbg1_scan_in),
      .dbg1_scan_out(dbg1_scan_out),
      .pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
      .pc_iu_debug_mux1_ctrls(pc_iu_debug_mux1_ctrls),
      .debug_bus_in(debug_bus_in),
      .debug_bus_out(ifetch_debug_bus_out),
      .coretrace_ctrls_in(coretrace_ctrls_in),
      .coretrace_ctrls_out(ifetch_coretrace_ctrls_out)
   );

//   iuq_bht bht0(
   tri_bht_1024x8_1r1w bht0(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_abst_sl_thold_2(pc_iu_abst_sl_thold_2),
      .pc_iu_ary_nsl_thold_2(pc_iu_ary_nsl_thold_2),
      .pc_iu_repr_sl_thold_2(pc_iu_repr_sl_thold_2),
      .pc_iu_bolt_sl_thold_2(pc_iu_bolt_sl_thold_2),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .clkoff_b(clkoff_b),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .act_dis(act_dis),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .g8t_clkoff_b(g8t_clkoff_b),
      .g8t_d_mode(g8t_d_mode),
      .g8t_delay_lclkr(g8t_delay_lclkr),
      .g8t_mpw1_b(g8t_mpw1_b),
      .g8t_mpw2_b(g8t_mpw2_b),
      .func_scan_in(bh0_scan_in),
      .time_scan_in(1'b0),
      .abst_scan_in(1'b0),
      .repr_scan_in(1'b0),
      .func_scan_out(bh0_scan_out),
      .time_scan_out(),
      .abst_scan_out(),
      .repr_scan_out(),
      .pc_iu_abist_di_0(pc_iu_abist_di_0),
      .pc_iu_abist_g8t_bw_1(pc_iu_abist_g8t_bw_1),
      .pc_iu_abist_g8t_bw_0(pc_iu_abist_g8t_bw_0),
      .pc_iu_abist_waddr_0(pc_iu_abist_waddr_0),
      .pc_iu_abist_g8t_wenb(pc_iu_abist_g8t_wenb),
      .pc_iu_abist_raddr_0(pc_iu_abist_raddr_0[3:9]),
      .pc_iu_abist_g8t1p_renb_0(pc_iu_abist_g8t1p_renb_0),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .pc_iu_abist_ena_dc(pc_iu_abist_ena_dc),
      .pc_iu_abist_wl128_comp_ena(pc_iu_abist_wl128_comp_ena),
      .pc_iu_abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .pc_iu_abist_g8t_dcomp(pc_iu_abist_g8t_dcomp),
      .pc_iu_bo_enable_2(pc_iu_bo_enable_3),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select[0]),
      .iu_pc_bo_fail(),
      .iu_pc_bo_diagout(),
      .r_act(iu0_bh0_rd_act),
      .w_act(ex5_bh0_wr_act),
      .r_addr(iu0_bh0_rd_addr[0:9]),
      .w_addr(ex5_bh0_wr_addr[0:9]),
      .data_in(ex5_bh0_wr_data),
      .data_out0(iu2_0_bh0_rd_data),
      .data_out1(iu2_1_bh0_rd_data),
      .data_out2(iu2_2_bh0_rd_data),
      .data_out3(iu2_3_bh0_rd_data),
      .pc_iu_init_reset(pc_iu_init_reset)
   );


//   iuq_bht bht1(
   tri_bht_1024x8_1r1w bht1(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_abst_sl_thold_2(pc_iu_abst_sl_thold_2),
      .pc_iu_ary_nsl_thold_2(pc_iu_ary_nsl_thold_2),
      .pc_iu_repr_sl_thold_2(pc_iu_repr_sl_thold_2),
      .pc_iu_bolt_sl_thold_2(pc_iu_bolt_sl_thold_2),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .clkoff_b(clkoff_b),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .act_dis(act_dis),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .g8t_clkoff_b(g8t_clkoff_b),
      .g8t_d_mode(g8t_d_mode),
      .g8t_delay_lclkr(g8t_delay_lclkr),
      .g8t_mpw1_b(g8t_mpw1_b),
      .g8t_mpw2_b(g8t_mpw2_b),
      .func_scan_in(bh1_scan_in),
      .time_scan_in(1'b0),
      .abst_scan_in(1'b0),
      .repr_scan_in(1'b0),
      .func_scan_out(bh1_scan_out),
      .time_scan_out(),
      .abst_scan_out(),
      .repr_scan_out(),
      .pc_iu_abist_di_0(pc_iu_abist_di_0),
      .pc_iu_abist_g8t_bw_1(pc_iu_abist_g8t_bw_1),
      .pc_iu_abist_g8t_bw_0(pc_iu_abist_g8t_bw_0),
      .pc_iu_abist_waddr_0(pc_iu_abist_waddr_0),
      .pc_iu_abist_g8t_wenb(pc_iu_abist_g8t_wenb),
      .pc_iu_abist_raddr_0(pc_iu_abist_raddr_0[3:9]),
      .pc_iu_abist_g8t1p_renb_0(pc_iu_abist_g8t1p_renb_0),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .pc_iu_abist_ena_dc(pc_iu_abist_ena_dc),
      .pc_iu_abist_wl128_comp_ena(pc_iu_abist_wl128_comp_ena),
      .pc_iu_abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .pc_iu_abist_g8t_dcomp(pc_iu_abist_g8t_dcomp),
      .pc_iu_bo_enable_2(pc_iu_bo_enable_3),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select[0]),
      .iu_pc_bo_fail(),
      .iu_pc_bo_diagout(),
      .r_act(iu0_bh1_rd_act),
      .w_act(ex5_bh1_wr_act),
      .r_addr(iu0_bh1_rd_addr[0:9]),
      .w_addr(ex5_bh1_wr_addr[0:9]),
      .data_in(ex5_bh1_wr_data),
      .data_out0(iu2_0_bh1_rd_data),
      .data_out1(iu2_1_bh1_rd_data),
      .data_out2(iu2_2_bh1_rd_data),
      .data_out3(iu2_3_bh1_rd_data),
      .pc_iu_init_reset(pc_iu_init_reset)
   );

//   iuq_bht bht2(
   tri_bht_512x4_1r1w bht2(
      .gnd(gnd),
      .vdd(vdd),
      .vcs(vdd),
      .nclk(nclk),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_time_sl_thold_2(pc_iu_time_sl_thold_2),
      .pc_iu_abst_sl_thold_2(pc_iu_abst_sl_thold_2),
      .pc_iu_ary_nsl_thold_2(pc_iu_ary_nsl_thold_2),
      .pc_iu_repr_sl_thold_2(pc_iu_repr_sl_thold_2),
      .pc_iu_bolt_sl_thold_2(pc_iu_bolt_sl_thold_2),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .tc_ac_scan_dis_dc_b(tc_ac_scan_dis_dc_b),
      .clkoff_b(clkoff_b),
      .scan_diag_dc(tc_ac_scan_diag_dc),
      .act_dis(act_dis),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .g8t_clkoff_b(g8t_clkoff_b),
      .g8t_d_mode(g8t_d_mode),
      .g8t_delay_lclkr(g8t_delay_lclkr),
      .g8t_mpw1_b(g8t_mpw1_b),
      .g8t_mpw2_b(g8t_mpw2_b),
      .func_scan_in(bh2_scan_in),
      .time_scan_in(1'b0),
      .abst_scan_in(1'b0),
      .repr_scan_in(1'b0),
      .func_scan_out(bh2_scan_out),
      .time_scan_out(),
      .abst_scan_out(),
      .repr_scan_out(),
      .pc_iu_abist_di_0(pc_iu_abist_di_0),
      .pc_iu_abist_g8t_bw_1(pc_iu_abist_g8t_bw_1),
      .pc_iu_abist_g8t_bw_0(pc_iu_abist_g8t_bw_0),
      .pc_iu_abist_waddr_0(pc_iu_abist_waddr_0),
      .pc_iu_abist_g8t_wenb(pc_iu_abist_g8t_wenb),
      .pc_iu_abist_raddr_0(pc_iu_abist_raddr_0[3:9]),
      .pc_iu_abist_g8t1p_renb_0(pc_iu_abist_g8t1p_renb_0),
      .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
      .pc_iu_abist_ena_dc(pc_iu_abist_ena_dc),
      .pc_iu_abist_wl128_comp_ena(pc_iu_abist_wl128_comp_ena),
      .pc_iu_abist_raw_dc_b(pc_iu_abist_raw_dc_b),
      .pc_iu_abist_g8t_dcomp(pc_iu_abist_g8t_dcomp),
      .pc_iu_bo_enable_2(pc_iu_bo_enable_3),
      .pc_iu_bo_reset(pc_iu_bo_reset),
      .pc_iu_bo_unload(pc_iu_bo_unload),
      .pc_iu_bo_repair(pc_iu_bo_repair),
      .pc_iu_bo_shdata(pc_iu_bo_shdata),
      .pc_iu_bo_select(pc_iu_bo_select[0]),
      .iu_pc_bo_fail(),
      .iu_pc_bo_diagout(),
      .r_act(iu0_bh2_rd_act),
      .w_act(ex5_bh2_wr_act),
      .r_addr(iu0_bh2_rd_addr[0:8]),
      .w_addr(ex5_bh2_wr_addr[0:8]),
      .data_in(ex5_bh2_wr_data),
      .data_out0(iu2_0_bh2_rd_data),
      .data_out1(iu2_1_bh2_rd_data),
      .data_out2(iu2_2_bh2_rd_data),
      .data_out3(iu2_3_bh2_rd_data),
      .pc_iu_init_reset(pc_iu_init_reset)
   );

   //`IBUFF_IFAR_WIDTH  => `IBUFF_IFAR_WIDTH,
   iuq_slice_top iuq_slice_top0(
      //.vdd(vdd),
      //.gnd(gnd),
      .nclk(nclk),
      .pc_iu_sg_2(pc_iu_sg_2),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .clkoff_b(clkoff_b),
      .act_dis(act_dis),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .d_mode(d_mode),
      .delay_lclkr(delay_lclkr),
      .mpw1_b(mpw1_b),
      .mpw2_b(mpw2_b),
      .scan_in(slice_scan_in),
      .scan_out(slice_scan_out),


      .iu_pc_fx0_credit_ok(iu_pc_fx0_credit_ok),
      .iu_pc_fx1_credit_ok(iu_pc_fx1_credit_ok),
      .iu_pc_lq_credit_ok(iu_pc_lq_credit_ok),
      .iu_pc_sq_credit_ok(iu_pc_sq_credit_ok),
      .iu_pc_axu0_credit_ok(iu_pc_axu0_credit_ok),
      .iu_pc_axu1_credit_ok(iu_pc_axu1_credit_ok),

      //-------------------------------
      // Performance interface with I$
      //-------------------------------
      .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
      .slice_ic_t0_perf_events(slice_ic_t0_perf_events),
`ifndef THREADS1
      .slice_ic_t1_perf_events(slice_ic_t1_perf_events),
`endif

      .spr_dec_mask(spr_dec_mask),
      .spr_dec_match(spr_dec_match),

      .xu_iu_ccr2_ucode_dis(xu_iu_spr_ccr2_ucode_dis),
      .mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),
      .rm_ib_iu3_instr(rm_ib_iu3_instr),

      .cp_iu_iu4_flush(iu_flush),
      .cp_flush_into_uc(cp_flush_into_uc),

      .xu_iu_epcr_dgtmi(xu_iu_epcr_dgtmi),
      .xu_iu_msrp_uclep(xu_iu_msrp_uclep),
      .xu_iu_msr_pr(xu_iu_msr_pr),
      .xu_iu_msr_gs(xu_iu_msr_gs),
      .xu_iu_msr_ucle(xu_iu_msr_ucle),
      .spr_single_issue(spr_single_issue),

      // Input to dispatch to block due to ivax
      .cp_dis_ivax(cp_dis_ivax),

      //-----------------------------
      // MMU Connections
      //-----------------------------
      .mm_iu_flush_req(mm_iu_flush_req),
      .dp_cp_hold_req(dp_cp_hold_req),
      .mm_iu_hold_done(mm_iu_hold_done),
      .mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
      .dp_cp_bus_snoop_hold_req(dp_cp_bus_snoop_hold_req),
      .mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
      .mm_iu_tlbi_complete(mm_iu_tlbi_complete),

      //----------------------------
      // Credit Interface with IU
      //----------------------------
      .rv_iu_fx0_credit_free(rv_iu_fx0_credit_free),
      .rv_iu_fx1_credit_free(rv_iu_fx1_credit_free),		// Need to add 2nd unit someday
      .lq_iu_credit_free(lq_iu_credit_free),
      .sq_iu_credit_free(sq_iu_credit_free),
      .axu0_iu_credit_free(axu0_iu_credit_free),		// credit free from axu reservation station
      .axu1_iu_credit_free(axu1_iu_credit_free),		// credit free from axu reservation station

      .ib_rm_rdy(ib_rm_rdy),
      .rm_ib_iu3_val(rm_ib_iu3_val),
      .ib_uc_rdy(ib_uc_rdy),
      .uc_ib_done(uc_ib_done),

      .iu_flush(iu_flush),
      .cp_flush(cp_flush_internal),
      .br_iu_redirect(br_iu_redirect),
      .uc_ib_iu3_flush_all(uc_ib_iu3_flush_all),
      .cp_rn_uc_credit_free(cp_rn_uc_credit_free),
      .xu_iu_run_thread(xu_iu_run_thread),
      .iu_xu_credits_returned(iu_xu_credits_returned),

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
      .spr_t0_cpcr3_cp_cnt(spr_t0_cpcr3_cp_cnt),
      .spr_t0_cpcr4_fx0_cnt(spr_t0_cpcr4_fx0_cnt),
      .spr_t0_cpcr4_fx1_cnt(spr_t0_cpcr4_fx1_cnt),
      .spr_t0_cpcr4_lq_cnt(spr_t0_cpcr4_lq_cnt),
      .spr_t0_cpcr4_sq_cnt(spr_t0_cpcr4_sq_cnt),
      .spr_t0_cpcr5_fu0_cnt(spr_t0_cpcr5_fu0_cnt),
      .spr_t0_cpcr5_fu1_cnt(spr_t0_cpcr5_fu1_cnt),
      .spr_t0_cpcr5_cp_cnt(spr_t0_cpcr5_cp_cnt),
`ifndef THREADS1
      .spr_t1_cpcr2_fx0_cnt(spr_t1_cpcr2_fx0_cnt),
      .spr_t1_cpcr2_fx1_cnt(spr_t1_cpcr2_fx1_cnt),
      .spr_t1_cpcr2_lq_cnt(spr_t1_cpcr2_lq_cnt),
      .spr_t1_cpcr2_sq_cnt(spr_t1_cpcr2_sq_cnt),
      .spr_t1_cpcr3_fu0_cnt(spr_t1_cpcr3_fu0_cnt),
      .spr_t1_cpcr3_fu1_cnt(spr_t1_cpcr3_fu1_cnt),
      .spr_t1_cpcr3_cp_cnt(spr_t1_cpcr3_cp_cnt),
      .spr_t1_cpcr4_fx0_cnt(spr_t1_cpcr4_fx0_cnt),
      .spr_t1_cpcr4_fx1_cnt(spr_t1_cpcr4_fx1_cnt),
      .spr_t1_cpcr4_lq_cnt(spr_t1_cpcr4_lq_cnt),
      .spr_t1_cpcr4_sq_cnt(spr_t1_cpcr4_sq_cnt),
      .spr_t1_cpcr5_fu0_cnt(spr_t1_cpcr5_fu0_cnt),
      .spr_t1_cpcr5_fu1_cnt(spr_t1_cpcr5_fu1_cnt),
      .spr_t1_cpcr5_cp_cnt(spr_t1_cpcr5_cp_cnt),
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

      //-----------------------------
      // SPR values
      //-----------------------------
      .iu_au_t0_config_iucr(iu_au_t0_config_iucr),

      //----------------------------
      // Ucode interface with IB
      //----------------------------
      .uc_ib_iu3_t0_invalid(uc_ib_iu3_t0_invalid),
      .uc_ib_t0_val(uc_ib_t0_val),
      .uc_ib_t0_instr0(uc_ib_t0_instr0),
      .uc_ib_t0_instr1(uc_ib_t0_instr1),
      .uc_ib_t0_ifar0(uc_ib_t0_ifar0),
      .uc_ib_t0_ifar1(uc_ib_t0_ifar1),
      .uc_ib_t0_ext0(uc_ib_t0_ext0),
      .uc_ib_t0_ext1(uc_ib_t0_ext1),

      //----------------------------
      // Completion Interface
      //----------------------------
      .cp_rn_empty(cp_rn_empty),
      .cp_rn_t0_i0_axu_exception_val(cp_rn_t0_i0_axu_exception_val),
      .cp_rn_t0_i0_axu_exception(cp_rn_t0_i0_axu_exception),
      .cp_rn_t0_i1_axu_exception_val(cp_rn_t0_i1_axu_exception_val),
      .cp_rn_t0_i1_axu_exception(cp_rn_t0_i1_axu_exception),
      .cp_rn_t0_i0_v(cp_rn_t0_i0_v),
      .cp_rn_t0_i0_itag(iu_lq_t0_i0_completed_itag_int),
      .cp_rn_t0_i0_t1_v(cp_rn_t0_i0_t1_v),
      .cp_rn_t0_i0_t1_t(cp_rn_t0_i0_t1_t),
      .cp_rn_t0_i0_t1_p(cp_rn_t0_i0_t1_p),
      .cp_rn_t0_i0_t1_a(cp_rn_t0_i0_t1_a),
      .cp_rn_t0_i0_t2_v(cp_rn_t0_i0_t2_v),
      .cp_rn_t0_i0_t2_t(cp_rn_t0_i0_t2_t),
      .cp_rn_t0_i0_t2_p(cp_rn_t0_i0_t2_p),
      .cp_rn_t0_i0_t2_a(cp_rn_t0_i0_t2_a),
      .cp_rn_t0_i0_t3_v(cp_rn_t0_i0_t3_v),
      .cp_rn_t0_i0_t3_t(cp_rn_t0_i0_t3_t),
      .cp_rn_t0_i0_t3_p(cp_rn_t0_i0_t3_p),
      .cp_rn_t0_i0_t3_a(cp_rn_t0_i0_t3_a),

      .cp_rn_t0_i1_v(cp_rn_t0_i1_v),
      .cp_rn_t0_i1_itag(iu_lq_t0_i1_completed_itag_int),
      .cp_rn_t0_i1_t1_v(cp_rn_t0_i1_t1_v),
      .cp_rn_t0_i1_t1_t(cp_rn_t0_i1_t1_t),
      .cp_rn_t0_i1_t1_p(cp_rn_t0_i1_t1_p),
      .cp_rn_t0_i1_t1_a(cp_rn_t0_i1_t1_a),
      .cp_rn_t0_i1_t2_v(cp_rn_t0_i1_t2_v),
      .cp_rn_t0_i1_t2_t(cp_rn_t0_i1_t2_t),
      .cp_rn_t0_i1_t2_p(cp_rn_t0_i1_t2_p),
      .cp_rn_t0_i1_t2_a(cp_rn_t0_i1_t2_a),
      .cp_rn_t0_i1_t3_v(cp_rn_t0_i1_t3_v),
      .cp_rn_t0_i1_t3_t(cp_rn_t0_i1_t3_t),
      .cp_rn_t0_i1_t3_p(cp_rn_t0_i1_t3_p),
      .cp_rn_t0_i1_t3_a(cp_rn_t0_i1_t3_a),

      //----------------------------------------------------------------
      // Interface to reservation station - Completion is snooping also
      //----------------------------------------------------------------
      .iu_rv_iu6_t0_i0_vld(rn_cp_iu6_t0_i0_vld),
      .iu_rv_iu6_t0_i0_act(iu_rv_iu6_t0_i0_act),
      .iu_rv_iu6_t0_i0_itag(rn_cp_iu6_t0_i0_itag),
      .iu_rv_iu6_t0_i0_ucode(rn_cp_iu6_t0_i0_ucode),
      .iu_rv_iu6_t0_i0_ucode_cnt(iu_rv_iu6_t0_i0_ucode_cnt),
      .iu_rv_iu6_t0_i0_2ucode(iu_rv_iu6_t0_i0_2ucode),
      .iu_rv_iu6_t0_i0_fuse_nop(rn_cp_iu6_t0_i0_fuse_nop),
      .iu_rv_iu6_t0_i0_rte_lq(rn_cp_iu6_t0_i0_rte_lq),
      .iu_rv_iu6_t0_i0_rte_sq(rn_cp_iu6_t0_i0_rte_sq),
      .iu_rv_iu6_t0_i0_rte_fx0(rn_cp_iu6_t0_i0_rte_fx0),
      .iu_rv_iu6_t0_i0_rte_fx1(rn_cp_iu6_t0_i0_rte_fx1),
      .iu_rv_iu6_t0_i0_rte_axu0(rn_cp_iu6_t0_i0_rte_axu0),
      .iu_rv_iu6_t0_i0_rte_axu1(rn_cp_iu6_t0_i0_rte_axu1),
      .iu_rv_iu6_t0_i0_valop(rn_cp_iu6_t0_i0_valop),
      .iu_rv_iu6_t0_i0_ord(iu_rv_iu6_t0_i0_ord),
      .iu_rv_iu6_t0_i0_cord(iu_rv_iu6_t0_i0_cord),
      .iu_rv_iu6_t0_i0_error(rn_cp_iu6_t0_i0_error),
      .iu_rv_iu6_t0_i0_btb_entry(rn_cp_iu6_t0_i0_btb_entry),
      .iu_rv_iu6_t0_i0_btb_hist(rn_cp_iu6_t0_i0_btb_hist),
      .iu_rv_iu6_t0_i0_bta_val(rn_cp_iu6_t0_i0_bta_val),
      .iu_rv_iu6_t0_i0_fusion(iu_rv_iu6_t0_i0_fusion),
      .iu_rv_iu6_t0_i0_spec(iu_rv_iu6_t0_i0_spec),
      .iu_rv_iu6_t0_i0_type_fp(rn_cp_iu6_t0_i0_type_fp),
      .iu_rv_iu6_t0_i0_type_ap(rn_cp_iu6_t0_i0_type_ap),
      .iu_rv_iu6_t0_i0_type_spv(rn_cp_iu6_t0_i0_type_spv),
      .iu_rv_iu6_t0_i0_type_st(rn_cp_iu6_t0_i0_type_st),
      .iu_rv_iu6_t0_i0_async_block(rn_cp_iu6_t0_i0_async_block),
      .iu_rv_iu6_t0_i0_np1_flush(rn_cp_iu6_t0_i0_np1_flush),
      .iu_rv_iu6_t0_i0_isram(rn_cp_iu6_t0_i0_isram),
      .iu_rv_iu6_t0_i0_isload(iu_rv_iu6_t0_i0_isload),
      .iu_rv_iu6_t0_i0_isstore(iu_rv_iu6_t0_i0_isstore),
      .iu_rv_iu6_t0_i0_instr(rn_cp_iu6_t0_i0_instr),
      .iu_rv_iu6_t0_i0_ifar(rn_cp_iu6_t0_i0_ifar),
      .iu_rv_iu6_t0_i0_bta(rn_cp_iu6_t0_i0_bta),
      .iu_rv_iu6_t0_i0_br_pred(rn_cp_iu6_t0_i0_br_pred),
      .iu_rv_iu6_t0_i0_bh_update(rn_cp_iu6_t0_i0_bh_update),
      .iu_rv_iu6_t0_i0_bh0_hist(rn_cp_iu6_t0_i0_bh0_hist),
      .iu_rv_iu6_t0_i0_bh1_hist(rn_cp_iu6_t0_i0_bh1_hist),
      .iu_rv_iu6_t0_i0_bh2_hist(rn_cp_iu6_t0_i0_bh2_hist),
      .iu_rv_iu6_t0_i0_gshare(rn_cp_iu6_t0_i0_gshare),
      .iu_rv_iu6_t0_i0_ls_ptr(rn_cp_iu6_t0_i0_ls_ptr),
      .iu_rv_iu6_t0_i0_match(rn_cp_iu6_t0_i0_match),
      .iu_rv_iu6_t0_i0_ilat(iu_rv_iu6_t0_i0_ilat),
      .iu_rv_iu6_t0_i0_t1_v(rn_cp_iu6_t0_i0_t1_v),
      .iu_rv_iu6_t0_i0_t1_t(rn_cp_iu6_t0_i0_t1_t),
      .iu_rv_iu6_t0_i0_t1_a(rn_cp_iu6_t0_i0_t1_a),
      .iu_rv_iu6_t0_i0_t1_p(rn_cp_iu6_t0_i0_t1_p),
      .iu_rv_iu6_t0_i0_t2_v(rn_cp_iu6_t0_i0_t2_v),
      .iu_rv_iu6_t0_i0_t2_a(rn_cp_iu6_t0_i0_t2_a),
      .iu_rv_iu6_t0_i0_t2_p(rn_cp_iu6_t0_i0_t2_p),
      .iu_rv_iu6_t0_i0_t2_t(rn_cp_iu6_t0_i0_t2_t),
      .iu_rv_iu6_t0_i0_t3_v(rn_cp_iu6_t0_i0_t3_v),
      .iu_rv_iu6_t0_i0_t3_a(rn_cp_iu6_t0_i0_t3_a),
      .iu_rv_iu6_t0_i0_t3_p(rn_cp_iu6_t0_i0_t3_p),
      .iu_rv_iu6_t0_i0_t3_t(rn_cp_iu6_t0_i0_t3_t),
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

      .iu_rv_iu6_t0_i1_vld(rn_cp_iu6_t0_i1_vld),
      .iu_rv_iu6_t0_i1_act(iu_rv_iu6_t0_i1_act),
      .iu_rv_iu6_t0_i1_itag(rn_cp_iu6_t0_i1_itag),
      .iu_rv_iu6_t0_i1_ucode(rn_cp_iu6_t0_i1_ucode),
      .iu_rv_iu6_t0_i1_ucode_cnt(iu_rv_iu6_t0_i1_ucode_cnt),
      .iu_rv_iu6_t0_i1_fuse_nop(rn_cp_iu6_t0_i1_fuse_nop),
      .iu_rv_iu6_t0_i1_rte_lq(rn_cp_iu6_t0_i1_rte_lq),
      .iu_rv_iu6_t0_i1_rte_sq(rn_cp_iu6_t0_i1_rte_sq),
      .iu_rv_iu6_t0_i1_rte_fx0(rn_cp_iu6_t0_i1_rte_fx0),
      .iu_rv_iu6_t0_i1_rte_fx1(rn_cp_iu6_t0_i1_rte_fx1),
      .iu_rv_iu6_t0_i1_rte_axu0(rn_cp_iu6_t0_i1_rte_axu0),
      .iu_rv_iu6_t0_i1_rte_axu1(rn_cp_iu6_t0_i1_rte_axu1),
      .iu_rv_iu6_t0_i1_valop(rn_cp_iu6_t0_i1_valop),
      .iu_rv_iu6_t0_i1_ord(iu_rv_iu6_t0_i1_ord),
      .iu_rv_iu6_t0_i1_cord(iu_rv_iu6_t0_i1_cord),
      .iu_rv_iu6_t0_i1_error(rn_cp_iu6_t0_i1_error),
      .iu_rv_iu6_t0_i1_btb_entry(rn_cp_iu6_t0_i1_btb_entry),
      .iu_rv_iu6_t0_i1_btb_hist(rn_cp_iu6_t0_i1_btb_hist),
      .iu_rv_iu6_t0_i1_bta_val(rn_cp_iu6_t0_i1_bta_val),
      .iu_rv_iu6_t0_i1_fusion(iu_rv_iu6_t0_i1_fusion),
      .iu_rv_iu6_t0_i1_spec(iu_rv_iu6_t0_i1_spec),
      .iu_rv_iu6_t0_i1_type_fp(rn_cp_iu6_t0_i1_type_fp),
      .iu_rv_iu6_t0_i1_type_ap(rn_cp_iu6_t0_i1_type_ap),
      .iu_rv_iu6_t0_i1_type_spv(rn_cp_iu6_t0_i1_type_spv),
      .iu_rv_iu6_t0_i1_type_st(rn_cp_iu6_t0_i1_type_st),
      .iu_rv_iu6_t0_i1_async_block(rn_cp_iu6_t0_i1_async_block),
      .iu_rv_iu6_t0_i1_np1_flush(rn_cp_iu6_t0_i1_np1_flush),
      .iu_rv_iu6_t0_i1_isram(rn_cp_iu6_t0_i1_isram),
      .iu_rv_iu6_t0_i1_isload(iu_rv_iu6_t0_i1_isload),
      .iu_rv_iu6_t0_i1_isstore(iu_rv_iu6_t0_i1_isstore),
      .iu_rv_iu6_t0_i1_instr(rn_cp_iu6_t0_i1_instr),
      .iu_rv_iu6_t0_i1_ifar(rn_cp_iu6_t0_i1_ifar),
      .iu_rv_iu6_t0_i1_bta(rn_cp_iu6_t0_i1_bta),
      .iu_rv_iu6_t0_i1_br_pred(rn_cp_iu6_t0_i1_br_pred),
      .iu_rv_iu6_t0_i1_bh_update(rn_cp_iu6_t0_i1_bh_update),
      .iu_rv_iu6_t0_i1_bh0_hist(rn_cp_iu6_t0_i1_bh0_hist),
      .iu_rv_iu6_t0_i1_bh1_hist(rn_cp_iu6_t0_i1_bh1_hist),
      .iu_rv_iu6_t0_i1_bh2_hist(rn_cp_iu6_t0_i1_bh2_hist),
      .iu_rv_iu6_t0_i1_gshare(rn_cp_iu6_t0_i1_gshare),
      .iu_rv_iu6_t0_i1_ls_ptr(rn_cp_iu6_t0_i1_ls_ptr),
      .iu_rv_iu6_t0_i1_match(rn_cp_iu6_t0_i1_match),
      .iu_rv_iu6_t0_i1_ilat(iu_rv_iu6_t0_i1_ilat),
      .iu_rv_iu6_t0_i1_t1_v(rn_cp_iu6_t0_i1_t1_v),
      .iu_rv_iu6_t0_i1_t1_t(rn_cp_iu6_t0_i1_t1_t),
      .iu_rv_iu6_t0_i1_t1_a(rn_cp_iu6_t0_i1_t1_a),
      .iu_rv_iu6_t0_i1_t1_p(rn_cp_iu6_t0_i1_t1_p),
      .iu_rv_iu6_t0_i1_t2_v(rn_cp_iu6_t0_i1_t2_v),
      .iu_rv_iu6_t0_i1_t2_a(rn_cp_iu6_t0_i1_t2_a),
      .iu_rv_iu6_t0_i1_t2_p(rn_cp_iu6_t0_i1_t2_p),
      .iu_rv_iu6_t0_i1_t2_t(rn_cp_iu6_t0_i1_t2_t),
      .iu_rv_iu6_t0_i1_t3_v(rn_cp_iu6_t0_i1_t3_v),
      .iu_rv_iu6_t0_i1_t3_a(rn_cp_iu6_t0_i1_t3_a),
      .iu_rv_iu6_t0_i1_t3_p(rn_cp_iu6_t0_i1_t3_p),
      .iu_rv_iu6_t0_i1_t3_t(rn_cp_iu6_t0_i1_t3_t),
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
      //-----------------------------
      // SPR values
      //-----------------------------
      .iu_au_t1_config_iucr(iu_au_t1_config_iucr),

      //----------------------------
      // Ucode interface with IB
      //----------------------------
      .uc_ib_iu3_t1_invalid(uc_ib_iu3_t1_invalid),
      .uc_ib_t1_val(uc_ib_t1_val),
      .uc_ib_t1_instr0(uc_ib_t1_instr0),
      .uc_ib_t1_instr1(uc_ib_t1_instr1),
      .uc_ib_t1_ifar0(uc_ib_t1_ifar0),
      .uc_ib_t1_ifar1(uc_ib_t1_ifar1),
      .uc_ib_t1_ext0(uc_ib_t1_ext0),
      .uc_ib_t1_ext1(uc_ib_t1_ext1),

      //----------------------------
      // Completion Interface
      //----------------------------
      .cp_rn_t1_i0_axu_exception_val(cp_rn_t1_i0_axu_exception_val),
      .cp_rn_t1_i0_axu_exception(cp_rn_t1_i0_axu_exception),
      .cp_rn_t1_i1_axu_exception_val(cp_rn_t1_i1_axu_exception_val),
      .cp_rn_t1_i1_axu_exception(cp_rn_t1_i1_axu_exception),
      .cp_rn_t1_i0_v(cp_rn_t1_i0_v),
      .cp_rn_t1_i0_itag(iu_lq_t1_i0_completed_itag_int),
      .cp_rn_t1_i0_t1_v(cp_rn_t1_i0_t1_v),
      .cp_rn_t1_i0_t1_t(cp_rn_t1_i0_t1_t),
      .cp_rn_t1_i0_t1_p(cp_rn_t1_i0_t1_p),
      .cp_rn_t1_i0_t1_a(cp_rn_t1_i0_t1_a),
      .cp_rn_t1_i0_t2_v(cp_rn_t1_i0_t2_v),
      .cp_rn_t1_i0_t2_t(cp_rn_t1_i0_t2_t),
      .cp_rn_t1_i0_t2_p(cp_rn_t1_i0_t2_p),
      .cp_rn_t1_i0_t2_a(cp_rn_t1_i0_t2_a),
      .cp_rn_t1_i0_t3_v(cp_rn_t1_i0_t3_v),
      .cp_rn_t1_i0_t3_t(cp_rn_t1_i0_t3_t),
      .cp_rn_t1_i0_t3_p(cp_rn_t1_i0_t3_p),
      .cp_rn_t1_i0_t3_a(cp_rn_t1_i0_t3_a),

      .cp_rn_t1_i1_v(cp_rn_t1_i1_v),
      .cp_rn_t1_i1_itag(iu_lq_t1_i1_completed_itag_int),
      .cp_rn_t1_i1_t1_v(cp_rn_t1_i1_t1_v),
      .cp_rn_t1_i1_t1_t(cp_rn_t1_i1_t1_t),
      .cp_rn_t1_i1_t1_p(cp_rn_t1_i1_t1_p),
      .cp_rn_t1_i1_t1_a(cp_rn_t1_i1_t1_a),
      .cp_rn_t1_i1_t2_v(cp_rn_t1_i1_t2_v),
      .cp_rn_t1_i1_t2_t(cp_rn_t1_i1_t2_t),
      .cp_rn_t1_i1_t2_p(cp_rn_t1_i1_t2_p),
      .cp_rn_t1_i1_t2_a(cp_rn_t1_i1_t2_a),
      .cp_rn_t1_i1_t3_v(cp_rn_t1_i1_t3_v),
      .cp_rn_t1_i1_t3_t(cp_rn_t1_i1_t3_t),
      .cp_rn_t1_i1_t3_p(cp_rn_t1_i1_t3_p),
      .cp_rn_t1_i1_t3_a(cp_rn_t1_i1_t3_a),

      .iu_rv_iu6_t1_i0_vld(rn_cp_iu6_t1_i0_vld),
      .iu_rv_iu6_t1_i0_act(iu_rv_iu6_t1_i0_act),
      .iu_rv_iu6_t1_i0_itag(rn_cp_iu6_t1_i0_itag),
      .iu_rv_iu6_t1_i0_ucode(rn_cp_iu6_t1_i0_ucode),
      .iu_rv_iu6_t1_i0_ucode_cnt(iu_rv_iu6_t1_i0_ucode_cnt),
      .iu_rv_iu6_t1_i0_2ucode(iu_rv_iu6_t1_i0_2ucode),
      .iu_rv_iu6_t1_i0_fuse_nop(rn_cp_iu6_t1_i0_fuse_nop),
      .iu_rv_iu6_t1_i0_rte_lq(rn_cp_iu6_t1_i0_rte_lq),
      .iu_rv_iu6_t1_i0_rte_sq(rn_cp_iu6_t1_i0_rte_sq),
      .iu_rv_iu6_t1_i0_rte_fx0(rn_cp_iu6_t1_i0_rte_fx0),
      .iu_rv_iu6_t1_i0_rte_fx1(rn_cp_iu6_t1_i0_rte_fx1),
      .iu_rv_iu6_t1_i0_rte_axu0(rn_cp_iu6_t1_i0_rte_axu0),
      .iu_rv_iu6_t1_i0_rte_axu1(rn_cp_iu6_t1_i0_rte_axu1),
      .iu_rv_iu6_t1_i0_valop(rn_cp_iu6_t1_i0_valop),
      .iu_rv_iu6_t1_i0_ord(iu_rv_iu6_t1_i0_ord),
      .iu_rv_iu6_t1_i0_cord(iu_rv_iu6_t1_i0_cord),
      .iu_rv_iu6_t1_i0_error(rn_cp_iu6_t1_i0_error),
      .iu_rv_iu6_t1_i0_btb_entry(rn_cp_iu6_t1_i0_btb_entry),
      .iu_rv_iu6_t1_i0_btb_hist(rn_cp_iu6_t1_i0_btb_hist),
      .iu_rv_iu6_t1_i0_bta_val(rn_cp_iu6_t1_i0_bta_val),
      .iu_rv_iu6_t1_i0_fusion(iu_rv_iu6_t1_i0_fusion),
      .iu_rv_iu6_t1_i0_spec(iu_rv_iu6_t1_i0_spec),
      .iu_rv_iu6_t1_i0_type_fp(rn_cp_iu6_t1_i0_type_fp),
      .iu_rv_iu6_t1_i0_type_ap(rn_cp_iu6_t1_i0_type_ap),
      .iu_rv_iu6_t1_i0_type_spv(rn_cp_iu6_t1_i0_type_spv),
      .iu_rv_iu6_t1_i0_type_st(rn_cp_iu6_t1_i0_type_st),
      .iu_rv_iu6_t1_i0_async_block(rn_cp_iu6_t1_i0_async_block),
      .iu_rv_iu6_t1_i0_np1_flush(rn_cp_iu6_t1_i0_np1_flush),
      .iu_rv_iu6_t1_i0_isram(rn_cp_iu6_t1_i0_isram),
      .iu_rv_iu6_t1_i0_isload(iu_rv_iu6_t1_i0_isload),
      .iu_rv_iu6_t1_i0_isstore(iu_rv_iu6_t1_i0_isstore),
      .iu_rv_iu6_t1_i0_instr(rn_cp_iu6_t1_i0_instr),
      .iu_rv_iu6_t1_i0_ifar(rn_cp_iu6_t1_i0_ifar),
      .iu_rv_iu6_t1_i0_bta(rn_cp_iu6_t1_i0_bta),
      .iu_rv_iu6_t1_i0_br_pred(rn_cp_iu6_t1_i0_br_pred),
      .iu_rv_iu6_t1_i0_bh_update(rn_cp_iu6_t1_i0_bh_update),
      .iu_rv_iu6_t1_i0_bh0_hist(rn_cp_iu6_t1_i0_bh0_hist),
      .iu_rv_iu6_t1_i0_bh1_hist(rn_cp_iu6_t1_i0_bh1_hist),
      .iu_rv_iu6_t1_i0_bh2_hist(rn_cp_iu6_t1_i0_bh2_hist),
      .iu_rv_iu6_t1_i0_gshare(rn_cp_iu6_t1_i0_gshare),
      .iu_rv_iu6_t1_i0_ls_ptr(rn_cp_iu6_t1_i0_ls_ptr),
      .iu_rv_iu6_t1_i0_match(rn_cp_iu6_t1_i0_match),
      .iu_rv_iu6_t1_i0_ilat(iu_rv_iu6_t1_i0_ilat),
      .iu_rv_iu6_t1_i0_t1_v(rn_cp_iu6_t1_i0_t1_v),
      .iu_rv_iu6_t1_i0_t1_t(rn_cp_iu6_t1_i0_t1_t),
      .iu_rv_iu6_t1_i0_t1_a(rn_cp_iu6_t1_i0_t1_a),
      .iu_rv_iu6_t1_i0_t1_p(rn_cp_iu6_t1_i0_t1_p),
      .iu_rv_iu6_t1_i0_t2_v(rn_cp_iu6_t1_i0_t2_v),
      .iu_rv_iu6_t1_i0_t2_a(rn_cp_iu6_t1_i0_t2_a),
      .iu_rv_iu6_t1_i0_t2_p(rn_cp_iu6_t1_i0_t2_p),
      .iu_rv_iu6_t1_i0_t2_t(rn_cp_iu6_t1_i0_t2_t),
      .iu_rv_iu6_t1_i0_t3_v(rn_cp_iu6_t1_i0_t3_v),
      .iu_rv_iu6_t1_i0_t3_a(rn_cp_iu6_t1_i0_t3_a),
      .iu_rv_iu6_t1_i0_t3_p(rn_cp_iu6_t1_i0_t3_p),
      .iu_rv_iu6_t1_i0_t3_t(rn_cp_iu6_t1_i0_t3_t),
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

      .iu_rv_iu6_t1_i1_vld(rn_cp_iu6_t1_i1_vld),
      .iu_rv_iu6_t1_i1_act(iu_rv_iu6_t1_i1_act),
      .iu_rv_iu6_t1_i1_itag(rn_cp_iu6_t1_i1_itag),
      .iu_rv_iu6_t1_i1_ucode(rn_cp_iu6_t1_i1_ucode),
      .iu_rv_iu6_t1_i1_ucode_cnt(iu_rv_iu6_t1_i1_ucode_cnt),
      .iu_rv_iu6_t1_i1_fuse_nop(rn_cp_iu6_t1_i1_fuse_nop),
      .iu_rv_iu6_t1_i1_rte_lq(rn_cp_iu6_t1_i1_rte_lq),
      .iu_rv_iu6_t1_i1_rte_sq(rn_cp_iu6_t1_i1_rte_sq),
      .iu_rv_iu6_t1_i1_rte_fx0(rn_cp_iu6_t1_i1_rte_fx0),
      .iu_rv_iu6_t1_i1_rte_fx1(rn_cp_iu6_t1_i1_rte_fx1),
      .iu_rv_iu6_t1_i1_rte_axu0(rn_cp_iu6_t1_i1_rte_axu0),
      .iu_rv_iu6_t1_i1_rte_axu1(rn_cp_iu6_t1_i1_rte_axu1),
      .iu_rv_iu6_t1_i1_valop(rn_cp_iu6_t1_i1_valop),
      .iu_rv_iu6_t1_i1_ord(iu_rv_iu6_t1_i1_ord),
      .iu_rv_iu6_t1_i1_cord(iu_rv_iu6_t1_i1_cord),
      .iu_rv_iu6_t1_i1_error(rn_cp_iu6_t1_i1_error),
      .iu_rv_iu6_t1_i1_btb_entry(rn_cp_iu6_t1_i1_btb_entry),
      .iu_rv_iu6_t1_i1_btb_hist(rn_cp_iu6_t1_i1_btb_hist),
      .iu_rv_iu6_t1_i1_bta_val(rn_cp_iu6_t1_i1_bta_val),
      .iu_rv_iu6_t1_i1_fusion(iu_rv_iu6_t1_i1_fusion),
      .iu_rv_iu6_t1_i1_spec(iu_rv_iu6_t1_i1_spec),
      .iu_rv_iu6_t1_i1_type_fp(rn_cp_iu6_t1_i1_type_fp),
      .iu_rv_iu6_t1_i1_type_ap(rn_cp_iu6_t1_i1_type_ap),
      .iu_rv_iu6_t1_i1_type_spv(rn_cp_iu6_t1_i1_type_spv),
      .iu_rv_iu6_t1_i1_type_st(rn_cp_iu6_t1_i1_type_st),
      .iu_rv_iu6_t1_i1_async_block(rn_cp_iu6_t1_i1_async_block),
      .iu_rv_iu6_t1_i1_np1_flush(rn_cp_iu6_t1_i1_np1_flush),
      .iu_rv_iu6_t1_i1_isram(rn_cp_iu6_t1_i1_isram),
      .iu_rv_iu6_t1_i1_isload(iu_rv_iu6_t1_i1_isload),
      .iu_rv_iu6_t1_i1_isstore(iu_rv_iu6_t1_i1_isstore),
      .iu_rv_iu6_t1_i1_instr(rn_cp_iu6_t1_i1_instr),
      .iu_rv_iu6_t1_i1_ifar(rn_cp_iu6_t1_i1_ifar),
      .iu_rv_iu6_t1_i1_bta(rn_cp_iu6_t1_i1_bta),
      .iu_rv_iu6_t1_i1_br_pred(rn_cp_iu6_t1_i1_br_pred),
      .iu_rv_iu6_t1_i1_bh_update(rn_cp_iu6_t1_i1_bh_update),
      .iu_rv_iu6_t1_i1_bh0_hist(rn_cp_iu6_t1_i1_bh0_hist),
      .iu_rv_iu6_t1_i1_bh1_hist(rn_cp_iu6_t1_i1_bh1_hist),
      .iu_rv_iu6_t1_i1_bh2_hist(rn_cp_iu6_t1_i1_bh2_hist),
      .iu_rv_iu6_t1_i1_gshare(rn_cp_iu6_t1_i1_gshare),
      .iu_rv_iu6_t1_i1_ls_ptr(rn_cp_iu6_t1_i1_ls_ptr),
      .iu_rv_iu6_t1_i1_match(rn_cp_iu6_t1_i1_match),
      .iu_rv_iu6_t1_i1_ilat(iu_rv_iu6_t1_i1_ilat),
      .iu_rv_iu6_t1_i1_t1_v(rn_cp_iu6_t1_i1_t1_v),
      .iu_rv_iu6_t1_i1_t1_t(rn_cp_iu6_t1_i1_t1_t),
      .iu_rv_iu6_t1_i1_t1_a(rn_cp_iu6_t1_i1_t1_a),
      .iu_rv_iu6_t1_i1_t1_p(rn_cp_iu6_t1_i1_t1_p),
      .iu_rv_iu6_t1_i1_t2_v(rn_cp_iu6_t1_i1_t2_v),
      .iu_rv_iu6_t1_i1_t2_a(rn_cp_iu6_t1_i1_t2_a),
      .iu_rv_iu6_t1_i1_t2_p(rn_cp_iu6_t1_i1_t2_p),
      .iu_rv_iu6_t1_i1_t2_t(rn_cp_iu6_t1_i1_t2_t),
      .iu_rv_iu6_t1_i1_t3_v(rn_cp_iu6_t1_i1_t3_v),
      .iu_rv_iu6_t1_i1_t3_a(rn_cp_iu6_t1_i1_t3_a),
      .iu_rv_iu6_t1_i1_t3_p(rn_cp_iu6_t1_i1_t3_p),
      .iu_rv_iu6_t1_i1_t3_t(rn_cp_iu6_t1_i1_t3_t),
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
      //----------------------------
      // Ifetch with slice
      //----------------------------
`ifndef THREADS1
      .ib_ic_t1_need_fetch(ib_ic_t1_need_fetch),
      .bp_ib_iu3_t1_val(bp_ib_iu3_t1_val),
      .bp_ib_iu3_t1_ifar(bp_ib_iu3_t1_ifar),
      .bp_ib_iu3_t1_bta(bp_ib_iu3_t1_bta),
      .bp_ib_iu3_t1_0_instr(bp_ib_iu3_t1_0_instr),
      .bp_ib_iu3_t1_1_instr(bp_ib_iu3_t1_1_instr),
      .bp_ib_iu3_t1_2_instr(bp_ib_iu3_t1_2_instr),
      .bp_ib_iu3_t1_3_instr(bp_ib_iu3_t1_3_instr),
`endif
      .ib_ic_t0_need_fetch(ib_ic_t0_need_fetch),
      .bp_ib_iu3_t0_ifar(bp_ib_iu3_t0_ifar),
      .bp_ib_iu3_t0_bta(bp_ib_iu3_t0_bta),
      .bp_ib_iu3_t0_0_instr(bp_ib_iu3_t0_0_instr),
      .bp_ib_iu3_t0_1_instr(bp_ib_iu3_t0_1_instr),
      .bp_ib_iu3_t0_2_instr(bp_ib_iu3_t0_2_instr),
      .bp_ib_iu3_t0_3_instr(bp_ib_iu3_t0_3_instr),
      .bp_ib_iu3_t0_val(bp_ib_iu3_t0_val)

   );

   assign iu_rv_iu6_t0_i0_vld = rn_cp_iu6_t0_i0_vld;
   assign iu_rv_iu6_t0_i0_itag = rn_cp_iu6_t0_i0_itag;
   assign iu_rv_iu6_t0_i0_ucode = rn_cp_iu6_t0_i0_ucode;
   assign iu_rv_iu6_t0_i0_rte_lq = rn_cp_iu6_t0_i0_rte_lq;
   assign iu_rv_iu6_t0_i0_rte_sq = rn_cp_iu6_t0_i0_rte_sq;
   assign iu_rv_iu6_t0_i0_rte_fx0 = rn_cp_iu6_t0_i0_rte_fx0;
   assign iu_rv_iu6_t0_i0_rte_fx1 = rn_cp_iu6_t0_i0_rte_fx1;
   assign iu_rv_iu6_t0_i0_rte_axu0 = rn_cp_iu6_t0_i0_rte_axu0;
   assign iu_rv_iu6_t0_i0_rte_axu1 = rn_cp_iu6_t0_i0_rte_axu1;
   assign iu_rv_iu6_t0_i0_instr = rn_cp_iu6_t0_i0_instr;
   assign iu_rv_iu6_t0_i0_ifar = rn_cp_iu6_t0_i0_ifar;
   assign iu_rv_iu6_t0_i0_bta = rn_cp_iu6_t0_i0_bta;
   assign iu_rv_iu6_t0_i0_br_pred = rn_cp_iu6_t0_i0_br_pred;
   assign iu_rv_iu6_t0_i0_bh_update = rn_cp_iu6_t0_i0_bh_update;
   assign iu_rv_iu6_t0_i0_gshare = rn_cp_iu6_t0_i0_gshare;
   assign iu_rv_iu6_t0_i0_ls_ptr = rn_cp_iu6_t0_i0_ls_ptr;
   assign iu_rv_iu6_t0_i0_t1_v = rn_cp_iu6_t0_i0_t1_v;
   assign iu_rv_iu6_t0_i0_t1_t = rn_cp_iu6_t0_i0_t1_t;
   assign iu_rv_iu6_t0_i0_t1_p = rn_cp_iu6_t0_i0_t1_p;
   assign iu_rv_iu6_t0_i0_t2_v = rn_cp_iu6_t0_i0_t2_v;
   assign iu_rv_iu6_t0_i0_t2_p = rn_cp_iu6_t0_i0_t2_p;
   assign iu_rv_iu6_t0_i0_t2_t = rn_cp_iu6_t0_i0_t2_t;
   assign iu_rv_iu6_t0_i0_t3_v = rn_cp_iu6_t0_i0_t3_v;
   assign iu_rv_iu6_t0_i0_t3_p = rn_cp_iu6_t0_i0_t3_p;
   assign iu_rv_iu6_t0_i0_t3_t = rn_cp_iu6_t0_i0_t3_t;
   assign iu_rv_iu6_t0_i0_bta_val = rn_cp_iu6_t0_i0_bta_val;
   assign iu_rv_iu6_t0_i1_vld = rn_cp_iu6_t0_i1_vld;
   assign iu_rv_iu6_t0_i1_itag = rn_cp_iu6_t0_i1_itag;
   assign iu_rv_iu6_t0_i1_ucode = rn_cp_iu6_t0_i1_ucode;
   assign iu_rv_iu6_t0_i1_rte_lq = rn_cp_iu6_t0_i1_rte_lq;
   assign iu_rv_iu6_t0_i1_rte_sq = rn_cp_iu6_t0_i1_rte_sq;
   assign iu_rv_iu6_t0_i1_rte_fx0 = rn_cp_iu6_t0_i1_rte_fx0;
   assign iu_rv_iu6_t0_i1_rte_fx1 = rn_cp_iu6_t0_i1_rte_fx1;
   assign iu_rv_iu6_t0_i1_rte_axu0 = rn_cp_iu6_t0_i1_rte_axu0;
   assign iu_rv_iu6_t0_i1_rte_axu1 = rn_cp_iu6_t0_i1_rte_axu1;
   assign iu_rv_iu6_t0_i1_instr = rn_cp_iu6_t0_i1_instr;
   assign iu_rv_iu6_t0_i1_ifar = rn_cp_iu6_t0_i1_ifar;
   assign iu_rv_iu6_t0_i1_bta = rn_cp_iu6_t0_i1_bta;
   assign iu_rv_iu6_t0_i1_br_pred = rn_cp_iu6_t0_i1_br_pred;
   assign iu_rv_iu6_t0_i1_bh_update = rn_cp_iu6_t0_i1_bh_update;
   assign iu_rv_iu6_t0_i1_gshare = rn_cp_iu6_t0_i1_gshare;
   assign iu_rv_iu6_t0_i1_ls_ptr = rn_cp_iu6_t0_i1_ls_ptr;
   assign iu_rv_iu6_t0_i1_t1_v = rn_cp_iu6_t0_i1_t1_v;
   assign iu_rv_iu6_t0_i1_t1_t = rn_cp_iu6_t0_i1_t1_t;
   assign iu_rv_iu6_t0_i1_t1_p = rn_cp_iu6_t0_i1_t1_p;
   assign iu_rv_iu6_t0_i1_t2_v = rn_cp_iu6_t0_i1_t2_v;
   assign iu_rv_iu6_t0_i1_t2_p = rn_cp_iu6_t0_i1_t2_p;
   assign iu_rv_iu6_t0_i1_t2_t = rn_cp_iu6_t0_i1_t2_t;
   assign iu_rv_iu6_t0_i1_t3_v = rn_cp_iu6_t0_i1_t3_v;
   assign iu_rv_iu6_t0_i1_t3_p = rn_cp_iu6_t0_i1_t3_p;
   assign iu_rv_iu6_t0_i1_t3_t = rn_cp_iu6_t0_i1_t3_t;
   assign iu_rv_iu6_t0_i1_bta_val = rn_cp_iu6_t0_i1_bta_val;
`ifndef THREADS1
   assign iu_rv_iu6_t1_i0_vld = rn_cp_iu6_t1_i0_vld;
   assign iu_rv_iu6_t1_i0_itag = rn_cp_iu6_t1_i0_itag;
   assign iu_rv_iu6_t1_i0_ucode = rn_cp_iu6_t1_i0_ucode;
   assign iu_rv_iu6_t1_i0_rte_lq = rn_cp_iu6_t1_i0_rte_lq;
   assign iu_rv_iu6_t1_i0_rte_sq = rn_cp_iu6_t1_i0_rte_sq;
   assign iu_rv_iu6_t1_i0_rte_fx0 = rn_cp_iu6_t1_i0_rte_fx0;
   assign iu_rv_iu6_t1_i0_rte_fx1 = rn_cp_iu6_t1_i0_rte_fx1;
   assign iu_rv_iu6_t1_i0_rte_axu0 = rn_cp_iu6_t1_i0_rte_axu0;
   assign iu_rv_iu6_t1_i0_rte_axu1 = rn_cp_iu6_t1_i0_rte_axu1;
   assign iu_rv_iu6_t1_i0_instr = rn_cp_iu6_t1_i0_instr;
   assign iu_rv_iu6_t1_i0_ifar = rn_cp_iu6_t1_i0_ifar;
   assign iu_rv_iu6_t1_i0_bta = rn_cp_iu6_t1_i0_bta;
   assign iu_rv_iu6_t1_i0_br_pred = rn_cp_iu6_t1_i0_br_pred;
   assign iu_rv_iu6_t1_i0_bh_update = rn_cp_iu6_t1_i0_bh_update;
   assign iu_rv_iu6_t1_i0_gshare = rn_cp_iu6_t1_i0_gshare;
   assign iu_rv_iu6_t1_i0_ls_ptr = rn_cp_iu6_t1_i0_ls_ptr;
   assign iu_rv_iu6_t1_i0_t1_v = rn_cp_iu6_t1_i0_t1_v;
   assign iu_rv_iu6_t1_i0_t1_t = rn_cp_iu6_t1_i0_t1_t;
   assign iu_rv_iu6_t1_i0_t1_p = rn_cp_iu6_t1_i0_t1_p;
   assign iu_rv_iu6_t1_i0_t2_v = rn_cp_iu6_t1_i0_t2_v;
   assign iu_rv_iu6_t1_i0_t2_p = rn_cp_iu6_t1_i0_t2_p;
   assign iu_rv_iu6_t1_i0_t2_t = rn_cp_iu6_t1_i0_t2_t;
   assign iu_rv_iu6_t1_i0_t3_v = rn_cp_iu6_t1_i0_t3_v;
   assign iu_rv_iu6_t1_i0_t3_p = rn_cp_iu6_t1_i0_t3_p;
   assign iu_rv_iu6_t1_i0_t3_t = rn_cp_iu6_t1_i0_t3_t;
   assign iu_rv_iu6_t1_i0_bta_val = rn_cp_iu6_t1_i0_bta_val;
   assign iu_rv_iu6_t1_i1_vld = rn_cp_iu6_t1_i1_vld;
   assign iu_rv_iu6_t1_i1_itag = rn_cp_iu6_t1_i1_itag;
   assign iu_rv_iu6_t1_i1_ucode = rn_cp_iu6_t1_i1_ucode;
   assign iu_rv_iu6_t1_i1_rte_lq = rn_cp_iu6_t1_i1_rte_lq;
   assign iu_rv_iu6_t1_i1_rte_sq = rn_cp_iu6_t1_i1_rte_sq;
   assign iu_rv_iu6_t1_i1_rte_fx0 = rn_cp_iu6_t1_i1_rte_fx0;
   assign iu_rv_iu6_t1_i1_rte_fx1 = rn_cp_iu6_t1_i1_rte_fx1;
   assign iu_rv_iu6_t1_i1_rte_axu0 = rn_cp_iu6_t1_i1_rte_axu0;
   assign iu_rv_iu6_t1_i1_rte_axu1 = rn_cp_iu6_t1_i1_rte_axu1;
   assign iu_rv_iu6_t1_i1_instr = rn_cp_iu6_t1_i1_instr;
   assign iu_rv_iu6_t1_i1_ifar = rn_cp_iu6_t1_i1_ifar;
   assign iu_rv_iu6_t1_i1_bta = rn_cp_iu6_t1_i1_bta;
   assign iu_rv_iu6_t1_i1_br_pred = rn_cp_iu6_t1_i1_br_pred;
   assign iu_rv_iu6_t1_i1_bh_update = rn_cp_iu6_t1_i1_bh_update;
   assign iu_rv_iu6_t1_i1_gshare = rn_cp_iu6_t1_i1_gshare;
   assign iu_rv_iu6_t1_i1_ls_ptr = rn_cp_iu6_t1_i1_ls_ptr;
   assign iu_rv_iu6_t1_i1_t1_v = rn_cp_iu6_t1_i1_t1_v;
   assign iu_rv_iu6_t1_i1_t1_t = rn_cp_iu6_t1_i1_t1_t;
   assign iu_rv_iu6_t1_i1_t1_p = rn_cp_iu6_t1_i1_t1_p;
   assign iu_rv_iu6_t1_i1_t2_v = rn_cp_iu6_t1_i1_t2_v;
   assign iu_rv_iu6_t1_i1_t2_p = rn_cp_iu6_t1_i1_t2_p;
   assign iu_rv_iu6_t1_i1_t2_t = rn_cp_iu6_t1_i1_t2_t;
   assign iu_rv_iu6_t1_i1_t3_v = rn_cp_iu6_t1_i1_t3_v;
   assign iu_rv_iu6_t1_i1_t3_p = rn_cp_iu6_t1_i1_t3_p;
   assign iu_rv_iu6_t1_i1_t3_t = rn_cp_iu6_t1_i1_t3_t;
   assign iu_rv_iu6_t1_i1_bta_val = rn_cp_iu6_t1_i1_bta_val;
`endif

   // FPSCR, update on completion.  Use t1 type, but no dependency
`ifdef THREADS1
   assign cp_axu_i1_t1_v = cp_rn_t0_i1_t1_v;
   assign cp_axu_i0_t1_v = cp_rn_t0_i0_t1_v;
`endif
`ifndef THREADS1
   assign cp_axu_i1_t1_v = {cp_rn_t0_i1_t1_v, cp_rn_t1_i1_t1_v};
   assign cp_axu_i0_t1_v = {cp_rn_t0_i0_t1_v, cp_rn_t1_i0_t1_v};
`endif
   assign cp_axu_t0_i0_t1_t = cp_rn_t0_i0_t1_t;
   assign cp_axu_t0_i0_t1_p = cp_rn_t0_i0_t1_p;
   assign cp_axu_t0_i1_t1_t = cp_rn_t0_i1_t1_t;
   assign cp_axu_t0_i1_t1_p = cp_rn_t0_i1_t1_p;
`ifndef THREADS1
   assign cp_axu_t1_i0_t1_t = cp_rn_t1_i0_t1_t;
   assign cp_axu_t1_i0_t1_p = cp_rn_t1_i0_t1_p;
   assign cp_axu_t1_i1_t1_t = cp_rn_t1_i1_t1_t;
   assign cp_axu_t1_i1_t1_p = cp_rn_t1_i1_t1_p;
`endif

   iuq_cpl_top iuq_cpl_top0(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .tc_ac_ccflush_dc(tc_ac_ccflush_dc),
      .clkoff_dc_b(clkoff_b),
      .d_mode_dc(d_mode),
      .delay_lclkr_dc(delay_lclkr),
      .mpw1_dc_b(mpw1_b),
      .mpw2_dc_b(mpw2_b),
      .pc_iu_func_sl_thold_2(pc_iu_func_sl_thold_2),
      .pc_iu_func_slp_sl_thold_2(pc_iu_func_slp_sl_thold_2),
      .pc_iu_sg_2(pc_iu_sg_2),
      .cp_scan_in(cp_scan_in),
      .cp_scan_out(cp_scan_out),
      .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
      .pc_iu_event_count_mode(pc_iu_event_count_mode),
      .spr_cp_perf_event_mux_ctrls(spr_cp_perf_event_mux_ctrls),
      .event_bus_in(event_bus_in[1]),
      .event_bus_out(event_bus_out[1]),
      .rn_cp_iu6_t0_i0_vld(rn_cp_iu6_t0_i0_vld),
      .rn_cp_iu6_t0_i0_itag(rn_cp_iu6_t0_i0_itag[1:`ITAG_SIZE_ENC-1]),
      .rn_cp_iu6_t0_i0_ucode(rn_cp_iu6_t0_i0_ucode),
      .rn_cp_iu6_t0_i0_fuse_nop(rn_cp_iu6_t0_i0_fuse_nop),
      .rn_cp_iu6_t0_i0_rte_lq(rn_cp_iu6_t0_i0_rte_lq),
      .rn_cp_iu6_t0_i0_rte_sq(rn_cp_iu6_t0_i0_rte_sq),
      .rn_cp_iu6_t0_i0_rte_fx0(rn_cp_iu6_t0_i0_rte_fx0),
      .rn_cp_iu6_t0_i0_rte_fx1(rn_cp_iu6_t0_i0_rte_fx1),
      .rn_cp_iu6_t0_i0_rte_axu0(rn_cp_iu6_t0_i0_rte_axu0),
      .rn_cp_iu6_t0_i0_rte_axu1(rn_cp_iu6_t0_i0_rte_axu1),
      .rn_cp_iu6_t0_i0_ifar(rn_cp_iu6_t0_i0_ifar),
      .rn_cp_iu6_t0_i0_bta(rn_cp_iu6_t0_i0_bta),
      .rn_cp_iu6_t0_i0_isram(rn_cp_iu6_t0_i0_isram),
      .rn_cp_iu6_t0_i0_instr(rn_cp_iu6_t0_i0_instr),
      .rn_cp_iu6_t0_i0_valop(rn_cp_iu6_t0_i0_valop),
      .rn_cp_iu6_t0_i0_error(rn_cp_iu6_t0_i0_error),
      .rn_cp_iu6_t0_i0_br_pred(rn_cp_iu6_t0_i0_br_pred),
      .rn_cp_iu6_t0_i0_bh_update(rn_cp_iu6_t0_i0_bh_update),
      .rn_cp_iu6_t0_i0_bh0_hist(rn_cp_iu6_t0_i0_bh0_hist),
      .rn_cp_iu6_t0_i0_bh1_hist(rn_cp_iu6_t0_i0_bh1_hist),
      .rn_cp_iu6_t0_i0_bh2_hist(rn_cp_iu6_t0_i0_bh2_hist),
      .rn_cp_iu6_t0_i0_gshare(rn_cp_iu6_t0_i0_gshare[0:9]),
      .rn_cp_iu6_t0_i0_ls_ptr(rn_cp_iu6_t0_i0_ls_ptr),
      .rn_cp_iu6_t0_i0_match(rn_cp_iu6_t0_i0_match),
      .rn_cp_iu6_t0_i0_type_fp(rn_cp_iu6_t0_i0_type_fp),
      .rn_cp_iu6_t0_i0_type_ap(rn_cp_iu6_t0_i0_type_ap),
      .rn_cp_iu6_t0_i0_type_spv(rn_cp_iu6_t0_i0_type_spv),
      .rn_cp_iu6_t0_i0_type_st(rn_cp_iu6_t0_i0_type_st),
      .rn_cp_iu6_t0_i0_async_block(rn_cp_iu6_t0_i0_async_block),
      .rn_cp_iu6_t0_i0_np1_flush(rn_cp_iu6_t0_i0_np1_flush),
      .rn_cp_iu6_t0_i0_t1_v(rn_cp_iu6_t0_i0_t1_v),
      .rn_cp_iu6_t0_i0_t1_t(rn_cp_iu6_t0_i0_t1_t),
      .rn_cp_iu6_t0_i0_t1_p(rn_cp_iu6_t0_i0_t1_p),
      .rn_cp_iu6_t0_i0_t1_a(rn_cp_iu6_t0_i0_t1_a),
      .rn_cp_iu6_t0_i0_t2_v(rn_cp_iu6_t0_i0_t2_v),
      .rn_cp_iu6_t0_i0_t2_t(rn_cp_iu6_t0_i0_t2_t),
      .rn_cp_iu6_t0_i0_t2_p(rn_cp_iu6_t0_i0_t2_p),
      .rn_cp_iu6_t0_i0_t2_a(rn_cp_iu6_t0_i0_t2_a),
      .rn_cp_iu6_t0_i0_t3_v(rn_cp_iu6_t0_i0_t3_v),
      .rn_cp_iu6_t0_i0_t3_t(rn_cp_iu6_t0_i0_t3_t),
      .rn_cp_iu6_t0_i0_t3_p(rn_cp_iu6_t0_i0_t3_p),
      .rn_cp_iu6_t0_i0_t3_a(rn_cp_iu6_t0_i0_t3_a),
      .rn_cp_iu6_t0_i0_btb_entry(rn_cp_iu6_t0_i0_btb_entry),
      .rn_cp_iu6_t0_i0_btb_hist(rn_cp_iu6_t0_i0_btb_hist),
      .rn_cp_iu6_t0_i0_bta_val(rn_cp_iu6_t0_i0_bta_val),
      .rn_cp_iu6_t0_i1_vld(rn_cp_iu6_t0_i1_vld),
      .rn_cp_iu6_t0_i1_itag(rn_cp_iu6_t0_i1_itag[1:`ITAG_SIZE_ENC-1]),
      .rn_cp_iu6_t0_i1_ucode(rn_cp_iu6_t0_i1_ucode),
      .rn_cp_iu6_t0_i1_fuse_nop(rn_cp_iu6_t0_i1_fuse_nop),
      .rn_cp_iu6_t0_i1_rte_lq(rn_cp_iu6_t0_i1_rte_lq),
      .rn_cp_iu6_t0_i1_rte_sq(rn_cp_iu6_t0_i1_rte_sq),
      .rn_cp_iu6_t0_i1_rte_fx0(rn_cp_iu6_t0_i1_rte_fx0),
      .rn_cp_iu6_t0_i1_rte_fx1(rn_cp_iu6_t0_i1_rte_fx1),
      .rn_cp_iu6_t0_i1_rte_axu0(rn_cp_iu6_t0_i1_rte_axu0),
      .rn_cp_iu6_t0_i1_rte_axu1(rn_cp_iu6_t0_i1_rte_axu1),
      .rn_cp_iu6_t0_i1_ifar(rn_cp_iu6_t0_i1_ifar),
      .rn_cp_iu6_t0_i1_bta(rn_cp_iu6_t0_i1_bta),
      .rn_cp_iu6_t0_i1_isram(rn_cp_iu6_t0_i1_isram),
      .rn_cp_iu6_t0_i1_instr(rn_cp_iu6_t0_i1_instr),
      .rn_cp_iu6_t0_i1_valop(rn_cp_iu6_t0_i1_valop),
      .rn_cp_iu6_t0_i1_error(rn_cp_iu6_t0_i1_error),
      .rn_cp_iu6_t0_i1_br_pred(rn_cp_iu6_t0_i1_br_pred),
      .rn_cp_iu6_t0_i1_bh_update(rn_cp_iu6_t0_i1_bh_update),
      .rn_cp_iu6_t0_i1_bh0_hist(rn_cp_iu6_t0_i1_bh0_hist),
      .rn_cp_iu6_t0_i1_bh1_hist(rn_cp_iu6_t0_i1_bh1_hist),
      .rn_cp_iu6_t0_i1_bh2_hist(rn_cp_iu6_t0_i1_bh2_hist),
      .rn_cp_iu6_t0_i1_gshare(rn_cp_iu6_t0_i1_gshare[0:9]),
      .rn_cp_iu6_t0_i1_ls_ptr(rn_cp_iu6_t0_i1_ls_ptr),
      .rn_cp_iu6_t0_i1_match(rn_cp_iu6_t0_i1_match),
      .rn_cp_iu6_t0_i1_type_fp(rn_cp_iu6_t0_i1_type_fp),
      .rn_cp_iu6_t0_i1_type_ap(rn_cp_iu6_t0_i1_type_ap),
      .rn_cp_iu6_t0_i1_type_spv(rn_cp_iu6_t0_i1_type_spv),
      .rn_cp_iu6_t0_i1_type_st(rn_cp_iu6_t0_i1_type_st),
      .rn_cp_iu6_t0_i1_async_block(rn_cp_iu6_t0_i1_async_block),
      .rn_cp_iu6_t0_i1_np1_flush(rn_cp_iu6_t0_i1_np1_flush),
      .rn_cp_iu6_t0_i1_t1_v(rn_cp_iu6_t0_i1_t1_v),
      .rn_cp_iu6_t0_i1_t1_t(rn_cp_iu6_t0_i1_t1_t),
      .rn_cp_iu6_t0_i1_t1_p(rn_cp_iu6_t0_i1_t1_p),
      .rn_cp_iu6_t0_i1_t1_a(rn_cp_iu6_t0_i1_t1_a),
      .rn_cp_iu6_t0_i1_t2_v(rn_cp_iu6_t0_i1_t2_v),
      .rn_cp_iu6_t0_i1_t2_t(rn_cp_iu6_t0_i1_t2_t),
      .rn_cp_iu6_t0_i1_t2_p(rn_cp_iu6_t0_i1_t2_p),
      .rn_cp_iu6_t0_i1_t2_a(rn_cp_iu6_t0_i1_t2_a),
      .rn_cp_iu6_t0_i1_t3_v(rn_cp_iu6_t0_i1_t3_v),
      .rn_cp_iu6_t0_i1_t3_t(rn_cp_iu6_t0_i1_t3_t),
      .rn_cp_iu6_t0_i1_t3_p(rn_cp_iu6_t0_i1_t3_p),
      .rn_cp_iu6_t0_i1_t3_a(rn_cp_iu6_t0_i1_t3_a),
      .rn_cp_iu6_t0_i1_btb_entry(rn_cp_iu6_t0_i1_btb_entry),
      .rn_cp_iu6_t0_i1_btb_hist(rn_cp_iu6_t0_i1_btb_hist),
      .rn_cp_iu6_t0_i1_bta_val(rn_cp_iu6_t0_i1_bta_val),
`ifndef THREADS1
      .rn_cp_iu6_t1_i0_vld(rn_cp_iu6_t1_i0_vld),
      .rn_cp_iu6_t1_i0_itag(rn_cp_iu6_t1_i0_itag[1:`ITAG_SIZE_ENC-1]),
      .rn_cp_iu6_t1_i0_ucode(rn_cp_iu6_t1_i0_ucode),
      .rn_cp_iu6_t1_i0_fuse_nop(rn_cp_iu6_t1_i0_fuse_nop),
      .rn_cp_iu6_t1_i0_rte_lq(rn_cp_iu6_t1_i0_rte_lq),
      .rn_cp_iu6_t1_i0_rte_sq(rn_cp_iu6_t1_i0_rte_sq),
      .rn_cp_iu6_t1_i0_rte_fx0(rn_cp_iu6_t1_i0_rte_fx0),
      .rn_cp_iu6_t1_i0_rte_fx1(rn_cp_iu6_t1_i0_rte_fx1),
      .rn_cp_iu6_t1_i0_rte_axu0(rn_cp_iu6_t1_i0_rte_axu0),
      .rn_cp_iu6_t1_i0_rte_axu1(rn_cp_iu6_t1_i0_rte_axu1),
      .rn_cp_iu6_t1_i0_ifar(rn_cp_iu6_t1_i0_ifar),
      .rn_cp_iu6_t1_i0_bta(rn_cp_iu6_t1_i0_bta),
      .rn_cp_iu6_t1_i0_isram(rn_cp_iu6_t1_i0_isram),
      .rn_cp_iu6_t1_i0_instr(rn_cp_iu6_t1_i0_instr),
      .rn_cp_iu6_t1_i0_valop(rn_cp_iu6_t1_i0_valop),
      .rn_cp_iu6_t1_i0_error(rn_cp_iu6_t1_i0_error),
      .rn_cp_iu6_t1_i0_br_pred(rn_cp_iu6_t1_i0_br_pred),
      .rn_cp_iu6_t1_i0_bh_update(rn_cp_iu6_t1_i0_bh_update),
      .rn_cp_iu6_t1_i0_bh0_hist(rn_cp_iu6_t1_i0_bh0_hist),
      .rn_cp_iu6_t1_i0_bh1_hist(rn_cp_iu6_t1_i0_bh1_hist),
      .rn_cp_iu6_t1_i0_bh2_hist(rn_cp_iu6_t1_i0_bh2_hist),
      .rn_cp_iu6_t1_i0_gshare(rn_cp_iu6_t1_i0_gshare[0:9]),
      .rn_cp_iu6_t1_i0_ls_ptr(rn_cp_iu6_t1_i0_ls_ptr),
      .rn_cp_iu6_t1_i0_match(rn_cp_iu6_t1_i0_match),
      .rn_cp_iu6_t1_i0_type_fp(rn_cp_iu6_t1_i0_type_fp),
      .rn_cp_iu6_t1_i0_type_ap(rn_cp_iu6_t1_i0_type_ap),
      .rn_cp_iu6_t1_i0_type_spv(rn_cp_iu6_t1_i0_type_spv),
      .rn_cp_iu6_t1_i0_type_st(rn_cp_iu6_t1_i0_type_st),
      .rn_cp_iu6_t1_i0_async_block(rn_cp_iu6_t1_i0_async_block),
      .rn_cp_iu6_t1_i0_np1_flush(rn_cp_iu6_t1_i0_np1_flush),
      .rn_cp_iu6_t1_i0_t1_v(rn_cp_iu6_t1_i0_t1_v),
      .rn_cp_iu6_t1_i0_t1_t(rn_cp_iu6_t1_i0_t1_t),
      .rn_cp_iu6_t1_i0_t1_p(rn_cp_iu6_t1_i0_t1_p),
      .rn_cp_iu6_t1_i0_t1_a(rn_cp_iu6_t1_i0_t1_a),
      .rn_cp_iu6_t1_i0_t2_v(rn_cp_iu6_t1_i0_t2_v),
      .rn_cp_iu6_t1_i0_t2_t(rn_cp_iu6_t1_i0_t2_t),
      .rn_cp_iu6_t1_i0_t2_p(rn_cp_iu6_t1_i0_t2_p),
      .rn_cp_iu6_t1_i0_t2_a(rn_cp_iu6_t1_i0_t2_a),
      .rn_cp_iu6_t1_i0_t3_v(rn_cp_iu6_t1_i0_t3_v),
      .rn_cp_iu6_t1_i0_t3_t(rn_cp_iu6_t1_i0_t3_t),
      .rn_cp_iu6_t1_i0_t3_p(rn_cp_iu6_t1_i0_t3_p),
      .rn_cp_iu6_t1_i0_t3_a(rn_cp_iu6_t1_i0_t3_a),
      .rn_cp_iu6_t1_i0_btb_entry(rn_cp_iu6_t1_i0_btb_entry),
      .rn_cp_iu6_t1_i0_btb_hist(rn_cp_iu6_t1_i0_btb_hist),
      .rn_cp_iu6_t1_i0_bta_val(rn_cp_iu6_t1_i0_bta_val),
      .rn_cp_iu6_t1_i1_vld(rn_cp_iu6_t1_i1_vld),
      .rn_cp_iu6_t1_i1_itag(rn_cp_iu6_t1_i1_itag[1:`ITAG_SIZE_ENC-1]),
      .rn_cp_iu6_t1_i1_ucode(rn_cp_iu6_t1_i1_ucode),
      .rn_cp_iu6_t1_i1_fuse_nop(rn_cp_iu6_t1_i1_fuse_nop),
      .rn_cp_iu6_t1_i1_rte_lq(rn_cp_iu6_t1_i1_rte_lq),
      .rn_cp_iu6_t1_i1_rte_sq(rn_cp_iu6_t1_i1_rte_sq),
      .rn_cp_iu6_t1_i1_rte_fx0(rn_cp_iu6_t1_i1_rte_fx0),
      .rn_cp_iu6_t1_i1_rte_fx1(rn_cp_iu6_t1_i1_rte_fx1),
      .rn_cp_iu6_t1_i1_rte_axu0(rn_cp_iu6_t1_i1_rte_axu0),
      .rn_cp_iu6_t1_i1_rte_axu1(rn_cp_iu6_t1_i1_rte_axu1),
      .rn_cp_iu6_t1_i1_ifar(rn_cp_iu6_t1_i1_ifar),
      .rn_cp_iu6_t1_i1_bta(rn_cp_iu6_t1_i1_bta),
      .rn_cp_iu6_t1_i1_isram(rn_cp_iu6_t1_i1_isram),
      .rn_cp_iu6_t1_i1_instr(rn_cp_iu6_t1_i1_instr),
      .rn_cp_iu6_t1_i1_valop(rn_cp_iu6_t1_i1_valop),
      .rn_cp_iu6_t1_i1_error(rn_cp_iu6_t1_i1_error),
      .rn_cp_iu6_t1_i1_br_pred(rn_cp_iu6_t1_i1_br_pred),
      .rn_cp_iu6_t1_i1_bh_update(rn_cp_iu6_t1_i1_bh_update),
      .rn_cp_iu6_t1_i1_bh0_hist(rn_cp_iu6_t1_i1_bh0_hist),
      .rn_cp_iu6_t1_i1_bh1_hist(rn_cp_iu6_t1_i1_bh1_hist),
      .rn_cp_iu6_t1_i1_bh2_hist(rn_cp_iu6_t1_i1_bh2_hist),
      .rn_cp_iu6_t1_i1_gshare(rn_cp_iu6_t1_i1_gshare[0:9]),
      .rn_cp_iu6_t1_i1_ls_ptr(rn_cp_iu6_t1_i1_ls_ptr),
      .rn_cp_iu6_t1_i1_match(rn_cp_iu6_t1_i1_match),
      .rn_cp_iu6_t1_i1_type_fp(rn_cp_iu6_t1_i1_type_fp),
      .rn_cp_iu6_t1_i1_type_ap(rn_cp_iu6_t1_i1_type_ap),
      .rn_cp_iu6_t1_i1_type_spv(rn_cp_iu6_t1_i1_type_spv),
      .rn_cp_iu6_t1_i1_type_st(rn_cp_iu6_t1_i1_type_st),
      .rn_cp_iu6_t1_i1_async_block(rn_cp_iu6_t1_i1_async_block),
      .rn_cp_iu6_t1_i1_np1_flush(rn_cp_iu6_t1_i1_np1_flush),
      .rn_cp_iu6_t1_i1_t1_v(rn_cp_iu6_t1_i1_t1_v),
      .rn_cp_iu6_t1_i1_t1_t(rn_cp_iu6_t1_i1_t1_t),
      .rn_cp_iu6_t1_i1_t1_p(rn_cp_iu6_t1_i1_t1_p),
      .rn_cp_iu6_t1_i1_t1_a(rn_cp_iu6_t1_i1_t1_a),
      .rn_cp_iu6_t1_i1_t2_v(rn_cp_iu6_t1_i1_t2_v),
      .rn_cp_iu6_t1_i1_t2_t(rn_cp_iu6_t1_i1_t2_t),
      .rn_cp_iu6_t1_i1_t2_p(rn_cp_iu6_t1_i1_t2_p),
      .rn_cp_iu6_t1_i1_t2_a(rn_cp_iu6_t1_i1_t2_a),
      .rn_cp_iu6_t1_i1_t3_v(rn_cp_iu6_t1_i1_t3_v),
      .rn_cp_iu6_t1_i1_t3_t(rn_cp_iu6_t1_i1_t3_t),
      .rn_cp_iu6_t1_i1_t3_p(rn_cp_iu6_t1_i1_t3_p),
      .rn_cp_iu6_t1_i1_t3_a(rn_cp_iu6_t1_i1_t3_a),
      .rn_cp_iu6_t1_i1_btb_entry(rn_cp_iu6_t1_i1_btb_entry),
      .rn_cp_iu6_t1_i1_btb_hist(rn_cp_iu6_t1_i1_btb_hist),
      .rn_cp_iu6_t1_i1_bta_val(rn_cp_iu6_t1_i1_bta_val),
`endif
      .cp_rn_empty(cp_rn_empty),
      .cp_async_block(cp_async_block),
      .cp_rn_t0_i0_v(cp_rn_t0_i0_v),
      .cp_rn_t0_i0_axu_exception_val(cp_rn_t0_i0_axu_exception_val),
      .cp_rn_t0_i0_axu_exception(cp_rn_t0_i0_axu_exception),
      .cp_rn_t0_i0_t1_v(cp_rn_t0_i0_t1_v),
      .cp_rn_t0_i0_t1_t(cp_rn_t0_i0_t1_t),
      .cp_rn_t0_i0_t1_p(cp_rn_t0_i0_t1_p),
      .cp_rn_t0_i0_t1_a(cp_rn_t0_i0_t1_a),
      .cp_rn_t0_i0_t2_v(cp_rn_t0_i0_t2_v),
      .cp_rn_t0_i0_t2_t(cp_rn_t0_i0_t2_t),
      .cp_rn_t0_i0_t2_p(cp_rn_t0_i0_t2_p),
      .cp_rn_t0_i0_t2_a(cp_rn_t0_i0_t2_a),
      .cp_rn_t0_i0_t3_v(cp_rn_t0_i0_t3_v),
      .cp_rn_t0_i0_t3_t(cp_rn_t0_i0_t3_t),
      .cp_rn_t0_i0_t3_p(cp_rn_t0_i0_t3_p),
      .cp_rn_t0_i0_t3_a(cp_rn_t0_i0_t3_a),
      .cp_rn_t0_i1_v(cp_rn_t0_i1_v),
      .cp_rn_t0_i1_axu_exception_val(cp_rn_t0_i1_axu_exception_val),
      .cp_rn_t0_i1_axu_exception(cp_rn_t0_i1_axu_exception),
      .cp_rn_t0_i1_t1_v(cp_rn_t0_i1_t1_v),
      .cp_rn_t0_i1_t1_t(cp_rn_t0_i1_t1_t),
      .cp_rn_t0_i1_t1_p(cp_rn_t0_i1_t1_p),
      .cp_rn_t0_i1_t1_a(cp_rn_t0_i1_t1_a),
      .cp_rn_t0_i1_t2_v(cp_rn_t0_i1_t2_v),
      .cp_rn_t0_i1_t2_t(cp_rn_t0_i1_t2_t),
      .cp_rn_t0_i1_t2_p(cp_rn_t0_i1_t2_p),
      .cp_rn_t0_i1_t2_a(cp_rn_t0_i1_t2_a),
      .cp_rn_t0_i1_t3_v(cp_rn_t0_i1_t3_v),
      .cp_rn_t0_i1_t3_t(cp_rn_t0_i1_t3_t),
      .cp_rn_t0_i1_t3_p(cp_rn_t0_i1_t3_p),
      .cp_rn_t0_i1_t3_a(cp_rn_t0_i1_t3_a),
`ifndef THREADS1
		.cp_rn_t1_i0_v(cp_rn_t1_i0_v),
      .cp_rn_t1_i0_axu_exception_val(cp_rn_t1_i0_axu_exception_val),
      .cp_rn_t1_i0_axu_exception(cp_rn_t1_i0_axu_exception),
      .cp_rn_t1_i0_t1_v(cp_rn_t1_i0_t1_v),
      .cp_rn_t1_i0_t1_t(cp_rn_t1_i0_t1_t),
      .cp_rn_t1_i0_t1_p(cp_rn_t1_i0_t1_p),
      .cp_rn_t1_i0_t1_a(cp_rn_t1_i0_t1_a),
      .cp_rn_t1_i0_t2_v(cp_rn_t1_i0_t2_v),
      .cp_rn_t1_i0_t2_t(cp_rn_t1_i0_t2_t),
      .cp_rn_t1_i0_t2_p(cp_rn_t1_i0_t2_p),
      .cp_rn_t1_i0_t2_a(cp_rn_t1_i0_t2_a),
      .cp_rn_t1_i0_t3_v(cp_rn_t1_i0_t3_v),
      .cp_rn_t1_i0_t3_t(cp_rn_t1_i0_t3_t),
      .cp_rn_t1_i0_t3_p(cp_rn_t1_i0_t3_p),
      .cp_rn_t1_i0_t3_a(cp_rn_t1_i0_t3_a),
      .cp_rn_t1_i1_v(cp_rn_t1_i1_v),
      .cp_rn_t1_i1_axu_exception_val(cp_rn_t1_i1_axu_exception_val),
      .cp_rn_t1_i1_axu_exception(cp_rn_t1_i1_axu_exception),
      .cp_rn_t1_i1_t1_v(cp_rn_t1_i1_t1_v),
      .cp_rn_t1_i1_t1_t(cp_rn_t1_i1_t1_t),
      .cp_rn_t1_i1_t1_p(cp_rn_t1_i1_t1_p),
      .cp_rn_t1_i1_t1_a(cp_rn_t1_i1_t1_a),
      .cp_rn_t1_i1_t2_v(cp_rn_t1_i1_t2_v),
      .cp_rn_t1_i1_t2_t(cp_rn_t1_i1_t2_t),
      .cp_rn_t1_i1_t2_p(cp_rn_t1_i1_t2_p),
      .cp_rn_t1_i1_t2_a(cp_rn_t1_i1_t2_a),
      .cp_rn_t1_i1_t3_v(cp_rn_t1_i1_t3_v),
      .cp_rn_t1_i1_t3_t(cp_rn_t1_i1_t3_t),
      .cp_rn_t1_i1_t3_p(cp_rn_t1_i1_t3_p),
      .cp_rn_t1_i1_t3_a(cp_rn_t1_i1_t3_a),
`endif
      .cp_bp_t0_val(cp_bp_val[0]),
      .cp_bp_t0_ifar(cp_bp_t0_ifar),
      .cp_bp_t0_bh0_hist(cp_bp_t0_bh0_hist),
      .cp_bp_t0_bh1_hist(cp_bp_t0_bh1_hist),
      .cp_bp_t0_bh2_hist(cp_bp_t0_bh2_hist),
      .cp_bp_t0_br_pred(cp_bp_br_pred[0]),
      .cp_bp_t0_br_taken(cp_bp_br_taken[0]),
      .cp_bp_t0_bh_update(cp_bp_bh_update[0]),
      .cp_bp_t0_bcctr(cp_bp_bcctr[0]),
      .cp_bp_t0_bclr(cp_bp_bclr[0]),
      .cp_bp_t0_getnia(cp_bp_getNIA[0]),
      .cp_bp_t0_group(cp_bp_group[0]),
      .cp_bp_t0_lk(cp_bp_lk[0]),
      .cp_bp_t0_bh(cp_bp_t0_bh),
      .cp_bp_t0_gshare(cp_bp_t0_gshare),
      .cp_bp_t0_ls_ptr(cp_bp_t0_ls_ptr),
      .cp_bp_t0_ctr(cp_bp_t0_ctr),
      .cp_bp_t0_btb_entry(cp_bp_btb_entry[0]),
      .cp_bp_t0_btb_hist(cp_bp_t0_btb_hist),
`ifndef THREADS1
      .cp_bp_t1_val(cp_bp_val[1]),
      .cp_bp_t1_ifar(cp_bp_t1_ifar),
      .cp_bp_t1_bh0_hist(cp_bp_t1_bh0_hist),
      .cp_bp_t1_bh1_hist(cp_bp_t1_bh1_hist),
      .cp_bp_t1_bh2_hist(cp_bp_t1_bh2_hist),
      .cp_bp_t1_br_pred(cp_bp_br_pred[1]),
      .cp_bp_t1_br_taken(cp_bp_br_taken[1]),
      .cp_bp_t1_bh_update(cp_bp_bh_update[1]),
      .cp_bp_t1_bcctr(cp_bp_bcctr[1]),
      .cp_bp_t1_bclr(cp_bp_bclr[1]),
      .cp_bp_t1_getnia(cp_bp_getNIA[1]),
      .cp_bp_t1_group(cp_bp_group[1]),
      .cp_bp_t1_lk(cp_bp_lk[1]),
      .cp_bp_t1_bh(cp_bp_t1_bh),
      .cp_bp_t1_gshare(cp_bp_t1_gshare),
      .cp_bp_t1_ls_ptr(cp_bp_t1_ls_ptr),
      .cp_bp_t1_ctr(cp_bp_t1_ctr),
      .cp_bp_t1_btb_entry(cp_bp_btb_entry[1]),
      .cp_bp_t1_btb_hist(cp_bp_t1_btb_hist),
`endif
      .cp_dis_ivax(cp_dis_ivax),
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
      .iu_lq_i1_completed(iu_lq_i1_completed),
      .iu_lq_t0_i0_completed_itag(iu_lq_t0_i0_completed_itag_int),
      .iu_lq_t0_i1_completed_itag(iu_lq_t0_i1_completed_itag_int),
`ifndef THREADS1
      .iu_lq_t1_i0_completed_itag(iu_lq_t1_i0_completed_itag_int),
      .iu_lq_t1_i1_completed_itag(iu_lq_t1_i1_completed_itag_int),
`endif
      .iu_lq_recirc_val(iu_lq_recirc_val),
      .br_iu_execute_vld(br_iu_execute_vld),
      .br_iu_itag(br_iu_itag),
      .br_iu_bta(br_iu_bta),
      .br_iu_redirect(br_iu_redirect),
      .br_iu_taken(br_iu_taken),
      .br_iu_perf_events(br_iu_perf_events),
      .xu_iu_execute_vld(xu_iu_execute_vld),
      .xu_iu_itag(xu_iu_itag),
      .xu_iu_exception_val(xu_iu_exception_val),
      .xu_iu_exception(xu_iu_exception),
      .xu_iu_mtiar(xu_iu_mtiar),
      .xu_iu_bta(xu_iu_bta),
      .xu_iu_perf_events(xu_iu_perf_events),
      .xu_iu_n_flush(xu_iu_n_flush),
      .xu_iu_np1_flush(xu_iu_np1_flush),
      .xu_iu_flush2ucode(xu_iu_flush2ucode),
      .xu1_iu_execute_vld(xu1_iu_execute_vld),
      .xu1_iu_itag(xu1_iu_itag),
      .axu0_iu_execute_vld(axu0_iu_execute_vld),
      .axu0_iu_itag(axu0_iu_itag),
      .axu0_iu_n_flush(axu0_iu_n_flush),
      .axu0_iu_np1_flush(axu0_iu_np1_flush),
      .axu0_iu_n_np1_flush(axu0_iu_n_np1_flush),
      .axu0_iu_exception(axu0_iu_exception),
      .axu0_iu_exception_val(axu0_iu_exception_val),
      .axu0_iu_flush2ucode(axu0_iu_flush2ucode),
      .axu0_iu_flush2ucode_type(axu0_iu_flush2ucode_type),
      .axu0_iu_async_fex(axu0_iu_async_fex),
      .axu0_iu_perf_events(axu0_iu_perf_events),
      .axu1_iu_execute_vld(axu1_iu_execute_vld),
      .axu1_iu_itag(axu1_iu_itag),
      .axu1_iu_n_flush(axu1_iu_n_flush),
      .axu1_iu_np1_flush(axu1_iu_np1_flush),
      .axu1_iu_exception(axu1_iu_exception),
      .axu1_iu_exception_val(axu1_iu_exception_val),
      .axu1_iu_flush2ucode(axu1_iu_flush2ucode),
      .axu1_iu_flush2ucode_type(axu1_iu_flush2ucode_type),
      .axu1_iu_perf_events(axu1_iu_perf_events),
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
      .xu_iu_t0_rest_ifar(xu_iu_t0_rest_ifar),
`ifndef THREADS1
		.xu_iu_t1_rest_ifar(xu_iu_t1_rest_ifar),
`endif
      .cp_is_isync(cp_ic_is_isync),
      .cp_is_csync(cp_ic_is_csync),
      .iu_flush(iu_flush),
      .cp_flush_into_uc(cp_flush_into_uc),
      .cp_uc_t0_flush_ifar(cp_uc_t0_flush_ifar),
`ifndef THREADS1
      .cp_uc_t1_flush_ifar(cp_uc_t1_flush_ifar),
`endif
      .cp_uc_np1_flush(cp_uc_np1_flush),
      .cp_flush(cp_flush_internal),
      .cp_t0_next_itag(cp_t0_next_itag),
      .cp_t0_flush_itag(cp_t0_flush_itag),
      .cp_t0_flush_ifar(cp_t0_flush_ifar_internal),
`ifndef THREADS1
      .cp_t1_next_itag(cp_t1_next_itag),
      .cp_t1_flush_itag(cp_t1_flush_itag),
      .cp_t1_flush_ifar(cp_t1_flush_ifar_internal),
`endif
      .cp_iu0_flush_2ucode(cp_iu0_flush_2ucode),
      .cp_iu0_flush_2ucode_type(cp_iu0_flush_2ucode_type),
      .cp_iu0_flush_nonspec(cp_iu0_flush_nonspec),
      .pc_iu_init_reset(pc_iu_init_reset),
      .cp_rn_uc_credit_free(cp_rn_uc_credit_free),
      .iu_xu_rfi(iu_xu_rfi),
      .iu_xu_rfgi(iu_xu_rfgi),
      .iu_xu_rfci(iu_xu_rfci),
      .iu_xu_rfmci(iu_xu_rfmci),
      .iu_xu_int(iu_xu_int),
      .iu_xu_gint(iu_xu_gint),
      .iu_xu_cint(iu_xu_cint),
      .iu_xu_mcint(iu_xu_mcint),
      .iu_xu_dear_update(iu_xu_dear_update),
      .iu_spr_eheir_update(iu_spr_eheir_update),
      .iu_xu_t0_nia(iu_xu_t0_nia),
      .iu_xu_t0_esr(iu_xu_t0_esr),
      .iu_xu_t0_mcsr(iu_xu_t0_mcsr),
      .iu_xu_t0_dbsr(iu_xu_t0_dbsr),
      .iu_xu_t0_dear(iu_xu_t0_dear),
      .iu_spr_t0_eheir(iu_spr_t0_eheir),
      .xu_iu_t0_dbcr0_dac1(xu_iu_t0_dbcr0_dac1),
      .xu_iu_t0_dbcr0_dac2(xu_iu_t0_dbcr0_dac2),
      .xu_iu_t0_dbcr0_dac3(xu_iu_t0_dbcr0_dac3),
      .xu_iu_t0_dbcr0_dac4(xu_iu_t0_dbcr0_dac4),
`ifndef THREADS1
      .iu_xu_t1_nia(iu_xu_t1_nia),
      .iu_xu_t1_esr(iu_xu_t1_esr),
      .iu_xu_t1_mcsr(iu_xu_t1_mcsr),
      .iu_xu_t1_dbsr(iu_xu_t1_dbsr),
      .iu_xu_t1_dear(iu_xu_t1_dear),
      .iu_spr_t1_eheir(iu_spr_t1_eheir),
      .xu_iu_t1_dbcr0_dac1(xu_iu_t1_dbcr0_dac1),
      .xu_iu_t1_dbcr0_dac2(xu_iu_t1_dbcr0_dac2),
      .xu_iu_t1_dbcr0_dac3(xu_iu_t1_dbcr0_dac3),
      .xu_iu_t1_dbcr0_dac4(xu_iu_t1_dbcr0_dac4),
`endif
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
      .iu_mm_bus_snoop_hold_ack(iu_mm_bus_snoop_hold_ack_int),
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
      .xu_iu_spr_ccr2_en_dcr(xu_iu_spr_ccr2_en_dcr),
      .xu_iu_spr_ccr2_ucode_dis(xu_iu_spr_ccr2_ucode_dis),
      .xu_iu_hid_mmu_mode(xu_iu_hid_mmu_mode),
      .xu_iu_xucr4_mmu_mchk(xu_iu_xucr4_mmu_mchk),
      .iu_xu_quiesce(iu_xu_quiesce),
      .iu_pc_quiesce(iu_pc_quiesce),
      .mm_iu_ierat_rel_val(mm_iu_ierat_rel_val[0:`THREADS - 1]),
      .mm_iu_ierat_pt_fault(mm_iu_ierat_pt_fault),
      .mm_iu_ierat_lrat_miss(mm_iu_ierat_lrat_miss),
      .mm_iu_ierat_tlb_inelig(mm_iu_ierat_tlb_inelig),
      .mm_iu_tlb_multihit_err(mm_iu_tlb_multihit_err),
      .mm_iu_tlb_par_err(mm_iu_tlb_par_err),
      .mm_iu_lru_par_err(mm_iu_lru_par_err),
      .mm_iu_tlb_miss(mm_iu_tlb_miss),
      .mm_iu_reload_hit(mm_iu_reload_hit),
      .mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1[3:4]),
      .ic_cp_nonspec_hit(ic_cp_nonspec_hit),
      .cp_mm_except_taken_t0(cp_mm_except_taken_t0),
   `ifndef THREADS1
      .cp_mm_except_taken_t1(cp_mm_except_taken_t1),
   `endif
      .xu_iu_single_instr_mode(xu_iu_single_instr_mode),
      .spr_single_issue(spr_single_issue),
      .spr_ivpr(spr_ivpr),
      .spr_givpr(spr_givpr),
      .spr_iac1(spr_iac1),
      .spr_iac2(spr_iac2),
      .spr_iac3(spr_iac3),
      .spr_iac4(spr_iac4),
      .iu_rf_t0_xer_p(iu_rf_t0_xer_p),
`ifndef THREADS1
      .iu_rf_t1_xer_p(iu_rf_t1_xer_p),
`endif
	   .pc_iu_ram_active(pc_iu_ram_active),
      .pc_iu_ram_flush_thread(pc_iu_ram_flush_thread),
      .xu_iu_msrovride_enab(xu_iu_msrovride_enab),
      .iu_pc_ram_done(iu_pc_ram_done_int),
      .iu_pc_ram_interrupt(iu_pc_ram_interrupt),
      .iu_pc_ram_unsupported(iu_pc_ram_unsupported),
      .pc_iu_stop(pc_iu_stop),
      .pc_iu_step(pc_iu_step),
      .pc_iu_t0_dbg_action(pc_iu_t0_dbg_action),
`ifndef THREADS1
      .pc_iu_t1_dbg_action(pc_iu_t1_dbg_action),
`endif
      .iu_pc_step_done(iu_pc_step_done),
      .iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
      .iu_pc_err_debug_event(iu_pc_err_debug_event),
      .iu_pc_attention_instr(iu_pc_attention_instr),
      .iu_pc_err_mchk_disabled(iu_pc_err_mchk_disabled),
      .ac_an_debug_trigger(ac_an_debug_trigger),
      .iu_xu_stop(iu_xu_stop_internal),
      .pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
      .pc_iu_debug_mux_ctrls(pc_iu_debug_mux2_ctrls),
      .debug_bus_in(ifetch_debug_bus_out),
      .debug_bus_out(debug_bus_out),
      .coretrace_ctrls_in(ifetch_coretrace_ctrls_out),
      .coretrace_ctrls_out(coretrace_ctrls_out)

   );

   assign iu_pc_ram_done = iu_pc_ram_done_int;

   // Need to fix these

   assign g8t_clkoff_b = 1'b1;
   assign g8t_d_mode = 1'b0;
   assign g8t_delay_lclkr = {5{1'b0}};
   assign g8t_mpw1_b = {5{1'b1}};
   assign g8t_mpw2_b = 1'b1;
   assign g6t_clkoff_b = 1'b1;
   assign g6t_act_dis = 1'b0;
   assign g6t_d_mode = 1'b0;
   assign g6t_delay_lclkr = {4{1'b0}};
   assign g6t_mpw1_b = {5{1'b1}};
   assign g6t_mpw2_b = 1'b1;
   assign cam_clkoff_b = 1'b1;
   assign cam_act_dis = 1'b0;
   assign cam_d_mode = 1'b0;
   assign cam_delay_lclkr = {5{1'b0}};
   assign cam_mpw1_b = {5{1'b1}};
   assign cam_mpw2_b = 1'b1;

   assign btb_scan_in = 1'b0;
   assign func_scan_in = 1'b0;
   assign ac_ccfg_scan_in = 1'b0;
   assign time_scan_in = 1'b0;
   assign repr_scan_in = 1'b0;
   assign abst_scan_in = 3'b000;
   assign regf_scan_in = {5{1'b0}};
   assign bp_scan_in = {2*`THREADS{1'b0}};
   assign ram_scan_in = 1'b0;
   assign uc_scan_in = {`THREADS{1'b0}};
   assign dbg1_scan_in = 1'b0;
   assign bh0_scan_in = 1'b0;
   assign bh1_scan_in = 1'b0;
   assign bh2_scan_in = 1'b0;
   assign slice_scan_in = {(`THREADS*7+1){1'b0}};
   assign cp_scan_in = {(`THREADS+1){1'b0}};

   assign iu_pc_bo_fail[4] = 1'b0;
   assign iu_pc_bo_diagout[4] = 1'b0;

   // This needs to get moved into an RLM
   tri_plat #(.WIDTH(15)) perv_3to2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .flush(tc_ac_ccflush_dc),
      .din({pc_iu_func_slp_sl_thold_3,
            pc_iu_func_nsl_thold_3,
            pc_iu_func_slp_nsl_thold_3,
            pc_iu_func_sl_thold_3,
            pc_iu_cfg_slp_sl_thold_3,
            pc_iu_regf_slp_sl_thold_3,
            pc_iu_time_sl_thold_3,
            pc_iu_abst_sl_thold_3,
            pc_iu_abst_slp_sl_thold_3,
            pc_iu_repr_sl_thold_3,
            pc_iu_ary_nsl_thold_3,
            pc_iu_ary_slp_nsl_thold_3,
            pc_iu_bolt_sl_thold_3,
            pc_iu_sg_3,
            pc_iu_fce_3}),
      .q(  {pc_iu_func_slp_sl_thold_2,
            pc_iu_func_nsl_thold_2,
            pc_iu_func_slp_nsl_thold_2,
            pc_iu_func_sl_thold_2,
            pc_iu_cfg_slp_sl_thold_2,
            pc_iu_regf_slp_sl_thold_2,
            pc_iu_time_sl_thold_2,
            pc_iu_abst_sl_thold_2,
            pc_iu_abst_slp_sl_thold_2,
            pc_iu_repr_sl_thold_2,
            pc_iu_ary_nsl_thold_2,
            pc_iu_ary_slp_nsl_thold_2,
            pc_iu_bolt_sl_thold_2,
            pc_iu_sg_2,
	    pc_iu_fce_2})
   );


endmodule
