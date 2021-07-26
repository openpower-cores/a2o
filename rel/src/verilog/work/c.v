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
//* TITLE:
//*
//* NAME: c.v
//*
//*********************************************************************

// For RLMs & Top-level only
(* recursive_synthesis="0" *)

module c(
`include "tri_a2o.vh"
//	 inout                                                  vcs,
//	 inout                                                  vdd,
//	 inout                                                  gnd,
	 input[0:`NCLK_WIDTH-1] nclk,
	 input                                                  scan_in,
	 output                                                 scan_out,

	 // Pervasive clock control
	 input                                                  an_ac_rtim_sl_thold_8,
	 input                                                  an_ac_func_sl_thold_8,
	 input                                                  an_ac_func_nsl_thold_8,
	 input                                                  an_ac_ary_nsl_thold_8,
	 input                                                  an_ac_sg_8,
	 input                                                  an_ac_fce_8,
	 input [0:7]                                            an_ac_abst_scan_in,

	 // L2 STCX complete
	 input [0:`THREADS-1]                                   an_ac_stcx_complete,
	 input [0:`THREADS-1]                                   an_ac_stcx_pass,

	 // ICBI ACK Interface
	 input                                                  an_ac_icbi_ack,
	 input [0:1]                                            an_ac_icbi_ack_thread,

	 // Back invalidate interface
	 input                                                  an_ac_back_inv,
	 input [64-`REAL_IFAR_WIDTH:63]                         an_ac_back_inv_addr,
	 input [0:4]                                            an_ac_back_inv_target,		// connect to bit(0)
	 input                                                  an_ac_back_inv_local,
	 input                                                  an_ac_back_inv_lbit,
	 input                                                  an_ac_back_inv_gs,
	 input                                                  an_ac_back_inv_ind,
	 input [0:7]                                            an_ac_back_inv_lpar_id,
	 output                                                 ac_an_back_inv_reject,
	 output [0:7]                                           ac_an_lpar_id,

	 // L2 Reload Inputs
	 input                                                  an_ac_reld_data_vld,		// reload data is coming next cycle
	 input [0:4]                                            an_ac_reld_core_tag,		// reload data destinatoin tag (which load queue)
	 input [0:127]                                          an_ac_reld_data,		// Reload Data
	 input [58:59]                                          an_ac_reld_qw,		// quadword address of reload data beat
	 input                                                  an_ac_reld_ecc_err,		// Reload Data contains a Correctable ECC error
	 input                                                  an_ac_reld_ecc_err_ue,		// Reload Data contains an Uncorrectable ECC error
	 input                                                  an_ac_reld_data_coming,
	 input                                                  an_ac_reld_ditc,
	 input                                                  an_ac_reld_crit_qw,
	 input                                                  an_ac_reld_l1_dump,
	 input [0:3]                                            an_ac_req_spare_ctrl_a1,		// spare control bits from L2

	 // load/store credit control
	 input                                                  an_ac_flh2l2_gate,		// Gate L1 Hit forwarding SPR config bit
	 input                                                  an_ac_req_ld_pop,		// credit for a load (L2 can take a load command)
	 input                                                  an_ac_req_st_pop,		// credit for a store (L2 can take a store command)
	 input                                                  an_ac_req_st_gather,		// credit for a store due to L2 gathering of store commands
	 input [0:`THREADS-1]                                   an_ac_sync_ack,

	 //SCOM Satellite
	 input [0:3]                                            an_ac_scom_sat_id,
	 input                                                  an_ac_scom_dch,
	 input                                                  an_ac_scom_cch,
	 output                                                 ac_an_scom_dch,
	 output                                                 ac_an_scom_cch,

	 // FIR and Error Signals
	 output [0:`THREADS-1]                                  ac_an_special_attn,
	 output [0:2]                                           ac_an_checkstop,
	 output [0:2]                                           ac_an_local_checkstop,
	 output [0:2]                                           ac_an_recov_err,
	 output                                                 ac_an_trace_error,
   	 output                       				ac_an_livelock_active,
	 input                                                  an_ac_checkstop,
	 input [0:`THREADS-1]                                   an_ac_external_mchk,

	 // Perfmon Event Bus
	 output [0:4*`THREADS-1]                                ac_an_event_bus0,
	 output [0:4*`THREADS-1]                                ac_an_event_bus1,

	 // Reset related
	 input                                                  an_ac_reset_1_complete,
	 input                                                  an_ac_reset_2_complete,
	 input                                                  an_ac_reset_3_complete,
	 input                                                  an_ac_reset_wd_complete,

	 // Power Management
	 output [0:`THREADS-1]                                  ac_an_pm_thread_running,
	 input [0:`THREADS-1]                                   an_ac_pm_thread_stop,
	 input [0:`THREADS-1]                                   an_ac_pm_fetch_halt,
	 output                                                 ac_an_power_managed,
	 output                                                 ac_an_rvwinkle_mode,

	 // Clock, Test, and LCB Controls
	 input                                                  an_ac_gsd_test_enable_dc,
	 input                                                  an_ac_gsd_test_acmode_dc,
	 input                                                  an_ac_ccflush_dc,
	 input                                                  an_ac_ccenable_dc,
	 input                                                  an_ac_lbist_en_dc,
	 input                                                  an_ac_lbist_ip_dc,
	 input                                                  an_ac_lbist_ac_mode_dc,
	 input                                                  an_ac_scan_diag_dc,
	 input                                                  an_ac_scan_dis_dc_b,

	 //Thold input to clock control macro
	 input [0:8]                                            an_ac_scan_type_dc,

	 // Pervasive
	 output                                                 ac_an_reset_1_request,
	 output                                                 ac_an_reset_2_request,
	 output                                                 ac_an_reset_3_request,
	 output                                                 ac_an_reset_wd_request,
	 input                                                  an_ac_lbist_ary_wrt_thru_dc,
	 input [0:`THREADS-1]                                   an_ac_reservation_vld,
	 input [0:`THREADS-1]                                   an_ac_sleep_en,
	 input [0:`THREADS-1]                                   an_ac_ext_interrupt,
	 input [0:`THREADS-1]                                   an_ac_crit_interrupt,
	 input [0:`THREADS-1]                                   an_ac_perf_interrupt,
	 input [0:`THREADS-1]                                   an_ac_hang_pulse,
	 input                                                  an_ac_tb_update_enable,
	 input                                                  an_ac_tb_update_pulse,
	 input [0:3]                                            an_ac_chipid_dc,
	 input [0:7]                                            an_ac_coreid,
	 output [0:`THREADS-1]                                  ac_an_machine_check,
	 input                                                  an_ac_debug_stop,
	 output [0:`THREADS-1]                                  ac_an_debug_trigger,
	 input [0:`THREADS-1]                                   an_ac_uncond_dbg_event,
	 output [0:31]                                   	ac_an_debug_bus,
	 output                                                 ac_an_coretrace_first_valid,	// coretrace_ctrls[0]
	 output							ac_an_coretrace_valid,		// coretrace_ctrls[1]
	 output	[0:1]						ac_an_coretrace_type,		// coretrace_ctrls[2:3]

	 // L2 Outputs
	 output                                                 ac_an_req_pwr_token,		// power token for command coming next cycle
	 output                                                 ac_an_req,		// command request valid
	 output [64-`REAL_IFAR_WIDTH:63]                        ac_an_req_ra,		// real address for request
	 output [0:5]                                           ac_an_req_ttype,		// command (transaction) type
	 output [0:2]                                           ac_an_req_thread,		// encoded thread ID
	 output                                                 ac_an_req_wimg_w,		// write-through
	 output                                                 ac_an_req_wimg_i,		// cache-inhibited
	 output                                                 ac_an_req_wimg_m,		// memory coherence required
	 output                                                 ac_an_req_wimg_g,		// guarded memory
	 output [0:3]                                           ac_an_req_user_defined,		// User Defined Bits
	 output [0:3]                                           ac_an_req_spare_ctrl_a0,		// Spare bits
	 output [0:4]                                           ac_an_req_ld_core_tag,		// load command tag (which load Q)
	 output [0:2]                                           ac_an_req_ld_xfr_len,		// transfer length for non-cacheable load
	 output [0:31]                                          ac_an_st_byte_enbl,		// byte enables for store data
	 output [0:255]                                         ac_an_st_data,		// store data
	 output                                                 ac_an_req_endian,		// endian mode (0=big endian, 1=little endian)
	 output                                                 ac_an_st_data_pwr_token		// store data power token

	 );


   parameter                                              float_type = 1;

   // I$
   // Cache inject
   wire 							iu_pc_err_icache_parity;
   wire 							iu_pc_err_icachedir_parity;
   wire 							iu_pc_err_icachedir_multihit;
   wire 							iu_pc_err_ierat_multihit;
   wire 							iu_pc_err_ierat_parity;
   wire 							pc_iu_inj_icache_parity;
   wire 							pc_iu_inj_icachedir_parity;
   wire 							pc_iu_init_reset;
   // spr ring
   wire 							iu_slowspr_val_out;
   wire 							iu_slowspr_rw_out;
   wire [0:1] 							iu_slowspr_etid_out;
   wire [0:9] 							iu_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					iu_slowspr_data_out;
   wire 							iu_slowspr_done_out;
   wire 							iu_slowspr_val_in;
   wire 							iu_slowspr_rw_in;
   wire [0:1] 							iu_slowspr_etid_in;
   wire [0:9] 							iu_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					iu_slowspr_data_in;
   wire 							iu_slowspr_done_in;
   wire 							xu_slowspr_val_out;
   wire 							xu_slowspr_rw_out;
   wire [0:1] 							xu_slowspr_etid_out;
   wire [0:9] 							xu_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					xu_slowspr_data_out;
   wire 							xu_slowspr_val_in;
   wire 							xu_slowspr_rw_in;
   wire [0:1] 							xu_slowspr_etid_in;
   wire [0:9] 							xu_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					xu_slowspr_data_in;
   wire 							xu_slowspr_done_in;
   wire 							lq_slowspr_val_out;
   wire 							lq_slowspr_rw_out;
   wire [0:1] 							lq_slowspr_etid_out;
   wire [0:9] 							lq_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					lq_slowspr_data_out;
   wire 							lq_slowspr_done_out;
   wire 							lq_slowspr_val_in;
   wire 							lq_slowspr_rw_in;
   wire [0:1] 							lq_slowspr_etid_in;
   wire [0:9] 							lq_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					lq_slowspr_data_in;
   wire 							lq_slowspr_done_in;
   wire 							pc_slowspr_val_out;
   wire 							pc_slowspr_rw_out;
   wire [0:1] 							pc_slowspr_etid_out;
   wire [0:9] 							pc_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					pc_slowspr_data_out;
   wire 							pc_slowspr_done_out;
   wire 							pc_slowspr_val_in;
   wire 							pc_slowspr_rw_in;
   wire [0:1] 							pc_slowspr_etid_in;
   wire [0:9] 							pc_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					pc_slowspr_data_in;
   wire 							pc_slowspr_done_in;
   wire 							fu_slowspr_val_out;
   wire 							fu_slowspr_rw_out;
   wire [0:1] 							fu_slowspr_etid_out;
   wire [0:9] 							fu_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					fu_slowspr_data_out;
   wire 							fu_slowspr_done_out;
   wire 							fu_slowspr_val_in;
   wire 							fu_slowspr_rw_in;
   wire [0:1] 							fu_slowspr_etid_in;
   wire [0:9] 							fu_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					fu_slowspr_data_in;
   wire 							fu_slowspr_done_in;
   wire 							mm_slowspr_val_out;
   wire 							mm_slowspr_rw_out;
   wire [0:1] 							mm_slowspr_etid_out;
   wire [0:9] 							mm_slowspr_addr_out;
   wire [64-`GPR_WIDTH:63] 					mm_slowspr_data_out;
   wire 							mm_slowspr_done_out;
   wire 							mm_slowspr_val_in;
   wire 							mm_slowspr_rw_in;
   wire [0:1] 							mm_slowspr_etid_in;
   wire [0:9] 							mm_slowspr_addr_in;
   wire [64-`GPR_WIDTH:63] 					mm_slowspr_data_in;
   wire 							mm_slowspr_done_in;

   // XU-IU interface
   wire 							xu_iu_hid_mmu_mode;

   // IU-ERAT interface
   wire 							iu_mm_ierat_req;
   wire 							iu_mm_ierat_req_nonspec;
   wire [0:51] 							iu_mm_ierat_epn;
   wire [0:`THREADS-1] 						iu_mm_ierat_thdid;
   wire [0:3] 							iu_mm_ierat_state;
   wire [0:13] 							iu_mm_ierat_tid;
   wire [0:`THREADS-1] 						iu_mm_ierat_flush;
   wire [0:`THREADS-1] 						iu_mm_perf_itlb;
   wire [0:4] 							mm_iu_ierat_rel_val;
   wire [0:131] 						mm_iu_ierat_rel_data;
   wire [0:13] 							mm_iu_t0_ierat_pid;
   wire [0:19] 					          	mm_iu_t0_ierat_mmucr0;
`ifndef THREADS1
   wire [0:13] 							mm_iu_t1_ierat_pid;
   wire [0:19] 					          	mm_iu_t1_ierat_mmucr0;
`endif
   wire 							mm_iu_tlbwe_binv;
   wire [0:5]                                                   cp_mm_except_taken_t0;
`ifndef THREADS1
   wire [0:5]                                                   cp_mm_except_taken_t1;
`endif

   wire [0:17] 							iu_mm_ierat_mmucr0;
   wire [0:`THREADS-1] 						iu_mm_ierat_mmucr0_we;
   wire [0:8] 							mm_iu_ierat_mmucr1;
   wire [0:3] 							iu_mm_ierat_mmucr1;
   wire [0:`THREADS-1]						iu_mm_ierat_mmucr1_we;
   wire 							mm_iu_ierat_snoop_coming;
   wire 							mm_iu_ierat_snoop_val;
   wire [0:25] 							mm_iu_ierat_snoop_attr;
   wire [(62-`EFF_IFAR_ARCH):51] 				mm_iu_ierat_snoop_vpn;
   wire 							iu_mm_ierat_snoop_ack;
   wire [0:`THREADS-1] 						iu_mm_hold_ack;
   wire [0:`THREADS-1] 						iu_mm_bus_snoop_hold_ack;
   wire [0:`THREADS-1] 						mm_iu_bus_snoop_hold_req;
   wire [0:`THREADS-1] 						mm_iu_bus_snoop_hold_done;
   wire [0:`THREADS-1] 						mm_iu_tlbi_complete;
   wire [0:`THREADS-1] 						mm_iu_hold_req;
   wire [0:`THREADS-1] 						mm_iu_hold_done;
   wire [0:`THREADS-1] 						mm_iu_flush_req;

   // IU-LQ interface
   wire [0:`THREADS-1] 						iu_lq_request;
   wire [0:1] 							iu_lq_cTag;
   wire [64-`REAL_IFAR_WIDTH:59] 				iu_lq_ra;
   wire [0:4] 							iu_lq_wimge;
   wire [0:3] 							iu_lq_userdef;
   wire [0:`THREADS-1] 						lq_iu_icbi_val;
   wire [64-`REAL_IFAR_WIDTH:57] 				lq_iu_icbi_addr;
   wire [0:`THREADS-1] 						iu_lq_icbi_complete;
   wire 							lq_iu_ici_val;
   // IU-RV interface
   wire 							iu_rv_iu6_t0_i0_vld;
   wire 							iu_rv_iu6_t0_i0_act;
   wire 							iu_rv_iu6_t0_i0_rte_lq;
   wire 							iu_rv_iu6_t0_i0_rte_sq;
   wire 							iu_rv_iu6_t0_i0_rte_fx0;
   wire 							iu_rv_iu6_t0_i0_rte_fx1;
   wire 							iu_rv_iu6_t0_i0_rte_axu0;
   wire 							iu_rv_iu6_t0_i0_rte_axu1;
   wire [0:31] 				iu_rv_iu6_t0_i0_instr;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t0_i0_ifar;
   wire [0:2] 					iu_rv_iu6_t0_i0_ucode;
   wire 							iu_rv_iu6_t0_i0_2ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t0_i0_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t0_i0_itag;
   wire 							iu_rv_iu6_t0_i0_ord;
   wire 							iu_rv_iu6_t0_i0_cord;
   wire 							iu_rv_iu6_t0_i0_spec;
   wire 							iu_rv_iu6_t0_i0_t1_v;
   wire [0:2] 							iu_rv_iu6_t0_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_t1_p;
   wire 							iu_rv_iu6_t0_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_t2_p;
   wire [0:2] 							iu_rv_iu6_t0_i0_t2_t;
   wire 							iu_rv_iu6_t0_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_t3_p;
   wire [0:2] 							iu_rv_iu6_t0_i0_t3_t;
   wire 							iu_rv_iu6_t0_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_s1_p;
   wire [0:2] 							iu_rv_iu6_t0_i0_s1_t;
   wire 							iu_rv_iu6_t0_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_s2_p;
   wire [0:2] 							iu_rv_iu6_t0_i0_s2_t;
   wire 							iu_rv_iu6_t0_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t0_i0_s3_p;
   wire [0:2] 							iu_rv_iu6_t0_i0_s3_t;
   wire [0:3] 							iu_rv_iu6_t0_i0_ilat;
   wire [0:`EFF_IFAR_WIDTH-1] 					iu_rv_iu6_t0_i0_bta;
   wire 							iu_rv_iu6_t0_i0_bta_val;
   wire 							iu_rv_iu6_t0_i0_br_pred;
   wire [0:`EFF_IFAR_WIDTH-1] 					iu_rv_iu6_t0_i0_fusion;
   wire [0:2] 							iu_rv_iu6_t0_i0_ls_ptr;
   wire [0:17] 							iu_rv_iu6_t0_i0_gshare;
   wire 							iu_rv_iu6_t0_i0_bh_update;
   wire 							iu_rv_iu6_t0_i0_isLoad;
   wire 							iu_rv_iu6_t0_i0_isStore;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t0_i0_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t0_i0_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t0_i0_s3_itag;

   wire 							iu_rv_iu6_t0_i1_vld;
   wire 							iu_rv_iu6_t0_i1_act;
   wire 							iu_rv_iu6_t0_i1_rte_lq;
   wire 							iu_rv_iu6_t0_i1_rte_sq;
   wire 							iu_rv_iu6_t0_i1_rte_fx0;
   wire 							iu_rv_iu6_t0_i1_rte_fx1;
   wire 							iu_rv_iu6_t0_i1_rte_axu0;
   wire 							iu_rv_iu6_t0_i1_rte_axu1;
   wire [0:31] 				iu_rv_iu6_t0_i1_instr;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t0_i1_ifar;
   wire [0:2] 					iu_rv_iu6_t0_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t0_i1_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t0_i1_itag;
   wire 							iu_rv_iu6_t0_i1_ord;
   wire 							iu_rv_iu6_t0_i1_cord;
   wire 							iu_rv_iu6_t0_i1_spec;
   wire 							iu_rv_iu6_t0_i1_t1_v;
   wire [0:2] 					iu_rv_iu6_t0_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_t1_p;
   wire 							iu_rv_iu6_t0_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_t2_p;
   wire [0:2] 					iu_rv_iu6_t0_i1_t2_t;
   wire 							iu_rv_iu6_t0_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_t3_p;
   wire [0:2] 					iu_rv_iu6_t0_i1_t3_t;
   wire 							iu_rv_iu6_t0_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_s1_p;
   wire [0:2] 					iu_rv_iu6_t0_i1_s1_t;
   wire                    iu_rv_iu6_t0_i1_s1_dep_hit;
   wire 							iu_rv_iu6_t0_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_s2_p;
   wire [0:2] 					iu_rv_iu6_t0_i1_s2_t;
   wire                    iu_rv_iu6_t0_i1_s2_dep_hit;
   wire 							iu_rv_iu6_t0_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t0_i1_s3_p;
   wire [0:2] 					iu_rv_iu6_t0_i1_s3_t;
   wire                    iu_rv_iu6_t0_i1_s3_dep_hit;
   wire [0:3] 					iu_rv_iu6_t0_i1_ilat;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t0_i1_bta;
   wire 							iu_rv_iu6_t0_i1_bta_val;
   wire 							iu_rv_iu6_t0_i1_br_pred;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t0_i1_fusion;
   wire [0:2] 					iu_rv_iu6_t0_i1_ls_ptr;
   wire [0:17] 					iu_rv_iu6_t0_i1_gshare;
   wire 							iu_rv_iu6_t0_i1_bh_update;
   wire 							iu_rv_iu6_t0_i1_isLoad;
   wire 							iu_rv_iu6_t0_i1_isStore;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t0_i1_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t0_i1_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t0_i1_s3_itag;

`ifndef THREADS1

   wire 							iu_rv_iu6_t1_i0_vld;
   wire 							iu_rv_iu6_t1_i0_act;
   wire 							iu_rv_iu6_t1_i0_rte_lq;
   wire 							iu_rv_iu6_t1_i0_rte_sq;
   wire 							iu_rv_iu6_t1_i0_rte_fx0;
   wire 							iu_rv_iu6_t1_i0_rte_fx1;
   wire 							iu_rv_iu6_t1_i0_rte_axu0;
   wire 							iu_rv_iu6_t1_i0_rte_axu1;
   wire [0:31] 				iu_rv_iu6_t1_i0_instr;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t1_i0_ifar;
   wire [0:2] 					iu_rv_iu6_t1_i0_ucode;
   wire 							iu_rv_iu6_t1_i0_2ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] iu_rv_iu6_t1_i0_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] iu_rv_iu6_t1_i0_itag;
   wire 							iu_rv_iu6_t1_i0_ord;
   wire 							iu_rv_iu6_t1_i0_cord;
   wire 							iu_rv_iu6_t1_i0_spec;
   wire 							iu_rv_iu6_t1_i0_t1_v;
   wire [0:2] 					iu_rv_iu6_t1_i0_t1_t;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_t1_p;
   wire 							iu_rv_iu6_t1_i0_t2_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_t2_p;
   wire [0:2] 					iu_rv_iu6_t1_i0_t2_t;
   wire 							iu_rv_iu6_t1_i0_t3_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_t3_p;
   wire [0:2] 					iu_rv_iu6_t1_i0_t3_t;
   wire 							iu_rv_iu6_t1_i0_s1_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_s1_p;
   wire [0:2] 					iu_rv_iu6_t1_i0_s1_t;
   wire      					iu_rv_iu6_t1_i0_s1_dep_hit;
   wire 							iu_rv_iu6_t1_i0_s2_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_s2_p;
   wire [0:2] 					iu_rv_iu6_t1_i0_s2_t;
   wire      					iu_rv_iu6_t1_i0_s2_dep_hit;
   wire 							iu_rv_iu6_t1_i0_s3_v;
   wire [0:`GPR_POOL_ENC-1] iu_rv_iu6_t1_i0_s3_p;
   wire [0:2] 					iu_rv_iu6_t1_i0_s3_t;
   wire      					iu_rv_iu6_t1_i0_s3_dep_hit;
   wire [0:3] 					iu_rv_iu6_t1_i0_ilat;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t1_i0_bta;
   wire 							iu_rv_iu6_t1_i0_bta_val;
   wire 							iu_rv_iu6_t1_i0_br_pred;
   wire [0:`EFF_IFAR_WIDTH-1] iu_rv_iu6_t1_i0_fusion;
   wire [0:2] 					iu_rv_iu6_t1_i0_ls_ptr;
   wire [0:17] 					iu_rv_iu6_t1_i0_gshare;
   wire 							iu_rv_iu6_t1_i0_bh_update;
   wire 							iu_rv_iu6_t1_i0_isLoad;
   wire 							iu_rv_iu6_t1_i0_isStore;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i0_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i0_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i0_s3_itag;

   wire 							iu_rv_iu6_t1_i1_vld;
   wire 							iu_rv_iu6_t1_i1_act;
   wire 							iu_rv_iu6_t1_i1_rte_lq;
   wire 							iu_rv_iu6_t1_i1_rte_sq;
   wire 							iu_rv_iu6_t1_i1_rte_fx0;
   wire 							iu_rv_iu6_t1_i1_rte_fx1;
   wire 							iu_rv_iu6_t1_i1_rte_axu0;
   wire 							iu_rv_iu6_t1_i1_rte_axu1;
   wire [0:31] 							iu_rv_iu6_t1_i1_instr;
   wire [0:`EFF_IFAR_WIDTH-1] 					iu_rv_iu6_t1_i1_ifar;
   wire [0:2] 							iu_rv_iu6_t1_i1_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 				iu_rv_iu6_t1_i1_ucode_cnt;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i1_itag;
   wire 							iu_rv_iu6_t1_i1_ord;
   wire 							iu_rv_iu6_t1_i1_cord;
   wire 							iu_rv_iu6_t1_i1_spec;
   wire 							iu_rv_iu6_t1_i1_t1_v;
   wire [0:2] 							iu_rv_iu6_t1_i1_t1_t;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_t1_p;
   wire 							iu_rv_iu6_t1_i1_t2_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_t2_p;
   wire [0:2] 							iu_rv_iu6_t1_i1_t2_t;
   wire 							iu_rv_iu6_t1_i1_t3_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_t3_p;
   wire [0:2] 							iu_rv_iu6_t1_i1_t3_t;
   wire 							iu_rv_iu6_t1_i1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_s1_p;
   wire [0:2] 							iu_rv_iu6_t1_i1_s1_t;
   wire 							iu_rv_iu6_t1_i1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_s2_p;
   wire [0:2] 							iu_rv_iu6_t1_i1_s2_t;
   wire 							iu_rv_iu6_t1_i1_s3_v;
   wire [0:`GPR_POOL_ENC-1] 					iu_rv_iu6_t1_i1_s3_p;
   wire [0:2] 							iu_rv_iu6_t1_i1_s3_t;
   wire [0:3] 							iu_rv_iu6_t1_i1_ilat;
   wire [0:`EFF_IFAR_WIDTH-1] 					iu_rv_iu6_t1_i1_bta;
   wire 							iu_rv_iu6_t1_i1_bta_val;
   wire 							iu_rv_iu6_t1_i1_br_pred;
   wire [0:`EFF_IFAR_WIDTH-1] 					iu_rv_iu6_t1_i1_fusion;
   wire [0:2] 							iu_rv_iu6_t1_i1_ls_ptr;
   wire [0:17] 							iu_rv_iu6_t1_i1_gshare;
   wire 							iu_rv_iu6_t1_i1_bh_update;
   wire 							iu_rv_iu6_t1_i1_isLoad;
   wire 							iu_rv_iu6_t1_i1_isStore;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i1_s1_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i1_s2_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_rv_iu6_t1_i1_s3_itag;

`endif

   // Credit Interface with IU
   wire [0:`THREADS-1] 						rv_iu_fx0_credit_free;
   wire [0:`THREADS-1] 						rv_iu_fx1_credit_free;
   wire [0:`THREADS-1] 						rv_iu_axu0_credit_free;
   wire [0:`THREADS-1] 						rv_iu_axu1_credit_free;

   // LQ Instruction Executed
   wire [0:`THREADS-1] 						lq0_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					lq0_iu_itag;
   wire 							lq0_iu_n_flush;
   wire 							lq0_iu_np1_flush;
   wire 							lq0_iu_dacr_type;
   wire [0:3] 							lq0_iu_dacrw;
   wire [0:31] 							lq0_iu_instr;
   wire [64-`GPR_WIDTH:63] 					lq0_iu_eff_addr;
   wire 							lq0_iu_exception_val;
   wire [0:5] 							lq0_iu_exception;
   wire 							lq0_iu_flush2ucode;
   wire 							lq0_iu_flush2ucode_type;
   wire [0:`THREADS-1] 						lq0_iu_recirc_val;
   wire [0:`THREADS-1] 						lq0_iu_dear_val;
   wire [0:`THREADS-1] 						lq1_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					lq1_iu_itag;
   wire 							lq1_iu_n_flush;
   wire 							lq1_iu_np1_flush;
   wire 							lq1_iu_exception_val;
   wire [0:5] 							lq1_iu_exception;
   wire 							lq1_iu_dacr_type;
   wire [0:3] 							lq1_iu_dacrw;
   wire [0:3] 							lq1_iu_perf_events;
   wire [0:`THREADS-1] 						lq_iu_credit_free;
   wire [0:`THREADS-1] 						sq_iu_credit_free;
   wire 							pc_lq_init_reset;

   // BR Instruction Executed
   wire [0:`THREADS-1] 						br_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					br_iu_itag;
   wire [62-`EFF_IFAR_ARCH:61] 					br_iu_bta;
   wire 							br_iu_taken;
   wire [0:`THREADS-1] 						br_iu_redirect;
   wire [0:3]							br_iu_perf_events;

   //br unit repairs
   wire [0:17] 							br_iu_gshare;
   wire [0:2] 							br_iu_ls_ptr;
   wire [62-`EFF_IFAR_WIDTH:61] 				br_iu_ls_data;
   wire 							br_iu_ls_update;

   // AXU Instruction Executed
   wire [0:`THREADS-1] 						axu0_rv_itag_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					axu0_rv_itag;
   wire [0:`THREADS-1] 						axu1_rv_itag_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					axu1_rv_itag;
   wire                                                         axu0_rv_hold_all;
   wire                                                         axu1_rv_hold_all;


   // Abort
   wire 							lq_rv_ex2_s1_abort;
   wire 							lq_rv_ex2_s2_abort;
   wire 							fx0_rv_ex2_s1_abort;
   wire 							fx0_rv_ex2_s2_abort;
   wire 							fx0_rv_ex2_s3_abort;
   wire 							fx1_rv_ex2_s1_abort;
   wire 							fx1_rv_ex2_s2_abort;
   wire 							fx1_rv_ex2_s3_abort;
   wire 							axu0_rv_ex2_s1_abort;
   wire 							axu0_rv_ex2_s2_abort;
   wire 							axu0_rv_ex2_s3_abort;
   wire   							fu_lq_ex3_abort;



   // XU Instruction Executed
   wire [0:`THREADS-1] 						xu_iu_ucode_xer_val;
   wire [`XER_WIDTH-7:`XER_WIDTH-1] 				xu_iu_ucode_xer;
   wire [0:`THREADS-1] 						xu_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					xu_iu_itag;
   wire 							xu_iu_n_flush;
   wire 							xu_iu_np1_flush;
   wire 							xu_iu_flush2ucode;
   wire [0:3]              xu0_iu_perf_events;
   wire 							xu_iu_exception_val;
   wire [0:4] 							xu_iu_exception;
   wire [0:`THREADS-1] 						xu_iu_mtiar;
   wire [62-`EFF_IFAR_ARCH:61] 					xu_iu_bta;
   wire [0:`THREADS-1] 						xu1_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					xu1_iu_itag;
   wire [0:`THREADS-1] 						xu_iu_val;
   wire [0:`THREADS-1] 						xu_iu_pri_val;
   wire [0:2] 							xu_iu_pri;
   wire 							xu_iu_is_eratre;
   wire 							xu_iu_is_eratwe;
   wire 							xu_iu_is_eratsx;
   wire 							xu_iu_is_eratilx;
   wire 							xu_iu_is_erativax;
   wire [0:1] 							xu_iu_ws;
   wire [0:2] 							xu_iu_t;
   wire [0:8] 							xu_iu_rs_is;		// Never see this used in IERAT
   wire [0:3] 							xu_iu_ra_entry;
   wire [64-`GPR_WIDTH:51] 					xu_iu_rb;
   wire [64-`GPR_WIDTH:63] 					xu_iu_rs_data;
   wire 							xu_iu_ord_ready;
   wire 							iu_xu_ord_read_done;
   wire 							iu_xu_ord_write_done;
   wire 							iu_xu_ord_n_flush_req;
   wire                    iu_xu_ord_par_err;
   wire [0:`THREADS-1] 						mm_xu_ord_read_done;
   wire [0:`THREADS-1] 						mm_xu_ord_write_done;
   wire [0:`THREADS-1] 						mm_xu_ord_n_flush_req;
   wire [0:`THREADS-1] 						mm_xu_ord_np1_flush_req;
   wire                                mm_xu_ord_tlb_multihit;
   wire                                mm_xu_ord_tlb_par_err;
   wire                                mm_xu_ord_lru_par_err;
   wire                                mm_xu_local_snoop_reject;
   wire [0:`ITAG_SIZE_ENC-1] 					mm_xu_itag;
   wire 							xu_mm_ord_ready;
   wire [0:`THREADS-1] 						mm_xu_cr0_eq;		// for record forms
   wire [0:`THREADS-1] 						mm_xu_cr0_eq_valid;		// for record forms
   wire [0:`THREADS-1] 						mm_xu_tlb_miss;
   wire [0:`THREADS-1] 						mm_xu_lrat_miss;
   wire [0:`THREADS-1] 						mm_xu_tlb_inelig;
   wire [0:`THREADS-1] 						mm_xu_pt_fault;
   wire [0:`THREADS-1] 						mm_xu_hv_priv;
   wire [0:`THREADS-1] 						mm_xu_illeg_instr;
   wire [0:1] 							mm_xu_t0_mmucr0_tlbsel;
`ifndef THREADS1
   wire [0:1] 							mm_xu_t1_mmucr0_tlbsel;
`endif
   wire 							mm_xu_tlb_miss_ored;
   wire 							mm_xu_lrat_miss_ored;
   wire 							mm_xu_tlb_inelig_ored;
   wire 							mm_xu_pt_fault_ored;
   wire 							mm_xu_hv_priv_ored;
   wire 							mm_xu_illeg_instr_ored;
   wire 							mm_xu_cr0_eq_ored;		// for record forms
   wire 							mm_xu_cr0_eq_valid_ored;		// for record forms
   wire 							mm_xu_ord_n_flush_req_ored;
   wire 							mm_xu_ord_np1_flush_req_ored;
   wire 							mm_xu_ord_read_done_ored;
   wire 							mm_xu_ord_write_done_ored;
   wire 							mm_pc_tlb_multihit_err_ored;
   wire 							mm_pc_tlb_par_err_ored;
   wire 							mm_pc_lru_par_err_ored;
   wire 							mm_pc_local_snoop_reject_ored;

   wire [0:`THREADS-1] 						mm_tlb_multihit_err;
   wire [0:`THREADS-1] 						mm_tlb_par_err;
   wire [0:`THREADS-1] 						mm_lru_par_err;
   wire [0:`THREADS-1] 						mm_iu_local_snoop_reject;
   wire [64-`GPR_WIDTH:63] 					iu_xu_ex5_data;
   wire 							xu_lq_act;
   wire [0:`THREADS-1] 						xu_lq_val;
   wire 							xu_lq_is_eratre;
   wire 							xu_lq_is_eratwe;
   wire 							xu_lq_is_eratsx;
   wire 							xu_lq_is_eratilx;
   wire [0:1] 							xu_lq_ws;
   wire [0:2] 							xu_lq_t;
   wire [0:8] 							xu_lq_rs_is;		// Never see this used in IERAT
   wire [0:4] 							xu_lq_ra_entry;
   wire [64-`GPR_WIDTH:51] 					xu_lq_rb;
   wire [64-`GPR_WIDTH:63] 					xu_lq_rs_data;
   wire 							xu_lq_ord_ready;
   wire 							xu_lq_hold_req;
   wire 							lq_xu_ord_read_done;
   wire 							lq_xu_ord_write_done;
   wire 							lq_xu_ord_n_flush_req;
   wire                    lq_xu_ord_par_err;
   wire [64-`GPR_WIDTH:63] lq_xu_ex5_data;
   wire 							lq_xu_dbell_val;
   wire [0:4] 					lq_xu_dbell_type;
   wire 							lq_xu_dbell_brdcast;
   wire 							lq_xu_dbell_lpid_match;
   wire [50:63] 				lq_xu_dbell_pirtag;
   wire 							xu_mm_is_tlbre;
   wire 							xu_mm_is_tlbwe;
   wire 							xu_mm_is_tlbsx;
   wire 							xu_mm_is_tlbsxr;
   wire 							xu_mm_is_tlbsrx;
   wire 							xu_mm_is_tlbivax;
   wire 							xu_mm_is_tlbilx;
   wire [0:11] 				xu_mm_ra_entry;
   wire [64-`GPR_WIDTH:63] xu_mm_rb;
   wire 							lq_xu_spr_xucr0_cslc_xuop;
   wire 							lq_xu_spr_xucr0_cslc_binv;
   wire 							lq_xu_spr_xucr0_clo;
   wire 							lq_xu_spr_xucr0_cul;
   wire [0:`THREADS-1] 		lq_iu_spr_dbcr3_ivc;
   // FU Instruction Executed
   wire [0:`THREADS-1] 		axu0_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] axu0_iu_itag;
   wire 							axu0_iu_n_flush;
   wire 							axu0_iu_np1_flush;
   wire 							axu0_iu_n_np1_flush;
   wire 							axu0_iu_flush2ucode;
   wire 							axu0_iu_flush2ucode_type;
   wire 							axu0_iu_exception_val;
   wire [0:3] 					axu0_iu_exception;
   wire [0:`THREADS-1] 		axu0_iu_async_fex;
   wire [0:3]              axu0_iu_perf_events;

   wire [0:`THREADS-1] 		axu1_iu_execute_vld;
   wire [0:`ITAG_SIZE_ENC-1] axu1_iu_itag;
   wire 							axu1_iu_n_flush;
   wire 							axu1_iu_np1_flush;
   wire 							axu1_iu_flush2ucode;
   wire 							axu1_iu_flush2ucode_type;
   wire 							axu1_iu_exception_val;
   wire [0:3] 					axu1_iu_exception;
   wire [0:3]              axu1_iu_perf_events;

   wire [0:`THREADS-1] 		cp_flush;
   wire [0:`ITAG_SIZE_ENC-1] cp_t0_next_itag;
   wire [0:`ITAG_SIZE_ENC-1] cp_t0_flush_itag;
   wire [62-`EFF_IFAR_ARCH:61] cp_t0_flush_ifar;
   wire [0:`THREADS-1]		cp_axu_i0_t1_v;
   wire [0:`THREADS-1]		cp_axu_i1_t1_v;

   wire [0:2] 					cp_axu_t0_i0_t1_t;
   wire [0:`GPR_WIDTH_ENC-1] cp_axu_t0_i0_t1_p;
   wire [0:2] 					cp_axu_t0_i1_t1_t;
   wire [0:`GPR_WIDTH_ENC-1] cp_axu_t0_i1_t1_p;

   wire [0:`ITAG_SIZE_ENC-1] 					cp_t1_next_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					cp_t1_flush_itag;
   wire [62-`EFF_IFAR_ARCH:61] 					cp_t1_flush_ifar;
   wire [0:2] 							cp_axu_t1_i0_t1_t;
   wire [0:`GPR_WIDTH_ENC-1] 					cp_axu_t1_i0_t1_p;
   wire [0:2] 							cp_axu_t1_i1_t1_t;
   wire [0:`GPR_WIDTH_ENC-1] 					cp_axu_t1_i1_t1_p;

   wire 							cp_is_isync;
   wire 							cp_is_csync;

   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu0_ex1_r0d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu0_ex1_r1d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu0_ex1_r2d;
   wire 							xu0_gpr_ex6_we;
   wire [0:`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 			xu0_gpr_ex6_wa;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			xu0_gpr_ex6_wd;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu1_ex1_r0d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu1_ex1_r1d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_xu1_ex1_r2d;
   wire 							xu1_gpr_ex3_we;
   wire [0:`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 			xu1_gpr_ex3_wa;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			xu1_gpr_ex3_wd;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			rv_lq_gpr_ex1_r0d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			rv_lq_gpr_ex1_r1d;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			gpr_lq_ex1_r2d;
   wire 							lq_rv_gpr_ex6_we;
   wire [0:`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 			lq_rv_gpr_ex6_wa;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			lq_rv_gpr_ex6_wd;
   wire 							lq_xu_gpr_ex5_we;
   wire [0:`AXU_SPARE_ENC+`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 	lq_xu_gpr_ex5_wa;
   wire 							lq_rv_gpr_rel_we;
   wire [0:`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 			lq_rv_gpr_rel_wa;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			lq_rv_gpr_rel_wd;
   wire 							lq_xu_gpr_rel_we;
   wire [0:`AXU_SPARE_ENC+`GPR_WIDTH_ENC+`THREADS_POOL_ENC-1] 	lq_xu_gpr_rel_wa;
   wire [64-`GPR_WIDTH:63+`GPR_WIDTH/8] 			lq_xu_gpr_rel_wd;

   wire 							lq_xu_cr_ex5_we;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1] 			lq_xu_cr_ex5_wa;
   wire 							lq_xu_cr_l2_we;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1] 			lq_xu_cr_l2_wa;
   wire [0:3] 							lq_xu_cr_l2_wd;
   wire [0:`XER_POOL_ENC-1] 					iu_rf_t0_xer_p;
`ifndef THREADS1
   wire [0:`XER_POOL_ENC-1] 					iu_rf_t1_xer_p;
`endif
   wire [0:`THREADS-1] 						xu_lq_xer_cp_rd;

   // Interface to FX0
   wire [0:`THREADS-1] 						rv_fx0_vld;
   wire 							rv_fx0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_s1_p;
   wire [0:2] 							rv_fx0_s1_t;
   wire 							rv_fx0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_s2_p;
   wire [0:2] 							rv_fx0_s2_t;
   wire 							rv_fx0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_s3_p;
   wire [0:2] 							rv_fx0_s3_t;
   wire [0:31] 							rv_fx0_ex0_instr;
   wire [62-`EFF_IFAR_WIDTH:61] 				rv_fx0_ex0_ifar;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_fx0_ex0_itag;
   wire [0:2] 							rv_fx0_ex0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 				rv_fx0_ex0_ucode_cnt;
   wire 							rv_fx0_ex0_ord;
   wire 							rv_fx0_ex0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_ex0_t1_p;
   wire [0:2] 							rv_fx0_ex0_t1_t;
   wire 							rv_fx0_ex0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_ex0_t2_p;
   wire [0:2] 							rv_fx0_ex0_t2_t;
   wire 							rv_fx0_ex0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx0_ex0_t3_p;
   wire [0:2] 							rv_fx0_ex0_t3_t;
   wire 							rv_fx0_ex0_s1_v;
   wire 							rv_fx0_ex0_s2_v;
   wire [0:2] 							rv_fx0_ex0_s2_t;
   wire 							rv_fx0_ex0_s3_v;
   wire [0:2] 							rv_fx0_ex0_s3_t;
   wire [0:19] 							rv_fx0_ex0_fusion;
   wire [62-`EFF_IFAR_WIDTH:61] 				rv_fx0_ex0_pred_bta;
   wire 							rv_fx0_ex0_bta_val;
   wire 							rv_fx0_ex0_br_pred;
   wire [0:2] 							rv_fx0_ex0_ls_ptr;
   wire 							rv_fx0_ex0_bh_update;
   wire [0:17] 							rv_fx0_ex0_gshare;
   wire [0:`THREADS-1] 						rv_fx0_ex0_spec_flush;
   wire [0:`THREADS-1] 						rv_fx0_ex1_spec_flush;
   wire [0:`THREADS-1] 						rv_fx0_ex2_spec_flush;
   wire 							fx0_rv_hold_all;
   wire [0:`ITAG_SIZE_ENC-1] 					fx0_rv_ord_itag;
   wire 							fx0_rv_ord_complete;

   // Interface to FX1
   wire [0:`THREADS-1] 						rv_fx1_vld;
   wire 							rv_fx1_s1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_s1_p;
   wire [0:2] 							rv_fx1_s1_t;
   wire 							rv_fx1_s2_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_s2_p;
   wire [0:2] 							rv_fx1_s2_t;
   wire 							rv_fx1_s3_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_s3_p;
   wire [0:2] 							rv_fx1_s3_t;
   wire [0:31] 							rv_fx1_ex0_instr;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_fx1_ex0_itag;
   wire [0:2] 							rv_fx1_ex0_ucode;
   wire 							rv_fx1_ex0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_ex0_t1_p;
   wire 							rv_fx1_ex0_t2_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_ex0_t2_p;
   wire 							rv_fx1_ex0_t3_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_fx1_ex0_t3_p;
   wire 							rv_fx1_ex0_s1_v;
   wire [0:2] 							rv_fx1_ex0_s3_t;
   wire 							rv_fx1_ex0_isStore;

   wire [0:`THREADS-1] 						rv_fx1_ex0_spec_flush;
   wire [0:`THREADS-1] 						rv_fx1_ex1_spec_flush;
   wire [0:`THREADS-1] 						rv_fx1_ex2_spec_flush;
   wire 							fx1_rv_hold_all;
   wire 							fx1_rv_hold_ordered;

   //------------------------------------------------------------------
   // AXU Pass Thru Interface
   //------------------------------------------------------------------
   wire [59:63] 						lq_xu_axu_ex4_addr;
   wire 							lq_xu_axu_ex5_we;
   wire 							lq_xu_axu_ex5_le;
   wire [59:63] 						xu_axu_lq_ex4_addr;
   wire 							xu_axu_lq_ex5_we;
   wire 							xu_axu_lq_ex5_le;
   wire [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] 	xu_axu_lq_ex5_wa;
   wire [(128-`STQ_DATA_SIZE):127] 				xu_axu_lq_ex5_wd;
   wire 							lq_xu_axu_rel_we;
   wire 							lq_xu_axu_rel_le;
   wire 							xu_axu_lq_rel_we;
   wire 							xu_axu_lq_rel_le;
   wire [0:`AXU_SPARE_ENC+`GPR_POOL_ENC+`THREADS_POOL_ENC-1] 	xu_axu_lq_rel_wa;
   wire [(128-`STQ_DATA_SIZE):128+((`STQ_DATA_SIZE-1)/8)] 	xu_axu_lq_rel_wd;
   wire [0:`THREADS-1] 						axu_xu_lq_ex_stq_val;
   wire [0:`ITAG_SIZE_ENC-1] 					axu_xu_lq_ex_stq_itag;
   wire [128-`STQ_DATA_SIZE:127] 				axu_xu_lq_exp1_stq_data;
   wire [0:`THREADS-1] 						xu_lq_axu_ex_stq_val;
   wire [0:`ITAG_SIZE_ENC-1] 					xu_lq_axu_ex_stq_itag;
   wire [128-`STQ_DATA_SIZE:127] 				xu_lq_axu_exp1_stq_data;
   wire 							axu_xu_lq_exp1_sto_parity_err;

   // Interface to LQ
   wire [0:`THREADS-1] 						rv_lq_rvs_empty;
   wire [0:`THREADS-1] 						rv_lq_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_lq_ex0_itag;
   wire 							rv_lq_isLoad;

   wire [0:`THREADS-1] 						rv_lq_rv1_i0_vld;
   wire 							rv_lq_rv1_i0_ucode_preissue;
   wire 							rv_lq_rv1_i0_2ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 				rv_lq_rv1_i0_ucode_cnt;
   wire [0:2] 							rv_lq_rv1_i0_s3_t;
   wire 							rv_lq_rv1_i0_isLoad;
   wire 							rv_lq_rv1_i0_isStore;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_lq_rv1_i0_itag;
   wire 							rv_lq_rv1_i0_rte_lq;
   wire 							rv_lq_rv1_i0_rte_sq;
   wire [61-`PF_IAR_BITS+1:61] 					rv_lq_rv1_i0_ifar;

   wire [0:`THREADS-1] 						rv_lq_rv1_i1_vld;
   wire 							rv_lq_rv1_i1_ucode_preissue;
   wire 							rv_lq_rv1_i1_2ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 				rv_lq_rv1_i1_ucode_cnt;
   wire [0:2] 							rv_lq_rv1_i1_s3_t;
   wire 							rv_lq_rv1_i1_isLoad;
   wire 							rv_lq_rv1_i1_isStore;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_lq_rv1_i1_itag;
   wire 							rv_lq_rv1_i1_rte_lq;
   wire 							rv_lq_rv1_i1_rte_sq;
   wire [61-`PF_IAR_BITS+1:61] 					rv_lq_rv1_i1_ifar;
   wire [0:31] 							rv_lq_ex0_instr;
   wire [0:2] 							rv_lq_ex0_ucode;
   wire [0:`UCODE_ENTRIES_ENC-1] 				rv_lq_ex0_ucode_cnt;
   wire 							rv_lq_ex0_spec;
   wire 							rv_lq_ex0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_lq_ex0_t1_p;
   wire [0:`GPR_POOL_ENC-1] 					rv_lq_ex0_t3_p;
   wire 							rv_lq_ex0_s1_v;
   wire 							rv_lq_ex0_s2_v;
   wire [0:2] 							rv_lq_ex0_s2_t;

   wire 							lq_rv_hold_all;
   wire [0:`THREADS-1] 						lq_rv_itag0_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					lq_rv_itag0;
   wire [0:`THREADS-1] 						lq_rv_itag1_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					lq_rv_itag1;
   wire [0:`THREADS-1] 						lq_rv_itag2_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					lq_rv_itag2;
   wire 							lq_rv_itag0_spec;
   wire                             lq_rv_itag0_abort;
   wire 							lq_rv_itag1_restart;
   wire 							lq_rv_itag1_abort;
   wire 							lq_rv_itag1_hold;
   wire 							lq_rv_itag1_cord;
   wire [0:`THREADS-1] 						lq_rv_clr_hold;
   wire 							lq_rv_ord_complete;

   wire [0:`GPR_POOL_ENC-1] 					rv_sq_s3_p;

   wire [0:`THREADS-1] 						rv_axu0_vld;
   wire 							rv_axu0_s1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_s1_p;
   wire [0:2] 							rv_axu0_s1_t;
   wire 							rv_axu0_s2_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_s2_p;
   wire [0:2] 							rv_axu0_s2_t;
   wire 							rv_axu0_s3_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_s3_p;
   wire [0:2] 							rv_axu0_s3_t;
   wire 							rv_axu0_s1_spec;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_axu0_s1_itag;
   wire 							rv_axu0_s2_spec;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_axu0_s2_itag;
   wire 							rv_axu0_s3_spec;
   wire [0:`ITAG_SIZE_ENC-1] 					rv_axu0_s3_itag;

   wire [0:`ITAG_SIZE_ENC-1] 					rv_axu0_ex0_itag;
   wire [0:31] 							rv_axu0_ex0_instr;
   wire [0:2] 							rv_axu0_ex0_ucode;
   wire 							rv_axu0_ex0_t1_v;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_ex0_t1_p;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_ex0_t2_p;
   wire [0:`GPR_POOL_ENC-1] 					rv_axu0_ex0_t3_p;


   wire 							axu0_rv_ord_complete;

   wire 							sq_rv_itag0_vld;
   wire [0:`ITAG_SIZE_ENC-1] 					sq_rv_itag0;
   wire [0:`THREADS-1] 						iu_lq_i0_completed;
   wire [0:`THREADS-1] 						iu_lq_i1_completed;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_lq_t0_i0_completed_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_lq_t0_i1_completed_itag;
`ifndef THREADS1
   wire [0:`ITAG_SIZE_ENC-1] 					iu_lq_t1_i0_completed_itag;
   wire [0:`ITAG_SIZE_ENC-1] 					iu_lq_t1_i1_completed_itag;
`endif
   wire [0:`THREADS-1] 						iu_lq_recirc_val;
   wire [64-(2**`GPR_WIDTH_ENC):63] 				iu_lq_ls5_tlb_data;
   wire [0:`THREADS-1] 						fu_lq_ex2_store_data_val;
   wire [0:`ITAG_SIZE_ENC-1] 					fu_lq_ex2_store_itag;
   wire [(128-`STQ_DATA_SIZE):127] 				fu_lq_ex3_store_data;
   wire [0:`THREADS-1] 						mm_lq_lsu_req;
   wire [0:1] 							mm_lq_lsu_ttype;
   wire [0:4] 							mm_lq_lsu_wimge;
   wire [0:3] 							mm_lq_lsu_u;
   wire [64-`REAL_IFAR_WIDTH:63] 				mm_lq_lsu_addr;
   wire [0:7] 							mm_lq_lsu_lpid;
   wire [0:7] 							mm_lq_lsu_lpidr;
   wire 							mm_lq_lsu_gs;
   wire 							mm_lq_lsu_ind;
   wire 							mm_lq_lsu_lbit;
   wire 							lq_mm_lsu_token;
   wire 							xu_lq_xucr0_aflsta;
   wire 							xu_lq_xucr0_cred;
   wire 							xu_lq_xucr0_rel;
   wire 							xu_lq_xucr0_flsta;
   wire 							xu_lq_xucr0_l2siw;
   wire 							xu_lq_xucr0_flh2l2;
   wire 							xu_lq_xucr0_dc_dis;
   wire 							xu_lq_xucr0_wlk;
   wire 							xu_lq_xucr0_clfc;
   wire 							xu_lq_xucr0_bypErat;
   wire 							lq_mm_derat_req;
   wire [0:51] 							lq_mm_derat_epn;
   wire [0:`THREADS-1] 						lq_mm_derat_thdid;
   wire [0:`EMQ_ENTRIES-1] 					lq_mm_derat_req_emq;
   wire [0:1] 							lq_mm_derat_ttype;
   wire [0:3] 							lq_mm_derat_state;
   wire [0:7] 							lq_mm_derat_lpid;
   wire [0:13] 							lq_mm_derat_tid;
   wire 							lq_mm_derat_req_nonspec;
   wire [0:`ITAG_SIZE_ENC-1] 					lq_mm_derat_req_itag;
   wire [0:`THREADS-1] 						lq_mm_perf_dtlb;
   wire [0:4] 							mm_lq_derat_rel_val;
   wire [0:131] 						mm_lq_derat_rel_data;
   wire [0:`EMQ_ENTRIES-1] 					mm_lq_derat_rel_emq;
   wire [0:`ITAG_SIZE_ENC-1] 					mm_lq_derat_rel_itag;
   wire 							mm_lq_derat_snoop_coming;
   wire 							mm_lq_derat_snoop_val;
   wire [0:25] 							mm_lq_derat_snoop_attr;
   wire [(62-`EFF_IFAR_ARCH):51] 				mm_lq_derat_snoop_vpn;
   wire 							lq_mm_derat_snoop_ack;
   wire [0:13] 							mm_lq_t0_derat_pid;
   wire [0:19] 							mm_lq_t0_derat_mmucr0;
`ifndef THREADS1
   wire [0:13] 							mm_lq_t1_derat_pid;
   wire [0:19] 							mm_lq_t1_derat_mmucr0;
`endif
   wire [0:17] 							lq_mm_derat_mmucr0;
   wire [0:`THREADS-1] 						lq_mm_derat_mmucr0_we;
   wire [0:9] 							mm_lq_derat_mmucr1;
   wire [0:4] 							lq_mm_derat_mmucr1;
   wire [0:`THREADS-1]						lq_mm_derat_mmucr1_we;
   wire 							lq_mm_lmq_stq_empty;
   // Interface to BR
   // Interface to AXU
   wire [59:63] 						lq_fu_ex4_eff_addr;
   wire 							lq_fu_ex5_load_val;
   wire 							lq_fu_ex5_load_le;
   wire [(128-`STQ_DATA_SIZE):127] 				lq_fu_ex5_load_data;

   // Ram interface
   wire [0:31] 							pc_iu_ram_instr;
   wire [0:3] 							pc_iu_ram_instr_ext;
   wire [0:`THREADS-1] 						pc_iu_ram_active;
   wire [0:`THREADS-1] 						pc_iu_ram_flush_thread;
   wire 							pc_iu_ram_issue;
   wire 							iu_pc_ram_done;
   wire 							iu_pc_ram_interrupt;
   wire 							iu_pc_ram_unsupported;
   wire 							xu_pc_ram_data_val;
   wire [64-(2**`GPR_WIDTH_ENC):63] 				xu_pc_ram_data;
   wire 							xu_pc_ram_exception;
   wire [0:`THREADS-1] 						pc_xu_ram_active;
   wire 							pc_xu_msrovride_enab;
   wire [0:`THREADS-1] 						xu_iu_msrovride_enab;
   wire 							pc_xu_msrovride_pr;
   wire 							pc_xu_msrovride_gs;
   wire 							pc_xu_msrovride_de;
   wire [0:`THREADS-1] 						pc_lq_ram_active;
   wire 							lq_pc_ram_data_val;
   wire [64-(2**`GPR_WIDTH_ENC):63] 				lq_pc_ram_data;
   // PC control
   wire [0:`THREADS-1] 						pc_iu_stop;
   wire [0:`THREADS-1] 						pc_iu_step;
   wire [0:`THREADS-1] 						iu_pc_step_done;
   wire [0:`THREADS-1] 						iu_pc_stop_dbg_event;
   wire [0:`THREADS-1] 						xu_pc_stop_dnh_instr;
   wire [0:2] 							pc_iu_t0_dbg_action;
`ifndef THREADS1
   wire [0:2] 							pc_iu_t1_dbg_action;
`endif
   wire [0:3*`THREADS-1] 					pc_iu_dbg_action_int;
   wire 							pc_xu_extirpts_dis_on_stop;
   wire 							pc_xu_timebase_dis_on_stop;
   wire 							pc_xu_decrem_dis_on_stop;
   wire 							ac_an_power_managed_int;
   wire [0:`THREADS-1] 						pc_xu_spr_dbcr0_edm;
   wire [0:`THREADS-1] 						pc_iu_spr_dbcr0_edm;

   // MSR connections
   wire [0:`THREADS-1] 						spr_msr_ucle;
   wire [0:`THREADS-1] 						spr_msr_spv;
   wire [0:`THREADS-1] 						spr_msr_fp;
   wire [0:`THREADS-1] 						spr_msr_fe0;
   wire [0:`THREADS-1] 						spr_msr_fe1;
   wire [0:`THREADS-1] 						spr_msr_de;
   wire [0:`THREADS-1] 						spr_msrp_uclep;
   wire [0:`THREADS-1] 						spr_msr_pr;
   wire [0:`THREADS-1] 						spr_msr_is;
   wire [0:`THREADS-1] 						spr_msr_cm;
   wire [0:`THREADS-1] 						spr_msr_gs;
   wire [0:`THREADS-1] 						spr_msr_ee;
   wire [0:`THREADS-1] 						spr_msr_ce;
   wire [0:`THREADS-1] 						spr_msr_me;
   wire [0:`THREADS-1] 						spr_msr_ds;
   wire [0:`THREADS-1] 						spr_dbcr0_idm;
   wire [0:`THREADS-1] 						spr_dbcr0_icmp;
   wire [0:`THREADS-1] 						spr_dbcr0_brt;
   wire [0:`THREADS-1] 						spr_dbcr0_irpt;
   wire [0:`THREADS-1] 						spr_dbcr0_trap;
   wire [0:`THREADS-1] 						xu_iu_iac1_en;
   wire [0:`THREADS-1] 						xu_iu_iac2_en;
   wire [0:`THREADS-1] 						xu_iu_iac3_en;
   wire [0:`THREADS-1] 						xu_iu_iac4_en;
   wire [0:`THREADS*2-1] 					spr_dbcr0_dac1;
   wire [0:`THREADS*2-1] 					spr_dbcr0_dac2;
   wire [0:`THREADS*2-1] 					spr_dbcr0_dac3;
   wire [0:`THREADS*2-1] 					spr_dbcr0_dac4;
   wire [0:`THREADS-1] 						spr_dbcr0_ret;
   wire [0:`THREADS-1] 						spr_dbcr1_iac12m;
   wire [0:`THREADS-1] 						spr_dbcr1_iac34m;
   wire 							spr_ccr2_en_dcr;
   wire 							spr_ccr2_en_trace;
   wire 							spr_ccr2_en_pc;
   wire [0:8] 							spr_ccr2_ifratsc;
   wire 							spr_ccr2_ifrat;
   wire [0:8] 							spr_ccr2_dfratsc;
   wire 							spr_ccr2_dfrat;
   wire 							spr_ccr2_ucode_dis;
   wire [0:3] 							spr_ccr2_ap;
   wire 							spr_ccr2_en_attn;
   wire 							spr_ccr2_en_ditc;
   wire 							spr_ccr2_en_icswx;
   wire 							spr_ccr2_notlb;
   wire 							spr_xucr0_clfc;
   wire 							spr_xucr0_cls;
   wire 							spr_xucr0_mbar_ack;
   wire 							spr_xucr0_tlbsync;
   wire 							spr_xucr0_aflsta;
   wire 							spr_xucr0_mddp;
   wire 							spr_xucr0_cred;
   wire 							spr_xucr0_rel;
   wire 							spr_xucr0_mdcp;
   wire 							spr_xucr0_flsta;
   wire 							spr_xucr0_l2siw;
   wire 							spr_xucr0_flh2l2;
   wire 							spr_xucr0_dc_dis;
   wire 							spr_xucr0_wlk;
   wire [0:3] 							spr_xucr0_trace_um;
   wire 							spr_cpcr2_lsu_inorder;

   wire [0:`THREADS-1] 						xu_iu_epcr_extgs;
   wire [0:`THREADS-1] 						xu_iu_epcr_dtlbgs;
   wire [0:`THREADS-1] 						xu_iu_epcr_itlbgs;
   wire [0:`THREADS-1] 						xu_iu_epcr_dsigs;
   wire [0:`THREADS-1] 						xu_iu_epcr_isigs;
   wire [0:`THREADS-1] 						xu_iu_epcr_duvd;
   wire [0:`THREADS-1] 						spr_epcr_dgtmi;
   wire [0:`THREADS-1] 						xu_iu_epcr_icm;
   wire [0:`THREADS-1] 						xu_iu_epcr_gicm;
   wire [0:`THREADS-1] 						xu_mm_spr_epcr_dmiuh;
   wire 							iu_lq_spr_iucr0_icbi_ack;

   //-------------------------------------------------------------------
   // Interface from bypass to units
   //-------------------------------------------------------------------
   // Interface with FXU0
   //-------------------------------------------------------------------
   wire [1:11] 							rv_fx0_ex0_s1_fx0_sel;
   wire [1:11] 							rv_fx0_ex0_s2_fx0_sel;
   wire [1:11] 							rv_fx0_ex0_s3_fx0_sel;
   wire [4:8] 							rv_fx0_ex0_s1_lq_sel;
   wire [4:8] 							rv_fx0_ex0_s2_lq_sel;
   wire [4:8] 							rv_fx0_ex0_s3_lq_sel;
   wire [1:6] 							rv_fx0_ex0_s1_fx1_sel;
   wire [1:6] 							rv_fx0_ex0_s2_fx1_sel;
   wire [1:6] 							rv_fx0_ex0_s3_fx1_sel;

   //-------------------------------------------------------------------
   // Interface with LQ
   //-------------------------------------------------------------------
   wire [2:12] 							rv_lq_ex0_s1_fx0_sel;
   wire [2:12] 							rv_lq_ex0_s2_fx0_sel;
   wire [4:8] 							rv_lq_ex0_s1_lq_sel;
   wire [4:8] 							rv_lq_ex0_s2_lq_sel;
   wire [2:7] 							rv_lq_ex0_s1_fx1_sel;
   wire [2:7] 							rv_lq_ex0_s2_fx1_sel;

   //-------------------------------------------------------------------
   // Interface with FXU1
   //-------------------------------------------------------------------
   wire [1:11] 							rv_fx1_ex0_s1_fx0_sel;
   wire [1:11] 							rv_fx1_ex0_s2_fx0_sel;
   wire [1:11] 							rv_fx1_ex0_s3_fx0_sel;
   wire [4:8] 							rv_fx1_ex0_s1_lq_sel;
   wire [4:8] 							rv_fx1_ex0_s2_lq_sel;
   wire [4:8] 							rv_fx1_ex0_s3_lq_sel;
   wire [1:6] 							rv_fx1_ex0_s1_fx1_sel;
   wire [1:6] 							rv_fx1_ex0_s2_fx1_sel;
   wire [1:6] 							rv_fx1_ex0_s3_fx1_sel;

   wire [2:3] 							rv_fx0_ex0_s1_rel_sel;
   wire [2:3] 							rv_fx0_ex0_s2_rel_sel;
   wire [2:3] 							rv_fx0_ex0_s3_rel_sel;
   wire [2:3] 							rv_lq_ex0_s1_rel_sel;
   wire [2:3] 							rv_lq_ex0_s2_rel_sel;
   wire [2:3] 							rv_fx1_ex0_s1_rel_sel;
   wire [2:3] 							rv_fx1_ex0_s2_rel_sel;
   wire [2:3] 							rv_fx1_ex0_s3_rel_sel;



   wire [0:3] 							lq_xu_ex5_cr;
   wire [64-`GPR_WIDTH:63] 					fxu0_fxu1_ex3_rt;
   wire [0:3] 							fxu0_fxu1_ex3_cr;
   wire [0:9] 							fxu0_fxu1_ex3_xer;
   wire [64-`GPR_WIDTH:63] 					fxu1_fxu0_ex3_rt;
   wire [0:3] 							fxu1_fxu0_ex3_cr;
   wire [0:9] 							fxu1_fxu0_ex3_xer;
   wire [64-`GPR_WIDTH:63] 					xu0_lq_ex3_rt;
   wire [64-`GPR_WIDTH:63] 					xu0_lq_ex4_rt;
   wire 							xu1_lq_ex3_act;
   wire [64-`GPR_WIDTH:63] 					xu0_lq_ex6_rt;
   wire 							xu1_lq_ex6_act;
   wire                             xu1_lq_ex3_abort;
   wire [64-`GPR_WIDTH:63] 					xu1_lq_ex3_rt;
   wire 							xu0_lq_ex3_act;
   wire                             xu0_lq_ex3_abort;
   wire 							xu1_lq_ex3_illeg_lswx;
   wire 							xu1_lq_ex3_strg_noop;
   wire [0:`THREADS-1] 						xu1_lq_ex2_stq_val;
   wire [0:`ITAG_SIZE_ENC-1] 					xu1_lq_ex2_stq_itag;
   wire [1:4] 							xu1_lq_ex2_stq_size;
   wire [(64-`GPR_WIDTH)/8:7] 					xu1_lq_ex2_stq_dvc1_cmp;
   wire [(64-`GPR_WIDTH)/8:7] 					xu1_lq_ex2_stq_dvc2_cmp;

   wire 							        lq_xu_ex5_act;
   wire [64-`GPR_WIDTH:63] 					lq_xu_ex5_rt;
   wire                                     lq_xu_ex5_abort;
   wire                                      xu_axu_lq_ex5_abort;

   // REMOVE THESE AS REAL CONNECTIONS COME IN
   wire [0:`CR_POOL_ENC-1] 					cr_r3a;
   wire [0:3] 							cr_r3d;
   wire 							axu0_cr_w4e;
   wire [0:`CR_POOL_ENC+`THREADS_POOL_ENC-1] 			axu0_cr_w4a;
   wire [0:3] 							axu0_cr_w4d;
   wire [0:`XER_POOL_ENC-1] 					xer_r1a;
   wire [0:9] 							xer_r1d;
   wire [0:`XER_POOL_ENC-1] 					xer_r2a;
   wire [0:9] 							xer_r2d;
   wire [0:`XER_POOL_ENC-1] 					xer_r3a;
   wire [0:9] 							xer_r3d;
   wire [0:`XER_POOL_ENC-1] 					xer_r4a;
   wire [0:9] 							xer_r4d;
   wire [0:`XER_POOL_ENC-1] 					xer_r5a;
   wire [0:9] 							xer_r5d;
   wire [0:`XER_POOL_ENC-1] 					xer_r6a;
   wire [0:9] 							xer_r6d;

   // Scan connections
   wire 							scan_in_ic;
   wire 							scan_out_ic;
   wire 							scan_in_rv;
   wire 							scan_out_rv;
   wire [0:3] 							scan_in_xu;
   wire [0:3] 							scan_out_xu;
   wire [0:24] 							scan_in_lq;
   wire [0:24] 							scan_out_lq;
   wire 							scan_in_rf_gpr;
   wire 							scan_out_rf_gpr;
   wire 							scan_in_rf_ctr;
   wire 							scan_out_rf_ctr;
   wire 							scan_in_rf_lr;
   wire 							scan_out_rf_lr;
   wire 							scan_in_rf_cr;
   wire 							scan_out_rf_cr;
   wire 							scan_in_rf_xer;
   wire 							scan_out_rf_xer;
   wire 							scan_in_br;
   wire 							scan_out_br;
   wire 							scan_in_rv_byp;
   wire 							scan_out_rv_byp;

   // Need to think about where these go
   wire [0:`THREADS-1] 						iu_xu_icache_quiesce;
   wire [0:`THREADS-1] 						iu_pc_icache_quiesce;
   wire 							iu_mm_lmq_empty;
   wire 							force_xhdl0;
   wire [0:`THREADS-1] 						iu_xu_stop;
   wire [0:`THREADS-1] 						xu_iu_run_thread;
   wire [0:`THREADS-1] 						xu_iu_single_instr_mode;
   wire [0:`THREADS-1]                 xu_iu_raise_iss_pri;
   wire [0:`THREADS-1] 						xu_iu_np1_async_flush;
   wire [0:`THREADS-1] 						iu_xu_async_complete;
   wire                                     iu_xu_credits_returned;
   wire [0:`THREADS-1] 						iu_xu_quiesce;
   wire [0:`THREADS-1] 						iu_pc_quiesce;
   wire [0:`THREADS-1] 						iu_xu_act;
   wire [0:`THREADS-1] 						iu_xu_rfi;
   wire [0:`THREADS-1] 						iu_xu_rfgi;
   wire [0:`THREADS-1] 						iu_xu_rfci;
   wire [0:`THREADS-1] 						iu_xu_rfmci;
   wire [0:`THREADS-1] 						iu_xu_int;
   wire [0:`THREADS-1] 						iu_xu_gint;
   wire [0:`THREADS-1] 						iu_xu_cint;
   wire [0:`THREADS-1] 						iu_xu_mcint;
   wire [62-`EFF_IFAR_ARCH:61] 				       	iu_xu_t0_nia;
   wire [0:16] 							iu_xu_t0_esr;
   wire [0:14]     						iu_xu_t0_mcsr;
   wire [0:18] 							iu_xu_t0_dbsr;
   wire [64-`GPR_WIDTH:63] 					iu_xu_t0_dear;
`ifndef THREADS1
   wire [62-`EFF_IFAR_ARCH:61] 				       	iu_xu_t1_nia;
   wire [0:16] 							iu_xu_t1_esr;
   wire [0:14]     						iu_xu_t1_mcsr;
   wire [0:18] 							iu_xu_t1_dbsr;
   wire [64-`GPR_WIDTH:63] 					iu_xu_t1_dear;
`endif
   wire [0:`THREADS-1] 						iu_xu_dear_update;
   wire [0:`THREADS-1] 						iu_xu_dbsr_update;
   wire [0:`THREADS-1] 						iu_xu_dbsr_ude;
   wire [0:`THREADS-1] 						iu_xu_dbsr_ide;
   wire [0:`THREADS-1] 						iu_xu_esr_update;
   wire [0:`THREADS-1] 						iu_xu_dbell_taken;
   wire [0:`THREADS-1] 						iu_xu_cdbell_taken;
   wire [0:`THREADS-1] 						iu_xu_gdbell_taken;
   wire [0:`THREADS-1] 						iu_xu_gcdbell_taken;
   wire [0:`THREADS-1] 						iu_xu_gmcdbell_taken;
   wire [0:`THREADS-1] 						xu_iu_dbsr_ide;
   wire [0:`THREADS-1] 						iu_xu_instr_cpl;

   wire [0:`THREADS-1] 						xu_iu_external_mchk;
   wire [0:`THREADS-1] 						xu_iu_ext_interrupt;
   wire [0:`THREADS-1] 						xu_iu_dec_interrupt;
   wire [0:`THREADS-1] 						xu_iu_udec_interrupt;
   wire [0:`THREADS-1] 						xu_iu_perf_interrupt;
   wire [0:`THREADS-1] 						xu_iu_fit_interrupt;
   wire [0:`THREADS-1] 						xu_iu_crit_interrupt;
   wire [0:`THREADS-1] 						xu_iu_wdog_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gwdog_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gfit_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gdec_interrupt;
   wire [0:`THREADS-1] 						xu_iu_dbell_interrupt;
   wire [0:`THREADS-1] 						xu_iu_cdbell_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gdbell_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gcdbell_interrupt;
   wire [0:`THREADS-1] 						xu_iu_gmcdbell_interrupt;
   wire [62-`EFF_IFAR_ARCH:61]					xu_iu_t0_rest_ifar;
`ifndef THREADS1
   wire [62-`EFF_IFAR_ARCH:61]					xu_iu_t1_rest_ifar;
`endif
   wire [0:`THREADS-1] 						lq_xu_quiesce;
   wire [0:`THREADS-1] 						mm_xu_quiesce;
   wire [0:`THREADS-1] 						mm_pc_tlb_req_quiesce;
   wire [0:`THREADS-1] 						mm_pc_tlb_ctl_quiesce;
   wire [0:`THREADS-1] 						mm_pc_htw_quiesce;
   wire [0:`THREADS-1] 						mm_pc_inval_quiesce;
   wire [0:`THREADS-1] 						xu_pc_running;
   wire [0:`THREADS-1]						lq_pc_ldq_quiesce;
   wire [0:`THREADS-1]						lq_pc_stq_quiesce;
   wire [0:`THREADS-1]						lq_pc_pfetch_quiesce;

   // PCQ Signals
   wire 							rp_pc_scom_dch_q;
   wire 							rp_pc_scom_cch_q;
   wire 							pc_rp_scom_dch;
   wire 							pc_rp_scom_cch;
   // pcq error related and FIRs
   wire [0:`THREADS-1] 						pc_rp_special_attn;
   wire [0:2] 							pc_rp_checkstop;
   wire [0:2] 							pc_rp_local_checkstop;
   wire [0:2] 							pc_rp_recov_err;
   wire 							pc_rp_trace_error;
   wire 							pc_rp_livelock_active;
   wire 							rp_pc_checkstop_q;
   wire 							lq_pc_err_dcache_parity;
   wire 							lq_pc_err_dcachedir_ldp_parity;
   wire 							lq_pc_err_dcachedir_stp_parity;
   wire 							lq_pc_err_dcachedir_ldp_multihit;
   wire 							lq_pc_err_dcachedir_stp_multihit;
   wire 							lq_pc_err_prefetcher_parity;
   wire								iu_pc_err_btb_parity;
   wire								lq_pc_err_relq_parity;
   wire [0:`THREADS-1] 						xu_pc_err_sprg_ecc;
   wire [0:`THREADS-1] 						xu_pc_err_sprg_ue;
   wire [0:`THREADS-1] 						xu_pc_err_regfile_parity;
   wire [0:`THREADS-1] 						xu_pc_err_regfile_ue;
   wire [0:`THREADS-1] 						lq_pc_err_regfile_parity;
   wire [0:`THREADS-1] 						lq_pc_err_regfile_ue;
   wire 							lq_pc_err_l2intrf_ecc;
   wire 							lq_pc_err_l2intrf_ue;
   wire 							lq_pc_err_l2credit_overrun;
   wire 							lq_pc_err_invld_reld;
   wire [0:`THREADS-1] 						xu_pc_err_llbust_attempt;
   wire [0:`THREADS-1] 						xu_pc_err_llbust_failed;
   wire [0:`THREADS-1] 						xu_pc_err_wdt_reset;
   wire [0:`THREADS-1]     					iu_pc_err_cpArray_parity;
   wire [0:`THREADS-1] 						iu_pc_err_debug_event;
   wire [0:`THREADS-1] 						iu_pc_err_ucode_illegal;
   wire [0:`THREADS-1] 						iu_pc_err_mchk_disabled;
   wire 							lq_pc_err_derat_parity;
   wire 							lq_pc_err_derat_multihit;
   wire [0:`THREADS-1] 						iu_pc_err_attention_instr;
   wire 							pc_iu_inj_icachedir_multihit;
   wire 							pc_lq_inj_dcache_parity;
   wire 							pc_lq_inj_dcachedir_ldp_parity;
   wire 							pc_lq_inj_dcachedir_stp_parity;
   wire 							pc_lq_inj_dcachedir_ldp_multihit;
   wire 							pc_lq_inj_dcachedir_stp_multihit;
   wire 							pc_lq_inj_prefetcher_parity;
   wire								pc_lq_inj_relq_parity;
   wire [0:`THREADS-1] 						pc_lq_inj_regfile_parity;
   wire [0:`THREADS-1] 						pc_xu_inj_sprg_ecc;
   wire [0:`THREADS-1] 						pc_fx0_inj_regfile_parity;
   wire [0:`THREADS-1] 						pc_fx1_inj_regfile_parity;
   wire [0:`THREADS-1] 						pc_xu_inj_llbust_attempt;
   wire [0:`THREADS-1] 						pc_xu_inj_llbust_failed;
   wire [0:`THREADS-1]     					pc_iu_inj_cpArray_parity;
   // pcq power management + resets
   wire [0:`THREADS-1] 						rp_pc_pm_thread_stop_q;
   wire [0:`THREADS-1] 						rp_pc_pm_fetch_halt_q;
   wire [0:1] 							xu_pc_spr_ccr0_pme;
   wire [0:`THREADS-1] 						pc_iu_pm_fetch_halt;
   wire [0:`THREADS-1] 						xu_pc_spr_ccr0_we;
   wire [0:`THREADS-1] 						pc_rp_pm_thread_running;
   wire 							pc_rp_power_managed;
   wire 							pc_rp_rvwinkle_mode;
   wire 							pc_xu_pm_hold_thread;
   // pcq debug + perf events
   wire 							rp_pc_debug_stop_q;
   wire 							pc_iu_trace_bus_enable;
   wire 							pc_rv_trace_bus_enable;
   wire 							pc_mm_trace_bus_enable;
   wire 							pc_xu_trace_bus_enable;
   wire 							pc_lq_trace_bus_enable;
   wire [0:`THREADS-1] 						xu_pc_perfmon_alert;
   wire [0:`THREADS-1]                 				pc_xu_spr_cesr1_pmae;
   wire [0:10] 							pc_iu_debug_mux1_ctrls;
   wire [0:10] 							pc_iu_debug_mux2_ctrls;
   wire [0:10] 							pc_rv_debug_mux_ctrls;
   wire [0:10] 							pc_mm_debug_mux_ctrls;
   wire [0:10] 							pc_xu_debug_mux_ctrls;
   wire [0:10] 							pc_lq_debug_mux1_ctrls;
   wire [0:10] 							pc_lq_debug_mux2_ctrls;
   wire 							pc_xu_cache_par_err_event;
   wire 							pc_iu_event_bus_enable;
   wire 							pc_rv_event_bus_enable;
   wire 							pc_rp_event_bus_enable;
   wire 							pc_mm_event_bus_enable;
   wire 							pc_xu_event_bus_enable;
   wire 							pc_lq_event_bus_enable;
   wire [0:2] 							pc_iu_event_count_mode;
   wire [0:2] 							pc_rv_event_count_mode;
   wire [0:2] 							pc_mm_event_count_mode;
   wire [0:2] 							pc_xu_event_count_mode;
   wire [0:2] 							pc_lq_event_count_mode;

   wire [0:39] 							pc_rv_event_mux_ctrls;
   wire [0:7] 							rv_rp_event_bus;

   wire 							pc_iu_instr_trace_mode;
   wire [0:1] 							pc_iu_instr_trace_tid;
   wire 							pc_lq_instr_trace_mode;
   wire [0:`THREADS-1] 						pc_lq_instr_trace_tid;
   wire 							pc_xu_instr_trace_mode;
   wire [0:1] 							pc_xu_instr_trace_tid;
   wire 							pc_lq_event_bus_seldbghi;
   wire 							pc_lq_event_bus_seldbglo;
   // pcq clock + scan controls
   wire 							rp_pc_rtim_sl_thold_7;
   wire 							rp_pc_func_sl_thold_7;
   wire 							rp_pc_func_nsl_thold_7;
   wire 							rp_pc_ary_nsl_thold_7;
   wire 							rp_pc_sg_7;
   wire 							rp_pc_fce_7;
   wire 							pc_rp_ccflush_out_dc;
   wire 							pc_rp_gptr_sl_thold_4;
   wire 							pc_rp_time_sl_thold_4;
   wire 							pc_rp_repr_sl_thold_4;
   wire 							pc_rp_abst_sl_thold_4;
   wire 							pc_rp_abst_slp_sl_thold_4;
   wire 							pc_rp_regf_sl_thold_4;
   wire 							pc_rp_regf_slp_sl_thold_4;
   wire 							pc_rp_func_sl_thold_4;
   wire 							pc_rp_func_slp_sl_thold_4;
   wire 							pc_rp_cfg_sl_thold_4;
   wire 							pc_rp_cfg_slp_sl_thold_4;
   wire 							pc_rp_func_nsl_thold_4;
   wire 							pc_rp_func_slp_nsl_thold_4;
   wire 							pc_rp_ary_nsl_thold_4;
   wire 							pc_rp_ary_slp_nsl_thold_4;
   wire 							pc_rp_rtim_sl_thold_4;
   wire 							pc_rp_sg_4;
   wire 							pc_rp_fce_4;
   wire 							rp_iu_ccflush_dc;
   wire 							rp_iu_gptr_sl_thold_3;
   wire 							rp_iu_time_sl_thold_3;
   wire 							rp_iu_repr_sl_thold_3;
   wire 							rp_iu_abst_sl_thold_3;
   wire 							rp_iu_abst_slp_sl_thold_3;
   wire 							rp_iu_regf_slp_sl_thold_3;
   wire 							rp_iu_func_sl_thold_3;
   wire 							rp_iu_func_slp_sl_thold_3;
   wire 							rp_iu_cfg_sl_thold_3;
   wire 							rp_iu_cfg_slp_sl_thold_3;
   wire 							rp_iu_func_nsl_thold_3;
   wire 							rp_iu_func_slp_nsl_thold_3;
   wire 							rp_iu_ary_nsl_thold_3;
   wire 							rp_iu_ary_slp_nsl_thold_3;
   wire 							rp_iu_sg_3;
   wire 							rp_iu_fce_3;
   wire 							rp_rv_ccflush_dc;
   wire 							rp_rv_gptr_sl_thold_3;
   wire 							rp_rv_time_sl_thold_3;
   wire 							rp_rv_repr_sl_thold_3;
   wire 							rp_rv_abst_sl_thold_3;
   wire 							rp_rv_abst_slp_sl_thold_3;
   wire 							rp_rv_func_sl_thold_3;
   wire 							rp_rv_func_slp_sl_thold_3;
   wire 							rp_rv_cfg_sl_thold_3;
   wire 							rp_rv_cfg_slp_sl_thold_3;
   wire 							rp_rv_func_nsl_thold_3;
   wire 							rp_rv_func_slp_nsl_thold_3;
   wire 							rp_rv_ary_nsl_thold_3;
   wire 							rp_rv_ary_slp_nsl_thold_3;
   wire 							rp_rv_sg_3;
   wire 							rp_rv_fce_3;
   wire 							rp_xu_ccflush_dc;
   wire 							rp_xu_gptr_sl_thold_3;
   wire 							rp_xu_time_sl_thold_3;
   wire 							rp_xu_repr_sl_thold_3;
   wire 							rp_xu_abst_sl_thold_3;
   wire 							rp_xu_abst_slp_sl_thold_3;
   wire 							rp_xu_regf_slp_sl_thold_3;
   wire 							rp_xu_func_sl_thold_3;
   wire 							rp_xu_func_slp_sl_thold_3;
   wire 							rp_xu_cfg_sl_thold_3;
   wire 							rp_xu_cfg_slp_sl_thold_3;
   wire 							rp_xu_func_nsl_thold_3;
   wire 							rp_xu_func_slp_nsl_thold_3;
   wire 							rp_xu_ary_nsl_thold_3;
   wire 							rp_xu_ary_slp_nsl_thold_3;
   wire 							rp_xu_sg_3;
   wire 							rp_xu_fce_3;
   wire [0:4] 							TEMP_rp_xu_func_sl_thold_3;
   wire [0:4] 							TEMP_rp_xu_func_slp_sl_thold_3;
   wire [0:4] 							TEMP_rp_xu_sg_3;
   wire [0:1] 							TEMP_rp_xu_fce_3;
   wire 							rp_lq_ccflush_dc;
   wire 							rp_lq_gptr_sl_thold_3;
   wire 							rp_lq_time_sl_thold_3;
   wire 							rp_lq_repr_sl_thold_3;
   wire 							rp_lq_abst_sl_thold_3;
   wire 							rp_lq_abst_slp_sl_thold_3;
   wire 							rp_lq_regf_slp_sl_thold_3;
   wire 							rp_lq_func_sl_thold_3;
   wire 							rp_lq_func_slp_sl_thold_3;
   wire 							rp_lq_cfg_sl_thold_3;
   wire 							rp_lq_cfg_slp_sl_thold_3;
   wire 							rp_lq_func_nsl_thold_3;
   wire 							rp_lq_func_slp_nsl_thold_3;
   wire 							rp_lq_ary_nsl_thold_3;
   wire 							rp_lq_ary_slp_nsl_thold_3;
   wire 							rp_lq_sg_3;
   wire 							rp_lq_fce_3;
   wire 							rp_mm_ccflush_dc;
   wire 							rp_mm_gptr_sl_thold_3;
   wire 							rp_mm_time_sl_thold_3;
   wire 							rp_mm_repr_sl_thold_3;
   wire 							rp_mm_abst_sl_thold_3;
   wire 							rp_mm_abst_slp_sl_thold_3;
   wire 							rp_mm_func_sl_thold_3;
   wire 							rp_mm_func_slp_sl_thold_3;
   wire 							rp_mm_cfg_sl_thold_3;
   wire 							rp_mm_cfg_slp_sl_thold_3;
   wire 							rp_mm_func_nsl_thold_3;
   wire 							rp_mm_func_slp_nsl_thold_3;
   wire 							rp_mm_ary_nsl_thold_3;
   wire 							rp_mm_ary_slp_nsl_thold_3;
   wire 							rp_mm_sg_3;
   wire 							rp_mm_fce_3;
   wire [0:1] 							TEMP_rp_mm_func_sl_thold_3;
   wire [0:1] 							TEMP_rp_mm_func_slp_sl_thold_3;
   wire [0:1] 							TEMP_rp_mm_sg_3;
   wire [8:15] 							spr_pvr_version_dc;
   wire [12:15] 						spr_pvr_revision_dc;
   wire [16:19] 						spr_pvr_revision_minor_dc;
   wire 							spr_xucr4_mmu_mchk;
   wire 							spr_xucr4_mddmh;
   // Unit Trace bus signals
   wire [0:31] 							fu_debug_bus_in;
   wire [0:31] 							fu_debug_bus_out;
   wire [0:3] 							fu_coretrace_ctrls_in;
   wire [0:3] 							fu_coretrace_ctrls_out;
   wire [0:31] 							mm_debug_bus_in;
   wire [0:31] 							mm_debug_bus_out;
   wire [0:3] 							mm_coretrace_ctrls_in;
   wire [0:3] 							mm_coretrace_ctrls_out;
   wire [0:31] 							xu_debug_bus_in;
   wire [0:31] 							xu_debug_bus_out;
   wire [0:3] 							xu_coretrace_ctrls_in;
   wire [0:3] 							xu_coretrace_ctrls_out;
   wire [0:31] 							lq_debug_bus_in;
   wire [0:31] 							lq_debug_bus_out;
   wire [0:3] 							lq_coretrace_ctrls_in;
   wire [0:3] 							lq_coretrace_ctrls_out;
   wire [0:31] 							rv_debug_bus_in;
   wire [0:31] 							rv_debug_bus_out;
   wire [0:3] 							rv_coretrace_ctrls_in;
   wire [0:3] 							rv_coretrace_ctrls_out;
   wire [0:31] 							iu_debug_bus_in;
   wire [0:31] 							iu_debug_bus_out;
   wire [0:3] 							iu_coretrace_ctrls_in;
   wire [0:3] 							iu_coretrace_ctrls_out;
   wire [0:31] 							pc_debug_bus_in;
   wire [0:31] 							pc_debug_bus_out;
   wire [0:3] 							pc_coretrace_ctrls_in;
   wire [0:3] 							pc_coretrace_ctrls_out;
   // Unit Event bus signals
   wire [0:4*`THREADS-1]         				fu_event_bus_in;
   wire [0:4*`THREADS-1]         				fu_event_bus_out;
   wire [0:4*`THREADS-1]         				mm_event_bus_in;
   wire [0:4*`THREADS-1]         				mm_event_bus_out;
   wire [0:4*`THREADS-1]         				xu_event_bus_in;
   wire [0:4*`THREADS-1]         				xu_event_bus_out;
   wire [0:4*`THREADS-1]         				lq_event_bus_in;
   wire [0:4*`THREADS-1]         				lq_event_bus_out;
   wire [0:4*`THREADS-1]         				rv_event_bus_in;
   wire [0:4*`THREADS-1]         				rv_event_bus_out;
   wire [0:4*`THREADS-1]         				iu_event_bus_in;
   wire [0:4*`THREADS-1]         				iu_event_bus0_out;
   wire [0:4*`THREADS-1]         				iu_event_bus1_out;


   wire [0:`THREADS-1]						iu_pc_fx0_credit_ok;
   wire [0:`THREADS-1]						iu_pc_fx1_credit_ok;
   wire [0:`THREADS-1]						iu_pc_axu0_credit_ok;
   wire [0:`THREADS-1]						iu_pc_axu1_credit_ok;
   wire [0:`THREADS-1]						iu_pc_lq_credit_ok;
   wire [0:`THREADS-1]						iu_pc_sq_credit_ok;



   wire [0:`THREADS-1] 						xu_mm_val;
   wire [0:`ITAG_SIZE_ENC-1] 					xu_mm_itag;

   wire [0:`THREADS-1] 						bx_xu_quiesce;		// inbox and outbox are empty

   wire 							func_sl_thold_0_b;

   wire [0:63] 							tidn;
   wire [0:63] 							tiup;

   // Temporary because of 2D arrays
   wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH] 		iu_br_t0_flush_ifar;
`ifndef THREADS1
   wire [62-`EFF_IFAR_ARCH : 61-`EFF_IFAR_WIDTH] 		iu_br_t1_flush_ifar;
`endif

   assign tidn = {64{1'b0}};
   assign tiup = {64{1'b1}};
   assign spr_pvr_version_dc = 8'h4c;
   assign spr_pvr_revision_dc = 4'h1;
   assign spr_pvr_revision_minor_dc = 4'h0;

   assign ac_an_power_managed = ac_an_power_managed_int;

   // XU-IU interface
   assign xu_iu_hid_mmu_mode = 1'b1;

   assign force_xhdl0 = 1'b0;


   // TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
   assign lq_rv_itag0_spec		= 1'b0;
   // TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP


   // LQ
   assign bx_xu_quiesce = {`THREADS{1'b1}};
   assign iu_lq_ls5_tlb_data = {(63-(64 - (2 ** `GPR_WIDTH_ENC))+1){1'b0}};
   assign lq_xu_ord_n_flush_req = 1'b0;

   // PC
   assign TEMP_rp_mm_func_sl_thold_3 = {2{rp_mm_func_sl_thold_3}};
   assign TEMP_rp_mm_func_slp_sl_thold_3 = {2{rp_mm_func_slp_sl_thold_3}};
   assign TEMP_rp_mm_sg_3 = {2{rp_mm_sg_3}};

   // Slow SPR ring connections
   assign lq_slowspr_val_in = xu_slowspr_val_out;
   assign lq_slowspr_rw_in = xu_slowspr_rw_out;
   assign lq_slowspr_etid_in = xu_slowspr_etid_out;
   assign lq_slowspr_addr_in = xu_slowspr_addr_out;
   assign lq_slowspr_data_in = xu_slowspr_data_out;
   assign lq_slowspr_done_in = 1'b0;
   assign iu_slowspr_val_in = lq_slowspr_val_out;
   assign iu_slowspr_rw_in = lq_slowspr_rw_out;
   assign iu_slowspr_etid_in = lq_slowspr_etid_out;
   assign iu_slowspr_addr_in = lq_slowspr_addr_out;
   assign iu_slowspr_data_in = lq_slowspr_data_out;
   assign iu_slowspr_done_in = lq_slowspr_done_out;
   assign mm_slowspr_val_in = iu_slowspr_val_out;
   assign mm_slowspr_rw_in = iu_slowspr_rw_out;
   assign mm_slowspr_etid_in = iu_slowspr_etid_out;
   assign mm_slowspr_addr_in = iu_slowspr_addr_out;
   assign mm_slowspr_data_in = iu_slowspr_data_out;
   assign mm_slowspr_done_in = iu_slowspr_done_out;
   assign pc_slowspr_val_in = mm_slowspr_val_out;
   assign pc_slowspr_rw_in = mm_slowspr_rw_out;
   assign pc_slowspr_etid_in = mm_slowspr_etid_out;
   assign pc_slowspr_addr_in = mm_slowspr_addr_out;
   assign pc_slowspr_data_in = mm_slowspr_data_out;
   assign pc_slowspr_done_in = mm_slowspr_done_out;
   assign fu_slowspr_val_in = pc_slowspr_val_out;
   assign fu_slowspr_rw_in = pc_slowspr_rw_out;
   assign fu_slowspr_etid_in = pc_slowspr_etid_out;
   assign fu_slowspr_addr_in = pc_slowspr_addr_out;
   assign fu_slowspr_data_in = pc_slowspr_data_out;
   assign fu_slowspr_done_in = pc_slowspr_done_out;
   assign xu_slowspr_val_in = fu_slowspr_val_out;
   assign xu_slowspr_rw_in = fu_slowspr_rw_out;
   assign xu_slowspr_etid_in = fu_slowspr_etid_out;
   assign xu_slowspr_addr_in = fu_slowspr_addr_out;
   assign xu_slowspr_data_in = fu_slowspr_data_out;
   assign xu_slowspr_done_in = fu_slowspr_done_out;

    // Trace bus connections
   assign mm_debug_bus_in	= {64{1'b0}};
   assign fu_debug_bus_in	= mm_debug_bus_out;
   assign pc_debug_bus_in	= fu_debug_bus_out;
   assign rv_debug_bus_in	= pc_debug_bus_out;
   assign iu_debug_bus_in	= rv_debug_bus_out;
   assign xu_debug_bus_in	= iu_debug_bus_out;
   assign lq_debug_bus_in	= xu_debug_bus_out;
   assign ac_an_debug_bus	= lq_debug_bus_out;

   assign mm_coretrace_ctrls_in	= { 4{1'b0}};
   assign fu_coretrace_ctrls_in	= mm_coretrace_ctrls_out;
   assign pc_coretrace_ctrls_in	= fu_coretrace_ctrls_out;
   assign rv_coretrace_ctrls_in	= pc_coretrace_ctrls_out;
   assign iu_coretrace_ctrls_in	= rv_coretrace_ctrls_out;
   assign xu_coretrace_ctrls_in	= iu_coretrace_ctrls_out;
   assign lq_coretrace_ctrls_in	= xu_coretrace_ctrls_out;
   assign ac_an_coretrace_first_valid = lq_coretrace_ctrls_out[0];
   assign ac_an_coretrace_valid = lq_coretrace_ctrls_out[1];
   assign ac_an_coretrace_type	= lq_coretrace_ctrls_out[2:3];

    // Performance Event bus connections
   assign mm_event_bus_in	= {4*`THREADS{1'b0}};
   assign fu_event_bus_in	= mm_event_bus_out;
   assign rv_event_bus_in	= fu_event_bus_out;
   assign xu_event_bus_in	= rv_event_bus_out;
   assign lq_event_bus_in	= xu_event_bus_out;
   assign iu_event_bus_in	= lq_event_bus_out;
   assign ac_an_event_bus0	= iu_event_bus0_out;
   assign ac_an_event_bus1	= iu_event_bus1_out;

   // TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP
   assign iu_event_bus1_out	= {4*`THREADS{1'b0}};
   // TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP TEMP


   // PC errors
   assign xu_pc_err_regfile_parity = {`THREADS{1'b0}};
   assign xu_pc_err_regfile_ue = {`THREADS{1'b0}};
   assign lq_pc_err_regfile_parity = {`THREADS{1'b0}};
   assign lq_pc_err_regfile_ue = {`THREADS{1'b0}};
   assign iu_pc_err_cpArray_parity = 1'b0;



   // Ties
   assign fx1_rv_hold_all = 1'b0;

   assign mm_xu_local_snoop_reject = |mm_iu_local_snoop_reject;

   assign pc_iu_t0_dbg_action = pc_iu_dbg_action_int[0:2];
   assign mm_xu_t0_mmucr0_tlbsel = mm_lq_t0_derat_mmucr0[4:5];
   assign iu_br_t0_flush_ifar = cp_t0_flush_ifar[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH];
`ifndef THREADS1
   assign pc_iu_t1_dbg_action = pc_iu_dbg_action_int[3:5];
   assign mm_xu_t1_mmucr0_tlbsel = mm_lq_t1_derat_mmucr0[4:5];
   assign iu_br_t1_flush_ifar = cp_t1_flush_ifar[62 - `EFF_IFAR_ARCH:61 - `EFF_IFAR_WIDTH];
`endif

   iuq
   iuq0(
	//.vcs(vcs),
	//.vdd(vdd),
	//.gnd(gnd),
	.nclk(nclk),
	.pc_iu_sg_3(rp_iu_sg_3),
	.pc_iu_fce_3(rp_iu_fce_3),
	.pc_iu_func_slp_sl_thold_3(rp_iu_func_slp_sl_thold_3),
	.pc_iu_func_nsl_thold_3(rp_iu_func_nsl_thold_3),
	.pc_iu_cfg_slp_sl_thold_3(rp_iu_cfg_slp_sl_thold_3),
	.pc_iu_regf_slp_sl_thold_3(rp_iu_regf_slp_sl_thold_3),
	.pc_iu_func_sl_thold_3(rp_iu_func_sl_thold_3),
	.pc_iu_time_sl_thold_3(rp_iu_time_sl_thold_3),
	.pc_iu_abst_sl_thold_3(rp_iu_abst_sl_thold_3),
	.pc_iu_abst_slp_sl_thold_3(rp_iu_abst_slp_sl_thold_3),
	.pc_iu_repr_sl_thold_3(rp_iu_repr_sl_thold_3),
	.pc_iu_ary_nsl_thold_3(rp_iu_ary_nsl_thold_3),
	.pc_iu_ary_slp_nsl_thold_3(rp_iu_ary_slp_nsl_thold_3),
	.pc_iu_func_slp_nsl_thold_3(rp_iu_func_slp_nsl_thold_3),
	.pc_iu_bolt_sl_thold_3(1'b0),
	.clkoff_b(1'b1),
	.act_dis(1'b0),
	.tc_ac_ccflush_dc(rp_iu_ccflush_dc),
	.tc_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
	.tc_ac_scan_diag_dc(an_ac_scan_diag_dc),
	.d_mode(1'b0),
	.delay_lclkr(1'b0),
	.mpw1_b(1'b0),
	.mpw2_b(1'b0),
	.scan_in(scan_in_ic),
	.scan_out(scan_out_ic),

	.pc_iu_abist_dcomp_g6t_2r({4{1'b0}}),
	.pc_iu_abist_di_0({4{1'b0}}),
	.pc_iu_abist_di_g6t_2r({4{1'b0}}),
	.pc_iu_abist_ena_dc(1'b0),
	.pc_iu_abist_g6t_bw(2'b0),
	.pc_iu_abist_g6t_r_wb(1'b0),
	.pc_iu_abist_g8t1p_renb_0(1'b0),
	.pc_iu_abist_g8t_bw_0(1'b0),
	.pc_iu_abist_g8t_bw_1(1'b0),
	.pc_iu_abist_g8t_dcomp({4{1'b0}}),
	.pc_iu_abist_g8t_wenb(1'b0),
	.pc_iu_abist_raddr_0({9{1'b0}}),
	.pc_iu_abist_raw_dc_b(1'b0),
	.pc_iu_abist_waddr_0({7{1'b0}}),
	.pc_iu_abist_wl128_comp_ena(1'b0),
	.pc_iu_abist_wl512_comp_ena(1'b0),
	.an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
	.an_ac_lbist_en_dc(an_ac_lbist_en_dc),
	.an_ac_atpg_en_dc(1'b0),
	.an_ac_grffence_en_dc(1'b0),

	.pc_iu_bo_enable_3(1'b0),
	.pc_iu_bo_reset(1'b0),
	.pc_iu_bo_unload(1'b0),
	.pc_iu_bo_repair(1'b0),
	.pc_iu_bo_shdata(1'b0),
	.pc_iu_bo_select({5{1'b0}}),
	.iu_pc_bo_fail(),
	.iu_pc_bo_diagout(),

	.iu_pc_err_ucode_illegal(iu_pc_err_ucode_illegal),

	// Cache inject
	.iu_pc_err_icache_parity(iu_pc_err_icache_parity),
	.iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
	.iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
	.iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
	.iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),
	.pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
	.pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
	.pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
	.pc_iu_init_reset(pc_iu_init_reset),

	// spr ring
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

	.xu_iu_msr_ucle(spr_msr_ucle),
	.xu_iu_msr_de(spr_msr_de),
	.xu_iu_msr_pr(spr_msr_pr),
	.xu_iu_msr_is(spr_msr_is),
	.xu_iu_msr_cm(spr_msr_cm),
	.xu_iu_msr_gs(spr_msr_gs),
	.xu_iu_msr_me(spr_msr_me),
	.xu_iu_dbcr0_edm(pc_iu_spr_dbcr0_edm),
	.xu_iu_dbcr0_idm(spr_dbcr0_idm),
	.xu_iu_dbcr0_icmp(spr_dbcr0_icmp),
	.xu_iu_dbcr0_brt(spr_dbcr0_brt),
	.xu_iu_dbcr0_irpt(spr_dbcr0_irpt),
	.xu_iu_dbcr0_trap(spr_dbcr0_trap),
	.xu_iu_iac1_en(xu_iu_iac1_en),
	.xu_iu_iac2_en(xu_iu_iac2_en),
	.xu_iu_iac3_en(xu_iu_iac3_en),
	.xu_iu_iac4_en(xu_iu_iac4_en),
	.xu_iu_t0_dbcr0_dac1(spr_dbcr0_dac1[0:1]),
	.xu_iu_t0_dbcr0_dac2(spr_dbcr0_dac2[0:1]),
	.xu_iu_t0_dbcr0_dac3(spr_dbcr0_dac3[0:1]),
	.xu_iu_t0_dbcr0_dac4(spr_dbcr0_dac4[0:1]),
`ifndef THREADS1
	.xu_iu_t1_dbcr0_dac1(spr_dbcr0_dac1[2:3]),
	.xu_iu_t1_dbcr0_dac2(spr_dbcr0_dac2[2:3]),
	.xu_iu_t1_dbcr0_dac3(spr_dbcr0_dac3[2:3]),
	.xu_iu_t1_dbcr0_dac4(spr_dbcr0_dac4[2:3]),
`endif
	.xu_iu_dbcr0_ret(spr_dbcr0_ret),
	.xu_iu_dbcr1_iac12m(spr_dbcr1_iac12m),
	.xu_iu_dbcr1_iac34m(spr_dbcr1_iac34m),
	.lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
	.xu_iu_epcr_extgs(xu_iu_epcr_extgs),
	.xu_iu_epcr_dtlbgs(xu_iu_epcr_dtlbgs),
	.xu_iu_epcr_itlbgs(xu_iu_epcr_itlbgs),
	.xu_iu_epcr_dsigs(xu_iu_epcr_dsigs),
	.xu_iu_epcr_isigs(xu_iu_epcr_isigs),
	.xu_iu_epcr_duvd(xu_iu_epcr_duvd),
	.xu_iu_epcr_dgtmi(spr_epcr_dgtmi),
	.xu_iu_epcr_icm(xu_iu_epcr_icm),
	.xu_iu_epcr_gicm(xu_iu_epcr_gicm),
	.xu_iu_msrp_uclep(spr_msrp_uclep),
	.xu_iu_hid_mmu_mode(spr_ccr2_notlb),
        .xu_iu_spr_ccr2_en_dcr(spr_ccr2_en_dcr),
	.xu_iu_spr_ccr2_ifrat(spr_ccr2_ifrat),
	.xu_iu_spr_ccr2_ifratsc(spr_ccr2_ifratsc),
	.xu_iu_spr_ccr2_ucode_dis(spr_ccr2_ucode_dis),
	.xu_iu_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),

	.iu_mm_ierat_req(iu_mm_ierat_req),
	.iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
	.iu_mm_ierat_epn(iu_mm_ierat_epn),
	.iu_mm_ierat_thdid(iu_mm_ierat_thdid),
	.iu_mm_perf_itlb(iu_mm_perf_itlb),
	.iu_mm_ierat_state(iu_mm_ierat_state),
	.iu_mm_ierat_tid(iu_mm_ierat_tid),
	.iu_mm_ierat_flush(iu_mm_ierat_flush),

	.mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
	.mm_iu_ierat_rel_data(mm_iu_ierat_rel_data),
	.mm_iu_ierat_pt_fault(mm_xu_pt_fault),
	.mm_iu_ierat_lrat_miss(mm_xu_lrat_miss),
	.mm_iu_ierat_tlb_inelig(mm_xu_tlb_inelig),
	.mm_iu_tlb_multihit_err(mm_tlb_multihit_err),
	.mm_iu_tlb_par_err(mm_tlb_par_err),
	.mm_iu_lru_par_err(mm_lru_par_err),
        .mm_iu_tlb_miss(mm_xu_tlb_miss),

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

	.mm_iu_flush_req(mm_iu_flush_req),
	.iu_mm_bus_snoop_hold_ack(iu_mm_bus_snoop_hold_ack),
	.mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
	.mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
            .mm_iu_tlbi_complete(mm_iu_tlbi_complete),
	.iu_mm_hold_ack(iu_mm_hold_ack),
	.mm_iu_hold_req(mm_iu_hold_req),
	.mm_iu_hold_done(mm_iu_hold_done),
	.mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),
        .cp_mm_except_taken_t0(cp_mm_except_taken_t0),
     `ifndef THREADS1
        .cp_mm_except_taken_t1(cp_mm_except_taken_t1),
     `endif

	.an_ac_back_inv(an_ac_back_inv),
	.an_ac_back_inv_addr(an_ac_back_inv_addr[64 - `REAL_IFAR_WIDTH:57]),
	.an_ac_back_inv_target(an_ac_back_inv_target[0]),

	.iu_lq_request(iu_lq_request),
	.iu_lq_ctag(iu_lq_cTag),
	.iu_lq_ra(iu_lq_ra),
	.iu_lq_wimge(iu_lq_wimge),
	.iu_lq_userdef(iu_lq_userdef),

	.an_ac_reld_data_vld(an_ac_reld_data_vld),
	.an_ac_reld_core_tag(an_ac_reld_core_tag),
	.an_ac_reld_qw(an_ac_reld_qw),
	.an_ac_reld_data(an_ac_reld_data),
	.an_ac_reld_ecc_err(an_ac_reld_ecc_err),
	.an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),

        .iu_mm_lmq_empty(iu_mm_lmq_empty),
	.iu_xu_icache_quiesce(iu_xu_icache_quiesce),
	.iu_pc_icache_quiesce(iu_pc_icache_quiesce),
        .iu_pc_err_btb_parity(iu_pc_err_btb_parity),


	// Interface to reservation stations
	 .iu_rv_iu6_t0_i0_vld(iu_rv_iu6_t0_i0_vld),
	 .iu_rv_iu6_t0_i0_act(iu_rv_iu6_t0_i0_act),
	 .iu_rv_iu6_t0_i0_rte_lq(iu_rv_iu6_t0_i0_rte_lq),
	 .iu_rv_iu6_t0_i0_rte_sq(iu_rv_iu6_t0_i0_rte_sq),
	 .iu_rv_iu6_t0_i0_rte_fx0(iu_rv_iu6_t0_i0_rte_fx0),
	 .iu_rv_iu6_t0_i0_rte_fx1(iu_rv_iu6_t0_i0_rte_fx1),
	 .iu_rv_iu6_t0_i0_rte_axu0(iu_rv_iu6_t0_i0_rte_axu0),
	 .iu_rv_iu6_t0_i0_rte_axu1(iu_rv_iu6_t0_i0_rte_axu1),
	 .iu_rv_iu6_t0_i0_instr(iu_rv_iu6_t0_i0_instr),
	 .iu_rv_iu6_t0_i0_ifar(iu_rv_iu6_t0_i0_ifar),
	 .iu_rv_iu6_t0_i0_ucode(iu_rv_iu6_t0_i0_ucode),
	 .iu_rv_iu6_t0_i0_2ucode(iu_rv_iu6_t0_i0_2ucode),
	 .iu_rv_iu6_t0_i0_ucode_cnt(iu_rv_iu6_t0_i0_ucode_cnt),
	 .iu_rv_iu6_t0_i0_itag(iu_rv_iu6_t0_i0_itag),
	 .iu_rv_iu6_t0_i0_ord(iu_rv_iu6_t0_i0_ord),
	 .iu_rv_iu6_t0_i0_cord(iu_rv_iu6_t0_i0_cord),
	 .iu_rv_iu6_t0_i0_spec(iu_rv_iu6_t0_i0_spec),
	 .iu_rv_iu6_t0_i0_t1_v(iu_rv_iu6_t0_i0_t1_v),
	 .iu_rv_iu6_t0_i0_t1_p(iu_rv_iu6_t0_i0_t1_p),
	 .iu_rv_iu6_t0_i0_t1_t(iu_rv_iu6_t0_i0_t1_t),
	 .iu_rv_iu6_t0_i0_t2_v(iu_rv_iu6_t0_i0_t2_v),
	 .iu_rv_iu6_t0_i0_t2_p(iu_rv_iu6_t0_i0_t2_p),
	 .iu_rv_iu6_t0_i0_t2_t(iu_rv_iu6_t0_i0_t2_t),
	 .iu_rv_iu6_t0_i0_t3_v(iu_rv_iu6_t0_i0_t3_v),
	 .iu_rv_iu6_t0_i0_t3_p(iu_rv_iu6_t0_i0_t3_p),
	 .iu_rv_iu6_t0_i0_t3_t(iu_rv_iu6_t0_i0_t3_t),
	 .iu_rv_iu6_t0_i0_s1_v(iu_rv_iu6_t0_i0_s1_v),
	 .iu_rv_iu6_t0_i0_s1_p(iu_rv_iu6_t0_i0_s1_p),
	 .iu_rv_iu6_t0_i0_s1_t(iu_rv_iu6_t0_i0_s1_t),
	 .iu_rv_iu6_t0_i0_s2_v(iu_rv_iu6_t0_i0_s2_v),
	 .iu_rv_iu6_t0_i0_s2_p(iu_rv_iu6_t0_i0_s2_p),
	 .iu_rv_iu6_t0_i0_s2_t(iu_rv_iu6_t0_i0_s2_t),
	 .iu_rv_iu6_t0_i0_s3_v(iu_rv_iu6_t0_i0_s3_v),
	 .iu_rv_iu6_t0_i0_s3_p(iu_rv_iu6_t0_i0_s3_p),
	 .iu_rv_iu6_t0_i0_s3_t(iu_rv_iu6_t0_i0_s3_t),
	 .iu_rv_iu6_t0_i0_ilat(iu_rv_iu6_t0_i0_ilat),
	 .iu_rv_iu6_t0_i0_isload(iu_rv_iu6_t0_i0_isLoad),
	 .iu_rv_iu6_t0_i0_isstore(iu_rv_iu6_t0_i0_isStore),
	 .iu_rv_iu6_t0_i0_s1_itag(iu_rv_iu6_t0_i0_s1_itag),
	 .iu_rv_iu6_t0_i0_s2_itag(iu_rv_iu6_t0_i0_s2_itag),
	 .iu_rv_iu6_t0_i0_s3_itag(iu_rv_iu6_t0_i0_s3_itag),
	 .iu_rv_iu6_t0_i0_fusion(iu_rv_iu6_t0_i0_fusion),
	 .iu_rv_iu6_t0_i0_bta_val(iu_rv_iu6_t0_i0_bta_val),
	 .iu_rv_iu6_t0_i0_bta(iu_rv_iu6_t0_i0_bta),
	 .iu_rv_iu6_t0_i0_br_pred(iu_rv_iu6_t0_i0_br_pred),
	 .iu_rv_iu6_t0_i0_ls_ptr(iu_rv_iu6_t0_i0_ls_ptr),
	 .iu_rv_iu6_t0_i0_bh_update(iu_rv_iu6_t0_i0_bh_update),
	 .iu_rv_iu6_t0_i0_gshare(iu_rv_iu6_t0_i0_gshare),

	 .iu_rv_iu6_t0_i1_vld(iu_rv_iu6_t0_i1_vld),
	 .iu_rv_iu6_t0_i1_act(iu_rv_iu6_t0_i1_act),
	 .iu_rv_iu6_t0_i1_rte_lq(iu_rv_iu6_t0_i1_rte_lq),
	 .iu_rv_iu6_t0_i1_rte_sq(iu_rv_iu6_t0_i1_rte_sq),
	 .iu_rv_iu6_t0_i1_rte_fx0(iu_rv_iu6_t0_i1_rte_fx0),
	 .iu_rv_iu6_t0_i1_rte_fx1(iu_rv_iu6_t0_i1_rte_fx1),
	 .iu_rv_iu6_t0_i1_rte_axu0(iu_rv_iu6_t0_i1_rte_axu0),
	 .iu_rv_iu6_t0_i1_rte_axu1(iu_rv_iu6_t0_i1_rte_axu1),
	 .iu_rv_iu6_t0_i1_instr(iu_rv_iu6_t0_i1_instr),
	 .iu_rv_iu6_t0_i1_ifar(iu_rv_iu6_t0_i1_ifar),
	 .iu_rv_iu6_t0_i1_ucode(iu_rv_iu6_t0_i1_ucode),
	 .iu_rv_iu6_t0_i1_ucode_cnt(iu_rv_iu6_t0_i1_ucode_cnt),
	 .iu_rv_iu6_t0_i1_itag(iu_rv_iu6_t0_i1_itag),
	 .iu_rv_iu6_t0_i1_ord(iu_rv_iu6_t0_i1_ord),
	 .iu_rv_iu6_t0_i1_cord(iu_rv_iu6_t0_i1_cord),
	 .iu_rv_iu6_t0_i1_spec(iu_rv_iu6_t0_i1_spec),
	 .iu_rv_iu6_t0_i1_t1_v(iu_rv_iu6_t0_i1_t1_v),
	 .iu_rv_iu6_t0_i1_t1_p(iu_rv_iu6_t0_i1_t1_p),
	 .iu_rv_iu6_t0_i1_t1_t(iu_rv_iu6_t0_i1_t1_t),
	 .iu_rv_iu6_t0_i1_t2_v(iu_rv_iu6_t0_i1_t2_v),
	 .iu_rv_iu6_t0_i1_t2_p(iu_rv_iu6_t0_i1_t2_p),
	 .iu_rv_iu6_t0_i1_t2_t(iu_rv_iu6_t0_i1_t2_t),
	 .iu_rv_iu6_t0_i1_t3_v(iu_rv_iu6_t0_i1_t3_v),
	 .iu_rv_iu6_t0_i1_t3_p(iu_rv_iu6_t0_i1_t3_p),
	 .iu_rv_iu6_t0_i1_t3_t(iu_rv_iu6_t0_i1_t3_t),
	 .iu_rv_iu6_t0_i1_s1_v(iu_rv_iu6_t0_i1_s1_v),
	 .iu_rv_iu6_t0_i1_s1_p(iu_rv_iu6_t0_i1_s1_p),
	 .iu_rv_iu6_t0_i1_s1_t(iu_rv_iu6_t0_i1_s1_t),
	 .iu_rv_iu6_t0_i1_s1_dep_hit(iu_rv_iu6_t0_i1_s1_dep_hit),
	 .iu_rv_iu6_t0_i1_s2_v(iu_rv_iu6_t0_i1_s2_v),
	 .iu_rv_iu6_t0_i1_s2_p(iu_rv_iu6_t0_i1_s2_p),
	 .iu_rv_iu6_t0_i1_s2_t(iu_rv_iu6_t0_i1_s2_t),
	 .iu_rv_iu6_t0_i1_s2_dep_hit(iu_rv_iu6_t0_i1_s2_dep_hit),
	 .iu_rv_iu6_t0_i1_s3_v(iu_rv_iu6_t0_i1_s3_v),
	 .iu_rv_iu6_t0_i1_s3_p(iu_rv_iu6_t0_i1_s3_p),
	 .iu_rv_iu6_t0_i1_s3_t(iu_rv_iu6_t0_i1_s3_t),
	 .iu_rv_iu6_t0_i1_s3_dep_hit(iu_rv_iu6_t0_i1_s3_dep_hit),
	 .iu_rv_iu6_t0_i1_ilat(iu_rv_iu6_t0_i1_ilat),
	 .iu_rv_iu6_t0_i1_isload(iu_rv_iu6_t0_i1_isLoad),
	 .iu_rv_iu6_t0_i1_isstore(iu_rv_iu6_t0_i1_isStore),
	 .iu_rv_iu6_t0_i1_s1_itag(iu_rv_iu6_t0_i1_s1_itag),
	 .iu_rv_iu6_t0_i1_s2_itag(iu_rv_iu6_t0_i1_s2_itag),
	 .iu_rv_iu6_t0_i1_s3_itag(iu_rv_iu6_t0_i1_s3_itag),
	 .iu_rv_iu6_t0_i1_fusion(iu_rv_iu6_t0_i1_fusion),
	 .iu_rv_iu6_t0_i1_bta_val(iu_rv_iu6_t0_i1_bta_val),
	 .iu_rv_iu6_t0_i1_bta(iu_rv_iu6_t0_i1_bta),
	 .iu_rv_iu6_t0_i1_br_pred(iu_rv_iu6_t0_i1_br_pred),
	 .iu_rv_iu6_t0_i1_ls_ptr(iu_rv_iu6_t0_i1_ls_ptr),
	 .iu_rv_iu6_t0_i1_bh_update(iu_rv_iu6_t0_i1_bh_update),
	 .iu_rv_iu6_t0_i1_gshare(iu_rv_iu6_t0_i1_gshare),
`ifndef THREADS1
	 .iu_rv_iu6_t1_i0_vld(iu_rv_iu6_t1_i0_vld),
	 .iu_rv_iu6_t1_i0_act(iu_rv_iu6_t1_i0_act),
	 .iu_rv_iu6_t1_i0_rte_lq(iu_rv_iu6_t1_i0_rte_lq),
	 .iu_rv_iu6_t1_i0_rte_sq(iu_rv_iu6_t1_i0_rte_sq),
	 .iu_rv_iu6_t1_i0_rte_fx0(iu_rv_iu6_t1_i0_rte_fx0),
	 .iu_rv_iu6_t1_i0_rte_fx1(iu_rv_iu6_t1_i0_rte_fx1),
	 .iu_rv_iu6_t1_i0_rte_axu0(iu_rv_iu6_t1_i0_rte_axu0),
	 .iu_rv_iu6_t1_i0_rte_axu1(iu_rv_iu6_t1_i0_rte_axu1),
	 .iu_rv_iu6_t1_i0_instr(iu_rv_iu6_t1_i0_instr),
	 .iu_rv_iu6_t1_i0_ifar(iu_rv_iu6_t1_i0_ifar),
	 .iu_rv_iu6_t1_i0_ucode(iu_rv_iu6_t1_i0_ucode),
	 .iu_rv_iu6_t1_i0_2ucode(iu_rv_iu6_t1_i0_2ucode),
	 .iu_rv_iu6_t1_i0_ucode_cnt(iu_rv_iu6_t1_i0_ucode_cnt),
	 .iu_rv_iu6_t1_i0_itag(iu_rv_iu6_t1_i0_itag),
	 .iu_rv_iu6_t1_i0_ord(iu_rv_iu6_t1_i0_ord),
	 .iu_rv_iu6_t1_i0_cord(iu_rv_iu6_t1_i0_cord),
	 .iu_rv_iu6_t1_i0_spec(iu_rv_iu6_t1_i0_spec),
	 .iu_rv_iu6_t1_i0_t1_v(iu_rv_iu6_t1_i0_t1_v),
	 .iu_rv_iu6_t1_i0_t1_p(iu_rv_iu6_t1_i0_t1_p),
	 .iu_rv_iu6_t1_i0_t1_t(iu_rv_iu6_t1_i0_t1_t),
	 .iu_rv_iu6_t1_i0_t2_v(iu_rv_iu6_t1_i0_t2_v),
	 .iu_rv_iu6_t1_i0_t2_p(iu_rv_iu6_t1_i0_t2_p),
	 .iu_rv_iu6_t1_i0_t2_t(iu_rv_iu6_t1_i0_t2_t),
	 .iu_rv_iu6_t1_i0_t3_v(iu_rv_iu6_t1_i0_t3_v),
	 .iu_rv_iu6_t1_i0_t3_p(iu_rv_iu6_t1_i0_t3_p),
	 .iu_rv_iu6_t1_i0_t3_t(iu_rv_iu6_t1_i0_t3_t),
	 .iu_rv_iu6_t1_i0_s1_v(iu_rv_iu6_t1_i0_s1_v),
	 .iu_rv_iu6_t1_i0_s1_p(iu_rv_iu6_t1_i0_s1_p),
	 .iu_rv_iu6_t1_i0_s1_t(iu_rv_iu6_t1_i0_s1_t),
	 .iu_rv_iu6_t1_i0_s2_v(iu_rv_iu6_t1_i0_s2_v),
	 .iu_rv_iu6_t1_i0_s2_p(iu_rv_iu6_t1_i0_s2_p),
	 .iu_rv_iu6_t1_i0_s2_t(iu_rv_iu6_t1_i0_s2_t),
	 .iu_rv_iu6_t1_i0_s3_v(iu_rv_iu6_t1_i0_s3_v),
	 .iu_rv_iu6_t1_i0_s3_p(iu_rv_iu6_t1_i0_s3_p),
	 .iu_rv_iu6_t1_i0_s3_t(iu_rv_iu6_t1_i0_s3_t),
	 .iu_rv_iu6_t1_i0_ilat(iu_rv_iu6_t1_i0_ilat),
	 .iu_rv_iu6_t1_i0_isload(iu_rv_iu6_t1_i0_isLoad),
	 .iu_rv_iu6_t1_i0_isstore(iu_rv_iu6_t1_i0_isStore),
	 .iu_rv_iu6_t1_i0_s1_itag(iu_rv_iu6_t1_i0_s1_itag),
	 .iu_rv_iu6_t1_i0_s2_itag(iu_rv_iu6_t1_i0_s2_itag),
	 .iu_rv_iu6_t1_i0_s3_itag(iu_rv_iu6_t1_i0_s3_itag),
	 .iu_rv_iu6_t1_i0_fusion(iu_rv_iu6_t1_i0_fusion),
	 .iu_rv_iu6_t1_i0_bta_val(iu_rv_iu6_t1_i0_bta_val),
	 .iu_rv_iu6_t1_i0_bta(iu_rv_iu6_t1_i0_bta),
	 .iu_rv_iu6_t1_i0_br_pred(iu_rv_iu6_t1_i0_br_pred),
	 .iu_rv_iu6_t1_i0_ls_ptr(iu_rv_iu6_t1_i0_ls_ptr),
	 .iu_rv_iu6_t1_i0_bh_update(iu_rv_iu6_t1_i0_bh_update),
	 .iu_rv_iu6_t1_i0_gshare(iu_rv_iu6_t1_i0_gshare),

	 .iu_rv_iu6_t1_i1_vld(iu_rv_iu6_t1_i1_vld),
	 .iu_rv_iu6_t1_i1_act(iu_rv_iu6_t1_i1_act),
	 .iu_rv_iu6_t1_i1_rte_lq(iu_rv_iu6_t1_i1_rte_lq),
	 .iu_rv_iu6_t1_i1_rte_sq(iu_rv_iu6_t1_i1_rte_sq),
	 .iu_rv_iu6_t1_i1_rte_fx0(iu_rv_iu6_t1_i1_rte_fx0),
	 .iu_rv_iu6_t1_i1_rte_fx1(iu_rv_iu6_t1_i1_rte_fx1),
	 .iu_rv_iu6_t1_i1_rte_axu0(iu_rv_iu6_t1_i1_rte_axu0),
	 .iu_rv_iu6_t1_i1_rte_axu1(iu_rv_iu6_t1_i1_rte_axu1),
	 .iu_rv_iu6_t1_i1_instr(iu_rv_iu6_t1_i1_instr),
	 .iu_rv_iu6_t1_i1_ifar(iu_rv_iu6_t1_i1_ifar),
	 .iu_rv_iu6_t1_i1_ucode(iu_rv_iu6_t1_i1_ucode),
	 .iu_rv_iu6_t1_i1_ucode_cnt(iu_rv_iu6_t1_i1_ucode_cnt),
	 .iu_rv_iu6_t1_i1_itag(iu_rv_iu6_t1_i1_itag),
	 .iu_rv_iu6_t1_i1_ord(iu_rv_iu6_t1_i1_ord),
	 .iu_rv_iu6_t1_i1_cord(iu_rv_iu6_t1_i1_cord),
	 .iu_rv_iu6_t1_i1_spec(iu_rv_iu6_t1_i1_spec),
	 .iu_rv_iu6_t1_i1_t1_v(iu_rv_iu6_t1_i1_t1_v),
	 .iu_rv_iu6_t1_i1_t1_p(iu_rv_iu6_t1_i1_t1_p),
	 .iu_rv_iu6_t1_i1_t1_t(iu_rv_iu6_t1_i1_t1_t),
	 .iu_rv_iu6_t1_i1_t2_v(iu_rv_iu6_t1_i1_t2_v),
	 .iu_rv_iu6_t1_i1_t2_p(iu_rv_iu6_t1_i1_t2_p),
	 .iu_rv_iu6_t1_i1_t2_t(iu_rv_iu6_t1_i1_t2_t),
	 .iu_rv_iu6_t1_i1_t3_v(iu_rv_iu6_t1_i1_t3_v),
	 .iu_rv_iu6_t1_i1_t3_p(iu_rv_iu6_t1_i1_t3_p),
	 .iu_rv_iu6_t1_i1_t3_t(iu_rv_iu6_t1_i1_t3_t),
	 .iu_rv_iu6_t1_i1_s1_v(iu_rv_iu6_t1_i1_s1_v),
	 .iu_rv_iu6_t1_i1_s1_p(iu_rv_iu6_t1_i1_s1_p),
	 .iu_rv_iu6_t1_i1_s1_t(iu_rv_iu6_t1_i1_s1_t),
	 .iu_rv_iu6_t1_i1_s1_dep_hit(iu_rv_iu6_t1_i1_s1_dep_hit),
	 .iu_rv_iu6_t1_i1_s2_v(iu_rv_iu6_t1_i1_s2_v),
	 .iu_rv_iu6_t1_i1_s2_p(iu_rv_iu6_t1_i1_s2_p),
	 .iu_rv_iu6_t1_i1_s2_t(iu_rv_iu6_t1_i1_s2_t),
	 .iu_rv_iu6_t1_i1_s2_dep_hit(iu_rv_iu6_t1_i1_s2_dep_hit),
	 .iu_rv_iu6_t1_i1_s3_v(iu_rv_iu6_t1_i1_s3_v),
	 .iu_rv_iu6_t1_i1_s3_p(iu_rv_iu6_t1_i1_s3_p),
	 .iu_rv_iu6_t1_i1_s3_t(iu_rv_iu6_t1_i1_s3_t),
	 .iu_rv_iu6_t1_i1_s3_dep_hit(iu_rv_iu6_t1_i1_s3_dep_hit),
	 .iu_rv_iu6_t1_i1_ilat(iu_rv_iu6_t1_i1_ilat),
	 .iu_rv_iu6_t1_i1_isload(iu_rv_iu6_t1_i1_isLoad),
	 .iu_rv_iu6_t1_i1_isstore(iu_rv_iu6_t1_i1_isStore),
	 .iu_rv_iu6_t1_i1_s1_itag(iu_rv_iu6_t1_i1_s1_itag),
	 .iu_rv_iu6_t1_i1_s2_itag(iu_rv_iu6_t1_i1_s2_itag),
	 .iu_rv_iu6_t1_i1_s3_itag(iu_rv_iu6_t1_i1_s3_itag),
	 .iu_rv_iu6_t1_i1_fusion(iu_rv_iu6_t1_i1_fusion),
	 .iu_rv_iu6_t1_i1_bta_val(iu_rv_iu6_t1_i1_bta_val),
	 .iu_rv_iu6_t1_i1_bta(iu_rv_iu6_t1_i1_bta),
	 .iu_rv_iu6_t1_i1_br_pred(iu_rv_iu6_t1_i1_br_pred),
	 .iu_rv_iu6_t1_i1_ls_ptr(iu_rv_iu6_t1_i1_ls_ptr),
	 .iu_rv_iu6_t1_i1_bh_update(iu_rv_iu6_t1_i1_bh_update),
	 .iu_rv_iu6_t1_i1_gshare(iu_rv_iu6_t1_i1_gshare),

`endif

	// XER read bus to RF for store conditionals
	.iu_rf_t0_xer_p(iu_rf_t0_xer_p),
`ifndef THREADS1
	.iu_rf_t1_xer_p(iu_rf_t1_xer_p),
`endif
	// Credit Interface with IU
	.rv_iu_fx0_credit_free(rv_iu_fx0_credit_free),
	.rv_iu_fx1_credit_free(rv_iu_fx1_credit_free),
	.axu0_iu_credit_free(rv_iu_axu0_credit_free),
	.axu1_iu_credit_free(rv_iu_axu1_credit_free),

	// LQ Instruction Executed
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

	.lq_iu_credit_free(lq_iu_credit_free),
	.sq_iu_credit_free(sq_iu_credit_free),

	// Interface IU ucode
	.xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
	.xu_iu_ucode_xer(xu_iu_ucode_xer),

	// Complete iTag
	.iu_lq_i0_completed(iu_lq_i0_completed),
	.iu_lq_i1_completed(iu_lq_i1_completed),
	.iu_lq_t0_i0_completed_itag(iu_lq_t0_i0_completed_itag),
	.iu_lq_t0_i1_completed_itag(iu_lq_t0_i1_completed_itag),
`ifndef THREADS1
	.iu_lq_t1_i0_completed_itag(iu_lq_t1_i0_completed_itag),
	.iu_lq_t1_i1_completed_itag(iu_lq_t1_i1_completed_itag),
`endif
	.iu_lq_recirc_val(iu_lq_recirc_val),

	// ICBI Interface to IU
	.lq_iu_icbi_val(lq_iu_icbi_val),
	.lq_iu_icbi_addr(lq_iu_icbi_addr),
	.iu_lq_icbi_complete(iu_lq_icbi_complete),
	.lq_iu_ici_val(lq_iu_ici_val),
	.iu_lq_spr_iucr0_icbi_ack(iu_lq_spr_iucr0_icbi_ack),

	// BR Instruction Executed
	.br_iu_execute_vld(br_iu_execute_vld),
	.br_iu_itag(br_iu_itag),
	.br_iu_bta(br_iu_bta),
	.br_iu_taken(br_iu_taken),
	.br_iu_redirect(br_iu_redirect),
	.br_iu_perf_events(br_iu_perf_events),

	.br_iu_gshare(br_iu_gshare),
	.br_iu_ls_ptr(br_iu_ls_ptr),
	.br_iu_ls_data(br_iu_ls_data),
	.br_iu_ls_update(br_iu_ls_update),

	// XU0 Instruction Executed
	.xu_iu_execute_vld(xu_iu_execute_vld),
	.xu_iu_itag(xu_iu_itag),
	.xu_iu_n_flush(xu_iu_n_flush),
	.xu_iu_np1_flush(xu_iu_np1_flush),
	.xu_iu_flush2ucode(xu_iu_flush2ucode),
	.xu_iu_exception_val(xu_iu_exception_val),
	.xu_iu_exception(xu_iu_exception),
	.xu_iu_mtiar(xu_iu_mtiar),
	.xu_iu_bta(xu_iu_bta),
   .xu_iu_perf_events(xu0_iu_perf_events),

	// XU1 Instruction Executed
	.xu1_iu_execute_vld(xu1_iu_execute_vld),
	.xu1_iu_itag(xu1_iu_itag),

	// XU IERAT interface
	.xu_iu_val(xu_iu_val),
	.xu_iu_pri_val(xu_iu_pri_val),
	.xu_iu_pri(xu_iu_pri),
	.xu_iu_is_eratre(xu_iu_is_eratre),
	.xu_iu_is_eratwe(xu_iu_is_eratwe),
	.xu_iu_is_eratsx(xu_iu_is_eratsx),
	.xu_iu_is_eratilx(xu_iu_is_eratilx),
	.xu_iu_ws(xu_iu_ws),
	.xu_iu_ra_entry(xu_iu_ra_entry),
	.xu_iu_rb(xu_iu_rb),
	.xu_iu_rs_data(xu_iu_rs_data),
	.iu_xu_ord_read_done(iu_xu_ord_read_done),
	.iu_xu_ord_write_done(iu_xu_ord_write_done),
	.iu_xu_ord_par_err(iu_xu_ord_par_err),
	.iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),
	.iu_xu_ex5_data(iu_xu_ex5_data),

	// AXU0 Instruction Executed
	.axu0_iu_execute_vld(axu0_iu_execute_vld),
	.axu0_iu_itag(axu0_iu_itag),
	.axu0_iu_n_flush(axu0_iu_n_flush),
	.axu0_iu_np1_flush(axu0_iu_np1_flush),
	.axu0_iu_n_np1_flush(axu0_iu_n_np1_flush),
	.axu0_iu_flush2ucode(axu0_iu_flush2ucode),
	.axu0_iu_flush2ucode_type(axu0_iu_flush2ucode_type),
	.axu0_iu_exception_val(axu0_iu_exception_val),
	.axu0_iu_exception(axu0_iu_exception),
	.axu0_iu_async_fex(axu0_iu_async_fex),
	.axu0_iu_perf_events(axu0_iu_perf_events),

	// AXU1 Instruction Executed
	.axu1_iu_execute_vld(axu1_iu_execute_vld),
	.axu1_iu_itag(axu1_iu_itag),
	.axu1_iu_n_flush(axu1_iu_n_flush),
	.axu1_iu_np1_flush(axu1_iu_np1_flush),
	.axu1_iu_flush2ucode(axu1_iu_flush2ucode),
	.axu1_iu_flush2ucode_type(axu1_iu_flush2ucode_type),
	.axu1_iu_exception_val(axu1_iu_exception_val),
	.axu1_iu_exception(axu1_iu_exception),
	.axu1_iu_perf_events(axu1_iu_perf_events),

	// Completion and XU
	// Run State
	.iu_xu_stop(iu_xu_stop),
	.xu_iu_run_thread(xu_iu_run_thread),
        .iu_xu_credits_returned(iu_xu_credits_returned),
	.xu_iu_single_instr_mode(xu_iu_single_instr_mode),
   .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri),
	.iu_xu_quiesce(iu_xu_quiesce),
	.iu_pc_quiesce(iu_pc_quiesce),
	// Interrupt Interface
	.iu_xu_rfi(iu_xu_rfi),
	.iu_xu_rfgi(iu_xu_rfgi),
	.iu_xu_rfci(iu_xu_rfci),
	.iu_xu_rfmci(iu_xu_rfmci),
	.iu_xu_int(iu_xu_int),
	.iu_xu_gint(iu_xu_gint),
	.iu_xu_cint(iu_xu_cint),
	.iu_xu_mcint(iu_xu_mcint),
	.iu_xu_t0_nia(iu_xu_t0_nia),
	.iu_xu_t0_esr(iu_xu_t0_esr),
	.iu_xu_t0_mcsr(iu_xu_t0_mcsr),
	.iu_xu_t0_dbsr(iu_xu_t0_dbsr),
	.iu_xu_t0_dear(iu_xu_t0_dear),
`ifndef THREADS1
	.iu_xu_t1_nia(iu_xu_t1_nia),
	.iu_xu_t1_esr(iu_xu_t1_esr),
	.iu_xu_t1_mcsr(iu_xu_t1_mcsr),
	.iu_xu_t1_dbsr(iu_xu_t1_dbsr),
	.iu_xu_t1_dear(iu_xu_t1_dear),
`endif
	.iu_xu_dear_update(iu_xu_dear_update),
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

	// Interrupts
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

        .pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
	//Ram interface
	.pc_iu_ram_instr(pc_iu_ram_instr),
	.pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
	.pc_iu_ram_issue(pc_iu_ram_issue),
	.iu_pc_ram_done(iu_pc_ram_done),
	.iu_pc_ram_interrupt(iu_pc_ram_interrupt),
	.iu_pc_ram_unsupported(iu_pc_ram_unsupported),

	.pc_iu_ram_active(pc_iu_ram_active),
	.pc_iu_ram_flush_thread(pc_iu_ram_flush_thread),
	.xu_iu_msrovride_enab(xu_iu_msrovride_enab),
	.pc_iu_stop(pc_iu_stop),
	.pc_iu_step(pc_iu_step),
	.pc_iu_t0_dbg_action(pc_iu_t0_dbg_action),
`ifndef THREADS1
	.pc_iu_t1_dbg_action(pc_iu_t1_dbg_action),
`endif
	.iu_pc_step_done(iu_pc_step_done),
	.iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
	.iu_pc_err_debug_event(iu_pc_err_debug_event),
	.iu_pc_attention_instr(iu_pc_err_attention_instr),
	.iu_pc_err_mchk_disabled(iu_pc_err_mchk_disabled),
	.ac_an_debug_trigger(ac_an_debug_trigger),

	.cp_axu_i0_t1_v(cp_axu_i0_t1_v),
	.cp_axu_i1_t1_v(cp_axu_i1_t1_v),
	.cp_axu_t0_i0_t1_t(cp_axu_t0_i0_t1_t),
	.cp_axu_t0_i0_t1_p(cp_axu_t0_i0_t1_p),
	.cp_axu_t0_i1_t1_t(cp_axu_t0_i1_t1_t),
	.cp_axu_t0_i1_t1_p(cp_axu_t0_i1_t1_p),
`ifndef THREADS1
	.cp_axu_t1_i0_t1_t(cp_axu_t1_i0_t1_t),
	.cp_axu_t1_i0_t1_p(cp_axu_t1_i0_t1_p),
	.cp_axu_t1_i1_t1_t(cp_axu_t1_i1_t1_t),
	.cp_axu_t1_i1_t1_p(cp_axu_t1_i1_t1_p),
`endif
	.cp_is_isync(cp_is_isync),
	.cp_is_csync(cp_is_csync),

	// Completion flush
	.cp_t0_next_itag(cp_t0_next_itag),
	.cp_t0_flush_itag(cp_t0_flush_itag),
	.cp_t0_flush_ifar(cp_t0_flush_ifar),
`ifndef THREADS1
	.cp_t1_next_itag(cp_t1_next_itag),
	.cp_t1_flush_itag(cp_t1_flush_itag),
	.cp_t1_flush_ifar(cp_t1_flush_ifar),
`endif
	.cp_flush(cp_flush),

        // Performance
        .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
        .pc_iu_event_count_mode(pc_iu_event_count_mode),
        .iu_event_bus_in(iu_event_bus_in),
        .iu_event_bus_out(iu_event_bus0_out),

        .iu_pc_fx0_credit_ok(iu_pc_fx0_credit_ok),
        .iu_pc_fx1_credit_ok(iu_pc_fx1_credit_ok),
        .iu_pc_lq_credit_ok(iu_pc_lq_credit_ok),
        .iu_pc_sq_credit_ok(iu_pc_sq_credit_ok),
        .iu_pc_axu0_credit_ok(iu_pc_axu0_credit_ok),
        .iu_pc_axu1_credit_ok(iu_pc_axu1_credit_ok),


        // Debug Trace
        .pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
        .pc_iu_debug_mux1_ctrls(pc_iu_debug_mux1_ctrls),
        .pc_iu_debug_mux2_ctrls(pc_iu_debug_mux2_ctrls),
        .debug_bus_in(iu_debug_bus_in),
        .debug_bus_out(iu_debug_bus_out),
        .coretrace_ctrls_in(iu_coretrace_ctrls_in),
        .coretrace_ctrls_out(iu_coretrace_ctrls_out)
	);


   assign func_sl_thold_0_b = (~rp_xu_func_sl_thold_3);
   assign func_slp_sl_thold_0_b = (~rp_xu_func_slp_sl_thold_3);



   xu
    xu0(
       //-------------------------------------------------------------------
       // Clocks & Power
       //-------------------------------------------------------------------
       .nclk(nclk),
//       .vcs(vcs),
//       .vdd(vdd),
//       .gnd(gnd),

       //-------------------------------------------------------------------
       // Pervasive
       //-------------------------------------------------------------------
       .pc_xu_ccflush_dc(rp_xu_ccflush_dc),
       .clkoff_dc_b(1'b1),
       .d_mode_dc(1'b0),
       .delay_lclkr_dc(1'b0),
       .mpw1_dc_b(1'b0),
       .mpw2_dc_b(1'b0),
       .func_sl_force(1'b0),
       .func_sl_thold_0_b(func_sl_thold_0_b),
       .func_slp_sl_thold_0_b(func_slp_sl_thold_0_b),
       .sg_0(rp_xu_sg_3),
       .fce_0(rp_xu_fce_3),
       .scan_in(1'b0),
       .scan_out(),

       .xu_pc_ram_done(xu_pc_ram_data_val),
       .xu_pc_ram_data(xu_pc_ram_data),

       //-------------------------------------------------------------------
       // Interface with CP
       //-------------------------------------------------------------------
       .cp_flush(cp_flush),
       .iu_br_t0_flush_ifar(iu_br_t0_flush_ifar),
       .cp_next_itag_t0(cp_t0_next_itag),
`ifndef THREADS1
       .iu_br_t1_flush_ifar(iu_br_t1_flush_ifar),
       .cp_next_itag_t1(cp_t1_next_itag),
`endif
       //-------------------------------------------------------------------
       // BR's Interface with CP
       //-------------------------------------------------------------------
       .br_iu_execute_vld(br_iu_execute_vld),
       .br_iu_itag(br_iu_itag),
       .br_iu_taken(br_iu_taken),
       .br_iu_bta(br_iu_bta),
       .br_iu_gshare(br_iu_gshare),
       .br_iu_ls_ptr(br_iu_ls_ptr),
       .br_iu_ls_data(br_iu_ls_data),
       .br_iu_ls_update(br_iu_ls_update),
       .br_iu_redirect(br_iu_redirect),
       .br_iu_perf_events(br_iu_perf_events),

       //-------------------------------------------------------------------
       // Interface with RV
       //-------------------------------------------------------------------
       .rv_xu0_s1_v(rv_fx0_s1_v),
       .rv_xu0_s1_p(rv_fx0_s1_p),
       .rv_xu0_s2_v(rv_fx0_s2_v),
       .rv_xu0_s2_p(rv_fx0_s2_p),
       .rv_xu0_s3_v(rv_fx0_s3_v),
       .rv_xu0_s3_p(rv_fx0_s3_p),

       .rv_xu0_vld(rv_fx0_vld),
       .rv_xu0_ex0_ord(rv_fx0_ex0_ord),
       .rv_xu0_ex0_fusion(rv_fx0_ex0_fusion),
       .rv_xu0_ex0_instr(rv_fx0_ex0_instr),
       .rv_xu0_ex0_ifar(rv_fx0_ex0_ifar),
       .rv_xu0_ex0_itag(rv_fx0_ex0_itag),
       .rv_xu0_ex0_ucode(rv_fx0_ex0_ucode),
       .rv_xu0_ex0_bta_val(rv_fx0_ex0_bta_val),
       .rv_xu0_ex0_pred_bta(rv_fx0_ex0_pred_bta),
       .rv_xu0_ex0_pred(rv_fx0_ex0_br_pred),
       .rv_xu0_ex0_ls_ptr(rv_fx0_ex0_ls_ptr),
       .rv_xu0_ex0_bh_update(rv_fx0_ex0_bh_update),
       .rv_xu0_ex0_gshare(rv_fx0_ex0_gshare),
       .rv_xu0_ex0_s1_v(rv_fx0_ex0_s1_v),
       .rv_xu0_ex0_s2_v(rv_fx0_ex0_s2_v),
       .rv_xu0_ex0_s2_t(rv_fx0_ex0_s2_t),
       .rv_xu0_ex0_s3_v(rv_fx0_ex0_s3_v),
       .rv_xu0_ex0_s3_t(rv_fx0_ex0_s3_t),
       .rv_xu0_ex0_t1_v(rv_fx0_ex0_t1_v),
       .rv_xu0_ex0_t1_p(rv_fx0_ex0_t1_p),
       .rv_xu0_ex0_t1_t(rv_fx0_ex0_t1_t),
       .rv_xu0_ex0_t2_v(rv_fx0_ex0_t2_v),
       .rv_xu0_ex0_t2_p(rv_fx0_ex0_t2_p),
       .rv_xu0_ex0_t2_t(rv_fx0_ex0_t2_t),
       .rv_xu0_ex0_t3_v(rv_fx0_ex0_t3_v),
       .rv_xu0_ex0_t3_p(rv_fx0_ex0_t3_p),
       .rv_xu0_ex0_t3_t(rv_fx0_ex0_t3_t),
       .rv_xu0_ex0_spec_flush(rv_fx0_ex0_spec_flush),
       .rv_xu0_ex1_spec_flush(rv_fx0_ex1_spec_flush),
       .rv_xu0_ex2_spec_flush(rv_fx0_ex2_spec_flush),
       .rv_xu0_s1_fxu0_sel(rv_fx0_ex0_s1_fx0_sel),
       .rv_xu0_s2_fxu0_sel(rv_fx0_ex0_s2_fx0_sel),
       .rv_xu0_s3_fxu0_sel(rv_fx0_ex0_s3_fx0_sel[2:11]),
       .rv_xu0_s1_fxu1_sel(rv_fx0_ex0_s1_fx1_sel),
       .rv_xu0_s2_fxu1_sel(rv_fx0_ex0_s2_fx1_sel),
       .rv_xu0_s3_fxu1_sel(rv_fx0_ex0_s3_fx1_sel[2:6]),
       .rv_xu0_s1_lq_sel(rv_fx0_ex0_s1_lq_sel),
       .rv_xu0_s2_lq_sel(rv_fx0_ex0_s2_lq_sel),
       .rv_xu0_s3_lq_sel(rv_fx0_ex0_s3_lq_sel),
       .rv_xu0_s1_rel_sel(rv_fx0_ex0_s1_rel_sel),
       .rv_xu0_s2_rel_sel(rv_fx0_ex0_s2_rel_sel),
       .xu0_rv_ord_complete(fx0_rv_ord_complete),
       .xu0_rv_ord_itag(fx0_rv_ord_itag),
       .xu0_rv_hold_all(fx0_rv_hold_all),
       .xu0_rv_ex2_s1_abort(fx0_rv_ex2_s1_abort),
       .xu0_rv_ex2_s2_abort(fx0_rv_ex2_s2_abort),
       .xu0_rv_ex2_s3_abort(fx0_rv_ex2_s3_abort),
       //-------------------------------------------------------------------
       // Bypass Inputs
       //-------------------------------------------------------------------
       .lq_xu_ex5_act(lq_xu_ex5_act),
       .lq_xu_ex5_rt(lq_xu_ex5_rt),
       .lq_xu_ex5_abort(lq_xu_ex5_abort),
       .lq_xu_ex5_data(lq_xu_ex5_data),
       .iu_xu_ex5_data(iu_xu_ex5_data),
       .lq_xu_ex5_cr(lq_xu_ex5_cr),

       //-------------------------------------------------------------------
       // Interface with MMU / ERATs
       //-------------------------------------------------------------------
       .xu_iu_ord_ready(xu_iu_ord_ready),
       .xu_iu_val(xu_iu_val),
       .xu_iu_is_eratre(xu_iu_is_eratre),
       .xu_iu_is_eratwe(xu_iu_is_eratwe),
       .xu_iu_is_eratsx(xu_iu_is_eratsx),
       .xu_iu_is_eratilx(xu_iu_is_eratilx),
       .xu_iu_is_erativax(xu_iu_is_erativax),
       .xu_iu_ws(xu_iu_ws),
       .xu_iu_t(xu_iu_t),
       .xu_iu_rs_is(xu_iu_rs_is),
       .xu_iu_ra_entry(xu_iu_ra_entry),
       .xu_iu_rb(xu_iu_rb),
       .xu_iu_rs_data(xu_iu_rs_data),
       .iu_xu_ord_read_done(iu_xu_ord_read_done),
       .iu_xu_ord_write_done(iu_xu_ord_write_done),
       .iu_xu_ord_n_flush_req(iu_xu_ord_n_flush_req),
       .iu_xu_ord_par_err(iu_xu_ord_par_err),

       .xu_lq_ord_ready(xu_lq_ord_ready),
       .xu_lq_act(xu_lq_act),
       .xu_lq_val(xu_lq_val),
       .xu_lq_hold_req(xu_lq_hold_req),
       .xu_lq_is_eratre(xu_lq_is_eratre),
       .xu_lq_is_eratwe(xu_lq_is_eratwe),
       .xu_lq_is_eratsx(xu_lq_is_eratsx),
       .xu_lq_is_eratilx(xu_lq_is_eratilx),
       .xu_lq_ws(xu_lq_ws),
       .xu_lq_t(xu_lq_t),
       .xu_lq_rs_is(xu_lq_rs_is),
       .xu_lq_ra_entry(xu_lq_ra_entry),
       .xu_lq_rb(xu_lq_rb),
       .xu_lq_rs_data(xu_lq_rs_data),
       .lq_xu_ord_read_done(lq_xu_ord_read_done),
       .lq_xu_ord_write_done(lq_xu_ord_write_done),
       .lq_xu_ord_n_flush_req(lq_xu_ord_n_flush_req),
       .lq_xu_ord_par_err(lq_xu_ord_par_err),

       .xu_mm_ord_ready(xu_mm_ord_ready),
       .xu_mm_val(xu_mm_val),
       .xu_mm_itag(xu_mm_itag),
       .xu_mm_is_tlbre(xu_mm_is_tlbre),
       .xu_mm_is_tlbwe(xu_mm_is_tlbwe),
       .xu_mm_is_tlbsx(xu_mm_is_tlbsx),
       .xu_mm_is_tlbsxr(xu_mm_is_tlbsxr),
       .xu_mm_is_tlbsrx(xu_mm_is_tlbsrx),
       .xu_mm_is_tlbivax(xu_mm_is_tlbivax),
       .xu_mm_is_tlbilx(xu_mm_is_tlbilx),
       .xu_mm_ra_entry(xu_mm_ra_entry),
       .xu_mm_rb(xu_mm_rb),
       .mm_xu_itag(mm_xu_itag),

       .mm_xu_ord_n_flush_req(mm_xu_ord_n_flush_req_ored),
       .mm_xu_ord_read_done(mm_xu_ord_read_done_ored),
       .mm_xu_ord_write_done(mm_xu_ord_write_done_ored),
       .mm_xu_tlb_miss(mm_xu_tlb_miss_ored),
       .mm_xu_lrat_miss(mm_xu_lrat_miss_ored),
       .mm_xu_tlb_inelig(mm_xu_tlb_inelig_ored),
       .mm_xu_pt_fault(mm_xu_pt_fault_ored),
       .mm_xu_hv_priv(mm_xu_hv_priv_ored),
       .mm_xu_illeg_instr(mm_xu_illeg_instr_ored),
       .mm_xu_tlb_multihit(mm_xu_ord_tlb_multihit),
       .mm_xu_tlb_par_err(mm_xu_ord_tlb_par_err),
       .mm_xu_lru_par_err(mm_xu_ord_lru_par_err),
       .mm_xu_local_snoop_reject(mm_xu_local_snoop_reject),
       .mm_xu_mmucr0_tlbsel_t0(mm_xu_t0_mmucr0_tlbsel),
`ifndef THREADS1
       .mm_xu_mmucr0_tlbsel_t1(mm_xu_t1_mmucr0_tlbsel),
`endif
       .mm_xu_tlbwe_binv(mm_iu_tlbwe_binv),
       .mm_xu_cr0_eq(mm_xu_cr0_eq_ored),		// for record forms
       .mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid_ored),		// for record forms

       //-------------------------------------------------------------------
       // Bypass Outputs
       //-------------------------------------------------------------------
       .xu0_lq_ex3_act(xu0_lq_ex3_act),
       .xu0_lq_ex3_abort(xu0_lq_ex3_abort),
       .xu0_lq_ex3_rt(xu0_lq_ex3_rt),
       .xu0_lq_ex4_rt(xu0_lq_ex4_rt),
       .xu0_lq_ex6_rt(xu0_lq_ex6_rt),
       .xu0_lq_ex6_act(xu0_lq_ex6_act),

       //-------------------------------------------------------------------
       // Interface with IU
       //-------------------------------------------------------------------
       .xu0_iu_execute_vld(xu_iu_execute_vld),
       .xu0_iu_itag(xu_iu_itag),
       .xu0_iu_mtiar(xu_iu_mtiar),
       .xu0_iu_bta(xu_iu_bta),
       .xu0_iu_exception_val(xu_iu_exception_val),
       .xu0_iu_exception(xu_iu_exception),
       .xu0_iu_n_flush(xu_iu_n_flush),
       .xu0_iu_np1_flush(xu_iu_np1_flush),
       .xu0_iu_flush2ucode(xu_iu_flush2ucode),
       .xu0_iu_perf_events(xu0_iu_perf_events),
       .xu_iu_pri_val(xu_iu_pri_val),
       .xu_iu_pri(xu_iu_pri),
       .xu_iu_ucode_xer_val(xu_iu_ucode_xer_val),
       .xu_iu_ucode_xer(xu_iu_ucode_xer),

       // Abort
       .xu1_rv_ex2_s1_abort(fx1_rv_ex2_s1_abort),
       .xu1_rv_ex2_s2_abort(fx1_rv_ex2_s2_abort),
       .xu1_rv_ex2_s3_abort(fx1_rv_ex2_s3_abort),
       .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
       //-------------------------------------------------------------------
       // SlowSPRs
       //-------------------------------------------------------------------
       .xu_slowspr_val_in(xu_slowspr_val_in),
       .xu_slowspr_rw_in(xu_slowspr_rw_in),
       .xu_slowspr_data_in(xu_slowspr_data_in),
       .xu_slowspr_done_in(xu_slowspr_done_in),

       //-------------------------------------------------------------------
       // Interface with RV
       //-------------------------------------------------------------------
       .rv_xu1_s1_v(rv_fx1_s1_v),
       .rv_xu1_s1_p(rv_fx1_s1_p),
       .rv_xu1_s2_v(rv_fx1_s2_v),
       .rv_xu1_s2_p(rv_fx1_s2_p),
       .rv_xu1_s3_v(rv_fx1_s3_v),
       .rv_xu1_s3_p(rv_fx1_s3_p),

       .rv_xu1_vld(rv_fx1_vld),
       .rv_xu1_ex0_instr(rv_fx1_ex0_instr),
       .rv_xu1_ex0_itag(rv_fx1_ex0_itag),
       .rv_xu1_ex0_isstore(rv_fx1_ex0_isStore),
       .rv_xu1_ex0_ucode(rv_fx1_ex0_ucode[1:1]),
       .rv_xu1_ex0_t1_v(rv_fx1_ex0_t1_v),
       .rv_xu1_ex0_t1_p(rv_fx1_ex0_t1_p),
       .rv_xu1_ex0_t2_v(rv_fx1_ex0_t2_v),
       .rv_xu1_ex0_t2_p(rv_fx1_ex0_t2_p),
       .rv_xu1_ex0_t3_v(rv_fx1_ex0_t3_v),
       .rv_xu1_ex0_t3_p(rv_fx1_ex0_t3_p),
       .rv_xu1_ex0_s1_v(rv_fx1_ex0_s1_v),
       .rv_xu1_ex0_s3_t(rv_fx1_ex0_s3_t),
       .rv_xu1_ex0_spec_flush(rv_fx1_ex0_spec_flush),
       .rv_xu1_ex1_spec_flush(rv_fx1_ex1_spec_flush),
       .rv_xu1_ex2_spec_flush(rv_fx1_ex2_spec_flush),

       //-------------------------------------------------------------------
       // Interface with Bypass Controller
       //-------------------------------------------------------------------
       .rv_xu1_s1_fxu0_sel(rv_fx1_ex0_s1_fx0_sel),
       .rv_xu1_s2_fxu0_sel(rv_fx1_ex0_s2_fx0_sel),
       .rv_xu1_s3_fxu0_sel(rv_fx1_ex0_s3_fx0_sel[2:11]),
       .rv_xu1_s1_fxu1_sel(rv_fx1_ex0_s1_fx1_sel),
       .rv_xu1_s2_fxu1_sel(rv_fx1_ex0_s2_fx1_sel),
       .rv_xu1_s3_fxu1_sel(rv_fx1_ex0_s3_fx1_sel[2:6]),
       .rv_xu1_s1_lq_sel(rv_fx1_ex0_s1_lq_sel),
       .rv_xu1_s2_lq_sel(rv_fx1_ex0_s2_lq_sel),
       .rv_xu1_s3_lq_sel(rv_fx1_ex0_s3_lq_sel),
       .rv_xu1_s1_rel_sel(rv_fx1_ex0_s1_rel_sel),
       .rv_xu1_s2_rel_sel(rv_fx1_ex0_s2_rel_sel),

       //-------------------------------------------------------------------
       // Interface with LQ
       //-------------------------------------------------------------------
       .xu1_lq_ex2_stq_val(xu1_lq_ex2_stq_val),
       .xu1_lq_ex2_stq_itag(xu1_lq_ex2_stq_itag),
       .xu1_lq_ex2_stq_size(xu1_lq_ex2_stq_size),
       .xu1_lq_ex3_illeg_lswx(xu1_lq_ex3_illeg_lswx),
       .xu1_lq_ex3_strg_noop(xu1_lq_ex3_strg_noop),
       .xu1_lq_ex2_stq_dvc1_cmp(xu1_lq_ex2_stq_dvc1_cmp),
       .xu1_lq_ex2_stq_dvc2_cmp(xu1_lq_ex2_stq_dvc2_cmp),

       //-------------------------------------------------------------------
       // Interface with IU
       //-------------------------------------------------------------------
       .xu1_iu_execute_vld(xu1_iu_execute_vld),
       .xu1_iu_itag(xu1_iu_itag),

       //-------------------------------------------------------------------
       // Bypass Outputs
       //-------------------------------------------------------------------
       .xu1_lq_ex3_act(xu1_lq_ex3_act),
       .xu1_lq_ex3_rt(xu1_lq_ex3_rt),

       //-------------------------------------------------------------------
       // Unit Write Ports
       //-------------------------------------------------------------------
       .xu0_gpr_ex6_we(xu0_gpr_ex6_we),
       .xu0_gpr_ex6_wa(xu0_gpr_ex6_wa),
       .xu0_gpr_ex6_wd(xu0_gpr_ex6_wd),
       .xu1_gpr_ex3_we(xu1_gpr_ex3_we),
       .xu1_gpr_ex3_wa(xu1_gpr_ex3_wa),
       .xu1_gpr_ex3_wd(xu1_gpr_ex3_wd),

       .lq_xu_gpr_ex5_we(lq_xu_gpr_ex5_we),
       .lq_xu_gpr_ex5_wa(lq_xu_gpr_ex5_wa),
       .lq_xu_gpr_rel_we(lq_xu_gpr_rel_we),
       .lq_xu_gpr_rel_wa(lq_xu_gpr_rel_wa),
       .lq_xu_gpr_rel_wd(lq_xu_gpr_rel_wd),

       .lq_xu_cr_l2_we(lq_xu_cr_l2_we),
       .lq_xu_cr_l2_wa(lq_xu_cr_l2_wa),
       .lq_xu_cr_l2_wd(lq_xu_cr_l2_wd),
       .lq_xu_cr_ex5_we(lq_xu_cr_ex5_we),
       .lq_xu_cr_ex5_wa(lq_xu_cr_ex5_wa),
       .axu_xu_cr_w0e(axu0_cr_w4e),
       .axu_xu_cr_w0a(axu0_cr_w4a),
       .axu_xu_cr_w0d(axu0_cr_w4d),

       .iu_rf_xer_p_t0(iu_rf_t0_xer_p),
`ifndef THREADS1
       .iu_rf_xer_p_t1(iu_rf_t1_xer_p),
`endif
       .xer_lq_cp_rd(xu_lq_xer_cp_rd),

       //-------------------------------------------------------------------
       // AXU Pass Thru Interface
       //-------------------------------------------------------------------
       .lq_xu_axu_ex4_addr(lq_xu_axu_ex4_addr),
       .lq_xu_axu_ex5_we(lq_xu_axu_ex5_we),
       .lq_xu_axu_ex5_le(lq_xu_axu_ex5_le),
       .xu_axu_lq_ex4_addr(xu_axu_lq_ex4_addr),
       .xu_axu_lq_ex5_we(xu_axu_lq_ex5_we),
       .xu_axu_lq_ex5_le(xu_axu_lq_ex5_le),
       .xu_axu_lq_ex5_wa(xu_axu_lq_ex5_wa),
       .xu_axu_lq_ex5_wd(xu_axu_lq_ex5_wd),
       .xu_axu_lq_ex5_abort(xu_axu_lq_ex5_abort),

       .lq_xu_axu_rel_we(lq_xu_axu_rel_we),
       .lq_xu_axu_rel_le(lq_xu_axu_rel_le),
       .xu_axu_lq_rel_we(xu_axu_lq_rel_we),
       .xu_axu_lq_rel_le(xu_axu_lq_rel_le),
       .xu_axu_lq_rel_wa(xu_axu_lq_rel_wa),
       .xu_axu_lq_rel_wd(xu_axu_lq_rel_wd),

       .axu_xu_lq_ex_stq_val(axu_xu_lq_ex_stq_val),
       .axu_xu_lq_ex_stq_itag(axu_xu_lq_ex_stq_itag),
       .axu_xu_lq_exp1_stq_data(axu_xu_lq_exp1_stq_data),
       .xu_lq_axu_ex_stq_val(xu_lq_axu_ex_stq_val),
       .xu_lq_axu_ex_stq_itag(xu_lq_axu_ex_stq_itag),
       .xu_lq_axu_exp1_stq_data(xu_lq_axu_exp1_stq_data),

       //-------------------------------------------------------------------
       // SPR
       //-------------------------------------------------------------------
       // PERF
      .pc_xu_event_count_mode(pc_xu_event_count_mode),
      .pc_xu_event_bus_enable(pc_xu_event_bus_enable),
      .xu_event_bus_in(xu_event_bus_in),
      .xu_event_bus_out(xu_event_bus_out),
       // Debug
      .pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
      .xu_debug_bus_in(xu_debug_bus_in),
      .xu_debug_bus_out(xu_debug_bus_out),
      .xu_coretrace_ctrls_in(xu_coretrace_ctrls_in),
      .xu_coretrace_ctrls_out(xu_coretrace_ctrls_out),

       .an_ac_coreid(an_ac_coreid),
       .an_ac_chipid_dc(an_ac_chipid_dc),
       .spr_pvr_version_dc(spr_pvr_version_dc),
       .spr_pvr_revision_dc(spr_pvr_revision_dc),
       .spr_pvr_revision_minor_dc(spr_pvr_revision_minor_dc),
       .an_ac_ext_interrupt(an_ac_ext_interrupt),
       .an_ac_crit_interrupt(an_ac_crit_interrupt),
       .an_ac_perf_interrupt(an_ac_perf_interrupt),
       .an_ac_reservation_vld(an_ac_reservation_vld),
       .an_ac_tb_update_pulse(an_ac_tb_update_pulse),
       .an_ac_tb_update_enable(an_ac_tb_update_enable),
       .an_ac_sleep_en(an_ac_sleep_en),
       .an_ac_hang_pulse(an_ac_hang_pulse),
       .ac_tc_machine_check(ac_an_machine_check),
       .an_ac_external_mchk(an_ac_external_mchk),
       .pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
       .pc_xu_instr_trace_tid(pc_xu_instr_trace_tid),

       .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
       .an_ac_scan_diag_dc(an_ac_scan_diag_dc),

       // Interrupt Interface
       .iu_xu_rfi(iu_xu_rfi),
       .iu_xu_rfgi(iu_xu_rfgi),
       .iu_xu_rfci(iu_xu_rfci),
       .iu_xu_rfmci(iu_xu_rfmci),
       .iu_xu_act(iu_xu_act),
       .iu_xu_int(iu_xu_int),
       .iu_xu_gint(iu_xu_gint),
       .iu_xu_cint(iu_xu_cint),
       .iu_xu_mcint(iu_xu_mcint),
       .iu_xu_dear_update(iu_xu_dear_update),
       .iu_xu_dbsr_update(iu_xu_dbsr_update),
       .iu_xu_dbsr_ude(iu_xu_dbsr_ude),
       .iu_xu_dbsr_ide(iu_xu_dbsr_ide),
       .iu_xu_esr_update(iu_xu_esr_update),
       .iu_xu_force_gsrr(iu_xu_gdbell_taken),
       .xu_iu_dbsr_ide(xu_iu_dbsr_ide),
       .xu_iu_rest_ifar_t0(xu_iu_t0_rest_ifar),
       .iu_xu_nia_t0(iu_xu_t0_nia),
       .iu_xu_esr_t0(iu_xu_t0_esr),
       .iu_xu_mcsr_t0(iu_xu_t0_mcsr),
       .iu_xu_dbsr_t0(iu_xu_t0_dbsr),
       .iu_xu_dear_t0(iu_xu_t0_dear),
`ifndef THREADS1
       .xu_iu_rest_ifar_t1(xu_iu_t1_rest_ifar),
       .iu_xu_nia_t1(iu_xu_t1_nia),
       .iu_xu_esr_t1(iu_xu_t1_esr),
       .iu_xu_mcsr_t1(iu_xu_t1_mcsr),
       .iu_xu_dbsr_t1(iu_xu_t1_dbsr),
       .iu_xu_dear_t1(iu_xu_t1_dear),
`endif
       // Async Interrupt Req Interface
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
       .iu_xu_dbell_taken(iu_xu_dbell_taken),
       .iu_xu_cdbell_taken(iu_xu_cdbell_taken),
       .iu_xu_gdbell_taken(iu_xu_gdbell_taken),
       .iu_xu_gcdbell_taken(iu_xu_gcdbell_taken),
       .iu_xu_gmcdbell_taken(iu_xu_gmcdbell_taken),

       // DBELL Int
       .lq_xu_dbell_val(lq_xu_dbell_val),
       .lq_xu_dbell_type(lq_xu_dbell_type),
       .lq_xu_dbell_brdcast(lq_xu_dbell_brdcast),
       .lq_xu_dbell_lpid_match(lq_xu_dbell_lpid_match),
       .lq_xu_dbell_pirtag(lq_xu_dbell_pirtag),

       // Slow SPR Bus
       .xu_slowspr_val_out(xu_slowspr_val_out),
       .xu_slowspr_rw_out(xu_slowspr_rw_out),
       .xu_slowspr_etid_out(xu_slowspr_etid_out),
       .xu_slowspr_addr_out(xu_slowspr_addr_out),
       .xu_slowspr_data_out(xu_slowspr_data_out),

       // Trap
       .xu_iu_fp_precise(),
       // Run State
       .pc_xu_pm_hold_thread(pc_xu_pm_hold_thread),
       .iu_xu_stop(iu_xu_stop),
       .xu_pc_running(xu_pc_running),
       .xu_iu_run_thread(xu_iu_run_thread),
       .xu_iu_single_instr_mode(xu_iu_single_instr_mode),
       .xu_iu_raise_iss_pri(xu_iu_raise_iss_pri),
       .xu_iu_np1_async_flush(xu_iu_np1_async_flush),
       .iu_xu_async_complete(iu_xu_async_complete),
       .iu_xu_credits_returned(iu_xu_credits_returned),
       .xu_pc_spr_ccr0_we(xu_pc_spr_ccr0_we),
       .xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr),

       // Quiesce
	    .iu_xu_icache_quiesce(iu_xu_icache_quiesce),
       .iu_xu_quiesce(iu_xu_quiesce),
       .lq_xu_quiesce(lq_xu_quiesce),
       .mm_xu_quiesce(mm_xu_quiesce),
       .bx_xu_quiesce(bx_xu_quiesce),

       // PCCR0
       .pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
       .pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
       .pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),

       // MSR Override
       .pc_xu_ram_active(pc_xu_ram_active),
       .pc_xu_msrovride_enab(pc_xu_msrovride_enab),
       .xu_iu_msrovride_enab(xu_iu_msrovride_enab),
       .pc_xu_msrovride_pr(pc_xu_msrovride_pr),
       .pc_xu_msrovride_gs(pc_xu_msrovride_gs),
       .pc_xu_msrovride_de(pc_xu_msrovride_de),
       // SIAR
       .pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae),
       .xu_pc_perfmon_alert(xu_pc_perfmon_alert),

       // LiveLock
       .iu_xu_instr_cpl(iu_xu_instr_cpl),
       .xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
       .xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),

       // Resets
       .pc_xu_reset_wd_complete(an_ac_reset_wd_complete),
       .pc_xu_reset_1_complete(an_ac_reset_1_complete),
       .pc_xu_reset_2_complete(an_ac_reset_2_complete),
       .pc_xu_reset_3_complete(an_ac_reset_3_complete),
       .ac_tc_reset_1_request(ac_an_reset_1_request),
       .ac_tc_reset_2_request(ac_an_reset_2_request),
       .ac_tc_reset_3_request(ac_an_reset_3_request),
       .ac_tc_reset_wd_request(ac_an_reset_wd_request),

       // Err Inject
       .pc_xu_inj_llbust_attempt(pc_xu_inj_llbust_attempt),
       .pc_xu_inj_llbust_failed(pc_xu_inj_llbust_failed),
       .pc_xu_inj_wdt_reset({`THREADS{1'b0}}),
       .xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),

       // Parity
       .pc_xu_inj_sprg_ecc(pc_xu_inj_sprg_ecc),
       .xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
       .xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),

       // SPRs
       .spr_dbcr0_edm(pc_xu_spr_dbcr0_edm),
       .spr_xucr0_clkg_ctl(),
       .xu_iu_iac1_en(xu_iu_iac1_en),
       .xu_iu_iac2_en(xu_iu_iac2_en),
       .xu_iu_iac3_en(xu_iu_iac3_en),
       .xu_iu_iac4_en(xu_iu_iac4_en),
       .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
       .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
       .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),
       .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
       .spr_epcr_extgs(xu_iu_epcr_extgs),
       .spr_epcr_icm(xu_iu_epcr_icm),
       .spr_epcr_gicm(xu_iu_epcr_gicm),
       .spr_msr_de(spr_msr_de),
       .spr_msr_pr(spr_msr_pr),
       .spr_msr_is(spr_msr_is),
       .spr_msr_cm(spr_msr_cm),
       .spr_msr_gs(spr_msr_gs),
       .spr_msr_ee(spr_msr_ee),
       .spr_msr_ce(spr_msr_ce),
       .spr_msr_me(spr_msr_me),
       .spr_msr_fe0(spr_msr_fe0),
       .spr_msr_fe1(spr_msr_fe1),
       .xu_lsu_spr_xucr0_clfc(spr_xucr0_clfc),
       .xu_pc_spr_ccr0_pme(xu_pc_spr_ccr0_pme),
       .spr_ccr2_en_dcr(spr_ccr2_en_dcr),
       .spr_ccr2_en_trace(spr_ccr2_en_trace),
       .spr_ccr2_ifratsc(spr_ccr2_ifratsc),
       .spr_ccr2_ifrat(spr_ccr2_ifrat),
       .spr_ccr2_dfratsc(spr_ccr2_dfratsc),
       .spr_ccr2_dfrat(spr_ccr2_dfrat),
       .spr_ccr2_ucode_dis(spr_ccr2_ucode_dis),
       .spr_ccr2_ap(spr_ccr2_ap),
       .spr_ccr2_en_ditc(spr_ccr2_en_ditc),
       .spr_ccr2_en_icswx(spr_ccr2_en_icswx),
       .spr_ccr2_notlb(spr_ccr2_notlb),
       .spr_ccr2_en_pc(spr_ccr2_en_pc),
       .spr_xucr0_trace_um(spr_xucr0_trace_um),
       .xu_lsu_spr_xucr0_mbar_ack(spr_xucr0_mbar_ack),
       .xu_lsu_spr_xucr0_tlbsync(spr_xucr0_tlbsync),
       .spr_xucr0_cls(spr_xucr0_cls),
       .xu_lsu_spr_xucr0_aflsta(spr_xucr0_aflsta),
       .spr_xucr0_mddp(spr_xucr0_mddp),
       .xu_lsu_spr_xucr0_cred(spr_xucr0_cred),
       .xu_lsu_spr_xucr0_rel(spr_xucr0_rel),
       .spr_xucr0_mdcp(spr_xucr0_mdcp),
       .xu_lsu_spr_xucr0_flsta(spr_xucr0_flsta),
       .xu_lsu_spr_xucr0_l2siw(spr_xucr0_l2siw),
       .xu_lsu_spr_xucr0_flh2l2(spr_xucr0_flh2l2),
       .xu_lsu_spr_xucr0_dcdis(spr_xucr0_dc_dis),
       .xu_lsu_spr_xucr0_wlk(spr_xucr0_wlk),
       .spr_dbcr0_idm(spr_dbcr0_idm),
       .spr_dbcr0_icmp(spr_dbcr0_icmp),
       .spr_dbcr0_brt(spr_dbcr0_brt),
       .spr_dbcr0_irpt(spr_dbcr0_irpt),
       .spr_dbcr0_trap(spr_dbcr0_trap),
       .spr_dbcr0_dac1(spr_dbcr0_dac1),
       .spr_dbcr0_dac2(spr_dbcr0_dac2),
       .spr_dbcr0_ret(spr_dbcr0_ret),
       .spr_dbcr0_dac3(spr_dbcr0_dac3),
       .spr_dbcr0_dac4(spr_dbcr0_dac4),
       .spr_dbcr1_iac12m(spr_dbcr1_iac12m),
       .spr_dbcr1_iac34m(spr_dbcr1_iac34m),
       .spr_epcr_dtlbgs(xu_iu_epcr_dtlbgs),
       .spr_epcr_itlbgs(xu_iu_epcr_itlbgs),
       .spr_epcr_dsigs(xu_iu_epcr_dsigs),
       .spr_epcr_isigs(xu_iu_epcr_isigs),
       .spr_epcr_duvd(xu_iu_epcr_duvd),
       .spr_epcr_dgtmi(spr_epcr_dgtmi),
       .xu_mm_spr_epcr_dmiuh(xu_mm_spr_epcr_dmiuh),
       .spr_msr_ucle(spr_msr_ucle),
       .spr_msr_spv(spr_msr_spv),
       .spr_msr_fp(spr_msr_fp),
       .spr_msr_ds(spr_msr_ds),
       .spr_msrp_uclep(spr_msrp_uclep),
       .spr_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),
       .spr_xucr4_mddmh(spr_xucr4_mddmh),

       .xu_iu_act(),
       .xu_mm_act(),

       // BOLT-ON
       .bo_enable_2(1'b0),		// general bolt-on enable
       .pc_xu_bo_reset(1'b0),		// reset
       .pc_xu_bo_unload(1'b0),		// unload sticky bits
       .pc_xu_bo_repair(1'b0),		// execute sticky bit decode
       .pc_xu_bo_shdata(1'b0),		// shift data for timing write and diag loop
       .pc_xu_bo_select(1'b0),		// select for mask and hier writes
       .xu_pc_bo_fail(),		// fail/no-fix reg
       .xu_pc_bo_diagout(),
       // ABIST
       .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
       .pc_xu_abist_ena_dc(1'b0),
       .pc_xu_abist_g8t_wenb(1'b0),
       .pc_xu_abist_waddr_0({6{1'b0}}),
       .pc_xu_abist_di_0({4{1'b0}}),
       .pc_xu_abist_g8t1p_renb_0(1'b0),
       .pc_xu_abist_raddr_0({6{1'b0}}),
       .pc_xu_abist_wl32_comp_ena(1'b0),
       .pc_xu_abist_raw_dc_b(1'b0),
       .pc_xu_abist_g8t_dcomp({4{1'b0}}),
       .pc_xu_abist_g8t_bw_1(1'b0),
       .pc_xu_abist_g8t_bw_0(1'b0),

       .pc_xu_trace_bus_enable(pc_xu_trace_bus_enable)
       );



   assign lq_rv_ord_complete = 1'b0;
   assign rv_fx0_ex0_spec_flush = {`THREADS{1'b0}};
   assign rv_fx0_ex1_spec_flush = {`THREADS{1'b0}};
   assign rv_fx0_ex2_spec_flush = {`THREADS{1'b0}};
   assign rv_fx1_ex0_spec_flush = {`THREADS{1'b0}};
   assign rv_fx1_ex1_spec_flush = {`THREADS{1'b0}};
   assign rv_fx1_ex2_spec_flush = {`THREADS{1'b0}};



   rv
     rv0(

	 //-------------------------------------------------------------------
	 // Instructions from IU
	 //-------------------------------------------------------------------
	 .iu_rv_iu6_t0_i0_vld(iu_rv_iu6_t0_i0_vld),
	 .iu_rv_iu6_t0_i0_rte_lq(iu_rv_iu6_t0_i0_rte_lq),
	 .iu_rv_iu6_t0_i0_rte_sq(iu_rv_iu6_t0_i0_rte_sq),
	 .iu_rv_iu6_t0_i0_rte_fx0(iu_rv_iu6_t0_i0_rte_fx0),
	 .iu_rv_iu6_t0_i0_rte_fx1(iu_rv_iu6_t0_i0_rte_fx1),
	 .iu_rv_iu6_t0_i0_rte_axu0(iu_rv_iu6_t0_i0_rte_axu0),
	 .iu_rv_iu6_t0_i0_rte_axu1(iu_rv_iu6_t0_i0_rte_axu1),
	 .iu_rv_iu6_t0_i0_act(iu_rv_iu6_t0_i0_act),
	 .iu_rv_iu6_t0_i0_instr(iu_rv_iu6_t0_i0_instr),
	 .iu_rv_iu6_t0_i0_ifar(iu_rv_iu6_t0_i0_ifar),
	 .iu_rv_iu6_t0_i0_ucode(iu_rv_iu6_t0_i0_ucode),
	 .iu_rv_iu6_t0_i0_2ucode(iu_rv_iu6_t0_i0_2ucode),
	 .iu_rv_iu6_t0_i0_ucode_cnt(iu_rv_iu6_t0_i0_ucode_cnt),
	 .iu_rv_iu6_t0_i0_itag(iu_rv_iu6_t0_i0_itag),
	 .iu_rv_iu6_t0_i0_ord(iu_rv_iu6_t0_i0_ord),
	 .iu_rv_iu6_t0_i0_cord(iu_rv_iu6_t0_i0_cord),
	 .iu_rv_iu6_t0_i0_spec(iu_rv_iu6_t0_i0_spec),
	 .iu_rv_iu6_t0_i0_t1_v(iu_rv_iu6_t0_i0_t1_v),
	 .iu_rv_iu6_t0_i0_t1_p(iu_rv_iu6_t0_i0_t1_p),
	 .iu_rv_iu6_t0_i0_t1_t(iu_rv_iu6_t0_i0_t1_t),
	 .iu_rv_iu6_t0_i0_t2_v(iu_rv_iu6_t0_i0_t2_v),
	 .iu_rv_iu6_t0_i0_t2_p(iu_rv_iu6_t0_i0_t2_p),
	 .iu_rv_iu6_t0_i0_t2_t(iu_rv_iu6_t0_i0_t2_t),
	 .iu_rv_iu6_t0_i0_t3_v(iu_rv_iu6_t0_i0_t3_v),
	 .iu_rv_iu6_t0_i0_t3_p(iu_rv_iu6_t0_i0_t3_p),
	 .iu_rv_iu6_t0_i0_t3_t(iu_rv_iu6_t0_i0_t3_t),
	 .iu_rv_iu6_t0_i0_s1_v(iu_rv_iu6_t0_i0_s1_v),
	 .iu_rv_iu6_t0_i0_s1_p(iu_rv_iu6_t0_i0_s1_p),
	 .iu_rv_iu6_t0_i0_s1_t(iu_rv_iu6_t0_i0_s1_t),
	 .iu_rv_iu6_t0_i0_s2_v(iu_rv_iu6_t0_i0_s2_v),
	 .iu_rv_iu6_t0_i0_s2_p(iu_rv_iu6_t0_i0_s2_p),
	 .iu_rv_iu6_t0_i0_s2_t(iu_rv_iu6_t0_i0_s2_t),
	 .iu_rv_iu6_t0_i0_s3_v(iu_rv_iu6_t0_i0_s3_v),
	 .iu_rv_iu6_t0_i0_s3_p(iu_rv_iu6_t0_i0_s3_p),
	 .iu_rv_iu6_t0_i0_s3_t(iu_rv_iu6_t0_i0_s3_t),
	 .iu_rv_iu6_t0_i0_ilat(iu_rv_iu6_t0_i0_ilat),
	 .iu_rv_iu6_t0_i0_isLoad(iu_rv_iu6_t0_i0_isLoad),
	 .iu_rv_iu6_t0_i0_isStore(iu_rv_iu6_t0_i0_isStore),
	 .iu_rv_iu6_t0_i0_s1_itag(iu_rv_iu6_t0_i0_s1_itag),
	 .iu_rv_iu6_t0_i0_s2_itag(iu_rv_iu6_t0_i0_s2_itag),
	 .iu_rv_iu6_t0_i0_s3_itag(iu_rv_iu6_t0_i0_s3_itag),
	 .iu_rv_iu6_t0_i0_fusion(iu_rv_iu6_t0_i0_fusion),
	 .iu_rv_iu6_t0_i0_bta_val(iu_rv_iu6_t0_i0_bta_val),
	 .iu_rv_iu6_t0_i0_bta(iu_rv_iu6_t0_i0_bta),
	 .iu_rv_iu6_t0_i0_br_pred(iu_rv_iu6_t0_i0_br_pred),
	 .iu_rv_iu6_t0_i0_ls_ptr(iu_rv_iu6_t0_i0_ls_ptr),
	 .iu_rv_iu6_t0_i0_bh_update(iu_rv_iu6_t0_i0_bh_update),
	 .iu_rv_iu6_t0_i0_gshare(iu_rv_iu6_t0_i0_gshare),

	 .iu_rv_iu6_t0_i1_vld(iu_rv_iu6_t0_i1_vld),
	 .iu_rv_iu6_t0_i1_rte_lq(iu_rv_iu6_t0_i1_rte_lq),
	 .iu_rv_iu6_t0_i1_rte_sq(iu_rv_iu6_t0_i1_rte_sq),
	 .iu_rv_iu6_t0_i1_rte_fx0(iu_rv_iu6_t0_i1_rte_fx0),
	 .iu_rv_iu6_t0_i1_rte_fx1(iu_rv_iu6_t0_i1_rte_fx1),
	 .iu_rv_iu6_t0_i1_rte_axu0(iu_rv_iu6_t0_i1_rte_axu0),
	 .iu_rv_iu6_t0_i1_rte_axu1(iu_rv_iu6_t0_i1_rte_axu1),
	 .iu_rv_iu6_t0_i1_act(iu_rv_iu6_t0_i1_act),
	 .iu_rv_iu6_t0_i1_instr(iu_rv_iu6_t0_i1_instr),
	 .iu_rv_iu6_t0_i1_ifar(iu_rv_iu6_t0_i1_ifar),
	 .iu_rv_iu6_t0_i1_ucode(iu_rv_iu6_t0_i1_ucode),
	 .iu_rv_iu6_t0_i1_ucode_cnt(iu_rv_iu6_t0_i1_ucode_cnt),
	 .iu_rv_iu6_t0_i1_itag(iu_rv_iu6_t0_i1_itag),
	 .iu_rv_iu6_t0_i1_ord(iu_rv_iu6_t0_i1_ord),
	 .iu_rv_iu6_t0_i1_cord(iu_rv_iu6_t0_i1_cord),
	 .iu_rv_iu6_t0_i1_spec(iu_rv_iu6_t0_i1_spec),
	 .iu_rv_iu6_t0_i1_t1_v(iu_rv_iu6_t0_i1_t1_v),
	 .iu_rv_iu6_t0_i1_t1_p(iu_rv_iu6_t0_i1_t1_p),
	 .iu_rv_iu6_t0_i1_t1_t(iu_rv_iu6_t0_i1_t1_t),
	 .iu_rv_iu6_t0_i1_t2_v(iu_rv_iu6_t0_i1_t2_v),
	 .iu_rv_iu6_t0_i1_t2_p(iu_rv_iu6_t0_i1_t2_p),
	 .iu_rv_iu6_t0_i1_t2_t(iu_rv_iu6_t0_i1_t2_t),
	 .iu_rv_iu6_t0_i1_t3_v(iu_rv_iu6_t0_i1_t3_v),
	 .iu_rv_iu6_t0_i1_t3_p(iu_rv_iu6_t0_i1_t3_p),
	 .iu_rv_iu6_t0_i1_t3_t(iu_rv_iu6_t0_i1_t3_t),
	 .iu_rv_iu6_t0_i1_s1_v(iu_rv_iu6_t0_i1_s1_v),
	 .iu_rv_iu6_t0_i1_s1_p(iu_rv_iu6_t0_i1_s1_p),
	 .iu_rv_iu6_t0_i1_s1_t(iu_rv_iu6_t0_i1_s1_t),
	 .iu_rv_iu6_t0_i1_s2_v(iu_rv_iu6_t0_i1_s2_v),
	 .iu_rv_iu6_t0_i1_s2_p(iu_rv_iu6_t0_i1_s2_p),
	 .iu_rv_iu6_t0_i1_s2_t(iu_rv_iu6_t0_i1_s2_t),
	 .iu_rv_iu6_t0_i1_s3_v(iu_rv_iu6_t0_i1_s3_v),
	 .iu_rv_iu6_t0_i1_s3_p(iu_rv_iu6_t0_i1_s3_p),
	 .iu_rv_iu6_t0_i1_s3_t(iu_rv_iu6_t0_i1_s3_t),
	 .iu_rv_iu6_t0_i1_ilat(iu_rv_iu6_t0_i1_ilat),
	 .iu_rv_iu6_t0_i1_isLoad(iu_rv_iu6_t0_i1_isLoad),
	 .iu_rv_iu6_t0_i1_isStore(iu_rv_iu6_t0_i1_isStore),
	 .iu_rv_iu6_t0_i1_s1_itag(iu_rv_iu6_t0_i1_s1_itag),
	 .iu_rv_iu6_t0_i1_s2_itag(iu_rv_iu6_t0_i1_s2_itag),
	 .iu_rv_iu6_t0_i1_s3_itag(iu_rv_iu6_t0_i1_s3_itag),
	 .iu_rv_iu6_t0_i1_s1_dep_hit(iu_rv_iu6_t0_i1_s1_dep_hit),
	 .iu_rv_iu6_t0_i1_s2_dep_hit(iu_rv_iu6_t0_i1_s2_dep_hit),
	 .iu_rv_iu6_t0_i1_s3_dep_hit(iu_rv_iu6_t0_i1_s3_dep_hit),
	 .iu_rv_iu6_t0_i1_fusion(iu_rv_iu6_t0_i1_fusion),
	 .iu_rv_iu6_t0_i1_bta_val(iu_rv_iu6_t0_i1_bta_val),
	 .iu_rv_iu6_t0_i1_bta(iu_rv_iu6_t0_i1_bta),
	 .iu_rv_iu6_t0_i1_br_pred(iu_rv_iu6_t0_i1_br_pred),
	 .iu_rv_iu6_t0_i1_ls_ptr(iu_rv_iu6_t0_i1_ls_ptr),
	 .iu_rv_iu6_t0_i1_bh_update(iu_rv_iu6_t0_i1_bh_update),
	 .iu_rv_iu6_t0_i1_gshare(iu_rv_iu6_t0_i1_gshare),
`ifndef THREADS1
	 .iu_rv_iu6_t1_i0_vld(iu_rv_iu6_t1_i0_vld),
	 .iu_rv_iu6_t1_i0_rte_lq(iu_rv_iu6_t1_i0_rte_lq),
	 .iu_rv_iu6_t1_i0_rte_sq(iu_rv_iu6_t1_i0_rte_sq),
	 .iu_rv_iu6_t1_i0_rte_fx0(iu_rv_iu6_t1_i0_rte_fx0),
	 .iu_rv_iu6_t1_i0_rte_fx1(iu_rv_iu6_t1_i0_rte_fx1),
	 .iu_rv_iu6_t1_i0_rte_axu0(iu_rv_iu6_t1_i0_rte_axu0),
	 .iu_rv_iu6_t1_i0_rte_axu1(iu_rv_iu6_t1_i0_rte_axu1),
	 .iu_rv_iu6_t1_i0_act(iu_rv_iu6_t1_i0_act),
	 .iu_rv_iu6_t1_i0_instr(iu_rv_iu6_t1_i0_instr),
	 .iu_rv_iu6_t1_i0_ifar(iu_rv_iu6_t1_i0_ifar),
	 .iu_rv_iu6_t1_i0_ucode(iu_rv_iu6_t1_i0_ucode),
	 .iu_rv_iu6_t1_i0_2ucode(iu_rv_iu6_t1_i0_2ucode),
	 .iu_rv_iu6_t1_i0_ucode_cnt(iu_rv_iu6_t1_i0_ucode_cnt),
	 .iu_rv_iu6_t1_i0_itag(iu_rv_iu6_t1_i0_itag),
	 .iu_rv_iu6_t1_i0_ord(iu_rv_iu6_t1_i0_ord),
	 .iu_rv_iu6_t1_i0_cord(iu_rv_iu6_t1_i0_cord),
	 .iu_rv_iu6_t1_i0_spec(iu_rv_iu6_t1_i0_spec),
	 .iu_rv_iu6_t1_i0_t1_v(iu_rv_iu6_t1_i0_t1_v),
	 .iu_rv_iu6_t1_i0_t1_p(iu_rv_iu6_t1_i0_t1_p),
	 .iu_rv_iu6_t1_i0_t1_t(iu_rv_iu6_t1_i0_t1_t),
	 .iu_rv_iu6_t1_i0_t2_v(iu_rv_iu6_t1_i0_t2_v),
	 .iu_rv_iu6_t1_i0_t2_p(iu_rv_iu6_t1_i0_t2_p),
	 .iu_rv_iu6_t1_i0_t2_t(iu_rv_iu6_t1_i0_t2_t),
	 .iu_rv_iu6_t1_i0_t3_v(iu_rv_iu6_t1_i0_t3_v),
	 .iu_rv_iu6_t1_i0_t3_p(iu_rv_iu6_t1_i0_t3_p),
	 .iu_rv_iu6_t1_i0_t3_t(iu_rv_iu6_t1_i0_t3_t),
	 .iu_rv_iu6_t1_i0_s1_v(iu_rv_iu6_t1_i0_s1_v),
	 .iu_rv_iu6_t1_i0_s1_p(iu_rv_iu6_t1_i0_s1_p),
	 .iu_rv_iu6_t1_i0_s1_t(iu_rv_iu6_t1_i0_s1_t),
	 .iu_rv_iu6_t1_i0_s2_v(iu_rv_iu6_t1_i0_s2_v),
	 .iu_rv_iu6_t1_i0_s2_p(iu_rv_iu6_t1_i0_s2_p),
	 .iu_rv_iu6_t1_i0_s2_t(iu_rv_iu6_t1_i0_s2_t),
	 .iu_rv_iu6_t1_i0_s3_v(iu_rv_iu6_t1_i0_s3_v),
	 .iu_rv_iu6_t1_i0_s3_p(iu_rv_iu6_t1_i0_s3_p),
	 .iu_rv_iu6_t1_i0_s3_t(iu_rv_iu6_t1_i0_s3_t),
	 .iu_rv_iu6_t1_i0_ilat(iu_rv_iu6_t1_i0_ilat),
	 .iu_rv_iu6_t1_i0_isLoad(iu_rv_iu6_t1_i0_isLoad),
	 .iu_rv_iu6_t1_i0_isStore(iu_rv_iu6_t1_i0_isStore),
	 .iu_rv_iu6_t1_i0_s1_itag(iu_rv_iu6_t1_i0_s1_itag),
	 .iu_rv_iu6_t1_i0_s2_itag(iu_rv_iu6_t1_i0_s2_itag),
	 .iu_rv_iu6_t1_i0_s3_itag(iu_rv_iu6_t1_i0_s3_itag),
	 .iu_rv_iu6_t1_i0_fusion(iu_rv_iu6_t1_i0_fusion),
	 .iu_rv_iu6_t1_i0_bta_val(iu_rv_iu6_t1_i0_bta_val),
	 .iu_rv_iu6_t1_i0_bta(iu_rv_iu6_t1_i0_bta),
	 .iu_rv_iu6_t1_i0_br_pred(iu_rv_iu6_t1_i0_br_pred),
	 .iu_rv_iu6_t1_i0_ls_ptr(iu_rv_iu6_t1_i0_ls_ptr),
	 .iu_rv_iu6_t1_i0_bh_update(iu_rv_iu6_t1_i0_bh_update),
	 .iu_rv_iu6_t1_i0_gshare(iu_rv_iu6_t1_i0_gshare),

	 .iu_rv_iu6_t1_i1_vld(iu_rv_iu6_t1_i1_vld),
	 .iu_rv_iu6_t1_i1_rte_lq(iu_rv_iu6_t1_i1_rte_lq),
	 .iu_rv_iu6_t1_i1_rte_sq(iu_rv_iu6_t1_i1_rte_sq),
	 .iu_rv_iu6_t1_i1_rte_fx0(iu_rv_iu6_t1_i1_rte_fx0),
	 .iu_rv_iu6_t1_i1_rte_fx1(iu_rv_iu6_t1_i1_rte_fx1),
	 .iu_rv_iu6_t1_i1_rte_axu0(iu_rv_iu6_t1_i1_rte_axu0),
	 .iu_rv_iu6_t1_i1_rte_axu1(iu_rv_iu6_t1_i1_rte_axu1),
	 .iu_rv_iu6_t1_i1_act(iu_rv_iu6_t1_i1_act),
	 .iu_rv_iu6_t1_i1_instr(iu_rv_iu6_t1_i1_instr),
	 .iu_rv_iu6_t1_i1_ifar(iu_rv_iu6_t1_i1_ifar),
	 .iu_rv_iu6_t1_i1_ucode(iu_rv_iu6_t1_i1_ucode),
	 .iu_rv_iu6_t1_i1_ucode_cnt(iu_rv_iu6_t1_i1_ucode_cnt),
	 .iu_rv_iu6_t1_i1_itag(iu_rv_iu6_t1_i1_itag),
	 .iu_rv_iu6_t1_i1_ord(iu_rv_iu6_t1_i1_ord),
	 .iu_rv_iu6_t1_i1_cord(iu_rv_iu6_t1_i1_cord),
	 .iu_rv_iu6_t1_i1_spec(iu_rv_iu6_t1_i1_spec),
	 .iu_rv_iu6_t1_i1_t1_v(iu_rv_iu6_t1_i1_t1_v),
	 .iu_rv_iu6_t1_i1_t1_p(iu_rv_iu6_t1_i1_t1_p),
	 .iu_rv_iu6_t1_i1_t1_t(iu_rv_iu6_t1_i1_t1_t),
	 .iu_rv_iu6_t1_i1_t2_v(iu_rv_iu6_t1_i1_t2_v),
	 .iu_rv_iu6_t1_i1_t2_p(iu_rv_iu6_t1_i1_t2_p),
	 .iu_rv_iu6_t1_i1_t2_t(iu_rv_iu6_t1_i1_t2_t),
	 .iu_rv_iu6_t1_i1_t3_v(iu_rv_iu6_t1_i1_t3_v),
	 .iu_rv_iu6_t1_i1_t3_p(iu_rv_iu6_t1_i1_t3_p),
	 .iu_rv_iu6_t1_i1_t3_t(iu_rv_iu6_t1_i1_t3_t),
	 .iu_rv_iu6_t1_i1_s1_v(iu_rv_iu6_t1_i1_s1_v),
	 .iu_rv_iu6_t1_i1_s1_p(iu_rv_iu6_t1_i1_s1_p),
	 .iu_rv_iu6_t1_i1_s1_t(iu_rv_iu6_t1_i1_s1_t),
	 .iu_rv_iu6_t1_i1_s2_v(iu_rv_iu6_t1_i1_s2_v),
	 .iu_rv_iu6_t1_i1_s2_p(iu_rv_iu6_t1_i1_s2_p),
	 .iu_rv_iu6_t1_i1_s2_t(iu_rv_iu6_t1_i1_s2_t),
	 .iu_rv_iu6_t1_i1_s3_v(iu_rv_iu6_t1_i1_s3_v),
	 .iu_rv_iu6_t1_i1_s3_p(iu_rv_iu6_t1_i1_s3_p),
	 .iu_rv_iu6_t1_i1_s3_t(iu_rv_iu6_t1_i1_s3_t),
	 .iu_rv_iu6_t1_i1_ilat(iu_rv_iu6_t1_i1_ilat),
	 .iu_rv_iu6_t1_i1_isLoad(iu_rv_iu6_t1_i1_isLoad),
	 .iu_rv_iu6_t1_i1_isStore(iu_rv_iu6_t1_i1_isStore),
	 .iu_rv_iu6_t1_i1_s1_itag(iu_rv_iu6_t1_i1_s1_itag),
	 .iu_rv_iu6_t1_i1_s2_itag(iu_rv_iu6_t1_i1_s2_itag),
	 .iu_rv_iu6_t1_i1_s3_itag(iu_rv_iu6_t1_i1_s3_itag),
	 .iu_rv_iu6_t1_i1_s1_dep_hit(iu_rv_iu6_t1_i1_s1_dep_hit),
	 .iu_rv_iu6_t1_i1_s2_dep_hit(iu_rv_iu6_t1_i1_s2_dep_hit),
	 .iu_rv_iu6_t1_i1_s3_dep_hit(iu_rv_iu6_t1_i1_s3_dep_hit),
	 .iu_rv_iu6_t1_i1_fusion(iu_rv_iu6_t1_i1_fusion),
	 .iu_rv_iu6_t1_i1_bta_val(iu_rv_iu6_t1_i1_bta_val),
	 .iu_rv_iu6_t1_i1_bta(iu_rv_iu6_t1_i1_bta),
	 .iu_rv_iu6_t1_i1_br_pred(iu_rv_iu6_t1_i1_br_pred),
	 .iu_rv_iu6_t1_i1_ls_ptr(iu_rv_iu6_t1_i1_ls_ptr),
	 .iu_rv_iu6_t1_i1_bh_update(iu_rv_iu6_t1_i1_bh_update),
	 .iu_rv_iu6_t1_i1_gshare(iu_rv_iu6_t1_i1_gshare),
	 .cp_t1_next_itag(cp_t1_next_itag),

`endif

	 .cp_t0_next_itag(cp_t0_next_itag),

	 .rv_iu_lq_credit_free(),
	 .rv_iu_fx0_credit_free(rv_iu_fx0_credit_free),
	 .rv_iu_fx1_credit_free(rv_iu_fx1_credit_free),
	 .rv_iu_axu0_credit_free(rv_iu_axu0_credit_free),
	 .rv_iu_axu1_credit_free(rv_iu_axu1_credit_free),

	 //-------------------------------------------------------------------
	 // Machine zap interface
	 //-------------------------------------------------------------------
	 .cp_flush(cp_flush),

	 //-------------------------------------------------------------------
	 // Interface to FX0
	 //-------------------------------------------------------------------
	 .rv_fx0_vld(rv_fx0_vld),
	 .rv_fx0_s1_v(rv_fx0_s1_v),
	 .rv_fx0_s1_p(rv_fx0_s1_p),
	 .rv_fx0_s2_v(rv_fx0_s2_v),
	 .rv_fx0_s2_p(rv_fx0_s2_p),
	 .rv_fx0_s3_v(rv_fx0_s3_v),
	 .rv_fx0_s3_p(rv_fx0_s3_p),

	 .rv_fx0_ex0_instr(rv_fx0_ex0_instr),
	 .rv_fx0_ex0_ifar(rv_fx0_ex0_ifar),
	 .rv_fx0_ex0_itag(rv_fx0_ex0_itag),
	 .rv_fx0_ex0_ucode(rv_fx0_ex0_ucode),
	 .rv_fx0_ex0_ucode_cnt(rv_fx0_ex0_ucode_cnt),
	 .rv_fx0_ex0_ord(rv_fx0_ex0_ord),
	 .rv_fx0_ex0_t1_v(rv_fx0_ex0_t1_v),
	 .rv_fx0_ex0_t1_p(rv_fx0_ex0_t1_p),
	 .rv_fx0_ex0_t1_t(rv_fx0_ex0_t1_t),
	 .rv_fx0_ex0_t2_v(rv_fx0_ex0_t2_v),
	 .rv_fx0_ex0_t2_p(rv_fx0_ex0_t2_p),
	 .rv_fx0_ex0_t2_t(rv_fx0_ex0_t2_t),
	 .rv_fx0_ex0_t3_v(rv_fx0_ex0_t3_v),
	 .rv_fx0_ex0_t3_p(rv_fx0_ex0_t3_p),
	 .rv_fx0_ex0_t3_t(rv_fx0_ex0_t3_t),
	 .rv_fx0_ex0_s1_v(rv_fx0_ex0_s1_v),
	 .rv_fx0_ex0_s2_v(rv_fx0_ex0_s2_v),
	 .rv_fx0_ex0_s2_t(rv_fx0_ex0_s2_t),
	 .rv_fx0_ex0_s3_v(rv_fx0_ex0_s3_v),
	 .rv_fx0_ex0_s3_t(rv_fx0_ex0_s3_t),
	 .rv_fx0_ex0_fusion(rv_fx0_ex0_fusion),
	 .rv_fx0_ex0_pred_bta(rv_fx0_ex0_pred_bta),
	 .rv_fx0_ex0_bta_val(rv_fx0_ex0_bta_val),
	 .rv_fx0_ex0_br_pred(rv_fx0_ex0_br_pred),
	 .rv_fx0_ex0_ls_ptr(rv_fx0_ex0_ls_ptr),
	 .rv_fx0_ex0_gshare(rv_fx0_ex0_gshare),
	 .rv_fx0_ex0_bh_update(rv_fx0_ex0_bh_update),

	 .fx0_rv_ord_itag(fx0_rv_ord_itag),
	 .fx0_rv_ord_complete(fx0_rv_ord_complete),
	 .fx0_rv_hold_all(fx0_rv_hold_all),

	 //-------------------------------------------------------------------
	 // Interface to FX1
	 //-------------------------------------------------------------------
	 .rv_fx1_vld(rv_fx1_vld),
	 .rv_fx1_s1_v(rv_fx1_s1_v),
	 .rv_fx1_s1_p(rv_fx1_s1_p),
	 .rv_fx1_s2_v(rv_fx1_s2_v),
	 .rv_fx1_s2_p(rv_fx1_s2_p),
	 .rv_fx1_s3_v(rv_fx1_s3_v),
	 .rv_fx1_s3_p(rv_fx1_s3_p),

	 .rv_fx1_ex0_instr(rv_fx1_ex0_instr),
	 .rv_fx1_ex0_itag(rv_fx1_ex0_itag),
	 .rv_fx1_ex0_ucode(rv_fx1_ex0_ucode),
	 .rv_fx1_ex0_t1_v(rv_fx1_ex0_t1_v),
	 .rv_fx1_ex0_t1_p(rv_fx1_ex0_t1_p),
	 .rv_fx1_ex0_t2_v(rv_fx1_ex0_t2_v),
	 .rv_fx1_ex0_t2_p(rv_fx1_ex0_t2_p),
	 .rv_fx1_ex0_t3_v(rv_fx1_ex0_t3_v),
	 .rv_fx1_ex0_t3_p(rv_fx1_ex0_t3_p),
	 .rv_fx1_ex0_s1_v(rv_fx1_ex0_s1_v),
	 .rv_fx1_ex0_s3_t(rv_fx1_ex0_s3_t),
	 .rv_fx1_ex0_isStore(rv_fx1_ex0_isStore),

	 .fx1_rv_hold_all(fx1_rv_hold_all),

	 //-------------------------------------------------------------------
	 // Interface to LQ
	 //-------------------------------------------------------------------
	 .rv_lq_vld(rv_lq_vld),
	 .rv_lq_isLoad(rv_lq_isLoad),
	 .rv_lq_ex0_itag(rv_lq_ex0_itag),
	 .rv_lq_ex0_instr(rv_lq_ex0_instr),
	 .rv_lq_ex0_ucode(rv_lq_ex0_ucode),
	 .rv_lq_ex0_ucode_cnt(rv_lq_ex0_ucode_cnt),
	 .rv_lq_ex0_spec(rv_lq_ex0_spec),
	 .rv_lq_ex0_t1_v(rv_lq_ex0_t1_v),
	 .rv_lq_ex0_t1_p(rv_lq_ex0_t1_p),
	 .rv_lq_ex0_t3_p(rv_lq_ex0_t3_p),
	 .rv_lq_ex0_s1_v(rv_lq_ex0_s1_v),
	 .rv_lq_ex0_s2_v(rv_lq_ex0_s2_v),
	 .rv_lq_ex0_s2_t(rv_lq_ex0_s2_t),
	 .rv_lq_rvs_empty(rv_lq_rvs_empty),

	 // LQ Release Interface
	 .lq_rv_itag0_vld(lq_rv_itag0_vld),
	 .lq_rv_itag0(lq_rv_itag0),
	 .lq_rv_itag0_abort(lq_rv_itag0_abort),

	 .lq_rv_itag1_vld(lq_rv_itag1_vld),
	 .lq_rv_itag1(lq_rv_itag1),
	 .lq_rv_itag1_restart(lq_rv_itag1_restart),
	 .lq_rv_itag1_abort(lq_rv_itag1_abort),
	 .lq_rv_itag1_hold(lq_rv_itag1_hold),
	 .lq_rv_itag1_cord(lq_rv_itag1_cord),

	 .lq_rv_itag2_vld(lq_rv_itag2_vld),
	 .lq_rv_itag2(lq_rv_itag2),

	 .lq_rv_clr_hold(lq_rv_clr_hold),
	 .lq_rv_ord_complete(lq_rv_ord_complete),
	 .lq_rv_hold_all(lq_rv_hold_all),

	 .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
	 .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
	 .rv_lq_rv1_i0_ucode_cnt(rv_lq_rv1_i0_ucode_cnt),
	 .rv_lq_rv1_i0_2ucode(rv_lq_rv1_i0_2ucode),
	 .rv_lq_rv1_i0_s3_t(rv_lq_rv1_i0_s3_t),
	 .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
	 .rv_lq_rv1_i0_isStore(rv_lq_rv1_i0_isStore),
	 .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
	 .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
	 .rv_lq_rv1_i0_rte_sq(rv_lq_rv1_i0_rte_sq),
	 .rv_lq_rv1_i0_ifar(rv_lq_rv1_i0_ifar),

	 .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
	 .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
	 .rv_lq_rv1_i1_ucode_cnt(rv_lq_rv1_i1_ucode_cnt),
	 .rv_lq_rv1_i1_2ucode(rv_lq_rv1_i1_2ucode),
	 .rv_lq_rv1_i1_s3_t(rv_lq_rv1_i1_s3_t),
	 .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
	 .rv_lq_rv1_i1_isStore(rv_lq_rv1_i1_isStore),
	 .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
	 .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
	 .rv_lq_rv1_i1_rte_sq(rv_lq_rv1_i1_rte_sq),
	 .rv_lq_rv1_i1_ifar(rv_lq_rv1_i1_ifar),

	 //-------------------------------------------------------------------
	 // Interface to AXU0
	 //-------------------------------------------------------------------
	 .rv_axu0_vld(rv_axu0_vld),
	 .rv_axu0_s1_v(rv_axu0_s1_v),
	 .rv_axu0_s1_p(rv_axu0_s1_p),
	 .rv_axu0_s2_v(rv_axu0_s2_v),
	 .rv_axu0_s2_p(rv_axu0_s2_p),
	 .rv_axu0_s3_v(rv_axu0_s3_v),
	 .rv_axu0_s3_p(rv_axu0_s3_p),

	 .rv_axu0_ex0_itag(rv_axu0_ex0_itag),
	 .rv_axu0_ex0_instr(rv_axu0_ex0_instr),
	 .rv_axu0_ex0_ucode(rv_axu0_ex0_ucode),
	 .rv_axu0_ex0_t1_v(rv_axu0_ex0_t1_v),
	 .rv_axu0_ex0_t1_p(rv_axu0_ex0_t1_p),
	 .rv_axu0_ex0_t2_p(rv_axu0_ex0_t2_p),
	 .rv_axu0_ex0_t3_p(rv_axu0_ex0_t3_p),

	 .axu0_rv_ord_complete(axu0_rv_ord_complete),
	 //-------------------------------------------------------------------
	 // Interface to AXU
	 //-------------------------------------------------------------------
	 .axu0_rv_itag_vld(axu0_rv_itag_vld),
	 .axu0_rv_itag(axu0_rv_itag),
	 .axu0_rv_itag_abort(axu0_rv_itag_abort),
         .axu0_rv_hold_all(axu0_rv_hold_all),
	 .axu1_rv_itag_vld(axu1_rv_itag_vld),
	 .axu1_rv_itag(axu1_rv_itag),
	 .axu1_rv_itag_abort(axu1_rv_itag_abort),
         .axu1_rv_hold_all(axu1_rv_hold_all),
	 //-------------------------------------------------------------------
	 // Abort
	 //-------------------------------------------------------------------
	 .lq_rv_ex2_s1_abort(lq_rv_ex2_s1_abort) ,
	 .lq_rv_ex2_s2_abort(lq_rv_ex2_s2_abort) ,
	 .fx0_rv_ex2_s1_abort(fx0_rv_ex2_s1_abort) ,
	 .fx0_rv_ex2_s2_abort(fx0_rv_ex2_s2_abort) ,
	 .fx0_rv_ex2_s3_abort(fx0_rv_ex2_s3_abort) ,
	 .fx1_rv_ex2_s1_abort(fx1_rv_ex2_s1_abort) ,
	 .fx1_rv_ex2_s2_abort(fx1_rv_ex2_s2_abort) ,
	 .fx1_rv_ex2_s3_abort(fx1_rv_ex2_s3_abort) ,
	 .axu0_rv_ex2_s1_abort(axu0_rv_ex2_s1_abort) ,
	 .axu0_rv_ex2_s2_abort(axu0_rv_ex2_s2_abort) ,
	 .axu0_rv_ex2_s3_abort(axu0_rv_ex2_s3_abort) ,


	 //-------------------------------------------------------------------
	 // Bypass
	 //-------------------------------------------------------------------
	 .rv_fx0_ex0_s1_fx0_sel(rv_fx0_ex0_s1_fx0_sel),
	 .rv_fx0_ex0_s2_fx0_sel(rv_fx0_ex0_s2_fx0_sel),
	 .rv_fx0_ex0_s3_fx0_sel(rv_fx0_ex0_s3_fx0_sel),
	 .rv_fx0_ex0_s1_lq_sel(rv_fx0_ex0_s1_lq_sel),
	 .rv_fx0_ex0_s2_lq_sel(rv_fx0_ex0_s2_lq_sel),
	 .rv_fx0_ex0_s3_lq_sel(rv_fx0_ex0_s3_lq_sel),
	 .rv_fx0_ex0_s1_fx1_sel(rv_fx0_ex0_s1_fx1_sel),
	 .rv_fx0_ex0_s2_fx1_sel(rv_fx0_ex0_s2_fx1_sel),
	 .rv_fx0_ex0_s3_fx1_sel(rv_fx0_ex0_s3_fx1_sel),
	 .rv_lq_ex0_s1_fx0_sel(rv_lq_ex0_s1_fx0_sel),
	 .rv_lq_ex0_s2_fx0_sel(rv_lq_ex0_s2_fx0_sel),
	 .rv_lq_ex0_s1_lq_sel(rv_lq_ex0_s1_lq_sel),
	 .rv_lq_ex0_s2_lq_sel(rv_lq_ex0_s2_lq_sel),
	 .rv_lq_ex0_s1_fx1_sel(rv_lq_ex0_s1_fx1_sel),
	 .rv_lq_ex0_s2_fx1_sel(rv_lq_ex0_s2_fx1_sel),
	 .rv_fx1_ex0_s1_fx0_sel(rv_fx1_ex0_s1_fx0_sel),
	 .rv_fx1_ex0_s2_fx0_sel(rv_fx1_ex0_s2_fx0_sel),
	 .rv_fx1_ex0_s3_fx0_sel(rv_fx1_ex0_s3_fx0_sel),
	 .rv_fx1_ex0_s1_lq_sel(rv_fx1_ex0_s1_lq_sel),
	 .rv_fx1_ex0_s2_lq_sel(rv_fx1_ex0_s2_lq_sel),
	 .rv_fx1_ex0_s3_lq_sel(rv_fx1_ex0_s3_lq_sel),
	 .rv_fx1_ex0_s1_fx1_sel(rv_fx1_ex0_s1_fx1_sel),
	 .rv_fx1_ex0_s2_fx1_sel(rv_fx1_ex0_s2_fx1_sel),
	 .rv_fx1_ex0_s3_fx1_sel(rv_fx1_ex0_s3_fx1_sel),
	 .rv_fx0_ex0_s1_rel_sel(rv_fx0_ex0_s1_rel_sel),
	 .rv_fx0_ex0_s2_rel_sel(rv_fx0_ex0_s2_rel_sel),
	 .rv_fx0_ex0_s3_rel_sel(rv_fx0_ex0_s3_rel_sel),
	 .rv_lq_ex0_s1_rel_sel(rv_lq_ex0_s1_rel_sel),
	 .rv_lq_ex0_s2_rel_sel(rv_lq_ex0_s2_rel_sel),
	 .rv_fx1_ex0_s1_rel_sel(rv_fx1_ex0_s1_rel_sel),
	 .rv_fx1_ex0_s2_rel_sel(rv_fx1_ex0_s2_rel_sel),
	 .rv_fx1_ex0_s3_rel_sel(rv_fx1_ex0_s3_rel_sel),

	 //-------------------------------------------------------------------
	 // LQ Regfile
	 //-------------------------------------------------------------------
	 .xu0_gpr_ex6_we(xu0_gpr_ex6_we),
	 .xu0_gpr_ex6_wa(xu0_gpr_ex6_wa),
	 .xu0_gpr_ex6_wd(xu0_gpr_ex6_wd),
	 .xu1_gpr_ex3_we(xu1_gpr_ex3_we),
	 .xu1_gpr_ex3_wa(xu1_gpr_ex3_wa),
	 .xu1_gpr_ex3_wd(xu1_gpr_ex3_wd),

	 .lq_rv_gpr_ex6_we(lq_rv_gpr_ex6_we),
	 .lq_rv_gpr_ex6_wa(lq_rv_gpr_ex6_wa),
	 .lq_rv_gpr_ex6_wd(lq_rv_gpr_ex6_wd),

	 .lq_rv_gpr_rel_we(lq_rv_gpr_rel_we),
	 .lq_rv_gpr_rel_wa(lq_rv_gpr_rel_wa),
	 .lq_rv_gpr_rel_wd(lq_rv_gpr_rel_wd),

	 .rv_lq_gpr_ex1_r0d(rv_lq_gpr_ex1_r0d),
	 .rv_lq_gpr_ex1_r1d(rv_lq_gpr_ex1_r1d),

	 //-------------------------------------------------------------------
	 // Debug and perf
	 //-------------------------------------------------------------------
	 .pc_rv_trace_bus_enable(pc_rv_trace_bus_enable),
	 .pc_rv_debug_mux_ctrls(pc_rv_debug_mux_ctrls),
	 .pc_rv_event_bus_enable(pc_rv_event_bus_enable),
	 .pc_rv_event_count_mode(pc_rv_event_count_mode),
	 .pc_rv_event_mux_ctrls(pc_rv_event_mux_ctrls),
         .spr_msr_gs(spr_msr_gs),
	 .spr_msr_pr(spr_msr_pr),

	 .rv_event_bus_in(rv_event_bus_in),
	 .rv_event_bus_out(rv_event_bus_out),

	 .debug_bus_out(rv_debug_bus_out),
	 .coretrace_ctrls_out(rv_coretrace_ctrls_out),
	 .debug_bus_in(rv_debug_bus_in),
	 .coretrace_ctrls_in(rv_coretrace_ctrls_in),

	 //-------------------------------------------------------------------
	 // Pervasive
	 //-------------------------------------------------------------------
	 //.vdd(vdd),
	 //.gnd(gnd),
	 .nclk(nclk),

	 .rp_rv_ccflush_dc(rp_rv_ccflush_dc),
	 .rp_rv_func_sl_thold_3(rp_rv_func_sl_thold_3),
	 .rp_rv_gptr_sl_thold_3(rp_rv_gptr_sl_thold_3),
	 .rp_rv_sg_3(rp_rv_sg_3),
	 .rp_rv_fce_3(rp_rv_fce_3),
	 .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
	 .an_ac_scan_diag_dc(an_ac_scan_diag_dc),

	 .scan_in(scan_in_rv),
	 .scan_out(scan_out_rv)
	 );


   lq
   lq0(
       //--------------------------------------------------------------
       // SPR Interface
       //--------------------------------------------------------------
       .xu_lq_spr_ccr2_en_trace(spr_ccr2_en_trace),
       .xu_lq_spr_ccr2_en_pc(spr_ccr2_en_pc),
       .xu_lq_spr_ccr2_en_ditc(spr_ccr2_en_ditc),
       .xu_lq_spr_ccr2_en_icswx(spr_ccr2_en_icswx),
       .xu_lq_spr_ccr2_dfrat(spr_ccr2_dfrat),
       .xu_lq_spr_ccr2_dfratsc(spr_ccr2_dfratsc),
       .xu_lq_spr_ccr2_ap(spr_ccr2_ap[0]),
       .xu_lq_spr_ccr2_ucode_dis(spr_ccr2_ucode_dis),
       .xu_lq_spr_xucr0_clkg_ctl(1'b0),
       .xu_lq_spr_xucr0_wlk(spr_xucr0_wlk),
       .xu_lq_spr_xucr0_mbar_ack(spr_xucr0_mbar_ack),
       .xu_lq_spr_xucr0_tlbsync(spr_xucr0_tlbsync),
       .xu_lq_spr_xucr0_dcdis(spr_xucr0_dc_dis),
       .xu_lq_spr_xucr0_aflsta(spr_xucr0_aflsta),
       .xu_lq_spr_xucr0_flsta(spr_xucr0_flsta),
       .xu_lq_spr_xucr0_clfc(spr_xucr0_clfc),
       .xu_lq_spr_xucr0_cls(spr_xucr0_cls),
       .xu_lq_spr_xucr0_trace_um(spr_xucr0_trace_um[0:`THREADS - 1]),
       .xu_lq_spr_xucr0_cred(spr_xucr0_cred),
       .xu_lq_spr_xucr0_mddp(spr_xucr0_mddp),
       .xu_lq_spr_xucr0_mdcp(spr_xucr0_mdcp),
       .xu_lq_spr_ccr2_notlb(spr_ccr2_notlb),
       .xu_lq_spr_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),
       .xu_lq_spr_xucr4_mddmh(spr_xucr4_mddmh),
       .xu_lq_spr_dbcr0_dac1(spr_dbcr0_dac1),
       .xu_lq_spr_dbcr0_dac2(spr_dbcr0_dac2),
       .xu_lq_spr_dbcr0_dac3(spr_dbcr0_dac3),
       .xu_lq_spr_dbcr0_dac4(spr_dbcr0_dac4),
       .xu_lq_spr_dbcr0_idm(spr_dbcr0_idm),
       .xu_lq_spr_epcr_duvd(xu_iu_epcr_duvd),
       .xu_lq_spr_msr_cm(spr_msr_cm),
       .xu_lq_spr_msr_fp(spr_msr_fp),
       .xu_lq_spr_msr_spv(spr_msr_spv),
       .xu_lq_spr_msr_gs(spr_msr_gs),
       .xu_lq_spr_msr_pr(spr_msr_pr),
       .xu_lq_spr_msr_ds(spr_msr_ds),
       .xu_lq_spr_msr_ucle(spr_msr_ucle),
       .xu_lq_spr_msr_de(spr_msr_de),
       .xu_lq_spr_msrp_uclep(spr_msrp_uclep),
       .iu_lq_spr_iucr0_icbi_ack(iu_lq_spr_iucr0_icbi_ack),
       .lq_xu_spr_xucr0_cul(lq_xu_spr_xucr0_cul),
       .lq_xu_spr_xucr0_cslc_xuop(lq_xu_spr_xucr0_cslc_xuop),
       .lq_xu_spr_xucr0_cslc_binv(lq_xu_spr_xucr0_cslc_binv),
       .lq_xu_spr_xucr0_clo(lq_xu_spr_xucr0_clo),
       .lq_iu_spr_dbcr3_ivc(lq_iu_spr_dbcr3_ivc),
       .slowspr_val_in(lq_slowspr_val_in),
       .slowspr_rw_in(lq_slowspr_rw_in),
       .slowspr_etid_in(lq_slowspr_etid_in),
       .slowspr_addr_in(lq_slowspr_addr_in),
       .slowspr_data_in(lq_slowspr_data_in),
       .slowspr_done_in(lq_slowspr_done_in),
       .slowspr_val_out(lq_slowspr_val_out),
       .slowspr_rw_out(lq_slowspr_rw_out),
       .slowspr_etid_out(lq_slowspr_etid_out),
       .slowspr_addr_out(lq_slowspr_addr_out),
       .slowspr_data_out(lq_slowspr_data_out),
       .slowspr_done_out(lq_slowspr_done_out),

       //--------------------------------------------------------------
       // CP Interface
       //--------------------------------------------------------------
       .iu_lq_cp_flush(cp_flush),
       .iu_lq_recirc_val(iu_lq_recirc_val),
       .iu_lq_cp_next_itag_t0(cp_t0_next_itag),
`ifndef THREADS1
       .iu_lq_cp_next_itag_t1(cp_t1_next_itag),
`endif
       .iu_lq_isync(cp_is_isync),
       .iu_lq_csync(cp_is_csync),
       .lq0_iu_execute_vld(lq0_iu_execute_vld),
       .lq0_iu_recirc_val(lq0_iu_recirc_val),
       .lq0_iu_dear_val(lq0_iu_dear_val),
       .lq0_iu_itag(lq0_iu_itag),
       .lq0_iu_flush2ucode(lq0_iu_flush2ucode),
       .lq0_iu_flush2ucode_type(lq0_iu_flush2ucode_type),
       .lq0_iu_exception_val(lq0_iu_exception_val),
       .lq0_iu_exception(lq0_iu_exception),
       .lq0_iu_n_flush(lq0_iu_n_flush),
       .lq0_iu_np1_flush(lq0_iu_np1_flush),
       .lq0_iu_dacr_type(lq0_iu_dacr_type),
       .lq0_iu_dacrw(lq0_iu_dacrw),
       .lq0_iu_instr(lq0_iu_instr),
       .lq0_iu_eff_addr(lq0_iu_eff_addr),
       .lq1_iu_execute_vld(lq1_iu_execute_vld),
       .lq1_iu_itag(lq1_iu_itag),
       .lq1_iu_exception_val(lq1_iu_exception_val),
       .lq1_iu_exception(lq1_iu_exception),
       .lq1_iu_n_flush(lq1_iu_n_flush),
       .lq1_iu_np1_flush(lq1_iu_np1_flush),
       .lq1_iu_dacr_type(lq1_iu_dacr_type),
       .lq1_iu_dacrw(lq1_iu_dacrw),
       .lq1_iu_perf_events(lq1_iu_perf_events),
       .rv_lq_rv1_i0_vld(rv_lq_rv1_i0_vld),
       .rv_lq_rv1_i0_ucode_preissue(rv_lq_rv1_i0_ucode_preissue),
       .rv_lq_rv1_i0_2ucode(rv_lq_rv1_i0_2ucode),
       .rv_lq_rv1_i0_ucode_cnt(rv_lq_rv1_i0_ucode_cnt),
       .rv_lq_rv1_i0_s3_t(rv_lq_rv1_i0_s3_t),
       .rv_lq_rv1_i0_isLoad(rv_lq_rv1_i0_isLoad),
       .rv_lq_rv1_i0_isStore(rv_lq_rv1_i0_isStore),
       .rv_lq_rv1_i0_itag(rv_lq_rv1_i0_itag),
       .rv_lq_rv1_i0_rte_lq(rv_lq_rv1_i0_rte_lq),
       .rv_lq_rv1_i0_rte_sq(rv_lq_rv1_i0_rte_sq),
       .rv_lq_rv1_i0_ifar(rv_lq_rv1_i0_ifar),
       .rv_lq_rv1_i1_vld(rv_lq_rv1_i1_vld),
       .rv_lq_rv1_i1_ucode_preissue(rv_lq_rv1_i1_ucode_preissue),
       .rv_lq_rv1_i1_2ucode(rv_lq_rv1_i1_2ucode),
       .rv_lq_rv1_i1_ucode_cnt(rv_lq_rv1_i1_ucode_cnt),
       .rv_lq_rv1_i1_s3_t(rv_lq_rv1_i1_s3_t),
       .rv_lq_rv1_i1_isLoad(rv_lq_rv1_i1_isLoad),
       .rv_lq_rv1_i1_isStore(rv_lq_rv1_i1_isStore),
       .rv_lq_rv1_i1_itag(rv_lq_rv1_i1_itag),
       .rv_lq_rv1_i1_rte_lq(rv_lq_rv1_i1_rte_lq),
       .rv_lq_rv1_i1_rte_sq(rv_lq_rv1_i1_rte_sq),
       .rv_lq_rv1_i1_ifar(rv_lq_rv1_i1_ifar),
       .lq_iu_credit_free(lq_iu_credit_free),
       .sq_iu_credit_free(sq_iu_credit_free),
       .iu_lq_i0_completed(iu_lq_i0_completed),
       .iu_lq_i1_completed(iu_lq_i1_completed),
       .iu_lq_i0_completed_itag_t0(iu_lq_t0_i0_completed_itag),
       .iu_lq_i1_completed_itag_t0(iu_lq_t0_i1_completed_itag),
`ifndef THREADS1
       .iu_lq_i0_completed_itag_t1(iu_lq_t1_i0_completed_itag),
       .iu_lq_i1_completed_itag_t1(iu_lq_t1_i1_completed_itag),
`endif
       .iu_lq_request(iu_lq_request),
       .iu_lq_cTag(iu_lq_cTag),
       .iu_lq_ra(iu_lq_ra),
       .iu_lq_wimge(iu_lq_wimge),
       .iu_lq_userdef(iu_lq_userdef),
       .lq_iu_icbi_val(lq_iu_icbi_val),
       .lq_iu_icbi_addr(lq_iu_icbi_addr),
       .iu_lq_icbi_complete(iu_lq_icbi_complete),
       .lq_iu_ici_val(lq_iu_ici_val),

       //--------------------------------------------------------------
       // Interface with XU DERAT
       //--------------------------------------------------------------
       .xu_lq_act(xu_lq_act),
       .xu_lq_val(xu_lq_val),
       .xu_lq_is_eratre(xu_lq_is_eratre),
       .xu_lq_is_eratwe(xu_lq_is_eratwe),
       .xu_lq_is_eratsx(xu_lq_is_eratsx),
       .xu_lq_is_eratilx(xu_lq_is_eratilx),
       .xu_lq_ws(xu_lq_ws),
       .xu_lq_ra_entry(xu_lq_ra_entry),
       .xu_lq_rs_data(xu_lq_rs_data),
       .xu_lq_hold_req(xu_lq_hold_req),
       .lq_xu_ex5_data(lq_xu_ex5_data),
       .lq_xu_ord_par_err(lq_xu_ord_par_err),
       .lq_xu_ord_read_done(lq_xu_ord_read_done),
       .lq_xu_ord_write_done(lq_xu_ord_write_done),

       //--------------------------------------------------------------
       // Doorbell Interface with XU
       //--------------------------------------------------------------
       .lq_xu_dbell_val(lq_xu_dbell_val),
       .lq_xu_dbell_type(lq_xu_dbell_type),
       .lq_xu_dbell_brdcast(lq_xu_dbell_brdcast),
       .lq_xu_dbell_lpid_match(lq_xu_dbell_lpid_match),
       .lq_xu_dbell_pirtag(lq_xu_dbell_pirtag),

       //--------------------------------------------------------------
       // Interface with RV
       //--------------------------------------------------------------
       .rv_lq_rvs_empty(rv_lq_rvs_empty),
       .rv_lq_vld(rv_lq_vld),
       .rv_lq_ex0_itag(rv_lq_ex0_itag),
       .rv_lq_isLoad(rv_lq_isLoad),
       .rv_lq_ex0_instr(rv_lq_ex0_instr),
       .rv_lq_ex0_ucode(rv_lq_ex0_ucode[0:1]),
       .rv_lq_ex0_ucode_cnt(rv_lq_ex0_ucode_cnt),
       .rv_lq_ex0_t1_v(rv_lq_ex0_t1_v),
       .rv_lq_ex0_t1_p(rv_lq_ex0_t1_p),
       .rv_lq_ex0_t3_p(rv_lq_ex0_t3_p),
       .rv_lq_ex0_s1_v(rv_lq_ex0_s1_v),
       .rv_lq_ex0_s2_v(rv_lq_ex0_s2_v),

       .lq_rv_itag0(lq_rv_itag0),
       .lq_rv_itag0_vld(lq_rv_itag0_vld),
       .lq_rv_itag0_abort(lq_rv_itag0_abort),
       .lq_rv_ex2_s1_abort(lq_rv_ex2_s1_abort),
       .lq_rv_ex2_s2_abort(lq_rv_ex2_s2_abort),
       .lq_rv_hold_all(lq_rv_hold_all),
       .lq_rv_itag1_vld(lq_rv_itag1_vld),
       .lq_rv_itag1(lq_rv_itag1),
       .lq_rv_itag1_restart(lq_rv_itag1_restart),
       .lq_rv_itag1_abort(lq_rv_itag1_abort),
       .lq_rv_itag1_hold(lq_rv_itag1_hold),
       .lq_rv_itag1_cord(lq_rv_itag1_cord),
       .lq_rv_itag2_vld(lq_rv_itag2_vld),
       .lq_rv_itag2(lq_rv_itag2),
       .lq_rv_clr_hold(lq_rv_clr_hold),

       //-------------------------------------------------------------------
       // Interface with Bypass Controller
       //-------------------------------------------------------------------
       .rv_lq_ex0_s1_xu0_sel(rv_lq_ex0_s1_fx0_sel),
       .rv_lq_ex0_s2_xu0_sel(rv_lq_ex0_s2_fx0_sel),
       .rv_lq_ex0_s1_xu1_sel(rv_lq_ex0_s1_fx1_sel),
       .rv_lq_ex0_s2_xu1_sel(rv_lq_ex0_s2_fx1_sel),
       .rv_lq_ex0_s1_lq_sel(rv_lq_ex0_s1_lq_sel),
       .rv_lq_ex0_s2_lq_sel(rv_lq_ex0_s2_lq_sel),
       .rv_lq_ex0_s1_rel_sel(rv_lq_ex0_s1_rel_sel),
       .rv_lq_ex0_s2_rel_sel(rv_lq_ex0_s2_rel_sel),

       //--------------------------------------------------------------
       // Interface with Regfiles
       //--------------------------------------------------------------
       .xu_lq_xer_cp_rd(xu_lq_xer_cp_rd),
       .rv_lq_gpr_ex1_r0d(rv_lq_gpr_ex1_r0d[64 - `GPR_WIDTH:63]),
       .rv_lq_gpr_ex1_r1d(rv_lq_gpr_ex1_r1d[64 - `GPR_WIDTH:63]),
       .lq_rv_gpr_ex6_we(lq_rv_gpr_ex6_we),
       .lq_rv_gpr_ex6_wa(lq_rv_gpr_ex6_wa),
       .lq_rv_gpr_ex6_wd(lq_rv_gpr_ex6_wd),
       .lq_xu_gpr_ex5_we(lq_xu_gpr_ex5_we),
       .lq_xu_gpr_ex5_wa(lq_xu_gpr_ex5_wa),
       .lq_rv_gpr_rel_we(lq_rv_gpr_rel_we),
       .lq_rv_gpr_rel_wa(lq_rv_gpr_rel_wa),
       .lq_rv_gpr_rel_wd(lq_rv_gpr_rel_wd),
       .lq_xu_gpr_rel_we(lq_xu_gpr_rel_we),
       .lq_xu_gpr_rel_wa(lq_xu_gpr_rel_wa),
       .lq_xu_gpr_rel_wd(lq_xu_gpr_rel_wd),
       .lq_xu_axu_rel_we(lq_xu_axu_rel_we),
       .lq_xu_axu_rel_le(lq_xu_axu_rel_le),
       .lq_xu_cr_l2_we(lq_xu_cr_l2_we),
       .lq_xu_cr_l2_wa(lq_xu_cr_l2_wa),
       .lq_xu_cr_l2_wd(lq_xu_cr_l2_wd),
       .lq_xu_cr_ex5_we(lq_xu_cr_ex5_we),
       .lq_xu_cr_ex5_wa(lq_xu_cr_ex5_wa),

       //-------------------------------------------------------------------
       // Interface with FXU0
       //-------------------------------------------------------------------
       .xu0_lq_ex3_act(xu0_lq_ex3_act),
       .xu0_lq_ex3_abort(xu0_lq_ex3_abort),
       .xu0_lq_ex3_rt(xu0_lq_ex3_rt),
       .xu0_lq_ex4_rt(xu0_lq_ex4_rt),
       .xu0_lq_ex6_rt(xu0_lq_ex6_rt),
       .xu0_lq_ex6_act(xu0_lq_ex6_act),
       .lq_xu_ex5_act(lq_xu_ex5_act),
       .lq_xu_ex5_cr(lq_xu_ex5_cr),
       .lq_xu_ex5_rt(lq_xu_ex5_rt),
       .lq_xu_ex5_abort(lq_xu_ex5_abort),

       //-------------------------------------------------------------------
       // Interface with FXU1
       //-------------------------------------------------------------------
       .xu1_lq_ex3_act(xu1_lq_ex3_act),
       .xu1_lq_ex3_abort(xu1_lq_ex3_abort),
       .xu1_lq_ex3_rt(xu1_lq_ex3_rt),
       .xu1_lq_ex2_stq_val(xu1_lq_ex2_stq_val),
       .xu1_lq_ex2_stq_itag(xu1_lq_ex2_stq_itag),
       .xu1_lq_ex2_stq_size(xu1_lq_ex2_stq_size),
       .xu1_lq_ex2_stq_dvc1_cmp(xu1_lq_ex2_stq_dvc1_cmp),
       .xu1_lq_ex2_stq_dvc2_cmp(xu1_lq_ex2_stq_dvc2_cmp),
       .xu1_lq_ex3_illeg_lswx(xu1_lq_ex3_illeg_lswx),
       .xu1_lq_ex3_strg_noop(xu1_lq_ex3_strg_noop),

       //--------------------------------------------------------------
       // Interface with FU
       //--------------------------------------------------------------
       .xu_lq_axu_ex_stq_val(xu_lq_axu_ex_stq_val),
       .xu_lq_axu_ex_stq_itag(xu_lq_axu_ex_stq_itag),
       .xu_lq_axu_exp1_stq_data(xu_lq_axu_exp1_stq_data),
       .lq_xu_axu_ex4_addr(lq_xu_axu_ex4_addr),
       .lq_xu_axu_ex5_we(lq_xu_axu_ex5_we),
       .lq_xu_axu_ex5_le(lq_xu_axu_ex5_le),

       //--------------------------------------------------------------
       // Interface with MMU
       //--------------------------------------------------------------
       .mm_lq_lsu_req(mm_lq_lsu_req),
       .mm_lq_lsu_ttype(mm_lq_lsu_ttype),
       .mm_lq_lsu_wimge(mm_lq_lsu_wimge),
       .mm_lq_lsu_u(mm_lq_lsu_u),
       .mm_lq_lsu_addr(mm_lq_lsu_addr),
       .mm_lq_lsu_lpid(mm_lq_lsu_lpid),
       .mm_lq_lsu_gs(mm_lq_lsu_gs),
       .mm_lq_lsu_ind(mm_lq_lsu_ind),
       .mm_lq_lsu_lbit(mm_lq_lsu_lbit),
       .mm_lq_lsu_lpidr(mm_lq_lsu_lpidr),
       .lq_mm_lsu_token(lq_mm_lsu_token),
       .mm_lq_hold_req(mm_iu_hold_req[0]),
       .mm_lq_hold_done(mm_iu_hold_done[0]),
       .mm_lq_pid_t0(mm_lq_t0_derat_pid),
       .mm_lq_mmucr0_t0(mm_lq_t0_derat_mmucr0),
`ifndef THREADS1
       .mm_lq_pid_t1(mm_lq_t1_derat_pid),
       .mm_lq_mmucr0_t1(mm_lq_t1_derat_mmucr0),
`endif
       .mm_lq_mmucr1(mm_lq_derat_mmucr1),
       .mm_lq_rel_val(mm_lq_derat_rel_val),
       .mm_lq_rel_data(mm_lq_derat_rel_data),
       .mm_lq_rel_emq(mm_lq_derat_rel_emq),
       .mm_lq_itag(mm_lq_derat_rel_itag),
       .mm_lq_tlb_miss(mm_xu_tlb_miss),
       .mm_lq_tlb_inelig(mm_xu_tlb_inelig),
       .mm_lq_pt_fault(mm_xu_pt_fault),
       .mm_lq_lrat_miss(mm_xu_lrat_miss),
       .mm_lq_tlb_multihit(mm_tlb_multihit_err),
       .mm_lq_tlb_par_err(mm_tlb_par_err),
       .mm_lq_lru_par_err(mm_lru_par_err),
       .mm_lq_snoop_coming(mm_lq_derat_snoop_coming),
       .mm_lq_snoop_val(mm_lq_derat_snoop_val),
       .mm_lq_snoop_attr(mm_lq_derat_snoop_attr),
       .mm_lq_snoop_vpn(mm_lq_derat_snoop_vpn),
       .lq_mm_snoop_ack(lq_mm_derat_snoop_ack),
       .lq_mm_req(lq_mm_derat_req),
       .lq_mm_req_nonspec(lq_mm_derat_req_nonspec),
       .lq_mm_req_itag(lq_mm_derat_req_itag),
       .lq_mm_req_epn(lq_mm_derat_epn),
       .lq_mm_thdid(lq_mm_derat_thdid),
       .lq_mm_req_emq(lq_mm_derat_req_emq),
       .lq_mm_ttype(lq_mm_derat_ttype),
       .lq_mm_state(lq_mm_derat_state),
       .lq_mm_lpid(lq_mm_derat_lpid),
       .lq_mm_tid(lq_mm_derat_tid),
       .lq_mm_mmucr0_we(lq_mm_derat_mmucr0_we),
       .lq_mm_mmucr0(lq_mm_derat_mmucr0),
       .lq_mm_mmucr1_we(lq_mm_derat_mmucr1_we),
       .lq_mm_mmucr1(lq_mm_derat_mmucr1),
       .lq_mm_lmq_stq_empty(lq_mm_lmq_stq_empty),
       .lq_mm_perf_dtlb(lq_mm_perf_dtlb),
       .lq_xu_quiesce(lq_xu_quiesce),
       .lq_pc_ldq_quiesce(lq_pc_ldq_quiesce),
       .lq_pc_stq_quiesce(lq_pc_stq_quiesce),
       .lq_pc_pfetch_quiesce(lq_pc_pfetch_quiesce),

       //--------------------------------------------------------------
       // Interface with PC
       //--------------------------------------------------------------
       .pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
       .pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
       .pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),
       .pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),
       .pc_lq_inj_dcache_parity(pc_lq_inj_dcache_parity),
       .pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),
       .lq_pc_err_derat_parity(lq_pc_err_derat_parity),
       .lq_pc_err_dir_ldp_parity(lq_pc_err_dcachedir_ldp_parity),
       .lq_pc_err_dir_stp_parity(lq_pc_err_dcachedir_stp_parity),
       .lq_pc_err_relq_parity(lq_pc_err_relq_parity),
       .lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
       .lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
       .lq_pc_err_dir_ldp_multihit(lq_pc_err_dcachedir_ldp_multihit),
       .lq_pc_err_dir_stp_multihit(lq_pc_err_dcachedir_stp_multihit),
       .lq_pc_err_invld_reld(lq_pc_err_invld_reld),
       .lq_pc_err_l2intrf_ecc(lq_pc_err_l2intrf_ecc),
       .lq_pc_err_l2intrf_ue(lq_pc_err_l2intrf_ue),
       .lq_pc_err_l2credit_overrun(lq_pc_err_l2credit_overrun),
       .pc_lq_ram_active(pc_lq_ram_active),
       .lq_pc_ram_data_val(lq_pc_ram_data_val),
       .lq_pc_ram_data(lq_pc_ram_data),
       .pc_lq_inj_prefetcher_parity(pc_lq_inj_prefetcher_parity),
       .lq_pc_err_prefetcher_parity(lq_pc_err_prefetcher_parity),

        //--------------------------------------------------------------
        // Debug Bus Control
        //--------------------------------------------------------------
        // Pervasive Debug Control
        .pc_lq_trace_bus_enable(pc_lq_trace_bus_enable),
        .pc_lq_debug_mux1_ctrls(pc_lq_debug_mux1_ctrls),
        .pc_lq_debug_mux2_ctrls(pc_lq_debug_mux2_ctrls),
        .pc_lq_instr_trace_mode(pc_lq_instr_trace_mode),
        .pc_lq_instr_trace_tid(pc_lq_instr_trace_tid),

        // Pass Thru Debug Trace Bus
        .debug_bus_in(lq_debug_bus_in),
        .coretrace_ctrls_in(lq_coretrace_ctrls_in),

        .debug_bus_out(lq_debug_bus_out),
        .coretrace_ctrls_out(lq_coretrace_ctrls_out),

        //--------------------------------------------------------------
        // Performance Event Control
        //--------------------------------------------------------------
        .pc_lq_event_bus_enable(pc_lq_event_bus_enable),
        .pc_lq_event_count_mode(pc_lq_event_count_mode),
        .event_bus_in(lq_event_bus_in),
        .event_bus_out(lq_event_bus_out),

       //--------------------------------------------------------------
       // Interface with L2
       //--------------------------------------------------------------
       .an_ac_coreid(an_ac_coreid[6:7]),
       .an_ac_sync_ack(an_ac_sync_ack),
       .an_ac_stcx_complete(an_ac_stcx_complete),
       .an_ac_stcx_pass(an_ac_stcx_pass),
       .an_ac_icbi_ack(an_ac_icbi_ack),
       .an_ac_icbi_ack_thread(an_ac_icbi_ack_thread),
       .an_ac_back_inv(an_ac_back_inv),
       .an_ac_back_inv_addr(an_ac_back_inv_addr),
       .an_ac_back_inv_target_bit1(an_ac_back_inv_target[1]),
       .an_ac_back_inv_target_bit3(an_ac_back_inv_target[3]),
       .an_ac_back_inv_target_bit4(an_ac_back_inv_target[4]),
       .an_ac_flh2l2_gate(an_ac_flh2l2_gate),
       .an_ac_req_ld_pop(an_ac_req_ld_pop),
       .an_ac_req_st_pop(an_ac_req_st_pop),
       .an_ac_req_st_gather(an_ac_req_st_gather),
       .an_ac_reld_data_vld(an_ac_reld_data_vld),
       .an_ac_reld_core_tag(an_ac_reld_core_tag),
       .an_ac_reld_data(an_ac_reld_data),
       .an_ac_reld_qw(an_ac_reld_qw),
       .an_ac_reld_ecc_err(an_ac_reld_ecc_err),
       .an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
       .an_ac_reld_data_coming(an_ac_reld_data_coming),
       .an_ac_reld_ditc(an_ac_reld_ditc),
       .an_ac_reld_crit_qw(an_ac_reld_crit_qw),
       .an_ac_reld_l1_dump(an_ac_reld_l1_dump),
       .an_ac_req_spare_ctrl_a1(an_ac_req_spare_ctrl_a1),
       .ac_an_req_pwr_token(ac_an_req_pwr_token),
       .ac_an_req(ac_an_req),
       .ac_an_req_ra(ac_an_req_ra),
       .ac_an_req_ttype(ac_an_req_ttype),
       .ac_an_req_thread(ac_an_req_thread),
       .ac_an_req_wimg_w(ac_an_req_wimg_w),
       .ac_an_req_wimg_i(ac_an_req_wimg_i),
       .ac_an_req_wimg_m(ac_an_req_wimg_m),
       .ac_an_req_wimg_g(ac_an_req_wimg_g),
       .ac_an_req_user_defined(ac_an_req_user_defined),
       .ac_an_req_spare_ctrl_a0(ac_an_req_spare_ctrl_a0),
       .ac_an_req_ld_core_tag(ac_an_req_ld_core_tag),
       .ac_an_req_ld_xfr_len(ac_an_req_ld_xfr_len),
       .ac_an_st_byte_enbl(ac_an_st_byte_enbl),
       .ac_an_st_data(ac_an_st_data),
       .ac_an_req_endian(ac_an_req_endian),
       .ac_an_st_data_pwr_token(ac_an_st_data_pwr_token),

       // Pervasive
       //.vcs(vcs),
       //.vdd(vdd),
       //.gnd(gnd),
       .nclk(nclk),

       //--Thold inputs
       .pc_lq_init_reset(pc_lq_init_reset),
       .pc_lq_ccflush_dc(rp_lq_ccflush_dc),
       .pc_lq_gptr_sl_thold_3(rp_lq_gptr_sl_thold_3),
       .pc_lq_time_sl_thold_3(rp_lq_time_sl_thold_3),
       .pc_lq_repr_sl_thold_3(rp_lq_repr_sl_thold_3),
       .pc_lq_bolt_sl_thold_3(1'b0),
       .pc_lq_abst_sl_thold_3(rp_lq_abst_sl_thold_3),
       .pc_lq_abst_slp_sl_thold_3(rp_lq_abst_slp_sl_thold_3),
       .pc_lq_func_sl_thold_3(rp_lq_func_sl_thold_3),
       .pc_lq_func_slp_sl_thold_3(rp_lq_func_slp_sl_thold_3),
       .pc_lq_cfg_sl_thold_3(rp_lq_cfg_sl_thold_3),
       .pc_lq_cfg_slp_sl_thold_3(rp_lq_cfg_slp_sl_thold_3),
       .pc_lq_regf_slp_sl_thold_3(rp_lq_regf_slp_sl_thold_3),
       .pc_lq_func_nsl_thold_3(rp_lq_func_nsl_thold_3),
       .pc_lq_func_slp_nsl_thold_3(rp_lq_func_slp_nsl_thold_3),
       .pc_lq_ary_nsl_thold_3(rp_lq_ary_nsl_thold_3),
       .pc_lq_ary_slp_nsl_thold_3(rp_lq_ary_slp_nsl_thold_3),
       .pc_lq_sg_3(rp_lq_sg_3),
       .pc_lq_fce_3(rp_lq_fce_3),

       // G8T ABIST Control
       .pc_lq_abist_wl64_comp_ena(1'b0),
       .pc_lq_abist_g8t_wenb(1'b0),
       .pc_lq_abist_g8t1p_renb_0(1'b0),
       .pc_lq_abist_g8t_dcomp({4{1'b0}}),
       .pc_lq_abist_g8t_bw_1(1'b0),
       .pc_lq_abist_g8t_bw_0(1'b0),
       .pc_lq_abist_di_0({4{1'b0}}),
       .pc_lq_abist_waddr_0({8{1'b0}}),

       // G6T ABIST Control
       .pc_lq_abist_ena_dc(1'b0),
       .pc_lq_abist_raw_dc_b(1'b0),
       .pc_lq_abist_g6t_bw({2{1'b0}}),
       .pc_lq_abist_di_g6t_2r({4{1'b0}}),
       .pc_lq_abist_wl256_comp_ena(1'b0),
       .pc_lq_abist_dcomp_g6t_2r({4{1'b0}}),
       .pc_lq_abist_raddr_0({8{1'b0}}),
       .pc_lq_abist_g6t_r_wb(1'b0),

       .pc_lq_bo_enable_3(1'b0),
       .pc_lq_bo_unload(1'b0),
       .pc_lq_bo_repair(1'b0),
       .pc_lq_bo_reset(1'b0),
       .pc_lq_bo_shdata(1'b0),
       .pc_lq_bo_select({14{1'b0}}),
       .lq_pc_bo_fail(),
       .lq_pc_bo_diagout(),

       // Core Level Signals
       .an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
       .an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
       .an_ac_scan_diag_dc(an_ac_scan_diag_dc),
       .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
       .an_ac_atpg_en_dc(1'b0),
       .an_ac_grffence_en_dc(1'b0),


       // SCAN
       .gptr_scan_in(1'b0),
       .gptr_scan_out(),
       .abst_scan_in({6{1'b0}}),
       .abst_scan_out(),
       .time_scan_in(1'b0),
       .time_scan_out(),
       .repr_scan_in(1'b0),
       .repr_scan_out(),
       .regf_scan_in({7{1'b0}}),
       .regf_scan_out(),
       .ccfg_scan_in(1'b0),
       .ccfg_scan_out(),
       .func_scan_in(scan_in_lq),
       .func_scan_out(scan_out_lq)
       );

   // 6=64-bit model, 5=32-bit model
   mmq
   mmu0(
//			.vcs(vcs),
//			.vdd(vdd),
//			.gnd(gnd),
			.nclk(nclk),

			.tc_ac_ccflush_dc(rp_mm_ccflush_dc),
			.tc_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
			.tc_ac_scan_diag_dc(an_ac_scan_diag_dc),
			.tc_ac_lbist_en_dc(1'b0),
			.pc_mm_gptr_sl_thold_3(rp_mm_gptr_sl_thold_3),
			.pc_mm_time_sl_thold_3(rp_mm_time_sl_thold_3),
			.pc_mm_repr_sl_thold_3(rp_mm_repr_sl_thold_3),
			.pc_mm_abst_sl_thold_3(rp_mm_abst_sl_thold_3),
			.pc_mm_abst_slp_sl_thold_3(rp_mm_abst_slp_sl_thold_3),
			.pc_mm_func_sl_thold_3(TEMP_rp_mm_func_sl_thold_3),
			.pc_mm_func_slp_sl_thold_3(TEMP_rp_mm_func_slp_sl_thold_3),
			.pc_mm_cfg_sl_thold_3(rp_mm_cfg_sl_thold_3),
			.pc_mm_cfg_slp_sl_thold_3(rp_mm_cfg_slp_sl_thold_3),
			.pc_mm_func_nsl_thold_3(rp_mm_func_nsl_thold_3),
			.pc_mm_func_slp_nsl_thold_3(rp_mm_func_slp_nsl_thold_3),
			.pc_mm_ary_nsl_thold_3(rp_mm_ary_nsl_thold_3),
			.pc_mm_ary_slp_nsl_thold_3(rp_mm_ary_slp_nsl_thold_3),
			.pc_mm_sg_3(TEMP_rp_mm_sg_3),
			.pc_mm_fce_3(rp_mm_fce_3),
			.debug_bus_in(mm_debug_bus_in),
			.debug_bus_out(mm_debug_bus_out),
                        .coretrace_ctrls_in(mm_coretrace_ctrls_in),
                        .coretrace_ctrls_out(mm_coretrace_ctrls_out),

			.pc_mm_debug_mux1_ctrls(pc_mm_debug_mux_ctrls),
			.pc_mm_trace_bus_enable(pc_mm_trace_bus_enable),
			.pc_mm_event_count_mode(pc_mm_event_count_mode),
			.rp_mm_event_bus_enable_q(pc_mm_event_bus_enable),
			.mm_event_bus_in(mm_event_bus_in),
			.mm_event_bus_out(mm_event_bus_out),
			.an_ac_lbist_ary_wrt_thru_dc(an_ac_lbist_ary_wrt_thru_dc),
			.pc_mm_abist_dcomp_g6t_2r({4{1'b0}}),
			.pc_mm_abist_di_0({4{1'b0}}),
			.pc_mm_abist_di_g6t_2r({4{1'b0}}),
			.pc_mm_abist_ena_dc(1'b0),
			.pc_mm_abist_g6t_r_wb(1'b0),
			.pc_mm_abist_g8t1p_renb_0(1'b0),
			.pc_mm_abist_g8t_bw_0(1'b0),
			.pc_mm_abist_g8t_bw_1(1'b0),
			.pc_mm_abist_g8t_dcomp({4{1'b0}}),
			.pc_mm_abist_g8t_wenb(1'b0),
			.pc_mm_abist_raddr_0({10{1'b0}}),
			.pc_mm_abist_raw_dc_b(1'b0),
			.pc_mm_abist_waddr_0({10{1'b0}}),
			.pc_mm_abist_wl128_comp_ena(1'b0),
			.pc_mm_bolt_sl_thold_3(1'b0),
			.pc_mm_bo_enable_3(1'b0),
			.pc_mm_bo_reset(1'b0),
			.pc_mm_bo_unload(1'b0),
			.pc_mm_bo_repair(1'b0),
			.pc_mm_bo_shdata(1'b0),
			.pc_mm_bo_select({5{1'b0}}),
			.mm_pc_bo_fail(),
			.mm_pc_bo_diagout(),
			.iu_mm_ierat_req(iu_mm_ierat_req),
			.iu_mm_ierat_req_nonspec(iu_mm_ierat_req_nonspec),
			.iu_mm_ierat_epn(iu_mm_ierat_epn),
			.iu_mm_ierat_thdid(iu_mm_ierat_thdid),
			.iu_mm_ierat_state(iu_mm_ierat_state),
			.iu_mm_ierat_tid(iu_mm_ierat_tid),
			.iu_mm_ierat_flush({`THREADS{1'b0}}),
			.mm_iu_ierat_snoop_coming(mm_iu_ierat_snoop_coming),
			.mm_iu_ierat_rel_val(mm_iu_ierat_rel_val),
			.mm_iu_ierat_rel_data(mm_iu_ierat_rel_data),
			.mm_iu_ierat_snoop_val(mm_iu_ierat_snoop_val),
			.mm_iu_ierat_snoop_attr(mm_iu_ierat_snoop_attr),
			.mm_iu_ierat_snoop_vpn(mm_iu_ierat_snoop_vpn),
			.iu_mm_ierat_snoop_ack(iu_mm_ierat_snoop_ack),
			.mm_iu_t0_ierat_pid(mm_iu_t0_ierat_pid),
			.mm_iu_t0_ierat_mmucr0(mm_iu_t0_ierat_mmucr0),
`ifndef THREADS1
			.mm_iu_t1_ierat_pid(mm_iu_t1_ierat_pid),
			.mm_iu_t1_ierat_mmucr0(mm_iu_t1_ierat_mmucr0),
`endif
			.iu_mm_ierat_mmucr0(iu_mm_ierat_mmucr0),
			.iu_mm_ierat_mmucr0_we(iu_mm_ierat_mmucr0_we),
			.mm_iu_ierat_mmucr1(mm_iu_ierat_mmucr1),
			.mm_iu_tlbwe_binv(mm_iu_tlbwe_binv),
			.iu_mm_ierat_mmucr1(iu_mm_ierat_mmucr1),
			.iu_mm_ierat_mmucr1_we(iu_mm_ierat_mmucr1_we),
			.xu_mm_derat_req(lq_mm_derat_req),
			.xu_mm_derat_epn(lq_mm_derat_epn),
			.xu_mm_derat_thdid(lq_mm_derat_thdid),
			.xu_mm_derat_ttype(lq_mm_derat_ttype),
			.xu_mm_derat_state(lq_mm_derat_state),
			.xu_mm_derat_lpid(lq_mm_derat_lpid),
			.xu_mm_derat_tid(lq_mm_derat_tid),
			.lq_mm_derat_req_nonspec(lq_mm_derat_req_nonspec),
			.lq_mm_derat_req_itag(lq_mm_derat_req_itag),
			.lq_mm_derat_req_emq(lq_mm_derat_req_emq),
			.mm_xu_derat_rel_val(mm_lq_derat_rel_val),
			.mm_xu_derat_rel_data(mm_lq_derat_rel_data),
			.mm_xu_derat_rel_itag(mm_lq_derat_rel_itag),
			.mm_xu_derat_rel_emq(mm_lq_derat_rel_emq),
			.mm_xu_derat_snoop_coming(mm_lq_derat_snoop_coming),
			.mm_xu_derat_snoop_val(mm_lq_derat_snoop_val),
			.mm_xu_derat_snoop_attr(mm_lq_derat_snoop_attr),
			.mm_xu_derat_snoop_vpn(mm_lq_derat_snoop_vpn),
			.xu_mm_derat_snoop_ack(lq_mm_derat_snoop_ack),
			.mm_xu_t0_derat_pid(mm_lq_t0_derat_pid),
			.mm_xu_t0_derat_mmucr0(mm_lq_t0_derat_mmucr0),
`ifndef THREADS1
			.mm_xu_t1_derat_pid(mm_lq_t1_derat_pid),
			.mm_xu_t1_derat_mmucr0(mm_lq_t1_derat_mmucr0),
`endif
			.xu_mm_derat_mmucr0(lq_mm_derat_mmucr0),
			.xu_mm_derat_mmucr0_we(lq_mm_derat_mmucr0_we),
			.mm_xu_derat_mmucr1(mm_lq_derat_mmucr1),
			.xu_mm_derat_mmucr1(lq_mm_derat_mmucr1),
			.xu_mm_derat_mmucr1_we(lq_mm_derat_mmucr1_we),
			.xu_mm_rf1_val(xu_mm_val),
			.xu_mm_rf1_is_tlbre(xu_mm_is_tlbre),
			.xu_mm_rf1_is_tlbwe(xu_mm_is_tlbwe),
			.xu_mm_rf1_is_tlbsx(xu_mm_is_tlbsx),
			.xu_mm_rf1_is_tlbsxr(xu_mm_is_tlbsxr),
			.xu_mm_rf1_is_tlbsrx(xu_mm_is_tlbsrx),
			.xu_mm_rf1_is_tlbivax(xu_mm_is_tlbivax),
			.xu_mm_rf1_is_tlbilx(xu_mm_is_tlbilx),
			.xu_mm_rf1_is_erativax(xu_iu_is_erativax),
			.xu_mm_rf1_is_eratilx(xu_iu_is_eratilx),
			.xu_mm_ex1_is_isync(cp_is_isync),
			.xu_mm_ex1_is_csync(cp_is_csync),
			.xu_mm_rf1_t(xu_iu_t),
			.xu_mm_ex1_rs_is(xu_iu_rs_is),
			.xu_mm_ex2_eff_addr(xu_mm_rb),
			.xu_mm_msr_gs(spr_msr_gs),
			.xu_mm_msr_pr(spr_msr_pr),
			.xu_mm_msr_is(spr_msr_is),
			.xu_mm_msr_ds(spr_msr_ds),
			.xu_mm_msr_cm(spr_msr_cm),
			.xu_mm_spr_epcr_dmiuh(xu_mm_spr_epcr_dmiuh),
			.xu_mm_spr_epcr_dgtmi(spr_epcr_dgtmi),
			.xu_mm_hid_mmu_mode(spr_ccr2_notlb),
			.xu_mm_xucr4_mmu_mchk(spr_xucr4_mmu_mchk),
			.xu_mm_lmq_stq_empty(lq_mm_lmq_stq_empty),
			.iu_mm_lmq_empty(iu_mm_lmq_empty),

			.xu_rf1_flush(cp_flush),
			.xu_ex1_flush(cp_flush),
			.xu_ex2_flush(cp_flush),
			.xu_ex3_flush(cp_flush),
			.xu_ex4_flush(cp_flush),
			.xu_ex5_flush(cp_flush),
			.xu_mm_ex4_flush(cp_flush),
			.xu_mm_ex5_flush(cp_flush),

			.xu_mm_ierat_miss({`THREADS{1'b1}}),
			.xu_mm_ierat_flush({`THREADS{1'b0}}),
			.iu_mm_perf_itlb(iu_mm_perf_itlb),
			.lq_mm_perf_dtlb(lq_mm_perf_dtlb),
			.mm_xu_eratmiss_done(),
			.mm_xu_cr0_eq(mm_xu_cr0_eq),
			.mm_xu_cr0_eq_valid(mm_xu_cr0_eq_valid),
			.mm_xu_tlb_miss(mm_xu_tlb_miss),
			.mm_xu_lrat_miss(mm_xu_lrat_miss),
			.mm_xu_tlb_inelig(mm_xu_tlb_inelig),
			.mm_xu_pt_fault(mm_xu_pt_fault),
			.mm_xu_hv_priv(mm_xu_hv_priv),
			.mm_xu_illeg_instr(mm_xu_illeg_instr),

			.mm_xu_tlb_miss_ored(mm_xu_tlb_miss_ored),
			.mm_xu_lrat_miss_ored(mm_xu_lrat_miss_ored),
			.mm_xu_tlb_inelig_ored(mm_xu_tlb_inelig_ored),
			.mm_xu_pt_fault_ored(mm_xu_pt_fault_ored),
			.mm_xu_hv_priv_ored(mm_xu_hv_priv_ored),
			.mm_xu_cr0_eq_ored(mm_xu_cr0_eq_ored),
			.mm_xu_cr0_eq_valid_ored(mm_xu_cr0_eq_valid_ored),

			.mm_xu_esr_pt(),
			.mm_xu_esr_data(),
			.mm_xu_esr_epid(),
			.mm_xu_esr_st(),
			.mm_xu_quiesce(mm_xu_quiesce),
                        .mm_pc_tlb_req_quiesce(mm_pc_tlb_req_quiesce),
                        .mm_pc_tlb_ctl_quiesce(mm_pc_tlb_ctl_quiesce),
                        .mm_pc_htw_quiesce(mm_pc_htw_quiesce),
                        .mm_pc_inval_quiesce(mm_pc_inval_quiesce),

                        .cp_mm_except_taken_t0(cp_mm_except_taken_t0),
                    `ifndef THREADS1
                        .cp_mm_except_taken_t1(cp_mm_except_taken_t1),
                    `endif

			.mm_xu_tlb_multihit_err(mm_tlb_multihit_err),
			.mm_xu_tlb_par_err(mm_tlb_par_err),
			.mm_xu_lru_par_err(mm_lru_par_err),
			.mm_xu_ord_tlb_multihit(mm_xu_ord_tlb_multihit),
			.mm_xu_ord_tlb_par_err(mm_xu_ord_tlb_par_err),
			.mm_xu_ord_lru_par_err(mm_xu_ord_lru_par_err),
			.mm_xu_local_snoop_reject(mm_iu_local_snoop_reject),

			.mm_pc_tlb_multihit_err_ored(mm_pc_tlb_multihit_err_ored),
			.mm_pc_tlb_par_err_ored(mm_pc_tlb_par_err_ored),
			.mm_pc_lru_par_err_ored(mm_pc_lru_par_err_ored),
			.mm_pc_local_snoop_reject_ored(mm_pc_local_snoop_reject_ored),

			.mm_xu_ex3_flush_req(),
			.mm_xu_lsu_req(mm_lq_lsu_req),
			.mm_xu_lsu_ttype(mm_lq_lsu_ttype),
			.mm_xu_lsu_wimge(mm_lq_lsu_wimge),
			.mm_xu_lsu_u(mm_lq_lsu_u),
			.mm_xu_lsu_addr(mm_lq_lsu_addr),
			.mm_xu_lsu_lpid(mm_lq_lsu_lpid),
			.mm_xu_lsu_lpidr(mm_lq_lsu_lpidr),
			.mm_xu_lsu_gs(mm_lq_lsu_gs),
			.mm_xu_lsu_ind(mm_lq_lsu_ind),
			.mm_xu_lsu_lbit(mm_lq_lsu_lbit),
			.xu_mm_lsu_token(lq_mm_lsu_token),
			.slowspr_val_in(mm_slowspr_val_in),
			.slowspr_rw_in(mm_slowspr_rw_in),
			.slowspr_etid_in(mm_slowspr_etid_in),
			.slowspr_addr_in(mm_slowspr_addr_in),
			.slowspr_data_in(mm_slowspr_data_in),
			.slowspr_done_in(mm_slowspr_done_in),
			.slowspr_val_out(mm_slowspr_val_out),
			.slowspr_rw_out(mm_slowspr_rw_out),
			.slowspr_etid_out(mm_slowspr_etid_out),
			.slowspr_addr_out(mm_slowspr_addr_out),
			.slowspr_data_out(mm_slowspr_data_out),
			.slowspr_done_out(mm_slowspr_done_out),

			.gptr_scan_in(1'b0),
			.time_scan_in(1'b0),
			.repr_scan_in(1'b0),
			.abst_scan_in({2{1'b0}}),
			.func_scan_in({10{1'b0}}),
			.bcfg_scan_in(1'b0),
			.ccfg_scan_in(1'b0),
			.dcfg_scan_in(1'b0),
			.gptr_scan_out(),
			.time_scan_out(),
			.repr_scan_out(),
			.abst_scan_out(),
			.func_scan_out(),
			.bcfg_scan_out(),
			.ccfg_scan_out(),
			.dcfg_scan_out(),

			.ac_an_power_managed_imm(ac_an_power_managed_int),
			.an_ac_back_inv(an_ac_back_inv),
			.an_ac_back_inv_target(an_ac_back_inv_target[2]),
			.an_ac_back_inv_local(an_ac_back_inv_local),
			.an_ac_back_inv_lbit(an_ac_back_inv_lbit),
			.an_ac_back_inv_gs(an_ac_back_inv_gs),
			.an_ac_back_inv_ind(an_ac_back_inv_ind),
			.an_ac_back_inv_addr(an_ac_back_inv_addr),
			.an_ac_back_inv_lpar_id(an_ac_back_inv_lpar_id),
			.ac_an_back_inv_reject(ac_an_back_inv_reject),
			.ac_an_lpar_id(ac_an_lpar_id),
			.an_ac_reld_core_tag(an_ac_reld_core_tag),
			.an_ac_reld_data(an_ac_reld_data),
			.an_ac_reld_data_vld(an_ac_reld_data_vld),
			.an_ac_reld_ecc_err(an_ac_reld_ecc_err),
			.an_ac_reld_ecc_err_ue(an_ac_reld_ecc_err_ue),
			.an_ac_reld_qw(an_ac_reld_qw),
			.an_ac_reld_ditc(an_ac_reld_ditc),
			.an_ac_reld_crit_qw(an_ac_reld_crit_qw),

			// some new a2o mmu sigs
			.xu_mm_rf1_itag(xu_mm_itag),
			.mm_xu_ord_n_flush_req(mm_xu_ord_n_flush_req),
			.mm_xu_ord_np1_flush_req(mm_xu_ord_np1_flush_req),
			.mm_xu_ord_read_done(mm_xu_ord_read_done),
			.mm_xu_ord_write_done(mm_xu_ord_write_done),
			.iu_mm_hold_ack(iu_mm_hold_ack),
			.mm_iu_hold_req(mm_iu_hold_req),
			.mm_iu_hold_done(mm_iu_hold_done),
			.mm_iu_flush_req(mm_iu_flush_req),
			.iu_mm_bus_snoop_hold_ack(iu_mm_bus_snoop_hold_ack),
			.mm_iu_bus_snoop_hold_req(mm_iu_bus_snoop_hold_req),
			.mm_iu_bus_snoop_hold_done(mm_iu_bus_snoop_hold_done),
			.mm_iu_tlbi_complete(mm_iu_tlbi_complete),
			.mm_xu_illeg_instr_ored(mm_xu_illeg_instr_ored),
			.mm_xu_ord_n_flush_req_ored(mm_xu_ord_n_flush_req_ored),
			.mm_xu_ord_np1_flush_req_ored(mm_xu_ord_np1_flush_req_ored),		// out std_ulogic_vector(0 to thdid_width-1);
			.mm_xu_ord_read_done_ored(mm_xu_ord_read_done_ored),
			.mm_xu_ord_write_done_ored(mm_xu_ord_write_done_ored),

			.mm_xu_itag(mm_xu_itag)

			);


   c_fu_pc  #(.float_type(float_type))
     fupc(
		// .vdd(vdd),
		// .gnd(gnd),
		.nclk(nclk),

		.fu_debug_bus_in(fu_debug_bus_in),
 		.fu_debug_bus_out(fu_debug_bus_out),
      		.fu_coretrace_ctrls_in(fu_coretrace_ctrls_in),
      		.fu_coretrace_ctrls_out(fu_coretrace_ctrls_out),
   	        .fu_event_bus_in(fu_event_bus_in),
   	        .fu_event_bus_out(fu_event_bus_out),

		.pc_debug_bus_in(pc_debug_bus_in),
 		.pc_debug_bus_out(pc_debug_bus_out),
      		.pc_coretrace_ctrls_in(pc_coretrace_ctrls_in),
      		.pc_coretrace_ctrls_out(pc_coretrace_ctrls_out),

		.fu_gptr_scan_in(1'b0),
		.fu_time_scan_in(1'b0),
		.fu_repr_scan_in(1'b0),
		.fu_bcfg_scan_in(1'b0),
		.fu_ccfg_scan_in(1'b0),
		.fu_dcfg_scan_in(1'b0),
		.fu_func_scan_in({4{1'b0}}),
		.fu_abst_scan_in(1'b0),
		.fu_gptr_scan_out(),
		.fu_time_scan_out(),
		.fu_repr_scan_out(),
		.fu_bcfg_scan_out(),
		.fu_ccfg_scan_out(),
		.fu_dcfg_scan_out(),
		.fu_func_scan_out(),
		.fu_abst_scan_out(),

		.pc_gptr_scan_in(1'b0),
		.pc_ccfg_scan_in(1'b0),
		.pc_bcfg_scan_in(1'b0),
		.pc_dcfg_scan_in(1'b0),
		.pc_func_scan_in(2'b00),
		.pc_gptr_scan_out(),
		.pc_ccfg_scan_out(),
		.pc_bcfg_scan_out(),
		.pc_dcfg_scan_out(),
		.pc_func_scan_out(),

		.cp_flush(cp_flush),
		.fu_slowspr_addr_in(fu_slowspr_addr_in),
		.fu_slowspr_data_in(fu_slowspr_data_in),
		.fu_slowspr_done_in(fu_slowspr_done_in),
		.fu_slowspr_etid_in(fu_slowspr_etid_in),
		.fu_slowspr_rw_in(fu_slowspr_rw_in),
		.fu_slowspr_val_in(fu_slowspr_val_in),
		.fu_slowspr_addr_out(fu_slowspr_addr_out),
		.fu_slowspr_data_out(fu_slowspr_data_out),
		.fu_slowspr_done_out(fu_slowspr_done_out),
		.fu_slowspr_etid_out(fu_slowspr_etid_out),
		.fu_slowspr_rw_out(fu_slowspr_rw_out),
		.fu_slowspr_val_out(fu_slowspr_val_out),

		.pc_slowspr_addr_in(pc_slowspr_addr_in),
		.pc_slowspr_data_in(pc_slowspr_data_in),
		.pc_slowspr_done_in(pc_slowspr_done_in),
		.pc_slowspr_etid_in(pc_slowspr_etid_in),
		.pc_slowspr_rw_in(pc_slowspr_rw_in),
		.pc_slowspr_val_in(pc_slowspr_val_in),
		.pc_slowspr_addr_out(pc_slowspr_addr_out),
		.pc_slowspr_data_out(pc_slowspr_data_out),
		.pc_slowspr_done_out(pc_slowspr_done_out),
		.pc_slowspr_etid_out(pc_slowspr_etid_out),
		.pc_slowspr_rw_out(pc_slowspr_rw_out),
		.pc_slowspr_val_out(pc_slowspr_val_out),

		// FU Interface
		.cp_t0_next_itag(cp_t0_next_itag),
		.cp_t1_next_itag(cp_t1_next_itag),
		.cp_axu_i0_t1_v(cp_axu_i0_t1_v),
		.cp_axu_i0_t0_t1_t(cp_axu_t0_i0_t1_t),
		.cp_axu_i0_t0_t1_p(cp_axu_t0_i0_t1_p),
		.cp_axu_i0_t1_t1_t(cp_axu_t1_i0_t1_t),
		.cp_axu_i0_t1_t1_p(cp_axu_t1_i0_t1_p),
		.cp_axu_i1_t1_v(cp_axu_i1_t1_v),
		.cp_axu_i1_t0_t1_t(cp_axu_t0_i1_t1_t),
		.cp_axu_i1_t0_t1_p(cp_axu_t0_i1_t1_p),
		.cp_axu_i1_t1_t1_t(cp_axu_t1_i1_t1_t),
		.cp_axu_i1_t1_t1_p(cp_axu_t1_i1_t1_p),

		.iu_xx_t0_zap_itag(cp_t0_flush_itag),
		.iu_xx_t1_zap_itag(cp_t1_flush_itag),
		.axu0_iu_async_fex(axu0_iu_async_fex),
		.axu0_iu_perf_events(axu0_iu_perf_events),
		.axu0_iu_exception(axu0_iu_exception),
		.axu0_iu_exception_val(axu0_iu_exception_val),
		.axu0_iu_execute_vld(axu0_iu_execute_vld),
		.axu0_iu_flush2ucode(axu0_iu_flush2ucode),
		.axu0_iu_flush2ucode_type(axu0_iu_flush2ucode_type),
		.axu0_iu_itag(axu0_iu_itag),
		.axu0_iu_n_flush(axu0_iu_n_flush),
		.axu0_iu_n_np1_flush(axu0_iu_n_np1_flush),
		.axu0_iu_np1_flush(axu0_iu_np1_flush),
		.axu1_iu_perf_events(axu1_iu_perf_events),
		.axu1_iu_exception(axu1_iu_exception),
		.axu1_iu_exception_val(axu1_iu_exception_val),
		.axu1_iu_execute_vld(axu1_iu_execute_vld),
		.axu1_iu_flush2ucode(axu1_iu_flush2ucode),
		.axu1_iu_flush2ucode_type(axu1_iu_flush2ucode_type),
		.axu1_iu_itag(axu1_iu_itag),
		.axu1_iu_n_flush(axu1_iu_n_flush),
		.axu1_iu_np1_flush(axu1_iu_np1_flush),

		.lq_fu_ex4_eff_addr(xu_axu_lq_ex4_addr),
		.lq_fu_ex5_load_le(xu_axu_lq_ex5_le),
		.lq_fu_ex5_load_data(xu_axu_lq_ex5_wd),
		.lq_fu_ex5_load_tag(xu_axu_lq_ex5_wa),
		.lq_fu_ex5_load_val(xu_axu_lq_ex5_we),
     	        .lq_fu_ex5_abort(xu_axu_lq_ex5_abort),
		.lq_gpr_rel_we(xu_axu_lq_rel_we),
		.lq_gpr_rel_le(xu_axu_lq_rel_le),
		.lq_gpr_rel_wa(xu_axu_lq_rel_wa),
		.lq_gpr_rel_wd(xu_axu_lq_rel_wd[64:127]),		// Fix me
		.lq_rv_itag0(lq_rv_itag0),
		.lq_rv_itag0_vld(lq_rv_itag0_vld[0]),
		.lq_rv_itag0_spec(lq_rv_itag0_spec),
		.lq_rv_itag1_restart(lq_rv_itag1_restart),
		.fu_lq_ex2_store_data_val(axu_xu_lq_ex_stq_val),
		.fu_lq_ex2_store_itag(axu_xu_lq_ex_stq_itag),
		.fu_lq_ex3_store_data(axu_xu_lq_exp1_stq_data),
		.fu_lq_ex3_sto_parity_err(axu_xu_lq_exp1_sto_parity_err),
      	        .fu_lq_ex3_abort(fu_lq_ex3_abort),

		.rv_axu0_vld(rv_axu0_vld),
		.rv_axu0_ex0_instr(rv_axu0_ex0_instr),
       	        .rv_axu0_ex0_itag(rv_axu0_ex0_itag),
		.rv_axu0_ex0_ucode(rv_axu0_ex0_ucode),
		.rv_axu0_ex0_t1_v(rv_axu0_ex0_t1_v),
		.rv_axu0_ex0_t1_p(rv_axu0_ex0_t1_p),
		.rv_axu0_ex0_t2_p(rv_axu0_ex0_t2_p),
		.rv_axu0_ex0_t3_p(rv_axu0_ex0_t3_p),
		.rv_axu0_s1_v(rv_axu0_s1_v),
		.rv_axu0_s1_p(rv_axu0_s1_p),
		.rv_axu0_s1_t(rv_axu0_s1_t),
		.rv_axu0_s2_v(rv_axu0_s2_v),
		.rv_axu0_s2_p(rv_axu0_s2_p),
		.rv_axu0_s2_t(rv_axu0_s2_t),
		.rv_axu0_s3_v(rv_axu0_s3_v),
		.rv_axu0_s3_p(rv_axu0_s3_p),
		.rv_axu0_s3_t(rv_axu0_s3_t),
      	        .axu0_rv_ex2_s1_abort(axu0_rv_ex2_s1_abort),
      	        .axu0_rv_ex2_s2_abort(axu0_rv_ex2_s2_abort),
      	        .axu0_rv_ex2_s3_abort(axu0_rv_ex2_s3_abort),
		.axu0_rv_itag(axu0_rv_itag),
		.axu0_rv_itag_vld(axu0_rv_itag_vld),
		.axu0_rv_itag_abort(axu0_rv_itag_abort),
		.axu0_rv_ord_complete(axu0_rv_ord_complete),
	        .axu0_rv_hold_all(axu0_rv_hold_all),
		.axu1_rv_itag(axu1_rv_itag),
		.axu1_rv_itag_vld(axu1_rv_itag_vld),
		.axu1_rv_itag_abort(axu1_rv_itag_abort),
	        .axu1_rv_hold_all(axu1_rv_hold_all),

		.pc_fu_abist_di_0({4{1'b0}}),
		.pc_fu_abist_di_1({4{1'b0}}),
		.pc_fu_abist_ena_dc(1'b0),
		.pc_fu_abist_grf_renb_0(1'b0),
		.pc_fu_abist_grf_renb_1(1'b0),
		.pc_fu_abist_grf_wenb_0(1'b0),
		.pc_fu_abist_grf_wenb_1(1'b0),
		.pc_fu_abist_raddr_0({10{1'b0}}),
		.pc_fu_abist_raddr_1({10{1'b0}}),
		.pc_fu_abist_raw_dc_b(1'b0),
		.pc_fu_abist_waddr_0({10{1'b0}}),
		.pc_fu_abist_waddr_1({10{1'b0}}),
		.pc_fu_abist_wl144_comp_ena(1'b0),

		.xu_fu_msr_fe0(spr_msr_fe0),
		.xu_fu_msr_fe1(spr_msr_fe1),
		.xu_fu_msr_fp(spr_msr_fp),
		.xu_fu_msr_gs(spr_msr_gs),
		.xu_fu_msr_pr(spr_msr_pr),
		.axu0_cr_w4e(axu0_cr_w4e),
		.axu0_cr_w4a(axu0_cr_w4a),
		.axu0_cr_w4d(axu0_cr_w4d),


		// PC Interface
		// SCOM Satellite
		.an_ac_scom_sat_id(an_ac_scom_sat_id),
		.an_ac_scom_dch(rp_pc_scom_dch_q),
		.an_ac_scom_cch(rp_pc_scom_cch_q),
		.ac_an_scom_dch(pc_rp_scom_dch),
		.ac_an_scom_cch(pc_rp_scom_cch),
		// FIR and Error Signals
		.ac_an_special_attn(pc_rp_special_attn),
		.ac_an_checkstop(pc_rp_checkstop),
		.ac_an_local_checkstop(pc_rp_local_checkstop),
		.ac_an_recov_err(pc_rp_recov_err),
		.ac_an_trace_error(pc_rp_trace_error),
      		.ac_an_livelock_active(pc_rp_livelock_active),
		.an_ac_checkstop(rp_pc_checkstop_q),
		.iu_pc_err_attention_instr(iu_pc_err_attention_instr),
		.iu_pc_err_icache_parity(iu_pc_err_icache_parity),
		.iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
		.iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
		.iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),
		.iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
		.iu_pc_err_btb_parity(iu_pc_err_btb_parity),
      		.iu_pc_err_cpArray_parity(iu_pc_err_cpArray_parity),
		.iu_pc_err_ucode_illegal(iu_pc_err_ucode_illegal),
		.iu_pc_err_mchk_disabled(iu_pc_err_mchk_disabled),
		.iu_pc_err_debug_event(iu_pc_err_debug_event),
		.lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
		.lq_pc_err_dcachedir_ldp_parity(lq_pc_err_dcachedir_ldp_parity),
		.lq_pc_err_dcachedir_stp_parity(lq_pc_err_dcachedir_stp_parity),
		.lq_pc_err_dcachedir_ldp_multihit(lq_pc_err_dcachedir_ldp_multihit),
		.lq_pc_err_dcachedir_stp_multihit(lq_pc_err_dcachedir_stp_multihit),
		.lq_pc_err_derat_parity(lq_pc_err_derat_parity),
		.lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
		.lq_pc_err_l2intrf_ecc(lq_pc_err_l2intrf_ecc),
		.lq_pc_err_l2intrf_ue(lq_pc_err_l2intrf_ue),
		.lq_pc_err_invld_reld(lq_pc_err_invld_reld),
		.lq_pc_err_l2credit_overrun(lq_pc_err_l2credit_overrun),
		.lq_pc_err_regfile_parity(lq_pc_err_regfile_parity),
		.lq_pc_err_regfile_ue(lq_pc_err_regfile_ue),
		.lq_pc_err_prefetcher_parity(lq_pc_err_prefetcher_parity),
		.lq_pc_err_relq_parity(lq_pc_err_relq_parity),
		.mm_pc_err_tlb_parity(mm_pc_tlb_par_err_ored),
		.mm_pc_err_tlb_multihit(mm_pc_tlb_multihit_err_ored),
		.mm_pc_err_tlb_lru_parity(mm_pc_lru_par_err_ored),
		.mm_pc_err_local_snoop_reject(mm_pc_local_snoop_reject_ored),
		.xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
		.xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
		.xu_pc_err_regfile_parity(xu_pc_err_regfile_parity),
		.xu_pc_err_regfile_ue(xu_pc_err_regfile_ue),
		.xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
		.xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),
		.xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),
		.pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
		.pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
		.pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
      		.pc_iu_inj_cpArray_parity(pc_iu_inj_cpArray_parity),
		.pc_lq_inj_dcache_parity(pc_lq_inj_dcache_parity),
		.pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
		.pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),
		.pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
		.pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),
		.pc_lq_inj_prefetcher_parity(pc_lq_inj_prefetcher_parity),
		.pc_lq_inj_regfile_parity(pc_lq_inj_regfile_parity),
		.pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),
		.pc_fx0_inj_regfile_parity(pc_fx0_inj_regfile_parity),
		.pc_fx1_inj_regfile_parity(pc_fx1_inj_regfile_parity),
		.pc_xu_inj_sprg_ecc(pc_xu_inj_sprg_ecc),
		.pc_xu_inj_llbust_attempt(pc_xu_inj_llbust_attempt),
		.pc_xu_inj_llbust_failed(pc_xu_inj_llbust_failed),
      		// Unit quiesce and credit status bits
      		.iu_pc_quiesce(iu_pc_quiesce),
     		.iu_pc_icache_quiesce(iu_pc_icache_quiesce),
      		.lq_pc_ldq_quiesce(lq_pc_ldq_quiesce),
      		.lq_pc_stq_quiesce(lq_pc_stq_quiesce),
      		.lq_pc_pfetch_quiesce(lq_pc_pfetch_quiesce),
      		.mm_pc_tlb_req_quiesce(mm_pc_tlb_req_quiesce),
      		.mm_pc_tlb_ctl_quiesce(mm_pc_tlb_ctl_quiesce),
      		.mm_pc_htw_quiesce(mm_pc_htw_quiesce),
      		.mm_pc_inval_quiesce(mm_pc_inval_quiesce),
      		.iu_pc_fx0_credit_ok(iu_pc_fx0_credit_ok),
      		.iu_pc_fx1_credit_ok(iu_pc_fx1_credit_ok),
      		.iu_pc_axu0_credit_ok(iu_pc_axu0_credit_ok),
      		.iu_pc_axu1_credit_ok(iu_pc_axu1_credit_ok),
      		.iu_pc_lq_credit_ok(iu_pc_lq_credit_ok),
      		.iu_pc_sq_credit_ok(iu_pc_sq_credit_ok),
		// RAM Command/Data
		.pc_iu_ram_instr(pc_iu_ram_instr),
		.pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
		.pc_iu_ram_active(pc_iu_ram_active),
		.pc_iu_ram_issue(pc_iu_ram_issue),
		.iu_pc_ram_done(iu_pc_ram_done),
		.iu_pc_ram_interrupt(iu_pc_ram_interrupt),
		.iu_pc_ram_unsupported(iu_pc_ram_unsupported),
		.pc_xu_ram_active(pc_xu_ram_active),
		.xu_pc_ram_data_val(xu_pc_ram_data_val),
		.xu_pc_ram_data(xu_pc_ram_data),
		.pc_lq_ram_active(pc_lq_ram_active),
		.lq_pc_ram_data_val(lq_pc_ram_data_val),
		.lq_pc_ram_data(lq_pc_ram_data),
		.pc_xu_msrovride_enab(pc_xu_msrovride_enab),
		.pc_xu_msrovride_pr(pc_xu_msrovride_pr),
		.pc_xu_msrovride_gs(pc_xu_msrovride_gs),
		.pc_xu_msrovride_de(pc_xu_msrovride_de),
		.pc_iu_ram_force_cmplt(),
		.pc_iu_ram_flush_thread(pc_iu_ram_flush_thread),
		// THRCTL + PCCR0 Registers
		.an_ac_debug_stop(rp_pc_debug_stop_q),
		.xu_pc_running(xu_pc_running),
		.iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
		.xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr),
		.iu_pc_step_done(iu_pc_step_done),
		.pc_iu_stop(pc_iu_stop),
		.pc_iu_step(pc_iu_step),
		.pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
		.pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
		.pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),
		.pc_iu_dbg_action(pc_iu_dbg_action_int),
		.pc_iu_spr_dbcr0_edm(pc_iu_spr_dbcr0_edm),
		.pc_xu_spr_dbcr0_edm(pc_xu_spr_dbcr0_edm),
		// Debug Bus Controls
		.pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
		.pc_rv_trace_bus_enable(pc_rv_trace_bus_enable),
		.pc_mm_trace_bus_enable(pc_mm_trace_bus_enable),
		.pc_xu_trace_bus_enable(pc_xu_trace_bus_enable),
		.pc_lq_trace_bus_enable(pc_lq_trace_bus_enable),
		.pc_iu_debug_mux1_ctrls(pc_iu_debug_mux1_ctrls),
		.pc_iu_debug_mux2_ctrls(pc_iu_debug_mux2_ctrls),
		.pc_rv_debug_mux_ctrls(pc_rv_debug_mux_ctrls),
		.pc_mm_debug_mux_ctrls(pc_mm_debug_mux_ctrls),
		.pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
		.pc_lq_debug_mux1_ctrls(pc_lq_debug_mux1_ctrls),
		.pc_lq_debug_mux2_ctrls(pc_lq_debug_mux2_ctrls),
 		// Event Bus Controls
		.pc_rv_event_mux_ctrls(pc_rv_event_mux_ctrls),
		.pc_iu_event_bus_enable(pc_iu_event_bus_enable),
		.pc_rv_event_bus_enable(pc_rv_event_bus_enable),
		.pc_mm_event_bus_enable(pc_mm_event_bus_enable),
		.pc_xu_event_bus_enable(pc_xu_event_bus_enable),
		.pc_lq_event_bus_enable(pc_lq_event_bus_enable),
		.pc_iu_event_count_mode(pc_iu_event_count_mode),
		.pc_rv_event_count_mode(pc_rv_event_count_mode),
		.pc_mm_event_count_mode(pc_mm_event_count_mode),
		.pc_xu_event_count_mode(pc_xu_event_count_mode),
		.pc_lq_event_count_mode(pc_lq_event_count_mode),
		.pc_iu_instr_trace_mode(pc_iu_instr_trace_mode),
		.pc_iu_instr_trace_tid(pc_iu_instr_trace_tid[0]),
		.pc_lq_instr_trace_mode(pc_lq_instr_trace_mode),
		.pc_lq_instr_trace_tid(pc_lq_instr_trace_tid[0]),
		.pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
		.pc_xu_instr_trace_tid(pc_xu_instr_trace_tid[0]),
		.xu_pc_perfmon_alert(xu_pc_perfmon_alert),
		.pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae),
		.pc_lq_event_bus_seldbghi(pc_lq_event_bus_seldbghi),
		.pc_lq_event_bus_seldbglo(pc_lq_event_bus_seldbglo),
		// Reset related
		.pc_lq_init_reset(pc_lq_init_reset),
		.pc_iu_init_reset(pc_iu_init_reset),
		// Power Management
		.ac_an_pm_thread_running(pc_rp_pm_thread_running),
		.an_ac_pm_thread_stop(rp_pc_pm_thread_stop_q),
		.an_ac_pm_fetch_halt(rp_pc_pm_fetch_halt_q),
      		.pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
		.ac_an_power_managed(pc_rp_power_managed),
		.ac_an_rvwinkle_mode(pc_rp_rvwinkle_mode),
		.pc_xu_pm_hold_thread(pc_xu_pm_hold_thread),
		.xu_pc_spr_ccr0_pme(xu_pc_spr_ccr0_pme),
		.xu_pc_spr_ccr0_we(xu_pc_spr_ccr0_we),
		// Clock, Test, and LCB Controls
		.an_ac_gsd_test_enable_dc(an_ac_gsd_test_enable_dc),
		.an_ac_gsd_test_acmode_dc(an_ac_gsd_test_acmode_dc),
		.an_ac_ccflush_dc(an_ac_ccflush_dc),
		.an_ac_ccenable_dc(an_ac_ccenable_dc),
		.an_ac_lbist_en_dc(an_ac_lbist_en_dc),
		.an_ac_lbist_ip_dc(an_ac_lbist_ip_dc),
		.an_ac_lbist_ac_mode_dc(an_ac_lbist_ac_mode_dc),
		.an_ac_scan_diag_dc(an_ac_scan_diag_dc),
		.an_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
		.an_ac_rtim_sl_thold_7(rp_pc_rtim_sl_thold_7),
		.an_ac_func_sl_thold_7(rp_pc_func_sl_thold_7),
		.an_ac_func_nsl_thold_7(rp_pc_func_nsl_thold_7),
		.an_ac_ary_nsl_thold_7(rp_pc_ary_nsl_thold_7),
		.an_ac_sg_7(rp_pc_sg_7),
		.an_ac_fce_7(rp_pc_fce_7),
		.an_ac_scan_type_dc(an_ac_scan_type_dc),
		// Thold outputs to clock staging
		.pc_rp_ccflush_out_dc(pc_rp_ccflush_out_dc),
		.pc_rp_gptr_sl_thold_4(pc_rp_gptr_sl_thold_4),
		.pc_rp_time_sl_thold_4(pc_rp_time_sl_thold_4),
		.pc_rp_repr_sl_thold_4(pc_rp_repr_sl_thold_4),
		.pc_rp_abst_sl_thold_4(pc_rp_abst_sl_thold_4),
		.pc_rp_abst_slp_sl_thold_4(pc_rp_abst_slp_sl_thold_4),
		.pc_rp_regf_sl_thold_4(pc_rp_regf_sl_thold_4),
		.pc_rp_regf_slp_sl_thold_4(pc_rp_regf_slp_sl_thold_4),
		.pc_rp_func_sl_thold_4(pc_rp_func_sl_thold_4),
		.pc_rp_func_slp_sl_thold_4(pc_rp_func_slp_sl_thold_4),
		.pc_rp_cfg_sl_thold_4(pc_rp_cfg_sl_thold_4),
		.pc_rp_cfg_slp_sl_thold_4(pc_rp_cfg_slp_sl_thold_4),
		.pc_rp_func_nsl_thold_4(pc_rp_func_nsl_thold_4),
		.pc_rp_func_slp_nsl_thold_4(pc_rp_func_slp_nsl_thold_4),
		.pc_rp_ary_nsl_thold_4(pc_rp_ary_nsl_thold_4),
		.pc_rp_ary_slp_nsl_thold_4(pc_rp_ary_slp_nsl_thold_4),
		.pc_rp_rtim_sl_thold_4(pc_rp_rtim_sl_thold_4),
		.pc_rp_sg_4(pc_rp_sg_4),
		.pc_rp_fce_4(pc_rp_fce_4)
		);

 //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   c_perv_rp
   perv_rp(
//	   .vdd(vdd),
//	   .gnd(gnd),
	   .nclk(nclk),

	   //CLOCK CONTROLS
	   //Top level clock controls
	   .an_ac_ccflush_dc(an_ac_ccflush_dc),
	   .rtim_sl_thold_8(an_ac_rtim_sl_thold_8),
	   .func_sl_thold_8(an_ac_func_sl_thold_8),
	   .func_nsl_thold_8(an_ac_func_nsl_thold_8),
	   .ary_nsl_thold_8(an_ac_ary_nsl_thold_8),
	   .sg_8(an_ac_sg_8),
	   .fce_8(an_ac_fce_8),
	   .rtim_sl_thold_7(rp_pc_rtim_sl_thold_7),
	   .func_sl_thold_7(rp_pc_func_sl_thold_7),
	   .func_nsl_thold_7(rp_pc_func_nsl_thold_7),
	   .ary_nsl_thold_7(rp_pc_ary_nsl_thold_7),
	   .sg_7(rp_pc_sg_7),
	   .fce_7(rp_pc_fce_7),
	   //Thold inputs from pcq clock controls
	   .pc_rp_ccflush_out_dc(pc_rp_ccflush_out_dc),
	   .pc_rp_gptr_sl_thold_4(pc_rp_gptr_sl_thold_4),
	   .pc_rp_time_sl_thold_4(pc_rp_time_sl_thold_4),
	   .pc_rp_repr_sl_thold_4(pc_rp_repr_sl_thold_4),
	   .pc_rp_abst_sl_thold_4(pc_rp_abst_sl_thold_4),
	   .pc_rp_abst_slp_sl_thold_4(pc_rp_abst_slp_sl_thold_4),
	   .pc_rp_regf_sl_thold_4(pc_rp_regf_sl_thold_4),
	   .pc_rp_regf_slp_sl_thold_4(pc_rp_regf_slp_sl_thold_4),
	   .pc_rp_func_sl_thold_4(pc_rp_func_sl_thold_4),
	   .pc_rp_func_slp_sl_thold_4(pc_rp_func_slp_sl_thold_4),
	   .pc_rp_cfg_sl_thold_4(pc_rp_cfg_sl_thold_4),
	   .pc_rp_cfg_slp_sl_thold_4(pc_rp_cfg_slp_sl_thold_4),
	   .pc_rp_func_nsl_thold_4(pc_rp_func_nsl_thold_4),
	   .pc_rp_func_slp_nsl_thold_4(pc_rp_func_slp_nsl_thold_4),
	   .pc_rp_ary_nsl_thold_4(pc_rp_ary_nsl_thold_4),
	   .pc_rp_ary_slp_nsl_thold_4(pc_rp_ary_slp_nsl_thold_4),
	   .pc_rp_rtim_sl_thold_4(pc_rp_rtim_sl_thold_4),
	   .pc_rp_sg_4(pc_rp_sg_4),
	   .pc_rp_fce_4(pc_rp_fce_4),
	   //Thold outputs to the units
	   .rp_iu_ccflush_dc(rp_iu_ccflush_dc),
	   .rp_iu_gptr_sl_thold_3(rp_iu_gptr_sl_thold_3),
	   .rp_iu_time_sl_thold_3(rp_iu_time_sl_thold_3),
	   .rp_iu_repr_sl_thold_3(rp_iu_repr_sl_thold_3),
	   .rp_iu_abst_sl_thold_3(rp_iu_abst_sl_thold_3),
	   .rp_iu_abst_slp_sl_thold_3(rp_iu_abst_slp_sl_thold_3),
	   .rp_iu_regf_slp_sl_thold_3(rp_iu_regf_slp_sl_thold_3),
	   .rp_iu_func_sl_thold_3(rp_iu_func_sl_thold_3),
	   .rp_iu_func_slp_sl_thold_3(rp_iu_func_slp_sl_thold_3),
	   .rp_iu_cfg_sl_thold_3(rp_iu_cfg_sl_thold_3),
	   .rp_iu_cfg_slp_sl_thold_3(rp_iu_cfg_slp_sl_thold_3),
	   .rp_iu_func_nsl_thold_3(rp_iu_func_nsl_thold_3),
	   .rp_iu_func_slp_nsl_thold_3(rp_iu_func_slp_nsl_thold_3),
	   .rp_iu_ary_nsl_thold_3(rp_iu_ary_nsl_thold_3),
	   .rp_iu_ary_slp_nsl_thold_3(rp_iu_ary_slp_nsl_thold_3),
	   .rp_iu_sg_3(rp_iu_sg_3),
	   .rp_iu_fce_3(rp_iu_fce_3),
	   //
	   .rp_rv_ccflush_dc(rp_rv_ccflush_dc),
	   .rp_rv_gptr_sl_thold_3(rp_rv_gptr_sl_thold_3),
	   .rp_rv_time_sl_thold_3(rp_rv_time_sl_thold_3),
	   .rp_rv_repr_sl_thold_3(rp_rv_repr_sl_thold_3),
	   .rp_rv_abst_sl_thold_3(rp_rv_abst_sl_thold_3),
	   .rp_rv_abst_slp_sl_thold_3(rp_rv_abst_slp_sl_thold_3),
	   .rp_rv_func_sl_thold_3(rp_rv_func_sl_thold_3),
	   .rp_rv_func_slp_sl_thold_3(rp_rv_func_slp_sl_thold_3),
	   .rp_rv_cfg_sl_thold_3(rp_rv_cfg_sl_thold_3),
	   .rp_rv_cfg_slp_sl_thold_3(rp_rv_cfg_slp_sl_thold_3),
	   .rp_rv_func_nsl_thold_3(rp_rv_func_nsl_thold_3),
	   .rp_rv_func_slp_nsl_thold_3(rp_rv_func_slp_nsl_thold_3),
	   .rp_rv_ary_nsl_thold_3(rp_rv_ary_nsl_thold_3),
	   .rp_rv_ary_slp_nsl_thold_3(rp_rv_ary_slp_nsl_thold_3),
	   .rp_rv_sg_3(rp_rv_sg_3),
	   .rp_rv_fce_3(rp_rv_fce_3),
	   //
	   .rp_xu_ccflush_dc(rp_xu_ccflush_dc),
	   .rp_xu_gptr_sl_thold_3(rp_xu_gptr_sl_thold_3),
	   .rp_xu_time_sl_thold_3(rp_xu_time_sl_thold_3),
	   .rp_xu_repr_sl_thold_3(rp_xu_repr_sl_thold_3),
	   .rp_xu_abst_sl_thold_3(rp_xu_abst_sl_thold_3),
	   .rp_xu_abst_slp_sl_thold_3(rp_xu_abst_slp_sl_thold_3),
	   .rp_xu_regf_slp_sl_thold_3(rp_xu_regf_slp_sl_thold_3),
	   .rp_xu_func_sl_thold_3(rp_xu_func_sl_thold_3),
	   .rp_xu_func_slp_sl_thold_3(rp_xu_func_slp_sl_thold_3),
	   .rp_xu_cfg_sl_thold_3(rp_xu_cfg_sl_thold_3),
	   .rp_xu_cfg_slp_sl_thold_3(rp_xu_cfg_slp_sl_thold_3),
	   .rp_xu_func_nsl_thold_3(rp_xu_func_nsl_thold_3),
	   .rp_xu_func_slp_nsl_thold_3(rp_xu_func_slp_nsl_thold_3),
	   .rp_xu_ary_nsl_thold_3(rp_xu_ary_nsl_thold_3),
	   .rp_xu_ary_slp_nsl_thold_3(rp_xu_ary_slp_nsl_thold_3),
	   .rp_xu_sg_3(rp_xu_sg_3),
	   .rp_xu_fce_3(rp_xu_fce_3),
	   //
	   .rp_lq_ccflush_dc(rp_lq_ccflush_dc),
	   .rp_lq_gptr_sl_thold_3(rp_lq_gptr_sl_thold_3),
	   .rp_lq_time_sl_thold_3(rp_lq_time_sl_thold_3),
	   .rp_lq_repr_sl_thold_3(rp_lq_repr_sl_thold_3),
	   .rp_lq_abst_sl_thold_3(rp_lq_abst_sl_thold_3),
	   .rp_lq_abst_slp_sl_thold_3(rp_lq_abst_slp_sl_thold_3),
	   .rp_lq_regf_slp_sl_thold_3(rp_lq_regf_slp_sl_thold_3),
	   .rp_lq_func_sl_thold_3(rp_lq_func_sl_thold_3),
	   .rp_lq_func_slp_sl_thold_3(rp_lq_func_slp_sl_thold_3),
	   .rp_lq_cfg_sl_thold_3(rp_lq_cfg_sl_thold_3),
	   .rp_lq_cfg_slp_sl_thold_3(rp_lq_cfg_slp_sl_thold_3),
	   .rp_lq_func_nsl_thold_3(rp_lq_func_nsl_thold_3),
	   .rp_lq_func_slp_nsl_thold_3(rp_lq_func_slp_nsl_thold_3),
	   .rp_lq_ary_nsl_thold_3(rp_lq_ary_nsl_thold_3),
	   .rp_lq_ary_slp_nsl_thold_3(rp_lq_ary_slp_nsl_thold_3),
	   .rp_lq_sg_3(rp_lq_sg_3),
	   .rp_lq_fce_3(rp_lq_fce_3),
	   //
	   .rp_mm_ccflush_dc(rp_mm_ccflush_dc),
	   .rp_mm_gptr_sl_thold_3(rp_mm_gptr_sl_thold_3),
	   .rp_mm_time_sl_thold_3(rp_mm_time_sl_thold_3),
	   .rp_mm_repr_sl_thold_3(rp_mm_repr_sl_thold_3),
	   .rp_mm_abst_sl_thold_3(rp_mm_abst_sl_thold_3),
	   .rp_mm_abst_slp_sl_thold_3(rp_mm_abst_slp_sl_thold_3),
	   .rp_mm_func_sl_thold_3(rp_mm_func_sl_thold_3),
	   .rp_mm_func_slp_sl_thold_3(rp_mm_func_slp_sl_thold_3),
	   .rp_mm_cfg_sl_thold_3(rp_mm_cfg_sl_thold_3),
	   .rp_mm_cfg_slp_sl_thold_3(rp_mm_cfg_slp_sl_thold_3),
	   .rp_mm_func_nsl_thold_3(rp_mm_func_nsl_thold_3),
	   .rp_mm_func_slp_nsl_thold_3(rp_mm_func_slp_nsl_thold_3),
	   .rp_mm_ary_nsl_thold_3(rp_mm_ary_nsl_thold_3),
	   .rp_mm_ary_slp_nsl_thold_3(rp_mm_ary_slp_nsl_thold_3),
	   .rp_mm_sg_3(rp_mm_sg_3),
	   .rp_mm_fce_3(rp_mm_fce_3),

	   //SCANRING REPOWERING
	   .pc_bcfg_scan_in(1'b0),
	   .pc_bcfg_scan_in_q(),
	   .pc_dcfg_scan_in(1'b0),
	   .pc_dcfg_scan_in_q(),
	   .pc_bcfg_scan_out(1'b0),
	   .pc_bcfg_scan_out_q(),
	   .pc_ccfg_scan_out(1'b0),
	   .pc_ccfg_scan_out_q(),
	   .pc_dcfg_scan_out(1'b0),
	   .pc_dcfg_scan_out_q(),
	   .pc_func_scan_in(2'b00),
	   .pc_func_scan_in_q(),
	   .pc_func_scan_out(2'b00),
	   .pc_func_scan_out_q(),
	   //
	   .fu_abst_scan_in(1'b0),
	   .fu_abst_scan_in_q(),
	   .fu_abst_scan_out(1'b0),
	   .fu_abst_scan_out_q(),
	   .fu_ccfg_scan_out(1'b0),
	   .fu_ccfg_scan_out_q(),
	   .fu_bcfg_scan_out(1'b0),
	   .fu_bcfg_scan_out_q(),
	   .fu_dcfg_scan_out(1'b0),
	   .fu_dcfg_scan_out_q(),
	   .fu_func_scan_in(4'b0000),
	   .fu_func_scan_in_q(),
	   .fu_func_scan_out(4'b0000),
	   .fu_func_scan_out_q(),

	   //MISCELLANEOUS FUNCTIONAL SIGNALS
	   // node inputs going to pcq
	   .an_ac_scom_dch(an_ac_scom_dch),
	   .an_ac_scom_cch(an_ac_scom_cch),
	   .an_ac_checkstop(an_ac_checkstop),
	   .an_ac_debug_stop(an_ac_debug_stop),
	   .an_ac_pm_thread_stop(an_ac_pm_thread_stop),
	   .an_ac_pm_fetch_halt(an_ac_pm_fetch_halt),
	   //
	   .rp_pc_scom_dch_q(rp_pc_scom_dch_q),
	   .rp_pc_scom_cch_q(rp_pc_scom_cch_q),
	   .rp_pc_checkstop_q(rp_pc_checkstop_q),
	   .rp_pc_debug_stop_q(rp_pc_debug_stop_q),
	   .rp_pc_pm_thread_stop_q(rp_pc_pm_thread_stop_q),
	   .rp_pc_pm_fetch_halt_q(rp_pc_pm_fetch_halt_q),
	   // pcq outputs going to node
	   .pc_rp_scom_dch(pc_rp_scom_dch),
	   .pc_rp_scom_cch(pc_rp_scom_cch),
	   .pc_rp_special_attn(pc_rp_special_attn),
	   .pc_rp_checkstop(pc_rp_checkstop),
	   .pc_rp_local_checkstop(pc_rp_local_checkstop),
	   .pc_rp_recov_err(pc_rp_recov_err),
	   .pc_rp_trace_error(pc_rp_trace_error),
	   .pc_rp_pm_thread_running(pc_rp_pm_thread_running),
	   .pc_rp_power_managed(pc_rp_power_managed),
	   .pc_rp_rvwinkle_mode(pc_rp_rvwinkle_mode),
      	   .pc_rp_livelock_active(pc_rp_livelock_active),
	   //
	   .ac_an_scom_dch_q(ac_an_scom_dch),
	   .ac_an_scom_cch_q(ac_an_scom_cch),
	   .ac_an_special_attn_q(ac_an_special_attn),
	   .ac_an_checkstop_q(ac_an_checkstop),
	   .ac_an_local_checkstop_q(ac_an_local_checkstop),
	   .ac_an_recov_err_q(ac_an_recov_err),
	   .ac_an_trace_error_q(ac_an_trace_error),
	   .ac_an_pm_thread_running_q(ac_an_pm_thread_running),
	   .ac_an_power_managed_q(ac_an_power_managed_int),
	   .ac_an_rvwinkle_mode_q(ac_an_rvwinkle_mode),
      	   .ac_an_livelock_active_q(ac_an_livelock_active),

	   // SCAN CHAINS
	   .scan_diag_dc(an_ac_scan_diag_dc),
	   .scan_dis_dc_b(an_ac_scan_dis_dc_b),
	   .func_scan_in(1'b0),
	   .gptr_scan_in(1'b0),
	   .func_scan_out(),
	   .gptr_scan_out()
	   );

endmodule
