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
//  Description: Pervasive Core Registers + Error Reporting
//
//*****************************************************************************

module pcq_regs(
// Include model build parameters
`include "tri_a2o.vh"

   inout                       	vdd,
   inout                       	gnd,
   input  [0:`NCLK_WIDTH-1]    	nclk,
   input                       	scan_dis_dc_b,
   input                       	lcb_clkoff_dc_b,
   input                       	lcb_d_mode_dc,
   input                       	lcb_mpw1_dc_b,
   input                       	lcb_mpw2_dc_b,
   input                       	lcb_delay_lclkr_dc,
   input                       	lcb_act_dis_dc,
   input                       	lcb_func_slp_sl_thold_0,
   input                       	lcb_cfg_sl_thold_0,
   input                       	lcb_cfg_slp_sl_thold_0,
   input                       	lcb_sg_0,
   input                       	ccfg_scan_in,
   input                       	bcfg_scan_in,
   input                       	dcfg_scan_in,
   input                       	func_scan_in,
   output                      	ccfg_scan_out,
   output                      	bcfg_scan_out,
   output                      	dcfg_scan_out,
   output                      	func_scan_out,
   //SCOM Satellite Interface
   input  [0:3]                	an_ac_scom_sat_id,
   input                       	an_ac_scom_dch,
   input                       	an_ac_scom_cch,
   output                      	ac_an_scom_dch,
   output                      	ac_an_scom_cch,
   //FIR and Error Signals
   output [0:`THREADS-1]       	ac_an_special_attn,
   output [0:2]                	ac_an_checkstop,
   output [0:2]                	ac_an_local_checkstop,
   output [0:2]                	ac_an_recov_err,
   output                      	ac_an_trace_error,
   output                      	rg_ck_fast_xstop,
   output                       ac_an_livelock_active,
   input                       	an_ac_checkstop,
   input  [0:`THREADS-1]       	fu_pc_err_regfile_parity,
   input  [0:`THREADS-1]       	fu_pc_err_regfile_ue,
   input                       	iu_pc_err_icache_parity,
   input                       	iu_pc_err_icachedir_parity,
   input                       	iu_pc_err_icachedir_multihit,
   input                       	iu_pc_err_ierat_parity,
   input                       	iu_pc_err_ierat_multihit,
   input                     	iu_pc_err_btb_parity,
   input  [0:`THREADS-1]     	iu_pc_err_cpArray_parity,
   input  [0:`THREADS-1]       	iu_pc_err_ucode_illegal,
   input  [0:`THREADS-1]       	iu_pc_err_mchk_disabled,
   input  [0:`THREADS-1]       	iu_pc_err_debug_event,
   input                       	lq_pc_err_dcache_parity,
   input                       	lq_pc_err_dcachedir_ldp_parity,
   input                       	lq_pc_err_dcachedir_stp_parity,
   input                       	lq_pc_err_dcachedir_ldp_multihit,
   input                       	lq_pc_err_dcachedir_stp_multihit,
   input                       	lq_pc_err_derat_parity,
   input                       	lq_pc_err_derat_multihit,
   input                       	lq_pc_err_l2intrf_ecc,
   input                       	lq_pc_err_l2intrf_ue,
   input                       	lq_pc_err_invld_reld,
   input                       	lq_pc_err_l2credit_overrun,
   input  [0:`THREADS-1]       	lq_pc_err_regfile_parity,
   input  [0:`THREADS-1]       	lq_pc_err_regfile_ue,
   input                       	lq_pc_err_prefetcher_parity,
   input                        lq_pc_err_relq_parity,
   input                       	mm_pc_err_tlb_parity,
   input                       	mm_pc_err_tlb_multihit,
   input                       	mm_pc_err_tlb_lru_parity,
   input                       	mm_pc_err_local_snoop_reject,
   input  [0:`THREADS-1]       	xu_pc_err_sprg_ecc,
   input  [0:`THREADS-1]       	xu_pc_err_sprg_ue,
   input  [0:`THREADS-1]       	xu_pc_err_regfile_parity,
   input  [0:`THREADS-1]       	xu_pc_err_regfile_ue,
   input  [0:`THREADS-1]       	xu_pc_err_llbust_attempt,
   input  [0:`THREADS-1]       	xu_pc_err_llbust_failed,
   input  [0:`THREADS-1]       	xu_pc_err_wdt_reset,
   input  [0:`THREADS-1]       	iu_pc_err_attention_instr,
   output                      	pc_iu_inj_icache_parity,
   output                      	pc_iu_inj_icachedir_parity,
   output                      	pc_iu_inj_icachedir_multihit,
   output                      	pc_lq_inj_dcache_parity,
   output                      	pc_lq_inj_dcachedir_ldp_parity,
   output                      	pc_lq_inj_dcachedir_stp_parity,
   output                      	pc_lq_inj_dcachedir_ldp_multihit,
   output                      	pc_lq_inj_dcachedir_stp_multihit,
   output                      	pc_lq_inj_prefetcher_parity,
   output			pc_lq_inj_relq_parity,
   output [0:`THREADS-1]       	pc_xu_inj_sprg_ecc,
   output [0:`THREADS-1]       	pc_fx0_inj_regfile_parity,
   output [0:`THREADS-1]       	pc_fx1_inj_regfile_parity,
   output [0:`THREADS-1]       	pc_lq_inj_regfile_parity,
   output [0:`THREADS-1]       	pc_fu_inj_regfile_parity,
   output [0:`THREADS-1]       	pc_xu_inj_llbust_attempt,
   output [0:`THREADS-1]       	pc_xu_inj_llbust_failed,
   output [0:`THREADS-1]     	pc_iu_inj_cpArray_parity,
   //  -- Unit quiesce and credit status bits
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
   //SCOM Register Interfaces
   //  -- RAM Command/Data
   output [0:31]               	pc_iu_ram_instr,
   output [0:3]                	pc_iu_ram_instr_ext,
   output [0:`THREADS-1]       	pc_iu_ram_active,
   output                      	pc_iu_ram_execute,
   input                       	iu_pc_ram_done,
   input                       	iu_pc_ram_interrupt,
   input                       	iu_pc_ram_unsupported,
   output [0:`THREADS-1]       	pc_xu_ram_active,
   input                       	xu_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63]   	xu_pc_ram_data,
   output [0:`THREADS-1]       	pc_fu_ram_active,
   input                       	fu_pc_ram_data_val,
   input  [0:63]               	fu_pc_ram_data,
   output [0:`THREADS-1]       	pc_lq_ram_active,
   input                       	lq_pc_ram_data_val,
   input  [64-`GPR_WIDTH:63]   	lq_pc_ram_data,
   output                      	pc_xu_msrovride_enab,
   output                      	pc_xu_msrovride_pr,
   output                      	pc_xu_msrovride_gs,
   output                      	pc_xu_msrovride_de,
   output                      	pc_iu_ram_force_cmplt,
   output [0:`THREADS-1]       	pc_iu_ram_flush_thread,
   output                      	rg_rg_load_sramd,
   output [0:63]               	rg_rg_sramd_din,
   //  -- THRCTL + PCCR0 Register
   output [0:`THREADS-1]       	ac_an_pm_thread_running,
   output [0:`THREADS-1]       	pc_iu_stop,
   output [0:`THREADS-1]       	pc_iu_step,
   output [0:3*`THREADS-1]     	pc_iu_dbg_action,
   output [0:`THREADS-1]       	pc_iu_spr_dbcr0_edm,
   output [0:`THREADS-1]       	pc_xu_spr_dbcr0_edm,
   input  [0:`THREADS-1]       	xu_pc_running,
   input  [0:`THREADS-1]       	iu_pc_stop_dbg_event,
   input  [0:`THREADS-1]       	xu_pc_stop_dnh_instr,
   input  [0:`THREADS-1]       	iu_pc_step_done,
   input  [0:`THREADS-1]     	an_ac_pm_thread_stop,
   input  [0:`THREADS-1]       	an_ac_pm_fetch_halt,
   output [0:`THREADS-1]       	pc_iu_pm_fetch_halt,
   input  [0:`THREADS-1]       	ct_rg_power_managed,
   input                       	ct_rg_hold_during_init,
   input                       	an_ac_debug_stop,
   output                      	pc_xu_extirpts_dis_on_stop,
   output                      	pc_xu_timebase_dis_on_stop,
   output                      	pc_xu_decrem_dis_on_stop,
   output                      	rg_ct_dis_pwr_savings,
   //  --Debug Select Register outputs to units for debug grouping
   input                       	sp_rg_trace_bus_enable,
   output                      	rg_db_trace_bus_enable,
   output                      	pc_iu_trace_bus_enable,
   output                      	pc_fu_trace_bus_enable,
   output                      	pc_rv_trace_bus_enable,
   output                      	pc_mm_trace_bus_enable,
   output                      	pc_xu_trace_bus_enable,
   output                      	pc_lq_trace_bus_enable,
   output [0:10]               	rg_db_debug_mux_ctrls,
   output [0:10]               	pc_iu_debug_mux1_ctrls,
   output [0:10]               	pc_iu_debug_mux2_ctrls,
   output [0:10]               	pc_fu_debug_mux_ctrls,
   output [0:10]               	pc_rv_debug_mux_ctrls,
   output [0:10]               	pc_mm_debug_mux_ctrls,
   output [0:10]               	pc_xu_debug_mux_ctrls,
   output [0:10]               	pc_lq_debug_mux1_ctrls,
   output [0:10]               	pc_lq_debug_mux2_ctrls,
   //Debug Signals to Trace Muxes
   output [0:11]               	dbg_scom,
   output [0:24]		dbg_thrctls,
   output [0:15]		dbg_ram,
   output [0:27]               	dbg_fir0_err,
   output [0:19]               	dbg_fir1_err,
   output [0:19]  	       	dbg_fir2_err,
   output [0:14]	       	dbg_fir_misc
);


//=====================================================================
// Signal Declarations
//=====================================================================
   // ram registers
   parameter		       RAMI_SIZE = 32;
   parameter		       RAMC_SIZE = 23;
   parameter		       RAMD_SIZE = 64;
   parameter		       FU_RAM_DIN_SIZE = 64;
   parameter		       XU_RAM_DIN_SIZE = `GPR_WIDTH + 1;
   parameter		       LQ_RAM_DIN_SIZE = `GPR_WIDTH + 1;
   // debug control registers
   parameter		       THRCTL1_SIZE = 7 * `THREADS + 5;
   parameter		       THRCTL2_SIZE = 8;
   parameter		       PCCR0_SIZE = 3 * `THREADS + 12;
   parameter		       RECERRCNTR_SIZE = 4;
   parameter		       SPATTN_USED = 1 * `THREADS;
`ifdef THREADS1
   parameter		       SPATTN_PARITY_INIT = 1;
`else
   parameter		       SPATTN_PARITY_INIT = 0;
`endif
   // mux select registers
   parameter		       ARDSR_SIZE = 22;
   parameter		       IDSR_SIZE = 22;
   parameter		       MPDSR_SIZE = 22;
   parameter		       XDSR_SIZE = 11;
   parameter		       LDSR_SIZE = 22;
   // misc functions
   parameter		       ERRINJ_SIZE = 23 + 9 * (`THREADS - 1);
   parameter		       PARITY_SIZE = 1;
   parameter		       SCOM_MISC_SIZE = 8;
   parameter		       ERRDBG_T0_SIZE = 15;
   parameter		       ERRDBG_T1_SIZE = 15 * (`THREADS - 1);
   // repower/timing latches
   parameter		       DCFG_STAGE1_SIZE = 4;
   parameter		       BCFG_STAGE1_T0_SIZE = 8;
   parameter		       BCFG_STAGE1_T1_SIZE = 7 * (`THREADS - 1);
   parameter		       BCFG_STAGE2_T0_SIZE = 7;
   parameter		       BCFG_STAGE2_T1_SIZE = 4 * (`THREADS - 1);
   parameter		       FUNC_STAGE1_SIZE = 2;
   parameter		       INJ_STAGE1_T0_SIZE = 18;
   parameter		       INJ_STAGE1_T1_SIZE = 8;
   parameter		       FUNC_STAGE3_SIZE = 17;

   //---------------------------------------------------------------------
   // Scan Ring Ordering:
   // start of dcfg scan chain ordering
   parameter		       ARDSR_OFFSET = 0;
   parameter		       IDSR_OFFSET = ARDSR_OFFSET + ARDSR_SIZE;
   parameter		       MPDSR_OFFSET = IDSR_OFFSET + IDSR_SIZE;
   parameter		       XDSR_OFFSET = MPDSR_OFFSET + MPDSR_SIZE;
   parameter		       LDSR_OFFSET = XDSR_OFFSET + XDSR_SIZE;
   parameter		       PCCR0_OFFSET = LDSR_OFFSET + LDSR_SIZE;
   parameter		       RECERRCNTR_OFFSET = PCCR0_OFFSET + PCCR0_SIZE;
   parameter		       PCCR0_PAR_OFFSET = RECERRCNTR_OFFSET + RECERRCNTR_SIZE;
   parameter		       DCFG_STAGE1_OFFSET = PCCR0_PAR_OFFSET + PARITY_SIZE;
   parameter		       DCFG_RIGHT = DCFG_STAGE1_OFFSET + DCFG_STAGE1_SIZE - 1;
   // end of dcfg scan chain ordering
   // start of bcfg scan chain ordering
   parameter		       SCOMMODE_OFFSET = 0;
   parameter		       THRCTL1_OFFSET = SCOMMODE_OFFSET + 2;
   parameter		       THRCTL2_OFFSET = THRCTL1_OFFSET + THRCTL1_SIZE;
   parameter		       SPATTN_DATA_OFFSET = THRCTL2_OFFSET + THRCTL2_SIZE;
   parameter		       SPATTN_MASK_OFFSET = SPATTN_DATA_OFFSET + SPATTN_USED;
   parameter		       SPATTN_PAR_OFFSET = SPATTN_MASK_OFFSET + SPATTN_USED;
   parameter		       BCFG_STAGE1_T0_OFFSET = SPATTN_PAR_OFFSET + PARITY_SIZE;
   parameter		       BCFG_STAGE1_T1_OFFSET = BCFG_STAGE1_T0_OFFSET + BCFG_STAGE1_T0_SIZE;
   parameter		       BCFG_STAGE2_T0_OFFSET = BCFG_STAGE1_T1_OFFSET + BCFG_STAGE1_T1_SIZE;
   parameter		       BCFG_STAGE2_T1_OFFSET = BCFG_STAGE2_T0_OFFSET + BCFG_STAGE2_T0_SIZE;
   parameter		       ERRDBG_T0_OFFSET = BCFG_STAGE2_T1_OFFSET + BCFG_STAGE2_T1_SIZE;
   parameter		       ERRDBG_T1_OFFSET = ERRDBG_T0_OFFSET + ERRDBG_T0_SIZE;
   parameter		       BCFG_RIGHT = ERRDBG_T1_OFFSET + ERRDBG_T1_SIZE - 1;
   // end of bcfg scan chain ordering
   // start of func scan chain ordering
   parameter		       RAMI_OFFSET = 0;
   parameter		       RAMC_OFFSET = RAMI_OFFSET + RAMI_SIZE;
   parameter		       RAMD_OFFSET = RAMC_OFFSET + RAMC_SIZE;
   parameter		       FU_RAM_DIN_OFFSET = RAMD_OFFSET + RAMD_SIZE;
   parameter		       XU_RAM_DIN_OFFSET = FU_RAM_DIN_OFFSET + FU_RAM_DIN_SIZE;
   parameter		       LQ_RAM_DIN_OFFSET = XU_RAM_DIN_OFFSET + XU_RAM_DIN_SIZE;
   parameter		       ERRINJ_OFFSET = LQ_RAM_DIN_OFFSET + LQ_RAM_DIN_SIZE;
   parameter		       SC_MISC_OFFSET = ERRINJ_OFFSET + ERRINJ_SIZE;
   parameter		       SCADDR_DEC_OFFSET = SC_MISC_OFFSET + SCOM_MISC_SIZE;
   parameter		       FUNC_STAGE1_OFFSET = SCADDR_DEC_OFFSET + 64;
   parameter		       INJ_STAGE1_T0_OFFSET = FUNC_STAGE1_OFFSET + FUNC_STAGE1_SIZE;
   parameter		       INJ_STAGE1_T1_OFFSET = INJ_STAGE1_T0_OFFSET + INJ_STAGE1_T0_SIZE;
   parameter		       FUNC_STAGE3_OFFSET = INJ_STAGE1_T1_OFFSET + INJ_STAGE1_T1_SIZE;
   parameter		       SCOMFUNC_OFFSET = FUNC_STAGE3_OFFSET + FUNC_STAGE3_SIZE;
   parameter		       FUNC_RIGHT = SCOMFUNC_OFFSET + 177 - 1;
   // end of func scan chain ordering

   //---------------------------------------------------------------------
   // start of scom register addresses
   parameter		       SCOM_WIDTH = 64;
   //						    0000000000111111111122222222223333333333444444444455555555556666
   //						    0123456789012345678901234567890123456789012345678901234567890123
   parameter		       USE_ADDR       = 64'b1111111111111110111111111011100000000000111111111111111110011111;
   parameter		       ADDR_IS_RDABLE = 64'b1001111001100110100110011010000000000000111001111001001000011111;
   parameter		       ADDR_IS_WRABLE = 64'b1111101111111110111011111011100000000000111111111111111110011111;
   // end of scom register addresses

   //---------------------------------------------------------------------
   // Clock+Scan signals
   wire 		       	tidn;
   wire 		       	tiup;
   wire [0:31]  	       	tidn_32;
   wire [0:BCFG_RIGHT]  	bcfg_siv;
   wire [0:BCFG_RIGHT]  	bcfg_sov;
   wire [0:DCFG_RIGHT]  	dcfg_siv;
   wire [0:DCFG_RIGHT]  	dcfg_sov;
   wire [0:FUNC_RIGHT]  	func_siv;
   wire [0:FUNC_RIGHT]  	func_sov;
   wire 		       	lcb_func_slp_sl_thold_0_b;
   wire 		       	lcb_cfg_slp_sl_thold_0_b;
   wire 		       	force_cfgslp;
   wire 		       	force_funcslp;
   wire 		       	cfgslp_d1clk;
   wire 		       	cfgslp_d2clk;
   wire [0:`NCLK_WIDTH-1]      	cfgslp_lclk;
   wire 		       	cfg_slat_force;
   wire 		       	cfg_slat_d2clk;
   wire [0:`NCLK_WIDTH-1]      	cfg_slat_lclk;
   wire 		       	cfg_slat_thold_b;
   // SCOM satellite/decode signals
   wire 		       	scom_cch_q;
   wire 		       	scom_dch_q;
   wire 		       	scom_act;
   wire 		       	scom_local_act;
   wire 		       	scom_wr_act;
   wire 		       	sc_r_nw;
   wire 		       	sc_ack;
   wire [0:63]  	       	sc_rdata;
   wire [0:63]  	       	sc_wdata;
   wire [0:1]		       	sc_ack_info;
   wire 		       	sc_wparity_out;
   wire 		       	sc_wparity;
   wire 		       	scom_fsm_err;
   wire 		       	scom_ack_err;
   wire [0:5]		       	scaddr_predecode;
   wire [0:63]  	       	scaddr_dec_d;
   wire [0:63]  	       	scaddr_v;
   wire [0:63]  	       	andmask_ones;
   wire 		       	sc_req_d;
   wire 		       	sc_req_q;
   wire 		       	sc_wr_d;
   wire 		       	sc_wr_q;
   wire [0:63]  	       	scaddr_v_d;
   wire [0:63]  	       	scaddr_v_q;
   wire 		       	scaddr_nvld_d;
   wire 		       	scaddr_nvld_q;
   wire 		       	sc_wr_nvld_d;
   wire 		       	sc_wr_nvld_q;
   wire 		       	sc_rd_nvld_d;
   wire 		       	sc_rd_nvld_q;
   // RAM related signals
   wire [0:3]		       	ramc_instr_in;
   wire 		       	ramc_mode_in;
   wire 		       	ramc_thread_in;
   wire 		       	ramc_execute_in;
   wire [0:3]		       	ramc_msr_ovrid_in;
   wire 		       	ramc_force_cmplt_in;
   wire [0:1]		       	ramc_force_flush_in;
   wire [0:3] 		       	ramc_spare_in;
   wire [0:4]		       	ramc_status_in;
   wire 		       	or_ramc_load;
   wire 		       	and_ramc_ones;
   wire 		       	and_ramc_load;
   wire [0:63]  	       	or_ramc;
   wire [0:63]  	       	and_ramc;
   wire [0:RAMI_SIZE-1] 	rami_d;
   wire [0:RAMI_SIZE-1] 	rami_q;
   wire [0:63]      		rami_out;
   wire [0:RAMC_SIZE-1] 	ramc_d;
   wire [0:RAMC_SIZE-1] 	ramc_q;
   wire [0:63]      		ramc_out;
   wire [0:63]      		ramic_out;
   wire [0:RAMD_SIZE-1] 	ramd_d;
   wire [0:RAMD_SIZE-1] 	ramd_q;
   wire [0:63]  	       	ramdh_out;
   wire [0:63]  	       	ramdl_out;
   wire 		       	rg_rg_ram_mode;
   wire [0:64-`GPR_WIDTH]      	ramd_load_zeros;
   wire [0:64]  	       	xu_ramd_load_data_d;
   wire [0:64]  	       	xu_ramd_load_data_q;
   wire [0:63]  	       	xu_ramd_load_data;
   wire [0:63]  	       	fu_ramd_load_data_d;
   wire [0:63]  	       	fu_ramd_load_data_q;
   wire [0:64]  	       	lq_ramd_load_data_d;
   wire [0:64]  	       	lq_ramd_load_data_q;
   wire [0:63]  	       	lq_ramd_load_data;
   wire   			xu_ram_data_val_q;
   wire   			fu_ram_data_val_q;
   wire   			lq_ram_data_val_q;
   wire				ram_mode_d;
   wire				ram_mode_q;
   wire [0:`THREADS-1]  	ram_active_out;
   wire [0:1]   		ram_active_d;
   wire [0:1]   		ram_active_q;
   wire 		       	ram_execute_d;
   wire 		       	ram_execute_q;
   wire 		       	ram_unsupported_q;
   wire 		       	ram_interrupt_q;
   wire 		       	ram_done_q;
   wire 		       	ram_msrovren_d;
   wire 		       	ram_msrovren_q;
   wire 		       	ram_msrovrpr_d;
   wire 		       	ram_msrovrpr_q;
   wire 		       	ram_msrovrgs_d;
   wire 		       	ram_msrovrgs_q;
   wire 		       	ram_msrovrde_d;
   wire 		       	ram_msrovrde_q;
   wire 		       	ram_force_d;
   wire 		       	ram_force_q;
   wire [0:1]		       	ram_flush_d;
   wire [0:1]		       	ram_flush_q;
   wire 		       	load_sramd_d;
   wire 		       	load_sramd_q;
   wire [0:1]		       	ramCmpltCntr_in;
   wire [0:1]		       	ramCmpltCntr_q;
   wire 		       	rammed_thrd_running;
   wire 		       	rammed_thrd_running_chk;
   wire 		       	two_ram_executes_chk;
   wire 		       	ram_mode_ends_wo_done_chk;
   wire 		       	rammed_instr_overrun;
   wire 		       	ramc_error_status;
   // THRCTL related signals
   wire 		       	or_thrctl_load;
   wire 		       	and_thrctl_ones;
   wire 		       	and_thrctl_load;
   wire [0:63]  	       	or_thrctl;
   wire [0:63]  	       	and_thrctl;
   wire [0:63]  	       	thrctl_out;
   wire [0:THRCTL1_SIZE-1]	thrctl1_d;
   wire [0:THRCTL1_SIZE-1]	thrctl1_q;
   wire [0:THRCTL2_SIZE-1]	thrctl2_d;
   wire [0:THRCTL2_SIZE-1]	thrctl2_q;
   wire [0:`THREADS-1]         	thrctl_stop_in;
   wire [0:`THREADS-1]  	thrctl_step_in;
   wire [0:`THREADS-1]  	thrctl_run_in;
   wire 		       	thrctl_debug_stop_in;
   wire [0:3+(4*(`THREADS-1))]  thrctl_stop_summary_in;
   wire [0:1]		       	thrctl_spare1_in;
   wire 		       	thrctl_step_ovrun_in;
   wire 		       	thrctl_ramc_err_in;
   wire [0:2]		       	thrctl_misc_dbg_in;
   wire [0:4]		       	thrctl_spare2_in;
   wire [0:`THREADS-1]  	tx_stop_d;
   wire [0:`THREADS-1]  	tx_stop_q;
   wire 		       	extirpts_dis_d;
   wire 		       	extirpts_dis_q;
   wire 		       	timebase_dis_d;
   wire 		       	timebase_dis_q;
   wire 		       	decrem_dis_d;
   wire 		       	decrem_dis_q;
   wire 		       	ext_debug_stop_q;
   wire [0:`THREADS-1]  	external_debug_stop;
   wire [0:`THREADS-1]  	stop_dbg_event_q;
   wire [0:`THREADS-1]  	stop_dbg_dnh_q;
   wire [0:`THREADS-1]  	stop_for_debug;
   wire [0:`THREADS-1]  	pm_thread_stop_q;
   wire [0:`THREADS-1]  	pm_fetch_halt_q;
   wire [0:`THREADS-1]  	step_done_q;
   wire [0:`THREADS-1]  	tx_step_d;
   wire [0:`THREADS-1]  	tx_step_q;
   wire [0:`THREADS-1]  	tx_step_req_d;
   wire [0:`THREADS-1]  	tx_step_req_q;
   wire [0:`THREADS-1]  	tx_step_val_d;
   wire [0:`THREADS-1]  	tx_step_val_q;
   wire [0:`THREADS-1]  	tx_step_overrun;
   wire 		       	instr_step_overrun;
   // PCCR0 related signals
   wire 		       	or_pccr0_load;
   wire 		       	and_pccr0_ones;
   wire 		       	and_pccr0_load;
   wire [0:63]  	       	or_pccr0;
   wire [0:63]  	       	and_pccr0;
   wire [0:63]  	       	pccr0_out;
   wire 		       	pccr0_par_err;
   wire [0:PCCR0_SIZE+4-1]	pccr0_par_in;
   wire [0:PCCR0_SIZE-1]	pccr0_d;
   wire [0:PCCR0_SIZE-1]	pccr0_q;
   wire [0:0]		       	pccr0_par_d;
   wire [0:0]		       	pccr0_par_q;
   wire 		       	debug_mode_d;
   wire 		       	debug_mode_q;
   wire 		       	debug_mode_act;
   wire 		       	trace_bus_enable_d;
   wire 		       	trace_bus_enable_q;
   wire 		       	ram_enab_d;
   wire 		       	ram_enab_q;
   wire 		       	ram_enab_act;
   wire 		       	ram_ctrl_act;
   wire 		       	ram_data_act;
   wire 		       	errinj_enab_d;
   wire 		       	errinj_enab_q;
   wire 		       	errinj_enab_act;
   wire 		       	errinj_enab_scom_act;
   wire 		       	rg_rg_xstop_report_ovride;
   wire 		       	rg_rg_fast_xstop_enable;
   wire 		       	rg_rg_dis_overrun_chks;
   wire 		       	rg_rg_maxRecErrCntrValue;
   wire 		       	rg_rg_gateRecErrCntr;
   wire 		       	recErrCntr_pargen;
   wire [0:3]		       	incr_recErrCntr;
   wire [0:3]		       	recErrCntr_in;
   wire [0:3]		       	recErrCntr_q;
   wire [0:7]		       	pccr0_pervModes_in;
   wire [0:3]		       	pccr0_spare_in;
   wire [0:3*`THREADS-1]	pccr0_dbgActSel_in;
   wire [0:`THREADS-1]		pccr0_dba_active_d;
   wire [0:`THREADS-1]		pccr0_dba_active_q;
   // spattn related signals
   wire 		       	or_spattn_load;
   wire 		       	and_spattn_ones;
   wire 		       	and_spattn_load;
   wire [0:63]  	       	or_spattn;
   wire [0:63]  	       	and_spattn;
   wire [0:63]  	       	spattn_out;
   wire 		       	spattn_par_err;
   wire [0:0]		       	spattn_par_d;
   wire [0:0]		       	spattn_par_q;
   wire [0:SPATTN_USED-1]	spattn_data_d;
   wire [0:SPATTN_USED-1]	spattn_data_q;
   wire [0:SPATTN_USED-1]	spattn_mask_d;
   wire [0:SPATTN_USED-1]	spattn_mask_q;
   wire [0:SPATTN_USED-1]	spattn_out_masked;
   wire [SPATTN_USED:15]       	spattn_unused;
   wire [0:`THREADS-1]  	spattn_attn_instr_in;
   wire [0:`THREADS-1]  	err_attention_instr_q;
   // Debug related signals
   wire [0:ARDSR_SIZE-1]	ardsr_data_in;
   wire [0:63]          	ardsr_out;
   wire [0:ARDSR_SIZE-1]	ardsr_d;
   wire [0:ARDSR_SIZE-1]	ardsr_q;
   wire [0:IDSR_SIZE-1] 	idsr_data_in;
   wire [0:63]          	idsr_out;
   wire [0:IDSR_SIZE-1] 	idsr_d;
   wire [0:IDSR_SIZE-1] 	idsr_q;
   wire [0:MPDSR_SIZE-1]	mpdsr_data_in;
   wire [0:63]          	mpdsr_out;
   wire [0:MPDSR_SIZE-1]	mpdsr_d;
   wire [0:MPDSR_SIZE-1]	mpdsr_q;
   wire [0:XDSR_SIZE-1] 	xdsr_data_in;
   wire [0:63]          	xdsr_out;
   wire [0:XDSR_SIZE-1] 	xdsr_d;
   wire [0:XDSR_SIZE-1] 	xdsr_q;
   wire [0:LDSR_SIZE-1] 	ldsr_data_in;
   wire [0:63]          	ldsr_out;
   wire [0:LDSR_SIZE-1] 	ldsr_d;
   wire [0:LDSR_SIZE-1] 	ldsr_q;
   // FIR + ERROR RELATed signals
   wire [0:63]          	errinj_out;
   wire [0:ERRINJ_SIZE-1]	errinj_errtype_in;
   wire [0:ERRINJ_SIZE-1]	errinj_d;
   wire [0:ERRINJ_SIZE-1]	errinj_q;
   wire 		       	rg_rg_ram_mode_xstop;
   wire [0:`THREADS-1]  	rg_rg_xstop_err;
   wire 		       	rg_rg_any_fir_xstop;
   wire [0:1]		       	scom_reg_par_checks;
   wire 		       	scaddr_fir;
   wire 		       	fir_func_si;
   wire 		       	fir_func_so;
   wire 		       	fir_mode_si;
   wire 		       	fir_mode_so;
   wire [0:63]  	       	fir_data_out;
   wire [0:ERRINJ_SIZE-1]      	rg_rg_errinj_shutoff;
   wire 		       	sc_parity_error_inj;
   wire 		       	inj_icache_parity_d;
   wire 		       	inj_icache_parity_q;
   wire 		       	inj_icachedir_parity_d;
   wire 		       	inj_icachedir_parity_q;
   wire 		       	inj_icachedir_multihit_d;
   wire 		       	inj_icachedir_multihit_q;
   wire 		       	inj_dcache_parity_d;
   wire 		       	inj_dcache_parity_q;
   wire 		       	inj_dcachedir_ldp_parity_d;
   wire 		       	inj_dcachedir_ldp_parity_q;
   wire 		       	inj_dcachedir_stp_parity_d;
   wire 		       	inj_dcachedir_stp_parity_q;
   wire 		       	inj_dcachedir_ldp_multihit_d;
   wire 		       	inj_dcachedir_ldp_multihit_q;
   wire 		       	inj_dcachedir_stp_multihit_d;
   wire 		       	inj_dcachedir_stp_multihit_q;
   wire 		       	inj_prefetcher_parity_d;
   wire 		       	inj_prefetcher_parity_q;
   wire 		       	inj_relq_parity_d;
   wire 		       	inj_relq_parity_q;
   wire [0:`THREADS-1]  	inj_sprg_ecc_d;
   wire [0:`THREADS-1]  	inj_sprg_ecc_q;
   wire [0:`THREADS-1]  	inj_fx0regfile_parity_d;
   wire [0:`THREADS-1]  	inj_fx0regfile_parity_q;
   wire [0:`THREADS-1]  	inj_fx1regfile_parity_d;
   wire [0:`THREADS-1]  	inj_fx1regfile_parity_q;
   wire [0:`THREADS-1]  	inj_lqregfile_parity_d;
   wire [0:`THREADS-1]  	inj_lqregfile_parity_q;
   wire [0:`THREADS-1]  	inj_furegfile_parity_d;
   wire [0:`THREADS-1]  	inj_furegfile_parity_q;
   wire [0:`THREADS-1]  	inj_llbust_attempt_d;
   wire [0:`THREADS-1]  	inj_llbust_attempt_q;
   wire [0:`THREADS-1]  	inj_llbust_failed_d;
   wire [0:`THREADS-1]  	inj_llbust_failed_q;
   wire [0:`THREADS-1]  	inj_cpArray_parity_d;
   wire [0:`THREADS-1]  	inj_cpArray_parity_q;
   wire [0:ERRDBG_T0_SIZE-1]	errDbg_t0_d;
   wire [0:ERRDBG_T0_SIZE-1]	errDbg_t0_q;
   wire [0:ERRDBG_T1_SIZE-1]	errDbg_t1_d;
   wire [0:ERRDBG_T1_SIZE-1]	errDbg_t1_q;
   wire [0:31]			errDbg_out;
   // Miscellaneous signals
   wire [0:1]		        dbg_ram_active_q;
   wire [0:1]			dbg_spattn_data_q;
   wire [0:1]  			dbg_stop_dbg_event_q;
   wire [0:1]  			dbg_stop_dbg_dnh_q;
   wire [0:1]  			dbg_power_managed_q;
   wire [0:1]  			dbg_pm_thread_stop_q;
   wire [0:1]  			dbg_tx_stop_q;
   wire [0:1]  			dbg_thread_running_q;
   wire [0:1]  			dbg_tx_step_q;
   wire [0:1]  			dbg_tx_step_done_q;
   wire [0:1]  			dbg_tx_step_req_q;




// Get rid of sinkless net messages
// synopsys translate_off
(* analysis_not_referenced="true" *)
// synopsys translate_on
   wire 		       	unused_signals;
   assign unused_signals =
   	  (|{or_ramc[0:31], or_ramc[36:43], or_ramc[45], or_ramc[56:58], and_ramc[0:31],
	     and_ramc[36:43], and_ramc[45], and_ramc[47], and_ramc[53:54], and_ramc[56:58],
	     xu_ramd_load_data_q[0], lq_ramd_load_data_q[0], or_thrctl[0:31], or_thrctl[34:35],
	     or_thrctl[38:44], or_thrctl[48], and_thrctl[0:31], and_thrctl[34:35], and_thrctl[38:44],
	     and_thrctl[48], or_pccr0[0:31], or_pccr0[44:52], or_pccr0[56], or_pccr0[60:63],
	     and_pccr0[0:31], and_pccr0[44:52], and_pccr0[56], and_pccr0[60:63], or_spattn[0:31],
	     or_spattn[34:47], or_spattn[50:63], and_spattn[0:31], and_spattn[34:47], and_spattn[50:63],
	     sc_wparity
	  });


//---------------------------------------------------------------------
//!! Bugspray Include: pcq_regs;
// --## figtree_source pcq_regs.fig


   assign tidn = 1'b0;
   assign tidn_32 = {32 {1'b0}};
   assign tiup = 1'b1;

//=====================================================================
// SCOM Satellite and Controls
//=====================================================================
   tri_serial_scom2 #(.WIDTH(SCOM_WIDTH), .INTERNAL_ADDR_DECODE(1'b0), .PIPELINE_PARITYCHK(1'b0)) scomsat(
      //  Global lines for clocking and cop control
      .nclk(nclk),
      .vdd(vdd),
      .gnd(gnd),
      .scom_func_thold(lcb_func_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis_dc(lcb_act_dis_dc),
      .clkoff_dc_b(lcb_clkoff_dc_b),
      .mpw1_dc_b(lcb_mpw1_dc_b),
      .mpw2_dc_b(lcb_mpw2_dc_b),
      .d_mode_dc(lcb_d_mode_dc),
      .delay_lclkr_dc(lcb_delay_lclkr_dc),
      .func_scan_in(func_siv[ SCOMFUNC_OFFSET:SCOMFUNC_OFFSET + SCOM_WIDTH + 2 * ((SCOM_WIDTH - 1)/16 + 1) + 104]),
      .func_scan_out(func_sov[SCOMFUNC_OFFSET:SCOMFUNC_OFFSET + SCOM_WIDTH + 2 * ((SCOM_WIDTH - 1)/16 + 1) + 104]),
      .dcfg_scan_dclk(cfg_slat_d2clk),
      .dcfg_scan_lclk(cfg_slat_lclk),
      .dcfg_d1clk(cfgslp_d1clk),
      .dcfg_d2clk(cfgslp_d2clk),
      .dcfg_lclk(cfgslp_lclk),
      .dcfg_scan_in(bcfg_siv[ SCOMMODE_OFFSET:SCOMMODE_OFFSET + 1]),
      .dcfg_scan_out(bcfg_sov[SCOMMODE_OFFSET:SCOMMODE_OFFSET + 1]),
      //-------------------------------------------------------------------
      //  Global SCOM interface
      //-------------------------------------------------------------------
      .scom_local_act(scom_local_act),
      // tie to VDD/GND to program the base address ranges
      .sat_id(an_ac_scom_sat_id),
      // global serial lines to top level of macro
      .scom_dch_in(scom_dch_q),
      .scom_cch_in(scom_cch_q),
      .scom_dch_out(ac_an_scom_dch),
      .scom_cch_out(ac_an_scom_cch),
      //-------------------------------------------------------------------
      //  Internal SCOM interface to parallel registers
      //-------------------------------------------------------------------
      // address/control interface
      .sc_req(sc_req_d),
      .sc_ack(sc_ack),
      .sc_ack_info(sc_ack_info),
      .sc_r_nw(sc_r_nw),
      .sc_addr(scaddr_predecode),
      .sc_rdata(sc_rdata),
      .sc_wdata(sc_wdata),
      .sc_wparity(sc_wparity_out),
      .scom_err(scom_fsm_err),
      .fsm_reset(tidn)
   );

   tri_scom_addr_decode #(.USE_ADDR(USE_ADDR), .ADDR_IS_RDABLE(ADDR_IS_RDABLE), .ADDR_IS_WRABLE(ADDR_IS_WRABLE)) scaddr(
      .sc_addr(scaddr_predecode),	// binary coded scom address
      .scaddr_dec(scaddr_dec_d),	// one hot coded scom address, not latched
      .sc_req(sc_req_d),		// scom request
      .sc_r_nw(sc_r_nw),	 	// read / not write bit
      .scaddr_nvld(scaddr_nvld_d),	// scom address not valid; not latched
      .sc_wr_nvld(sc_wr_nvld_d),	// scom write not allowed, not latched
      .sc_rd_nvld(sc_rd_nvld_d),	// scom read  not allowed, not latched
      .vd(vdd),
      .gd(gnd)
   );


   assign scom_act 	= sc_req_d | sc_req_q | scom_local_act;
   assign scom_wr_act 	= scom_act & sc_wr_q;

   assign sc_wr_d 	= (~sc_r_nw);

   assign scaddr_v_d 	= {SCOM_WIDTH {sc_req_d}} & scaddr_dec_d;
   assign scaddr_v 	= scaddr_v_q;

   assign sc_ack	= (sc_req_d & (~sc_r_nw)) | (sc_req_q & sc_r_nw);

   assign sc_ack_info 	= ({2 {(~sc_r_nw)}} & {(sc_wr_nvld_d | sc_rd_nvld_d), scaddr_nvld_d}) |
   	                  ({2 {  sc_r_nw }} & {(sc_wr_nvld_q | sc_rd_nvld_q), scaddr_nvld_q}) ;

   assign scom_ack_err 	= (|sc_ack_info);

   assign sc_wparity 	= sc_wparity_out ^ sc_parity_error_inj;


   //=====================================================================
   // SCOM Register Writes
   //=====================================================================
   assign andmask_ones = {SCOM_WIDTH {1'b1}};

   //---------------------------------------------------------------------
   // RAM Instruction Register -------------------------------------------
   // RAMIC RW address  = 40
   // RAMI  RW address  = 41

   assign rami_d[0:31] = ((scaddr_v[40] & sc_wr_q) == 1'b1) ? sc_wdata[0:31]  :
			 ((scaddr_v[41] & sc_wr_q) == 1'b1) ? sc_wdata[32:63] :
			 rami_q[0:31];

   assign rami_out 	= {tidn_32, rami_q[0:31]};

   assign ramic_out 	= {rami_out[32:63], ramc_out[32:63]};


   //---------------------------------------------------------------------
   // RAM Control Register -----------------------------------------------
   // RAMIC RW address       = 40
   // RAMC  RW address       = 42
   // RAMC  WO with and-mask = 43
   // RAMC  WO with or-mask  = 44

   assign or_ramc_load 	=    (scaddr_v[40] | scaddr_v[42] | scaddr_v[44]) & sc_wr_q;
   assign and_ramc_ones = (~((scaddr_v[40] | scaddr_v[42] | scaddr_v[43]) & sc_wr_q));
   assign and_ramc_load =     scaddr_v[43] & sc_wr_q;

   assign or_ramc  =  {SCOM_WIDTH {or_ramc_load}}  & sc_wdata;
   assign and_ramc = ({SCOM_WIDTH {and_ramc_load}} & sc_wdata)  | ({SCOM_WIDTH {and_ramc_ones}} & andmask_ones);

   // Instruction fields: set by SCOM; reset by SCOM
   assign ramc_instr_in = or_ramc[32:35] | (ramc_out[32:35] & and_ramc[32:35]);

   // Mode bit: set by SCOM; reset by SCOM
   assign ramc_mode_in = or_ramc[44] | (ramc_out[44] & and_ramc[44]);

   // Thread bit: set by SCOM; reset by SCOM
   // Note: Bit 45 is unimplemented
   assign ramc_thread_in = or_ramc[46] | (ramc_out[46] & and_ramc[46]);

   // Execute bit: not latched; pulsed by SCOM write
   assign ramc_execute_in = or_ramc[47];

   // MSR Override control bits: set by SCOM; reset by SCOM
   assign ramc_msr_ovrid_in = or_ramc[48:51] | (ramc_out[48:51] & and_ramc[48:51]);

   // Force Ram Completion bit: set by SCOM; reset by SCOM
   assign ramc_force_cmplt_in = or_ramc[52] | (ramc_out[52] & and_ramc[52]);

   // Force Flush bits: not latched; pulsed by SCOM write.
   assign ramc_force_flush_in = or_ramc[53:54];

   // Spare bits: set by SCOM; reset by SCOM
   assign ramc_spare_in = or_ramc[55:58] | (ramc_out[55:58] & and_ramc[55:58]);

   // Unsupported bit: set by SCOM + iu Unsupported signal; reset by SCOM
   assign ramc_status_in[0] = ram_unsupported_q | or_ramc[59] | (ramc_out[59] & and_ramc[59]);

   // Overrun bit: set by SCOM + rammed_instr_overrun signal; reset by SCOM
   assign ramc_status_in[1] = rammed_instr_overrun | or_ramc[60] | (ramc_out[60] & and_ramc[60]);

   // Interrupt bit: set by SCOM + iu Interrupt signal; reset by SCOM
   assign ramc_status_in[2] = ram_interrupt_q | or_ramc[61] | (ramc_out[61] & and_ramc[61]);

   // Checkstop bit: set by SCOM + Rammed `THREADS checkstop bit; reset by SCOM
   assign ramc_status_in[3] = rg_rg_ram_mode_xstop | or_ramc[62] | (ramc_out[62] & and_ramc[62]);

   // Done bit: set by SCOM + iu Done signals; reset by SCOM + RAMC_execute
   assign ramc_status_in[4] = ram_done_q | or_ramc[63] | (ramc_out[63] & and_ramc[63] & (~ramc_out[47]));

   assign ramc_d = {ramc_instr_in, 	ramc_mode_in, 		ramc_thread_in, 	ramc_execute_in,
   	            ramc_msr_ovrid_in, 	ramc_force_cmplt_in, 	ramc_force_flush_in, 	ramc_spare_in,
		    ramc_status_in };

   //			        Instr Exten	     	Mode		   Thread+Exec   MSR Overrides
   assign ramc_out = {tidn_32, 	ramc_q[0:3], 	8'h00, 	ramc_q[4],  1'b0,  ramc_q[5:6],  ramc_q[7:10],
   //	       	      MSR Forces      Spare Ltchs    Status
  	              ramc_q[11:13],  ramc_q[14:17], ramc_q[18:22] };

   // ---------------------------
   // RAMC Controls and Overrun Checking Logic:
   assign ram_mode_d = ram_enab_d & ramc_out[44];
   assign ram_thread = ramc_out[46];
   assign ram_execute_d = ram_mode_d & ramc_out[47] & (~rammed_instr_overrun);

   // ram_active_q set same time as ram_execute_q; cleared when IU activates ram_done_q.
   assign ram_active_d[0] = (ram_execute_d & (~ram_thread)) | ((~ram_done_q) & ram_active_q[0]);
   assign ram_active_d[1] = (ram_execute_d &   ram_thread ) | ((~ram_done_q) & ram_active_q[1]);

   generate
      if (`THREADS == 1)
      begin : T1_RAMCTRL
	 assign rammed_thrd_running = (~ram_thread) & thrctl_out[40];
	 assign ram_active_out = ram_active_q[0];
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_RAMCTRL
	 assign rammed_thrd_running = ((~ram_thread) & thrctl_out[40]) | (ram_thread & thrctl_out[41]);
	 assign ram_active_out = ram_active_q[0:1];
      end
   endgenerate

   assign ramCmpltCntr_in = (ram_mode_d == 1'b0) 	? 2'b00 :
			    (ram_execute_q == 1'b1) 	? (ramCmpltCntr_q + 2'b01) :
			    (ram_done_q == 1'b1) 	? (ramCmpltCntr_q - 2'b01) :
			    ramCmpltCntr_q[0:1];

   // OVERRUN CHECK 1: RAMC[EXEC] pulses while the Rammed thread is still running
   assign rammed_thrd_running_chk = ram_mode_d & ramc_out[47] & rammed_thrd_running;
   // OVERRUN CHECK 2: Two consecutive ram_execute pulses without receiving a ram_done
   assign two_ram_executes_chk = ramc_out[47] & (~ramCmpltCntr_q[0]) & ramCmpltCntr_q[1];
   // OVERRUN CHECK 3: Counter not cleared when ram_mode goes inactive.
   assign ram_mode_ends_wo_done_chk = (~ram_mode_d) & ram_mode_q & (|ramCmpltCntr_q[0:1]);
   // ---------------------------
   assign rammed_instr_overrun = (rammed_thrd_running_chk | two_ram_executes_chk | ram_mode_ends_wo_done_chk) & (~rg_rg_dis_overrun_chks);
   // ---------------------------

   // RAMC status summary signal; sets Ram "sticky" status bit in thread status register.
   assign ramc_error_status = ram_unsupported_q | rammed_instr_overrun | ram_interrupt_q | rg_rg_ram_mode_xstop;


   //---------------------------------------------------------------------
   // RAM Data Register  -------------------------------------------------
   // RAMD  R/W address  = 45
   // RAMDH R/W address  = 46
   // RAMDL R/W address  = 47

   assign fu_ramd_load_data_d = fu_pc_ram_data[0:63];

   // For XU+LQ, adjusting size of RAM data when compiled as 32-bit core.
   assign ramd_load_zeros = {65-`GPR_WIDTH {1'b0}};
   assign xu_ramd_load_data_d[0:64] = {ramd_load_zeros, xu_pc_ram_data[64-`GPR_WIDTH:63]};
   assign xu_ramd_load_data[0:63] = xu_ramd_load_data_q[1:64];

   assign lq_ramd_load_data_d[0:64] = {ramd_load_zeros, lq_pc_ram_data[64-`GPR_WIDTH:63]};
   assign lq_ramd_load_data[0:63] = lq_ramd_load_data_q[1:64];

   // Latch Ram data from SCOM, or FU/XU Ram data buses.
   assign ramd_d[0:31] = ((scaddr_v[45] & sc_wr_q) == 1'b1) ? sc_wdata[0:31] :
			 ((scaddr_v[46] & sc_wr_q) == 1'b1) ? sc_wdata[32:63] :
			 (fu_ram_data_val_q == 1'b1) ? fu_ramd_load_data_q[0:31] :
			 (xu_ram_data_val_q == 1'b1) ? xu_ramd_load_data[0:31] :
			 (lq_ram_data_val_q == 1'b1) ? lq_ramd_load_data[0:31] :
			 ramd_q[0:31];

   assign ramd_d[32:63] = ((scaddr_v[45] & sc_wr_q) == 1'b1) ? sc_wdata[32:63] :
			  ((scaddr_v[47] & sc_wr_q) == 1'b1) ? sc_wdata[32:63] :
			  (fu_ram_data_val_q == 1'b1) ? fu_ramd_load_data_q[32:63] :
			  (xu_ram_data_val_q == 1'b1) ? xu_ramd_load_data[32:63] :
			  (lq_ram_data_val_q == 1'b1) ? lq_ramd_load_data[32:63] :
			  ramd_q[32:63];

   assign ramdh_out = {tidn_32, ramd_q[0:31]};

   assign ramdl_out = {tidn_32, ramd_q[32:63]};

   // SRAMD load pulse active 1 cycle after SCOM write to RAMD register address
   assign load_sramd_d = sc_wr_q & (|scaddr_v[45:47]);


   //---------------------------------------------------------------------
   // Thread Control Register
   // THRCTL RW address       = 48
   // THRCTL WO with and-mask = 49
   // THRCTL WO with or-mask  = 50

   assign or_thrctl_load =     (scaddr_v[48] | scaddr_v[50]) & sc_wr_q;
   assign and_thrctl_ones = (~((scaddr_v[48] | scaddr_v[49]) & sc_wr_q));
   assign and_thrctl_load =     scaddr_v[49] & sc_wr_q;

   assign or_thrctl  =  {SCOM_WIDTH {or_thrctl_load}}  & sc_wdata;
   assign and_thrctl = ({SCOM_WIDTH {and_thrctl_load}} & sc_wdata) | ({SCOM_WIDTH {and_thrctl_ones}} & andmask_ones);

   assign stop_for_debug = stop_dbg_event_q | stop_dbg_dnh_q;

   // Stop bit: set by SCOM + misc stop signals; reset by SCOM
   assign thrctl_stop_in = stop_for_debug[0:`THREADS-1] 	| rg_rg_xstop_err[0:`THREADS-1]	 |
   	                   err_attention_instr_q[0:`THREADS-1] 	| or_thrctl[32:32 + `THREADS-1]  |
			   (thrctl_out[32:32 + `THREADS-1] 	& and_thrctl[32:32 + `THREADS-1]);

   // Step bit: set by SCOM; reset by SCOM or iu_pc_step_done
   assign thrctl_step_in = or_thrctl[36:36 + `THREADS-1] 	|
   	                   (thrctl_out[36:36 + `THREADS-1] 	& and_thrctl[36:36 + `THREADS-1] &
			    (~tx_step_overrun[0:`THREADS-1]) 	& (~step_done_q[0:`THREADS - 1]));

   // Run bit: controlled by external status input
   assign thrctl_run_in = xu_pc_running[0:`THREADS-1];

   // Debug Stop Status bit: controlled by PCCR0[Enable Debug Stop] AND an_ac_debug_stop input signals
   assign thrctl_debug_stop_in = external_debug_stop[0];

   // Thread Stop Summary Status: PwrMgmt; XstopErr; DbgEvent; SpecAttn.
   assign thrctl_stop_summary_in[0]   = ct_rg_power_managed[0] | pm_fetch_halt_q[0] | pm_thread_stop_q[0];

   assign thrctl_stop_summary_in[1:3] = {rg_rg_xstop_err[0], stop_for_debug[0], err_attention_instr_q[0]} |
   	                                 or_thrctl[45:47]  | (thrctl_out[45:47] & and_thrctl[45:47]);

   generate
      if (`THREADS == 2)
      begin : T2_STOP_REQ
	 assign thrctl_stop_summary_in[4]   = ct_rg_power_managed[1] | pm_fetch_halt_q[1] | pm_thread_stop_q[1];

	 assign thrctl_stop_summary_in[5:7] = {rg_rg_xstop_err[1], stop_for_debug[1], err_attention_instr_q[1]} |
	 				       or_thrctl[49:51]  | (thrctl_out[49:51] & and_thrctl[49:51]);
      end
   endgenerate

   // Misc Debug Ctrl bits: set by SCOM; reset by SCOM
   assign thrctl_misc_dbg_in = or_thrctl[52:54] | (thrctl_out[52:54] & and_thrctl[52:54]);

   // Spare bits: set by SCOM; reset by SCOM
   assign thrctl_spare2_in = or_thrctl[55:59] | (thrctl_out[55:59] & and_thrctl[55:59]);

   // Spare bits: set by SCOM; reset by SCOM
   assign thrctl_spare1_in = or_thrctl[60:61] | (thrctl_out[60:61] & and_thrctl[60:61]);

   // InstrStep Overrun: set by SCOM + instr_step_overrun; reset by SCOM
   assign thrctl_step_ovrun_in = instr_step_overrun | or_thrctl[62] | (thrctl_out[62] & and_thrctl[62]);

   // RAMC Error Status: set by SCOM + ramc_error_status signals; reset by SCOM
   assign thrctl_ramc_err_in = ramc_error_status | or_thrctl[63] | (thrctl_out[63] & and_thrctl[63]);

   // THRCTL register inputs: thrctl1 is always enabled; thrctl2 updates when debug mode active
   assign thrctl1_d = {thrctl_stop_in, 		thrctl_step_in, 	thrctl_run_in, 		thrctl_debug_stop_in,
   		       thrctl_stop_summary_in, 	thrctl_spare1_in, 	thrctl_step_ovrun_in, 	thrctl_ramc_err_in};
   assign thrctl2_d = {thrctl_misc_dbg_in, 	thrctl_spare2_in};

   //  SCOM output - reserves unimplemented bit spacing when `THREADS set to 1 or 2
   generate
      if (`THREADS == 1)
      begin : T1_THRCTL
	 //			        Stop(32)	      Step(36)		    Run(40) 	         DbgStopInp(43)
	 assign thrctl_out = {tidn_32, 	thrctl1_q[0], 3'b000, thrctl1_q[1], 3'b000, thrctl1_q[2], 2'b00, thrctl1_q[3],
	 //			        StopSumary(44:47)	 Dbg/Spares(52:59)  Spare1(60:61)   Error Stat (62:63)
	 				thrctl1_q[4:7], 4'b0000, thrctl2_q[0:7],    thrctl1_q[8:9], thrctl1_q[10:11]};
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_THRCTL
	 //			       Stop(32:33)	      Step(36:37)	     Run(40:41)		   DbgStopInp(43)
	 assign thrctl_out = {tidn_32, thrctl1_q[0:1], 2'b00, thrctl1_q[2:3], 2'b00, thrctl1_q[4:5], 1'b0, thrctl1_q[6],
	 //			       StopSum(44:51)   Dbg/Spares(52:59)  Spare1(60:61)     Error Stat (62:63)
	 	                       thrctl1_q[7:14], thrctl2_q[0:7],    thrctl1_q[15:16], thrctl1_q[17:18]};
      end
   endgenerate

   // ---------------------------
   // InstrStep Controls and Overrun Checking Logic:

   // Its an overrun when there is a step_req rising edge pulse and THRCTL[Tx_RUN] is still active.
   assign tx_step_req_d[0:`THREADS-1]   = {`THREADS {debug_mode_d}} & thrctl_out[36:36 + `THREADS-1];
   assign tx_step_overrun[0:`THREADS-1] = tx_step_req_d & (~tx_step_req_q) & thrctl_out[40:40 + `THREADS-1] &
  					  ~{`THREADS {rg_rg_dis_overrun_chks}};

   // Latch tx_step_val_q when step_req rising edge pulse and THRCTL[Tx_RUN] is inactive. A step_done pulse resets latch.
   // Requires debug_mode active to set latch. latch is cleared if debug_mode is dropped.
   assign tx_step_val_d[0:`THREADS-1] = (tx_step_req_d & (~tx_step_req_q) & ((~thrctl_out[40:40 + `THREADS-1]) 	|
   					 {`THREADS {rg_rg_dis_overrun_chks}})) 				  	|
   	                                ({`THREADS {debug_mode_d}} & (tx_step_val_q & (~step_done_q)));

   // THRCTL status bit
   assign instr_step_overrun = (|tx_step_overrun[0:`THREADS-1]);


   //---------------------------------------------------------------------
   // PC Unit Configuration Register 0
   // PCCR0 RW address        = 51
   // PCCR0 WO with and-mask  = 52
   // PCCR0 WO with or-mask   = 53

   assign or_pccr0_load =     (scaddr_v[51] | scaddr_v[53]) & sc_wr_q;
   assign and_pccr0_ones = (~((scaddr_v[51] | scaddr_v[52]) & sc_wr_q));
   assign and_pccr0_load =     scaddr_v[52] & sc_wr_q;

   assign or_pccr0  =  {SCOM_WIDTH {or_pccr0_load}}  & sc_wdata;
   assign and_pccr0 = ({SCOM_WIDTH {and_pccr0_load}} & sc_wdata)  | ({SCOM_WIDTH {and_pccr0_ones}} & andmask_ones);

   // PCCR0(32:38) are pervasive modes and miscellaneous controls: set by SCOM; reset by SCOM
   // 32 = Enable Debug mode
   // 33 = Enable Ram mode
   // 34 = Enable Error Inject mode
   // 35 = Enable External Debug Stop
   // 36 = Disable xstop reporting in Ram mode
   // 37 = Enable fast clockstop
   // 38 = Disable power savings
   // 39 = Disable overrun checking
   assign pccr0_pervModes_in = or_pccr0[32:39] | (pccr0_out[32:39] & and_pccr0[32:39]);

   // PCCR0(40:43) are spare bits: set by SCOM; reset by SCOM
   assign pccr0_spare_in = or_pccr0[40:43] | (pccr0_out[40:43] & and_pccr0[40:43]);

   // PCCR0(48:51) is the Recoverable Error Counter
   // Incremented when gated by a new recoverable error; PCCR0 parity recalculated.
   assign incr_recErrCntr   = recErrCntr_q[0:3] + 4'b0001;
   assign recErrCntr_pargen = (^{incr_recErrCntr, pccr0_out[32:43], pccr0_out[53:59]});

   assign recErrCntr_in = ((scaddr_v[51] & sc_wr_q) == 1'b1) 	? sc_wdata[48:51] :
			  (rg_rg_gateRecErrCntr == 1'b1) 	? incr_recErrCntr :
			  recErrCntr_q[0:3];

   // PCCR0(T0=53:55, T1=57:59) Debug Action Selects:
   assign pccr0_dbgActSel_in[0:2] = or_pccr0[53:55] | (pccr0_out[53:55] & and_pccr0[53:55]);

   generate
      if (`THREADS == 2)
      begin : T1_DBA
	 assign pccr0_dbgActSel_in[3:5] = or_pccr0[57:59] | (pccr0_out[57:59] & and_pccr0[57:59]);
      end
   endgenerate

   //  Load Register
   assign pccr0_d = {pccr0_pervModes_in, pccr0_spare_in, pccr0_dbgActSel_in};

   //  SCOM output - reserves locations for T1 DBA bits when `THREADS=2
   generate
      if (`THREADS == 1)
      begin : T1_PCCR0
	 assign pccr0_out = {tidn_32, pccr0_q[0:11], 4'h0, recErrCntr_q, 1'b0, pccr0_q[12:14], 8'h00};
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_PCCR0
	 assign pccr0_out = {tidn_32, pccr0_q[0:11], 4'h0, recErrCntr_q, 1'b0, pccr0_q[12:14], 1'b0, pccr0_q[15:17], 4'h0};
      end
   endgenerate

   //  Parity Bit
   assign pccr0_par_in   = {pccr0_d, recErrCntr_in[0:3]};

   assign pccr0_par_d[0] = (sc_wr_q & (|scaddr_v[51:53]) == 1'b1) ? (^pccr0_par_in) :
			   (rg_rg_gateRecErrCntr == 1'b1) 	  ? recErrCntr_pargen :
			    pccr0_par_q[0];

   assign pccr0_par_err = ((^pccr0_out) ^ pccr0_par_q[0]) | (sc_wr_q & (|scaddr_v[51:53]) & sc_parity_error_inj);


   //---------------------------------------------------------------------
   // Special Attention and Mask Register
   // SPATTN RW address       = 54
   // SPATTN WO with and-mask = 55
   // SPATTN WO with or-mask  = 56

   assign or_spattn_load  =    (scaddr_v[54] | scaddr_v[56]) & sc_wr_q;
   assign and_spattn_ones = (~((scaddr_v[54] | scaddr_v[55]) & sc_wr_q));
   assign and_spattn_load =     scaddr_v[55] & sc_wr_q;

   assign or_spattn  =  {SCOM_WIDTH {or_spattn_load}}  & sc_wdata;
   assign and_spattn = ({SCOM_WIDTH {and_spattn_load}} & sc_wdata)  | ({SCOM_WIDTH {and_spattn_ones}} & andmask_ones);

   assign spattn_unused = {16-SPATTN_USED {1'b0}};

   // Special Attention Data:
   // attn_instr: Attention signal generated by attn instruction
   assign spattn_attn_instr_in = or_spattn[32:32 + `THREADS-1]  | err_attention_instr_q[0:`THREADS-1] |
   	                        (spattn_out[32:32 + `THREADS-1] & and_spattn[32:32 + `THREADS-1]);

   assign spattn_data_d = spattn_attn_instr_in;

   // Special Attention Mask: set by SCOM; reset by SCOM
   assign spattn_mask_d = or_spattn[48:(48 + SPATTN_USED-1)]  |
   		         (spattn_out[48:(48 + SPATTN_USED-1)] & and_spattn[48:(48 + SPATTN_USED-1)]);

   // SCOM output: Reserves locations for T1 bits when `THREADS=1
   generate
      if (`THREADS == 1)
      begin : T1_SPATTN
	 assign spattn_out = {tidn_32, spattn_data_q, spattn_unused, spattn_mask_q, spattn_unused};
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_SPATTN
	 assign spattn_out = {tidn_32, spattn_data_q, spattn_unused, spattn_mask_q, spattn_unused};
      end
   endgenerate

   //  Parity Bit
   assign spattn_par_d[0] = (sc_wr_q & (|scaddr_v[54:56])) == 1'b1 ? (^spattn_mask_d) :
			    spattn_par_q[0];

   assign spattn_par_err = ((^spattn_mask_q) ^ spattn_par_q[0]) | (sc_wr_q & (|scaddr_v[54:56]) & sc_parity_error_inj);


   //---------------------------------------------------------------------
   // Debug Select Registers
   // ARDSR RW address   = 59
   // IDSR  RW address   = 60
   // MPDSR RW address   = 61
   // XDSR  RW address   = 62
   // LDSR  RW address   = 63

   assign ardsr_data_in[0:10]  = ((scaddr_v[59] & sc_wr_q) == 1'b1) ? sc_wdata[32:42] : ardsr_out[32:42];
   assign ardsr_data_in[11:21] = ((scaddr_v[59] & sc_wr_q) == 1'b1) ? sc_wdata[48:58] : ardsr_out[48:58];

   assign ardsr_d   =  ardsr_data_in;
   //  AXU + RV debug mux controls
   assign ardsr_out = {tidn_32, ardsr_q[0:10], 5'b00000, ardsr_q[11:21], 5'b00000 };


   assign idsr_data_in[0:10]   = ((scaddr_v[60] & sc_wr_q) == 1'b1) ? sc_wdata[32:42] : idsr_out[32:42];
   assign idsr_data_in[11:21]  = ((scaddr_v[60] & sc_wr_q) == 1'b1) ? sc_wdata[48:58] : idsr_out[48:58];

   assign idsr_d   =  idsr_data_in;
   //  IU debug mux controls
   assign idsr_out = {tidn_32, idsr_q[0:10], 5'b00000, idsr_q[11:21], 5'b00000 };


   assign mpdsr_data_in[0:10]  = ((scaddr_v[61] & sc_wr_q) == 1'b1) ? sc_wdata[32:42] : mpdsr_out[32:42];
   assign mpdsr_data_in[11:21] = ((scaddr_v[61] & sc_wr_q) == 1'b1) ? sc_wdata[48:58] : mpdsr_out[48:58];

   assign mpdsr_d   =  mpdsr_data_in;
   //  MMU + PC debug mux controls
   assign mpdsr_out = {tidn_32, mpdsr_q[0:10], 5'b00000, mpdsr_q[11:21], 5'b00000 };


   assign xdsr_data_in[0:10]   = ((scaddr_v[62] & sc_wr_q) == 1'b1) ? sc_wdata[32:42] : xdsr_out[32:42];

   assign xdsr_d   =  xdsr_data_in;
   //  XU debug mux controls
   assign xdsr_out = {tidn_32, xdsr_q[0:10], {21 {1'b0}} };


   assign ldsr_data_in[0:10]   = ((scaddr_v[63] & sc_wr_q) == 1'b1) ? sc_wdata[32:42] : ldsr_out[32:42];
   assign ldsr_data_in[11:21]  = ((scaddr_v[63] & sc_wr_q) == 1'b1) ? sc_wdata[48:58] : ldsr_out[48:58];

   assign ldsr_d   =  ldsr_data_in;
   //  LSU debug mux controls
   assign ldsr_out = {tidn_32, ldsr_q[0:10], 5'b00000, ldsr_q[11:21], 5'b00000 };


   //---------------------------------------------------------------------
   // Error Inject Register
   // ERRINJ RW address = 9

   assign errinj_errtype_in[0:22] = ((scaddr_v[9] & sc_wr_q) == 1'b1) ? sc_wdata[32:54] :
				    (errinj_out[32:54] & (~rg_rg_errinj_shutoff[0:22])) ;

   generate
      if (`THREADS > 1)
      begin : T1_ERRINJ
	 assign errinj_errtype_in[23:31] = ((scaddr_v[9] & sc_wr_q) == 1'b1) ? sc_wdata[55:63] :
					   (errinj_out[55:63] & (~rg_rg_errinj_shutoff[23:31]));
      end
   endgenerate

   assign errinj_d = errinj_errtype_in;

   generate
      if (`THREADS == 1)
      begin : T1_INJOUT
	 assign errinj_out = {tidn_32, errinj_q, 9'b000000000};
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_INJOUT
	 assign errinj_out = {tidn_32, errinj_q};
      end
   endgenerate

//=====================================================================
// SCOM Register Read
//=====================================================================
   assign scaddr_fir = scaddr_v[0]  | scaddr_v[3]  | scaddr_v[4]  | scaddr_v[6]  | scaddr_v[5]  |
   	               scaddr_v[19] | scaddr_v[10] | scaddr_v[13] | scaddr_v[14] | scaddr_v[16] |
		       scaddr_v[20] | scaddr_v[23] | scaddr_v[24] | scaddr_v[26] ;


   assign sc_rdata = ({SCOM_WIDTH {scaddr_v[40]}} &  ramic_out)    |
                     ({SCOM_WIDTH {scaddr_v[41]}} &  rami_out) 	   |
                     ({SCOM_WIDTH {scaddr_v[42]}} &  ramc_out) 	   |
                     ({SCOM_WIDTH {scaddr_v[45]}} &  ramd_q[0:63]) |
                     ({SCOM_WIDTH {scaddr_v[46]}} &  ramdh_out)    |
                     ({SCOM_WIDTH {scaddr_v[47]}} &  ramdl_out)    |
                     ({SCOM_WIDTH {scaddr_v[48]}} &  thrctl_out)   |
                     ({SCOM_WIDTH {scaddr_v[51]}} &  pccr0_out)    |
                     ({SCOM_WIDTH {scaddr_v[54]}} &  spattn_out)   |
                     ({SCOM_WIDTH {scaddr_v[59]}} &  ardsr_out)    |
                     ({SCOM_WIDTH {scaddr_v[60]}} &  idsr_out) 	   |
                     ({SCOM_WIDTH {scaddr_v[61]}} &  mpdsr_out)    |
                     ({SCOM_WIDTH {scaddr_v[62]}} &  xdsr_out) 	   |
                     ({SCOM_WIDTH {scaddr_v[63]}} &  ldsr_out) 	   |
                     ({SCOM_WIDTH {scaddr_v[9] }} &  errinj_out)   |
                     ({SCOM_WIDTH {scaddr_fir  }} &  fir_data_out) ;

//=====================================================================
// Output + Signal Assignments
//=====================================================================
   // RAM Command Signals
   assign pc_iu_ram_instr 	= rami_out[32:63];
   assign pc_iu_ram_instr_ext 	= ramc_out[32:35];
   assign pc_iu_ram_execute 	= ram_execute_q;

   assign pc_iu_ram_active 	= ram_active_out;
   assign pc_xu_ram_active 	= ram_active_out;
   assign pc_fu_ram_active 	= ram_active_out;
   assign pc_lq_ram_active 	= ram_active_out;

   assign rg_rg_ram_mode 	= ram_mode_q;

   assign ram_msrovren_d 	= ram_mode_d & ramc_out[48];
   assign pc_xu_msrovride_enab 	= ram_msrovren_q;

   assign ram_msrovrpr_d 	= ram_mode_d & ramc_out[49];
   assign pc_xu_msrovride_pr 	= ram_msrovrpr_q;

   assign ram_msrovrgs_d 	= ram_mode_d & ramc_out[50];
   assign pc_xu_msrovride_gs 	= ram_msrovrgs_q;

   assign ram_msrovrde_d 	= ram_mode_d & ramc_out[51];
   assign pc_xu_msrovride_de 	= ram_msrovrde_q;

   assign ram_force_d 		= ram_mode_d & ramc_out[52];
   assign pc_iu_ram_force_cmplt = ram_force_q;

   assign ram_flush_d = {2 {ram_enab_d}} & ramc_out[53:54];

   generate
      if (`THREADS == 1)
      begin : T1_RAMCTL
	 assign pc_iu_ram_flush_thread = ram_flush_q[0:0];
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_RAMCTL
	 assign pc_iu_ram_flush_thread = ram_flush_q[0:1];
      end
   endgenerate

   assign rg_rg_load_sramd 	= load_sramd_q;
   assign rg_rg_sramd_din  	= ramd_q[0:63];

   //---------------------------------------------------------------------
   // Thread Control Signals
   //  an_ac_debug_stop, when enabled, forces all THREADS to stop
   assign external_debug_stop = {`THREADS {pccr0_out[35] & ext_debug_stop_q}};

   assign tx_stop_d  =	 {`THREADS {ct_rg_hold_during_init}}  |  pm_thread_stop_q  |
			 ((thrctl_out[32:32+`THREADS-1] | external_debug_stop[0:`THREADS-1]) & (~tx_step_val_q[0:`THREADS-1]));

   assign pc_iu_stop = tx_stop_q[0:`THREADS-1];

   assign pc_iu_pm_fetch_halt = pm_fetch_halt_q[0:`THREADS-1];

   // tx_step latch used to keep the pc_iu_stop and pc_iu_step changes synchronized.
   assign tx_step_d  = tx_step_val_q[0:`THREADS-1];
   assign pc_iu_step = tx_step_q[0:`THREADS-1];

   assign ac_an_pm_thread_running = thrctl_out[40:40+`THREADS-1];

   // Debug disables for external interrupts and Timers
   assign extirpts_dis_d 	     = debug_mode_d & thrctl_out[52];
   assign pc_xu_extirpts_dis_on_stop = extirpts_dis_q;

   assign timebase_dis_d 	     = debug_mode_d & thrctl_out[53];
   assign pc_xu_timebase_dis_on_stop = timebase_dis_q;

   assign decrem_dis_d 		     = debug_mode_d & thrctl_out[54];
   assign pc_xu_decrem_dis_on_stop   = decrem_dis_q;

   //---------------------------------------------------------------------
   // PC Configuration Signals
   assign trace_bus_enable_d 	 = pccr0_out[32] | sp_rg_trace_bus_enable;
   assign rg_db_trace_bus_enable = trace_bus_enable_q;
   assign pc_iu_trace_bus_enable = trace_bus_enable_q;
   assign pc_fu_trace_bus_enable = trace_bus_enable_q;
   assign pc_rv_trace_bus_enable = trace_bus_enable_q;
   assign pc_mm_trace_bus_enable = trace_bus_enable_q;
   assign pc_xu_trace_bus_enable = trace_bus_enable_q;
   assign pc_lq_trace_bus_enable = trace_bus_enable_q;

   // ACT control for latches gated with debug_mode.
   assign debug_mode_d 	 = pccr0_out[32];
   assign debug_mode_act = scom_wr_act | debug_mode_d | debug_mode_q;

   // ACT control for latches gated with ram_enable.
   assign ram_enab_d 	 = pccr0_out[33];
   assign ram_enab_act 	 = ram_enab_d  | ram_enab_q;
   assign ram_ctrl_act 	 = scom_wr_act | (|ramc_status_in);
   assign ram_data_act 	 = scom_wr_act | xu_ram_data_val_q | fu_ram_data_val_q | lq_ram_data_val_q;

   // ACT control for latches gated with errinj_enable.
   assign errinj_enab_d	 	= pccr0_out[34];
   assign errinj_enab_act      	= errinj_enab_d | errinj_enab_q;
   assign errinj_enab_scom_act 	= errinj_enab_act | scom_wr_act;

   assign rg_rg_xstop_report_ovride = pccr0_out[36];

   assign rg_rg_fast_xstop_enable = debug_mode_d & pccr0_out[37];

   assign rg_ct_dis_pwr_savings = pccr0_out[38];

   assign rg_rg_dis_overrun_chks = pccr0_out[39];

   assign rg_rg_maxRecErrCntrValue = (&recErrCntr_q[0:3]);


   generate
      if (`THREADS == 1)
      begin : T1_DBAOUT
   	 assign pccr0_dba_active_d[0] = (|pccr0_out[53:55]);

	 assign pc_iu_dbg_action    =  pccr0_out[53:55];
	 assign pc_iu_spr_dbcr0_edm =  pccr0_dba_active_q[0];
	 assign pc_xu_spr_dbcr0_edm =  pccr0_dba_active_q[0];
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : T2_DBAOUT
   	 assign pccr0_dba_active_d  = { (|pccr0_out[53:55]), (|pccr0_out[57:59]) };

	 assign pc_iu_dbg_action    = { pccr0_out[53:55], pccr0_out[57:59] };
	 assign pc_iu_spr_dbcr0_edm =   pccr0_dba_active_q[0:1];
	 assign pc_xu_spr_dbcr0_edm =   pccr0_dba_active_q[0:1];
      end
   endgenerate

   //---------------------------------------------------------------------
   // Special Attention Signals
   assign spattn_out_masked = spattn_data_q & (~spattn_mask_q);

   // Drive out special attention signals (thread specific)
   assign ac_an_special_attn = spattn_out_masked[0:`THREADS-1];

   //---------------------------------------------------------------------
   // Debug Select Controls
   assign pc_iu_debug_mux1_ctrls = idsr_out[32:42];
   assign pc_iu_debug_mux2_ctrls = idsr_out[48:58];

   assign pc_fu_debug_mux_ctrls  = ardsr_out[32:42];
   assign pc_rv_debug_mux_ctrls  = ardsr_out[48:58];

   assign pc_mm_debug_mux_ctrls  = mpdsr_out[32:42];
   assign rg_db_debug_mux_ctrls  = mpdsr_out[48:58];

   assign pc_xu_debug_mux_ctrls  = xdsr_out[32:42];

   assign pc_lq_debug_mux1_ctrls = ldsr_out[32:42];
   assign pc_lq_debug_mux2_ctrls = ldsr_out[48:58];

   //---------------------------------------------------------------------
   // Error Injection Signals
   assign inj_icache_parity_d 		= errinj_enab_d & errinj_out[32];
   assign inj_icachedir_parity_d 	= errinj_enab_d & errinj_out[33];
   assign inj_icachedir_multihit_d 	= errinj_enab_d & errinj_out[34];
   assign inj_dcache_parity_d 		= errinj_enab_d & errinj_out[35];
   assign inj_dcachedir_ldp_parity_d 	= errinj_enab_d & errinj_out[36];
   assign inj_dcachedir_stp_parity_d 	= errinj_enab_d & errinj_out[37];
   assign inj_dcachedir_ldp_multihit_d 	= errinj_enab_d & errinj_out[38];
   assign inj_dcachedir_stp_multihit_d 	= errinj_enab_d & errinj_out[39];
   assign inj_prefetcher_parity_d 	= errinj_enab_d & errinj_out[41];
   assign inj_relq_parity_d 		= errinj_enab_d & errinj_out[42];

   assign inj_sprg_ecc_d[0] 		= errinj_enab_d & errinj_out[45];
   assign inj_fx0regfile_parity_d[0] 	= errinj_enab_d & errinj_out[46];
   assign inj_fx1regfile_parity_d[0] 	= errinj_enab_d & errinj_out[47];
   assign inj_lqregfile_parity_d[0] 	= errinj_enab_d & errinj_out[48];
   assign inj_furegfile_parity_d[0] 	= errinj_enab_d & errinj_out[49];
   assign inj_llbust_attempt_d[0] 	= errinj_enab_d & errinj_out[50];
   assign inj_llbust_failed_d[0] 	= errinj_enab_d & errinj_out[51];
   assign inj_cpArray_parity_d[0] 	= errinj_enab_d & errinj_out[52];

   generate
      if (`THREADS > 1)
      begin : ERRINJOUT_2T
	 assign inj_sprg_ecc_d[1] 	   = errinj_enab_d & errinj_out[55];
	 assign inj_fx0regfile_parity_d[1] = errinj_enab_d & errinj_out[56];
	 assign inj_fx1regfile_parity_d[1] = errinj_enab_d & errinj_out[57];
	 assign inj_lqregfile_parity_d[1]  = errinj_enab_d & errinj_out[58];
	 assign inj_furegfile_parity_d[1]  = errinj_enab_d & errinj_out[59];
	 assign inj_llbust_attempt_d[1]    = errinj_enab_d & errinj_out[60];
	 assign inj_llbust_failed_d[1]     = errinj_enab_d & errinj_out[61];
   	 assign inj_cpArray_parity_d[1]	   = errinj_enab_d & errinj_out[62];
      end
   endgenerate

   assign pc_iu_inj_icache_parity 	   = inj_icache_parity_q;
   assign pc_iu_inj_icachedir_parity 	   = inj_icachedir_parity_q;
   assign pc_iu_inj_icachedir_multihit 	   = inj_icachedir_multihit_q;
   assign pc_lq_inj_dcache_parity 	   = inj_dcache_parity_q;
   assign pc_lq_inj_dcachedir_ldp_parity   = inj_dcachedir_ldp_parity_q;
   assign pc_lq_inj_dcachedir_stp_parity   = inj_dcachedir_stp_parity_q;
   assign pc_lq_inj_dcachedir_ldp_multihit = inj_dcachedir_ldp_multihit_q;
   assign pc_lq_inj_dcachedir_stp_multihit = inj_dcachedir_stp_multihit_q;
   assign sc_parity_error_inj 		   = errinj_enab_d & errinj_out[40];
   assign pc_lq_inj_prefetcher_parity 	   = inj_prefetcher_parity_q;
   assign pc_lq_inj_relq_parity 	   = inj_relq_parity_q;

   assign pc_xu_inj_sprg_ecc[0:`THREADS-1] 	  = inj_sprg_ecc_q[0:`THREADS-1];
   assign pc_fx0_inj_regfile_parity[0:`THREADS-1] = inj_fx0regfile_parity_q[0:`THREADS-1];
   assign pc_fx1_inj_regfile_parity[0:`THREADS-1] = inj_fx1regfile_parity_q[0:`THREADS-1];
   assign pc_lq_inj_regfile_parity[0:`THREADS-1]  = inj_lqregfile_parity_q[0:`THREADS-1];
   assign pc_fu_inj_regfile_parity[0:`THREADS-1]  = inj_furegfile_parity_q[0:`THREADS-1];
   assign pc_xu_inj_llbust_attempt[0:`THREADS-1]  = inj_llbust_attempt_q[0:`THREADS-1];
   assign pc_xu_inj_llbust_failed[0:`THREADS-1]   = inj_llbust_failed_q[0:`THREADS-1];
   assign pc_iu_inj_cpArray_parity[0:`THREADS-1]  = inj_cpArray_parity_q[0:`THREADS-1];

   //---------------------------------------------------------------------
   // Error Debug Signals
   assign  errDbg_t0_d[0:ERRDBG_T0_SIZE-1] = {
   		iu_pc_quiesce[0],		iu_pc_icache_quiesce[0],	lq_pc_ldq_quiesce[0],
		lq_pc_stq_quiesce[0], 		lq_pc_pfetch_quiesce[0],  	mm_pc_tlb_req_quiesce[0],
		mm_pc_tlb_ctl_quiesce[0],	mm_pc_htw_quiesce[0],		mm_pc_inval_quiesce[0],
		iu_pc_fx0_credit_ok[0],		iu_pc_fx1_credit_ok[0],		iu_pc_axu0_credit_ok[0],
		iu_pc_axu1_credit_ok[0],	iu_pc_lq_credit_ok[0],		iu_pc_sq_credit_ok[0]
		};


   generate
      if (`THREADS == 1)
      begin : ERRDBG_1T
      	assign errDbg_out = { errDbg_t0_q, {32-ERRDBG_T0_SIZE {1'b0}} };
      end
   endgenerate
   generate
      if (`THREADS == 2)
      begin : ERRDBG_2T
        assign errDbg_out = { errDbg_t0_q, errDbg_t1_q, 2'b00 };

	assign  errDbg_t1_d[0:ERRDBG_T1_SIZE-1] = {
   			iu_pc_quiesce[1],		iu_pc_icache_quiesce[1],	lq_pc_ldq_quiesce[1],
			lq_pc_stq_quiesce[1], 		lq_pc_pfetch_quiesce[1],  	mm_pc_tlb_req_quiesce[1],
			mm_pc_tlb_ctl_quiesce[1],	mm_pc_htw_quiesce[1],		mm_pc_inval_quiesce[1],
			iu_pc_fx0_credit_ok[1],		iu_pc_fx1_credit_ok[1],		iu_pc_axu0_credit_ok[1],
			iu_pc_axu1_credit_ok[1],	iu_pc_lq_credit_ok[1],		iu_pc_sq_credit_ok[1]
			};
      end
   endgenerate


//=====================================================================
// FIR Related Registers and Error Reporting
//=====================================================================
   pcq_regs_fir  fir_regs(
      .vdd(vdd),
      .gnd(gnd),
      .nclk(nclk),
      .lcb_clkoff_dc_b(lcb_clkoff_dc_b),
      .lcb_mpw1_dc_b(lcb_mpw1_dc_b),
      .lcb_mpw2_dc_b(lcb_mpw2_dc_b),
      .lcb_delay_lclkr_dc(lcb_delay_lclkr_dc),
      .lcb_act_dis_dc(lcb_act_dis_dc),
      .lcb_sg_0(lcb_sg_0),
      .lcb_func_slp_sl_thold_0(lcb_func_slp_sl_thold_0),
      .lcb_cfg_slp_sl_thold_0(lcb_cfg_slp_sl_thold_0),
      .cfgslp_d1clk(cfgslp_d1clk),
      .cfgslp_d2clk(cfgslp_d2clk),
      .cfgslp_lclk(cfgslp_lclk),
      .cfg_slat_d2clk(cfg_slat_d2clk),
      .cfg_slat_lclk(cfg_slat_lclk),
      .bcfg_scan_in(fir_mode_si),
      .func_scan_in(fir_func_si),
      .bcfg_scan_out(fir_mode_so),
      .func_scan_out(fir_func_so),
      // SCOM Satellite Interface
      .sc_active(scom_wr_act),
      .sc_wr_q(sc_wr_q),
      .sc_addr_v(scaddr_v),
      .sc_wdata(sc_wdata),
      .sc_rdata(fir_data_out),
      // FIR and Error Signals
      .ac_an_checkstop(ac_an_checkstop),
      .ac_an_local_checkstop(ac_an_local_checkstop),
      .ac_an_recov_err(ac_an_recov_err),
      .ac_an_trace_error(ac_an_trace_error),
      .ac_an_livelock_active(ac_an_livelock_active),
      .an_ac_checkstop(an_ac_checkstop),
      .rg_rg_any_fir_xstop(rg_rg_any_fir_xstop),
      .iu_pc_err_icache_parity(iu_pc_err_icache_parity),
      .iu_pc_err_icachedir_parity(iu_pc_err_icachedir_parity),
      .iu_pc_err_icachedir_multihit(iu_pc_err_icachedir_multihit),
      .lq_pc_err_dcache_parity(lq_pc_err_dcache_parity),
      .lq_pc_err_dcachedir_ldp_parity(lq_pc_err_dcachedir_ldp_parity),
      .lq_pc_err_dcachedir_stp_parity(lq_pc_err_dcachedir_stp_parity),
      .lq_pc_err_dcachedir_ldp_multihit(lq_pc_err_dcachedir_ldp_multihit),
      .lq_pc_err_dcachedir_stp_multihit(lq_pc_err_dcachedir_stp_multihit),
      .iu_pc_err_ierat_parity(iu_pc_err_ierat_parity),
      .iu_pc_err_ierat_multihit(iu_pc_err_ierat_multihit),
      .iu_pc_err_btb_parity(iu_pc_err_btb_parity),
      .lq_pc_err_derat_parity(lq_pc_err_derat_parity),
      .lq_pc_err_derat_multihit(lq_pc_err_derat_multihit),
      .mm_pc_err_tlb_parity(mm_pc_err_tlb_parity),
      .mm_pc_err_tlb_multihit(mm_pc_err_tlb_multihit),
      .mm_pc_err_tlb_lru_parity(mm_pc_err_tlb_lru_parity),
      .mm_pc_err_local_snoop_reject(mm_pc_err_local_snoop_reject),
      .lq_pc_err_l2intrf_ecc(lq_pc_err_l2intrf_ecc),
      .lq_pc_err_l2intrf_ue(lq_pc_err_l2intrf_ue),
      .lq_pc_err_invld_reld(lq_pc_err_invld_reld),
      .lq_pc_err_l2credit_overrun(lq_pc_err_l2credit_overrun),
      .scom_reg_par_checks(scom_reg_par_checks),
      .scom_sat_fsm_error(scom_fsm_err),
      .scom_ack_error(scom_ack_err),
      .lq_pc_err_prefetcher_parity(lq_pc_err_prefetcher_parity),
      .lq_pc_err_relq_parity(lq_pc_err_relq_parity),
      .xu_pc_err_sprg_ecc(xu_pc_err_sprg_ecc),
      .xu_pc_err_sprg_ue(xu_pc_err_sprg_ue),
      .xu_pc_err_regfile_parity(xu_pc_err_regfile_parity),
      .xu_pc_err_regfile_ue(xu_pc_err_regfile_ue),
      .lq_pc_err_regfile_parity(lq_pc_err_regfile_parity),
      .lq_pc_err_regfile_ue(lq_pc_err_regfile_ue),
      .fu_pc_err_regfile_parity(fu_pc_err_regfile_parity),
      .fu_pc_err_regfile_ue(fu_pc_err_regfile_ue),
      .iu_pc_err_cpArray_parity(iu_pc_err_cpArray_parity),
      .iu_pc_err_ucode_illegal(iu_pc_err_ucode_illegal),
      .iu_pc_err_mchk_disabled(iu_pc_err_mchk_disabled),
      .xu_pc_err_llbust_attempt(xu_pc_err_llbust_attempt),
      .xu_pc_err_llbust_failed(xu_pc_err_llbust_failed),
      .xu_pc_err_wdt_reset(xu_pc_err_wdt_reset),
      .iu_pc_err_debug_event(iu_pc_err_debug_event),
      .rg_rg_ram_mode(rg_rg_ram_mode),
      .rg_rg_ram_mode_xstop(rg_rg_ram_mode_xstop),
      .rg_rg_xstop_report_ovride(rg_rg_xstop_report_ovride),
      .rg_rg_xstop_err(rg_rg_xstop_err),
      .sc_parity_error_inject(sc_parity_error_inj),
      .rg_rg_errinj_shutoff(rg_rg_errinj_shutoff),
      .rg_rg_maxRecErrCntrValue(rg_rg_maxRecErrCntrValue),
      .rg_rg_gateRecErrCntr(rg_rg_gateRecErrCntr),
      .errDbg_out(errDbg_out),
      // Trace/Trigger Signals
      .dbg_fir0_err(dbg_fir0_err),
      .dbg_fir1_err(dbg_fir1_err),
      .dbg_fir2_err(dbg_fir2_err),
      .dbg_fir_misc(dbg_fir_misc)
   );

   assign scom_reg_par_checks 	= {pccr0_par_err, spattn_par_err};

   assign rg_ck_fast_xstop 	= rg_rg_fast_xstop_enable & rg_rg_any_fir_xstop;

//=====================================================================
// Trace/Trigger Signals
//=====================================================================
   assign dbg_scom =	{
			scom_act,              		//  0
			sc_req_q, 		    	//  1
			sc_wr_q, 		    	//  2
   			scaddr_predecode[0:5],		//  3:8
			scaddr_nvld_q, 	    		//  9
			sc_wr_nvld_q, 	    		// 10
			sc_rd_nvld_q 	    		// 11
			};


   assign dbg_thrctls = {
    			rg_rg_xstop_report_ovride,	//  0
    			pccr0_out[38],			//  1	 (dis_pwr_savings)
    			rg_rg_dis_overrun_chks,		//  2
    			rg_rg_maxRecErrCntrValue,	//  3
			ext_debug_stop_q,		//  4
 			dbg_spattn_data_q[0:1],		//  5:6
			dbg_power_managed_q[0:1],	//  7:8
			dbg_pm_thread_stop_q[0:1],	//  9:10
   			dbg_stop_dbg_event_q[0:1],	// 11:12
   			dbg_stop_dbg_dnh_q[0:1],	// 13:14
			dbg_tx_stop_q[0:1],		// 15:16
 			dbg_thread_running_q[0:1],	// 17:18
 			dbg_tx_step_q[0:1],		// 19:20
 			dbg_tx_step_done_q[0:1],	// 21:22
 			dbg_tx_step_req_q[0:1]		// 23:24
		     	};


   assign dbg_ram = 	{
			ram_mode_q,   		     	//  0
			dbg_ram_active_q[0:1],   	//  1:2
   			ram_execute_q,    		//  3
			ram_msrovren_q,			//  4
			ram_msrovrpr_q,			//  5
			ram_msrovrgs_q,			//  6
			ram_msrovrde_q,			//  7
			ram_unsupported_q, 		//  8
			rammed_instr_overrun,		//  9
   			ram_interrupt_q,      	     	// 10
			rg_rg_ram_mode_xstop,   	// 11
			ram_done_q, 		     	// 12
			xu_ram_data_val_q,   	     	// 13
			fu_ram_data_val_q,    	     	// 14
			lq_ram_data_val_q     	     	// 15
			};


   generate
      if (`THREADS == 1)
      	begin : DBG_1T
   	 assign dbg_ram_active_q	= {ram_active_q[0], 1'b0};
   	 assign dbg_spattn_data_q	= {err_attention_instr_q[0], 1'b0};
    	 assign dbg_power_managed_q	= {ct_rg_power_managed[0], 1'b0};
    	 assign dbg_pm_thread_stop_q	= {pm_thread_stop_q[0], 1'b0};
    	 assign dbg_stop_dbg_event_q	= {stop_dbg_event_q[0], 1'b0};
    	 assign dbg_stop_dbg_dnh_q	= {stop_dbg_dnh_q[0], 1'b0};
    	 assign dbg_tx_stop_q		= {tx_stop_q[0], 1'b0};
    	 assign dbg_thread_running_q	= {thrctl_out[40], 1'b0};
    	 assign dbg_tx_step_q		= {tx_step_q[0], 1'b0};
    	 assign dbg_tx_step_done_q	= {step_done_q[0], 1'b0};
    	 assign dbg_tx_step_req_q	= {tx_step_req_q[0], 1'b0};
     	end
      else
       	begin : DBG_2T
  	 assign dbg_ram_active_q	= ram_active_q[0:1];
   	 assign dbg_spattn_data_q	= err_attention_instr_q[0:1];
   	 assign dbg_power_managed_q	= ct_rg_power_managed[0:1];
   	 assign dbg_pm_thread_stop_q	= pm_thread_stop_q[0:1];
   	 assign dbg_stop_dbg_event_q	= stop_dbg_event_q[0:1];
   	 assign dbg_stop_dbg_dnh_q	= stop_dbg_dnh_q[0:1];
   	 assign dbg_tx_stop_q		= tx_stop_q[0:1];
   	 assign dbg_thread_running_q	= thrctl_out[40:40+`THREADS-1];
   	 assign dbg_tx_step_q		= tx_step_q[0:1];
   	 assign dbg_tx_step_done_q	= step_done_q[0:1];
   	 assign dbg_tx_step_req_q	= tx_step_req_q[0:1];
      	end
   endgenerate


//=====================================================================
// Latches
//=====================================================================
   // debug config ring registers start
   tri_rlmreg_p #(.WIDTH(ARDSR_SIZE), .INIT(0)) axrv_dbgsel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ ARDSR_OFFSET:ARDSR_OFFSET + ARDSR_SIZE - 1]),
      .scout(dcfg_sov[ARDSR_OFFSET:ARDSR_OFFSET + ARDSR_SIZE - 1]),
      .din(ardsr_d),
      .dout(ardsr_q)
   );

   tri_rlmreg_p #(.WIDTH(IDSR_SIZE), .INIT(0)) iu_dbgsel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ IDSR_OFFSET:IDSR_OFFSET + IDSR_SIZE - 1]),
      .scout(dcfg_sov[IDSR_OFFSET:IDSR_OFFSET + IDSR_SIZE - 1]),
      .din(idsr_d),
      .dout(idsr_q)
   );

   tri_rlmreg_p #(.WIDTH(MPDSR_SIZE), .INIT(0)) mmpc_dbgsel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ MPDSR_OFFSET:MPDSR_OFFSET + MPDSR_SIZE - 1]),
      .scout(dcfg_sov[MPDSR_OFFSET:MPDSR_OFFSET + MPDSR_SIZE - 1]),
      .din(mpdsr_d),
      .dout(mpdsr_q)
   );

   tri_rlmreg_p #(.WIDTH(XDSR_SIZE), .INIT(0)) xu_dbgsel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ XDSR_OFFSET:XDSR_OFFSET + XDSR_SIZE - 1]),
      .scout(dcfg_sov[XDSR_OFFSET:XDSR_OFFSET + XDSR_SIZE - 1]),
      .din(xdsr_d),
      .dout(xdsr_q)
   );

   tri_rlmreg_p #(.WIDTH(LDSR_SIZE), .INIT(0)) lq_dbgsel_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ LDSR_OFFSET:LDSR_OFFSET + LDSR_SIZE - 1]),
      .scout(dcfg_sov[LDSR_OFFSET:LDSR_OFFSET + LDSR_SIZE - 1]),
      .din(ldsr_d),
      .dout(ldsr_q)
   );

   tri_rlmreg_p #(.WIDTH(PCCR0_SIZE), .INIT(0)) pccr0_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ PCCR0_OFFSET:PCCR0_OFFSET + PCCR0_SIZE - 1]),
      .scout(dcfg_sov[PCCR0_OFFSET:PCCR0_OFFSET + PCCR0_SIZE - 1]),
      .din(pccr0_d),
      .dout(pccr0_q)
   );

   tri_rlmreg_p #(.WIDTH(RECERRCNTR_SIZE), .INIT(0)) rec_err_cntr(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ RECERRCNTR_OFFSET:RECERRCNTR_OFFSET + RECERRCNTR_SIZE - 1]),
      .scout(dcfg_sov[RECERRCNTR_OFFSET:RECERRCNTR_OFFSET + RECERRCNTR_SIZE - 1]),
      .din(recErrCntr_in),
      .dout(recErrCntr_q)
   );

   tri_rlmreg_p #(.WIDTH(1), .INIT(0)) pccr0_par(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ PCCR0_PAR_OFFSET:PCCR0_PAR_OFFSET]),
      .scout(dcfg_sov[PCCR0_PAR_OFFSET:PCCR0_PAR_OFFSET]),
      .din(pccr0_par_d),
      .dout(pccr0_par_q)
   );

   tri_rlmreg_p #(.WIDTH(DCFG_STAGE1_SIZE), .INIT(0)) dcfg_stage1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(dcfg_siv[ DCFG_STAGE1_OFFSET:DCFG_STAGE1_OFFSET + DCFG_STAGE1_SIZE - 1]),
      .scout(dcfg_sov[DCFG_STAGE1_OFFSET:DCFG_STAGE1_OFFSET + DCFG_STAGE1_SIZE - 1]),
      .din( {debug_mode_d, ram_enab_d, errinj_enab_d, trace_bus_enable_d }),
      .dout({debug_mode_q, ram_enab_q, errinj_enab_q, trace_bus_enable_q })
   );
   // debug config ring registers end

   // boot config ring registers start
   tri_rlmreg_p #(.WIDTH(THRCTL1_SIZE), .INIT(0)) thrctl1_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ THRCTL1_OFFSET:THRCTL1_OFFSET + THRCTL1_SIZE - 1]),
      .scout(bcfg_sov[THRCTL1_OFFSET:THRCTL1_OFFSET + THRCTL1_SIZE - 1]),
      .din(thrctl1_d),
      .dout(thrctl1_q)
   );

   tri_rlmreg_p #(.WIDTH(THRCTL2_SIZE), .INIT(0)) thrctl2_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ THRCTL2_OFFSET:THRCTL2_OFFSET + THRCTL2_SIZE - 1]),
      .scout(bcfg_sov[THRCTL2_OFFSET:THRCTL2_OFFSET + THRCTL2_SIZE - 1]),
      .din(thrctl2_d),
      .dout(thrctl2_q)
   );

   tri_rlmreg_p #(.WIDTH(SPATTN_USED), .INIT(0)) spattn_data_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ SPATTN_DATA_OFFSET:SPATTN_DATA_OFFSET + SPATTN_USED - 1]),
      .scout(bcfg_sov[SPATTN_DATA_OFFSET:SPATTN_DATA_OFFSET + SPATTN_USED - 1]),
      .din(spattn_data_d),
      .dout(spattn_data_q)
   );

   tri_rlmreg_p #(.WIDTH(SPATTN_USED), .INIT({SPATTN_USED {1'b1}})) spattn_mask_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ SPATTN_MASK_OFFSET:SPATTN_MASK_OFFSET + SPATTN_USED - 1]),
      .scout(bcfg_sov[SPATTN_MASK_OFFSET:SPATTN_MASK_OFFSET + SPATTN_USED - 1]),
      .din(spattn_mask_d),
      .dout(spattn_mask_q)
   );

   tri_rlmreg_p #(.WIDTH(1), .INIT(SPATTN_PARITY_INIT)) spattn_par(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ SPATTN_PAR_OFFSET:SPATTN_PAR_OFFSET]),
      .scout(bcfg_sov[SPATTN_PAR_OFFSET:SPATTN_PAR_OFFSET]),
      .din(spattn_par_d),
      .dout(spattn_par_q)
   );

   tri_rlmreg_p #(.WIDTH(BCFG_STAGE1_T0_SIZE), .INIT(1)) bcfg_stage1_t0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ BCFG_STAGE1_T0_OFFSET:BCFG_STAGE1_T0_OFFSET + BCFG_STAGE1_T0_SIZE - 1]),
      .scout(bcfg_sov[BCFG_STAGE1_T0_OFFSET:BCFG_STAGE1_T0_OFFSET + BCFG_STAGE1_T0_SIZE - 1]),
      // Lowest order bit initializes to 1; add new bits on left side of vector
      .din( {iu_pc_err_attention_instr[0], iu_pc_stop_dbg_event[0],
      	     xu_pc_stop_dnh_instr[0],      iu_pc_step_done[0],  	an_ac_pm_fetch_halt[0],
      	     an_ac_pm_thread_stop[0], 	   an_ac_debug_stop, 		tx_stop_d[0] }),

      .dout({err_attention_instr_q[0],     stop_dbg_event_q[0],
      	     stop_dbg_dnh_q[0],      	   step_done_q[0],      	pm_fetch_halt_q[0],
      	     pm_thread_stop_q[0],	   ext_debug_stop_q,     	tx_stop_q[0] })
   );

   tri_ser_rlmreg_p #(.WIDTH(BCFG_STAGE2_T0_SIZE), .INIT(0)) bcfg_stage2_t0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(debug_mode_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ BCFG_STAGE2_T0_OFFSET:BCFG_STAGE2_T0_OFFSET + BCFG_STAGE2_T0_SIZE - 1]),
      .scout(bcfg_sov[BCFG_STAGE2_T0_OFFSET:BCFG_STAGE2_T0_OFFSET + BCFG_STAGE2_T0_SIZE - 1]),

      .din( {extirpts_dis_d,  timebase_dis_d,    decrem_dis_d,    pccr0_dba_active_d[0],
      	     tx_step_d[0],    tx_step_req_d[0],  tx_step_val_d[0] }),

      .dout({extirpts_dis_q,  timebase_dis_q,    decrem_dis_q,    pccr0_dba_active_q[0],
     	     tx_step_q[0],    tx_step_req_q[0],  tx_step_val_q[0] })
   );

   tri_rlmreg_p #(.WIDTH(ERRDBG_T0_SIZE), .INIT(0)) errdbg_t0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_act),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_cfgslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(bcfg_siv[ ERRDBG_T0_OFFSET:ERRDBG_T0_OFFSET + ERRDBG_T0_SIZE - 1]),
      .scout(bcfg_sov[ERRDBG_T0_OFFSET:ERRDBG_T0_OFFSET + ERRDBG_T0_SIZE - 1]),
      .din( errDbg_t0_d ),
      .dout(errDbg_t0_q )
   );

   generate
      if (`THREADS > 1)
      begin : T1_bcfg

	 tri_rlmreg_p #(.WIDTH(BCFG_STAGE1_T1_SIZE), .INIT(1)) bcfg_stage1_t1(
	    .vd(vdd),
	    .gd(gnd),
	    .nclk(nclk),
	    .act(tiup),
	    .thold_b(lcb_cfg_slp_sl_thold_0_b),
	    .sg(lcb_sg_0),
	    .force_t(force_cfgslp),
	    .delay_lclkr(lcb_delay_lclkr_dc),
	    .mpw1_b(lcb_mpw1_dc_b),
	    .mpw2_b(lcb_mpw2_dc_b),
	    .scin(bcfg_siv[ BCFG_STAGE1_T1_OFFSET:BCFG_STAGE1_T1_OFFSET + BCFG_STAGE1_T1_SIZE - 1]),
	    .scout(bcfg_sov[BCFG_STAGE1_T1_OFFSET:BCFG_STAGE1_T1_OFFSET + BCFG_STAGE1_T1_SIZE - 1]),
	    // Lowest order bit initializes to 1; add new bits on left side of vector
	    .din( {iu_pc_err_attention_instr[1],    iu_pc_stop_dbg_event[1],
	   	   xu_pc_stop_dnh_instr[1],	    iu_pc_step_done[1],	    	an_ac_pm_fetch_halt[1],
		   an_ac_pm_thread_stop[1],	    tx_stop_d[1] }),

	    .dout({err_attention_instr_q[1],	    stop_dbg_event_q[1],
	    	   stop_dbg_dnh_q[1],	    	    step_done_q[1],	    	pm_fetch_halt_q[1],
		   pm_thread_stop_q[1],	    	    tx_stop_q[1] })
	 );

	 tri_ser_rlmreg_p #(.WIDTH(BCFG_STAGE2_T1_SIZE), .INIT(0)) bcfg_stage2_t1(
	    .vd(vdd),
	    .gd(gnd),
	    .nclk(nclk),
	    .act(debug_mode_act),
	    .thold_b(lcb_cfg_slp_sl_thold_0_b),
	    .sg(lcb_sg_0),
	    .force_t(force_cfgslp),
	    .delay_lclkr(lcb_delay_lclkr_dc),
	    .mpw1_b(lcb_mpw1_dc_b),
	    .mpw2_b(lcb_mpw2_dc_b),
	    .scin(bcfg_siv[ BCFG_STAGE2_T1_OFFSET:BCFG_STAGE2_T1_OFFSET + BCFG_STAGE2_T1_SIZE - 1]),
	    .scout(bcfg_sov[BCFG_STAGE2_T1_OFFSET:BCFG_STAGE2_T1_OFFSET + BCFG_STAGE2_T1_SIZE - 1]),

	    .din( {tx_step_d[1],  tx_step_req_d[1],  tx_step_val_d[1],  pccr0_dba_active_d[1] }),

	    .dout({tx_step_q[1],  tx_step_req_q[1],  tx_step_val_q[1],  pccr0_dba_active_q[1] })
	 );

   	tri_rlmreg_p #(.WIDTH(ERRDBG_T1_SIZE), .INIT(0)) errdbg_t1(
      	.vd(vdd),
      	.gd(gnd),
      	.nclk(nclk),
      	.act(scom_act),
      	.thold_b(lcb_cfg_slp_sl_thold_0_b),
      	.sg(lcb_sg_0),
      	.force_t(force_cfgslp),
      	.delay_lclkr(lcb_delay_lclkr_dc),
      	.mpw1_b(lcb_mpw1_dc_b),
      	.mpw2_b(lcb_mpw2_dc_b),
      	.scin(bcfg_siv[ ERRDBG_T1_OFFSET:ERRDBG_T1_OFFSET + ERRDBG_T1_SIZE - 1]),
      	.scout(bcfg_sov[ERRDBG_T1_OFFSET:ERRDBG_T1_OFFSET + ERRDBG_T1_SIZE - 1]),
      	.din( errDbg_t1_d ),
      	.dout(errDbg_t1_q )
   	);
      end
   endgenerate
   // boot config ring registers end

   // core config ring registers start
   // NOTE: CCFG ring not used in PCQ; latch added for timing.
   tri_slat_scan #(.WIDTH(1), .INIT(1'b0)) ccfg_repwr(
      .vd(vdd),
      .gd(gnd),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk),
      .scan_in(ccfg_scan_in),
      .scan_out(ccfg_scan_out)
   );
   // core config ring registers end

   // func ring registers start
   tri_rlmreg_p #(.WIDTH(RAMI_SIZE), .INIT(0)) rami_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_wr_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ RAMI_OFFSET:RAMI_OFFSET + RAMI_SIZE - 1]),
      .scout(func_sov[RAMI_OFFSET:RAMI_OFFSET + RAMI_SIZE - 1]),
      .din(rami_d),
      .dout(rami_q)
   );


   tri_rlmreg_p #(.WIDTH(RAMC_SIZE), .INIT(0)) ramc_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ram_ctrl_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ RAMC_OFFSET:RAMC_OFFSET + RAMC_SIZE - 1]),
      .scout(func_sov[RAMC_OFFSET:RAMC_OFFSET + RAMC_SIZE - 1]),
      .din(ramc_d),
      .dout(ramc_q)
   );


   tri_rlmreg_p #(.WIDTH(RAMD_SIZE), .INIT(0)) ramd_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ram_data_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ RAMD_OFFSET:RAMD_OFFSET + RAMD_SIZE - 1]),
      .scout(func_sov[RAMD_OFFSET:RAMD_OFFSET + RAMD_SIZE - 1]),
      .din(ramd_d),
      .dout(ramd_q)
   );


   tri_rlmreg_p #(.WIDTH(FU_RAM_DIN_SIZE), .INIT(0)) fu_ram_din(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(fu_pc_ram_data_val),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ FU_RAM_DIN_OFFSET:FU_RAM_DIN_OFFSET + FU_RAM_DIN_SIZE - 1]),
      .scout(func_sov[FU_RAM_DIN_OFFSET:FU_RAM_DIN_OFFSET + FU_RAM_DIN_SIZE - 1]),
      .din(fu_ramd_load_data_d),
      .dout(fu_ramd_load_data_q)
   );


   tri_rlmreg_p #(.WIDTH(XU_RAM_DIN_SIZE), .INIT(0)) xu_ram_din(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(xu_pc_ram_data_val),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ XU_RAM_DIN_OFFSET:XU_RAM_DIN_OFFSET + XU_RAM_DIN_SIZE - 1]),
      .scout(func_sov[XU_RAM_DIN_OFFSET:XU_RAM_DIN_OFFSET + XU_RAM_DIN_SIZE - 1]),
      .din(xu_ramd_load_data_d),
      .dout(xu_ramd_load_data_q)
   );


   tri_rlmreg_p #(.WIDTH(LQ_RAM_DIN_SIZE), .INIT(0)) lq_ram_din(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(lq_pc_ram_data_val),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ LQ_RAM_DIN_OFFSET:LQ_RAM_DIN_OFFSET + LQ_RAM_DIN_SIZE - 1]),
      .scout(func_sov[LQ_RAM_DIN_OFFSET:LQ_RAM_DIN_OFFSET + LQ_RAM_DIN_SIZE - 1]),
      .din(lq_ramd_load_data_d),
      .dout(lq_ramd_load_data_q)
   );


   tri_rlmreg_p #(.WIDTH(ERRINJ_SIZE), .INIT(0)) errinj_reg(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(errinj_enab_scom_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ ERRINJ_OFFSET:ERRINJ_OFFSET + ERRINJ_SIZE - 1]),
      .scout(func_sov[ERRINJ_OFFSET:ERRINJ_OFFSET + ERRINJ_SIZE - 1]),
      .din(errinj_d),
      .dout(errinj_q)
   );


   tri_ser_rlmreg_p #(.WIDTH(SCOM_MISC_SIZE), .INIT(0)) sc_misc(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ SC_MISC_OFFSET:SC_MISC_OFFSET + SCOM_MISC_SIZE - 1]),
      .scout(func_sov[SC_MISC_OFFSET:SC_MISC_OFFSET + SCOM_MISC_SIZE - 1]),

      .din( {sc_req_d,   scaddr_nvld_d,    sc_wr_nvld_d,    sc_rd_nvld_d,
             sc_wr_d,    ram_flush_d,      load_sramd_d }),

      .dout({sc_req_q,   scaddr_nvld_q,    sc_wr_nvld_q,    sc_rd_nvld_q,
      	     sc_wr_q,    ram_flush_q,      load_sramd_q })
   );

   tri_rlmreg_p #(.WIDTH(64), .INIT(0)) scaddr_dec(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(scom_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ SCADDR_DEC_OFFSET:SCADDR_DEC_OFFSET + 64 - 1]),
      .scout(func_sov[SCADDR_DEC_OFFSET:SCADDR_DEC_OFFSET + 64 - 1]),
      .din(scaddr_v_d),
      .dout(scaddr_v_q)
   );

   tri_rlmreg_p #(.WIDTH(FUNC_STAGE1_SIZE), .INIT(0)) func_stage1(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(tiup),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ FUNC_STAGE1_OFFSET:FUNC_STAGE1_OFFSET + FUNC_STAGE1_SIZE - 1]),
      .scout(func_sov[FUNC_STAGE1_OFFSET:FUNC_STAGE1_OFFSET + FUNC_STAGE1_SIZE - 1]),
      .din( {an_ac_scom_cch, an_ac_scom_dch }),
      .dout({scom_cch_q,     scom_dch_q })
   );

   tri_ser_rlmreg_p #(.WIDTH(INJ_STAGE1_T0_SIZE), .INIT(0)) inj_stage1_t0(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(errinj_enab_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ INJ_STAGE1_T0_OFFSET:INJ_STAGE1_T0_OFFSET + INJ_STAGE1_T0_SIZE - 1]),
      .scout(func_sov[INJ_STAGE1_T0_OFFSET:INJ_STAGE1_T0_OFFSET + INJ_STAGE1_T0_SIZE - 1]),

      .din( {inj_icache_parity_d,      	   inj_icachedir_parity_d,       inj_icachedir_multihit_d,
      	     inj_dcache_parity_d,      	   inj_dcachedir_ldp_parity_d,   inj_dcachedir_stp_parity_d,
      	     inj_dcachedir_ldp_multihit_d, inj_dcachedir_stp_multihit_d, inj_prefetcher_parity_d,
	     inj_relq_parity_d,		   inj_sprg_ecc_d[0],            inj_fx0regfile_parity_d[0],
      	     inj_fx1regfile_parity_d[0],   inj_lqregfile_parity_d[0],    inj_furegfile_parity_d[0],
      	     inj_llbust_attempt_d[0],	   inj_llbust_failed_d[0],	 inj_cpArray_parity_d[0] }),

      .dout({inj_icache_parity_q,      	   inj_icachedir_parity_q,       inj_icachedir_multihit_q,
      	     inj_dcache_parity_q,      	   inj_dcachedir_ldp_parity_q,   inj_dcachedir_stp_parity_q,
      	     inj_dcachedir_ldp_multihit_q, inj_dcachedir_stp_multihit_q, inj_prefetcher_parity_q,
	     inj_relq_parity_q,            inj_sprg_ecc_q[0],      	 inj_fx0regfile_parity_q[0],
      	     inj_fx1regfile_parity_q[0],   inj_lqregfile_parity_q[0],    inj_furegfile_parity_q[0],
      	     inj_llbust_attempt_q[0],      inj_llbust_failed_q[0],	 inj_cpArray_parity_q[0] })

   );

   generate
      if (`THREADS == 1)
      begin : T1_INJSTG_BYP
	 assign func_sov[INJ_STAGE1_T1_OFFSET:INJ_STAGE1_T1_OFFSET + INJ_STAGE1_T1_SIZE - 1] =
	        func_siv[INJ_STAGE1_T1_OFFSET:INJ_STAGE1_T1_OFFSET + INJ_STAGE1_T1_SIZE - 1] ;
      end
   endgenerate

   generate
      if (`THREADS > 1)
      begin : T1_INJSTG

	 tri_ser_rlmreg_p #(.WIDTH(INJ_STAGE1_T1_SIZE), .INIT(0)) inj_stage1_t1(
	    .vd(vdd),
	    .gd(gnd),
	    .nclk(nclk),
	    .act(errinj_enab_act),
	    .thold_b(lcb_func_slp_sl_thold_0_b),
	    .sg(lcb_sg_0),
	    .force_t(force_funcslp),
	    .delay_lclkr(lcb_delay_lclkr_dc),
	    .mpw1_b(lcb_mpw1_dc_b),
	    .mpw2_b(lcb_mpw2_dc_b),
	    .scin(func_siv[ INJ_STAGE1_T1_OFFSET:INJ_STAGE1_T1_OFFSET + INJ_STAGE1_T1_SIZE - 1]),
	    .scout(func_sov[INJ_STAGE1_T1_OFFSET:INJ_STAGE1_T1_OFFSET + INJ_STAGE1_T1_SIZE - 1]),

	    .din( {inj_sprg_ecc_d[1],	    	inj_fx0regfile_parity_d[1],   inj_fx1regfile_parity_d[1],
	    	   inj_lqregfile_parity_d[1],	inj_furegfile_parity_d[1],    inj_llbust_attempt_d[1],
	    	   inj_llbust_failed_d[1], 	inj_cpArray_parity_d[1] }),

	    .dout({inj_sprg_ecc_q[1],	    	inj_fx0regfile_parity_q[1],   inj_fx1regfile_parity_q[1],
	    	   inj_lqregfile_parity_q[1],   inj_furegfile_parity_q[1],    inj_llbust_attempt_q[1],
	    	   inj_llbust_failed_q[1],	inj_cpArray_parity_q[1] })
	 );
      end
   endgenerate

   tri_ser_rlmreg_p #(.WIDTH(FUNC_STAGE3_SIZE), .INIT(0)) func_stage3(
      .vd(vdd),
      .gd(gnd),
      .nclk(nclk),
      .act(ram_enab_act),
      .thold_b(lcb_func_slp_sl_thold_0_b),
      .sg(lcb_sg_0),
      .force_t(force_funcslp),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .scin(func_siv[ FUNC_STAGE3_OFFSET:FUNC_STAGE3_OFFSET + FUNC_STAGE3_SIZE - 1]),
      .scout(func_sov[FUNC_STAGE3_OFFSET:FUNC_STAGE3_OFFSET + FUNC_STAGE3_SIZE - 1]),

      .din( {ram_mode_d,          ram_execute_d,      ram_msrovren_d,     ram_msrovrpr_d,
      	     ram_msrovrgs_d,      ram_msrovrde_d,     ram_force_d,        xu_pc_ram_data_val,
      	     fu_pc_ram_data_val,  lq_pc_ram_data_val, ram_active_d[0:1],  iu_pc_ram_unsupported,
      	     iu_pc_ram_interrupt, iu_pc_ram_done,     ramCmpltCntr_in[0:1] }),

      .dout({ram_mode_q,      	  ram_execute_q,      ram_msrovren_q,     ram_msrovrpr_q,
      	     ram_msrovrgs_q,      ram_msrovrde_q,     ram_force_q,        xu_ram_data_val_q,
      	     fu_ram_data_val_q,   lq_ram_data_val_q,  ram_active_q[0:1],  ram_unsupported_q,
      	     ram_interrupt_q,     ram_done_q,         ramCmpltCntr_q[0:1] })
   );
   // func ring registers end

//=====================================================================
// additional LCB Staging
//=====================================================================
   // Config ring thold staging - power managaged
   assign cfg_slat_thold_b = (~lcb_cfg_sl_thold_0);
   assign cfg_slat_force   = lcb_sg_0;

   tri_lcbs  lcbs_cfg(
      .vd(vdd),
      .gd(gnd),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .nclk(nclk),
      .force_t(cfg_slat_force),
      .thold_b(cfg_slat_thold_b),
      .dclk(cfg_slat_d2clk),
      .lclk(cfg_slat_lclk)
   );

   // Config ring thold staging - NOT power managed
   tri_lcbor  lcbor_cfgslp(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(lcb_cfg_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_cfgslp),
      .thold_b(lcb_cfg_slp_sl_thold_0_b)
   );

   tri_lcbnd  lcbn_cfgslp(
      .vd(vdd),
      .gd(gnd),
      .act(tiup),
      .delay_lclkr(lcb_delay_lclkr_dc),
      .mpw1_b(lcb_mpw1_dc_b),
      .mpw2_b(lcb_mpw2_dc_b),
      .nclk(nclk),
      .force_t(force_cfgslp),
      .sg(lcb_sg_0),
      .thold_b(lcb_cfg_slp_sl_thold_0_b),
      .d1clk(cfgslp_d1clk),
      .d2clk(cfgslp_d2clk),
      .lclk(cfgslp_lclk)
   );

   // Func ring thold staging - NOT power managed
   tri_lcbor  lcbor_funcslp(
      .clkoff_b(lcb_clkoff_dc_b),
      .thold(lcb_func_slp_sl_thold_0),
      .sg(lcb_sg_0),
      .act_dis(lcb_act_dis_dc),
      .force_t(force_funcslp),
      .thold_b(lcb_func_slp_sl_thold_0_b)
   );

//=====================================================================
// Scan Connections
//=====================================================================
   // Boot config ring
   // includes latches in pcq_regs along with the pcq_regs_fir boot scan ring
   assign bcfg_siv[0:BCFG_RIGHT] = {bcfg_scan_in, bcfg_sov[0:BCFG_RIGHT - 1]};
   assign fir_mode_si 	= bcfg_sov[BCFG_RIGHT];
   assign bcfg_scan_out = fir_mode_so & scan_dis_dc_b;

   // Func config ring
   // includes latches in pcq_regs along with the pcq_regs_fir func scan ring
   assign func_siv[0:FUNC_RIGHT] = {func_scan_in, func_sov[0:FUNC_RIGHT - 1]};
   assign fir_func_si   = func_sov[FUNC_RIGHT];
   assign func_scan_out = fir_func_so & scan_dis_dc_b;

   // Debug config ring
   // includes just pcq_regs latches
   assign dcfg_siv[0:DCFG_RIGHT] = {dcfg_scan_in, dcfg_sov[0:DCFG_RIGHT - 1]};
   assign dcfg_scan_out = dcfg_sov[DCFG_RIGHT] & scan_dis_dc_b;


endmodule
