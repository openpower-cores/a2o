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

//*****************************************************************************
//*
//*  TITLE: c_fu_pc
//*
//*  DESC:  Top level interface for a combined fu and pcq RLM
//*
//*****************************************************************************

(* recursive_synthesis=0 *)


module c_fu_pc(
 `include "tri_a2o.vh"
// ----------------------------------------------------------------------
// Common I/O Ports
// ----------------------------------------------------------------------
   // inout                     		vdd,
   // inout                     		gnd,
   (* PIN_DATA="PIN_FUNCTION=/G_CLK/CAP_LIMIT=/99999/" *) 	// nclk
   input  [0:`NCLK_WIDTH-1]   			nclk,

   input  [0:31]                         	fu_debug_bus_in,
   output [0:31]                        	fu_debug_bus_out,
   input  [0:3]                          	fu_coretrace_ctrls_in,
   output [0:3]                         	fu_coretrace_ctrls_out,
   input  [0:4*`THREADS-1] 			fu_event_bus_in,
   output [0:4*`THREADS-1] 			fu_event_bus_out,

   input  [0:31]             			pc_debug_bus_in,
   output [0:31]             			pc_debug_bus_out,
   input  [0:3]		    			pc_coretrace_ctrls_in,
   output [0:3]		    			pc_coretrace_ctrls_out,

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_gptr_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_time_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_repr_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_bcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_ccfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_dcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input  [0:3]                         	fu_func_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                                	fu_abst_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_gptr_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_time_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_repr_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_bcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_ccfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_dcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output [0:3]                         	fu_func_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                               	fu_abst_scan_out,

   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                     			pc_gptr_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                     			pc_ccfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                     			pc_bcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input                     			pc_dcfg_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_IN/" *)  	// scan_in
   input  [0:1]              			pc_func_scan_in,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                    			pc_gptr_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                    			pc_ccfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                    			pc_bcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output                    			pc_dcfg_scan_out,
   (* pin_data="PIN_FUNCTION=/SCAN_OUT/" *) 	// scan_out
   output [0:1]              			pc_func_scan_out,

   input  [0:`THREADS-1]                 	cp_flush,
   input  [0:9]                          	fu_slowspr_addr_in,
   input  [64-(2**`REGMODE):63]          	fu_slowspr_data_in,
   input                                	fu_slowspr_done_in,
   input  [0:1]                          	fu_slowspr_etid_in,
   input                                	fu_slowspr_rw_in,
   input                                	fu_slowspr_val_in,
   output [0:9]                         	fu_slowspr_addr_out,
   output [64-(2**`REGMODE):63]         	fu_slowspr_data_out,
   output                               	fu_slowspr_done_out,
   output [0:1]                         	fu_slowspr_etid_out,
   output                               	fu_slowspr_rw_out,
   output                               	fu_slowspr_val_out,

   input  [0:9]              			pc_slowspr_addr_in,
   input  [64-`GPR_WIDTH:63] 			pc_slowspr_data_in,
   input                     			pc_slowspr_done_in,
   input  [0:1]              			pc_slowspr_etid_in,
   input                     			pc_slowspr_rw_in,
   input                     			pc_slowspr_val_in,
   output [0:9]              			pc_slowspr_addr_out,
   output [64-`GPR_WIDTH:63] 			pc_slowspr_data_out,
   output                    			pc_slowspr_done_out,
   output [0:1]              			pc_slowspr_etid_out,
   output                    			pc_slowspr_rw_out,
   output                    			pc_slowspr_val_out,


// ----------------------------------------------------------------------
// FU Interface
// ----------------------------------------------------------------------
   input  [0:6]                      		cp_t0_next_itag,
   input  [0:6]                      		cp_t1_next_itag,
   input  [0:`THREADS-1] 			cp_axu_i0_t1_v,
   input  [0:2] 	       			cp_axu_i0_t0_t1_t,
   input  [0:5] 	       			cp_axu_i0_t0_t1_p,
   input  [0:2] 	       			cp_axu_i0_t1_t1_t,
   input  [0:5] 	       			cp_axu_i0_t1_t1_p,
   input  [0:`THREADS-1] 			cp_axu_i1_t1_v,
   input  [0:2] 	       			cp_axu_i1_t0_t1_t,
   input  [0:5] 	       			cp_axu_i1_t0_t1_p,
   input  [0:2] 	       			cp_axu_i1_t1_t1_t,
   input  [0:5] 	       			cp_axu_i1_t1_t1_p,

   input  [0:6]                     		iu_xx_t0_zap_itag,
   input  [0:6]                      		iu_xx_t1_zap_itag,
   output [0:`THREADS-1]                        axu0_iu_async_fex,
   output [0:3]                         	axu0_iu_perf_events,
   output [0:3]                         	axu0_iu_exception,
   output                               	axu0_iu_exception_val,
   output [0:`THREADS-1]                	axu0_iu_execute_vld,
   output                               	axu0_iu_flush2ucode,
   output                               	axu0_iu_flush2ucode_type,
   output [0:`ITAG_SIZE_ENC-1]          	axu0_iu_itag,
   output                               	axu0_iu_n_flush,
   output                               	axu0_iu_n_np1_flush,
   output                               	axu0_iu_np1_flush,
   output [0:3]                         	axu1_iu_perf_events,
   output [0:3]                         	axu1_iu_exception,
   output                               	axu1_iu_exception_val,
   output [0:`THREADS-1]                	axu1_iu_execute_vld,
   output                               	axu1_iu_flush2ucode,
   output                               	axu1_iu_flush2ucode_type,
   output [0:`ITAG_SIZE_ENC-1]          	axu1_iu_itag,
   output                               	axu1_iu_n_flush,
   output                               	axu1_iu_np1_flush,

   input  [59:63]                        	lq_fu_ex4_eff_addr,
   input                                	lq_fu_ex5_load_le,
   input  [192:255]                      	lq_fu_ex5_load_data,
   input  [0:7+`THREADS]                 	lq_fu_ex5_load_tag,
   input                                	lq_fu_ex5_load_val,
   input                                	lq_fu_ex5_abort,
   input                                	lq_gpr_rel_we,
   input                                	lq_gpr_rel_le,
   input  [0:7+`THREADS]                 	lq_gpr_rel_wa,
   input  [64:127]                       	lq_gpr_rel_wd,
   input  [0:`ITAG_SIZE_ENC-1]           	lq_rv_itag0,
   input                                	lq_rv_itag0_vld,
   input                                	lq_rv_itag0_spec,
   input                                	lq_rv_itag1_restart,
   output [0:`THREADS-1]                	fu_lq_ex2_store_data_val,
   output [0:`ITAG_SIZE_ENC-1]          	fu_lq_ex2_store_itag,
   output [0:63]                        	fu_lq_ex3_store_data,
   output                               	fu_lq_ex3_sto_parity_err,
   output                               	fu_lq_ex3_abort,

   input  [0:`THREADS-1]                 	rv_axu0_vld,
   input  [0:31]                         	rv_axu0_ex0_instr,
   input  [0:`ITAG_SIZE_ENC-1] 			rv_axu0_ex0_itag,
   input  [0:2]                          	rv_axu0_ex0_ucode,
   input                                	rv_axu0_ex0_t1_v,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_ex0_t1_p,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_ex0_t2_p,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_ex0_t3_p,
   input                                	rv_axu0_s1_v,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_s1_p,
   input  [0:2]                          	rv_axu0_s1_t,
   input                                	rv_axu0_s2_v,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_s2_p,
   input  [0:2]                          	rv_axu0_s2_t,
   input                                	rv_axu0_s3_v,
   input  [0:`FPR_POOL_ENC-1]            	rv_axu0_s3_p,
   input  [0:2]                          	rv_axu0_s3_t,
   output                               	axu0_rv_ex2_s1_abort,
   output                               	axu0_rv_ex2_s2_abort,
   output                               	axu0_rv_ex2_s3_abort,
   output [0:`ITAG_SIZE_ENC-1]          	axu0_rv_itag,
   output [0:`THREADS-1]                	axu0_rv_itag_vld,
   output 					axu0_rv_itag_abort,
   output                               	axu0_rv_ord_complete,
   output                               	axu0_rv_hold_all,
   output [0:`ITAG_SIZE_ENC-1]          	axu1_rv_itag,
   output [0:`THREADS-1]                	axu1_rv_itag_vld,
   output 					axu1_rv_itag_abort,
   output                               	axu1_rv_hold_all,

   input  [0:3]                         	pc_fu_abist_di_0,
   input  [0:3]                          	pc_fu_abist_di_1,
   input                                	pc_fu_abist_ena_dc,
   input                                	pc_fu_abist_grf_renb_0,
   input                                	pc_fu_abist_grf_renb_1,
   input                                	pc_fu_abist_grf_wenb_0,
   input                                	pc_fu_abist_grf_wenb_1,
   input  [0:9]                          	pc_fu_abist_raddr_0,
   input  [0:9]                          	pc_fu_abist_raddr_1,
   input                                 	pc_fu_abist_raw_dc_b,
   input  [0:9]                          	pc_fu_abist_waddr_0,
   input  [0:9]                          	pc_fu_abist_waddr_1,
   input                                	pc_fu_abist_wl144_comp_ena,

   input  [0:`THREADS-1]                 	xu_fu_msr_fe0,
   input  [0:`THREADS-1]                 	xu_fu_msr_fe1,
   input  [0:`THREADS-1]                 	xu_fu_msr_fp,
   input  [0:`THREADS-1]                 	xu_fu_msr_gs,
   input  [0:`THREADS-1]                 	xu_fu_msr_pr,
   output                                   	axu0_cr_w4e,
   output [0:`CR_POOL_ENC+`THREAD_POOL_ENC-1] 	axu0_cr_w4a,
   output [0:3]                         	axu0_cr_w4d,

// ----------------------------------------------------------------------
// PC Interface
// ----------------------------------------------------------------------
   //SCOM Satellite
   input  [0:3]              			an_ac_scom_sat_id,
   input                     			an_ac_scom_dch,
   input                     			an_ac_scom_cch,
   output                    			ac_an_scom_dch,
   output                    			ac_an_scom_cch,
   // FIR and Error Signals
   output [0:`THREADS-1]     			ac_an_special_attn,
   output [0:2]              			ac_an_checkstop,
   output [0:2]              			ac_an_local_checkstop,
   output [0:2]              			ac_an_recov_err,
   output                    			ac_an_trace_error,
   output                       		ac_an_livelock_active,
   input                     			an_ac_checkstop,
   input  [0:`THREADS-1]     			iu_pc_err_attention_instr,
   input                     			iu_pc_err_icache_parity,
   input                     			iu_pc_err_icachedir_parity,
   input                     			iu_pc_err_icachedir_multihit,
   input                     			iu_pc_err_ierat_parity,
   input                     			iu_pc_err_ierat_multihit,
   input                     			iu_pc_err_btb_parity,
   input  [0:`THREADS-1]     			iu_pc_err_cpArray_parity,
   input  [0:`THREADS-1]     			iu_pc_err_ucode_illegal,
   input  [0:`THREADS-1]     			iu_pc_err_mchk_disabled,
   input  [0:`THREADS-1]     			iu_pc_err_debug_event,
   input                     			lq_pc_err_dcache_parity,
   input                     			lq_pc_err_dcachedir_ldp_parity,
   input                     			lq_pc_err_dcachedir_stp_parity,
   input                     			lq_pc_err_dcachedir_ldp_multihit,
   input                     			lq_pc_err_dcachedir_stp_multihit,
   input                     			lq_pc_err_derat_parity,
   input                     			lq_pc_err_derat_multihit,
   input                     			lq_pc_err_l2intrf_ecc,
   input                     			lq_pc_err_l2intrf_ue,
   input                     			lq_pc_err_invld_reld,
   input                     			lq_pc_err_l2credit_overrun,
   input  [0:`THREADS-1]     			lq_pc_err_regfile_parity,
   input  [0:`THREADS-1]     			lq_pc_err_regfile_ue,
   input                     			lq_pc_err_prefetcher_parity,
   input                        		lq_pc_err_relq_parity,
   input                     			mm_pc_err_tlb_parity,
   input                     			mm_pc_err_tlb_multihit,
   input                     			mm_pc_err_tlb_lru_parity,
   input                     			mm_pc_err_local_snoop_reject,
   input  [0:`THREADS-1]     			xu_pc_err_sprg_ecc,
   input  [0:`THREADS-1]     			xu_pc_err_sprg_ue,
   input  [0:`THREADS-1]     			xu_pc_err_regfile_parity,
   input  [0:`THREADS-1]     			xu_pc_err_regfile_ue,
   input  [0:`THREADS-1]     			xu_pc_err_llbust_attempt,
   input  [0:`THREADS-1]     			xu_pc_err_llbust_failed,
   input  [0:`THREADS-1]     			xu_pc_err_wdt_reset,
   output                    			pc_iu_inj_icache_parity,
   output                    			pc_iu_inj_icachedir_parity,
   output                    			pc_iu_inj_icachedir_multihit,
   output [0:`THREADS-1]     			pc_iu_inj_cpArray_parity,
   output                    			pc_lq_inj_dcache_parity,
   output                    			pc_lq_inj_dcachedir_ldp_parity,
   output                    			pc_lq_inj_dcachedir_stp_parity,
   output                    			pc_lq_inj_dcachedir_ldp_multihit,
   output                    			pc_lq_inj_dcachedir_stp_multihit,
   output                    			pc_lq_inj_prefetcher_parity,
   output [0:`THREADS-1]     			pc_lq_inj_regfile_parity,
   output                    			pc_lq_inj_relq_parity,
   output [0:`THREADS-1]     			pc_fx0_inj_regfile_parity,
   output [0:`THREADS-1]     			pc_fx1_inj_regfile_parity,
   output [0:`THREADS-1]     			pc_xu_inj_sprg_ecc,
   output [0:`THREADS-1]     			pc_xu_inj_llbust_attempt,
   output [0:`THREADS-1]     			pc_xu_inj_llbust_failed,
   //  Unit quiesce and credit status bits
   input  [0:`THREADS-1]        		iu_pc_quiesce,
   input  [0:`THREADS-1]        		iu_pc_icache_quiesce,
   input  [0:`THREADS-1]        		lq_pc_ldq_quiesce,
   input  [0:`THREADS-1]        		lq_pc_stq_quiesce,
   input  [0:`THREADS-1]        		lq_pc_pfetch_quiesce,
   input  [0:`THREADS-1]        		mm_pc_tlb_req_quiesce,
   input  [0:`THREADS-1]        		mm_pc_tlb_ctl_quiesce,
   input  [0:`THREADS-1]        		mm_pc_htw_quiesce,
   input  [0:`THREADS-1]        		mm_pc_inval_quiesce,
   input  [0:`THREADS-1]        		iu_pc_fx0_credit_ok,
   input  [0:`THREADS-1]        		iu_pc_fx1_credit_ok,
   input  [0:`THREADS-1]        		iu_pc_axu0_credit_ok,
   input  [0:`THREADS-1]        		iu_pc_axu1_credit_ok,
   input  [0:`THREADS-1]        		iu_pc_lq_credit_ok,
   input  [0:`THREADS-1]        		iu_pc_sq_credit_ok,
   // RAM Command/Data
   output [0:31]             			pc_iu_ram_instr,
   output [0:3]              			pc_iu_ram_instr_ext,
   output [0:`THREADS-1]     			pc_iu_ram_active,
   output                    			pc_iu_ram_issue,
   input                     			iu_pc_ram_done,
   input                     			iu_pc_ram_interrupt,
   input                     			iu_pc_ram_unsupported,
   output [0:`THREADS-1]     			pc_xu_ram_active,
   input                     			xu_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63] 			xu_pc_ram_data,
   output [0:`THREADS-1]     			pc_lq_ram_active,
   input                     			lq_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63] 			lq_pc_ram_data,
   output                    			pc_xu_msrovride_enab,
   output                    			pc_xu_msrovride_pr,
   output                    			pc_xu_msrovride_gs,
   output                    			pc_xu_msrovride_de,
   output                    			pc_iu_ram_force_cmplt,
   output [0:`THREADS-1]     			pc_iu_ram_flush_thread,
   // THRCTL + PCCR0 Registers
   input                     			an_ac_debug_stop,
   input  [0:`THREADS-1]     			xu_pc_running,
   input  [0:`THREADS-1]     			iu_pc_stop_dbg_event,
   input  [0:`THREADS-1]     			xu_pc_stop_dnh_instr,
   input  [0:`THREADS-1]     			iu_pc_step_done,
   output [0:`THREADS-1]     			pc_iu_stop,
   output [0:`THREADS-1]     			pc_iu_step,
   output                    			pc_xu_extirpts_dis_on_stop,
   output                    			pc_xu_timebase_dis_on_stop,
   output                    			pc_xu_decrem_dis_on_stop,
   output [0:3*`THREADS-1]   			pc_iu_dbg_action,
   output [0:`THREADS-1]     			pc_iu_spr_dbcr0_edm,
   output [0:`THREADS-1]     			pc_xu_spr_dbcr0_edm,
   //Debug Bus Controls
   output                    			pc_iu_trace_bus_enable,
   output                    			pc_rv_trace_bus_enable,
   output                    			pc_mm_trace_bus_enable,
   output                    			pc_xu_trace_bus_enable,
   output                    			pc_lq_trace_bus_enable,
   output [0:10]             			pc_iu_debug_mux1_ctrls,
   output [0:10]             			pc_iu_debug_mux2_ctrls,
   output [0:10]             			pc_rv_debug_mux_ctrls,
   output [0:10]             			pc_mm_debug_mux_ctrls,
   output [0:10]             			pc_xu_debug_mux_ctrls,
   output [0:10]             			pc_lq_debug_mux1_ctrls,
   output [0:10]             			pc_lq_debug_mux2_ctrls,
   // Event Bus Controls
   output [0:39]             			pc_rv_event_mux_ctrls,
   output                    			pc_iu_event_bus_enable,
   output                    			pc_rv_event_bus_enable,
   output                    			pc_mm_event_bus_enable,
   output                    			pc_xu_event_bus_enable,
   output                    			pc_lq_event_bus_enable,
   output [0:2]              			pc_iu_event_count_mode,
   output [0:2]              			pc_rv_event_count_mode,
   output [0:2]              			pc_mm_event_count_mode,
   output [0:2]              			pc_xu_event_count_mode,
   output [0:2]              			pc_lq_event_count_mode,
   output                    			pc_iu_instr_trace_mode,
   output                    			pc_iu_instr_trace_tid,
   output                    			pc_lq_instr_trace_mode,
   output                    			pc_lq_instr_trace_tid,
   output                    			pc_xu_instr_trace_mode,
   output                    			pc_xu_instr_trace_tid,
   input  [0:`THREADS-1]     			xu_pc_perfmon_alert,
   output [0:`THREADS-1]     			pc_xu_spr_cesr1_pmae,
   output                    			pc_lq_event_bus_seldbghi,
   output                    			pc_lq_event_bus_seldbglo,
   // Reset related
   output                    			pc_lq_init_reset,
   output                    			pc_iu_init_reset,
   // Power Management
   output [0:`THREADS-1]     			ac_an_pm_thread_running,
   input  [0:`THREADS-1]     			an_ac_pm_thread_stop,
   input  [0:`THREADS-1]     			an_ac_pm_fetch_halt,
   output [0:`THREADS-1]       			pc_iu_pm_fetch_halt,
   output                    			ac_an_power_managed,
   output                    			ac_an_rvwinkle_mode,
   output                    			pc_xu_pm_hold_thread,
   input  [0:1]              			xu_pc_spr_ccr0_pme,
   input  [0:`THREADS-1]     			xu_pc_spr_ccr0_we,
   // Clock, Test, and LCB Controls
   input                     			an_ac_gsd_test_enable_dc,
   input                     			an_ac_gsd_test_acmode_dc,
   input                     			an_ac_ccflush_dc,
   input                     			an_ac_ccenable_dc,
   input                     			an_ac_lbist_en_dc,
   input                     			an_ac_lbist_ip_dc,
   input                     			an_ac_lbist_ac_mode_dc,
   input                     			an_ac_scan_diag_dc,
   input                     			an_ac_scan_dis_dc_b,
   input                     			an_ac_rtim_sl_thold_7,
   input                     			an_ac_func_sl_thold_7,
   input                     			an_ac_func_nsl_thold_7,
   input                     			an_ac_ary_nsl_thold_7,
   input                     			an_ac_sg_7,
   input                     			an_ac_fce_7,
   input  [0:8]              			an_ac_scan_type_dc,
   //Thold outputs to clock staging
   output                    			pc_rp_ccflush_out_dc,
   output                    			pc_rp_gptr_sl_thold_4,
   output                    			pc_rp_time_sl_thold_4,
   output                    			pc_rp_repr_sl_thold_4,
   output                    			pc_rp_abst_sl_thold_4,
   output                    			pc_rp_abst_slp_sl_thold_4,
   output                    			pc_rp_regf_sl_thold_4,
   output                    			pc_rp_regf_slp_sl_thold_4,
   output                    			pc_rp_func_sl_thold_4,
   output                    			pc_rp_func_slp_sl_thold_4,
   output                    			pc_rp_cfg_sl_thold_4,
   output                    			pc_rp_cfg_slp_sl_thold_4,
   output                    			pc_rp_func_nsl_thold_4,
   output                    			pc_rp_func_slp_nsl_thold_4,
   output                    			pc_rp_ary_nsl_thold_4,
   output                    			pc_rp_ary_slp_nsl_thold_4,
   output                    			pc_rp_rtim_sl_thold_4,
   output                    			pc_rp_sg_4,
   output                    			pc_rp_fce_4

);


   // ###################### CONSTANTS ###################### --
   parameter                                    float_type = 1;



   // ####################### SIGNALS ####################### --
   // Internal Connections Between PC + FU
   wire   [0:`THREADS-1]                 	pc_fu_ram_active;
   wire   [0:63]                        	fu_pc_ram_data;
   wire                                 	fu_pc_ram_data_val;

   wire                                 	pc_fu_trace_bus_enable;
   wire   [0:10]                         	pc_fu_debug_mux_ctrls;
   wire                                 	pc_fu_instr_trace_mode;
   wire   [0:1]                          	pc_fu_instr_trace_tid;

   wire                                 	pc_fu_event_bus_enable;
   wire   [0:2]                          	pc_fu_event_count_mode;

   wire   [0:`THREADS-1]                       	pc_fu_inj_regfile_parity;
   wire   [0:`THREADS-1]                	fu_pc_err_regfile_parity;
   wire   [0:`THREADS-1]                	fu_pc_err_regfile_ue;

   wire                                 	pc_fu_ccflush_dc;
   wire                                 	pc_fu_gptr_sl_thold_3;
   wire                                 	pc_fu_time_sl_thold_3;
   wire                                 	pc_fu_repr_sl_thold_3;
   wire                                 	pc_fu_cfg_sl_thold_3;
   wire                                 	pc_fu_cfg_slp_sl_thold_3;
   wire                                 	pc_fu_func_nsl_thold_3;
   wire   [0:1]                          	pc_fu_func_sl_thold_3;
   wire                                 	pc_fu_func_slp_nsl_thold_3;
   wire   [0:1]                          	pc_fu_func_slp_sl_thold_3;
   wire                                 	pc_fu_abst_sl_thold_3;
   wire                                 	pc_fu_abst_slp_sl_thold_3;
   wire                                 	pc_fu_ary_nsl_thold_3;
   wire                                 	pc_fu_ary_slp_nsl_thold_3;
   wire   [0:1]                          	pc_fu_sg_3;
   wire                                 	pc_fu_fce_3;



   assign pc_fu_instr_trace_mode 	= 1'b0;
   assign pc_fu_instr_trace_tid[0:1] 	= 2'b00;


   // ####################### START ######################### --
   pcq
        pc0(
		// .vdd(vdd),
		// .gnd(gnd),
		.nclk(nclk),
		//SCOM Satellite
		.an_ac_scom_sat_id(an_ac_scom_sat_id),
		.an_ac_scom_dch(an_ac_scom_dch),
		.an_ac_scom_cch(an_ac_scom_cch),
		.ac_an_scom_dch(ac_an_scom_dch),
		.ac_an_scom_cch(ac_an_scom_cch),
		//Slow SPR
		.cp_flush(cp_flush),
		.slowspr_addr_in(pc_slowspr_addr_in),
		.slowspr_data_in(pc_slowspr_data_in),
		.slowspr_done_in(pc_slowspr_done_in),
		.slowspr_etid_in(pc_slowspr_etid_in),
		.slowspr_rw_in(pc_slowspr_rw_in),
		.slowspr_val_in(pc_slowspr_val_in),
		.slowspr_addr_out(pc_slowspr_addr_out),
		.slowspr_data_out(pc_slowspr_data_out),
		.slowspr_done_out(pc_slowspr_done_out),
		.slowspr_etid_out(pc_slowspr_etid_out),
		.slowspr_rw_out(pc_slowspr_rw_out),
		.slowspr_val_out(pc_slowspr_val_out),
		// FIR and Error Signals
		.ac_an_special_attn(ac_an_special_attn),
		.ac_an_checkstop(ac_an_checkstop),
		.ac_an_local_checkstop(ac_an_local_checkstop),
		.ac_an_recov_err(ac_an_recov_err),
		.ac_an_trace_error(ac_an_trace_error),
      		.ac_an_livelock_active(ac_an_livelock_active),
		.an_ac_checkstop(an_ac_checkstop),
		.fu_pc_err_regfile_parity(fu_pc_err_regfile_parity),
		.fu_pc_err_regfile_ue(fu_pc_err_regfile_ue),
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
		.mm_pc_err_tlb_parity(mm_pc_err_tlb_parity),
		.mm_pc_err_tlb_lru_parity(mm_pc_err_tlb_lru_parity),
		.mm_pc_err_tlb_multihit(mm_pc_err_tlb_multihit),
		.mm_pc_err_local_snoop_reject(mm_pc_err_local_snoop_reject),
		.xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
		.xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
		.xu_pc_err_regfile_parity(xu_pc_err_regfile_parity),
		.xu_pc_err_regfile_ue(xu_pc_err_regfile_ue),
		.xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
		.xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),
		.xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),
		.pc_fu_inj_regfile_parity(pc_fu_inj_regfile_parity),
      		.pc_iu_inj_cpArray_parity(pc_iu_inj_cpArray_parity),
		.pc_iu_inj_icache_parity(pc_iu_inj_icache_parity),
		.pc_iu_inj_icachedir_parity(pc_iu_inj_icachedir_parity),
		.pc_iu_inj_icachedir_multihit(pc_iu_inj_icachedir_multihit),
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
		// RAM Command/Data
		.pc_iu_ram_instr(pc_iu_ram_instr),
		.pc_iu_ram_instr_ext(pc_iu_ram_instr_ext),
		.pc_iu_ram_active(pc_iu_ram_active),
		.pc_iu_ram_execute(pc_iu_ram_issue),
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
		// THRCTL + PCCR0 Registers
		.xu_pc_running(xu_pc_running),
		.iu_pc_stop_dbg_event(iu_pc_stop_dbg_event),
		.xu_pc_stop_dnh_instr(xu_pc_stop_dnh_instr),
		.iu_pc_step_done(iu_pc_step_done),
		.pc_iu_stop(pc_iu_stop),
		.pc_iu_step(pc_iu_step),
		.pc_xu_extirpts_dis_on_stop(pc_xu_extirpts_dis_on_stop),
		.pc_xu_timebase_dis_on_stop(pc_xu_timebase_dis_on_stop),
		.pc_xu_decrem_dis_on_stop(pc_xu_decrem_dis_on_stop),
		.an_ac_debug_stop(an_ac_debug_stop),
		.pc_iu_dbg_action(pc_iu_dbg_action),
		.pc_iu_spr_dbcr0_edm(pc_iu_spr_dbcr0_edm),
		.pc_xu_spr_dbcr0_edm(pc_xu_spr_dbcr0_edm),

		// Trace/Debug Bus
		.debug_bus_in(pc_debug_bus_in),
 		.debug_bus_out(pc_debug_bus_out),
      		.coretrace_ctrls_in(pc_coretrace_ctrls_in),
      		.coretrace_ctrls_out(pc_coretrace_ctrls_out),
		//Debug Select Register outputs to units for debug grouping
		.pc_fu_trace_bus_enable(pc_fu_trace_bus_enable),
		.pc_iu_trace_bus_enable(pc_iu_trace_bus_enable),
		.pc_rv_trace_bus_enable(pc_rv_trace_bus_enable),
		.pc_mm_trace_bus_enable(pc_mm_trace_bus_enable),
		.pc_xu_trace_bus_enable(pc_xu_trace_bus_enable),
		.pc_lq_trace_bus_enable(pc_lq_trace_bus_enable),
		.pc_iu_debug_mux1_ctrls(pc_iu_debug_mux1_ctrls),
		.pc_iu_debug_mux2_ctrls(pc_iu_debug_mux2_ctrls),
		.pc_fu_debug_mux_ctrls(pc_fu_debug_mux_ctrls),
		.pc_rv_debug_mux_ctrls(pc_rv_debug_mux_ctrls),
		.pc_mm_debug_mux_ctrls(pc_mm_debug_mux_ctrls),
		.pc_xu_debug_mux_ctrls(pc_xu_debug_mux_ctrls),
		.pc_lq_debug_mux1_ctrls(pc_lq_debug_mux1_ctrls),
		.pc_lq_debug_mux2_ctrls(pc_lq_debug_mux2_ctrls),

		// Performance Bus and Event Mux Controls
		.pc_rv_event_mux_ctrls(pc_rv_event_mux_ctrls),
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
		.pc_lq_event_bus_seldbghi(pc_lq_event_bus_seldbghi),
		.pc_lq_event_bus_seldbglo(pc_lq_event_bus_seldbglo),
		.pc_iu_instr_trace_mode(pc_iu_instr_trace_mode),
		.pc_iu_instr_trace_tid(pc_iu_instr_trace_tid),
		.pc_lq_instr_trace_mode(pc_lq_instr_trace_mode),
		.pc_lq_instr_trace_tid(pc_lq_instr_trace_tid),
		.pc_xu_instr_trace_mode(pc_xu_instr_trace_mode),
		.pc_xu_instr_trace_tid(pc_xu_instr_trace_tid),
		.xu_pc_perfmon_alert(xu_pc_perfmon_alert),
		.pc_xu_spr_cesr1_pmae(pc_xu_spr_cesr1_pmae),
		// Reset related
		.pc_lq_init_reset(pc_lq_init_reset),
		.pc_iu_init_reset(pc_iu_init_reset),

		// Power Management
		.ac_an_pm_thread_running(ac_an_pm_thread_running),
		.an_ac_pm_thread_stop(an_ac_pm_thread_stop),
		.an_ac_pm_fetch_halt(an_ac_pm_fetch_halt),
      		.pc_iu_pm_fetch_halt(pc_iu_pm_fetch_halt),
		.ac_an_power_managed(ac_an_power_managed),
		.ac_an_rvwinkle_mode(ac_an_rvwinkle_mode),
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
		//Thold input to clock control macro
		.an_ac_rtim_sl_thold_7(an_ac_rtim_sl_thold_7),
		.an_ac_func_sl_thold_7(an_ac_func_sl_thold_7),
		.an_ac_func_nsl_thold_7(an_ac_func_nsl_thold_7),
		.an_ac_ary_nsl_thold_7(an_ac_ary_nsl_thold_7),
		.an_ac_sg_7(an_ac_sg_7),
		.an_ac_fce_7(an_ac_fce_7),
		.an_ac_scan_type_dc(an_ac_scan_type_dc),
		//Clock control outputs to clock staging logic
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
     		.pc_fu_ccflush_dc(pc_fu_ccflush_dc),
     		.pc_fu_gptr_sl_thold_3(pc_fu_gptr_sl_thold_3),
     		.pc_fu_time_sl_thold_3(pc_fu_time_sl_thold_3),
     		.pc_fu_repr_sl_thold_3(pc_fu_repr_sl_thold_3),
     		.pc_fu_cfg_sl_thold_3(pc_fu_cfg_sl_thold_3),
     		.pc_fu_cfg_slp_sl_thold_3(pc_fu_cfg_slp_sl_thold_3),
     		.pc_fu_func_nsl_thold_3(pc_fu_func_nsl_thold_3),
     		.pc_fu_func_sl_thold_3(pc_fu_func_sl_thold_3),
     		.pc_fu_func_slp_nsl_thold_3(pc_fu_func_slp_nsl_thold_3),
     		.pc_fu_func_slp_sl_thold_3(pc_fu_func_slp_sl_thold_3),
     		.pc_fu_abst_sl_thold_3(pc_fu_abst_sl_thold_3),
     		.pc_fu_abst_slp_sl_thold_3(pc_fu_abst_slp_sl_thold_3),
     		.pc_fu_ary_nsl_thold_3(pc_fu_ary_nsl_thold_3),
     		.pc_fu_ary_slp_nsl_thold_3(pc_fu_ary_slp_nsl_thold_3),
     		.pc_fu_sg_3(pc_fu_sg_3),
     		.pc_fu_fce_3(pc_fu_fce_3),

		// Scanning
		.gptr_scan_in(pc_gptr_scan_in),
		.ccfg_scan_in(pc_ccfg_scan_in),
		.bcfg_scan_in(pc_bcfg_scan_in),
		.dcfg_scan_in(pc_dcfg_scan_in),
		.func_scan_in(pc_func_scan_in),
		.gptr_scan_out(pc_gptr_scan_out),
		.ccfg_scan_out(pc_ccfg_scan_out),
		.bcfg_scan_out(pc_bcfg_scan_out),
		.dcfg_scan_out(pc_dcfg_scan_out),
		.func_scan_out(pc_func_scan_out)
	   );



   // DP Float
   generate
      if (float_type == 1)
	begin : dp
                fu
	   a_fuq(
		 //.gnd(gnd),
		 //.vcs(vcs),
		 //.vdd(vdd),
		 .nclk(nclk),

		 .debug_bus_in(fu_debug_bus_in),
 		 .debug_bus_out(fu_debug_bus_out),
      		 .coretrace_ctrls_in(fu_coretrace_ctrls_in),
      		 .coretrace_ctrls_out(fu_coretrace_ctrls_out),
   	         .event_bus_in(fu_event_bus_in),
   	         .event_bus_out(fu_event_bus_out),

		 .gptr_scan_in(fu_gptr_scan_in),
		 .time_scan_in(fu_time_scan_in),
		 .repr_scan_in(fu_repr_scan_in),
		 .bcfg_scan_in(fu_bcfg_scan_in),
		 .ccfg_scan_in(fu_ccfg_scan_in),
		 .dcfg_scan_in(fu_dcfg_scan_in),
		 .func_scan_in(fu_func_scan_in),
		 .abst_scan_in(fu_abst_scan_in),
		 .gptr_scan_out(fu_gptr_scan_out),
		 .time_scan_out(fu_time_scan_out),
		 .repr_scan_out(fu_repr_scan_out),
		 .bcfg_scan_out(fu_bcfg_scan_out),
		 .ccfg_scan_out(fu_ccfg_scan_out),
		 .dcfg_scan_out(fu_dcfg_scan_out),
		 .func_scan_out(fu_func_scan_out),
		 .abst_scan_out(fu_abst_scan_out),
		 .tc_ac_scan_dis_dc_b(an_ac_scan_dis_dc_b),
		 .tc_ac_scan_diag_dc(an_ac_scan_diag_dc),

		 .cp_flush(cp_flush),
		 .slowspr_addr_in(fu_slowspr_addr_in),
		 .slowspr_data_in(fu_slowspr_data_in),
		 .slowspr_done_in(fu_slowspr_done_in),
		 .slowspr_etid_in(fu_slowspr_etid_in),
		 .slowspr_rw_in(fu_slowspr_rw_in),
		 .slowspr_val_in(fu_slowspr_val_in),
		 .slowspr_addr_out(fu_slowspr_addr_out),
		 .slowspr_data_out(fu_slowspr_data_out),
		 .slowspr_done_out(fu_slowspr_done_out),
		 .slowspr_etid_out(fu_slowspr_etid_out),
		 .slowspr_rw_out(fu_slowspr_rw_out),
		 .slowspr_val_out(fu_slowspr_val_out),

		 .cp_t0_next_itag(cp_t0_next_itag),
		 .cp_t1_next_itag(cp_t1_next_itag),
		 .cp_axu_i0_t1_v(cp_axu_i0_t1_v),
		 .cp_axu_i0_t0_t1_t(cp_axu_i0_t0_t1_t),
		 .cp_axu_i0_t0_t1_p(cp_axu_i0_t0_t1_p),
		 .cp_axu_i1_t0_t1_t(cp_axu_i1_t0_t1_t),
		 .cp_axu_i1_t0_t1_p(cp_axu_i1_t0_t1_p),
		 .cp_axu_i1_t1_v(cp_axu_i1_t1_v),
		 .cp_axu_i0_t1_t1_t(cp_axu_i0_t1_t1_t),
		 .cp_axu_i0_t1_t1_p(cp_axu_i0_t1_t1_p),
		 .cp_axu_i1_t1_t1_t(cp_axu_i1_t1_t1_t),
		 .cp_axu_i1_t1_t1_p(cp_axu_i1_t1_t1_p),

		 .iu_xx_t0_zap_itag(iu_xx_t0_zap_itag),
		 .iu_xx_t1_zap_itag(iu_xx_t1_zap_itag),
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
		 .axu1_iu_np1_flush(axu1_iu_np1_flush),
		 .axu1_iu_n_flush(axu1_iu_n_flush),

		 .lq_fu_ex4_eff_addr(lq_fu_ex4_eff_addr),
		 .lq_fu_ex5_load_le(lq_fu_ex5_load_le),
		 .lq_fu_ex5_load_data(lq_fu_ex5_load_data),
		 .lq_fu_ex5_load_tag(lq_fu_ex5_load_tag),
		 .lq_fu_ex5_load_val(lq_fu_ex5_load_val),
     	         .lq_fu_ex5_abort(lq_fu_ex5_abort),
		 .lq_gpr_rel_we(lq_gpr_rel_we),
		 .lq_gpr_rel_le(lq_gpr_rel_le),
		 .lq_gpr_rel_wa(lq_gpr_rel_wa),
		 .lq_gpr_rel_wd(lq_gpr_rel_wd),
		 .lq_rv_itag0(lq_rv_itag0),
		 .lq_rv_itag0_vld(lq_rv_itag0_vld),
		 .lq_rv_itag0_spec(lq_rv_itag0_spec),
		 .lq_rv_itag1_restart(lq_rv_itag1_restart),
		 .fu_lq_ex2_store_data_val(fu_lq_ex2_store_data_val),
		 .fu_lq_ex2_store_itag(fu_lq_ex2_store_itag),
		 .fu_lq_ex3_store_data(fu_lq_ex3_store_data),
		 .fu_lq_ex3_sto_parity_err(fu_lq_ex3_sto_parity_err),
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

		 .pc_fu_ram_active(pc_fu_ram_active),
		 .fu_pc_ram_data(fu_pc_ram_data),
		 .fu_pc_ram_data_val(fu_pc_ram_data_val),
		 .pc_fu_trace_bus_enable(pc_fu_trace_bus_enable),
		 .pc_fu_debug_mux_ctrls(pc_fu_debug_mux_ctrls),
		 .pc_fu_instr_trace_mode(pc_fu_instr_trace_mode),
		 .pc_fu_instr_trace_tid(pc_fu_instr_trace_tid),
		 .pc_fu_event_bus_enable(pc_fu_event_bus_enable),
		 .pc_fu_event_count_mode(pc_fu_event_count_mode),
		 .pc_fu_inj_regfile_parity(pc_fu_inj_regfile_parity),
		 .fu_pc_err_regfile_parity(fu_pc_err_regfile_parity),
		 .fu_pc_err_regfile_ue(fu_pc_err_regfile_ue),
		 .an_ac_lbist_en_dc(an_ac_lbist_en_dc),
		 .pc_fu_ccflush_dc(pc_fu_ccflush_dc),
		 .pc_fu_gptr_sl_thold_3(pc_fu_gptr_sl_thold_3),
		 .pc_fu_time_sl_thold_3(pc_fu_time_sl_thold_3),
		 .pc_fu_repr_sl_thold_3(pc_fu_repr_sl_thold_3),
		 .pc_fu_cfg_sl_thold_3(pc_fu_cfg_sl_thold_3),
		 .pc_fu_cfg_slp_sl_thold_3(pc_fu_cfg_slp_sl_thold_3),
		 .pc_fu_func_nsl_thold_3(pc_fu_func_nsl_thold_3),
		 .pc_fu_func_sl_thold_3(pc_fu_func_sl_thold_3),
		 .pc_fu_func_slp_nsl_thold_3(pc_fu_func_slp_nsl_thold_3),
		 .pc_fu_func_slp_sl_thold_3(pc_fu_func_slp_sl_thold_3),
		 .pc_fu_abst_sl_thold_3(pc_fu_abst_sl_thold_3),
		 .pc_fu_abst_slp_sl_thold_3(pc_fu_abst_slp_sl_thold_3),
		 .pc_fu_ary_nsl_thold_3(pc_fu_ary_nsl_thold_3),
		 .pc_fu_ary_slp_nsl_thold_3(pc_fu_ary_slp_nsl_thold_3),
		 .pc_fu_sg_3(pc_fu_sg_3),
		 .pc_fu_fce_3(pc_fu_fce_3),

		 .pc_fu_abist_di_0(pc_fu_abist_di_0),
		 .pc_fu_abist_di_1(pc_fu_abist_di_1),
		 .pc_fu_abist_ena_dc(pc_fu_abist_ena_dc),
		 .pc_fu_abist_grf_renb_0(pc_fu_abist_grf_renb_0),
		 .pc_fu_abist_grf_renb_1(pc_fu_abist_grf_renb_1),
		 .pc_fu_abist_grf_wenb_0(pc_fu_abist_grf_wenb_0),
		 .pc_fu_abist_grf_wenb_1(pc_fu_abist_grf_wenb_1),
		 .pc_fu_abist_raddr_0(pc_fu_abist_raddr_0),
		 .pc_fu_abist_raddr_1(pc_fu_abist_raddr_1),
		 .pc_fu_abist_raw_dc_b(pc_fu_abist_raw_dc_b),
		 .pc_fu_abist_waddr_0(pc_fu_abist_waddr_0),
		 .pc_fu_abist_waddr_1(pc_fu_abist_waddr_1),
		 .pc_fu_abist_wl144_comp_ena(pc_fu_abist_wl144_comp_ena),

		 .xu_fu_msr_fe0(xu_fu_msr_fe0),
		 .xu_fu_msr_fe1(xu_fu_msr_fe1),
		 .xu_fu_msr_fp(xu_fu_msr_fp),
		 .xu_fu_msr_pr(xu_fu_msr_pr),
		 .xu_fu_msr_gs(xu_fu_msr_gs),
		 .axu0_cr_w4e(axu0_cr_w4e),
		 .axu0_cr_w4a(axu0_cr_w4a),
		 .axu0_cr_w4d(axu0_cr_w4d)

	 );
	end
   endgenerate
   // end component a_fuq

   // No Float!
   generate
      if (float_type == 0)
	begin : nf
           assign axu0_iu_execute_vld       = {`THREADS{1'b0}};
           assign axu0_iu_itag              = {`ITAG_SIZE_ENC{1'b0}};
           assign axu0_iu_n_flush           = 1'b0;
           assign axu0_iu_np1_flush         = 1'b0;
           assign axu0_iu_exception         = {4{1'b0}};
           assign axu0_iu_exception_val     = 1'b0;
           assign axu0_iu_flush2ucode       = 1'b0;
           assign axu0_iu_flush2ucode_type  = 1'b0;
           assign axu0_iu_async_fex         = {`THREADS{1'b0}};
           assign axu0_iu_perf_events       = {4{1'b0}};

           assign axu1_iu_execute_vld       = {`THREADS{1'b0}};
           assign axu1_iu_itag              = {`ITAG_SIZE_ENC{1'b0}};
           assign axu1_iu_n_flush           = 1'b0;
           assign axu1_iu_np1_flush         = 1'b0;
           assign axu1_iu_exception         = {4{1'b0}};
           assign axu1_iu_exception_val     = 1'b0;
           assign axu1_iu_flush2ucode       = 1'b0;
           assign axu1_iu_flush2ucode_type  = 1'b0;
           assign axu1_iu_perf_events       = {4{1'b0}};

           assign axu0_rv_itag_vld          = {`THREADS{1'b0}};
           assign axu1_rv_itag_vld          = {`THREADS{1'b0}};

           assign fu_slowspr_val_out  	    = fu_slowspr_val_in;
           assign fu_slowspr_rw_out   	    = fu_slowspr_rw_in;
           assign fu_slowspr_etid_out 	    = fu_slowspr_etid_in;
           assign fu_slowspr_addr_out 	    = fu_slowspr_addr_in;
           assign fu_slowspr_data_out 	    = fu_slowspr_data_in;
           assign fu_slowspr_done_out 	    = fu_slowspr_done_in;

           assign fu_debug_bus_out 	    = fu_debug_bus_in;
           assign fu_coretrace_ctrls_out    = fu_coretrace_ctrls_in;

	   assign fu_event_bus_out          = fu_event_bus_in;

           assign fu_pc_err_regfile_parity  = {`THREADS{1'b0}};
           assign fu_pc_err_regfile_ue      = {`THREADS{1'b0}};

           assign fu_lq_ex3_abort           = 1'b0;
           assign axu0_rv_ex2_s1_abort      = 1'b0;
           assign axu0_rv_ex2_s2_abort      = 1'b0;
           assign axu0_rv_ex2_s3_abort      = 1'b0;

           assign fu_pc_ram_data_val        = 1'b0;
	end
   endgenerate

endmodule
