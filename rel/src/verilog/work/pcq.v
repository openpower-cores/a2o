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

//
//  Description: Pervasive Core Unit
//
//*****************************************************************************


module pcq(
// Include model build parameters
`include "tri_a2o.vh"

   // inout                     	vdd,
   // inout                     	gnd,
   (* pin_data="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) // nclk
   input  [0:`NCLK_WIDTH-1]  	nclk,
   //SCOM and Register Interfaces
   //  SCOM Satellite
   input  [0:3]              	an_ac_scom_sat_id,
   input                     	an_ac_scom_dch,
   input                     	an_ac_scom_cch,
   output                    	ac_an_scom_dch,
   output                    	ac_an_scom_cch,
   //  Slow SPR
   input                     	slowspr_val_in,
   input                     	slowspr_rw_in,
   input  [0:1]              	slowspr_etid_in,
   input  [0:9]              	slowspr_addr_in,
   input  [64-`GPR_WIDTH:63] 	slowspr_data_in,
   input                     	slowspr_done_in,
   input  [0:`THREADS-1]     	cp_flush,
   output                    	slowspr_val_out,
   output                    	slowspr_rw_out,
   output [0:1]              	slowspr_etid_out,
   output [0:9]              	slowspr_addr_out,
   output [64-`GPR_WIDTH:63] 	slowspr_data_out,
   output                    	slowspr_done_out,

   //FIR and Error Signals
   output [0:`THREADS-1]     	ac_an_special_attn,
   output [0:2]              	ac_an_checkstop,
   output [0:2]              	ac_an_local_checkstop,
   output [0:2]              	ac_an_recov_err,
   output                    	ac_an_trace_error,
   output                       ac_an_livelock_active,
   input                     	an_ac_checkstop,
   input  [0:`THREADS-1]     	fu_pc_err_regfile_parity,
   input  [0:`THREADS-1]     	fu_pc_err_regfile_ue,
   input                     	iu_pc_err_icache_parity,
   input                     	iu_pc_err_icachedir_parity,
   input                     	iu_pc_err_icachedir_multihit,
   input                     	iu_pc_err_ierat_parity,
   input                     	iu_pc_err_ierat_multihit,
   input                     	iu_pc_err_btb_parity,
   input  [0:`THREADS-1]     	iu_pc_err_cpArray_parity,
   input  [0:`THREADS-1]     	iu_pc_err_ucode_illegal,
   input  [0:`THREADS-1]     	iu_pc_err_mchk_disabled,
   input  [0:`THREADS-1]     	iu_pc_err_debug_event,
   input                     	lq_pc_err_dcache_parity,
   input                     	lq_pc_err_dcachedir_ldp_parity,
   input                     	lq_pc_err_dcachedir_stp_parity,
   input                     	lq_pc_err_dcachedir_ldp_multihit,
   input                     	lq_pc_err_dcachedir_stp_multihit,
   input                     	lq_pc_err_derat_parity,
   input                     	lq_pc_err_derat_multihit,
   input                     	lq_pc_err_l2intrf_ecc,
   input                     	lq_pc_err_l2intrf_ue,
   input                     	lq_pc_err_invld_reld,
   input                     	lq_pc_err_l2credit_overrun,
   input  [0:`THREADS-1]     	lq_pc_err_regfile_parity,
   input  [0:`THREADS-1]     	lq_pc_err_regfile_ue,
   input                     	lq_pc_err_prefetcher_parity,
   input                        lq_pc_err_relq_parity,
   input                     	mm_pc_err_tlb_parity,
   input                     	mm_pc_err_tlb_multihit,
   input                     	mm_pc_err_tlb_lru_parity,
   input                     	mm_pc_err_local_snoop_reject,
   input  [0:`THREADS-1]     	xu_pc_err_sprg_ecc,
   input  [0:`THREADS-1]     	xu_pc_err_sprg_ue,
   input  [0:`THREADS-1]     	xu_pc_err_regfile_parity,
   input  [0:`THREADS-1]     	xu_pc_err_regfile_ue,
   input  [0:`THREADS-1]     	xu_pc_err_llbust_attempt,
   input  [0:`THREADS-1]     	xu_pc_err_llbust_failed,
   input  [0:`THREADS-1]     	xu_pc_err_wdt_reset,
   input  [0:`THREADS-1]     	iu_pc_err_attention_instr,
   output                    	pc_iu_inj_icache_parity,
   output                    	pc_iu_inj_icachedir_parity,
   output                    	pc_iu_inj_icachedir_multihit,
   output                    	pc_lq_inj_dcache_parity,
   output                    	pc_lq_inj_dcachedir_ldp_parity,
   output                    	pc_lq_inj_dcachedir_stp_parity,
   output                    	pc_lq_inj_dcachedir_ldp_multihit,
   output                    	pc_lq_inj_dcachedir_stp_multihit,
   output                    	pc_lq_inj_prefetcher_parity,
   output                    	pc_lq_inj_relq_parity,
   output [0:`THREADS-1]     	pc_xu_inj_sprg_ecc,
   output [0:`THREADS-1]     	pc_fx0_inj_regfile_parity,
   output [0:`THREADS-1]     	pc_fx1_inj_regfile_parity,
   output [0:`THREADS-1]     	pc_lq_inj_regfile_parity,
   output [0:`THREADS-1]     	pc_fu_inj_regfile_parity,
   output [0:`THREADS-1]     	pc_xu_inj_llbust_attempt,
   output [0:`THREADS-1]     	pc_xu_inj_llbust_failed,
   output [0:`THREADS-1]     	pc_iu_inj_cpArray_parity,
   //  Unit quiesce and credit status bits
   input  [0:`THREADS-1]        iu_pc_quiesce,
   input  [0:`THREADS-1]        iu_pc_icache_quiesce,
   input  [0:`THREADS-1]        lq_pc_ldq_quiesce,
   input  [0:`THREADS-1]        lq_pc_stq_quiesce,
   input  [0:`THREADS-1]        lq_pc_pfetch_quiesce,
   input  [0:`THREADS-1]        mm_pc_tlb_req_quiesce,
   input  [0:`THREADS-1]        mm_pc_tlb_ctl_quiesce,
   input  [0:`THREADS-1]        mm_pc_htw_quiesce,
   input  [0:`THREADS-1]        mm_pc_inval_quiesce,
   input  [0:`THREADS-1]        iu_pc_fx0_credit_ok,
   input  [0:`THREADS-1]        iu_pc_fx1_credit_ok,
   input  [0:`THREADS-1]        iu_pc_axu0_credit_ok,
   input  [0:`THREADS-1]        iu_pc_axu1_credit_ok,
   input  [0:`THREADS-1]        iu_pc_lq_credit_ok,
   input  [0:`THREADS-1]        iu_pc_sq_credit_ok,
   //Debug Functions
   //  RAM Command/Data
   output [0:31]             	pc_iu_ram_instr,
   output [0:3]              	pc_iu_ram_instr_ext,
   output [0:`THREADS-1]     	pc_iu_ram_active,
   output                    	pc_iu_ram_execute,
   input                     	iu_pc_ram_done,
   input                     	iu_pc_ram_interrupt,
   input                     	iu_pc_ram_unsupported,
   output [0:`THREADS-1]     	pc_xu_ram_active,
   input                     	xu_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63] 	xu_pc_ram_data,
   output [0:`THREADS-1]     	pc_fu_ram_active,
   input                     	fu_pc_ram_data_val,
   input  [0:63]             	fu_pc_ram_data,
   output [0:`THREADS-1]     	pc_lq_ram_active,
   input                     	lq_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63] 	lq_pc_ram_data,
   output                    	pc_xu_msrovride_enab,
   output                    	pc_xu_msrovride_pr,
   output                    	pc_xu_msrovride_gs,
   output                    	pc_xu_msrovride_de,
   output                    	pc_iu_ram_force_cmplt,
   output [0:`THREADS-1]     	pc_iu_ram_flush_thread,
   //  THRCTL + PCCR0 Registers
   input  [0:`THREADS-1]     	xu_pc_running,
   input  [0:`THREADS-1]     	iu_pc_stop_dbg_event,
   input  [0:`THREADS-1]     	xu_pc_stop_dnh_instr,
   input  [0:`THREADS-1]     	iu_pc_step_done,
   output [0:`THREADS-1]     	pc_iu_stop,
   output [0:`THREADS-1]     	pc_iu_step,
   output                    	pc_xu_extirpts_dis_on_stop,
   output                    	pc_xu_timebase_dis_on_stop,
   output                    	pc_xu_decrem_dis_on_stop,
   input                     	an_ac_debug_stop,
   output [0:3*`THREADS-1]   	pc_iu_dbg_action,
   output [0:`THREADS-1]     	pc_iu_spr_dbcr0_edm,
   output [0:`THREADS-1]     	pc_xu_spr_dbcr0_edm,

   //Trace/Debug Bus
   output [0:31]             	debug_bus_out,
   input  [0:31]             	debug_bus_in,
   input  [0:3]		    	coretrace_ctrls_in,
   output [0:3]		    	coretrace_ctrls_out,
   //  Debug Select Register outputs to units for debug grouping
   output                    	pc_iu_trace_bus_enable,
   output                    	pc_fu_trace_bus_enable,
   output                    	pc_rv_trace_bus_enable,
   output                    	pc_mm_trace_bus_enable,
   output                    	pc_xu_trace_bus_enable,
   output                    	pc_lq_trace_bus_enable,
   output [0:10]             	pc_iu_debug_mux1_ctrls,
   output [0:10]             	pc_iu_debug_mux2_ctrls,
   output [0:10]             	pc_fu_debug_mux_ctrls,
   output [0:10]             	pc_rv_debug_mux_ctrls,
   output [0:10]             	pc_mm_debug_mux_ctrls,
   output [0:10]             	pc_xu_debug_mux_ctrls,
   output [0:10]             	pc_lq_debug_mux1_ctrls,
   output [0:10]             	pc_lq_debug_mux2_ctrls,

   //Performance event mux controls
   output [0:39]             	pc_rv_event_mux_ctrls,
   output                    	pc_iu_event_bus_enable,
   output                    	pc_fu_event_bus_enable,
   output                    	pc_rv_event_bus_enable,
   output                    	pc_mm_event_bus_enable,
   output                    	pc_xu_event_bus_enable,
   output                    	pc_lq_event_bus_enable,
   output [0:2]              	pc_iu_event_count_mode,
   output [0:2]              	pc_fu_event_count_mode,
   output [0:2]              	pc_rv_event_count_mode,
   output [0:2]              	pc_mm_event_count_mode,
   output [0:2]              	pc_xu_event_count_mode,
   output [0:2]              	pc_lq_event_count_mode,
   output                    	pc_lq_event_bus_seldbghi,
   output                    	pc_lq_event_bus_seldbglo,
   output                    	pc_iu_instr_trace_mode,
   output                    	pc_iu_instr_trace_tid,
   output                    	pc_lq_instr_trace_mode,
   output                    	pc_lq_instr_trace_tid,
   output                    	pc_xu_instr_trace_mode,
   output                    	pc_xu_instr_trace_tid,
   input  [0:`THREADS-1]     	xu_pc_perfmon_alert,
   output [0:`THREADS-1]     	pc_xu_spr_cesr1_pmae,

   //Reset related
   output                    	pc_lq_init_reset,
   output                    	pc_iu_init_reset,

   //Power Management
   output [0:`THREADS-1]     	ac_an_pm_thread_running,
   input  [0:`THREADS-1]     	an_ac_pm_thread_stop,
   input  [0:`THREADS-1]     	an_ac_pm_fetch_halt,
   output [0:`THREADS-1]       	pc_iu_pm_fetch_halt,
   output                    	ac_an_power_managed,
   output                    	ac_an_rvwinkle_mode,
   output                    	pc_xu_pm_hold_thread,
   input  [0:1]              	xu_pc_spr_ccr0_pme,
   input  [0:`THREADS-1]     	xu_pc_spr_ccr0_we,

   //Clock, Test, and LCB Controls
   input                     	an_ac_gsd_test_enable_dc,
   input                     	an_ac_gsd_test_acmode_dc,
   input                     	an_ac_ccflush_dc,
   input                     	an_ac_ccenable_dc,
   input                     	an_ac_lbist_en_dc,
   input                     	an_ac_lbist_ip_dc,
   input                     	an_ac_lbist_ac_mode_dc,
   input                     	an_ac_scan_diag_dc,
   input                     	an_ac_scan_dis_dc_b,
   //  Thold input to clock control macro
   input                     	an_ac_rtim_sl_thold_7,
   input                     	an_ac_func_sl_thold_7,
   input                     	an_ac_func_nsl_thold_7,
   input                     	an_ac_ary_nsl_thold_7,
   input                     	an_ac_sg_7,
   input                     	an_ac_fce_7,
   input  [0:8]              	an_ac_scan_type_dc,
   //  Thold outputs to clock staging
   output                    	pc_rp_ccflush_out_dc,
   output                    	pc_rp_gptr_sl_thold_4,
   output                    	pc_rp_time_sl_thold_4,
   output                    	pc_rp_repr_sl_thold_4,
   output                    	pc_rp_abst_sl_thold_4,
   output                    	pc_rp_abst_slp_sl_thold_4,
   output                    	pc_rp_regf_sl_thold_4,
   output                    	pc_rp_regf_slp_sl_thold_4,
   output                    	pc_rp_func_sl_thold_4,
   output                    	pc_rp_func_slp_sl_thold_4,
   output                    	pc_rp_cfg_sl_thold_4,
   output                    	pc_rp_cfg_slp_sl_thold_4,
   output                    	pc_rp_func_nsl_thold_4,
   output                    	pc_rp_func_slp_nsl_thold_4,
   output                    	pc_rp_ary_nsl_thold_4,
   output                    	pc_rp_ary_slp_nsl_thold_4,
   output                    	pc_rp_rtim_sl_thold_4,
   output                    	pc_rp_sg_4,
   output                    	pc_rp_fce_4,
   //
   output               	pc_fu_ccflush_dc,
   output               	pc_fu_gptr_sl_thold_3,
   output               	pc_fu_time_sl_thold_3,
   output               	pc_fu_repr_sl_thold_3,
   output               	pc_fu_abst_sl_thold_3,
   output               	pc_fu_abst_slp_sl_thold_3,
   output [0:1]               	pc_fu_func_sl_thold_3,
   output [0:1]               	pc_fu_func_slp_sl_thold_3,
   output               	pc_fu_cfg_sl_thold_3,
   output               	pc_fu_cfg_slp_sl_thold_3,
   output               	pc_fu_func_nsl_thold_3,
   output               	pc_fu_func_slp_nsl_thold_3,
   output               	pc_fu_ary_nsl_thold_3,
   output               	pc_fu_ary_slp_nsl_thold_3,
   output [0:1]              	pc_fu_sg_3,
   output               	pc_fu_fce_3,

   //Scanning
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  // scan_in
   input                     	gptr_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  // scan_in
   input                     	ccfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  // scan_in
   input                     	bcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  // scan_in
   input                     	dcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  // scan_in
   input  [0:1]              	func_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                    	gptr_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                    	ccfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                    	bcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output                    	dcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) // scan_out
   output [0:1]              	func_scan_out
);


//=====================================================================
// Signal Declarations
//=====================================================================
//---------------------------------------------------------------------
// Basic/Misc Signals
   wire 		     	ct_db_func_scan_out;
   wire 		     	db_ss_func_scan_out;
   wire 		     	lcbctrl_gptr_scan_out;
   // Misc Controls
   wire [0:`THREADS-1]  	ct_rg_power_managed;
   wire 		     	ct_ck_pm_raise_tholds;
   wire 		     	ct_ck_pm_ccflush_disable;
   wire 		     	rg_ct_dis_pwr_savings;
   wire 		     	rg_ck_fast_xstop;
   wire 		     	ct_rg_hold_during_init;
   // SRAMD data and load pulse
   wire 		     	rg_rg_load_sramd;
   wire [0:63]  	     	rg_rg_sramd_din;
   // Clock Controls
   wire 		     	d_mode_dc;
   wire 		     	clkoff_dc_b;
   wire 		     	act_dis_dc;
   wire [0:4]		     	delay_lclkr_dc;
   wire [0:4]		     	mpw1_dc_b;
   wire 		     	mpw2_dc_b;
   wire 		     	pc_pc_ccflush_dc;
   wire 		     	pc_pc_gptr_sl_thold_0;
   wire 		     	pc_pc_func_sl_thold_0;
   wire 		     	pc_pc_func_slp_sl_thold_0;
   wire 		     	pc_pc_cfg_sl_thold_0;
   wire 		     	pc_pc_cfg_slp_sl_thold_0;
   wire 		     	pc_pc_sg_0;
   // Trace bus signals
   wire 		     	sp_rg_trace_bus_enable;
   wire 		     	rg_db_trace_bus_enable;
   wire [0:10]  	     	rg_db_debug_mux_ctrls;
   wire [0:11]		     	rg_db_dbg_scom;
   wire [0:24] 			rg_db_dbg_thrctls;
   wire [0:15] 			rg_db_dbg_ram;
   wire [0:27]  	     	rg_db_dbg_fir0_err;
   wire [0:19]  	     	rg_db_dbg_fir1_err;
   wire [0:19]		   	rg_db_dbg_fir2_err;
   wire [0:14] 			rg_db_dbg_fir_misc;
   wire [0:14]		     	ct_db_dbg_ctrls;
   wire [0:7]  	     		rg_db_dbg_spr;

   wire                      	vdd;
   wire                      	gnd;

// Get rid of sinkless net messages
// synopsys translate_off
(* analysis_not_referenced="true" *)
// synopsys translate_on
   wire 		     	unused_signals;
   assign unused_signals = (|{1'b0, 1'b0});

   assign 			vdd = 1'b1;
   assign 			gnd = 1'b0;

//!! Bugspray Include: pcq;

//=====================================================================
// Start of PCQ Module Instantiations
//=====================================================================

   pcq_regs  pcq_regs(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .lcb_clkoff_dc_b(clkoff_dc_b),
      .lcb_d_mode_dc(d_mode_dc),
      .lcb_mpw1_dc_b(mpw1_dc_b[0]),
      .lcb_mpw2_dc_b(mpw2_dc_b),
      .lcb_delay_lclkr_dc(delay_lclkr_dc[0]),
      .lcb_act_dis_dc(act_dis_dc),
      .lcb_func_slp_sl_thold_0(pc_pc_func_slp_sl_thold_0),
      .lcb_cfg_sl_thold_0(pc_pc_cfg_sl_thold_0),
      .lcb_cfg_slp_sl_thold_0(pc_pc_cfg_slp_sl_thold_0),
      .lcb_sg_0(pc_pc_sg_0),
      .ccfg_scan_in(ccfg_scan_in),
      .bcfg_scan_in(bcfg_scan_in),
      .dcfg_scan_in(dcfg_scan_in),
      .func_scan_in(func_scan_in[0]),
      .ccfg_scan_out(ccfg_scan_out),
      .bcfg_scan_out(bcfg_scan_out),
      .dcfg_scan_out(dcfg_scan_out),
      .func_scan_out(func_scan_out[0]),
      //SCOM Satellite interface
      .an_ac_scom_sat_id(an_ac_scom_sat_id),
      .an_ac_scom_dch(an_ac_scom_dch),
      .an_ac_scom_cch(an_ac_scom_cch),
      .ac_an_scom_dch(ac_an_scom_dch),
      .ac_an_scom_cch(ac_an_scom_cch),
      //Error Related
      .ac_an_special_attn(ac_an_special_attn),
      .ac_an_checkstop(ac_an_checkstop),
      .ac_an_local_checkstop(ac_an_local_checkstop),
      .ac_an_recov_err(ac_an_recov_err),
      .ac_an_trace_error(ac_an_trace_error),
      .ac_an_livelock_active(ac_an_livelock_active),
      .an_ac_checkstop(an_ac_checkstop),
      .rg_ck_fast_xstop(rg_ck_fast_xstop),
      .fu_pc_err_regfile_parity(fu_pc_err_regfile_parity),
      .fu_pc_err_regfile_ue(fu_pc_err_regfile_ue),
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
      .mm_pc_err_tlb_parity(mm_pc_err_tlb_parity),
      .mm_pc_err_tlb_multihit(mm_pc_err_tlb_multihit),
      .mm_pc_err_tlb_lru_parity(mm_pc_err_tlb_lru_parity),
      .mm_pc_err_local_snoop_reject(mm_pc_err_local_snoop_reject),
      .xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
      .xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
      .xu_pc_err_regfile_parity(xu_pc_err_regfile_parity),
      .xu_pc_err_regfile_ue(xu_pc_err_regfile_ue),
      .xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
      .xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),
      .xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),
      .iu_pc_err_attention_instr(iu_pc_err_attention_instr),
      .pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
      .pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
      .pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
      .pc_lq_inj_dcache_parity(pc_lq_inj_dcache_parity),
      .pc_lq_inj_dcachedir_ldp_parity(pc_lq_inj_dcachedir_ldp_parity),
      .pc_lq_inj_dcachedir_stp_parity(pc_lq_inj_dcachedir_stp_parity),
      .pc_lq_inj_dcachedir_ldp_multihit(pc_lq_inj_dcachedir_ldp_multihit),
      .pc_lq_inj_dcachedir_stp_multihit(pc_lq_inj_dcachedir_stp_multihit),
      .pc_lq_inj_prefetcher_parity(pc_lq_inj_prefetcher_parity),
      .pc_lq_inj_relq_parity(pc_lq_inj_relq_parity),
      .pc_xu_inj_sprg_ecc(pc_xu_inj_sprg_ecc),
      .pc_fx0_inj_regfile_parity(pc_fx0_inj_regfile_parity),
      .pc_fx1_inj_regfile_parity(pc_fx1_inj_regfile_parity),
      .pc_lq_inj_regfile_parity(pc_lq_inj_regfile_parity),
      .pc_fu_inj_regfile_parity(pc_fu_inj_regfile_parity),
      .pc_xu_inj_llbust_attempt(pc_xu_inj_llbust_attempt),
      .pc_xu_inj_llbust_failed(pc_xu_inj_llbust_failed),
      .pc_iu_inj_cpArray_parity(pc_iu_inj_cpArray_parity),
      //  Unit quiesce and credit status bits
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
      //RAMC+RAMD
      .pc_iu_ram_instr(pc_iu_ram_instr),
      .pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
      .pc_iu_ram_active(pc_iu_ram_active),
      .pc_iu_ram_execute(pc_iu_ram_execute),
      .iu_pc_ram_done(iu_pc_ram_done),
      .iu_pc_ram_interrupt(iu_pc_ram_interrupt),
      .iu_pc_ram_unsupported(iu_pc_ram_unsupported),
      .pc_xu_ram_active(pc_xu_ram_active),
      .xu_pc_ram_data_val(xu_pc_ram_data_val),
      .xu_pc_ram_data(xu_pc_ram_data),
      .pc_fu_ram_active(pc_fu_ram_active),
      .fu_pc_ram_data_val(fu_pc_ram_data_val),
      .fu_pc_ram_data(fu_pc_ram_data),
      .pc_lq_ram_active(pc_lq_ram_active),
      .lq_pc_ram_data_val(lq_pc_ram_data_val),
      .lq_pc_ram_data(lq_pc_ram_data),
      .pc_xu_msrovride_enab(pc_xu_msrovride_enab),
      .pc_xu_msrovride_pr(pc_xu_msrovride_pr),
      .pc_xu_msrovride_gs(pc_xu_msrovride_gs),
      .pc_xu_msrovride_de(pc_xu_msrovride_de),
      .pc_iu_ram_force_cmplt(pc_iu_ram_force_cmplt),
      .pc_iu_ram_flush_thread(pc_iu_ram_flush_thread),
      .rg_rg_load_sramd(rg_rg_load_sramd),
      .rg_rg_sramd_din(rg_rg_sramd_din),
      //THRCTL + PCCR0 Registers
      .ac_an_pm_thread_running(ac_an_pm_thread_running),
      .pc_iu_stop(pc_iu_stop),
      .pc_iu_step(pc_iu_step),
      .pc_iu_dbg_action(pc_iu_dbg_action),
      .pc_iu_spr_dbcr0_edm(pc_iu_spr_dbcr0_edm),
      .pc_xu_spr_dbcr0_edm(pc_xu_spr_dbcr0_edm),
      .xu_pc_running(xu_pc_running),
      .iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
      .xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr),
      .iu_pc_step_done(iu_pc_step_done),
      .an_ac_pm_thread_stop(an_ac_pm_thread_stop),
      .an_ac_pm_fetch_halt(an_ac_pm_fetch_halt),
      .pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
      .ct_rg_power_managed(ct_rg_power_managed),
      .ct_rg_hold_during_init(ct_rg_hold_during_init),
      .an_ac_debug_stop(an_ac_debug_stop),
      .pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
      .pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
      .pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),
      .rg_ct_dis_pwr_savings(rg_ct_dis_pwr_savings),
      //Debug Registers
      .sp_rg_trace_bus_enable(sp_rg_trace_bus_enable),
      .rg_db_trace_bus_enable(rg_db_trace_bus_enable),
      .pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
      .pc_fu_trace_bus_enable(pc_fu_trace_bus_enable),
      .pc_rv_trace_bus_enable(pc_rv_trace_bus_enable),
      .pc_mm_trace_bus_enable(pc_mm_trace_bus_enable),
      .pc_xu_trace_bus_enable(pc_xu_trace_bus_enable),
      .pc_lq_trace_bus_enable(pc_lq_trace_bus_enable),
      .rg_db_debug_mux_ctrls(rg_db_debug_mux_ctrls),
      .pc_iu_debug_mux1_ctrls(pc_iu_debug_mux1_ctrls),
      .pc_iu_debug_mux2_ctrls(pc_iu_debug_mux2_ctrls),
      .pc_fu_debug_mux_ctrls(pc_fu_debug_mux_ctrls),
      .pc_rv_debug_mux_ctrls(pc_rv_debug_mux_ctrls),
      .pc_mm_debug_mux_ctrls(pc_mm_debug_mux_ctrls),
      .pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
      .pc_lq_debug_mux1_ctrls(pc_lq_debug_mux1_ctrls),
      .pc_lq_debug_mux2_ctrls(pc_lq_debug_mux2_ctrls),
      //Trace Signals
      .dbg_scom(rg_db_dbg_scom),
      .dbg_thrctls(rg_db_dbg_thrctls),
      .dbg_ram(rg_db_dbg_ram),
      .dbg_fir0_err(rg_db_dbg_fir0_err),
      .dbg_fir1_err(rg_db_dbg_fir1_err),
      .dbg_fir2_err(rg_db_dbg_fir2_err),
      .dbg_fir_misc(rg_db_dbg_fir_misc)
   );

   pcq_ctrl  pcq_ctrl(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .lcb_clkoff_dc_b(clkoff_dc_b),
      .lcb_mpw1_dc_b(mpw1_dc_b[1]),
      .lcb_mpw2_dc_b(mpw2_dc_b),
      .lcb_delay_lclkr_dc(delay_lclkr_dc[1]),
      .lcb_act_dis_dc(act_dis_dc),
      .pc_pc_func_slp_sl_thold_0(pc_pc_func_slp_sl_thold_0),
      .pc_pc_sg_0(pc_pc_sg_0),
      .func_scan_in(func_scan_in[1]),
      .func_scan_out(ct_db_func_scan_out),
      //Stop/Start/Reset
      .pc_lq_init_reset(pc_lq_init_reset),
      .pc_iu_init_reset(pc_iu_init_reset),
      .ct_rg_hold_during_init(ct_rg_hold_during_init),
      //Power Management
      .ct_rg_power_managed(ct_rg_power_managed),
      .ac_an_power_managed(ac_an_power_managed),
      .ac_an_rvwinkle_mode(ac_an_rvwinkle_mode),
      .pc_xu_pm_hold_thread(pc_xu_pm_hold_thread),
      .ct_ck_pm_ccflush_disable(ct_ck_pm_ccflush_disable),
      .ct_ck_pm_raise_tholds(ct_ck_pm_raise_tholds),
      .rg_ct_dis_pwr_savings(rg_ct_dis_pwr_savings),
      .xu_pc_spr_ccr0_pme(xu_pc_spr_ccr0_pme),
      .xu_pc_spr_ccr0_we(xu_pc_spr_ccr0_we),
      //Trace/Trigger Signals
      .dbg_ctrls(ct_db_dbg_ctrls)
   );

   pcq_dbg  pcq_dbg(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .lcb_clkoff_dc_b(clkoff_dc_b),
      .lcb_mpw1_dc_b(mpw1_dc_b[2]),
      .lcb_mpw2_dc_b(mpw2_dc_b),
      .lcb_delay_lclkr_dc(delay_lclkr_dc[2]),
      .lcb_act_dis_dc(act_dis_dc),
      .pc_pc_func_slp_sl_thold_0(pc_pc_func_slp_sl_thold_0),
      .pc_pc_sg_0(pc_pc_sg_0),
      .func_scan_in(ct_db_func_scan_out),
      .func_scan_out(db_ss_func_scan_out),
      //Trace/Trigger Bus
      .debug_bus_out(debug_bus_out),
      .debug_bus_in(debug_bus_in),
      .rg_db_trace_bus_enable(rg_db_trace_bus_enable),
      .rg_db_debug_mux_ctrls(rg_db_debug_mux_ctrls),
      .coretrace_ctrls_in(coretrace_ctrls_in),
      .coretrace_ctrls_out(coretrace_ctrls_out),
      //PC Unit internal debug signals
      .rg_db_dbg_scom(rg_db_dbg_scom),
      .rg_db_dbg_thrctls(rg_db_dbg_thrctls),
      .rg_db_dbg_ram(rg_db_dbg_ram),
      .rg_db_dbg_fir0_err(rg_db_dbg_fir0_err),
      .rg_db_dbg_fir1_err(rg_db_dbg_fir1_err),
      .rg_db_dbg_fir2_err(rg_db_dbg_fir2_err),
      .rg_db_dbg_fir_misc(rg_db_dbg_fir_misc),
      .ct_db_dbg_ctrls(ct_db_dbg_ctrls),
      .rg_db_dbg_spr(rg_db_dbg_spr)
   );

   pcq_spr  pcq_spr(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .scan_dis_dc_b(an_ac_scan_dis_dc_b),
      .lcb_clkoff_dc_b(clkoff_dc_b),
      .lcb_mpw1_dc_b(mpw1_dc_b[0]),
      .lcb_mpw2_dc_b(mpw2_dc_b),
      .lcb_delay_lclkr_dc(delay_lclkr_dc[0]),
      .lcb_act_dis_dc(act_dis_dc),
      .pc_pc_func_sl_thold_0(pc_pc_func_sl_thold_0),
      .pc_pc_sg_0(pc_pc_sg_0),
      .func_scan_in(db_ss_func_scan_out),
      .func_scan_out(func_scan_out[1]),
      // slowSPR Interface
      .slowspr_val_in(slowspr_val_in),
      .slowspr_rw_in(slowspr_rw_in),
      .slowspr_etid_in(slowspr_etid_in),
      .slowspr_addr_in(slowspr_addr_in),
      .slowspr_data_in(slowspr_data_in[64 - `GPR_WIDTH:63]),
      .slowspr_done_in(slowspr_done_in),
      .cp_flush(cp_flush),
      .slowspr_val_out(slowspr_val_out),
      .slowspr_rw_out(slowspr_rw_out),
      .slowspr_etid_out(slowspr_etid_out),
      .slowspr_addr_out(slowspr_addr_out),
      .slowspr_data_out(slowspr_data_out[64 - `GPR_WIDTH:63]),
      .slowspr_done_out(slowspr_done_out),
      // Event Mux Controls
      .pc_rv_event_mux_ctrls(pc_rv_event_mux_ctrls),
      // CESR1 Controls
      .pc_iu_event_bus_enable(pc_iu_event_bus_enable),
      .pc_fu_event_bus_enable(pc_fu_event_bus_enable),
      .pc_rv_event_bus_enable(pc_rv_event_bus_enable),
      .pc_mm_event_bus_enable(pc_mm_event_bus_enable),
      .pc_xu_event_bus_enable(pc_xu_event_bus_enable),
      .pc_lq_event_bus_enable(pc_lq_event_bus_enable),
      .pc_iu_event_count_mode(pc_iu_event_count_mode),
      .pc_fu_event_count_mode(pc_fu_event_count_mode),
      .pc_rv_event_count_mode(pc_rv_event_count_mode),
      .pc_mm_event_count_mode(pc_mm_event_count_mode),
      .pc_xu_event_count_mode(pc_xu_event_count_mode),
      .pc_lq_event_count_mode(pc_lq_event_count_mode),
      .sp_rg_trace_bus_enable(sp_rg_trace_bus_enable),
      .pc_iu_instr_trace_mode(pc_iu_instr_trace_mode),
      .pc_iu_instr_trace_tid(pc_iu_instr_trace_tid),
      .pc_lq_instr_trace_mode(pc_lq_instr_trace_mode),
      .pc_lq_instr_trace_tid(pc_lq_instr_trace_tid),
      .pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
      .pc_xu_instr_trace_tid(pc_xu_instr_trace_tid),
      .pc_lq_event_bus_seldbghi(pc_lq_event_bus_seldbghi),
      .pc_lq_event_bus_seldbglo(pc_lq_event_bus_seldbglo),
      .xu_pc_perfmon_alert(xu_pc_perfmon_alert),
      .pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae),
      // SRAMD data and load pulse
      .rg_rg_load_sramd(rg_rg_load_sramd),
      .rg_rg_sramd_din(rg_rg_sramd_din),
      // Debug
      .dbg_spr(rg_db_dbg_spr)
   );

   pcq_clks  pcq_clks(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .rtim_sl_thold_7(an_ac_rtim_sl_thold_7),
      .func_sl_thold_7(an_ac_func_sl_thold_7),
      .func_nsl_thold_7(an_ac_func_nsl_thold_7),
      .ary_nsl_thold_7(an_ac_ary_nsl_thold_7),
      .sg_7(an_ac_sg_7),
      .fce_7(an_ac_fce_7),
      .gsd_test_enable_dc(an_ac_gsd_test_enable_dc),
      .gsd_test_acmode_dc(an_ac_gsd_test_acmode_dc),
      .ccflush_dc(an_ac_ccflush_dc),
      .ccenable_dc(an_ac_ccenable_dc),
      .scan_type_dc(an_ac_scan_type_dc),
      .lbist_en_dc(an_ac_lbist_en_dc),
      .lbist_ip_dc(an_ac_lbist_ip_dc),
      .rg_ck_fast_xstop(rg_ck_fast_xstop),
      .ct_ck_pm_ccflush_disable(ct_ck_pm_ccflush_disable),
      .ct_ck_pm_raise_tholds(ct_ck_pm_raise_tholds),
      //  --Thold outputs to the units
      .pc_pc_ccflush_out_dc(pc_rp_ccflush_out_dc),
      .pc_pc_gptr_sl_thold_4(pc_rp_gptr_sl_thold_4),
      .pc_pc_time_sl_thold_4(pc_rp_time_sl_thold_4),
      .pc_pc_repr_sl_thold_4(pc_rp_repr_sl_thold_4),
      .pc_pc_abst_sl_thold_4(pc_rp_abst_sl_thold_4),
      .pc_pc_abst_slp_sl_thold_4(pc_rp_abst_slp_sl_thold_4),
      .pc_pc_regf_sl_thold_4(pc_rp_regf_sl_thold_4),
      .pc_pc_regf_slp_sl_thold_4(pc_rp_regf_slp_sl_thold_4),
      .pc_pc_func_sl_thold_4(pc_rp_func_sl_thold_4),
      .pc_pc_func_slp_sl_thold_4(pc_rp_func_slp_sl_thold_4),
      .pc_pc_cfg_sl_thold_4(pc_rp_cfg_sl_thold_4),
      .pc_pc_cfg_slp_sl_thold_4(pc_rp_cfg_slp_sl_thold_4),
      .pc_pc_func_nsl_thold_4(pc_rp_func_nsl_thold_4),
      .pc_pc_func_slp_nsl_thold_4(pc_rp_func_slp_nsl_thold_4),
      .pc_pc_ary_nsl_thold_4(pc_rp_ary_nsl_thold_4),
      .pc_pc_ary_slp_nsl_thold_4(pc_rp_ary_slp_nsl_thold_4),
      .pc_pc_rtim_sl_thold_4(pc_rp_rtim_sl_thold_4),
      .pc_pc_sg_4(pc_rp_sg_4),
      .pc_pc_fce_4(pc_rp_fce_4),
      .pc_fu_ccflush_dc(pc_fu_ccflush_dc),
      .pc_fu_gptr_sl_thold_3(pc_fu_gptr_sl_thold_3),
      .pc_fu_time_sl_thold_3(pc_fu_time_sl_thold_3),
      .pc_fu_repr_sl_thold_3(pc_fu_repr_sl_thold_3),
      .pc_fu_abst_sl_thold_3(pc_fu_abst_sl_thold_3),
      .pc_fu_abst_slp_sl_thold_3(pc_fu_abst_slp_sl_thold_3),
      .pc_fu_func_sl_thold_3(pc_fu_func_sl_thold_3),
      .pc_fu_func_slp_sl_thold_3(pc_fu_func_slp_sl_thold_3),
      .pc_fu_cfg_sl_thold_3(pc_fu_cfg_sl_thold_3),
      .pc_fu_cfg_slp_sl_thold_3(pc_fu_cfg_slp_sl_thold_3),
      .pc_fu_func_nsl_thold_3(pc_fu_func_nsl_thold_3),
      .pc_fu_func_slp_nsl_thold_3(pc_fu_func_slp_nsl_thold_3),
      .pc_fu_ary_nsl_thold_3(pc_fu_ary_nsl_thold_3),
      .pc_fu_ary_slp_nsl_thold_3(pc_fu_ary_slp_nsl_thold_3),
      .pc_fu_sg_3(pc_fu_sg_3),
      .pc_fu_fce_3(pc_fu_fce_3),
      .pc_pc_ccflush_dc(pc_pc_ccflush_dc),
      .pc_pc_gptr_sl_thold_0(pc_pc_gptr_sl_thold_0),
      .pc_pc_func_sl_thold_0(pc_pc_func_sl_thold_0),
      .pc_pc_func_slp_sl_thold_0(pc_pc_func_slp_sl_thold_0),
      .pc_pc_cfg_sl_thold_0(pc_pc_cfg_sl_thold_0),
      .pc_pc_cfg_slp_sl_thold_0(pc_pc_cfg_slp_sl_thold_0),
      .pc_pc_sg_0(pc_pc_sg_0)
   );


//=====================================================================
// LCBCNTL Macro
//=====================================================================
   tri_lcbcntl_mac  lcbctrl(
      .vdd(vdd),
      .gnd(gnd),
      .sg(pc_pc_sg_0),
      .nclk(nclk),
      .scan_in(gptr_scan_in),
      .scan_diag_dc(an_ac_scan_diag_dc),
      .thold(pc_pc_gptr_sl_thold_0),
      .clkoff_dc_b(clkoff_dc_b),
      .delay_lclkr_dc(delay_lclkr_dc[0:4]),
      .act_dis_dc(),
      .d_mode_dc(d_mode_dc),
      .mpw1_dc_b(mpw1_dc_b[0:4]),
      .mpw2_dc_b(mpw2_dc_b),
      .scan_out(lcbctrl_gptr_scan_out)
   );

   // Forcing act_dis pin on all tri_lcbor components to 0.
   // Using logic signal connected to LCB ACT pin to control if latch held or updated.
   assign act_dis_dc = 1'b0;


endmodule
